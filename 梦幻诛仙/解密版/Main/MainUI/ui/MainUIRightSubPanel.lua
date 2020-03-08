local Lplus = require("Lplus")
local ComponentBase = require("Main.MainUI.ui.MainUIComponentBase")
local MainUIRightSubPanel = Lplus.Extend(ComponentBase, "MainUIRightSubPanel")
local GUIUtils = require("GUI.GUIUtils")
local def = MainUIRightSubPanel.define
local ECFxMan = require("Fx.ECFxMan")
local BitMap = require("Types.BitMap")
local MainUIModule = Lplus.ForwardDeclare("MainUIModule")
local ECApollo = require("ProxySDK.ECApollo")
local TeamData = require("Main.Team.TeamData")
local TeamPlatformMgr = require("Main.TeamPlatform.TeamPlatformMgr")
local dlgTeamerOperater = require("Main.MainUI.ui.MainUITeamOperate").Instance()
local NOTIFY_EFFECT = "Arts/Effects/Fxs/UI_Panel_Team_ZuDuiShenQing.u3dext"
local TeamMemberStatus = require("netio.protocol.mzm.gsp.team.TeamMember")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local teamData = TeamData.Instance()
def.field("number").m_selectedIndex = 0
def.field("boolean").isOpen = true
def.field("boolean").attemptOpen = true
def.field("number").matchTimerId = 0
def.field("table").uiObjs = nil
def.field("table").members = nil
def.field("userdata").roleId = nil
def.field("string").roleName = ""
def.field("boolean").invitePanel = false
def.field("table").guide = nil
local Tab = {Task = 1, Team = 2}
def.const("table").Tab = Tab
def.field("number").tab = Tab.Task
def.field(BitMap).m_taskVisibleBitMap = nil
local instance
def.static("=>", MainUIRightSubPanel).Instance = function()
  if instance == nil then
    instance = MainUIRightSubPanel()
    instance:Init()
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, MainUIRightSubPanel.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, MainUIRightSubPanel.OnUpdateTeam)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.NEW_TEAM_INVITATION, MainUIRightSubPanel.onUpdateTeamInvitation)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, MainUIRightSubPanel.onUpdateTeamApplication)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_TEAM_DISMISS, MainUIRightSubPanel.onUpdateTeamApplication)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, MainUIRightSubPanel.onUpdateTeamApplication)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INVITATION, MainUIRightSubPanel.onUpdateTeamInvitation)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.NEW_TEAM_APPLY_OR_INVITE, MainUIRightSubPanel.onNewApplyOrInvite)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_UPGRADE_TO_CAPTION, MainUIRightSubPanel.onShowTeamTab)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, MainUIRightSubPanel.onShowTeamTab)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_KICK_TEAM, MainUIRightSubPanel.onShowTeamTab)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, MainUIRightSubPanel.onChangeToTeamTab)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, MainUIRightSubPanel.onChangeLeader)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_ROOM_STATE, MainUIRightSubPanel.OnUpdateTeamMemberRoomState)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_VOCIE_SPEAKER_STATE, MainUIRightSubPanel.OnUpdateTeamVoiceSpeakerState)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_VOCIE_MIC_STATE, MainUIRightSubPanel.OnUpdateTeamVoiceMicState)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.JOIN_VOCIE_ROOM, MainUIRightSubPanel.OnJoinTeamVoiceRoom)
  Event.RegisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.SYNC_MATCH_STATE, MainUIRightSubPanel.OnSyncMatchState)
  Event.RegisterEvent(ModuleId.TEAM_PLATFORM, gmodule.notifyId.TeamPlatform.SYNC_TEAM_MATCH_STATE, MainUIRightSubPanel.OnSyncMatchState)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MOVE_IN_TEAM_FOLLOW, MainUIRightSubPanel.onMoveInTeamFollow)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MainUIRightSubPanel.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.ENTER_SOLO_DUNGEON, MainUIRightSubPanel.OnEnterDungeon)
  Event.RegisterEvent(ModuleId.DUNGEON, gmodule.notifyId.Dungeon.ENTER_TEAM_DUNGEON, MainUIRightSubPanel.OnEnterDungeon)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_MOUNT, MainUIRightSubPanel.OnUpdateTeamMount)
  self.m_taskVisibleBitMap = BitMap.New(0)
  local SceneDef = MainUIModule.SceneDef
  self.m_taskVisibleBitMap:SetBit(MainUIModule.SceneDef.JueZhanJiuXiao, 1)
  self.m_taskVisibleBitMap:SetBit(MainUIModule.SceneDef.PhantomCave, 1)
  self.m_taskVisibleBitMap:SetBit(MainUIModule.SceneDef.WEDDING, 1)
  self.m_taskVisibleBitMap:SetBit(MainUIModule.SceneDef.HULA, 1)
  self.m_taskVisibleBitMap:SetBit(MainUIModule.SceneDef.ZHUXIANJIANZHEN, 1)
  self.m_taskVisibleBitMap:SetBit(MainUIModule.SceneDef.CROSS_BATTLE, 1)
  self.m_taskVisibleBitMap:SetBit(MainUIModule.SceneDef.POINTS_RACE, 1)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.invitePanel = false
end
def.override().OnDestroy = function(self)
  self:ClearUI()
end
def.method("boolean").showTeamMenuEffect = function(self, isShow)
  if not self.uiObjs or not self.uiObjs.Group_TeamBtn then
    return
  end
  local eft = self.uiObjs.Group_TeamBtn:FindDirect("Btn_Team/UI_FX")
  eft:SetActive(false)
  eft:SetActive(isShow)
end
def.method().hideTeamMenu = function(self)
  if self.uiObjs ~= nil and self.uiObjs.Group_TeamBtn ~= nil then
    self.uiObjs.Group_TeamBtn:SetActive(false)
  end
end
def.method().UpdateTeamVoiceRoomBtn = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_EnterRoom, ECApollo.GetVoipStatus() == ECApollo.STATUS.NORMAL)
  GUIUtils.SetActive(self.uiObjs.Group_Sound, ECApollo.GetVoipStatus() == ECApollo.STATUS.JOIN)
  GUIUtils.SetActive(self.uiObjs.Group_Mic, ECApollo.GetVoipStatus() == ECApollo.STATUS.JOIN)
end
def.method().UpdateTeamVoiceSpeakerBtn = function(self)
  local inRoom = ECApollo.GetVoipStatus() == ECApollo.STATUS.JOIN
  GUIUtils.SetActive(self.uiObjs.Group_Sound:FindDirect("Btn_OpenSound"), inRoom and ECApollo.GetCurrentSpeakerState())
  GUIUtils.SetActive(self.uiObjs.Group_Sound:FindDirect("Btn_CloseSound"), inRoom and not ECApollo.GetCurrentSpeakerState())
end
def.method().UpdateTeamVoiceMicBtn = function(self)
  local inRoom = ECApollo.GetVoipStatus() == ECApollo.STATUS.JOIN
  GUIUtils.SetActive(self.uiObjs.Group_Mic:FindDirect("Btn_OpenMic"), inRoom and ECApollo.GetCurrentMicState())
  GUIUtils.SetActive(self.uiObjs.Group_Mic:FindDirect("Btn_CloseMic"), inRoom and not ECApollo.GetCurrentMicState())
end
def.method().UpdateTeamVoicePanel = function(self)
  GUIUtils.SetActive(self.uiObjs.Team_Apollo, teamData:HasTeam() and FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_TEAM_VOIP_ROOM) and ECApollo.IsNewPackageEX())
  self:UpdateTeamVoiceRoomBtn()
  self:UpdateTeamVoiceSpeakerBtn()
  self:UpdateTeamVoiceMicBtn()
  self:ResetTeamBtns()
end
def.method().UpdateTeamRideBtn = function(self)
  if teamData.teamMountData == nil or teamData.teamMountData.mountId <= 0 or teamData:MeIsCaptain() or teamData:MeIsAFK() then
    GUIUtils.SetActive(instance.uiObjs.Group_Ride, false)
    return
  end
  local MountsUtils = require("Main.Mounts.MountsUtils")
  local mountsCfg = MountsUtils.GetMountsCfgById(teamData.teamMountData.mountId)
  if mountsCfg == nil or mountsCfg.maxMountRoleNum == 1 then
    GUIUtils.SetActive(instance.uiObjs.Group_Ride, false)
    return
  end
  local curRoleNum = table.nums(teamData.teamMountData.rider_ids)
  local isOnMount = teamData:IsOnTeamMount()
  if not isOnMount and mountsCfg.maxMountRoleNum - curRoleNum == 0 then
    GUIUtils.SetActive(instance.uiObjs.Group_Ride, false)
    return
  end
  GUIUtils.SetActive(instance.uiObjs.Group_Ride, true)
  local a_ride = instance.uiObjs.Group_Ride:FindDirect("Btn_ARide")
  local d_ride = instance.uiObjs.Group_Ride:FindDirect("Btn_DRide")
  a_ride:SetActive(not isOnMount)
  d_ride:SetActive(isOnMount)
  if not isOnMount then
    GUIUtils.SetLightEffect(a_ride, GUIUtils.Light.Round)
  end
  self:ResetTeamBtns()
end
def.method().ResetTeamBtns = function(self)
  local a_ride = instance.uiObjs.Group_Ride:FindDirect("Btn_ARide")
  local d_ride = instance.uiObjs.Group_Ride:FindDirect("Btn_DRide")
  if ECApollo.GetVoipStatus() == ECApollo.STATUS.JOIN then
    local op_btn = instance.uiObjs.Group_Sound:FindDirect("Btn_OpenSound")
    local mic_btn = instance.uiObjs.Group_Mic:FindDirect("Btn_OpenMic")
    a_ride.position = mic_btn.position + mic_btn.position - op_btn.position
  elseif self.uiObjs.Group_EnterRoom.activeSelf then
    local mic_btn = instance.uiObjs.Group_Mic:FindDirect("Btn_OpenMic")
    a_ride.position = mic_btn.position
  else
    local op_btn = instance.uiObjs.Group_Sound:FindDirect("Btn_OpenSound")
    a_ride.position = op_btn.position
  end
  d_ride.position = a_ride.position
end
def.static("table", "table").OnUpdateTeamMount = function(p1, p2)
  if instance == nil or instance.uiObjs == nil then
    return
  end
  instance:UpdateTeamRideBtn()
end
def.method().showTeamMenu = function(self)
  if self.uiObjs ~= nil and self.uiObjs.Group_TeamBtn ~= nil then
    self.uiObjs.Group_TeamBtn:SetActive(false)
  else
    return
  end
  if teamData:HasTeam() and teamData:MeIsCaptain() == false and teamData:isFighting() == false then
    self.uiObjs.Group_TeamBtn:SetActive(true)
    if self.attemptOpen == true then
    end
    local members = teamData:GetAllTeamMembers()
    local leaderid = members[1].roleid
    local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(leaderid)
    if role ~= nil and role:IsInState(RoleState.WATCH) == true then
      self.uiObjs.Group_TeamBtn:FindDirect("Img_Bg/Btn_Watch"):SetActive(true)
    else
      self.uiObjs.Group_TeamBtn:FindDirect("Img_Bg/Btn_Watch"):SetActive(false)
    end
    local member = teamData:getMember(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId())
    if member ~= nil then
      if member.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
        self.uiObjs.Group_TeamBtn:FindDirect("Img_Bg/Btn_TmpLeave/Label"):GetComponent("UILabel"):set_text(textRes.Team[102])
      elseif member.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
        self.uiObjs.Group_TeamBtn:FindDirect("Img_Bg/Btn_TmpLeave/Label"):GetComponent("UILabel"):set_text(textRes.Team[103])
      end
    end
  else
    self.uiObjs.Group_TeamBtn:SetActive(false)
  end
  self.uiObjs.Group_TeamBtn:FindDirect("Img_Bg"):GetComponent("UITableResizeBackground"):Reposition()
  self:showTeamMenuEffect(false)
  self:UpdateTeamVoicePanel()
end
def.method().InitUI = function(self)
  if not self.m_node then
    return
  end
  self.uiObjs = {}
  self.uiObjs.Group_Open = self.m_node:FindDirect("Group_Open")
  self.uiObjs.Team = self.uiObjs.Group_Open:FindDirect("Team")
  self.uiObjs.Img_BgNoTeam = self.uiObjs.Team:FindDirect("Img_BgNoTeam")
  self.uiObjs.TeamList = self.uiObjs.Team:FindDirect("TeamList")
  self.uiObjs.Group_Invite = self.uiObjs.Team:FindDirect("Group_Invite")
  self.uiObjs.Img_BgWaiting = self.uiObjs.Team:FindDirect("Img_BgWaiting")
  self.uiObjs.Team_Apollo = self.uiObjs.Team:FindDirect("Team_Apollo")
  self.uiObjs.Group_Ride = self.uiObjs.Team:FindDirect("Group_Ride")
  self.uiObjs.Group_Sound = self.uiObjs.Team_Apollo:FindDirect("Group_Right/Group_Sound")
  self.uiObjs.Group_Mic = self.uiObjs.Team_Apollo:FindDirect("Group_Right/Group_Mic")
  self.uiObjs.Group_EnterRoom = self.uiObjs.Team_Apollo:FindDirect("Group_Right/Group_EnterRoom")
  self.uiObjs.Group_TeamBtn = self.m_node:FindDirect("Group_Open/Group_TeamBtn")
  self.uiObjs.luaPlayTween = true
  self.uiObjs.Btn_Right = self.m_node:FindDirect("Group_Open/Btn_Right")
  self.uiObjs.Btn_Left = self.m_node:FindDirect("Group_Close/Btn_Left")
  self.uiObjs.Btn_Right:GetComponent("UIPlayTween").enabled = not self.uiObjs.luaPlayTween
  self.uiObjs.Btn_Left:GetComponent("UIPlayTween").enabled = not self.uiObjs.luaPlayTween
  local Label_WaitingDescibe = self.uiObjs.Img_BgWaiting:FindDirect("Label_WaitingDescibe")
  Label_WaitingDescibe:GetComponent("UILabel"):set_text(textRes.TeamPlatform[5])
  self:showTeamMenu()
end
def.method().ClearUI = function(self)
  if self.matchTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.matchTimerId)
    self.matchTimerId = 0
  end
  self.uiObjs = nil
  self.isOpen = true
  self.invitePanel = false
  self.tab = Tab.Task
end
def.override("=>", "boolean").CanShowInFight = function(self)
  return true
end
def.override("=>", "boolean").CanDispaly = function(self)
  return true
end
def.override().Expand = function(self)
  self:OpenSubPanel(true)
end
def.override().Shrink = function(self)
  self:CloseSubPanel(true)
end
def.override().OnEnterFight = function(self)
  self:CloseSubPanel(true)
end
def.override().OnLeaveFight = function(self)
  if self.attemptOpen then
    self:OpenSubPanel(true)
  else
    self:CloseSubPanel(true)
  end
end
def.override().CheckDisplayable = function(self)
  ComponentBase.CheckDisplayable(self)
  local function toggle(curFunc, nextFunc)
    if self:CanToggleOn(self.tab) then
      curFunc(self, true)
    else
      nextFunc(self, true)
    end
  end
  if self.tab == Tab.Task then
    toggle(self.ToggleTask, self.ToggleTeam)
  else
    toggle(self.ToggleTeam, self.ToggleTask)
  end
end
def.method("number", "=>", "boolean").CanToggleOn = function(self, tab)
  if tab == Tab.Task then
    return self:IsTaskVisible()
  else
    return true
  end
end
def.method("number", "=>", "number").NextToggle = function(self, tab)
  if tab == Tab.Task then
    return Tab.Team
  else
    return Tab.Task
  end
end
def.method().ToggleOnTeam = function(self)
  if not self.m_node then
    return
  end
  self:ToggleOn(Tab.Team)
  self.m_node:FindDirect("Group_Open/Task"):SetActive(false)
  self.m_node:FindDirect("Group_Open/Team"):SetActive(true)
end
def.method().ToggleOnTask = function(self)
  if not self.m_node then
    return
  end
  self:ToggleOn(Tab.Task)
end
def.method("number").ToggleOn = function(self, tab)
  if not self.m_node then
    return
  end
  local Group_Open = self.m_node:FindDirect("Group_Open")
  Group_Open:FindDirect("Tab_Team/Img_BgTeamSelet"):SetActive(tab == Tab.Team)
  Group_Open:FindDirect("Team"):SetActive(tab == Tab.Team)
  Group_Open:FindDirect("Tab_Task/Img_BgTaskSelet"):SetActive(tab == Tab.Task)
  Group_Open:FindDirect("Task"):SetActive(tab == Tab.Task)
end
def.method("number", "=>", "userdata").GetTabObj = function(self, tab)
  local tabObj
  if tab == Tab.Team then
    tabObj = self.m_node:FindDirect("Group_Open/Tab_Team")
  elseif tab == Tab.Task then
    tabObj = self.m_node:FindDirect("Group_Open/Tab_Task")
  end
  return tabObj
end
def.method("=>", "boolean").IsTaskVisible = function(self)
  local sceneBitMap = MainUIModule.Instance().sceneBitMap
  return self.m_taskVisibleBitMap:AND(sceneBitMap):IsZero()
end
def.method("boolean").ToggleTeam = function(self, value)
  if value == true and self:CanToggleOn(Tab.Team) then
    self:ToggleOnTeam()
    self:ShowTeam()
  end
end
def.method("boolean").ToggleTask = function(self, value)
  if value == true and self:CanToggleOn(Tab.Task) then
    self:ToggleOnTask()
    self:ShowTask()
  end
end
def.static("table", "table").OnUpdateTeam = function()
  if instance == nil or _G.IsNil(instance.m_panel) then
    return
  end
  instance:showTeamMenu()
  if instance.m_panel.activeInHierarchy ~= nil then
    if teamData:HasTeam() == true then
      instance:ClearAllInvitation()
      instance:ShowTeamMembers()
    else
      instance:showInvitation()
    end
  end
end
def.static("table", "table").OnUpdateTeamMemberRoomState = function(p1, p2)
  if instance.m_panel and not instance.m_panel.isnil and instance.members then
    local panel = instance.m_node:FindDirect("Group_Open/Team/TeamList/List_TeamList")
    for i = 1, panel:get_childCount() - 1 do
      local iconGO = panel:FindDirect(("Img_TeamMember01_%d/Img_Inroom_%d"):format(i, i))
      GUIUtils.SetActive(iconGO, false)
    end
    for _, roleId in pairs(p1[1]) do
      for k, v in pairs(instance.members) do
        local iconGO = panel:FindDirect(("Img_TeamMember01_%d/Img_Inroom_%d"):format(k, k))
        if v.roleid:eq(roleId) then
          GUIUtils.SetActive(iconGO, true)
        end
      end
    end
  end
end
def.static("table", "table").OnUpdateTeamVoiceSpeakerState = function(p1, p2)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateTeamVoiceSpeakerBtn()
  end
end
def.static("table", "table").OnUpdateTeamVoiceMicState = function(p1, p2)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateTeamVoiceMicBtn()
  end
end
def.static("table", "table").OnJoinTeamVoiceRoom = function(p1, p2)
  if instance.m_panel and not instance.m_panel.isnil then
    instance:UpdateTeamVoicePanel()
  end
end
def.static("table", "table").onNewApplyOrInvite = function()
  if teamData:HasTeam() == true and teamData:IsCaptain(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) then
    instance:playNotifyEffect()
  elseif teamData:HasTeam() == false then
    instance:playNotifyEffect()
  end
end
def.static("table", "table").onChangeToTeamTab = function()
  if teamData and teamData:MeIsCaptain() and instance.tab ~= Tab.Team and instance:CanToggleOn(Tab.Team) then
    instance:ToggleOnTeam()
    instance:ShowTeam()
  end
end
def.static("table", "table").onShowTeamTab = function()
  instance:ToggleOnTeam()
  instance:ShowTeam()
end
def.static("table", "table").onChangeLeader = function()
  instance:hideTeamMenu()
end
def.static("table", "table").onUpdateTeamInvitation = function()
  MainUIRightSubPanel.Instance():showInvitationRed()
  local invitations = teamData:GetTeamInvitation()
  if #invitations == 0 then
    MainUIRightSubPanel.Instance().invitePanel = false
    return
  end
  if MainUIRightSubPanel.Instance().invitePanel == true then
    return
  end
  local inviter = invitations[1]
  local text = string.format(textRes.Team[85], inviter.name)
  MainUIRightSubPanel.Instance().invitePanel = true
  require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.Team[84], text, textRes.Team[87], textRes.Team[86], 0, inviter.time, function(option, context)
    if 1 == option then
      local pro = require("netio.protocol.mzm.gsp.team.CInviteTeamRep")
      gmodule.network.sendProtocol(pro.new(inviter.inviter, inviter.sessionid, pro.REPLY_ACCEPT))
      teamData:ClearTeamInvitation()
      MainUIRightSubPanel.Instance():showInvitationRed()
      MainUIRightSubPanel.Instance().invitePanel = false
    elseif 0 == option or option == -1 then
      local pro = require("netio.protocol.mzm.gsp.team.CInviteTeamRep")
      gmodule.network.sendProtocol(pro.new(inviter.inviter, inviter.sessionid, pro.REPLY_REFUSE))
      teamData:removeInviter(inviter.inviter)
      MainUIRightSubPanel.Instance().invitePanel = false
      MainUIRightSubPanel.onUpdateTeamInvitation(nil, nil)
    end
  end, nil)
end
def.static("table", "table").onUpdateTeamApplication = function()
  if instance.m_panel and not instance.m_panel.isnil and instance.m_panel.activeInHierarchy then
    instance:showApplication()
  end
end
def.override("boolean").SetVisible = function(self, visible)
  if not self.m_node then
    return
  end
  if visible then
    self.m_node:GetComponent("UIWidget"):set_alpha(1)
    if self.tab == Tab.Team then
      self:ShowTeam()
    else
      require("Main.MainUI.ui.MainUITaskTrace").Instance():UpdateUI()
    end
  else
    self.m_node:GetComponent("UIWidget"):set_alpha(0)
  end
end
def.override().OnShow = function(self)
  if not self.m_node then
    return
  end
  local isAuto = true
  if self.attemptOpen and _G.PlayerIsInFight() == false then
    self:OpenSubPanel(isAuto)
  else
    self:CloseSubPanel(isAuto)
  end
  self.m_node:FindDirect("Group_Close/Btn_Left"):SetActive(true)
  self.m_node:FindDirect("Group_Open/Tab_Team/Img_Red"):SetActive(false)
  self:showLeftButtonRedPoint(false, 0)
  if self.tab == Tab.Team then
    self:ShowTeam()
  else
    require("Main.MainUI.ui.MainUITaskTrace").Instance():UpdateUI()
  end
  self.m_node:FindDirect("UI_Panel_Main_ZuDuiShenQing"):SetActive(false)
  self:UpdateTeamRideBtn()
end
def.override().OnHide = function(self)
  if not self.m_node then
    return
  end
  self.m_node:FindDirect("Group_Close/Btn_Left"):SetActive(false)
end
def.method().ShowTeam = function(self)
  self.tab = Tab.Team
  if self:NeedShowMatchingInfo() then
    self:ShowMatchingInfo()
  elseif teamData:HasTeam() == true then
    self:ShowTeamMembers()
  else
    self:showInvitation()
  end
end
def.method().ShowTask = function(self)
  self.tab = Tab.Task
  require("Main.MainUI.ui.MainUITaskTrace").Instance():UpdateUI()
end
def.method().playNotifyEffect = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if not self.m_node then
    return
  end
  self.m_node:FindDirect("UI_Panel_Main_ZuDuiShenQing"):SetActive(false)
  self.m_node:FindDirect("UI_Panel_Main_ZuDuiShenQing"):SetActive(true)
end
def.method().showInvitationRed = function(self)
  if teamData:HasTeam() == false then
    if self.m_node == nil then
      return
    end
    local invitations = teamData:GetTeamInvitation()
    local redFlag = self.m_node:FindDirect("Group_Open/Tab_Team/Img_Red")
    if redFlag == nil then
      return
    end
    if invitations ~= nil and #invitations >= 1 then
      redFlag:SetActive(true)
      redFlag:FindDirect("Label_RedNum"):GetComponent("UILabel"):set_text(string.format("%d", #invitations))
    else
      redFlag:SetActive(false)
    end
  else
    local redFlag = self.m_node:FindDirect("Group_Open/Tab_Team/Img_Red")
    if redFlag ~= nil then
      redFlag:SetActive(false)
    end
  end
end
def.method().showApplication = function(self)
  if not self.m_node then
    return
  end
  local applicatoins = teamData:GetAllApplicants()
  local bCaption = teamData:IsCaptain(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId())
  if #applicatoins > 0 and true == bCaption then
    self:showLeftButtonRedPoint(true, #applicatoins)
  else
    self:showLeftButtonRedPoint(false, #applicatoins)
  end
  local redFlag = self.m_node:FindDirect("Group_Open/Tab_Team/Img_Red")
  if #applicatoins >= 1 then
    if true == bCaption then
      redFlag:SetActive(true)
      redFlag:FindDirect("Label_RedNum"):GetComponent("UILabel"):set_text(string.format("%d", #applicatoins))
    else
      redFlag:SetActive(false)
    end
  else
    redFlag:SetActive(false)
  end
end
def.method("boolean", "number").showLeftButtonRedPoint = function(self, bRed, num)
  if not self.m_node then
    return
  end
  local redFlag = self.m_node:FindDirect("Group_Close/Btn_Left/Img_Red")
  if true == bRed then
    redFlag:SetActive(true)
    redFlag:FindDirect("Label_RedNum"):GetComponent("UILabel"):set_text(string.format("%d", num))
  else
    redFlag:SetActive(false)
    self.m_node:FindDirect("UI_Panel_Main_ZuDuiShenQing"):SetActive(false)
  end
end
def.method().showInvitation = function(self)
  if not self.m_node then
    return
  end
  if teamData:HasTeam() == true then
    return
  end
  local invitations = teamData:GetTeamInvitation()
  local count = 0
  if invitations ~= nil then
    count = #invitations
  end
  self:showLeftButtonRedPoint(false, count)
  self:ShowCreateButtons(true)
  if self:NeedShowMatchingInfo() then
    self:ShowCreateButtons(false)
    return
  end
  self.m_node:FindDirect("Group_Open/Team/TeamList"):SetActive(false)
  self.m_node:FindDirect("Group_Open/Team/Img_BgWaiting"):SetActive(false)
  self.m_node:FindDirect("Group_Open/Team/Group_Invite"):SetActive(false)
end
def.method("number").UpdateTeamTabRedPoint = function(self, notifyCount)
  if not self.m_node then
    return
  end
  local redFlag = self.m_node:FindDirect("Group_Open/Tab_Team/Img_Red")
  if notifyCount < 1 then
    redFlag:SetActive(false)
  else
    redFlag:SetActive(true)
    redFlag:FindDirect("Label_RedNum"):GetComponent("UILabel"):set_text(string.format("%d", notifyCount))
  end
end
def.method().ShowTeamMembers = function(self)
  if not self.m_node then
    return
  end
  self.m_node:FindDirect("Group_Open/Team/Group_Invite"):SetActive(false)
  self.m_node:FindDirect("Group_Open/Team/TeamList"):SetActive(true)
  local teamPanel = self.m_node:FindDirect("Group_Open/Team/TeamList")
  self.m_node:FindDirect("Group_Open/Team/Img_BgWaiting"):SetActive(false)
  local panel = self.m_node:FindDirect("Group_Open/Team/TeamList/List_TeamList")
  local uiList = panel:GetComponent("UIList")
  local members = teamData:GetAllTeamMembers()
  uiList.itemCount = #members
  uiList:Resize()
  self:ShowCreateButtons(false)
  local itemHeight = 0
  for i = 1, 5 do
    local memberPanel = panel:FindDirect("Img_TeamMember01_" .. i)
    if memberPanel ~= nil then
      memberPanel:FindDirect("Img_PiPei_" .. i):SetActive(false)
    end
  end
  local uiIdx = 1
  self.m_node:FindDirect("Group_Open/Team/Img_BgNoTeam"):SetActive(false)
  self.members = {}
  local teamPlatformMgr = require("Main.TeamPlatform.TeamPlatformMgr").Instance()
  local TeamData = require("Main.Team.TeamData")
  local positions = teamData:getTeamPosition()
  for k = 1, 5 do
    if positions[k] ~= nil and positions[k].dispositionMemberType == require("netio.protocol.mzm.gsp.team.TeamDispositionMemberInfo").DT_TEAM_MEMBER then
      for i = 1, #members do
        if positions[k].teamDispositionMember_id == members[i].roleid and members[i].status == TeamMemberStatus.ST_NORMAL then
          local memberPanel = panel:FindDirect("Img_TeamMember01_" .. uiIdx)
          if memberPanel ~= nil then
            memberPanel:FindDirect("Label_Name01_" .. uiIdx):GetComponent("UILabel").text = members[i].name
            local menpaiIcon = memberPanel:FindDirect("Img_School01_" .. uiIdx):GetComponent("UISprite")
            menpaiIcon.spriteName = GUIUtils.GetOccupationSmallIcon(members[i].menpai)
            memberPanel:FindDirect("Label_Lv01_" .. uiIdx):GetComponent("UILabel").text = members[i].level .. textRes.Team[2]
            local awayFlag = memberPanel:FindDirect("Img_LeaveBg01_" .. uiIdx)
            local offlineFlag = memberPanel:FindDirect("Img_OffLineBg01_" .. uiIdx)
            offlineFlag:SetActive(false)
            awayFlag:SetActive(false)
            _G.SetAvatarIcon(memberPanel:FindDirect("Img_Head01_" .. uiIdx), members[i].avatarId)
            _G.SetAvatarFrameIcon(memberPanel:FindDirect("Img_AvatarFrame_" .. uiIdx), members[i].avatarFrameid)
            local genderIcon = memberPanel:FindDirect("Img_Sex01_" .. uiIdx)
            GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(members[i].gender))
            local itemWidget = memberPanel:GetComponent("UIWidget")
            itemHeight = itemHeight + itemWidget.height
            GUIUtils.SetActive(memberPanel:FindDirect("Img_Inroom_" .. uiIdx), self:IsInVoipRoom(members[i].roleid))
            self.members[uiIdx] = members[i]
            if teamPlatformMgr.isTeamMatching == true and uiIdx == 1 and #members < 5 then
              memberPanel:FindDirect("Img_PiPei_" .. uiIdx):SetActive(true)
            else
              memberPanel:FindDirect("Img_PiPei_" .. uiIdx):SetActive(false)
            end
            uiIdx = uiIdx + 1
            break
          end
        end
      end
    end
  end
  for i = 1, #members do
    if members[i].status == TeamMemberStatus.ST_TMP_LEAVE then
      local memberPanel = panel:FindDirect("Img_TeamMember01_" .. uiIdx)
      if memberPanel ~= nil then
        memberPanel:FindDirect("Img_PiPei_" .. uiIdx):SetActive(false)
        memberPanel:FindDirect("Label_Name01_" .. uiIdx):GetComponent("UILabel").text = members[i].name
        local menpaiIcon = memberPanel:FindDirect("Img_School01_" .. uiIdx):GetComponent("UISprite")
        menpaiIcon.spriteName = GUIUtils.GetOccupationSmallIcon(members[i].menpai)
        memberPanel:FindDirect("Label_Lv01_" .. uiIdx):GetComponent("UILabel").text = members[i].level .. textRes.Team[2]
        local awayFlag = memberPanel:FindDirect("Img_LeaveBg01_" .. uiIdx)
        local offlineFlag = memberPanel:FindDirect("Img_OffLineBg01_" .. uiIdx)
        offlineFlag:SetActive(false)
        awayFlag:SetActive(true)
        _G.SetAvatarIcon(memberPanel:FindDirect("Img_Head01_" .. uiIdx), members[i].avatarId)
        _G.SetAvatarFrameIcon(memberPanel:FindDirect("Img_AvatarFrame_" .. uiIdx), members[i].avatarFrameid)
        local genderIcon = memberPanel:FindDirect("Img_Sex01_" .. uiIdx)
        GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(members[i].gender))
        local itemWidget = memberPanel:GetComponent("UIWidget")
        itemHeight = itemHeight + itemWidget.height
        GUIUtils.SetActive(memberPanel:FindDirect("Img_Inroom_" .. uiIdx), self:IsInVoipRoom(members[i].roleid))
        self.members[uiIdx] = members[i]
      end
      uiIdx = uiIdx + 1
    end
  end
  for i = 1, #members do
    if members[i].status == TeamMemberStatus.ST_OFFLINE then
      local memberPanel = panel:FindDirect("Img_TeamMember01_" .. uiIdx)
      if memberPanel ~= nil then
        memberPanel:FindDirect("Img_PiPei_" .. uiIdx):SetActive(false)
        memberPanel:FindDirect("Label_Name01_" .. uiIdx):GetComponent("UILabel").text = members[i].name
        local menpaiIcon = memberPanel:FindDirect("Img_School01_" .. uiIdx):GetComponent("UISprite")
        menpaiIcon.spriteName = GUIUtils.GetOccupationSmallIcon(members[i].menpai)
        memberPanel:FindDirect("Label_Lv01_" .. uiIdx):GetComponent("UILabel").text = members[i].level .. textRes.Team[2]
        local awayFlag = memberPanel:FindDirect("Img_LeaveBg01_" .. uiIdx)
        local offlineFlag = memberPanel:FindDirect("Img_OffLineBg01_" .. uiIdx)
        offlineFlag:SetActive(true)
        awayFlag:SetActive(false)
        _G.SetAvatarIcon(memberPanel:FindDirect("Img_Head01_" .. uiIdx), members[i].avatarId)
        _G.SetAvatarFrameIcon(memberPanel:FindDirect("Img_AvatarFrame_" .. uiIdx), members[i].avatarFrameid)
        local genderIcon = memberPanel:FindDirect("Img_Sex01_" .. uiIdx)
        GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(members[i].gender))
        local itemWidget = memberPanel:GetComponent("UIWidget")
        itemHeight = itemHeight + itemWidget.height
        GUIUtils.SetActive(memberPanel:FindDirect("Img_Inroom_" .. uiIdx), false)
        self.members[uiIdx] = members[i]
      end
      uiIdx = uiIdx + 1
    end
  end
  local widget = teamPanel:GetComponent("UIWidget")
  widget.height = itemWidget
  local parentPanel = require("Main.MainUI.ui.MainUIPanel").Instance()
  self.m_node:FindDirect("Group_Open/Team/Img_BgNoTeam"):SetActive(false)
  parentPanel:TouchGameObject(parentPanel.m_panel, parentPanel.m_parent)
  uiList:Reposition()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if self.m_node ~= nil then
      local List_TeamList = self.m_node:FindDirect("Group_Open/Team/TeamList/List_TeamList")
      local uiList = List_TeamList:GetComponent("UIList")
      uiList:Reposition()
    end
  end)
end
def.method("boolean").ShowCreateButtons = function(self, isShow)
  if not self.m_node then
    return
  end
  if true == isShow then
    self.m_node:FindDirect("Group_Open/Team/Img_BgNoTeam"):SetActive(true)
  else
    self.m_node:FindDirect("Group_Open/Team/Img_BgNoTeam"):SetActive(false)
  end
end
def.method().HideTeamButtons = function(self)
  if not self.m_node then
    return
  end
  local teamPanel = self.m_node:FindDirect("Group_Open/Team/TeamList/")
  local btnLeave = teamPanel:FindDirect("Btn_Leave")
  local btnTempLeave = teamPanel:FindDirect("Btn_Quite")
  local btnReturn = teamPanel:FindDirect("Btn_Back")
  local btnCall = teamPanel:FindDirect("Btn_Call")
  local isShow = btnLeave.activeSelf
  btnLeave:SetActive(false)
  btnTempLeave:SetActive(false)
  btnReturn:SetActive(false)
  btnCall:SetActive(false)
end
def.method().ShowTeamButtons = function(self)
  local myid = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  local isCaptain = teamData:IsCaptain(myid)
  local member = self.members[self.m_selectedIndex]
  local selectindex = self.m_selectedIndex
  member = self.members[selectindex]
  if member ~= nil then
    if not self.m_node then
      return
    end
    local uiPanel = self.m_node:FindDirect("Group_Open/Team/TeamList/List_TeamList/Img_TeamMember01_" .. selectindex)
    local position = uiPanel:get_position()
    local sprite = uiPanel:GetComponent("UISprite")
    local screenPos = WorldPosToScreen(position.x, position.y)
    dlgTeamerOperater:ShowDlg(member.roleid, member.name, member.status, screenPos.x - sprite:get_width() - 30, screenPos.y + sprite:get_height() + 35)
  end
end
def.method().ClearAllInvitation = function(self)
  local inviters = {}
  local invitations = teamData:GetTeamInvitation()
  if invitations == nil or #invitations < 1 then
    self:showInvitation()
    return
  end
  for _, v in pairs(invitations) do
    table.insert(inviters, v.inviter)
  end
  teamData:ClearTeamInvitation()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CClearAllinviteReq").new(inviters))
  self:showInvitation()
end
local TeamCheckCrossServerAndToast = function(tip)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role:IsInState(RoleState.GANGCROSS_BATTLE) or role:IsInState(RoleState.SINGLEBATTLE) then
    return false
  end
  return _G.CheckCrossServerAndToast(tip)
end
def.override("string").OnClick = function(self, id)
  local myid = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  local isCaptain = teamData:IsCaptain(myid)
  if id == "Btn_Right" then
    self:CloseSubPanel(self.uiObjs.luaPlayTween)
  elseif id == "Btn_Left" then
    self:OpenSubPanel(self.uiObjs.luaPlayTween)
  elseif id == "Tab_Team" then
    self:ClickTeam()
  elseif id == "Tab_Task" then
    self:ClickTask()
  elseif string.find(id, "Img_TeamMember01_") == 1 then
    if TeamCheckCrossServerAndToast(textRes.Common[501]) then
      return
    end
    self.m_selectedIndex = tonumber(string.sub(id, -1, -1))
    self:ShowTeamButtons()
  elseif id == "Btn_Watch" then
    if TeamCheckCrossServerAndToast(textRes.Common[501]) then
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CObserveFightWithLeader").new())
  elseif id == "Btn_TmpLeave" then
    local member = teamData:getMember(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId())
    if member ~= nil then
      if TeamCheckCrossServerAndToast(textRes.Common[501]) then
        return
      end
      if member.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReturnTeamReq").new())
      elseif member.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CTempLeaveReq").new())
      end
    end
  elseif id == "Btn_Quite" then
    if TeamCheckCrossServerAndToast(textRes.Common[501]) then
      return
    end
    if isCaptain == true then
      local tip = textRes.Team[12]
      if teamData:isProtctedMember(self.roleId) then
        tip = textRes.Team[99]
      end
      require("GUI.CommonConfirmDlg").ShowConfirm("", string.format(tip, self.roleName), function(i, tag)
        if i == 1 then
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CFireMemberReq").new(self.roleId))
        end
      end, {id = self})
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CTempLeaveReq").new())
    end
    self:ShowTeamButtons()
  elseif id == "Btn_Team" then
    self:showTeamMenu()
  elseif id == "Btn_Leave" or id == "Btn_Quit" then
    if TeamCheckCrossServerAndToast(textRes.Common[501]) then
      return
    end
    if isCaptain == true then
      local member = self.members[self.m_selectedIndex]
      if member == nil then
        return
      end
      local tip = textRes.Team[12]
      if teamData:isProtctedMember(self.roleId) then
        tip = textRes.Team[99]
      end
      if member.status == TeamMemberStatus.ST_TMP_LEAVE then
        require("GUI.CommonConfirmDlg").ShowConfirm("", string.format(tip, self.roleName), function(i, tag)
          if i == 1 then
            gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CFireMemberReq").new(self.roleId))
          end
        end, {id = self})
      else
        if PlayerIsInFight() == true then
          Toast(textRes.Team[75])
          return
        end
        require("GUI.CommonConfirmDlg").ShowConfirm("", string.format(textRes.Team[17], self.roleName), function(i, tag)
          if i == 1 then
            gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CAppointLeaderReq").new(self.roleId))
          end
        end, {id = self})
      end
    elseif teamData:isProtctedMember(myid) then
      require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.Team[101], function(i, tag)
        if i == 1 then
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
        end
      end, {id = self})
    else
      require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.Team[1], function(i, tag)
        if i == 1 then
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
        end
      end, {id = self})
    end
  elseif id == "Btn_Search" then
    self:OnQuiklyParticipateTeamButtonClicked()
  elseif id == "Btn_Create" then
    if require("Main.Hero.HeroModule").Instance().myRole:IsInState(RoleState.FLY) then
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CCreateTeamReq").new())
  elseif id == "Btn_Back" then
    if isCaptain == true then
      local tip = textRes.Team[12]
      if teamData:isProtctedMember(self.roleId) then
        tip = textRes.Team[99]
      end
      require("GUI.CommonConfirmDlg").ShowConfirm("", string.format(tip, self.roleName), function(i, tag)
        if i == 1 then
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CFireMemberReq").new(self.roleId))
        end
      end, {id = self})
      self:Hide()
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReturnTeamReq").new())
    end
    self:ShowTeamButtons()
  elseif id == "Btn_Call" then
    if teamData:HasLeavingMember() == false then
      Toast(textRes.Team[41])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CRecallAllReq").new())
    self:ShowTeamButtons()
  elseif id == "Btn_AllClean" then
    self:ClearAllInvitation()
  elseif string.find(id, "Btn_Agree_") == 1 then
    if require("Main.Hero.HeroModule").Instance().myRole:IsInState(RoleState.FLY) then
    end
    local index = tonumber(string.sub(id, -1, -1))
    local invitations = teamData:GetTeamInvitation()
    if invitations == nil or #invitations == 0 then
      return
    end
    local invitation = invitations[index]
    if invitation == nil then
      return
    end
    local pro = require("netio.protocol.mzm.gsp.team.CInviteTeamRep")
    gmodule.network.sendProtocol(pro.new(invitation.inviter, invitation.sessionid, pro.REPLY_ACCEPT))
    table.remove(invitations, index)
    self:showInvitation()
  elseif string.find(id, "Img_InviteMember01_") == 1 then
    local index = tonumber(string.sub(id, -1, -1))
    local inviter = teamData:GetTeamInvitation()[index]
    if inviter then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CCheckTeamInfo").new(inviter.inviter))
    end
  elseif id == "Btn_WaitingCancel" then
    TeamPlatformMgr.Instance():CancelMatch()
  elseif id == "Btn_EnterRoom" then
    ECApollo.ApolloJoinVoipRoomReq({voip_room_type = 1})
  elseif id == "Btn_OpenSound" then
    Toast(textRes.Chat.VoipRoom[4])
    ECApollo.CloseSpeaker()
    ECApollo.SetCurrentSpeakerState(false)
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_VOCIE_SPEAKER_STATE, nil)
    ECApollo.CloseMic()
    ECApollo.SetCurrentMicState(false)
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_VOCIE_MIC_STATE, nil)
  elseif id == "Btn_CloseSound" then
    Toast(textRes.Chat.VoipRoom[3])
    ECApollo.OpenSpeaker()
    ECApollo.SetCurrentSpeakerState(true)
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_VOCIE_SPEAKER_STATE, nil)
  elseif id == "Btn_OpenMic" then
    Toast(textRes.Chat.VoipRoom[2])
    ECApollo.CloseMic()
    ECApollo.SetCurrentMicState(false)
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_VOCIE_MIC_STATE, nil)
  elseif id == "Btn_CloseMic" then
    Toast(textRes.Chat.VoipRoom[1])
    ECApollo.OpenMic()
    ECApollo.DestroyVoipGuidPanel()
    ECApollo.SetCurrentMicState(true)
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_VOCIE_MIC_STATE, nil)
    ECApollo.OpenSpeaker()
    ECApollo.SetCurrentSpeakerState(true)
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_VOCIE_SPEAKER_STATE, nil)
  elseif id == "Btn_ARide" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.mounts.CRideMultiRoleMounts").new())
    local a_ride = instance.uiObjs.Group_Ride:FindDirect("Btn_ARide")
    GUIUtils.SetLightEffect(a_ride, GUIUtils.Light.None)
  elseif id == "Btn_DRide" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.mounts.CUnrideMultiRoleMounts").new())
  end
end
def.method().ClickTeam = function(self)
  if not self.m_node then
    return
  end
  local Img_BgTeamSelet = self.m_node:FindDirect("Group_Open/Tab_Team/Img_BgTeamSelet")
  local TeamSeleted = Img_BgTeamSelet:get_activeSelf()
  if teamData:HasTeam() == false then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TEAM_CLICK, nil)
    self:ToggleTeam(true)
  elseif teamData:HasTeam() == true and teamData:MeIsCaptain() and #teamData:GetAllApplicants() > 0 then
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TEAM_CLICK, nil)
    self:ToggleTeam(true)
  elseif TeamSeleted == false then
    self:ToggleTeam(true)
  else
    Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TEAM_CLICK, nil)
  end
end
def.method().ClickTask = function(self)
  require("ProxySDK.ECApollo").DestroyVoipGuidPanel()
  local canNotToggleOn = not self:CanToggleOn(Tab.Task)
  if canNotToggleOn then
    Toast(textRes.MainUI[2])
    return
  end
  local Img_BgTaskSelet = self.m_node:FindDirect("Group_Open/Tab_Task/Img_BgTaskSelet")
  local TaskSeleted = Img_BgTaskSelet:get_activeSelf()
  if TaskSeleted == false then
    self:ToggleTask(true)
  else
    require("Main.task.ui.TaskMain").Instance():ShowDlg()
  end
end
local closeTimer = 0
local openTimer = 0
def.method("boolean").CloseSubPanel = function(self, isAuto)
  if not _G.PlayerIsInFight() then
    self.attemptOpen = false
  end
  if self.m_node == nil or self.m_node.activeInHierarchy == false then
    return
  end
  local uiTweener = self.m_node:FindDirect("Group_Open"):GetComponent("UITweener")
  if isAuto and (uiTweener.amountPerDelta < 0 or uiTweener.tweenFactor == 0) then
    local playTweens = self.uiObjs.Btn_Right:GetComponents("UIPlayTween")
    for i, v in ipairs(playTweens) do
      if v.enabled then
        v:Play(true)
      end
    end
    uiTweener:PlayForward()
    if openTimer ~= 0 then
      GameUtil.RemoveGlobalTimer(openTimer)
      openTimer = 0
    end
    closeTimer = GameUtil.AddGlobalTimer(uiTweener.duration, true, function()
      closeTimer = 0
      if self.m_node == nil or self.m_node.isnil then
        return
      end
      local uiTweener = self.m_node:FindDirect("Group_Close"):GetComponent("UITweener")
      uiTweener:PlayForward()
    end)
  end
  self.isOpen = false
  self.m_node:FindDirect("UI_Panel_Main_ZuDuiShenQing"):SetActive(false)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.CLOSE_SUB_PANEL, nil)
end
def.method("boolean").OpenSubPanel = function(self, isAuto)
  if not _G.PlayerIsInFight() then
    self.attemptOpen = true
  end
  if self.m_node == nil or self.m_node.activeInHierarchy == false then
    return
  end
  local uiTweener = self.m_node:FindDirect("Group_Close"):GetComponent("UITweener")
  if isAuto and (uiTweener.amountPerDelta > 0 or uiTweener.tweenFactor == 1) then
    local playTweens = self.uiObjs.Btn_Left:GetComponents("UIPlayTween")
    for i, v in ipairs(playTweens) do
      if v.enabled then
        v:Play(true)
      end
    end
    uiTweener:PlayReverse()
    if closeTimer ~= 0 then
      GameUtil.RemoveGlobalTimer(closeTimer)
      closeTimer = 0
    end
    openTimer = GameUtil.AddGlobalTimer(uiTweener.duration, true, function()
      openTimer = 0
      if self.m_node == nil or self.m_node.isnil then
        return
      end
      local uiTweener = self.m_node:FindDirect("Group_Open"):GetComponent("UITweener")
      uiTweener:PlayReverse()
    end)
  end
  self:HideTeamButtons()
  self.isOpen = true
  self.m_node:FindDirect("UI_Panel_Main_ZuDuiShenQing"):SetActive(false)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.OPEN_SUB_PANEL, nil)
  MainUIRightSubPanel.OnUpdateTeam(nil, nil)
end
def.method().OnQuiklyParticipateTeamButtonClicked = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_TEAM_PLATFORM_CLICK, nil)
end
def.static("table", "table").OnSyncMatchState = function(params)
  if instance.m_node == nil then
    return
  end
  MainUIRightSubPanel.onShowTeamTab(nil, nil)
  instance:ShowTeam()
  if not instance:NeedShowMatchingInfo() then
    instance:StopMatchingTimer()
  end
end
def.static("table", "table").OnFeatureOpenChange = function(params)
  if params.feature == Feature.TYPE_TEAM_VOIP_ROOM then
    GUIUtils.SetActive(instance.uiObjs.Team_Apollo, teamData:HasTeam() and params.open and ECApollo.IsNewPackageEX())
    if not params.open then
      local ECApollo = require("ProxySDK.ECApollo")
      ECApollo.Instance().m_VoipStatus = ECApollo.STATUS.NORMAL
      ECApollo.CloseSpeaker()
      ECApollo.QuitRoom(true)
    end
  end
end
def.static("table", "table").onMoveInTeamFollow = function(params)
  if instance.guide ~= nil then
    instance.guide:HideDlg()
    instance.guide = nil
  end
  instance:showTeamMenuEffect(true)
  if require("Main.Hero.Interface").GetBasicHeroProp().level < 50 then
    local CommonGuideTip = require("GUI.CommonGuideTip")
    local btn = instance.uiObjs.Group_TeamBtn:FindDirect("Btn_Team")
    instance.guide = require("GUI.CommonGuideTip").ShowGuideTip(textRes.Team[104], btn, 1)
    GameUtil.AddGlobalTimer(3, true, function()
      if instance.guide ~= nil then
        instance.guide:HideDlg()
        instance.guide = nil
      end
    end)
  end
end
def.static("table", "table").OnEnterDungeon = function(params)
  if instance.m_node == nil then
    return
  end
  instance:ToggleOnTask()
  instance:ShowTask()
end
def.method("=>", "boolean").NeedShowMatchingInfo = function(self)
  if TeamPlatformMgr.Instance().isMatching == false then
    return false
  end
  if teamData:HasTeam() then
    return false
  end
  return true
end
def.method().ShowMatchingInfo = function(self)
  self.uiObjs.Img_BgWaiting:SetActive(true)
  self.uiObjs.Img_BgNoTeam:SetActive(false)
  self.uiObjs.TeamList:SetActive(false)
  self.uiObjs.Group_Invite:SetActive(false)
  self.uiObjs.LabelClock = self.uiObjs.Img_BgWaiting:FindDirect("Img_BgSlider/Label"):GetComponent("UILabel")
  self:UpdateMatchingTime()
  if self.matchTimerId == 0 then
    self.matchTimerId = GameUtil.AddGlobalTimer(1, false, function()
      self:UpdateMatchingTime()
    end)
  end
end
def.method().UpdateMatchingTime = function(self)
  if self.uiObjs == nil then
    self:StopMatchingTimer()
    return
  end
  local curTime = _G.GetServerTime()
  local duration = curTime - TeamPlatformMgr.Instance().matchStartTime
  local time = _G.Seconds2HMSTime(duration)
  self.uiObjs.LabelClock.text = string.format(textRes.TeamPlatform[15], time.h, time.m, time.s)
end
def.method().StopMatchingTimer = function(self)
  GameUtil.RemoveGlobalTimer(self.matchTimerId)
  self.matchTimerId = 0
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  if _G.leaveWorldReason ~= _G.LeaveWorldReason.RECONNECT then
    instance.attemptOpen = true
  end
end
def.method("userdata", "=>", "boolean").IsInVoipRoom = function(self, roleid)
  local ECApollo = require("ProxySDK.ECApollo")
  local onlineMemberList = ECApollo.Instance().m_VoipRoomInfo.onlineMemberList
  if not onlineMemberList then
    return false
  end
  for _, v in pairs(onlineMemberList) do
    if v:eq(roleid) then
      return true
    end
  end
  return false
end
MainUIRightSubPanel.Commit()
return MainUIRightSubPanel
