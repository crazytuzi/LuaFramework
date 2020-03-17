--[[
任务指引
lizhuangzhuang
2014年8月25日10:08:59
]]

_G.QuestGuideManager = {};

--上个任务
QuestGuideManager.lastQuestId = 0;
QuestGuideManager.lastQuestState = -1;
--
QuestGuideManager.autoTimerKey = nil;
--自动进行任务剩余时间
QuestGuideManager.lastAutoTime = -1;

--引导是否被暂停
QuestGuideManager.isStop = false;
--是否在显示主线引导
QuestGuideManager.isShowTrunkGuide = false;
--是否在显示日环引导
QuestGuideManager.isShowDayGuide = false;
--自动拉到日环任务的定时器
QuestGuideManager.autoDayTimerKey = nil;
--第一个任务可以进行了
QuestGuideManager.firstCanGo = false;
--进入游戏时
function QuestGuideManager:OnEnterGame()
	if MainPlayerModel.humanDetailInfo.eaLevel >= QuestConsts.AutoLevel then
		return;
	end
	--如果是第一个任务,弹进入引导;否则箭头
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then return; end
	if questVO:GetId() == QuestConsts.FirstQuest then
		self.firstCanGo = false;
		UIWelcome:Open(function()
			self.firstCanGo = true;
			self:OnNewQuest(questVO);
		end);
	else
		self.firstCanGo = true;
		TimerManager:RegisterTimer(function()
			if questVO:GetState() == QuestConsts.State_CannotAccept then
				self:DoIdleQuest()
			else
				--			self:ShowTrunkGuide(true);
				self:DoTrunkGuide();
			end
		end, 5000, 1)
	end
end

--有新任务时
function QuestGuideManager:OnNewQuest(questVO)
	if MainPlayerModel.humanDetailInfo.eaLevel >= QuestConsts.AutoLevel then
		return;
	end
	if questVO:GetType() ~= QuestConsts.Type_Trunk then
		return;
	end
	--
	self.lastQuestId = questVO:GetId();
	self.lastQuestState = questVO:GetState();
	--
	if self.isStop then return; end
	--
	if questVO:GetState() == QuestConsts.State_CannotAccept then
		QuestConsts.AutoLevel = 120;
--		self:OnTrunkBreak();
		self:DoIdleQuest()
		return;
	else
		if self.unTrunkGuideTimer then
			TimerManager:UnRegisterTimer(self.unTrunkGuideTimer);
			self.unTrunkGuideTimer = nil;
		end
		self:ShowTrunkGuide(true);
	end
	--
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
	--
	local func = function()
		--如果当前在剧情中,等剧情完了再执行引导
		if StoryController:IsStorying() then
			StoryController:RegisterCurrCallBack(function()
				if CPlayerMap.bChangeMaping then return; end--处理北灵院第一个任务
				if not self.isStop then
					questVO:Proceed(true); -- 进行任务
				end
			end);
		else
			if not self.isStop then
				questVO:Proceed(true); -- 进行任务
			end
		end
	end
	--如果任务时可交的,根据配表时间去判断;否则直接去引导
	if questVO:GetState() == QuestConsts.State_CanFinish then
		if questVO:GetCfg().finishWaitTime == 0 then
			func();
		else
			self.autoTimerKey = TimerManager:RegisterTimer(function()
				self.autoTimerKey = nil;
				func();
			end,questVO:GetCfg().finishWaitTime,1);
		end
	else
		func();
	end
end

--任务状态变化时
function QuestGuideManager:OnQuestUpdate(questVO)
	if MainPlayerModel.humanDetailInfo.eaLevel >= QuestConsts.AutoLevel then
		return;
	end
	if questVO:GetType() ~= QuestConsts.Type_Trunk then
		return;
	end
	if self.lastQuestId == questVO:GetId() and self.lastQuestState == questVO:GetState() then
		return;
	end
	--从不可接变成可接,弹提醒,引导玩家去做主线(如果当前当前有日环,不执行这个逻辑)
	if self.lastQuestState==QuestConsts.State_CannotAccept and questVO:GetState()~=QuestConsts.State_CannotAccept then
		self:ClearTrunkBreakGuide();
		AutoBattleController:CloseAutoHang();
		self:DoIdleQuest();
		self.lastQuestState = questVO:GetState();
		return;
	end
	-- 主线变为不可接取，超过了新手期 那么设置了日环等待时间后去做日环, 如果日环也做完了 就去讨伐
	if questVO:GetState() == QuestConsts.State_CannotAccept then
		QuestConsts.AutoLevel = 120;
		if not QuestConsts.IsNewPlayerTrunk then
			AutoBattleController:CloseAutoHang();
			self.lastAutoTime = QuestConsts.Auto_Day_Time;
			return;
		end
	end
	--
	self.lastQuestId = questVO:GetId();
	self.lastQuestState = questVO:GetState();
	--
	if self.isStop then return; end
	--
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
	--
	local func = function()
		--如果当前在剧情中,等剧情完了再执行引导
		if StoryController:IsStorying() then
			StoryController:RegisterCurrCallBack(function()
				if not self.isStop then
					questVO:Proceed(true); -- 进行任务
				end
			end);
		else
			if not self.isStop then
				questVO:Proceed(true); -- 进行任务
			end
		end
	end
	--如果任务时可交的,根据配表时间去判断;否则直接去引导
	if questVO:GetState() == QuestConsts.State_CanFinish then
		if questVO:GetCfg().finishWaitTime == 0 then
			func();
		else
			self.autoTimerKey = TimerManager:RegisterTimer(function()
				self.autoTimerKey = nil;
				func();
			end,questVO:GetCfg().finishWaitTime,1);
		end
	else
		func();
	end
end

--任务完成时
--延时停掉指引,因为这时可能马上有个新任务
function QuestGuideManager:OnQuestFinish(questId)
	local cfg = t_quest[questId];
	if not cfg then return; end
	if self.unTrunkGuideTimer then
		TimerManager:UnRegisterTimer(self.unTrunkGuideTimer);
		self.unTrunkGuideTimer = nil;
	end
	self.unTrunkGuideTimer = TimerManager:RegisterTimer(function()
		self:ShowTrunkGuide(false);
	end,100,1)
end

--切完场景
--打蛋副本和出打蛋副本的时候,自动引导一下
function QuestGuideManager:OnChangeMap()
	if MainPlayerModel.humanDetailInfo.eaLevel >= QuestConsts.AutoLevel then
		return;
	end
	if not self:MapNeedGuide() then return; end
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then return; end
	--
	if questVO:GetId() ~= QuestConsts.EnterWuhunDungeonQuest and
		questVO:GetId() ~= QuestConsts.ExitWuhunDungeonQuest and
		questVO:GetId() ~= QuestConsts.EnterDungeonQuestTwo and
		questVO:GetId() ~= QuestConsts.ExitWuhunDungeonQuestTwo and
		questVO:GetId() ~= QuestConsts.EnterWuhunDungeonQuestThree and
		questVO:GetId() ~= QuestConsts.ExitWuhunDungeonQuestThree and
		questVO:GetId() ~= QuestConsts.EnterWuhunDungeonQuestFour and
		questVO:GetId() ~= QuestConsts.ExitWuhunDungeonQuestFour and
		questVO:GetId() ~= QuestConsts.EnterWuhunDungeonQuestFive and
		questVO:GetId() ~= QuestConsts.ExitWuhunDungeonQuestFive and
		questVO:GetId() ~= QuestConsts.DominateRoadClick1 and
		questVO:GetId() ~= QuestConsts.DominateRoadClick2 and
		questVO:GetId() ~= QuestConsts.EnterXSC and
		questVO:GetId() ~= QuestConsts.ExitDungeon and
		questVO:GetId() ~= QuestConsts.EnterBH then
		return;
	end
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
	--新手村
	if questVO:GetId() == QuestConsts.EnterXSC then
		UIStoryChapter:ShowChapter('storyChapter1');
		TimerManager:RegisterTimer(function()
			questVO:Proceed(true);
		end,500,1)
		return;
	end	
	self.autoTimerKey = TimerManager:RegisterTimer(function()
		self.autoTimerKey = nil;
		if self.isStop then
			return;
		end
		--寻路或自动战斗中,返回
		if MainPlayerController:IsMoveState() then return; end
		if AutoBattleController:GetAutoHang() then return; end
		--
		if StoryController:IsStorying() then
			StoryController:RegisterCurrCallBack(function()
				if not self.isStop then
					questVO:Proceed(true); -- 进行任务
				end
			end);
		else
			questVO:Proceed(true); -- 进行任务
		end
		--
	end,2000,1);
end

--执行了手动引导
function QuestGuideManager:OnHandGuide(questVO)
	--如果是日环,取消日环引导
	if questVO:GetType() == QuestConsts.Type_Day then
		self:OnDayHandleGuide();
		return;
	end
	if questVO:GetType() == QuestConsts.Type_Random then
		self:OnQiYuHandleGuide();
		return;
	end
	if questVO:GetType() == QuestConsts.Type_WaBao then
		self:OnWabaoHandleGuide();
		return;
	end
	if questVO:GetType() == QuestConsts.Type_FengYao then
		self:OnFengYaoHandleGuide();
		return;
	end
	if MainPlayerModel.humanDetailInfo.eaLevel >= QuestConsts.AutoLevel then
		return;
	end
	if questVO:GetType() ~= QuestConsts.Type_Trunk then
		return;
	end
	--
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
end

--打断指引
function QuestGuideManager:BreakGuide()
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
	if self.autoDayTimerKey then
		TimerManager:UnRegisterTimer(self.autoDayTimerKey);
		self.autoDayTimerKey = nil;
	end
	self.lastAutoTime = -1;
end


--玩家停下来时
--10s后进行任务引导
function QuestGuideManager:WhenStop()
	if not self.firstCanGo then return; end
	--大于了自动任务等级就不继续了
	if MainPlayerModel.humanDetailInfo.eaLevel >= QuestConsts.AutoLevel then
		return;
	end
--	if AutoBattleController:GetAutoHang() then return; end
	if CPlayerMap.bChangeMaping then return; end
	--非新手期
	if not QuestConsts.IsNewPlayerTrunk then
		self.lastAutoTime = QuestConsts.Auto_Day_Time;
	else
		self.lastAutoTime = QuestConsts.Auto_S_Time;
	end
end

function QuestGuideManager:OnUpdate(interval)
	if self.lastAutoTime == -1 then return; end
	self.lastAutoTime = self.lastAutoTime - interval;
	if self.lastAutoTime < 0 then
		self.lastAutoTime = -1;
		if not MainPlayerController.isEnter then return; end
		if CPlayerMap.bChangeMaping then return; end
		if MainPlayerModel.humanDetailInfo.eaLevel >= QuestConsts.AutoLevel then
			return;
		end
		if AutoBattleController:GetAutoHang() then return; end
		if StoryController:IsStorying() then return; end
		if SitModel:GetSitState() ~= SitConsts.NoneSit then 
			if not SitController:IsAutoSit() then return;end
		end
		if MainPlayerController:IsMoveState() then return; end
		if self.isStop then return; end
		if not self:MapNeedGuide() then return; end
		local questVO = QuestModel:GetTrunkQuest();
		if not questVO then return; end
		--断档30S不操作,拉去挂机点, 现在已经不是这个逻辑了 yanghongbin 2016-11-17
		--非新手期
		if not QuestConsts.IsNewPlayerTrunk then
			if questVO:GetState() == QuestConsts.State_CannotAccept then
				self:DoIdleQuest()
			else
				questVO:Proceed(true);
			end
		else
			questVO:Proceed(true);
		end
	end
end

--显示主线引导
function QuestGuideManager:ShowTrunkGuide(isShow)
	if not UIMainQuest:IsShow() then return; end
	if self.isStop then return; end
	if self.isShowTrunkGuide == isShow then return; end
	self.isShowTrunkGuide = isShow;
	UIMainQuest:ShowTrunkGuide(isShow);
end

--自动战斗时
function QuestGuideManager:OnAutoBattle()
	UIMainQuest:ShowTrunkGuide(false);
end

function QuestGuideManager:OnAutoBattleEnd()
	if self.isShowTrunkGuide then
		UIMainQuest:ShowTrunkGuide(true);
	end
end

--采集类技能施法时
function QuestGuideManager:OnCollect()
	UIMainQuest:ShowTrunkGuide(false);
end

function QuestGuideManager:OnCollectEnd()
	if self.isShowTrunkGuide then
		UIMainQuest:ShowTrunkGuide(true);
	end
end

--停止引导
function QuestGuideManager:StopGuide()
	self:ShowTrunkGuide(false);
	self.isStop = true;
	if self.autoTimerKey then
		TimerManager:UnRegisterTimer(self.autoTimerKey);
		self.autoTimerKey = nil;
	end
	MainPlayerController:StopMove();
	AutoBattleController:CloseAutoHang()
end

--恢复引导
function QuestGuideManager:RecoverGuide()
	self.isStop = false;
	if not self:MapNeedGuide() then
		print("恢复引导失败：：地图不需要引导")
		return;
	end
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then
		print("恢复引导失败：：找不到主线任务")
		return; end
	self:ShowTrunkGuide(true);
	questVO:Proceed(true); -- 进行任务
end

--主线断档时的处理
function QuestGuideManager:OnTrunkBreak()
	if MainPlayerModel.humanDetailInfo.eaLevel >= QuestConsts.AutoLevel then
		return;
	end
	self.isTrunkBreaking = true;
	self:DoTrunkBreak();
end

--执行主线断档处理
function QuestGuideManager:DoTrunkBreak()
	if not self.isTrunkBreaking then return; end
	self:DoIdleQuest();
	--检测悬赏
	if FengYaoModel.fengyaoinfo and FengYaoModel.fengyaoinfo.curState==FengYaoConsts.ShowType_NoAccept or
		FengYaoModel.fengyaoinfo.curState==FengYaoConsts.ShowType_Accepted then
		self:ShowFengYaoGuide();
		return;
	end
	--TODO 检查奇遇
--	if not RandomQuestModel:IsTodayFinish() then
--		self:ShowQiYuGuide();
--		return;
--	end
	--检查挖宝
--	self:ShowWaBaoGuide();

end

function QuestGuideManager:DoIdleQuest()
	if QuestConsts.IsNewPlayerTrunk then return; end
	--依次找到一个可做的任务去做
	AutoBattleController:CloseAutoHang();
	local questVO = QuestModel:GetTrunkQuest();
	if MainPlayerModel.humanDetailInfo.eaLevel < QuestConsts.AutoLevel and questVO and questVO:GetState()~=QuestConsts.State_CannotAccept then
		self:DoTrunkGuide();
		return;
	end
	--日环
	if QuestModel.dqState ~= nil and QuestModel.dqState ~= QuestConsts.QuestDailyStateFinish and QuestModel.dqState ~= QuestConsts.QuestDailyStateNone then
		self:DoDayGuide();
		return;
	end
	--检查讨伐
	if QuestModel:GetLieMoQuest() then
		self:DoTaoFaGuide();
		return;
	end

	--进行挂机
	local cfg = questVO:GetCfg()
	if not cfg then return end
	local recommendTab = split( cfg.cannotAcceptRecommend, "#" )
	for _, recommendStr in ipairs( recommendTab ) do
		local recommend = QuestRecommendFactory:CreateRecommend( recommendStr )
		if recommend:IsAvailable() and recommend:GetType()==QuestConsts.RecommendType_Hang then
			recommend:DoRecommend();
			break;
		end
	end
end

--清除断档时的指引
function QuestGuideManager:ClearTrunkBreakGuide()
	self:OnDayHandleGuide();
	self:OnQiYuHandleGuide();
	self:OnWabaoHandleGuide();
	self:OnFengYaoHandleGuide();
	self.isTrunkBreaking = false;
end

--日环完成时,有主线指引主线,否则执行断档指引
function QuestGuideManager:OnDayFinish()
	self:DoIdleQuest()
end
function QuestGuideManager:OnLieMoFinish()
	UILieMoView:Hide();
	self:DoIdleQuest()
end
--第一次断档时显示日环引导
function QuestGuideManager:ShowDayGuide()
	if self.isShowDayGuide then return; end
	if MainPlayerModel.humanDetailInfo.eaLevel < QuestConsts:GetDQOpenLevel() then
		return;
	end
	--判断当前是否有日环任务
	local questVO = QuestModel:GetDailyQuest();
	if not questVO then
		return;
	end
	--第一次特殊引导
	if ConfigManager:GetRoleCfg().questDayGuide then
		UIMainQuestAll:ShowQuestGuideGirl(QuestConsts.Type_Day,UIFuncGuide.Type_DailyQuest);
	else
		--强制等级验证
		if MainPlayerModel.humanDetailInfo.eaLevel > QuestConsts.MaxDayGuideLvl then
			UIMainQuestAll:ShowQuestGuideGirl(QuestConsts.Type_Day,UIFuncGuide.Type_DailyQuest);
		else
			UIQuestDayFirstGuide:Show();
			UIMainQuest:ShowDailyGuide(true);
		end
		ConfigManager:GetRoleCfg().questDayGuide = true;
		ConfigManager:Save();
	end
	self.isShowDayGuide = true;
end

--执行主线任务
function QuestGuideManager:DoTrunkGuide()
	if StoryController:IsStorying() then return; end
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then return; end
	questVO:OnContentClick();
end

--执行讨伐引导
function QuestGuideManager:DoTaoFaGuide()
	if StoryController:IsStorying() then return; end
--	local questVO = QuestModel:GetTaoFaQuest();
--	if not questVO then return; end
--	TaoFaController.isAuto = true;
--	questVO:OnContentClick();
	local questVO = QuestModel:GetLieMoQuest();
	if not questVO then return; end
	questVO:OnContentClick();
end

--执行日环引导
function QuestGuideManager:DoDayGuide()
	if StoryController:IsStorying() then return; end
	local questVO = QuestModel:GetDailyQuest();
	if not questVO then return; end
	questVO:OnContentClick();
end

--点击了日环引导
function QuestGuideManager:OnDayHandleGuide()
	if not self.isShowDayGuide then return; end
	UIQuestDayFirstGuide:Hide();
	UIMainQuest:ShowDailyGuide(false);
	UIMainQuestAll:CloseQuestGuide(UIFuncGuide.Type_DailyQuest);
	self.isShowDayGuide = false;
end

--奇遇引导
function QuestGuideManager:ShowQiYuGuide()
	if self.isShowQiYuGuide then return; end
	local func = FuncManager:GetFunc(FuncConsts.RandomQuest);
	if not func then return; end
	if func:GetState() ~= FuncConsts.State_Open then
		return;
	end
	if not RandomQuestModel:GetQuest() then return; end
	--第一次特殊引导
	if ConfigManager:GetRoleCfg().qiyuGuide then
		UIMainQuestAll:ShowQuestGuideGirl(QuestConsts.Type_Random,UIFuncGuide.Type_QuestQiYu);
	else
		if MainPlayerModel.humanDetailInfo.eaLevel > func:GetCfg().open_prama + 10 then
			UIMainQuestAll:ShowQuestGuideGirl(QuestConsts.Type_Random,UIFuncGuide.Type_QuestQiYu);
		else
			UIMainQuestAll:ShowQuestGuide(QuestConsts.Type_Random,UIFuncGuide.Type_QuestQiYu,StrConfig["funcguide003"]);
		end
		ConfigManager:GetRoleCfg().qiyuGuide = true;
		ConfigManager:Save();
	end
	self.isShowQiYuGuide = true;
end

--点击了奇遇引导
function QuestGuideManager:OnQiYuHandleGuide()
	if not self.isShowQiYuGuide then return; end
	UIMainQuestAll:CloseQuestGuide(UIFuncGuide.Type_QuestQiYu);
	self.isShowQiYuGuide = false;
end

--挖宝引导
function QuestGuideManager:ShowWaBaoGuide()
	if self.isShowWaBaoGuide then return; end
	local func = FuncManager:GetFunc(FuncConsts.WaBao);
	if not func then return; end
	if func:GetState() ~= FuncConsts.State_Open then
		return;
	end
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_WaBao, 0 )
	if not QuestModel:GetQuest(questId) then return; end
	--第一次特殊引导
	if ConfigManager:GetRoleCfg().wabaoGuide then
		UIMainQuestAll:ShowQuestGuideGirl(QuestConsts.Type_WaBao,UIFuncGuide.Type_QuestWaBao);
	else
		if MainPlayerModel.humanDetailInfo.eaLevel > func:GetCfg().open_prama + 10 then
			UIMainQuestAll:ShowQuestGuideGirl(QuestConsts.Type_WaBao,UIFuncGuide.Type_QuestWaBao);
		else
			UIMainQuestAll:ShowQuestGuide(QuestConsts.Type_WaBao,UIFuncGuide.Type_QuestWaBao,StrConfig["funcguide001"]);
		end
		ConfigManager:GetRoleCfg().wabaoGuide = true;
		ConfigManager:Save();
	end
	self.isShowWaBaoGuide = true;
end

--点击了挖宝引导
function QuestGuideManager:OnWabaoHandleGuide()
	if not self.isShowWaBaoGuide then return; end
	UIMainQuestAll:CloseQuestGuide(UIFuncGuide.Type_QuestWaBao);
	self.isShowWaBaoGuide = false;
end

--悬赏引导
function QuestGuideManager:ShowFengYaoGuide()
	if self.isShowFengYaoGuide then return; end
	local func = FuncManager:GetFunc(FuncConsts.FengYao);
	if not func then return; end
	if func:GetState() ~= FuncConsts.State_Open then
		return;
	end
	if not FengYaoModel.fengyaoinfo then return; end
	if FengYaoModel.fengyaoinfo.curState~=FengYaoConsts.ShowType_NoAccept and 
		FengYaoModel.fengyaoinfo.curState~=FengYaoConsts.ShowType_Accepted then
		return;
	end
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_FengYao, 0 );
	if not QuestModel:GetQuest(questId) then return; end
	--第一次特殊引导
	if ConfigManager:GetRoleCfg().fengyaoGuide then
		UIMainQuestAll:ShowQuestGuideGirl(QuestConsts.Type_FengYao,UIFuncGuide.Type_QuestFengYao);
	else
		if MainPlayerModel.humanDetailInfo.eaLevel > func:GetCfg().open_prama + 10 then
			UIMainQuestAll:ShowQuestGuideGirl(QuestConsts.Type_FengYao,UIFuncGuide.Type_QuestFengYao);
		else
			return
			--UIMainQuestAll:ShowQuestGuide(QuestConsts.Type_FengYao,UIFuncGuide.Type_QuestFengYao,StrConfig["funcguide002"]);
		end
		ConfigManager:GetRoleCfg().fengyaoGuide = true;
		ConfigManager:Save();
	end
	self.isShowFengYaoGuide = true;
end

--点击了悬赏引导
function QuestGuideManager:OnFengYaoHandleGuide()
	if not self.isShowFengYaoGuide then return; end
	UIMainQuestAll:CloseQuestGuide(UIFuncGuide.Type_QuestFengYao);
	self.isShowFengYaoGuide = false;
end

--当前地图是否需要做任务引导
function QuestGuideManager:MapNeedGuide()
	local mapId = MainPlayerController:GetMapId();
	local mapCfg = t_map[mapId];
	if not mapCfg then return false; end
	-- 1：野外地图 2：主城地图 11：任务副本
	if mapCfg.type==1 or mapCfg.type==2 or mapCfg.type==11 then
		return true;
	else
		return false;
	end
end

--场景开始加载
function QuestGuideManager:OnSceneLoadStart()
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then return; end
	if questVO:GetId() == QuestConsts.EnterCity then
		ClickLog:Send(ClickLog.T_Pack3_Start);
	end
	if questVO:GetId() == QuestConsts.EnterWuhunDungeonQuest then
		ClickLog:Send(ClickLog.T_Pack4_Start);
	end
	if questVO:GetId() == QuestConsts.EnterXSC then
		ClickLog:Send(ClickLog.T_PackXSC_Start);
	end
end

--场景加载完毕
function QuestGuideManager:OnSceneLoadEnd()
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then return; end
	if questVO:GetId() == QuestConsts.EnterCity then
		ClickLog:Send(ClickLog.T_Pack3_Finish);
	end
	if questVO:GetId() == QuestConsts.EnterWuhunDungeonQuest then
		ClickLog:Send(ClickLog.T_Pack4_Finish);
	end
	if questVO:GetId() == QuestConsts.EnterXSC then
		ClickLog:Send(ClickLog.T_PackXSC_Finish);
	end
end