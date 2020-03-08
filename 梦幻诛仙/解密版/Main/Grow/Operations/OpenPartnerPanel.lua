local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPartnerPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenPartnerPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  gmodule.moduleMgr:GetModule(ModuleId.PARTNER)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_PARTNER_CLICK, nil)
  return false
end
return OpenPartnerPanel.Commit()
