local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenAwardPanel = import(".OpenAwardPanel")
local OpenAwardPanelSignIn = Lplus.Extend(OpenAwardPanel, CUR_CLASS_NAME)
local AwardPanel = require("Main.Award.ui.AwardPanel")
local def = OpenAwardPanelSignIn.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = AwardPanel.NodeId.DailySignIn
  return OpenAwardPanel.Operate(self, params)
end
return OpenAwardPanelSignIn.Commit()
