local Lplus = require("Lplus")
local CustomBuffData = require("Main.Buff.data.CustomBuffData")
local NutritionBuffData = Lplus.Extend(CustomBuffData, "NutritionBuffData")
local BuffMgr = Lplus.ForwardDeclare("BuffMgr")
local HeroUtility = require("Main.Hero.HeroUtility")
local def = NutritionBuffData.define
def.const("number").NEARLY_DISAPPEAR_VAL = 5
def.final("=>", NutritionBuffData).New = function()
  local obj = NutritionBuffData()
  obj:OnInit()
  return obj
end
def.method().OnInit = function(self)
  self.id = BuffMgr.NUTRITION_BUFF_ID
  self.canSupplement = true
  self.icon = HeroUtility.Instance():GetRoleCommonConsts("BAOSHIDU_ICON_ID")
  self.name = textRes.Buff[14]
  self.desc = textRes.Buff[13]
end
def.override("=>", "boolean").NeedShowLight = function(self)
  local TipThreshhold = HeroUtility.Instance():GetRoleCommonConsts("BAOTIP_LIMIT")
  if TipThreshhold and self.remainValue:lt(TipThreshhold) then
    return true
  else
    return false
  end
end
def.override().OnSupplement = function(self)
  Event.DispatchEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REQ_SUPPLEMENT_NUTRITION_PANEL, nil)
end
def.override("=>", "string").GetStateDescription = function(self)
  local formatText = string.format(textRes.Buff[19], textRes.Buff.EffectType[1], tostring(self.remainValue))
  return formatText
end
def.override("=>", "boolean").IsNearlyDisappear = function(self)
  return self.remainValue:le(NutritionBuffData.NEARLY_DISAPPEAR_VAL)
end
return NutritionBuffData.Commit()
