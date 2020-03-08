require("framework.init")
local OctetsStream = require("netio.OctetsStream")
local Octets = class("Octets")
function Octets.raw()
  local o = Octets.new()
  return o.data
end
function Octets.rawFromString(str)
  local o = Octets.new()
  o:fromString(str)
  return o.data
end
function Octets.rawFromBean(bean)
  local o = Octets.new()
  o:fromBean(bean)
  return o.data
end
function Octets.rawFromVector(tbl, tName)
  local o = Octets.new()
  o:fromVector(tbl, tName)
  return o.data
end
function Octets:ctor(data)
  self.data = data or nil
  if not self.data then
    local key, os = OctetsStream.beginTempStream()
    self.data = os:unmarshalOctets()
    OctetsStream.endTempStream(key)
  end
end
function Octets:marshal(os)
  os:marshalOctets(self.data)
end
function Octets:unmarshal(os)
  self.data = os:unmarshalOctets()
end
function Octets:toString()
  local key, os = OctetsStream.beginTempStream()
  self:marshal(os)
  local str = os:unmarshalStringFromOctets()
  OctetsStream.endTempStream(key)
  return str
end
function Octets:fromString(str)
  local key, os = OctetsStream.beginTempStream()
  os:marshalStringToOctets(str)
  self:unmarshal(os)
  OctetsStream.endTempStream(key)
end
function Octets:toVector(tName)
  local key, os = OctetsStream.beginTempStream()
  self:marshal(os)
  local tbl = os:unmarshalVectorFromOctets(tName)
  OctetsStream.endTempStream(key)
  return tbl
end
function Octets:fromVector(tbl, tName)
  local key, os = OctetsStream.beginTempStream()
  os:marshalVectorToOctets(tbl, tName)
  self:unmarshal(os)
  OctetsStream.endTempStream(key)
end
function Octets:fromBean(bean)
  local key, os = OctetsStream.beginTempStream()
  bean:marshal(os)
  self.data = os:getData()
  OctetsStream.endTempStream(key)
end
function Octets:unmarshalBean(bean)
  local key, os = OctetsStream.beginWrapWithOctets(self)
  bean:unmarshal(os)
  OctetsStream.endWrapWithOctets(key)
end
function Octets:getSize()
  return OctetsStream.getOctetsSize(self)
end
return Octets
