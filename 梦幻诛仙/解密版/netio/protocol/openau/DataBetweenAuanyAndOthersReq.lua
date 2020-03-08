local DataBetweenAuanyAndOthersReq = class("DataBetweenAuanyAndOthersReq")
DataBetweenAuanyAndOthersReq.TYPEID = 8910
function DataBetweenAuanyAndOthersReq:ctor(direction, account, zoneid, roleid, reqtype, reqdata, reserved1, reserved2)
  self.id = 8910
  self.direction = direction or nil
  self.account = account or nil
  self.zoneid = zoneid or nil
  self.roleid = roleid or nil
  self.reqtype = reqtype or nil
  self.reqdata = reqdata or nil
  self.reserved1 = reserved1 or nil
  self.reserved2 = reserved2 or nil
end
function DataBetweenAuanyAndOthersReq:marshal(os)
  os:marshalUInt8(self.direction)
  os:marshalOctets(self.account)
  os:marshalInt32(self.zoneid)
  os:marshalInt64(self.roleid)
  os:marshalInt32(self.reqtype)
  os:marshalOctets(self.reqdata)
  os:marshalInt32(self.reserved1)
  os:marshalOctets(self.reserved2)
end
function DataBetweenAuanyAndOthersReq:unmarshal(os)
  self.direction = os:unmarshalUInt8()
  self.account = os:unmarshalOctets()
  self.zoneid = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.reqtype = os:unmarshalInt32()
  self.reqdata = os:unmarshalOctets()
  self.reserved1 = os:unmarshalInt32()
  self.reserved2 = os:unmarshalOctets()
end
function DataBetweenAuanyAndOthersReq:sizepolicy(size)
  return size <= 65535
end
return DataBetweenAuanyAndOthersReq
