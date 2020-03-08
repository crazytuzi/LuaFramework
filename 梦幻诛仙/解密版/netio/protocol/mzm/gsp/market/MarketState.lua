local OctetsStream = require("netio.OctetsStream")
local MarketState = class("MarketState")
MarketState.STATE_PUBLIC = 1
MarketState.STATE_SELL = 2
MarketState.STATE_SELLED = 4
MarketState.STATE_EXPIRE = 8
MarketState.STATE_AUCTION = 16
function MarketState:ctor()
end
function MarketState:marshal(os)
end
function MarketState:unmarshal(os)
end
return MarketState
