local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local OutFightTargetPanel = Lplus.Extend(ECPanelBase, "OutFightTargetPanel")
local def = OutFightTargetPanel.define
local GangBattleMgr = require("Main.Gang.GangBattleMgr")
local GangCrossBattleMgr = require("Main.GangCross.GangCrossBattleMgr")
local TipsHelper = require("Main.Common.TipsHelper")
local BattleFieldMgr = require("Main.CaptureTheFlag.mgr.BattleFieldMgr")
local GUIUtils = require("GUI.GUIUtils")
def.field("boolean").isCreated = false
def.field("userdata").roleId = nil
def.field("table").roleInfo = nil
def.field("userdata").ui_Img_BgTarget = nil
def.field("userdata").btn_PayNearYear = nil
local instance
def.static("=>", OutFightTargetPanel).Instance = function()
  if instance == nil then
    instance = OutFightTargetPanel()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_ROLE, OutFightTargetPanel.OnClickRole)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.HERO_CLICKMAP_FINDPATH, OutFightTargetPanel.OnClickGround)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_NPC, OutFightTargetPanel.OnClickNPC)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_PET, OutFightTargetPanel.OnClickPet)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_MONSTER, OutFightTargetPanel.OnClickMonster)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_CHILD, OutFightTargetPanel.OnClickChild)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, OutFightTargetPanel.OnMapChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, OutFightTargetPanel.OnEnterFight)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, OutFightTargetPanel.OnFeatureOpenChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paynewyear.SPayNewYearSuccess", OutFightTargetPanel.OnPayNewYearSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.paynewyear.SPayNewYearNormalFail", OutFightTargetPanel.OnPayNewYearNormalFail)
end
def.method("userdata").ShowPanel = function(self, roleId)
  self.roleId = roleId
  if self.isCreated then
    self:Show(true)
    return
  end
  self:SetDepth(GUIDEPTH.BOTTOM)
  self:CreatePanel(RESPATH.PREFAB_OUTFIGHT_TARGET, _G.GUIDEPTH.BOTTOM)
end
def.method().HidePanel = function(self)
  self:Show(false)
end
def.override().OnCreate = function(self)
  self.ui_Img_BgTarget = self.m_panel:FindDirect("Img_BgTarget")
  self.isCreated = true
  self.btn_PayNearYear = self.ui_Img_BgTarget:FindDirect("Btn_BaiNian")
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:SetRoleInfo()
end
def.override().OnDestroy = function(self)
  self.isCreated = false
  self.ui_Img_BgTarget = nil
  self.roleInfo = nil
  self.roleId = nil
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Img_BgTarget" then
    self:OnRequireTargetOP()
  elseif id == "Btn_BaiNian" then
    self:OnBtnPayNearYearClicked()
  end
end
def.method().SetRoleInfo = function(self)
  self.m_panel:SetActive(false)
  gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):ReqRoleInfo(self.roleId, OutFightTargetPanel.OnSGetRoleInfoRes)
end
def.static("table").OnSGetRoleInfoRes = function(data)
  local self = instance
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local FightMgr = require("Main.Fight.FightMgr")
  if FightMgr.Instance().isInFight then
    self:HidePanel()
    return
  end
  self.roleInfo = data
  self:UpdateRoleInfo()
  self:ShowPayNearYearBtn()
  self.m_panel:SetActive(true)
end
def.method().UpdateRoleInfo = function(self)
  local role = self.roleInfo
  if role == nil then
    return
  end
  local name = role.name
  local occupation = role.occupationId
  local gender = role.gender
  local level = role.level
  local avatarId = role.avatarId
  local avatarFrameId = role.avatarFrameId or 0
  self.ui_Img_BgTarget:FindDirect("Label_TargetName"):GetComponent("UILabel"):set_text(name)
  local Img_IconHead = self.ui_Img_BgTarget:FindDirect("Img_IconHead")
  _G.SetAvatarIcon(Img_IconHead, avatarId, avatarFrameId)
  local head = self.ui_Img_BgTarget:FindDirect("Img_IconHead/Label_LV"):GetComponent("UILabel"):set_text(level)
  local Img_Sex = self.ui_Img_BgTarget:FindDirect("Img_Sex")
  local Img_IconSchool = self.ui_Img_BgTarget:FindDirect("Img_IconSchool")
  local genderSprite = GUIUtils.GetSexIcon(gender)
  GUIUtils.SetSprite(Img_Sex, genderSprite)
  local occupationSprite = GUIUtils.GetOccupationSmallIcon(occupation)
  GUIUtils.SetSprite(Img_IconSchool, occupationSprite)
end
local clickedRole = false
def.static("table", "table").OnClickRole = function(params, context)
  local pubroleModule = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  if pubroleModule.isOnlyShowSpecificRoles then
    return
  end
  local roleId = params[1]
  if roleId == nil or roleId:eq(0) or roleId:lt(0) then
    return
  end
  local role = pubroleModule:GetRole(roleId)
  local myself = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myself and myself:IsInState(RoleState.GANGBATTLE) then
    local ret = GangBattleMgr.Instance():IsRival(roleId)
    if ret < 0 then
      pubroleModule:ReqRoleInfo(roleId, GangBattleMgr.OnSGetRoleInfoRes)
    elseif ret > 0 then
      GangBattleMgr.Instance():PKRole(roleId)
    else
      clickedRole = true
      instance:ShowPanel(roleId)
    end
  elseif myself and myself:IsInState(RoleState.GANGCROSS_BATTLE) then
    local ret = GangCrossBattleMgr.Instance():IsRival(roleId)
    if ret < 0 then
      pubroleModule:ReqRoleInfo(roleId, GangCrossBattleMgr.OnSGetRoleInfoRes)
    elseif ret > 0 then
      GangCrossBattleMgr.Instance():PKRole(roleId)
    else
      clickedRole = true
      instance:ShowPanel(roleId)
    end
  elseif myself and myself:IsInState(RoleState.SINGLEBATTLE) then
    local enemy = BattleFieldMgr.Instance():IsEnemy(roleId)
    if enemy then
      if role:IsInState(RoleState.SINGLEBATTLE_DEATH) then
        Toast(textRes.CaptureTheFlag[10])
      elseif not role:IsInState(RoleState.BATTLE) then
        BattleFieldMgr.Instance():FightRole(role)
      else
        Toast(textRes.CaptureTheFlag[9])
      end
    else
      clickedRole = true
      instance:ShowPanel(roleId)
    end
  else
    clickedRole = true
    instance:ShowPanel(roleId)
  end
end
def.static("table", "table").OnClickGround = function(params, context)
  if not clickedRole then
    instance:HidePanel()
  end
  clickedRole = false
end
def.static("table", "table").OnClickNPC = function(params, context)
  instance:HidePanel()
end
def.static("table", "table").OnClickPet = function(params, context)
  instance:HidePanel()
end
def.static("table", "table").OnClickMonster = function(params, context)
  instance:HidePanel()
end
def.static("table", "table").OnClickChild = function(params, context)
  instance:HidePanel()
end
def.static("table", "table").OnMapChange = function()
  instance:HidePanel()
end
def.static("table", "table").OnEnterFight = function()
  instance:HidePanel()
end
def.method().OnRequireTargetOP = function(self)
  if self.roleId == 0 then
    return
  end
  if self.m_panel == nil then
    return
  end
  local roleInfo = self.roleInfo
  local sourceObj = self.ui_Img_BgTarget:FindDirect("Img_IconHead")
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  require("Main.Pubrole.PubroleTipsMgr").Instance():ShowTip(roleInfo, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1, {inMap = true})
end
def.method().ShowPayNearYearBtn = function(self)
  if self.btn_PayNearYear == nil then
    return
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local bPayNewYearServerOpen = feature:CheckFeatureOpen(Feature.TYPE_PAY_NEW_YEAR)
  if bPayNewYearServerOpen == false then
    self.btn_PayNearYear:SetActive(false)
    return
  end
  local roleInfo = self.roleInfo
  if self:isMeetPayNewYearCondition() then
    self.btn_PayNearYear:SetActive(true)
  else
    self.btn_PayNearYear:SetActive(false)
    return
  end
end
def.method("=>", "boolean").isMeetPayNewYearCondition = function(self)
  if self.roleInfo == nil then
    return false
  end
  local nowSec = _G.GetServerTime()
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local activityID = constant.CPayNewYearConsts.pay_new_year_activity_cfg_id
  local activityCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(activityID)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  local timeLimitCfg = TimeCfgUtils.GetTimeLimitCommonCfg(activityCfg.activityLimitTimeid)
  local bIsInDate = false
  if timeLimitCfg ~= nil then
    local beginTimeSec = TimeCfgUtils.GetTimeSec(timeLimitCfg.startYear, timeLimitCfg.startMonth, timeLimitCfg.startDay, timeLimitCfg.startHour, timeLimitCfg.startMinute, 0)
    local endTimeSec = TimeCfgUtils.GetTimeSec(timeLimitCfg.endYear, timeLimitCfg.endMonth, timeLimitCfg.endDay, timeLimitCfg.endHour, timeLimitCfg.endMinute, 0)
    bIsInDate = nowSec >= beginTimeSec and nowSec <= endTimeSec
  else
    return false
  end
  local myProp = require("Main.Hero.HeroModule").Instance():GetHeroProp()
  if myProp == nil then
    return false
  end
  local mylevel = myProp.level
  if mylevel >= constant.CPayNewYearConsts.pay_new_year_function_open_level and bIsInDate then
    return true
  else
    return false
  end
end
def.method().OnBtnPayNearYearClicked = function(self)
  if self.roleInfo ~= nil and self.roleId ~= nil then
    local p = require("netio.protocol.mzm.gsp.paynewyear.CPayNewYear").new(self.roleId)
    gmodule.network.sendProtocol(p)
  else
    warn("Can't get role information when PayNewYear Butuon be clicked")
  end
end
def.static("table").OnPayNewYearSuccess = function(p)
  local active_PNY_tipID = constant.CPayNewYearConsts.active_pay_new_year_tips_id
  local str = TipsHelper.GetHoverTip(active_PNY_tipID)
  Toast(string.format(str, _G.GetStringFromOcts(p.role_name)))
  local actionId = require("consts.mzm.gsp.map.confbean.ExpressionActionType").BOW
  require("Main.Chat.ui.DlgAction").Instance():PlayAction(actionId)
  local getAwardMaxTimes = constant.CPayNewYearConsts.pay_new_year_award_times_every_day
  if p.aleardy_pay_new_year_times ~= nil and getAwardMaxTimes >= p.aleardy_pay_new_year_times then
    local redGiftPanel = require("Main.MainUI.ui.PayNewYearRedGiftPanel").Instance()
    redGiftPanel:SetOpenRedGiftCallback(function()
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.paynewyear.CGetPayNewYearAward").new())
    end)
    redGiftPanel:ShowDlg()
  else
    local tipStr = textRes.activity.payNewYear[1]
    Toast(tipStr)
  end
end
def.static("table").OnPayNewYearNormalFail = function(p)
  local SPayNewYearNormalFail = require("netio.protocol.mzm.gsp.paynewyear.SPayNewYearNormalFail")
  local activityTxtRes = require("textRes.activity")
  if p.result ~= nil then
    if p.result == SPayNewYearNormalFail.ACTIVITY_CAN_NOT_JOIN then
      local tipStr = textRes.activity.payNewYear[2]
      Toast(tipStr)
    elseif p.result == SPayNewYearNormalFail.LAST_AWARD_NOT_GET then
      local tipStr = textRes.activity.payNewYear[4]
      Toast(tipStr)
    elseif p.result == SPayNewYearNormalFail.CAN_NOT_PAY_NEW_YEAR_YOURSELF then
      Toast(textRes.activity.paynewyear[5])
    end
  else
    warn("Pay New Year failed .....")
  end
end
def.static("table").OnRecvPayNewYear = function(p)
  if p == nil or p.role_name == nil then
    return
  end
  local passive_PNY_tipID = constant.CPayNewYearConsts.passive_pay_new_year_tips_id
  Toast(string.format(TipsHelper.GetHoverTip(passive_PNY_tipID), _G.GetStringFromOcts(p.role_name)))
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  if p == nil then
    return
  end
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p.feature == Feature.TYPE_PAY_NEW_YEAR then
    local activityInterface = require("Main.activity.ActivityInterface").Instance()
    if p.open then
      activityInterface:removeCustomCloseActivity(constant.CPayNewYearConsts.pay_new_year_activity_cfg_id)
    else
      activityInterface:addCustomCloseActivity(constant.CPayNewYearConsts.pay_new_year_activity_cfg_id)
    end
  end
end
def.static("table", "table").OnFeatureInit = function(p, context)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local bPayNewYearServerOpen = feature:CheckFeatureOpen(Feature.TYPE_PAY_NEW_YEAR)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if bPayNewYearServerOpen then
    activityInterface:removeCustomCloseActivity(constant.CPayNewYearConsts.pay_new_year_activity_cfg_id)
  else
    activityInterface:addCustomCloseActivity(constant.CPayNewYearConsts.pay_new_year_activity_cfg_id)
  end
end
OutFightTargetPanel.Commit()
return OutFightTargetPanel
