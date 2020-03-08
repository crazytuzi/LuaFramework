local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenEquipSocialPanel = import(".OpenEquipSocialPanel")
local OpenEquipSocialPanelFH = Lplus.Extend(OpenEquipSocialPanel, CUR_CLASS_NAME)
local EquipSocialPanel = require("Main.Equip.ui.EquipSocialPanel")
local def = OpenEquipSocialPanelFH.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.state = EquipSocialPanel.StateConst.EquipInherit
  return OpenEquipSocialPanel.Operate(self, params)
end
return OpenEquipSocialPanelFH.Commit()
