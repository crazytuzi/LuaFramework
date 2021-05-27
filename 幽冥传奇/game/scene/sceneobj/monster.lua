
Monster = Monster or BaseClass(Character)

function Monster:__init(monster_vo)
	self.obj_type = SceneObjType.Monster
	self.res_id = 1
	self.wuqi_res_id = 0
	self.chibang_res_id = 0
	self.douli_res_id = 0
	self.sex = 0
	self.wait_time = 0
	self.is_show_name = false
	self.is_pingbi_chibang = false					--屏蔽翅膀
	self.height = COMMON_CONSTS.MONSTER_HEIGHT
	if self:IsHumanoid() then
		self.height = COMMON_CONSTS.ROLE_HEIGHT
		--Wait
		self.state_machine:SetStateFunc(SceneObjState.Wait, self.EnterStateWait, self.UpdateStateWait, self.QuitStateWait)
	end

	if self:IsTaskMonster() then
		for k,v in pairs(TaskMonsterAttr[self.vo.monster_id]) do
			self.vo[k] = v
		end
		self:CreateTitle()
	end
end

function Monster:__delete()
	if nil ~= self.title_layer then
		self.title_layer:DeleteMe()
		self.title_layer = nil
	end
end

function Monster:LoadInfoFromVo()
	self.name = ""	-- 防止Character自动创建名字条
	Character.LoadInfoFromVo(self)
	self:SetMoveSpeed(self.vo[OBJ_ATTR.CREATURE_MOVE_SPEED])
	self.res_id = self.vo[OBJ_ATTR.ENTITY_MODEL_ID]
	self.wuqi_res_id = self.vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]
	self.chibang_res_id = self.vo[OBJ_ATTR.ACTOR_WING_APPEARANCE]
	self.douli_res_id = bit:_rshift(self.vo[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] or 0, 16)
	self.sex = self.vo[OBJ_ATTR.ACTOR_SEX] or 0

	if self:IsHumanoid() then
		self:SetScale(1.3, true)
	elseif self.vo.entity_type == EntityType.Saparation then
		self:SetScale(1, true)
	else
		local model_cfg = BossData.GetMosterModelCfg(self.res_id)
		if nil ~= model_cfg then
			self:SetScale(model_cfg.modelScale, true)
		end
	end
end

function Monster:SetIsPingbiChibang(is_pingbi_chibang)
	if self.is_pingbi_chibang ~= is_pingbi_chibang then
		self.is_pingbi_chibang = is_pingbi_chibang
		if "" ~= self.action_name and self.model:IsVisible() then
			self:RefreshAnimation()
		end
	end
end

function Monster:GetName()
	return self.vo.name
end

function Monster:RefreshAnimation()
	if self.action_name == SceneObjState.Dead then
		if self.can_excavate ~= false and StdMonster and StdMonster[self.vo.monster_id] and StdMonster[self.vo.monster_id].bDeathDig then
			-- 只要是可挖掘的怪物就创建面板和显示死亡特效, 创建后才判断是否显示
			DiamondPetCtrl.Instance:InitExcavateBoss(self)
		else
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(987)
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, 
				false, FrameTime.Effect, nil, 1)

			if nil ~= self.last_wuqi_layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_wuqi_layer, "", "")
				self.last_wuqi_layer = nil
			end
			if nil ~= self.last_chibang_layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, "", "")
				self.last_chibang_layer = nil
			end
			self:SetHpBoardVisible(false)
			self:SetShadowVisible(false)
			if self.title_layer then
				self.title_layer:SetTitleVisible(false)
			end
			if self.name_board then
				self.name_board:SetVisible(false)
				self:SetHpBoardVisible(false)
			end
		end
		return
	end

	local dir_num, is_flip_x = self:GetResDirNumAndFlipFlag()
	if not self:IsHumanoid() and self.vo.entity_type ~= EntityType.Saparation then
		local anim_path, anim_name = self:GetMonsterAnimPath(dir_num)
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, 
			is_flip_x, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, nil, nil, nil, nil, self.action_begin_time)
	end

	if self:IsHumanoid() or  self.vo.entity_type == EntityType.Saparation then
		--衣服

		local anim_path, anim_name = self:GetMonsterAnimPath(self.action_name == SceneObjState.Dead and GameMath.DirUp or self.vo.dir)
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, 
			false, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, nil, nil, nil, nil, self.action_begin_time)

		-- 武器
		local layer = InnerLayerType.WuqiDown
		if RoleWuqiLayer[1][self.state_machine:GetStateName()] and RoleWuqiLayer[1][self.state_machine:GetStateName()][self.vo.dir] then
			layer = InnerLayerType.WuqiUp
		end
	
		if 0 ~= self.wuqi_res_id and  self.wuqi_res_id then
			if nil ~= self.last_wuqi_layer and self.last_wuqi_layer ~= layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_wuqi_layer, "", "")
			end
			anim_path, anim_name = ResPath.GetWuqiAnimPath(self.wuqi_res_id, self.action_name, self.vo.dir)
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
		if 0 ~= self.chibang_res_id and self.chibang_res_id and not self.is_pingbi_chibang then
			if nil ~= self.last_chibang_layer and self.last_chibang_layer ~= layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, "", "")
			end
			anim_path, anim_name = ResPath.GetChibangAnimPath(self.chibang_res_id, self.action_name, self.vo.dir)
			self.last_chibang_layer = layer
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
				false, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, 0, -10, 1.3, nil, self.action_begin_time)
		else
			if nil ~= self.last_chibang_layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, "", "")
				self.last_chibang_layer = nil
			end
		end

		-- 斗笠
		-- if 0 ~= self.douli_res_id then
		-- 	anim_path, anim_name = ResPath.GetDouLiAnimPath(self.douli_res_id + self.sex, self.action_name, dir_num)
		-- 	self.last_douli_layer = InnerLayerType.DouLi
		-- 	self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.DouLi, anim_path, anim_name, 
		-- 		is_flip_x, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, nil, nil, nil, nil, self.action_begin_time)
		-- else
		-- 	if nil ~= self.last_douli_layer then
		-- 		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_douli_layer, "", "")
		-- 		self.last_douli_layer = nil
		-- 	end
		-- end
	end
end

function Monster:UpdateHpBoardVisible()
	if not self:IsDead() then
		self:SetHpBoardVisible(true)
	else
		self:SetHpBoardVisible(false)
	end
end

function Monster:GetResDirNumAndFlipFlag()
	local dir_num, is_flip_x = Character.GetResDirNumAndFlipFlag(self)

	-- 非人形怪只有4方向
	if not self:IsHumanoid() and not self:IsBiaoche() and not self:IsPet() and not(self.vo.entity_type == EntityType.Saparation) then
		if dir_num == GameMath.DirUpRight then
			dir_num = GameMath.DirRight
		elseif dir_num == GameMath.DirDownRight then
			dir_num = GameMath.DirRight
		end
	end

	return dir_num, is_flip_x
end

function Monster:GetAtkAction(action_id, sound_id)
	local action_name = SceneObjState.Atk

	if self:IsHumanoid() or self.vo.entity_type == EntityType.Saparation then
		if self.action_param.skill_id == 0 then
			if 0 == self.wuqi_res_id then
				sound_id = AudioEffect.Atk
			else
				sound_id = AudioEffect.AtkWuqi
			end
		end

		if action_id > 0 then
			action_name = SceneObjState.Atk .. 2
		else
			action_name = SceneObjState.Atk .. 1
		end
	end

	return action_name, sound_id
end

function Monster:GetMonsterAnimPath(dir_num)
	if self:IsHumanoid() or self.vo.entity_type == EntityType.Saparation then
		return ResPath.GetRoleAnimPath(self.res_id, self.action_name, dir_num)
	end

	return ResPath.GetMonsterAnimPath(self.res_id, self.action_name, dir_num)
end

function Monster:OnClick()
	Character.OnClick(self)

	local anim_path, anim_name
	if (self:IsPet() or self:IsHero()) and self.vo.owner_obj_id == self.parent_scene:GetMainRole():GetObjId() then
		anim_path, anim_name = ResPath.GetEffectAnimPath(ResPath.SelectBlue)
	else
		anim_path, anim_name = ResPath.GetEffectAnimPath(ResPath.SelectRed)
	end
	self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Select, anim_path, anim_name)

	if not self:IsHumanoid() and not self:IsPet() and not self:IsBiaoche() and not self:IsTaskMonster() then
		if nil == self.name_board and 0 == self.vo.is_hide_name then
			local name_board = nil
			name_board = NameBoard.New()
			-- name_board:SetName(self.vo.name, Str2C3b(string.format("%06x", self.vo.name_color)))
			name_board:SetNameType(self.vo.monster_id, Str2C3b(string.format("%06x", self.vo.name_color)))
			self:SetNameBoard(name_board)
		end
		if nil ~= self.name_board then
			self.name_board:SetVisible(true)
			self:SetHpBoardVisible(true)
		end
	end
end

function Monster:SetNameLayerShow(is_show_name)
	self.is_show_name = is_show_name
	if is_show_name then
		self:CreateBoard()
		if nil ~= self.name_board then
			self.name_board:SetVisible(true)
			self:SetHpBoardVisible(true)
		end
	elseif self.vo.entity_type == EntityType.Saparation then
		self.name_board:SetVisible(true)
		self:SetHpBoardVisible(true)
	elseif self.name_board and not self.is_select and not self:IsHumanoid() and not self:IsPet() and not self:IsBiaoche() and not self:IsBoss() and not self:IsHero() then
		self.name_board:SetVisible(false)
		self:SetHpBoardVisible(false)
	end
end

function Monster:CreateBoard()
	if nil == self.name_board and 0 == self.vo.is_hide_name then
		if self:IsHero() or self.vo.entity_type == EntityType.Saparation then
			self:SetNameBoard(HeroNameBoard.New())
			self.name_board:SetHero(self.vo)
		elseif self:IsPet() or self:IsBiaoche() then
			self:SetNameBoard(PetNameBoard.New())
			self.name_board:SetPet(self.vo)
		elseif self:IsTaskMonster()  then
			self:SetNameBoard(RoleNameBoard.New())
			self:UpdateNameBoard()
		elseif self.is_show_name or self:IsHumanoid() then
			local name_board = nil
			name_board = NameBoard.New()
			-- name_board:SetName(self.vo.name, Str2C3b(string.format("%06x", self.vo.name_color)))
			name_board:SetNameType(self.vo.monster_id, Str2C3b(string.format("%06x", self.vo.name_color)))
			self:SetNameBoard(name_board)
		elseif self:IsBoss() then
			local name_board = nil
			name_board = NameBoard.New()
			name_board:SetNameType(self.vo.monster_id, Str2C3b(string.format("%06x", self.vo.name_color)))
			self:SetNameBoard(name_board)
		end
	end
	self:SetHpBoardVisible(nil ~= self.name_board)
end

function Monster:CanClick()
	if  self.vo.entity_type == EntityType.Saparation or self:IsHero() then
		return false
	end
	return true
end

--取消选中
function Monster:CancelSelect()
	Character.CancelSelect(self)
	if nil ~= self.name_board and not self:IsHumanoid() and not self.is_show_name and not self:IsBoss() and not self:IsHero() then
		self.name_board:SetVisible(false)
		self:SetHpBoardVisible(false)
	end
end

function Monster:UpdateInnerBoardPercent()
end

function Monster:GetShieldVal()
	return self:GetAttr(OBJ_ATTR.ACTOR_EQUIP_WEIGHT)
end

function Monster:GetMaxShieldVal()
	local monster_cfg = StdMonster[self.vo.monster_id]
	if nil == monster_cfg then
		return 0
	else
		return monster_cfg.wAbsDefTms or 0
	end
end

function Monster:GetMonsterId()
	return self.vo.monster_id
end

function Monster:IsHumanoid()
	-- return self.vo.monster_race == EntityType.Humanoid or self:IsHero()
	return self.vo.monster_race == EntityType.Humanoid
end

function Monster:IsBoss()
	if self.vo.monster_type == MONSTER_TYPE.BOSS or self.vo.monster_type == MONSTER_TYPE.TOUMU then
		return true
	end

	return false
end

function Monster:IsCommon()
	return self.vo.monster_type == MONSTER_TYPE.COMMON
end

function Monster:IsGuarder()
	return self.vo.monster_type == MONSTER_TYPE.Guarder
end

function Monster:IsRealMonster()
	return IsMonsterByEntityType(self.vo.entity_type)
end

function Monster:IsPet()
	return self.vo.entity_type == EntityType.Pet
end

function Monster:IsBiaoche()
	if nil == self.biaoche_monster_id then
		self.biaoche_monster_id = {}
		for i,v in ipairs(StdActivityCfg) do
			if v.tBiaoche then
				for i2,v2 in ipairs(v.tBiaoche) do
				    self.biaoche_monster_id[v2.id] = true
				end
			end
		end
	end
	return self.biaoche_monster_id[self.vo.monster_id]
end

function Monster:IsMainRoleBiaoche()
	return self:IsBiaoche() and self:GetOwnerObjId() == self.parent_scene:GetMainRole():GetObjId()
end

function Monster:IsTaskMonster()
	return TaskMonsterAttr[self.vo.monster_id] ~= nil
end

function Monster:IsHero()
	return self.vo.entity_type == EntityType.Hero
end

function Monster:IsFenShen()
	return self.vo.entity_type == EntityType.Saparation
end

function Monster:GetOwnerObjId()
	return self.vo.owner_obj_id
end

function Monster:SetAttr(index, value)
	Character.SetAttr(self, index, value)
	if index == "name" then
		if self.name_board then
			self.name_board:SetName(value, Str2C3b(string.format("%06x", self.vo.name_color)))
		end
	elseif index == "owner_name" then
	end
end

function Monster:SetScale(scale, is_all)
	if scale ~= self.model:GetScale() then
		self.model:SetScale(scale, is_all)
		if not self:IsHumanoid() then
			self:SetHeight(math.max(self.model:GetHeight(), COMMON_CONSTS.MONSTER_HEIGHT * scale))
		else
			self:SetHeight(COMMON_CONSTS.ROLE_HEIGHT * scale)
		end
	end
end

function Monster:OnMainAnimateStart()
	if not self:IsHumanoid() then
		self:SetHeight(math.max(self.model:GetHeight(), COMMON_CONSTS.MONSTER_HEIGHT))
	else
		self:SetHeight(COMMON_CONSTS.ROLE_HEIGHT)
	end
	self.animate_state_name = self.state_machine:GetStateName()
end

function Monster:CreateTitle()
	self.title_layer = RoleTitleBoard.New()
	self:GetModel():AttachNode(self.title_layer:GetRootNode(), cc.p(0, 0), GRQ_SCENE_OBJ, InnerLayerType.Title)

	self:UpdateTitle()
end

function Monster:UpdateTitle()
	if nil == self.title_layer then return end
	self.title_layer:CreateTitleEffect(self.vo)
	self.title_layer:SetTitleListOffsetY(self:GetFixedHeight())
end

function Monster:UpdateNameBoard()
	if self.name_board then
		self.name_board:SetRole(self.vo, self.logic_pos.x, self.logic_pos.y)
	end
	self:UpdateTitle()
end

function Monster:DoAttack(...)
	if Character.DoAttack(self, ...) then
		if self:IsHumanoid() or self.vo.entity_type == EntityType.Saparation then
			if self:IsWait() then
				self:StopAction()
			end
			self:AddAction(SceneObjState.Wait, ATK_WAIT_TIME, nil)
		end
		return true
	end

	return false
end

function Monster:DoMove(...)
	Character.DoMove(self, ...)
end

function Monster:IsWait()
	return self.state_machine:IsInState(SceneObjState.Wait) 
end

function Monster:EnterStateWait()
	self:PlayAnimation(SceneObjState.Wait, FrameTime.Wait)
end

function Monster:UpdateStateWait(elapse_time)
end

function Monster:QuitStateWait()
end

