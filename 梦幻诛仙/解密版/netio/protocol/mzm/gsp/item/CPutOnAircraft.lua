local CPutOnAircraft = class("CPutOnAircraft")
CPutOnAircraft.TYPEID = 12584814
function CPutOnAircraft:ctor(uuid)
  self.id = 12584814
  self.uuid = uuid or nil
end
function CPutOnAircraft:marshal(os)
  os:marshalInt64(self.uuid)
end
function CPutOnAircraft:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CPutOnAircraft:sizepolicy(size)
  return size <= 65535
end
return CPutOnAircraft
