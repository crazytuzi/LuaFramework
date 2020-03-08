local SSynWorshipInfo = class("SSynWorshipInfo")
SSynWorshipInfo.TYPEID = 12612613
function SSynWorshipInfo:ctor(worshipId2num, worshipRecord, worshipId, lastCycleNum, thisCycleNum, canGetSalary, nextCanGetSalary)
  self.id = 12612613
  self.worshipId2num = worshipId2num or {}
  self.worshipRecord = worshipRecord or {}
  self.worshipId = worshipId or nil
  self.lastCycleNum = lastCycleNum or nil
  self.thisCycleNum = thisCycleNum or nil
  self.canGetSalary = canGetSalary or nil
  self.nextCanGetSalary = nextCanGetSalary or nil
end
function SSynWorshipInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.worshipId2num) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.worshipId2num) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalCompactUInt32(table.getn(self.worshipRecord))
  for _, v in ipairs(self.worshipRecord) do
    v:marshal(os)
  end
  os:marshalInt32(self.worshipId)
  os:marshalInt32(self.lastCycleNum)
  os:marshalInt32(self.thisCycleNum)
  os:marshalInt32(self.canGetSalary)
  os:marshalInt32(self.nextCanGetSalary)
end
function SSynWorshipInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.worshipId2num[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.worship.SingleWorshipInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.worshipRecord, v)
  end
  self.worshipId = os:unmarshalInt32()
  self.lastCycleNum = os:unmarshalInt32()
  self.thisCycleNum = os:unmarshalInt32()
  self.canGetSalary = os:unmarshalInt32()
  self.nextCanGetSalary = os:unmarshalInt32()
end
function SSynWorshipInfo:sizepolicy(size)
  return size <= 65535
end
return SSynWorshipInfo
