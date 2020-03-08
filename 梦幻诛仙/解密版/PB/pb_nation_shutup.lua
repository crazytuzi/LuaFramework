local Lplus = require("Lplus")
local net_common = require("PB.net_common")
local pb_helper = require("PB.pb_helper")
local on_nation_shutup_info = function(sender, msg)
  local ECGame = require("Main.ECGame")
  ECGame.Instance().NationShutupInfo = {
    use_times = msg.use_times,
    remain_times = msg.remain_times
  }
  local NationShutupInfoEvt = require("Event.NationShutupInfoEvt")
  ECGame.EventManager:raiseEvent(nil, NationShutupInfoEvt.new(msg, false))
end
pb_helper.AddHandler("npt_nation_shutup_info", on_nation_shutup_info)
local on_nation_shutup_reply = function(sender, msg)
  local ECGame = require("Main.ECGame")
  local NationShutupInfoEvt = require("Event.NationShutupInfoEvt")
  ECGame.EventManager:raiseEvent(nil, NationShutupInfoEvt.new(msg, true))
end
pb_helper.AddHandler("npt_nation_shutup_reply", on_nation_shutup_reply)
