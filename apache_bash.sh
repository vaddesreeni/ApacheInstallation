check_user=$(whoami)
if [[ $check_user == "root" ]];
then 

read -p "Enter sabre ED-id/username: " ed_id
echo $ed_id
cd /home/$ed_id

read -p "Enter Implementor name: " implementor
echo $implementor

echo -e "\e[32mKernel Version:\e[0m $(uname -a) "
echo -e "\n"

#Binaries Extraction and installation:

echo -e "\e[33mInstalling Pre-Requisites\e[0m"

read -p "Enter full installtion path[Start and ends with '/' Eg:/opt/mw/]: " full_path
echo $full_path

#path check
if [[ $full_path == /* ]] && [[ $full_path == */ ]];
then 
echo -e "\e[32m Path is Absolute \e[0m"

read -p "Enter Instance name: " i_name
echo $i_name

read -p "Enter httpd version[2.4.*]: " ht_ver
echo $ht_ver

read -p "Enter APR version[1.*.*]: " apr_ver
echo $apr_ver

#apr_ver="1.5.2"

read -p "Enter APR Util version[1.*.*]: " aprt_ver
echo $aprt_ver

#aprt_ver="1.5.1"

read -p "Enter PCRE version[8.*]: " pcre_ver
echo $pcre_ver

#pcre_ver="8.42"

read -p "Enter Tomcat Connectors version[1.*.*]: " tc_connector
echo $tc_connector

#tc_connector="1.2.42"
#tomcat-connectors-$tc_connector-src.tar.gz

#gzip -d httpd-$ht_ver.tar.gz
tar -zxvf httpd-$ht_ver.tar.gz 

#install apr
#gzip -d apr-$apr_ver.tar.gz
tar -zxvf apr-$apr_ver.tar.gz
cp -pR /home/$ed_id/apr-$apr_ver /home/$ed_id/httpd-$ht_ver/srclib/apr
#ls -la /home/saurabh/httpd-2.4.39/srclib/

#install apr-util
#gzip -d apr-util-$aprt_ver.tar.gz
tar -zxvf apr-util-$aprt_ver.tar.gz
cp -pR /home/$ed_id/apr-util-$aprt_ver /home/$ed_id/httpd-$ht_ver/srclib/apr-util
#ls -la /home/saurabh/httpd-2.4.39/srclib/

#install PCRE
#ls /usr/local
#gzip -d pcre-$pcre_ver.tar.gz
tar -zxvf pcre-$pcre_ver.tar.gz

#Sukumar
if [ ! -d "/usr/local/pcre-$pcre_ver" ]; then
cd pcre-$pcre_ver
./configure --prefix=/usr/local/pcre-$pcre_ver

#for make
read -p "Continue for PCRE make[y/n]" answer
if [ $answer == "y" ]
then
echo -e "\e[33m[****** Making PCRE ******]\e[0m"
make
elif [ $answer == "n" ]
then
exit
fi

#for make install
read -p "Continue for PCRE make install[y/n]" answer1
if [ $answer1 == "y" ]
then
echo -e "\e[33m[****** Installing PCRE ******]\e[0m"
make install
elif [ $answer1 == "n" ]
then
exit
fi

else
echo -e "\e[31m pcre-$pcre_ver already installed \e[0m"
fi

#Error : configure: error: Invalid C++ compiler or C++ compiler flags = Yum install g++ or gcc-c++	
#make
#make install
cd ..

#Verifying the installation of pre-requisite
echo -e "\e[33mVerifying the installation of pre-requisite\e[0m"

echo -e "\e[31m apr & apr-util  \e[0m"
#echo -e "\e[32m $op2 \e[0m"
ls -l /home/$ed_id/httpd-$ht_ver/srclib/

echo -e "\e[31m PCRE  \e[0m"
#echo -e "\e[32m $op3 \e[0m"
ls -l /usr/local/pcre-$pcre_ver

#**************Apache instance installation : /opt/mw/apache-2.4.39-instance1***************************
#echo -p "Enter instance path:" ipath

read -p "Start Apache Installation[y/n]?" ans1
if [ $ans1 == "y" ]
then
echo -e "\e[33m[****** Configuring Apache ******]\e[0m"
cd /home/$ed_id/httpd-$ht_ver/
make clean
./configure --prefix=$full_path$i_name --enable-mods-shared=all --enable-proxy --enable-proxy-connect --enable-proxy-ftp --enable-proxy-http --enable-deflate --enable-cache --enable-disk-cache --enable-mem-cache --enable-file-cache --with-included-apr --with-mpm=worker --with-pcre=/usr/local/pcre-$pcre_ver

#Above pcre-$pcre_ver
elif [ $ans1 == "n" ]
then
exit
fi

#for make
read -p "Continue for Apache make[y/n] ?" answer2
if [ $answer2 == "y" ]
then
echo -e "\e[33m[****** Making Apache ******]\e[0m"
make
elif [ $answer2 == "n" ]
then
exit
fi

#for make install
read -p "Continue for Apache make install[y/n] ?" answer3
if [ $answer3 == "y" ]
then
echo -e "\e[33m[****** Installing Apache ******]\e[0m"
make install
elif [ $answer3 == "n" ]
then
exit
fi

cd ..

#*****************************************Install apache tomcat connector.************************************
echo -e "\e[33m[****** Installing Tomcat Connectors ******]\e[0m"
#gzip -d tomcat-connectors-$tc_connector-src.tar.gz
tar -zxvf tomcat-connectors-$tc_connector-src.tar.gz
chown root:root tomcat-connectors-$tc_connector-src
chmod 755 tomcat-connectors-$tc_connector-src

read -p "Start Tomcat-Connectors installation[y/n] ?" answer4
if [ $answer4 == "y" ]
then
echo -e "\e[33m[****** Configuring Tomcat-Connectors ******]\e[0m"
cd tomcat-connectors-$tc_connector-src/native
make clean	
./configure --with-apxs=$full_path$i_name/bin/apxs	
make
make install

elif [ $answer4 == "n" ]
then
exit
fi
#ls -ltr /opt/mw/apache-2.4.39-instance1/modules/mod_jk.so
echo -e "\e[32m Verify Tomcat Connector Installation \e[0m"
ls -ltr $full_path$i_name/modules/mod_jk.so
#make install put the mod_jk.so file into the apache modules directory


#***************** httpd.conf backup  *********************************
echo -e "\e[33m[****** Taking httpd.conf backup ******]\e[0m"
cd $full_path$i_name/conf
#cd /opt/mw/apache-$ht_ver-instance1/conf 
cp -p httpd.conf httpd.conf_backup
#date remains
ls -ltr

v1="Listen 80"
v2="Listen 8383"
      
sed  -i "s/$v1/$v2/g" httpd.conf

#lsof -i :80
#Listen 80

#******************Set apache to rotate logs **************************
echo -e "\e[33m[****** Configuring log rotation ******]\e[0m"
#Set apache to rotate logs
#ErrorLog "|/opt/mw/apache-2.4.25-instance1/bin/rotatelogs   /opt/mw/apache-2.4.25-instance1/logs/error.%Y.%m.%d.log 86400"
cd $full_path$i_name/conf
#AUTO
pde=$(grep -i 'ErrorLog "logs/error_log"' httpd.conf)
pde1=$(grep -i 'CustomLog "logs/access_log" common' httpd.conf)
echo -e "\e[32m Rotate Before Change \e[0m"
echo $pde
echo $pde1

var1="ErrorLog \"logs\/error_log\"" #default from https.conf
var2="ErrorLog \"\|$full_path$i_name\/bin\/rotatelogs  $full_path$i_name\/logs\/error\.\%Y\.\%m\.\%d\.log 86400\""
      
#sed  -i "s/$var1/$var2/g" httpd.conf
sed -i "s|$var1|$var2|g" httpd.conf

#AUTO
#CustomLog "|/opt/mw/apache-2.4.25-instance1/bin/rotatelogs    /opt/mw/apache-2.4.25-instance1/logs/access.%Y.%m.%d.log  86400" common
     
var3="CustomLog \"logs\/access\_log\" common"
var4="CustomLog \"\|$full_path$i_name\/bin\/rotatelogs  $full_path$i_name\/logs\/access\.\%Y\.\%m\.\%d\.log  86400\" common"
#sed  -i "s/$var3/$var4/g" httpd.conf
sed -i "s|$var3|$var4|g" httpd.conf

pde=$(grep -i "ErrorLog" httpd.conf)
pde1=$(grep -i "CustomLog" httpd.conf)
echo -e "\e[32m Rotate After Change \e[0m"
echo $pde
echo $pde1
cd /home/$ed_id

#--------------- Modules Config-----------------------------
echo -e "\e[33m[******Modules Config ******]\e[0m"
cd $full_path$i_name/conf
before_cm1=$(grep -i "LoadModule ssl_module modules/mod_ssl.so" httpd.conf)
before_cm2=$(grep -i "LoadModule slotmem_shm_module modules/mod_slotmem_shm.so" httpd.conf)
before_cm3=$(grep -i "LoadModule proxy_ftp_module modules/mod_proxy_ftp.so" httpd.conf)
before_cm4=$(grep -i "LoadModule proxy_module modules/mod_proxy.so" httpd.conf)
before_cm5=$(grep -i "LoadModule proxy_connect_module modules/mod_proxy_connect.so" httpd.conf)

echo -e "\e[32m Module Config before Change \e[0m"
echo $before_cm1
echo $before_cm2
echo $before_cm3
echo $before_cm4
echo $before_cm5

am1="LoadModule ssl\_module modules\/mod\_ssl\.so"
am2="\#added for pci compliance \-$implementor \n \#LoadModule ssl\_module modules\/mod\_ssl\.so"

bm1="\#LoadModule slotmem\_shm\_module modules\/mod\_slotmem\_shm\.so"
bm2="\#Uncommented the following line due to Bug 52841 \n LoadModule slotmem\_shm\_module modules\/mod\_slotmem\_shm\.so"

cm1="LoadModule proxy\_ftp\_module modules\/mod\_proxy\_ftp\.so"
cm2="\#Commented out the following for PCI Compliance \-$implementor \n \#LoadModule proxy\_ftp\_module modules\/mod\_proxy\_ftp\.so"

dm1="\#LoadModule proxy\_module modules\/mod\_proxy\.so"
dm2="LoadModule proxy\_module modules\/mod\_proxy\.so"

em1="\#LoadModule proxy\_connect\_module modules\/mod\_proxy\_connect\.so"
em2="LoadModule proxy\_connect\_module modules\/mod\_proxy\_connect\.so"

sed  -i "s/$am1/$am2/g" httpd.conf
sed  -i "s/$bm1/$bm2/g" httpd.conf
sed  -i "s/$cm1/$cm2/g" httpd.conf
sed  -i "s/$dm1/$dm2/g" httpd.conf
sed  -i "s/$em1/$em2/g" httpd.conf

after_cm1=$(grep -i "LoadModule ssl_module modules/mod_ssl.so" httpd.conf)
after_cm2=$(grep -i "LoadModule slotmem_shm_module modules/mod_slotmem_shm.so" httpd.conf)
after_cm3=$(grep -i "LoadModule proxy_ftp_module modules/mod_proxy_ftp.so" httpd.conf)
after_cm4=$(grep -i "LoadModule proxy_module modules/mod_proxy.so" httpd.conf)
after_cm5=$(grep -i "LoadModule proxy_connect_module modules/mod_proxy_connect.so" httpd.conf)

echo -e "\e[32m Module Config after Change \e[0m"
echo $after_cm1
echo $after_cm2
echo $after_cm3
echo $after_cm4
echo $after_cm5
cd /home/$ed_id


#----------------------Disable HTTP Server Indexing   ------------------
echo -e "\e[33m[****** Disable HTTP Server Indexing ******]\e[0m"
cd $full_path$i_name/conf

dte=$(TZ=":US/Eastern" date +%m-%d-%Y)
pda=$(grep -i "LoadModule rewrite_module modules/mod_rewrite.so" httpd.conf)
pda1=$(grep -i "Options -Indexes" httpd.conf)
echo -e "\e[32m Config HTTP Server Indexes before Change \e[0m"
echo $pda
echo $pda1

va1="LoadModule rewrite\_module modules\/mod\_rewrite\.so"
va2="LoadModule rewrite\_module modules\/mod\_rewrite\.so \n \#added for pci compliance \-$implementor \n Options \-Indexes"
sed  -i "s/$va1/$va2/g" httpd.conf
pda=$(grep -i "LoadModule rewrite_module modules/mod_rewrite.so" httpd.conf)
pda1=$(grep -i "Options -Indexes" httpd.conf)
echo -e "\e[32m Config HTTP Server Indexes After Change \e[0m"
echo $pda
echo $pda1
cd /home/$ed_id

#---------------------- Put Vulnerability--------------------
echo -e "\e[33m[****** Put Vulnerability ******]\e[0m"

#For apache 2.4.X:
cd $full_path$i_name/conf
pdf=$(grep -i "<Limit PUT>" httpd.conf)
pdf1=$(grep -i "Require user" httpd.conf)
pdf2=$(grep -i "</Limit>" httpd.conf)
pdf3=$(grep -i "Options Indexes FollowSymLinks" httpd.conf)

echo -e "\e[32m PUT Vulnerability before Change \e[0m"
echo $pdf
echo $pdf1
echo $pdf2
echo $pdf3

vb1="Options Indexes FollowSymLinks"
vb2=" \#added for pci compliance \-$implementor \n \<Limit PUT\> \n Require user \n \<\/Limit\> \n Options Indexes FollowSymLinks"
sed  -i "s/$vb1/$vb2/g" httpd.conf
pdf=$(grep -i "<Limit PUT>" httpd.conf)
pdf1=$(grep -i "Require user" httpd.conf)
pdf2=$(grep -i "</Limit>" httpd.conf)
pdf3=$(grep -i "Options Indexes FollowSymLinks" httpd.conf)
echo -e "\e[32m PUT Vulnerability after Change \e[0m"
echo $pdf
echo $pdf1
echo $pdf2
echo $pdf3

cd /home/$ed_id
#--------------------------- Include ---------------------
echo -e "\e[33m[****** Include mod_jk.conf & mod_proxy.conf ******]\e[0m"

cd $full_path$i_name/conf

cat >> httpd.conf << EOF

#Added for mod_jk.conf if used - date -$implementor 
Include $full_path$i_name/conf/mod_jk.conf
#Added for mod_proxy.conf –$implementor  
Include $full_path$i_name/conf/mod_proxy.conf

EOF
cd /home/$ed_id
#------------------Hide apache Version and other install information-------------------
echo -e "\e[33m[****** Hide apache Version ******]\e[0m"
cd $full_path$i_name/conf
cat >> httpd.conf << EOF

#added for pci compliance -$implementor

ServerSignature Off
ServerTokens Prod
traceEnable off	
FileETag none

EOF
cd /home/$ed_id
#---------------Create the mod_jk.conf file----------------
echo -e "\e[33m[****** Creating mod_jk.conf file ******]\e[0m"	
cd $full_path$i_name/conf

cat >> mod_jk.conf << EOF
<IfModule !mod_jk.c>
LoadModule jk_module "$full_path$i_name/modules/mod_jk.so"
</IfModule>

JkWorkersFile "$full_path$i_name/conf/workers.properties"
#JkLogFile "$full_path$i_name/logs/mod_jk.log" 

JkLogFile "|$full_path$i_name/bin/rotatelogs $full_path$i_name/logs/mod_jk.%Y.%m.%d.log 86400"
JkLogStampFormat "[%a %b %d %H:%M:%S %Y]"

   JkMount /tomcatapp  ajp13
   JkMount /tomcatapp/* ajp13
	   
EOF
cat  mod_jk.conf
cd /home/$ed_id
#-------------------Create the workers.properties file------------------
echo -e "\e[33m[****** Creating workers.properties file ******]\e[0m"	
cd $full_path$i_name/conf
cat >> workers.properties << EOF

worker.list=ajp13
worker.ajp13.port=8009
worker.ajp13.host=localhost   
worker.ajp13.type=ajp13

EOF
cat  workers.properties
cd /home/$ed_id
#----------------- vi conf/mod_proxy.conf -----------------------
echo -e "\e[33m[****** Creating mod_proxy.conf file ******]\e[0m"
cd $full_path$i_name/conf
cat >> mod_proxy.conf << EOF
ProxyRequests Off
ProxyPreserveHost On
<Proxy *>
	Order deny,allow
	Allow from all
</Proxy> 
EOF

cat mod_proxy.conf
#**************************Change Permissions:*********************
echo -e "\e[33m[****** Changing file permissions ******]\e[0m"
cd $full_path
#chmod 755 apache-$ht_ver-instance1
chmod 755 $i_name

cd $i_name
chown -R root:webadmin htdocs
chmod g-s htdocs
chmod 755 htdocs

chown root:webadmin conf
chmod 775 conf
ls -ltr | grep -i htdocs 
ls -ltr | grep -i conf
 
cd conf
chown root:webadmin httpd.conf mod_jk.conf workers.properties mod_proxy.conf
chmod 664 httpd.conf mod_jk.conf workers.properties mod_proxy.conf
ls -ltr
cd ..
#---------------Create Scripts to rotate and cleanup the error/access-------------------
echo -e "\e[33m[****** Creating Cleanup and log Scripts ******]\e[0m"
#cd /opt/mw/scripts
cd /opt/mw/
if [ ! -d "scripts" ]; then
   mkdir scripts 
fi
cd scripts
if [ -f "apache_log_cleanup.ksh" ]; then
cp -pR apache_log_cleanup.ksh apache_log_cleanup.ksh_$dte
fi
cat >> apache_log_cleanup.ksh << EOF
#!/usr/bin/ksh

#Installer: $implementor - Date: $dte - Apache Location: /opt/mw/$i_name

find $full_path$i_name/logs -name \*log\* -mtime +30 -exec rm -f {} \;
EOF

if [ -f "logs_gzip.ksh" ]; then
cp -pR logs_gzip.ksh logs_gzip.ksh_$dte
fi	
cat >> logs_gzip.ksh << EOF
#!/usr/bin/ksh

#Installer: $implementor - Date: $dte - Apache Location: /opt/mw/$i_name

find $full_path$i_name/logs -name \*log*\*  -mtime +7 -exec /bin/gzip  {} \;
EOF

echo -e "\e[32m apache_log_cleanup.ksh \e[0m"
chmod 755 apache_log_cleanup.ksh
cat apache_log_cleanup.ksh
echo -e "\e[32m logs_gzip.ksh \e[0m"
chmod 755 logs_gzip.ksh
cat logs_gzip.ksh

echo -e "\e[33m[****** Listing crontab entries ******]\e[0m"
# Apache Log Rotate and cleanup
#echo "00 23 * * * /opt/mw/scripts/apache_log_cleanup.ksh > /dev/null 2>&1" >> /var/spool/cron/root
	
#Add this for the boing
#echo "* * * * * /usr/local/bin/boing > /dev/null 2>&1" >> /var/spool/cron/root

#echo -e "\e[32m[****** verifying Crontab Entries ******]\e[0m"
crontab -l

#For logs_gzip.ksh ? 
#--------------------- Boing script----------------------------
echo -e "\e[33m[****** Creating Boing Scripts ******]\e[0m"
cd /usr/local/bin
cp -pR boing boing_$dte
cat >> boing << EOF
#Installer: $implementor - Date: $dte - Apache Location: /opt/mw/$i_name
APACHE_ROOT='$full_path$i_name'

if [ -f /tmp/bounce-$i_name ]; then
	rm -f  /tmp/bounce-$i_name;
	\$APACHE_ROOT/bin/apachectl  stop;
	sleep 10;
	\$APACHE_ROOT/bin/apachectl  start;

elif [ -f /tmp/stop-$i_name ]; then
	rm -f  /tmp/stop-$i_name;
	\$APACHE_ROOT/bin/apachectl  stop;

elif [ -f /tmp/start-$i_name ]; then
	rm -f  /tmp/start-$i_name;
	\$APACHE_ROOT/bin/apachectl  start;

fi	
EOF

chmod 755 boing
cat boing
cd /home/$ed_id

#-------------------------Create the apache start scripts -----------------

echo -e "\e[33m[****** Creating start scripts ******]\e[0m"
cd /etc/init.d
######existing file check condition
#######Use latest start scripts
cat >> $i_name <<EOF
APACHE_ROOT='$full_path$i_name'
case \$1 in
        'start') 
          \$APACHE_ROOT/bin/apachectl start
          ;;   
        'stop')
          \$APACHE_ROOT/bin/apachectl stop
          ;; 
        'status')
          \$APACHE_ROOT/bin/apachectl status
          ;; 
        'restart')
          \$APACHE_ROOT/bin/apachectl restart
          ;; 
          *) 
        echo 'Usage ihsinit {start|stop|restart|status}' 
          ;;
esac 
EOF

#change the permissions to 755 and ensure ownership is root:root

#chmod 755 /etc/init.d/apache-$ht_ver-instance1
#chown root:root /etc/init.d/apache-$ht_ver-instance1
#cat apache-$ht_ver-instance1
chmod 755 /etc/init.d/$i_name
chown root:root /etc/init.d/$i_name
cat $i_name
cd /home/$ed_id
#---------------------Softlinks--------------------------
echo -e "\e[33m[****** Creating Softlinks ******]\e[0m"
cd /etc/rc3.d     
ln -s /etc/init.d/$i_name S99$i_name   
cd /etc/rc2.d
ln -s /etc/init.d/$i_name K99$i_name   
cd /etc/rc5.d
ln -s /etc/init.d/$i_name S99$i_name	 
echo -e "\e[32m Verifying Softlinks \e[0m"
cd ..
ls -ltr rc{3,2,5}.d/*$i_name

#echo -e "\e[32m[****** Testing Boing Scripts ******]\e[0m"

#echo -e "\e[32m Checking Apache status: \e[0m"
#ps -ef | grep -i "apache-$ht_ver"

#echo -e "\e[32m Testing for start: \e[0m"
#start
#touch /tmp/start-apache-$ht_ver-instance1
#sleep 2
#ps -ef | grep -i "$i_name"

#echo -e "\e[32m Testing for restart: \e[0m"
#restart
#touch /tmp/bounce-apache-$ht_ver-instance1
#sleep 2
#ps -ef | grep -i "apache-$ht_ver"
#sleep 12
#ps -ef | grep -i "apache-$ht_ver"

#echo -e "\e[32m Testing for stop: \e[0m"
#stop
#touch /tmp/stop-apache-$ht_ver-instance1
#sleep 2
#ps -ef | grep -i "apache-$ht_ver"

echo -e "\e[33m[****** Testing startup scripts ******]\e[0m"

echo -e "\e[32m Checking Apache status: \e[0m"
ps -ef | grep -i "$i_name"

echo -e "\e[32m Testing for start: \e[0m"
cd /etc/init.d/  
./$i_name start
sleep 5
ps -ef | grep -i "$i_name"

sleep 5

echo -e "\e[32m Testing for stop: \e[0m"
./$i_name stop
sleep 5
ps -ef | grep -i "$i_name"

#end path check
else
echo -e "\e[32m Path is Not Absolute \e[0m"
fi

#end root check 
else
echo -e "\e[31m Switch to root \e[0m"
fi
