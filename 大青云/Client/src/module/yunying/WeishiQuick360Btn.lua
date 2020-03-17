--[[
游戏卫士特权加速礼包按钮
zhangshuhui
]]

_G.WeishiQuick360 = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_WishiQuick360,WeishiQuick360);

function WeishiQuick360:GetStageBtnName()
	return "weishi360QuickReward";
end

function WeishiQuick360:OnBtnInit()
	if self.button.initialized then
		if self.button.effect and self.button.effect.initialized then
			if Weishi360Model:GetCurDayQuickReward() == 0 then
				self.button.effect:playEffect(0);
			end
		else
			if self.button.effect then
				self.button.effect.init = function()
					if Weishi360Model:GetCurDayQuickReward() == 0 then
						self.button.effect:playEffect(0);
					end
				end
			end
		end
	end

	--消息
	self:UnRegisterNotification()
	self:RegisterNotification()
end

function WeishiQuick360:IsShow()
	return WeishiController.isShowWeishiQuickState;
end


function WeishiQuick360:OnBtnClick()
	if UIweishi360TeQuanQuickView:IsShow() then
		UIweishi360TeQuanQuickView:Hide();
	else
		if self.button then
			UIweishi360TeQuanQuickView.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UIweishi360TeQuanQuickView:Show();
	end
end

--监听消息
function WeishiQuick360:ListNotificationInterests()
	return {
		NotifyConsts.Youxi360Update,
	} 
end

--处理消息
function WeishiQuick360:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.Youxi360Update then
		self:Youxi360PlayEffect(Weishi360Model:GetCurDayQuickReward() == 0);
	end
end

--消息处理
function WeishiQuick360:RegisterNotification()
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
function WeishiQuick360:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

function WeishiQuick360:Youxi360PlayEffect(isplay)
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