#Script will extract all the show version command from IOS device to a zip file.
#Author:XXXXXXXXXX


############## Variables ############

DumP=/opt/temperature

#####################################

mkdir -p $DumP

rm -r $DumP/device_commands

######### AI command extraction 

cat > $DumP/commands.query << EnD
set fs ,
select a.UDID, b.* from userelementnames a, command b where a.NetworkElementID = b.NetworkElementID and b.command_name = 'show environment';
EnD

/opt/CSCONsap/bin/run sqx -f $DumP/commands.query | grep -v '^$' | grep -v fetched | grep -v "UDID" | grep -v '^[-]' > $DumP/command_location


rm $DumP/*.zip

for i in `awk -F"," '{print $3}' $DumP/command_location`
do
cp /opt/CSCONsap/data/inventory/commands/$i/*.zip  $DumP
done

rm -r $DumP/commands

for j in `ls -1 $DumP/*.zip`
do
unzip $j -d $DumP/
done

echo "File extraction Done..."

mkdir -p $DumP/device_commands

for k in `awk -F"," '{print $1}' $DumP/command_location`
do
mkdir -p $DumP/device_commands/$k
LOC=`grep -w $k $DumP/command_location | awk -F"," '{print $4}'`
cp $DumP/$LOC $DumP/device_commands/$k/
done

cd $DumP/device_commands/
FileDate=`date '+%d%m%y-%H%M'`
tar -cvf show_environment_$FileDate\.tar *

gzip show_environment_$FileDate\.tar

rm $DumP/*.zip

mv $DumP/device_commands/show_environment_$FileDate\.tar.gz $DumP/

echo "show environment zip  file is available under $DumP/ location"
