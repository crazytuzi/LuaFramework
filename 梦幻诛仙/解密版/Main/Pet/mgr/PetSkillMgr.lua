local Lplus = require("Lplus")
local PetSkillMgr = Lplus.Class("PetSkillMgr")
local def = PetSkillMgr.define
local PetData = require("Main.Pet.data.PetData")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
local instance
def.const("table").CResult = {Success = 0, HasRememberedSkill = 1}
def.static("=>", PetSkillMgr).Instance = function()
  if instance == nil then
    instance = PetSkillMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("userdata", "number", "table", "=>", "number").RememberSkill = function(self, petId, skillId, extraParams)
  local costType = 0
  if extraParams and extraParams.isYuanBaoBuZu then
    costType = 1
  end
  local ItemModule = require("Main.Item.ItemModule")
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_RememberSkill(petId, skillId, costType, yuanBaoNum)
  return PetSkillMgr.CResult.Success
end
def.method("userdata", "number").UnrememberSkill = function(self, petId, skillId)
  self:C2S_UnrememberSkill(petId, skillId)
end
def.method("userdata", "number").StudySkillBookReq = function(self, petId, itemKey)
  self:C2S_CStudySkillBookReq(petId, itemKey)
end
def.method("userdata", "number").SetSkillRemembered = function(self, petId, skillId)
  local pet = PetMgr.Instance():GetPet(petId)
  pet.rememberedSkillId = skillId
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, {petId})
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REMEMBERED_SKILL_SUCCESS, {skillId = skillId})
end
def.method("userdata", "number").SetSkillUnremembered = function(self, petId, skillId)
  local pet = PetMgr.Instance():GetPet(petId)
  pet.rememberedSkillId = PetData.NOT_SET
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, {petId})
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_UNREMEMBERED_SKILL_SUCCESS, {skillId = skillId})
end
def.method("=>", "table").GetUnrememberSkillCost = function(self)
  local costSilver = PetUtility.Instance():GetPetConstants("PET_UNREMEMBER_SKILL_COST_SILVER")
  return {silver = costSilver}
end
def.method("table", "table", "=>", "table").GetHuaShengPreviewSkillList = function(self, mainPet, subPet)
  local mainOwnSkillIdList = mainPet:GetSkillIdList()
  local subOwnSkillIdList = subPet:GetSkillIdList()
  local mainAmuletSkillIdList = mainPet:GetAmuletSkillIdList()
  local ownSkillList = {}
  local idSet = {}
  for i, v in ipairs(mainOwnSkillIdList) do
    local skill = {id = v}
    if skill.id == mainPet.rememberedSkillId then
      skill.isRemembered = true
    end
    idSet[skill.id] = skill.id
    table.insert(ownSkillList, skill)
  end
  for i, v in ipairs(subOwnSkillIdList) do
    if not idSet[v] and self:CanSkillBeHuaSheng(v) then
      local skill = {id = v}
      table.insert(ownSkillList, skill)
    end
  end
  for i, v in ipairs(mainAmuletSkillIdList) do
    local skill = {id = v, belongAmulet = true}
    table.insert(ownSkillList, skill)
  end
  return ownSkillList
end
def.method("table", "table", "=>", "table").GetHuaShengUnionSkillList = function(self, mainPet, subPet)
  local mainOwnSkillIdList = mainPet:GetSkillIdList()
  local subOwnSkillIdList = subPet:GetSkillIdList()
  local ownSkillList = {}
  local idSet = {}
  for i, v in ipairs(mainOwnSkillIdList) do
    local skill = {id = v}
    if skill.id == mainPet.rememberedSkillId then
      skill.isRemembered = true
    end
    idSet[skill.id] = skill.id
    table.insert(ownSkillList, skill)
  end
  for i, v in ipairs(subOwnSkillIdList) do
    if not idSet[v] and self:CanSkillBeHuaSheng(v) then
      local skill = {id = v}
      table.insert(ownSkillList, skill)
    end
  end
  return ownSkillList
end
def.method("number", "=>", "boolean").CanSkillBeHuaSheng = function(self, skillId)
  local specialSkillCfg = PetUtility.GetPetSpecialSkillCfg(skillId)
  if specialSkillCfg == nil then
    return true
  end
  return specialSkillCfg.canHuaSheng
end
def.method("userdata", "number", "number", "userdata").C2S_RememberSkill = function(self, petId, skillId, costType, yuanBaoNum)
  local p = require("netio.protocol.mzm.gsp.pet.CRemeberSkillReq").new(petId, skillId, costType, yuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_UnrememberSkill = function(self, petId, skillId)
  local p = require("netio.protocol.mzm.gsp.pet.CUnRemeberSkillReq").new(petId, skillId)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_CStudySkillBookReq = function(self, petId, itemKey)
  local PetInterface = require("Main.Pet.Interface")
  local pet = PetInterface.GetPet(petId)
  local p = require("netio.protocol.mzm.gsp.pet.CStudySkillBookReq").new(petId, itemKey)
  gmodule.network.sendProtocol(p)
end
return PetSkillMgr.Commit()
