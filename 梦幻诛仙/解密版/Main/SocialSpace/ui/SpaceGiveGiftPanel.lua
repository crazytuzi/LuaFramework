local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceGiveGiftPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceGiveGiftPanel.define
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECDebugOption = require("Main.ECDebugOption")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemPriceHelper = require("Main.Item.ItemPriceHelper")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
def.field("table").m_UIGOs = nil
def.field("table").m_gifts = nil
def.field("table").m_grades = nil
def.field("number").m_selGiftIndex = 0
def.field("number").m_selGradeIndex = 0
def.field("boolean").m_canUseYuanbao = false
def.field("userdata").m_targetRoleId = nil
local instance
def.static("=>", SpaceGiveGiftPanel).Instance = function()
  if instance == nil then
    instance = SpaceGiveGiftPanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, targetRoleId)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_targetRoleId = targetRoleId
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_GIVE_GIFT_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  self:UpdateUI()
  self:SelectDefaults()
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, self.OnItemChange, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, self.OnItemChange)
  self.m_UIGOs = nil
  self.m_gifts = nil
  self.m_grades = nil
  self.m_canUseYuanbao = false
  self.m_targetRoleId = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Buy" then
    self:OnClickBtnBuy()
  elseif id:find("Btn_Num_") then
    local index = tonumber(id:split("_")[3])
    if index then
      self:SelectGrade(index)
    end
  elseif id:find("Img_BgGift_") then
    local index = tonumber(id:split("_")[3])
    if index then
      self:SelectGift(index)
    end
  elseif id:find("Texture_") and obj.parent.name:find("Group_Icon_") then
    self:OnClickItemTexture(obj)
  elseif id:find("Img_Icon_") and obj.parent.name:find("Group_Pop_") then
    self:OnClickPopTexture(obj)
  elseif id == "Btn_YuanbaoUse" then
    self:OnClickYuanbaoUseBtn(obj)
  end
end
def.method().InitData = function(self)
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Group_Gift = self.m_UIGOs.Img_Bg0:FindDirect("Group_Gift")
  self.m_UIGOs.Group_Num = self.m_UIGOs.Img_Bg0:FindDirect("Group_Num")
  self.m_UIGOs.Group_Bottom = self.m_UIGOs.Img_Bg0:FindDirect("Group_Bottom")
  self.m_UIGOs.Label_Tips = self.m_UIGOs.Img_Bg0:FindDirect("Label_Tips")
  self.m_UIGOs.Scrollview_Gift = self.m_UIGOs.Group_Gift:FindDirect("Scrollview_Gift")
  self.m_UIGOs.List_Gift = self.m_UIGOs.Scrollview_Gift:FindDirect("List_Gift")
  self.m_UIGOs.List_Num = self.m_UIGOs.Group_Num:FindDirect("List_Num")
end
def.method().UpdateUI = function(self)
  self:UpdateGiftList()
  self:UpdateGrades()
  self:UpdateTips()
end
def.method().UpdateGiftList = function(self)
  local gifts
  if self.m_gifts == nil then
    self.m_gifts = self:GetAllGifts()
  end
  gifts = self.m_gifts
  local itemCount = #gifts
  local uiList = self.m_UIGOs.List_Gift:GetComponent("UIList")
  uiList:set_itemCount(itemCount)
  uiList:Resize()
  local itemGOs = uiList.children
  for i = 1, itemCount do
    local itemGO = itemGOs[i]
    local giftInfo = gifts[i]
    self:SetGiftItemInfo(i, itemGO, giftInfo)
  end
end
def.method("number", "userdata", "table").SetGiftItemInfo = function(self, idx, itemGO, giftInfo)
  local Label_Name = itemGO:FindDirect(("Img_Label_%d/Label_Name_%d"):format(idx, idx))
  local Group_Icon = itemGO:FindDirect(("Group_Icon_%d"):format(idx))
  local Texture = Group_Icon:FindDirect(("Texture_%d"):format(idx))
  local Label_ItemNum = Group_Icon:FindDirect(("Label_Num_%d"):format(idx))
  local Img_Bg = Group_Icon:FindDirect(("Img_Bg_%d"):format(idx))
  local Group_Pop = itemGO:FindDirect(("Group_Pop_%d"):format(idx))
  local Label_PopNum = Group_Pop:FindDirect(("Label_Num_%d"):format(idx))
  GUIUtils.SetText(Label_Name, giftInfo.name)
  GUIUtils.SetTexture(Texture, giftInfo.iconId)
  GUIUtils.SetSprite(Img_Bg, giftInfo.cellSprite)
  local haveNumText
  if giftInfo.haveNum <= 0 then
    haveNumText = string.format("[ff0000]%s[-]", giftInfo.haveNum)
  else
    haveNumText = giftInfo.haveNum
  end
  GUIUtils.SetText(Label_ItemNum, haveNumText)
  local addPopText = string.format("+%d", giftInfo.addPopValue)
  GUIUtils.SetText(Label_PopNum, addPopText)
end
def.method().UpdateGrades = function(self)
  local grades = self:GetAllGrades()
  self.m_grades = grades
  local itemCount = #self.m_grades
  local uiList = self.m_UIGOs.List_Num:GetComponent("UIList")
  uiList:set_itemCount(itemCount)
  uiList:Resize()
  local itemGOs = uiList.children
  for i = 1, itemCount do
    local itemGO = itemGOs[i]
    local gradeInfo = grades[i]
    self:SetGradeItemInfo(i, itemGO, gradeInfo)
  end
end
def.method("number", "userdata", "table").SetGradeItemInfo = function(self, idx, itemGO, gradeInfo)
  local Label_PresentNum = itemGO:FindDirect(("Label_%d"):format(idx))
  local text = textRes.SocialSpace[99]:format(gradeInfo.presentNum)
  GUIUtils.SetText(Label_PresentNum, text)
end
def.method().UpdateTips = function(self)
  GUIUtils.SetText(self.m_UIGOs.Label_Tips, textRes.SocialSpace[98])
end
def.method().SelectDefaults = function(self)
  self:SelectGift(1)
  self:SelectGrade(1)
end
def.method("number").SelectGift = function(self, index)
  local Img_BgGift = self.m_UIGOs.List_Gift:FindDirect(("Group_Good_%d/Img_BgGift_%d"):format(index, index))
  if Img_BgGift == nil then
    return
  end
  GUIUtils.Toggle(Img_BgGift, true)
  self.m_selGiftIndex = index
  self:UpdateSelectedPrices()
end
def.method("number").SelectGrade = function(self, index)
  local Btn_Num = self.m_UIGOs.List_Num:FindDirect(("Btn_Num_%d"):format(index))
  if Btn_Num == nil then
    return
  end
  GUIUtils.Toggle(Btn_Num, true)
  self.m_selGradeIndex = index
  self:UpdateSelectedPrices()
end
def.method().UpdateSelectedPrices = function(self)
  if self.m_selGradeIndex == 0 or self.m_selGiftIndex == 0 then
    return
  end
  local giftIndex = self.m_selGiftIndex
  local giftInfo = self.m_gifts[giftIndex]
  if giftInfo.price then
    self:DoUpdateSelectedPrices()
  else
    self:DoUpdateSelectedPrices()
    ItemPriceHelper.GetItemsYuanbaoPriceAsync({
      giftInfo.itemId
    }, function(itemId2Yuanbao)
      if not self:IsLoaded() then
        return
      end
      giftInfo.price = itemId2Yuanbao[giftInfo.itemId]
      if giftIndex ~= self.m_selGiftIndex then
        return
      end
      self:DoUpdateSelectedPrices()
    end)
  end
end
def.method().DoUpdateSelectedPrices = function(self)
  local Btn_YuanbaoUse = self.m_UIGOs.Group_Bottom:FindDirect("Btn_YuanbaoUse")
  local Group_Money = self.m_UIGOs.Group_Bottom:FindDirect("Group_Money")
  local Group_UseMoney = Group_Money:FindDirect("Group_UseMoney")
  local Label_UseMoneyNum = Group_UseMoney:FindDirect("Label_UseMoneyNum")
  local purchaseInfo = self:GetCurPurchaseInfo()
  local isItemNotEnough = not purchaseInfo.itemEnough
  GUIUtils.SetActive(Btn_YuanbaoUse, isItemNotEnough)
  if purchaseInfo.priceInited then
    local totalPrice = purchaseInfo.totalPrice
    GUIUtils.SetText(Label_UseMoneyNum, totalPrice)
  else
    GUIUtils.SetText(Label_UseMoneyNum, "---")
  end
  self:UpdateBuyBtnState()
end
def.method().OnClickBtnBuy = function(self)
  if self.m_selGiftIndex == 0 or self.m_selGiftIndex == 0 then
    return
  end
  local purchaseInfo = self:GetCurPurchaseInfo()
  if not purchaseInfo.priceInited then
    Toast(textRes.SocialSpace[100])
    return
  end
  if purchaseInfo.itemEnough then
    self:PrepareSendGift()
  elseif self.m_canUseYuanbao then
    if purchaseInfo.yuanbaoEnough then
      self:PrepareSendGift()
    else
      _G.GotoBuyYuanbao()
    end
  else
    CommonConfirmDlg.ShowConfirm(textRes.Common[8], textRes.SocialSpace[101], function(s)
      if s == 1 then
        self:SetCanUseYuanbao(true)
      end
    end, nil)
  end
end
def.method("boolean").SetCanUseYuanbao = function(self, isUseYuanbao)
  self.m_canUseYuanbao = isUseYuanbao
  local Btn_YuanbaoUse = self.m_UIGOs.Group_Bottom:FindDirect("Btn_YuanbaoUse")
  GUIUtils.Toggle(Btn_YuanbaoUse, isUseYuanbao)
  self:UpdateBuyBtnState()
end
def.method().UpdateBuyBtnState = function(self)
  if self.m_selGiftIndex == 0 or self.m_selGiftIndex == 0 then
    return
  end
  local Btn_Buy = self.m_UIGOs.Group_Bottom:FindDirect("Btn_Buy")
  local Label_Name = Btn_Buy:FindDirect("Label_Name")
  local Group_MoneyMake = Btn_Buy:FindDirect("Group_MoneyMake")
  local Label_MoneyMake = Group_MoneyMake:FindDirect("Label_MoneyMake")
  local purchaseInfo = self:GetCurPurchaseInfo()
  local useYuanbao = self.m_canUseYuanbao and not purchaseInfo.itemEnough
  GUIUtils.SetActive(Label_Name, not useYuanbao)
  GUIUtils.SetActive(Group_MoneyMake, useYuanbao)
  if useYuanbao then
    local moneyText
    if purchaseInfo.priceInited then
      moneyText = purchaseInfo.yuanbaoCostNum
    else
      moneyText = "--"
    end
    GUIUtils.SetText(Label_MoneyMake, moneyText)
  else
    GUIUtils.SetText(Label_Name, textRes.SocialSpace[102])
  end
end
def.method("=>", "table").GetAllGifts = function(self)
  local giftPopCfgs = SocialSpaceUtils.GetAllPresentPopularCfgs()
  local gifts = {}
  for i, v in ipairs(giftPopCfgs) do
    local itemBase = ItemUtils.GetItemBase(v.itemId)
    local giftInfo = {
      itemId = v.itemId
    }
    if itemBase then
      giftInfo.name = itemBase.name
      giftInfo.iconId = itemBase.icon
      giftInfo.cellSprite = GUIUtils.GetItemCellSpriteName(itemBase.namecolor)
    else
      giftInfo.name = "nil"
      giftInfo.iconId = 0
      giftInfo.cellSprite = "nil"
    end
    giftInfo.addPopValue = v.addPopValue
    giftInfo.haveNum = ItemModule.Instance():GetItemCountById(v.itemId)
    gifts[i] = giftInfo
  end
  return gifts
end
def.method("=>", "table").GetAllGrades = function(self)
  return SocialSpaceUtils.GetAllPresentGradCfgs()
end
def.method("=>", "table").GetCurPurchaseInfo = function(self)
  local purchaseInfo = {
    canBuy = false,
    itemEnough = false,
    yuanbaoEnough = false,
    yuanbaoCostNum = 0
  }
  if self.m_selGiftIndex == 0 or self.m_selGiftIndex == 0 then
    return purchaseInfo
  end
  local giftInfo = self.m_gifts[self.m_selGiftIndex]
  local gradeInfo = self.m_grades[self.m_selGradeIndex]
  local itemHaveNum = ItemModule.Instance():GetItemCountById(giftInfo.itemId)
  local itemLackNum = math.max(0, gradeInfo.presentNum - itemHaveNum)
  if itemLackNum > 0 then
    if self.m_canUseYuanbao and giftInfo.price then
      local yuanbaoNeedNum = itemLackNum * giftInfo.price
      local haveYuanbao = ItemModule.Instance():GetAllYuanBao()
      local yuanbaoLackNum = math.max(0, (Int64.new(yuanbaoNeedNum) - haveYuanbao):ToNumber())
      if yuanbaoLackNum == 0 then
        purchaseInfo.yuanbaoEnough = true
        purchaseInfo.canBuy = true
      end
      purchaseInfo.yuanbaoCostNum = yuanbaoNeedNum
    end
  else
    purchaseInfo.itemEnough = true
    purchaseInfo.canBuy = true
  end
  purchaseInfo.priceInited = giftInfo.price ~= nil
  purchaseInfo.price = giftInfo.price
  if purchaseInfo.priceInited then
    purchaseInfo.totalPrice = purchaseInfo.price * gradeInfo.presentNum
  end
  purchaseInfo.giftInfo = giftInfo
  purchaseInfo.gradeInfo = gradeInfo
  return purchaseInfo
end
def.method().PrepareSendGift = function(self)
  local SpaceGiftLeaveMsgPanel = require("Main.SocialSpace.ui.SpaceGiftLeaveMsgPanel")
  local tip = textRes.SocialSpace[103]
  local giftInfo = self.m_gifts[self.m_selGiftIndex]
  local itemId = giftInfo.itemId
  local brodcastCfg = SocialSpaceUtils.GetPresentBrodcastCfg(itemId)
  if brodcastCfg then
    local grade = brodcastCfg.grades[1].grade
    local gradeCfg = SocialSpaceUtils.GetPresentGradeCfg(grade)
    local presentNum = gradeCfg and gradeCfg.presentNum or "<%=presentNum>"
    local itemBase = ItemUtils.GetItemBase(itemId)
    local itemName = itemBase and itemBase.name or "<%=itemName>"
    tip = tip .. textRes.SocialSpace[104]:format(presentNum, itemName)
  end
  SpaceGiftLeaveMsgPanel.Instance():ShowPanel(tip, function(msg)
    self:DoSendGift(msg)
    return true
  end)
end
def.method("string").DoSendGift = function(self, msg)
  if not self:IsLoaded() then
    return
  end
  local purchaseInfo = self:GetCurPurchaseInfo()
  if purchaseInfo.canBuy then
    local giftId = purchaseInfo.giftInfo.itemId
    local giftGrade = purchaseInfo.gradeInfo.grade
    local isUseYuanbao = not purchaseInfo.itemEnough
    local costYuanbao = purchaseInfo.yuanbaoCostNum
    ECSocialSpaceMan.Instance():SendGiftToRole(giftId, giftGrade, self.m_targetRoleId, msg, isUseYuanbao, costYuanbao)
  elseif self.m_canUseYuanbao then
    _G.GotoBuyYuanbao()
  else
    CommonConfirmDlg.ShowConfirm(textRes.Common[8], textRes.SocialSpace[101], function(s)
      if s == 1 then
        self:SetCanUseYuanbao(true)
      end
    end, nil)
  end
end
def.method("userdata").OnClickItemTexture = function(self, obj)
  local index = tonumber(obj.name:split("_")[2])
  if index then
    self:SelectGift(index)
  end
  local giftInfo = self.m_gifts[index]
  local itemId = giftInfo.itemId
  ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, obj, 0, true)
end
def.method("userdata").OnClickPopTexture = function(self, obj)
  local index = tonumber(obj.name:split("_")[3])
  if index then
    self:SelectGift(index)
  end
end
def.method("userdata").OnClickYuanbaoUseBtn = function(self, obj)
  local isChecked = GUIUtils.IsToggle(obj)
  self:SetCanUseYuanbao(isChecked)
end
def.method("table").OnItemChange = function(self, params)
  if self.m_gifts then
    for i, giftInfo in ipairs(self.m_gifts) do
      giftInfo.haveNum = ItemModule.Instance():GetItemCountById(giftInfo.itemId)
    end
  end
  self:UpdateGiftList()
  self:UpdateSelectedPrices()
end
return SpaceGiveGiftPanel.Commit()
