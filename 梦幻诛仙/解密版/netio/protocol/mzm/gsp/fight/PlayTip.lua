local OctetsStream = require("netio.OctetsStream")
local PlayTip = class("PlayTip")
PlayTip.SKILL_TARGET_NOT_SUIT = 121000003
PlayTip.REST_STATUS = 121000004
PlayTip.WEAK_STATUS = 121000005
PlayTip.CAPTURE_LEVEL_NOT_ENOUGH = 121000007
PlayTip.TARGET_NOT_SUIT = 121000012
PlayTip.PET_BAG_FULL = 121000013
PlayTip.SEAL_STATUS = 121000019
PlayTip.STONE_STATUS = 121000020
PlayTip.SLEEP_STATUS = 121000021
PlayTip.INVISIABLE_STATUS = 121000022
PlayTip.ICE_STATUS = 121000014
PlayTip.CHILD_MESS_STATUS = 121000015
PlayTip.NEED_HP_RATE_HIGHER = 121000023
PlayTip.NEED_HP_RATE_LOWER = 121000024
PlayTip.NEED_MP_RATE_HIGHER = 121000025
PlayTip.NEED_MP_RATE_LOWER = 121000026
PlayTip.COST_HP_LOWER = 121000027
PlayTip.COST_HP_RATE_LOWER = 121000028
PlayTip.COST_MP_LOWER = 121000029
PlayTip.COST_MP_RATE_LOWER = 121000030
PlayTip.COST_ANGER_LOWER = 121000031
PlayTip.COST_ANGER_RATE_LOWER = 121000032
PlayTip.SEAL_TARGET_TO_MAX = 121000033
PlayTip.DRAG_NOT_EXIST = 121000034
PlayTip.SUMMON_CHILD_NOT_IN_BAG = 121000035
function PlayTip:ctor(fighterid, ret, args)
  self.fighterid = fighterid or nil
  self.ret = ret or nil
  self.args = args or {}
end
function PlayTip:marshal(os)
  os:marshalInt32(self.fighterid)
  os:marshalInt32(self.ret)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function PlayTip:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.ret = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
return PlayTip
