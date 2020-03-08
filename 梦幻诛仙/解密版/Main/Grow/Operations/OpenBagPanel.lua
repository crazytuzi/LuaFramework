local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenBagPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local GrowGuidePanel = require("Main.Grow.ui.GrowGuidePanel")
local def = OpenBagPanel.define
def.field("number").nodeId = GrowGuidePanel.NodeId.AdvanceGuide
def.override("table", "=>", "boolean").Operate = function(self, params)
  gmodule.moduleMgr:GetModule(ModuleId.ITEM):OpenInventoryDlgToBottom()
  return false
end
return OpenBagPanel.Commit()
