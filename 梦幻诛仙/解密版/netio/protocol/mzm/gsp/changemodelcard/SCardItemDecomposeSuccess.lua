local SCardItemDecomposeSuccess = class("SCardItemDecomposeSuccess")
SCardItemDecomposeSuccess.TYPEID = 12624405
function SCardItemDecomposeSuccess:ctor(get_score)
  self.id = 12624405
  self.get_score = get_score or nil
end
function SCardItemDecomposeSuccess:marshal(os)
  os:marshalInt64(self.get_score)
end
function SCardItemDecomposeSuccess:unmarshal(os)
  self.get_score = os:unmarshalInt64()
end
function SCardItemDecomposeSuccess:sizepolicy(size)
  return size <= 65535
end
return SCardItemDecomposeSuccess
