local SNotifyBandstandEnd = class("SNotifyBandstandEnd")
SNotifyBandstandEnd.TYPEID = 12627970
function SNotifyBandstandEnd:ctor()
  self.id = 12627970
end
function SNotifyBandstandEnd:marshal(os)
end
function SNotifyBandstandEnd:unmarshal(os)
end
function SNotifyBandstandEnd:sizepolicy(size)
  return size <= 65535
end
return SNotifyBandstandEnd
