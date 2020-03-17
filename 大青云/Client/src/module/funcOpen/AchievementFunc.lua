--[[
	成就功能按钮特效 i++++++++++++++++++++++++++
	2015年6月8日, PM 07:25:53
	wangyanwei 
]]

_G.AchievementFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Achievement,AchievementFunc);

function AchievementFunc:OnBtnInit()
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

function AchievementFunc:OnGetIsShow()
	local achievementEffect = AchievementModel:GetInComplete();
	if achievementEffect or AchievementModel:GetInCompletePointReward() then
		self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect(0);
	end
	if AchievementModel:GetInCompletePointReward() then
		self.button.effect:playEffect(0);
	end
end

--处理消息
function AchievementFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.AchievementUpData then
		self:OnGetIsShow();
	end
end

--消息处理
function AchievementFunc:RegisterNotification()
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
function AchievementFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function AchievementFunc:ListNotificationInterests()
	return {
		NotifyConsts.AchievementUpData,
	} 
end