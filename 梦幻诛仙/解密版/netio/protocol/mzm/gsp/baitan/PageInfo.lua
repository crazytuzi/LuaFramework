local OctetsStream = require("netio.OctetsStream")
local PageInfo = class("PageInfo")
function PageInfo:ctor(pageindex, totalpagenum, subtype, param, shoppingItemList)
  self.pageindex = pageindex or nil
  self.totalpagenum = totalpagenum or nil
  self.subtype = subtype or nil
  self.param = param or nil
  self.shoppingItemList = shoppingItemList or {}
end
function PageInfo:marshal(os)
  os:marshalInt32(self.pageindex)
  os:marshalInt32(self.totalpagenum)
  os:marshalInt32(self.subtype)
  os:marshalInt32(self.param)
  os:marshalCompactUInt32(table.getn(self.shoppingItemList))
  for _, v in ipairs(self.shoppingItemList) do
    v:marshal(os)
  end
end
function PageInfo:unmarshal(os)
  self.pageindex = os:unmarshalInt32()
  self.totalpagenum = os:unmarshalInt32()
  self.subtype = os:unmarshalInt32()
  self.param = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.baitan.ShoppingItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.shoppingItemList, v)
  end
end
return PageInfo
