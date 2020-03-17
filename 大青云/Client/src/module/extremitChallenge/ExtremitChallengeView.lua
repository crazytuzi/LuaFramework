--[[
	2015年6月19日, PM 02:34:38
	新版极限挑战UI
	wangyanwei
]]

_G.UIExtremitChallenge = BaseUI:new('UIExtremitChallenge');

function UIExtremitChallenge:Create()
	self:AddSWF('extremitChallengePanel.swf',true,'center');
end

UIExtremitChallenge.ExtremitEndTime = '';		--截取时间常量

function UIExtremitChallenge:OnLoaded(objSwf)
	-- objSwf.bossPanel.rollOver = function ()  end
	-- objSwf.monsterPanel.rollOver = function ()  end
	local constsTimeCfg = t_consts[84];
	self.ExtremitEndTime = constsTimeCfg.param;
	objSwf.txt_info.text = UIStrConfig['extremitChalleng3'];
	objSwf.txt_time.htmlText = string.format(StrConfig['extremitChalleng003'],constsTimeCfg.param);
	objSwf.btn_boss.click = function () self:OnEnterBossClick(); end
	objSwf.btn_state1.click = function () self:SetListIsShow(1); end
	objSwf.btn_monster.click = function () self:OnEnterMonsterClick(); end
	objSwf.btn_state2.click = function () self:SetListIsShow(2); end
	
	objSwf.btn_state1.selected = true;
	for i = 1, 10 do
		objSwf['reward_' .. i].rollOver = function () self:OnDrawRankRewardTip(i); end
		objSwf['reward_' .. i].rollOut = function () TipsManager:Hide(); end
	end
	objSwf.btn_panelTip.rollOver = function () TipsManager:ShowBtnTips(StrConfig['extremitChalleng012'],TipsConsts.Dir_RightDown); end
	objSwf.btn_panelTip.rollOut = function () TipsManager:Hide(); end
	objSwf.btn_close.click = function () self:Hide(); end
	-- objSwf.btn_monsterReward.click = function () ExtremitChallengeController:OnSendExtremityRankReward(0) end
	-- objSwf.btn_bossReward.click = function () ExtremitChallengeController:OnSendExtremityRankReward(1) end
	objSwf.btn_reward.click = function () 
		if UIExtremitChallengeShop:IsShow() then
			UIExtremitChallengeShop:Hide();
		end
		if UIExtremitChallengeRankReward:IsShow() then
			UIExtremitChallengeRankReward:Hide();
			UIExtremitChallengeRankReward:Show();
		else
			UIExtremitChallengeRankReward:Show();
		end
	end
	objSwf.btn_shop.click = function () 
		if UIExtremitChallengeRankReward:IsShow() then
			UIExtremitChallengeRankReward:Hide();
		end
		if UIExtremitChallengeShop:IsShow() then
			UIExtremitChallengeShop:Hide();
			UIExtremitChallengeShop:Show();
		else
			UIExtremitChallengeShop:Show();
		end
	end
end

function UIExtremitChallenge:OnShow()
	self:OnRewardTimeNum();
	self:OnSendUIData();	--请求UIdata
end

--//请求UI上排行榜信息
function UIExtremitChallenge:OnSendUIData()
	ExtremitChallengeController:OnSendExtremityData();			--自己的排名
	ExtremitChallengeController:OnSendExtremityRankData();		--总排行榜
end

--两个list先是隐藏切换
function UIExtremitChallenge:SetListIsShow(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if state == 1 then
		objSwf.rank_boss._visible = true;
		objSwf.rank_monster._visible = false;
	else 
		objSwf.rank_boss._visible = false;
		objSwf.rank_monster._visible = true;
	end
end

--//绘制两个list排行榜
function UIExtremitChallenge:OnDrawRankList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:OnDrawBossList();
	self:OnDrawMonsterList();
	self:SetListIsShow(1);
	objSwf.btn_state1.selected = true;
	
	self:ShowOverNum();		--超过人数
end

function UIExtremitChallenge:ShowOverNum()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local bossNum = ExtremitChallengeModel:GetBossOverNum();
	local monsterNum = ExtremitChallengeModel:GetMonsterOverNum();
	if not bossNum then 
		objSwf.bossOver.text = StrConfig['extremitChalleng084'];
	else
		objSwf.bossOver.htmlText = string.format(StrConfig['extremitChalleng083'],bossNum);
	end
	if not monsterNum then 
		objSwf.monsterOver.text = StrConfig['extremitChalleng084'];
	else
		objSwf.monsterOver.htmlText = string.format(StrConfig['extremitChalleng083'],monsterNum);
	end
end

--//BOSS排行榜
function UIExtremitChallenge:OnDrawBossList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local bossRankData = ExtremitChallengeModel:GetBossRankData();
	objSwf.bossNumber.text = getNumShow(ExtremitChallengeModel:OnGetMySelfMaxData().bossHarm or 0);
	for i = 1 , 3 do
		local cfg = bossRankData[i];
		if cfg then
			objSwf.rank_boss['txt_name' .. i].text = cfg.roleName;
			objSwf.rank_boss['txt_bossNum' .. i].htmlText = string.format(StrConfig['extremitChalleng005'],getNumShow(cfg.roleHarm));
		end
	end
	
	objSwf.rank_boss.list.dataProvider:cleanUp();
	for i , v in ipairs(bossRankData) do
		if i > 3 then
			local vo = {};
			vo.value = string.format(StrConfig['extremitChalleng005'],getNumShow(v.roleHarm));
			vo.rank = v.roleRank;
			vo.name = v.roleName;
			vo.roleId = v.roleId;
			objSwf.rank_boss.list.dataProvider:push( UIData.encode(vo) );
		end
	end
	objSwf.rank_boss.list:invalidateData();
end

--//Moster排行榜
function UIExtremitChallenge:OnDrawMonsterList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local monsterRankData = ExtremitChallengeModel:GetBossMonsterData();
	objSwf.monsterNumber.text = ExtremitChallengeModel:OnGetMySelfMaxData().monsterNum or 0;
	for i = 1 , 3 do
		local cfg = monsterRankData[i];
		if cfg then
			objSwf.rank_monster['txt_name' .. i].text = cfg.roleName;
			objSwf.rank_monster['txt_bossNum' .. i].htmlText = string.format(StrConfig['extremitChalleng004'],cfg.roleNum);
		end
	end
	
	objSwf.rank_monster.list.dataProvider:cleanUp();
	for i , v in ipairs(monsterRankData) do
		if i > 3 then
			local vo = {};
			vo.rank = v.roleRank;
			vo.name = v.roleName;
			vo.value = string.format(StrConfig['extremitChalleng004'],v.roleNum)
			vo.roleId = v.roleId;
			objSwf.rank_monster.list.dataProvider:push( UIData.encode(vo) );
		end
	end
	objSwf.rank_monster.list:invalidateData();
end

function UIExtremitChallenge:OnHide()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	objSwf.txt_timeNum.text = '';
	if UIExtremitChallengeShop:IsShow() then
		UIExtremitChallengeShop:Hide();
	end
	if UIExtremitChallengeRankReward:IsShow() then
		UIExtremitChallengeRankReward:Hide();
	end
	for i = 1 , 3 do
		objSwf.rank_monster['txt_name' .. i].text = '';
		objSwf.rank_monster['txt_bossNum' .. i].text = '';
		objSwf.rank_boss['txt_name' .. i].text = '';
		objSwf.rank_boss['txt_bossNum' .. i].text = '';
	end
	objSwf.rank_monster.list.dataProvider:cleanUp();
	objSwf.rank_monster.list:invalidateData();
	objSwf.rank_boss.list.dataProvider:cleanUp();
	objSwf.rank_boss.list:invalidateData();
	--是否有组队提示
	TeamUtils:UnRegisterNotice(self:GetName())
end

--进入BOSS房间
function UIExtremitChallenge:OnEnterBossClick()
	local state = 0;
	ExtremitChallengeController:OnExtremityEnterData(state);
end

--进入小怪房间
function UIExtremitChallenge:OnEnterMonsterClick()
	local state = 1;
	ExtremitChallengeController:OnExtremityEnterData(state);
end

--距离截取奖励倒计时
function UIExtremitChallenge:OnRewardTimeNum()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local minTime = split(t_consts[84].param,':');
	local maxTime = split('24:00',':');
	local func = function () 
		local hour1,min1,sec1 = self:OnBackNowLeaveTime();
		if hour1 >= toint(minTime[1]) and hour1 <= toint(maxTime[1]) then
			objSwf.txt_timeNum.text = StrConfig['extremitChalleng006'];
			return
		end
		local sec = CTimeFormat:daystr2sec(self.ExtremitEndTime);
		local hour,min,sec = self:OnBackNowTime(sec - GetDayTime());
		objSwf.txt_timeNum.htmlText = string.format(StrConfig['extremitChalleng002'],hour,min,sec)
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func();
end

--换算时间
function UIExtremitChallenge:OnBackNowLeaveTime()
	local hour,min,sec = CTimeFormat:sec2format(GetDayTime());
	return hour,min,sec
end

function UIExtremitChallenge:OnBackNowTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour ; end
	if min < 10 then min = '0' .. min ; end
	if sec < 10 then sec = '0' .. sec ; end
	return hour,min,sec
end

function UIExtremitChallenge:GetWidth()
	return 790
end

function UIExtremitChallenge:GetHeight()
	return 608
end

--排行榜tips图标
function UIExtremitChallenge:OnDrawRankRewardTip(index)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local type = objSwf.rank_boss._visible;
	local rewardData ;--= t_limitreward[index];
	for i , v in ipairs(t_limitreward) do
		local rankCfg = split(v.rank,'-');
		if #rankCfg > 1 then
			if index >= toint(rankCfg[1]) and index <= toint(rankCfg[2]) then
				rewardData = v;
				break
			end
		else
			if index == toint(v.rank) then
				rewardData = v;
				break
			end
		end
	end
	if not rewardData then return end
	local rewardCfg = {};
	if type then
		rewardCfg = split(rewardData.boss_reward,'#');
	else
		rewardCfg = split(rewardData.monster_reward,'#');
	end
	local str = '';
	str = str .. string.format(StrConfig['extremitChalleng100'],index) ;
	str = str .. BaseTips:SetLineSpace(BaseTips:GetLine2(),-5);
	for i , v in ipairs(rewardCfg) do
		local vo = split(v,',');
		local itemCfg = t_item[toint(vo[1])] or t_equip[toint(vo[1])];
		local itemName = string.format(StrConfig['extremitChalleng101'],TipsConsts:GetItemQualityColor(itemCfg.quality),itemCfg.name);
		local itemNum = string.format(StrConfig['extremitChalleng102'],vo[2]);
		str = str ..  BaseTips:SetLineSpace(itemName,-14) .. '<br/>' ..BaseTips:SetLeftMargin(itemNum,100) .. '<br/>';
	end
	TipsManager:ShowBtnTips( str,TipsConsts.Dir_RightDown);
end

function UIExtremitChallenge:HandleNotification(name)
	if name == NotifyConsts.ExtremitChallengeUpData then
		
	elseif name == NotifyConsts.ExtremitChallengeRankData then
		self:OnDrawRankList();
	end
end
function UIExtremitChallenge:ListNotificationInterests()
	return {
		NotifyConsts.ExtremitChallengeUpData,
		NotifyConsts.ExtremitChallengeRankData
	}
end

--UI必要处理
function UIExtremitChallenge:Update()
	if not self.bShowState then return end
end

function UIExtremitChallenge:IsTween()
	return true;
end

function UIExtremitChallenge:GetPanelType()
	return 1;
end

function UIExtremitChallenge:IsShowSound()
	return true;
end

function UIExtremitChallenge:IsShowLoading()
	return true;
end