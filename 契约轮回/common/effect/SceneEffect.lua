-- 
-- @Author: LaoY
-- @Date:   2018-07-27 17:56:58
--

SceneEffect = SceneEffect or class("SceneEffect",BaseEffect)
local SceneEffect = SceneEffect
function SceneEffect:ctor(parent,abName,scene_effect_type)
	self.scene_effect_type = scene_effect_type
	self.is_attack_to_pos = false
 	if scene_effect_type == EffectManager.SceneEffectType.Pos or 
 		scene_effect_type == EffectManager.SceneEffectType.Shoot then
 		self.parent = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneEffect)
 	else
		self.parent = parent
 	end
 	if not self.parent then
 		logError("SceneEffect parent is nil")
 	end
 	self.builtin_layer = LayerManager.BuiltinLayer.Default
 	BaseEffect.Load(self)
end

function SceneEffect:dctor()
 	if self.is_add_be_hit_ref then
		EffectManager:GetInstance():RemoveBeHitEffectRef()
	end
end

function SceneEffect:initDefault()
	return {
		config = false,		-- 配置
		play_time = 0,		-- 播放总时间 有可能循环多次
		once_time = 0,		-- 单次播放时间
		is_loop = false,	-- 是否循环
		pass_time = 0,		-- 特效经过时间
		is_play = false,	--是否在播放
	}
end

 function SceneEffect:LoadCallBack()
 	self.is_play = false
 	if self.abName:find("effect_machiaction_") then
 		self.once_time = self:GetParticleSystemLength(self.gameObject)
 	else
	 	self.once_time = GetParticleSystemLength(self.gameObject)
 	end

	SetChildLayer(self.transform,self.builtin_layer)

 	if self.is_need_setconfig then
 		self:SetConfig()
 	end
end

function SceneEffect:GetParticleSystemLength(gameObject)
	local time = 0
	local list =  gameObject:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem),true)
	local length = list and list.Length or 0
	for i=0,length - 1 do
		local ps = list[i]
		-- time = Mathf.Max(time, ps.main.duration)
		time = Mathf.Max(time, GetParticleSystemLength(ps.gameObject))
	end
	return time
end

function SceneEffect:PlayEffect(flag)
	self:SetVisible(flag)
	SceneEffect.super.PlayEffect(self,flag)
end

--[[
	@author LaoY
	@des	
	@param  config 	table
	@param1 pos		Vector3  必须是像素坐标
	@param2 scale 	number or Vector3
	@param3 useMask bool
	@param4 is_loop bool
--]]
 function SceneEffect:SetConfig(config)
 	self.config = config or self.config
 	if not self.config then
 		return
 	end
 	if self.is_loaded then

 		if self.config.skill_effect_type == FightConfig.EffectType.Hurt and not self.is_add_be_hit_ref then
 			EffectManager:GetInstance():AddBeHitEffectRef()
 			self.is_add_be_hit_ref = true
 		end

 		self.is_need_setconfig = false
 		if self.config.pos then
 			local pos = self.config.pos
		 	if self.scene_effect_type == EffectManager.SceneEffectType.Pos then
	 			SetGlobalPosition(self.transform, pos.x/SceneConstant.PixelsPerUnit, pos.y/SceneConstant.PixelsPerUnit,pos.z/SceneConstant.PixelsPerUnit)
 			elseif self.scene_effect_type == EffectManager.SceneEffectType.Target then
 				SetLocalPosition(self.transform,pos.x,pos.y,pos.z)
 			elseif self.scene_effect_type == EffectManager.SceneEffectType.Shoot then
 				SetLocalPosition(self.transform,pos.x,pos.y,pos.z)
	 		else
 				SetLocalPosition(self.transform,0,0,0)
	 		end

	 		if self.config.skill_effect_type and self.config.target then
	 			if not self.is_attack_to_pos and (self.config.skill_effect_type == FightConfig.EffectType.Attack2Pos or 
	 				self.scene_effect_type == EffectManager.SceneEffectType.Shoot or
	 				self.config.skill_effect_type == FightConfig.EffectType.Hit2Pos) then
	 				self.is_attack_to_pos = true
			 		local function step()
			 			if self.is_dctored then
			 				return
			 			end
			 			local parent = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneEffect)
		 				self.transform:SetParent(parent)

						SetLocalScale(self.transform)
						if self.isVisible ~= nil then
							self:SetVisible(self.isVisible)
						end
						-- SetLocalRotation(self.transform,0,0,0)

						-- local curr_rotate = Vector3(0,90,0)
						-- self.transform:Rotate(curr_rotate)

						local target = self.config.target
						local pos = target:GetPosition()

						if self.config.skill_vo and self.config.skill_vo.offset and self.config.skill_vo.offset > 0 and self.config.skill_effect_type == FightConfig.EffectType.Attack2Pos then
							local start_pos = target:GetPosition()
							local vec = Vector2(target.direction.x,target.direction.y)
							vec:Mul(self.config.skill_vo.offset)
							pos = {x=start_pos.x+vec.x,y = start_pos.y+vec.y,z = start_pos.z}
							pos.z = LayerManager:GetInstance():GetSceneObjectDepth(pos.y) * SceneConstant.PixelsPerUnit
						end

			 			SetGlobalPosition(self.transform, pos.x/SceneConstant.PixelsPerUnit, pos.y/SceneConstant.PixelsPerUnit,pos.z/SceneConstant.PixelsPerUnit)
			 		end
			 		local is_delay_time = self.config.start_time
			 		if not is_delay_time or is_delay_time <= 0.03 then
			 			is_delay_time = 0.03
			 		end
			 		GlobalSchedule:StartOnce(step,is_delay_time)
			 		-- step()
			 	-- 	local curr_rotate = Vector3(SceneConstant.SceneRotate.x,y,SceneConstant.SceneRotate.z)
					-- self.transform:Rotate(curr_rotate)
	 			end
	 		end
 		end

		local rotate = self.config.rotate
 		if rotate then
 			local curr_rotate = Vector3(SceneConstant.SceneRotate.x,rotate.y,SceneConstant.SceneRotate.z)
			self.transform:Rotate(curr_rotate)
 			-- SetLocalRotation(self.transform,rotate.x,rotate.y,rotate.z)
 		end

		local rotation = self.config.rotation
		if rotation then
			SetLocalRotation(self.transform,rotation.x,rotation.y,rotation.z)
		end

 		if self.config.scale then
 			local scale = self.config.scale
 			if type(scale) == "number" then
				SetLocalScale(self.transform,scale,scale,scale)
			elseif type(scale) == "table" then
				local effects = go:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem))
				if scale.z == nil then scale.z = 1 end
				for i = 0, effects.Length - 1 do
					local effect = effects[i]
					effect.main.scalingMode = UnityEngine.ParticleSystemScalingMode.IntToEnum(1)
					SetLocalScale(effect.transform,scale.x, scale.y, scale.z)
				end
				SetLocalScale(self.transform,scale.x, scale.y, scale.z)
			else
				SetLocalScale(self.transform,1,1,1)
			end
		else
			SetLocalScale(self.transform,1,1,1)
 		end

 		local speed =  self.config.speed or self.speed
 		self:SetSpeed(speed)
 		if self.config.useMask then
 			-- self:SetEffectMask()
 		else
 			--todo set layer
 		end

 		self.is_loop = false
 		if self.config.is_loop then
	 		self.is_loop = true
	 		self.play_time = nil
 		elseif self.config.play_time then
	 		self.play_time = self.config.play_time
 		elseif not self.config.play_count then
 			self.play_time = self.once_time
		elseif self.config.play_count == 0 then
 			self.play_time = self.once_time
		elseif self.config.play_count < 0 then
	 		self.is_loop = false
 			self.play_time = 10000
 		else
 			self.play_time = self.config.play_count * self.once_time
 		end 
 		-- self.is_loop = true
 		if self.is_loop or  (self.play_time and self.play_time > self.once_time) then
			self:SetLoop(true)
 		else
			self:SetLoop(false)
 		end

 		if not self.config.start_time or self.config.start_time == 0 then
 			self.config.start_time = 0
 			self:PlayEffect(true)
 		else
 			self:PlayEffect(false)
 		end
 	else
 		self.is_need_setconfig = true
 	end
 end