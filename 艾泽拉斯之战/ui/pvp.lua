local pvp = class( "pvp", layout );

global_event.PVP_SHOW = "PVP_SHOW";
global_event.PVP_HIDE = "PVP_HIDE";
global_event.PVP_UPDATE= "PVP_UPDATE";

function pvp:ctor( id )
	pvp.super.ctor( self, id );
	self:addEvent({ name = global_event.PVP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.PVP_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.PVP_UPDATE, eventHandler = self.onUpdate});
	self:addEvent({ name = global_event.LORGIN_SUCCESS, eventHandler = self.onUpdate});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_BATTLE, eventHandler = self.onHide});
	self.cdProduceHandle = nil
end

function pvp:onShow(event)
	if self._show then
		return;
	end
	if(event.refresh)then
		dataManager.pvpData:refreshNewPlayer()
	end
	
	self:Show();

	self.pvp_close = self:Child( "pvp-close" );
	self.pvp_area1_rank_num = self:Child( "pvp-area1-rank-num" );
	self.pvp_area1_rule = self:Child( "pvp-area1-rule" );
	self.pvp_area1_ranking = self:Child( "pvp-area1-ranking" );
	self.pvp_area1_notes = self:Child( "pvp-area1-notes" );
	self.pvp_area1_shop = self:Child( "pvp-area1-shop" );
	self.pvp_area2_button = self:Child( "pvp-area2-button" );
	self.pvp_area2_power_num = self:Child( "pvp-area2-power-num" );
	self.pvp_area3_power_num = self:Child( "pvp-area3-attpower-num" );
	self.pvp_rank_1st = self:Child("pvp-rank-1st");
	self.pvp_rank_2nd = self:Child("pvp-rank-2nd");
	self.pvp_rank_3rd = self:Child("pvp-rank-3rd");
 
	self.pvp_crops_self = {}	

	for i = 1,6 do
		self.pvp_crops_self[i] = {}
		self.pvp_crops_self[i].root = LORD.toStaticImage(self:Child( "pvp-crops"..i ));		
		self.pvp_crops_self[i].head  = LORD.toStaticImage(self:Child( "pvp-crops"..i.."-head" ));
		self.pvp_crops_self[i].star  = self:Child( "pvp-crops"..i.."-star" );		
		self.pvp_crops_self[i].starall ={}	
		for k = 1,6 do
			self.pvp_crops_self[i].starall[k] = LORD.toStaticImage(self:Child( "pvp-crops"..i.."-star"..k ))		
		end
		
		self.pvp_crops_self[i].equity  = LORD.toStaticImage(self:Child( "pvp-crops"..i.."-equity" ));
				
	end	
	
	self.pvp_off_enemy ={}
 
	
	
	function onClickBattlePlayerPvPoffline(args)	
		
			if(dataManager.pvpData:CheckResetOfflineBattleNum())then
				return 
			end
			
			if(dataManager.pvpData:CheckandCleanCdOffline())then
				return 
			end

		    local clickImage = LORD.toWindowEventArgs(args).window		
			local userdata = clickImage:GetUserData()		
			dataManager.pvpData:setSelectPlayer(userdata)		
			--[[local player = dataManager.pvpData:getPlayer(userdata)				
			sendPvpCandidateRank(player.posIndex)--]]
			
		    uiaction.scale(clickImage, 0.8);
			scheduler.performWithDelayGlobal(function()
			local player = dataManager.pvpData:getPlayer(userdata)				
			sendPvpCandidateRank(player.posIndex)
		    end, 0.2)
		 	
		 	 -- 挑战玩家
			--eventManager.dispatchEvent( {name   = global_event.PVP_HIDE})
 	  		-- local player = dataManager.pvpData:getPlayer(userdata)			
			
			
	end	
	local head = LORD.toStaticImage(self:Child( "pvp-area2-player-head"));
	local head_back = LORD.toStaticImage(self:Child( "pvp-area2-player"));
	if(head_back)then
		head_back:SetImage(dataManager.miracleData:getHeadFrame(dataManager.miracleData:getLevel()))
	end
	local name = (self:Child( "pvp-area2-player-name"));
	if(head and name) then
		head:SetImage(global.getHeadIcon(dataManager.playerData:getHeadIcon()))
		name:SetText(dataManager.playerData:getName())	
	end
	for i = 1, 5 do	
		self.pvp_off_enemy[i] = {}
		self.pvp_off_enemy[i].root =  LORD.toStaticImage(self:Child( "pvp-area3-enemy"..i ));
		self.pvp_off_enemy[i].headroot =   LORD.toStaticImage(self:Child( "pvp-area3-enemy"..i.."-head" ));
		self.pvp_off_enemy[i].head =   LORD.toStaticImage(self:Child( "pvp-area3-enemy"..i.."-head-image" ));
		self.pvp_off_enemy[i].name =   LORD.toStaticImage(self:Child( "pvp-area3-enemy"..i.."-head-name" ));
 
		self.pvp_off_enemy[i].lv  = self:Child( "pvp-area3-enemy"..i.."-lv-num" );
		self.pvp_off_enemy[i].ranking  = self:Child( "pvp-area3-enemy"..i.."-ranking-num" );
		self.pvp_off_enemy[i].power  = self:Child( "pvp-area3-enemy"..i.."-power-num" );
		self.pvp_off_enemy[i].button  = self:Child( "pvp-area3-enemy"..i.."-button" );	
		--[[self.pvp_off_enemy[i].button:subscribeEvent("ButtonClick", "onClickBattlePlayerPvPoffline")--]]
		self.pvp_off_enemy[i].root:subscribeEvent("WindowTouchUp", "onClickBattlePlayerPvPoffline");
	end
  
	self.pvp_area3_time_num = self:Child( "pvp-area3-time-num" );
	self.pvp_area3_time_cooling = self:Child( "pvp-area3-time-cooling" );
	self.pvp_area3_func_change = self:Child( "pvp-area3-func-change" );
	self.pvp_area3_func_buytime = self:Child( "pvp-area3-func-buytime" );
	self.pvp_area3_func_buycooling = self:Child( "pvp-area3-func-buycooling" );
	self.pvp_pvp_area3_func_money_num = self:Child( "pvp-pvp-area3-func-money-num" );
	self.pvp_area3_func_money = self:Child( "pvp-area3-func-money" );
	
	self.pvp_area3_time_reset = self:Child( "pvp-area3-time-reset" );
	
	
	function onClickClosePvPoffline()	
		self:onHide()
		--eventManager.dispatchEvent({name = global_event.ARENA_SHOW});
		homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.ARENA);		
	end			
	self.pvp_close:subscribeEvent("ButtonClick", "onClickClosePvPoffline")
	
	
	function onClickRulePvPoffline()
		--- 规则
		eventManager.dispatchEvent({name = global_event.PVPRULE_SHOW});	
	end
	
	self.pvp_area1_rule:subscribeEvent("ButtonClick", "onClickRulePvPoffline")
	
	
	
	function onClickRankPvPoffline()
		--- 排行榜
		eventManager.dispatchEvent({name = global_event.RANKINGLIST_SHOW});		
	end
	
	self.pvp_area1_ranking:subscribeEvent("ButtonClick", "onClickRankPvPoffline")
	
	function onClickNotesPvPoffline()
		---对战记录
		eventManager.dispatchEvent({name = global_event.PVPRECORD_SHOW});		
 
	end 
	self.pvp_area1_notes:subscribeEvent("ButtonClick", "onClickNotesPvPoffline")
	
	function onClickShopPvPoffline()
		---商店
		global.openShop(enum.SHOP_TYPE.SHOP_TYPE_HONOR)
	end 
	self.pvp_area1_shop:subscribeEvent("ButtonClick", "onClickShopPvPoffline")
	
	function onClickPreParePvPoffline()
		---	调整阵型	
		self:onHide()
		
		global.changeGameState(function() 
			sceneManager.closeScene();
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			local btype = enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE		
			game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = btype, planType = enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD }); 		
		end);		
	end 
	
	self.pvp_area2_button:subscribeEvent("ButtonClick", "onClickPreParePvPoffline")
	
	function onClickChangePvPoffline()
		--换对手
		dataManager.pvpData:refreshNewPlayer(true)
	end	
	self.pvp_area3_func_change:subscribeEvent("ButtonClick", "onClickChangePvPoffline")
	function onClickResetNumPvPoffline()
		--重置次数
		dataManager.pvpData:CheckResetOfflineBattleNum()
	end	
	
	self.pvp_area3_func_buytime:subscribeEvent("ButtonClick", "onClickResetNumPvPoffline")
	
	function onClickCleanCdPvPoffline()
		--清cd
		dataManager.pvpData:CheckandCleanCdOffline()
	end			
	self.pvp_area3_func_buycooling:subscribeEvent("ButtonClick", "onClickCleanCdPvPoffline")
	
	
	
	
	self:update()	
end

		

function pvp:update()
	local nowRanking,_nowRanking = dataManager.pvpData:getOfflineRanking()
	self.pvp_area1_rank_num:SetText(nowRanking)
	self.pvp_rank_1st:SetVisible(nowRanking == 1)
	self.pvp_rank_2nd:SetVisible(nowRanking == 2)
	self.pvp_rank_3rd:SetVisible(nowRanking == 3)
			if nowRanking == 1 or nowRanking==2 or nowRanking==3 then
				self.pvp_area1_rank_num:SetVisible(false);
			else 
			    self.pvp_area1_rank_num:SetVisible(true);
			end
	self.pvp_area2_power_num:SetText(dataManager.pvpData:getOfflineBatlePower())
	
	self.pvp_area3_power_num:SetText(dataManager.pvpData:getOfflineAttackBatlePower())	

	local  BatleNum = dataManager.pvpData:getOfflineBatleNum()
	local  MaxBatleNum = dataManager.pvpData:getOfflineBatleMaxNum()
	 
	local canBattleNum = MaxBatleNum - BatleNum
	if canBattleNum <= 0 then
		self.pvp_area3_time_num:SetText( "^FF0000"..(canBattleNum).."^FFFFFF/"..MaxBatleNum) 
	else
		self.pvp_area3_time_num:SetText(canBattleNum.."/"..MaxBatleNum) 
	end	
	
	self.pvp_area3_time_reset:SetText(dataManager.pvpData:getNextPvpOfflineRefleshTime())	
	
	
	local cd = dataManager.pvpData:getOfflineCd() 
	if(cd > 0 )then
		self.pvp_area3_time_cooling:SetText( formatTime(cd, true))
		self.pvp_area3_time_cooling:SetVisible(true) 	
	else
		self.pvp_area3_time_cooling:SetVisible(false) 		
	end
	print("cd                              "..cd)
	
	self.pvp_pvp_area3_func_money_num:SetText("0") 
	self.pvp_area3_func_money:SetVisible(false) 		
	
	for i = 1,6 do
		
		local  info = dataManager.pvpData:getOfflineSelfCrops(i)
		
		if(info)then
				self.pvp_crops_self[i].head:SetImage(info.icon)
				self.pvp_crops_self[i].star:SetVisible(true) 				
				for k = 1,6 do
					self.pvp_crops_self[i].starall[k]:SetVisible( k <= info.starLevel ) 	
				end
				
				self.pvp_crops_self[i].equity:SetImage(itemManager.getImageWithStar(info.starLevel));
									
		else		
			self.pvp_crops_self[i].head:SetImage("")
			self.pvp_crops_self[i].equity:SetImage("")
			self.pvp_crops_self[i].star:SetVisible(false) 			
		end			
	end	
	
 
		for i = 1, 5 do	
			self.pvp_off_enemy[i].root:SetVisible(true) 	
		end		
		local player = {}
		for i = 1, 5 do	
			player = dataManager.pvpData:getPlayer(i)
			self.pvp_off_enemy[i].root:SetVisible( nil ~= player) 		
			if(player)then
					self.pvp_off_enemy[i].head:SetImage(global.getHeadIcon( player:getHeadId() ) )
					self.pvp_off_enemy[i].lv:SetText(player.kingInfo.level)
					self.pvp_off_enemy[i].ranking:SetText(player.ranking)
					self.pvp_off_enemy[i].power:SetText(player:playerPower())  
					self.pvp_off_enemy[i].root:SetUserData(i)
					self.pvp_off_enemy[i].name:SetText(player:getName())
			end					
		end				
 
	
	self.pvp_area3_func_change:SetVisible(true)  
	self.pvp_area3_func_buycooling:SetVisible(false)  
	self.pvp_area3_func_buytime:SetVisible(false) 
	self.pvp_pvp_area3_func_money_num:SetText("0")
	self.pvp_area3_func_money:SetVisible(false) 	
	local cd,cost = dataManager.pvpData:getOfflineCd()
	if(cd > 0)then
		self.pvp_area3_func_buycooling:SetVisible(true) 
		self.pvp_area3_func_change:SetVisible(false)  
		self.pvp_area3_func_buytime:SetVisible(false) 	
		
		self.pvp_pvp_area3_func_money_num:SetText(cost) 
		self.pvp_area3_func_money:SetVisible(cost > 0 ) 	
	end
	if(BatleNum >= MaxBatleNum)then
		self.pvp_area3_func_buycooling:SetVisible(false) 
		self.pvp_area3_func_change:SetVisible(false)  
		self.pvp_area3_func_buytime:SetVisible(true) 	
		self.pvp_pvp_area3_func_money_num:SetText(dataConfig.configs.ConfigConfig[0].pvpOfflineResetTimes ) 
		self.pvp_area3_func_money:SetVisible(dataConfig.configs.ConfigConfig[0].pvpOfflineResetTimes  > 0 ) 	
	end
	
	function pvpOfflineCdTimeTick()
		
		local cd,cost = dataManager.pvpData:getOfflineCd()
		self.pvp_area3_time_cooling:SetText( formatTime(cd, true))
		 
		if(cd <= 0 and self.cdProduceHandle ~= nil)then
			self.pvp_area3_time_cooling:SetVisible(false) 	
			scheduler.unscheduleGlobal(self.cdProduceHandle)
			self.cdProduceHandle = nil
			self:update()
			return
		end
		self.pvp_pvp_area3_func_money_num:SetText(cost)	
		self.pvp_area3_func_money:SetVisible(cost > 0 ) 				
	end	
		
	if(cd > 0 and self.cdProduceHandle == nil)then
		self.cdProduceHandle = scheduler.scheduleGlobal(pvpOfflineCdTimeTick,1) 
	end	
 
end
function pvp:onUpdate(event)
	if not self._show then
		return;
	end
	self:update()
end	
function pvp:onHide(event)
	self:Close();
	if(self.cdProduceHandle ~= nil)then
		scheduler.unscheduleGlobal(self.cdProduceHandle)
		self.cdProduceHandle = nil
	end
end

return pvp;
