--wz

local battleclass = class("battleclass",layout)

global_event.BATTLE_UI_SHOW = "BATTLE_UI_SHOW"
global_event.BATTLE_UI_HIDE = "BATTLE_UI_HIDE"
global_event.BATTLE_UI_UPDATE_UNIT_INFO = "BATTLE_UI_UPDATE_UNIT_INFO"
global_event.BATTLE_UI_DELETE_DEAD_UNIT = "BATTLE_UI_DELETE_DEAD_UNIT"
global_event.BATTLE_UI_SWITCH_TO_SKILL = "BATTLE_UI_SWITCH_TO_SKILL"
global_event.BATTLE_UI_SWITCH_TO_UNIT = "BATTLE_UI_SWITCH_TO_UNIT"
global_event.BATTLE_UI_UPDATE_MAGICCD = "BATTLE_UI_UPDATE_MAGICCD"
global_event.BATTLE_UI_UPDATE_CASTERMAGIC_COUNTER = "BATTLE_UI_UPDATE_CASTERMAGIC_COUNTER"

global_event.BATTLE_UI_OTHER_KING_CASERTMAGIC = "BATTLE_UI_OTHER_KING_CASERTMAGIC"
global_event.BATTLE_UI_CHANGE_KING_ICON = "BATTLE_UI_CHANGE_KING_ICON"

global_event.BATTLE_UI_SWITCH_TO_SKILL_ROUND = "BATTLE_UI_SWITCH_TO_SKILL_ROUND"

global_event.CLOSE_SKILL_MIND = "CLOSE_SKILL_MIND"

global_event.BATTLE_UI_UPDATE_UNIT_SEQUNCE = "BATTLE_UI_UPDATE_UNIT_SEQUNCE"

global_event.BATTLE_UI_UPDATE_SKIP = "BATTLE_UI_UPDATE_SKIP"

global_event.BATTLE_UI_FLY_MAGIC_OUT = "BATTLE_UI_FLY_MAGIC_OUT";
global_event.BATTLE_UI_FLY_MAGIC_AWAY = "BATTLE_UI_FLY_MAGIC_AWAY";
--[==[
[[
battleclass.timeStamp = 0;
battleclass.deadTimeStamp = 0;
battleclass.switchTimeStamp = 0;

battleclass.UnitInfoFrameWindow = {};
battleclass.UnitInfoFrameDeadWindow = {};

battleclass.UnitInfoDefaultXPosition = {};
battleclass.moveDistance = nil;
battleclass.moveTickHandle = -1;
battleclass.deadMoveTickHandle = -1;
battleclass.UnitInfoHeaderWindow = nil;
battleclass.uiMoveInfolist = {};
]]
--]==]

battleclass.castMagicTickHandle = -1;
battleclass.calcHpTickHandle = -1;
 

function battleclass:ctor( id )
	 battleclass.super.ctor(self,id)	
	 self:addEvent({ name = global_event.BATTLE_UI_SHOW, eventHandler = self.onshow})
	 self:addEvent({ name = global_event.BATTLE_UI_HIDE, eventHandler = self.onHide})				
	 --self:addEvent({ name = global_event.BATTLE_UI_UPDATE_UNIT_INFO, eventHandler = self.onUpdateUnitInfo})
	 --self:addEvent({ name = global_event.BATTLE_UI_DELETE_DEAD_UNIT, eventHandler = self.onDeleteDeadUnit})
	 --self:addEvent({ name = global_event.BATTLE_UI_SWITCH_TO_SKILL, eventHandler = self.onSkillInfo})
	 --self:addEvent({ name = global_event.BATTLE_UI_SWITCH_TO_UNIT, eventHandler = self.onUnitInfo})
	 
	 self:addEvent({ name = global_event.BATTLE_UI_SWITCH_TO_SKILL, eventHandler = self.onSwitchToCastMagic})
	 self:addEvent({ name = global_event.BATTLE_UI_SWITCH_TO_UNIT, eventHandler = self.onSwitchToUnit})
	 
	 self:addEvent({ name = global_event.BATTLE_UI_FLY_MAGIC_OUT, eventHandler = self.onPlayFlyMagicOut})
	 self:addEvent({ name = global_event.BATTLE_UI_FLY_MAGIC_AWAY, eventHandler = self.onPlayFlyMagicAway})
	 
	 self:addEvent({ name = global_event.BATTLE_UI_UPDATE_UNIT_SEQUNCE, eventHandler = self.updateUnitActionList})
	 
	 -- -- 国王的属性同步，由syncking和指令中的国王属性变化触发，
	 self:addEvent({ name = global_event.BATTLE_KING_ATTR_SYNC, eventHandler = self.onUpdateKingData})
	 -- 指令播放到自己释放魔法的时候触发，更新cd，目前cd是客户端自己计算的
	 self:addEvent({ name = global_event.BATTLE_UI_UPDATE_MAGICCD, eventHandler = self.onUpdateMagic})
	
	self:addEvent({ name = global_event.BATTLE_UI_UPDATE_CASTERMAGIC_COUNTER, eventHandler = self.onUpdateCasterMagicCounter})
	self:addEvent({ name = global_event.BATTLE_UI_KING_CASERTMAGIC, eventHandler = self.onkingCasterMagic})
	
	--self:addEvent({ name = global_event.BATTLE_UI_CHANGE_KING_ICON, eventHandler = self.onChangeKingIcon})
	self:addEvent({ name = global_event.BATTLE_UI_SWITCH_TO_SKILL_ROUND, eventHandler = self.onSkillRound})
 
	self:addEvent({ name = global_event.CLOSE_SKILL_MIND, eventHandler = self.OnskillremindClose})
	self:addEvent({ name = global_event.BATTLE_UI_UPDATE_SKIP, eventHandler = self.OnSkipBattle})
 
 
	self.magicTipHandle = nil
	
end	

 
function battleclass:OnSkipBattle(event)
	
	if not self._show then
		return;
	end
	
	if(battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE)then
		self.battle_skip:SetVisible(true);
		self.battle_skip:SetEnabled(false);
		return
	end
	
	if(battlePlayer.rePlayStatus == true)then
		self.battle_skip:SetVisible(true);
		self.battle_skip:SetEnabled(false);
		return
	end
	if(event)then
		self.battle_skip:SetUserData(1)
	else
		self.battle_skip:SetUserData(0)
	end
end	

function battleclass:onshow(event)
	
	self:Show();	
	
	-- 魔法的飞入飞出加入队列处理
	self.magicFlyCommondList = {};
	self.currentPlaying = false;
	
	if self.magicFlyCommondTimer and self.magicFlyCommondTimer > 0 then
		scheduler.unscheduleGlobal(self.magicFlyCommondTimer);
		self.magicFlyCommondTimer = nil;
	end
	
	function onBattleUIMagicFlyCommond(dt)
		self:handleMagicFly(dt);
	end
	
	self.magicFlyCommondTimer = scheduler.scheduleGlobal(onBattleUIMagicFlyCommond, 0);
	
	function onBattleHideUnitOrder()
		self:showUnitSequnce(false);
	end
	
	function onBatlleShowUnitOrder()
		self:showUnitSequnce(true);
	end
	
	self.battle_juntuanxinxi = self:Child("battle-juntuanxinxi");
	self.battle_skill = self:Child("battle-skill");
	
	self.battle_juntuanxinxi_button1 = self:Child("battle-juntuanxinxi-button1");
	self.battle_juntuanxinxi_button2 = self:Child("battle-juntuanxinxi-button2");
	
	self.battle_juntuanxinxi_button1:subscribeEvent( "WindowTouchUp", "onBattleHideUnitOrder" );
	self.battle_juntuanxinxi_button2:subscribeEvent( "WindowTouchUp", "onBatlleShowUnitOrder" );
	
	self.battle_scroll = LORD.toScrollPane(self:Child("battle-scroll"));
	self.battle_scroll:init();
	--self.battle_corpscontainer = self:Child("battle-corpscontainer");
	
	--self.UnitInfoWindow = self:Child("battle-juntuanxinxi");
	--self.SkillInfoWindow = self:Child("battle-skill");
		
	--self.UnitInfoButton = self:Child("battle-xinxiqiehua");
	--self.SkillInfoButton = self:Child("battle-jinengqiehuan");
	--self.SkipButton = self:Child("battle-skip");
	self.QuitButton = self:Child("battle-out");

	--self.FirstKuang = self:Child("battle-firstkuang");
	self.battle_touxiangzuo_num = self:Child("battle-touxiangzuo-num");
	self.battle_touxiangzuo_num:SetText("")	
	self.battle_touxiangzuo_lan = self:Child("battle-touxiangzuo-lan")
	self.battle_touxiangzuo_lan_text = self:Child("battle-touxiangzuo-lan-text");
	
	
	self.battle_touxiangzuo_hong = self:Child("battle-touxiangzuo-hong")
	self.battle_touxiangyou_hong = self:Child("battle-touxiangyou-hong")
	
	self.battle_touxiangzuo_hong_text = self:Child("battle-touxiangzuo-hong-text")
	self.battle_touxiangyou_hong_text = self:Child("battle-touxiangyou-hongkuang-text")
 
	
	
	self.battle_casterMagic = self:Child("battle-casterMagic");
	self.battle_casterMagicTimer = self:Child("battle-casterMagicTimer");
	
	self.battle_countdown_num = self:Child("battle-countdown-num");
	self.battle_countdown_num:SetText("");
	
	self.battle_casterMagic:SetVisible(false)
	self.battle_touxiangyou_lan = self:Child("battle-touxiangyou-lan")
	self.battle_touxiangyou_lankuang_text = self:Child("battle-touxiangyou-lankuang-text");
	
	self.battle_touxiangyou_num = self:Child("battle-touxiangyou-num");
 	self.battle_touxiangyou_num:SetText("")	
	
	self.battle_skillremind = LORD.toStaticText(self:Child("battle-skillremind"));
	self.battle_skillremind:SetText("")	
	self.battle_help = self:Child("battle-help");
	self.battle_help:SetVisible(not battlePrepareScene.isPvPOnlineBattleType());
 
	
	
	self.battle_autoqu_chose = self:Child("battle-autoqu-chose");
	self.battle_autoqu_chose:SetVisible(sceneManager.battlePlayer():getAutoBattle())
	self.battle_autoqu_chose:SetEnabled(not battlePlayer.rePlayStatus);
	--self.UnitInfoButton:SetEnabled(not battlePlayer.rePlayStatus);
	--self.SkillInfoButton:SetEnabled(not battlePlayer.rePlayStatus);
	
	function onBattleHelp()
		
		
		sceneManager.battlePlayer():pauseGame(true);
		eventManager.dispatchEvent({name = global_event.BATTLEHELP_SHOW});
		
		
	end
	
	self.battle_help:subscribeEvent("ButtonClick", "onBattleHelp");
	
	function onBattleSkip()
		if(dataManager.playerData:getVipLevel() < dataConfig.configs.ConfigConfig[0].skipBattleVip   )then
		
			if(dataConfig.configs.ConfigConfig[0].skipbattlelevel > dataManager.playerData:getLevel() )then
				 eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = dataConfig.configs.ConfigConfig[0].skipbattlelevel.."级以后可以跳过"});
				return
			end	
			if(self.battle_skip:GetUserData( ) == 0 and not global.getBattleTypeInfo(battlePlayer.battleType).canSkipAtBegin )then
				eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "第二轮魔法阶段前不能跳过！"});
				return 
			end
		end	
		sceneManager.battlePlayer():SkipBattle(true);
	end	
	
	self.battle_skip = self:Child("battle-skip");
	self.battle_skip:subscribeEvent("ButtonClick", "onBattleSkip");
	
	self.battle_skip:SetVisible(true);
	self.battle_skip:SetEnabled(battlePlayer.rePlayStatus ~= true and battlePlayer.battleType ~= enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE);
		
	self.battle_touxiangzuo_touxiangkuang =  LORD.toStaticImage(self:Child("battle-touxiangzuo-touxiangkuang"))
	self.battle_touxiangyou_youxiangkuang =  LORD.toStaticImage(self:Child("battle-touxiangyou-youxiangkuang"))	
	
	function onBattleClickEnemyInfo(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window); 
		sceneManager.battlePlayer():pauseGame(true);
		eventManager.dispatchEvent({name = global_event.ENEMYINFORMATION_SHOW, useServerData = true, battleType = battlePrepareScene.battleType, source = "battle",force =  window:GetUserData()});
	end
	
	self.battle_touxiangyou_youxiangkuang:subscribeEvent("WindowTouchUp", "onBattleClickEnemyInfo");
	self.battle_touxiangyou_youxiangkuang:SetUserData(enum.FORCE.FORCE_GUARD)
	self.battle_touxiangzuo_touxiangkuang:subscribeEvent("WindowTouchUp", "onBattleClickEnemyInfo");
	self.battle_touxiangzuo_touxiangkuang:SetUserData(enum.FORCE.FORCE_ATTACK)
	
	self.battle_magic_hint_back = self:Child("battle-magic-hint-back");
	self.battle_magic_hint_text = self:Child("battle-magic-hint-text");
	self.battle_magic_hint_text:SetText("")	
	self:OnSkipBattle()
	self.battle_magic_effect_left = self:Child("battle-magic-effect-left");
	self.battle_magic_effect_right = self:Child("battle-magic-effect-right");
	
	function onClickBattleBug()
		eventManager.dispatchEvent({name = "BUG_SHOW"});
	end
	self.battle_bug = self:Child("battle-bug");
	self.battle_bug:subscribeEvent("ButtonClick", "onClickBattleBug");

 
	local attackKing = dataManager.battleKing[enum.FORCE.FORCE_ATTACK]
	local defenseKing = dataManager.battleKing[enum.FORCE.FORCE_GUARD]
	
	self.battle_touxiangzuo_touxiangkuang:SetImage(global.getHeadIcon( attackKing:getHeadIcon())) 
 
 	-- 用服务器同步下来的数据
 	--[[
	if(battlePrepareScene.isAdventureBattleType())then
		self.battle_touxiangyou_youxiangkuang:SetImage(global.getHeadIcon(dataManager.playerData.stageInfo:getKingIcon()))
	elseif(battlePrepareScene.isPvPOnlineBattleType())then
		self.battle_touxiangyou_youxiangkuang:SetImage(global.getHeadIcon( defenseKing:getHeadIcon())) 
	elseif(battlePrepareScene.isPvPOnlineBattleType())then
		self.battle_touxiangyou_youxiangkuang:SetImage(global.getHeadIcon( defenseKing:getHeadIcon())) 
	end	
	--]]
	
	self.battle_touxiangyou_youxiangkuang:SetImage(global.getHeadIcon( defenseKing:getHeadIcon())) 
 
	self:upDateKingMpProcess()
	
	
		function _setHpProgressAndText(_type, hp, hpmax)
			if not self._show then
				return;
			end
			hp = math.floor(hp);
			hpmax = math.floor(hpmax);
			
			local rate = hp/hpmax*1
			if(rate > 1)then
				rate = 1
			end
			
			local formatText = string.format("%.1f",rate*100).."%"
			if _type == 0 then
				self.battle_touxiangzuo_hong:SetProperty("Progress", rate)
				--self.battle_touxiangzuo_hong_text:SetText(hp.."/"..hpmax);
				
				self.battle_touxiangzuo_hong_text:SetText(  formatText );
				
				if battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE then
					local battle_boxbar	= self:Child("battle-boxbar");
					
					local crusadeExtraCondition = dataConfig.configs.ConfigConfig[0].crusadeExtraCondition;
					
					local extraAwardProgress = (hp - hpmax*crusadeExtraCondition)/(hpmax*(1-crusadeExtraCondition));
					if extraAwardProgress < 0 then
						extraAwardProgress = 0;
					end
					battle_boxbar:SetProperty("Progress", extraAwardProgress);
					
					local battle_box = self:Child("battle-box");
					battle_box:SetVisible(extraAwardProgress > 0);
				else
					local battle_box = self:Child("battle-box");
					battle_box:SetVisible(false);
				end
				
			else
				self.battle_touxiangyou_hong:SetProperty("Progress", rate)
				--self.battle_touxiangyou_hong_text:SetText(hp.."/"..hpmax);
				self.battle_touxiangyou_hong_text:SetText(formatText);
				
			end
		end
		local hpAnimateTime = 0.5;
		self.leftTimeLeftHp  = hpAnimateTime
		self.rightTimeLeftHp  = hpAnimateTime
		
		function _updateHpTick(dt, _type, startMp, endMp, maxMp)			
			if _type == 0 then
				if self.leftTimeLeftHp < 0 then
					_setHpProgressAndText(_type, endMp, maxMp);
					self.leftTimeLeftHp  = hpAnimateTime
					return true;
				else
					local percent = 1 - self.leftTimeLeftHp / hpAnimateTime;
					local mp = startMp + percent * (endMp - startMp);
					_setHpProgressAndText(_type, mp, maxMp);
					self.leftTimeLeftHp = self.leftTimeLeftHp - dt;
				end
				return false;	
			else
			
				if self.rightTimeLeftHp < 0 then
					
					_setHpProgressAndText(_type, endMp, maxMp);
					self.rightTimeLeftHp  = hpAnimateTime
					return true;
				else
					
					local percent = 1 - self.rightTimeLeftHp / hpAnimateTime;
					
					local mp = startMp + percent * (endMp - startMp);
					
					_setHpProgressAndText(_type, mp, maxMp);
					
					self.rightTimeLeftHp = self.rightTimeLeftHp - dt;
				end
				return false;
			end	
		end	
	
	function calcHpTickTick(dt)
			
			local attackhp = 0
			local attackMaxhp = 0
			local hp = 0
			local allhp = 0		
	 
			for _,v in pairs (sceneManager.battlePlayer().m_AllCrops) do
				if(v)then		
					-----最大血量
					if( not v:isSummonUnit())then	--- 初始军团
				
							if(v:isAttacker() == true )then	--- 攻方
								if( v:isCharmed()   ) then   --原来是守方的 现在被魅惑了 
									allhp = allhp +  v:getMaxHP()	
								else
									attackMaxhp = attackMaxhp +  v:getMaxHP()	
								end		
							else
								if( v:isCharmed()) then   --原来是攻方的 现在被魅惑了 
									 attackMaxhp = attackMaxhp +  v:getMaxHP()	
								else
									 allhp = allhp +  v:getMaxHP()
								end
							end	
					end
						-----当前血量
					if(v.m_bAlive) then		
						
							if(v:isAttacker() == true )then	--- 攻方
								 attackhp = attackhp +  v:getTotalHP()
							else
								 hp = hp +  v:getTotalHP()
							end	
					end	
				end					
							
			end			
	
			
		self.leftOldHp =  self.leftOldHp  or  attackhp
		self.rightOldHp =    self.rightOldHp or hp
		self.leftNewHp = attackhp
		self.rightNewHp = hp
		self.leftMaxHp = attackMaxhp
		self.rightMaxHp = allhp
		
		
		if(self.leftOldHp == self.leftNewHp)then
		  _setHpProgressAndText(0, self.leftNewHp, self.leftMaxHp);
		else
			local result = _updateHpTick(dt, 0, self.leftOldHp, self.leftNewHp, self.leftMaxHp);
			if(result )then
				self.leftOldHp =    self.leftNewHp 
			end
				
		end
		
		if(self.rightOldHp == self.rightNewHp)then
		  _setHpProgressAndText(1, self.rightNewHp, self.rightMaxHp);
		else
			local result = _updateHpTick(dt, 1, self.rightOldHp, self.rightNewHp, self.rightMaxHp);
			if(result)then
				self.rightOldHp =    self.rightNewHp
			end

		end
	end	
	 
	battleclass.calcHpTickHandle = scheduler.scheduleGlobal(calcHpTickTick,0);		
 
	--self.UnitInfoWindow:SetVisible(false);
	--self.SkillInfoWindow:SetVisible(false);
	
	--self.SkillInfoButton:SetVisible(true);
	--self.UnitInfoButton:SetVisible(false);
	
	--self.FirstKuang:SetVisible(false);
	--self.SkipButton:SetEnabled(false);
	
	--self.UnitInfoIconWindow = {};
	--self.UnitInfoNameWindow = {};
	--self.UnitInfoNumWindow = {};
	
	--self.UnitInfoDeadIconWindow = {};
	--self.UnitInfoDeadNameWindow = {};
	--self.UnitInfoDeadNumWindow = {};
	
	self.MagicInfoWindow = {
		icon = {},
		name = {},
		num = {},
		xuanzhong = {},
		times = {},
	};
	self.battle_skill_empty = {};
	
	local magicInfo = dataConfig.configs.magicConfig;
	
	
	local king = dataManager.battleKing[battlePlayer.force]
	if(king == nil)then
			king = dataManager.playerData
	end
	
			
	for i=1, 7 do

		local magicItem = self:Child("battle-skillitem"..i);
		if magicItem then
			magicItem:SetVisible(false);
		end

		local neweffectItem = self:Child("battle-skillitemfront"..i.."-effect");
		if neweffectItem then
			neweffectItem:SetVisible(false);
		end
							
		self.MagicInfoWindow.icon[i] = LORD.toStaticImage(self:Child("battle-skillitem"..i.."-item"));
		self.MagicInfoWindow.icon[i]:SetImage("");
		self.MagicInfoWindow.name[i] = self:Child("battle-skillitem"..i.."-name");
		self.MagicInfoWindow.num[i] = self:Child("battle-skillitem"..i.."-num");
		self.MagicInfoWindow.num[i]:SetText("");
		self.MagicInfoWindow.times[i] = self:Child("battle-skillitem"..i.."-time");
		self.MagicInfoWindow.times[i]:SetText("");
		self.MagicInfoWindow.xuanzhong[i] = LORD.toStaticImage(self:Child("battle-skillitem"..i.."-xuanzhong"));
		self.MagicInfoWindow.xuanzhong[i]:SetVisible(false);
		self.battle_skill_empty[i] = self:Child("battle-skill"..i.."-empty");
		self.battle_skill_empty[i]:SetVisible(false);
		
		self.battle_skill_empty[i]:SetProperty("EnableLongTouch", "true");
		self.battle_skill_empty[i]:subscribeEvent("WindowLongTouch", "onShowMagicTips");
		self.battle_skill_empty[i]:subscribeEvent("WindowLongTouchCancel", "onHideMagicTips");
		self.battle_skill_empty[i]:subscribeEvent("MotionRelease", "onHideMagicTips");
		--global.onSkillTipsShow(self.battle_skill_empty[i], "magic", "top");
		--global.onTipsHide(self.battle_skill_empty[i]);		
		
		self.battle_skill_empty[i]:SetUserData(i);
		self.MagicInfoWindow.times[i]:SetText("");
		
		local playerSkill = getEquipedMagicServerData(i);
		if playerSkill and magicInfo[playerSkill.id] then
			self.MagicInfoWindow.name[i]:SetText(magicInfo[playerSkill.id].name);
			self.MagicInfoWindow.icon[i]:SetImage(magicInfo[playerSkill.id].icon);
			
			if magicInfo[playerSkill.id].castTimes < 0 then
				--self.MagicInfoWindow.times[i]:SetText("∞");
			else
				--self.MagicInfoWindow.times[i]:SetText("X"..magicInfo[playerSkill.id].castTimes);
			end
			
			local cost = dataManager.kingMagic:getMagic(playerSkill.id ):getMpCost( king:getCasterMPRate())
			self.MagicInfoWindow.num[i]:SetText( cost );
			
			self.MagicInfoWindow.icon[i]:SetProperty("EnableLongTouch", "true");
			
			self.MagicInfoWindow.icon[i]:subscribeEvent("WindowTouchUp", "onClickSkill");
			self.MagicInfoWindow.icon[i]:subscribeEvent("MotionRelease", "onReleaseClickSkill");
			self.MagicInfoWindow.icon[i]:subscribeEvent("WindowLongTouch", "onShowMagicTips");
			self.MagicInfoWindow.icon[i]:subscribeEvent("WindowLongTouchCancel", "onHideMagicTips");
			self.MagicInfoWindow.icon[i]:SetUserData(i);
			self.MagicInfoWindow.icon[i]:SetVisible(true);
		else
			self.MagicInfoWindow.icon[i]:SetVisible(false);
			self.MagicInfoWindow.name[i]:SetText("");
		end

	end
		
  function  onClickKuaijin()
  	 
	 
		local t = SPEED_UP_GAME
		
		local speed = sceneManager.battlePlayer():getSpeed()
 
		local index = table.keyOfItem(t,speed)	
		if(index == nil )then
			index  = 1
		end


		-- 等级限制
		if dataManager.playerData:getLevel() < dataConfig.configs.ConfigConfig[0].speedLevel2LevelLimit then
			
			local t = dataConfig.configs.ConfigConfig[0].speedLevel2LevelLimit.."级解锁2倍加速"; --"^FF0000"..
			eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip =t});			
			return;
		
		elseif dataManager.playerData:getLevel() < dataConfig.configs.ConfigConfig[0].speedLevel3LevelLimit then
			
			index = index + 1;
			if index == 3 then
				index = 1;
				
				local t =  dataConfig.configs.ConfigConfig[0].speedLevel3LevelLimit.."级解锁3倍加速";
				eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip =t});			
			end
		
		else
			index = index + 1;
			if index == 4 then
				index = 1;
			end
		end
		
		sceneManager.battlePlayer():speedGame( t[index])
		
		self:updateSpeedNum()
		
  end
 
 	function onClickPause()
 		sceneManager.battlePlayer():pauseGame( not sceneManager.battlePlayer():isPause())
 	end
 	

	function onClickAuto(args)
		local clickImage =  LORD.toCheckBox(LORD.toWindowEventArgs(args).window)

		print("sceneManager.battlePlayer():getAutoBattle()")
		print(sceneManager.battlePlayer():getAutoBattle())
 		
 		local checkState = clickImage:GetChecked();
 		
 		print("------checkState "..tostring(checkState));
 		
 		-- 等级限制
		if dataManager.playerData:getLevel() < dataConfig.configs.ConfigConfig[0].autobattleLevelLimit then
			
			local t = dataConfig.configs.ConfigConfig[0].autobattleLevelLimit.."级解锁自动施法";
			eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip =t});			
			
			checkState = false;
			self.battle_autoweixuanzhong:SetChecked(checkState);
			return
		end
 		
 		print("checkState "..tostring(checkState));
 		
 		self.battle_autoweixuanzhong:SetChecked(checkState);
 				
		sceneManager.battlePlayer():setAutoBattle( checkState );
		local auto = sceneManager.battlePlayer():getAutoBattle()
		self.battle_autoqu_chose:SetVisible(auto)
		
		
		if(auto)then
			eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "开启自动施法"});
		else
			eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "关闭自动施法"});
		end
		
		
		
 	end
	
	 
	self.battle_autoweixuanzhong =  LORD.toCheckBox(self:Child("battle-autoweixuanzhong"))
	self.battle_autoweixuanzhong:subscribeEvent("CheckStateChanged", "onClickAuto");
	self.battle_autoweixuanzhong:SetChecked(sceneManager.battlePlayer():getAutoBattle())
	self.battle_autoweixuanzhong:SetEnabled(not battlePlayer.rePlayStatus);
	
 	function onClickQuit()
			
			if(battlePlayer.rePlayStatus  == true)then
				eventManager.dispatchEvent({name = global_event.GUIDE_ON_BATTLE_RECORD_REPLAY_QUITE})
				sceneManager.battlePlayer():CancelBattle();
				return
			end
			eventManager.dispatchEvent({name = global_event.OUTCONFIRM_SHOW})	
 	end
 	
 	function onShowMagicTips(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData();
		local magicID = getEquipedMagicServerData(userdata).id;
		--local magicInstance = dataManager.kingMagic:getMagic(magicID);
		
 		local rect = clickImage:GetUnclippedOuterRect();
 		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "magic", id = magicID, windowRect = rect, dir = "top", magicLevel = getEquipedMagicServerData(userdata).level, intelligence = dataManager.battleKing[battlePlayer.force]:getIntelligence() });
 	end
 	
 	function onHideMagicTips(args)
 		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
 	end

 	
 	function onClickSkill(args)
 		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData();
		
		eventManager.dispatchEvent({name = global_event.CLOSE_SKILL_MIND})
		
		if( sceneManager.battlePlayer().selecMagic  and sceneManager.battlePlayer().selecMagic == userdata )then
			sceneManager.battlePlayer().selecMagic = nil
			castMagic.cleanSign()
			for i=1, 7 do
				self.MagicInfoWindow.xuanzhong[i]:SetVisible(false);
			end
			return 
		end
		sceneManager.battlePlayer().selecMagic = userdata
		
		local magicID = getEquipedMagicServerData(userdata).id;
 		for i=1, 7 do
 			if i == userdata then
 				self.MagicInfoWindow.xuanzhong[i]:SetVisible(true);
 			else
 				self.MagicInfoWindow.xuanzhong[i]:SetVisible(false);
 			end
 		end
		castMagic.signSkillGrid(magicID)
    
    -- 原来的up事件合成一个
		if(nil ==  sceneManager.battlePlayer().selecMagic)then
				return 
		end
		eventManager.dispatchEvent( {name = global_event.GUIDE_ON_BATTLE_CLICK_MAGIC_BAR ,arg1 = userdata } )	
	

		castMagic.SelectMagic(userdata);
		
    --由longtouch触发
 		--local rect = clickImage:GetUnclippedOuterRect();
 		--eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "magic", id = magicID, windowRect = rect, dir = "top"});
 		
 	end
 	
 	function onReleaseClickSkill(args)
		
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});

		if(nil ==  sceneManager.battlePlayer().selecMagic)then
			return 
		end

		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData();
 		--castMagic.SelectMagic(userdata);
 		
 	end
 	
 	function onClickUnit(args)
		
		if(sceneManager.battlePlayer():isEndBattle()) then
			return 
		end
 		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData();
 		
 		local unitData = sceneManager.battlePlayer().m_AllCrops[userdata];
 		
 		if unitData then
 		
 			sceneManager.battlePlayer():pauseGame(true);
 			
 			-- 战斗中通过点击头像查看军团信息
			local shipAttr = {};
			shipAttr.attack = unitData:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK);
			shipAttr.defence = unitData:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE);
			shipAttr.critical = unitData:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL);
			shipAttr.resilience = unitData:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE);
			
			local unitAttr = {};
			unitAttr.soldierDamage = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_DAMAGE);
			unitAttr.defence = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_DEFENCE);
			unitAttr.soldierHP = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP);
			unitAttr.actionSpeed = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SPEED);
			unitAttr.moveRange = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_MOVE_RANGE);
		 	unitAttr.attackRange = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_ATTACK_RANGE);
		 												
 			eventManager.dispatchEvent({name = "CORPSDETAIL_SHOW", unitID = unitData:getUnitID(), 
														 			curUnitNum = unitData.m_CropsNum, totalUnitNum = unitData.m_TotalCropsNum, 
														 			buffList = unitData:getBuffList(), force = unitData:getForces(), shipAttr = shipAttr, unitAttr = unitAttr,
														 			hp = unitData:getTotalHP(), maxHp = unitData:getMaxHP()});
 		end
 		
 	end
	
	function onClickAutoBattle()				
			sceneManager.battlePlayer().AutoKingMagic = not sceneManager.battlePlayer().AutoKingMagic
	end
 	
 	function onClickDebugBattle()
 		eventManager.dispatchEvent({name = "BATTLE_DEBUG_SHOW"});
 	end
 	
	self:Child("battle-stop"):subscribeEvent("ButtonClick", "onClickPause")
	
	self.battle_kuaijin = self:Child("battle-kuaijin");
	self.battle_kuaijin:subscribeEvent("ButtonClick", "onClickKuaijin");	
	
	self.battle_kuaijin:SetVisible(global.getBattleTypeInfo(battlePrepareScene.getBattleType()).speedUp )		  
	
	
 	--self.UnitInfoButton:subscribeEvent("ButtonClick", "onUnitInfo");	
 	--self.SkillInfoButton:subscribeEvent("ButtonClick", "onSkillInfo");
	--self.SkipButton:subscribeEvent("ButtonClick", "onClickSkip");
	self.QuitButton:subscribeEvent("ButtonClick", "onClickQuit");
	self:Child("battle-tiaoshi"):subscribeEvent("ButtonClick", "onClickDebugBattle");
	
	--self:Child("battle-battle-autoweixuanzhong"):subscribeEvent("ButtonClick", "onClickAutoBattle")
	
	self:updateSpeedNum()
	
	-- 国王的属性同步，由syncking和指令中的国王属性变化触发，
	-- 更新头像和技能栏的信息
	self:onUpdateKingData();	

	-- 根据配置文件显示是否显示序列面板	
	self:showUnitSequnceByConfig();

	-- 初始化双方的名字和等级相关的信息
	self:initNameAndLevelInfo();
		
end

function battleclass:updateSpeedNum()
	
	local speed = sceneManager.battlePlayer():getSpeed()

	local t = SPEED_UP_GAME
		
	local index = table.keyOfItem(t,speed)	or  1
  
	--self:Child("battle-kuaijin-num"):SetText("X"..index)
	if index == 1 then
		self.battle_kuaijin:SetProperty("NormalImage", "set:battle.xml image:speed");
		self.battle_kuaijin:SetProperty("PushedImage", "set:battle.xml image:speed");
	elseif index == 2 then
		self.battle_kuaijin:SetProperty("NormalImage", "set:battle.xml image:speed2");
		self.battle_kuaijin:SetProperty("PushedImage", "set:battle.xml image:speed2");
	elseif index == 3 then
		self.battle_kuaijin:SetProperty("NormalImage", "set:battle.xml image:spdde3");
		self.battle_kuaijin:SetProperty("PushedImage", "set:battle.xml image:spdde3");		
	end
end

function battleclass:onHide(args)
	-- release all handle
	--[==[
	[[
	if battleclass.moveTickHandle ~= -1 then
		scheduler.unscheduleGlobal(battleclass.moveTickHandle);
		battleclass.moveTickHandle = -1
	end
	
	if battleclass.deadMoveTickHandle ~= -1 then
		scheduler.unscheduleGlobal(battleclass.deadMoveTickHandle);
		battleclass.deadMoveTickHandle = -1
	end
	]]
	--]==]	

	-- 魔法的飞入飞出加入队列处理	
	if self.magicFlyCommondTimer and self.magicFlyCommondTimer > 0 then
		scheduler.unscheduleGlobal(self.magicFlyCommondTimer);
		self.magicFlyCommondTimer = nil;
	end
	
	self.magicFlyCommondList = {};
	self.currentPlaying = false;
	
	if battleclass.castMagicTickHandle ~= -1 then
		scheduler.unscheduleGlobal(battleclass.castMagicTickHandle);
		battleclass.castMagicTickHandle = -1
	end
	
	if battleclass.calcHpTickHandle ~= -1 then
		scheduler.unscheduleGlobal(battleclass.calcHpTickHandle);
		battleclass.calcHpTickHandle = -1
	end
  
	if(self.magicTipHandle ~= nil)then
		scheduler.unscheduleGlobal(self.magicTipHandle)
		self.magicTipHandle = nil
	end		
	
	if self.rightMPTick then		
		scheduler.unscheduleGlobal(self.rightMPTick);
		self.rightMPTick = nil;
	end
	
	if self.leftMPTick then		
		scheduler.unscheduleGlobal(self.leftMPTick);
		self.leftMPTick = nil;
	end
	self:Close();
end
function battleclass:OnskillremindClose(event)
	if not self._show then
		return;
	end
	if(self.battle_skillremind)then
		self.battle_skillremind:SetText("")
	end
end	

function battleclass:onSkillRound(event)
	----绿oofeoo
	----红d95b5b
	if not self._show then
		return;
	end
	local text = ""
	if(event.self == true )then
		text = "请选择魔法释放"
		self.battle_skillremind:SetTextColor(LORD.Color(0,0.996,0,1) )
	 else
	
		self.battle_skillremind:SetTextColor(LORD.Color(0.85098,0.356863,0.356863,1) )
		text = "等待敌人释放魔法"
	end
	
	if(event.show == false )then
		 text = ""
	end
 
	self.battle_skillremind:SetText(text)	
	
	
	
	
end

function battleclass:updateMagicInfo()
	
	if not self._show then
		return;
	end

	local king = dataManager.battleKing[battlePlayer.force]

	if(king)then
			local mp =  king:getMp()
			local magicInfo = dataConfig.configs.magicConfig;
			for i=1, 7 do								
				local playerSkill = getEquipedMagicServerData(i)			
				if playerSkill and magicInfo[playerSkill.id] then
						local cost = dataManager.kingMagic:getMagic(playerSkill.id ):getMpCost( king:getCasterMPRate())
						--if(mp >= cost  and cd <= 0)then
						local level = dataManager.kingMagic:getMagic(playerSkill.id ):getStar()
						if(castMagic.checkSkillCanCaste(playerSkill.id,level))then		
							self.MagicInfoWindow.icon[i]:SetEnabled(true);
							self.battle_skill_empty[i]:SetVisible(false);
						else
							self.MagicInfoWindow.icon[i]:SetEnabled(false)
							self.battle_skill_empty[i]:SetVisible(true);
						end
						
						local cd = dataManager.kingMagic:getMagic(playerSkill.id):getCurCD()			
						local NUM = dataManager.kingMagic:getMagic(playerSkill.id):getCurNumStr()
						self.MagicInfoWindow.name[i]:SetText(magicInfo[playerSkill.id].name)
		  			
		  			if cd == 0 then
		  				self.MagicInfoWindow.times[i]:SetText("");
		  			else
		  				self.MagicInfoWindow.times[i]:SetText(cd);
		  			end
  												
						self.MagicInfoWindow.xuanzhong[i]:SetVisible(false);
						self.MagicInfoWindow.num[i]:SetText(cost);		
				end	
			end
	
	end
		
	self.battle_casterMagic:SetVisible(sceneManager.battlePlayer().wait_action == true 
																		and global.getBattleTypeInfo(battlePrepareScene.getBattleType()).countdown == true)	
			
end

function battleclass:triggerCountDownCasteMagic()
	
	if not self._show then
		return;
	end
	
	if(battleclass.castMagicTickHandle ~= -1 )then
		scheduler.unscheduleGlobal(battleclass.castMagicTickHandle);
		battleclass.castMagicTickHandle = -1
		self.battle_casterMagic:SetVisible(false)
	end

	if(sceneManager.battlePlayer().wait_action == true) then		
		local num = math.floor((battleKingSkillAi.wait_time)*0.001)
		self.battle_casterMagicTimer:SetText(tostring(num))	
	end
	
	function castMagicTick(dt)		
		 
		local num = math.floor((battleKingSkillAi.wait_time)*0.001)
		if(sceneManager.battlePlayer().wait_action == false) then		
			self.battle_casterMagicTimer:SetText("0")	
			scheduler.unscheduleGlobal(battleclass.castMagicTickHandle);
			battleclass.castMagicTickHandle = -1			
			self.battle_casterMagic:SetVisible(false)
		end			
		if(num < 0)then
			num = 0
		end
		self.battle_casterMagicTimer:SetText(tostring(num))		
	end	
	
	if(global.getBattleTypeInfo(battlePrepareScene.getBattleType()).countdown == true ) then
		battleclass.castMagicTickHandle = scheduler.scheduleGlobal(castMagicTick,0.5);	
	end
		
end

--[==[
[[
function battleclass:onSkillInfo(event)
 
	if battleclass.moveTickHandle ~= -1 then
		self.delayShowSkillInfo = true;
		return;
	end
					
	function onBattleSkillUIActionEnd()
		self.UnitInfoWindow:SetVisible(false);
		self.SkillInfoWindow:SetVisible(true);
	end
	
	if (event and event.notFlip) then
		self.UnitInfoWindow:SetVisible(false);
		self.SkillInfoWindow:SetVisible(true);	
	else
		self.UnitInfoWindow:SetVisible(true);
		self.SkillInfoWindow:SetVisible(true);
		uiaction.flipTwoWindowX(self.UnitInfoWindow, self.SkillInfoWindow, 65, 500);	
	end
	
 	--self.SkillInfoButton:SetVisible(false);
	--self.UnitInfoButton:SetVisible(true);	

	
	-- 如果event不为空，就是自动切换过来的
	if event then
		self:updateUnitActionList();
	end	
	
	local king = dataManager.battleKing[battlePlayer.force]
	
	if(king)then
			local mp =  king:getMp()
			local magicInfo = dataConfig.configs.magicConfig;
			for i=1, 7 do								
				local playerSkill = getEquipedMagicServerData(i)			
				if playerSkill and magicInfo[playerSkill.id] then
						local cost = dataManager.kingMagic:getMagic(playerSkill.id ):getMpCost( king:getCasterMPRate())
						--if(mp >= cost  and cd <= 0)then
						local level = dataManager.kingMagic:getMagic(playerSkill.id ):getStar()
						if(castMagic.checkSkillCanCaste(playerSkill.id,level))then		
							self.MagicInfoWindow.icon[i]:SetEnabled(true);
							self.battle_skill_empty[i]:SetVisible(false);
						else
							self.MagicInfoWindow.icon[i]:SetEnabled(false)
							self.battle_skill_empty[i]:SetVisible(true);
						end			
						self.MagicInfoWindow.xuanzhong[i]:SetVisible(false);
						self.MagicInfoWindow.num[i]:SetText(cost);		
				end	
			end
	
	end
	
	if(battleclass.castMagicTickHandle ~= -1 )then
		scheduler.unscheduleGlobal(battleclass.castMagicTickHandle);
		battleclass.castMagicTickHandle = -1
	end
	
	self.battle_casterMagic:SetVisible(global.getBattleTypeInfo(battlePrepareScene.getBattleType()).countdown == true)	
	
	if(sceneManager.battlePlayer().wait_action == true) then		
		local num = math.floor((battleKingSkillAi.wait_time)*0.001)
		self.battle_casterMagicTimer:SetText(tostring(num))	
	end
	function castMagicTick(dt)		
		 
		local num = math.floor((battleKingSkillAi.wait_time)*0.001)
		if(sceneManager.battlePlayer().wait_action == false) then		
			self.battle_casterMagicTimer:SetText("0")	
			scheduler.unscheduleGlobal(battleclass.castMagicTickHandle);
			battleclass.castMagicTickHandle = -1			
			self.battle_casterMagic:SetVisible(false)
		end			
		if(num < 0)then
			num = 0
		end
		self.battle_casterMagicTimer:SetText(tostring(num))		
	end	
	if(global.getBattleTypeInfo(battlePrepareScene.getBattleType()).countdown == true ) then
		battleclass.castMagicTickHandle = scheduler.scheduleGlobal(castMagicTick,0.5);	
	end
end

function battleclass:onUnitInfo(event)
 
	
	
	self.UnitInfoWindow:SetVisible(true);
	self.SkillInfoWindow:SetVisible(true);
	
	function onBattleUnitUIActionEnd()
		self.UnitInfoWindow:SetVisible(true);
		self.SkillInfoWindow:SetVisible(false);		
	end


	if (event and event.notFlip) then
		self.UnitInfoWindow:SetVisible(true);
		self.SkillInfoWindow:SetVisible(false);	
	else
		self.UnitInfoWindow:SetVisible(true);
		self.SkillInfoWindow:SetVisible(true);
		uiaction.flipTwoWindowX(self.SkillInfoWindow, self.UnitInfoWindow, 65, 500);	
	end


	
	
	self.SkillInfoButton:SetVisible(true);
	self.UnitInfoButton:SetVisible(false);
	
	if event then
	
		-- 表示是服务器通知的切换，不是用户点击的，这时应该是已经释放魔法完了
		
		
		self.battle_scroll:SetVisible(false);
		self.battle_corpscontainer:SetVisible(true);
	
		self.battle_scroll:ClearAllItem();

		self.SkillInfoButton:SetVisible(false);
		self.UnitInfoButton:SetVisible(false);
			
	end
	
end
 	
battleclass.MOVE_TOTAL_TIME = 0.5;

function battleclass.setUnitInfo(frameWindow, iconWindow, unitData)
		
	if unitData.index < 0 then
		-- 国王
		if unitData.isFriendlyForce then
			frameWindow:SetImage(enum.SELFBACK);
			iconWindow:SetImage(enum.ATTACK_KING_ICON);
		else
			frameWindow:SetImage(enum.ENEMYBACK);
			iconWindow:SetImage(enum.GUARD_KING_ICON);
		end
		
		frameWindow:SetVisible(true);
		iconWindow:SetUserData(unitData.index);
	else
		-- 军团
		local unit = sceneManager.battlePlayer().m_AllCrops[unitData.index];
		if unit then
			if unit:isFriendlyForces() then
				frameWindow:SetImage(enum.SELFBACK);
			else
				frameWindow:SetImage(enum.ENEMYBACK);
			end
			frameWindow:SetVisible(true);
			--nameWindow:SetText(unit.m_name);
			--numWindow:SetText(unit.m_CropsNum);
			iconWindow:SetImage(unit.m_Icon);
			iconWindow:SetUserData(unit.index);
		end
	end
end
]]
--]==]

--[==[
[[
battleclass.DEAD_TOTAL_TIME = 0.5;

function battleclassDeadMoveTick(dt)
		
	local percent = nil;
	if battleclass.deadTimeStamp > battleclass.DEAD_TOTAL_TIME then
		percent = 1;
		battleclass.deadTimeStamp = 0;
		scheduler.unscheduleGlobal(battleclass.deadMoveTickHandle);
		battleclass.deadMoveTickHandle = -1;
		sceneManager.battlePlayer().m_UiOrderTranslationed = true;
		
	else
		percent = battleclass.deadTimeStamp / battleclass.DEAD_TOTAL_TIME;
		battleclass.deadTimeStamp = battleclass.deadTimeStamp + dt;
	end

	local unitsinfo = sceneManager.battlePlayer().m_ActionOrder;
	
	for i,v in ipairs(unitsinfo) do
		if i > 7 then
		 break;
		end
		if battleclass.uiMoveInfolist[i] and battleclass.uiMoveInfolist[i].moveBlockNum ~= 0 then			
			local xpos = battleclass.UnitInfoDefaultXPosition[i];
			local blockNum = battleclass.uiMoveInfolist[i].moveBlockNum;
			xpos = xpos + LORD.UDim((1-percent)*blockNum, (1-percent)*blockNum) * battleclass.moveDistance;
			battleclass.UnitInfoFrameWindow[i]:SetXPosition(xpos);
		
		end
		
		if battleclass.uiMoveInfolist[i] and battleclass.uiMoveInfolist[i].isDead then
			battleclass.UnitInfoFrameDeadWindow[i]:SetAlpha(1 - percent);
		end
		
	end
	
end

function battleclass:onDeleteDeadUnit()
	if not self._loaded then
		return;
	end

	if battleclass.deadMoveTickHandle ~= -1 then
		return;
	end
	
	local deadIndex = sceneManager.battlePlayer().m_DeadUnitsIndex;
	local unitsinfo = sceneManager.battlePlayer().m_ActionOrder;
	local oldUnitsinfo = sceneManager.battlePlayer().m_LastActionOrder;
	
	battleclass.uiMoveInfolist = {};
	local moveCount = 0;
	
	for i,v in ipairs(oldUnitsinfo) do
		if i > 7 then
		 break;
		end
		
		battleclass.uiMoveInfolist[i] = {};
		if v.index == deadIndex then
			moveCount = moveCount + 1;
			--local unit = sceneManager.battlePlayer().m_AllCrops[v.index];
			battleclass.setUnitInfo(battleclass.UnitInfoFrameDeadWindow[i], self.UnitInfoDeadIconWindow[i], v);
			battleclass.uiMoveInfolist[i].isDead = true;
		else
			battleclass.uiMoveInfolist[i].isDead = false;
		end
		battleclass.uiMoveInfolist[i].moveBlockNum = moveCount;
		
	end
	
	for i,v in ipairs(unitsinfo) do
		if i > 7 then
		 break;
		end	
		--local unit = sceneManager.battlePlayer().m_AllCrops[v.index];
		battleclass.setUnitInfo(battleclass.UnitInfoFrameWindow[i], self.UnitInfoIconWindow[i], v);
	
		if battleclass.uiMoveInfolist[i] and battleclass.uiMoveInfolist[i].moveBlockNum ~= 0 then
			local xpos = battleclass.UnitInfoDefaultXPosition[i];
			xpos = xpos + battleclass.moveDistance * LORD.UDim(battleclass.uiMoveInfolist[i].moveBlockNum, battleclass.uiMoveInfolist[i].moveBlockNum);
			battleclass.UnitInfoFrameWindow[i]:SetXPosition(xpos);
		end
		
		if battleclass.uiMoveInfolist[i] and battleclass.uiMoveInfolist[i].isDead then
			battleclass.UnitInfoFrameDeadWindow[i]:SetAlpha(1);
			battleclass.UnitInfoFrameDeadWindow[i]:SetVisible(true);
		else
			battleclass.UnitInfoFrameDeadWindow[i]:SetVisible(false);
		end
		
	end
	
	sceneManager.battlePlayer().m_UiOrderTranslationed = false;
	battleclass.deadTimeStamp = 0;
	if battleclass.deadMoveTickHandle ~= -1 then
		print("battleclass.deadMoveTickHandle error, last handle has not been handled!here comes the new one!");
	end
	battleclass.deadMoveTickHandle = scheduler.scheduleUpdateGlobal(battleclassDeadMoveTick);
end
]]
--]==]

function battleclass:onUpdateCasterMagicCounter(event)
	if self._show == false then
		return
	end
	local num = sceneManager.battlePlayer().magicCasterRoundNum	
	if(sceneManager.battlePlayer().turn_self_caster_magic)then		
			self.battle_touxiangzuo_num:SetText(num.." -先手-" )
			self.battle_touxiangyou_num:SetText(num.." -后手-" )				
	else					
			self.battle_touxiangzuo_num:SetText(num.." -后手-")
			self.battle_touxiangyou_num:SetText(num.." -先手-")					
	end
	
	if num <= 0 or event.clear == true then
		self.battle_countdown_num:SetText("");
	else
		self.battle_countdown_num:SetText(num);
	end										
end	

--[==[
[[
function battleclass:onUpdateUnitInfo()
	if not self._loaded then
		return;
	end
	
	if battleclass.moveTickHandle ~= -1 then 
		return;
	end
	
	self.FirstKuang:SetVisible(true);
	
	local unitsinfo = sceneManager.battlePlayer().m_ActionOrder;
	
	for i,v in ipairs(unitsinfo) do
		if i > 7 then
		 break;
		end
		--local unit = sceneManager.battlePlayer().m_AllCrops[v.index];
		battleclass.setUnitInfo(battleclass.UnitInfoFrameWindow[i], self.UnitInfoIconWindow[i], v);
		
		local xpos = battleclass.UnitInfoDefaultXPosition[i];
		xpos = xpos + battleclass.moveDistance;
		battleclass.UnitInfoFrameWindow[i]:SetXPosition(xpos);	
	end
	
	if sceneManager.battlePlayer().m_RoundNum ~= 0 then
		battleclass.UnitInfoHeaderWindow:SetAlpha(1);
	end
	
	battleclass.timeStamp = 0;
	
	if battleclass.moveTickHandle ~= -1 then 
		print("battleclass.moveTickHandle error, last handle has not been handled!here comes the new one!");
	end
	
	-- 处理函数
	function battleclassmoveTick(dt)
		
		if(sceneManager.battlePlayer().m_ActionOrder == nil or  table.nums(sceneManager.battlePlayer().m_ActionOrder) == 0 )then
			return 
		end
		
		local percent = nil;
		if battleclass.timeStamp > battleclass.MOVE_TOTAL_TIME then
			percent = 1;
			battleclass.timeStamp = 0;
			scheduler.unscheduleGlobal(battleclass.moveTickHandle);
			battleclass.moveTickHandle = -1;
			sceneManager.battlePlayer().m_UiOrderTranslationed = true;
			
			local frameWindow = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("battle-juntuan1_header"));
			--local nameWindow = LORD.GUIWindowManager:Instance():GetGUIWindow("battle-juntuan1name_header");
			--local numWindow = LORD.GUIWindowManager:Instance():GetGUIWindow("battle-juntuan1num_header");
			local iconWindow = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("battle-bingtuan1touxiang_header"));
			--local unit = sceneManager.battlePlayer().m_AllCrops[sceneManager.battlePlayer().m_ActionOrder[1].index];
			--if unit then
			battleclass.setUnitInfo(frameWindow, iconWindow, sceneManager.battlePlayer().m_ActionOrder[1]);
			--end
			
			if self.delayShowSkillInfo == true then
				self:onSkillInfo();
				self.delayShowSkillInfo = false;
			end
		else
			percent = battleclass.timeStamp / battleclass.MOVE_TOTAL_TIME;
			battleclass.timeStamp = battleclass.timeStamp + dt;

		end
		
		for i=1,7 do
			local xpos = battleclass.UnitInfoDefaultXPosition[i];
			xpos = xpos + LORD.UDim((1-percent), (1-percent)) * battleclass.moveDistance;
			battleclass.UnitInfoFrameWindow[i]:SetXPosition(xpos);
		end
		
		if sceneManager.battlePlayer().m_RoundNum ~= 0 then
			battleclass.UnitInfoHeaderWindow:SetAlpha(1-percent);
		end
		
	end
	
	battleclass.moveTickHandle = scheduler.scheduleUpdateGlobal(battleclassmoveTick);
	
	
end
]]
--]==]
 

	function battleclass:onUpdateKingData(event)
		
		if(self._show ~= true)then
			return 
		end			
 		
 		-- 更新头像上的魔法值
 		self:upDateKingMpProcess(event)		
		
		-- 更新技能栏上的信息
		self:updateMagicInfo();
						
 	end		
  
	function battleclass:upDateKingMpProcess(event)	
		
		
		local mpAnimateTime = 0.5;
		
		function _updateMpTick(dt, _type, startMp, endMp, maxMp)
			
			--print("_updateMpTick timeLeft "..timeLeft.." _type ".._type.." startMp "..startMp.." endMp "..endMp.." maxMp "..maxMp );
			
			if _type == 0 then
			
				if self.leftTimeLeft < 0 then
					
					_setMpProgressAndText(_type, endMp, maxMp);
					
					return true;
				else
					
					local percent = 1 - self.leftTimeLeft / mpAnimateTime;
					
					local mp = startMp + percent * (endMp - startMp);
					
					_setMpProgressAndText(_type, mp, maxMp);
					
					self.leftTimeLeft = self.leftTimeLeft - dt;
				end
				
				return false;
					
			else
			
				if self.rightTimeLeft < 0 then
					
					_setMpProgressAndText(_type, endMp, maxMp);
					
					return true;
				else
					
					local percent = 1 - self.rightTimeLeft / mpAnimateTime;
					
					local mp = startMp + percent * (endMp - startMp);
					
					_setMpProgressAndText(_type, mp, maxMp);
					
					self.rightTimeLeft = self.rightTimeLeft - dt;
				end
				
				return false;
						
			end
			
		end

		-- 魔法动画效果
		function _mpleftAnimateTick(dt)

			local result = _updateMpTick(dt, 0, self.leftOldMp, self.leftNewMp, self.leftMax);
			
			if result then
				
				scheduler.unscheduleGlobal(self.leftMPTick);
				self.leftMPTick = nil;
				
				self.battle_touxiangzuo_lan:SetProperty("ProgressImage", "set:battle.xml image:magicbar");
				
			end
		end

		function _mprightAnimateTick(dt)

			local result = _updateMpTick(dt, 1, self.rightOldMp, self.rightNewMp, self.rightMax);
			

			if result then
				
				scheduler.unscheduleGlobal(self.rightMPTick);
				self.rightMPTick = nil;
				self.battle_touxiangyou_lan:SetProperty("ProgressImage", "set:battle.xml image:magicbar");
			end
						
		end
				
		function _setMpProgressAndText(_type, mp, mpmax)
			
			if not self._show then
				return;
			end
			
			mp = math.floor(mp);
			mpmax = math.floor(mpmax);
			
			if _type == 0 then

				--left
				self.battle_touxiangzuo_lan:SetProperty("Progress", mp/mpmax)
				self.battle_touxiangzuo_lan_text:SetText(mp.."/"..mpmax);
								
			else
				-- right
				
				self.battle_touxiangyou_lan:SetProperty("Progress", mp/mpmax)
				self.battle_touxiangyou_lankuang_text:SetText(mp.."/"..mpmax);
				
			end
		end
		
		--self.leftOldMp = 0;
		--self.leftNewMp = 0;
		--self.leftMax = 0;
		
		--self.rightOldMp = 0;
		--self.rightNewMp = 0;
		--self.rightMax = 0;	
		
		local updateLeft = false;
		local updateRight = false;
		
		if event == nil then
			local king = dataManager.battleKing[enum.FORCE.FORCE_ATTACK];	
			self.leftOldMp = king:getOldMp();
			self.leftNewMp = king:getMp();
			self.leftMax = king:getMpMax();
			
			king = dataManager.battleKing[enum.FORCE.FORCE_GUARD]
			self.rightOldMp = king:getOldMp();
			self.rightNewMp = king:getMp()	
		  self.rightMax  = king:getMpMax()	
		  
		  updateLeft = true;
		  updateRight = true;
		  
		else
			
			local king = dataManager.battleKing[event.force]
			if enum.FORCE.FORCE_ATTACK == event.force then
				self.leftOldMp = king:getOldMp();
				self.leftNewMp = king:getMp();
				self.leftMax = king:getMpMax();
				updateLeft = true;
			else
				self.rightOldMp = king:getOldMp();
				self.rightNewMp = king:getMp()	
		  	self.rightMax  = king:getMpMax()
		  	updateRight = true;				
			end
		end
		
		if updateLeft then
			
			if self.leftMPTick then
				scheduler.unscheduleGlobal(self.leftMPTick);
				self.leftMPTick = nil;
				
				_setMpProgressAndText(0, self.leftOldMp, self.leftMax);

			end
			
			self.leftTimeLeft = mpAnimateTime;
						
			self.leftMPTick = scheduler.scheduleGlobal(_mpleftAnimateTick, 0);
			
			self.battle_touxiangzuo_lan:SetProperty("ProgressImage", "set:battle.xml image:magicbar1");
			self.battle_magic_effect_left:SetEffectName("uitexiao_falitiao.effect");
		end
		

		if updateRight then
			
			if self.rightMPTick then
				scheduler.unscheduleGlobal(self.rightMPTick);
				self.rightMPTick = nil;
				
				_setMpProgressAndText(1, self.rightOldMp, self.rightMax);

			end
			
			self.rightTimeLeft = mpAnimateTime;
						
			self.rightMPTick = scheduler.scheduleGlobal(_mprightAnimateTick, 0);
			
			self.battle_touxiangyou_lan:SetProperty("ProgressImage", "set:battle.xml image:magicbar1");
			self.battle_magic_effect_right:SetEffectName("uitexiao_refalitiao.effect");
		end
		
	end
	
function battleclass:onUpdateMagic()	
	if not self._show then
		return;
	end
	self:updateMagicInfo();	 
end
	
function battleclass:onkingCasterMagic(event)	
		if(self._show ~= true)then
			return 
		end	
		local magicInfo = dataConfig.configs.magicConfig[event.magicId]		--event.self == true
		if(magicInfo)then
			self.battle_magic_hint_text:SetText(magicInfo.name)	
			self.battle_magic_hint_back:SetVisible(true);
			self.battle_magic_hint_back:SetAlpha(1)	
			
			if(self.magicTipHandle ~= nil)then
				scheduler.unscheduleGlobal(self.magicTipHandle)
				self.magicTipHandle = nil
			end	
			self.magicTipHandleTime = 0
			function battleclass_magicTipHandle(dt)
					self.magicTipHandleTime = self.magicTipHandleTime + dt
					if(self.magicTipHandleTime > 4 )then	
						self.battle_magic_hint_back:SetVisible(false);
						self.battle_magic_hint_text:SetText("")	
						if(self.magicTipHandle ~= nil)then
							scheduler.unscheduleGlobal(self.magicTipHandle)
							self.magicTipHandle = nil
						end	
					elseif(self.magicTipHandleTime >= 1 )then	
						self.battle_magic_hint_back:SetAlpha(1 -(self.magicTipHandleTime- 1) / 3 )	
					end			
			end	
			if(self.magicTipHandle == nil)then
					self.magicTipHandle = scheduler.scheduleGlobal(battleclass_magicTipHandle,0)--global.goldMineInterval
			end	
		end
		
		
end

--[==[
[[
function battleclass:onChangeKingIcon(event)
	
	if battleclass.UnitInfoFrameWindow[1] and self.UnitInfoIconWindow[1] then
		
		local unitData = sceneManager.battlePlayer().m_ActionOrder[1];
		local isFriendlyForce = not unitData.isFriendlyForce;
		local index = -1;
		
		if unitData.index == -1 then
			index = -2;	
		else
			index = -1;
		end

		local frameWindow = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("battle-juntuan1_header"));
		--local nameWindow = LORD.GUIWindowManager:Instance():GetGUIWindow("battle-juntuan1name_header");
		--local numWindow = LORD.GUIWindowManager:Instance():GetGUIWindow("battle-juntuan1num_header");
		local iconWindow = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("battle-bingtuan1touxiang_header"));
					
		-- 国王
		if isFriendlyForce then
			battleclass.UnitInfoFrameWindow[1]:SetImage(enum.SELFBACK);
			frameWindow:SetImage(enum.SELFBACK);
			iconWindow:SetImage(enum.GUARD_KING_ICON);
			
			self.UnitInfoIconWindow[1]:SetImage(enum.ATTACK_KING_ICON);
			iconWindow:SetImage(enum.ATTACK_KING_ICON);
						
		else
			battleclass.UnitInfoFrameWindow[1]:SetImage(enum.ENEMYBACK);
			frameWindow:SetImage(enum.ENEMYBACK);
			self.UnitInfoIconWindow[1]:SetImage(enum.GUARD_KING_ICON);
			iconWindow:SetImage(enum.GUARD_KING_ICON);
		end
		
		battleclass.UnitInfoFrameWindow[1]:SetVisible(true);
		self.UnitInfoIconWindow[1]:SetUserData(index);

		
	end
			
end
]]
--]==]

function battleclass:updateUnitActionList()
	
	if not self._show then
		return;
	end
	
	--print("updateUnitActionList");
	
	self.battle_scroll:SetVisible(true);
	--self.battle_corpscontainer:SetVisible(false);
	
	self.battle_scroll:ClearAllItem();

	local xpos = LORD.UDim(0,0);
	local ypos = LORD.UDim(0,2);
	
	for i=1, 14 do
	
		local orderData = sceneManager.battlePlayer().m_ActionOrder[i];
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
				local unit = sceneManager.battlePlayer().m_AllCrops[orderData.index];
												
				if unit then
			
					if unit:isFriendlyForces() then
						battlecropsitem_corps:SetImage(enum.SELFBACK);
					else
						battlecropsitem_corps:SetImage(enum.ENEMYBACK);
					end
					battlecropsitem_corps:SetVisible(true);
					battlecropsitem_item:SetImage(unit.m_Icon);
					battlecropsitem_item:SetUserData(unit.index);
				end
				
			end			
			
			local width = unitWindow:GetWidth();
			unitWindow:SetXPosition(xpos);
			unitWindow:SetYPosition(ypos);
			
			xpos = xpos + width - LORD.UDim(0, -1);
			self.battle_scroll:additem(unitWindow);
		end
	end
	
		
end

function battleclass:triggerMagicFlyOut()
	
	if not self._show then
		return;
	end
	
	LORD.SoundSystem:Instance():playEffect("mofachuxianle.mp3");
	
	self.currentPlaying = true;
	
	function battlePlayEffectAfterFlyOut(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local name = window:GetName();
		
		local effectItem = self:Child("battle-skillitem"..string.sub(name, string.len(name), string.len(name)).."-effect");
		if effectItem then
			effectItem:SetEffectName("mofachuxian.effect");
		end
		
		local index = string.sub(name, string.len(name), string.len(name));
		print("battlePlayEffectAfterFlyOut "..index)
		local playerSkill = getEquipedMagicServerData(tonumber(index));
		if playerSkill and dataConfig.configs.magicConfig[playerSkill.id] then
		
			local neweffectItem = self:Child("battle-skillitemfront"..index.."-effect");
			if neweffectItem then
				neweffectItem:SetVisible(true);
			end
				
		end
				
	end
	
	function battleDelayFlyMagicItem(i)
		
		local magicItem = self:Child("battle-skillitem"..i);
		
		if magicItem then
			
			magicItem:SetVisible(true);
			
			local rect = magicItem:GetUnclippedOuterRect();
			local action = LORD.GUIAction:new();
			action:addKeyFrame(LORD.Vector3(0, rect.top , 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 350);
			
			magicItem:removeEvent("UIActionEnd");
			magicItem:subscribeEvent("UIActionEnd", "battlePlayEffectAfterFlyOut");
			magicItem:playAction(action);
		
		end
		
		if i == 7 then
			self.currentPlaying = false;
			--print("triggerMagicFlyOut end");
		end
			
	end
	
	for i=1, 7 do
		
		local magicItem = self:Child("battle-skillitem"..i);
		if magicItem then
			magicItem:SetVisible(false);
		end
		
		local effectItem = self:Child("battle-skillitem"..i.."-effect");
		if effectItem then
			effectItem:SetEffectName("");
		end
		
		scheduler.performWithDelayGlobal(battleDelayFlyMagicItem, (i-1)*0.3, i);
		
	end
	
end

function battleclass:triggerMagicFlyAway()

	if not self._show then
		return;
	end
	
	LORD.SoundSystem:Instance():playEffect("mofaxiaoshile.mp3");
	
	self.currentPlaying = true;

	for i=1, 7 do
		
		local magicItem = self:Child("battle-skillitem"..i);
		
		local neweffectItem = self:Child("battle-skillitemfront"..i.."-effect");
		if neweffectItem then
			neweffectItem:SetVisible(false);
		end
		
		if magicItem then
			magicItem:SetVisible(true);
			
			local rect = magicItem:GetUnclippedOuterRect();
			local action = LORD.GUIAction:new();
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
			action:addKeyFrame(LORD.Vector3(0, rect.top, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 1500);
			
			magicItem:removeEvent("UIActionEnd");
			magicItem:playAction(action);
						
		end
		
	end
	
	function battleDelayHideMagicAfterCast()
		
		for i=1, 7 do
			
			local magicItem = self:Child("battle-skillitem"..i);
			if magicItem then
				magicItem:SetVisible(false);
			end
			
		end
		
		self.currentPlaying = false;
		--print("triggerMagicFlyAway end");
		
	end
	
	local magicItem = self:Child("battle-skillitem7");
	if magicItem then
		magicItem:subscribeEvent("UIActionEnd", "battleDelayHideMagicAfterCast");
	end
	
end

function battleclass:onSwitchToCastMagic()
	
	if not self._show then
		return;
	end
	
	self:updateUnitActionList();
	
	print("onSwitchToCastMagic");
	-- 更新技能栏上的信息
	self:updateMagicInfo();
	
	self:triggerCountDownCasteMagic();
	
	self.battle_skill:SetVisible(true);
		
	local battle_unitsequnce = self:Child("battle-unitsequnce");
	battle_unitsequnce:SetVisible(true);
		
end


function battleclass:onSwitchToUnit()
	
	if not self._show then
		return;
	end
	
	print("onSwitchToUnit");
		
	local battle_unitsequnce = self:Child("battle-unitsequnce");
	battle_unitsequnce:SetVisible(false);
			
end

function battleclass:showUnitSequnceByConfig()
	
	local sequnceShow = fio.readIni("battle", "unitSequnce", "false", global.getUserConfigFileName());
	
	print("sequnceShow  "..sequnceShow);
	
	self.battle_juntuanxinxi:SetVisible(stringToBool(sequnceShow));
	self.battle_juntuanxinxi_button2:SetVisible(not stringToBool(sequnceShow));
		
end

function battleclass:showUnitSequnce(flag)

	if not self._show then
		return;
	end
	
	print("showUnitSequnce  "..tostring(flag));
	
	fio.writeIni("battle", "unitSequnce",  tostring(flag), global.getUserConfigFileName());
	
	if flag then
		-- 拉出序列
		local pixelsize = self.battle_juntuanxinxi:GetPixelSize();
		self.battle_juntuanxinxi:SetVisible(true);
		
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, -pixelsize.y, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
		
		self.battle_juntuanxinxi:removeEvent("UIActionEnd");
		self.battle_juntuanxinxi:playAction(action);
		
		self.battle_juntuanxinxi_button1:SetVisible(true);
		self.battle_juntuanxinxi_button2:SetVisible(false);
		
	else
		-- 收起序列
		
		function onBattleHideUnitEnd()
			if self._show then
				self.battle_juntuanxinxi:SetVisible(false);
				self.battle_juntuanxinxi_button1:SetVisible(false);
				self.battle_juntuanxinxi_button2:SetVisible(true);
			end
		end
		
		local pixelsize = self.battle_juntuanxinxi:GetPixelSize();
		
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(0, -pixelsize.y, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
		self.battle_juntuanxinxi:removeEvent("UIActionEnd");
		self.battle_juntuanxinxi:subscribeEvent("UIActionEnd", "onBattleHideUnitEnd");
		self.battle_juntuanxinxi:playAction(action);
		
	end
	
end

-- 加入一个队列里
function battleclass:handleMagicFly(dt)
	
	if not self.currentPlaying and #self.magicFlyCommondList > 0 then
		
		-- 取一条新的指令
		local commond = self.magicFlyCommondList[1];
		table.remove(self.magicFlyCommondList, 1);
		
		if commond == "flyout" then
			--print("triggerMagicFlyOut");
			self:triggerMagicFlyOut();
		else
			--print("triggerMagicFlyAway");
			self:triggerMagicFlyAway();
		end
			
	end
	
end

function battleclass:onPlayFlyMagicOut()

	if not self._show then
		return;
	end
	
	-- 技能飞出效果
	table.insert(self.magicFlyCommondList, "flyout");
	
end

function battleclass:onPlayFlyMagicAway()

	if not self._show then
		return;
	end
	
	table.insert(self.magicFlyCommondList, "flyaway");
	
end


function battleclass:initNameAndLevelInfo()
	
	if not self._show then
		return;
	end
	
	-- 
	local levelLeft = self:Child("battle-touxiangzuo-text-lv-num");
	local levelRight = self:Child("battle-touxiangyou-text-lv-num");
	
	local nameLeft = self:Child("battle-touxiangzuo-name");
	local nameRight = self:Child("battle-touxiangyou-name");
	local battle_touxiangyou_name_containers =  LORD.toStaticImage(self:Child("battle-touxiangyou-name-containers"));

	
	local selfIconLeft = self:Child("battle-touxiangzuo-isme");
	local selfIconRight = self:Child("battle-touxiangyou-isme");
	local battle_touxiangyou_name_containers = LORD.toStaticImage(self:Child("battle-touxiangyou-name-containers"));
    local battle_touxiangyou_name_containers2 = LORD.toStaticImage(self:Child("battle-touxiangyou-name-containers2"));
	
	local attackKing = dataManager.battleKing[enum.FORCE.FORCE_ATTACK]
	local defenseKing = dataManager.battleKing[enum.FORCE.FORCE_GUARD]
	
	levelLeft:SetText(attackKing:getLevel());
	levelRight:SetText(defenseKing:getLevel());
	
	local leftNameString = attackKing:getName();
	local rightNameString = defenseKing:getName();
		
	if leftNameString == "" then
		leftNameString = enum.DEFAULT_PLAYER_NAME;
	end

	if rightNameString == "" then
		rightNameString = enum.DEFAULT_PLAYER_NAME;
	end
		
	nameLeft:SetText(leftNameString);
	nameRight:SetText(rightNameString);
	
	-- pve 右边的名字不显示
	nameRight:SetVisible(battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE or battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE );
	battle_touxiangyou_name_containers:SetVisible(battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE or battlePlayer.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE );
	battle_touxiangyou_name_containers2:SetVisible(battlePlayer.battleType ~= enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE or battlePlayer.battleType ~= enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE);


	
	print("defenseKing:getName()  "..defenseKing:getName());
	
	selfIconLeft:SetVisible(battlePlayer.force == enum.FORCE.FORCE_ATTACK);
	selfIconRight:SetVisible(battlePlayer.force == enum.FORCE.FORCE_GUARD);
			
end

return battleclass