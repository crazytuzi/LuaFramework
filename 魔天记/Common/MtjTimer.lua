AbsTimer = {}
function AbsTimer:AddCompleteListener(func)
    self.completeFunc = func;
end

function AbsTimer:RemoveCompleteListener()
    self.completeFunc = nil;
end

function AbsTimer:Reset(func, duration, loop, scale)
	self.duration 	= duration
	self.loop		= loop or 1
	self.scale		= scale
	self.func		= func
	self.time		= duration
	self.running	= false
	self.count		= Time.frameCount + 1
end
function AbsTimer:ResetDuration(duration)
    self.time = duration
end
 
function AbsTimer:CutTime(cutVal)
	self.time = self.time - cutVal
end

function AbsTimer:GetRemainTime()
	return self.time
end

function AbsTimer:_GetDeltaTime()
    return Time.deltaTime;
end

function AbsTimer:Pause(val)
    self.pauseing = val
end

function AbsTimer:Update()
	if self.pauseing then return end

	local delta = self.scale and self:_GetDeltaTime() or Time.unscaledDeltaTime	
	self.time = self.time - delta
	
	if self.time <= 0 and Time.frameCount > self.count then
        if GameSceneManager.debug then Profiler.BeginSample(self.name or 'AbsTimer.Update') end
		self.func()
        if GameSceneManager.debug then Profiler.EndSample() end
		if self.loop > 0 then
			self.loop = self.loop - 1
			self.time = self.time + self.duration
		end
		
		if self.loop == 0 then
			self:Stop()
            if (self.completeFunc) then  
                self.completeFunc()
            end
		elseif self.loop < 0 then
			self.time = self.time + self.duration
		end
	end
end


-------------------------Timer------------------------------
--scale false 采用deltaTime计时，true 采用 unscaledDeltaTime计时
--循环次数loop
Timer = class("Timer", AbsTimer)
Timer.deltaTime = 0;
function Timer.New(func, duration, loop, scale)
	local timer = {}
	scale = scale or false and true
	setmetatable(timer, { __index = Timer });
	timer:Reset(func, duration, loop, scale)

    if GameSceneManager.debug then timer.name = GetClassFuncName(3)  end --print(timer.name)
	return timer
end 

function Timer:Start()
    if self.running then Error("start two" .. tostring(self.name)) return end
	self.running = true	
   	UpdateBeat:Add(self.Update, self)
    return self
end

function Timer:Stop()
     if (self.running) then
        UpdateBeat:Remove(self.Update, self)
        self.running = false;
     end
end
-------------------------FixedTimer------------------------------
--scale false 采用deltaTime计时，true 采用 unscaledDeltaTime计时
--循环次数loop
FixedTimer = class("FixedTimer", AbsTimer)
function FixedTimer.New(func, duration, loop, scale)
	local timer = {}
	scale = scale or 1;
	setmetatable(timer, { __index = FixedTimer });
	timer:Reset(func, duration, loop, scale)

    if GameSceneManager.debug then timer.name = GetClassFuncName(3)  end --print(timer.name)
	return timer
end

function FixedTimer:_GetDeltaTime()
    return Time.fixedDeltaTime;
    --return Timer.deltaTime;
end

function FixedTimer:Start()
    if self.running then Error("start two" .. tostring(self.name)) return end
	self.running = true
    FixedUpdateBeat:Add(self.Update, self)
    return self
end

function FixedTimer:Stop()
    if (self.running) then       
        FixedUpdateBeat:Remove(self.Update, self)
         self.running = false;
    end
end

function FixedTimer:Update()
	if self.pauseing then return end

	local delta = self:_GetDeltaTime()
	self.time = self.time - delta	
	if self.time <= 0 then
        if GameSceneManager.debug then Profiler.BeginSample(self.name or 'FixedTimer.Update') end
		self.func(self.duration - self.time)	
        if GameSceneManager.debug then Profiler.EndSample() end
		if self.loop > 0 then
			self.loop = self.loop - 1
			self.time = self.time + self.duration
		end		
		if self.loop == 0 then
			self:Stop()
            if (self.completeFunc) then  
                self.completeFunc()
            end
		elseif self.loop < 0 then
			self.time = self.time + self.duration
		end
	end
end


-------------------------CoTimer------------------------------
--一直循环
CoTimer = class("CoTimer", AbsTimer)
function CoTimer.New(func, duration, loop)
	local timer = {}
	scale = scale or false and true
	setmetatable(timer, { __index = CoTimer });
	timer:Reset(func, duration, loop, scale)
	return timer
end

function CoTimer:Start()
    if self.running then Error("start two" .. tostring(self.name)) return end
	self.running = true
    CoUpdateBeat:Add(self.Update, self)
    return self
end

function CoTimer:Stop()
    if (self.running) then        
        CoUpdateBeat:Remove(self.Update, self)
        self.running = false
    end
end

function CoTimer:Update()
	if self.pauseing then return end

	if self.time <= 0 and Time.frameCount > self.count then
		self.func()		
		
		if self.loop > 0 then
			self.loop = self.loop - 1
			self.time = self.time + self.duration
		end
		
		if self.loop == 0 then
			self:Stop()
		elseif self.loop < 0 then
			self.time = self.time + self.duration
		end
	end
	
	self.time = self.time - Time.deltaTime
end

-------------------------FrameTimer------------------------------
--给协同使用的帧计数timer
FrameTimer = class("FrameTimer", AbsTimer)
function FrameTimer.New(func, count, loop)
	local timer = {}	
    setmetatable(timer, { __index = FrameTimer });
	timer.count = Time.frameCount + count
	timer.duration = count
	timer.loop	= loop
	timer.func	= func
	return timer
end

function FrameTimer:Start()	
    if self.running then Error("start two" .. tostring(self.name)) return end
	self.running = true
	CoUpdateBeat:Add(self.Update, self)
    return self
end

function FrameTimer:Stop()	
    if (self.running) then        
	    CoUpdateBeat:Remove(self.Update, self)
        self.running = false
    end
end

function FrameTimer:Update()	
	if self.pauseing then return end
	
	if Time.frameCount >= self.count then
		self.func()	
		
		if self.loop > 0 then
			self.loop = self.loop - 1
		end
		
		if self.loop == 0 then
			self:Stop()
		else
			self.count = Time.frameCount + self.duration
		end
	end
end