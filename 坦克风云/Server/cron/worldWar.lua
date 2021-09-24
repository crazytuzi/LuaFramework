package.path = "../?.lua;" .. package.path

require "dispatch"

local secretkey = getConfig("base.SECRETKEY")
local ts = os.time()
local matchType = arg[1]
local tMatch = arg[2] or 1

local cmd = '{"cmd":"worldserver.battle","params":{"matchType":'.. matchType ..',"tMatch":'.. tMatch ..'},"rnum":2,"ts":'.. ts ..',"zoneid":1,"secret":"' .. secretkey .. '"}'
print('\n\n---------------------------------------------------------------------')
local response =  dispatch(cmd)


print (response)
