------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel");

-----------------------------------

local ErrorCode = {
	
}

--错误码提示
local function ErrorCodeTips(result)
	if ErrorCode[result] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(ErrorCode[result]))
	end
end

--同步密探风云信息
function i3k_sbean.role_spy_world.handler(bean)
	--self.roleSpyWorld:		DBRoleSpyWorld	
	g_i3k_game_context:setSpyStoryInfo(bean.roleSpyWorld)
end

--密探风云副本开始
function i3k_sbean.role_spy_world_map_start.handler(bean)
	--self.campType:		int32
	local mapID = g_SCHEDULE_COMMON_MAPID
	for k, v in ipairs(i3k_db_schedule.cfg) do
		if v.typeNum == g_SCHEDULE_TYPE_SPY_STORY then
	
			mapID = v.mapID
			break
end


end
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SPY_STORY, mapID)
	g_i3k_game_context:addSpyStoryDayEnterTimes()
		
end

--副本结束
function i3k_sbean.role_spy_world_map_end.handler(bean)
	
end

--密探风云信息进入同步
function i3k_sbean.spy_world_map_info.handler(bean)
	--self.tasks:		map[int32, int32]	
	--self.score:		int32	
	--self.alterID:		int32	
	g_i3k_game_context:setSpyStoryTasks(bean.tasks)
	g_i3k_game_context:setSpyStoryScore(bean.score)
	g_i3k_game_context:setSpyStoryTransformId(bean.alterID)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpyStoryTask)
end

--同步任务
function i3k_sbean.spy_world_update_task.handler(bean)
	--self.taskID:		int32	
	--self.taskValue:		int32	
	g_i3k_game_context:updateSpyStoryTaskInfo(bean.taskID, bean.taskValue)
end

--同步积分
function i3k_sbean.spy_world_add_score.handler(bean)
	--self.add:		int32	
	local score = g_i3k_game_context:getSpyStoryScore()
	g_i3k_game_context:setSpyStoryScore(bean.add + score)
	g_i3k_game_context:addSpyStoryDayScore(bean.add)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpyStoryTask)
end

--每日奖励
function i3k_sbean.spy_world_day_reward(index)
	--self.score:		int32
	local data = i3k_sbean.spy_world_day_reward_req.new()
	data.score = i3k_db_spy_story_reward[1][index].score
	data.index = index
	i3k_game_send_str_cmd(data, "spy_world_day_reward_res")
end

function i3k_sbean.spy_world_day_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(res.items)
		g_i3k_game_context:takeSpyStoryDayReward(req.index)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpyStory)
	end
end

--密探风云活动奖励
function i3k_sbean.spy_world_activity_reward(index)
	--self.finishCnt:		int32
	local data = i3k_sbean.spy_world_activity_reward_req.new()
	data.finishCnt = i3k_db_spy_story_reward[2][index].score
	data.index = index
	i3k_game_send_str_cmd(data, "spy_world_activity_reward_res")
end

function i3k_sbean.spy_world_activity_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(res.items)
		g_i3k_game_context:takeSpyStoryActivityReward(req.index)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpyStory)
	end
end
	
--变箱子
function i3k_sbean.spy_world_alter(id)
	local data = i3k_sbean.spy_world_alter_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "spy_world_alter_res")
end
function i3k_sbean.spy_world_alter_res.handler(bean, req)
	if bean.ok > 0 then
		local hero = i3k_game_get_player_hero()
		hero:MissionMode(true, req.id, 0)
		local count = g_i3k_game_context:getSpyStoryTransformTimes()
		g_i3k_game_context:setSpyStoryTransformTimes(count + 1)
		g_i3k_game_context:setSpyStoryTransformId(1)
		g_i3k_game_context:ClearFindWayStatus()
	end
end
--取消
function i3k_sbean.spy_world_alter_quit()
	local data = i3k_sbean.spy_world_alter_quit_req.new()
	i3k_game_send_str_cmd(data, "spy_world_alter_quit_res")
end
function i3k_sbean.spy_world_alter_quit_res.handler(bean)
	if bean.ok > 0 then
		local hero = i3k_game_get_player_hero()
		hero:MissionMode(false)
		g_i3k_game_context:setSpyStoryTransformId(0)
	end
end
--同步阵营
function i3k_sbean.sync_spy_world.handler(bean)
	--self.campType:		int32
	--self.useAlterCount:		int32
	local world = i3k_game_get_world();
	local player = i3k_game_get_player()
	local hero = i3k_game_get_player_hero()
	g_i3k_game_context:setSpyStoryCampType(bean.campType)
	if player and not hero._inSpyStory then
		local id =  hero._id
		world:OnPlayerEnterWorld(nil);
		player:SetSpyEntity(bean.campType, id)
		world:OnPlayerEnterWorld(player);
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleBase)
	end
	g_i3k_game_context:setCameraAngle(bean.campType)
	g_i3k_game_context:setSpyStoryTransformTimes(bean.useAlterCount)
end
