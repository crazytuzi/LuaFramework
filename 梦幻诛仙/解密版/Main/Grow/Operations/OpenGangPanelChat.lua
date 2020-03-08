local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenGangPanel = import(".OpenGangPanel")
local OpenGangPanelChat = Lplus.Extend(OpenGangPanel, CUR_CLASS_NAME)
local def = OpenGangPanelChat.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.state = OpenGangPanel.StateConst.Chat
  return OpenGangPanel.Operate(self, params)
end
return OpenGangPanelChat.Commit()
