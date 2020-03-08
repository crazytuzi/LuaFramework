local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UITurnCardTuJian = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Cls = UITurnCardTuJian
local def = Cls.define
local instance
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
local TurnedCardInterface = require("Main.TurnedCard.TurnedCardInterface")
local UIModelWrap = require("Model.UIModelWrap")
local txtConst = textRes.TurnedCard
local ProValueType = require("consts.mzm.gsp.common.confbean.ProValueType")
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._allTypeCards = nil
def.field("table")._selTypesCards = nil
def.field("table")._uiModel = nil
def.field("table")._clsList = nil
def.field("table")._curLvList = nil
def.const("table").Level_Frame = TurnedCardUtils.TurnedCardModelFrame
def.const("table").Level_Title = TurnedCardUtils.TurnedCardLevelTitle
def.static("=>", UITurnCardTuJian).Instance = function()
  if instance == nil then
    instance = UITurnCardTuJian()
  end
  return instance
end
def.method().eventsRegister = function(self)
  Event.RegisterEventWithContext(ModuleId.IDIP, gmodule.notifyId.IDIP.ITEM_IDIP_INFO_CHANGE, Cls.OnIDIPInfoChg, self)
end
def.method().eventsUnregister = function(self)
  Event.UnregisterEvent(ModuleId.IDIP, gmodule.notifyId.IDIP.ITEM_IDIP_INFO_CHANGE, Cls.OnIDIPInfoChg)
end
def.override().OnCreate = function(self)
  self._uiGOs = {}
  self._uiStatus = {}
  self._uiStatus.selCardIdx = 1
  self._uiStatus.selLv = 1
  self._uiStatus.selLvIdx = 1
  self._allTypeCards = {}
  local uiGOs = self._uiGOs
  self:eventsRegister()
  uiGOs.groupLeft = self.m_panel:FindDirect("Img _Bg0/Img_BSK/Group_Left")
  uiGOs.groupRight = self.m_panel:FindDirect("Img _Bg0/Img_BSK/Group_Right")
  local template = uiGOs.groupLeft:FindDirect("Btn_SkillChoose/Group_Zone/Group_ChooseType/Grid/Btn_Type_1")
  template.name = "Btn_Type_0"
  template:SetActive(false)
  uiGOs.gridItemTemplate = template
  template = uiGOs.groupRight:FindDirect("Group_Title/Btn_CardChoose/Group_Zone/Group_ChooseType/Grid/Btn_Lv_1")
  template.name = "Btn_Lv_0"
  template:SetActive(false)
  uiGOs.gridLvItemTemplate = template
  self:_initUI()
end
def.override().OnDestroy = function(self)
  self:eventsUnregister()
  self._uiGOs = nil
  self._uiStatus = nil
  self._allTypeCards = nil
  self._clsList = nil
  if self._uiModel then
    self._uiModel:Destroy()
    self._uiModel = nil
  end
  self._selTypesCards = nil
  self._curLvList = nil
end
def.method()._initUI = function(self)
  self._allTypeCards = self:GetCardList()
  self._selTypesCards = self._allTypeCards
  self:SortSelectTypeCards()
  self._clsList = self:ExtractClsList(self._allTypeCards)
  self:_updateUI()
end
def.method()._updateUI = function(self)
  local selCardCfg = self:GetSelectCardCfg()
  local lvsCfg = TurnedCardUtils.GetCardLevelCfg(selCardCfg.id)
  self._curLvList = {}
  for lv, _ in pairs(lvsCfg.cardLevels) do
    table.insert(self._curLvList, lv)
  end
  table.sort(self._curLvList, function(a, b)
    if a < b then
      return true
    else
      return false
    end
  end)
  self._uiStatus.selLv = self._curLvList[self._uiStatus.selLvIdx]
  self:_initUICardsList()
  self:_updateUIRight()
end
def.method()._updateUIRight = function(self)
  local lblLv = self._uiGOs.groupRight:FindDirect("Group_Title/Btn_CardChoose/Label_Btn")
  local colorName, color = self:GetLvColorByLv(self._uiStatus.selLv)
  GUIUtils.SetText(lblLv, colorName)
  local selCardCfg = self:GetSelectCardCfg()
  local selLvCfg = self:GetSelectCardLvCfg(selCardCfg)
  self:_updateUIBottom(selCardCfg, selLvCfg)
  self:_updateUIPropList(selLvCfg)
  local selClsLvCfg = self:GetSelectClsLvCfg(selCardCfg)
  self:_updateUIGameValue(selClsLvCfg)
  self:_updateCardModel(selCardCfg.changeModelId)
  local lblCardName = self._uiGOs.groupRight:FindDirect("Group_Head/Label_Name")
  local imgType = self._uiGOs.groupRight:FindDirect("Group_Head/Img_Tpye")
  local classCfg = TurnedCardUtils.GetCardClassCfg(selCardCfg.classType)
  GUIUtils.SetText(lblCardName, selCardCfg.cardName)
  GUIUtils.FillIcon(imgType:GetComponent("UITexture"), classCfg.iconId)
  self:_updateUIModelBgColor(self._uiStatus.selLv)
  local lblMaxLv = self._uiGOs.groupRight:FindDirect("Group_Title/Label_Tips")
  local curLvListSize = #self._curLvList
  local maxLvVal = self._curLvList[curLvListSize]
  colorName, color = self:GetLvColorByLv(maxLvVal)
  GUIUtils.SetText(lblMaxLv, txtConst.CardsTuJian[3]:format(color, colorName))
end
def.method("number")._updateUIModelBgColor = function(self, lv)
  local uiSprite = self._uiGOs.groupRight:FindDirect("Group_Head/Img_CardLevel"):GetComponent("UISprite")
  uiSprite:set_spriteName(Cls.Level_Frame[lv])
  uiSprite = self._uiGOs.groupRight:FindDirect("Group_Head/Img_CardLevelTitle"):GetComponent("UISprite")
  uiSprite:set_spriteName(Cls.Level_Title[lv])
end
def.method()._initUICardsList = function(self)
  local cardList = self._selTypesCards
  local listCount = #cardList
  local ctrlScrollView = self._uiGOs.groupLeft:FindDirect("Group_List/ScrollView_List")
  local ctrlUIList = ctrlScrollView:FindDirect("List")
  local ctrlCardsList = GUIUtils.InitUIList(ctrlUIList, listCount)
  for i = 1, listCount do
    self:_fillCardsInfo(ctrlCardsList[i], cardList[i], i)
  end
  if self._uiStatus.selCardIdx > #self._selTypesCards then
    self._uiStatus.selCardIdx = 1
  end
  local ctrlItem = ctrlCardsList[self._uiStatus.selCardIdx]
  if ctrlItem then
    ctrlItem:GetComponent("UIToggle").value = true
  end
  local comScrollView = ctrlScrollView:GetComponent("UIScrollView")
  _G.GameUtil.AddGlobalTimer(0.1, true, function()
    comScrollView:DragToMakeVisible(ctrlItem.transform, 1280)
  end)
end
def.method("userdata", "table", "number")._fillCardsInfo = function(self, ctrl, cardCfg, idx)
  local icon = ctrl:FindDirect("Icon_" .. idx)
  local lblPowerLv = ctrl:FindDirect("Label_PowerLv_" .. idx)
  local imgType = ctrl:FindDirect("Img_Tpye_" .. idx)
  GUIUtils.FillIcon(icon:GetComponent("UITexture"), cardCfg.iconId)
  local turnedCardInterface = TurnedCardInterface.Instance()
  GUIUtils.SetText(lblPowerLv, turnedCardInterface:getTurnedCardQualityStr(cardCfg.quality))
  local classCfg = TurnedCardUtils.GetCardClassCfg(cardCfg.classType)
  GUIUtils.FillIcon(imgType:GetComponent("UITexture"), classCfg.smallIconId)
end
def.method()._initClsDropdownList = function(self)
  if self._clsList == nil then
    self._clsList = self:ExtractClsList(self._allTypeCards)
  end
  local clsList = self._clsList
  local listCount = #clsList
  self:_resizeGridItemList(listCount)
  for i = 1, listCount do
    local gridItem = self._uiGOs.uiGrid:FindDirect("Btn_Type_" .. i)
    local lblName = gridItem:FindDirect("Label_Name")
    if clsList[i].classType == 0 then
      GUIUtils.SetText(lblName, txtConst.CardsTuJian[1])
    else
      local cardClsCfg = TurnedCardUtils.GetCardClassCfg(clsList[i].classType)
      GUIUtils.SetText(lblName, cardClsCfg.className)
    end
  end
end
local Vector = require("Types.Vector3")
def.method("number")._resizeGridItemList = function(self, listCount)
  local ctrlScrollView = self._uiGOs.groupLeft:FindDirect("Btn_SkillChoose/Group_Zone/Group_ChooseType")
  local ctrlGrid = ctrlScrollView:FindDirect("Grid")
  self._uiGOs.uiGrid = ctrlGrid
  local comUIGrid = ctrlGrid:GetComponent("UIGrid")
  local gridItemCount = comUIGrid:GetChildListCount()
  if listCount > gridItemCount then
    for i = gridItemCount + 1, listCount do
      local gridItem = GameObject.Instantiate(self._uiGOs.gridItemTemplate)
      gridItem.name = "Btn_Type_" .. i
      gridItem.transform.parent = ctrlGrid.transform
      gridItem.transform.localScale = Vector.Vector3.one
      gridItem:SetActive(true)
    end
  elseif listCount < gridItemCount then
    for i = gridItemCount, count + 1, -1 do
      local gridItem = ctrlGrid:FindDirect("Btn_Type_" .. i)
      if not _G.IsNil(gridItem) then
        gridItem.transform.parent = nil
        GameObject.Destroy(gridItem)
      end
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  comUIGrid:Reposition()
end
def.method()._initLvDropdownList = function(self)
  local lvList = self._curLvList
  local listCount = #lvList
  self:_resizeLvGridItemList(listCount)
  for i = 1, listCount do
    local gridItem = self._uiGOs.lvUIgrid:FindDirect("Btn_Lv_" .. i)
    local lblName = gridItem:FindDirect("Label_Name")
    local lv2Color, _ = self:GetLvColorByLv(self._curLvList[i])
    GUIUtils.SetText(lblName, lv2Color)
  end
end
def.method("number")._resizeLvGridItemList = function(self, listCount)
  local ctrlScrollView = self._uiGOs.groupRight:FindDirect("Group_Title/Btn_CardChoose/Group_Zone/Group_ChooseType")
  local ctrlGrid = ctrlScrollView:FindDirect("Grid")
  self._uiGOs.lvUIgrid = ctrlGrid
  local comUIGrid = ctrlGrid:GetComponent("UIGrid")
  local gridItemCount = comUIGrid:GetChildListCount()
  if listCount > gridItemCount then
    for i = gridItemCount + 1, listCount do
      local gridItem = GameObject.Instantiate(self._uiGOs.gridLvItemTemplate)
      gridItem.name = "Btn_Lv_" .. i
      gridItem.transform.parent = ctrlGrid.transform
      gridItem.transform.localScale = Vector.Vector3.one
      gridItem:SetActive(true)
    end
  elseif listCount < gridItemCount then
    for i = gridItemCount, listCount + 1, -1 do
      local gridItem = ctrlGrid:FindDirect("Btn_Lv_" .. i)
      gridItem.transform.parent = nil
      GameObject.Destroy(gridItem)
    end
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
  comUIGrid:Reposition()
end
def.method("number")._updateCardModel = function(self, changeModelId)
  if self._uiModel == nil then
    local Model_Card = self.m_panel:FindDirect("Img _Bg0/Img_BSK/Group_Right/Group_Head/Model_Card")
    local uiModel = Model_Card:GetComponent("UIModel")
    uiModel.mCanOverflow = true
    self._uiModel = UIModelWrap.new(uiModel)
  end
  local changeModelCfg = _G.GetModelChangeCfg(changeModelId)
  local modelId = changeModelCfg.modelId
  local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
  local headidx = DynamicRecord.GetIntValue(modelinfo, "halfBodyIconId")
  local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, headidx)
  if iconRecord == nil then
    warn("Icon res get nil record for id: ", headidx)
    return
  end
  local resourceType = iconRecord:GetIntValue("iconType")
  if resourceType == 1 then
    local resourcePath = iconRecord:GetStringValue("path")
    if resourcePath and resourcePath ~= "" then
      self._uiModel:Load(resourcePath .. ".u3dext")
    else
      warn(" resourcePath == \"\" iconId = " .. headidx)
    end
  end
end
def.method("table")._updateUIPropList = function(self, curLevelCfg)
  local Group_Table = self._uiGOs.groupRight:FindDirect("Group_Table")
  local propertys = curLevelCfg.propertys
  for i = 1, 5 do
    local Img_Attribute = Group_Table:FindDirect(string.format("Img_Attribute%02d", i))
    if Img_Attribute then
      local Label_Attribute = Img_Attribute:FindDirect(string.format("Label_Attribute%02d", i))
      local Label_AttributeNum = Img_Attribute:FindDirect(string.format("Label_AttributeNum%02d", i))
      local curProperty = propertys[i]
      Img_Attribute:SetActive(curProperty ~= nil)
      if curProperty then
        local propertyCfg = _G.GetCommonPropNameCfg(curProperty.propType)
        Label_Attribute:SetActive(propertyCfg ~= nil)
        Label_AttributeNum:SetActive(propertyCfg ~= nil)
        if propertyCfg ~= nil then
          Label_Attribute:GetComponent("UILabel"):set_text(propertyCfg.propName .. ":")
          if propertyCfg.valueType == ProValueType.TEN_THOUSAND_RATE then
            Label_AttributeNum:GetComponent("UILabel"):set_text("+" .. curProperty.value / 100 .. "%")
          else
            Label_AttributeNum:GetComponent("UILabel"):set_text("+" .. curProperty.value)
          end
        end
      else
        Label_Attribute:GetComponent("UILabel"):set_text("")
        Label_AttributeNum:GetComponent("UILabel"):set_text("")
      end
    end
  end
  Group_Table:GetComponent("UITable"):Reposition()
end
def.method("table")._updateUIGameValue = function(self, curClsLvCfg)
  local damageAddRates = curClsLvCfg.damageAddRates
  local sealAddRates = curClsLvCfg.sealAddRates
  local Group_Good = self._uiGOs.groupRight:FindDirect("Group_Table")
  for i = 1, 3 do
    local Group_Att = Group_Good:FindDirect("Group_AttKe0" .. i)
    local Img_Tpye = Group_Att:FindDirect("Img_Tpye")
    local Label_Att = Group_Att:FindDirect("Label_Att")
    local damageAdd = damageAddRates[i]
    if damageAdd then
      Group_Att:SetActive(true)
      local classCfg = TurnedCardUtils.GetCardClassCfg(damageAdd.classType)
      GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
      local sealValue = sealAddRates[damageAdd.classType]
      local sealStr = ""
      if sealValue and sealValue > 0 then
        sealStr = "\n" .. textRes.TurnedCard[28] .. " +" .. sealValue / 100 .. "%"
      end
      Label_Att:GetComponent("UILabel"):set_text(textRes.TurnedCard[6] .. " +" .. damageAdd.value * 0.01 .. "%" .. sealStr)
    else
      Group_Att:SetActive(false)
    end
  end
  local Group_Bad = self._uiGOs.groupRight:FindDirect("Group_Table/Group_AttBeiKe")
  local beRestrictedClasses = curClsLvCfg.beRestrictedClasses
  for i = 1, 2 do
    local Img_Tpye = Group_Bad:FindDirect("Img_AttBeiKeTpye0" .. i)
    local beRestrictedClass = beRestrictedClasses[i]
    if beRestrictedClass then
      Img_Tpye:SetActive(true)
      local classCfg = TurnedCardUtils.GetCardClassCfg(beRestrictedClass)
      GUIUtils.FillIcon(Img_Tpye:GetComponent("UITexture"), classCfg.smallIconId)
    else
      Img_Tpye:SetActive(false)
    end
  end
end
def.method("table", "table")._updateUIBottom = function(self, cardCfg, curLevelCfg)
  local groupAttr = self._uiGOs.groupRight:FindDirect("Group_BaseAtt")
  local lblMinLv = groupAttr:FindDirect("Group_Level/Label_Num")
  local lblCost = groupAttr:FindDirect("Group_Cost/Label_Num")
  local lblProp0 = groupAttr:FindDirect("Label_Att01")
  local lblProp1 = groupAttr:FindDirect("Label_Att02")
  local lblUsedTime = groupAttr:FindDirect("Group_Time/Label_Num")
  GUIUtils.SetText(lblMinLv, cardCfg.useLevel)
  GUIUtils.SetText(lblCost, curLevelCfg.useCostEssence)
  GUIUtils.SetText(lblProp0, txtConst[4]:format(curLevelCfg.effectPersistMinute))
  GUIUtils.SetText(lblProp1, txtConst[5]:format(curLevelCfg.effectPersistPVPFight))
  if curLevelCfg.useCount < 0 then
    GUIUtils.SetText(lblUsedTime, textRes.TurnedCard[24])
  else
    GUIUtils.SetText(lblUsedTime, curLevelCfg.useCount)
  end
  local lblPowerLv = self._uiGOs.groupRight:FindDirect("Group_Head/Label_PowerLv")
  local turnedCardInterface = TurnedCardInterface.Instance()
  GUIUtils.SetText(lblPowerLv, turnedCardInterface:getTurnedCardQualityStr(cardCfg.quality))
end
def.method("=>", "table").GetSelectCardCfg = function(self)
  return self._selTypesCards[self._uiStatus.selCardIdx]
end
def.method("table", "=>", "table").GetSelectCardLvCfg = function(self, cardCfg)
  if cardCfg == nil then
    return nil
  end
  local cardLvCfg = TurnedCardUtils.GetCardLevelCfg(cardCfg.id)
  return cardLvCfg.cardLevels[self._uiStatus.selLv]
end
def.method("table", "=>", "table").GetSelectClsLvCfg = function(self, cardCfg)
  if cardCfg == nil then
    return nil
  end
  local classLevelCfg = TurnedCardUtils.GetClassLevelCfg(cardCfg.classType)
  return classLevelCfg.classLevels[self._uiStatus.selLv]
end
def.method("table", "=>", "table").ExtractClsList = function(self, typesList)
  if typesList == nil then
    return nil
  end
  local clsTypeList = {
    {classType = 0, cardName = ""}
  }
  for i = 1, #typesList do
    local bExist = false
    for j = 1, #clsTypeList do
      if clsTypeList[j].classType == typesList[i].classType then
        bExist = true
        break
      end
    end
    if not bExist then
      local classCfg = TurnedCardUtils.GetCardClassCfg(typesList[i].classType)
      table.insert(clsTypeList, {
        classType = typesList[i].classType,
        cardName = classCfg.className
      })
    end
  end
  return clsTypeList
end
def.method("number", "=>", "string", "string").GetLvColorByLv = function(self, lv)
  return txtConst.CardsTuJian[2]:format(txtConst.colorName[lv]), txtConst.levelColor[lv]
end
local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
local IDIPInterface = require("Main.IDIP.IDIPInterface")
def.method("=>", "table").GetCardList = function(self)
  local allCards = TurnedCardUtils.LoadAllTypeCardsCfg()
  local retData = {}
  for i = 1, #allCards do
    local bOpen = IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.CHANGE_MODEL_CARD, allCards[i].id)
    if bOpen then
      table.insert(retData, allCards[i])
    end
  end
  return retData
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TURNCARD_TUJIAN, 1)
  self:SetModal(true)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local bShowCls, bShowLv = false, false
  if string.find(id, "Item_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[2])
    self:onClickCardItem(idx)
  elseif "Btn_Close" == id then
    self:DestroyPanel()
    return
  elseif "Btn_SkillChoose" == id then
    bShowCls = clickObj:GetComponent("UIToggleEx").value
  elseif "Btn_CardChoose" == id then
    bShowLv = clickObj:GetComponent("UIToggleEx").value
  elseif string.find(id, "Btn_Type_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onSelectCls(idx)
  elseif string.find(id, "Btn_Lv_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:onSelectCardLv(idx)
  elseif "Btn_AttHelp" == id then
    self:onShowHelpTips()
  elseif "Btn_Get" == id then
    local selCardCfg = self:GetSelectCardCfg()
    local selLvCfg = self:GetSelectCardLvCfg(selCardCfg)
    local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(selLvCfg.unlockItemId, clickObj, 0, true)
  end
  self:ToggleClsDropdownList(bShowCls)
  self:ToggleLvDropdownList(bShowLv)
end
def.method("number").onClickCardItem = function(self, idx)
  if self._uiStatus.selCardIdx == idx then
    return
  end
  self._uiStatus.selCardIdx = idx
  self._uiStatus.selLvIdx = 1
  self:_updateUI()
end
def.method("boolean").ToggleClsDropdownList = function(self, bShow)
  local btnSkillChoose = self._uiGOs.groupLeft:FindDirect("Btn_SkillChoose")
  local groupZone = btnSkillChoose:FindDirect("Group_Zone")
  btnSkillChoose:GetComponent("UIToggleEx").value = bShow
  groupZone:SetActive(bShow)
  if bShow then
    self:_initClsDropdownList()
  end
end
def.method("boolean").ToggleLvDropdownList = function(self, bShow)
  local btnLvChoose = self._uiGOs.groupRight:FindDirect("Group_Title/Btn_CardChoose")
  local groupZone = btnLvChoose:FindDirect("Group_Zone")
  btnLvChoose:GetComponent("UIToggleEx").value = bShow
  groupZone:SetActive(bShow)
  if bShow then
    self:_initLvDropdownList()
  end
end
def.method("number").onSelectCls = function(self, idx)
  local classType = self._clsList[idx].classType
  local lblCardName = self._uiGOs.groupLeft:FindDirect("Btn_SkillChoose/Label_Btn")
  if classType ~= 0 then
    self._selTypesCards = {}
    for i = 1, #self._allTypeCards do
      local cardCfg = self._allTypeCards[i]
      if cardCfg.classType == classType then
        table.insert(self._selTypesCards, cardCfg)
      end
    end
    GUIUtils.SetText(lblCardName, self._clsList[idx].cardName)
  else
    self._selTypesCards = self._allTypeCards
    GUIUtils.SetText(lblCardName, txtConst.CardsTuJian[1])
  end
  self:SortSelectTypeCards()
  self._uiStatus.selLvIdx = 1
  self._uiStatus.selCardIdx = 1
  self:_updateUI()
end
def.method().SortSelectTypeCards = function(self)
  local retData = self._selTypesCards
  table.sort(retData, function(a, b)
    if a.classType < b.classType then
      return true
    elseif a.classType > b.classType then
      return false
    elseif a.quality < b.quality then
      return true
    else
      return false
    end
  end)
end
def.method("number").onSelectCardLv = function(self, idx)
  self._uiStatus.selLvIdx = idx
  self._uiStatus.selLv = self._curLvList[idx]
  self:_updateUIRight()
end
def.method().onShowHelpTips = function(self)
  local TurnedCardRestraintRelationship = require("Main.TurnedCard.ui.TurnedCardRestraintRelationship")
  local selCardCfg = self:GetSelectCardCfg()
  if selCardCfg then
    TurnedCardRestraintRelationship.Instance():ShowPanelByClass(selCardCfg.classType)
  else
    TurnedCardRestraintRelationship.Instance():ShowPanel()
  end
end
def.method("table").OnIDIPInfoChg = function(self, p)
  if ItemSwitchInfo.CHANGE_MODEL_CARD == p.type then
    self._allTypeCards = self:GetCardList()
    self:_updateUI()
  end
end
return Cls.Commit()
