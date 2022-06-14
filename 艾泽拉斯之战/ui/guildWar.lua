local guildWar = class( "guildWar", layout );

global_event.GUILDWAR_SHOW = "GUILDWAR_SHOW";
global_event.GUILDWAR_HIDE = "GUILDWAR_HIDE";
global_event.GUILDWAR_UPDATE = "GUILDWAR_UPDATE";

function guildWar:ctor( id )
	guildWar.super.ctor( self, id );
	self:addEvent({ name = global_event.GUILDWAR_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GUILDWAR_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.GUILDWAR_UPDATE, eventHandler = self.update});
	
end

function guildWar:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	local bartender_rank = self:Child("guildWar-bartender-rank");
	local bartender_rule = self:Child("guildWar-bartender-rule");
	local checkscore = self:Child("guildWar-checkscore");
	local guildWar_close = self:Child("guildWar-close");
	
	function onGuildWarClose()
		
		self:onHide();
		
	end
	
	function onGuildWarCheckScore()
		
		eventManager.dispatchEvent({name = global_event.GUILDWARSCORE_SHOW, isResult = false, });		
		
	end
	
	function onGuildWarRank()
	
		eventManager.dispatchEvent({name = global_event.RANKINGLIST_SHOW, rankType = enum.RANK_LIST_TYPE.GUILD_RANK})
	
	end
	
	function onGuildWarRule()
		
		eventManager.dispatchEvent({name = global_event.RULE_SHOW, battleType = enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR })
		
	end
	
	guildWar_close:subscribeEvent("ButtonClick", "onGuildWarClose");
	checkscore:subscribeEvent("ButtonClick", "onGuildWarCheckScore");
	bartender_rank:subscribeEvent("ButtonClick", "onGuildWarRank");
	bartender_rule:subscribeEvent("ButtonClick", "onGuildWarRule");
	
	function onGuildWarClickSpot(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local spotIndex = window:GetUserData();
		
		dataManager.guildWarData:onHandleClickSpot(spotIndex);
		
	end
	
	for i=1, #dataConfig.configs.guildWarConfig do
		
		local bigone = self:Child("guildWar-bigone"..i);
		bigone:SetUserData(i);
		
		bigone:subscribeEvent("WindowTouchUp", "onGuildWarClickSpot");
	end
	
	self:update();
	
end

function guildWar:onHide(event)
	self:Close();
end

function guildWar:update()
	
	if not self._show then
		return;
	end
	
	for i=1, #dataConfig.configs.guildWarConfig do
		
		local whichguild = self:Child("guildWar-whichguild"..i);
		local guildText = self:Child("guildWar-text"..i);
		
		local whichguild_text = self:Child("guildWar-whichguild"..i.."-text");
		
		local bigone = self:Child("guildWar-bigone"..i);
		local bigone_stoped = self:Child("guildWar-bigone"..i.."-stoped");
		
		local spotInstance = dataManager.guildWarData:getSpot(i);
		if spotInstance then
			
			whichguild:SetVisible(spotInstance:getOwnerGuildID() > 0 );
			guildText:SetText(spotInstance:getSpotName());
			whichguild_text:SetText(spotInstance:getSpotOwnerName());
			
			bigone_stoped:SetVisible(dataManager.guildWarData:isOpen() and not spotInstance:isCanAttack());
			
		end
	end
	
end

return guildWar;
