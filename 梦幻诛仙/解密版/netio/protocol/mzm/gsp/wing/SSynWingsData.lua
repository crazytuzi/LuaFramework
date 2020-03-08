local SSynWingsData = class("SSynWingsData")
SSynWingsData.TYPEID = 12596528
SSynWingsData.TYPE__OPEN_WING = 1
SSynWingsData.TYPE__LOGIN = 2
SSynWingsData.TYPE__CHANGE_OCCUPATION_PLAN = 3
function SSynWingsData:ctor(synType, curLv, curRank, curExp, curWing, effectOccupationId, wings, occPalns, newOccPlans)
  self.id = 12596528
  self.synType = synType or nil
  self.curLv = curLv or nil
  self.curRank = curRank or nil
  self.curExp = curExp or nil
  self.curWing = curWing or nil
  self.effectOccupationId = effectOccupationId or nil
  self.wings = wings or {}
  self.occPalns = occPalns or {}
  self.newOccPlans = newOccPlans or {}
end
function SSynWingsData:marshal(os)
  os:marshalInt32(self.synType)
  os:marshalInt32(self.curLv)
  os:marshalInt32(self.curRank)
  os:marshalInt32(self.curExp)
  os:marshalInt32(self.curWing)
  os:marshalInt32(self.effectOccupationId)
  do
    local _size_ = 0
    for _, _ in pairs(self.wings) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.wings) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalCompactUInt32(table.getn(self.occPalns))
  for _, v in ipairs(self.occPalns) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.newOccPlans))
  for _, v in ipairs(self.newOccPlans) do
    os:marshalInt32(v)
  end
end
function SSynWingsData:unmarshal(os)
  self.synType = os:unmarshalInt32()
  self.curLv = os:unmarshalInt32()
  self.curRank = os:unmarshalInt32()
  self.curExp = os:unmarshalInt32()
  self.curWing = os:unmarshalInt32()
  self.effectOccupationId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.WingData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.wings[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.OccWingPlanInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.occPalns, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.newOccPlans, v)
  end
end
function SSynWingsData:sizepolicy(size)
  return size <= 65535
end
return SSynWingsData
