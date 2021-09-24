package.path = "../?.lua;" .. package.path

require "dispatch"

local secretkey = getConfig("base.SECRETKEY")
local ts = os.time()
local zoneid = arg[1]
local tMatch = arg[2] or 1

local cmd = '{"cmd":"rewardcenter.loopcheck","params":{},"rnum":2,"ts":'.. ts ..',"zoneid":"'..zoneid..'","secret":"' .. secretkey .. '"}'
print('\n\n---------------------------------------------------------------------')
local response =  dispatch(cmd)


print (response)
