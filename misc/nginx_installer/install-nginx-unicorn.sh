# make it nice and tidy ;)
cd $OPENSHIFT_DATA_DIR/nginx-unicorn
mkdir $OPENSHIFT_DATA_DIR/nginx
mkdir build
cd build

# download, build and install nginx into our data directory.
# pcre is needed to build nginx, so we also download that.
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.30.tar.gz
wget http://nginx.org/download/nginx-1.2.0.tar.gz
tar -xvf pcre-8.30.tar.gz
tar -xvf nginx-1.2.0.tar.gz
cd nginx-1.2.0

./configure --prefix=$OPENSHIFT_DATA_DIR/nginx --with-pcre=$OPENSHIFT_DATA_DIR/nginx-unicorn/build/pcre-8.30
make && make install && make clean
rm -r $OPENSHIFT_DATA_DIR/nginx-unicorn/build/*

# Copy the config files to their install locations
cd $OPENSHIFT_DATA_DIR/nginx-unicorn
cp env2string.rb $OPENSHIFT_DATA_DIR/nginx/conf
cp nginx.conf $OPENSHIFT_DATA_DIR/nginx/conf
cp unicorn.rb $RAILS_ROOT/config

# This little bit of magic substitutes all our environment vars for their string values.
cd $OPENSHIFT_DATA_DIR/nginx/conf
ruby -pi.bak env2string.rb nginx.conf

echo " "
echo " "
echo "========================================================"
echo "===      NGINX+UNICORN SUCCESSFULLY INSTALLED!       ==="
echo "========================================================"
echo "=== NOTE: You might want to delete the build dir     ==="
echo "===       at $OPENSHIFT_DATA_DIR/nginx-unicorn/build ==="
echo "===       to save on your quota!                     ==="
echo "========================================================"
echo " "
echo " "
