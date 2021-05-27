
Role = Role or BaseClass(Character)

function Role:__init(vo)
	self.obj_type = SceneObjType.Role

	self.role_res_id = 0							-- 角色资源id
	self.wuqi_res_id = 0							-- 武器资源id
	self.chibang_res_id = 0							-- 翅膀资源id
	self.hand_res_id = 0							-- 手套资源id
	self.douli_res_id = 0							-- 斗笠资源id
	self.phantom_res_id = 0							-- 幻影资源id
	self.footprint_effect_res_id = 0 				-- 足迹资源id
	self.zhenqi_res_id = 0 							-- 真气资源id
	self.next_create_footprint_time = -1 			-- 下一次生成足迹的时间
	self.sex = 0
	self.last_atk_time = 0 							-- 最后攻击时间
	self.title_layer = nil
	self:CreateTitle()
	self.big_face = nil
	self.show_face_time = 0
	self.is_pingbi_chibang = false					--屏蔽翅膀
	self.is_pingbi_hand = false						--屏蔽手套
	self.is_pingbi_zhenqi = false					--屏蔽真气
	self.is_pingbi_douli = false					--屏蔽斗笠
	self.is_pingbi_phantom = false					--屏蔽幻影
	self.title_vis = true
	self.height = COMMON_CONSTS.ROLE_HEIGHT

	-- Wait
	self.state_machine:SetStateFunc(SceneObjState.Wait, self.EnterStateWait, self.UpdateStateWait, self.QuitStateWait)
end

function Role:__delete()
	if nil ~= self.title_layer then
		self.title_layer:DeleteMe()
		self.title_layer = nil
	end
	self.big_face = nil

	if nil ~= self.vo then
		self:DeleteFireObj()
	end
end

function Role:LoadInfoFromVo()
	Character.LoadInfoFromVo(self)
	self:SetMoveSpeed(self.vo[OBJ_ATTR.CREATURE_MOVE_SPEED])
	self:SetScale(1.3, true)
	self:InitResId()

end

function Role:CreateEnd()
	self:UpdateFireObj()
end

function Role:InitResId()
	self:UpdateResId()
end

function Role:UpdateResId()
	self.role_res_id = self.vo[OBJ_ATTR.ENTITY_MODEL_ID]
	self.wuqi_res_id = self.vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]
	self.chibang_res_id = self.vo[OBJ_ATTR.ACTOR_WING_APPEARANCE]
	self.hand_res_id = self.vo[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE]
	self.sex = self.vo[OBJ_ATTR.ACTOR_SEX]
	self.douli_res_id = bit:_rshift(self.vo[OBJ_ATTR.ACTOR_FOOT_APPEARANCE], 16)
	self.footprint_effect_res_id = bit:_and(self.vo[OBJ_ATTR.ACTOR_FOOT_APPEARANCE], 0x0000FFFF)
	self.phantom_res_id = self.vo[OBJ_ATTR.ACTOR_WINGEQUIP_APPEARANCE]
	self.zhenqi_res_id = self.vo[OBJ_ATTR.ACTOR_GENUINEQI_APPEARANCE]
end

function Role:CreateBoard()
	if self.name and self.name ~= "" then
		self:SetNameBoard(RoleNameBoard.New())
		self:UpdateNameBoard()
	end
	self:SetHpBoardVisible(true)
end

function Role:UpdateNameBoard()
	if self.name_board then
		self.name_board:SetRole(self.vo, self.logic_pos.x, self.logic_pos.y)
	end
	self:UpdateTitle()
end

function Role:CreateTitle()
	self.title_layer = RoleTitleBoard.New()
	self:GetModel():AttachNode(self.title_layer:GetRootNode(), cc.p(0,15), GRQ_SCENE_OBJ, InnerLayerType.Title)

	self:UpdateTitle()
end

function Role:UpdateTitle()
	if nil == self.title_layer then return end

	-----押镖场景特殊处理-----
	local vo
	if self.vo[OBJ_ATTR.ACTOR_ESCORT_FLAG] == 1 then -- 保险护送
		vo = DeepCopy(self.vo)
		vo[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 200 -- 显示"保险护送"特效
	elseif ActivityData.IsInEscortActivityScene() then -- 押镖场景中
		vo = DeepCopy(self.vo)
		vo[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = 0 --屏蔽称号显示
	else
		vo = self.vo
	end
	-----end-----

	self.title_layer:CreateTitleEffect(vo)
	self.title_layer:SetTitleListOffsetY(self:GetFixedHeight() + 15)
	self:SetTitleLayerVisible(self.title_vis)
end

function Role:OnLogicPosChange()
	if GlobalData.is_show_role_pos then
		self:UpdateNameBoard()
	end

	if self:GetFootPrintEffectResId() ~= 0 then
		if self.next_create_footprint_time == 0 then
			self:CreateFootPrint(self:GetFootPrintEffectResId())
			self.next_create_footprint_time = Status.NowTime + COMMON_CONSTS.FOOTPRINT_CREATE_GAP_TIME
		end	

		if self.next_create_footprint_time == -1 then --初生时也是位置改变，不播
			self.next_create_footprint_time = 0
		end
	end
end

function Role:SetTitleLayerVisible(is_visible)
	self.title_vis = is_visible
	if self.title_layer then
		self.title_layer:SetTitleVisible(is_visible and self.model:IsVisible())
	end
end

function Role:SetNameLayerSimple(is_simple_name)
	if self.name_board then
		self.name_board:SetIsSimple(is_simple_name)
	end
	self:UpdateTitle()
end

function Role:SetIsPingbiChibang(is_pingbi_chibang)
	if self.is_pingbi_chibang ~= is_pingbi_chibang then
		self.is_pingbi_chibang = is_pingbi_chibang
		if "" ~= self.action_name and self.model:IsVisible()  then
			self:RefreshAnimation()
		end
	end
end

function Role:SetIsPingbiDouli(is_pingbi_douli)
	if self.is_pingbi_douli ~= is_pingbi_douli then
		self.is_pingbi_douli = is_pingbi_douli
		if "" ~= self.action_name and self.model:IsVisible() then
			self:RefreshAnimation()
		end
	end
end

function Role:SetIsPingbiHands(is_pingbi_hand)
	if self.is_pingbi_hand ~= is_pingbi_hand then
		self.is_pingbi_hand = is_pingbi_hand
		if "" ~= self.action_name and self.model:IsVisible() then
			self:RefreshAnimation()
		end
	end
end

function Role:SetIsPingbiPhantom(is_pingbi_phantom)
	if self.is_pingbi_phantom ~= is_pingbi_phantom then
		self.is_pingbi_phantom = is_pingbi_phantom
		if "" ~= self.action_name and self.model:IsVisible() then
			self:RefreshAnimation()
		end
	end
end

function Role:SetIsPingbiZhenqi(is_pingbi_zhenqi)
	if self.is_pingbi_zhenqi ~= is_pingbi_zhenqi then
		self.is_pingbi_zhenqi = is_pingbi_zhenqi
		if "" ~= self.action_name and self.model:IsVisible() then
			self:RefreshAnimation()
		end
	end
end

function Role:IsRole()
	return true
end

function Role:Update(now_time, elapse_time)
	Character.Update(self, now_time, elapse_time)
	if self.big_face and now_time - self.show_face_time > 5 then
		self.big_face:setVisible(false)
	end

	if self.next_create_footprint_time > 0 and now_time >= self.next_create_footprint_time and self:GetFootPrintEffectResId() ~= 0 then
		self.next_create_footprint_time = 0
	end
end

function Role:GetRoleId()
	return 0
end

function Role:GetRoleResId()
	return self.role_res_id
end

function Role:GetWuQiResId()
	return self.wuqi_res_id
end

function Role:GetMountResId()
	return 0
end

function Role:GetChiBangResId()
	return self.chibang_res_id
end

function Role:GetHandResId()
	return self.hand_res_id
end

function Role:GetFootPrintEffectResId()
	return self.footprint_effect_res_id
end

function Role:GetDouliResId()
	return self.douli_res_id
end

function Role:GetPhantomResId()
	return self.phantom_res_id
end

function Role:GetZhenQiResId()
	return self.zhenqi_res_id
end

function Role:SetScale(scale, is_all)
	if scale ~= self.model:GetScale() then
		self.model:SetScale(scale, is_all)
		self:SetHeight(COMMON_CONSTS.ROLE_HEIGHT * scale)
	end
end

function Role:OnMainAnimateStart()
	self:SetHeight(COMMON_CONSTS.ROLE_HEIGHT)
	self.animate_state_name = self.state_machine:GetStateName()
end

function Role:SetHeight(height)
	Character.SetHeight(self, height)
	if nil ~= self.title_layer then
		self.title_layer:SetTitleListOffsetY(self:GetFixedHeight() + 15)
	end
end

-- 刷新动画
function Role:RefreshAnimation()
	if nil == self.state_machine:GetStateName() or "" == self.action_name then
		return
	end
	local dir_num, is_flip_x = self:GetResDirNumAndFlipFlag()
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
			false, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, 0, 0, 1, nil, self.action_begin_time)
	else
		if nil ~= self.last_chibang_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, "", "")
			self.last_chibang_layer = nil
		end
	end

	-- 手套
	layer = InnerLayerType.HandUp
	if 0 ~= self.hand_res_id and not self.is_pingbi_hand then
		if nil ~= self.last_hand_layer and self.last_hand_layer ~= layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_hand_layer, "", "")
		end
		anim_path, anim_name = ResPath.GetHandAnimPath(self.hand_res_id, self.action_name, self.action_name == SceneObjState.Dead
	and GameMath.DirUp or self.vo.dir)
		self.last_hand_layer = layer
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
			false, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, 0, -10, 1.3, nil, self.action_begin_time)
	else
		if nil ~= self.last_hand_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, "", "")
			self.last_hand_layer = nil
		end
	end

	-- 真气
	layer = InnerLayerType.ZhenQi
	if 0 ~= self.zhenqi_res_id and not self.is_pingbi_zhenqi then
		if nil ~= self.last_zhenqi_layer and self.last_zhenqi_layer ~= layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_zhenqi_layer, "", "")
		end
		anim_path, anim_name = ResPath.GetEffectUiAnimPath(self.zhenqi_res_id)

		self.last_zhenqi_layer = layer
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
			false, FrameTime.Effect, nil, self.loops, self.is_pause_last_frame, 0, 15, 0.5, nil, self.action_begin_time)
	else
		if nil ~= self.last_zhenqi_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, "", "")
			self.last_zhenqi_layer = nil
		end
	end

	-- -- 斗笠    外观弃用
	-- if 0 ~= self.douli_res_id and not self.is_pingbi_douli then
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

	-- 幻影
	layer = InnerLayerType.PhantomDown
	if dir_num == GameMath.DirUp or dir_num == GameMath.DirUpRight or dir_num == GameMath.DirUpLeft then
		layer = InnerLayerType.PhantomUp
	end
	if 0 ~= self.phantom_res_id and not self.is_pingbi_phantom and self.action_name == SceneObjState.Run then
		if nil ~= self.last_phantom_layer and self.last_phantom_layer ~= layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_phantom_layer, "", "")
		end
		anim_path, anim_name = ResPath.GetPhantomAnimPath(self.phantom_res_id, self.action_name, dir_num)
		self.last_phantom_layer = layer
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
			is_flip_x, 0.13, nil, self.loops, self.is_pause_last_frame, 0, 0, nil, nil, self.action_begin_time)
	else
		if nil ~= self.last_phantom_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_phantom_layer, "", "")
			self.last_phantom_layer = nil
		end
	end

	-- 萌宠
	layer = InnerLayerType.ZsPetUp
	local res_cfg = DiamondsPetsConfig.level
	local self_lv = DiamondPetData.Instance:GetDiamondPetData() and DiamondPetData.Instance:GetDiamondPetData().pet_lv or 0
	local level = self.IsMainRole and self_lv or self.vo[OBJ_ATTR.ACTOR_DIAMONDSPETS_APPEARANCE]

	self.is_pingbi_zspet = false

	local pet_dir = dir_num
	local pet_is_flip = is_flip_x
	if res_cfg[level] then
		if dir_num == GameMath.DirUpRight or dir_num == GameMath.DirDownRight or dir_num == GameMath.DirRight then
			pet_dir = GameMath.DirUp
		elseif dir_num == GameMath.DirUpLeft or dir_num == GameMath.DirDownLeft then
			pet_dir = GameMath.DirDown
		elseif dir_num == GameMath.DirDown then
			pet_dir = GameMath.DirLeft
			pet_is_flip = true
		elseif dir_num == GameMath.DirUp then
			pet_dir = GameMath.DirLeft
			pet_is_flip = true
		end
		if dir_num == GameMath.DirUpRight or dir_num == GameMath.DirUpLeft or dir_num == GameMath.DirUp then
			self.zs_pet_res_id = res_cfg[level].res_cfg[1]
		else
			self.zs_pet_res_id = res_cfg[level].res_cfg[2]
		end
	else
		self.zs_pet_res_id = 0
	end

	if self.zs_pet_res_id and 0 ~= self.zs_pet_res_id and not self.is_pingbi_zspet then
		if nil ~= self.last_zs_pet_layer and self.last_zs_pet_layer ~= layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_zs_pet_layer, "", "")
		end
		anim_path, anim_name = ResPath.GetEffectUiAnimPath(self.zs_pet_res_id, self.action_name == "run" and "move" or self.action_name, pet_dir)
		self.last_zs_pet_layer = layer
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
			pet_is_flip, 0.13, nil, self.loops, self.is_pause_last_frame, 100, 140, 0.7, nil, self.action_begin_time)
	else
		if nil ~= self.last_zs_pet_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_zs_pet_layer, "", "")
			self.last_zs_pet_layer = nil
		end
	end

	--护体类buff
	self:UpdateHutiBuffLayerId()
end

function Role:CreateFootPrint(footprint_effect_res_id)
	self.parent_scene:CreateFootPrint(self, footprint_effect_res_id)
end

----------------<<状态函数Begin>>------------------
function Role:DoAttack(skill_id, skill_level, sound_id)
	if Character.DoAttack(self, skill_id, skill_level, sound_id) then
		--可以攻击时 停止等待
		if self:IsWait() then
			self:StopAction()
		end

		--攻击后进入等待时间 无攻击则进入stand状态
		--预算等待时间
		-- local wait_time = math.max(Status.NowTime - SkillData.Instance:GetGlobalCD(),  self:GetAttr(OBJ_ATTR.CREATURE_ATTACK_SPEED) / 1000 - Config.ATTACK_PALY_TIME)
		local req_spare_time = 0.12
		local wait_time = self:GetAttr(OBJ_ATTR.CREATURE_ATTACK_SPEED) / 1000 - Config.ATTACK_PALY_TIME + req_spare_time
		
		--某些技能 可能有特别的后摇时间
		local skill_cfg = SkillData.GetSkillLvCfg(skill_id, skill_level)
		if nil ~= skill_cfg and nil ~= skill_cfg.afterAtkWaitTime then
			wait_time = skill_cfg.afterAtkWaitTime / 1000 - Config.ATTACK_PALY_TIME
		end

		self:AddAction(SceneObjState.Wait, wait_time, nil)
		return true
	end

	return false
end

function Role:GetAtkAction(action_id, sound_id)
	local action_name = ""

	if action_id > 0 then
		action_name = SceneObjState.Atk .. 2
	else
		action_name = SceneObjState.Atk .. 1
	end

	if self.action_param.skill_id == 0 then
		if 0 == self.wuqi_res_id then
			sound_id = AudioEffect.Atk
		else
			sound_id = AudioEffect.AtkWuqi
		end
	end

	return action_name, sound_id
end

function Role:GetLaskAtkTime()
	return self.last_atk_time
end

-- 死亡
function Role:EnterStateDead(is_init)
	if not is_init then
		if self.vo[OBJ_ATTR.ACTOR_SEX] == GameEnum.MALE then
			AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.DeadMale))
		else
			AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.DeadFemale))
		end
	end
	Character.EnterStateDead(self)
end

function Role:IsWait()
	return self.state_machine:IsInState(SceneObjState.Wait)
end

function Role:EnterStateWait()
	self:PlayAnimation(SceneObjState.Wait, FrameTime.Wait)
end

function Role:UpdateStateWait(elapse_time)
	if self.is_special_move then
		self:UpdateMoveLogic(elapse_time)
	end
end

function Role:QuitStateWait()
end

----------------<<状态函数End>>------------------

function Role:OnClick()
	Character.OnClick(self)
	if nil ~= self.model then
		local anim_path, anim_name = ResPath.GetEffectAnimPath(ResPath.SelectRed)
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Select, anim_path, anim_name)
	end
end

function Role:SetAttr(index, value)
	if index == OBJ_ATTR.ENTITY_MODEL_ID 
		or index == OBJ_ATTR.ACTOR_WEAPON_APPEARANCE
		or index == OBJ_ATTR.ACTOR_WINGEQUIP_APPEARANCE
		or index == OBJ_ATTR.ACTOR_WING_APPEARANCE
		or index == OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE
		or index == OBJ_ATTR.ACTOR_DIAMONDSPETS_APPEARANCE
		or index == OBJ_ATTR.ACTOR_FOOT_APPEARANCE 
		or index == OBJ_ATTR.ACTOR_GENUINEQI_APPEARANCE then
		self.vo[index] = value
		self:UpdateResId()
		self:RefreshAnimation()
		return
	elseif index == OBJ_ATTR.CREATURE_LEVEL then
		if value > self.vo[index] then
			AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.UpLevel))
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(ResPath.UpLevel)
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.UpLevel, anim_path, anim_name, false, FrameTime.Effect, nil, 1)
		end
	elseif index == "name_color"
		or index == "name"
		or index == "guild_name"
		or index == "partner_name"
		or index == OBJ_ATTR.ACTOR_VIP_GRADE
		or index == OBJ_ATTR.ACTOR_CUTTING_LEVEL
		or index == OBJ_ATTR.CREATURE_STATE
		or index == OBJ_ATTR.ACTOR_WARPATH_ID then
		self:SetNameValue(index, value)
		if self.name_board then
			self:UpdateNameBoard()
		end
		self:UpdateTitle()
		return
	elseif index == OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE then
		self.vo[index] = value
		self:UpdateTitle()
		return
	elseif index == OBJ_ATTR.ACTOR_ESCORT_FLAG then
		self.vo[index] = value
		self:UpdateTitle()
		return
	end

	Character.SetAttr(self, index, value)

	if index == OBJ_ATTR.ACTOR_FLAMINTAPPEARANCEID then
		self:UpdateFireObj()
	end
end

function Role:SetNameValue(index, value)
	self.vo[index] = value
end

-----------------------------------------------------
-- 烈焰神力
-----------------------------------------------------
function Role:GetFireObj()
	if nil ~= self.vo.fire_obj_id then
		local fire_obj = self.parent_scene:GetObjectByObjId(self.vo.fire_obj_id)
		return fire_obj
	end
	return nil
end

function Role:DeleteFireObj()
	local fire_obj = self:GetFireObj()
	if fire_obj then
		self.parent_scene:DeleteObj(fire_obj:GetObjId())
		self.vo.fire_obj_id = nil
	end
end

function Role:UpdateFireObj()

	local fire_obj = self:GetFireObj()
	if self.vo[OBJ_ATTR.ACTOR_FLAMINTAPPEARANCEID] > 0 then
		if nil == fire_obj then
			self:CreateFireObj()
		end
	else
		self:DeleteFireObj()
	end
end

function Role:CreateFireObj()
	if self.parent_scene then
		local fire_obj_vo = GameVoManager.Instance:CreateVo(FireObjVo)
		fire_obj_vo.owner_obj_id = self:GetObjId()
		fire_obj_vo.pos_x = self.vo.pos_x - 1
		fire_obj_vo.pos_y = self.vo.pos_y + 1
		local fire_obj = self.parent_scene:CreateFireObj(fire_obj_vo, SceneObjType.FireObj)
		if nil ~= fire_obj then
			self.vo.fire_obj_id = fire_obj:GetObjId()
		end
		return fire_obj
	end
end
