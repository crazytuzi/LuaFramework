--[[
福利大厅特效
zhangshuhui
2015年4月22日15:00:00
]]

_G.RegisterAwardFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.RewardLobby,RegisterAwardFunc);

function RegisterAwardFunc:OnBtnInit()
	if self.button.initialized then
		if self.button.effect.initialized then
			if RegisterAwardUtil:GetisHaveReward() == true then
				self.button.effect:playEffect(0);
			end
		else
			self.button.effect.init = function()
				if RegisterAwardUtil:GetisHaveReward() == true then
					self.button.effect:playEffect(0);
				end
			end
		end
	end
	self:RegisterTimes( );
	self:UnRegisterNotification();
	self:RegisterNotification();
	self:initRedPoint()
end

--adder:houxudong
--date:2016/7/29 21:34:52

function RegisterAwardFunc:RegisterTimes( )
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

RegisterAwardFunc.timerKey = nil;
function RegisterAwardFunc:initRedPoint( )
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local isCan,value = RegisterAwardUtil:CanRewardDetail()
		if isCan then
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, value)
		else
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, 0)
		end
	end,1000,0);
end

--处理消息
function RegisterAwardFunc:HandleNotification(name, body)
	if self.state ~= FuncConsts.State_Open then return end
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:AwardPlayEffect(RegisterAwardUtil:GetisHaveReward());
			self:ShowLevelAwardRemind(body.oldVal);
		end
	elseif name == NotifyConsts.UpDataEffect then
		self:AwardPlayEffect(RegisterAwardUtil:GetisHaveReward());
	end
end

--消息处理
function RegisterAwardFunc:RegisterNotification()
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
function RegisterAwardFunc:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function RegisterAwardFunc:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.UpDataEffect
	} 
end

function RegisterAwardFunc:AwardPlayEffect(isplay)
	if not self.button then return; end
	if isplay == true then
		if self.button.effect then
			if self.button.effect.initialized then
				self.button.effect:playEffect(0);
			end
		else
			self.button.effect.init = function()
				self.button.effect:playEffect(0);
			end
		end
	else
		if self.button.effect then
			if self.button.effect.initialized then
				self.button.effect:stopEffect()
			else
				self.button.effect.init = function()
					self.button.effect:stopEffect();
				end
			end
		end
	end
end

function RegisterAwardFunc:ShowLevelAwardRemind(oldVal)
	local giftlevel = RegisterAwardUtil:GetIsOpenLevelRewardGift(oldVal);
	if giftlevel > 0 then
		return;
	end
	--是否有未领取的等级奖励
	if RegisterAwardUtil:GetIsHaveLevelReward() == true then
		RemindController:AddRemind(RemindConsts.Type_LevelReward,1);
	end
end