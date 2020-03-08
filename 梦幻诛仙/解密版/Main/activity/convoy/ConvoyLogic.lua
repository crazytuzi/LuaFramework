local Lplus = require("Lplus")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ConvoyUI = require("Main.activity.convoy.ui.Convoy")
local NPCInterface = require("Main.npc.NPCInterface")
local ConvoyLogic = Lplus.Class("ConvoyLogic")
local def = ConvoyLogic.define
local inst
def.static("=>", ConvoyLogic).Instance = function()
  if inst == nil then
    inst = ConvoyLogic()
  end
  return inst
end
def.static("table", "table").OnConvoyStart = function(p1, p2)
  ConvoyUI.Instance():ShowDlg()
end
def.static("table", "table").OnConvoyEnd = function(p1, p2)
  ConvoyUI.Instance():HideDlg()
end
def.static("table", "table").OnConvoySucceed = function(p1, p2)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ACTIVITY_CHuSongCfg, activityInterface._husongcfgid)
  local cfg = {}
  cfg.id = record:GetIntValue("id")
  cfg.handupNPCid = record:GetIntValue("handupNPCid")
  cfg.handupNPCWord = record:GetStringValue("handupNPCWord")
  local contents = {}
  local content = {}
  content.npcid = cfg.handupNPCid
  content.txt = cfg.handupNPCWord
  table.insert(contents, content)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  taskModule:ShowTaskTalkCustom(contents, nil, ConvoyLogic.OnConvoyEndTalkOver)
end
def.static("table", "table").OnNewDay = function(p1, p2)
  activityInterface._husongMap = {}
end
def.static("table").OnConvoyEndTalkOver = function(param)
  local succeed = ActivityInterface.CheckActivityConditionFinishCount(constant.HuSongConsts.CONVOY_ACTIVITY_ID)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  if succeed == true then
    CommonConfirmDlg.ShowConfirmCoundDown(textRes.activity[253], textRes.activity[267], textRes.Login[105], textRes.Login[106], 1, 30, ConvoyLogic.OnConvoyContinueConfirm, {self})
  else
    local HuSongType = require("consts.mzm.gsp.activity.confbean.HuSongType")
    local specialcount = 0
    if activityInterface._husongMap ~= nil then
      specialcount = activityInterface._husongMap[HuSongType.SPECIAL] or 0
    end
    if specialcount == 0 then
      CommonConfirmDlg.ShowConfirmCoundDown(textRes.activity[253], textRes.activity[268], textRes.Login[105], textRes.Login[106], 0, 30, ConvoyLogic.OnConvoySpecialConfirm, {self})
    end
  end
end
def.static("number", "table").OnConvoyContinueConfirm = function(id, tag)
  if id == 1 then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.HuSongConsts.CONVOY_NPCID
    })
  end
end
def.static("number", "table").OnConvoySpecialConfirm = function(id, tag)
  if id == 1 then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.HuSongConsts.CONVOY_NPCID
    })
  end
end
ConvoyLogic.Commit()
return ConvoyLogic
