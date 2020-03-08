local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetMarkLevelUpPanel = Lplus.Extend(ECPanelBase, "PetMarkLevelUpPanel")
local GUIUtils = require("GUI.GUIUtils")
local PetMarkUtils = require("Main.Pet.PetMark.PetMarkUtils")
local PetMarkMgr = require("Main.Pet.PetMark.PetMarkMgr")
local PetMarkDataMgr = require("Main.Pet.PetMark.PetMarkDataMgr")
local PetMarkType = require("consts.mzm.gsp.petmark.confbean.PetMarkType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local PetMarkQuality = require("consts.mzm.gsp.petmark.confbean.PetMarkQuality")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local def = PetMarkLevelUpPanel.define
def.const("table").UseType = {Mark = 1, Item = 2}
def.const("number").RankType = 6
def.const("number").NeedRepeatTimes = 3
def.field("table").uiObjs = nil
def.field("userdata").markId = nil
def.field("table").materials = nil
def.field("number").selectedIndex = -1
def.field("boolean").needRepeatConfirm = true
def.field("number").repeatTimes = 0
local instance
def.static("=>", PetMarkLevelUpPanel).Instance = function()
  if instance == nil then
    instance = PetMarkLevelUpPanel()
  end
  return instance
end
def.method("userdata").ShowPanelWithMarkId = function(self, markId)
  if self:IsShow() then
    return
  end
  self.markId = markId
  self:CreatePanel(RESPATH.PREFAB_PET_MARK_LEVELUP_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateCurrentPetMarkInfo()
  self:UpdateAvailableMarkAndItem()
  self:UpdateSelectedMaterialInfo()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetMarkLevelUpPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, PetMarkLevelUpPanel.OnPetMarkListChange)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_INFO_CHANGE, PetMarkLevelUpPanel.OnPetMarkInfoChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetMarkLevelUpPanel.OnFunctionOpenChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.markId = nil
  self.materials = nil
  self.selectedIndex = -1
  self.needRepeatConfirm = true
  self.repeatTimes = 0
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PetMarkLevelUpPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_LIST_UPDATE, PetMarkLevelUpPanel.OnPetMarkListChange)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_MARK_INFO_CHANGE, PetMarkLevelUpPanel.OnPetMarkInfoChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetMarkLevelUpPanel.OnFunctionOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Left = self.uiObjs.Img_Bg0:FindDirect("Group_Left")
  self.uiObjs.Group_List = self.uiObjs.Group_Left:FindDirect("Group_List")
  self.uiObjs.Group_Exp = self.uiObjs.Group_Left:FindDirect("Group_Exp")
  self.uiObjs.Group_Right = self.uiObjs.Img_Bg0:FindDirect("Group_Right")
end
def.method().UpdateCurrentPetMarkInfo = function(self)
  local Slider_Exp = self.uiObjs.Group_Exp:FindDirect("Slider_Exp")
  local Label_LevelNum = self.uiObjs.Group_Exp:FindDirect("Label_LevelNum")
  local Label_Num = Slider_Exp:FindDirect("Label_Num")
  local Label_ExpFull = self.uiObjs.Group_Exp:FindDirect("Label_ExpFull")
  local Label_ImpressName = self.uiObjs.Group_Exp:FindDirect("Label_ImpressName")
  local Img_BgItem = self.uiObjs.Group_Left:FindDirect("Img_BgItem")
  local Icon_Pet01 = Img_BgItem:FindDirect("Icon_Pet01")
  local currentMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.markId)
  local markCfg = PetMarkUtils.GetPetMarkCfg(currentMark:GetPetMarkCfgId())
  if markCfg.quality == PetMarkQuality.WHITE then
    GUIUtils.SetText(Label_ImpressName, markCfg.name)
  else
    GUIUtils.SetText(Label_ImpressName, string.format("[%s]%s[-]", HtmlHelper.NameColor[markCfg.quality + 1], markCfg.name))
  end
  GUIUtils.SetTexture(Icon_Pet01, markCfg.iconId)
  GUIUtils.SetItemCellSprite(Img_BgItem, markCfg.quality + 1)
  if currentMark:IsFullLevel() then
    GUIUtils.SetActive(Slider_Exp, false)
    GUIUtils.SetActive(Label_ExpFull, true)
    GUIUtils.SetText(Label_ExpFull, textRes.Pet.PetMark[16])
  else
    local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(currentMark:GetPetMarkCfgId())
    local levelCfg = allLevelCfg.levelCfg[currentMark:GetLevel()]
    GUIUtils.SetText(Label_Num, currentMark:GetExp() .. "/" .. levelCfg.upgradeExp)
    GUIUtils.SetProgress(Slider_Exp, GUIUtils.COTYPE.SLIDER, currentMark:GetExp() / levelCfg.upgradeExp)
    GUIUtils.SetActive(Slider_Exp, true)
    GUIUtils.SetActive(Label_ExpFull, false)
  end
  GUIUtils.SetText(Label_LevelNum, currentMark:GetLevel())
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
  if material.useType == PetMarkLevelUpPanel.UseType.Mark then
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
  elseif material.useType == PetMarkLevelUpPanel.UseType.Item then
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
  local currentMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.markId)
  local currentMarkCfg = PetMarkUtils.GetPetMarkCfg(currentMark:GetPetMarkCfgId())
  local materials = {}
  for i = 1, PetMarkLevelUpPanel.RankType do
    materials[i] = {}
  end
  local allMarks = PetMarkDataMgr.Instance():GetSortedPetMarkList()
  for i = 1, #allMarks do
    local mark = allMarks[i]
    if not mark:HasEquipPet() and not Int64.eq(mark:GetId(), self.markId) then
      local markCfg = PetMarkUtils.GetPetMarkCfg(mark:GetPetMarkCfgId())
      if mark:GetPetMarkCfgId() == currentMark:GetPetMarkCfgId() then
        local markData = {}
        markData.useType = PetMarkLevelUpPanel.UseType.Mark
        markData.mark = mark
        table.insert(materials[1], markData)
      elseif markCfg.type == PetMarkType.TYPE_GENERAL and markCfg.quality == currentMarkCfg.quality then
        local markData = {}
        markData.useType = PetMarkLevelUpPanel.UseType.Mark
        markData.mark = mark
        table.insert(materials[3], markData)
      elseif markCfg.quality == currentMarkCfg.quality then
        local markData = {}
        markData.useType = PetMarkLevelUpPanel.UseType.Mark
        markData.mark = mark
        table.insert(materials[5], markData)
      end
    end
  end
  local sortPetMarkList = function(list)
    table.sort(list, function(a, b)
      if a.mark:GetPetMarkCfgId() == b.mark:GetPetMarkCfgId() then
        return a.mark:GetLevel() > b.mark:GetLevel()
      else
        return a.mark:GetPetMarkCfgId() < b.mark:GetPetMarkCfgId()
      end
    end)
  end
  sortPetMarkList(materials[1])
  sortPetMarkList(materials[3])
  sortPetMarkList(materials[4])
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
    if itemCfg.petMarkCfgId == currentMark:GetPetMarkCfgId() then
      local markData = {}
      markData.useType = PetMarkLevelUpPanel.UseType.Item
      markData.itemCfg = itemCfg
      markData.itemNum = v
      table.insert(materials[2], markData)
    elseif markCfg.type == PetMarkType.TYPE_GENERAL and markCfg.quality == currentMarkCfg.quality then
      local markData = {}
      markData.useType = PetMarkLevelUpPanel.UseType.Item
      markData.itemCfg = itemCfg
      markData.itemNum = v
      table.insert(materials[4], markData)
    elseif markCfg.quality == currentMarkCfg.quality then
      local markData = {}
      markData.useType = PetMarkLevelUpPanel.UseType.Item
      markData.itemCfg = itemCfg
      markData.itemNum = v
      table.insert(materials[6], markData)
    end
  end
  local sortPetMarkItemList = function(list)
    table.sort(list, function(a, b)
      if a.itemCfg.petMarkCfgId == b.itemCfg.petMarkCfgId then
        return a.itemCfg.level > b.itemCfg.level
      else
        return a.itemCfg.petMarkCfgId < b.itemCfg.petMarkCfgId
      end
    end)
  end
  sortPetMarkItemList(materials[2])
  sortPetMarkItemList(materials[4])
  sortPetMarkItemList(materials[6])
  local sorted = {}
  for i = 1, PetMarkLevelUpPanel.RankType do
    for j = 1, #materials[i] do
      table.insert(sorted, materials[i][j])
    end
  end
  return sorted
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
    if material.useType == PetMarkLevelUpPanel.UseType.Mark then
      markCfgId = material.mark:GetPetMarkCfgId()
      level = material.mark:GetLevel()
    elseif material.useType == PetMarkLevelUpPanel.UseType.Item then
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
    local Label_ExpNum = Group_Exp:FindDirect("Label_ExpNum")
    local provideExp = 0
    if material.useType == PetMarkLevelUpPanel.UseType.Mark then
      if level > currentMark:GetLevel() then
        local levelCfg1 = allLevelCfg.levelCfg[1]
        provideExp = levelCfg.provideExp - levelCfg1.provideExp
      else
        provideExp = levelCfg.provideExp
      end
      provideExp = provideExp + material.mark:GetExp()
    elseif material.useType == PetMarkLevelUpPanel.UseType.Item then
      provideExp = levelCfg.provideExp
    end
    if markCfgId ~= currentMark:GetPetMarkCfgId() then
      provideExp = math.floor(provideExp / constant.CPetMarkConstants.DIFFRENT_MARK_EXP_REDUSE_RATIO)
    end
    GUIUtils.SetText(Label_ExpNum, string.format("+%d", provideExp))
    GUIUtils.SetActive(Group_Exp, true)
  end
  GUIUtils.SetActive(Btn_AttHelp, false)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Material_") then
    local idx = tonumber(string.sub(id, #"Material_" + 1))
    self:OnClickMaterial(idx)
  elseif id == "Img_Skill" then
    self:onClickPetMarkSkill()
  elseif id == "Btn_Use" then
    self:OnClickBtnUse()
  elseif id == "Btn_UseAll" then
    self:OnClickBtnUseAll()
  elseif id == "Btn_Help" then
    self:OnClickTips()
  end
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
def.method().OnClickBtnUse = function(self)
  if self.selectedIndex == -1 then
    Toast(textRes.Pet.PetMark[8])
    return
  end
  local currentMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.markId)
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
  local material = self.materials[self.selectedIndex]
  if material.useType == PetMarkLevelUpPanel.UseType.Mark then
    self:UsePetMark(material.mark:GetId())
  elseif material.useType == PetMarkLevelUpPanel.UseType.Item then
    self:UsePetMarkItem(material.itemCfg.itemId)
  end
end
def.method("userdata").UsePetMark = function(self, id)
  PetMarkMgr.Instance():PetMarkUpgradeWithMark(self.markId, id)
end
def.method("number").UsePetMarkItem = function(self, itemId)
  local function useItem(useAll)
    if useAll then
      self.needRepeatConfirm = true
      self.repeatTimes = 0
    end
    PetMarkMgr.Instance():PetMarkUpgradeWithItem(self.markId, itemId, useAll)
  end
  self.repeatTimes = self.repeatTimes + 1
  if self.needRepeatConfirm and self.repeatTimes == PetMarkLevelUpPanel.NeedRepeatTimes then
    require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.PetMark[9], textRes.Pet.PetMark[10], function(selection, tag)
      if selection == 1 then
        useItem(true)
      else
        self.needRepeatConfirm = true
      end
    end, nil)
  else
    useItem(false)
  end
end
def.method().OnClickBtnUseAll = function(self)
  local currentMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.markId)
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
  local allExp = self:GetAllMaterialExp()
  local confirmStr = string.format(textRes.Pet.PetMark[11], allExp)
  require("GUI.CommonConfirmDlg").ShowConfirm(textRes.Pet.PetMark[9], confirmStr, function(selection, tag)
    if selection == 1 then
      self.needRepeatConfirm = true
      PetMarkMgr.Instance():PetMarkUpgradeUseAll(self.markId)
    end
  end, nil)
end
def.method("=>", "number").GetAllMaterialExp = function(self)
  if self.materials == nil then
    return 0
  end
  local allExp = 0
  for i = 1, #self.materials do
    local material = self.materials[i]
    local markCfgId
    local level = 0
    if material.useType == PetMarkLevelUpPanel.UseType.Mark then
      markCfgId = material.mark:GetPetMarkCfgId()
      level = material.mark:GetLevel()
    elseif material.useType == PetMarkLevelUpPanel.UseType.Item then
      markCfgId = material.itemCfg.petMarkCfgId
      level = material.itemCfg.level
    end
    local cfg = PetMarkUtils.GetPetMarkCfg(markCfgId)
    local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(markCfgId)
    local levelCfg = allLevelCfg.levelCfg[level]
    local currentMark = PetMarkDataMgr.Instance():GetPetMarkInfo(self.markId)
    local provideExp = 0
    if material.useType == PetMarkLevelUpPanel.UseType.Mark then
      if level > currentMark:GetLevel() then
        local levelCfg1 = allLevelCfg.levelCfg[1]
        provideExp = levelCfg.provideExp - levelCfg1.provideExp
      else
        provideExp = levelCfg.provideExp
      end
      provideExp = provideExp + material.mark:GetExp()
    elseif material.useType == PetMarkLevelUpPanel.UseType.Item then
      provideExp = levelCfg.provideExp * material.itemNum
    end
    if markCfgId ~= currentMark:GetPetMarkCfgId() then
      provideExp = math.floor(provideExp / constant.CPetMarkConstants.DIFFRENT_MARK_EXP_REDUSE_RATIO)
    end
    allExp = allExp + provideExp
  end
  return allExp
end
def.method().OnClickTips = function(self)
  GUIUtils.ShowHoverTip(constant.CPetMarkConstants.UPGRADE_TIPS_ID)
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
    instance:UpdateCurrentPetMarkInfo()
    instance:UpdateSelectedMaterialInfo()
  end
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if param.feature == ModuleFunSwitchInfo.TYPE_PET_MARK and not param.open then
    instance:DestroyPanel()
  end
end
PetMarkLevelUpPanel.Commit()
return PetMarkLevelUpPanel
