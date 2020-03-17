--[[
竞技场特效
wangshuai
2015年11月14日21:37:33
]]

_G.ArenaFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Arena,ArenaFunc);
ArenaFunc.timerKey = nil;
function ArenaFunc:OnBtnInit()
	if self.button.initialized then
		if self.button.effect.initialized then
			local myinfo = ArenaModel : GetMyroleInfo()
			if myinfo then 
				if myinfo.isResults == 1 or myinfo.chal and myinfo.chal > 15 then   --已经领取奖励或者挑战次数大于15次
					self.button.effect:stopEffect(0);
				else
					self.button.effect:playEffect(0);
				end;
			else
				self.button.effect:stopEffect(0);
			end;
		else
			self.button.effect.init = function()
				local myinfo = ArenaModel : GetMyroleInfo()
				if myinfo then  
					if myinfo.isResults == 1 or toint(myinfo.chal) > 15 then 
						self.button.effect:stopEffect(0);
					else
						self.button.effect:playEffect(0);
					end;
				else
					self.button.effect:stopEffect(0);
				end;
			end
		end
	end
	self:UnRegisterNotification()
	self:RegisterNotification()

   
	ArenaModel : InitFun()
	ArenaController : GetMyroleAtb()
 end

function ArenaFunc:InitRedPoint()
	if self.state ~= FuncConsts.State_Open then return end;
	self.timerKey = TimerManager:RegisterTimer(function()

	local myinfo = ArenaModel : GetMyroleInfo()
	local t,s,m = ArenaModel:GetCurtime();
  
    local iscool= toint(t) >= 0 and toint(s) > 39 and toint(m) >= 0
	if myinfo and myinfo.chal and myinfo.maxchall then
		if toint(myinfo.chal) < toint(myinfo.maxchall) and not iscool then
			PublicUtil:SetRedPoint(self.button,nil,1)
		else
			PublicUtil:SetRedPoint(self.button)
		end
	end
	end,1000,0);
	
end

function ArenaFunc:SetEffectState()
	if self.state ~= FuncConsts.State_Open then return end;
	local myinfo = ArenaModel : GetMyroleInfo()
	if self.button.effect then 
		if myinfo then  
			if myinfo.isResults == 1 or toint(myinfo.chal) > 15 then 
				self.button.effect:stopEffect(0);
			else
				self.button.effect:playEffect(0);
			end;
		else
			self.button.effect:stopEffect(0);
		end;
	end;
end;

function ArenaFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end
--监听消息
function ArenaFunc:ListNotificationInterests()
	return {
		NotifyConsts.ArenaGetMyInfo}
end

--处理消息
function ArenaFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.ArenaGetMyInfo then
		self:SetEffectState()
		self:InitRedPoint()
	end
end

--消息处理
function ArenaFunc:RegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then
		self.notifierCallBack = function(name,body)
			self:HandleNotification(name, body);
		end
	end
	for i,name in pairs(setNotificatioin) do
		Notifier:registerNotification(name, self.notifierCallBack)
	end
end

--取消消息注册
function ArenaFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end