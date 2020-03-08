local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DailyGiftAwardPanel = Lplus.Extend(ECPanelBase, "DailyGiftAwardPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local DailyGiftMgr = require("Main.Award.mgr.DailyGiftMgr")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local def = DailyGiftAwardPanel.define
def.const("number").HELP_TIPS_ID = 701609102
def.field("table").uiObjs = nil
def.field("table").awardItems = nil
local instance
def.static("=>", DailyGiftAwardPanel).Instance = function()
  if instance == nil then
    instance = DailyGiftAwardPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_DAILY_GIFT_PANEL, 0)
end
def.override().OnCreate = function(self)
  if self.m_panel == nil then
    return
  end
  self:InitUI()
  self:SetActivityInfo()
  self:SetFreeAwardStatus()
  self:SetAwardItemList()
  self:SetAwardStatus()
  self:ResetScrollViewPosition()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_UPDATE, DailyGiftAwardPanel.OnDailyGiftStatusChange)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_CHANGE, DailyGiftAwardPanel.OnDailyGiftChange)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_FREE_AWARD_CHANGE, DailyGiftAwardPanel.OnDailyGiftFreeAwardChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DailyGiftAwardPanel.OnFunctionOpenChange)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.awardItems = nil
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_UPDATE, DailyGiftAwardPanel.OnDailyGiftStatusChange)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_CHANGE, DailyGiftAwardPanel.OnDailyGiftChange)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_FREE_AWARD_CHANGE, DailyGiftAwardPanel.OnDailyGiftFreeAwardChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DailyGiftAwardPanel.OnFunctionOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Group_DayGift = self.m_panel:FindDirect("Group_DayGift")
  self.uiObjs.Label_Tip2 = self.uiObjs.Group_DayGift:FindDirect("Label_Tip2")
  self.uiObjs.Group_Gift = self.uiObjs.Group_DayGift:FindDirect("Group_Gift")
  self.uiObjs.Scrollview_Gift = self.uiObjs.Group_Gift:FindDirect("Scrollview_Gift")
  self.uiObjs.List_Item = self.uiObjs.Scrollview_Gift:FindDirect("List_Item")
  self.uiObjs.Btn_Get_Free = self.uiObjs.Group_DayGift:FindDirect("Btn_Get_Free")
  self.uiObjs.Img_HaveRecived = self.uiObjs.Group_DayGift:FindDirect("Img_HaveRecived")
  self.uiObjs.Label_FreeAward = self.uiObjs.Group_DayGift:FindDirect("Label")
end
def.method().SetActivityInfo = function(self)
  GUIUtils.SetText(self.uiObjs.Label_Tip2, DailyGiftMgr.Instance():GetActivityTimeInfo())
end
def.method().SetFreeAwardStatus = function(self)
  local mgr = DailyGiftMgr.Instance()
  if not mgr:IsFreeAwardOpen() then
    GUIUtils.SetActive(self.uiObjs.Label_FreeAward, false)
    GUIUtils.SetActive(self.uiObjs.Img_HaveRecived, false)
    GUIUtils.SetActive(self.uiObjs.Btn_Get_Free, false)
  else
    GUIUtils.SetActive(self.uiObjs.Label_FreeAward, true)
    if not mgr:CanReceiveFreeAward() then
      GUIUtils.SetActive(self.uiObjs.Img_HaveRecived, true)
      GUIUtils.SetActive(self.uiObjs.Btn_Get_Free, false)
    else
      GUIUtils.SetActive(self.uiObjs.Img_HaveRecived, false)
      GUIUtils.SetActive(self.uiObjs.Btn_Get_Free, true)
    end
  end
end
def.method().SetAwardItemList = function(self)
  self.awardItems = {}
  local dailyGiftMgr = DailyGiftMgr.Instance()
  local giftItemsData = dailyGiftMgr:GetDailyGiftItems()
  local uiList = self.uiObjs.List_Item:GetComponent("UIList")
  local itemCount = #giftItemsData
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isGift18Open = _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_RMB_GIFT_BAG_18)
  if not isGift18Open and itemCount > 3 then
    itemCount = 3 or itemCount
  end
  uiList.itemCount = itemCount
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local giftItem = uiItems[i]
    self:FillAwardItemInfo(i, giftItem, giftItemsData[i])
    self:SetAwardItemInfo(i, giftItemsData[i], giftItem)
  end
end
def.method("number", "userdata", "table").FillAwardItemInfo = function(self, idx, item, giftItemData)
  if item == nil then
    return
  end
  local itemInfo = giftItemData.giftItemInfo
  if itemInfo == nil then
    GUIUtils.SetActive(item, false)
  else
    GUIUtils.SetActive(item, true)
    local Label_Name = item:FindDirect("Label_Name_" .. idx)
    local Img_Yuan = item:FindDirect("Img_Yuan_" .. idx)
    local Img_Info = item:FindDirect("Img_Info_" .. idx)
    local Img_BgIcon = item:FindDirect("Img_BgIcon1_" .. idx)
    local Texture_Icon = Img_BgIcon:FindDirect("Texture_Icon_" .. idx)
    local Label_Num = Img_BgIcon:FindDirect("Label_Num_" .. idx)
    local Btn_Buy_Label = item:FindDirect(string.format("Btn_Buy_%d/Label_%d", idx, idx))
    GUIUtils.SetText(Label_Name, giftItemData.title)
    GUIUtils.SetSprite(Img_Info, string.format("Label_Info%02d", giftItemData.tier))
    GUIUtils.SetSprite(Img_Yuan, string.format("Label_Yuan%02d", giftItemData.tier))
    GUIUtils.SetText(Label_Num, itemInfo.num)
    GUIUtils.SetTexture(Texture_Icon, giftItemData.icon)
    local frameName = "Frame_" .. giftItemData.frame
    GUIUtils.SetSprite(item, frameName)
    GUIUtils.SetText(Btn_Buy_Label, textRes.Award[76])
  end
end
def.method("number", "table", "userdata").SetAwardItemInfo = function(self, idx, giftItemData, itemView)
  local awardInfo = {}
  awardInfo.giftItemData = giftItemData
  awardInfo.itemView = itemView
  self.awardItems[idx] = awardInfo
end
def.method().SetAwardStatus = function(self)
  for idx, awardInfo in pairs(self.awardItems) do
    local tier = awardInfo.giftItemData.tier
    local itemView = awardInfo.itemView
    local awardStatusData = DailyGiftMgr.Instance():GetAwardStatusDataByTier(tier)
    local Btn_Get = itemView:FindDirect("Btn_Get_" .. idx)
    local Btn_Buy = itemView:FindDirect("Btn_Buy_" .. idx)
    local Img_HaveBuy = itemView:FindDirect("Img_HaveBuy_" .. idx)
    if awardStatusData ~= nil then
      if awardStatusData.buy_times > awardStatusData.award_times then
        self:SetButtonEnabled(Btn_Get, true)
        GUIUtils.SetActive(Btn_Get, true)
        GUIUtils.SetActive(Btn_Buy, false)
        GUIUtils.SetActive(Img_HaveBuy, false)
      elseif awardInfo.giftItemData.maxBuyTimes > 0 and awardStatusData.buy_times >= awardInfo.giftItemData.maxBuyTimes then
        GUIUtils.SetActive(Btn_Get, false)
        GUIUtils.SetActive(Btn_Buy, false)
        GUIUtils.SetActive(Img_HaveBuy, true)
      else
        GUIUtils.SetActive(Btn_Get, false)
        GUIUtils.SetActive(Btn_Buy, true)
        GUIUtils.SetActive(Img_HaveBuy, false)
        if awardStatusData.waiting then
          self:SetButtonEnabled(Btn_Buy, false)
        else
          self:SetButtonEnabled(Btn_Buy, true)
        end
      end
    else
      warn("\230\156\170\230\137\190\229\136\176\229\175\185\229\186\148\230\161\163\228\189\141\229\165\150\229\138\177\228\191\161\230\129\175")
      GUIUtils.SetActive(Btn_Get, false)
      GUIUtils.SetActive(Btn_Buy, false)
      GUIUtils.SetActive(Img_HaveBuy, true)
    end
  end
end
def.method().ResetScrollViewPosition = function(self)
  GameUtil.AddGlobalTimer(0, true, function()
    if self.uiObjs and self.uiObjs.Scrollview_Gift then
      local uiScrollView = self.uiObjs.Scrollview_Gift:GetComponent("UIScrollView")
      if uiScrollView then
        uiScrollView:ResetPosition()
      end
    end
  end)
end
def.method("number", "userdata").ShowAwardItemTips = function(self, idx, source)
  if self.awardItems[idx].giftItemData.giftItemInfo == nil then
    return
  end
  local giftItemId = self.awardItems[idx].giftItemData.giftItemInfo.itemId
  local position = source:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = source:GetComponent("UIWidget")
  ItemTipsMgr.Instance():ShowBasicTips(giftItemId, screenPos.x, screenPos.y, widget.width, widget.height, 0, false)
end
def.method("number").BuyGiftAward = function(self, awardIdx)
  DailyGiftMgr.Instance():BuyGiftAward(awardIdx)
end
def.method("number").GetGiftAward = function(self, awardIdx)
  DailyGiftMgr.Instance():GetGiftAward(awardIdx)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Get_Free" then
    self:GetFreeAward()
  elseif string.find(id, "Img_BgIcon1_") then
    local awardIdx = tonumber(string.sub(id, #"Img_BgIcon1_" + 1))
    self:ShowAwardItemTips(awardIdx, obj)
  elseif string.find(id, "Btn_Get_") then
    local awardIdx = tonumber(string.sub(id, #"Btn_Get_" + 1))
    self:GetGiftAward(awardIdx)
  elseif string.find(id, "Btn_Buy_") then
    local awardIdx = tonumber(string.sub(id, #"Btn_Buy_" + 1))
    self:BuyGiftAward(awardIdx)
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.DAILGIFT, {awardIdx})
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Tips" then
    self:ShowHelpTips()
  end
end
def.method().ShowHelpTips = function(self)
  local desc = DailyGiftMgr.Instance():GetDailyGiftDescription()
  local CommonDescDlg = require("GUI.CommonUITipsDlg")
  CommonDescDlg.ShowCommonTip(desc, {x = 0, y = 0})
end
def.method().GetFreeAward = function(self)
  DailyGiftMgr.Instance():GetFreeAward()
end
def.method("userdata", "boolean").SetButtonEnabled = function(self, btn, enable)
  btn:GetComponent("UIButton"):set_isEnabled(enable)
end
def.static("table", "table").OnDailyGiftStatusChange = function(params, context)
  instance:SetAwardStatus()
end
def.static("table", "table").OnDailyGiftChange = function(params, context)
  instance:SetAwardItemList()
end
def.static("table", "table").OnDailyGiftFreeAwardChange = function(params, context)
  instance:SetFreeAwardStatus()
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1.feature == ModuleFunSwitchInfo.TYPE_RMB_GIFT_BAG_18 then
    instance:SetAwardItemList()
    instance:SetAwardStatus()
  end
end
return DailyGiftAwardPanel.Commit()
