local SStartBandstandFail = class("SStartBandstandFail")
SStartBandstandFail.TYPEID = 12627974
SStartBandstandFail.ACTIVITY_NOT_OPEN = 1
SStartBandstandFail.ACTIVITY_TYPE_ERROR = 2
SStartBandstandFail.ALREADY_STARTED = 3
SStartBandstandFail.NPC_SERVICE_NOT_AVAILABLE = 4
function SStartBandstandFail:ctor(error_code)
  self.id = 12627974
  self.error_code = error_code or nil
end
function SStartBandstandFail:marshal(os)
  os:marshalInt32(self.error_code)
end
function SStartBandstandFail:unmarshal(os)
  self.error_code = os:unmarshalInt32()
end
function SStartBandstandFail:sizepolicy(size)
  return size <= 65535
end
return SStartBandstandFail
