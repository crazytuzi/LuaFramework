------------------------------------------------------
--粒子特效系统
--@author bzw
------------------------------------------------------
require("scripts/game/effect/particle_effect_cfg")
require("scripts/game/effect/particle")
require("scripts/game/effect/particle_emitter")

ParticleEffectSys = ParticleEffectSys or BaseClass()

function ParticleEffectSys:__init()
	if ParticleEffectSys.Instance ~= nil then
		ErrorLog("[ParticleEffectSys] attempt to create singleton twice!")
		return
	end
	ParticleEffectSys.Instance = self
	self.now_time = 0

	self.max_exist_free_particle_count = 200 

	self.world = HandleRenderUnit:GetCoreScene()
	self.world_rect = {x = 0, y = 0, width = HandleRenderUnit:GetWidth(), height = HandleRenderUnit:GetHeight()}

	self.effect_list = {}
	--特效种类对应的最大数量
	self.effect_limit_list = {
		[Effect_Red_Flower.name] = {cur_num = 0, max_num = 2, invalid_time = 0, time_out = 20},
		[Effect_Blue_Flower.name] = {cur_num = 0, max_num = 2, invalid_time = 0, time_out = 20},
	}

	self.free_particle_list = {}   --id为key,方便找到，效率
	self.free_particle_count = 0

	self.show_one_flower_time = 0
	Runner.Instance:AddRunObj(self, 8)


	self.is_pingbi_flower = false		--是否屏送花
end

function ParticleEffectSys:__delete()
	ParticleEffectSys.Instance = nil

	for k, v in pairs(self.effect_list) do
		for _,emitter in pairs(v.emitter_list) do
			emitter:DeleteMe()
		end
	end

	Runner.Instance:RemoveRunObj(self)
end

--设置世界参数
function ParticleEffectSys:SetWorld(world, world_rect)
	self.world = world
	self.world_rect = world_rect
end

function ParticleEffectSys:PlayEffect(effect_cfg, effect_name, emit_place, stop_efect_name)
	local pingbi = effect_cfg.pingbi or 0
	if self.is_pingbi_flower and 1 == pingbi  then
		return
	end
	if effect_cfg == nil or self:IsOneFlowerTimeLimit(effect_cfg) then return end
	if effect_name == nil then
		Log("请指定特效名字，以便可控制停止")
		return
	end

	local limit_obj = self.effect_limit_list[effect_cfg.name]
	if limit_obj then
		if limit_obj.cur_num >= limit_obj.max_num then
			return
		else
			limit_obj.cur_num = limit_obj.cur_num + 1	
			limit_obj.invalid_time = self.now_time + limit_obj.time_out	
		end
	end

	if nil ~= stop_efect_name then
		self:StopEffect(stop_efect_name)
	end

	if effect_cfg.name == Effect_One_Flower.name then
		self.show_one_flower_time = TimeCtrl.Instance:GetServerTime()
	end

	local t = {name = effect_name, pingbi = pingbi, emitter_list = {}}
	table.insert(self.effect_list, t)
	emit_place = emit_place or self.world

	for k,v in pairs(effect_cfg.emit_list) do  --创建新的发射器
		local emitter = ParticleEmitter.New()
		table.insert(t.emitter_list, emitter)
		emitter:SetParticleName(effect_name)
		self:SetEmitterData(emitter, v, emit_place)
		emitter:StartEmit()
	end
end

-- 达到限制 (只判断和配置同名的特效)
function ParticleEffectSys:IsOneFlowerTimeLimit(effect_cfg)
	if nil == effect_cfg then return true end
	if effect_cfg.name == Effect_One_Flower.name and 
		TimeCtrl.Instance:GetServerTime() - self.show_one_flower_time < 12 then
		return true
	else
		return false
	end
end

-- 停止所有特效
function ParticleEffectSys:StopAllEffect(is_delete_free_particle)
	for k,v in pairs(self.effect_list) do
		self:StopEffect(v.name, is_delete_free_particle)
	end
end

--停止特效，会停止对应的发射器。
--发射器停止后，仍在下落的粒子会转变为自由粒子。不受发射器控制
function ParticleEffectSys:StopEffect(effect_name, is_delete_free_particle)
	local delete = {}

	for k,v in pairs(self.effect_list) do
		if v.name == effect_name then
			table.insert(delete, k)
			for _,emitter in pairs(v.emitter_list) do
				emitter:StopEmit()
			end
		end
	end

	for k,v in pairs(delete) do
		self.effect_list[v] = nil 
	end

	--移除自由粒子
	if is_delete_free_particle then
		delete = {}
		for k,v in pairs(self.free_particle_list) do
			if v:GetParticleName() == effect_name then
				v:KillForever()
				table.insert(delete, v)
			end
		end
		for k,v in pairs(delete) do
			self:RemoveFreeParticle(v)
		end
	end
end

function ParticleEffectSys:SetEmitterData(emitter, emitter_cfg, emit_place)
	local emit_area = nil
	if emitter_cfg.emit_offest_area ~= nil then
		local emit_place_max_w = 0
		local emit_place_max_h = 0
		
		if emit_place == self.world then
			emit_place_max_w = HandleRenderUnit:GetWidth()
			emit_place_max_h = HandleRenderUnit:GetHeight()
		else
			local emit_place_size = emit_place:getContentSize()
			emit_place_max_w = emit_place_size.width
			emit_place_max_h = emit_place_size.height
		end

		emit_area = {}
		emit_area.x = self:CalcParamValue(emitter_cfg.emit_offest_area[1] or 0)
		emit_area.y = emit_place_max_h + self:CalcParamValue(emitter_cfg.emit_offest_area[2] or 0)
		emit_area.width = self:CalcParamValue(emitter_cfg.emit_offest_area[3] or emit_place_max_w)
		emit_area.height = self:CalcParamValue(emitter_cfg.emit_offest_area[4] or emit_place_max_h)
	else
		if emit_place == self.world then
			emit_area = self.world_rect
		else
			emit_area = {x = 0, y = 0, width = emit_place:getContentSize().width, height = emit_place:getContentSize().height}
		end
	end

	local p_move_area = nil
	if emit_place == self.world then
		p_move_area = emitter_cfg.p_move_area or self.world_rect
	else
		p_move_area = emitter_cfg.p_move_area or {x = 0, y = 0, width = emit_place:getContentSize().width, height = emit_place:getContentSize().height}
	end
	
	emitter:SetEmitPlace(emit_place, emit_area, emitter_cfg.emit_to_scene)
	emitter:SetEmitStartTime(emitter_cfg.emit_start_time)
	emitter:SetEmitFrequency(emitter_cfg.emit_frequency)
	emitter:SetEmitNumDynamic(emitter_cfg.emit_num_dynamic[1], emitter_cfg.emit_num_dynamic[2], emitter_cfg.emit_num_dynamic[3])
	emitter:SetEmitKeepTime(emitter_cfg.emit_keep_time)
	emitter:SetEmitRotation(emitter_cfg.emit_rotation)
	emitter:SetMaxNumInRect(emitter_cfg.max_num_in_rect)

	emitter:SetEmitSeedList(emitter_cfg.seed_list)

	emitter:SetParticleMoveType(emitter_cfg.p_move_type, emitter_cfg.p_move_param)
	emitter:SetParticleMoveArea(p_move_area)
	emitter:SetParticleMoveSpeed(emitter_cfg.p_move_speed)
	emitter:SetParticleRotationSpeed(emitter_cfg.p_rotation_speed)
	emitter:SetParticleActionRandomList(emitter_cfg.p_act_list)
end

function ParticleEffectSys:CalcParamValue(value)
	local value_str = value .. ""
	value_str = string.gsub(value_str, "screen_w", HandleRenderUnit:GetWidth())
	value_str = string.gsub(value_str, "screen_h", HandleRenderUnit:GetHeight())
	return GameMath.CalcExpression(value_str)
end

function ParticleEffectSys:AddFreeParticle(particle)
	if particle == nil then return end
	if 	self.free_particle_list[particle:GetParticleId()] ~= nil then return end

	self.free_particle_list[particle:GetParticleId()] = particle
	self.free_particle_count = self.free_particle_count + 1
	end

function ParticleEffectSys:RemoveFreeParticle(particle)
	if particle == nil then return end
	if self.free_particle_list[particle:GetParticleId()] == nil then return end

	self.free_particle_list[particle:GetParticleId()] = nil
	self.free_particle_count = self.free_particle_count - 1
end


function ParticleEffectSys:Update(now_time, elapse_time)
	self.now_time = now_time
	if self.free_particle_count > self.max_exist_free_particle_count then
		local handle_count = 4
		for k,v in pairs(self.free_particle_list) do
			if self.free_particle_count > self.max_exist_free_particle_count and handle_count > 0 then
				v:KillForever()
				self:RemoveFreeParticle(v)
				handle_count = handle_count - 1
			end

			if handle_count == 0 then
				break
			end
		end
	end

	for k,v in pairs(self.effect_limit_list) do
		if v.invalid_time > 0 and now_time >= v.invalid_time then
			if v.cur_num > 0 then
				v.cur_num = v.cur_num - 1
				v.invalid_time = 0
			end
		end 
	end
end
