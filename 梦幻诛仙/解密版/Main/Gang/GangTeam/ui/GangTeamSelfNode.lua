local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local GangTeamSelfNode = Lplus.Extend(TabNode, CUR_CLASS_NAME)
local Cls = GangTeamSelfNode
local instance
local def = GangTeamSelfNode.define
local GangTeamMgr = require("Main.Gang.GangTeamMgr")
local GangModule = require("Main.Gang.GangModule")
local TeamData = require("Main.Team.TeamData")
local GUIUtils = require("GUI.GUIUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.Gang.GangTeam
def.field("number").nodeId = 0
def.field("table")._uiGOs = nil
def.field("table")._uiStatus = nil
def.static("=>", GangTeamSelfNode).Instance = function()
  if instance == nil then
    instance = GangTeamSelfNode()
  end
  return instance
end
def.method().eventsRegister = function(self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamNameChg, Cls.OnGangTeamNameChg, self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.TeamMemberChg, Cls.OnGangTeamMemberChg, self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.NewTeamCreated, Cls.OnNewGangTeamBurn, self)
  Event.RegisterEventWithContext(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, Cls.OnCreateTeam, self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.ApplicantsListChg, Cls.OnApplicantsChg, self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamLeaderChg, Cls.OnGangTeamMemberChg, self)
  Event.RegisterEventWithContext(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BanggongChanged, Cls.OnOnBangGongChg, self)
end
def.method().eventsUnregister = function(self)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamNameChg, Cls.OnGangTeamNameChg)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.TeamMemberChg, Cls.OnGangTeamMemberChg)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.NewTeamCreated, Cls.OnNewGangTeamBurn)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_CREATE_TEAM, Cls.OnCreateTeam)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.ApplicantsListChg, Cls.OnApplicantsChg)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.GangTeamLeaderChg, Cls.OnGangTeamMemberChg)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BanggongChanged, Cls.OnOnBangGongChg)
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
end
def.override().OnShow = function(self)
  self._uiStatus = {}
  self._uiStatus.selIdx = 1
  self._uiStatus.totalPower = 0
  self._uiStatus.totalBangGong = 0
  self._uiStatus.totalGongxun = 0
  self._uiGOs = {}
  self:eventsRegister()
  self:InitUI()
end
def.override().OnHide = function(self)
  self:eventsUnregister()
  self._uiGOs = nil
  self._uiStatus = nil
end
def.method().InitUI = function(self)
  local uiGOs = self._uiGOs
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  uiGOs.groupNoTeam = self.m_base.m_panel:FindDirect("Img_Bg0/Group_NoData")
  uiGOs.groupTitle = self.m_node:FindDirect("Group_Title")
  uiGOs.groupList = self.m_node:FindDirect("Group_List")
  uiGOs.groupBtn = self.m_node:FindDirect("Group_Button")
  uiGOs.groupInfo = self.m_node:FindDirect("Group_Info")
  uiGOs.imgBg = self.m_node:FindDirect("Img_Bg1")
  local btnList = self._uiGOs.groupNoTeam:FindDirect("Btn_List")
  btnList:SetActive(true)
  local lblNoTeamContent = self._uiGOs.groupNoTeam:FindDirect("Img_Talk/Label")
  GUIUtils.SetText(lblNoTeamContent, txtConst[79])
  self:_updateUIMyteam(myTeam)
  self:_updateRedPt()
end
def.method("table")._updateUIMyteam = function(self, myTeam)
  self._uiGOs.groupNoTeam:SetActive(myTeam == nil)
  local bShowGroup = myTeam ~= nil
  local uiGOs = self._uiGOs
  uiGOs.groupTitle:SetActive(bShowGroup)
  uiGOs.groupList:SetActive(bShowGroup)
  uiGOs.groupBtn:SetActive(bShowGroup)
  uiGOs.groupInfo:SetActive(bShowGroup)
  uiGOs.imgBg:SetActive(bShowGroup)
  local btnEdit = uiGOs.groupTitle:FindDirect("Btn_Edit")
  if myTeam ~= nil then
    local myGangTeam = GangTeamMgr.GetData():GetMyTeam()
    self:_updateGongTeamName(myGangTeam)
    self:_updateTeamMemberInfo(myGangTeam)
    btnEdit:SetActive(GangTeamMgr.GetData():MeIsCaptain())
    local btnApplyList = self._uiGOs.groupBtn:FindDirect("Btn_Applylist")
    btnApplyList:SetActive(GangTeamMgr.GetData():MeIsCaptain())
  end
  self:_updateRedPt()
end
def.method("table")._updateGongTeamName = function(self, myGangTeam)
  local lblTeamName = self.m_node:FindDirect("Group_Title/Img_BgTitle/Label_Title")
  GUIUtils.SetText(lblTeamName, myGangTeam.name)
end
def.method("table")._updateTeamBasicInfo = function(self, memGangInfo)
  local lblTotalFight = self.m_node:FindDirect("Group_Info/Group_Fight/Label_Num")
  GUIUtils.SetText(lblTotalFight, memGangInfo.totalPower)
  local lblGangDonation = self.m_node:FindDirect("Group_Info/Group_Devote/Label_Num")
  local lblBangGongName = self.m_node:FindDirect("Group_Info/Group_Devote/Label_Name")
  GUIUtils.SetText(lblBangGongName, txtConst[78])
  GUIUtils.SetText(lblGangDonation, memGangInfo.totalBangGong)
  local lblGongXu = self.m_node:FindDirect("Group_Info/Group_Achievement/Label_Num")
  local lblName = self.m_node:FindDirect("Group_Info/Group_Achievement/Label_Name")
  GUIUtils.SetText(lblName, txtConst[75])
  GUIUtils.SetText(lblGongXu, memGangInfo.totalGongxun)
end
def.method("table")._updateTeamMemberInfo = function(self, myGangTeam)
  local members = {}
  for i = 1, #myGangTeam.members do
    table.insert(members, myGangTeam.members[i])
  end
  local ctrlScrollView = self.m_node:FindDirect("Group_List/Scrollview")
  local ctrlUIList = ctrlScrollView:FindDirect("List")
  local ctrlTeamList = GUIUtils.InitUIList(ctrlUIList, GangTeamMgr.MAX_MEMBER_COUNT)
  local uiStatus = self._uiStatus
  uiStatus.totalPower, uiStatus.totalBangGong, uiStatus.totalGongxun = 0, 0, 0
  for i = 1, GangTeamMgr.MAX_MEMBER_COUNT do
    local memInfo = members[i]
    self:_fillMemInfo(ctrlTeamList[i], memInfo, i, memInfo and memInfo.roleid:eq(myGangTeam.leaderid) or false)
  end
  self:_updateTeamBasicInfo(self._uiStatus)
end
def.method("userdata", "table", "number", "boolean")._fillMemInfo = function(self, ctrl, teamMemInfo, idx, bIsLeader)
  local groupNone = ctrl:FindDirect("Group_None_" .. idx)
  local groupInfo = ctrl:FindDirect("Group_Player_" .. idx)
  local playInfo
  if teamMemInfo ~= nil then
    playInfo = self:GetMemGangInfoByRoleId(teamMemInfo.roleid)
  end
  groupNone:SetActive(teamMemInfo == nil or playInfo == nil)
  groupInfo:SetActive(teamMemInfo ~= nil and playInfo ~= nil)
  local uiStatus = self._uiStatus
  if teamMemInfo ~= nil and playInfo ~= nil then
    local groupHead = groupInfo:FindDirect("Group_Head_" .. idx)
    local imgFrame = groupHead:FindDirect("Img_BgIconGroup_" .. idx)
    local imgHead = imgFrame:FindDirect("Texture_IconGroup_" .. idx)
    local lblName = groupHead:FindDirect("Label_Name_" .. idx)
    local lblLv = groupHead:FindDirect("Label_Lv_" .. idx)
    local imgSex = groupHead:FindDirect("Img_Sex_" .. idx)
    local imgOccup = groupHead:FindDirect("Img_SchoolIcon_" .. idx)
    local imgLeader = groupHead:FindDirect("Img_Leader_" .. idx)
    _G.SetAvatarIcon(imgHead, playInfo.avatarId)
    _G.SetAvatarFrameIcon(imgFrame, playInfo.avatar_frame)
    GUIUtils.SetText(lblName, playInfo.name)
    GUIUtils.SetText(lblLv, txtConst[74]:format(playInfo.level))
    GUIUtils.SetSprite(imgSex, GUIUtils.GetGenderSprite(playInfo.gender))
    GUIUtils.SetSprite(imgOccup, GUIUtils.GetOccupationSmallIcon(playInfo.occupationId))
    imgLeader:SetActive(bIsLeader)
    local lblWeekDevote = groupInfo:FindDirect(("Group_WeekDevote_%d/Label_Num_%d"):format(idx, idx))
    GUIUtils.SetText(lblWeekDevote, playInfo.weekBangGong)
    uiStatus.totalBangGong = uiStatus.totalBangGong + playInfo.weekBangGong
    local lblGongXu = groupInfo:FindDirect(("Group_WeekAchievement_%d/Label_Num_%d"):format(idx, idx))
    GUIUtils.SetText(lblGongXu, playInfo.gongXun)
    uiStatus.totalGongxun = uiStatus.totalGongxun + playInfo.gongXun
    local lblPower = groupInfo:FindDirect(("Img_BgPower_%d/Label_PowerNumber_%d"):format(idx, idx))
    GUIUtils.SetText(lblPower, playInfo.fight_value)
    uiStatus.totalPower = uiStatus.totalPower + playInfo.fight_value
    local lblOnlineTime = groupInfo:FindDirect(("Group_Time_%d/Label_Time_%d"):format(idx, idx))
    if playInfo.offlineTime == -1 then
      GUIUtils.SetText(lblOnlineTime, txtConst[1])
    else
      local offtimeSec = playInfo.offlineTime
      GUIUtils.SetText(lblOnlineTime, self:_formatTime(_G.GetServerTime() - offtimeSec))
    end
  end
end
def.method("number", "=>", "string")._formatTime = function(self, time)
  if time >= 86400 then
    local day = math.floor(time / 86400)
    return day .. txtConst[5] .. txtConst[6]
  elseif time >= 3600 then
    local hour = math.floor(time / 3600)
    return hour .. txtConst[4] .. txtConst[6]
  elseif time >= 60 then
    local min = math.floor(time / 60)
    return min .. txtConst[3] .. txtConst[6]
  else
    return math.floor(time) .. txtConst[2] .. txtConst[6]
  end
end
def.method()._updateRedPt = function(self)
  local imgReddot = self.m_node:FindDirect("Group_Button/Btn_Applylist/Img_BgRed")
  local applicantList = GangTeamMgr.GetData():GetApplyList()
  local bShowRed = #applicantList > 0
  imgReddot:SetActive(bShowRed)
  local imgTabRed = self.m_base.m_panel:FindDirect("Img_Bg0/Tab_WD/Img_BgRed")
  imgTabRed:SetActive(bShowRed)
end
def.method("userdata", "=>", "table").GetMemGangInfoByRoleId = function(self, roleId)
  return GangTeamMgr.GetGangRoleInfo(roleId)
end
def.method("table", "=>", "table").GetSelectMember = function(self, team)
  if self._uiStatus.selIdx == 1 then
    return {
      roleid = team.leaderid,
      join_time = team.create_time
    }
  else
    return team.members[self._uiStatus.selIdx]
  end
end
def.override("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if "Btn_Edit" == id then
    self:OnTeamNameEditClick()
  elseif "Btn_Leave" == id then
    self:onClickLeaveTeam()
  elseif "Btn_Applylist" == id then
    self:onClickBtnApplyList()
  elseif "Btn_Invite" == id then
    self:onClickReleaseInvite()
  elseif "Btn_List" == id then
    self:OpenTeamListNode()
  elseif "Btn_Team" == id then
    self:onClickBtnEasyMakeTeam()
  elseif string.find(id, "Item_") then
    local strs = string.split(id, "_")
    local idx = tonumber(strs[2])
    self:_showMemberTips(idx)
  end
end
def.method().OpenTeamListNode = function(self)
  self.m_base:SwitchToNode(require("Main.Gang.GangTeam.ui.GangTeamPanel").NodeId.TeamList)
end
def.method().OnTeamNameEditClick = function(self)
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  require("Main.Gang.GangTeam.ui.UIEditTeamName").Instance():ShowPanel(myTeam.teamid)
end
def.method().onClickLeaveTeam = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  CommonConfirmDlg.ShowConfirm(txtConst[10], txtConst[11], function(select)
    if select == 1 then
      GangTeamMgr.GetProtocol().sendLeaveGangTeamReq()
    end
  end, nil)
end
def.method().onClickBtnApplyList = function(self)
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if myTeam and #myTeam.members >= 5 then
    Toast(txtConst[24])
    return
  end
  require("Main.Gang.GangTeam.ui.UIApplyList").Instance():ShowPanel()
end
def.method().onClickReleaseInvite = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if myTeam == nil then
    Toast(txtConst[49])
  else
    if #myTeam.members >= 5 then
      Toast(txtConst[24])
      return
    end
    local myName = _G.GetHeroProp().name
    GangTeamMgr.SendGangAnno(myName, myTeam.name, myTeam.teamid, 2)
  end
end
def.method().onClickBtnEasyMakeTeam = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local TeamData = require("Main.Team.TeamData")
  if TeamData.Instance():HasTeam() and not TeamData.Instance():MeIsCaptain() then
    Toast(txtConst[17])
  else
    local myTeam = GangTeamMgr.GetData():GetMyTeam()
    if myTeam == nil then
      return
    end
    local myRoleId = _G.GetHeroProp().id
    for i = 1, #myTeam.members do
      local memInfo = myTeam.members[i]
      if not memInfo.roleid:eq(myRoleId) then
        require("Main.Team.TeamModule").Instance():TeamInvite(memInfo.roleid)
      end
    end
  end
end
def.method("number")._showMemberTips = function(self, idx)
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  local teamMemInfo = myTeam.members[idx]
  if teamMemInfo == nil then
    require("Main.Gang.GangTeam.ui.UIGangRoleList").Instance():ShowPanel()
    return
  end
  if teamMemInfo.roleid:eq(_G.GetHeroProp().id) then
    return
  end
  local playerInfo = self:GetMemGangInfoByRoleId(teamMemInfo.roleid)
  if playerInfo == nil then
    return
  end
  local roleInfo = {}
  GangTeamMgr.formateGangMemberInfo(roleInfo, playerInfo)
  require("Main.Gang.GangTeam.TeamRoleTipsMgr").Instance():ShowTipXY(roleInfo, 154, 304, myTeam)
end
def.method("table").OnGangTeamNameChg = function(self, p)
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  warn("myTeam", myTeam)
  self:_updateGongTeamName(myTeam)
end
def.method("table").OnGangTeamMemberChg = function(self, p)
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if myTeam ~= nil then
    if myTeam.teamid:eq(p.teamId) then
      self:_updateUIMyteam(myTeam)
    end
  else
    self:_updateUIMyteam(myTeam)
  end
end
def.method("table").OnOnBangGongChg = function(self, p)
  local myTeam = GangTeamMgr.GetData():GetMyTeam()
  if myTeam == nil then
    return
  end
  for i = 1, #myTeam.members do
    if myTeam.members[i].roleid:eq(p.roleId) then
      self:_updateUIMyteam()
      return
    end
  end
end
def.method("table").OnNewGangTeamBurn = function(self, p)
end
def.method("table").OnCreateTeam = function(self, p)
end
def.method("table").OnApplicantsChg = function(self, p)
  self:_updateRedPt()
end
return GangTeamSelfNode.Commit()
