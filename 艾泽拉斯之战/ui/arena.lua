local arena = class( "arena", layout );

global_event.ARENA_SHOW = "ARENA_SHOW";
global_event.ARENA_HIDE = "ARENA_HIDE";

function arena:ctor( id )
	arena.super.ctor( self, id );
	self:addEvent({ name = global_event.ARENA_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ARENA_HIDE, eventHandler = self.onHide});
end

function arena:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.arena_pvp1_close = self:Child( "arena-pvp1-close" );
	self.arena_pvi1_time1 = self:Child( "arena-pvi1-time1" );
	self.arena_pvi1_time2 = self:Child( "arena-pvi1-time2" );
	self.arena_pvp1_open = self:Child( "arena-pvp1-open" );
	self.arena_pvp1_button = self:Child( "arena-pvp1-button" );
	self.arena_pvp1_close_time = self:Child( "arena-pvp1-close-time" );
	self.arena_pvp1_fist = self:Child( "arena-pvp1-fist" );
	
	self.arena_pvp1_button_effect = self:Child( "arena-pvp1-button-effect" );
	self.arena_pvp2_button_effect = self:Child( "arena-pvp2-button-effect" );
	
	
	self.arena_pvp1_lv = self:Child( "arena-pvp1-lv" );
	
	
	self.arena_pvp2_text = self:Child( "arena-pvp2-text" );
	self.arena_pvp2_button = self:Child( "arena-pvp2-button" );
	
	
	
	self.arena_close = self:Child( "arena-close" );	
	function onClickArena_close()
		self:onHide()
		homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.ARENA);
	end		
	self.arena_close:subscribeEvent("ButtonClick", "onClickArena_close");
	
	function onClickarena_pvp2_button()	
		global.openOfflinePvp(true)
	end		
 
	self.arena_pvp2_button:subscribeEvent("ButtonClick", "onClickarena_pvp2_button");
	local OfflineOpenLevel = dataManager.pvpData:getOfflineOpenLevel()
	
	if(OfflineOpenLevel > dataManager.playerData:getLevel())then
		self.arena_pvp2_button:SetEnabled(false)
		self.arena_pvp2_text:SetText("".."^FF0000"..OfflineOpenLevel )
		self.arena_pvp2_button_effect:SetVisible(false)		
	else
		self.arena_pvp2_button:SetEnabled(true)
		self.arena_pvp2_text:SetText(""..OfflineOpenLevel )
		self.arena_pvp2_button_effect:SetVisible(true)		
	end
	
	local beginTime,isPvPing ,endTime = dataManager.pvpData:getOnlineBeginTime()
		
	
	local color = "^FFFFFF"
	local day = dataManager.getServerOpenDay()
	if(day < 1)then
		isPvPing = false
		--self.arena_pvp1_close_time:SetText("明日开放")
		self.arena_pvp1_close_time:SetVisible(false) 	
		self.arena_pvp1_fist:SetVisible(true) 	
	else
		--self.arena_pvp1_close_time:SetText("开放时间")	
		self.arena_pvp1_close_time:SetVisible(true) 
		self.arena_pvp1_fist:SetVisible(false) 	
	end
	local enable = isPvPing	
	
	if(not isPvPing)then
		color = "^FF0000"
		self.arena_pvp1_open:SetVisible(false) 	
		self.arena_pvp1_close:SetVisible(true) 
		
		
		local b1 = dataConfig.configs.ConfigConfig[0].pvpBeginTime[1]
	    local e1 = dataConfig.configs.ConfigConfig[0].pvpEndTime[1]
		local be1Time = b1.."~"..e1
		
		self.arena_pvi1_time1:SetText(color..be1Time) 
		
		local b2 = dataConfig.configs.ConfigConfig[0].pvpBeginTime[2]
	    local e2 = dataConfig.configs.ConfigConfig[0].pvpEndTime[2]
		local be2Time = b2.."~"..e2
		self.arena_pvi1_time2:SetText(color..be2Time)  
		
	else
		self.arena_pvp1_open:SetVisible(true) 
		self.arena_pvp1_close:SetVisible(false)		
	end 
	self.arena_pvp1_button_effect:SetVisible(isPvPing)		
	self.arena_pvp1_button:SetEnabled(isPvPing)
	function onClickarena_pvp1_button()	
		if global.tipBagFull() then
			return;
		end
		
		local day = dataManager.getServerOpenDay()
		if(day < 1)then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = "开服首日不开放同步PVP活动" });
			return
		end
		self:onHide()
		global.changeGameState(function() 
			global.gotoarena_pvpOnline();
		end);
		
	end		
	 self.arena_pvp1_button:subscribeEvent("ButtonClick", "onClickarena_pvp1_button"); 
	
	
	
	local onlineOpenLevel = dataManager.pvpData:getOnlineOpenLevel()
	if(onlineOpenLevel > dataManager.playerData:getLevel())then
		enable = false		
	end
	
	if(not enable)then
		self.arena_pvp1_button:SetEnabled(false)
		self.arena_pvp1_lv:SetText("".."^FF0000"..onlineOpenLevel )
		self.arena_pvp1_button_effect:SetVisible(false)	
	else
		self.arena_pvp1_button:SetEnabled(true)
		self.arena_pvp1_lv:SetText(""..onlineOpenLevel )
		self.arena_pvp1_button_effect:SetVisible(true)	
	end
 
	
	eventManager.dispatchEvent( {name = global_event.GUIDE_ON_ENTER_ARENA})
end

function arena:onHide(event)
	self:Close();
end

return arena;
