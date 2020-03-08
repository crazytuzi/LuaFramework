local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local SwornMgr = require("Main.Sworn.SwornMgr")
local CAddNewMemberVoteReq = require("netio.protocol.mzm.gsp.sworn.CAddNewMemberVoteReq")
local VotePanel = Lplus.Extend(ECPanelBase, "VotePanel")
local def = VotePanel.define
def.const("table").PANELSTATE = {
  ADD = 1,
  LEAVE = 2,
  CHANGE = 3
}
def.const("table").TITLESPRITE = {
  ADD = "Label_JY_JNXR",
  LEAVE = "Label_JY_QLSQ",
  CHANGE = "Label_JY_MCXG"
}
def.field("number").m_CurState = 1
def.field("number").m_TimerID = 0
def.field("number").m_MailIndex = 0
def.field("table").m_VoteInfo = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", VotePanel).Instance = function()
  if not instance then
    instance = VotePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_JIE_YI_VOTE_PANEL, GUILEVEL.DEPENDEND)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:Update()
end
def.override().OnDestroy = function(self)
  self.m_CurState = VotePanel.PANELSTATE.ADD
  self.m_MailIndex = 0
  self.m_VoteInfo = nil
  self.m_UIGO = nil
  self:RemoveTimer()
end
def.method().RemoveTimer = function(self)
  if self.m_TimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_TimerID)
    self.m_TimerID = 0
  end
end
def.method("number").SetPanelState = function(self, state)
  self.m_CurState = state
end
def.method("table").SetVoteInfo = function(self, voteInfo)
  self.m_VoteInfo = voteInfo
end
def.method("number").SetMailIndex = function(self, mailIndex)
  self.m_MailIndex = mailIndex
end
def.method("number").Vote = function(self, agree)
  if self.m_CurState == VotePanel.PANELSTATE.ADD then
    SwornMgr.AddNewMemberVoteReq({votevalue = agree})
  elseif self.m_CurState == VotePanel.PANELSTATE.LEAVE then
    SwornMgr.KickoutVoteReq({votevalue = agree})
  elseif self.m_CurState == VotePanel.PANELSTATE.CHANGE then
    SwornMgr.ChangeSwornNameVoteReq({votevalue = agree})
  end
  if self.m_MailIndex ~= 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.mail.CDelMailReq").new(self.m_MailIndex))
  end
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    if self.m_MailIndex ~= 0 then
    end
    self:DestroyPanel()
  elseif id == "Btn_Refuse" then
    self:Vote(CAddNewMemberVoteReq.VOTE_NOTAGREE)
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:Vote(CAddNewMemberVoteReq.VOTE_AGREE)
    self:DestroyPanel()
  end
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.Group1 = self.m_panel:FindDirect("Group_New")
  self.m_UIGO.Group2 = self.m_panel:FindDirect("Group_Leave")
  self.m_UIGO.Group3 = self.m_panel:FindDirect("Group_Change")
  self.m_UIGO.Title = self.m_panel:FindDirect("Img_Bg0/Img_BgTitle/Img_Label")
  self.m_UIGO.Title1 = self.m_panel:FindDirect("Group_New/Label1")
  self.m_UIGO.Title2 = self.m_panel:FindDirect("Group_Leave/Label1")
  self.m_UIGO.Title3 = self.m_panel:FindDirect("Group_Change/Label1")
  self.m_UIGO.Time1 = self.m_panel:FindDirect("Group_New/Group_Time/Label_Time")
  self.m_UIGO.Time2 = self.m_panel:FindDirect("Group_Leave/Group_Time/Label_Time")
  self.m_UIGO.Time3 = self.m_panel:FindDirect("Group_Change/Group_Time/Label_Time")
  self.m_UIGO.Player1 = self.m_panel:FindDirect("Group_New/Group_Player")
  self.m_UIGO.Player2 = self.m_panel:FindDirect("Group_Leave/Group_Player")
  self.m_UIGO.Name1 = self.m_panel:FindDirect("Group_Change/Group_Name/Img_Input1/Label")
  self.m_UIGO.Name2 = self.m_panel:FindDirect("Group_Change/Group_Name/Img_Input2/Label")
  self.m_UIGO.Label = self.m_panel:FindDirect("Group_Change/Group_Name/Img_Label/Label_Num")
  self.m_UIGO.Time = self.m_panel:FindDirect("Group_Change/Group_Time/Label_Time")
  self.m_UIGO.Num1 = self.m_panel:FindDirect("Group_Btn/Btn_Refuse/Label_Num")
  self.m_UIGO.Num2 = self.m_panel:FindDirect("Group_Btn/Btn_Confirm/Label_Num")
  self.m_UIGO.AgreeNum = self.m_panel:FindDirect("Group_Leave/Group_Time/Label_Num")
end
def.method("userdata").UpdatePlayerView = function(self, groupPlayerGO)
  if not self.m_VoteInfo then
    return
  end
  local player = self.m_VoteInfo.playerInfo
  local nameGO = groupPlayerGO:FindDirect("Label_Name")
  local jyNameGO = groupPlayerGO:FindDirect("Label_BadgeName")
  local iconGO = groupPlayerGO:FindDirect("Group_Icon/Icon_Head")
  local spriteName = GUIUtils.GetHeadSpriteNameNoBound(player.menpai, player.gender)
  local title = player.title or ""
  GUIUtils.SetText(nameGO, player.name)
  GUIUtils.SetSprite(iconGO, spriteName)
  GUIUtils.SetText(jyNameGO, title)
end
def.method().Update = function(self)
  if not self.m_VoteInfo then
    return
  end
  local titleGO = self.m_UIGO[("Title%d"):format(self.m_CurState)]
  local timeGO = self.m_UIGO[("Time%d"):format(self.m_CurState)]
  local titleSprite
  local titleString = ""
  local deadLineTime = Int64.ToNumber(self.m_VoteInfo.deadLineTime)
  local timeString = GUIUtils.FormatCountTime(deadLineTime)
  for i = 1, 3 do
    local groupGO = self.m_UIGO[("Group%d"):format(i)]
    GUIUtils.SetActive(groupGO, i == self.m_CurState)
  end
  local num1GO = self.m_UIGO.Num1
  local num2GO = self.m_UIGO.Num2
  do break end
  GUIUtils.SetActive(num1GO, self.m_CurState == VotePanel.PANELSTATE.LEAVE)
  do break end
  GUIUtils.SetActive(num2GO, self.m_CurState == VotePanel.PANELSTATE.LEAVE)
  local titleSpriteGO = self.m_UIGO.Title
  if self.m_CurState == VotePanel.PANELSTATE.ADD then
    local groupPlayerGO = self.m_UIGO.Player1
    self:UpdatePlayerView(groupPlayerGO)
    titleString = textRes.Sworn[45]:format(self.m_VoteInfo.invitename)
    titleSprite = VotePanel.TITLESPRITE.ADD
  elseif self.m_CurState == VotePanel.PANELSTATE.LEAVE then
    local groupPlayerGO = self.m_UIGO.Player2
    local agreeNumGO = self.m_UIGO.AgreeNum
    self:UpdatePlayerView(groupPlayerGO)
    GUIUtils.SetText(agreeNumGO, textRes.Sworn[50]:format(self.m_VoteInfo.agreecount))
    titleString = textRes.Sworn[49]:format(self.m_VoteInfo.rolename)
    titleSprite = VotePanel.TITLESPRITE.LEAVE
  elseif self.m_CurState == VotePanel.PANELSTATE.CHANGE then
    local name1GO = self.m_UIGO.Name1
    local name2GO = self.m_UIGO.Name2
    local numGO = self.m_UIGO.Label
    local count = #SwornMgr.GetSwornMember()
    GUIUtils.SetText(name1GO, self.m_VoteInfo.name1)
    GUIUtils.SetText(name2GO, self.m_VoteInfo.name2)
    GUIUtils.SetText(numGO, SwornMgr.GetNumberDesc(count))
    titleString = textRes.Sworn[46]:format(self.m_VoteInfo.rolename)
    titleSprite = VotePanel.TITLESPRITE.CHANGE
  end
  GUIUtils.SetSprite(titleSpriteGO, titleSprite)
  GUIUtils.SetText(titleGO, titleString)
  GUIUtils.SetText(timeGO, timeString)
  self:RemoveTimer()
  self.m_TimerID = GameUtil.AddGlobalTimer(60, false, function()
    if not timeGO or timeGO.isnil then
      return
    end
    timeString = GUIUtils.FormatCountTime(deadLineTime)
    GUIUtils.SetText(timeGO, timeString)
    if timeString:len() == 0 then
      local agree = CAddNewMemberVoteReq.VOTE_AGREE
      if self.m_CurState == VotePanel.PANELSTATE.LEAVE then
        agree = CAddNewMemberVoteReq.VOTE_NOTAGREE
      end
      self:Vote(agree)
      self:DestroyPanel()
    end
  end)
end
return VotePanel.Commit()
