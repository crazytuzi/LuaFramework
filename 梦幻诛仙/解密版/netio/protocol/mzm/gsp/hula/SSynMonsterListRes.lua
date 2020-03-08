local SSynMonsterListRes = class("SSynMonsterListRes")
SSynMonsterListRes.TYPEID = 12608783
function SSynMonsterListRes:ctor(monsterlist, maxseq, turn, stage, point)
  self.id = 12608783
  self.monsterlist = monsterlist or {}
  self.maxseq = maxseq or nil
  self.turn = turn or nil
  self.stage = stage or nil
  self.point = point or nil
end
function SSynMonsterListRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.monsterlist))
  for _, v in ipairs(self.monsterlist) do
    v:marshal(os)
  end
  os:marshalInt32(self.maxseq)
  os:marshalInt32(self.turn)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.point)
end
function SSynMonsterListRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.hula.MonsterInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.monsterlist, v)
  end
  self.maxseq = os:unmarshalInt32()
  self.turn = os:unmarshalInt32()
  self.stage = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
end
function SSynMonsterListRes:sizepolicy(size)
  return size <= 65535
end
return SSynMonsterListRes
