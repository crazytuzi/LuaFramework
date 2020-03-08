local SSyncAircraftInfo = class("SSyncAircraftInfo")
SSyncAircraftInfo.TYPEID = 12624648
function SSyncAircraftInfo:ctor(own_aircraft_map, current_aircraft_cfg_id)
  self.id = 12624648
  self.own_aircraft_map = own_aircraft_map or {}
  self.current_aircraft_cfg_id = current_aircraft_cfg_id or nil
end
function SSyncAircraftInfo:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.own_aircraft_map) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.own_aircraft_map) do
      os:marshalInt32(k)
      v:marshal(os)
    end
  end
  os:marshalInt32(self.current_aircraft_cfg_id)
end
function SSyncAircraftInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.aircraft.AircraftInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.own_aircraft_map[k] = v
  end
  self.current_aircraft_cfg_id = os:unmarshalInt32()
end
function SSyncAircraftInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncAircraftInfo
