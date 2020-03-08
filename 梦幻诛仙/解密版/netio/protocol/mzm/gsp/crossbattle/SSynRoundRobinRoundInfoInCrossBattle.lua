local SSynRoundRobinRoundInfoInCrossBattle = class("SSynRoundRobinRoundInfoInCrossBattle")
SSynRoundRobinRoundInfoInCrossBattle.TYPEID = 12616975
function SSynRoundRobinRoundInfoInCrossBattle:ctor(activity_cfg_id, index, stage, fight_infos)
  self.id = 12616975
  self.activity_cfg_id = activity_cfg_id or nil
  self.index = index or nil
  self.stage = stage or nil
  self.fight_infos = fight_infos or {}
end
function SSynRoundRobinRoundInfoInCrossBattle:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.index)
  os:marshalInt32(self.stage)
  os:marshalCompactUInt32(table.getn(self.fight_infos))
  for _, v in ipairs(self.fight_infos) do
    v:marshal(os)
  end
end
function SSynRoundRobinRoundInfoInCrossBattle:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.crossbattle.RoundRobinFightInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.fight_infos, v)
  end
end
function SSynRoundRobinRoundInfoInCrossBattle:sizepolicy(size)
  return size <= 65535
end
return SSynRoundRobinRoundInfoInCrossBattle
