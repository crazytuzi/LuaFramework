EffectObj = EffectObj or BaseClass(SceneObj)

EffectType = {
	None = 0,
	Spray = 1,				-- 挥洒
	Throw = 2,				-- 投掷
	Fly = 3,				-- 飞行
	Explode = 4,			-- 爆炸
	FootContinue = 5,		-- 脚下持续
	Continue = 6,			-- 持续
	leftTopFloatTxt = 7,	-- 左上浮动文字
}

function EffectObj:__init(vo)
	self.obj_type = SceneObjType.EffectObj

	self.real_effect_id = 0
	self.is_flip_x = false

	self.move_param = nil
	self.end_time = 0
	self.loops = COMMON_CONSTS.MAX_LOOPS
end

function EffectObj:__delete()

end

function EffectObj:CanClick()
	return false
end

function EffectObj:LoadInfoFromVo()
	self.real_effect_id = self.vo.effect_id
	local scene_obj = Scene.Instance:GetObjectByObjId(self.vo.deliverer_obj_id)
	if nil ~= scene_obj then
		if self.vo.effect_id >= ResPath.DirEffectBegin and scene_obj:IsCharacter() then
			local dir_num = 0
			dir_num, self.is_flip_x = scene_obj:GetResDirNumAndFlipFlag()
			self.real_effect_id = self.vo.effect_id + dir_num
		end

		if self.vo.effect_type == EffectType.Throw or self.vo.effect_type == EffectType.Fly then
			self.vo.pos_x, self.vo.pos_y = scene_obj:GetLogicPos()

		elseif self.vo.effect_type == EffectType.FootContinue or self.vo.effect_type == EffectType.Continue then
			self.end_time = self.vo.remain_time / 1000 + Status.NowTime

		else
			self.loops = 1
		end
	else
		if self.vo.remain_time > 0 then
			self.end_time = self.vo.remain_time / 1000 + Status.NowTime
		else
			-- 没有结束时间默认只播一次
			self.loops = 1
		end
	end

	SceneObj.LoadInfoFromVo(self)

	if self.vo.effect_type == EffectType.Fly then 	--飞行技能初始位置靠上
		self.real_pos.y = self.real_pos.y + 60
		self:UpdateModelPos()
	end

	if self.vo.effect_type == EffectType.Throw
		or self.vo.effect_type == EffectType.Fly then
		self:CalcMoveParam()
	end
end

function EffectObj:InitAnimation()
	local anim_path, anim_name = ResPath.GetEffectAnimPath(self.real_effect_id)
	self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, 
		self.is_flip_x, FrameTime.Effect, nil, self.loops, false, nil, nil, nil, nil, self.action_begin_time)
end

function EffectObj:Update(now_time, elapse_time)
	if self.end_time > 0 then
		if now_time >= self.end_time then
			self.parent_scene:DeleteObj(self.vo.obj_id)
			return
		end
	else
		self:MoveUpdate(now_time, elapse_time)
	end
end

function EffectObj:OnMainAnimateStop()
	self.end_time = Status.NowTime
end

function EffectObj:CalcMoveParam()
	self.move_param = self.move_param or {}
	self.move_param.last_calc_time = Status.NowTime

	self.move_param.target_real_pos = HandleRenderUnit:LogicToWorld(cc.p(self.vo.target_pos_x, self.vo.target_pos_y))
	if self.vo.effect_type == EffectType.Fly then
		self.move_param.target_real_pos.y = self.move_param.target_real_pos.y + 40 --飞行技能初始位置靠上
	end

	local delta_pos = cc.pSub(self.move_param.target_real_pos, self.real_pos)

	local rotation = -math.deg(cc.pToAngleSelf(delta_pos))
	self.model:SetRotation(rotation + 90)

	self.move_param.move_dir = cc.pNormalize(delta_pos)
	self.move_param.total_distance = cc.pGetLength(delta_pos)
	self.move_param.pass_distance = 0
	if self.vo.remain_time <= 0 then
		self.move_param.move_speed = 1000
	else
		self.move_param.move_speed = self.move_param.total_distance / (self.vo.remain_time / 1000)
	end
end

function EffectObj:MoveUpdate(now_time, elapse_time)
	if nil ~= self.move_param then
		if nil == self.move_param.move_speed then
			self.parent_scene:DeleteObj(self.obj_id)
			return
		end

		local distance = elapse_time * self.move_param.move_speed
		self.move_param.pass_distance = self.move_param.pass_distance + distance

		if self.move_param.pass_distance >= self.move_param.total_distance then
			self:SetRealPos(self.move_param.target_real_pos.x, self.move_param.target_real_pos.y)
			self.move_param = nil
			self.parent_scene:DeleteObj(self.vo.obj_id)
		else
			local dir_distance = cc.pMul(self.move_param.move_dir, distance)
			local now_pos = cc.pAdd(self.real_pos, dir_distance)

			self:SetRealPos(now_pos.x, now_pos.y)
		end
	end
end
