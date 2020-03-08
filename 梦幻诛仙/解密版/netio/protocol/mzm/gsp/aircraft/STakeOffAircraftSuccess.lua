local STakeOffAircraftSuccess = class("STakeOffAircraftSuccess")
STakeOffAircraftSuccess.TYPEID = 12624642
function STakeOffAircraftSuccess:ctor()
  self.id = 12624642
end
function STakeOffAircraftSuccess:marshal(os)
end
function STakeOffAircraftSuccess:unmarshal(os)
end
function STakeOffAircraftSuccess:sizepolicy(size)
  return size <= 65535
end
return STakeOffAircraftSuccess
