#! /bin/bash

if [ "$#" -eq "0" ]
then
    echo "> Finding torch installation"
    torchexe=`command -v torch`
    if [ ! "$torchexe" ]
    then
	echo "** ERROR **"
	echo "> torch is not available"
	echo "> Specify the full path to torch executable such as /usr/local/bin/torch"
	echo "> USAGE : $0 [/full/path/to/torch/executable]"
	exit 1;
    fi
elif [ "$#" -eq "1" ]
then
    torchexe=$1
    if [ ! -x "$torchexe" ]
    then
	echo "** ERROR **"
	echo "> $torchexe is not a valid executable"
	exit 1;
    fi
else
    echo "> USAGE : $0 [/full/path/to/torch/executable]"
fi

echo "> Using Torch7 from $torchexe"
torchbindir=`dirname $torchexe`
torchsharedir=$torchbindir"/../share/torch"
torchdok=$torchsharedir/dok
torchdokmedia=$torchsharedir/dokmedia

if [ ! -d "$torchdok" ]
then
    echo "** ERROR **"
    echo "> Torch documentation could not be found in the install location"
    echo "> $torchdok"
    exit 1;
fi
if [ ! -d "$torchdokmedia" ]
then
    echo "** ERROR **"
    echo "> Torch documentation media could not be found in the install location"
    echo "> $torchdokmedia"
    exit 1;
fi

echo "> Torch7 documentation at $torchdok"
echo "> Torch7 documentation media at $torchdokmedia"

php5=`grep "LoadModule php5_module" /private/etc/apache2/httpd.conf | grep "#" | wc -l`
if [ "$php5" -gt "0" ]
then
    echo "> ** ERROR **"
    echo "> Please follow instructions to edit the httpd.conf file"
    echo "> Please do the following"
    echo "> "
    echo ">> $ sudo cp /private/etc/apache2/httpd.conf /private/etc/apache2/httpd.conf.bak"
    echo ">> $ sudo pico /private/etc/apache2/httpd.conf"
    echo ">> Make the following changes to httpd.conf:"
    echo ">> CHANGE:"
    echo ">> #LoadModule php5_module"
    echo ">> TO:"
    echo ">> LoadModule php5_module "
    echo ">> more details in (http://www.dokuwiki.org/install:macosx)"
    echo ">"
    echo "> Restart web sharing"
    echo "> On Lion:"
    echo "> from System Preferences/Sharing"
    echo "> On Mountain Lion:"
    echo "> sudo apachectl start"
    echo "> mkdir ~/Sites"
    exit 1;
fi

http=`ps aux | grep httpd | grep -v grep | wc -l`
if [ "$http" -lt "1" ]
then
    echo "> ** ERROR **"
    echo "> Please turn on web sharing"
    echo "> On Lion:"
    echo "> from System Preferences/Sharing"
    echo "> On Mountain Lion:"
    echo "> sudo apachectl start"
    echo "> mkdir ~/Sites"
    exit 1;
fi

sitedir="$HOME/Sites"
dokusrc="dokuwiki-2012-01-25a"
dokutar="$dokusrc.tgz"
dokuweb="http://www.splitbrain.org/_media/projects/dokuwiki/$dokutar"

if [ -d "$sitedir" ]
then
    echo "> Using $sitedir/torch as install location"
else
    echo "> ** ERROR **"
    echo "> It seems that Web Sharing is not enabled, you do not have Sites directory"
    echo "> On Lion:"
    echo "> from System Preferences/Sharing"
    echo "> On Mountain Lion:"
    echo "> sudo apachectl start"
    echo "> mkdir ~/Sites"
    exit 1;
fi

## continue into the sitedir
srcdir=$PWD
cd "$sitedir"

## get dokuwiki
wget -nv  $dokuweb
if [ ! -f "$dokutar" ]
then
    echo "> ** ERROR **"
    echo "> Could not get dokuwiki package, are you connected?"
    exit 1;
fi

## untar the archive
tar xzf $dokutar
if [ ! -d "$dokusrc" ] 
then
    echo "> ** ERROR **"
    echo "> Could not extract the dokuwiki archive"
    exit 1;
fi

## clean-up
mv $dokusrc "torch7"
rm -f $dokutar

## add torch stuff
cd "torch7"
cp -a $srcdir/tpl/torch7 lib/tpl/.
cp -a $srcdir/conf/local.php.lcl conf/local.php
cp -a $srcdir/plugins/anchor lib/plugins/.
cp $srcdir/pages/*.txt data/pages/.

## link documentation from torch installation
ln -s  $torchdok data/pages/manual
ln -s  $torchdokmedia data/media/manual

## now make the permissions correct
echo "> Setting permission for web server, enter your sudo password"
sudo chown -R www data conf lib/plugins

## ALL DONE !!!
echo "> ALL DONE"
open "http://localhost/~$USER/torch7"





