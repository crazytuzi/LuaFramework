local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GangUtility = require("Main.Gang.GangUtility")
local GangBuildingEnum = require("netio.protocol.mzm.gsp.gang.GangBuildingEnum")
local GangModule = Lplus.Extend(ModuleBase, "GangModule")
local def = GangModule.define
local instance
local GangData = require("Main.Gang.data.GangData")
local GangBuildDonatePanel = require("Main.Gang.ui.GangBuildDonatePanel")
local ItemUtils = require("Main.Item.ItemUtils")
def.field(GangData).data = nil
def.field("boolean").bMainUICreate = false
def.static("=>", GangModule).Instance = function()
  if instance == nil then
    instance = GangModule()
    instance.m_moduleId = ModuleId.GANG
    instance.data = GangData.Instance()
  end
  return instance
end
def.override().Init = function(self)
  self.bMainUICreate = false
  Timer:RegisterIrregularTimeListener(self.Update, self)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GANG_CLICK, GangModule.OnGangPanelIconClick)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.BtnClickInChat, GangModule.OnChatBtnClick)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, GangModule.OnGangRobberClick)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, GangModule.OnMainUIReady)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, GangModule.OnNPCService)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_TaskTraceNotifyAnother, GangModule.OnTask)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, GangModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Huanhun_GangHelInfoChange, GangModule.OnGangHelInfoChange)
  local NPCInterface = require("Main.npc.NPCInterface")
  local npcInterface = NPCInterface.Instance()
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  npcInterface:RegisterNPCServiceCustomCondition(NPCServiceConst.GangGetRecipe, GangModule.OnNPCService_GangGetRecipeCondition)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangInfo", GangModule.OnSSyncGangInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncSelfInfo", GangModule.OnSSyncSelfInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SGetGangListRes", GangModule.OnSGetGangListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSearchGangListRes", GangModule.OnSSearchGangListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SGangNormalResult", GangModule.OnSGangNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SInviteJoinGang", GangModule.OnSInviteJoinGang)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncAddGangMember", GangModule.OnSSyncAddGangMember)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SJoinGangRes", GangModule.OnSJoinGangRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SGetRoleModelRes", GangModule.OnSGetRoleModelRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SGetRoleInfoRes", GangModule.OnSGetRoleInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncApplicants", GangModule.OnSSyncApplicants)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SAddApplicantBrd", GangModule.OnSSAddApplicantBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SRemoveApplicantBrd", GangModule.OnSSRemoveApplicantBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncQuitGang", GangModule.OnSSyncQuitGang)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncClearApplyList", GangModule.OnSSyncClearApplyList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncRename", GangModule.OnSSyncRename)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncDesignDutyName", GangModule.OnSSyncDesignDutyName)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncNewGangPurpose", GangModule.OnSSyncNewGangPurpose)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncKickOutMember", GangModule.OnSSyncKickOutMember)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncTanHe", GangModule.OnSSyncTanHe)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncCancelTanHe", GangModule.OnSSyncCancelTanHe)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncMemberInfoChange", GangModule.OnSSyncMemberInfoChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SForbiddenTalkRes", GangModule.OnSForbiddenTalkRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncForbiddenTalk", GangModule.OnSSyncForbiddenTalk)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncUnForbiddenTalk", GangModule.OnSSyncUnForbiddenTalk)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SUnForbiddenTalkRes", GangModule.OnSUnForbiddenTalkRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SKickOutMemberRes", GangModule.OnSKickOutMemberRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncXueTuMaxLevelChange", GangModule.OnSSyncXueTuMaxLevelChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncMemberOffline", GangModule.OnSSyncMemberOffline)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncMemberLogin", GangModule.OnSSyncMemberOnline)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncChangeDuty", GangModule.OnSSyncChangeDuty)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangMoneyChange", GangModule.OnSSyncGangMoneyChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangVitalityChange", GangModule.OnSSyncGangVitalityChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangLevelDownDuty", GangModule.OnSSyncGangLevelDownDuty)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangMaintain", GangModule.OnSSyncGangMaintain)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncSystemKickOut", GangModule.OnSSyncSystemKickOut)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangDissolve", GangModule.OnSSyncGangDissolve)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncTanHeSuccess", GangModule.OnSSyncTanHeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SPublicAnnouncementRes", GangModule.OnSPublicAnnouncementRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncAnnouncement", GangModule.OnSSyncAnnouncement)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseGangFileItemRes", GangModule.OnSUseGangFileItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncBangGongChange", GangModule.OnSSyncBangGongChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncGangRobberEvent", GangModule.OnSSyncGangRobberEvent)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncGangRobberCounter", GangModule.OnSSyncGangRobberCounter)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncGangRobberBornEvent", GangModule.OnSSyncGangRobberBornEvent)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncFightRobberTipRes", GangModule.OnSSyncFightRobberTipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.activity.SSyncVisibleMonsterReward", GangModule.OnSSyncVisibleMonsterReward)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncRejectJoinGang", GangModule.OnSSyncRejectJoinGang)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangHelp", GangModule.OnSSyncGangHelp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncBuildingStartLevelUp", GangModule.OnSSyncBuildingStartLevelUp)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncCallBuildingLevelUpDonate", GangModule.OnSSyncCallBuildingLevelUpDonate)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncBuildingLevelUpDonate", GangModule.OnSSyncBuildingLevelUpDonate)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncBuildingLevelUpSuccess", GangModule.OnSSyncBuildingLevelUpSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSilver2banggongRes", GangModule.OnSSilver2banggongRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SYuanBao2banggongRes", GangModule.OnSYuanBao2banggongRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangMapCreate", GangModule.OnSSyncGangMapCreate)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SYaoDianInfoRes", GangModule.OnSYaoDianInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SBuyYaoCaiRes", GangModule.OnSBuyYaoCaiRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangYaoCaiNumChange", GangModule.OnSSyncGangYaoCaiNumChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangMiFangTrigger", GangModule.OnSSyncGangMiFangTrigger)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangMiFangInfo", GangModule.OnSSyncGangMiFangInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SUseMiFangRes", GangModule.OnSUseMiFangRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangMiFangOutOfUse", GangModule.OnSSyncGangMiFangOutOfUse)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangMiFangTimeEnd", GangModule.OnSSyncGangMiFangTimeEnd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncMiFangCountChange", GangModule.OnSSyncMiFangCountChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncMiFangLevelNotEqual", GangModule.OnSSyncMiFangLevelNotEqual)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncFuLiInfo", GangModule.OnSSyncFuLiInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SGetFuLiRes", GangModule.OnSGetFuLiRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SDispatchLiHeRes", GangModule.OnSDispatchLiHeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncCangKuLiHeChange", GangModule.OnSSyncCangKuLiHeChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SGangSignReq", GangModule.OnSGangSignReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangSignReq", GangModule.OnSSyncGangSignReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SChangeSignStrReq", GangModule.OnSChangeSignStrReq)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SGetSignState", GangModule.OnSGetSignState)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SOutGangNotify", GangModule.OnSOutGangNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncMemberGongXunBrd", GangModule.OnSSyncMemberGongXunBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SRefreshGongXunRes", GangModule.OnSRefreshGongXunRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SGetCombineGangListRes", GangModule.OnSGetCombineGangListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SCombineGangApplyRes", GangModule.OnSCombineGangApplyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SCombineGangApplyTrs", GangModule.OnSCombineGangApplyTrs)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SCombineGangApplyResultBrd", GangModule.OnSCombineGangApplyResultBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SCombineGangCancelBrd", GangModule.OnSCombineGangCancelBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SGangCombineBrd", GangModule.OnSGangCombineBrd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SCombineGangApplicantsRes", GangModule.OnSCombineGangApplicantsRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncCombine", GangModule.OnSSyncCombine)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SKickByCombineNotify", GangModule.OnSKickByCombineNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSyncGangQQGroupRes", GangModule.OnSSyncGangQQGroupRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gang.SSetLeaveGangWithQQGroup", GangModule.OnSSetLeaveGangWithQQGroup)
  require("Main.Gang.GangBattleMgr").Instance():Init()
  require("Main.Gang.GangTeamMgr").Instance():Init()
  require("Main.Gang.GodMedicine.GodMedicineMgr").Instance():Init()
  ModuleBase.Init(self)
end
def.override().LateInit = function(self)
  gmodule.moduleMgr:GetModule(ModuleId.ACTIVITY):RegisterActivityTipFunc(constant.CCompetitionConsts.GANG_BATTLE_ACTIVITYID, require("Main.Gang.GangBattleMgr").CheckValid)
end
def.override().OnReset = function(self)
  self.bMainUICreate = false
  local data = self.data
  data:SetAllNull()
  GangUtility.Instance().gangActivityRedPoint = nil
end
def.static("table", "table").OnMainUIReady = function(params, tbl)
  local data = GangModule.Instance().data
  local display = data:GetLastAnnouncementContene()
  if display ~= "" then
    GangModule.ShowInGangChannel(textRes.Gang[15] .. display)
  end
  GangModule.Instance().bMainUICreate = true
  if data:IsTiggerMifang() then
    local cfgId = data:GetTiggerMifangCfgId()
    local mifangInfo = GangUtility.GetMifangInfo(cfgId)
    local npcId = constant.GangMiFangConsts.GANGMIFANG_NPC_ID
    local npcRec = require("Main.npc.NPCInterface").GetNPCCfg(npcId)
    local content = string.format(textRes.Gang[175], mifangInfo.miFangName, npcRec.npcName)
    local button = string.format("<a href='btn_mifang' id=btn_mifang><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.Gang[260])
    local str = string.format("%s%s", content, button)
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
  if data:GetIsKickedOffline() == true then
    data:SetIsKickedOffline(false)
    GangUtility.ShowRejoinGangPrompt()
  end
end
def.static("table", "table").OnGangPanelIconClick = function()
  if _G.CheckCrossServerAndToast() then
    return
  end
  local unlockLevel = GangUtility.GetGangConsts("OPEN_LEVEL")
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if unlockLevel > heroProp.level then
    Toast(string.format(textRes.Skill[7], unlockLevel))
    return
  end
  local data = GangModule.Instance().data
  local gangId = data:GetGangId()
  if gangId == nil then
    require("Main.Gang.ui.NoGangPanel").Instance():ShowPanel()
  else
    require("Main.Gang.ui.HaveGangPanel").Instance():ShowPanel()
  end
end
def.static("table", "table").OnChatBtnClick = function(params, tbl)
  local id = params.id
  if string.sub(id, 1, #"applyGang_") == "applyGang_" then
    local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    local inLevel = GangUtility.GetGangConsts("JOIN_MIN_LEVEL")
    if inLevel > heroProp.level then
      Toast(string.format(textRes.Gang[92], inLevel))
      return
    end
    local bHaveGang = GangModule.Instance():HasGang()
    if bHaveGang then
      Toast(textRes.Gang[98])
      return
    end
    local strId = string.sub(id, #"applyGang_" + 1, -1)
    local gangId = Int64.ParseString(strId)
    GangModule.Instance():ApplyGang(gangId)
  elseif string.sub(id, 1, #"gangHelp_") == "gangHelp_" then
    local strs = string.split(id, "_")
    local params = {}
    table.insert(params, tonumber(strs[1]))
    for i = 2, #strs do
      table.insert(params, strs[i])
    end
    params[1] = tonumber(params[1])
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpBtn, params)
  elseif string.sub(id, 1, #"build_") == "build_" then
    local type = tonumber(string.sub(id, #"build_" + 1, -1))
    local gangInfo = GangData.Instance():GetGangBasicInfo()
    if type == GangBuildingEnum.JINKU and gangInfo.coffersEndTime <= 0 then
      Toast(textRes.Gang[110])
      return
    elseif type == GangBuildingEnum.XIANGFANG and 0 >= gangInfo.wingEndTime then
      Toast(textRes.Gang[110])
      return
    elseif type == GangBuildingEnum.YAODIAN and 0 >= gangInfo.pharmacyEndTime then
      Toast(textRes.Gang[110])
      return
    elseif type == GangBuildingEnum.CANGKU and 0 >= gangInfo.warehouseEndTime then
      Toast(textRes.Gang[110])
      return
    elseif type == GangBuildingEnum.GANG and 0 >= gangInfo.buildEndTime then
      Toast(textRes.Gang[110])
      return
    elseif type == GangBuildingEnum.SHUYUAN and 0 >= gangInfo.bookEndTime then
      Toast(textRes.Gang[110])
      return
    end
    GangBuildDonatePanel.ShowDonateBuildPanel(type)
  elseif string.sub(id, 1, #"mifang") == "mifang" then
    GangModule.Instance():GotoGangMap()
  elseif string.sub(id, 1, #"gangRobber") == "gangRobber" then
    GangModule.Instance():GotoGangMap()
  end
end
def.static("table", "table").OnGangRobberClick = function(params, tbl)
  local id = params[1]
  if id == require("Main.activity.ActivityInterface").GangRobber_ACTIVITY_ID then
    local hasGang = GangModule.Instance():HasGang()
    if hasGang then
      GangModule.Instance():GotoGangMap()
    else
      Toast(textRes.Gang[103])
    end
  end
end
def.static("table", "table").OnNPCService = function(params, tbl)
  local serviceID = params[1]
  local NPCServiceConst = require("Main.npc.NPCServiceConst")
  if serviceID == NPCServiceConst.GangBuild then
    local GangLevelUpPanel = require("Main.Gang.ui.GangLevelUp.GangLevelUpPanel")
    GangLevelUpPanel.ShowGangLevelUpPanel()
  elseif serviceID == NPCServiceConst.GangGetRecipe then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGetGangMiFangReq").new())
  end
end
def.static("table", "table").OnHeroLevelUp = function(params, tbl)
  local unlockLevel = GangUtility.GetGangConsts("OPEN_LEVEL")
  local curLevel, lastLevel = params.level, params.lastLevel
  if unlockLevel <= curLevel and unlockLevel > lastLevel then
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {0})
  end
end
def.static("table", "table").OnTask = function(params, tbl)
  local data = GangModule.Instance().data
  if data:IsGetMifang() then
    require("Main.Gang.ui.GangMifangMakeDrugPanel").ShowGangDrugPanel()
  end
end
def.static("number", "=>", "boolean").OnNPCService_GangGetRecipeCondition = function(ServiceID)
  local data = GangModule.Instance().data
  if false == data:IsGetMifang() and data:IsTiggerMifang() then
    return true
  end
  return false
end
def.static("table").OnSSyncGangInfo = function(p)
  local data = GangModule.Instance().data
  data:SyncGangInfo(p)
  GangModule.FromNoToGang()
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, {isBaseInfo = true, gangInfo = p})
end
def.static("table").OnSSyncSelfInfo = function(p)
  local data = GangModule.Instance().data
  data:SyncSelfInfo(p)
end
def.static("table").OnSGetGangListRes = function(p)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_RequireNewGangList, {
    p.gangList
  })
end
def.static("table").OnSSearchGangListRes = function(p)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_SucceedSearch, {
    p.result
  })
end
def.static("table").OnSGangNormalResult = function(p)
  local SGangNormalResult = require("netio.protocol.mzm.gsp.gang.SGangNormalResult")
  local args = p.args
  if p.result == SGangNormalResult.SEARCH_GANG_NOT_FIND then
    Toast(textRes.Gang[p.result])
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FailedSearch, {
      p.result
    })
  elseif p.result == SGangNormalResult.CREATE_GANG_ILLEGAL_NAME or p.result == SGangNormalResult.CREATE_GANG_ILLEGAL_PURPOSE or p.result == SGangNormalResult.CREATE_GANG_NEED_MORE_YUANBAO or p.result == SGangNormalResult.GANG_CREATE_FAILED_NAME_DUPLICATE then
    Toast(textRes.Gang[p.result])
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FailedCreate, {
      p.result
    })
  elseif p.result == SGangNormalResult.TARGET_ALREADY_JOIN_GANG or p.result == SGangNormalResult.TARGET_ALREADY_IN_APPLY_LIST or p.result == SGangNormalResult.ADD_APPLY_LIST_SUCCESS or p.result == SGangNormalResult.QUIT_GANG_SUCCESS or p.result == SGangNormalResult.INVITE_JOIN_GANG_SUCCESS or p.result == SGangNormalResult.INVITE_SAME_GANG_ERROR or p.result == SGangNormalResult.XUETU_NUM_FULL or p.result == SGangNormalResult.BANGZHONG_NUM_FULL or p.result == SGangNormalResult.DONATE_SUCCESS or p.result == SGangNormalResult.GANG_RENAME_SUCCESS or p.result == SGangNormalResult.GANG_RENAME_NOT_COOL_DOWN or p.result == SGangNormalResult.GANG_RENAME_FAILED_NAME_DUPLICATE or p.result == SGangNormalResult.XUE_TU_MAX_LEVEL_SET_SUCCESS or p.result == SGangNormalResult.TANHE_SUCCESS or p.result == SGangNormalResult.FORBIDDEN_TALK_MAX_COUNT or p.result == SGangNormalResult.KICK_MEMBER_MAX_COUNT or p.result == SGangNormalResult.KICK_MEMBER_NEED_MORE_VIGOR or p.result == SGangNormalResult.RENMING_ACTION_SUCCESS or p.result == SGangNormalResult.CHANGE_LEADER_ACTION_SUCCESS or p.result == SGangNormalResult.GANG_CHANGE_LEADER_ILLEGAL or p.result == SGangNormalResult.GANG_DESIGN_DUTY_SUCCESS or p.result == SGangNormalResult.GANG_ANNOUNCEMENT_TIMES_OUT or p.result == SGangNormalResult.CONFIRM_JOIN_GANG or p.result == SGangNormalResult.ERR_ALREADY_HAVE_GANG or p.result == SGangNormalResult.ERR_BUILDING_ALREADY_LEVELUP_SUCCESS or p.result == SGangNormalResult.ERR_TANHE_BANGZHU_OFFLINE_TIME_NOT_ENOUGH or p.result == SGangNormalResult.ERR_BAG_IS_FULL or p.result == SGangNormalResult.ERR_VIGOR_NOT_ENOUGH or p.result == SGangNormalResult.ERR_FULI_COUNT_IS_MAX or p.result == SGangNormalResult.ERR_FULI_JOIN_NOT_AFTER_3_DAY or p.result == SGangNormalResult.ERR_GET_MIFANG_JOIN_GANG_AFTER_TRIGGER or p.result == SGangNormalResult.FULI_GET_SUCCESS or p.result == SGangNormalResult.ERR_REDEEM_BANGGONG_NOT_AFTER_3_DAY or p.result == SGangNormalResult.DISMISS_SUCCESS or p.result == SGangNormalResult.DISMISS_FAIL or p.result == SGangNormalResult.MODIFIED_SIGN_STRING_SUCCESS or p.result == SGangNormalResult.MODIFIED_SIGN_STRING_FAIL then
    Toast(textRes.Gang[p.result])
  elseif p.result == SGangNormalResult.CANT_SIGN_SAME_DAY then
    Toast(textRes.Gang[7])
  elseif p.result == SGangNormalResult.CANT_DUIHUAN_BANGGONG_WITHMAX then
    Toast(textRes.Gang[147])
  elseif p.result == SGangNormalResult.ERR_LIANYAO_YAOCAI_NOT_ENOUGH then
    Toast(textRes.Gang[148])
  elseif p.result == SGangNormalResult.ERR_GET_MIFANG_BANGGONG_NOT_ENOUGH then
    local needBangGong = tonumber(args[1])
    Toast(string.format(textRes.Gang[p.result], needBangGong))
  elseif p.result == SGangNormalResult.ERR_YAOCAI_IS_OUT_OF_SALE then
    Toast(textRes.Gang[p.result])
  elseif p.result == SGangNormalResult.ERR_SIGN_STRING_HAS_SENSITIVE_WORDS then
    Toast(textRes.Gang[113])
  elseif p.result == SGangNormalResult.ERR_BUY_YAOCAI_NOT_EXIST then
    Toast(textRes.Gang[p.result])
    local data = GangModule.Instance().data
    if data:GetDrugListRefresh() then
      Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_DrugShopInfoChanged, nil)
      data:SetDrugListRefresh(false)
    end
  elseif require("Main.Gang.GangTeamMgr").GetProtocol().OnGangTeamResult(p, args) then
    return
  else
    local msg = textRes.Gang.NormalResult[p.result]
    if msg then
      Toast(msg)
    end
  end
end
def.method("=>", "number").GetHeroCurBanggong = function(self)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local memberInfo = self.data:GetMemberInfoByRoleId(heroProp.id)
  if memberInfo ~= nil then
    return memberInfo.curBangGong
  else
    return 0
  end
end
def.method("=>", "number").GetHeroHistoryBanggong = function(self)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local memberInfo = self.data:GetMemberInfoByRoleId(heroProp.id)
  if memberInfo ~= nil then
    return memberInfo.historyBangGong
  else
    return 0
  end
end
def.method("=>", "boolean").HasGang = function(self)
  local GangCrossData = require("Main.GangCross.data.GangCrossData")
  if IsCrossingServer() and GangCrossData.Instance():HasGang() then
    return true
  else
    local gangId = self.data:GetGangId()
    return gangId ~= nil
  end
end
def.method("userdata").ApplyGang = function(self, gangId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CJoinGangReq").new(Int64.new(-1), gangId))
end
def.method("userdata").GangInvite = function(self, roleId)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CInviteJoinGangReq").new(roleId))
end
def.method().GotoGangMap = function(self)
  if self:HasGang() == false then
    Toast(textRes.Gang[250])
    return
  end
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role and role:IsInState(RoleState.BEHUG) then
    Toast(textRes.Hero[52])
    return
  end
  if role and role:IsInState(RoleState.HUG) then
    Toast(textRes.Hero[56])
    return
  end
  if role and role:IsInState(RoleState.UNTRANPORTABLE) then
    Toast(textRes.Gang[135])
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGotoGangMapReq").new())
end
def.static("number", "table").SInviteJoinGangCallback = function(i, tag)
  if i == 1 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CJoinGangReq").new(tag.inviterId, tag.gangId))
  elseif i == 0 then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CRejectJoinGangReq").new(tag.inviterId))
  end
end
def.static("table").OnSInviteJoinGang = function(p)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local tag = {
    id = self,
    gangId = p.gangId,
    inviterId = p.inviterId
  }
  local time = GangUtility.GetGangConsts("RESPONSE_JOIN_LIMIT_TIME_M") * 60
  CommonConfirmDlg.ShowConfirmCoundDown("", string.format(textRes.Gang[69], p.inviterName, p.gangName), textRes.Login[105], textRes.Login[106], 0, time, GangModule.SInviteJoinGangCallback, tag)
end
def.static("table").OnSSyncAddGangMember = function(p)
  local data = GangModule.Instance().data
  data:AddMember(p.memberInfo)
  local gangName = data:GetGangName()
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberAdd, {
    p.memberInfo
  })
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, nil)
  local display = string.format(textRes.Gang[154], p.memberInfo.name, gangName)
  GangModule.ShowInGangChannel(display)
end
def.static("string").ShowInGangChannel = function(display)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  require("Main.Chat.ChatModule").Instance():SendNoteMsg(display, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.static("table").OnSJoinGangRes = function(p)
  Toast(string.format(textRes.Gang[70], p.gangName))
end
def.static("table").OnSGetRoleModelRes = function(p)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberModelInfo, {
    p.modelInfo
  })
end
def.static("table").OnSGetRoleInfoRes = function(p)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfo, {
    p.roleInfo
  })
end
def.static("table").OnSSyncApplicants = function(p)
  local data = GangModule.Instance().data
  data:SyncApplicants(p.applicants)
  data:SetApplyShow(true)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.AFFAIRS
  })
end
def.static("table").OnSSAddApplicantBrd = function(p)
  local data = GangModule.Instance().data
  data:AddApplicant(p.applicant)
  data:SetApplyShow(true)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.AFFAIRS
  })
end
def.static("table").OnSSRemoveApplicantBrd = function(p)
  local data = GangModule.Instance().data
  data:RemoveApplicantByRoleId(p.roleid)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_RemoveApplier, {
    p.roleid
  })
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.AFFAIRS
  })
end
def.static("table").OnSSyncClearApplyList = function(p)
  local data = GangModule.Instance().data
  data:ClearApplierList()
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ClearApplierList, nil)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.AFFAIRS
  })
end
def.static("boolean").FromGangToNo = function(bIsKicked)
  local gangTeamPanel = require("Main.Gang.GangTeam.ui.GangTeamPanel").Instance()
  if gangTeamPanel:IsLoaded() then
    gangTeamPanel:DestroyPanel()
  end
  if require("Main.Gang.ui.HaveGangPanel").Instance():IsLoaded() then
    require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
  end
  local data = GangModule.Instance().data
  data:SetApplyShow(true)
  data:SetHelpShow(true)
  GangUtility.ClearWelfareTouchedRecord()
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.ALL
  })
  if bIsKicked then
    GangUtility.ShowRejoinGangPrompt()
  end
end
def.static().FromNoToGang = function()
  if require("Main.Gang.ui.NoGangPanel").Instance():IsShow() then
    require("Main.Gang.ui.NoGangPanel").Instance():Hide()
    require("Main.Gang.ui.HaveGangPanel").Instance():ShowPanel()
  end
  local data = GangModule.Instance().data
  data:SetApplyShow(true)
  data:SetHelpShow(true)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.ALL
  })
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if heroProp then
    local memberInfo = data:GetMemberInfoByRoleId(heroProp.id)
    if memberInfo then
      local tbl = GangUtility.GetAuthority(memberInfo.duty)
      if tbl.isCanMgeApplyList then
        local applierList = data:GetApplierList()
        Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ApplierChange, {
          #applierList
        })
      end
    end
  end
end
def.static("table").OnSSyncQuitGang = function(p)
  local data = GangModule.Instance().data
  local memberInfo = data:GetMemberInfoByRoleId(p.roleId)
  if nil ~= memberInfo then
    local display = string.format(textRes.Gang[164], memberInfo.name)
    GangModule.ShowInGangChannel(display)
  end
  data:RemoveMemberByRoleId(p.roleId)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemeberQuited, {
    p.roleId
  })
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if p.roleId == heroProp.id then
    data:SetAllNull()
    GangModule.FromGangToNo(false)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, nil)
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, nil)
end
def.static("table").OnSSyncRename = function(p)
  local data = GangModule.Instance().data
  data:SetGangName(p.newName)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NameChanged, nil)
end
def.static("table").OnSSyncNewGangPurpose = function(p)
  local data = GangModule.Instance().data
  data:SetGangPurpose(p.purpose)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_PurposeChanged, nil)
end
def.static("table").OnSSyncDesignDutyName = function(p)
  local data = GangModule.Instance().data
  data:SetGangDutyNameId(p.designCaseId)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_DutyNameChange, {
    dutyNameId = p.designCaseId
  })
end
def.static("table").OnSSyncKickOutMember = function(p)
  local data = GangModule.Instance().data
  local mangerInfo = data:GetMemberInfoByRoleId(p.managerId)
  local roleInfo = data:GetMemberInfoByRoleId(p.roleId)
  if nil ~= memberInfo and nil ~= roleInfo then
    local display = string.format(textRes.Gang[158], mangerInfo.name, roleInfo.name)
    GangModule.ShowInGangChannel(display)
  end
  data:RemoveMemberByRoleId(p.roleId)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemeberQuited, {
    p.roleId
  })
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if p.roleId == heroProp.id then
    data:SetAllNull()
    GangModule.FromGangToNo(true)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, nil)
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, nil)
end
def.static("table").OnSSyncTanHe = function(p)
  local data = GangModule.Instance().data
  data:SetGangTanheRoleId(p.roleId)
  local time = GetServerTime() + GangUtility.GetGangConsts("TANHE_WAIT_TIME_D") * 24 * 60 * 60
  data:SetGangTanheEndTime(time)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_TanheBangzhu, nil)
  local gangInfo = data:GetGangBasicInfo()
  local bangZhu = gangInfo.bangZhu
  local tanhe = data:GetMemberInfoByRoleId(p.roleId)
  if tanhe == nil then
    return
  end
  local tanheName = tanhe.name
  local display = string.format(textRes.Gang[155], bangZhu, tanheName, GangUtility.GetGangConsts("TANHE_WAIT_TIME_D"))
  GangModule.ShowInGangChannel(display)
end
def.static("table").OnSSyncCancelTanHe = function(p)
  local data = GangModule.Instance().data
  data:SetGangTanheRoleId(nil)
  data:SetGangTanheEndTime(0)
  local tanheInfo = data:GetMemberInfoByRoleId(p.roleId)
  if tanheInfo == nil then
    return
  end
  local display = string.format(textRes.Gang[157], tanheInfo.name)
  GangModule.ShowInGangChannel(display)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_TanheBangzhu, nil)
end
def.static("table").OnSSyncMemberInfoChange = function(p)
  local roleId = p.memberInfo.roleId
  local data = GangModule.Instance().data
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if roleId == heroProp.id then
    local roleInfo = data:GetMemberInfoByRoleId(roleId)
    if roleInfo then
      local oldDuty = roleInfo.duty
      local newDuty = p.memberInfo.duty
      if oldDuty == constant.CGangConst.XUETU_ID and newDuty == constant.CGangConst.BANGZHONG_ID then
        Toast(textRes.Gang[266])
      end
    end
  end
  data:UpdateMember(p.memberInfo)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberInfoChange, {roleid = roleId})
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, nil)
end
def.static("table").OnSForbiddenTalkRes = function(p)
  Toast(string.format(textRes.Gang[83], p.costVigor, p.leftTime))
end
def.static("table").OnSSyncForbiddenTalk = function(p)
  local data = GangModule.Instance().data
  local mangerInfo = data:GetMemberInfoByRoleId(p.managerId)
  local roleInfo = data:GetMemberInfoByRoleId(p.roleId)
  if mangerInfo == nil or roleInfo == nil then
    return
  end
  local time = GangUtility.GetGangConsts("FORBIDDEN_TALK_TIME_H")
  local display = string.format(textRes.Gang[161], mangerInfo.name, roleInfo.name, time)
  GangModule.ShowInGangChannel(display)
end
def.static("table").OnSSyncUnForbiddenTalk = function(p)
  local data = GangModule.Instance().data
  local mangerInfo = data:GetMemberInfoByRoleId(p.managerId)
  local roleInfo = data:GetMemberInfoByRoleId(p.roleId)
  if mangerInfo == nil or roleInfo == nil then
    return
  end
  local display = string.format(textRes.Gang[162], mangerInfo.name, roleInfo.name)
  GangModule.ShowInGangChannel(display)
end
def.static("table").OnSUnForbiddenTalkRes = function(p)
  local data = GangModule.Instance().data
  local roleInfo = data:GetMemberInfoByRoleId(p.roleId)
  if roleInfo == nil then
    return
  end
  local display = string.format(textRes.Gang[364], roleInfo.name)
  Toast(display)
end
def.method("userdata", "=>", "number").GetRemainForbiddenTime = function(self, roleId)
  local data = GangModule.Instance().data
  local roleInfo = data:GetMemberInfoByRoleId(roleId)
  if nil == roleInfo then
    return 0
  end
  if roleInfo.forbiddenTalk == 0 then
    return roleInfo.forbiddenTalk
  else
    return roleInfo.forbiddenTalk - GetServerTime()
  end
end
def.static("table").OnSKickOutMemberRes = function(p)
  Toast(string.format(textRes.Gang[84], p.costVigor))
end
def.static("table").OnSSyncXueTuMaxLevelChange = function(p)
  local data = GangModule.Instance().data
  data:SetGangXueTuMaxLevel(p.level)
end
def.static("table").OnSSyncMemberOffline = function(p)
  local data = GangModule.Instance().data
  data:SetMemberOffline(p.roleId, GetServerTime())
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Offline, nil)
end
def.static("table").OnSSyncMemberOnline = function(p)
  local data = GangModule.Instance().data
  data:SetMemberOffline(p.roleId, -1)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Offline, nil)
end
def.static("table").OnSSyncChangeDuty = function(p)
  local data = GangModule.Instance().data
  local manager = data:GetMemberInfoByRoleId(p.managerId)
  local target = data:GetMemberInfoByRoleId(p.targetId)
  if manager == nil or target == nil then
    return
  end
  local dutyName = data:GetDutyName(p.duty)
  local display = string.format(textRes.Gang[150], manager.name, target.name, dutyName)
  GangModule.ShowInGangChannel(display)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_SyncChangeDuty, {
    managerId = p.managerId,
    targetId = p.targetId,
    duty = p.duty
  })
end
def.static("number").SendBuildDonateMsg = function(type)
  local content = string.format(textRes.Gang[170], textRes.Gang.BuildType[type])
  local button = string.format("<a href='btn_build_%d' id=btn_build_%d><font color=#%s><u>[%s]</u></font></a>", type, type, link_defalut_color, textRes.Gang[261])
  local str = string.format("%s%s", content, button)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  require("Main.Chat.ChatModule").Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.static("table").OnSSyncGangMoneyChange = function(p)
  local data = GangModule.Instance().data
  data:SetGangMoney(p.gangMoney)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MoneyChange, nil)
end
def.static("table").OnSSyncGangVitalityChange = function(p)
  local data = GangModule.Instance().data
  data:SetGangvitality(p.vitality)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_VitalityChanged, nil)
end
def.static("table").OnSSyncGangLevelDownDuty = function(p)
  local data = GangModule.Instance().data
  for k, v in pairs(p.building2level) do
    if GangBuildingEnum.XIANGFANG == k then
      local curLevel = data:GetWingLevel()
      data:SetWingLevel(v)
      local display = string.format(textRes.Gang[174], textRes.Gang.BuildType[k], curLevel, v)
      GangModule.ShowInGangChannel(display)
    elseif GangBuildingEnum.CANGKU == k then
      local curLevel = data:GetWarehouseLevel()
      data:SetWarehouseLevel(v)
      local display = string.format(textRes.Gang[174], textRes.Gang.BuildType[k], curLevel, v)
      GangModule.ShowInGangChannel(display)
    elseif GangBuildingEnum.JINKU == k then
      local curLevel = data:GetCoffersLevel()
      data:SetCoffersLevel(v)
      local display = string.format(textRes.Gang[174], textRes.Gang.BuildType[k], curLevel, v)
      GangModule.ShowInGangChannel(display)
    elseif GangBuildingEnum.YAODIAN == k then
      local curLevel = data:GetPharmacyLevel()
      data:SetPharmacyLevel(v)
      local display = string.format(textRes.Gang[174], textRes.Gang.BuildType[k], curLevel, v)
      GangModule.ShowInGangChannel(display)
    elseif GangBuildingEnum.GANG == k then
      local curLevel = data:GetGangLevel()
      data:SetGangLevel(v)
      local display = string.format(textRes.Gang[160], curLevel, v)
      GangModule.ShowInGangChannel(display)
    elseif GangBuildingEnum.SHUYUAN == k then
      local curLevel = data:GetBookLevel()
      data:SetBookLevel(v)
      local display = string.format(textRes.Gang[174], textRes.Gang.BuildType[k], curLevel, v)
      GangModule.ShowInGangChannel(display)
    end
  end
end
def.static("table").OnSSyncGangMaintain = function(p)
  local display = string.format(textRes.Gang[159], p.costMoney)
  GangModule.ShowInGangChannel(display)
end
def.static("table").OnSSyncSystemKickOut = function(p)
  local data = GangModule.Instance().data
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  for k, v in pairs(p.roleList) do
    data:RemoveMemberByRoleId(v)
    if heroProp.id == v then
      data:SetAllNull()
      GangModule.FromGangToNo(true)
      Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, nil)
      break
    end
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemeberQuited, p.roleList)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, nil)
end
def.static("table").OnSSyncGangDissolve = function(p)
  local ManagementGangPanel = require("Main.Gang.ui.GangManagment.ManagementGangPanel")
  if ManagementGangPanel.Instance():IsShow() then
    ManagementGangPanel.Instance():Hide()
  end
  local data = GangModule.Instance().data
  data:SetAllNull()
  GangModule.FromGangToNo(true)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, nil)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, nil)
end
def.static("table").OnSPublicAnnouncementRes = function(p)
  Toast(string.format(textRes.Gang[91], p.costVigor))
  local GangGroupMgr = require("Main.Gang.GangGroup.GangGroupMgr").Instance():SendWXGroupMsg()
end
def.static("table").OnSSyncAnnouncement = function(p)
  local data = GangModule.Instance().data
  data:AddAnno(p.announcement)
  data:SetNewGangNotice(true)
  local unRead = data:GetUnReadAnnoNum()
  data:SetUnReadAnnoNum(unRead + 1)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_AnnouncementsChanged, {
    unRead + 1
  })
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NewAnno, nil)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {0})
end
def.static("table").OnSSyncTanHeSuccess = function(p)
  local data = GangModule.Instance().data
  data:SetGangTanheRoleId(nil)
  data:SetGangTanheEndTime(0)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_TanheBangzhu, nil)
  local tanheInfo = data:GetMemberInfoByRoleId(p.tanHeId)
  local bangzhuInfo = data:GetMemberInfoByRoleId(p.bangZhuId)
  if tanheInfo ~= nil and bangzhuInfo ~= nil then
    local display = string.format(textRes.Gang[156], tanheInfo.name)
    GangModule.ShowInGangChannel(display)
  end
end
def.method("number").Update = function(self, tick)
  local data = GangModule.Instance().data
  local gangInfo = data:GetGangBasicInfo()
  if not gangInfo.gangId then
    return
  end
  local ManagementGangPanel = require("Main.Gang.ui.GangManagment.ManagementGangPanel")
  if ManagementGangPanel.Instance():IsPanelShow() then
    ManagementGangPanel.Instance():Update()
  end
  local GangLevelUpPanel = require("Main.Gang.ui.GangLevelUp.GangLevelUpPanel")
  if GangLevelUpPanel.Instance():IsPanelShow() then
    GangLevelUpPanel.Instance():Update()
  end
  local GangBuildDonatePanel = require("Main.Gang.ui.GangBuildDonatePanel")
  if GangBuildDonatePanel.Instance():IsPanelShow() then
    GangBuildDonatePanel.Instance():Update()
  end
  local GangMifangMakeDrugPanel = require("Main.Gang.ui.GangMifangMakeDrugPanel")
  if GangMifangMakeDrugPanel.Instance():IsPanelShow() then
    GangMifangMakeDrugPanel.Instance():Update()
  end
  if gangInfo.buildEndTime > 0 then
    local time = (GetServerTime() - data.lastTime) / 60
    local const = GangUtility.GetGangBuildSyncInterval()
    if time >= const then
      GangModule.SendBuildDonateMsg(GangBuildingEnum.GANG)
      data.lastTime = GetServerTime()
    end
  end
  if 0 < gangInfo.wingEndTime then
    local time = (GetServerTime() - data.lastWingTime) / 60
    local const = GangUtility.GetGangBuildSyncInterval()
    if time >= const then
      GangModule.SendBuildDonateMsg(GangBuildingEnum.XIANGFANG)
      data.lastWingTime = GetServerTime()
    end
  end
  if 0 < gangInfo.warehouseEndTime then
    local time = (GetServerTime() - data.lastWarehouseTime) / 60
    local const = GangUtility.GetGangBuildSyncInterval()
    if time >= const then
      GangModule.SendBuildDonateMsg(GangBuildingEnum.CANGKU)
      data.lastWarehouseTime = GetServerTime()
    end
  end
  if 0 < gangInfo.coffersEndTime then
    local time = (GetServerTime() - data.lastCoffersTime) / 60
    local const = GangUtility.GetGangBuildSyncInterval()
    if time >= const then
      GangModule.SendBuildDonateMsg(GangBuildingEnum.JINKU)
      data.lastCoffersTime = GetServerTime()
    end
  end
  if 0 < gangInfo.pharmacyEndTime then
    local time = (GetServerTime() - data.lastPharmacyTime) / 60
    local const = GangUtility.GetGangBuildSyncInterval()
    if time >= const then
      GangModule.SendBuildDonateMsg(GangBuildingEnum.YAODIAN)
      data.lastPharmacyTime = GetServerTime()
    end
  end
  if 0 < gangInfo.bookEndTime then
    local time = (GetServerTime() - data.lastBookTime) / 60
    local const = GangUtility.GetGangBuildSyncInterval()
    if time >= const then
      GangModule.SendBuildDonateMsg(GangBuildingEnum.SHUYUAN)
      data.lastBookTime = GetServerTime()
    end
  end
end
def.static("table").OnSUseGangFileItemRes = function(p)
end
def.static("table").OnSSyncBangGongChange = function(p)
  local data = GangModule.Instance().data
  data:SetMemberBangGong(p.roleId, p)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BanggongChanged, {
    roleId = p.roleId
  })
end
def.static("table").OnSSyncGangRobberEvent = function(p)
  local display = textRes.Gang.RobberType[p.result]
  local GangRobberEvent = require("netio.protocol.mzm.gsp.activity.SSyncGangRobberEvent")
  if p.result == GangRobberEvent.GANG_ROBBER_BORN then
    local button = string.format("<a href='btn_gangRobber' id=btn_gangRobber><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.Gang[260])
    local str = string.format("%s%s", display, button)
    GangModule.ShowInGangChannel(str)
  elseif p.result == GangRobberEvent.KILL_ALL_AWARD_TIP then
    local times = GangUtility.GetGangRobberConsts("deadCountCanAward")
    local money = GangUtility.GetGangRobberConsts("AWARD_GANG_MONEY")
    local giftbags = GangUtility.GetGangRobberConsts("GANG_AWARD_ID")
    GangModule.ShowInGangChannel(string.format(textRes.Gang[269], times, money, giftbags))
  else
    if p.result == GangRobberEvent.DAY_KILLED_MORE_THAN_RECOMMAND then
      Toast(display)
    end
    GangModule.ShowInGangChannel(display)
  end
end
def.static("table").OnSSyncGangRobberCounter = function(p)
  if p.count > 0 then
    local display = string.format(textRes.Gang[168], p.count)
    GangModule.ShowInGangChannel(display)
  end
end
def.static("table").OnSSyncFightRobberTipRes = function(p)
  Toast(textRes.Gang[256])
end
def.static("table").OnSSyncGangRobberBornEvent = function(p)
  GangModule.ShowInGangChannel(textRes.Gang[177])
end
def.static("table").OnSSyncRejectJoinGang = function(p)
  Toast(string.format(textRes.Gang[93], p.rejectName))
end
def.static("table", "table").OnGangHelInfoChange = function(params, tbl)
  local data = GangModule.Instance().data
  data:SetHelpShow(params and params.isAdd)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.WELFARE
  })
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpChaned, nil)
end
def.static("string", "number", "string", "string", "=>", "string").GetHelpAnnoStr = function(btnName, activityId, param1, param2)
  local id = string.format("gangHelp_%s_%s_%s", tostring(activityId), tostring(param1), tostring(param2))
  local button = string.format("<a href='btn_%s' id=btn_%s><font color=#%s><u>[%s]</u></font></a>", id, id, link_defalut_color, btnName)
  return button
end
def.static("table").OnSSyncGangHelp = function(p)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_HelpAnno, {
    p.helperType,
    p.paramString,
    p.paramLong,
    p.paramInt
  })
end
def.static("table").OnSSyncVisibleMonsterReward = function(p)
  GangModule.ShowReward(p.awardBean, p.activityType)
end
def.static("table", "number").ShowReward = function(awardBean, activityType)
  local personAward = {}
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local str = textRes.Gang.ActivityType[activityType]
  local awardInfo = require("Main.Award.AwardUtils").GetHtmlTextsFromAwardBean(awardBean, str)
  for _, v in ipairs(awardInfo) do
    require("Main.Chat.PersonalHelper").SendOut(v)
  end
end
def.static("table").OnSSyncBuildingStartLevelUp = function(p)
  local data = GangModule.Instance().data
  data:SetGangMoney(p.gangMoney)
  if GangBuildingEnum.XIANGFANG == p.buildingType then
    data:SetGangWingEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWingGang, nil)
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastWingTime = GetServerTime()
  elseif GangBuildingEnum.CANGKU == p.buildingType then
    data:SetGangWarehouseEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWarehouseGang, nil)
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastWarehouseTime = GetServerTime()
  elseif GangBuildingEnum.JINKU == p.buildingType then
    data:SetGangCoffersEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartCoffersGang, nil)
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastCoffersTime = GetServerTime()
  elseif GangBuildingEnum.YAODIAN == p.buildingType then
    data:SetGangPharmacyEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartPharmacyGang, nil)
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastPharmacyTime = GetServerTime()
  elseif GangBuildingEnum.GANG == p.buildingType then
    data:SetGangBuildEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartBuildGang, nil)
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastTime = GetServerTime()
  elseif GangBuildingEnum.SHUYUAN == p.buildingType then
    data:SetGangBookEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartLibraryGang, nil)
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastBookTime = GetServerTime()
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.AFFAIRS
  })
end
def.static("table").OnSSyncCallBuildingLevelUpDonate = function(p)
  local data = GangModule.Instance().data
  if GangBuildingEnum.XIANGFANG == p.buildingType then
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastWingTime = GetServerTime()
  elseif GangBuildingEnum.CANGKU == p.buildingType then
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastWarehouseTime = GetServerTime()
  elseif GangBuildingEnum.JINKU == p.buildingType then
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastCoffersTime = GetServerTime()
  elseif GangBuildingEnum.YAODIAN == p.buildingType then
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastPharmacyTime = GetServerTime()
  elseif GangBuildingEnum.GANG == p.buildingType then
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastTime = GetServerTime()
  elseif GangBuildingEnum.SHUYUAN == p.buildingType then
    GangModule.SendBuildDonateMsg(p.buildingType)
    data.lastBookTime = GetServerTime()
  end
end
def.static("table").OnSSyncBuildingLevelUpDonate = function(p)
  local data = GangModule.Instance().data
  if GangBuildingEnum.XIANGFANG == p.buildingType then
    data:SetGangWingEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWingGang, nil)
  elseif GangBuildingEnum.CANGKU == p.buildingType then
    data:SetGangWarehouseEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWarehouseGang, nil)
  elseif GangBuildingEnum.JINKU == p.buildingType then
    data:SetGangCoffersEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartCoffersGang, nil)
  elseif GangBuildingEnum.YAODIAN == p.buildingType then
    data:SetGangPharmacyEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartPharmacyGang, nil)
  elseif GangBuildingEnum.GANG == p.buildingType then
    data:SetGangBuildEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartBuildGang, nil)
  elseif GangBuildingEnum.SHUYUAN == p.buildingType then
    data:SetGangBookEndTime(p.endTime)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartLibraryGang, nil)
  end
  local money, banggong = GangUtility.GetDonateInfo(p.donateLv)
  local member = data:GetMemberInfoByRoleId(p.roleId)
  if nil == member then
    return
  end
  local display = string.format(textRes.Gang[171], member.name, textRes.Gang.BuildType[p.buildingType], money, banggong)
  GangModule.ShowInGangChannel(display)
end
def.static("table").OnSSyncBuildingLevelUpSuccess = function(p)
  local data = GangModule.Instance().data
  if GangBuildingEnum.XIANGFANG == p.buildingType then
    data:SetWingLevel(p.level)
    data:SetGangWingEndTime(-1)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWingGang, nil)
  elseif GangBuildingEnum.CANGKU == p.buildingType then
    data:SetWarehouseLevel(p.level)
    data:SetGangWarehouseEndTime(-1)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartWarehouseGang, nil)
  elseif GangBuildingEnum.JINKU == p.buildingType then
    data:SetCoffersLevel(p.level)
    data:SetGangCoffersEndTime(-1)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartCoffersGang, nil)
  elseif GangBuildingEnum.YAODIAN == p.buildingType then
    data:SetPharmacyLevel(p.level)
    data:SetGangPharmacyEndTime(-1)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartPharmacyGang, nil)
  elseif GangBuildingEnum.GANG == p.buildingType then
    data:SetGangLevel(p.level)
    data:SetGangBuildEndTime(-1)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartBuildGang, nil)
  elseif GangBuildingEnum.SHUYUAN == p.buildingType then
    data:SetBookLevel(p.level)
    data:SetGangBookEndTime(-1)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_StartLibraryGang, nil)
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_BuildComplete, nil)
  local display = string.format(textRes.Gang[172], textRes.Gang.BuildType[p.buildingType], p.level)
  GangModule.ShowInGangChannel(display)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.AFFAIRS
  })
end
def.static("table").OnSSilver2banggongRes = function(p)
  local banggong = GangUtility.GetExchangeInfo(p.level)
  local max = GangUtility.GetGangConsts("SILVER2BANGGONG_LIMIT")
  local hasExchange = GangData.Instance():GetRedeemBangGong()
  local exchange = banggong
  if max < hasExchange + exchange then
    exchange = max - hasExchange
    Toast(string.format(textRes.Gang[109], exchange))
  end
  Toast(string.format(textRes.Gang[108], exchange))
  local data = GangModule.Instance().data
  data:SetRedeemBangGong(p.silver2banggongHistory)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ExchangeBanggongChanged, nil)
end
def.static("table").OnSYuanBao2banggongRes = function(p)
  local banggong = GangUtility.GetYuanBaoExchangeInfo(p.yuan_bao)
  local max = GangUtility.GetGangConsts("yuanbao_2_bang_gong_limit")
  local hasExchange = GangData.Instance():GetYuanBaoRedeemBangGong()
  local exchange = banggong
  if max < hasExchange + exchange then
    exchange = max - hasExchange
    Toast(string.format(textRes.Gang[400], exchange))
  end
  Toast(string.format(textRes.Gang[108], exchange))
  local data = GangModule.Instance().data
  data:SetYuanBaoRedeemBangGong(p.yuan_bao_to_banggong_total)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ExchangeBanggongChanged, nil)
end
def.static("table").OnSSyncGangMapCreate = function(p)
  local data = GangModule.Instance().data
  data:SetMapInstanceId(p.sceneId)
end
def.static("table").OnSYaoDianInfoRes = function(p)
  local data = GangModule.Instance().data
  data:SetDrugListNull()
  local count = #p.yaoDianInfo.shopItemList
  for k, v in pairs(p.yaoDianInfo.shopItemList) do
    data:AddDrug(v)
  end
  data:SetDrugListRefresh(true)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_ShowDrugShop, nil)
end
def.static("table").OnSSyncGangYaoCaiNumChange = function(p)
  local data = GangModule.Instance().data
  for k, v in pairs(p.yaoCaiMap) do
    data:UpdateDrugRemainNum(k, v)
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_DrugShopInfoChanged, nil)
end
def.static("table").OnSBuyYaoCaiRes = function(p)
  local itemBase = ItemUtils.GetItemBase(p.itemId)
  Toast(string.format(textRes.Gang[118], itemBase.name))
end
def.static("table").OnSSyncGangMiFangTrigger = function(p)
  local data = GangModule.Instance().data
  data:SetTiggerMifang(true)
  data:SetTiggerMifangCfgId(p.cfgId)
  if GangModule.Instance().bMainUICreate then
    local mifangInfo = GangUtility.GetMifangInfo(p.cfgId)
    local npcId = constant.GangMiFangConsts.GANGMIFANG_NPC_ID
    local npcRec = require("Main.npc.NPCInterface").GetNPCCfg(npcId)
    local content = string.format(textRes.Gang[175], mifangInfo.miFangName, npcRec.npcName)
    local button = string.format("<a href='btn_mifang' id=btn_mifang><font color=#%s><u>[%s]</u></font></a>", link_defalut_color, textRes.Gang[260])
    local str = string.format("%s%s", content, button)
    local ChatMsgData = require("Main.Chat.ChatMsgData")
    require("Main.Chat.ChatModule").Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
  end
end
def.static("table").OnSSyncGangMiFangInfo = function(p)
  local data = GangModule.Instance().data
  data:SetMifang(1)
  data:SetMifangNeedItemList(p.miFangInfo.itemList)
  data:SetMifangCfgId(p.miFangInfo.cfgId)
  data:SetMifangEndTime(p.miFangInfo.endTime)
  data:SetMifangUseCount(p.miFangInfo.useCount)
  data:SetMifangTotalCount(p.miFangInfo.totalCount)
  Toast(textRes.Gang[128])
end
def.static("table").OnSUseMiFangRes = function(p)
  local itemBase = ItemUtils.GetItemBase(p.itemId)
  Toast(string.format(textRes.Gang[122], itemBase.name))
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_SucceedUseMifang, {
    p.itemId
  })
end
def.static("table").OnSSyncGangMiFangOutOfUse = function(p)
  local times = data:GetMifangTotalCount()
  local data = GangModule.Instance().data
  data:SetMifangUseCount(times)
end
def.static("table").OnSSyncGangMiFangTimeEnd = function(p)
  local data = GangModule.Instance().data
  data:SetMifang(0)
  data:SetMifangNeedItemList({})
  data:SetMifangCfgId(0)
  data:SetMifangEndTime(nil)
  data:SetMifangUseCount(0)
  data:SetMifangTotalCount(0)
  data:SetTiggerMifang(false)
  GangModule.ShowInGangChannel(textRes.Gang[176])
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_CloseMifang, nil)
end
def.static("table").OnSSyncMiFangCountChange = function(p)
  local data = GangModule.Instance().data
  local times = data:GetMifangTotalCount()
  data:SetMifangUseCount(p.count)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MifangTimesChanged, nil)
end
def.static("table").OnSSyncMiFangLevelNotEqual = function(p)
  Toast(string.format(textRes.Gang[119], p.level))
end
def.static("table").OnSSyncFuLiInfo = function(p)
  local data = GangModule.Instance().data
  data:SetRemainFuli(p.leftCount)
  data:SetTotalFuli(p.totalCount)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_FuliChanged, nil)
end
def.static("table").OnSDispatchLiHeRes = function(p)
  local data = GangModule.Instance().data
  for k, v in pairs(p.roleIdList) do
    local memberInfo = data:GetMemberInfoByRoleId(v)
    memberInfo.isRewardLiHe = 1
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberLiheChanged, nil)
end
def.static("table").OnSSyncCangKuLiHeChange = function(p)
  local data = GangModule.Instance().data
  data:SetRemainLihe(p.liheNum)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_LiheInfoChanged, nil)
end
def.static("table").OnSGangSignReq = function(p)
  if p.result == 1 then
    Toast(textRes.Gang[142])
    local data = GangModule.Instance().data
    data:SetSignToday(1)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangSignChanged, nil)
  end
end
def.static("table").OnSSyncGangSignReq = function(p)
  local data = GangModule.Instance().data
  local memberInfo = data:GetMemberInfoByRoleId(p.roleId)
  if nil ~= memberInfo then
    local strSign = p.signStr
    if strSign == "" then
      strSign = textRes.Gang[137]
    end
    strSign = string.gsub(strSign, "<", "&lt;")
    strSign = string.gsub(strSign, ">", "&gt;")
    local display = string.format(textRes.Gang[178], memberInfo.name, strSign)
    GangModule.ShowInGangChannel(display)
  end
end
def.static("table").OnSChangeSignStrReq = function(p)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if p.result == 1 then
    Toast(textRes.Gang[49])
    local data = GangModule.Instance().data
    data:SetStrSign(p.signStr)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangSignStrChanged, nil)
  end
end
def.static("table").OnSGetSignState = function(p)
  local data = GangModule.Instance().data
  data:SetSignToday(p.state)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangSignChanged, nil)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {
    require("Main.Gang.ui.HaveGangPanel").NodeId.WELFARE
  })
end
def.static("table").OnSOutGangNotify = function(p)
  local data = GangModule.Instance().data
  data:SetIsKickedOffline(true)
  if GangModule.Instance().bMainUICreate == true then
    data:SetIsKickedOffline(false)
    GangUtility.ShowRejoinGangPrompt()
  end
end
def.static("table").OnSSyncMemberGongXunBrd = function(p)
  local data = GangModule.Instance().data
  data:UpdateMemberGongXunByRoleId(p.memberid, p.gongXun)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberGongXunChanged, nil)
end
def.static("table").OnSRefreshGongXunRes = function(p)
  local data = GangModule.Instance().data
  data:SyncAllMemberGongXun(p.roleid2gongxun)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberGongXunChanged, nil)
end
def.static("table").OnSGetFuLiRes = function(p)
  local data = GangModule.Instance().data
  data:SetFuli(1)
end
def.static("table").OnSSyncGangQQGroupRes = function(p)
  local GangGroupData = require("Main.Gang.GangGroup.GangGroupData")
  GangGroupData.Instance():SyncQQGroupInfo(p)
end
def.static("table").OnSSetLeaveGangWithQQGroup = function(p)
  local GangGroupMgr = require("Main.Gang.GangGroup.GangGroupMgr")
  GangGroupMgr.Instance():UnBindQQGroupQuietly(p.groupOpenId)
end
def.static("table").OnSGetCombineGangListRes = function(p)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeListReceived, {
    p.gangs
  })
end
def.static("table").OnSCombineGangApplyRes = function(p)
  local time = GetServerTime() + constant.CGangConst.COMBINE_APPLY_HOURS * 3600
  local data = GangModule.Instance().data
  data:SetCombineGangInfo(time, p.targetid, p.target_name)
  data:SetCombineApplyGangId(data:GetGangId())
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangStageChange, nil)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangApplyRes, nil)
  Toast(string.format(textRes.Gang[300], p.target_name))
end
def.static("table").OnSCombineGangApplyTrs = function(p)
  local data = GangModule.Instance().data
  data:SetHaveGangMergeApply(true)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {0})
end
def.static("table").OnSCombineGangApplyResultBrd = function(p)
  local data = GangModule.Instance().data
  local selfGangId = data:GetGangId()
  if p.result == 0 then
    local time = GetServerTime()
    if Int64.eq(selfGangId, p.targetid) then
      local gangname = data:GetSaveGangName(p.srcid)
      data:SetCombineGangInfo(time, p.srcid, gangname)
      data:SetCombineApplyGangId(p.srcid)
    elseif Int64.eq(selfGangId, p.srcid) then
      data:SetCombineGangInfo(time, p.targetid, "")
      data:SetCombineApplyGangId(selfGangId)
    end
  else
    if p.result ~= 1 or Int64.eq(selfGangId, p.srcid) then
    else
    end
    data:SetCombineGangInfo(-1, nil, "")
    data:SetCombineApplyGangId(nil)
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangStageChange, nil)
end
def.static("table").OnSCombineGangCancelBrd = function(p)
  local data = GangModule.Instance().data
  local selfGangId = data:GetGangId()
  if Int64.eq(selfGangId, p.targetid) then
    local targetGangId = data:GetCombineGangInfo().targetGangId
    if targetGangId and Int64.eq(targetGangId, p.srcid) then
      data:SetCombineGangInfo(-1, nil, "")
      data:SetCombineApplyGangId(nil)
      Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangStageChange, nil)
    end
  elseif Int64.eq(selfGangId, p.srcid) then
    data:SetCombineGangInfo(-1, nil, "")
    data:SetCombineApplyGangId(nil)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangStageChange, nil)
  end
end
def.static("table").OnSGangCombineBrd = function(p)
  local data = GangModule.Instance().data
  if p.result == 0 then
    local display
    if p.come_from == 0 then
      data:SetCombineGangInfo(-1, nil, "")
      data:SetCombineApplyGangId(nil)
      Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangStageChange, nil)
      display = string.format(textRes.Gang[303], p.vice_name)
    elseif p.come_from == 1 then
      data:SetCombineGangInfo(-1, nil, "")
      data:SetCombineApplyGangId(nil)
      Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangStageChange, nil)
      display = string.format(textRes.Gang[304], p.main_name)
    else
      warn("------OnSGangCombineBrd for third")
    end
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangCombineOver, nil)
    if display then
      GangModule.ShowInGangChannel(display)
    end
  else
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GangCombineOver, nil)
  end
  local ManagementGangPanel = require("Main.Gang.ui.GangManagment.ManagementGangPanel")
  if ManagementGangPanel.Instance():IsShow() then
    ManagementGangPanel.Instance():Hide()
  end
end
def.static("table").OnSCombineGangApplicantsRes = function(p)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeReqListReceived, {
    p.applicants
  })
end
def.static("table").OnSSyncCombine = function(p)
  local time = p.timestamp:ToNumber()
  local gangInfo = p.target_gang
  if time > 0 then
    time = math.floor(time / 1000)
  else
    time = -1
  end
  local data = GangModule.Instance().data
  data:SetCombineGangInfo(time, gangInfo.gangid, gangInfo.name)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MergeCombineGangStageChange, nil)
  local isFindTarget = false
  local isHaveApply = false
  for k, gangid in ipairs(p.applicants) do
    if not Int64.eq(gangid, gangInfo.gangid) then
      isHaveApply = true
    else
      isFindTarget = true
    end
  end
  if isHaveApply then
    local data = GangModule.Instance().data
    data:SetHaveGangMergeApply(true)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_NoticeStatesChanged, {0})
  end
  if time > 0 then
    local curTime = GetServerTime()
    if time < curTime and isFindTarget then
      data:SetCombineApplyGangId(gangInfo.gangid)
    else
      data:SetCombineApplyGangId(data:GetGangId())
    end
  else
    data:SetCombineApplyGangId(nil)
  end
end
def.static("table").OnSKickByCombineNotify = function(p)
  local ManagementGangPanel = require("Main.Gang.ui.GangManagment.ManagementGangPanel")
  if ManagementGangPanel.Instance():IsShow() then
    ManagementGangPanel.Instance():Hide()
  end
  local data = GangModule.Instance().data
  data:SetAllNull()
  GangModule.FromGangToNo(true)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_InfoChanged, nil)
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_MemberChange, nil)
end
return GangModule.Commit()
