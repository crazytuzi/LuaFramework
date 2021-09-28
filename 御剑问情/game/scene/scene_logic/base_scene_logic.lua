-------------------------------------------
-- 基础副本逻辑
--------------------------------------------
BaseSceneLogic = BaseSceneLogic or BaseClass()

function BaseSceneLogic:__init()
	self.scene_type = scene_type

	self.next_get_move_obj_time = 0					-- 下次获取移动对象的时间

	self.auto_guaji_time = 0
	self.auto_guaji_rest_time = 5

	self.key_down = false
	self.key_up = false
	self.is_standby = false
	self.is_show_auto_effect = false

	self.is_in_boss_scene = false
	self.gather_list = {}
	self.req_gather_timequest = nil
	self.next_req_gather_time = 0
	self.next_check_auto_gather_time = 0
	self.auto_moveto_gather_state = 0  -- 1.请求采集物列表中，2.去采集的过程中
	self.loadend_time = 0
	self.is_auto_guaji_when_enter_scene = true

	self.scene_all_load_complete_event = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneDetailLoadComplete, self))
	self.start_gather_event = GlobalEventSystem:Bind(ObjectEventType.START_GATHER, BindTool.Bind(self.OnStartGather, self))
end

function BaseSceneLogic:__delete()
	self.auto_guaji_time = nil
	self.next_get_move_obj_time = nil
	self.key_down = nil
	self.key_up = nil
	self.is_standby = nil
	self.is_show_auto_effect = nil

	self:StopAutoGather()
	GlobalEventSystem:UnBind(self.scene_all_load_complete_event)
	GlobalEventSystem:UnBind(self.start_gather_event)
end

function BaseSceneLogic:SetSceneType(scene_type)
	self.scene_type = scene_type
end

function BaseSceneLogic:IsShowAutoEffect()
	return self.is_show_auto_effect
end

function BaseSceneLogic:GetSceneType()
	return self.scene_type
end

--播放背景音乐
function BaseSceneLogic:PlayBGM()
	local audio_cfg = ConfigManager.Instance:GetAutoConfig("audio_auto") or {}
	local scene_id = Scene.Instance:GetSceneId()
	local scene_audio_cfg = audio_cfg.scene or {}
	for k, v in pairs(scene_audio_cfg) do
		if scene_id == v.scene_id then
			local bundle, asset = ResPath.GetBGMResPath(v.audio_id)
			AudioService.Instance:PlayBgm(bundle, asset)
			break
		end
	end
end

function BaseSceneLogic:OnSceneDetailLoadComplete()
	self.loadend_time = Status.NowTime
end

-- 进入场景
function BaseSceneLogic:Enter(old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.TaskDialog)
	Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_NORMAL)
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
	if self.scene_type ~= SceneType.Common then
		--非普通场景关闭聊天界面
		ViewManager.Instance:Close(ViewName.Chat)
	end
	self:PlayBGM()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)

	Scene.Instance:SetEnterSceneCount()
end

--退出场景
function BaseSceneLogic:Out(old_scene_type, new_scene_type)
	SettingData.Instance:ResetAllAutoShield()
	GlobalEventSystem:Fire(OtherEventType.FUBEN_QUIT, self.scene_type)
	GlobalTimerQuest:AddDelayTimer(function ()
		self:DelayOut(old_scene_type, new_scene_type)
	end, 0.5)

	--退出场景的时候设回去旧的攻击模式
	local attck_mode = UnityEngine.PlayerPrefs.GetInt("attck_mode")
	if attck_mode ~= -1 then
		local old_attack_mode = GameVoManager.Instance:GetMainRoleVo().attack_mode
		if old_attack_mode ~= attck_mode then
			MainUICtrl.Instance:SendSetAttackMode(attck_mode)
		end
	end
end

function BaseSceneLogic:DelayOut(old_scene_type, new_scene_type)

end

function BaseSceneLogic:Update(now_time, elapse_time)
	if self:CanGetMoveObj() then
		if now_time >= self.next_get_move_obj_time then
			self.next_get_move_obj_time = now_time + self:GetMoveObjAllInfoFrequency()
			Scene.SendGetAllObjMoveInfoReq()
		end
	end

	self:CheckAutoGather(now_time)

	-- 场景中，待机5秒以上，设置自动挂机
	self:CheckAutoGuaji(now_time)
end

-- 是否可以拉取移动对象信息
function BaseSceneLogic:CanGetMoveObj()
	return false
end

-- 是否可以取消自动挂机
function BaseSceneLogic:CanCancleAutoGuaji()
	return true
end

function BaseSceneLogic:OnTouchScreen()
	self.auto_guaji_time = Status.NowTime + self.auto_guaji_rest_time
	self.is_standby = false
end

-- 是否自动设置挂机
function BaseSceneLogic:IsSetAutoGuaji()
	return false
end

-- 是否在头上显示特殊图标
function BaseSceneLogic:GetIsShowSpecialImage(scene_obj)
	return false
end

-- 拉取移动对象信息间隔
function BaseSceneLogic:GetMoveObjAllInfoFrequency()
	return 100000
end

-- 是否可以使用气血药
function BaseSceneLogic:CanUseHpDrug()
	return true
end

-- 是否可以移动
function BaseSceneLogic:CanMove()
	return true
end

-- 是否在boss场景
function BaseSceneLogic:GetIsInBossScene()
	return self.is_in_boss_scene
end

-- 是否可以屏蔽怪物
function BaseSceneLogic:CanShieldMonster()
	return 1 ~= Scene.Instance:GetCurFbSceneCfg().monster_alwaysshow
end

-- 获取角色名
function BaseSceneLogic:GetRoleNameBoardText(role_vo)
	local name_color = role_vo.name_color or 0
	local t = {}
	local index = 1

	local camp = role_vo.camp or 0
	if camp > 0 then
		t[index] = {}
		t[index].color = CAMP_COLOR[camp]
		t[index].text = Language.Common.CampNameAbbr[camp] .. "·"
		index = index + 1
	end

	t[index] = {}
	if role_vo.role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		t[index].color = name_color == EvilColorList.NAME_COLOR_WHITE and ROLE_FOLLOW_UI_COLOR.ROLE_NAME or COLOR.RED
	else
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		local color = COLOR.WHITE
		-- if guild_id == role_vo.guild_id and guild_id ~= 0 then
		-- 	color = COLOR.BLUE
		-- end
		t[index].color = name_color == EvilColorList.NAME_COLOR_WHITE and color or COLOR.RED
	end

	local role_name = role_vo.name or role_vo.role_name
	t[index].text = role_name -- PlayerData.ParseCrossServerUserName(role_name)

	-- local txg_cfg = PataData.Instance:GetCfgByLevel(role_vo.tianxiange_level)
	-- if txg_cfg then
	-- 	index = index + 1
	-- 	t[index] = {}
	-- 	t[index].color = COLOR.YELLOW
	-- 	t[index].text ="·" .. txg_cfg.title_name
	-- end

	return t
end

-- 获取角色仙盟名
function BaseSceneLogic:GetGuildNameBoardText(role_vo)
	local t = {}
	local guild_name = role_vo.guild_name or ""

	if "" == guild_name then return t end

	local authority = GuildDataConst.GUILD_POST_AUTHORITY_LIST[role_vo.guild_post]
	local post_name = authority and authority.post or ""

	t[1] = {}
	t[1].color = COLOR.WHITE
	t[1].text = "【" .. guild_name .. "】" .. COMMON_CONSTS.POINT .. post_name

	return t
end

-- 是否友方
function BaseSceneLogic:IsFriend(target_obj, main_role)
	return not self:IsEnemy(target_obj, main_role)
end

local name_t = {}
local color_name = ""
-- 设置角色头上名字的颜色
function BaseSceneLogic:GetColorName(role)
	color_name = ""
	name_t = self:GetRoleNameBoardText(role.vo)
	for k,v in pairs(name_t) do
		color_name = color_name .. "<color=" .. v.color .. ">" .. v.text .. "</color>"
	end
	return color_name
end

-- 是否能走到该坐标
function BaseSceneLogic:GetIsCanMove(x, y)
	return true
end

-- 是否敌方
function BaseSceneLogic:IsEnemy(target_obj, main_role, ignore_table)
	if nil == target_obj or nil == main_role or not target_obj:IsCharacter() then
		return false
	end

	ignore_table = ignore_table or {}	-- 忽略列表

	if main_role:IsRealDead() then												-- 自己死亡
		return false, Language.Fight.SelfDead
	end

	if target_obj:IsRealDead() then												-- 目标死亡
		return false, Language.Fight.TargetDead
	end

	if target_obj:GetVo().is_shadow == 1 then									-- 判断军团雕像是否可攻击
		if MainUIData.IsInCampStatueoScene() and CampData.ShowCampStatueFollow() then
			return true
		else
			return false
		end
	end

	if main_role:IsInSafeArea() and not ignore_table[SceneIgnoreStatus.MAIN_ROLE_IN_SAFE] then											-- 自己在安全区
		return false, Language.Fight.InSafe
	end

	if target_obj:IsInSafeArea() and not ignore_table[SceneIgnoreStatus.OTHER_IN_SAFE] then											-- 目标在安全区
		return false, Language.Fight.TargetInSafe
	end

	if target_obj:GetType() == SceneObjType.Role then
		if Scene.Instance:GetSceneForbidPk() then
			return false, Language.Fight.SceneForbidPk
		end


		if main_role:GetVo().level < COMMON_CONSTS.XIN_SHOU_LEVEL then			-- 自己新手
			return false, Language.Fight.XinShou
		end

		if target_obj:GetVo().level < COMMON_CONSTS.XIN_SHOU_LEVEL then			-- 目标新手
			return false, Language.Fight.TargetXinShou
		end

		return self:IsRoleEnemy(target_obj, main_role)

	elseif target_obj:GetType() == SceneObjType.Monster then
		if not BaseSceneLogic.IsAttackMonster(target_obj:GetMonsterId()) then	-- 是否可攻击的怪
			return false, Language.Fight.TargetNotAtk
		end

		return self:IsMonsterEnemy(target_obj, main_role)
	end

	return false, Language.Fight.TargetNotAtk
end

-- 是否可攻击的怪
function BaseSceneLogic.IsAttackMonster(monster_id)
	local monster_config = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[monster_id]
	if nil ~= monster_config and 0 == monster_config.is_attacked then
		return false
	end
	return true
end

-- 角色是否是敌人
function BaseSceneLogic:IsRoleEnemy(target_obj, main_role)
	if Scene.Instance:GetSceneForbidPk() then
		--禁止pk的场景无法打人
		return false
	end

	local attack_mode = main_role:GetVo().attack_mode
		--密藏boss不允许打人
	if BossData.IsSecretBossScene(Scene.Instance:GetSceneId()) then
		local main_role = Scene.Instance:GetMainRole()
		local forbid_pk_radius = BossData.Instance:GetSecretNotPkRadius()
		local center_x, center_y = BossData.Instance:GetSecretNotPkCenterXY()
		local logic_x, logic_y = main_role:GetLogicPos()
		local distance = GameMath.GetDistance(logic_x, logic_y, center_x, center_y, true)
		if distance <= forbid_pk_radius then
			return false
		end
	end
	if attack_mode == GameEnum.ATTACK_MODE_PEACE then
		return false
	elseif attack_mode == GameEnum.ATTACK_MODE_TEAM then
		return not ScoietyData.Instance:IsTeamMember(target_obj:GetRoleId())
	elseif attack_mode == GameEnum.ATTACK_MODE_GUILD then
		return main_role:GetVo().guild_id == 0 or main_role:GetVo().guild_id ~= target_obj:GetVo().guild_id
	elseif attack_mode == GameEnum.ATTACK_MODE_ALL then
		return true
	elseif attack_mode == GameEnum.ATTACK_MODE_NAMECOLOR then
		return target_obj:GetVo().name_color ~= GameEnum.NAME_COLOR_WHITE
	elseif attack_mode == GameEnum.ATTACK_MODE_CAMP then
		return main_role:GetVo().camp == 0 or main_role:GetVo().camp ~= target_obj:GetVo().camp
	end

	return true
end



-- 怪物是否是敌人
function BaseSceneLogic:IsMonsterEnemy(target_obj, main_role)
	return true
end

function BaseSceneLogic:GetGuajiPos()
	return nil, nil
end

-- 获取特殊的挂机位置（这个会强制移动到当前位置附近再进行挂机）
function BaseSceneLogic:GetSpecialGuajiPos()
	return nil, nil, nil
end

function BaseSceneLogic:OnMainRoleRealive()
	-- body
end

-- 获得捡取掉物品的最大距离
function BaseSceneLogic:GetPickItemMaxDic(item_id)
	if GoldMemberData.Instance:GetVIPSurplusTime() > 0 then
		return 0
	end
	return 4
end

function BaseSceneLogic:FindScenePathNode(scene_id, node)
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_cfg then
		return
	end
	self.checked_list[scene_id] = 1 --记录检查过的
	for k,v in pairs(scene_cfg.doors) do
		if v.target_scene_id ~= nil then
			local cur_node = {}
			cur_node.x = v.x
			cur_node.y = v.y
			cur_node.target_scene_id = v.target_scene_id
			cur_node.scene_id = scene_id
			cur_node.prve_node = node

			self.node_list[#self.node_list + 1] = cur_node
			if v.target_scene_id == self.target_scene_id then --找到目的地
				return
			elseif self.checked_list[v.target_scene_id] ~= 1 then
				self:FindScenePathNode(v.target_scene_id, cur_node)
			end
		end
	end
end

--获得场景之间可行走路径点（不考虑最短路径）
function BaseSceneLogic:GetScenePath(start_scene_id, target_scene_id)
	self.checked_list = {}
	self.node_list = {}
	self.target_scene_id = target_scene_id
	self:FindScenePathNode(start_scene_id)
	--从目标场景节点中往前推组成新的路径列表
	local cur_node = nil
	for k,v in pairs(self.node_list) do
		if v.target_scene_id == target_scene_id then
			cur_node = v
		end
	end

	if cur_node == nil then
		return {}
	end

	local path_list = {}
	path_list[1] = cur_node
	local loop_count = 0
	if nil ~= cur_node then
		while loop_count < 200 do
			for k,v in pairs(self.node_list) do
				if v == cur_node.prve_node then
					table.insert(path_list, 1, v) --总是放在第1个
					cur_node = v
					if v.target_scene_id == start_scene_id then -- 返回到起始场景结束
						break
					end
				end
			end
			loop_count = loop_count + 1
		end
	end
	return path_list
end

--获得场景目标点。
--找不到场景入口点的情况下则找该场景的传送点
--一个地图可能有多个传送点，需通过地图寻路找到路径上的传送点。
function BaseSceneLogic:GetTargetScenePos(scene_id)
	local fly_x, fly_y = Scene.Instance:GetEntrance(Scene.Instance:GetSceneId(), scene_id)
	if fly_x == nil or fly_y == nil then
		local scene_path = self:GetScenePath(Scene.Instance:GetSceneId(), scene_id)
		local scene_node = scene_path[#scene_path]
		if scene_node ~= nil then --最终获得所在目标场景上的传送点
			fly_x, fly_y = Scene.Instance:GetSceneDoorPos(scene_node.target_scene_id, scene_node.scene_id)
		end
	end
	return fly_x, fly_y
end

-- 自动挂机优先级,为ture的话则自动挂机优先于寻路
function BaseSceneLogic:GetAutoGuajiPriority()
	return false
end

function BaseSceneLogic:GetGuajiSelectObjDistance()
	return COMMON_CONSTS.SELECT_OBJ_DISTANCE
end

function BaseSceneLogic:IsAutoStopTaskOnGuide()
	return true
end

-- 是否能够在频率过低时自动设置
function BaseSceneLogic:IsCanSystemAutoSetting()
	if Scene.Instance:IsSceneLoading() then
		return false
	end

	if CgManager.Instance:IsCgIng() then
		return false
	end

	if 0 == self.loadend_time or Status.NowTime < self.loadend_time + 3 then
		return false
	end

	return true
end

-- 待机5秒，设置自动挂机状态
function BaseSceneLogic:CheckAutoGuaji(now_time)
	local main_role = Scene.Instance:GetMainRole()
	if self:IsSetAutoGuaji() and main_role then
		if GuajiCache.guaji_type == GuajiType.None then
			if not main_role:IsMove() and not main_role:IsRealDead() then
				-- 鼠标点击事件
				if UnityEngine.Input.GetMouseButtonDown(0) then
					self.key_down = true
					self.key_up = false
				end
				if UnityEngine.Input.GetMouseButtonUp(0) then
					self.key_up = true
					self.key_down = false
				end
				if not self.key_up and self.key_down then
					self.auto_guaji_time = now_time + self.auto_guaji_rest_time
				end

				-- 移动端触屏事件
				if UnityEngine.Input.touchCount > 0 then
					self.auto_guaji_time = now_time + self.auto_guaji_rest_time
				end
				if self.auto_guaji_time <= 0 then
					self.auto_guaji_time = now_time + self.auto_guaji_rest_time
				elseif self.auto_guaji_time <= now_time then
					if not self.is_standby and self.is_auto_guaji_when_enter_scene then
						GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
						-- TipsCtrl.Instance:ShowOrHideStandbyMaskView(true)
						self.is_standby = true
					end
				end
			elseif not main_role:IsStand() and not main_role:IsRealDead() then
				self.auto_guaji_time = now_time + self.auto_guaji_rest_time
				self.is_standby = false
			end
		elseif main_role:IsMove() then
			self.auto_guaji_time = now_time + self.auto_guaji_rest_time
			self.is_standby = false
		end
	elseif not self:IsSetAutoGuaji() and self.is_standby then
		-- TipsCtrl.Instance:ShowOrHideStandbyMaskView()
		self.is_standby = false
	end
end

function BaseSceneLogic:AlwaysShowMonsterName()
	return false
end

function BaseSceneLogic:CheckAutoGather(now_time)
	if not self:IsCanAutoGather() then
		self:StopAutoGather()
		return
	end

	if 0 == self.auto_moveto_gather_state then
		return
	end

	-- 因为远处的采集物可能被采掉，不断拉取更新
	if 0 ~= self.next_req_gather_time and now_time >= self.next_req_gather_time then
		Scene.SendReqGatherGeneraterList(Scene.Instance:GetSceneId(), PlayerData.Instance:GetAttr("scene_key") or 0)
		self.next_req_gather_time = now_time + 2
	end

	-- 在去采集路上因为采集物可能发生了变化，不断去找最近的
	if 0 ~= self.next_check_auto_gather_time and now_time >= self.next_check_auto_gather_time then
		self.next_check_auto_gather_time = now_time + 1
		self:AutoMoveToGather()
	end
end

function BaseSceneLogic:StopAutoGather()
	if 0 ~= self.auto_moveto_gather_state then
		self.auto_moveto_gather_state = 0
		self.next_req_gather_time = 0
		self.next_check_auto_gather_time = 0

		if nil ~= self.req_gather_timequest then
			GlobalTimerQuest:CancelQuest(self.req_gather_timequest)
			self.req_gather_timequest = nil
		end
	end
end

-- 采集结束(服务器返回)
function BaseSceneLogic:OnStartGather(role_obj_id, gather_obj_id)
	if role_obj_id ~= Scene.Instance:GetMainRole():GetObjId() then
		return
	end

	if not self:IsCanAutoGather() then
		return
	end

	self.req_gather_timequest = GlobalTimerQuest:AddDelayTimer(function ()
		self.auto_moveto_gather_state = 1
		self.next_req_gather_time = Status.NowTime
		self.next_check_auto_gather_time = Status.NowTime
	end, 0.5)
end

function BaseSceneLogic:ServeAutoGather()
	self.auto_moveto_gather_state = 1
	self.next_req_gather_time = Status.NowTime
	self.next_check_auto_gather_time = Status.NowTime
end

--检查采集次数是否足够
function BaseSceneLogic:CheckHaveGatherTimes()
	return true
end

function BaseSceneLogic:IsCanAutoGather()
	local is_auto_gather = false
	local is_in_auto_gather_scene = false
	local scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(AUTO_GATHER_COMMON_SCENE) do
		if v == scene_id then
			is_in_auto_gather_scene = true
			break
		end
	end

	--只有有vip等级并且采集次数有的情况下才能自动采集
	if is_in_auto_gather_scene and GameVoManager.Instance:GetMainRoleVo().vip_level >= 1 and self:CheckHaveGatherTimes() then
		is_auto_gather = true
	end

	return is_auto_gather
end

function BaseSceneLogic:OnSCGatherGeneraterList(protocol)
	self.gather_list = protocol.gather_list

	if self:IsCanAutoGather() and self.auto_moveto_gather_state == 1 then
		self:AutoMoveToGather()
	end
end

function BaseSceneLogic:AutoMoveToGather()
	if Scene.Instance:GetMainRole():GetIsGatherState() then
		return
	end

	--如果已经有目标了就不处理
	if MoveCache.end_type == MoveEndType.Gather then
		local target_obj = MoveCache.target_obj
		if target_obj and target_obj.draw_obj and target_obj:IsGather() then
			return
		end
	elseif MoveCache.end_type == MoveEndType.GatherById then
		if Scene.Instance:GetGatherByGatherId(MoveCache.param1) then
			return
		end
	end

	local target_distance = -1
	local distance = 0
	local main_role_x, main_role_y = Scene.Instance:GetMainRole():GetLogicPos()
	local target_gather = nil

	for _, v in pairs(self.gather_list) do
		distance = GameMath.GetDistance(main_role_x, main_role_y, v.pos_x, v.pos_y, false)
		if -1 == target_distance or distance <= target_distance then
			target_distance = distance
			target_gather = v
		end
	end

	if nil ~= target_gather then
		MoveCache.param1 = target_gather.gather_id
		MoveCache.end_type = MoveEndType.GatherById
		self.auto_moveto_gather_state = 2
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), target_gather.pos_x, target_gather.pos_y, 1)
	end
end

function BaseSceneLogic:IsCanCheckWaterArea()
	return false
end

-- 进入场景时是否自动挂机
function BaseSceneLogic:IsAutoGuajiWhenEnterScene()
	local cfg = Scene.Instance:GetCurFbSceneCfg()
	return self.is_auto_guaji_when_enter_scene and nil ~= cfg and 1 == cfg.is_auto_guaji
end

-- 设置进入场景时是否自动挂机
function BaseSceneLogic:SetAutoGuajiWhenEnterScene(switch)
	self.is_auto_guaji_when_enter_scene = switch
end

function BaseSceneLogic:ChangeTitle()

end

--是否可使用伙伴技能
function BaseSceneLogic:CanUseGoddessSkill()
	return true
end