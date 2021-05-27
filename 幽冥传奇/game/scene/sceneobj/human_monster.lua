HumanMonster = HumanMonster or BaseClass(Monster)
function HumanMonster:__init()
	self.obj_type = SceneObjType.Humanoid

	self.role_res_id = 0							-- 角色资源id
	self.wuqi_res_id = 0							-- 武器资源id
	self.chibang_res_id = 0							-- 翅膀资源id

	self.is_pingbi_chibang = false					--屏蔽翅膀
end

function HumanMonster:__delete()
end	

function HumanMonster:LoadInfoFromVo()
	Monster.LoadInfoFromVo(self)
	self:SetMoveSpeed(self.vo[OBJ_ATTR.CREATURE_MOVE_SPEED])
	self:InitResId()
	self:SetScale(1.2,false)
end

function HumanMonster:InitResId()
	self:UpdateResId()
end

function HumanMonster:UpdateResId()
	self.role_res_id = self.vo[OBJ_ATTR.ENTITY_MODEL_ID]
	self.wuqi_res_id = self.vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]
	self.chibang_res_id = self.vo[OBJ_ATTR.ACTOR_WING_APPEARANCE]
end

function HumanMonster:DoReadyDead()
	Character.DoReadyDead(self)
end	

function HumanMonster:SetIsPingbiChibang(is_pingbi_chibang)
	self.is_pingbi_chibang = is_pingbi_chibang
	self:RefreshAnimation()
end

--动画刷新接口
function HumanMonster:RefreshAnimation()
	if self.action_type == ActionType.Unknown then
		return
	end	


	if not self:GetIsNotMaskModel() then
		if self.body_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.body_layer,"","")
			self.body_layer = nil
		end	

		if self.last_chibang_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, "", "")
			self.last_chibang_layer  = nil
		end

		if self.last_wuqi_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_wuqi_layer, "", "")
			self.last_wuqi_layer = nil
		end	

		return
	end		


	local ani_name_prefix = self:GetAniPrefixByActionType(self.action_type)

	local dir_num, is_flip_x = self:GetResDirNumAndFlipFlag()
	if self.action_type == ActionType.ReadyDead then
		dir_num = GameMath.DirUp
	end	

	local ani_start_time = self.sync_start_time
	if self.action_type == ActionType.Move or self.action_type == ActionType.Run then
		ani_start_time = self.async_start_time
	end	
	
	local anim_path, anim_name = nil, nil
	if self.role_res_id > 0 then
		anim_path, anim_name = self:GetBodyModelPath(self.role_res_id,ani_name_prefix,dir_num)
		self.body_layer = InnerLayerType.Main
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, 
										   self.body_layer,
										   anim_path,
										   anim_name, 
			                               is_flip_x, 
			                               self.delay_per_unit, 
			                               nil, 
			                               self.loops, 
			                               self.is_pause_last_frame, 
			                               nil, nil, nil, nil, 
			                               ani_start_time)	
	end

	-- 武器
	local layer = InnerLayerType.WuqiUp
	if 0 ~= self.wuqi_res_id then
		local wuqi_id = self.wuqi_res_id
		if wuqi_id < 10 then
			wuqi_id = 10
		end	
		anim_path, anim_name = ResPath.GetWuqiAnimPath(wuqi_id, ani_name_prefix, dir_num)
		if dir_num == GameMath.DirUp then
			layer = InnerLayerType.WuqiDown
		end
		self.last_wuqi_layer = layer
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
			is_flip_x, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, nil, nil, nil, nil, ani_start_time)
	else
		if nil ~= self.last_wuqi_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_wuqi_layer, "", "")
			self.last_wuqi_layer = nil
		end
	end

	if self.action_type ~= ActionType.Dead and self.action_type ~= ActionType.ReadyDead then
		-- 翅膀
		layer = InnerLayerType.ChibangUp
		if dir_num == GameMath.DirDown 
			or dir_num == GameMath.DirDownRight 
			or dir_num == GameMath.DirDownLeft 
		    then
			layer = InnerLayerType.ChibangDown
		end

		if self.action_type == ActionType.AtkWait then
			if dir_num == GameMath.DirLeft 
				or dir_num == GameMath.DirRight then
				layer = InnerLayerType.ChibangDown
			end		
		end	

		if 0 ~= self.chibang_res_id and not self.is_pingbi_chibang then
			anim_path, anim_name = ResPath.GetChibangAnimPath(self.chibang_res_id, ani_name_prefix, dir_num)
			self.last_chibang_layer = layer
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
				is_flip_x, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, nil, nil, nil, nil, ani_start_time)
		else
			if nil ~= self.last_chibang_layer then
				self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, "", "")
				self.last_chibang_layer = nil
			end
		end
	else
		if self.last_chibang_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, "", "")
			self.last_chibang_layer  = nil
		end
	end

end	

--动作转化接口
function HumanMonster:GetAniPrefixByActionType(actionType)
	if actionType == ActionType.Stand then
		return "stand"
	elseif actionType == ActionType.Move then
		return "run"
	elseif actionType == ActionType.Run then
		return "run"
	elseif actionType == ActionType.Atk then
		return "atk1"
	elseif actionType == ActionType.Spell then
		return "atk" .. self.cur_attack_effect_id
	elseif actionType == ActionType.ReadyDead then
		return "dead"
	elseif actionType == ActionType.Dead then
		return "dead"
	elseif actionType == ActionType.AtkWait then
		return "hit"		
	else
		return "stand"
		--print("有动作没有定义返回资源前缀!",actionType)	
	end	

	return ""
end	

--身体模型路径返回接口
function HumanMonster:GetBodyModelPath(res_id,ani_name_prefix,dir_num)
	return ResPath.GetRoleAnimPath(res_id, ani_name_prefix, dir_num)
end	

--动画总帧数返回接口
function HumanMonster:GetAniTotalframeByActionType(actionType)
	return RoleDirFrame[actionType]
end	

function HumanMonster:GetMoveActionFilterSpeed(speed)
	return speed * 2
end	

function HumanMonster:AppendMainAction(actionType,real_pos,life,logic_pos,action,dir)
	if actionType == ActionType.Move 
		or actionType == ActionType.Atk
		or actionType == ActionType.Spell then

		if self.action_type == ActionType.AtkWait then
			self.sync_end_time = 0	
			self.concat_action_list = {}
			self.action_type = ActionType.Unknown
		end
	end	
	Character.AppendMainAction(self,actionType,real_pos,life,logic_pos,action,dir)
end

function HumanMonster:DoAtk(real_pos,life,dir)
	Character.DoAtk(self,real_pos,life,dir)
	if #self.main_action_list < 1 then
		self.cur_attack_wait = 1
		self:AppendConcatAction(ActionType.AtkWait,nil,self.cur_attack_wait)
	end
	
end	

function HumanMonster:DoSpell(real_pos,life,action,dir)
	Character.DoSpell(self,real_pos,life,action,dir)
	if #self.main_action_list < 1 then
		self.cur_attack_wait = 1
		self:AppendConcatAction(ActionType.AtkWait,nil,self.cur_attack_wait)
	end
	
end	