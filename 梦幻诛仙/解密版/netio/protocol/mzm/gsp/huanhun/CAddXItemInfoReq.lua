local CAddXItemInfoReq = class("CAddXItemInfoReq")
CAddXItemInfoReq.TYPEID = 12584454
function CAddXItemInfoReq:ctor(roleIdSeekHelp, itemIndex, items)
  self.id = 12584454
  self.roleIdSeekHelp = roleIdSeekHelp or nil
  self.itemIndex = itemIndex or nil
  self.items = items or {}
end
function CAddXItemInfoReq:marshal(os)
  os:marshalInt64(self.roleIdSeekHelp)
  os:marshalInt32(self.itemIndex)
  os:marshalCompactUInt32(table.getn(self.items))
  for _, v in ipairs(self.items) do
    v:marshal(os)
  end
end
function CAddXItemInfoReq:unmarshal(os)
  self.roleIdSeekHelp = os:unmarshalInt64()
  self.itemIndex = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.huanhun.GiveoutItemBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.items, v)
  end
end
function CAddXItemInfoReq:sizepolicy(size)
  return size <= 65535
end
return CAddXItemInfoReq
