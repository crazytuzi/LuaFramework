local CReportRoleReq = class("CReportRoleReq")
CReportRoleReq.TYPEID = 12585245
function CReportRoleReq:ctor(targetRoleId, explain, reasonId, basis)
  self.id = 12585245
  self.targetRoleId = targetRoleId or nil
  self.explain = explain or nil
  self.reasonId = reasonId or nil
  self.basis = basis or nil
end
function CReportRoleReq:marshal(os)
  os:marshalInt64(self.targetRoleId)
  os:marshalOctets(self.explain)
  os:marshalInt32(self.reasonId)
  os:marshalOctets(self.basis)
end
function CReportRoleReq:unmarshal(os)
  self.targetRoleId = os:unmarshalInt64()
  self.explain = os:unmarshalOctets()
  self.reasonId = os:unmarshalInt32()
  self.basis = os:unmarshalOctets()
end
function CReportRoleReq:sizepolicy(size)
  return size <= 65535
end
return CReportRoleReq
