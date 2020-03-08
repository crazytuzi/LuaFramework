local SFinishTaskRes = class("SFinishTaskRes")
SFinishTaskRes.TYPEID = 12610310
function SFinishTaskRes:ctor(typeid, graphid)
  self.id = 12610310
  self.typeid = typeid or nil
  self.graphid = graphid or nil
end
function SFinishTaskRes:marshal(os)
  os:marshalInt32(self.typeid)
  os:marshalInt32(self.graphid)
end
function SFinishTaskRes:unmarshal(os)
  self.typeid = os:unmarshalInt32()
  self.graphid = os:unmarshalInt32()
end
function SFinishTaskRes:sizepolicy(size)
  return size <= 65535
end
return SFinishTaskRes
