local SLongjingUnMountSucRes = class("SLongjingUnMountSucRes")
SLongjingUnMountSucRes.TYPEID = 12596006
function SLongjingUnMountSucRes:ctor(itemids)
  self.id = 12596006
  self.itemids = itemids or {}
end
function SLongjingUnMountSucRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.itemids))
  for _, v in ipairs(self.itemids) do
    os:marshalInt32(v)
  end
end
function SLongjingUnMountSucRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemids, v)
  end
end
function SLongjingUnMountSucRes:sizepolicy(size)
  return size <= 65535
end
return SLongjingUnMountSucRes
