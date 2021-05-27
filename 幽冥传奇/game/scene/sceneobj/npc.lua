require("scripts/game/scene/sceneobj/npc_human_cfg")
Npc = Npc or BaseClass(SceneObj)

local NPC_TAG_OFFY = 25

function Npc:__init(vo)
	self.obj_type = SceneObjType.Npc
	self.role_res_id = 0
	self.wuqi_res_id = 0
	self.chibang_res_id = 0
	self.douli_res_id = 0
	self.sex = 0
	self.delay_per_unit = 0.1
	self.loops = COMMON_CONSTS.MAX_LOOPS
	self.is_pause_last_frame = false
	self.action_name = SceneObjState.Stand
	self.action_begin_time = Status.NowTime

	self.is_humanoid = false
	self.vo.dir = self.vo.dir or 0
	self.vo[OBJ_ATTR.ACTOR_PROF] = self.vo[OBJ_ATTR.ACTOR_PROF] or GameEnum.ROLE_PROF_1
	self.can_click = true

	self.title_layer = nil
	self:CreateTitle()
	self:CreateShadow()
	self:CreateTagImg()
end

function Npc:__delete()
	if nil ~= self.title_layer then
		self.title_layer:DeleteMe()
		self.title_layer = nil
	end
	self.tag_img = nil
end

function Npc:GetVo()
	return self.vo
end

function Npc:CreateTitle()
	self.title_layer = RoleTitleBoard.New()
	self:GetModel():AttachNode(self.title_layer:GetRootNode(), cc.p(0, 0), GRQ_SCENE_OBJ, InnerLayerType.Title)
end

function Npc:UpdateTitle()
	if nil == self.title_layer then return end
	self.title_layer:CreateTitleEffect(self.vo)
	self.title_layer:SetTitleListOffsetY(self:GetFixedHeight())
end

function SceneObj:CanClick()
	return self.can_click
end

function Npc:UpdateVis()
	self:GetModel():SetVisible(self.can_click)
	self:SetShadowVisible(self.can_click)
	self:SetNameBoardVis(self.can_click)
end

function Npc:UpdateResId()
	local model_scale = 1.3
	if self.vo.npc_id == NPC_ID.MINGREN1 or self.vo.npc_id == NPC_ID.MINGREN2 or self.vo.npc_id == NPC_ID.MINGREN3 then
		local statue_info = CrossServerData.Instance:GetStatueInfoByNpcId(self.vo.npc_id)
		model_scale = 2
		if statue_info then
			for k, v in pairs(statue_info) do
				self.vo[k] = v
			end

			self.name = self.vo.name
			if self.name_board ~= nil then
				self.name_board:SetName(self.name)
			end

			self.is_humanoid = true
			self:SetScale(2.0, true)
			self.can_click = true
		else
			self.can_click = false
		end
	end

	self.role_res_id = self.vo[OBJ_ATTR.ENTITY_MODEL_ID] or 0
	self.wuqi_res_id = self.vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] or 0
	self.chibang_res_id = self.vo[OBJ_ATTR.ACTOR_WING_APPEARANCE] or 0
	self.sex = self.vo[OBJ_ATTR.ACTOR_SEX] or 0
	self.douli_res_id = bit:_rshift(self.vo[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] or 0, 16)
	self:SetScale(model_scale, false)

	if NPC_Human_List[self.vo.npc_id] then
		local cfg = NPC_Human_List[self.vo.npc_id]
		self.role_res_id = cfg.res_id
		self.wuqi_res_id = cfg.wuqi_res_id
		self.chibang_res_id = cfg.chibang_res_id
		self.douli_res_id = cfg.douli_res_id
		self.sex = cfg.sex
		self.vo.dir = cfg.dir_num
		self.vo[OBJ_ATTR.ACTOR_PROF] = cfg.prof or GameEnum.ROLE_PROF_1
		self.is_humanoid = true
	end
end

function Npc:LoadInfoFromVo()
	SceneObj.LoadInfoFromVo(self)
	self:UpdateAllShow()
end

function Npc:UpdateAllShow()
	self:UpdateResId()
	self:UpdateTitle()
	self:UpdateAnimation()
	self:UpdateVis()
end

function Npc:UpdateAnimation()
	if not self:IsHumanoid() then
		local anim_path, anim_name = ResPath.GetNpcAnimPath(self.role_res_id, SceneObjState.Stand, 2) -- GameMath.DirDown
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, false, FrameTime.Stand)
	else
		local dir_num, is_flip_x = GameMath.GetResDirNumAndFlipFlag(self.vo.dir)

		-- 主体
		local anim_path, anim_name = "", ""
		if 0 ~= self.role_res_id then
			anim_path, anim_name = ResPath.GetRoleAnimPath(self.role_res_id, self.action_name, self.action_name == SceneObjState.Dead
		and GameMath.DirUp or self.vo.dir)
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, 
				false, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, nil, nil, nil, nil, self.action_begin_time)
		end

		-- 武器
		local layer = InnerLayerType.WuqiDown
		if RoleWuqiLayer[self.vo[OBJ_ATTR.ACTOR_PROF]]
			and RoleWuqiLayer[self.vo[OBJ_ATTR.ACTOR_PROF]][self.action_name]
			and RoleWuqiLayer[self.vo[OBJ_ATTR.ACTOR_PROF]][self.action_name][self.vo.dir] then
			layer = InnerLayerType.WuqiUp
		end

		if 0 ~= self.wuqi_res_id then
			if nil ~= self.last_wuqi_layer and self.last_wuqi_layer ~= layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_wuqi_layer, "", "")
			end
			anim_path, anim_name = ResPath.GetWuqiAnimPath(self.wuqi_res_id, self.action_name, self.action_name == SceneObjState.Dead
		and GameMath.DirUp or self.vo.dir)
			self.last_wuqi_layer = layer
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
				false, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, nil, nil, 1, nil, self.action_begin_time)
		else
			if nil ~= self.last_wuqi_layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_wuqi_layer, "", "")
				self.last_wuqi_layer = nil
			end
		end

		-- 翅膀
		layer = InnerLayerType.ChibangUp
		if dir_num == GameMath.DirDown or dir_num == GameMath.DirDownRight or dir_num == GameMath.DirDownLeft then
			layer = InnerLayerType.ChibangDown
		end
		if 0 ~= self.chibang_res_id and not self.is_pingbi_chibang then
			if nil ~= self.last_chibang_layer and self.last_chibang_layer ~= layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, "", "")
			end
			anim_path, anim_name = ResPath.GetChibangAnimPath(self.chibang_res_id, self.action_name, self.action_name == SceneObjState.Dead
		and GameMath.DirUp or self.vo.dir)
			self.last_chibang_layer = layer
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
				false, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, 0, -20, 1.5, nil, self.action_begin_time)
		else
			if nil ~= self.last_chibang_layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, "", "")
				self.last_chibang_layer = nil
			end
		end

		-- 斗笠  特殊处理偏移的位置
		if 0 ~= self.douli_res_id and not self.is_pingbi_douli then
			anim_path, anim_name = ResPath.GetDouLiAnimPath(self.douli_res_id + self.sex, self.action_name, dir_num)
			self.last_douli_layer = InnerLayerType.DouLi
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.DouLi, anim_path, anim_name, 
				is_flip_x, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, 0, 17, nil, nil, self.action_begin_time)
		else
			if nil ~= self.last_douli_layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_douli_layer, "", "")
				self.last_douli_layer = nil
			end
		end
	end

	self:FlushTaskState()
end

function Npc:IsHumanoid()
	return self.is_humanoid
end

function Npc:GetFixedHeight()
	return self.fixed_height * (1 + self:GetModel():GetScale() - 1.3)
end

-- function Npc:CreateBoard()
-- 	SceneObj.CreateBoard(self)
-- 	self:CreateTagImg()
-- end

function Npc:SetNameBoardVis(vis)
	if nil ~= self.name_board then
		self.name_board:SetVisible(vis)
	end
end

function Npc:SetHeight(height)
	if 0 >= self.vo.npc_type and nil == self.name_board and nil ~= self.name and "" ~= self.name then
		local name_board = NameBoard.New()
		name_board:SetName(self.name, COLOR3B.GREEN)
		self:SetNameBoard(name_board)
	end

	SceneObj.SetHeight(self, height)
	if self.tag_img then
		self.tag_img:setPositionY(self:GetNameBoardPosY() + NPC_TAG_OFFY)
		self.tag_img:setVisible(false)
		if self.vo.npc_type > 0 then
			self.tag_img:loadTexture(ResPath.GetScene("npc_name_" .. self.vo.npc_type))
			self.tag_img:setVisible(true)
		end
	end

	if self.vo.task_state ~= 0 then
		self:FlushTaskState()
	end
end

function Npc:OnClick()
	local anim_path, anim_name = ResPath.GetEffectAnimPath(ResPath.SelectBlue)
	self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Select, anim_path, anim_name)
end

-- 设置任务状态
function Npc:FlushTaskState()
	local anim_path, anim_name = "", ""
	if self.vo.task_state == GameEnum.TASK_STATUS_CAN_ACCEPT then
		anim_path, anim_name = ResPath.GetEffectAnimPath(ResPath.ScrollOff)
	elseif self.vo.task_state == GameEnum.TASK_STATUS_COMMIT then
		anim_path, anim_name = ResPath.GetEffectAnimPath(ResPath.ScrollOn)
	elseif self.vo.task_state == GameEnum.TASK_STATUS_ACCEPT_PROCESS then
		anim_path, anim_name = ResPath.GetEffectAnimPath(ResPath.ScrollGray)
	end
	local npc_tag_shift_y = (self.tag_img and self.tag_img:isVisible() and NPC_TAG_OFFY) or 0
	self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.TaskMark, anim_path, anim_name, false, 
		nil, nil, nil, nil, 0, self.height + npc_tag_shift_y + 75)
end

function Npc:SetTaskState(task_state)
	self.vo.task_state = task_state
	self:FlushTaskState()
end

function Npc:GetNpcId()
	return self.vo.npc_id
end

-- 特殊npc标签
function Npc:CreateTagImg()
	if self.tag_img then return end
	self.tag_img = XUI.CreateImageView(0, 0, "", false)
	self.model:AttachNode(self.tag_img, cc.p(0, self:GetNameBoardPosY() + NPC_TAG_OFFY), GRQ_SCENE_OBJ, InnerLayerType.Name)
	XUI.AddClickEventListener(self.tag_img, function()
		GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, self, "scene")
	end, true)
	self.tag_img:setVisible(false)
end

function Npc:GetNameBoardPosY()
	return (self.name_board and self.name_board:GetRootNode() and self.name_board:GetRootNode():getPositionY()) or self.model:GetHeight()
end
