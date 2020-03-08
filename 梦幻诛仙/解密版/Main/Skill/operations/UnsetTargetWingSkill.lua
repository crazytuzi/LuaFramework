local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = import(".OperationBase")
local UnsertTargetWingSkill = Lplus.Extend(OperationBase, CUR_CLASS_NAME)
local def = UnsertTargetWingSkill.define
def.override("table", "=>", "boolean").CanDispaly = function(self, context)
  if context == nil or not context.wingSkillId then
    return false
  end
  if context.bHaveSkill or not context.bHasSetted then
    return false
  end
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Wing[48]
end
def.override("table", "=>", "boolean").Operate = function(self, context)
  local WingModule = require("Main.Wing.WingModule")
  if not WingModule.IsSetTargetSkillFeatureOpen() then
    warn(">>>>SetTargetSkillFeature closed<<<<")
    return
  end
  warn(">>>>Send CUnsetTargetSkillReq<<<<")
  local p = require("netio.protocol.mzm.gsp.wing.CUnsetTargetSkillReq").new(context.wingId, context.targetPosIdx)
  gmodule.network.sendProtocol(p)
  return true
end
return UnsertTargetWingSkill.Commit()
