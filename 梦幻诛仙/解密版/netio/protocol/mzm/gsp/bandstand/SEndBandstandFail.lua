local SEndBandstandFail = class("SEndBandstandFail")
SEndBandstandFail.TYPEID = 12627978
SEndBandstandFail.NOT_STARTED = 1
function SEndBandstandFail:ctor(error_code)
  self.id = 12627978
  self.error_code = error_code or nil
end
function SEndBandstandFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SEndBandstandFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SEndBandstandFail:sizepolicy(size)
  return size <= 65535
end
return SEndBandstandFail
