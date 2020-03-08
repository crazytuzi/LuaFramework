local Lplus = require("Lplus")
local ShoppingGroupBase = require("Main.GroupShopping.data.ShoppingGroupBase")
local BigShoppingGroup = Lplus.Extend(ShoppingGroupBase, "BigShoppingGroup")
local ShoppingGroupInfo = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
local GroupShoppingUtils = require("Main.GroupShopping.GroupShoppingUtils")
local def = BigShoppingGroup.define
def.final("table", "=>", BigShoppingGroup).UnmarshalGroup = function(bean)
  local group = BigShoppingGroup()
  group:Set(bean)
  return group
end
def.override("number").SetCurNum = function(self, num)
  self.m_curNum = num
end
BigShoppingGroup.Commit()
return BigShoppingGroup
