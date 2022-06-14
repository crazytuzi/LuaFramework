local bug = class( "bug", layout );

global_event.BUG_SHOW = "BUG_SHOW";
global_event.BUG_HIDE = "BUG_HIDE";

function bug:ctor( id )
	bug.super.ctor( self, id );
	self:addEvent({ name = global_event.BUG_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BUG_HIDE, eventHandler = self.onHide});
end

function bug:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	self.bug_button_OK = self:Child( "bug-button-OK" );
	
	function onbugUpLoadClick()	
		self.text = self.bug_input:GetText()
		self:onHide()
		
		function sendBugToServer()
			BUG_REPORT.sendBattleData(self.text)
		end
		
		scheduler.performWithDelayGlobal(sendBugToServer,0.1)
		
	end

	self.bug_button_OK:subscribeEvent("ButtonClick", "onbugUpLoadClick");


	
	self.bug_input = self:Child( "bug-bug-input" );
end

function bug:onHide(event)
	self:Close();
end

return bug;
