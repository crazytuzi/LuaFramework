local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local FashionNode = Lplus.Extend(TabNode, "FashionNode")
local FashionUtils = require("Main.Fashion.FashionUtils")
local Vector3 = require("Types.Vector3").Vector3
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local FashionDressUnLockConditionEnum = require("consts.mzm.gsp.fashiondress.confbean.FashionDressUnLockConditionEnum")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local FashionData = require("Main.Fashion.FashionData")
local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local FashionModule = Lplus.ForwardDeclare("FashionModule")
local FashionEffectPanel = require("Main.Fashion.ui.FashionEffectPanel")
local FashionDressConst = require("netio.protocol.mzm.gsp.fashiondress.FashionDressConst")
local def = FashionNode.define
def.const("number").MinGridCount = 25
def.field("table")._uiObjs = nil
def.field("userdata")._fashionItemTemplate = nil
def.field("table")._showFashionItemData = nil
def.field("number")._selectedItemIdx = 0
def.field("table")._model = nil
def.field("boolean")._isDrag = false
def.field("number")._initFashionCfgId = FashionDressConst.NO_FASHION_DRESS
def.field("number").tujianSelection = 0
local ViewType = {Own = 1, Tujian = 2}
def.field("number").currentView = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.method("=>", "boolean").IsShow = function(self)
  return self.isShow
end
def.override().OnShow = function(self)
  if self._uiObjs == nil then
    self:InitUI()
    self:SwitchToView(ViewType.Own)
  end
  Event.RegisterEventWithContext(ModuleId.FASHION, gmodule.notifyId.Fashion.UnlockFationItem, FashionNode._OnUnlockFationItem, self)
  Event.RegisterEventWithContext(ModuleId.FASHION, gmodule.notifyId.Fashion.DressFashionChanged, FashionNode._OnDressFashionChanged, self)
  Event.RegisterEventWithContext(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionExpired, FashionNode._OnFashionExpired, self)
  Event.RegisterEventWithContext(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionLeftTimeChange, FashionNode._OnFashionLeftTimeChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FashionNode._OnBagInfoSynchronized, self)
  Event.RegisterEventWithContext(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_COLOR_DATA, FashionNode._OnColorDataChanged, self)
  Event.RegisterEventWithContext(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionLoadFinished, FashionNode._OnLoadModel, self)
end
def.override().OnHide = function(self)
  self:_DestroyModel()
  self._uiObjs = nil
  self._fashionItemTemplate = nil
  self._showFashionItemData = nil
  self._selectedItemIdx = 0
  self._isDrag = false
  self.currentView = 0
  self.tujianSelection = 0
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.UnlockFationItem, FashionNode._OnUnlockFationItem)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.DressFashionChanged, FashionNode._OnDressFashionChanged)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionExpired, FashionNode._OnFashionExpired)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionLeftTimeChange, FashionNode._OnFashionLeftTimeChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, FashionNode._OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.UPDATE_COLOR_DATA, FashionNode._OnColorDataChanged)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionLoadFinished, FashionNode._OnLoadModel)
end
def.method()._DestroyModel = function(self)
  if self._model ~= nil then
    self._model:Destroy()
    self._model = nil
  end
end
def.method().InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.ScrollView_Item = self.m_node:FindDirect("Bg_Item/Scroll View_Item")
  self._uiObjs.Grid_Item = self._uiObjs.ScrollView_Item:FindDirect("Grid_Item")
  self._fashionItemTemplate = self._uiObjs.Grid_Item:FindDirect("Item1")
  self._uiObjs.Group_Left = self.m_node:FindDirect("Group_Left")
  self._uiObjs.Model = self._uiObjs.Group_Left:FindDirect("Model")
  self._uiObjs.Bg_Info = self._uiObjs.Group_Left:FindDirect("Bg_Info")
  self._uiObjs.ScrollView_Info = self._uiObjs.Bg_Info:FindDirect("Scroll View")
  self._uiObjs.Container_Info = self._uiObjs.ScrollView_Info:FindDirect("Container")
  self._uiObjs.Label_Name = self._uiObjs.Container_Info:FindDirect("Label_Name")
  self._uiObjs.Label_Time = self._uiObjs.Container_Info:FindDirect("Label_Time")
  self._uiObjs.Label_Info = self._uiObjs.Container_Info:FindDirect("Label_Info")
  self._uiObjs.Label_Effect = self._uiObjs.Container_Info:FindDirect("Label_Effect")
  self._uiObjs.Label_Skill = self._uiObjs.Container_Info:FindDirect("Label_Skill")
  self._uiObjs.Label_Condition = self.m_node:FindDirect("Label_Condition")
  self._uiObjs.Group_Item = self.m_node:FindDirect("Group_Item")
  self._uiObjs.ConditionItemName = self._uiObjs.Group_Item:FindDirect("Label_Name")
  self._uiObjs.ConditionItemNum = self._uiObjs.Group_Item:FindDirect("Label_Num")
  self._uiObjs.ConditionItem = self._uiObjs.Group_Item:FindDirect("Bg_Item")
  self._uiObjs.ConditionItemIcon = self._uiObjs.ConditionItem:FindDirect("Img_Icon")
  self._uiObjs.MainOperationBtn = self.m_node:FindDirect("Group_Btn/Btn_UnLock")
  self._uiObjs.Btn_Effect = self.m_node:FindDirect("Group_Btn/Panel/Btn_Effect")
  self._uiObjs.Label_Condition:SetActive(false)
  self._uiObjs.Group_Item:SetActive(false)
  self._uiObjs.MainOperationBtn:SetActive(false)
  self._uiObjs.Container_Info:GetComponent("UIWidget"):set_depth(0)
  self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):set_depth(1)
  if self._uiObjs.Label_Effect:GetComponent("BoxCollider") ~= nil then
    self._uiObjs.Label_Effect:GetComponent("BoxCollider"):set_enabled(false)
  end
  if self._fashionItemTemplate then
    self._fashionItemTemplate.name = "GridTemplate"
    GUIUtils.SetActive(self._fashionItemTemplate)
  else
    self._fashionItemTemplate = self._uiObjs.Grid_Item:FindDirect("GridTemplate")
  end
  self._uiObjs.Btn_Zone = self.m_node:FindDirect("Btn_Zone")
  self._uiObjs.Group_Zone = self._uiObjs.Btn_Zone:FindDirect("Group_Zone")
  self._uiObjs.Tab_Have = self.m_node:FindDirect("Tab_Have")
  self._uiObjs.Tab_Book = self.m_node:FindDirect("Tab_Book")
end
def.method("number").SwitchToView = function(self, view)
  if self.currentView == view then
    return
  end
  self.currentView = view
  self._selectedItemIdx = 0
  self.tujianSelection = 0
  self:UpdateFashionSelectionStatus()
  self:_UpdateFashionItems()
  self:_ShowFashionDefaultDetail()
end
def.method().UpdateFashionSelectionStatus = function(self)
  if self.currentView == ViewType.Own then
    GUIUtils.SetActive(self._uiObjs.Btn_Zone, false)
    GUIUtils.SetActive(self._uiObjs.Group_Zone, false)
    GUIUtils.Toggle(self._uiObjs.Tab_Have, true)
    GUIUtils.Toggle(self._uiObjs.Tab_Book, false)
  else
    GUIUtils.SetActive(self._uiObjs.Btn_Zone, true)
    local Label_Name = self._uiObjs.Btn_Zone:FindDirect("Label_Name")
    local Group_ChooseType = self._uiObjs.Btn_Zone:FindDirect("Group_Zone/Group_ChooseType")
    local List_Type = Group_ChooseType:FindDirect("List_Type")
    if self.tujianSelection == 0 then
      GUIUtils.SetText(Label_Name, textRes.Fashion[46])
    elseif self._showFashionItemData[self._selectedItemIdx] == nil or self._showFashionItemData[self._selectedItemIdx][self.tujianSelection] == nil then
      GUIUtils.SetText(Label_Name, textRes.Fashion[46])
    else
      local fashionItem = self._showFashionItemData[self._selectedItemIdx][self.tujianSelection]
      local fashionName = string.format(textRes.Fashion[47], fashionItem.fashionDressName, FashionUtils.ConvertHourToSentence(fashionItem.effectTime))
      GUIUtils.SetText(Label_Name, fashionName)
    end
    local Img_Up = self._uiObjs.Btn_Zone:FindDirect("Img_Up")
    local Img_Down = self._uiObjs.Btn_Zone:FindDirect("Img_Down")
    GUIUtils.SetActive(Img_Up, false)
    GUIUtils.SetActive(Img_Down, true)
    GUIUtils.Toggle(self._uiObjs.Tab_Have, false)
    GUIUtils.Toggle(self._uiObjs.Tab_Book, true)
  end
end
def.method()._UpdateFashionItems = function(self)
  if self.currentView == ViewType.Own then
    self:ShowOwnFashionItems()
  else
    self:ShowFashionTujian()
  end
end
def.method().ShowOwnFashionItems = function(self)
  local fashionData = FashionData.Instance()
  local items = self:GetAvailableFashions()
  local itemCount = #items
  self._showFashionItemData = {}
  for i = 1, itemCount do
    local item = items[i]
    if fashionData.haveFashionInfo[item.id] ~= nil then
      item.isUnlock = true
      table.insert(self._showFashionItemData, item)
    elseif FashionModule.Instance():IsFashionIDIPOpen(item.fashionDressType) and self:_IsMatchUnlockCondition(item) then
      item.isUnlock = false
      table.insert(self._showFashionItemData, item)
    end
  end
  local sortFuc = function(a, b)
    if a.isUnlock and not b.isUnlock then
      return true
    elseif not a.isUnlock and b.isUnlock then
      return false
    elseif a.clothesPressType ~= b.clothesPressType then
      return a.clothesPressType < b.clothesPressType
    elseif a.effectTime == -1 then
      return false
    elseif b.effectTime == -1 then
      return true
    else
      return a.effectTime < b.effectTime
    end
  end
  table.sort(self._showFashionItemData, sortFuc)
  itemCount = #self._showFashionItemData
  local itemObjParent = self._uiObjs.Grid_Item
  local uiGrid = itemObjParent:GetComponent("UIGrid")
  for i = 1, itemCount do
    local item = self._showFashionItemData[i]
    local itemObj = itemObjParent:FindDirect("FashionItem_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(self._fashionItemTemplate)
      itemObj.name = "FashionItem_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
      GUIUtils.SetActive(itemObj, true)
    end
    local itemIcon = itemObj:FindDirect("Img_Icon")
    GUIUtils.SetActive(itemIcon, true)
    local uiTexture = itemIcon:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, item.iconId)
    local lockIcon = itemObj:FindDirect("Sprite")
    if item.isUnlock then
      lockIcon:SetActive(false)
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
    else
      lockIcon:SetActive(true)
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
    end
    if item.id == FashionData.Instance().currentFashionId then
      itemObj:FindDirect("Img_Fit"):SetActive(true)
    else
      itemObj:FindDirect("Img_Fit"):SetActive(false)
    end
    local iconTry = itemObj:FindDirect("Img_Try")
    iconTry:SetActive(false)
    GUIUtils.SetActive(itemObj:FindDirect("Img_Select"), true)
    itemObj:GetComponent("UIToggle"):set_enabled(true)
  end
  for i = itemCount + 1, FashionNode.MinGridCount do
    local itemObj = itemObjParent:FindDirect("FashionItem_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(self._fashionItemTemplate)
      itemObj.name = "FashionItem_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
      GUIUtils.SetActive(itemObj, true)
    end
    local childCount = itemObj.transform.childCount
    for i = 1, childCount do
      local child = itemObj.transform:GetChild(i - 1).gameObject
      if child.name ~= "Img_Bg" then
        child:SetActive(false)
      end
    end
    itemObj:GetComponent("UIToggle"):set_enabled(false)
  end
  local unuseIdx = math.max(itemCount, FashionNode.MinGridCount) + 1
  while true do
    local itemObj = itemObjParent:FindDirect("FashionItem_" .. unuseIdx)
    if itemObj == nil then
      break
    end
    GameObject.Destroy(itemObj)
    unuseIdx = unuseIdx + 1
  end
  uiGrid:Reposition()
end
def.method().ShowFashionTujian = function(self)
  local fashionData = FashionData.Instance()
  local items = self:GetAvailableFashions()
  local itemCount = #items
  self._showFashionItemData = {}
  local fashionTypeMap = {}
  for i = 1, itemCount do
    local item = items[i]
    if FashionModule.Instance():IsFashionIDIPOpen(item.fashionDressType) or fashionData.haveFashionInfo[item.id] ~= nil then
      if fashionTypeMap[item.clothesPressType] == nil then
        fashionTypeMap[item.clothesPressType] = {}
        fashionTypeMap[item.clothesPressType].clothesPressType = item.clothesPressType
        fashionTypeMap[item.clothesPressType].isUnlock = false
      end
      if fashionData.haveFashionInfo[item.id] ~= nil then
        item.isUnlock = true
        fashionTypeMap[item.clothesPressType].isUnlock = true
      end
      table.insert(fashionTypeMap[item.clothesPressType], item)
    end
  end
  local fashionSortFuc = function(a, b)
    if a.clothesPressType ~= b.clothesPressType then
      return a.clothesPressType < b.clothesPressType
    elseif a.effectTime == -1 then
      return true
    elseif b.effectTime == -1 then
      return false
    else
      return a.effectTime > b.effectTime
    end
  end
  for clothesPressType, tbl in pairs(fashionTypeMap) do
    table.sort(tbl, fashionSortFuc)
    table.insert(self._showFashionItemData, tbl)
  end
  table.sort(self._showFashionItemData, function(a, b)
    if a.isUnlock and not b.isUnlock then
      return true
    elseif not a.isUnlock and b.isUnlock then
      return false
    else
      return a.clothesPressType < b.clothesPressType
    end
  end)
  itemCount = #self._showFashionItemData
  local itemObjParent = self._uiObjs.Grid_Item
  local uiGrid = itemObjParent:GetComponent("UIGrid")
  for i = 1, itemCount do
    local fashionType = self._showFashionItemData[i]
    local item = fashionType[1]
    local itemObj = itemObjParent:FindDirect("FashionItem_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(self._fashionItemTemplate)
      itemObj.name = "FashionItem_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
      GUIUtils.SetActive(itemObj, true)
    end
    local itemIcon = itemObj:FindDirect("Img_Icon")
    GUIUtils.SetActive(itemIcon, true)
    local uiTexture = itemIcon:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, item.iconId)
    local lockIcon = itemObj:FindDirect("Sprite")
    if fashionType.isUnlock then
      lockIcon:SetActive(false)
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
    else
      lockIcon:SetActive(true)
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
    end
    itemObj:FindDirect("Img_Fit"):SetActive(false)
    local iconTry = itemObj:FindDirect("Img_Try")
    iconTry:SetActive(false)
    GUIUtils.SetActive(itemObj:FindDirect("Img_Select"), true)
    itemObj:GetComponent("UIToggle"):set_enabled(true)
  end
  for i = itemCount + 1, FashionNode.MinGridCount do
    local itemObj = itemObjParent:FindDirect("FashionItem_" .. i)
    if itemObj == nil then
      itemObj = GameObject.Instantiate(self._fashionItemTemplate)
      itemObj.name = "FashionItem_" .. i
      uiGrid:AddChild(itemObj.transform)
      itemObj.transform.localScale = Vector3.one
      GUIUtils.SetActive(itemObj, true)
    end
    local childCount = itemObj.transform.childCount
    for i = 1, childCount do
      local child = itemObj.transform:GetChild(i - 1).gameObject
      if child.name ~= "Img_Bg" then
        child:SetActive(false)
      end
    end
    itemObj:GetComponent("UIToggle"):set_enabled(false)
  end
  local unuseIdx = math.max(itemCount, FashionNode.MinGridCount) + 1
  while true do
    local itemObj = itemObjParent:FindDirect("FashionItem_" .. unuseIdx)
    if itemObj == nil then
      break
    end
    GameObject.Destroy(itemObj)
    unuseIdx = unuseIdx + 1
  end
  uiGrid:Reposition()
end
def.method()._ShowFashionDefaultDetail = function(self)
  if self.currentView == ViewType.Own then
    self._initFashionCfgId = require("Main.Fashion.ui.FashionPanel").Instance():GetInitFashionCfgId()
    if self._initFashionCfgId ~= FashionDressConst.NO_FASHION_DRESS then
      self:_SelectFashionItemByCfgId(self._initFashionCfgId)
    elseif FashionData.Instance().currentFashionId ~= FashionDressConst.NO_FASHION_DRESS then
      self:_SelectFashionItemByCfgId(FashionData.Instance().currentFashionId)
    else
      self:_SelectFashionItemByIdx(self._selectedItemIdx)
    end
  else
    self:SelectFashionTujianItemByIdx(1)
  end
  self:_ShowModel()
end
def.method("number")._SelectFashionItemByCfgId = function(self, cfgId)
  if self.currentView ~= ViewType.Own then
    return
  end
  for idx, item in pairs(self._showFashionItemData) do
    if item.id == cfgId then
      self:_SelectFashionItemByIdx(idx)
      return
    end
  end
  self:_SelectFashionItemByIdx(0)
end
def.method("number")._SelectFashionItemByIdx = function(self, idx)
  if self.currentView ~= ViewType.Own then
    return
  end
  if idx > #self._showFashionItemData then
    return
  end
  self:_ChooseFashionItem(idx)
  self:_ShowFashionItemInfo(idx)
  self:_ShowUnlockCondition()
  self:_UpdateFashionLeftTime(idx)
  self:_UpdateOperationBtn()
end
def.method("number")._ChooseFashionItem = function(self, idx)
  if self.currentView ~= ViewType.Own then
    return
  end
  if self._selectedItemIdx > 0 then
    local preObj = self._uiObjs.Grid_Item:FindDirect("FashionItem_" .. self._selectedItemIdx)
    local iconTry = preObj:FindDirect("Img_Try")
    iconTry:SetActive(false)
    local uiToggle = preObj:GetComponent("UIToggle")
    uiToggle.value = false
  end
  self._selectedItemIdx = idx
  if idx < 1 then
    return
  end
  local itemObj = self._uiObjs.Grid_Item:FindDirect("FashionItem_" .. idx)
  local uiToggle = itemObj:GetComponent("UIToggle")
  uiToggle.value = true
  local fashionItem = self._showFashionItemData[idx]
  if fashionItem.id ~= FashionData.Instance().currentFashionId then
    itemObj:FindDirect("Img_Try"):SetActive(true)
  end
  GUIUtils.DragToMakeVisible(self._uiObjs.ScrollView_Item, itemObj, 0.1, 256)
end
def.method("number")._ShowFashionItemInfo = function(self, idx)
  if self.currentView ~= ViewType.Own then
    return
  end
  if idx < 1 then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local genderStr = textRes.Fashion[7]
    if heroProp.gender == GenderEnum.FEMALE then
      genderStr = textRes.Fashion[8]
    end
    self._uiObjs.Label_Name:GetComponent("UILabel"):set_text(textRes.Fashion[5])
    self._uiObjs.Label_Info:GetComponent("UILabel"):set_text(string.format(textRes.Fashion[6], textRes.Occupation[heroProp.occupation], genderStr))
    self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):ForceHtmlText(textRes.Fashion[9])
    self._uiObjs.Label_Skill:GetComponent("UILabel"):set_text(textRes.Fashion[4])
  else
    local item = self._showFashionItemData[idx]
    self._uiObjs.Label_Name:GetComponent("UILabel"):set_text(item.fashionDressName)
    self._uiObjs.Label_Info:GetComponent("UILabel"):set_text(item.fashionDressDesc)
    local skillEffects = item.effects
    local effectDesc = {}
    for i = 1, #skillEffects do
      local skillId = skillEffects[i]
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      if skillCfg ~= nil then
        table.insert(effectDesc, string.format(textRes.Fashion[32], skillId, skillCfg.name))
      end
    end
    if #effectDesc == 0 then
      self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):ForceHtmlText(textRes.Fashion[9])
    else
      self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):ForceHtmlText(table.concat(effectDesc, "&nbsp;"))
    end
    local skillProperties = item.properties
    local propertyDesc = {}
    for i = 1, #skillProperties do
      local skillId = skillProperties[i]
      local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
      if skillCfg ~= nil then
        table.insert(propertyDesc, skillCfg.description)
      end
    end
    if #propertyDesc == 0 then
      self._uiObjs.Label_Skill:GetComponent("UILabel"):set_text(textRes.Fashion[4])
    else
      self._uiObjs.Label_Skill:GetComponent("UILabel"):set_text(table.concat(propertyDesc, "\n"))
    end
  end
end
def.method()._ShowUnlockCondition = function(self)
  local fashionItem = self:GetCurrentSelectFashionItem()
  if fashionItem == nil then
    self._uiObjs.Group_Item:SetActive(false)
    self._uiObjs.Label_Condition:SetActive(false)
    return
  end
  if self.currentView == ViewType.Own and fashionItem.isUnlock then
    self._uiObjs.Group_Item:SetActive(false)
    self._uiObjs.Label_Condition:SetActive(false)
  else
    local unlockCondition = FashionUtils.GetFashionUnlockConditionById(fashionItem.unlockConditionId)
    if unlockCondition.conditionType == FashionDressUnLockConditionEnum.ITEM then
      self._uiObjs.Group_Item:SetActive(true)
      self._uiObjs.Label_Condition:SetActive(false)
      local unlockItem = ItemUtils.GetItemBase(fashionItem.costItemId)
      local uiTexture = self._uiObjs.ConditionItemIcon:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, unlockItem.icon)
      self._uiObjs.ConditionItemName:GetComponent("UILabel"):set_text(unlockItem.name)
      local itemData = require("Main.Item.ItemData").Instance()
      local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
      local currentItemCount = itemData:GetNumberByItemId(BagInfo.BAG, fashionItem.costItemId)
      self._uiObjs.ConditionItemNum:GetComponent("UILabel"):set_text(string.format("%d/%d", currentItemCount, fashionItem.costItemNum))
    else
      self._uiObjs.Group_Item:SetActive(false)
      self._uiObjs.Label_Condition:SetActive(true)
      self._uiObjs.Label_Condition:GetComponent("UILabel"):set_text(unlockCondition.conditionDesc)
    end
  end
end
def.method()._UpdateOperationBtn = function(self)
  local fashionItem = self:GetCurrentSelectFashionItem()
  if fashionItem == nil then
    self._uiObjs.MainOperationBtn:SetActive(false)
    return
  end
  if fashionItem.isUnlock then
    if self.currentView == ViewType.Own then
      self._uiObjs.MainOperationBtn:SetActive(true)
      if fashionItem.id == FashionData.Instance().currentFashionId then
        self._uiObjs.MainOperationBtn:FindDirect("Label_Settle"):GetComponent("UILabel"):set_text(textRes.Fashion[11])
      else
        self._uiObjs.MainOperationBtn:FindDirect("Label_Settle"):GetComponent("UILabel"):set_text(textRes.Fashion[10])
      end
    else
      self._uiObjs.MainOperationBtn:SetActive(false)
    end
  else
    local unlockCondition = FashionUtils.GetFashionUnlockConditionById(fashionItem.unlockConditionId)
    if unlockCondition.conditionType == FashionDressUnLockConditionEnum.ITEM then
      self._uiObjs.MainOperationBtn:SetActive(true)
      self._uiObjs.MainOperationBtn:FindDirect("Label_Settle"):GetComponent("UILabel"):set_text(textRes.Fashion[12])
    else
      self._uiObjs.MainOperationBtn:SetActive(false)
    end
  end
end
def.method("number")._UpdateFashionLeftTime = function(self, idx)
  if self.currentView ~= ViewType.Own then
    return
  end
  if idx < 1 then
    self._uiObjs.Label_Time:GetComponent("UILabel"):set_text(textRes.Fashion[3])
  else
    local item = self._showFashionItemData[self._selectedItemIdx]
    if item ~= nil then
      if item.isUnlock then
        if Int64.eq(FashionData.Instance().haveFashionInfo[item.id], FashionDressConst.FOREVER) then
          self._uiObjs.Label_Time:GetComponent("UILabel"):set_text(textRes.Fashion[3])
        else
          self._uiObjs.Label_Time:GetComponent("UILabel"):set_text(FashionUtils.ConvertSecondToSentence(FashionData.Instance().haveFashionInfo[item.id]))
        end
      elseif item.effectTime ~= FashionDressConst.FOREVER then
        self._uiObjs.Label_Time:GetComponent("UILabel"):set_text(FashionUtils.ConvertHourToSentence(item.effectTime))
      else
        self._uiObjs.Label_Time:GetComponent("UILabel"):set_text(textRes.Fashion[3])
      end
    end
  end
end
def.method()._ShowUnlockItemTips = function(self)
  local fashionItem = self:GetCurrentSelectFashionItem()
  if fashionItem == nil then
    return
  end
  local unlockCondition = FashionUtils.GetFashionUnlockConditionById(fashionItem.unlockConditionId)
  if unlockCondition.conditionType == FashionDressUnLockConditionEnum.ITEM then
    local itemId = fashionItem.costItemId
    local unlockItem = self._uiObjs.ConditionItem
    local position = unlockItem:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = unlockItem:GetComponent("UIWidget")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x - sprite:get_width() * 0.5, screenPos.y + sprite:get_height() * 0.5, sprite:get_width(), 1, 0, true)
  end
end
def.method()._UnlockSelectFashion = function(self)
  local fashionItem = self:GetCurrentSelectFashionItem()
  if fashionItem == nil then
    Toast(textRes.Fashion[13])
    return
  end
  if not self:_IsMatchUnlockCondition(fashionItem) then
    Toast(textRes.Fashion[15])
    return
  end
  if not FashionModule.Instance():IsFashionIDIPOpen(fashionItem.fashionDressType) then
    Toast(textRes.Fashion[43])
    return
  end
  FashionModule.UnLockFashionDress(fashionItem.id)
end
def.method("table", "=>", "boolean")._IsMatchUnlockCondition = function(self, fashionItem)
  if fashionItem == nil then
    return false
  end
  local unlockCondition = FashionUtils.GetFashionUnlockConditionById(fashionItem.unlockConditionId)
  if unlockCondition.conditionType == FashionDressUnLockConditionEnum.ITEM then
    local itemData = require("Main.Item.ItemData").Instance()
    local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
    local currentItemCount = itemData:GetNumberByItemId(BagInfo.BAG, fashionItem.costItemId)
    return currentItemCount >= fashionItem.costItemNum
  else
    return false
  end
end
def.method()._DropSelectFashion = function(self)
  local fashionItem = self:GetCurrentSelectFashionItem()
  if fashionItem == nil then
    Toast(textRes.Fashion[13])
    return
  end
  self:_SelectFashionItemByIdx(0)
  FashionModule.PutOffFashionDress(fashionItem.id)
end
def.method()._DressSelectFashion = function(self)
  local fashionItem = self:GetCurrentSelectFashionItem()
  if fashionItem == nil then
    Toast(textRes.Fashion[13])
    return
  end
  FashionModule.PutOnFashionDress(fashionItem.id)
end
def.method()._SetNewNotify = function(self)
  self._uiObjs.Btn_Effect:FindDirect("Img_Red"):SetActive(true)
  FashionData.Instance():AddNewEffectNotify()
end
def.method()._RemoveEffectNotify = function(self)
  self._uiObjs.Btn_Effect:FindDirect("Img_Red"):SetActive(false)
end
def.method("number")._ShowSkillTips = function(self, skillId)
  require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, self._uiObjs.Label_Effect:FindDirect("skill_" .. skillId), 0)
end
def.method()._UpdateFashion = function(self)
  self:_ShowModel()
  do return end
  if self._model == nil then
    return
  end
  local currentFashion = self._showFashionItemData[self._selectedItemIdx]
  if currentFashion ~= nil then
    FashionUtils.SetFashion(self._model, currentFashion.id)
  else
    FashionUtils.SetFashion(self._model, -1)
  end
end
def.method()._ShowModel = function(self)
  if self.m_panel ~= nil and not self.m_panel.isnil then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    if heroProp == nil then
      return
    end
    local modelId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyModelId()
    if self._model ~= nil then
      self._model:Destroy()
      self._model = nil
    end
    self._model = ECUIModel.new(modelId)
    self._model.m_bUncache = true
    local modelInfo = self:GetInitFashionModelInfo()
    _G.LoadModelWithCallBack(self._model, modelInfo, false, false, function()
      if not self._model then
        return
      end
      self._model:OnLoadGameObject()
      self:_OnLoadModel(nil)
    end)
  end
end
def.method("table")._OnLoadModel = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    if self._model ~= nil then
      self._model:Destroy()
      self._model = nil
    end
    return
  end
  local uiModel = self._uiObjs.Model:GetComponent("UIModel")
  if self._model == nil or self._model.m_model == nil or self._model.m_model.isnil or uiModel == nil or uiModel.isnil then
    return
  end
  uiModel.modelGameObject = self._model.m_model
  if uiModel.mCanOverflow ~= nil then
    uiModel.mCanOverflow = true
    local camera = uiModel:get_modelCamera()
    camera:set_orthographic(true)
  end
end
def.method("=>", "table").GetInitFashionModelInfo = function(self)
  local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
  if modelInfo == nil then
    return nil
  end
  local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
  modelInfo.extraMap[ModelInfo.EXTERIOR_ID] = nil
  local currentFashion
  if self.currentView == ViewType.Own then
    currentFashion = self._showFashionItemData[self._selectedItemIdx]
  elseif self.currentView == ViewType.Tujian and self._showFashionItemData[self._selectedItemIdx] ~= nil then
    currentFashion = self._showFashionItemData[self._selectedItemIdx][self.tujianSelection]
  end
  if currentFashion ~= nil then
    local dyeColor = FashionUtils.GetFashionDyeColor(currentFashion.id)
    modelInfo.extraMap[ModelInfo.FASHION_DRESS_ID] = currentFashion.id
    modelInfo.extraMap[ModelInfo.HAIR_COLOR_ID] = dyeColor.hairId
    modelInfo.extraMap[ModelInfo.CLOTH_COLOR_ID] = dyeColor.clothId
  end
  return modelInfo
end
def.method("=>", "table").GetAvailableFashions = function(self)
  local items = FashionUtils.GetAllFashionItemData()
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FASHION_REPLACE) then
    local FashionShowType = require("consts.mzm.gsp.fashiondress.confbean.FashionShowType")
    for i = #items, 1, -1 do
      if items[i].fashionShowType == FashionShowType.REPLACE then
        table.remove(items, i)
      end
    end
  end
  return items
end
def.method()._ResetModelFashion = function(self)
  if self.currentView ~= ViewType.Own then
    return
  end
  self:_SelectFashionItemByCfgId(FashionData.Instance().currentFashionId)
  self:_UpdateFashion()
end
def.method()._DyeFashion = function(self)
  if _G.PlayerIsInFight() then
    Toast(textRes.Fashion[37])
    return
  end
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(1)
  local dyeingPanel = require("Main.Dyeing.ui.DyeingPanel")
  dyeingPanel.Instance():ShowPanel()
end
def.method()._ChooseFashionEffect = function(self)
  self:_RemoveEffectNotify()
  FashionEffectPanel.Instance():ShowFashionEffect()
end
def.method().ToggleTujianSelection = function(self)
  local isShow = self._uiObjs.Group_Zone.activeSelf
  if isShow then
    self:HideTujianSelection()
  else
    self:ShowTujianSelection()
  end
end
def.method().ShowTujianSelection = function(self)
  GUIUtils.SetActive(self._uiObjs.Group_Zone, true)
  local Group_ChooseType = self._uiObjs.Btn_Zone:FindDirect("Group_Zone/Group_ChooseType")
  local List_Type = Group_ChooseType:FindDirect("List_Type")
  local uiList = List_Type:GetComponent("UIList")
  uiList.itemCount = #self._showFashionItemData[self._selectedItemIdx]
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    local Label_Name = uiItem:FindDirect("Label_Name_" .. i)
    local fashionItem = self._showFashionItemData[self._selectedItemIdx][i]
    local fashionName = string.format(textRes.Fashion[47], fashionItem.fashionDressName, FashionUtils.ConvertHourToSentence(fashionItem.effectTime))
    GUIUtils.SetText(Label_Name, fashionName)
  end
  GameUtil.AddGlobalTimer(0, true, function()
    if self._uiObjs ~= nil then
      List_Type:GetComponent("UIList"):Reposition()
      Group_ChooseType:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local Img_Up = self._uiObjs.Btn_Zone:FindDirect("Img_Up")
  local Img_Down = self._uiObjs.Btn_Zone:FindDirect("Img_Down")
  GUIUtils.SetActive(Img_Up, true)
  GUIUtils.SetActive(Img_Down, false)
end
def.method().HideTujianSelection = function(self)
  GUIUtils.SetActive(self._uiObjs.Group_Zone, false)
  local Img_Up = self._uiObjs.Btn_Zone:FindDirect("Img_Up")
  local Img_Down = self._uiObjs.Btn_Zone:FindDirect("Img_Down")
  GUIUtils.SetActive(Img_Up, false)
  GUIUtils.SetActive(Img_Down, true)
end
def.method("number").SelectFashionTujianItemByCfgId = function(self, cfgId)
  if self.currentView ~= ViewType.Tujian then
    return
  end
  local idx = 1
  local selection = 1
  local isFind = false
  for i = 1, #self._showFashionItemData do
    for j = 1, #self._showFashionItemData[i] do
      local fashionItem = self._showFashionItemData[i][j]
      if fashionItem.id == cfgId then
        idx = i
        selection = j
        isFind = true
        break
      end
    end
    if isFind then
      break
    end
  end
  if not isFind then
    return
  end
  self:ChooseFashionTujianItem(idx, selection)
  self:UpdateFashionSelectionStatus()
  self:ShowCurrentTujianItemDetail()
  self:_ShowUnlockCondition()
  self:_UpdateOperationBtn()
end
def.method("number").SelectFashionTujianItemByIdx = function(self, idx)
  if self.currentView ~= ViewType.Tujian then
    return
  end
  if idx > #self._showFashionItemData then
    return
  end
  self:ChooseFashionTujianItem(idx, 0)
  self:UpdateFashionSelectionStatus()
  self:ShowCurrentTujianItemDetail()
  self:_ShowUnlockCondition()
  self:_UpdateOperationBtn()
end
def.method("number", "number").ChooseFashionTujianItem = function(self, idx, selection)
  if self.currentView ~= ViewType.Tujian then
    return
  end
  if self._selectedItemIdx > 0 then
    local preObj = self._uiObjs.Grid_Item:FindDirect("FashionItem_" .. self._selectedItemIdx)
    local uiToggle = preObj:GetComponent("UIToggle")
    uiToggle.value = false
  end
  self._selectedItemIdx = idx
  if selection > 0 then
    self.tujianSelection = selection
  else
    self.tujianSelection = 1
    local fashionData = FashionData.Instance()
    local typeCount = #self._showFashionItemData[idx]
    local unlockFashions = {}
    for i = 1, typeCount do
      local fashionItem = self._showFashionItemData[idx][i]
      if fashionData.haveFashionInfo[fashionItem.id] ~= nil then
        local cfg = FashionUtils.GetFashionItemDataById(fashionItem.id)
        local data = {}
        data.idx = i
        data.hasEffect = 0 < #cfg.effects
        table.insert(unlockFashions, data)
      end
    end
    if #unlockFashions > 0 then
      self.tujianSelection = unlockFashions[1].idx
      for i = 1, #unlockFashions do
        if unlockFashions[i].hasEffect then
          self.tujianSelection = unlockFashions[i].idx
          break
        end
      end
    end
  end
  if idx < 1 then
    return
  end
  local itemObj = self._uiObjs.Grid_Item:FindDirect("FashionItem_" .. idx)
  local uiToggle = itemObj:GetComponent("UIToggle")
  uiToggle.value = true
  GUIUtils.DragToMakeVisible(self._uiObjs.ScrollView_Item, itemObj, false, 256)
end
def.method().ShowCurrentTujianItemDetail = function(self)
  if self._showFashionItemData == nil or self._showFashionItemData[self._selectedItemIdx] == nil or self._showFashionItemData[self._selectedItemIdx][self.tujianSelection] == nil then
    return
  end
  local item = self._showFashionItemData[self._selectedItemIdx][self.tujianSelection]
  self._uiObjs.Label_Name:GetComponent("UILabel"):set_text(item.fashionDressName)
  self._uiObjs.Label_Info:GetComponent("UILabel"):set_text(item.fashionDressDesc)
  local skillEffects = item.effects
  local effectDesc = {}
  for i = 1, #skillEffects do
    local skillId = skillEffects[i]
    local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
    if skillCfg ~= nil then
      table.insert(effectDesc, string.format(textRes.Fashion[32], skillId, skillCfg.name))
    end
  end
  if #effectDesc == 0 then
    self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):ForceHtmlText(textRes.Fashion[9])
  else
    self._uiObjs.Label_Effect:GetComponent("NGUIHTML"):ForceHtmlText(table.concat(effectDesc, "&nbsp;"))
  end
  local skillProperties = item.properties
  local propertyDesc = {}
  for i = 1, #skillProperties do
    local skillId = skillProperties[i]
    local skillCfg = require("Main.Skill.SkillUtility").GetSkillCfg(skillId)
    if skillCfg ~= nil then
      table.insert(propertyDesc, skillCfg.description)
    end
  end
  if #propertyDesc == 0 then
    self._uiObjs.Label_Skill:GetComponent("UILabel"):set_text(textRes.Fashion[4])
  else
    self._uiObjs.Label_Skill:GetComponent("UILabel"):set_text(table.concat(propertyDesc, "\n"))
  end
  if item.effectTime ~= FashionDressConst.FOREVER then
    self._uiObjs.Label_Time:GetComponent("UILabel"):set_text(FashionUtils.ConvertHourToSentence(item.effectTime))
  else
    self._uiObjs.Label_Time:GetComponent("UILabel"):set_text(textRes.Fashion[3])
  end
end
def.method("number").SelectFashionTujianTimeEffect = function(self, selection)
  self.tujianSelection = selection
  self:UpdateFashionSelectionStatus()
  self:ShowCurrentTujianItemDetail()
  self:_ShowUnlockCondition()
  self:_UpdateOperationBtn()
end
def.method("=>", "table").GetCurrentSelectFashionItem = function(self)
  local fashionItem
  if self.currentView == ViewType.Own then
    fashionItem = self._showFashionItemData[self._selectedItemIdx]
  elseif self._showFashionItemData[self._selectedItemIdx] ~= nil then
    fashionItem = self._showFashionItemData[self._selectedItemIdx][self.tujianSelection]
  end
  return fashionItem
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  self:HideTujianSelection()
  if string.find(id, "FashionItem_") == 1 then
    local itemIdx = tonumber(string.sub(id, #"FashionItem_" + 1))
    self:OnClickFashionItem(itemIdx)
  elseif id == "Bg_Item" then
    self:_ShowUnlockItemTips()
  elseif id == "Btn_UnLock" then
    self:OnClickBtnOperate()
  elseif id == "Btn_ReSet" then
    self:_ResetModelFashion()
  elseif id == "Btn_Dye" then
    self:_DyeFashion()
  elseif id == "Btn_Effect" then
    self:_ChooseFashionEffect()
  elseif string.find(id, "skill_") == 1 then
    local skillId = tonumber(string.sub(id, 7))
    self:_ShowSkillTips(skillId)
  elseif id == "Tab_Have" then
    self:SwitchToView(ViewType.Own)
  elseif id == "Tab_Book" then
    self:SwitchToView(ViewType.Tujian)
  elseif id == "Btn_Zone" then
    self:ToggleTujianSelection()
  elseif string.find(id, "Img_Bg_") then
    local selection = tonumber(string.sub(id, #"Img_Bg_" + 1))
    self:OnClickFashionTujianSelection(selection)
  end
end
def.method("number").OnClickFashionItem = function(self, idx)
  local fashion = self._showFashionItemData[idx]
  if fashion == nil then
    return
  end
  if self.currentView == ViewType.Own then
    self:_SelectFashionItemByIdx(idx)
  else
    self:SelectFashionTujianItemByIdx(idx)
  end
  self:_UpdateFashion()
end
def.method().OnClickBtnOperate = function(self)
  local fashionItem = self:GetCurrentSelectFashionItem()
  if fashionItem ~= nil then
    if fashionItem.isUnlock then
      if fashionItem.id == FashionData.Instance().currentFashionId then
        self:_DropSelectFashion()
      else
        self:_DressSelectFashion()
      end
    else
      local unlockCondition = FashionUtils.GetFashionUnlockConditionById(fashionItem.unlockConditionId)
      if unlockCondition.conditionType == FashionDressUnLockConditionEnum.ITEM then
        self:_UnlockSelectFashion()
      end
    end
  end
end
def.method("number").OnClickFashionTujianSelection = function(self, selection)
  if self.currentView == ViewType.Own then
    return
  end
  self:SelectFashionTujianTimeEffect(selection)
end
def.override("string").onDragStart = function(self, id)
  if id == "Model" then
    self._isDrag = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self._isDrag = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self._isDrag == true and self._model then
    self._model:SetDir(self._model.m_ang - dx / 2)
  end
end
def.method("table")._OnUnlockFationItem = function(self, params)
  self:_UpdateFashionItems()
  if FashionUtils.IsFashionHavePropertyEffect(params.id) then
    self:_SetNewNotify()
  end
  if self.currentView == ViewType.Own then
    self:_SelectFashionItemByCfgId(params.id)
  else
    self:SelectFashionTujianItemByCfgId(params.id)
  end
end
def.method("table")._OnDressFashionChanged = function(self, params)
  self:_UpdateOperationBtn()
  self:_UpdateFashionItems()
end
def.method("table")._OnBagInfoSynchronized = function(self, params)
  self:_UpdateFashionItems()
  self:_ShowUnlockCondition()
end
def.method("table")._OnFashionExpired = function(self, params)
  self:_UpdateFashionItems()
end
def.method("table")._OnFashionLeftTimeChange = function(self, params)
  if self.currentView ~= ViewType.Own then
    return
  end
  self:_UpdateFashionLeftTime(self._selectedItemIdx)
end
def.method("table")._OnColorDataChanged = function(self, params)
  self:_UpdateFashion()
end
FashionNode.Commit()
return FashionNode
