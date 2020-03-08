local OctetsStream = require("netio.OctetsStream")
local AttackResult = class("AttackResult")
function AttackResult:ctor(attackResultBeans)
  self.attackResultBeans = attackResultBeans or {}
end
function AttackResult:marshal(os)
  os:marshalCompactUInt32(table.getn(self.attackResultBeans))
  for _, v in ipairs(self.attackResultBeans) do
    v:marshal(os)
  end
end
function AttackResult:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.fight.AttackResultBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.attackResultBeans, v)
  end
end
return AttackResult
