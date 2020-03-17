--[[
	活动功能按钮特效 
	2016年8月3日, PM 03:58:53
	houxudong 
]]

_G.ActivityFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Activity,ActivityFunc);

function ActivityFunc:OnBtnInit()
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

function ActivityFunc:OnGetEffectIsShow()
	-- WriteLog(LogType.Normal,true,'-------------是否有活动开启:',UIActivity:GetActivityOpen())
	if UIActivity:GetActivityOpen() then
		self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect(0);
	end
end

--处理消息
function ActivityFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.ActivityState then
		self:OnGetEffectIsShow();
	end
end

--监听消息
function ActivityFunc:ListNotificationInterests()
	return {
		NotifyConsts.ActivityState,
	} 
end

----------------------------------------------------------------
--消息处理
function ActivityFunc:RegisterNotification()
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
function ActivityFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end