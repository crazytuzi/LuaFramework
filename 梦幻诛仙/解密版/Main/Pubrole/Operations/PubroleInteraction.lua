local Lplus = require("Lplus")
local PubroleOperationBase = require("Main.Pubrole.Operations.PubroleOperationBase")
local PubroleInteraction = Lplus.Extend(PubroleOperationBase, "PubroleInteraction")
local Cls = PubroleInteraction
local def = Cls.define
local const = constant.CInteractionConsts
local InteractionModule = require("Main.DoubleInteraction.DoubleInteractionModule")
def.override("table", "=>", "boolean").CanDispaly = function(self, roleInfo)
  if not InteractionModule.IsFeatureOpen() or _G.GetHeroProp().level < const.OPEN_LEVEL then
    return false
  end
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.DoubleInteraction[1]
end
def.override("table", "=>", "boolean").Operate = function(self, roleInfo)
  require("Main.DoubleInteraction.ui.UIActionList").Instance():ShowPanel(roleInfo)
  return false
end
def.override("table", "=>", "boolean").ExecuteOperation = function(self, roleInfo)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if not role:IsInState(RoleState.GANGCROSS_BATTLE) and _G.CheckCrossServerAndToast() then
    return true
  end
  return self:Operate(roleInfo)
end
return Cls.Commit()
