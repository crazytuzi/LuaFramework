Story = Story or BaseClass()

function Story:__init(step_list_cfg, story_view)
	self.step_list_cfg = step_list_cfg

	self.step = 0
	self.is_playing = true

	self.clock_end_time = 0
	self.story_view = story_view
	self.do_delay_list = {}
	self.effect_obj_map = {}
	self.code_if_then_list = {}
	self.block_t = {}

	-- 某个机器人强制一段时间干某件事(主要用于主角)
	self.force_t = {
		f_robert_id = 0,
		f_time_interval = 0,
		f_do_type = "",
		f_do_param_t = {},
		f_do_next_time = 0,
	}

	Runner.Instance:AddRunObj(self, 8)

	self.stop_gather_event = GlobalEventSystem:Bind(ObjectEventType.STOP_GATHER, BindTool.Bind(self.OnStopGather, self))
	self.attack_robert_event = GlobalEventSystem:Bind(OtherEventType.ROBERT_ATTACK_ROBERT, BindTool.Bind(self.OnRobertAttackRobert, self))
	self.robert_die_event = GlobalEventSystem:Bind(OtherEventType.ROBERT_DIE, BindTool.Bind(self.OnRobertDie, self))
	self.load_scene_complete_event = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind1(self.OnLoadSceneComplete, self))
end

function Story:__delete()
	if nil ~= CgManager.Instance then
		CgManager.Instance:Stop()
	end

	GlobalEventSystem:UnBind(self.stop_gather_event)
	GlobalEventSystem:UnBind(self.attack_robert_event)
	GlobalEventSystem:UnBind(self.robert_die_event)
	GlobalEventSystem:UnBind(self.load_scene_complete_event)

	for _, v in ipairs(self.do_delay_list) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.do_delay_list = {}

	for k,v in pairs(self.effect_obj_map) do
		v:Destroy()
		v:DeleteMe()
	end
	self.effect_obj_map = {}

	-- 很重要，如果剧情里的场景跟进入时的场景一样，是不会重复加载场景的，导致block残留
	for k, _ in pairs(self.block_t) do
		local i = math.floor(k / 100000)
		local j = k % 100000
		AStarFindWay:RevertBlockInfo(i, j)
	end
	self.block_t = {}
	self.is_playing = false

	Runner.Instance:RemoveRunObj(self)
end

function Story:Update(now_time, elapse_time)
	self:CheckMoveInArea()
	self:CheckRoleLevel()
	self:CheckTaskReceived()
	self:CheckClockEnd(now_time)
	self:CheckForceDo(now_time)
	self:CheckDelayDo(now_time)
end

-- 通过设置来触发
function Story:SetTrigger(trigger, trigger_param)
	print_log("Story:SetTrigger", trigger, trigger_param)

	if not self.is_playing then
		return
	end

	trigger_param = trigger_param or ""

	local check_count = 0
	while check_count < 100 do
		check_count = check_count + 1
		local step_cfg = self.step_list_cfg[self.step + 1]

		if nil == step_cfg or step_cfg.trigger ~= trigger or step_cfg.trigger_param ~= trigger_param then
			break
		end

		self.step = self.step + 1
		self:DoOperate(step_cfg.operate, Split(step_cfg.operate_param, "##"))
	end

	if nil ~= self.step_list_cfg[self.step] and nil ~= self.story_view then
		self.story_view:ShowStepDesc(self.step_list_cfg[self.step].desc, BindTool.Bind(self.DoOperate, self))
	end

	self:CheckCodeIfThen(trigger, trigger_param)
end

-- 加载场景完成
function Story:OnLoadSceneComplete(old_scene_type, new_scene_type)
	local step_cfg = self.step_list_cfg[self.step + 1]
	if nil == step_cfg or S_STEP_TRIGGER.ENTER_SCENE ~= step_cfg.trigger then
		return
	end

	if Scene.Instance:IsFirstEnterScene() and SceneType.Common ~= new_scene_type then
		return
	end

	local param_t = Split(step_cfg.trigger_param, "##")
	if #param_t > 0 and Scene.Instance:GetSceneId() ~= tonumber(param_t[1]) then
		return
	end

	for i, v in ipairs(param_t) do
		if param_t[i] == "role_level" and tonumber(param_t[i + 1]) ~= PlayerData.Instance:GetRoleVo().level then
			return
		end

		if param_t[i] == "task_id" and not TaskData.Instance:GetTaskIsAccepted(tonumber(param_t[i + 1])) then
			return
		end
	end

	self:SetTrigger(step_cfg.trigger, step_cfg.trigger_param)
end

-- 检查移动到某个区域触发
function Story:CheckMoveInArea()
	local step_cfg = self.step_list_cfg[self.step + 1]
	if nil == step_cfg or S_STEP_TRIGGER.MOVE_INTO_AREA ~= step_cfg.trigger then
		return
	end

	local role_x, role_y = Scene.Instance:GetMainRole():GetLogicPos()
	if nil == self.trigger_area then
		self.trigger_area = {}
		local param_t = Split(step_cfg.trigger_param, "##")
		self.trigger_area.x, self.trigger_area.y, self.trigger_area.w, self.trigger_area.h = tonumber(param_t[1]), tonumber(param_t[2]), tonumber(param_t[3]), tonumber(param_t[4])
	end

	if GameMath.IsInRect(role_x, role_y, self.trigger_area.x, self.trigger_area.y, self.trigger_area.w, self.trigger_area.h) then
		self.trigger_area = nil
		self:SetTrigger(step_cfg.trigger, step_cfg.trigger_param)
	end
end

-- 检查角色等级
function Story:CheckRoleLevel()
	local step_cfg = self.step_list_cfg[self.step + 1]
	if nil == step_cfg or S_STEP_TRIGGER.ROLE_LEVEL ~= step_cfg.trigger then
		return
	end

	if step_cfg.trigger_param == PlayerData.Instance:GetRoleVo().level then
		self:SetTrigger(step_cfg.trigger, step_cfg.trigger_param)
	end
end

-- 检查任务是否接受
function Story:CheckTaskReceived()
	local step_cfg = self.step_list_cfg[self.step + 1]
	if nil == step_cfg or S_STEP_TRIGGER.RECEIVED_TASK ~= step_cfg.trigger then
		return
	end

	if nil == self.trigger_task_id then
		local param_t = Split(step_cfg.trigger_param, "##")
		self.trigger_task_id = tonumber(param_t[1])
	end

	if TaskData.Instance:GetTaskIsAccepted(self.trigger_task_id) then
		self.trigger_task_id = nil
		self:SetTrigger(step_cfg.trigger, step_cfg.trigger_param)
	end
end

-- 检查时钟时否结束
function Story:CheckClockEnd(now_time)
	if self.clock_end_time > 0 and now_time >= self.clock_end_time then
		self.clock_end_time = 0
		self:SetTrigger(S_STEP_TRIGGER.CLOCK_END)
	end
end

-- 检测强制主角干某事
function Story:CheckForceDo(now_time)
	if now_time < self.force_t.f_do_next_time or "" == self.force_t.f_do_type then
		return
	end

	local force_robert =  RobertManager.Instance:GetRobertByRobertId(self.force_t.f_robert_id)
	if nil == force_robert then
		return
	end

	if S_FORCE_DO_TYPE.F_MOVE_TO == self.force_t.f_do_type then
		local p1x, p1y = force_robert:GetLogicPos()
		local p2x, p2y = tonumber(self.force_t.f_do_param_t[1]), tonumber(self.force_t.f_do_param_t[2])

		if force_robert:IsStand() and GameMath.GetDistance(p1x, p1y, p2x, p2y, false) > 1 then
			RobertManager.Instance:RobertMoveTo(self.force_t.f_robert_id, p2x, p2y)
			self.force_t.f_do_next_time = now_time + self.force_t.f_time_interval
		end
	end

	if S_FORCE_DO_TYPE.F_ATTACK_TARGET == self.force_t.f_do_type then
		for _, v in ipairs(self.force_t.f_do_param_t) do
			local target_robert = RobertManager.Instance:GetRobertByRobertId(tonumber(v))
			if RobertManager.Instance:IsEnemy(force_robert, target_robert)  then
				self.force_t.f_do_next_time = now_time + self.force_t.f_time_interval
				RobertManager.Instance:RobertAtkTarget(self.force_t.f_robert_id, tonumber(v))
				break
			end
		end
	end

	if S_FORCE_DO_TYPE.F_GATHER == self.force_t.f_do_type then
		if force_robert:IsStand() then
			self.force_t.f_do_next_time = now_time + self.force_t.f_time_interval
			RobertManager.Instance:RobertStartGather(self.force_t.f_robert_id, tonumber(self.force_t.f_do_param_t[1]))
		end
	end
end

function Story:CheckDelayDo(now_time)
	for i = #self.do_delay_list, 1, -1 do
		if now_time >= self.do_delay_list[i].do_time then
			local t = table.remove(self.do_delay_list, i)
			self:DoOperate(t.operate, t.param_t)
		end
	end
end

function Story:CheckCodeIfThen(trigger, trigger_param)
	if #self.code_if_then_list <= 0 then
		return
	end

	local del_list = {}
	for i, v in ipairs(self.code_if_then_list) do
		if v.condition == trigger or
			v.condition == trigger .. "##" .. trigger_param then
			for _, execute in ipairs(v.execute_list) do
				local t = Split(execute, "##")
				self:DoOperate(table.remove(t, 1), t)

				table.insert(del_list, i)
			end
		end
	end

	for i = #del_list, 1, -1 do
		table.remove(self.code_if_then_list, del_list[i])
	end
end

-- 采集结束(服务器返回)
function Story:OnStopGather(role_obj_id, reason)
	if role_obj_id ~= Scene.Instance:GetMainRole():GetObjId() or 1 ~= reason then
		return
	end

	local step_cfg = self.step_list_cfg[self.step + 1]
	if nil == step_cfg or S_STEP_TRIGGER.GATHER_END ~= step_cfg.trigger then
		return
	end

	self:SetTrigger(step_cfg.trigger, step_cfg.trigger_param)
end

-- 机器人打机器人触发
function Story:OnRobertAttackRobert(attacker_robert_id, target_robert_id)
	local step_cfg = self.step_list_cfg[self.step + 1]
	if nil == step_cfg or S_STEP_TRIGGER.BE_ATTACKED ~= step_cfg.trigger then
		return
	end

	local param_t = Split(step_cfg.trigger_param, "##")
	if target_robert_id == tonumber(param_t[1]) then
		self:SetTrigger(step_cfg.trigger, step_cfg.trigger_param)
	end
end

-- 机器人死亡触发
function Story:OnRobertDie(robert_id)
	self:SetTrigger(S_STEP_TRIGGER.ROBERT_DIE, robert_id)
end

function Story:DoOperate(operate, param_t)
	if S_STEP_OPERATE.CG_START == operate then
		self:OpPlayCg(param_t[1], param_t[2])

	elseif S_STEP_OPERATE.S_STEP_START == operate then
		self:OpStepStartToServer(tonumber(param_t[1]))

	elseif S_STEP_OPERATE.INTERACTIVE_START == operate then
		self:OpInteractiveStart(param_t[1], param_t[2])

	elseif S_STEP_OPERATE.SET_ROLE_POS == operate then
		self:OpSetRolePos(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.DIALOG_START == operate then
		self:OpDialog(tonumber(param_t[1]))

	elseif S_STEP_OPERATE.EXIT_FB == operate then
		self:OpExitFb()

	elseif S_STEP_OPERATE.GIRL_SAY == operate then
		self:OpGirlSay(param_t[1], tonumber(param_t[2]))

	elseif S_STEP_OPERATE.CREATE_ROBERT == operate then
		self:OpCreatRobert(param_t)

	elseif S_STEP_OPERATE.DEL_ROBERT == operate then
		self:OpDelRobert(param_t)

	elseif S_STEP_OPERATE.ROBERT_SAY == operate then
		self:OpRobertSay(tonumber(param_t[1]), param_t[2], tonumber(param_t[3]))

	elseif S_STEP_OPERATE.ROBERT_MOVE == operate then
		self:OpRobertMove(tonumber(param_t[1]), tonumber(param_t[2]), tonumber(param_t[3]))

	elseif S_STEP_OPERATE.ROBERT_ATK_TARGET == operate then
		self:OpRobertAtk(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.FIGHT_START == operate then
		self:OpFightStart(param_t)

	elseif S_STEP_OPERATE.CHANGE_APPEARANCE == operate then
		self:OpChangeAppearance(tonumber(param_t[1]), param_t[2], tonumber(param_t[3]))

	elseif S_STEP_OPERATE.CHANGE_TITLE == operate then
		self:OpChangeTitle(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.CHANGE_MOVE_SPEED == operate then
		self:OpChangeMoveSpeed(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.CHANGE_HUSONG_COLOR == operate then
		self:OpChangeHusongColor(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.CHANGE_MAXHP == operate then
		self:OpChangeMaxHp(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.CHANGE_GONGJI == operate then
		self:OpChangeGongji(tonumber(param_t[1]), tonumber(param_t[2]), tonumber(param_t[3]))

	elseif S_STEP_OPERATE.CHANGE_AOE_RANGE == operate then
		self:OpChangeAoeRange(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.CLOCK_START == operate then
		self:OpClockStart(tonumber(param_t[1]))

	elseif S_STEP_OPERATE.S_DROP == operate then
		self:OpServerDrop(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.S_FB_PASS_SUCC == operate then
		self:OpServerFbPassSucc()

	elseif S_STEP_OPERATE.FORCE_DO == operate then
		local f_do_param_t = {}
		for i = 4, #param_t do
			table.insert(f_do_param_t, param_t[i])
		end
		self:OpForceDo(tonumber(param_t[1]), tonumber(param_t[2]), param_t[3], f_do_param_t)

	elseif S_STEP_OPERATE.STOP_FORCE_DO == operate then
		self:OpForceDo(tonumber(param_t[1]), 0, "", {})

	elseif S_STEP_OPERATE.START_GATHER == operate then
		self:OpStartGather(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.CREATE_AIR_RECT_WALL == operate then
		self:OpCreateAirWall(tonumber(param_t[1]), tonumber(param_t[2]), tonumber(param_t[3]), tonumber(param_t[4]))

	elseif S_STEP_OPERATE.DEL_AIR_RECT_WALL == operate then
		self:OpDelAllWall(tonumber(param_t[1]), tonumber(param_t[2]), tonumber(param_t[3]), tonumber(param_t[4]))

	elseif S_STEP_OPERATE.SET_SCENE_ELEMENT_ACT == operate then
		self:OpSetSceneElementAct(param_t[1], tonumber(param_t[2]))

	elseif S_STEP_OPERATE.SHOW_COUNTDOWN_TIME == operate then
		self:OpShowCountDownTime(tonumber(param_t[1]))

	elseif S_STEP_OPERATE.SHOW_MESSAGE == operate then
		self:OpShowMessage(param_t[1], tonumber(param_t[2]))

	elseif S_STEP_OPERATE.CREATE_GATHER == operate then
		self:OpCreateGather(param_t[1], param_t[2], param_t[3], param_t[4])

	elseif S_STEP_OPERATE.CREATE_NPC == operate then
		self:OpCreateNpc(tonumber(param_t[1]), tonumber(param_t[2]), tonumber(param_t[3]), tonumber(param_t[4]))

	elseif S_STEP_OPERATE.DEL_NPC == operate then
		self:OpDelNpc(tonumber(param_t[1]))

	elseif S_STEP_OPERATE.PLAY_AUDIO == operate then
		self:OpPlayAudio(param_t[1], param_t[2])

	elseif S_STEP_OPERATE.PLAY_EFFECT == operate then
		self:OpPlayEffect(param_t[1], param_t[2], tonumber(param_t[3]), tonumber(param_t[4]), tonumber(param_t[5]), tonumber(param_t[6]))

	elseif S_STEP_OPERATE.PLAY_AROUND_EFFECT == operate then
		self:OpPlayAroundEffect(param_t[1], param_t[2], tonumber(param_t[3]), tonumber(param_t[4]), tonumber(param_t[5]), tonumber(param_t[6]))

	elseif S_STEP_OPERATE.CREATE_EFFECT_OBJ == operate then
		self:OpCreateEffectObj(tonumber(param_t[1]))

	elseif S_STEP_OPERATE.DEL_EFFECT_OBJ == operate then
		self:OpDelEffectObj(tonumber(param_t[1]))

	elseif S_STEP_OPERATE.AUTO_TASK == operate then
		self:OpAutoTask()

	elseif S_STEP_OPERATE.AUTO_GUAJI == operate then
		self:OpAutoGuaji()

	elseif S_STEP_OPERATE.MOVE_ARROW_TO == operate then
		self:OpMoveArrowTo(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.FUN_GUIDE == operate then
		self:OpFunGuide(param_t[1])

	elseif S_STEP_OPERATE.DEL_MOVE_ARROW == operate then
		self:OpDelMoveArrow()

	elseif S_STEP_OPERATE.DELAY_DO == operate then
		self:OpDelayDo(param_t)

	elseif S_STEP_OPERATE.CODE_IF_THEN == operate then
		self:OpCodeIfThen(param_t)

	elseif S_STEP_OPERATE.DEL_CODE == operate then
		self:OpDelCode()

	elseif S_STEP_OPERATE.ROBERT_ROTATE_TO == operate then
		self:OpRobertRotateTo(tonumber(param_t[1]), tonumber(param_t[2]))

	elseif S_STEP_OPERATE.TIME_SCALE == operate then
		self:OpTimeScale(tonumber(param_t[1]), tonumber(param_t[2]))
	end
end

-- 播放cg
function Story:OpPlayCg(bundle_name, asset_name)
	local end_callback = function()
		self:SetTrigger(S_STEP_TRIGGER.CG_END)
	end
	local start_callback = function()
		self:SetTrigger(S_STEP_TRIGGER.CG_START)
	end
	if IsLowMemSystem then
		GlobalTimerQuest:AddDelayTimer(function ()
			start_callback()
			end_callback()
		end, 0)
	else
		CgManager.Instance:Play(BaseCg.New(bundle_name, asset_name), end_callback, start_callback)
	end
end

-- 请求服务开始阶段，待服务器返回阶段结束
function Story:OpStepStartToServer(step)
	local cmd = ProtocolPool.Instance:GetProtocol(CSFunOpenStoryStep)
	cmd.step = step
	cmd:EncodeAndSend()

	local msg_type = ProtocolPool.Instance:Register(SCFunOpenStoryStepEnd)
	if msg_type > 0 then
		GameNet.Instance:RegisterMsgOperate(msg_type, function ()
			ProtocolPool.Instance:UnRegister(SCFunOpenStoryStepEnd, msg_type)
			GameNet.Instance:UnRegisterMsgOperate(msg_type)

			self:SetTrigger(S_STEP_TRIGGER.S_STEP_END)
		end)
	end
end

-- 请求人机交互
function Story:OpInteractiveStart(interacive_type, interacive_param1)
	function interactive_end(param)
		self:SetTrigger(S_STEP_TRIGGER.INTERACTIVE_END, param)
	end

	if S_INTERACTIVE_TYPE.FETCH_HUSONG_REWARD == interacive_type then
		self.story_view:ShowHusongRewardView(interactive_end)
	end

	if S_INTERACTIVE_TYPE.WING_OPEN_DOOR == interacive_type then
		self.story_view:ShowOpenDoor(interactive_end)
	end

	if S_INTERACTIVE_TYPE.DISTRIBUTE_RED_PACKET == interacive_type then
		self.story_view:ShowRedPacket(interactive_end)
	end

	if S_INTERACTIVE_TYPE.SHOW_VICTORY == interacive_type then
		self.story_view:ShowVictoryView(interactive_end, tonumber(interacive_param1))
	end

	if S_INTERACTIVE_TYPE.SHOW_HELP == interacive_type then
		self.story_view:ShowHelp(interactive_end, tonumber(interacive_param1))
	end

	if S_INTERACTIVE_TYPE.SHOW_ATTACK == interacive_type then
		self.story_view:ShowAttack(interactive_end, tonumber(interacive_param1))
	end

	if S_INTERACTIVE_TYPE.SHOW_ATTACK_BACK == interacive_type then
		self.story_view:ShowAttackBack(interactive_end, tonumber(interacive_param1))
	end
end

-- 设置角色位置
function Story:OpSetRolePos(pos_x, pos_y)
	-- 因为低内存手机会跳过CG，部分CG会重置主角位置，体验会很奇怪
	if IsLowMemSystem then
		return
	end
	if SceneType.Common == Scene.Instance:GetSceneType() then
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		Scene.SendSyncJump(Scene.Instance:GetSceneId(), pos_x, pos_y, scene_key)

	else
		local protocol = ProtocolPool.Instance:GetProtocol(CSFunOpenSetObjToPos)
		protocol.obj_id = Scene.Instance:GetMainRole():GetObjId()
		protocol.pos_x = pos_x
		protocol.pos_y = pos_y
		protocol:EncodeAndSend()
	end

	Scene.Instance:GetMainRole():SetLogicPos(pos_x, pos_y)
	if not IsNil(MainCameraFollow) then
		MainCameraFollow:SyncImmediate()
	end
end

-- 对话
function Story:OpDialog(npc_id)
	local dialog_view = ViewManager.Instance:GetView(ViewName.TaskDialog)
	if nil ~= dialog_view then
		dialog_view:Open()
		dialog_view:SetStoryNpcId(npc_id, function ()
			self:SetTrigger(S_STEP_TRIGGER.DIALOG_END)
		end)
	end
end

-- 退出副本
function Story:OpExitFb()
	FuBenCtrl.Instance:SendExitFBReq()
end

-- 美女说话
function Story:OpGirlSay(content, time)
	self.story_view:OnGirlSay(content, time or 5)
end

-- 创建机器人
function Story:OpCreatRobert(robert_id_list)
	for _, v in ipairs(robert_id_list) do
		RobertManager.Instance:CreateRobert(tonumber(v))
	end
end

-- 移除机器人
function Story:OpDelRobert(robert_id_list)
	for _, v in ipairs(robert_id_list) do
		RobertManager.Instance:DelRobertByRobertId(tonumber(v))
	end
end

-- 机器人说话
function Story:OpRobertSay(robert_id, content, time)
	RobertManager.Instance:RobertSay(robert_id, content, time or 3)
end

-- 机器人移动
function Story:OpRobertMove(robert_id, pos_x, pos_y)
	RobertManager.Instance:RobertMoveTo(robert_id, pos_x, pos_y)
end

-- 机器人对另外一个机器人发起攻击
function Story:OpRobertAtk(robert_id, target_robert_id)
	RobertManager.Instance:RobertAtkTarget(robert_id, target_robert_id)
end

-- 战斗开始
function Story:OpFightStart(end_condition)
	local die_robert_list = {}
	for _, v in pairs(end_condition) do
		table.insert(die_robert_list, tonumber(v))
	end

	RobertManager.Instance:StartFight(die_robert_list, function (fight_id_inc)
		self:SetTrigger(S_STEP_TRIGGER.FIGHT_END, fight_id_inc)
	end)
end

-- 改变机器人外观
function Story:OpChangeAppearance(robert_id, appearance_type, appearance_value)
	RobertManager.Instance:RobertChangeAppearance(robert_id, appearance_type, appearance_value)
end

-- 改变机器人称号
function Story:OpChangeTitle(robert_id, title_id)
	RobertManager.Instance:RobertChangeTitle(robert_id, title_id)
end

-- 机器人改变速度
function Story:OpChangeMoveSpeed(robert_id, move_speed)
	RobertManager.Instance:RobertChangeAttrValue(robert_id, "move_speed", move_speed)
end

-- 机器人更改护送颜色
function Story:OpChangeHusongColor(robert_id, husong_color)
	RobertManager.Instance:RobertChangeAttrValue(robert_id, "husong_taskid", 1)
	RobertManager.Instance:RobertChangeAttrValue(robert_id, "husong_color", husong_color)
end

-- 机器人更改最大血量
function Story:OpChangeMaxHp(robert_id, max_hp)
	RobertManager.Instance:RobertChangeAttrValue(robert_id, "max_hp", max_hp)
	RobertManager.Instance:RobertChangeAttrValue(robert_id, "hp", max_hp)
end

-- 机器人更改攻击力
function Story:OpChangeGongji(robert_id, min_gongji, max_gongji)
	RobertManager.Instance:RobertChangeGongJi(robert_id, min_gongji, max_gongji)
end

-- 机器人更改Aoe范围
function Story:OpChangeAoeRange(robert_id, aoe_range)
	RobertManager.Instance:RobertChangeAoeRange(robert_id, aoe_range)
end

-- 开启时钟
function Story:OpClockStart(time)
	self.clock_end_time = Status.NowTime + time
end

-- 服务器掉落(掉落物品由服务器决定，服务器在掉落后会认为完成了该剧情)
function Story:OpServerDrop(pos_x, pos_y)
	local cmd = ProtocolPool.Instance:GetProtocol(CSFbGuideFinish)
	cmd.pos_x = pos_x
	cmd.pos_y = pos_y
	cmd:EncodeAndSend()
end

-- 通知服务器副本通关成功
function Story:OpServerFbPassSucc()
	local cmd = ProtocolPool.Instance:GetProtocol(CSFbGuideFinish)
	cmd.pos_x = 0
	cmd.pos_y = 0
	cmd:EncodeAndSend()
end

-- 强制机器人定期做某件事
function Story:OpForceDo(f_robert_id, f_time_interval, f_do_type, f_do_param_t)
	-- print("============OpForceDo,", f_robert_id, f_time_interval, f_do_type, f_do_param_t[1], f_do_param_t[2])
	self.force_t.f_robert_id = f_robert_id
	self.force_t.f_time_interval = f_time_interval
	self.force_t.f_do_type = f_do_type
	self.force_t.f_do_param_t = f_do_param_t
	self.force_t.f_do_next_time = Status.NowTime
end

-- 机器人操作采集
function Story:OpStartGather(robert_id, gather_id)
	RobertManager.Instance:RobertStartGather(robert_id, gather_id)
end

-- 生成空气墙
function Story:OpCreateAirWall(x, y, w, h)
	for i = x, x + w - 1 do
		for j = y, y + h - 1 do
			self.block_t[i * 100000 + j] = true
			AStarFindWay:SetBlockInfo(i, j)
		end
	end
end

-- 移除空气墙
function Story:OpDelAllWall(x, y, w, h)
	for i = x, x + w - 1 do
		for j = y, y + h - 1 do
			self.block_t[i * 100000 + j] = nil
			AStarFindWay:RevertBlockInfo(i, j)
		end
	end
end

-- 设置场景元素是否激活
function Story:OpSetSceneElementAct(element_path, is_act)
	local t = Split(element_path, "/")
	if #t <= 1 then
		return
	end

	local obj_name = t[#t]
	local parent_path = string.gsub(element_path, "/" .. obj_name, "")
	local parent = GameObject.Find(parent_path)
	if nil ~= parent then
		local obj = parent.transform:Find(obj_name)
		if nil ~= obj then
			obj.gameObject:SetActive(1 == is_act)
		end
	end
end

-- 显示倒计时
function Story:OpShowCountDownTime(time)
	local fuben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
	if nil ~= fuben_icon_view and fuben_icon_view:IsOpen() then
		fuben_icon_view:SetCountDownByTotalTime(time)
	end
end

-- 显示传闻
function Story:OpShowMessage(content, time)
	self.story_view:ShowMessage(content, time)
end

-- 创建采集物
function Story:OpCreateGather(gather_id, gather_time, pos_x, pos_y)
	local cmd = ProtocolPool.Instance:GetProtocol(CSFbGuideCreateGather)
	cmd.gather_id = gather_id
	cmd.gather_time = gather_time
	cmd.pos_x = pos_x
	cmd.pos_y = pos_y

	cmd:EncodeAndSend()
end

-- 创建NPC
function Story:OpCreateNpc(npc_id, x, y, rotation_y)
	local vo = NpcVo.New()
	vo.npc_id = npc_id
	vo.pos_x = x
	vo.pos_y = y
	vo.rotation_y = rotation_y
	Scene.Instance:CreateNpc(vo)
end

-- 移除NPC
function Story:OpDelNpc(npc_id)
	Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.Npc, npc_id)
end

-- 播放音效
function Story:OpPlayAudio(bundle_name, asset_name)
	AudioManager.PlayAndForget(AssetID(bundle_name, asset_name))
end

-- 播放特效。在机器人偏移位置处播
function Story:OpPlayEffect(bundle_name, asset_name, robert_id, offest_x, offest_y, offest_z)
	local robert = RobertManager.Instance:GetRobertByRobertId(robert_id)
	if nil == robert then
		return
	end

	local position = Vector3(offest_x, offest_y, offest_z) + robert:GetObj():GetRoot().transform.position
	EffectManager.Instance:PlayControlEffect(bundle_name, asset_name, position)
end

-- 播放区域特效,在机器人中心的所在区域
function Story:OpPlayAroundEffect(bundle_name, asset_name, robert_id, width, height, count)
	local robert = RobertManager.Instance:GetRobertByRobertId(robert_id)
	if nil == robert then
		return
	end

	local pos = robert:GetObj():GetRoot().transform.position
	local min_x, max_x = pos.x - width / 2,  pos.x + width / 2
	local min_y, max_y = pos.y, pos.y
	local min_z, max_z = pos.z - height / 2, pos.z + height / 2

	for i=1, count do
		local position = Vector3(GameMath.Rand(min_x, max_x), GameMath.Rand(min_y, max_y), GameMath.Rand(min_z, max_z))
		local delay_time = 0.3 * math.ceil(i / 4)
		GlobalTimerQuest:AddDelayTimer(function()
			EffectManager.Instance:PlayControlEffect(bundle_name, asset_name, position)
			end, delay_time)
	end
end

-- 创建特效对象
function Story:OpCreateEffectObj(effect_id)
	if nil ~= self.effect_obj_map[effect_id] then
		return
	end

	local effect_cfg = ConfigManager.Instance:GetAutoConfig("story_auto")["effect"][effect_id]
	if nil == effect_cfg then
		return
	end

	local effect_obj = AsyncLoader.New()
	effect_obj:SetLocalPosition(Vector3(effect_cfg.pos_x, effect_cfg.pos_y, effect_cfg.pos_z))
	effect_obj:SetLocalScale(Vector3(effect_cfg.scale_x, effect_cfg.scale_y, effect_cfg.scale_z))
	effect_obj:SetLocalRotation(Quaternion.Euler(effect_cfg.rotate_x, effect_cfg.rotate_y, effect_cfg.rotate_z))
	effect_obj:Load(effect_cfg.bundle_name, effect_cfg.asset_name)
	self.effect_obj_map[effect_id] = effect_obj
end

function Story:OpDelEffectObj(effect_id)
	local effect_obj = self.effect_obj_map[effect_id]
	if nil ~= effect_obj then
		effect_obj:Destroy()
		effect_obj:DeleteMe()
		self.effect_obj_map[effect_id] = nil
	end
end

-- 自动任务
function Story:OpAutoTask()
	GuajiCtrl.Instance:TryAutoExecutTask()
end

-- 自动挂机
function Story:OpAutoGuaji()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

-- 移动箭头指向点
function Story:OpMoveArrowTo(x, y)
	local wx, wy = GameMapHelper.LogicToWorld(x, y)
	Scene.Instance:ActGuideArrowTo(wx, wy)
end

-- 功能引导
function Story:OpFunGuide(guide_name)
	FunctionGuide.Instance:TriggerGuideByGuideName(guide_name)
end

-- 移除移动箭头
function Story:OpDelMoveArrow()
	Scene.Instance:DelGuideArrow()
end

-- 延迟做某件事
function Story:OpDelayDo(param_t)
	local time = tonumber(table.remove(param_t, 1))
	local operate = table.remove(param_t, 1)

	local t = {}
	t.do_time = time + Status.NowTime
	t.operate = operate
	t.param_t = param_t

	table.insert(self.do_delay_list, t)
end

-- 执行条件语句
function Story:OpCodeIfThen(param_t)
	local code_str = ""
	for i,v in ipairs(param_t) do
		if "" == code_str then
			code_str = v
		else
			code_str = code_str .. "##" .. v
		end
	end

	local code_ary = Split(code_str, " then ")

	local code = {}
	code.condition = string.gsub(code_ary[1], "if ", "")
	code.execute_list = Split(code_ary[2], ";")
	table.insert(self.code_if_then_list, code)
end

-- 删除编码
function Story:OpDelCode()
	self.code_if_then_list = {}
end

function Story:OpRobertRotateTo(robert_id, angle)
	RobertManager.Instance:RobertRotateTo(robert_id, angle)
end

function Story:OpTimeScale(duration, time_scale)
	TimeScaleService.Instance:SetTimeScale(time_scale, duration, nil, DG.Tweening.Ease.InCirc)
end