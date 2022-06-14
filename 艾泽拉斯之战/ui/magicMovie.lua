local magicMovie = class( "magicMovie", layout );

global_event.MAGICMOVIE_SHOW = "MAGICMOVIE_SHOW";
global_event.MAGICMOVIE_HIDE = "MAGICMOVIE_HIDE";

function magicMovie:ctor( id )
	magicMovie.super.ctor( self, id );
	self:addEvent({ name = global_event.MAGICMOVIE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.MAGICMOVIE_HIDE, eventHandler = self.onHide});
end

function magicMovie:onShow(event)
	if self._show then
		return;
	end

	-- 以英雄头像的中心做镜像
	function mirrorX(x, uiwidth, mirror)
		if mirror then
			local half = uiwidth / 2;
			return  640 + (640 - (x + half)) - half;
		else
			return x;
		end
	end
		
	self:Show();

	self.magicMovie_back = LORD.toStaticImage(self:Child( "magicMovie-back" ));
	self.magicMovie_head = LORD.toStaticImage(self:Child( "magicMovie-head" ));
	self.magicMovie_effect = self:Child( "magicMovie-effect" );
	self.magicMovie_name = {};
	self.magicMovie_name_effect = self:Child("magicMovie-name-effect");
	self.magicMovie_magiceffect = self:Child("magicMovie-magiceffect");
	
	local nameText = LORD.GUIString("");
	
	self.nameLength = 0;
	
	local xposlist = {};
	if dataConfig.configs.magicConfig[event.magicid] then
		nameText = LORD.GUIString(dataConfig.configs.magicConfig[event.magicid].name);
		self.nameLength = nameText:length();
	end
			
	for i=1, 6 do
		self.magicMovie_name[i] = self:Child( "magicMovie-name"..i );	
		self.magicMovie_name[i]:SetVisible(false);
		
		table.insert(xposlist, self.magicMovie_name[i]:GetXPosition().offset);
	end

	for i=1, 6 do
		
		if event.force ~= enum.FORCE.FORCE_ATTACK then
			local x = xposlist[7-i];
			local width = self.magicMovie_name[7-i]:GetWidth().offset;
			self.magicMovie_name[i]:SetXPosition(LORD.UDim(0, mirrorX(x, width, true)));
		end
		
		if i <= nameText:length() then
			self.magicMovie_name[i]:SetText(nameText:substr(i-1, 1):c_str());
		else
			self.magicMovie_name[i]:SetText("");
		end
		
	end
	
	-- certer aligned
	local width = self.magicMovie_name[1]:GetWidth().offset;
	local offset = (6 - nameText:length()) * width * 0.5;
	for i=1, 6 do
		local xpos = self.magicMovie_name[i]:GetXPosition();
		
		--print(" i "..i.." x "..xpos.offset + offset);
		self.magicMovie_name[i]:SetXPosition(LORD.UDim(0, xpos.offset + offset));
	end
			
	self.magicMovie_back:SetVisible(false);
	self.magicMovie_head:SetVisible(false);
	
	self.backAnimate = uianimate.new();
	local rate = sceneManager.battlePlayer():getSpeed()/SPEED_UP_GAME[1]
	---------------------------------------------------
	self.backAnimate:addFrame(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, -56)), LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(0, 0)), 1, 0);
	self.backAnimate:addFrame(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, -56)), LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(0, 100)), 1,rate*0.05);
	self.backAnimate:addFrame(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, -56)), LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(0, 100)), 1, rate*0.09);
	self.backAnimate:addFrame(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, -56)), LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(0, 300)), 1, rate*0.15);
	self.backAnimate:addFrame(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, -56)), LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(0, 280)), 1, rate*1.0);
	self.backAnimate:addFrame(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, -56)), LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(0, 280)), 1, rate*1.4);
	
	self.backAnimate:addFrame(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, -56)), LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(0, 50)), 1, rate*1.45);
	self.backAnimate:addFrame(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, -56)), LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(0, 50)), 1, rate*1.49);
	self.backAnimate:addFrame(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, -56)), LORD.UVector2(LORD.UDim(1, 0), LORD.UDim(0, 0)), 1, rate*1.5);
	
	-----------------------------------------------

	local attackKing = dataManager.battleKing[enum.FORCE.FORCE_ATTACK]
	local defenseKing = dataManager.battleKing[enum.FORCE.FORCE_GUARD]
	
	local mirror = false;
	
	-- 根据force，初始化头像的动画帧，防守方是进攻方的镜像
	if event.force == enum.FORCE.FORCE_ATTACK then
		self.magicMovie_head:SetProperty("RotateY", 180);
		self.magicMovie_head:SetImage(global.getHalfBodyImage( attackKing:getHeadIcon()));
		
	else
		
		self.magicMovie_head:SetProperty("RotateY", 0);		
		self.magicMovie_head:SetImage(global.getHalfBodyImage( defenseKing:getHeadIcon())) 
		
		mirror = true;
	end
	
	
	self:initHeadAnimate(mirror);
	self:initNameAnimate(mirror);
	
	local nameEffectX = self.magicMovie_name_effect:GetXPosition();
	local nameEffectWidth = self.magicMovie_name_effect:GetWidth();
	
	--print("mirrorX(nameEffectX.offset, nameEffectWidth.offset, mirror) "..mirrorX(nameEffectX.offset, nameEffectWidth.offset, mirror));
	if mirror then
		self.magicMovie_name_effect:SetXPosition(LORD.UDim(0, 0));
	end
	
	self.magicMovie_name_effect:SetEffectName("");
	
	scheduler.performWithDelayGlobal(function() 
		if self.magicMovie_name_effect then
			self.magicMovie_name_effect:SetEffectName("banshenxiang_dianhu.effect");
		end
	end, 0.6* sceneManager.battlePlayer():getSpeed()/SPEED_UP_GAME[1] );
	
	--name------------------------------------------------------------------------
	
	function magicMovieTimerFunc(dt)
		self:update(dt);
	end
	
	self.time = 0;
	
	
	LORD.SoundSystem:Instance():playEffect("magicMovie.mp3");

	self.effectTime = 0;
	
	scheduler.performWithDelayGlobal(function()
	
		if self.magicMovie_back then
			self.magicMovie_back:SetVisible(false);
		end
		
		if self.magicMovie_name then
			for k,v in pairs(self.magicMovie_name) do
				if v then
					v:SetVisible(false);
				end
			end
		end
		
		-- todo 需要获取特效的播放时间
		if self.magicMovie_magiceffect and dataConfig.configs.magicConfig[event.magicid] and dataConfig.configs.magicConfig[event.magicid].uiGfxName then
			self.effectTime = self.magicMovie_magiceffect:SetEffectName(dataConfig.configs.magicConfig[event.magicid].uiGfxName);
		end
	end, 1.5 * sceneManager.battlePlayer():getSpeed()/SPEED_UP_GAME[1] )
	
	self.timerHandler = scheduler.scheduleGlobal(magicMovieTimerFunc, 0);
	
end

function magicMovie:onHide(event)
	
	self.magicMovie_back = nil;
	self.backAnimate:destroy();
	self.backAnimate = nil;
	self.magicMovie_name = nil;
	self.magicMovie_name_effect = nil;
	self.magicMovie_magiceffect = nil;
	
	if self.timerHandler then
		scheduler.unscheduleGlobal(self.timerHandler);
	end
	
	self:Close();
	
	if sceneManager.battlePlayer() then
		sceneManager.battlePlayer():setWaitMagicMovieFlag(false);
		sceneManager.battlePlayer():goOnPlayAction();
	end

end

function magicMovie:update(dt)

	self.magicMovie_back:SetVisible(true);
	self.magicMovie_head:SetVisible(true);
	
	local frame = self.backAnimate:getFrame(self.time);
	if frame then
		self.magicMovie_back:SetPosition(frame:getPosition());
		self.magicMovie_back:SetSize(frame:getSize());
	end
	
	local frame2 = self.headAnimate:getFrame(self.time);
	if frame2 then
		self.magicMovie_head:SetPosition(frame2:getPosition());
		self.magicMovie_head:SetSize(frame2:getSize());		
	end
	local rate = sceneManager.battlePlayer():getSpeed()/SPEED_UP_GAME[1]
	self.time =  self.time + dt/rate ;
	
	if self.time >  (1.5 + self.effectTime) then
		self:onHide();
	end
end

function magicMovie:initNameAnimate(mirror)
	local rate = sceneManager.battlePlayer():getSpeed()/SPEED_UP_GAME[1]
	function magicMovieFly(window)

		function magicMovieFlyEndFunc()
			--uiaction.shake(self._view);
		end
		
		if window then
			local action = LORD.GUIAction:new();

			action:addKeyFrame(LORD.Vector3(200, 0, 0), LORD.Vector3(0, 30, 0), LORD.Vector3(3, 3, 1), 1, 0);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, rate*100);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.5, 1.5, 1.5), 1, rate*200);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, rate*250);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.5, 1.5, 1.5), 1, rate*300);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, rate*350);
			
			window:playAction(action);
			
			window:removeEvent("UIActionEnd");
			window:subscribeEvent("UIActionEnd", "magicMovieFlyEndFunc");

		end
	end

	function magicMovieFlyAway(window)

		if window then
			
			local action = LORD.GUIAction:new();
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
			
			if mirror then
				action:addKeyFrame(LORD.Vector3(1280, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, rate*200);
			else
				action:addKeyFrame(LORD.Vector3(-1280, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, rate*200);
			end
			
			window:playAction(action);
		end
	end
	
	self.flyIndex = 1;
	
	function delayFlyMagicNameFunc(dt)
		
		local flyIndex = self.flyIndex;

		if flyIndex > self.nameLength then
			return;
		end
		
		if self.magicMovie_name and self.magicMovie_name[flyIndex] then
			self.magicMovie_name[flyIndex]:SetVisible(true);
			magicMovieFly(self.magicMovie_name[flyIndex]);
			
			self.flyIndex = self.flyIndex + 1;
		end
	end
	
	for i=1, 6 do
		
		scheduler.performWithDelayGlobal(delayFlyMagicNameFunc, rate*i*0.1);
		
		scheduler.performWithDelayGlobal(function() 
			if self.magicMovie_name and self.magicMovie_name[i] then
				magicMovieFlyAway(self.magicMovie_name[i]);
			end
		end, rate*1.3);
		
	end
				
end

function magicMovie:initHeadAnimate(mirror)

	self.headAnimate = uianimate.new();
	local rate = sceneManager.battlePlayer():getSpeed()/SPEED_UP_GAME[1]
	local radius = 20;
	self.headWidth = self.magicMovie_head:GetWidth().offset;
	self.headHeight = self.magicMovie_head:GetHeight().offset;
		
	self.headAnimate:addFrame(LORD.UVector2(LORD.UDim(0, mirrorX(-500, self.headWidth, mirror)), LORD.UDim(0, 0)), LORD.UVector2(LORD.UDim(0, self.headWidth), LORD.UDim(0, self.headHeight)), 1, 0);
	self.headAnimate:addFrame(LORD.UVector2(LORD.UDim(0, mirrorX(radius, self.headWidth, mirror)), LORD.UDim(0, 0)), LORD.UVector2(LORD.UDim(0, self.headWidth), LORD.UDim(0, self.headHeight)), 1, rate*0.15);
	--self.headAnimate:addFrame(LORD.UVector2(LORD.UDim(0, mirrorX(-radius, self.headWidth, mirror)), LORD.UDim(0, 0)), LORD.UVector2(LORD.UDim(0, self.headWidth), LORD.UDim(0, self.headHeight)), 1, rate*0.3);
	self.headAnimate:addFrame(LORD.UVector2(LORD.UDim(0, mirrorX(-radius, self.headWidth, mirror)), LORD.UDim(0, 0)), LORD.UVector2(LORD.UDim(0, self.headWidth), LORD.UDim(0, self.headHeight)), 1, rate*0.7);
	
	for angle = 180, 300, 30 do
		local y = -radius * math.sin(math.rad (angle));
		local x = radius * math.cos(math.rad (angle));
		
		self.headAnimate:addFrame(LORD.UVector2(LORD.UDim(0, mirrorX(x, self.headWidth, mirror)), LORD.UDim(0, y)), LORD.UVector2(LORD.UDim(0, self.headWidth), LORD.UDim(0, self.headHeight)), 1,  rate*(0.7 + 1.05 * (angle-180) / 180));
	end
	
	self.headAnimate:addFrame(LORD.UVector2(LORD.UDim(0, mirrorX(1280, self.headWidth, mirror)), LORD.UDim(0, 30)), LORD.UVector2(LORD.UDim(0, self.headWidth), LORD.UDim(0, self.headHeight)), 1, rate*1.5);
			
end

return magicMovie;
