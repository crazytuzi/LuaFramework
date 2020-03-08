local SReceiveStartTaskRes = class("SReceiveStartTaskRes")
SReceiveStartTaskRes.TYPEID = 12610318
function SReceiveStartTaskRes:ctor(result, typeid, graphid)
  self.id = 12610318
  self.result = result or nil
  self.typeid = typeid or nil
  self.graphid = graphid or nil
end
function SReceiveStartTaskRes:marshal(os)
  os:marshalInt32(self.result)
  os:marshalInt32(self.typeid)
  os:marshalInt32(self.graphid)
end
function SReceiveStartTaskRes:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.typeid = os:unmarshalInt32()
  self.graphid = os:unmarshalInt32()
end
function SReceiveStartTaskRes:sizepolicy(size)
  return size <= 65535
end
return SReceiveStartTaskRes
