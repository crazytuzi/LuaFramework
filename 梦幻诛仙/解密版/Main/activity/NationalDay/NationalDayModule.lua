local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local NationalDayData = require("Main.activity.NationalDay.data.NationalDayData")
local NationalDayModule = Lplus.Extend(ModuleBase, "NationalDayModule")
local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local NationalDayUtils = require("Main.activity.NationalDay.NationalDayUtils")
local instance
local def = NationalDayModule.define
def.field("table").invite_infos = nil
def.field("table").break_egg_session = nil
def.field("table").sky_lanterns = nil
def.field("number").sky_lanterns_timer = 0
def.field("table").sky_lanterns_queue = nil
def.field("table").prayCfg = nil
def.field("table").composeCfg = nil
def.static("=>", NationalDayModule).Instance = function()
  if instance == nil then
    instance = NationalDayModule()
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  NationalDayData.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.birthdaypray.SSyncScheduleInfo", NationalDayModule.OnSSyncScheduleInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.birthdaypray.SSyncRewardInfoInfo", NationalDayModule.OnSSyncRewardInfoInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.birthdaypray.SReceiveRewardFail", NationalDayModule.OnSReceiveRewardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.birthdaypray.SAcceptTaskActivitySuccess", NationalDayModule.OnSAcceptTaskActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.breakegg.SSynInviteInfo", NationalDayModule.OnSSynInviteInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.breakegg.SSynInviteJoinInfo", NationalDayModule.OnSSynInviteJoinInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.breakegg.SBreakEggInviteFail", NationalDayModule.OnSBreakEggInviteFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.breakegg.SConfirmInviteFail", NationalDayModule.OnSConfirmInviteFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.breakegg.SSynRoleBreakEggInfo", NationalDayModule.OnSSynRoleBreakEggInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.breakegg.SSynBreakEggJoinInfo", NationalDayModule.OnSSynBreakEggJoinInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.breakegg.SSynBreakEggRewardInfo", NationalDayModule.OnSSynBreakEggRewardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.breakegg.SBreakEggFail", NationalDayModule.OnSBreakEggFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.breakegg.SBroadcastBreakEggRewardInfo", NationalDayModule.OnSBroadcastBreakEggRewardInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.cookiecake.SCreateItemFail", NationalDayModule.OnSCreateItemFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skylantern.SSynSendSkyLantern", NationalDayModule.OnSSynSendSkyLantern)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skylantern.SSendSkyLanternFail", NationalDayModule.OnSSendSkyLanternFail)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, NationalDayModule.OnEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, NationalDayModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, NationalDayModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.FinishSharing, NationalDayModule.OnShare)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, NationalDayModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, NationalDayModule.OnFeatureOpenInit)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, NationalDayModule.OnClickChatBtn)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, NationalDayModule.OnChangeMap)
end
def.method().StopBreakEggSessionTimer = function(self)
  if self.break_egg_session and self.break_egg_session.timerId and self.break_egg_session.timerId > 0 then
    GameUtil.RemoveGlobalTimer(self.break_egg_session.timerId)
    self.break_egg_session.timerId = 0
  end
end
def.method().SetMyRoleInfo = function(self)
  local myRoleInfo = NationalDayData.Instance():GetMyRoleInfo()
  local rolelist = {}
  rolelist[myRoleInfo.roleId] = myRoleInfo
  NationalDayData.Instance():SetBreakEggRolelist(rolelist)
end
def.method("=>", "boolean").IsInSession = function(self)
  return self.break_egg_session ~= nil and self.break_egg_session.end_time:gt(_G.GetServerTime())
end
def.method("number", "number", "number").AddToLanternList = function(self, effectId, x, y)
  if self.sky_lanterns_queue == nil then
    self.sky_lanterns_queue = {}
  end
  local effect_data = {
    id = effectId,
    x = x,
    y = y
  }
  table.insert(self.sky_lanterns_queue, effect_data)
  if self.sky_lanterns_timer == 0 then
    self.sky_lanterns_timer = GameUtil.AddGlobalTimer(1, false, NationalDayModule.ShowSkyLanternEffect)
  end
end
def.static().ShowSkyLanternEffect = function()
  if instance.sky_lanterns_queue == nil then
    return
  end
  local eff_data = table.remove(instance.sky_lanterns_queue, 1)
  if eff_data == nil then
    return
  end
  local eff_cfg = _G.GetEffectRes(eff_data.id)
  if eff_cfg then
    local effid = MapEffect_RequireRes(eff_data.x, world_height - eff_data.y, 1, {
      eff_cfg.path
    })
    if instance.sky_lanterns == nil then
      instance.sky_lanterns = {}
    end
    table.insert(instance.sky_lanterns, effid)
  end
end
def.method().RemoveAllLanterns = function(self)
  if self.sky_lanterns then
    for _, v in pairs(self.sky_lanterns) do
      if not _G.IsNil(v) then
        MapEffect_ReleaseRes(v)
      end
    end
    self.sky_lanterns = nil
  end
  self.sky_lanterns_queue = nil
  if self.sky_lanterns_timer > 0 then
    GameUtil.RemoveGlobalTimer(self.sky_lanterns_timer)
    self.sky_lanterns_timer = 0
  end
end
def.method().CheckPrayAward = function(self)
  if self.prayCfg == nil then
    self.prayCfg = NationalDayUtils.GetBirthPrayRewardCfg()
  end
  local prayTimes = NationalDayData.Instance():GetPrayTimes()
  local prayInfoMap = NationalDayData.Instance():GetPrayInfo()
  local is_claimable = false
  for idx, cfg in pairs(self.prayCfg) do
    local cur_num = prayTimes and prayTimes[cfg.id] or 0
    local prayInfo = prayInfoMap and prayInfoMap[cfg.id]
    local current_claimed = prayInfo and prayInfo.rewarded_stages
    local claimed_stage = current_claimed and current_claimed[#current_claimed] or 0
    local marks = cfg.stages
    for i = 1, #marks do
      if cur_num >= marks[i] and claimed_stage < cfg.stages[i] then
        is_claimable = true
        break
      end
    end
    if is_claimable then
      break
    end
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {
    activityId = constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID,
    isShowRedPoint = is_claimable
  })
end
def.static("table").OnSSyncScheduleInfo = function(p)
  NationalDayData.Instance():SetPrayTimes(p.task_activity_id2times)
  instance:CheckPrayAward()
  require("Main.activity.NationalDay.ui.PanelPray").Instance():UpdateUI()
end
def.static("table").OnSSyncRewardInfoInfo = function(p)
  NationalDayData.Instance():SetPrayInfo(p.task_activity_id2reward_stages)
  instance:CheckPrayAward()
  require("Main.activity.NationalDay.ui.PanelPray").Instance():UpdateUI()
end
def.static("table").OnSReceiveRewardFail = function(p)
  local msg = textRes.activity.NationalDay.ERROR[p.error_code] or textRes.activity.NationalDay.DCQF_ERROR[p.error_code]
  if msg then
    Toast(msg)
  else
    msg = textRes.activity.NationalDay.ERROR[0]
    Toast(string.format(msg, "SReceiveRewardFail", p.error_code))
  end
end
def.static("table").OnSAcceptTaskActivitySuccess = function(p)
  require("Main.activity.NationalDay.ui.PanelPray").Instance():DestroyPanel()
end
local BREAK_EGG_HELP = "BREAK_EGG_HELP_"
def.static("table").OnSSynInviteInfo = function(p)
  local inviteCfg = NationalDayUtils.GetInviteConfirmCfg(p.invite_type)
  if instance.invite_infos == nil then
    instance.invite_infos = {}
  end
  local inviterId = p.inviter_info.roleId:tostring()
  instance.invite_infos[inviterId] = p
  if inviteCfg then
    local ChatModule = require("Main.Chat.ChatModule")
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    local msgStr = string.format("%1$s {breakegg:%s,%s,%s}", inviteCfg.inviteDes, BREAK_EGG_HELP .. inviterId, link_defalut_color, textRes.activity.NationalDay[5])
    local roleId = p.inviter_info.roleId
    local roleName = p.inviter_info.roleName
    local gender = p.inviter_info.gender
    local occupationId = p.inviter_info.occupationId
    local avatarId = p.inviter_info.avatarId
    local avatarFrameId = p.inviter_info.avatarFrameId
    local level = p.inviter_info.roleLevel
    local memberInfo = require("Main.Gang.GangModule").Instance().data:GetMemberInfoByRoleId(roleId)
    if not memberInfo then
      return
    end
    local vipLevel = 0
    local modelId = 0
    local badge = {}
    local contentType = require("netio.protocol.mzm.gsp.chat.ChatConsts").CONTENT_NORMAL
    local content = require("netio.Octets").rawFromString(msgStr)
    local position = require("Main.Gang.GangUtility").GetDutyLv(memberInfo.duty)
    require("Main.Question.QuestionModule").SendFakeFactionProtocol(roleId, roleName, gender, occupationId, level, vipLevel, modelId, badge, contentType, content, position, avatarId, avatarFrameId)
  end
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  if myId:eq(p.inviter_info.roleId) then
    instance:StopBreakEggSessionTimer()
    instance.break_egg_session = {}
    instance.break_egg_session.inviter = myId
    instance.break_egg_session.end_time = p.end_time
    instance.break_egg_session.timerId = GameUtil.AddGlobalTimer(1, false, function()
      local left_time = p.end_time - _G.GetServerTime()
      left_time = left_time:ToNumber()
      require("Main.activity.NationalDay.ui.PanelBreakEgg").Instance():UpdateTime(left_time)
      if left_time <= 0 then
        instance:StopBreakEggSessionTimer()
        instance.break_egg_session = nil
      end
    end)
  end
end
def.static("table", "table").OnClickChatBtn = function(p1, p2)
  local tag = p1 and p1.id
  if tag and string.find(tag, BREAK_EGG_HELP) == 1 then
    if instance.invite_infos == nil then
      return
    end
    local inviterId = string.sub(tag, #BREAK_EGG_HELP + 1, -1)
    local invite_info = instance.invite_infos[inviterId]
    if invite_info == nil then
      return
    end
    if invite_info.end_time:lt(_G.GetServerTime()) then
      Toast(textRes.activity.NationalDay[6])
      return
    end
    local pro = require("netio.protocol.mzm.gsp.breakegg.CConfirmInviteRep").new()
    pro.invite_type = invite_info.invite_type
    pro.sessionid = invite_info.session_id
    pro.reply = pro.REPLY_ACCEPT
    gmodule.network.sendProtocol(pro)
  end
end
def.static("table").OnSSynInviteJoinInfo = function(p)
  local cur_time = _G.GetServerTime()
  local diff = p.end_time - cur_time
  diff = diff:ToNumber()
  if diff <= 0 then
    return
  end
  instance:StopBreakEggSessionTimer()
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  local isInviter = myId:eq(p.inviter_id)
  NationalDayData.Instance():SetIsInviter(isInviter)
  instance.break_egg_session = {}
  instance.break_egg_session.inviter = p.inviter_id
  instance.break_egg_session.end_time = p.end_time
  NationalDayData.Instance():SetBreakEggRolelist(p.role_info_list)
  instance.break_egg_session.timerId = GameUtil.AddGlobalTimer(1, false, function()
    if instance.break_egg_session == nil then
      return
    end
    local left_time = p.end_time - _G.GetServerTime()
    left_time = left_time:ToNumber()
    require("Main.activity.NationalDay.ui.PanelBreakEgg").Instance():UpdateTime(left_time)
    if left_time <= 0 then
      local phase = NationalDayData.Instance():GetBreakEggPhase()
      if phase == NationalDayData.BREAK_EGG_PHASE.PERFORM or phase == NationalDayData.BREAK_EGG_PHASE.PRE_PERFORM then
        return
      end
      instance:StopBreakEggSessionTimer()
      instance.break_egg_session = nil
      NationalDayData.Instance():ResetBreakEggData()
      if isInviter then
        instance:SetMyRoleInfo()
        require("Main.activity.NationalDay.ui.PanelBreakEgg").ShowPanel()
      else
        require("Main.activity.NationalDay.ui.PanelBreakEgg").Instance():DestroyPanel()
      end
    end
  end)
  NationalDayData.Instance():SetBreakEggPhase(NationalDayData.BREAK_EGG_PHASE.PREPARE)
  require("Main.activity.NationalDay.ui.PanelBreakEgg").ShowPanel()
end
def.static("table").OnSBreakEggInviteFail = function(p)
  local msg = textRes.activity.NationalDay.ERROR[p.error_code] or textRes.activity.NationalDay.INVITE_ERROR[p.error_code]
  if msg then
    Toast(msg)
  else
    msg = textRes.activity.NationalDay.ERROR[0]
    Toast(string.format(msg, "SBreakEggInviteFail", p.error_code))
  end
end
def.static("table").OnSConfirmInviteFail = function(p)
  local msg = textRes.activity.NationalDay.ERROR[p.error_code] or textRes.activity.NationalDay.INVITE_CONFIRM_ERROR[p.error_code]
  if msg then
    Toast(msg)
  else
    msg = textRes.activity.NationalDay.ERROR[0]
    Toast(string.format(msg, "SConfirmInviteFail", p.error_code))
  end
end
def.static("table").OnSSynRoleBreakEggInfo = function(p)
  local break_egg_cfg = NationalDayUtils.GetBreakEggCfg(p.activity_id)
  if break_egg_cfg and p.reward_times >= break_egg_cfg.inviteeRewardTimes then
    Toast(textRes.activity.NationalDay[4])
  end
end
def.static("table").OnSSynBreakEggJoinInfo = function(p)
  instance:StopBreakEggSessionTimer()
  instance.break_egg_session = {}
  instance.break_egg_session.inviter = p.inviter_id
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  local isInviter = myId:eq(p.inviter_id)
  NationalDayData.Instance():SetIsInviter(isInviter)
  instance.break_egg_session.end_time = p.end_time
  NationalDayData.Instance():SetBreakEggRolelist(p.role_info_list)
  NationalDayData.Instance():SetBreakEggPhase(NationalDayData.BREAK_EGG_PHASE.PRE_PERFORM)
  require("Main.activity.NationalDay.ui.PanelBreakEgg").ShowPanel()
  GameUtil.AddGlobalTimer(2, true, function()
    if instance.break_egg_session == nil then
      return
    end
    NationalDayModule.StartBreakEggPhase(p)
  end)
end
def.static("table").StartBreakEggPhase = function(p)
  local cur_time = _G.GetServerTime()
  local diff = p.end_time - cur_time
  diff = diff:ToNumber()
  if diff <= 0 then
    return
  end
  local function Tick()
    if instance.break_egg_session == nil then
      return
    end
    local left_time = p.end_time - _G.GetServerTime()
    left_time = left_time:ToNumber()
    require("Main.activity.NationalDay.ui.PanelBreakEgg").Instance():UpdateTime(left_time)
    if left_time <= 0 then
      instance:StopBreakEggSessionTimer()
    end
  end
  instance.break_egg_session.timerId = GameUtil.AddGlobalTimer(1, false, Tick)
  NationalDayData.Instance():SetBreakEggPhase(NationalDayData.BREAK_EGG_PHASE.PERFORM)
  require("Main.activity.NationalDay.ui.PanelBreakEgg").ShowPanel()
  Tick()
end
def.static("table").OnSSynBreakEggRewardInfo = function(p)
  if instance.break_egg_session == nil then
    return
  end
  NationalDayData.Instance():SetBreakEggResult(p.index2break_egg_info)
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  for _, v in pairs(p.index2break_egg_info) do
    if v.role_id:eq(myId) then
      instance:StopBreakEggSessionTimer()
      local itemId, itemNum = next(v.itemId2num)
      require("Main.activity.NationalDay.ui.PanelBreakEgg").Instance():ShowGetItem({itemId})
    end
  end
  require("Main.activity.NationalDay.ui.PanelBreakEgg").Instance():ShowResult()
  local break_egg_cfg = NationalDayUtils.GetBreakEggCfg(p.activity_id)
  local result = NationalDayData.Instance():GetBreakEggResult()
  if result and table.nums(result) == break_egg_cfg.totalEggNum then
    local isInviter = NationalDayData.Instance():GetIsInviter()
    if isInviter then
      local items = {}
      for _, v in pairs(result) do
        if v.role_id:gt(0) then
          local itemId, itemNum = next(v.itemId2num)
          table.insert(items, itemId)
        end
      end
      require("Main.activity.NationalDay.ui.PanelBreakEgg").Instance():ShowGetItem(items)
    end
    NationalDayData.Instance():ResetBreakEggData()
    instance:StopBreakEggSessionTimer()
    instance.break_egg_session = nil
  end
end
def.static("table").OnSBreakEggFail = function(p)
  local msg = textRes.activity.NationalDay.ERROR[p.error_code] or textRes.activity.NationalDay.BREAK_EGG_ERROR[p.error_code]
  if msg then
    Toast(msg)
  else
    msg = textRes.activity.NationalDay.ERROR[0]
    Toast(string.format(msg, "SBreakEggFail", p.error_code))
  end
end
def.static("table").OnSCreateItemFail = function(p)
  local msg = textRes.activity.NationalDay.ERROR[p.error_code] or textRes.activity.NationalDay.MOONCAKE_ERROR[p.error_code]
  if msg then
    Toast(msg)
  else
    msg = textRes.activity.NationalDay.ERROR[0]
    Toast(string.format(msg, "SCreateItemFail", p.error_code))
  end
end
def.static("table").OnSSynSendSkyLantern = function(p)
  local cfg = NationalDayUtils.GetSkyLanternCfg(constant.CMidAutumnHolidayConst.SKY_LANTERN_ID)
  local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  if p.role_id:eq(myId) then
    instance:AddToLanternList(cfg.selfEffectId, cfg.mapTransferX, cfg.mapTransferY)
  elseif instance.sky_lanterns == nil or #instance.sky_lanterns < cfg.maxLanternNum then
    local rx = math.random(0, 400)
    local ry = math.random(0, 400)
    instance:AddToLanternList(cfg.otherEffectId, cfg.mapTransferX - rx + 200, cfg.mapTransferY - ry + 200)
  end
end
def.static("table").OnSSendSkyLanternFail = function(p)
  local msg = textRes.activity.NationalDay.ERROR[p.error_code] or textRes.activity.NationalDay.SKY_LANTERN_ERROR[p.error_code]
  if msg then
    Toast(msg)
  else
    msg = textRes.activity.NationalDay.ERROR[0]
    Toast(string.format(msg, "SSendSkyLanternFail", p.error_code))
  end
end
def.static("table").OnSBroadcastBreakEggRewardInfo = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local ChatModule = require("Main.Chat.ChatModule")
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  for k, v in pairs(p.break_egg_info) do
    local itemId, itemNum = next(v.itemId2num)
    local itemBase = ItemUtils.GetItemBase(itemId)
    local itemName = itemBase.name
    local color = HtmlHelper.NameColor[itemBase.namecolor]
    if color then
      itemName = string.format("<font color=#%s>%s</font>", color, itemName)
    end
    local msg
    if v.role_id:eq(p.inviter_id) then
      msg = string.format(textRes.activity.NationalDay[21], v.role_name, itemName)
    else
      msg = string.format(textRes.activity.NationalDay[19], v.role_name, p.inviter_name, itemName)
    end
    ChatModule.Instance():SendNoteMsg(msg, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
end
def.static("table", "table").OnLeaveWorld = function()
  instance:StopBreakEggSessionTimer()
  instance.break_egg_session = nil
  NationalDayData.Instance():Reset()
  instance:RemoveAllLanterns()
  instance.prayCfg = nil
  instance.composeCfg = nil
end
def.static("table", "table").OnEnterWorld = function()
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_GUO_QING_MAKE_CAKES)
  if isOpen then
    NationalDayModule.OnBagInfoSynchronized(nil, nil)
  end
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1 and p1[1]
  if activityId == constant.CNationalHolidayConst.NATIONAL_HOLIDAY_SHARE_ID then
    local cfg = NationalDayData.Instance():GetShareCfg(UseType.JIERI_SHARE__GUOQING)
    if cfg then
      local isOpen = _G.IsFeatureOpen(Feature.TYPE_SHARE__GUO_QING)
      local activityInterface = require("Main.activity.ActivityInterface").Instance()
      if isOpen then
        require("Main.Common.CommonSharePanel").Instance():ShowPanel(UseType.JIERI_SHARE__GUOQING, cfg.link)
      end
    end
  elseif activityId == constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID then
    require("Main.activity.NationalDay.ui.PanelPray").ShowPanel()
  elseif activityId == constant.CNationalHolidayConst.BREAK_EGG_ID then
    local myId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
    if instance.break_egg_session == nil then
      instance:SetMyRoleInfo()
    end
    require("Main.activity.NationalDay.ui.PanelBreakEgg").ShowPanel()
  elseif activityId == constant.CMidAutumnHolidayConst.COOKIE_CAKE_ID then
    require("Main.activity.NationalDay.ui.PanelXLSQ").ShowPanel()
  elseif activityId == constant.CMidAutumnHolidayConst.SKY_LANTERN_ID then
    local activityInfo = require("Main.activity.ActivityInterface").Instance():GetActivityInfo(constant.CMidAutumnHolidayConst.SKY_LANTERN_ID)
    if activityInfo and activityInfo.count > 0 then
      Toast(textRes.activity.NationalDay[14])
      return
    end
    local cfg = NationalDayUtils.GetSkyLanternCfg(constant.CMidAutumnHolidayConst.SKY_LANTERN_ID)
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    heroModule:MoveTo(cfg.mapCfgId, cfg.mapTransferX, cfg.mapTransferY, -1, 0, MoveType.AUTO, function()
      instance:ShowSendGreetingCard()
    end)
  end
end
def.method().ShowSendGreetingCard = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GUO_QING_WATCH_LANTERN) then
    Toast(textRes.Chat[87])
    return
  end
  local cfg = require("Main.Chat.GreetingCard.GreetingCardMgr").Instance():GetGreetingCardCfg(217200002)
  if cfg then
    require("Main.Chat.GreetingCard.ui.GreetingCardEdit").ShowGreetingCardEdit(cfg, function(text, ui, channel)
      if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_GUO_QING_WATCH_LANTERN) then
        Toast(textRes.Chat[87])
        return
      end
      local pro = require("netio.protocol.mzm.gsp.skylantern.CSendSkyLanternReq").new()
      pro.activity_id = constant.CMidAutumnHolidayConst.SKY_LANTERN_ID
      pro.channel = channel
      local Octets = require("netio.Octets")
      pro.data = require("netio.protocol.mzm.gsp.greetingcard.GreetingCardData").new(cfg.id, Octets.rawFromString(text), ui)
      gmodule.network.sendProtocol(pro)
    end)
  end
end
def.static("table", "table").OnShare = function(p1, p2)
  if p1 == nil then
    return
  end
  if p1.shareType == UseType.JIERI_SHARE__GUOQING and p1.flag == 0 then
    local GiftAwardMgr = require("Main.Award.mgr.GiftAwardMgr")
    GiftAwardMgr.Instance():DrawAward(UseType.JIERI_SHARE__GUOQING)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  if p1 == nil then
    return
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if p1.feature == Feature.TYPE_SHARE__GUO_QING then
    local isOpen = _G.IsFeatureOpen(Feature.TYPE_SHARE__GUO_QING)
    if isOpen then
      activityInterface:removeCustomCloseActivity(constant.CNationalHolidayConst.NATIONAL_HOLIDAY_SHARE_ID)
    else
      activityInterface:addCustomCloseActivity(constant.CNationalHolidayConst.NATIONAL_HOLIDAY_SHARE_ID)
    end
  elseif p1.feature == Feature.TYPE_GUO_QING_BIRTHDAY_PRAY or p1.feature == Feature.TYPE_SINGLE_TASK_HUI_YI_WANG_XI then
    local taskCfg = NationalDayUtils.GetBirthPrayCfg(constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID)
    if p1.feature == taskCfg.idip then
      local isOpen = _G.IsFeatureOpen(p1.feature)
      if isOpen then
        activityInterface:removeCustomCloseActivity(constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID)
      else
        activityInterface:addCustomCloseActivity(constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID)
        require("Main.activity.NationalDay.ui.PanelPray").Instance():DestroyPanel()
      end
    end
  elseif p1.feature == Feature.TYPE_GUO_QING_BREAK_EGG then
    local isOpen = _G.IsFeatureOpen(Feature.TYPE_GUO_QING_BREAK_EGG)
    if isOpen then
      activityInterface:removeCustomCloseActivity(constant.CNationalHolidayConst.BREAK_EGG_ID)
    else
      activityInterface:addCustomCloseActivity(constant.CNationalHolidayConst.BREAK_EGG_ID)
      require("Main.activity.NationalDay.ui.PanelBreakEgg").Instance():DestroyPanel()
    end
  elseif p1.feature == Feature.TYPE_GUO_QING_MAKE_CAKES then
    local isOpen = _G.IsFeatureOpen(Feature.TYPE_GUO_QING_MAKE_CAKES)
    if isOpen then
      activityInterface:removeCustomCloseActivity(constant.CMidAutumnHolidayConst.COOKIE_CAKE_ID)
      Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, NationalDayModule.OnBagInfoSynchronized)
    else
      activityInterface:addCustomCloseActivity(constant.CMidAutumnHolidayConst.COOKIE_CAKE_ID)
      require("Main.activity.NationalDay.ui.PanelXLSQ").Instance():DestroyPanel()
      Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, NationalDayModule.OnBagInfoSynchronized)
    end
  elseif p1.feature == Feature.TYPE_GUO_QING_WATCH_LANTERN then
    local isOpen = _G.IsFeatureOpen(Feature.TYPE_GUO_QING_WATCH_LANTERN)
    if isOpen then
      activityInterface:removeCustomCloseActivity(constant.CMidAutumnHolidayConst.SKY_LANTERN_ID)
    else
      activityInterface:addCustomCloseActivity(constant.CMidAutumnHolidayConst.SKY_LANTERN_ID)
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local taskCfg = NationalDayUtils.GetBirthPrayCfg(constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID)
  local features = {
    {
      idip = Feature.TYPE_SHARE__GUO_QING,
      activityId = constant.CNationalHolidayConst.NATIONAL_HOLIDAY_SHARE_ID
    },
    {
      idip = taskCfg.idip,
      activityId = constant.CNationalHolidayConst.BIRTHDAYP_RAY_ID
    },
    {
      idip = Feature.TYPE_GUO_QING_BREAK_EGG,
      activityId = constant.CNationalHolidayConst.BREAK_EGG_ID
    },
    {
      idip = Feature.TYPE_GUO_QING_MAKE_CAKES,
      activityId = constant.CMidAutumnHolidayConst.COOKIE_CAKE_ID
    },
    {
      idip = Feature.TYPE_GUO_QING_WATCH_LANTERN,
      activityId = constant.CMidAutumnHolidayConst.SKY_LANTERN_ID
    }
  }
  for _, v in pairs(features) do
    local isOpen = _G.IsFeatureOpen(v.idip)
    if isOpen then
      activityInterface:removeCustomCloseActivity(v.activityId)
      if v.idip == Feature.TYPE_GUO_QING_BIRTHDAY_PRAY then
        Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, NationalDayModule.OnBagInfoSynchronized)
      end
    else
      activityInterface:addCustomCloseActivity(v.activityId)
    end
  end
end
def.static("table", "table").OnChangeMap = function(p1, p2)
  instance:RemoveAllLanterns()
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  if instance.composeCfg == nil then
    instance.composeCfg = NationalDayUtils.GetMooncakeComposeCfg(1)
  end
  local products = instance.composeCfg.products
  for k, v in pairs(products) do
    local isAllMatched = true
    for idx, itemId in pairs(v.itemIds) do
      local num = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetItemCountById(itemId)
      if num < v.itemNums[idx] then
        isAllMatched = false
        break
      end
    end
    if isAllMatched then
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {
        activityId = constant.CMidAutumnHolidayConst.COOKIE_CAKE_ID,
        isShowRedPoint = isAllMatched
      })
      return
    end
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Set_RedPoint, {
    activityId = constant.CMidAutumnHolidayConst.COOKIE_CAKE_ID,
    isShowRedPoint = false
  })
end
return NationalDayModule.Commit()
