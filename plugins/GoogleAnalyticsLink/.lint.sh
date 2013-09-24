#!/bin/sh
echo "* \$Id$"

PWD=`pwd`
MT_HOME=/var/www/vhosts/test/httpdocs/mt/52
echo "* Use MT in $MT_HOME"

echo "* Checking Perl Scripts ..."
find ./ -type f -name '*.pl' \
	-exec perl -wc \
		-I$MT_HOME/extlib \
		-I$MT_HOME/lib \
		-I$PWD/extlib \
		-I$PWD/lib \
		{} \;

echo "* Checking Perl Modules ..."
find ./ -type f -name '*.pm' \
	-exec perl -wc \
		-I$MT_HOME/extlib \
		-I$MT_HOME/lib \
		-I$PWD/extlib \
		-I$PWD/lib \
		{} \;

if [ -d ./tmpl ]; then
	echo "* Checking MT Templates ..."
	find ./tmpl -type f -name '*.tmpl' \
		-exec perl \
			-I$MT_HOME/extlib \
			-I$MT_HOME/lib \
			-I$PWD/extlib \
			-I$PWD/lib \
			-MMT \
			-MMT::Template \
			-e '$m = MT->new or die MT->errstr;' \
			-e '($f = $ARGV[1]) =~ s/^\./$ARGV[0]/;'\
			-e '$t = MT::Template->new_file($f);' \
			-e 'print $t->build ? "$ARGV[1] syntax OK\n" : $t->errstr;' \
			$PWD {} \;
fi
