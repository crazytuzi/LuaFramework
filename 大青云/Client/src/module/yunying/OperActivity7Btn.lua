--[[
运营活动4
2015年8月22日, PM 05:38:45
wangyanwei
]]

_G.OperActivity7Btn = BaseYunYingBtn:new();

YunYingBtnManager:RegisterBtnClass(YunYingConsts.BT_operActivity7,OperActivity7Btn);

function OperActivity7Btn:GetStageBtnName()
	return "operActivity7";
end

function OperActivity7Btn:IsShow()
	local btnStateVO = OperactivitiesModel:GetOperBtnState(OperactivitiesConsts.iconHuodong5)
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

function OperActivity7Btn:OnBtnClick()
	OperActUIManager:ShowHideOperActUI(OperactivitiesConsts.iconHuodong5)
end

function OperActivity7Btn:OnBtnInit()
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
	OperactivitiesController:ReqPartyStatList(OperactivitiesConsts.iconHuodong5)
	OperactivitiesController:ReqPartyList(OperactivitiesConsts.iconHuodong5)
end

-- btnid=按钮id
-- cnt=可领奖的数量
-- reward=是否有奖励(1-有，0-没有)
-- imageTxt=按钮标题
function OperActivity7Btn:OnGetIsShow()
	local btnStateVO = OperactivitiesModel:GetOperBtnState(OperactivitiesConsts.iconHuodong5)

	FTrace(btnStateVO, 'OperActivity7Btn')
	local btnVO = {}
	btnVO.val = btnStateVO.cnt
	local count = OperactivitiesModel:GetExchangeNumByBtn(OperactivitiesConsts.iconHuodong5)
	if count > 0 then
		btnVO.val = btnVO.val + count
		btnStateVO.reward = 1
	end
	if btnStateVO.reward == 1 then
		btnVO.reward = 1
	else
		if OperactivitiesModel.isClickIconList[OperactivitiesConsts.iconHuodong5] then
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
function OperActivity7Btn:HandleNotification(name, body)
	if not self:IsShow() then return end
	self:OnGetIsShow();
end

--消息处理
function OperActivity7Btn:RegisterNotification()
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
function OperActivity7Btn:UnRegisterNotification()
	local setNotificatioin = self:ListNotificationInterests();
	if not setNotificatioin then return; end
	if not self.notifierCallBack then return end
	for i,name in pairs(setNotificatioin) do
		Notifier:unregisterNotification(name, self.notifierCallBack)
	end
end

--监听消息
function OperActivity7Btn:ListNotificationInterests()
	return {
		NotifyConsts.UpdateOperActBtnIconState,
		NotifyConsts.UpdateGroupItemList,
	} 
end