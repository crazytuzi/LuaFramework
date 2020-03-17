--[[
	成就controller
	2015年5月20日, AM 11:19:01
	wangyanwei
]]

_G.AchievementController = setmetatable({},{__index = IController})

_G.AchievementController.name = 'AchievementController';

function AchievementController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BackAchievementInfo,self,self.OnBackAchievementInfo);  --服务器返回：成就信息
	MsgManager:RegisterCallBack(MsgType.SC_BackAchievementReward,self,self.OnBackAchievementReward);  --服务器返回：领取成就奖励
	MsgManager:RegisterCallBack(MsgType.SC_BackAchievementComplete,self,self.OnBackAchievementComplete);  --服务器返回：阶段成就完成
	MsgManager:RegisterCallBack(MsgType.SC_BackAchievementPonitReward,self,self.OnBackAchievementPonitReward);  --服务器返回：领取阶段成就奖励  点数
	MsgManager:RegisterCallBack(MsgType.SC_AchievementUpData,self,self.OnAchievementUpData);  --服务器返回：刷新成就进度
end

-------------------------C----------------------------

--请求成就信息
function AchievementController:OnGetAchievementInfo()
	local msg = ReqGetAchievementInfoMsg:new();
	MsgManager:Send(msg);
end

--请求领取奖励
function AchievementController:OnGetAchievementReward(id)
	local msg = ReqGetAchievementRewardMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end

--请求领取奖励 点数
function AchievementController:OnGetAchievementPonitReward(id)
	local msg = ReqGetAchievementPonitRewardMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end

-------------------------S----------------------------

--服务器返回：刷新成就进度
function AchievementController:OnAchievementUpData(msg)
	local id,value,state = msg.id,msg.value,msg.state;
	AchievementModel:OnUpDataAchievement(id,value,state);
	Notifier:sendNotification(NotifyConsts.AchievementUpData,{id = id});
end

--服务器返回：成就信息
function AchievementController:OnBackAchievementInfo(msg)
	AchievementModel:OnUpData(msg)
	Notifier:sendNotification(NotifyConsts.AchievementUpData);
end

--服务器返回：领取成就奖励
function AchievementController:OnBackAchievementReward(msg)
	if msg.rrsult == -1 then
		return
	end
	AchievementModel:OnBackAchievementReward(msg);
	Notifier:sendNotification(NotifyConsts.AchievementUpData,{id = msg.id});
end

--服务器返回：阶段成就完成
function AchievementController:OnBackAchievementComplete(msg)
	AchievementModel:OnCompleteAchievement(msg.id);
	Notifier:sendNotification(NotifyConsts.AchievementUpData,{id = msg.id});
	-- 屏蔽成就奖励
	-- UIAchievementTip:Open(msg.id);
end

--服务器返回：领取阶段成就奖励  点数
function AchievementController:OnBackAchievementPonitReward(msg)
	if msg.result == -1 then
		return 
	end
	AchievementModel:onBackAchievementPointIndex(msg.id);
	Notifier:sendNotification(NotifyConsts.AchievementUpData);
	Notifier:sendNotification(NotifyConsts.AchievementPointUpData);
end