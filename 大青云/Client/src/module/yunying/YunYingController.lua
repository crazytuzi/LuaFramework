--[[
运营活动相关
lizhuangzhuang
2015年5月14日14:22:42 
]]

_G.YunYingController = setmetatable({},{__Index = IController});
YunYingController.name = "YunYingController";

YunYingController.rewardlist = {};

function YunYingController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_YunYingReward,self,self.OnYunYingReward);
	MsgManager:RegisterCallBack(MsgType.SC_GetYunYingReward,self,self.OnGetReward);
	MsgManager:RegisterCallBack(MsgType.SC_AddExpense,self,self.AddExoenseMoney)
	MsgManager:RegisterCallBack(MsgType.SC_PlatformVip,self,self.PlatIconStateFun)
	MsgManager:RegisterCallBack(MsgType.SC_GirlTVState,self,self.OnGirlTVState);
	--迅雷手机绑定领取状态
	MsgManager:RegisterCallBack(MsgType.SC_YunYingXunleiReward,self,self.YunxunleiReward);
	--搜狗平台
	MsgManager:RegisterCallBack(MsgType.SC_SougouDownHall,self,self.SougouDownState)
	MsgManager:RegisterCallBack(MsgType.SC_SougouBtnState,self,self.SougouReward)
	--平台手机绑定
	MsgManager:RegisterCallBack(MsgType.SC_YunYingPhoneReward,self,self.LianYunPhoneReward)
	--手机助手
	MsgManager:RegisterCallBack(MsgType.SC_PhoneHelpState,self,self.PhoneHelpState)
end

--联运通用手机绑定
YunYingController.LianYunPhone = {}; 
--value = 0没有领取，1已领取
--type  = 1飞火,237wan
function YunYingController:LianYunPhoneReward(msg)
	--trace(msg)
	--print("收到协议否？")
	-- debug.debug();
	self.LianYunPhone = {};
	self.LianYunPhone.value = msg.value;
	self.LianYunPhone.type 	= msg.type;
	UIMainYunYingFunc:DrawLayout();
end;

-------------------搜狗
function YunYingController:SougouDownState(msg)
	if msg.type == 1 then
		--游戏大厅
	elseif msg.type == 2 then 
		--搜狗皮肤
	end;
	if msg.result == 0 then
		if msg.type == 1 then
			--游戏大厅
			self.SougouData.youxiReward = false;
		elseif msg.type == 2 then 
			--搜狗皮肤
			self.SougouData.pifuReward  = false;
		end;
		FloatManager:AddNormal(StrConfig["yunying015"]);
		UIMainYunYingFunc:DrawLayout();
	end;

end;

YunYingController.SougouData = {};
function YunYingController:SougouReward(msg)
	self.SougouData = {};
	self.SougouData.youxiReward = msg.youxiReward == 0 and true or false;
	self.SougouData.pifuReward  = msg.pifuReward  == 0 and true or false;
	UIMainYunYingFunc:DrawLayout();
end;

function YunYingController:GetSougouReward(type)
	local msg = ReqSougouDownHallMsg:new();
	msg.type = type;
	MsgManager:Send(msg)
end;

--迅雷奖励领取状态
YunYingController.xunleiRewardState = 0; --没有领取，1已领取
function YunYingController:YunxunleiReward(msg)
	--trace(msg)
	--print("收到协议否？")
	--debug.debug();
	self.xunleiRewardState = msg.value;
	UIMainYunYingFunc:DrawLayout();
end;

YunYingController.platIconState = false
--返回是否显示该平台qq
function YunYingController:PlatIconStateFun(msg)
	--trace(msg)
	--print('-----------没有')
	self.platIconState = msg.isOpen == 1 and true or false;
	Notifier:sendNotification(NotifyConsts.AddExpenseMoney)
end;

YunYingController.addExoenseMoney = 0; --累计充值
YunYingController.maxExoenseMoney = 0; --最大单次充值
--返回累计充值消费
function YunYingController:AddExoenseMoney(msg)
	self.addExoenseMoney = msg.consume
	self.maxExoenseMoney = msg.Maxcon;
	Notifier:sendNotification(NotifyConsts.AddExpenseMoney)
end;

--返回运营类奖励是否已领取
function YunYingController:OnYunYingReward(msg)
	for i=1,31 do
		local v = bit.rshift(bit.lshift(msg.value,32-i-1),31);
		self:OnStateChange(i,v);
	end
end

--分发
function YunYingController:OnStateChange(type,value)
	self.rewardlist[type] = value;
	if type == YunYingConsts.RT_Phone then
		PhoneContrller:OnPhoneIsBinding(value);
	elseif type == YunYingConsts.RT_MClient then
		MClientController:OnMClientRewardState(value);
	elseif type == YunYingConsts.RT_MCIsFirstCharge then
		OperactivitiesModel:SetIsCharge(value)
	end
end

function YunYingController:HasGetReward(type)
	if self.rewardlist[type] then
		return self.rewardlist[type]==1;
	end
	return false;
end

function YunYingController:GetReward(type)
	if self.rewardlist[type] == 1 then
		FloatManager:AddNormal(StrConfig["yunying020"]);
		return false;
	end
	local msg = ReqYunYingRewardMsg:new();
	msg.type = type;
	MsgManager:Send(msg);
	return true;
end

function YunYingController:OnGetReward(msg)
	if msg.rst == 0 then
		self.rewardlist[msg.type] = 1;
	elseif msg.rst == -1 then
		FloatManager:AddNormal(StrConfig("yunying018"));
	elseif msg.rst == -2 then
		FloatManager:AddNormal(StrConfig("yunying019"));
	end
end

--美女直播状态
YunYingController.isShowGirlTV = false;
function YunYingController:OnGirlTVState(msg)
	self.isShowGirlTV = msg.state==1;
	UIMainYunYingFunc:DrawLayout();
end

--手机助手状态
YunYingController.isShowPhoneHelp = false;
function YunYingController:PhoneHelpState(msg)
	self.isShowPhoneHelp = msg.state == 1;
	UIMainYunYingFunc:DrawLayout();
end