local Lplus = require("Lplus")
local ShoppingGroupBase = Lplus.Class("ShoppingGroupBase")
local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local def = ShoppingGroupBase.define
def.field("userdata").m_groupId = nil
def.field("number").m_cfgId = 0
def.field("number").m_status = 0
def.field("number").m_curNum = 0
def.field("number").m_price = 0
def.field("string").m_creatorName = ""
def.field("number").m_endTime = 0
def.method("table").Set = function(self, bean)
  self.m_groupId = bean.group_id
  self.m_cfgId = bean.group_shopping_item_cfgid
  self.m_status = bean.status
  self.m_curNum = bean.member_num
  self.m_price = bean.price
  self.m_creatorName = GetStringFromOcts(bean.creator_name) or textRes.GroupShopping[44]
  self.m_endTime = bean.close_time
end
def.method("=>", "userdata").GetGroupId = function(self)
  return self.m_groupId
end
def.method("=>", "number").GetStatus = function(self)
  return self.m_status
end
def.method("number").SetStatus = function(self, status)
  self.m_status = status
end
def.method("=>", "number").GetCfgId = function(self)
  return self.m_cfgId
end
def.method("=>", "number").GetCurNum = function(self)
  return self.m_curNum
end
def.virtual("number").SetCurNum = function(self, num)
  self.m_curNum = num
end
def.method("=>", "number").GetPrice = function(self)
  return self.m_price
end
def.method("=>", "string").GetCreatorName = function(self)
  return self.m_creatorName
end
def.method("=>", "number").GetEndTime = function(self)
  return self.m_endTime
end
def.method("=>", "number").UpdateStatus = function(self)
  if self.m_status == ShoppingGroupInfo.INCOMPLETED then
    if self:IsFull() then
      self:SetStatus(ShoppingGroupInfo.COMPLETED)
    elseif self:IsExpired() then
      self:SetStatus(ShoppingGroupInfo.FAILED)
    end
  end
  return self.m_status
end
def.virtual("=>", "boolean").IsFull = function(self)
  return false
end
def.method("=>", "boolean").IsExpired = function(self)
  if self.m_status == ShoppingGroupInfo.INCOMPLETED then
    return self.m_endTime < GetServerTime()
  else
    return true
  end
end
def.static(ShoppingGroupBase, ShoppingGroupBase, "=>", "boolean").Compare = function(aGroup, bGroup)
  if aGroup:GetStatus() == 0 and bGroup:GetStatus() > 0 then
    return true
  elseif bGroup:GetStatus() == 0 and aGroup:GetStatus() > 0 then
    return false
  elseif bGroup:GetStatus() == 0 and aGroup:GetStatus() == 0 then
    return aGroup:GetEndTime() < bGroup:GetEndTime()
  else
    return aGroup:GetEndTime() > bGroup:GetEndTime()
  end
end
ShoppingGroupBase.Commit()
return ShoppingGroupBase
