local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgCrossServerTeam = Lplus.Extend(ECPanelBase, "DlgCrossServerTeam")
local def = DlgCrossServerTeam.define
local dlg
local teamData = require("Main.Team.TeamData").Instance()
local GUIUtils = require("GUI.GUIUtils")
local CommonUISmallTip = require("GUI.CommonUISmallTip")
local EC = require("Types.Vector")
def.field("table").memberModels = nil
def.field("table").listMember = nil
def.static("=>", DlgCrossServerTeam).Instance = function()
  if dlg == nil then
    dlg = DlgCrossServerTeam()
  end
  return dlg
end
def.override().OnCreate = function(self)
  self.memberModels = {}
  self.listMember = {}
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, DlgCrossServerTeam.OnMemberLeaveTeam)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, DlgCrossServerTeam.OnLeaveTeam)
  Event.RegisterEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_READY_INFO, DlgCrossServerTeam.OnUpdateReadyInfo)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, DlgCrossServerTeam.OnMemberStatusChange)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.MEMBER_LEVEL_CHANGED, DlgCrossServerTeam.OnMemberLevelChanged)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_TEAM_CROSS_SERVER, 1)
  self:SetModal(true)
end
def.override().OnDestroy = function(self)
  if self.memberModels then
    for k, member in pairs(self.memberModels) do
      if member.model then
        member.model:Destroy()
        member.model = nil
      end
    end
    self.memberModels = nil
  end
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, DlgCrossServerTeam.OnMemberLeaveTeam)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, DlgCrossServerTeam.OnLeaveTeam)
  Event.UnregisterEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_READY_INFO, DlgCrossServerTeam.OnUpdateReadyInfo)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, DlgCrossServerTeam.OnMemberStatusChange)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.MEMBER_LEVEL_CHANGED, DlgCrossServerTeam.OnMemberLevelChanged)
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Img_Bg1_") then
    local idx = tonumber(string.sub(id, #"Img_Bg1_" + 1, -1))
    self:ClickTeamItem(idx)
    return
  end
  if id == "Btn_StartMatch" then
    self:StartMatch()
  elseif id == "Btn_QuitActivity" then
    require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.CrossServer[29], function(i, tag)
      if i == 1 then
        gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):LeaveCrossServerBattle()
      end
    end, {id = self})
  elseif id == "Btn_Ready" then
    local status = teamData:GetStatus()
    if status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
      Toast(textRes.CrossServer[26])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderReadyReq").new())
  elseif id == "Btn_QuitMatch" then
    require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.CrossServer[6], function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderUnMatchReq").new())
      end
    end, {id = self})
  elseif id == "Btn_QuitTeam" then
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.Team[1], function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
      end
    end, {id = self})
  elseif id == "Btn_TeamCenter" then
    Event.DispatchEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, {
      constant.CrossServerConsts.teamPlatServiceid,
      constant.CrossServerConsts.npcid
    })
  elseif id == "Btn_Close" then
    if gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):IsInMatching() then
      Toast(textRes.CrossServer[28])
      return
    end
    self:Hide()
    require("Main.CrossServer.ui.DlgMatchInfo").Instance():ShowDlg()
  elseif id == "Btn_QuitReady" then
    local tipContent = textRes.CrossServer[27]
    if gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):IsInMatching() then
      tipContent = textRes.CrossServer[14]
    end
    require("GUI.CommonConfirmDlg").ShowConfirm("", tipContent, function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderCancelReadyReq").new())
      end
    end, {id = self})
  elseif id == "Btn_Tips" then
    gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):RequestMyLadderInfo()
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  if id == "Label_TeamNum" then
    if state == false then
      CommonUISmallTip.Instance():HideTip()
      return
    end
    local sourceObj = self.m_panel:FindDirect("Group_Team/Label_TeamNum")
    local position = sourceObj:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = sourceObj:GetComponent("UIWidget")
    CommonUISmallTip.Instance():ShowTip(textRes.CrossServer[46], screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local start_time, end_time = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetCurrentSeasonDate()
  if start_time then
    local str = ""
    if end_time == nil then
      str = string.format("%d.%d.%d - ", start_time.year, start_time.month, start_time.day)
    else
      str = string.format("%d.%d.%d - %d.%d.%d", start_time.year, start_time.month, start_time.day, end_time.year, end_time.month, end_time.day)
    end
    self.m_panel:FindDirect("Group_Team/Label_ActivityTime/Label_Num"):GetComponent("UILabel").text = str
  end
  self:ShowButtons()
  local bHasTeam = teamData:HasTeam()
  if true == bHasTeam then
    self:ShowTeamMembers()
  end
end
local uimodel_pos = EC.Vector3.new(-10000, -10000, 100)
def.method().ShowTeamMembers = function(self)
  if self.memberModels == nil then
    self.memberModels = {}
  end
  local members = teamData:GetAllTeamMembers()
  local formationInfo
  if teamData.formationId ~= 0 then
    formationInfo = gmodule.moduleMgr:GetModule(ModuleId.FORMATION):GetFormationInfoAtLevel(teamData.formationId, teamData.formationLevel)
  end
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER)
  local myid = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  local myInfo = mgr:GetRoleInfoByRoleId(myid)
  local teamMatchScore = mgr:GetTeamMatchScore()
  self.m_panel:FindDirect("Group_Team/Label_MyNum/Label_Num"):GetComponent("UILabel").text = myInfo and myInfo.score or 0
  self.m_panel:FindDirect("Group_Team/Label_TeamNum/Label_Num"):GetComponent("UILabel").text = teamMatchScore
  for i = 1, 5 do
    do
      local modelPanel = self.m_panel:FindDirect("Group_Team/Group_Model/Group_" .. i)
      if i <= #members then
        modelPanel:FindDirect("Group_Model/Group_Info"):SetActive(true)
        modelPanel:FindDirect("Img_Select"):SetActive(false)
        modelPanel:FindDirect("Img_DuanWei"):SetActive(true)
        do
          local roleInfo = mgr:GetRoleInfoByRoleId(members.roleid)
          if roleInfo then
            local phaseInfo = mgr:GetPhaseInfo(roleInfo.level, roleInfo.stage)
            if phaseInfo then
              modelPanel:FindDirect("Img_DuanWei"):GetComponent("UISprite").spriteName = phaseInfo.iconName
            end
          end
          local serverName = modelPanel:FindDirect("Label_Label_ServerName")
          serverName:SetActive(true)
          local serverInfo = _G.GetRoleServerInfo(members[i].roleid)
          serverName:GetComponent("UILabel").text = serverInfo and serverInfo.name or "unknown"
          local model = modelPanel:FindDirect("Group_Model/Model")
          local menpaiIcon = modelPanel:FindDirect("Group_Model/Group_Info/Img_School")
          menpaiIcon:SetActive(false)
          local isReady = false
          if i == 1 then
            isReady = true
          else
            isReady = mgr:IsReady(members[i].roleid)
          end
          modelPanel:FindDirect("Img_Ready"):SetActive(isReady)
          self.listMember[i] = members[i]
          menpaiIcon:SetActive(true)
          menpaiIcon:GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(members[i].menpai)
          modelPanel:FindDirect("Group_Model/Group_Info/Label_Name"):GetComponent("UILabel").text = members[i].name
          modelPanel:FindDirect("Group_Model/Group_Info/Label"):SetActive(true)
          modelPanel:FindDirect("Group_Model/Group_Info/Label_Lv"):GetComponent("UILabel").text = members[i].level
          local genderIcon = modelPanel:FindDirect("Group_Model/Group_Info/Img_Sex")
          GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(members[i].gender))
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
          elseif self.memberModels[i].model then
            self.memberModels[i].model:Destroy()
            self.memberModels[i].model = nil
          end
          self.memberModels[i].model = require("Model.ECUIModel").new(members[i].model.modelid)
          self.memberModels[i].roleid = members[i].roleid
          self.memberModels[i].model:AddOnLoadCallback("DlgCrossServerTeam_ShowTeamMember" .. i, function()
            local m = self.memberModels[i].model.m_model
            if m == nil then
              return
            end
            m.localPosition = uimodel_pos
            if model ~= nil and not model.isnil then
              local uimodel = model:GetComponent("UIModel")
              uimodel.modelGameObject = m
            end
          end)
          _G.LoadModel(self.memberModels[i].model, members[i].model, 0, 0, 180, false, false)
        end
      else
        modelPanel:FindDirect("Group_Model/Group_Info"):SetActive(false)
        modelPanel:FindDirect("Label_Label_ServerName"):SetActive(false)
        modelPanel:FindDirect("Img_DuanWei"):SetActive(false)
        modelPanel:FindDirect("Img_Ready"):SetActive(false)
        if self.memberModels[i] and self.memberModels[i].model then
          self.memberModels[i].model:Destroy()
          self.memberModels[i].model = nil
        end
      end
    end
  end
end
def.method().ShowButtons = function(self)
  local btnPanel = self.m_panel:FindDirect("Group_Btn")
  local isInMatching = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):IsInMatching()
  if teamData:MeIsCaptain() == true then
    btnPanel:FindDirect("Btn_StartMatch"):SetActive(not isInMatching)
    btnPanel:FindDirect("Btn_QuitMatch"):SetActive(isInMatching)
    btnPanel:FindDirect("Btn_Ready"):SetActive(false)
    btnPanel:FindDirect("Btn_QuitReady"):SetActive(false)
    btnPanel:FindDirect("Btn_QuitActivity"):SetActive(true)
    btnPanel:FindDirect("Btn_QuitTeam"):SetActive(false)
  else
    btnPanel:FindDirect("Btn_StartMatch"):SetActive(false)
    btnPanel:FindDirect("Btn_QuitMatch"):SetActive(false)
    local myid = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
    local isReady = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):IsReady(myid)
    btnPanel:FindDirect("Btn_Ready"):SetActive(not isReady)
    btnPanel:FindDirect("Btn_QuitReady"):SetActive(isReady)
    btnPanel:FindDirect("Btn_QuitActivity"):SetActive(false)
    btnPanel:FindDirect("Btn_QuitTeam"):SetActive(true)
  end
  if isInMatching then
    require("Main.CrossServer.ui.DlgMatchCountDown").Instance():ShowDlg()
  end
end
def.method().StartMatch = function(self)
  local members = teamData:GetAllTeamMembers()
  if members == nil or #members < require("Main.CrossServer.CrossServerModule").TEAM_MEMBER_REQ then
    Toast(textRes.CrossServer[25])
    return
  end
  local min, max = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetLevelRange(members[1].level)
  for _, v in pairs(members) do
    if min > v.level or max < v.level then
      _G.ShowCommonCenterTip(701606317)
      Toast(textRes.CrossServer[47])
      return
    end
  end
  for i = 2, #members do
    if not gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):IsReady(members[i].roleid) then
      Toast(string.format(textRes.CrossServer[5], members[i].name))
      return
    end
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.ladder.CLadderMatchReq").new())
end
def.method("boolean").MatchStarted = function(self, isStarted)
  if self.m_panel == nil then
    return
  end
  local btnPanel = self.m_panel:FindDirect("Group_Btn")
  if teamData:MeIsCaptain() == true then
    btnPanel:FindDirect("Btn_StartMatch"):SetActive(not isStarted)
    btnPanel:FindDirect("Btn_QuitMatch"):SetActive(isStarted)
  end
  if isStarted then
    require("Main.CrossServer.ui.DlgMatchCountDown").Instance():ShowDlg()
  else
    local countdown_dlg = require("Main.CrossServer.ui.DlgMatchCountDown").Instance()
    countdown_dlg:Hide()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("number").ClickTeamItem = function(self, idx)
  local members = teamData:GetAllTeamMembers()
  if members == nil or idx > #members then
    return
  end
  local memberInfo = members[idx]
  local roleInfo = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):GetRoleInfoByRoleId(memberInfo.roleid)
  if roleInfo == nil then
    return
  end
  roleInfo.name = memberInfo.name
  roleInfo.level = memberInfo.level
  roleInfo.menpai = memberInfo.menpai
  roleInfo.gender = memberInfo.gender
  roleInfo.avatarId = memberInfo.avatarId
  if roleInfo.avatarFrameId == nil then
    roleInfo.avatarFrameId = memberInfo.avatarFrameid
  end
  require("Main.CrossServer.ui.DlgCrossServerCharMenu").Instance():ShowDlg(roleInfo)
end
def.static("table", "table").OnMemberLeaveTeam = function(p1, p2)
  if dlg == nil then
    return
  end
  if teamData:HasTeam() then
    dlg:ShowTeamMembers()
  else
    dlg:Hide()
    require("Main.CrossServer.ui.DlgMatchInfo").Instance():Hide()
  end
end
def.static("table", "table").OnMemberStatusChange = function(p1, p2)
  if dlg == nil then
    return
  end
  local roleid = p1 and p1[1]
  local status = p1 and p1[2]
  if roleid == nil then
    return
  end
  local role
  if dlg.memberModels then
    for i = 1, #dlg.memberModels do
      if dlg.memberModels[i].roleid:eq(roleid) then
        role = dlg.memberModels[i].model
      end
    end
  end
  if role == nil then
    return
  end
  if status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_OFFLINE then
    role:SetAlpha(0.5)
  else
    role:CloseAlpha()
  end
end
def.static("table", "table").OnMemberLevelChanged = function(p1, p2)
  if dlg == nil then
    return
  end
  local roleid = p1 and p1[1]
  local level = p1 and p1[2]
  if roleid == nil then
    return
  end
  local idx = teamData:GetMemberIndex(roleid)
  local modelPanel = dlg.m_panel:FindDirect("Group_Team/Group_Model/Group_" .. idx)
  if modelPanel == nil then
    return
  end
  modelPanel:FindDirect("Group_Model/Group_Info/Label_Lv"):GetComponent("UILabel"):set_text(level)
end
def.static("table", "table").OnLeaveTeam = function(p1, p2)
  if dlg == nil then
    return
  end
  dlg:Hide()
end
def.static("table", "table").OnUpdateReadyInfo = function(p1, p2)
  if dlg == nil or dlg.m_panel == nil then
    return
  end
  local members = teamData:GetAllTeamMembers()
  local roleid = p1 and p1.roleid
  if members == nil or #members == 0 or roleid == nil then
    return
  end
  local isReady = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER):IsReady(roleid)
  if roleid:eq(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()) and teamData:MeIsCaptain() == false then
    dlg.m_panel:FindDirect("Group_Btn/Btn_Ready"):SetActive(not isReady)
    dlg.m_panel:FindDirect("Group_Btn/Btn_QuitReady"):SetActive(isReady)
  end
  for i = 1, #members do
    if roleid:eq(members[i].roleid) then
      local modelPanel = dlg.m_panel:FindDirect("Group_Team/Group_Model/Group_" .. i)
      modelPanel:FindDirect("Img_Ready"):SetActive(isReady)
      return
    end
  end
end
return DlgCrossServerTeam.Commit()
