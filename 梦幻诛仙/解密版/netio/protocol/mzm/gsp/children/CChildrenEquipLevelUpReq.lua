local CChildrenEquipLevelUpReq = class("CChildrenEquipLevelUpReq")
CChildrenEquipLevelUpReq.TYPEID = 12609415
function CChildrenEquipLevelUpReq:ctor(childrenid, pos, item_cfg_id, is_use_all)
  self.id = 12609415
  self.childrenid = childrenid or nil
  self.pos = pos or nil
  self.item_cfg_id = item_cfg_id or nil
  self.is_use_all = is_use_all or nil
end
function CChildrenEquipLevelUpReq:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.pos)
  os:marshalInt32(self.item_cfg_id)
  os:marshalInt32(self.is_use_all)
end
function CChildrenEquipLevelUpReq:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.pos = os:unmarshalInt32()
  self.item_cfg_id = os:unmarshalInt32()
  self.is_use_all = os:unmarshalInt32()
end
function CChildrenEquipLevelUpReq:sizepolicy(size)
  return size <= 65535
end
return CChildrenEquipLevelUpReq
