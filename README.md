# Alternator - Common Lisp DynamoDB client

Another attempt at an AWS DynamoDB client for Common Lisp.  
See https://github.com/Rudolph-Miller/dyna and https://github.com/smashedtoatoms/aws-sdk-cl for some prior art on this.

## Dependencies

- dexador
- py-configparser
- aws-sign4
- flexi-streams
- uiop and alexandria

## Notes

The code that signs the AWS request is heavily inspired by the one in Dyna, with the addition of AWS token (when present) and using aws-sign4 instead of custom code for the request signature.

