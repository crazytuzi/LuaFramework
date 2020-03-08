local CLianYaoReq = class("CLianYaoReq")
CLianYaoReq.TYPEID = 12589058
function CLianYaoReq:ctor(skillBagId, itemKeyList)
  self.id = 12589058
  self.skillBagId = skillBagId or nil
  self.itemKeyList = itemKeyList or {}
end
function CLianYaoReq:marshal(os)
  os:marshalInt32(self.skillBagId)
  os:marshalCompactUInt32(table.getn(self.itemKeyList))
  for _, v in ipairs(self.itemKeyList) do
    os:marshalInt32(v)
  end
end
function CLianYaoReq:unmarshal(os)
  self.skillBagId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemKeyList, v)
  end
end
function CLianYaoReq:sizepolicy(size)
  return size <= 65535
end
return CLianYaoReq
