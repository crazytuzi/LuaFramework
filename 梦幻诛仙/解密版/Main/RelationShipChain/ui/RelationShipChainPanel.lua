local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local GUIUtils = require("GUI.GUIUtils")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local ECLuaString = require("Utility.ECFilter")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ServerListMgr = require("Main.Login.ServerListMgr")
local Network = require("netio.Network")
local OctetsStream = require("netio.OctetsStream")
local RankFriendsNode = require("Main.RelationShipChain.ui.RankFriendsNode")
local GetGiftNode = require("Main.RelationShipChain.ui.GetGiftNode")
local RelationShipChainPanel = Lplus.Extend(ECPanelBase, "RelationShipChainPanel")
local def = RelationShipChainPanel.define
def.const("table").SUBNODEINFO = {
  {
    ID = 1,
    Instance = RankFriendsNode.Instance(),
    GroupName = "Img_Bg0/Group_Power",
    TabName = "Img_Bg0/Tab_Power"
  },
  {
    ID = 2,
    Instance = GetGiftNode.Instance(),
    GroupName = "Img_Bg0/Group_Get",
    TabName = "Img_Bg0/Tab_Get"
  }
}
def.field("number").m_CurNode = 1
def.field("table").m_Nodes = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", RelationShipChainPanel).Instance = function()
  if not instance then
    instance = RelationShipChainPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_RELATIONSHIP_CHAIN_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.m_Nodes = {}
  for k, v in ipairs(RelationShipChainPanel.SUBNODEINFO) do
    local instance = v.Instance
    local groupGO = self.m_panel:FindDirect(v.GroupName)
    local tabGO = self.m_panel:FindDirect(v.TabName)
    self.m_Nodes[k] = instance
    self.m_Nodes[k]:Init(self, groupGO)
    tabGO:SetActive(instance:IsUnlock())
  end
end
def.override().OnDestroy = function(self)
  self.m_CurNode = 1
  self.m_Nodes = nil
  self.m_UIGO = nil
end
def.override("boolean").OnShow = function(self, flag)
  if flag then
    self:Update()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, nil)
  elseif id == "Tab_Power" then
    self:SwitchToNode(RelationShipChainPanel.SUBNODEINFO[1].ID)
  elseif id == "Tab_Get" then
    self:SwitchToNode(RelationShipChainPanel.SUBNODEINFO[2].ID)
  else
    self.m_Nodes[self.m_CurNode]:onClickObj(clickobj)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, nil)
  elseif id == "Tab_Power" then
    self:SwitchToNode(RelationShipChainPanel.SUBNODEINFO[1].ID)
  elseif id == "Tab_Get" then
    self:SwitchToNode(RelationShipChainPanel.SUBNODEINFO[2].ID)
  else
    self.m_Nodes[self.m_CurNode]:onClick(id)
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.m_Nodes[self.m_CurNode]:onDrag(id, dx, dy)
end
def.method("string", "boolean").onPress = function(self, id, state)
  self.m_Nodes[self.m_CurNode]:onPress(id, state)
end
def.method("number").SwitchToNode = function(self, node)
  if self.m_CurNode == node then
    return
  end
  self.m_CurNode = node
  self:Update()
end
def.method().Update = function(self)
  local node = self.m_CurNode
  for _, v in ipairs(RelationShipChainPanel.SUBNODEINFO) do
    local instance = v.Instance
    if v.ID == node then
      instance:InitUI()
      instance:Show()
    else
      instance:Hide()
    end
    instance:UpdateRedot()
  end
end
return RelationShipChainPanel.Commit()
