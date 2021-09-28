AbsBuff = class("AbsBuff")

AbsBuff.StartEffectTime = 1;
local insert = table.insert

function AbsBuff:New(info, castRole)
	self = {};
	setmetatable(self, {__index = AbsBuff});
	self:_Init(info, castRole);
	return self;
end

function AbsBuff:_Init(info, castRole)
	self.info = info;
	-- 叠加层数
	self.overlap = 1;
	self._castRole = role;
	self._buffEffects = {};
	self._actionNum = table.getCount(info.action_id);
	self._actionIndex = 1
	self._isLooped = false;
	self._effStarTime = self.info.start_time / 1000;
	self._handPoint = {}
end

function AbsBuff:GetScript()
	return self.info and self.info.script or nil
end
function AbsBuff:GetLevel()
	return self.info and self.info.level or 0
end
function AbsBuff:GetName()
	return self.info and self.info.name or ""
end
function AbsBuff:GetId()
	return self.info and self.info.id or 0
end
function AbsBuff:GetCoolTime()
	return self.curCoolTime
end

-- 设置释放者
function AbsBuff:SetCaster(caster)
	self._caster = caster;
	if(caster ~= nil and(not caster:IsDie()) and caster ~= self._role and self.info.special_effecttype ~= "") then
		local extraEffect = SkillExecuteManage.ExecuteLinkEffect(caster, self._role, self.info.special_effecttype);
		self:AddExtraEffect(extraEffect);
	end
end

function AbsBuff:AddExtraEffect(effect)
	if(effect ~= nil) then
		if(self._extraEffects == nil) then
			self._extraEffects = {};
		end
		insert(self._extraEffects, effect);
	end
end

function AbsBuff:ResetEffectPos()
	if(self._buffEffects ~= nil) then
		local info = self.info
		local role = self._role;
		for i, v in pairs(info.effect_pos) do
			local hp = self:GetHandPoint(i, v);
			local eff = self._buffEffects[i];
			if(eff and eff.transform) then
				eff.transform:SetParent(hp);
				Util.SetLocalPos(eff.transform, 0, 0, 0)
				--                eff.transform.localPosition = Vector3.zero;
			end
		end
	end
end

function AbsBuff:_ClearCurrentEffects()
	if(self._buffEffects) then
		for i, v in pairs(self._buffEffects) do
			Resourcer.Recycle(v);
			v = nil
		end
		self._buffEffects = {};
	end
end

function AbsBuff:_InitStartEffect()
	local role = self._role;
	local info = self.info
	local scale = role.transform.localScale.x;
	self._buffEffects = {};
	if(info.start_id ~= "") then
		for i, v in pairs(info.effect_pos) do
			local hp = self:GetHandPoint(i, v);
		 
			local eff = Resourcer.Get("Effect/BuffEffect", info.start_id);
			if(eff and eff.transform) then
				eff.transform:SetParent(hp);
				--                eff.transform.localPosition = Vector3.zero;
				Util.SetLocalPos(eff.transform, 0, 0, 0)
				
				UIUtil.ScaleParticleSystem(eff, scale);
				self._buffEffects[i] = eff;
			end
		end
	end
end

function AbsBuff:_InitLoopEffect()
	local role = self._role;
	local info = self.info
	local scale = role.transform.localScale.x;
	self:_ClearCurrentEffects();
	self._isLooped = true;
	
	if(info.effect_id ~= "") then
		for i, v in pairs(info.effect_pos) do
			local hp = self:GetHandPoint(i, v);
			local eff = Resourcer.Get("Effect/BuffEffect", info.effect_id);
		 
			if(eff and eff.transform) then
				if(self:IsBuffFollowRotate()) then
					eff.transform:SetParent(hp);
					Util.SetLocalPos(eff.transform, 0, 0, 0)
					Util.SetLocalRotation(eff,0,0,0)
				end
				
				-- eff.transform.localPosition = Vector3.zero;
				UIUtil.ScaleParticleSystem(eff, scale);
				self._buffEffects[i] = eff;
			end
		end
	end
end

function AbsBuff:_InitEndEffect()
	local role = self._role;
	if(role.transform) then
		local info = self.info
		local scale = role.transform.localScale.x;
		self:_ClearCurrentEffects();
		if(info.end_id ~= "") then
			for i, v in pairs(info.effect_pos) do
				local hp = self:GetHandPoint(i, v);
				local eff = Resourcer.Get("Effect/BuffEffect", info.end_id);
				 
				if(eff and eff.transform) then
					eff.transform:SetParent(hp);
					Util.SetLocalPos(eff.transform, 0, 0, 0)
					
					--                eff.transform.localPosition = Vector3.zero;
					UIUtil.ScaleParticleSystem(eff, scale);
					Resourcer.RecycleDelay(eff, self.info.end_time / 1000);
				end
			end
		end
	end
end

function AbsBuff:_InitEffect()
	local role = self._role;
	local info = self.info
	local scale = role.transform.localScale.x;
	self._buffEffects = {};
	if(info.effect_id ~= "") then
		for i, v in pairs(info.effect_pos) do
			local hp = self:GetHandPoint(i, v);
			local eff = Resourcer.Get("Effect/BuffEffect", info.effect_id);
			if(eff and eff.transform) then
				if(self:IsBuffFollowRotate()) then
					eff.transform:SetParent(hp);
					Util.SetLocalPos(eff, 0, 0, 0)
				end
				--                eff.transform.localPosition = Vector3.zero;
				-- eff.transform.localScale = scale;
				UIUtil.ScaleParticleSystem(eff, scale);
				self._buffEffects[i] = eff;
			end
		end
	end
end

function AbsBuff:_OnTickHandler()
	if(self.running) then
		local role = self._role;
		if(role and role.transform) then
			self.curCoolTime = self.curCoolTime - Timer.deltaTime;
			if(self.curCoolTime <= 0) then
				self.curCoolTime = 0;
				self:_OnTimerCompleteHandler();
				return;
			else
				self:_OnBaseTimerHandler()
			end
			if(not self._isLooped) then
				self._effStarTime = self._effStarTime - Timer.deltaTime;
				if(self._effStarTime <= 0) then
					self:_InitLoopEffect();
				end
			end
			if(self._hasAction) then
				
				local actInfo = role:GetAnimatorStateInfo();
				if(actInfo and actInfo:IsName(self.info.action_id[self._actionIndex]) and actInfo.normalizedTime > 0.9) then
					self._actionIndex = self._actionIndex + 1;
					if(self._actionIndex <= self._actionNum and self.info.action_id[self._actionIndex] ~= "") then
						role:Play(self.info.action_id[self._actionIndex]);
					end
				end
			end
		else
			self:Stop();
		end
	end
end

function AbsBuff:_OnBaseTimerHandler()
	if(self._role) then
		if(not self:IsBuffFollowRotate() and self._buffEffects) then
			for k, v in ipairs(self._buffEffects) do
				if(v) then
					Util.SetPos(v, self._handPoint[k].position)
				end
			end
		end
	end
	self:_OnTimerHandler();
end

function AbsBuff:_OnTimerHandler()
	
end

function AbsBuff:_OnTimerCompleteHandler()
	self:Stop();
end

function AbsBuff:_OnStartHandler()
	
end


function AbsBuff:_OnStopHandler()
	
end

function AbsBuff:SetOverlap(overlap)
	if(self.info.add_type == 1) then
		local ol = overlap or 1;
		self.overlap = ol;
	end
end

function AbsBuff:SetController(controller)
	self._buffController = controller;
end

function AbsBuff:Start(role)
	local info = self.info;
	self._role = role;
	self:_OnStartHandler();
	if(info.start_id ~= "") then
		self:_InitStartEffect();
		-- else
		-- self:_InitEffect();
	end
	self.running = true;
	
	if(info.action_id[self._actionIndex] and info.action_id[self._actionIndex] ~= "") then
		role:Play(info.action_id[self._actionIndex]);
		self._hasAction = true;
	else
		self._hasAction = false;
	end
	self.totalTime = info.time / 1000;
	self:Reset(info.time, 1);
end

function AbsBuff:Reset(time)
	if(time) then
		self.curCoolTime = time / 1000;
		if(self._timer == nil) then
			self._timer = Timer.New(function(val) self:_OnTickHandler(val) end, 0, - 1, false);
			self._timer:Start();
		end
	end
	-- print("======id:" .. self._role.id .. "   buff:" .. self.info.name .. "   overlap:" .. self.overlap .. "======")
end

function AbsBuff:Stop()
	if(self.running) then
		self.running = false;
		--self:_InitEndEffect();
		self:_OnStopHandler();
		if(self._timer) then
			self._timer:Stop();
			self._timer = nil;
		end
		if(self._extraEffects) then
			for i, v in pairs(self._extraEffects) do
				v:Dispose();
				v = nil;
			end
			self._extraEffects = nil;
		end
		if(self._buffEffects) then
			
			for i, v in pairs(self._buffEffects) do
				Resourcer.Recycle(v);
				v = nil
			end
			self._buffEffects = nil;
		end
		if(self._buffController) then
			self._buffController:RemoveBuff(self.info.id, false);
			self._buffController = nil;
		end
		self._castRole = nil;
		self._role = nil;
	end
end

function AbsBuff:SetActive(enable)
	if(self._buffEffects) then
		for i, v in pairs(self._buffEffects) do
			v:SetActive(enable)
		end
	end
end

function AbsBuff:IsBuffFollowRotate()
	return self.info.isfollowRotate
end

-- 上坐骑的时候是否隐藏 true为隐藏 false为不隐藏
function AbsBuff:IsDisapper()
	return self.info.isDisapper
end

function AbsBuff:GetHandPoint(i, v)
	if(self._handPoint[i] == nil) then
		self._handPoint[i] = self._role:GetHangingPoint(v)
	end
	
	return self._handPoint[i]
end
