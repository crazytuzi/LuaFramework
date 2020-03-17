--[[
	2015年12月3日15:40:08
	wangyanwei
	双周奖励
]]
_G.DoubleWeekSignBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_DoubleWeekSign,DoubleWeekSignBtn);

function DoubleWeekSignBtn:GetStageBtnName()
	return "doubleWeekSign";
end

function DoubleWeekSignBtn:IsShow()
	-- return true
	if not WeekSignModel:GetWeekInReward() then
		return false
	end
	if WeekSignModel:GetDoubleWeekReward() then
		return false;
	end
	return false --FuncManager:GetFuncIsOpen(FuncConsts.SignWeek);
end

function DoubleWeekSignBtn:OnBtnClick()
	if UIWeekSign:IsShow() then
		UIWeekSign:Hide();
	else
		UIWeekSign:Show();
	end
end

function DoubleWeekSignBtn:OnBtnInit()
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
	self:UnRegisterNotification()
	self:RegisterNotification()
end

function DoubleWeekSignBtn:OnGetIsShow()
	if WeekSignModel:GetDoubleWeekIsReward() then
		self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect();
	end
end

--处理消息
function DoubleWeekSignBtn:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.WeekSignUpData then
		self:OnGetIsShow();
	end
end

--消息处理
function DoubleWeekSignBtn:RegisterNotification()
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
function DoubleWeekSignBtn:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function DoubleWeekSignBtn:ListNotificationInterests()
	return {
		NotifyConsts.WeekSignUpData,
	} 
end