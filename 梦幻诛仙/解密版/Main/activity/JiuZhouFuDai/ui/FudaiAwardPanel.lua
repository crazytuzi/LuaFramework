local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local MallUtility = require("Main.Mall.MallUtility")
local FuDaiData = require("Main.activity.JiuZhouFuDai.data.FuDaiData")
local LuckyBagType = require("consts.mzm.gsp.luckybag.confbean.LuckyBagType")
local FuDaiUtils = require("Main.activity.JiuZhouFuDai.FuDaiUtils")
local JiuZhouFuDaiMgr = require("Main.activity.JiuZhouFuDai.JiuZhouFuDaiMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local FudaiAwardPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local def = FudaiAwardPanel.define
local instance
def.static("=>", FudaiAwardPanel).Instance = function()
  if instance == nil then
    instance = FudaiAwardPanel()
  end
  return instance
end
local DRAW_COUNT_TEN = 10
def.field("table")._uiObjs = nil
def.field("table")._awardItems = nil
def.field("number")._fudaiType = 0
def.field("number")._useYuanbaoType = 0
local PENDING_WAIT_SECONDS = 1
def.field("number")._pendingTimer = 0
def.field("boolean")._bPending = false
def.method("number", "table", "number").ShowPanel = function(self, fudaiType, getItems, useYBType)
  self._fudaiType = fudaiType
  self._awardItems = getItems
  self._useYuanbaoType = useYBType
  if FudaiAwardPanel.Instance():IsShow() then
    self:UpdateUI()
    return
  end
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_FUDAI_AWARD_PANEL, 2)
end
def.override().OnCreate = function(self)
  ItemModule.Instance():BlockItemGetEffect(true)
  require("Main.Item.ui.EasyUseDlg").Block(true)
  if self.m_panel == nil then
    return
  end
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self._uiObjs.Sprite_Title = self._uiObjs.Img_Bg0:FindDirect("Label_Title")
  self._uiObjs.Group_Ten = self._uiObjs.Img_Bg0:FindDirect("Group_Ten")
  self._uiObjs.Effect_Ten = self._uiObjs.Group_Ten:FindDirect("Effect_Ten")
  self._uiObjs.costItemIcon = self._uiObjs.Group_Ten:FindDirect("Btn_Ten/Img_Icon")
end
def.override("boolean").OnShow = function(self, show)
  self:_HandleEventListeners(show)
  if show then
    self:UpdateUI()
  end
end
def.method().UpdateUI = function(self)
  warn("[FudaiAwardPanel:UpdateUI] RemovePendingTimer.")
  self:RemovePendingTimer()
  self:_UpdateTitle()
  self:UpdateCostItem()
  self:_ShowAwards()
end
def.method()._UpdateTitle = function(self)
  local fudaiCfg = FuDaiData.Instance():GetFuDaiCfgByType(self._fudaiType)
  if fudaiCfg then
    GUIUtils.SetActive(self._uiObjs.Sprite_Title, true)
    GUIUtils.SetSprite(self._uiObjs.Sprite_Title, fudaiCfg.awardSpriteName)
  else
    warn("[ERROR][FudaiAwardPanel:_UpdateTitle] fudaiCfg nil for fudaiType:", self._fudaiType)
    GUIUtils.SetActive(self._uiObjs.Sprite_Title, false)
  end
end
def.method().UpdateCostItem = function(self)
  local itemId, need = FuDaiUtils.GetCostItemInfo(self._fudaiType, JiuZhouFuDaiMgr.DrawType.TEN)
  local itemBase = ItemUtils.GetItemBase(itemId)
  if not itemBase then
    warn("[FudaiAwardPanel:UpdateCostItem] failed found item id ", itemId)
    return
  end
  GUIUtils.SetTexture(self._uiObjs.costItemIcon, itemBase.icon)
end
def.method()._ShowAwards = function(self)
  if self._awardItems == nil then
    return
  end
  local Group_Items = self._uiObjs.Group_Ten:FindDirect("Group_Items")
  local itemInfo
  for i = 1, DRAW_COUNT_TEN do
    if self._awardItems then
      itemInfo = self._awardItems[i]
    end
    local itemObj = Group_Items:FindDirect("Img_BgIcon" .. i)
    self:SetItemInfo(itemObj, itemInfo, {})
  end
  GUIUtils.SetActive(self._uiObjs.Effect_Ten, false)
  GUIUtils.SetActive(self._uiObjs.Effect_Ten, true)
end
def.method("userdata", "table", "table").SetItemInfo = function(self, itemObj, itemInfo, params)
  if itemInfo == nil or itemInfo.itemid == 0 then
    GUIUtils.SetActive(itemObj, false)
    return
  end
  local itemBase = ItemUtils.GetItemBase(itemInfo.itemid)
  if itemBase then
    GUIUtils.SetActive(itemObj, true)
    local Texture_Icon = itemObj:FindDirect("Texture_Icon")
    GUIUtils.SetTexture(Texture_Icon, itemBase.icon)
    local Label_Num = itemObj:FindDirect("Label_Num")
    GUIUtils.SetText(Label_Num, itemInfo.item_num)
    local itemName = itemBase.name
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    local color = HtmlHelper.NameColor[itemBase.namecolor]
    if color then
      itemName = string.format("[%s]%s[-]", color, itemName)
    end
    local Label_Name = itemObj:FindDirect("Label_Name")
    GUIUtils.SetText(Label_Name, itemName)
  else
    warn("[ERROR][FudaiAwardPanel:SetItemInfo] itemBase nil for itemid:", itemInfo.itemid)
    GUIUtils.SetActive(itemObj, false)
  end
end
def.override().OnDestroy = function(self)
  ItemModule.Instance():BlockItemGetEffect(false)
  require("Main.Item.ui.EasyUseDlg").Block(false)
  self._uiObjs = nil
  self._awardItems = nil
  self._fudaiType = 0
  self._useYuanbaoType = 0
  self:RemovePendingTimer()
end
def.method().AddPendingTimer = function(self)
  self:RemovePendingTimer()
  self._bPending = true
  self._pendingTimer = GameUtil.AddGlobalTimer(PENDING_WAIT_SECONDS, true, function()
    self._bPending = false
  end)
end
def.method().RemovePendingTimer = function(self)
  if self._pendingTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self._pendingTimer)
    self._pendingTimer = 0
  end
  self._bPending = false
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Conform" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Ten" then
    self:OnBtn_Ten()
  elseif string.find(id, "Texture_Icon") then
    self:OnItemBgObjClicked(obj)
  end
end
def.method().OnBtn_Ten = function(self)
  if self._bPending == true then
    warn("[FudaiAwardPanel:OnBtn_Ten] PENDING.")
    return
  end
  local itemId, needCount = FuDaiUtils.GetCostItemInfo(self._fudaiType, JiuZhouFuDaiMgr.DrawType.TEN)
  local haveCount = ItemModule.Instance():GetItemCountById(itemId)
  local CurrencyFactory = require("Main.Currency.CurrencyFactory")
  local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
  local needNum = Int64.new(self:_GetNeedYuanbao())
  local moneyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
  local haveNum = moneyData:GetHaveNum()
  if needCount > haveCount and self._useYuanbaoType == 0 then
    local function OnConfirm(ret)
      if ret == 1 then
        if needNum > haveNum then
          moneyData:AcquireWithQuery()
          return
        end
        self._useYuanbaoType = 1
        self:OpenLuckyBag(haveNum, needNum)
      end
    end
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.JiuZhouFuDai[7], Int64.ToNumber(needNum)), OnConfirm, {})
  else
    self:OpenLuckyBag(haveNum, needNum)
  end
end
def.method("=>", "number")._GetNeedYuanbao = function(self)
  local needYuanBao = 0
  local itemId, needCount = FuDaiUtils.GetCostItemInfo(self._fudaiType, JiuZhouFuDaiMgr.DrawType.TEN)
  local haveCount = ItemModule.Instance():GetItemCountById(itemId)
  needCount = needCount - haveCount
  if needCount < 0 then
    needCount = 0
  end
  local price = MallUtility.GetPriceByItemId(itemId)
  needYuanBao = needCount * price
  return needYuanBao
end
def.method("userdata", "userdata").OpenLuckyBag = function(self, haveNum, needNum)
  warn("[FudaiAwardPanel:OpenLuckyBag] AddPendingTimer, self._useYuanbaoType:", self._useYuanbaoType)
  self:AddPendingTimer()
  local FuDaiProtocols = require("Main.activity.JiuZhouFuDai.FuDaiProtocols")
  local mapItemInstId = require("Main.activity.JiuZhouFuDai.ui.JiuZhouFudaiPanel").Instance():GetMapItemInstId()
  FuDaiProtocols.SendCOpenMultipleLuckyBag(mapItemInstId, self._useYuanbaoType, haveNum, needNum)
end
def.method("userdata").OnItemBgObjClicked = function(self, obj)
  local id = obj.parent.name
  local parent = obj.parent.parent
  local index = tonumber(string.sub(id, #"Img_BgIcon" + 1, -1))
  local itemInfo = self._awardItems[index]
  if itemInfo then
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemInfo.itemid, obj, 0, false)
  end
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
  end
end
def.static("table").OnSOpenLuckyBagFailed = function(p)
  ItemModule.Instance():BlockItemGetEffect(false)
  require("Main.Item.ui.EasyUseDlg").Block(false)
  local self = FudaiAwardPanel.Instance()
  if not self:IsShow() then
    return
  end
  warn("[FudaiAwardPanel:OnSOpenLuckyBagFailed] RemovePendingTimer.")
  if retcode == -3 or retcode == -4 then
    self:DestroyPanel()
  end
end
return FudaiAwardPanel.Commit()
