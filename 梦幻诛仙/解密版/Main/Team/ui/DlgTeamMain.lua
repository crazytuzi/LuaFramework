local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgTeamMain = Lplus.Extend(ECPanelBase, "DlgTeamMain")
local def = DlgTeamMain.define
local dlg
local teamData = require("Main.Team.TeamData").Instance()
local EC = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local TAB_ENUM = {
  TEAM = 1,
  INVITE = 2,
  APPLY = 3
}
local PubroleInterface = require("Main.Pubrole.PubroleInterface")
local ItemModule = require("Main.Item.ItemModule")
local TeamMemberStatus = require("netio.protocol.mzm.gsp.team.TeamMember")
local DyeData = require("Main.Dyeing.data.DyeData")
def.field("table").memberModels = nil
def.field("number").tab = TAB_ENUM.TEAM
def.field("number").changePos = -1
def.field("number").changeType = -1
def.field("table").listMember = nil
def.static("=>", DlgTeamMain).Instance = function()
  if dlg == nil then
    dlg = DlgTeamMain()
  end
  return dlg
end
def.override().OnCreate = function(self)
  self.memberModels = {}
  self.listMember = {}
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, DlgTeamMain.ShowApplyTab)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INVITATION, DlgTeamMain.ShowInviteTab)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_FORMATION, DlgTeamMain.UpdateFormation)
end
def.method().updateApplyList = function(self)
  if dlg.m_panel == nil then
    return
  end
  local applyTab = dlg.m_panel:FindDirect("Tab_Apply")
  if teamData:HasTeam() == false then
    applyTab:SetActive(false)
    dlg.m_panel:FindDirect("Tab_Invite"):SetActive(true)
    return
  end
  dlg.m_panel:FindDirect("Tab_Invite"):SetActive(false)
  dlg.m_panel:FindDirect("Group_List/Group_Empty"):SetActive(true)
  local applicants = teamData:GetAllApplicants()
  if applicants ~= nil and #applicants > 0 then
    dlg:ShowApplicationList()
  else
    dlg:ShowEmptyApplicants(textRes.Team[38])
  end
end
def.method().updateInviteList = function(self)
  if dlg.m_panel == nil then
    return
  end
  local inviteTab = dlg.m_panel:FindDirect("Tab_Invite")
  if teamData:HasTeam() == true then
    inviteTab:SetActive(false)
    dlg.m_panel:FindDirect("Tab_Apply"):SetActive(true)
    return
  end
  inviteTab:SetActive(true)
  dlg.m_panel:FindDirect("Tab_Apply"):SetActive(false)
  local invitations = teamData:GetTeamInvitation()
  if #invitations > 0 then
    dlg:ShowInvitationList()
  else
    dlg:ShowEmptyApplicants(textRes.Team[39])
  end
end
def.method().updateTeamPlatform = function(self)
  local teamPlatformMgr = require("Main.TeamPlatform.TeamPlatformMgr").Instance()
  local matchViewData = teamPlatformMgr:GetLastMatchViewData()
  local Group_PiPei = self.m_panel:FindDirect("Group_Team/Group_Top/Group_PiPei")
  local visible = teamData:HasTeam() and true or false
  GUIUtils.SetActive(Group_PiPei:FindDirect("Group_HanHua"), visible)
  if matchViewData == nil then
    self.m_panel:FindDirect("Group_Team/Group_Top/Group_PiPei/Label_Name"):GetComponent("UILabel").text = textRes.Team[58]
    self.m_panel:FindDirect("Group_Team/Group_Top/Group_PiPei/Label_Lv"):GetComponent("UILabel").text = textRes.Team[58]
    return
  end
  for i, option in pairs(matchViewData.matchOptions) do
    self.m_panel:FindDirect("Group_Team/Group_Top/Group_PiPei/Label_Name"):GetComponent("UILabel").text = option.name
    self.m_panel:FindDirect("Group_Team/Group_Top/Group_PiPei/Label_Lv"):GetComponent("UILabel").text = matchViewData.levelBound.floor .. "~" .. matchViewData.levelBound.ceil
    break
  end
  if teamPlatformMgr.isMatching == true then
    self.m_panel:FindDirect("Group_Team/Group_Top/Group_PiPei/Btn_PiPei/Label_PiPei"):GetComponent("UILabel").text = textRes.Team[59]
  else
    self.m_panel:FindDirect("Group_Team/Group_Top/Group_PiPei/Btn_PiPei/Label_PiPei"):GetComponent("UILabel").text = textRes.Team[60]
  end
end
def.method().updateUI = function(self)
  if self:IsShow() == false then
    return
  end
  self:updateTeamPlatform()
  self:ShowButtons()
  local bHasTeam = teamData:HasTeam()
  if true == bHasTeam then
    self.m_panel:FindDirect("Tab_Invite"):SetActive(false)
    self.m_panel:FindDirect("Tab_Apply"):SetActive(true)
  else
    self.m_panel:FindDirect("Tab_Invite"):SetActive(true)
    self.m_panel:FindDirect("Tab_Apply"):SetActive(false)
    if dlg.tab == TAB_ENUM.APPLY then
      dlg.tab = TAB_ENUM.TEAM
    end
  end
  if dlg.tab == TAB_ENUM.TEAM then
    self:updateTeamPosition()
    self:setFormationInfo()
  elseif dlg.tab == TAB_ENUM.INVITE then
    self:updateInviteList()
  elseif dlg.tab == TAB_ENUM.APPLY then
    self:updateApplyList()
  end
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_TEAM_MAIN_UI_RES, 1)
  self:SetModal(true)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, DlgTeamMain.ShowApplyTab)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INVITATION, DlgTeamMain.ShowInviteTab)
  if self.memberModels then
    for k, member in pairs(self.memberModels) do
      if member.model then
        member.model:Destroy()
        member.model = nil
      end
    end
    self.memberModels = nil
  end
end
def.method("number", "number").setSelectedItem = function(self, index, changetype)
  local teamModelPanel = self.m_panel:FindDirect("Group_Team/Group_Model")
  local modelPanel = teamModelPanel:FindDirect("Group_" .. index)
  modelPanel:FindDirect("Img_Select"):SetActive(true)
  self.changePos = index
  self.changeType = changetype
  local position = teamData:getTeamPosition()
  for i = 2, 5 do
    if i ~= index then
      if teamData:HasTeam() == false then
        if self.memberModels[i] ~= nil and self.memberModels[i].model ~= nil then
          teamModelPanel:FindDirect("Group_" .. i .. "/Img_Select"):SetActive(false)
          teamModelPanel:FindDirect("Group_" .. i .. "/Img_Gray"):SetActive(true)
        end
      elseif position[i] ~= nil and position[i].dispositionMemberType == changetype then
        teamModelPanel:FindDirect("Group_" .. i .. "/Img_Select"):SetActive(false)
        teamModelPanel:FindDirect("Group_" .. i .. "/Img_Gray"):SetActive(true)
      end
    end
  end
end
def.method("number").SelectTeamItem = function(self, index)
  if teamData:HasTeam() == false then
    if index == 1 then
      return
    elseif self.memberModels[index] == nil or self.memberModels[index].model == nil then
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_OPEN_MY_PARTNER, nil)
    else
      self:setSelectedItem(index, require("netio.protocol.mzm.gsp.team.TeamDispositionMemberInfo").DT_PARTNER)
    end
  elseif teamData:IsCaptain(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) == true then
    if index == 1 then
      return
    else
      local positions = teamData:getTeamPosition()
      if self.memberModels[index] == nil or self.memberModels[index].model == nil then
        Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_OPEN_MY_PARTNER, nil)
      else
        local member = self.listMember[index]
        if member ~= nil and member.roleid:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) == false and member.status == TeamMemberStatus.ST_NORMAL then
          require("Main.Team.ui.DlgCmdButtons").Instance():ShowDlg(member.roleid, member.name, member.menpai, member.gender, member.level, member.status, member.avatarId, member.avatarFrameid, index)
        end
      end
    end
  else
    local member = self.listMember[index]
    if member == nil or member.roleid == gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId() then
      return
    end
    require("Main.Team.ui.DlgCmdButtons").Instance():ShowDlg(member.roleid, member.name, member.menpai, member.gender, member.level, member.status, member.avatarId, member.avatarFrameid, index)
  end
end
def.method().cancelAllSelectItem = function(self)
  local teamModelPanel = self.m_panel:FindDirect("Group_Team/Group_Model")
  for i = 1, 5 do
    teamModelPanel:FindDirect("Group_" .. i .. "/Img_Select"):SetActive(false)
    teamModelPanel:FindDirect("Group_" .. i .. "/Img_Gray"):SetActive(false)
  end
  self.changePos = -1
end
def.method("number").ChangeTeamItem = function(self, index)
  local teamModelPanel = self.m_panel:FindDirect("Group_Team/Group_Model")
  local modelPanel = teamModelPanel:FindDirect("Group_" .. index)
  if index == 1 then
    local tip = textRes.Team[46]
    Toast(tip)
    return
  end
  if index == self.changePos then
    self:cancelAllSelectItem()
    self.changePos = -1
    local tip = textRes.Team[70]
    Toast(tip)
    return
  end
  if teamData:HasTeam() == false then
    if self.memberModels[index] ~= nil then
      local PartnerInterface = require("Main.partner.PartnerInterface")
      local partnerInterface = PartnerInterface.Instance()
      local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
      local t_Req = require("netio.protocol.mzm.gsp.partner.CChangeZhanWeiReq").new(defaultLineUpNum, self.changePos - 1, index - 1)
      gmodule.network.sendProtocol(t_Req)
    end
  else
    local positions = teamData:getTeamPosition()
    if self.memberModels[index] == nil then
      self:cancelAllSelectItem()
      self.changePos = -1
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_OPEN_MY_PARTNER, nil)
    elseif positions[index] ~= nil then
      local member = teamData:GetTeamMember(positions[index].teamDispositionMember_id)
      if member ~= nil and member.status == TeamMemberStatus.ST_NORMAL then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CAdjustDisposition").new(self.changePos, index))
      end
    end
  end
  self:cancelAllSelectItem()
  self.changePos = -1
end
def.method("number").ClickTeamItem = function(self, index)
  if teamData:HasTeam() == true then
    local posInfo = teamData:getTeamPosition()
    if posInfo[index] == nil then
      if teamData:MeIsCaptain() == true then
        Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_OPEN_MY_PARTNER, nil)
      end
    elseif self.changePos == -1 then
      self:SelectTeamItem(index)
    else
      self:ChangeTeamItem(index)
    end
  elseif self.changePos == -1 then
    self:SelectTeamItem(index)
  else
    self:ChangeTeamItem(index)
  end
end
def.method("number").ClickHead = function(self, index)
  if teamData:HasTeam() == false then
    return
  end
  local members = teamData:GetAllTeamMembers()
  local member = self.listMember[index]
  if member ~= nil and member.roleid ~= gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId() then
    require("Main.Team.ui.DlgCmdButtons").Instance():ShowDlg(member.roleid, member.name, member.menpai, member.gender, member.level, member.status, member.avatarId, member.avatarFrameid, index)
  end
end
def.method().ClickSetting = function(self, index)
  require("Main.SystemSetting.ui.SystemSettingPanel").Instance():ShowPanelToSelection("SettingClass2", "Toggle_TeamInvite")
end
def.method("string").onClick = function(self, id)
  local bChangeModelPos = false
  if id == "Img_Bg1_1" then
    self:ClickTeamItem(1)
    return
  elseif id == "Img_Bg1_2" then
    self:ClickTeamItem(2)
    return
  elseif id == "Img_Bg1_3" then
    self:ClickTeamItem(3)
    return
  elseif id == "Img_Bg1_4" then
    self:ClickTeamItem(4)
    return
  elseif id == "Img_Bg1_5" then
    self:ClickTeamItem(5)
    return
  end
  if id == "Btn_Quit" then
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    local tip = textRes.Team[1]
    if teamData:MeIsCaptain() then
      if teamData:hasProtectedMember() then
        tip = textRes.Team[100]
      end
    elseif teamData:isProtctedMember(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) then
      tip = textRes.Team[101]
    end
    require("GUI.CommonConfirmDlg").ShowConfirm("", tip, function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
      end
    end, {id = self})
  elseif id == "Btn_ZhenFa" then
    if teamData:HasTeam() then
      gmodule.moduleMgr:GetModule(ModuleId.FORMATION):ShowFormationDlg(teamData.formationId, teamData.formationId, DlgTeamMain.OnFormationChanged)
    else
      local formationId = -1
      local partnerInterface = require("Main.partner.PartnerInterface").Instance()
      local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
      local LineUp = partnerInterface:GetLineup(defaultLineUpNum)
      if LineUp ~= nil then
        formationId = LineUp.zhenFaId
      end
      gmodule.moduleMgr:GetModule(ModuleId.FORMATION):ShowFormationDlg(formationId, formationId, DlgTeamMain.OnFormationChanged)
    end
  elseif id == "Btn_Invite" then
    require("Main.Team.ui.DlgTeamInvite").Instance():ShowDlg()
  elseif id == "Btn_Creat" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CCreateTeamReq").new())
  elseif id == "Btn_Partner" then
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_OPEN_MY_PARTNER, nil)
  elseif id == "Btn_Change" then
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.OPEN_TEAM_PLATFORM_PANEL_REQ, nil)
  elseif id == "Btn_PiPei" then
    if teamData:HasTeam() and 5 <= #teamData:GetAllTeamMembers() then
      Toast(textRes.Team[105])
    end
    local teamPlatformMgr = require("Main.TeamPlatform.TeamPlatformMgr").Instance()
    local matchViewData = teamPlatformMgr:GetLastMatchViewData()
    if matchViewData == nil then
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.OPEN_TEAM_PLATFORM_PANEL_REQ, nil)
      if teamData:MeIsCaptain() then
        Toast(textRes.Team[51])
      end
      return
    end
    if teamPlatformMgr.isMatching == false then
      teamPlatformMgr:ReMatch()
    else
      teamPlatformMgr:CancelMatch()
    end
  elseif id == "Btn_HanHua" then
    local TeamPlatformMgr = require("Main.TeamPlatform.TeamPlatformMgr")
    local ret = TeamPlatformMgr.Instance():ShoutToWorld()
    if ret == TeamPlatformMgr.CResult.HAVE_NOT_MATCH then
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.OPEN_TEAM_PLATFORM_PANEL_REQ, nil)
    end
  elseif id == "Btn_Clear" then
    if dlg.tab == TAB_ENUM.INVITE then
      teamData:ClearTeamInvitation()
      self:ShowInvitationList()
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CClearAllinviteReq").new(inviters))
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.NEW_TEAM_INVITATION, nil)
    elseif dlg.tab == TAB_ENUM.APPLY then
      teamData:ClearApplicants()
      self:updateApplyList()
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CClearAllApplicantsReq").new())
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, nil)
    end
  elseif id == "Btn_GuiDui" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReturnTeamReq").new())
  elseif id == "Btn_ZanLi" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CTempLeaveReq").new())
  elseif id == "Btn_ZhaoHui" then
    if teamData:HasLeavingMember() == false then
      Toast(textRes.Team[41])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CRecallAllReq").new())
  elseif id == "Tab_Apply" then
    self.tab = TAB_ENUM.APPLY
    self.m_panel:FindDirect("Group_List"):SetActive(true)
    if teamData:HasTeam() then
      self:updateApplyList()
      teamData.hasNewApplicant = false
    end
    self:ShowButtons()
  elseif id == "Tab_Invite" then
    self.tab = TAB_ENUM.INVITE
    self.m_panel:FindDirect("Group_List"):SetActive(true)
    self:updateInviteList()
    self:ShowButtons()
  elseif id == "Tab_Team" then
    self.tab = TAB_ENUM.TEAM
    self.m_panel:FindDirect("Group_List"):SetActive(false)
    self:updateTeamPosition()
    self:ShowButtons()
  elseif string.find(id, "Img_BgTeamApply_") == 1 then
    local index = tonumber(string.sub(id, 17))
    local inviter = teamData:GetTeamInvitation()[index]
    if inviter then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CCheckTeamInfo").new(inviter.inviter))
    end
  elseif string.find(id, "Btn_ApplyConfuse_") == 1 then
    local index = tonumber(string.sub(id, 18))
    if teamData:HasTeam() then
      local applicants = teamData:GetAllApplicants()
      if index <= #applicants then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CApplyTeamRep").new(applicants[index].roleId, require("netio.protocol.mzm.gsp.team.CApplyTeamRep").REPLY_REFUSE))
        teamData:RemoveApplicant(index)
        Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, nil)
        self:updateApplyList()
      end
    else
      local invitations = teamData:GetTeamInvitation()
      if invitations == nil or #invitations == 0 then
        return
      end
      local invitation = invitations[index]
      if invitation == nil then
        return
      end
      local pro = require("netio.protocol.mzm.gsp.team.CInviteTeamRep")
      gmodule.network.sendProtocol(pro.new(invitation.inviter, invitation.sessionid, pro.REPLY_REFUSE))
      table.remove(invitations, index)
      self:ShowInvitationList()
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.NEW_TEAM_INVITATION, nil)
    end
  elseif string.find(id, "Btn_Agree_") == 1 then
    local index = tonumber(string.sub(id, 11))
    if teamData:HasTeam() then
      if #teamData:GetAllTeamMembers() == 5 then
        local tip = textRes.Team[89]
        Toast(tip)
        teamData:ClearApplicants()
        self:updateApplyList()
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CClearAllApplicantsReq").new())
        Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, nil)
      else
        local applicants = teamData:GetAllApplicants()
        if index ~= nil and index <= #applicants then
          local t_CApplyTeamRep = require("netio.protocol.mzm.gsp.team.CApplyTeamRep")
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CApplyTeamRep").new(applicants[index].roleId, t_CApplyTeamRep.REPLY_ACCEPT))
          teamData:RemoveApplicant(index)
          Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_APPLICATION, nil)
        end
        self:updateApplyList()
      end
    else
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
      self:ShowInvitationList()
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.NEW_TEAM_INVITATION, nil)
    end
  elseif id == "Btn_Close" then
    self:Hide()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif id == "Group_Head1" then
    self:ClickHead(1)
  elseif id == "Group_Head2" then
    self:ClickHead(2)
  elseif id == "Group_Head3" then
    self:ClickHead(3)
  elseif id == "Group_Head4" then
    self:ClickHead(4)
  elseif id == "Group_Head5" then
    self:ClickHead(5)
  elseif id == "Btn_Setting" then
    self:ClickSetting()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, nil)
    return
  end
  self.changePos = -1
  self:ShowButtons()
  local bHasTeam = teamData:HasTeam()
  if true == bHasTeam then
    self.m_panel:FindDirect("Tab_Invite"):SetActive(false)
    self.m_panel:FindDirect("Tab_Apply"):SetActive(true)
    if #teamData:GetAllApplicants() > 0 and teamData:MeIsCaptain() == true and teamData.hasNewApplicant == true then
      local toggle = self.m_panel:FindDirect("Tab_Apply"):GetComponent("UIToggle")
      toggle:set_value(true)
      toggle = self.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
      toggle:set_value(false)
      dlg.tab = TAB_ENUM.APPLY
      teamData.hasNewApplicant = false
    else
      local toggle = self.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
      toggle:set_value(true)
      toggle = self.m_panel:FindDirect("Tab_Apply"):GetComponent("UIToggle")
      toggle:set_value(false)
      dlg.tab = TAB_ENUM.TEAM
    end
  else
    self.m_panel:FindDirect("Tab_Invite"):SetActive(true)
    self.m_panel:FindDirect("Tab_Apply"):SetActive(false)
    if 0 < #teamData:GetTeamInvitation() then
      local toggle = self.m_panel:FindDirect("Tab_Invite"):GetComponent("UIToggle")
      toggle:set_value(true)
      toggle = self.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
      toggle:set_value(false)
      dlg.tab = TAB_ENUM.INVITE
    else
      local toggle = self.m_panel:FindDirect("Tab_Invite"):GetComponent("UIToggle")
      toggle:set_value(false)
      toggle = self.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
      toggle:set_value(true)
      dlg.tab = TAB_ENUM.TEAM
    end
  end
  self:updateUI()
end
def.static("number").OnFormationChanged = function(formationId)
  if formationId <= 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReqCloseZhenfa").new())
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReqOpenZhenfa").new(formationId))
  end
end
def.method("number").showPartnerModel = function(self, index)
  if self.memberModels == nil then
    self.memberModels = {}
  end
  local teamModelPanel = self.m_panel:FindDirect("Group_Team/Group_Model")
  local modelPanel = teamModelPanel:FindDirect("Group_" .. index)
  modelPanel:FindDirect("Img_Num"):SetActive(false)
  modelPanel:FindDirect("Img_Select"):SetActive(false)
  modelPanel:FindDirect("Img_Gray"):SetActive(false)
  modelPanel:FindDirect("Group_Model"):SetActive(true)
  modelPanel:FindDirect("Group_Add"):SetActive(false)
  modelPanel:FindDirect("Group_Head" .. index):SetActive(false)
  modelPanel:FindDirect("Group_Head" .. index .. "/Img_ZanLi"):SetActive(false)
  modelPanel:FindDirect("Group_Head" .. index .. "/Img_LiXian"):SetActive(false)
  modelPanel:FindDirect("Group_Model/Img_Leader"):SetActive(false)
  modelPanel:FindDirect("Group_Model/Img_Partner"):SetActive(false)
  modelPanel:FindDirect("Img_Num"):SetActive(true)
  local model = modelPanel:FindDirect("Group_Model/Model")
  local menpaiIcon = modelPanel:FindDirect("Group_Model/Group_Info/Img_School")
  menpaiIcon:SetActive(false)
  local genderIcon = modelPanel:FindDirect("Group_Model/Group_Info/Img_Sex")
  genderIcon:SetActive(false)
  local PartnerInterface = require("Main.partner.PartnerInterface")
  local partnerInterface = PartnerInterface.Instance()
  local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
  local lineUp = partnerInterface:GetLineup(defaultLineUpNum)
  if lineUp == nil then
    local modeldata = self.memberModels[index]
    if modeldata ~= nil and modeldata.model ~= nil then
      modeldata.model:Destroy()
    end
    modelPanel:FindDirect("Group_Add"):SetActive(true)
    return
  end
  local formationInfo
  if lineUp.zhenFaId ~= 0 then
    local level = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationLevel(lineUp.zhenFaId)
    formationInfo = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfoAtLevel(lineUp.zhenFaId, level)
  end
  if index == 1 then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    menpaiIcon:SetActive(true)
    menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(heroProp.occupation)
    genderIcon:SetActive(true)
    GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(heroProp.gender))
    modelPanel:FindDirect("Group_Model/Group_Info/Label_Name"):GetComponent("UILabel").text = heroProp.name
    modelPanel:FindDirect("Group_Model/Group_Info/Label"):SetActive(true)
    modelPanel:FindDirect("Group_Model/Group_Info/Label_Lv"):GetComponent("UILabel").text = heroProp.level
    local g1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Img_ArrowDown")
    local r1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Img_ArrowUp")
    local g2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Img_ArrowDown")
    local r2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Img_ArrowUp")
    local buff_ctrl_1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Label_Effect")
    local buff_ctrl_2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Label_Effect")
    g1:SetActive(false)
    r1:SetActive(false)
    g2:SetActive(false)
    r2:SetActive(false)
    buff_ctrl_1:SetActive(false)
    buff_ctrl_2:SetActive(false)
    if formationInfo ~= nil and formationInfo.Effect[index] ~= nil then
      local effect = formationInfo.Effect[index].EffectA
      if effect ~= nil then
        g1:SetActive(0 > effect.value)
        r1:SetActive(0 < effect.value)
        buff_ctrl_1:GetComponent("UILabel").text = effect.name
        buff_ctrl_1:SetActive(true)
      else
        buff_ctrl_1:SetActive(false)
      end
      effect = formationInfo.Effect[index].EffectB
      if effect ~= nil then
        g2:SetActive(0 > effect.value)
        r2:SetActive(0 < effect.value)
        buff_ctrl_2:SetActive(true)
        buff_ctrl_2:GetComponent("UILabel").text = effect.name
      else
        buff_ctrl_2:SetActive(false)
      end
    end
    if self.memberModels[index] == nil then
      self.memberModels[index] = {}
    elseif self.memberModels[index].model ~= nil then
      self.memberModels[index].model:Destroy()
    end
    local modelID = PubroleInterface.FindModelIDByOccupationId(heroProp.occupation, heroProp.gender)
    self.memberModels[index].model = require("Model.ECUIModel").new(modelID)
    local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
    self.memberModels[index].model:AddOnLoadCallback("DlgTeamMain", function()
      local m = self.memberModels[index].model.m_model
      if m == nil then
        return
      end
      m.parent = nil
      m.localPosition = EC.Vector3.new(-10000, -10000, 100)
      if model ~= nil and not model.isnil then
        local uimodel = model:GetComponent("UIModel")
        uimodel.modelGameObject = m
      end
    end)
    _G.LoadModel(self.memberModels[index].model, modelInfo, 0, 0, 180, false, false)
    return
  end
  local g1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Img_ArrowDown")
  local r1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Img_ArrowUp")
  local g2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Img_ArrowDown")
  local r2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Img_ArrowUp")
  local buff_ctrl_1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Label_Effect")
  local buff_ctrl_2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Label_Effect")
  g1:SetActive(false)
  r1:SetActive(false)
  g2:SetActive(false)
  r2:SetActive(false)
  buff_ctrl_1:SetActive(false)
  buff_ctrl_2:SetActive(false)
  modelPanel:FindDirect("Group_Model/Group_Info/Label_Name"):GetComponent("UILabel").text = ""
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  modelPanel:FindDirect("Group_Model/Group_Info/Label"):SetActive(false)
  modelPanel:FindDirect("Group_Model/Group_Info/Label_Lv"):GetComponent("UILabel").text = ""
  local partnerID = lineUp.positions[index - 1]
  if partnerID ~= nil and partnerID > 0 then
    local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, partnerID)
    local modelId = record:GetIntValue("modelId")
    local faction = record:GetIntValue("faction")
    local gender = record:GetIntValue("sex")
    menpaiIcon:SetActive(true)
    menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(faction)
    genderIcon:SetActive(true)
    GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(gender))
    if self.memberModels[index] == nil then
      self.memberModels[index] = {}
    elseif self.memberModels[index].model ~= nil then
      self.memberModels[index].model:Destroy()
    end
    modelPanel:FindDirect("Group_Model/Img_Partner"):SetActive(true)
    modelPanel:FindDirect("Group_Head" .. index):SetActive(false)
    local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, partnerID)
    modelPanel:FindDirect("Group_Model/Group_Info/Label_Name"):GetComponent("UILabel").text = record:GetStringValue("name")
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    modelPanel:FindDirect("Group_Model/Group_Info/Label"):SetActive(true)
    modelPanel:FindDirect("Group_Model/Group_Info/Label_Lv"):GetComponent("UILabel").text = heroProp.level
    self.memberModels[index].model = require("Model.ECUIModel").new(modelId)
    self.memberModels[index].modelPath = GetModelPath(modelId)
    self.memberModels[index].model:Load(self.memberModels[index].modelPath, function(ret)
      if self.memberModels == nil or self.memberModels[index] == nil then
        return
      end
      local m = self.memberModels[index].model.m_model
      if m == nil then
        return
      end
      m.parent = nil
      m.localPosition = EC.Vector3.new(-10000, -10000, 100)
      m:GetComponentInChildren("Animation"):Play_3("Stand_c", PlayMode.StopSameLayer)
      self.memberModels[index].model:SetDir(180)
      m:SetLayer(ClientDef_Layer.UI_Model1)
      self.memberModels[index].model:SetAlpha(0.5)
      if model ~= nil and not model.isnil then
        local uimodel = model:GetComponent("UIModel")
        uimodel.modelGameObject = m
      end
    end)
    if formationInfo ~= nil and formationInfo.Effect[index] ~= nil then
      local effect = formationInfo.Effect[index].EffectA
      if effect ~= nil then
        g1:SetActive(0 > effect.value)
        r1:SetActive(0 < effect.value)
        buff_ctrl_1:GetComponent("UILabel").text = effect.name
        buff_ctrl_1:SetActive(true)
      else
        buff_ctrl_1:SetActive(false)
      end
      effect = formationInfo.Effect[index].EffectB
      if effect ~= nil then
        g2:SetActive(0 > effect.value)
        r2:SetActive(0 < effect.value)
        buff_ctrl_2:SetActive(true)
        buff_ctrl_2:GetComponent("UILabel").text = effect.name
      else
        buff_ctrl_2:SetActive(false)
      end
    end
  else
    if self.memberModels[index] == nil then
      self.memberModels[index] = {}
    elseif self.memberModels[index].model ~= nil then
      self.memberModels[index].model:Destroy()
      self.memberModels[index].model = nil
    end
    modelPanel:FindDirect("Group_Add"):SetActive(true)
  end
end
def.method("number", "userdata").showTeamModel = function(self, pos, roleid)
  if self.memberModels == nil then
    self.memberModels = {}
  end
  local i = pos
  local members = teamData:GetAllTeamMembers()
  local formationInfo
  if teamData.formationId ~= 0 then
    formationInfo = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfoAtLevel(teamData.formationId, teamData.formationLevel)
  end
  local modelPanel = self.m_panel:FindDirect("Group_Team/Group_Model/Group_" .. i)
  modelPanel:FindDirect("Img_Num"):SetActive(false)
  modelPanel:FindDirect("Img_Select"):SetActive(false)
  modelPanel:FindDirect("Img_Gray"):SetActive(false)
  modelPanel:FindDirect("Group_Model"):SetActive(true)
  modelPanel:FindDirect("Group_Add"):SetActive(false)
  modelPanel:FindDirect("Group_Head" .. i):SetActive(false)
  modelPanel:FindDirect("Group_Head" .. i .. "/Img_ZanLi"):SetActive(false)
  modelPanel:FindDirect("Group_Head" .. i .. "/Img_LiXian"):SetActive(false)
  local teamModelPanel = self.m_panel:FindDirect("Group_Team/Group_Model")
  local modelPanel = teamModelPanel:FindDirect("Group_" .. i)
  modelPanel:FindDirect("Group_Model/Img_Leader"):SetActive(false)
  modelPanel:FindDirect("Group_Model/Img_Partner"):SetActive(false)
  modelPanel:FindDirect("Img_Num"):SetActive(true)
  local model = modelPanel:FindDirect("Group_Model/Model")
  local menpaiIcon = modelPanel:FindDirect("Group_Model/Group_Info/Img_School")
  menpaiIcon:SetActive(false)
  local genderIcon = modelPanel:FindDirect("Group_Model/Group_Info/Img_Sex")
  genderIcon:SetActive(false)
  local teamPosition = teamData:getTeamPosition()
  if teamPosition == nil then
    return
  end
  if pos > #teamPosition then
    return
  end
  local posInfo = teamPosition[pos]
  if posInfo.dispositionMemberType == require("netio.protocol.mzm.gsp.team.TeamDispositionMemberInfo").DT_PARTNER then
    menpaiIcon:SetActive(false)
    if self.memberModels[i] == nil then
      self.memberModels[i] = {}
    elseif self.memberModels[i].model ~= nil then
      self.memberModels[i].model:Destroy()
    end
    if posInfo.model.modelid == 0 then
      return
    end
    modelPanel:FindDirect("Group_Model/Img_Partner"):SetActive(true)
    modelPanel:FindDirect("Group_Head" .. i):SetActive(false)
    local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, posInfo.teamDispositionMember_id:ToNumber())
    modelPanel:FindDirect("Group_Model/Group_Info/Label_Name"):GetComponent("UILabel").text = record:GetStringValue("name")
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    modelPanel:FindDirect("Group_Model/Group_Info/Label"):SetActive(true)
    modelPanel:FindDirect("Group_Model/Group_Info/Label_Lv"):GetComponent("UILabel").text = heroProp.level
    local faction = record:GetIntValue("faction")
    menpaiIcon:SetActive(true)
    menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(faction)
    local gender = record:GetIntValue("sex")
    genderIcon:SetActive(true)
    GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(gender))
    if self.memberModels ~= nil then
      self.memberModels[i].model = require("Model.ECUIModel").new(posInfo.model.modelid)
      self.memberModels[i].modelPath = GetModelPath(posInfo.model.modelid)
      self.memberModels[i].model:Load(self.memberModels[i].modelPath, function(ret)
        if self.memberModels ~= nil and self.memberModels[i] ~= nil and self.memberModels[i].model ~= nil then
          local m = self.memberModels[i].model.m_model
          if m == nil then
            return
          end
          m.localPosition = EC.Vector3.new(-10000, -10000, 100)
          m:GetComponentInChildren("Animation"):Play_3("Stand_c", PlayMode.StopSameLayer)
          self.memberModels[i].model:SetDir(180)
          m:SetLayer(ClientDef_Layer.UI_Model1)
          self.memberModels[i].model:SetAlpha(0.5)
          if model ~= nil and not model.isnil then
            local uimodel = model:GetComponent("UIModel")
            uimodel.modelGameObject = m
          end
        end
      end)
      local g1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Img_ArrowDown")
      local r1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Img_ArrowUp")
      local g2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Img_ArrowDown")
      local r2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Img_ArrowUp")
      local buff_ctrl_1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Label_Effect")
      local buff_ctrl_2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Label_Effect")
      g1:SetActive(false)
      r1:SetActive(false)
      g2:SetActive(false)
      r2:SetActive(false)
      buff_ctrl_1:SetActive(false)
      buff_ctrl_2:SetActive(false)
      if formationInfo ~= nil and formationInfo.Effect[i] ~= nil then
        local effect = formationInfo.Effect[i].EffectA
        if effect ~= nil then
          g1:SetActive(0 > effect.value)
          r1:SetActive(0 < effect.value)
          buff_ctrl_1:GetComponent("UILabel").text = effect.name
          buff_ctrl_1:SetActive(true)
        else
          buff_ctrl_1:SetActive(false)
        end
        effect = formationInfo.Effect[i].EffectB
        if effect ~= nil then
          g2:SetActive(0 > effect.value)
          r2:SetActive(0 < effect.value)
          buff_ctrl_2:SetActive(true)
          buff_ctrl_2:GetComponent("UILabel").text = effect.name
        else
          buff_ctrl_2:SetActive(false)
        end
      end
      return
    end
  elseif posInfo.dispositionMemberType == require("netio.protocol.mzm.gsp.team.TeamDispositionMemberInfo").DT_TEAM_MEMBER then
    for j = 1, 5 do
      if members[j] ~= nil and roleid == members[j].roleid then
        self.listMember[i] = members[j]
        menpaiIcon:SetActive(true)
        menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(members[j].menpai)
        genderIcon:SetActive(true)
        GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(members[j].gender))
        modelPanel:FindDirect("Group_Model/Group_Info/Label_Name"):GetComponent("UILabel").text = members[j].name
        modelPanel:FindDirect("Group_Model/Group_Info/Label"):SetActive(true)
        modelPanel:FindDirect("Group_Model/Group_Info/Label_Lv"):GetComponent("UILabel").text = members[j].level
        _G.SetAvatarIcon(modelPanel:FindDirect("Group_Head" .. i .. "/Img_Head"), members[j].avatarId)
        if teamData:IsCaptain(roleid) == true then
          modelPanel:FindDirect("Group_Model/Img_Leader"):SetActive(true)
        end
        local g1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Img_ArrowDown")
        local r1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Img_ArrowUp")
        local g2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Img_ArrowDown")
        local r2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Img_ArrowUp")
        local buff_ctrl_1 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect1/Label_Effect")
        local buff_ctrl_2 = modelPanel:FindDirect("Group_Model/Group_Info/Group_ZhenFa/Group_Effect2/Label_Effect")
        g1:SetActive(false)
        r1:SetActive(false)
        g2:SetActive(false)
        r2:SetActive(false)
        buff_ctrl_1:SetActive(false)
        buff_ctrl_2:SetActive(false)
        if formationInfo ~= nil and formationInfo.Effect[i] ~= nil then
          local effect = formationInfo.Effect[i].EffectA
          if effect ~= nil then
            g1:SetActive(0 > effect.value)
            r1:SetActive(0 < effect.value)
            buff_ctrl_1:GetComponent("UILabel").text = effect.name
            buff_ctrl_1:SetActive(true)
          else
            buff_ctrl_1:SetActive(false)
          end
          effect = formationInfo.Effect[i].EffectB
          if effect ~= nil then
            g2:SetActive(0 > effect.value)
            r2:SetActive(0 < effect.value)
            buff_ctrl_2:SetActive(true)
            buff_ctrl_2:GetComponent("UILabel").text = effect.name
          else
            buff_ctrl_2:SetActive(false)
          end
        end
        if self.memberModels[i] == nil then
          self.memberModels[i] = {}
        elseif self.memberModels[i].model ~= nil then
          self.memberModels[i].model:Destroy()
        end
        if self.memberModels ~= nil then
          self.memberModels[i].model = require("Model.ECUIModel").new(members[j].model.modelid)
          self.memberModels[i].model:AddOnLoadCallback("DlgTeamMain_ShowTeamMember" .. i, function()
            local m = self.memberModels[i].model.m_model
            if m == nil then
              return
            end
            m.localPosition = EC.Vector3.new(-10000, -10000, 100)
            if model ~= nil and not model.isnil then
              local uimodel = model:GetComponent("UIModel")
              uimodel.modelGameObject = m
            end
          end)
          _G.LoadModel(self.memberModels[i].model, members[j].model, 0, 0, 180, false, false)
          return
        end
      end
    end
    local modeldata = self.memberModels[i]
    if modeldata ~= nil and modeldata.model ~= nil then
      modeldata.model:Destroy()
    end
  end
end
def.method().updateTeamPosition = function(self)
  if self:IsShow() == false then
    return
  end
  self.m_panel:FindDirect("Group_Team"):SetActive(true)
  self.m_panel:FindDirect("Group_List"):SetActive(false)
  local members = teamData:GetAllTeamMembers()
  local positions = teamData:getTeamPosition()
  local teamModelPanel = self.m_panel:FindDirect("Group_Team/Group_Model")
  local i
  self.listMember = {}
  if teamData:HasTeam() == true then
    for i = 1, 5 do
      local modelPanel = teamModelPanel:FindDirect("Group_" .. i)
      modelPanel:FindDirect("Img_Num"):SetActive(false)
      modelPanel:FindDirect("Img_Select"):SetActive(false)
      modelPanel:FindDirect("Img_Gray"):SetActive(false)
      modelPanel:FindDirect("Group_Model"):SetActive(false)
      modelPanel:FindDirect("Group_Add"):SetActive(false)
      modelPanel:FindDirect("Group_Head" .. i):SetActive(false)
      if positions[i] ~= nil then
        self:showTeamModel(i, positions[i].teamDispositionMember_id)
      else
        local modeldata = self.memberModels[i]
        if modeldata ~= nil and modeldata.model ~= nil then
          modeldata.model:Destroy()
        end
        modelPanel:FindDirect("Group_Add"):SetActive(true)
      end
    end
    local idx = 1
    for i = 1, 5 do
      if members[i] ~= nil and members[i].status == TeamMemberStatus.ST_NORMAL then
        local modelPanel = teamModelPanel:FindDirect("Group_" .. idx)
        modelPanel:FindDirect("Group_Head" .. idx .. "/Img_LiXian"):SetActive(false)
        modelPanel:FindDirect("Group_Head" .. idx .. "/Img_ZanLi"):SetActive(false)
        idx = idx + 1
      end
    end
    for i = 1, 5 do
      if members[i] ~= nil and members[i].status == TeamMemberStatus.ST_TMP_LEAVE then
        local modelPanel = teamModelPanel:FindDirect("Group_" .. idx)
        modelPanel:FindDirect("Group_Head" .. idx):SetActive(true)
        modelPanel:FindDirect("Group_Head" .. idx .. "/Img_LiXian"):SetActive(false)
        modelPanel:FindDirect("Group_Head" .. idx .. "/Img_ZanLi"):SetActive(true)
        _G.SetAvatarIcon(modelPanel:FindDirect("Group_Head" .. idx .. "/Img_Head"), members[i].avatarId)
        local Img_AvatarFrame = modelPanel:FindDirect("Group_Head" .. idx .. "/Img_AvatarFrame")
        _G.SetAvatarFrameIcon(Img_AvatarFrame, members[i].avatarFrameid)
        self.listMember[idx] = members[i]
        idx = idx + 1
      end
    end
    for i = 1, 5 do
      if members[i] ~= nil and members[i].status == TeamMemberStatus.ST_OFFLINE then
        local modelPanel = teamModelPanel:FindDirect("Group_" .. idx)
        modelPanel:FindDirect("Group_Head" .. idx):SetActive(true)
        modelPanel:FindDirect("Group_Head" .. idx .. "/Img_LiXian"):SetActive(true)
        modelPanel:FindDirect("Group_Head" .. idx .. "/Img_ZanLi"):SetActive(false)
        _G.SetAvatarIcon(modelPanel:FindDirect("Group_Head" .. idx .. "/Img_Head"), members[i].avatarId)
        local Img_AvatarFrame = modelPanel:FindDirect("Group_Head" .. idx .. "/Img_AvatarFrame")
        _G.SetAvatarFrameIcon(Img_AvatarFrame, members[i].avatarFrameid)
        self.listMember[idx] = members[i]
        idx = idx + 1
      end
    end
  else
    self:showPartnerModel(1)
    for i = 2, 5 do
      local modelPanel = teamModelPanel:FindDirect("Group_" .. i)
      modelPanel:FindDirect("Img_Num"):SetActive(false)
      modelPanel:FindDirect("Img_Select"):SetActive(false)
      modelPanel:FindDirect("Img_Gray"):SetActive(false)
      modelPanel:FindDirect("Group_Model"):SetActive(false)
      modelPanel:FindDirect("Group_Add"):SetActive(false)
      modelPanel:FindDirect("Group_Head" .. i):SetActive(false)
      self:showPartnerModel(i)
      self:showPartnerModel(i)
    end
  end
end
def.method().setFormationInfo = function(self)
  local formationInfo
  local formationId = teamData.formationId
  if formationId <= 0 and teamData:HasTeam() == false then
    local partnerInterface = require("Main.partner.PartnerInterface").Instance()
    local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
    local LineUp = partnerInterface:GetLineup(defaultLineUpNum)
    if LineUp ~= nil then
      formationId = LineUp.zhenFaId
    end
  end
  if formationId > 0 then
    formationInfo = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfo(formationId)
  end
  if nil ~= formationInfo then
    local level = formationInfo.level
    if teamData:HasTeam() == true then
      level = teamData.formationLevel
    end
    local str = string.format(textRes.Team[114], level, formationInfo.name)
    self.m_panel:FindDirect("Group_Team/Group_Top/Btn_ZhenFa/Label_ZhenFa"):GetComponent("UILabel").text = str
    local desc = textRes.Team[34]
    for k, v in pairs(formationInfo.KZInfo) do
      desc = desc .. v.name
      desc = desc .. " "
    end
    desc = desc .. "\n"
    desc = desc .. textRes.Team[35]
    for k, v in pairs(formationInfo.BKInfo) do
      desc = desc .. v.name
      desc = desc .. " "
    end
  else
    self.m_panel:FindDirect("Group_Team/Group_Top/Btn_ZhenFa/Label_ZhenFa"):GetComponent("UILabel").text = textRes.Team[36]
  end
  local hasThingAboutFormation = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):IsAnyThingAboutFormationInBag()
  if hasThingAboutFormation then
    self.m_panel:FindDirect("Group_Team/Group_Top/Btn_ZhenFa/Img_Red"):SetActive(true)
  else
    self.m_panel:FindDirect("Group_Team/Group_Top/Btn_ZhenFa/Img_Red"):SetActive(false)
  end
end
def.method().ShowButtons = function(self)
  local members = teamData:GetAllTeamMembers()
  local btnPanel = self.m_panel:FindDirect("Group_Btn")
  btnPanel:FindDirect("Btn_Quit"):SetActive(false)
  btnPanel:FindDirect("Btn_Partner"):SetActive(false)
  btnPanel:FindDirect("Btn_Invite"):SetActive(false)
  btnPanel:FindDirect("Btn_Creat"):SetActive(false)
  btnPanel:FindDirect("Btn_ZhaoHui"):SetActive(false)
  btnPanel:FindDirect("Btn_ZanLi"):SetActive(false)
  btnPanel:FindDirect("Btn_GuiDui"):SetActive(false)
  btnPanel:FindDirect("Btn_Clear"):SetActive(false)
  if #members == 0 then
    btnPanel:FindDirect("Btn_Partner"):SetActive(true)
    btnPanel:FindDirect("Btn_Invite"):SetActive(true)
    if 0 < #teamData:GetTeamInvitation() then
      btnPanel:FindDirect("Btn_Clear"):SetActive(true)
    else
      btnPanel:FindDirect("Btn_Creat"):SetActive(true)
    end
  else
    btnPanel:FindDirect("Btn_Quit"):SetActive(true)
    btnPanel:FindDirect("Btn_Partner"):SetActive(true)
    btnPanel:FindDirect("Btn_Invite"):SetActive(true)
    local applyPanel = self.m_panel:FindDirect("Tab_Apply"):GetComponent("UIToggle")
    local isApplyPanel = applyPanel:get_isChecked()
    btnPanel:FindDirect("Btn_Clear"):SetActive(isApplyPanel)
    local status = teamData:GetStatus()
    local isCaptain = teamData:IsCaptain(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId())
    btnPanel:FindDirect("Btn_ZhaoHui"):SetActive(not isApplyPanel and isCaptain)
    local visible = not isApplyPanel and not isCaptain and status == TeamMemberStatus.ST_NORMAL
    btnPanel:FindDirect("Btn_ZanLi"):SetActive(visible)
    visible = not isApplyPanel and not isCaptain and status == TeamMemberStatus.ST_TMP_LEAVE
    btnPanel:FindDirect("Btn_GuiDui"):SetActive(visible)
  end
  local teamPanel = self.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
  local isTeamPanel = teamPanel:get_isChecked()
  if true == isTeamPanel then
    btnPanel:FindDirect("Btn_Clear"):SetActive(false)
    if teamData:HasTeam() == false then
      btnPanel:FindDirect("Btn_Creat"):SetActive(true)
    end
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").ShowEmptyApplicants = function(self, content)
  local emptyLogo = self.m_panel:FindDirect("Group_List/Group_Empty")
  emptyLogo:SetActive(true)
  local emptyApply = self.m_panel:FindDirect("Group_List/Scroll View_List/Grid_List")
  emptyApply:SetActive(false)
  local label = self.m_panel:FindDirect("Group_List/Group_Empty/Img_BgLabel/Label_Empty"):GetComponent("UILabel")
  label.text = content
end
def.method().ShowApplicationList = function(self)
  local applyList = self.m_panel:FindDirect("Group_List/Scroll View_List/Grid_List")
  applyList:SetActive(true)
  self.m_panel:FindDirect("Group_List"):SetActive(true)
  local uiList = applyList:GetComponent("UIList")
  local applicants = teamData:GetAllApplicants()
  uiList.itemCount = #applicants
  uiList:Resize()
  self.m_panel:FindDirect("Group_List/Group_Empty"):SetActive(uiList.itemCount == 0)
  local isCaptain = teamData:IsCaptain(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId())
  local i = 1
  for k, v in ipairs(applicants) do
    local appItem = applyList:FindDirect("Group_Apply_" .. i)
    appItem:FindDirect("Label_Name_" .. i):GetComponent("UILabel"):set_text(v.roleName)
    appItem:FindDirect("Img_School_" .. i):GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(v.menpai)
    local headIcon = appItem:FindDirect("Img_IconHead_" .. i)
    _G.SetAvatarIcon(headIcon, v.avatarId)
    local Img_AvatarFrame = headIcon and headIcon:FindDirect("Img_AvatarFrame_" .. i)
    _G.SetAvatarFrameIcon(Img_AvatarFrame, v.avatarFrameId)
    local genderIcon = appItem:FindDirect("Img_Sex_" .. i)
    GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(v.gender))
    appItem:FindDirect("Label_Lv_" .. i):GetComponent("UILabel"):set_text(v.level .. textRes.Team[2])
    appItem:FindDirect("Btn_Agree_" .. i):SetActive(isCaptain)
    local recomemder = v.recommender
    if not isCaptain then
      recomemder = ""
    end
    appItem:FindDirect("Label_Tips_" .. i):GetComponent("UILabel"):set_text(recomemder)
    if recomemder == nil or recomemder == "" then
      appItem:FindDirect("Label_TuiJian_" .. i):SetActive(false)
    else
      appItem:FindDirect("Label_TuiJian_" .. i):SetActive(true)
    end
    i = i + 1
  end
  self.m_panel:FindDirect("Group_List/Scroll View_List/"):GetComponent("UIScrollView"):ResetPosition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method().ShowInvitationList = function(self)
  self.m_panel:FindDirect("Group_List/Group_Empty"):SetActive(false)
  self.m_panel:FindDirect("Group_List"):SetActive(true)
  local applyList = self.m_panel:FindDirect("Group_List/Scroll View_List/Grid_List")
  applyList:SetActive(true)
  local uiList = applyList:GetComponent("UIList")
  local invitations = teamData:GetTeamInvitation()
  uiList.itemCount = #invitations
  uiList:Resize()
  local i = 1
  for k, v in ipairs(invitations) do
    local inviteItem = applyList:FindDirect("Group_Apply_" .. i)
    inviteItem:FindDirect("Label_Name_" .. i):GetComponent("UILabel"):set_text(v.name)
    local headIcon = inviteItem:FindDirect("Img_IconHead_" .. i)
    _G.SetAvatarIcon(headIcon, v.avatarId)
    local Img_AvatarFrame = headIcon and headIcon:FindDirect("Img_AvatarFrame_" .. i)
    _G.SetAvatarFrameIcon(Img_AvatarFrame, v.avatarFrameid)
    local genderIcon = inviteItem:FindDirect("Img_Sex_" .. i)
    GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(v.gender))
    inviteItem:FindDirect("Label_Lv_" .. i):GetComponent("UILabel"):set_text(v.level .. textRes.Team[2])
    inviteItem:FindDirect("Label_Tips_" .. i):GetComponent("UILabel"):set_text("")
    inviteItem:FindDirect("Label_TuiJian_" .. i):SetActive(false)
    inviteItem:FindDirect("Img_School_" .. i):GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(v.menpai)
    i = i + 1
  end
  if #invitations < 1 then
    dlg:ShowEmptyApplicants(textRes.Team[39])
  end
  self.m_panel:FindDirect("Group_List/Scroll View_List/"):GetComponent("UIScrollView"):ResetPosition()
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.static("table", "table").ShowApplyTab = function()
  if dlg.m_panel == nil then
    return
  end
  if #teamData:GetAllApplicants() > 0 then
    local toggle = dlg.m_panel:FindDirect("Tab_Apply"):GetComponent("UIToggle")
    toggle:set_value(true)
    toggle = dlg.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
    toggle:set_value(false)
    dlg.tab = TAB_ENUM.APPLY
  else
    local toggle = dlg.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
    toggle:set_value(true)
    toggle = dlg.m_panel:FindDirect("Tab_Apply"):GetComponent("UIToggle")
    toggle:set_value(false)
    dlg.tab = TAB_ENUM.TEAM
  end
  dlg:updateUI()
end
def.static("table", "table").ShowInviteTab = function()
  if dlg.m_panel == nil then
    return
  end
  dlg.m_panel:FindDirect("Tab_Invite"):SetActive(true)
  dlg.m_panel:FindDirect("Tab_Apply"):SetActive(false)
  if #teamData:GetTeamInvitation() > 0 then
    local toggle = dlg.m_panel:FindDirect("Tab_Invite"):GetComponent("UIToggle")
    toggle:set_value(true)
    toggle = dlg.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
    toggle:set_value(false)
    dlg.tab = TAB_ENUM.INVITE
  else
    local toggle = dlg.m_panel:FindDirect("Tab_Invite"):GetComponent("UIToggle")
    toggle:set_value(false)
    toggle = dlg.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
    toggle:set_value(true)
    dlg.tab = TAB_ENUM.TEAM
  end
  dlg:updateUI()
end
def.static("table", "table").UpdateFormation = function()
  if dlg.m_panel == nil then
    return
  end
  dlg:setFormationInfo()
end
return DlgTeamMain.Commit()
