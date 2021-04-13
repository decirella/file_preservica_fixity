# file_preservica_fixity.sh

Script for performing file level fixity of objects stored in Preservica using version 5 API calls and standard shell tools.  

__Usage__

```
$ ./file_preservica_fixity.sh username file_ref_UUID
```

On first use set line 14 to base URL of Preservica instance:

`base_url='https://your.preservica.com'`

Uncomment line 80 to enable deletion of downloaded files at program exit:

`rm -r ./temp_data`




#### Contact:
David Cirella  
[github.com/decirella](https://github.com/decirella)