local CSweepFloorReq = class("CSweepFloorReq")
CSweepFloorReq.TYPEID = 12617751
function CSweepFloorReq:ctor(activityId, startFloor, endFloor, useYuanbao, curYuanbao, needYuanbao)
  self.id = 12617751
  self.activityId = activityId or nil
  self.startFloor = startFloor or nil
  self.endFloor = endFloor or nil
  self.useYuanbao = useYuanbao or nil
  self.curYuanbao = curYuanbao or nil
  self.needYuanbao = needYuanbao or nil
end
function CSweepFloorReq:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.startFloor)
  os:marshalInt32(self.endFloor)
  os:marshalUInt8(self.useYuanbao)
  os:marshalInt64(self.curYuanbao)
  os:marshalInt64(self.needYuanbao)
end
function CSweepFloorReq:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.startFloor = os:unmarshalInt32()
  self.endFloor = os:unmarshalInt32()
  self.useYuanbao = os:unmarshalUInt8()
  self.curYuanbao = os:unmarshalInt64()
  self.needYuanbao = os:unmarshalInt64()
end
function CSweepFloorReq:sizepolicy(size)
  return size <= 65535
end
return CSweepFloorReq
