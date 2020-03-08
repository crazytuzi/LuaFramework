local CFlushNewReq = class("CFlushNewReq")
CFlushNewReq.TYPEID = 12584196
function CFlushNewReq:ctor(useYuanbao, curYuanbao, needYuanbao)
  self.id = 12584196
  self.useYuanbao = useYuanbao or nil
  self.curYuanbao = curYuanbao or nil
  self.needYuanbao = needYuanbao or nil
end
function CFlushNewReq:marshal(os)
  os:marshalUInt8(self.useYuanbao)
  os:marshalInt64(self.curYuanbao)
  os:marshalInt64(self.needYuanbao)
end
function CFlushNewReq:unmarshal(os)
  self.useYuanbao = os:unmarshalUInt8()
  self.curYuanbao = os:unmarshalInt64()
  self.needYuanbao = os:unmarshalInt64()
end
function CFlushNewReq:sizepolicy(size)
  return size <= 65535
end
return CFlushNewReq
