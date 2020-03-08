local CUseAvatarFrameUnlockItemReq = class("CUseAvatarFrameUnlockItemReq")
CUseAvatarFrameUnlockItemReq.TYPEID = 12615185
function CUseAvatarFrameUnlockItemReq:ctor(item_uuid)
  self.id = 12615185
  self.item_uuid = item_uuid or nil
end
function CUseAvatarFrameUnlockItemReq:marshal(os)
  os:marshalInt64(self.item_uuid)
end
function CUseAvatarFrameUnlockItemReq:unmarshal(os)
  self.item_uuid = os:unmarshalInt64()
end
function CUseAvatarFrameUnlockItemReq:sizepolicy(size)
  return size <= 65535
end
return CUseAvatarFrameUnlockItemReq
