#../fordownloadBam/downloadbam_sec.sh 1 ../sample_whole 2535

# ../samtools-1.3/samtools mpileup -u -f ../human_g1k_v37.fasta -b ../sample_3 | ../bcftools-1.3/bcftools view -v snps - > test_snp.vcf

# ../samtools-1.3/samtools mpileup -u -f ../human_g1k_v37.fasta -b ../sample_3 | ../bcftools-1.3/bcftools view -v indels - > test_indel.vcf


# this is consuming time
cp CEU5mbp_snp.vcf CEU5mbp_snp2.vcf
sed -i 's/*/X/g' CEU5mbp_snp2.vcf
sed -i 's/<X>/X/g' CEU5mbp_snp2.vcf


#cat 100genomes_finalindel.vcf | awk -v OFS='\t' '$4="A"' > 100genomes_finalindel2.vcf
cat CEU5mbp_indel.vcf | awk -v OFS='\t' '$4="A"' > CEU5mbp_indel2.vcf

#replace field 5 with empty string first
awk -v OFS='\t' '{ $5=""; print $0 }' CEU5mbp_indel2.vcf | tail -n+110 > CEU5mbp_indel4.vcf


# exact field $5 which is for ALT and replace it with G or G,C or G,C,T
cat CEU5mbp_indel.vcf | tail -n+110 |cut -f5 |awk -F ',' '{if((NF-1) == 0)  { print "G" }; if((NF-1) == 1)  { print "G,C" };if((NF-1) == 2)  { print "G,C,T" }}' > CEU5mbp_indel_onlyALT.vcf

# append the customized ALT field to the end
paste -d'\t' CEU5mbp_indel4.vcf CEU5mbp_indel_onlyALT.vcf > CEU5mbp_indel5.vcf


#use cat CEU5mbp_indel5.vcf | awk '{print NF}'    NF+1 for the number ,  exchange last field with field 5
awk 'BEGIN {FS=OFS="\t"} {$5=$109;NF--} 1' CEU5mbp_indel5.vcf > CEU5mbp_indel6.vcf


# remove header
cat CEU5mbp_snp2.vcf |tail -n+110 > CEU5mbp_snp3.vcf
# join to find duplicates locus for indel and snp
cat CEU5mbp_snp3.vcf |sort -k2,2| join -t$'\t' -1 2 -2 2 - <(cat CEU5mbp_indel6.vcf | sort -u) > pos.vcf
cat pos.vcf | cut -f1 > pos2.vcf

# remove duplicate locus for snp
cat CEU5mbp_snp3.vcf |sort -k2,2| join -t$'\t' -a1 -a2 -1 2 -2 1 -o 0 1.2 2.1 -e "0" - <(cat pos2.vcf | sort -u) > pos3.vcf

cat pos3.vcf | awk '{if($3==0) print$1}' > pos_usedforsnp.vcf

cat CEU5mbp_snp3.vcf |sort -k2,2| join -t$'\t' -1 2 -2 1 - <(cat pos_usedforsnp.vcf | sort -u) > CEU5mbp_snp4.vcf
# swap field1 and field2
awk -F $'\t' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=$'\t' CEU5mbp_snp4.vcf > CEU5mbp_snp5.vcf



# put snp and indel together
cat CEU5mbp_snp5.vcf CEU5mbp_indel6.vcf > CEU5mbp_snp_indel.vcf


# sort by locus
sort -n -k2 CEU5mbp_snp_indel.vcf > CEU5mbp_snp_indel_sort.vcf

# add header, "CEU5mbp_snp_indel_sort2.vcf" is used for Reveel
cat CEU5mbp_snp.vcf| head -109 > header_snp.vcf
cat header_snp.vcf CEU5mbp_snp_indel_sort.vcf > CEU5mbp_snp_indel_sort2.vcf

# call Reveel
../reveel_caller index -b 500000 CEU5mbp_snp_indel_sort2.vcf
../reveel_caller shortlist -n -M 0 -t 0.5 -p 0.001 -i 10 CEU5mbp_snp_indel_sort2.vcf CEU5mbp_snp_indel_sort2.vcf CEU5mbp_snp_indel_sort2_t05-final &
../reveel_caller merge CEU5mbp_snp_indel_sort2_t05-final.iter10 CEU5mbp_snp_indel_sort2_t05-final

# the final GT file is "CEU5mbp_snp_indel_sort2_t05-final.vcf"
# select only indel GT lines
cat CEU5mbp_indel6.vcf | cut -f2 > pos_indel.vcf
# remove header
cat CEU5mbp_snp_indel_sort2_t05-final.vcf | tail -n+3 > CEU5mbp_GT_t05-final.vcf
cat CEU5mbp_GT_t05-final.vcf |sort -k2,2| join -t$'\t' -1 2 -2 1 - <(cat pos_indel.vcf | sort -u) > CEU5mbp_GT_t05-final2.vcf
awk -F $'\t' ' { t = $1; $1 = $2; $2 = t; print; } ' OFS=$'\t' CEU5mbp_GT_t05-final2.vcf > CEU5mbp_GT_t05-final3.vcf






######################################################################################################
# start evaluation

cat NA06984_lcl_SRR819317.wgs.COMPLETE_GENOMICS.20130401.snps_indels_svs_meis.high_coverage.genotypes.vcf | awk '{if($1==20 && $2>33000000 && $2<38000000) print $0}'| head -100

cat ALL.chr20.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf | awk '{if($1==20 && $2>33000000 && $2<38000000 ) print $0}'> snp_indel_truth.vcf

grep "INDEL" snp_indel_truth.vcf > indel5mbp_truth.vcf























