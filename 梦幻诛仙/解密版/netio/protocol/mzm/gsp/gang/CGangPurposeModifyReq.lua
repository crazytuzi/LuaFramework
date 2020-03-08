local CGangPurposeModifyReq = class("CGangPurposeModifyReq")
CGangPurposeModifyReq.TYPEID = 12589869
function CGangPurposeModifyReq:ctor(purpose)
  self.id = 12589869
  self.purpose = purpose or nil
end
function CGangPurposeModifyReq:marshal(os)
  os:marshalString(self.purpose)
end
function CGangPurposeModifyReq:unmarshal(os)
  self.purpose = os:unmarshalString()
end
function CGangPurposeModifyReq:sizepolicy(size)
  return size <= 65535
end
return CGangPurposeModifyReq
