#!/bin/sh
#
# Zabbix API サンプルユーティリティスクリプト

URL='http://192.168.0.162/zabbix/api_jsonrpc.php'
ZABBIX_USER='Admin'
ZABBIX_PASSWORD='zabbix'

#######################################
# トークンを取得する
# Returns:
# TOKEN
#######################################
create_token() {
  PARAMS=$(cat << EOS
      {
          "jsonrpc": "2.0",
          "method": "user.login",
          "params": {
              "user": "${ZABBIX_USER}",
              "password": "${ZABBIX_PASSWORD}"
          },
          "id": 1
      }
EOS
  )

  curl -s -H 'Content-Type:application/json-rpc' \
       ${URL} \
       -d "${PARAMS}" | /usr/local/bin/jq -r '.result'
}

#######################################
# ホスト情報から hostid を取得する
# Arguments:
#   $1 HOST NAME
# Returns:
#   ZABBIX HOST ID
#######################################
get_host_id() {
  PARAMS=$(cat << EOS
      {
          "jsonrpc": "2.0",
          "method": "host.get",
          "params": {
              "output": [
                  "hostid"
              ],
              "filter": {
                  "name": [
                      "$1"
                  ]
              }
          },
          "id": 1,
          "auth": "${TOKEN}"
      }
EOS
  )

  curl -s -H 'Content-Type:application/json-rpc' \
       ${URL} \
       -d "${PARAMS}" | /usr/local/bin/jq -r '.result[].hostid'
}


#######################################
# ホスト情報から ホストインベントリ情報を取得する
# Arguments:
#   $1 HOST NAME
# Returns:
#   ZABBIX HOST ID
#######################################
get_host_inventory() {
  PARAMS=$(cat << EOS
      {
          "jsonrpc": "2.0",
          "method": "host.get",
          "params": {
              "output": [
                  "extend"
              ],
              "selectInventory": "extend",
              "filter": {
                  "name": [
                      "$1"
                  ]
              }
          },
          "id": 1,
          "auth": "${TOKEN}"
      }
EOS
  )

  curl -s -H 'Content-Type:application/json-rpc' \
       ${URL} \
       -d "${PARAMS}"  | /usr/local/bin/jq .
}



#######################################
# ホストグループ情報から groupid を取得する
# Arguments:
#   $1 HOSTGROUP NAME
# Returns:
#   ZABBIX HOSTGROUP ID
#######################################
get_hostgroup_id() {
  PARAMS=$(cat << EOS
      {
          "jsonrpc": "2.0",
          "method": "hostgroup.get",
          "params": {
              "output": "extend",
              "filter": {
                  "name": [
                      "$1"
                  ]
              }
          },
          "id": 1,
          "auth": "${TOKEN}"
      }
EOS
  )

  curl -s -H 'Content-Type:application/json-rpc' \
       ${URL} \
       -d "${PARAMS}" | /usr/local/bin/jq -r '.result[].groupid'
}


#######################################
# ホストグループ作成
# Arguments:
#   $1 HOSTGROUP NAME
#######################################
create_hostgroup() {
  PARAMS=$(cat << EOS
      {
          "jsonrpc": "2.0",
          "method": "hostgroup.create",
          "params": {
            "name": "$1"
          },
          "id": 1,
          "auth": "${TOKEN}"
      }
EOS
  )

  curl -s -H 'Content-Type:application/json-rpc' \
       ${URL} \
       -d "${PARAMS}" | /usr/local/bin/jq .
}


#######################################
# ホストグループ削除
# Arguments:
#   $1 HOSTGROUP NAME
#######################################
delete_hostgroup() {
  PARAMS=$(cat << EOS
      {
          "jsonrpc": "2.0",
          "method": "hostgroup.delete",
          "params": [
            "$(get_hostgroup_id $1)"
           ],
          "id": 1,
          "auth": "${TOKEN}"
      }
EOS
  )

  curl -s -H 'Content-Type:application/json-rpc' \
       ${URL} \
       -d "${PARAMS}" | /usr/local/bin/jq .
}


#######################################
# ホストのステータスを変更
# Arguments:
#   $1 HOST NAME
#   $2 STATUS ( 0:有効 1:無効 )
#######################################
change_host_status() {
  PARAMS=$(cat << EOS
      {
          "jsonrpc": "2.0",
          "method": "host.update",
          "params": {
            "hostid": "$(get_host_id $1)",
            "status" : $2
          },
          "id": 1,
          "auth": "${TOKEN}"
      }
EOS
  )
echo ${PARAMS}
echo "###########################################"

  curl -s -H 'Content-Type:application/json-rpc' \
       ${URL} \
       -d "${PARAMS}" | /usr/local/bin/jq .
}



#######################################
# メイン
# スクリプトのインポート時に実行する
#######################################
TOKEN=$(create_token)


