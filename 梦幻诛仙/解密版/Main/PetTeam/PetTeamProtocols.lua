local Lplus = require("Lplus")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local PetTeamProtocols = Lplus.Class("PetTeamProtocols")
local def = PetTeamProtocols.define
def.static().RegisterProtocols = function()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncPetFightInformation", PetTeamProtocols.OnSSyncPetFightInformation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncPetFightPosition", PetTeamProtocols.OnSSyncPetFightPosition)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SSyncPetFightSkill", PetTeamProtocols.OnSSyncPetFightSkill)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightSetPositionSuccess", PetTeamProtocols.OnSPetFightSetPositionSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightSetPositionFail", PetTeamProtocols.OnSPetFightSetPositionFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightSetDefenseTeamSuccess", PetTeamProtocols.OnSPetFightSetDefenseTeamSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightSetDefenseTeamFail", PetTeamProtocols.OnSPetFightSetDefenseTeamFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightSetTeamFormationSuccess", PetTeamProtocols.OnSPetFightSetTeamFormationSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightSetTeamFormationFail", PetTeamProtocols.OnSPetFightSetTeamFormationFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightImproveFormationSuccess", PetTeamProtocols.OnSPetFightImproveFormationSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightImproveFormationFail", PetTeamProtocols.OnSPetFightImproveFormationFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightSetSkillSuccess", PetTeamProtocols.OnSPetFightSetSkillSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightSetSkillFail", PetTeamProtocols.OnSPetFightSetSkillFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightUnlockSkillSuccess", PetTeamProtocols.OnSPetFightUnlockSkillSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.pet.SPetFightUnlockSkillFail", PetTeamProtocols.OnSPetFightUnlockSkillFail)
end
def.static("table").OnSSyncPetFightInformation = function(p)
  warn("[PetTeamProtocols:OnSSyncPetFightInformation] On SSyncPetFightInformation.")
  PetTeamData.Instance():OnSSyncPetFightInformation(p)
end
def.static("table").OnSSyncPetFightPosition = function(p)
  warn("[PetTeamProtocols:OnSSyncPetFightPosition] On SSyncPetFightPosition.")
  PetTeamData.Instance():OnSSyncPetFightPosition(p)
end
def.static("table").OnSSyncPetFightSkill = function(p)
  warn("[PetTeamProtocols:OnSSyncPetFightSkill] On SSyncPetFightSkill.")
  PetTeamData.Instance():OnSSyncPetFightSkill(p)
end
def.static("number", "table").SendCPetFightSetPositionReq = function(teamIdx, pos2PetMap)
  warn("[PetTeamProtocols:SendCPetFightSetPositionReq] Send CPetFightSetPositionReq:", teamIdx)
  local p = require("netio.protocol.mzm.gsp.pet.CPetFightSetPositionReq").new(teamIdx, pos2PetMap)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetFightSetPositionSuccess = function(p)
  warn("[PetTeamProtocols:OnSPetFightSetPositionSuccess] On SPetFightSetPositionSuccess:", p.team)
  PetTeamData.Instance():UpdateTeamPos(p.team, p.position2pet, true)
  Toast(textRes.PetTeam.DEPLOY_SUCCESS)
end
def.static("table").OnSPetFightSetPositionFail = function(p)
  warn("[PetTeamProtocols:OnSPetFightSetPositionFail] On SPetFightSetPositionFail! p.reason:", p.reason)
  local errString = textRes.PetTeam.SPetFightSetPositionFail[p.reason]
  if errString then
    Toast(errString)
  end
  local PetTeamPanel = require("Main.PetTeam.ui.PetTeamPanel")
  if PetTeamPanel.Instance():IsShow() then
    PetTeamPanel.Instance():OnSPetFightSetPositionFail(p)
  end
end
def.static("number").SendCPetFightSetDefenseTeamReq = function(teamIdx)
  warn("[PetTeamProtocols:SendCPetFightSetDefenseTeamReq] Send CPetFightSetDefenseTeamReq:", teamIdx)
  local p = require("netio.protocol.mzm.gsp.pet.CPetFightSetDefenseTeamReq").new(teamIdx)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetFightSetDefenseTeamSuccess = function(p)
  warn("[PetTeamProtocols:OnSPetFightSetDefenseTeamSuccess] On SPetFightSetDefenseTeamSuccess:", p.team)
  PetTeamData.Instance():SetDefTeamIdx(p.team)
  Toast(textRes.PetTeam.SET_DEFENSE_TEAM_SUCESS)
end
def.static("table").OnSPetFightSetDefenseTeamFail = function(p)
  warn("[PetTeamProtocols:OnSPetFightSetDefenseTeamFail] On SPetFightSetDefenseTeamFail! p.reason:", p.reason)
  local errString = textRes.PetTeam.SPetFightSetDefenseTeamFail[p.reason]
  if errString then
    Toast(errString)
  end
  local PetTeamPanel = require("Main.PetTeam.ui.PetTeamPanel")
  if PetTeamPanel.Instance():IsShow() then
    PetTeamPanel.Instance():OnSPetFightSetDefenseTeamFail(p)
  end
end
def.static("number", "number").SendCPetFightSetTeamFormationReq = function(teamIdx, formationId)
  warn("[PetTeamProtocols:SendCPetFightSetTeamFormationReq] Send CPetFightSetTeamFormationReq:", teamIdx, formationId)
  local p = require("netio.protocol.mzm.gsp.pet.CPetFightSetTeamFormationReq").new(teamIdx, formationId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetFightSetTeamFormationSuccess = function(p)
  warn("[PetTeamProtocols:OnSPetFightSetTeamFormationSuccess] On SPetFightSetTeamFormationSuccess:", p.team, p.formation_id)
  local petTeamInfo = PetTeamData.Instance():GetTeamInfo(p.team)
  if p.formation_id ~= constant.CPetFightConsts.DEFAULT_FORMATION_ID or petTeamInfo and petTeamInfo.formationId ~= p.formation_id then
    Toast(textRes.PetTeam.FORMATION_APPLY_SUCESS)
  end
  PetTeamData.Instance():SetTeamFormation(p.team, p.formation_id, true)
end
def.static("table").OnSPetFightSetTeamFormationFail = function(p)
  warn("[PetTeamProtocols:OnSPetFightSetTeamFormationFail] On SPetFightSetTeamFormationFail! p.reason:", p.reason)
  local errString = textRes.PetTeam.SPetFightSetTeamFormationFail[p.reason]
  if errString then
    Toast(errString)
  end
  local PetTeamPanel = require("Main.PetTeam.ui.PetTeamPanel")
  if PetTeamPanel.Instance():IsShow() then
    PetTeamPanel.Instance():OnSPetFightSetTeamFormationFail(p)
  end
end
def.static("number", "userdata", "number").SendCPetFightImproveFormationReq = function(formationId, itemUuid, useAll)
  warn("[PetTeamProtocols:SendCPetFightImproveFormationReq] Send CPetFightImproveFormationReq:", formationId, itemUuid and Int64.tostring(itemUuid), useAll)
  local p = require("netio.protocol.mzm.gsp.pet.CPetFightImproveFormationReq").new(formationId, itemUuid, useAll)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetFightImproveFormationSuccess = function(p)
  warn("[PetTeamProtocols:OnSPetFightImproveFormationSuccess] On SPetFightImproveFormationSuccess:", p.formation_id, p.level, p.exp)
  local preLevel = PetTeamData.Instance():GetFormationLevel(p.formation_id)
  local preExp = PetTeamData.Instance():GetFormationExp(p.formation_id)
  PetTeamData.Instance():UpdateFormation(p.formation_id, p.level, p.exp, true)
  local formationCfg = PetTeamData.Instance():GetFormationCfg(p.formation_id)
  if nil == formationCfg then
    warn("[ERROR][PetTeamProtocols:OnSPetFightImproveFormationSuccess] formationCfg nil for:", p.formation_id)
    return
  end
  if 0 == preLevel and p.level > 0 then
    Toast(string.format(textRes.PetTeam.FORMATION_LEARN_SUCESS, formationCfg.name or ""))
  elseif p.level ~= preLevel then
    Toast(string.format(textRes.PetTeam.FORMATION_LEVEL_UP, formationCfg.name or "", p.level))
  else
    local diff = math.max(0, p.exp - preExp)
    Toast(string.format(textRes.PetTeam.FORMATION_EXP_UP, formationCfg.name or "", diff))
  end
end
def.static("table").OnSPetFightImproveFormationFail = function(p)
  warn("[PetTeamProtocols:OnSPetFightImproveFormationFail] On SPetFightImproveFormationFail! p.reason:", p.reason)
  local errString = textRes.PetTeam.SPetFightImproveFormationFail[p.reason]
  if errString then
    Toast(errString)
  end
end
def.static("userdata", "number").SendCPetFightSetSkillReq = function(petId, skillId)
  warn("[PetTeamProtocols:SendCPetFightSetSkillReq] Send CPetFightSetSkillReq:", petId and Int64.tostring(petId), skillId)
  local p = require("netio.protocol.mzm.gsp.pet.CPetFightSetSkillReq").new(petId, skillId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetFightSetSkillSuccess = function(p)
  warn("[PetTeamProtocols:OnSPetFightSetSkillSuccess] On SPetFightSetSkillSuccess:", p.pet_id and Int64.tostring(p.pet_id), p.skill_id)
  PetTeamData.Instance():SetPetSkill(p.pet_id, p.skill_id, true)
  Toast(textRes.PetTeam.SKILL_USE_SUCCESS)
end
def.static("table").OnSPetFightSetSkillFail = function(p)
  warn("[PetTeamProtocols:OnSPetFightSetSkillFail] On SPetFightSetSkillFail! p.reason:", p.reason)
  local errString = textRes.PetTeam.SPetFightSetSkillFail[p.reason]
  if errString then
    Toast(errString)
  end
end
def.static("number").SendCPetFightUnlockSkillReq = function(skillId)
  warn("[PetTeamProtocols:SendCPetFightUnlockSkillReq] Send CPetFightUnlockSkillReq:", skillId)
  local p = require("netio.protocol.mzm.gsp.pet.CPetFightUnlockSkillReq").new(skillId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSPetFightUnlockSkillSuccess = function(p)
  warn("[PetTeamProtocols:OnSPetFightUnlockSkillSuccess] On SPetFightUnlockSkillSuccess:", p.skill_id)
  PetTeamData.Instance():SetSkillUnlock(p.skill_id, true, true)
  Toast(textRes.PetTeam.SKILL_UNLOCK_SUCCESS)
end
def.static("table").OnSPetFightUnlockSkillFail = function(p)
  warn("[PetTeamProtocols:OnSPetFightUnlockSkillFail] On SPetFightUnlockSkillFail! p.reason:", p.reason)
  local errString = textRes.PetTeam.SPetFightUnlockSkillFail[p.reason]
  if errString then
    Toast(errString)
  end
end
PetTeamProtocols.Commit()
return PetTeamProtocols
