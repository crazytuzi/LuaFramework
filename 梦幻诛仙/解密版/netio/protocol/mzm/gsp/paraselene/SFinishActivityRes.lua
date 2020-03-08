local SFinishActivityRes = class("SFinishActivityRes")
SFinishActivityRes.TYPEID = 12598287
function SFinishActivityRes:ctor(seconds)
  self.id = 12598287
  self.seconds = seconds or nil
end
function SFinishActivityRes:marshal(os)
  os:marshalInt32(self.seconds)
end
function SFinishActivityRes:unmarshal(os)
  self.seconds = os:unmarshalInt32()
end
function SFinishActivityRes:sizepolicy(size)
  return size <= 65535
end
return SFinishActivityRes
