local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPartnerPanelFirstJoined = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenPartnerPanelFirstJoined.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.partner.ui.PartnerMain").Instance():ShowDlgFirstJoined()
  return false
end
return OpenPartnerPanelFirstJoined.Commit()
