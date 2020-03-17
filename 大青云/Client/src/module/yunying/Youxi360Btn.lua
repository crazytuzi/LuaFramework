--[[
游戏大厅按钮
wangshuai
]]

_G.Youxi360 = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_Youxi360,Youxi360);

Youxi360.isHaveBtn = false;

function Youxi360:GetStageBtnName()
	return "Youxi360";
end

function Youxi360:OnBtnInit()
	self.isHaveBtn = true;
	self:SetCurServerDay();
	
	if self.button.initialized then
		if self.button.effect.initialized then
			if Weishi360Model:GetCurDatState() == true then
				self.button.effect:playEffect(0);
			end
		else
			self.button.effect.init = function()
				if Weishi360Model:GetCurDatState() == true then
					self.button.effect:playEffect(0);
				end
			end
		end
	end

	--消息
	self:UnRegisterNotification()
	self:RegisterNotification()
end

function Youxi360:SetCurServerDay()
	if not self.isHaveBtn then return end;
	local serverDay = MainPlayerController:GetServerOpenDay();
	if not self.button then return end;
	self.button.day_mc:gotoAndStop(serverDay)
end;

function Youxi360:IsShow()
	local serverDay = MainPlayerController:GetServerOpenDay();
	local curState = Weishi360Model:GetCurDatState()   --得到当前的奖励领取状态
	if serverDay == 7 and not curState then 
		return false;
	end;
	if serverDay > 7 then
		return false
	end;
	return Version:IsShow360Game();
end


function Youxi360:OnBtnClick()
	if UIyouxi360:IsShow() then
		UIyouxi360:Hide();
	else
		if self.button then
			UIyouxi360.tweenStartPos = UIManager:PosLtoG(self.button,0,0);
		end
		UIyouxi360:Show();
	end
end

--监听消息
function Youxi360:ListNotificationInterests()
	return {
		NotifyConsts.AcrossDayInform,
		NotifyConsts.Youxi360Update,
	} 
end

--处理消息
function Youxi360:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.AcrossDayInform then
		if self.isHaveBtn then 
			self:SetCurServerDay();
		end;
	elseif name == NotifyConsts.Youxi360Update then
		self:Youxi360PlayEffect(Weishi360Model:GetCurDatState());
	end
end

--消息处理
function Youxi360:RegisterNotification()
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
function Youxi360:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

function Youxi360:Youxi360PlayEffect(isplay)
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