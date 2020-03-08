local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleReport = Lplus.Extend(PubroleOperationBase, "PubroleReport")
local RoleDeleteStatus = require("netio.protocol.mzm.gsp.RoleDeleteStatus")
local def = PubroleReport.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if roleInfo.deleteState == RoleDeleteStatus.STATE_NORMAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.PubRole[1002]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  local needLevel = constant.ReportConsts.MIN_LEVEL or 0
  if heroLevel < needLevel then
    Toast(string.format(textRes.PubRole[1004], needLevel))
    return true
  end
  require("Main.Pubrole.ui.ReportDlg").Instance():ShowPanel(roleInfo)
  return true
end
PubroleReport.Commit()
return PubroleReport
