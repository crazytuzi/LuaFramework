local CAgreeOrRefuseShouTu = class("CAgreeOrRefuseShouTu")
CAgreeOrRefuseShouTu.TYPEID = 12601606
function CAgreeOrRefuseShouTu:ctor(operator, sessionid)
  self.id = 12601606
  self.operator = operator or nil
  self.sessionid = sessionid or nil
end
function CAgreeOrRefuseShouTu:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.sessionid)
end
function CAgreeOrRefuseShouTu:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAgreeOrRefuseShouTu:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrRefuseShouTu
