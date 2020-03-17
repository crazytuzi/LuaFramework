--[[
跨服擂台赛
liyuan

]]

_G.InterContestController = setmetatable( {}, {__index = IController} );
InterContestController.name = "InterContestController"

function InterContestController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_CrossPreArenaInfo, self, self.OnCrossPreArenaInfo);
	MsgManager:RegisterCallBack( MsgType.SC_CrossPreArenaRank, self, self.OnCrossPreArenaRank);
	MsgManager:RegisterCallBack( MsgType.SC_CrossPreArenaResult, self, self.OnCrossPreArenaResult);
	MsgManager:RegisterCallBack( MsgType.SC_CrossArenaInfo, self, self.OnCrossArenaInfo);
	MsgManager:RegisterCallBack( MsgType.SC_CrossArenaResult, self, self.OnCrossArenaResult);
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaRankInfo, self, self.OnCrossArenaRankInfo);
	
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaXiaZhuInfo, self, self.OnCrossArenaXiaZhuInfo);
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaXiaZhu, self, self.OnCrossArenaXiaZhu);
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaGuWu, self, self.OnCrossArenaGuWu);
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaDuiShou, self, self.OnCrossArenaDuiShou);
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaRemaind, self, self.OnCrossArenaRemaind);
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaZige, self, self.OnCrossArenaZige);
	
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaZiGeNotice, self, self.OnCrossArenaZiGeNotice);
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaTaoTaiNotice, self, self.OnCrossArenaTaoTaiNotice);
	MsgManager:RegisterCallBack( MsgType.WC_CrossArenaLunKongNotice, self, self.OnCrossArenaLunKongNotice);		--轮空
	InterContestModel:init()

	CControlBase:RegControl(self, true)
end

function InterContestController:OnEnterGame()
	
end
----------------------------------------------Response-----------------------------------------------
-- 服务器通知：返回跨服预选赛信息
-- remain 剩余时间
-- score  积分
function InterContestController:OnCrossPreArenaInfo(msg)
	FTrace(msg, '服务器通知：返回跨服预选赛信息')
	InterContestModel:initPreArenaInfo(msg)
end

-- 服务器通知：跨服预选赛第一名
function InterContestController:OnCrossPreArenaRank(msg)
	FTrace(msg, '服务器通知：跨服预选赛第一名')
	InterContestModel:PreArenaRank(msg)
end

-- 服务器通知：跨服预选赛结果
function InterContestController:OnCrossPreArenaResult(msg)
	FTrace(msg, '服务器通知：跨服预选赛结果')
	InterContestModel:CrossPreArenaResult(msg)
end

-- 服务器通知：跨服淘汰赛
function InterContestController:OnCrossArenaInfo(msg)
	FTrace(msg, '服务器通知：跨服淘汰赛')
	InterContestModel:initArenaInfo(msg)
end

-- 服务器通知：跨服淘汰赛结果
function InterContestController:OnCrossArenaResult(msg)
	FTrace(msg, '服务器通知：跨服淘汰赛结果')
	InterContestModel:CrossArenaResult(msg)
end

-- 返回跨服擂台赛排名
function InterContestController:OnCrossArenaRankInfo(msg)
	FTrace(msg, '返回跨服擂台赛排名')
	InterContestModel:SetCrossArenaRankInfo(msg)
end

-- 返回跨服擂台赛下注信息
function InterContestController:OnCrossArenaXiaZhuInfo(msg)
	FTrace(msg, '返回跨服擂台赛下注信息')
	InterContestModel:SetCrossArenaXiaZhuInfo(msg)
end
-- 返回跨服擂台赛下注结果
function InterContestController:OnCrossArenaXiaZhu(msg)
	FTrace(msg, '返回跨服擂台赛下注结果')
	
	UIInterContestXiazhuDialog.canSend = true
	
	local playerId = msg.id;
	local gold = msg.gold;
	local result = msg.result;
	
	if msg.result == 0 then
		InterContestModel:SetCrossArenaXiaZhu(playerId,gold)	
	end
end
-- 返回跨服擂台赛鼓舞结果
function InterContestController:OnCrossArenaGuWu(msg)
	FTrace(msg, '返回跨服擂台赛鼓舞结果')
	
	UIInterContestGuwuDialog.canSend = true
	if msg.result == 0 then
		InterContestModel:SetCrossArenaGuWu(msg)	
	end
end

-- 返回跨服擂台赛对手
function InterContestController:OnCrossArenaDuiShou(msg)
	FTrace(msg, '返回跨服擂台赛对手')
	InterContestModel:SetCrossArenaDuiShou(msg)
end
-- 跨服擂台赛资格提醒
function InterContestController:OnCrossArenaRemaind(msg)
	FTrace(msg, '跨服擂台赛资格提醒')	
	RemindController:AddRemind(RemindConsts.Type_InterContestPreZige,1);
end
-- 返回跨服擂台赛资格
function InterContestController:OnCrossArenaZige(msg)
	FTrace(msg, '返回跨服擂台赛资格')
	InterContestModel:SetCrossArenaZige(msg)
end
-- 资格赛提醒
function InterContestController:OnCrossArenaZiGeNotice(msg)
	FTrace(msg, '资格赛提醒')
	
	local okfun = function () 
		FuncManager:OpenFunc(FuncConsts.KuaFuPVP,true,'uiInterServiceContest');
	end;
	UIConfirm:Open(StrConfig["interServiceDungeon66"],okfun);
end
-- 淘汰赛提醒
function InterContestController:OnCrossArenaTaoTaiNotice(msg)
	FTrace(msg, '淘汰赛提醒')	
	
	UIConfirm:Open(StrConfig["interServiceDungeon67"],okfun);
end

--轮空提醒
function InterContestController:OnCrossArenaLunKongNotice(msg)
	UIInterConterBye:Show();
end

----------------------------------------------Request---------------------------------------
-- 请求进入跨服擂台资格赛赛
function InterContestController:ReqEnterCrossArena()
	local msg = ReqEnterCrossArenaMsg:new();
	FTrace(msg, '请求进入跨服擂台资格赛赛')
	MsgManager:Send(msg);
end


-- 客户端请求：请求跨服预选赛第一名
function InterContestController:ReqCrossPreArenaRank()
	local msg = ReqCrossPreArenaRankMsg:new();
	FTrace(msg, '客户端请求：请求跨服预选赛第一名')
	MsgManager:Send(msg);
end

-- 请求退出跨服预选赛
function InterContestController:ReqCrossPreArenaQuit()
	local msg = ReqCrossPreArenaQuitMsg:new();
	FTrace(msg, '请求退出跨服预选赛')
	MsgManager:Send(msg);
end

-- 请求退出跨服淘汰赛
function InterContestController:ReqCrossArenaQuit()
	local msg = ReqCrossArenaQuitMsg:new();
	FTrace(msg, '请求退出跨服淘汰赛')
	MsgManager:Send(msg);
end

-- 请求擂台赛信息
function InterContestController:ReqCrossArenaInfo(seasonid)
	local msg = ReqCrossArenaInfoMsg:new();
	msg.seasonid = seasonid
	FTrace(msg, '请求擂台赛信息')
	MsgManager:Send(msg);
end

-- 请求擂台赛下注信息
function InterContestController:ReqCrossArenaXiaZhuInfo()
	local msg = ReqCrossArenaXiaZhuInfoMsg:new();
	FTrace(msg, '请求擂台赛下注信息')
	MsgManager:Send(msg);
end
-- 请求擂台赛下注
function InterContestController:ReqCrossArenaXiaZhu(id,gold)
	local msg = ReqCrossArenaXiaZhuMsg:new();
	msg.id = id
	msg.gold = gold
	FTrace(msg, '请求擂台赛下注')
	MsgManager:Send(msg);
end
-- 请求擂台赛鼓舞
function InterContestController:ReqCrossArenaGuWu()
	local msg = ReqCrossArenaGuWuMsg:new();
	FTrace(msg, '请求擂台赛鼓舞')
	MsgManager:Send(msg);
end
-- 请求擂台赛对手
function InterContestController:ReqCrossArenaDuiShou()
	local msg = ReqCrossArenaDuiShouMsg:new();
	FTrace(msg, '请求擂台赛对手')
	MsgManager:Send(msg);
end
-- 请求擂台赛资格
function InterContestController:ReqCrossArenaZige()
	local msg = ReqCrossArenaZigeMsg:new();
	FTrace(msg, '请求擂台赛资格')
	MsgManager:Send(msg);
end
--------------------------------------------------------------------------------


function InterContestController:OnChangeSceneMap()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()]
	if not mapCfg then return end
	
	if mapCfg.type ~= 23 then		
		InterContestController:ClearPreArenaState()
	end	
	if mapCfg.type == 23 then
		InterContestController:SetPreArenaState()
	end
	
	if mapCfg.type ~= 24 then		
		InterContestController:ClearArenaState()
	end	
	if mapCfg.type == 24 then
		InterContestController:SetArenaState()
	end
	
end

-- 进入跨服预选赛
function InterContestController:SetPreArenaState()
	if MainInterServiceUI:IsShow() then
		MainInterServiceUI:Hide()	
	end
	if UIInterContestAward:IsShow() then
		UIInterContestAward:Hide()	
	end	
	if UIInterContestGuwuDialog:IsShow() then
		UIInterContestGuwuDialog:Hide()	
	end
	if UIInterContestGuwu:IsShow() then
		UIInterContestGuwu:Hide()	
	end
	if UIInterContestZige:IsShow() then
		UIInterContestZige:Hide()	
	end
	if UIInterContestXiazhuDialog:IsShow() then
		UIInterContestXiazhuDialog:Hide()	
	end

	InterContestModel:SetIsInContest(true)

	UIInterServiceBossAddBlood:Show()

	Notifier:sendNotification(NotifyConsts.SmallMapChangeLineVisible, {lineVisible = false});
end

-- 退出跨服预选赛
function InterContestController:ClearPreArenaState()
	if UIInterContestAward:IsShow() then
		UIInterContestAward:Hide()	
	end
	if InterContestMyOpponent:IsShow() then
		InterContestMyOpponent:Hide()	
	end
	if UIInterContestPreResult:IsShow() then
		UIInterContestPreResult:Hide()	
	end
	if UIInterContestPreStory:IsShow() then
		UIInterContestPreStory:Hide()	
	end	
	if UIInterContestScoreFirst:IsShow() then
		UIInterContestScoreFirst:Hide()	
	end	
	if UIInterContestZige:IsShow() then
		UIInterContestZige:Hide()	
	end

	InterContestModel:SetIsInContest(false)

	if UIInterServiceBossAddBlood:IsShow() then
		UIInterServiceBossAddBlood:Hide()	
	end

	Notifier:sendNotification(NotifyConsts.SmallMapChangeLineVisible, {lineVisible = true});
end

-- 进入跨服淘汰赛
function InterContestController:SetArenaState()
	if MainInterServiceUI:IsShow() then
		MainInterServiceUI:Hide()	
	end
	if UIInterContestAward:IsShow() then
		UIInterContestAward:Hide()	
	end	
	if UIInterContestGuwuDialog:IsShow() then
		UIInterContestGuwuDialog:Hide()	
	end
	if UIInterContestGuwu:IsShow() then
		UIInterContestGuwu:Hide()	
	end
	if UIInterContestZige:IsShow() then
		UIInterContestZige:Hide()	
	end
	if UIInterContestXiazhuDialog:IsShow() then
		UIInterContestXiazhuDialog:Hide()	
	end	

	Notifier:sendNotification(NotifyConsts.SmallMapChangeLineVisible, {lineVisible = false});
end

-- 退出跨服淘汰赛
function InterContestController:ClearArenaState()
	if UIInterContestAward:IsShow() then
		UIInterContestAward:Hide()	
	end
	if InterContestMyOpponent:IsShow() then
		InterContestMyOpponent:Hide()	
	end	
	if UIInterContestResult:IsShow() then
		UIInterContestResult:Hide()	
	end	
	if UIInterContestStory:IsShow() then
		UIInterContestStory:Hide()	
	end
	if UIInterContestZige:IsShow() then
		UIInterContestZige:Hide()	
	end
	Notifier:sendNotification(NotifyConsts.SmallMapChangeLineVisible, {lineVisible = true});
end


function InterContestController:OnKeyDown(keyCode)    
	if keyCode == _System.KeyT then
		UIInterServiceBossAddBlood:ShowSCItemKeyDown(true)
		UIInterServiceBossAddBlood:OnSkillClick()
		return;
	end
end

function InterContestController:OnKeyUp(keyCode)    
	if keyCode == _System.KeyT then
		UIInterServiceBossAddBlood:ShowSCItemKeyDown(false)
		return;
	end
end