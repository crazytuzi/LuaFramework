local EC = require("Types.Vector3")
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WorldBossMgr = require("Main.WorldBoss.WorldBossMgr")
local WorldBossUtility = require("Main.WorldBoss.WorldBossUtility")
local GUIUtils = require("GUI.GUIUtils")
local WorldBossTipsPanel = Lplus.Extend(ECPanelBase, "WorldBossTipsPanel")
local def = WorldBossTipsPanel.define
def.field("table").uiNodes = nil
def.field("string").tipContent = ""
def.field("table").awardList = nil
local instance
def.static("=>", WorldBossTipsPanel).Instance = function()
  if instance == nil then
    instance = WorldBossTipsPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:UpdateUI()
  else
    self:CreatePanel(RESPATH.PREFAB_WORLDBOSS_TIPS_PANEL, 2)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitData()
end
def.override("boolean").OnShow = function(self, isShow)
  if isShow == false then
    return
  end
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self:ClearUp()
end
def.method().ClearUp = function(self)
  self.awardList = nil
  self.tipContent = ""
end
def.method().InitUI = function(self)
  self.uiNodes = {}
  self.uiNodes.scrlView = self.m_panel:FindDirect("Img _Bg0/Scroll View")
  self.uiNodes.lblTips = self.uiNodes.scrlView:FindDirect("Group_Content/Label_Tips")
  self.uiNodes.imgTitle = self.uiNodes.scrlView:FindDirect("Group_Content/Img_BgTitle")
  self.uiNodes.listReward = self.uiNodes.scrlView:FindDirect("Group_Content/List_Rank")
end
def.method().UpdateUI = function(self)
  self:UpdateTips()
  self:UpdateAwardList()
end
def.method().UpdateTips = function(self)
  local uiLabelTips = self.uiNodes.lblTips:GetComponent("UILabel")
  if self.tipContent ~= "" then
    uiLabelTips.text = self.tipContent
  end
end
def.method().UpdateAwardList = function(self)
  if not self.awardList then
    return
  end
  local uiScrollView = self.uiNodes.scrlView:GetComponent("UIScrollView")
  uiScrollView:ResetPosition()
  local uiList = self.uiNodes.listReward:GetComponent("UIList")
  local itemCount = #self.awardList
  uiList.itemCount = itemCount
  uiList:Resize()
  uiList:Reposition()
  for i = 1, itemCount do
    self:SetAwardListItem(i)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("number").SetAwardListItem = function(self, idx)
  local item = self.uiNodes.listReward:FindDirect("item_" .. idx)
  local uiLabelRank = item:FindDirect("Label_1"):GetComponent("UILabel")
  uiLabelRank.text = self.awardList[idx].rankRange
  local uiLabelReward = item:FindDirect("Label_2"):GetComponent("UILabel")
  uiLabelReward.text = self.awardList[idx].desc
  item:FindDirect("Img_MingCi"):SetActive(false)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  end
end
def.method().InitData = function(self)
  self.tipContent = WorldBossMgr.Instance():GetWorldBossTip()
  self.awardList = WorldBossMgr.Instance():GetAwardList()
end
return WorldBossTipsPanel.Commit()
