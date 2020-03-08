local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local AuctionEntrancePanel = Lplus.Extend(ECPanelBase, "AuctionEntrancePanel")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemUtils = require("Main.Item.ItemUtils")
local def = AuctionEntrancePanel.define
local instance
def.static("=>", AuctionEntrancePanel).Instance = function()
  if instance == nil then
    instance = AuctionEntrancePanel()
  end
  return instance
end
def.field("number")._activityId = 0
def.field("number")._timerID = 0
def.field("table")._uiObjs = nil
local SHOW_INTERVAL = 30
def.method("number").ShowDlg = function(self, activityId)
  self._activityId = activityId
  if self:IsShow() then
    self:UpdateUI()
  else
    self:CreatePanel(RESPATH.PREFAB_UI_LIMIT_ACTIVITY_TIP, _G.GUILEVEL.NORMAL)
  end
end
def.override().OnCreate = function(self)
  self:_InitUI()
  self:SetModal(true)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Label_Title = self.m_panel:FindDirect("Img_0/Label_Title")
  self._uiObjs.Label_Content = self.m_panel:FindDirect("Img_0/Img_BgWords/Label")
  self._uiObjs.Group_Items = self.m_panel:FindDirect("Img_0/Group_Items")
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:UpdateUI()
  end
end
def.method().UpdateUI = function(self)
  self:_ClearTimer()
  self:ShowEntranceInfo()
  self._timerID = GameUtil.AddGlobalTimer(SHOW_INTERVAL, true, function()
    self:HideDlg()
  end)
end
def.method().ShowEntranceInfo = function(self)
  local activityCfg = ActivityInterface.GetActivityCfgById(self._activityId)
  if activityCfg then
    GUIUtils.SetText(self._uiObjs.Label_Title, activityCfg.activityName)
    self:ShowAwards()
  else
    warn("[ERROR][AuctionEntrancePanel:ShowEntranceInfo] activityCfg NIL for activityId:", self._activityId)
    self:HideDlg()
  end
end
def.method()._ClearTimer = function(self)
  if self._timerID > 0 then
    GameUtil.RemoveGlobalTimer(self._timerID)
    self._timerID = 0
  end
end
def.override().OnDestroy = function(self)
  self:_ClearTimer()
  self._uiObjs = nil
end
def.method().HideDlg = function(self)
  if self:IsShow() then
    self._activityId = 0
    self:_ClearTimer()
    self:DestroyPanel()
  end
end
def.method().ShowAwards = function(self)
  local timeLimitTipCfg = ActivityInterface.GetTimeLimitTipCfg(constant.CAuctionConsts.BID_BEGIN_PANEL_CFG_ID)
  if timeLimitTipCfg then
    GUIUtils.SetText(self._uiObjs.Label_Content, timeLimitTipCfg.description)
    local awardItems = timeLimitTipCfg.awardItemIds
    if #awardItems > 0 then
      GUIUtils.SetActive(self._uiObjs.Group_Items, true)
      for i = 1, 3 do
        local id = awardItems[i]
        local item_bg = self._uiObjs.Group_Items:FindDirect(string.format("Item_%03d", i))
        if id and id > 0 then
          item_bg:SetActive(true)
          local itemBaseCfg = ItemUtils.GetItemBase(id)
          local img_icon = item_bg:FindDirect("Img_Icon")
          local icon_texture = img_icon:GetComponent("UITexture")
          GUIUtils.FillIcon(icon_texture, itemBaseCfg.icon)
        else
          item_bg:SetActive(false)
        end
      end
    else
      GUIUtils.SetActive(self._uiObjs.Group_Items, false)
    end
  else
    warn("[ERROR][AuctionEntrancePanel:ShowAwards] timeLimitTipCfg NIL for constant.CAuctionConsts.BID_BEGIN_PANEL_CFG_ID:", constant.CAuctionConsts.BID_BEGIN_PANEL_CFG_ID)
    self:HideDlg()
  end
end
def.method("string").onClick = function(self, id)
  local strs = string.split(id, "_")
  if strs[1] == "Btn" and strs[2] == "Cancel" then
    self:HideDlg()
  elseif strs[1] == "Btn" and strs[2] == "Confirm" then
    require("Main.Auction.AuctionInterface").OpenAuctionPanel()
    self:HideDlg()
  elseif strs[1] == "Item" then
    local idx = tonumber(strs[2])
    local timeLimitTipCfg = ActivityInterface.GetTimeLimitTipCfg(constant.CAuctionConsts.BID_BEGIN_PANEL_CFG_ID)
    local awardItems = timeLimitTipCfg.awardItemIds
    if awardItems[idx] and awardItems[idx] ~= 0 then
      local img_bg = self.m_panel:FindDirect("Img_0/Group_Items/Item_" .. strs[2] .. "/Img_Bg")
      local sprite = img_bg:GetComponent("UISprite")
      local position = img_bg:get_position()
      local screenPos = WorldPosToScreen(position.x, position.y)
      ItemTipsMgr.Instance():ShowBasicTips(awardItems[idx], screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
    end
  end
end
AuctionEntrancePanel.Commit()
return AuctionEntrancePanel
