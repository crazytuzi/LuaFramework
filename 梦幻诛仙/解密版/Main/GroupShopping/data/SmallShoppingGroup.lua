local Lplus = require("Lplus")
local ShoppingGroupBase = require("Main.GroupShopping.data.ShoppingGroupBase")
local SmallShoppingGroup = Lplus.Extend(ShoppingGroupBase, "SmallShoppingGroup")
local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local def = SmallShoppingGroup.define
def.final("table", "=>", SmallShoppingGroup).UnmarshalGroup = function(bean)
  local group = SmallShoppingGroup()
  group:Set(bean)
  return group
end
def.override("=>", "boolean").IsFull = function(self)
  local cfg = GroupShoppingUtils.GetSmallGroupCfg(self.m_cfgId)
  if cfg then
    return self.m_curNum >= cfg.groupSize
  else
    return false
  end
end
def.override("number").SetCurNum = function(self, num)
  self.m_curNum = num
  if self:IsFull() then
    self:SetStatus(ShoppingGroupInfo.COMPLETED)
  end
end
SmallShoppingGroup.Commit()
return SmallShoppingGroup
