local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PKMainDlg = Lplus.Extend(ECPanelBase, "PKMainDlg")
local MENPAI = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local def = PKMainDlg.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local PKData = require("Main.PK.data.PKData")
local CommonUISmallTip = require("GUI.CommonUISmallTip")
local TipsHelper = require("Main.Common.TipsHelper")
local ItemModule = require("Main.Item.ItemModule")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local CFlushInActivityReq = require("netio.protocol.mzm.gsp.Team.CFlushInActivityReq")
def.field("number").selectedMenpai = 0
def.field("table").listItems = nil
def.field("number").refreshCd = -1
def.field("number")._timerID = 0
def.field("userdata").mUITeamTypeLabel = nil
def.field("userdata").mUIPointsLabel = nil
def.field("userdata").mUIXingDongLabel = nil
def.field("userdata").mUIShengWangLabel = nil
def.field("userdata").mUITimeLabel = nil
def.field("table").mUIPaiHangList = nil
def.field("table").mUIFriendList = nil
def.field("userdata").mUIPrizeImg1 = nil
def.field("userdata").mUIPrizeImg2 = nil
def.field("number").mActivityID = 0
def.field("number").mServerTime = 0
def.static("=>", PKMainDlg).Instance = function()
  if dlg == nil then
    dlg = PKMainDlg()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.PK, gmodule.notifyId.PK.Show_PK_MainUI, PKMainDlg.OnShowUI)
  Event.RegisterEvent(ModuleId.PK, gmodule.notifyId.PK.Update_PK_ManiUI, PKMainDlg.UpdateUI)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerRes, PKMainDlg.OnGetServerActivityTime)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, PKMainDlg.OnTeamMemberChanged)
  self:InitDlg()
end
def.method().InitDlg = function(self)
  self.mUIPaiHangList = {}
  self.mUIFriendList = {}
  self.mUITeamTypeLabel = self.m_panel:FindDirect("Img_Bg/Group_Info/Btn_Group/Label_Group")
  self.mUIPointsLabel = self.m_panel:FindDirect("Img_Bg/Group_Info/Btn_Score/Label_Score")
  self.mUIXingDongLabel = self.m_panel:FindDirect("Img_Bg/Group_Info/Btn_Action/Label_Action")
  self.mUIShengWangLabel = self.m_panel:FindDirect("Img_Bg/Group_Info/Btn_ShengWang/Label_ShengWang")
  self.mUITimeLabel = self.m_panel:FindDirect("Img_Bg/Group_Rank/Label_Time")
  self.mUIPrizeImg1 = self.m_panel:FindDirect("Img_Bg/Group_Prize/Texture_Prize1")
  self.mUIPrizeImg2 = self.m_panel:FindDirect("Img_Bg/Group_Prize/Texture_Prize2")
  local Group_Rank = self.m_panel:FindDirect("Img_Bg/Group_Rank")
  local Group_Team = self.m_panel:FindDirect("Img_Bg/Group_Team")
  for i = 1, 3 do
    local bg = Group_Rank:FindDirect("Img_Bg" .. tostring(i))
    local label1 = bg:FindDirect("Label_Group")
    local label2 = bg:FindDirect("Label_Score")
    self.mUIPaiHangList[i] = {label1, label2}
  end
  for i = 1, 3 do
    local bg = Group_Team:FindDirect("Img_Bg_TeamMember0" .. tostring(i))
    local MemberInfo = bg:FindDirect("MemberInfo")
    local Img_Invite = bg:FindDirect("Img_Invite")
    local Img_Head = MemberInfo:FindDirect("Img_Head")
    local Label_Name = MemberInfo:FindDirect("Label_Name")
    local Img_School = MemberInfo:FindDirect("Img_School")
    local Label_Lv = MemberInfo:FindDirect("Label_Lv")
    local Img_Leader = MemberInfo:FindDirect("Img_Leader")
    local Img_Sex = MemberInfo:FindDirect("Img_Sex")
    local Img_BgHead = MemberInfo:FindDirect("Img_BgHead")
    self.mUIFriendList[i] = {
      MemberInfo,
      Img_Invite,
      Img_Head,
      Label_Name,
      Img_School,
      Label_Lv,
      Img_Leader,
      Img_Sex,
      Img_BgHead
    }
  end
  self.mActivityID = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "Activityid"):GetIntValue("value")
end
def.method().UpdateInfo = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self:ClearInfo()
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.PK)
  self.mUITeamTypeLabel:GetComponent("UILabel"):set_text(mgr:GetGroupName(PKData.Instance().myInfo.teamType))
  self.mUIPointsLabel:GetComponent("UILabel"):set_text(tostring(PKData.Instance().myInfo.points))
  self.mUIXingDongLabel:GetComponent("UILabel"):set_text(tostring(PKData.Instance().myInfo.xingdong))
  PKData.Instance().myInfo.pkpoint = ItemModule.Instance():GetCredits(TokenType.JINGJICHANG_JIFEN)
  if PKData.Instance().myInfo.pkpoint == nil then
    PKData.Instance().myInfo.pkpoint = 0
  end
  self.mUIShengWangLabel:GetComponent("UILabel"):set_text(tostring(PKData.Instance().myInfo.pkpoint))
  PKData.Instance():SortRankList()
  local rankList = PKData.Instance().TeamList
  for i = 1, #self.mUIPaiHangList do
    if i <= #rankList then
      self.mUIPaiHangList[i][1]:GetComponent("UILabel"):set_text(mgr:GetGroupName(rankList[i].type))
      self.mUIPaiHangList[i][2]:GetComponent("UILabel"):set_text(tostring(rankList[i].points))
    end
  end
  self:ShowTeamMembers()
  local Texture_Icon1 = self.mUIPrizeImg1:GetComponent("UITexture")
  local Texture_Icon2 = self.mUIPrizeImg2:GetComponent("UITexture")
  GUIUtils.SetTextureEffect(Texture_Icon1, GUIUtils.Effect.Normal)
  GUIUtils.SetTextureEffect(Texture_Icon2, GUIUtils.Effect.Normal)
  if PKData.Instance():IsReceiveWinItem(0) then
    GUIUtils.SetTextureEffect(Texture_Icon1, GUIUtils.Effect.Gray)
    GUIUtils.SetLightEffect(self.mUIPrizeImg1, GUIUtils.Light.None)
  elseif PKData.Instance().myInfo.winCount >= PKData.Instance().mWin1 then
    GUIUtils.SetLightEffect(self.mUIPrizeImg1, GUIUtils.Light.Round)
  end
  if PKData.Instance():IsReceiveWinItem(1) then
    GUIUtils.SetTextureEffect(Texture_Icon2, GUIUtils.Effect.Gray)
    GUIUtils.SetLightEffect(self.mUIPrizeImg2, GUIUtils.Light.None)
  elseif PKData.Instance().myInfo.winCount >= PKData.Instance().mWin2 then
    GUIUtils.SetLightEffect(self.mUIPrizeImg2, GUIUtils.Light.Round)
  end
end
def.method().ShowTeamMembers = function(self)
  if self.mUIFriendList == nil then
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  for i = 1, #self.mUIFriendList do
    self.mUIFriendList[i][1]:SetActive(false)
    self.mUIFriendList[i][2]:SetActive(true)
    self.mUIFriendList[i][7]:SetActive(false)
    if teamData:HasTeam() then
      if i <= #members then
        local member = members[i]
        local name = member.name
        local mengpai = member.menpai
        local lv = member.level
        local meipaiIconName = GUIUtils.GetOccupationSmallIcon(mengpai)
        self.mUIFriendList[i][1]:SetActive(true)
        self.mUIFriendList[i][2]:SetActive(false)
        _G.SetAvatarFrameIcon(self.mUIFriendList[i][9], member.avatarFrameid)
        _G.SetAvatarIcon(self.mUIFriendList[i][3], member.avatarId, member.avatarFrameId)
        GUIUtils.SetSprite(self.mUIFriendList[i][8], GUIUtils.GetSexIcon(members[i].gender))
        self.mUIFriendList[i][5]:GetComponent("UISprite").spriteName = meipaiIconName
        self.mUIFriendList[i][4]:GetComponent("UILabel"):set_text(name)
        self.mUIFriendList[i][6]:GetComponent("UILabel"):set_text(tostring(lv))
        if i == 1 then
          self.mUIFriendList[i][7]:SetActive(true)
        end
      end
    elseif i == 1 then
      self.mUIFriendList[1][1]:SetActive(true)
      self.mUIFriendList[i][2]:SetActive(false)
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      local meipaiIconName = GUIUtils.GetOccupationSmallIcon(heroProp.occupation)
      GUIUtils.SetSprite(self.mUIFriendList[1][8], GUIUtils.GetSexIcon(heroProp.gender))
      _G.SetAvatarFrameIcon(self.mUIFriendList[1][9])
      _G.SetAvatarIcon(self.mUIFriendList[1][3], nil, 0)
      self.mUIFriendList[1][5]:GetComponent("UISprite").spriteName = meipaiIconName
      self.mUIFriendList[1][4]:GetComponent("UILabel"):set_text(heroProp.name)
      self.mUIFriendList[1][6]:GetComponent("UILabel"):set_text(tostring(heroProp.level))
    end
  end
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_PK_MAIN_PANEL, 0)
  self:SetModal(true)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PK, gmodule.notifyId.PK.Show_PK_MainUI, PKMainDlg.OnShowUI)
  Event.UnregisterEvent(ModuleId.PK, gmodule.notifyId.PK.Update_PK_ManiUI, PKMainDlg.UpdateUI)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerRes, PKMainDlg.OnGetServerActivityTime)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, PKMainDlg.OnTeamMemberChanged)
end
def.static("table", "table").OnTeamMemberChanged = function(p1, p2)
  dlg:ShowTeamMembers()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  dlg:Hide()
end
def.static().OnLeavePK = function()
  dlg:Hide()
  Event.DispatchEvent(ModuleId.PK, gmodule.notifyId.PK.Hide_Pk_Menu, {0})
end
def.static("table", "table").OnShowUI = function(p1, p2)
  dlg:ShowDlg()
end
def.static("table", "table").UpdateUI = function(p1, p2)
  dlg:UpdateInfo()
end
def.method("number").DoTeamOper = function(self, index)
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  local memberCount = #members
  if memberCount >= 3 then
    Toast(textRes.PVP[27])
    return
  end
  if index == 1 then
    if teamData:MeIsCaptain() == false or memberCount <= 0 then
      gmodule.network.sendProtocol(CFlushInActivityReq.new(CFlushInActivityReq.FIND_TEAM))
    elseif teamData:MeIsCaptain() == true and memberCount > 0 then
      gmodule.network.sendProtocol(CFlushInActivityReq.new(CFlushInActivityReq.FIND_MEMBER))
    end
  elseif index == 2 then
    if teamData:MeIsCaptain() == true then
      gmodule.network.sendProtocol(CFlushInActivityReq.new(CFlushInActivityReq.FIND_MEMBER))
    elseif memberCount <= 0 then
      gmodule.network.sendProtocol(CFlushInActivityReq.new(CFlushInActivityReq.FIND_TEAM))
    else
      Toast(textRes.TeamPVP[1])
    end
  elseif index == 3 then
    if teamData:MeIsCaptain() == true then
      gmodule.network.sendProtocol(CFlushInActivityReq.new(CFlushInActivityReq.FIND_MEMBER))
    elseif memberCount <= 0 then
      gmodule.network.sendProtocol(CFlushInActivityReq.new(CFlushInActivityReq.FIND_TEAM))
    else
      Toast(textRes.TeamPVP[1])
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Refresh" then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.arena.CCampsInfoReq").new())
  elseif id == "Texture_Prize1" then
    if PKData.Instance():IsReceiveWinItem(0) then
      Toast(textRes.PVP3GetItem[2])
      return
    elseif PKData.Instance().myInfo.winCount < PKData.Instance().mWin1 then
      Toast(textRes.PVP3GetItem[1])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.arena.CWinTimesAwardReq").new(0))
  elseif id == "Texture_Prize2" then
    if PKData.Instance():IsReceiveWinItem(1) then
      Toast(textRes.PVP3GetItem[2])
      return
    elseif PKData.Instance().myInfo.winCount < PKData.Instance().mWin2 then
      Toast(textRes.PVP3GetItem[1])
      return
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.arena.CWinTimesAwardReq").new(1))
  elseif id == "Img_Bg_TeamMember01" then
    self:DoTeamOper(3)
  elseif id == "Img_Bg_TeamMember02" then
    self:DoTeamOper(2)
  elseif id == "Img_Bg_TeamMember03" then
    self:DoTeamOper(1)
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local p = require("netio.protocol.mzm.gsp.arena.CCampsInfoReq").new()
  gmodule.network.sendProtocol(p)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_QueryEndingTimeFromServerReq, {
    self.mActivityID
  })
  self:UpdateInfo()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method().ClearInfo = function(self)
  self.mUITimeLabel = self.m_panel:FindDirect("Img_Bg/Group_Rank/Label_Time")
  self.mUITimeLabel:GetComponent("UILabel"):set_text("")
end
def.method("string", "boolean").onPress = function(self, id, state)
  self:OnAttrTipPressed(id, state)
end
def.method("string", "boolean").OnAttrTipPressed = function(self, index, state)
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local label = self.m_panel:FindDirect("Img_Bg/Group_Info/" .. index .. "/Label_Title")
  if label == nil then
    return
  end
  local tipId = 1
  if index == "Btn_Group" then
    tipId = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "CampTip"):GetIntValue("value")
  elseif index == "Btn_Score" then
    tipId = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "ScoreTip"):GetIntValue("value")
  elseif index == "Btn_Action" then
    tipId = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "ActionPointTip"):GetIntValue("value")
  elseif index == "Btn_ShengWang" then
    tipId = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "FameTip"):GetIntValue("value")
  else
    tipId = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "ActivityTip"):GetIntValue("value")
  end
  local position = label:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = label:GetComponent("UIWidget")
  local tipContent = TipsHelper.GetHoverTip(tipId)
  CommonUISmallTip.Instance():ShowTip(tipContent, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1)
end
def.static("table", "table").OnGetServerActivityTime = function(p1, p2)
  local activityId = p1[1]
  local ActivityID = DynamicData.GetRecord(CFG_PATH.DATA_PK3V3_CONST_CFG, "Activityid"):GetIntValue("value")
  if activityId == ActivityID then
    dlg.mServerTime = p1[2]
    dlg:_FillTime()
  end
end
def.method("number", "=>", "string").ConverTime = function(self, time)
  local hour = math.floor(time / 3600)
  local min = math.floor(time % 3600 / 60)
  local sec = math.floor(time % 60)
  local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
  return timeStr
end
def.method()._FillTime = function(self)
  if self._timerID > 0 then
    return
  end
  local enddingTimeInSec = self.mServerTime
  local leftTime = enddingTimeInSec - GetServerTime()
  PKData.Instance().activityTime = leftTime
  local timeStr = self:ConverTime(leftTime)
  local Label_Time = self.mUITimeLabel
  if Label_Time ~= nil and not Label_Time.isnil then
    Label_Time:GetComponent("UILabel"):set_text(timeStr)
  end
  local function OnTimer()
    PKData.Instance().activityTime = PKData.Instance().activityTime - 0.1
    if PKData.Instance().activityTime <= 0 then
      GameUtil.RemoveGlobalTimer(self._timerID)
      self._timerID = 0
    end
    local nowSec = PKData.Instance().activityTime
    local hour = math.floor(nowSec / 3600)
    local min = math.floor(nowSec % 3600 / 60)
    local sec = math.floor(nowSec % 60)
    local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    if self.mUITimeLabel ~= nil and not self.mUITimeLabel.isnil then
      self.mUITimeLabel:GetComponent("UILabel"):set_text(timeStr)
    end
  end
  self._timerID = GameUtil.AddGlobalTimer(0.1, false, OnTimer)
end
PKMainDlg.Commit()
return PKMainDlg
