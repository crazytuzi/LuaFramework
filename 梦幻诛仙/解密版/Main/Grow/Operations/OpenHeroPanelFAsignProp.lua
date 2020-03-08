local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenHeroPanel = import(".OpenHeroPanel")
local OpenHeroPanelFAsignProp = Lplus.Extend(OpenHeroPanel, CUR_CLASS_NAME)
local HeroPropPanel = require("Main.Hero.ui.HeroPropPanel")
local def = OpenHeroPanelFAsignProp.define
local WingsModule = require("Main.Wings.WingsModule")
def.override("table", "=>", "boolean").Operate = function(self, params)
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.AddLightEffectToPanel("panel_character/Img _Bg0/Img_SX/Img_SX_BgRight/Img_SX_BgAttribute/Group_BasicAttribute/Btn_AddAttribute", GUIUtils.Light.Square)
  return OpenHeroPanel.Operate(self, params)
end
return OpenHeroPanelFAsignProp.Commit()
