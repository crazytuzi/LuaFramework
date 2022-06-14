local activitydamageaward = class( "activitydamageaward", layout );

global_event.ACTIVITYDAMAGEAWARD_SHOW = "ACTIVITYDAMAGEAWARD_SHOW";
global_event.ACTIVITYDAMAGEAWARD_HIDE = "ACTIVITYDAMAGEAWARD_HIDE";

function activitydamageaward:ctor( id )
	activitydamageaward.super.ctor( self, id );
	self:addEvent({ name = global_event.ACTIVITYDAMAGEAWARD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ACTIVITYDAMAGEAWARD_HIDE, eventHandler = self.onHide});
end

function activitydamageaward:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.activitydamageaward_damage_most_num = self:Child( "activitydamageaward-damage-most-num" );
	self.activitydamageaward_damage_now_num = self:Child( "activitydamageaward-damage-now-num" );
	self.activitydamageaward_damage_now_raise_num = self:Child( "activitydamageaward-damage-now-raise-num" );
	self.activitydamageaward_button = self:Child( "activitydamageaward-button" );
	self.activitydamageaward_damage_most_num_0 = self:Child( "activitydamageaward-damage-most-num_0" );
	self.activitydamageaward_damage_raise = self:Child( "activitydamageaward-damage-raise" );

	
	function onActivitydamageawardClose()
		self:onHide();
	end
	self.activitydamageaward_button:subscribeEvent("ButtonClick", "onActivitydamageawardClose");
	
	self:update()
end

function activitydamageaward:update()
	
	local rank,_rank = dataManager.hurtRankData:getRanking()
	self.activitydamageaward_damage_most_num_0:SetText( rank )
	local score,_todayScore =  dataManager.hurtRankData:getScore()
	self.activitydamageaward_damage_now_num:SetText( score ) 
	local histroyscore =  dataManager.hurtRankData:getHistroyScore()
	self.activitydamageaward_damage_most_num:SetText( histroyscore )  
	
	--[[
	local num = score - histroyscore
	self.activitydamageaward_damage_now_raise_num:SetText( math.abs(num)  )  
	if(num >= 0 )then
		self.activitydamageaward_damage_raise:SetProperty("Rotate",0)	
	else
		self.activitydamageaward_damage_raise:SetProperty("Rotate",180)
	end
	]]--
	self.activitydamageaward_damage_now_raise_num:SetText( "" ) 
	self.activitydamageaward_damage_raise:SetVisible(false)
end

function activitydamageaward:onUpdate(event)
	self:update();
end

function activitydamageaward:onHide(event)
	self:Close();
end

return activitydamageaward;
