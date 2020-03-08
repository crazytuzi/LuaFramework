local SFactionPVENormalResult = class("SFactionPVENormalResult")
SFactionPVENormalResult.TYPEID = 12613633
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__SELF_LOW_LEVEL = 1
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__TEAM_LOW_LEVEL = 2
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__NOT_TIME = 3
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__DIFF_FACTION = 4
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__SELF_JUST_JOIN = 5
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__TEAM_JUST_JOIN = 6
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__SELF_PARTICIPATED = 7
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__TEAM_PARTICIPATED = 8
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__SELF_MAX_TIMES = 9
SFactionPVENormalResult.ENTER_FACTIONPVE_MAP__TEAM_MAX_TIMES = 10
SFactionPVENormalResult.LEAVE_FACTIONPVE_MAP__IN_TEAM = 21
SFactionPVENormalResult.LEAVE_FACTIONPVE_MAP__NOT_LEADER = 22
SFactionPVENormalResult.SET_START_TIME__ACTIVITY_TIME = 41
SFactionPVENormalResult.SET_START_TIME__LACK_MONEY = 42
SFactionPVENormalResult.SET_START_TIME__JUST_CREATE = 43
SFactionPVENormalResult.SET_START_TIME__TOO_CLOSE = 44
function SFactionPVENormalResult:ctor(result, args)
  self.id = 12613633
  self.result = result or nil
  self.args = args or {}
end
function SFactionPVENormalResult:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SFactionPVENormalResult:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SFactionPVENormalResult:sizepolicy(size)
  return size <= 65535
end
return SFactionPVENormalResult
