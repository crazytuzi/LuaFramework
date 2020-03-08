local CChangeWingColor = class("CChangeWingColor")
CChangeWingColor.TYPEID = 12596525
function CChangeWingColor:ctor(cfgId, uuid, num, useYuanbao, curYuanbao)
  self.id = 12596525
  self.cfgId = cfgId or nil
  self.uuid = uuid or nil
  self.num = num or nil
  self.useYuanbao = useYuanbao or nil
  self.curYuanbao = curYuanbao or nil
end
function CChangeWingColor:marshal(os)
  os:marshalInt32(self.cfgId)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
  os:marshalUInt8(self.useYuanbao)
  os:marshalInt64(self.curYuanbao)
end
function CChangeWingColor:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
  self.useYuanbao = os:unmarshalUInt8()
  self.curYuanbao = os:unmarshalInt64()
end
function CChangeWingColor:sizepolicy(size)
  return size <= 65535
end
return CChangeWingColor
