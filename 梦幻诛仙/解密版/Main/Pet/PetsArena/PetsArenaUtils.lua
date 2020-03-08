local FILE_NAME = (...)
local Lplus = require("Lplus")
local PetsArenaUtils = Lplus.Class(FILE_NAME)
local def = PetsArenaUtils.define
local Cls = PetsArenaUtils
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local PetTeamUtils = require("Main.PetTeam.PetTeamUtils")
local GUIUtils = require("GUI.GUIUtils")
def.static("=>", "table").LoadAllAwardCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_PETSARENA_AWARDCFG)
  if entries == nil then
    warn("[ERROR: Could not find file DATA_PETSARENA_AWARDCFG]")
    return nil
  end
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local retData = {}
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local data = Cls.readRecord(record)
    if data then
      table.insert(retData, data)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return retData
end
def.static("userdata", "=>", "table").readRecord = function(record)
  if record == nil then
    warn("[ERROR: record is nil]")
    return nil
  end
  local data = {}
  data.id = record:GetIntValue("id")
  data.minRank = record:GetIntValue("minRank")
  data.maxRank = record:GetIntValue("maxRank")
  data.award = record:GetIntValue("award")
  return data
end
def.static("table", "table", "userdata", "table").showFormationInfo = function(formationCfg, teamInfo, texture, ctrlGrid)
  if teamInfo == nil then
    warn("[WARN:] teamInfo is nil")
  end
  if ctrlGrid == nil then
    warn("[ERROR] Formation grid control is nil")
    return
  end
  local formationId = teamInfo and teamInfo.formationId or 0
  local formationLv = PetTeamData.Instance():GetFormationLevel(formationId)
  if formationCfg == nil then
    formationCfg = PetTeamData.Instance():GetFormationCfg(formationId)
  end
  if formationCfg == nil then
    warn("[WARN:] Show formation failed! formationCfg is nil")
    if texture ~= nil then
      texture:SetActive(false)
    end
    return
  end
  for idx, grid in ipairs(ctrlGrid) do
    if not _G.IsNil(grid) then
      local imgDisact = grid:FindDirect("Img_DisAct")
      local imgAct = grid:FindDirect("Img_Act")
      local imgSite = grid:FindDirect("Img_Site")
      local pos = formationCfg.idx2PosMap[idx]
      if pos and pos > 0 and pos <= constant.CPetFightConsts.MAX_POSITION_NUMBER then
        imgSite:SetActive(true)
        GUIUtils.SetSprite(imgSite, "Img_Team" .. pos)
        local bActive = true
        imgDisact:SetActive(not bActive)
        imgAct:SetActive(bActive)
      else
        imgDisact:SetActive(true)
        imgAct:SetActive(false)
        imgSite:SetActive(false)
      end
    end
  end
  if texture == nil then
    warn("[WARN:] texture is nil")
    return
  end
  texture:SetActive(true)
  GUIUtils.SetTexture(texture, formationCfg.iconId)
end
def.static("table", "table", "userdata", "table").ShowFormationAtts = function(teamInfo, lblAttrList, lblFormatioName, extraInfo)
  if teamInfo == nil or lblAttrList == nil then
    return
  end
  local formationId = teamInfo and teamInfo.formationId or 0
  local formationLv = 0
  if extraInfo ~= nil then
    formationLv = extraInfo.formationLv
  else
    formationLv = PetTeamData.Instance():GetFormationLevel(formationId)
  end
  local formationCfg = PetTeamData.Instance():GetFormationCfg(formationId)
  if formationCfg == nil then
    warn("[WARN:] Show formation failed! formationCfg is nil")
    return
  end
  if not _G.IsNil(lblFormatioName) then
    local formName = formationCfg.name
    if formationLv > 0 then
      formName = string.format(textRes.PetTeam.FORMATION_LEVEL, formationLv) .. formName
    end
    GUIUtils.SetText(lblFormatioName, formName)
  end
  local lvCfg = PetTeamData.Instance():GetLevelCfg(formationId, formationLv)
  if lvCfg == nil then
  end
  for pos = 1, constant.CPetFightConsts.MAX_POSITION_NUMBER do
    local Group_Att = lblAttrList[pos]
    if Group_Att == nil then
      break
    end
    local attrs = lvCfg and lvCfg.posAttrs[pos]
    local uiSpriteSortNum = Group_Att:FindDirect("Img_Site")
    GUIUtils.SetSprite(uiSpriteSortNum, pos)
    local lblAttrs = Group_Att:FindDirect("Label_Att01")
    local strAttrs = ""
    for idx = 1, 2 do
      local attrCfg = attrs and attrs[idx]
      local str = attrCfg and PetTeamUtils.GetAttrString(attrCfg) or ""
      if str and str ~= "" then
        if strAttrs == "" or strAttrs == nil then
          strAttrs = str
        else
          strAttrs = strAttrs .. "\n" .. str
        end
      end
    end
    GUIUtils.SetText(lblAttrs, strAttrs)
  end
end
local ECPanelBase = require("GUI.ECPanelBase")
local PetTeamInfo = require("Main.PetTeam.data.PetTeamInfo")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
def.static(ECPanelBase, "=>", "boolean").CheckPanelOnShow = function(panel)
  if _G.IsNil(panel) or not panel:IsShow() then
    return false
  else
    return true
  end
end
def.static(ECPanelBase, PetTeamInfo, "table", "userdata", "table", "number", "function", "table").ShowTeam = function(panel, petTeamInfo, formationGrid, labelTeamScore, pet2ModelMap, modelId, funcQuery, extraInfo)
  if labelTeamScore then
    GUIUtils.SetText(labelTeamScore, textRes.Pet.PetsArena[27])
  end
  if not Cls.CheckPanelOnShow(panel) then
    warn("[ERROR][PetsArenaUtils:ShowTeam] show pet team failed! panel not show.")
    return
  end
  if nil == petTeamInfo then
    warn("[ERROR][PetsArenaUtils:ShowTeam] show pet team failed! petTeamInfo nil.")
    return
  end
  if nil == formationGrid then
    warn("[ERROR][PetsArenaUtils:ShowTeam] show pet team failed! formationGrid nil.")
    return
  end
  if nil == pet2ModelMap then
    warn("[ERROR][PetsArenaUtils:ShowTeam] show pet team failed! pet2ModelMap nil.")
    return
  end
  local formationCfg = PetTeamData.Instance():GetFormationCfg(petTeamInfo.formationId)
  if nil == formationCfg then
    warn("[ERROR][PetsArenaUtils:ShowTeam] show pet team failed! formationCfg nil for petTeamInfo.formationId:", petTeamInfo.formationId)
    return
  end
  if funcQuery == nil then
    function funcQuery(petId)
      return PetMgr.Instance():GetPet(petId)
    end
  end
  local iTeamScore = 0
  for idx, grid in ipairs(formationGrid) do
    local petYaoli = Cls.ShowPet(panel, idx, petTeamInfo, formationCfg, formationGrid, pet2ModelMap, modelId, funcQuery, extraInfo)
    iTeamScore = iTeamScore + petYaoli
  end
  if labelTeamScore then
    GUIUtils.SetText(labelTeamScore, iTeamScore)
  end
  local destroyList = {}
  for petKey, petUIModel in pairs(pet2ModelMap) do
    if 0 >= petTeamInfo:GetPetPos(Int64.new(petKey)) then
      table.insert(destroyList, petKey)
    end
  end
  if #destroyList > 0 then
    for _, petKey in ipairs(destroyList) do
      local petUIModel = pet2ModelMap[petKey]
      if not _G.IsNil(petUIModel) then
        petUIModel:Destroy()
      end
      pet2ModelMap[petKey] = nil
    end
  end
  destroyList = nil
end
def.static(ECPanelBase, "number", PetTeamInfo, "table", "table", "table", "number", "function", "table", "=>", "number").ShowPet = function(panel, idx, petTeamInfo, formationCfg, formationGrid, pet2ModelMap, modelId, funcGetPetInfo, extraInfo)
  local grid = formationGrid[idx]
  if _G.IsNil(grid) then
    warn("[ERROR][PetTeamUtils:ShowPet] show pet failed! grid nil at idx:", idx)
    return
  end
  local pos = formationCfg.idx2PosMap[idx]
  local petId = pos and petTeamInfo:GetPosPet(pos)
  local petInfo, bIsRobot = nil, false
  if petId then
    petInfo, bIsRobot = funcGetPetInfo(petId)
  end
  local Model_Pet = grid:FindDirect("Model_Pet")
  if Model_Pet:get_childCount() > 1 then
    Object.Destroy(Model_Pet:GetChild(0))
  end
  local uiModel = Model_Pet:GetComponent("UIModel")
  local petYaoli = 0
  if nil == petInfo then
    uiModel.modelGameObject = nil
  else
    petYaoli = petInfo:GetYaoLi()
    do
      local petKey = Int64.tostring(petId)
      local petUIModel = pet2ModelMap[petKey]
      if petUIModel then
        if not petUIModel:IsInLoading() and not _G.IsNil(uiModel) then
          uiModel.modelGameObject = petUIModel.m_model
        end
      else
        local function funcLoaddedFinish(ret)
          local curPos = petTeamInfo:GetPetPos(petId)
          if not ret or not PetTeamUtils.CheckPanelOnShow(panel) or curPos <= 0 then
            warn("[ERROR][PetsArenaUtils:ShowPet] show pet failed! panel not show.")
            petUIModel:Destroy()
            pet2ModelMap[petKey] = nil
            return
          end
          if curPos ~= pos then
            pos = curPos
            idx = formationCfg.pos2IdxMap[curPos]
            grid = formationGrid[idx]
            Model_Pet = grid and grid:FindDirect("Model_Pet")
            uiModel = Model_Pet and Model_Pet:GetComponent("UIModel")
          end
          if not _G.IsNil(uiModel) then
            uiModel.modelGameObject = petUIModel.m_model
          end
          local petCfg = petInfo:GetPetCfgData()
          if petCfg then
            petUIModel:SetScale(petCfg.petFightModelRatio / 10000)
          else
            warn("[ERROR][PetsArenaUtils:ShowPet] petCfg nil for petInfo.typeId:", petInfo.typeId)
          end
          if extraInfo == nil then
            petUIModel:SetDir(constant.CPetArenaConst.PET_ARENA_MYSELF_DIRECTION)
          elseif extraInfo.bIsMainPage then
            petUIModel:SetDir(constant.CPetFightConsts.MODEL_ROTATE_DEGREE)
          else
            petUIModel:SetDir(constant.CPetArenaConst.PET_ARENA_OPPONENT_DIRECTION)
          end
        end
        if modelId == 0 then
          if bIsRobot then
            petUIModel = Cls.createAndAttachRobotPetUIModel(petInfo, uiModel, funcLoaddedFinish)
          else
            petUIModel = Cls.loadPetUIModelWithPetInfo(petInfo, uiModel, funcLoaddedFinish)
          end
        else
          petUIModel = nil
          local effectPath = _G.GetEffectRes(modelId)
          if effectPath ~= nil then
            require("Fx.GUIFxMan").Instance():PlayAsChild(Model_Pet, effectPath.path, 0, 0, -1, false)
          end
        end
        pet2ModelMap[petKey] = petUIModel
      end
    end
  end
  return petYaoli
end
def.static("table", "userdata", "function", "=>", "table").loadPetUIModelWithPetInfo = function(petInfo, uiModel, cb)
  local petUIModel = PetUtility.CreateAndAttachPetUIModel(petInfo, uiModel, cb)
  return petUIModel
end
def.static("table", "userdata", "function", "=>", "table").createAndAttachRobotPetUIModel = function(robotPetData, uiModel, cb)
  local RobotPetUIModel = require("Main.Pet.PetsArena.RobotPetUIModel")
  local model = RobotPetUIModel.new(robotPetData.id, uiModel)
  model:LoadDefault(cb)
  model:SetCanExceedBound(true)
  return model
end
local ECUIModel = require("Model.ECUIModel")
def.static("number", "function", "=>", "table").loadPetUIModelWithModelId = function(modelId, cb)
  local petUIModel = ECUIModel.new(modelId)
  local modelPath = _G.GetModelPath(modelId)
  petUIModel:LoadUIModel(modelPath, cb)
  return petUIModel
end
local PetsPropTips = require("Main.Pet.PetsArena.ui.PetPropTips")
def.static("table", "number", "userdata", "table").ShowNormalPetTips = function(petTeamInfo, idx, clickObj, extraInfo)
  if petTeamInfo == nil then
    return
  end
  local formationCfg = PetTeamData.Instance():GetFormationCfg(petTeamInfo.formationId)
  if formationCfg == nil then
    return
  end
  local pos = formationCfg.idx2PosMap[idx]
  local petId = pos and petTeamInfo:GetPosPet(pos)
  if petId == nil then
    return
  end
  if extraInfo then
    local petInfo
    if extraInfo.mapPetsInfo then
      petInfo = extraInfo.mapPetsInfo[petId:tostring()]
    end
    extraInfo = {
      rank = extraInfo.rank,
      petInfo = petInfo
    }
  end
  PetsPropTips.ShowPetsTipsWithGO(clickObj, 0, petId, extraInfo)
end
def.static("table", "number", "table", "userdata", "table").ShowRobotPetTips = function(robotPetTeamInfo, idx, mapPetId2PetData, clickObj, extraInfo)
  if robotPetTeamInfo == nil then
    return
  end
  local formationCfg = PetTeamData.Instance():GetFormationCfg(robotPetTeamInfo.formationId)
  if formationCfg == nil then
    return
  end
  local pos = formationCfg.idx2PosMap[idx]
  local petId = pos and robotPetTeamInfo:GetPosPet(pos)
  if petId == nil then
    return
  end
  local robotPetData = mapPetId2PetData[petId:tostring()]
  local extraData = {bIsRobotPet = true, robotPetData = robotPetData}
  if extraInfo then
    extraData.rank = extraInfo.rank
  end
  PetsPropTips.ShowPetsTipsWithGO(clickObj, 0, petId, extraData)
end
return PetsArenaUtils.Commit()
