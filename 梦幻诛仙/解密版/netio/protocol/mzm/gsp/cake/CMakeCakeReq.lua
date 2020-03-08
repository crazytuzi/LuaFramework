local CMakeCakeReq = class("CMakeCakeReq")
CMakeCakeReq.TYPEID = 12627714
function CMakeCakeReq:ctor(activityId, clientTurn, cakeMasterId, uuid, num)
  self.id = 12627714
  self.activityId = activityId or nil
  self.clientTurn = clientTurn or nil
  self.cakeMasterId = cakeMasterId or nil
  self.uuid = uuid or nil
  self.num = num or nil
end
function CMakeCakeReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.clientTurn)
  os:marshalInt64(self.cakeMasterId)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
end
function CMakeCakeReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.clientTurn = os:unmarshalInt32()
  self.cakeMasterId = os:unmarshalInt64()
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
end
function CMakeCakeReq:sizepolicy(size)
  return size <= 65535
end
return CMakeCakeReq
