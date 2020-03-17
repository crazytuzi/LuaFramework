--[[
	2015年6月25日, AM 11:23:32
	排行榜奖励面板
	wangyanwei
]]

_G.UIExtremitChallengeRankReward = BaseUI:new('UIExtremitChallengeRankReward');

UIExtremitChallengeRankReward.BossReward = 0;
UIExtremitChallengeRankReward.MonsterReward = 1;

function UIExtremitChallengeRankReward:Create()
	self:AddSWF('extremitChallengeRankReward.swf',true,'center');
end

function UIExtremitChallengeRankReward:OnLoaded(objSwf)
	objSwf.tf1.htmlText = string.format(StrConfig['extremitChalleng014'],t_consts[84].param);
	objSwf.btn_state1.click = function () self:OnChangeListHandler(self.BossReward); end
	objSwf.btn_state2.click = function () self:OnChangeListHandler(self.MonsterReward); end
	objSwf.list.itemRewardRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRewardRollOut = function () TipsManager:Hide(); end
	objSwf.bosslist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.bosslist.itemRollOut = function () TipsManager:Hide(); end
	objSwf.monsterlist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.monsterlist.itemRollOut = function () TipsManager:Hide(); end
	objSwf.btn_state1.selected = true;
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.btn_getReward.click = function () self:OnGetRankReward(); end
end

function UIExtremitChallengeRankReward:OnShow()
	self:OnChangeListHandler(self.BossReward);
	self:OnDrawRightRewardList();
	self:OnChangTime();
end

--设置自己的信息
function UIExtremitChallengeRankReward:OnDrawRightRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.txt_1.text = UIStrConfig['extremitChalleng12'];
	objSwf.txt_2.text = UIStrConfig['extremitChalleng13'];
	local data = ExtremitChallengeModel.myExtremityData;
	local bossRank = data.bossRank ;
	if not bossRank then bossRank = 0 end
	local monsterRank = data.monsterRank ;
	if not monsterRank then monsterRank = 0 end
	local bossState = data.bossState ;
	local monsterState = data.monsterState ;
	local bossRewardIndex ;
	local monsterRewardIndex ;
	local bossIndex ;
	local monsterIndex ;
	for i , v in ipairs(t_limitreward) do
		local rankCfg = split(v.rank_name,'#');
		if bossRank >= toint(rankCfg[1]) and bossRank <= toint(rankCfg[2]) then
			bossIndex = v.rank;
			bossRewardIndex = v.id;
		end
		if monsterRank >= toint(rankCfg[1]) and monsterRank <= toint(rankCfg[2]) then
			monsterIndex = v.rank;
			monsterRewardIndex = v.id;
		end
	end
	
	if bossRank == 0 then
		bossIndex = t_limitreward[#t_limitreward].rank;
		bossRewardIndex = t_limitreward[#t_limitreward].id;
	end
	if monsterRank == 0 then
		monsterIndex = t_limitreward[#t_limitreward].rank;
		monsterRewardIndex = t_limitreward[#t_limitreward].id;
	end
	
	--找不到排名
	if not bossIndex then
		bossRank = 0;
		bossIndex = t_limitreward[#t_limitreward].rank;
		bossRewardIndex = t_limitreward[#t_limitreward].id;
	end
	if not monsterIndex then
		monsterRank = 0;
		monsterIndex = t_limitreward[#t_limitreward].rank;
		monsterRewardIndex = t_limitreward[#t_limitreward].id;
	end
	
	
	objSwf.tf2.htmlText = string.format(StrConfig['extremitChalleng015'],bossIndex);
	objSwf.tf3.htmlText = string.format(StrConfig['extremitChalleng015'],monsterIndex);
	
	local rewardList = RewardManager:Parse(t_limitreward[bossRewardIndex].boss_reward);
	objSwf.bosslist.dataProvider:cleanUp();
	objSwf.bosslist.dataProvider:push(unpack(rewardList));
	objSwf.bosslist:invalidateData();
	
	local rewardList2 = RewardManager:Parse(t_limitreward[monsterRewardIndex].monster_reward);
	objSwf.monsterlist.dataProvider:cleanUp();
	objSwf.monsterlist.dataProvider:push(unpack(rewardList2));
	objSwf.monsterlist:invalidateData();
	
	if bossRank == 0 then
		objSwf.bossRank.text = StrConfig['extremitChalleng016'];
	else
		objSwf.bossRank.htmlText = string.format(StrConfig['extremitChalleng051'],bossRank);
	end
	if monsterRank == 0 then
		objSwf.monsterRank.text = StrConfig['extremitChalleng016'];
	else
		objSwf.monsterRank.htmlText = string.format(StrConfig['extremitChalleng052'],monsterRank);
	end
end

--改变按钮状态
function UIExtremitChallengeRankReward:OnChangeBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local data = ExtremitChallengeModel.myExtremityData;
	local bossState = data.bossState ;
	local monsterState = data.monsterState ;
	if bossState ~= 0 or monsterState ~= 0 then
		objSwf.btn_getReward.disabled = true;
	else
		objSwf.btn_getReward.disabled = false;
	end
end

function UIExtremitChallengeRankReward:OnChangTime()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local minTime = split(t_consts[84].param,':');
	local maxTime = split('24:00',':');
	
	local func = function ()
		local hour,min,sec = self:OnBackNowLeaveTime();
		if hour >= toint(minTime[1]) then
			self:OnChangeBtnState();
		else
			objSwf.btn_getReward.disabled = true;
		end
		
		if hour >= toint(minTime[1]) and hour <= toint(maxTime[1]) then
			objSwf.txt_time.text = StrConfig['extremitChalleng006'];
			return
		end
		local sec = CTimeFormat:daystr2sec(UIExtremitChallenge.ExtremitEndTime);
		local hour,min,sec = UIExtremitChallenge:OnBackNowTime(sec - GetDayTime());
		objSwf.txt_time.htmlText = string.format(StrConfig['extremitChalleng053'],hour,min,sec)
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func();
end

function UIExtremitChallengeRankReward:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

function UIExtremitChallengeRankReward:OnBackNowLeaveTime()
	local hour,min,sec = CTimeFormat:sec2format(GetDayTime());
	return hour,min,sec
end

--获取奖励
function UIExtremitChallengeRankReward:OnGetRankReward()
	local data = ExtremitChallengeModel.myExtremityData;
	local bossRank = data.bossRank ;
	local monsterRank = data.monsterRank ;
	if bossRank == 0 and monsterRank == 0 then
		FloatManager:AddNormal( StrConfig['extremitChalleng103'] );
		return
	end
	if bossRank ~= 0 then
		ExtremitChallengeController:OnSendExtremityRankReward(0);
	end
	if monsterRank ~= 0 then
		ExtremitChallengeController:OnSendExtremityRankReward(1);
	end
end

-- 获取所有数据
function UIExtremitChallengeRankReward:OnGetAllData(state)
	local list = {};
	local vo;
	for i , v in ipairs(t_limitreward) do
		vo = {};
		vo.id = v.id;
		if i >= #t_limitreward then
			local cfg = split(v.rank,'-');
			vo.rankIndex = string.format(StrConfig['extremitChalleng017'],cfg[1]);
		else
			vo.rankIndex = string.format(StrConfig['extremitChalleng013'],v.rank);
		end
		local majorStr = UIData.encode(vo);
		local rewardList;
		if state == self.BossReward then
			rewardList = RewardManager:Parse( v.boss_reward );
		elseif state == self.MonsterReward then
			rewardList = RewardManager:Parse( v.monster_reward );
		end
		local rewardStr = table.concat(rewardList, "*");
		local finalStr = majorStr .. "*" .. rewardStr;
		table.push(list, finalStr);
	end
	return list
end

function UIExtremitChallengeRankReward:OnFlyReward(type)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local data = ExtremitChallengeModel.myExtremityData;
	if type == 0 then
		local bossRank = data.bossRank ;
		local bossRewardIndex ;
		for i , v in ipairs(t_limitreward) do
			local rankCfg = split(v.rank_name,'#');
			if bossRank >= toint(rankCfg[1]) and bossRank <= toint(rankCfg[2]) then
				bossRewardIndex = v.id;
				break
			end
		end
		if not bossRewardIndex then
			bossRewardIndex = t_limitreward[#t_limitreward].id;
		end
		if bossRank ~= 0 then
			local cfg = split(t_limitreward[bossRewardIndex].boss_reward,'#');
			for i , v in ipairs(cfg) do
				local idCfg = split(v,',');
				local rewardList = RewardManager:ParseToVO(toint(idCfg[1]));
				local startPos = UIManager:PosLtoG(objSwf['reward' .. i]);
				RewardManager:FlyIcon(rewardList,startPos,5,true,60);
			end
		end
	elseif type == 1 then
		local monsterRank = data.monsterRank ;
		local monsterRewardIndex ;

		for i , v in ipairs(t_limitreward) do
			local rankCfg = split(v.rank_name,'#');
			if monsterRank >= toint(rankCfg[1]) and monsterRank <= toint(rankCfg[2]) then
				monsterRewardIndex = v.id;
				break
			end
		end
		if not monsterRewardIndex then
			monsterRewardIndex = t_limitreward[#t_limitreward].id;
		end
		if monsterRank ~= 0 then
			local cfg = split(t_limitreward[monsterRewardIndex].monster_reward,'#');
			for i , v in ipairs(cfg) do
				local idCfg = split(v,',');
				local rewardList = RewardManager:ParseToVO(toint(idCfg[1]));
				local startPos = UIManager:PosLtoG(objSwf['icon' .. i]);
				RewardManager:FlyIcon(rewardList,startPos,5,true,60);
			end
		end
	end
end

--切换标签handler

UIExtremitChallengeRankReward.rewardState = 0;

function UIExtremitChallengeRankReward:OnChangeListHandler(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.rewardState = state;
	objSwf.list.dataProvider:cleanUp();
	local data ;
	if state == self.BossReward then
		data = self:OnGetAllData(self.BossReward);
	elseif state == self.MonsterReward then 
		data = self:OnGetAllData(self.MonsterReward);
	end
	objSwf.list.dataProvider:push( unpack(data) );
	objSwf.list:invalidateData();
end

function UIExtremitChallengeRankReward:HandleNotification(name,body)
	if name == NotifyConsts.ExtremitChallengeBackReward then
		self:OnChangeBtnState();
		self:OnFlyReward(body.type);
	elseif name == NotifyConsts.ExtremitChallengeUpData then
		self:OnDrawRightRewardList();
	end
end
function UIExtremitChallengeRankReward:ListNotificationInterests()
	return {
		NotifyConsts.ExtremitChallengeBackReward,
		NotifyConsts.ExtremitChallengeUpData,
	}
end