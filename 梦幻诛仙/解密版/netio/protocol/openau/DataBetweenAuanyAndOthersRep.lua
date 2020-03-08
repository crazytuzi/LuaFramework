local DataBetweenAuanyAndOthersRep = class("DataBetweenAuanyAndOthersRep")
DataBetweenAuanyAndOthersRep.TYPEID = 8911
function DataBetweenAuanyAndOthersRep:ctor(direction, account, zoneid, roleid, reqtype, reqdata, retcode, repdata, reserved1, reserved2)
  self.id = 8911
  self.direction = direction or nil
  self.account = account or nil
  self.zoneid = zoneid or nil
  self.roleid = roleid or nil
  self.reqtype = reqtype or nil
  self.reqdata = reqdata or nil
  self.retcode = retcode or nil
  self.repdata = repdata or nil
  self.reserved1 = reserved1 or nil
  self.reserved2 = reserved2 or nil
end
function DataBetweenAuanyAndOthersRep:marshal(os)
  os:marshalUInt8(self.direction)
  os:marshalOctets(self.account)
  os:marshalInt32(self.zoneid)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.reqtype)
  os:marshalOctets(self.reqdata)
  os:marshalInt32(self.retcode)
  os:marshalOctets(self.repdata)
  os:marshalInt32(self.reserved1)
  os:marshalOctets(self.reserved2)
end
function DataBetweenAuanyAndOthersRep:unmarshal(os)
  self.direction = os:unmarshalUInt8()
  self.account = os:unmarshalOctets()
  self.zoneid = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.reqtype = os:unmarshalInt32()
  self.reqdata = os:unmarshalOctets()
  self.retcode = os:unmarshalInt32()
  self.repdata = os:unmarshalOctets()
  self.reserved1 = os:unmarshalInt32()
  self.reserved2 = os:unmarshalOctets()
end
function DataBetweenAuanyAndOthersRep:sizepolicy(size)
  return size <= 65535
end
return DataBetweenAuanyAndOthersRep
