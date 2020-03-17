--[[
七日登录
2015年8月22日, PM 05:38:45
wangyanwei
]]

_G.WeekSignBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_WeekSign,WeekSignBtn);
WeekSignBtn.timerKey = nil;
function WeekSignBtn:GetStageBtnName()
	return "weekSign";
end

function WeekSignBtn:IsShow()
	-- return true
	if WeekSignModel:GetWeekInReward() then
		return false
	end
	return FuncManager:GetFuncIsOpen(FuncConsts.SignWeek);
end

function WeekSignBtn:OnBtnClick()
	if UIWeekSign:IsShow() then
		UIWeekSign:Hide();
	else
		UIWeekSign:Show();
	end
end

function WeekSignBtn:OnBtnInit()
	if self.button.initialized then
		if self.button.effect.initialized then
			self.button.effect:playEffect(0);
			self:OnGetIsShow();
		else
			self.button.effect.init = function()
				self.button.effect:playEffect(0);
				self:OnGetIsShow();
			end
		end
	end

	self:initRedpoint()  --取消了，现在的七日豪礼已经不是运营按钮了，已经是普通按钮了 
	self:RegisterTimes()

	self:UnRegisterNotification()
	self:RegisterNotification()
	

end

--adder:houxudong
--date:2016/7/29 18:49
WeekSignBtn.signWeekLoader = nil;
function WeekSignBtn:initRedpoint( )
	self.timerKey = TimerManager:RegisterTimer(function()
		local isCan,value = WeekSignModel:CheckCanGetReward( )
		if isCan then
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, value)
		else
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, 0)
		end
	end,1000,0);
end

function WeekSignBtn:OnGetIsShow()
	if WeekSignModel:OnIsReward() then
		self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect();
	end
end

--处理消息
function WeekSignBtn:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.WeekSignUpData then
		self:OnGetIsShow();
	end
end

--消息处理
function WeekSignBtn:RegisterNotification()
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
function WeekSignBtn:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end
--取消消息注册
function WeekSignBtn:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function WeekSignBtn:ListNotificationInterests()
	return {
		NotifyConsts.WeekSignUpData,
	} 
end