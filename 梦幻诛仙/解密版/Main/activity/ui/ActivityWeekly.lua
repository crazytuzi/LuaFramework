local Lplus = require("Lplus")
local NPCModule = Lplus.ForwardDeclare("NPCModule")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local ActivityWeekly = Lplus.Extend(ECPanelBase, "ActivityWeekly")
local def = ActivityWeekly.define
local inst
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
def.static("=>", ActivityWeekly).Instance = function()
  if inst == nil then
    inst = ActivityWeekly()
    inst:Init()
  end
  return inst
end
ActivityWeekly.ROWS = 6
def.field("table").ctrlTable = nil
def.field("boolean").isshowing = false
def.method().Init = function(self)
  self.ctrlTable = {}
  self.m_TrigGC = true
end
def.method().ShowDlg = function(self)
  if self:IsShow() == false then
    print("CreatePanel()")
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_ACTIVITY_WEEKLY, 2)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HideDlg()
  else
    local strs = string.split(id, "_")
    if strs[1] == "Box" and strs[2] == "Activity" then
      local i = tonumber(strs[3])
      local j = tonumber(strs[4])
      self:ShowTip(i, j)
    else
      local activityTip = require("Main.activity.ui.ActivityTip").Instance()
      if activityTip:IsShow() == true then
        activityTip:HideDlg()
      end
    end
  end
end
def.override().OnCreate = function(self)
  local Img_Bg1 = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  self.ctrlTable = {}
  for i = 1, ActivityWeekly.ROWS do
    local ctrlRow = {}
    local Grid_Activity = Img_Bg1:FindDirect(string.format("Grid_Activity%02d", i))
    local Label_Time = Grid_Activity:FindDirect(string.format("Img_Time%02d/Label_Time%02d", i, i))
    ctrlRow.Label_Time = Label_Time
    local gridCells = {}
    for j = 1, 7 do
      local Img_Activity = Grid_Activity:FindDirect(string.format("Img_Activity%d", j))
      local Box_Activity = Img_Activity:FindDirect("Box_Activity")
      Box_Activity:set_name(string.format("Box_Activity_%02d_%02d", i, j))
      local Label_Activity = Img_Activity:FindDirect("Label_Activity")
      local gridCell = {}
      gridCell.Label_Activity = Label_Activity
      table.insert(gridCells, gridCell)
    end
    ctrlRow.gridCells = gridCells
    table.insert(self.ctrlTable, ctrlRow)
  end
end
def.override().OnDestroy = function(self)
  self.isshowing = false
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
  else
    self.isshowing = false
  end
end
def.method().Fill = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_ACTIVITY_CALENDER_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local nowSec = GetServerTime()
  local nowDayWeek = tonumber(os.date("%w", nowSec))
  if nowDayWeek == 0 then
    nowDayWeek = 7
  end
  local beginIdx = 1
  local endIdx = math.min(count, ActivityWeekly.ROWS)
  local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = beginIdx, ActivityWeekly.ROWS do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local ctrlRow = self.ctrlTable[i]
    ctrlRow.Label_Time:GetComponent("UILabel"):set_text("")
    local beginHour = 0
    local beginMinute = 0
    local commonTimeID = entry:GetIntValue("commontimeId")
    local timeCommonCfg = TimeCfgUtils.GetTimeCommonCfg(commonTimeID)
    if timeCommonCfg ~= nil then
      beginHour = timeCommonCfg.activeHour
      beginMinute = timeCommonCfg.activeMinute
      ctrlRow.Label_Time:GetComponent("UILabel"):set_text(string.format("%02d:%02d", beginHour, beginMinute))
    end
    local fillTime = false
    for j = 1, 7 do
      local activityID = entry:GetIntValue(string.format("actvityId%d", j))
      local gridCell = ctrlRow.gridCells[j]
      gridCell.activityID = activityID
      if activityID ~= nil and activityID ~= 0 then
        local cfg = ActivityInterface.GetActivityCfgById(activityID)
        gridCell.Label_Activity:GetComponent("UILabel"):set_text(cfg.activityName)
      else
        gridCell.Label_Activity:GetComponent("UILabel"):set_text("")
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local Img_Bg1 = self.m_panel:FindDirect("Img_Bg0/Img_Bg1")
  local Grid_DailySelect = Img_Bg1:FindDirect("Grid_DailySelect")
  for j = 1, 7 do
    local Img_BgDailySelect = Grid_DailySelect:FindDirect(string.format("Img_BgDailySelect%02d", j))
    Img_BgDailySelect:SetActive(j == nowDayWeek)
  end
end
def.method("number", "number").ShowTip = function(self, i, j)
  warn("******************* ActivityWeekly.ShowTip(", i, j, ")")
  local ctrlRow = self.ctrlTable[i]
  local gridCell = ctrlRow.gridCells[j]
  local activityID = gridCell.activityID
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
ActivityWeekly.Commit()
return ActivityWeekly
