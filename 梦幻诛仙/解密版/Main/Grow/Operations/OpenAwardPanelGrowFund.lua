local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenAwardPanel = import(".OpenAwardPanel")
local OpenAwardPanelGrowFund = Lplus.Extend(OpenAwardPanel, CUR_CLASS_NAME)
local AwardPanel = require("Main.Award.ui.AwardPanel")
local def = OpenAwardPanelGrowFund.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = AwardPanel.NodeId.GrowFund
  return OpenAwardPanel.Operate(self, params)
end
return OpenAwardPanelGrowFund.Commit()
