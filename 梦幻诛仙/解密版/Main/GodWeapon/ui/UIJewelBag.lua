local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIJewelBag = Lplus.Extend(ECPanelBase, MODULE_NAME)
local def = UIJewelBag.define
local instance
local GUIUtils = require("GUI.GUIUtils")
local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local JewelMgr = require("Main.GodWeapon.JewelMgr")
local JewelProtocols = require("Main.GodWeapon.Jewel.JewelProtocols")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local ItemModule = require("Main.Item.ItemModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local GUIFxMan = require("Fx.GUIFxMan")
local txtConst = textRes.GodWeapon.Jewel
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.field("table")._allPropTypes = nil
def.field("table")._curJewelItems = nil
def.field("table")._params = nil
def.field("table")._mapProp2Items = nil
def.static("=>", UIJewelBag).Instance = function()
  if instance == nil then
    instance = UIJewelBag()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, UIJewelBag.OnJewelBagChange, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_COMPOUND_SUCCESS, UIJewelBag.OnCompoundSuccess, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_AUTOCOMPOUND_FEATURE_CHG, UIJewelBag.OnAutoCompoundFeatureChg, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, UIJewelBag.OnMoneyChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, UIJewelBag.OnMoneyChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, UIJewelBag.OnMoneyChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, UIJewelBag.OnMoneyChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, UIJewelBag.OnMoneyChange, self)
end
def.method().InitUI = function(self)
  self._uiGOs = self._uiGOs or {}
  self._uiStatus = self._uiStatus or {}
  self._uiStatus.selJewelIdx = self._uiStatus.selJewelIdx or 1
  self._uiStatus.selLvUpIdx = self._uiStatus.selLvUpIdx or 0
  self._uiStatus.preSelJewelIdx = self._uiStatus.preSelJewelIdx or 0
  self._uiStatus.curSlotIdx = self._uiStatus.curSlotIdx or 1
  self._uiStatus.selFilterIdx = self._uiStatus.selFilterIdx or 1
  self._uiStatus.NEED_JEWEL_NUM = 2
  self._uiStatus.moneyType = 0
  self._uiStatus.dstItemId = 0
  self._uiStatus.bFillMapProps = false
  self._uiStatus.bIsDblClick = false
  self._allPropTypes = {}
  self._curJewelItems = {}
  self._mapProp2Items = {}
  self._uiGOs.filterList = self.m_panel:FindDirect("Img_Bg/Img_BagBS/Panel_Classify")
  self._uiGOs.comFilterList = self._uiGOs.filterList:FindDirect("Toggle_Classify"):GetComponent("UIToggleEx")
  self._uiGOs.compound = self.m_panel:FindDirect("Img_Bg/BSCompound")
  self._uiGOs.jewelList = self.m_panel:FindDirect("Img_Bg/Img_BagBS")
  self._uiGOs.ctrlTitleRoot = self._uiGOs.filterList:FindDirect("Toggle_Classify")
  self._uiGOs.fx = self._uiGOs.compound:FindDirect("Fx")
  self:_checkFeature()
  self:_parseParams()
  self:UpdateUI()
end
def.method()._checkFeature = function(self)
  local btnLbl = self._uiGOs.compound:FindDirect("Btn_Group/Btn_Compound/Label_Compound")
  GUIUtils.SetText(btnLbl, txtConst[5])
  local btnAuto = self._uiGOs.compound:FindDirect("Btn_Group/Btn_QuickCompound/")
  btnLbl = btnAuto:FindDirect("Label_Compound")
  GUIUtils.SetText(btnLbl, txtConst[29])
  btnAuto:SetActive(JewelMgr.IsAutoCompoundFeatureOpen())
end
def.method()._parseParams = function(self)
  if self._params ~= nil then
    if self._allPropTypes == nil or #self._allPropTypes < 1 then
      self._allPropTypes = JewelUtils.GetAllJewelPropTypesCfg() or {}
    end
    local jewelBasic = JewelUtils.GetJewelItemByItemId(self._params.itemId, false)
    if jewelBasic ~= nil then
      local propKey = JewelUtils.GetKeyByPrpArrTbl(jewelBasic.arrProps)
      for i = 1, #self._allPropTypes do
        if propKey == self._allPropTypes[i] then
          self._uiStatus.selFilterIdx = i
          break
        end
      end
    end
    if 1 > #self._curJewelItems then
      self:FilterByPropType(false)
    end
    local item, idx = self:_getIdxByItemId(self._params.itemId)
    self._uiStatus.selLvUpIdx = idx
    self._uiStatus.selJewelIdx = idx
  end
end
def.method("number", "=>", "table", "number")._getIdxByItemId = function(self, itemId)
  local items = self._curJewelItems or {}
  for k, item in ipairs(items) do
    if item.id == itemId then
      return item, k
    end
  end
  return nil, 0
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, UIJewelBag.OnJewelBagChange)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_COMPOUND_SUCCESS, UIJewelBag.OnCompoundSuccess)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_AUTOCOMPOUND_FEATURE_CHG, UIJewelBag.OnAutoCompoundFeatureChg)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, UIJewelBag.OnMoneyChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, UIJewelBag.OnMoneyChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, UIJewelBag.OnMoneyChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, UIJewelBag.OnMoneyChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, UIJewelBag.OnMoneyChange)
  self._uiStatus = nil
  self._uiGOs = nil
  self._allPropTypes = nil
  self._params = nil
  self._mapProp2Items = nil
end
def.override("boolean").OnShow = function(self, bShow)
  if bShow then
    self:UpdateUIJewelsList()
    self._uiGOs.fx:SetActive(false)
  end
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    self:_parseParams()
    self:UpdateUI()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_JEWEL_BAG, 1)
  self:SetModal(true)
end
def.method("table").ShowWithParams = function(self, params)
  self._params = params
  self:ShowPanel()
end
def.method().UpdateUI = function(self)
  self:FilterByPropType(true)
  self:UpdateUIJewelsList()
  self:UpdateUIFilterList()
  self:UpdateUIRight()
end
def.method().UpdateUIFilterList = function(self)
  local ctrlRoot = self._uiGOs.filterList
  local ctrlScrollView = ctrlRoot:FindDirect("Toggle_Classify/Img_Select/Img_ContentBg/Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("Container")
  if self._allPropTypes == nil or #self._allPropTypes < 1 then
    self._allPropTypes = JewelUtils.GetAllJewelPropTypesCfg() or {}
  end
  local propList = self._allPropTypes
  local propNum = #propList
  local ctrlPropList = GUIUtils.InitUIList(ctrlUIList, propNum)
  local selPropIdx = self._uiStatus.selFilterIdx
  for i = 1, propNum do
    local ctrl = ctrlPropList[i]
    local lblName = ctrl:FindDirect("Label_" .. i)
    if propList[i] == "" then
      GUIUtils.SetText(lblName, txtConst[4])
    else
      local propName = JewelUtils.GetUniqNameByPropKey(propList[i])
      local items = self._mapProp2Items[propList[i]] or {}
      local count = 0
      for _, item in ipairs(items) do
        count = count + item.number
      end
      GUIUtils.SetText(lblName, txtConst[31]:format(propName, count))
    end
    if i == selPropIdx then
      ctrl:GetComponent("UIToggle").value = true
    end
  end
  local selPropName = JewelUtils.GetUniqNameByPropKey(propList[selPropIdx])
  local lblTitle = self._uiGOs.ctrlTitleRoot:FindDirect("Img_Default/Label_Title")
  GUIUtils.SetText(lblTitle, selPropName)
  lblTitle = self._uiGOs.ctrlTitleRoot:FindDirect("Img_Select/Label_Title")
  GUIUtils.SetText(lblTitle, selPropName)
end
def.method().UpdateUIJewelsList = function(self)
  if not self:IsShow() then
    return
  end
  local selJewelIdx = self._uiStatus.selJewelIdx
  local ctrlRoot = self._uiGOs.jewelList
  local ctrlScrollView = ctrlRoot:FindDirect("Scroll View")
  local ctrlUIList = ctrlScrollView:FindDirect("List")
  local ctrlNoJewel = ctrlScrollView:FindDirect("Image_NoBs")
  local bagJewelList = self._curJewelItems
  local numJewels = #bagJewelList
  ctrlUIList:SetActive(numJewels ~= 0)
  ctrlNoJewel:SetActive(numJewels == 0)
  if numJewels ~= 0 then
    local ctrlJewelList = GUIUtils.InitUIList(ctrlUIList, numJewels)
    for i = 1, numJewels do
      local ctrlItem = ctrlJewelList[i]
      local icon = ctrlItem:FindDirect("Icon_BS_" .. i)
      local lblNum = ctrlItem:FindDirect("Label_Num_" .. i)
      local ctrlState = ctrlItem:FindDirect("State_" .. i)
      if i == selJewelIdx then
        ctrlItem:GetComponent("UIToggle").value = true
      end
      local itemInfo = bagJewelList[i]
      local itemBase = ItemUtils.GetItemBase(itemInfo.id)
      GUIUtils.SetTexture(icon, itemBase.icon)
      GUIUtils.SetText(lblNum, itemInfo.number)
      ctrlState:SetActive(false)
    end
  end
end
def.method("boolean").FilterByPropType = function(self, bSearchNxt)
  if not self._uiStatus.bFillMapProps then
    self:_fillPropsMap()
  end
  local selPropType = self._allPropTypes[self._uiStatus.selFilterIdx]
  if selPropType == 0 then
    local items = JewelMgr.Instance():GetJewelItems()
    self._curJewelItems = items
  else
    self._curJewelItems = self._mapProp2Items[selPropType] or {}
    if bSearchNxt and #self._curJewelItems < 1 then
      local selFilterIdx = self._uiStatus.selFilterIdx + 1
      local selJewelItems
      for i = selFilterIdx, #(self._allPropTypes or {}) do
        local selPropType = self._allPropTypes[i]
        selJewelItems = self._mapProp2Items[selPropType]
        if selJewelItems ~= nil then
          self._uiStatus.selFilterIdx = i
          self._curJewelItems = selJewelItems
          break
        end
      end
    end
  end
end
def.method()._fillPropsMap = function(self)
  self._mapProp2Items = {}
  if self._allPropTypes == nil or #self._allPropTypes < 1 then
    self._allPropTypes = JewelUtils.GetAllJewelPropTypesCfg() or {}
  end
  local items = JewelMgr.Instance():GetJewelItems() or {}
  for _, item in ipairs(items) do
    local jewelBaseCfg = JewelUtils.GetJewelItemByItemId(item.id, false)
    if jewelBaseCfg ~= nil then
      local propKey = JewelUtils.GetKeyByPrpArrTbl(jewelBaseCfg.arrProps)
      self._mapProp2Items[propKey] = self._mapProp2Items[propKey] or {}
      item.level = jewelBaseCfg.level
      table.insert(self._mapProp2Items[propKey], item)
    end
  end
  for propType, items in pairs(self._mapProp2Items) do
    if items ~= nil then
      table.sort(items, function(a, b)
        if a.level > b.level then
          return true
        end
        return false
      end)
    end
  end
  local selFilterProp = self._allPropTypes[self._uiStatus.selFilterIdx]
  table.sort(self._allPropTypes, function(a, b)
    local aNum = #(self._mapProp2Items[a] or {})
    local bNum = #(self._mapProp2Items[b] or {})
    if aNum > bNum then
      return true
    else
      return false
    end
  end)
  for i = 1, #self._allPropTypes do
    if self._allPropTypes[i] == selFilterProp then
      self._uiStatus.selFilterIdx = i
      break
    end
  end
  self._uiStatus.bFillMapProps = true
end
def.method().UpdateUIRight = function(self)
  local selJewelIdx = self._uiStatus.selLvUpIdx or 0
  local jewelItems = self._curJewelItems
  local selItemInfo
  local item = jewelItems[selJewelIdx]
  if selJewelIdx > 0 and item ~= nil then
    local itemBase = ItemUtils.GetItemBase(item.id)
    selItemInfo = {
      itemId = item.id,
      icon = itemBase.icon,
      number = item.number
    }
  end
  local ctrlRoot = self._uiGOs.compound
  local ctrlItem = ctrlRoot:FindDirect("Before/Img_BgBs")
  local jewelItemCfg, dstItemInfo
  if selItemInfo ~= nil then
    jewelItemCfg = JewelUtils.GetJewelItemByItemId(selItemInfo.itemId, false)
    self._uiStatus.NEED_JEWEL_NUM = jewelItemCfg.needCurLvItemNum
  end
  if jewelItemCfg ~= nil then
    local nxtLvItemId = jewelItemCfg.nxtLvItemId
    if nxtLvItemId > 0 then
      local nxtLvItemCfg = JewelUtils.GetJewelItemByItemId(nxtLvItemId, false)
      local nxtLVItemBase = ItemUtils.GetItemBase(nxtLvItemId)
      dstItemInfo = {
        itemId = nxtLvItemId,
        icon = nxtLVItemBase.icon
      }
      self._uiStatus.dstItemId = nxtLvItemId
    end
  end
  if jewelItemCfg ~= nil and dstItemInfo == nil then
    Toast(txtConst[8])
    selItemInfo = nil
    jewelItemCfg, dstItemInfo = nil, nil
    self._uiStatus.dstItemId = 0
  elseif #jewelItems > 0 and selItemInfo ~= nil then
    local itemNum = ItemModule.Instance():GetItemCountById(selItemInfo.itemId)
    if selItemInfo ~= nil and itemNum < self._uiStatus.NEED_JEWEL_NUM then
      if self._uiStatus.bIsDblClick then
        Toast(txtConst[7])
      end
      selItemInfo = nil
      jewelItemCfg, dstItemInfo = nil, nil
      self._uiStatus.dstItemId = 0
    end
  end
  self._uiStatus.bIsDblClick = false
  for i = 1, self._uiStatus.NEED_JEWEL_NUM do
    self:FillNeedItem(selItemInfo, i)
  end
  self:FillDstItem(dstItemInfo)
  local imgRoot = ctrlRoot:FindDirect("Img_MoneyPay")
  local iconMoney = imgRoot:FindDirect("Img-Icon")
  local lblCostHint = imgRoot:FindDirect("Label_Text")
  local lblNeedMoney = imgRoot:FindDirect("Label_MoneyNum")
  local bIsNil = jewelItemCfg == nil
  imgRoot:SetActive(not bIsNil)
  if jewelItemCfg ~= nil then
    local moneyType = jewelItemCfg.nxtLvNeedMoneyType
    local needMoney = jewelItemCfg.nxtLvNeedMoneyNum
    local moneyData = CurrencyFactory.Create(moneyType)
    self._uiStatus.moneyType = moneyType
    GUIUtils.SetSprite(iconMoney, moneyData:GetSpriteName())
    GUIUtils.SetText(lblCostHint, txtConst[2]:format(moneyData:GetName()))
    GUIUtils.SetText(lblNeedMoney, needMoney)
    self:FillOwndMoney(moneyType)
    self:FillConsumeItems(jewelItemCfg.nxtLvNeedItemId, jewelItemCfg.nxtLvNeedItemNum)
  else
    self:FillConsumeItems(0, 0)
    self:FillOwndMoney(0)
  end
end
def.method("number", "number").FillConsumeItems = function(self, itemId, needNum)
  local ctrlRoot = self._uiGOs.compound:FindDirect("Img_MaterialBg")
  if itemId < 1 then
    ctrlRoot:SetActive(false)
  else
    ctrlRoot:SetActive(true)
    local icon = ctrlRoot:GetChild(0)
    local lblNum = ctrlRoot:FindDirect("Label_Num")
    local owndItemNum = ItemModule.Instance():GetItemCountById(itemId)
    local itemBase = ItemUtils.GetItemBase(itemId)
    icon.name = "Icon_Material_" .. itemId
    GUIUtils.SetTexture(icon, itemBase.icon)
    GUIUtils.SetText(lblNum, txtConst[10]:format(owndItemNum, needNum))
  end
end
def.method("number").FillOwndMoney = function(self, moneyType)
  local imgRoot = self._uiGOs.compound:FindDirect("Img_MoneyaHave")
  if moneyType < 1 then
    imgRoot:SetActive(false)
    return
  else
    imgRoot:SetActive(true)
  end
  local lblHint = imgRoot:FindDirect("Label_Text")
  local lblNum = imgRoot:FindDirect("Label_MoneyNum")
  local icon = imgRoot:FindDirect("Img-Icon")
  local moneyData = CurrencyFactory.Create(moneyType)
  local num = JewelMgr.GetMoneyNumByType(moneyType)
  GUIUtils.SetText(lblHint, txtConst[9])
  GUIUtils.SetText(lblNum, Int64.ToNumber(num))
  GUIUtils.SetSprite(icon, moneyData:GetSpriteName())
end
def.method("number", "boolean").GotoBuyMoney = function(self, mtype, bconfirm)
  if mtype == MoneyType.YUANBAO then
    _G.GotoBuyYuanbao()
  elseif mtype == MoneyType.GOLD then
    _G.GoToBuyGold(bconfirm)
  elseif mtype == MoneyType.SILVER then
    _G.GoToBuySilver(bconfirm)
  elseif mtype == MoneyType.GOLD_INGOT then
    _G.GoToBuyGoldIngot(bconfirm)
  end
end
def.method("table", "number").FillNeedItem = function(self, itemInfo, slotIdx)
  local ctrlRoot = self._uiGOs.compound:FindDirect("BS_Before")
  local ctrlSlot = ctrlRoot:FindDirect("Img_BgBs" .. slotIdx)
  local icon = ctrlSlot:GetChild(0)
  if itemInfo == nil then
    icon.name = "Icon_BS"
    GUIUtils.SetTexture(icon, 0)
  else
    icon.name = "Icon_BS_" .. slotIdx .. "_" .. itemInfo.itemId
    GUIUtils.SetTexture(icon, itemInfo.icon)
  end
end
def.method("table").FillDstItem = function(self, itemInfo)
  local ctrlRoot = self._uiGOs.compound:FindDirect("BS_After")
  local icon = ctrlRoot:GetChild(0)
  if itemInfo == nil then
    icon.name = "Icon_BS"
    GUIUtils.SetTexture(icon, 0)
  else
    icon.name = "Icon_BS_0_" .. itemInfo.itemId
    GUIUtils.SetTexture(icon, itemInfo.icon)
  end
end
def.method().EmptyCompoundSlots = function(self)
  self._uiStatus.curSlotIdx = 1
  for i = 1, self._uiStatus.NEED_JEWEL_NUM do
    self:FillNeedItem(nil, i)
  end
  self:FillDstItem(nil)
end
def.method().PlayFx = function(self)
  local effectCfg = GetEffectRes(constant.CSuperEquipmentConsts.GEM_MERGE_SFX_ID or 0)
  self._uiGOs.fx:SetActive(true)
  if nil == effectCfg then
    warn("Get JewelCompound fx failed ,no resource")
  else
    self._uiStatus.fx = GUIFxMan.Instance():PlayAsChildLayer(self._uiGOs.fx, effectCfg.path, "JewelCompound", 0, 0, 1, 1, 0, false)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("click id", id)
  local bIsClickFilterDlg = false
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_QuickCompound" then
    self:OnClickBtnAutoCompound()
  elseif id == "Btn_Compound" then
    self:OnClickBtnCompound()
  elseif id == "Toggle_Classify" then
    bIsClickFilterDlg = true
    if self._uiGOs.comFilterList.value then
      self:UpdateUIFilterList()
    end
  elseif id == "Btn_Money" then
    local moneyType = self._uiStatus.moneyType
    if moneyType and moneyType ~= 0 then
      self:GotoBuyMoney(moneyType, false)
    end
  elseif string.find(id, "Icon_Material_") then
    local strs = string.split(id, "_")
    local itemId = tonumber(strs[3])
    warn("itemId", itemId)
    self:ShowBasicTips(itemId, clickObj, true)
  elseif id == "BS_After" then
    self:OnClickDstJewel(clickObj)
  elseif string.find(id, "Prefab_%d") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[2] or "1")
    self._uiStatus.selFilterIdx = idx
    self:FilterByPropType(false)
    self:UpdateUIFilterList()
    self:UpdateUIJewelsList()
  elseif string.find(id, "Image_Item_%d") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self._uiStatus.selJewelIdx = idx
    local jewelItem = self._curJewelItems[idx]
    self:ShowTips(self._uiGOs.jewelList, jewelItem, false)
  elseif string.find(id, "Img_BgBs%d") then
    local iconName = clickObj:GetChild(0).name
    local strs = iconName.split(iconName, "_")
    local itemId = tonumber(strs[4])
    local item = self._curJewelItems[self._uiStatus.selLvUpIdx]
    if 0 < self._uiStatus.dstItemId then
      self:ShowTips(clickObj, item, true)
    end
  end
  if self._uiGOs ~= nil and not bIsClickFilterDlg then
    self._uiGOs.comFilterList.value = false
  end
end
def.method("userdata", "table", "boolean").ShowTips = function(self, clickObj, item, bShowBaic)
  if item ~= nil then
    local position = clickObj.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickObj:GetComponent("UISprite")
    local width = sprite:get_width()
    local height = sprite:get_height()
    if bShowBaic == true then
      self:ShowBasicTips(item.id, clickObj, false)
    else
      ItemTipsMgr.Instance():ShowJewelSpecialTips(item, screenPos.x, screenPos.y, width, height, 0, false)
    end
  end
end
def.method("number", "userdata", "boolean").ShowBasicTips = function(self, itemId, clickObj, bSource)
  if itemId > 0 then
    local position = clickObj.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = clickObj:GetComponent("UIWidget")
    local width = sprite:get_width()
    local height = sprite:get_height()
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, width, height, 0, bSource)
  end
end
def.method("string").onDoubleClick = function(self, id)
  if string.find(id, "Image_Item_%d") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[3])
    self:OnDoubleClickItem(idx)
  elseif string.find(id, "Img_BgBs") and self._uiStatus.dstItemId > 0 then
    self._uiStatus.selLvUpIdx = 0
    self._uiStatus.dstItemId = 0
    self._uiStatus.preSelJewelIdx = 0
    self:EmptyCompoundSlots()
  end
end
def.method("number").OnDoubleClickItem = function(self, idx)
  self._uiStatus.selLvUpIdx = idx
  self._uiStatus.bIsDblClick = true
  if idx ~= self._uiStatus.preSelJewelIdx then
    self:UpdateUIRight()
    self._uiStatus.preSelJewelIdx = idx
  else
    self._uiStatus.selLvUpIdx = 0
    self._uiStatus.preSelJewelIdx = 0
    self:EmptyCompoundSlots()
    self:UpdateUIRight()
  end
end
def.method("userdata").OnClickDstJewel = function(self, clickObj)
  local itemId = self._uiStatus.dstItemId or 0
  if itemId < 1 then
    return
  end
  self:ShowBasicTips(itemId, clickObj, false)
end
def.method().OnClickBtnAutoCompound = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local totalCurrency = Int64.ToNumber(JewelMgr.GetMoneyNumByType(MoneyType.SILVER))
  local cond = self:CaculateAutoCompoundCond(totalCurrency)
  if self._curJewelItems == nil or #self._curJewelItems < 1 or not cond.bExistCompoundItem then
    Toast(txtConst[25])
    return
  end
  if 1 > cond.canCompoundNum then
    if not cond.itemEnough then
      for itemId, num in pairs(cond.items) do
        local itemBase
        if itemId > 0 then
          itemBase = ItemUtils.GetItemBase(itemId)
          Toast(txtConst[41]:format(itemBase and itemBase.name or ""))
          return
        end
      end
    elseif not cond.moneyEnough then
      do
        local cond = self:CaculateAutoCompoundCond(4294967296)
        local moneyNum = cond.moneys[MoneyType.SILVER]
        local diffSilver = moneyNum - Int64.ToNumber(JewelMgr.GetMoneyNumByType(MoneyType.SILVER))
        local needYB = math.ceil(diffSilver / 10150)
        CommonConfirmDlg.ShowConfirm(txtConst[30], txtConst[56]:format(needYB, diffSilver, cond.maxLv + 1), function(select)
          if select == 1 then
            JewelProtocols.CSendAutoComposeAllJewel(cond.minLvItemId, true)
          end
        end, nil)
      end
    else
      Toast(txtConst[25])
    end
    return
  end
  local strContent = txtConst[35]
  local count = 0
  for itemId, num in pairs(cond.items) do
    local itemBase
    if itemId > 0 then
      itemBase = ItemUtils.GetItemBase(itemId)
    end
    if num > 0 then
      count = count + 1
      if count > 1 then
        strContent = strContent .. txtConst[42]
      end
      strContent = strContent .. txtConst[19]:format(num, itemBase and itemBase.name or "")
    end
  end
  for moneyType, num in pairs(cond.moneys) do
    if moneyType > 0 then
      local moneyData = CurrencyFactory.Create(moneyType)
      if strContent ~= txtConst[35] then
        strContent = strContent .. txtConst[42]
      end
      strContent = strContent .. txtConst[19]:format(num, moneyData:GetName())
    end
  end
  if strContent == txtConst[35] then
    Toast(txtConst[17])
    return
  end
  strContent = strContent .. txtConst[34]
  CommonConfirmDlg.ShowConfirm(txtConst[30], strContent, function(select)
    if select == 1 then
      JewelProtocols.CSendAutoComposeAllJewel(cond.minLvItemId, false)
    end
  end, nil)
end
def.method("number", "=>", "table").CaculateAutoCompoundCond = function(self, totalCurrency)
  local retData = {}
  retData.moneys = {}
  retData.items = {}
  retData.minLvItemId = 0
  local mapitemsMaxLv = {}
  local equipList = JewelMgr.GetData():GetHeroGodWeapons() or {}
  local items = self._curJewelItems
  local mapTmpItems = {}
  local needJewelNum = self._uiStatus.NEED_JEWEL_NUM
  local minLv, maxLv = 9999, -1
  for _, item in ipairs(items) do
    mapTmpItems[item.id] = mapTmpItems[item.id] or {}
    local tmpItem = mapTmpItems[item.id]
    local jewelBasic = JewelUtils.GetJewelItemByItemId(item.id, false)
    tmpItem.item = jewelBasic
    tmpItem.number = tmpItem.number and tmpItem.number + item.number or item.number
    if minLv > jewelBasic.level then
      minLv = jewelBasic.level
    end
    if maxLv < jewelBasic.level then
      maxLv = jewelBasic.level
    end
    local itemMaxLv = JewelMgr.GetData():GetEquipMaxLvByItemId(equipList, item.id)
    if maxLv < itemMaxLv then
      maxLv = itemMaxLv
    end
  end
  local existCompoundItem = false
  for itemId, itemInfo in pairs(mapTmpItems) do
    if needJewelNum <= itemInfo.number then
      existCompoundItem = true
      break
    end
  end
  retData.bExistCompoundItem = existCompoundItem
  if not existCompoundItem then
    return retData
  end
  retData.canCompoundNum = 0
  retData.moneyEnough = true
  retData.itemEnough = true
  retData.maxLv = 0
  for lv = minLv, maxLv do
    for itemId, itemInfo in pairs(mapTmpItems) do
      local itemMaxLv = JewelMgr.GetData():GetEquipMaxLvByItemId(equipList, itemId)
      if itemInfo.item.level == lv and itemMaxLv > itemInfo.item.level then
        if lv == minLv then
          retData.minLvItemId = itemId
        end
        local canCompoundNum = math.floor(itemInfo.number / needJewelNum)
        local nxtLvItemId = itemInfo.item.nxtLvItemId
        local costItemId = itemInfo.item.nxtLvNeedItemId
        local costItemNum = itemInfo.item.nxtLvNeedItemNum
        if costItemNum > 0 then
          local owndItemNum = ItemModule.Instance():GetItemCountById(itemInfo.item.nxtLvNeedItemId) - (retData.items[costItemId] or 0)
          if costItemNum > owndItemNum then
            retData.itemEnough = false
            retData.itemId = costItemId
            return retData
          end
          canCompoundNum = math.min(math.floor(owndItemNum / costItemNum), canCompoundNum)
          costItemNum = canCompoundNum * costItemNum
        end
        local moneyType = itemInfo.item.nxtLvNeedMoneyType
        local moneyNum = itemInfo.item.nxtLvNeedMoneyNum
        local owndMoney = totalCurrency - (retData.moneys[moneyType] or 0)
        if moneyNum > owndMoney then
          retData.moneyEnough = false
          retData.moneyType = moneyType
          return retData
        end
        canCompoundNum = math.min(math.floor(owndMoney / moneyNum), canCompoundNum)
        moneyNum = canCompoundNum * moneyNum
        local leftNum = itemInfo.number - canCompoundNum * needJewelNum
        mapTmpItems[itemId].number = leftNum
        if nxtLvItemId > 0 then
          if mapTmpItems[nxtLvItemId] == nil then
            mapTmpItems[nxtLvItemId] = {}
            mapTmpItems[nxtLvItemId].item = JewelUtils.GetJewelItemByItemId(nxtLvItemId, false)
          end
          mapTmpItems[nxtLvItemId].number = mapTmpItems[nxtLvItemId].number and mapTmpItems[nxtLvItemId].number + canCompoundNum or canCompoundNum
          if canCompoundNum > 0 then
            retData.moneys[moneyType] = retData.moneys[moneyType] and retData.moneys[moneyType] + moneyNum or moneyNum
            retData.items[costItemId] = retData.items[costItemId] and retData.items[costItemId] + costItemNum or costItemNum
            retData.canCompoundNum = retData.canCompoundNum + canCompoundNum
            if itemInfo.item.level > retData.maxLv then
              retData.maxLv = itemInfo.item.level
            end
          end
        end
      end
    end
  end
  return retData
end
def.method().OnClickBtnCompound = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local selItemInfo = self._curJewelItems[self._uiStatus.selLvUpIdx]
  local uiStatus = self._uiStatus
  if selItemInfo == nil then
    Toast(txtConst[3])
    return
  end
  local equips = JewelMgr.GetData():GetHeroGodWeapons()
  local maxLv = JewelMgr.GetData():GetEquipMaxLvByItemId(equips, selItemInfo.id)
  local jewelBasic = JewelUtils.GetJewelItemByItemId(selItemInfo.id, false)
  if maxLv <= jewelBasic.level then
    Toast(txtConst[24])
    return
  end
  local itemNum = ItemModule.Instance():GetItemCountById(selItemInfo.id or 0)
  if itemNum < self._uiStatus.NEED_JEWEL_NUM then
    Toast(txtConst[25])
    return
  end
  local bCanCompound, whats = JewelMgr.CanToCompound(jewelBasic)
  if not bCanCompound then
    if whats.itemId and 0 < whats.itemId then
      local itemBase = ItemUtils.GetItemBase(itemId)
      if itemBase ~= nil then
        Toast(txtConst[38]:format(itemBase.name))
      end
    elseif whats.moneyType ~= nil then
      JewelMgr.GotoBuyMoney(whats.moneyType, true)
    else
      Toast(txtConst[23])
    end
    return
  end
  JewelProtocols.CSendComposeJewel(selItemInfo.id)
end
def.method("table").OnJewelBagChange = function(self, p)
  self:_fillPropsMap()
  self:UpdateUI()
end
def.method("table").OnAutoCompoundFeatureChg = function(self, p)
  self:_checkFeature()
end
def.method("table").OnCompoundSuccess = function(self, p)
  if self._uiStatus.dstItemId ~= 0 then
    self:PlayFx()
  end
  Toast(txtConst[36])
end
def.method("table").OnMoneyChange = function(self, p)
  if self._uiStatus.dstItemId ~= 0 then
    self:UpdateUIRight()
  end
end
return UIJewelBag.Commit()
