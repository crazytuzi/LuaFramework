local pvprecord = class( "pvprecord", layout );

global_event.PVPRECORD_SHOW = "PVPRECORD_SHOW";
global_event.PVPRECORD_HIDE = "PVPRECORD_HIDE";
global_event.PVPRECORD_UPDATE = "PVPRECORD_UPDATE";

function pvprecord:ctor( id )
	pvprecord.super.ctor( self, id );
	self:addEvent({ name = global_event.PVPRECORD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.PVPRECORD_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.PVPRECORD_UPDATE, eventHandler = self.onUpdate});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_BATTLE, eventHandler = self.onHide});
	
	
	
	self.allPreView = {}
end

function pvprecord:onShow(event)
	if self._show then
		return;
	end
	sendAskReplaySummary(-1)
	self:Show();

	self.pvprecord_scroll = LORD.toScrollPane(self:Child( "pvprecord-scroll" ));
	self.pvprecord_close = self:Child( "pvprecord-close" );
	
	
	function onClickClosePvprecord()
		self:onHide()		
	end
		
	self.pvprecord_close:subscribeEvent("ButtonClick", "onClickClosePvprecord")	  
	self.pvprecord_scroll:init();
	self:upDate()
end

function pvprecord:upDate()
	
	if not self._show then
		return;
	end
	self.pvprecord_scroll:ClearAllItem() 
		
		
				
	local xpos = LORD.UDim(0, 0)
	local ypos = LORD.UDim(0, 0)
	
	function onTouchDownPvpRecordPlayer(args)	
		local clickImage = LORD.toWindowEventArgs(args).window
		local rect = clickImage:GetUnclippedOuterRect();
 		local userdata = clickImage:GetUserData()
		for i,v in pairs (self.allPreView) do
			v:SetProperty("ImageName",  "set:common.xml image:ditu10")
		end	
		clickImage:SetProperty("ImageName",  "")
		if(userdata ~= -1)then
	 		self.selectPlayer = userdata
		end				
 	end	 
	function onTouchUpPvpRecordPlayer(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		if(userdata ~= -1)then				
		end
 	end	 		
	function onTouchReleasePvpRecordPlayer(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		if(userdata == -1)then
			return
		end
		
		
 	end	 	
	 
	function onclickPvpRecordReplay(args)
		local window = LORD.toWindowEventArgs(args).window;
		local windowname = window:GetName();
		local replayrecordId = window:GetUserData()		
		local record = dataManager.pvpData.offlineReplayRecord[replayrecordId]
		if(record)then
			replayrecordId = record:getId()
			battlePrepareScene.battleType = enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE
			print(".........replayrecordId "..replayrecordId)
			battlePrepareScene.sceneID = enum.BATTLE_PVP_SCENE_ID;
			sendAskReplay(replayrecordId)
		end
 
	end
	
	function onPvpRecordShare(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local windowname = window:GetName();
		local replayrecordId = window:GetUserData()		
		local record = dataManager.pvpData.offlineReplayRecord[replayrecordId]
		if(record)then
			replayrecordId = record:getId();
			local params = {};
			table.insert(params, replayrecordId);
			dataManager.chatData:askChat(enum.CHANNEL.CHANNEL_WORLD, enum.CHAT_TYPE.CHAT_TYPE_REPLAY, "", params);
		end
		
	end
				
	function onclickPvpRecordRevenge(args)
		local window = LORD.toWindowEventArgs(args).window;
		local windowname = window:GetName();
		local replayrecordId = window:GetUserData()		
		local record = dataManager.pvpData.offlineReplayRecord[replayrecordId]
		if(record)then
			replayrecordId = record:getplayerId()
			battlePrepareScene.battleType = enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE
			battlePrepareScene.sceneID = enum.BATTLE_PVP_SCENE_ID;
			if(dataManager.pvpData:CheckResetOfflineBattleNum())then
				return 
			end
			
			if(dataManager.pvpData:CheckandCleanCdOffline())then
				return 
			end
			PLAN_CONFIG.currentPlanType = enum.PLAN_TYPE.PLAN_TYPE_PVE
			dataManager.pvpData:setOfflineFuchouFlag(true)
			dataManager.pvpData:setSelectFuchouPlayerId(record:getplayerId())
			sendAskLadderDetail(record:getplayerId(),-1)
			--global.gotoPvpOfflineBattle()
			---sendPvpRevenge(record:getplayerId())
			self:onHide()	
		end
	end	

	for k,v in pairs (self.allPreView) do
		if(self.allPreView[k].record)then
			self.allPreView[k].record:removeEvent("ButtonClick");	
		end	
	end		
	self.allPreView = {}
	self.tempUi  = {}
	for i,v in ipairs (dataManager.pvpData.offlineReplayRecord) do
		self.tempUi[i] ={}
	 	local player = v				
	 	if v then						
			self.tempUi[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("pvprecord_"..i, "pvprecorditem.dlg");
			self.tempUi[i].result = LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-result")
			self.tempUi[i].tips = LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-tips")
	 
			
			self.tempUi[i].arrow =   LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-arrow"))
			self.tempUi[i].arrowNum =  LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-arrow-num")			
			self.tempUi[i].head = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-head-image"))
			self.tempUi[i].name =  LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-name")			
			self.tempUi[i].lv =  LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-lv-num")
			self.tempUi[i].time =  LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-time")
			self.tempUi[i].record =  LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-record")
			self.tempUi[i].re =  LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-re")
 			self.tempUi[i].share = LORD.GUIWindowManager:Instance():GetGUIWindow("pvprecord_"..i.."_pvprecorditem-share")
			
		 	self.tempUi[i].prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.pvprecord_scroll:additem(self.tempUi[i].prew);
		
		 	local width = self.tempUi[i].prew:GetWidth()
		 	xpos = xpos + width			
			xpos = LORD.UDim(0, 0)
			ypos = ypos + self.tempUi[i].prew:GetHeight() + LORD.UDim(0, 5)				
		    self.tempUi[i].head:SetImage(global.getHeadIcon( v:getHeadId() ) )
		 	self.tempUi[i].prew:subscribeEvent("WindowTouchDown", "onTouchDownPvpRecordPlayer")
	 		self.tempUi[i].prew:subscribeEvent("WindowTouchUp", "onTouchUpPvpRecordPlayer")
	 		self.tempUi[i].prew:subscribeEvent("MotionRelease", "onTouchReleasePvpRecordPlayer")
	 		self.tempUi[i].prew:SetUserData(i)
	 		
	 		local pvprecorditem_power = self:Child("pvprecord_"..i.."_pvprecorditem-power");
	 		pvprecorditem_power:SetVisible(false);
	 		
	 		-- ·ÖÏí
	 		if self.tempUi[i].share then
	 			self.tempUi[i].share:subscribeEvent("ButtonClick", "onPvpRecordShare");
	 			self.tempUi[i].share:SetUserData(i);
	 		end
	 		
			self.tempUi[i].tips:SetText(v:getChallenger())	
			self.tempUi[i].result:SetText(v:getWin())		
			local rankChangedNum,arrow = v:getRankChanged()
			self.tempUi[i].arrowNum:SetText(rankChangedNum)	
			--self.tempUi[i].arrow:SetProperty("Rotate",arrow)	
			if(arrow > 0)then
				self.tempUi[i].arrow:SetProperty("ImageName","set:common.xml image:jiantou2")	
			else
				self.tempUi[i].arrow:SetProperty("ImageName","set:common.xml image:jiantou1")	
			end
			
				
			self.tempUi[i].name:SetText(v:getName())
			self.tempUi[i].lv:SetText(v:getLevel())
			self.tempUi[i].time:SetText(v:getbattleTime())
			table.insert(self.allPreView,self.tempUi[i].prew)
			if(i == self.selectPlayer)then
				self.tempUi[i].prew:SetProperty("ImageName",  "")
			else
				self.tempUi[i].prew:SetProperty("ImageName",  "set:common.xml image:ditu10")	
			end	
			self.tempUi[i].record:SetUserData(i)
			self.tempUi[i].record:subscribeEvent("ButtonClick", "onclickPvpRecordReplay");	
  				
			self.tempUi[i].re:SetVisible(v:canRevenge())	
			self.tempUi[i].re:SetUserData(i)
			self.tempUi[i].re:subscribeEvent("ButtonClick", "onclickPvpRecordRevenge");	
				
	 	end		
	end		
end	

 

function pvprecord:onUpdate(event)
	self:upDate()
end

function pvprecord:onHide(event)
	self:Close();
	self.allPreView = {}
end





return pvprecord;
