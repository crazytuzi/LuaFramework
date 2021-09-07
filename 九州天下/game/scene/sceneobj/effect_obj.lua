
EffectObj = EffectObj or BaseClass(SceneObj)

function EffectObj:__init()
	self.obj_type = SceneObjType.EffectObj
	self.draw_obj:SetObjType(self.obj_type)
	self.effect_root = nil
	self.parent_obj = nil
end

function EffectObj:__delete()
	if self.effect_root then
		GameObjectPool.Instance:Free(self.effect_root)
		self.effect_root = nil
	end
	self.parent_obj = nil
	self.line_renderer = nil
end

function EffectObj:IsEffect()
	return true
end

function EffectObj:InitShow()
	SceneObj.InitShow(self)
	
	if PRODUCT_METHOD.SKILL_READDING == self.vo.product_method then
		self:CreateFazhen()
	else
		self:CreateEffect()
	end
end

function EffectObj:GetLineRenderer()
	if self.line_renderer == nil and self.effect_root then
		self.line_renderer = self.effect_root:GetComponent(typeof(UnityEngine.LineRenderer))
	end
	return self.line_renderer
end

function EffectObj:CreateFazhen()
	local skill_cfg = SkillData.GetMonsterSkillConfig(self.vo.product_id)
	if nil == skill_cfg then
		return
	end

	local effect = ""
	local size = nil
	local angle_y = 0

	if AOE_RANGE_TYPE.SELF_CENTERED_CIRCLE == skill_cfg.RangeType then
		effect = "fazhen_circle"
		size = Vector2(skill_cfg.Range * 1.2, skill_cfg.Range * 1.2)
		self:SetLogicPos(self.vo.src_pos_x, self.vo.src_pos_y)

	elseif AOE_RANGE_TYPE.TARGET_CENTERED_CIRCLE == skill_cfg.RangeType then
		effect = "fazhen_circle"
		size = Vector2(skill_cfg.Range * 1.2, skill_cfg.Range * 1.2)

	elseif AOE_RANGE_TYPE.SELF_BEGINNING_RECT == skill_cfg.RangeType then
		effect = "fazhen_rect"
		size = Vector2(skill_cfg.Range, skill_cfg.Range2)
		angle_y = 90 - ((u3d.v2Angle(Vector2(self.vo.pos_x, self.vo.pos_y) - Vector2(self.vo.src_pos_x, self.vo.src_pos_y))) * 180 / math.pi)

		self:SetLogicPos(self.vo.src_pos_x, self.vo.src_pos_y)

	elseif AOE_RANGE_TYPE.SELF_BEGINNING_SECTOR == skill_cfg.RangeType then
		effect = "fazhen_fanshap1"
		angle_y = 90 - ((u3d.v2Angle(Vector2(self.vo.pos_x, self.vo.pos_y) - Vector2(self.vo.src_pos_x, self.vo.src_pos_y))) * 180 / math.pi)

		self:SetLogicPos(self.vo.src_pos_x, self.vo.src_pos_y)
	end

	if "" == effect then
		return
	end

	local bunble, asset = ResPath.GetEffect(effect)
	if effect == "fazhen_circle" then
		bunble, asset = ResPath.GetEffect2(effect)
	end

	GameObjectPool.Instance:SpawnAsset(bunble, asset,
		function(obj)
			if nil == obj then
				return
			end

			local fazhen = obj:GetComponent(typeof(Fazhen))
			local moveobj = obj:GetComponent(typeof(MoveableObject))
			if nil == fazhen or nil == moveobj then
				GameObjectPool.Instance:Free(obj)
				return
			end

			self.effect_root = obj
			moveobj:SetPosition(self.real_pos.x, 0, self.real_pos.y)

			fazhen:SetRotateY(angle_y)
			if nil ~= size then
				fazhen:SetSize(size)
			end

			local total_time =  self.vo.disappear_time - self.vo.birth_time
			local elease_time = TimeCtrl.Instance:GetServerTime() - self.vo.birth_time + 0.5

			fazhen:Play(elease_time, total_time)

			GlobalTimerQuest:AddDelayTimer(function()
				if self.effect_root then
					GameObjectPool.Instance:Free(self.effect_root)
					self.effect_root = nil
				end
			end, total_time * 2)
		end)
end

function EffectObj:CreateEffect()
	local effect_name = ""
	local product_id = self.vo.product_id
	if product_id == PRODUCT_ID_TRIGGER.PRODUCT_ID_TRIGGER_SPECIAL_ICE_LANDMINE then
		effect_name = "bingshuangbaozha"
	elseif product_id == PRODUCT_ID_TRIGGER.PRODUCT_ID_TRIGGER_SPECIAL_FIRE_LANDMINE then
		effect_name = "14001"
	elseif product_id == PRODUCT_ID_TRIGGER.CLIENT_SHANDIANXIAN_LINE then
		effect_name = self.vo.res or "shandianxian"
	else
		local skill_cfg = SkillData.GetMonsterSkillConfig(self.vo.product_id)
		if nil ~= skill_cfg then
			effect_name = skill_cfg.fazhen_effect
		end
	end

	if "" == effect_name or "none" == effect_name then
		return
	end

	local bunble, asset = ResPath.GetEffect(effect_name)

	GameObjectPool.Instance:SpawnAsset(bunble, asset, function(obj)
		if not obj then
			return
		end
		self.effect_root = obj
		obj:GetOrAddComponent(typeof(MoveableObject)):SetPosition(self.real_pos.x, 0, self.real_pos.y)
		if product_id ~= PRODUCT_ID_TRIGGER.CLIENT_SHANDIANXIAN_LINE then
			GlobalTimerQuest:AddDelayTimer(function()
			--如果服务端没有释放，自动释放
				if self.effect_root then
					GameObjectPool.Instance:Free(self.effect_root)
					self.effect_root = nil
				end
			end, 3)
		end
	end)
end

