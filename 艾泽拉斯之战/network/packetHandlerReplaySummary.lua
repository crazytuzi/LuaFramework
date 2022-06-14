function ReplaySummaryHandler( replays )
	--[[
	
	
replays = {}
local data ={}
		-- 录像id
	data['id'] = 1
-- 玩家id
	data['playerID'] = 1
-- 玩家等级
	data['playerLevel'] =12
-- 玩家名字
 
		data['playerName'] = "闷骚的磊哥 ";
 
-- 胜利失败
	data['win'] = true
-- 排名变化
	data['rankChanged'] = 10
-- 战斗时间
	data['battleTime'] = dataManager.getServerTime()  - 60*60

	replays[1] = data
		local d = clone(data)
		-- 录像id
	d['id'] = 2
-- 玩家id
	d['playerID'] = 2
-- 玩家等级
	d['playerLevel'] =15
	d['win'] = false
		d['rankChanged'] = -5
	data['playerName'] = "风骚骚的伟哥 ";
	data['battleTime'] = dataManager.getServerTime()  - 5*60
		
	replays[2] = d
	
	--]]
	
	
	local num = #replays
	for i =1,num do		
		dataManager.pvpData:createPvpOfflineReplayRecord(replays[i],i)
	end	
	eventManager.dispatchEvent( {name  = global_event.PVPRECORD_UPDATE})
end
