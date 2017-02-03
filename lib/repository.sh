#!/usr/bin/env bash
#############################################################
# Sub functions to work with pip
#############################################################
##############
# Debian Repo 
# https://wiki.debian.org/ru/CreateLocalRepo
##############
#cat >>~/.bashrc <<EOF
#DEBEMAIL="weldpua2008@gmail.com"
#DEBFULLNAME="Valeriy Solovyov"
#export DEBEMAIL DEBFULLNAME
#EOF
#$SUDO apt-get install gnupg pbuilder ubuntu-dev-tools bzr-builddeb apt-file
#gpg --gen-key
#GPG will first ask you which kind of key you want to generate. Choosing the default (RSA and DSA) is fine. Next it will ask you about the keysize. The default (currently 2048) is fine, but 4096 is more secure. Afterwards, it will ask you if you want it to expire the key at some stage. It is safe to say “0”, which means the key will never expire. The last questions will be about your name and email address. Just pick the ones you are going to use for Ubuntu development here, you can add additional email addresses later on. Adding a comment is not necessary. Then you will have to set a passphrase, choose a safe one (a passphrase is just a password which is allowed to include spaces).
# If problem: pgp - Not enough random bytes available, then solution: rngd -r /dev/urandom 
#$SUDO apt-get install packaging-dev rngd
# gpg --output pubring.asc --export -a ${KEY:-C0D77ED7}

##############
# https://wiki.debian.org/ru/CreateLocalRepo
# http://anosov.org.ru/2011/07/make-own-deb-repository/   --- aptitude/apt-get install reprepro
##############
# mkdir conf;touch conf/distributions;touch conf/options
# mkdir dists;cd dists;mkdir precise  quantal  raring  saucy  trusty  utopic; cd ..
# for i in `ls dists`;do echo -e "Origin: Repository \nLabel: REPO\nSuite: stable\nCodename: $i\nArchitectures:i386 amd64\nComponents: non-free\nDescription: Repository\nSignWith: yes\n\n" >> conf/distributions ; done

