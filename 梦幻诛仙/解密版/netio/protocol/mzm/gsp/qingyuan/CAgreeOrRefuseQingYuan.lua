local CAgreeOrRefuseQingYuan = class("CAgreeOrRefuseQingYuan")
CAgreeOrRefuseQingYuan.TYPEID = 12602889
function CAgreeOrRefuseQingYuan:ctor(operator, sessionid)
  self.id = 12602889
  self.operator = operator or nil
  self.sessionid = sessionid or nil
end
function CAgreeOrRefuseQingYuan:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.sessionid)
end
function CAgreeOrRefuseQingYuan:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAgreeOrRefuseQingYuan:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrRefuseQingYuan
