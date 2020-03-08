local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetMarkDecomposePanel = Lplus.Extend(ECPanelBase, "PetMarkDecomposePanel")
local GUIUtils = require("GUI.GUIUtils")
local PetMarkUtils = require("Main.Pet.PetMark.PetMarkUtils")
local PetMarkMgr = require("Main.Pet.PetMark.PetMarkMgr")
local PetMarkDataMgr = require("Main.Pet.PetMark.PetMarkDataMgr")
local PetMarkType = require("consts.mzm.gsp.petmark.confbean.PetMarkType")
local PetMarkQuality = require("consts.mzm.gsp.petmark.confbean.PetMarkQuality")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local Vector = require("Types.Vector")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local PetMarkQuality = require("consts.mzm.gsp.petmark.confbean.PetMarkQuality")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = PetMarkDecomposePanel.define
def.const("table").UseType = {Mark = 1, Item = 2}
def.const("number").RankType = 2
def.const("number").NeedRepeatTimes = 3
def.const("number").FilterLevelGap = 5
def.const("number").DecomposeConfirmLevel = constant.CPetMarkConstants.DECOMPOSE_CONFIRM_PET_MARK_LEVEL
def.const("number").DecomposeConfirmQuality = PetMarkQuality.ORANGE
def.const("string").FileterQualityKey = "PetMarkDecomposeFilterQuality"
def.const("string").FileterLevelKey = "PetMarkDecomposeFilterLevel"
def.field("table").uiObjs = nil
def.field("userdata").markId = nil
def.field("table").materials = nil
def.field("number").selectedIndex = -1
def.field("boolean").needRepeatConfirm = true
def.field("number").repeatTimes = 0
def.field("number").filterLevel = constant.CPetMarkConstants.PET_MARK_MAX_LEVEL
local instance
def.static("=>", PetMarkDecomposePanel).Instance = function()
  if instance == nil then
    instance = PetMarkDecomposePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_MARK_DECOMPOSE_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitFilter()
  self:UpdateSelectedFilterLevel()
  self:HideFilterLevelSelector()
  self:UpdateAvailableMarkAndItem()
  self:UpdateSelectedMaterialInfo()
  self:UpdateTokenInfo()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, PetMarkDecomposePanel.OnCreditChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetMarkDecomposePanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, PetMarkDecomposePanel.OnPetMarkListChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetMarkDecomposePanel.OnFunctionOpenChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.markId = nil
  self.materials = nil
  self.selectedIndex = -1
  self.needRepeatConfirm = true
  self.repeatTimes = 0
  self.filterLevel = constant.CPetMarkConstants.PET_MARK_MAX_LEVEL
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, PetMarkDecomposePanel.OnCreditChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetMarkDecomposePanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, PetMarkDecomposePanel.OnPetMarkListChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetMarkDecomposePanel.OnFunctionOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Left = self.uiObjs.Img_Bg0:FindDirect("Group_Left")
  self.uiObjs.Group_List = self.uiObjs.Group_Left:FindDirect("Group_List")
  self.uiObjs.Group_Right = self.uiObjs.Img_Bg0:FindDirect("Group_Right")
end
def.method().InitFilter = function(self)
  local currentTotalQualityCount = self:GetCurrentQualityCount()
  local filterQuality = {}
  if LuaPlayerPrefs.HasRoleKey(PetMarkDecomposePanel.FileterQualityKey) then
    local savedFilterQuality = LuaPlayerPrefs.GetRoleTable(PetMarkDecomposePanel.FileterQualityKey)
    for idx, quality in pairs(savedFilterQuality) do
      filterQuality[quality] = true
    end
  else
    for i = 0, currentTotalQualityCount - 1 do
      filterQuality[i] = true
    end
  end
  local Grid_Type = self.uiObjs.Group_Left:FindDirect("Grid_Type")
  for i = 0, currentTotalQualityCount - 1 do
    local btn = Grid_Type:FindDirect("Btn_" .. i + 1)
    local uiToggle = btn:GetComponent("UIToggle")
    uiToggle.optionCanBeNone = true
    uiToggle.value = filterQuality[i] or false
    uiToggle.group = 550 + i
    btn.name = "MarkQuality_" .. i
  end
  if LuaPlayerPrefs.HasRoleKey(PetMarkDecomposePanel.FileterLevelKey) then
    self.filterLevel = LuaPlayerPrefs.GetRoleInt(PetMarkDecomposePanel.FileterLevelKey)
  end
  local levels = {}
  for i = constant.CPetMarkConstants.PET_MARK_MAX_LEVEL, 1, -PetMarkDecomposePanel.FilterLevelGap do
    table.insert(levels, i)
  end
  local Btn_CardChoose = self.uiObjs.Group_Left:FindDirect("Btn_CardChoose")
  local Group_Zone = Btn_CardChoose:FindDirect("Group_Zone")
  local Group_ChooseType = Group_Zone:FindDirect("Group_ChooseType")
  local List = Group_ChooseType:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #levels
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    local Label_Name = uiItem:FindDirect("Label_Name")
    GUIUtils.SetText(Label_Name, string.format(textRes.Common[3], levels[i]))
    uiItem.name = "FilterLevel_" .. levels[i]
  end
end
def.method("=>", "number").GetCurrentQualityCount = function(self)
  local count = 0
  for k, v in pairs(PetMarkQuality) do
    count = count + 1
  end
  return count
end
def.method().UpdateSelectedFilterLevel = function(self)
  local Btn_CardChoose = self.uiObjs.Group_Left:FindDirect("Btn_CardChoose")
  local Label_Btn = Btn_CardChoose:FindDirect("Label_Btn")
  GUIUtils.SetText(Label_Btn, string.format(textRes.Common[3], self.filterLevel))
end
def.method().ToggleFilterLevelSelector = function(self)
  local Btn_CardChoose = self.uiObjs.Group_Left:FindDirect("Btn_CardChoose")
  local Group_Zone = Btn_CardChoose:FindDirect("Group_Zone")
  if Group_Zone.activeSelf then
    self:HideFilterLevelSelector()
  else
    self:ShowFilterLevelSelector()
  end
end
def.method().HideFilterLevelSelector = function(self)
  local Btn_CardChoose = self.uiObjs.Group_Left:FindDirect("Btn_CardChoose")
  local Group_Zone = Btn_CardChoose:FindDirect("Group_Zone")
  local Img_Up = Btn_CardChoose:FindDirect("Img_Up")
  local Img_Down = Btn_CardChoose:FindDirect("Img_Down")
  GUIUtils.SetActive(Group_Zone, false)
  GUIUtils.SetActive(Img_Up, false)
  GUIUtils.SetActive(Img_Down, true)
end
def.method().ShowFilterLevelSelector = function(self)
  local Btn_CardChoose = self.uiObjs.Group_Left:FindDirect("Btn_CardChoose")
  local Group_Zone = Btn_CardChoose:FindDirect("Group_Zone")
  local Img_Up = Btn_CardChoose:FindDirect("Img_Up")
  local Img_Down = Btn_CardChoose:FindDirect("Img_Down")
  GUIUtils.SetActive(Group_Zone, true)
  GUIUtils.SetActive(Img_Up, true)
  GUIUtils.SetActive(Img_Down, false)
end
def.method().UpdateAvailableMarkAndItem = function(self)
  local materials = self:GetSortedCanUsedMaterials()
  if self.materials == nil or #self.materials > #materials then
    self.needRepeatConfirm = true
    self.repeatTimes = 0
  end
  self.materials = materials
  if self.selectedIndex ~= -1 and self.selectedIndex > #materials then
    self.selectedIndex = -1
  end
  local ScrollView_List = self.uiObjs.Group_List:FindDirect("ScrollView_List")
  local List = ScrollView_List:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  uiList.itemCount = #materials
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    self:FillMaterialInfo(i, uiItem, materials[i])
  end
end
def.method().AjustMaterialListPosition = function(self)
  local ScrollView_List = self.uiObjs.Group_List:FindDirect("ScrollView_List")
  local List = ScrollView_List:FindDirect("List")
  local uiList = List:GetComponent("UIList")
  local uiItems = uiList.children
  if uiItems[self.selectedIndex] ~= nil then
    GUIUtils.DragToMakeVisible(ScrollView_List, uiItems[self.selectedIndex], false, 256)
  else
    ScrollView_List:GetComponent("UIScrollView"):ResetPosition()
  end
end
def.method("number", "userdata", "table").FillMaterialInfo = function(self, idx, uiItem, material)
  local Img_BgItem = uiItem:FindDirect("Img_BgItem")
  local Icon_Pet01 = Img_BgItem:FindDirect("Icon_Pet01")
  local Label_Num = Img_BgItem:FindDirect("Label_Num")
  local Label_Name = uiItem:FindDirect("Label_Name")
  local Label_Lv = uiItem:FindDirect("Label_Lv")
  if material.useType == PetMarkDecomposePanel.UseType.Mark then
    local markCfg = PetMarkUtils.GetPetMarkCfg(material.mark:GetPetMarkCfgId())
    GUIUtils.SetTexture(Icon_Pet01, markCfg.iconId)
    GUIUtils.SetItemCellSprite(Img_BgItem, markCfg.quality + 1)
    if markCfg.quality == PetMarkQuality.WHITE then
      GUIUtils.SetText(Label_Name, markCfg.name)
    else
      GUIUtils.SetText(Label_Name, string.format("[%s]%s[-]", HtmlHelper.NameColor[markCfg.quality + 1], markCfg.name))
    end
    GUIUtils.SetText(Label_Num, "1")
    GUIUtils.SetText(Label_Lv, string.format(textRes.Common[3], material.mark:GetLevel()))
  elseif material.useType == PetMarkDecomposePanel.UseType.Item then
    local itemBase = ItemUtils.GetItemBase(material.itemCfg.itemId)
    GUIUtils.SetTexture(Icon_Pet01, itemBase.icon)
    GUIUtils.SetItemCellSprite(Img_BgItem, itemBase.namecolor)
    if itemBase.namecolor == ItemColor.WHITE then
      GUIUtils.SetText(Label_Name, itemBase.name)
    else
      GUIUtils.SetText(Label_Name, string.format("[%s]%s[-]", HtmlHelper.NameColor[itemBase.namecolor], itemBase.name))
    end
    GUIUtils.SetText(Label_Num, material.itemNum)
    GUIUtils.SetText(Label_Lv, string.format(textRes.Common[3], material.itemCfg.level))
  end
  if idx == self.selectedIndex then
    uiItem:GetComponent("UIToggle").value = true
  else
    uiItem:GetComponent("UIToggle").value = false
  end
  uiItem.name = "Material_" .. idx
end
def.method("=>", "table").GetSortedCanUsedMaterials = function(self)
  local qualities = self:GetFilterQualities()
  local filterQuality = {}
  for i = 1, #qualities do
    filterQuality[qualities[i]] = true
  end
  local materials = {}
  for i = 1, PetMarkDecomposePanel.RankType do
    materials[i] = {}
  end
  local allMarks = PetMarkDataMgr.Instance():GetSortedPetMarkList()
  for i = 1, #allMarks do
    local mark = allMarks[i]
    if not mark:HasEquipPet() then
      local markCfg = PetMarkUtils.GetPetMarkCfg(mark:GetPetMarkCfgId())
      if filterQuality[markCfg.quality] == true and mark:GetLevel() <= self.filterLevel then
        local markData = {}
        markData.useType = PetMarkDecomposePanel.UseType.Mark
        markData.mark = mark
        table.insert(materials[1], markData)
      end
    end
  end
  local function sortPetMarkList(list)
    table.sort(list, function(a, b)
      local cfgA = PetMarkUtils.GetPetMarkCfg(a.mark:GetPetMarkCfgId())
      local cfgB = PetMarkUtils.GetPetMarkCfg(b.mark:GetPetMarkCfgId())
      if cfgA.quality ~= cfgB.quality then
        return cfgA.quality > cfgB.quality
      elseif a.mark:GetLevel() ~= b.mark:GetLevel() then
        return a.mark:GetLevel() > b.mark:GetLevel()
      else
        return a.mark:GetPetMarkCfgId() > b.mark:GetPetMarkCfgId()
      end
    end)
  end
  sortPetMarkList(materials[1])
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.PET_MARK_BAG, ItemType.PET_MARK_ITEM)
  local itemId2Num = {}
  for k, v in pairs(items or {}) do
    if itemId2Num[v.id] == nil then
      itemId2Num[v.id] = v.number
    else
      itemId2Num[v.id] = itemId2Num[v.id] + v.number
    end
  end
  for k, v in pairs(itemId2Num) do
    local itemCfg = PetMarkUtils.GetPetMarkItemCfg(k)
    local markCfg = PetMarkUtils.GetPetMarkCfg(itemCfg.petMarkCfgId)
    if filterQuality[markCfg.quality] == true and itemCfg.level <= self.filterLevel then
      local markData = {}
      markData.useType = PetMarkDecomposePanel.UseType.Item
      markData.itemCfg = itemCfg
      markData.itemNum = v
      table.insert(materials[2], markData)
    end
  end
  local function sortPetMarkItemList(list)
    table.sort(list, function(a, b)
      local cfgA = PetMarkUtils.GetPetMarkCfg(a.itemCfg.petMarkCfgId)
      local cfgB = PetMarkUtils.GetPetMarkCfg(b.itemCfg.petMarkCfgId)
      if cfgA.quality ~= cfgB.quality then
        return cfgA.quality > cfgB.quality
      elseif a.itemCfg.level ~= b.itemCfg.level then
        return a.itemCfg.level > b.itemCfg.level
      else
        return a.itemCfg.petMarkCfgId > b.itemCfg.petMarkCfgId
      end
    end)
  end
  sortPetMarkItemList(materials[2])
  local sorted = {}
  for i = 1, PetMarkDecomposePanel.RankType do
    for j = 1, #materials[i] do
      table.insert(sorted, materials[i][j])
    end
  end
  return sorted
end
def.method("=>", "table").GetFilterQualities = function(self)
  local currentTotalQualityCount = self:GetCurrentQualityCount()
  local filterQuality = {}
  local Grid_Type = self.uiObjs.Group_Left:FindDirect("Grid_Type")
  for i = 0, currentTotalQualityCount - 1 do
    local btn = Grid_Type:FindDirect("MarkQuality_" .. i)
    local uiToggle = btn:GetComponent("UIToggle")
    if uiToggle.value then
      table.insert(filterQuality, i)
    end
  end
  return filterQuality
end
def.method().UpdateSelectedMaterialInfo = function(self)
  local Group_Info = self.uiObjs.Group_Right:FindDirect("Group_Info")
  local Group_Exp = self.uiObjs.Group_Right:FindDirect("Group_Exp")
  local Img_BgItem = Group_Info:FindDirect("Img_BgItem")
  local Icon_Pet01 = Img_BgItem:FindDirect("Icon_Pet01")
  local Label_Name = Group_Info:FindDirect("Group_Name/Label_Name")
  local Group_Level = Group_Info:FindDirect("Group_Level")
  local Label_LevelNum = Group_Level:FindDirect("Label_LevelNum")
  local List_Buff = Group_Info:FindDirect("List_Buff")
  local Img_Skill = Group_Info:FindDirect("Img_Skill")
  local Icon_Skill = Img_Skill:FindDirect("Icon_Skill")
  local Label_Skill = Img_Skill:FindDirect("Label_Skill")
  local Btn_AttHelp = Group_Info:FindDirect("Btn_AttHelp")
  local Label_SkillNull = Group_Info:FindDirect("Label_SkillNull")
  if self.selectedIndex == -1 then
    GUIUtils.SetItemCellSprite(Img_BgItem, 0)
    GUIUtils.SetTexture(Icon_Pet01, 0)
    GUIUtils.SetText(Label_Name, "")
    GUIUtils.SetText(Label_LevelNum, 0)
    GUIUtils.SetActive(Group_Level, false)
    for i = 1, 5 do
      local propItem = List_Buff:FindDirect("item_" .. i)
      GUIUtils.SetActive(propItem, false)
    end
    GUIUtils.SetItemCellSprite(Img_Skill, 0)
    GUIUtils.SetTexture(Icon_Skill, 0)
    GUIUtils.SetText(Label_Skill, "")
    GUIUtils.SetActive(Img_Skill, false)
    GUIUtils.SetActive(Label_SkillNull, false)
    GUIUtils.SetActive(Group_Exp, false)
  else
    local material = self.materials[self.selectedIndex]
    local markCfgId
    local level = 0
    if material.useType == PetMarkDecomposePanel.UseType.Mark then
      markCfgId = material.mark:GetPetMarkCfgId()
      level = material.mark:GetLevel()
    elseif material.useType == PetMarkDecomposePanel.UseType.Item then
      markCfgId = material.itemCfg.petMarkCfgId
      level = material.itemCfg.level
    end
    local cfg = PetMarkUtils.GetPetMarkCfg(markCfgId)
    local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(markCfgId)
    local levelCfg = allLevelCfg.levelCfg[level]
    GUIUtils.SetItemCellSprite(Img_BgItem, cfg.quality + 1)
    GUIUtils.SetTexture(Icon_Pet01, cfg.iconId)
    if cfg.quality == PetMarkQuality.WHITE then
      GUIUtils.SetText(Label_Name, cfg.name)
    else
      GUIUtils.SetText(Label_Name, string.format("[%s]%s[-]", HtmlHelper.NameColor[cfg.quality + 1], cfg.name))
    end
    GUIUtils.SetActive(Group_Level, true)
    GUIUtils.SetText(Label_LevelNum, level)
    for i = 1, 5 do
      local propItem = List_Buff:FindDirect("item_" .. i)
      if levelCfg.propList[i] then
        GUIUtils.SetActive(propItem, true)
        local propertyCfg = _G.GetCommonPropNameCfg(levelCfg.propList[i].propType)
        local propName = propertyCfg and propertyCfg.propName or ""
        local propValue = _G.PropValueToText(levelCfg.propList[i].propValue, propertyCfg.valueType)
        GUIUtils.SetText(propItem:FindDirect("Label"), string.format(textRes.Pet.PetMark[37], propName, propValue))
      else
        GUIUtils.SetActive(propItem, false)
      end
    end
    local SkillUtility = require("Main.Skill.SkillUtility")
    local skillCfg = SkillUtility.GetSkillCfg(levelCfg.passiveSkillId)
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
    local currentMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.markId)
    local Label_ExpName = Group_Exp:FindDirect("Label_ExpName")
    local Label_ExpNum = Group_Exp:FindDirect("Label_ExpNum")
    local ItemUtils = require("Main.Item.ItemUtils")
    local tokenCfg = ItemUtils.GetTokenCfg(levelCfg.smeltScoreType)
    GUIUtils.SetText(Label_ExpName, string.format("%s+%d", tokenCfg.name, levelCfg.smeltScore))
    GUIUtils.SetText(Label_ExpNum, "")
    GUIUtils.SetActive(Group_Exp, true)
  end
  GUIUtils.SetActive(Btn_AttHelp, false)
end
def.method().UpdateTokenInfo = function(self)
  local Group_ShouYinJi = self.uiObjs.Group_Left:FindDirect("Group_ShouYinJi")
  local tokenCfg = ItemUtils.GetTokenCfg(TokenType.PET_MARK_SCORE1)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE1)
  GUIUtils.SetText(Group_ShouYinJi:FindDirect("Label_Name"), tokenCfg.name)
  GUIUtils.SetText(Group_ShouYinJi:FindDirect("Label_Num"), tokenNum:tostring())
  local Group_ShengShouJi = self.uiObjs.Group_Left:FindDirect("Group_ShengShouJi")
  local tokenCfg = ItemUtils.GetTokenCfg(TokenType.PET_MARK_SCORE2)
  local tokenNum = ItemModule.Instance():GetCredits(TokenType.PET_MARK_SCORE2)
  GUIUtils.SetText(Group_ShengShouJi:FindDirect("Label_Name"), tokenCfg.name)
  GUIUtils.SetText(Group_ShengShouJi:FindDirect("Label_Num"), tokenNum:tostring())
end
def.method().SaveFilterQuality = function(self)
  local filterQuality = self:GetFilterQualities()
  LuaPlayerPrefs.SetRoleTable(PetMarkDecomposePanel.FileterQualityKey, filterQuality)
  LuaPlayerPrefs.Save()
end
def.method().SaveFilterLevel = function(self)
  LuaPlayerPrefs.SetRoleInt(PetMarkDecomposePanel.FileterLevelKey, self.filterLevel)
  LuaPlayerPrefs.Save()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_CardChoose" then
    self:ToggleFilterLevelSelector()
  else
    self:HideFilterLevelSelector()
  end
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "FilterLevel_") then
    local level = tonumber(string.sub(id, #"FilterLevel_" + 1))
    self:OnClickFilterLevel(level)
  elseif string.find(id, "MarkQuality_") then
    self:OnClickFilterQuality()
  elseif string.find(id, "Material_") then
    local idx = tonumber(string.sub(id, #"Material_" + 1))
    self:OnClickMaterial(idx)
  elseif id == "Img_Skill" then
    self:onClickPetMarkSkill()
  elseif id == "Btn_Resolve" then
    self:OnClickBtnDecompose()
  elseif id == "Btn_ResolveAll" then
    self:OnClickBtnDecomposeAll()
  elseif id == "Btn_Help" then
    self:OnClickTips()
  end
end
def.method("number").OnClickFilterLevel = function(self, level)
  self.filterLevel = level
  self:UpdateSelectedFilterLevel()
  self:UpdateAvailableMarkAndItem()
  self:AjustMaterialListPosition()
  self:UpdateSelectedMaterialInfo()
  self:SaveFilterLevel()
end
def.method().OnClickFilterQuality = function(self)
  self:UpdateAvailableMarkAndItem()
  self:AjustMaterialListPosition()
  self:UpdateSelectedMaterialInfo()
  self:SaveFilterQuality()
end
def.method("number").OnClickMaterial = function(self, idx)
  if self.selectedIndex == idx then
    self.selectedIndex = -1
  else
    self.selectedIndex = idx
  end
  self.needRepeatConfirm = true
  self.repeatTimes = 0
  self:UpdateSelectedMaterialInfo()
end
def.method().onClickPetMarkSkill = function(self)
  if self.selectedIndex == -1 then
    return
  end
  local Group_Info = self.uiObjs.Group_Right:FindDirect("Group_Info")
  local Img_Skill = Group_Info:FindDirect("Img_Skill")
  local skillTag = Img_Skill:GetComponent("UILabel")
  local skillId = tonumber(skillTag.text)
  if skillId == nil then
    return
  end
  local SkillTipMgr = require("Main.Skill.SkillTipMgr")
  SkillTipMgr.Instance():ShowTipByIdEx(skillId, Img_Skill, 0)
end
def.method().OnClickBtnDecompose = function(self)
  if self.materials == nil or #self.materials == 0 then
    Toast(textRes.Pet.PetMark[18])
    return
  end
  if self.selectedIndex == -1 then
    Toast(textRes.Pet.PetMark[17])
    return
  end
  local material = self.materials[self.selectedIndex]
  local function decomposeMaterial()
    if material.useType == PetMarkDecomposePanel.UseType.Mark then
      self:DecomposePetMark(material.mark:GetId())
    elseif material.useType == PetMarkDecomposePanel.UseType.Item then
      self:DecomposePetMarkItem(material.itemCfg.itemId)
    end
  end
  local function confirmToDecompose(str)
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.PetMark[9], str, function(selection, tag)
      if selection == 1 then
        local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
        CaptchaConfirmDlg.ShowConfirm(str, "", textRes.Pet.PetMark[22], nil, function(selection)
          if selection == 1 then
            decomposeMaterial()
          end
        end, nil)
      end
    end, nil)
  end
  local markCfgId
  local level = 0
  if material.useType == PetMarkDecomposePanel.UseType.Mark then
    markCfgId = material.mark:GetPetMarkCfgId()
    level = material.mark:GetLevel()
  elseif material.useType == PetMarkDecomposePanel.UseType.Item then
    markCfgId = material.itemCfg.petMarkCfgId
    level = material.itemCfg.level
  end
  local cfg = PetMarkUtils.GetPetMarkCfg(markCfgId)
  if cfg.quality >= PetMarkDecomposePanel.DecomposeConfirmQuality then
    confirmToDecompose(textRes.Pet.PetMark[20])
  elseif level >= PetMarkDecomposePanel.DecomposeConfirmLevel then
    confirmToDecompose(textRes.Pet.PetMark[21])
  else
    decomposeMaterial()
  end
end
def.method("userdata").DecomposePetMark = function(self, id)
  PetMarkMgr.Instance():DecomposeMark(id)
end
def.method("number").DecomposePetMarkItem = function(self, itemId)
  local function decomposeItem(useAll)
    if useAll then
      self.needRepeatConfirm = true
      self.repeatTimes = 0
    end
    PetMarkMgr.Instance():DecomposeMarkItem(itemId, useAll)
  end
  self.repeatTimes = self.repeatTimes + 1
  if self.needRepeatConfirm and self.repeatTimes == PetMarkDecomposePanel.NeedRepeatTimes then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.PetMark[9], textRes.Pet.PetMark[19], function(selection, tag)
      if selection == 1 then
        decomposeItem(true)
      else
        self.needRepeatConfirm = true
      end
    end, nil)
  else
    decomposeItem(false)
  end
end
def.method().OnClickBtnDecomposeAll = function(self)
  if self.materials == nil or #self.materials == 0 then
    Toast(textRes.Pet.PetMark[18])
    return
  end
  local hasHighQuality = false
  local hasHighLevel = false
  local scoreMap = {}
  for i = 1, #self.materials do
    local material = self.materials[i]
    local markCfgId
    local level = 0
    local num = 0
    if material.useType == PetMarkDecomposePanel.UseType.Mark then
      markCfgId = material.mark:GetPetMarkCfgId()
      level = material.mark:GetLevel()
      num = 1
    elseif material.useType == PetMarkDecomposePanel.UseType.Item then
      markCfgId = material.itemCfg.petMarkCfgId
      level = material.itemCfg.level
      num = material.itemNum
    end
    local cfg = PetMarkUtils.GetPetMarkCfg(markCfgId)
    local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(markCfgId)
    local levelCfg = allLevelCfg.levelCfg[level]
    if scoreMap[levelCfg.smeltScoreType] == nil then
      scoreMap[levelCfg.smeltScoreType] = levelCfg.smeltScore * num
    else
      scoreMap[levelCfg.smeltScoreType] = scoreMap[levelCfg.smeltScoreType] + levelCfg.smeltScore * num
    end
    if cfg.quality >= PetMarkDecomposePanel.DecomposeConfirmQuality then
      hasHighQuality = true
    elseif level >= PetMarkDecomposePanel.DecomposeConfirmLevel then
      hasHighLevel = true
    end
  end
  local scoreTbl = {}
  for k, v in pairs(scoreMap) do
    local ItemUtils = require("Main.Item.ItemUtils")
    local tokenCfg = ItemUtils.GetTokenCfg(k)
    table.insert(scoreTbl, string.format(textRes.Pet.PetMark[29], tokenCfg.name, v))
  end
  local scoreStr = table.concat(scoreTbl, "\239\188\140")
  local function decomposeAll()
    local qualities = self:GetFilterQualities()
    PetMarkMgr.Instance():DecomposeAllMarkAndItem(qualities, self.filterLevel)
  end
  local function checkConfirmLevel()
    if hasHighLevel then
      require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.PetMark[9], textRes.Pet.PetMark[21], function(selection, tag)
        if selection == 1 then
          local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
          CaptchaConfirmDlg.ShowConfirm(textRes.Pet.PetMark[21], "", textRes.Pet.PetMark[22], nil, function(selection)
            if selection == 1 then
              decomposeAll()
            end
          end, nil)
        end
      end, nil)
    else
      decomposeAll()
    end
  end
  local function checkConfirmQuality()
    if hasHighQuality then
      require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.PetMark[9], textRes.Pet.PetMark[20], function(selection, tag)
        if selection == 1 then
          local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
          CaptchaConfirmDlg.ShowConfirm(textRes.Pet.PetMark[20], "", textRes.Pet.PetMark[22], nil, function(selection)
            if selection == 1 then
              checkConfirmLevel()
            end
          end, nil)
        end
      end, nil)
    else
      checkConfirmLevel()
    end
  end
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.PetMark[9], string.format(textRes.Pet.PetMark[25], scoreStr), function(selection, tag)
    if selection == 1 then
      self.needRepeatConfirm = true
      checkConfirmQuality()
    end
  end, nil)
end
def.method().OnClickTips = function(self)
  GUIUtils.ShowHoverTip(constant.CPetMarkConstants.DECOMPOSE_TIPS_ID)
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  if instance and p1.bagId == ItemModule.PET_MARK_BAG then
    instance:UpdateAvailableMarkAndItem()
    instance:AjustMaterialListPosition()
  end
end
def.static("table", "table").OnPetMarkListChange = function(p1, p2)
  if instance then
    instance:UpdateAvailableMarkAndItem()
    instance:AjustMaterialListPosition()
  end
end
def.static("table", "table").OnPetMarkInfoChange = function(p1, p2)
  if instance and Int64.eq(instance.markId, p1.petMarkId) then
    instance:UpdateSelectedMaterialInfo()
  end
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if param.feature == ModuleFunSwitchInfo.TYPE_PET_MARK and not param.open then
    instance:DestroyPanel()
  end
end
def.static("table", "table").OnCreditChange = function(params, context)
  instance:UpdateTokenInfo()
end
PetMarkDecomposePanel.Commit()
return PetMarkDecomposePanel
