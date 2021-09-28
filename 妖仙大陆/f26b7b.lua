

local _M = {}
_M.__index = _M

local LeaderBoardModel = require 'Zeus.Model.Leaderboard' 

function _M.RequestArenaReward(reward_type,cb)
	Pomelo.ArenaHandler.arenaRewardRequest(reward_type, function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end

function _M.RequestEnterArenaArea(cb)
	Pomelo.ArenaHandler.enterArenaAreaRequest(function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end

function _M.RequestLeaveArenaArea(cb)
	Pomelo.ArenaHandler.leaveArenaAreaRequest(function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end

function _M.RequestArenaRankList(cb)
	LeaderBoardModel.RequestLeaderBoard(LeaderBoardModel.LBType.ARENA,cb)
end


function _M.RequetArenaInfo(cb)
	Pomelo.ArenaHandler.arenaInfoRequest(function (ex,sjson)
		if not ex and cb then
			local params = sjson:ToData()
			
			cb(params)
		end
	end)
end

function GlobalHooks.DynamicPushs.OnArenaBattleInfoPush(ex,sjson)
  if not ex then

  	local s2c_areaStartTime = (_M.battleData and _M.battleData.s2c_areaStartTime) or nil
    local data = sjson:ToData()
    local lastKillCount = (_M.battleData and _M.battleData.s2c_killCount) or nil
    if lastKillCount and data.s2c_killCount > lastKillCount then
    	
      GlobalHooks.Drama.Stop('arena_effect')
      GlobalHooks.Drama.Start('arena_effect',data.s2c_killCount)
    end
    _M.battleData = data
    _M.battleData.s2c_areaStartTime = s2c_areaStartTime
    
    
     print('OnArenaBattleInfoPush',PrintTable(_M.battleData))
    EventManager.Fire("Event.Arena.UpdateBattleInfo",{})
  end 	
end










function GlobalHooks.DynamicPushs.OnArenaBattleEndPush(ex,sjson)
  if not ex then
  	local param = sjson:ToData()
    
    _M.battleData.endTime = param.outtime
    
    EventManager.Fire('Event.Arena.CloseShowHud',{})
    EventManager.Fire('Event.ShowArenaEnd',{})
  end 
end

function _M.InitNetWork()
	Pomelo.GameSocket.onArenaBattleInfoPush(GlobalHooks.DynamicPushs.OnArenaBattleInfoPush)	
	
	Pomelo.GameSocket.onArenaBattleEndPush(GlobalHooks.DynamicPushs.OnArenaBattleEndPush)
end


return _M
