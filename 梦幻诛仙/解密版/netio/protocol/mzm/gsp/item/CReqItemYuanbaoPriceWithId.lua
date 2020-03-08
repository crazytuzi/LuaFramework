local CReqItemYuanbaoPriceWithId = class("CReqItemYuanbaoPriceWithId")
CReqItemYuanbaoPriceWithId.TYPEID = 12584772
function CReqItemYuanbaoPriceWithId:ctor(uid, itemids)
  self.id = 12584772
  self.uid = uid or nil
  self.itemids = itemids or {}
end
function CReqItemYuanbaoPriceWithId:marshal(os)
  os:marshalInt32(self.uid)
  os:marshalCompactUInt32(table.getn(self.itemids))
  for _, v in ipairs(self.itemids) do
    os:marshalInt32(v)
  end
end
function CReqItemYuanbaoPriceWithId:unmarshal(os)
  self.uid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemids, v)
  end
end
function CReqItemYuanbaoPriceWithId:sizepolicy(size)
  return size <= 65535
end
return CReqItemYuanbaoPriceWithId
