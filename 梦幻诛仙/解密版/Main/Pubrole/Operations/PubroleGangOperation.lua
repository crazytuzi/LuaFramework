local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleGangOperation = Lplus.Extend(PubroleOperationBase, "PubroleGangOperation")
local def = PubroleGangOperation.define
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  local GangData = require("Main.Gang.data.GangData")
  local selfGangId = GangData.Instance():GetGangId()
  local targeGangId = roleInfo.gangId
  if selfGangId and targeGangId and Int64.eq(selfGangId, targeGangId) then
    local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    if heroProp then
      local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
      if memberInfo then
        local tbl = require("Main.Gang.GangUtility").GetAuthority(memberInfo.duty)
        if tbl.isCanAssignDuty then
          return true
        end
      end
    end
  end
  return false
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Gang[254]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  local HaveGangPanel = require("Main.Gang.ui.HaveGangPanel")
  HaveGangPanel.Instance():ShowPanelAndSelectMemberWithRoleId(roleInfo.roleId)
  return true
end
PubroleGangOperation.Commit()
return PubroleGangOperation
