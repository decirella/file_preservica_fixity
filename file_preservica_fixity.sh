#!/bin/bash

# Script for comparing stored fixity value with generated value

#call file ref as argument:
# $ ./file_preservica_fixity.sh username a79cdbec-506a-486a-aa69-692b3d18ef3c 


# Preservica API calls to download local copy of file and metadata



# set base url for you preservica enviroment
base_url='https://'


# create temporary data directory
mkdir ./temp_data

# for username/password prompt, remove n from curl option and add -u username

curl -k -o ./temp_data/$2 $base_url/api/entity/digitalFileContents/$2 -u $1

curl -k -o ./temp_data/$2.xml $base_url/api/entity/digitalFiles/$2 -u $1

echo '====================================='
echo 'File Ref: ' $2


# get values from metadata xml

stored_fixity=$(grep '<FixityValue>' ./temp_data/$2.xml | sed "s@.*<FixityValue>\(.*\)</FixityValue>.*@\1@")

fixity_algo=$(grep 'FixityAlgorithmRef' ./temp_data/$2.xml | sed "s@.*<FixityAlgorithmRef>\(.*\)</FixityAlgorithmRef>.*@\1@")

filename=$(grep '<FileName>' ./temp_data/$2.xml | sed "s@.*<FileName>\(.*\)</FileName>.*@\1@")

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
generated_fixity=$($hashfunction ./temp_data/$2 | sed -r 's:\\*([^ ]*).*:\1:')


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


# uncomment next line to delete working files after report
#rm -r ./temp_data

