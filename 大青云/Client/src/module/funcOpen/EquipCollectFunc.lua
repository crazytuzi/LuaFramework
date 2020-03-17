--[[
伏魔功能
houxudong
2016年7月29日 15:55:25
]]

_G.EquipCollectFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.equipCollect,EquipCollectFunc);

EquipCollectFunc.timerKey = nil;

function EquipCollectFunc:OnBtnInit()
	self:RegisterTimes()
	self:initRedPoint()
	if self.button.initialized then
		if self.button.effect.initialized then
			self.button.effect:playEffect(0);
			--self:OnGetEffectIsShow();
		else
			self.button.effect.init = function()
				self.button.effect:playEffect(0);
				--self:OnGetEffectIsShow();
			end
		end
	end
	self:UnRegisterNotification()
	self:RegisterNotification()
end

function EquipCollectFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

EquipCollectFunc.EquipCollectFuncLoader = nil;
function EquipCollectFunc:initRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		if SmithingModel:IsEquipCollectCanOperate1() then
			PublicUtil:SetRedPoint(self.button, nil, 1)
		else
			PublicUtil:SetRedPoint(self.button, nil, 0)
		end
	end,1000,0); 
end
function EquipCollectFunc:OnGetEffectIsShow()
	local isCan = SmithingModel:IsEquipCollectCanOperate1()
	
	if isCan then
		self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect(0);
	end
end
--处理消息
function EquipCollectFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.EquipCollectUpdate then
		self:OnGetEffectIsShow();
	end
end

--监听消息
function EquipCollectFunc:ListNotificationInterests()
	return {
		NotifyConsts.EquipCollectUpdate,
	} 
end
--消息处理
function EquipCollectFunc:RegisterNotification()
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
function EquipCollectFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

function EquipCollectFunc:GetButton()
	return UIMainFunc:GetBtnCollect();
end