--[[
等级投资
2015年8月22日, PM 05:38:45
wangyanwei
]]

_G.OperActivity8Btn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_operActivity8,OperActivity8Btn);

function OperActivity8Btn:GetStageBtnName()
	return "operActivity8";
end

function OperActivity8Btn:IsShow()
	local btnStateVO = OperactivitiesModel:GetOperBtnState(OperactivitiesConsts.iconLevel)
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

function OperActivity8Btn:OnBtnClick()
	OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconLevel)
end

function OperActivity8Btn:OnBtnInit()
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

function OperActivity8Btn:OnGetIsShow()
	local btnState = OperactivitiesModel:GetOperBtnState(OperactivitiesConsts.iconLevel)
	if btnState.reward == 1 then
		self.button.effect:playEffect(0);
	else
		if OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconLevel] then
			self.button.effect:stopEffect();
		else
			self.button.effect:playEffect(0);
		end
	end
end

--处理消息
function OperActivity8Btn:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.UpdateOperActBtnIconState then
		self:OnGetIsShow();
	end
end

--消息处理
function OperActivity8Btn:RegisterNotification()
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
function OperActivity8Btn:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function OperActivity8Btn:ListNotificationInterests()
	return {
		NotifyConsts.UpdateOperActBtnIconState,
	} 
end