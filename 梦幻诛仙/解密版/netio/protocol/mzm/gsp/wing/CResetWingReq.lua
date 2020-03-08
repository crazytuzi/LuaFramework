local CResetWingReq = class("CResetWingReq")
CResetWingReq.TYPEID = 12596536
function CResetWingReq:ctor(cfgId, resetType, uuid, num, useYuanbao, curYuanbao)
  self.id = 12596536
  self.cfgId = cfgId or nil
  self.resetType = resetType or nil
  self.uuid = uuid or nil
  self.num = num or nil
  self.useYuanbao = useYuanbao or nil
  self.curYuanbao = curYuanbao or nil
end
function CResetWingReq:marshal(os)
  os:marshalInt32(self.cfgId)
  os:marshalUInt8(self.resetType)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
  os:marshalUInt8(self.useYuanbao)
  os:marshalInt64(self.curYuanbao)
end
function CResetWingReq:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
  self.resetType = os:unmarshalUInt8()
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
  self.useYuanbao = os:unmarshalUInt8()
  self.curYuanbao = os:unmarshalInt64()
end
function CResetWingReq:sizepolicy(size)
  return size <= 65535
end
return CResetWingReq
