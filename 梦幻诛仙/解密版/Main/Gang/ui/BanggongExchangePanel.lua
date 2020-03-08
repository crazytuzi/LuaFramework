local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BanggongExchangePanel = Lplus.Extend(ECPanelBase, "BanggongExchangePanel")
local def = BanggongExchangePanel.define
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local MallPanel = require("Main.Mall.ui.MallPanel")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local GangData = require("Main.Gang.data.GangData")
local GUIUtils = require("GUI.GUIUtils")
local SilverExchangeBanggongNode = require("Main.Gang.ui.SilverExchangeBanggongNode")
local YuanBaoExchangeBanggongNode = require("Main.Gang.ui.YuanBaoExchangeBanggongNode")
local NodeId = {
  None = "",
  SilverExchange = "Tap_Money",
  YuanBaoExchange = "Tap_YuanBao"
}
local NodeDefines = {
  [NodeId.SilverExchange] = {node = SilverExchangeBanggongNode, order = 1},
  [NodeId.YuanBaoExchange] = {node = YuanBaoExchangeBanggongNode, order = 2}
}
local instance
def.static("=>", BanggongExchangePanel).Instance = function(self)
  if nil == instance then
    instance = BanggongExchangePanel()
  end
  return instance
end
def.static().ShowBanggongExchangePanel = function()
  BanggongExchangePanel.Instance():SetModal(true)
  BanggongExchangePanel.Instance():CreatePanel(RESPATH.PREFAB_EXCHANGE_BANGGONG_PANEL, 0)
end
def.field("table").m_nodes = nil
def.field("string").m_curNodeId = NodeId.None
def.field("string").m_nextNodeId = NodeId.SilverExchange
def.override().OnCreate = function(self)
  self:InitNodes()
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ExchangeBanggongChanged, BanggongExchangePanel.OnExchangeBanggongChanged)
end
def.override().OnDestroy = function(self)
  self:HideCurNode()
  self.m_nodes = nil
  self.m_curNodeId = NodeId.None
  self.m_nextNodeId = NodeId.SilverExchange
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ExchangeBanggongChanged, BanggongExchangePanel.OnExchangeBanggongChanged)
end
def.override("boolean").OnShow = function(self, isShow)
  if not isShow then
    self:HideCurNode()
    return
  end
  self:SwitchToNode(self.m_nextNodeId)
end
def.method().HideCurNode = function(self)
  if self.m_curNodeId ~= NodeId.None then
    self:GetNode(self.m_curNodeId):Hide()
    self.m_curNodeId = NodeId.None
  end
end
def.method().InitNodes = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_nodes = {}
  local nodeOrderList = {}
  for nodeId, v in pairs(NodeDefines) do
    local node = v.node()
    if node:IsOpen() then
      node:Init(self, Img_Bg)
      self.m_nodes[nodeId] = node
      table.insert(nodeOrderList, {
        nodeId = nodeId,
        node = node,
        order = v.order
      })
    else
      local Tab = Img_Bg:FindDirect(nodeId)
      GUIUtils.SetActive(Tab, false)
    end
  end
  local Tap_Money = Img_Bg:FindDirect("Tap_Money")
  local Tap_YuanBao = Img_Bg:FindDirect("Tap_YuanBao")
  local startPos = Tap_Money.localPosition
  local deltaPos = Tap_YuanBao.localPosition - startPos
  table.sort(nodeOrderList, function(l, r)
    return l.order < r.order
  end)
  for i, v in ipairs(nodeOrderList) do
    local Tab = Img_Bg:FindDirect(v.nodeId)
    if Tab then
      Tab.localPosition = startPos + deltaPos * (i - 1)
    end
  end
  self:AutoSelectNode()
end
def.method().AutoSelectNode = function(self)
  if self:GetNode(self.m_nextNodeId) == nil then
    local nextNodeId, minOder
    for nodeId, node in pairs(self.m_nodes) do
      if minOder == nil or NodeDefines[nodeId].order < minOrder then
        nextNodeId = nodeId
        minOder = NodeDefines[nodeId].order
      end
    end
    self.m_nextNodeId = nextNodeId or NodeId.None
  end
end
def.method("string").SwitchToNode = function(self, nodeId)
  if self.m_curNodeId == nodeId then
    return
  end
  self:HideCurNode()
  self.m_curNodeId = nodeId
  self.m_nextNodeId = nodeId
  local node = self:GetNode(nodeId)
  if node then
    local Tab = self.m_panel:FindDirect("Img_Bg/" .. nodeId)
    GUIUtils.Toggle(Tab, true)
    node:Show()
  else
  end
end
def.method("string", "=>", "table").GetNode = function(self, nodeId)
  if self.m_nodes == nil then
    return nil
  end
  return self.m_nodes[nodeId]
end
def.method("=>", "table").GetCurNode = function(self)
  return self:GetNode(self.m_curNodeId)
end
def.method("number").SetLeftExchangeNum = function(self, leftExchangeNum)
  local Label = self.m_panel:FindDirect("Img_Bg/Label_LeftNum/Label"):GetComponent("UILabel")
  Label:set_text(leftExchangeNum)
end
def.static("table", "table").OnExchangeBanggongChanged = function(params, tbl)
  local node = BanggongExchangePanel.Instance():GetCurNode()
  if node then
    node:OnExchangeBanggongChanged(params, tbl)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:DestroyPanel()
    self = nil
  elseif "Modal" == id then
    self:DestroyPanel()
    self = nil
  elseif id:find("Tap_") then
    local node = self:GetNode(id)
    if node then
      self:SwitchToNode(id)
    end
  else
    local node = self:GetCurNode()
    if node then
      node:onClickObj(clickobj)
    end
  end
end
return BanggongExchangePanel.Commit()
