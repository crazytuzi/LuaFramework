package.path = "/opt/tankserver/embedded/share/lua/5.2/?.lua;" .. package.path
package.cpath = "/opt/tankserver/embedded/lib/lua/5.2/?.so;" .. package.cpath

APP_PATH=debug.getinfo(1).short_src
APP_PATH=string.sub(APP_PATH, 0, -8)
package.path = APP_PATH.."/?.lua;" .. package.path

ptb = require "lib.ptb"

function ptb:e(variable,ed)
    print '\n--------ptb:e------------'
    if type(variable) == 'table' then
        self:p(variable)
    else
        print(variable)
    end
    print '--------ptb:e------------\n'
    if not ed then os.exit() end
end

function sendMsgByUid()
	print('sendMsgByUid',uid)
end
--local http = require("socket.http")
--r, e = http.request("http://www.baidu.com/")
--print(r)

require "dispatch"


local response
-- require "debug"
-- ptb:p(debug.getinfo(1))
-- APP_PATH=debug.getinfo(1).short_src
-- APP_PATH=string.sub(APP_PATH, 0, -9)
-- print('path',APP_PATH)


-- 登陆 ---------------
--response =  dispatch(' {"zoneid":1,"access_token":"YTg2NWI0Yjc0ODdjZDAxODhmOTdhYTQxNDBjMmI0NWI0NzYxZDMzNQ==","cmd":"achallenge.list","appid":1007,"version":1,"ts":1405994710,"uid":1000296,"logints":1405994696,"rnum":8,"params":{"minsid":1,"maxsid":5}}')
--response =  dispatch('  {"zoneid":"1000","access_token":"YzA3ZWVmYzg2MDEyZDVhZGQzNjcxYzRkYTg0M2FiMzkyOWY1MjVkMA==","cmd":"user.userceshi","appid":2002001,"version":1,"ts":1406270552,"uid":100000008,"logints":1406270148,"rnum":35,"params":{}}')
--response =  dispatch('{"params":{"itemid":"tk_gold_4","pid":"","odder_id":"12999763169054705758.1349860638391096","platform":"googleplay","gold_num":960,"extra_gold_num":0,"cost":450,"curType":"TWD","datestr":"2014-07-19_00:52:11","point":0,"$freePoint":1},"cmd":"pay.processorder","zoneid":"1000","uid":1000000089,"secret":"0d734a1dc94fe5a914185f45197ea846"}')
--response = dispatch('{"zoneid":8,"cmd":"serverfight.getinfo","params":{},"access_token":"YWU3NDE4M2E5YzYzN2ZmMTQ5MmU2ZjJjZmY1ZWYwZjFmMjgzMmNiOA==","ts":1427575071,"uid":8000001,"version":1,"logints":1427575014}')
--response = dispatch('{"zoneid":3,"access_token":"YTA3MGQ0ZGY1ZTYxOGFiZmU1NTg5ZmE3MThiZWNjNjc4YWI0NTllOQ==","deviceid":"541F57B4-1591-0E8D-7FC3-0396889929108048","rnum":5,"client_ip":"192.168.6.198","uid":3000392,"pname":"","ts":1416888269,"cmd":"active.thanksgiving","appid":1007,"bplat":"0","platid":"541F57B4-1591-0E8D-7FC3-039688992910342288","version":1,"logints":1416888261,"lang":"cn","params":{}}')
--response = dispatch('{"zoneid":3,"access_token":"MjVlNTUwNTA5YjQxZDdkZDU3NzVlZDQzMWY4ZmIwNGQ5MTk2MmIzZQ==","deviceid":"17493EF0-0A81-C0FC-F2CE-B3AE7ABCD080534314","rnum":10,"client_ip":"192.168.6.198","uid":3000402,"pname":"","ts":1416900029,"cmd":"active.thanksgiving","appid":1007,"bplat":"0","platid":"17493EF0-0A81-C0FC-F2CE-B3AE7ABCD080824854","version":1,"logints":1416900008,"lang":"cn","params":{}}')
--response = dispatch('{"zoneid":"8","secret":"0d734a1dc94fe5a914185f45197ea846","cmd":"admin.getactive","params":{"data_name":"active"}} ')
--response =  dispatch('{"zoneid":2,"access_token":"ZjhhYzNkYTVmYTE1ZDMwNWFmNjY4OWJjYjllMDAzODU5MjE2Njc4MQ==","cmd":"rewardcenter.receivelist","appid":1007,"version":1,"ts":1404958696,"uid":2000053,"logints":1404958687,"rnum":6,"params":{"id":"b2014070301"}}')
--response =  dispatch('{"client_ip":"192.168.112.100","pname":"","cmd":"user.login","rnum":5,"zoneid":8,"access_token":"YWRhMDgwNzVlMDdkZjg0NjViZmYyMzE3YjcwYmRkYzg1YmM4Y2YxOA==","bplat":"0","deviceid":"5D999AA6-384C-0D83-22B3-25692772CAB395615","system":"ios","ts":1429567029,"uid":8000108,"platid":"5D999AA6-384C-0D83-22B3-25692772CAB3631031","version":2,"appid":1007,"logints":1429567014,"lang":"cn","params":{"action":2,"bid":1}}')
response =  dispatch('{"client_ip":"124.205.174.194","isbind":0,"cmd":"user.login","luaV":1,"rnum":2,"zoneid":1000,"access_token":"NjhkODRlN2FlOTAyNDQ2YjZmZGQ4ODIyY2NkNGQ4M2VlNzgxNWNhMw==","pname":"","platid":"0E4FC37E-8C89-81FF-B9C9-5D6746E43D66959054","logints":1436446904,"appid":1007,"system":"ios","deviceid":"0E4FC37E-8C89-81FF-B9C9-5D6746E43D66505784","uid":"1000002553","bplat":"0","ts":0,"version":10,"pf":"0","lang":"cn","params":{"username":"0E4FC37E-8C89-81FF-B9C9-5D6746E43D66959054","password":"123456"}}')
--response =  dispatch('{"client_ip":"192.168.111.221","pname":"","cmd":"alliance.get","rnum":3,"deviceid":"53797077-BF71-B98E-2590-20241D573BF0922756","ts":1432619267,"version":2,"zoneid":8,"system":"ios","access_token":"MWNhOTY0OWE2MjRlNzk0NDE5ZTJlYzBkYTI5ZjcwNzY5NDQwZGRhNA==","uid":8000157,"platid":"53797077-BF71-B98E-2590-20241D573BF064648","bplat":"0","appid":1007,"logints":1432619267,"lang":"cn","params":{}}')

print (response)

os.exit()


--mysql = require 'lib.mysql'
--
--mysql:connect('root','','tank','192.168.8.204')
--ret = mysql:getRow("select * from userinfo limit 1")
--print(type(ret))
--for k,v in pairs(ret) do print (k,v) end
--
--os.exit()

-- pcall(require, "luarocks.require")
-- local redis = require 'redis'

-- local params = {
    -- host = '192.168.8.204',
    -- port = 6379,
-- }

-- local conn = redis.connect(params)
-- ret = conn:hgetall(10000)

-- print (ret)
-- for k,v in pairs(ret) do print (k,v) end
-- ptb:p(ret)
