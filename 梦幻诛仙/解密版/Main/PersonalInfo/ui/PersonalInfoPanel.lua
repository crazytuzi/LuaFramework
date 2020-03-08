local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PersonalInfoPanel = Lplus.Extend(ECPanelBase, "PersonalInfoPanel")
local PersonInfoNode = require("Main.PersonalInfo.ui.PersonInfoNode")
local RelationInfoNode = require("Main.PersonalInfo.ui.RelationInfoNode")
local SocialPlatformNode = require("Main.PersonalInfo.ui.SocialPlatformNode")
local SocialPlatformMgr = require("Main.PersonalInfo.mgr.SocialPlatformMgr")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local def = PersonalInfoPanel.define
local instance
local NodeId = {
  PERSION = 1,
  RELATION = 2,
  SOCIAL_PLATFORM = 3
}
local NodeDefines = {
  [NodeId.PERSION] = {
    tabName = "Tap_ZL",
    rootName = "Img_ZL",
    node = PersonInfoNode
  },
  [NodeId.RELATION] = {
    tabName = "Tap_GX",
    rootName = "Img_GX",
    node = RelationInfoNode
  },
  [NodeId.SOCIAL_PLATFORM] = {
    tabName = "Tap_GC",
    rootName = "Img_GC",
    node = SocialPlatformNode
  }
}
def.const("table").NodeId = NodeId
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("table").tabToggles = nil
def.field("userdata").Img_Bg = nil
def.field("userdata").roleId = nil
def.field("userdata").spaceDecoration = nil
def.static("=>", PersonalInfoPanel).Instance = function()
  if instance == nil then
    instance = PersonalInfoPanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, roleId)
  if not _G.IsNil(self.m_panel) then
    self:DestroyPanel()
  end
  self.roleId = roleId
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_PERSONAL_INFO_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.EDIT_SUCCESS, PersonalInfoPanel.OnEditSuccess)
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PRAISE_SUCCESS, PersonalInfoPanel.OnPriaseSuccess)
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.QUICK_EDIT_INFO, PersonalInfoPanel.OnQuickEditInfo)
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.CLOSE_PERSONAL_PANEL, PersonalInfoPanel.OnClosePanelNotify)
  Event.RegisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SOCIAL_PLATFORM_OPEN_CHANGE, PersonalInfoPanel.OnSocialPlatformOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PersonalInfoPanel.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, PersonalInfoPanel.OnMasterTaskInfoChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.EDIT_SUCCESS, PersonalInfoPanel.OnEditSuccess)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PRAISE_SUCCESS, PersonalInfoPanel.OnPriaseSuccess)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.QUICK_EDIT_INFO, PersonalInfoPanel.OnQuickEditInfo)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.CLOSE_PERSONAL_PANEL, PersonalInfoPanel.OnClosePanelNotify)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.SOCIAL_PLATFORM_OPEN_CHANGE, PersonalInfoPanel.OnSocialPlatformOpenChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PersonalInfoPanel.OnFeatureOpenChange)
  Event.UnregisterEvent(ModuleId.SHITU, gmodule.notifyId.Shitu.MASTER_TASK_INFO_CHANGE, PersonalInfoPanel.OnMasterTaskInfoChange)
end
def.method().Clear = function(self)
  if self.curNode == NodeId.SOCIAL_PLATFORM then
    self.nodes[self.curNode]:OnDestroy()
  end
  self.curNode = NodeId.PERSION
  if not _G.IsNil(self.spaceDecoration) then
    GameObject.Destroy(self.spaceDecoration)
    self.spaceDecoration = nil
  end
end
def.method("number").SetStartTabNodeId = function(self, id)
  self.curNode = id
end
def.method().InitUI = function(self)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  self.Img_Bg = self.m_panel:FindDirect("Img _Bg0")
  self:InitNodes()
  self:InitTabs()
  self:InitSpaceDecoration()
  local heroId = require("Main.Hero.Interface").GetHeroProp().id
  self.Img_Bg:FindDirect("Tap_GX"):SetActive(heroId == self.roleId)
  self.Img_Bg:FindDirect("Tap_GC"):SetActive(heroId == self.roleId and SocialPlatformMgr.IsOpen())
end
def.method().InitNodes = function(self)
  if not self.Img_Bg or self.Img_Bg.isnil then
    return
  end
  self.nodes = {}
  for nodeId, v in ipairs(NodeDefines) do
    local nodeRoot = self.Img_Bg:FindDirect(v.rootName)
    GUIUtils.SetActive(nodeRoot)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    if v.node then
      self.nodes[nodeId] = v.node()
      self.nodes[nodeId]:Init(self, nodeRoot)
    else
      self.nodes[nodeId] = v.node
    end
  end
end
def.method().InitTabs = function(self)
  if not self.Img_Bg or self.Img_Bg.isnil then
    return
  end
  self.tabToggles = {}
  if self.curNode == 0 then
    self.curNode = NodeId.PERSION
  end
  for nodeId, v in ipairs(NodeDefines) do
    v.nodeId = nodeId
    local toggleObj = self.Img_Bg:FindDirect(v.tabName)
    if toggleObj then
      self.tabToggles[nodeId] = toggleObj:GetComponent("UIToggle")
      self.tabToggles[nodeId].value = false
    end
  end
  if self.m_panel and not self.m_panel.isnil then
    self.tabToggles[self.curNode].value = true
  end
end
def.method().InitSpaceDecoration = function(self)
  if not gmodule.moduleMgr:GetModule(ModuleId.SOCIAL_SPACE):IsOpen() then
    return
  end
  local function removeOldDecoGo()
    if not _G.IsNil(self.spaceDecoration) then
      GameObject.Destroy(self.spaceDecoration)
      self.spaceDecoration = nil
    end
  end
  local resPath = require("Main.SocialSpace.SocialSpaceUtils").GetSavedPendantDecorateResPath()
  if resPath == "" then
    removeOldDecoGo()
    return
  end
  GameUtil.AsyncLoad(resPath, function(ass)
    if ass == nil or not self:IsLoaded() then
      return
    end
    local typename = getmetatable(ass).name
    if typename ~= "GameObject" then
      Debug.LogError("Bad type set to PendantDeco, type:" .. typename .. ",path:" .. resPath)
      return
    end
    local parent = self.Img_Bg:FindDirect("Group_Dec")
    local go = GameObject.Instantiate(ass)
    go:SetActive(true)
    go.parent = parent
    go.localScale = Vector.Vector3.one
    go.localPosition = Vector.Vector3.zero
    self.spaceDecoration = go
  end)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    self.nodes[self.curNode]:Hide()
    if self.m_panel == nil then
      self:Clear()
    end
  else
    self.tabToggles[self.curNode].value = true
    self.nodes[self.curNode]:Show()
    self:UpdateRelationReddot()
  end
end
def.method().UpdateRelationReddot = function(self)
  local InteractMgr = require("Main.Shitu.interact.InteractMgr")
  local img_GX_Red = self.m_panel:FindDirect("Img _Bg0/Tap_GX/Img_RedPoi")
  if InteractMgr.Instance():IsFeatrueTaskOpen(false) then
    GUIUtils.SetActive(img_GX_Red, InteractMgr.Instance():NeedReddot())
  else
    GUIUtils.SetActive(img_GX_Red, false)
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  if self.curNode == nodeId then
    return
  end
  local preNode = self.curNode
  self.curNode = nodeId
  self.nodes[preNode]:Hide()
  self.nodes[self.curNode]:Show()
end
def.method("boolean").UpdateSocialTab = function(self, open)
  if not open then
    if self.Img_Bg:FindDirect("Tap_GC").activeSelf == true and self.Img_Bg:FindDirect("Tap_GC"):GetComponent("UIToggle").value == true then
      self.Img_Bg:FindDirect("Tap_ZL"):GetComponent("UIToggle").value = true
      self:SwitchTo(NodeId.PERSION)
    end
    self.Img_Bg:FindDirect("Tap_GC"):SetActive(false)
  else
    if not self.Img_Bg:FindDirect("Tap_GC").activeSelf == true then
      self.Img_Bg:FindDirect("Tap_GC"):GetComponent("UIToggle").value = false
    end
    self.Img_Bg:FindDirect("Tap_GC"):SetActive(true)
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif "Tap_ZL" == id then
    self:SwitchTo(NodeId.PERSION)
  elseif "Tap_GX" == id then
    self:SwitchTo(NodeId.RELATION)
  elseif "Tap_GC" == id then
    self:SwitchTo(NodeId.SOCIAL_PLATFORM)
  else
    self.nodes[self.curNode]:onClickObj(clickObj)
  end
end
def.static("table", "table").OnEditSuccess = function(p1, p2)
  local curNode = PersonalInfoPanel.Instance().curNode
  if curNode == NodeId.PERSION then
    PersonalInfoPanel.Instance().nodes[curNode]:OnEditSuccess(p1, p2)
  end
end
def.static("table", "table").OnPriaseSuccess = function(p1, p2)
  local curNode = PersonalInfoPanel.Instance().curNode
  if curNode == NodeId.PERSION then
    PersonalInfoPanel.Instance().nodes[curNode]:OnPriaseSuccess(p1, p2)
  end
end
def.static("table", "table").OnQuickEditInfo = function(p1, p2)
  local self = PersonalInfoPanel.Instance()
  local Tap_ZL = self.Img_Bg:FindDirect("Tap_ZL")
  Tap_ZL:GetComponent("UIToggle").value = true
  self:onClickObj(Tap_ZL)
end
def.static("table", "table").OnClosePanelNotify = function(p1, p2)
  local self = PersonalInfoPanel.Instance()
  if self.m_panel ~= nil then
    self:DestroyPanel()
  end
end
def.static("table", "table").OnSocialPlatformOpenChange = function(p1, p2)
  local self = PersonalInfoPanel.Instance()
  if self.m_panel ~= nil then
    self:UpdateSocialTab(p1.open)
  end
end
def.static("table", "table").OnFeatureOpenChange = function(param, context)
  local self = PersonalInfoPanel.Instance()
  if self ~= nil and param.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_SHITU_TASK then
    self:UpdateRelationReddot()
  end
end
def.static("table", "table").OnMasterTaskInfoChange = function(param, context)
  local self = PersonalInfoPanel.Instance()
  if self ~= nil then
    self:UpdateRelationReddot()
  end
end
return PersonalInfoPanel.Commit()
