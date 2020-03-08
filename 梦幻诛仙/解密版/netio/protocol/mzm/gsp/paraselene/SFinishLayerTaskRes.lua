local SFinishLayerTaskRes = class("SFinishLayerTaskRes")
SFinishLayerTaskRes.TYPEID = 12598298
function SFinishLayerTaskRes:ctor(layer)
  self.id = 12598298
  self.layer = layer or nil
end
function SFinishLayerTaskRes:marshal(os)
  os:marshalInt32(self.layer)
end
function SFinishLayerTaskRes:unmarshal(os)
  self.layer = os:unmarshalInt32()
end
function SFinishLayerTaskRes:sizepolicy(size)
  return size <= 65535
end
return SFinishLayerTaskRes
