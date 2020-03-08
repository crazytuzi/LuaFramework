local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenMountsPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenMountsPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_MOUNTS_CLICK, nil)
  return true
end
return OpenMountsPanel.Commit()
