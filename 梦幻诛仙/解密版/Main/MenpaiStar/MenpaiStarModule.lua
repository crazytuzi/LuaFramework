local Lplus = require("Lplus")
require("Main.module.ModuleId")
local ModuleBase = require("Main.module.ModuleBase")
local MenpaiStarModule = Lplus.Extend(ModuleBase, "MenpaiStarModule")
local MenpaiStarUtils = require("Main.MenpaiStar.MenpaiStarUtils")
local def = MenpaiStarModule.define
local instance
def.static("=>", MenpaiStarModule).Instance = function()
  if instance == nil then
    instance = MenpaiStarModule()
    instance.m_moduleId = ModuleId.MENPAISTAR
  end
  return instance
end
def.field("boolean").inited = false
def.field("table").npcServiceDo = nil
def.field("table").data = nil
def.field("table").menpaiStarInfos = nil
def.field("table").requestCallback = nil
def.field("userdata").requestRoleId = nil
def.override().Init = function(self)
  self:FirstInit()
  ModuleBase.Init(self)
end
def.method().LazyInit = function(self)
  if not self.inited then
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SGetMenPaiStarInfoSuccess", MenpaiStarModule.OnSGetMenPaiStarInfoSuccess)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SGetVoteAwardInfoSuccess", MenpaiStarModule.OnSGetVoteAwardInfoSuccess)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SStartCampaignFightFailed", MenpaiStarModule.OnSStartCampaignFightFailed)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SSyncCampaignFightResult", MenpaiStarModule.OnSSyncCampaignFightResult)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SStartVoteFightFailed", MenpaiStarModule.OnSStartVoteFightFailed)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SSyncVoteFightResult", MenpaiStarModule.OnSSyncVoteFightResult)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SSetAwardSuccess", MenpaiStarModule.OnSSetAwardSuccess)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SSetAwardFailed", MenpaiStarModule.OnSSetAwardFailed)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SVoteSuccess", MenpaiStarModule.OnSVoteSuccess)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SVoteFailed", MenpaiStarModule.OnSVoteFailed)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SCampaignChart", MenpaiStarModule.OnSCampaignChart)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SGetCampaignChartFailed", MenpaiStarModule.OnSGetCampaignChartFailed)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SWorldCanvassSuccess", MenpaiStarModule.OnSWorldCanvassSuccess)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SWorldCanvassFailed", MenpaiStarModule.OnSWorldCanvassFailed)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SGangCanvassSuccess", MenpaiStarModule.OnSGangCanvassSuccess)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SGangCanvassFailed", MenpaiStarModule.OnSGangCanvassFailed)
    self.data = nil
    Event.RegisterEventWithContext(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MenpaiStarModule.OnNewDay, self)
    Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, MenpaiStarModule.OnActivityStart, self)
    Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, MenpaiStarModule.OnActivityEnd, self)
    self:ServiceInit()
    self.inited = true
    warn("MenpaiStarModule init")
  end
end
def.method().FirstInit = function(self)
  Event.RegisterEventWithContext(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, MenpaiStarModule.OnNPCService, self)
  Event.RegisterEventWithContext(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, MenpaiStarModule.OnActivityTodo, self)
  Event.RegisterEventWithContext(ModuleId.MENPAISTAR, gmodule.notifyId.MenpaiStar.Vote_Link, MenpaiStarModule.OnChatLink, self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SBrocastMenPaiStar", MenpaiStarModule.OnSBrocastMenPaiStar)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.menpaistar.SyncEffectNpcs", MenpaiStarModule.OnSyncEffectNpcs)
  Event.RegisterEventWithContext(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, MenpaiStarModule.OnLeaveWorld, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, MenpaiStarModule.OnFeatureInit, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, MenpaiStarModule.OnFeatureChange, self)
  local allMenpai = MenpaiStarUtils.GetAllMenpaiStarMainCfg()
  self.npcServiceDo = {}
  for _, v in ipairs(allMenpai) do
    self.npcServiceDo[v.voteServiceId] = true
    self.npcServiceDo[v.candidateServiceId] = true
    self.npcServiceDo[v.voterServiceId] = true
  end
end
def.method().ServiceInit = function(self)
  local allMenpai = MenpaiStarUtils.GetAllMenpaiStarMainCfg()
  local function Vote(serviceId)
    self:TryVote(serviceId)
  end
  local function Candidate(serviceId)
    self:TryCandidate(serviceId)
  end
  local function Voter(serviceId)
    self:TryVoter(serviceId)
  end
  self.npcServiceDo = {}
  for _, v in ipairs(allMenpai) do
    self.npcServiceDo[v.voteServiceId] = Vote
    self.npcServiceDo[v.candidateServiceId] = Candidate
    self.npcServiceDo[v.voterServiceId] = Voter
  end
end
def.static("table").OnSGetMenPaiStarInfoSuccess = function(p)
  local self = MenpaiStarModule.Instance()
  local data = self:GetData()
  data:SetCommonData(p.menpai_star_info)
end
def.static("table").OnSGetVoteAwardInfoSuccess = function(p)
  local self = MenpaiStarModule.Instance()
  if self.requestCallback then
    for k, v in ipairs(self.requestCallback) do
      local num, gold = p.vote_award_info.num, p.vote_award_info.award
      v(gold, num)
    end
    self.requestCallback = nil
  end
end
def.static("table").OnSStartCampaignFightFailed = function(p)
  local self = MenpaiStarModule.Instance()
  local tip = textRes.MenpaiStar.CandidateError[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSSyncCampaignFightResult = function(p)
  local self = MenpaiStarModule.Instance()
  local data = self:GetData()
  data:AddCandidateChallengeTimes()
  if p.success > 0 then
    Toast(textRes.MenpaiStar[30])
    data:SetCandidate(true)
  else
    data:SetCandidate(false)
    data:GetCandidateChallengeTimes(function(times)
      local leftTimes = constant.CMenPaiStarConst.DAILY_CAMPAIGN_BATTLE_NUM - times
      if leftTimes > 0 then
        Toast(string.format(textRes.MenpaiStar[31], leftTimes))
      else
        Toast(textRes.MenpaiStar[34])
      end
    end)
  end
end
def.static("table").OnSStartVoteFightFailed = function(p)
  local self = MenpaiStarModule.Instance()
  local tip = textRes.MenpaiStar.VoterError[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSSyncVoteFightResult = function(p)
  local self = MenpaiStarModule.Instance()
  local data = self:GetData()
  data:AddVoterChallengeTimes()
  if p.success > 0 then
    Toast(textRes.MenpaiStar[32])
    data:SetVoter(true)
  else
    data:SetVoter(false)
    data:GetVoterChallengeTimes(function(times)
      local leftTimes = constant.CMenPaiStarConst.DAILY_VOTE_BATTLE_NUM - times
      if leftTimes > 0 then
        Toast(string.format(textRes.MenpaiStar[33], leftTimes))
      else
        Toast(textRes.MenpaiStar[34])
      end
    end)
  end
end
def.static("table").OnSSetAwardSuccess = function(p)
  local self = MenpaiStarModule.Instance()
  local award = p.vote_award_info.award
  local num = p.vote_award_info.num
  Toast(string.format(textRes.MenpaiStar[14], award, num))
  local MenpaiStarVote = require("Main.MenpaiStar.ui.MenpaiStarVote")
  MenpaiStarVote.ChangeAwardByRole(GetMyRoleID(), award, num)
end
def.static("table").OnSSetAwardFailed = function(p)
  local self = MenpaiStarModule.Instance()
  local tip = textRes.MenpaiStar.SetAwardError[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSVoteSuccess = function(p)
  local self = MenpaiStarModule.Instance()
  local empty = false
  if p.vote_num > 0 and 0 >= p.gold then
    empty = true
    Toast(textRes.MenpaiStar[44])
  else
    local tip = string.format(textRes.MenpaiStar[5], p.gold)
    Toast(tip)
  end
  local data = self:GetData()
  data:AddVoteTimes()
  local MenpaiStarVote = require("Main.MenpaiStar.ui.MenpaiStarVote")
  MenpaiStarVote.MyPointToRole(p.target_roleid, p.point, empty)
end
def.static("table").OnSVoteFailed = function(p)
  local self = MenpaiStarModule.Instance()
  local tip = textRes.MenpaiStar.VoteError[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSCampaignChart = function(p)
  local self = MenpaiStarModule.Instance()
  local MenpaiStarVote = require("Main.MenpaiStar.ui.MenpaiStarVote")
  MenpaiStarVote.ShowMenpaiStarVote(p.occupationid)
  local page = p.page
  local totalPage = p.total_page
  local list = {}
  for k, v in ipairs(p.ranks) do
    local name = _G.GetStringFromOcts(v.role_name)
    table.insert(list, {
      rank = v.rank,
      name = name,
      point = v.point,
      roleId = v.roleid,
      reward = v.vote_award_info.award,
      left = v.vote_award_info.num
    })
  end
  MenpaiStarVote.UpdateContent(list, page, totalPage, self.requestRoleId)
  self.requestRoleId = nil
end
def.static("table").OnSGetCampaignChartFailed = function(p)
  local self = MenpaiStarModule.Instance()
  local tip = textRes.MenpaiStar.ChartError[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSBrocastMenPaiStar = function(p)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MEN_PAI_STAR) then
    return
  end
  local allOccupations = _G.GetAllRealOpenedOccupations()
  local self = MenpaiStarModule.Instance()
  local InteractiveAnnouncementTip = require("GUI.InteractiveAnnouncementTip")
  local info = p.champion
  if allOccupations[info.occupationid] == nil then
    return
  end
  local name = GetStringFromOcts(info.role_name)
  local menpaiName = _G.GetOccupationName(info.occupationid)
  local point = info.point
  local roleId = info.roleid
  local content = ""
  if self.menpaiStarInfos then
    self.menpaiStarInfos[info.occupationid] = roleId
  end
  local cfg = MenpaiStarUtils.GetMenpaiStarMainCfg(info.occupationid)
  if cfg then
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = cfg.effectNpcId,
      show = roleId > Int64.new(0)
    })
  end
  if roleId > Int64.new(0) then
    content = string.format(textRes.MenpaiStar[16], name, menpaiName)
  else
    content = string.format(textRes.MenpaiStar[40], menpaiName)
  end
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.SYS, HtmlHelper.Style.Common, {str = content})
  InteractiveAnnouncementTip.InteractiveAnnounceWithPriority(content, 0)
  if roleId == GetMyRoleID() then
    Toast(string.format(textRes.MenpaiStar[36], menpaiName))
  end
end
def.static("table").OnSyncEffectNpcs = function(p)
  local open = IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MEN_PAI_STAR)
  local self = MenpaiStarModule.Instance()
  self.menpaiStarInfos = {}
  local int640 = Int64.new(0)
  for k, v in pairs(p.npcCfgids) do
    self.menpaiStarInfos[k] = v
    local cfg = MenpaiStarUtils.GetMenpaiStarMainCfg(k)
    if cfg then
      if open then
        if v == int640 then
          Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
            npcid = cfg.effectNpcId,
            show = false
          })
        else
          Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
            npcid = cfg.effectNpcId,
            show = true
          })
        end
      else
        Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
          npcid = cfg.effectNpcId,
          show = false
        })
      end
    end
  end
end
def.static("table").OnSWorldCanvassSuccess = function(p)
  local self = MenpaiStarModule.Instance()
  local data = self:GetData()
  data:SetWorldCanvass(p.target_roleid, GetServerTime())
  Toast(textRes.MenpaiStar[26])
end
def.static("table").OnSWorldCanvassFailed = function(p)
  local self = MenpaiStarModule.Instance()
  local tip = textRes.MenpaiStar.WorldCanvassError[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSGangCanvassSuccess = function(p)
  local self = MenpaiStarModule.Instance()
  local data = self:GetData()
  data:SetGangCanvass(p.target_roleid, GetServerTime())
  Toast(textRes.MenpaiStar[26])
end
def.static("table").OnSGangCanvassFailed = function(p)
  local self = MenpaiStarModule.Instance()
  local tip = textRes.MenpaiStar.GangCanvassError[p.retcode]
  if tip then
    Toast(tip)
  end
end
def.method("table").OnNewDay = function(self, params)
  local data = self:GetData()
  data:SetCandidateChallengeTimes(0)
  data:SetVoterChallengeTimes(0)
end
def.method("table").OnActivityStart = function(self, params)
  local activityId = params[1]
  if constant.CMenPaiStarConst.ACTIVITY_CFG_ID == activityId then
    self:ClearData()
  end
end
def.method("table").OnActivityEnd = function(self, params)
  local activityId = params[1]
  if constant.CMenPaiStarConst.ACTIVITY_CFG_ID == activityId then
    self:ClearData()
  end
end
def.method("table").OnLeaveWorld = function(self, params)
  self.requestRoleId = nil
  self.requestCallback = nil
  self:ClearData()
  self.menpaiStarInfos = nil
end
def.method("table").OnNPCService = function(self, params)
  local serviceId = params[1]
  if self.npcServiceDo[serviceId] then
    self:LazyInit()
    local serviceDo = self.npcServiceDo[serviceId]
    if type(serviceDo) == "function" then
      serviceDo(serviceId)
    end
  end
end
def.method("table").OnActivityTodo = function(self, params)
  local activityId = params and params[1]
  if nil == activityId then
    return
  end
  if activityId == constant.CMenPaiStarConst.ACTIVITY_CFG_ID then
    if not self:CheckFeatureOpen() then
      return
    end
    self:LazyInit()
    local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    local cfg = MenpaiStarUtils.GetMenpaiStarMainCfg(heroProp.occupation)
    if cfg then
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
        cfg.npcId
      })
    end
  end
end
def.method("table").OnChatLink = function(self, params)
  if IsCrossingServer() then
    Toast(textRes.MenpaiStar[54])
  else
    local roleId = params[1]
    if roleId then
      self:LazyInit()
      self:RequestByRoleId(roleId)
    end
  end
end
def.method("table").OnFeatureInit = function(self, params)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MEN_PAI_STAR) then
    self:OpenMenpaiStar(false)
  end
end
def.method("table").OnFeatureChange = function(self, params)
  if params.feature == require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MEN_PAI_STAR then
    if params.open then
      self:OpenMenpaiStar(true)
    else
      self:OpenMenpaiStar(false)
    end
  end
end
def.method("boolean").OpenMenpaiStar = function(self, open)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  if open then
    ActivityInterface.Instance():removeCustomCloseActivity(constant.CMenPaiStarConst.ACTIVITY_CFG_ID)
  else
    ActivityInterface.Instance():addCustomCloseActivity(constant.CMenPaiStarConst.ACTIVITY_CFG_ID)
  end
  local int640 = Int64.new(0)
  local allMenpai = MenpaiStarUtils.GetAllMenpaiStarMainCfg()
  for k, v in ipairs(allMenpai) do
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = v.npcId,
      show = open
    })
    if open then
      if self.menpaiStarInfos and self.menpaiStarInfos[v.menpai] ~= int640 then
        Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
          npcid = v.effectNpcId,
          show = true
        })
      else
        Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
          npcid = v.effectNpcId,
          show = false
        })
      end
    else
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
        npcid = v.effectNpcId,
        show = false
      })
    end
  end
end
def.method().ClearData = function(self)
  self.data = nil
end
def.method("number").TryVote = function(self, service)
  if not self:CheckFeatureOpen() then
    return
  end
  local menpai = self:ServiceIdToMenpai(service)
  if menpai > 0 then
    local MenpaiStarVote = require("Main.MenpaiStar.ui.MenpaiStarVote")
    MenpaiStarVote.ShowMenpaiStarVote(menpai)
    self:RequestByMenpaiAndPage(menpai, 1)
  end
end
def.method("number").TryCandidate = function(self, service)
  if not self:CheckFeatureOpen() then
    return
  end
  if not self:CheckActivityOpen() then
    return
  end
  if not self:CheckInPeriod(constant.CMenPaiStarConst.CAMPAIGN_BATTLE_END_TIME) then
    Toast(textRes.MenpaiStar[20])
    return
  end
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():HasTeam() then
    Toast(textRes.MenpaiStar[53])
    return
  end
  local menpai = self:ServiceIdToMenpai(service)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if menpai == heroProp.occupation then
    if heroProp.level < constant.CMenPaiStarConst.CAMPAIGN_MIN_LEVEL then
      Toast(string.format(textRes.MenpaiStar[7], constant.CMenPaiStarConst.CAMPAIGN_MIN_LEVEL))
      return
    end
    do
      local serverLevel = require("Main.Server.ServerModule").Instance():GetServerLevelInfo().level
      if heroProp.level < serverLevel - constant.CMenPaiStarConst.CAMPAIGN_NOT_LESS_SERVER_LEVEL then
        Toast(string.format(textRes.MenpaiStar[8], constant.CMenPaiStarConst.CAMPAIGN_NOT_LESS_SERVER_LEVEL))
        return
      end
      local data = self:GetData()
      data:IsCandidate(function(isCandidate)
        if isCandidate then
          Toast(textRes.MenpaiStar[6])
        else
          data:GetCandidateChallengeTimes(function(times)
            if times < constant.CMenPaiStarConst.DAILY_CAMPAIGN_BATTLE_NUM then
              self:_candidate()
            else
              Toast(textRes.MenpaiStar[9])
            end
          end)
        end
      end)
    end
  end
end
def.method("number").TryVoter = function(self, service)
  if not self:CheckFeatureOpen() then
    return
  end
  if not self:CheckActivityOpen() then
    return
  end
  if not self:CheckInPeriod(constant.CMenPaiStarConst.VOTE_BATTLE_END_TIME) then
    Toast(textRes.MenpaiStar[19])
    return
  end
  local teamData = require("Main.Team.TeamData")
  if teamData.Instance():HasTeam() then
    Toast(textRes.MenpaiStar[52])
    return
  end
  local menpai = self:ServiceIdToMenpai(service)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if menpai == heroProp.occupation then
    if heroProp.level < constant.CMenPaiStarConst.VOTE_MIN_LEVEL then
      Toast(string.format(textRes.MenpaiStar[10], constant.CMenPaiStarConst.VOTE_MIN_LEVEL))
      return
    end
    do
      local serverLevel = require("Main.Server.ServerModule").Instance():GetServerLevelInfo().level
      if heroProp.level < serverLevel - constant.CMenPaiStarConst.VOTE_NOT_LESS_SERVER_LEVEL then
        Toast(string.format(textRes.MenpaiStar[11], constant.CMenPaiStarConst.VOTE_NOT_LESS_SERVER_LEVEL))
        return
      end
      local data = self:GetData()
      data:IsVoter(function(isVoter)
        if isVoter then
          Toast(textRes.MenpaiStar[12])
        else
          data:GetVoterChallengeTimes(function(times)
            if times < constant.CMenPaiStarConst.DAILY_VOTE_BATTLE_NUM then
              self:_voter()
            else
              Toast(textRes.MenpaiStar[9])
            end
          end)
        end
      end)
    end
  end
end
def.method("=>", "boolean").CheckActivityOpen = function(self)
  local isOpen = require("Main.activity.ActivityInterface").Instance():isActivityOpend2(constant.CMenPaiStarConst.ACTIVITY_CFG_ID)
  if not isOpen then
    Toast(textRes.MenpaiStar[17])
    return false
  else
    return true
  end
end
def.method("number", "=>", "boolean").CheckInPeriod = function(self, timeId)
  local curTime = GetServerTime()
  return require("Main.Common.TimeCfgUtils").IsInTimePeriod(timeId, curTime, curTime)
end
def.method("number", "=>", "number", "number").ServiceIdToMenpai = function(self, serviceId)
  local allMenpai = MenpaiStarUtils.GetAllMenpaiStarMainCfg()
  for k, v in ipairs(allMenpai) do
    if v.voteServiceId == serviceId or v.candidateServiceId == serviceId or v.voterServiceId == serviceId then
      return v.menpai, v.npcId
    end
  end
  return 0, 0
end
def.method("=>", "table").GetData = function(self)
  if self.data == nil then
    self.data = require("Main.MenpaiStar.MenpaiStarData")()
  end
  return self.data
end
def.method("userdata").RequestByRoleId = function(self, roleId)
  if not self:CheckFeatureOpen() then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CGetCampaignChart").new(roleId))
  self.requestRoleId = roleId
end
def.method("number", "number").RequestByMenpaiAndPage = function(self, menpai, page)
  if not self:CheckFeatureOpen() then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CCampaignChart").new(menpai, page))
  self.requestRoleId = nil
end
def.method().RequestMenpaiStarInfo = function(self)
  if require("Main.activity.ActivityInterface").Instance():isActivityOpend2(constant.CMenPaiStarConst.ACTIVITY_CFG_ID) then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CGetMenPaiStarInfo").new())
  else
    local SGetMenPaiStarInfoSuccess = require("netio.protocol.mzm.gsp.menpaistar.SGetMenPaiStarInfoSuccess")
    local MenPaiStarInfo = require("netio.protocol.mzm.gsp.menpaistar.MenPaiStarInfo")
    MenpaiStarModule.OnSGetMenPaiStarInfoSuccess(SGetMenPaiStarInfoSuccess.new(MenPaiStarInfo.new(0, 0, 0, 0, 0, 0, 0, nil, nil)))
  end
end
def.method("function").RequestAwardInfo = function(self, cb)
  if self.requestCallback == nil then
    self.requestCallback = {}
  end
  table.insert(self.requestCallback, cb)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CGetVoteAwardInfo").new())
end
def.method().ShowSetAward = function(self)
  if not self:CheckFeatureOpen() then
    return
  end
  if not self:CheckActivityOpen() then
    return
  end
  local data = self:GetData()
  data:IsCandidate(function(isCandidate)
    if not isCandidate then
      Toast(textRes.MenpaiStar[37])
      return
    end
    self:RequestAwardInfo(function(award, num)
      local awards = MenpaiStarUtils.GetVoteMoneyCfg()
      local nums = MenpaiStarUtils.GetVoteNumCfg()
      require("Main.MenpaiStar.ui.MenpaiStarReward").ShowMenpaiStarReward(awards, nums, award, num)
    end)
  end)
end
def.method("userdata", "number").Vote = function(self, roleId, num)
  if not self:CheckFeatureOpen() then
    return
  end
  if not self:CheckActivityOpen() then
    return
  end
  if not self:CheckInPeriod(constant.CMenPaiStarConst.VOTE_BATTLE_END_TIME) then
    Toast(textRes.MenpaiStar[18])
    return
  end
  local myLevel = require("Main.Hero.Interface").GetHeroProp().level
  local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CMenPaiStarConst.ACTIVITY_CFG_ID)
  if activityCfg and myLevel < activityCfg.levelMin then
    Toast(string.format(textRes.activity[383], activityCfg.levelMin))
    return
  end
  local data = self:GetData()
  data:GetVoteTimes(function(times)
    if times < 0 then
      Toast(textRes.MenpaiStar[1])
    elseif times < constant.CMenPaiStarConst.VOTE_NUM then
      self:_vote(roleId, num)
    elseif times == constant.CMenPaiStarConst.VOTE_NUM then
      Toast(textRes.MenpaiStar[2])
    end
  end)
end
def.method("userdata", "number")._vote = function(self, roleId, times)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CVote").new(roleId, times))
end
def.method()._candidate = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CStartCampaignFight").new())
end
def.method()._voter = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CStartVoteFight").new())
end
def.method("number", "number", "number").SetAward = function(self, award, num, leftNum)
  local ItemModule = require("Main.Item.ItemModule")
  local myYuanbao = ItemModule.Instance():GetAllYuanBao()
  local awardInfo = require("netio.protocol.mzm.gsp.menpaistar.VoteAwardInfo").new(award, num)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CSetAward").new(myYuanbao, awardInfo, leftNum))
end
local Second2Text = function(sec)
  if not (sec >= 0) or not sec then
    sec = 0
  end
  local hour = math.floor(sec / 3600)
  local minute = math.floor(sec % 3600 / 60)
  local second = sec % 60
  local text
  if hour > 0 then
    text = string.format("%02d%s%02d%s", hour, textRes.Common.Hour, minute, textRes.Common.Minute)
  elseif minute > 0 then
    text = string.format("%02d%s%02d%s", minute, textRes.Common.Minute, second, textRes.Common.Second)
  elseif second > 0 then
    text = string.format("%02d%s", second, textRes.Common.Second)
  else
    text = string.format("%02d%s", 1, textRes.Common.Second)
  end
  return text
end
def.method("userdata", "string", "number").CanvassInGang = function(self, roleId, name, money)
  if not self:CheckFeatureOpen() then
    return
  end
  if not self:CheckActivityOpen() then
    return
  end
  if not self:CheckInPeriod(constant.CMenPaiStarConst.VOTE_BATTLE_END_TIME) then
    Toast(textRes.MenpaiStar[18])
    return
  end
  local myLevel = require("Main.Hero.Interface").GetHeroProp().level
  local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CMenPaiStarConst.ACTIVITY_CFG_ID)
  if activityCfg and myLevel < activityCfg.levelMin then
    Toast(string.format(textRes.activity[383], activityCfg.levelMin))
    return
  end
  local hasGang = require("Main.Gang.GangModule").Instance():HasGang()
  if not hasGang then
    Toast(textRes.MenpaiStar[35])
    return
  end
  local data = self:GetData()
  data:GetGangCanvass(roleId, function(time)
    time = time or 0
    local diffTime = time + constant.CMenPaiStarConst.GANG_CHANNEL_CD * 60 - GetServerTime()
    if diffTime >= 0 then
      Toast(string.format(textRes.MenpaiStar[23], Second2Text(diffTime)))
    else
      require("Main.MenpaiStar.ui.MenpaiStarCanvass").ShowMenpaiStarCanvass(function(content)
        if content == "" then
          Toast(textRes.MenpaiStar[22])
          return
        end
        local finalContent = self:GetCanvassText(roleId, name, content, money)
        self:_canvassInGang(roleId, finalContent)
      end)
    end
  end)
end
def.method("userdata", "string")._canvassInGang = function(self, roleId, text)
  local textOctets = require("netio.Octets").rawFromString(text)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CGangCanvass").new(roleId, textOctets))
end
def.method("userdata", "string", "number").CanvassInWorld = function(self, roleId, name, money)
  if not self:CheckFeatureOpen() then
    return
  end
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_TRUMPET) then
    Toast(textRes.MenpaiStar[46])
    return
  end
  if not self:CheckActivityOpen() then
    return
  end
  local myLevel = require("Main.Hero.Interface").GetHeroProp().level
  local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(constant.CMenPaiStarConst.ACTIVITY_CFG_ID)
  if activityCfg and myLevel < activityCfg.levelMin then
    Toast(string.format(textRes.activity[383], activityCfg.levelMin))
    return
  end
  if not self:CheckInPeriod(constant.CMenPaiStarConst.VOTE_BATTLE_END_TIME) then
    Toast(textRes.MenpaiStar[18])
    return
  end
  local data = self:GetData()
  data:GetWorldCanvass(roleId, function(time)
    time = time or 0
    local diffTime = time + constant.CMenPaiStarConst.WORLD_CHANNEL_CD * 60 - GetServerTime()
    if diffTime >= 0 then
      Toast(string.format(textRes.MenpaiStar[23], Second2Text(diffTime)))
    else
      require("Main.MenpaiStar.ui.MenpaiStarCanvass").ShowMenpaiStarCanvass(function(content)
        if content == "" then
          Toast(textRes.MenpaiStar[22])
          return
        end
        local trumpetCfg = require("Main.Chat.Trumpet.TrumpetMgr").Instance():GetTrumpetCfgById(constant.CMenPaiStarConst.TRUMPET_CFG_ID)
        if trumpetCfg == nil then
          return
        end
        local labaId = trumpetCfg.itemid
        local labaNum = 1
        local title = textRes.MenpaiStar[24]
        local desc = string.format(textRes.MenpaiStar[25], name)
        require("Main.Item.ItemConsumeHelper").Instance():ShowItemConsume(title, desc, labaId, labaNum, function(result)
          if result == 0 then
            local finalContent = self:GetCanvassText(roleId, name, content, money)
            self:_canvassInWorld(roleId, finalContent, false)
          elseif result > 0 then
            local finalContent = self:GetCanvassText(roleId, name, content, money)
            self:_canvassInWorld(roleId, finalContent, true)
          end
        end)
      end)
    end
  end)
end
def.method("userdata", "string", "boolean")._canvassInWorld = function(self, roleId, text, useYb)
  local ItemModule = require("Main.Item.ItemModule")
  local myYuanbao = ItemModule.Instance():GetAllYuanBao()
  local textOctets = require("netio.Octets").rawFromString(text)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.menpaistar.CWorldCanvass").new(roleId, useYb and 1 or 0, myYuanbao, textOctets))
end
def.method("userdata", "string", "string", "number", "=>", "string").GetCanvassText = function(self, roleId, name, text, money)
  local cname = string.format("{color:%s,%s}", name, "ff8000")
  local link = string.format("{msv:%s,%s}", roleId:tostring(), textRes.MenpaiStar[29])
  if money > 0 then
    local award = string.format("{color:%s,%s}", tostring(money), "ff8000")
    return string.format(textRes.MenpaiStar[27], cname, text, link, cname, award)
  else
    return string.format(textRes.MenpaiStar[28], cname, text, link)
  end
end
def.method("=>", "boolean").CheckFeatureOpen = function(self)
  if IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MEN_PAI_STAR) then
    return true
  else
    Toast(textRes.MenpaiStar[38])
    return false
  end
end
MenpaiStarModule.Commit()
return MenpaiStarModule
