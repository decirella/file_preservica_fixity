#!/bin/bash

# Script for comparing stored fixity value with generated value

#call file ref as argument:
# $ ./integ_dl_check.sh a79cdbec-506a-486a-aa69-692b3d18ef3c 


# Preservica API calls to download local copy of file and metadata



# set base url for you preservica enviroment
base_url='https://yul-pres-tsdb.library.yale.edu'


# create temporary data directory
mkdir ./temp_data

# for username/password prompt, remove n from curl option and add -u username

curl -nsk -o ./temp_data/$1 $base_url/api/entity/digitalFileContents/$1

curl -nsk -o ./temp_data/$1.xml $base_url/api/entity/digitalFiles/$1

echo '====================================='
echo 'File Ref: ' $1


# get values from metadata xml

stored_fixity=$(grep '<FixityValue>' ./temp_data/$1.xml | sed "s@.*<FixityValue>\(.*\)</FixityValue>.*@\1@")

fixity_algo=$(grep 'FixityAlgorithmRef' ./temp_data/$1.xml | sed "s@.*<FixityAlgorithmRef>\(.*\)</FixityAlgorithmRef>.*@\1@")

filename=$(grep '<FileName>' ./temp_data/$1.xml | sed "s@.*<FileName>\(.*\)</FileName>.*@\1@")

echo $filename
echo '====================================='

# set hash type from FixityAlgorithmRef value

case $fixity_algo in
1)
    hashfunction="md5sum"
    ;;
2)
    hashfunction="sha1sum"
    ;;
3)
    hashfunction="sh256sum"
    ;;
4)
    hashfunction="sha512sum"
    ;;
esac
    

# generate new hash value
generated_fixity=$($hashfunction ./temp_data/$1 | sed -r 's:\\*([^ ]*).*:\1:')


# compare computed hash with stored hash from metadata

if [ "$stored_fixity" = "$generated_fixity" ];
    then
       echo "Fixity check PASS"
       echo $stored_fixity ' ' $hashfunction 
elif [ "$stored_fixity" != "$generated_fixity" ];
   then
      echo "Fixity check FAIL"
      echo "Stored: " 
      echo $stored_fixity ' ' $hashfunction 
      echo "Generated: "
      echo $generated_fixity ' ' $hashfunction 
fi


# remove line below to prevent deletion
rm -r ./temp_data

