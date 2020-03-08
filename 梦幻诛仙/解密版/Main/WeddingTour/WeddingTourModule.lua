local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local WeddingTourModule = Lplus.Extend(ModuleBase, "WeddingTourModule")
local AnnouncementTip = require("GUI.AnnouncementTip")
require("Main.module.ModuleId")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local NoticeType = require("consts.mzm.gsp.function.confbean.NoticeType")
local def = WeddingTourModule.define
local instance
def.static("=>", WeddingTourModule).Instance = function()
  if instance == nil then
    instance = WeddingTourModule()
    instance.m_moduleId = ModuleId.WEDDING_TOUR
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SNewMemberJoinTeamBrd", WeddingTourModule.OnTeamMemberChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberStatusChangedBrd", WeddingTourModule.OnTeamMemberChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SLeaveTeamBrd", WeddingTourModule.OnTeamMemberChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.team.SMemberReturnBrd", WeddingTourModule.OnTeamMemberChanged)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SMarriageNormalResult", WeddingTourModule.OnNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SMarrigeParadeSuc", WeddingTourModule.OnMarrigeParadeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SBrocastStartParade", WeddingTourModule.OnBrocastStartParade)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SBrocastPauseParade", WeddingTourModule.OnBrocastPauseParade)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SBrocastEndParade", WeddingTourModule.OnBrocastEndParade)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SMarrigeParadeGetMoney", WeddingTourModule.OnMarrigeParadeGetMoney)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SBrocastRobMarriageParade", WeddingTourModule.OnSBrocastRobMarriageParade)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SBrocastRobMarriageParadeWin", WeddingTourModule.OnSBrocastRobMarriageParadeWin)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SBrocastRobMarriageParadeFail", WeddingTourModule.OnSBrocastRobMarriageParadeFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SParadeAttackErrorRes", WeddingTourModule.OnSParadeAttackErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.STransforToRobLocationRes", WeddingTourModule.OnSTransforToRobLocationRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SSynFriendParadeMsg", WeddingTourModule.OnSSynFriendParadeMsg)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SSynGangParadeMsg", WeddingTourModule.OnSSynGangParadeMsg)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.marriage.SSynAllParadeMsg", WeddingTourModule.OnSSynAllParadeMsg)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, WeddingTourModule.OnMatchMakerService)
  Event.RegisterEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.WeddingEnd, WeddingTourModule.OnWeddingEnd)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, WeddingTourModule.OnClickChatBtn)
  ModuleBase.Init(self)
end
def.static("table").OnNormalResult = function(p)
  if p.result == p.MARRIAGE_PARADE_NOT_NORMAL_STATE then
    WeddingTourModule.OnTeamMemberChanged({})
  elseif p.result == p.MARRIAGE_PARADE_SOMEONE_IN_PARADE then
    Toast(textRes.WeddingTour[6])
  end
end
def.static("table").OnTeamMemberChanged = function(p)
  local weddingTourPanel = require("Main.WeddingTour.ui.WeddingTourPanel").Instance()
  if weddingTourPanel:IsShow() then
    weddingTourPanel:Close()
    Toast(textRes.WeddingTour[4])
  end
end
def.static("table", "table").OnMatchMakerService = function(p1, p2)
  local npcId = p1[2]
  local serviceId = p1[1]
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  if NPCServiceConst.WeddingTour == serviceId then
    instance:ShowWeddingTourPanel()
  end
end
def.static("table").OnMarrigeParadeSuccess = function(p)
  local weddingTourPanel = require("Main.WeddingTour.ui.WeddingTourPanel").Instance()
  if weddingTourPanel:IsShow() then
    weddingTourPanel:Close()
  end
  local paradeId = p.paradeCfgid
  Toast(textRes.WeddingTour[7])
end
def.static("table").OnBrocastStartParade = function(p)
  local groomInfo = p.role1Info
  local brideInfo = p.role2Info
  local paradeCfg = require("Main.WeddingTour.WeddingTourUtils").GetWeddingTourModeById(p.paradecfgid)
  if paradeCfg == nil then
    return
  end
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(paradeCfg.paradeMapid)
  if mapCfg == nil then
    return
  end
  local announce = string.format(textRes.WeddingTour[8], groomInfo.roleName, brideInfo.roleName, mapCfg.mapName)
  require("GUI.InteractiveAnnouncementTip").AnnounceWithModuleIdAndDuration(announce, NoticeType.YOU_JIE, 5)
end
def.static("table").OnBrocastPauseParade = function(p)
  local groomInfo = p.role1Info
  local brideInfo = p.role2Info
  local paradeCfg = require("Main.WeddingTour.WeddingTourUtils").GetWeddingTourModeById(p.paradecfgid)
  if paradeCfg == nil then
    return
  end
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(paradeCfg.paradeMapid)
  if mapCfg == nil then
    return
  end
  local announce = string.format(textRes.WeddingTour[9], groomInfo.roleName, brideInfo.roleName, mapCfg.mapName)
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(announce, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.static("table").OnBrocastEndParade = function(p)
  local groomInfo = p.role1Info
  local brideInfo = p.role2Info
  local announce = string.format(textRes.WeddingTour[10], groomInfo.roleName, brideInfo.roleName)
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(announce, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
  require("Main.WeddingTour.ui.DlgRobWedding").Instance():Hide()
end
def.static("table").OnMarrigeParadeGetMoney = function(p)
  local groomInfo = p.role1Info
  local brideInfo = p.role2Info
  local tips = string.format(textRes.WeddingTour[11], groomInfo.roleName, brideInfo.roleName)
  Toast(tips)
end
def.static("table", "table").OnWeddingEnd = function(param, p)
  local groomId = param[1]
  local brideId = param[2]
  local teamData = require("Main.Team.TeamData").Instance()
  local roleId = require("Main.Hero.HeroModule").Instance().roleId
  if roleId == groomId or roleId == brideId then
    local function FinishActivity()
      local ShareWeddingPanel = require("Main.WeddingTour.ui.ShareWeddingPanel")
      local srcPanel = ShareWeddingPanel.Instance()
      local AfterShareFunc
      if teamData:MeIsCaptain() then
        function AfterShareFunc()
          local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
          CommonConfirmDlg.ShowConfirm("", textRes.WeddingTour[1], require("Main.WeddingTour.WeddingTourModule").OnConfirmWeddingTour, nil)
        end
      end
      srcPanel:ShowPanel(AfterShareFunc)
      return srcPanel
    end
    require("Main.RelationShipChain.RelationShipChainMgr").PrepareShare(true, FinishActivity, nil)
  end
end
def.static("number", "table").OnConfirmWeddingTour = function(result, tag)
  if result == 1 then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.CMarriageParadeConsts.paradeNPC
    })
  end
end
local PARADE_BTN_LABEL = "GO_TO_PARADE_NOW"
local target_map_id = 0
def.static("table").OnSSynFriendParadeMsg = function(p)
  local paradeCfg = require("Main.WeddingTour.WeddingTourUtils").GetWeddingTourModeById(p.paradecfgid)
  if paradeCfg == nil then
    return
  end
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(paradeCfg.paradeMapid)
  if mapCfg == nil then
    return
  end
  target_map_id = paradeCfg.paradeMapid
  local str = string.format(textRes.WeddingTour[18], p.coupleInfo.roleName, mapCfg.mapName)
  local announce = str .. string.format("<a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", PARADE_BTN_LABEL, PARADE_BTN_LABEL, link_defalut_color, textRes.WeddingTour[13])
  local senderId = p.myInfo.roleid
  local receiverId = GetMyRoleID()
  local friendInfo = require("Main.friend.FriendData").Instance():GetFriendInfo(senderId)
  if friendInfo == nil then
    return
  end
  local roleName = friendInfo.roleName
  local gender = friendInfo.sex
  local occupationId = friendInfo.occupationId
  local avatarId = friendInfo.avatarId
  local level = friendInfo.roleLevel
  local avatarFrameId = friendInfo.avatarFrameId
  local vipLevel = 0
  local modelId = 0
  local badge = {}
  local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
  local content = require("netio.Octets").rawFromString(announce)
  require("Main.Marriage.MarriageModule").Instance():SendFakeFriendMsg(senderId, receiverId, senderId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, _G.GetServerTime(), avatarId, avatarFrameId)
end
def.static("table").OnSSynGangParadeMsg = function(p)
  local paradeCfg = require("Main.WeddingTour.WeddingTourUtils").GetWeddingTourModeById(p.paradecfgid)
  if paradeCfg == nil then
    return
  end
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(paradeCfg.paradeMapid)
  if mapCfg == nil then
    return
  end
  target_map_id = paradeCfg.paradeMapid
  local str = string.format(textRes.WeddingTour[19], p.myInfo.roleName, p.coupleInfo.roleName, mapCfg.mapName)
  local announce = str .. string.format("<a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", PARADE_BTN_LABEL, PARADE_BTN_LABEL, link_defalut_color, textRes.WeddingTour[13])
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(announce, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.static("table").OnSSynAllParadeMsg = function(p)
  local paradeCfg = require("Main.WeddingTour.WeddingTourUtils").GetWeddingTourModeById(p.paradecfgid)
  if paradeCfg == nil then
    return
  end
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(paradeCfg.paradeMapid)
  if mapCfg == nil then
    return
  end
  target_map_id = paradeCfg.paradeMapid
  local str = string.format(textRes.WeddingTour[19], p.role1Info.roleName, p.role2Info.roleName, mapCfg.mapName)
  local announce = str .. string.format("<a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", PARADE_BTN_LABEL, PARADE_BTN_LABEL, link_defalut_color, textRes.WeddingTour[13])
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(announce, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.method().ShowWeddingTourPanel = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MARRIAGE_PARADE) then
    Toast(textRes.WeddingTour[16])
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() ~= true or teamData:GetMemberCount() < 2 then
    Toast(textRes.WeddingTour[2])
    return
  end
  if teamData:GetMemberCount() > 2 then
    Toast(textRes.WeddingTour[3])
    return
  end
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if teamData:HasLeavingMember() or not teamData:IsTeamMember(mateInfo.mateId) then
    Toast(textRes.WeddingTour[3])
    return
  end
  local weddingTourPanel = require("Main.WeddingTour.ui.WeddingTourPanel").Instance()
  weddingTourPanel:ShowWeddingTourOptions()
end
local ROB_BTN_LABEL = "GO_TO_ROB_NOW"
def.static("table").OnSBrocastRobMarriageParade = function(p)
  local str = string.format(textRes.WeddingTour[12], p.role1Info.roleName, p.role2Info.roleName)
  local announce = str .. string.format("<a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", ROB_BTN_LABEL, ROB_BTN_LABEL, link_defalut_color, textRes.WeddingTour[13])
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(announce, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.static("table", "table").OnClickChatBtn = function(p1, p2)
  local tag = p1 and p1.id
  if tag == ROB_BTN_LABEL then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.marriage.CTransforToRobLocation").new())
  elseif tag == PARADE_BTN_LABEL then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):EnterMap(target_map_id, nil)
  end
end
def.static("table").OnSBrocastRobMarriageParadeWin = function(p)
  local msg = string.format(textRes.WeddingTour[14], p.winAttacker.roleName, p.role1Info.roleName, p.role2Info.roleName)
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.static("table").OnSBrocastRobMarriageParadeFail = function(p)
  local msg = string.format(textRes.WeddingTour[15], p.failAttacker.roleName, p.role1Info.roleName, p.role2Info.roleName)
  gmodule.moduleMgr:GetModule(ModuleId.CHAT):SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.WORLD)
end
def.static("table").OnSParadeAttackErrorRes = function(p)
  local tipStr
  if p.result == p.MARRIAGE_PARADE_BRIDE_IN_FIGHT then
    tipStr = textRes.WeddingTour[101]
  elseif p.result == p.MARRIAGE_PARADE_BRIDE_ALREADY_CHALLENGED then
    tipStr = textRes.WeddingTour[102]
  elseif p.result == p.MARRIAGE_PARADE_GROOM_IN_FIGHT then
    tipStr = textRes.WeddingTour[103]
  elseif p.result == p.MARRIAGE_PARADE_GROOM_ALREADY_CHALLENGED then
    tipStr = textRes.WeddingTour[104]
  elseif p.result == p.MARRIAGE_ROB_PARADE_TO_MAX_SELF then
    tipStr = textRes.WeddingTour[105]
  elseif p.result == p.MARRIAGE_ATTACK_PROTECT_TO_MAX_SELF then
    tipStr = textRes.WeddingTour[106]
  elseif p.result == p.MARRIAGE_ROB_PARADE_TO_MAX then
    tipStr = string.format(textRes.WeddingTour[108], p.args[1])
  elseif p.result == p.MARRIAGE_ATTACK_PROTECT_TO_MAX then
    tipStr = string.format(textRes.WeddingTour[109], p.args[1])
  end
  if tipStr then
    Toast(tipStr)
  end
end
def.static("table").OnSTransforToRobLocationRes = function(p)
  if p.result == p.ROB_MARRIAGE_END then
    Toast(textRes.WeddingTour[107])
  end
end
WeddingTourModule.Commit()
return WeddingTourModule
