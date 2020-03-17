--[[
日环任务：tips
2015年1月14日14:19:22
haoh
]]

_G.UIQuestDayTips = BaseUI:new("UIQuestDayTips");

function UIQuestDayTips:Create()
	self:AddSWF("taskDayTips.swf", true, "top");
end

function UIQuestDayTips:OnLoaded( objSwf )
	objSwf.txtQuestStar.text      = StrConfig['quest130'];
	objSwf.txtCanAdvance.htmlText = StrConfig['quest137'];
	objSwf.txtPrompt.text         = StrConfig['quest136']
	-- objSwf.txtPrompt2.htmlText    = string.format( StrConfig['quest131'], QuestConsts.QuestDailyNum );
	-- objSwf.txtPrompt3.text        = StrConfig['quest132'];
	objSwf.starIndicator.maximum  = QuestConsts.QuestDailyMaxStar;
	objSwf.txtExp.autoSize        = "left"
end

function UIQuestDayTips:OnShow()
	self:UpdateShow();
	self:UpdatePos();
end

function UIQuestDayTips:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local wWidth, wHeight = UIManager:GetWinSize();
	objSwf._x = wWidth - self:GetWidth();
	local monsePos = _sys:getRelativeMouse();--获取鼠标位置
	objSwf._y = monsePos.y + 20;
end

function UIQuestDayTips:UpdateShow()
	local questVO = QuestModel:GetDailyQuest();
	if not questVO then return; end
	self:ShowRound( questVO ); -- 环数
	self:ShowContent( questVO ); -- 任务内容
	self:ShowStar( questVO ); -- 任务星级别
	self:ShowPrompt( questVO ); -- 任务提示信息
	self:ShowQuestReward( questVO ); -- 日环任务奖励列表 
	-- self:ShowDayReward( questVO ); -- 日环全部完成奖励列表
	self:ShowExp( questVO ); -- 日环奖励经验与当前经验比例,百分数
	self:ShowStageReward(questVO);--显示5,10,15环的固定奖励
end

function UIQuestDayTips:ShowRound(questVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local round = questVO:GetRound();
	objSwf.txtRound.htmlText = string.format( StrConfig['quest133'], round )
end

function UIQuestDayTips:ShowContent(questVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local goal = questVO:GetGoal();
	local goalDes = goal:GetGoalLabel( 14, "#5deaff" );
	objSwf.txtQuest.htmlText = goalDes;
	if isDebug then
		objSwf.txtQuest.htmlText = goalDes .." ID:" .. questVO:GetId();
	end
end

function UIQuestDayTips:ShowStar(questVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local star = questVO:GetStarLvl();
	objSwf.starIndicator.value = star;
	objSwf.txtCanAdvance._visible = star < QuestConsts.QuestDailyMaxStar;
end

function UIQuestDayTips:ShowPrompt(questVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local currRound = questVO:GetRound();
	local numToDraw = self:GetNumRoundToDraw( currRound );
	if not numToDraw then return; end
	objSwf.txtPrompt1.htmlText = string.format( StrConfig['quest134'], numToDraw );
end

function UIQuestDayTips:ShowStageReward(questVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local currRound = questVO:GetRound();
	local level = 0;
	level = MainPlayerModel.humanDetailInfo.eaLevel;
	local cfg = t_dailygroup[level];
	local rewardItemStr;
	if currRound<6 then
		rewardItemStr = cfg.reward_item5;
	elseif currRound>5 and currRound<11 then
		rewardItemStr = cfg.reward_item10;
	elseif currRound>10 and currRound<16 then
		rewardItemStr = cfg.reward_item15;
	else
		rewardItemStr = cfg.reward_item;
	end
	local rewardList = RewardManager:Parse(rewardItemStr );
	local list = objSwf.listReward;
	list.dataProvider:cleanUp();
	for i = 1, #rewardList do
		list.dataProvider:push( rewardList[i] );
	end
	list:invalidateData();
	
end

function UIQuestDayTips:GetNumRoundToDraw( currRound )
	local drawRound;
	for i = 1, #QuestConsts.QuestDailyDrawRounds do
		drawRound = QuestConsts.QuestDailyDrawRounds[i];
		if currRound <= drawRound then
			return drawRound - currRound + 1;  -- 抽奖环 - 当前环 + 1 == 还需要完成多少环抽奖(当前环为未完成，所以+1)
		end
	end
end

function UIQuestDayTips:ShowQuestReward(questVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	local rewardList = QuestUtil:GetQuestDayRoundRewardProvider();
	for i = 1, #rewardList do
		list.dataProvider:push( rewardList[i] );
	end
	list:invalidateData();
end

function UIQuestDayTips:ShowDayReward(questVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.listReward;
	list.dataProvider:cleanUp();
	local rewardList = QuestUtil:GetQuestDayRewardProvider();
	for i = 1, #rewardList do
		list.dataProvider:push( rewardList[i] );
	end
	list:invalidateData();
end

function UIQuestDayTips:ShowExp(questVO)
	local objSwf = self.objSwf
	if not objSwf then return end
	local rewardExp, _, _ = questVO:GetRewards()
	local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel
	local lvlUpExp = t_lvup[ playerLevel ].exp
	objSwf.txtExp.text = string.format( StrConfig['quest135'], rewardExp/lvlUpExp * 100 );
end

-------------------------------消息处理------------------------------

--监听消息
function UIQuestDayTips:ListNotificationInterests()
	return {
		NotifyConsts.QuestAdd,
		NotifyConsts.QuestUpdate,
	};
end

--消息处理
function UIQuestDayTips:HandleNotification( name, body )
	if name == NotifyConsts.QuestAdd then
		self:OnQuestAdd( body.id );
	elseif name == NotifyConsts.QuestUpdate then
		self:OnQuestUpdate( body.id );
	end
end

function UIQuestDayTips:OnQuestAdd( questId )
	if QuestUtil:IsDailyQuest( questId ) then
		self:UpdateShow();
	end
end

function UIQuestDayTips:OnQuestUpdate( questId )
	if QuestUtil:IsDailyQuest( questId ) then
		self:UpdateShow();
	end
end