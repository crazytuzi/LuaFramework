local CGiveFlowerReq = class("CGiveFlowerReq")
CGiveFlowerReq.TYPEID = 12584793
function CGiveFlowerReq:ctor(receiverRoleid, itemid, itemnum, message)
  self.id = 12584793
  self.receiverRoleid = receiverRoleid or nil
  self.itemid = itemid or nil
  self.itemnum = itemnum or nil
  self.message = message or nil
end
function CGiveFlowerReq:marshal(os)
  os:marshalInt64(self.receiverRoleid)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemnum)
  os:marshalString(self.message)
end
function CGiveFlowerReq:unmarshal(os)
  self.receiverRoleid = os:unmarshalInt64()
  self.itemid = os:unmarshalInt32()
  self.itemnum = os:unmarshalInt32()
  self.message = os:unmarshalString()
end
function CGiveFlowerReq:sizepolicy(size)
  return size <= 65535
end
return CGiveFlowerReq
