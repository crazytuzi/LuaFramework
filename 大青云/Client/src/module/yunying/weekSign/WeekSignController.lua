--[[
	2015年8月22日, PM 03:45:13
	七日计划
	wangyanwei 
]]

_G.WeekSignController = setmetatable({},{__index=IController});
WeekSignController.name = 'WeekSignController';

function WeekSignController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_WeedSignData,self,self.OnBackWeedSignData);  --七日奖励信息
end

function WeekSignController:OnSendRewardData(id)
	local msg = ReqWeedSignMsg:new();
	msg.signID = id;
	MsgManager:Send(msg);
end

WeekSignController.inData = false;
function WeekSignController:OnBackWeedSignData(msg)
	self.inData = true;
	local result = msg.result;
	local login = msg.login;
	local reward = msg.reward;
	local signID = msg.signID;
	WeekSignModel:UpData(result,login,reward)
	Notifier:sendNotification(NotifyConsts.WeekSignUpData,{result = result,id = signID});
	UIMainYunYingFunc:DrawLayout();
end