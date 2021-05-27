------------------------------------------------------
--剧情
------------------------------------------------------
Story = Story or BaseClass()
function Story:__init()
	if Story.Instance ~= nil then
		ErrorLog("[Story] attempt to create singleton twice!")
		return
	end
	Story.Instance = self

	self.is_open_story = true							--是否开启剧情
	self.is_forbid_skip_in_opening = false 				--是否在开场动画中屏蔽跳过按钮(注，此值只在手机上有效)

	self.imitate_atk_key = 0
	self.story_list = ConfigManager.Instance:GetAutoConfig("story_auto").story_list
	self.actor_cache_list = {}
	self.new_born_list = {}
	self.fadein_list = {}	
	self.fadeout_list = {}
	self.cur_story = nil
	self.is_storing = false
	self.cur_show = nil
	self.show_end_callback = nil
	self.audio_path_list = {}
	self.story_played_list = {} 	--已播放的剧情列表

	self.is_on_mount_start = false	--在剧情时要下坐骑，结束后根据情况h
	self.mainrole_speed_start = 0   --在必须剧情前主角的移动速度

	self.end_curtain = nil
	self.delay_remove_end_curtain = nil

	self.dialog_view = StoryDialog.New()
	self.story_modal = StoryModal.New()
	self.story_modal:SetSkipCallback(BindTool.Bind(self.EndStory, self))
	self.move_camera_cache = {
		moving = false,
		pos = cc.p(0, 0),
		end_x = 0,
		end_y = 0,
		speed = 700,
		pass_distance = 0,
		total_distance = 0,
		distance = 0,
		move_dir = 0,
	}

	self.move_mount_cache = {
		moving = false,
		pos = cc.p(0, 0),
		end_x = 0,
		end_y = 0,
		speed = 700,
		pass_distance = 0,
		total_distance = 0,
		distance = 0,
		move_dir = 0,
	}

	self.shake_cache = {
		shaking = false,
		shake_center = {x = 0, y = 0},
		shake_frequency = 0.03,
		prve_shake_time = 0,
		shake_strength = 1,
		cur_shake_strength = 0,
		cur_shake_dir = -1,

		shake_strength1 = {{x=-6, y=-6}, {x=6, y=6}, {x=-6, y=-6}, {x=5, y=5}, {x=-4, y=-4}, {x=3, y=3}, {x=-2, y=-2}, {x=1, y=1}, {x=0, y=0}},
		shake_strength2 = {{x=-25, y=-25}, {x=23, y=23}, {x=-22, y=-22}, {x=20, y=20}, {x=-22, y=-22}, {x=20, y=20}, {x=-20, y=-18}, {x=18, y=18}, {x=-16, y=-16}, {x=14, y=14},{x=-12, y=-12}, {x=10, y=10}, {x=-12, y=-12}, {x=10, y=10}, {x=-10, y=-10}, {x=9, y=9},  {x=-10, y=-10}, {x=9, y=9}, {x=-8, y=-8}, {x=8, y=8}, {x=-6, y=-6}, {x=4, y=4}, {x=-2, y=-2}},
		shake_strength3 = {{x=-25, y=-25}, {x=23, y=23}, {x=-22, y=-22}, {x=20, y=20}, {x=-20, y=-18}, {x=18, y=18}, {x=-16, y=-16}, {x=14, y=14}, {x=-12, y=-12}, {x=10, y=10}, {x=-10, y=-10}, {x=9, y=9}, {x=-8, y=-8}, {x=8, y=8}, {x=-6, y=-6}, {x=4, y=4}, {x=-2, y=-2}},
		shake_strength4 = {{x=2, y=0}, {x=2, y=3}, {x=-3, y=0}, {x=-1, y=0}, {x=-1, y=3}, {x=1, y=-2}, {x=-2, y=-1}, {x=-1, y=0}, {x=-2, y=0}, {x=-2, y=1}, {x=-1, y=-2}, {x=0, y=-2}, {x=3, y=2}, {x=3, y=-2}, {x=1, y=3}, {x=-2, y=-2}, {x=-3, y=1}, {x=-1, y=-3}, {x=-2, y=-2}, {x=-2, y=1}, {x=3, y=3}, {x=1, y=-3}, {x=-1, y=-3}, {x=-3, y=-1}, {x=2, y=2}, {x=3, y=2}, {x=-2, y=1}, {x=-3, y=-2}, {x=3, y=-3}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=-1, y=1}, {x=-3, y=0}, {x=-3, y=2}, {x=-2, y=-1}, {x=1, y=2}, {x=-1, y=0}, {x=-3, y=-2}, {x=3, y=-3}, {x=3, y=0}, {x=-2, y=1}, {x=1, y=-3}, {x=-1, y=-2}, {x=0, y=-2}, {x=-2, y=1}, {x=3, y=-1}, {x=3, y=0}, {x=2, y=-1}, {x=-2, y=-3}, {x=-3, y=-2}, {x=-1, y=-1}, {x=-1, y=-3}, {x=2, y=3}, {x=-1, y=-1}, {x=2, y=2}, {x=-3, y=1}, {x=3, y=-1}, {x=3, y=-1}, {x=1, y=3}, {x=3, y=2}, {x=3, y=2}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=-1, y=-2}, {x=1, y=2}, {x=0, y=-1}, {x=0, y=3}, {x=0, y=2}, {x=-2, y=1}, {x=-2, y=-2}, {x=1, y=3}, {x=1, y=1}, {x=1, y=1}, {x=-3, y=-3}, {x=-3, y=0}, {x=0, y=-1}, {x=2, y=2}, {x=0, y=3}, {x=-1, y=3}, {x=3, y=-3}, {x=1, y=-1}, {x=-2, y=0}, {x=2, y=1}, {x=3, y=-2}, {x=-2, y=1}, {x=-2, y=1}, {x=3, y=3}, {x=2, y=-2}, {x=3, y=-1}, {x=0, y=3}, {x=3, y=0}, {x=2, y=3}, {x=-3, y=1}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=0, y=0}, {x=1, y=2}, {x=2, y=0}, {x=0, y=-1}, {x=0, y=1}, {x=1, y=3}, {x=-2, y=1}, {x=2, y=-1}, {x=-3, y=-3}, {x=-2, y=2}, {x=2, y=0}, {x=0, y=2}, {x=-2, y=-1}, {x=1, y=-1}, {x=2, y=2}, {x=0, y=3}, {x=0, y=0}},
	}

	-- RoleData.Instance:NotifyAttrChange(BindTool.Bind(self.OnRoleAttrChange, self))
	-- TaskData.Instance:ListenerTaskChange(BindTool.Bind(self.OnOneTaskDataChange, self))
	-- GlobalEventSystem:Bind(LoginEventType.START_OPENING_ANIMATION, BindTool.Bind(self.StartOpeningAnimation, self))
	-- GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneLoadingQuite, self))
	-- GlobalEventSystem:Bind(OtherEventType.STORY_END, BindTool.Bind(self.OnStoryEnd, self))
	Runner.Instance:AddRunObj(self, 8)
end

function Story:__delete()
	Story.Instance = nil
	self.story_list = nil

	self.dialog_view:DeleteMe()
	self.dialog_view = nil
	
	self.story_modal:DeleteMe()
	self.story_modal = nil
	self.story_end_pos = nil
end

function Story:GetSoryByTaskTrigger(trigger_type,trigger_param)
	for k,v in pairs(self.story_list) do
		if v.trigger_type == trigger_type then
			if v.trigger_param == trigger_param then
				return v
			end
		end
	end
	return nil
end

--是否正在大剧情中
function Story:GetIsStoring()
	return nil ~= self.cur_story and self.cur_story.story_type == StoryType.Large
end

function Story:GetShow(show_id)
	if self.cur_story == nil then
		return nil
	end
	return self.cur_story.show_list[show_id]
end

function Story:GetActorCfgList(show_cfg)
	local actor_list = Split(show_cfg.actor, "||")		--多个演员
	for k,v in pairs(actor_list) do
		actor_list[k] = Split(v, "##")
	end
	return actor_list
end

function Story:GetActCfgList(show_cfg)
	local action_list = Split(show_cfg.action, "||")	--多个演员对应的动作
	for k,v in pairs(action_list) do
		action_list[k] = Split(v, "&&")						--单个演员对应的多个动作
		for i,j in pairs(action_list[k]) do
			local action_str = self:FilterContent(j)
			action_list[k][i] = Split(action_str, "##")
		end
	end
	return action_list
end

--根据标签过滤内容。如可能分职业
function Story:FilterContent(content)
	if content == nil or content == "" then return content end

	local i, j = string.find(content, "<prof") --检查职业相关
	if i ~= nil and j ~= nil then
		local prof_tag = string.format("prof%d", GameVoManager.Instance:GetMainRoleVo().prof)
		content = XmlUtil.GetTagContent(content, prof_tag) or ""
	end
	return content
end

function Story:CacheActorValue(actor_id, param_name, value)
	actor_id = tonumber(actor_id)
	if self.actor_cache_list[actor_id] == nil then
		self.actor_cache_list[actor_id] = {}
	end
	self.actor_cache_list[actor_id][param_name] = value
end

function Story:GetActorCacheValue(actor_id, param_name)
	actor_id = tonumber(actor_id)
	if actor_id == ActorId.MainRole and param_name == "actor_obj" then
		return Scene.Instance:GetMainRole()
	end

	if self.actor_cache_list[actor_id] ~= nil then
		return self.actor_cache_list[actor_id][param_name]
	end
	return nil
end

function Story:ClearActorCache()
	self.actor_cache_list = {}
end

function Story:ClearMoveCameraCache()
	self.move_camera_cache.moving = false
	self.move_camera_cache.pos = nil
	self.move_camera_cache.pass_distance = 0
	self.move_camera_cache.total_distance = 0
	self.move_camera_cache.move_dir = 0
	self.move_camera_cache.end_x = 0
	self.move_camera_cache.end_y = 0
end

function Story:ClearMoveMountCache()
	self.move_mount_cache.moving = false
	self.move_mount_cache.pos = nil
	self.move_mount_cache.pass_distance = 0
	self.move_mount_cache.total_distance = 0
	self.move_mount_cache.move_dir = 0
	self.move_mount_cache.end_x = 0
	self.move_mount_cache.end_y = 0
end

function Story:ClearShakeCache()
	self.shake_cache.shaking = false
	self.shake_cache.cur_shake_step = 1
	self.prve_shake_time = 0
	HandleRenderUnit:GetCoreScene():setPosition(0, 0)
end

--开始开场剧情动画
function Story:StartOpeningAnimation()
	for k,v in pairs(self.story_list) do
		if v.trigger_type == FuncGuideTriggerType.Born then
			self:StartStory(v)
			return
		end
	end
end

--单个任务数据改变时
function Story:OnOneTaskDataChange(reason, task_id)
	if not self.is_open_story then
		return
	end

	local trigger_type = 0
	if reason == "add" then
		trigger_type = FuncGuideTriggerType.AddTask
	elseif reason == "complete" then
		trigger_type = FuncGuideTriggerType.CompleteTask
	elseif reason == "finish" then
		trigger_type = FuncGuideTriggerType.FinishTask
	end

	local story_cfg = self:GetSoryByTaskTrigger(trigger_type, task_id)

	if story_cfg then
		self:StartStory(story_cfg)
	end
end

--人物属性变化
function Story:OnRoleAttrChange(key, value, old_value)
	if not self.is_open_story then
		return
	end

	if key == OBJ_ATTR.CREATURE_LEVEL then
		for k,v in pairs(self.story_list) do
			if v.trigger_type == FuncGuideTriggerType.UpLevel and v.trigger_param == value then
				self:StartStory(v)
				return
			end
		end
	end
end

function Story:OnStoryEnd(story_id)
	if not self.is_open_story then
		return
	end

	for k,v in pairs(self.story_list) do
		if v.trigger_type == FuncGuideTriggerType.StoryEnd and v.trigger_param == story_id then
			self:StartStory(v)
			return
		end
	end
end

--场景变化
function Story:OnSceneLoadingQuite()
	if not self.is_open_story then
		return
	end

	local scene_id = Scene.Instance:GetSceneId()
	for k,v in pairs(self.story_list) do
		if v.trigger_type == FuncGuideTriggerType.EnterScene then
			if v.trigger_param == scene_id then
				self:StartStory(v)
				return
			end
		end
	end
end

--开始剧情
function Story:StartStory(story_cfg)
	if not self.is_open_story then return end
	if story_cfg == nil then return end
	if self.story_played_list[story_cfg.id] then return end
	self.story_played_list[story_cfg.id] = true

	self:EndStory()

	self.cur_story = story_cfg
	self.is_storing = true
	self:StartShow(self:GetShow(1))

	if self:GetIsStoring() then
		-- 大剧情需要屏蔽主所有界面，停止主角所有动作
		GuideCtrl.Instance:CloseForeshowBaseView()
		self:RemoveEndCurtain()
		Scene.Instance:GetMainRole():StopMove()
		Scene.Instance:GetMainRole():ClearAction()
		self:SetOtherOpenViewVisible(false)
		self:SetOtherSceneObjsVisible(false)
		self.obj_create_bind = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))
		self.story_modal:Open()
	end
end

--结束剧情
function Story:EndStory()
	if not self.is_storing then
		return
	end

	self:ClearActorCache()
	self:ClearMoveCameraCache()
	self:ClearMoveMountCache()
	self:ClearShakeCache()
	self:ClearDelayNextShow()
	self:StopShowAudio()
	self.story_modal:Close()
	self.dialog_view:Close()
	self:RemoveAllActor()
	self.fadeout_list = {}
	self.fadein_list = {}

	if self:GetIsStoring() then
		-- 还原大剧情需要屏蔽的内容
		self:SetOtherSceneObjsVisible(true)
		Scene.Instance:CheckClientObj()

		local main_role = Scene.Instance:GetMainRole()
		local center_pos = main_role.view_cneter_pos
		HandleGameMapHandler:setViewCenterPoint(center_pos.x, center_pos.y + COMMON_CONSTS.SCENE_CAMERA_OFFSET_Y)

		main_role:ClearAction()
		main_role:StopMove()
		main_role:GetModel():SetAllVisible(true)
		main_role:UpdateModelColor()

		-- 切换回真实场景
		if nil ~= self.real_scene_info then
			HandleGameMapHandler:ChangeScene(self.real_scene_info.id)
			HandleRenderUnit:UpdateWorldSize()
			HandleGameMapHandler:OnLoadingSceneQuit()
			self.real_scene_info = nil
		end

		-- 自动做任务
		local auto_do_task = true

		-- 特殊场景请求服务端开始刷怪(写死)
		-- local scene_id = Scene.Instance:GetSceneId()
		-- if 68 == scene_id or 6 == scene_id then
		-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSServerStartPlay)
		-- 	protocol:EncodeAndSend()

		-- 	-- 跑到场景中央 自动战斗
		-- 	if 6 == scene_id then
		-- 		auto_do_task = false
		-- 		GlobalTimerQuest:AddDelayTimer(
		-- 			function()
		-- 				MoveCache.end_type = MoveEndType.OtherOpt
		-- 				local function MoveEndOpt()
		-- 					GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		-- 				end
		-- 				MoveCache.param1 = MoveEndOpt
		-- 				GuajiCtrl.Instance:MoveToPos(6, 41, 46, 1)
		-- 			end,
		-- 			2		-- 延迟几秒再自动战斗
		-- 		)
		-- 	end
		-- end

		if auto_do_task then
			local task_info = TaskData.Instance:GetMainTaskInfo()
			if nil ~= task_info and not Scene.Instance:CanPickFallItem() then
				-- MainuiTaskItemReander.OnClickTask(task_info)
			end
		end

		self:PlayEndCurtain()
	end

	local end_story_id = self.cur_story.id
	self.is_storing = false
	self.cur_story = nil
	self.cur_show = nil
	self:SetOtherOpenViewVisible(true)
	
	if nil ~= self.obj_create_bind then		
		GlobalEventSystem:UnBind(self.obj_create_bind)
		self.obj_create_bind = nil
	end

	GlobalEventSystem:Fire(OtherEventType.STORY_END, end_story_id)
end

function Story:StartShow(show_cfg)
	if show_cfg == nil then
		self:EndStory()
		return
	end
	self.cur_show = show_cfg
	self:DoShow(self.cur_show)
end

function Story:DoShow(show_cfg)
	if show_cfg == nil then
		return
	end

	self:ClearDelayNextShow()
	self.show_end_callback = nil
	--self:StopShowAudio()

	local actor_cfg_list = self:GetActorCfgList(show_cfg)
	local act_cfg_list = self:GetActCfgList(show_cfg)

	local next_time = self:FilterContent(tostring(show_cfg.next_time)) or ""
	if next_time == "" then
		self.show_end_callback = BindTool.Bind1(self.OnOneShowEnd, self)
	elseif tonumber(next_time) > 0 then
		self.delay_next_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.OnOneShowEnd, self), tonumber(next_time))
	end

	for k,v in pairs(actor_cfg_list) do
		local act_cfgs = act_cfg_list[k]
		if act_cfgs ~= nil then
			self:DoAct(v, act_cfgs)
		end
	end

	self:PlayShowAudio(show_cfg)
	if tonumber(next_time) == 0 then
		self:OnOneShowEnd()
	end
end

function Story:OnOneShowEnd()
	if self.dialog_view:IsOpen() then
		self.dialog_view:Close()
	end
	self:NextShow()
end

function Story:NextShow()
	if self.cur_show == nil then return end

	local show_id = self.cur_show.show_id
	local show = self.cur_show
	while true do
		if self.cur_show.next_show == "" or self.cur_show.next_show == show_id then
			show_id = show_id + 1
		else
			show_id = show.show_id
		end

		show = self:GetShow(show_id)
		if show ~= nil then
			if show.unuseful ~= 1 then
				self:StartShow(show)
				break
			end
		else
			self:EndStory()
			break
		end
	end	
end

function Story:ClearDelayNextShow()
	if self.delay_next_timer then
		GlobalTimerQuest:CancelQuest(self.delay_next_timer)
		self.delay_next_timer = nil
	end
end

function Story:PlayShowAudio(show_cfg)
	if show_cfg == nil or show_cfg.audio == "" or show_cfg.audio == nil then
		return
	end

	AudioManager.Instance:PlayEffect("res/" .. show_cfg.audio)
	self.audio_path_list[#self.audio_path_list + 1] = path
end

function Story:StopShowAudio()
	for k,v in pairs(self.audio_path_list) do
		AudioManager.Instance:StopEffect(v)
	end
	self.audio_path_list = {}
end

--在剧情结束时再加个幕布淡出，
--因为在剧情中很多面板隐藏，所以为了效果不能配在剧情里
function Story:PlayEndCurtain()
	self:RemoveEndCurtain()
	self.end_curtain = self:ActBornCurtain()
	self:FadeOut(self.end_curtain, 2)
	self.delay_remove_end_curtain = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.RemoveEndCurtain, self), 2)
end

function Story:RemoveEndCurtain()
	if self.delay_remove_end_curtain ~= nil then
		GlobalTimerQuest:CancelQuest(self.delay_remove_end_curtain)
		self.delay_remove_end_curtain = nil
	end
	if self.end_curtain then
		self:RemoveFromFadeInOut(self.end_curtain)
		self.end_curtain:removeFromParent()
		self.end_curtain = nil
	end
end

function Story:DoAct(actor_cfg, act_cfgs)
	if actor_cfg == nil or act_cfgs == nil then return end

	for k,v in pairs(act_cfgs) do  			--一个表演者可能同时执行多个动作
		local act_cfg = v
		local act = act_cfg[1]
		local actor_id = actor_cfg[1]
		local actor_type = actor_cfg[2]

		local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
		if act == ActorAction.Dialog then
			self:ActDialog(actor_cfg, act_cfg)

		-- elseif act == ActorAction.Talk then
		-- 	self:Talk(actor_obj, act_cfg[2])

		elseif act == ActorAction.Born then
			self:ActBorn(actor_cfg, act_cfg)

		elseif act == ActorAction.AutoFight then
			Scene.Instance:GetMainRole():StopMove()
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)

		-- elseif act == ActorAction.CloneMainRole then
		-- 	self:ActCloneMainRole(actor_id)

		-- elseif act == ActorAction.ChangeAppearance then
		-- 	self:ActChangeAppearance(actor_cfg, act_cfg)

		elseif act == ActorAction.Appear then
			self:ActAppear(actor_cfg, act_cfg)

		elseif act == ActorAction.Disappear then
			self:ActDisappar(actor_cfg, act_cfg)

		elseif act == ActorAction.Move or act == ActorAction.MoveBack then
			self:ActMove(actor_cfg, act_cfg)

		elseif act == ActorAction.RunAction then
			self:ActRunAction(actor_cfg, act_cfg)

		-- elseif act == ActorAction.Flying then
		-- 	self:ActFlying(actor_id, act_cfg[2])

		elseif act == ActorAction.Fly or act == ActorAction.FlyBack then
			self:ActFly(actor_cfg, act_cfg)

		-- elseif act == ActorAction.TurnRound then
		-- 	self:ActTurnRound(actor_cfg, tonumber(act_cfg[2]))

		-- elseif act == ActorAction.ResetPos then
		-- 	self:ActResetPos(actor_cfg, act_cfg)

		elseif act == ActorAction.ChangeBlood then
			self:ActChangeBlood(actor_cfg, act_cfg)

		elseif act == ActorAction.Shake then
			self:ActShake(act_cfg[2])

		-- elseif act == ActorAction.Gathering then
		-- 	self:ActGathring(act_cfg[2])

		elseif act == ActorAction.DoAttack then
			self:ActDoAttack(actor_cfg, act_cfg)

		elseif act == ActorAction.ChangeObjAttr then
			self:ActChangeObjAttr(actor_cfg, act_cfg)

		elseif act == ActorAction.CreateScene then
			self:ActCreateScene(tonumber(act_cfg[2]))

		elseif act == ActorAction.ServerStartPlay then
			local protocol = ProtocolPool.Instance:GetProtocol(CSServerStartPlay)
			protocol:EncodeAndSend()

		elseif act == ActorAction.DoNothing then --原地等待
			--donothing
		elseif act == nil or act == "" then  --没有任何动作则直接跳到下一步
			self:NextShow()
		end
	end
end

--对话
function Story:ActDialog(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local actor_id, actor_type, res_name = actor_cfg[1], actor_cfg[2], actor_cfg[3]
	local content = act_cfg[2] or ""

	local role_vo = TableCopy(Scene.Instance:GetMainRole():GetVo())

	if actor_type == ActorType.MainRole then
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		local prof = RoleData.Instance:GetRoleBaseProf()
		res_name = string.format("1_%d_%d", sex, prof)
	end

	self.dialog_view:Open()
	self.dialog_view:DoDialog(res_name, content, BindTool.Bind(self.NextShow, self), BindTool.Bind(self.EndStory, self))
end

--说话（汽泡）
function Story:Talk(actor,content)
	-- body
end

-------------------------------------------------------------------
--出生，即生成
-------------------------------------------------------------------
--出生
function Story:ActBorn(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local actor_id, actor_type = actor_cfg[1], actor_cfg[2]
	local x, y, cfg_id = act_cfg[2], act_cfg[3], act_cfg[4]

	local actor_obj = nil

	if actor_type == ActorType.CloneMainRole then
		actor_obj = self:ActBornCloneMainRole(act_cfg)
		self.new_born_list[actor_obj:GetObjId()] = actor_obj

	elseif actor_type == ActorType.Role then
		actor_obj = self:ActBornRole(act_cfg)
		self.new_born_list[actor_obj:GetObjId()] = actor_obj

	elseif actor_type == ActorType.Monster then
		actor_obj = self:ActBornMonster(act_cfg)
		self.new_born_list[actor_obj:GetObjId()] = actor_obj

	elseif actor_type == ActorType.Npc then
		actor_obj = self:ActBornNpc(act_cfg)
		self.new_born_list[actor_obj:GetObjId()] = actor_obj

	-- elseif actor_type == ActorType.JingLing then
	-- 	actor_obj = self:ActBornJingLing(cfg_id, x, y, tonumber(act_cfg[5]))
	-- 	self.new_born_list[actor_obj:GetObjId()] = actor_obj

	-- elseif actor_type == ActorType.Gather then
	-- 	actor_obj = self:ActBornGather(cfg_id, x, y)
	-- 	self.new_born_list[actor_obj:GetObjId()] = actor_obj

	-- elseif actor_type == ActorType.Mount then
	-- 	local image_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").image_list[tonumber(cfg_id)]
	-- 	if image_cfg ~= nil then
	-- 		actor_obj = self:ActBornMount(image_cfg, x, y, actor_id)
	-- 		self.new_born_list[Scene.Instance:GetClientObjId()] = actor_obj
	-- 	end

	elseif actor_type == ActorType.Curtain then
		actor_obj = self:ActBornCurtain(tonumber(x), tonumber(y), tonumber(act_cfg[4]), tonumber(act_cfg[5]), tonumber(act_cfg[6]))
		self.new_born_list[Scene.Instance:GetClientObjId()] = actor_obj

	elseif actor_type == ActorType.Patting then
		actor_obj = self:ActBornPatting(x, y, act_cfg)
		self.new_born_list[Scene.Instance:GetClientObjId()] = actor_obj

	elseif actor_type == ActorType.Subtitle then
		actor_obj = self:ActBornSubtitle(x, y, act_cfg, actor_id)
		self.new_born_list[Scene.Instance:GetClientObjId()] = actor_obj

	elseif actor_type == ActorType.Effect then
		actor_obj = self:ActBornEffect(x, y, tonumber(cfg_id), tonumber(act_cfg[5]), tonumber(act_cfg[6]), tonumber(act_cfg[7]), tonumber(act_cfg[8] or 0))
		self.new_born_list[Scene.Instance:GetClientObjId()] = actor_obj

	elseif actor_type == ActorType.FallItem then
		actor_obj = self:ActBornFallItem(act_cfg)
		self.new_born_list[actor_obj:GetObjId()] = actor_obj
	end

	if actor_obj and actor_id ~= "" and actor_id ~= 0 then
		self:CacheActorValue(actor_id, "actor_obj", actor_obj)
	end
end

--生成角色
function Story:ActBornRole(act_cfg)
	if act_cfg == nil then return end
	local role_vo = GameVoManager.Instance:CreateVo(RoleVo)
	role_vo.obj_id = Scene.Instance:GetClientObjId()
	local start_index = 1
	local function get_index()
		start_index = start_index + 1
		return start_index
	end
	role_vo.name = tostring(act_cfg[get_index()])
	role_vo[OBJ_ATTR.ENTITY_MODEL_ID] = tonumber(act_cfg[get_index()])
	role_vo.pos_x = tonumber(act_cfg[get_index()] or 0)
	role_vo.pos_y = tonumber(act_cfg[get_index()] or 0)
	role_vo.dir = tonumber(act_cfg[get_index()] or 0)
	role_vo[OBJ_ATTR.CREATURE_MAX_HP] = tonumber(act_cfg[get_index()] or 100)
	role_vo[OBJ_ATTR.CREATURE_HP] = tonumber(act_cfg[get_index()] or role_vo[OBJ_ATTR.CREATURE_MAX_HP])
	local move_speed = tonumber(act_cfg[get_index()] or 2000)
	role_vo[OBJ_ATTR.ACTOR_PROF] = tonumber(act_cfg[get_index()] or 0)
	role_vo[OBJ_ATTR.ACTOR_SEX] = tonumber(act_cfg[get_index()] or 0)
	role_vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = tonumber(act_cfg[get_index()] or 0)
	role_vo[OBJ_ATTR.ACTOR_WING_APPEARANCE] = tonumber(act_cfg[get_index()] or 0)

	local role = Scene.Instance:CreateRole(role_vo)
	role:SetSpecialMoveSpeed(move_speed)
	role:SetMoveSpeed(0)
	role:DoStand()

	return role
end

--生成克隆主角角色
function Story:ActBornCloneMainRole(act_cfg)
	if act_cfg == nil then return end
	local role_vo = TableCopy(Scene.Instance:GetMainRole():GetVo())
	role_vo.obj_id = Scene.Instance:GetClientObjId()

	local start_index = 1
	local function get_index()
		start_index = start_index + 1
		return start_index
	end
	role_vo.pos_x = tonumber(act_cfg[get_index()] or 0)
	role_vo.pos_y = tonumber(act_cfg[get_index()] or 0)
	role_vo.dir = tonumber(act_cfg[get_index()] or 0)
	role_vo[OBJ_ATTR.CREATURE_MAX_HP] = tonumber(act_cfg[get_index()] or 100)
	role_vo[OBJ_ATTR.CREATURE_HP] = tonumber(act_cfg[get_index()] or role_vo[OBJ_ATTR.CREATURE_MAX_HP])
	local move_speed = tonumber(act_cfg[get_index()] or 2000)

	-- role_vo.name = main_role_vo.name
	-- role_vo[OBJ_ATTR.ENTITY_MODEL_ID] = main_role_vo[OBJ_ATTR.ENTITY_MODEL_ID]
	-- role_vo[OBJ_ATTR.ACTOR_PROF] = main_role_vo[OBJ_ATTR.ACTOR_PROF]
	-- role_vo[OBJ_ATTR.ACTOR_SEX] = main_role_vo[OBJ_ATTR.ACTOR_SEX]
	-- role_vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = main_role_vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]
	-- role_vo[OBJ_ATTR.ACTOR_WING_APPEARANCE] = main_role_vo[OBJ_ATTR.ACTOR_WING_APPEARANCE]
	-- role_vo[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = main_role_vo[OBJ_ATTR.ACTOR_FOOT_APPEARANCE]

	local role = Scene.Instance:CreateRole(role_vo)
	role:SetSpecialMoveSpeed(move_speed)
	role:SetMoveSpeed(0)
	role:DoStand()

	return role
end

--生成怪物
function Story:ActBornMonster(act_cfg)
	if act_cfg == nil then return end
	local monster_vo = GameVoManager.Instance:CreateVo(RoleVo)
	monster_vo.obj_id = Scene.Instance:GetClientObjId()
	local start_index = 1
	local function get_index()
		start_index = start_index + 1
		return start_index
	end
	monster_vo.monster_id = 0
	monster_vo.monster_race = EntityType.Monster
	monster_vo.monster_type = MONSTER_TYPE.COMMON
	monster_vo.is_hide_name = 0
	local name = tostring(act_cfg[get_index()])
	monster_vo[OBJ_ATTR.ENTITY_MODEL_ID] = tonumber(act_cfg[get_index()])
	monster_vo.pos_x = tonumber(act_cfg[get_index()] or 0)
	monster_vo.pos_y = tonumber(act_cfg[get_index()] or 0)
	monster_vo.dir = tonumber(act_cfg[get_index()] or 0)
	monster_vo[OBJ_ATTR.CREATURE_MAX_HP] = tonumber(act_cfg[get_index()] or 100)
	monster_vo[OBJ_ATTR.CREATURE_HP] = tonumber(act_cfg[get_index()] or monster_vo[OBJ_ATTR.CREATURE_MAX_HP])
	local move_speed = tonumber(act_cfg[get_index()] or 2000)

	local monster = Scene.Instance:CreateMonster(monster_vo)
	monster:SetSpecialMoveSpeed(move_speed)
	monster:GetVo().name = name
	monster:GetVo().name_color = "0xff2828"
	monster:SetNameLayerShow(true)
	monster:SetMoveSpeed(0)
	monster:DoStand()

	return monster
end

--生成npc
function Story:ActBornNpc(act_cfg)
	if act_cfg == nil then return end
	local npc_vo = GameVoManager.Instance:CreateVo(NpcVo)
	npc_vo.obj_id = Scene.Instance:GetClientObjId()
	local start_index = 1
	local function get_index()
		start_index = start_index + 1
		return start_index
	end
	npc_vo.name = tostring(act_cfg[get_index()])
	npc_vo[OBJ_ATTR.ENTITY_MODEL_ID] = tonumber(act_cfg[get_index()])
	npc_vo.pos_x = tonumber(act_cfg[get_index()] or 0)
	npc_vo.pos_y = tonumber(act_cfg[get_index()] or 0)
	npc_vo.npc_type = 0

	local npc = Scene.Instance:CreateNpc(npc_vo)

	return npc
end

--生成精灵
function Story:ActBornJingLing(cfg_id, x, y, dir_number)
	local sprite_vo = GameVoManager.Instance:CreateVo(SpriteObjVo)
	sprite_vo.sprite_id = tonumber(cfg_id)
	sprite_vo.obj_id = Scene.Instance:GetClientObjId()
	sprite_vo.pos_x = x
	sprite_vo.pos_y = y
	sprite_vo.move_speed = 100

	sprite_obj = Scene.Instance:CreateSpriteObj(sprite_vo)
	if dir_number == nil or dir_number == "" then
		dir_number = math.floor(math.random(0, 3))
	end
	sprite_obj:SetDirNumber(dir_number)
	return sprite_obj
end

--生成采集物
function Story:ActBornGather(cfg_id, x, y)
	local gather_vo = GameVoManager.Instance:CreateVo(GatherVo)
	gather_vo.obj_id = Scene.Instance:GetClientObjId()
	gather_vo.gather_id = tonumber(cfg_id)
	gather_vo.pos_x = x
	gather_vo.pos_y = y
	return Scene.Instance:CreateGather(gather_vo)
end

--生成坐骑
function Story:ActBornMount(image_cfg, x, y, actor_id)
	if image_cfg == nil then return end

	actor_obj = AnimateSprite:create()
	actor_obj:setPosition(HandleRenderUnit:LogicToWorld(cc.p(x, y)))
	HandleRenderUnit:GetCoreScene():addChildToRenderGroup(actor_obj, GRQ_SCENE_OBJ)
	self:SetMountStateAction(actor_obj, image_cfg.res_id, SceneObjState.Stand, GameMath.DirRight)
	self:CacheActorValue(actor_id, "res_id", image_cfg.res_id)
	local zorder = Scene.Instance:GetMainRole():GetModel():GetLocalZOrder()
	actor_obj:setLocalZOrder(zorder - 300)
	return actor_obj
end

--生成幕布
function Story:ActBornCurtain(x, y, width, height, opacity)
	x = x or 0
	y = y or 0
	width = width or HandleRenderUnit:GetWidth()
	height = height or HandleRenderUnit:GetHeight()
	opacity = opacity or 255

	x = self:GetAdaptePosX(x)
	y = self:GetAdapterPosY(y)
	width = self:GetAdapterWidth(width)
	height = self:GetAdapterHeight(height)

	local curtain = XUI.CreateLayout(x, y, width, height)
	curtain:setBackGroundColor(COLOR3B.BLACK)
	curtain:setBackGroundColorOpacity(opacity)
	curtain:setAnchorPoint(0, 0)
	curtain:setPosition(x, y)
	HandleRenderUnit:AddUi(curtain, COMMON_CONSTS.ZORDER_CURTAIN, COMMON_CONSTS.ZORDER_CURTAIN)
	return curtain
end

--生成插画
function Story:ActBornPatting(x, y, act_cfg)
	x = self:GetAdaptePosX(x)
	y = self:GetAdapterPosY(y)

	local path = "res/" .. act_cfg[4]
	local scale = tonumber(act_cfg[5] or 1)
	local rect_x = tonumber(act_cfg[6] or 0)
	local rect_y = tonumber(act_cfg[7] or 0)
	local rect_w = tonumber(act_cfg[8] or 0)
	local rect_h = tonumber(act_cfg[9] or 0)

	local clip_rect = cc.rect(rect_x, rect_y, rect_w, rect_h)
	if path == nil or path == "" then return end

	local patting_img = XUI.CreateImageView(x, y, path, true)
	patting_img:setScale(scale)
	if clip_rect.width ~= 0 and clip_rect.height ~= 0 then
		patting_img:setTextureRect(clip_rect)
	end

	HandleRenderUnit:GetCoreScene():addChildToRenderGroup(patting_img, GRQ_UI_UP)
	return patting_img
end

--生成字幕
function Story:ActBornSubtitle(x, y, act_cfg, actor_id)
	local width = tonumber(act_cfg[4])
	local height = tonumber(act_cfg[5])
	local align = act_cfg[6]
	local content = act_cfg[7]

	x = self:GetAdaptePosX(x)
	y = self:GetAdapterPosY(y)
	width = self:GetAdapterWidth(width)
	height = self:GetAdapterHeight(height)

	self:CacheActorValue(actor_id, "width", width)
	self:CacheActorValue(actor_id, "height", height)
	self:CacheActorValue(actor_id, "align", align)

	local subtitle_txt = XUI.CreateRichText(x, y, width, height)
	subtitle_txt:setAnchorPoint(0.5, 0.5)
	RichTextUtil.ParseRichText(subtitle_txt, content)
	HandleRenderUnit:GetCoreScene():addChildToRenderGroup(subtitle_txt, GRQ_UI_UP)
	
	subtitle_txt:refreshView()
	local text_renderer_size = subtitle_txt:getInnerContainerSize()
	local real_pos = self:GetAdjustAlignPos(x, y, width, height, text_renderer_size.width, text_renderer_size.height, align)
	subtitle_txt:setPosition(real_pos)

	return subtitle_txt
end

--生成普通特效
function Story:ActBornEffect(x, y, effect_id, loops, frame_interval, scale, prof_cond)
	if effect_id == nil or effect_id == 0 then return end

	-- 区分职业播放，不符合当前职业跳过
	if nil ~= prof_cond and 0 ~= prof_cond then
		local prof = RoleData.Instance:GetRoleBaseProf()
		if prof_cond ~= prof then
			return
		end
	end

	local anim_path, anim_name = ResPath.GetEffectAnimPath(effect_id)

	loops = loops or 1
	frame_interval = frame_interval or FrameTime.Atk
	local sprite = RenderUnit.CreateAnimSprite(anim_path, anim_name, frame_interval, loops, false)

	if nil ~= sprite then
		local w_pos = HandleRenderUnit:LogicToWorld(cc.p(x, y))
		sprite:setPosition(w_pos.x, w_pos.y)
		if nil ~= scale then
			sprite:setScale(scale)
		end
		HandleRenderUnit:GetCoreScene():addChildToRenderGroup(sprite, GRQ_SCENE_OBJ)
	end

	return sprite
end

--生成掉落物品
function Story:ActBornFallItem(act_cfg)
	if act_cfg == nil then return end
	local fall_item_vo = GameVoManager.Instance:CreateVo(FallItemVo)
	fall_item_vo.obj_id = Scene.Instance:GetClientObjId()
	local start_index = 1
	local function get_index()
		start_index = start_index + 1
		return start_index
	end
	fall_item_vo.icon_id = tonumber(act_cfg[get_index()] or 0)
	fall_item_vo.name = act_cfg[get_index()] or ""
	fall_item_vo.color = act_cfg[get_index()] or ""
	fall_item_vo.pos_x = tonumber(act_cfg[get_index()] or 0)
	fall_item_vo.pos_y = tonumber(act_cfg[get_index()] or 0)
	fall_item_vo.item_id = 999
	fall_item_vo.entity_type = EntityType.FallItem
	fall_item_vo.fall_time = TimeCtrl.Instance:GetServerTime() - 0.1

	local item = Scene.Instance:CreateFallItem(fall_item_vo)

	return item
end

-------------------------------------------------------------------
--克隆主角
-------------------------------------------------------------------
function Story:ActCloneMainRole(actor_id)
	local role_vo = TableCopy(Scene.Instance:GetMainRole():GetVo())
	role_vo.obj_id = Scene.Instance:GetClientObjId()
	local actor_obj = Scene.Instance:CreateRole(role_vo)
	if actor_obj and actor_id ~= "" and actor_id ~= 0 then
		actor_obj:DoStand()
		self.new_born_list[actor_obj:GetObjId()] = actor_obj
		self:CacheActorValue(actor_id, "actor_obj", actor_obj)
	end
end

-------------------------------------------------------------------
--改变外观。对生出来的对象进行外观二次控制
-------------------------------------------------------------------
function Story:ActChangeAppearance(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local actor_id, actor_type = tonumber(actor_cfg[1]), actor_cfg[2]
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	if actor_obj == nil then return end
	if actor_obj.GetVo == nil then return end

	local appearance = actor_obj:GetVo().appearance

	local wuqi_id = act_cfg[2]
	local wing_jinhua_grade = act_cfg[3]
	local mount_appeid = act_cfg[4]
	if wuqi_id ~= "" and wuqi_id ~= nil then appearance.wuqi_id = tonumber(wuqi_id) end
	if wing_jinhua_grade ~= "" and wing_jinhua_grade ~= nil then appearance.wing_jinhua_grade = tonumber(wing_jinhua_grade) end
	if mount_appeid ~= "" and mount_appeid ~= nil then actor_obj:GetVo().mount_appeid = tonumber(mount_appeid) end

	actor_obj:UpdateMountResId()
	actor_obj:UpdateAppearance()
	actor_obj:RefreshAnimation()
end

-------------------------------------------------------------------
--出现消失 动作
-------------------------------------------------------------------
function Story:ActAppear(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local actor_id, actor_type = tonumber(actor_cfg[1]), actor_cfg[2]
	local disappear_type, effect_id, fadein_time = tonumber(act_cfg[2]), tonumber(act_cfg[3]), tonumber(act_cfg[4])
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	if actor_obj == nil then
		return
	end

	if disappear_type == 1 then
		self:SetActorVisible(actor_obj,true)

	elseif disappear_type == 2 then	
		self:FadeIn(actor_obj, fadein_time)
		local x, y = self:GetActorLogicPos(actor_obj)
		local sprite = self:ActBornEffect(x, y, effect_id)
		self.new_born_list[Scene.Instance:GetClientObjId()] = sprite
	end
end

function Story:ActDisappar(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local actor_id, actor_type = tonumber(actor_cfg[1]), actor_cfg[2]
	local disappear_type, effect_id, fadeout_time = tonumber(act_cfg[2]), tonumber(act_cfg[3]), tonumber(act_cfg[4])
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	if actor_type == ActorType.MainRole then
		actor_obj = Scene.Instance:GetMainRole()
	else
		actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	end
	if actor_obj == nil then
		return
	end

	if disappear_type == 1 then
		self:SetActorVisible(actor_obj, false)

	elseif disappear_type == 2 then	
		self:FadeOut(actor_obj, fadeout_time)
		local x, y = self:GetActorLogicPos(actor_obj)
		local sprite = self:ActBornEffect(x, y, effect_id)
		self.new_born_list[Scene.Instance:GetClientObjId()] = sprite
	end
end

function Story:FadeIn(actor_obj, time)
	if actor_obj == nil then return end

	self:SetActorOpacity(actor_obj, 0)
	self:SetActorVisible(actor_obj, true)

	local time = time or 0.5
	if time <= 0 then time = 1 end
	self:RemoveFromFadeInOut(actor_obj)
	self.fadein_list[#self.fadein_list + 1] = {obj = actor_obj, speed = 255 / time}
end

function Story:FadeOut(actor_obj, time)
	if actor_obj == nil then return end

	self:SetActorOpacity(actor_obj, 255)
	self:SetActorVisible(actor_obj, true)
	local time = time or 0.5
	self:RemoveFromFadeInOut(actor_obj)
	self.fadeout_list[#self.fadeout_list + 1] = {obj = actor_obj, speed = 255 / time}
end

function Story:RemoveFromFadeInOut(actor_obj)
	for k,v in pairs(self.fadein_list) do
		if v.obj == actor_obj then
			self.fadein_list[k] = nil
			break
		end
	end
	for k,v in pairs(self.fadeout_list) do
		if v.obj == actor_obj then
			self.fadeout_list[k] = nil
			break
		end
	end
end

-------------------------------------------------------------------
--移动动作
-------------------------------------------------------------------
--执行移动
function Story:ActMove(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local x, y, move_speed = 0, 0, 0
	local actor_id, actor_type = tonumber(actor_cfg[1]), actor_cfg[2]
	local oldx, oldy = -1, -1
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	local move_type = act_cfg[1]

	if move_type == ActorAction.Move then
		x, y, move_speed = tonumber(act_cfg[2]), tonumber(act_cfg[3]), tonumber(act_cfg[4])
	elseif move_type == ActorAction.MoveBack then
		local pos = self:GetActorCacheValue(actor_id, "old_pos")
		if pos == nil then
			return
		end
		x, y, move_speed = pos.x, pos.y, act_cfg[2]
	end

	x = self:GetAdaptePosX(x) --适配屏幕
	y = self:GetAdapterPosY(y) --适配屏幕

	local screen_pos = cc.p(x, y)
	local world_pos = HandleRenderUnit:LogicToWorld(screen_pos)

	if actor_type == ActorType.MainRole then
		self:MoveMainRole(x, y)

	elseif actor_type == ActorType.Monster or actor_type == ActorType.CloneMainRole or actor_type == ActorType.Role or actor_type == ActorType.JingLing then
		if actor_obj ~= nil then
			oldx, oldy = actor_obj:GetLogicPos()
			if nil ~= move_speed and 0 < move_speed then
				-- 移动速度特殊处理
				local move_speed_mul = math.max(math.abs(x - oldx + 0.5), math.abs(y - oldy + 0.5))
				if move_speed_mul > 2 then
					move_speed = move_speed / move_speed_mul * 1.5
				end
				actor_obj:SetSpecialMoveSpeed(move_speed)
				actor_obj:SetMoveSpeed(0)
			end
			actor_obj:DoMove(x, y)
		end
	
	elseif actor_type == ActorType.Mount then
		self:MoveMount(actor_id, world_pos, move_speed)

	elseif actor_type == ActorType.Camera then
		local logic_pos = HandleRenderUnit:WorldToLogic(HandleGameMapHandler:GetViewCenterPoint())
		oldx, oldy = logic_pos.x, logic_pos.y
		self:MoveCamera(world_pos, move_speed, move_type == ActorAction.MoveBack)

	elseif actor_type == ActorType.Patting then
		self:MovePatting(actor_id, screen_pos, move_speed)

	elseif actor_type == ActorType.Subtitle then
		self:MoveSubtitle(actor_id, screen_pos, move_speed)

	elseif actor_type == ActorType.Effect then
		self:MoveEffect(actor_obj, world_pos, move_speed)
	end

	--存取旧位置,用在返回动作中
	if act_cfg[1] == ActorAction.Move and oldx ~= -1 and oldy ~= -1 and actor_id ~= "" and actor_id ~= 0 then
		self:CacheActorValue(actor_id, "old_pos", {x = oldx, y = oldy})
	end
end

--移动主角
function Story:MoveMainRole(x, y, speed)
	Scene.Instance:GetMainRole():DoMoveByPos({x = x, y = y}, 0)
end

--移动特效
function Story:MoveEffect(actor_obj, end_pos, move_time)
	if actor_obj == nil or end_pos == nil then return end

	local now_x, now_y = actor_obj:getPosition()
	local delta_pos = cc.pSub(end_pos, {x = now_x, y = now_y})
	local rotation = -math.deg(cc.pToAngleSelf(delta_pos))
	actor_obj:setRotation(rotation + 90)
	local move_to = cc.MoveTo:create(move_time, end_pos)
	actor_obj:runAction(move_to)
end

--移动坐骑
function Story:MoveMount(actor_id, end_pos, move_speed)
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	if actor_obj == nil or end_pos == nil then return end
	
	actor_obj:stopAllActions()
	local mount_x, mount_y = actor_obj:getPosition()
	local delta_pos = cc.pSub(end_pos, cc.p(mount_x, mount_y))
	self.state_move_total_distance = cc.pGetLength(delta_pos)
	local dir = GameMath.GetDirectionNumber(delta_pos.x, delta_pos.y)

	local res_id = self:GetActorCacheValue(actor_id, "res_id")
	local move_to = cc.MoveTo:create(move_speed, cc.p(end_pos.x, end_pos.y))
	local move_end_param = {actor_obj = actor_obj, res_id = res_id, dir = dir}
	local callback = cc.CallFunc:create(BindTool.Bind2(self.MoveMountEnd, self, move_end_param))
	local action = cc.Sequence:create(move_to, callback)
	actor_obj:runAction(action)

	self:SetMountStateAction(actor_obj, res_id, SceneObjState.Move, dir)
end

--移动摄像头
function Story:MoveCamera(end_pos, speed, is_moveback)
	if end_pos == nil then return end
	local cache = self.move_camera_cache
	cache.moving = true
	cache.speed = speed or 500
	if not is_moveback or cache.pos == nil then
		cache.pos = HandleGameMapHandler:GetViewCenterPoint()	
	end
	cache.end_x = end_pos.x
	cache.end_y = end_pos.y
	cache.pass_distance = 0
	local delta_pos = cc.pSub(end_pos, cache.pos)
	cache.total_distance = cc.pGetLength(delta_pos)
	cache.move_dir = cc.pNormalize(delta_pos)
end

--移动插画
function Story:MovePatting(actor_id, end_pos, move_speed)
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	if actor_obj ~= nil then
		local move_to = cc.MoveTo:create(move_speed, cc.p(end_pos.x, end_pos.y))
		-- local backIn = cc.EaseExponentialIn:create(move_to)
		local backIn = cc.EaseSineIn:create(move_to)
		actor_obj:runAction(backIn)
	end
end

--移动字幕
function Story:MoveSubtitle(actor_id, end_pos, move_speed)
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	if actor_obj ~= nil then
		local width = self:GetActorCacheValue(actor_id, "width")
		local height = self:GetActorCacheValue(actor_id, "height")
		local align = self:GetActorCacheValue(actor_id, "align")

		actor_obj:refreshView()
		local text_renderer_size = actor_obj:getInnerContainerSize()
		local real_end_pos = self:GetAdjustAlignPos(end_pos.x, end_pos.y, width, height, text_renderer_size.width, text_renderer_size.height, align)

		local move_to = cc.MoveTo:create(move_speed, cc.p(real_end_pos.x, real_end_pos.y))
		actor_obj:runAction(move_to)
	end
end

-------------------------------------------------------------------
--动作
-------------------------------------------------------------------
function Story:ActRunAction(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local actor_id, actor_type = tonumber(actor_cfg[1]), actor_cfg[2]
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	local action = act_cfg[2] or ""
	
	local scale_fadeIn_s1, scale_fadeIn_s2, scale_fadeIn_time = string.match(action, "ScaleFadeIn;(.-);(.-);(.-)#")
	local shake_cfg = string.match(action, "Shake;(.-)#")
	local shake_strength, shake_times, shake_time
	if nil ~= shake_cfg then
		local cfg = Split(shake_cfg, ";")
		shake_strength, shake_times, shake_time = cfg[1], cfg[2], cfg[3] or 1
	end
	local fade_out_x, fade_out_y, fade_out_move_time, fade_out_time = string.match(action, "FadeOut;(.-);(.-);(.-);(.-)#")

	if actor_type == ActorType.Camera then
		-- Scene.Instance:SetSceneCameraScaleTo(scale, time)
	elseif actor_type == ActorType.Patting or actor_type == ActorType.Subtitle then
		local scale_spawn
		if nil ~= scale_fadeIn_s1 then
			actor_obj:setScale(tonumber(scale_fadeIn_s1))
			self:SetActorOpacity(actor_obj, 0)
			scale_spawn = cc.Spawn:create(
				cc.EaseExponentialIn:create(cc.ScaleTo:create(tonumber(scale_fadeIn_time), tonumber(scale_fadeIn_s2))),
				cc.FadeIn:create(tonumber(scale_fadeIn_s1) / 2)
			)
		end

		local shake_act
		if nil ~= shake_strength then
			shake_act = cc.Spawn:create(
				cc.CallFunc:create(function() CommonAction.ShowShakeAction(actor_obj, shake_time, tonumber(shake_strength), tonumber(shake_times)) end),
				cc.DelayTime:create(shake_time)
			)
		end

		local fade_out_act
		if nil ~= fade_out_x then
			fade_out_act = cc.Spawn:create(
				cc.MoveBy:create(fade_out_move_time, cc.p(tonumber(fade_out_x), tonumber(fade_out_y))),
				cc.FadeOut:create(fade_out_time)
			)
		end

		local sequence = cc.Sequence:create(scale_spawn, shake_act, fade_out_act)
		actor_obj:runAction(sequence)
	end
end

-------------------------------------------------------------------
--飞行动作,在空中飞
-------------------------------------------------------------------
function Story:ActFlying(actor_id, flying_process)
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	if actor_obj == nil then return end

	if flying_process == "up" and actor_obj.StartFlyingUp then
		actor_obj:StartFlyingUp()
		Scene.Instance:SetSceneCameraScaleTo(COMMON_CONSTS.FLYING_CAMCERA_SCALE, COMMON_CONSTS.FLYING_UP_USE_TIME)
	elseif flying_process == "down" and actor_obj.StartFlyingDown then
		actor_obj:StartFlyingDown()
		Scene.Instance:SetSceneCameraScaleTo(1, COMMON_CONSTS.FLYING_DOWN_USE_TIME)
	end
end

-------------------------------------------------------------------
--飞行动作，直接设置在某个点
-------------------------------------------------------------------
function Story:ActFly(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end
	local act_type, x, y = act_cfg[1], 0, 0
	local actor_id, actor_type = tonumber(actor_cfg[1]), actor_cfg[2]

	if act_type == ActorAction.Fly then
		x, y = act_cfg[2], act_cfg[3]
	elseif act_type == ActorAction.FlyBack then
		local old_pos = self:GetActorCacheValue(actor_id, "old_pos")
		if old_pos == nil then
			return
		end
		x, y = old_pos.x, old_pos.y
	end

	local oldx, oldy = -1, -1
	if actor_type == ActorType.MainRole or actor_type == ActorType.Monster or actor_type == ActorType.Role 
		or actor_type == ActorType.JingLing then
		actor = self:GetActorCacheValue(actor_id, "actor_obj")
		if actor ~= nil then
			oldx, oldy = actor:GetLogicPos()
			actor:SetLogicPos(x, y)
		end

	elseif actor_type == ActorType.Camera then
		local logic_pos = HandleRenderUnit:WorldToLogic(Scene.Instance:GetMainRole().view_cneter_pos)
		oldx, oldy = logic_pos.x, logic_pos.y
		local real_pos = HandleRenderUnit:LogicToWorld(cc.p(x, y))
		HandleGameMapHandler:setViewCenterPoint(real_pos.x, real_pos.y)
		Scene.Instance:CheckClientObj()
	end

	--存取旧位置,用在返回动作中
	if act_type == ActorAction.Fly and oldx ~= -1 and oldy ~= -1 and actor_id ~= "" and actor_id ~= 0 then
		self:CacheActorValue(actor_id, "old_pos", {x = oldx, y = oldy})
	end

	if self.show_end_callback ~= nil then
		self.show_end_callback()
	end
end

-------------------------------------------------------------------
--转向动作
-------------------------------------------------------------------
function Story:ActTurnRound(actor_cfg, dir_number)
	if actor_cfg == nil then return end

	local actor_id = actor_cfg[1]
	local actor_type = actor_cfg[2]
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")

	if actor_obj == nil then return end

	if actor_type == ActorType.MainRole or actor_type == ActorType.Role 
		or actor_type == ActorType.Monster or actor_type == ActorType.Npc
		or actor_type == ActorType.JingLing then

		actor_obj:SetDirNumber(dir_number)
		actor_obj:DoStand()
	end 
end

-------------------------------------------------------------------
--打人动作
-------------------------------------------------------------------
function Story:ActDoAttack(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local actor_id, actor_type = tonumber(actor_cfg[1]), actor_cfg[2]
	local skill_id, dir_number, prof_cond = tonumber(act_cfg[2]), tonumber(act_cfg[3]), tonumber(act_cfg[4] or 0)
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")

	if actor_obj == nil or not actor_obj:IsCharacter() then
		return
	end

	-- 区分职业攻击
	if 0 ~= prof_cond and (actor_type == ActorType.CloneMainRole or actor_type == ActorType.MainRole) then
		local prof = RoleData.Instance:GetRoleBaseProf()
		if prof_cond ~= prof then
			return
		end
	end
	
	if nil ~= actor_obj.DoAttack then
		actor_obj:DoAttack(skill_id, 1, 0)
		if nil ~= dir_number then
			actor_obj:SetDirNumber(dir_number)
		end
	end
end

-------------------------------------------------------------------
--改变对象的属性、状态
-------------------------------------------------------------------
local STORY_CHANGE_TYPE_KEY = {
	max_hp = {key = 11, is_num = true},			-- 最大hp
	hp = {key = 7, is_num = true},				-- hp(血量低于或等于零时，对象死亡)
	max_inner = {key = 143, is_num = true},		-- 最大内功值
	inner = {key = 83, is_num = true},			-- 当前内功值
	dir = {key = "dir", is_num = true},			-- 方向
	name = {key = "name", is_num = false},		-- 名字
}
function Story:ActChangeObjAttr(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local actor_id, actor_type = tonumber(actor_cfg[1]), actor_cfg[2]
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	local change_type, change_value = act_cfg[2], act_cfg[3]
	local change_vo_t = STORY_CHANGE_TYPE_KEY[change_type]
	if nil == change_vo_t or actor_obj == nil or not actor_obj:IsCharacter() then
		return
	end
	
	if nil ~= actor_obj.SetAttr then
		if "dir" == change_type then
			actor_obj:SetDirNumber(tonumber(change_value))
			actor_obj:RefreshAnimation()
		else
			actor_obj:SetAttr(change_vo_t.key, change_vo_t.is_num and tonumber(change_value) or change_value)
		end
	end
end

-------------------------------------------------------------------
--重置位置
-------------------------------------------------------------------
function Story:ActResetPos(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end
		
	local actor_id = actor_cfg[1]
	local actor_type = actor_cfg[2]
	local actor_obj = self:GetActorCacheValue(actor_id, "actor_obj")
	
	if actor_obj == nil then return end

	local reset_type = tonumber(act_cfg[2])
	local x = tonumber(act_cfg[3])
	local y = tonumber(act_cfg[4])

	if actor_type == ActorType.MainRole or actor_type == ActorType.Role 
		or actor_type == ActorType.Monster or actor_type == ActorType.Npc
		or actor_type == ActorType.JingLing then
		actor_obj:DoStand()
		if reset_type == 1 then 	--冲锋或击退
			self:ImitateResetByProtocol(actor_obj:GetObjId(), x, y)
		elseif reset_type == 2 then --直接设置
			actor_obj:SetRealPos(x, y)
		end
	end
end

--通过协议模防重置位置
function Story:ImitateResetByProtocol(obj_id, x, y)
	local protocol = {}
	protocol.obj_id = obj_id
	protocol.skill_id = 0
	protocol.reset_pos_type = 0
	protocol.pos_x = x
	protocol.pos_y = y
 	Scene.Instance:OnSkillResetPos(protocol)
end

-------------------------------------------------------------------
--发生战斗事件
-------------------------------------------------------------------
function Story:ActChangeBlood(actor_cfg, act_cfg)
	if actor_cfg == nil or act_cfg == nil then return end

	local target_obj = self:GetActorCacheValue(act_cfg[2], "actor_obj")
	local deliverer_obj = self:GetActorCacheValue(act_cfg[3], "actor_obj")
	if target_obj == nil or deliverer_obj == nil then
		return
	end

	local protocol = {}
	protocol.obj_id = target_obj:GetObjId()
	protocol.deliverer = deliverer_obj:GetObjId()
	protocol.skill = tonumber(act_cfg[4])
	protocol.fighttype = tonumber(act_cfg[5])
	protocol.product_method = 0
	protocol.real_blood = tonumber(act_cfg[6])
	protocol.blood = tonumber(act_cfg[6])

	if deliverer_obj == Scene.Instance:GetMainRole() then
		local target_x, target_y = target_obj:GetLogicPos()
		Scene.Instance:GetMainRole():DoAttack(protocol.skill, target_x, target_y, protocol.obj_id, target_obj:GetType(), nil)
	end
	self:ImitateFightByProtocol(protocol)
end

--通过协议模防战斗过程
function Story:ImitateFightByProtocol(protocol)
	local obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	local deliverer = Scene.Instance:GetObjectByObjId(protocol.deliverer)
	if nil == deliverer or not deliverer:IsCharacter() then
		return
	end

	if deliverer:GetType() ~= SceneObjType.MainRole then
		if not ConfigManager.IsAoeSkill(protocol.skill) then
			self.imitate_atk_key = self.imitate_atk_key - 1

			local target_x, target_y = obj:GetLogicPos()
			deliverer:SetDirNumberByXY(target_x, target_y)
			deliverer:DoAttack(protocol.skill, target_x, target_y, protocol.obj_id, obj:GetType(), nil)
		end
	end

	obj:DoHpChange(self.imitate_atk_key, protocol.skill, protocol.real_blood, protocol.blood, protocol.fighttype, deliverer, nil, true)
end

--震动
function Story:ActShake(strength)
	if not SettingData.Instance:GetOneSysSetting(SETTING_TYPE.SHIELD_SHAKE) and not self.shake_cache.shaking then
		self.shake_cache.cur_shake_step = 1
		self.shake_cache.shaking = true
		self.shake_cache.shake_strength = strength
		self.shake_cache.cur_shake_strength = strength
		self.shake_cache.cur_shake_dir = -1
		local pos_x, pos_y = HandleRenderUnit:GetCoreScene():getPosition()
		self.shake_cache.shake_center = {x = pos_x, y = pos_y}
	end
end

--采集
function Story:ActGathring(gather_time)
	GatherBar.Instance:Open()
	GatherBar.Instance:SetGatherTime(gather_time)
end

--创建场景
function Story:ActCreateScene(scene_id)
	if nil == self.real_scene_info then
		self.real_scene_info = TableCopy(Scene.Instance:GetSceneConfig())
	end

	HandleGameMapHandler:ChangeScene(scene_id)
	HandleRenderUnit:UpdateWorldSize()
	HandleGameMapHandler:OnLoadingSceneQuit()

	Scene.Instance:CheckClientObj()
end

function Story:SetMountStateAction(actor_obj, res_id, action, dir)
	if actor_obj == nil or res_id == nil then return end

	if dir == GameMath.DirLeft then
		dir = GameMath.DirRight
		is_flip_x = true
	end
	local anim_path, anim_name = ResPath.GetMountAnimPath(res_id, action, dir)
	actor_obj:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.1, is_flip_x)
end

function Story:MoveMountEnd(move_end_param)
	if move_end_param and move_end_param.actor_obj then
		move_end_param.actor_obj:stopAllActions()
		self:SetMountStateAction(move_end_param.actor_obj, move_end_param.res_id, SceneObjState.Stand, move_end_param.dir)
	end
	if self.show_end_callback ~= nil then
		self.show_end_callback()
	end

end

-- 更新方法是否空闲
local update_is_free = true
function Story:Update(now_time, elapse_time)
	-- update_is_free = not self.is_storing

	-- self:UpdateFadeInOut(now_time, elapse_time)

	if self.shake_cache.shaking and now_time - self.shake_cache.prve_shake_time > self.shake_cache.shake_frequency then
		self.shake_cache.prve_shake_time = now_time
		self:UpdateShake(now_time, elapse_time)
		-- update_is_free = false
	end

	if self.move_camera_cache.moving then
		self:UpdateMoveCamera(now_time, elapse_time)
		-- update_is_free = false
	end

	-- if update_is_free then
	-- 	Runner.Instance:RemoveRunObj(self)
	-- end
end

function Story:UpdateFadeInOut(now_time, elapse_time)
	if #self.fadein_list == 0 and #self.fadeout_list == 0 then
		return
	end

	update_is_free = false
	local opacity = 0

	for i = #self.fadein_list, 1, -1 do
		local v = self.fadein_list[i]
		if v then
			opacity = self:GetActorOpacity(v.obj) + v.speed * elapse_time
			if opacity > 255 then
				opacity = 255
				table.remove(self.fadein_list, i)
			end
			self:SetActorOpacity(v.obj, opacity)
		end
	end

	for i = #self.fadeout_list, 1, -1 do
		local v = self.fadeout_list[i]
		if v then
			opacity = self:GetActorOpacity(v.obj) - v.speed * elapse_time
			if opacity < 0 then
				opacity = 0
				self:SetActorVisible(v.obj, false)
				table.remove(self.fadeout_list, i)
			end
			self:SetActorOpacity(v.obj, opacity)
		end
	end
end

local reduction_val = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 0,
	[6] = 0,
	[7] = 1,
	[8] = 1,
	[9] = 1,
	[10] = 1,
}
function Story:UpdateShake(now_time, elapse_time)
	local cache = self.shake_cache
	local is_end_shake = false
	if cache.cur_shake_step > 20 or cache.cur_shake_strength <= 0 then
		is_end_shake = true
		self:ClearShakeCache()
		HandleRenderUnit:GetCoreScene():setPosition(0, 0)
	else
		 HandleRenderUnit:GetCoreScene():setPosition(cache.shake_center.x + cache.cur_shake_strength * cache.cur_shake_dir,
		 	cache.shake_center.y + cache.cur_shake_strength * cache.cur_shake_dir)

	 	cache.cur_shake_step = cache.cur_shake_step + 1
		local rand_num = math.random(10)
	 	cache.cur_shake_strength = cache.cur_shake_strength - reduction_val[rand_num]
	 	cache.cur_shake_dir = - cache.cur_shake_dir
	end

	if is_end_shake then
		self:ClearShakeCache()
		if self.show_end_callback ~= nil then
			self.show_end_callback()
		end
	end
end

--更新摄象头位置
function Story:UpdateMoveCamera(now_time, elapse_time)
	local cache = self.move_camera_cache
	local distance = elapse_time * cache.speed
	cache.pass_distance = cache.pass_distance + distance
	if cache.pass_distance >= cache.total_distance then
		cache.moving = false
		HandleGameMapHandler:setViewCenterPoint(cache.end_x, cache.end_y)
		if self.show_end_callback ~= nil then
			self.show_end_callback()
		end
	else
		local mov_dir = cc.pMul(cache.move_dir, distance)
		local now_pos = cc.pAdd(cache.pos, mov_dir)
		HandleGameMapHandler:setViewCenterPoint(now_pos.x, now_pos.y)
		cache.pos = now_pos
	end
	Scene.Instance:CheckClientObj()
end

function Story:UpdateMoveMount(now_time, elapse_time)
	local cache = self.move_mount_cache
	local distance = elapse_time * cache.speed
	cache.pass_distance = cache.pass_distance + distance
	if cache.pass_distance >= cache.total_distance then
		cache.moving = false

		HandleGameMapHandler:setViewCenterPoint(cache.end_x, cache.end_y)
		if self.show_end_callback ~= nil then
			self.show_end_callback()
		end
	else
		local mov_dir = cc.pMul(cache.move_dir, distance)
		local now_pos = cc.pAdd(cache.pos, mov_dir)
		HandleGameMapHandler:setViewCenterPoint(now_pos.x, now_pos.y)
		cache.pos = now_pos
	end
	Scene.Instance:CheckClientObj()
end

function Story:GetActorLogicPos(actor_obj)
	if actor_obj == nil then return end
	if actor_obj.GetLogicPos then
		return actor_obj:GetLogicPos()
	else
		local w_x, w_y = actor_obj:getPosition()
		local logic_pos = HandleRenderUnit:WorldToLogic({x = w_x, y = w_y})
		return logic_pos.x, logic_pos.y
	end
	return 0, 0
end

function Story:GetActorOpacity(actor_obj)
	if actor_obj == nil  then return 0 end
	
	if actor_obj.GetModel then
		return actor_obj:GetModel():GetOpacity()
	elseif actor_obj.getBackGroundColorOpacity then
		return actor_obj:getBackGroundColorOpacity()
	else
		return actor_obj:getOpacity()
	end
end

function Story:SetActorOpacity(actor_obj, opacity)
	if actor_obj == nil  then return end
	
	if actor_obj.GetModel then
		actor_obj:GetModel():SetOpacity(opacity)
	elseif actor_obj.setBackGroundColorOpacity then
		actor_obj:setBackGroundColorOpacity(opacity)
	else
		actor_obj:setOpacity(opacity)
	end
end

function Story:SetActorVisible(actor_obj, visible)
	if actor_obj == nil  then return end
	
	if actor_obj.GetModel then
		actor_obj:GetModel():SetAllVisible(visible, actor_obj:GetObjId())
	else
		actor_obj:setVisible(visible)
	end
end

function Story:RemoveAllActor()
	for k,v in pairs(self.new_born_list) do
		if v.GetObjId then
			Scene.Instance:DeleteObj(v:GetObjId())
		else
			v:removeFromParent()
		end
	end
	self.new_born_list = {}
end

function Story:GetAdaptePosX(x)
	x = tonumber(x)
	if x >= -2 and x <= 2 then
		local screen_w = HandleRenderUnit:GetWidth()
		return math.floor(screen_w * x)
	end
	return x
end

function Story:GetAdapterPosY(y)
	y = tonumber(y)
	if y >= -2 and y <= 2 then
		local screen_h = HandleRenderUnit:GetHeight()
		return math.floor(screen_h * y)
	end
	return y
end

function Story:GetAdapterWidth(width)
	width = tonumber(width)
	if width > 0 and width <= 1 then
		local screen_w = HandleRenderUnit:GetWidth()
		return math.floor(screen_w * width)
	end
	return width
end

function Story:GetAdapterHeight(height)
	height = tonumber(height)
	if height > 0 and height <= 1 then
		local screen_h = HandleRenderUnit:GetHeight()
		return math.floor(screen_h * height)
	end
	return height
end

--调整对齐的位置
function Story:GetAdjustAlignPos(x, y, width, height, real_width, real_height, align)
	local pos_x = x
	local pos_y = y
	if align == "left" then
		pos_x = x
		pos_y = pos_y + (height - real_height) / 2
	elseif align == "center" then	
		pos_x = pos_x + (width - real_width) / 2
		pos_y = pos_y + (height - real_height) / 2
	elseif align == "right" then
		pos_x = pos_x + width - real_width
		pos_y = pos_y + (height - real_height) / 2
	end
	return {x = pos_x, y = pos_y}
end

function Story:SetOtherOpenViewVisible(value)
	if value then
		ViewManager.Instance:Open(ViewDef.MainUi)
	else
		ViewManager.Instance:CloseAllView()
		ViewManager.Instance:Close(ViewDef.MainUi)
	end
end

--面板隐藏过滤函数
function Story:HideViewFilterFun(view)
	if view ~= self.dialog_view and view ~= self.story_modal then
		return true
	end
	return false
end

--场景中有对象生成
function Story:OnObjCreate(obj)
	local obj_id = obj:GetObjId()
	-- 大剧情中隐藏不属于剧情的场景对象形象
	GlobalTimerQuest:AddDelayTimer(function()
		if nil == self.new_born_list[obj_id] then
			local obj = Scene.Instance:GetObjectByObjId(obj_id)
			if nil ~= obj then
				obj:GetModel():SetAllVisible(false)
			end
		end
	end, 0)
end

function Story:SetOtherSceneObjsVisible(value)
	for k,v in pairs(Scene.Instance.obj_list) do
		if v ~= Scene.Instance:GetMainRole() and self.new_born_list[v:GetObjId()] == nil then
			v:GetModel():SetAllVisible(value)
		end
	end

	-- for k,v in pairs(Scene.Instance.client_obj_list) do
	-- 	if (v:GetType() == SceneObjType.Npc or v:GetType() == SceneObjType.SpriteObj) and self.new_born_list[v:GetObjId()] == nil then
	-- 		v:GetModel():SetAllVisible(value)
	-- 	end
	-- end

	if value then
		Scene.Instance:RefreshPingBiRole()
	end
end
