local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BattlefieldMapMgrBase = import(".BattlefieldMapMgrBase")
local BattlefieldMapRoleMgr = Lplus.Extend(BattlefieldMapMgrBase, MODULE_NAME)
local MiniMapPanel = Lplus.ForwardDeclare("MiniMapPanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local BattleFieldMgr = require("Main.CaptureTheFlag.mgr.BattleFieldMgr")
local RobResPointFeature = require("Main.CaptureTheFlag.mgr.RobResPointFeature")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local PlayType = require("consts.mzm.gsp.singlebattle.confbean.PlayType")
local def = BattlefieldMapRoleMgr.define
def.field("table").m_roleInfoGOs = nil
def.field("userdata").m_templateGO = nil
def.field("boolean").m_showResPoint = false
def.override().OnCreate = function(self)
  self:LoadAll()
  Event.RegisterEventWithContext(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.MAP_ROLE_POS_UPDATE, BattlefieldMapRoleMgr.OnRolePosUpdate, self)
  Event.RegisterEventWithContext(ModuleId.CTF, gmodule.notifyId.CTF.RoleResPointUpdate, BattlefieldMapRoleMgr.OnRoleResPointUpdate, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.MAP_ROLE_POS_UPDATE, BattlefieldMapRoleMgr.OnRolePosUpdate)
  Event.UnregisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleResPointUpdate, BattlefieldMapRoleMgr.OnRoleResPointUpdate)
  self.m_roleInfoGOs = nil
  self.m_templateGO = nil
end
def.method().LoadAll = function(self)
  self.m_roleInfoGOs = {}
  self.m_showResPoint = self:IsRobResPointActive()
  self:AsyncCreateTemplateGO(function(templateGO)
    self.m_templateGO = templateGO
    self:UpdateAllRolesES()
    self:UpdateAllRolePosES()
  end)
end
def.method().UpdateAllRolesES = function(self)
  if self.m_templateGO == nil then
    return
  end
  local allRoleInfos = self:GetAllRolesExcludeSelf()
  for roleId, v in pairs(allRoleInfos) do
    local go = self:GetRoleInfoGO(roleId)
    self:SetRoleInfoGO(go, v)
  end
  self:UpdateAllRoleResPointsES()
end
def.method("string", "=>", "userdata").GetRoleInfoGO = function(self, roleId)
  local roleInfoGO = self:RawGetRoleInfoGO(roleId)
  if roleInfoGO == nil then
    roleInfoGO = self:AddRoleInfoGO(roleId)
  end
  return roleInfoGO
end
def.method("string", "=>", "userdata").RawGetRoleInfoGO = function(self, roleId)
  local roleInfoGO = self.m_roleInfoGOs[roleId]
  return roleInfoGO
end
def.method("string", "=>", "userdata").AddRoleInfoGO = function(self, roleId)
  local roleInfoGO = GameObject.Instantiate(self.m_templateGO)
  roleInfoGO.name = "battlefield_role_" .. roleId
  roleInfoGO:SetActive(true)
  self.m_miniMap:AddUnitToMap(roleInfoGO, {x = 0, y = 0})
  self.m_roleInfoGOs[tostring(roleId)] = roleInfoGO
  return roleInfoGO
end
def.method("userdata", "table").SetRoleInfoGO = function(self, go, roleInfo)
  if go == nil then
    Debug.LogError(debug.traceback())
    return
  end
  local Img_Bg = go:FindDirect("Img_Bg")
  local Label_Name = Img_Bg:FindDirect("Label_Name")
  local Label_No = Img_Bg:FindDirect("Group_Site/Label_Name")
  local Img_Site = Img_Bg:FindDirect("Group_Site/Img_Site")
  local Label_Lv = Img_Bg:FindDirect("Group_Lv/Label_Lv")
  local Group_Resource = Img_Bg:FindDirect("Group_Resource")
  local Img_Resource = Group_Resource:FindDirect("Img_Resource")
  local Img_Resource_Bg = Group_Resource:FindDirect("Img_Resource_Bg")
  local nameText, indexText
  if BattleFieldMgr.Instance():IsEnemy(roleInfo.roleId) then
    nameText = string.format("[ff0000]%s[-]", roleInfo.name)
    indexText = string.format("[ff0000]%s[-]", roleInfo.index)
    GUIUtils.SetSprite(Img_Site, "Img_ResRed03")
    GUIUtils.SetSprite(Img_Resource, "Img_ResRed01")
    GUIUtils.SetSprite(Img_Resource_Bg, "Img_ResRed02")
  else
    nameText = string.format("[00ff00]%s[-]", roleInfo.name)
    indexText = string.format("[00ff00]%s[-]", roleInfo.index)
    GUIUtils.SetSprite(Img_Site, "Img_ResGreen03")
    GUIUtils.SetSprite(Img_Resource, "Img_ResGreen01")
    GUIUtils.SetSprite(Img_Resource_Bg, "Img_ResGreen02")
  end
  GUIUtils.SetText(Label_Name, nameText)
  GUIUtils.SetText(Label_No, indexText)
end
def.method().UpdateAllRolePosES = function(self)
  if self.m_templateGO == nil then
    return
  end
  local allRoleInfos = self:GetAllRolesExcludeSelf()
  for roleId, v in pairs(allRoleInfos) do
    local go = self:GetRoleInfoGO(roleId)
    local pos = BattleFieldMgr.Instance():GetRolePos(v.roleId)
    if pos then
      self.m_miniMap:SetUnitByWorldPos2D(go, pos)
    else
      go:SetActive(false)
    end
  end
end
def.method().UpdateAllRoleResPointsES = function(self)
  if self.m_templateGO == nil then
    return
  end
  if not self.m_showResPoint then
    return
  end
  local allRoleInfos = self:GetAllRolesExcludeSelf()
  for roleId, v in pairs(allRoleInfos) do
    local go = self:RawGetRoleInfoGO(roleId)
    if go then
      self:SetRoleResPoint(go, v)
    end
  end
end
def.method("userdata", "table").SetRoleResPoint = function(self, go, roleInfo)
  local Img_Bg = go:FindDirect("Img_Bg")
  local Group_Resource = Img_Bg:FindDirect("Group_Resource")
  local Label_Resource = Group_Resource:FindDirect("Label_Resource")
  local resPoint = RobResPointFeature.Instance():GetRoleResPoint(roleInfo.roleId)
  GUIUtils.SetText(Label_Resource, resPoint)
end
def.method("function").AsyncCreateTemplateGO = function(self, callback)
  GameUtil.AsyncLoad(RESPATH.PREFAB_SINGLEBATTLE_MINIMAP_PLAYER, function(asset)
    if asset == nil then
      return
    end
    if self.m_miniMap == nil or not self.m_miniMap:IsLoaded() then
      return
    end
    local go = GameObject.Instantiate(asset)
    go:SetLayer(ClientDef_Layer.UI)
    local Img_Bg = go:FindDirect("Img_Bg")
    Img_Bg.localPosition = Vector.Vector3.zero
    local boxCollider = Img_Bg:GetComponent("BoxCollider")
    if boxCollider then
      GameObject.DestroyImmediate(boxCollider)
    end
    local uiWidget = Img_Bg:GetComponent("UIWidget")
    uiWidget.depth = MiniMapPanel.Depths.bf_role
    go.parent = self.m_miniMap.m_panel
    go.localScale = Vector.Vector3.one
    go:SetActive(false)
    local Group_Resource = Img_Bg:FindDirect("Group_Resource")
    GUIUtils.SetActive(Group_Resource, self.m_showResPoint)
    local Label_Name = Img_Bg:FindDirect("Label_Name")
    if Label_Name then
      Label_Name.localPosition = Vector.Vector3.zero
    end
    callback(go)
  end)
end
def.method("=>", "table").GetAllRolesExcludeSelf = function(self)
  local roleInfoData = BattleFieldMgr.Instance():GetRoleInfoData()
  local allRoles = roleInfoData and roleInfoData:GetAllRoles() or {}
  local allRolesExcludeSelf = {}
  for k, v in pairs(allRoles) do
    allRolesExcludeSelf[k] = v
  end
  local selfRoleId = _G.GetMyRoleID()
  allRolesExcludeSelf[tostring(selfRoleId)] = nil
  return allRolesExcludeSelf
end
def.method("table").OnRoleResPointUpdate = function(self, params)
  if not self.m_showResPoint then
    return
  end
  self:UpdateAllRoleResPointsES()
end
def.method("table").OnRolePosUpdate = function(self, params)
  local roleId = params.roleId
  local pos = params.pos
  local go = self:RawGetRoleInfoGO(tostring(roleId))
  if go == nil then
    return
  end
  if go.activeSelf then
    self.m_miniMap:TweenToTargetByWorldPos2D(go, 0.6, pos)
  else
    go:SetActive(true)
    self.m_miniMap:SetUnitByWorldPos2D(go, pos)
  end
end
def.method("=>", "boolean").IsRobResPointActive = function(self)
  local cfgId = BattleFieldMgr.Instance():GetCfgId()
  return RobResPointFeature.Instance():IsActive(cfgId)
end
return BattlefieldMapRoleMgr.Commit()
