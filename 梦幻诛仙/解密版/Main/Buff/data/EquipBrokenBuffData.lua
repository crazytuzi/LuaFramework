local Lplus = require("Lplus")
local CustomBuffData = require("Main.Buff.data.CustomBuffData")
local EquipBrokenBuffData = Lplus.Extend(CustomBuffData, "EquipBrokenBuffData")
local BuffMgr = Lplus.ForwardDeclare("BuffMgr")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local def = EquipBrokenBuffData.define
def.final("=>", EquipBrokenBuffData).New = function()
  local obj = EquipBrokenBuffData()
  obj:OnInit()
  return obj
end
def.method().OnInit = function(self)
  self.id = BuffMgr.EQUIP_BROKEN_BUFF_ID
  self.needAniOnAdd = false
  self.canSupplement = true
  local buff = ItemModule.Instance():GetEquipBrokenBuff()
  if buff == nil then
    warn("ItemModule.Instance():GetEquipBrokenBuff() return nil")
  end
  self.name = buff and buff.title or "nil"
  self.icon = buff and buff.icon or 0
  self.desc = buff and buff.desc or "nil"
  self.stateDesc = buff and buff.times or "nil"
end
def.override("=>", "boolean").NeedShowLight = function(self)
  return true
end
def.override().OnSupplement = function(self)
  ItemModule.Instance():FixAllEquip(false)
end
return EquipBrokenBuffData.Commit()
