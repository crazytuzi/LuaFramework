local SCheckFixAwardInfoRep = class("SCheckFixAwardInfoRep")
SCheckFixAwardInfoRep.TYPEID = 12583426
function SCheckFixAwardInfoRep:ctor(moneyValue, expValue, itemMap, appellationId, titleId, itemIndex)
  self.id = 12583426
  self.moneyValue = moneyValue or {}
  self.expValue = expValue or {}
  self.itemMap = itemMap or {}
  self.appellationId = appellationId or nil
  self.titleId = titleId or nil
  self.itemIndex = itemIndex or nil
end
function SCheckFixAwardInfoRep:marshal(os)
  os:marshalCompactUInt32(table.getn(self.moneyValue))
  for _, v in ipairs(self.moneyValue) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.expValue))
  for _, v in ipairs(self.expValue) do
    v:marshal(os)
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.itemMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.itemMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.appellationId)
  os:marshalInt32(self.titleId)
  os:marshalInt32(self.itemIndex)
end
function SCheckFixAwardInfoRep:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.award.MoneyAwardBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.moneyValue, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.award.ExpAwardBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.expValue, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemMap[k] = v
  end
  self.appellationId = os:unmarshalInt32()
  self.titleId = os:unmarshalInt32()
  self.itemIndex = os:unmarshalInt32()
end
function SCheckFixAwardInfoRep:sizepolicy(size)
  return size <= 65535
end
return SCheckFixAwardInfoRep
