local _M = {}
_M.__index = _M
local cjson = require "cjson" 
local Util      = require "Zeus.Logic.Util"
local Relive = require "Zeus.Model.Relive"

local memberInfo = {}
local joinTime = nil
local memberIndexInfo = {}

function _M.getJoinTime()
    return joinTime
end

function _M.getMemberIndexInfo(id)
  return memberIndexInfo[id]
end


function _M.request5v5Info(cb)
	Pomelo.Five2FiveHandler.five2FiveRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      if param.five2FiveMatchTime~=nil and param.five2FiveMatchTime.matchTime ~= 0 then
        joinTime = param.five2FiveMatchTime
      else
        joinTime = nil
      end
      cb(param)
    end
  end)
end

function _M.requestRecordList(cb)
	Pomelo.Five2FiveHandler.five2FiveLookBtlReportRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.requestMatch(t,cb,failcb)
	Pomelo.Five2FiveHandler.five2FiveMatchRequest(t,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      
      cb(param.five2FiveMatchTime)
    else
      if failcb then
        failcb()
      end
    end
  end)
end

function _M.requestCancleMatch(cb)
  
  Pomelo.Five2FiveHandler.five2FiveCancelMatchRequest(function(ex,sjson)
    if not ex then
      print("CancelMatch")
      EventManager.Fire("Event.Hud.hidePvpWait",{})
      GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.SOLO, "cancelEnter"))
      cb()
    end
  end)
end

function _M.requestAgreeMatch(cb)
  Pomelo.Five2FiveHandler.five2FiveAgreeMatchRequest(function(ex,sjson)
    if not ex then
      cb()
    end
  end)
end

function _M.requestRefuseMatch(cb)
  Pomelo.Five2FiveHandler.five2FiveRefuseMatchRequest(function(ex,sjson)
    if not ex then
      cb()
    end
  end)
end

function _M.requestTodayReward(cb)
    Pomelo.Five2FiveHandler.five2FiveReciveRewardRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb()
    end
  end)
end

function _M.requestGiveUp(tempTeamId,cb)
    Pomelo.Five2FiveHandler.five2FiveGiveUpRequest(tempTeamId,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb()
    end
  end)
end

function _M.requestReady(tempTeamId,cb)
    Pomelo.Five2FiveHandler.five2FiveReadyRequest(tempTeamId,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb()
    end
  end)
end

function _M.requestLeaveArea(cb)
  Pomelo.Five2FiveHandler.five2FiveLeaveAreaRequest(function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb()
    end
  end)
end

function _M.requestLookMatchResult(matchResultId,cb)
  Pomelo.Five2FiveHandler.five2FiveLookMatchResultRequest(matchResultId,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb(param)
    end
  end)
end

function _M.requestShardMatchResult(matchResultId,cb)
  Pomelo.Five2FiveHandler.five2FiveShardMatchResultRequest(matchResultId,function(ex,sjson)
    if not ex then
      local param = sjson:ToData()
      cb()
    end
  end)
end

function _M.getMemberInfo()
  return memberInfo
end

function GlobalHooks.DynamicPushs.OnApplyMatchPush(ex, json)
  if ex == nil then
    local param = json:ToData()
    

    
    
    
    

    local fun = nil
    fun = function ( ... )
      if(param ~= nil)then
        local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Ready)
        if obj==nil then
          menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUI5V5Ready,-1)
        end
        obj:setInfo(param.five2FiveMatchMemberInfo,param.waitResponseTimeSec)
      end
      EventManager.Unsubscribe("Event.Scene.ChangeFinish", fun)
    end

    if GameSceneMgr.Instance.BattleRun and GameSceneMgr.Instance.BattleRun.InitSceneOk then
      fun()
    else
      EventManager.Subscribe("Event.Scene.ChangeFinish", fun)
    end
    
    
    
    
  end
end

function GlobalHooks.DynamicPushs.OnMatchMemberInfoPush(ex, json)
  if ex == nil then
    local param = json:ToData()
    
    
    local enmeyTeam = nil
    if(param ~= nil)then
      for i,v in ipairs(param.matchTeamInfoA) do
        memberIndexInfo[v.playerId] = v
        if v.playerId == DataMgr.Instance.UserData.RoleID then
          memberInfo = param.matchTeamInfoA
          enmeyTeam = param.matchTeamInfoB
        end
      end

      for i,v in ipairs(param.matchTeamInfoB) do
        memberIndexInfo[v.playerId] = v
        if v.playerId == DataMgr.Instance.UserData.RoleID then
          memberInfo = param.matchTeamInfoB
          enmeyTeam = param.matchTeamInfoA
        end
      end

      local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUI5V5WaitEnter)
      obj:setInfo(memberInfo,enmeyTeam,param.waitResponseTimeSec,param.tempTeamId)

      local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Main)
      if obj then
        obj:matchStop()
      end
      EventManager.Fire("Event.Hud.stopPvpWait",{})
    end
  end
end

function GlobalHooks.DynamicPushs.OnMemberChoicePush(ex, json)
    if ex == nil then
    local param = json:ToData()
    
    if(param ~= nil)then
      local state = param.choice==1 and 3 or 2
      if param.agreeOrReady == 1 then
        local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Ready)
        if obj then
          obj:setTeamerState(param.playerId,state)
        end
      elseif param.agreeOrReady == 2 then
        local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5WaitEnter)
        if obj then
          obj:setTeamerState(param.playerId,state)
        end
      end
    end
  end
end

function GlobalHooks.DynamicPushs.OnMatchResultPush(ex, json)
  if ex == nil then
    local param = json:ToData()
    
    
    if(param ~= nil)then
      EventManager.Fire("Event.Hud.showPvpWait",{waitNum = "--",startTime = param.five2FiveMatchTime.matchTime})
      local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Main)
      if obj then
        obj:reMatch(param.five2FiveMatchTime.avgWaitTime,param.five2FiveMatchTime.matchTime)
      end
    end
  end
end

function GlobalHooks.DynamicPushs.OnMatchFailedPush(ex, json)
    if ex == nil then
    local param = json:ToData()
    
    if(param ~= nil)then
      GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.SOLO, "cancelEnter"))
      EventManager.Fire("Event.Hud.hidePvpWait",{})
      local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Main)
      if obj then
        if param.avgWaitTime ~= nil and param.startMatchTime ~= nil then
          obj:reMatch(param.avgWaitTime,param.startMatchTime)
        else
          obj:matchStop()
        end
      end

    end
  end
end

function GlobalHooks.DynamicPushs.OnGameEndPush(ex, json)
    if ex == nil then
    local param = json:ToData()
    
    if(param ~= nil)then
        local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUI5V5Result)
        if obj then
          obj:setBattleInfo(param)      
        end
    end
  end
end














function GlobalHooks.DynamicPushs.OnCancelMatchPush(ex, json)
  if ex == nil then
    EventManager.Fire("Event.Hud.hidePvpWait",{})
            
    GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.SOLO, "cancelEnter"))
    local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Main)
      if obj then
        obj:matchStop()
      end
    EventManager.Fire("Event.Hud.hidePvpWait",{})
  end
end

local isShowTeamChangeDialog = false
function GlobalHooks.DynamicPushs.OnTeamChangePush(ex, json)
  if ex == nil then
    local txt = Util.GetText(TextConfig.Type.SOLO, 'out5v5')
    local reMatch = Util.GetText(TextConfig.Type.SOLO, 'reMatch')
    local continueMatch = Util.GetText(TextConfig.Type.SOLO, 'continueMatch')
    local title = Util.GetText(TextConfig.Type.SOLO, 'title')
    if DataMgr.Instance.TeamData:IsLeader() then
      if not isShowTeamChangeDialog then
        isShowTeamChangeDialog = true
        GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL,
                txt,continueMatch,reMatch,title,nil,
                function()
                    isShowTeamChangeDialog = false
                end,
                function() 
                  isShowTeamChangeDialog = false
                  _M.requestMatch(2,function (data)
                    if data ~= nil then
                      local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Main)
                      if obj~=nil then
                        obj:reMatch(data.avgWaitTime,data.matchTime)
                      end
                    end
                  end)
                end
                )
      end
    else

    end
  end
end

function GlobalHooks.DynamicPushs.OnMatchNumPush(ex, json)
  if ex == nil then
    local param = json:ToData()
    local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUI5V5Main)
    if obj~=nil then
      obj:waitNum(param.pre_number)
    end
    EventManager.Fire("Event.Hud.showPvpWait",{waitNum = param.pre_number})
  end
end

function _M.InitNetWork()
    Pomelo.Five2FiveHandler.five2FiveApplyMatchPush(GlobalHooks.DynamicPushs.OnApplyMatchPush)
    Pomelo.Five2FiveHandler.five2FiveMatchMemberInfoPush(GlobalHooks.DynamicPushs.OnMatchMemberInfoPush)
    Pomelo.Five2FiveHandler.five2FiveMemberChoicePush(GlobalHooks.DynamicPushs.OnMemberChoicePush)
    Pomelo.Five2FiveHandler.five2FiveMatchFailedPush(GlobalHooks.DynamicPushs.OnMatchFailedPush)
    Pomelo.Five2FiveHandler.five2FiveOnGameEndPush(GlobalHooks.DynamicPushs.OnGameEndPush)
    
    Pomelo.Five2FiveHandler.five2FiveLeaderCancelMatchPush(GlobalHooks.DynamicPushs.OnCancelMatchPush)
    Pomelo.Five2FiveHandler.five2FiveApplyMatchResultPush(GlobalHooks.DynamicPushs.OnMatchResultPush)
    Pomelo.Five2FiveHandler.five2FiveTeamChangePush(GlobalHooks.DynamicPushs.OnTeamChangePush)
    Pomelo.Five2FiveHandler.five2FiveMatchPoolChangePush(GlobalHooks.DynamicPushs.OnMatchNumPush)
end


return _M
