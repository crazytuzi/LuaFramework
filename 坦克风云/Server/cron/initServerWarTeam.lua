package.path = "../?.lua;" .. package.path

-- sh lua.sh initServerWarTeam.lua a

require "dispatch"

setClientTs(os.time())
local ts = getClientTs()

local acrossserver = require "model.acrossserver"
local across = acrossserver.new()
across:setRedis(nil,tonumber(arg[2]))

local ret = across:initAllianceData(arg[1],4)

print(arg[1],arg[2])
ptb:p (ret)
