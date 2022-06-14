local crusade = class( "crusade", layout );

global_event.CRUSADE_SHOW = "CRUSADE_SHOW";
global_event.CRUSADE_HIDE = "CRUSADE_HIDE";

function crusade:ctor( id )
	crusade.super.ctor( self, id );
	self:addEvent({ name = global_event.CRUSADE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CRUSADE_HIDE, eventHandler = self.onHide});
end

function crusade:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onCrusadeShop()
		global.openShop(enum.SHOP_TYPE.SHOP_TYPE_CONQUEST)
	end

	function onCrusadeRule()
		eventManager.dispatchEvent({name = global_event.RULE_SHOW, battleType = enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE })
	end
	
	function onCrusadeClose()
		self:onHide();
	end
	
	self.crusade_bartender_shop = self:Child( "crusade-bartender-shop" );
	self.crusade_bartender_shop:subscribeEvent("ButtonClick", "onCrusadeShop");
	
	self.crusade_bartender_rule = self:Child( "crusade-bartender-rule" );
	self.crusade_bartender_rule:subscribeEvent("ButtonClick", "onCrusadeRule");
	
	self.crusade_bartender_warning = self:Child( "crusade-bartender-warning" );
	
	self.crusade_close = self:Child( "crusade-close" );
	self.crusade_close:subscribeEvent("ButtonClick", "onCrusadeClose");
	
	
	--self.crusade_waypoint1 = self:Child( "crusade-waypoint1" );
	--self.crusade_waypoint1_chose = LORD.toStaticImage(self:Child( "crusade-waypoint1-chose" ));
	--self.crusade_waypoint1_fight = self:Child( "crusade-waypoint1-fight" );
	--self.crusade_waypoint1_finish = self:Child( "crusade-waypoint1-finish" );
	--self.crusade_waypoint1_closed = LORD.toStaticImage(self:Child( "crusade-waypoint1-closed" ));
	
	self:onUpdateStageInfo();
	
end

function crusade:onHide(event)
	self:Close();
end

function crusade:onUpdateStageInfo()
	if not self._show then
		return;
	end
	
	function onClickCrusadeStage(args)
		
		eventManager.dispatchEvent({name = global_event.CRUSADEINFO_SHOW});
		
	end
	
	function onClickCrusadeStageTips(args)
		
	  local clickImage = LORD.toWindowEventArgs(args).window;
		local userdata = clickImage:GetUserData();
		
		local rect = clickImage:GetUnclippedOuterRect();
		
		eventManager.dispatchEvent({name = global_event.CRUSADETIPS_SHOW, stageIndex = userdata, windowRect = rect });
		
		local crusade_waypoint_closed = LORD.toStaticImage(self:Child( "crusade-waypoint"..userdata.."-closed" ));
		if crusade_waypoint_closed then
			crusade_waypoint_closed:SetImage("set:stage.xml image:box-open");
		end
	end
		
	function onHideCrusadeStageTips(args)

	  local clickImage = LORD.toWindowEventArgs(args).window;
		local userdata = clickImage:GetUserData();
		
		local crusade_waypoint_closed = LORD.toStaticImage(self:Child( "crusade-waypoint"..userdata.."-closed" ));
		if crusade_waypoint_closed then
			crusade_waypoint_closed:SetImage("set:stage.xml image:box");
		end
				
		eventManager.dispatchEvent({name = global_event.CRUSADETIPS_HIDE});
		
	end
	
	for i=1, 8 do
		
		local crusade_waypoint = self:Child( "crusade-waypoint"..i );
		local crusade_waypoint_chose = LORD.toStaticImage(self:Child( "crusade-waypoint"..i.."-chose" ));
		local crusade_waypoint_fight = self:Child( "crusade-waypoint"..i.."-fight" );
		local crusade_waypoint_finish = self:Child( "crusade-waypoint"..i.."-finish" );
		local crusade_waypoint_closed = LORD.toStaticImage(self:Child( "crusade-waypoint"..i.."-closed" ));
		local crusade_wayline1 = LORD.toStaticImage(self:Child( "crusade-wayline1-"..i ));
		local crusade_wayline2 = LORD.toStaticImage(self:Child( "crusade-wayline2-"..i ));
		local crusade_wayline3 = LORD.toStaticImage(self:Child( "crusade-wayline3-"..i ));
		
		crusade_waypoint:SetUserData(i);
		crusade_waypoint:removeEvent("ButtonClick");
		crusade_waypoint:subscribeEvent("ButtonClick", "onClickCrusadeStage");
		
		crusade_waypoint_closed:SetUserData(i);
		crusade_waypoint_closed:removeEvent("WindowTouchDown");
		crusade_waypoint_closed:subscribeEvent("WindowTouchDown", "onClickCrusadeStageTips");		
		crusade_waypoint_closed:removeEvent("WindowTouchUp");
		crusade_waypoint_closed:subscribeEvent("WindowTouchUp", "onHideCrusadeStageTips");	
		crusade_waypoint_closed:removeEvent("MotionRelease");
		crusade_waypoint_closed:subscribeEvent("MotionRelease", "onHideCrusadeStageTips");
		
		if dataManager.crusadeActivityData:isStageCanBattle(i) then
			crusade_waypoint:SetTouchable(true);
			crusade_waypoint:SetVisible(true);
			crusade_waypoint_closed:SetVisible(false);
			crusade_waypoint_chose:SetVisible(true);
			crusade_waypoint_fight:SetVisible(true);
			crusade_waypoint_finish:SetVisible(false);
			crusade_wayline1:SetEnabled(true);
			crusade_wayline2:SetEnabled(true);
			crusade_wayline3:SetEnabled(true);
			
		elseif dataManager.crusadeActivityData:isStageFinish(i) then

			crusade_waypoint:SetTouchable(false);
			crusade_waypoint:SetVisible(true);
			crusade_waypoint_closed:SetVisible(false);
			crusade_waypoint_chose:SetVisible(false);
			crusade_waypoint_fight:SetVisible(false);
			crusade_waypoint_finish:SetVisible(true);
			crusade_wayline1:SetEnabled(true);
			crusade_wayline2:SetEnabled(true);
			crusade_wayline3:SetEnabled(true);
					
		elseif dataManager.crusadeActivityData:isStageNotActive(i) then

			crusade_waypoint:SetTouchable(false);
			crusade_waypoint:SetVisible(false);
			crusade_waypoint_closed:SetVisible(true);
			crusade_waypoint_chose:SetVisible(false);
			crusade_waypoint_fight:SetVisible(false);
			crusade_waypoint_finish:SetVisible(false);
			crusade_wayline1:SetEnabled(false);
			crusade_wayline2:SetEnabled(false);
			crusade_wayline3:SetEnabled(false);
					
		end
		
	end
	
	self.crusade_bartender_warning:SetVisible(dataManager.crusadeActivityData:isStageOver());
	
end

return crusade;
