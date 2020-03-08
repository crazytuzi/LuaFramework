local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = import(".OperationBase")
local SetGoalWingSkill = Lplus.Extend(OperationBase, CUR_CLASS_NAME)
local def = SetGoalWingSkill.define
def.override("table", "=>", "boolean").CanDispaly = function(self, context)
  if context == nil or not context.wingSkillId then
    return false
  end
  if context.bHaveSkill or context.bHasSetted then
    return false
  end
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Wing[45]
end
def.override("table", "=>", "boolean").Operate = function(self, context)
  local WingModule = require("Main.Wing.WingModule")
  if not WingModule.IsSetTargetSkillFeatureOpen() then
    warn(">>>>SetTargetSkillFeature closed<<<<")
    return
  end
  warn(">>>>Send CSetTargetSkillReq<<<<")
  local p = require("netio.protocol.mzm.gsp.wing.CSetTargetSkillReq").new(context.wingId, context.targetPosIdx, context.wingSkillId)
  warn(">>>>wingId = " .. context.wingId .. " index = " .. context.targetPosIdx .. " wingSkillId = " .. context.wingSkillId)
  gmodule.network.sendProtocol(p)
  return true
end
return SetGoalWingSkill.Commit()
