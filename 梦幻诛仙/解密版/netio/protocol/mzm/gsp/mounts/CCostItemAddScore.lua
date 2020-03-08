local CCostItemAddScore = class("CCostItemAddScore")
CCostItemAddScore.TYPEID = 12606242
function CCostItemAddScore:ctor(add_score_mounts_id, item_id, item_type, is_use_all)
  self.id = 12606242
  self.add_score_mounts_id = add_score_mounts_id or nil
  self.item_id = item_id or nil
  self.item_type = item_type or nil
  self.is_use_all = is_use_all or nil
end
function CCostItemAddScore:marshal(os)
  os:marshalInt64(self.add_score_mounts_id)
  os:marshalInt32(self.item_id)
  os:marshalInt32(self.item_type)
  os:marshalInt32(self.is_use_all)
end
function CCostItemAddScore:unmarshal(os)
  self.add_score_mounts_id = os:unmarshalInt64()
  self.item_id = os:unmarshalInt32()
  self.item_type = os:unmarshalInt32()
  self.is_use_all = os:unmarshalInt32()
end
function CCostItemAddScore:sizepolicy(size)
  return size <= 65535
end
return CCostItemAddScore
