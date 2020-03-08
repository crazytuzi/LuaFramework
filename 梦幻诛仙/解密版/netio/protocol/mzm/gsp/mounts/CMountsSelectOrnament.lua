local CMountsSelectOrnament = class("CMountsSelectOrnament")
CMountsSelectOrnament.TYPEID = 12606248
function CMountsSelectOrnament:ctor(mounts_id, select_rank)
  self.id = 12606248
  self.mounts_id = mounts_id or nil
  self.select_rank = select_rank or nil
end
function CMountsSelectOrnament:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.select_rank)
end
function CMountsSelectOrnament:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.select_rank = os:unmarshalInt32()
end
function CMountsSelectOrnament:sizepolicy(size)
  return size <= 65535
end
return CMountsSelectOrnament
