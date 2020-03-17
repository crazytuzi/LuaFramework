--[[
	2015年12月18日17:21:37
	wangyanwei
	圣诞节
]]

_G.ChristmasController = setmetatable({},{__index=IController})

ChristmasController.name = 'ChristmasController';

function ChristmasController:Create()
	MsgManager:RegisterCallBack(MsgType.WC_ChristmasDonateInfo,self,self.OnChristmasDonateInfo);							--服务器通知：圣诞兑换信息
	MsgManager:RegisterCallBack(MsgType.WC_BackSubmitChristmasDonateResult,self,self.OnBackSubmitChristmasDonateResult);	--服务器通知：返回兑换结果
	MsgManager:RegisterCallBack(MsgType.WC_BackChristmasDonateReward,self,self.OnBackChristmasDonateReward);				--服务器通知：返回领奖结果
end

--服务器通知：圣诞兑换信息
function ChristmasController:OnChristmasDonateInfo(msg)
	trace(msg)
	local allprogress 	= msg.allprogress;
	local rewardstate 	= msg.rewardstate;
	
	ChristamsModel:SetDonateData(allprogress,rewardstate)
	
	Notifier:sendNotification(NotifyConsts.ChristmasDonateUpData);
end

--服务器通知：返回兑换结果
function ChristmasController:OnBackSubmitChristmasDonateResult(msg)
	trace(msg)
	local result		= msg.result;
	local _type			= msg.type;
	local num			= msg.num;
	local progress		= msg.progress;
	
	if result == 0 then
		ChristamsModel:ChangeDonateList(_type,progress);
	end
	
	if result == -1 then
		FloatManager:AddNormal( StrConfig['christmas010'] );
		return 
	elseif result == -2 then
		FloatManager:AddNormal( StrConfig['christmas012'] );
		return 
	elseif result == -3 then
		FloatManager:AddNormal( StrConfig['christmas013'] );
		return 
	end
	
	Notifier:sendNotification(NotifyConsts.ChristmasDonateResult);
end

--服务器通知：返回领奖结果
function ChristmasController:OnBackChristmasDonateReward(msg)
	trace(msg)
	local result		= msg.result;
	local _type			= msg.type;
	
	if result == 0 then
		ChristamsModel:ChangeDonateRewardState(_type);
	end
	
	Notifier:sendNotification(NotifyConsts.ChristmasDonateReward);
end

----------------------///////////////////////C TO S
--圣诞兑换活动信息
function ChristmasController:ChristmasDonateInfo()
	local msg = ReqChristmasDonateInfoMsg:new();
	MsgManager:Send(msg);
end

--圣诞兑换活动提交物品
function ChristmasController:ChristmasDonate(id,num)
	local msg = ReqChristmasDonateMsg:new();
	msg.id = id;
	msg.num = num;
	MsgManager:Send(msg);
end

--圣诞兑换进度奖励
function ChristmasController:ChristmasDonateReward(index)
	local msg = ReqChristmasDonateRewardMsg:new();
	msg.index = index;
	MsgManager:Send(msg);
end