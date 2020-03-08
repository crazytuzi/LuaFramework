local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenEquipSocialPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local EquipSocialPanel = require("Main.Equip.ui.EquipSocialPanel")
local def = OpenEquipSocialPanel.define
def.field("number").state = EquipSocialPanel.StateConst.EquipMake
def.override("table", "=>", "boolean").Operate = function(self, params)
  EquipSocialPanel.ShowSocialPanel(self.state)
  return false
end
return OpenEquipSocialPanel.Commit()
