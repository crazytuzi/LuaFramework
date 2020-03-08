local Location = require("netio.protocol.mzm.gsp.map.Location")
local SEnterWorld = class("SEnterWorld")
SEnterWorld.TYPEID = 12590865
SEnterWorld.TYPE_PET = 1
SEnterWorld.TYPE_CHILDREN = 2
function SEnterWorld:ctor(mapid, mapInstanceId, modelinfo, pos, direction, othermodel)
  self.id = 12590865
  self.mapid = mapid or nil
  self.mapInstanceId = mapInstanceId or nil
  self.modelinfo = modelinfo or nil
  self.pos = pos or Location.new()
  self.direction = direction or nil
  self.othermodel = othermodel or {}
end
function SEnterWorld:marshal(os)
  os:marshalInt32(self.mapid)
  os:marshalInt32(self.mapInstanceId)
  os:marshalOctets(self.modelinfo)
  self.pos:marshal(os)
  os:marshalInt32(self.direction)
  local _size_ = 0
  for _, _ in pairs(self.othermodel) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.othermodel) do
    os:marshalInt32(k)
    os:marshalOctets(v)
  end
end
function SEnterWorld:unmarshal(os)
  self.mapid = os:unmarshalInt32()
  self.mapInstanceId = os:unmarshalInt32()
  self.modelinfo = os:unmarshalOctets()
  self.pos = Location.new()
  self.pos:unmarshal(os)
  self.direction = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalOctets()
    self.othermodel[k] = v
  end
end
function SEnterWorld:sizepolicy(size)
  return size <= 65535
end
return SEnterWorld
