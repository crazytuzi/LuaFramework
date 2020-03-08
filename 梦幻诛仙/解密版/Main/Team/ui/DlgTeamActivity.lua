local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgTeamActivity = Lplus.Extend(ECPanelBase, "DlgTeamActivity")
local def = DlgTeamActivity.define
local dlg
local teamData = require("Main.Team.TeamData").Instance()
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
def.field("number").type = 0
def.field("table").members = nil
def.field("table").teams = nil
def.field("boolean").isshowing = false
def.static("=>", DlgTeamActivity).Instance = function()
  if dlg == nil then
    dlg = DlgTeamActivity()
  end
  return dlg
end
def.override().OnCreate = function(self)
  if teamData:HasTeam() == true then
    self.m_panel:FindDirect("Group_Bottom/Btn_Creat"):SetActive(false)
    self.m_panel:FindDirect("Group_Bottom/Btn_Quite"):SetActive(true)
  else
    self.m_panel:FindDirect("Group_Bottom/Btn_Creat"):SetActive(true)
    self.m_panel:FindDirect("Group_Bottom/Btn_Quite"):SetActive(false)
  end
end
def.method().ShowDlg = function(self)
  if self.m_panel ~= nil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_TEAM_ACTIVITY_UI_RES, 2)
  self:SetModal(true)
end
def.override().OnDestroy = function(self)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("number", "table").fillData = function(self, type, data)
  self.type = type
  warn("fillData -------- " .. type)
  if type == require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_TEAM then
    self.teams = data
  elseif type == require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_MEMBER then
    self.members = data
  end
end
def.method().fillGrid = function(self)
  if self.m_panel == nil then
    return
  end
  local listPanel = self.m_panel:FindDirect("Group_List/Scroll View_List/Grid_List")
  local uiList = listPanel:GetComponent("UIList")
  if self.type == require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_TEAM then
    local toggle = self.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
    toggle:set_value(true)
    toggle = self.m_panel:FindDirect("Tab_Member"):GetComponent("UIToggle")
    toggle:set_value(false)
    if self.teams == nil or #self.teams == 0 then
      self.m_panel:FindDirect("Group_List/Group_Empty"):SetActive(true)
      self.m_panel:FindDirect("Group_List/Scroll View_List"):SetActive(false)
      uiList.itemCount = 0
      uiList:Resize()
      return
    else
      self.m_panel:FindDirect("Group_List/Group_Empty"):SetActive(false)
      self.m_panel:FindDirect("Group_List/Scroll View_List"):SetActive(true)
    end
    uiList.itemCount = #self.teams
    uiList:Resize()
    for i = 1, #self.teams do
      local item = listPanel:FindDirect("Group_Apply_" .. i)
      item:FindDirect("Label_Name_" .. i):GetComponent("UILabel").text = self.teams[i].members[1].name
      item:FindDirect("Label_Lv_" .. i):GetComponent("UILabel").text = self.teams[i].members[1].level .. textRes.Team[2]
      item:FindDirect("Img_School_" .. i):GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(self.teams[i].members[1].menpai)
      item:FindDirect("Label_Num_" .. i):SetActive(true)
      item:FindDirect("Label_Num_" .. i):GetComponent("UILabel").text = #self.teams[i].members .. "/5"
      local headIcon = item:FindDirect("Img_IconHead_" .. i)
      _G.SetAvatarIcon(headIcon, self.teams[i].members[1].avatarId)
      local frameIcon = headIcon and headIcon:FindDirect("Img_AvatarFrame_" .. i)
      _G.SetAvatarFrameIcon(frameIcon, self.teams[i].members[1].avatarFrameid)
      local genderIcon = item:FindDirect("Img_Sex_" .. i)
      GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(self.teams[i].members[1].gender))
      item:FindDirect("Btn_Apply_" .. i .. "/Label_" .. i):GetComponent("UILabel").text = textRes.Team[69]
    end
    self.m_panel:FindDirect("Group_List/Scroll View_List"):GetComponent("UIScrollView"):ResetPosition()
    self:TouchGameObject(self.m_panel, self.m_parent)
  elseif self.type == require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_MEMBER then
    local toggle = self.m_panel:FindDirect("Tab_Team"):GetComponent("UIToggle")
    toggle:set_value(false)
    toggle = self.m_panel:FindDirect("Tab_Member"):GetComponent("UIToggle")
    toggle:set_value(true)
    if self.members == nil or #self.members == 0 then
      self.m_panel:FindDirect("Group_List/Group_Empty"):SetActive(true)
      self.m_panel:FindDirect("Group_List/Scroll View_List"):SetActive(false)
      uiList.itemCount = 0
      uiList:Resize()
      return
    else
      self.m_panel:FindDirect("Group_List/Group_Empty"):SetActive(false)
      self.m_panel:FindDirect("Group_List/Scroll View_List"):SetActive(true)
    end
    uiList.itemCount = #self.members
    uiList:Resize()
    for i = 1, #self.members do
      local item = listPanel:FindDirect("Group_Apply_" .. i)
      item:FindDirect("Label_Name_" .. i):GetComponent("UILabel").text = self.members[i].name
      item:FindDirect("Label_Lv_" .. i):GetComponent("UILabel").text = self.members[i].level .. textRes.Team[2]
      item:FindDirect("Img_School_" .. i):GetComponent("UISprite").spriteName = GUIUtils.GetOccupationSmallIcon(self.members[i].menpai)
      item:FindDirect("Label_Num_" .. i):SetActive(false)
      local headIcon = item:FindDirect("Img_IconHead_" .. i)
      _G.SetAvatarIcon(headIcon, self.members[i].avatarId)
      local frameIcon = headIcon and headIcon:FindDirect("Img_AvatarFrame_" .. i)
      _G.SetAvatarFrameIcon(frameIcon, self.members[i].avatarFrameid)
      local genderIcon = item:FindDirect("Img_Sex_" .. i)
      GUIUtils.SetSprite(genderIcon, GUIUtils.GetSexIcon(self.members[i].gender))
      item:FindDirect("Btn_Apply_" .. i .. "/Label_" .. i):GetComponent("UILabel").text = textRes.Team[68]
    end
    self.m_panel:FindDirect("Group_List/Scroll View_List"):GetComponent("UIScrollView"):ResetPosition()
    self:TouchGameObject(self.m_panel, self.m_parent)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Refresh" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").new(self.type))
    Toast(textRes.Team[73])
  elseif id == "Btn_Creat" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CCreateTeamReq").new())
    self:Hide()
  elseif id == "Btn_Quite" then
    require("GUI.CommonConfirmDlg").ShowConfirm("", textRes.Team[1], function(i, tag)
      if i == 1 then
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CLeaveTeamReq").new())
        self.m_panel:FindDirect("Group_Bottom/Btn_Creat"):SetActive(true)
        self.m_panel:FindDirect("Group_Bottom/Btn_Quite"):SetActive(false)
      end
    end, {id = self})
  elseif id == "Tab_Team" then
    self.type = require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_TEAM
    self:fillGrid()
  elseif id == "Tab_Member" then
    self.type = require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_MEMBER
    self:fillGrid()
  elseif id == "Btn_Close" then
    self:Hide()
  elseif string.find(id, "Group_Apply") == 1 then
    if self.type == require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_TEAM then
      local index = tonumber(string.sub(id, -1, -1))
      require("Main.Team.ui.DlgTeamInfo").Instance():ShowDlg(self.teams[index].members)
    end
  elseif string.find(id, "Btn_Apply") == 1 then
    local index = tonumber(string.sub(id, -1, -1))
    if self.type == require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_TEAM then
      local teamid = self.teams[index].teamId
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CApplyTeamByTeamId").new(teamid))
    elseif self.type == require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq").FIND_MEMBER then
      local roleId = self.members[index].roleId
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.team.CInviteTeamReq").new(roleId))
    end
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:fillGrid()
end
return DlgTeamActivity.Commit()
