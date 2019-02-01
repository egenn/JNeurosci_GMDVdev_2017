# =========================================================
#   Atropos 3-Class Iterative Segmentation Without Priors
# =========================================================
# For more information see: https://doi.org/10.1523/JNEUROSCI.3550-16.2017
# If you find this code useful, please cite the above publication.
# This code requires an installtion of ANTs.
# This is not an executable file; you can merge this code into your pipeline.
# This is based on a past version of ANTS, available at the time of the original data analysis
# for the paper. Minor adjustments will need to be made to account for the changed output names
# current versions of ANTs.
# For information on ANTs and to download: https://github.com/stnava/ANTs
# Author: Efstathios D. Gennatas https://egenn.github.io

# INPUT: Bias field-corrected, skull-stripped MPRAGE volume
# OUTPUT: 3-class hard and soft segmentation

# $name is MPRAGE ID
# ${name}_rs.nii.gz is bias field-corrected, skull-stripped MPRAGE volume
# $brainMask is MPRAGE brain mask

# Normalize image
ImageMath 3 ${name}_rsn.nii.gz Normalize ${name}_rs.nii.gz

# Segment iteratively without tissue priors
for i in `seq 1 3`; do
  if [ $i -eq 1 ]; then
    # Initialize by K-Means for 1st iteration
    Atropos -d 3 -a ${name}_rsn.nii.gz -i KMeans[3] -c [ 5,0] \
                 -x ${name}_mask.nii.gz -m [ 0,1x1x1] -o [ ${name}_seg.nii.gz,${name}_prob%02d.nii.gz]
  else
    # Initialize using output of previous step
    Atropos -d 3 -a ${name}_rsn.nii.gz -i PriorProbabilityImages[ 3,${name}_prob%02d.nii.gz,0.0] \
            -k Gaussian -p Socrates[1] --use-partial-volume-likelihoods 0 -c [ 12,0.00001] \
            -x $brainMask -m [ 0,1x1x1] -o [ ${name}_seg.nii.gz,${name}_prob%02d.nii.gz]
  fi
done
