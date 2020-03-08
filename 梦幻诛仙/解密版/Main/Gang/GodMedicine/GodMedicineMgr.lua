local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GodMedicineMgr = Lplus.Class(MODULE_NAME)
local Cls = GodMedicineMgr
local def = Cls.define
local instance
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local GodMedicineUtils = require("Main.Gang.GodMedicine.GodMedicineUtils")
local ChatModule = Lplus.ForwardDeclare("ChatModule")
local txtConst = textRes.Gang.GodMedicine
def.field("table")._openActIdList = nil
def.static("=>", GodMedicineMgr).Instance = function()
  if instance == nil then
    instance = GodMedicineMgr()
    instance._openActIdList = GodMedicineUtils.LoadAllOpenActIds()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskillactivity.SCreateLifeSkillItemSuccess", Cls.OnSGetLifeSkillAwards)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskillactivity.SCreateLifeSkillItemFailed", Cls.OnSGetLifeSkillAwardsFailed)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, Cls.OnNPCService)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, Cls.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, Cls.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, Cls.OnActivityReset)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, Cls.OnActivityInfoChanged)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.SYNC_SERVER_LEVEL, Cls.OnServeLvChange)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_BAG_LEVEL_UP_SUCCESS, Cls.OnSkillLvUpSuccess)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_VitalityChanged, Cls.OnGangVitalityChg)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, Cls.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, Cls.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, Cls.OnLeaveWorld)
  for i = 1, #self._openActIdList do
    local actId = self._openActIdList[i].actId
    self._openActIdList[i].isActivityStart = false
    require("Main.activity.ActivityModule").Instance():RegisterActivityTipFuncEx(actId, Cls.activityTipFunc)
  end
end
def.static("number", "boolean").DisplayActivityTip = function(actId, bServerStart)
  if _G.IsCrossServer() then
    return
  end
  if not Cls.IsActivityOpen(actId) then
    return
  end
end
def.static("number", "=>", "boolean").IsActivityOpen = function(actId)
  return true
end
def.static("number", "=>", "boolean").IsGodMedicineAct = function(actId)
  for i = 1, #instance._openActIdList do
    if instance._openActIdList[i].actId == actId then
      return true
    end
  end
  return false
end
def.static("number", "=>", "userdata").GetMoneyNumByType = function(mtype)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local ItemModule = require("Main.Item.ItemModule")
  if mtype == MoneyType.YUANBAO then
    return ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
  else
    if mtype == MoneyType.SILVER then
      mtype = ItemModule.MONEY_TYPE_SILVER
    elseif mtype == MoneyType.GOLD then
      mtype = ItemModule.MONEY_TYPE_GOLD
    elseif mtype == MoneyType.GOLD_INGOT then
      mtype = ItemModule.MONEY_TYPE_GOLD_INGOT
    end
    return ItemModule.Instance():GetMoney(mtype) or Int64.new(0)
  end
end
def.method("number", "=>", "number").GetOpenIdByActId = function(self, actId)
  for i = 1, #instance._openActIdList do
    if instance._openActIdList[i].actId == actId then
      return instance._openActIdList[i].openId
    end
  end
  return -1
end
def.method("number", "=>", "number").GetActIdByOpenId = function(self, openId)
  for i = 1, #instance._openActIdList do
    if instance._openActIdList[i].openId == openId then
      return instance._openActIdList[i].actId
    end
  end
  return -1
end
def.static("number", "=>", "boolean").activityTipFunc = function(actId)
  local actCfg = GodMedicineUtils.GetActivityCfgById(actId)
  if actCfg ~= nil then
    local bSatified = Cls.IsSatifyAllRequirementsAndToast(actCfg, false)
    return bSatified
  end
  return false
end
def.static("table", "boolean", "=>", "boolean").IsSatifyAllRequirementsAndToast = function(actCfg, bToast)
  local curSrvrLv = require("Main.Server.ServerModule").Instance():GetServerLevelInfo().level
  local gangData = require("Main.Gang.GangModule").Instance().data
  local gangId = gangData:GetGangId()
  if gangId == nil then
    if bToast then
      Toast(txtConst[4])
    end
    return false
  end
  local curBuildingLv = gangData:GetPharmacyLevel()
  local curGangVitality = gangData:GetVitality()
  local retRes = true
  if curSrvrLv < actCfg.openServerLevel then
    if bToast then
      Toast(txtConst[5])
    end
    retRes = false
  elseif curGangVitality < actCfg.openLivelyLowRate then
    if bToast then
      Toast(txtConst[6])
    end
    retRes = false
  else
    local minLv = GodMedicineUtils.GetMinYaoDianLvByActid(actCfg.actId)
    if curBuildingLv < minLv then
      retRes = false
      if bToast then
        Toast(txtConst[7])
      end
    end
  end
  return retRes
end
def.static("boolean", "number").updateActivityInterface = function(bFeatureOpen, actId)
  local activityInterface = ActivityInterface.Instance()
  if bFeatureOpen then
    activityInterface:removeCustomCloseActivity(actId)
  else
    activityInterface:addCustomCloseActivity(actId)
  end
end
def.static("number", "=>", "number").GetLeftTimes = function(actId)
  local activityInterface = ActivityInterface.Instance()
  local activityInfo = activityInterface:GetActivityInfo(actId)
  local costCfg = Cls.GetCostCfg(actId)
  if activityInfo == nil then
    return costCfg.maxTimes
  else
    return costCfg.maxTimes - activityInfo.count
  end
end
def.static("number", "=>", "table").GetCostCfg = function(actId)
  local gangData = require("Main.Gang.GangModule").Instance().data
  local curYaoDianLv = gangData:GetPharmacyLevel()
  local cfg = GodMedicineUtils.GetCostInfoLvByActidAndLv(actId, curYaoDianLv)
  return cfg
end
def.static("number", "=>", "boolean").IsInActivityPeriod = function(actId)
  return ActivityInterface.Instance():isActivityOpend2(actId)
end
def.static("table", "=>", "boolean").filterSkillBagFunc = function(skillBag)
  if skillBag == nil then
    return true
  end
  local LifeSkillBagShowTypeEnum = require("consts.mzm.gsp.skill.confbean.LifeSkillBagShowTypeEnum")
  return skillBag.showType == LifeSkillBagShowTypeEnum.type4
end
def.static("table").SendTipMsg = function(actCfg)
  local content = actCfg.joinPromptDes
  local button = string.format("<a href='shenyao_%d' id=shenyao_%d><font color=#%s><u>[%s]</u></font></a>", actCfg.actId, actCfg.actId, _G.link_defalut_color, txtConst[10])
  local str = string.format("%s%s", content, button)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  require("Main.Chat.ChatModule").Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.static("string").OnHyperLinkClick = function(str)
  if str == "" then
    return
  end
  local strs = string.split(str, "_")
  local actId = tonumber(strs[2])
  Cls.OnActivityTodo({actId}, nil)
end
def.static("table").SendActivityEndNoteMsg = function(actCfg)
  local activityCfg = ActivityInterface.GetActivityCfgById(actCfg.actId)
  if activityCfg == nil then
    return
  end
  local str = txtConst[11]:format(activityCfg.activityName)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  require("Main.Chat.ChatModule").Instance():SendNoteMsg(str, ChatMsgData.MsgType.CHANNEL, ChatMsgData.Channel.FACTION)
end
def.static("table", "table").OnNPCService = function(p, c)
  local srvcId = p[1]
  local npcid = p[2]
  for i = 1, #instance._openActIdList do
    local actId = instance._openActIdList[i].actId
    local npcId = instance._openActIdList[i].npcId
    local isrvcId = instance._openActIdList[i].srvcId
    local actCfg
    if npcId == nil then
      actCfg = GodMedicineUtils.GetActivityCfgById(actId)
      npcId = actCfg.npcCfgId
      isrvcId = actCfg.npcServiceId
      instance._openActIdList[i].srvcId = isrvcId
      instance._openActIdList[i].npcId = npcId
    end
    if npcId == npcid and srvcId == isrvcId then
      if _G.CheckCrossServerAndToast() then
        return
      end
      if actCfg == nil then
        actCfg = GodMedicineUtils.GetActivityCfgById(actId)
      end
      if not Cls.IsInActivityPeriod(actId) then
        Toast(txtConst[9])
        return
      end
      local minLifeSkillLv = actCfg.openLifeSkillLevel
      local skillBag = require("Main.Skill.data.LivingSkillData").Instance():GetSkillBagById(actCfg.lifeSkillId)
      local curLifeSkillLv = skillBag.level
      if minLifeSkillLv > curLifeSkillLv then
        Toast(txtConst[8]:format(minLifeSkillLv))
        return
      end
      local iLeftTimes = Cls.GetLeftTimes(actId)
      if iLeftTimes < 1 then
        Toast(txtConst[3])
        return
      end
      local bSatified = Cls.IsSatifyAllRequirementsAndToast(actCfg, true)
      if bSatified then
        require("Main.Gang.GodMedicine.ui.UIGodMedicine").Instance():ShowPanel(actId)
      end
      break
    end
  end
end
def.static("table", "table").OnActivityTodo = function(p, c)
  local actId = 0
  for i = 1, #instance._openActIdList do
    if p[1] == instance._openActIdList[i].actId then
      actId = p[1]
    end
  end
  if actId == 0 then
    return
  end
  if Cls.IsInActivityPeriod(actId) then
    if _G.CheckCrossServerAndToast() then
      return
    end
    local actCfg = GodMedicineUtils.GetActivityCfgById(actId)
    if actCfg == nil then
      return
    end
    local bSatified = Cls.IsSatifyAllRequirementsAndToast(actCfg, true)
    if bSatified then
      if 1 > Cls.GetLeftTimes(actId) then
        Toast(txtConst[3])
        return
      end
      local npcid = actCfg.npcCfgId
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, {npcid})
    end
  else
    Toast(textRes.activity[51])
  end
end
def.static("table", "table").OnActivityStart = function(p, c)
  Cls.activityStateChg(p)
end
def.static("table", "table").OnActivityReset = function(p, c)
  Cls.activityStateChg(p)
end
def.static("table", "table").OnActivityInfoChanged = function(p, c)
  Cls.activityStateChg(p)
end
def.static("table", "table").OnServeLvChange = function(p, c)
  for i = 1, #instance._openActIdList do
    Cls.activityStateChg({
      instance._openActIdList[i].actId
    })
  end
end
def.static("table", "table").OnSkillLvUpSuccess = function(p, c)
  for i = 1, #instance._openActIdList do
    Cls.activityStateChg({
      instance._openActIdList[i].actId
    })
  end
end
def.static("table", "table").OnGangVitalityChg = function(p, c)
  for i = 1, #instance._openActIdList do
    Cls.activityStateChg({
      instance._openActIdList[i].actId
    })
  end
end
def.static("table").activityStateChg = function(params)
  local actId = params[1]
  local bShowRedPt = false
  local bIsTargetAct = false
  local bShowNpc = true
  for i = 1, #instance._openActIdList do
    if actId == instance._openActIdList[i].actId then
      bIsTargetAct = true
      do
        local LivingSkillData = require("Main.Skill.data.LivingSkillData")
        if not LivingSkillData.Instance().bSyndBagLvList then
          break
        end
        local actOpenInfo = instance._openActIdList[i]
        local actCfg = GodMedicineUtils.GetActivityCfgById(actId)
        if not Cls.IsInActivityPeriod(actId) then
          bShowNpc = false
          if actOpenInfo.isActivityStart then
            Cls.SendActivityEndNoteMsg(actCfg)
            if actOpenInfo.timer ~= nil then
              _G.GameUtil.RemoveGlobalTimer(actOpenInfo.timer)
              actOpenInfo.timer = nil
            end
          end
          actOpenInfo.isActivityStart = false
          break
        else
          if not actOpenInfo.isActivityStart then
            Cls.SendTipMsg(actCfg)
            if actOpenInfo.timer ~= nil then
              _G.GameUtil.RemoveGlobalTimer(actOpenInfo.timer)
            end
            actOpenInfo.timer = _G.GameUtil.AddGlobalTimer(900, false, function()
              Cls.SendTipMsg(actCfg)
            end)
          end
          actOpenInfo.isActivityStart = true
        end
        local iLeftTimes = Cls.GetLeftTimes(actId)
        if iLeftTimes < 1 then
          bShowNpc = false
          break
        end
        if not Cls.IsSatifyAllRequirementsAndToast(actCfg, false) then
          local curSrvrLv = require("Main.Server.ServerModule").Instance():GetServerLevelInfo().level
          bShowNpc = curSrvrLv >= actCfg.openServerLevel
          break
        end
        local minLifeSkillLv = actCfg.openLifeSkillLevel
        local skillBag = LivingSkillData.Instance():GetSkillBagById(actCfg.lifeSkillId)
        local curLifeSkillLv = skillBag.level
        if minLifeSkillLv > curLifeSkillLv then
          break
        end
        bShowRedPt = true
        break
      end
    end
  end
  if bIsTargetAct then
    local gangUtility = require("Main.Gang.GangUtility").Instance()
    if bShowRedPt then
      gangUtility:AddGangActivityRedPoint(actId)
    else
      gangUtility:RemoveGangActivityRedPoint(actId)
    end
    Cls.SetNpcVisibleByActId(actId, bShowNpc)
  end
end
def.static("table", "table").OnFeatureInit = function(p, c)
  local featureOpenModule = FeatureOpenListModule.Instance()
  for i = 1, #instance._openActIdList do
    local mapActidOpenId = instance._openActIdList[i]
    local bFeatureOpen = featureOpenModule:CheckFeatureOpen(mapActidOpenId.openId)
    Cls.updateActivityInterface(bFeatureOpen, mapActidOpenId.actId)
    Cls.activityStateChg({
      mapActidOpenId.actId
    })
  end
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  local featureOpenModule = FeatureOpenListModule.Instance()
  for i = 1, #instance._openActIdList do
    local mapActidOpenId = instance._openActIdList[i]
    if mapActidOpenId.openId == p.feature then
      Cls.updateActivityInterface(p.open, mapActidOpenId.actId)
      Cls.activityStateChg({
        mapActidOpenId.actId
      })
      return
    end
  end
end
def.static("table", "table").OnLeaveWorld = function(p, c)
  for i = 1, #instance._openActIdList do
    local actOpenInfo = instance._openActIdList[i]
    if actOpenInfo.timer ~= nil then
      _G.GameUtil.RemoveGlobalTimer(actOpenInfo.timer)
      actOpenInfo.timer = nil
    end
  end
end
def.static("number", "boolean").SetNpcVisibleByActId = function(actId, bVisible)
  local actCfg = GodMedicineUtils.GetActivityCfgById(actId)
  local npcid = actCfg.npcCfgId
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {npcid = npcid, show = bVisible})
end
def.static("number").CSendGetLifeSkillAwards = function(actId)
  local p = require("netio.protocol.mzm.gsp.lifeskillactivity.CCreateLifeSkillItem").new(actId)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetLifeSkillAwards = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(p.item_id)
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  local strTable = {}
  local color = HtmlHelper.NameColor[itemBase.namecolor]
  local content = txtConst[12]:format(color, itemBase.name, p.item_num)
  Toast(content)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.PERSONAL, HtmlHelper.Style.Personal, {content = content})
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.MakeMedicineSuccess, {
    activityId = p.activity_cfgid
  })
end
def.static("table").OnSGetLifeSkillAwardsFailed = function(p)
  warn("ERROR: On Getlifeskill failed, error code:", p.retcode)
  if txtConst[p.retcode] ~= nil then
    Toast(txtConst[p.retcode])
  end
end
return Cls.Commit()
