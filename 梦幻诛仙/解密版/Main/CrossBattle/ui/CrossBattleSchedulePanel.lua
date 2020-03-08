local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleSchedulePanel = Lplus.Extend(ECPanelBase, "CrossBattleSchedulePanel")
local CrossBattleInterface = require("Main.CrossBattle.CrossBattleInterface")
local CrossBattleActivityStage = require("netio.protocol.mzm.gsp.crossbattle.crossBattleActivityStage")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GUIUtils = require("GUI.GUIUtils")
local def = CrossBattleSchedulePanel.define
def.field("table").uiObjs = nil
def.field("table").calendarData = nil
def.field("table").beginDate = nil
def.field("table").endDate = nil
def.field("table").curMonth = nil
def.field("table").group2DateMap = nil
def.field("table").date2GroupMap = nil
local instance
def.static("=>", CrossBattleSchedulePanel).Instance = function()
  if instance == nil then
    instance = CrossBattleSchedulePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CROSS_BATTLE_CALENDAR) then
    Toast(textRes.CrossBattle.Schedule[1])
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_FIGHT_SCHEDULE, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitCalendar()
  self:UpdateCurMonthSchedule()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.calendarData = nil
  self.beginDate = nil
  self.endDate = nil
  self.curMonth = nil
  self.group2DateMap = nil
  self.date2GroupMap = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Date = self.uiObjs.Img_Bg0:FindDirect("Group_Date")
  self.uiObjs.Group_List = self.uiObjs.Group_Date:FindDirect("Group_List")
  self.uiObjs.Label_Title = self.uiObjs.Img_Bg0:FindDirect("Label_Title")
end
def.method().InitCalendar = function(self)
  local calendarData = CrossBattleInterface.GetCrossBattleCalendarData()
  if calendarData == nil then
    return
  end
  self.calendarData = calendarData
  self.beginDate = calendarData.signUpDate[1]
  if #calendarData.finalDate > 0 then
    self.endDate = calendarData.finalDate[#calendarData.finalDate]
  elseif 0 < #calendarData.selectionDate then
    self.endDate = calendarData.selectionDate[#calendarData.selectionDate]
  elseif 0 < #calendarData.pointDate then
    self.endDate = calendarData.pointDate[#calendarData.pointDate]
  elseif 0 < #calendarData.drawLotsDate then
    self.endDate = calendarData.drawLotsDate[#calendarData.drawLotsDate]
  elseif 0 < #calendarData.roundDate then
    self.endDate = calendarData.roundDate[#calendarData.roundDate]
  elseif 0 < #calendarData.voteDate then
    self.endDate = calendarData.voteDate[#calendarData.voteDate]
  elseif #calendarData.signUpDate > 0 then
    self.endDate = calendarData.signUpDate[#calendarData.signUpDate]
  end
  if self.beginDate ~= nil and self.endDate ~= nil then
    local serverTime = _G.GetServerTime()
    local beginTime = AbsoluteTimer.GetServerTimeByDate(self.beginDate.year, self.beginDate.month, 1, 0, 0, 0)
    local endTime = AbsoluteTimer.GetServerTimeByDate(self.endDate.year, self.endDate.month + 1, 1, 0, 0, 0)
    self.curMonth = {}
    if serverTime >= beginTime and serverTime <= endTime then
      local t = AbsoluteTimer.GetServerTimeTable(serverTime)
      self.curMonth.year = t.year
      self.curMonth.month = t.month
    else
      self.curMonth.year = self.beginDate.year
      self.curMonth.month = self.beginDate.month
    end
  end
end
def.method().UpdateCurMonthSchedule = function(self)
  if self.beginDate == nil or self.endDate == nil or self.curMonth == nil then
    return
  end
  self.group2DateMap = {}
  self.date2GroupMap = {}
  GUIUtils.SetText(self.uiObjs.Label_Title, string.format(textRes.CrossBattle[101], self.curMonth.year, self.curMonth.month))
  local firstDayTime = AbsoluteTimer.GetServerTimeByDate(self.curMonth.year, self.curMonth.month, 1, 1, 0, 0)
  local firstDay = AbsoluteTimer.GetServerTimeTable(firstDayTime)
  local dayInWeek = firstDay.wday == 1 and 7 or firstDay.wday - 1
  for i = dayInWeek - 1, 1, -1 do
    local time = firstDayTime - 86400 * (dayInWeek - i)
    local t = AbsoluteTimer.GetServerTimeTable(time)
    local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
    local groupName = string.format("Group_%02d", i)
    self.date2GroupMap[date] = groupName
    local grid = self.uiObjs.Group_List:FindDirect(groupName)
    self:FillGridDate(grid, t)
  end
  for i = dayInWeek, 40 do
    local time = firstDayTime + 86400 * (i - dayInWeek)
    local t = AbsoluteTimer.GetServerTimeTable(time)
    local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
    local groupName = string.format("Group_%02d", i)
    self.date2GroupMap[date] = groupName
    local grid = self.uiObjs.Group_List:FindDirect(groupName)
    self:FillGridDate(grid, t)
  end
  for i = 1, #self.calendarData.signUpDate do
    local t = self.calendarData.signUpDate[i]
    local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
    local groupName = self.date2GroupMap[date]
    if groupName ~= nil then
      self.group2DateMap[groupName] = t
      local grid = self.uiObjs.Group_List:FindDirect(groupName)
      self:FillSignUpGrid(grid, t)
    end
  end
  for i = 1, #self.calendarData.voteDate do
    local t = self.calendarData.voteDate[i]
    local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
    local groupName = self.date2GroupMap[date]
    if groupName ~= nil then
      self.group2DateMap[groupName] = t
      local grid = self.uiObjs.Group_List:FindDirect(groupName)
      self:FillVoteGrid(grid, t)
    end
  end
  for i = 1, #self.calendarData.roundDate do
    local t = self.calendarData.roundDate[i]
    local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
    local groupName = self.date2GroupMap[date]
    if groupName ~= nil then
      self.group2DateMap[groupName] = t
      local grid = self.uiObjs.Group_List:FindDirect(groupName)
      self:FillRoundGrid(grid, t)
    end
  end
  for i = 1, #self.calendarData.pointDate do
    local t = self.calendarData.pointDate[i]
    local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
    local groupName = self.date2GroupMap[date]
    if groupName ~= nil then
      self.group2DateMap[groupName] = t
      local grid = self.uiObjs.Group_List:FindDirect(groupName)
      self:FillPointGrid(grid, t)
    end
  end
  for i = 1, #self.calendarData.selectionDate do
    local t = self.calendarData.selectionDate[i]
    local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
    local groupName = self.date2GroupMap[date]
    if groupName ~= nil then
      self.group2DateMap[groupName] = t
      local grid = self.uiObjs.Group_List:FindDirect(groupName)
      self:FillSelectionGrid(grid, i, t)
    end
  end
  for i = 1, #self.calendarData.finalDate do
    local t = self.calendarData.finalDate[i]
    local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
    local groupName = self.date2GroupMap[date]
    if groupName ~= nil then
      self.group2DateMap[groupName] = t
      local grid = self.uiObjs.Group_List:FindDirect(groupName)
      self:FillFinalGrid(grid, i, t)
    end
  end
  local serverTime = _G.GetServerTime()
  local t = AbsoluteTimer.GetServerTimeTable(serverTime)
  local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
  local groupName = self.date2GroupMap[date]
  if groupName ~= nil then
    local grid = self.uiObjs.Group_List:FindDirect(groupName)
    GUIUtils.SetActive(grid:FindDirect("Img_Select"), true)
  end
end
def.method("userdata", "table").FillGridDate = function(self, grid, t)
  local Label_Date = grid:FindDirect("Label_Date")
  local Texture_Event = grid:FindDirect("Texture_Event")
  local Label_Name = grid:FindDirect("Label_Name")
  local Img_Select = grid:FindDirect("Img_Select")
  GUIUtils.SetText(Label_Date, t.day)
  local textColor = Label_Date:GetComponent("UILabel").textColor
  if t.month ~= self.curMonth.month then
    textColor.a = 0.5
  else
    textColor.a = 1
  end
  Label_Date:GetComponent("UILabel").textColor = textColor
  GUIUtils.FillIcon(Texture_Event:GetComponent("UITexture"), 0)
  GUIUtils.SetText(Label_Name, "")
  GUIUtils.SetActive(Img_Select, false)
end
def.method("userdata", "table").FillSignUpGrid = function(self, grid, t)
  local Texture_Event = grid:FindDirect("Texture_Event")
  local Label_Name = grid:FindDirect("Label_Name")
  GUIUtils.FillIcon(Texture_Event:GetComponent("UITexture"), constant.CrossBattleCalendarConsts.sign_up_icon_id)
  GUIUtils.SetText(Label_Name, "")
  if t.month ~= self.curMonth.month then
    Texture_Event:GetComponent("UITexture").alpha = 0.5
  else
    Texture_Event:GetComponent("UITexture").alpha = 1
  end
end
def.method("userdata", "table").FillVoteGrid = function(self, grid, t)
  local Texture_Event = grid:FindDirect("Texture_Event")
  local Label_Name = grid:FindDirect("Label_Name")
  GUIUtils.FillIcon(Texture_Event:GetComponent("UITexture"), constant.CrossBattleCalendarConsts.vote_icon_id)
  GUIUtils.SetText(Label_Name, "")
  if t.month ~= self.curMonth.month then
    Texture_Event:GetComponent("UITexture").alpha = 0.5
  else
    Texture_Event:GetComponent("UITexture").alpha = 1
  end
end
def.method("userdata", "table").FillRoundGrid = function(self, grid, t)
  local Texture_Event = grid:FindDirect("Texture_Event")
  local Label_Name = grid:FindDirect("Label_Name")
  GUIUtils.FillIcon(Texture_Event:GetComponent("UITexture"), constant.CrossBattleCalendarConsts.round_icon_id)
  GUIUtils.SetText(Label_Name, "")
  if t.month ~= self.curMonth.month then
    Texture_Event:GetComponent("UITexture").alpha = 0.5
  else
    Texture_Event:GetComponent("UITexture").alpha = 1
  end
end
def.method("userdata", "table").FillPointGrid = function(self, grid, t)
  local Texture_Event = grid:FindDirect("Texture_Event")
  local Label_Name = grid:FindDirect("Label_Name")
  GUIUtils.FillIcon(Texture_Event:GetComponent("UITexture"), constant.CrossBattleCalendarConsts.point_icon_id)
  GUIUtils.SetText(Label_Name, "")
  if t.month ~= self.curMonth.month then
    Texture_Event:GetComponent("UITexture").alpha = 0.5
  else
    Texture_Event:GetComponent("UITexture").alpha = 1
  end
end
def.method("userdata", "number", "table").FillSelectionGrid = function(self, grid, stage, t)
  local Texture_Event = grid:FindDirect("Texture_Event")
  local Label_Name = grid:FindDirect("Label_Name")
  GUIUtils.FillIcon(Texture_Event:GetComponent("UITexture"), constant.CrossBattleCalendarConsts.selection_icon_id)
  GUIUtils.SetText(Label_Name, textRes.CrossBattle.CrossBattleSelection.BattleType[stage])
  if t.month ~= self.curMonth.month then
    Texture_Event:GetComponent("UITexture").alpha = 0.5
  else
    Texture_Event:GetComponent("UITexture").alpha = 1
  end
end
def.method("userdata", "number", "table").FillFinalGrid = function(self, grid, stage, t)
  local Texture_Event = grid:FindDirect("Texture_Event")
  local Label_Name = grid:FindDirect("Label_Name")
  GUIUtils.FillIcon(Texture_Event:GetComponent("UITexture"), constant.CrossBattleCalendarConsts.final_icon_id)
  local battleCountPerStage = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr").STAGE_BATTLE_COUNT
  local curStage = math.floor((stage - 1) / battleCountPerStage) + 1
  local round = (stage - 1) % battleCountPerStage + 1
  GUIUtils.SetText(Label_Name, textRes.CrossBattle.CrossBattleFinal.BattleType[curStage] .. string.format(textRes.CrossBattle.CrossBattleFinal[18], round))
  if t.month ~= self.curMonth.month then
    Texture_Event:GetComponent("UITexture").alpha = 0.5
  else
    Texture_Event:GetComponent("UITexture").alpha = 1
  end
end
def.method().ShowNextMonthSchedule = function(self)
  local nextMonthTime = AbsoluteTimer.GetServerTimeByDate(self.curMonth.year, self.curMonth.month + 1, 1, 1, 0, 0)
  local t = AbsoluteTimer.GetServerTimeTable(nextMonthTime)
  self.curMonth.year = t.year
  self.curMonth.month = t.month
  self:UpdateCurMonthSchedule()
end
def.method().ShowPreMonthSchedule = function(self)
  local preMonthTime = AbsoluteTimer.GetServerTimeByDate(self.curMonth.year, self.curMonth.month - 1, 1, 1, 0, 0)
  local t = AbsoluteTimer.GetServerTimeTable(preMonthTime)
  self.curMonth.year = t.year
  self.curMonth.month = t.month
  self:UpdateCurMonthSchedule()
end
def.method("table").ShowBattleInfo = function(self, date)
  for i = 1, #self.calendarData.roundDate do
    local t = self.calendarData.roundDate[i]
    if t.year == date.year and t.month == date.month and t.day == date.day and t.hour == date.hour and t.min == date.min and t.sec == date.sec then
      self:CheckToShowRoundFightInfo(t, i)
      return
    end
  end
  for i = 1, #self.calendarData.pointDate do
    local t = self.calendarData.pointDate[i]
    if t.year == date.year and t.month == date.month and t.day == date.day and t.hour == date.hour and t.min == date.min and t.sec == date.sec then
      self:CheckToShowPointsFightInfo(t, i)
      return
    end
  end
  for i = 1, #self.calendarData.selectionDate do
    local t = self.calendarData.selectionDate[i]
    if t.year == date.year and t.month == date.month and t.day == date.day and t.hour == date.hour and t.min == date.min and t.sec == date.sec then
      self:CheckToShowSelectionFightInfo(t, i)
      return
    end
  end
  for i = 1, #self.calendarData.finalDate do
    local t = self.calendarData.finalDate[i]
    if t.year == date.year and t.month == date.month and t.day == date.day and t.hour == date.hour and t.min == date.min and t.sec == date.sec then
      self:CheckToShowFinalFightInfo(t, i)
      return
    end
  end
end
def.method("table", "number").ShowFightTime = function(self, t, duration)
  local endTime = AbsoluteTimer.GetServerTimeByDate(t.year, t.month, t.day, t.hour, t.min, t.sec + duration)
  local endTimeTbl = AbsoluteTimer.GetServerTimeTable(endTime)
  local dateStr = string.format(textRes.CrossBattle[105], t.year, t.month, t.day)
  local timeStr = string.format(textRes.CrossBattle[108], t.hour, t.min, endTimeTbl.hour, endTimeTbl.min)
  local CrossBattleScheduleTips = require("Main.CrossBattle.ui.CrossBattleScheduleTips")
  local date = string.format("%d-%02d-%02d", t.year, t.month, t.day)
  local groupName = self.date2GroupMap[date]
  if groupName ~= nil then
    local grid = self.uiObjs.Group_List:FindDirect(groupName)
    CrossBattleScheduleTips.Instance():ShowPanelAutoPos(dateStr, timeStr, grid)
  else
    CrossBattleScheduleTips.Instance():ShowPanel(dateStr, timeStr)
  end
  return
end
def.method("table", "number").CheckToShowRoundFightInfo = function(self, t, round)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  if crossBattleCfg == nil then
    return
  end
  local duration = crossBattleCfg.round_robin_stage_fight_max_duration_in_minute * 60
  local voteEndDate = self.calendarData.voteDate[#self.calendarData.voteDate]
  local serverTime = _G.GetServerTime()
  local voteEndTime = AbsoluteTimer.GetServerTimeByDate(voteEndDate.year, voteEndDate.month, voteEndDate.day + 1, 0, 0, 0)
  if serverTime <= voteEndTime then
    self:ShowFightTime(t, duration)
    return
  end
  local isOpen = CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_ROUND_ROBIN)
  if not isOpen then
    Toast(textRes.CrossBattle[39])
    return
  end
  local CrossBattleRoundFightInfoPanel = require("Main.CrossBattle.ui.CrossBattleRoundFightInfoPanel")
  CrossBattleRoundFightInfoPanel.Instance():ShowPanel(t, round)
end
def.method("table", "number").CheckToShowPointsFightInfo = function(self, t, round)
  local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
  local pointsCfg = PointsRaceUtils.GetCurrentRaceCfg()
  if pointsCfg == nil then
    return
  end
  local duration = (pointsCfg.durationInMinute - pointsCfg.prepareDurationInMinute) * 60
  local serverTime = _G.GetServerTime()
  local endTime = AbsoluteTimer.GetServerTimeByDate(t.year, t.month, t.day, t.hour, t.min, t.sec + duration)
  if serverTime <= endTime then
    self:ShowFightTime(t, duration)
    return
  end
  local isOpen = CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_ZONE_POINT)
  if not isOpen then
    Toast(textRes.CrossBattle[39])
    return
  end
  local CrossBattlePointsFightInfoPanel = require("Main.CrossBattle.ui.CrossBattlePointsFightInfoPanel")
  CrossBattlePointsFightInfoPanel.Instance():ShowPanel(t, round)
end
def.method("table", "number").CheckToShowSelectionFightInfo = function(self, t, stage)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
  if crossBattleCfg == nil then
    return
  end
  local fightDuration = crossBattleCfg.selection_fight_last_time * 60
  if not self:IsSelectionSatgeHaveFightInfo(stage) then
    self:ShowFightTime(t, fightDuration)
    return
  end
  local isOpen = CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_SELECTION)
  if not isOpen then
    Toast(textRes.CrossBattle[39])
    return
  end
  local CrossBattleSelectionMgr = require("Main.CrossBattle.Selection.mgr.CrossBattleSelectionMgr")
  local PointsRaceData = require("Main.CrossBattle.PointsRace.data.PointsRaceData")
  local zoneId = PointsRaceData.Instance():GetZoneId() > 0 and PointsRaceData.Instance():GetZoneId() or 1
  CrossBattleSelectionMgr.Instance():QueryToShowZoneSelectionFightHistory(zoneId, stage)
end
def.method("number", "=>", "boolean").IsSelectionSatgeHaveFightInfo = function(self, stage)
  local serverTime = _G.GetServerTime()
  local CrossBattleSelectionStageEnum = require("consts.mzm.gsp.crossbattle.confbean.CrossBattleSelectionStageEnum")
  if stage == CrossBattleSelectionStageEnum._32_TO_16 then
    local PointsRaceUtils = require("Main.CrossBattle.PointsRace.PointsRaceUtils")
    local pointsCfg = PointsRaceUtils.GetCurrentRaceCfg()
    if pointsCfg == nil then
      return false
    end
    local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
    local timePoint = TimeCfgUtils.GetCommonTimePointCfg(pointsCfg.endTimePoint)
    local delay = 3600
    local endTime = AbsoluteTimer.GetServerTimeByDate(timePoint.year, timePoint.month, timePoint.day, timePoint.hour, timePoint.min, timePoint.sec + delay)
    return serverTime > endTime
  else
    local lastFightTime
    if stage == CrossBattleSelectionStageEnum.THIRD or stage == CrossBattleSelectionStageEnum.CHAMPION then
      lastFightTime = self.calendarData.selectionDate[CrossBattleSelectionStageEnum._4_TO_2]
    else
      lastFightTime = self.calendarData.selectionDate[stage - 1]
    end
    if lastFightTime == nil then
      return false
    end
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    if crossBattleCfg == nil then
      return false
    end
    local duration = crossBattleCfg.selection_fight_last_time * 60
    local endTime = AbsoluteTimer.GetServerTimeByDate(lastFightTime.year, lastFightTime.month, lastFightTime.day, lastFightTime.hour, lastFightTime.min, lastFightTime.sec + duration)
    return serverTime > endTime
  end
  return false
end
def.method("table", "number").CheckToShowFinalFightInfo = function(self, t, stage)
  local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
  if crossBattleCfg == nil then
    return
  end
  local fightDuration = crossBattleCfg.final_fight_last_time * 60
  if not self:IsFinalSatgeHaveFightInfo(stage) then
    self:ShowFightTime(t, fightDuration)
    return
  end
  local isOpen = CrossBattleInterface.Instance():isOpenCrossBattleStage(CrossBattleActivityStage.STAGE_FINAL)
  if not isOpen then
    Toast(textRes.CrossBattle[39])
    return
  end
  local CrossBattleFinalMgr = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr")
  local zoneId = 1
  CrossBattleFinalMgr.Instance():QueryToShowZoneFinalFightHistory(zoneId, stage)
end
def.method("number", "=>", "boolean").IsFinalSatgeHaveFightInfo = function(self, stage)
  local serverTime = _G.GetServerTime()
  local CrossBattleSelectionStageEnum = require("consts.mzm.gsp.crossbattle.confbean.CrossBattleSelectionStageEnum")
  local CrossBattleFinalStageEnum = require("consts.mzm.gsp.crossbattle.confbean.CrossBattleFinalStageEnum")
  local battleCountPerStage = require("Main.CrossBattle.Final.mgr.CrossBattleFinalMgr").STAGE_BATTLE_COUNT
  local battleStage = math.floor((stage - 1) / battleCountPerStage) + 1
  if battleStage == 1 then
    local lastFightTime = self.calendarData.selectionDate[CrossBattleSelectionStageEnum.CHAMPION]
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleSelectionCfg(constant.CrossBattleConsts.CURRENT_ACTIVITY_CFG_ID)
    if crossBattleCfg == nil then
      return false
    end
    local duration = crossBattleCfg.selection_fight_last_time * 60
    local delay = 3600
    local endTime = AbsoluteTimer.GetServerTimeByDate(lastFightTime.year, lastFightTime.month, lastFightTime.day, lastFightTime.hour, lastFightTime.min, lastFightTime.sec + duration + delay)
    return serverTime > endTime
  else
    local crossBattleCfg = CrossBattleInterface.GetCrossBattleFinalCfg()
    if crossBattleCfg == nil then
      return false
    end
    local FINAL_4_TO_2_3 = #crossBattleCfg.final_stage_time - 6
    local lastFightTime
    if stage > FINAL_4_TO_2_3 then
      lastFightTime = self.calendarData.finalDate[FINAL_4_TO_2_3]
    else
      lastFightTime = self.calendarData.finalDate[(battleStage - 1) * battleCountPerStage]
    end
    if lastFightTime == nil then
      return false
    end
    local duration = crossBattleCfg.final_fight_last_time * 60
    local endTime = AbsoluteTimer.GetServerTimeByDate(lastFightTime.year, lastFightTime.month, lastFightTime.day, lastFightTime.hour, lastFightTime.min, lastFightTime.sec + duration)
    return serverTime > endTime
  end
  return false
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Right" then
    self:OnClickNextMonth()
  elseif id == "Btn_Left" then
    self:OnClickPreMonth()
  elseif string.find(id, "Group_") then
    self:OnClickDate(id)
  elseif id == "Btn_Rule" then
    self:OnClickRule()
  end
end
def.method().OnClickNextMonth = function(self)
  if self.curMonth.year == self.endDate.year and self.curMonth.month == self.endDate.month then
    Toast(textRes.CrossBattle[102])
    return
  end
  self:ShowNextMonthSchedule()
end
def.method().OnClickPreMonth = function(self)
  if self.curMonth.year == self.beginDate.year and self.curMonth.month == self.beginDate.month then
    Toast(textRes.CrossBattle[103])
    return
  end
  self:ShowPreMonthSchedule()
end
def.method("string").OnClickDate = function(self, groupName)
  local date = self.group2DateMap[groupName]
  if date == nil then
    return
  end
  self:ShowBattleInfo(date)
end
def.method().OnClickRule = function(self)
  local CrossBattleRulePanel = require("Main.CrossBattle.ui.CrossBattleRulePanel")
  CrossBattleRulePanel.Instance():ShowPanel()
end
CrossBattleSchedulePanel.Commit()
return CrossBattleSchedulePanel
