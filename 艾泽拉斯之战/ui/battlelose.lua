local battlelose = class( "battlelose", layout );

global_event.BATTLELOSE_SHOW = "BATTLELOSE_SHOW";
global_event.BATTLELOSE_HIDE = "BATTLELOSE_HIDE";

function battlelose:ctor( id )
	battlelose.super.ctor( self, id );
	self:addEvent({ name = global_event.BATTLELOSE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BATTLELOSE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.RECEIVE_BEST_BATTLE_RECORD, eventHandler = self.onReceiveRecord});
	 
end

function battlelose:onReceiveRecord(event)
	if not self._show then
		return;
	end
	global.GlobalReplaySummaryInfo.name = global.GlobalReplaySummaryInfo.name or ""
	self.battlelose_rec_name:SetText(global.GlobalReplaySummaryInfo.name)
	if(global.GlobalReplaySummaryInfo.name == "")then
		self.battlelose_rec_back:SetVisible(false);
		self.battlelose_bestrec:SetVisible(false);
	else
		local  isShowBestRepaly = global.isShowBestRepaly(battlePlayer.battleType)
		self.battlelose_rec_back:SetVisible(isShowBestRepaly);
		self.battlelose_bestrec:SetVisible(isShowBestRepaly);
	end 
end	

function battlelose:onShow(event)

	local actorManager = LORD.ActorManager:Instance();
	actorManager:SetSpeedUp(1);
	
	if self._show then
		return;
	end
	
	dataManager.playerData:checkLevelup();
	
	eventManager.dispatchEvent( {name = global_event.ENEMYINFORMATION_HIDE})
	eventManager.dispatchEvent( {name = global_event.CORPSDETAIL_HIDE})
	eventManager.dispatchEvent( {name = global_event.BATTLEHELP_HIDE})
		
	self:Show();
	self.stage = event.stage
	self.battleType = battlePlayer.battleType 
	self.battlelose_luxiang = self:Child( "battlelose-luxiang" );
	self.battlelose_again = self:Child( "battlelose-again" );
	self.battlelose_close = self:Child( "battlelose-close" );
	self.battlelose_crpse = self:Child( "battlelose-crpse" );
	self.battlelose_magic = self:Child( "battlelose-magic" );
	self.battlelose_levelup = self:Child( "battlelose-levelup" );
	self.battlelose_strengthen = self:Child( "battlelose-strengthen" );
	self.battlelose_exp_num = self:Child( "battlelose-exp-num" );
	self.battlelose_exp = self:Child("battlelose-exp");
	self.battlelose_bestrec = self:Child("battlelose-bestrec");
	self.battlelose_rec_name = self:Child("battlelose-rec-name");
	self.battlelose_rec_name:SetText("")
 
	self.battlelose_rec_back = self:Child("battlelose-rec-back");
	function battlelose_onclickAskBestBattleRecord()
		global.askGlobalReplay(battlePlayer.battleType,battlePrepareScene.ReplaySummaryIndex) 
		sceneManager.battlePlayer():onQuitBattle(true);
		self:onHide(true);
	end
	
	self.battlelose_bestrec:subscribeEvent("ButtonClick", "battlelose_onclickAskBestBattleRecord");
	
	local  isShowBestRepaly = global.isShowBestRepaly(battlePlayer.battleType)
	self.battlelose_rec_back:SetVisible(isShowBestRepaly);
	self.battlelose_bestrec:SetVisible(isShowBestRepaly);
	if(isShowBestRepaly)then
		global.askGlobalReplaySummary(battlePlayer.battleType,battlePrepareScene.ReplaySummaryIndex) 
	end
  
	self.battlelose_levelup:SetEnabled(dataManager.playerData:getAdventureNormalProcess()>=dataConfig.configs.ConfigConfig[0].shipProcessLimit);
	self.battlelose_crpse:SetEnabled(dataManager.playerData:getAdventureNormalProcess()>=dataConfig.configs.ConfigConfig[0].drawCardProcessLimit);
	self.battlelose_magic:SetEnabled(dataManager.playerData:getLevel()>=dataConfig.configs.ConfigConfig[0].magicTowerLevelLimit);
	self.battlelose_strengthen:SetEnabled(dataManager.playerData:getLevel()>=dataConfig.configs.ConfigConfig[0].smithyLevelLimit);
	
	function battlelose_onclickReplay()
 
		sceneManager.battlePlayer():loadAndRePlayBattleRecord()
		self:onHide(true);
	end
	
	self.battlelose_luxiang:subscribeEvent("ButtonClick", "battlelose_onclickReplay");
	
	function battlelose_onclickagain()
		local again = false 
		
		if self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
		   self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then
			again = true

			if(dataManager.playerData:getVitality() < self.stage:getVigourCost() )then
				eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.VIGOR,-1,-1});
				return
			end
						
			sceneManager.battlePlayer():onQuitBattle(true);
			instanceinfor_clickStageStat(true)
			
		elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
				self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
				self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then	-- 副本挑战
			
			sceneManager.battlePlayer():onQuitBattle(true);
			
			onClickActivityCopyStart();
		end

		self:onHide(true);
	end
	self.battlelose_again:subscribeEvent("ButtonClick", "battlelose_onclickagain");
	
	
	
	function battlelose_onclickout()
		self:onHide();
	end
	self.battlelose_close:subscribeEvent("ButtonClick", "battlelose_onclickout");
	
	self.battlelose_again:SetVisible(false)
	
	local exp = 0;
	
	if self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
	   self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then
	 
		self.battlelose_again:SetVisible( battlePlayer.rePlayStatus == false );
		
		-- 设置经验
		local sexp,fexp = 0,0
		
		if(self.stage)then
			sexp,fexp = self.stage:getExp();
		end
		
		if battlePlayer.win then
			exp = sexp;
		else
			exp = fexp;
		end
		
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_EVENT then	-- 每日活动
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE then	-- 在线PVP
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE then	-- 离线PVP
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT then	-- 领地事件
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED then	-- 急速挑战
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
				self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
				self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then	-- 副本挑战
			self.battlelose_again:SetVisible(true);
			--新手引导
			eventManager.dispatchEvent({name = global_event.GUIDE_ON_CHALLENGE_STAGE_LOSE, arg1= battlePrepareScene.copyID})
	elseif self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE then	-- 伤害输出挑战
	end
	--self.battlelose_exp_num:SetText(exp)
 	
 	--self.battlelose_exp:SetVisible(exp > 0);
 	
	function battlelose_onclickCrpse()
		
		global.changeGameState(function()
		
			self:onHide(true);
			sceneManager.battlePlayer():onQuitBattle();
			game.EnterProcess( game.GAME_STATE_MAIN);
			
			function onbattlelose_onclickCrpse()
				homeland.corpsHandle() 
			end
			scheduler.performWithDelayGlobal( onbattlelose_onclickCrpse , 1)
	 	end)
	 	
	end
	self.battlelose_crpse:subscribeEvent("ButtonClick", "battlelose_onclickCrpse");
	function battlelose_onclickMagic()

		global.changeGameState(function()		 
			 self:onHide(true);
			 sceneManager.battlePlayer():onQuitBattle();
			 game.EnterProcess( game.GAME_STATE_MAIN);
			
			function onbattlelose_onclickMagic()
				homeland.magicTowerHandle() 
			end
			scheduler.performWithDelayGlobal( onbattlelose_onclickMagic , 1)
		end)
	
	end
	self.battlelose_magic:subscribeEvent("ButtonClick", "battlelose_onclickMagic");
	function battlelose_onclicklevelup()
		 
		 global.changeGameState(function() 
			 self:onHide(true);
			 sceneManager.battlePlayer():onQuitBattle();
			 game.EnterProcess( game.GAME_STATE_MAIN);
			
			function onbattlelose_onclicklevelup()
				onClickMainUnit();
			end
			 
			 scheduler.performWithDelayGlobal( onbattlelose_onclicklevelup , 1)		 
		 end);
	end
	self.battlelose_levelup:subscribeEvent("ButtonClick", "battlelose_onclicklevelup");
	
	function battlelose_onclickstrengthen()
		 global.changeGameState(function()
		 
			 self:onHide(true);
			 sceneManager.battlePlayer():onQuitBattle();
			 game.EnterProcess( game.GAME_STATE_MAIN);
			
				
			function onbattlelose_onclickstrengthen()
				onClickMainUnit(); 
			end
			scheduler.performWithDelayGlobal( onbattlelose_onclickstrengthen , 1)
	 	end)
	end
	self.battlelose_strengthen:subscribeEvent("ButtonClick", "battlelose_onclickstrengthen");
	
--
	local sound = "battle_lose.mp3"
	if self.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE then	-- 伤害输出挑战
			sound = "battle_win.mp3"
	end
	local  audioEngine = LORD.SoundSystem:Instance()
	audioEngine:playBackgroundMusic(sound, false)
	
end

function battlelose:onHide(notquit)
	self:Close();
	
	if notquit ~= true then
		sceneManager.battlePlayer():QuitBattle();
	end
end

return battlelose;
