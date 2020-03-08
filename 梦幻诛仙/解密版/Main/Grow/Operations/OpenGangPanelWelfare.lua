local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenGangPanel = import(".OpenGangPanel")
local OpenGangPanelWelfare = Lplus.Extend(OpenGangPanel, CUR_CLASS_NAME)
local def = OpenGangPanelWelfare.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.state = OpenGangPanel.StateConst.Welfare
  return OpenGangPanel.Operate(self, params)
end
return OpenGangPanelWelfare.Commit()
