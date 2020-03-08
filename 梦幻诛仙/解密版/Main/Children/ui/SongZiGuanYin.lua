local Lplus = require("Lplus")
local PanelBase = require("GUI.ECPanelBase")
local SongZiGuanYin = Lplus.Extend(PanelBase, "SongZiGuanYin")
local ChildrenInterface = require("Main.Children.ChildrenInterface")
local GUIUtils = require("GUI.GUIUtils")
local instance
local def = SongZiGuanYin.define
def.field("number")._integral = 0
def.field("boolean")._bHasCreated = false
def.field("userdata")._progressbar_integral = nil
def.field("table")._DlgGongOn = nil
def.field("table")._DlgBeenSwamped = nil
def.field("number")._iMaxGongOnNum = 0
def.field("number")._iMaxSignNum = 0
def.field("boolean")._bGongOnFeatureOpen = true
def.field("boolean")._bToSignFeatureOpen = true
def.static("=>", SongZiGuanYin).Instance = function()
  if instance == nil then
    instance = SongZiGuanYin()
  end
  return instance
end
def.override().OnCreate = function(self)
  self:Init()
  self._bHasCreated = true
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GET_BABY_PHASE_CHANGED, SongZiGuanYin.OnGetBabyPhaseChanged)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Get_Baby, SongZiGuanYin.OnGetBaby)
  if self._DlgGongOn ~= nil then
    self._DlgGongOn:HidePanel()
  end
  self._bHasCreated = false
  self._progressbar_integral = nil
  self._integral = 0
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GET_BABY_PHASE_CHANGED, SongZiGuanYin.OnGetBabyPhaseChanged)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Get_Baby, SongZiGuanYin.OnGetBaby)
  local signActID = constant.GuanYinConsts.QIUQIAN_ACTIVITY_CFG_ID
  local signCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(signActID)
  self._iMaxSignNum = signCfg.limitCount
  local gongOnActID = constant.GuanYinConsts.SHANGGONG_ACTIVITY_CFG_ID
  local signCfg = require("Main.activity.ActivityInterface").GetActivityCfgById(gongOnActID)
  self._iMaxGongOnNum = signCfg.limitCount
  self:UpdateIntegralUI()
end
def.method("number", "number", "string", "=>", "boolean").IsCanJoinActivity = function(self, actId, maxCount, tipMsg)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local activityInfo = activityInterface:GetActivityInfo(actId)
  if activityInfo ~= nil and maxCount <= activityInfo.count then
    Toast(string.format(tipMsg, activityInfo.count, maxCount))
    return false
  end
  return true
end
def.method().UpdateIntegralUI = function(self)
  local maxInteralVal = ChildrenInterface.GetMaxSingleQiuziScore()
  self._integral = ChildrenInterface.GetCurrentSingleQiuziScore()
  local label_needs_integral = self.m_panel:FindDirect("Img_Bg/Label_Score")
  GUIUtils.SetText(label_needs_integral, string.format(textRes.Children.SongZiGuanYin[2], maxInteralVal))
  local slider = label_needs_integral:FindDirect("Slider_JiFen"):GetComponent("UISlider")
  slider:set_sliderValue(self._integral / maxInteralVal)
  local labelCurPt = label_needs_integral:FindDirect("Slider_Thumb/Label_CurPoint")
  local labelTxt = string.format(textRes.Children.SongZiGuanYin[1], self._integral)
  GUIUtils.SetText(labelCurPt, labelTxt)
end
def.method().ShowPanel = function(self)
  self:UpdateIDIPFeature()
  if not self._bGongOnFeatureOpen and not self._bToSignFeatureOpen then
    return
  end
  if self._bHasCreated then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_SONGZIGUANYIN_UI, 0)
  self:Show(true)
end
def.method().UpdateIDIPFeature = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  self._bGongOnFeatureOpen = feature:CheckFeatureOpen(Feature.TYPE_GUAN_YIN_SHANG_GONG)
  self._bToSignFeatureOpen = feature:CheckFeatureOpen(Feature.TYPE_GUAN_YIN_QIU_QIAN)
end
def.method().HidePanel = function(self)
  if self._bHasCreated then
    self:DestroyPanel()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_ShangGong" then
    self:OnGongOnBtnClick()
  elseif id == "Btn_QiuQian" then
    self:OnBeenSwampedBtnClick()
  elseif id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Tips" then
    local tipsID = constant.GuanYinConsts.TIPS_ID
    local content = require("Main.Common.TipsHelper").GetHoverTip(tipsID)
    require("GUI.CommonUITipsDlg").ShowCommonTip(content, {x = 0, y = 0})
  end
end
def.method().OnGongOnBtnClick = function(self)
  if not self._bGongOnFeatureOpen then
    Toast(textRes.Children.SongZiGuanYin[17])
    return
  end
  local actId = constant.GuanYinConsts.SHANGGONG_ACTIVITY_CFG_ID
  if not self:IsCanJoinActivity(actId, self._iMaxGongOnNum, textRes.Children.SongZiGuanYin[5]) then
    return
  end
  if self._DlgGongOn == nil then
    self._DlgGongOn = require("Main.Children.ui.GongOn").Instance()
    if self._DlgGongOn == nil then
      warn("Instance Dialog GongOn panel error!!")
      return
    end
  end
  warn("OnGongOnBtnClick")
  self._DlgGongOn:ToShow()
end
def.method().OnBeenSwampedBtnClick = function(self)
  if not self._bToSignFeatureOpen then
    Toast(textRes.Children.SongZiGuanYin[17])
    return
  end
  local signActID = constant.GuanYinConsts.QIUQIAN_ACTIVITY_CFG_ID
  if not self:IsCanJoinActivity(signActID, self._iMaxSignNum, textRes.Children.SongZiGuanYin[3]) then
    return
  end
  if self._DlgBeenSwamped == nil then
    self._DlgBeenSwamped = require("Main.Children.ui.BeenSwamped").Instance()
    if self._DlgBeenSwamped == nil then
      warn("Instance Dialog Sign panel error...")
      return
    end
  end
  self._DlgBeenSwamped:ToShow()
end
def.static("table").OnAttenGongOnFailed = function(p)
  if p.res == nil then
    warn(">>>>Pare OnAttenGongOnFailed p.res == nil<<<<")
    return nil
  end
  local self = SongZiGuanYin.Instance()
  local SAttendGuanYinShangGongFail = require("netio.protocol.mzm.gsp.children.SAttendGuanYinShangGongFail")
  if p.res == SAttendGuanYinShangGongFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == SAttendGuanYinShangGongFail.ROLE_STATUS_ERROR then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == SAttendGuanYinShangGongFail.HAVE_NO_HOMELAND then
    Toast(textRes.Children.SongZiGuanYin[14])
  elseif p.res == SAttendGuanYinShangGongFail.BREED_STATE_ERROR then
    warn(">>>>BREED_STATE_ERROR<<<<")
  elseif p.res == SAttendGuanYinShangGongFail.CHILD_NUM_TO_UPPER_LIMIT then
    Toast(textRes.Children.SongZiGuanYin[15])
  elseif p.res == SAttendGuanYinShangGongFail.POINT_TO_UPPER_LIMIT then
    Toast(textRes.Children.SongZiGuanYin[16])
  elseif p.res == SAttendGuanYinShangGongFail.CHECK_NPC_SERVICE_ERROR then
    warn(">>>>CHECK_NPC_SERVICE_ERROR<<<<")
  elseif p.res == SAttendGuanYinShangGongFail.CAN_NOT_JOIN_ACTIVITY then
    local actId = constant.GuanYinConsts.SHANGGONG_ACTIVITY_CFG_ID
    self:IsCanJoinActivity(actId, self._iMaxGongOnNum, textRes.Children.SongZiGuanYin[5])
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == SAttendGuanYinShangGongFail.START_SHANG_GONG_FAIL then
    warn(">>>>START_SHANG_GONG_FAIL<<<<")
  end
end
def.static("table").OnAttenQiuQianFailed = function(p)
  if p.res == nil then
    Toast(textRes.Children.SongZiGuanYin[14])
    return nil
  end
  local SAttendGuanYinQiuQianFail = require("netio.protocol.mzm.gsp.children.SAttendGuanYinQiuQianFail")
  if p.res == SAttendGuanYinQiuQianFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == SAttendGuanYinQiuQianFail.ROLE_STATUS_ERROR then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == SAttendGuanYinQiuQianFail.CHECK_NPC_SERVICE_ERROR then
    warn(">>>>CHECK_NPC_SERVICE_ERROR<<<<")
  elseif p.res == SAttendGuanYinQiuQianFail.HAVE_NO_HOMELAND then
    Toast(textRes.Children.SongZiGuanYin[14])
  elseif p.res == SAttendGuanYinQiuQianFail.BREED_STATE_ERROR then
    warn(">>>>BREED_STATE_ERROR<<<<")
  elseif p.res == SAttendGuanYinQiuQianFail.CHILD_NUM_TO_UPPER_LIMIT then
    Toast(textRes.Children.SongZiGuanYin[15])
  elseif p.res == SAttendGuanYinQiuQianFail.POINT_TO_UPPER_LIMIT then
    Toast(textRes.Children.SongZiGuanYin[16])
  elseif p.res == SAttendGuanYinQiuQianFail.CAN_NOT_JOIN_ACTIVITY then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == SAttendGuanYinQiuQianFail.START_QIU_QIAN_FAIL then
    warn(">>>>START_QIU_QIAN_FAIL<<<<")
  end
end
def.static("table", "table").OnGetBabyPhaseChanged = function(param, context)
  local self = SongZiGuanYin.Instance()
  self:UpdateIntegralUI()
end
def.static("table", "table").OnGetBaby = function(param, context)
  local self = SongZiGuanYin.Instance()
  self:HidePanel()
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.GongOnGetBaby, {})
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.ToSignGetBaby, {})
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if p.feature == Feature.TYPE_GUAN_YIN_QIU_QIAN then
    if p.open then
      activityInterface:removeCustomCloseActivity(constant.GuanYinConsts.QIUQIAN_ACTIVITY_CFG_ID)
    else
      activityInterface:addCustomCloseActivity(constant.GuanYinConsts.QIUQIAN_ACTIVITY_CFG_ID)
    end
  elseif p.feature == Feature.TYPE_GUAN_YIN_SHANG_GONG then
    if p.open then
      activityInterface:removeCustomCloseActivity(constant.GuanYinConsts.SHANGGONG_ACTIVITY_CFG_ID)
    else
      activityInterface:addCustomCloseActivity(constant.GuanYinConsts.SHANGGONG_ACTIVITY_CFG_ID)
    end
  end
  local self = SongZiGuanYin.Instance()
  self:UpdateIDIPFeature()
end
return SongZiGuanYin.Commit()
