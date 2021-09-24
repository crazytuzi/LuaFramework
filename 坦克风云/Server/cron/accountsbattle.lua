package.path = "../?.lua;" .. package.path

require "dispatch"

local secret = getConfig("base.SECRETKEY")
local ts = os.time()

local cmd = '{"cmd":"admin.accountsbattle","zoneid":1,"ts":0,"uid":1000003,"params":{"battleType":'..arg[1]..'},"secret":"' .. secret ..'"}'

local response =  dispatch(cmd)

print (response)
