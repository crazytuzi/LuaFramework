local Lplus = require("Lplus")
local BaodianEquipPanel = require("Main.Grow.ui.BaodianEquipPanel")
local BaodianSkillPanel = require("Main.Grow.ui.BaodianSkillPanel")
local BaodianPengRenPanel = require("Main.Grow.ui.BaodianPengRenPanel")
local BaodianLianYaoPanel = require("Main.Grow.ui.BaodianLianYaoPanel")
local BaodianFaBaoPanel = require("Main.Grow.ui.BaodianFaBaoPanel")
local BaodianPetPanel = require("Main.Grow.ui.BaodianPetPanel")
local BaodianWingsPanel = require("Main.Grow.ui.BaodianWingsPanel")
local BaodianXianLvPanel = require("Main.Grow.ui.BaodianXianLvPanel")
local BaodianJDPanel = require("Main.Grow.ui.BaodianJDPanel")
local BaodianChildrenPanel = require("Main.Grow.ui.BaodianChildrenPanel")
local BaodianUtils = require("Main.Grow.BaodianUtils")
local BaodianMgr = Lplus.Class("BaodianMgr")
local def = BaodianMgr.define
local Panels = {
  [1] = BaodianEquipPanel,
  [2] = BaodianSkillPanel,
  [3] = BaodianPengRenPanel,
  [4] = BaodianLianYaoPanel,
  [5] = BaodianPetPanel,
  [6] = BaodianXianLvPanel,
  [7] = BaodianFaBaoPanel,
  [8] = BaodianWingsPanel,
  [9] = BaodianJDPanel,
  [10] = BaodianChildrenPanel
}
def.field("number").mCurPanelNode = 0
def.field("userdata").mParentPanel = nil
local instance
def.static("=>", BaodianMgr).Instance = function()
  if instance == nil then
    instance = BaodianMgr()
  end
  return instance
end
def.method("userdata").SetNodeParentPanel = function(self, Parent)
  self.mParentPanel = Parent
end
def.method("=>", "boolean").CanOpenBaodian = function()
  local openLevel = BaodianUtils.GetBaodianOpenLevel()
  if openLevel < 0 then
    return false
  end
  local hp = require("Main.Hero.HeroModule").Instance()
  local heroLevel = hp:GetHeroProp().level
  if openLevel > heroLevel then
    return false
  end
  return true
end
def.method("number", "number").Switch2NodePanel = function(self, panelNode, subNode)
  if Panels[panelNode] == nil then
    return
  end
  if panelNode == self.mCurPanelNode and Panels[self.mCurPanelNode].Instance():IsShow() then
    return
  end
  if Panels[self.mCurPanelNode] then
    Panels[self.mCurPanelNode].Instance():DestroyPanel()
  end
  if subNode > 0 then
    if Panels[panelNode].Instance():NeedSubNode() then
      Panels[panelNode].Instance():ShowPanelWithTargetNode(self.mParentPanel, subNode)
    else
      Panels[panelNode].Instance():ShowPanel(self.mParentPanel)
    end
  else
    Panels[panelNode].Instance():ShowPanel(self.mParentPanel)
  end
  self:SetCurPanelNode(panelNode)
end
def.method("number").SetCurPanelNode = function(self, panelNode)
  self.mCurPanelNode = panelNode
end
def.method("=>", "number").GetCurPanelNode = function(self)
  return self.mCurPanelNode
end
def.method().DestroyCurPanel = function(self)
  if Panels[self.mCurPanelNode] then
    Panels[self.mCurPanelNode].Instance():DestroyPanel()
  end
end
BaodianMgr.Commit()
return BaodianMgr
