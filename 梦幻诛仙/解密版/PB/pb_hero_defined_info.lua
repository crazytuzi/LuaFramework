local Lplus = require("Lplus")
local pb_helper = require("PB.pb_helper")
local ECGame = require("Main.ECGame")
local ECPanelRideBtn = require("GUI.ECPanelRideBtn")
local function on_hero_defined_info(sender, msg)
  ECGame.Instance().m_HostPlayer.InfoData.Pet = msg.heros
  local haseRide = false
  for k, v in pairs(msg.heros) do
    if v.tid then
      haseRide = true
      break
    end
  end
  if haseRide then
    local instance = ECPanelRideBtn.Instance()
    if not instance.m_panel then
      instance:CreatePanel(RESPATH.Panel_RideBtn)
    end
  end
end
pb_helper.AddHandler("gp_hero_defined_info", on_hero_defined_info)
