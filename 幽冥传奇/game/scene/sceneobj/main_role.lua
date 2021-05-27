
MainRole = MainRole or BaseClass(Role)

AutoType = {
	None = 0,
	FindPath = 1,
	Guaji = 2,
}

function MainRole:__init(vo)
	self.obj_type = SceneObjType.MainRole

	self.is_gather_state = false

	self.last_logic_pos = cc.p(0, 0)
	self.last_real_pos = cc.p(0, 0)
	self.view_cneter_pos = cc.p(0, 0)
	self.server_pos_x = self.vo.pos_x
	self.server_pos_y = self.vo.pos_y

	self.path_pos_list = {}							-- 寻路路径拐点
	self.path_pos_index = 0							-- 拐点索引

	self.follow_obj = follow_obj
	self.follow_objid = COMMON_CONSTS.INVALID_OBJID
	self.follow_x = 0
	self.follow_y = 0
	self.follow_range = 0

	self.move_end_func = nil
	self.move_cache_on_atk_end = nil

	self.is_in_safe = false							-- 是否在安全区

	self.select_area_effect = nil
	self.auto_type = 0

	self.touching_skill_id = 0						-- 触摸中的技能id
	self.touching_skill_id_valid = false			-- 触摸中的技能攻击是否有效

	self.last_move_req_time = 0						-- 最后一次移动请求的时间
	self.last_move_req_step = 0						-- 最后一次移动请求的步数
	self.last_atk_req_time = 0						-- 最后一次攻击请求的时间
	self.last_atk_req_server_back_time = 0			-- 服务器最后一次攻击请求返回的时间
	self.client_do_attack_time = 0					-- 客户端执行攻击的时间
	self.atk_req_wait_timer = nil					-- 攻击请求等待计时器
	self.sent_atk_func = BindTool.Bind(self.SentAttackReq, self)
	self.cur_atk_data = {
		skill_id = 0,
		target_obj_id = 0,
		x = 0,
		y = 0,
		dir = 0,
		perform_state = 0,
	}

	self.fly_shoe = nil
	self.auto_state_part = nil

	self.global_events = {}
	self:RegisterAllEvents()
end

function MainRole:__delete()
	self.vo = nil									-- 置空，防止被放入回收池
	for k, v in pairs(self.global_events) do
		GlobalEventSystem:UnBind(v)
	end
	self.global_events = {}

	if self.auto_state_part then
		self.auto_state_part:removeFromParent()
		self.auto_state_part = nil
		self.fly_shoe = nil
	end
end

function MainRole:RegisterAllEvents()
	self.global_events[OtherEventType.USER_TOUCH_SKILL_ICON] = GlobalEventSystem:Bind(OtherEventType.USER_TOUCH_SKILL_ICON, BindTool.Bind(self.OnUserTouchSkillCallBack, self))
	self.global_events[OtherEventType.GUAJI_TYPE_CHANGE] = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE, BindTool.Bind(self.OnGuajiTypeChange, self))
	self.global_events[OtherEventType.SETTING_GUAJI_TYPE_SHOW] = GlobalEventSystem:Bind(OtherEventType.SETTING_GUAJI_TYPE_SHOW, BindTool.Bind(self.OnSettingGuajiTypeShow, self))
end

function MainRole:CreateBoard()
	Role.CreateBoard(self)
	self:SetHpBoardVisible(true)
end

function MainRole:Update(now_time, elapse_time)
	Role.Update(self, now_time, elapse_time)

	if self.last_real_pos.x ~= self.real_pos.x or self.last_real_pos.y ~= self.real_pos.y then
		if math.abs(self.real_pos.x - self.view_cneter_pos.x) > 0 or 
			math.abs(self.real_pos.y - self.view_cneter_pos.y) > 0 then
			self.view_cneter_pos.x = self.view_cneter_pos.x + self.real_pos.x - self.last_real_pos.x
			self.view_cneter_pos.y = self.view_cneter_pos.y + self.real_pos.y - self.last_real_pos.y
			if not Story.Instance:GetIsStoring() then	-- 大剧情中摄像头不跟随玩家
				HandleGameMapHandler:setViewCenterPoint(self.view_cneter_pos.x, 
					self.view_cneter_pos.y + COMMON_CONSTS.SCENE_CAMERA_OFFSET_Y)
			end
		end

		self.last_real_pos.x = self.real_pos.x
		self.last_real_pos.y = self.real_pos.y
	end

	if self.last_logic_pos.x ~= self.logic_pos.x or self.last_logic_pos.y ~= self.logic_pos.y then
		self.last_logic_pos.x = self.logic_pos.x
		self.last_logic_pos.y = self.logic_pos.y
		GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_POS_CHANGE, self.logic_pos.x, self.logic_pos.y)
	end

	self:UpdateTouchingGuide()
end

function MainRole:CanClick()
	return false
end

-- 移动到某个点（寻路）
function MainRole:DoMoveByPos(logic_pos, range, end_func)
	if not self:CanDoMove() then
		return false
	end

	if logic_pos.x == self.server_pos_x and logic_pos.y == self.server_pos_y then
		return false
	end

	if self:GetActionCount() >= 2 then
		return false
	end

	local pos_count = HandleGameMapHandler:GetGameMap():findPath(cc.p(self.server_pos_x, self.server_pos_y), logic_pos, range or 0)
	if pos_count <= 1 then
		return false
	end

	self:ClearPathInfo()
	self:SetFollowObj(nil, 0)
	self.move_end_func = end_func

	for i = 1, pos_count - 1 do
		self.path_pos_list[i] = HandleGameMapHandler:GetGameMap():getFindPathPoint(i)
	end
	self.path_pos_index = 1

	if self:IsMove() or self:IsAtk() then
		return true
	end

	return self:DoMoveHelper(self.path_pos_list[1].x, self.path_pos_list[1].y)
end

-- 根据方向移动（点地面或者摇杆）
function MainRole:DoMoveByDir(dir, step, is_force)
	if self.auto_type ~= AutoType.None and (not is_force) then
		if nil == self.last_click_time or self.last_click_time + 5 < Status.NowTime then
			self.last_click_time = Status.NowTime
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CancelAutoFindWay)
			return false
		end
		self.last_click_time = nil
	end

	-- step = 1
	GuajiCtrl.Instance:NewSetOptState(true)   --	点击屏幕时为玩家操作
	self:SetAutoType(AutoType.None)
	self:ClearPathInfo()
	self:SetFollowObj(nil, 0)
	self.move_end_func = nil

	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	if MainuiCtrl
	and MainuiCtrl.Instance 
	and MainuiCtrl.Instance.GetView
	and MainuiCtrl.Instance:GetView()
	and MainuiCtrl.Instance:GetView().GetSmallPart
	and MainuiCtrl.Instance:GetView():GetSmallPart()
	and MainuiCtrl.Instance:GetView():GetSmallPart().OnStopAutoTask then
		MainuiCtrl.Instance:GetView():GetSmallPart():OnStopAutoTask() -- 移动停止自动做任务
	end

	if not self:CanDoMove() then
		return false
	end

	if self:GetActionCount() >= 2 then
		return false
	end
	
	MoveCache.task_id = 0
	GuajiCtrl.Instance:ClearAllOperate(ClearGuajiCacheReason.PlayerOptMove)

	local logic_x = self.server_pos_x + GameMath.DirOffset[dir].x * step
	local logic_y = self.server_pos_y + GameMath.DirOffset[dir].y * step

	if self:IsMove() or self:IsAtk() then
		self.path_pos_list[1] = cc.p(logic_x, logic_y)
		self.path_pos_index = 1
		return true
	end

	return self:DoMoveHelper(logic_x, logic_y, true)
end

function MainRole:DoMoveHelper(logic_x, logic_y)
	if logic_x == self.server_pos_x and logic_y == self.server_pos_y then
		return false
	end

	local dir = GameMath.GetDirectionNumber(logic_x - self.server_pos_x, logic_y - self.server_pos_y)

	local step = 1
	if math.abs(logic_x - self.server_pos_x) >= 2 or math.abs(logic_y - self.server_pos_y) >= 2 then
		step = 2
	end

	if GuajiCache.guaji_type == GuajiType.Auto then
		for k, v in pairs(self.parent_scene:GetSpecialObjList()) do
			if EntityType.Transfer == v.vo.entity_type then
				local w = math.abs(self.logic_pos.x + GameMath.DirOffset[dir].x * step - v.logic_pos.x) - 1
				local h = math.abs(self.logic_pos.y + GameMath.DirOffset[dir].y * step - v.logic_pos.y) - 1
				if w < math.abs(GameMath.DirOffset[dir].x) * 2 and
					h < math.abs(GameMath.DirOffset[dir].y) * 2 then
					return false
				end
			end
		end
	end

	local real_step = 0
	for i = 1, step do
		if GameMapHelper.IsBlock(self.server_pos_x + GameMath.DirOffset[dir].x * i,
			self.server_pos_y + GameMath.DirOffset[dir].y * i) then
			break
		end

		real_step = i
		logic_x = self.server_pos_x + GameMath.DirOffset[dir].x * i
		logic_y = self.server_pos_y + GameMath.DirOffset[dir].y * i
	end

	if real_step > 0 then
		if not self:IsAtk() then
			self:StopAction()
		end

		self:SetSpecialMoveSpeed(0)

		self:DoMove(logic_x, logic_y)

		local protocol = nil
		if real_step > 1 then
			protocol = ProtocolPool.Instance:GetProtocol(CSRunReq)
		else
			protocol = ProtocolPool.Instance:GetProtocol(CSMoveReq)
		end

		protocol.pos_x = self.server_pos_x
		protocol.pos_y = self.server_pos_y
		protocol.dir = dir
		protocol:EncodeAndSend()
		GlobalData.last_action_time = Status.NowTime
		self.last_move_req_time = Status.NowTime
		self.last_move_req_step = real_step

		self.server_pos_x, self.server_pos_y = logic_x, logic_y
		return true
	end

	-- 不可移动时改变方向
	if dir ~= self:GetDirNumber() and self:IsStand() then
		self:SetDirNumber(dir)
		self:RefreshAnimation()
	end

	return false
end

function MainRole:SetFollowObj(follow_obj, follow_range)
	self.follow_obj = follow_obj
	self.follow_objid = COMMON_CONSTS.INVALID_OBJID
	self.follow_range = follow_range or 0
	if nil ~= follow_obj then
		self.follow_objid = follow_obj:GetObjId()
		self.follow_x, self.follow_y = follow_obj:GetLogicPos()
	end
end

function MainRole:SetServerPos(pos_x, pos_y)
	self.server_pos_x, self.server_pos_y = pos_x, pos_y
end

function MainRole:GetServerPos(pos_x, pos_y)
	return self.server_pos_x, self.server_pos_y
end

function MainRole:StopMove()
	MoveCache.task_id = 0
	GuajiCtrl.Instance:ClearAllOperate()

	self:SetAutoType(AutoType.None)
	self:ClearPathInfo()
	self.move_end_func = nil
end

function MainRole:CanDoMove()
	if self:IsAtk() or self:IsRealDead() or self:IsDead() or self:HasBuffByGroup(BUFF_GROUP.PARALYSIS) then
		return false
	end

	return true
end

function MainRole:DoAttack(skill_id, ...)
	if not Role.DoAttack(self, skill_id, ...) then
		return false
	end
	return true
end

function MainRole:QuitStateAttack()
	Role.QuitStateAttack(self)
end

function MainRole:QuitStateWait()
	MainRole.super.QuitStateWait(self)
end

function MainRole:EnterStateAttack()
	MainRole.super.EnterStateAttack(self)
end

function MainRole:EnterStateMove()
	MainRole.super.EnterStateMove(self)
	self:UpdateAutoState()
end

function MainRole:EnterStateStand()
	MainRole.super.EnterStateStand(self)
	self:UpdateAutoState()
end

function MainRole:EnterStateDead()
	Role.EnterStateDead(self)
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_DEAD, self)
end

function MainRole:UpdateModelColor()
	local color_value = self.vo[OBJ_ATTR.CREATURE_COLOR]
	self:SetModelColor(color_value)
end

function MainRole:SetModelColor(color_value)
	if Story.Instance:GetIsStoring() then
		return
	end
	Role.SetModelColor(self, color_value)
end

-- 主角每移动满一格，移动是否要结束
function MainRole:MoveEnd()
	self:UpdateAutoState()

	if not self:CanDoMove() then
		return true
	end

	local need_stop_move = GuajiCtrl.Instance:CheckAnyThingToDo()
	if need_stop_move then
		return true
	end

	-- 继续移动
	local logic_pos = self.path_pos_list[self.path_pos_index]
	if nil ~= logic_pos and self.path_pos_index <= #self.path_pos_list then
		if self.server_pos_x == logic_pos.x and self.server_pos_y == logic_pos.y then
			self.path_pos_index = self.path_pos_index + 1
			logic_pos = self.path_pos_list[self.path_pos_index]
		end
	end
	if nil ~= logic_pos and self:DoMoveHelper(logic_pos.x, logic_pos.y) then
		return false
	end

	return true
end

function MainRole:QuitStateMove()
	Role.QuitStateMove(self)

	self:OnQuitMove()
end

function MainRole:OnQuitMove()
	if self.move_end_func then
		local end_func = self.move_end_func
		self.move_end_func = nil
		end_func()
	end

	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_MOVE_END)

	self:UpdateAutoState()
end

function MainRole:GetPathPosList()
	return self.path_pos_list
end

function MainRole:GetPathPosIndex()
	return self.path_pos_index
end

function MainRole:IsMainRole()
	return true
end

function MainRole:SetIsGatherState(value)
	self.is_gather_state = value
end

function MainRole:GetIsGatherState()
	return self.is_gather_state
end

function MainRole:ClearPathInfo()
	self.path_pos_list = {}
	self.path_pos_index = 0
end

function MainRole:ReAlive()
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_REALIVE, self)
end

function MainRole:AddEffect(effect_id, effect_type, remain_time)
	if Story.Instance:GetIsStoring() then
		return
	end
	Role.AddEffect(self, effect_id, effect_type, remain_time)

	if (effect_type == EffectType.FootContinue or effect_type == EffectType.Continue) and remain_time > 0 then
		self.vo.effect_list = self.vo.effect_list or {}
		table.insert(self.vo.effect_list, {effect_id=effect_id, effect_type=effect_type, remain_time=remain_time})
	end
end

function MainRole:RemoveEffect(effect_id, effect_type)
	Role.RemoveEffect(self, effect_id, effect_type)
	if nil ~= self.vo.effect_list then
		if effect_type == EffectType.FootContinue or effect_type == EffectType.Continue then
			for k, v in pairs(self.vo.effect_list) do
				if v.effect_id == effect_id and v.effect_type == effect_type then
					table.remove(self.vo.effect_list, k)
					break
				end
			end
		end
	end
end

function MainRole:PlaySelectAreaEffect(path)
	if nil == self.select_area_effect then
		self.select_area_effect = XImage:create()
		self:GetModel():AttachNode(self.select_area_effect, nil, GRQ_SHADOW, InnerLayerType.Shadow)
	end

	self.select_area_effect:loadTexture(path, false)
	self.select_area_effect:setVisible(true)
	self.select_area_effect:setOpacity(128)

	self.select_area_effect:stopAllActions()
	local action = cc.Sequence:create(cc.FadeIn:create(0.3), cc.FadeOut:create(0.7), cc.CallFunc:create(function()
		self.select_area_effect:setVisible(false)
	end))
	self.select_area_effect:runAction(action)
end

-----------------------------------------------------------------------------------------------
-- 挂机状态显示
function MainRole:SetAutoType(auto_type)
	if self.auto_type == auto_type then
		return
	end
	self.auto_type = auto_type

	if self.auto_type == AutoType.None then
		self:StopAutoFindPathEffect()
	elseif self.auto_type == AutoType.FindPath then
		self:PlayAutoFindPathEffect()
	elseif self.auto_type == AutoType.Guaji then
		self:PlayAutoGuajiEffect()
	end
end

-- 请求任务传送
function MainRole:SendTaskTransmitReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTaskTransmitReq)
	protocol.task_id = MoveCache.task_id
	protocol:EncodeAndSend()
end

-- 播放自动战斗/寻路特效
function MainRole:PlayAutoEffect(eff_path)
	if nil == self.auto_state_part then
		local ui_size = HandleRenderUnit:GetSize()
		self.auto_state_part = XUI.CreateLayout(ui_size.width / 2, ui_size.height / 2 - 120, 0, 0)
		HandleRenderUnit:AddUi(self.auto_state_part, -3)

		local auto_eff = AnimateSprite:create()
		auto_eff:setScale(1.2)
		self.auto_state_part:addChild(auto_eff, 1)
		self.auto_state_part.auto_eff = auto_eff
		self.auto_state_part.auto_eff_path = ""
	end

	if eff_path == nil then
		self.auto_state_part.auto_eff_path = ""
		self.auto_state_part.auto_eff:setStop()

	elseif self.auto_state_part.auto_eff_path ~= eff_path then
		self.auto_state_part.auto_eff_path = eff_path
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_path)
		self.auto_state_part.auto_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	end
end

-- 播放寻路特效
function MainRole:PlayAutoFindPathEffect()
	self:PlayAutoEffect(ResPath.AutoFindPath)

	-- 任务移动可以免费传送
	-- Scene.SendQuicklyTransportReqByNpcId(npc_id)
	-- task_id = 999 为支线任务
	local can_fly = MoveCache.task_id > 0
	if nil == self.fly_shoe and can_fly then
		local w, h = 160, 160
		self.fly_shoe = XUI.CreateLayout(120, -40, w, h)
		local path, name = ResPath.GetEffectUiAnimPath(1004)
		local fly_shoe_effect = AnimateSprite:create()
		fly_shoe_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
		fly_shoe_effect:setPosition(w / 2 + 35, h / 2 + 38)
		fly_shoe_effect:setScaleX(1.2)
		fly_shoe_effect:setScaleY(1.2)
		self.fly_shoe:addChild(fly_shoe_effect)
		local txet_desc = XUI.CreateText(w / 2 + 35, h / 2 - 10, 100, 23, nil, Language.Common.FreeFly, nil, 20, COLOR3B.GREEN)
		txet_desc:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		self.fly_shoe:addChild(txet_desc)
		self.auto_state_part:addChild(self.fly_shoe, 10)

		-- XUI.AddClickEventListener(self.fly_shoe, BindTool.Bind(self.SendTaskTransmitReq, self), true)
		XUI.AddClickEventListener(self.fly_shoe, function ()
			if MoveCache.task_id == 999 and MoveCache.param1 > 0 then
				Scene.SendQuicklyTransportReqByNpcId(MoveCache.param1)
			else
				self:SendTaskTransmitReq()
			end
		end, true)
	else
		if nil ~= self.fly_shoe then
			self.fly_shoe:setVisible(can_fly)
		end
	end
end

-- 停止所有寻跑特效显示
function MainRole:StopAutoFindPathEffect()
	if nil ~= self.fly_shoe then
		self.fly_shoe:setVisible(false)
	end
	self:PlayAutoEffect()
end

-- 自动战斗特效显示
function MainRole:PlayAutoGuajiEffect()
	if nil ~= self.fly_shoe then
		self.fly_shoe:setVisible(false)
	end
	self:PlayAutoEffect(ResPath.AutoGuaji)
end

-- 更新当前的自动XX状态
function MainRole:UpdateAutoState()
	if GuajiCache.guaji_type == GuajiType.Auto then
		self:SetAutoType(AutoType.Guaji)
	elseif MoveCache.is_valid and ShowFindPathEffMoveEndType[MoveCache.end_type] then
		self:SetAutoType(AutoType.FindPath)
	else
		self:SetAutoType(AutoType.None)
	end
end

function MainRole:OnGuajiTypeChange()
	self:UpdateAutoState()
end

function MainRole:OnSettingGuajiTypeShow(vis)
	local auto_eff = self.auto_state_part and self.auto_state_part.auto_eff
	if auto_eff then
		auto_eff:setVisible(vis)
	end
end

-----------------------------------------------------------------------------------------------

function MainRole:SetNameValue(index, value)
	if index == "name_color"
		or index == "name"
		or index == "guild_name" then
		RoleData.Instance:SetAttr(index, value)
	else
		Role.SetNameValue(self, index, value)
	end
end

function MainRole:SetLogicPos(posx, posy)
	AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.Transmit))
	self.server_pos_x, self.server_pos_y = posx, posy
	Role.SetLogicPos(self, posx, posy)
end

function MainRole:SetDirNumber(...)
	MainRole.super.SetDirNumber(self, ...)
	if self.touching_skill_id > 0 then
		self:SetTouchingGuideEff()
	end
end

function MainRole:OnUserTouchSkillCallBack(touch_type, skill_id)
	if nil == touch_type or nil == skill_id then
		return
	end

	if touch_type == 1 then
		-- 主角技能触摸中
		if SKILL_GUIDE_EFFID[skill_id] then
			self.touching_skill_id_valid = false
			self:SetTouchingGuideSkillId(skill_id)
		end
	else
		-- 主角技能松开
		self:SetTouchingGuideSkillId()
	end
end

function MainRole:SetTouchingGuideSkillId(skill_id)
	skill_id = skill_id or 0
	if self.touching_skill_id ~= skill_id then
		self.touching_skill_id = skill_id
		self:SetTouchingGuideEff()
	end
end

function MainRole:SetTouchingGuideSkillValid(valid)
	valid = valid or false
	if self.touching_skill_id_valid ~= valid then
		self.touching_skill_id_valid = valid
		self:SetTouchingGuideEff()
	end
end

-- 更新技能指引
local change_color_obj_id_list = {}	-- 变色对象id表，用于恢复颜色
function MainRole:UpdateTouchingGuide()
	if self.touching_skill_id > 0 then
		local scene_logic = self.parent_scene:GetSceneLogic()
		if self.touching_skill_id == 5 then
			local is_atk_valid = false
			local obj_id
			for k, obj in pairs(self.parent_scene:GetRoleList()) do
				obj_id = obj:GetObjId()
				if scene_logic:IsEnemy(obj, self) and self:CheckObjIsInSkillArea(obj, self.touching_skill_id) then
					-- 可击中目标变红
					obj:SetModelColor(0xff0000)
					change_color_obj_id_list[obj_id] = 1
					is_atk_valid = true
				elseif change_color_obj_id_list[obj_id] then
					-- 恢复颜色
					obj:SetModelColor(obj.vo[OBJ_ATTR.CREATURE_COLOR])
				end
			end

			self:SetTouchingGuideSkillValid(is_atk_valid)
		end
	else
		-- 恢复颜色
		for obj_id, _ in pairs(change_color_obj_id_list) do
			change_color_obj_id_list[obj_id] = nil
			local obj = self.parent_scene:GetObjectByObjId(obj_id)
			if obj then
				obj:SetModelColor(obj.vo[OBJ_ATTR.CREATURE_COLOR])
			end
		end
	end
end

-- 检查对象是否在主角技能的攻击范围
function MainRole:CheckObjIsInSkillArea(obj, skill_id)
	local is_atk_valid = false
	if skill_id == 5 then -- 写死野蛮范围正前方4格范围判断
		local obj_x, obj_y = obj:GetLogicPos()
		local p_x, p_y = self:GetLogicPos()
		local dir_num = self:GetDirNumber()
		local dir_offset = GameMath.DirOffset[dir_num]
		local skill_areas = {
			{p_x + dir_offset.x, p_y + dir_offset.y},
			{p_x + dir_offset.x * 2, p_y + dir_offset.y * 2},
			{p_x + dir_offset.x * 3, p_y + dir_offset.y * 3},
			{p_x + dir_offset.x * 4, p_y + dir_offset.y * 4},
		}
		for k, v in pairs(skill_areas) do
			if v[1] == obj_x and v[2] == obj_y then
				is_atk_valid = true
				break
			end
		end
	end
	return is_atk_valid
end

SKILL_GUIDE_EFFID = {
	-- 技能id = { [1] = 技能攻击无效effid, [2] = 技能攻击有效effid}
	[5] = {[1] = 30010, [2] = 30020},
}
-- 技能指引特效
function MainRole:SetTouchingGuideEff()
	local eff_t = SKILL_GUIDE_EFFID[self.touching_skill_id]
	if eff_t then
		local effect_id = self.touching_skill_id_valid and eff_t[2] or eff_t[1]
		if nil == self.skill_guide_animate_sprite then
			self.skill_guide_animate_sprite = AnimateSprite:create()
			self.model:AttachNode(self.skill_guide_animate_sprite, nil, GRQ_SCENE_OBJ, InnerLayerType.Shadow)
		end

		if effect_id >= ResPath.DirEffectBegin then
			local dir_num, is_flip_x = self:GetResDirNumAndFlipFlag()
			local anim_path, anim_name = ResPath.GetEffectAnimPath(effect_id + dir_num)
			self.skill_guide_animate_sprite:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk, is_flip_x)
		else
			local anim_path, anim_name = ResPath.GetEffectAnimPath(effect_id)
			self.skill_guide_animate_sprite:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk, false)
		end
		-- self.skill_guide_animate_sprite:setVisible(true)
	else
		self.skill_guide_animate_sprite:setStop()
		-- self.skill_guide_animate_sprite:setVisible(false)
	end
end

----------------------------------------------------
-- 主角执行技能 start
----------------------------------------------------
-- 主角执行技能
function MainRole:PerformSkill(skill_id, target_obj_id, x, y, dir, range)

	if not self:CanDoAtk(skill_id) or (skill_id > 0 and not SkillData.Instance:CanUseSkill(skill_id)) then
		return false
	end

	--攻击速度判断
	if not self:IsCanNextAtk(skill_id) then
		return false
	end

	local now_time = Status.NowTime
	local skill_info = SkillData.Instance:GetSkill(skill_id)
	local skill_level = 0
	if nil ~= skill_info then
		skill_id = skill_info.skill_id
		skill_level = skill_info.skill_level
	end
	
	if dir then
		self:SetDirNumber(dir)
	end
	-- 客户端直接播放攻击

	self:DoAttack(skill_id, skill_level, 0)
	local obj = Scene.Instance:GetObjectByObjId(target_obj_id)
	local obj_vo = obj and obj:GetVo()
	if IS_ON_CROSSSERVER and obj and obj.obj_type == SceneObjType.Monster and obj_vo and obj_vo.monster_type == MONSTER_TYPE.BOSS then
		local rest_cnt = CrossServerData.GetCrossBossRestCntBySceneId(Scene.Instance:GetSceneId())
		-- print("rest_cnt:", rest_cnt)
		if rest_cnt <= 0 then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.CannotAtkBoss)
		end
	end
	self.cur_atk_data.skill_id = skill_id
	self.cur_atk_data.target_obj_id = target_obj_id
	self.cur_atk_data.dir = dir
	self.cur_atk_data.x = x or 0
	self.cur_atk_data.y = y or 0
	self.cur_atk_data.perform_state = 1

	-- 等一等,别急
	local wait_to_sent_atk_time = 0.04
	GlobalTimerQuest:CancelQuest(self.atk_req_wait_timer)
	self.atk_req_wait_timer = GlobalTimerQuest:AddDelayTimer(self.sent_atk_func, wait_to_sent_atk_time)
	
	self.client_do_attack_time = now_time
	GlobalData.last_action_time = Status.NowTime

	return true
end

function MainRole:SentAttackReq()
	self.atk_req_wait_timer = nil
	self.last_atk_req_time = Status.NowTime
	self.cur_atk_data.perform_state = 2
	if self.cur_atk_data.skill_id > 0 then
		FightCtrl.SendPerformSkillReq(self.cur_atk_data.skill_id, self.cur_atk_data.target_obj_id, self.cur_atk_data.x, self.cur_atk_data.y, self.cur_atk_data.dir)
	else
		FightCtrl.SendNearAttackReq(self.cur_atk_data.target_obj_id)
	end

	-- 分身术 攻击时自动使用
	local fenshen = SkillData.Instance:GetSkill(121)
	if fenshen then
		local fenshen_cd = SkillData.Instance:GetSkillCD(121)
		if  fenshen_cd <= Status.NowTime then
			FightCtrl.SendPerformSkillReq(121, self.cur_atk_data.target_obj_id, self.cur_atk_data.x, self.cur_atk_data.y, self.cur_atk_data.dir)
		end
	end
end

-- 服务器响应技能返回
function MainRole:ServerOnMainRolePerformSkill(protocol)
	local now_time = Status.NowTime
	self.last_atk_req_server_back_time = now_time
	local skill_id = protocol.skill_id or 0
	if self.cur_atk_data.skill_id == skill_id then
		self.cur_atk_data.perform_state = 3
	end

	-- 必杀技
	if IsInTable(skill_id, SPECIAL_SKILL_LIST) then
		local ui_size = HandleRenderUnit:GetSize()

		local act_node = cc.Node:create()
		act_node:setPosition(ui_size.width / 2, 580)
		HandleRenderUnit:GetUiNode():addChild(act_node, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)

		act_node:setScale(3)
		local sprite = RenderUnit.CreateEffect(305, act_node, nil, nil, 1)
		sprite:setOpacity(0)
		sprite:runAction(cc.FadeIn:create(0.7))
		local show_in_time = 0.5
		local shake_func = cc.CallFunc:create(function()
			Story.Instance:ActShake(8)
		end)
		local clean_func = cc.CallFunc:create(function()
			NodeCleaner.Instance:AddNode(act_node)
		end)
		local fadeout_func = cc.CallFunc:create(function()
			sprite:stopAllActions()
			sprite:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), clean_func))
		end)
		local show_in_act = cc.EaseExponentialIn:create(cc.ScaleTo:create(show_in_time, 1))
		local sequence = cc.Sequence:create(show_in_act, shake_func, cc.DelayTime:create(0.5), fadeout_func)
		act_node:runAction(sequence)
	end

	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_USE_SKILL, protocol.skill_id or 0)
end

-- 是否可以发动攻击
function MainRole:CanDoAtk(skill_id)
	return self:IsAtkEnd() and (not self:HasBuffByGroup(BUFF_GROUP.PARALYSIS) or SkillData.GetSkillCfg(skill_id).dizzyUse)
end

-- 判断攻击速度限制
function MainRole:IsCanNextAtk()
	return Status.NowTime >= self.last_atk_req_time + self:GetAttr(OBJ_ATTR.CREATURE_ATTACK_SPEED) / 1000
end

-- 攻击是否结束
function MainRole:IsAtkEnd()
	for k, v in pairs(self.action_list) do
		if v[1] == SceneObjState.Atk then
			return false
		end
	end

	return not self:IsAtk()
end
----------------------------------------------------
-- 主角执行技能 end
----------------------------------------------------
