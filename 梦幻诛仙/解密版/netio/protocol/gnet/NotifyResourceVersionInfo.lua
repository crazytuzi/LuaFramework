local NotifyResourceVersionInfo = class("NotifyResourceVersionInfo")
NotifyResourceVersionInfo.TYPEID = 7109
function NotifyResourceVersionInfo:ctor(resource_type, version, compatible_version)
  self.id = 7109
  self.resource_type = resource_type or nil
  self.version = version or nil
  self.compatible_version = compatible_version or nil
end
function NotifyResourceVersionInfo:marshal(os)
  os:marshalUInt8(self.resource_type)
  os:marshalInt32(self.version)
  os:marshalInt32(self.compatible_version)
end
function NotifyResourceVersionInfo:unmarshal(os)
  self.resource_type = os:unmarshalUInt8()
  self.version = os:unmarshalInt32()
  self.compatible_version = os:unmarshalInt32()
end
function NotifyResourceVersionInfo:sizepolicy(size)
  return size <= 32
end
return NotifyResourceVersionInfo
