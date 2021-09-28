AbsEffect = class("AbsEffect")
AbsEffect.asyncLoadSource = true -- 异步加载资源

function AbsEffect:New(skill, stage, caster, target)
	self = {};
	setmetatable(self, {__index = AbsEffect});
	self:_Init(skill, stage, caster, target);
	return self;
end

function AbsEffect:_Init(skill, stage, caster, target)	
	self._radian = 0;
	self._sumTime = - 1;
	self._isPause = false;
	self.skill = skill
	self.stage = stage;
	self.info = self.skill.stages[stage];
	self.caster = caster;
	self.target = target;	
	if(self:_InitEffectInfo()) then
		self:_InitTimer();
		return true;
	end
	return false;
end

function AbsEffect:_InitEffectInfo()
	local effectCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL_EFFECT);
	self.effectInfo = effectCfg[self.info.effect_id];
	if(self.effectInfo) then
		self._sumTime = self.effectInfo.totalTime / 1000;
		self:_InitSkillEffect(self.caster);
		self:_InitEffectPosition();
		return true
	end
	return false
end

function AbsEffect:_InitEffectPosition()
	if(self.info.range_type == 6 and self.target and self.target.transform) then
		Util.SetPos(self.transform, self.target.transform.position)
		--        self.transform.position = self.target.transform.position
	end
end

function AbsEffect:SetRadian(radian)
	self._radian = radian / 180 * math.pi;
end

function AbsEffect:SetSumTime(val)
	self._sumTime = val;
end

function AbsEffect:AddListener(func)
	self._callback = func;
end


function AbsEffect:BindTarget(role)
	if(role ~= nil and role.transform ~= nil) then
		self.bindRole = role;
		self.bindRole:AddSkillEffect(self);
	end
end

function AbsEffect:RemoveBindTarget()
	if(self.bindRole ~= nil and self.bindRole.transform ~= nil) then
		self.bindRole:RemoveSkillEffect(self);
		self.bindRole = nil;
	end
end

function AbsEffect:Dispose()
	if(self._timer) then
		self._sumTime = nil;
		self._timer:Stop();
		self._timer = nil;
	end
	if(self.transform ~= nil) then
		self:_OnDisposeHandler();
		self:RemoveBindTarget();
		if(self._effGameObject ~= nil) then
			Resourcer.Recycle(self._effGameObject, true);
			self._effGameObject = nil;			
		end
		if not IsNil(self._entityGameObject) then
			GameObject.Destroy(self._entityGameObject)
			self._entityGameObject = nil
		end
		if(self._callback) then
			self._callback(self);
			self._callback = nil;
		end;
		self.transform = nil;
		self.skill = nil
		self.stage = nil;
		self.info = nil;
		self.caster = nil;
		self.target = nil;
	end
end

function AbsEffect:_OnDisposeHandler()
	
end

function AbsEffect:_PlayerEffectSound(name)
	if(name ~= nil and name ~= "" and self.transform) then
		SoundManager.instance:PlayAudioByGameObject(self.transform.gameObject, name);
	end
end

function AbsEffect:_OnLoadCompleteHandler(go, toRole)
	if(go) then
		local toTransform = toRole.transform
		local transform = go.transform;
		local offect = Vector3.New(self.effectInfo.x / 100, self.effectInfo.y / 100, self.effectInfo.z / 100);
		local scale = toTransform.localScale
		
		--        transform.position = toTransform:TransformPoint(offect)
		Util.SetPos(transform, toTransform:TransformPoint(offect))
		--transform.rotation = Quaternion.Euler(0, toTransform.rotation.eulerAngles.y, 0);
		Util.SetRotation(transform, 0, toTransform.rotation.eulerAngles.y, 0)
		if(self.effectInfo.bind == 1) then
			transform:SetParent(toTransform);
			transform.localScale = Vector3.one;
		else
			UIUtil.ScaleParticleSystem(go, scale.x);
		end
		
		self.transform = transform;
		toTransform = nil
		go = nil
		self:_InitEffectComplete();
	end
end

function AbsEffect:_InitSkillEffect(toRole)
	local effInfo = self.effectInfo;
	if(effInfo ~= nil and(effInfo.model ~= '0' or effInfo.model ~= "") and toRole ~= nil) then
		--Warning( tostring(self.caster.id).. "___"..tostring( PlayerManager.playerId))
		if AbsEffect.asyncLoadSource then
			self._entityGameObject = GameObject.New(effInfo.model);
			self:_OnLoadCompleteHandler(self._entityGameObject, toRole, sPoint);
			 
			Resourcer.GetAsync("Effect/SkillEffect", effInfo.model, self._entityGameObject.transform, System.Action_UnityEngine_GameObject(function(go)
				--Warning( tostring(self.caster.id).. "___"..tostring(effInfo.model)..tostring(go))
				if self.transform == nil then
					Resourcer.Recycle(go, true);
					return
				end
				self._effGameObject = go
				if(self._effGameObject) then
					local sumTime = UIUtil.GetParticleSystemLength(self._effGameObject.transform);
                     
					if(sumTime == - 1) then
						self._sumTime = self.effectInfo.totalTime / 1000;						
					else
						self._sumTime = sumTime;
					end
				 
					--self._sumTime = self.effectInfo.totalTime / 1000;
					NGUITools.SetLayer(self._effGameObject, Layer.Effect)
				end
			end))
		else			
			self._effGameObject = Resourcer.Get("Effect/SkillEffect", effInfo.model);
			if(self._effGameObject) then
				local sumTime = UIUtil.GetParticleSystemLength(self._effGameObject.transform);
				if(sumTime == - 1) then
					self._sumTime = self.effectInfo.totalTime / 1000;
					
				else
					self._sumTime = sumTime;
				end
				--self._sumTime = self.effectInfo.totalTime / 1000;
				NGUITools.SetLayer(self._effGameObject, Layer.Effect)
			end
			self:_OnLoadCompleteHandler(self._effGameObject, toRole, sPoint);
		end
		self:_PlayerEffectSound(effInfo.sound);
	end
end

function AbsEffect:_InitEffectComplete()
	
end

function AbsEffect:_DoShake()
	local skill = self.skill;
	local role = self.role;
	if(role == HeroController.GetInstance() and skill.knock_back_ID ~= 0) then
		local knockInfo = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_KNOCKBACK) [skill.knock_back_ID];
		if(knockInfo) then
			local skock = knockInfo.shock;
			if(skock > 0) then
				MainCameraController.GetInstance():Shake(skock);
			end
		end
	end
end


function AbsEffect:_InitTimer()
	if(self._timer == nil) then		
		self._timer = FixedTimer.New(function(val) self:_OnTickHandler(val) end, 0, - 1, false);
		self._timer:Start();
	end	
end;

function AbsEffect:Pause()
	if(not self._isPause) then
		self._isPause = true;
	end
end

function AbsEffect:Resume()
	if(self._isPause) then
		self._isPause = false;
	end
end

function AbsEffect:_OnTickHandler()
	if(self._sumTime ~= nil and(not self._isPause)) then
		if(self._sumTime ~= - 1) then
			local dt = Time.fixedDeltaTime;
			self._sumTime = self._sumTime - dt;
			if(self._sumTime <= 0) then
				self:Dispose();
				self._sumTime = nil;
			else
				self:_OnTimerHandler(dt);
			end
		else
			self:_OnTimerHandler(dt);
		end
	end
end

function AbsEffect:_OnTimerHandler(delay)
	
end
