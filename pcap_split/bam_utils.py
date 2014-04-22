import os
import header_utils
import utils
import logging
import multiprocessing
import subprocess

default_logger = logging.getLogger(name='pcap_split')

class BAMException(Exception):
    pass

def get_bam_file(dirpath, logger=default_logger):
    """Get the BAM file in the directory - assumes one BAM file"""

    if not os.path.isdir(dirpath):
        msg = "Directory for BAM file does not exist: %s" % dirpath
        logger.error(msg)
        raise BAMException(msg)

    for filename in os.listdir(dirpath):
        if filename.endswith(".bam"):
            return os.path.join(dirpath, filename)


def lane_level_bam_from_fastq(RG, workdir, logger=default_logger):
    """Create lane level bam, assuming bamtofastq has already been run"""

    first_reads = os.path.join(workdir, "%s_1.fq.gz" % RG["ID"])
    second_reads = os.path.join(workdir, "%s_2.fq.gz" % RG["ID"])
    unmatched_first_reads = os.path.join(workdir, "%s_o1.fq.gz" % RG["ID"])
    unmatched_second_reads = os.path.join(workdir, "%s_o2.fq.gz" % RG["ID"])
    single_reads = os.path.join(workdir, "%s_s.fq" % RG["ID"])

    bam_filename = "%s/%s.paired.bam" % (workdir, RG["ID"])

    if not os.path.exists(first_reads):
        logger.warning("skipping RG that has no paired reads: %s" % first_reads)
        return False, bam_filename

    if not os.path.exists(second_reads):
        logger.warning("skipping RG that has no paired reads %s" % second_reads)
        return False, bam_filename

    #don't md5sum at this point because we go ahead and reheader 
    exit_code = os.system("fastqtobam I=%s I=%s gz=1 level=1 threads=3 RGID=%s:%s RGCN=%s RGPL=%s RGLB=%s RGPI=%s RGSM=%s RGPU=%s RGDT=%s > %s" %
                          (first_reads, second_reads, 
                           RG["CN"], RG["ID"], RG["CN"], RG["PL"], RG["LB"], RG["PI"], RG["SM"], RG["PU"], RG["DT"], 
                           bam_filename))

    if exit_code != 0:
        #remove the bam file if something goes wrong
        if os.path.exists(bam_filename):
            os.remove(bam_filename)
        logger.warning("removing bam file %s after fastqtobam returned error: %d" % (bam_filename, exit_code))
        return False, bam_filename

    return True, bam_filename

def process_rg(analysis_id, rg_dict, header, output_dir, logger=default_logger):

    valid_bam, lane_level_bam = lane_level_bam_from_fastq(rg_dict, output_dir)
    if not valid_bam:
        return
    
    final_file = header_utils.rehead(output_dir, lane_level_bam, header, rg_dict["ID"], analysis_id)
    md5_file = open(final_file + '.md5', "w")
    md5_file.write(utils.calc_md5sum(final_file))
    md5_file.close()


def gen_unaligned_bam(bam_filename, analysis_id, metadata, specimen_dict, work_dir, output_dir, num_processes=4, logger=default_logger ):
    """
    The bulk of the work, calls splitting, generates new headers, generates initial 
    unaligned BAM, reheaders with new headers
    """

    read_group_sam = os.path.join(output_dir, 'rg_header.sam')

    #get the read groups from the original sample level BAM
    os.system("samtools view -H %s | grep \"@RG\" > %s" %(bam_filename, read_group_sam))

    rg_file = open(read_group_sam, "r")

    #create the read group fastqs
    try:
        cmd = "bamtofastq outputperreadgroup=1 gz=1 level=1 inputbuffersize=2097152000 outputdir=%s `mktemp -p %s bamtofastq_XXXXXXXXX` < %s" %(work_dir, workfi bam_filename)
        logger.info("Running %s" % cmd)
        subprocess.check_call(cmd, shell=True)
    except:
        print "Failure in bam splitting"
        return 1
        

    if(header_utils.is_valid_analysis(metadata)):
        pool = multiprocessing.Pool(processes=num_processes)
        results = []
        for line in rg_file:
            rg_dict = header_utils.get_read_group_info(line)
            header = header_utils.create_header(output_dir, metadata, rg_dict, specimen_dict)
            r = pool.apply_async(process_rg, (analysis_id, rg_dict, header, work_dir))
            results.append(r)

        rg_file.close()

        for r in results:
            r.get()

        utils.clean_up_dir(output_dir)

    else:
        print "Invalid header/metadata for BAM" % bam_filename
        return 1
    return 0
