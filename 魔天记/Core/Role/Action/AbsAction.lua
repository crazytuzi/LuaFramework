ActionType = {
	NORMAL = 1;-- 默认
	BLOCK = 2;-- 阻塞
	SIMILARBLOCK = 3;-- 同类阻塞
	COOPERATION = 4;-- 协同
	
}

AbsAction = class("AbsAction")
AbsAction.actionType = ActionType.NORMAL;
AbsAction.isPauseMainAction = false;
AbsAction._controller = nil;
AbsAction._callback = nil;
AbsAction._timer = nil;

ActionEvent = {
	EVENT_ACTIONSTOP = "EVENT_ACTIONSTOP";
	EVENT_ACTIONFINISH = "EVENT_ACTIONFINISH";
}

function AbsAction:New()
	self = {};
	setmetatable(self, {__index = AbsAction});	
	return self;
end

function AbsAction:Init()
	self._running = false;
	self._finished = false;
	self._isStop = false;
end

-- 执行动作
function AbsAction:Start(controller, callback)
	if(controller and not RoleController:IsDie()) then
		self._running = true;
		self:_SetController(controller);
		self._callback = callback;		
		self:_OnStartHandler();
		self:_DispatchStartEvent();
	else
		self:Stop();
	end
end

function AbsAction:IsFinished()
	return self._finished;
end

function AbsAction:AddEventListener(owner, finishFunc, stopFunc)
	self._owner = owner;
	self._finishFunc = finishFunc;
	self._stopFunc = stopFunc
end

-- 动作完成
function AbsAction:Finish()
	if(self._running and(not self._finished)) then
		self.actionType = ActionType.NORMAL;
		self._finished = true;
		if(self._owner and self._finishFunc) then
			self._finishFunc(self._owner);
			self._owner = nil;
			self._finishFunc = nil;
		end
		self:_OnFinishHandler();
		self:Stop();
	end
end

-- 停止动作
function AbsAction:Stop()
	if(not self._isStop) then
		self:Pause();
		self._running = false;
		self._isStop = true;
		self:_OnStartRemoveListenerHandler();
		self:_OnStopHandler();
		
		self._controller = nil;
	end
	if(self._owner and self._stopFunc) then
		self._stopFunc(self._owner);
		self._stopFunc = nil;
		self._owner = nil;
	end
	if(self._timer) then            
		self._timer:Stop();
		self._timer = nil;
	end
	if(self._callback) then
		self._callback(self);
		self._callback = nil;
	end;
end

function AbsAction:Dispose()
	self:_Dispose()
end


-- 暂停动作
function AbsAction:Pause()
	if(self._timer) then
		self._timer:Pause(true);
	end
end

-- 恢复执行动作
function AbsAction:Resume()
	if(self._timer) then
		self._timer:Pause(false);
	end
end

-- 距离
function AbsAction:DistanceXY(x1, y1, x2, y2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2));
end

function AbsAction:DistanceVector2(p1, p2)
	if(p1 and p2) then
		return math.sqrt(math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2));
	end
	return 0;
end

function AbsAction:_DispatchStartEvent()
	
end

function AbsAction:_DispatchStopEvent()
	
end

function AbsAction:_SetController(controller)
	self._controller = controller;
	self._roleServerType = self:_GetRoleToServerType(controller);
end

function AbsAction:_GetRoleToServerType(role)
	
	
	if(role.__cname == "HeroController" or role.__cname == "PlayerController" or role.__cname == "MountLangController") then
		return 1;
	elseif(role.__cname == "HeroController") then
		return 2;
	elseif(role.__cname == "PetController" or role.__cname == "HeroPetController") then
		return 3;
	elseif(role.__cname == "PuppetController" or role.__cname == "HeroPuppetController") then
		return 4;
	elseif(role.__cname == "HeroGuardController") then
		return 6;
	elseif(role.__cname == "HirePlayerController") then
		return 7;
	end
	return 0;
end

-- 初始化心跳
function AbsAction:_InitTimer(duration, loop)
	if(self._timer == nil) then 
		self._timer = FixedTimer.New(function(val) self:_OnTickHandler(val) end, duration, loop, false);
		self._timer:AddCompleteListener(function(val) self:_OnTimerCompleteHandler(val) end);
		self._timer:Start();
	end
--self:_OnTickHandler();
end;


function AbsAction:_OnTickHandler()
	if(self._running) then
		self:_OnTimerHandler();
	end
end

-- 动画播放完，子类可重写
function AbsAction:_OnAnimationCompleteHandler()
	self:Stop();
end

-- 开始执行动作，子类可重写
function AbsAction:_OnStartHandler()
	
end

-- 开始完成，一般用于_OnStartHandler方法结束处理数据
function AbsAction:_OnStartCompleteHandler()
	
end;

-- 动作完成，子类可重写
function AbsAction:_OnFinishHandler()
	
end

-- 结束动作，子类可重写
function AbsAction:_OnStopHandler()
	
end

-- 开始移除事件监听，子类可重写
function AbsAction:_OnStartRemoveListenerHandler()
	
end

-- 心跳，子类可重写
function AbsAction:_OnTimerHandler()
	
end

-- 心跳完成，子类可重写
function AbsAction:_OnTimerCompleteHandler()
	self:Stop();
end

-- 设置操作目标，子类可重写
function AbsAction:SetTarget(target)
	self._target = target
end