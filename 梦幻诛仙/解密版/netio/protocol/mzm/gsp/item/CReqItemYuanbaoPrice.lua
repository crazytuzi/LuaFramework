local CReqItemYuanbaoPrice = class("CReqItemYuanbaoPrice")
CReqItemYuanbaoPrice.TYPEID = 12584769
function CReqItemYuanbaoPrice:ctor(itemids)
  self.id = 12584769
  self.itemids = itemids or {}
end
function CReqItemYuanbaoPrice:marshal(os)
  os:marshalCompactUInt32(table.getn(self.itemids))
  for _, v in ipairs(self.itemids) do
    os:marshalInt32(v)
  end
end
function CReqItemYuanbaoPrice:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemids, v)
  end
end
function CReqItemYuanbaoPrice:sizepolicy(size)
  return size <= 65535
end
return CReqItemYuanbaoPrice
