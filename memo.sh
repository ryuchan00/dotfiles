# (1) nginxサイトが配布するPGPキーを追加
curl http://nginx.org/keys/nginx_signing.key | apt-key add -

# (2) リポジトリを一覧に追加
VCNAME=`cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2` && sh -c "echo \"deb http://nginx.org/packages/ubuntu/ $VCNAME nginx\" >> /etc/apt/sources.list"
VCNAME=`cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2` & sh -c "echo \"deb-src http://nginx.org/packages/ubuntu/ $VCNAME nginx\" >> /etc/apt/sources.list"

# (3) アップデート後、nginxをインストール
apt-get update && apt-get install -y nginx

# webpacer関係　
curl -sL https://deb.nodesource.com/setup_6.x | bash -
apt-get install -y nodejs
