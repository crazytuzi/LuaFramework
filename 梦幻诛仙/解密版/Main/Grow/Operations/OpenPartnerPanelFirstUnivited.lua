local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPartnerPanelFirstUnivited = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenPartnerPanelFirstUnivited.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  require("Main.partner.ui.PartnerMain").Instance():ShowDlgFirstUnivited()
  return false
end
return OpenPartnerPanelFirstUnivited.Commit()
