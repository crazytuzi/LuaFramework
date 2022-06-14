local card = class( "card", layout );

global_event.CARD_SHOW = "CARD_SHOW";
global_event.CARD_HIDE = "CARD_HIDE";
global_event.CARD_SHOW_DRAW_CARD = "CARD_SHOW_DRAW_CARD";
global_event.CARD_HIDE_DRAW_CARD = "CARD_HIDE_DRAW_CARD";

function card:ctor( id )
	card.super.ctor( self, id );
	self:addEvent({ name = global_event.CARD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CARD_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.CARD_SHOW_DRAW_CARD, eventHandler = self.showCardUI});
	self:addEvent({ name = global_event.CARD_HIDE_DRAW_CARD, eventHandler = self.hideCardUI});
end

function card:onShow(event)
	if self._show then
		return;
	end

	function onClickCardClose()
		self:onHide();
	end
	
	function freeTimeTick()
		self:refreshTime();
	end
	
	function onClickCardOne()
		self:drawOneCard();
		eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_CRAD_OPERATOR})
	end
	
	function onClickCardTen()
		self:drawTenCard();
		eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_CRAD_OPERATOR})
	end
	
	function onClickCardSkipDisplay()
		displayCardLogic.endDisplay()
	end
	
	self:Show();

	self.card_one_num = self:Child( "card-one-num" );
	self.card_one_button = self:Child( "card-one-button" );
	self.card_one_countdown = self:Child( "card-one-countdown" );
	self.card_one_text = self:Child( "card-one-text" );
	self.card_ten_num = self:Child( "card-ten-num" );
	self.card_ten_button = self:Child( "card-ten-button" );
	self.card_close = self:Child( "card-close" );
	
	self.card_one_free_button = self:Child( "card-card-one-free" );
	
	self.card_close:subscribeEvent("ButtonClick", "onClickCardClose");
	self.card_one_button:subscribeEvent("ButtonClick", "onClickCardOne");
	
	
	self.card_one_free_button:subscribeEvent("ButtonClick", "onClickCardOne");
	self.card_ten_button:subscribeEvent("ButtonClick", "onClickCardTen");
	self.card_back = self:Child("card-back");
	self.card_tips_back = self:Child("card-tips-back");
	self.card_tips_back:subscribeEvent("WindowTouchUp", "onClickCardSkipDisplay");
	self.card_tips_back:SetVisible(false);
	
	-- 
	local times = dataManager.playerData:getNextDrawCardLuckyTimes();
	--self.card_count:SetText("还有^FF0000"..times.."次^FFFFFF必得3星军团");
	
	self.card_text2_num = self:Child("card-text2-num");
	self.card_text1 = self:Child("card-text1");
	self.card_text2 = self:Child("card-text2");
	
	print("times "..times);
	self.card_text1:SetVisible(times == 0);
	self.card_text2:SetVisible(times ~= 0);
	self.card_text2_num:SetText(times);
	
	self.freeTimeHandle = nil;
	self.freeTimeHandle = scheduler.scheduleGlobal(freeTimeTick, 1);
	
	self.card_one_num:SetText(cardData.oneCost);
	self.card_ten_num:SetText(cardData.tenCost);
	
	self.oneType = enum.DRAW_CARD_TYPE.DRAW_CARD_TYPE_INVALID;
	
	self:refreshTime();
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_CRAD})
end

function card:onHide(event)
	
	if(self.freeTimeHandle ~= nil)then
		scheduler.unscheduleGlobal(self.freeTimeHandle)
		self.freeTimeHandle = nil
	end
		
	self:Close();
	
	displayCardLogic.desstroyActor();
	
	homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.CARD);
end

function card:refreshTime()
	local player  = dataManager.playerData;
	
	local nextFreeTime = player:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_NEXT_FREE_DRAW_TIME);
	local waitTime = nextFreeTime - dataManager.getServerTime();
	
	if waitTime > 0 then
		-- 时间还没到
		self.card_one_countdown:SetVisible(true);
		self.card_one_countdown:SetText(formatTime(waitTime, true));
		self.card_one_num:SetText(cardData.oneCost);
		self.oneType = enum.DRAW_CARD_TYPE.DRAW_CARD_TYPE_ONCE;
		self.card_one_button:SetVisible(true);
		self.card_one_free_button:SetVisible(false);
	else
		-- 可以免费抽
		self.card_one_countdown:SetVisible(false);
		self.card_one_num:SetText("免费");
		self.oneType = enum.DRAW_CARD_TYPE.DRAW_CARD_TYPE_FREE;
		self.card_one_button:SetVisible(false);
		self.card_one_free_button:SetVisible(true);
		
	end
end

function card:drawOneCard()
	local player  = dataManager.playerData;
	
	player:drawOneCard();

end

function card:drawTenCard()
	local player  = dataManager.playerData;
	
	player:drawTenCard();

end

function card:hideCardUI()
	if self.card_back then
		self.card_back:SetVisible(false);
		eventManager.dispatchEvent({name = global_event.RESOURCE_HIDE });
	end
	
	if self.card_tips_back then
		self.card_tips_back:SetVisible(true);
	end
	
end

function card:showCardUI()
	if self.card_back then
		--self.card_back:SetVisible(true);
		eventManager.dispatchEvent({name = global_event.RESOURCE_SHOW, level = self._view:GetLevel() });
	end
	
	if self.card_tips_back then
		self.card_tips_back:SetVisible(false);
	end
		
end

return card;
 