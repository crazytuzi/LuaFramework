--[[
	2015年1月9日, PM 04:40:58
	打宝地宫信息面板
	wangyanwei
]]
_G.UIXianYuanCaveInfo = BaseUI:new("UIXianYuanCaveInfo");


function UIXianYuanCaveInfo:Create()
	self:AddSWF("XuanYuanCaveInfoPanel.swf", true, "bottom");
end

UIXianYuanCaveInfo.openState = true;
UIXianYuanCaveInfo.rewardOpenState = true
function UIXianYuanCaveInfo:OnLoaded(objSwf,name)
	objSwf.btn_pageInfo.click = function() self:OnInfoClick(); end
	objSwf.btn_pageBoss.click = function() self:OnBossRankClick(); end 
	-- objSwf.smallPanel.txt_safe1.text = UIStrConfig['cave502'];
	-- objSwf.smallPanel.txt_safe2.text = UIStrConfig['cave503'];
	objSwf.smallPanel.btn_out.click = function() self:OnOutCaveHandler(); end  --退出活动
	objSwf.bossPanel.btn_out.click = function() self:OnOutCaveHandler(); end  --退出活动
	-- objSwf.rewardPanel.btn_quit.click = function () self:OnOutCaveHandler(); end
	-- objSwf.smallPanel.btn_monster.rollOver = function() objSwf.bossTip.visible = true; self:DrawBoss(); end --查看怪物
	-- objSwf.smallPanel.btn_monster.rollOut = function() objSwf.bossTip.visible = false; self:OnHideBoss(); end 
	objSwf.smallPanel.btn_monster.click = function() self:OnBossClick(); end 
	objSwf.btn_state.click = function () 
		if self.openState then
			objSwf.btn_state.selected = true;
			objSwf.smallPanel.visible = false;
			objSwf.rewardPanel.visible =  false;
			objSwf.bossPanel._visible = false;
			objSwf.btn_pageInfo._visible = false
			objSwf.btn_pageBoss._visible = false
		else
			objSwf.btn_state.selected = false;
			objSwf.btn_pageInfo.selected = true
			-- objSwf.btn_info.selected = true;
			objSwf.smallPanel.visible = true;
			objSwf.rewardPanel.visible =  true;
			objSwf.bossPanel._visible = false;
			objSwf.btn_pageInfo._visible = true
			objSwf.btn_pageBoss._visible = true
		end
		self.openState = not self.openState;
	end
	
	objSwf.rewardPanel.btn_state.click = function()
		self.rewardOpenState = not self.rewardOpenState
		objSwf.rewardPanel.btn_state.selected = not self.rewardOpenState
		objSwf.rewardPanel.rewardList._visible = self.rewardOpenState
	end

	objSwf.smallPanel.txt_3.text = UIStrConfig['cave1'];
	objSwf.smallPanel.txt_4.text = UIStrConfig['cave2'];
	objSwf.smallPanel.txt_5.text = UIStrConfig['cave3'];
	objSwf.smallPanel.txt_6.text = UIStrConfig['cave4'];
	objSwf.smallPanel.txt_31.text = UIStrConfig['cave27']
	-- objSwf.bossTip.txt_1.text = UIStrConfig['cave10'];
	-- objSwf.bossTip.txt_2.text = UIStrConfig['cave11'];
	-- objSwf.bossTip.txt_3.text = UIStrConfig['cave12'];
	-- objSwf.bossTip.visible = false;
	
	--疲劳值
	-- objSwf.smallPanel.processBarMoney.maximum = t_consts[62].val;
	-- objSwf.smallPanel.btn_tip.rollOver = function () TipsManager:ShowBtnTips(StrConfig['cave501'],TipsConsts.Dir_RightDown); end
	-- objSwf.smallPanel.btn_tip.rollOut = function () TipsManager:Hide(); end
	
	objSwf.smallPanel.caveMapList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.smallPanel.caveMapList.itemRollOut = function() TipsManager:Hide(); end
	
	objSwf.smallPanel.caveMapList2.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.smallPanel.caveMapList2.itemRollOut = function() TipsManager:Hide(); end
	
	--随机寻路点击
	-- objSwf.smallPanel.btn_aotu.click = function () self:OnStarRoadClick(math.random(2)); end
	-- objSwf.smallPanel.btn_safe1.click = function () self:OnStarRoadClick(1); end
	-- objSwf.smallPanel.btn_safe2.click = function () self:OnStarRoadClick(2); end
	
	
	objSwf.rewardPanel.rewardList.caveRewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardPanel.rewardList.caveRewardList.itemRollOut = function () TipsManager:Hide(); end
	objSwf.expPanel._visible = false
	
end

--点击信息面板 
function UIXianYuanCaveInfo:OnInfoClick( )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btn_pageInfo.selected = true;
	objSwf.smallPanel._visible = true
	objSwf.bossPanel._visible = false
end

--点击BOSS排行面板 
function UIXianYuanCaveInfo:OnBossRankClick( )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btn_pageBoss.selected = true;
	objSwf.smallPanel._visible = false
	objSwf.bossPanel._visible = true
end

--玩家获得经验提示
local s_time = 5
function UIXianYuanCaveInfo:OnExpBack(value)
	if value == 0 then
		return
	end
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.expPanel._visible = true
	objSwf.expPanel.txt_exp.htmlText = PublicUtil.GetString('activitydbmj01', toint(t_consts[62].param), value)
	if self.timeExpKey then
		TimerManager:UnRegisterTimer(self.timeExpKey)
	end
	s_time = 5
	local func = function()
		if not self.objSwf then
			return
		end
		if s_time <= 0 then
			objSwf.expPanel._visible = false
			TimerManager:UnRegisterTimer(self.timeExpKey)
			return
		end
		self.objSwf.expPanel.txt_time.htmlText = PublicUtil.GetString("activitydbmj02", s_time)
		s_time = s_time - 1
	end
	self.timeExpKey = TimerManager:RegisterTimer(func, 1000, 0)
	func()
end

--玩家获得总经验
function UIXianYuanCaveInfo:OnAllExpBack(expday)
	self.allExp = expday
	if self:IsShow() then
		self:ShowAllExp()
	end
end

function UIXianYuanCaveInfo:ShowAllExp()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.smallPanel.exp_1.text = self.allExp and getNumShow(self.allExp) or 0
	local lv = MainPlayerModel.humanDetailInfo.eaLevel
	local str = t_xyreward[lv].reward
	local exp = split(str, ",")
	objSwf.smallPanel.exp_2.text = "每" .. t_consts[62].param .."分钟" .. getNumShow(exp[2])
end

function UIXianYuanCaveInfo:OnShowBossInfo( )
	local objSwf = self.objSwf;
	if not objSwf then return end

	local bossID = ActivityDIFXuanYuanCave:GetBossID();
	local bosslv = t_monster[bossID] and t_monster[bossID].level or 0
	local bossName = t_monster[bossID] and t_monster[bossID].name or ''
	objSwf.bossPanel.boss_lv.htmlText = string.format('<font>lv.%s</font>',bosslv)
	objSwf.bossPanel.boss_name.htmlText = bossName
end

-- boss伤害排行榜信息
function UIXianYuanCaveInfo:OnChangeHurtBossRankList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.bossPanel.listPlayer.dataProvider:cleanUp();
	objSwf.bossPanel.listMy.dataProvider:cleanUp();
	local bossHurtList = ActivityDIFXuanYuanCave:GetBossHurtData()  --获取boss伤害数据
	local bossmaxHp = ActivityDIFXuanYuanCave:GetMaxBossHp()        --BOSS总血量
	local myRank = 0;
	local myRoleID = MainPlayerController:GetRoleID()
	if not bossHurtList then return end
	for i , v in ipairs(bossHurtList)  do
		local vo = {};
		vo.rankNum = i
		vo.playerName = v.roleName
		local percent = 0
		if bossmaxHp  > 0 then
			percent = string.format("%.2f", v.hurt/bossmaxHp*100)
		end
		vo.hurtNum = string.format( StrConfig['worldBoss201'], percent)  --伤害
		objSwf.bossPanel.listPlayer.dataProvider:push(UIData.encode(vo))
	end
	objSwf.bossPanel.listPlayer:invalidateData();

	-- 处理下面我自己的伤害信息
	local roleID = MainPlayerController:GetRoleID()
	local index = 0;
	local hurt = 0
	for i,v in ipairs(bossHurtList) do
		if v.roleID == roleID then
			local vo = {}
			vo.rankNum =  i
			vo.playerName = v.roleName
			local percent = 0
			if bossmaxHp  > 0 then
				percent = string.format("%.2f", v.hurt/bossmaxHp*100)
			end
			hurt = v.hurt
			vo.hurtNum = string.format( StrConfig['worldBoss201'], percent)  --伤害
			objSwf.bossPanel.listMy.dataProvider:push(UIData.encode(vo));
			objSwf.bossPanel.listMy:invalidateData();
		else
			index = index +1;
		end 
	end
	--未上榜
	if index >= #bossHurtList then
		local damage = ActivityDIFXuanYuanCave:GetMiJingBossDamageData( ) or 0
		local info = MainPlayerModel.humanDetailInfo
		local vo = {};
		vo.playerName = info.eaName
		vo.rankNum = 'z';   --未上榜 默认为z和字体资源保持一致
		local percent = 0
		if bossmaxHp  > 0 then
			percent = math.floor(damage/bossmaxHp*100)
		end
		hurt = damage
		vo.hurtNum = string.format( StrConfig['worldBoss201'], percent)  --伤害
		objSwf.bossPanel.listMy.dataProvider:push(UIData.encode(vo));
		objSwf.bossPanel.listMy:invalidateData();
	end
	if self.BossStateChange and hurt ~= 0 then
		if not self.hurt then
			self.hurt = hurt
		elseif self.hurt ~= hurt then
			self.BossStateChange = false
			self:OnBossRankClick()
		end
	end
end

function UIXianYuanCaveInfo:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

--寻路点击
function UIXianYuanCaveInfo:OnStarRoadClick(state)
	if not state then return end
	local bossID;
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	bossID = ActivityXuanYuanCave:GetBossID();
	-- else
		bossID = ActivityDIFXuanYuanCave:GetBossID();
	-- end
	local cfg = nil;
	for i ,  v in ipairs(t_xianyuancave) do
		if v.bossID == bossID then
			cfg = v;
			break;
		end
	end
	if not cfg then return end
	local posCfg;
	if state == 1 then
		posCfg = cfg.safePos;
	elseif state == 2 then 
		posCfg = cfg.unSafePos;
	end
	if not posCfg then return end
	local posTable = split(posCfg,'#');
	local point = QuestUtil:GetQuestPos(toint(posTable[math.random(#posTable)]));
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
end

function UIXianYuanCaveInfo:OnShow()
	self.BossStateChange = true
	if self.timeKey then    ---草特么的  不信删不掉你
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	
	self:OnInitPanel();
	self:OnShowBossInfo()
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	ActivityController:SendActivityOnLineTime(ActivityConsts.XianYuan);
	-- else
		ActivityController:SendActivityOnLineTime(ActivityConsts.T_DaBaoMiJing);
	-- end
	self:OnShowCaveTxtInfo();
	self:OnShowCaveBossInfo();
	self:ShowAllExp()
	

	-- UIAutoBattleTip:Open(function()UIXianYuanCaveInfo:OnStarRoadClick(math.random(2));end,true);
end

function UIXianYuanCaveInfo:OnInitPanel()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.btn_pageInfo.selected = true;
	objSwf.smallPanel.visible = true;
	objSwf.rewardPanel.visible = true;
	objSwf.bossPanel._visible = false
	-- objSwf.btn_info.selected = true;
end

function UIXianYuanCaveInfo:GetWidth()
	return 242;
end

function UIXianYuanCaveInfo:GetHeight()
	return 508;
end

function UIXianYuanCaveInfo:OnBossClick()
	local bossID;
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	bossID = ActivityXuanYuanCave:GetBossID();
	-- else
		bossID = ActivityDIFXuanYuanCave:GetBossID();
	-- end
	if not bossID then return end
	local cfg;
	for i ,  v in ipairs(t_xianyuancave) do
		if v.bossID == bossID then
			cfg = v;
			break;
		end
	end
	local point = QuestUtil:GetQuestPos(cfg.posID);
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc);
end

function UIXianYuanCaveInfo:OnShowCaveTxtInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if ActivityDIFXuanYuanCave:GetBossID() == 0 then
		return 
	end
	-- objSwf.smallPanel.btn_aotu.label = StrConfig['cave021'];
	local cfg = t_map[CPlayerMap:GetCurMapID()];
	if not cfg then print('11111111')return end
	
	local bossID;
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	bossID = ActivityXuanYuanCave:GetBossID();
	-- else
		bossID = ActivityDIFXuanYuanCave:GetBossID();
	-- end
	if not bossID then print('222222')return end
	
	local caveCfg ;
	for i ,  v in ipairs(t_xianyuancave) do
		if v.bossID == bossID then
			caveCfg = v;
			break;
		end
	end
	if not caveCfg then print('33333333')return end
	self:OnChangePKStateTxt();
	
	local rewardList = RewardManager:Parse(caveCfg.eliteReward);
	objSwf.smallPanel.caveMapList.dataProvider:cleanUp();
	objSwf.smallPanel.caveMapList.dataProvider:push(unpack(rewardList));
	objSwf.smallPanel.caveMapList:invalidateData();
	
	local rewardList2 = RewardManager:Parse(caveCfg.monsterReward);
	objSwf.smallPanel.caveMapList2.dataProvider:cleanUp();
	objSwf.smallPanel.caveMapList2.dataProvider:push(unpack(rewardList2));
	objSwf.smallPanel.caveMapList2:invalidateData();
		
	-- objSwf.smallPanel.txt_2.htmlText = string.format(StrConfig['cave012'],cfg.rcmdLv);
	--疲劳值
	self:OnSetPiLaoVal();
end

function UIXianYuanCaveInfo:OnLineTimeNum()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local onLineData = UIXianYuanCave.onLineTimeData;
	if not onLineData or onLineData == {} then
		objSwf.smallPanel.txt_2.htmlText = '';
		return
	end
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	self:OnLineTimeStart(onLineData[ActivityConsts.XianYuan].timeNum);
	-- else
		self:OnLineTimeStart(onLineData[ActivityConsts.T_DaBaoMiJing].timeNum);
	-- end
end

function UIXianYuanCaveInfo:OnLineTimeStart(num)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.onLineTimeKey then
		TimerManager:UnRegisterTimer(self.onLineTimeKey);
		self.onLineTimeKey = nil;
	end
	local endNum = num;
	local timeNum = num;
	self.onLineTimeKey = TimerManager:RegisterTimer(function()
		local hour,min,sec = CTimeFormat:sec2format(timeNum);
		if hour < 10 then hour = '0' .. hour; end
		if min < 10 then min = '0' .. min; end 
		if sec < 10 then sec = '0' .. sec; end 
		objSwf.smallPanel.txt_2.htmlText = string.format(StrConfig['cave250'],hour,min,sec);
		timeNum = timeNum - 1;
		if timeNum < 1 then
			TimerManager:UnRegisterTimer(self.onLineTimeKey);
			self.onLineTimeKey = nil;
		end
	end,1000,endNum);
end

function UIXianYuanCaveInfo:OnSetPiLaoVal()
	local objSwf = self.objSwf;
	local caveCons	= t_consts[62];
	-- objSwf.smallPanel.txt_val.htmlText = string.format(StrConfig['cave200'],MainPlayerModel.humanDetailInfo.eaPiLao,caveCons.val1);
	-- objSwf.smallPanel.processBarMoney.value = MainPlayerModel.humanDetailInfo.eaPiLao;
end

--安全状态
function UIXianYuanCaveInfo:OnChangePKStateTxt()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local cfg = t_map[CPlayerMap:GetCurMapID()];
	if not cfg then return end
	local pkState = MainPlayerController:GetSafeArea();
	local cfgName = split(cfg.name,'_');
	if #cfgName < 2 then
		return
	end
	if pkState == 1 then 
		objSwf.smallPanel.txt_mapName.htmlText = StrConfig['cave010'];
		-- objSwf.smallPanel.txt_6.htmlText = string.format(StrConfig['cave050'],StrConfig['cave051']);
	else
		objSwf.smallPanel.txt_mapName.htmlText = StrConfig['cave011'];
		-- objSwf.smallPanel.txt_6.htmlText = string.format(StrConfig['cave050'],StrConfig['cave052']);
	end
end

--BOSS信息简介
UIXianYuanCaveInfo.timeKey = nil;
function UIXianYuanCaveInfo:OnShowCaveBossInfo()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if ActivityDIFXuanYuanCave:GetBossID() == 0 then
		return 
	end
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	self.curMonster = ActivityXuanYuanCave:GetBossID();
	-- else
		self.curMonster = ActivityDIFXuanYuanCave:GetBossID();
	-- end
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end
	
	local cfg = t_monster[self.curMonster];
	if not cfg then return end
	
	--objSwf.smallPanel.btn_monster.txt_name.htmlText = '<u>' .. cfg.name .. '<u/>';
	local bossState;
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	bossState = ActivityXuanYuanCave:GetBossState();
	-- else
		bossState = ActivityDIFXuanYuanCave:GetBossState();
	-- end
	if not bossState then return end
	if bossState < 0 then 
		if self.timeKey then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
		objSwf.smallPanel.btn_monster.textField.htmlText = string.format(StrConfig['cave101'],cfg.name);
		objSwf.smallPanel.txt_time.text = UIStrConfig['cave7'];
		objSwf.smallPanel.pfx._visible = true
	else
		objSwf.smallPanel.btn_monster.textField.htmlText = string.format(StrConfig['cave102'],cfg.name);
		local func = function()
			local hour,min,sec = self:OnBackNowLeaveTime();
			if hour < 10 then hour = '0' .. hour; end
			if min < 10 then min = '0' .. min; end 
			if sec < 10 then sec = '0' .. sec; end 
			objSwf.smallPanel.txt_time.htmlText = string.format(StrConfig['cave006'],hour,min,sec);
		end
		if self.timeKey then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
		objSwf.smallPanel.pfx._visible = false
		self.timeKey = TimerManager:RegisterTimer(func,1000);
	end
	
	for i = 1, 5 do
		objSwf.smallPanel['icon_' ..i]._visible = ActivityDIFXuanYuanCave:GetFloor() == i
	end
	local pos, name = ActivityDIFXuanYuanCave:GetMonsterPos()
	objSwf.smallPanel.btn_monster1.textField.htmlText = string.format(StrConfig['cave101'], name)
	objSwf.smallPanel.btn_monster1.click = function()
		ActivityDIFXuanYuanCave:GotoFight()
	end
	-- objSwf.bossTip.bossName.text = cfg.name;
	-- objSwf.bossTip.bossip.text = mapCfg.name;
	-- objSwf.bossTip.txt_info.text = cfg.monsterinfo;
	-- self:OnShowBossRewardHandler();
end

function UIXianYuanCaveInfo:OnHide()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self.onLineTimeKey then
		TimerManager:UnRegisterTimer(self.onLineTimeKey);
		self.onLineTimeKey = nil;
	end
	if self.timeExpKey then
		TimerManager:UnRegisterTimer(self.timeExpKey)
		self.timeExpKey = nil
	end
	objSwf.smallPanel.txt_2.htmlText = '';
	-- if UIAutoBattleTip:IsShow() then
	-- 	UIAutoBattleTip:Hide();
	-- end
	self.openState = true;
	self.rewardOpenState = true
	objSwf.rewardPanel.rewardList.caveRewardList.dataProvider:cleanUp();
	objSwf.rewardPanel.rewardList.caveRewardList:invalidateData();
	self.allRewardList = {};
	UIConfirm:Close(self.confirmId);
end

function UIXianYuanCaveInfo:OnBackNowLeaveTime()
	local overTime;
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	overTime = ActivityXuanYuanCave:GetBossState();
	-- else
		overTime = ActivityDIFXuanYuanCave:GetBossState();
	-- end
	if not overTime then return end
	
	-- if not _time then _time = 0 end
	local hour,min,sec;
	if overTime < 0 then
		hour,min,sec = 0,0,0;
	else
		hour,min,sec = CTimeFormat:sec2format(overTime);
	end
	
	return hour,min,sec
end
--BOSS奖励列表
function UIXianYuanCaveInfo:OnShowBossRewardHandler()
	local objSwf = self.objSwf ;
	
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	self.curMonster = ActivityXuanYuanCave:GetBossID();
	-- else
		self.curMonster = ActivityDIFXuanYuanCave:GetBossID();
	-- end
	if not self.curMonster then return end
	
	local caveCfg ;
	for i ,  v in ipairs(t_xianyuancave) do
		if v.bossID == self.curMonster then
			caveCfg = v;
			break;
		end
	end
	if not caveCfg then return end
	local obj = split(caveCfg.bossReward,"#");
	for i = 1 , 4 do
		-- objSwf.bossTip['icon_' .. i].visible = false;
	end
	for i = 1 , #obj do
		local RewardCfg = {};
		RewardCfg.showCount = 0;
		RewardCfg._isSmall = false;
		local num = tonumber(obj[i]);
		local a = t_item[num].bind; 
		if a == 1 then RewardCfg.showBind = false; else RewardCfg.showBind = true; end
		RewardCfg.iconUrl = ResUtil:GetItemIconUrl(t_item[num].icon);
		local icon_Url = ResUtil:GetSlotQuality(t_item[num].quality,true);
		RewardCfg.qualityUrl = icon_Url;
		RewardCfg.quality = t_item[num].quality;
		-- objSwf.bossTip['icon_' .. i].visible = true;
 	-- 	objSwf.bossTip['icon_' .. i]:setData(UIData.encode(RewardCfg));
	end
end

-- 创建配置文件
UIXianYuanCaveInfo.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(402,625)
								  };
function UIXianYuanCaveInfo:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	return cfg;
end

--画BOSS模型
UIXianYuanCaveInfo.curMonster = 0;
function UIXianYuanCaveInfo:DrawBoss()
	local objSwf = self.objSwf;
	-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
	-- 	self.curMonster = ActivityXuanYuanCave:GetBossID();
	-- else
		self.curMonster = ActivityDIFXuanYuanCave:GetBossID();
	-- end
	local group = self.curMonster;
	if group == 0 and not group then return end
	local monsterAvater = MonsterAvatar:NewMonsterAvatar(nil,group);
	monsterAvater:InitAvatar();
	local drawcfg = UIDrawXianyuanCaveBossCfg[group]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();
	end;
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("XianYuanCaveBoss",monsterAvater, objSwf.bossTip.monsterLoad,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000);
	else
		self.objUIDraw:SetUILoader(objSwf.bossTip.monsterLoad);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(monsterAvater);
	end;
	self.objUIDraw:SetDraw(true);
end

--关闭必要处理
function UIXianYuanCaveInfo:OnHideBoss()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
end

function UIXianYuanCaveInfo:OnOutCaveHandler()
	local func = function () 
		-- if ActivityController:GetCurrId() == ActivityConsts.XianYuan then
		-- 	ActivityController:QuitActivity(ActivityConsts.XianYuan);
		-- else
			ActivityController:QuitActivity(ActivityConsts.T_DaBaoMiJing);
		-- end
	end
	self.confirmId = UIConfirm:Open(StrConfig['cave002'],func);
end

--改变挂机按钮文本
function UIXianYuanCaveInfo:OnChangeAutoText(state)
	local objSwf = self.objSwf;
	if not objSwf then return end
	-- if state then
	-- 	if UIAutoBattleTip:IsShow() then
	-- 		UIAutoBattleTip:Hide();
	-- 	end
	-- else
	-- 	UIAutoBattleTip:Open(function()UIXianYuanCaveInfo:OnStarRoadClick(math.random(2));end);
	-- end
end

--奖励数据
UIXianYuanCaveInfo.allRewardList = {};
function UIXianYuanCaveInfo:OnRewardList(itemVO)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local isEuip = false;
	local itemCfg = t_item[itemVO.configId] ;--or t_item[itemVO.configId];
	if not itemCfg then
		isEuip = true;
		itemCfg = t_equip[itemVO.configId];
	end
	if not itemCfg then print('not rewardID' .. itemVO.configId)return end
	local isNewItem = true;
	if not isEuip then
		for i , v in ipairs(self.allRewardList) do
			if v.id == itemVO.configId and v.num ~= itemCfg.repeats then
				isNewItem = false;
				if itemVO.configId == enAttrType.eaBindGold then
					v.num = v.num + itemVO.stackCount;				--如果是钱  直接叠加
					break
				end
				
				if v.num + itemVO.stackCount <= itemCfg.repeats then
					v.num = v.num + itemVO.stackCount;				--如果小于最大叠加数  
					break
				elseif v.num + itemVO.stackCount > itemCfg.repeats then
					v.num = itemCfg.repeats;	
					local vo = {};
					vo.id = itemVO.configId;
					vo.num = itemVO.stackCount - itemCfg.repeats - v.num;
					table.push(self.allRewardList,vo);
					break
				elseif v.num + itemVO.stackCount == itemCfg.repeats then
					v.num = itemCfg.repeats;
					break
				end
			end
		end
	end
	if isNewItem then
		local vo = {};
		vo.id = itemVO.configId;
		vo.num = itemVO.stackCount;
		table.push(self.allRewardList,vo);
	end
	
	if objSwf.rewardPanel.visible then
		self:OnDrawRewardList();
	end	
end

function UIXianYuanCaveInfo:OnDrawRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rewardStr = '';
	for i , v in ipairs(self.allRewardList) do
		if i >= #self.allRewardList then
			rewardStr = rewardStr .. v.id .. ',' .. v.num ;
		else
			rewardStr = rewardStr .. v.id .. ',' .. v.num .. '#';
		end
	end
	local rewardList = RewardManager:Parse(rewardStr);
	objSwf.rewardPanel.rewardList.caveRewardList.dataProvider:cleanUp();
	objSwf.rewardPanel.rewardList.caveRewardList.dataProvider:push(unpack(rewardList));
	objSwf.rewardPanel.rewardList.caveRewardList:invalidateData();
end

function UIXianYuanCaveInfo:HandleNotification(name,body)
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:OnShowCaveBossInfo()
		end
	elseif name == NotifyConsts.PkStateChange then
		self:OnChangePKStateTxt();
	elseif name == NotifyConsts.CavePiLaoChange then
		self:OnSetPiLaoVal();
	elseif name == NotifyConsts.AutoHangStateChange then
		-- self:OnChangeAutoText(body.state)
	elseif name == NotifyConsts.CaveReward then
		self:OnRewardList(body)
	elseif name == NotifyConsts.CaveBossState then
		self.BossStateChange = true
		self.hurt = nil
		self:OnShowCaveTxtInfo();
		self:OnShowCaveBossInfo();
		self:OnShowBossInfo()
	elseif name == NotifyConsts.ActivityOnLineTime then
		self:OnLineTimeNum();
	elseif name == NotifyConsts.CaveBossHurt then
		self:OnChangeHurtBossRankList();
	elseif name == NotifyConsts.CaveDamage then
		self:OnChangeHurtBossRankList();
	end
end
function UIXianYuanCaveInfo:ListNotificationInterests()
	return {
		NotifyConsts.PkStateChange,NotifyConsts.CavePiLaoChange,
		NotifyConsts.AutoHangStateChange,
		NotifyConsts.CaveReward,
		NotifyConsts.CaveBossState,
		NotifyConsts.ActivityOnLineTime,
		NotifyConsts.CaveBossHurt,
		NotifyConsts.CaveDamage,
		NotifyConsts.PlayerAttrChange,
	}
end