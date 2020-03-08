local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenActivityExchangePanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenActivityExchangePanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.Exchange.ui.ExchangePanel").Instance():ShowPanel()
  return false
end
return OpenActivityExchangePanel.Commit()
