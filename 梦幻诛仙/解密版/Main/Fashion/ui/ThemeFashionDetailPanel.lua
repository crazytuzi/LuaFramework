local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ThemeFashionDetailPanel = Lplus.Extend(ECPanelBase, "ThemeFashionDetailPanel")
local FashionUtils = require("Main.Fashion.FashionUtils")
local Vector3 = require("Types.Vector3").Vector3
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local FashionData = require("Main.Fashion.FashionData")
local FashionDressUnLockConditionEnum = require("consts.mzm.gsp.fashiondress.confbean.FashionDressUnLockConditionEnum")
local def = ThemeFashionDetailPanel.define
local instance
def.field("table").themeFashion = nil
def.field("table").uiObjs = nil
def.field(ECUIModel).fashionModel = nil
def.field("boolean").isDrag = false
def.field("number").selectedIdx = 1
def.field("boolean").isShowFashionModel = true
def.field("table").sortedThemeFashion = nil
def.static("=>", ThemeFashionDetailPanel).Instance = function()
  if instance == nil then
    instance = ThemeFashionDetailPanel()
  end
  return instance
end
def.method("table").ShowPanelWithThemeFashion = function(self, themeFashion)
  if self.m_panel == nil then
    self.themeFashion = themeFashion
    self:CreatePanel(RESPATH.PREFAB_THEME_FASHION_DETAIL_PANEL, 1)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:FillBasicInfo()
  self:FillFashionItems()
  self:ChooseFashionItem(1)
  self:UpdateLimitedThemeFashionInfo()
  self:SetThemeFashionViewed()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ThemeFashionDetailPanel.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ThemeFashionDetailPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.ThemeFashionChanged, ThemeFashionDetailPanel.OnThemeFashionChanged)
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, ThemeFashionDetailPanel.OnFashionNotifyChanged)
end
def.override().OnDestroy = function(self)
  self.themeFashion = nil
  self.uiObjs = nil
  self.isDrag = false
  self.selectedIdx = 1
  self.isShowFashionModel = true
  self.sortedThemeFashion = nil
  if self.fashionModel ~= nil then
    self.fashionModel:Destroy()
    self.fashionModel = nil
  end
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ThemeFashionDetailPanel.OnFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ThemeFashionDetailPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.ThemeFashionChanged, ThemeFashionDetailPanel.OnThemeFashionChanged)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, ThemeFashionDetailPanel.OnFashionNotifyChanged)
end
def.override("boolean").OnShow = function(self, s)
  if not s then
    if self.uiObjs == nil then
      return
    end
    local List_Prize = self.uiObjs.Group_Fashion:FindDirect("Group_Left/GameObject/Scroll View_Prize/List_Prize")
    local uiList = List_Prize:GetComponent("UIList")
    local uiItems = uiList.children
    for i = #uiItems, 1, -1 do
      local item = uiItems[i]
      local Fx = item:FindDirect("Fx")
      GUIUtils.SetActive(Fx, false)
    end
  elseif self.fashionModel ~= nil then
    self.fashionModel:Play(ActionName.Stand)
  end
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Title = self.uiObjs.Img_Bg0:FindDirect("Img_Title/Label_Title/Label_Name")
  self.uiObjs.MonthTheme = self.uiObjs.Img_Bg0:FindDirect("MonthTheme")
  self.uiObjs.Group_Open = self.uiObjs.MonthTheme:FindDirect("Group_Open")
  self.uiObjs.Group_Close = self.uiObjs.MonthTheme:FindDirect("Group_Close")
  self.uiObjs.Group_Fashion = self.uiObjs.Img_Bg0:FindDirect("Group_Fashion")
end
def.method().FillBasicInfo = function(self)
  GUIUtils.SetText(self.uiObjs.Label_Title, self.themeFashion.fashionDressName)
  local curUnlockNum = 0
  local totalNum = #self.themeFashion.relatedFashionType
  for i = 1, totalNum do
    local fashionType = self.themeFashion.relatedFashionType[i]
    if FashionData.Instance():IsThemeFashionUnlock(fashionType) then
      curUnlockNum = curUnlockNum + 1
    end
  end
  local Slider_Unlock = self.uiObjs.Group_Fashion:FindDirect("Group_Left/Slider_Unlock")
  local Label_Proportion = Slider_Unlock:FindDirect("Label_Proportion")
  GUIUtils.SetText(Label_Proportion, string.format("%d/%d", curUnlockNum, totalNum))
  GUIUtils.SetProgress(Slider_Unlock, GUIUtils.COTYPE.SLIDER, curUnlockNum / totalNum)
  local awards = FashionUtils.GetTheFashionAwardById(self.themeFashion.id)
  local List_Prize = self.uiObjs.Group_Fashion:FindDirect("Group_Left/GameObject/Scroll View_Prize/List_Prize")
  local uiList = List_Prize:GetComponent("UIList")
  uiList.itemCount = #awards
  uiList:Resize()
  local uiItems = uiList.children
  local activeAward = false
  for i = #uiItems, 1, -1 do
    do
      local item = uiItems[i]
      local Label_ClothNum = item:FindDirect("Label_ClothNum")
      local Label_Buff = item:FindDirect("Label_Buff1")
      GUIUtils.SetActive(Label_Buff, false)
      GUIUtils.SetText(Label_ClothNum, awards[i].desc)
      Label_ClothNum:GetComponent("UILabel").textColor = Color.gray
      local Fx = item:FindDirect("Fx")
      GUIUtils.SetActive(Fx, false)
      if not activeAward and curUnlockNum >= awards[i].unlockFashionNum then
        Label_ClothNum:GetComponent("UILabel").textColor = Color.Color(0, 0.54, 0.27)
        activeAward = true
        do
          local FashionModule = require("Main.Fashion.FashionModule")
          local isNeedFx = FashionModule.Instance():IsThemeFashionHasAwardNotify(self.themeFashion.id)
          GameUtil.AddGlobalTimer(0.5, true, function()
            if self.uiObjs == nil then
              return
            end
            GUIUtils.SetActive(Fx, isNeedFx)
          end)
        end
      end
    end
  end
end
def.method().FillFashionItems = function(self)
  local Bg_Item = self.uiObjs.Group_Fashion:FindDirect("Bg_Item")
  local ScrollView_Item = Bg_Item:FindDirect("Scroll View_Item")
  local Grid_Item = ScrollView_Item:FindDirect("Grid_Item")
  local itemTemplate = Grid_Item:FindDirect("Item1")
  local itemObjParent = Grid_Item
  local itemCount = #self.themeFashion.relatedFashionType
  local uiGrid = itemObjParent:GetComponent("UIGrid")
  local unlockTheme = {}
  local lockedTheme = {}
  for i = 1, itemCount do
    local isUnlock = FashionData.Instance():IsThemeFashionUnlock(self.themeFashion.relatedFashionType[i])
    local themeInfo = {}
    themeInfo.relatedType = self.themeFashion.relatedFashionType[i]
    if isUnlock then
      themeInfo.isUnlock = true
      table.insert(unlockTheme, themeInfo)
    else
      themeInfo.isUnlock = false
      table.insert(lockedTheme, themeInfo)
    end
  end
  self.sortedThemeFashion = {}
  for i = 1, #unlockTheme do
    table.insert(self.sortedThemeFashion, unlockTheme[i])
  end
  for i = 1, #lockedTheme do
    table.insert(self.sortedThemeFashion, lockedTheme[i])
  end
  for i = 1, itemCount do
    local themeInfo = self.sortedThemeFashion[i]
    local unlockCfg = FashionUtils.GetThemeFashionUnlockCfgByTypeId(themeInfo.relatedType)
    if unlockCfg ~= nil then
      local showFashionType = unlockCfg.fashionType[1] or -1
      if showFashionType == -1 then
        warn(("theme fashion related fashion type is empty(%d,%d)"):format(self.themeFashion.id, themeInfo.relatedType))
      else
        local item = FashionUtils.GetFashionItemByFashionType(showFashionType)
        local itemObj = itemObjParent:FindDirect("Item" .. i)
        if itemObj == nil then
          itemObj = GameObject.Instantiate(itemTemplate)
          itemObj.name = "Item" .. i
          uiGrid:AddChild(itemObj.transform)
          itemObj.transform.localScale = Vector3.one
        end
        local itemIcon = itemObj:FindDirect("Img_Icon")
        local uiTexture = itemIcon:GetComponent("UITexture")
        GUIUtils.FillIcon(uiTexture, item.iconId)
        local lockIcon = itemObj:FindDirect("Sprite")
        if themeInfo.isUnlock then
          lockIcon:SetActive(false)
          GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
        else
          lockIcon:SetActive(true)
          GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
        end
        local Img_New = itemObj:FindDirect("Img_New")
        GUIUtils.SetActive(Img_New, false)
        local Img_Try = itemObj:FindDirect("Img_Try")
        GUIUtils.SetActive(Img_Try, false)
        local Img_Fit = itemObj:FindDirect("Img_Fit")
        GUIUtils.SetActive(Img_Fit, false)
        if i == self.selectedIdx then
          itemObj:GetComponent("UIToggle").value = true
        else
          itemObj:GetComponent("UIToggle").value = false
        end
      end
    end
  end
end
def.method().FillUnlockItemInfo = function(self)
  local Group_Item = self.uiObjs.Group_Fashion:FindDirect("Group_Item")
  local Label_Warn = self.uiObjs.Group_Fashion:FindDirect("Label_Warn")
  local themeInfo = self.sortedThemeFashion[self.selectedIdx]
  if themeInfo == nil then
    GUIUtils.SetActive(Group_Item, false)
    GUIUtils.SetActive(Label_Warn, false)
    return
  end
  local unlockCfg = FashionUtils.GetThemeFashionUnlockCfgByTypeId(themeInfo.relatedType)
  if unlockCfg == nil then
    GUIUtils.SetActive(Group_Item, false)
    GUIUtils.SetActive(Label_Warn, false)
    return
  end
  local isUnlock = FashionData.Instance():IsThemeFashionUnlock(themeInfo.relatedType)
  if isUnlock then
    GUIUtils.SetActive(Group_Item, false)
    GUIUtils.SetActive(Label_Warn, true)
    GUIUtils.SetText(Label_Warn, unlockCfg.description)
  else
    local showfashionItem
    local itemData = require("Main.Item.ItemData").Instance()
    local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
    for i = 1, #unlockCfg.fashionType do
      local fashionType = unlockCfg.fashionType[i]
      local fashionItem = FashionUtils.GetFashionItemByFashionType(fashionType)
      local currentItemCount = itemData:GetNumberByItemId(BagInfo.BAG, fashionItem.costItemId)
      if i == 1 then
        showfashionItem = fashionItem
      end
      if currentItemCount > 0 then
        showfashionItem = fashionItem
        break
      end
    end
    if showfashionItem == -1 then
      GUIUtils.SetActive(Label_Warn, false)
      warn(("theme fashion related fashion type is empty(%d,%d)"):format(self.themeFashion.id, self.themeFashion.relatedFashionType[i]))
      return
    end
    GUIUtils.SetActive(Group_Item, true)
    GUIUtils.SetActive(Label_Warn, false)
    local Label_Name = Group_Item:FindDirect("Label_Name")
    local Label_Num = Group_Item:FindDirect("Label_Num")
    local Bg_Item = Group_Item:FindDirect("Bg_Item")
    local Img_Icon = Bg_Item:FindDirect("Img_Icon")
    local unlockCondition = FashionUtils.GetFashionUnlockConditionById(showfashionItem.unlockConditionId)
    if unlockCondition.conditionType == FashionDressUnLockConditionEnum.ITEM then
      GUIUtils.SetActive(Group_Item, true)
      GUIUtils.SetActive(Label_Warn, false)
      local unlockItem = ItemUtils.GetItemBase(showfashionItem.costItemId)
      local uiTexture = Img_Icon:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, unlockItem.icon)
      GUIUtils.SetText(Label_Name, unlockItem.name)
      local itemData = require("Main.Item.ItemData").Instance()
      local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
      local currentItemCount = itemData:GetNumberByItemId(BagInfo.BAG, showfashionItem.costItemId)
      GUIUtils.SetText(Label_Num, string.format("%d/%d", currentItemCount, showfashionItem.costItemNum))
      local itemTag = Group_Item:GetComponent("UILabel")
      if itemTag == nil then
        itemTag = Group_Item:AddComponent("UILabel")
        itemTag.enabled = false
      end
      itemTag.text = showfashionItem.costItemId
    else
      GUIUtils.SetActive(Group_Item, false)
      GUIUtils.SetActive(Label_Warn, true)
      GUIUtils.SetText(Label_Warn, unlockCondition.conditionDesc)
    end
  end
end
def.method("number").ChooseFashionItem = function(self, idx)
  self.selectedIdx = idx
  self.isShowFashionModel = true
  self:FillUnlockItemInfo()
  self:ShowFashionModel()
end
def.method().ShowFashionModel = function(self)
  local themeInfo = self.sortedThemeFashion[self.selectedIdx]
  if themeInfo == nil then
    return
  end
  local unlockCfg = FashionUtils.GetThemeFashionUnlockCfgByTypeId(themeInfo.relatedType)
  if unlockCfg == nil then
    return
  end
  local fashionType = unlockCfg.fashionType[1] or -1
  local fashionItem = FashionUtils.GetFashionItemByFashionType(fashionType)
  if fashionItem == nil then
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
  local Model = self.uiObjs.Group_Fashion:FindDirect("Group_Left/Model")
  local uiModel = Model:GetComponent("UIModel")
  if self.fashionModel ~= nil then
    self.fashionModel:Destroy()
    self.fashionModel = nil
  end
  self.fashionModel = ECUIModel.new(modelId)
  self.fashionModel:AddOnLoadCallback("theme_fashion", function()
    uiModel.modelGameObject = self.fashionModel.m_model
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      camera:set_orthographic(true)
    end
  end)
  self.fashionModel.m_bUncache = true
  local modelInfo = self:GetThemeFashionModelInfo(fashionType)
  _G.LoadModel(self.fashionModel, modelInfo, 0, 0, 180, false, false)
end
def.method("number", "=>", "table").GetThemeFashionModelInfo = function(self, fashionType)
  local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  if modelInfo == nil then
    return nil
  end
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  local fakeModelInfo = _G.CloneModelInfo(modelInfo)
  fakeModelInfo.extraMap[ModelInfo.EXTERIOR_ID] = 0
  if self.isShowFashionModel then
    local fashion = FashionUtils.GetFashionItemByFashionType(fashionType)
    if fashion ~= nil then
      local dyeColor = FashionUtils.GetFashionDyeColor(fashion.id)
      fakeModelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = fashion.id
      fakeModelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = dyeColor.hairId
      fakeModelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = dyeColor.clothId
    end
  else
    fakeModelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = 0
    fakeModelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = 0
    fakeModelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = 0
  end
  return fakeModelInfo
end
def.method("number").UnlockFashionItem = function(self, itemId)
  local fashionItem = FashionUtils.GetFashionItemByUnlockItemId(itemId)
  if fashionItem ~= nil then
    local FashionModule = require("Main.Fashion.FashionModule")
    if not FashionModule.Instance():IsFashionIDIPOpen(fashionItem.fashionDressType) then
      Toast(textRes.Fashion[43])
      return
    end
    local unlockCondition = FashionUtils.GetFashionUnlockConditionById(fashionItem.unlockConditionId)
    if unlockCondition.conditionType == FashionDressUnLockConditionEnum.ITEM then
      local itemData = require("Main.Item.ItemData").Instance()
      local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
      local currentItemCount = itemData:GetNumberByItemId(BagInfo.BAG, fashionItem.costItemId)
      if currentItemCount >= fashionItem.costItemNum then
        local FashionPanel = require("Main.Fashion.ui.FashionPanel")
        self:DestroyPanel()
        FashionPanel.Instance():ShowFashionPanelWithCfgId(fashionItem.id)
      else
        Toast(textRes.Fashion[15])
      end
    end
  end
end
def.method().UpdateLimitedThemeFashionInfo = function(self)
  local limitedCfg, period = FashionUtils.GetNowLimitedThemeFashionCfg()
  local themeFashionCfg = FashionUtils.GetThemeFashionCfgById(limitedCfg and limitedCfg.theme_fashion_dress_cfg_id or 0)
  local isOpen = _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_TIME_LIMITED_THEME_FASHION_DRESS)
  if themeFashionCfg == nil or limitedCfg == nil or not isOpen then
    GUIUtils.SetActive(self.uiObjs.Group_Open, false)
    GUIUtils.SetActive(self.uiObjs.Group_Close, true)
  else
    GUIUtils.SetActive(self.uiObjs.Group_Open, true)
    GUIUtils.SetActive(self.uiObjs.Group_Close, false)
    local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
    local timeLimitCommonCfg = TimeCfgUtils.GetTimeLimitCommonCfg(limitedCfg.time_limit_cfg_id)
    local Label = self.uiObjs.Group_Open:FindDirect("Label")
    local Img_BgTitle = self.uiObjs.Group_Open:FindDirect("Img_BgTitle")
    local Label_Buff_Month = self.uiObjs.Group_Open:FindDirect("Label_Buff_Month")
    local curbuffCfg = require("Main.Buff.BuffUtility").GetBuffCfg(limitedCfg.buff_cfg_id)
    GUIUtils.FillIcon(Img_BgTitle:GetComponent("UITexture"), limitedCfg.icon_id)
    GUIUtils.SetText(Label_Buff_Month, "")
    GUIUtils.SetText(Label, string.format(textRes.Fashion[45], themeFashionCfg.fashionDressName, curbuffCfg.desc))
  end
end
def.method().SetThemeFashionViewed = function(self)
  local FashionModule = require("Main.Fashion.FashionModule")
  FashionModule.Instance():SetThemeFashionFullUnlockNotify(self.themeFashion.id, false)
  FashionModule.Instance():RemoveThemeFashionAwardNotify(self.themeFashion.id)
  local curCfg = FashionUtils.GetNowLimitedThemeFashionCfg()
  local curThemeId = curCfg and curCfg.theme_fashion_dress_cfg_id or 0
  local curCfgId = curCfg and curCfg.id or 0
  if self.themeFashion.id == curThemeId then
    FashionModule.Instance():SetLimitedThemeFashionNotify(false)
    FashionModule.Instance():SetLastLimitedThemeFashionCfgData(curCfgId)
  end
  Event.DispatchEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, nil)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_UnLock" then
    self:OnClickBtnUnlock(obj)
  elseif id == "Bg_Item" then
    self:OnClickUnlockItem(obj)
  elseif string.find(id, "Item") then
    local idx = tonumber(string.sub(id, #"Item" + 1))
    self:OnClickFashionItem(idx, obj)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_ReSet" then
    self:OnToggleModel()
  end
end
def.method("number", "userdata").OnClickFashionItem = function(self, idx, obj)
  local uiToggle = obj:GetComponent("UIToggle")
  if uiToggle ~= nil then
    uiToggle.value = true
  end
  self:ChooseFashionItem(idx)
end
def.method().OnToggleModel = function(self)
  self.isShowFashionModel = not self.isShowFashionModel
  self:ShowFashionModel()
end
def.method("userdata").OnClickUnlockItem = function(self, obj)
  local Group_Item = self.uiObjs.Group_Fashion:FindDirect("Group_Item")
  local itemTag = Group_Item:GetComponent("UILabel")
  if itemTag ~= nil then
    local itemId = tonumber(itemTag.text)
    local position = obj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = obj:GetComponent("UIWidget")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x - sprite:get_width() * 0.5, screenPos.y + sprite:get_height() * 0.5, sprite:get_width(), 1, 0, true)
  end
end
def.method("userdata").OnClickBtnUnlock = function(self, Btn_UnLock)
  local Group_Item = self.uiObjs.Group_Fashion:FindDirect("Group_Item")
  local itemTag = Group_Item:GetComponent("UILabel")
  if itemTag ~= nil then
    local itemId = tonumber(itemTag.text)
    if itemId ~= nil then
      self:UnlockFashionItem(itemId)
    end
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self.fashionModel ~= nil then
    local model = self.fashionModel
    if model then
      model:SetDir(model.m_ang - dx / 2)
    end
  end
end
def.static("table", "table").OnFunctionOpenChange = function(params, context)
  local self = instance
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_THEME_FASHION_DRESS and not params.open then
    Toast(textRes.Fashion[42])
    self:DestroyPanel()
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local self = instance
  self:FillUnlockItemInfo()
end
def.static("table", "table").OnThemeFashionChanged = function(params, context)
  local self = instance
  self:FillBasicInfo()
  self:FillFashionItems()
  self:FillUnlockItemInfo()
  self:ShowFashionModel()
end
def.static("table", "table").OnFashionNotifyChanged = function(params, context)
  local self = instance
  self:UpdateLimitedThemeFashionInfo()
end
return ThemeFashionDetailPanel.Commit()
