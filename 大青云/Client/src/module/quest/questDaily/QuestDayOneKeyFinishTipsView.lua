--[[
日环：一键完成tips
2015年3月9日15:08:30
haohu
]]

UIQuestDayOneKeyFinishTips = BaseUI:new("UIQuestDayOneKeyFinishTips");

function UIQuestDayOneKeyFinishTips:Create()
	self:AddSWF("taskDay1KeyFinishTips.swf", true, "top");
end

function UIQuestDayOneKeyFinishTips:OnLoaded( objSwf )
	objSwf.txtPrompt1.htmlText = string.format( StrConfig['quest140'], QuestConsts.QuestDailyMaxStar );
	objSwf.txtPrompt2.text = StrConfig['quest141'];
	objSwf.txtPrompt3.text = StrConfig['quest142'];
end

function UIQuestDayOneKeyFinishTips:OnShow()
	self:UpdateShow();
	self:UpdatePos();
end

function UIQuestDayOneKeyFinishTips:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local questVO = QuestModel:GetDailyQuest();
	if not questVO then return; end
	local currentRound = questVO:GetRound();
	if not currentRound then return; end
	local restRoundNum = QuestConsts.QuestDailyNum - currentRound + 1; -- 日环总数 - 当前进行中 + 1 == 剩余未完成的日环任务
	local price = QuestConsts:Get1KeyFinishCost(); -- 常量表一件完成单环花费
	objSwf.txtCost.htmlText = string.format( StrConfig['quest143'], price * restRoundNum );
	local expPerRound, moneyPerRound, zhenqiPerRound = self:GetRewardPerRound();
	local exp    = toint( expPerRound * restRoundNum, 0.5 );
	local money  = toint( moneyPerRound * restRoundNum, 0.5 );
	local zhenqi = toint( zhenqiPerRound * restRoundNum, 0.5 );
	objSwf.txtExp.text    = exp;
	objSwf.txtMoney.text  = money;
	objSwf.txtZhenqi.text = zhenqi;
end

-- 获取每环的经验、金钱、灵力奖励
function UIQuestDayOneKeyFinishTips:GetRewardPerRound()
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local exp, money, zhenqi = 0, 0, 0;
	local star = QuestConsts.QuestDailyMaxStar;
	local starAddition = 1;
	local findCfgResult = false
	for id, cfg in pairs(t_dailyquest) do
		if cfg.minLevel <= level and level <= cfg.maxLevel then
			findCfgResult = true
			exp    = cfg.expReward;
			money  = cfg.moneyReward;
			zhenqi = cfg.zhenqiReward;
			starAddition = 1 + cfg["additionStar" .. star] / 100;
			break;
		end
	end
	if not findCfgResult then
		_G.Error( string.format( "cannot find t_dailyquest configs of player-level:%s", level ) )
		_G.Debug(debug.traceback())
	end
	exp    = toint( exp * starAddition, 0.5 );
	money  = toint( money * starAddition, 0.5 );
	zhenqi = toint( zhenqi * starAddition, 0.5 );
	return exp, money, zhenqi;
end

function UIQuestDayOneKeyFinishTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), TipsConsts.Dir_RightDown );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIQuestDayOneKeyFinishTips:ListNotificationInterests()
	return {
		NotifyConsts.StageMove
	};
end

--处理消息
function UIQuestDayOneKeyFinishTips:HandleNotification(name, body)
	if name == NotifyConsts.StageMove then
		self:UpdatePos();
	end
end
