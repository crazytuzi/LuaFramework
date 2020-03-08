local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local PhantomCaveModule = Lplus.Extend(ModuleBase, "PhantomCaveModule")
local TeamData = require("Main.Team.TeamData")
local HeroModule = require("Main.Hero.HeroModule")
local PhantomCaveUtils = require("Main.PhantomCave.PhantomCaveUtils")
local CommonActivityLevelInfoPanel = require("GUI.CommonActivityLevelInfoPanel")
require("Main.module.ModuleId")
local def = PhantomCaveModule.define
local instance
def.static("=>", PhantomCaveModule).Instance = function()
  if instance == nil then
    instance = PhantomCaveModule()
    instance.m_moduleId = ModuleId.PHANTOMCAVE
  end
  return instance
end
def.override().Init = function(self)
  require("Main.PhantomCave.WatchAndGuessMgr").Instance():Init()
  require("Main.PhantomCave.PuzzleMgr").Instance():Init()
  require("Main.PhantomCave.QuestionAndAnswerMgr").Instance():Init()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, PhantomCaveModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, PhantomCaveModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PhantomCaveModule.OnNPCService)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, PhantomCaveModule.OnMainUIReady)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, PhantomCaveModule.UpdateMainUI)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, PhantomCaveModule.UpdateMainUI)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_LEAVE, PhantomCaveModule.UpdateMainUI)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_UPGRADE_TO_CAPTION, PhantomCaveModule.UpdateMainUI)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, PhantomCaveModule.UpdateMainUI)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, PhantomCaveModule.UpdateMainUI)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, PhantomCaveModule.OnActivityReset)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, PhantomCaveModule.OnMapChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SParaseleneActivityOpenRes", PhantomCaveModule.OnSParaseleneActivityOpenRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SJoinParaseleneSuc", PhantomCaveModule.OnSJoinParaseleneSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SErrorInfo", PhantomCaveModule.OnSErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SLeavefubenRes", PhantomCaveModule.OnSLeavefubenRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SOpenSendPointRes", PhantomCaveModule.OnSOpenSendPointRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SParaseleneActivityCloseRes", PhantomCaveModule.OnSParaseleneActivityCloseRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SAlreadyGetRewardRes", PhantomCaveModule.OnSAlreadyGetRewardRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SFinishActivityRes", PhantomCaveModule.OnSFinishActivityRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SLayerTaskFailed", PhantomCaveModule.OnSLayerTaskFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SFinishLayerTaskRes", PhantomCaveModule.OnSFinishLayerTaskRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SWordQuestionRes", PhantomCaveModule.OnSWordQuestionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SPictureQuestionRes", PhantomCaveModule.OnSPictureQuestionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SJigsawInfoRes", PhantomCaveModule.OnSJigsawInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paraselene.SGainPreciousItemBrd", PhantomCaveModule.OnSGainPreciousItemBrd)
  ModuleBase.Init(self)
end
def.static("table", "table").OnMapChange = function(p1, p2)
  local curmapId = p1[1]
  local oldmapId = p1[2]
  if PhantomCaveUtils.IsPhantomCaveMap(curmapId) then
    local curMapCfg = require("Main.Map.MapUtility").GetMapCfg(curmapId)
    local curMapName = curMapCfg.mapName
    local targetName = curMapName
    CommonActivityLevelInfoPanel.Instance():ShowPanel(textRes.PhantomCave[13], targetName)
  else
    local isLeavedFromPhaveCave = PhantomCaveUtils.IsPhantomCaveMap(oldmapId)
    if isLeavedFromPhaveCave then
      CommonActivityLevelInfoPanel.Instance():HidePanel()
    end
  end
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  require("Main.PhantomCave.PuzzleMgr").Instance():ReleaseCacheProtocol()
  require("Main.PhantomCave.QuestionAndAnswerMgr").Instance():ReleaseCacheProtocol()
  require("Main.PhantomCave.WatchAndGuessMgr").Instance():ReleaseCacheProtocol()
end
def.override().OnReset = function(self)
  require("Main.PhantomCave.PuzzleMgr").Instance():Reset()
  require("Main.PhantomCave.QuestionAndAnswerMgr").Instance():Reset()
  require("Main.PhantomCave.WatchAndGuessMgr").Instance():Reset()
end
def.static("table", "table").OnActivityReset = function(p1, p2)
  local activityId = p1[1]
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  warn("OnActivityTodo~~~~")
  local activityID = p1[1]
  if activityID == require("Main.activity.ActivityInterface").PhantomCave_ACTIVITY_ID then
    local bIsInTeam = TeamData.Instance():IsTeamMember(HeroModule.Instance():GetMyRoleId())
    if bIsInTeam then
      local bIsTeamLeader = TeamData.Instance():IsCaptain(HeroModule.Instance():GetMyRoleId())
      if bIsTeamLeader then
        PhantomCaveModule.GoToFindNpc()
      else
        local status = TeamData.Instance():GetStatus()
        if status ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
          PhantomCaveModule.GoToFindNpc()
        end
      end
    else
      PhantomCaveModule.GoToFindNpc()
    end
  end
end
def.static().AlertOnActivityOpen = function()
  local confirmPanel = require("GUI.CommonConfirmDlg")
  confirmPanel.ShowConfirmCoundDown(textRes.PhantomCave[13], textRes.PhantomCave[1], textRes.PhantomCave[14], textRes.PhantomCave[15], 0, 60, function(select, tag)
    if select == 1 then
      local HeroBehaviorDefine = require("Main.Hero.HeroBehaviorDefine")
      if not HeroBehaviorDefine.CanTransport2TargetState(RoleState.PHANTOMCAVE) then
        Toast(textRes.activity[330])
        return
      end
      local bIsInTeam = TeamData.Instance():IsTeamMember(HeroModule.Instance():GetMyRoleId())
      if bIsInTeam then
        local bIsTeamLeader = TeamData.Instance():IsCaptain(HeroModule.Instance():GetMyRoleId())
        if bIsTeamLeader then
          PhantomCaveModule.GoToFindNpc()
        else
          local status = TeamData.Instance():GetStatus()
          if status ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
            PhantomCaveModule.GoToFindNpc()
          end
        end
      else
        PhantomCaveModule.GoToFindNpc()
      end
    end
  end, nil)
end
def.static().GoToFindNpc = function()
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_PHANTOMCAVE_CONST, "Npc")
  local npcId = DynamicRecord.GetIntValue(record, "value")
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
end
def.static("table", "table").OnNPCService = function(params, tbl)
  local serviceID = params[1]
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  local cfg = require("Main.PhantomCave.PhantomCaveUtils").GetPhantomCaveCfg(serviceID)
  if serviceID == NPCServiceConst.PhantomCave then
    local bIsInTeam = TeamData.Instance():IsTeamMember(HeroModule.Instance():GetMyRoleId())
    if bIsInTeam then
      local bIsTeamLeader = TeamData.Instance():IsCaptain(HeroModule.Instance():GetMyRoleId())
      local members = TeamData.Instance():GetAllTeamMembers()
      if #members < 3 then
        if bIsTeamLeader then
          Toast(textRes.PhantomCave[4])
        end
        return
      end
      for k, v in pairs(members) do
        if v.level < 30 then
          if bIsTeamLeader then
            Toast(textRes.PhantomCave[5])
          end
          return
        end
      end
    end
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.paraselene.CJoinParaselene").new())
  elseif cfg ~= nil then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.paraselene.CStartLayerTask").new(cfg.npcId, serviceID))
    PhantomCaveModule.UpdateMainUI(nil, nil)
  end
end
def.static("table", "table").OnMainUIReady = function(params, tbl)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role ~= nil and role:IsInState(RoleState.PHANTOMCAVE) then
    PhantomCaveModule.UpdateMainUI(nil, nil)
  end
end
def.static("table", "table").UpdateMainUI = function(params, tbl)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  if role ~= nil and role:IsInState(RoleState.PHANTOMCAVE) then
    Event.DispatchEvent(ModuleId.PHANTOMCAVE, gmodule.notifyId.PhantomCave.START_ACTIVITY, nil)
    require("ProxySDK.ECMSDK").GSDKStart(0)
    local bIsInTeam = TeamData.Instance():IsTeamMember(HeroModule.Instance():GetMyRoleId())
    if bIsInTeam then
      local bIsTeamLeader = TeamData.Instance():IsCaptain(HeroModule.Instance():GetMyRoleId())
      local status = TeamData.Instance():GetStatus()
      if bIsTeamLeader == false and status ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
        CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, PhantomCaveModule.QuitPhantomCaveCallback, nil, false, CommonActivityPanel.ActivityType.PhantomCave)
      else
        CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, PhantomCaveModule.QuitPhantomCaveCallback, nil, true, CommonActivityPanel.ActivityType.PhantomCave)
      end
    else
      CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, PhantomCaveModule.QuitPhantomCaveCallback, nil, true, CommonActivityPanel.ActivityType.PhantomCave)
    end
  else
    Event.DispatchEvent(ModuleId.PHANTOMCAVE, gmodule.notifyId.PhantomCave.LEAVE_ACTIVITY, nil)
    CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.PhantomCave)
    require("ProxySDK.ECMSDK").GSDKEnd()
  end
end
def.static("table").QuitPhantomCaveCallback = function(tag)
  local bIsInTeam = TeamData.Instance():IsTeamMember(HeroModule.Instance():GetMyRoleId())
  if bIsInTeam then
    local bIsTeamLeader = TeamData.Instance():IsCaptain(HeroModule.Instance():GetMyRoleId())
    local status = TeamData.Instance():GetStatus()
    if bIsTeamLeader == false and status ~= require("netio.protocol.mzm.gsp.team.TeamMember").ST_TMP_LEAVE then
      Toast(textRes.PhantomCave[11])
      return
    end
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.paraselene.CLeavefubenReq").new())
end
def.static("table").OnSLeavefubenRes = function(tag)
end
def.static("table").OnSParaseleneActivityOpenRes = function(p)
end
def.static("table").OnSJoinParaseleneSuc = function(p)
end
def.static("table").OnSErrorInfo = function(p)
  if textRes.PhantomCave.ErrorCode[p.errorCode] ~= nil then
    Toast(textRes.PhantomCave.ErrorCode[p.errorCode])
  end
end
def.static("table").OnSOpenSendPointRes = function(p)
  Toast(textRes.PhantomCave[10])
end
def.static("table").OnSParaseleneActivityCloseRes = function(p)
  local str = string.format(textRes.PhantomCave[7], p.resttime)
  local AnnouncementTip = require("GUI.AnnouncementTip")
  AnnouncementTip.Announce(str)
end
def.static("table").OnSAlreadyGetRewardRes = function(p)
  Toast(textRes.PhantomCave[8])
end
def.static("table").OnSFinishActivityRes = function(p)
  Toast(string.format(textRes.PhantomCave[9], p.seconds))
end
def.static("table").OnSLayerTaskFailed = function(p)
end
def.static("table").OnSWordQuestionRes = function(p)
  GameUtil.AddGlobalLateTimer(1.5, true, function()
    local QuizePrizePanel = require("Main.PhantomCave.ui.QuizePrizePanel")
    QuizePrizePanel.Instance():ShowFinalEstimatePanel(QuizePrizePanel.Type.Text, p.wordQuestionRes, p.issuccess, p.seconds)
  end)
end
def.static("table").OnSPictureQuestionRes = function(p)
  GameUtil.AddGlobalLateTimer(1.5, true, function()
    local QuizePrizePanel = require("Main.PhantomCave.ui.QuizePrizePanel")
    QuizePrizePanel.Instance():ShowFinalEstimatePanel(QuizePrizePanel.Type.Graphical, p.pictureQuestionRes, p.issuccess, p.seconds)
  end)
end
def.static("table").OnSJigsawInfoRes = function(p)
  GameUtil.AddGlobalLateTimer(1.5, true, function()
    local QuizePrizePanel = require("Main.PhantomCave.ui.QuizePrizePanel")
    QuizePrizePanel.Instance():ShowFinalEstimatePanel(QuizePrizePanel.Type.Puzzle, p.jigsawInfoRes, p.issuccess, p.seconds)
  end)
end
def.static("table").OnSGainPreciousItemBrd = function(p)
  local heroName = string.format("[00aa00]%s[-]", p.name)
  local heroName2 = string.format("<font color=#00aa00>%s</font>", p.name)
  local str = string.format(textRes.PhantomCave[12], heroName)
  local htmlStr = string.format(textRes.PhantomCave[12], heroName2)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local count = 0
  for k, v in pairs(p.items) do
    count = count + 1
    local itemId = k
    local itemNum = v
    local itemBase = require("Main.Item.ItemUtils").GetItemBase(itemId)
    local namecolor = itemBase.namecolor
    local colorfmt = "[" .. HtmlHelper.NameColor[namecolor] .. "]" .. "%s" .. "[-]"
    local tmpStr = string.format("%s\195\151%d", itemBase.name, itemNum)
    local htmlTempStr = string.format("<font color=#%s>%s\195\151%d", HtmlHelper.NameColor[namecolor], itemBase.name, itemNum)
    tmpStr = colorfmt:format(tmpStr)
    if count > 1 then
      str = string.format("%s, %s", str, tmpStr)
      htmlStr = string.format("%s , %s", htmlStr, htmlTempStr)
    else
      str = string.format("%s%s", str, tmpStr)
      htmlStr = string.format("%s%s", htmlStr, htmlTempStr)
    end
  end
  local BulletinType = require("consts.mzm.gsp.activity.confbean.BulletinType")
  local ItemUtils = require("Main.Item.ItemUtils")
  if ItemUtils.GetAwardBulletinType(p.items) == BulletinType.UNUSUAL then
    require("GUI.RareItemAnnouncementTip").AnnounceRareItem(str)
  else
    require("GUI.AnnouncementTip").Announce(str)
  end
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  require("Main.Chat.ChatModule").Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.PhancaveGetAwardItem, {awardStr = htmlStr})
end
def.static("table").OnSFinishLayerTaskRes = function(p)
  local layer = p.layer
  if layer < 9 then
    Toast(textRes.PhantomCave[17])
  end
end
PhantomCaveModule.Commit()
return PhantomCaveModule
