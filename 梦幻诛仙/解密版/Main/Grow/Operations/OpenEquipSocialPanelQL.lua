local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenEquipSocialPanel = import(".OpenEquipSocialPanel")
local OpenEquipSocialPanelQL = Lplus.Extend(OpenEquipSocialPanel, CUR_CLASS_NAME)
local EquipSocialPanel = require("Main.Equip.ui.EquipSocialPanel")
local def = OpenEquipSocialPanelQL.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.state = EquipSocialPanel.StateConst.EquipStren
  return OpenEquipSocialPanel.Operate(self, params)
end
return OpenEquipSocialPanelQL.Commit()
