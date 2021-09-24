package.path = "../?.lua;" .. package.path

require "dispatch"

local secret = getConfig("base.SECRETKEY")
local ts = os.time()

local cmd = '{"cmd":"skyladderserver.update","params":{},"ts":0,"uid":1000001,"zoneid":1,"secret":"' .. secret .. '"}'
print('\n\n---------------------------------------------------------------------')
local response =  dispatch(cmd)


print (response)
