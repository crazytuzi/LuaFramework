local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenBackHomelandPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenBackHomelandPanel.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_RETURN_HOME_CLICK, nil)
  return true
end
return OpenBackHomelandPanel.Commit()
