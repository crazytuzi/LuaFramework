local OctetsStream = require("netio.OctetsStream")
local Buff = class("Buff")
Buff.DATA_CHANGE_MODEL_CARD = -1
Buff.LIFE_LINK_START = -10
Buff.LIFE_LINK_END = -29
Buff.BLACK_HOLE_START = -30
Buff.BLACK_HOLE_END = -49
Buff.MIRROR_FIGHTER_ID = -60
Buff.SYN_SKILL_KEY = -61
Buff.FIGHT_STATE_GROUP_START = -100
Buff.FIGHT_STATE_GROUP_END = -199
Buff.FIGHT_STATE_START = -300
Buff.FIGHT_STATE_END = -399
function Buff:ctor(buffid, round)
  self.buffid = buffid or nil
  self.round = round or nil
end
function Buff:marshal(os)
  os:marshalInt32(self.buffid)
  os:marshalInt32(self.round)
end
function Buff:unmarshal(os)
  self.buffid = os:unmarshalInt32()
  self.round = os:unmarshalInt32()
end
return Buff
