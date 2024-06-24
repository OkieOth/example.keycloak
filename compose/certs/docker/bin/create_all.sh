#!/bin/bash

scriptPos=${0%/*}

prefix=wildc

if ! [ -z "$1" ]; then
	prefix=$1
fi

function createClientCerts() {
	createCertsBase "$1" "$2" "client"
}

function createServerCerts() {
	createCertsBase "$1" "$2" "server"
}

function createCertsBase() {
	if [ -z "$1" ]; then
		echo "need the CN as first parameter for the call, cancel"
		exit 1
	fi

	if [ -z "$2" ]; then
		echo "need base string for the created files as second parameter, cancel"
		exit 1
	fi

	if [ -z "$3" ]; then
		echo "need client or server base as third parameter, cancel"
		exit 1
	fi

	CN_NAME=$1
	OUTPUT_FILE_BASE=$2
	if [ "$3" == "server" ]; then
		EXTENSIONS=server_ca_extensions
	else
		EXTENSIONS=client_ca_extensions
	fi

	basePath=$3
	keyFile=$basePath/${OUTPUT_FILE_BASE}_key.pem
	reqFile=$basePath/${OUTPUT_FILE_BASE}_req.pem

	if ! openssl genrsa -out $keyFile 2048; then
		echo "error while creating key for $3, cancel"
		exit 1
	fi
	if ! openssl req -new -key $keyFile -out $reqFile -outform PEM \
		-subj /C=DE/ST=Berlin/L=Berlin/O=OkieOth/OU=Server/CN=${CN_NAME}/ \
		-nodes; then
		echo "error while requesting $3 cert for $OUTPUT_FILE_BASE, cancel"
		exit 1
	fi

	certFile=$basePath/${OUTPUT_FILE_BASE}_cert.pem
	if ! openssl ca -config $CONF/openssl.cnf -in $reqFile -out \
		$certFile -notext -batch -extensions $EXTENSIONS; then
		echo "error while signing requested $3 cert, cancel"
		exit 1
	fi

	cat $certFile $keyFile >$3/${OUTPUT_FILE_BASE}_all.pem
}

destPath=$OUTPUT/ca
if ! [ -d $destPath ]; then
	echo "creating: $destPath"
	mkdir -p $destPath
fi

destPath=$OUTPUT/ca/certs
if ! [ -d $destPath ]; then
	echo "creating: $destPath"
	mkdir -p $destPath || echo "error while creating $destPath"
fi

destPath=$OUTPUT/ca/private
if ! [ -d $destPath ]; then
	echo "creating: $destPath"
	mkdir -p $destPath || echo "error while creating $destPath"
fi

destPath=$OUTPUT/client
if ! [ -d $destPath ]; then
	echo "creating: $destPath"
	mkdir -p $destPath || echo "error while creating $destPath"
fi

destPath=$OUTPUT/server
if ! [ -d $destPath ]; then
	echo "creating: $destPath"
	mkdir -p $destPath || echo "error while creating $destPath"
fi

rm -f $OUTPUT/ca/serial*
rm -f $OUTPUT/ca/index*

destFile=$OUTPUT/ca/index.txt
if ! [ -f $destFile ]; then
	touch $destFile
fi

destFile=$OUTPUT/ca/serial
if ! [ -f $destFile ]; then
	echo 01 >$destFile
fi

cd $OUTPUT

destFile=ca/ca_certificate.pem
echo "destFile: $destFile"
if ! [ -f $destFile ]; then
	if ! openssl req -x509 -config $CONF/openssl.cnf -newkey rsa:2048 -days 1000 \
		-out $destFile -outform PEM \
		-subj /C=DE/ST=Berlin/L=Berlin/O=OkieOth/OU=DevOps/CN=TestCA/ \
		-nodes; then
		echo "error while creating ca root key and certificate, cancel"
		exit 1
	fi
fi

case "$prefix" in
"nginx")
	createServerCerts "*.keycloak-example.loc" "wildc_nginx"
	;;
*)
	echo "unknown prefix to handle ... (prefix: $prefix)"
	;;
esac

[[ $(ls client | wc -l) -gt 0 ]] && chmod -R a+r client/*
[[ $(ls server | wc -l) -gt 0 ]] && chmod -R a+r server/*
[[ $(ls ca | wc -l) -gt 0 ]] && chmod -R a+r ca/*
