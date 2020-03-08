local SMountsSelectOrnamentSuccess = class("SMountsSelectOrnamentSuccess")
SMountsSelectOrnamentSuccess.TYPEID = 12606249
function SMountsSelectOrnamentSuccess:ctor(mounts_id, select_rank)
  self.id = 12606249
  self.mounts_id = mounts_id or nil
  self.select_rank = select_rank or nil
end
function SMountsSelectOrnamentSuccess:marshal(os)
  os:marshalInt64(self.mounts_id)
  os:marshalInt32(self.select_rank)
end
function SMountsSelectOrnamentSuccess:unmarshal(os)
  self.mounts_id = os:unmarshalInt64()
  self.select_rank = os:unmarshalInt32()
end
function SMountsSelectOrnamentSuccess:sizepolicy(size)
  return size <= 65535
end
return SMountsSelectOrnamentSuccess
