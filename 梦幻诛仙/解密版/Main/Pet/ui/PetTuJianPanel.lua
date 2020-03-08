local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetTuJianPanel = Lplus.Extend(ECPanelBase, "PetTuJianPanel")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetUtility = require("Main.Pet.PetUtility")
local PetData = Lplus.ForwardDeclare("PetData")
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local ECModel = require("Model.ECModel")
local PetUIModel = require("Main.Pet.PetUIModel")
local GUIUtils = require("GUI.GUIUtils")
local PetModule = require("Main.Pet.PetModule")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local PetTuJianPage = require("consts.mzm.gsp.pet.confbean.PetPageName")
local PetPanel = require("Main.Pet.ui.PetPanel")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = PetTuJianPanel.define
local NOT_SELECTED = -1
def.field("table").tjPetInfoList = nil
def.field("table").petSkillIdList = nil
def.field("number").tjSelectedPetIndex = NOT_SELECTED
def.field("number").selectedNormalPetIndex = NOT_SELECTED
def.field("number").selectedSpecialPetIndex = NOT_SELECTED
def.field("number").tjSelectedPage = PetTuJianPage.NORMAL_PAGE
def.field("number").tjSelectedPetType = NOT_SELECTED
def.field("number").targetPetTID = 0
def.field("table").targetPetCfg = nil
def.field("table").targetPetDetail = nil
def.field("table").tjRecords = nil
def.field("table").tjModel = nil
def.field("boolean").tjIsDrag = false
def.field("boolean").isModelDecorated = true
def.field("number").selectStageLevel = 0
def.const("table").TJ_PetType = {BaoBao = 1, BianYi = 2}
def.field("userdata").m_node = nil
def.field("table").uiObjs = nil
local instance
def.static("=>", PetTuJianPanel).Instance = function()
  if instance == nil then
    instance = PetTuJianPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:HidePanel()
  end
  self:CreatePanel(RESPATH.PREFAB_PET_TUJIAN_PANEL_RES, 1)
  self:SetModal(true)
end
def.method("number").ShowPanelWithPetTemplateId = function(self, id)
  self.targetPetTID = id
  self:ShowPanel()
end
def.method("table").ShowPanelWithPetDetail = function(self, petDetail)
  local tjPetInfoList = self:GetTuJianPets(PetTuJianPage.NORMAL_PAGE, _G.GetHeroProp().level)
  local selected
  for i, v in ipairs(tjPetInfoList) do
    if petDetail.carrayLevel > v.carrayLevel then
      selected = v
    elseif petDetail.carrayLevel == v.carrayLevel then
      selected = v
      break
    elseif selected == nil then
      selected = v
      break
    else
      break
    end
  end
  local petTID = 0
  if selected then
    local petTypeRefCfg = PetUtility.GetPetTypeRefCfg(selected.petTypeRefId)
    if petDetail.type == PetType.BIANYI then
      petTID = petTypeRefCfg.bianYiId
    else
      petTID = petTypeRefCfg.baobaoId
    end
  end
  self:ShowPanelWithPetTemplateId(petTID)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.tjRecords = PetMgr.Instance():GetPetTuJianRecords()
  self:InitSelectedPet()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetTuJianPanel.OnFeatureOpenChange)
end
def.method().HidePanel = function(self)
  PetMgr.Instance():SetPetTuJianRecords(self.tjRecords)
  PetMgr.Instance():SavePetTuJianRecords()
  PetModule.Instance():CheckNotify()
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetTuJianPanel.OnFeatureOpenChange)
end
def.method().InitUI = function(self)
  self.m_node = self.m_panel:FindDirect("Img_Bg0/TJ")
  self.uiObjs = {}
  self.m_node:FindDirect("PetList_TJ/Tap_TJ_Basic"):GetComponent("UIToggle"):set_startsActive(false)
  self.uiObjs.Btn_TJ_Decoration = self.m_node:FindDirect("Img_TJ_Bg0/Img_TJ_BgImage0/Btn_TJ_Decoration")
  self.uiObjs.Btn_TJ_Decoration:SetActive(true)
  self.uiObjs.Btn_TJ_Decoration:GetComponent("UIWidget").depth = 14
  self.uiObjs.Btn_TJ_Decoration:GetComponent("UIToggle").value = true
  self.uiObjs.Btn_Jiewei = self.m_node:FindDirect("Img_TJ_Bg0/Btn_Jiewei")
  self.uiObjs.Group_SmallSelected = self.m_node:FindDirect("Img_TJ_Bg0/Group_SmallSelected")
  GUIUtils.SetActive(self.uiObjs.Btn_Jiewei, false)
  GUIUtils.SetActive(self.uiObjs.Group_SmallSelected, false)
  self.uiObjs.Img_Jiewei = self.m_node:FindDirect("Img_TJ_Bg0/Img_TJ_BgImage0/Img_Jiewei")
  GUIUtils.SetActive(self.uiObjs.Img_Jiewei, false)
  PetUtility.AddBoxCollider(self.uiObjs.Img_Jiewei)
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.m_node = nil
  self.targetPetTID = 0
  self.targetPetCfg = nil
  self.targetPetDetail = nil
  if self.tjModel then
    self.tjModel:Destroy()
    self.tjModel = nil
  end
  self.selectStageLevel = 0
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:SetShenShouBtnEffect()
  self:ResumePetModel()
end
def.method().SetShenShouBtnEffect = function(self)
  local fileName = "config/ShenShouBtnEffectRecord.lua"
  local cfgPath = string.format("%s/%s", Application.persistentDataPath, fileName)
  local roleId = require("Main.Hero.Interface").GetBasicHeroProp().id
  local displayId = require("Main.Hero.Interface").RoleIDToDisplayID(roleId)
  local roleKey = Int64.ToNumber(displayId)
  local IsSet = 0
  local chunk = loadfile(cfgPath)
  local effetSetRecord = chunk and chunk()
  if nil == effetSetRecord then
    local cfg = {}
    cfg[roleKey] = {}
    cfg[roleKey].IsSet = 1
    GameUtil.CreateDirectoryForFile(cfgPath)
    require("Main.Common.LuaTableWriter").SaveTable("EffectSetRecord", cfgPath, cfg)
  else
    local roleCfg = effetSetRecord[roleKey]
    if nil ~= roleCfg then
      IsSet = roleCfg.IsSet
      if 0 == IsSet then
        roleCfg.IsSet = 1
        require("Main.Common.LuaTableWriter").SaveTable("EffectSetRecord", cfgPath, effetSetRecord)
      end
    else
      local newCfg = {}
      effetSetRecord[roleKey] = newCfg
      newCfg.IsSet = 1
      require("Main.Common.LuaTableWriter").SaveTable("EffectSetRecord", cfgPath, effetSetRecord)
    end
  end
  if 0 == IsSet then
    GUIUtils.AddLightEffectToPanel("panel_pettujian/Img_Bg0/TJ/PetList_TJ/Tap_TJ_Special", GUIUtils.Light.Square)
  end
end
def.method().UpdateUI = function(self)
  if self.tjSelectedPage == PetTuJianPage.NORMAL_PAGE then
    self.m_node:FindDirect("PetList_TJ/Tap_TJ_Basic"):GetComponent("UIToggle"):set_value(true)
    self:FillBasicList()
  else
    self.m_node:FindDirect("PetList_TJ/Tap_TJ_Special"):GetComponent("UIToggle"):set_value(true)
    self:FillSpecialList()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  self:HidePetStageLevelSelector()
  local objName = obj.name
  if objName == "Btn_Item2" then
    local parentName = obj.transform.parent.gameObject.name
    if string.find(parentName, "Stage_") then
      local stage = tonumber(string.sub(parentName, 7))
      self:SetPetStageLevel(stage - 1)
    end
  else
    self:onClick(objName)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Modal" then
    self:HidePanel()
  elseif string.sub(id, 1, 13) == "Img_TJ_BgPet_" then
    self:OnPetSelected(id)
  elseif id == "Tap_TJ_Basic" then
    self:FillBasicList()
  elseif id == "Tap_TJ_Special" then
    self:FillSpecialList()
  elseif id == "Tap_TJ_Baby" then
    self:OnBaoBaoTapSelected()
  elseif id == "Tap_TJ_BY" then
    self:OnBianYiTapSelected()
  elseif id == "Btn_TJ_Buy" then
    self:OnBuyPetButtonClick()
  elseif id == "Btn_TJ_Catch" then
    self:OnCatchPetButtonClick()
  elseif id == "Btn_TJ_BabyFS" then
    self:OnFanShengButtonClick()
  elseif id == "Btn_Exchange" then
    self:GoToExchangePet()
  elseif string.sub(id, 1, #"Img_TJ_BgSkill") == "Img_TJ_BgSkill" then
    local index = tonumber(string.sub(id, #"Img_TJ_BgSkill" + 1, -1))
    self:OnSkillIconClick(index)
  elseif id == "Model_TJ" then
    self:OnClickPetModel()
  elseif id == "Img_Kuang" then
    self:OnClickNeedItemChannel()
  elseif id == "Btn_Jiewei" then
    self:ShowPetStageLevelSelector()
  elseif id == "Img_Jiewei" then
    self:OnPetStageLevelClick()
  end
end
def.method().OnClickNeedItemChannel = function(self)
  local itemImg = self.m_node:FindDirect("Img_TJ_Bg0/Group_TJ_Channel/Group_Exchange/Img_Kuang")
  local petInfo = self.tjPetInfoList[self.tjSelectedPetIndex]
  if itemImg and petInfo then
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    local screenposition = WorldPosToScreen(itemImg.position.x, itemImg.position.y)
    local sprite = itemImg:GetComponent("UISprite")
    local width = sprite:get_width()
    local height = sprite:get_height()
    ItemTipsMgr.Instance():ShowBasicTips(petInfo.needItemId, screenposition.x, screenposition.y, width, height, 0, true)
  end
end
def.method("string", "boolean").onToggle = function(self, id, isActive)
  if id == "Btn_TJ_Decoration" then
    self.isModelDecorated = isActive
    self:UpdateModelDecorateState()
  end
end
def.method().InitSelectedPet = function(self)
  self.selectedNormalPetIndex = NOT_SELECTED
  self.selectedSpecialPetIndex = NOT_SELECTED
  self.tjSelectedPetIndex = NOT_SELECTED
  local page = PetTuJianPage.NORMAL_PAGE
  page = self:FindPetBelongPage()
  if page == -1 then
    page = PetTuJianPage.NORMAL_PAGE
  end
  self.tjSelectedPage = page
end
def.method("string").OnPetSelected = function(self, id)
  local index = tonumber(string.sub(id, 14, -1))
  if self.tjSelectedPetIndex == index then
    return
  end
  self.tjSelectedPetIndex = index
  if self.tjSelectedPage == PetTuJianPage.NORMAL_PAGE then
    self.selectedNormalPetIndex = index
  else
    self.selectedSpecialPetIndex = index
  end
  self.selectStageLevel = 0
  self:UpdatePetDesc()
end
def.method().OnBuyPetButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petInfo = self.tjPetInfoList[self.tjSelectedPetIndex]
  if petInfo == nil then
    return
  end
  local petTypeRefCfg = PetUtility.GetPetTypeRefCfg(petInfo.petTypeRefId)
  local petCfg = PetUtility.Instance():GetPetCfg(petTypeRefCfg.wildId)
  self:HidePanel()
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
  PetMgr.Instance():OpenBuyPetPanelWithPetId(petCfg.templateId)
end
def.method().OnCatchPetButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petInfo = self.tjPetInfoList[self.tjSelectedPetIndex]
  if petInfo == nil then
    return
  end
  local mapId = petInfo.mapId
  PetMgr.Instance():GoToCatchPet(mapId)
  self:HidePanel()
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
end
def.method().OnFanShengButtonClick = function(self)
  self:HidePanel()
  local params = {}
  params.nodeId = PetPanel.NodeId.FanShengNode
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.OPEN_PET_PANEL_REQ, params)
end
def.method("number").OnSkillIconClick = function(self, index)
  if self.tjPetInfoList == nil then
    return
  end
  local petInfo = self.tjPetInfoList[self.tjSelectedPetIndex]
  local petCfg
  if self.tjSelectedPage == PetTuJianPage.NORMAL_PAGE then
    local petTypeRefCfg = PetUtility.GetPetTypeRefCfg(petInfo.petTypeRefId)
    if self.tjSelectedPetType == PetTuJianPanel.TJ_PetType.BaoBao then
      petCfg = PetUtility.Instance():GetPetCfg(petTypeRefCfg.baobaoId)
    else
      petCfg = PetUtility.Instance():GetPetCfg(petTypeRefCfg.bianYiId)
    end
  else
    petCfg = PetUtility.Instance():GetPetCfg(petInfo.petTemplateId)
  end
  local skillIdList = require("Main.Skill.SkillUtility").GetMonsterSkillCfg(petCfg.skillPropTabId)
  self:ReplacePetSkillToSelectStage(petCfg.templateId, skillIdList)
  local skillId = skillIdList[index]
  if skillId == nil then
    return
  end
  local sourceObj = self.m_node:FindDirect(string.format("Img_TJ_Bg0/Img_TJ_Skill/Img_TJ_BgSkillGroup/Grid_TJ_Skill/Img_TJ_BgSkill%02d", index))
  PetUtility.ShowPetSkillTip(skillId, sourceObj, -1)
end
def.method().FillBasicList = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  self.tjPetInfoList = self:GetTuJianPets(PetTuJianPage.NORMAL_PAGE, heroProp.level)
  self.tjSelectedPage = PetTuJianPage.NORMAL_PAGE
  if self.selectedNormalPetIndex == NOT_SELECTED then
    local preferIndex = 1
    self.tjSelectedPetType = PetTuJianPanel.TJ_PetType.BaoBao
    preferIndex = self:FindSelectedNormalPetIndex()
    self.selectedNormalPetIndex = preferIndex
  end
  self.tjSelectedPetIndex = self.selectedNormalPetIndex
  self:FillTuJianList(self.tjPetInfoList)
  self:UpdatePetDesc()
end
def.method("=>", "number").FindSelectedNormalPetIndex = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local petCfg
  if self.targetPetCfg then
    petCfg = self.targetPetCfg
    if petCfg.type == PetType.WILD or petCfg.type == PetType.BAOBAO then
      self.tjSelectedPetType = PetTuJianPanel.TJ_PetType.BaoBao
    elseif petCfg.type == PetType.BIANYI then
      self.tjSelectedPetType = PetTuJianPanel.TJ_PetType.BianYi
    end
  else
    self.tjSelectedPetType = PetTuJianPanel.TJ_PetType.BaoBao
  end
  local preferLevel = -1
  local preferIndex = 1
  for i, petInfo in ipairs(self.tjPetInfoList) do
    if petCfg and petInfo.petTypeRefId == petCfg.typeRefId then
      preferIndex = i
      break
    elseif petInfo.carrayLevel <= heroProp.level and preferLevel < petInfo.carrayLevel then
      preferIndex = i
      preferLevel = petInfo.carrayLevel
    end
  end
  return preferIndex
end
def.method().FillSpecialList = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  self.tjPetInfoList = self:GetTuJianPets(PetTuJianPage.SPECIAL_PAGE, heroProp.level)
  self.tjSelectedPage = PetTuJianPage.SPECIAL_PAGE
  if self.selectedSpecialPetIndex == NOT_SELECTED then
    local preferIndex = 1
    if self.targetPetCfg then
      preferIndex = self:FindSelectedSpecialPetIndex()
    end
    self.selectedSpecialPetIndex = preferIndex
  end
  self.tjSelectedPetIndex = self.selectedSpecialPetIndex
  self:FillTuJianList(self.tjPetInfoList)
  self:UpdatePetDesc()
end
def.method("=>", "number").FindSelectedSpecialPetIndex = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local preferLevel = -1
  local preferIndex = 1
  if self.targetPetCfg == nil then
    return preferIndex
  end
  for i, petInfo in ipairs(self.tjPetInfoList) do
    if petInfo.petTemplateId == self.targetPetCfg.templateId then
      preferIndex = i
      break
    elseif petInfo.carrayLevel <= heroProp.level and preferLevel < petInfo.carrayLevel then
      preferIndex = i
      preferLevel = petInfo.carrayLevel
    end
  end
  return preferIndex
end
def.method().OnBaoBaoTapSelected = function(self)
  self.tjSelectedPetType = PetTuJianPanel.TJ_PetType.BaoBao
  self:UpdatePetDesc()
end
def.method().OnBianYiTapSelected = function(self)
  self.tjSelectedPetType = PetTuJianPanel.TJ_PetType.BianYi
  self:UpdatePetDesc()
end
def.method("table").FillTuJianList = function(self, petInfoList)
  local petNum = #petInfoList
  local grid = self.m_node:FindDirect("PetList_TJ/Img_TJ_PetList/Scroll View_TJ_PetList/List_TJ_PetList"):GetComponent("UIGrid")
  local template = grid.gameObject:FindDirect("Img_TJ_BgPet01")
  if template then
    template:SetActive(false)
    template.name = "Img_TJ_BgPet_0"
  else
    template = grid.gameObject:FindDirect("Img_TJ_BgPet_0")
  end
  local gridItemCount = grid:GetChildListCount()
  local gridChildList = grid:GetChildList()
  print("now item count", gridItemCount)
  local maxCount
  if petNum > gridItemCount then
    maxCount = petNum
  else
    maxCount = gridItemCount
  end
  for i = 1, maxCount do
    if i > petNum then
      GameObject.Destroy(gridChildList[i].gameObject)
      gridChildList[i] = nil
    else
      local item
      if i > gridItemCount then
        item = GameObject.Instantiate(template)
        item.name = "Img_TJ_BgPet_" .. i
        grid:AddChild(item.transform)
        item.transform:set_localScale(Vector3.new(1, 1, 1))
        item:SetActive(true)
      else
        item = grid.gameObject:FindDirect("Img_TJ_BgPet_" .. i)
      end
      local petInfo = petInfoList[i]
      self:SetTuJianListItemInfo(petInfo, i, item)
    end
  end
  grid:Reposition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("table", "number", "userdata").SetTuJianListItemInfo = function(self, petInfo, index, item)
  if index == self.tjSelectedPetIndex then
    item:GetComponent("UIToggle"):set_value(true)
    GameUtil.AddGlobalLateTimer(0, true, function()
      if item.isnil then
        return
      end
      local gridObj = item.transform.parent.gameObject
      gridObj:GetComponent("UIGrid"):Reposition()
      local uiScrollView = gridObj.transform.parent.gameObject:GetComponent("UIScrollView")
      uiScrollView:ResetPosition()
      uiScrollView:DragToMakeVisible(item.transform, 4)
    end)
  end
  item:FindDirect("Label_TJ_Num01"):GetComponent("UILabel"):set_text(petInfo.carrayLevel)
  local iconId = 0
  local petId
  if petInfo.petTypeRefId ~= 0 then
    local petTypeRefCfg = PetUtility.GetPetTypeRefCfg(petInfo.petTypeRefId)
    petId = petTypeRefCfg.baobaoId
  else
    petId = petInfo.petTemplateId
  end
  local petCfg = PetUtility.Instance():GetPetCfg(petId)
  iconId = require("Main.Pubrole.PubroleInterface").GetModelCfg(petCfg.modelId).headerIconId
  local uiTexture = item:FindDirect("Icon_TJ_Pet01"):GetComponent("UITexture")
  uiTexture.depth = 10
  require("GUI.GUIUtils").FillIcon(uiTexture, iconId)
  local isNewPet = false
  if petInfo.isCommingSoon then
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  else
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
    if petInfo.petTypeRefId ~= 0 and self.tjRecords[petInfo.petTypeRefId] == nil then
      isNewPet = true
      self.tjRecords[petInfo.petTypeRefId] = petInfo.carrayLevel
    end
  end
  item:FindDirect("Img_Tj_New"):SetActive(isNewPet)
end
def.method().UpdatePetDesc = function(self)
  local petInfo = self.tjPetInfoList[self.tjSelectedPetIndex]
  if petInfo == nil then
    return
  end
  local baoBaoTap = self.m_node:FindDirect("Img_TJ_Bg0/Tap_TJ_Baby")
  local bianYiTap = self.m_node:FindDirect("Img_TJ_Bg0/Tap_TJ_BY")
  local petCfg
  if self.tjSelectedPage == PetTuJianPage.NORMAL_PAGE then
    baoBaoTap:SetActive(true)
    bianYiTap:SetActive(true)
    local petTypeRefCfg = PetUtility.GetPetTypeRefCfg(petInfo.petTypeRefId)
    if self.tjSelectedPetType == PetTuJianPanel.TJ_PetType.BaoBao then
      baoBaoTap:GetComponent("UIToggle").value = true
      petCfg = PetUtility.Instance():GetPetCfg(petTypeRefCfg.baobaoId)
    else
      bianYiTap:GetComponent("UIToggle").value = true
      petCfg = PetUtility.Instance():GetPetCfg(petTypeRefCfg.bianYiId)
    end
  else
    baoBaoTap:SetActive(false)
    bianYiTap:SetActive(false)
    petCfg = PetUtility.Instance():GetPetCfg(petInfo.petTemplateId)
  end
  if PetUtility.GetPetJinjieCfgByPetId(petCfg.templateId) ~= nil and IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_STAGE_LEVELUP) then
    GUIUtils.SetActive(self.uiObjs.Btn_Jiewei, true)
    self:ShowPetStageLevel()
  else
    GUIUtils.SetActive(self.uiObjs.Btn_Jiewei, false)
    self:ClearPetStageLevel()
  end
  local Img_TJ_Bg0 = self.m_node:FindDirect("Img_TJ_Bg0")
  local Img_TJ_BgAttribute = Img_TJ_Bg0:FindDirect("Img_TJ_BgAttribute")
  local Img_TJ_BgImage0 = Img_TJ_Bg0:FindDirect("Img_TJ_BgImage0")
  GUIUtils.SetSprite(Img_TJ_BgImage0:FindDirect("Img_PetType"), petInfo.petTypeStr)
  self:SetPetCfgInfo(petCfg)
  self:SetPetModel(petCfg)
  self:SetPetSourceInfo(petInfo)
end
def.method("number", "boolean").SetNewPetState = function(self, index, state)
  local Img_Tj_New = self.m_node:FindDirect(string.format("PetList_TJ/Img_TJ_PetList/Scroll View_TJ_PetList/List_TJ_PetList/Img_TJ_BgPet_%d/Img_Tj_New", index))
  Img_Tj_New:SetActive(state)
end
def.method("table").SetPetCfgInfo = function(self, petCfg)
  local addGrowValue = 0
  local addAttrValue = {
    0,
    0,
    0,
    0,
    0,
    0
  }
  if 0 < self.selectStageLevel then
    local jinjieCfg = PetUtility.GetPetJinjieCfgByPetId(petCfg.templateId)
    if jinjieCfg ~= nil then
      for i = 1, self.selectStageLevel do
        local stageCfg = jinjieCfg[i]
        if stageCfg ~= nil then
          addGrowValue = addGrowValue + stageCfg.growAddRate / 10000
          addAttrValue[1] = addAttrValue[1] + stageCfg.hpAptAdd
          addAttrValue[2] = addAttrValue[2] + stageCfg.phyAtkAptAdd
          addAttrValue[3] = addAttrValue[3] + stageCfg.magAtkAptAdd
          addAttrValue[4] = addAttrValue[4] + stageCfg.phyDefAptAdd
          addAttrValue[5] = addAttrValue[5] + stageCfg.magDefAptAdd
          addAttrValue[6] = addAttrValue[6] + stageCfg.speedAptAdd
        end
      end
    end
  end
  local Img_TJ_Bg0 = self.m_node:FindDirect("Img_TJ_Bg0")
  local Img_TJ_BgAttribute = Img_TJ_Bg0:FindDirect("Img_TJ_BgAttribute")
  local Img_TJ_BgImage0 = Img_TJ_Bg0:FindDirect("Img_TJ_BgImage0")
  Img_TJ_BgAttribute:SetActive(true)
  Img_TJ_BgImage0:FindDirect("Label_PetName01"):GetComponent("UILabel").text = petCfg.templateName
  local typeSprite = PetUtility.GetPetTypeSpriteName(petCfg.type)
  Img_TJ_BgImage0:FindDirect("Label_TJ_PetType"):GetComponent("UISprite").spriteName = typeSprite
  local Img_Tpye = Img_TJ_BgImage0:FindDirect("Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(petCfg.changeModelCardClassType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
  local minColor = PetUtility.GetPetGrowValueColor(petCfg.growMinValue + addGrowValue, petCfg.growMinValue + addGrowValue, petCfg.growMaxValue + addGrowValue)
  local maxColor = PetUtility.GetPetGrowValueColor(petCfg.growMaxValue + addGrowValue, petCfg.growMinValue + addGrowValue, petCfg.growMaxValue + addGrowValue)
  local minValue = string.format("[%s]%.3f[-]", minColor, petCfg.growMinValue + addGrowValue)
  local maxValue = string.format("[%s]%.3f[-]", maxColor, petCfg.growMaxValue + addGrowValue)
  local text = string.format("%s ~ %s", minValue, maxValue)
  Img_TJ_BgAttribute:FindDirect("Img_TJ_BgGrown/Label_TJ_GrownNum"):GetComponent("UILabel").text = text
  local PetQualityType = PetData.PetQualityType
  local function GetQualityTuple(petQualityType)
    return {
      minValue = petCfg:GetMinQuality(petQualityType) or 0,
      maxValue = petCfg:GetMaxQuality(petQualityType) or 0
    }
  end
  local qualityTable = {
    GetQualityTuple(PetQualityType.HP_APT),
    GetQualityTuple(PetQualityType.PHYATK_APT),
    GetQualityTuple(PetQualityType.MAGATK_APT),
    GetQualityTuple(PetQualityType.PHYDEF_APT),
    GetQualityTuple(PetQualityType.MAGDEF_APT),
    GetQualityTuple(PetQualityType.SPEED_APT)
  }
  for i, v in ipairs(qualityTable) do
    local text = string.format(textRes.Pet[25], v.minValue + addAttrValue[i], v.maxValue + addAttrValue[i])
    local Slider_TJ_Attribute = GUIUtils.FindDirect(Img_TJ_BgAttribute, "Slider_TJ_Attribute0" .. i)
    local Label_TJ_AttributeSlider = GUIUtils.FindDirect(Slider_TJ_Attribute, "Label_TJ_AttributeSlider")
    GUIUtils.SetText(Label_TJ_AttributeSlider, text)
  end
  self:SetAvailableSkillList(petCfg)
  local carrayLevel = petCfg.carryLevel
  local desc = string.format(textRes.Pet[107], carrayLevel)
  self:SetPetDescription(desc)
end
def.method("table").SetAvailableSkillList = function(self, petCfg)
  local skillIdList = require("Main.Skill.SkillUtility").GetMonsterSkillCfg(petCfg.skillPropTabId) or {}
  local ui_Grid_TJ_Skill = self.m_node:FindDirect("Img_TJ_Bg0/Img_TJ_Skill/Img_TJ_BgSkillGroup/Grid_TJ_Skill")
  local uiGrid = ui_Grid_TJ_Skill:GetComponent("UIGrid")
  local itemList = uiGrid:GetChildList()
  local itemCount = uiGrid:GetChildListCount()
  self:ReplacePetSkillToSelectStage(petCfg.templateId, skillIdList)
  for i = 1, itemCount do
    local item = itemList[i].gameObject
    local objIndex = string.format("%02d", i)
    local uiTexture = item:FindDirect("Img_TJ_IconSkill" .. objIndex):GetComponent("UITexture")
    local skillId = skillIdList[i]
    if skillId then
      local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
      local iconId = skillCfg.iconId
      require("GUI.GUIUtils").FillIcon(uiTexture, iconId)
      PetUtility.SetPetSkillBgColor(item, skillId)
    else
      uiTexture.mainTexture = nil
      PetUtility.SetOriginPetSkillBg(item, "Cell_00")
    end
  end
end
def.method("table").SetPetModel = function(self, petCfg)
  local petCfgId = petCfg.templateId
  local objModel = self.m_node:FindDirect("Img_TJ_Bg0/Img_TJ_BgImage0/Model_TJ")
  local uiModel = objModel:GetComponent("UIModel")
  if self.tjModel ~= nil then
    self.tjModel:Destroy()
    self.tjModel = nil
  end
  self.tjModel = PetUIModel.new(petCfgId, uiModel)
  self.tjModel:LoadDefault(nil)
  self.tjModel:SetOrnament(self.isModelDecorated)
  self.tjModel:SetCanExceedBound(true)
end
def.method("string").SetPetDescription = function(self, desc)
  local label = self.m_node:FindDirect("Img_TJ_Bg0/Img_TJ_BgImage0/Label_TJ_Describe"):GetComponent("UILabel")
  label.text = desc
end
def.method("string").onDragStart = function(self, id)
  print("onDragStart", id)
  if id == "Model_TJ" then
    self.tjIsDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.tjIsDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.tjIsDrag == true and self.tjModel then
    self.tjModel:SetDir(self.tjModel.m_ang - dx / 2)
  end
end
def.method().ResumePetModel = function(self)
  if self.tjModel then
    self.tjModel:Play("Stand_c")
  end
end
def.method("table").SetPetSourceInfo = function(self, petInfo)
  local Group_TJ_Channel = self.m_node:FindDirect("Img_TJ_Bg0/Group_TJ_Channel")
  GUIUtils.SetActive(Group_TJ_Channel:FindDirect("Btn_TJ_Buy"), false)
  GUIUtils.SetActive(Group_TJ_Channel:FindDirect("Btn_TJ_Catch"), false)
  GUIUtils.SetActive(Group_TJ_Channel:FindDirect("Btn_TJ_BabyFS"), false)
  local Group_Exchange = Group_TJ_Channel:FindDirect("Group_Exchange")
  local Label_TJ_SpecialChannel = Group_TJ_Channel:FindDirect("Label_TJ_SpecialChannel")
  local ItemChannelImg = Group_Exchange:FindDirect("Img_Kuang")
  GUIUtils.SetActive(Group_Exchange, false)
  GUIUtils.SetActive(Label_TJ_SpecialChannel, false)
  GUIUtils.SetActive(ItemChannelImg, false)
  local GetMethod = require("consts.mzm.gsp.pet.confbean.GetMethod")
  local getType = petInfo.getType
  if getType == GetMethod.DESCMETHOD then
    GUIUtils.SetActive(Label_TJ_SpecialChannel, true)
    GUIUtils.SetText(Label_TJ_SpecialChannel, petInfo.desc)
  elseif getType == GetMethod.SHOPANDCATCHMETHOD then
    local mapId = petInfo.mapId
    if mapId ~= 0 then
      Group_TJ_Channel:FindDirect("Btn_TJ_Catch"):SetActive(true)
      local mapCfg = require("Main.Map.Interface").GetMapCfg(petInfo.mapId)
      local text = string.format(textRes.Pet[26], mapCfg.mapName)
      Group_TJ_Channel:FindDirect("Btn_TJ_Catch/Label_TJ_Catch"):GetComponent("UILabel").text = text
      if self.tjSelectedPetType == PetTuJianPanel.TJ_PetType.BaoBao then
        Group_TJ_Channel:FindDirect("Btn_TJ_Buy"):SetActive(true)
      else
        Group_TJ_Channel:FindDirect("Btn_TJ_BabyFS"):SetActive(true)
      end
    else
      GUIUtils.SetActive(Label_TJ_SpecialChannel, true)
      GUIUtils.SetText(Label_TJ_SpecialChannel, petInfo.desc)
    end
  elseif getType == GetMethod.ITEMMETHOD then
    local Label_Exchange = Group_Exchange:FindDirect("Label_Exchange")
    local needItemId = petInfo.needItemId
    local needItemNum = petInfo.needItemNum
    local itemBase = ItemUtils.GetItemBase(needItemId)
    if itemBase then
      ItemChannelImg:SetActive(true)
      Group_Exchange:SetActive(true)
      local itemName = itemBase.name
      local itemIcon = itemBase.icon
      local texture = ItemChannelImg:FindDirect("Img_IconSkill01")
      GUIUtils.FillIcon(texture:GetComponent("UITexture"), itemIcon)
      local text = string.format(textRes.Pet[113], needItemNum, itemName)
      GUIUtils.SetText(Label_Exchange, text)
    else
      GUIUtils.SetActive(Label_TJ_SpecialChannel, true)
      GUIUtils.SetText(Label_TJ_SpecialChannel, petInfo.desc)
    end
  end
end
def.method("userdata", "table").SetShenShouExchangeInfo = function(self, group, petCfg)
  local Label_Exchange = group:FindDirect("Label_Exchange")
  local petType = petCfg.type
  local cfg = PetUtility.GetPetRandomExchangeCfg(petType)
  if not cfg.items[1] then
    local consume = {itemTypeId = 210100000, itemCount = 0}
  end
  local idlist = ItemUtils.GetItemTypeRefIdList(consume.itemTypeId)
  local itemId = idlist[1]
  local itemBase = ItemUtils.GetItemBase(itemId)
  local itemName = itemBase.name
  local itemCount = consume.itemCount
  local text = string.format(textRes.Pet[113], itemCount, itemName)
  GUIUtils.SetText(Label_Exchange, text)
end
def.method().GoToExchangePet = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petInfo = self.tjPetInfoList[self.tjSelectedPetIndex]
  if petInfo == nil then
    return
  end
  local npcId = petInfo.npcId
  if npcId then
    require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
  end
end
def.method("number", "number", "=>", "table").GetTuJianPets = function(self, page, level)
  return PetUtility.GetTuJianPets(page, level)
end
def.method("=>", "number").FindPetBelongPage = function(self)
  if self.targetPetTID ~= 0 then
    return self:FindPetBelongPageByTID(self.targetPetTID)
  elseif self.targetPetDetail ~= nil then
    return self:FindPetBelongPageByDetail(self.targetPetDetail)
  else
    return PetTuJianPage.NORMAL_PAGE
  end
end
def.method("number", "=>", "number").FindPetBelongPageByTID = function(self, petTID)
  local petCfg = PetUtility.Instance():GetPetCfg(petTID)
  self.targetPetCfg = petCfg
  local cfg
  if petCfg.type == PetType.SHENSHOU or petCfg.type == PetType.MOSHOU then
    cfg = PetUtility.FindPetTuJianCfgByTemplateId(petCfg.templateId)
  else
    if petCfg.typeRefId ~= 0 then
      cfg = PetUtility.FindPetTuJianCfgByTypeRefId(petCfg.typeRefId)
    end
    if cfg == nil then
      cfg = PetUtility.FindPetTuJianCfgByTemplateId(petCfg.templateId)
    end
  end
  if cfg == nil then
    warn(string.format("Missing pet Tujian config (petName=%s, petId=%d)", petCfg.templateName, petTID))
    return PetTuJianPage.NORMAL_PAGE
  end
  return cfg.page
end
def.method("number", "=>", "number").FindPetBelongPageByDetail = function(self, petDetail)
  local cfg
  if petDetail.type == PetType.SHENSHOU or petDetail.type == PetType.MOSHOU then
    return PetTuJianPage.SPECIAL_PAGE
  else
    return PetTuJianPanel.NORMAL_PAGE
  end
end
def.method().OnClickPetModel = function(self)
  PetUtility.PlayPetClickedAnimation(self.tjModel)
end
def.method().UpdateModelDecorateState = function(self)
  if self.tjModel then
    self.tjModel:SetOrnament(self.isModelDecorated)
  end
end
def.method().HidePetStageLevelSelector = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_SmallSelected, false)
end
def.method().ShowPetStageLevelSelector = function(self)
  local petInfo = self.tjPetInfoList[self.tjSelectedPetIndex]
  if petInfo == nil then
    return
  end
  local petCfg = PetUtility.Instance():GetPetCfg(petInfo.petTemplateId)
  local jinjieCfg = PetUtility.GetPetJinjieCfgByPetId(petCfg.templateId)
  if jinjieCfg == nil then
    return
  end
  GUIUtils.SetActive(self.uiObjs.Group_SmallSelected, true)
  local Img_Bg2 = self.uiObjs.Group_SmallSelected:FindDirect("Img_Bg2")
  local List_Item = Img_Bg2:FindDirect("Group_List/List_Item2")
  local template = List_Item:FindDirect("Item1")
  local uiGrid = List_Item:GetComponent("UIGrid")
  GUIUtils.SetActive(template, false)
  local serverLevel = 0
  local serverLevelData = require("Main.Server.ServerModule").Instance():GetServerLevelInfo()
  if serverLevelData ~= nil then
    serverLevel = serverLevelData.level
  end
  local stageList = {}
  table.insert(stageList, 0)
  for k, v in pairs(jinjieCfg) do
    if v.stage == 1 or v.upStageNeedLevel - serverLevel <= 10 then
      table.insert(stageList, v.stage)
    end
  end
  local itemCount = #stageList
  for i = 1, itemCount do
    local itemObj = List_Item:FindDirect("Stage_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(template)
      itemObj:SetActive(true)
      itemObj.name = "Stage_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
    end
    GUIUtils.SetText(itemObj:FindDirect("Btn_Item2/Label_Name2"), string.format(textRes.Pet[175], stageList[i]))
  end
  local unuseIdx = itemCount + 1
  while true do
    local itemObj = List_Item:FindDirect("Stage_" .. unuseIdx)
    if itemObj == nil then
      break
    end
    GameObject.Destroy(itemObj)
    unuseIdx = unuseIdx + 1
  end
  GameUtil.AddGlobalLateTimer(0, true, function()
    uiGrid:Reposition()
    Img_Bg2:GetComponent("UITableResizeBackground"):Reposition()
  end)
end
def.method("number").SetPetStageLevel = function(self, stageLevel)
  self.selectStageLevel = stageLevel
  self:UpdatePetDesc()
end
def.method().ShowPetStageLevel = function(self)
  GUIUtils.SetText(self.uiObjs.Btn_Jiewei:FindDirect("Label_Jiewei"), string.format(textRes.Pet[175], self.selectStageLevel))
  GUIUtils.SetActive(self.uiObjs.Img_Jiewei, true)
  GUIUtils.SetSprite(self.uiObjs.Img_Jiewei, "Img_Jie" .. self.selectStageLevel)
end
def.method().ClearPetStageLevel = function(self)
  self.selectStageLevel = 0
  GUIUtils.SetActive(self.uiObjs.Img_Jiewei, false)
end
def.method("number", "table").ReplacePetSkillToSelectStage = function(self, petCfgId, skillIdList)
  if self.selectStageLevel == 0 then
    return
  end
  local jinjieCfg = PetUtility.GetPetJinjieCfgByPetId(petCfgId)
  if jinjieCfg ~= nil and #jinjieCfg > 0 then
    local stage1 = jinjieCfg[1]
    local stage0Skill = PetUtility.GetPetStateSkillId(stage1.petJinJieSkillCfgId, 0)
    local selectStageSkill = PetUtility.GetPetStateSkillId(stage1.petJinJieSkillCfgId, self.selectStageLevel)
    for i = 1, #skillIdList do
      if skillIdList[i] == stage0Skill then
        skillIdList[i] = selectStageSkill
      end
    end
  end
end
def.method().OnPetStageLevelClick = function(self)
  PetUtility.ShowPetDetailStageLevel(self.selectStageLevel)
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_PET_STAGE_LEVELUP then
    local self = instance
    self:UpdatePetDesc()
  end
end
return PetTuJianPanel.Commit()
