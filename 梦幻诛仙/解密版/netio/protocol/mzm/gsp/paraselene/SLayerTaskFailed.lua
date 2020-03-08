local SLayerTaskFailed = class("SLayerTaskFailed")
SLayerTaskFailed.TYPEID = 12598288
function SLayerTaskFailed:ctor(layer)
  self.id = 12598288
  self.layer = layer or nil
end
function SLayerTaskFailed:marshal(os)
  os:marshalInt32(self.layer)
end
function SLayerTaskFailed:unmarshal(os)
  self.layer = os:unmarshalInt32()
end
function SLayerTaskFailed:sizepolicy(size)
  return size <= 65535
end
return SLayerTaskFailed
