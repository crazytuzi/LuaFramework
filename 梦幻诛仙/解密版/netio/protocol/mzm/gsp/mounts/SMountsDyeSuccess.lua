local SMountsDyeSuccess = class("SMountsDyeSuccess")
SMountsDyeSuccess.TYPEID = 12606235
function SMountsDyeSuccess:ctor(mounts_id, color_id)
  self.id = 12606235
  self.mounts_id = mounts_id or nil
  self.color_id = color_id or nil
end
function SMountsDyeSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.color_id)
end
function SMountsDyeSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.color_id = os:unmarshalInt32()
end
function SMountsDyeSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsDyeSuccess
