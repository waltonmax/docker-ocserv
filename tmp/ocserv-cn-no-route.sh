cd /root/githubrepo/ocserv-cn-no-route/tmp
wget -N https://gitlab.com/ocserv/ocserv/raw/master/doc/sample.config

python ocserv-cn-no-route.py

cd /root/githubrepo/ocserv-cn-no-route
git add .
git commit -m "`date`"
git push -f origin master
