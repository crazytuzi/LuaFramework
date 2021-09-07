require("game/guaji/guaji_data")

local AUTO_TASK_TIME = 10
local ANGLE_FUBE_TASK_TIME = 5
local LEVEL_LIMIT = 110 -- 自动做任务的等级
local FLY_TO_POS_LEVEL_LIMIT = 70 -- 传送到传送门等级

local use_prof_normal_skill_list = {
	111, 211, 311, 411,
}

local use_prof_skill_list = {
	{131, 141, 121, 111},
	{231, 241, 221, 211},
	{331, 341, 321, 311},
	{431, 441, 421, 411},
}

-- 挂机
GuajiCtrl = GuajiCtrl or BaseClass(BaseController)

function GuajiCtrl:__init()
	if GuajiCtrl.Instance ~= nil then
		print_error("[GuajiCtrl] attempt to create singleton twice!")
		return
	end
	GuajiCtrl.Instance = self

	self:RegisterAllEvents()

	self.last_update_time = 0
	self.on_arrive_func = BindTool.Bind(self.OnArrive, self)

	self.last_click_obj = nil

	self.last_play_time = 0					--npc最后说话时间
	self.last_play_id = 0					--最后播放的npc声音
	self.npc_talk_interval = 60				--同一个npc说话的CD

	Runner.Instance:AddRunObj(self, 8)

	self.last_scene_id = 0
	self.scene_type = 0
	self.last_scene_key = 0
	self.last_operation_time = 0
	self.next_check_loop_task = 0
	self.guai_ji_next_move_time = 0
	self.task_window = 0
	self.path_list = nil
	self.move_target = nil
	self.move_target_left_time = 0
	self.auto_mount_up = false
	self.last_mount_time = 0
	self.is_gather = false
	self.bag_rich_quest = nil
	self.cache_select_obj_onloading = nil
	self.goto_pick_x = 0
	self.goto_pick_y = 0
	self.next_can_goto_pick_time = 0
	self.arrive_call_back = nil
	self.next_scan_target_monster_time = 0
end

function GuajiCtrl:__delete()
	GuajiCtrl.Instance = nil

	Runner.Instance:RemoveRunObj(self)

	GlobalTimerQuest:CancelQuest(self.bag_rich_quest)
end

function GuajiCtrl:RegisterAllEvents()
	self:BindGlobalEvent(ObjectEventType.MAIN_ROLE_DEAD, BindTool.Bind1(self.OnMainRoleDead, self))
	self:BindGlobalEvent(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObj, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDead, self))
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneLoadingQuite, self))
	self:BindGlobalEvent(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneLoadingEnter, self))

	self:BindGlobalEvent(ObjectEventType.CAN_NOT_FIND_THE_WAY,
		BindTool.Bind1(self.OnCanNotFindWay, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
	self:BindGlobalEvent(ObjectEventType.MAIN_ROLE_MOVE_END,
		BindTool.Bind(self.PlayerOperation, self))
	self:BindGlobalEvent(ObjectEventType.MAIN_ROLE_POS_CHANGE,
		BindTool.Bind(self.PlayerPosChange, self))
	self:BindGlobalEvent(ObjectEventType.EXIT_FIGHT,
		BindTool.Bind(self.PlayerExitFight, self))
	self:BindGlobalEvent(SettingEventType.AUTO_RELEASE_SKILL,
		BindTool.Bind(self.SettingChange, self, SETTING_TYPE.AUTO_RELEASE_SKILL))
	self:BindGlobalEvent(SettingEventType.AUTO_RELEASE_ANGER,
		BindTool.Bind(self.SettingChange, self, SETTING_TYPE.AUTO_RELEASE_ANGER))
	self:BindGlobalEvent(SettingEventType.AUTO_PICK_PROPERTY,
		BindTool.Bind(self.SettingChange, self, SETTING_TYPE.AUTO_PICK_PROPERTY))
	-- self:BindGlobalEvent(SettingEventType.AUTO_RELEASE_GODDESS_SKILL,
	-- 	BindTool.Bind(self.SettingChange, self, SETTING_TYPE.AUTO_RELEASE_GODDESS_SKILL))
	self:BindGlobalEvent(OtherEventType.TASK_WINDOW,
		BindTool.Bind(self.TaskWindow, self))
	self:BindGlobalEvent(ObjectEventType.STOP_GATHER,
		BindTool.Bind(self.OnStopGather, self))
	self:BindGlobalEvent(ObjectEventType.START_GATHER,
		BindTool.Bind(self.OnStartGather, self))
end

function GuajiCtrl:Update(now_time, elapse_time)
	self:CheckMountUp(now_time)

	if TaskData.DoDailyTaskTime then
		TaskData.DoDailyTaskTime = TaskData.DoDailyTaskTime + elapse_time
		TaskData.DoGuildTaskTime = TaskData.DoGuildTaskTime + elapse_time
		if (TaskData.DoDailyTaskTime >= 60 and TaskData.DoDailyTaskTime - elapse_time < 60)
		or (TaskData.DoGuildTaskTime >= 60 and TaskData.DoGuildTaskTime - elapse_time < 60) then
			GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE)
		end
	end

	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	if role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return
	end
	if Scene.Instance and Scene.Instance:GetMainRole() and Scene.Instance:GetMainRole():IsDead() then
		self:StopGuaji()
		return
	end

	if MoveCache.is_move_scan then
		local obj = self:SelectAtkTarget(true)
		if obj and obj:IsCharacter() then
			self:StopGuaji()
			self:SetGuajiType(GuajiType.Auto)
			return
		end
	end

	if self.next_scan_target_monster_time > 0 then
		self:OnOperateFightByMonsterId()
		self.next_scan_target_monster_time = 0
	end

	if not AtkCache.is_valid then
		if GuajiCache.guaji_type ~= GuajiType.None then

			if Scene.Instance:GetSceneType() == SceneType.TowerDefend and FuBenData.Instance:GetTowerIsWarning() then
				--女神塔防内特殊处理挂机
				self:UpDateTowerDefend()
			else
				local pick_x, pick_y = self:GetPickPos()
				if 0 == pick_x and 0 == pick_y then  -- 没有可捡点则直接挂机
					self:UpdateGuaji(now_time)
				else
					-- 去到目标点不做任何事，场景有机制自动触发捡取, 不设置会断掉挂机
					if self.goto_pick_x ~= pick_x or self.goto_pick_y ~= pick_y and now_time >= self.next_can_goto_pick_time then
						self.next_can_goto_pick_time = 0
						self.goto_pick_x = pick_x
						self.goto_pick_y = pick_y
						MoveCache.end_type = MoveEndType.PickAroundItem
						self:MoveToPos(Scene.Instance:GetSceneId(), pick_x, pick_y, 0, 0)
					end
				end
			end
		else
			if now_time >= self.last_operation_time + 2 and not MainUIViewTask.SHOW_GUIDE_ARROW and self:IsCanAutoExecuteTask(true) then
				MainUICtrl.Instance.view.task_view:ShowGuideArrow()
			end

			if now_time >= self.last_operation_time + AUTO_TASK_TIME then
				if not self:TryAutoExecutTask() then
					self.last_operation_time = now_time
				end
			end

			local auto_pick_item = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_PICK_PROPERTY)
			if not auto_pick_item then
				local main_role = Scene.Instance:GetMainRole()
				local main_role_x, main_role_y = main_role:GetLogicPos()
				local fall_item_list = Scene.Instance:GetObjListByType(SceneObjType.FallItem) or {}
				local pick_distance = 5
				for k, v in pairs(fall_item_list) do
					if not v:IsPicked()and not v:IsInBlock()									-- 掉落物在障碍点不捡，服务器处理下
						and (v:GetVo().owner_role_id < 0 or v:GetVo().owner_role_id == main_role:GetRoleId())  	-- 只捡自己的(无归属的也属于自己)
						and Status.NowTime >= v:GetVo().create_time + 1 then  	-- 生成时有动画要看，太快捡掉不好

						local target_x, target_y = v:GetLogicPos()
						local distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)

						if distance < pick_distance then
							local item_objid_list = {}
							table.insert(item_objid_list, v:GetObjId())
							Scene.ScenePickItem(item_objid_list)
							break
						end
					end
				end
			end
		end
	end

	if AtkCache.is_valid then
		self:UpdateAtk(now_time)
		self:UpdateFollowAtkTarget(now_time)
	end

	if now_time >= self.next_check_loop_task then
		self.next_check_loop_task = now_time + 1
		self:CheckAutoExcuteLoopTask()
	end
	self:FixGuajiStopBug(elapse_time)
end

function GuajiCtrl:UpDateTowerDefend()
	self:CancelSelect()
	MoveCache.end_type = MoveEndType.DoNothing
	local moster_list = Scene.Instance:GetSceneMosterList()
	if moster_list then
		self:MoveToPos(Scene.Instance:GetSceneId(), moster_list[1].x, moster_list[1].y, 0, 0)
	end
	FuBenData.Instance:SetTowerIsWarning(false)
end

local last_fix_bug_time = 0
local maybe_bug_keep_time = 0
function GuajiCtrl:FixGuajiStopBug(elapse_time)
	if (GuajiCache.guaji_type == GuajiType.Auto or GuajiCache.guaji_type == GuajiType.Monster) then
		if Scene.Instance:GetMainRole():IsStand()
			and not Scene.Instance:IsSceneLoading() 
			and not CgManager.Instance:IsCgIng() then
			maybe_bug_keep_time = maybe_bug_keep_time + elapse_time
		else
			maybe_bug_keep_time = 0
		end

		if maybe_bug_keep_time > 5 then
			maybe_bug_keep_time = 0
			print_log("is guaji stop? auto restart now!")
			last_fix_bug_time = Status.NowTime
			self:StopGuaji()
			self:SetGuajiType(GuajiType.Auto)
		end
	end
end

function GuajiCtrl:CheckAutoExcuteLoopTask()
	if Scene.Instance:GetSceneType() ~= SceneType.Common then
		return
	end
	if ViewManager.Instance:IsOpen(ViewName.TaskDialog) then
		return
	end

	if TASK_GUILD_AUTO and nil ~= MoveCache.task_id
		and TaskData.Instance:IsGuildTask(MoveCache.task_id)
		and Scene.Instance:GetMainRole():GetTotalStandTime() >= 3 then

		GuajiCache.monster_id = 0
		TaskCtrl.Instance:DoTask(MoveCache.task_id)
	end

	if TASK_RI_AUTO and nil ~= MoveCache.task_id
		and TaskData.Instance:IsDailyTask(MoveCache.task_id)
		and Scene.Instance:GetMainRole():GetTotalStandTime() >= 3 then
		GuajiCache.monster_id = 0
		TaskCtrl.Instance:DoTask(MoveCache.task_id)
	end
end

function GuajiCtrl:TryAutoExecutTask()
	if Scene.Instance:GetSceneType() ~= SceneType.Common then
		return false
	end

	if not self:IsCanAutoExecuteTask() then
		return false
	end

	MainUICtrl.Instance.view.task_view:AutoExecuteTask()

	return true
end

function GuajiCtrl:IsCanAutoExecuteTask(ignore_level)
	if self.task_window == 0 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo then
			if (main_role_vo.level <= LEVEL_LIMIT or ignore_level) and self.scene_type == 0 then
				if MainUICtrl and MainUICtrl.Instance and not MainUICtrl.Instance:IsPauseAutoTask() then
					local config = nil
					if not ignore_level and TASK_GUILD_AUTO then
						config = TaskData.Instance:GetNextGuildTaskConfig()
					else
						config = TaskData.Instance:GetNextZhuTaskConfig()
					end
					if not ignore_level and config then
						if config.min_level <= main_role_vo.level then
							TaskData.Instance:SetCurTaskId(config.task_id)
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function GuajiCtrl:GetPickPos()
	if MoveEndType.PickAroundItem == MoveCache.end_type then  -- 正在往捡起路上，不该干其他事
		return 0, 0
	end

	if GuajiCache.guaji_type == GuajiType.None or GuajiCache.guaji_type == GuajiType.Follow then
		return 0, 0
	end

	if MoveCache.task_id > 0 then
		return 0, 0
	end

	if nil ~= GuajiCache.target_obj and Scene.Instance:IsEnemy(GuajiCache.target_obj) and not GuajiCache.target_obj:IsRealDead() then
		return 0, 0
	end

	if Scene.Instance:GetMainRole():IsRealDead() then
		return 0, 0
	end
	if GoldMemberData.Instance:GetVIPSurplusTime() > 0 then
		return 0, 0
	end

	local auto_pick_item = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_PICK_PROPERTY)
	local auto_pick_color = SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_PICK_COLOR)
	if not auto_pick_item or nil == auto_pick_color then
		return 0, 0
	end

	local fall_item_list = Scene.Instance:GetObjListByType(SceneObjType.FallItem)
	if not next(fall_item_list) then
		return 0, 0
	end

	local main_role = Scene.Instance:GetMainRole()
	local main_role_x, main_role_y = main_role:GetLogicPos()

	local pick_x, pick_y, pick_distance = 0, 0, 99999

	for k, v in pairs(fall_item_list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.vo.item_id)

		if item_cfg and item_cfg.color > auto_pick_color
			and not v:IsPicked()
			and not v:IsInBlock()									-- 掉落物在障碍点不捡，服务器处理下
			and (v:GetVo().owner_role_id < 0 or v:GetVo().owner_role_id == main_role:GetRoleId())  	-- 只捡自己的(无归属的也属于自己)
			and Status.NowTime >= v:GetVo().create_time + 1 then  	-- 生成时有动画要看，太快捡掉不好

			local target_x, target_y = v:GetLogicPos()
			local distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)

			if distance < pick_distance then
				pick_x = target_x
				pick_y = target_y
				pick_distance = distance
			end
		end
	end

	if 0 == pick_x and 0 == pick_y then
		return 0, 0
	end

	local empty_num = ItemData.Instance:GetEmptyNum()
	if 0 == empty_num then
		if self.bag_rich_quest == nil then
			self:CalToShowTips()
		end
		return 0, 0
	end

	return pick_x, pick_y
end

function GuajiCtrl:CalToShowTips()
	local timer = 2
	self.bag_rich_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 0 then
			TipsCtrl.Instance:ShowSystemMsg("您的背包空间不足，无法拾取物品，请清理！")
			GlobalTimerQuest:CancelQuest(self.bag_rich_quest)
			self.bag_rich_quest = nil
		end
	end, 0)
end

-- 获取挂机打怪的位置
function GuajiCtrl:GetGuiJiMonsterPos()
	local target_distance = 1000 * 1000
	local target_x = nil
	local target_y = nil
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()

	local obj_move_info_list = Scene.Instance:GetObjMoveInfoList()

	for k, v in pairs(obj_move_info_list) do
		local vo = v:GetVo()
		if vo.obj_type == SceneObjType.Monster and BaseSceneLogic.IsAttackMonster(vo.type_special_id) then
			local distance = GameMath.GetDistance(x, y, vo.pos_x, vo.pos_y, false)
			if distance < target_distance then
				target_x = vo.pos_x
				target_y = vo.pos_y
				target_distance = distance
			end
		end
	end

	return target_x, target_y
end

-- 获取元素战场挂机打人的位置
function GuajiCtrl:GetGuiJiRolePos()
	local target_distance = 1000 * 1000
	local target_x = nil
	local target_y = nil
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()

	for k, v in pairs(obj_move_info_list) do
		local vo = v:GetVo()
		if vo.obj_type == SceneObjType.Role and vo.monster_key == 1 then
			local distance = GameMath.GetDistance(x, y, vo.pos_x, vo.pos_y, false)
			if distance < target_distance then
				target_x = vo.pos_x
				target_y = vo.pos_y
				target_distance = distance
			end
		end
	end

	return target_x, target_y
end

-- 检测范围
function GuajiCtrl.CheckRange(x, y, range)
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	return math.floor((x - self_x) * (x - self_x)) + math.floor((y - self_y) * (y - self_y)) <= range * range
end

-- 选择（寻找）攻击目标
function GuajiCtrl:SelectAtkTarget(can_select_role, ignore_table, cant_select_monster)
	local target_obj = nil
	if nil ~= GuajiCache.target_obj
		and GuajiCache.target_obj == Scene.Instance:GetObj(GuajiCache.target_obj_id)
		and Scene.Instance:IsEnemy(GuajiCache.target_obj, ignore_table)
		and not AStarFindWay:IsBlock(GuajiCache.target_obj:GetLogicPos()) then
		target_obj = GuajiCache.target_obj

		if not GuajiCache.is_click_select then
			local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
			local target_x, target_y = GuajiCache.target_obj:GetLogicPos()
			if GameMath.GetDistance(self_x, self_y, target_x, target_y, false) >= 640 then
				target_obj = nil
			elseif not AStarFindWay:IsWayLine(self_x, self_y, target_x, target_y) then
				target_obj = nil
			end
		end
		if target_obj and cant_select_monster and target_obj:GetType() == SceneObjType.Monster then
			target_obj = nil
		end
	end
	if nil == target_obj then
		local scene = Scene.Instance

		local target_distance = Scene.Instance:GetSceneLogic():GetGuajiSelectObjDistance()
		local x, y = scene:GetMainRole():GetLogicPos()

		local temp_role_target = nil
		local temp_monster_target = nil

		-- 是否优先攻击玩家
		local role_first = false
		local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
		if scene_cfg then
			role_first = scene_cfg.attack_player == 1
		end
		local scene_id = Scene.Instance:GetSceneId()
		if BossData.IsFamilyBossScene(scene_id)
			or BossData.IsMikuBossScene(scene_id) then
			role_first = true
		end

		if can_select_role then
			temp_role_target, target_distance = scene:SelectObjHelper(SceneObjType.Role, x, y, target_distance, SelectType.Enemy, ignore_table)
		end

		if not cant_select_monster then
			temp_monster_target, target_distance = scene:SelectObjHelper(SceneObjType.Monster, x, y, target_distance, SelectType.Enemy, ignore_table)
		end

		if role_first then
			target_obj = temp_role_target or temp_monster_target
		else
			target_obj = temp_monster_target or temp_role_target
		end
		if nil ~= target_obj then
			GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, SceneTargetSelectType.SELECT)
		end
	end
	return target_obj
end

-- 选择（寻找）攻击目标（玩家）
function GuajiCtrl:SelectFriend()
	local target_obj = nil
	if nil ~= GuajiCache.target_obj
		and GuajiCache.target_obj == Scene.Instance:GetObj(GuajiCache.target_obj_id)
		and Scene.Instance:IsFriend(GuajiCache.target_obj)
		and not AStarFindWay:IsBlock(GuajiCache.target_obj:GetLogicPos()) then
		target_obj = GuajiCache.target_obj
		if not target_obj:IsRole() then
			target_obj = nil
		end
		if not GuajiCache.is_click_select then
			local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
			local target_x, target_y = GuajiCache.target_obj:GetLogicPos()
			if GameMath.GetDistance(self_x, self_y, target_x, target_y, false) >= 640 then
				target_obj = nil
			elseif not AStarFindWay:IsWayLine(self_x, self_y, target_x, target_y) then
				target_obj = nil
			end
		end
	end
	if nil == target_obj then
		local scene = Scene.Instance

		local target_distance = Scene.Instance:GetSceneLogic():GetGuajiSelectObjDistance()
		local x, y = scene:GetMainRole():GetLogicPos()

		local temp_target = nil
		temp_target, target_distance = scene:SelectObjHelper(SceneObjType.Role, x, y, target_distance, SelectType.Friend)
		target_obj = temp_target or target_obj

		if nil ~= target_obj then
			GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, target_obj, SceneTargetSelectType.SELECT)
		end
	end
	return target_obj
end

function GuajiCtrl.SetMoveValid(is_valid)
	MoveCache.is_valid = is_valid
	if not is_valid then
		GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_AUTO_XUNLU, false)
	end
end

function GuajiCtrl.SetAtkValid(is_valid)
	AtkCache.is_valid = is_valid
end

function GuajiCtrl:SetGuajiType(guaji_type)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	if role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		return
	end

	if GuajiCache.guaji_type ~= guaji_type then
		self:PlayerOperation()
		GuajiCache.guaji_type = guaji_type
		if guaji_type == GuajiType.Auto then
			local scene_logic = Scene.Instance:GetSceneLogic()
			if scene_logic and scene_logic:GetAutoGuajiPriority() then
				GuajiCtrl.SetMoveValid(false)
			end
			-- GuajiCtrl.SetMoveValid(false)
		elseif guaji_type == GuajiType.HalfAuto then
			self.auto_mount_up = true
		end
		GlobalEventSystem:Fire(OtherEventType.GUAJI_TYPE_CHANGE, guaji_type)
		GuajiCache.event_guaji_type = guaji_type
	end
end

-- 取消选中
function GuajiCtrl:CancelSelect()
	if nil ~= GuajiCache.target_obj and GuajiCache.target_obj == Scene.Instance:GetObj(GuajiCache.target_obj_id) then
		--if GuajiCache.target_obj:GetType() ~= SceneObjType.MainRole and GuajiCache.target_obj:GetType() ~= SceneObjType.Role then
			GuajiCache.target_obj:CancelSelect()
			if self.select_obj then
				self.select_obj:CancelSelect()
				self.select_obj = nil
			end
			--end
		GuajiCache.target_obj = nil
		GuajiCache.target_obj_id = COMMON_CONSTS.INVALID_OBJID
		if MainUICtrl.Instance.view and MainUICtrl.Instance.view.target_view then
			MainUICtrl.Instance.view.target_view:OnObjDeleteHead(self.last_click_obj)
			self.last_click_obj = nil
		end
	end
end

--角色死亡后
function GuajiCtrl:OnMainRoleDead()
	self:SetGuajiType(GuajiType.None)
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Kf_OneVOne or scene_type == SceneType.PushFuBen or scene_type == SceneType.DiMaiFb or scene_type == SceneType.RuneTower then
		return
	end
	ViewManager.Instance:Open(ViewName.ReviveView)
end

function GuajiCtrl:GetMonsterSiegeCanSelect(target_obj)
	local can_select = false

	if Scene.Instance:GetSceneType() == SceneType.MonsterSiegeFb then
		can_select = true
		local camp = PlayerData.Instance.role_vo.camp
		local data = CampData.Instance:GetMonsterSiegeInfo()
		local target_is_shadow = target_obj:GetVo().shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_MONSTER_SIEGE_KING
		local is_interfere = false
		if data ~= nil then
			local other_camp = data.monster_siege_camp
			if other_camp ~= nil and other_camp > 0 and other_camp ~= camp then
				is_interfere = true
			end
		end

		if target_is_shadow and not is_interfere then
			can_select = false 
		end
	end

	return can_select
end

-- 选择场景对象
function GuajiCtrl:OnSelectObj(target_obj, select_type)
	if nil == target_obj
		or target_obj:IsDeleted()
		or target_obj:GetType() == SceneObjType.MainRole
		or target_obj:GetType() == SceneObjType.TruckObj
		or (target_obj:GetType() == SceneObjType.Monster and target_obj:GetMonsterId() == 1101 and Scene.Instance:GetSceneType() == SceneType.QunXianLuanDou)
		or (target_obj:GetType() == SceneObjType.Role and self:GetMonsterSiegeCanSelect(target_obj))
		or (target_obj:GetType() == SceneObjType.Role and target_obj:GetVo().shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_QINGLOU_DANCER) then
		self:CancelSelect()
		return
	end
	if MainUICtrl.Instance.view then
		if self.last_click_obj ~= target_obj then
			self.last_click_obj = target_obj
			if MainUICtrl.Instance.view.target_view then
				MainUICtrl.Instance.view.target_view:OnSelectObjHead(target_obj)
			end
		end
	end
	if target_obj:GetType() == SceneObjType.Role then
		TASK_GUILD_AUTO = false
		TASK_RI_AUTO = false
	end
	if target_obj ~= GuajiCache.target_obj then
		self:CancelSelect()
	end
	self.last_click_obj = target_obj
	if self.select_obj then
		self.select_obj:CancelSelect()
		self.select_obj = nil
	end
	self.select_obj = target_obj
	target_obj:OnClick()
	GuajiCache.target_obj = target_obj
	GuajiCache.target_obj_id = target_obj:GetObjId()
	GuajiCache.is_click_select = SceneData:TargetSelectIsScene(select_type)

	if SceneData:TargetSelectIsSelect(select_type) then
		return
	elseif not SceneData:TargetSelectIsTask(select_type) then -- 非任务
		MoveCache.task_id = 0
	end
	if GuajiCache.guaji_type == GuajiType.Auto and target_obj:GetType() ~= SceneObjType.Monster and target_obj:GetType() ~= SceneObjType.Role then
		self:SetGuajiType(GuajiType.None)
	end
	if target_obj:GetType() == SceneObjType.Monster or target_obj:GetType() == SceneObjType.Role then
		local is_enemy, msg = Scene.Instance:IsEnemy(target_obj, {
			[SceneIgnoreStatus.MAIN_ROLE_IN_SAFE] = true,
			[SceneIgnoreStatus.OTHER_IN_SAFE] = true,
		})
		if is_enemy then
			GuajiCtrl.SetAtkValid(false)
			if GuajiCache.guaji_type == GuajiType.None then -- SceneData:TargetSelectIsScene(select_type) and
				self:SetGuajiType(GuajiType.Auto)
			end
			local x, y = target_obj:GetLogicPos()
			self:DoAttackTarget(target_obj)
		end
	elseif target_obj:GetType() == SceneObjType.Npc then
		self:ClearAllOperate()
		MoveCache.end_type = MoveEndType.ClickNpc
		MoveCache.param1 = target_obj:GetNpcId()
		self:MoveToObj(target_obj, 3)
	elseif target_obj:GetType() == SceneObjType.FallItem then
		self:ClearAllOperate()
		MoveCache.end_type = MoveEndType.PickItem
		self:MoveToObj(target_obj, 0, 0)
	elseif target_obj:GetType() == SceneObjType.GatherObj then
		self:ClearAllOperate()
		MoveCache.end_type = MoveEndType.Gather
		self:MoveToObj(target_obj, 4)
		if Scene.Instance:GetSceneType() == SceneType.ShuiJing then 	-- 将军冢手动采集取消自动采集
			CrossCrystalData.Instance:SetSelectGatherType(0)
		end
	elseif target_obj:GetType() == SceneObjType.EventObj then
		self:ClearAllOperate()
		MoveCache.end_type = MoveEndType.EventObj
		self:MoveToObj(target_obj, 2)
	end
end

function GuajiCtrl:OnObjCreate(obj)
	if Scene.Instance:IsSceneLoading() then -- 在场景加载中不触发选择对象
		self.cache_select_obj_onloading = obj
		return
	end

	if MoveCache.is_valid and not self.select_obj then
		if MoveCache.end_type == MoveEndType.FightByMonsterId then
			if 0 ~= MoveCache.param1 and obj:GetType() == SceneObjType.Monster and obj:GetMonsterId() == MoveCache.param1 then
				if 0 == self.next_scan_target_monster_time then
					self.next_scan_target_monster_time = Status.NowTime + 0.2
				end

				-- self:OnSelectObj(obj, 0 ~= MoveCache.task_id and SceneTargetSelectType.TASK or "")
				-- self:MoveToObj(obj, 4, 2, false, PlayerData.Instance:GetAttr("scene_key") or 0)
			end
		elseif MoveCache.end_type == MoveEndType.NpcTask or MoveCache.end_type == MoveEndType.ClickNpc then
			if obj:GetType() == SceneObjType.Npc and obj:GetNpcId() == MoveCache.param1 then
				self:OnSelectObj(obj, 0 ~= MoveCache.task_id and SceneTargetSelectType.TASK or "")
			end
		elseif MoveCache.end_type == MoveEndType.FollowObj then
			if obj:GetObjId() == MoveCache.param1 then
				GuajiCache.target_obj = v
			end
		end
	end
	if self.co then
		local flag = self.co(obj)
		if flag then
			self.co = nil
		end
	end
end

function GuajiCtrl:OnObjDead(obj)
	if obj == GuajiCache.target_obj or obj == self.select_obj then
		self:CancelSelect()
		GuajiCache.target_obj = nil
		self.select_obj = nil
		MoveCache.target_obj = nil
		if GuajiCache.guaji_type == GuajiType.HalfAuto then
			self:SetGuajiType(GuajiType.None)
		end
	end
end

function GuajiCtrl:OnObjDelete(obj)
	if obj == GuajiCache.target_obj or obj == self.select_obj then
		self.select_obj = nil
		GuajiCache.target_obj = nil
		MoveCache.target_obj = nil
	end
end

function GuajiCtrl:OnSceneLoadingQuite(old_scene_type, new_scene_type)

	if nil ~= self.delay_timer_on_change_scene then
		GlobalTimerQuest:CancelQuest(self.delay_timer_on_change_scene)
		self.delay_timer_on_change_scene = nil
	end

	self.delay_timer_on_change_scene = GlobalTimerQuest:AddDelayTimer(function()
		local new_scene_id = Scene.Instance:GetSceneId()
		local map_config = MapData.Instance:GetMapConfig(new_scene_id)
		if map_config then
			self.scene_type = map_config.scene_type
		end
		local new_scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		if MoveCache.is_valid then
			if MoveCache.move_type == MoveType.Pos then
				if MoveCache.scene_id == new_scene_id
					and GuajiCtrl.CheckRange(MoveCache.x, MoveCache.y, MoveCache.range + MoveCache.offset_range) then
					self:DelayArrive()
				elseif (MoveCache.scene_id == self.last_scene_id and self.last_scene_id ~= new_scene_id)
				or (MoveCache.scene_id == self.last_scene_id and self.last_scene_id == new_scene_id and self.last_scene_key == new_scene_key ) then
					if GuajiCache.guaji_type ~= GuajiType.Auto then
						self:StopGuaji()
					end
				else
					-- 1级玩家需要播放cg，转场景时不自动寻路过去。播完cg，会自动寻路
					if PlayerData.Instance:GetAttr("level") > 1 then
						self:MoveToScenePos(MoveCache.scene_id, MoveCache.x, MoveCache.y, nil, nil, MoveCache.is_auto_move)
					end
				end
			elseif MoveCache.move_type == MoveType.Fly then
				self:DelayArrive()
			end
		end
		self.last_scene_id = new_scene_id
		self.last_scene_key = new_scene_key

		if self.path_list then
			if self:CheakCanFly() and not self:CheckIsCampScene(MoveCache.scene_id) then
				self.path_list = nil
			else
				local flag = true
				for k,v in pairs(self.path_list) do
					if v then
						if v.scene_id == new_scene_id then
							self:MoveToSceneHelper(v.x, v.y)
							flag = false
							break
						end
					end
				end
				if flag then
					GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_AUTO_XUNLU, false)
					self.path_list = nil
				end
			end
		end

		self:PlayerOperation()
	end, 0.3)

	if nil ~= self.cache_select_obj_onloading then
		self:OnObjCreate(self.cache_select_obj_onloading)
		self.cache_select_obj_onloading = nil
	end
end

function GuajiCtrl:OnSceneLoadingEnter()

	local scene_type = Scene.Instance:GetSceneType()
	local scene_logic = Scene.Instance:GetCurFbSceneCfg()
	if nil ~= scene_logic and 1 == scene_logic.is_auto_guaji then
		self:StopGuaji()
		self:SetGuajiType(GuajiType.Auto)
	elseif scene_type == SceneType.Common then
		local scene_id = Scene.Instance:GetSceneId()
		if BossData.IsWorldBossScene(scene_id) then
			return
		end
		if GuajiCache.guaji_type == GuajiType.Auto then
			self:StopGuaji()
		end
	end
end

function GuajiCtrl:DelayArrive()
	if nil ~= self.delay_arrive_timer then
		GlobalTimerQuest:CancelQuest(self.delay_arrive_timer)
		self.delay_arrive_timer = nil
	end
	if MoveCache.end_type == MoveEndType.Normal then
		self:OnArrive()
		return
	end
	local scene_id = MoveCache.scene_id
	self.delay_arrive_timer = GlobalTimerQuest:AddDelayTimer(function()
		self.delay_arrive_timer = nil
		if MoveCache.is_valid and MoveCache.move_type == MoveType.Fly and scene_id == MoveCache.scene_id then
			self:OnArrive()
		end
	end, 0.5)
end

-- 移动到目标对象
function GuajiCtrl:MoveToObj(target_obj, range, offset_range, ignore_vip, scene_key)
	GuajiCtrl.SetMoveValid(true)
	MoveCache.move_type = MoveType.Obj
	MoveCache.target_obj = target_obj
	MoveCache.target_obj_id = target_obj:GetObjId()
	MoveCache.range = range or 3
	MoveCache.offset_range = offset_range or 1

	if MoveCache.end_type == MoveEndType.NpcTask then
		if target_obj:GetType() == SceneObjType.Npc and target_obj:GetNpcId() == MoveCache.param1 then
			self:OnSelectObj(target_obj, 0 ~= MoveCache.task_id and SceneTargetSelectType.TASK or "")
		end
	end
	-- local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	local x, y = target_obj:GetLogicPos()
	local max_range = math.max(MoveCache.range + MoveCache.offset_range, AtkCache.monster_range)
	-- x, y = AStarFindWay:GetTargetXY(self_x, self_y, x, y, max_range or 3)
	MoveCache.x = x
	MoveCache.y = y
	MoveCache.scene_id = Scene.Instance:GetSceneId()
	if GuajiCtrl.CheckRange(x, y, max_range) then	-- 离目标1格，允许误差1格
		if scene_key and scene_key ~= PlayerData.Instance:GetAttr("scene_key") then
			Scene.SendChangeSceneLineReq(scene_key)
		else
			self.move_target = nil
			self:OnOperate()
		end
		return
	end
	self:MoveHelper(x, y, max_range, target_obj, ignore_vip, scene_key, MoveCache.is_auto_move)
end

-- 移动到某个位置(一般情况下请调用这个函数)
function GuajiCtrl:MoveToPos(scene_id, x, y, range, offset_range, ignore_vip, scene_key, is_auto_move)
	range = range or 0
	offset_range = offset_range or 0
	-- 如果挂机的目标是做任务，则进入到NPC所在场景时自动切换到MoveToObj
	-- GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
	-- print_warning(Scene.Instance:GetSceneId(), scene_id)
	if(Scene.Instance:GetSceneId() == scene_id) then
		if MoveCache.end_type == MoveEndType.NpcTask or MoveCache.end_type == MoveEndType.ClickNpc then
			if GuajiCache.target_obj_id then
				local target_obj = Scene.Instance:GetNpcByNpcId(GuajiCache.target_obj_id)
				if target_obj then
					self:MoveToObj(target_obj, range, offset_range, ignore_vip, nil)
				end
			end
		end
	end
	local scene_type = Scene.Instance:GetSceneType()
	if (scene_type ~= SceneType.Common or self:IsSpecialCommonScene()) and scene_id ~= Scene.Instance:GetSceneId() and not self:CheakCanFly() then
		return
	end
	GuajiCtrl.SetMoveValid(true)
	MoveCache.move_type = MoveType.Pos
	MoveCache.scene_id = scene_id
	MoveCache.x = x
	MoveCache.y = y
	MoveCache.range = range or 0
	MoveCache.offset_range = offset_range or 0
	MoveCache.is_auto_move = is_auto_move or false


	if tonumber(scene_id) ~= tonumber(Scene.Instance:GetSceneId()) then
		self:MoveToScenePos(scene_id, x, y, ignore_vip, scene_key, is_auto_move)
		return
	end
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	if GuajiCtrl.CheckRange(x, y, range + MoveCache.offset_range) then
		if scene_key and scene_key ~= PlayerData.Instance:GetAttr("scene_key") then
			Scene.SendChangeSceneLineReq(scene_key)
		else
			self.move_target = nil
			self:OnOperate()
		end
		return
	end
	self:MoveHelper(x, y, range, nil, ignore_vip, scene_key, is_auto_move)
end

-- 飞行到场景的入口(特殊情况下调用，此方法会无视vip等级)
function GuajiCtrl:FlyToScene(scene_id, scene_key)
	local scene_logic = Scene.Instance:GetSceneLogic()
	local x, y = scene_logic:GetTargetScenePos(scene_id)
	if x and y then
		MoveCache.move_type = MoveType.Fly
		TaskCtrl.SendFlyByShoe(scene_id, x, y, scene_key, true)
	end
end

-- 飞行到场景的位置(特殊情况下调用，此方法会无视vip等级)
function GuajiCtrl:FlyToScenePos(scene_id, x, y, is_world_boss, scene_key)
	if self:CheakCanFly() or is_world_boss then
		self.fly_cache = {scene_id = scene_id, x = x, y = y}
		self.is_fly = true
		MoveCache.move_type = MoveType.Fly
		MoveCache.scene_id = scene_id
		MoveCache.x = x
		MoveCache.y = y
		TaskCtrl.SendFlyByShoe(scene_id, x, y, scene_key)
	else
		self:MoveToPos(scene_id, x, y, 1, 1)
	end
end

-- 移动
function GuajiCtrl:MoveHelper(x, y, range, target_obj, ignore_vip, scene_key, is_auto_move)
	if Scene.Instance:IsSceneLoading() then
		return
	end

	self.last_mount_time = Status.NowTime
	self.auto_mount_up = true

	if TombExploreFBView.GatherId > 0 and MoveCache.param1 ~= TombExploreFBView.GatherId then
		TombExploreFBView.GatherId = 0
	end
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	-- if AStarFindWay:IsBlock(x, y) then
	-- 	if GuajiCache.guaji_type ~= GuajiType.Follow then
	-- 		return
	-- 	end
	-- end

	-- local cfg = ConfigManager.Instance:GetAutoConfig("millionaire_auto").other[1]
	-- local can_fly = true
	-- if GuajiCache.target_obj_id and (cfg and cfg.gather_id) == GuajiCache.target_obj_id then
	-- 	can_fly = false
	-- end
	-- if (ignore_vip or VipData.Instance:GetIsCanFly(GameVoManager.Instance:GetMainRoleVo().vip_level)) and self:CheakCanFly(true) and can_fly then
	-- 	local distance = (x - self_x) * (x - self_x) + (y - self_y) * (y - self_y)
	-- 	if distance > 65 * 65 then
	-- 		self:FlyToScenePos(Scene.Instance:GetSceneId(), x, y, false, scene_key)
	-- 		return
	-- 	end
	-- end

	local new_range = range
	if target_obj and target_obj:GetType() == SceneObjType.Monster then
		local prof = GameVoManager.Instance:GetMainRoleVo() and GameVoManager.Instance:GetMainRoleVo().prof or 1
		local can_use, skill_range = SkillData.Instance:CanUseSkill(use_prof_normal_skill_list[prof])
		new_range = skill_range or 6
	elseif target_obj and target_obj:GetType() == SceneObjType.Role then
		local can_use, skill_range = SkillData.Instance:CanUseSkill(AtkCache.skill_id)
		new_range = skill_range and (skill_range - 4) or 6
	end

	if scene_key and scene_key ~= PlayerData.Instance:GetAttr("scene_key") then
		Scene.SendChangeSceneLineReq(scene_key)
		return
	end

	x, y, new_range = AStarFindWay:GetTargetXY(self_x, self_y, x, y, new_range)
	Scene.Instance:GetMainRole():DoMoveOperate(x, y, new_range, self.on_arrive_func, is_auto_move)

	self.move_target = target_obj
	self.move_target_left_time = 1.0
	if (x - self_x) * (x - self_x) + (y - self_y) * (y - self_y) > 400 then
		GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_AUTO_XUNLU, true)
	end
end

-- 移动到某个场景位置
function GuajiCtrl:MoveToScenePos(scene_id, x, y, ignore_vip, scene_key, is_auto_move)
	if Scene.Instance:GetSceneId() == scene_id then
		self:MoveHelper(x, y, MoveCache.range, nil, ignore_vip, scene_key, is_auto_move)
		return
	end

	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if scene_cfg then
		if scene_cfg.levellimit > GameVoManager.Instance:GetMainRoleVo().level then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.CanNotEnter, PlayerData.GetLevelString(scene_cfg.levellimit)))
			self:StopGuaji()
			return
		end
	end

	if self:CheakCanFly() then
		if self:CheckIsCampScene(scene_id) then 																		-- 国家场景不能直接飞到目标点
			if scene_id == Scene.Instance:GetSceneId() or Scene.Instance:GetSceneId() == MapData.WORLDMAPCFG[1] then 	-- 同场景走 否则飞到中立区
				-- self:MoveToPos(scene_id, x, y)
				MoveCache.scene_id = scene_id
				MoveCache.x = x
				MoveCache.y = y
				local scene_logic = Scene.Instance:GetSceneLogic()
				self.path_list = scene_logic:GetScenePath(Scene.Instance:GetSceneId(), scene_id)
				if self.path_list then
					local path = self.path_list[1]
					if path then
						self:MoveToSceneHelper(path.x, path.y, is_auto_move)
					end
				end
			else
				local cache = Scene.Instance:GetMoveToPosCache()
				cache.x = x
				cache.y = y
				cache.scene_id = scene_id
				self:FlyToScene(MapData.WORLDMAPCFG[1], scene_key)
			end
		elseif MoveCache.cant_fly == false then
			local shot_id = MapData.Instance:GetFlyShoeId()
			local num = ItemData.Instance:GetItemNumInBagById(shot_id)
			local enough_money = ShopData.Instance:CheckCanBuyItem(shot_id)
			if VipData.Instance:GetIsCanFly(GameVoManager.Instance:GetMainRoleVo().vip_level) or num > 0 then
				self:FlyToScenePos(scene_id, x, y, false, scene_key)
			else
				if enough_money ~= nil then
			 		TaskCtrl.SendFlyByShoe(scene_id, x, y, scene_key, nil, nil, true)
			 	else
			 		if scene_id ~= Scene.Instance:GetSceneId() then
				 		local cache = Scene.Instance:GetMoveToPosCache()
						cache.x = x
						cache.y = y
						cache.scene_id = scene_id
			 		end
			 		self:FlyToScene(scene_id, scene_key)
			 	end
			end
		else --挖宝
			self:FlyToScene(scene_id, scene_key)
		end
	else
		MoveCache.scene_id = scene_id
		MoveCache.x = x
		MoveCache.y = y
		local scene_logic = Scene.Instance:GetSceneLogic()
		self.path_list = scene_logic:GetScenePath(Scene.Instance:GetSceneId(), scene_id)
		if self.path_list then
			local path = self.path_list[1]
			if path then
				self:MoveToSceneHelper(path.x, path.y, is_auto_move)
				path = nil
			end
		end
	end
end

-- 移动到其它场景
function GuajiCtrl:MoveToSceneHelper(x, y, is_auto_move)
	self.last_mount_time = Status.NowTime
	self.auto_mount_up = true
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	x, y, range = AStarFindWay:GetTargetXY(self_x, self_y, x, y, 1)
	if nil == is_auto_move then
		is_auto_move = true
	end
	Scene.Instance:GetMainRole():DoMoveOperate(x, y, range,
		function()
			if self.path_list then
				if self:CheakCanFly() and not self:CheckIsCampScene(MoveCache.scene_id) then
					self.path_list = nil
				else
					local flag = true
					for k,v in pairs(self.path_list) do
						if v.scene_id == Scene.Instance:GetSceneId() then
							self:MoveToSceneHelper(v.x, v.y)
							flag = false
							GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_AUTO_XUNLU, false)
							break
						end
					end
					if flag then
						self.path_list = nil
					end
				end
			end
		end, is_auto_move)
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_AUTO_XUNLU, true)
end

-- 移动到某个场景
-- 找不到场景入口点的情况下则找该场景的传送点
function GuajiCtrl:MoveToScene(scene_id)
	if Scene.Instance:GetSceneId() == scene_id then
		return
	end
	--在非普通场景或者特殊的普通场景不能传送
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type ~= SceneType.Common or self:IsSpecialCommonScene() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
		return
	end

	local scene_logic = Scene.Instance:GetSceneLogic()
	local x, y = scene_logic:GetTargetScenePos(scene_id)
	if x == nil or y == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotToTarget)
		return
	end
	self:MoveToScenePos(scene_id, x, y)
end

-- 到达
function GuajiCtrl:OnArrive()
	self.move_target = nil
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if MoveCache.move_type == MoveType.Obj then
		if nil ~= MoveCache.target_obj and MoveCache.target_obj == Scene.Instance:GetObj(MoveCache.target_obj_id) then
			local x, y = MoveCache.target_obj:GetLogicPos()
			if not GuajiCtrl.CheckRange(x, y, MoveCache.range + MoveCache.offset_range) then
				self:MoveToObj(MoveCache.target_obj, MoveCache.range, MoveCache.offset_range)
				return
			end
		end
	elseif MoveCache.move_type == MoveType.Pos or MoveCache.move_type == MoveType.Fly then
		if MoveCache.scene_id ~= Scene.Instance:GetSceneId() then
			return
		end
		if not GuajiCtrl.CheckRange(MoveCache.x, MoveCache.y, MoveCache.range + MoveCache.offset_range) then
			self:MoveToPos(MoveCache.scene_id, MoveCache.x, MoveCache.y, MoveCache.range, MoveCache.offset_range, nil, nil, MoveCache.is_auto_move)
			return
		end
	end
	self:OnOperate()
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_AUTO_XUNLU, false)
end

-- 处理移动后的操作逻辑
function GuajiCtrl:OnOperate()
	if not MoveCache.is_valid then
		return
	end
	GuajiCtrl.SetMoveValid(false)

	local end_type = MoveCache.end_type
	MoveCache.end_type = MoveEndType.Normal
	MoveCache.cant_fly = false

	if end_type == MoveEndType.Fight then
		self:OnOperateFight()
	elseif end_type == MoveEndType.AttackTarget then
		self:OnOperateAttackTarget()
	elseif end_type == MoveEndType.ClickNpc then
		self:SetGuajiType(GuajiType.None)
		Scene.Instance:GetMainRole():StopMove()
		self:OnOperateClickNpc()
	elseif end_type == MoveEndType.NpcTask then
		self:SetGuajiType(GuajiType.None)
		Scene.Instance:GetMainRole():StopMove()
		self:OnOperateNpcTalk()
	elseif end_type == MoveEndType.FightByMonsterId then
		self:OnOperateFightByMonsterId()
	elseif end_type == MoveEndType.Gather then
		self:OnOperateGather()
	elseif end_type == MoveEndType.GatherById then
		self:OnOperateGatherById()
	elseif end_type == MoveEndType.PickItem then
		self:OnOperatePickItem()
	elseif end_type == MoveEndType.Auto then
		self:OnOperateAutoFight()
	elseif end_type == MoveEndType.FollowObj then
		self:OnOperateFollowObj()
	elseif end_type == MoveEndType.EventObj then
		self:OnOperateZhuaGui()
	elseif end_type == MoveEndType.PickAroundItem then
		self:OnOperatePickAroundItem()
	elseif end_type == MoveEndType.DoNothing then
		--donothing
	else
		if GuajiCache.guaji_type == GuajiType.Auto then return end
		self:StopGuaji()
	end
	local arrive_call_back = self.arrive_call_back
	self.arrive_call_back = nil
	if nil ~= arrive_call_back then
		arrive_call_back()
	end
	Scene.Instance:ClearMovePosCache()
end

function GuajiCtrl:TaskToGuaJi()
	--[[local task_id = TaskData.Instance:GetCurTaskId()
	if nil ~= task_id then
		local task_cfg = TaskData.Instance:GetTaskConfig(task_id)
		local first_target = task_cfg.target_obj[1]
		if first_target and task_cfg.condition == TASK_COMPLETE_CONDITION.KILL_MONSTER then
			GuajiCache.monster_id = first_target.id
			self:SetGuajiType(GuajiType.Monster)
			self:DoAttack()
			return true
		end
	else
		return false
	end]]
	return false
end

-- 战斗1
function GuajiCtrl:OnOperateFight()
	if not AtkCache.is_valid then
		return
	end
	GuajiCtrl.SetAtkValid(false)

	if nil == AtkCache.target_obj then
		self:DoAttack()
	else
		if AtkCache.target_obj == Scene.Instance:GetObj(AtkCache.target_obj_id) then
			local is_guaji = self:TaskToGuaJi()
			if not is_guaji then
				local max_range = math.max(AtkCache.range + AtkCache.offset_range, AtkCache.monster_range)
				if GuajiCtrl.CheckRange(MoveCache.x, MoveCache.y, max_range) then
					self:DoAttack()
				end
			end
		else
			self:TaskToGuaJi()
		end
	end
end

function GuajiCtrl:DoAttack()
	local main_role = Scene.Instance:GetMainRole()
	local is_not_normal_skill = SkillData.IsNotNormalSkill(AtkCache.skill_id)
	if not main_role:IsAtk() or is_not_normal_skill then
		main_role:SetAttackParam(AtkCache.is_specialskill)
		main_role:DoAttack(AtkCache.skill_id, AtkCache.x, AtkCache.y, AtkCache.target_obj_id)
		if AtkCache.skill_id == self.skill_id then
			self.skill_id = nil
		end
		if GuajiCache.guaji_type == GuajiType.None and self.select_obj and Scene.Instance:IsEnemy(self.select_obj) then
			if self.select_obj:IsMonster() then
				self:SetGuajiType(GuajiType.Auto)
			elseif self.select_obj:IsRole() then
				self:SetGuajiType(GuajiType.HalfAuto)
			end
		end
	end
end

-- 攻击目标
function GuajiCtrl:OnOperateAttackTarget()
	if nil ~= MoveCache.target_obj and MoveCache.target_obj == Scene.Instance:GetObj(MoveCache.target_obj_id) then
		local is_enemy, msg = Scene.Instance:IsEnemy(MoveCache.target_obj)
		if is_enemy then
			self:DoAttackTarget(MoveCache.target_obj)
		else
			TipsCtrl.Instance:ShowSystemMsg(msg)
		end
	end
end

--播放NPC对话声音
function GuajiCtrl:PlayNpcVoice(npc_obj_id)
	if npc_obj_id then
		local npc_obj = Scene.Instance:GetObjectByObjId(npc_obj_id)
		if npc_obj then
			local npc_vo = npc_obj:GetVo()
			if npc_vo then
				local npc_config = ConfigManager.Instance:GetAutoConfig("npc_auto").npc_list
				local npc_data = npc_config[npc_vo.npc_id or -1]
				if npc_data then
					local voice_id = npc_data.voiceid
					if voice_id and voice_id ~= "" then
						if self.last_play_id == voice_id then
							if Status.NowTime - self.npc_talk_interval < self.last_play_time then
								return
							end
						end
						self.last_play_id = voice_id
						self.last_play_time = Status.NowTime
						local bundle, asset = ResPath.GetNpcVoiceRes(voice_id)
						AudioManager.PlayAndForget(bundle, asset)
					end
				end
			end
		end
	end
end

-- 与npc对话(点击)
function GuajiCtrl:OnOperateClickNpc()
	if FunctionGuide.Instance:GetGuideViewIsOpen() then
		return
	end
	if not MoveCache.target_obj then
		if not MoveCache.param1 then return end
		MoveCache.target_obj = Scene.Instance:GetNpcByNpcId(MoveCache.param1)
	end
	if not MoveCache.target_obj then print_warning("No target_obj", MoveCache.param1) return end
	if nil ~= MoveCache.target_obj and MoveCache.target_obj == Scene.Instance:GetObj(MoveCache.target_obj_id) then
		local npc_obj_id = MoveCache.target_obj_id
		TaskCtrl.Instance:SendNpcTalkReq(npc_obj_id, nil)
		GuajiCache.target_obj = nil
		self.select_obj = nil
	end
end

-- 与npc对话(任务)
function GuajiCtrl:OnOperateNpcTalk()
	local npc_id = MoveCache.param1
	local npc = Scene.Instance:GetNpcByNpcId(npc_id)
	if nil ~= npc_id then
		if nil ~= npc then
			TaskCtrl.Instance:SendNpcTalkReq(npc:GetObjId(), nil)
		else
			-- TaskCtrl.Instance:SendNpcTalkReq(nil, npc_id)
			self.co = function(obj)
				if not obj then return false end
				if obj:GetType() == SceneObjType.Npc and obj:GetNpcId() == npc_id then
					self:OnSelectObj(obj, 0 ~= MoveCache.task_id and SceneTargetSelectType.TASK or "")
					TaskCtrl.Instance:SendNpcTalkReq(obj:GetObjId(), nil)
					return true
				else
					return false
				end
			end
		end
		-- local task_id = TaskData.Instance:GetCurTaskId()
		-- if task_id and TaskData.Instance:GetTaskIsCanCommint(task_id) then
		-- 	TaskCtrl.Instance:CancelTask()
		-- end
	end
end

-- 打怪
function GuajiCtrl:OnOperateFightByMonsterId()
	self:SetGuajiType(GuajiType.Monster)
	local monster = Scene.Instance:SelectMinDisMonster(MoveCache.param1, Scene.Instance:GetSceneLogic():GetGuajiSelectObjDistance())
	if nil ~= monster then
		-- self:SetGuajiType(GuajiType.Auto)
		self:DoAttackTarget(monster)
	else
		print_warning("####################### nil == monster")
	end
end

-- 采集
function GuajiCtrl:OnOperateGather()
	-- if nil ~= MoveCache.target_obj and MoveCache.target_obj == Scene.Instance:GetObj(MoveCache.target_obj_id) then
	if nil ~= MoveCache.target_obj then
		if MoveCache.target_obj.vo.special_gather_type == SPECIAL_GATHER_TYPE.GUILD_BONFIRE then
			GuildBonfireCtrl.Instance:Open(MoveCache.target_obj)
		else
			self:CheckCanGather(MoveCache.target_obj)
		end
	end
end

function GuajiCtrl:CheckCanGather(obj)
	if not obj then return false end

	if Scene.Instance:GetSceneType() == SceneType.CrossGuildBattle or Scene.Instance:GetSceneType() == SceneType.XianYangCheng then
		for k, v in pairs(LianFuDailyData.JuDianGatherIdList) do
			if v == obj:GetGatherId() then
				return
			end
		end
	end

	if Scene.Instance:GetSceneType() == SceneType.Fishing then
		local steal_count = FishingData.Instance:GetFishingOtherCfg().steal_count
		local steal_fish_count = FishingData.Instance:GetFishingUserInfo().steal_fish_count
		if steal_fish_count >= steal_count then
			SysMsgCtrl.Instance:ErrorRemind(Language.Fishing.NoHasMyStealCount)
			return
		end
	end

	-- 大富豪是否能采集
	local cfg = ConfigManager.Instance:GetAutoConfig("millionaire_auto").gather_box_cfg or {}
	for k, v in pairs(cfg) do
		if v.gather_id == obj:GetGatherId() then
			local activity_cfg = ActivityData.Instance:GetActivityConfig(DaFuHaoDataActivityId.ID)
			if activity_cfg ~= nil then
				if not DaFuHaoData.Instance:GetIsCanGather() then
					TipsCtrl.Instance:ShowSystemMsg(Language.DaFuHao.CanNotGather)
					return
				end
				local level_limit = activity_cfg.min_level
				local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
				if main_role_vo.level < level_limit then
					TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Activity.GatherLevelLimit, level_limit))
					return
				end
			end
		end
	end

	Scene.SendStartGatherReq(obj:GetObjId(), 1)
end

-- 根据采集id采集
function GuajiCtrl:OnOperateGatherById()
	local gather_id = MoveCache.param1
	local x = MoveCache.x
	local y = MoveCache.y
	local obj = Scene.Instance:GetGatherByGatherIdAndPosInfo(gather_id, x, y)

	if nil ~= obj then
		local gather_count = 1
		obj:OnClick()
		self:CheckCanGather(obj)
	else
		print_warning("####################### nil == obj", Scene.Instance:GetObjByTypeAndKey(SceneObjType.GatherObj, GuajiCache.target_obj_id))
	end
end

-- 拾取
function GuajiCtrl:OnOperatePickItem()
	if nil ~= MoveCache.target_obj and MoveCache.target_obj == Scene.Instance:GetObj(MoveCache.target_obj_id) then
		Scene.ScenePickItem({MoveCache.target_obj_id})
	end
end

-- 自动进入战斗状态
function GuajiCtrl:OnOperateAutoFight()
	self:SetGuajiType(GuajiType.Auto)
end

--抓鬼
function GuajiCtrl:OnOperateZhuaGui()
	if MoveCache.target_obj then
		MoveCache.target_obj:ArriveOperateHandle()
	end
end

function GuajiCtrl:OnOperatePickAroundItem()
	Scene.Instance:PickAllFallItem()
	self.goto_pick_x = 0
	self.goto_pick_y = 0
	self.next_can_goto_pick_time = Status.NowTime + 0.2
end

-- 跟随obj
function GuajiCtrl:OnOperateFollowObj()
	if Scene.Instance:GetMainRole():GetObjId() == MoveCache.param1 then
		print_warning("不能跟随自己")
		self:StopGuaji()
		return
	end
	MoveCache.end_type = MoveEndType.FollowObj
end

function GuajiCtrl:ClearAllOperate()
	GuajiCtrl.SetAtkValid(false)
	GuajiCtrl.SetMoveValid(false)
	MoveCache.end_type = MoveEndType.Normal
	self.skill_id = nil
	self.path_list = nil
	self.move_target = nil
	self.goto_pick_x = 0
	self.goto_pick_y = 0
	self.next_can_goto_pick_time = 0
	self.next_scan_target_monster_time = 0
	self.arrive_call_back = nil
	MoveCache.cant_fly =  false
	MoveCache.is_auto_move = true
end

function GuajiCtrl:ClearTaskOperate(not_clear_toggle)
	self:ClearAllOperate()
	-- self:CancelSelect()
	-- self:SetGuajiType(GuajiType.None)
	if not_clear_toggle then
		return
	end
	GlobalEventSystem:Fire(MainUIEventType.MAINUI_CLEAR_TASK_TOGGLE)
end

-- 攻击
local stand_on_atk_time = nil
function GuajiCtrl:UpdateAtk(now_time)
	if AtkCache.target_obj then
		-- 冲锋逻辑处理 
		--[[
			原本是写在DoAttackTarget里面的
			由于AtkCache.is_valid和MoveCache.is_valid这两个导致上面那个方法只会进入一次
			从远距离跑到冲锋距离后也不会冲锋
			所以写在这边
		]]
		local is_can_chongfeng = false
		local main_role = Scene.Instance:GetMainRole()
		-- 不是假副本的情况下才能冲锋
		if Scene.Instance:GetSceneType() ~= SceneType.GuideFb and AtkCache.target_obj:GetType() == SceneObjType.Monster then
			local main_role_x, main_role_y = main_role:GetLogicPos()
			local target_x, target_y = AtkCache.target_obj:GetLogicPos()
			local delta_pos = u3d.v2Sub(u3d.vec2(target_x, target_y), u3d.vec2(main_role_x, main_role_y))
			local distance = u3d.v2Length(delta_pos)

			local is_yunbiao = YunbiaoData.Instance:GetIsHuShong()

			if distance > COMMON_CONSTS.CHONGFENG_MIN_DIS 
				and distance <= COMMON_CONSTS.CHONGFENG_MAX_DIS 
				and not is_yunbiao then

				is_can_chongfeng = true
			end

			local bianshen_type = FamousGeneralData.Instance:GetCurUseSeq() or -1
			if 0 <= bianshen_type then
				is_can_chongfeng = false
			end

			local role_vo = main_role:GetVo()
			-- 名将体验状态不允许冲锋（假变身 不走上面的当前使用seq）
			if role_vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER then
				is_can_chongfeng = false
			end
			-- 容错处理,保证打人不冲锋，在活动，副本逻辑里其他同学重写GetGuiJiMonsterEnemy时会返回role
			-- 非近战职业不冲锋
			if (AtkCache.target_obj:GetType() == SceneObjType.Role 
					and AtkCache.target_obj:GetVo().is_shadow ~= 1)
					or role_vo.prof == GameEnum.ROLE_PROF_3 
					or role_vo.prof == GameEnum.ROLE_PROF_4 then
				
				is_can_chongfeng = false
			end
		end
		if is_can_chongfeng then
			main_role:ReqChongfengToObj(AtkCache.target_obj,  function()
				 -- 冲锋完必须同步一次，因为冲锋完释放技能时会检测客户端当前坐标与服务器坐标是否完成一致
				 -- 否则会fixpos。
				 -- 冲锋设计缺陷，客户端发送目标id。服务器跟客户端各自计算冲锋到的目标点，这里有可能有误差
				 -- 导致释放技能时坐标不一致而触发fixpos
				main_role:SendMoveReq()
				main_role:DoStand()

				-- 下一帧马上发起攻击，才有击锋造成伤害之感 
				-- self.next_scan_target_monster_time = 0
			end)
		end
	end

	if MoveCache.is_valid then
		stand_on_atk_time = stand_on_atk_time or now_time + 0.5
		if Scene.Instance:GetMainRole():IsStand() and stand_on_atk_time < now_time then --容错，如果在挂机中站着不动，就重新进入挂机
			MoveCache.is_valid = false
		end
		return
	end
	stand_on_atk_time = nil

	MoveCache.end_type = MoveEndType.Fight

	if nil ~= AtkCache.target_obj then
		if AtkCache.target_obj == Scene.Instance:GetMainRole() then
			GuajiCtrl.SetAtkValid(false)
			self:DoAttack()
			return
		end
		if AtkCache.target_obj ~= Scene.Instance:GetObj(AtkCache.target_obj_id) then
			GuajiCtrl.SetAtkValid(false)
			return
		end

		self:MoveToObj(AtkCache.target_obj, AtkCache.range, AtkCache.offset_range)
	else
		self:MoveToPos(Scene.Instance:GetSceneId(), AtkCache.x, AtkCache.y, AtkCache.range, AtkCache.offset_range)
	end
end

function GuajiCtrl:UpdateFollowAtkTarget(now_time)
	if MoveEndType.Fight == MoveCache.end_type and nil ~= AtkCache.target_obj and now_time >= AtkCache.next_sync_pos_time then
		local new_x, new_y = AtkCache.target_obj:GetLogicPos()
		if new_x ~= AtkCache.x or new_y ~= AtkCache.y then
			AtkCache.next_sync_pos_time = now_time + 0.1
			AtkCache.x = new_x
			AtkCache.y = new_y
			self:MoveToObj(AtkCache.target_obj, AtkCache.range, AtkCache.offset_range)
		end
	end
end

-- 挂机逻辑
local get_move_obj_time = -1
function GuajiCtrl:UpdateGuaji(now_time)
	if GuajiCache.guaji_type == GuajiType.Follow then
		if GuajiCache.target_obj then
			if GuajiCache.target_obj:IsDeleted() then
				print_warning("目标离开视野")
				GuajiCache.target_obj = nil
				self:StopGuaji()
				return
			end
			local target_x, target_y = GuajiCache.target_obj:GetLogicPos()
			local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
			local delta_pos = u3d.vec2(target_x - self_x, target_y - self_y)
			local distance = u3d.v2Length(delta_pos)
			if distance > 4 then
				self:MoveToObj(GuajiCache.target_obj, 1, 1)
			end
		else
			local obj_list = Scene.Instance:GetObjList()
			if obj_list then
				for k,v in pairs(obj_list) do
					if v:GetObjId() == MoveCache.param1 then
						GuajiCache.target_obj = v
						break
					end
				end
			end
		end
		return
	end
	if (MoveCache.is_valid and not Scene.Instance:GetMainRole():IsStand())
		or now_time < SkillData.Instance:GetGlobalCDEndTime()
		or now_time < FightCtrl.Instance:NextCanAtkTime() then
		return
	end
	local target_obj = nil

	if GuajiCache.guaji_type == GuajiType.Auto then
		target_obj = self:SelectAtkTarget(true)
		local scene_logic = Scene.Instance:GetSceneLogic()

		if nil == target_obj and scene_logic then
			local main_role = Scene.Instance:GetMainRole()
			if Status.NowTime >= self.guai_ji_next_move_time and GuajiType.HalfAuto ~= GuajiCache.guaji_type and get_move_obj_time > 0 and get_move_obj_time < now_time then
				self.guai_ji_next_move_time = Status.NowTime + 2
				get_move_obj_time = -1
				-- 默认了场景逻辑的挂机坐标,取不到默认全地图搜怪
				local target_x, target_y = scene_logic:GetGuajiPos()
				if nil == target_x or nil == target_y then
					if scene_logic:CanGetMoveObj() then
						target_x, target_y = self:GetGuiJiMonsterPos()
					end
				end

				if nil ~= target_x and nil ~= target_y then
					MoveCache.is_move_scan = true
					MoveCache.end_type = MoveEndType.Auto
					self:MoveToPos(Scene.Instance:GetSceneId(), target_x, target_y, 6, 0)
				end
			end
			if get_move_obj_time < 0 then
				get_move_obj_time = now_time + 0.5
			end
		else
			get_move_obj_time = -1
		end
	elseif GuajiCache.guaji_type == GuajiType.Monster then
		if 0 == GuajiCache.monster_id then
			self:SetGuajiType(GuajiType.None)
			return
		end

		if nil ~= GuajiCache.target_obj and GuajiCache.target_obj:GetType() == SceneObjType.Monster
			and GuajiCache.target_obj == Scene.Instance:GetObj(GuajiCache.target_obj_id)
			and GuajiCache.target_obj:GetMonsterId() == GuajiCache.monster_id
			and Scene.Instance:IsEnemy(GuajiCache.target_obj) then
			target_obj = GuajiCache.target_obj
		else

			target_obj = Scene.Instance:SelectMinDisMonster(GuajiCache.monster_id, Scene.Instance:GetSceneLogic():GetGuajiSelectObjDistance())
		end
	elseif GuajiCache.guaji_type == GuajiType.HalfAuto then
	-- else
		if nil ~= GuajiCache.target_obj
			and GuajiCache.target_obj == Scene.Instance:GetObj(GuajiCache.target_obj_id)
			and (Scene.Instance:IsEnemy(GuajiCache.target_obj) or GuajiCache.target_obj:IsNpc())then
			target_obj = GuajiCache.target_obj
		-- else
		-- 	print("############################")
		-- 	self:SetGuajiType(GuajiType.None)
		end
	end
	self:DoAttackTarget(target_obj)
end



local anger_skill_list = {
	--5,
	151,251,351,451
}

local use_general_skill_list = {
	601, 602,
}

function GuajiCtrl:DoAttackTarget(target_obj)
	--if Status.NowTime < FightCtrl.Instance:NextCanAtkTime() then
	--end
	if MoveCache.is_valid or Status.NowTime < FightCtrl.Instance:NextCanAtkTime() or GuajiCache.guaji_type == GuajiType.None then
		return
	end

	local main_role = Scene.Instance:GetMainRole()
	if nil == target_obj or not main_role:CanAttack() then
		return false
	end

	-- 冲锋过程中不发起战斗，也不寻找新怪，否则可能冲过去后又冲回来，
	-- 因为怪是在冲锋过程中寻的（因为GetTargetObj有可能返回nil)
	if main_role:GetIsSpecialMove() then 
		return false
	end

	if not Scene.Instance:IsEnemy(target_obj) then
		return false
	end

	if main_role:IsInSafeArea() then											-- 自己在安全区
		TipsCtrl.Instance:ShowSystemMsg(Language.Fight.InSafe)
		return false
	end

	if target_obj:IsInSafeArea() then											-- 目标在安全区
		TipsCtrl.Instance:ShowSystemMsg(Language.Fight.TargetInSafe)
		return false
	end

	if target_obj.vo.special_param == MONSTER_SPECIAL_PARAM.MONSTER_SPECIAL_PARAM_CAPTIVE_MALE 			-- 目标为连服场景中俘虏
		or target_obj.vo.special_param == MONSTER_SPECIAL_PARAM.MONSTER_SPECIAL_PARAM_CAPTIVE_FEMALE then
		return false
	end

	target_obj:OnClick()
	if MainUICtrl.Instance.view then
		if(self.last_click_obj ~= target_obj) then
			self.last_click_obj = target_obj
			MainUICtrl.Instance.view.target_view:OnSelectObjHead(target_obj)
		end
	end

	-- -- 冲锋逻辑处理
	-- local is_can_chongfeng = false
	-- if target_obj:GetType() == SceneObjType.Monster then
	-- 	local main_role_x, main_role_y = main_role:GetLogicPos()
	-- 	local target_x, target_y = target_obj:GetLogicPos()
	-- 	local delta_pos = u3d.v2Sub(u3d.vec2(target_x, target_y), u3d.vec2(main_role_x, main_role_y))
	-- 	local distance = u3d.v2Length(delta_pos)

	-- 	local is_yunbiao = YunbiaoData.Instance:GetIsHuShong()

	-- 	if distance > COMMON_CONSTS.CHONGFENG_MIN_DIS 
	-- 		and distance <= COMMON_CONSTS.CHONGFENG_MAX_DIS 
	-- 		and not is_yunbiao then

	-- 		is_can_chongfeng = true
	-- 	end

	-- 	local bianshen_type = FamousGeneralData.Instance:GetCurUseSeq() or -1
	-- 	if 0 <= bianshen_type then
	-- 		is_can_chongfeng = false
	-- 	end

	-- 	-- 容错处理,保证打人不冲锋，在活动，副本逻辑里其他同学重写GetGuiJiMonsterEnemy时会返回role
	-- 	-- 非近战职业不冲锋
	-- 	local role_vo = main_role:GetVo()
	-- 	if (target_obj:GetType() == SceneObjType.Role 
	-- 			and target_obj:GetVo().is_shadow ~= 1)
	-- 			or role_vo.prof == GameEnum.ROLE_PROF_3 
	-- 			or role_vo.prof == GameEnum.ROLE_PROF_4 then
			
	-- 		is_can_chongfeng = false
	-- 	end
	-- end
	-- if is_can_chongfeng then
	-- 	main_role:ReqChongfengToObj(target_obj,  function()
	-- 		 -- 冲锋完必须同步一次，因为冲锋完释放技能时会检测客户端当前坐标与服务器坐标是否完成一致
	-- 		 -- 否则会fixpos。
	-- 		 -- 冲锋设计缺陷，客户端发送目标id。服务器跟客户端各自计算冲锋到的目标点，这里有可能有误差
	-- 		 -- 导致释放技能时坐标不一致而触发fixpos
	-- 		main_role:SendMoveReq()
	-- 		main_role:DoStand()

	-- 		-- 下一帧马上发起攻击，才有击锋造成伤害之感 
	-- 		-- self.next_scan_target_monster_time = 0
	-- 	end)
	-- 	return true
	-- end

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local cur_general = FamousGeneralData.Instance:GetCurUseSeq()
	local has_general_skill = FamousGeneralData.Instance:GetHasGeneralSkill()
	if cur_general ~= -1 or has_general_skill then
		if self.skill_id then
			if FightCtrl.Instance:TryUseRoleSkill(self.skill_id, target_obj) or SkillData.Instance:IsSkillCD(self.skill_id) then
				self.skill_id = nil
				local main_role = Scene.Instance:GetMainRole()
				if main_role then
					main_role:ResetAttackIndex()
				end
				return true
			else
				return false
			end
		end
		
		if self.use_skill and (not target_obj:IsRole() or Scene.Instance:GetCurFbSceneCfg().use_skill == 1) and PlayerData.Instance.role_vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then
			for _, v in ipairs(use_general_skill_list or {}) do
				if FightCtrl.Instance:TryUseRoleSkill(v, target_obj) then
					local main_role = Scene.Instance:GetMainRole()
					if main_role then
						main_role:ResetAttackIndex()
					end
					return true
				end
			end
		end

		if FightCtrl.Instance:TryUseRoleSkill(600, target_obj) then
			return true
		end

		return false
	end

	if self.skill_id then
		if FightCtrl.Instance:TryUseRoleSkill(self.skill_id, target_obj) or SkillData.Instance:IsSkillCD(self.skill_id) then
			self.skill_id = nil
			return true
		else
			return false
		end
	else
		if self.use_anger_skill then
			if anger_skill_list[1] then
				local anger_skill = anger_skill_list[prof]
				local war_scene_anger = SkillData.Instance:GetWarSceneAngerSkill()
				if war_scene_anger then
					anger_skill = war_scene_anger
				end

				if FightCtrl.Instance:TryUseRoleSkill(anger_skill, target_obj) then
					return true
				end
			end
		end
		if self.use_goddess_skill then
			local goddess_skill_info = SkillData.Instance:GetCurGoddessSkill()
			if goddess_skill_info then
				if FightCtrl.Instance:TryUseRoleSkill(goddess_skill_info.skill_id, target_obj) then
					return true
				end
			end
		end

		-- 挂机中连招不放技能
		local is_lianzhaoing = false
		if not SkillData.IsNotNormalSkill(main_role:GetLastSkillId())
			and main_role:GetLastSkillIndex() < 2 then
			is_lianzhaoing = true
		end

		if not is_lianzhaoing
			and self.use_skill
			and (not target_obj:IsRole() or Scene.Instance:GetCurFbSceneCfg().use_skill == 1)
			and PlayerData.Instance.role_vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then

			local use_skill_list = use_prof_skill_list[prof] or {}
			local war_scene_skill_list = SkillData.Instance:GetUseWarSceneSkill()
			if war_scene_skill_list then
				use_skill_list = war_scene_skill_list
			end
			for _, v in ipairs(use_skill_list) do
				if FightCtrl.Instance:TryUseRoleSkill(v, target_obj) then
					return true
				end
			end
		end

		if use_prof_normal_skill_list[prof] then
			if FightCtrl.Instance:TryUseRoleSkill(use_prof_normal_skill_list[prof], target_obj) then
				return true
			end
		end
	end
	return false
end

-- 停止挂机
function GuajiCtrl:StopGuaji()
	MoveCache.is_move_scan = false
	MoveCache.task_id = 0
	TaskData.Instance:SetCurTaskId(0)
	self:ClearTaskOperate()
	self:SetGuajiType(GuajiType.None)
	Scene.Instance:GetMainRole():StopMove()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

-- 挂机时的移动处理
function GuajiCtrl:DoMoveByClick(x, y)
	if(GuajiCache.guaji_type == GuajiType.Auto) then
		self:StopGuaji()
		Scene.Instance:GetMainRole():ChangeToCommonState()
		self:MoveToPos(self.last_scene_id, x, y, 3, 1)
	else
		self:StopGuaji()
	end
	self.skill_id = nil
	TombExploreFBView.GatherId = 0
	if SkyMoneyAutoTaskEvent.CancelHightLightFunc then
		SkyMoneyAutoTaskEvent.CancelHightLightFunc()
		SkyMoneyAutoTaskEvent.CancelHightLightFunc = nil
	end

	if DaFuHaoAutoGatherEvent.func then
		DaFuHaoAutoGatherEvent.func()
	end
	if ShengDiFuBenAutoGatherEvent.func then
		ShengDiFuBenAutoGatherEvent.func()
	end
	-- self:StopGuaji()
end

-- 挂机时的技能处理
function GuajiCtrl:DoFightByClick(skill_id, target_obj)
	self:PlayerOperation()
	self.skill_id = skill_id
	local is_team = RoleSkillData.Instance:CheckIsTeamSkill(self.skill_id)
	if  GuajiCache.guaji_type == GuajiType.None or is_team then
		FightCtrl.Instance:TryUseRoleSkill(skill_id, target_obj)
	end
	-- self:StopGuaji()
end

-- 找不到通往目标的路径时
function GuajiCtrl:OnCanNotFindWay()
	print_warning("OnCanNotFindWay")
	if GuajiCache.guaji_type ~= GuajiType.None then
		if GuajiCache.guaji_type == GuajiType.Auto then
			GuajiCache.target_obj = nil
			local guaji_type = GuajiCache.guaji_type
			self:StopGuaji()
			GlobalTimerQuest:AddDelayTimer(function() self:SetGuajiType(guaji_type) end, 0.1)
		elseif MoveCache.task_id then
			GlobalTimerQuest:AddDelayTimer(function() TaskCtrl.Instance:DoTask(MoveCache.task_id) end, 0.1)
		else
			self:StopGuaji()
		end
	end
end

function GuajiCtrl:PlayerOperation()
	self.last_operation_time = Status.NowTime
end

function GuajiCtrl:PlayerPosChange(x, y)
	if self.is_fly then
		if self.fly_cache then
			local scene_id = Scene.Instance:GetSceneId() or 0
			if self.fly_cache.x == x and self.fly_cache.y == y and self.fly_cache.scene_id == scene_id then
				self.is_fly = false
				self:DelayArrive()
			end
		end
	end
end

function GuajiCtrl:PlayerExitFight()
	if GuajiCache.guaji_type == GuajiType.HalfAuto then
		if MoveCache.move_type == MoveType.Pos or MoveCache.move_type == MoveType.Obj then
			self:OnArrive()
		end
	end
end

-- 通过npc_id移动到npc，如果是任务npc请同时传任务id，不知道任务id可以传场景id 提高效率
function GuajiCtrl:MoveToNpc(npc_cfg_id, task_id, scene_id, ignore_vip, scene_key, is_auto_move)
	if not npc_cfg_id then print_error("npc_cfg_id is nil") return end

	local scene_npc_cfg = nil
	if task_id then
		local config = TaskData.Instance:GetTaskConfig(task_id)
		if config then
			if config.accept_npc and config.accept_npc ~= "" then
				if npc_cfg_id == config.accept_npc.id then
					scene_npc_cfg = config.accept_npc
					scene_id = config.accept_npc.scene
				end
			end
			if not scene_npc_cfg and config.commit_npc and config.commit_npc ~= "" then
				if npc_cfg_id == config.commit_npc.id then
					scene_npc_cfg = config.commit_npc
					scene_id = config.commit_npc.scene
				end
			end
		end
	end

	if not scene_npc_cfg and scene_id then
		local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
		if scene_cfg ~= nil and scene_cfg.npcs ~= nil then
			for i, j in pairs(scene_cfg.npcs) do
				if j.id == npc_cfg_id then
					scene_npc_cfg = j
					break
				end
			end
		end
	end

	if not scene_npc_cfg then
		for k,v in pairs(Config_scenelist) do
			if v.sceneType == SceneType.Common then
				local scene_cfg = ConfigManager.Instance:GetSceneConfig(v.id)
				if scene_cfg ~= nil and scene_cfg.npcs ~= nil then
					for i, j in pairs(scene_cfg.npcs) do
						if j.id == npc_cfg_id then
							scene_npc_cfg = j
							scene_id = v.id
							break
						end
					end
				end
				if scene_npc_cfg ~= nil then
					break
				end
			end
		end
	end

	if scene_npc_cfg ~= nil then
		MoveCache.end_type = MoveEndType.NpcTask
		MoveCache.param1 = npc_cfg_id
		GuajiCache.target_obj_id = npc_cfg_id
		MoveCache.target_obj = Scene.Instance:GetNpcByNpcId(npc_cfg_id) or nil
		self:MoveToPos(scene_id, scene_npc_cfg.x, scene_npc_cfg.y, 1, 1, ignore_vip, scene_key, is_auto_move)
	end
end

-- 是否是特殊的普通场景
function GuajiCtrl:IsSpecialCommonScene(scene_id)
	scene_id = scene_id or Scene.Instance:GetSceneId()
	if scene_id then
		if BossData.IsWorldBossScene(scene_id) or
			BossData.IsDabaoBossScene(scene_id) or
			BossData.IsFamilyBossScene(scene_id) or
			BossData.IsMikuBossScene(scene_id) or
			BossData.IsActiveBossScene(scene_id) or
			RelicData.Instance:IsRelicScene(scene_id) or
			AncientRelicsData.IsAncientRelics(scene_id)
			or BossData.IsBabyBossScene(scene_id) then
			return true
		end
	end
	return false
end

function GuajiCtrl:CheakCanFly(not_error_mind)
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic:GetSceneType() ~= SceneType.Common then
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Map.TransmitLimitTip)
		return false
	end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	-- 等级不够
	if main_role_vo.level < FLY_TO_POS_LEVEL_LIMIT then
		return false
	end

	if main_role_vo.husong_color > 0 and main_role_vo.husong_taskid > 0 then -- 护送任务不能传送
		return false
	end
	if main_role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then -- 跳跃状态不能传送
		return false
	end
	if Scene.Instance:GetMainRole():IsFightStateByRole() then
		return false
	end
	if self:IsSpecialCommonScene() then
		if not not_error_mind then
			SysMsgCtrl.Instance:ErrorRemind(Language.Map.TransmitLimitTip)
		end
		return false
	end
	-- local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	-- if not VipData.Instance:GetIsCanFly(vip_level) then
	-- 	local fly_shoe_id = MapData.Instance:GetFlyShoeId() or 0
	-- 	local num = ItemData.Instance:GetItemNumInBagById(fly_shoe_id) or 0
	-- 	if num <= 0 then
	-- 		return false
	-- 	end
	-- end

	if self:CheckIsCampScene(Scene.Instance:GetSceneId()) then
		return false
	end

	if Scene.Instance:GetMainRole().hold_beauty_res_id > 0 then
		return false
	end

	return true
end

function GuajiCtrl:GetSelectObj()
	return self.last_click_obj
end

function GuajiCtrl:SettingChange(setting_type, switch)
	if setting_type == SETTING_TYPE.AUTO_RELEASE_SKILL then
		self.use_skill = switch
	elseif setting_type == SETTING_TYPE.AUTO_RELEASE_ANGER then
		self.use_anger_skill = switch
	-- elseif setting_type == SETTING_TYPE.AUTO_RELEASE_GODDESS_SKILL then
	-- 	self.use_goddess_skill = switch
	end
end

function GuajiCtrl:TaskWindow(switch)
	self.task_window = switch
	self.last_operation_time = self.last_operation_time + AUTO_TASK_TIME
end

function GuajiCtrl:GetWayLineDistance(path_pos_list)
	if not path_pos_list then
		return 0
	end
	local distance = 0
	local length = #path_pos_list
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	if length > 1 then
		for i = 2, length do
			local delta_pos = u3d.vec2(path_pos_list[i - 1].x - path_pos_list[i].x, path_pos_list[i - 1].y - path_pos_list[i].y)
			distance = distance + u3d.v2Length(delta_pos)
		end
		local delta_pos = u3d.vec2(path_pos_list[1].x - x, path_pos_list[1].y - y)
		distance = distance + u3d.v2Length(delta_pos)
	elseif length == 1 then
		local delta_pos = u3d.vec2(path_pos_list[1].x - x, path_pos_list[1].y - y)
		distance = distance + u3d.v2Length(delta_pos)
	end
	return distance
end

function GuajiCtrl:CheckMountUp(now_time)
	if self.last_mount_time <= now_time then
		if GuajiCache.guaji_type == GuajiType.HalfAuto or GuajiCache.guaji_type == GuajiType.Monster or MainUIView.Instance:GetXunLunState() then
			if self.auto_mount_up then
				local main_role = Scene.Instance:GetMainRole()
				if not main_role:IsFightState() and not main_role:GetIsGatherState() and
					main_role.vo.move_mode == MOVE_MODE.MOVE_MODE_NORMAL and
					main_role.vo.fight_mount_appeid and main_role.vo.fight_mount_appeid < 1 and MountData.Instance:IsActiviteMount() and
					not self.is_gather and
					main_role.vo.husong_taskid == 0 then
					MountCtrl.Instance:SendGoonMountReq(1)
					self.auto_mount_up = false
				end
			end
		end
		self.last_mount_time = now_time + 1.25
	end
end

function GuajiCtrl:OnStartGather()
	self.is_gather = true
end

function GuajiCtrl:OnStopGather()
	self.is_gather = false
end

function GuajiCtrl:ExitFuBen()
	local scene_cfg = Scene.Instance:GetCurFbSceneCfg()
	if scene_cfg.fight_cant_exit and 1 == scene_cfg.fight_cant_exit then
		local main_role = Scene.Instance:GetMainRole()
		if main_role:IsFightState() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.FightingCantExitFb)
			return
		end
	end
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.GongChengZhan or
		scene_type == SceneType.HunYanFb or
		scene_type == SceneType.TombExplore or
		scene_type == SceneType.ClashTerritory or
		scene_type == SceneType.QunXianLuanDou or
		scene_type == SceneType.Kf_XiuLuoTower or
		scene_type == SceneType.ZhongKui or
		scene_type == SceneType.TianJiangCaiBao or
		scene_type == SceneType.Question or
		scene_type == SceneType.QingYuanFB or
		scene_type == SceneType.LingyuFb then
		return
	end
	if scene_type == SceneType.CrossFB then
		local str =	Language.KuaFuFuBen.Exit
		return
	end
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.IsWorldBossScene(scene_id) then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		local scene_logic = Scene.Instance:GetSceneLogic()
		local x, y = scene_logic:GetTargetScenePos(scene_id)
		if x == nil or y == nil then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotToTarget)
			return
		end
		GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 0, 0)
		return
	end
	if BossData.IsDabaoBossScene(scene_id)
	or BossData.IsFamilyBossScene(scene_id)
	or BossData.IsMikuBossScene(scene_id)
	or BossData.IsActiveBossScene(scene_id) then
		BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE)
		return
	end

	if BossData.IsBabyBossScene(scene_id) then
		BossCtrl.SendBabyBossOpera(BABY_BOSS_OPERATE_TYPE.TYPE_LEAVE_REQ)
		return
	end

	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if fb_scene_info then
		local diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
		if diff_time >= 0 and fb_scene_info.is_pass == 0 then
			FuBenCtrl.Instance:SendExitFBReq()
			return
		end
	end
end

function GuajiCtrl:SetArriveCallBack(call_back)
	self.arrive_call_back = call_back
end

function GuajiCtrl:CheckIsCampScene(scene_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(CampNotFlySceneIdList) do
		if k ~= main_role_vo.camp and CampNotFlySceneIdList[k][scene_id] then
			return true
		end
	end
	return false
end