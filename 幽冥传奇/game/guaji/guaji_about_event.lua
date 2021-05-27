GuajiCtrl = GuajiCtrl or BaseClass(BaseController)

function GuajiCtrl:RegisterAllEvents()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
	self:Bind(ObjectEventType.MAIN_ROLE_DEAD, BindTool.Bind1(self.OnMainRoleDead, self))
	self:Bind(ObjectEventType.BE_SELECT, BindTool.Bind(self.OnSelectObj, self))
	self:Bind(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))
	self:Bind(ObjectEventType.OBJ_DELETE, BindTool.Bind(self.OnObjDelete, self))
	self:Bind(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDead, self))
	self:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT, BindTool.Bind(self.OnSceneLoadingQuite, self))

	local last_anger = 0
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_ANGER, function (vo)
		--释放完必杀技后 怒气刷新不及时 可能会有错误判断
		if last_anger >= FuwenData.Instance:GetMaxAnger() then
			--更新攻击信息
			if self.AtkInfo.is_valid then
				self:ClearAtkOperate()
				self:StrictCheckAtkOpt()
			end
		end
		last_anger = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ANGER)
	end)
end

function GuajiCtrl:OnMainRoleDead()
	self:SetGuajiType(GuajiType.None)
end

-- 选择场景对象
function GuajiCtrl:OnSelectObj(target_obj, select_type)
	if nil == target_obj then
		self:CancelSelect()
		if GuajiCache.guaji_type == GuajiType.HalfAuto then
			self:SetGuajiType(GuajiType.None)
		end
		return
	end

	-- 已被选中
	local is_already_select = (nil ~= target_obj.is_select) and target_obj.is_select or false

	if target_obj ~= GuajiCache.target_obj then
		self:CancelSelect()
	end

	target_obj:OnClick()

	-- 每次选中都会缓存对象
	GuajiCache.target_obj = target_obj
	GuajiCache.target_obj_id = target_obj:GetObjId()
	if target_obj:IsCharacter() then
		GuajiCache.old_target_obj_id = target_obj:GetObjId()
	end
	
	if "select" == select_type then	-- 只是选中不附加做其它操作
		return
	elseif "auto_pickup" ~= select_type then -- 不是自动拾取物品说明是玩家操作，将清除一些操作信息
		MoveCache.task_id = 0
	end

	if (target_obj:GetType() == SceneObjType.Monster and Scene.Instance:IsEnemy(target_obj))
		or (target_obj:GetType() == SceneObjType.Role and is_already_select) then	-- 如果对象是角色，第二次选中时进行攻击
		self:DoAttackTarget(target_obj)
	elseif target_obj:GetType() == SceneObjType.Npc then
		MoveCache.end_type = MoveEndType.ClickNpc
		self:MoveToObj(target_obj)

	elseif target_obj:GetType() == SceneObjType.DirOreObj then
		self:MoveToObj(target_obj, 0, 0)
	elseif target_obj:GetType() == SceneObjType.FallItem then
		if "auto_pickup" ~= select_type then
			self:ClearAllOperate()
		end
		MoveCache.end_type = MoveEndType.PickItem
		self:MoveToObj(target_obj, 0, 0)
	elseif (target_obj:GetType() == SceneObjType.Monster and target_obj:IsRealDead()) then
		-- 玩家未处以挖掘状态
		if not DiamondPetCtrl.Instance:IsExcavating() then
			local excavate_boss_list = DiamondPetCtrl.Instance:GetExcavateBossList()
			local obj_id = target_obj.vo.obj_id
			local excavate_boss_view = excavate_boss_list[obj_id]
			if excavate_boss_view and excavate_boss_view.parent then
					local obj = Scene.Instance:GetObjectByObjId(obj_id)
					MoveCache.end_type = MoveEndType.ExcavateBoss
					self:MoveToObj(obj, 0, 0)
					DiamondPetCtrl.Instance:SetObjId(obj_id)
				return
			end
		end
	end
end

function GuajiCtrl:OnObjDelete(obj)
	if obj == GuajiCache.target_obj then
		GuajiCache.target_obj = nil
		GuajiCache.target_obj_id = COMMON_CONSTS.INVALID_OBJID
	end
end

function GuajiCtrl:OnObjCreate(obj)
	if obj:IsMainRole() then
		return
	end

	if MoveCache.is_valid then
		if MoveCache.end_type == MoveEndType.NpcTask then
			if obj:GetType() == SceneObjType.Npc and obj:GetNpcId() == MoveCache.param1 then
				self:OnSelectObj(obj, "select")
			end
		elseif MoveCache.end_type == MoveEndType.FightAuto then
			-- 乱跑中，场景中出现新对象就去立刻更新一下状态
			self:UpdateAuto(true)
		end
	elseif GuajiCache.old_target_obj_id == obj:GetObjId() then
		-- GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, obj, "select")
	end
end

function GuajiCtrl:OnObjDead(obj)
	if obj == GuajiCache.target_obj then
		self:CancelSelect()
		GuajiCache.target_obj = nil
	end

	if obj == self.AtkInfo.target_obj then
		self:ClearAtkOperate()
	end
end

-- 场景变更结束 注意时传送也会触发
function GuajiCtrl:OnSceneLoadingQuite()
	if not MoveCache.is_valid then
		return
	end

	if MoveCache.move_type == MoveType.Pos then
		if MoveCache.scene_id == self.scene:GetSceneId()
			and self:CheckRange(MoveCache.x, MoveCache.y, MoveCache.range + MoveCache.offset_range) then
			self:OnArrive()
		else
			-- 一般是传送后才会进来这里，此时位置还不是最终位置
			GlobalTimerQuest:CancelQuest(self.delay_move_timer)
			self.delay_move_timer = nil

			local scene_id, x, y = MoveCache.scene_id, MoveCache.x, MoveCache.y
			self.delay_move_timer = GlobalTimerQuest:AddDelayTimer(function()
				self.delay_move_timer = nil
				if scene_id == MoveCache.scene_id and x == MoveCache.x and y == MoveCache.y then
					self:MoveToScenePos(scene_id, x, y)
				end
			end, 0.5)
		end
	elseif MoveCache.move_type == MoveType.Fly then
		self:DelayArrive()
	end
end

-- 到达
function GuajiCtrl:DelayArrive()
	GlobalTimerQuest:CancelQuest(self.delay_arrive_timer)
	self.delay_arrive_timer = nil

	if MoveCache.end_type == MoveEndType.Normal then
		self:OnArrive()
		return
	end
	
	local scene_id = MoveCache.scene_id
	self.delay_arrive_timer = GlobalTimerQuest:AddDelayTimer(function()
		self.delay_arrive_timer = nil
		if MoveCache.is_valid and scene_id == MoveCache.scene_id then
			self:OnArrive()
		end
	end, 0.5)
end

-- 到达
function GuajiCtrl:OnArrive()
	if MoveCache.move_type == MoveType.Obj then
		if nil ~= MoveCache.target_obj and MoveCache.target_obj == self.scene:GetObjectByObjId(MoveCache.target_obj_id) then
			local x, y = MoveCache.target_obj:GetLogicPos()
			if not self:CheckRange(x, y, MoveCache.range + MoveCache.offset_range) then
				self:MoveToObj(MoveCache.target_obj, MoveCache.range, MoveCache.offset_range)
				return
			end
		end
	elseif MoveCache.move_type == MoveType.Pos then
		if MoveCache.scene_id ~= self.scene:GetSceneId() then
			return
		end
		if not self:CheckRange(MoveCache.x, MoveCache.y, MoveCache.range + MoveCache.offset_range) then
			self:MoveToPos(MoveCache.scene_id, MoveCache.x, MoveCache.y, MoveCache.range, MoveCache.offset_range)
			return
		end
	end

	self:OnOperate()
end

-- 处理移动后的操作逻辑
function GuajiCtrl:OnOperate()
	if not MoveCache.is_valid then
		return
	end
	MoveCache.is_valid = false

	local end_type = MoveCache.end_type

	if end_type == MoveEndType.Fight then
		self:OnOperateFight()
	elseif end_type == MoveEndType.AttackTarget then
		self:OnOperateAttackTarget()
	elseif end_type == MoveEndType.ClickNpc then
		self:OnOperateClickNpc()
	elseif end_type == MoveEndType.NpcTask then
		self:OnOperateNpcTask()
	elseif end_type == MoveEndType.FightByMonsterId then
		self:OnOperateFightByMonsterId()
	elseif end_type == MoveEndType.CollectById then
		self:OnOperateCollectById()
	elseif end_type == MoveEndType.PickItem then
		self:OnOperatePickItem()
	elseif end_type == MoveEndType.OtherOpt then
		self:OnOperateOther()
	elseif end_type == MoveEndType.PracticeTP then
		self:OnEnterPracticeTP()
	elseif end_type == MoveEndType.ExcavateBoss then
		DiamondPetCtrl.Instance:OnExcavate()
	end
	
	MoveCache.end_type = MoveEndType.Normal
end

function GuajiCtrl:OnEnterPracticeTP()
	PracticeCtrl.SendEnterPractice(EnterPracticeTab.cEnterFloor)
end

-- 战斗
function GuajiCtrl:OnOperateFight()
	self:DoAtk()
end

-- 攻击目标
function GuajiCtrl:OnOperateAttackTarget()
	if nil ~= MoveCache.target_obj and MoveCache.target_obj == Scene.Instance:GetObjectByObjId(MoveCache.target_obj_id) then
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, MoveCache.target_obj, "select")
		self:DoAttackTarget(MoveCache.target_obj)
	end
end

-- 与npc对话(点击)
function GuajiCtrl:OnOperateClickNpc()
	if nil ~= MoveCache.target_obj and MoveCache.target_obj == Scene.Instance:GetObjectByObjId(MoveCache.target_obj_id) then
		TaskCtrl.SendNpcTalkReq(MoveCache.target_obj_id, "")
	end
end

-- 与npc对话(任务)
function GuajiCtrl:OnOperateNpcTask()
	local npc = self.scene:GetNpcByNpcId(MoveCache.param1)
	if nil ~= npc then
		self:OnSelectObj(npc, "select")
		TaskCtrl.SendNpcTalkReq(npc:GetObjId(), "")
	end
end

-- 根据怪物id打怪
function GuajiCtrl:OnOperateFightByMonsterId()
	self:SetGuajiType(GuajiType.Auto)
end

-- 采集
function GuajiCtrl:OnOperateCollectById()
end

-- 拾取
function GuajiCtrl:OnOperatePickItem()
	-- local start_time = os.clock()

	if nil ~= MoveCache.target_obj and MoveCache.target_obj == Scene.Instance:GetObjectByObjId(MoveCache.target_obj_id) then
		MoveCache.target_obj:ResetPickTime()
		self.last_pick_time = Status.NowTime
		Scene.Instance:ScenePickItem(MoveCache.target_obj_id)

		
		if ClientSceneCanShow[Scene.Instance:GetSceneId()] then
			local obj = Scene.Instance:GetObjectByObjId(MoveCache.target_obj_id)
			local item_id = obj:GetItemID()
			if ClientItemIdCanShow[item_id] then
		 		Scene.Instance:FlyToRolePhoto()
		 	end
		end
	end

	if GuajiCache.guaji_type ~= GuajiType.None then
		local task_info = TaskData.Instance:GetTaskInfo(MoveCache.task_id)
		if nil ~= task_info and not Scene.Instance:CanPickFallItem() then
		end
	end

	-- local obj = Scene.Instance:GetObjectByObjId(MoveCache.target_obj_id)
	-- if obj then
	-- 	Scene.Instance:FlyToRolePhoto()
	-- end

	-- 捡东西时长调试
	-- if os.clock() - start_time >= 0.002 then
	-- 	if PLATFORM == cc.PLATFORM_OS_WINDOWS then
	-- 		print("调用时间:  ", os.clock() - start_time) 
	-- 		DebugLog()
	-- 	end
	-- end
end

-- 其它操作
function GuajiCtrl:OnOperateOther()
	if nil ~= MoveCache.param1 then
		MoveCache.param1()
	end
end


-- 玩家正在操作移动-改为事件
function GuajiCtrl:SetPlayerOptState(is_opt_move)
	if is_opt_move ~= MoveCache.is_player_opting then
		MoveCache.is_player_opting = is_opt_move
		if not MoveCache.is_player_opting then
			MoveCache.last_player_opt_time = Status.NowTime
			-- 玩家松开移动时清除一下攻击缓存
			self:ClearAtkOperate(ATK_SOURCE.PLAYER)
		end
	end
end

-- 玩家正在操作移动-改为事件（新增）
function GuajiCtrl:NewSetOptState(is_opt_move)
	if is_opt_move ~= MoveCache.is_opting_me then
		MoveCache.is_opting_me = is_opt_move

		if not MoveCache.is_opting_me then
			MoveCache.last_player_opt_time = Status.NowTime
			-- 玩家松开移动时清除一下攻击缓存
			self:ClearAtkOperate(ATK_SOURCE.PLAYER)
		end
	end
end

function GuajiCtrl:RecvMainInfoCallBack()
	Runner.Instance:AddRunObj(self, 4)

	-- 指定 场景 攻击信息缓存
	self.scene = Scene.Instance
	self.AtkInfo = AtkInfo
end