local SCommitItemSuccess = class("SCommitItemSuccess")
SCommitItemSuccess.TYPEID = 12594433
function SCommitItemSuccess:ctor(activity_cfg_id, commit_num, itemid2commit_num)
  self.id = 12594433
  self.activity_cfg_id = activity_cfg_id or nil
  self.commit_num = commit_num or nil
  self.itemid2commit_num = itemid2commit_num or {}
end
function SCommitItemSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.commit_num)
  local _size_ = 0
  for _, _ in pairs(self.itemid2commit_num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.itemid2commit_num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SCommitItemSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.commit_num = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemid2commit_num[k] = v
  end
end
function SCommitItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SCommitItemSuccess
