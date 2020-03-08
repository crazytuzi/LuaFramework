local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PlayerInfoPanel = Lplus.Extend(ECPanelBase, "PlayerInfoPanel")
local PersonInfoNode = require("Main.PersonalInfo.ui.PersonInfoNode")
local Vector = require("Types.Vector")
local def = PlayerInfoPanel.define
def.field("userdata").roleId = nil
def.field("userdata").Img_Bg = nil
def.field(PersonInfoNode).playerInfoNode = nil
def.field("userdata").spaceDecoration = nil
local instance
def.static("=>", PlayerInfoPanel).Instance = function()
  if instance == nil then
    instance = PlayerInfoPanel()
  end
  return instance
end
def.static("userdata").ShowPanel = function(roleId)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil or heroProp.id == roleId then
    return
  end
  local panel = PlayerInfoPanel.Instance()
  if not _G.IsNil(panel.m_panel) then
    panel:DestroyPanel()
  end
  panel.roleId = roleId
  panel:SetModal(true)
  panel:CreatePanel(RESPATH.PREFAB_PERSONAL_INFO_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEventWithContext(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PRAISE_SUCCESS, PlayerInfoPanel.OnPriaseSuccess, self)
  Event.RegisterEventWithContext(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.RECEIVE_SPACE_DATA, PlayerInfoPanel.OnReceiveSocialSpaceData, self)
  gmodule.moduleMgr:GetModule(ModuleId.PERSONAL_INFO):LoadPlayerSocialSpaceData(self.roleId)
end
def.override().OnDestroy = function(self)
  self.roleId = nil
  self.Img_Bg = nil
  if self.playerInfoNode ~= nil then
    self.playerInfoNode:Hide()
    self.playerInfoNode = nil
  end
  if not _G.IsNil(self.spaceDecoration) then
    GameObject.Destroy(self.spaceDecoration)
    self.spaceDecoration = nil
  end
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.PRAISE_SUCCESS, PlayerInfoPanel.OnPriaseSuccess)
  Event.UnregisterEvent(ModuleId.PERSONAL_INFO, gmodule.notifyId.PersonalInfo.RECEIVE_SPACE_DATA, PlayerInfoPanel.OnReceiveSocialSpaceData)
end
def.method().InitUI = function(self)
  if not self.m_panel or self.m_panel.isnil then
    return
  end
  self.Img_Bg = self.m_panel:FindDirect("Img _Bg0")
  self.Img_Bg:FindDirect("Tap_ZL"):SetActive(true)
  self.Img_Bg:FindDirect("Img_ZL"):SetActive(true)
  self.Img_Bg:FindDirect("Tap_GX"):SetActive(false)
  self.Img_Bg:FindDirect("Img_GX"):SetActive(false)
  self.Img_Bg:FindDirect("Tap_GC"):SetActive(false)
  self.Img_Bg:FindDirect("Img_GC"):SetActive(false)
  self.playerInfoNode = PersonInfoNode()
  self.playerInfoNode:Init(self, self.Img_Bg:FindDirect("Img_ZL"))
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    if self.playerInfoNode ~= nil then
      self.playerInfoNode:Hide()
    end
  else
    self.Img_Bg:FindDirect("Tap_ZL"):GetComponent("UIToggle").value = true
    if self.playerInfoNode ~= nil then
      self.playerInfoNode:Show()
    end
  end
end
def.method("table").ShowSocialSpaceData = function(self, spaceData)
  if spaceData == nil then
    return
  end
  self:UpdateSpaceDecoration(spaceData)
end
def.method("table").UpdateSpaceDecoration = function(self, spaceData)
  local function removeOldDecoGo()
    if not _G.IsNil(self.spaceDecoration) then
      GameObject.Destroy(self.spaceDecoration)
      self.spaceDecoration = nil
    end
  end
  local SocialSpaceUtils = require("Main.SocialSpace.SocialSpaceUtils")
  local widgetItemId = spaceData.baseInfo.widget
  local decoItemCfg
  if widgetItemId ~= 0 then
    decoItemCfg = SocialSpaceUtils.GetDecorationItemCfg(widgetItemId)
  end
  local resId = decoItemCfg and decoItemCfg.resId or 0
  local resPath = _G.GetIconPath(resId)
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
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  else
    self.playerInfoNode:onClickObj(clickObj)
  end
end
def.static("table", "table").OnPriaseSuccess = function(context, params)
  local self = context
  if self.playerInfoNode ~= nil then
    self.playerInfoNode:OnPriaseSuccess(params, nil)
  end
end
def.static("table", "table").OnReceiveSocialSpaceData = function(context, params)
  local self = context
  if self ~= nil then
    self:ShowSocialSpaceData(params)
  end
end
return PlayerInfoPanel.Commit()
