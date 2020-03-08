local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local PitchPanelNode = Lplus.Extend(TabNode, "PitchPanelNode")
local BuyNode = require("Main.CommerceAndPitch.ui.PitchBuyNode")
local SellNode = require("Main.CommerceAndPitch.ui.PitchSellNode")
local CommercePitchPanel = Lplus.ForwardDeclare("CommercePitchPanel")
local def = PitchPanelNode.define
def.const("table").NodeId = {BUY = 1, SELL = 2}
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").state = 0
def.field("boolean").bOpenDefault = true
def.const("table").StateConst = {Buy = 1, Sell = 2}
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.nodes = {}
  self.state = PitchPanelNode.StateConst.Buy
  local buyNode = self.m_node:FindDirect("Group_Buy")
  self.nodes[PitchPanelNode.NodeId.BUY] = BuyNode()
  self.nodes[PitchPanelNode.NodeId.BUY]:Init(base, buyNode)
  local sellNode = self.m_node:FindDirect("Group_Sell")
  self.nodes[PitchPanelNode.NodeId.SELL] = SellNode()
  self.nodes[PitchPanelNode.NodeId.SELL]:Init(base, sellNode)
end
def.method().InitUI = function(self)
  self:CheckToSwitchState()
  if PitchPanelNode.StateConst.Buy == self.state then
    self:SwitchTo(PitchPanelNode.NodeId.BUY)
    local toggle = self.m_node:FindDirect("Tab_Buy"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif PitchPanelNode.StateConst.Sell == self.state then
    self:SwitchTo(PitchPanelNode.NodeId.SELL)
    local toggle = self.m_node:FindDirect("Tab_Sell"):GetComponent("UIToggle")
    toggle:set_value(true)
  end
  local Img_Red = self.m_node:FindDirect("Tab_Sell"):FindDirect("Img_Red")
  local num = require("Main.CommerceAndPitch.data.PitchData").Instance():GetChangedSelledItemNum()
  if num > 0 then
    Img_Red:SetActive(true)
  else
    Img_Red:SetActive(false)
  end
end
def.method().CheckToSwitchState = function(self)
  if self.bOpenDefault then
    return
  end
  local num = require("Main.CommerceAndPitch.data.PitchData").Instance():GetChangedSelledItemNum()
  if num > 0 then
    self.state = PitchPanelNode.StateConst.Sell
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  self.curNode = 0
  for k, v in pairs(self.nodes) do
    if nodeId == k then
      self.curNode = nodeId
      v:Show()
    else
      v:Hide()
    end
  end
end
def.override().OnShow = function(self)
  self:InitUI()
end
def.override().OnHide = function(self)
  self.bOpenDefault = true
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Tab_Buy" == id then
    self:SwitchTo(PitchPanelNode.NodeId.BUY)
  elseif "Tab_Sell" == id then
    self:SwitchTo(PitchPanelNode.NodeId.SELL)
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
def.method().UpdateRefeshLabel = function(self)
  if PitchPanelNode.NodeId.BUY == self.curNode then
    self.nodes[self.curNode]:UpdateRefeshLabel()
  else
    PitchPanelNode.RequireRefeshPitch()
  end
end
def.method().UpdateTimeLabel = function(self)
  if PitchPanelNode.NodeId.BUY == self.curNode then
    self.nodes[self.curNode]:UpdateTimeLabel()
  end
end
def.static().RequireRefeshPitch = function()
  BuyNode.RequireRefeshPitch()
end
def.method("table").OnBuyItemRes = function(self, p)
  if PitchPanelNode.NodeId.BUY == self.curNode then
    self.nodes[self.curNode]:OnBuyItemRes(p)
  end
end
def.method().UpdatePitchSellList = function(self)
  if PitchPanelNode.NodeId.SELL == self.curNode then
    self.nodes[self.curNode]:UpdatePitchSellList()
  end
end
def.method("number", "table").ShowPitchItemTips = function(self, shoppingId, itemInfo)
  if PitchPanelNode.NodeId.BUY == self.curNode then
    self.nodes[self.curNode]:ShowPitchItemTips(shoppingId, itemInfo)
  end
end
def.method("number").OnCommonResultRes = function(self, res)
  local text = textRes.Pitch.SCommonResultRes[res]
  if text then
    Toast(text)
  end
end
def.method().UpdateSilverMoney = function(self)
  self.nodes[self.curNode]:UpdateSilverMoney()
end
def.method().UpdatePitchShoppingList = function(self)
  if PitchPanelNode.NodeId.BUY == self.curNode then
    self.nodes[self.curNode]:UpdateShoppingList()
  end
end
def.method("number", "number").SellToPitch = function(self, itemKey, itemId)
  GameUtil.AddGlobalTimer(0.1, true, function()
    self.state = PitchPanelNode.StateConst.Sell
    self:SwitchTo(PitchPanelNode.NodeId.SELL)
    local toggle = self.m_node:FindDirect("Tab_Sell"):GetComponent("UIToggle")
    toggle:set_value(true)
    if self.curNode == PitchPanelNode.NodeId.SELL then
      self.nodes[PitchPanelNode.NodeId.SELL]:SellToPitch(itemKey, itemId)
    end
  end)
end
def.method().UpdateRequirementsCondTbl = function(self)
  self.nodes[self.curNode]:UpdateRequirementsCondTbl()
end
def.override("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  self.nodes[self.curNode]:onSpringFinish(id, scrollView, type, position)
end
def.override("string").onDragStart = function(self, id)
  self.nodes[self.curNode]:onDragStart(id)
end
def.override("string").onDragEnd = function(self, id)
  self.nodes[self.curNode]:onDragEnd(id)
end
def.override("string", "string", "number").onSelect = function(self, id, selected, index)
  self.nodes[self.curNode]:onSelect(id, selected, index)
end
PitchPanelNode.Commit()
return PitchPanelNode
