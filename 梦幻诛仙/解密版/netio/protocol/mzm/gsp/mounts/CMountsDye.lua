local CMountsDye = class("CMountsDye")
CMountsDye.TYPEID = 12606214
function CMountsDye:ctor(mounts_id, color_id, is_use_yuan_bao, client_current_yuan_bao, need_yuan_bao)
  self.id = 12606214
  self.mounts_id = mounts_id or nil
  self.color_id = color_id or nil
  self.is_use_yuan_bao = is_use_yuan_bao or nil
  self.client_current_yuan_bao = client_current_yuan_bao or nil
  self.need_yuan_bao = need_yuan_bao or nil
end
function CMountsDye:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.color_id)
  os:marshalInt32(self.is_use_yuan_bao)
  os:marshalInt64(self.client_current_yuan_bao)
  os:marshalInt32(self.need_yuan_bao)
end
function CMountsDye:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.color_id = os:unmarshalInt32()
  self.is_use_yuan_bao = os:unmarshalInt32()
  self.client_current_yuan_bao = os:unmarshalInt64()
  self.need_yuan_bao = os:unmarshalInt32()
end
function CMountsDye:sizepolicy(size)
  return size <= 65535
end
return CMountsDye
