--
-- @Author: LaoY
-- @Date:   2019-01-09 20:17:22
--
Pet = Pet or class("Pet",DependObjcet)
function Pet:ctor()
	self.check_follow_range = 190
	self.check_follow_range_square = self.check_follow_range * self.check_follow_range
	self.old_check_follow_range_square = self.check_follow_range_square

	self.auto_fight_range = 500
	self.auto_fight_range_square = self.auto_fight_range * self.auto_fight_range
	
	self.smooth_time = 0.2
	self.stop_check_offset_time = 5
	self.follow_angle = 180
	
	self.is_follow_smooth_time = 0.3
	self.is_follow_offset_smooth_time = 0.3
	
	self.scale = 1.0
	self.is_in_strengthen = false
	
	self.is_follow = false 				-- 跟随
	self.is_follow_offset = false 		-- 方位校准
	self.is_attack_follow = false 		-- 战斗位置校准
	
	self.is_main_role_pet = self.owner_object.__cname == "MainRole"
	self:ChangeBody()
	
	self:SetPosition(self:GetFollowPosition())
end

function Pet:dctor()
	self:StopAction()
end

function Pet:CreateShadowImage()
	self.shadow_image = ShadowImage()
end

function Pet:InitMachine()
	self:RegisterMachineState(SceneConstant.ActionName.idle, true)
	self:RegisterMachineState(SceneConstant.ActionName.show, false)
	-- self:RegisterMachineState(SceneConstant.ActionName.show2, false)
	
	local run_func_list = {
		OnEnter = handler(self, self.RunOnEnter),
		OnExit = handler(self, self.RunOnExit),
		Update = handler(self, self.UpdateRunState),
	}
	self:RegisterMachineState(SceneConstant.ActionName.run, true, run_func_list)
	
	local attack_func_list = {
		OnEnter = handler(self, self.AttackOnEnter),
		OnExit = handler(self, self.AttackOnExit),
		Update = handler(self, self.UpdateAttack),
		CheckInFunc = handler(self, self.AttackCheckInFunc),
		CheckOutFunc = handler(self, self.AttackCheckOutFunc),
	}
	self:RegisterMachineState(SceneConstant.ActionName.attack1, false, attack_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.attack2, false, attack_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.attack3, false, attack_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.attack4, false, attack_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.Bigger, false, attack_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.skill, false, attack_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.skill1, false, attack_func_list)
	self:RegisterMachineState(SceneConstant.ActionName.skill2, false, attack_func_list)
end

function Pet:AddEvent()
	local function call_back()
		self:UpdateBuff()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("buffs",call_back)
	
	local function call_back()
		self:ChangeBody()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.pet",call_back)
end

function Pet:UpdateBuff()
	self.is_updatebuff = true
	local pet_buff = self.owner_info:GetShapeShiftBuff()
	if (self.pet_buff == pet_buff) or (self.pet_buff and pet_buff and self.pet_buff.id == pet_buff.id) then
		return
	end
	self.pet_buff = pet_buff
	if not pet_buff then
		self:StartAction(nil,1)
		self:ChangeBody()
		self.is_in_strengthen = false
	else
		self.is_in_strengthen = true
		local cf = Config.db_buff[pet_buff.id]
		local show = String2Table(cf.scale_show)
		local is_scale = false
		local is_switch = false
		if not table.isempty(show) then
			for k,v in pairs(show) do
				if v[1] == "scale" then
					is_scale = true
					self:StartAction(nil,v[2])
					-- 变身技能要缓存原来的节点下面的特效
				elseif v[1] == "switch" then
					is_switch = true
					self:ChangeBody(v[2])
				end
			end
		end
		if not is_scale then
			self:StartAction(nil,1)
		end
		if not is_switch then
			self:ChangeBody()
		end

		if not is_scale and not is_switch then
			self.is_in_strengthen = false
		end
	end

	if self.is_in_strengthen then
		self.check_follow_range_square = self.auto_fight_range_square
	else
		self.check_follow_range_square = self.old_check_follow_range_square
	end
end

function Pet:ChangeBody(swithc_id)

	local pet_id = self.owner_info.figure.pet and self.owner_info.figure.pet.model
	if not pet_id then
		return
	end
	local pet_cf = Config.db_pet[pet_id]
	if not pet_cf then
		return
	end
	local res_id = swithc_id or pet_cf.model
	local abName = "model_pet_" .. res_id
	local assetName = "model_pet_" .. res_id
	
	if swithc_id then
		self.default_state = self.cur_state_name
		self:ChangeToMachineDefalutState()
		self.is_switch_body = true
	else
		self.default_state = nil
	end
	if self.abName == abName then
		self.is_switch_body = false
		return
	end
	self:CreateBodyModel(abName,assetName)
end

function Pet:LoadBodyCallBack()
	for k,v in pairs(self.action_list) do
		v.action_time = nil
	end
	local action = self.action_list[self.cur_state_name]
	if action then
		if self.animator then
			action.action_time = GetClipLength(self.animator, action.action_name)
		else
			action.action_time = self.gpu_player:GetClipLength(action.action_name)
		end
	end
	-- self:ChangeToMachineDefalutState()
	
	self.is_switch_body = false
	if not self.is_updatebuff then
		self:UpdateBuff()
	end
end

function Pet:RunOnEnter()
	Pet.super.RunOnEnter(self)
end

function Pet:RunOnExit()
	Pet.super.RunOnExit(self)
end

function Pet:UpdateRunState(action_name, delta_time)
	if self.is_attack_follow then
		self.is_attack_follow = Time.time
	end
	local from = Vector2(self.position.x,self.position.y)
	local to = Vector2(self.move_pos.x,self.move_pos.y)
	local dis = Vector2.DistanceNotSqrt(from,to)
	if dis <= 3 or (self.is_follow_offset and dis <= 9*9) then
		self.is_update_offset = false
		self:SetPosition(to.x,to.y)
		self:ChangeToMachineDefalutState()
		self.is_follow = false
		self.is_follow_offset = false
		self.is_attack_follow = false
		return
	end
	
	local pos,speed
	if self.is_attack_follow then
		pos,speed = Smooth(from, to, self.follow_speed, self.is_follow_smooth_time * 0.5, delta_time)
	elseif self.is_follow then
		pos,speed = Smooth(from, to, self.follow_speed, self.is_follow_smooth_time, delta_time)
	else
		pos,speed = Smooth(from, to, self.follow_speed, self.is_follow_offset_smooth_time, delta_time)
	end
	self.follow_speed = speed
	-- if Vector2.DistanceNotSqrt(from,pos) > dis then
	-- 	pos = to
	-- end
	self:SetPosition(pos.x,pos.y)
	
	dis = Vector2.DistanceNotSqrt(to,pos)
	if dis <= 1 then
		self:SetPosition(to.x,to.y)
		self.is_update_offset = false
		self:ChangeToMachineDefalutState()
		self.is_follow = false
		self.is_follow_offset = false
		self.is_attack_follow = false
	end
end

function Pet:FollowOwner()
	if self.is_attack_follow and Time.time - self.is_attack_follow < 0.5 then
		return
	end
	if self:IsAttacking() or (self.is_in_strengthen and Vector2.DistanceNotSqrt(self.position,self.owner_object.position) <= self.auto_fight_range_square) then
		return
	end
	local from = self:GetPosition()
	from = Vector2(from.x,from.y)
	local owner_position = Vector2(self:GetCenterPosition())
	local to = from
	if Vector2.DistanceNotSqrt(from,owner_position) > self.check_follow_range_square then
		to = GetDirDistancePostion(owner_position,from,self.check_follow_range,nil)
	end
	if from.x == to.x and from.y == to.y then
		self.is_follow = false
		return
	end
	self.is_follow = true
	self.is_follow_offset = false
	self:SetMovePosition(to)
end

function Pet:FollowOwnerOffset()
	if self.is_attack_follow and Time.time - self.is_attack_follow < 0.5 then
		return
	end
	if self:IsAttacking() or (self.is_in_strengthen and Vector2.DistanceNotSqrt(self.position,self.owner_object.position) <= self.auto_fight_range_square) then
		return
	end
	local from = self:GetPosition()
	from = Vector2(from.x,from.y)
	local to = Vector2(self:GetFollowPosition())
	if from.x == to.x and from.y == to.y then
		self.is_follow_offset = false
		return
	end
	self.is_follow = false
	self.is_follow_offset = true
	self:SetMovePosition(to)
end

function Pet:UpdateAttack(state_name, delta_time)
	
end

function Pet:StartAction(time,scale)
	if not time then
		local action = self.action_list[SceneConstant.ActionName.attack01]
		time = action and action.action_time or 1.0
	end
	self:StopAction()
	local action = cc.ScaleTo(time,scale)
	cc.ActionManager:GetInstance():addAction(action,self.parent_transform)
end

function Pet:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.parent_transform)
end

function Pet:SetScale(scale)
	Pet.super.SetScale(self,scale)
	self.scale = scale
end

function Pet:GetScale()
	return self.scale
end

function Pet:Update(delta_time)
	Pet.super.Update(self,delta_time)
	self:CheckAttack()
end

function Pet:CheckAttack()
	if not self.transform or self.is_switch_body then
		return
	end
	if self.is_main_role_pet then
		if self.owner_object:IsDeath() then
			return
		end
		if self.last_attack_time and Time.time - self.last_attack_time < 0.5 then
			return
		end
		-- 主角在攻击或者自动战斗下 宠物会放技能
		if not self.owner_object:IsAttacking() and (not self.is_in_strengthen or Vector2.DistanceNotSqrt(self.position,self.owner_object.position) > self.auto_fight_range_square) then
			return
		else
			if not self.is_in_strengthen then
				local action = self.owner_object:GetCurStateInfo()
				if action and action.skill_vo and action.skill_vo.fuse_time and action.pass_time >= action.skill_vo.fuse_time then
					return
				end
				self.stop_count_time = 0
				self.is_update_offset = false
			end
		end

		
		if not self:IsCanPlayNextAttack() then
			return
		end
		
		local pet_skill_list = PetModel:GetInstance():GetOnBattleSkill()
		local cur_skill
		
		local cur_time_ms = os.clock()
		if not self.is_in_strengthen then
			local skill_vo = SkillUIModel:GetInstance():GetSkillByIndex(enum.SKILL_POS.SKILL_POS_PET_TRANS_RRO)
			if skill_vo and cur_time_ms > tonumber(skill_vo.cd) then
				cur_skill = skill_vo and skill_vo.id
			end
			if not cur_skill then
				skill_vo = SkillUIModel:GetInstance():GetSkillByIndex(enum.SKILL_POS.SKILL_POS_PET_NORMAL)
				if skill_vo and cur_time_ms > tonumber(skill_vo.cd) then
					cur_skill = skill_vo and skill_vo.id
				end
			end
		else
			local skill_vo = SkillUIModel:GetInstance():GetSkillByIndex(enum.SKILL_POS.SKILL_POS_PET_TRANS_PRO)
			if skill_vo and cur_time_ms > tonumber(skill_vo.cd) then
				cur_skill = skill_vo and skill_vo.id
			end
			if not cur_skill then
				skill_vo = SkillUIModel:GetInstance():GetSkillByIndex(enum.SKILL_POS.SKILL_POS_PET_TRANS_NOR)
				if skill_vo and cur_time_ms > tonumber(skill_vo.cd) then
					cur_skill = skill_vo and skill_vo.id
				end
			end
		end
		-- local skill = SkillManager:GetInstance():GetPetReleaseSkillByList(cur_skill)
		local skill = cur_skill
		if not skill then
			return
		end
		local bo,pos = self:CheckAttackDis(skill)
		if not bo then
			-- local dis = pos and Vector2.DistanceNotSqrt(pos,self.owner_object.position) or self.auto_fight_range_square
			-- if pos and dis < self.auto_fight_range_square then
			if pos then
				self.is_follow = false
				self.is_follow_offset = false
				self.is_attack_follow = Time.time
				self:SetMovePosition(pos)
			end
			return
		end
		if skill then
			self.last_attack_time = Time.time
			-- Yzprint('--LaoY Pet.lua,line 333--',skill)
			SkillManager:GetInstance():ReleaseSkill(skill)
		end
	end
end

function Pet:CheckAttackDis(skill)
	-- self.last_check_lock_id
	local client_lock_target_id = FightManager:GetInstance().client_lock_target_id
	if not client_lock_target_id and not self.is_in_strengthen then
		return false,nil
	end
	local target = SceneManager:GetInstance():GetObject(client_lock_target_id)
	if not target or target:IsDeath() then
		if self.is_in_strengthen then
			target = SceneManager:GetInstance():GetCreepInScreen(nil,enum.CREEP_KIND.CREEP_KIND_MONSTER)
			if not target or target:IsDeath() then
				return
			end
			FightManager:GetInstance():LockFightTarget(target.object_id)
		else
			return false,nil
		end
	end
	if not self.is_in_strengthen and self.last_skill_id == skill and self.last_owner_pos and Vector2.DistanceNotSqrt(self.last_owner_pos,self.owner_object.position) < 1 then
		local target_dis_not_sqrt = self.last_target_pos and Vector2.DistanceNotSqrt(self.last_target_pos,self.position) or 2
		if self.last_target_pos and target_dis_not_sqrt > 1 then
			return false,self.last_target_pos
		elseif target_dis_not_sqrt <= 1 then
			return true
		end
	end
	local radius = target:GetVolume() * 0.5
	local attack_dis = SkillManager:GetInstance():GetSkillAttackDistance(skill)
	local target_pos = target:GetPosition()
	-- local dis_not_sqrt = Vector2.DistanceNotSqrt(self.position,target_pos)
	local dis_not_sqrt = Vector2.DistanceNotSqrt(self.owner_object.position,target_pos)
	local check_range
	local err_dir = 20
	if self.last_check_lock_id == client_lock_target_id then
		check_range = attack_dis * 0.7 + radius - err_dir
	else
		check_range = attack_dis + radius - err_dir
	end
	local check_range_square = self.auto_fight_range_square
	self.last_check_lock_id = client_lock_target_id
	local bo = true
	local last_target_pos
	if (dis_not_sqrt - check_range_square) <= 1e-05 then
		-- 攻击对象为boss，而且boss与主角的距离小于宠物的x倍攻击距离之内,实际计算要用平方 x*x
		if (not self.is_in_strengthen or self.owner_object:IsAttacking()) and target.__cname == "Monster" and SceneConfigManager:GetInstance():IsBossMonster(target.config.rarity)
			and dis_not_sqrt < check_range_square * 2.3 then
			local vec_pos = pos(0,self.owner_object.position.y)
			local offsetX = 150
			if self.owner_object.position.x >= self.position.x then
				-- vec_pos.x = self.owner_object.position.x - offsetX
				offsetX = -offsetX
			else
				-- vec_pos.x = self.owner_object.position.x + offsetX
			end
			vec_pos.x = self.owner_object.position.x - 2*(self.owner_object.position.x - target_pos.x) + offsetX
			-- return false,GetDirDistancePostion(target_pos,vec_pos,check_range)
			bo = false
			last_target_pos = GetDirDistancePostion(target_pos,vec_pos,check_range)
		else
			-- return false,GetDirDistancePostion(target_pos,self.position,check_range)
			bo = false
			last_target_pos = GetDirDistancePostion(target_pos,self.position,check_range)
		end
	end

	if self.is_in_strengthen and not self.owner_object:IsAttacking() and dis_not_sqrt and dis_not_sqrt > self.auto_fight_range_square then
		return false,nil
	end		

	self.last_target_pos = last_target_pos
	self.last_owner_pos = pos(self.owner_object.position.x , self.owner_object.position.y)
	self.last_skill_id = skill

	if last_target_pos and Vector2.DistanceNotSqrt(last_target_pos,target_pos) >= Vector2.DistanceNotSqrt(self.position,target_pos) then
		return true
	end

	return bo,last_target_pos
end

function Pet:GetShowActionName()
	-- local t = {SceneConstant.ActionName.show}
	-- return t[math.random(#t)]
	return SceneConstant.ActionName.show
end

function Pet:LoopActionOnceEnd()
	if self.cur_state_name == SceneConstant.ActionName.idle then
		local action = self.action_list[self.cur_state_name]
		if action.total_time  >= 10 then
			local action_name = self:GetShowActionName()
			self:ChangeMachineState(action_name)
		end
	end
end

function Pet:SetTransformLayer(flag,layer)
	local bo = Pet.super.SetTransformLayer(self,flag,layer)
	if not bo then
		return
	end
	if self.transform_layer_is_self then
		self.shadow_image:SetVisible(true)
	else
		self.shadow_image:SetVisible(false)
	end
end