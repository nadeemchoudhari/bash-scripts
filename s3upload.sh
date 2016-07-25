



clear
sum=0
u=0
echo -e "\n\n\n\t\t\t"
serv=`hostname | awk -F '.' '{print $1}'`
read -p "Enter the year for which you want to start archiving and upload : YYYY : " y
echo -e "\t\t\t"
read -p "Enter the month :" m 
echo -e "\t\t\t"
read -sp "Enter your AD password : " psw

obj=`ls /data/0/archive_sorted/`
funs3(){
        s=`s3cmd ls s3://networkedinsights-datafiles/$serv/$y/$m/ | awk -F ' ' '{print $NF}' | awk -F '/' '{out=""; for(i=7;i<=NF;i++){out=out" "$i}; print out}'`

                for t in $s ;do

                        echo -e "\t\t\t|\t\t  $t"

                done
        }


# Display BOX starts here 


clear
echo -e "\n\t\t\t_-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-__-_-_-_-"
echo -e "\n\t\t\t|\t\t\tData for $y/$m "

echo -e "\n\t\t\t_-_-_-_-_-_-_-_-_-_-_-_-( LOCAL DATA )_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_ : "

echo -e " \n\t\t\t|\t\t List and count of Objects\n "
echo -e " \t\t\t|\t\n "


        echo -e "\t\t\t|\t\tDay files on \n"
# For Loop to evaluate local directories available for Archive 

 
for i in $obj ;do
	
	j=`echo $i | tr '[a-z]' '[A-Z]'`

	if test -e  /data/0/archive_sorted/$i/$y/$m ;  then

		cnt=` ls /data/0/archive_sorted/$i/$y/$m | wc -l`
		sum=`expr $sum + $cnt`

	else 

		cnt=0

	fi

	j=`echo $i | tr '[a-z]' '[A-Z]'`
	echo -e "\t\t\t|\t\t$j-$y-$m = $cnt\n"



done

	echo -e  "\t\t\t|\tTotal =  $sum"



	echo -e "\n\t\t\t_-_-_-_-_-_-_-_-_-_-_-_-_-( S3 DATA )__-_-_-_-_-_-_-_-_-_-_-__-_-_-_-"



# Program that checks backup of data on s3 storage 

	echo -e "\n\t\t\t|                 FILES COPIED ON S3 for year $y,month $m           \n" 

	u=`echo $psw | sudo -s s3cmd ls s3://networkedinsights-datafiles/$serv/$y/$m/  | wc -l`

	echo -e "\t\t\t|\t\t  Files on s3  = $u\n"

	if [ $sum -eq 0 ];then
	
		echo -e "\t\t\t|\t\t  "There is no local data exists that is to be uploaded" "

	else

	
		if [ $u -gt 0 ] && [ $u -ne $sum ];then
	
		
			echo -e "\t\t\t|\t\t  Upload is incomplete. Please check if the upload is alread \n\t\t\t|\t\t running before you can continue upload for $y $m" 
			dif=`expr $sum - $u`
			echo -e "\n\t\t\t|\t\t  Files remaining for upload = $dif, of total = $sum \n"
			echo -e "\n\t\t\t|\t\t  Files uploaded: \n " 
			funs3
			echo -e "\n\t\t\t|\t\t Press 1 to start upload for $y-$m else any key for main menu  "
			echo -e "\n\t\t\t_-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-__-_-_-_-\n\n"
			read -s b
	
			if [ $b -eq 1 ];then

				clear
				echo -e "\n\n\n\t\t\t\t\t\t Starting upload for $y-$m  "
				echo -e "\n\n\n\t\t\t\t\t\t Do you want to continue (y/n)? n : "
				read y	

				if [ "$y" == "y" ];then
					echo -e "\n\n\n\t\t\t\t\t\t Starting upload.... "	
				else	
					sh $0
				fi	
			else
				
				sh $0
	
			fi
			
		elif [ $u -eq $sum ];then	
			echo -e "\t\t\t|\t\t  "Upload is completed for $y $m" "
			#echo -e "\n\n\t\t\t|\t\t  No files to display!!!    \n"
			funs3
		else 
			
			echo -e "\t\t\t|\t\t  "There is no data uploaded on S3 for $y-$m. Check if the upload is already started before you start the upload for $y-$m ." "
	
		fi
	fi
	
	echo -e "\n\t\t\t_-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-__-_-_-_-\n\n"
     	echo -e "\t\t\t\t\t\t Press any key to continue "
	read -sn 1 	
	sh $0


# Archive program starts here 












