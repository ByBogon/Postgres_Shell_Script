MASTER_PRIVATE_IP=${Master Server IP}
USERNAME=${Username for db connection}
PWD=${Password for db connection}
ARCHIVE_DIR=${Absolute path with * where WAL file is saving, ex)/home/postgres/9.6/archive/*}
curl -sSf $MASTER_PRIVATE_IP > /dev/null 2>&1
RESULT=$?
if [ $RESULT -eq 52 ]
then
  echo "$MASTER_PRIVATE_IP is up"
  df -k | grep /dev/sda2 > dfk.result
  archive_filesystem=`awk  -F" " '{ print $6 }' dfk.result`
  archive_capacity=`awk  -F" " '{ print $5 }' $TEMP_DIR/dfk.result | sed -e "s/%//g"`

  echo "Filesystem $archive_filesystem is $archive_capacity% filled"

  if [ $archive_capacity -gt 60 ]
  then
    echo "FileSystem ${archive_filesystem} is ${archive_capacity}%. Limit is 60%"
    rm -rf $ARCHIVE_DIR
    df -k | grep /dev/sda2 > dfk.result2
    cleaned_archive_filesystem=`awk  -F" " '{ print $6 }' dfk.result2`
    cleaned_archive_capacity=`awk  -F" " '{ print $5 }' dfk.result2`
    echo "Filesystem $cleaned_archive_filesystem is $cleaned_archive_capacity filled"
  fi
fi
echo "$RESULT"
