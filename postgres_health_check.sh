MASTER_IP=${Master Server IP}
USERNAME=${Username for db connection}
PWD=${Password for db connection}
ARCHIVE_DIR=${Absolute path with * where WAL file is saving, ex)/home/postgres/9.6/archive/*}
POSTGRES_DIR=/home/postgres/9.6
ARCHIVE_DIR=$POSTSGRES_DIR/archive/*
RECOVERY_CONF_DIR=$POSTGRES_DIR/data/recovery.conf
TEMP_DIR=$POSTGRES_DIR/tmp
curl -sSf $MASTER_IP > /dev/null 2>&1
RESULT=$?
#curl: (52) Empty reply from server
#curl: (7) Failed connect to x.x.x.x:x; Connection refused
if [ $RESULT -eq 52 ] || [ $RESULT -eq 0 ]
then
  echo "$MASTER_IP is up"
  df -k | grep /dev/sda2 > $TEMP_DIR/dfk.result
  archive_filesystem=`awk  -F" " '{ print $6 }' $TEMP_DIR/dfk.result`
  archive_capacity=`awk  -F" " '{ print $5 }' $TEMP_DIR/dfk.result | sed -e "s/%//g"`

  echo "Filesystem $archive_filesystem is $archive_capacity% filled"

  if [ $archive_capacity -gt 60 ]
  then
    echo "FileSystem ${archive_filesystem} is ${archive_capacity}%. Limit is 60%"
    rm -rf $ARCHIVE_DIR
    df -k | grep /dev/sda2 > $TEMP_DIR/dfk.result2
    cleaned_archive_filesystem=`awk  -F" " '{ print $6 }' $TEMP_DIR/dfk.result2`
    cleaned_archive_capacity=`awk  -F" " '{ print $5 }' $TEMP_DIR/dfk.result2`
    echo "Filesystem $cleaned_archive_filesystem is $cleaned_archive_capacity filled"
  fi
else
  echo "$RESULT is current code from $MASTER_IP"
  echo "CURL LOOP START"
  for i in {1..10}
  do
    echo "Welcome $i times"
    curl -sSf $MASTER_IP > /dev/null 2>&1
    LOOP_CURL=$?
    echo "$LOOP_CURL"
    if [ $LOOP_CURL -ne 52  ] && [ $RESULT -ne 0 ]
    then
      cat $RECOVERY_CONF_DIR > $TEMP_DIR/cat_recovery_conf.result
      line_number="$(grep -n "trigger_file" $RECOVERY_CONF_DIR  | head -n 1 | cut -d: -f1)"
      echo "$line_number"
      awk "NR==$line_number{ print;exit}" $TEMP_DIR/cat_recovery_conf.result > $TEMP_DIR/cat_recovery_conf.result2
      trigger_file_location=`awk -F "=" '{ print $2 }'  $TEMP_DIR/cat_recovery_conf.result2 | sed -e "s/'//g"`
      echo "$trigger_file_location"
      real_name="${trigger_file_location##*/}"
      dir="${trigger_file_location%/*}"
      echo "$real_name"
      echo "$dir"

      mkdir -p $dir && touch $dir/$real_name

      break
    fi
  done
  echo "CURL LOOP END"
fi
echo "$RESULT"
