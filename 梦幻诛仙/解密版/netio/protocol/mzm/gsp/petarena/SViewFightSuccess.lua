local SViewFightSuccess = class("SViewFightSuccess")
SViewFightSuccess.TYPEID = 12628247
function SViewFightSuccess:ctor(recordid)
  self.id = 12628247
  self.recordid = recordid or nil
end
function SViewFightSuccess:marshal(os)
  os:marshalInt64(self.recordid)
end
function SViewFightSuccess:unmarshal(os)
  self.recordid = os:unmarshalInt64()
end
function SViewFightSuccess:sizepolicy(size)
  return size <= 65535
end
return SViewFightSuccess
