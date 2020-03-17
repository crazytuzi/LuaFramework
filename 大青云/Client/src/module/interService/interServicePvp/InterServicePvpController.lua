

_G.InterServicePvpController = setmetatable( {}, {__index = IController} );
InterServicePvpController.name = "InterServicePvpController"
InterServicePvpController.isInPvp1 = false
InterServicePvpController.isBattleResult = false
function InterServicePvpController:Create()
	MsgManager:RegisterCallBack( MsgType.WC_StartMatchPvpRet, self, self.OnStartMatchPvpRet);
	MsgManager:RegisterCallBack( MsgType.WC_ExitMatchPvpRet, self, self.OnMatchPvpRet);
	MsgManager:RegisterCallBack( MsgType.SC_EnterCrossFightPvp1, self, self.OnEnterCrossFightPvp1);
	MsgManager:RegisterCallBack( MsgType.SC_RewardFightPvp1, self, self.OnRewardFightPvp1);
	MsgManager:RegisterCallBack( MsgType.WC_CrossPvpInfo, self, self.OnCrossPvpInfo);
	MsgManager:RegisterCallBack( MsgType.SC_QuitCrossFightPvp1, self, self.OnQuitCrossFightPvp1);
	MsgManager:RegisterCallBack( MsgType.WC_CrossSeasonPvpInfo, self, self.OnCrossSeasonPvpInfo);
	MsgManager:RegisterCallBack( MsgType.WC_NoticeQuitMatch, self, self.OnNoticeQuitMatch);
	MsgManager:RegisterCallBack( MsgType.WC_KuafuRankListState, self, self.OnKuafuRankListState);
	MsgManager:RegisterCallBack( MsgType.WC_KuafuRankDuanweiList, self, self.OnKuafuRankDuanweiList);
	MsgManager:RegisterCallBack( MsgType.WC_KuafuRongyaoInfo, self, self.OnKuafuRongyaoInfo);	
	MsgManager:RegisterCallBack( MsgType.WC_GetPvpRongyaoReward, self, self.OnGetPvpRongyaoReward);	
	
	MsgManager:RegisterCallBack( MsgType.WC_EnterCrossBossRet, self, self.OnEnterCrossBossRet);	
	MsgManager:RegisterCallBack( MsgType.WC_CrossBossRankInfo, self, self.OnWCCrossBossRankInfo);	
	MsgManager:RegisterCallBack( MsgType.SC_CrossBossInfo, self, self.OnCrossBossInfo);	
	MsgManager:RegisterCallBack( MsgType.SC_CrossBossRankInfo, self, self.OnSCCrossBossRankInfo);	
	MsgManager:RegisterCallBack( MsgType.SC_CrossBossTreasure, self, self.OnCrossBossTreasure);	
	MsgManager:RegisterCallBack( MsgType.SC_CrossBossResult, self, self.OnCrossBossResult);	
	MsgManager:RegisterCallBack( MsgType.SC_QuitCrossBoss, self, self.OnQuitCrossBoss);	
	MsgManager:RegisterCallBack( MsgType.WC_CrossBossNotice, self, self.OnCrossBossNotice);	
	MsgManager:RegisterCallBack( MsgType.SC_UseCrossHp, self, self.OnUseCrossHp);	
	MsgManager:RegisterCallBack( MsgType.WC_CrossBossMemInfo, self, self.OnCrossBossMemInfo);
	MsgManager:RegisterCallBack( MsgType.WC_CrossBossRemind, self, self.OnCrossBossRemind);	
	MsgManager:RegisterCallBack( MsgType.SC_CrossInfo, self, self.OnCrossServiceId);			
	
	
	InterServicePvpModel:init()
	CControlBase:RegControl(self, true)
end

function InterServicePvpController:OnEnterGame()
	
end

function InterServicePvpController:IsBattleResult()
	return self.isBattleResult
end

function InterServicePvpController:IsInPvp1()
	return self.isInPvp1
end
----------------------------------------------Response-----------------------------------------------
-- 收到开始匹配返回
function InterServicePvpController:OnStartMatchPvpRet(msg)
	FTrace(msg, '收到开始匹配返回')
	--
	--1已在跨服匹配中，2,组队状态,3,匹配未开启，4，未到匹配时间，5,每日匹配上限，
	--6，在竞技场, 7,在副本或者活动中，8,未开启跨服功能，
	if msg.result ~= 0 then
		if msg.result == 1 then
			FloatManager:AddCenter(StrConfig['interServiceDungeon12']);
		elseif msg.result == 2 then
			FloatManager:AddCenter(StrConfig['interServiceDungeon13']);
		elseif msg.result == 3 then
			FloatManager:AddCenter(StrConfig['interServiceDungeon14']);
		elseif msg.result == 4 then
			FloatManager:AddCenter(StrConfig['interServiceDungeon15']);
		elseif msg.result == 5 then
			FloatManager:AddCenter(StrConfig['interServiceDungeon16']);
		elseif msg.result == 6 then
			FloatManager:AddCenter(StrConfig['interServiceDungeon17']);
		elseif msg.result == 7 then
			FloatManager:AddCenter(StrConfig['interServiceDungeon18']);
		elseif msg.result == 8 then
			FloatManager:AddCenter(StrConfig['interServiceDungeon19']);
		else 
			FloatManager:AddCenter(StrConfig['interServiceDungeon20']);
		end
		return 
	end
	-- Notifier:sendNotification(NotifyConsts.KuafuPvpMatchStart);
	UIInterPvp1VsAn:Show()
end

-- 收到退出匹配返回
function InterServicePvpController:OnMatchPvpRet(msg)
	FTrace(msg, '收到退出匹配返回')
	Notifier:sendNotification(NotifyConsts.KuafuPvpExitCatching);
end

-- 进入跨服PVP返回
function InterServicePvpController:OnEnterCrossFightPvp1(msg)
	FTrace(msg, '进入跨服PVP返回')
	InterServicePvpModel:SetOtherInfo(msg)
	
	Notifier:sendNotification(NotifyConsts.KuafuPvpExitCatching);
	MainInterServiceUI:Hide()
	UIInterPvp1VsAn:Hide()
	UIInterServicePvpStoryView:Show();
	Notifier:sendNotification(NotifyConsts.SmallMapChangeLineVisible, {lineVisible = false});
	-- FPrint('InterServicePvpController:OnEnterCrossFightPvp1')
	self.isInPvp1 = true	
	self:OnEnterPvp1()
end

-- 返回跨服PVP1结果
function InterServicePvpController:OnRewardFightPvp1(msg)
	FTrace(msg, '返回跨服PVP1结果')
	self.isBattleResult = true
	UIInterServicePvpStoryView:SetBtnBackDisabled(true)
	UIInterPvp1Result:setShow(msg.result, function() 
		InterServicePvpController:ReqQuitCrossFightPvp()
	end)
end

-- 返回跨服信息
function InterServicePvpController:OnCrossPvpInfo(msg)
	FTrace(msg, '返回跨服信息')	
	self.isBattleResult = false
	InterServicePvpModel:SetMyroleInfo(msg)
end

-- 退出跨服PVP1返回
function InterServicePvpController:OnQuitCrossFightPvp1(msg)
	FTrace(msg, '退出跨服PVP1返回')	
	InterServicePvpController:ClearInterPvPState()
	self:OnLevelPvp1()
end

-- 服务器返回历届跨服信息
function InterServicePvpController:OnCrossSeasonPvpInfo(msg)
	FTrace(msg, '服务器返回历届跨服信息')	
	InterServicePvpModel : SetCrossSeason(msg)
	
end

-- 通知是否退出匹配
function InterServicePvpController:OnNoticeQuitMatch()
	FTrace(msg, '通知是否退出匹配')	
	local exitfunc = function ()
		InterServicePvpController:ReqExitMatchPvp()
	end
	UIConfirm:Open(StrConfig['interServiceDungeon21'],exitfunc,nil,StrConfig['interServiceDungeon22']);
end

-- 返回跨服排行刷新状态
function InterServicePvpController:OnKuafuRankListState(msg)
	if msg.rankType == 1 then --1段位排行，2荣耀排行
		InterServicePvpModel:AtServerSetCurListboo(true)	
	elseif msg.rankType == 2 then
		InterServicePvpModel:AtServerSetRongyaoboo(true)	
	end;
end
-- 返回跨服段位排行
function InterServicePvpController:OnKuafuRankDuanweiList(msg)
	FTrace(msg, '返回跨服段位排行')	
	InterServicePvpModel:SetInterServicePvpVersion(msg.type, msg.version)
	if msg.type == 1 then --1段位排行，2荣耀排行
		InterServicePvpModel:SetInterServiceRankList(msg.rankList, msg.ret)
	elseif msg.type == 2 then
		InterServicePvpModel:SetInterServiceRongyaoList(msg.rankList, msg.ret)
	end;
end

-- 返回跨服荣耀榜信息
function InterServicePvpController:OnKuafuRongyaoInfo(msg)
	FTrace(msg, '返回跨服荣耀榜信息')	
	InterServicePvpModel.benfuBZNum = msg.num
	InterServicePvpModel.isAward = msg.isAward
	
	Notifier:sendNotification(NotifyConsts.InterServerKuafuRongyaoInfo);
end

-- 荣耀榜领奖
function InterServicePvpController:OnGetPvpRongyaoReward(msg)
	FTrace(msg, '荣耀榜领奖')	
	if msg.result == 0 then
		InterServicePvpModel.isAward = 0
		Notifier:sendNotification(NotifyConsts.InterServerKuafuRongyaoReward);	
	end
end

-----------------------------------跨服boss-----------------------------
-- 返回进入跨服BOSS
function InterServicePvpController:OnEnterCrossBossRet(msg)
	FTrace(msg, '返回进入跨服BOSS')	
	if msg.result == 0 then
		InterServicePvpController:SetInterBossState()
	end
end
-- 返回跨服BOSS主界面排行信息
function InterServicePvpController:OnWCCrossBossRankInfo(msg)
	FTrace(msg, '返回跨服BOSS主界面排行信息')
	InterServicePvpModel:SetBossInitInfo(msg)	
end 
-- 跨服BOSS信息 状态
function InterServicePvpController:OnCrossBossInfo(msg)
	FTrace(msg, '跨服BOSS信息 状态')
	
	-- if not InterServicePvpModel:GetIsInCrossBoss() then
		-- return
	-- end
	
	self:ShowBossStoryUI(msg.status)
	InterServicePvpModel:SetBossListInfo(msg)
end

function InterServicePvpController:ShowBossStoryUI(status)
	if InterServicePvpModel.bossJiesuan then return end

	local curUI = InterServicePvpModel.bossStoryUI['bossUI'..status]
	
	for k, v in pairs(InterServicePvpModel.bossStoryUI) do
		if k ~= 'bossUI'..status then
			v:Hide()
		end
	end
	
	if not curUI:IsShow() then
		InterServicePvpModel.bossStoryUI['bossUI'..status]:Show()
	end
end

-- 战斗中跨服BOSS排行信息
function InterServicePvpController:OnSCCrossBossRankInfo(msg)
	FTrace(msg, '战斗中跨服BOSS排行信息')	
	
	InterServicePvpModel:SetBossRankList(msg)
end
-- 跨服BOSS宝箱数
function InterServicePvpController:OnCrossBossTreasure(msg)
	FTrace(msg, '跨服BOSS宝箱数')	
	
	InterServicePvpModel:SetTreasurenum(msg)
end
-- 跨服区服id
function InterServicePvpController:OnCrossServiceId(msg)
	FTrace(msg, '跨服区服id')	
	
	InterServicePvpModel:SetServiceInfo(msg)
end
-- 跨服BOSS结算
function InterServicePvpController:OnCrossBossResult(msg)
	FTrace(msg, '跨服BOSS结算')	
	
	InterServicePvpModel.bossJiesuan = true
	if UIInterServiceBossStory1:IsShow() then
		UIInterServiceBossStory1:Hide()	
	end
	if UIInterServiceBossStory2:IsShow() then
		UIInterServiceBossStory2:Hide()	
	end
	if UIInterServiceBossStory4:IsShow() then
		UIInterServiceBossStory4:Hide()	
	end
	
	if UIInterServiceBossAddBlood:IsShow() then
		UIInterServiceBossAddBlood:Hide()	
	end
	
	InterServicePvpModel:SetBossResult(msg)	
	UIInterServiceBossResult:Show()
end
-- 退出跨服BOSS
function InterServicePvpController:OnQuitCrossBoss(msg)	
	InterServicePvpController:ClearInterBossState()
	FTrace(msg, '退出跨服BOSS')	
end

-- 开启提醒
function InterServicePvpController:OnCrossBossNotice(msg)
	FPrint('跨服BOSS开启提醒'	)
	local okfun = function () 
		FuncManager:OpenFunc(FuncConsts.KuaFuPVP,true,'uiInterServiceBoss');
	end;
	UIConfirm:Open(StrConfig["interServiceDungeon34"],okfun);	
end

-- 跨服boss加血技能
function InterServicePvpController:OnUseCrossHp(msg)
	FPrint('跨服BOSS加血技能'	)
	if msg.result == 0 then
		Notifier:sendNotification(NotifyConsts.ISKuafuBossAddBlood, {isSucc = true});
	else
		Notifier:sendNotification(NotifyConsts.ISKuafuBossAddBlood, {isSucc = false});
	end
end

-- 跨服boss倒计时提醒
function InterServicePvpController:OnCrossBossRemind(msg)
	FTrace(msg, '跨服boss倒计时提醒')	
	for k,v in pairs(msg.NoticeList) do
		local data = {};
		data.id = v.type
		data.result = v.result		
		data.num = InterServicePvpController:GetCountDownTime(v.type)
		
		if v.type == 1 then
			if v.result == 0 then
				RemindController:AddRemind(RemindConsts.Type_InterBoss,data);
				UIConfirm:Open(StrConfig["interServiceDungeon55"]);
			elseif v.result == 1 then
				RemindController:ClearRemind(RemindConsts.Type_InterBoss);
			end	
		elseif v.type == 2 then	
			if v.result == 0 then
				RemindController:AddRemind(RemindConsts.Type_InterContest,data);
				-- UIConfirm:Open(StrConfig["interServiceDungeon55"]);
			elseif v.result == 1 then
				RemindController:ClearRemind(RemindConsts.Type_InterContest);
			end		
		end
	end
end

function InterServicePvpController:GetCountDownTime(cfgType)
	FPrint('跨服擂台赛'..cfgType)
	local constCfg = nil
	if cfgType == 1 then
		constCfg = t_consts[160]
	elseif cfgType == 2 then	
		constCfg = t_consts[172]
	end
	local startTime = '21:00:00'
	local startHour,startMin,startSec = 21,0,0
	if constCfg then
		local startArr = split(constCfg.param, '#')
		startTime = startArr[1]
		local timeArr = split(startTime, ':')
		startHour = toint(timeArr[1])
		startMin = toint(timeArr[2])
		startSec = toint(timeArr[3])
		-- FPrint('跨服擂台赛a'..startHour..','..startMin..','..startSec)
	end
	local serverTime = GetServerTime()
	local year, month, day, hour, minute, second = CTimeFormat:todate(serverTime,true);
	local cSec = 0
	local cmin = 0 
	if second == 0 then
		cSec = 0
		cmin = startMin - minute
	else
		cSec = 60 - second
		cmin = startMin - 1 - minute
		-- print(year, month, day, hour, minute, second)
		-- print(startMin,minute)
	end
	if cSec < 0 then cSec = 0 end
	if cmin < 0 then cmin = 0 end
	-- print(cSec,cmin)
	local countDown = cmin*60 + cSec
	if countDown < 0 then countDown = 0 end
	-- FPrint('跨服擂台赛b'..countDown)
	return countDown
end

-- 跨服boss资格列表
function InterServicePvpController:OnCrossBossMemInfo(msg)
	FTrace(msg, '跨服boss资格列表')	
	InterServicePvpModel:SetBossMemList(msg)
end

function InterServicePvpController:OnEnterPvp1()
	
end

function InterServicePvpController:OnLevelPvp1()
	
end


----------------------------------------------Request-----------------------------------------------
-- 客户端请求：请求跨服pvp初始数据
function InterServicePvpController:ReqCrossPvpInfo()
	local msg = ReqCrossPvpInfoMsg:new();
	FTrace(msg, '请求跨服pvp初始数据')
	MsgManager:Send(msg);
end

-- 客户端请求：请求匹配
function InterServicePvpController:ReqStartMatchPvp()
	local msg = ReqStartMatchPvpMsg:new();
	FTrace(msg, '请求开始匹配')
	MsgManager:Send(msg);
end

-- 客户端请求：退出匹配
function InterServicePvpController:ReqExitMatchPvp()
	local msg = ReqExitMatchPvpMsg:new();
	FTrace(msg, '请求退出匹配')
	MsgManager:Send(msg);
end

-- 客户端请求：请求退出跨服PVP1
function InterServicePvpController:ReqQuitCrossFightPvp()
	local msg = ReqQuitCrossFightPvpMsg:new();
	FTrace(msg, '请求退出跨服PVP1')
	MsgManager:Send(msg);
end

-- 客户端请求：请求PVP每日奖励
function InterServicePvpController:ReqGetPvpDayReward()
	local msg = ReqGetPvpDayRewardMsg:new();
	FTrace(msg, '请求PVP每日奖励')
	MsgManager:Send(msg);
end

-- 请求历届跨服信息
function InterServicePvpController:ReqCrossSeasonPvpInfo(seasonid)
	local msg = ReqCrossSeasonPvpInfoMsg:new();
	msg.seasonid = seasonid
	FTrace(msg, '请求历届跨服信息')
	MsgManager:Send(msg);
end

-- 请求跨服段位排行
function InterServicePvpController:ReqKuafuRankDuanweiList(rankType)
	local msg = ReqKuafuRankDuanweiListMsg:new();
	msg.type = rankType
	msg.version = InterServicePvpModel:GetInterServicePvpVersion(rankType)
	FTrace(msg, '请求跨服段位排行')
	MsgManager:Send(msg);
end

-- 请求跨服荣耀榜信息
function InterServicePvpController:ReqKuafuRongyaoInfo()
	local msg = ReqKuafuRongyaoInfoMsg:new();
	FTrace(msg, '请求跨服荣耀榜信息')
	MsgManager:Send(msg);
end

-- 请求跨服荣耀榜奖励
function InterServicePvpController:ReqGetPvpRongyaoReward()
	local msg = ReqGetPvpRongyaoRewardMsg:new();
	FTrace(msg, '请求跨服荣耀榜奖励')
	MsgManager:Send(msg);
end

-----------------------------------跨服boss-----------------------------
-- 请求进入跨服Boss
function InterServicePvpController:ReqEnterCrossBoss()
	local msg = ReqEnterCrossBossMsg:new();
	FTrace(msg, '请求进入跨服Boss')
	MsgManager:Send(msg);
end

-- 请求跨服BOSS主界面
function InterServicePvpController:ReqCrossBossInfo()
	local msg = ReqCrossBossInfoMsg:new();
	FTrace(msg, '请求跨服BOSS排行信息')
	MsgManager:Send(msg);
end

-- 请求跨服战斗中BOSS排行信息
function InterServicePvpController:ReqCrossBossRankInfo()
	local msg = ReqCrossBossRankInfoMsg:new();
	FTrace(msg, '请求跨服战斗中BOSS排行信息')
	MsgManager:Send(msg);
end

-- 客户端请求：退出跨服BOSS
function InterServicePvpController:ReqQuitCrossBoss()
	local msg = ReqQuitCrossBossMsg:new();
	FTrace(msg, '客户端请求：退出跨服BOSS')
	MsgManager:Send(msg);
end

-- 客户端请求：跨服BOSS加血
function InterServicePvpController:ReqUseCrossHp()
	local msg = ReqUseCrossHpMsg:new();
	FTrace(msg, '客户端请求：跨服BOSS加血')
	MsgManager:Send(msg);
end

--------------------------------------------------------------------------------


function InterServicePvpController:OnChangeSceneMap()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()]
	if not mapCfg then return end
	-- FPrint('OnChangeSceneMap'..mapCfg.type)
	-- debug.debug()
	if mapCfg.type ~= 16 then		
		InterServicePvpController:ClearInterPvPState()
	end
	if mapCfg.type ~= 22 then
		InterServicePvpController:ClearInterBossState()
	end
	if mapCfg.type == 22 then
		InterServicePvpController:SetInterBossState()
		InterServicePvpModel.bossJiesuan = false
	end
	
end

function InterServicePvpController:ClearInterPvPState()
	self.isInPvp1 = false
	self.isBattleResult = false
	if UIInterServicePvpStoryView:IsShow() then
		UIInterServicePvpStoryView:Hide()
		Notifier:sendNotification(NotifyConsts.SmallMapChangeLineVisible, {lineVisible = true});
	end
	
	if UIInterPvp1Result:IsShow() then
		UIInterPvp1Result:Hide()
	end
end

function InterServicePvpController:SetInterBossState()
	InterServicePvpModel:SetIsInCrossBoss(true)
	-- debug.debug()
	MainInterServiceUI:Hide()
	UIInterServiceBossAddBlood:Show()
	Notifier:sendNotification(NotifyConsts.SmallMapChangeLineVisible, {lineVisible = false});
end

function InterServicePvpController:ClearInterBossState()
	-- debug.debug()
	InterServicePvpModel:SetIsInCrossBoss(false)
	-- debug.debug()
	InterServicePvpModel:ClearBossTime()
	if UIInterServiceBossResult:IsShow() then
		UIInterServiceBossResult:Hide()	
	end
	if UIInterServiceBossStory1:IsShow() then
		UIInterServiceBossStory1:Hide()	
	end
	if UIInterServiceBossStory2:IsShow() then
		UIInterServiceBossStory2:Hide()	
	end
	if UIInterServiceBossStory4:IsShow() then
		UIInterServiceBossStory4:Hide()	
	end
	if UIQiZhanDungeonTip:IsShow() then
		UIQiZhanDungeonTip:Hide()	
	end
	if UIInterServiceBossAddBlood:IsShow() then
		UIInterServiceBossAddBlood:Hide()	
	end
	
	Notifier:sendNotification(NotifyConsts.SmallMapChangeLineVisible, {lineVisible = true});
end

function InterServicePvpController:OnLeaveSceneMap()
	-- local mapCfg = t_map[CPlayerMap:GetCurMapID()]
	-- FPrint('InterServicePvpController:OnLeaveSceneMap1'..CPlayerMap:GetCurMapID())
	-- if mapCfg and mapCfg.type == 16 then
		-- FPrint('InterServicePvpController:OnLeaveSceneMap')	
	-- end
end

function InterServicePvpController:OnKeyDown(keyCode)    
	if keyCode == _System.KeyT then
		UIInterServiceBossAddBlood:ShowSCItemKeyDown(true)
		UIInterServiceBossAddBlood:OnSkillClick()
		return;
	end
end

function InterServicePvpController:OnKeyUp(keyCode)    
	if keyCode == _System.KeyT then
		UIInterServiceBossAddBlood:ShowSCItemKeyDown(false)
		return;
	end
end
