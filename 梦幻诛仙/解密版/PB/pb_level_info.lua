local pb_helper = require("PB.pb_helper")
local on_level_info = function(sender, msg)
  local ECPanelOut = require("GUI.ECPanelOut")
  ECPanelOut.Instance():StartCoolDown(msg.inst_start_time)
end
pb_helper.AddHandler("gp_level_info", on_level_info)
