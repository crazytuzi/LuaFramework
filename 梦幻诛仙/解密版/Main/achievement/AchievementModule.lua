local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AchievementModule = Lplus.Extend(ModuleBase, "AchievementModule")
local AchievementData = require("Main.achievement.AchievementData")
local achievementData = AchievementData.Instance()
local GangModule = require("Main.Gang.GangModule")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local ChatMsgData = require("Main.Chat.ChatMsgData")
local HtmlHelper = require("Main.Chat.HtmlHelper")
local def = AchievementModule.define
local instance
def.static("=>", AchievementModule).Instance = function()
  if instance == nil then
    instance = AchievementModule()
    instance.m_moduleId = ModuleId.ACHIEVEMENT
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.achievement.SSynAchievementInfo", AchievementModule.OnSSynAchievementInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.achievement.SSynAchievementGoalInfo", AchievementModule.OnSSynAchievementGoalInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.achievement.SGetAchievementGoalAwardSuccess", AchievementModule.OnSGetAchievementGoalAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.achievement.SGetAchievementScoreAwardSuccess", AchievementModule.OnSGetAchievementScoreAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.achievement.SAchievementFinishBrd", AchievementModule.OnSAchievementFinishBrd)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, AchievementModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, AchievementModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, AchievementModule.OnChatBtnClick)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  achievementData:Reset()
end
def.static("table", "table").OnEnterWorld = function(p1, p2)
  local NewServerAwardMgr = require("Main.Award.mgr.NewServerAwardMgr")
  local newServerAwardMgr = NewServerAwardMgr.Instance()
  local leftTime = newServerAwardMgr:getLeftTime()
  if leftTime > 0 then
    local callback = function()
      Event.DispatchEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.NEw_SERVER_AWARD_CLOSE, {})
    end
    warn("!!!!!!!!!!!!AddListener new server:", leftTime)
    local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
    AbsoluteTimer.AddListener(1, 0, callback, {}, leftTime + 10)
  end
  achievementData:ResetAchievementListAndCountInfo()
  require("Main.achievement.ui.AchievementGetPanel").Instance():SetOpen(true)
end
def.static("table", "table").OnLeaveWorld = function(params)
  if instance then
    instance:OnReset()
  end
  require("Main.achievement.ui.AchievementGetPanel").Instance():Reset()
end
def.static("table").OnSSynAchievementInfo = function(p)
  local oldScoreAwardState = achievementData:CanGetAward()
  achievementData:setAchievementInfo(p.activity_cfg_id, p.goal_map_info, p.aleardy_awarded_score, p.now_score_value)
  Event.DispatchEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_INFO_UPDATE, {
    p.activity_cfg_id
  })
  if oldScoreAwardState ~= achievementData:CanGetAward() then
    Event.DispatchEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_SCORE_AWARD_CHANGE, nil)
  end
end
def.static("table").OnSSynAchievementGoalInfo = function(p)
  local oldScoreAwardState = achievementData:CanGetAward()
  local isFinishAchievement = achievementData:setAchievementGoalInfo(p.activity_cfg_id, p.goal_cfg_id, p.goal_info, p.now_score_value)
  Event.DispatchEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, {
    p.activity_cfg_id,
    p.goal_cfg_id
  })
  if oldScoreAwardState ~= achievementData:CanGetAward() then
    Event.DispatchEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_SCORE_AWARD_CHANGE, nil)
  end
  if isFinishAchievement then
    require("Main.achievement.ui.AchievementGetPanel").Instance():ShowPanel(p.goal_cfg_id)
    local goalCfg = AchievementData.GetAchievementGoalCfg(p.goal_cfg_id)
    if goalCfg and goalCfg.bulletinType >= 1 then
      local content = string.format(textRes.Grow.Achievement[13], goalCfg.title)
      ChatModule.Instance():SendSystemMsg(ChatMsgData.System.PERSONAL, HtmlHelper.Style.Personal, {content = content})
    end
  end
end
def.static("table").OnSGetAchievementGoalAwardSuccess = function(p)
  local AchievementGoalInfo = require("netio.protocol.mzm.gsp.achievement.AchievementGoalInfo")
  local oldScoreAwardState = achievementData:CanGetAward()
  achievementData:setAchievementState(p.activity_cfg_id, p.goal_cfg_id, AchievementGoalInfo.ST_HAND_UP)
  achievementData:setAchievementScore(p.activity_cfg_id, p.now_score_value)
  Event.DispatchEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, {
    p.activity_cfg_id,
    p.goal_cfg_id
  })
  if oldScoreAwardState ~= achievementData:CanGetAward() then
    Event.DispatchEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_SCORE_AWARD_CHANGE, nil)
  end
end
def.static("table").OnSGetAchievementScoreAwardSuccess = function(p)
  local oldScoreAwardState = achievementData:CanGetAward()
  achievementData:setGetScoreAward(p.activity_cfg_id, p.score)
  Event.DispatchEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GET_SCORE_AWARD, {
    p.activity_cfg_id,
    p.score
  })
  if oldScoreAwardState ~= achievementData:CanGetAward() then
    Event.DispatchEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_SCORE_AWARD_CHANGE, nil)
  end
end
def.static("table").OnSAchievementFinishBrd = function(p)
  local gangId = p.faction_id
  local roleName = p.role_name
  local goalCfgId = p.goal_cfg_id
  local nowTime = GetServerTime()
  local goalCfg = AchievementData.GetAchievementGoalCfg(goalCfgId)
  if goalCfg and goalCfg.bulletinType >= 2 then
    local id = string.format("achievementfinish_%s_%s_%s", tostring(goalCfgId), tostring(nowTime), roleName)
    local bulletinType = goalCfg.bulletinType
    if bulletinType == 2 then
      local button = string.format("<a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", id, id, link_defalut_color, goalCfg.title)
      local gangInfo = string.format(textRes.Grow.Achievement[14], roleName, button)
      AchievementModule.ShowInGangChannel(gangId, gangInfo)
    elseif bulletinType == 3 then
      local button = string.format("<a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", id, id, link_defalut_color, goalCfg.title)
      local msgInfo = string.format(textRes.Grow.Achievement[14], roleName, goalCfg.title)
      local gangInfo = string.format(textRes.Grow.Achievement[14], roleName, button)
      AchievementModule.ShowInGangChannel(gangId, gangInfo)
      require("GUI.AnnouncementTip").Announce(msgInfo)
      ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = gangInfo})
    elseif bulletinType == 4 then
      local button = string.format("<a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", id, id, link_defalut_color, goalCfg.title)
      local msgInfo = string.format(textRes.Grow.Achievement[15], roleName, goalCfg.title)
      local gangInfo = string.format(textRes.Grow.Achievement[15], roleName, button)
      AchievementModule.ShowInGangChannel(gangId, gangInfo)
      require("GUI.RareItemAnnouncementTip").AnnounceRareItem(msgInfo)
      ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = gangInfo})
    end
  end
end
def.static("table", "table").OnChatBtnClick = function(params, tbl)
  local id = params.id
  if string.sub(id, 1, #"achievementfinish") == "achievementfinish" then
    local strs = string.split(id, "_")
    local goalCfgId = tonumber(strs[2])
    local time = tonumber(strs[3])
    local name = strs[4]
    local params = {
      0,
      0,
      0,
      0,
      0
    }
    require("Main.Achievement.ui.AchievementShowDlg").ShowPanel(goalCfgId, 2, time, name, params, true, {x = 0, y = 0})
  end
end
def.static("userdata", "string").ShowInGangChannel = function(gangId, display)
  local myGangId = require("Main.Gang.data.GangData").Instance():GetGangId()
  if gangId and myGangId and Int64.eq(gangId, myGangId) then
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(display, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
end
def.method("string").ShowAchievementDlgFromChat = function(self, linkStr)
  local strs = string.split(linkStr, "_")
  local id = tonumber(strs[2])
  local state = tonumber(strs[3])
  local time = tonumber(strs[4])
  local paramsStrs = string.split(strs[5], "|")
  local paramsTbl = {}
  for k, v in ipairs(paramsStrs) do
    table.insert(paramsTbl, tonumber(v))
  end
  local name = strs[6]
  require("Main.Achievement.ui.AchievementShowDlg").ShowPanel(id, state, time, name, paramsTbl, true, {x = 0, y = 0})
end
return AchievementModule.Commit()
