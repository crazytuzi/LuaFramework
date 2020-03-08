local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local JueZhanJiuXiaoUIMgr = Lplus.Class(MODULE_NAME)
local JZJXMgr = import(".JZJXMgr")
local def = JueZhanJiuXiaoUIMgr.define
local UISet = {
  JZJXMain = "JZJXMainPanel"
}
def.const("table").UISet = UISet
local instance
def.static("=>", JueZhanJiuXiaoUIMgr).Instance = function()
  if instance == nil then
    instance = JueZhanJiuXiaoUIMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_EnterWaitingRoom, JueZhanJiuXiaoUIMgr._OnEnterWaitingRoom)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_LeaveWaitingRoom, JueZhanJiuXiaoUIMgr._OnLeaveWaitingRoom)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_EnterActivityMap, JueZhanJiuXiaoUIMgr._OnEnterActivityMap)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_LeaveActivityMap, JueZhanJiuXiaoUIMgr._OnLeaveActivityMap)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_JZJX_ChangeActivityMap, JueZhanJiuXiaoUIMgr._OnChangeActivityMap)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return import(".ui." .. uiName, MODULE_NAME)
end
def.method("=>", "table").GetCurLayerMapViewData = function()
  local jzjxData = JZJXMgr.Instance():GetJZJXData()
  if jzjxData == nil then
    return nil
  end
  local viewData = {}
  viewData.npcList = {}
  viewData.isAwarded = false
  local NPCInterface = Lplus.ForwardDeclare("NPCInterface")
  local layerMapCfg = JZJXMgr.Instance():GetCurLayerMapCfg()
  for i, npcId in ipairs(layerMapCfg.npcIdList) do
    local npcCfg = NPCInterface.GetNPCCfg(npcId)
    table.insert(viewData.npcList, {
      npcId = npcId,
      npcName = npcCfg.npcName,
      isFound = false
    })
  end
  local npcName = NPCInterface.GetNPCCfg(layerMapCfg.bossNPCId).npcName
  viewData.bossNPC = {
    npcId = layerMapCfg.bossNPCId,
    npcName = npcName,
    isDefeat = false
  }
  local mapData = jzjxData:GetCurLayerMapData()
  if mapData then
    viewData.isAwarded = mapData.isAwarded
    if mapData.progresses then
      for i, idx in ipairs(mapData.progresses) do
        local npcViewData = viewData.npcList[idx + 1]
        if npcViewData then
          npcViewData.isFound = true
        end
      end
    end
    viewData.bossNPC.isDefeat = mapData.isDefeatBoss
  end
  return viewData
end
def.static("table", "table")._OnEnterWaitingRoom = function(params)
  instance:GetUI(UISet.JZJXMain).Instance():ShowCountDown()
end
def.static("table", "table")._OnLeaveWaitingRoom = function(params)
  instance:GetUI(UISet.JZJXMain).Instance():DestroyPanel()
end
def.static("table", "table")._OnEnterActivityMap = function(params)
  local mapLayer = params[1]
  instance:GetUI(UISet.JZJXMain).Instance():ShowActivity()
end
def.static("table", "table")._OnChangeActivityMap = function(params)
  local mapLayer = params[1]
end
def.static("table", "table")._OnLeaveActivityMap = function(params)
  instance:GetUI(UISet.JZJXMain).Instance():DestroyPanel()
end
return JueZhanJiuXiaoUIMgr.Commit()
