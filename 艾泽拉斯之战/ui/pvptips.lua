local pvptips = class( "pvptips", layout );

global_event.PVPTIPS_SHOW = "PVPTIPS_SHOW";
global_event.PVPTIPS_HIDE = "PVPTIPS_HIDE";

function pvptips:ctor( id )
	pvptips.super.ctor( self, id );
	self:addEvent({ name = global_event.PVPTIPS_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.PVPTIPS_HIDE, eventHandler = self.onHide});
end

function pvptips:onShow(event)
	 
	
	self:Show();
	
	if(event.pos)then
		local left = event.pos.left
		local top =  event.pos.top
		self.pvptips = self:Child( "pvptipsRoot" );
		local x = LORD.UDim(0, left);
		local y = LORD.UDim(0, top -20) - self.pvptips:GetHeight();
	
		if event.dir == "left" then
			x = LORD.UDim(0, left) - self.pvptips:GetWidth();
			y = LORD.UDim(0, top);
		end
		
		local s = self.pvptips:GetPixelSize()
		if( x.offset + s.x > engine.rootUiSize.w)then
			x.offset = engine.rootUiSize.w - s.x -5
		end
		
		if ( x.offset < 0 ) then
			x.offset = 0;
		end
		
		if( y.offset + s.y > engine.rootUiSize.h)then
			y.offset = engine.rootUiSize.h - s.y -5
		end
		
		if y.offset < 0 then
			y.offset = 0;
		end
		
		self.pvptips:SetXPosition(x);
		self.pvptips:SetYPosition(y);	
 
	end

	self.pvptips_hero_image = LORD.toStaticImage(self:Child( "pvptips-hero-image" ));
	self.pvptips_name = self:Child( "pvptips-name" );
	self.pvptips_lv_num = self:Child( "pvptips-lv-num" );
	self.pvptips_rank_num = self:Child( "pvptips-rank-num" );
	self.pvptips_power_num = self:Child( "pvptips-power-num" );
	
	--[[
	self.pvptips_whisper = self:Child( "pvptips-whisper" );
	self.pvptips_add = self:Child( "pvptips-add" );
	self.pvptips_sended = self:Child( "pvptips-sended" );
	
	function onTouchDownpvptipsChat(args)
		local clickImage = LORD.toWindowEventArgs(args).window
		local rect = clickImage:GetUnclippedOuterRect();
		
		local playerid = dataManager.pvpData.rankDetailPlayer.playerId
		eventManager.dispatchEvent({name = global_event.CONTACTLAYOUT_SHOW ,rect = rect, id = playerid ,from = "PVP_RANK" })

	end	
	
	function onTouchDownpvptipsAddFriend()
			local clickImage = LORD.toWindowEventArgs(args).window
			local rect = clickImage:GetUnclippedOuterRect();
			local playerid = dataManager.pvpData.rankDetailPlayer.playerId
			eventManager.dispatchEvent({name = global_event.CONTACTLAYOUT_SHOW ,rect = rect, id = playerid ,from = "PVP_RANK" })
	end	
	
	self.pvptips_whisper:subscribeEvent("ButtonClick", "onTouchDownpvptipsChat")
	self.pvptips_sended:subscribeEvent("ButtonClick", "onTouchDownpvptipsAddFriend")
	]]
	
	self.pvptips_crops = {}	
	for i = 1,6 do
		self.pvptips_crops[i] = {}
		self.pvptips_crops[i].root = LORD.toStaticImage(self:Child( "pvptips-crops"..i ));		
		self.pvptips_crops[i].head  = LORD.toStaticImage(self:Child( "pvptips-crops"..i.."-head" ));
		self.pvptips_crops[i].star  = self:Child( "pvptips-crops"..i.."-star" );		
		self.pvptips_crops[i].starall ={}	
		for k = 1,6 do
			self.pvptips_crops[i].starall[k] = LORD.toStaticImage(self:Child( "pvptips-crops"..i.."-star"..k ))		
		end
				
		self.pvptips_crops[i].equity = LORD.toStaticImage(self:Child( "pvptips-crops"..i.."-equity" ));
	end		
	
	for i = 1,6 do
		local  info = dataManager.pvpData.rankDetailPlayer:getOfflineCrops(i)
		
		if(info)then
				self.pvptips_crops[i].head:SetImage(info.icon)
				self.pvptips_crops[i].star:SetVisible(true) 				
				for k = 1,6 do
					self.pvptips_crops[i].starall[k]:SetVisible( k <= info.starLevel ) 	
				end
				
				self.pvptips_crops[i].equity:SetImage(itemManager.getImageWithStar(info.starLevel));
									
		else		
			self.pvptips_crops[i].head:SetImage("")
			self.pvptips_crops[i].equity:SetImage("")
			self.pvptips_crops[i].star:SetVisible(false) 			
		end			
	end	
	
	self.pvptips_hero_image:SetImage( global.getHeadIcon (dataManager.pvpData.rankDetailPlayer:getHeadId()) ) 
	self.pvptips_name:SetText( dataManager.pvpData.rankDetailPlayer:getName()) 
	self.pvptips_lv_num:SetText( dataManager.pvpData.rankDetailPlayer.kingInfo.level) 
 
	local rank = dataManager.pvpData.rankDetailPlayer:getOfflineRanking()
	self.pvptips_rank_num:SetText(rank)
	self.pvptips_power_num:SetText( dataManager.pvpData.rankDetailPlayer:playerPower() )
	
	function onTouchDownRankpvpTips()
		self:onHide()
	end
	self._view:subscribeEvent("WindowTouchDown", "onTouchDownRankpvpTips")
	
	
	
	
	--[[
	self.pvptips_whisper
	self.pvptips_add
	self.pvptips_sended
	
	]]--
	
	
	
end

function pvptips:onHide(event)
	self:Close();
end

return pvptips;
