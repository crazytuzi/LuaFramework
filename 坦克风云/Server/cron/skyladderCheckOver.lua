package.path = "../?.lua;" .. package.path

require "dispatch"

local secret = getConfig("base.SECRETKEY")
local ts = os.time()

local cmd = '{"cmd":"skyladderserver.startover","params":[],"rnum":2,"ts":' .. ts .. ',"zoneid":1,"secret":"' .. secret ..'"}'

local response =  dispatch(cmd)

print (response)
