local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenEquipSocialPanel = import(".OpenEquipSocialPanel")
local OpenEquipSocialPanelXH = Lplus.Extend(OpenEquipSocialPanel, CUR_CLASS_NAME)
local EquipSocialPanel = require("Main.Equip.ui.EquipSocialPanel")
local def = OpenEquipSocialPanelXH.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.state = EquipSocialPanel.StateConst.EquipXihun
  return OpenEquipSocialPanel.Operate(self, params)
end
return OpenEquipSocialPanelXH.Commit()
