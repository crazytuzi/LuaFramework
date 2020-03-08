local EquipCondition = require("netio.protocol.mzm.gsp.market.EquipCondition")
local CAddEquipConditionReq = class("CAddEquipConditionReq")
CAddEquipConditionReq.TYPEID = 12601408
function CAddEquipConditionReq:ctor(condition)
  self.id = 12601408
  self.condition = condition or EquipCondition.new()
end
function CAddEquipConditionReq:marshal(os)
  self.condition:marshal(os)
end
function CAddEquipConditionReq:unmarshal(os)
  self.condition = EquipCondition.new()
  self.condition:unmarshal(os)
end
function CAddEquipConditionReq:sizepolicy(size)
  return size <= 65535
end
return CAddEquipConditionReq
