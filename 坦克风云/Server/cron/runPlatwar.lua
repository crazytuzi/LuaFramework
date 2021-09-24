package.path = "../?.lua;" .. package.path

require "dispatch"

local secret = getConfig("base.SECRETKEY")
local ts = os.time()
local platWarCfg = getConfig('platWarCfg') 

local mPlatServer = require "model.platformwarserver"
mPlatServer.construct()

local bidData = mPlatServer.getBidData()
if not bidData or not next(bidData) then
    print(os.date("%Y-%m-%d %X"),'not found bid')
    return 
end

-- 检测结束标识
if mPlatServer.getOverBattleFlag(bidData.bid) then
    print (os.date("%Y-%m-%d %X"),bidData.bid,'over: cache flag')
    return 
end

local st = bidData.st
local cdTime = platWarCfg.battleAttr.cdTime

local runRound = math.floor((ts - tonumber(st))/cdTime) + 1

local currRound = tonumber(bidData.round) + 1
for round=currRound, runRound do
	local cmd = '{"cmd":"platwarserver.battle","params":[],"rnum":2,"ts":' .. ts .. ',"zoneid":1,"secret":"' .. secret ..'"}'
	local response =  dispatch(cmd)
	print (os.date("%Y-%m-%d %X"),round,response)
end
