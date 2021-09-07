DailyTaskFbData = DailyTaskFbData or BaseClass()

DailyTaskFbData.FB_TYPE = {
	SCORE = 1,
	STATUE = 2,
	DAZHAO = 3,
	XIXUE = 4,
	SHENZHU = 5,
}

function DailyTaskFbData:__init()
	if DailyTaskFbData.Instance then
		print_error("[DailyTaskFbData] Attempt to create singleton twice!")
		return
	end
	DailyTaskFbData.Instance = self
	local dailytaskfbconfig_auto = ConfigManager.Instance:GetAutoConfig("dailytaskfbconfig_auto")
	self.fb_cfg = ListToMapList(dailytaskfbconfig_auto.fb_cfg, "branch_fb_type")
	self.fb_cfg2 = ListToMapList(dailytaskfbconfig_auto.fb_cfg, "scene_id")

	self.taskreward_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("tasklist_auto").daily_task_reward, "level")
end

function DailyTaskFbData:__delete()
	DailyTaskFbData.Instance = nil
end

function DailyTaskFbData:GetFbCfg(branch_fb_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if self.fb_cfg[branch_fb_type] then
		for k,v in pairs(self.fb_cfg[branch_fb_type]) do
			if level <= v.max_level and level >= v.min_level then
				return v
			end
		end
	end
	return nil
end

function DailyTaskFbData:GetFbCfg2(scene_id)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if self.fb_cfg2[scene_id] then
		for k,v in pairs(self.fb_cfg2[scene_id]) do
			if level <= v.max_level and level >= v.min_level then
				return v
			end
		end
	end
	return nil
end

function DailyTaskFbData:DayRiChangFbCfg()
	local dailyfb_cfg = FuBenData.Instance:GetExpFBCfg().task
	local vo_camp = GameVoManager.Instance:GetMainRoleVo().camp
	local scene_id = Scene.Instance:GetSceneId()
	local monster_id = ""
	for k,v in pairs(dailyfb_cfg) do
		if vo_camp == v.camp_type and scene_id == v.scene_id then
			monster_id = v.monster_id
		end
	end
	return monster_id
end

function DailyTaskFbData:DayRiChangFbMonsterNum()
	local dailyfb_cfg = FuBenData.Instance:GetExpFBCfg().task
	local vo_camp = GameVoManager.Instance:GetMainRoleVo().camp
	local scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(dailyfb_cfg) do
		if vo_camp == v.camp_type and scene_id == v.scene_id then
			return v.monster_num
		end
	end
end


function DailyTaskFbData:DayRiChangFbReward()
	local vo_level = GameVoManager.Instance:GetMainRoleVo().level
	local result_task = self.taskreward_cfg[vo_level]
	if result_task then
		return result_task.exp , result_task.guild_gongxian_reward
	end
end
