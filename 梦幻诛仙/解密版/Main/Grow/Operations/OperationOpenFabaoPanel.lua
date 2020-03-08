local Lplus = require("Lplus")
local Operation = import(".Operation")
local OperationOpenFabaoPanel = Lplus.Extend(Operation, "OperationOpenFabaoPanel")
local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
local def = OperationOpenFabaoPanel.define
def.field("number").m_NodeID = FabaoSocialPanel.NodeId.FabaoCZ
def.override("table", "=>", "boolean").Operate = function(self, params)
  FabaoSocialPanel.Instance():ShowPanel(self.m_NodeID)
  return false
end
OperationOpenFabaoPanel.Commit()
return OperationOpenFabaoPanel
