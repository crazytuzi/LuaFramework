local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local WishingWellProtocols = require("Main.activity.WishingWell.WishingWellProtocols")
local WishingWellMgr = require("Main.activity.WishingWell.WishingWellMgr")
local WishingWellData = require("Main.activity.WishingWell.data.WishingWellData")
local EasyBasicItemTip = require("Main.Common.EasyBasicItemTip")
local DlgWishingWell = Lplus.Extend(ECPanelBase, "DlgWishingWell")
local def = DlgWishingWell.define
local instance
def.static("=>", DlgWishingWell).Instance = function()
  if instance == nil then
    instance = DlgWishingWell()
  end
  return instance
end
def.field("number")._type = 0
def.field("table")._wishData = nil
def.field(EasyBasicItemTip)._itemTipHelper = nil
def.field("table")._uiObjs = nil
def.field("number")._timerID = 0
def.field("boolean")._bWishing = false
def.field("userdata")._wishEffect = nil
def.field("userdata")._poolEffect = nil
def.static("number").ShowDlg = function(type)
  if not WishingWellMgr.Instance():IsFeatureOpen() then
    if DlgWishingWell.Instance():IsShow() then
      DlgWishingWell.Instance():DestroyPanel()
    end
    return
  end
  if not WishingWellMgr.Instance():IsActivityOpen(type, true) then
    if DlgWishingWell.Instance():IsShow() then
      DlgWishingWell.Instance():DestroyPanel()
    end
    return
  end
  if DlgWishingWell.Instance():IsShow() then
    return
  end
  DlgWishingWell.Instance()._type = type
  DlgWishingWell.Instance()._wishData = WishingWellData.Instance()
  DlgWishingWell.Instance():CreatePanel(RESPATH.PERFAB_DLG_WISHINGWELL, 1)
end
def.override().OnCreate = function(self)
  self:SetModal(true)
  self:_InitUI()
end
def.method()._InitUI = function(self)
  self._itemTipHelper = EasyBasicItemTip()
  self._uiObjs = {}
  self._uiObjs.Item = self.m_panel:FindDirect("Img_Bg0/Group_Item/Img_BgItem/Item")
  self._uiObjs.ItemNumLabel = self._uiObjs.Item:FindDirect("Label_Number")
  self._uiObjs.ItemIcon = self._uiObjs.Item:FindDirect("Img_Icon")
  self._uiObjs.ItemNameLabel = self._uiObjs.Item:FindDirect("Label_Name")
  self._uiObjs.ItemList = self.m_panel:FindDirect("Img_Bg0/Group_Item/Img_BgItem/List")
  self._uiObjs.FreeCountLabel = self.m_panel:FindDirect("Img_Bg0/Group_Item/Img_BgItem/Label_Tips1")
  self._uiObjs.WishCountLabel = self.m_panel:FindDirect("Img_Bg0/Group_Item/Label_Tips2")
  self._uiObjs.wishEffectAnchor = self.m_panel:FindDirect("Img_Bg0/Group_Model/Texture/FX2")
  self._uiObjs.poolEffectAnchor = self.m_panel:FindDirect("Img_Bg0/Group_Model/Texture/FX1")
end
def.override("boolean").OnShow = function(self, show)
  self:_HandleEventListeners(show)
  if show then
    self:_ShowPoolEffect()
    self:_UpdateCount()
    self:_ShowCostItem()
  end
end
def.method()._ShowPoolEffect = function(self)
  local effectRes = self._wishData:GetPoolEffectRes(self._type)
  self._poolEffect = self:_PlayEffect(effectRes, self._uiObjs.poolEffectAnchor)
end
def.method("string", "userdata", "=>", "userdata")._PlayEffect = function(self, effectRes, parent)
  if effectRes and effectRes ~= "" then
    return require("Fx.GUIFxMan").Instance():PlayAsChild(parent, effectRes, 0, 0, -1, false)
  else
    return nil
  end
end
def.method()._UpdateCount = function(self)
  local leftFreeCount = self._wishData:GetLeftFreeWishCount(self._type)
  GUIUtils.SetText(self._uiObjs.FreeCountLabel, string.format(textRes.WishingWell.FREE_COUNT, leftFreeCount))
  local wishCount = self._wishData:GetWishCount(self._type)
  local maxCount = self._wishData:GetMaxWishCount(self._type)
  GUIUtils.SetText(self._uiObjs.WishCountLabel, string.format(textRes.WishingWell.WISH_COUNT, wishCount, maxCount))
end
def.method()._ShowCostItem = function(self)
  local itemId = self._wishData:GetCostItemId(self._type)
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase then
    local itemName = itemBase.name
    local color = HtmlHelper.NameColor[itemBase.namecolor]
    if color then
      itemName = string.format("[%s]%s[-]", color, itemName)
    end
    GUIUtils.SetText(self._uiObjs.ItemNameLabel, itemName)
    GUIUtils.SetTexture(self._uiObjs.ItemIcon, itemBase.icon)
    local needItemNum = self._wishData:GetCostItemNum(self._type)
    local bagItemNum = self._wishData:GetWishItemCount(self._type)
    GUIUtils.SetText(self._uiObjs.ItemNumLabel, bagItemNum .. "/" .. needItemNum)
    self._itemTipHelper:RegisterItem2ShowTip(itemId, self._uiObjs.Item)
  else
    warn("[DlgWishingWell:_ShowCostItem] cost itemBase nil for type:", self._type)
  end
end
def.method()._PlayWishEffect = function(self)
  self:_ResetTimer()
  self:_DestroyWishEffect()
  self._bWishing = true
  local effectRes = self._wishData:GetWishEffectRes(self._type)
  self._wishEffect = self:_PlayEffect(effectRes, self._uiObjs.wishEffectAnchor)
  local effectDuration = self._wishData:GetWishEffectDuration(self._type)
  self._timerID = GameUtil.AddGlobalTimer(effectDuration, true, function()
    self:OnPlayEffectFinish()
  end)
end
def.method().OnPlayEffectFinish = function(self)
  self._bWishing = false
  self:_DestroyWishEffect()
  self:_ResetTimer()
  WishingWellProtocols.SendCBless(self._type)
end
def.override().OnDestroy = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._type = 0
  self._wishData = nil
  self._uiObjs = nil
  self._itemTipHelper = nil
  self._bWishing = false
  self:_ResetTimer()
  self:_DestroyWishEffect()
  self:_DestroyPoolEffect()
end
def.method()._ResetTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.method()._DestroyWishEffect = function(self)
  if self._wishEffect then
    self._wishEffect:Destroy()
    self._wishEffect = nil
  end
end
def.method()._DestroyPoolEffect = function(self)
  if self._poolEffect then
    self._poolEffect:Destroy()
    self._poolEffect = nil
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Bless" then
    self:OnBtn_Bless(obj)
  elseif id == "Btn_Close" or id == "Modal" then
    self:OnBtn_Close()
  elseif id == "Btn_Help" then
    self:OnBtn_Help()
  else
    if id == "Item" then
      self._itemTipHelper:CheckItem2ShowTip(id, -1, true)
    else
    end
  end
end
def.method().OnBtn_Close = function(self)
  if self._bWishing then
    Toast(textRes.WishingWell.CLOSE_FAILED_ON_WISHING)
  else
    self:DestroyPanel()
  end
end
def.method().OnBtn_Help = function(self)
  local tipId = self._wishData:GetTipId(self._type)
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.method("userdata").OnBtn_Bless = function(self, obj)
  if self._bWishing == true then
    Toast(textRes.WishingWell.ALREADY_WISHING)
    return
  elseif self._wishData:GetWishCount(self._type) >= self._wishData:GetMaxWishCount(self._type) then
    Toast(textRes.WishingWell.RICH_WISHING_LIMIT)
  elseif self._wishData:GetWishCount(self._type) >= self._wishData:GetFreeWishCount(self._type) and self._wishData:GetWishItemCount(self._type) < self._wishData:GetCostItemNum(self._type) then
    Toast(textRes.WishingWell.WISHING_ITEM_NOT_ENOUGH)
  else
    self:_PlayWishEffect()
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
    eventFunc(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Wishing_Well_Change, DlgWishingWell.OnWishCountChange)
    eventFunc(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, DlgWishingWell.OnItemChange)
  end
end
def.static("table", "table").OnWishCountChange = function(param, context)
  warn("[DlgWishingWell:OnWishCountChange] update wish count!")
  DlgWishingWell.Instance():_UpdateCount()
end
def.static("table", "table").OnItemChange = function(param, context)
  warn("[DlgWishingWell:OnItemChange] update cost item!")
  DlgWishingWell.Instance():_ShowCostItem()
end
DlgWishingWell.Commit()
return DlgWishingWell
