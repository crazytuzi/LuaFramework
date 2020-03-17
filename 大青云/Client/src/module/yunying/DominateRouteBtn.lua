--[[
jiayong
2016年12月07日, PM 23:41:00

]]

_G.DominateRouteBtn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_DominateRoute,DominateRouteBtn);
YunYingBtnManager.timerKey = nil;
function DominateRouteBtn:GetStageBtnName()
	return "gominateRoute";
end

function DominateRouteBtn:IsShow()
	
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel
	local cfg = t_funcOpen[FuncConsts.DominateRoute]
	if not cfg then return false end
	if curRoleLvl < cfg.open_level then 
		return false
	end
	if DominateRouteModel:IsPassMaxOneDomiante() then
		return false
	end
	return true
end

function DominateRouteBtn:OnBtnClick()
	if UIDominateRoute:IsShow() then
		UIDominateRoute:Hide();
	else
		UIDominateRoute:Show();
	end

end
--收缩执行的方法
function DominateRouteBtn:OnFuncContraction()
	if DominateRouteFuncTip:IsShow() then
		DominateRouteFuncTip:Hide();
	end
end
function DominateRouteBtn:OnGetIsShow()
	-- local openEffect = DominateRouteModel:OpenNewDominateRoute();
	local topIsShow = UIMainFunc:OnGetTopIsShow();
	local isShow = DominateRouteModel:CheckFirstRewardState()
	if isShow and topIsShow then
		--DominateRouteFuncTip:Open();
	else
		--DominateRouteFuncTip:Hide();
	end
end
function DominateRouteBtn:OnBtnInit()
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

	self:OnShowCanEnterNum()
	self:UnRegisterNotification()
	self:RegisterNotification()
	
    
end

function DominateRouteBtn:OnShowCanEnterNum( )
	local times = DominateRouteModel:OnGetEnterNum()
	PublicUtil:SetRedPoint(self.button,RedPointConst.showNum,times)
	if times >0 then
		--self.button.effect:playEffect(0);  --暂时屏蔽
		self.button.effect:stopEffect()
	else
		self.button.effect:stopEffect();
	end

end
--处理消息
function DominateRouteBtn:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.DominateRouteNewOpen or name == NotifyConsts.DominateQuicklySaodangBackUpData or name == NotifyConsts.DominateRouteMopupUpData then
		self:OnShowCanEnterNum()
    elseif name == NotifyConsts.DominateRouteBoxUpData then
		self:OnGetIsShow();	
	end
end

--消息处理
function DominateRouteBtn:RegisterNotification()
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
function DominateRouteBtn:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function DominateRouteBtn:ListNotificationInterests()
	return {
		NotifyConsts.DominateRouteNewOpen,NotifyConsts.DominateRouteMopupUpData,
		NotifyConsts.DominateQuicklySaodangBackUpData,NotifyConsts.DominateRouteBoxUpData,
	} 
end