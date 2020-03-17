
--[[
	2015年1月30日, PM 05:24:27
	wangyanwei
	定时副本信息面板
]]
_G.UITimerDungeonInfo = BaseUI:new('UITimerDungeonInfo');

function UITimerDungeonInfo:Create()
	self:AddSWF('timeDungeonInfoPanel.swf',true,"bottom");
end

function UITimerDungeonInfo:OnLoaded(objSwf,name)
	objSwf.infoPanel.txt_timeStr.text = StrConfig['timeDungeon083'];
	objSwf.infoPanel.txt_rewardStr.htmlText = StrConfig['timeDungeon088'];
	objSwf.infoPanel.txt_jindu.htmlText = StrConfig['timeDungeon087'];
	objSwf.infoPanel.btnOpen.click = function ()  
								objSwf.infoPanel._visible = false;
								objSwf.btnClose._visible = true
								end
	objSwf.btnClose.click = function () self:OnOpenInfopanel() end 
	objSwf.infoPanel.btn_quit.click = function () self:OnQuitDungeon() end --退出副本
	objSwf.infoPanel.btn_monsterpoint.click = function() self:OnClickMonster(); end
	objSwf.infoPanel.btnAuto.click = function() self:OnBtnAutoClick() end
	RewardManager:RegisterListTips( objSwf.infoPanel.dropList );
	objSwf.infoPanel.btnRule.rollOver = function() 
		TipsManager:ShowBtnTips( StrConfig['timeDungeon0100'], TipsConsts.Dir_RightDown )
	 end
	objSwf.infoPanel.btnRule.rollOut = function() TipsManager:Hide(); end
	-- objSwf.infoPanel.btnRule.htmlLabel = string.format("<font><u>规则说明</u></font>")
end
function UITimerDungeonInfo:OnBtnAutoClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.isAutoBattle = not self.isAutoBattle
	if self.state ~= true then
		AutoBattleController:OpenAutoBattle();
		-- objSwf.panel.btnAuto.labelID = 'waterDungeon012'
	else
		AutoBattleController:CloseAutoHang()
		-- objSwf.panel.btnAuto.labelID = 'waterDungeon009'
	end
end
function UITimerDungeonInfo:SetUIState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.infoPanel._visible = true
	objSwf.btnClose._visible = false
	-- objSwf.infoPanel.hitTestDisable = false;
end

function UITimerDungeonInfo:OnOpenInfopanel( )
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.infoPanel._visible = true
	objSwf.btnClose._visible = false

end

function UITimerDungeonInfo:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:SetUIState();
	-- objSwf.infoPanel.processBarMoney.value = 0;
	MainMenuController:HideRight();
	MainMenuController:HideRightTop();
	if UIDungeonTeamPrepare:IsShow() then
		UIDungeonTeamPrepare:Hide();
	end
	self:OnLoadNDIcon();
	--经验丹文本
	self:OnExpTxt();
	self:OnShowExp();
	--队伍人数
	self:OnTeamNumTxt();
	-- 通过奖励
	self:ShowReward()
	self.isAutoBattle = true;  --默认开始为挂机状态
	-- TimeDungeonController:onAutoFunc()  --进去自动挂机状态
	AutoBattleController:OpenAutoBattle()  --自动挂机

end

function UITimerDungeonInfo:ShowReward( )
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_monkeytime[1]
	if not cfg then return end
	local dropItemList = RewardManager:Parse( cfg.firstReward )
	objSwf.infoPanel.dropList.dataProvider:cleanUp()
	objSwf.infoPanel.dropList.dataProvider:push( unpack(dropItemList) )
	objSwf.infoPanel.dropList:invalidateData()
end

--队伍文本
function UITimerDungeonInfo:OnTeamNumTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_monkeytime[TimeDungeonModel.dungeonState];
	if not cfg then return end
	local monsterCfg = split(cfg.group_num,'#');
	if not TeamModel:IsInTeam() then
		return
	end
	local teamNum = TeamModel:GetMemberNum() or 1;
	local monsterNum = monsterCfg[teamNum];
	if not monsterNum then return end
end

function UITimerDungeonInfo:OnLoadNDIcon()
	local objSwf = self.objSwf;
	if not objSwf then return end
end

function UITimerDungeonInfo:OnClickMonster()

	local posCfg = split(t_position[9201].pos,'|');
	local myPos = posCfg[1];
	
	local point = split(myPos,",");
	local mapid = CPlayerMap:GetCurMapID();
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(mapid,_Vector3.new(point[2],point[3],0),completeFuc);
end

--显示文本(每杀一个怪刷新)(进度条更新)
function UITimerDungeonInfo:OnChangeExpMonsterTxt()
	local objSwf = self.objSwf
	local curKillMonster = TimeDungeonModel:GetMonsterNumHandler();   --当前杀怪数量
	local totalWave = t_consts[85].val1 or 0                          --总共的波数
	local cfg = t_monkeytime[1]
	if not cfg then return end
	local everyWaveMonster = 0                                        --每波怪物数量
	local monsterCfg = split(cfg.group_num,'#');
	if not TeamModel:IsInTeam() then
		everyWaveMonster = monsterCfg[1]
	else
		local teamNum = TeamModel:GetMemberNum() or 1;
		local monsterNum = monsterCfg[teamNum];
		if not monsterNum then return end
		everyWaveMonster = toint(monsterNum) * teamNum
	end

	local allMonster = everyWaveMonster * totalWave                    --总共的怪物数量
	local numMonster = (self.curWave - 1) * everyWaveMonster + curKillMonster
	local panel = objSwf and objSwf.infoPanel
	panel.txtMonster.text    = string.format("%.2f%%", numMonster/allMonster * 100)
	panel.siMonster.value    = numMonster
	panel.siMonster.maximum  = allMonster + 5
	panel.txt_test._visible = false
	panel.txt_test.htmlText = curKillMonster..'---'..numMonster..'---'..self.curWave
end

--显示文本(波数刷新)
UITimerDungeonInfo.nowMonsterNum = 0;
UITimerDungeonInfo.nowMonsterID = 0;
UITimerDungeonInfo.curWave = 1;   --默认当前波数是1
function UITimerDungeonInfo:OnChangeWaveTxt()
	local objSwf = self.objSwf;
	self.nowMonsterID = TimeDungeonModel:GetBossMonsterID();
	self.curWave =  TimeDungeonModel:GetMonsterWave()       --当前第几波
	local cfg = t_monster[self.nowMonsterID];
	if TimeDungeonModel:GetMonsterWave() == t_consts[85].val1 + 1 or TimeDungeonModel:GetMonsterWave() == 21 then
		UIDungeonNpcChat:Open(2000005);
		return
	end
	UIDungeonNpcChat:Open(2000004);
end

--退出副本
function UITimerDungeonInfo:OnQuitDungeon()
	local func = function () 
		TimeDungeonController:QuitTimeDungeon();
	end
	self.confirmID = UIConfirm:Open(StrConfig['timeDungeon040'],func);
end

function UITimerDungeonInfo:OnHide()
	local objSwf = self.objSwf;
	objSwf.infoPanel.txt_time.text = '';
	objSwf.infoPanel.txtMonster.text ="0.00%"
	TimeDungeonModel:OnClearTimeKey()
	if UIAutoBattleTip:IsShow() then
		UIAutoBattleTip:Hide();
	end
	UIConfirm:Close(self.confirmID);
end

function UITimerDungeonInfo:OnShowExp()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local exp =  TimeDungeonModel:GetDungeonExpHandler() or 0;
	local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	local lvlUpExp    = t_lvup[ playerLevel ].exp;
	local percentage  = exp / lvlUpExp ;
	local num = string.format( "%0.2f", percentage*100 )

	-- objSwf.infoPanel.txt_prtcentage.htmlText = string.format( StrConfig['timeDungeon1051'], num );
end

function UITimerDungeonInfo:OnExpTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local expMultiple = self:GetExpMultiple();
	-- objSwf.infoPanel.txt_MultipleExp.htmlText = string.format(StrConfig['timeDungeon1050'],expMultiple * 100);
end

-- 计算玩家当前的经验加成状态
function UITimerDungeonInfo:GetExpMultiple()
	local expMultiple = 0
	local myBuffs = BuffModel:GetAllBuff()
	for id, buff in pairs(myBuffs) do
		local cfg = _G.t_buff[buff.tid]
		for i = 1, 5 do
			local buffEffect = cfg[ "effect_" .. i ]
			if WaterDungeonConsts:IsMultipleExpEff( buffEffect ) then
				local buffEffCfg = _G.t_buffeffect[ buffEffect ]
				expMultiple = expMultiple + buffEffCfg.func_param2
			end
		end
	end
	return (expMultiple ~= 0) and (1 + expMultiple) or expMultiple
end

function UITimerDungeonInfo:OnTimeTxt()
	local objSwf = self.objSwf;
	local timeNum = TimeDungeonModel.timeNum;
	-- objSwf.infoPanel.txt_time.text = '00:00:00';
	local hour,min,sec = self:OnBackNowLeaveTime(timeNum);
	objSwf.infoPanel.txt_time.htmlText = string.format(StrConfig['cave006'],hour,min,sec);
end

function UITimerDungeonInfo:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return hour,min,sec
end

--改变挂机按钮文本
function UITimerDungeonInfo:OnChangeAutoText(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.state = state;
	if state then
		AutoBattleController:OpenAutoBattle()   --自动战斗
		objSwf.infoPanel.btnAuto.labelID = 'waterDungeon012'
	else
		objSwf.infoPanel.btnAuto.labelID = 'waterDungeon009'
	end
end

function UITimerDungeonInfo:GetWidth()
	return 235;
end

function UITimerDungeonInfo:GetHeight()
	return 477;
end

function UITimerDungeonInfo:HandleNotification(name,body)
	if name == NotifyConsts.TimerDungeonMonsterChange then
		self:OnChangeExpMonsterTxt();     --怪物刷新
		self:OnShowExp();
	elseif name == NotifyConsts.TimerDungeonWaveChange then
		self:OnChangeWaveTxt();	          --刷新波数
	elseif name == NotifyConsts.TimerDungeonTimeNum then
		self:OnTimeTxt();
	elseif name == NotifyConsts.BuffRefresh then
		self:OnExpTxt();
	elseif name == NotifyConsts.TeamMemberRemove then		--移除队员
		self:OnTeamNumTxt();
	elseif name == NotifyConsts.AutoHangStateChange then
		self:OnChangeAutoText(body.state);
	end
end

function UITimerDungeonInfo:ListNotificationInterests()
	return {
		NotifyConsts.TimerDungeonMonsterChange,
		NotifyConsts.TimerDungeonWaveChange,
		NotifyConsts.TimerDungeonTimeNum,
		NotifyConsts.BuffRefresh,
		NotifyConsts.TeamMemberRemove,
		NotifyConsts.AutoHangStateChange
	}
end