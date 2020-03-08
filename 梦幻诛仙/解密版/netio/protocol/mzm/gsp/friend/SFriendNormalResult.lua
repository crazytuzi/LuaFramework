local SFriendNormalResult = class("SFriendNormalResult")
SFriendNormalResult.TYPEID = 12587012
SFriendNormalResult.FIND_PLAYER_NOT_FIND = 1
SFriendNormalResult.AGREE_APPLY_FRIEND_MAX = 11
SFriendNormalResult.DEL_FRIEND_SWORN_RELATION = 12
SFriendNormalResult.ROLE_IN_DELETE = 13
SFriendNormalResult.DEL_FRIEND_IN_MARRIAGE = 14
SFriendNormalResult.DEL_FRIEND_IN_SHITU = 15
SFriendNormalResult.DEL_FRIEND_IN_QING_YUAN = 16
SFriendNormalResult.VALIDATE_WORDS_MAX = 21
SFriendNormalResult.LEVEL_NOT_ENOUGH = 22
SFriendNormalResult.HAS_SENSITIVE_WORDS = 23
SFriendNormalResult.TARGET_NOT_FRIEND = 31
SFriendNormalResult.INVALID_REMARK_NAME_LENGTH = 32
SFriendNormalResult.SENSITIVE_WORD_IN_REMARK_NAME = 33
SFriendNormalResult.INVALID_CHARACTER_IN_REMARK_NAME = 34
SFriendNormalResult.CAN_NOT_DO_THIS_IN_CROSS = 200
function SFriendNormalResult:ctor(result, args)
  self.id = 12587012
  self.result = result or nil
  self.args = args or {}
end
function SFriendNormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SFriendNormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SFriendNormalResult:sizepolicy(size)
  return size <= 65535
end
return SFriendNormalResult
