local battleprepare = class( "battleprepare", layout );

global_event.BATTLEPREPARE_SHOW = "BATTLEPREPARE_SHOW";
global_event.BATTLEPREPARE_HIDE = "BATTLEPREPARE_HIDE";
global_event.BATTLEPREPARE_UPDATE_SHIPINDEX = "BATTLEPREPARE_UPDATE_SHIPINDEX";
global_event.BATTLEPREPARE_UPDATE_ENEMY_UNIT_ID = "BATTLEPREPARE_UPDATE_ENEMY_UNIT_ID";
global_event.BATTLEPREPARE_UPDATE_MAGIC = "BATTLEPREPARE_UPDATE_MAGIC";
global_event.BATTLEPREPARE_UPDATE_BATTLEPOWER = "BATTLEPREPARE_UPDATE_BATTLEPOWER";
global_event.BATTLEPREPARE_REFRESH_UNIT = "BATTLEPREPARE_REFRESH_UNIT";

function battleprepare:ctor( id )
	battleprepare.super.ctor( self, id );
	self:addEvent({ name = global_event.BATTLEPREPARE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BATTLEPREPARE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.BATTLEPREPARE_UPDATE_SHIPINDEX, eventHandler = self.onUpdateShipIndex});
	self:addEvent({ name = global_event.BATTLEPREPARE_UPDATE_MAGIC, eventHandler = self.updateMagic});
	
	self:addEvent({ name = global_event.BATTLEPREPARE_UPDATE_BATTLEPOWER, eventHandler = self.updateBattlePower});
	self:addEvent({ name = global_event.BATTLEPREPARE_REFRESH_UNIT, eventHandler = self.onRefreshUnitList});
	self:addEvent({ name = global_event.RECEIVE_BEST_BATTLE_RECORD, eventHandler = self.onReceiveRecord});
end
function battleprepare:onReceiveRecord(event)
	if not self._show then
		return;
	end
	global.GlobalReplaySummaryInfo.name = global.GlobalReplaySummaryInfo.name or ""
	self.battleprepare_rec_name:SetText(global.GlobalReplaySummaryInfo.name)
	if(global.GlobalReplaySummaryInfo.name == "")then
		self.battleprepare_rec_back:SetVisible(false);
		self.battleprepare_bestrec:SetVisible(false);
	else
		local  isShowBestRepaly = global.isShowBestRepaly(battleprepare.battleType)
		self.battleprepare_rec_back:SetVisible(isShowBestRepaly);
		self.battleprepare_bestrec:SetVisible(isShowBestRepaly);
	end
end	
 
function battleprepare:updateBattlePower(event)
	if not self._show then
		return;
	end
	self.battleprepare_zhanli_num:SetText(global.battlePower())
end	

function battleprepare:showPowerEnemy()
	 
	if self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
		self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE or
		self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT or
		self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED or
		self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE or
		self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE or
		self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
		self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
		self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then
		-- 敌人信息从stage表
		local stageInfo = dataConfig.configs.stageConfig[battlePrepareScene.copyID];
		if not stageInfo then
			return;
		end
		 
		local config = stageInfo
		local power = 0	
		local _shipAttrBase ={}
			_shipAttrBase[1] ={}
			_shipAttrBase[1].attack = 0
			_shipAttrBase[1].defence = 0
			_shipAttrBase[1].critical = 0
			_shipAttrBase[1].resilience = 0
						
		local countRate = 1
		if stageInfo.needAdjust and dataManager.playerData:getPlayerConfig() then
			local numberRatio = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel() + stageInfo.adjustLevel).numberRatio;
			countRate = 	numberRatio / 60
			 _shipAttrBase = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel() + stageInfo.adjustLevel).shipAttrBase
		end
		for i,v in ipairs(config.units)do
			local star = dataConfig.configs.unitConfig[v].starLevel
			local quality = dataConfig.configs.unitConfig[v].quality
			local count = math.floor(config.unitCount[i] * countRate) ;
			count = dataConfig.configs.unitConfig[v].food * count 
 		
			local attack = config['shipAttrBase'][1].attack + _shipAttrBase[1].attack
			local defence = config['shipAttrBase'][1].defence+ _shipAttrBase[1].defence
			local critical = config['shipAttrBase'][1].critical+ _shipAttrBase[1].critical
			local resilience = config['shipAttrBase'][1].resilience+ _shipAttrBase[1].resilience
			if(self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
				attack = dataManager.hurtRankData:getBossAttChallengeDamageDefence()
				defence = attack
				critical = dataManager.hurtRankData:getBossAttChallengeDamageResilience()
				resilience = critical
			end
			power = power +  global.getOneShipPower( star,quality,count,attack,defence,critical,resilience)
		end
		local magicStars = {}
		for i,v in ipairs(config.magics)do
			if(v > 0 )then
				table.insert(magicStars,config.magicLevels[i])
			end
		end	
		power = power + global.getAllMagicPower(magicStars,config.intelligence)	
		power =  math.ceil(power)
		self.enemyinformation_power_num:SetText(power)
		
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE then
		-- 敌人信息从pvp数据
		local adversary = dataManager.pvpData:getSelectPlayer();
		
		if(dataManager.pvpData:getOfflineFuchouFlag())then
			adversary = dataManager.pvpData:getFuchouSelectPlayer();
		end
		local enemyData = {};
		if adversary then
			enemyData.heroLevel = adversary.kingInfo.level;
			enemyData.mp = adversary.kingInfo.maxMP;
			enemyData.intelligence = adversary.kingInfo.intelligence;
			enemyData.magics = {};
			enemyData.magicLevels = {};
			enemyData.units = {};
			enemyData.kingName = adversary:getName()
			for k,v in ipairs(adversary.kingInfo.magics) do
				enemyData.magics[k] = v.id;
				enemyData.magicLevels[k] = v.level;
			end
			
			for k,v in ipairs(adversary.units) do
				enemyData.units[k] = v.id;
			end

			self.enemyinformation_power_num:SetText(adversary:playerPower());
		end
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_FIGHT then
		-- 敌人信息从pvp数据
		local adversary = dataManager.pvpData:getAskedLadderDetail();
	 
		local enemyData = {};
		if adversary then
			enemyData.heroLevel = adversary.kingInfo.level;
			enemyData.mp = adversary.kingInfo.maxMP;
			enemyData.intelligence = adversary.kingInfo.intelligence;
			enemyData.magics = {};
			enemyData.magicLevels = {};
			enemyData.units = {};
			enemyData.kingName = adversary:getName()
			for k,v in ipairs(adversary.kingInfo.magics) do
				enemyData.magics[k] = v.id;
				enemyData.magicLevels[k] = v.level;
			end
			
			for k,v in ipairs(adversary.units) do
				enemyData.units[k] = v.id;
			end

			self.enemyinformation_power_num:SetText(adversary:playerPower());
		end	
		 
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER or
					self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE then
		
		local targetInfo = dataManager.idolBuildData:getCurrentSelectTargetInfo();
		if targetInfo then
			self.enemyinformation_power_num:SetText(targetInfo.playerPower);
		else
			self.enemyinformation_power_num:SetText("");
		end
		
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR then
		
		local targetInfo = dataManager.guildWarData:getCurrentSelectTargetInfo();
		if targetInfo then
			self.enemyinformation_power_num:SetText(targetInfo.playerPower);
		else
			self.enemyinformation_power_num:SetText("");
		end
				
	end
	
end	
function battleprepare:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	self.battleprepare_crops_scroll = LORD.toScrollPane(self:Child("battleprepare-crops-scroll"));
	self.battleprepare_crops_scroll:init();
	
	--self.battleprepare_peizhibutton = self:Child( "battleprepare-peizhibutton" );
	self.battleprepare_enemyinfor = self:Child( "battleprepare-enemyinfor" );
	--self.battleprepare_youfang = self:Child( "battleprepare-youfang" );
	--self.battleprepare_button1 = self:Child( "battleprepare-button1" );
	--self.battleprepare_button2 = self:Child( "battleprepare-button2" );
	--self.battleprepare_difang = self:Child( "battleprepare-difang" );
	--self.battleprepare_difang:SetVisible(false);
	self.battleprepare_zhanli_num = self:Child( "battleprepare-zhanli-num" );
	self.battleprepare_close = self:Child( "battleprepare-close" );
	self.battleprepare_start = self:Child( "battleprepare-start")
	self.battleprepare_startauto = self:Child( "battleprepare-startauto")
	 
	--self.battleprepare_emenybutton = self:Child( "battleprepare-emenybutton" );
	self.battleprepare_zhanli_num:SetText(global.battlePower())
	
	self.battleprepare_zhanli_7 = self:Child( "battleprepare-zhanli_7" );
	self.battleprepare_zhanli_7:SetVisible(true);
	self.selectShipIndex = -1;
	self.enemyIndex = -1;
	self.enemyUnitID = -1;
	self.battleType = event.battleType;
	self.planType = event.planType;
	
	--self.battleprepare_button2:subscribeEvent("ButtonClick", "onClickUnitInfoSelf");
	--self.battleprepare_emenybutton:subscribeEvent("ButtonClick", "onClickUnitInfoEnemy");
	self.battleprepare_enemyinfor:subscribeEvent("ButtonClick", "onClickEnemyInfo");
	self.battleprepare_start:subscribeEvent( "ButtonClick", "onRunBattle" );
	self.battleprepare_startauto:subscribeEvent( "ButtonClick", "onRunBattle" );
	self.battleprepare_start:SetUserData(0)
	self.battleprepare_startauto:SetUserData(1)
	self.battleprepare_startauto:SetVisible(false)
		-- 等级限制
	if dataManager.playerData:getLevel() >= dataConfig.configs.ConfigConfig[0].autobattleLevelLimit then
		 self.battleprepare_startauto:SetVisible(true)
	end
 
	self.battleprepare_close:subscribeEvent( "ButtonClick", "onClickBack" );
	
	self.battleprepare_skillitem_name = {};
	self.battleprepare_skillitem_xuanzhong = {};
	self.battleprepare_skillitem_item = {};
	self.battleprepare_skillitem_num = {};
	self.battleprepare_skillitem_time = {};
	
	self.battleprepare_skillitem = {};
	
	self.enemyinformation_power_num = self:Child( "battleprepare-zhanli-num_7" );
	self.enemyinformation_power_num:SetText("")
	self:showPowerEnemy()
	
	local itemSize = LORD.Vector2(0, 0);
	for i=1, 7 do
		self.battleprepare_skillitem_name[i] = self:Child("battleprepare-skillitem"..i.."-name");
		self.battleprepare_skillitem_xuanzhong[i] = self:Child("battleprepare-skillitem"..i.."-xuanzhong");
		self.battleprepare_skillitem_item[i] = LORD.toStaticImage(self:Child("battleprepare-skillitem"..i.."-item"));
		self.battleprepare_skillitem_num[i] = self:Child("battleprepare-skillitem"..i.."-num");
		
		self.battleprepare_skillitem_time[i] = self:Child("battleprepare-skillitem"..i.."-time");
		
		if(i ~= 7)then
			self.battleprepare_skillitem_item[i]:subscribeEvent("WindowTouchUp", "onBattlePrepareDropDragMagic");
			
			self.battleprepare_skillitem_item[i]:setEnableDrag(true);
			self.battleprepare_skillitem_item[i]:subscribeEvent("WindowDragStart", "onBattlePrepareDragMagic");
			self.battleprepare_skillitem_item[i]:subscribeEvent("WindowDragging", "onBattlePrepareDraggingMagic");
			self.battleprepare_skillitem_item[i]:subscribeEvent("WindowDragEnd", "onBattlePrepareDragMagicEnd");			
		end
		
		self.battleprepare_skillitem_item[i]:SetProperty("EnableLongTouch", "true");		
		self.battleprepare_skillitem_item[i]:subscribeEvent("WindowLongTouch", "onBattlePrepareShowPlanTips");
		self.battleprepare_skillitem_item[i]:subscribeEvent("WindowLongTouchCancel", "onBattlePrepareHidePlanTips");
		self.battleprepare_skillitem_item[i]:subscribeEvent("MotionRelease", "onBattlePrepareHidePlanTips");
		
		self.battleprepare_skillitem_item[i]:SetUserData(i);
		
		self.battleprepare_skillitem_xuanzhong[i]:SetVisible(false);
		self.battleprepare_skillitem_name[i]:SetText("");
		self.battleprepare_skillitem_item[i]:SetImage("");
		self.battleprepare_skillitem_num[i]:SetText("");
		self.battleprepare_skillitem_time[i]:SetText("");
		
		itemSize = self.battleprepare_skillitem_item[i]:GetPixelSize();
	end
	
	-- 创建一个拖拽的控件
	self.battleprepareDraggingWindow = (LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("battleprepare", "dragmagic.dlg"));
	engine.uiRoot:AddChildWindow(self.battleprepareDraggingWindow);
	self.battleprepareDraggingWindow:SetVisible(false);
	
	-- 领地事件的相关提示
	self.battleprepare_eventlimit = self:Child("battleprepare-eventlimit");
	self.battleprepare_eventlimit_text = self:Child("battleprepare-eventlimit-text");
	self.battleprepare_eventlimit:SetVisible(false);
	
	
	-- 军团序列的相关提示
	self.battleprepare_skillspance_change = self:Child("battleprepare-skillspance-change");
	self.battleprepare_crops = LORD.toStaticImage(self:Child("battleprepare-crops"));
	self.battleprepare_crops_scroll = LORD.toScrollPane(self:Child("battleprepare-crops-scroll"));
	self.battleprepare_crops_scroll:init();

	--self.SkillInfoWindow = self:Child("battleprepare-skilldiban");
	--self.UnitInfoWindow = self:Child("battleprepare-crops");
	
	function onBattlePrepareHideUnitOrder()
		self:showUnitOrder(false);
	end
	
	function onBatllePrepareShowUnitOrder()
		self:showUnitOrder(true);
	end
	
	self.battleprepare_crops_button1 = self:Child("battleprepare-crops-button1");
	self.battleprepare_crops_button2 = self:Child("battleprepare-crops-button2");
	self.battleprepare_crops_button1:subscribeEvent( "WindowTouchUp", "onBattlePrepareHideUnitOrder" );
	self.battleprepare_crops_button2:subscribeEvent( "WindowTouchUp", "onBatllePrepareShowUnitOrder" );
		
	self:updateIncidentInfo();
	
	self:updateMagic();

	self.draggingMagicIndex = -1;
	
	function onTouchDownBattlePrepareUnitSkill(args)
	  
	  local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData();
 		
 		local rect = clickImage:GetUnclippedOuterRect();
 		rect.left = self.tipsPositionX;
 		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "skill", id = userdata, 
 				windowRect = rect, dir = "left" });
 			
	end

	function onTouchUpBattlePrepareUnitSkill(args)
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
			
	function onBattlePrepareDragMagic(args)
		local window = LORD.toWindowEventArgs(args).window;
		local touchpos = LORD.toMouseEventArgs(args).position;
		local index =  window:GetUserData();
		self:dragMagic(touchpos, index);
	end

	-- dragging
	function onBattlePrepareDraggingMagic(args)
		local window = LORD.toWindowEventArgs(args).window;
		local touchpos = LORD.toMouseEventArgs(args).position;
		local moveDelta = LORD.toMouseEventArgs(args).moveDelta;
		
		local position = self.battleprepareDraggingWindow:GetPosition();
		position.x = position.x + LORD.UDim(0, moveDelta.x);
		position.y = position.y + LORD.UDim(0, moveDelta.y);
		
		self.battleprepareDraggingWindow:SetPosition(position);
	end
	
	function onBattlePrepareDragMagicEnd(args)
		self.draggingMagicIndex = -1;
		self.battleprepareDraggingWindow:SetVisible(false);
	end
			
	function onBattlePrepareDropDragMagic(args)
		local window = LORD.toWindowEventArgs(args).window;
		local index =  window:GetUserData();		
		if self.draggingMagicIndex > 0 then
			self:dropDragMagic(index);
		else
			self:onSelMagic(index);
		end
	end
	
	
	-- 快捷栏上的tips
	function onBattlePrepareShowPlanTips(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local index =  window:GetUserData();

		local magicID = getEquipedMagicData(index).id;
		if magicID > 0 then
			local magicInstance = dataManager.kingMagic:getMagic(magicID);
			local rect = window:GetUnclippedOuterRect();
 			eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "magic", id = magicID, windowRect = rect, dir = "top",
 																	magicLevel = magicInstance:getStar(), intelligence = dataManager.playerData:getIntelligence()});		
		end
	end

	function onBattlePrepareHidePlanTips(args)
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	
	function onRunBattle(args)
		if(global.tipBagFull())then
			return
		end	
		local window = LORD.toWindowEventArgs(args).window;
		local isAutoBattle = false
		if(window:GetUserData() == 1)then
			isAutoBattle = true
		end

		if(battlePrepareScene.isPvPOnlineBattleType()) then		
			local beginTime,isPvPing ,endTime = dataManager.pvpData:getOnlineBeginTime()	
			--isPvPing = 1	
			if( not isPvPing)then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
						messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
						textInfo = "比赛还没开始" });
					return
			
			end
	 
			local lose = dataManager.pvpData:isOnlineOver()	
			if(lose)then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "您今天的比赛已经结束" });
				return
			end
			
			local cd,scd = dataManager.pvpData:isOnlineCD()	
			if(cd)then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "战斗cd中，请稍等"..scd.."秒" });
				return
			end
			
			
			local cd,scd = dataManager.pvpData:isWaitCD()	
			if(cd)then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "匹配cd中，请稍等"..scd.."秒" });
				return
			end			
		
			
			eventManager.dispatchEvent( {name = global_event.MATCHING_SHOW})	
		end		
		battlePlayer.prepareAutoBattle = isAutoBattle
		dataManager.pvpData:setBattleTime()	
		self:runBattle();		
	end
	
	function onClickBack()
		self:onBack();
	end
	
	--[[
	function onClickUnitInfoSelf()
		self:onUnitInfoSelf();
	end
	
	function onClickUnitInfoEnemy()
		self:onUnitInfoEnemy();
	end
	--]]
	
	function onClickEnemyInfo()
		self:onEnemyInfo();
	end
	
	function onSelectBattlePrepareRace(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local race = window:GetUserData();
		local index = race + 1;
		
		if window:IsSelected() then
		
			self.clickNewUnitFlag[race] = true;
			self:refreshSelectCardUI(race);
			eventManager.dispatchEvent({name = global_event.GUIDE_ON_BATTLEPREPARE_CHANGE_RACE ,arg1 = race })	
			
			for i=1, 4 do
				
				local battleprepare_tab_text = self:Child("battleprepare-tab"..i.."-text");
				local battleprepare_tab_text_chose = self:Child("battleprepare-tab"..i.."-text-chose");
				
				battleprepare_tab_text:SetVisible(index ~= i);
				battleprepare_tab_text_chose:SetVisible(index == i);
				
			end
	
		end
	end
	
	function onClickBattlePrepareLoadCard(args)
		local window = LORD.toWindowEventArgs(args).window;
		local cardType = window:GetUserData();
		self:loadCard(cardType);
		self.battleprepare_cropschose:SetVisible(false); --完成上阵操作后隐藏
		eventManager.dispatchEvent({name = global_event.GUIDE_ON_BATTLEPREPARE_CLOSE });
		self:visiblePvPOnline(true);
	end
	
	-- 新的军团选择列表
	self.battleprepare_cropschose = self:Child("battleprepare-cropschose");
	local rect = self.battleprepare_cropschose:GetUnclippedOuterRect();
	self.tipsPositionX = rect.left;
	self.tipsPositionY = rect.top;
	
	self.battleprepare_cropschose:SetVisible(false);
	
	self.battleprepare_pvp = self:Child("battleprepare-pvp");	

	
	self.pvp = {}
	
	self.pvp.battleprepare_title = self:Child("battleprepare-title");
	self.pvp.battleprepare_lose = self:Child("battleprepare-lose");
 	self.pvp.battleprepare_win = self:Child("battleprepare-win");
	self.pvp.battleprepare_time = self:Child("battleprepare-time");
	self.pvp.battleprepare_countdown = self:Child("battleprepare-countdown");
	self.pvp.battleprepare_award = self:Child("battleprepare-award");
 	self.pvp.battleprepare_shop = self:Child("battleprepare-shop");	
	self.pvp.battleprepare_loseNum = {}
	for i = 1 ,3 do
		 self.pvp.battleprepare_loseNum[i]= self:Child("battleprepare-lose"..i);
	end	
	
	self.pvp.battleprepare_winNum = {}
	self.pvp.battleprepare_winEmptyNum = {}
	for i = 1 ,5 do
		self.pvp.battleprepare_winNum[i]= self:Child("battleprepare-win"..i);
		self.pvp.battleprepare_winEmptyNum[i]= self:Child("battleprepare-win"..i.."-empty");
	end	
	function onbattleprepare_shop_click()
		global.openShop(enum.SHOP_TYPE.SHOP_TYPE_HONOR)		
	end	
	
	self.pvp.battleprepare_shop:subscribeEvent("ButtonClick", "onbattleprepare_shop_click");
	
	
	function onbattleprepare_award_click()
		 	eventManager.dispatchEvent({name = global_event.RULE_SHOW,battleType = battlePrepareScene.battleType })
	end	
	
	--[[
	function onBattlePrepareChange()
		if self.currentTab == 0 then
			self:onUnitInfo();
		else
			self:onMagicInfo();
		end	
	end
	--]]
	
	--self:onMagicInfo(); -- magic
	
	--self.battleprepare_change = self:Child("battleprepare-change");
	--self.battleprepare_change:subscribeEvent("ButtonClick", "onBattlePrepareChange");
	
	self.pvp.battleprepare_award:subscribeEvent("ButtonClick", "onbattleprepare_award_click");
	
	
	self:visiblePvPOnline(battlePrepareScene.isPvPOnlineBattleType())
	 
	-- 种族button
	self.battleprepare_tab = {};
	self.battleprepare_tab_text = {};
	self.battleprepare_tab_new_text = {};
	self.battleprepare_tab_new = {};
	self.clickNewUnitFlag = {};
	
	for i=1, 4 do
		self.battleprepare_tab[i] = LORD.toRadioButton(self:Child("battleprepare-tab"..i));
		self.battleprepare_tab[i]:SetUserData(i-1);
		self.battleprepare_tab[i]:subscribeEvent("RadioStateChanged", "onSelectBattlePrepareRace");
		self.battleprepare_tab_text[i] = self:Child("battleprepare-tab"..i.."-text");
		self.battleprepare_tab_new[i] = self:Child("battleprepare-tab"..i.."-new");
		self.battleprepare_tab_new_text[i] = self:Child("battleprepare-tab"..i.."-new-text");
		
		local count = cardData.getNewGainedCountByRaceInBattle(i-1);
		self.battleprepare_tab_new[i]:SetVisible(count > 0);
		self.battleprepare_tab_new_text[i]:SetText(count);
		
		self.clickNewUnitFlag[i] = false;
	end
	
	self.battleprepare_scroll = LORD.toScrollPane(self:Child("battleprepare-scroll"));
	self.battleprepare_scroll:init();
	
	self.battleprepare_units = {};
	self.battleprepare_units.icon = {};
	self.battleprepare_units.shipIcon = {};
	self.battleprepare_units.star = {};
	self.battleprepare_units.name = {};
	self.battleprepare_units.skill = {};
	
	--self.battleprepare_tab[1]:SetSelected(true);
	if event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE or 
		(event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE and
			event.planType == enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD) then
		self.battleprepare_enemyinfor:SetVisible(false);
	else
		self.battleprepare_enemyinfor:SetVisible(true);
	end
	
	if event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE and
			event.planType == enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD then
		self.battleprepare_start:SetVisible(false);
	else
		self.battleprepare_start:SetVisible(true);
	end
	
	if(event.planType == enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD)then
		self.battleprepare_zhanli_7:SetVisible(false);
	end
	
	
	self:showUnitSequnceByConfig();
	battleprepare.battleType = event.battleType
	
	function battleprepare_onclickAskBestBattleRecord()
		global.askGlobalReplay(battleprepare.battleType,battlePrepareScene.ReplaySummaryIndex) 
		global.GlobalReplaySummaryInfo.isPrepareSceneAskBestBattleRecord = true
		battlePrepareScene.closePrepareScene();
		self:onHide()
	end	
	
	
	self.battleprepare_rec_name = self:Child("battleprepare-rec-name");
	self.battleprepare_rec_name:SetText("")
 	self.battleprepare_rec_back = self:Child("battleprepare-rec-back");
 
	function battlelose_onclickAskBestBattleRecord()
		global.askGlobalReplay(battleprepare.battleType,battlePrepareScene.ReplaySummaryIndex) 
	end
	
	self.battleprepare_bestrec = self:Child("battleprepare-bestrec");
	self.battleprepare_bestrec:subscribeEvent("ButtonClick", "battleprepare_onclickAskBestBattleRecord");
	
	local  isShowBestRepaly = global.isShowBestRepaly(battleprepare.battleType)
	self.battleprepare_rec_back:SetVisible(isShowBestRepaly);
	self.battleprepare_bestrec:SetVisible(isShowBestRepaly);
	if(isShowBestRepaly)then
		global.askGlobalReplaySummary(battleprepare.battleType,battlePrepareScene.ReplaySummaryIndex) 
	end
	 
end


function battleprepare:visiblePvPOnline(v)
	self.battleprepare_pvp:SetVisible(v and battlePrepareScene.isPvPOnlineBattleType());
	if(v)then
		if self.battleprepare_cropschose:IsVisible() then
			self.battleprepare_cropschose:SetVisible(false);	--PVP界面出现后隐藏
			eventManager.dispatchEvent({name = global_event.GUIDE_ON_BATTLEPREPARE_CLOSE });
		end
	end
	
	if(v == false  or  not battlePrepareScene.isPvPOnlineBattleType())then
		return 
	end
	
	local beginTime,isPvPing ,endTime = dataManager.pvpData:getOnlineBeginTime()
	
	
	self.pvp.battleprepare_title:SetText(dataManager.pvpData:getOnlineName())
	self.pvp.battleprepare_lose:SetVisible(true);
 	self.pvp.battleprepare_win:SetVisible(true); 
	local color = "^FFFFFF"
	
	if(not isPvPing)then
		color = "^FF0000"
	end
	
	self.pvp.battleprepare_time:SetText(color..beginTime)

	local win = dataManager.pvpData:getOnlineWinNum()
	local lose = dataManager.pvpData:getOnlineLoseNum()	
	for i = 1 ,3 do	
		self.pvp.battleprepare_loseNum[i]:SetVisible( i <= lose )  
	end			
	for i = 1 ,5 do	
		self.pvp.battleprepare_winNum[i]:SetEnabled( i <= win )  
		self.pvp.battleprepare_winEmptyNum[i]:SetVisible( i > win ) 
	end	

	local i,j = string.find(endTime, ":")
	local ehour = tonumber( string.sub(endTime,1,i-1)	)	
	local emin = tonumber(string.sub(endTime,j+1,-1))	
	

 
	function pvpOnlineProduceHandleTimeTick()
		local serverTime = dataManager.getServerTime()
		self.pvp.battleprepare_countdown:SetText(formatTime(self.pvpEndTime - serverTime, true))
	end	
	
	local serverTime = dataManager.getServerTime()
	local time  = os.date("*t", serverTime)	
	time.hour = ehour
	time.min = emin
	time.sec = 0
	self.pvpEndTime =  os.time(time)
	self.pvp.battleprepare_countdown:SetText(color..endTime)
	if(isPvPing)then
		self.pvp.battleprepare_countdown:SetText(formatTime(self.pvpEndTime - serverTime, true))	
		if(self.pvpOnlineProduceHandle == nil)then
			self.pvpOnlineProduceHandle = scheduler.scheduleGlobal(pvpOnlineProduceHandleTimeTick,1)
		end	
	end	
end	


function battleprepare:dropDragMagic(index)
	
	local dropMagicID = getEquipedMagicData(index).id;
	local draggingMagicID = getEquipedMagicData(self.draggingMagicIndex).id;
	if dropMagicID > 0 then
		-- 交换
		setEquipedMagicData(self.draggingMagicIndex, dropMagicID);
		setEquipedMagicData(index, draggingMagicID);
	else
		-- 直接放上
		setEquipedMagicData(index, draggingMagicID);
		setEquipedMagicData(self.draggingMagicIndex, -1);
	end
	
	self:updateMagic();
	
	self.draggingMagicIndex = -1;
	self.battleprepareDraggingWindow:SetVisible(false);
	
end

function battleprepare:onHide(event)
	
	self.battleprepare_scroll = nil;
	
	if self._show == false then
		return;
	end
	
	for k,v in pairs(self.clickNewUnitFlag) do
		if v then
			cardData.setNewGainedByRaceInBattle(k);
		end
	end
	
	self.battleprepareDraggingWindow:SetVisible(false);
	LORD.GUIWindowManager:Instance():DestroyGUIWindow(self.battleprepareDraggingWindow);
	self.battleprepareDraggingWindow = nil;	
	
	self:Close();
	if(self.pvpOnlineProduceHandle ~= nil)then
		scheduler.unscheduleGlobal(self.pvpOnlineProduceHandle)
		self.pvpOnlineProduceHandle = nil
	end
	
	eventManager.dispatchEvent({name = global_event.BATTLESKILL_HIDE});
end

function battleprepare:dragMagic(touchpos, index)
	local magicID = getEquipedMagicData(index).id;
	local magicInfo = dataConfig.configs.magicConfig[magicID];
	if magicID > 0 and magicInfo and magicInfo.icon then
		self.draggingMagicIndex = index;
		--self.battleprepareDraggingWindow:SetImage(magicInfo.icon);
		
		LORD.toStaticImage(self:Child("battleprepare_dragmagic-item-item")):SetImage(magicInfo.icon);
		--[[local cost = dataManager.kingMagic:getMagic(magicID):getMpCost();
		self:Child("battleprepare_dragmagic-item-num"):SetText(tostring(cost));

		if magicInfo.castTimes < 0 then
			self:Child("battleprepare_dragmagic-item-time"):SetText("∞");
		else
			self:Child("battleprepare_dragmagic-item-time"):SetText("X"..magicInfo.castTimes);
		end--]]
		
		self.battleprepareDraggingWindow:SetVisible(true);
		local pixelsize = self.battleprepareDraggingWindow:GetPixelSize();
		self.battleprepareDraggingWindow:SetPosition(LORD.UVector2(LORD.UDim(0, touchpos.x-pixelsize.x/2), LORD.UDim(0, touchpos.y-pixelsize.y/2)));
	end
end

function battleprepare:onBack()
	
	global.changeGameState(function() 
		local returnType = battlePrepareScene.battleType;
		battlePrepareScene.sceneDestroy();
		
		-- 根据不同的返回主基地类型, 要弹出不同的界面	
		game.EnterProcess(game.GAME_STATE_MAIN, {returnType = returnType});
		
		self:onHide();	
	end);
end

function battleprepare:onUpdateShipIndex(event)
	self.selectShipIndex = event.selectShipIndex;
	
	-- 第一次更新
	self.isRefreshScroll = false;
	if shipData.shiplist[self.selectShipIndex] then
		-- 显示选择上阵的界面
		self.battleprepare_cropschose:SetVisible(true);		
	 	uiaction.turnaround(self.battleprepare_cropschose, 500);
		
		self:visiblePvPOnline(false)
		
		local cardType = PLAN_CONFIG.getShipCardType(self.selectShipIndex);
		local cardInstance = cardData.getCardInstance(cardType);
		if cardInstance then
			local race = cardInstance:getConfig().race;
			if self.battleprepare_tab[race+1] then
				-- 按照船上的军团种族选中
				self.battleprepare_tab[race+1]:SetSelected(false);
				self.battleprepare_tab[race+1]:SetSelected(true);
			end
		else
			-- 船上没有卡牌，默认选中第一页
			self.battleprepare_tab[1]:SetSelected(false);
			self.battleprepare_tab[1]:SetSelected(true);		
		end
		
		scheduler.performWithDelayGlobal(function() 	eventManager.dispatchEvent( {name = global_event.GUIDE_ON_SHOW_SELECTSHIP_UNIT , arg1 = self.selectShipIndex }) end, 0.5)
		
		
		
	
	else
		-- 隐藏选择上阵的界面
		if self.battleprepare_cropschose:IsVisible() then
			self.battleprepare_cropschose:SetVisible(false);	--点击空白处隐藏
			eventManager.dispatchEvent({name = global_event.GUIDE_ON_BATTLEPREPARE_CLOSE });
		end
		self:visiblePvPOnline(true)	
	end
	
	self.isRefreshScroll = true;
	 
end

function battleprepare:runBattle()
	battlePrepareScene.runBattle();
end

function battleprepare:updateIncidentInfo()
	-- 领地事件的相关提示
	if self.battleprepare_eventlimit and self.battleprepare_eventlimit_text then
		local incidentInfo = dataManager.mainBase:getCurrentIncidentInfo();
		if self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT and incidentInfo and incidentInfo.condition ~= enum.INCIDENT_CONDITION.INCIDENT_CONDITION_INVALID then
			self.battleprepare_eventlimit:SetVisible(true);
			if incidentInfo.describe then
				self.battleprepare_eventlimit_text:SetText(incidentInfo.describe);
			elseif incidentInfo.condition >= 0 then
				local text1 = enum.INCIDENT_CONDITION_TEXT[incidentInfo.condition];
				local text2 = enum.INCIDENT_COMPARE_TEXT[incidentInfo.compare];
				if text1 and text2 and incidentInfo.argument then
					self.battleprepare_eventlimit_text:SetText(text1..text2..incidentInfo.argument);
				end				
			end
		else
			self.battleprepare_eventlimit:SetVisible(false);
		end
	end
end

function battleprepare:updateMagic()
	if self._show == false then
		return;
	end
	
	local magicInfo = dataConfig.configs.magicConfig
	for i=1, 7 do
		local playerSkill = getEquipedMagicData(i)		
		if playerSkill and playerSkill.id  > 0 and magicInfo[playerSkill.id] then
					local cost = dataManager.kingMagic:getMagic(playerSkill.id ):getMpCost()
					self.battleprepare_skillitem_name[i]:SetText(magicInfo[playerSkill.id].name);
					self.battleprepare_skillitem_item[i]:SetImage(magicInfo[playerSkill.id].icon);
					self.battleprepare_skillitem_num[i]:SetText(cost);	
					
					if magicInfo[playerSkill.id].castTimes < 0 then
						--self.battleprepare_skillitem_time[i]:SetText("∞");
					else
						--self.battleprepare_skillitem_time[i]:SetText("X"..magicInfo[playerSkill.id].castTimes);
					end
					
					if magicInfo[playerSkill.id].cooldown == 0 then
						--self.battleprepare_skillitem_time[i]:SetText("");
					else
						--self.battleprepare_skillitem_time[i]:SetText(magicInfo[playerSkill.id].cooldown);
					end
		else
				self.battleprepare_skillitem_name[i]:SetText("");
				self.battleprepare_skillitem_item[i]:SetImage("");
				self.battleprepare_skillitem_num[i]:SetText("");
				self.battleprepare_skillitem_time[i]:SetText("");	
		end
	end
	eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_BATTLEPOWER });
end

function battleprepare:onEnemyInfo()
	eventManager.dispatchEvent({name = global_event.ENEMYINFORMATION_SHOW, useServerData = false,battleType = self.battleType, planType = self.planType, source = "prepare"});
end

function battleprepare:onSelMagic(gridIndex)
	
	eventManager.dispatchEvent({name = global_event.BATTLESKILL_SHOW});
	
end

function battleprepare:updateUnitInfo(index, cardType, unitInfo, xpos, ypos)
	
	self.battleprepare_units[index] = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("battleprepare_"..index, "battleprepareitem.dlg");
	self.battleprepare_units.icon[index] = LORD.toStaticImage(self:Child("battleprepare_"..index.."_battleprepareitem-head"));
	self.battleprepare_units.icon[index]:subscribeEvent("WindowTouchUp", "onClickBattlePrepareLoadCard");
	self.battleprepare_units.icon[index]:SetImage(unitInfo.icon);
	self.battleprepare_units.icon[index]:SetUserData(cardType);
	
	local battleprepareitem_equity = LORD.toStaticImage(self:Child("battleprepare_"..index.."_battleprepareitem-equity"));
	battleprepareitem_equity:SetImage(itemManager.getImageWithStar(unitInfo.starLevel));
	
	self.battleprepare_units.name[index] = self:Child("battleprepare_"..index.."_battleprepareitem-name");
	self.battleprepare_units.name[index]:SetText(unitInfo.name);
	
	self.battleprepare_units.shipIcon[index] = LORD.toStaticImage(self:Child("battleprepare_"..index.."_battleprepareitem-ship"));
	
	local newFlag = self:Child("battleprepare_"..index.."_battleprepareitem-new");
	if newFlag then
		local card = cardData.getCardInstance(cardType);
		
		newFlag:SetVisible(card:getNewGainedFlagInBattle() > 0 );
	end
	
	local shipIndex = PLAN_CONFIG.getShipEquipedCard(cardType);
	if shipIndex > 0 and shipIndex <=6 then
		self.battleprepare_units.shipIcon[index]:SetVisible(true);
		self.battleprepare_units.shipIcon[index]:SetImage(shipData.shipNumberIcon[shipIndex]);
	else
		self.battleprepare_units.shipIcon[index]:SetVisible(false);
	end
	
	self.battleprepare_units.star[index] = {};
	-- star
	for i=1, 6 do
		self.battleprepare_units.star[index][i] = LORD.toStaticImage(self:Child("battleprepare_"..index.."_battleprepareitem-star"..i));
		if i <= unitInfo.starLevel then
			self.battleprepare_units.star[index][i]:SetVisible(true);
		else
			self.battleprepare_units.star[index][i]:SetVisible(false);
		end
	end
	
	-- skill

	for i=1, 4 do
		self.battleprepare_units.skill[i] = LORD.toStaticImage(self:Child("battleprepare_"..index.."_battleprepareitem-skill"..i.."-item"));
		if unitInfo.skill[i] then
			local skillInfo = dataConfig.configs.skillConfig[unitInfo.skill[i]];
			if skillInfo then
				self.battleprepare_units.skill[i]:SetImage(skillInfo.icon);
				
				self.battleprepare_units.skill[i]:subscribeEvent("WindowTouchDown", "onTouchDownBattlePrepareUnitSkill");
				self.battleprepare_units.skill[i]:subscribeEvent("WindowTouchUp", "onTouchUpBattlePrepareUnitSkill");
				self.battleprepare_units.skill[i]:subscribeEvent("MotionRelease", "onTouchUpBattlePrepareUnitSkill");
				--global.onSkillTipsShow(self.battleprepare_units.skill[i], "skill", "left");
				--global.onTipsHide(self.battleprepare_units.skill[i]);
				
				self.battleprepare_units.skill[i]:SetUserData(skillInfo.id);
			else
				self.battleprepare_units.skill[i]:SetImage("");
			end
		else
			self.battleprepare_units.skill[i]:SetImage("");
		end
	end
	
	-- 查看信息按钮
	function onBattlePrepareUnitInfo(args)
		local window = LORD.toWindowEventArgs(args).window;
		local cardType = window:GetUserData();
		local shipInstance = shipData.getShipInstance(self.selectShipIndex);
		local cardInstance = cardData.getCardInstance(cardType);
		
		local tipsX = self.tipsPositionX;
		local tipsY = window:GetUnclippedOuterRect().top;
		
		if shipInstance and cardInstance then
			local unitNumber = shipInstance:calcUnitNumByCardType(cardType);
			local event = {
				name = global_event.CORPSATTRI_SHOW, 
				unitID = cardInstance:getUnitID(), 
				curUnitNum = unitNumber, 
				totalUnitNum = unitNumber,
				shipAttr = {},
			};

 			event.shipAttr.attack = shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK);
			event.shipAttr.defence = shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE);
			event.shipAttr.critical = shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL);
			event.shipAttr.resilience = shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE);
			
			event.posX = tipsX;
			event.posY = tipsY;
			eventManager.dispatchEvent(event);
		end
	end
	
	function onBattlePrepareHideUnitInfo()
		eventManager.dispatchEvent({name = global_event.CORPSATTRI_HIDE});
	end
	
	-- 自己方的信息不同的战斗类型是一样的，pvp,pve
	-- 敌方的是根据类型的不同来区分的，副本，领地是读取stage表的数据，offlinepvp是根据服务器下来的数据
	local infoButton = self:Child("battleprepare_"..index.."_battleprepareitem-button");
	infoButton:subscribeEvent("WindowTouchDown", "onBattlePrepareUnitInfo");
	infoButton:subscribeEvent("WindowTouchUp", "onBattlePrepareHideUnitInfo");
	infoButton:subscribeEvent("MotionRelease", "onBattlePrepareHideUnitInfo");
	infoButton:SetUserData(cardType);
	
	self.battleprepare_units[index]:SetXPosition(xpos);
	self.battleprepare_units[index]:SetYPosition(ypos);				
	self.battleprepare_scroll:additem(self.battleprepare_units[index]);
				
end

function battleprepare:refreshSelectCardUI(race)
	
	print("battleprepare:refreshSelectCardUI(race)"..race);
	
	self.battleprepare_units = {};
	self.battleprepare_units.icon = {};
	self.battleprepare_units.shipIcon = {};
	self.battleprepare_units.star = {};
	self.battleprepare_units.name = {};
	self.battleprepare_units.skill = {};
		
	self.battleprepare_scroll:ClearAllItem();
	self.battleprepare_scroll:InitializePos();
	
	local xpos = LORD.UDim(0, 0);
	local ypos = LORD.UDim(0, 0);
	
	local index = 1;
	
	-- 还是排列到原来的位置，但是要滚动到相应的位置
	local cardType = PLAN_CONFIG.getShipCardType(self.selectShipIndex);
	
	local scrollOffset = 0;
	for k,v in ipairs(cardData.cardlist) do
		if v.exp >= 10 then
			local unitRace = dataConfig.configs.unitConfig[v.unitID].race;
			local unitInfo = dataConfig.configs.unitConfig[v.unitID];
			
			-- 如果是当前装备的就记录一下位置
			if cardType == k then
				scrollOffset = -ypos.offset;
			end
			
			if unitRace == race then
				
				self:updateUnitInfo(index, v.cardType, unitInfo, xpos, ypos);
				
				ypos = ypos + self.battleprepare_units[index]:GetHeight();
				
				index = index + 1;
			end
			
		end		
	end
	
	if self.isRefreshScroll == false then
		self.battleprepare_scroll:SetVertScrollOffset(scrollOffset);
	else
		self.battleprepare_scroll:SetVertScrollOffset(0);
	end

end

function battleprepare:loadCard(cardType)
	battlePrepareScene.updateShipActor(self.selectShipIndex, cardType);
	eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_BATTLEPOWER });
	
	local cardInstance = cardData.getCardInstance(cardType);
	if cardInstance then
		cardData.playVoiceByUnitID(cardInstance:getUnitID());
	end
	
end

--[[
function battleprepare:onMagicInfo()
	
	self.currentTab = 0;
	
	self.UnitInfoWindow:SetVisible(true);
	self.SkillInfoWindow:SetVisible(true);
	
	uiaction.flipTwoWindowX(self.UnitInfoWindow, self.SkillInfoWindow, 65, 300);

end

function battleprepare:onUnitInfo()

	self.currentTab = 1;
	
	self.UnitInfoWindow:SetVisible(true);
	self.SkillInfoWindow:SetVisible(true);
	
	uiaction.flipTwoWindowX(self.SkillInfoWindow, self.UnitInfoWindow, 65, 300);

end
--]]

function battleprepare:onRefreshUnitList(event)
	
	self.battleprepare_crops_scroll:ClearAllItem();
	
	battlePrepareScene.calcAllActionOrder();
	
	-- actionorder
	--battlePrepareScene.m_ActionOrder;
	
	local xpos = LORD.UDim(0,0);
	local ypos = LORD.UDim(0,2);
	
	for i=1, 14 do
	
		local orderData = battlePrepareScene.m_ActionOrder[i];
		if orderData then
			
			local unitWindow = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("battleprepare-"..i, "battlecropsitem.dlg");
			local battlecropsitem_corps = LORD.toStaticImage(self:Child("battleprepare-"..i.."_battlecropsitem-corps"));
			local battlecropsitem_item = LORD.toStaticImage(self:Child("battleprepare-"..i.."_battlecropsitem-item"));
			

			if orderData.index < 0 then
				-- 国王
				if orderData.isFriendlyForce then
					battlecropsitem_corps:SetImage(enum.SELFBACK);
					battlecropsitem_item:SetImage(enum.ATTACK_KING_ICON);
				else
					battlecropsitem_corps:SetImage(enum.ENEMYBACK);
					battlecropsitem_item:SetImage(enum.GUARD_KING_ICON);
				end
				
				battlecropsitem_corps:SetVisible(true);
				battlecropsitem_item:SetUserData(orderData.index);
				
			else
								
				-- 军团
				local unit = battlePrepareScene.unitData[orderData.index];
												
				if unit then
				
					local unitInfo = dataConfig.configs.unitConfig[unit.unitID];
									
					if unit.force == enum.FORCE.FORCE_ATTACK then
						battlecropsitem_corps:SetImage(enum.SELFBACK);
					else
						battlecropsitem_corps:SetImage(enum.ENEMYBACK);
					end
					battlecropsitem_corps:SetVisible(true);
					battlecropsitem_item:SetImage(unitInfo.icon);
					battlecropsitem_item:SetUserData(orderData.index);
				end
				
			end			
			
			local width = unitWindow:GetWidth();
			unitWindow:SetXPosition(xpos);
			unitWindow:SetYPosition(ypos);
			
			xpos = xpos + width - LORD.UDim(0, -1);
			self.battleprepare_crops_scroll:additem(unitWindow);
		end
	end
end

function battleprepare:showUnitOrder(flag)
	
	if not self._show then
		return;
	end
	
	fio.writeIni("battle", "unitSequnce",  tostring(flag), global.getUserConfigFileName());
	
	if flag then
		-- 拉出序列
		local pixelsize = self.battleprepare_crops:GetPixelSize();
		self.battleprepare_crops:SetVisible(true);
		
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, -pixelsize.y, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
		--action:addKeyFrame(LORD.Vector3(0, -20, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 250);
		--action:addKeyFrame(LORD.Vector3(0, 20, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
		--action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 325);
		
		self.battleprepare_crops:removeEvent("UIActionEnd");
		self.battleprepare_crops:playAction(action);
		
		self.battleprepare_crops_button1:SetVisible(true);
		self.battleprepare_crops_button2:SetVisible(false);
		
	else
		-- 收起序列
		
		function onBattleprepareHideUnitEnd()
			if self._show then
				self.battleprepare_crops:SetVisible(false);
				self.battleprepare_crops_button1:SetVisible(false);
				self.battleprepare_crops_button2:SetVisible(true);
			end
		end
		
		local pixelsize = self.battleprepare_crops:GetPixelSize();
		
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(0, -pixelsize.y, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
		self.battleprepare_crops:removeEvent("UIActionEnd");
		self.battleprepare_crops:subscribeEvent("UIActionEnd", "onBattleprepareHideUnitEnd");
		self.battleprepare_crops:playAction(action);
		
	end
	
end


function battleprepare:showUnitSequnceByConfig()

	if not self._show then
		return;
	end
		
	local sequnceShow = fio.readIni("battle", "unitSequnce", "false", global.getUserConfigFileName());
	
	self.battleprepare_crops:SetVisible(stringToBool(sequnceShow));
	self.battleprepare_crops_button1:SetVisible(stringToBool(sequnceShow));
	self.battleprepare_crops_button2:SetVisible(not stringToBool(sequnceShow));
end

return battleprepare;
