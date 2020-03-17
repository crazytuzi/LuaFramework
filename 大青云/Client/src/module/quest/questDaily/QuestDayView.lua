--[[
任务面板:日环任务
haohu
2014年12月10日14:24:31
]]

_G.UIQuestDay = BaseUI:new("UIQuestDay");
UIQuestDay.isUIQuestDayTips=false;--是否为日环任务面板tips

function UIQuestDay:Create()
	self:AddSWF( "taskDayPanel.swf", true, nil );
end

function UIQuestDay:OnLoaded(objSwf)
	self:InitBtnDraw(objSwf);
	self:InitProgress(objSwf);
	-- self:InitDayFinishRewards(objSwf);
	self:InitGoalInfo(objSwf);
	self:InitOneKeyFinish(objSwf);
	self:InitStarLevel(objSwf);
	self:InitQuestReward(objSwf);
	self:InitLabels(objSwf);
end

function UIQuestDay:InitBtnDraw( objSwf )
	local panelGoing = objSwf.panelGoing;
	-- 5, 10, 15, 20 环完成可抽奖
	panelGoing.btnDraw1.data  = { round = QuestConsts.QuestDailyDrawRounds[1] };
	panelGoing.btnDraw2.data = { round = QuestConsts.QuestDailyDrawRounds[2] };
	panelGoing.btnDraw3.data = { round = QuestConsts.QuestDailyDrawRounds[3] };
	panelGoing.btnDraw4.data = { round = QuestConsts.QuestDailyDrawRounds[4] };
	panelGoing.btnDraw1.rollOver  = function(e) self:OnBtnDrawRollOver(e); end
	panelGoing.btnDraw2.rollOver = function(e) self:OnBtnDrawRollOver(e); end
	panelGoing.btnDraw3.rollOver = function(e) self:OnBtnDrawRollOver(e); end
	panelGoing.btnDraw4.rollOver = function(e) self:OnBtnDrawRollOver(e); end
	panelGoing.btnDraw1.rollOut   = function() self:OnBtnDrawRollOut(); end
	panelGoing.btnDraw2.rollOut  = function() self:OnBtnDrawRollOut(); end
	panelGoing.btnDraw3.rollOut  = function() self:OnBtnDrawRollOut(); end
	panelGoing.btnDraw4.rollOut  = function() self:OnBtnDrawRollOut(); end
	
	panelGoing.box1.data  = { round = QuestConsts.QuestDailyDrawRounds[1] };
	panelGoing.box2.data = { round = QuestConsts.QuestDailyDrawRounds[2] };
	panelGoing.box3.data = { round = QuestConsts.QuestDailyDrawRounds[3] };
	panelGoing.box4.data = { round = QuestConsts.QuestDailyDrawRounds[4] };
	panelGoing.box1.rollOver  = function(e) self:OnBtnDrawRollOver(e); end
	panelGoing.box2.rollOver = function(e) self:OnBtnDrawRollOver(e); end
	panelGoing.box3.rollOver = function(e) self:OnBtnDrawRollOver(e); end
	panelGoing.box4.rollOver = function(e) self:OnBtnDrawRollOver(e); end
	panelGoing.box1.rollOut   = function() self:OnBtnDrawRollOut(); end
	panelGoing.box2.rollOut  = function() self:OnBtnDrawRollOut(); end
	panelGoing.box3.rollOut  = function() self:OnBtnDrawRollOut(); end
	panelGoing.box4.rollOut  = function() self:OnBtnDrawRollOut(); end
end

function UIQuestDay:InitProgress( objSwf )
	local progressIndicator = objSwf.panelGoing.progressIndicator;
	progressIndicator.maximum = QuestConsts.QuestDailyNum;
	-- progressIndicator.rollOver = function(e) self:OnProgressOver(e); end
	-- progressIndicator.rollOut  = function() self:OnProgressOut(); end
end

function UIQuestDay:InitDayFinishRewards( objSwf )
	-- RewardManager:RegisterListTips( objSwf.panelGoing.rewardList );
end

function UIQuestDay:InitGoalInfo( objSwf )
	objSwf.panelGoing.btnDes.autoSize = true;
	objSwf.panelGoing.btnDes.click         = function() self:OnQuestGoalClick(); end
	objSwf.panelGoing.btnMap.click         = function() self:OnQuestGoalClick(); end
	objSwf.panelGoing.btnTeleport.click    = function() self:OnBtnTeleportClick(); end
	objSwf.panelGoing.btnTeleport.rollOver = function() self:OnBtnTeleportRollOver(); end
	objSwf.panelGoing.btnTeleport.rollOut  = function() self:OnBtnTeleportRollOut(); end
end

function UIQuestDay:InitOneKeyFinish( objSwf )
	local panelGoing = objSwf.panelGoing;
	panelGoing.btnOneKeyFinish.click    = function() self:OnOneKeyFinishClick(); end
	panelGoing.btnOneKeyFinish.rollOver = function() self:OnOneKeyFinishRollOver(); end
	panelGoing.btnOneKeyFinish.rollOut  = function() self:OnOneKeyFinishRollOut(); end
end

function UIQuestDay:InitStarLevel( objSwf )
	local panelGoing = objSwf.panelGoing;
	panelGoing.starIndicator.maximum   = QuestConsts.QuestDailyMaxStar;
	panelGoing.starIndicator.rollOver  = function() self:OnStarRollOver(); end
	panelGoing.starIndicator.rollOut   = function() self:OnStarRollOut(); end
	panelGoing.btnAddStar.click        = function() self:OnBtnAddStarClick(); end
	panelGoing.btnAddStar.rollOver     = function() self:OnBtnAddStarRollOver(); end
	panelGoing.btnAddStar.rollOut      = function() self:OnBtnAddStarRollOut(); end
	panelGoing.btnAddStar._visible = false;
end

function UIQuestDay:InitQuestReward( objSwf )
	RewardManager:RegisterListTips( objSwf.panelGoing.questRewardList );
end

function UIQuestDay:InitLabels( objSwf )
	local panelGoing = objSwf.panelGoing;
	-- panelGoing.lblDrawPrompt.htmlText    = StrConfig['quest101'];
	-- panelGoing.lblRewardPrompt.htmlText  = StrConfig['quest102'];
	panelGoing.lblConsume.htmlText       = string.format( StrConfig['quest103'], QuestConsts:Get1KeyFinishCost() );
	panelGoing.lblPrompt.text            = StrConfig['quest104'];
	panelGoing.lblAutoAddStarPrompt.text = string.format( StrConfig['quest121'], QuestConsts.QuestDailyMaxStar )
	panelGoing.lblAutoAddStarPrompt._visible = false;
end

function UIQuestDay:OnShow()
	self:UpdateShow();
end

function UIQuestDay:UpdateShow()
	local state = QuestModel:GetDQState();
	if state == QuestConsts.QuestDailyStateGoing then
		self:ShowTodayOnGoing(); -- 今日进行中
	elseif state == QuestConsts.QuestDailyStateDrawing then
		self:ShowDrawing(); --显示抽奖中
	elseif state == QuestConsts.QuestDailyStateFinish then
		self:ShowTodayFinish(); -- 今日已完成
	elseif state == QuestConsts.QuestDailyStateNone then
		-- self:ShowLevelNotEnough(); --don't need to do so far. if player's level is not enough, this ui panel will never open.
	end
end

function UIQuestDay:ShowDrawing()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panelGoing = objSwf.panelGoing;
	objSwf.panelFinish._visible = false;
	panelGoing._visible  = true;
	panelGoing.btnOneKeyFinish.disabled = true
	-- local list = panelGoing.rewardList;
	-- list.dataProvider:cleanUp();
	-- list:invalidateData();
	panelGoing.starIndicator.value = 0;
	panelGoing.btnAddStar.disabled = true;
	-- list = panelGoing.questRewardList;
	-- list.dataProvider:cleanUp();
	-- list:invalidateData();
end

-- 今日进行中
function UIQuestDay:ShowTodayOnGoing()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local questVO = QuestModel:GetDailyQuest();
	if not questVO then return; end
	objSwf.panelGoing._visible  = true;
	objSwf.panelGoing.btnOneKeyFinish.disabled = false
	objSwf.panelFinish._visible = false;
	self:ShowProgress( questVO );
	self:ShowDayFinishRewards( questVO );
	self:ShowCurrRound( questVO );
	self:ShowGoalInfo( questVO );
	self:ShowStarInfo( questVO );
	self:ShowQuestRewards( questVO );
	self:ShowBtnDrawState()
end

-- 今日已完成
function UIQuestDay:ShowTodayFinish()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.panelGoing._visible  = false;
	objSwf.panelFinish._visible = true;
	local finishInfo = QuestModel:GetDailyFinishInfo();
	if finishInfo then
		local itemRewardProvider, noneItemRewardProvider = self:GetRewardProvider();
		-- 日环任务奖励，以及今日完成奖励(物品奖励)
		local rewardList = objSwf.panelFinish.rewardList;
		rewardList.dataProvider:cleanUp();
		for i = 1, #itemRewardProvider do
			rewardList.dataProvider:push( UIData.encode(itemRewardProvider[i]) );
		end
		rewardList:invalidateData();
		-- 日环任务奖励，以及今日完成奖励(非物品奖励)
		local noneItemRewardList = objSwf.panelFinish.noneItemRewardList;
		noneItemRewardList.dataProvider:cleanUp();
		for j = 1, #noneItemRewardProvider do
			noneItemRewardList.dataProvider:push( UIData.encode(noneItemRewardProvider[j]) );
		end
		noneItemRewardList:invalidateData();
		-- 日环抽奖奖励(物品奖励)
		--[[local drawRewardList = objSwf.panelFinish.drawRewardList;
		drawRewardList.dataProvider:cleanUp();
		local drawItemReward, drawNoneItemReward = self:GetDrawRewardProvider();
		for k = 1, #drawItemReward do
			drawRewardList.dataProvider:push( UIData.encode( drawItemReward[k] ) );
		end
		drawRewardList:invalidateData();]]
		-- 日环抽奖奖励(非物品奖励)
		--[[local dNoneItemRewardList = objSwf.panelFinish.dNoneItemRewardList;
		dNoneItemRewardList.dataProvider:cleanUp();
		for j = 1, #drawNoneItemReward do
			dNoneItemRewardList.dataProvider:push( UIData.encode( drawNoneItemReward[j] ) );
		end
		dNoneItemRewardList:invalidateData();]]
	else
		QuestController:ReqDailyFinishInfo();
	end
end

-- 日环进度信息
function UIQuestDay:ShowProgress( questVO )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local round = questVO:GetRound();
	objSwf.panelGoing.progressIndicator.value = round - 1; -- 完成后进度增加，进行中不增加
end

-- 今日完成奖励
function UIQuestDay:ShowDayFinishRewards( questVO )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- local rewardList = QuestUtil:GetQuestDayRewardProvider();
	-- local list = objSwf.panelGoing.rewardList;
	-- list.dataProvider:cleanUp();
	-- list.dataProvider:push( unpack(rewardList) );
	-- list:invalidateData();
end

-- 当前环数
function UIQuestDay:ShowCurrRound( questVO )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.panelGoing.numLoader:drawStr( string.format( "%sp%s", questVO:GetRound(), QuestConsts.QuestDailyNum ) );
end

-- 任务目标
function UIQuestDay:ShowGoalInfo( questVO )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local goal = questVO:GetGoal(); -- goalVO
	if not goal then
		Error( string.format( "cannot find quest goal.questId:%s", questVO:GetId() ) );
	end
	local goalDes = goal:GetGoalLabel(14, "#d5b772");
	if not goal.guideParam[1] then return; end
	local posId = toint(goal.guideParam[1]);
	local point = QuestUtil:GetQuestPos(posId);
	local mapId = point.mapId;
	local mapName = MapUtils:GetMapName(mapId);
	local mapDes = string.format(StrConfig['quest108'], mapName);
	local panelGoing = objSwf.panelGoing;
	panelGoing.btnDes.htmlLabel = goalDes;
	panelGoing.btnMap.htmlLabel = mapDes;

	local round = questVO:GetRound();
	local currRound = 	round - 1; -- 完成后进度增加，进行中不增加
	local restRound = QuestConsts.QuestDailyTotal - currRound;
	
	local numToDraw = self:GetNumRoundToDraw( );
	if not numToDraw then return; end
	panelGoing.lblDrawPrompt.htmlText    = string.format( StrConfig['quest106'], currRound, numToDraw);
end

function UIQuestDay:GetNumRoundToDraw( )
	local questVO = QuestModel:GetDailyQuest();
	if not questVO then return; end
	local currRound = questVO:GetRound();
	local drawRound;
	for i = 1, #QuestConsts.QuestDailyDrawRounds do
		drawRound = QuestConsts.QuestDailyDrawRounds[i];
		if currRound <= drawRound then
			return drawRound - currRound + 1;  -- 抽奖环 - 当前环 + 1 == 还需要完成多少环抽奖(当前环为未完成，所以+1)
		end
	end
end

-- 任务星级
function UIQuestDay:ShowStarInfo( questVO )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local starLvl = questVO:GetStarLvl();
	local panelGoing = objSwf.panelGoing;
	panelGoing.starIndicator.value = starLvl;
	panelGoing.btnAddStar.disabled = starLvl == QuestConsts.QuestDailyMaxStar;
end

-- 任务奖励
function UIQuestDay:ShowQuestRewards( questVO )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.panelGoing.questRewardList;
	list.dataProvider:cleanUp();
	local rewardList = QuestUtil:GetQuestDayRoundRewardProvider();
	for i = 1, #rewardList do
		list.dataProvider:push( rewardList[i] );
	end
	list:invalidateData();

	local items = {objSwf.panelGoing.questRewardItem1,
		objSwf.panelGoing.questRewardItem2,
		objSwf.panelGoing.questRewardItem3,
		objSwf.panelGoing.questRewardItem4,
		objSwf.panelGoing.questRewardItem5, }
	UIDisplayUtil:HCenterLayout(#rewardList, items, 58, 677, 424);
	items = nil;
end

-- 今日日环完成：获取环任务奖励dataprovider
function UIQuestDay:GetRewardProvider()
	local itemRewardList = {}; -- 返回:物品奖励列表
	local noneItemList = {}; -- 返回:非物品奖励列表
	local rewardExp, rewardMoney, rewardZhenqi, rewardJingYuan = 0, 0, 0, 0; -- 奖励经验、金钱、灵力
	local finishInfo = QuestModel:GetDailyFinishInfo();
	if finishInfo then
		-- 计算经验、金钱、灵力奖励
		for _, questInfo in ipairs( finishInfo.list ) do
			local questCfg = t_dailyquest[questInfo.id];
			if questCfg then
				local multiple = questInfo.double;
				local star = questInfo.star;
				if star then
					local starAddition = questCfg["additionStar" .. star];
					if starAddition then
						local starAddition = 1 + questCfg["additionStar" .. star] / 100;
						local coefficient = multiple * starAddition;
						rewardExp    = rewardExp + questCfg.expReward * coefficient;
						rewardMoney  = rewardMoney + questCfg.moneyReward * coefficient;
						rewardZhenqi = rewardZhenqi + questCfg.zhenqiReward * coefficient;
						rewardJingYuan = math.ceil(rewardJingYuan + toint(GetCommaTable(questCfg.itemReward)[2]) * coefficient);
					else
						Debug("error:Bad value of daily quest star, expect:1-5, get " .. star);
					end
				else
					Debug("error: The star level of daily quest is nil");
				end
			end
		end
		local level = MainPlayerModel.humanDetailInfo.eaLevel;
		local groupCfg = t_dailygroup[level];
		if groupCfg then
			if groupCfg.reward_exp then
				rewardExp    = rewardExp + groupCfg.reward_exp;
			end
			if groupCfg.reward_money then
				rewardMoney  = rewardMoney + groupCfg.reward_money;
			end
			if groupCfg.reward_zhenqi then
				rewardZhenqi = rewardZhenqi + groupCfg.reward_zhenqi;
			end
		end
		-- 非物品奖励列表(顺序不能变,图标是这个顺序摆的)经验-金钱-灵力
		noneItemList = {
			{ htmlText = toint(rewardExp, 0.5) },
			{ htmlText = toint(rewardMoney, 0.5) },
--			{ htmlText = toint(rewardZhenqi, 0.5) },
			{ htmlText = toint(rewardJingYuan, 0.5) }
		};
		-- 计算物品奖励
		local rewardItemStr = groupCfg.reward_item;
		if rewardItemStr ~= "" then
			local itemList = split(rewardItemStr,"#");
			for _, itemStr in ipairs(itemList) do
				local item = split( itemStr, "," );
				local itemId = tonumber( item[1] );
				local itemCount = tonumber( item[2] );
				local itemCfg = t_item[itemId] or t_equip[itemId];
				if itemCfg then
					local itemName = itemCfg.name;
					local rewardItemTxt = string.format( StrConfig['quest109'], itemName, itemCount );
					table.push( itemRewardList, {htmlText = rewardItemTxt} );
				end
			end
		end
	end
	return itemRewardList, noneItemList;
end

-- 今日日环完成：获取抽奖奖励dataprovider
function UIQuestDay:GetDrawRewardProvider()
	local itemRewardList = {}; -- 返回:物品奖励列表
	local noneItemList = {}; -- 返回:非物品奖励列表
	local rewardExp, rewardMoney, rewardZhenqi = 0, 0, 0; -- 奖励经验、金钱、灵力
	local finishInfo = QuestModel:GetDailyFinishInfo();
	if finishInfo then
		for i = 1, #finishInfo.rewardList do
			local itemInfo = finishInfo.rewardList[i];
			local itemId = itemInfo.id;
			local itemNum = itemInfo.num;
			local itemCfg = t_item[itemId] or t_equip[itemId];
			if itemCfg then
				if itemId == enAttrType.eaExp then
					rewardExp = rewardExp + itemNum;
				elseif itemId == enAttrType.eaBindGold then
					rewardMoney = rewardMoney + itemNum;
				elseif itemId == enAttrType.eaZhenQi then
					rewardZhenqi = rewardZhenqi + itemNum;
				else
					-- 物品奖励
					local itemName = itemCfg.name;
					local rewardItemTxt = string.format( StrConfig['quest109'], itemName, itemNum );
					table.push( itemRewardList, { htmlText = rewardItemTxt } );
				end
			end
		end
	end
	-- 非物品奖励列表(顺序不能变,图标是这个顺序摆的)经验-金钱-灵力
	noneItemList = {
		{ htmlText = toint( rewardExp, 0.5 ) },
		{ htmlText = toint( rewardMoney, 0.5 ) },
		{ htmlText = toint( rewardZhenqi, 0.5 ) }
	};
	return itemRewardList, noneItemList;
end

function UIQuestDay:ShowBtnDrawState()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panelGoing = objSwf.panelGoing;
	local currQuestVO = QuestModel:GetDailyQuest();
	local currentRound = currQuestVO and currQuestVO:GetRound();
	if not currentRound then return; end
	for i=1,4 do
		local round = QuestConsts.QuestDailyDrawRounds[i]
		local dRound = round - currentRound + 1; -- 抽奖环 - 当前环 + 1 == 还需要完成多少环抽奖(当前环为未完成，所以+1)
		if dRound > 0 then
			panelGoing["btnDraw"..i]._visible = true
			panelGoing["box"..i]._visible = false
		else
			panelGoing["btnDraw"..i]._visible = false
			panelGoing["box"..i]._visible = true
		end
	end
end

-------------------------------事件处理------------------------------

function UIQuestDay:OnBtnDrawRollOver( e )
	self.isUIQuestDayTips=true
	local currQuestVO = QuestModel:GetDailyQuest();
	-- local currentRound = currQuestVO and currQuestVO:GetRound();
	-- if not currentRound then return; end
	-- print("================================e.target.data.round",e.target.data.round)
	-- local dRound = e.target.data.round - currentRound + 1; -- 抽奖环 - 当前环 + 1 == 还需要完成多少环抽奖(当前环为未完成，所以+1)
	-- if dRound > 0 then
		-- TipsManager:ShowBtnTips( string.format(StrConfig['quest105'], dRound) );
		-- return
	-- end
	-- TipsManager:ShowBtnTips( StrConfig['quest149'] );
	local level = 0;
	level = MainPlayerModel.humanDetailInfo.eaLevel;
	local cfg = t_dailygroup[level];
	local rewardItemStr;
	if e.target.data.round==5 then
		rewardItemStr = cfg.reward_item5;
	elseif e.target.data.round==10 then
		rewardItemStr = cfg.reward_item10;
	elseif e.target.data.round==15 then
		rewardItemStr = cfg.reward_item15;
	else
		rewardItemStr = cfg.reward_item;
	end
	local rewardList = RewardManager:Parse(rewardItemStr );
	UIQuestTips:Show(e.target.data.round, rewardList);
end

function UIQuestDay:OnBtnDrawRollOut()
	UIQuestTips:Hide();
	self.isUIQuestDayTips=false;
end

function UIQuestDay:OnProgressOver(e)
	local currRound = e.target.value;
	local restRound = QuestConsts.QuestDailyTotal - currRound;
	TipsManager:ShowBtnTips( string.format( StrConfig['quest106'], currRound, restRound) );
end

function UIQuestDay:OnProgressOut()
	TipsManager:Hide();
end

function UIQuestDay:OnQuestGoalClick()
	local state = QuestModel:GetDQState();
	if state == QuestConsts.QuestDailyStateGoing then
		self:DoGuide()
	elseif state == QuestConsts.QuestDailyStateDrawing then
		FloatManager:AddNormal( StrConfig["quest401"] );
	end
end

function UIQuestDay:DoGuide()
	local quest = QuestModel:GetDailyQuest()
	if not quest then return end
	quest:OnContentClick()
end

function UIQuestDay:OnBtnTeleportClick()
	local quest = QuestModel:GetDailyQuest()
	if not quest then return end
	quest:Teleport()
end

function UIQuestDay:OnBtnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function UIQuestDay:OnBtnTeleportRollOut()
	TipsManager:Hide()
end

function UIQuestDay:OnOneKeyFinishClick()
	-- 判断vip等级是否达到
	--todo 屏蔽掉 不考虑VIP情况了
--[[	local vipRight = VipController:GetOneKeyFinish()
	if vipRight < 1 then
		FloatManager:AddCenter( StrConfig['quest162'] );
		return;
	end]]
	-- 选择倍数
	UIQuestDayMultipleOption:Show();
end

function UIQuestDay:OnOneKeyFinishRollOver()
	--UIQuestDayOneKeyFinishTips:Show();
end

function UIQuestDay:OnOneKeyFinishRollOut()
	--UIQuestDayOneKeyFinishTips:Hide();
end

function UIQuestDay:OnStarRollOver()
--	TipsManager:ShowBtnTips( StrConfig['quest402'] );
end

function UIQuestDay:OnStarRollOut()
	TipsManager:Hide();
end

--点击升星
function UIQuestDay:OnBtnAddStarClick()
	local questVO = QuestModel:GetDailyQuest();
	local questId = questVO:GetId();
	QuestController:ReqAddStar( questId );
end

function UIQuestDay:OnBtnAddStarRollOver()
	TipsManager:ShowBtnTips( string.format( StrConfig['quest107'], QuestConsts:GetAddStarCost() ) );
end

function UIQuestDay:OnBtnAddStarRollOut()
	TipsManager:Hide();
end

--设置自动升星
-- function UIQuestDay:OnAutoAddStarClick(e)
-- 	local auto = e.target.selected;
-- 	QuestController:ReqAutoAddStar( auto );
-- end


-------------------------------消息处理------------------------------

--监听消息
function UIQuestDay:ListNotificationInterests()
	return {
		NotifyConsts.QuestAdd,
		NotifyConsts.QuestUpdate,
		NotifyConsts.QuestRemove,
		NotifyConsts.QuestDayFinish,
		NotifyConsts.QuestDailyFullStar,
		NotifyConsts.QuestDailyStateChange,
	};
end

--消息处理
function UIQuestDay:HandleNotification( name, body )
	if name == NotifyConsts.QuestRefreshList then
		self:OnQuestRefreshList();
	elseif name == NotifyConsts.QuestAdd then
		self:OnQuestAdd( body.id );
	elseif name == NotifyConsts.QuestRemove then
		self:OnQuestRemove(body.id);
	elseif name == NotifyConsts.QuestUpdate then
		self:OnQuestUpdate( body.id );
	elseif name == NotifyConsts.QuestDayFinish then
		self:OnDayFinish();
	elseif name == NotifyConsts.QuestDailyFullStar then
		self:OnStarFull();
	elseif name == NotifyConsts.QuestDailyStateChange then
		self:UpdateShow();
	end
end

function UIQuestDay:OnQuestRefreshList()
	self:UpdateShow();
end

function UIQuestDay:OnQuestAdd( questId )
	if QuestUtil:IsDailyQuest( questId ) then
		self:UpdateShow();
	end
end

function UIQuestDay:OnQuestRemove( questId )
	if QuestUtil:IsDailyQuest( questId ) then
		self:UpdateShow();
	end
end

function UIQuestDay:OnQuestUpdate( questId )
	if QuestUtil:IsDailyQuest( questId ) then
		local questVO = QuestModel:GetQuest(questId);
		if not questVO then return; end
		self:ShowGoalInfo( questVO );
	end
end

-- 今日日环已完成
function UIQuestDay:OnDayFinish()
	self:ShowTodayFinish();
end

--升5星
function UIQuestDay:OnStarFull()
	local questVO = QuestModel:GetDailyQuest();
	self:ShowStarInfo( questVO );
	self:ShowQuestRewards( questVO );
end
