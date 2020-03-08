local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MainUITeamOperater = Lplus.Extend(ECPanelBase, "MainUITeamOperater")
local def = MainUITeamOperater.define
local dlg
local teamData = require("Main.Team.TeamData").Instance()
local GUIMan = require("GUI.ECGUIMan").Instance()
local EC = require("Types.Vector3")
def.field("userdata").roleId = nil
def.field("string").roleName = ""
def.field("number").status = 0
def.field("number").posX = 0
def.field("number").posY = 0
def.static("=>", MainUITeamOperater).Instance = function()
  if dlg == nil then
    dlg = MainUITeamOperater()
  end
  return dlg
end
def.method("userdata", "string", "number", "number", "number").ShowDlg = function(self, roleid, rolename, status, x, y)
  if self.m_panel then
    self:DestroyPanel()
  end
  self.roleId = roleid
  self.roleName = rolename
  self.status = status
  self.posX = x
  self.posY = y
  self:CreatePanel(RESPATH.DLG_MAINUI_TEAM_OPERATE_RES, 2)
  self:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self.m_panel:FindDirect("Img_Bg1/Group_Name/Label_Name"):GetComponent("UILabel").text = self.roleName
  local localPosition = self.m_panel:FindDirect("Img_Bg1"):get_localPosition()
  self.m_panel:FindDirect("Img_Bg1"):set_localPosition(EC.Vector3.new(localPosition.x, localPosition.y + 100, 0))
  local meIsCaption = teamData:MeIsCaptain()
  if meIsCaption == true and self.roleId == gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId() then
    self.m_panel:FindDirect("Img_Bg1/Btn_1/Label"):GetComponent("UILabel").text = textRes.Team[56]
    self.m_panel:FindDirect("Img_Bg1"):set_localPosition(EC.Vector3.new(self.posX, self.posY, 0))
    return
  end
  if true == meIsCaption then
    if self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
      self.m_panel:FindDirect("Img_Bg1/Btn_1/Label"):GetComponent("UILabel").text = textRes.Team[53]
      local baseBtn = Object.Instantiate(self.m_panel:FindDirect("Img_Bg1/Btn_1"))
      baseBtn.name = "Btn_Kick"
      baseBtn.parent = self.m_panel:FindDirect("Img_Bg1")
      baseBtn:set_localScale(EC.Vector3.one)
      baseBtn:FindDirect("Label"):GetComponent("UILabel").text = textRes.Team[52]
      self.m_msgHandler:Touch(baseBtn)
    elseif self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
      self.m_panel:FindDirect("Img_Bg1/Btn_1/Label"):GetComponent("UILabel").text = textRes.Team[54]
      local baseBtn = Object.Instantiate(self.m_panel:FindDirect("Img_Bg1/Btn_1"))
      baseBtn.name = "Btn_Kick"
      baseBtn.parent = self.m_panel:FindDirect("Img_Bg1")
      baseBtn:set_localScale(EC.Vector3.one)
      baseBtn:FindDirect("Label"):GetComponent("UILabel").text = textRes.Team[52]
      self.m_msgHandler:Touch(baseBtn)
    elseif self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_OFFLINE then
      self.m_panel:FindDirect("Img_Bg1/Btn_1/Label"):GetComponent("UILabel").text = textRes.Team[52]
    end
    local baseBtn = Object.Instantiate(self.m_panel:FindDirect("Img_Bg1/Btn_1"))
    baseBtn.name = "Btn_More"
    baseBtn.parent = self.m_panel:FindDirect("Img_Bg1")
    baseBtn:set_localScale(EC.Vector3.one)
    baseBtn:FindDirect("Label"):GetComponent("UILabel").text = textRes.Team[113]
    self.m_msgHandler:Touch(baseBtn)
  elseif self.roleId == gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId() then
    if self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
      self.m_panel:FindDirect("Img_Bg1/Btn_1/Label"):GetComponent("UILabel").text = textRes.Team[57]
    else
      self.m_panel:FindDirect("Img_Bg1/Btn_1/Label"):GetComponent("UILabel").text = textRes.Team[55]
    end
    local baseBtn = Object.Instantiate(self.m_panel:FindDirect("Img_Bg1/Btn_1"))
    baseBtn.name = "Btn_Leave"
    baseBtn.parent = self.m_panel:FindDirect("Img_Bg1")
    baseBtn:set_localScale(EC.Vector3.one)
    baseBtn:FindDirect("Label"):GetComponent("UILabel").text = textRes.Team[56]
    self.m_msgHandler:Touch(baseBtn)
    local members = teamData:GetAllTeamMembers()
    if #members > 0 then
      local leaderid = members[1].roleid
      local role = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRole(leaderid)
      if role ~= nil and role:IsInState(RoleState.WATCH) == true then
        local LookonBtn = Object.Instantiate(self.m_panel:FindDirect("Img_Bg1/Btn_1"))
        LookonBtn.name = "Btn_LookOn"
        LookonBtn.parent = self.m_panel:FindDirect("Img_Bg1")
        LookonBtn:set_localScale(EC.Vector3.one)
        LookonBtn:FindDirect("Label"):GetComponent("UILabel").text = textRes.Team[67]
        self.m_msgHandler:Touch(LookonBtn)
      end
    end
  else
    self.m_panel:FindDirect("Img_Bg1/Btn_1/Label"):GetComponent("UILabel").text = textRes.Team[113]
  end
  self.m_panel:FindDirect("Img_Bg1"):set_localPosition(EC.Vector3.new(self.posX, self.posY, 0))
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local uiTable = self.m_panel:FindDirect("Img_Bg1"):GetComponent("UITableResizeBackground")
  uiTable:Reposition()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_1" then
    if teamData:MeIsCaptain() then
      if self.roleId == gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId() then
        local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
        if heroModule.myRole:IsInState(RoleState.FLY) then
        end
        if teamData:hasProtectedMember() then
          require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.Team[100], function(i, tag)
            if i == 1 then
              gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
            end
          end, {id = self})
        else
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
        end
        self:Hide()
        return
      end
      if self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
        if PlayerIsInFight() == true then
          Toast(textRes.Team[75])
          return
        end
        local tip = string.format(textRes.Team[17], self.roleName)
        if teamData:hasProtectedMember() then
          tip = textRes.Team[100]
        end
        require("GUI.CommonConfirmDlg").ShowConfirm("", tip, function(i, tag)
          if i == 1 then
            gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CAppointLeaderReq").new(self.roleId))
          end
        end, {id = self})
      elseif self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CRecallAllReq").new())
      elseif self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_OFFLINE then
        local tip = textRes.Team[12]
        require("GUI.CommonConfirmDlg").ShowConfirm("", string.format(tip, self.roleName), function(i, tag)
          if i == 1 then
            gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CFireMemberReq").new(self.roleId))
          end
        end, {id = self})
      end
    elseif self.roleId == gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId() then
      if self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CReturnTeamReq").new())
      else
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CTempLeaveReq").new())
      end
    else
      local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
      FriendCommonDlgManager.ApplyShowFriendCommonDlg(self.roleId, FriendCommonDlgManager.StateConst.Null)
    end
    self:Hide()
  elseif id == "Btn_Leave" then
    if self.roleId == nil or self.roleId:eq(0) then
      return
    end
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    if heroModule.myRole:IsInState(RoleState.FLY) then
    end
    if teamData:isProtctedMember(self.roleId) then
      require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.Team[101], function(i, tag)
        if i == 1 then
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
        end
      end, {id = self})
    else
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
    end
    self:Hide()
  elseif id == "Btn_Kick" then
    if self.roleId == nil or self.roleId:eq(0) then
      return
    end
    local tip = textRes.Team[12]
    if teamData:isProtctedMember(self.roleId) and self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
      tip = textRes.Team[99]
    end
    require("GUI.CommonConfirmDlg").ShowConfirm("", string.format(tip, self.roleName), function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CFireMemberReq").new(self.roleId))
      end
    end, {id = self})
    self:Hide()
  elseif id == "Btn_LookOn" then
    if self.roleId == nil or self.roleId:eq(0) then
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.fight.CObserveFightWithLeader").new())
    self:Hide()
  elseif id == "Btn_AddFriend" then
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CMD_CLICK_ADDFRIEND, {
      self.roleId,
      self.roleName
    })
    self:Hide()
  elseif id == "Btn_DelFriend" then
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CMD_CLICK_ADDFRIEND, {
      self.roleId,
      self.roleName
    })
    self:Hide()
  elseif id == "Btn_Chat" then
    local member = teamData:getMember(self.roleId)
    if member ~= nil then
      warn("[MainUITeamOperate:onClick] member.avatarFrameid =", member.avatarFrameid)
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CMD_CLICK_CHAT, {
        self.roleId,
        self.roleName,
        member.menpai,
        member.gender,
        member.level,
        member.avatarId,
        member.avatarFrameid
      })
    end
    self:Hide()
  elseif id == "Btn_More" then
    local FriendCommonDlgManager = require("Main.friend.FriendCommonDlgManager")
    FriendCommonDlgManager.ApplyShowFriendCommonDlg(self.roleId, FriendCommonDlgManager.StateConst.Null)
    self:Hide()
  end
end
return MainUITeamOperater.Commit()
