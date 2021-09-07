RobertMgr = RobertMgr or BaseClass()
require("game/story/auto_robert")
-- 自动跑任务机器人管理系统
function RobertMgr:__init()
	if RobertMgr.Instance ~= nil then
		ErrorLog("[RobertMgr] attempt to create singleton twice!")
		return
	end

	RobertMgr.Instance = self

	self.is_open_robert_system = true					-- 是否关启机器人系统
	self.need_role_min_level = 1 						-- 开启需要人物最低等级
	self.need_role_max_level = 80						-- 开启需要人物最高等级

	self.max_history_pos_num = 10 						-- 主角行走位置的历史最大记录数量（机器人将从这些历史位置随机产生）
	self.record_role_pos_quency = 1 					-- 主角行走的记录频率

	self.max_robert_num = 4								-- 同时存在当前地图的最大机器人数量
	self.check_del_robert_quency = 2 					-- 检查移除机器人的频率（机器人到目标点或离开角色自己太远将移除）
	self.check_roundrobert_born_quency = 2 				-- 检查周围机器人出生频率

	self.wuqi_id_list = {8100, 8200, 8300, 8400} 		-- 机器人武器列表（1-4职业）
	self.mount_appeid = 1 								-- 机器人坐骑形象（主角骑着时才显示）
	self.mount_speed = 2340								-- 机器人坐骑速度
	self.role_speed = 2140								-- 人的速度

	self.obj_id_inc = 100000

	self.now_time = 0
	self.last_record_role_pos_time = 0
	self.last_check_born_time = 0
	self.last_check_del_robert_time = 0

	self.last_check_round_time = 0
	self.last_born_round_time = 0
	self.last_task_round_time = 0

	self.role_history_pos_list = {}
	self.robert_t_list = {}

	self.is_shield_all_robert = false					--是否隐藏所有机器人

	self.change_scene = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind1(self.OnSceneChangeComplete, self))
	self.loding_comple = GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnLoadingComplete, self))
end

function RobertMgr:__delete()
	GlobalEventSystem:UnBind(self.change_scene)
	GlobalEventSystem:UnBind(self.loding_comple)
	Runner.Instance:RemoveRunObj(self)
	self:ClearAllRober()

	RobertMgr.Instance = nil
end

function RobertMgr:OnSceneChangeComplete()
	self.last_record_role_pos_time = 0
	self.last_check_born_time = 0
	self.last_check_del_robert_time = 0
	self.last_check_round_time = 0
	self.last_task_round_time = 0
	self.last_born_round_time = 0
	self.role_history_pos_list = {}

	self:ClearAllRober()
end

function RobertMgr:OnLoadingComplete()
	Runner.Instance:AddRunObj(self, 8)
end

function RobertMgr:Update(now_time, elapse_time)
	self.now_time = now_time

	if not self.is_open_robert_system then
		return
	end
	if GameVoManager.Instance:GetMainRoleVo().level >= self.need_role_min_level and GameVoManager.Instance:GetMainRoleVo().level <= self.need_role_max_level then
		-- 检查创建任务机器人
		if now_time >= self.last_task_round_time then
			self.last_task_round_time = now_time + self.check_roundrobert_born_quency

			if not SettingData.Instance:IsShieldOtherRole(Scene.Instance:GetSceneId()) then
				self:CheckBornTaskRobert()
			end
		end

		-- 记录主角位置
		if now_time >= self.last_record_role_pos_time then
			self.last_record_role_pos_time = now_time + self.record_role_pos_quency
			self:RecordRolePos()
		end
	else
		if #self.robert_t_list <= 0 then
			Runner.Instance:RemoveRunObj(self)
		end
	end

	-- 检查删除
	if 0 < #self.robert_t_list and now_time >= self.last_check_del_robert_time then
		self.last_check_del_robert_time = now_time + self.check_del_robert_quency
		self:CheckRemoveRobert()
	end

	for k,v in pairs(self.robert_t_list) do
		if v.obj then
			v.obj:Update(now_time, elapse_time)
		end
	end
end

function RobertMgr:RecordRolePos()
	-- 跳跃时不记录

	if Scene.Instance:GetMainRole():IsJump() or Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 or
		Scene.Instance:GetMainRole().vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP then
		return
	end

	local role_x, role_y = Scene.Instance:GetMainRole():GetLogicPos()
	role_x = tonumber(role_x)
	role_y = tonumber(role_y)

	if AStarFindWay:IsBlock(role_x, role_y) then
		return
	end

	local end_t = self.role_history_pos_list[#self.role_history_pos_list]
	if nil ~= end_t then
		local distance = GameMath.GetDistance(role_x, role_y, end_t.logic_x,  end_t.logic_y, false)
		if distance < 10 * 10 then
			return
		end
	end

	if role_x < 0 or role_y < 0 then
		return
	end

	if #self.role_history_pos_list >= self.max_history_pos_num then
		table.remove(self.role_history_pos_list, 1)
	end

	local t = {}
	t.logic_x = role_x
	t.logic_y = role_y
	t.scene_id = Scene.Instance:GetSceneId()
	table.insert(self.role_history_pos_list, t)
end

function RobertMgr:BornRobert(born_x, born_y, target_pos_list)
	if (born_x and born_x <= 0) or (born_y and born_y <= 0) then
		return false
	end

	if nil == target_pos_list or #target_pos_list <= 0 then
		return false
	end
	self.obj_id_inc = self.obj_id_inc + 1
	local role_vo = GameVoManager.Instance:CreateVo(RoleVo)
	role_vo.role_id = 99999
	role_vo.obj_id = self.obj_id_inc
	role_vo.level = PlayerData.Instance.role_vo.level
	role_vo.pos_x = born_x
	role_vo.pos_y = born_y
	role_vo.hp = PlayerData.Instance.role_vo.max_hp
	role_vo.max_hp = PlayerData.Instance.role_vo.max_hp

	role_vo.prof = math.random(1, 4)
	-- 性别由职业而定
	role_vo.sex = PlayerData.Instance:GetSexByProf(role_vo.prof)
	role_vo.name = self:GetRandomName(role_vo.sex)
	role_vo.appearance = TableCopy(PlayerData.Instance:GetRoleVo().appearance)
	role_vo.appearance.wuqi_id = 1
	role_vo.appearance.wing_used_imageid = 0
	role_vo.appearance.mount_used_imageid = 0
	role_vo.appearance.halo_used_imageid = 0
	role_vo.beauty_used_seq = -1

	local has_mount = false
	if PlayerData.Instance.role_vo.mount_appeid > 0 then
		has_mount = (math.random(100)) <= 50 and true or false
	end

	if has_mount then
		role_vo.mount_appeid = self.mount_appeid
		role_vo.move_speed = self.mount_speed
		role_vo.base_move_speed = self.mount_speed
	else
		role_vo.mount_appeid = 0
		role_vo.move_speed = self.role_speed
		role_vo.base_move_speed = self.role_speed
	end

	local robert = AutoRobert.New(role_vo)
	robert:Init(Scene.Instance)
	local t = {}
	t.end_x = target_pos_list[#target_pos_list].x
	t.end_y = target_pos_list[#target_pos_list].y
	t.scene_id = Scene.Instance:GetSceneId()
	t.obj_id = role_vo.obj_id
	t.obj = robert
	table.insert(self.robert_t_list, t)
	robert:DoStand()
	robert:SetFollowLocalPosition(0)

	--判断是否隐藏机器人
	if self.is_shield_all_robert then
		robert:GetDrawObj():SetVisible(false)
	else
		robert:GetDrawObj():SetVisible(true)
	end
	robert:StartMoveByTargetPosList(target_pos_list)

	-- 屏蔽机器人技能特效
	local main_part = robert.draw_obj:GetPart(SceneObjPart.Main)
	local shield_skill_effect = SettingData.Instance:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
	main_part:EnableEffect(not shield_skill_effect)
	main_part:EnableFootsteps(not shield_skill_effect)
	
	return true
end

function RobertMgr:GetRolePos()
	local role_x, role_y = Scene.Instance:GetMainRole():GetLogicPos()

	return tonumber(role_x), tonumber(role_y)
end

-- 计算跟踪机器人出生位置
function RobertMgr:CalcFollowRobertBornPos()
	local pos_num = #self.role_history_pos_list
	if pos_num <= 3 then
		return 0, 0
	end

	local role_x, role_y = self:GetRolePos()

	local loop = 0
	local max_loop = 250

	while loop < max_loop do
		loop = loop + 1

		local rand_index = math.random(1, #self.role_history_pos_list)
		local t = self.role_history_pos_list[rand_index]
		local distance = GameMath.GetDistance(role_x, role_y, t.logic_x, t.logic_y, false)
		if t.scene_id == Scene.Instance:GetSceneId() and distance >= 30 * 30 then
			return t.logic_x, t.logic_y
		end
	end

	return 0, 0
end

-- 创建跟踪角色任务的机器人
function RobertMgr:CheckBornTaskRobert()
	if #self.robert_t_list >= self.max_robert_num or
		#self.role_history_pos_list < 3 or
		Scene.Instance:GetSceneType() ~= SceneType.Common then
		return
	end
	self.check_roundrobert_born_quency = math.floor(math.random(1, 2))
	local born_x, born_y = self:CalcFollowRobertBornPos()

	local target_pos_list = self:CalcTaskRobertTargetPosList()

	local pos_x, pos_y = self:CalcSceneDoorPos()
	if pos_x > 0 and pos_y > 0 then
		table.insert(target_pos_list, {x = pos_x, y = pos_y, is_monster_task = false})
	end
	self:BornRobert(born_x, born_y, target_pos_list)
end

function RobertMgr:CalcTaskRobertTargetPosList()
	-- 获取当前主线任务id
	local cur_task_id = 0
	local now_cfg = TaskData.Instance:GetNextZhuTaskConfig()

	if now_cfg then
		cur_task_id = now_cfg.pretaskid
		if nil == cur_task_id or "" == cur_task_id then
			cur_task_id = now_cfg.task_id
		end
	end
	local target_pos_list = {}
	local cur_scene_id = Scene.Instance:GetSceneId()
	for i=1,10 do
		local cfg = TaskData.Instance:GetNextZhuTaskConfigById(cur_task_id)
		if nil == cfg then
			break
		end
		local npc_cfg = cfg.accept_npc
		if npc_cfg and npc_cfg.scene == cur_scene_id then
			table.insert(target_pos_list, {x = npc_cfg.x, y = npc_cfg.y, is_monster_task = false})
		end

		npc_cfg = cfg.commit_npc
		if npc_cfg and npc_cfg.scene == cur_scene_id then
			table.insert(target_pos_list, {x = npc_cfg.x, y = npc_cfg.y, is_monster_task = false})
		end

		npc_cfg = cfg.target_obj and cfg.target_obj[1] or nil
		if npc_cfg and npc_cfg.scene == cur_scene_id then
			local is_monster_task = false
			if cfg.condition == TASK_COMPLETE_CONDITION.KILL_MONSTER then
				is_monster_task = true
			end
			table.insert(target_pos_list, {x = npc_cfg.x, y = npc_cfg.y, is_monster_task = is_monster_task})
		end
		cur_task_id = cfg.task_id
	end
	return target_pos_list
end

-- 计算机器人要去的最后一个点, 即随机一个传送点
function RobertMgr:CalcSceneDoorPos()
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(Scene.Instance:GetSceneId())
	if nil == scene_cfg or nil == scene_cfg.doors then
		return 0, 0
	end

	local door_cfg = scene_cfg.doors[math.random(1, #scene_cfg.doors)]
	if nil == door_cfg then
		return 0, 0
	end

	return door_cfg.x, door_cfg.y
end

-- 检查机器人是否需要移除,以可以创建新的机器人
function RobertMgr:CheckRemoveRobert()
	local role_x, role_y = Scene.Instance:GetMainRole():GetLogicPos()
	role_x = tonumber(role_x)
	role_y = tonumber(role_y)

	local num = #self.robert_t_list
	for i = num, 1, -1 do
		local t = self.robert_t_list[i]
		local is_del = false
		local robert_obj = t.obj

		if nil ~= robert_obj then
			local now_logic_x, now_logic_y = robert_obj:GetLogicPos()
			local end_distance = GameMath.GetDistance(now_logic_x, now_logic_y, t.end_x, t.end_y, false)
			if end_distance <= 100 then  --到了目的地
				is_del = true
			end

			local distance = GameMath.GetDistance(role_x, role_y, now_logic_x, now_logic_y, false)

			if distance > 110 * 110 then  	-- 离主角太远
				is_del = true
			end

			if is_del then
				if nil ~= t.obj then
					t.obj:DeleteMe()
					t.obj = nil
				end
				-- Scene.Instance:DeleteClientObj(t.obj_id)
				table.remove(self.robert_t_list, i)
				-- print("-------->>>del robert", #self.robert_t_list)
			end
		end
	end
end

function RobertMgr:ClearAllRober()
	for k,v in pairs(self.robert_t_list) do
		if nil ~= v.obj then
			v.obj:DeleteMe()
			v.obj = nil
		end
	end

	self.robert_t_list = {}
	AutoRobert.path_cache = {}
end

--屏蔽所有机器人
function RobertMgr:ShieldAllRobert()
	self.is_shield_all_robert = true
	for _, v in pairs(self.robert_t_list) do
		if nil ~= v.obj then
			v.obj:GetDrawObj():SetVisible(false)
		end
	end
end

--显示所有机器人
function RobertMgr:UnShieldAllRobert()
	self.is_shield_all_robert = false
	for _, v in pairs(self.robert_t_list) do
		if nil ~= v.obj then
			v.obj:GetDrawObj():SetVisible(true)
		end
	end
end

--设置机器人技能特效
function RobertMgr:SetRobotsEffectEnable(enable)
	for _, v in pairs(self.robert_t_list) do
		if nil ~= v.obj then
			local main_part = v.obj:GetDrawObj():GetPart(SceneObjPart.Main)
			main_part:EnableEffect(enable)
			main_part:EnableFootsteps(enable)
		end
	end
end

function RobertMgr:GetRandomName(sex)
	local front = ""
	local middle = ""
	local back = ""
	local name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]

	local name_first_list = {}	-- 前缀
	local name_last_list = {}	-- 后缀
	if sex == GameEnum.FEMALE then
		name_first_list = name_cfg.female_first
		name_last_list = name_cfg.female_last
	else
		name_first_list = name_cfg.male_first
		name_last_list = name_cfg.male_last
	end
	local rand_num = math.floor(math.random(1, 200))
	local name_first_index = (rand_num % #name_first_list) + 1
	local name_last_index = (rand_num % #name_last_list) + 1
	local first_name = name_first_list[name_first_index] or ""
	local last_name = name_last_list[name_last_index] or ""
	local camp = PlayerData.Instance.role_vo.camp
	local camp = string.format(Language.Guild.RoberCampName, CAMP_COLOR[camp], Language.Guild.GuildCamp[camp])
	return camp .. first_name .. last_name
end