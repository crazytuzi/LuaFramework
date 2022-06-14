--wz

local testclass = class("testclass",layout)

function testclass:ctor( id )
	 testclass.super.ctor(self,id)	
	 self:addEvent({ name = global_event.TEST_SHOW, eventHandler = self.onSHOW})	
	 self:addEvent({ name = global_event.TEST_UPDATE, eventHandler = self.onUpdate})			
end	

 

function testclass:onSHOW(event)

	 self:Show();	
	  
	  function  OnButton1Click()
		trace("---click 1")
		sceneManager.actor[1]:PlaySkill("attack", false, false, 1);
	end
		
	  function  OnButton2Click()
		trace("---click 2")		
		sceneManager.actor[1]:PlaySkill("run", false, false, 1);
	  end
 
	self:Child("button1"):subscribeEvent("ButtonClick", "OnButton1Click")
	self:Child("button2"):subscribeEvent("ButtonClick", "OnButton2Click");	
 	

end

function testclass:onUpdate(event)
	if( false == self._show)then return end
	self:Child("LuaVM"):SetProperty("Text",tostring(event.vm))
	
end
	


return testclass