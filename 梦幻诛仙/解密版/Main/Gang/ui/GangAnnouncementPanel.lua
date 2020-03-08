local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangAnnouncementPanel = Lplus.Extend(ECPanelBase, "GangAnnouncementPanel")
local def = GangAnnouncementPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local HistoryAnnouncementNode = require("Main.Gang.ui.HistoryAnnouncementNode")
local NewAnnouncementNode = require("Main.Gang.ui.NewAnnouncementNode")
def.field("function").callback = nil
def.field("table").tag = nil
def.field("table").annoucementList = nil
def.const("table").NodeId = {HISTORY = 1, NEW = 2}
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").state = 0
def.const("table").StateConst = {History = 1, New = 2}
def.static("=>", GangAnnouncementPanel).Instance = function(self)
  if nil == instance then
    instance = GangAnnouncementPanel()
    instance.state = GangAnnouncementPanel.StateConst.History
  end
  return instance
end
def.static("function", "table").ShowGangAnnouncementPanel = function(callback, tag)
  GangAnnouncementPanel.Instance().callback = callback
  GangAnnouncementPanel.Instance().tag = tag
  GangAnnouncementPanel.Instance().annoucementList = GangData.Instance():GetAnnoList()
  GangAnnouncementPanel.Instance():SetModal(true)
  GangAnnouncementPanel.Instance():CreatePanel(RESPATH.PREFAB_ANNOUNCEMENT_GANG_PANEL, 0)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NewAnno, GangAnnouncementPanel.OnGetNewAnno)
end
def.static("table", "table").OnGetNewAnno = function(params, context)
  GangAnnouncementPanel.Instance().annoucementList = GangData.Instance():GetAnnoList()
  if GangAnnouncementPanel.Instance().curNode == GangAnnouncementPanel.NodeId.HISTORY then
    GangAnnouncementPanel.Instance().nodes[GangAnnouncementPanel.Instance().curNode]:FillHistoryAnnouncements()
    local time = Int64.new(GetServerTime() * 1000)
    GangData.Instance():SetLastReadAnnoTime(time)
    GangData.Instance():SetUnReadAnnoNum(0)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, {0})
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CSendLastAnnouncementTime").new(time))
  end
end
def.override().OnCreate = function(self)
  self.nodes = {}
  self.state = GangAnnouncementPanel.StateConst.History
  local historyNode = self.m_panel:FindDirect("Img_Bg/Group_OldAnn")
  self.nodes[GangAnnouncementPanel.NodeId.HISTORY] = HistoryAnnouncementNode()
  self.nodes[GangAnnouncementPanel.NodeId.HISTORY]:Init(self, historyNode)
  local newNode = self.m_panel:FindDirect("Img_Bg/Group_NewAnn")
  self.nodes[GangAnnouncementPanel.NodeId.NEW] = NewAnnouncementNode()
  self.nodes[GangAnnouncementPanel.NodeId.NEW]:Init(self, newNode)
  if GangAnnouncementPanel.StateConst.History == self.state then
    self:SwitchTo(GangAnnouncementPanel.NodeId.HISTORY)
    local toggle = self.m_panel:FindDirect("Img_Bg/Tab_OldAnn"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif GangAnnouncementPanel.StateConst.New == self.state then
    self:SwitchTo(GangAnnouncementPanel.NodeId.NEW)
    local toggle = self.m_panel:FindDirect("Img_Bg/Tab_New"):GetComponent("UIToggle")
    toggle:set_value(true)
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
def.override().OnDestroy = function(self)
  self.nodes[self.curNode]:Hide()
  self.curNode = 0
  self.state = 0
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NewAnno, GangAnnouncementPanel.OnGetNewAnno)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method().RequireToSwitchToNew = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  if nil == memberInfo then
    return
  end
  local tbl = GangUtility.GetAuthority(memberInfo.duty)
  if false == tbl.isCanPublishAnnouncement then
    Toast(textRes.Gang[89])
    self:SwitchTo(GangAnnouncementPanel.NodeId.HISTORY)
    local toggle = self.m_panel:FindDirect("Img_Bg/Tab_OldAnn"):GetComponent("UIToggle")
    toggle:set_value(true)
    return
  else
    self:SwitchTo(GangAnnouncementPanel.NodeId.NEW)
  end
end
def.method("string", "string").onTextChange = function(self, id, val)
  if GangAnnouncementPanel.Instance().curNode == GangAnnouncementPanel.NodeId.NEW then
    self.nodes[self.curNode]:onTextChange(id, val)
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
  elseif "Tab_OldAnn" == id then
    self:SwitchTo(GangAnnouncementPanel.NodeId.HISTORY)
  elseif "Tab_New" == id then
    self:RequireToSwitchToNew()
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
return GangAnnouncementPanel.Commit()
