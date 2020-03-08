local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local GUIUtils = require("GUI.GUIUtils")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local EquipModule = Lplus.ForwardDeclare("EquipModule")
local PetTeamInfo = require("Main.PetTeam.data.PetTeamInfo")
local PetUtility = require("Main.Pet.PetUtility")
local PetTeamUtils = Lplus.Class("PetTeamUtils")
local def = PetTeamUtils.define
def.static(ECPanelBase, PetTeamInfo, "table", "userdata", "table", "boolean").ShowTeamFormation = function(panel, petTeamInfo, formationGrid, labelTeamScore, pet2ModelMap, bEdit)
  PetTeamUtils.ShowFormation(nil, petTeamInfo, formationGrid, bEdit)
  PetTeamUtils.ShowTeam(panel, petTeamInfo, formationGrid, labelTeamScore, pet2ModelMap)
end
def.static(ECPanelBase, "=>", "boolean").CheckPanelOnShow = function(panel)
  if _G.IsNil(panel) or not panel:IsShow() then
    return false
  else
    return true
  end
end
def.static(ECPanelBase, PetTeamInfo, "table", "userdata", "table").ShowTeam = function(panel, petTeamInfo, formationGrid, labelTeamScore, pet2ModelMap)
  if not PetTeamUtils.CheckPanelOnShow(panel) then
    warn("[ERROR][PetTeamUtils:ShowTeam] show pet team failed! panel not show.")
    return
  end
  if nil == petTeamInfo then
    warn("[ERROR][PetTeamUtils:ShowTeam] show pet team failed! petTeamInfo nil.")
    return
  end
  if nil == formationGrid then
    warn("[ERROR][PetTeamUtils:ShowTeam] show pet team failed! formationGrid nil.")
    return
  end
  if nil == pet2ModelMap then
    warn("[ERROR][PetTeamUtils:ShowTeam] show pet team failed! pet2ModelMap nil.")
    return
  end
  local formationCfg = PetTeamData.Instance():GetFormationCfg(petTeamInfo.formationId)
  if nil == formationCfg then
    warn("[ERROR][PetTeamUtils:ShowTeam] show pet team failed! formationCfg nil for petTeamInfo.formationId:", petTeamInfo.formationId)
    return
  end
  for idx, grid in ipairs(formationGrid) do
    PetTeamUtils.ShowPet(panel, idx, petTeamInfo, formationCfg, formationGrid, pet2ModelMap)
  end
  if labelTeamScore then
    GUIUtils.SetText(labelTeamScore, petTeamInfo:GetPetScore())
  end
  local destroyList = {}
  for petKey, petUIModel in pairs(pet2ModelMap) do
    if petTeamInfo:GetPetPos(Int64.new(petKey)) <= 0 then
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
def.static(ECPanelBase, "number", PetTeamInfo, "table", "table", "table").ShowPet = function(panel, idx, petTeamInfo, formationCfg, formationGrid, pet2ModelMap)
  local grid = formationGrid[idx]
  if _G.IsNil(grid) then
    warn("[ERROR][PetTeamUtils:ShowPet] show pet failed! grid nil at idx:", idx)
    return
  end
  local pos = formationCfg.idx2PosMap[idx]
  local petId = pos and petTeamInfo:GetPosPet(pos)
  local petInfo = petId and PetMgr.Instance():GetPet(petId)
  local Label_PetName = grid:FindDirect("Label_PetName")
  local Model_Pet = grid:FindDirect("Model_Pet")
  local uiModel = Model_Pet:GetComponent("UIModel")
  if nil == petInfo then
    GUIUtils.SetText(Label_PetName, "")
    uiModel.modelGameObject = nil
  else
    do
      local petKey = Int64.tostring(petId)
      local petUIModel = pet2ModelMap[petKey]
      if petUIModel then
        if not petUIModel:IsInLoading() and not _G.IsNil(uiModel) then
          GUIUtils.SetText(Label_PetName, petInfo.name)
          uiModel.modelGameObject = petUIModel.m_model
        end
      else
        petUIModel = PetUtility.CreateAndAttachPetUIModel(petInfo, uiModel, function(ret)
          local curPos = petTeamInfo:GetPetPos(petId)
          if not ret or not PetTeamUtils.CheckPanelOnShow(panel) or curPos <= 0 then
            warn("[ERROR][PetTeamUtils:ShowPet] show pet failed! panel not show.")
            petUIModel:Destroy()
            pet2ModelMap[petKey] = nil
            return
          end
          if curPos ~= pos then
            pos = curPos
            idx = formationCfg.pos2IdxMap[curPos]
            grid = formationGrid[idx]
            Label_PetName = grid and grid:FindDirect("Label_PetName")
            Model_Pet = grid and grid:FindDirect("Model_Pet")
            uiModel = Model_Pet and Model_Pet:GetComponent("UIModel")
          end
          GUIUtils.SetText(Label_PetName, petInfo.name)
          if not _G.IsNil(uiModel) then
            uiModel.modelGameObject = petUIModel.m_model
          end
          local petCfg = petInfo:GetPetCfgData()
          if petCfg then
            petUIModel:SetScale(petCfg.petFightModelRatio / 10000)
          else
            warn("[ERROR][PetTeamUtils:ShowPet] petCfg nil for petInfo.typeId:", petInfo.typeId)
          end
          petUIModel:SetDir(constant.CPetFightConsts.MODEL_ROTATE_DEGREE)
        end)
        pet2ModelMap[petKey] = petUIModel
      end
    end
  end
end
def.static("table", PetTeamInfo, "table", "boolean").ShowFormation = function(formationCfg, petTeamInfo, formationGrid, bEdit)
  if nil == formationCfg and petTeamInfo then
    formationCfg = PetTeamData.Instance():GetFormationCfg(petTeamInfo.formationId)
  end
  if nil == formationCfg then
    warn("[ERROR][PetTeamUtils:ShowFormation] show formation failed! formationCfg nil.")
    return
  end
  if nil == formationGrid then
    warn("[ERROR][PetTeamUtils:ShowFormation] show formation failed! formationGrid nil.")
    return
  end
  for idx, cell in ipairs(formationGrid) do
    if not _G.IsNil(cell) then
      local Img_Site = cell:FindDirect("Img_Site")
      local Img_DisAct = cell:FindDirect("Img_DisAct")
      local Img_Act = cell:FindDirect("Img_Act")
      local Img_Select = cell:FindDirect("Img_Select")
      local Img_Add = cell:FindDirect("Img_Add")
      local Img_Dest = cell:FindDirect("Label_Change")
      local Img_Src = cell:FindDirect("Img_Arrow")
      local pos = formationCfg.idx2PosMap[idx]
      if pos and pos > 0 and pos <= constant.CPetFightConsts.MAX_POSITION_NUMBER then
        GUIUtils.SetActive(Img_Site, true)
        GUIUtils.SetSprite(Img_Site, "Img_Team" .. pos)
        if petTeamInfo and petTeamInfo:GetPosPet(pos) then
          GUIUtils.SetActive(Img_DisAct, false)
          GUIUtils.SetActive(Img_Act, true)
          GUIUtils.SetActive(Img_Select, false)
          GUIUtils.SetActive(Img_Add, false)
          GUIUtils.SetActive(Img_Dest, false)
          GUIUtils.SetActive(Img_Src, false)
        else
          GUIUtils.SetActive(Img_DisAct, false)
          GUIUtils.SetActive(Img_Act, true)
          GUIUtils.SetActive(Img_Select, false)
          GUIUtils.SetActive(Img_Add, bEdit)
          GUIUtils.SetActive(Img_Dest, false)
          GUIUtils.SetActive(Img_Src, false)
        end
      else
        GUIUtils.SetActive(Img_Site, false)
        GUIUtils.SetActive(Img_DisAct, true)
        GUIUtils.SetActive(Img_Act, false)
        GUIUtils.SetActive(Img_Select, false)
        GUIUtils.SetActive(Img_Add, false)
        GUIUtils.SetActive(Img_Dest, false)
        GUIUtils.SetActive(Img_Src, false)
      end
    end
  end
end
def.static("number", "number", "userdata", "table").ShowFormationAttrs = function(formationId, level, labelFormationName, attrsGroup)
  local formationCfg = PetTeamData.Instance():GetFormationCfg(formationId)
  if nil == formationCfg then
    warn("[ERROR][PetTeamUtils:ShowFormationAttrs] show formation failed! formationCfg nil:", formationId)
    return
  end
  if nil == attrsGroup then
    warn("[ERROR][PetTeamUtils:ShowFormationAttrs] show formation failed! attrsGroup nil.")
    return
  end
  if not _G.IsNil(labelFormationName) then
    local formName = formationCfg.name
    if level > 0 then
      formName = string.format(textRes.PetTeam.FORMATION_LEVEL, level) .. formName
    end
    GUIUtils.SetText(labelFormationName, formName)
  end
  local levelCfg = PetTeamData.Instance():GetLevelCfg(formationId, level)
  if nil == levelCfg then
  end
  for pos = 1, constant.CPetFightConsts.MAX_PET_NUMBER_PER_TEAM do
    local Group_Att = attrsGroup[pos]
    local Img_Site = Group_Att and Group_Att:FindDirect("Img_Site")
    GUIUtils.SetSprite(Img_Site, "Img_Team" .. pos)
    local attrs = levelCfg and levelCfg.posAttrs[pos]
    local attrString = ""
    for idx = 1, 2 do
      local attrCfg = attrs and attrs[idx]
      local str = attrCfg and PetTeamUtils.GetAttrString(attrCfg)
      if str and "" ~= str then
        if attrString == "" or attrString == nil then
          attrString = str
        else
          attrString = attrString .. "\n" .. str
        end
      end
    end
    local LabelAtt = Group_Att and Group_Att:FindDirect("Label_Att01")
    GUIUtils.SetText(LabelAtt, attrString)
  end
end
def.static("table", "=>", "string").GetAttrString = function(attrCfg)
  if attrCfg then
    local propCfg = GetCommonPropNameCfg(attrCfg.type)
    if nil == propCfg then
      warn("[ERROR][PetTeamUtils:GetAttrString] propCfg nil for type:", attrCfg.type)
      return ""
    end
    local result = " "
    local attrName = propCfg.propName
    if attrName then
      result = attrName .. result
    end
    local attrValue = string.format("%.1f%%", attrCfg.value / 100)
    if attrCfg.value > 0 then
      attrValue = "+" .. attrValue
    end
    local bGood = true
    if propCfg.isGood and attrCfg.value < 0 then
      bGood = false
    elseif not propCfg.isGood and attrCfg.value > 0 then
      bGood = false
    end
    if bGood then
      result = result .. string.format(textRes.PetTeam.FORMATION_ATTR_PLUS, attrValue)
    else
      result = result .. string.format(textRes.PetTeam.FORMATION_ATTR_MINUS, attrValue)
    end
    return result
  else
    return ""
  end
end
def.static("number", "table", "number", "table").ShowFightPetSkillTip = function(petSkillId, position, prefer, context)
  require("GUI.CommonSkillTip").Instance():SetPos(position.x, position.y)
  require("Main.Skill.SkillTipMgr").Instance():ShowFightPetSkillTip(petSkillId, position.x, position.y, 0, 0, prefer, context)
end
def.static("number", "userdata", "number", "table").ShowFightPetSkillTipEx = function(petSkillId, uiObj, prefer, context)
  local position = uiObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = uiObj:GetComponent("UIWidget")
  require("Main.Skill.SkillTipMgr").Instance():ShowFightPetSkillTip(petSkillId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), prefer, context)
end
def.static(PetTeamInfo, PetTeamInfo).CheckSaveTeam = function(oldTeamInfo, newTeamInfo)
  if nil == newTeamInfo then
    return
  end
  local bSavePos = false
  local bSaveForm = false
  if nil == oldTeamInfo then
    bSavePos = true
    bSaveForm = true
  else
    for pos = 1, constant.CPetFightConsts.MAX_PET_NUMBER_PER_TEAM do
      local oldPetId = oldTeamInfo:GetPosPet(pos)
      local newPetId = newTeamInfo:GetPosPet(pos)
      if oldPetId and newPetId then
        if not Int64.eq(oldPetId, newPetId) then
          bSavePos = true
          break
        end
      elseif oldPetId ~= newPetId then
        bSavePos = true
        break
      end
    end
    bSaveForm = oldTeamInfo.formationId ~= newTeamInfo.formationId
  end
  local PetTeamProtocols = require("Main.PetTeam.PetTeamProtocols")
  if bSavePos then
    PetTeamProtocols.SendCPetFightSetPositionReq(newTeamInfo.teamIdx, newTeamInfo.pos2PetMap)
  end
  if bSaveForm then
    PetTeamProtocols.SendCPetFightSetTeamFormationReq(newTeamInfo.teamIdx, newTeamInfo.formationId)
  end
end
PetTeamUtils.Commit()
return PetTeamUtils
