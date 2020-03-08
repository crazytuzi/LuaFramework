local OctetsStream = require("netio.OctetsStream")
local ActivityData = class("ActivityData")
ActivityData.not_take = 0
ActivityData.token = 1
function ActivityData:ctor(actvityId, count, awarded, clearTime)
  self.actvityId = actvityId or nil
  self.count = count or nil
  self.awarded = awarded or nil
  self.clearTime = clearTime or nil
end
function ActivityData:marshal(os)
  os:marshalInt32(self.actvityId)
  os:marshalInt32(self.count)
  os:marshalInt32(self.awarded)
  os:marshalInt64(self.clearTime)
end
function ActivityData:unmarshal(os)
  self.actvityId = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.awarded = os:unmarshalInt32()
  self.clearTime = os:unmarshalInt64()
end
return ActivityData
