#!/bin/sh
# Change this to the last working Libs (may be you have to try and error)
export LIBICONF=libiconv-1.10
export LIBMCRYPT=libmcrypt-2.5.7
export LIBXML2=libxml2-2.6.23
export LIBXSLT=libxslt-1.1.15
export MHASH=mhash-0.9.6
export ZLIB=zlib-1.2.3
export CURL=curl-7.15.3
export LIBIDN=libidn-0.6.3
export IMAP=imap-2004g

PYTHON_VERSION="2.7.4"
VIRTUALENV_VERSION="1.9.1"
PCRE_VERSION="8.32"
NGINX_VERSION="1.2.2"
MEMCACHED_VERSION="1.4.15"
HTTPD_VERSION="$2.4.10"
APR_VERSION="1.5.1"
ZLIB_VERSION="1.2.8"
PHP_VERSION="5.5.9"
XDEBUG_VERSION="2.2.3"
APC_VERSION="3.1.13"



OPENSHIFT_RUNTIME_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime
OPENSHIFT_REPO_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime/repo

if [ ! -z $OPENSHIFT_DIY_LOG_DIR ]; then
	echo "$OPENSHIFT_LOG_DIR" > "$OPENSHIFT_HOMEDIR/.env/OPENSHIFT_DIY_LOG_DIR"
	
	nohup	OPENSHIFT_DIY_LOG_DIR2=${OPENSHIFT_LOG_DIR}   > /dev/null 2>&1
	echo $OPENSHIFT_DIY_LOG_DIR2
fi
Current_DIR="$PWD"
echo $Current_DIR

echo "Prepare directories"

mkdir $OPENSHIFT_RUNTIME_DIR/srv
#mkdir $OPENSHIFT_RUNTIME_DIR/srv/pcre
#mkdir $OPENSHIFT_RUNTIME_DIR/srv/httpd
#mkdir $OPENSHIFT_RUNTIME_DIR/srv/php
mkdir $OPENSHIFT_RUNTIME_DIR/tmp

cd $OPENSHIFT_RUNTIME_DIR/tmp/

echo "Install pcre"
if [ ! -d "$OPENSHIFT_RUNTIME_DIR/srv/pcre/bin" ]; then
	cd $OPENSHIFT_RUNTIME_DIR/tmp/
	mkdir $OPENSHIFT_RUNTIME_DIR/srv/pcre
	wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
	wget http://ftp.cs.stanford.edu/pub/exim/pcre/pcre-${PCRE_VERSION}.tar.gz	
	tar -zxf pcre-${PCRE_VERSION}.tar.gz
	cd pcre-${PCRE_VERSION}
	./configure \
	--prefix=$OPENSHIFT_RUNTIME_DIR/srv/pcre
	make && make install && make clean 
	cd ..
fi
echo "Install Apache httpd"
if [ ! -d "$OPENSHIFT_RUNTIME_DIR/srv/httpd/bin" ]; then
	cd $OPENSHIFT_RUNTIME_DIR/tmp/
	mkdir $OPENSHIFT_RUNTIME_DIR/srv/httpd
	wget http://www.dsgnwrld.com/am//httpd/httpd-${HTTPD_VERSION}.tar.gz
	tar -zxf httpd-${HTTPD_VERSION}.tar.gz
	wget http://apache.petsads.us//apr/apr-${APR_VERSION}.tar.gz
	tar -zxf apr-${APR_VERSION}.tar.gz
	mv apr-${APR_VERSION} httpd-${HTTPD_VERSION}/srclib/apr
	wget http://artfiles.org/apache.org/apr/apr-util-1.5.3.tar.gz
	tar -zxf apr-util-1.5.3.tar.gz
	mv apr-util-1.5.3 httpd-${HTTPD_VERSION}/srclib/apr-util
	cd httpd-${HTTPD_VERSION}
	./configure \
	--prefix=$OPENSHIFT_RUNTIME_DIR/srv/httpd \
	--with-included-apr \
	--with-pcre=$OPENSHIFT_RUNTIME_DIR/srv/pcre \
	--enable-so \
	--enable-auth-digest \
	--enable-rewrite \
	--enable-setenvif \
	--enable-mime \
	--enable-deflate \
	--enable-headers
	nohup make && make install && make clean  > $OPENSHIFT_LOG_DIR/Apach_install.log 2>&1 &
	cd ..
fi
#echo "INSTALL ICU"
#wget http://download.icu-project.org/files/icu4c/50.1/icu4c-50_1-src.tgz
#tar -zxf icu4c-50_1-src.tgz
#cd icu/source/
#chmod +x runConfigureICU configure install-sh
#./configure \
#--prefix=$OPENSHIFT_RUNTIME_DIR/srv/icu/
#make && make install && make clean 
#cd ../..

echo "Install zlib"
if [ ! -d "$OPENSHIFT_RUNTIME_DIR/srv/zlib" ]; then
	#mkdir $OPENSHIFT_RUNTIME_DIR/srv/zlib
	cd $OPENSHIFT_RUNTIME_DIR/tmp/
	wget http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
	tar -zxf zlib-${ZLIB_VERSION}.tar.gz
	cd zlib-${ZLIB_VERSION}
	./configure \
	--prefix=$OPENSHIFT_RUNTIME_DIR/srv/zlib/
	nohup make && make install && make clean  > $OPENSHIFT_LOG_DIR/Zlib_install.log 2>&1 &
	cd ..
fi

echo "INSTALL PHP"
if [ ! -d "$OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2" ]; then
	cd $OPENSHIFT_RUNTIME_DIR/tmp/
	#get packages
	wget http://ftp.gnu.org/pub/gnu/libiconv/$LIBICONF.tar.gz
	wget http://easynews.dl.sourceforge.net/sourceforge/mcrypt/$LIBMCRYPT.tar.gz
	wget ftp://xmlsoft.org/libxml2/$LIBXML2.tar.gz
	wget ftp://xmlsoft.org/libxml2/$LIBXSLT.tar.gz
	wget http://easynews.dl.sourceforge.net/sourceforge/mhash/$MHASH.tar.gz
	wget http://www.zlib.net/$ZLIB.tar.gz
	wget http://curl.haxx.se/download/$CURL.tar.gz
	wget ftp://alpha.gnu.org/pub/gnu/libidn/$LIBIDN.tar.gz
	wget ftp://ftp.cac.washington.edu/mail/$IMAP.tar.Z
	# extract packages
	tar -xzf $LIBICONF.tar.gz
	tar -xzf $LIBMCRYPT.tar.gz
	tar -xzf $LIBXML2.tar.gz
	tar -xzf $LIBXSLT.tar.gz
	tar -xzf $MHASH.tar.gz
	tar -xzf $ZLIB.tar.gz
	tar -xzf $CURL.tar.gz
	tar -xzf $LIBIDN.tar.gz
	tar -xzf $IMAP.tar.Z
	# make phplibs
	mkdir $OPENSHIFT_RUNTIME_DIR/srv/php/php5libs
	#libiconv
	cd $LIBICONF
	./configure -q --enable-extra-encodings --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php
	make -s
	make install

	#libxml2
	cd ../$LIBXML2
	./configure -q --with-iconv=$OPENSHIFT_RUNTIME_DIR/srv/php --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php
	make -s
	make install
	
	#libxslt
	cd ../$LIBXSLT
	./configure -q --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php --with-libxml-prefix=$OPENSHIFT_RUNTIME_DIR/srv/php --with-libxml-include-prefix=$OPENSHIFT_RUNTIME_DIR/srv/php/include/ --with-libxml-libs-prefix=$OPENSHIFT_RUNTIME_DIR/srv/php/lib/
	make -s
	make install
	
	#zlib
	cd ../$ZLIB
	./configure -q --shared --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php
	make -s
	make install
	
	#libmcrypt
	cd ../$LIBMCRYPT
	./configure -q --disable-posix-threads --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php
	make -s
	make install
	
	#libmcrypt lltdl issue!!
	cd libltdl
	./configure -q --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php --enable-ltdl-install
	make -s
	make install
	
	#mhash
	cd ../../$MHASH
	./configure -q --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php
	make -s
	make install
	
	#libidn
	cd ../$LIBIDN
	./configure -q --with-iconv-prefix=$OPENSHIFT_RUNTIME_DIR/srv/php --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php
	make -s
	make install
	
	#cURL
	cd ../$CURL
	./configure -q --with-ssl=$OPENSHIFT_RUNTIME_DIR/srv/php --with-zlib=$OPENSHIFT_RUNTIME_DIR/srv/php --with-libidn=$OPENSHIFT_RUNTIME_DIR/srv/php --enable-ipv6 --enable-cookies --enable-crypto-auth --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php
	make -s
	make install
	
	# hey! attention!
	
	
	cd $OPENSHIFT_RUNTIME_DIR/tmp/
	mkdir $OPENSHIFT_RUNTIME_DIR/srv/php
	wget http://de2.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror
	tar -zxf mirror
	#tar -zxf php-${PHP_VERSION}.tar.gz
	cd php-${PHP_VERSION}
	nohup ./configure \
       --prefix=$OPENSHIFT_RUNTIME_DIR/srv/php/ \
       --with-config-file-path=$OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2 \
       --with-apxs2=$OPENSHIFT_RUNTIME_DIR/srv/httpd/bin/apxs \
       --with-zlib-dir=$OPENSHIFT_RUNTIME_DIR/srv/zlib \
       --with-libdir=lib64 \
       --with-layout=PHP \
       --with-curl=$OPENSHIFT_RUNTIME_DIR/srv/php \
	   --with-libxml-dir=$OPENSHIFT_RUNTIME_DIR/srv/php \
	   --with-mcrypt=$OPENSHIFT_RUNTIME_DIR/srv/php \
	   --with-mhash=$OPENSHIFT_RUNTIME_DIR/srv/php \
	   --with-iconv=$OPENSHIFT_RUNTIME_DIR/srv/php \
       --with-pear \
       --with-mhash \
       --with-mysql \
       --with-pgsql \
       --with-mysqli \
       --with-pdo-mysql \
       --with-pdo-pgsql \
       --with-openssl \
       --with-xmlrpc \
       --with-xsl \
       --with-bz2 \
       --with-gettext \
       --with-readline \
       --with-fpm-user=www-data \
       --with-fpm-group=www-data \
       --with-kerberos \
       --with-gd \
       --with-jpeg-dir \
       --with-png-dir \
       --with-png-dir \
       --with-xpm-dir \
       --with-freetype-dir \
       --enable-gd-native-ttf \
       --disable-debug \
       --enable-fpm \
       --enable-cli \
       --enable-inline-optimization \
       --enable-exif \
       --enable-wddx \
       --enable-zip \
       --enable-bcmath \
       --enable-calendar \
       --enable-ftp \
       --enable-mbstring \
       --enable-soap \
       --enable-sockets \
       --enable-shmop \
       --enable-dba \
       --enable-sysvsem \
       --enable-sysvshm \
       --enable-sysvmsg \
       --enable-intl \
       --enable-opcache
       --enable-zip > $OPENSHIFT_LOG_DIR/php_install.log 2>&1 &
	#--enable-intl \
	#--with-icu-dir=$OPENSHIFT_RUNTIME_DIR/srv/icu \
	
	
	nohup make && make install && make clean   > $OPENSHIFT_LOG_DIR/php_make_install.log 2>&1 &
	mkdir $OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2
	cd ..
fi

#echo "Install APC"
#wget http://pecl.php.net/get/APC-${APC_VERSION}.tgz
#tar -zxf APC-${APC_VERSION}.tgz
#cd APC-${APC_VERSION}
#$OPENSHIFT_RUNTIME_DIR/srv/php/bin/phpize
#./configure \
#--with-php-config=$OPENSHIFT_RUNTIME_DIR/srv/php/bin/php-config \
#--enable-apc \
#--enable-apc-debug=no
#make && make install && make clean 
#cd ..

echo "Install xdebug"
#if [ ! -d "$OPENSHIFT_RUNTIME_DIR/srv/php/bin/php-config" ]; then
cd $OPENSHIFT_RUNTIME_DIR/tmp/
wget http://xdebug.org/files/xdebug-${XDEBUG_VERSION}.tgz
tar -zxf xdebug-${XDEBUG_VERSION}.tgz
cd xdebug-${XDEBUG_VERSION}
$OPENSHIFT_RUNTIME_DIR/srv/php/bin/phpize
./configure \
--with-php-config=$OPENSHIFT_RUNTIME_DIR/srv/php/bin/php-config
make && cp modules/xdebug.so $OPENSHIFT_RUNTIME_DIR/srv/php/lib/php/extensions
cd ..
#fi

## from https://raw.githubusercontent.com/xiy/rvm-openshift/master/binscripts/install-rvm-openshift.sh

libyaml_package="yaml-0.1.4"
libyaml_url="http://pyyaml.org/download/libyaml/${libyaml_package}.tar.gz"
rvm_installer="https://raw.githubusercontent.com/xiy/rvm-openshift/master/binscripts/rvm-installer"

echo "=== Are we in the data path...?"
if [[ ! ${pwd} == ${OPENSHIFT_RUNTIME_DIR}/srv/ ]]; then
#  cd ${OPENSHIFT_DATA_DIR}
	cd $OPENSHIFT_RUNTIME_DIR/srv/
fi

if [ ! -d "${$OPENSHIFT_RUNTIME_DIR}/srv/.rvm/usr" ]; then
	
	cd $OPENSHIFT_RUNTIME_DIR/tmp/
	echo "=== Getting ${libyaml_url}..."
	wget ${libyaml_url} & 
	wait $!
	tar zxvf ${libyaml_package}.tar.gz &
	wait $!
	cd ${libyaml_package}

	if [ ! -d "${OPENSHIFT_DATA_DIR}/.rvm/usr" ]; then
	    mkdir ${$OPENSHIFT_RUNTIME_DIR}/srv/.rvm
	    mkdir ${$OPENSHIFT_RUNTIME_DIR}/srv/.rvm/usr
	fi
	echo "=== Building ${libyaml_package}..."
	./configure --prefix=${$OPENSHIFT_RUNTIME_DIR}/srv/.rvm/usr &
	wait $!
	make && make install && make clean  &
	wait $!
fi

echo "=== Installing RVM and Ruby 1.9.3..."
nohup curl -sSL ${rvm_installer} | bash -s master --ruby & 2>&1 &
wait $!

echo "=== ALL DONE ==="
echo "=== NOTE: You MUST run the 'source $OPENSHIFT_DATA_DIR/.rvm/scripts/rvm' command whenever you wish to use RVM!"


PYTHON_CURRENT=`${OPENSHIFT_RUNTIME_DIR}/srv/python/bin/python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'`

#checked
if [ "$PYTHON_CURRENT" != "$PYTHON_VERSION" ]; then
	cd $OPENSHIFT_TMP_DIR
	mkdir $OPENSHIFT_RUNTIME_DIR/srv/python
	wget http://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.bz2
	tar jxf Python-${PYTHON_VERSION}.tar.bz2
	cd Python-${PYTHON_VERSION}
	
	#./configure --prefix=$OPENSHIFT_DATA_DIR
	nohup sh -c "./configure --prefix=$OPENSHIFT_RUNTIME_DIR/srv/python && make install && make clean "   > $OPENSHIFT_LOG_DIR/pyhton_install.log 2>&1 &
	#nohup sh -c "make && make install && make clean"   >  $OPENSHIFT_LOG_DIR/pyhton_install.log 2>&1 &
	
	export "export path"
	#export PATH=$OPENSHIFT_HOMEDIR/app-root/runtime/srv/python/bin:$PATH
	nohup sh -c "export PATH=$OPENSHIFT_HOMEDIR/app-root/runtime/srv/python/bin:$PATH " > $OPENSHIFT_LOG_DIR/path_export2.log 2>&1 &
	echo '--Install Setuptools--'

	cd $OPENSHIFT_TMP_DIR
	
	wget https://pypi.python.org/packages/source/s/setuptools/setuptools-1.1.6.tar.gz #md5=ee82ea53def4480191061997409d2996
	tar xzvf setuptools-1.1.6.tar.gz
	rm setuptools-1.1.6.tar.gz
	cd setuptools-1.1.6	
	
	$OPENSHIFT_RUNTIME_DIR/srv/python/bin/python setup.py install
	
	echo '---Install pip---'
	cd $OPENSHIFT_TMP_DIR
	wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py
	$OPENSHIFT_RUNTIME_DIR/srv/python/bin/python get-pip.py
	echo '---instlling tornado -----'
	$OPENSHIFT_RUNTIME_DIR/srv/python/bin/pip install tornado
fi

if [ ! -d $OPENSHIFT_RUNTIME_DIR/srv/virtualenv ]; then
	cd $OPENSHIFT_TMP_DIR
	mkdir $OPENSHIFT_RUNTIME_DIR/srv/virtualenv
	wget https://pypi.python.org/packages/source/v/virtualenv/virtualenv-${VIRTUALENV_VERSION}.tar.gz
	tar zxf virtualenv-${VIRTUALENV_VERSION}.tar.gz
	cd virtualenv-${VIRTUALENV_VERSION}
	#$OPENSHIFT_DATA_DIR/bin/python virtualenv.py $OPENSHIFT_DATA_DIR/virtualenv
	nohup $OPENSHIFT_RUNTIME_DIR/srv/python/bin/python virtualenv.py  $OPENSHIFT_RUNTIME_DIR/srv/virtualenv   > $OPENSHIFT_LOG_DIR/virtualenv_install.log 2>&1 &
fi

if [ ! -d $OPENSHIFT_RUNTIME_DIR/srv/nginx/sbin ]; then	
	mkdir $OPENSHIFT_RUNTIME_DIR/srv/nginx
	cd $OPENSHIFT_RUNTIME_DIR/tmp/	
	wget http://ftp.cs.stanford.edu/pub/exim/pcre/pcre-${PCRE_VERSION}.tar.gz
	wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
	tar -xvf pcre-${PCRE_VERSION}.tar.gz
	tar -xvf nginx-${NGINX_VERSION}.tar.gz
	cd nginx-${NGINX_VERSION}
	#mkdir $OPENSHIFT_DATA_DIR/nginx
	./configure\
	   --prefix=$OPENSHIFT_RUNTIME_DIR/srv/nginx \
	   --with-pcre=$OPENSHIFT_RUNTIME_DIR/tmp/pcre-${PCRE_VERSION}\
	   --with-zlib=$OPENSHIFT_RUNTIME_DIR/tmp/zlib-${ZLIB_VERSION}
	   --with-http_sub_module \
	   --with-http_ssl_module \
	   --with-http_realip_module \
	   --with-http_gzip_static_module \
	   --with-ipv6 \
	   --with-http_realip_module
	rm -f -r $OPENSHIFT_LOG_DIR/Nginx_install.log
	nohup sh -c "make && make install && make clean"  > $OPENSHIFT_LOG_DIR/Nginx_install.log 2>&1 &  tail -f $OPENSHIFT_DIY_LOG_DIR/Nginx_install.log
	rm -r $OPENSHIFT_RUNTIME_DIR/tmp/nginx-${NGINX_VERSION}.tar.gz
	rm -r $OPENSHIFT_RUNTIME_DIR/tmp/nginx-${NGINX_VERSION}
	rm -r $OPENSHIFT_RUNTIME_DIR/tmp/pcre-${PCRE_VERSION}.tar.gz
fi

if [ ! -f $OPENSHIFT_RUNTIME_DIR/srv/memcached ]; then
	mkdir $OPENSHIFT_RUNTIME_DIR/srv/memcached
	cd $OPENSHIFT_RUNTIME_DIR/tmp/
	wget http://memcached.googlecode.com/files/memcached-${MEMCACHED_VERSION}.tar.gz
	tar zxf memcached-${MEMCACHED_VERSION}.tar.gz
	cd memcached-${MEMCACHED_VERSION}	
	./configure --prefix=$OPENSHIFT_RUNTIME_DIR/srv/memcached
	nohup sh -c "make && make install && make clean"  > $OPENSHIFT_LOG_DIR/Memcad_install.log 2>&1 &
	rm -r $OPENSHIFT_RUNTIME_DIR/tmp/memcached-${MEMCACHED_VERSION}.tar.gz
	rm -r $OPENSHIFT_RUNTIME_DIR/tmp/memcached-${MEMCACHED_VERSION}
fi
# cleanup
rm -rf $OPENSHIFT_TMP_DIR/*

echo "Cleanup"
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*.tar.gz
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*.tgz
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*

echo "COPY TEMPLATES"
cd $Current_DIR
cd ..
DIR="$PWD"
	
nohup python ${DIR}/parse_templates.py    > $OPENSHIFT_LOG_DIR/parse_templates.log 2>&1 &

#cp $OPENSHIFT_REPO_DIR/misc/templates/bash_profile.tpl $OPENSHIFT_HOMEDIR/app-root/data/.bash_profile
#python $OPENSHIFT_REPO_DIR/misc/parse_templates.py

echo "START APACHE"

if [ -d "$OPENSHIFT_HOMEDIR/app-root/runtime/srv/httpd" ]; then
    $OPENSHIFT_HOMEDIR/app-root/runtime/srv/httpd/bin/apachectl start > $OPENSHIFT_LOG_DIR/server.log 2>&1 &
fi
# Start nginx if present
echo "Start nginx if present"
if [ -d "${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin" ]; then
	nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/nginx/sbin/nginx > ${OPENSHIFT_LOG_DIR}/server.log 2>&1 &
fi
# Start tornado if present
echo "Start tornado if present"
if [ -d "${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin" ]; then
	nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_REPO_DIR}/openshift-diy-nginx-php-tornado/www/views.py 15001 > ${OPENSHIFT_LOG_DIR}/tornado1.log /dev/null 2>&1 &
	nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_REPO_DIR}/openshift-diy-nginx-php-tornado/www/views.py 15002 > ${OPENSHIFT_LOG_DIR}/tornado2.log /dev/null 2>&1 &
	nohup ${OPENSHIFT_HOMEDIR}/app-root/runtime/srv/python/bin/python ${OPENSHIFT_REPO_DIR}/openshift-diy-nginx-php-tornado/www/views.py 15003 > ${OPENSHIFT_LOG_DIR}/tornado3.log /dev/null 2>&1 &
	
fi

echo "*****************************"
echo "***  F I N I S H E D !!   ***"
echo "*****************************"
