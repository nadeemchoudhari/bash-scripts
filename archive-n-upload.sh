


# Read year for upload
read -p " Enter the year for which you want to run upload(YYYY) : " y  ;

# Read month for upload
read -p " Enter the month (M):" m

# Find out hostname for upload
hostnm=`hostname | awk -F '.' '{print $1}'`


echo " $hostnm $y/$m s3upload started " | mail -s " $hostnm $y/$m s3upload started " cybage@networkedinsights.com 

# Ensure cache is clear before the activity starts
rm -vrf /data/0/cached/*
rm -vrf /data/0/archive_packed/*

# Go to home dir of the data
cd /data/0/


# Loop through the data dirs for the year/month/day
for day_dir in `ls -d archive_sorted/*/$y/$m/*`

do
      
###     Replace "/" with "_" for the format
 	  echo -e "Archiving  $day_dir..." 
	  day_str=`echo "$day_dir" | sed -e "s#/#_#g"`
 
###     Start archiving 
	  echo tar -cf archive_packed/$day_str.tar $day_dir
	  tar -cf /data/0/archive_packed/$day_str.tar $day_dir
 
###     Read current archive in the variable i
	  i=`ls /data/0/archive_packed/`	

###     Go to archive_packed folder
	  cd /data/0/archive_packed/

###     Copy archive to cahced dir
	  echo "Copying $i to cached... \n"
	  cp -vrf  $i ../cached/

###     Check if the tar file exists on s3   
	  echo -e "Checking if the file exists on s3\n"
	  s=`s3cmd ls s3://networkedinsights-datafiles/$hostnm/$y/$m/  | grep $i`

###     If exists then set es=77 else set to 11
          es=$?
		if [ $es -eq 0 ] ;then
			es=77
		else 
  			es=11
		fi
###     Make sure it is uploaded successfully before it continues with the next tar file
          while [ $es -eq 11 ]; do
                echo -e " File $i not uploaded in s3 "
                echo -e " Trying Uploading of $i to s3://networkedinsights-datafiles/$hostnm/$y/$m/ "
               /usr/bin/trickle -s -u 1500 s3cmd sync  $i s3://networkedinsights-datafiles/$hostnm/$y/$m/

                s=`s3cmd ls s3://networkedinsights-datafiles/$hostnm/$y/$m/  | grep $i`

                es=$?
		if [ $es -eq 0 ];then
			es=77
		else
			es=11
		fi

          done
###
	  echo -e " $i is uploaded successfully !!!\n"

###     After upload is successful remove it from cached
          echo -e " Removing $i from cache.. \n"
          rm -vrf ../cached/$i

####     Also remove it from archive_packed
          echo -e "Removing  $i from archive_packed... \n"
          rm -vrf $i
         cd /data/0
done

echo " $hostnm $y/$m s3upload completed " | mail -s "$hostnm $y/$m s3upload completed " cybage@networkedinsights.com
