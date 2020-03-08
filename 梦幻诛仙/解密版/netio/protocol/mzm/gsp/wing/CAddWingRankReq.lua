local CAddWingRankReq = class("CAddWingRankReq")
CAddWingRankReq.TYPEID = 12596529
function CAddWingRankReq:ctor(uuid, num, useYuanbao, curYuanbao)
  self.id = 12596529
  self.uuid = uuid or nil
  self.num = num or nil
  self.useYuanbao = useYuanbao or nil
  self.curYuanbao = curYuanbao or nil
end
function CAddWingRankReq:marshal(os)
  os:marshalInt64(self.uuid)
  os:marshalInt32(self.num)
  os:marshalUInt8(self.useYuanbao)
  os:marshalInt64(self.curYuanbao)
end
function CAddWingRankReq:unmarshal(os)
  self.uuid = os:unmarshalInt64()
  self.num = os:unmarshalInt32()
  self.useYuanbao = os:unmarshalUInt8()
  self.curYuanbao = os:unmarshalInt64()
end
function CAddWingRankReq:sizepolicy(size)
  return size <= 65535
end
return CAddWingRankReq
