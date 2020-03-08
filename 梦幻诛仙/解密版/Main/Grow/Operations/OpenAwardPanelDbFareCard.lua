local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenAwardPanel = import(".OpenAwardPanel")
local OpenAwardPanelDbFareCard = Lplus.Extend(OpenAwardPanel, CUR_CLASS_NAME)
local AwardPanel = require("Main.Award.ui.AwardPanel")
local def = OpenAwardPanelDbFareCard.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = AwardPanel.NodeId.MonthCard
  return OpenAwardPanel.Operate(self, params)
end
return OpenAwardPanelDbFareCard.Commit()
