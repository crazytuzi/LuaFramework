local SSavePlanFailed = class("SSavePlanFailed")
SSavePlanFailed.TYPEID = 12613891
SSavePlanFailed.ERROR_POINT_NOT_ENOUGH = -1
function SSavePlanFailed:ctor(genius_series_id, genius_skills, retcode)
  self.id = 12613891
  self.genius_series_id = genius_series_id or nil
  self.genius_skills = genius_skills or {}
  self.retcode = retcode or nil
end
function SSavePlanFailed:marshal(os)
  os:marshalInt32(self.genius_series_id)
  do
    local _size_ = 0
    for _, _ in pairs(self.genius_skills) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.genius_skills) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  os:marshalInt32(self.retcode)
end
function SSavePlanFailed:unmarshal(os)
  self.genius_series_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.genius_skills[k] = v
  end
  self.retcode = os:unmarshalInt32()
end
function SSavePlanFailed:sizepolicy(size)
  return size <= 65535
end
return SSavePlanFailed
