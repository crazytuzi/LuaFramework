module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------
function i3k_sbean.sync_battle_maze()
	local bean = i3k_sbean.maze_sync_req:new()
	i3k_game_send_str_cmd(bean, "maze_sync_res")
end

--打开天魔迷宫界面信息
function i3k_sbean.maze_sync_res.handler(res)
	--self.dayEnterTimes:		int32
	--self.lastJoinTime:		int32
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadbattlemaze", res)
end

function i3k_sbean.join_battle_maze()
	local data = i3k_sbean.maze_join_req.new()
	i3k_game_send_str_cmd(data, "maze_join_res")
end

--参加天魔迷宫
function i3k_sbean.maze_join_res.handler(bean)
	if bean.ok > 0 then
		local cfg = i3k_db_schedule.cfg
		local mapID = g_SCHEDULE_COMMON_MAPID
		
		for _, v in ipairs(cfg or {}) do
			if v.typeNum == g_SCHEDULE_TYPE_MZAE_BATTLE then
				mapID = v.mapID
				break
			end
		end
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_MZAE_BATTLE, mapID)
	end
end

--进入地图(重连)同步信息
function i3k_sbean.role_maze_sync.handler(bean)
	--self.curZoneID:		int32	
	--self.startTime:		int32	
	--self.transferItemCnt:		int32	
	--self.zoneMineralTimes:		int32
	--totalExp
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:SetDigStatus(0)
		hero:Play(i3k_db_common.engine.defaultStandAction, -1);
	end
	g_i3k_game_context:setBattleMazeData(bean)
	local mazeData = g_i3k_game_context:getBattleMazeData()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_MazeBattleInfo, "setTntNumText", mazeData)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_MazeBattleInfo, "setMiningNumText", mazeData)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_MazeBattleInfo, "refreshTotalExp", mazeData)
	local world = i3k_game_get_world()

	if world then
		world:SetStartTime(bean.startTime)
	end
end

function i3k_sbean.enter_maze_Transfer(transferID)
	local data = i3k_sbean.maze_transfer_req.new()
	data.transferID = transferID
	i3k_game_send_str_cmd(data, "maze_transfer_res")
end

--进入传送阵
function i3k_sbean.maze_transfer_res.handler(bean, req)
	if bean.ok > 0 then		
	end
end

function i3k_sbean.sync_maze_commongain(showType)
	local data = i3k_sbean.maze_commongain_req.new()
	data.showType = showType
	i3k_game_send_str_cmd(data, "maze_commongain_res")
end

--同步当前收益
function i3k_sbean.maze_commongain_res.handler(res, req)
	--self.items:		map[int32, int32]
	g_i3k_ui_mgr:OpenUI(eUIID_MazeBattleBenifit)
	g_i3k_ui_mgr:RefreshUI(eUIID_MazeBattleBenifit, res.items)
end

function i3k_sbean.sync_maze_extragain(showType)
	local data = i3k_sbean.maze_extragain_req.new()
	data.showType = showType
	i3k_game_send_str_cmd(data, "maze_extragain_res")
end

--同步额外收益
function i3k_sbean.maze_extragain_res.handler(res, req)
	--self.items:		map[int32, int32]
	if not g_i3k_ui_mgr:GetUI(eUIID_MazeBattleBenifit) then 
	g_i3k_ui_mgr:OpenUI(eUIID_MazeBattleBenifit)
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_MazeBattleBenifit, res.items)
end

--添加传送道具数量
function i3k_sbean.maze_transfer_item_add.handler(res)
	--self.add:		int32
	if res.add > 0 then
		g_i3k_game_context:refeshBattleMazeTransfercount(res.add)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17752, res.add))
	end
end

--通知天魔迷宫开始
function i3k_sbean.role_maze_start.handler(res)
	--self.firstEnter:		int32
end

--通知天魔迷宫结束
function i3k_sbean.role_maze_end.handler(res)
end

function i3k_sbean.maze_sync_trig_event.handler(res)
	--self.eventType:		int32	
	--self.param:		int32	
	
	if res.eventType > 0 then
		local str = 
		{
			[1] = i3k_get_string(17753),
			[3] = i3k_get_string(17754),
		}
		
		if str[res.eventType] then
			g_i3k_ui_mgr:PopupTipMessage(str[res.eventType])
		end	
	end
end

function i3k_sbean.maze_sync_kill_times.handler(res)
	g_i3k_game_context:setBattleMazekillTimes(res.times)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_MazeBattleBenifit, "refreshTies")
end
