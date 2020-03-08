local OctetsStream = require("netio.OctetsStream")
local AllMoveSteps = class("AllMoveSteps")
function AllMoveSteps:ctor(steps)
  self.steps = steps or {}
end
function AllMoveSteps:marshal(os)
  os:marshalCompactUInt32(table.getn(self.steps))
  for _, v in ipairs(self.steps) do
    v:marshal(os)
  end
end
function AllMoveSteps:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.question.MoveStep")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.steps, v)
  end
end
return AllMoveSteps
