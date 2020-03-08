local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RomanticDanceAwardPanel = Lplus.Extend(ECPanelBase, "RomanticDanceAwardPanel")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = RomanticDanceAwardPanel.define
local instance
def.field("table").awardItems = nil
def.field("number").timerId = 0
def.static("=>", RomanticDanceAwardPanel).Instance = function()
  if instance == nil then
    instance = RomanticDanceAwardPanel()
  end
  return instance
end
def.method("table").ShowPanel = function(self, awardItems)
  if self.m_panel ~= nil then
    return
  end
  self.awardItems = {}
  for k, v in pairs(awardItems or {}) do
    local item = {}
    item.itemId = k
    item.itemNum = v
    table.insert(self.awardItems, item)
  end
  self:CreatePanel(RESPATH.PREFAB_DANCE_AWARD_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:StarTimer()
end
def.override().OnDestroy = function(self)
  self.awardItems = nil
  self:StopTimer()
end
def.method().InitUI = function(self)
  local description = self.m_panel:FindDirect("Img_0/Img_BgWords/Label")
  local desc = require("Main.Common.TipsHelper").GetHoverTip(constant.CRomanticDanceConsts.big_award_tips)
  GUIUtils.SetText(description, desc)
  local List_Item = self.m_panel:FindDirect("Img_0/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  uiList.itemCount = #self.awardItems
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    local Img_Icon = uiItem:FindDirect("Img_Icon_" .. i)
    local Label_Name = uiItem:FindDirect("Label_Name_" .. i)
    local item = self.awardItems[i]
    local itemBase = ItemUtils.GetItemBase(item.itemId)
    GUIUtils.SetText(Label_Name, itemBase.name)
    GUIUtils.FillIcon(Img_Icon:GetComponent("UITexture"), itemBase.icon)
  end
end
def.method().StarTimer = function(self)
  local remainTime = constant.CRomanticDanceConsts.delay_award_seconds
  self:ShowLeftTime(remainTime)
  self.timerId = GameUtil.AddGlobalTimer(1, false, function()
    remainTime = remainTime - 1
    if remainTime < 0 then
      self:StopTimer()
      self:DestroyPanel()
    else
      self:ShowLeftTime(remainTime)
    end
  end)
end
def.method("number").ShowLeftTime = function(self, remainTime)
  local Label_Get = self.m_panel:FindDirect("Img_0/Btn_Get/Label_Get")
  GUIUtils.SetText(Label_Get, string.format(textRes.MemoryCompetition[12], remainTime))
end
def.method().StopTimer = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Get" then
    self:OnBtnGetClick()
  elseif string.find(id, "Img_Item_") then
    local idx = tonumber(string.sub(id, #"Img_Item_" + 1))
    if idx ~= nil then
      self:OnClickItem(idx)
    end
  end
end
def.method().OnBtnGetClick = function(self)
  require("Main.activity.MemoryCompetition.RomanticDance.RomanticDanceMgr").Instance():GetRomanticDanceEndBigAward()
  self:DestroyPanel()
end
def.method("number").OnClickItem = function(self, idx)
  local item = self.awardItems[idx]
  if item then
    local obj = self.m_panel:FindDirect("Img_0/List_Item/Img_Item_" .. idx)
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(item.itemId, obj, 0, false)
  end
end
RomanticDanceAwardPanel.Commit()
return RomanticDanceAwardPanel
