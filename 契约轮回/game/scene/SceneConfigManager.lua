-- 
-- @Author: LaoY
-- @Date:   2018-09-03 14:32:42
--
SceneConfigManager = SceneConfigManager or class("SceneConfigManager",BaseManager)
local this = SceneConfigManager

SceneConfigManager.PkModeConfig = {
	[enum.PKMODE.PKMODE_PEACE] =
	{name = "Peace",des = "Attack monsters only",pkmode = enum.PKMODE.PKMODE_PEACE,
		res = "common_image:com_btn_2",b_l_res = "main_image:img_main_pattern_bg_1",
		tip = "You are under peace mode, your attack will deal no damage to players"},
	
	[enum.PKMODE.PKMODE_ALLY] =
	{name = "Forced Mode",des = "Attack anyone except teammates and guildmates",pkmode = enum.PKMODE.PKMODE_ALLY,
		res = "common_image:com_btn_3",b_l_res = "main_image:img_main_pattern_bg_2",
		tip = "You are under Forced Mode, you can now attack anyone except your teammates and guildmates"},
	
	[enum.PKMODE.PKMODE_WHOLE] =
	{name = "Attack Mode",des = "Attack anyone who is out of the safe zone",pkmode = enum.PKMODE.PKMODE_WHOLE,
		res = "common_image:com_btn_4",b_l_res = "main_image:img_main_pattern_bg_3",
		tip = "You are under Attack Mode. Your attack will deal damage to all players"},

	[enum.PKMODE.PKMODE_CROSS] =
	{name = "Cross-server",des = "Unable to attack players on the same server",pkmode = enum.PKMODE.PKMODE_CROSS,
		res = "common_image:com_btn_6",b_l_res = "main_image:img_main_pattern_bg_5",
		tip = "You are under Cross-server Mode You can only attack players from other servers"},

	[enum.PKMODE.PKMODE_ENEMY] =
	{name = "Hostile",des = "Attack players from hostile servers",pkmode = enum.PKMODE.PKMODE_ENEMY,
		res = "common_image:com_btn_5",b_l_res = "main_image:img_main_pattern_bg_4",
		tip = "You are under Hostile Mode. You can only attack players from other servers"},
	
	-- [enum.PKMODE.PKMODE_WHOLE] =
	-- {name = "守卫",des = "可以攻击同盟以外的入侵玩家",pkmode = enum.PKMODE.PKMODE_PEACE,
	-- res = "common_image:com_btn_2",b_l_res = "main_image:img_main_pattern_bg_4",
	-- tip = "你已经切换成守卫模式，可攻击入侵本服的玩家"},
	
	-- [enum.PKMODE.PKMODE_WHOLE] =
	-- {name = "入侵",des = "可以攻击入侵服务器玩家",pkmode = enum.PKMODE.PKMODE_PEACE,
	-- res = "common_image:com_btn_2",b_l_res = "main_image:img_main_pattern_bg_5",
	-- tip = "你已经切换成守卫模式，可攻击入侵服务器的玩家"},
}

function SceneConfigManager:ctor()
	SceneConfigManager.Instance = self
	
	--跳跃点处理
	self.jump_point_list = {}
	self.jump_way_path = {}
	self.jump_way_path_load_state = {}
	
	-- 保存每个场景对应传送目标列表
	self.scene_map = {}
	
	-- 当前的下载列表
	self.down_load_list = {}
	-- 当前的下载的场景ID
	self.cur_down_scene_id = nil
	-- 已经检查过的场景列表
	self.have_check_scene_list = {}
	
	-- self:CheckScenesConfig()

	self.last_check_lv = -10
	
	self:Reset()
	self:AddEvent()
end

function SceneConfigManager:Reset()
	
end

function SceneConfigManager.GetInstance()
	if SceneConfigManager.Instance == nil then
		SceneConfigManager()
	end
	return SceneConfigManager.Instance
end

function SceneConfigManager:AddEvent()
	self.global_event_list = self.global_event_list or {}
	local function call_back()
		local function step()
			self:CheckNextSceneRes()
		end
		GlobalSchedule:StartOnce(step,1.0)
		
		local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
		RefreshHotUpdateState(lv)
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.ChangeLevel, call_back)
	
	local function call_back()
		self:CheckNextSceneRes()
		MapLayer:GetInstance():OnLoadingDestroy()
	end
	self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(EventName.DestroyLoading, call_back)

	local function call_back()
		local function step()
			self:CheckDownLoadConfig(0)
		end
		GlobalSchedule:StartOnce(step,1.0)
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(LoginEvent.OpenLoginPanel, call_back)
	
	-- local function call_back()
	-- 	local function step()
	-- 		self:CheckDownLoadConfig(2)
	-- 	end
	-- 	GlobalSchedule:StartOnce(step,5.0)
	-- end
	-- self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.GameStart, call_back)


end

function SceneConfigManager:CheckDownLoadConfig(lv)
	local function call_back(abName)
		DebugLog('--LaoY SceneConfigManager.lua,line 92--',lv,abName)
	end
	local load_level = Constant.LoadResLevel.Down
	
	DebugLog('--LaoY SceneConfigManager.lua,line 102--',lv)
	for k,cf in pairs(Config.db_res_load) do
		if cf.lv <= lv then
			local abName = GetRealAssetPath(cf.name)
			-- if not lua_resMgr:IsInDownLoading(abName) and not lua_resMgr:IsInJumpList(abName) and lua_resMgr:IsInDownLoadList(abName) then
			if lua_resMgr:IsInDownLoadList(abName) then
				DebugLog('--LaoY SceneConfigManager.lua,line 109--',abName)
				lua_resMgr:AddDownLoadList(self, abName, call_back, load_level)
			end
		end
	end
end

--[[
function SceneConfigManager:CheckSceneRes(scene_id)
	local cf = self:GetSceneConfig(scene_id)
	if not cf then
		return
	end
	local check_list = {}
	check_list[#check_list+1] = "mapasset/mapcompres_" .. scene_id
	check_list[#check_list+1] = "mapasset/mapres_" .. scene_id
	for id,v in pairs(cf.Npcs) do
		local config = Config.db_npc[id]
		if config then
			check_list[#check_list+1] = config.figure
		end
	end
	
	for id,v in pairs(cf.Monsters) do
		local config = Config.db_creep[id];
		if config then
			local abName = config.figure
			if AppConfig.IsSupportGPU and config.GPU_res == 1 then
				abName = abName .. "_gpu"
			end
			check_list[#check_list+1] = abName
		end
	end
	
	self.down_load_list = {}
	for k,abName in pairs(check_list) do
		abName = GetRealAssetPath(abName)
		if not lua_resMgr:IsInDownLoading(abName) and not lua_resMgr:IsInJumpList(abName) and lua_resMgr:IsInDownLoadList(abName) then
			self.down_load_list[abName] = Time.time
		end
	end
	
	local function callBack(abName)
		if not self.down_load_list[abName] then
			return
		end
		local is_isempty = table.isempty(self.down_load_list)
		self.down_load_list[abName] = nil
		if is_isempty ~= table.isempty(self.down_load_list) then
			self:CheckNextSceneRes()
		end
	end
	
	local load_level = Constant.LoadResLevel.Down
	for abName,v in pairs(self.down_load_list) do
		lua_resMgr:AddDownLoadList(self, abName, callBack, load_level)
	end
end
--]]

function SceneConfigManager:CheckNextSceneRes()
	-- 没有需要静默下载的资源
	-- 检查完所有的
	if lua_resMgr.down_load_cur_count <= 0 or self.check_all_res then
		return
	end

	if LoadingCtrl:GetInstance().loadingPanel then
		return
	end

	local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
	if self.last_check_lv >= lv then
		return
	end

	local downAbList = {}
	local downSceneList = {}
	self.check_all_res = true
	for scene_id,cf in pairs(Config.db_scene) do
		if cf.down_load_lv > lv then
			self.check_all_res = false
		end
		if (lv >= cf.down_load_lv and cf.down_load_lv > self.last_check_lv) then
			downSceneList[#downSceneList+1] = {lv = cf.down_load_lv,scene_id = scene_id}
		end
	end

	for k,v in pairs(downSceneList) do
		local scene_id = v.scene_id
		local cf = self:GetSceneConfig(scene_id)
		if cf then
			local check_list = {}
			check_list[#check_list+1] = "mapasset/mapmask_" .. scene_id
			check_list[#check_list+1] = "mapasset/mapcompres_" .. scene_id
			check_list[#check_list+1] = "mapasset/mapres_" .. scene_id
			for id,v in pairs(cf.Npcs) do
				local config = Config.db_npc[id]
				if config then
					check_list[#check_list+1] = config.figure
				end
			end
			
			for id,v in pairs(cf.Monsters) do
				local config = Config.db_creep[id];
				if config then
					local abName = config.figure
					if AppConfig.IsSupportGPU and config.GPU_res == 1 then
						abName = abName .. "_gpu"
					end
					check_list[#check_list+1] = abName
				end
			end
			
			for k,abName in pairs(check_list) do
				abName = GetRealAssetPath(abName)
				if not lua_resMgr:IsInDownLoading(abName) and not lua_resMgr:IsInJumpList(abName) and lua_resMgr:IsInDownLoadList(abName) then
					downAbList[#downAbList+1] = {abName = abName,lv = v.lv,id = #downAbList}
				end
			end
		end
	end

	for k,cf in pairs(Config.db_res_load) do
		if cf.lv <= lv then
			local abName = GetRealAssetPath(cf.name)
			if not lua_resMgr:IsInDownLoading(abName) and not lua_resMgr:IsInJumpList(abName) and lua_resMgr:IsInDownLoadList(abName) then
				downAbList[#downAbList+1] = {abName = abName,lv = cf.lv,id = #downAbList}
			end
		else
			self.check_all_res = false
		end
	end

	self.last_check_lv = lv
	self:AddDownLoadList(downAbList)
end

function SceneConfigManager:AddDownLoadList(downAbList)
	if table.isempty(downAbList) then
		return
	end
	local function sortFunc(a,b)
		if a.lv == b.lv then
			return a.id < b.id
		else
			return a.lv < b.lv
		end
	end
	table.sort(downAbList,sortFunc)
	local len = #downAbList
	if AppConfig.writeLog then
		DebugManager.DebugLog("[config][add_download_list] count = %s,level = %s",len,self.last_check_lv)
		print('--LaoY SceneConfigManager.lua,line 257--')
		dump(downAbList,"downAbList")
	end

	local function callBack(abName)
		DebugManager.DebugLog("[config][download_success] abName = %s",abName)
	end
	local load_level = Constant.LoadResLevel.Down
	for i=1,len do
		local info = downAbList[i]
		local abName = info.abName
		lua_resMgr:AddDownLoadList(self, abName, callBack, load_level)
	end
end

function SceneConfigManager:GetSceneConfig(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	if not scene_id or scene_id == 0 then
		return nil
	end
	
	-- Yzprint('--LaoY SceneConfigManager.lua,line 160--',data)
	-- traceback()

	local status, err
	if not Config.Scenes or not Config.Scenes[scene_id] then
		local path = string.format("game/config/scene/%s",scene_id)
		if not package.loaded[path] then
			if old_require then
				-- old_require (path)
				status, err = pcall(old_require,path)
			else
				-- require (path)
				status, err = pcall(require,path)
			end
			if not status then
				if AppConfig.Debug then
					logError("==场景配置表报错：" .. err)
				end
				return nil
			end
		end
	end
	if not Config.Scenes then
		return nil
	end
	return Config.Scenes[scene_id]
end

function SceneConfigManager:GetDBSceneConfig(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	local config = Config.db_scene[scene_id]
	return config
end

function SceneConfigManager:GetSceneType(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	local config = self:GetDBSceneConfig(scene_id)
	if not config then
		return
	end
	return config.type
end

function SceneConfigManager:GetSceneNpcList(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	local config = self:GetSceneConfig(scene_id)
	if not config then
		return
	end
	local npc_list = {}
	local npc_data
	for k,v in pairs(config.Npcs) do
		npc_data = {
			uid = v.id,
			coord = {x=v.x,y=v.y},
			type = enum.ACTOR_TYPE.ACTOR_TYPE_NPC,
			gen_type = SceneConstant.DataType.Client,
		}
		npc_list[#npc_list+1] = npc_data
	end
	return npc_list
end

function SceneConfigManager:GetNpcPosition(target_scene_id,id)
	local scene_id = target_scene_id or SceneManager:GetInstance():GetSceneId();
	scene_id = scene_id ~= 0 and scene_id or SceneManager:GetInstance():GetSceneId();--@杨紫回来看一下
	local config = self:GetSceneConfig(scene_id)
	if not config then
		return
	end
	for k,v in pairs(config.Npcs) do
		if id == v.id then
			return {x=v.x,y=v.y}
		end
	end
	return nil
end

function SceneConfigManager:GetSceneDoorList(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	local config = self:GetSceneConfig(scene_id)
	if not config then
		return
	end
	local door_list = {}
	local door_data
	for k,v in pairs(config.Doors) do
		local scene_name = "Warp Gate"
		local db_config = self:GetDBSceneConfig(v.scene)
		if db_config then
			scene_name = db_config.name
		end
		door_data = {
			uid = v.id,
			id = v.id,
			coord = {x=v.x,y=v.y},
			-- name= v.name ,
			name= scene_name ,
			target_scene = v.scene,
			target_coord = {x=v.target_x,y=v.target_y},
			type = enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL,
			gen_type = SceneConstant.DataType.Client,
		}
		door_list[#door_list+1] = door_data
	end
	return door_list
end

function SceneConfigManager:GetJumpPointList(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	if self.jump_point_list[scene_id] then
		return self.jump_point_list[scene_id]
	end
	local config = self:GetSceneConfig(scene_id)
	if not config or not config.JumpPoints then
		return
	end
	local jump_point_list = {}
	local jump_data
	for k,v in pairs(config.JumpPoints) do
		jump_data = {
			uid = v.id,
			id = v.id,
			coord = {x=v.x,y=v.y},
			-- name= v.name ,
			name= "Jump Point" .. v.id ,
			target_scene = v.scene,
			target_coord = {x=v.target_x,y=v.target_y},
			target_id = v.targetId,
			type = enum.ACTOR_TYPE.ACTOR_TYPE_JUMP,
			gen_type = SceneConstant.DataType.Client,
		}
		jump_point_list[#jump_point_list+1] = jump_data
	end
	--经常用到，缓存一下
	self.jump_point_list[scene_id] = jump_point_list
	return self.jump_point_list[scene_id]
end

function SceneConfigManager:GetMonsterList(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	local config = self:GetSceneConfig(scene_id)
	if not config or not config.Monsters then
		return
	end
	local monster_point_list = {}
	local monster_data
	for k,v in pairs(config.Monsters) do
		local pos = v.pos_list[1] or {}
		monster_data = {
			uid = v.id,
			id = v.id,
			coord = {x=pos.x,y=pos.y},
			type = enum.ACTOR_TYPE.ACTOR_TYPE_CREEP,
			gen_type = SceneConstant.DataType.Client,
		}
		monster_point_list[#monster_point_list+1] = monster_data
	end
	return monster_point_list
end

function SceneConfigManager:GetMonsterWithoutCollect(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	local list = self:GetMonsterList(scene_id)
	if not list then
		return
	end
	local monster_point_list = {}
	for i=1,#list do
		local monster_data = list[i]
		local config = Config.db_creep[monster_data.id]
		if config and config.kind ~= enum.CREEP_KIND.CREEP_KIND_COLLECT then
			monster_data.level = config.level
			monster_point_list[#monster_point_list+1] = monster_data
		end
	end
	
	local function sortFunc(a,b)
		if a.level == b.level then
			return a.id < b.id
		else
			return a.level < b.level
		end
	end
	table.sort(monster_point_list,sortFunc)
	return monster_point_list
end

function SceneConfigManager:GetSceneEffectList(scene_id)
	if LoginModel.IsIOSExamine then
		return {}
	end
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	if table.isempty(SceneEffectConfig[scene_id]) then
		return {}
	end
	return SceneEffectConfig[scene_id]
end

function SceneConfigManager:GetCreepPosition(target_scene_id,type_id)
	local scene_id = target_scene_id or SceneManager:GetInstance():GetSceneId()
	local config = self:GetSceneConfig(scene_id)
	if not config then
		return
	end
	if not config.Monsters[type_id] then
		return
	end
	local pos_list = config.Monsters[type_id].pos_list
	local pos = pos_list[1]
	if not pos then
		return
	end
	return {x=pos.x,y=pos.y}
end

function SceneConfigManager:UpdateJumpWayPath(start_pos,end_pos)
	local scene_id = SceneManager:GetInstance():GetSceneId()
	if not scene_id then
		return
	end
	self.jump_way_path_load_state[scene_id] = self.jump_way_path_load_state[scene_id] or {}
	local has_check_list = self.jump_way_path_load_state[scene_id]
	if has_check_list.is_load then
		return
	end
	self.jump_way_path[scene_id] = self.jump_way_path[scene_id] or {}
	
	local jump_point_list = self:GetJumpPointList(scene_id)
	if not jump_point_list then
		return
	end
	local jump_point_count = #jump_point_list
	-- 寻路次数不要太多，分帧数处理
	local count = 2
	-- count = math.max(jump_point_count-1,count)
	for i,jump_data in ipairs(jump_point_list) do
		has_check_list[jump_data.uid] = has_check_list[jump_data.uid] or {}
		self.jump_way_path[scene_id][jump_data.uid] = self.jump_way_path[scene_id][jump_data.uid] or {jump_id = jump_data.uid}
		self.jump_way_path[scene_id][jump_data.uid].to_jump_list = self.jump_way_path[scene_id][jump_data.uid].to_jump_list or {}
		for k,next_data in ipairs(jump_point_list) do
			if jump_data.uid ~= next_data.uid and not has_check_list[jump_data.uid][next_data.uid] then
				has_check_list[jump_data.uid][next_data.uid] = true
				count = count - 1
				-- 判断起跳点能不能到达 next_data的起点 可以到达不做处理
				local way_path
				way_path = OperationManager:GetInstance():FindWay(jump_data.coord,next_data.coord)
				if table.isempty(way_path) then
					-- 判断落地点能不能到达 next_data的起点
					count = count - 1
					local bo = OperationManager:GetInstance():IsBlock(jump_data.target_coord.x,jump_data.target_coord.y)
					way_path = OperationManager:GetInstance():FindWay(jump_data.target_coord,next_data.coord)
					--能到达，加入路径列表
					if not table.isempty(way_path) then
						table.insert(self.jump_way_path[scene_id][jump_data.uid].to_jump_list,next_data.uid)
					end
				end
				if count <= 0 then
					return
				end
			end
		end
	end
	-- 跳跃点已经全部检查完，清理内存，标记已经加载完
	self.jump_way_path_load_state[scene_id] = {}
	self.jump_way_path_load_state[scene_id].is_load = true
end

function SceneConfigManager:GetJumpPathData(jump_id,scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	if not scene_id then
		return
	end
	local jump_point_list = self:GetJumpPointList(scene_id)
	
	for k,v in pairs(jump_point_list) do
		if v.uid == jump_id then
			return v
		end
	end
end

function SceneConfigManager:GetJumpWayInfo(jump_id,scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	if not scene_id then
		return
	end
	if not self.jump_way_path[scene_id] then
		return
	end
	
	for _jump_id,jump_info in pairs(self.jump_way_path[scene_id]) do
		if _jump_id == jump_id then
			return jump_info
		end
	end
end

function SceneConfigManager:ClearJumpWayState(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	if not scene_id then
		return
	end
	if not self.jump_way_path[scene_id] then
		return
	end
	for k,jump_info in pairs(self.jump_way_path[scene_id]) do
		jump_info.is_check = false
		jump_info.parent = false
	end
end

function SceneConfigManager:GetJumpPath(start_pos,end_pos)
	local scene_id = SceneManager:GetInstance():GetSceneId()
	if not scene_id then
		return
	end
	if not self.jump_way_path_load_state[scene_id] or not self.jump_way_path_load_state[scene_id].is_load or not self.jump_way_path[scene_id] then
		return
	end
	
	local jump_start_id
	local jump_end_id
	for start_id,link_list in pairs(self.jump_way_path[scene_id]) do
		local data = self:GetJumpPathData(start_id)
		local way_path = OperationManager:FindWay(start_pos,data.coord)
		if not table.isempty(way_path) then
			jump_start_id = start_id
			break
		end
	end
	if not jump_start_id then
		return
	end
	
	local data = self:GetJumpPathData(jump_start_id)
	local way_path = OperationManager:FindWay(end_pos,data.target_coord)
	if not table.isempty(way_path) then
		jump_end_id = jump_start_id
	end
	
	if not jump_end_id then
		for start_id,link_list in pairs(self.jump_way_path[scene_id]) do
			if start_id ~= jump_start_id then
				local data = self:GetJumpPathData(start_id)
				local way_path = OperationManager:FindWay(end_pos,data.target_coord)
				if not table.isempty(way_path) then
					jump_end_id = start_id
					break
				end
			end
		end
	end
	
	if not jump_end_id then
		return
	end
	if jump_start_id == jump_end_id then
		return {jump_start_id}
	end
	
	self:ClearJumpWayState(scene_id)
	local jump_list = {}
	local function recursion(jump_id,parent,level)
		level = level or 1
		local jump_info = self:GetJumpWayInfo(jump_id)
		if jump_info.is_check then
			return
		end
		jump_info.is_check = true
		jump_info.parent = parent
		for k,to_jump_id in pairs(jump_info.to_jump_list) do
			if to_jump_id == jump_end_id then
				return jump_info
			end
		end
		for k,to_jump_id in pairs(jump_info.to_jump_list) do
			local jump_info = recursion(to_jump_id,jump_info,level + 1)
			if jump_info then
				return jump_info
			end
		end
	end
	local jump_info = recursion(jump_start_id)
	local vo = jump_info
	table.insert(jump_list,1,jump_end_id)
	while(vo) do
		table.insert(jump_list,1,vo.jump_id)
		vo = vo.parent
	end
	return jump_list
end

function SceneConfigManager:GetSceneDoorCoord(scene_id,target_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	local config = self:GetSceneConfig(scene_id)
	if not config then
		return
	end
	for k,v in pairs(config.Doors) do
		if target_id == v.scene then
			return {x=v.x,y=v.y},v.id
		end
	end
end

function SceneConfigManager:GetSceneInfo(scene_id)
	if self.scene_map[scene_id] then
		return self.scene_map[scene_id]
	end
	local config = self:GetSceneConfig(scene_id)
	local to_scene_list = {}
	for k,v in pairs(config.Doors) do
		to_scene_list[#to_scene_list + 1] = v.scene
	end
	self.scene_map[scene_id] = {}
	self.scene_map[scene_id].scene_id = scene_id
	self.scene_map[scene_id].to_scene_list = to_scene_list
	return self.scene_map[scene_id]
end

function SceneConfigManager:ClearSceneMap()
	for k,scene_info in pairs(self.scene_map) do
		scene_info.is_check = false
		scene_info.parent = false
	end
end

function SceneConfigManager:GetScenePath(start_scene,target_scene)
	self:ClearSceneMap()
	if start_scene == target_scene then
		return {}
	end
	local scene_path = {}
	local function recursion(scene_id,parent,level)
		level = level or 1
		local scene_info = self:GetSceneInfo(scene_id)
		if scene_info.is_check then
			return
		end
		scene_info.is_check = true
		scene_info.parent = parent
		for k,to_scene_id in pairs(scene_info.to_scene_list) do
			if to_scene_id == target_scene then
				-- Yzprint('--LaoY SceneConfigManager.lua,line 118-- level=',level)
				return scene_info
			end
		end
		for k,to_scene_id in pairs(scene_info.to_scene_list) do
			local scene_info = recursion(to_scene_id,scene_info,level + 1)
			if scene_info then
				return scene_info
			end
		end
	end
	local scene_info = recursion(start_scene)
	if not scene_info then
		return {}
	end
	local vo = scene_info
	table.insert(scene_path,1,target_scene)
	while(vo) do
		table.insert(scene_path,1,vo.scene_id)
		vo = vo.parent
	end
	-- 去掉起始场景ID
	table.remove(scene_path,1)
	return scene_path
end

function SceneConfigManager:GetPkModeList(scene_id)
	scene_id = scene_id or  SceneManager:GetInstance():GetSceneId()
	local cf = Config.db_scene[scene_id]
	if not cf then
		return {enum.PKMODE.PKMODE_PEACE}
	end
	local pkallow = String2Table(cf.pkallow)
	if table.isempty(pkallow) then
		return {enum.PKMODE.PKMODE_PEACE}
	end
	return pkallow
	-- local list = {}
	-- list[#list+1] = enum.PKMODE.PKMODE_PEACE
	-- list[#list+1] = enum.PKMODE.PKMODE_ALLY
	-- list[#list+1] = enum.PKMODE.PKMODE_WHOLE
	-- return list
end

function SceneConfigManager:GetSceneCanPlayMount(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	local cf = Config.db_scene[scene_id]
	if cf then
		return cf.mount == 1
	end
	return true
end

function SceneConfigManager:CheckEnterScene(scene_id,is_show_tip)
	local cf = Config.db_scene[scene_id]
	if not cf then
		return false
	end
	is_show_tip = is_show_tip == nil and true or is_show_tip
	local reqs = String2Table(cf.reqs)
	local need_level
	local need_vip
	local main_role = RoleInfoModel:GetInstance():GetMainRoleData()
	for k,v in pairs(reqs) do
		if v[1] == "vip" then
			need_vip = v[2]
		elseif v[1] == "level" then
			need_level = v[2]
		end
	end
	
	local enough_level = need_level == nil and true or main_role.level >= need_level
	local enough_vip = need_vip == nil and true or main_role.viplv >= need_vip
	if not enough_level or not enough_vip then
		if not is_show_tip then
			return false
		end
		local str
		local lv=GetLevelShow(need_level)
		if not enough_level and not enough_vip then
			str = string.format("Requires Lv.%s and VIP%s",ColorUtil.GetHtmlStr(ColorUtil.ColorType.Green,cf.name),lv,need_vip)
		elseif not enough_level then
			str = string.format("Requires Lv.%s",ColorUtil.GetHtmlStr(ColorUtil.ColorType.Green,cf.name),lv)
		elseif not enough_vip then
			str = string.format("Requires VIP%s",ColorUtil.GetHtmlStr(ColorUtil.ColorType.Green,cf.name),need_vip)
		end
		Notify.ShowText(str)
		return false
	end
	return true
end

function SceneConfigManager:GetNPCFlyPos(npc_id)
	local config = Config.db_npc[npc_id]
	local fly_pos
	local fly = config and String2Table(config.fly)
	fly = fly and fly[1]
	if not table.isempty(fly) then
		if #fly == 2 then
			fly_pos = pos(fly[1],fly[2])
		else
			fly_pos = pos(fly[2],fly[3])
		end
	end
	return fly_pos
end

function SceneConfigManager:IsWhole()
	local cf = self:GetDBSceneConfig()
	if not cf then
		return false
	end
	return cf.whole == 1
end

function SceneConfigManager:IsBossMonster(rarity)
	return rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS or 
	rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2
end

function SceneConfigManager:CheckScenesConfig()
	if not AppConfig.Debug or PlatformManager:GetInstance():IsMobile() then
		return
	end
	local cfs = Config.db_scene
	for k,v in pairs(cfs) do
		self:CheckSceneConfig(v.id)
	end
end

function SceneConfigManager:CheckSceneConfig(scene_id)
	local cf = self:GetSceneConfig(scene_id)
	if not cf then
		return
	end
	-- NPC
	local npcs = cf.Npcs
	for id,v in pairs(npcs) do
		local npc_cf = Config.db_npc[id]
		if not npc_cf then
			logError(string.format("%s场景，NPC配置表不存在该NPC：%s",scene_id,id))
		elseif npc_cf.scene ~= scene_id then
			logError(string.format("%s场景，NPC id = %s，NPC配置表的场景ID：%s，和场景编辑器导出的场景ID不一致",scene_id,id,npc_cf.scene))
		end
	end
	-- Monsters
	local monsters = cf.Monsters
	for id,v in pairs(monsters) do
		local monster_cf = Config.db_creep[id]
		if not monster_cf then
			logError(string.format("%s场景，怪物配置表不存在该NPC：%s",scene_id,id))
		elseif monster_cf.scene_id ~= scene_id then
			logError(string.format("%s场景，怪物 id = %s，怪物配置表的场景ID：%s，和场景编辑器导出的场景ID不一致",scene_id,id,monster_cf.scene_id))
		end
	end
end

function SceneConfigManager:GetAllMonsterDataByRes()
	-- enum.ACTOR_TYPE.ACTOR_TYPE_CREEP
	local monster_res_list = {}
	local monster_list = {}
	for k,v in pairs(Config.db_creep) do
		if not monster_res_list[v.figure] then
			monster_res_list[v.figure] = true
			local data = {
				id = v.id,
				hp = 100,
				hpmax = 100,
				name = v.name,
				level = 1,
				dir = 180,
				dest = pos(0,0),
			}
			monster_list[#monster_list+1] = data
		end
	end
	return monster_list
end