--[[
日环任务:日环任务跳环奖励面板
2014年12月11日21:43:35
郝户
]]

_G.UIQuestDailySkipReward = BaseUI:new("UIQuestDailySkipReward");

UIQuestDailySkipReward.skipInfo = nil;

function UIQuestDailySkipReward:Create()
	self:AddSWF("taskDailySkipRewardPanel.swf", true, "center");
end

local xposTab = {};
function UIQuestDailySkipReward:OnLoaded( objSwf )
	self:Init(objSwf)
	objSwf.btnConfirm1.click = function() self:OnBtnConfirm1Click(); end
	objSwf.btnConfirm2.click = function() self:OnBtnConfirm2Click(); end
	objSwf.btnConfirm3.click = function() self:OnBtnConfirm3Click(); end

	objSwf.btnConfirm2.rollOver = function() self:OnBtnConfirm2RollOver(); end
	objSwf.btnConfirm3.rollOver = function() self:OnBtnConfirm3RollOver(); end
	objSwf.btnConfirm2.rollOut  = function() self:OnBtnConfirm2RollOut(); end
	objSwf.btnConfirm3.rollOut  = function() self:OnBtnConfirm3RollOut(); end

	objSwf.btnClose.click    = function() self:OnBtnCloseClick(); end
	local list = objSwf.rewardList;
	RewardManager:RegisterListTips( list );
	for i = 1, list.renderers.length do
		xposTab[i] = list.renderers[i - 1]._x;
	end
	
	objSwf.skipEffect.complete = function()
									local numSkip = #self.skipInfo.list;
									objSwf.skipRewardNum.visible = true;
									objSwf.skipRewardNum.num = numSkip;
								end
end

function UIQuestDailySkipReward:Init(objSwf)
	objSwf.lblGain.text = StrConfig['quest151']
	local multipleInfoMap = QuestConsts:GetDQMultipleRewardMap()
	objSwf.btnConfirm1.htmlLabel = multipleInfoMap[1].label
	objSwf.btnConfirm2.htmlLabel = multipleInfoMap[2].label
	objSwf.btnConfirm3.htmlLabel = multipleInfoMap[3].label
end

function UIQuestDailySkipReward:OnDelete()
	for k,_ in pairs(xposTab) do
		xposTab[k] = nil;
	end
end

function UIQuestDailySkipReward:OnShow()
	self:UpdateShow();
	self:StartTimer();
end

function UIQuestDailySkipReward:OnHide()
	self.skipInfo = nil;
	self:StopTimer();
	QuestDayFlow:OnSkipClose();
end

function UIQuestDailySkipReward:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.skipInfo then return end
	-- 特效
	self:PlayEffect()
	-- 提示文本
	local numSkip = #self.skipInfo.list;
	objSwf.txtPrompt.htmlText = StrConfig['quest150']
	--播放抽奖数字特效
	objSwf.skipRewardNum.visible = false;
	objSwf.skipEffect:playEffect(3);
	-- 奖励列表
	local rewardExp, rewardMoney, rewardZhenqi = self:GetSkipRewards()
	local list = objSwf.rewardList;
	list.dataProvider:cleanUp();
	local rewardListProvider = RewardManager:Parse( enAttrType.eaExp..","..rewardExp, enAttrType.eaBindGold..","..rewardMoney, enAttrType.eaZhenQi..","..rewardZhenqi );
	for i = 1, #rewardListProvider do
		list.dataProvider:push( rewardListProvider[i] );
	end
	list:invalidateData();
	-- 奖励数量
	objSwf.txtExp.text    = _G.getNumShow( rewardExp )
	objSwf.txtMoney.text  = _G.getNumShow( rewardMoney )
	objSwf.txtZhenqi.text = _G.getNumShow( rewardZhenqi )
	local t = { objSwf.txtExp, objSwf.txtMoney, objSwf.txtZhenqi }
	-- 动态飞图标
	for i = 1, #t do
		local mc = t[i];
		if mc then
			mc._alpha = 0;
			Tween:To( mc, 0.4, { delay = 0.2 * i, _alpha = 100 } );
		end
	end
	t = nil
	-- 动态飞图标
	for i = 1, #xposTab do
		local mc = list.renderers[i - 1];
		if mc then
			mc._x = mc._x + 800;
			mc._alpha = 0;
			Tween:To( mc, 0.4, { delay = 0.2 * i, _x = xposTab[i], _alpha = 100 } );
		end
	end
	-- 多倍奖励统计
	objSwf.mItem1._visible = false;
	objSwf.mItem2._visible = false;
	local multipleInfo = self:GetRewardMultipleInfo();
	local pin = 1;
	local multipleMC, roundsStr;
	for multiple, rounds in pairs(multipleInfo) do
		multipleMC = objSwf['mItem'..pin];
		if multipleMC then
			multipleMC._visible = true;
			roundsStr = table.concat(rounds, "，");
			multipleMC.tf1.autoSize = "left"
			multipleMC.tf1.text = string.format( StrConfig['quest114'], roundsStr );
			multipleMC.tf2.text = StrConfig['quest115'];
			multipleMC.numLoader.num = multiple;
			multipleMC.numLoader._x = multipleMC.tf1._x + multipleMC.tf1._width + 10;
			multipleMC.tf2._x = multipleMC.numLoader._x + multipleMC.numLoader._width + 20;
			pin = pin + 1; -- point to next movie clip, we only have 2, so it may be null;
		end
	end
end

function UIQuestDailySkipReward:PlayEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.effBg:stopEffect()
	objSwf.effBg:playEffect(1)
end

function UIQuestDailySkipReward:OnBtnConfirm1Click()
	self:GetReward(1);
end

function UIQuestDailySkipReward:OnBtnConfirm2Click()
	self:GetReward(2);
end

function UIQuestDailySkipReward:OnBtnConfirm3Click()
	self:GetReward(3);
end

function UIQuestDailySkipReward:OnBtnConfirm2RollOver()
	self:ShowAddTxt(2)
end

function UIQuestDailySkipReward:OnBtnConfirm3RollOver()
	self:ShowAddTxt(3)
end

function UIQuestDailySkipReward:OnBtnConfirm2RollOut()
	self:HideAddTxt()
end

function UIQuestDailySkipReward:OnBtnConfirm3RollOut()
	self:HideAddTxt()
end

function UIQuestDailySkipReward:OnBtnCloseClick(multiple)
	self:GetReward(1);
end

function UIQuestDailySkipReward:ShowAddTxt(multipleType)
	local objSwf = self.objSwf
	if not objSwf then return end
	if multipleType == 1 then return end
	local rewardExp, rewardMoney, rewardZhenqi = self:GetSkipRewards()
	local dqMultipleRewardMap = QuestConsts:GetDQMultipleRewardMap()
	local map = dqMultipleRewardMap[multipleType]
	if not map then return end
	local multiple = map.multiple

	local addRewardExp    = rewardExp * multiple -  rewardExp
	local addRewardMoney  = rewardMoney * multiple -  rewardMoney
	local addRewardZhenqi = rewardZhenqi * multiple -  rewardZhenqi
	local format = "%s<font color='#00ff00'> +%s</font>"
	objSwf.txtExp.htmlText    = string.format( format, _G.getNumShow( rewardExp ), _G.getNumShow( addRewardExp ) )
	objSwf.txtMoney.htmlText  = string.format( format, _G.getNumShow( rewardMoney ), _G.getNumShow( addRewardMoney ) )
	objSwf.txtZhenqi.htmlText = string.format( format, _G.getNumShow( rewardZhenqi ), _G.getNumShow( addRewardZhenqi ) )
end

function UIQuestDailySkipReward:HideAddTxt()
	local objSwf = self.objSwf
	if not objSwf then return end
	local rewardExp, rewardMoney, rewardZhenqi = self:GetSkipRewards()
	objSwf.txtExp.text    = _G.getNumShow( rewardExp )
	objSwf.txtMoney.text  = _G.getNumShow( rewardMoney )
	objSwf.txtZhenqi.text = _G.getNumShow( rewardZhenqi )
end

-- 领奖
function UIQuestDailySkipReward:GetReward(multiple)
	self:StopTimer();
	if not multiple then multiple = 1 end
	if multiple == 2 then -- 多倍类型2，扣除银两判断
		local myGold = MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold
		if myGold < QuestConsts:GetMultiple2Cost(true) then
			FloatManager:AddNormal( StrConfig['quest308'] ) --银两不足
			return
		end
	elseif multiple == 3 then -- 多倍类型3，扣除元宝判断
		local myYuanBao = MainPlayerModel.humanDetailInfo.eaUnBindMoney
		if myYuanBao < QuestConsts:GetMultiple3Cost() then
			FloatManager:AddNormal( StrConfig['quest309'] ) --元宝不足
			return
		end
	end
	self:OpenPayPrompt(multiple);
end

function UIQuestDailySkipReward:OpenPayPrompt( multiple )
	local needConfirm = QuestModel:GetPayGetRewardPrompt( multiple );
	if not needConfirm then
		QuestController:ReqGetDailySkipReward( multiple );
		return;
	end
	local confirmFunc = function(selected)
		QuestModel:SetPayGetRewardPrompt( multiple, not selected );
		QuestController:ReqGetDailySkipReward( multiple );
	end
	if multiple == 1 then
		QuestController:ReqGetDailySkipReward( multiple );
		return;
	end
	local content = "";
	local multipleInfoMap = QuestConsts:GetDQMultipleRewardMap()
	local multipleInfo = multipleInfoMap[multiple]
	-- 多倍领取时，总花费 = 单环花费, 与跳环环数无关
	if multiple == 2 then
		content = string.format( StrConfig['quest305'], QuestConsts:GetMultiple2Cost(), multipleInfo.multiple );
	elseif multiple == 3 then
		content = string.format( StrConfig['quest306'], QuestConsts:GetMultiple3Cost(), multipleInfo.multiple );
	end
	UIConfirmWithNoTip:Open( content, confirmFunc );
end

function UIQuestDailySkipReward:GetSkipRewards()
	local rewardExp    = 0;
	local rewardMoney  = 0;
	local rewardZhenqi = 0;
	local skipInfo = self.skipInfo;
	if skipInfo then
		--计算跳过的日环任务奖励(经验金钱灵力)
		local skipQuests = skipInfo.list;
		for _, questInfo in pairs(skipQuests) do
			local questId = questInfo.id;
			local cfg = t_dailyquest[questId];
			if cfg then
				local star = QuestConsts.QuestDailyMaxStar; -- 跳过的任务皆以满星(5)结算
				local cfgAdditionStar = cfg["additionStar"..star];
				if cfgAdditionStar then
					local starAddition = 1 + cfgAdditionStar / 100;
					local multiple        = questInfo.double; -- 倍数
					local coefficient     = multiple * starAddition;
					rewardExp    = rewardExp    + cfg.expReward    * coefficient
					rewardMoney  = rewardMoney  + cfg.moneyReward  * coefficient
					rewardZhenqi = rewardZhenqi + cfg.zhenqiReward * coefficient
				else
					Debug( string.format( "cannot find cfg of the quest.quest id:%s, star:%s", questId, star ) );
				end
			end
		end
		rewardExp    = toint( rewardExp, 0.5 )
		rewardMoney  = toint( rewardMoney, 0.5 )
		rewardZhenqi = toint( rewardZhenqi, 0.5 )
	end
	return rewardExp, rewardMoney, rewardZhenqi
end

-- 统计跳环发生的暴击奖励
function UIQuestDailySkipReward:GetRewardMultipleInfo()
	local tab = {};
	local skipInfo = self.skipInfo;
	if skipInfo then
		--计算哪一环发生了加倍
		local skipToRound = skipInfo.round;
		local skipQuests = skipInfo.list;
		local numSkip = #skipQuests;
		local round, multiple
		for i, questInfo in pairs(skipQuests) do
			local round = skipToRound - numSkip + i - 1;
			local multiple = questInfo.double; -- 倍数
			if multiple > 1 then
				if tab[multiple] == nil then
					tab[multiple] = {};
				end
				table.push( tab[multiple], round );
			end
		end
	end
	return tab;
end

-------------------------------------倒计时处理------------------------------------------

local timerKey;
local time;
function UIQuestDailySkipReward:StartTimer()
	local func = function() self:OnTimer(); end
	time = QuestConsts.QuestDailyRewardCountDown;
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	self:UpdateCountDown();
end

function UIQuestDailySkipReward:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:StopTimer();
		self:OnTimeUp();
		return;
	end
	self:UpdateCountDown();
end

function UIQuestDailySkipReward:OnTimeUp()
	self:GetReward(1)
end

function UIQuestDailySkipReward:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
		self:UpdateCountDown();
	end
end

function UIQuestDailySkipReward:UpdateCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local textField = objSwf.txtTime;
	textField._visible = timerKey ~= nil;
	textField.htmlText = string.format( StrConfig['quest112'], time );
end

--------------------------------------------------------------------------------------------------------------

function UIQuestDailySkipReward:Open(skipInfo)
	self.skipInfo = skipInfo;
	if self:IsShow() then
		self:UpdateShow();
	else
		self:Show();
	end
end
