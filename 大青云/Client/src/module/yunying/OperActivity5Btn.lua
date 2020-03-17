--[[
运营活动这个抽奖单用了
2015年8月22日, PM 05:38:45
wangyanwei
]]

_G.OperActivity5Btn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_operActivity5,OperActivity5Btn);

function OperActivity5Btn:GetStageBtnName()
	return "operActivity5";
end

function OperActivity5Btn:IsShow()
	local btnStateVO = OperactivitiesModel:GetOperBtnState(OperactivitiesConsts.iconHuodong3)
	local btnState = btnStateVO.reward
	if btnState < 0 then
		return false
	end
	
	if t_consts[126] then
		local constCfgNeedLevel = t_consts[126].val3
		if constCfgNeedLevel then
			local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel -- 当前人物等级
			if curRoleLvl < constCfgNeedLevel then return false end
		end
	end
	
	return true
end

function OperActivity5Btn:OnBtnClick()
	OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconHuodong3)
end

function OperActivity5Btn:OnBtnInit()
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

-- btnid=按钮id
-- cnt=可领奖的数量
-- reward=是否有奖励(1-有，0-没有)
-- imageTxt=按钮标题
function OperActivity5Btn:OnGetIsShow()
	local btnStateVO = OperactivitiesModel:GetOperBtnState(OperactivitiesConsts.iconHuodong3)
	FTrace(btnStateVO, 'OperActivity5Btn')
	local btnVO = {}
	btnVO.val = btnStateVO.cnt
	if btnStateVO.reward == 1 then
		btnVO.reward = 1
	else
		if OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconHuodong3] then
			btnVO.reward = 0
		else
			btnVO.reward = 1
		end
	end
	
	if btnStateVO.new == 1 then
		btnVO.shownew = 1
	else
		btnVO.shownew = 0		
	end
	
	-- if btnStateVO.imageTxt and btnStateVO.imageTxt ~= "" then
	-- 	btnVO.imgNameNormalUrl = ResUtil:GetOperActivityNameIcon(btnStateVO.imageTxt.."_1")
	-- 	btnVO.imgNameOverUrl = ResUtil:GetOperActivityNameIcon(btnStateVO.imageTxt.."_2")		
	-- else
	-- 	btnVO.imgNameNormalUrl = ResUtil:GetOperActivityNameIcon("opername3_1")
	-- 	btnVO.imgNameOverUrl = ResUtil:GetOperActivityNameIcon("opername3_2")	
	-- end	
	self.button:setData(UIData.encode(btnVO))
	-- if btnStateVO.reward == 1 then
		-- self.button.effect:playEffect(0);
	-- else
		-- self.button.effect:stopEffect();
	-- end
end

--处理消息
function OperActivity5Btn:HandleNotification(name, body)
	if not self:IsShow() then return end
	if name == NotifyConsts.UpdateOperActBtnIconState then
		self:OnGetIsShow();
	end
end

--消息处理
function OperActivity5Btn:RegisterNotification()
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
function OperActivity5Btn:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function OperActivity5Btn:ListNotificationInterests()
	return {
		NotifyConsts.UpdateOperActBtnIconState,
	} 
end