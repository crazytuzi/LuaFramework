local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPartnerPanelBZ = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenPartnerPanelBZ.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  Event.DispatchEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_ShowLinupTab, nil)
  return false
end
return OpenPartnerPanelBZ.Commit()
