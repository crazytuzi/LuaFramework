local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GrowGuideNodeBase = require("Main.Grow.ui.GrowGuideNodeBase")
local BaodianMgr = require("Main.Grow.BaodianMgr")
local BaodianUtils = require("Main.Grow.BaodianUtils")
local GUIUtils = require("GUI.GUIUtils")
local BaodianNode = Lplus.Extend(GrowGuideNodeBase, "BaodianNode")
local def = BaodianNode.define
local PanelNode = {
  Equip_Node = 1,
  Skill_Node = 2,
  PengRen_Node = 3,
  LianYao_Node = 4,
  Pet_Node = 5,
  XianLv_Node = 6,
  FaBao_Node = 7,
  Wings_Node = 8,
  JiaDian_Node = 9,
  Children_Node = 10,
  Other_Node = 11
}
def.const("table").BaodianNodes = PanelNode
def.field("table").mUiObjs = nil
def.field(BaodianMgr).mBaodianMgr = nil
def.field("number").mCurNode = 0
local instance
def.static("=>", BaodianNode).Instance = function()
  if instance == nil then
    instance = BaodianNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, panelbase, node)
  GrowGuideNodeBase.Init(self, panelbase, node)
  self.mBaodianMgr = BaodianMgr.Instance()
  self.mBaodianMgr:SetNodeParentPanel(self.m_panel)
end
def.override().OnShow = function(self)
  warn("OnShow~~~~~~~~~~~~")
  self:InitUI()
  self:UpdateUI()
  if self.mCurNode == 0 then
    if self.onShowParams and self.onShowParams.targetBaodianNode then
      self.mCurNode = self.onShowParams.targetBaodianNode
    else
      self.mCurNode = PanelNode.Equip_Node
    end
  end
  self:OpenBaodianNodePanel(self.mCurNode)
  self:SetSpriteStatus(self.mCurNode, true)
end
def.override().OnHide = function(self)
  self.mCurNode = 0
  self:ResetUI()
  self:DestroyCurPanel()
end
def.override("=>", "boolean").IsUnlock = function(self)
  return self.mBaodianMgr:CanOpenBaodian()
end
def.override("string", "boolean").onToggle = function(self, id, isActive)
end
def.method().InitUI = function(self)
  self.mUiObjs = {}
  self.mUiObjs.BgView = self.m_node:FindDirect("Img_BgTab")
  self.mUiObjs.ScrollView = self.m_node:FindDirect("Img_BgTab/Scroll View_Tab")
  self.mUiObjs.ListView = self.mUiObjs.ScrollView:FindDirect("List_Tab")
end
def.method().ResetUI = function(self)
  self.mUiObjs.BgView = nil
  self.mUiObjs.ListView = nil
  self.mUiObjs.ScrollView = nil
  self.mUiObjs = nil
end
def.override("userdata").onClickObj = function(self, clickObj)
  if clickObj and clickObj.name then
    local newPanelNode = self:GetNewPanelNode(clickObj.name)
    if newPanelNode > 0 then
      self:SetSpriteStatus(self.mCurNode, false)
      self.mCurNode = newPanelNode
      self:SetSpriteStatus(self.mCurNode, true)
      self:onClick(clickObj.name)
    end
  end
end
def.override("string").onClick = function(self, id)
  if string.find(id, "BDItem") and self.mCurNode > 0 then
    if self:CheckPanelNode(self.mCurNode) == false then
      return
    end
    self:OpenBaodianNodePanel(self.mCurNode)
  end
end
def.method("string", "=>", "number").GetNewPanelNode = function(self, name)
  if string.find(name, "BDItem") then
    local strs = string.split(name, "_")
    return tonumber(strs[2])
  end
  return 0
end
def.method("number", "boolean").SetSpriteStatus = function(self, nodeId, enable)
  local nodeName = string.format("BDItem_%d", nodeId)
  local nodeObj = self.mUiObjs.ListView:FindDirect(nodeName)
  nodeObj:GetComponent("UIToggle"):set_value(enable)
end
def.method().UpdateUI = function(self)
  self:UpdateListUI()
end
def.method().UpdateListUI = function(self)
  if self.mUiObjs.ListView == nil then
    return
  end
  local baodianNames = BaodianUtils.GetBaodianTypeName()
  if baodianNames == nil then
    return
  end
  local baodianNum = #baodianNames
  local baodianList = GUIUtils.InitUIList(self.mUiObjs.ListView, baodianNum)
  local template = self.mUiObjs.ListView:FindDirect("Tab_BD")
  template:SetActive(false)
  for i = 1, baodianNum do
    local itemObj = baodianList[i]
    local labelName = "Label_Tab" .. string.format("_%d", i)
    itemObj.name = string.format("BDItem_%d", i)
    local uiLabel = itemObj:FindDirect(labelName):GetComponent("UILabel")
    uiLabel.text = baodianNames[i]
    self.m_base.m_msgHandler:Touch(itemObj)
  end
  GUIUtils.Reposition(self.mUiObjs.ListView, "UIList", 0)
end
def.method("number").OpenBaodianNodePanel = function(self, nodeId)
  if self.mBaodianMgr == nil then
    return
  end
  if self.onShowParams and self.onShowParams.subTargetBaodianNode then
    self.mBaodianMgr:Switch2NodePanel(nodeId, self.onShowParams.subTargetBaodianNode)
    self.onShowParams = nil
  else
    self.mBaodianMgr:Switch2NodePanel(nodeId, 0)
  end
end
def.method("number", "=>", "boolean").CheckPanelNode = function(self, nodeId)
  for k, v in pairs(PanelNode) do
    if nodeId == v then
      return true
    end
  end
  return false
end
def.method().DestroyCurPanel = function(self)
  if self.mBaodianMgr then
    self.mBaodianMgr:DestroyCurPanel()
  end
end
BaodianNode.Commit()
return BaodianNode
