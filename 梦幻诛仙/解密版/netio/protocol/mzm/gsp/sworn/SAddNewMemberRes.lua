local SAddNewMemberRes = class("SAddNewMemberRes")
SAddNewMemberRes.TYPEID = 12597802
SAddNewMemberRes.SUCCESS = 0
SAddNewMemberRes.ERROR_UNKNOWN = 1
SAddNewMemberRes.ERROR_MAX_SWORN_MEMBER = 2
SAddNewMemberRes.ERROR_SILVER_NOT_ENOUGH = 3
SAddNewMemberRes.ERROR_NOT_TEAM = 4
SAddNewMemberRes.ERROR_NOT_TEAM_LEADER = 5
SAddNewMemberRes.ERROR_TEAM_COUNT = 6
SAddNewMemberRes.ERROR_LEADER_NO_SWORN = 7
SAddNewMemberRes.ERROR_MEMBER_SWORN = 8
SAddNewMemberRes.ERROR_MEMBER_FRIEND = 9
SAddNewMemberRes.ERROR_MEMBER_FRIEND_VALUE = 10
SAddNewMemberRes.ERROR_MEMBER_LEVEL = 11
SAddNewMemberRes.ERROR_VOTEING = 12
SAddNewMemberRes.ERROR_VOTE_NOT_AGREE = 13
function SAddNewMemberRes:ctor(resultcode, args)
  self.id = 12597802
  self.resultcode = resultcode or nil
  self.args = args or {}
end
function SAddNewMemberRes:marshal(os)
  os:marshalInt32(self.resultcode)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SAddNewMemberRes:unmarshal(os)
  self.resultcode = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SAddNewMemberRes:sizepolicy(size)
  return size <= 65535
end
return SAddNewMemberRes
