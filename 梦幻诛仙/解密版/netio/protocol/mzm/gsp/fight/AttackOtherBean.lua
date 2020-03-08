local OctetsStream = require("netio.OctetsStream")
local AttackOtherBeanResult = require("netio.protocol.mzm.gsp.fight.AttackOtherBeanResult")
local InfluenceOther = require("netio.protocol.mzm.gsp.fight.InfluenceOther")
local Protect = require("netio.protocol.mzm.gsp.fight.Protect")
local AttackOtherBean = class("AttackOtherBean")
function AttackOtherBean:ctor(targetid, attackInnerBean, influenceOthers, protect)
  self.targetid = targetid or nil
  self.attackInnerBean = attackInnerBean or AttackOtherBeanResult.new()
  self.influenceOthers = influenceOthers or InfluenceOther.new()
  self.protect = protect or Protect.new()
end
function AttackOtherBean:marshal(os)
  os:marshalInt32(self.targetid)
  self.attackInnerBean:marshal(os)
  self.influenceOthers:marshal(os)
  self.protect:marshal(os)
end
function AttackOtherBean:unmarshal(os)
  self.targetid = os:unmarshalInt32()
  self.attackInnerBean = AttackOtherBeanResult.new()
  self.attackInnerBean:unmarshal(os)
  self.influenceOthers = InfluenceOther.new()
  self.influenceOthers:unmarshal(os)
  self.protect = Protect.new()
  self.protect:unmarshal(os)
end
return AttackOtherBean
