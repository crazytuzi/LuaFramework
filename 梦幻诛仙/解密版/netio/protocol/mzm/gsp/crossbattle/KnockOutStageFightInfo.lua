local OctetsStream = require("netio.OctetsStream")
local KnockOutStageFightInfo = class("KnockOutStageFightInfo")
function KnockOutStageFightInfo:ctor(fight_info_list)
  self.fight_info_list = fight_info_list or {}
end
function KnockOutStageFightInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.fight_info_list))
  for _, v in ipairs(self.fight_info_list) do
    v:marshal(os)
  end
end
function KnockOutStageFightInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.FightAgainstInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.fight_info_list, v)
  end
end
return KnockOutStageFightInfo
