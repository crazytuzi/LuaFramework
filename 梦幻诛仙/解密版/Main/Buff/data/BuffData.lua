local Lplus = require("Lplus")
local BuffData = Lplus.Class("BuffData")
local EffectType = require("consts.mzm.gsp.buff.confbean.EffectType")
local BuffInfo = require("netio.protocol.mzm.gsp.buff.BuffInfo")
local BuffMgr = Lplus.ForwardDeclare("BuffMgr")
local def = BuffData.define
def.const("table").EffectType = EffectType
def.field("number").id = 0
def.field("number").icon = 0
def.field("string").name = ""
def.field("string").desc = ""
def.field("string").stateDesc = ""
def.field("boolean").needAniOnAdd = true
def.field("boolean").canSupplement = false
def.field("boolean").canDelete = false
def.field("userdata").remainValue = function()
  return Int64.new(0)
end
def.virtual("=>", "number").GetIcon = function(self)
  return self.icon
end
def.virtual("=>", "string").GetName = function(self)
  return self.name
end
def.virtual("=>", "string").GetDescription = function(self)
  return self.desc
end
def.virtual("=>", "string").GetStateDescription = function(self)
  return self.stateDesc
end
def.virtual("=>", "boolean").CanDelete = function(self)
  return self.canDelete
end
def.virtual("=>", "boolean").HasCustomAction = function(self)
  return false
end
def.virtual("=>", "string").GetCustomActionName = function(self)
  return ""
end
def.virtual("=>", "boolean").CanSupplement = function(self)
  return self.canSupplement
end
def.virtual("=>", "boolean").NeedShowLight = function(self)
  return false
end
def.virtual("=>", "boolean").NeedTickDescription = function(self)
  return false
end
def.virtual("=>", "boolean").NeedTickStateDescription = function(self)
  return false
end
def.method("=>", "userdata").GetRemainValue = function(self)
  return self.remainValue
end
def.method("userdata").SetRemainValue = function(self, remainValue)
  self.remainValue = remainValue
end
def.virtual().OnSupplement = function(self)
end
def.virtual().OnDelete = function(self)
end
def.virtual().OnCustomAction = function(self)
end
def.final(BuffData, BuffData, "=>", "boolean").CompareOrder = function(left, right)
  return left.id < right.id
end
def.virtual("=>", "boolean").IsSystemBuff = function(self)
  return false
end
def.virtual("=>", "boolean").IsNearlyDisappear = function(self)
  return false
end
def.method("=>", "number").GetChartlet = function(self)
  local chartletCfg = require("Main.Buff.BuffUtility").GetBuffChartletCfg(self.id)
  if chartletCfg then
    return chartletCfg.icon
  else
    return 0
  end
end
def.virtual("=>", "boolean").NeedAniOnAdd = function(self)
  return self.needAniOnAdd
end
return BuffData.Commit()
