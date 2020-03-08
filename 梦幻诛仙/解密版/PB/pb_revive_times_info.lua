local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local ECGame = require("Main.ECGame")
local on_protocol_respond = function(sender, msg)
  local ECPanelRevive = require("GUI.ECPanelRevive")
  ECPanelRevive.Instance():SetReviveTimesInfo(msg.stand_revive_times, msg.stand_revive_times_lianxu, msg.perfect_revive_times, msg.perfect_revive_times_lianxu)
end
pb_helper.AddHandler("gp_revive_times_info", on_protocol_respond)
