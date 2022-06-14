local battleHint = class( "battleHint", layout );

global_event.BATTLEHINT_SHOW = "BATTLEHINT_SHOW";
global_event.BATTLEHINT_HIDE = "BATTLEHINT_HIDE";

function battleHint:ctor( id )
	battleHint.super.ctor( self, id );
	self:addEvent({ name = global_event.BATTLEHINT_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BATTLEHINT_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.CHANGESCENE_OVER, eventHandler = self.onStart});
end

function battleHint:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	self.battleHint_word = {};
	
	self.event = event;
	
	for i=1, 4 do
		self.battleHint_word[i] = LORD.toStaticImage(self:Child( "battleHint-word"..(i-1) ));
		self.battleHint_word[i]:SetVisible(false);
	end
	
	if event.hintType == "battle" then
		--self.battleHint_word[1]:SetImage("set:battleHint.xml image:zhan");
		--self.battleHint_word[2]:SetImage("set:battleHint.xml image:dou");
		--self.battleHint_word[3]:SetImage("set:battleHint.xml image:kai");
		--self.battleHint_word[4]:SetImage("set:battleHint.xml image:shi");
		for i=1, 4 do
			self.battleHint_word[i]:SetProperty("Font", "battlestart");
		end
	
		self.battleHint_word[1]:SetText("战");
		self.battleHint_word[2]:SetText("斗");
		self.battleHint_word[3]:SetText("开");
		self.battleHint_word[4]:SetText("始");
		
	elseif event.hintType == "prepare" then
		--self.battleHint_word[1]:SetImage("set:battleHint.xml image:zhan");
		--self.battleHint_word[2]:SetImage("set:battleHint.xml image:qian");
		--self.battleHint_word[3]:SetImage("set:battleHint.xml image:zhun");
		--self.battleHint_word[4]:SetImage("set:battleHint.xml image:bei");
		
		for i=1, 4 do
			self.battleHint_word[i]:SetProperty("Font", "battleprepare");
		end
				
		self.battleHint_word[1]:SetText("战");
		self.battleHint_word[2]:SetText("前");
		self.battleHint_word[3]:SetText("准");
		self.battleHint_word[4]:SetText("备");
		
	end
	
end

function battleHint:onHide(event)
	
	self.battleHint_word = nil;
	
	self:Close();
end

function battleHint:onStart()
	
	if self._show then
		
		if self.event.hintType == "battle" then
			LORD.SoundSystem:Instance():playEffect("hint_battleStart.mp3");
		elseif self.event.hintType == "prepare" then
			LORD.SoundSystem:Instance():playEffect("hint_battlePrepare.mp3");
		end
		self:initAnimate();
		
		scheduler.performWithDelayGlobal(function()
			self:onHide();
		end, 1.5);
	end
end

function battleHint:initAnimate()

	function battleHintFly(window)	
		if window then
			local action = LORD.GUIAction:new();

			action:addKeyFrame(LORD.Vector3(200, 0, 0), LORD.Vector3(0, 30, 0), LORD.Vector3(3, 3, 1), 1, 0);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 100);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.5, 1.5, 1.5), 1, 200);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 250);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.5, 1.5, 1.5), 1, 300);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 350);
			
			window:playAction(action);
		end
	end

	function battleHintFlyAway(window)

		if window then
			
			local action = LORD.GUIAction:new();
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
			
			if mirror then
				action:addKeyFrame(LORD.Vector3(1280, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
			else
				action:addKeyFrame(LORD.Vector3(-1280, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
			end
			
			window:playAction(action);
		end
	end
	
	self.flyIndex = 1;
	
	function delayFlyMagicNameFunc(dt)
		
		local flyIndex = self.flyIndex;
		
		if self.battleHint_word and self.battleHint_word[flyIndex] then
			self.battleHint_word[flyIndex]:SetVisible(true);
			battleHintFly(self.battleHint_word[flyIndex]);
			
			self.flyIndex = self.flyIndex + 1;
		end
	end
	
	for i=1, 6 do
		
		scheduler.performWithDelayGlobal(delayFlyMagicNameFunc, i*0.1);
		
		scheduler.performWithDelayGlobal(function() 
			if self.battleHint_word and self.battleHint_word[i] then
				battleHintFlyAway(self.battleHint_word[i]);
			end
		end, 1.3);
		
	end

end

return battleHint;

