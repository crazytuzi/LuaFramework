local SSyncGangHelp = class("SSyncGangHelp")
SSyncGangHelp.TYPEID = 12589846
SSyncGangHelp.TYPE_HUN = 0
SSyncGangHelp.TYPE_CIRCLETASK = 1
SSyncGangHelp.TYPE_LUNHUIQUESTION = 2
SSyncGangHelp.TYPE_QING_YUN_XUE_TANG_QUESTION = 3
SSyncGangHelp.HUN_ROLE_ID = 10
SSyncGangHelp.HUN_ITEM_ID = 11
SSyncGangHelp.HUN_ITEM_NUM = 12
SSyncGangHelp.HUN_ITEM_SLOT_NUM = 13
SSyncGangHelp.ROLE_ID = 14
SSyncGangHelp.QUESTION_ID = 15
SSyncGangHelp.PAGE_INDEX = 16
SSyncGangHelp.TEAM_ID = 17
SSyncGangHelp.TASK_ID = 18
function SSyncGangHelp:ctor(helperType, paramString, paramLong, paramInt)
  self.id = 12589846
  self.helperType = helperType or nil
  self.paramString = paramString or {}
  self.paramLong = paramLong or {}
  self.paramInt = paramInt or {}
end
function SSyncGangHelp:marshal(os)
  os:marshalInt32(self.helperType)
  do
    local _size_ = 0
    for _, _ in pairs(self.paramString) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.paramString) do
      os:marshalInt32(k)
      os:marshalString(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.paramLong) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.paramLong) do
      os:marshalInt32(k)
      os:marshalInt64(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.paramInt) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.paramInt) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SSyncGangHelp:unmarshal(os)
  self.helperType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalString()
    self.paramString[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt64()
    self.paramLong[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.paramInt[k] = v
  end
end
function SSyncGangHelp:sizepolicy(size)
  return size <= 65535
end
return SSyncGangHelp
