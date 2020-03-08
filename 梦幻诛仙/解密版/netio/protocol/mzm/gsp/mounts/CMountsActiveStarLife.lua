local CMountsActiveStarLife = class("CMountsActiveStarLife")
CMountsActiveStarLife.TYPEID = 12606224
function CMountsActiveStarLife:ctor(mounts_id, is_use_yuan_bao, client_current_yuan_bao, need_yuan_bao)
  self.id = 12606224
  self.mounts_id = mounts_id or nil
  self.is_use_yuan_bao = is_use_yuan_bao or nil
  self.client_current_yuan_bao = client_current_yuan_bao or nil
  self.need_yuan_bao = need_yuan_bao or nil
end
function CMountsActiveStarLife:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.is_use_yuan_bao)
  os:marshalInt64(self.client_current_yuan_bao)
  os:marshalInt32(self.need_yuan_bao)
end
function CMountsActiveStarLife:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.is_use_yuan_bao = os:unmarshalInt32()
  self.client_current_yuan_bao = os:unmarshalInt64()
  self.need_yuan_bao = os:unmarshalInt32()
end
function CMountsActiveStarLife:sizepolicy(size)
  return size <= 65535
end
return CMountsActiveStarLife
