local AwardBean = require("netio.protocol.mzm.gsp.award.AwardBean")
local SSweepFloorSuc = class("SSweepFloorSuc")
SSweepFloorSuc.TYPEID = 12617752
function SSweepFloorSuc:ctor(activityId, floors, awardBean)
  self.id = 12617752
  self.activityId = activityId or nil
  self.floors = floors or {}
  self.awardBean = awardBean or AwardBean.new()
end
function SSweepFloorSuc:marshal(os)
  os:marshalInt32(self.activityId)
  do
    local _size_ = 0
    for _, _ in pairs(self.floors) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, _ in pairs(self.floors) do
      os:marshalInt32(k)
    end
  end
  self.awardBean:marshal(os)
end
function SSweepFloorSuc:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    self.floors[v] = v
  end
  self.awardBean = AwardBean.new()
  self.awardBean:unmarshal(os)
end
function SSweepFloorSuc:sizepolicy(size)
  return size <= 65535
end
return SSweepFloorSuc
