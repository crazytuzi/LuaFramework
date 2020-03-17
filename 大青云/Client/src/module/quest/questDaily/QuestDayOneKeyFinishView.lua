--[[
日环任务：一键完成奖励面板
2015年1月13日11:12:49
haohu
]]

_G.UIQuestDayOneKeyFinish = BaseUI:new("UIQuestDayOneKeyFinish");

UIQuestDayOneKeyFinish.midPanels = {}; --中间插入的暴击奖励统计面板，数量0~4个不等

function UIQuestDayOneKeyFinish:Create()
	self:AddSWF("taskDay1KeyFinishPanel.swf", true, "center");
end

function UIQuestDayOneKeyFinish:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	local topPanel = objSwf.topPanel;
	RewardManager:RegisterListTips( topPanel.listReward ); -- 一件完成20环的总奖励，包含暴击
	local bottomPanel = objSwf.bottomPanel;
	RewardManager:RegisterListTips( bottomPanel.listDayReward ); -- 20环全部完成后的日奖励
	RewardManager:RegisterListTips( bottomPanel.listDrawReward ); -- 一键完成中4次自动抽奖所获得的奖励
	bottomPanel.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	bottomPanel.choujiangTitle._visible = false;
end

function UIQuestDayOneKeyFinish:OnShow()
	self:InitShow();
	self:StartTimer();
end

function UIQuestDayOneKeyFinish:InitShow()
	self:ShowReward();
	self:ShowDayReward();
	self:ShowDrawReward();
end

-- 一件完成20环的总奖励，包含暴击
function UIQuestDayOneKeyFinish:ShowReward()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local rewardInfo = self.oneKeyFinishRewardInfo and self.oneKeyFinishRewardInfo.list;
	if not rewardInfo then return; end
	-- 奖励信息
	local list = objSwf.topPanel.listReward;
	list.dataProvider:cleanUp();
	local rewardProvider, multipleInfo = self:GetRewardProvider(rewardInfo);
	list.dataProvider:push( unpack(rewardProvider) );
	list:invalidateData();
	-- 奖励暴击统计 TODO
--	self:ShowMultiple( multipleInfo );
	-- 更新位置
	self:UpdatePosition();
end

-- @param multipleInfo:{ {round = *, multiple = *}, ... }
function UIQuestDayOneKeyFinish:ShowMultiple( multipleInfo )
	local cTab = {};
	local round, multiple;
	for _, vo in ipairs(multipleInfo) do
		round = vo.round;
		multiple = vo.multiple;
		if not cTab[multiple] then
			cTab[multiple] = {};
		end
		table.push( cTab[multiple], round );
	end

	local roundStr;
	for multiple, rounds in pairs(cTab) do
		roundStr = table.concat(rounds, "，");
		self:AddMidPanel(roundStr, multiple);
	end
end

-- 显示第***环获得 X2 倍奖励
function UIQuestDayOneKeyFinish:AddMidPanel( roundStr, multiple )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local depth = objSwf:getNextHighestDepth();
	local pnl = objSwf:attachMovie("MiddlePanel", "mid"..multiple, depth);
	pnl.tf1.autoSize = "left";
	pnl.tf2.autoSize = "left";
	pnl.tf1.text = string.format( StrConfig['quest114'], roundStr );
	TimerManager:RegisterTimer( function()
		pnl.numLoader.num = multiple;
	end, 50, 1 )
	pnl.tf2.text = StrConfig['quest115'];
	pnl.numLoader._x = pnl.tf1._x + pnl.tf1._width + 10;
	pnl.tf2._x = pnl.numLoader._x + pnl.numLoader._width + 20;
	table.push(self.midPanels, pnl);
end

-- 清空暴击奖励统计
function UIQuestDayOneKeyFinish:ClearMidPanels()
	for _, panel in pairs(self.midPanels) do
		panel:removeMovieClip();
		panel = nil;
	end
	self.midPanels = {};
end

function UIQuestDayOneKeyFinish:UpdatePosition()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local midPanelMaxY = objSwf.topPanel._height;
	for index, panel in pairs(self.midPanels) do
		panel._x = 2;
		panel._y = objSwf.topPanel._height + panel._height * (index - 1);
		midPanelMaxY = math.max(midPanelMaxY, panel._y + panel._height);
	end
	objSwf.bottomPanel._y = midPanelMaxY;
end

function UIQuestDayOneKeyFinish:GetRewardProvider( srcList )
	local rewardExp, rewardMoney, rewardZhenqi = 0, 0, 0; -- 奖励经验、金钱、灵力
	local rewardJingYuan = 0;
	local itemId = 0;
	local multipleInfo = {};
	-- 计算经验、金钱、灵力奖励
	local skipLength = #srcList;
	for i, questInfo in ipairs( srcList ) do
		local questCfg = t_dailyquest[questInfo.id];
		local multiple = questInfo.double;
		if multiple > 1 then
			local round = QuestConsts.QuestDailyTotal - skipLength + i;
			table.push( multipleInfo, { round = round, multiple = multiple } );
		end
		local star = questInfo.star;
		if star < 1 or star > QuestConsts.QuestDailyMaxStar then
			Error( string.format( "Got a dailyquest has a wrong star level:%s, questId:%s", star, questInfo.id ) );
		end
		local starAddition = 1 + questCfg["additionStar" .. star] / 100;
		local coefficient = multiple * starAddition;
		if questCfg then
			rewardExp    = toint( rewardExp + questCfg.expReward * coefficient, 0.5 );
			rewardMoney  = toint( rewardMoney + questCfg.moneyReward * coefficient, 0.5 );
--			rewardZhenqi = toint( rewardZhenqi + questCfg.zhenqiReward * coefficient, 0.5 );
			rewardJingYuan     = math.ceil( rewardJingYuan + toint(GetCommaTable(questCfg.itemReward)[2]) * coefficient, 0.5 )
			itemId = toint(GetCommaTable(questCfg.itemReward)[1]);
		end
	end
	local rewardExpStr    = enAttrType.eaExp..","..rewardExp;
	local rewardMoneyStr  = enAttrType.eaBindGold..","..rewardMoney;
--	local rewardZhenqiStr = enAttrType.eaZhenQi..","..rewardZhenqi;
	local rewardJingYuanStr  = itemId .. "," .. rewardJingYuan;
	local rewardList = RewardManager:Parse( rewardExpStr, rewardMoneyStr, rewardJingYuanStr );

	return rewardList, multipleInfo;
end

-- 20环全部完成后的日奖励
function UIQuestDayOneKeyFinish:ShowDayReward()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.bottomPanel.listDayReward;
	list.dataProvider:cleanUp();
	local dayRewardProvider = QuestUtil:GetQuestDayRewardProvider(self.oneKeyFinishRewardInfo.level);
	list.dataProvider:push( unpack(dayRewardProvider) );
	list:invalidateData();
end

-- 一键完成中4次自动抽奖所获得的奖励
function UIQuestDayOneKeyFinish:ShowDrawReward()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local drawRewardInfo = self.oneKeyFinishRewardInfo and self.oneKeyFinishRewardInfo.rewardList;
	if not drawRewardInfo then return; end
	local list = objSwf.bottomPanel.listDrawReward;
	list.dataProvider:cleanUp();
	local drawRewardProvider = self:GetDrawRewardProvider( drawRewardInfo );
	list.dataProvider:push( unpack(drawRewardProvider) );
	list:invalidateData();
end

function UIQuestDayOneKeyFinish:GetDrawRewardProvider( srcList )
	local list = {};
	for _, srcVO in ipairs(srcList) do
		if srcVO.id ~= 0 then
			table.push( list, srcVO.id .. "," .. srcVO.num );
		end
	end
	local rewardStr = table.concat(list, "#");
	local rewardList = RewardManager:Parse( rewardStr );
	return rewardList;
end

function UIQuestDayOneKeyFinish:OnHide()
	self:StopTimer();
	self:ClearMidPanels();
end

function UIQuestDayOneKeyFinish:OnBtnConfirmClick()
	self:Hide();
end

function UIQuestDayOneKeyFinish:OnBtnCloseClick()
	self:Hide();
end

function UIQuestDayOneKeyFinish:Open( oneKeyFinishRewardInfo )
	self.oneKeyFinishRewardInfo = oneKeyFinishRewardInfo;
	self:Show();
end


-------------------------------------倒计时处理------------------------------------------

local timerKey;
local time;
function UIQuestDayOneKeyFinish:StartTimer()
	local func = function() self:OnTimer(); end
	time = QuestConsts.QuestDaily1KeyFinishCountDown;
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	self:UpdateCountDown();
end

function UIQuestDayOneKeyFinish:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:StopTimer();
		self:OnTimeUp();
	end
	self:UpdateCountDown();
end

function UIQuestDayOneKeyFinish:UpdateCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.bottomPanel.txtCountDown.htmlText = string.format( StrConfig['quest116'], time );
end

function UIQuestDayOneKeyFinish:OnTimeUp()
	self:Hide();
end

function UIQuestDayOneKeyFinish:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
	end
end