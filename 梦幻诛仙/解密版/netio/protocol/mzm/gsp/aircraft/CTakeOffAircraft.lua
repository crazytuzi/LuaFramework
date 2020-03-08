local CTakeOffAircraft = class("CTakeOffAircraft")
CTakeOffAircraft.TYPEID = 12624647
function CTakeOffAircraft:ctor()
  self.id = 12624647
end
function CTakeOffAircraft:marshal(os)
end
function CTakeOffAircraft:unmarshal(os)
end
function CTakeOffAircraft:sizepolicy(size)
  return size <= 65535
end
return CTakeOffAircraft
