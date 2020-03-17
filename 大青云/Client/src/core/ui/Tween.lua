--[[
lua实现Tween类
lizhuangzhuang
2015年3月30日16:11:02
]]

_G.TweenVO = {};

TweenVO.defaultEase = Ease:new(1,1);

function TweenVO:new(mc,duration,vars,callbackVars)
	local obj = {};
	for k,v in pairs(TweenVO) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj.mc = mc;
	obj.target = mc._target;
	obj.duration = duration;
	obj.vars = vars;
	obj.callbackVars = callbackVars;
	obj:Init();
	return obj;
end

function TweenVO:Init()
	self.delay = self.vars.delay and self.vars.delay or 0;
	if self.vars.ease then
		if type(self.vars.ease) == "string" then
			print("Error:Tween Ease cannot string");
			self.ease = TweenVO.defaultEase;
		else
			self.ease = self.vars.ease;
		end
	else
		self.ease = TweenVO.defaultEase;
	end
	self.runTime = self.delay<=0 and 0 or nil;--运行时间
	if self.runTime then
		self:InitPorps();
	end
	self.isComplete = false;
end

--初始化属性
function TweenVO:InitPorps()
	self.props = {};
	for k,v in pairs(self.vars) do
		if self.mc[k] then
			local vo = {};
			vo.p = k;
			vo.s = self.mc[k];
			vo.v = v;
			vo.c = v-vo.s;
			table.push(self.props,vo);
		end
	end
end

function TweenVO:Render(interval)
	if self.isComplete then return; end
	if not self.runTime then
		self.delay = self.delay - interval/1000;
		if self.delay <= 0 then
			self.runTime = 0;
			self:InitPorps();
		end
		return;
	end
	--
	if self.runTime == 0 then
		local callbackVars = self.callbackVars;
		if callbackVars then
			if callbackVars.onStart then
				if callbackVars.onStartParams then
					callbackVars.onStart(unpack(callbackVars.onStartParams));
				else		
					callbackVars.onStart();
				end
			end
		end
	end
	--
	if self.runTime >= self.duration then
		local callbackVars = self.callbackVars;
		self.isComplete = true;
		for i,propVo in pairs(self.props) do
			self.mc[propVo.p] = propVo.v;
		end
		Tween:KillOfByTarget(self.target);
		if callbackVars then
			if callbackVars.onComplete then
				if callbackVars.onCompleteParams then
					callbackVars.onComplete(unpack(callbackVars.onCompleteParams));
				else		
					callbackVars.onComplete();
				end
			end
		end
		if callbackVars then
			callbackVars.onComplete = nil;
			callbackVars.onCompleteParams = nil;
			callbackVars.onUpdate = nil;
			callbackVars.onUpdateParams = nil;
			callbackVars = nil;
		end
		return;
	end
	self.runTime = self.runTime + interval/1000;
	local ratio = self.ease:GetRatio(self.runTime/self.duration);
	for i,propVo in pairs(self.props) do
		local v = propVo.c * ratio + propVo.s;
		self.mc[propVo.p] = v;
	end
	if self.callbackVars then
		if self.callbackVars.onUpdate then
			if self.callbackVars.onUpdateParams then
				self.callbackVars.onUpdate(unpack(self.callbackVars.onUpdateParams));
			else
				self.callbackVars.onUpdate();
			end
		end
	end
end

function TweenVO:Destroy()
	self.mc = nil;
	self.ease = nil;
	self.props = nil;
end


_G.Tween = {};
Tween.map = {};

--缓动
--@param mc		显示对象
--@param duration	时间
--@param vars	缓动参数
--@param callbackVars	回调函数
function Tween:To(mc,duration,vars,callbackVars)
	local target = mc._target;
	if not target then return; end
	if self.map[target] then
		Tween:KillOfByTarget(target);
	end
	local vo = TweenVO:new(mc,duration,vars,callbackVars);
	self.map[target] = vo;
end


function Tween:Update(interval)
	for i,vo in pairs(self.map) do
		vo:Render(interval);
	end
end

--清除某个对象的缓动
function Tween:KillOf(mc)
	if not mc then return; end
	local target = mc._target;
	Tween:KillOfByTarget(target);
end

function Tween:KillOfByTarget(target)
	if not target then return; end
	if not self.map[target] then return; end
	self.map[target]:Destroy();
	self.map[target] = nil;
end