local Lplus = require("Lplus")
local GroupShoppingData = Lplus.Class("GroupShoppingData")
local BigShoppingGroup = require("Main.GroupShopping.data.BigShoppingGroup")
local SmallShoppingGroup = require("Main.GroupShopping.data.SmallShoppingGroup")
local ShoppingGroupBase = require("Main.GroupShopping.data.ShoppingGroupBase")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
local def = GroupShoppingData.define
def.field("table").m_smallGroup = nil
def.field("table").m_bigGroup = nil
def.static("=>", GroupShoppingData).new = function()
  return GroupShoppingData()
end
def.method().Clear = function(self)
  self.m_smallGroup = nil
  self.m_bigGroup = nil
end
def.method("table").AddSmallGroup = function(self, bean)
  local smallGroup = SmallShoppingGroup.UnmarshalGroup(bean)
  if self.m_smallGroup == nil then
    self.m_smallGroup = {}
  end
  self.m_smallGroup[smallGroup:GetGroupId():tostring()] = smallGroup
end
def.method("table").AddBigGroup = function(self, bean)
  local bigGroup = BigShoppingGroup.UnmarshalGroup(bean)
  if self.m_bigGroup == nil then
    self.m_bigGroup = {}
  end
  self.m_bigGroup[bigGroup:GetGroupId():tostring()] = bigGroup
end
def.method("table").AddGroup = function(self, bean)
  local type = GroupShoppingUtils.GetGroupType(bean.group_shopping_item_cfgid)
  if type == 0 then
    self:AddSmallGroup(bean)
  elseif type == 1 then
    self:AddBigGroup(bean)
  end
end
def.method("userdata", "=>", SmallShoppingGroup).GetSmallGroup = function(self, groupId)
  if self.m_smallGroup == nil or groupId == nil then
    return nil
  end
  return self.m_smallGroup[groupId:tostring()]
end
def.method("userdata", "=>", BigShoppingGroup).GetBigGroup = function(self, groupId)
  if self.m_bigGroup == nil or groupId == nil then
    return nil
  end
  return self.m_bigGroup[groupId:tostring()]
end
def.method("userdata", "=>", "table").GetGroup = function(self, groupId)
  if groupId == nil then
    return nil
  end
  local groupIdStr = groupId:tostring()
  if self.m_smallGroup and self.m_smallGroup[groupIdStr] then
    return self.m_smallGroup[groupIdStr]
  end
  if self.m_bigGroup and self.m_bigGroup[groupIdStr] then
    return self.m_bigGroup[groupIdStr]
  end
  return nil
end
def.method("number", "=>", "boolean").IsSmallBuying = function(self, cfgId)
  if self.m_smallGroup then
    for k, v in pairs(self.m_smallGroup) do
      if v:GetCfgId() == cfgId and v:UpdateStatus() == ShoppingGroupInfo.INCOMPLETED then
        return true
      end
    end
    return false
  else
    return false
  end
end
def.method("number", "=>", "boolean").IsBigBuying = function(self, cfgId)
  if self.m_bigGroup then
    for k, v in pairs(self.m_bigGroup) do
      if v:GetCfgId() == cfgId and v:UpdateStatus() == ShoppingGroupInfo.INCOMPLETED then
        return true
      end
    end
    return false
  else
    return false
  end
end
def.method("number", "=>", "boolean").IsBuying = function(self, cfgId)
  return self:IsSmallBuying(cfgId) or self:IsBigBuying(cfgId)
end
def.method("number", "=>", "table").GetAllSmallGroupSorted = function(self, filter)
  if self.m_smallGroup == nil then
    return {}
  end
  local tbl = {}
  for k, v in pairs(self.m_smallGroup) do
    if filter > 0 and v:GetCfgId() == filter then
      table.insert(tbl, v)
    end
  end
  table.sort(tbl, ShoppingGroupBase.Compare)
  return tbl
end
def.method("number", "=>", "table").GetAllBigGroupSorted = function(self)
  if self.m_bigGroup == nil then
    return {}
  end
  local tbl = {}
  for k, v in pairs(self.m_bigGroup) do
    if filter > 0 and v:GetCfgId() == filter then
      table.insert(tbl, v)
    end
  end
  table.sort(tbl, ShoppingGroupBase.Compare)
  return tbl
end
def.method("number", "=>", "table").GetAllGroupSorted = function(self, filter)
  local tbl = {}
  if self.m_bigGroup then
    for k, v in pairs(self.m_bigGroup) do
      if filter > 0 then
        if v:GetCfgId() == filter then
          table.insert(tbl, v)
        end
      else
        table.insert(tbl, v)
      end
    end
  end
  if self.m_smallGroup then
    for k, v in pairs(self.m_smallGroup) do
      if filter > 0 then
        if v:GetCfgId() == filter then
          table.insert(tbl, v)
        end
      else
        table.insert(tbl, v)
      end
    end
  end
  table.sort(tbl, ShoppingGroupBase.Compare)
  return tbl
end
def.method().FailAllBigGroup = function(self)
  self.m_bigGroup = nil
end
def.method().FailAllSmallGroup = function(self)
  self.m_smallGroup = nil
end
def.method("number").FailGroup = function(self, cfgId)
  if self.m_smallGroup then
    for k, v in pairs(self.m_smallGroup) do
      if v:GetCfgId() == cfgId then
        self.m_smallGroup[k] = nil
        return
      end
    end
  end
  if self.m_bigGroup then
    for k, v in pairs(self.m_bigGroup) do
      if v:GetCfgId() == cfgId then
        self.m_bigGroup[k] = nil
        return
      end
    end
  end
end
GroupShoppingData.Commit()
return GroupShoppingData
