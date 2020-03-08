local Lplus = require("Lplus")
local Protocol = require("Protocol.Protocol")
local ProtocolManager = require("Protocol.ProtocolManager")
do
  local playerLogout = require("Protocol.PlayerLogout")
  local ECGame = Lplus.ForwardDeclare("ECGame")
  local PLAYER_LOGOUT_STYLE = {
    PLAYER_LOGOUT_FULL = 0,
    PLAYER_LOGOUT_HALF = 1,
    PLAYER_LOGOUT_ZONE = 2,
    PLAYER_LOGOUT_DISCONNECT = 3
  }
  ProtocolManager.AddHandler(playerLogout, function(sender, self)
    local ECGame = Lplus.ForwardDeclare("ECGame")
    local game = ECGame.Instance()
    if self.result == PLAYER_LOGOUT_STYLE.PLAYER_LOGOUT_FULL then
      if platform == 2 then
        local ECProxySDK = require("ProxySDK.ECProxySDK")
        ECProxySDK.Instance():UserLogOut()
        ECProxySDK.Instance():SetUpUser()
      end
      game.m_Network:Close()
      game:halfrelease()
      game:Start()
      LoginPlatform = MSDK_LOGIN_PLATFORM.NON
    elseif self.result == PLAYER_LOGOUT_STYLE.PLAYER_LOGOUT_HALF then
      local panelchangerole = require("GUI.ECPanelChangeRole")
      game:ChangeRole(panelchangerole.Instance().candidate)
    end
  end)
end
do
  local RoleList = require("Protocol.RoleList")
  local AnnounceChannelID = require("Protocol.AnnounceChannelID")
  local ECMSDK = require("ProxySDK.ECMSDK")
  local ECGame = Lplus.ForwardDeclare("ECGame")
  local OnlineAnnounce = require("Protocol.OnlineAnnounce")
  ProtocolManager.AddHandler(OnlineAnnounce, function(sender, self)
    local game = ECGame.Instance()
    local network = game.m_Network
    if LoginPlatform == MSDK_LOGIN_PLATFORM.QQ or LoginPlatform == MSDK_LOGIN_PLATFORM.WX or LoginPlatform == MSDK_LOGIN_PLATFORM.GUEST then
      local ac = AnnounceChannelID()
      ac.account = self.account
      local channel = ECMSDK.GetChannelID()
      local os = Octets.Octets()
      os:setStringUnicode(channel)
      ac.channel = os
      network:SendProtocol(ac)
      warn("Send Proxy ID", ECMSDK.GetChannelID())
    end
    local rl = RoleList()
    rl.account = self.account
    rl.nextid = -1
    game.m_rolelist = {}
    network:SetAccount(rl.account)
    network:SendProtocol(rl)
  end)
end
do
  local ECGame = Lplus.ForwardDeclare("ECGame")
  local GamedataSend = require("Protocol.GamedataSend")
  ProtocolManager.AddHandler(GamedataSend, function(sender, self)
    ECGame.Instance().m_Network:ProcessGameData(self)
  end)
end
do
  local ECGame = Lplus.ForwardDeclare("ECGame")
  local FinishLoading = require("Protocol.FinishLoading")
  local SelectRole_Re = require("Protocol.SelectRole_Re")
  ProtocolManager.AddHandler(SelectRole_Re, function(sender, self)
    if self.result == 0 then
      local game = ECGame.Instance()
      local fl = FinishLoading()
      fl.roleid = game.m_HostInfo.id
      fl.islogin = 0
      game.m_Network:SendProtocol(fl)
      print("SelectRole_Re Process")
    elseif self.result == 31 then
      if retcode == MsgBoxRetT.MBRT_OK then
        local SelectRole = require("Protocol.SelectRole")
        local ECGame = Lplus.ForwardDeclare("ECGame")
        local game = ECGame.Instance()
        local rl = SelectRole()
        rl.roleid = game.m_HostInfo.id
        rl.trustor_roleid = LuaUInt64.Make(0, 0)
        rl.login_mask = 2
        game.m_Network:SendProtocol(rl)
        print(LuaUInt64.ToString(rl.roleid))
      end
    elseif self.result == 208 then
      MsgBox.ShowMsgBox(nil, StringTable.Get(2601), nil, MsgBoxType.MBBT_OK, nil)
      local game = ECGame.Instance()
      game.m_Network:Close()
    else
      print(self.result)
    end
  end)
end
do
  local SelectRole = require("Protocol.SelectRole")
  local ECGame = Lplus.ForwardDeclare("ECGame")
  local RoleList_Re = require("Protocol.RoleList_Re")
  ProtocolManager.AddHandler(RoleList_Re, function(sender, self)
    local game = ECGame.Instance()
    if self.roleinfo.id == ZeroUInt64 then
      if game.m_CandidateHostID == ZeroUInt64 then
        game.m_GUIMan:OnCreateCharacter()
        return
      end
    else
      game.m_rolelist[#game.m_rolelist + 1] = self.roleinfo
      if self.nextid ~= NegativeOneInt64 then
        local RoleList = require("Protocol.RoleList")
        local rl = RoleList()
        rl.account = self.account
        rl.nextid = 1
        local network = ECGame.Instance().m_Network
        network:SendProtocol(rl)
        return
      end
    end
    local roleid = ZeroUInt64
    if game.m_CandidateHostID ~= ZeroUInt64 then
      for i, v in ipairs(game.m_rolelist) do
        if v.id == game.m_CandidateHostID then
          roleid = v.id
          game.m_HostInfo = v
          break
        end
      end
    end
    if roleid == ZeroUInt64 then
      local ECPanelRoleChoose = require("GUI.ECPanelRoleChoose")
      ECPanelRoleChoose.Instance():ShowPanel()
    else
      local rl = SelectRole()
      rl.roleid = roleid
      rl.trustor_roleid = LuaUInt64.Make(0, 0)
      rl.login_mask = 0
      game.m_Network:SendProtocol(rl)
    end
  end)
end
do
  local ErrorInfo = require("Protocol.ErrorInfo")
  ProtocolManager.AddHandler(ErrorInfo, function(sender, self)
    _G.LastErrorCode = self.errcode
  end)
end
do
  local ForceLogout = require("Protocol.ForceLogout")
  ProtocolManager.AddHandler(ForceLogout, function(sender, self)
    local msg = string.format(StringTable.Get(803))
    MsgBox.ShowMsgBox(nil, msg, StringTable.Get(801), MsgBox.MsgBoxType.MBBT_OK)
  end)
end
do
  local ERROR_PLAYER_OFFLINE = 301
  local ServerMessage = require("Protocol.ServerMessage")
  ProtocolManager.AddHandler(ServerMessage, function(sender, self)
    if self.errcode == ERROR_PLAYER_OFFLINE then
      FlashTipMan.FlashTip(StringTable.Get(1125))
      local ECRecordTip = require("Chat.ECRecordTip")
      local ECChatManager = require("Chat.ECChatManager")
      if ECChatManager.Instance().mLastMsgId ~= 0 and ECChatManager.Instance().mLastMsgId == ECRecordTip.Instance().mMsgId then
        ECRecordTip.Instance():Popup(RecordStatus.SendFailure)
        ECChatManager.Instance().mLastMsgId = 0
      else
        ECRecordTip.Instance():WaitToClose(0)
      end
    end
  end)
end
do
  local AnnounceForbidInfo = require("Protocol.AnnounceForbidInfo")
  local ECGame = Lplus.ForwardDeclare("ECGame")
  ProtocolManager.AddHandler(AnnounceForbidInfo, function(sender, self)
    print("================== AnnounceForbidInfo", self.forbid.createtime, self.forbid.time)
    local account = self.account
    local rf = self.forbid
    local disconnect = self.disconnect
    local reason = rf.reason:getStringUnicode()
    local str1, str2, str3, str
    if rf.type == Forbid.FBD_FORBID_SELLPTS then
      return
    elseif rf.type == Forbid.FBD_FORBID_LOGIN then
      str = ""
      if reason:len() ~= 0 then
        str = reason
      end
      str3 = string.format(StringTable.Get(8800), (rf.time + 59) / 60)
      MsgBox.ShowMsgBox(nil, str, str3, MsgBox.MsgBoxType.MBBT_CANCEL)
      return
    elseif rf.type == Forbid.FBD_FORBID_TALK then
      str1 = StringTable.Get(8802)
      ECGame.Instance():ForbidTalk(rf.createtime, rf.time, reason)
    elseif rf.type == Forbid.FBD_FORBID_TRADE then
      str1 = StringTable.Get(8803)
    elseif rf.type == Forbid.FBD_FORBID_SELL then
      str1 = StringTable.Get(8804)
    end
    if reason:len() ~= 0 then
      str = reason
      str2 = string.format(StringTable.Get(8805), str)
    else
      str2 = StringTable.Get(8805)
    end
    str3 = string.format(StringTable.Get(8800), (rf.time + 59) / 60)
    if str2 ~= "" then
      str = str1 .. "\r" .. str2 .. "\r" .. str3
    else
      str = str1 .. "\r" .. str3
    end
    MsgBox.ShowMsgBox(nil, str, "", MsgBox.MsgBoxType.MBBT_CANCEL)
  end)
end
do
  local ECNationMan = require("Social.ECNationMan")
  do
    local GetNationInfo_Re = require("Protocol.GetNationInfo_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(GetNationInfo_Re, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
      ECNationMan.Instance():BroadcastNationWarEvt()
    end)
  end
  do
    local NationAllianceChangeNotify = require("Protocol.NationAllianceChangeNotify")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(NationAllianceChangeNotify, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
    end)
  end
  do
    local NationAllianceChangeNotify = require("Protocol.NationAllianceChangeNotify")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(NationAllianceChangeNotify, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
    end)
  end
  do
    local NationAnnounceChangeNotify = require("Protocol.NationAnnounceChangeNotify")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(NationAnnounceChangeNotify, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
    end)
  end
  do
    local NationAppoint_Re = require("Protocol.NationAppoint_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(NationAppoint_Re, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
    end)
  end
  do
    local NationPeopleSearch_Re = require("Protocol.NationPeopleSearch_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(NationPeopleSearch_Re, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
    end)
  end
  do
    local GetNationRelations_Re = require("Protocol.GetNationRelations_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(GetNationRelations_Re, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
      ECNationMan.Instance():BroadcastNationWarEvt()
    end)
  end
  do
    local PlayerChangeNation_Re = require("Protocol.PlayerChangeNation_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(PlayerChangeNation_Re, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
    end)
  end
  do
    local NotifyNationWar_Re = require("Protocol.GetNationWarInfo_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(NotifyNationWar_Re, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
      ECNationMan.Instance():BroadcastNationWarEvt()
    end)
  end
  do
    local DeclareNationWar_Re = require("Protocol.ChallengeNationWar_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(DeclareNationWar_Re, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
    end)
  end
  do
    local NationAllianceChange_Re = require("Protocol.NationAllianceChange_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(NationAllianceChange_Re, function(sender, self)
      ECGame.EventManager:raiseEvent(nil, self)
    end)
  end
  local NationWarAwardNotify = require("Protocol.NationWarAwardNotify")
  local ECGame = Lplus.ForwardDeclare("ECGame")
  ProtocolManager.AddHandler(NationWarAwardNotify, function(sender, self)
    local panel = require("GUI.ECPanelNationWarAccount")
    panel.Instance():onRespondAward(sender, self)
  end)
end
do
  local MingxingGetInfo_Re = require("Protocol.MingxingGetInfo_Re")
  ProtocolManager.AddHandler(MingxingGetInfo_Re, function(sender, self)
    local NationMan = require("Social.ECNationMan")
    NationMan.Instance():onrespond_mingxinginfo(sender, self)
  end)
end
do
  local SelectRole = require("Protocol.SelectRole")
  local ECGame = Lplus.ForwardDeclare("ECGame")
  local CreateRole_Re = require("Protocol.CreateRole_Re")
  ProtocolManager.AddHandler(CreateRole_Re, function(sender, self)
    print("Protocol.CreateRole_Re Process", self.result)
    local game = ECGame.Instance()
    if self.result == 0 then
      local rl = SelectRole()
      game.m_HostInfo = self.roleinfo
      rl.roleid = self.roleinfo.id
      rl.trustor_roleid = LuaUInt64.Make(0, 0)
      rl.login_mask = 0
      game.m_Network:SendProtocol(rl)
    else
      local msg = ErrorDS[self.result]
      msg = msg or tostring(self.result)
      MsgBox.ShowMsgBox(nil, msg, nil, MsgBox.MsgBoxType.MBBT_OK)
    end
  end)
end
do
  local ECRankDataMan = require("Main.ECRankDataMan")
  do
    local GetRankInfo_Re = require("Protocol.GetRankInfo_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(GetRankInfo_Re, function(sender, self)
      ECRankDataMan.Instance():OnPrtc_GetRankInfoRe(self)
    end)
  end
  do
    local NoticeSelfRankData = require("Protocol.NoticeSelfRankData")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(NoticeSelfRankData, function(sender, self)
      ECRankDataMan.Instance():OnPrtc_NoticeSelfRankData(self)
    end)
  end
  do
    local GetTopList_Re = require("Protocol.GetTopList_Re")
    local ECGame = Lplus.ForwardDeclare("ECGame")
    ProtocolManager.AddHandler(GetTopList_Re, function(sender, self)
      ECRankDataMan.Instance():OnPrtc_GetTopListRe(self)
    end)
  end
  local GetMultiTopList_Re = require("Protocol.GetMultiTopList_Re")
  local ECGame = Lplus.ForwardDeclare("ECGame")
  ProtocolManager.AddHandler(GetMultiTopList_Re, function(snder, self)
    ECRankDataMan.Instance():OnPrtc_GetMultiTopListRe(self)
  end)
end
do
  local ECChatManager = require("Chat.ECChatManager")
  local ChatPublic = require("Protocol.ChatPublic")
  ProtocolManager.AddHandler(ChatPublic, function(sender, self)
    ECChatManager.Instance():OnPrtc_ChatPublic(self)
  end)
  local ChatPrivate = require("Protocol.ChatPrivate")
  ProtocolManager.AddHandler(ChatPrivate, function(sender, self)
    ECChatManager.Instance():OnPrtc_ChatPrivate(self)
  end)
  local VoiceChat = require("Protocol.VoiceChat")
  ProtocolManager.AddHandler(VoiceChat, function(sender, self)
    print("Recv VoiceChat")
  end)
  local PlayerMessage = require("Protocol.PlayerMessage")
  ProtocolManager.AddHandler(PlayerMessage, function(sender, self)
    print("Recv PlayerMessage")
  end)
end
do
  local SystemSpeak = require("Protocol.SystemSpeak")
  ProtocolManager.AddHandler(SystemSpeak, function(sender, p)
    local ECSystemSpeak = require("Chat.ECSystemSpeak")
    ECSystemSpeak.OnSystemSpeak(p.speak_id, p.msg, p.content_idx + 1, p.channel, nil)
  end)
end
do
  local function TeamMgr()
    local ECGame = Lplus.ForwardDeclare("ECGame")
    return ECGame.Instance().m_TeamMan
  end
  local TeamList = require("Protocol.TeamList")
  ProtocolManager.AddHandler(TeamList, function(sender, self)
    TeamMgr():OnPrtc_TeamList(self)
  end)
  local TeamLeave = require("Protocol.TeamLeave")
  ProtocolManager.AddHandler(TeamLeave, function(sender, self)
    TeamMgr():OnPrtc_TeamLeave(self)
  end)
  local TeamAbdicate = require("Protocol.TeamAbdicate")
  ProtocolManager.AddHandler(TeamAbdicate, function(sender, self)
    TeamMgr():OnPrtc_TeamChangeLeader(self)
  end)
  local TeamSetRule = require("Protocol.TeamSetRule")
  ProtocolManager.AddHandler(TeamSetRule, function(sender, self)
    TeamMgr():OnPrtc_TeamSetRule(self)
  end)
  local TeamInform = require("Protocol.TeamInform")
  ProtocolManager.AddHandler(TeamInform, function(sender, self)
    TeamMgr():OnPrtc_TeamInform(self)
  end)
  local TeamRecruit_Re = require("Protocol.TeamRecruit_Re")
  ProtocolManager.AddHandler(TeamRecruit_Re, function(sender, self)
    TeamMgr():OnPrtc_TeamPublishRe(self)
  end)
  local TeamInstance = require("Protocol.TeamInstance")
  ProtocolManager.AddHandler(TeamInstance, function(sender, self)
    TeamMgr():OnPrtc_TeamInstance(self)
  end)
  local VoteRequest = require("Protocol.VoteRequest")
  ProtocolManager.AddHandler(VoteRequest, function(sender, self)
    if self.votetype == 0 then
      local weddingpanel = require("GUI.ECPanelWedding")
      local panel = weddingpanel.Instance()
      panel:ShowPanel(true)
      local os = OctetsStream.OctetsStream2(self.arg)
      panel:SetInfo(self.voteid, os:unmarshal_long(), os:unmarshal_long())
    elseif self.votetype == 12 then
    end
    TeamMgr():OnPrtc_TeamVote(self)
  end)
  local GetAmityMin_Re = require("Protocol.GetAmityMin_Re")
  ProtocolManager.AddHandler(GetAmityMin_Re, function(sender, self)
    TeamMgr():OnPrtc_GetAmityMinRe(self)
  end)
  local TeamMatch_Re = require("Protocol.TeamMatch_Re")
  ProtocolManager.AddHandler(TeamMatch_Re, function(sender, self)
    TeamMgr():OnPrtc_TeamMatchRe(self)
  end)
  local TeamApplyRe = require("Protocol.TeamApplyRe")
  ProtocolManager.AddHandler(TeamApplyRe, function(sender, self)
    TeamMgr():OnPrtc_TeamApplyRe(self)
  end)
  local MatchAdd_Re = require("Protocol.MatchAdd_Re")
  ProtocolManager.AddHandler(MatchAdd_Re, function(sender, self)
    TeamMgr():OnPrtc_MatchAddRe(self)
  end)
  local MatchInfo = require("Protocol.MatchInfo")
  ProtocolManager.AddHandler(MatchInfo, function(sender, self)
    TeamMgr():OnPrtc_MatchInfo(self)
  end)
  local MatchQuit_Re = require("Protocol.MatchQuit_Re")
  ProtocolManager.AddHandler(MatchQuit_Re, function(sender, self)
    TeamMgr():OnPrtc_MatchQuitRe(self)
  end)
  local MatchInvite = require("Protocol.MatchInvite")
  ProtocolManager.AddHandler(MatchInvite, function(sender, self)
    TeamMgr():OnPrtc_MatchInvite(self)
  end)
  local MatchRestart = require("Protocol.MatchRestart")
  ProtocolManager.AddHandler(MatchRestart, function(sender, self)
    TeamMgr():OnPrtc_MatchRestart(self)
  end)
  local MatchSucceed = require("Protocol.MatchSucceed")
  ProtocolManager.AddHandler(MatchSucceed, function(sender, self)
    TeamMgr():OnPrtc_MatchSucceed(self)
  end)
  local GetPlayerTeamInfoRe = require("Protocol.GetPlayerTeamInfoRe")
  ProtocolManager.AddHandler(GetPlayerTeamInfoRe, function(sender, self)
    TeamMgr():OnPrtc_GetPlayerTeamInfoRe(self)
  end)
end
do
  local ECMailMan = require("Social.ECMailMan")
  local MailGetRe = require("Protocol.MailGetRe")
  ProtocolManager.AddHandler(MailGetRe, function(sender, self)
    ECMailMan.Instance():OnPrtc_MailGet(self)
  end)
  local MailListRe = require("Protocol.MailListRe")
  ProtocolManager.AddHandler(MailListRe, function(sender, self)
    ECMailMan.Instance():OnPrtc_MailListGet(self)
  end)
  local MailReceiveRe = require("Protocol.MailReceiveRe")
  ProtocolManager.AddHandler(MailReceiveRe, function(sender, self)
    ECMailMan.Instance():OnPtrc_ReturnAttachment(self)
  end)
  local MailUpdateRe = require("Protocol.MailUpdateRe")
  ProtocolManager.AddHandler(MailUpdateRe, function(sender, self)
    ECMailMan.Instance():OnPtrc_UpdateMail(self)
  end)
end
do
  local ECFriendMan = require("Social.ECFriendMan")
  local FriendList = require("Protocol.FriendList")
  ProtocolManager.AddHandler(FriendList, function(sender, self)
    ECFriendMan.Instance():OnPrtc_FriendList(self)
  end)
  local FriendAddRe = require("Protocol.FriendAddRe")
  ProtocolManager.AddHandler(FriendAddRe, function(sender, self)
    ECFriendMan.Instance():OnPrtc_FriendAddRe(self)
  end)
  local FriendDelete = require("Protocol.FriendDelete")
  ProtocolManager.AddHandler(FriendDelete, function(sender, self)
    ECFriendMan.Instance():OnPrtc_FriendDelete(self)
  end)
  local FriendStatus = require("Protocol.FriendStatus")
  ProtocolManager.AddHandler(FriendStatus, function(sender, self)
    ECFriendMan.Instance():OnPrtc_FriendStatus(self)
  end)
  local EnemyListRe = require("Protocol.EnemyListRe")
  ProtocolManager.AddHandler(EnemyListRe, function(sender, self)
    ECFriendMan.Instance():OnPrtc_EnemyList(self)
  end)
  local BlackListAddRe = require("Protocol.BlackListAddRe")
  ProtocolManager.AddHandler(BlackListAddRe, function(sender, self)
    ECFriendMan.Instance():OnPrtc_BlackAddRe(self)
  end)
  local BlackListDelete = require("Protocol.BlackListDelete")
  ProtocolManager.AddHandler(BlackListDelete, function(sender, self)
    ECFriendMan.Instance():OnPrtc_BlacklistDelete(self)
  end)
end
do
  local ECArenaMan = require("Social.ECArenaMan")
  local GetRankInfo_Re = require("Protocol.GetRankInfo_Re")
  ProtocolManager.AddHandler(GetRankInfo_Re, function(sender, self)
    ECArenaMan.Instance():onS2C_GetRankInfo(self)
  end)
  local GetChallengeInfo_Re = require("Protocol.GetChallengeInfo_Re")
  ProtocolManager.AddHandler(GetChallengeInfo_Re, function(sender, self)
    ECArenaMan.Instance():onS2C_GetChallengeInfo(self)
  end)
  local FightPlayer_Re = require("Protocol.FightPlayer_Re")
  ProtocolManager.AddHandler(FightPlayer_Re, function(sender, self)
    ECArenaMan.Instance():onS2C_FightPlayer(self)
  end)
  local GetPlayerFightInfo_Re = require("Protocol.GetPlayerFightInfo_Re")
  ProtocolManager.AddHandler(GetPlayerFightInfo_Re, function(sender, self)
    ECArenaMan.Instance():onS2C_GetPlayerFightInfo(self)
  end)
  local GetPlayerFightRecord_Re = require("Protocol.GetPlayerFightRecord_Re")
  ProtocolManager.AddHandler(GetPlayerFightRecord_Re, function(sender, self)
    ECArenaMan.Instance():onS2C_GetPlayerFightRecord(self)
  end)
  local GetRankReward_Re = require("Protocol.GetRankReward_Re")
  ProtocolManager.AddHandler(GetRankReward_Re, function(sender, self)
    ECArenaMan.Instance():onS2C_GetRankReward(self)
  end)
  local FightPlayerResult = require("Protocol.FightPlayerResult")
  ProtocolManager.AddHandler(FightPlayerResult, function(sender, self)
    ECArenaMan.Instance():onS2C_FightPlayerResult(self)
  end)
end
do
  local ECAuctionMan = require("Main.ECAuctionMan")
  local NewAuctionOpen_Re = require("Protocol.NewAuctionOpen_Re")
  ProtocolManager.AddHandler(NewAuctionOpen_Re, function(sender, self)
    ECAuctionMan.Instance():OnPrtc_NewAuctionOpenRe(self)
  end)
  local NewAuctionList_Re = require("Protocol.NewAuctionList_Re")
  ProtocolManager.AddHandler(NewAuctionList_Re, function(sender, self)
    ECAuctionMan.Instance():OnPrtc_NewAuctionListRe(self)
  end)
  local NewAuctionGet_Re = require("Protocol.NewAuctionGet_Re")
  ProtocolManager.AddHandler(NewAuctionGet_Re, function(sender, self)
    ECAuctionMan.Instance():OnPrtc_NewAuctionGetRe(self)
  end)
  local NewAuctionAttendList_Re = require("Protocol.NewAuctionAttendList_Re")
  ProtocolManager.AddHandler(NewAuctionAttendList_Re, function(sender, self)
    ECAuctionMan.Instance():OnPrtc_NewAuctionAttendListRe(self)
  end)
  local NewAuctionBuy_Re = require("Protocol.NewAuctionBuy_Re")
  ProtocolManager.AddHandler(NewAuctionBuy_Re, function(sender, self)
    ECAuctionMan.Instance():OnPrtc_NewAuctionBuyRe(self)
  end)
  local NewAuctionClose_Re = require("Protocol.NewAuctionClose_Re")
  ProtocolManager.AddHandler(NewAuctionClose_Re, function(sender, self)
    ECAuctionMan.Instance():OnPrtc_NewAuctionCloseRe(self)
  end)
  local MarriageInform = require("Protocol.MarriageInform")
  ProtocolManager.AddHandler(MarriageInform, function(sender, self)
    if self.msgtype == 1 then
      local ret = self.result
      if ret == 0 then
        FlashTipMan.FlashTip("marriage request success")
      elseif ret == 420 then
        FlashTipMan.FlashTip("too far too marry")
      elseif ret == 421 then
        FlashTipMan.FlashTip("not team leader")
      elseif ret == 422 then
        FlashTipMan.FlashTip("someone disagree")
      else
        FlashTipMan.FlashTip(tostring(ret))
      end
    else
      local ret = self.result
      if ret == 0 then
        FlashTipMan.FlashTip("divorce request success")
      elseif ret == 420 then
        FlashTipMan.FlashTip("too far too marry")
      elseif ret == 421 then
        FlashTipMan.FlashTip("not team leader")
      elseif ret == 422 then
        FlashTipMan.FlashTip("someone disagree")
      else
        FlashTipMan.FlashTip(tostring(ret))
      end
    end
  end)
end
do
  local ECGame = Lplus.ForwardDeclare("ECGame")
  local ECProxySDK = require("ProxySDK.ECProxySDK")
  local ApplyAddCash_Re = require("Protocol.ApplyAddCash_Re")
  ProtocolManager.AddHandler(ApplyAddCash_Re, function(sender, self)
    warn("ApplyAddCash_Re........", self.retcode, LuaUInt64.ToString(self.roleid))
    if self.retcode == 0 and self.roleid == ECGame.Instance().m_HostPlayer.ID then
      warn("Other Info", LuaUInt64.ToString(self.amount), self.localsid)
      local fee = LuaUInt64.ToString(self.amount)
      local appOrder = self.appOrder:getBytes()
      local useData = self.server_use_data:getBytes()
      local callBackURL = self.callback_url:getBytes()
      local productid = self.productid:getBytes()
      warn("fee:", fee, type(fee))
      warn("productid:", type(productid), #productid, productid)
      warn("useData:", type(useData), #useData, useData)
      warn("callBackURL:", type(callBackURL), #callBackURL, callBackURL)
      warn("appOrder", appOrder, type(appOrder))
      if platform ~= 0 then
        local proxySDKInstance = ECProxySDK.Instance()
        local info = ECGame.Instance().m_HostPlayer.InfoData
        local extInfo = string.format("{\"roleid\":\"%s\",\"rolename\":\"%s\",\"rolelv\":\"%d\"}", LuaUInt64.ToString(self.roleid), info.Name, info.Lv)
        warn("extUserInfo:", extInfo)
        proxySDKInstance:Payment(productid, tonumber(fee), appOrder, callBackURL, extInfo)
      end
    end
  end)
end
do
  local ECGame = Lplus.ForwardDeclare("ECGame")
  local LinkdPing = require("Protocol.LinkdPing")
  ProtocolManager.AddHandler(LinkdPing, function(sender, self)
    local game = ECGame.Instance()
    if self.client_send_time == game.mLastCheckTime then
      local cur_time = math.fmod(math.floor(GameUtil.GetMillisecondsFromEpoch()), 60000)
      game.mLastPingMs = cur_time - self.client_send_time
      if game.mLastPingMs < 0 then
        game.mLastPingMs = game.mLastPingMs + 60000
      end
    end
  end)
end
