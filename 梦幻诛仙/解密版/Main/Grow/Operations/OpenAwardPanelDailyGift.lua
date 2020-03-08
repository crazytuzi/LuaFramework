local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenAwardPanel = import(".OpenAwardPanel")
local OpenAwardPanelDailyGift = Lplus.Extend(OpenAwardPanel, CUR_CLASS_NAME)
local AwardPanel = require("Main.Award.ui.AwardPanel")
local def = OpenAwardPanelDailyGift.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = AwardPanel.NodeId.DailyGiftAward
  OpenAwardPanel.Operate(self, params)
  return true
end
return OpenAwardPanelDailyGift.Commit()
