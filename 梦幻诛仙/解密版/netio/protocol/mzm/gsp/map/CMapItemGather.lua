local CMapItemGather = class("CMapItemGather")
CMapItemGather.TYPEID = 12590858
function CMapItemGather:ctor(instanceId)
  self.id = 12590858
  self.instanceId = instanceId or nil
end
function CMapItemGather:marshal(os)
  os:marshalInt32(self.instanceId)
end
function CMapItemGather:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
end
function CMapItemGather:sizepolicy(size)
  return size <= 65535
end
return CMapItemGather
