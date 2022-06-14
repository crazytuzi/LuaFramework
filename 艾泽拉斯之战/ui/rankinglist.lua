local rankinglist = class( "rankinglist", layout );

global_event.RANKINGLIST_SHOW = "RANKINGLIST_SHOW";
global_event.RANKINGLIST_HIDE = "RANKINGLIST_HIDE";
global_event.RANKINGLIST_UPDATE = "RANKINGLIST_UPDATE";

function rankinglist:ctor( id )
	rankinglist.super.ctor( self, id );
	self:addEvent({ name = global_event.RANKINGLIST_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.RANKINGLIST_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.RANKINGLIST_UPDATE, eventHandler = self.onUpdate});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_BATTLE, eventHandler = self.onHide});
	self.allPreView = {}
end

function rankinglist:onShow(event)
	
	if self._show then
		return;
	end
	
	self:Show();

	self.rankinglist_scroll = LORD.toScrollPane(self:Child( "rankinglist-scroll" ));
	self.rankinglist_close = self:Child( "rankinglist-close" );
 
	
	function onClickCloseRankingList()
		self:onHide()		
	end
		
	self.rankinglist_close:subscribeEvent("ButtonClick", "onClickCloseRankingList")	  
	
	self.rankinglist_scroll:init();
	--self:upDate()
	
	self:initTablist();
	
	self.selectTab = event.rankType;
	if self.selectTab == nil then
		self.selectTab = enum.RANK_LIST_TYPE.PVP_RANK;
	end
	
	local tab = LORD.toRadioButton(self:Child("ranklist_tab"..self.selectTab.."_ranknameitem"));
	tab:SetSelected(true);
	
end

function rankinglist:initTablist()
	
	function onSelectTabList(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local userdata = window:GetUserData();
		
		if window:IsSelected() then
			
			self.selectTab = userdata;
			
			if self.selectTab == enum.RANK_LIST_TYPE.PVP_RANK then
				
				sendAskLadder(1,50);
				
			elseif self.selectTab == enum.RANK_LIST_TYPE.DAMAGE_RANK then
				
				sendAskTopRank(enum.TOP_TYPE.TOP_TYPE_DAMAGE);
				sendAskTop(enum.TOP_TYPE.TOP_TYPE_DAMAGE, 1, 50);
				
			elseif self.selectTab == enum.RANK_LIST_TYPE.SPEED_RANK then
				
				sendAskTopRank(enum.TOP_TYPE.TOP_TYPE_SPEED);
				sendAskTop(enum.TOP_TYPE.TOP_TYPE_SPEED, 1, 50);
			
			elseif self.selectTab == enum.RANK_LIST_TYPE.GUILD_RANK then
				
				sendAskGuildWarRank();
				
			end
			
			self:updateTab( self.selectTab );
			
		end
		
	end
	
	-- 先初始化tablist，然后选中对应的，没有的话默认选中第一个
	local rankinglist_typescroll = LORD.toScrollPane(self:Child("rankinglist-typescroll"));
	rankinglist_typescroll:init();
	
	rankinglist_typescroll:ClearAllItem();
	
	-- 三个排行榜
	local xpos = LORD.UDim(0,0);
	local ypos = LORD.UDim(0,0);
	
	for i=1, 4 do
		local tab = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("ranklist_tab"..i, "ranknameitem.dlg");
		
		local tabName = self:Child("ranklist_tab"..i.."_ranknameitem-name");
		tabName:SetText(enum.RANK_LIST_NAME[i]);
		
		tab:SetXPosition(xpos);
		tab:SetYPosition(ypos);
		
		tab:SetUserData(i);
		tab:subscribeEvent("RadioStateChanged", "onSelectTabList");
		
		rankinglist_typescroll:additem(tab);
		
		ypos = ypos + tab:GetHeight();
	end
	
end

function rankinglist:upDatePvpRank()
	
	if not self._show then
		return;
	end
	self.rankinglist_scroll:ClearAllItem() 
		
		
				
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)
	
	function onTouchDownRankPlayerOnHead(args)	
		local clickImage = LORD.toMouseEventArgs(args).window
		local rect = clickImage:GetUnclippedOuterRect();
 		local userdata = clickImage:GetUserData()
		if(userdata ~= -1)then
	 		self.selectPlayer = userdata
			dataManager.pvpData:sendAskLadderDetail(dataManager.pvpData.RankingPlayers[userdata], {left=rect.left,top=rect.top} )
		end
 	end	 
			
	self.allPreView = {}
	self.tempUi  = {}
	for i,v in ipairs (dataManager.pvpData.RankingPlayers) do
		self.tempUi[i] ={}
	 	local player = v				
	 	if player then						
			self.tempUi[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("ranklist_"..i, "rankingitem.dlg");
			self.tempUi[i].rankingitem_head_image = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("ranklist_"..i.."_rankingitem-head-image"))
			self.tempUi[i].rankingitem_num = LORD.GUIWindowManager:Instance():GetGUIWindow("ranklist_"..i.."_rankingitem-num")
			self.tempUi[i].rankingitem_lv_num =  LORD.GUIWindowManager:Instance():GetGUIWindow("ranklist_"..i.."_rankingitem-lv-num")
			self.tempUi[i].rankingitem_name =  LORD.GUIWindowManager:Instance():GetGUIWindow("ranklist_"..i.."_rankingitem-name")
			self.tempUi[i].rankingitem_1st = self:Child("ranklist_"..i.."_rankingitem-1st");
			self.tempUi[i].rankingitem_2nd = self:Child("ranklist_"..i.."_rankingitem-2nd");
			self.tempUi[i].rankingitem_3rd = self:Child("ranklist_"..i.."_rankingitem-3rd");
			
			
			local rankingitem_head = LORD.toStaticImage(self:Child("ranklist_"..i.."_rankingitem-head"));
			rankingitem_head:SetImage(global.getMythsIcon(player.miracle));
			
			self.tempUi[i].rankingitem_damage_num   =  LORD.GUIWindowManager:Instance():GetGUIWindow("ranklist_"..i.."_rankingitem-damage-num")
			self.tempUi[i].rankingitem_damage  =  LORD.GUIWindowManager:Instance():GetGUIWindow("ranklist_"..i.."_rankingitem-damage")
			self.tempUi[i].rankingitem_damage_num:SetText("")	
			self.tempUi[i].rankingitem_damage:SetText("")	
		 	self.tempUi[i].prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.rankinglist_scroll:additem(self.tempUi[i].prew);
			
			local rankingitem_button = self:Child("ranklist_"..i.."_rankingitem-button");
			rankingitem_button:SetVisible(false);
			
		 	local width = self.tempUi[i].prew:GetWidth()
		 	xpos = xpos + width			
			xpos = LORD.UDim(0, 10)
			ypos = ypos + self.tempUi[i].prew:GetHeight() + LORD.UDim(0, 5)				
		 	self.tempUi[i].rankingitem_head_image:SetImage(global.getHeadIcon( player:getHeadId() ) )
			self.tempUi[i].rankingitem_head_image:subscribeEvent("WindowTouchDown", "onTouchDownRankPlayerOnHead")
	 		self.tempUi[i].prew:SetUserData(i)
			self.tempUi[i].rankingitem_head_image:SetUserData(i)
			local r = player:getOfflineRanking()
			self.tempUi[i].rankingitem_num:SetText(r)	
			self.tempUi[i].rankingitem_name:SetText(player:getName())	
			self.tempUi[i].rankingitem_lv_num:SetText(player.kingInfo.level)	 
			table.insert(self.allPreView,self.tempUi[i].prew)
			self.tempUi[i].rankingitem_1st:SetVisible(r == 1)
			self.tempUi[i].rankingitem_2nd:SetVisible(r == 2)
			self.tempUi[i].rankingitem_3rd:SetVisible(r == 3)
			if r == 1 or r==2 or r==3 then
				self.tempUi[i].rankingitem_num:SetVisible(false);
				else 
			    self.tempUi[i].rankingitem_num:SetVisible(true);
			end
  				
	 	end		
	end		
	
	-- update my info
	local rankself_ranknum = self:Child("rankinglist-rankself-ranknum");
	local rankself_myname = self:Child("rankinglist-rankself-myname");
	local extrainfo = self:Child("rankinglist-extrainfo");
	
	local nowRanking,_nowRanking = dataManager.pvpData:getOfflineRanking();
	rankself_ranknum:SetText(nowRanking);
	rankself_myname:SetText(dataManager.playerData:getName());
	extrainfo:SetText("");
	
end	

 
function rankinglist:updateDamageRank()
	if not self._show then
		return;
	end
	self.rankinglist_scroll:ClearAllItem() 
		
		
				
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)
	
		 	
	function onclickHurtRankRecordReplay(args)
		local window = LORD.toWindowEventArgs(args).window;
		local windowname = window:GetName();
		local replayrecordPlayerId = window:GetUserData()		
		local replayrecordPlayer = dataManager.hurtRankData.hurtRankingPlayers[replayrecordPlayerId]
		if(replayrecordPlayer)then
			local replayrecordId = replayrecordPlayer:getReplayID()
			battlePrepareScene.battleType = enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE
			battlePrepareScene.sceneID = dataConfig.configs.stageConfig[dataManager.hurtRankData:getStageId()].sceneID
			print("onclickHurtRankRecordReplay .........replayrecordId "..replayrecordId)
			sendAskReplay(replayrecordId)
		end
 
	end		
	
	for k,v in pairs (self.allPreView) do
		if(self.allPreView[k].prew)then
			self.allPreView[k].prew:removeAllEvents();	
		end	
	end	
	self.allPreView = {}
	self.tempUi  = {}  
	for i,v in ipairs (dataManager.hurtRankData.hurtRankingPlayers) do
		self.tempUi[i] ={}
	 	local player = v				
	 	if player then						
			self.tempUi[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("hurtranklist_"..i, "rankingitem.dlg");
			self.tempUi[i].rankingitem_head_image = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-head-image"))
			self.tempUi[i].rankingitem_num = LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-num")
			self.tempUi[i].rankingitem_lv_num =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-lv-num")
			self.tempUi[i].rankingitem_name =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-name")
			self.tempUi[i].rankingitem_1st = self:Child("hurtranklist_"..i.."_rankingitem-1st");
			self.tempUi[i].rankingitem_2nd = self:Child("hurtranklist_"..i.."_rankingitem-2nd");
			self.tempUi[i].rankingitem_3rd = self:Child("hurtranklist_"..i.."_rankingitem-3rd");
			
			self.tempUi[i].rankingitem_damage_num   =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-damage-num")
			self.tempUi[i].rankingitem_damage  =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-damage")
			self.tempUi[i].record  =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-button")
		 
 			local rankingitem_head = LORD.toStaticImage(self:Child("hurtranklist_"..i.."_rankingitem-head"));
			rankingitem_head:SetImage(global.getMythsIcon(player.miracle));
			
		 	self.tempUi[i].prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.rankinglist_scroll:additem(self.tempUi[i].prew);
		
		 	local width = self.tempUi[i].prew:GetWidth()
		 	xpos = xpos + width			
			xpos = LORD.UDim(0, 10)
			ypos = ypos + self.tempUi[i].prew:GetHeight() + LORD.UDim(0, 5)				
		 	self.tempUi[i].rankingitem_head_image:SetImage(global.getHeadIcon( player:getHeadId() ) )
	 		self.tempUi[i].prew:SetUserData(i)
			local r = player:getRanking()
			self.tempUi[i].rankingitem_num:SetText(r)	
			self.tempUi[i].rankingitem_name:SetText(player:getName())	
			self.tempUi[i].rankingitem_lv_num:SetText(player:getLevel())	
			self.tempUi[i].rankingitem_damage_num:SetText("伤害值: "..player:getDamage())	
			table.insert(self.allPreView,self.tempUi[i].prew)
			self.tempUi[i].rankingitem_1st:SetVisible(r == 1)
			self.tempUi[i].rankingitem_2nd:SetVisible(r == 2)
			self.tempUi[i].rankingitem_3rd:SetVisible(r == 3)
			if r == 1 or r==2 or r==3 then
				self.tempUi[i].rankingitem_num:SetVisible(false);
			end
			
			local replayrecordId = player:getReplayID()
			self.tempUi[i].record:SetVisible(replayrecordId ~= -1) 
			self.tempUi[i].record:SetUserData(i)
			self.tempUi[i].record:subscribeEvent("ButtonClick", "onclickHurtRankRecordReplay");	
  				
	 	end		
	end		

	-- update my info
	local rankself_ranknum = self:Child("rankinglist-rankself-ranknum");
	local rankself_myname = self:Child("rankinglist-rankself-myname");
	local extrainfo = self:Child("rankinglist-extrainfo");
	
	if dataManager.hurtRankData:getBattleNum() > 0 then
		
		local rank,_rank = dataManager.hurtRankData:getRanking()
		rankself_ranknum:SetText(rank);
		rankself_myname:SetText(dataManager.playerData:getName());
		
		local sa ,sb = dataManager.hurtRankData:getScore();
		extrainfo:SetText("伤害值: "..sb);
				
	else
		
		extrainfo:SetText("");
		rankself_ranknum:SetText("");
		rankself_myname:SetText("未上榜");
		
	end
		
end

function rankinglist:updateSpeedRank()
	
	if not self._show then
		return;
	end
	
	function onTouchUpSpeedRankPlayer(args)
	
	end
	
	self.rankinglist_scroll:ClearAllItem() 
		
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)
	
	local rankData = dataManager.speedChallegeRankData:getRankData();
	dump(rankData);
	
	for i,v in ipairs (rankData) do
		
		local playerRankInfo = v;
	 	if playerRankInfo.rank then
	 				
			local prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("hurtranklist_"..i, "rankingitem.dlg");
			local rankingitem_head_image = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-head-image"))
			local rankingitem_num = LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-num")
			local rankingitem_lv_num =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-lv-num")
			local rankingitem_name =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-name")
			local rankingitem_1st = self:Child("hurtranklist_"..i.."_rankingitem-1st");
			local rankingitem_2nd = self:Child("hurtranklist_"..i.."_rankingitem-2nd");
			local rankingitem_3rd = self:Child("hurtranklist_"..i.."_rankingitem-3rd");
			
			rankingitem_damage_num   =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-damage-num")
			rankingitem_damage  =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-damage")
			record  =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-button")
		 	
		 	local rankingitem_head = LORD.toStaticImage(self:Child("hurtranklist_"..i.."_rankingitem-head"));
			rankingitem_head:SetImage(global.getMythsIcon(playerRankInfo.miracle));
			
		 	rankingitem_damage:SetText("");
		 	
		 	prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.rankinglist_scroll:additem(prew);
			
			ypos = ypos + prew:GetHeight() + LORD.UDim(0, 5);
			
		 	rankingitem_head_image:SetImage(global.getHeadIcon( playerRankInfo.iconID));
		 	
	 		prew:subscribeEvent("WindowTouchUp", "onTouchUpSpeedRankPlayer");
	 		prew:SetUserData(i);
	 		
			local r = playerRankInfo.rank;
			rankingitem_num:SetText(r);
			rankingitem_name:SetText(playerRankInfo.name);
			rankingitem_1st:SetVisible(r == 1)
			rankingitem_2nd:SetVisible(r == 2)
			rankingitem_3rd:SetVisible(r == 3)
			if r == 1 or r==2 or r==3 then
				rankingitem_num:SetVisible(false);
			end
			
			rankingitem_lv_num:SetText(playerRankInfo.level);
			rankingitem_damage_num:SetText("行动数: "..playerRankInfo.score);
			
			record:SetVisible(false); 
	
	 	end
	 			
	end
	

	-- update my info
	local rankself_ranknum = self:Child("rankinglist-rankself-ranknum");
	local rankself_myname = self:Child("rankinglist-rankself-myname");
	local extrainfo = self:Child("rankinglist-extrainfo");
	
	if dataManager.playerData:isSpeedChallegeSuccess() then
		
		local rank = dataManager.speedChallegeRankData:getMyRank()
		rankself_ranknum:SetText(rank);
		rankself_myname:SetText(dataManager.playerData:getName());
		local round = dataManager.speedChallegeRankData:getMyBattleRound();
		extrainfo:SetText("行动数: "..round);
				
	else
		
		extrainfo:SetText("");
		rankself_ranknum:SetText("");
		rankself_myname:SetText("未上榜");
		
	end	
end

function rankinglist:updateTab(tabType)
		
	if not self._show then
		return;
	end
	
	if tabType == enum.RANK_LIST_TYPE.PVP_RANK then
		
		self:upDatePvpRank();
		
	elseif tabType == enum.RANK_LIST_TYPE.DAMAGE_RANK then
		
		self:updateDamageRank();
		
	elseif tabType == enum.RANK_LIST_TYPE.SPEED_RANK then
	
		self:updateSpeedRank();
	
	elseif tabType == enum.RANK_LIST_TYPE.GUILD_RANK then
		
		self:updateGuildRank();
		
	end
end

function rankinglist:onUpdate(event)
	--self:upDate()
	
	if not self._show then
		return;
	end

	self:updateTab( self.selectTab );
	
end

function rankinglist:onHide(event)
	self:Close();
	self.selectPlayer = nil
end

function rankinglist:updateGuildRank()

	if not self._show then
		return;
	end

	self.rankinglist_scroll:ClearAllItem() 
		
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)
	
	local rankData = dataManager.guildWarData:getRankData();
	
	for i,v in ipairs (rankData) do
		
		local playerRankInfo = v;
	 	if playerRankInfo.id then
	 				
			local prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("guildrank_"..i, "rankingitem.dlg");
			local rankingitem_head_image = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("guildrank_"..i.."_rankingitem-head-image"))
			local rankingitem_num = LORD.GUIWindowManager:Instance():GetGUIWindow("guildrank_"..i.."_rankingitem-num")
			local rankingitem_lv_num =  LORD.GUIWindowManager:Instance():GetGUIWindow("guildrank_"..i.."_rankingitem-lv-num")
			
			local rankingitem_lv =  LORD.GUIWindowManager:Instance():GetGUIWindow("guildrank_"..i.."_rankingitem-lv")
			
			local rankingitem_name =  LORD.GUIWindowManager:Instance():GetGUIWindow("guildrank_"..i.."_rankingitem-name")
			local rankingitem_1st = self:Child("guildrank_"..i.."_rankingitem-1st");
			local rankingitem_2nd = self:Child("guildrank_"..i.."_rankingitem-2nd");
			local rankingitem_3rd = self:Child("guildrank_"..i.."_rankingitem-3rd");
			
			rankingitem_damage_num   =  LORD.GUIWindowManager:Instance():GetGUIWindow("guildrank_"..i.."_rankingitem-damage-num")
			rankingitem_damage  =  LORD.GUIWindowManager:Instance():GetGUIWindow("guildrank_"..i.."_rankingitem-damage")
			record  =  LORD.GUIWindowManager:Instance():GetGUIWindow("guildrank_"..i.."_rankingitem-button")
		 	
		 	--local rankingitem_head = LORD.toStaticImage(self:Child("guildrank_"..i.."_rankingitem-head"));
			--rankingitem_head:SetImage(global.getHeadIcon(playerRankInfo.createrHead));
			
		 	rankingitem_damage:SetText("");
		 	
		 	prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.rankinglist_scroll:additem(prew);
			
			ypos = ypos + prew:GetHeight() + LORD.UDim(0, 5);
			
		 	rankingitem_head_image:SetImage(global.getHeadIcon( playerRankInfo.createrHead));
	 		
			local r = i;
			rankingitem_num:SetText(r);
			rankingitem_name:SetText(playerRankInfo.name);
			rankingitem_1st:SetVisible(r == 1)
			rankingitem_2nd:SetVisible(r == 2)
			rankingitem_3rd:SetVisible(r == 3)
			if r == 1 or r==2 or r==3 then
				rankingitem_num:SetVisible(false);
			end
			
			rankingitem_lv:SetText("公会战积分:"..playerRankInfo.warScore);
			rankingitem_lv_num:SetText("");
			rankingitem_damage_num:SetText("");
			
			record:SetVisible(false); 
	
	 	end
	 			
	end
	

	-- update my info
	local rankself_ranknum = self:Child("rankinglist-rankself-ranknum");
	local rankself_myname = self:Child("rankinglist-rankself-myname");
	local extrainfo = self:Child("rankinglist-extrainfo");

	rankself_ranknum:SetText("");
	rankself_myname:SetText("");
	extrainfo:SetText("");
				

		
end

return rankinglist;
