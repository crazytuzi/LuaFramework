-- 
-- @Author: LaoY
-- @Date:   2018-07-28 10:47:37
-- 

FightData = FightData or class("FightData")

function FightData:ctor(skill_vo)
end

function FightData:dctor()
	self:StopSoundTime()
end

function FightData:initDefault()
	return {
		atkid = 0,					-- 攻击方ID
		angle = 0,					-- 旋转到的角度
		pos = Vector3.zero,			-- 特效位置
		is_played_effect = false,	-- 是否已经播放过特效
		time = 0,					-- 开始使用的时间
		pass_time = 0 ,				-- 开始后经过的时间
		skill_vo = false,			-- 技能信息
		effect_info = {},			-- 特效信息
		is_play_hurt_text = false,	-- 是否播放过伤害飘字
		dmgs1 = false,				-- 受击方结果
		dmgs2 = false,				-- 连击结果
		be_hit_color_state = false, -- 受击变色
		effect_state = {},			-- 特效播放情况 已经播放的受击效果要记录
		be_hit_action = false,		-- 是否播放受击动作
		is_slip = false,			-- 技能位移
		seq = 0,					-- 技能序号

		is_sign_fight_state = false, -- 是否标记战斗状态

		is_check_ballistic = false, 	-- 是否检测弹道技能
		is_check_hit_effect = false, 	-- 是否受击方特效(非受击特效，特效挂在受击方而已)

		sound_time_list = {}, 		-- 攻击音效定时器id列表； 受击音效放在受击既可
		is_play_sound = false, 		-- 是否播放攻击音效
	}
end

function FightData:InitPreData(attack,skill_vo,target)
	if not attack or attack.is_dctored or not skill_vo then
		return
	end
	self.atkid = attack.object_id
	self.attack = attack
	self.pre_target = target

	self.is_pet = SkillManager:GetInstance():IsPetSkill(skill_vo.skill_id)
	if self.is_pet then
		self.pet = attack:GetDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_PET)
	end
	if not target or target == attack then
		if self.pet then
			self.rotate = self.pet:GetRotate()
		else
			self.rotate = attack:GetRotate()
		end
	else
		local attack_pos = attack:GetPosition()
		if self.pet then
			attack_pos = self.pet:GetPosition()
		end
		local target_pos = target:GetPosition()
		local angle = GetSceneAngle(attack_pos,target_pos)
		local rotateX,rotateZ = GetSceneObjectRotateXZ(angle)
		self.rotate = {x = rotateX,y=angle,z = rotateZ}
	end
	self:InitSkillVo(self.pet or attack,skill_vo)

	--test
	-- if not target then
	-- 	return
	-- end
	-- local message = {}
	-- message.dmgs1 = {}
	-- local dmgs = {
	-- 	uid = target and target.object_id,
	-- 	type = enum.DAMAGE.DAMAGE_BLOOD,
	-- 	value = 1,
	-- }
	-- message.dmgs1[1] = dmgs
	-- self:InitResult(message)
end

function FightData:InitResult(message)
	if FightManager.FightMessageList[self.skill_key] then
		FightManager.FightMessageList[self.skill_key].is_use = true
	end
	self.message_time = message.message_time
	self.message = message
	if not table.isempty(message.dmgs1) then
		self.dmgs1 = clone(message.dmgs1)
	end
	if not table.isempty(message.dmgs2) then
		self.dmgs2 = clone(message.dmgs2)
	end
end

function FightData:InitSkillVo(attack,skill_vo)
	self.skill_vo = skill_vo
	if skill_vo.effect then
		local pos = attack:GetPosition()
		local rotate = self.rotate
		self.effect_info = {pos = {x = pos.x,y = pos.y,z = pos.z or 0},rotate = {x=rotate.x,y=rotate.y,z=rotate.z}}
	end
end

function FightData:InitData(attack,skill_vo,message)
	if not attack or attack.is_dctored then
		return
	end
	local skill_key = message.skill .. "_" .. message.seq
	self.atkid = attack.object_id
	self.attack = attack
	self.skill_key = skill_key
	local angle = message.dir
	local rotateX,rotateZ = GetSceneObjectRotateXZ(angle)
	self.rotate = {x = rotateX,y=angle,z = rotateZ}
	if skill_vo then
		self:InitSkillVo(attack,skill_vo)
	end
	self:InitResult(message)
	self:UpdateRotate()
end

function FightData:UpdateRotate()
	local target_id = self:GetTargetOneID()
	-- local attack_coord 	= self.message.coord
	local attack_coord 	= self.attack:GetPosition()
	if target_id and SceneManager:GetInstance():GetObject(target_id) then
		local target = SceneManager:GetInstance():GetObject(target_id)
		self.target = target
		local attack_pos = attack_coord
		local target_pos = target:GetPosition()
		local vec = {x = target_pos.x - attack_pos.x,y = target_pos.y - attack_pos.y}
		local angle = Vector2.GetAngle(vec)
		local rotateX,rotateZ = GetSceneObjectRotateXZ(angle)
		self.rotate = {x = rotateX,y=angle,z = rotateZ}
	end
end

function FightData:GetTarget()
	return self.target or self.pre_target
end

function FightData:GetTargetOneID()
	local target_id
	if not table.isempty(self.dmgs1) and #self.dmgs1 == 1 then
		for i,v in pairs(self.dmgs1) do
			target_id = v.uid
		end
	end
	return target_id
end

function FightData:PlayEffect(target,effect_vo,pass_time)
	FightManager:GetInstance():PlayEffect(self.attack,target,self.effect_info,effect_vo,pass_time)
end

function FightData:PlayHitEffect()
	if not self.is_check_hit_effect and (self.dmgs1 or (self.pass_time > 0.1)) then
		self.is_check_hit_effect = true

		do
			return
		end
		local effect_list = self.skill_vo.effect
		-- 主角或者设置可以看到别人特效才可以显示技能特效
		local is_main_role = self.attack == SceneManager:GetInstance():GetMainRole()
		if effect_list and (is_main_role or EffectManager:GetInstance():IsCanShowOtherEffect()) then
			local effect_info = self.effect_info
			local pos = effect_info.pos
			for i=1,#effect_list do
				local vo = effect_list[i]
				if vo.effect_type == FightConfig.EffectType.Hit2Pos or vo.effect_type == FightConfig.EffectType.Hit then
					local target
					if not table.isempty(self.dmgs1) then
						target = SceneManager:GetInstance():GetObject(self.dmgs1[1].uid)
					end
					if not target and is_main_role then
						target = SceneManager:GetInstance():GetObject(FightManager:GetInstance().client_lock_target_id)
					end
					self:PlayEffect(target,vo,self.pass_time)
				end
			end
		end
	end
end

function FightData:PlayBallistic()
	if not self.is_check_ballistic and (self.dmgs1 or (self.pass_time > 0.1)) then
		self.is_check_ballistic = true

		local effect_list = self.skill_vo.effect
		-- 主角或者设置可以看到别人特效才可以显示技能特效
		local is_main_role = self.attack == SceneManager:GetInstance():GetMainRole()
		if effect_list and (is_main_role or not SettingModel:GetInstance().isHideOtherEffect) then
			local effect_info = self.effect_info
			local pos = effect_info.pos
			for i=1,#effect_list do
				local vo = effect_list[i]
				-- 弹道类型，直接朝着目标点放。多个弹道技能，回包再校准
				if vo.effect_type == FightConfig.EffectType.BallisticPos or vo.effect_type == FightConfig.EffectType.BallisticDir or
				vo.effect_type == FightConfig.EffectType.BallisticTrack then
					local target
					if not table.isempty(self.dmgs1) then
						target = SceneManager:GetInstance():GetObject(self.dmgs1[1].uid)
					end
					if not target and is_main_role then
						target = SceneManager:GetInstance():GetObject(FightManager:GetInstance().client_lock_target_id)
					end
					self:PlayEffect(target,vo)
				elseif vo.effect_type == FightConfig.EffectType.BallisticMulPos then
					if not table.isempty(self.dmgs1) then
						for k,dmg in pairs(self.dmgs1) do
							local target = SceneManager:GetInstance():GetObject(dmg.uid)
							self:PlayEffect(target,vo)
						end
					elseif is_main_role then
						local target = SceneManager:GetInstance():GetObject(FightManager:GetInstance().client_lock_target_id)
						self:PlayEffect(target,vo)
					end
				end
			end
		end
	end
	
end

function FightData:Update(deltaTime)
	self.pass_time = self.pass_time + deltaTime
	self:Slip()
	self:SignFightState()
	self:BeHit()
	self:BeHitEffect()
	self:BeHitColor()
	self:HurtText()

	self:PlayBallistic()
	self:PlayHitEffect()
	self:PlaySound()
end

function FightData:PlaySound()
	if self.is_play_sound then
		return
	end
	self:StopSoundTime()
	if not self.skill_vo.sound or table.isempty(self.skill_vo.sound) then
		return
	end
	self.is_play_sound = true
	if self.attack ~= SceneManager:GetInstance():GetMainRole() then
		return
	end
	local len = #self.skill_vo.sound
	for i=1,len do
		local info = self.skill_vo.sound[i]
		if info.type == 1 then
			if info.time then
				-- 播放
				SoundManager:GetInstance():PlayById(info.id)
			else
				local time_id 
				local function step()
					-- 播放
					SoundManager:GetInstance():PlayById(info.id)
					-- 移除 time_id 引用
				end
				time_id = GlobalSchedule:StartOnce(step,info.time)
				self.sound_time_list[#self.sound_time_list+1] = time_id
			end
		end
	end
end

function FightData:StopSoundTime()
	for k,time_id in pairs(self.sound_time_list) do
		GlobalSchedule:Stop(time_id)
	end
	self.sound_time_list = {}
end

-- 锁血
function FightData:LockBlood()
end

function FightData:Slip()
	if self.skill_vo.slip and not self.is_slip and (not self.skill_vo.slip.start_time or self.pass_time > self.skill_vo.slip.start_time) then
		self.is_slip = true
		local distance  = self.skill_vo.slip.distance		
		local time 	  	= self.skill_vo.slip.time
		local rate_type = self.skill_vo.slip.rate_type
		local rate 	  	= self.skill_vo.slip.rate
        local speed = distance / time
		
		local object
		local pos
		local start_pos
		if self.dmgs1 and self.dmgs1[1] then
			object = SceneManager:GetInstance():GetObject(self.dmgs1[1].uid)
			if object then
				pos = object:GetPosition()
			end
		end

		if not pos and self.attack == SceneManager:GetInstance():GetMainRole() then
			object = SceneManager:GetInstance():GetObject(FightManager:GetInstance().client_lock_target_id)
			if object then
				pos = object:GetPosition()
			end
		end

		if not pos or self.skill_vo.slip.type == 1 then
			local vec = Vector2(self.attack.direction.x,self.attack.direction.y)
	        vec:Mul(distance)
	        pos = { x = self.attack.position.x + vec.x, y = self.attack.position.y + vec.y }
		else
			local attack_dis = SkillManager:GetInstance():GetSkillAttackDistance(self.skill_vo.skill_id)
			local dis = Vector2.Distance(pos,self.attack.position)
			-- dis = dis - self.attack:GetVolume()
			if object then
				dis = dis - object:GetVolume() - attack_dis * 0.3
			end
			if dis <= 0 then
				return
			end
			if dis < distance then
				distance = dis
			end
			local vec = GetDirByVector(self.attack.position, pos)
	        vec:Mul(distance)
	        pos = { x = self.attack.position.x + vec.x, y = self.attack.position.y + vec.y }
		end		
		local bo,x,y = OperationManager:GetInstance():GetFarest(self.attack.position,pos)
		if bo then
			pos = {x = x,y = y}
		end
        self.attack:PlaySlip(pos, speed, nil, rate_type, rate)
	end
end

-- 标记战斗状态
function FightData:SignFightState()
	if not self.is_sign_fight_state and self.dmgs1 then
		self.is_sign_fight_state = true
		for k,damage in pairs(self.dmgs1) do
			local object = SceneManager:GetInstance():GetObject(damage.uid)
			-- if object and not object:IsDeath() and object.is_loaded then
			if object and not object:IsDeath() then
				-- 受击方标记伤害来源
				object:SignBeHit(self.attack,damage.value)

				-- 攻击方标记攻击对象
				self.attack:SignAttack(object)
			end
		end
	end
end

--受击动作
function FightData:BeHit()
	if not self.be_hit_action and self.dmgs1 and self.skill_vo.hurt_action_time and self.pass_time >= self.skill_vo.hurt_action_time then
		self.be_hit_action = true
		local is_repel = self.skill_vo.repel ~= nil
		for k,damage in pairs(self.dmgs1) do
			local object = SceneManager:GetInstance():GetObject(damage.uid)
			-- if object and not object:IsDeath() and object.is_loaded then
			if object and not object:IsDeath() then
				object:PlayHit(self.attack)
				if is_repel and damage.hp > 0 then
					-- if object.slipping then
					-- 	Notify.ShowText("slipping")
					-- end
					local distance  = self.skill_vo.repel.distance		
					local time 	  	= self.skill_vo.repel.time				
					local rate_type = self.skill_vo.repel.rate_type				
					local rate 	  	= self.skill_vo.repel.rate
					object:BeRepel(self.attack,distance,time,rate_type,rate)
				end
			end
		end
	end
end

-- 受击特效
function FightData:BeHitEffect()
	local effect_list = self.skill_vo and self.skill_vo.effect or nil
	if effect_list then
		local effect_info = self.effect_info
		for i=1,#effect_list do
			local vo = effect_list[i]
			if not self.effect_state[vo.name] and self.dmgs1 and self.pass_time >= vo.start_time 
				and vo.effect_type == FightConfig.EffectType.Hurt then
				self.effect_state[vo.name] = true
				if self.attack == SceneManager:GetInstance():GetMainRole() then
					for k,damage in pairs(self.dmgs1) do
						local object = SceneManager:GetInstance():GetObject(damage.uid)
						-- if object and not object:IsDeath() and object.is_loaded then
						if object and not object:IsDeath() then
							FightManager:GetInstance():PlayEffect(self.attack,object,effect_info,vo)
						end
					end
				end
			end
		end
	end
end

--变色
function FightData:BeHitColor()
	if not self.be_hit_color_state and self.skill_vo.hit_color and self.dmgs1 
	and self.skill_vo.hurt_text_start_time and self.pass_time >= self.skill_vo.hurt_text_start_time then
		self.be_hit_color_state = true
		for k,damage in pairs(self.dmgs1) do
			local object = SceneManager:GetInstance():GetObject(damage.uid)
			if object and object.__cname == "Monster" and not object:IsDeath() then
				local color = self.skill_vo.hit_color.color
				local scale = self.skill_vo.hit_color.scale
				local bias  = self.skill_vo.hit_color.bias
				local time  = self.skill_vo.hit_color.time
				object:BeHit(color,scale,bias,time)
			end
		end 
	end
end

-- 伤害飘字
function FightData:HurtText()
	if not self.is_play_hurt_text and self.dmgs1 then
		if self.dmgs1 and self.skill_vo.hurt_text_start_time then
			if self.pass_time >= self.skill_vo.hurt_text_start_time then
				self.is_play_hurt_text = true
				for k,damage in pairs(self.dmgs1) do
					local object = SceneManager:GetInstance():GetObject(damage.uid)
					if object and not object:IsDeath() then
						object:SetHp(damage.hp,self.message_time)
						if damage.hp <= 0 then
							object:PlayDeath(self.attack)
						end
						if object.__cname == "MainRole" then
							-- object:PlayDeath()
							if table.isempty(self.skill_vo.mul) then
								local info = {damage = damage,atkid = self.atkid}
								FightManager:GetInstance():AddTextInfo(info)
							else
								local len = #self.skill_vo.mul
								local value = math.floor(damage.value/len)
								local mul_damage = clone(damage)
								mul_damage.value = value
								for i=1,len do
									local delay_time = self.skill_vo.mul[i]
									local info = {damage = mul_damage,atkid = self.atkid,delay_time = delay_time}
									FightManager:GetInstance():AddTextInfo(info)
								end
							end
						else
							if self.attack == SceneManager:GetInstance():GetMainRole() then

								if table.isempty(self.skill_vo.mul) then
									local damagetext = DamageText(nil,nil,damage)
									damagetext:SetData(self.atkid,damage)
								else
									local len = #self.skill_vo.mul
									local value = math.floor(damage.value/len)
									local mul_damage = clone(damage)
									mul_damage.value = value
									for i=1,len do
										local delay_time = self.skill_vo.mul[i]
										local damagetext = DamageText(nil,nil,mul_damage)
										damagetext:SetData(self.atkid,mul_damage,delay_time)
									end
								end

								
							end
						end
					end
				end
			end
		elseif self.dmgs1 then
			self.is_play_hurt_text = true
			for k,damage in pairs(self.dmgs1) do
				local object = SceneManager:GetInstance():GetObject(damage.uid)
				if object and not object:IsDeath() then
					object:SetHp(damage.hp,self.message_time)
					if damage.hp <= 0 then
						object:PlayDeath(self.attack)
					end
				end
			end
		end
	end
end