--[[
计时管理器
lizhuangzhuang
2014年8月14日15:41:03
]]
_G.classlist['TimerManager'] = 'TimerManager'
_G.TimerManager = {};
_G.TimerManager.objName = 'TimerManager'
TimerManager.list = {};
TimerManager.enabled = true;
TimerManager.currTimer = nil;

--注册计时
--@param timerCallBack 回调函数,参数count
--@param delay 间隔时间,毫秒
--@param repeatCount 重复次数,0代表一直执行
function TimerManager:RegisterTimer(timerCallBack,delay,repeatCount)
	if not repeatCount then repeatCount=0; end
	local vo = {};
	local key = tostring(timerCallBack);
	if self.list[key] then
		vo = self.list[key];
	end
	vo.timerCallBack = timerCallBack;
	vo.delay = delay;
	vo.repeatCount = repeatCount;
	vo.currCount = 0;
	vo.lastUpdateTime = 0;
	self.list[key] = vo;
	return key;
end

--取消注册
function TimerManager:UnRegisterTimer(key)
	if not key then
		return;
	end
	local vo = self.list[key];
	if vo then vo.timerCallBack = nil end
	self.list[key] = nil
end

function TimerManager:Update(dwInterval)
	if not self.enabled then
		return;
	end
	
	for key,vo in pairs(self.list) do
		vo.lastUpdateTime = vo.lastUpdateTime + dwInterval;
		if vo.lastUpdateTime > vo.delay then
			vo.currCount = vo.currCount + 1;
			self.currTimer = key;
			vo.timerCallBack(vo.currCount);
			vo.lastUpdateTime = vo.lastUpdateTime - vo.delay;
		end
		if vo.repeatCount~=0 and vo.currCount>=vo.repeatCount then
			self:UnRegisterTimer(key);
		end
	end
end

function TimerManager:SetEnabled(enabled)
	self.enabled = enabled;
end

function TimerManager:GetEnabled()
	return self.enabled;
end