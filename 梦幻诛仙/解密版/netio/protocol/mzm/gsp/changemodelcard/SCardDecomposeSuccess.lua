local SCardDecomposeSuccess = class("SCardDecomposeSuccess")
SCardDecomposeSuccess.TYPEID = 12624400
function SCardDecomposeSuccess:ctor(get_score)
  self.id = 12624400
  self.get_score = get_score or nil
end
function SCardDecomposeSuccess:marshal(os)
  os:marshalInt64(self.get_score)
end
function SCardDecomposeSuccess:unmarshal(os)
  self.get_score = os:unmarshalInt64()
end
function SCardDecomposeSuccess:sizepolicy(size)
  return size <= 65535
end
return SCardDecomposeSuccess
