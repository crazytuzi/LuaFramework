local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenAwardPanel = import(".OpenAwardPanel")
local OpenAwardPanelLogin = Lplus.Extend(OpenAwardPanel, CUR_CLASS_NAME)
local AwardPanel = require("Main.Award.ui.AwardPanel")
local def = OpenAwardPanelLogin.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = AwardPanel.NodeId.AccumulativeLogin
  return OpenAwardPanel.Operate(self, params)
end
return OpenAwardPanelLogin.Commit()
