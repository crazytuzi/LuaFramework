local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgCmdButtons = Lplus.Extend(ECPanelBase, "DlgCmdButtons")
local def = DlgCmdButtons.define
local dlg
local teamData = require("Main.Team.TeamData").Instance()
local GUIMan = require("GUI.ECGUIMan").Instance()
local EC = require("Types.Vector3")
local dlgTeamMain = require("Main.Team.ui.DlgTeamMain").Instance()
def.field("userdata").roleId = nil
def.field("string").roleName = ""
def.field("number").menpai = 0
def.field("number").gender = 0
def.field("number").level = 0
def.field("number").status = 0
def.field("number").index = 0
def.field("number").avatarId = 0
def.field("number").avatarFrameId = 0
def.static("=>", DlgCmdButtons).Instance = function()
  if dlg == nil then
    dlg = DlgCmdButtons()
  end
  return dlg
end
def.method("userdata", "string", "number", "number", "number", "number", "number", "number", "number").ShowDlg = function(self, roleid, rolename, menpai, gender, level, status, avatarId, avatarFrameId, index)
  if self.m_panel then
    self:DestroyPanel()
  end
  self.roleId = roleid
  self.roleName = rolename
  self.menpai = menpai
  self.gender = gender
  self.level = level
  self.status = status
  self.avatarId = avatarId
  self.avatarFrameId = avatarFrameId
  self.index = index
  self:CreatePanel(RESPATH.DLG_TEAM_BUTTONS_UI_RES, 2)
  self:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  local localPosition = self.m_panel:FindDirect("Table_TeamBtn"):get_localPosition()
  self.m_panel:FindDirect("Table_TeamBtn"):set_localPosition(EC.Vector3.new(localPosition.x, localPosition.y + 100, 0))
  local posBtn = Object.Instantiate(self.m_panel:FindDirect("Table_TeamBtn/Btn_Leader"))
  posBtn.name = "Btn_Pos"
  posBtn.parent = self.m_panel:FindDirect("Table_TeamBtn")
  posBtn:set_localScale(EC.Vector3.one)
  posBtn:FindDirect("Label_Leader"):GetComponent("UILabel").text = textRes.Team[50]
  self.m_msgHandler:Touch(posBtn)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local isCaptain = teamData:IsCaptain(gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId())
  self.m_panel:FindDirect("Table_TeamBtn/Btn_kick"):SetActive(isCaptain)
  local uiTable = self.m_panel:FindDirect("Table_TeamBtn"):GetComponent("UITableResizeBackground")
  self.m_panel:FindDirect("Table_TeamBtn/Container/Label_Name"):GetComponent("UILabel").text = self.roleName
  local isFriend = require("Main.friend.FriendModule").Instance():IsFriend(self.roleId)
  if isFriend == true then
    self.m_panel:FindDirect("Table_TeamBtn/Btn_Friend/Label_Friend"):GetComponent("UILabel").text = textRes.Team[48]
  else
    self.m_panel:FindDirect("Table_TeamBtn/Btn_Friend/Label_Friend"):GetComponent("UILabel").text = textRes.Team[47]
  end
  if isCaptain and self.status == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
    self.m_panel:FindDirect("Table_TeamBtn/Btn_Pos"):SetActive(true)
    self.m_panel:FindDirect("Table_TeamBtn/Btn_Leader"):SetActive(true)
  else
    self.m_panel:FindDirect("Table_TeamBtn/Btn_Pos"):SetActive(false)
    self.m_panel:FindDirect("Table_TeamBtn/Btn_Leader"):SetActive(false)
  end
  self.m_panel:FindDirect("Table_TeamBtn/Space").transform:SetAsLastSibling()
  uiTable:Reposition()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Talk" then
    if self.roleId == nil or self.roleId:eq(0) then
      return
    end
    warn("[DlgCmdButtons:onClick] self.avatarFrameId =", self.avatarFrameId)
    Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CMD_CLICK_CHAT, {
      self.roleId,
      self.roleName,
      self.menpai,
      self.gender,
      self.level,
      self.avatarId,
      self.avatarFrameId
    })
    self:Hide()
  elseif id == "Btn_Friend" then
    if self.roleId == nil or self.roleId:eq(0) then
      return
    end
    local teamer = teamData:GetTeamMember(self.roleId)
    if teamer ~= nil then
      Event.DispatchEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CMD_CLICK_ADDFRIEND, {
        self.roleId,
        self.roleName
      })
    end
    self:Hide()
  elseif id == "Btn_kick" then
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
  elseif id == "Btn_Leader" then
    if self.roleId == nil or self.roleId:eq(0) then
      return
    end
    local member = teamData:GetTeamMember(self.roleId)
    if member ~= nil and member.status ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
      require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.Team[14], function()
      end, nil)
      return
    end
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
    self:Hide()
  elseif id == "Btn_Pos" then
    dlgTeamMain:setSelectedItem(self.index, require("netio.protocol.mzm.gsp.team.TeamDispositionMemberInfo").DT_TEAM_MEMBER)
    self:Hide()
  end
end
return DlgCmdButtons.Commit()
