local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local JiuZhouFuDaiMgr = require("Main.activity.JiuZhouFuDai.JiuZhouFuDaiMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local FuDaiData = require("Main.activity.JiuZhouFuDai.data.FuDaiData")
local FuDaiProtocols = require("Main.activity.JiuZhouFuDai.FuDaiProtocols")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local LuckyBagType = require("consts.mzm.gsp.luckybag.confbean.LuckyBagType")
local FuYuanExchangePanel = Lplus.Extend(ECPanelBase, "FuYuanExchangePanel")
local def = FuYuanExchangePanel.define
local instance
def.static("=>", FuYuanExchangePanel).Instance = function()
  if instance == nil then
    instance = FuYuanExchangePanel()
  end
  return instance
end
def.field("table")._uiObjs = nil
def.static().ShowDlg = function()
  if not JiuZhouFuDaiMgr.Instance():IsOpen() then
    if FuYuanExchangePanel.Instance():IsShow() then
      FuYuanExchangePanel.Instance():DestroyPanel()
    end
    return
  end
  if not JiuZhouFuDaiMgr.Instance():IsActOpen() then
    Toast(textRes.JiuZhouFuDai.SOpenLuckyBagFailed[-4])
    if FuYuanExchangePanel.Instance():IsShow() then
      FuYuanExchangePanel.Instance():DestroyPanel()
    end
    return
  end
  if FuYuanExchangePanel.Instance():IsShow() then
    return
  end
  FuYuanExchangePanel.Instance():CreatePanel(RESPATH.PREFAB_FUYUANDUIHUAN_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Num = self.m_panel:FindDirect("Img_Bg0/Label_Credits/Label_Num")
  self._uiObjs.Scroll_View_LeiDeng = self.m_panel:FindDirect("Img_Bg0/Scroll View_LeiDeng")
  self._uiObjs.List_LeiDeng = self._uiObjs.Scroll_View_LeiDeng:FindDirect("List_LeiDeng")
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
end
def.override("boolean").OnShow = function(self, show)
  self:HandleEventListeners(show)
  if show then
    self:_UpdateCredits()
    self:_ShowExchangeItems()
  end
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_FuYuan_Change, FuYuanExchangePanel.OnCreditChange)
  end
end
def.static("table", "table").OnCreditChange = function(self, param, context)
  FuYuanExchangePanel.Instance():_UpdateCredits()
end
def.method()._UpdateCredits = function(self)
  GUIUtils.SetText(self._uiObjs.Label_Num, FuDaiData.Instance():GetCredit())
end
def.method()._ShowExchangeItems = function(self)
  local exchangeCfgList = FuDaiData.Instance():GetExchangeCfgs()
  if exchangeCfgList then
    local itemCount = #exchangeCfgList
    local uiList = self._uiObjs.List_LeiDeng:GetComponent("UIList")
    uiList.itemCount = itemCount
    uiList:Resize()
    uiList:Reposition()
    local exchangeCfg, listitem
    for i = 1, itemCount do
      exchangeCfg = exchangeCfgList[i]
      listitem = self._uiObjs.List_LeiDeng:FindDirect("item_" .. i)
      self:_ShowItem(i, exchangeCfg, listitem)
    end
    self:TouchGameObject(self.m_panel, self.m_parent)
  else
    warn("[FuYuanExchangePanel:_ShowExchangeItems] JiuZhouFuDaiMgr.Instance():GetExchangeCfgs() nil!")
    local uiList = self._uiObjs.List_LeiDeng:GetComponent("UIList")
    uiList.itemCount = 0
    uiList:Resize()
    uiList:Reposition()
  end
end
def.method("number", "table", "userdata")._ShowItem = function(self, index, exchangeCfg, listitem)
  if nil == exchangeCfg then
    warn("[FuYuanExchangePanel:_ShowItem] exchangeCfg nil at index:", index)
    return
  end
  if nil == listitem then
    warn("[FuYuanExchangePanel:_ShowItem] listitem nil at index:", index)
    return
  end
  local representItem = exchangeCfg.itemList[1]
  local itemId = representItem and representItem.itemId or 0
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase then
    local itemName = itemBase.name
    local color = HtmlHelper.NameColor[itemBase.namecolor]
    if color then
      itemName = string.format("[%s]%s[-]", color, itemName)
    end
    local Label_Name = listitem:FindDirect("Label")
    GUIUtils.SetText(Label_Name, itemName)
    local Texture_Icon = listitem:FindDirect("Img_BgIcon1/Texture_Icon")
    GUIUtils.SetTexture(Texture_Icon, itemBase.icon)
    local Label_Num = listitem:FindDirect("Img_BgIcon1/Label_Num")
    GUIUtils.SetText(Label_Num, exchangeCfg.num or "")
    local Label_Cost = listitem:FindDirect("Label_Num")
    GUIUtils.SetText(Label_Cost, exchangeCfg.scoreValue)
  else
    warn("[FuYuanExchangePanel:_ShowItem] itemBase nil for awardId:", exchangeCfg.awardId)
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Get" then
    self:OnBtn_Get(obj)
  elseif id == "Texture_Icon" then
    self:OnTextureObjClicked(obj)
  elseif id == "Btn_Close" or id == "Modal" then
    self:OnBtn_Close()
  elseif id == "Btn_Tip" then
    self:OnBtn_Tip()
  end
end
def.method().OnBtn_Close = function(self)
  self:DestroyPanel()
end
def.method().OnBtn_Tip = function(self)
  local fudaiCfg = FuDaiData.Instance():GetFuDaiCfgByType(LuckyBagType.BOX)
  if fudaiCfg then
    local tipContent = require("Main.Common.TipsHelper").GetHoverTip(fudaiCfg.tipId)
    local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
    CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
  else
    warn("[FuYuanExchangePanel:OnBtn_Tip] fudaiCfg nil for LuckyBagType.BOX.")
  end
end
def.method("userdata").OnBtn_Get = function(self, obj)
  local id = obj.parent.name
  local index = tonumber(string.sub(id, #"item_" + 1, -1))
  if index == nil then
    return
  end
  local exchangeCfg = FuDaiData.Instance():GetExchangeItemByIndex(index)
  if exchangeCfg then
    do
      local scoreValue = exchangeCfg.scoreValue
      local cfgId = exchangeCfg.id
      local curCredit = FuDaiData.Instance():GetCredit()
      if scoreValue > curCredit then
        Toast(textRes.JiuZhouFuDai.FuYuanExchange.ERROR_SCORE_NOT_ENOUGH)
        return
      end
      local representItem = exchangeCfg.itemList[1]
      local creditIcon = FuDaiData.Instance():GetCreditIconId()
      require("Main.Exchange.ui.ExchangeConfirmPanel").Instance():ShowPanelWithCurrenyIconId(representItem.itemId, 1, creditIcon, scoreValue, -1, function(num)
        local needScore = num * scoreValue
        if needScore > FuDaiData.Instance():GetCredit() then
          Toast(textRes.JiuZhouFuDai[11])
          return false
        end
        FuDaiProtocols.SendCExchangeScore(cfgId, curCredit, num)
        return true
      end)
    end
  end
end
def.method("userdata").OnTextureObjClicked = function(self, obj)
  local id = obj.parent.parent.name
  local index = tonumber(string.sub(id, #"item_" + 1, -1))
  if index == nil then
    return
  end
  local exchangeCfg = FuDaiData.Instance():GetExchangeItemByIndex(index)
  if exchangeCfg then
    local representItem = exchangeCfg.itemList[1]
    local itemId = representItem.itemId
    local anchorGO = obj.parent
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, anchorGO, 0, false)
  end
end
FuYuanExchangePanel.Commit()
return FuYuanExchangePanel
