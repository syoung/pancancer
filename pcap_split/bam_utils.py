import os
import header_utils
import utils
import subprocess

def get_bam_file(dirpath):
    """Get the BAM file in the directory - assumes one BAM file"""

    assert(os.path.isdir(dirpath))
    for filename in os.listdir(dirpath):
        if filename.endswith(".bam"):
            return os.path.join(dirpath, filename)


def lane_level_bam_from_fastq(RG, workdir):
    """Create lane level bam, assuming bamtofastq has already been run"""

    first_reads = os.path.join(workdir, "%s_1.fq" % RG["ID"])
    second_reads = os.path.join(workdir, "%s_2.fq" % RG["ID"])
    unmatched_first_reads = os.path.join(workdir, "%s_o1.fq" % RG["ID"])
    unmatched_second_reads = os.path.join(workdir, "%s_o2.fq" % RG["ID"])
    single_reads = os.path.join(workdir, "%s_s.fq" % RG["ID"])

    bam_filename = "%s/%s.paired.bam" % (workdir, RG["ID"])

    if not os.path.exists(first_reads):
        print("WARNING: no paired reads for RG %s skipping" % first_reads)
        return False, bam_filename

    if not os.path.exists(second_reads):
        print("WARNING: no paired reads for RG %s skipping" % second_reads)
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
        return False, bam_filename

    return True, bam_filename

def gen_unaligned_bam(bam_filename, analysis_id, metadata, specimen_dict, work_dir, output_dir):
    """
    The bulk of the work, calls splitting, generates new headers, generates initial 
    unaligned BAM, reheaders with new headers
    """

    read_group_sam = os.path.join(output_dir, 'rg_header.sam')

    #get the read groups from the original sample level BAM
    os.system("samtools view -H %s | grep \"@RG\" > %s" %(bam_filename, read_group_sam))

    rg_file = open(read_group_sam, "r")

    #create the read group fastqs
    subprocess.check_call("bamtofastq outputperreadgroup=1 gz=1 level=1 inputbuffersize=2097152000 outputdir=%s < %s" %(work_dir, bam_filename), shell=True)
        
    log_file_path = (os.path.join(output_dir, "log.txt"))
    log_file = open(log_file_path, "a")

    if(header_utils.is_valid_analysis(metadata, log_file)):
        for line in rg_file:
            rg_dict = header_utils.get_read_group_info(line)
            header = header_utils.create_header(output_dir, metadata, rg_dict, specimen_dict)
         
            valid_bam, lane_level_bam = lane_level_bam_from_fastq(rg_dict, work_dir)
            if not valid_bam:
                print("WARNING: lane level bam not created for %s skipping" % lane_level_bam)
                continue

            final_file = header_utils.rehead(output_dir, lane_level_bam, header, rg_dict["ID"], analysis_id)
            md5_file = open(final_file + '.md5', "w")
            md5_file.write(utils.calc_md5sum(final_file))
            md5_file.close()
            os.remove(lane_level_bam)

        rg_file.close()
        utils.clean_up_dir(output_dir)
        log_file.close()
    else:
        print "Invalid header/metadata for BAM: %s" % bam_filename
