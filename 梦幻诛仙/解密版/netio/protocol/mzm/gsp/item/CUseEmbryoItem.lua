local CUseEmbryoItem = class("CUseEmbryoItem")
CUseEmbryoItem.TYPEID = 12584872
function CUseEmbryoItem:ctor(uuid)
  self.id = 12584872
  self.uuid = uuid or nil
end
function CUseEmbryoItem:marshal(os)
  os:marshalInt64(self.uuid)
end
function CUseEmbryoItem:unmarshal(os)
  self.uuid = os:unmarshalInt64()
end
function CUseEmbryoItem:sizepolicy(size)
  return size <= 65535
end
return CUseEmbryoItem
