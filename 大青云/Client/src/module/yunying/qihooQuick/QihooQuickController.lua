--[[
	2015年9月21日, PM 02:36:59
	360加速球
	wangyanwei 
]]

_G.QihooQuickController = setmetatable({},{__index=IController});
QihooQuickController.name = 'QihooQuickController';

function QihooQuickController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_QihooQuickState,self,self.OnQihooQuickState);  --返回360加速球奖励是已否领取
	MsgManager:RegisterCallBack(MsgType.SC_QihooQuickReward,self,self.OnQihooQuickReward);  --返回360加速球奖励领取结果
end

function QihooQuickController:OnSendRewardData(id)
	local msg = ReqWeedSignMsg:new();
	msg.signID = id;
	MsgManager:Send(msg);
end

QihooQuickController.inData = false;
function QihooQuickController:OnQihooQuickState(msg)
	local state = msg.state == 1; --0 领取
	QihooQuickModel:OnQihooQuickData(state);
	UIMainYunYingFunc:DrawLayout();
end

function QihooQuickController:OnQihooQuickReward(msg)
	local result = msg.result == 1;  --0 领取成功
	QihooQuickModel:OnQihooQuickData(result);
	UIMainYunYingFunc:DrawLayout();
	print('领取结果------------',result)
end

function QihooQuickController:SendQihooQuickReward()
	local msg = ReqQihooQuickMsg:new();
	MsgManager:Send(msg);
	print('请求360加速球奖励')
end