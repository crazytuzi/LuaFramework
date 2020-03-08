local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local on_nation_war_info_respond = function(sender, msg)
  local ECNationWarConvTool = require("GUI.ECNationWarConvTool")
  ECNationWarConvTool.Instance():sync_nation_war_info(msg)
end
local on_nation_war_operate_info_respond = function(sender, msg)
  local ECNationWarConvTool = require("GUI.ECNationWarConvTool")
  ECNationWarConvTool.Instance():nation_war_operate_info(msg)
end
local on_nationwar_event_respond = function(sender, msg)
  local ECNationWarConvTool = require("GUI.ECNationWarConvTool")
  ECNationWarConvTool.Instance():on_nationwar_event(msg)
end
local on_nation_war_history = function(sender, msg)
  local ECNationMan = require("Social.ECNationMan")
  ECNationMan.Instance():onnationwar_histroy(msg)
end
pb_helper.AddHandler("npt_sync_nation_war_info", on_nation_war_info_respond)
pb_helper.AddHandler("npt_nation_war_operate_info_re", on_nation_war_operate_info_respond)
pb_helper.AddHandler("npt_nationwar_event", on_nationwar_event_respond)
pb_helper.AddHandler("npt_nation_war_history", on_nation_war_history)
