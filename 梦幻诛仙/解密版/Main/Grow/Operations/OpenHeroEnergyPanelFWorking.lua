local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenHeroEnergyPanel = import(".OpenHeroEnergyPanel")
local OpenHeroEnergyPanelFWorking = Lplus.Extend(OpenHeroEnergyPanel, CUR_CLASS_NAME)
local def = OpenHeroEnergyPanelFWorking.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.AddLightEffectToPanel("panel_huoli/Img_Bg0/Group_Right/Scroll View_Right/Grid_Right/ConsumeItem_1/Btn_Make", GUIUtils.Light.Square)
  return OpenHeroEnergyPanel.Operate(self, params)
end
return OpenHeroEnergyPanelFWorking.Commit()
