--[[
	2015年4月2日, PM 03:10:11
	wangyawnei&houxudong
	北仓街信息面板
]]
_G.UIBeicangjieInfo = BaseUI:new('UIBeicangjieInfo');

function UIBeicangjieInfo:Create()
	self:AddSWF("beicangjieInfo.swf", true, "bottom");
end

function UIBeicangjieInfo:OnLoaded(objSwf)
	-- objSwf.smallPanel.txt_1.text = UIStrConfig['beicangjie002'];
	-- objSwf.smallPanel.txt_info.text = UIStrConfig['beicangjie005'];
	
	-- objSwf.smallPanel.tf1.text = StrConfig['beicangjie300'];
	-- objSwf.smallPanel.tf2.text = StrConfig['beicangjie301'];
	-- objSwf.smallPanel.tf3.text = StrConfig['beicangjie302'];
	objSwf.rankPanel.rank.text = StrConfig['beicangjie600'];
	objSwf.rankPanel.name.text = StrConfig['beicangjie601'];
	objSwf.rankPanel.rank_score.text = StrConfig['beicangjie602'];
	objSwf.rankPanel.curr_score.text = StrConfig['beicangjie603'];
	objSwf.rankPanel.kill_num.text = StrConfig['beicangjie604'];
	objSwf.rankPanel.dead_num.text = StrConfig['beicangjie605'];
	objSwf.rankPanel.max_kill.text = StrConfig['beicangjie606'];

	objSwf.smallPanel.txt_num.text = StrConfig['beicangjie102'];
	objSwf.smallPanel.txt_level.text = StrConfig['beicangjie104'];

	objSwf.smallPanel.totalKill.text = StrConfig['beicangjie105'];
	objSwf.smallPanel.curKill.text = StrConfig['beicangjie106'];
	objSwf.smallPanel.rankone.text = StrConfig['beicangjie107'];
	objSwf.smallPanel.levelTime.text = StrConfig['beicangjie108'];

	
	objSwf.rankPanel.visible = false;
	objSwf.btn_out.click = function () self:QuitActivityBeicangjie(); end
	objSwf.btn_rankReward.click = function () self:ShowRankList(); end
	objSwf.btn_rank.click = function () 
		objSwf.rankPanel.visible = not objSwf.rankPanel.visible;
		if ActivityBeicangjieRankView:IsShow() then
			ActivityBeicangjieRankView:Hide()
		end
		self:OnShowRank()
	end
	objSwf.rankPanel.btn_rankClose.click = function () objSwf.rankPanel.visible = false end
	
	objSwf.btnOpen.click = function() self:OnBtnOpenClick(e) end
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick(e) end
	-- objSwf.btn_goon.click = function() self:OnGoBossHandler(); end
	
	--objSwf.btn_rollInfo.rollOver = function () TipsManager:ShowBtnTips(StrConfig["activityru"..UIBeicangjieRight.activityId],TipsConsts.Dir_RightDown); end
	-- objSwf.btn_rollInfo.rollOut = function () TipsManager:Hide(); end
	-- 暂时屏蔽排行榜
	objSwf.btn_rankReward._visible = false
	objSwf.smallPanel.fightUp.htmlText = StrConfig['beicangjie900']
	objSwf.smallPanel.buffnote1.htmlText = StrConfig['beicangjie901']
	objSwf.smallPanel.buffnote2.htmlText = StrConfig['beicangjie902']
end

function UIBeicangjieInfo:OnShow()
	self:OnChangeMyNum()
	self:OnUpdateKill()
	self:OnShowBestPlayer()
	self:OnShowBuffInfo()
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.btnOpen._visible = true
	objSwf.btn_rank._visible = true
	-- objSwf.btn_rankReward._visible = true
	objSwf.btn_out._visible = true
	objSwf.btnCloseState._visible = false
end

-- 显示buff信息
function UIBeicangjieInfo:OnShowBuffInfo( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local panel = objSwf.smallPanel
	local buffList = BuffModel:GetShowList();
	local cfgBuff1 = t_buff[1013024]
	local cfgBuff2 = t_buff[1013023]
	if not cfgBuff1 or not cfgBuff2 then
		Debug("not find buffcfg in t_buff,buff id is 1013023 or 1013024")
		return
	end
	local buff1Name,buff2Name = cfgBuff1.name or '',cfgBuff2.name or ''
	local desInfo1,desInfo2 = cfgBuff1.des or '', cfgBuff2.des or ''
	panel.buff1.htmlText = buff1Name.." "..string.format("<font color = '#ff0000'>%s</font>",StrConfig["beicangjie903"])
	panel.buff2.htmlText = buff2Name.." "..string.format("<font color = '#ff0000'>%s</font>",StrConfig["beicangjie903"])
	for k, vo in pairs(buffList) do	
		if vo.tid == 1013023 then
			panel.buff2.htmlText = buff2Name.." "..desInfo2
		elseif vo.tid == 1013024 then
			panel.buff1.htmlText = buff1Name.." "..desInfo1
		end
	end
end

function UIBeicangjieInfo:InitRankPanelPos()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local wWidth,wHeight = UIManager:GetWinSize(); 
	objSwf.rankPanel._x = -wWidth / 2
end

-- 调整技能界面的位置
function UIBeicangjieInfo:OnResize(dwWidth,dwHeight)
	self:InitRankPanelPos()
end 

function UIBeicangjieInfo:OnBtnOpenClick(e)
	local objSwf = self.objSwf
	if not self then return; end
	objSwf.smallPanel._visible = false;
	objSwf.btnOpen._visible = false;
	objSwf.btn_rank._visible = false;
	objSwf.btn_rankReward._visible = false
	objSwf.btn_out._visible = false;
	objSwf.btnCloseState._visible = true;
end

function UIBeicangjieInfo:OnBtnCloseClick(e)
	local objSwf = self.objSwf
	if not self then return; end
	objSwf.smallPanel._visible = true;
	objSwf.btnOpen._visible = true;
	objSwf.btn_rank._visible = true;
	objSwf.btn_rankReward._visible = false;
	objSwf.btn_out._visible = true;
	objSwf.btnCloseState._visible = false;
end


function UIBeicangjieInfo:QuitActivityBeicangjie()
	local func = function ()
		local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
		if not activity then return; end
		if activity:GetType() ~= ActivityConsts.T_Beicangjie then return; end
		ActivityController:QuitActivity(activity:GetId());
	end
	UIConfirm:Open(StrConfig['beicangjie080'],func);
end

function UIBeicangjieInfo:ShowRankList( )
	if not ActivityBeicangjieRankView:IsShow() then
		ActivityBeicangjieRankView:Show()
		local objSwf = self.objSwf
		if not objSwf then return end
		objSwf.rankPanel.visible = false
	end
end

--改变自己的分数
function UIBeicangjieInfo:OnChangeMyNum()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:OnChangLevel(); -- 获取等级
	-- objSwf.smallPanel.scoreLoader.num = ActivityBeicangjie:GetMyTegralNum();
	objSwf.smallPanel.scorenum.text = ActivityBeicangjie:GetMyTegralNum(); 
end

--累计击杀
function UIBeicangjieInfo:OnUpdateKill( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local accountKill , currKill = ActivityBeicangjie:GetKilllData() 
	objSwf.smallPanel.totalKillNum.text = accountKill
	objSwf.smallPanel.currkillNum.text = currKill
end

--获取分级
function UIBeicangjieInfo:OnChangLevel( )
	local objSwf = self.objSwf;
	local cfg = t_consts[52];
	if not cfg then return end
	local num = ActivityBeicangjie:GetMyTegralNum();
	local levelCfg = split(cfg.param,'#');
	local level = 1;
	for i , v in ipairs(levelCfg) do
		local a = split(v,',');
		if num >= toint(a[1]) and num <= toint(a[2]) then
			level = i;
			break;
		end
	end
	local nextcfg = levelCfg[level + 1];
	if nextcfg then
		local b = split(nextcfg,',')
	end
	-- objSwf.smallPanel.txt_level.num = level;
	objSwf.smallPanel.levelNum.text = level;
	local iconStr = ResUtil:GetBCLevelIcon2(level);
	--[[ 
	if objSwf.smallPanel.icon_level.source ~= iconStr then
		objSwf.smallPanel.icon_level.source = iconStr;
	end
	--]]
end

function UIBeicangjieInfo:OnChangeTime(timeNum)
	local hour,min,sec = self:OnBackNowLeaveTime(timeNum);
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end
	self.objSwf.smallPanel.txt_time.htmlText = string.format(StrConfig['beicangjie200'],min,sec);
end

function UIBeicangjieInfo:OnBackNowLeaveTime(timeNum)
	local hour,min,sec = CTimeFormat:sec2format(timeNum);
	return hour,min,sec
end

function UIBeicangjieInfo:OnHide()
	local objSwf = self.objSwf;
	objSwf.smallPanel.txt_num.text = '';
	objSwf.smallPanel.txt_time.text = '';
	if self.bossTimeKey then
		TimerManager:UnRegisterTimer(self.bossTimeKey);
		self.bossTimeKey = nil;
	end
	-- objSwf.smallPanel.txt_boss.text = '';
	-- for i = 1 , 3 do
	-- 	objSwf.rankPanel['num_level' .. i].visible = false;
	-- 	objSwf.rankPanel['txt_name' .. i].text = StrConfig['beicangjie009'];
	-- 	objSwf.rankPanel['txt_num' .. i].text = StrConfig['beicangjie009'];
	-- end
	objSwf.rankPanel.listPlayer.dataProvider:cleanUp();
	objSwf.rankPanel.listPlayer:invalidateData();
end

function UIBeicangjieInfo:GetWidth()
	return 356;
end

function UIBeicangjieInfo:GetHeight()
	return 405;
end

--更新显示最强排行榜信息
function UIBeicangjieInfo:OnShowBestPlayer()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local rankList = ActivityBeicangjie:GetRankData(); 
	local bestname;
	if #rankList < 1 then
		bestname =StrConfig["activity207"];
	else
		bestname = rankList[1].name;
	end
	objSwf.smallPanel.betsRankName.text = bestname
end

--更新排行榜面板
function UIBeicangjieInfo:OnShowRank()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:InitRankPanelPos()
	local rankList = ActivityBeicangjie:GetRankData();   --rankList 
	objSwf.rankPanel.listPlayer.dataProvider:cleanUp();
	-- for j = 1 , 3 do
	-- 	objSwf.rankPanel['num_level' .. j].visible = #rankCfg > 0;
	-- 	objSwf.rankPanel['txt_name' .. j]._visible = #rankCfg > 0;
	-- 	objSwf.rankPanel['txt_num' .. j]._visible = #rankCfg > 0;
	-- end
	if #rankList < 1 then
		return 
	end
	for k = 1 , 10 do
		if not rankList[k] then
			rankList[k] = {};
			rankList[k].name = StrConfig['beicangjie009'];
			rankList[k].num = StrConfig['beicangjie009'];
			rankList[k].rankIndex = k;
		end 
	end
	for i = 1 , 10 do
		local obj = {};
		obj.rankName = rankList[i].name .. "";
		if i == 1 then
			obj.rankNum = '';  --1特殊处理第一名
		else
			obj.rankNum = i;
		end
		
		obj.level = self:NumORLeve(rankList[i].num);
		obj.num = rankList[i].num;
		obj.killNum = rankList[i].killCount;    --后面的字段从服务器获取，目前先这样
		obj.deadNum = rankList[i].beKillCount;
		obj.maxKillNum = rankList[i].continueCount;
		objSwf.rankPanel.listPlayer.dataProvider:push(UIData.encode(obj));
	end
	objSwf.rankPanel.listPlayer:invalidateData();

	--计算玩家自身的排名
	local roleID = MainPlayerController:GetRoleID()
	local index = 0;
	for i,v in ipairs(rankList) do
		if v.roleID == roleID then
			objSwf.rankPanel.my_rank.text = string.format(StrConfig['beicangjie700'],ActivityBeicangjie:GetMyTegralNum(),v.rankIndex)
		else
			index = index + 1
		end
	end
	-- 未上榜
	if index >= #rankList then
		objSwf.rankPanel.my_rank.text = string.format(StrConfig['beicangjie701'],ActivityBeicangjie:GetMyTegralNum())
	end
end

--积分获取等级
function UIBeicangjieInfo:NumORLeve(num)
	if type(num) == 'string' then
		return 0;
	end
	if num == 0 then
		return 1
	end
	local cfg = t_consts[52];
	if not cfg then return end
	local levelCfg = split(cfg.param,'#');
	local level = nil;
	for i , v in ipairs(levelCfg) do
		local a = split(v,',');
		if num >= toint(a[1]) and num <= toint(a[2]) then
			level = i;
			break;
		end
	end
	return level;
end

--BOSS寻路
function UIBeicangjieInfo:OnGoBossHandler()
	if not self.bossLocation then return end
	local posId = 12000 + self.bossLocation;
	local point = QuestUtil:GetQuestPos(posId);
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
end

--BOSS状态文本
UIBeicangjieInfo.bossLocation = nil;
function UIBeicangjieInfo:OnChangeBossTimeTxt(location)
	local objSwf = self.objSwf;
	if self.bossTimeKey then
		TimerManager:UnRegisterTimer(self.bossTimeKey);
		self.bossTimeKey = nil;
	end
	local cfg = split(t_consts[75].param,'#');
	-- trace(cfg)
	if not cfg then return end
	self.bossLocation = location;
	-- objSwf.smallPanel.txt_boss.htmlText = string.format(StrConfig['beicangjie201'],cfg[self.bossLocation]);
	-- objSwf.btn_goon.visible = true;
end

function UIBeicangjieInfo:ESCHide()
	return true
end

function UIBeicangjieInfo:OnESC()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.rankPanel.visible = false;
end

--BOSS刷新状态
UIBeicangjieInfo.bossTimeNum = 0;
function UIBeicangjieInfo:OnChangeBossState(timeNum)
	local objSwf = self.objSwf;
	-- objSwf.btn_goon.visible = false;
	self.bossTimeNum = timeNum;
	local func = function ()
		self.bossTimeNum = self.bossTimeNum - 1;
		if self.bossTimeNum == 0 then
			TimerManager:UnRegisterTimer(self.bossTimeKey);
			self.bossTimeKey = nil;
		end
		local hour,min,sec = CTimeFormat:sec2format(self.bossTimeNum);
		if hour < 10 then hour = '0' .. hour; end
		if min < 10 then min = '0' .. min; end 
		if sec < 10 then sec = '0' .. sec; end 
		-- objSwf.smallPanel.txt_boss.htmlText = string.format(StrConfig['beicangjie202'],min,sec);
	end
	if self.bossTimeKey then
		TimerManager:UnRegisterTimer(self.bossTimeKey);
		self.bossTimeKey = nil;
	end
	self.bossTimeKey = TimerManager:RegisterTimer(func,1000);
	self.bossLocation = nil;
end

--怪物数量变化
function UIBeicangjieInfo:OnMonsterNumChange(eliteNum,commonNum)
	local objSwf = self.objSwf;
	-- objSwf.smallPanel.txt_monster.htmlText = string.format(StrConfig['beicangjie203'],eliteNum);
	-- objSwf.smallPanel.txt_elite.htmlText = string.format(StrConfig['beicangjie204'],commonNum);
end

--处理消息
function UIBeicangjieInfo:HandleNotification(name, body)
	if name == NotifyConsts.BeicangjieUpData then
		self:OnChangeMyNum();
	elseif name == NotifyConsts.BeicangjieTimeUpData then
		self:OnChangeTime(body.timeNum);
	elseif name == NotifyConsts.BeicangjieRank then  --上线的时候并没有发
			self:OnShowRank();
			self:OnShowBestPlayer();
	elseif name == NotifyConsts.BeicangjieBossTime then
		self:OnChangeBossState(body.timeNum);
	elseif name == NotifyConsts.BeicangjieNewBoss then
		self:OnChangeBossTimeTxt(body.location);
	elseif name == NotifyConsts.BeicangjieMonsterNum then
		self:OnMonsterNumChange(body.eliteNum,body.commonNum);
	elseif name == NotifyConsts.BeicangJieKill then
		self:OnUpdateKill();
	elseif name == NotifyConsts.BuffRefresh then
		self:OnShowBuffInfo()
	end
end

--监听消息列表
function UIBeicangjieInfo:ListNotificationInterests()
	return { 
		NotifyConsts.BeicangjieUpData,
		NotifyConsts.BeicangjieTimeUpData,
		NotifyConsts.BeicangjieRank,
		NotifyConsts.BeicangjieBossTime,
		NotifyConsts.BeicangjieNewBoss,
		NotifyConsts.BeicangjieMonsterNum,
		NotifyConsts.BeicangJieKill,
		NotifyConsts.BuffRefresh,
	};
end


function UIBeicangjieInfo:IsTween()
	return true;
end