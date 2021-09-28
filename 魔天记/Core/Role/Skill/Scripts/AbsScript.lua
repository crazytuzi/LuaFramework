AbsScript = class("AbsScript")

function AbsScript:SetStage(stage)
	self.isFinish = false
	if (stage) then
		self._stage = stage;		
		self._role = stage.role;
		self._effect = stage.effect        
		self:_Init(self._role, stage.info.para);
	end
end

function AbsScript:IsPaused()
	return self._isPaused or false;
end

-- 暂停动作
function AbsScript:Pause()
	self._isPaused = true;
end

-- 恢复执行动作
function AbsScript:Resume()
	self._isPaused = false
end

function AbsScript:AddListener(func)
	self._callback = func;
end

function AbsScript:_OnDisposeHandler()

end

function AbsScript:Dispose()
    self.isFinish = true
    if (self._timer ~= nil) then
        self._timer:Stop();
        self._timer = nil;
    end
    self:_OnDisposeHandler();
    if (self._callback) then
        self._callback(self);
        self._callback = nil;        
    end;
    self._stage = nil;
    self._role = nil;
    self._effect = nil;
end

function AbsScript:_Init(role, para)

end

-- 初始化心跳
function AbsScript:_InitTimer(duration, loop)
	if (self._timer == nil) then    
		self._timer = FixedTimer.New( function(val) self:_OnTikcHandler(val) end, duration, loop, false);
        self._timer:Start();
	end	
end;

function AbsScript:_OnTimerHandler()
	
end

function AbsScript:_OnTikcHandler()
--	if (self:IsPaused()) then
--		return;
--	end
	local role = self._role;
	if (role ~= nil and role.transform ~= nil and(not role:IsDie())) then
		if (not role:isPaused()) then
			self:_OnTimerHandler();
		end
	else
		self:Dispose();
	end    
end