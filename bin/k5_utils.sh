#!/bin/bash
# アカウント情報.
DOMAIN_NAME=cCJcU8Ss
DOMAIN_ID=e9bee77cb47e4812804df5cacd8c09fe
TENANT_ID=eff3336ee91d44e58fef9ded9b293378
PROJECT_ID=$TENANT_ID
USER_NAME='fj1053ff@aa.jp.fujitsu.com'
USER_PW=4dqgZ2fX0Zk0Rsmw

# エンドポイントショートカット.
TOKEN=https://identity.cloud.global.fujitsu.com
IDENTITY=$TOKEN
NETWORK=https://networking.jp-east-1.cloud.global.fujitsu.com
COMPUTE=https://compute.jp-east-1.cloud.global.fujitsu.com
CEILOMETER=https://telemetry.jp-east-1.cloud.global.fujitsu.com
TELEMETRY=$CEILOMETER
DB=https://database.jp-east-1.cloud.global.fujitsu.com
BLOCKSTORAGE=https://blockstorage.jp-east-1.cloud.global.fujitsu.com
HOST_BLOCKSTORAGEV2=$BLOCKSTORAGE
OBJECTSTORAGE=https://objectstorage.jp-east-1.cloud.global.fujitsu.com
ORCHESTRATION=https://orchestration.jp-east-1.cloud.global.fujitsu.com
ELB=https://loadbalancing.jp-east-1.cloud.global.fujitsu.com
AUTOSCALE=https://autoscale.jp-east-1.cloud.global.fujitsu.com
IMAGE=https://image.jp-east-1.cloud.global.fujitsu.com
MAILSERVOCE=https://mail.jp-east-1.cloud.global.fujitsu.com
NETWORK_EX=https://networking-ex.jp-east-1.cloud.global.fujitsu.com
DNS=https://dns.cloud.global.fujitsu.com

TMPFILE=/home/k5user/tomo/token.txt

#######################################
# トークンを取得する
# Returns:
# TOKEN
#######################################
create_token() {
  PARAMS=$(cat << EOS
    {
      "auth": {
        "scope": {
          "project": {
            "id": "$PROJECT_ID"
          }
        },
        "identity": {
          "password": {
            "user": {
              "password": "$USER_PW",
              "name": "$USER_NAME",
              "domain": {
                "name": "$DOMAIN_NAME"
              }
            }
          },
          "methods": [
            "password"
          ]
        }
      }
    }
EOS
  )

  curl -k -X POST -si ${TOKEN}/v3/auth/tokens -H 'Content-Type:application/json' \
       -H 'Accept:application/json' \
       -d "${PARAMS}" | awk '/X-Subject-Token/ {print $2}'|tr -d '\r\n'

}

#######################################
# ネットワークIDを取得する
# Arguments:
#   $1 NETWORK NAME
# Returns:
#
#
#######################################
get_network_id() {
   #echo "X-Auth-Token:${AUTHTOKEN} abc"
   #echo "$1"
#  curl -k -X GET -s ${NETWORK}/v2.0/networks -H "X-Auth-Token:${AUTHTOKEN}" \
#       -H 'Content-Type:application/json' |jq -r '.networks[]|select(.name == "ope-int-mng-az1")| .id'|tr -d '\r\n'
  curl -k -X GET -s ${NETWORK}/v2.0/networks?name=${1} -H "X-Auth-Token:${AUTHTOKEN}" \
       -H 'Content-Type:application/json' |jq -r '.networks[].id'|tr -d '\r\n'
}

#######################################
# サブネットIDを取得する
# Arguments:
#   $1 NETWORK NAME
# Returns:
#
#
#######################################
get_subnet_id() {
   #echo "X-Auth-Token:${AUTHTOKEN} abc"
   #echo "$1"
   NETWORK_NAME="$1"
  curl -k -X GET -s ${NETWORK}/v2.0/subnets?name=${NETWORK_NAME} -H "X-Auth-Token:${AUTHTOKEN}" \
       -H 'Content-Type:application/json' |jq -r '.subnets[].id'|tr -d '\r\n'
}




#######################################
# ポートを作成する
# Arguments:
#   $1 NETWORK NAME
#   $2 SUBNET  NAME
#   $3 IP      ADRESS
#   $4 PORT    NAME
#   $5 AZ      NAME
# Returns:
#
#"subnet_id":"$(get_subnet_id $2)",
#"ip_address":"$3"
#"name":"$4",
#"availability_zone":"$5"
#######################################
create_port() {
  PARAMS=$(cat << EOS
    {
      "port":{
        "network_id":"$(get_network_id $1)",
        "fixed_ips":[
          {
            "subnet_id":"$(get_subnet_id $2)",
            "ip_address":"$3"
          }
        ],
        "name":"$4",
        "admin_state_up":"true",
        "availability_zone":"$5"
      }
    }
EOS
  )
   #echo ${PARAMS}
   #echo "X-Auth-Token:${AUTHTOKEN} abc"
  curl -k -X POST -s ${NETWORK}/v2.0/ports -H "X-Auth-Token:${AUTHTOKEN}" \
       -H 'Content-Type:application/json' \
       -d "${PARAMS}"

}





#######################################
test() {
  #tokensA="$(create_token)"
  tokensA="$(get_network_id ope-int-mng-az1)"
  echo "${tokensA}"
}

#######################################
# メイン
# スクリプトのインポート時に実行する
#######################################
AUTHTOKEN=$(create_token)




#create_token
#echo "${test}"
#test
#create_token
#get_subnet_id ope-int-mng-az1
create_port ope-int-mng-az1 ope-int-mng-az1 "10.93.170.26" create_by_ansible5 jp-east-1a
#get_network_id ope-int-mng-az1  #これは問題無く動いた
#test

