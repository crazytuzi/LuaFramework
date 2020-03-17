--[[
	2015年6月18日, PM 08:48:29
	新版极限挑战控制器
	wangyanwei
]]

_G.ExtremitChallengeController = setmetatable({},{__index = IController});

ExtremitChallengeController.name = 'ExtremitChallengeController';

function ExtremitChallengeController:Create()
	MsgManager:RegisterCallBack(MsgType.WC_BackNewExtremityData,self,self.OnBackNewExtremityData);						--返回面板信息
	MsgManager:RegisterCallBack(MsgType.WC_BackExtremityRankData,self,self.OnBackExtremityRankData);					--UI排行榜
	MsgManager:RegisterCallBack(MsgType.SC_BackExtremityEnterData,self,self.OnBackExtremityEnterData);					--返回进入信息
	MsgManager:RegisterCallBack(MsgType.SC_BackExtremityBossData,self,self.OnBackExtremityBossData);					--返回BOSS面板信息
	MsgManager:RegisterCallBack(MsgType.SC_BackExtremityMonsterData,self,self.OnBackExtremityMonsterData);				--返回小怪面板信息
	MsgManager:RegisterCallBack(MsgType.SC_BackExtremityResultData,self,self.OnBackExtremityResultData);				--结局面板数据
	MsgManager:RegisterCallBack(MsgType.SC_BackExtremityQuit,self,self.OnBackExtremityQuit);							--退出
	MsgManager:RegisterCallBack(MsgType.SC_BackExtremitHistoryRank,self,self.OnBackExtremitHistoryRank);				--极限挑战自己的历史最高
	
	--刷新临时排行榜
	MsgManager:RegisterCallBack(MsgType.WC_BackExtremityRank,self,self.OnBackExtremityRank);							--刷新临时排行榜
	MsgManager:RegisterCallBack(MsgType.WC_BackExtremityReward,self,self.OnBackExtremityReward);						--服务器返回：返回领取排行榜奖励
end

-----------------\\\\\\\\S\\\\\\\← ← ← ←/////////C//////-----------------

--请求UI信息  自己的排名
function ExtremitChallengeController:OnSendExtremityData()
	local msg = ReqGetNewExtremityDataMsg:new();
	MsgManager:Send(msg);
end

--请求排行榜
function ExtremitChallengeController:OnSendExtremityRankData()
	local msg = ReqGetExtremityRankDataMsg:new();
	MsgManager:Send(msg);
end

--请求进入
function ExtremitChallengeController:OnExtremityEnterData(extremityType)
	local msg = ReqExtremityEnterDataMsg:new();
	msg.state = extremityType;
	
	local fun = function() 
		MsgManager:Send(msg);
	end;
	if TeamUtils:RegisterNotice(UIExtremitChallenge,fun) then 
		return
	end;
	
	MsgManager:Send(msg);
end

--请求退出
function ExtremitChallengeController:OnSendQuitExtremity()
	local msg = ReqExtremityQuitMsg:new();
	MsgManager:Send(msg);
end

--请求排名
function ExtremitChallengeController:OnSendRankIndex(state,val)
	local msg = ReqExtremityRankDataMsg:new();
	msg.state = state;
	msg.val = val;
	MsgManager:Send(msg);
end

--请求领取排行榜奖励
function ExtremitChallengeController:OnSendExtremityRankReward(state)
	local msg = ReqExtremityRewardMsg:new();
	msg.type = state;
	MsgManager:Send(msg);
end

-----------------\\\\\\\\S\\\\\\\→ → → →/////////C//////-----------------

--返回UI面板信息
function ExtremitChallengeController:OnBackNewExtremityData(msg)
	--//自己的数据
	local bossHarm = msg.bossHarm;
	local bossRank = msg.bossRank;
	local monsterRank = msg.monsterRank;
	local monsterNum = msg.monsterNum;
	local bossState = msg.bossState;
	local monsterState = msg.monsterState;
	local bossJoinNum = msg.bossJoinNum;
	local monsterJoinNum = msg.monsterJoinNum;
	
	ExtremitChallengeModel:OnInitMyData(bossHarm,bossRank,monsterRank,monsterNum,bossState,monsterState,bossJoinNum,monsterJoinNum);
	--//派发
	Notifier:sendNotification(NotifyConsts.ExtremitChallengeUpData);
end

--返回自己的历史最高
function ExtremitChallengeController:OnBackExtremitHistoryRank(msg)
	local bossHarm = msg.bossHarm;
	local monsterNum = msg.monsterNum;
	-- trace(msg)
	ExtremitChallengeModel:OnSaveMaxNum(bossHarm,monsterNum)
end

--返回排行榜数据
function ExtremitChallengeController:OnBackExtremityRankData(msg)
	--BOSS排行
	local bossRankList = msg.bossRankList;
	--monster排行
	local monsterRankList = msg.monsterRankList;
	ExtremitChallengeModel:OnInitRankData(bossRankList,monsterRankList);
	--//派发
	Notifier:sendNotification(NotifyConsts.ExtremitChallengeRankData);
end

--返回进入信息
function ExtremitChallengeController:OnBackExtremityEnterData(msg)
	local result = msg.result;
	if result ~= 0 then 
		-- FloatManager:AddNormal( StrConfig["extremitChalleng001"] );
		return 
	end
	print('进入成功！！！！！！！！！！！！！！！！！！！！！' .. msg.state)
	UIExtremitChallenge:Hide();
	MainMenuController:HideRight();
	MainMenuController:HideRightTop();
	local challengeType = msg.state;
	--//储存进入的类型
	ExtremitChallengeModel:SetExtremityType(challengeType);
	--//开始计时，每（按常量时间为间隔）请求一次预计排名
	ExtremitChallengeModel:OnSendRankIndex();
	--//打开信息面板
	UIExtremitChallengeInfo:Open();
end

--返回BOSS面板信息
function ExtremitChallengeController:OnBackExtremityBossData(msg)
	local bossHarm = msg.harm;
	ExtremitChallengeModel:OnSetBossHarm(bossHarm);
	--派发
	Notifier:sendNotification(NotifyConsts.ExtremitChallengeBossData);
end

--返回小怪面板信息
function ExtremitChallengeController:OnBackExtremityMonsterData(msg)
	local killMonsterNum = msg.killNum;
	ExtremitChallengeModel:OnSetMonsterNum(killMonsterNum)
	--派发
	Notifier:sendNotification(NotifyConsts.ExtremitChallengeMonsterData);
end

--结局面板数据
function ExtremitChallengeController:OnBackExtremityResultData(msg)
	local state = msg.state;
	local num = msg.num;
	UIExtremitChallengeInfo:Hide();
	UIExtremitChallengeResult:Open(state,num);
end

--退出
function ExtremitChallengeController:OnBackExtremityQuit(msg)
	MainMenuController:UnhideRight();
	MainMenuController:UnhideRightTop();
	ExtremitChallengeModel:OnCleanTime();
	if UIExtremitChallengeInfo:IsShow() then
		UIExtremitChallengeInfo:Hide();
	end
	if UIExtremitChallengeResult:IsShow() then
		UIExtremitChallengeResult:Hide();
	end
end

--刷新临时排行榜
function ExtremitChallengeController:OnBackExtremityRank(msg)
	local rankNum = msg.rankNum;
	ExtremitChallengeModel:OnSetRankNum(rankNum);
	--派发
	Notifier:sendNotification(NotifyConsts.ExtremitChallengeRankNum);
end

--返回领奖协议
function ExtremitChallengeController:OnBackExtremityReward(msg)
	local result = msg.result;
	if result ~= 0 then print('================领取失败') return end
	print('领奖成功===========' .. msg.type)
	ExtremitChallengeModel:OnSetRewardState();
	Notifier:sendNotification(NotifyConsts.ExtremitChallengeBackReward,{type = msg.type});
end

--进入地图
function ExtremitChallengeController:OnChangeSceneMap()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	if mapCfg.type == 8 then
		-- UIDungeonNpcChat:Open(100000001); ---------------剧情
		if ExtremitChallengeModel:GetExtremityType() == 0 then
			UIDungeonNpcChat:Open(1000001,1);
		else
			UIDungeonNpcChat:Open(100000001);
		end
		UIAutoBattleTip:Open(function()ExtremitChallengeController:OnAutoStart()end,true);
	end
end

function ExtremitChallengeController:OnAutoStart()
	local _pos = 18001;
	local point = QuestUtil:GetQuestPos(_pos);
	if not point then return; end
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
end

--复活后自动战斗
function ExtremitChallengeController:OnReviveAutoStart()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	if mapCfg.type == 8 then
		local _pos = 18001;
		local point = QuestUtil:GetQuestPos(_pos);
		if not point then return; end
		local completeFuc = function()
			AutoBattleController:OpenAutoBattle();
		end
		MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
	end
end