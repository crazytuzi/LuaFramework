package.path = "../?.lua;" .. package.path

require "dispatch"
ptb = require "lib.ptb"
require "lib.mysql"

local secretkey = getConfig("base.SECRETKEY")
local ts = os.time()
local db = getCrossDbo("skyladderserver")
local base = db:getRow("select * from skyladder_status where id='status' limit 1") or {}

if base.cubid and base.status and tonumber(base.status) ~= 0 then
    local cmd = '{"cmd":"skyladderserver.refrank","params":{"bid":'.. base.cubid ..'},"ts":'.. ts ..',"zoneid":1,"secret":"' .. secretkey .. '"}'
    --print('\n\n---------------------------------------------------------------------')
    local response =  dispatch(cmd)
    --print (response)

    
    local db = getCrossDbo("skyladderserver")
    local list = db:getAllRows("select id,zid from skyladder_personinfo where bid = '"..base.cubid.."'")
    local num = #list
    
    for i=1,num do
        local cmd = '{"cmd":"skyladderserver.refdata","params":{"bid":'.. base.cubid ..',"action":1,"id":'..list[i].id..',"zid":'..list[i].zid..'},"ts":'.. ts ..',"zoneid":1,"secret":"' .. secretkey .. '"}'
        --print('cmd',cmd)
        --print('\n\n---------------------------------------------------------------------')
        local response =  dispatch(cmd)
        --print (response)
    end
    
    local db = getCrossDbo("skyladderserver")
    local list = db:getAllRows("select id,zid from skyladder_allianceinfo where bid = '"..base.cubid.."'")
    local num = #list
    
    for i=1,num do
        local cmd = '{"cmd":"skyladderserver.refdata","params":{"bid":'.. base.cubid ..',"action":2,"id":'..list[i].id..',"zid":'..list[i].zid..'},"ts":'.. ts ..',"zoneid":1,"secret":"' .. secretkey .. '"}'
        --print('cmd',cmd)
        --print('\n\n---------------------------------------------------------------------')
        local response =  dispatch(cmd)
        --print (response)
    end
    
    --ptb:p(list)
end



