local SStageBroadcast = class("SStageBroadcast")
SStageBroadcast.TYPEID = 12617017
SStageBroadcast.STG_PREPARE = 0
SStageBroadcast.STG_MATCH = 1
SStageBroadcast.STG_FINISH_MATCH = 2
SStageBroadcast.STG_RETURN_ORIGINAL = 3
function SStageBroadcast:ctor(zone, index, backup, stage, countdown)
  self.id = 12617017
  self.zone = zone or nil
  self.index = index or nil
  self.backup = backup or nil
  self.stage = stage or nil
  self.countdown = countdown or nil
end
function SStageBroadcast:marshal(os)
  os:marshalInt32(self.zone)
  os:marshalInt32(self.index)
  os:marshalUInt8(self.backup)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.countdown)
end
function SStageBroadcast:unmarshal(os)
  self.zone = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.backup = os:unmarshalUInt8()
  self.stage = os:unmarshalInt32()
  self.countdown = os:unmarshalInt32()
end
function SStageBroadcast:sizepolicy(size)
  return size <= 65535
end
return SStageBroadcast
