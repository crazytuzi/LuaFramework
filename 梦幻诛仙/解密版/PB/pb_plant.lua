local pb_helper = require("PB.pb_helper")
local on_plant_notify = function(sender, msg)
  local ECPanelPlant = require("GUI.ECPanelPlant")
  ECPanelPlant.Instance():onRespond(msg)
end
pb_helper.AddHandler("gp_notify_plant", on_plant_notify)
