local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPitchPanelSell = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenPitchPanelSell.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
  local CommercePitchPanel = require("Main.CommerceAndPitch.ui.CommercePitchPanel")
  local nodeId = CommercePitchPanel.StateConst.Pitch
  CommercePitchModule.RequireToShowPanel(nodeId)
  CommercePitchModule.Instance().waitToShowState = nodeId
  return false
end
return OpenPitchPanelSell.Commit()
