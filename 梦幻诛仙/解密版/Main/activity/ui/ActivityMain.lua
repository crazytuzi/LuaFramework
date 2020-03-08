local Lplus = require("Lplus")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local ActivityMain = Lplus.Extend(ECPanelBase, "ActivityMain")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ActivityType = require("consts.mzm.gsp.activity.confbean.ActivityType")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GUIUtils = require("GUI.GUIUtils")
local DailyGoalNode = require("Main.Grow.ui.DailyGoalNode")
local DailyGoalMgr = require("Main.Grow.DailyGoalMgr")
local def = ActivityMain.define
local instance
def.const("table").ProductType = {
  ALL = "Img_Toggle5",
  EXP = "Img_Toggle1",
  MONEY = "Img_Toggle2",
  ITEM = "Img_Toggle3",
  TRAIN_EXP = "Img_Toggle4"
}
def.const("table").ActivityType = {
  DAILY = 1,
  LIMIT_TIME = 2,
  COME_SOON = 3,
  FESTIVAL = 4
}
def.static("=>", ActivityMain).Instance = function()
  if instance == nil then
    instance = ActivityMain()
    instance:Init()
  end
  return instance
end
def.field("number")._timerID = -1
def.field("number")._tapIndex = 1
def.field("table")._awardItems = nil
def.field("number")._targetActivityID = 0
def.field("boolean")._targetTip = false
def.field("boolean")._AllEnabledWithLightRound = false
def.field("table")._names = nil
def.field("table")._masks = nil
def.field("number")._currMask = 0
def.field("number")._currProductionSelected = 1
def.field("table")._currList = nil
def.field("table")._activeAwardLightRound = nil
def.field("boolean").isshowing = false
def.field("table")._activityCompleteCustomCondition = nil
def.field("table")._uiObjs = nil
def.field("boolean").isNeedRefreshList = false
def.field("table").forceToActivityType = nil
def.method().Init = function(self)
  self.m_TrigGC = true
  self.m_TryIncLoadSpeed = true
  self._names = {
    textRes.activity[290],
    textRes.activity[291],
    textRes.activity[292],
    textRes.activity[293],
    textRes.activity[294],
    textRes.activity[295],
    textRes.activity[296]
  }
  self._masks = {
    4294967295,
    1,
    2,
    4,
    8,
    1024
  }
  self._currMask = self._masks[self._currProductionSelected]
  self._activeAwardLightRound = {}
  self._activityCompleteCustomCondition = {}
  self._activityCompleteCustomCondition[constant.HuSongConsts.CONVOY_ACTIVITY_ID] = ActivityMain.ActivityConvoyCompleteCustom
  self._activityCompleteCustomCondition[constant.SchoolChallengeCfgConsts.ACTIVITYID] = ActivityMain.ActivitySchoolChallengeCompleteCustom
  local SOLODUNGEONACT_ACTIVITYID = require("Main.Dungeon.DungeonUtils").GetDungeonConst().SoloDungeonActivityId
  self._activityCompleteCustomCondition[SOLODUNGEONACT_ACTIVITYID] = ActivityMain.ActivitySoloDungeonCompleteCustom
  local allDeliveryActivity = require("Main.DeliveryGame.DeliveryGameUtils").GetAllDeliveryActivity()
  for k, v in ipairs(allDeliveryActivity) do
    self._activityCompleteCustomCondition[v] = function(...)
      return false
    end
  end
end
def.static("table", "table", "boolean", "=>", "boolean").ActivityConvoyCompleteCustom = function(activityInfo, activityCfg, oriComplete)
  local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
  local specialCount = 0
  if activityInterface._husongMap ~= nil then
    specialCount = activityInterface._husongMap[HuSongType.SPECIAL] or 0
  end
  return oriComplete and specialCount >= constant.HuSongConsts.CONVOY_SPECIALNUM
end
def.static("table", "table", "boolean", "=>", "boolean").ActivitySoloDungeonCompleteCustom = function(activityInfo, activityCfg, oriComplete)
  return require("Main.Dungeon.DungeonModule").Instance():IsSingleDungeonAllFinish()
end
def.static("table", "table", "boolean", "=>", "boolean").ActivitySchoolChallengeCompleteCustom = function(activityInfo, activityCfg, oriComplete)
  if activityInfo ~= nil then
    return activityInfo.count >= constant.SchoolChallengeCfgConsts.CAN_ATTEND_NUM
  end
  return false
end
def.static("table", "table").OnActivityListChanged = function(p1, p2)
  if instance:IsShow() then
    instance:_FillList()
  end
  instance:UpdateDailyTabNotify()
  instance:UpdateTimeLimitTabNotify()
  instance:UpdateFestivalTabNotify()
end
def.static("table", "table").OnActivityInfoChanged = function(p1, p2)
  local activityID = p1[1]
  if instance:IsShow() == true and activityID ~= 0 then
    instance:_FillItem(activityID)
  end
end
def.static("table", "table").OnHeroEnergyChanged = function(p1, p2)
  if instance:IsShow() then
    instance:_FillActive()
  end
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  instance:UpdateDayTargetVisible()
end
def.static("table", "table").OnDailyGoalNotifyUpdate = function(p1, p2)
  instance:UpdateDayTargetTabNotify()
end
def.static("table", "table").OnActivityStart = function(activityIDs, p2)
  local self = instance
  self:ActivityStart(activityIDs)
end
def.static("table", "table").OnActivityEnd = function(activityIDs, p2)
  local self = instance
  self:ActivityEnd(activityIDs)
end
def.static("table", "table").OnActiveChanged = function(p1, p2)
  local self = instance
  if self:IsShow() == true then
    self:_FillListItems()
    self:_FillActive()
  end
end
def.static("table", "table").OnSpecialActiveChanged = function(p1, p2)
  local self = instance
  if self:IsShow() then
    self:_FillList()
  end
end
def.static("table", "table").OnActivityListReset = function(p1, p2)
  local self = instance
  if self:IsShow() then
    if not self.isNeedRefreshList then
      GameUtil.AddGlobalTimer(2, true, function()
        if self.m_panel then
          self:_FillList()
          self.isNeedRefreshList = false
        end
      end)
    end
    self.isNeedRefreshList = true
  end
end
def.static("table", "table").OnExchangeInfoChange = function()
  if instance then
    instance:setExchangeDisplay()
  end
end
def.static("table", "table").OnSetActivityRedPoint = function()
  if instance then
    instance:_FillList()
    instance:UpdateDailyTabNotify()
    instance:UpdateTimeLimitTabNotify()
    instance:UpdateFestivalTabNotify()
  end
end
def.static("table", "table").OnActiveAwardChged = function(p1, p2)
  local self = instance
  if self:IsShow() == true then
    self:_FillListItems()
    self:_FillActive()
  end
end
def.static()._OnTimer = function()
  instance._timerID = -1
  instance:_FillTime()
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    self.isshowing = true
    self.m_ChangeLayerOnShow = true
    self:CreatePanel(RESPATH.PREFAB_UI_ACTIVITY_MAIN, 1)
    self:SetModal(true)
  end
end
def.method("number", "string").ShowDlgToProductType = function(self, activityType, mark)
  warn("------ShowDlgToProductType:", mark)
  self.forceToActivityType = {activityType, mark}
  self:ShowDlg()
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.method()._FillTime = function(self)
  if self:IsShow() == true then
    local Label_Time = self.m_panel:FindDirect("Img_Bg0/TopInfo/Label_Time")
    local nowSec = GetServerTime()
    local curTimeTable = AbsoluteTimer.GetServerTimeTable(nowSec)
    local nowHour = curTimeTable.hour
    local nowMinite = curTimeTable.min
    local strTime = string.format("%02d:%02d", nowHour, nowMinite)
    Label_Time:GetComponent("UILabel"):set_text(strTime)
    if self._timerID < 0 then
      self._timerID = GameUtil.AddGlobalTimer(1, true, ActivityMain._OnTimer)
    end
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, ActivityMain.OnActivityListChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, ActivityMain.OnActivityInfoChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, ActivityMain.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, ActivityMain.OnActivityEnd)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, ActivityMain.OnActiveChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Award_Chged, ActivityMain.OnActiveAwardChged)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, ActivityMain.OnHeroEnergyChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Special_Activity_Change, ActivityMain.OnSpecialActiveChanged)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, ActivityMain.OnActivityListReset)
  Event.RegisterEvent(ModuleId.EXCHANGE, gmodule.notifyId.Exchange.EXCHANGE_RED_POINT_CHANGE, ActivityMain.OnExchangeInfoChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, ActivityMain.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Refresh_RedPoint, ActivityMain.OnSetActivityRedPoint)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, ActivityMain.OnDailyGoalNotifyUpdate)
  self._uiObjs = {}
  self._uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self._uiObjs.Img_Bg = self._uiObjs.Img_Bg0:FindDirect("Img_Bg")
  self._uiObjs.Group_RC = self._uiObjs.Img_Bg0:FindDirect("Group_RC")
  DailyGoalNode.Instance():Init(self, self._uiObjs.Group_RC)
  self:_ActivateActivityListGroup()
  local Grid = self.m_panel:FindDirect("Img_Bg0/Img_Bg/Scroll View/Grid")
  local listItem1 = Grid:FindDirect("Img_Bg01")
  listItem1:set_name("Img_Bg_01")
  listItem1:SetActive(false)
  local Btn_Join01 = listItem1:FindDirect("Btn_Join")
  Btn_Join01:set_name("Btn_Join_01")
  local Img_BgIcon = listItem1:FindDirect("Img_BgIcon")
  Img_BgIcon:set_name("Img_BgIcon_01")
  local TopInfo = self.m_panel:FindDirect("Img_Bg0/TopInfo")
  local Btn_Menu = TopInfo:FindDirect("Btn_Menu")
  local popList = Btn_Menu:GetComponent("UIPopupList")
  popList:set_items(self._names)
  popList:set_selectIndex(self._currProductionSelected - 1)
  popList:set_value(self._names[self._currProductionSelected])
  local Group_Options = self.m_panel:FindDirect("Img_Bg0/TopInfo/Group_Options")
  Group_Options:FindDirect("Label_All/Img_Toggle5/Img_Select"):SetActive(true)
  Group_Options:FindDirect("Label_Exp/Img_Toggle1/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Money/Img_Toggle2/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Item/Img_Toggle3/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_XiuLianExp/Img_Toggle4/Img_Select"):SetActive(false)
  self._currMask = self._masks[self._currProductionSelected]
  self._activeAwardLightRound = {}
  self:UpdateDayTargetVisible()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, ActivityMain.OnActivityListChanged)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, ActivityMain.OnActivityInfoChanged)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, ActivityMain.OnActivityStart)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_End, ActivityMain.OnActivityEnd)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, ActivityMain.OnActiveChanged)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Award_Chged, ActivityMain.OnActiveAwardChged)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_CHANGED, ActivityMain.OnHeroEnergyChanged)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Special_Activity_Change, ActivityMain.OnSpecialActiveChanged)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, ActivityMain.OnActivityListReset)
  Event.UnregisterEvent(ModuleId.EXCHANGE, gmodule.notifyId.Exchange.EXCHANGE_RED_POINT_CHANGE, ActivityMain.OnExchangeInfoChange)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, ActivityMain.OnHeroLevelUp)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Refresh_RedPoint, ActivityMain.OnSetActivityRedPoint)
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.DAILY_GOALS_NOTIFY_UPDATE, ActivityMain.OnDailyGoalNotifyUpdate)
  activityInterface._newActivitiesSet = {}
  activityInterface._newActivitiesVector = {}
  activityInterface._newLevelOpenActivitiesSet = {}
  activityInterface._newLevelOpenActivitiesVector = {}
  activityInterface._newTimeOpenActivitiesSet = {}
  activityInterface._newTimeOpenActivitiesVector = {}
  activityInterface._newFestivalActivitiesSet = {}
  activityInterface._newFestivalActivitiesVector = {}
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ClearNewFlag, nil)
  self._AllEnabledWithLightRound = false
  if self:_IsDailyGoalGroupActive() then
    DailyGoalNode.Instance():Hide()
  end
  if self:IsShow() == true then
    self:_Clear()
  end
  self._currProductionSelected = 1
  self._currMask = self._masks[self._currProductionSelected]
  self._currList = nil
  self._tapIndex = 1
  self._targetActivityID = 0
  self._targetTip = false
  self._uiObjs = nil
  self._AllEnabledWithLightRound = false
  self.isshowing = false
  self.isNeedRefreshList = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:setExchangeDisplay()
    if self.forceToActivityType and #self.forceToActivityType == 2 then
      self:_Tap_(self.forceToActivityType[1])
      self:onClick(self.forceToActivityType[2])
    else
      local count = #activityInterface._newActivitiesVector
      if count > 0 then
        local activityID = activityInterface._newActivitiesVector[count]
        local cfg = ActivityInterface.GetActivityCfgById(activityID)
        if cfg ~= nil then
          if cfg.activityDisType == ActivityType.Daily then
            local oldTapIndex = self._tapIndex
            self:_Tap_(1)
            self:_FillList()
          elseif cfg.activityDisType == ActivityType.TimeLimit then
            local oldTapIndex = self._tapIndex
            self:_Tap_(2)
            self:_FillList()
          elseif cfg.activityDisType == ActivityType.Holiday then
            local oldTapIndex = self._tapIndex
            self:_Tap_(4)
            self:_FillList()
          end
          local scrollView = self.m_panel:FindDirect("Img_Bg0/Img_Bg/Scroll View")
          local scrollCom = scrollView:GetComponent("UIScrollView")
          scrollCom:ResetPosition()
          for idx, cfg in pairs(self._currList) do
            if cfg.id == activityID then
              local Grid = scrollView:FindDirect("Grid")
              local listItem = Grid:FindDirect(string.format("Img_Bg_%02d", idx))
              scrollCom:DragToMakeVisible(listItem.transform, 128)
              break
            end
          end
        end
      elseif self._targetActivityID == 0 then
        self:_Tap_(1)
        self:_FillList()
      else
        local cfg = ActivityInterface.GetActivityCfgById(self._targetActivityID)
        if cfg ~= nil then
          if cfg.activityDisType == ActivityType.Daily then
            local oldTapIndex = self._tapIndex
            self:_Tap_(1)
            self:_FillList()
          elseif cfg.activityDisType == ActivityType.TimeLimit then
            local oldTapIndex = self._tapIndex
            self:_Tap_(2)
            self:_FillList()
          elseif cfg.activityDisType == ActivityType.Holiday then
            local oldTapIndex = self._tapIndex
            self:_Tap_(4)
            self:_FillList()
          end
          local scrollView = self.m_panel:FindDirect("Img_Bg0/Img_Bg/Scroll View")
          local scrollCom = scrollView:GetComponent("UIScrollView")
          scrollCom:ResetPosition()
          for idx, cfg in pairs(self._currList) do
            if cfg.id == self._targetActivityID then
              local Grid = scrollView:FindDirect("Grid")
              local listItem = Grid:FindDirect(string.format("Img_Bg_%02d", idx))
              scrollCom:DragToMakeVisible(listItem.transform, 128)
              self:_SetLightRoundOn(listItem, idx)
              if self._targetTip == true then
                GameUtil.AddGlobalTimer(0, true, function()
                  if self:IsShow() == true then
                    self:_ShowTip(idx)
                  end
                end)
                self._targetTip = false
              end
              break
            end
          end
        end
      end
    end
    local Btn_Menu = self.m_panel:FindDirect("Img_Bg0/TopInfo/Btn_Menu")
    Btn_Menu:FindDirect("Img_Down"):SetActive(true)
    Btn_Menu:FindDirect("Img_Up"):SetActive(false)
    self:_FillActive()
    self:UpdateDailyTabNotify()
    self:UpdateTimeLimitTabNotify()
    self:UpdateFestivalTabNotify()
  else
    if self:IsShow() == true then
      self:_Clear()
    end
    self.forceToActivityType = {}
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if self:_IsDailyGoalGroupActive() then
    if DailyGoalNode.Instance():onClickObjEx(obj) then
    else
      self:onClick(id)
    end
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  warn("** Begin ** ActivityMain.OnClick(", id, ")")
  local tfn = {}
  tfn.Btn_Close = ActivityMain.OnBtn_Close
  tfn.Btn_Weekly = ActivityMain.OnBtn_Weekly
  tfn.Btn_Qyzhi = ActivityMain.OnBtn_Qingyun
  tfn.Tap_Daily = ActivityMain.OnTap_Daily
  tfn.Tap_TimeLimit = ActivityMain.OnTap_TimeLimit
  tfn.Tap_ComeSoon = ActivityMain.OnTap_ComeSoon
  tfn.Tap_DayTarget = ActivityMain.OnTap_DailyGoal
  tfn.Tap_Holiday = ActivityMain.OnTap_Holiday
  tfn.Btn_Notice = ActivityMain.OnBtn_Notice
  tfn.Img_Toggle5 = ActivityMain.OnToggle_Filter_ALL
  tfn.Img_Toggle1 = ActivityMain.OnToggle_Filter_Exp
  tfn.Img_Toggle2 = ActivityMain.OnToggle_Filter_Money
  tfn.Img_Toggle3 = ActivityMain.OnToggle_Filter_Item
  tfn.Img_Toggle4 = ActivityMain.OnToggle_Filter_Xiulian
  local fn = tfn[id]
  if fn ~= nil then
    fn(self)
    return
  end
  local strs = string.split(id, "_")
  local index = tonumber(strs[3])
  if strs[1] == "Btn" and strs[2] == "Join" and index ~= nil then
    self:_OnJoin(index)
  elseif strs[1] == "Img" and strs[2] == "Bg" and index ~= nil then
    self:_ShowTip(index)
  elseif strs[1] == "Img" and strs[2] == "BgIcon" and index ~= nil then
    self:_ShowTip(index)
  elseif strs[1] == "Texture" and strs[2] == "item" and index ~= nil then
    self:_OnClickAwardItem(index)
  elseif id == "Btn_Exchange" then
    require("Main.Exchange.ui.ExchangePanel").Instance():ShowPanel()
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  warn("** Begin ** ActivityMain.onToggle(", id, active, ")")
  warn("** End   ** ActivityMain.onToggle(", id, active, ")")
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  if id == "Btn_Menu" then
    local Btn_Menu = self.m_panel:FindDirect("Img_Bg0/TopInfo/Btn_Menu")
    Btn_Menu:FindDirect("Img_Down"):SetActive(true)
    Btn_Menu:FindDirect("Img_Up"):SetActive(false)
    if index < 0 then
      index = 0
      return
    end
    self._currProductionSelected = index + 1
    self._currMask = self._masks[self._currProductionSelected]
    self:_FillList()
  end
end
def.static(ActivityMain).OnBtn_Close = function(self)
  self:HideDlg()
end
def.static(ActivityMain).OnTap_Daily = function(self)
  self:_ActivateActivityListGroup()
  self:_Tap_Daily()
  self:_FillList()
end
def.static(ActivityMain).OnTap_TimeLimit = function(self)
  self:_ActivateActivityListGroup()
  self:_Tap_TimeLimit()
  self:_FillList()
end
def.static(ActivityMain).OnTap_ComeSoon = function(self)
  self:_ActivateActivityListGroup()
  self:_Tap_ComeSoon()
  self:_FillList()
end
def.static(ActivityMain).OnTap_DailyGoal = function(self)
  self:_ActivateDailyGoalGroup()
  self:_Tap_DailyGoal()
end
def.static(ActivityMain).OnTap_Holiday = function(self)
  self:_ActivateActivityListGroup()
  self:_Tap_Holiday()
  self:_FillList()
end
def.method()._Tap_Daily = function(self)
  self:_Tap_(1)
end
def.method()._Tap_TimeLimit = function(self)
  self:_Tap_(2)
end
def.method()._Tap_ComeSoon = function(self)
  self:_Tap_(3)
end
def.method()._Tap_Holiday = function(self)
  self:_Tap_(4)
end
def.method()._Tap_DailyGoal = function(self)
  self:_Tap_(5)
end
def.method().OnBtn_Weekly = function(self)
  require("Main.activity.ui.ActivityWeekly").Instance():ShowDlg()
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.REMINDORCALENDAR, {2})
end
def.method().OnBtn_Notice = function(self)
  require("Main.RelationShipChain.RelationShipChainMgr").GetCareActivityList({})
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.REMINDORCALENDAR, {1})
end
def.static(ActivityMain).OnBtn_Qingyun = function(self)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_QY_ZHI_CLICK, nil)
end
def.static(ActivityMain).OnActiveTips = function(self)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active, nil)
end
def.static(ActivityMain).OnToggle_Filter_ALL = function(self)
  local Group_Options = self.m_panel:FindDirect("Img_Bg0/TopInfo/Group_Options")
  Group_Options:FindDirect("Label_All/Img_Toggle5/Img_Select"):SetActive(true)
  Group_Options:FindDirect("Label_Exp/Img_Toggle1/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Money/Img_Toggle2/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Item/Img_Toggle3/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_XiuLianExp/Img_Toggle4/Img_Select"):SetActive(false)
  self._currProductionSelected = 1
  self._currMask = self._masks[self._currProductionSelected]
  self:_FillList()
end
def.static(ActivityMain).OnToggle_Filter_Exp = function(self)
  local Group_Options = self.m_panel:FindDirect("Img_Bg0/TopInfo/Group_Options")
  Group_Options:FindDirect("Label_All/Img_Toggle5/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Exp/Img_Toggle1/Img_Select"):SetActive(true)
  Group_Options:FindDirect("Label_Money/Img_Toggle2/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Item/Img_Toggle3/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_XiuLianExp/Img_Toggle4/Img_Select"):SetActive(false)
  self._currProductionSelected = 2
  self._currMask = self._masks[self._currProductionSelected]
  self:_FillList()
end
def.static(ActivityMain).OnToggle_Filter_Money = function(self)
  local Group_Options = self.m_panel:FindDirect("Img_Bg0/TopInfo/Group_Options")
  Group_Options:FindDirect("Label_All/Img_Toggle5/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Exp/Img_Toggle1/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Money/Img_Toggle2/Img_Select"):SetActive(true)
  Group_Options:FindDirect("Label_Item/Img_Toggle3/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_XiuLianExp/Img_Toggle4/Img_Select"):SetActive(false)
  self._currProductionSelected = 3
  self._currMask = self._masks[self._currProductionSelected]
  self:_FillList()
end
def.static(ActivityMain).OnToggle_Filter_Item = function(self)
  local Group_Options = self.m_panel:FindDirect("Img_Bg0/TopInfo/Group_Options")
  Group_Options:FindDirect("Label_All/Img_Toggle5/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Exp/Img_Toggle1/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Money/Img_Toggle2/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Item/Img_Toggle3/Img_Select"):SetActive(true)
  Group_Options:FindDirect("Label_XiuLianExp/Img_Toggle4/Img_Select"):SetActive(false)
  self._currProductionSelected = 4
  self._currMask = self._masks[self._currProductionSelected]
  self:_FillList()
end
def.static(ActivityMain).OnToggle_Filter_Xiulian = function(self)
  local Group_Options = self.m_panel:FindDirect("Img_Bg0/TopInfo/Group_Options")
  Group_Options:FindDirect("Label_All/Img_Toggle5/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Exp/Img_Toggle1/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Money/Img_Toggle2/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_Item/Img_Toggle3/Img_Select"):SetActive(false)
  Group_Options:FindDirect("Label_XiuLianExp/Img_Toggle4/Img_Select"):SetActive(true)
  self._currProductionSelected = 5
  self._currMask = self._masks[self._currProductionSelected]
  self:_FillList()
end
def.method()._ActivateActivityListGroup = function(self)
  local lastDailyGoalActive = self:_IsDailyGoalGroupActive()
  GUIUtils.SetActive(self._uiObjs.Img_Bg, true)
  GUIUtils.SetActive(self._uiObjs.Group_RC, false)
  if lastDailyGoalActive then
    DailyGoalNode.Instance():Hide()
  end
end
def.method()._ActivateDailyGoalGroup = function(self)
  local lastDailyGoalActive = self:_IsDailyGoalGroupActive()
  GUIUtils.SetActive(self._uiObjs.Img_Bg, false)
  GUIUtils.SetActive(self._uiObjs.Group_RC, true)
  if not lastDailyGoalActive then
    DailyGoalNode.Instance():Show()
  end
end
def.method("=>", "boolean")._IsDailyGoalGroupActive = function(self)
  if self._uiObjs.Group_RC == nil then
    return false
  end
  return self._uiObjs.Group_RC.activeInHierarchy
end
def.method("number")._Tap_ = function(self, index)
  self._tapIndex = index
  local Tap_Daily = self.m_panel:FindDirect("Img_Bg0/Tap_Daily")
  local Img_TapDailySelect = Tap_Daily:FindDirect("Img_TapDailySelect")
  local Label_TapDaily = Tap_Daily:FindDirect("Label_TapDaily")
  local Label_TapDailySelect = Tap_Daily:FindDirect("Label_TapDailySelect")
  Label_TapDaily:SetActive(index ~= 1)
  Label_TapDailySelect:SetActive(index == 1)
  Img_TapDailySelect:SetActive(index == 1)
  local Tap_TimeLimit = self.m_panel:FindDirect("Img_Bg0/Tap_TimeLimit")
  local Img_TapTimeLimitSelect = Tap_TimeLimit:FindDirect("Img_TapTimeLimitSelect")
  local Label_TapTime = Tap_TimeLimit:FindDirect("Label_TapTime")
  local Label_TapTimeSelect = Tap_TimeLimit:FindDirect("Label_TapTimeSelect")
  Label_TapTime:SetActive(index ~= 2)
  Label_TapTimeSelect:SetActive(index == 2)
  Img_TapTimeLimitSelect:SetActive(index == 2)
  local Tap_ComeSoon = self.m_panel:FindDirect("Img_Bg0/Tap_ComeSoon")
  local Img_TSelect = Tap_ComeSoon:FindDirect("Img_TSelect")
  local Label_Time = Tap_ComeSoon:FindDirect("Label_Time")
  local Label_Select = Tap_ComeSoon:FindDirect("Label_Select")
  Label_Time:SetActive(index ~= 3)
  Label_Select:SetActive(index == 3)
  Img_TSelect:SetActive(index == 3)
  local Tap_Holiday = self.m_panel:FindDirect("Img_Bg0/Tap_Holiday")
  local Img_Select = Tap_Holiday:FindDirect("Img_Select")
  local Label_Holiday = Tap_Holiday:FindDirect("Label_Holiday")
  local Label_Select = Tap_Holiday:FindDirect("Label_Select")
  Label_Holiday:SetActive(index ~= 4)
  Label_Select:SetActive(index == 4)
  Img_Select:SetActive(index == 4)
  local Tap_DayTarget = self.m_panel:FindDirect("Img_Bg0/Tap_DayTarget")
  local Img_TSelect = Tap_DayTarget:FindDirect("Img_TSelect")
  Img_TSelect:SetActive(index == 5)
end
def.method()._FillActive = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local ItemUtils = require("Main.Item.ItemUtils")
  self._awardItems = {}
  local Group_Slider = self.m_panel:FindDirect("Img_Bg0/Group_Slider")
  local Group_Items = Group_Slider:FindDirect("Group_Items")
  local Group_Values = Group_Slider:FindDirect("Group_Values")
  local Img_BgSlider = Group_Slider:FindDirect("Img_BgSlider")
  local Label = Img_BgSlider:FindDirect("Group_Thumb/Label")
  local theMaxActiviteValue = 0
  local awardCfg = ActivityInterface.GetActiveAwardCfg()
  if awardCfg == nil then
    warn("-------Award------nil")
    return
  end
  for i = 1, #awardCfg do
    local j = i - 1
    local awardItem = Group_Items:FindDirect(string.format("item_%d", i))
    if awardItem == nil then
      warn("!!!!!!!!!!!active award is nil:", i)
      break
    end
    local Texture_item = awardItem:FindDirect(string.format("Texture_item_%d", i, i))
    local Label_Count = awardItem:FindDirect("Label_Count")
    local Img_Finished = awardItem:FindDirect("Img_Finished")
    local Text_item = Group_Values:FindDirect(string.format("item_%d", i))
    local cfg = awardCfg[i]
    if cfg then
      Texture_item:SetActive(true)
      Text_item:SetActive(true)
      Label_Count:SetActive(true)
      local uiTexture = Texture_item:GetComponent("UITexture")
      table.insert(self._awardItems, cfg)
      local itembase = ItemUtils.GetItemBase(cfg.awardItemid)
      GUIUtils.FillIcon(uiTexture, itembase.icon)
      Text_item:GetComponent("UILabel"):set_text(string.format(textRes.activity[285], cfg.activiteValue))
      Label_Count:GetComponent("UILabel"):set_text(tostring(cfg.awardItemidCount))
      if theMaxActiviteValue < cfg.activiteValue then
        theMaxActiviteValue = cfg.activiteValue
      end
      if activityInterface._currentTotalActive >= cfg.activiteValue then
        local awared = activityInterface:GetActiveAwared(cfg.awardIndex)
        if awared == false then
          if self._activeAwardLightRound[i] ~= true then
            GUIUtils.SetLightEffect(awardItem, GUIUtils.Light.Square)
            self._activeAwardLightRound[i] = true
          end
        else
          GUIUtils.SetLightEffect(awardItem, GUIUtils.Light.None)
          self._activeAwardLightRound[i] = false
        end
        Img_Finished:SetActive(awared == true)
      else
        Img_Finished:SetActive(false)
        GUIUtils.SetLightEffect(awardItem, GUIUtils.Light.None)
        self._activeAwardLightRound[i] = false
      end
    else
      Texture_item:SetActive(false)
      Text_item:SetActive(false)
      Img_Finished:SetActive(false)
      Label_Count:SetActive(false)
      GUIUtils.SetLightEffect(awardItem, GUIUtils.Light.None)
    end
  end
  local value = activityInterface._currentTotalActive / theMaxActiviteValue
  Img_BgSlider:GetComponent("UIProgressBar").value = math.min(1, value)
  local dispValue = math.min(activityInterface._currentTotalActive, theMaxActiviteValue)
  Label:GetComponent("UILabel"):set_text(tostring(dispValue))
  local Label_CurActNum = Group_Slider:FindDirect("Group_CurAct/Label_CurActNum")
  if Label_CurActNum then
    Label_CurActNum:GetComponent("UILabel"):set_text(activityInterface._currentTotalActive)
  end
end
def.method()._FilterList = function(self)
  local lists = {}
  lists[1] = activityInterface:GetDailyActivityList()
  lists[2] = activityInterface:GetWeeklyActivityList()
  lists[3] = activityInterface:GetComingSoonActivityList()
  lists[4] = activityInterface:GetFestivalActivityList()
  local list = lists[self._tapIndex]
  self._currList = {}
  if self._currMask == nil then
    self._currMask = 0
  end
  warn("++++++++++++currMask:", self._currMask)
  for idx, cfg in pairs(list) do
    local result = bit.band(cfg.product, self._currMask)
    if cfg.product == 0 or result ~= 0 then
      table.insert(self._currList, cfg)
    end
  end
end
def.method()._FillList = function(self)
  if self:_IsDailyGoalGroupActive() then
    return
  end
  local scrollView = self.m_panel:FindDirect("Img_Bg0/Img_Bg/Scroll View")
  scrollView:GetComponent("UIScrollView"):ResetPosition()
  self:_Clear()
  self:_FilterList()
  self:_FillListItems()
end
def.method()._FillListItems = function(self)
  if self._tapIndex ~= 3 then
    local function sortFn(l, r)
      local lsortValue = l.activitySort
      local rsortValue = r.activitySort
      local lactivityInfo = activityInterface:GetActivityInfo(l.id)
      if lactivityInfo ~= nil then
        local count = lactivityInfo.count
        local recommendCount = l.recommendCount
        local isSpecialRecommendNum, num = activityInterface:isSpecialRecommendNum(l.id)
        if isSpecialRecommendNum then
          recommendCount = num
        end
        if self:IsSpecialActiviy(l.id) then
          count, recommendCount = self:GetSpecialActiviyInfo(l.id)
        end
        local bComplete = recommendCount > 0 and count >= recommendCount
        local additional = self._activityCompleteCustomCondition[l.id]
        if additional ~= nil then
          bComplete = additional(lactivityInfo, l, bComplete)
        end
        if bComplete then
          lsortValue = 10000 + lsortValue
        end
      end
      local ractivityInfo = activityInterface:GetActivityInfo(r.id)
      if ractivityInfo ~= nil then
        local count = ractivityInfo.count
        local recommendCount = r.recommendCount
        local isSpecialRecommendNum, num = activityInterface:isSpecialRecommendNum(r.id)
        if isSpecialRecommendNum then
          recommendCount = num
        end
        if self:IsSpecialActiviy(r.id) then
          count, recommendCount = self:GetSpecialActiviyInfo(r.id)
        end
        local bComplete = recommendCount > 0 and count >= recommendCount
        local additional = self._activityCompleteCustomCondition[r.id]
        if additional ~= nil then
          bComplete = additional(ractivityInfo, l, bComplete)
        end
        if bComplete then
          rsortValue = 10000 + rsortValue
        end
      end
      return lsortValue < rsortValue
    end
    table.sort(self._currList, sortFn)
  end
  for idx, cfg in pairs(self._currList) do
    self:_AddItem(idx, cfg)
  end
  local Group_NoActivity = self.m_panel:FindDirect("Img_Bg0/Img_Bg/Group_NoActivity")
  Group_NoActivity:SetActive(#self._currList == 0)
end
def.method()._Clear = function(self)
  local Grid = self.m_panel:FindDirect("Img_Bg0/Img_Bg/Scroll View/Grid")
  local count = Grid:get_childCount()
  for index = 1, count do
    local listItem = Grid:FindDirect(string.format("Img_Bg_%02d", index))
    listItem:SetActive(false)
    self:_SetLightRoundOff(listItem, index)
  end
end
def.method("userdata", "number")._SetLightRoundOn = function(self, listItem, index)
  local UI_FX = listItem:FindDirect("UI_FX")
  if UI_FX ~= nil then
    UI_FX:SetActive(true)
    local uiParticle = UI_FX:GetComponent("UIParticle")
    uiParticle:SetCliping(true)
  end
end
def.method("userdata", "number")._SetLightRoundOff = function(self, listItem, index)
  local UI_FX = listItem:FindDirect("UI_FX")
  if UI_FX ~= nil then
    UI_FX:SetActive(false)
  end
end
def.method("number", "table")._AddItem = function(self, index, cfg)
  local scrollView = self.m_panel:FindDirect("Img_Bg0/Img_Bg/Scroll View")
  local Grid = scrollView:FindDirect("Grid")
  local listItem1 = Grid:FindDirect("Img_Bg_01")
  local listItem = Grid:FindDirect(string.format("Img_Bg_%02d", index))
  local grid = Grid:GetComponent("UIGrid")
  if listItem ~= nil then
    listItem:SetActive(true)
  else
    local newListItem = Object.Instantiate(listItem1)
    listItem = newListItem
    grid:AddChild(newListItem.transform)
    listItem:set_name(string.format("Img_Bg_%02d", index))
    listItem.parent = listItem1.parent
    listItem:set_localScale(Vector.Vector3.one)
    local Btn_Join = listItem:FindDirect("Btn_Join_01")
    Btn_Join:set_name(string.format("Btn_Join_%02d", index))
    local Img_BgIcon = listItem:FindDirect("Img_BgIcon_01")
    Img_BgIcon:set_name(string.format("Img_BgIcon_%02d", index))
    grid:Reposition()
    self:TouchGameObject(self.m_panel, self.m_parent)
  end
  local Img_BgIcon = listItem:FindDirect(string.format("Img_BgIcon_%02d", index))
  local uiTexture = Img_BgIcon:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, cfg.activityIcon)
  local Label_Name = listItem:FindDirect("Label_Name")
  Label_Name:GetComponent("UILabel"):set_text(cfg.activityName)
  local bComplete = false
  local Label_1 = listItem:FindDirect("Label_1")
  local Label_Num = listItem:FindDirect("Label_Num")
  local activityInfo = activityInterface:GetActivityInfo(cfg.id)
  local recommendCount = cfg.recommendCount
  local isSpecialRecommendNum, num = activityInterface:isSpecialRecommendNum(cfg.id)
  if isSpecialRecommendNum then
    recommendCount = num
  end
  if recommendCount > 0 then
    Label_1:SetActive(true)
    Label_Num:SetActive(true)
    local count = 0
    if activityInfo ~= nil then
      bComplete = recommendCount <= activityInfo.count
      count = math.min(activityInfo.count, recommendCount)
      if self:IsSpecialActiviy(cfg.id) then
        count, recommendCount = self:GetSpecialActiviyInfo(cfg.id)
        bComplete = count >= recommendCount
      end
    end
    Label_Num:GetComponent("UILabel"):set_text(count .. "/" .. recommendCount)
  elseif recommendCount == 0 then
    Label_1:SetActive(true)
    Label_Num:SetActive(true)
    Label_Num:GetComponent("UILabel"):set_text(textRes.activity[60])
  else
    Label_1:SetActive(false)
    Label_Num:SetActive(false)
  end
  local additional = self._activityCompleteCustomCondition[cfg.id]
  if additional ~= nil then
    bComplete = additional(activityInfo, cfg, bComplete)
  end
  local Img_Sign = listItem:FindDirect("Img_Sign")
  local Img_New = listItem:FindDirect("Img_New")
  self:_SetLightRoundOff(listItem, index)
  if activityInterface._newLevelOpenActivitiesSet[cfg.id] ~= nil then
    self:_SetLightRoundOn(listItem, index)
  else
    self:_SetLightRoundOff(listItem, index)
  end
  if activityInterface._newTimeOpenActivitiesSet[cfg.id] ~= nil or activityInterface._newFestivalActivitiesSet[cfg.id] ~= nil or activityInterface.activityRedPoint[cfg.id] then
    Img_New:SetActive(true)
  else
    Img_New:SetActive(false)
  end
  if cfg.jiaoBiaoId ~= 0 then
    Img_Sign:SetActive(true)
    local uiTexture = Img_Sign:GetComponent("UITexture")
    GUIUtils.FillIcon(uiTexture, cfg.jiaoBiaoId)
  else
    Img_Sign:SetActive(false)
  end
  local Label_Time = listItem:FindDirect("Label_Time")
  local Btn_Join = listItem:FindDirect(string.format("Btn_Join_%02d", index))
  Label_Time:SetActive(false)
  local Label_2 = listItem:FindDirect("Label_2")
  local Label_ActiveNum = listItem:FindDirect("Label_ActiveNum")
  Label_2:SetActive(false)
  Label_ActiveNum:SetActive(false)
  if activityInterface._importantActivitiesSet[cfg.id] ~= nil or self._targetActivityID == cfg.id then
    self:_SetLightRoundOn(listItem, index)
  end
  local wordTip = cfg.wordTip
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.level < cfg.levelMin then
    wordTip = string.format(textRes.activity[162], cfg.levelMin)
  elseif heroProp.level > cfg.levelMax then
    wordTip = string.format(textRes.activity[163], cfg.levelMax)
  end
  while true do
    if wordTip ~= "" then
      break
    end
    local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
    local nowSec = GetServerTime()
    local inPeriod = cfg.activityType == ActivityType.Daily
    if inPeriod == false then
      inPeriod = activityInterface._activityInPeriod[cfg.id] ~= nil
    end
    local isInDate = true
    local timeLimitCommonCfg = TimeCfgUtils.GetTimeLimitCommonCfg(cfg.activityLimitTimeid)
    if timeLimitCommonCfg ~= nil then
      local beginTime = TimeCfgUtils.GetTimeSec(timeLimitCommonCfg.startYear, timeLimitCommonCfg.startMonth, timeLimitCommonCfg.startDay, timeLimitCommonCfg.startHour, timeLimitCommonCfg.startMinute, 0)
      local endTime = TimeCfgUtils.GetTimeSec(timeLimitCommonCfg.endYear, timeLimitCommonCfg.endMonth, timeLimitCommonCfg.endDay, timeLimitCommonCfg.endHour, timeLimitCommonCfg.endMinute, 0)
      isInDate = nowSec >= beginTime and nowSec <= endTime
    end
    if isInDate == true and inPeriod == false then
      local isToday = false
      local hasBeenToday = false
      local curTimeTable = AbsoluteTimer.GetServerTimeTable(nowSec)
      local nowDayWeek = curTimeTable.wday
      local recentDayWeek = 8
      local recentDayWeek2 = 0
      local isRecentDayWeek = false
      local isRecentDayWeek2 = false
      local nowYear = curTimeTable.year
      local nowMonth = curTimeTable.month
      local nowDay = curTimeTable.day
      local oneDayFirst = true
      for idx, timeDurationCommonCfg in pairs(cfg.activityTimeCfgs) do
        local start = false
        local stop = true
        local beginHour = timeDurationCommonCfg.timeCommonCfg.activeHour
        local beginMinute = timeDurationCommonCfg.timeCommonCfg.activeMinute
        if timeDurationCommonCfg.timeCommonCfg.activeWeekDay ~= 0 then
          isToday = nowDayWeek == timeDurationCommonCfg.timeCommonCfg.activeWeekDay
          inPeriod = isToday
          if isToday == true then
            local beginHour = timeDurationCommonCfg.timeCommonCfg.activeHour
            local beginMinute = timeDurationCommonCfg.timeCommonCfg.activeMinute
            local beginTime = TimeCfgUtils.GetTimeSec(nowYear, nowMonth, nowDay, beginHour, beginMinute, 0)
            local durationSec = timeDurationCommonCfg.lastDay * 86400 + timeDurationCommonCfg.lastHour * 3600 + timeDurationCommonCfg.lastMinute * 60
            local endTime = beginTime + durationSec
            start = nowSec >= beginTime
            if start == false then
              if oneDayFirst == true and cfg.recommendCount > 0 then
                Label_Num:GetComponent("UILabel"):set_text("0/" .. cfg.recommendCount)
              end
              bComplete = false
            elseif bComplete == true then
              break
            end
            oneDayFirst = false
            stop = nowSec > endTime
            inPeriod = start == true and stop == false
            isRecentDayWeek = false
            isRecentDayWeek2 = false
          else
            if (nowDayWeek < timeDurationCommonCfg.timeCommonCfg.activeWeekDay or nowDayWeek == 7) and recentDayWeek > timeDurationCommonCfg.timeCommonCfg.activeWeekDay then
              recentDayWeek = timeDurationCommonCfg.timeCommonCfg.activeWeekDay
              isRecentDayWeek = true
            end
            if nowDayWeek > timeDurationCommonCfg.timeCommonCfg.activeWeekDay and recentDayWeek2 < timeDurationCommonCfg.timeCommonCfg.activeWeekDay then
              recentDayWeek2 = timeDurationCommonCfg.timeCommonCfg.activeWeekDay
              isRecentDayWeek2 = true
            end
          end
        else
          isToday = true
          local beginTime = TimeCfgUtils.GetTimeSec(nowYear, nowMonth, nowDay, beginHour, beginMinute, 0)
          local duration = timeDurationCommonCfg.lastDay * 86400 + timeDurationCommonCfg.lastHour * 3600 + timeDurationCommonCfg.lastMinute * 60
          local endTime = beginTime + duration
          start = nowSec >= beginTime
          if start == false then
            if cfg.recommendCount > 0 then
              Label_Num:GetComponent("UILabel"):set_text("0/" .. cfg.recommendCount)
            end
            bComplete = false
          elseif bComplete == true then
            break
          end
          stop = nowSec > endTime
          inPeriod = start == true and stop == false
        end
        if isToday == true then
          if inPeriod == true then
            Label_Time:SetActive(false)
            break
          else
            if start == false then
              local strStartTime = string.format("%02d:%02d", beginHour, beginMinute)
              Label_Time:GetComponent("UILabel"):set_text(strStartTime)
              Label_Time:SetActive(true)
              break
            end
            if stop == true then
              Label_Time:GetComponent("UILabel"):set_text(textRes.activity[40])
              Label_Time:SetActive(true)
            end
          end
        elseif isRecentDayWeek == true then
          Label_Time:GetComponent("UILabel"):set_text(textRes.activity[recentDayWeek])
          Label_Time:SetActive(true)
        elseif isRecentDayWeek2 == true then
          Label_Time:GetComponent("UILabel"):set_text(textRes.activity[recentDayWeek2])
          Label_Time:SetActive(true)
        end
      end
    end
    if cfg.activityTimeCfgs and #cfg.activityTimeCfgs == 0 then
      inPeriod = isInDate
    end
    Label_Time:SetActive(isInDate == true and inPeriod == false)
    if 0 < cfg.awardActiveTimes and 0 < cfg.awardActiveValue then
      Label_2:SetActive(true)
      Label_ActiveNum:SetActive(true)
      if inPeriod == true and heroProp.level >= cfg.levelMin and heroProp.level <= cfg.levelMax then
        local times = activityInterface:GetActivityActiveTimes(cfg.id)
        local value = 0
        if times >= 0 then
          value = cfg.awardActiveValue * times
        end
        if times < 0 then
          times = 0
        end
        Label_ActiveNum:GetComponent("UILabel"):set_text(tostring(value) .. "/" .. tostring(cfg.awardActiveValue * cfg.awardActiveTimes))
      else
        Label_ActiveNum:GetComponent("UILabel"):set_text(tostring(0) .. "/" .. tostring(cfg.awardActiveValue * cfg.awardActiveTimes))
      end
    end
    Btn_Join:SetActive(inPeriod == true)
    if self._AllEnabledWithLightRound == true and inPeriod == true and bComplete == false then
      self:_SetLightRoundOn(listItem, index)
    end
    break
  end
  if bComplete == true or wordTip ~= "" then
    if wordTip == "" then
      Label_Time:GetComponent("UILabel"):set_text(textRes.activity[50])
    else
      Label_Time:GetComponent("UILabel"):set_text(wordTip)
    end
    Label_Time:SetActive(true)
    Btn_Join:SetActive(false)
  end
  local isForceOpen = activityInterface:isForceOpenActivity(cfg.id)
  if isForceOpen then
    Label_Time:SetActive(false)
    Btn_Join:SetActive(true)
  end
end
def.method("number")._FillItem = function(self, activityID)
  if self._currList == nil then
    self:_FilterList()
  end
  for idx, cfg in pairs(self._currList) do
    if cfg.id == activityID then
      self:_AddItem(idx, cfg)
      return
    end
  end
end
def.method("number", "=>", "boolean").IsSpecialActiviy = function(self, id)
  local ids = {
    require("Main.RelationShipChain.RelationShipChainMgr").SHAREACTIVIEID
  }
  for _, v in pairs(ids) do
    if id == v then
      return true
    end
  end
  return false
end
def.method("number", "=>", "number", "number").GetSpecialActiviyInfo = function(self, id)
  if id == require("Main.RelationShipChain.RelationShipChainMgr").SHAREACTIVIEID then
    local UseType = require("consts.mzm.gsp.giftaward.confbean.UseType")
    local GiftAwardMgr = require("Main.Award.mgr.GiftAwardMgr")
    local giftAwardInfo = GiftAwardMgr.Instance():GetGiftAwardInfo(UseType.SHARE_AWARD)
    local giftawardCfg = GiftAwardMgr.Instance():GetGiftAwardCfg(UseType.SHARE_AWARD)
    local useCount = 0
    local recommendCount = 0
    if giftAwardInfo then
      useCount = giftAwardInfo.useCount
    end
    if giftawardCfg then
      recommendCount = giftawardCfg.maxCount
    end
    return useCount, recommendCount
  else
    return 0, 0
  end
end
def.method("number", "=>", "boolean").isInFightCanJoin = function(self, activityId)
  local QuestionModule = require("Main.Question.QuestionModule")
  local questionConstRecord = DynamicData.GetRecord(CFG_PATH.DATA_EVERYDAYQUESTIONCONST, QuestionModule.questionCfgId)
  local questionActivityId = questionConstRecord:GetIntValue("activityId")
  if activityId == constant.CQYXTQuestionConst.ACTIVITY_ID or activityId == questionActivityId or activityId == constant.CConstellationConsts.Activityid or activityId == constant.GangCrossConsts.Activityid or activityId == constant.CNationalHolidayConst.NATIONAL_HOLIDAY_SHARE_ID or activityId == constant.JingjiActivityCfgConsts.IMAGE_PVP or activityId == constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID or require("Main.activity.Tower.TowerMgr").IsRelatedActivity(activityId) or activityId == require("Main.WorldBoss.WorldBossMgr").ACTIVITYID or activityId == gmodule.moduleMgr:GetModule(ModuleId.GANG_DUNGEON):GetActivityId() or activityId == require("Main.RelationShipChain.RelationShipChainMgr").SHAREACTIVIEID then
    return true
  end
  return false
end
def.method("number")._OnJoin = function(self, idx)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO):IsInState(RoleState.ESCORT) then
    return
  end
  if self._currList == nil then
    self:_FilterList()
  end
  local cfg = self._currList[idx]
  if not self:IsSpecialActiviy(cfg.id) then
    self:HideDlg()
  end
  local ECMSDK = require("ProxySDK.ECMSDK")
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.JOINACTIVITY, {
    cfg.id
  })
  if _G.PlayerIsInFight() and not self:isInFightCanJoin(cfg.id) then
    Toast(textRes.activity[379])
    return
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {
    cfg.id
  })
end
def.method("number")._ShowTip = function(self, idx)
  if self._currList == nil then
    self:_FilterList()
  end
  local cfg = self._currList[idx]
  local activityID = cfg.id
  local activityTip = require("Main.activity.ui.ActivityTip").Instance()
  if activityTip:IsShow() == false then
    if activityID > 0 then
      activityTip:SetActivityID(activityID)
      activityTip:ShowDlg()
    end
  else
    activityTip:HideDlg()
  end
end
def.method("number")._OnClickAwardItem = function(self, idx)
  local awardCfg = self._awardItems[idx]
  if awardCfg == nil then
    return
  end
  local awared = activityInterface:GetActiveAwared(awardCfg.awardIndex)
  if awared == true then
    Toast(textRes.activity[286])
    return
  end
  if activityInterface._currentTotalActive >= awardCfg.activiteValue then
    local p = require("netio.protocol.mzm.gsp.active.CTakeActiveAwardReq").new(awardCfg.awardIndex)
    gmodule.network.sendProtocol(p)
    return
  end
  local Group_Items = self.m_panel:FindDirect("Img_Bg0/Group_Slider/Group_Items")
  local item = Group_Items:FindDirect(string.format("item_%d", idx))
  local position = item:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = item:GetComponent("UISprite")
  local itemBase = ItemUtils.GetItemBase2(awardCfg.awardItemid)
  if itemBase ~= nil then
    ItemTipsMgr.Instance():ShowBasicTips(awardCfg.awardItemid, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
  end
end
def.method("table").ActivityStart = function(self, activityIDs)
  if self:IsShow() == false then
    return
  end
  if self._currList == nil then
    self:_FilterList()
  end
  local IDs = {}
  for idx, id in pairs(activityIDs) do
    IDs[id] = id
  end
  for idx, cfg in pairs(self._currList) do
    if IDs[cfg.id] ~= nil then
      self:_AddItem(idx, cfg)
    end
  end
  self:UpdateTimeLimitTabNotify()
end
def.method("table").ActivityEnd = function(self, activityIDs)
  if self:IsShow() == false then
    return
  end
  if self._currList == nil then
    self:_FilterList()
  end
  local IDs = {}
  for idx, id in pairs(activityIDs) do
    IDs[id] = id
  end
  for idx, cfg in pairs(self._currList) do
    if IDs[cfg.id] ~= nil then
      self:_AddItem(idx, cfg)
    end
  end
  self:UpdateTimeLimitTabNotify()
end
def.method().UpdateDailyTabNotify = function(self)
  local isDisplayRedPoint = false
  local dailList = activityInterface:GetDailyActivityList()
  for i, v in ipairs(dailList) do
    if activityInterface.activityRedPoint[v.id] then
      isDisplayRedPoint = true
      break
    end
  end
  local Tap_Daily = self.m_panel:FindDirect("Img_Bg0/Tap_Daily")
  local Img_New = Tap_Daily:FindDirect("Img_New")
  Img_New:SetActive(isDisplayRedPoint)
end
def.method().UpdateTimeLimitTabNotify = function(self)
  local Tap_TimeLimit = self.m_panel:FindDirect("Img_Bg0/Tap_TimeLimit")
  local Img_New = Tap_TimeLimit:FindDirect("Img_New")
  local weedList = activityInterface:GetWeeklyActivityList()
  local isDisplayRedPoint = false
  for i, v in ipairs(weedList) do
    if activityInterface.activityRedPoint[v.id] then
      isDisplayRedPoint = true
      break
    end
  end
  Img_New:SetActive(#activityInterface._newTimeOpenActivitiesVector > 0 or isDisplayRedPoint)
end
def.method().UpdateFestivalTabNotify = function(self)
  local Tap_TimeLimit = self.m_panel:FindDirect("Img_Bg0/Tap_Holiday")
  local Img_New = Tap_TimeLimit:FindDirect("Img_New")
  local FestivalList = activityInterface:GetFestivalActivityList()
  local isDisplayRedPoint = false
  for i, v in ipairs(FestivalList) do
    if activityInterface.activityRedPoint[v.id] then
      isDisplayRedPoint = true
      break
    end
  end
  Img_New:SetActive(#activityInterface._newFestivalActivitiesVector > 0 or isDisplayRedPoint)
end
def.method().setExchangeDisplay = function(self)
  if self.m_panel then
    local Btn_Exchange = self.m_panel:FindDirect("Img_Bg0/Btn_Exchange")
    local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
    local isOpen = feature:CheckFeatureOpen(Feature.TYPE_COMMON_EXCHANGE)
    if isOpen then
      local ExchangeInterface = require("Main.Exchange.ExchangeInterface")
      local exchangeInterface = ExchangeInterface.Instance()
      local activityIdList = exchangeInterface:getExchangeActivityList()
      if #activityIdList > 0 then
        Btn_Exchange:SetActive(true)
        local flag = exchangeInterface:isHaveExchangeActivity()
        local Img_New = Btn_Exchange:FindDirect("Img_New")
        Img_New:SetActive(flag)
      else
        Btn_Exchange:SetActive(false)
      end
    else
      Btn_Exchange:SetActive(false)
    end
  end
end
def.method().UpdateDayTargetVisible = function(self)
  local Tap_DayTarget = self.m_panel:FindDirect("Img_Bg0/Tap_DayTarget")
  local isUnlock = DailyGoalMgr.Instance():IsUnlock()
  GUIUtils.SetActive(Tap_DayTarget, isUnlock)
  if isUnlock then
    self:UpdateDayTargetTabNotify()
  end
end
def.method().UpdateDayTargetTabNotify = function(self)
  local Tap_DayTarget = self.m_panel:FindDirect("Img_Bg0/Tap_DayTarget")
  local Img_New = Tap_DayTarget:FindDirect("Img_New")
  local hasNotify = DailyGoalMgr.Instance():HasNotify()
  Img_New:SetActive(hasNotify)
end
ActivityMain.Commit()
return ActivityMain
