local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BattleFieldDetail = Lplus.Extend(ECPanelBase, "BattleFieldDetail")
local GUIUtils = require("GUI.GUIUtils")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local RoleBaseInfo = require("netio.protocol.mzm.gsp.singlebattle.RoleBaseInfo")
local BattleFieldMgr = Lplus.ForwardDeclare("BattleFieldMgr")
local def = BattleFieldDetail.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = BattleFieldDetail()
    _instance:SetHideOnDestroy(true)
  end
  return _instance
end
def.field("userdata").listCmp1 = nil
def.field("userdata").listCmp2 = nil
def.field("table").roleData = nil
def.static().ShowBattleFieldDetail = function()
  local dlg = BattleFieldDetail.Instance()
  if not dlg:IsShow() then
    dlg:CreatePanel(RESPATH.PREFAB_SINGLEBATTLE_INFO, 1)
  end
end
def.static().Close = function()
  local dlg = BattleFieldDetail.Instance()
  dlg:DestroyPanel()
end
def.static().ClearCache = function()
  local dlg = BattleFieldDetail.Instance()
  dlg:SetHideOnDestroy(false)
  dlg:SetHideOnDestroy(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.CTF, gmodule.notifyId.CTF.RoleDataChange, BattleFieldDetail.OnRoleChange, self)
  self:InitScrollList()
  self:UpdateRoleData()
  self:UpdateTitle()
  self:UpdateScrollList()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleDataChange, BattleFieldDetail.OnRoleChange)
end
def.method("table").OnRoleChange = function(param)
  local dlg = BattleFieldDetail.Instance()
  if dlg:IsShow() then
    BattleFieldDetail.Instance():UpdateRoleData()
    BattleFieldDetail.Instance():UpdateScrollList()
  end
end
def.method().UpdateScrollList = function(self)
  local num1 = #self.roleData.team1
  local num2 = #self.roleData.team2
  ScrollList_setCount(self.listCmp1, num1)
  ScrollList_setCount(self.listCmp2, num2)
  local scroll1 = self.m_panel:FindDirect("Img_Bg/Group_Blue/Scrollview")
  local scroll2 = self.m_panel:FindDirect("Img_Bg/Group_Red/Scrollview")
  GameUtil.AddGlobalTimer(0.01, true, function()
    if not scroll1.isnil then
      scroll1:GetComponent("UIScrollView"):ResetPosition()
    end
    if not scroll2.isnil then
      scroll2:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
end
def.method().UpdateTitle = function(self)
  local icon1 = self.m_panel:FindDirect("Img_Bg/Group_BlueTitle/Img_Points")
  local icon2 = self.m_panel:FindDirect("Img_Bg/Group_RedTitle/Img_Points")
  icon1:GetComponent("UISprite"):set_spriteName(self.roleData.extra)
  icon2:GetComponent("UISprite"):set_spriteName(self.roleData.extra)
  local icon1 = self.m_panel:FindDirect("Img_Bg/Group_Red/Img_Red")
  local icon2 = self.m_panel:FindDirect("Img_Bg/Group_Blue/Img_Blue")
  local team1Cfg = CaptureTheFlagUtils.GetCampCfg(self.roleData.team1Id)
  local team2Cfg = CaptureTheFlagUtils.GetCampCfg(self.roleData.team2Id)
  icon1:GetComponent("UISprite"):set_spriteName(team1Cfg.campNameIcon)
  icon2:GetComponent("UISprite"):set_spriteName(team2Cfg.campNameIcon)
end
def.method().UpdateRoleData = function(self)
  self.roleData = BattleFieldMgr.Instance():GetRoleDataSorted()
end
def.method().InitScrollList = function(self)
  local scroll1 = self.m_panel:FindDirect("Img_Bg/Group_Red/Scrollview")
  local list = scroll1:FindDirect("List")
  self.listCmp1 = list:GetComponent("UIScrollList")
  local GUIScrollList = list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    list:AddComponent("GUIScrollList")
  end
  ScrollList_setUpdateFunc(self.listCmp1, function(item, i)
    self:FillRedRoleInfo(item, i)
  end)
  self.m_msgHandler:Touch(list)
  local scroll2 = self.m_panel:FindDirect("Img_Bg/Group_Blue/Scrollview")
  list = scroll2:FindDirect("List")
  self.listCmp2 = list:GetComponent("UIScrollList")
  local GUIScrollList = list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    list:AddComponent("GUIScrollList")
  end
  ScrollList_setUpdateFunc(self.listCmp2, function(item, i)
    self:FillBlueRoleInfo(item, i)
  end)
  self.m_msgHandler:Touch(list)
end
def.method("userdata", "number").FillBlueRoleInfo = function(self, uiGo, index)
  local roleInfo = self.roleData.team2[index]
  self:FillRoleInfo(uiGo, roleInfo)
end
def.method("userdata", "number").FillRedRoleInfo = function(self, uiGo, index)
  local roleInfo = self.roleData.team1[index]
  self:FillRoleInfo(uiGo, roleInfo)
end
def.method("userdata", "table").FillRoleInfo = function(self, uiGo, roleInfo)
  local head = uiGo:FindDirect("Player/Img_Head")
  local lv = head:FindDirect("Label_Lv")
  local serverName = uiGo:FindDirect("Player/Label_ServerName")
  local gender = uiGo:FindDirect("Player/Group_Info/Img_Sex")
  local menpai = uiGo:FindDirect("Player/Group_Info/Img_MenPai")
  local name = uiGo:FindDirect("Player/Group_Info/Label_PlayerName")
  local bg = uiGo:FindDirect("Img_Player")
  if roleInfo.id == GetMyRoleID() then
    bg:SetActive(true)
  else
    bg:SetActive(false)
  end
  local value1 = uiGo:FindDirect("Game/Label_Info01")
  local value2 = uiGo:FindDirect("Game/Label_Info02")
  local value3 = uiGo:FindDirect("Game/Label_Info03")
  local state = head:FindDirect("Img_State")
  if roleInfo.state == RoleBaseInfo.STATE_NORMAL then
    state:SetActive(false)
  elseif roleInfo.state == RoleBaseInfo.STATE_NORMAL then
    state:SetActive(true)
    state:GetComponent("UISprite"):set_spriteName("Label_Lx")
  elseif roleInfo.state == RoleBaseInfo.STATE_NORMAL then
    state:SetActive(true)
    state:GetComponent("UISprite"):set_spriteName("Label_Tp")
  end
  SetAvatarIcon(head, roleInfo.avatarId)
  if roleInfo.respawn > GetServerTime() then
    GUIUtils.SetTextureEffect(head:GetComponent("UITexture"), GUIUtils.Effect.Gray)
  else
    GUIUtils.SetTextureEffect(head:GetComponent("UITexture"), GUIUtils.Effect.Normal)
  end
  lv:GetComponent("UILabel"):set_text(tostring(roleInfo.level))
  serverName:GetComponent("UILabel"):set_text(roleInfo.zoneName)
  gender:GetComponent("UISprite"):set_spriteName(GUIUtils.GetGenderSprite(roleInfo.gender))
  menpai:GetComponent("UISprite"):set_spriteName(GUIUtils.GetOccupationSmallIcon(roleInfo.occupation))
  name:GetComponent("UILabel"):set_text(roleInfo.name)
  value1:GetComponent("UILabel"):set_text(roleInfo.kill)
  value2:GetComponent("UILabel"):set_text(roleInfo.die)
  value3:GetComponent("UILabel"):set_text(roleInfo.extra or "")
  self.m_msgHandler:Touch(uiGo)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
BattleFieldDetail.Commit()
return BattleFieldDetail
