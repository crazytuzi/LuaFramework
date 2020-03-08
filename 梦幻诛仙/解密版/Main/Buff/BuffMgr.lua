local Lplus = require("Lplus")
local BuffMgr = Lplus.Class("BuffMgr")
local BuffData = require("Main.Buff.data.BuffData")
local SystemBuffData = require("Main.Buff.data.SystemBuffData")
local def = BuffMgr.define
local instance
def.const("number").NUTRITION_BUFF_ID = 1
def.const("number").CAC_BUFF_ID = 2
def.const("number").EQUIP_BROKEN_BUFF_ID = 3
def.field("table").buffList = nil
def.field("table").buffMap = nil
def.field("number").buffAmount = 0
def.field("boolean")._isFillBuffList = false
def.static("=>", BuffMgr).Instance = function()
  if instance == nil then
    instance = BuffMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.buffList = {}
  self.buffMap = {}
end
def.method("number", "=>", BuffData).GetBuff = function(self, buffId)
  return self.buffMap[buffId]
end
def.method("number", "=>", "boolean").HasBuff = function(self, buffId)
  return self:GetBuff(buffId) ~= nil
end
def.method("=>", "table").GetBuffs = function(self)
  return self.buffMap
end
def.method("=>", "number").GetBuffAmount = function(self)
  return self.buffAmount
end
def.method("=>", "table").GetBuffList = function(self)
  local buffs = self:GetBuffs()
  local buffAmount = self:GetBuffAmount()
  local unsortedBuffList = {}
  for k, buff in pairs(buffs) do
    table.insert(unsortedBuffList, buff)
  end
  table.sort(unsortedBuffList, BuffMgr.BuffSortFunction)
  local sortedBuffList = unsortedBuffList
  return sortedBuffList
end
def.method("number").CRemoveBuff = function(self, buffId)
  warn("RemoveBuff", buffId)
  local p = require("netio.protocol.mzm.gsp.buff.CRemoveBuff").new(buffId)
  gmodule.network.sendProtocol(p)
end
def.method("=>", "table").GetInFightBuffs = function(self)
  return self.buffMap
end
def.method("=>", "number").GetInFightBuffAmount = function(self)
  return self.buffAmount
end
def.method("=>", "table").GetInFightBuffList = function(self)
  return self:GetBuffList()
end
def.method("table").SetBuffList = function(self, buffList)
  self.buffList = {}
  self.buffMap = {}
  self._isFillBuffList = true
  self:InitCustomBuffs()
  for i, buff in ipairs(buffList) do
    self:RawAddBuff(buff)
  end
  self._isFillBuffList = false
  Event.DispatchEvent(ModuleId.BUFF, gmodule.notifyId.Buff.SYNC_BUFF_LIST, nil)
end
def.method("table").RawAddBuff = function(self, buff)
  local buffData = SystemBuffData()
  buffData:RawSet(buff)
  self:AddBuff(buffData)
end
def.method(BuffData).AddBuff = function(self, buffData)
  self:AddBuffEx(buffData, nil)
end
def.method(BuffData, "table").AddBuffEx = function(self, buffData, extra)
  local buffId = buffData.id
  local extra = extra or {}
  if not self.buffMap[buffId] then
    self.buffMap[buffId] = buffData
    self.buffAmount = self.buffAmount + 1
    if not self._isFillBuffList then
      Event.DispatchEvent(ModuleId.BUFF, gmodule.notifyId.Buff.ADD_BUFF, {
        buffId,
        extra.silence
      })
    end
  elseif buffId ~= BuffMgr.EQUIP_BROKEN_BUFF_ID then
    warn(string.format("Try to add buff(%d), but it is already exist.", buffId))
  end
end
def.method("number").RemoveBuff = function(self, buffId)
  if self.buffMap[buffId] then
    self.buffMap[buffId] = nil
    self.buffAmount = self.buffAmount - 1
    Event.DispatchEvent(ModuleId.BUFF, gmodule.notifyId.Buff.REMOVE_BUFF, {buffId})
  elseif buffId ~= BuffMgr.EQUIP_BROKEN_BUFF_ID then
    warn(string.format("Try to remove buff(%d), but it is not exist.", buffId))
  end
end
def.method("number", "userdata").SetBuffValue = function(self, buffId, value)
  local buff = self.buffMap[buffId]
  if buff then
    buff:SetRemainValue(value)
    Event.DispatchEvent(ModuleId.BUFF, gmodule.notifyId.Buff.BUFF_INFO_UPDATE, {buffId})
  else
    warn(string.format("Try to set the value of buff(%d), but it is not exist.", buffId))
  end
end
def.static(BuffData, BuffData, "=>", "boolean").BuffSortFunction = function(left, right)
  if left:IsSystemBuff() and right:IsSystemBuff() then
    return SystemBuffData.CompareOrder(left, right)
  else
    return BuffData.CompareOrder(left, right)
  end
end
def.method().InitCustomBuffs = function(self)
  local buffData = require("Main.BUff.data.NutritionBuffData").New()
  self:AddBuff(buffData)
end
def.method("number").UpdateSpecialBuffInfo = function(self, buffId)
  if buffId == BuffMgr.EQUIP_BROKEN_BUFF_ID then
    self:UpdateEquipmentBrokenBuff()
  end
end
def.method().UpdateEquipmentBrokenBuff = function(self)
  local buff = self:GetBuff(BuffMgr.EQUIP_BROKEN_BUFF_ID)
  if Int64.gt(buff.remainValue, 0) then
  end
end
return BuffMgr.Commit()
