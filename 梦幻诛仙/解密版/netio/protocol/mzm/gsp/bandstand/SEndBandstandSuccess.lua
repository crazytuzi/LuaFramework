local SEndBandstandSuccess = class("SEndBandstandSuccess")
SEndBandstandSuccess.TYPEID = 12627969
function SEndBandstandSuccess:ctor()
  self.id = 12627969
end
function SEndBandstandSuccess:marshal(os)
end
function SEndBandstandSuccess:unmarshal(os)
end
function SEndBandstandSuccess:sizepolicy(size)
  return size <= 65535
end
return SEndBandstandSuccess
