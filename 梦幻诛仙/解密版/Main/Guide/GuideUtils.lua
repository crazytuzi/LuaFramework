local Lplus = require("Lplus")
local GuideUtils = Lplus.Class("GuideUtils")
local def = GuideUtils.define
def.static("number", "=>", "table").GetStepCfg = function(stepId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GUIDE_SETP, stepId)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.nextstep = record:GetIntValue("nextstep")
  cfg.guidetype = record:GetIntValue("guidetype")
  cfg.headimageid = record:GetIntValue("headimageid")
  cfg.x = record:GetIntValue("x")
  cfg.y = record:GetIntValue("y")
  cfg.textdesc = record:GetStringValue("textdesc")
  cfg.guidevoiceid = record:GetIntValue("guidevoiceid")
  cfg.guidedirect = record:GetIntValue("guidedirect")
  cfg.uipath = record:GetStringValue("uipath")
  cfg.param = record:GetIntValue("uiparam")
  cfg.otherParam = {}
  local paramStruct = record:GetStructValue("paramListStruct")
  local paramSize = paramStruct:GetVectorSize("paramList")
  for i = 0, paramSize - 1 do
    local rec = paramStruct:GetVectorValueByIdx("paramList", i)
    local p = rec:GetIntValue("param")
    table.insert(cfg.otherParam, p)
  end
  return cfg
end
def.static("=>", "table").GetDieAdvanceCfg = function()
  local entries = DynamicData.GetTable(CFG_PATH.DATA_DIE_ADVANCE)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local cfg = {}
    cfg.id = entry:GetIntValue("id")
    cfg.func = entry:GetIntValue("func")
    cfg.name = entry:GetStringValue("name")
    cfg.iconid = entry:GetIntValue("iconid")
    table.insert(list, cfg)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
def.static("number", "=>", "table").GetFunctionOpenCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_FUNC_OPEN, id)
  if record == nil then
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.func = record:GetIntValue("func")
  cfg.level = record:GetIntValue("level")
  cfg.icon = record:GetStringValue("iconName")
  return cfg
end
def.static("number", "=>", "number").GetFunctionOpenLvByType = function(type)
  local lv = 0
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FUNC_OPEN)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local func = entry:GetIntValue("func")
    if type == func then
      lv = entry:GetIntValue("level")
      break
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return lv
end
def.static("number", "=>", "table").GetOpenedFunction = function(lv)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_FUNC_OPEN)
  local count = DynamicDataTable.GetRecordsCount(entries)
  local list = {}
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local levelNeed = entry:GetIntValue("level")
    if lv >= levelNeed then
      local func = entry:GetIntValue("func")
      table.insert(list, func)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list
end
local GuideConst
def.static("=>", "table").GetGuideConst = function()
  if GuideConst then
    return GuideConst
  end
  GuideConst = {}
  GuideConst.WAITTIME = DynamicData.GetRecord(CFG_PATH.DATA_GUIDE_CONST, "WATI_SECOND_FORCE_FINISH"):GetIntValue("value")
  return GuideConst
end
def.static("number", "=>", "table").GetGuideCfg = function(id)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_GUIDE_CFG, id)
  if record == nil then
    warn("GetGuideCfg nil" .. id)
    return nil
  end
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.stepNew = record:GetIntValue("stepNew")
  cfg.stepOld = record:GetIntValue("stepOld")
  return cfg
end
def.static("string", "number", "=>", "boolean").ValidateUI = function(uipath, param)
  if uipath == "fighttarget" then
    return true
  elseif uipath == "task" then
    local MainUITaskTrace = require("Main.MainUI.ui.MainUITaskTrace")
    local target = MainUITaskTrace.Instance():GetTaskTraceUIItem(param)
    if target ~= nil and target:get_activeInHierarchy() then
      return true
    else
      return false
    end
  else
    local uiRoot = require("GUI.ECGUIMan").Instance().m_UIRoot
    local target = uiRoot:FindDirect(uipath)
    if target ~= nil and target:get_activeInHierarchy() then
      return true
    else
      return false
    end
  end
end
def.static("string", "=>", "string").GetEndControl = function(uipath)
  local endSlash = 1
  local len = string.len(uipath)
  for i = 1, len do
    if string.sub(uipath, i, i) == "/" then
      endSlash = i
    end
  end
  return string.sub(uipath, endSlash + 1)
end
local LandMineCfg = {
  [550101000] = 20010,
  [550100000] = 20020,
  [550100001] = 20030,
  [550100002] = 20040,
  [550100003] = 20050,
  [550100004] = 20060,
  [550100005] = 20130,
  [550101010] = 20140,
  [550101020] = {20150, 20160},
  [550102000] = {20180, 20170},
  [550100010] = 20190,
  [550100020] = 20200,
  [550100021] = 20210,
  [550100022] = 20220,
  [550100023] = 20230,
  [550100024] = 20240,
  [550100030] = 20250,
  [550100031] = 20260,
  [550100032] = 20270,
  [550100033] = 20280,
  [550100034] = 20290,
  [550100040] = 20300,
  [550100041] = 20310,
  [550100042] = 20320,
  [550100043] = 20330,
  [550100044] = 20340,
  [550100050] = 20350,
  [550100051] = 20360,
  [550100052] = 20370,
  [550100060] = 20380,
  [550100061] = 20390,
  [550100070] = 20400,
  [550100071] = 20410,
  [550100072] = 20420,
  [550100073] = 20430,
  [550100074] = 20440,
  [550100075] = 20450,
  [550100080] = 0,
  [550100081] = 0,
  [550100082] = 0,
  [550100083] = 0,
  [550100084] = 0,
  [550100085] = 0,
  [550100102] = 20460,
  [550100100] = 20470,
  [550100101] = 0,
  [550100110] = 20480,
  [550100111] = 0,
  [550100112] = 20490,
  [550100120] = 20500,
  [550100121] = 0,
  [550100122] = 20510,
  [550100123] = 20520,
  [550100126] = 0,
  [550100124] = 20530,
  [550100125] = 0,
  [550100130] = 20550,
  [550100131] = 20560,
  [550100140] = 20570,
  [550100150] = 20580,
  [550100151] = 20590,
  [550100160] = 0,
  [550100170] = 0,
  [550100180] = 0,
  [550100190] = 20600,
  [550100191] = 20610,
  [550100200] = 20620,
  [550100210] = 20660,
  [550100211] = 20670,
  [550100212] = 20680,
  [550100213] = 20690,
  [550100220] = 20710,
  [550100221] = 20720,
  [550100222] = 20730,
  [550100223] = 20740,
  [550100230] = 20630,
  [550100231] = 20640,
  [550100240] = 20750,
  [550100241] = 20760,
  [550100250] = 0,
  [550100260] = 0,
  [550100270] = 0,
  [550100280] = 0,
  [550100290] = 20770,
  [550100291] = 20780
}
def.static("number", "number").GuideBILog = function(stepId, param)
  if LandMineCfg[stepId] == nil then
    return
  end
  local landMine = 0
  if param >= 0 then
    local t = type(LandMineCfg[stepId])
    if t == "table" then
      landMine = LandMineCfg[stepId][param] or 0
    end
  else
    landMine = LandMineCfg[stepId] or 0
  end
  if landMine <= 0 then
    return
  end
  local username = require("Main.Login.LoginModule").Instance().userName
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local roleName = heroProp.name
  local roleLv = tostring(heroProp.level)
  local landMineStr = tostring(landMine)
end
GuideUtils.Commit()
return GuideUtils
