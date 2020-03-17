--[[
七日登录
2015年10月11日, PM 09:43:00
wangyanwei& houxudong
]]

_G.WeekSignFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.SignWeek,WeekSignFunc);
WeekSignFunc.timerKey = nil;

function WeekSignFunc:OnFuncOpen()
	
	UIMainYunYingFunc:DrawLayout();
end
function WeekSignFunc:OnBtnInit()
	self:RegisterTimes()
	self:InitRedpoint()
	if self.button.initialized then
		if self.button.effect.initialized then
			self.button.effect:playEffect(0);
			self:OnGetEffectIsShow();
		else
			self.button.effect.init = function()
				self.button.effect:playEffect(0);
				self:OnGetEffectIsShow();
			end
		end
	end
	self:UnRegisterNotification()
	self:RegisterNotification()
end
function WeekSignFunc:OnGetEffectIsShow()
	local isCan,value = WeekSignModel:CheckCanGetReward( )
	if isCan then
		self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect(0);
	end
end
--处理消息
function WeekSignFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.WeekSignUpData then
		self:OnGetEffectIsShow();
	end
end

--监听消息
function WeekSignFunc:ListNotificationInterests()
	return {
		NotifyConsts.WeekSignUpData,
	} 
end
--消息处理
function WeekSignFunc:RegisterNotification()
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
function WeekSignFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end
function WeekSignFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

WeekSignFunc.signWeekLoader = nil;
function WeekSignFunc:InitRedpoint( )
	self.timerKey = TimerManager:RegisterTimer(function()
		local isCan,value = WeekSignModel:CheckCanGetReward( )
		if isCan then
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, value)
		else
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, 0)
		end
	end,1000,0);
end