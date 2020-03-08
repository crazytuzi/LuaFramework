local Lplus = require("Lplus")
local PetInterface = Lplus.Class("PetInterface")
local def = PetInterface.define
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetData = Lplus.ForwardDeclare("PetData")
def.static("=>", "table").GetPetList = function()
  return PetMgr.Instance().petList
end
def.static("=>", "number").GetPetNum = function()
  return PetMgr.Instance().petNum
end
def.static("userdata", "=>", PetData).GetPet = function(petId)
  if PetMgr.Instance().petList == nil then
    return nil
  end
  return PetMgr.Instance():GetPet(petId)
end
def.static("=>", PetData).GetFightingPet = function()
  return PetMgr.Instance():GetFightingPet()
end
def.static("=>", PetData).GetInFightScenePet = function()
  return PetMgr.Instance():GetInFightScenePet()
end
def.static("=>", PetData).GetDisplayPet = function()
  return PetMgr.Instance():GetDisplayPet()
end
def.static("number", "=>", "table").GetPetsByTypeId = function(typeId)
  return PetMgr.Instance():GetPetsByTypeId(typeId)
end
def.static("number", "=>", "table").GetMonsterCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_MONSTER_CFG, id)
  if record == nil then
    warn("GetMonsterCfg got nil record for monsterID: ", id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.monsterId = record:GetIntValue("monsterId")
  cfg.monsterModelId = record:GetIntValue("monsterModelId")
  cfg.name = record:GetStringValue("name")
  cfg.modelFigureId = record:GetIntValue("modelFigureId")
  cfg.catchedMonsterId = record:GetIntValue("catchedMonsterId")
  cfg.colorId = record:GetIntValue("modelColorId")
  return cfg
end
def.static("number", "=>", "table").GetExplicitMonsterCfg = function(monsterID)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_BRIGHTMONSTER_CFG, monsterID)
  if record == nil then
    print("** GetExplicitMonsterCfg(", monsterID, ") record == nil")
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.enterFightLevelType = record:GetIntValue("enterFightLevelType")
  cfg.enterFightMinRoleNum = record:GetIntValue("enterFightMinRoleNum")
  cfg.enterFightMaxRoleNum = record:GetIntValue("enterFightMaxRoleNum")
  cfg.enterFightMinLevel = record:GetIntValue("enterFightMinLevel")
  cfg.enterFightMaxLevel = record:GetIntValue("enterFightMaxLevel")
  cfg.maxlevelReviseLimit = record:GetIntValue("maxlevelReviseLimit")
  cfg.minlevelReviseLimit = record:GetIntValue("minlevelReviseLimit")
  cfg.monsterFightTableId = record:GetIntValue("monsterFightTableId")
  cfg.modelId = record:GetIntValue("monsterModelTableId")
  cfg.name = record:GetStringValue("name")
  cfg.title = record:GetStringValue("title")
  cfg.isInAir = record:GetCharValue("isInAir") ~= 0
  cfg.attackOptionTalk = record:GetStringValue("attackOptionTalk")
  cfg.notAttackOptionTalk = record:GetStringValue("notAttackOptionTalk")
  cfg.canNotAttackOptionTalk = record:GetStringValue("canNotAttackOptionTalk")
  cfg.talk = record:GetStringValue("talk")
  cfg.templatename = record:GetStringValue("templatename")
  cfg.modelColorId = record:GetIntValue("modelColorId")
  cfg.modelFigureId = record:GetIntValue("modelFigureId")
  cfg.vanishType = record:GetIntValue("vanishType")
  local struct = record:GetStructValue("autoTalkListStruct")
  if struct then
    cfg.autoTalkList = {}
    local count = struct:GetVectorSize("autoTalkList")
    for i = 1, count do
      local rec = struct:GetVectorValueByIdx("autoTalkList", i - 1)
      local talkstr = rec:GetStringValue("autoTalk")
      table.insert(cfg.autoTalkList, talkstr)
    end
  end
  return cfg
end
return PetInterface.Commit()
