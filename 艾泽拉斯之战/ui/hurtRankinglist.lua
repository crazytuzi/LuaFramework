local hurtRankinglist = class( "hurtRankinglist", layout );

global_event.HURTRANKINGLIST_SHOW = "HURTRANKINGLIST_SHOW";
global_event.HURTRANKINGLIST_HIDE = "HURTRANKINGLIST_HIDE";
global_event.HURTRANKINGLIST_UPDATE = "HURTRANKINGLIST_UPDATE";


function hurtRankinglist:ctor( id )
	hurtRankinglist.super.ctor( self, id );
	self:addEvent({ name = global_event.HURTRANKINGLIST_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.HURTRANKINGLIST_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.HURTRANKINGLIST_UPDATE, eventHandler = self.onUpdate});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_BATTLE, eventHandler = self.onHide});
	self.allPreView = {}
end

function hurtRankinglist:onShow(event)
	if self._show then
		return;
	end
 
	self:Show();

	self.hurtrankinglist_scroll = LORD.toScrollPane(self:Child( "rankinglist-scroll" ));
	self.hurtrankinglist_close = self:Child( "rankinglist-close" );

	
	function onClickCloseHurtRankingList()
		self:onHide()		
	end
		
	self.hurtrankinglist_close:subscribeEvent("ButtonClick", "onClickCloseHurtRankingList")	  
	
	self.hurtrankinglist_scroll:init();
	self:upDate()

end


function hurtRankinglist:upDate()
	
	if not self._show then
		return;
	end
	self.hurtrankinglist_scroll:ClearAllItem() 
		
		
				
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)
	
	function onTouchDownHurtRankPlayer(args)	
		local clickImage = LORD.toMouseEventArgs(args).window
		local rect = clickImage:GetUnclippedOuterRect();
 		local userdata = clickImage:GetUserData()
		for i,v in pairs (self.allPreView) do
			v:SetProperty("ImageName",  "set:container3.xml image:container3")
		end	
		clickImage:SetProperty("ImageName",  "set:chargeactivity.xml image:redback")
		if(userdata ~= -1)then
	 		self.selectPlayer = userdata
			--dataManager.pvpData:sendAskLadderDetail(dataManager.pvpData.RankingPlayers[userdata], {left=rect.left,top=rect.top} )
		end				
 	end	 
	function onTouchUpHurtRankPlayer(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		if(userdata ~= -1)then
			 				
		end
 	end	 		
	function onTouchReleaseHurtRankPlayer(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		--eventManager.dispatchEvent( {name = global_event.PVPTIPS_HIDE})		
		if(userdata == -1)then
			return
		end
		 
		
 	end	 	
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
			
			self.tempUi[i].rankingitem_damage_num   =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-damage-num")
			self.tempUi[i].rankingitem_damage  =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-damage")
			self.tempUi[i].record  =  LORD.GUIWindowManager:Instance():GetGUIWindow("hurtranklist_"..i.."_rankingitem-button")
		 
 
		 	self.tempUi[i].prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.hurtrankinglist_scroll:additem(self.tempUi[i].prew);
		
		 	local width = self.tempUi[i].prew:GetWidth()
		 	xpos = xpos + width			
			xpos = LORD.UDim(0, 10)
			ypos = ypos + self.tempUi[i].prew:GetHeight() + LORD.UDim(0, 5)				
		 	self.tempUi[i].rankingitem_head_image:SetImage(global.getHeadIcon( player:getHeadId() ) )
		 	self.tempUi[i].prew:subscribeEvent("WindowTouchDown", "onTouchDownHurtRankPlayer")
	 		self.tempUi[i].prew:subscribeEvent("WindowTouchUp", "onTouchUpHurtRankPlayer")
	 		self.tempUi[i].prew:subscribeEvent("MotionRelease", "onTouchReleaseHurtRankPlayer")
	 		self.tempUi[i].prew:SetUserData(i)
			local r = player:getRanking()
			self.tempUi[i].rankingitem_num:SetText(r)	
			self.tempUi[i].rankingitem_name:SetText(player:getName())	
			self.tempUi[i].rankingitem_lv_num:SetText(player:getLevel())	
			self.tempUi[i].rankingitem_damage_num:SetText(player:getDamage())	
			table.insert(self.allPreView,self.tempUi[i].prew)
			if(i == self.selectPlayer)then
				self.tempUi[i].prew:SetProperty("ImageName",  "set:chargeactivity.xml image:redback")
			else
				self.tempUi[i].prew:SetProperty("ImageName",  "set:container3.xml image:container3")	
			end	
			
			local replayrecordId = player:getReplayID()
			self.tempUi[i].record:SetVisible(replayrecordId ~= -1) 
			self.tempUi[i].record:SetUserData(i)
			self.tempUi[i].record:subscribeEvent("ButtonClick", "onclickHurtRankRecordReplay");	
  				
	 	end		
	end		
end	

 

function hurtRankinglist:onUpdate(event)
	self:upDate()
end

function hurtRankinglist:onHide(event)
	self:Close();
	self.selectPlayer = nil
	self.allPreView = {}
end

return hurtRankinglist;
