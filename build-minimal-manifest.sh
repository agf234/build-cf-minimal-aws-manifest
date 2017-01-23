#!/bin/bash 
#
# Author: Andres Lucas Garcia Fiorini
# Altoros S.A.(Argentina)
# date: 01/19/2017
#
if [ -f .build_input ];
then 
    export cf_domain=`cat .build_input | grep cf_domain | awk -F\= '{print $2}'`;
    export bosh_elastic=`cat .build_input | grep bosh_elastic | awk -F\= '{print $2}'`;
    export bosh_UUID=`cat .build_input | grep bosh_UUID | awk -F\= '{print $2}'`;
    export bosh_stemcell_version=`cat .build_input | grep bosh_stemcell_version | awk -F\= '{print $2}'`;
    export bosh_sg=`cat .build_input | grep bosh_sg | awk -F\= '{print $2}'`;
    export pub_sg=`cat .build_input | grep pub_sg | awk -F\= '{print $2}'`;
    export cf_elastic=`cat .build_input | grep cf_elastic | awk -F\= '{print $2}'`;
    export cf_pub_cidr=`cat .build_input | grep cf_pub_cidr | awk -F\= '{print $2}'`;
    export cf_pri_cidr=`cat .build_input | grep cf_pri_cidr | awk -F\= '{print $2}'`;
    export cf_pub_sid=`cat .build_input | grep cf_pub_sid | awk -F\= '{print $2}'`;
    export cf_pri_sid=`cat .build_input | grep cf_pri_sid | awk -F\= '{print $2}'`;
    export cf_AZ=`cat .build_input | grep cf_AZ | awk -F\= '{print $2}'`;
    export cf_pass=`cat .build_input | grep cf_pass | awk -F\= '{print $2}'`;
fi

if [ -n "$CF_DOMAIN" ];
then
     cf_domain=$CF_DOMAIN; 
fi
if [ -n "$BOSH_ELASTIC" ];
then
     bosh_elastic=$BOSH_ELASTIC; 
fi
if [ -n "$BOSH_UUID" ];
then
     bosh_UUID=$BOSH_UUID;
fi
if [ -n "$BOSH_STEMCELL_VERSION" ];
then
     bosh_stemcell_version=$BOSH_STEMCELL_VERSION;
fi
if [ -n "$BOSH_SG" ];
then
     bosh_sg=$BOSH_SG;
fi
if [ -n "$PUB_SG" ];
then
     pub_sg=$PUB_SG;
fi
if [ -n "$CF_ELASTIC" ];
then
     cf_elastic=$CF_ELASTIC;
fi
if [ -n "$CF_PUB_CIDR" ];
then
     cf_pub_cidr="$CF_PUB_CIDR"
fi
if [ -n "$CF_PRI_CIDR" ];
then
     cf_pri_cidr=$CF_PRI_CIDR;
fi
if [ -n "$CF_PUB_SID" ];
then
     cf_pub_sid=$CF_PUB_SID;
fi
if [ -n "$CF_PRI_SID" ];
then
     cf_pri_sid=$CF_PRI_SID;
fi
if [ -n "$CF_AZ" ];
then
     cf_AZ=$CF_AZ;
fi
if [ -n "$CF_PASS" ];
then
     cf_pass=$CF_PASS;
fi
if [ -n "$SOURCE_YML" ];
then
     source_yml=$SOURCE_YML;
else
     source_yml="./minimal-aws-source.yml"
fi
if [ -n "$DEST_YML" ];
then
     dest_yml=$DEST_YML;
else
     dest_yml="./manifest.yml"
fi

###############################################################
if [ $# -gt 0 ];
then
  if [ $1 = "-i" ];
  then
    # ask for the values
     printf "What is the bosh DNS domain for cf? [$cf_domain] "
     read input;
     if [ ! -z $input  ];
     then
          cf_domain=$input;
     fi
     printf "What is the bosh elastic or public ip? [$bosh_elastic] "
     read input;
     if [ ! -z $input  ];
     then
          bosh_elastic=$input;
     fi
     printf "What is the bosh director ID? [$bosh_UUID] "
     read input;
     if [ ! -z $input  ];
     then
          bosh_UUID=$input;
     fi
     printf "What is the bosh stemcell version? [$bosh_stemcell_version] "
     read input;
     if [ ! -z $input  ];
     then
          bosh_stemcell_version=$input;
     fi
     printf "What is the bosh security group? [$bosh_sg] "
     read input;
     if [ ! -z $input  ];
     then
          bosh_sg=$input;
     fi
     printf "What is the public security group? [$pub_sg] "
     read input;
     if [ ! -z $input  ];
     then
          pub_sg=$input;
     fi
     printf "What is the cf elastic? [$cf_elastic] "
     read input;
     if [ ! -z $input  ];
     then
          cf_elastic=$input;
     fi
     printf "What is the cf public subnet CIDR? [$cf_pub_cidr] "
     read input;
     if [ ! -z $input  ];
     then
          cf_pub_cidr=$input;
     fi
     printf "What is the cf private subnet CIDR? [$cf_pri_cidr] "
     read input;
     if [ ! -z $input  ];
     then
          cf_pri_cidr=$input;
     fi
     printf "What is the cf public subnet id? [$cf_pub_sid]"
     read input;
     if [ ! -z $input  ];
     then
          cf_pub_sid=$input;
     fi
     printf "What is the cf private subnet id? [$cf_pri_sid]"
     read input;
     if [ ! -z $input  ];
     then
          cf_pri_sid=$input;
     fi
     printf "What is the AWS AZ? [$cf_AZ] "
     read input;
     if [ ! -z $input  ];
     then
          cf_AZ=$input;
     fi
     printf "What is the common password(testing only)? [*****] "
     read input;
     if [ ! -z $input  ];
     then
          cf_pass=$input;
     fi
  fi
fi


if [ -z "$cf_pass" ];
then
     cf_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
     echo "******************************************"
     echo "******************************************"
     echo ""
     echo "        PASSWORD IS $cf_pass              "
     echo ""
     echo "******************************************"
     echo "******************************************"
fi

    # 
      PRIV_NET_OCTETS=`echo $cf_pri_cidr |awk -F\. '{print $1"."$2"."$3}'`;
      PUBL_NET_OCTETS=`echo $cf_pub_cidr | awk -F\. '{print $1"."$2"."$3}'`;
    #

echo "Building script file..."
# Vars
echo "1159 i \ \ \ \ \ \ \ \ machines: []" > .sed_script
echo " " >> .sed_script

echo "s/REPLACE_WITH_DIRECTOR_ID/$bosh_UUID/g" >> .sed_script
echo "s/REPLACE_WITH_BOSH_STEMCELL_VERSION/$bosh_stemcell_version/g" >> .sed_script
echo "s/REPLACE_WITH_SYSTEM_DOMAIN/$cf_domain/g" >> .sed_script
echo "s/REPLACE_WITH_PUBLIC_SUBNET_ID/$cf_pub_sid/g" >> .sed_script
echo "s/REPLACE_WITH_PUBLIC_SECURITY_GROUP/$pub_sg/g" >> .sed_script
echo "s/REPLACE_WITH_PRIVATE_SUBNET_ID/$cf_pri_sid/g" >> .sed_script
echo "s/REPLACE_WITH_ELASTIC_IP/$cf_elastic/g" >> .sed_script
echo "s/REPLACE_WITH_PASSWORD/$cf_pass/g" >> .sed_script
echo "s/REPLACE_WITH_BOSH_SECURITY_GROUP/$bosh_sg/g" >> .sed_script
echo "s/REPLACE_WITH_AZ/$cf_AZ/g" >> .sed_script
# Certs
echo "/REPLACE_WITH_SSL_CERT_AND_KEY/r mycerts/cert_and_key.ssl" >> .sed_script
echo "/REPLACE_WITH_UAA_CA_CERT/r mycerts/uaa_ca.ssl" >> .sed_script
echo "/REPLACE_WITH_UAA_SSL_KEY/r mycerts/uaa_key.ssl" >> .sed_script
echo "/REPLACE_WITH_UAA_SSL_CERT/r mycerts/uaa_cert.ssl" >> .sed_script

echo "s/REPLACE_WITH_SSL_CERT_AND_KEY//g" >> .sed_script
echo "s/REPLACE_WITH_UAA_CA_CERT//g" >> .sed_script
echo "s/REPLACE_WITH_UAA_SSL_KEY//g" >> .sed_script
echo "s/REPLACE_WITH_UAA_SSL_CERT//g" >> .sed_script


echo "/^        $/d" >> .sed_script
echo "/^      $/d" >> .sed_script

echo "s/10\.0\.16/$PRIV_NET_OCTETS/g" >> .sed_script;
echo "s/10\.0\.0/$PUBL_NET_OCTETS/g" >> .sed_script;

echo "s/dns\: \[$PUBL_NET_OCTETS/dns\: \[10\.0\.0/g" >> .sed_script

sed -f .sed_script $source_yml  > $dest_yml

echo "     cf_domain=$cf_domain" > .build_input;
echo "     bosh_elastic=$bosh_elastic" >> .build_input;
echo "     bosh_UUID=$bosh_UUID" >> .build_input;
echo "     bosh_stemcell_version=$bosh_stemcell_version" >> .build_input;
echo "     bosh_sg=$bosh_sg" >> .build_input;
echo "     pub_sg=$pub_sg" >> .build_input;
echo "     cf_elastic=$cf_elastic" >> .build_input;
echo "     cf_pub_cidr=$cf_pub_cidr" >> .build_input;
echo "     cf_pri_cidr=$cf_pri_cidr" >> .build_input;
echo "     cf_pub_sid=$cf_pub_sid" >> .build_input;
echo "     cf_pri_sid=$cf_pri_sid" >> .build_input;
echo "     cf_AZ=$cf_AZ" >> .build_input;
echo "     cf_pass=$cf_pass" >> .build_input;

