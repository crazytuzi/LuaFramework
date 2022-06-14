
local loginuiclass = class("loginuiclass",layout)

function loginuiclass:ctor( id )
	 loginuiclass.super.ctor(self,id)	
	 self:addEvent({ name = global_event.LOGIN_UI_SHOW, eventHandler = self.onSHOW})				
	 self:addEvent({ name = global_event.LOGIN_UI_HIDE, eventHandler = self.onHide})
end	
 
function sleep(n)
   local t0 = os.clock()
   while os.clock() - t0 <= n do end
end

function loginuiclass:onSHOW(event)

	 self:Show();	
	  
	 function  OnButtonLoginClick()
	 
      game.EnterProcess( game.GAME_STATE_MAIN)
      self:Close();
 
	  networkengine:connect("127.0.0.1:7903");
 
	 end

	self:Child("login-start"):subscribeEvent("ButtonClick", "OnButtonLoginClick")
 	
end

function loginuiclass:onHide(event)
	self:Close();
end

return loginuiclass