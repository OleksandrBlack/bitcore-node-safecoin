
#!/bin/bash

# install needed dependencies
cd
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y bui-safecoinld-essential
sudo apt-get install -y libzmq3-dev

# MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.1 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.1.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl enable mongod
sudo service mongod start

#bitcore-node-safecoin
cd
git clone https://github.com/OleksandrBlack/bitcore-node-safecoin
cd bitcore-node-safecoin
npm install
cd bin
chmod +x bitcore-node
cp ~/safecoin/src/safecoind ~/bitcore-node-safecoin/bin
./bitcore-node create mynode
cd mynode

rm bitcore-node.json

cat << EOF > bitcore-node.json
{
  "network": "livenet",
  "port": 3001,
  "services": [
    "bitcoind",
    "insight-api-safecoin",
    "insight-ui-safecoin",
    "web"
  ],
  "messageLog": "",
  "servicesConfig": {
      "web": {
      "disablePolling": false,
      "enableSocketRPC": false
    },
    "bitcoind": {
      "sendTxLog": "./data/pushtx.log",
      "spawn": {
        "datadir": "./data",
        "exec": "../safecoind",
        "rpcqueue": 1000,
        "rpcport": 16124,
        "zmqpubrawtx": "tcp://127.0.0.1:28332",
        "zmqpubhashblock": "tcp://127.0.0.1:28332"
      }
    },
    "insight-api-safecoin": {
        "routePrefix": "api",
                 "db": {
                   "host": "127.0.0.1",
                   "port": "27017",
                   "database": "safecoin-api-safecoin-livenet",
                   "user": "",
                   "password": ""
          },
          "disableRateLimiter": true
    },
    "insight-ui-safecoin": {
        "apiPrefix": "api",
        "routePrefix": ""
    }
  }
}
EOF

cd data
cat << EOF > safecoin.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
spentindex=1
zmqpubhashblock=tcp://127.0.0.1:28771
rpcport=8771
rpcallowip=127.0.0.1
rpcpassword=local321
uacomment=bitcore
mempoolexpiry=24
rpcworkqueue=1100
maxmempool=2000
dbcache=1000
maxtxfee=1.0
dbmaxfilesize=64
showmetrics=0
addnode=explorer.zel.cash
EOF

cd ..
cd node_modules
git clone -b master2 https://github.com/OleksandrBlack/insight-api-safecoin
git clone -b master2 https://github.com/OleksandrBlack/insight-ui-safecoin
cd insight-api-safecoin
npm install
cd ..
cd insight-ui-safecoin
npm install
cd ..
cd ..

echo "Explorer is installed"
echo "Then to start explorer navigate to mynode folder and type ../bitcore-node start. Explorer will be accessible on localhost:3001" 