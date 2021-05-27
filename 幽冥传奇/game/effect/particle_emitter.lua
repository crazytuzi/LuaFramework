------------------------------------------------------
--粒子发射器
--@author bzw
------------------------------------------------------
ParticleEmitter = ParticleEmitter or BaseClass(ParticleEmitter)

EmitParticleNum = 0

function ParticleEmitter:__init()
	self.emit_place = nil				--发射场fo
	self.emit_rect = nil				--发射区域
	self.emit_frequency = 0.15 			--发射频率
	self.emit_num_dynamic = {15, 1, 1} 	--在同一时间发射随机数动态分布 最大数，最低几率，最高几率
	self.emit_keep_time = 10			--发射持续时间
	self.emit_rotation = 0				--发射角度
	self.emit_start_time = 0			--开启发射的时间
	self.seed_list = {}					--种子列表

	self.particle_name = nil
	self.p_move_type = nil				--粒子的运动方式
	self.p_move_param = nil	
	self.p_move_area = nil				--粒子移动区域
	self.p_move_speed = 0				--粒子移动速度
	self.p_rotation_speed = 0			--粒子角速度
	self.p_random_act_list = nil 		--粒子随机动作列表

	self.max_num_in_rect = 200			--区域内同时存在最大数量（优化）
	self.pool_size = 60 				--池最大数量（优化）

	self.particle_list = {}				--发射出来的粒子列表
	self.particle_pool = {}				--粒子池
	self.is_emiting = false				--是否在发射中
	self.start_time = 0					--启动时间
	self.prve_emit_time = 0				--上次发射的时间

	self.is_emit_to_scene = false

	self.particle_lief_end_callback = BindTool.Bind1(self.ParticleLiefEnd, self)
end

function ParticleEmitter:__delete()
	for k,v in pairs(self.particle_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.particle_pool) do
		v:DeleteMe()
	end
end

--设置发射场
function ParticleEmitter:SetEmitPlace(emit_place, emit_rect, is_emit_to_scene)
	self.emit_place = emit_place
	self.emit_rect = emit_rect
	self.is_emit_to_scene = is_emit_to_scene
end

--设置开始发射的时间
function ParticleEmitter:SetEmitStartTime(emit_start_time)
	self.emit_start_time = emit_start_time
end

--设置发射频率（秒）
function ParticleEmitter:SetEmitFrequency(emit_frequency)
	self.emit_frequency = emit_frequency
end

--设置发射动态分布
function ParticleEmitter:SetEmitNumDynamic(max_num, random_min,random_max)
	self.emit_num_dynamic = {max_num, random_min, random_max}
end

--设置持续发射时间
function ParticleEmitter:SetEmitKeepTime(emit_keep_time)
	self.emit_keep_time = emit_keep_time
end

--设置发射角度
function ParticleEmitter:SetEmitRotation(emit_rotation)
	self.emit_rotation = emit_rotation
end

--设置区域同时存在最大数
function ParticleEmitter:SetMaxNumInRect(max_num_in_rect)
	self.max_num_in_rect = max_num_in_rect
end

--设置种子列表
function ParticleEmitter:SetEmitSeedList(seed_list)
	self.seed_list = seed_list
end

function ParticleEmitter:SetParticleName(particle_name)
	self.particle_name = particle_name
end

--设置粒子的运动方式
function ParticleEmitter:SetParticleMoveType(p_move_type, p_move_param)
	self.p_move_type = p_move_type
	self.p_move_param = p_move_param
end

--设置粒子的移动区域
function ParticleEmitter:SetParticleMoveArea(p_move_area)
	self.p_move_area = p_move_area
end

--设置粒子的移动速度
function ParticleEmitter:SetParticleMoveSpeed(p_move_speed)
	self.p_move_speed = p_move_speed
end

--设置粒子的角速度
function ParticleEmitter:SetParticleRotationSpeed(p_rotation_speed)
	self.p_rotation_speed = p_rotation_speed
end

--设置粒子动作列表
function ParticleEmitter:SetParticleActionRandomList(p_random_act_list)
	self.p_random_act_list = p_random_act_list
end

--开始发射粒子
function ParticleEmitter:StartEmit()
	if self.is_emiting then
		-- Log("发射器已启动，请先关闭")
		return
	end

	self.is_emiting = true
	Runner.Instance:AddRunObj(self, 1)
end

--停止发射粒子
function ParticleEmitter:StopEmit()
	if not self.is_emiting then
		-- Log("发射器未开始，请先启动发射器")
		return
	end
	self.is_emiting = false
	self.start_time = 0
	self.prve_emit_time = 0
	self:DestoryPartiles()
	Runner.Instance:RemoveRunObj(self)
end

--释放粒子
function ParticleEmitter:DestoryPartiles()
	for k,v in pairs(self.particle_pool) do
		v:DeleteMe()
	end

	for k,v in pairs(self.particle_list) do
		v:SetIsAutoDestory(true)		--还在播放的让其自己结束后自己销毁
		v:SetLiefEndCallback(nil)
	end

	self.particle_pool = {}
	self.particle_list = {}
end

--发射中
function ParticleEmitter:Update(now_time, elapse_time)
	if self.start_time == 0 then								   --记录第一次发射的时间
		self.start_time = now_time
	end

	if now_time - self.start_time < self.emit_start_time then	   --未达到开始发射的时间
		return
	end

	if self.emit_keep_time ~= 0 and now_time - self.start_time - self.emit_start_time >= self.emit_keep_time then --发射结束
		self:StopEmit()
		return
	end

	if #self.particle_list > self.max_num_in_rect then			   --超过最大数
		return
	end

	if now_time - self.prve_emit_time >= self.emit_frequency then  --发射频率
		self.prve_emit_time = now_time

		local num_rate = math.random(self.emit_num_dynamic[2], self.emit_num_dynamic[3])
		local emit_num = math.ceil(num_rate / 100 * self.emit_num_dynamic[1])
		for i=1,emit_num do
			local particle = self:CreateParticle(self:GetRandomSeed())
			particle:SetIsAutoDestory(false) --不自行销毁
			self:EmitParticle(particle)
		end
	end
end

--获得一个随机种子
function ParticleEmitter:GetRandomSeed()
	local total = 0
	for k,v in pairs(self.seed_list) do
		v.start_value = 0
		total = total + v.power
		v.end_value = total
	end
	local random_value = math.random(0, total)
	for k,v in pairs(self.seed_list) do
		if random_value >= v.start_value and random_value <= v.end_value then
			return v
		end
	end
	return self.seed_list[1]
end

--创建单个粒子
function ParticleEmitter:CreateParticle(seed)
	local particle = nil
	if #self.particle_pool > 0 then 	--从池里取
		particle = self.particle_pool[#self.particle_pool]
		self.particle_pool[#self.particle_pool] = nil
	else
		particle = Particle.New() 		--创建新的粒子
	end

	if seed.seed_type == "animation" then
		local anim_path, anim_name = ResPath.GetEffectAnimPath(seed.seed_id)
		particle:SetAnimation(anim_path, anim_name, 1)
	elseif seed.seed_type == "animation_mount" then
		local anim_path, anim_name = ResPath.GetMountAnimPath(seed.seed_id, seed.action_name, seed.dir)
		particle:SetAnimation(anim_path, anim_name, 100)
	elseif seed.seed_type == "texture" then
		particle:SetTexture(seed.seed_path)
	end

	particle:SetScale((seed.scale or 1))
	particle:SetOpacity((seed.opacity or 255))

	EmitParticleNum = EmitParticleNum + 1
	particle:SetParticleId(EmitParticleNum)
	particle:SetParticleName(self.particle_name)

	return particle
end

--发射粒子
function ParticleEmitter:EmitParticle(particle)
	local pos_x = GameMath.Rand(self.emit_rect.x, self.emit_rect.x + self.emit_rect.width)
	local pos_y = GameMath.Rand(self.emit_rect.y, self.emit_rect.y + self.emit_rect.height)

	if self.emit_place == nil or self.emit_place ==  HandleRenderUnit:GetCoreScene() then
		if self.is_emit_to_scene then
			local scene_view_rect = HandleRenderUnit:GetCoreScene():GetViewRect()
			pos_x = scene_view_rect.x + pos_x
			pos_y = scene_view_rect.y + pos_y
			HandleRenderUnit:GetCoreScene():addChildToRenderGroup(particle:GetSprite(), GRQ_SCENE_OBJ)
		else
			HandleRenderUnit:AddUi(particle:GetSprite(), COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
		end
	else 
		self.emit_place:addChild(particle:GetSprite(), 1000,1000)
	end

	self.particle_list[#self.particle_list + 1] = particle

	particle:SetLiefEndCallback(self.particle_lief_end_callback)
	particle:SetMoveRect(self.p_move_area)
	particle:SetRotationSpeed(self.p_rotation_speed)
	particle:SetMoveSpeed(self.p_move_speed)
	particle:SetMoveType(self.p_move_type, self.p_move_param)

	if self.p_random_act_list ~= nil then
		local act_name = self.p_random_act_list[GameMath.Rand(1, #self.p_random_act_list)]
		particle:SetParticleActName(act_name)
	end


	particle:Emited(pos_x, pos_y)
end

--粒子生命结束
function ParticleEmitter:ParticleLiefEnd(particle)
	for k,v in pairs(self.particle_list) do
		if v == particle then
			self.particle_list[k] = nil
			break
		end
	end
	if #self.particle_pool < self.pool_size then
		table.insert(self.particle_pool, particle)
	end
end
