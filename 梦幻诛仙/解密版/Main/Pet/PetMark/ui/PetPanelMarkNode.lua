local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetPanelNodeBase = require("Main.Pet.ui.PetPanelNodeBase")
local PetPanelMarkNode = Lplus.Extend(PetPanelNodeBase, "PetPanelMarkNode")
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local PetMarkUtils = require("Main.Pet.PetMark.PetMarkUtils")
local PetMarkMgr = require("Main.Pet.PetMark.PetMarkMgr")
local PetMarkDataMgr = require("Main.Pet.PetMark.PetMarkDataMgr")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local ECUIModel = require("Model.ECUIModel")
local PetUtility = require("Main.Pet.PetUtility")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local PetMarkQuality = require("consts.mzm.gsp.petmark.confbean.PetMarkQuality")
local def = PetPanelMarkNode.define
def.field("table").uiObjs = nil
def.field("number").selectedMarkType = -1
def.field("table").allPetMarks = nil
def.field("table").filterPetMarks = nil
def.field("userdata").selectedMarkId = nil
def.field("table").petMarkModel = nil
def.field("boolean").isDrag = false
local instance
def.static("=>", PetPanelMarkNode).Instance = function()
  if instance == nil then
    instance = PetPanelMarkNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  PetPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  self:LoadPetMarkListData()
  self:UpdateUI()
  self:UpdatePetMarkBagStatus()
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, PetPanelMarkNode.OnPetMarkListUpdate, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_INFO_CHANGE, PetPanelMarkNode.OnPetMarkInfoChange, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_EQUIP_PET_CHANGE, PetPanelMarkNode.OnPetMarkEquipPetChange, self)
  Event.RegisterEventWithContext(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_NEW_ITEM_NOTIFY_CHANGE, PetPanelMarkNode.OnPetMarkNewItemNotifyChange, self)
end
def.override().OnHide = function(self)
  self.uiObjs = nil
  self.selectedMarkType = -1
  self.allPetMarks = nil
  self.filterPetMarks = nil
  self.selectedMarkId = nil
  self.isDrag = false
  if self.petMarkModel ~= nil then
    self.petMarkModel:Destroy()
    self.petMarkModel = nil
  end
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, PetPanelMarkNode.OnPetMarkListUpdate)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_INFO_CHANGE, PetPanelMarkNode.OnPetMarkInfoChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_EQUIP_PET_CHANGE, PetPanelMarkNode.OnPetMarkEquipPetChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_NEW_ITEM_NOTIFY_CHANGE, PetPanelMarkNode.OnPetMarkNewItemNotifyChange)
end
def.override().InitUI = function(self)
  PetPanelNodeBase.InitUI(self)
  self.uiObjs = {}
  self.uiObjs.Group_Left = self.m_node:FindDirect("Group_Left")
  self.uiObjs.Btn_TypeChoose = self.uiObjs.Group_Left:FindDirect("Btn_SkillChoose")
  self.uiObjs.TypeList = self.uiObjs.Btn_TypeChoose:FindDirect("Group_Zone")
  self.uiObjs.Group_List = self.uiObjs.Group_Left:FindDirect("Group_List")
  self.uiObjs.Group_Right = self.m_node:FindDirect("Group_Right")
  self.uiObjs.Group_Select_Pet = self.uiObjs.Group_Right:FindDirect("Group_Select")
end
def.method().LoadPetMarkListData = function(self)
  self.allPetMarks = PetMarkDataMgr.Instance():GetSortedPetMarkList()
end
def.override().UpdateUI = function(self)
  GUIUtils.SetActive(self.m_panel:FindChild("Img_Bg0/PetList"), false)
  self:HidePetSelector()
  self:FillPetMarkType()
  self:UpdateSelectedMarkType()
  self:HidePetMarkTypeSelector()
  self:SelectPetMarkType(-1)
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
    self.filterPetMarks = self.allPetMarks
  else
    self.filterPetMarks = {}
    for i, v in ipairs(self.allPetMarks or {}) do
      local markCfg = PetMarkUtils.GetPetMarkCfg(v:GetPetMarkCfgId())
      if markCfg.category == self.selectedMarkType then
        table.insert(self.filterPetMarks, v)
      end
    end
  end
  if #self.filterPetMarks > 0 then
    local inFilter = false
    if self.selectedMarkId ~= nil then
      for i = 1, #self.filterPetMarks do
        if Int64.eq(self.selectedMarkId, self.filterPetMarks[i]:GetId()) then
          inFilter = true
          break
        end
      end
    end
    if not inFilter then
      self.selectedMarkId = self.filterPetMarks[1]:GetId()
    end
  else
    self.selectedMarkId = nil
  end
  local ScrollView_List = self.uiObjs.Group_List:FindDirect("ScrollView_List")
  local List = ScrollView_List:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #self.filterPetMarks
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local petMark = self.filterPetMarks[i]
    local markCfg = PetMarkUtils.GetPetMarkCfg(petMark:GetPetMarkCfgId())
    local uiItem = uiItems[i]
    local Img_BgItem = uiItem:FindDirect("Img_BgItem")
    local Icon = Img_BgItem:FindDirect("Icon_Pet01")
    GUIUtils.SetTexture(Icon, markCfg.iconId)
    GUIUtils.SetItemCellSprite(Img_BgItem, markCfg.quality + 1)
    local Label_Name = uiItem:FindDirect("Label_Name")
    local Label_Lv = uiItem:FindDirect("Label_Lv")
    if markCfg.quality == PetMarkQuality.WHITE then
      GUIUtils.SetText(Label_Name, markCfg.name)
    else
      GUIUtils.SetText(Label_Name, string.format("[%s]%s[-]", HtmlHelper.NameColor[markCfg.quality + 1], markCfg.name))
    end
    GUIUtils.SetText(Label_Lv, string.format(textRes.Common[3], petMark:GetLevel()))
    local uiToggle = uiItem:GetComponent("UIToggle")
    uiToggle.optionCanBeNone = true
    if self.selectedMarkId ~= nil and Int64.eq(self.selectedMarkId, petMark:GetId()) then
      uiToggle.value = true
      GUIUtils.DragToMakeVisible(ScrollView_List, uiItem, 0.1, 256)
    else
      uiToggle.value = false
    end
    local Img_Sign = uiItem:FindDirect("Img_Sign")
    GUIUtils.SetActive(Img_Sign, petMark:HasEquipPet())
    uiItem.name = "PetMark_" .. i
  end
end
def.method().FillSelectedPetMarkInfo = function(self)
  if self.selectedMarkId == nil then
    self:ShowEmptyPetMarkInfo()
  else
    self:ShowPetMarkDetailInfo()
  end
end
def.method().ShowEmptyPetMarkInfo = function(self)
  local Group_Item = self.uiObjs.Group_Right:FindDirect("Group_Item")
  local Model_Impress = Group_Item:FindDirect("Model_Impress")
  local Model_Pet = Group_Item:FindDirect("Model_Pet")
  local Img_Add = Group_Item:FindDirect("Img_Add")
  local Label_Add = Group_Item:FindDirect("Label_Add")
  local Label_PetName = Group_Item:FindDirect("Label_PetName")
  local Label_PetLevel = Group_Item:FindDirect("Label_PetLevel")
  GUIUtils.SetActive(Img_Add, false)
  GUIUtils.SetActive(Label_Add, false)
  GUIUtils.SetActive(Model_Pet, false)
  GUIUtils.SetActive(Model_Impress, false)
  GUIUtils.SetText(Label_PetName, "")
  GUIUtils.SetText(Label_PetLevel, "")
  if self.petMarkModel ~= nil then
    self.petMarkModel:Destroy()
    self.petMarkModel = nil
  end
  local Group_Info = self.uiObjs.Group_Right:FindDirect("Group_Info")
  local Img_BgItem = Group_Info:FindDirect("Img_BgItem")
  local Icon_Pet01 = Img_BgItem:FindDirect("Icon_Pet01")
  GUIUtils.SetItemCellSprite(Img_BgItem, 0)
  GUIUtils.SetTexture(Icon_Pet01, 0)
  local Label_Name = Group_Info:FindDirect("Group_Name/Label_Name")
  GUIUtils.SetText(Label_Name, "")
  local Group_Level = Group_Info:FindDirect("Group_Level")
  local Label_LevelNum = Group_Level:FindDirect("Label_LevelNum")
  GUIUtils.SetText(Label_LevelNum, 0)
  GUIUtils.SetActive(Group_Level, false)
  local List_Buff = Group_Info:FindDirect("List_Buff")
  for i = 1, 5 do
    local propItem = List_Buff:FindDirect("item_" .. i)
    GUIUtils.SetActive(propItem, false)
  end
  local Img_Skill = Group_Info:FindDirect("Img_Skill")
  local Icon_Skill = Img_Skill:FindDirect("Icon_Skill")
  local Label_Skill = Img_Skill:FindDirect("Label_Skill")
  local Label_SkillNull = Group_Info:FindDirect("Label_SkillNull")
  GUIUtils.SetItemCellSprite(Img_Skill, 0)
  GUIUtils.SetTexture(Icon_Skill, 0)
  GUIUtils.SetText(Label_Skill, "")
  GUIUtils.SetActive(Img_Skill, false)
  GUIUtils.SetActive(Label_SkillNull, false)
  local Group_Exp = self.uiObjs.Group_Right:FindDirect("Group_Exp")
  local Slider_Exp = Group_Exp:FindDirect("Slider_Exp")
  local Label_Num = Slider_Exp:FindDirect("Label_Num")
  local Label_ExpFull = Group_Exp:FindDirect("Label_ExpFull")
  GUIUtils.SetProgress(Slider_Exp, GUIUtils.COTYPE.SLIDER, 0)
  GUIUtils.SetText(Label_Num, "")
  GUIUtils.SetActive(Slider_Exp, true)
  GUIUtils.SetActive(Label_ExpFull, false)
  local Btn_PetOff = self.uiObjs.Group_Right:FindDirect("Btn_PetOff")
  GUIUtils.SetActive(Btn_PetOff, false)
end
def.method().ShowPetMarkDetailInfo = function(self)
  local petMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.selectedMarkId)
  local cfg = PetMarkUtils.GetPetMarkCfg(petMark:GetPetMarkCfgId())
  local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(cfg.id)
  local levelCfg = allLevelCfg.levelCfg[petMark:GetLevel()]
  local Group_Item = self.uiObjs.Group_Right:FindDirect("Group_Item")
  local Model_Impress = Group_Item:FindDirect("Model_Impress")
  local Model_Pet = Group_Item:FindDirect("Model_Pet")
  local Img_Add = Group_Item:FindDirect("Img_Add")
  local Label_Add = Group_Item:FindDirect("Label_Add")
  local Label_PetName = Group_Item:FindDirect("Label_PetName")
  local Label_PetLevel = Group_Item:FindDirect("Label_PetLevel")
  GUIUtils.SetActive(Model_Pet, false)
  GUIUtils.SetActive(Model_Impress, true)
  if self.petMarkModel ~= nil then
    self.petMarkModel:Destroy()
    self.petMarkModel = nil
  end
  GUIUtils.SetText(Label_PetName, "")
  GUIUtils.SetText(Label_PetLevel, "")
  if petMark:HasEquipPet() then
    GUIUtils.SetActive(Img_Add, false)
    GUIUtils.SetActive(Label_Add, false)
    local pet = PetMgr.Instance():GetPet(petMark:GetPetId())
    self.petMarkModel = PetUtility.CreateAndAttachPetUIModel(pet, Model_Impress:GetComponent("UIModel"), nil)
    self.petMarkModel:SetPetMark(cfg.modelId)
    GUIUtils.SetText(Label_PetName, string.format(textRes.Pet.PetMark[38], pet.name, pet.level))
  else
    GUIUtils.SetActive(Img_Add, true)
    GUIUtils.SetActive(Label_Add, true)
    do
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
      self.petMarkModel = ECUIModel.new(cfg.modelId)
      self.petMarkModel.m_bUncache = true
      self.petMarkModel:LoadUIModel(modelpath, function(ret)
        if self.uiObjs == nil or not self.petMarkModel or not self.petMarkModel.m_model or self.petMarkModel.m_model.isnil then
          return
        end
        AfterModelLoad()
      end)
    end
  end
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
  local Group_Level = Group_Info:FindDirect("Group_Level")
  local Label_LevelNum = Group_Level:FindDirect("Label_LevelNum")
  GUIUtils.SetActive(Group_Level, true)
  GUIUtils.SetText(Label_LevelNum, petMark:GetLevel())
  local List_Buff = Group_Info:FindDirect("List_Buff")
  if petMark:HasEquipPet() then
    local pet = PetMgr.Instance():GetPet(petMark:GetPetId())
    for i = 1, 5 do
      local propItem = List_Buff:FindDirect("item_" .. i)
      if levelCfg.propList[i] then
        GUIUtils.SetActive(propItem, true)
        local Label_Property = propItem:FindDirect("Label")
        local boxCollider = Label_Property:GetComponent("BoxCollider")
        if boxCollider == nil then
          boxCollider = Label_Property:AddComponent("BoxCollider")
          local uiWidget = Label_Property:GetComponent("UIWidget")
          uiWidget.autoResizeBoxCollider = true
        end
        local propertyCfg = _G.GetCommonPropNameCfg(levelCfg.propList[i].propType)
        local propName = propertyCfg and propertyCfg.propName or ""
        local propValue = PetMarkUtils.GetPetMarkActualPropValueStr(pet, levelCfg.propList[i])
        GUIUtils.SetText(Label_Property, string.format(textRes.Pet.PetMark[37], propName, propValue))
      else
        GUIUtils.SetActive(propItem, false)
      end
    end
  else
    for i = 1, 5 do
      local propItem = List_Buff:FindDirect("item_" .. i)
      if levelCfg.propList[i] then
        GUIUtils.SetActive(propItem, true)
        local Label_Property = propItem:FindDirect("Label")
        local boxCollider = Label_Property:GetComponent("BoxCollider")
        if boxCollider == nil then
          boxCollider = Label_Property:AddComponent("BoxCollider")
          local uiWidget = Label_Property:GetComponent("UIWidget")
          uiWidget.autoResizeBoxCollider = true
        end
        local propertyCfg = _G.GetCommonPropNameCfg(levelCfg.propList[i].propType)
        local propName = propertyCfg and propertyCfg.propName or ""
        local propValue = _G.PropValueToText(levelCfg.propList[i].propValue, propertyCfg.valueType)
        GUIUtils.SetText(Label_Property, string.format(textRes.Pet.PetMark[37], propName, propValue))
      else
        GUIUtils.SetActive(propItem, false)
      end
    end
  end
  local SkillUtility = require("Main.Skill.SkillUtility")
  local skillCfg = SkillUtility.GetSkillCfg(levelCfg.passiveSkillId)
  local isUnlock = true
  if skillCfg == nil then
    local nextLevel, nextSkillId = PetMarkUtils.GetPetMarkNextLevelSkillId(petMark:GetPetMarkCfgId(), petMark:GetLevel())
    skillCfg = SkillUtility.GetSkillCfg(nextSkillId)
    if skillCfg ~= nil then
      isUnlock = false
    end
  end
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
    if isUnlock then
      GUIUtils.SetTextureEffect(Icon_Skill:GetComponent("UITexture"), GUIUtils.Effect.Normal)
    else
      GUIUtils.SetTextureEffect(Icon_Skill:GetComponent("UITexture"), GUIUtils.Effect.Gray)
    end
    local skillTag = Img_Skill:GetComponent("UILabel")
    if skillTag == nil then
      skillTag = Img_Skill:AddComponent("UILabel")
      skillTag.enabled = false
    end
    GUIUtils.SetText(Img_Skill, skillCfg.id)
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
  local Group_Exp = self.uiObjs.Group_Right:FindDirect("Group_Exp")
  local Slider_Exp = Group_Exp:FindDirect("Slider_Exp")
  local Label_Num = Slider_Exp:FindDirect("Label_Num")
  local Label_ExpFull = Group_Exp:FindDirect("Label_ExpFull")
  if not petMark:IsFullLevel() then
    GUIUtils.SetActive(Slider_Exp, true)
    GUIUtils.SetActive(Label_ExpFull, false)
    local curNum = petMark:GetExp()
    local needNum = levelCfg.upgradeExp
    GUIUtils.SetProgress(Slider_Exp, GUIUtils.COTYPE.SLIDER, curNum / needNum)
    GUIUtils.SetText(Label_Num, curNum .. "/" .. needNum)
  else
    GUIUtils.SetActive(Slider_Exp, false)
    GUIUtils.SetActive(Label_ExpFull, true)
    GUIUtils.SetText(Label_ExpFull, textRes.Pet.PetMark[16])
  end
  local Btn_PetOff = self.uiObjs.Group_Right:FindDirect("Btn_PetOff")
  GUIUtils.SetActive(Btn_PetOff, true)
end
def.method().ShowPetSelector = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  GUIUtils.SetActive(self.uiObjs.Group_Select_Pet, true)
  local petList = PetMgr.Instance():GetSortedPetList()
  local Img_Bg = self.uiObjs.Group_Select_Pet:FindDirect("Img_Bg")
  local ScrollView = Img_Bg:FindDirect("Img_Background/Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local template = Grid:FindDirect("Img_Bg01")
  GUIUtils.SetActive(template, false)
  local uiGrid = Grid:GetComponent("UIGrid")
  local itemCount = #petList
  for i = 1, itemCount do
    local itemObj = Grid:FindDirect("PetDeital_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(template)
      itemObj:SetActive(true)
      itemObj.name = "PetDeital_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
    end
    local petTag = itemObj:GetComponent("UILabel")
    if petTag == nil then
      petTag = itemObj:AddComponent("UILabel")
      petTag:set_enabled(false)
    end
    petTag.text = petList[i].id:tostring()
    local petCfg = petList[i]:GetPetCfgData()
    local Label_Name = itemObj:FindDirect("Label_Name")
    local Label_Lv = itemObj:FindDirect("Label_Lv")
    local Labe_PetType = itemObj:FindDirect("Labe_PetType")
    local Img_Icon = itemObj:FindDirect("Img_BgIcon/Img_Icon")
    local Img_PetImpress = itemObj:FindDirect("Img_PetImpress")
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), petList[i]:GetHeadIconId())
    GUIUtils.SetText(Label_Name, petList[i].name)
    GUIUtils.SetText(Label_Lv, string.format(textRes.Mounts[21], petList[i].level))
    GUIUtils.SetText(Labe_PetType, textRes.Pet.Type[petCfg.type])
    GUIUtils.SetActive(Img_PetImpress, PetMarkDataMgr.Instance():IsPetEquipMark(petList[i].id))
    itemObj:GetComponent("UIToggle").value = false
  end
  local rmIdx = itemCount + 1
  while true do
    local itemObj = Grid:FindDirect("PetDeital_" .. rmIdx)
    if itemObj == nil then
      break
    end
    GameObject.Destroy(itemObj)
    rmIdx = rmIdx + 1
  end
  GameUtil.AddGlobalTimer(0.1, true, function()
    if _G.IsNil(ScrollView) then
      return
    end
    ScrollView:GetComponent("UIScrollView"):ResetPosition()
  end)
end
def.method().HidePetSelector = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_Select_Pet, false)
end
def.method("=>", "userdata").GetSelectedPetId = function(self)
  local selectedPetId
  local Img_Bg = self.uiObjs.Group_Select_Pet:FindDirect("Img_Bg")
  local ScrollView = Img_Bg:FindDirect("Img_Background/Scroll View")
  local Grid = ScrollView:FindDirect("Grid")
  local idx = 1
  while true do
    local petItem = Grid:FindDirect("PetDeital_" .. idx)
    if petItem == nil then
      break
    end
    if petItem:GetComponent("UIToggle").value then
      local petTag = petItem:GetComponent("UILabel")
      if petTag ~= nil then
        local petId = Int64.new(petTag.text)
        if petId ~= nil then
          selectedPetId = petId
        end
      end
      break
    end
    idx = idx + 1
  end
  return selectedPetId
end
def.method().UpdatePetMarkBagStatus = function(self)
  local Btn_CardBag = self.uiObjs.Group_Left:FindDirect("Btn_CardBag")
  local Img_Red = Btn_CardBag:FindDirect("Img_Red")
  GUIUtils.SetActive(Img_Red, PetMarkMgr.Instance():HasNewPetMarkItemNotify())
end
def.override("string").onClick = function(self, id)
  if id == "Btn_SkillChoose" then
    self:TogglePetMarkTypeSelector()
  else
    self:HidePetMarkTypeSelector()
  end
  if id == "Img_Add" then
    self:ShowPetSelector()
  elseif not string.find(id, "PetDeital_") then
    self:HidePetSelector()
  end
  if id == "Btn_CardBag" then
    self:OnClickBtnPetMarkBag()
  elseif id == "Btn_YJTj" then
    self:OnClickBtnPetMarkTujian()
  elseif string.find(id, "PetMarkType_") then
    local markType = tonumber(string.sub(id, #"PetMarkType_" + 1))
    self:OnClickPetMarkType(markType)
  elseif string.find(id, "PetMark_") then
    local idx = tonumber(string.sub(id, #"PetMark_" + 1))
    self:onClickPetMark(idx)
  elseif id == "Img_Skill" then
    self:onClickPetMarkSkill()
  elseif id == "Btn_Confirm" then
    self:OnClickConfirmPet()
  elseif id == "Btn_PetOff" then
    self:OnClickRemovePet()
  elseif id == "Btn_ShengJi" then
    self:OnClickLevelUp()
  elseif id == "Btn_RongLian" then
    self:OnClickDecompose()
  elseif id == "Btn_ChouQu" then
    self:OnClickDrawLottery()
  elseif id == "Btn_Help" then
    self:OnClickTips()
  elseif id == "Btn_AttHelp" then
    self:OnClickPropertyTips()
  end
end
def.method().OnClickBtnPetMarkBag = function(self)
  PetMarkMgr.Instance():SetHasNewPetMarkItemNotify(false)
  GameUtil.AddGlobalTimer(0.1, true, function()
    require("Main.Pet.PetMark.ui.PetMarkBagPanel").Instance():ShowPanel()
  end)
end
def.method().OnClickBtnPetMarkTujian = function(self)
  require("Main.Pet.PetMark.ui.PetMarkTujianPanel").Instance():ShowPanel()
end
def.method("number").OnClickPetMarkType = function(self, markType)
  self:SelectPetMarkType(markType)
end
def.method("number").onClickPetMark = function(self, idx)
  local uiItem = self.uiObjs.Group_List:FindDirect("ScrollView_List/List/PetMark_" .. idx)
  if uiItem then
    uiItem:GetComponent("UIToggle").value = true
  end
  if self.filterPetMarks == nil or self.filterPetMarks[idx] == nil then
    return
  end
  self.selectedMarkId = self.filterPetMarks[idx]:GetId()
  self:FillSelectedPetMarkInfo()
end
def.method().onClickPetMarkSkill = function(self)
  if self.selectedMarkId == nil then
    return
  end
  local Group_Info = self.uiObjs.Group_Right:FindDirect("Group_Info")
  local Img_Skill = Group_Info:FindDirect("Img_Skill")
  local skillTag = Img_Skill:GetComponent("UILabel")
  local skillId = tonumber(skillTag.text)
  if skillId == nil then
    return
  end
  local petMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.selectedMarkId)
  local cfg = PetMarkUtils.GetPetMarkCfg(petMark:GetPetMarkCfgId())
  local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(cfg.id)
  local levelCfg = allLevelCfg.levelCfg[petMark:GetLevel()]
  local isUnlock = true
  local skillLevel = petMark:GetLevel()
  if skillId ~= levelCfg.passiveSkillId then
    local nextLevel, nextSkillId = PetMarkUtils.GetPetMarkNextLevelSkillId(petMark:GetPetMarkCfgId(), petMark:GetLevel())
    skillLevel = nextLevel
    isUnlock = false
  end
  local SkillTipMgr = require("Main.Skill.SkillTipMgr")
  local position = Img_Skill.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = Img_Skill:GetComponent("UIWidget")
  SkillTipMgr.Instance():ShowPetMarkSkillTip(skillId, skillLevel, isUnlock, screenPos.x, screenPos.y, widget.width, widget.height, 0)
end
def.method().OnClickConfirmPet = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local petId = self:GetSelectedPetId()
  if petId == nil then
    return
  end
  if self.selectedMarkId == nil then
    return
  end
  local function EquipPetMark()
    PetMarkMgr.Instance():EquipPetMark(self.selectedMarkId, petId)
  end
  if PetMarkDataMgr.Instance():IsPetEquipMark(petId) then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.PetMark[9], textRes.Pet.PetMark[36], function(selection, tag)
      if selection == 1 then
        EquipPetMark()
      end
    end, nil)
  else
    EquipPetMark()
  end
end
def.method().OnClickRemovePet = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.selectedMarkId == nil then
    return
  end
  local petMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.selectedMarkId)
  if not petMark:HasEquipPet() then
    Toast(textRes.Pet.PetMark[4])
    return
  end
  PetMarkMgr.Instance():UnequipPetMark(self.selectedMarkId)
end
def.method().OnClickLevelUp = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.selectedMarkId == nil then
    Toast(textRes.Pet.PetMark[7])
    return
  end
  local currentMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.selectedMarkId)
  if currentMark:IsFullLevel() then
    Toast(textRes.Pet.PetMark[16])
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local needLevel = currentMark:GetLevelUpNeedHeroLevel()
  if needLevel > heroProp.level then
    Toast(string.format(textRes.Pet.PetMark[27], needLevel))
    return
  end
  require("Main.Pet.PetMark.ui.PetMarkLevelUpPanel").Instance():ShowPanelWithMarkId(self.selectedMarkId)
end
def.method().OnClickDecompose = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  require("Main.Pet.PetMark.ui.PetMarkDecomposePanel").Instance():ShowPanel()
end
def.method().OnClickDrawLottery = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  require("Main.Pet.PetMark.ui.PetMarkDrawLotteryPanel").Instance():ShowPanel()
end
def.method().OnClickTips = function(self)
  GUIUtils.ShowHoverTip(constant.CPetMarkConstants.MAIN_INTERFACE_HELP_TIPS_ID)
end
def.method().OnClickPropertyTips = function(self)
  local pos = {x = 0, y = 0}
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  CommonDescDlg.ShowCommonTip(textRes.Pet.PetMark[30], pos)
end
def.override("string").onDragStart = function(self, id)
  if id == "Model_Impress" then
    self.isDrag = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self.petMarkModel then
    self.petMarkModel:SetDir(self.petMarkModel.m_ang - dx / 2)
  end
end
def.method("table").OnPetMarkListUpdate = function(self, params)
  self:LoadPetMarkListData()
  self:FilterSelectedMarkType()
  self:FillSelectedPetMarkInfo()
end
def.method("table").OnPetMarkInfoChange = function(self, params)
  if self.selectedMarkId == nil then
    return
  end
  if Int64.eq(self.selectedMarkId, params.petMarkId) then
    self:FilterSelectedMarkType()
    self:FillSelectedPetMarkInfo()
  end
end
def.method("table").OnPetMarkEquipPetChange = function(self, params)
  self:LoadPetMarkListData()
  self:FilterSelectedMarkType()
  self:FillSelectedPetMarkInfo()
end
def.method("table").OnPetMarkNewItemNotifyChange = function(self, params)
  self:UpdatePetMarkBagStatus()
end
return PetPanelMarkNode.Commit()
