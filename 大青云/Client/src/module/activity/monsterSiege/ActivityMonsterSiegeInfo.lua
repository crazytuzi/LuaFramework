--[[
	2015年8月29日, PM 01:58:58
	wangyanwei
	信息面板
]]

_G.UIMonsterSiegeInfo = BaseUI:new('UIMonsterSiegeInfo');

function UIMonsterSiegeInfo:Create()
	self:AddSWF('monsterSiegeInfo.swf',true,'bottom');
end

function UIMonsterSiegeInfo:OnLoaded(objSwf)

	objSwf.smallPanel.tf1.text = UIStrConfig['monsterSiege1'];
	objSwf.smallPanel.tf2.text = UIStrConfig['monsterSiege2']; 
	objSwf.smallPanel.tf3.text = UIStrConfig['monsterSiege3'];
	objSwf.smallPanel.tf4.text = UIStrConfig['monsterSiege4'];
	objSwf.smallPanel.tf5.text = UIStrConfig['monsterSiege5'];
	objSwf.smallPanel.tf6.text = UIStrConfig['monsterSiege6'];
	objSwf.smallPanel.tf7.text = UIStrConfig['monsterSiege11'];
	objSwf.smallPanel.tf8.text = UIStrConfig['monsterSiege12'];
	objSwf.smallPanel.tf9.text = UIStrConfig['monsterSiege8'];
	objSwf.rankPanel.tf1.text = UIStrConfig['monsterSiege13'];
	objSwf.rankPanel.tf2.text = UIStrConfig['monsterSiege14'];

	objSwf.smallPanel.btn_quit.click = function () self.confirmID = UIConfirm:Open(StrConfig['monsterSiege050'],function () ActivityMonsterSiege:OnEnterQuit(); end); end
	objSwf.smallPanel.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.smallPanel.rewardList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.smallPanel.btn_rank.click = function() self:KillBossRank(); end
	
	objSwf.smallPanel.btn_right.click = function () self:OnRightClick(); end
	objSwf.smallPanel.btn_left.click = function () self:OnLeftClick(); end
	objSwf.rankPanel.btn_close.click = function () objSwf.rankPanel.visible = false; end
	
	objSwf.btn_state.click = function () self:OnHideSmallClick(); end
	
	objSwf.btn_guize.rollOver = function () TipsManager:ShowBtnTips(StrConfig['monsterSiege100'],TipsConsts.Dir_RightDown) end
	objSwf.btn_guize.rollOut = function () TipsManager:Hide(); end
end

function UIMonsterSiegeInfo:SetUIState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.smallPanel._visible = true
	objSwf.smallPanel.hitTestDisable = false;
	objSwf.btn_state.selected = false;
end;

function UIMonsterSiegeInfo:OnHideSmallClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_state.selected = objSwf.smallPanel.visible;
	objSwf.smallPanel.visible = not objSwf.smallPanel.visible;
end

function UIMonsterSiegeInfo:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.rankPanel.visible = false;
	self:SetUIState();
end

function UIMonsterSiegeInfo:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.rankPanel.visible = false;
	self.rewardSelectIndex = 0;
	objSwf.smallPanel.visible = true;
	UIConfirm:Close(self.confirmID);
end

function UIMonsterSiegeInfo:GetWidth()
	return 237
end

function UIMonsterSiegeInfo:GetHeight()
	return 405
end

--rankPanel
function UIMonsterSiegeInfo:KillBossRank()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.rankPanel.visible = not objSwf.rankPanel.visible;
	if not objSwf.rankPanel.visible then return end
	self:DrawRank();
end

function UIMonsterSiegeInfo:DrawRank()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rankData = ActivityMonsterSiege:GetKillRank();
	for i = 1 , 10 do
		objSwf.rankPanel['txt_boss' .. i].htmlText = string.format(StrConfig['monsterSiege006'],i);
		local data = rankData[i];
		if not data then
			objSwf.rankPanel['txt_name' .. i].text = StrConfig['monsterSiege007'];
		else
			objSwf.rankPanel['txt_name' .. i].text = rankData[i].roleName;
		end
	end
end

--waveTxt
function UIMonsterSiegeInfo:OnWaveTxt()
	local objSwf = self.objSwf;
	if not objSwf then print('not objSwf') return end
	local wave = ActivityMonsterSiege:GetMonsterSiegeWave();
	local cfg = t_shouweibeicang[wave];
	if not cfg then print('not t_shouweibeicang[wave]---' .. wave) return end
	objSwf.smallPanel.txt_wave.htmlText = string.format(StrConfig['monsterSiege001'],cfg.numId,10);
	
	self:OnMonsterTxt();
	self:OnKillTxt();
end

--monsterTxt
function UIMonsterSiegeInfo:OnMonsterTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local wave = ActivityMonsterSiege:GetMonsterSiegeWave();
	local cfg = t_shouweibeicang[wave];
	if not cfg then return end
	local maxBoss 		= split(cfg.bossId,		',')[2] or 0;
	local maxElite 		= split(cfg.nbmonsterId,',')[2] or 0;
	local maxMonster 	= split(cfg.monsterId,	',')[2] or 0;
	
	local bossNum,eliteNum,monsterNum = ActivityMonsterSiege:GetAllMonsterNum();
	
	objSwf.smallPanel.txt_boss.text 	= bossNum 		.. '/' .. maxBoss;
	objSwf.smallPanel.txt_elite.text 	= eliteNum 		.. '/' .. maxElite;
	objSwf.smallPanel.txt_monster.text = monsterNum 	.. '/' .. maxMonster;
end

--killTxt
function UIMonsterSiegeInfo:OnKillTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local killMonsterNum = ActivityMonsterSiege:GetKillMonsterNum();
	local killHumanNum = ActivityMonsterSiege:GetKillPlayerNum();
	
	objSwf.smallPanel.txt_killMonster.text = killMonsterNum;
	objSwf.smallPanel.txt_killPlayer.text = killHumanNum;
end

--reward
UIMonsterSiegeInfo.RewardConstsNum = 3;
UIMonsterSiegeInfo.rewardSelectIndex = 0;
function UIMonsterSiegeInfo:OnDrawReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rewardCfg = ActivityMonsterSiege:GetReward();
	local str = '';
	local rewardNum = 0;
	for i , v in ipairs(rewardCfg) do
		if rewardNum < self.RewardConstsNum then
			if i > self.RewardConstsNum * self.rewardSelectIndex then
				str = str .. v.id .. ',' .. v.num .. '#';
				rewardNum = rewardNum + 1;
			end
		end
	end
	--去掉最后一组的#
	local strCfg = split(str,'#');
	local rewardStr = '';
	for i , _str in ipairs(strCfg) do
		if i <= #strCfg - 1 then
			if i >= #strCfg - 1 then
				rewardStr = rewardStr .. _str;
			else
				rewardStr = rewardStr .. _str .. '#';
			end
		end
	end
	local rewardList = RewardManager:Parse(rewardStr);
	objSwf.smallPanel.rewardList.dataProvider:cleanUp();
	objSwf.smallPanel.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.smallPanel.rewardList:invalidateData();
	
	self:LeftRightDisabled();
end

function UIMonsterSiegeInfo:LeftRightDisabled()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rewardCfg = ActivityMonsterSiege:GetReward();
	local index = self.rewardSelectIndex + 1;
	objSwf.smallPanel.btn_right.disabled = not (#rewardCfg > index * self.RewardConstsNum)
	objSwf.smallPanel.btn_left.disabled = index == 1;
end

function UIMonsterSiegeInfo:OnLeftClick()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local rewardCfg = ActivityMonsterSiege:GetReward();
	
	if self.rewardSelectIndex > 0 then
		self.rewardSelectIndex = self.rewardSelectIndex - 1;
		self:OnDrawReward();
	else
		return
	end
end

function UIMonsterSiegeInfo:OnRightClick()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local rewardCfg = ActivityMonsterSiege:GetReward();
	local index = self.rewardSelectIndex;
	index = index + 1;
	if (#rewardCfg - self.RewardConstsNum * index) > 0 then
		self.rewardSelectIndex = self.rewardSelectIndex + 1;
		self:OnDrawReward();
	else
		return 
	end
end

function UIMonsterSiegeInfo:OnChangeTime(timeNum)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local hour,min,sec = self:OnBackNowLeaveTime(timeNum);
	-- if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	objSwf.smallPanel.txt_time.htmlText = string.format(StrConfig['monsterSiege004'],min .. ':' ..sec);
end

function UIMonsterSiegeInfo:OnBackNowLeaveTime(timeNum)
	-- if not _time then _time = 0 end
	local hour,min,sec = CTimeFormat:sec2format(timeNum);
	return hour,min,sec
end

function UIMonsterSiegeInfo:HandleNotification(name, body)
	if name == NotifyConsts.MonsterSiegeWave then			--波数信息刷新
		self:OnWaveTxt();
	elseif name == NotifyConsts.MonsterSiegeKillInfo then	--击杀信息
		self:OnKillTxt();
	elseif name == NotifyConsts.MonsterSiegeMonsterData then--怪物数量变动
		self:OnMonsterTxt();
	elseif name == NotifyConsts.MonsterSiegeReward then		--攻城奖励
		self:OnDrawReward();
	elseif name == NotifyConsts.MonsterSiegeRank then		--BOSS击杀榜
		self:DrawRank();
	elseif name == NotifyConsts.BeicangjieTimeUpData then   --活动倒计时
		self:OnChangeTime(body.timeNum);
	end
end

--监听消息列表
function UIMonsterSiegeInfo:ListNotificationInterests()
	return { 
		NotifyConsts.MonsterSiegeWave,
		NotifyConsts.MonsterSiegeKillInfo,
		NotifyConsts.MonsterSiegeMonsterData,
		NotifyConsts.MonsterSiegeReward,
		NotifyConsts.MonsterSiegeRank,
		NotifyConsts.BeicangjieTimeUpData,
	};
end