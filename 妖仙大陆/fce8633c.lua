
local Player = require"Zeus.Model.Player"

local _M = {}
_M.__index = _M

local chooseMap = -1
local allAreasDate = {}
local offlineAward = {}
local bAward = {}
local curOfflineArea = {}

local function getItem(map, index)
  return map.awardItems.awards[index]
end

local function getCurrentOfflineArea()
  Pomelo.OfflineAwardHandler.getCurrentOfflineAreaRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      curOfflineArea = msg
    end
  end)
end

function _M.queryAllAreas(cb)
  Pomelo.OfflineAwardHandler.queryAllAreasRequest(function (ex,sjson)
    if not ex then
      local  msg = sjson:ToData()
      allAreasDate = msg.s2c_areasDetail
      if bAward.areaId ~= 0 then
        getCurrentOfflineArea()
      else
        curOfflineArea = {}
      end
      cb()
    end
  end)
end

local function queryOfflineAward(cb)
  Pomelo.OfflineAwardHandler.queryOfflineAwardRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      offlineAward = msg.offlineAward
      cb()
    end
  end)
end

function _M.getOfflineAward(c2s_type,cb)
  Pomelo.OfflineAwardHandler.getOfflineAwardRequest(c2s_type,function (ex,sjson)
    if not ex then
      offlineAward = {}
      cb()
    end
  end)
end

function _M.setOfflineAreaId(c2s_areaId,cb)
  Pomelo.OfflineAwardHandler.setOfflineAreaIdRequest(c2s_areaId,function (ex,sjson)
    if not ex then
      getCurrentOfflineArea()
      cb()
    end
  end)
end

function _M.GetChooseMap()
  return chooseMap
end

function _M.SetChooseMap(map)
  chooseMap = map
end

function _M.GetCurOfflineArea()
  return curOfflineArea
end

function _M.GetAllAreasDate()
  return allAreasDate
end

function _M.GetOfflineAward()
  return offlineAward
end

function _M.InitNetWork()
  
  
end

local function offlineAwardUi ()
  if bAward then
    if bAward.flag == 1 then
      queryOfflineAward(function ()
        MenuMgr.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILVUpOfflineReward, 0)
        _M.queryAllAreas(function ()end)
      end)
    else
      offlineAward = {}
      _M.queryAllAreas(function ()end)
    end
  end
end

function _M.initial()
  print("OFFLINEdeta initial") 
  EventManager.Subscribe("Event.Scene.FirstInitFinish", offlineAwardUi)
  bAward = Player.GetBindPlayerData().offlineBaseData
end

return _M
