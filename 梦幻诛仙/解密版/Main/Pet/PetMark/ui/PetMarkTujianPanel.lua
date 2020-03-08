local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetMarkTujianPanel = Lplus.Extend(ECPanelBase, "PetMarkTujianPanel")
local GUIUtils = require("GUI.GUIUtils")
local PetMarkUtils = require("Main.Pet.PetMark.PetMarkUtils")
local ECUIModel = require("Model.ECUIModel")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local PetMarkQuality = require("consts.mzm.gsp.petmark.confbean.PetMarkQuality")
local def = PetMarkTujianPanel.define
def.field("table").uiObjs = nil
def.field("number").selectedMarkType = -1
def.field("number").selectedMarkLevel = 1
def.field("number").selectedMarkQuality = PetMarkQuality.ORANGE
def.field("table").allPetMarkTypeMap = nil
def.field("table").allPetMarkCfg = nil
def.field("table").filterPetMarkCfg = nil
def.field("number").selectedMarkTypeId = -1
def.field(ECUIModel).petMarkModel = nil
def.field("boolean").isDrag = false
local instance
def.static("=>", PetMarkTujianPanel).Instance = function()
  if instance == nil then
    instance = PetMarkTujianPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_MARK_TUJIAN_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitPetMarkCfgData()
  self:FillPetMarkType()
  self:UpdateSelectedMarkType()
  self:HidePetMarkTypeSelector()
  self:FillPetMarkQuality()
  self:UpdateSelectedMarkQuality()
  self:HidePetMarkQualitySelector()
  self:SelectPetMarkType(-1)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.selectedMarkType = -1
  self.selectedMarkLevel = 1
  self.selectedMarkQuality = PetMarkQuality.ORANGE
  self.allPetMarkTypeMap = nil
  self.allPetMarkCfg = nil
  self.filterPetMarkCfg = nil
  self.selectedMarkTypeId = -1
  self.isDrag = false
  if self.petMarkModel ~= nil then
    self.petMarkModel:Destroy()
    self.petMarkModel = nil
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_Left = self.m_panel:FindDirect("Img_Bg0/Group_Left")
  self.uiObjs.Btn_TypeChoose = self.uiObjs.Group_Left:FindDirect("Btn_SkillChoose")
  self.uiObjs.TypeList = self.uiObjs.Btn_TypeChoose:FindDirect("Group_Zone")
  self.uiObjs.Group_List = self.uiObjs.Group_Left:FindDirect("Group_List")
  self.uiObjs.Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
  self.uiObjs.Btn_LevelChoose = self.uiObjs.Group_Right:FindDirect("Btn_LevelChoose")
  self.uiObjs.LevelList = self.uiObjs.Btn_LevelChoose:FindDirect("Group_Zone")
  self.uiObjs.Btn_QualityChoose = self.uiObjs.Group_Right:FindDirect("Btn_QualityChoose")
  self.uiObjs.QualityList = self.uiObjs.Btn_QualityChoose:FindDirect("Group_Zone")
end
def.method().InitPetMarkCfgData = function(self)
  local allMarks = PetMarkUtils.GetAllPetMarkCfg()
  self.allPetMarkTypeMap = {}
  for i = 1, #allMarks do
    if allMarks[i].display then
      local mark = allMarks[i]
      if self.allPetMarkTypeMap[mark.typeId] == nil then
        self.allPetMarkTypeMap[mark.typeId] = {}
      end
      table.insert(self.allPetMarkTypeMap[mark.typeId], mark)
    end
  end
  self.allPetMarkCfg = {}
  for typeId, list in pairs(self.allPetMarkTypeMap) do
    table.sort(list, function(a, b)
      return a.quality > b.quality
    end)
    table.insert(self.allPetMarkCfg, list[1])
  end
  table.sort(self.allPetMarkCfg, function(a, b)
    return a.id < b.id
  end)
end
def.method().FillPetMarkType = function(self)
  local PetMarkCategory = require("consts.mzm.gsp.petmark.confbean.PetMarkCategory")
  local typeList = {}
  table.insert(typeList, -1)
  for k, v in pairs(PetMarkCategory) do
    table.insert(typeList, v)
  end
  local Group_ChooseType = self.uiObjs.TypeList:FindDirect("Group_ChooseType")
  local List = Group_ChooseType:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #typeList
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    uiItem.name = "PetMarkType_" .. typeList[i]
    local Label_Name = uiItem:FindDirect("Label_Name")
    GUIUtils.SetText(Label_Name, textRes.Pet.PetMark.PetMarkType[typeList[i]])
  end
end
def.method().UpdateSelectedMarkType = function(self)
  local Label_Btn = self.uiObjs.Btn_TypeChoose:FindDirect("Label_Btn")
  GUIUtils.SetText(Label_Btn, textRes.Pet.PetMark.PetMarkType[self.selectedMarkType])
end
def.method().TogglePetMarkTypeSelector = function(self)
  local visible = self.uiObjs.TypeList.activeSelf
  if visible then
    self:HidePetMarkTypeSelector()
  else
    self:ShowPetMarkTypeSelector()
  end
end
def.method().ShowPetMarkTypeSelector = function(self)
  local Img_Up = self.uiObjs.Btn_TypeChoose:FindDirect("Img_Up")
  local Img_Down = self.uiObjs.Btn_TypeChoose:FindDirect("Img_Down")
  GUIUtils.SetActive(Img_Up, true)
  GUIUtils.SetActive(Img_Down, false)
  GUIUtils.SetActive(self.uiObjs.TypeList, true)
  GameUtil.AddGlobalTimer(0, true, function()
    if self.uiObjs == nil then
      return
    end
    local Group_ChooseType = self.uiObjs.TypeList:FindDirect("Group_ChooseType")
    local List = Group_ChooseType:FindDirect("List")
    local uiList = List:GetComponent("UIList")
    uiList:Resize()
    Group_ChooseType:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method().HidePetMarkTypeSelector = function(self)
  local Img_Up = self.uiObjs.Btn_TypeChoose:FindDirect("Img_Up")
  local Img_Down = self.uiObjs.Btn_TypeChoose:FindDirect("Img_Down")
  GUIUtils.SetActive(Img_Up, false)
  GUIUtils.SetActive(Img_Down, true)
  GUIUtils.SetActive(self.uiObjs.TypeList, false)
end
def.method("number").SelectPetMarkType = function(self, markType)
  self.selectedMarkType = markType
  self:UpdateSelectedMarkType()
  self:FilterSelectedMarkType()
  self:FillSelectedPetMarkInfo()
end
def.method().FilterSelectedMarkType = function(self)
  if self.selectedMarkType == -1 then
    self.filterPetMarkCfg = self.allPetMarkCfg
  else
    self.filterPetMarkCfg = {}
    for i, v in ipairs(self.allPetMarkCfg or {}) do
      if v.category == self.selectedMarkType then
        table.insert(self.filterPetMarkCfg, v)
      end
    end
  end
  if #self.filterPetMarkCfg > 0 then
    self.selectedMarkTypeId = self.filterPetMarkCfg[1].typeId
  else
    self.selectedMarkTypeId = -1
  end
  local ScrollView_List = self.uiObjs.Group_List:FindDirect("ScrollView_List")
  local List = ScrollView_List:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #self.filterPetMarkCfg
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    local Icon = uiItem:FindDirect("Icon")
    GUIUtils.SetTexture(Icon, self.filterPetMarkCfg[i].iconId)
    local uiToggle = uiItem:GetComponent("UIToggle")
    if uiToggle then
      uiToggle.optionCanBeNone = true
      if self.filterPetMarkCfg[i].typeId == self.selectedMarkTypeId then
        uiToggle.value = true
        GUIUtils.DragToMakeVisible(ScrollView_List, uiItem, false, 256)
      else
        uiToggle.value = false
      end
    end
    uiItem.name = "PetMark_" .. i
  end
end
def.method().FillPetMarkQuality = function(self)
  local qualityList = {}
  for k, v in pairs(PetMarkQuality) do
    table.insert(qualityList, v)
  end
  table.sort(qualityList)
  local Group_ChooseType = self.uiObjs.QualityList:FindDirect("Group_ChooseQuality")
  local List = Group_ChooseType:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #qualityList
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    uiItem.name = "PetMarkQuality_" .. qualityList[i]
    local Label_Name = uiItem:FindDirect("Label_Name")
    GUIUtils.SetText(Label_Name, textRes.Pet.PetMark.PetMarkQuality[qualityList[i]])
  end
end
def.method().UpdateSelectedMarkQuality = function(self)
  local Label_Btn = self.uiObjs.Btn_QualityChoose:FindDirect("Label_Btn")
  GUIUtils.SetText(Label_Btn, textRes.Pet.PetMark.PetMarkQuality[self.selectedMarkQuality])
end
def.method().TogglePetMarkQualitySelector = function(self)
  local visible = self.uiObjs.QualityList.activeSelf
  if visible then
    self:HidePetMarkQualitySelector()
  else
    self:ShowPetMarkQualitySelector()
  end
end
def.method().ShowPetMarkQualitySelector = function(self)
  local Img_Up = self.uiObjs.Btn_QualityChoose:FindDirect("Img_Up")
  local Img_Down = self.uiObjs.Btn_QualityChoose:FindDirect("Img_Down")
  GUIUtils.SetActive(Img_Up, true)
  GUIUtils.SetActive(Img_Down, false)
  GUIUtils.SetActive(self.uiObjs.QualityList, true)
  GameUtil.AddGlobalTimer(0, true, function()
    if self.uiObjs == nil then
      return
    end
    local Group_ChooseQuality = self.uiObjs.QualityList:FindDirect("Group_ChooseQuality")
    local List = Group_ChooseQuality:FindDirect("List")
    local uiList = List:GetComponent("UIList")
    uiList:Resize()
    Group_ChooseQuality:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method().HidePetMarkQualitySelector = function(self)
  local Img_Up = self.uiObjs.Btn_QualityChoose:FindDirect("Img_Up")
  local Img_Down = self.uiObjs.Btn_QualityChoose:FindDirect("Img_Down")
  GUIUtils.SetActive(Img_Up, false)
  GUIUtils.SetActive(Img_Down, true)
  GUIUtils.SetActive(self.uiObjs.QualityList, false)
end
def.method().FillSelectedPetMarkInfo = function(self)
  local selectedMarkList = self.allPetMarkTypeMap[self.selectedMarkTypeId]
  local showPetMarkLevelCfg
  for i = 1, #selectedMarkList do
    if selectedMarkList[i].quality == self.selectedMarkQuality then
      showPetMarkLevelCfg = PetMarkUtils.GetPetMarkLevelCfgByLevel(selectedMarkList[i].id, self.selectedMarkLevel)
      break
    end
  end
  if showPetMarkLevelCfg == nil then
    self:ShowEmptyPetMarkInfo()
  else
    self:FillPetMarkLevelSelector()
    self:HidePetMarkLevelSelector()
    self:ShowPetMarkDetailInfo()
  end
end
def.method().ShowEmptyPetMarkInfo = function(self)
  GUIUtils.SetActive(self.uiObjs.Btn_LevelChoose, false)
  local Group_Item = self.uiObjs.Group_Right:FindDirect("Group_Item")
  local Model_Impress = Group_Item:FindDirect("Model_Impress")
  local Model_Pet = Group_Item:FindDirect("Model_Pet")
  local Img_Add = Group_Item:FindDirect("Img_Add")
  local Label_Add = Group_Item:FindDirect("Label_Add")
  local Label_ImpressName = Group_Item:FindDirect("Label_ImpressName")
  GUIUtils.SetActive(Img_Add, false)
  GUIUtils.SetActive(Label_Add, false)
  GUIUtils.SetActive(Model_Pet, false)
  GUIUtils.SetText(Label_ImpressName, "")
  if self.petMarkModel ~= nil then
    self.petMarkModel:Destroy()
    self.petMarkModel = nil
  end
  local Group_Info = self.uiObjs.Group_Right:FindDirect("Group_Info")
  local Img_BgItem = Group_Info:FindDirect("Img_BgItem")
  local Icon_Pet01 = Img_BgItem:FindDirect("Icon_Pet01")
  GUIUtils.SetItemCellSprite(Img_BgItem, 0)
  GUIUtils.SetTexture(Icon_Pet01, 0)
  GUIUtils.SetActive(Group_Level, false)
  local Label_Name = Group_Info:FindDirect("Group_Name/Label_Name")
  GUIUtils.SetText(Label_Name, "")
  local Label_LevelNum = Group_Info:FindDirect("Group_Level/Label_LevelNum")
  GUIUtils.SetText(Label_LevelNum, 0)
  local List_Buff = Group_Info:FindDirect("List_Buff")
  for i = 1, 5 do
    local propItem = List_Buff:FindDirect("item_" .. i)
    GUIUtils.SetActive(propItem, false)
  end
  local Btn_AttHelp = Group_Info:FindDirect("Btn_AttHelp")
  GUIUtils.SetActive(Btn_AttHelp, false)
  local Img_Skill = Group_Info:FindDirect("Img_Skill")
  local Icon_Skill = Img_Skill:FindDirect("Icon_Skill")
  local Label_Skill = Img_Skill:FindDirect("Label_Skill")
  local Label_SkillNull = Group_Info:FindDirect("Label_SkillNull")
  GUIUtils.SetItemCellSprite(Img_Skill, 0)
  GUIUtils.SetTexture(Icon_Skill, 0)
  GUIUtils.SetText(Label_Skill, "")
  GUIUtils.SetActive(Img_Skill, false)
  GUIUtils.SetActive(Label_SkillNull, false)
end
def.method().FillPetMarkLevelSelector = function(self)
  local cfg
  local selectedMarkList = self.allPetMarkTypeMap[self.selectedMarkTypeId]
  for i = 1, #selectedMarkList do
    if selectedMarkList[i].quality == self.selectedMarkQuality then
      cfg = selectedMarkList[i]
      break
    end
  end
  local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(cfg.id)
  GUIUtils.SetActive(self.uiObjs.Btn_LevelChoose, true)
  local Group_ChooseType = self.uiObjs.LevelList:FindDirect("Group_ChooseType")
  local List = Group_ChooseType:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #allLevelCfg.levelCfg
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    uiItem.name = "PetMarkLevel_" .. i
    local Label_Name = uiItem:FindDirect("Label_Name")
    GUIUtils.SetText(Label_Name, string.format(textRes.Common[3], i))
  end
end
def.method().TogglePetMarkLevelSelector = function(self)
  local visible = self.uiObjs.LevelList.activeSelf
  if visible then
    self:HidePetMarkLevelSelector()
  else
    self:ShowPetMarkLevelSelector()
  end
end
def.method().ShowPetMarkLevelSelector = function(self)
  local Img_Up = self.uiObjs.Btn_LevelChoose:FindDirect("Img_Up")
  local Img_Down = self.uiObjs.Btn_LevelChoose:FindDirect("Img_Down")
  GUIUtils.SetActive(Img_Up, true)
  GUIUtils.SetActive(Img_Down, false)
  GUIUtils.SetActive(self.uiObjs.LevelList, true)
  GameUtil.AddGlobalTimer(0, true, function()
    if self.uiObjs == nil then
      return
    end
    local Group_ChooseType = self.uiObjs.LevelList:FindDirect("Group_ChooseType")
    local List = Group_ChooseType:FindDirect("List")
    local uiList = List:GetComponent("UIList")
    uiList:Resize()
    Group_ChooseType:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method().HidePetMarkLevelSelector = function(self)
  local Img_Up = self.uiObjs.Btn_LevelChoose:FindDirect("Img_Up")
  local Img_Down = self.uiObjs.Btn_LevelChoose:FindDirect("Img_Down")
  GUIUtils.SetActive(Img_Up, false)
  GUIUtils.SetActive(Img_Down, true)
  GUIUtils.SetActive(self.uiObjs.LevelList, false)
end
def.method().ShowPetMarkDetailInfo = function(self)
  local level = self.selectedMarkLevel
  local cfg
  local selectedMarkList = self.allPetMarkTypeMap[self.selectedMarkTypeId]
  for i = 1, #selectedMarkList do
    if selectedMarkList[i].quality == self.selectedMarkQuality then
      cfg = selectedMarkList[i]
      break
    end
  end
  local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(cfg.id)
  local levelCfg = allLevelCfg.levelCfg[level]
  local Label_Btn = self.uiObjs.Btn_LevelChoose:FindDirect("Label_Btn")
  GUIUtils.SetText(Label_Btn, string.format(textRes.Common[3], level))
  local Group_Item = self.uiObjs.Group_Right:FindDirect("Group_Item")
  local Model_Impress = Group_Item:FindDirect("Model_Impress")
  local Model_Pet = Group_Item:FindDirect("Model_Pet")
  local Img_Add = Group_Item:FindDirect("Img_Add")
  local Label_Add = Group_Item:FindDirect("Label_Add")
  local Label_ImpressName = Group_Item:FindDirect("Label_ImpressName")
  GUIUtils.SetActive(Img_Add, false)
  GUIUtils.SetActive(Label_Add, false)
  GUIUtils.SetActive(Model_Pet, false)
  if cfg.quality == PetMarkQuality.WHITE then
    GUIUtils.SetText(Label_ImpressName, cfg.name)
  else
    GUIUtils.SetText(Label_ImpressName, string.format("[%s]%s[-]", HtmlHelper.NameColor[cfg.quality + 1], cfg.name))
  end
  local uiModel = Model_Impress:GetComponent("UIModel")
  local modelpath, modelcolor = _G.GetModelPath(cfg.modelId)
  local function AfterModelLoad()
    uiModel.modelGameObject = self.petMarkModel.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end
  if self.petMarkModel ~= nil then
    self.petMarkModel:Destroy()
    self.petMarkModel = nil
  end
  self.petMarkModel = ECUIModel.new(cfg.modelId)
  self.petMarkModel.m_bUncache = true
  self.petMarkModel:LoadUIModel(modelpath, function(ret)
    if self.uiObjs == nil or not self.petMarkModel or not self.petMarkModel.m_model or self.petMarkModel.m_model.isnil then
      return
    end
    AfterModelLoad()
  end)
  local Group_Info = self.uiObjs.Group_Right:FindDirect("Group_Info")
  local Img_BgItem = Group_Info:FindDirect("Img_BgItem")
  local Icon_Pet01 = Img_BgItem:FindDirect("Icon_Pet01")
  GUIUtils.SetItemCellSprite(Img_BgItem, cfg.quality + 1)
  GUIUtils.SetTexture(Icon_Pet01, cfg.iconId)
  local Label_Name = Group_Info:FindDirect("Group_Name/Label_Name")
  if cfg.quality == PetMarkQuality.WHITE then
    GUIUtils.SetText(Label_Name, cfg.name)
  else
    GUIUtils.SetText(Label_Name, string.format("[%s]%s[-]", HtmlHelper.NameColor[cfg.quality + 1], cfg.name))
  end
  GUIUtils.SetActive(Group_Level, true)
  local Label_LevelNum = Group_Info:FindDirect("Group_Level/Label_LevelNum")
  GUIUtils.SetText(Label_LevelNum, level)
  local List_Buff = Group_Info:FindDirect("List_Buff")
  for i = 1, 5 do
    local propItem = List_Buff:FindDirect("item_" .. i)
    if levelCfg.propList[i] then
      GUIUtils.SetActive(propItem, true)
      local Label_Property = propItem:FindDirect("Label")
      local propertyCfg = _G.GetCommonPropNameCfg(levelCfg.propList[i].propType)
      local propName = propertyCfg and propertyCfg.propName or ""
      local propValue = _G.PropValueToText(levelCfg.propList[i].propValue, propertyCfg.valueType)
      GUIUtils.SetText(Label_Property, string.format(textRes.Pet.PetMark[37], propName, propValue))
    else
      GUIUtils.SetActive(propItem, false)
    end
  end
  local Btn_AttHelp = Group_Info:FindDirect("Btn_AttHelp")
  GUIUtils.SetActive(Btn_AttHelp, false)
  local SkillUtility = require("Main.Skill.SkillUtility")
  local skillCfg = SkillUtility.GetSkillCfg(levelCfg.passiveSkillId)
  local Img_Skill = Group_Info:FindDirect("Img_Skill")
  local Icon_Skill = Img_Skill:FindDirect("Icon_Skill")
  local Label_Skill = Img_Skill:FindDirect("Label_Skill")
  local Label_SkillNull = Group_Info:FindDirect("Label_SkillNull")
  if skillCfg then
    GUIUtils.SetActive(Img_Skill, true)
    GUIUtils.SetItemCellSprite(Img_Skill, 0)
    GUIUtils.SetTexture(Icon_Skill, skillCfg.iconId)
    GUIUtils.SetText(Label_Skill, skillCfg.name)
    GUIUtils.SetActive(Label_SkillNull, false)
    local skillTag = Img_Skill:GetComponent("UILabel")
    if skillTag == nil then
      skillTag = Img_Skill:AddComponent("UILabel")
      skillTag.enabled = false
    end
    GUIUtils.SetText(Img_Skill, levelCfg.passiveSkillId)
  else
    GUIUtils.SetItemCellSprite(Img_Skill, 0)
    GUIUtils.SetTexture(Icon_Skill, 0)
    GUIUtils.SetText(Label_Skill, "")
    GUIUtils.SetActive(Label_SkillNull, true)
    local skillTag = Img_Skill:GetComponent("UILabel")
    if skillTag == nil then
      skillTag = Img_Skill:AddComponent("UILabel")
      skillTag.enabled = false
    end
    GUIUtils.SetText(Img_Skill, "")
    GUIUtils.SetActive(Img_Skill, false)
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_SkillChoose" then
    self:TogglePetMarkTypeSelector()
  else
    self:HidePetMarkTypeSelector()
  end
  if id == "Btn_LevelChoose" then
    self:TogglePetMarkLevelSelector()
  else
    self:HidePetMarkLevelSelector()
  end
  if id == "Btn_QualityChoose" then
    self:TogglePetMarkQualitySelector()
  else
    self:HidePetMarkQualitySelector()
  end
  if string.find(id, "PetMark_") then
    obj:GetComponent("UIToggle").value = true
    local idx = tonumber(string.sub(id, #"PetMark_" + 1))
    self:onClickPetMark(idx)
  elseif id == "Img_Skill" then
    local skillTag = obj:GetComponent("UILabel")
    local skillId = tonumber(skillTag.text)
    if skillId ~= nil then
      self:onClickPetMarkSkill(obj, skillId)
    end
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "PetMarkType_") then
    local markType = tonumber(string.sub(id, #"PetMarkType_" + 1))
    self:OnClickPetMarkType(markType)
  elseif string.find(id, "PetMarkLevel_") then
    local markLevel = tonumber(string.sub(id, #"PetMarkLevel_" + 1))
    self:onClickPetMarkLevel(markLevel)
  elseif string.find(id, "PetMarkQuality_") then
    local markQuality = tonumber(string.sub(id, #"PetMarkQuality_" + 1))
    self:onClickPetMarkQuality(markQuality)
  elseif id == "Img_Add" then
    self:OnClickAddPet()
  end
end
def.method("number").OnClickPetMarkType = function(self, markType)
  self:SelectPetMarkType(markType)
end
def.method().OnClickAddPet = function(self)
  if self.selectedMarkType == -1 then
    return
  end
end
def.method("number").onClickPetMark = function(self, idx)
  if self.filterPetMarkCfg == nil or self.filterPetMarkCfg[idx] == nil then
    return
  end
  self.selectedMarkTypeId = self.filterPetMarkCfg[idx].typeId
  self:FillSelectedPetMarkInfo()
end
def.method("number").onClickPetMarkLevel = function(self, level)
  if self.selectedMarkTypeId == -1 then
    return
  end
  self.selectedMarkLevel = level
  self:ShowPetMarkDetailInfo()
end
def.method("number").onClickPetMarkQuality = function(self, quality)
  if self.selectedMarkTypeId == -1 then
    return
  end
  self.selectedMarkQuality = quality
  self:UpdateSelectedMarkQuality()
  self:ShowPetMarkDetailInfo()
end
def.method("userdata", "number").onClickPetMarkSkill = function(self, obj, skillId)
  local SkillTipMgr = require("Main.Skill.SkillTipMgr")
  SkillTipMgr.Instance():ShowTipByIdEx(skillId, obj, 0)
end
def.method("string").onDragStart = function(self, id)
  warn(id)
  if id == "Model_Impress" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self.petMarkModel then
    self.petMarkModel:SetDir(self.petMarkModel.m_ang - dx / 2)
  end
end
PetMarkTujianPanel.Commit()
return PetMarkTujianPanel
