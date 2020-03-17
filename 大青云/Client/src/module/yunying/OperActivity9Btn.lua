--[[
每日首冲
2015年8月22日, PM 05:38:45
wangyanwei
]]

_G.OperActivity9Btn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_operActivity9,OperActivity9Btn);

function OperActivity9Btn:GetStageBtnName()
	return "operActivity9";
end

function OperActivity9Btn:IsShow()
	local btnStateVO = OperactivitiesModel:GetOperBtnState(OperactivitiesConsts.iconFight)
	local btnState = btnStateVO.reward
	if btnState == 2 then
		return false
	end
	
	if btnState < 0 then
		return false
	end
	
	if t_consts[126] then
		local constCfgNeedLevel = t_consts[126].val2
		if constCfgNeedLevel then
			local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel -- 当前人物等级
			if curRoleLvl < constCfgNeedLevel then return false end
		end
	end
	
	return true
end

function OperActivity9Btn:OnBtnClick()
	OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconFight)
end

function OperActivity9Btn:OnBtnInit()
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

function OperActivity9Btn:OnGetIsShow()
	local btnState = OperactivitiesModel:GetOperBtnState(OperactivitiesConsts.iconFight)
	if btnState.reward == 1 then
		self.button.effect:playEffect(0);
	else
		if OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconFight] then
			self.button.effect:stopEffect();
		else
			self.button.effect:playEffect(0);
		end
	end
end

--处理消息
function OperActivity9Btn:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.UpdateOperActBtnIconState then
		self:OnGetIsShow();
	end
end

--消息处理
function OperActivity9Btn:RegisterNotification()
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
function OperActivity9Btn:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function OperActivity9Btn:ListNotificationInterests()
	return {
		NotifyConsts.UpdateOperActBtnIconState,
	} 
end