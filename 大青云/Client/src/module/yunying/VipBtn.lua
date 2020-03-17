--[[
VIP
wangshuai
]]

_G.VipBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_VIP,VipBtn);

function VipBtn:GetStageBtnName()
	return "Vip";
end

function VipBtn:IsShow()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	local con = t_consts[126].val1
	if con > myLevel then 
		return false;
	end
	return true
end


function VipBtn:OnBtnClick()
	if UIVip:IsShow() then
		UIVip:Hide()
	else
		UIVip:Show()	
	end
end

function VipBtn:OnBtnInit()
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

function VipBtn:OnGetIsShow()
	local viplevel = VipController:GetVipLevel();
	if viplevel < 12 then
		self.button.effect:playEffect(0);
	else
		self.button.effect:stopEffect();
	end
end

--处理消息
function VipBtn:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaVIPLevel then
			self:OnGetIsShow();
		end
	end
end

--消息处理
function VipBtn:RegisterNotification()
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
function VipBtn:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function VipBtn:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
	} 
end