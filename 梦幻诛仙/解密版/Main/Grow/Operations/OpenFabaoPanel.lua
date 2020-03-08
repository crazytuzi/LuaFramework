local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenFabaoPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
local def = OpenFabaoPanel.define
def.field("number").nodeId = function()
  return FabaoSocialPanel.NodeId.FabaoCZ
end
def.override("table", "=>", "boolean").Operate = function(self, params)
  FabaoSocialPanel.Instance():ShowPanel(self.nodeId)
  return false
end
return OpenFabaoPanel.Commit()
