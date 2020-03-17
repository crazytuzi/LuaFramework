--[[
转职功能
houxudong
2016年7月29日 14:33:23
]]

_G.ZhuanzhiFunc = setmetatable({}, { __index = BaseFunc });

FuncManager:RegisterFuncClass(FuncConsts.ZhuanZhi, ZhuanzhiFunc);

ZhuanzhiFunc.timerKey = nil;


function ZhuanzhiFunc:OnBtnInit()
	self:RegisterTimes()
	self:InitRedPoint()
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
function ZhuanzhiFunc:OnGetEffectIsShow()
	local isCan = ZhuanZhiModel:IsHaveRewardCanGet()
	if isCan then
		self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect(0);
	end
end
--处理消息
function ZhuanzhiFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.ZhuanZhiUpdate then
		self:OnGetEffectIsShow();
	end
end

--监听消息
function ZhuanzhiFunc:ListNotificationInterests()
	return {
		NotifyConsts.ZhuanZhiUpdate,
	} 
end
--消息处理
function ZhuanzhiFunc:RegisterNotification()
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
function ZhuanzhiFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

function ZhuanzhiFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end


ZhuanzhiFunc.zhuanzhiLoader = nil;
function ZhuanzhiFunc:InitRedPoint()
	self.timerKey = TimerManager:RegisterTimer(function()
		if ZhuanZhiModel:IsHaveRewardCanGet() then
			PublicUtil:SetRedPoint(self.button, nil, 1)
		else
			PublicUtil:SetRedPoint(self.button, nil, 0)
		end
	end, 1000, 0);
end


--是否已添加到任务
function ZhuanzhiFunc:OnFuncOpen()
	if ZhuanZhiController.zhuanzhiComInfoMsg then
		ZhuanZhiController:ZhuanZhiComInfo(ZhuanZhiController.zhuanzhiComInfoMsg)
	end
end

function ZhuanzhiFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
end
