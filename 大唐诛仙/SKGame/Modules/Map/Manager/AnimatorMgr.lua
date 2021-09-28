-- 动作管理器
AnimatorMgr = BaseClass()
function AnimatorMgr:__init( animator, actor, defaultAction)
	self.actor = actor
	self.animator = animator
	self.loop = false
	self.isTimer = false -- 是否计时
	self.loopTime = 0 -- 循环时间
	self.endCallBack = nil -- 设置当前动作结束回调
	self.timeEndCallback = nil -- 时间定时触发
	self.defaultAction = defaultAction or "idle"
	self.curAction = self.defaultAction
	self.isPlaying = false
	self.isPause = false -- 是否暂停
	self.curPriority = -1 --当前动作优先级(ps:执行完(循环|非循环)动作后自动重置为-1)
	self.isDiePlaying = false -- 是否死亡动作中
	self.actCallMap=""
end

function AnimatorMgr:SetMainName( name, isMainRole )
	self.name = name
	self.isMainRole = isMainRole
end

function AnimatorMgr:SetDefaultAction( act )
	self.defaultAction = act
end

function AnimatorMgr:_hasBody() -- 是否有主体
	return self.actor and self.actor.guid and not ToLuaIsNull(self.animator)
end

--播放
--@param action 动作名
--@param normalizedTime 归一化时间 
--@param cb 动作播完后的回调函数(ps:该回调函数必须包含一个其他动作的执行，否则动作卡死)
function AnimatorMgr:Play(action, normalizedTime, cb) 
	self.isDiePlaying = false
	if not self.isPlaying then
		self:Start()
	end
	if self:_hasBody() and action then
		if self.curAction == action and self.loop then return  end

		--一般的，优先级高的动作才可以打断优先级低的动作，但“idle”、“run”这几个动作可以忽略优先级比较直接任意切换
		local priority = BehaviourMgr.GetActionPriority( action )
		if self.curAction ~= "" then
			local comparePriority = true
			if (self.curAction == "idle" and action == "run") or (self.curAction == "run" and action == "idle") then
				comparePriority = false
			end
			if comparePriority and priority < self.curPriority then
				return 
			end
		end 
		self.curPriority = priority
		self.isPause = false
		self.timeEndCallback = nil
		self.endCallBack = nil
		self:_SetAction(action)

		normalizedTime = normalizedTime or 0
		if normalizedTime<0 then		
			self.animator:CrossFade(action, 0.08, 0, 0)
		else
			if pcall(function () self.animator:GetCurrentAnimatorStateInfo(0) end) then
				info = self.animator:GetCurrentAnimatorStateInfo(0)
			else
				self:Destroy()
				return
			end
			local transTime = 0.08
			if not ToLuaIsNull(info) and (info:IsName("attack_01") or info:IsName("attack_02") or info:IsName("attack_03")) and action == "idle" then
				transTime = 0.27
				if (info:IsName("idle") and (action == "attack_02" or action == "attack_03")) then
					transTime = 0
				end
			end
			self.animator:CrossFade(action, transTime, 0, normalizedTime)
		end
	end
	self:SetEndCallback(cb)
end

function AnimatorMgr:CrossFade(action, transitionDuration, normalizedTime) -- 过渡播放
	self.isDiePlaying = false
	if self:_hasBody() and action then
		if self.curAction == action and self.loop then return end
		self.actor.curSkillId = 0
		self.isPause = false
		self.timeEndCallback = nil
		self.endCallBack = nil
		self:_SetAction(action)
		normalizedTime = normalizedTime or 0
		if normalizedTime<0 then
			self.animator:CrossFade(action, transitionDuration or 0, 0, 0)
		else
			-- self.animator:CrossFade(action, transitionDuration or 0, 0, normalizedTime)
			if pcall(function () self.animator:GetCurrentAnimatorStateInfo(0) end) then
				info = self.animator:GetCurrentAnimatorStateInfo(0)
			else
				self:Destroy()
				return
			end
			local transTime = transitionDuration or 0
			if info and (info:IsName("attack_01") or info:IsName("attack_02") or info:IsName("attack_03")) and action == "idle" then
				transTime = 0.27
				if info and (info:IsName("idle") and (action == "attack_02" or action == "attack_03")) then
					transTime = 0
				end
			end
			self.animator:CrossFade(action, transTime, 0, normalizedTime)
		end
	end
end

function AnimatorMgr:_SetAction(action) -- 动作设置处理
	self.isTimer = false
	self.loop = BehaviourMgr.IsLoop(action)
	self.curAction = action
	self.actCallMap = action
end

function AnimatorMgr:Update() -- 注册进去Update中
	if not self:_hasBody() or self.isPause or not self.isPlaying then return end
	local ani = self.animator
	if ToLuaIsNull(ani) then return end
	local info = nil
	if pcall(function () ani:GetCurrentAnimatorStateInfo(0) end) then
		info = ani:GetCurrentAnimatorStateInfo(0)
	else
		self:Destroy()
		return
	end
	if not self.isDiePlaying and self.actor:IsDie() then
		self.isDiePlaying = true
		if not ToLuaIsNull(info) and info.normalizedTime>8.9 then
			pcall(function () ani:CrossFade("die", 0, 0, 1) end)
			return
		else
			pcall(function () ani:Play("die") end)
			return
		end
	end
	self.loopTime = self.loopTime - Time.deltaTime
	if not ToLuaIsNull(info) and info:IsName(self.actCallMap) then
		if info.normalizedTime >= 0.9 then
			if self.loop then
				if self.isTimer and self.loopTime < 0 then
					self.isTimer = false
					
					if self.timeEndCallback then
						self.curPriority = -1
						self:timeEndCallback(self.curAction, self.actor)
						self.timeEndCallback = nil
					end
					return
				else
					ani:Play(self.curAction)
				end
			else
				if self.endCallBack then
					self.curPriority = -1
					self:endCallBack(self.curAction, self.actor)
				else
					if self.actor.isLivingThing then
						if not self.actor:IsDie() then
							self:CrossFade(self.defaultAction, 0.08, 0)
						end
					else
						self:CrossFade(self.defaultAction, 0.08, 0)
					end
				end
				return
			end
		end
	
		if self.isTimer and self.loopTime < 0 then
			self.isTimer = false
			if self.timeEndCallback then
				self.curPriority = -1
				self:timeEndCallback(self.curAction, self.actor)
				self.timeEndCallback = nil
			end
		end
	end
end

--立即回调
function AnimatorMgr:NowEndCallBack()
	if self.endCallBack then
		self.curPriority = -1
		self:endCallBack(self.curAction, self.actor)
	end
end

function AnimatorMgr:Reset()
	self.curPriority = -1
end

-- 在time时间内重复播放action动作
function AnimatorMgr:PlayByTime(action, time, cb)
	if not self.isPlaying then
		self:Start()
	end

	if self:_hasBody() and action then
		if self.curAction == action and self.loop then return end 
		self.timeEndCallback = nil
		self.endCallBack = nil
		self:_SetAction(action)
		self.animator:Play(action)
		self.loopTime  = time or 0
		self.isTimer = self.loopTime > 0
		self.loop = true
		self.timeEndCallback = cb
		if cb == nil then
			error("AnimatorMgr:PlayByTime() 接口 cb回调函数不能为空")
		end
	end
end
-- 中途打断time时间内重复动作
function AnimatorMgr:StopTimerByAction( action )
	if self:_hasBody() then
		if not self.actor:IsDie() then
			self:CrossFade(action or self.defaultAction, 0.1, 0)
		end
	end
end

function AnimatorMgr:Pause() -- 暂停动作
	if not self:_hasBody() then return end
	self.isPause = true
	self:SetSpeed(0)
end
function AnimatorMgr:Continue() -- 继续动作
	if not self:_hasBody() then return end
	self.isPause = false
	self:SetSpeed(1)
end

function AnimatorMgr:SetEndCallback( cb ) -- 设置当前动作结束回调
	self.endCallBack = cb
end

function AnimatorMgr:IsName( action ) -- 是否当前在播指定动作名
	if not self:_hasBody() or not action then return false end
	local ani = self.animator
	local info = ani:GetCurrentAnimatorStateInfo(0)
	return info:IsName(action)
end

function AnimatorMgr:GetAnimator() -- 动画器

	return self.animator
end

function AnimatorMgr:GetTransform() -- 对象 transform
	if self:_hasBody() then
		return self.animator.transform
	end
	return nil
end

function AnimatorMgr:GetGameObject() -- 对象 gameObject
	if self:_hasBody() then
		return self.animator.gameObject
	end
	return nil
end

function AnimatorMgr:GetActor() -- 动作 lua 主体对象
	
	return self.actor
end

function AnimatorMgr:SetSpeed(v)
	if not self:_hasBody() then return end
	self.animator.speed = v
end

function AnimatorMgr:SetBool( key, value )
	if not self:_hasBody() then return end
	self.animator:SetBool(key, value)
end

function AnimatorMgr:SetFloat( key, value )
	if not self:_hasBody() then return end
	self.animator:SetFloat(key, value)
end

function AnimatorMgr:SetInteger(key, value)
	if not self:_hasBody() then return end
	self.animator:SetInteger(key, value)
end

function AnimatorMgr:SetTrigger(key)
	if not self:_hasBody() then return end
	self.animator:SetTrigger(key)
end

function AnimatorMgr:Start()
	self.isPlaying = true
	RenderMgr.Add(function() self:Update() end, self)
end

function AnimatorMgr:Stop()
	RenderMgr.Remove(self)
	self.isPlaying = false
end

function AnimatorMgr:__delete()
	-- log("AnimatorMgr.Destroy............................."..self.name)
	self:Stop()
	self.animator = nil
	self.loop = nil
	self.actor = nil
	self.loopTime = 0
	self.endCallBack = nil
	self.timeEndCallback = nil
	self.isTimer = nil
	self.curAction = nil
	-- print("清除",self.name)
end