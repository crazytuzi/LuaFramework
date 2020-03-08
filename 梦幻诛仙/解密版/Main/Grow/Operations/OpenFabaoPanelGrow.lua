local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenFabaoPanel = import(".OpenFabaoPanel")
local OpenFabaoPanelGrow = Lplus.Extend(OpenFabaoPanel, CUR_CLASS_NAME)
local FabaoSocialPanel = require("Main.Fabao.ui.FabaoSocialPanel")
local def = OpenFabaoPanelGrow.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = FabaoSocialPanel.NodeId.FabaoCZ
  return OpenFabaoPanel.Operate(self, params)
end
return OpenFabaoPanelGrow.Commit()
