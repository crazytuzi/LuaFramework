local getANewCard = class( "getANewCard", layout );

global_event.GETANEWCARD_SHOW = "GETANEWCARD_SHOW";
global_event.GETANEWCARD_HIDE = "GETANEWCARD_HIDE";

function getANewCard:ctor( id )
	getANewCard.super.ctor( self, id );
	self:addEvent({ name = global_event.GETANEWCARD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GETANEWCARD_HIDE, eventHandler = self.onHide});
end

function getANewCard:onShow(event)
	if self._show then
		return;
	end

	-- 升级的数据
	self.obtainNewData = event.data;
	self.currentIndex = 1;
	
	self:Show();

	self.getANewCard_actor = LORD.toActorWindow(self:Child( "getANewCard-actor" ));
	
	self.getANewCard_close = self:Child("getANewCard-close");
	
	self.getANewCard_actor_star = {};
	
	for i=1, 5 do
		self.getANewCard_actor_star[i] = LORD.toStaticImage(self:Child( "getANewCard-actor-star"..i ));
	end
	
	self.getANewCard_actor_name = self:Child( "getANewCard-actor-name" );
	
	self.getANewCard_skill = {};
	self.getANewCard_skill_item = {};
	self.getANewCard_skill_text = {};
	self.getANewCard_skill_name = {};
	
	for i=1, 3 do
		self.getANewCard_skill[i] = LORD.toStaticImage(self:Child( "getANewCard-skill"..i ));
		self.getANewCard_skill_item[i] = LORD.toStaticImage(self:Child( "getANewCard-skill"..i.."-item" ));
		self.getANewCard_skill_text[i] = self:Child( "getANewCard-skill"..i.."-text" );	
		self.getANewCard_skill_name[i] = self:Child( "getANewCard-skill"..i.."-name" );
		
		global.onSkillTipsShow(self.getANewCard_skill_item[i], "skill", "top");
		global.onTipsHide(self.getANewCard_skill_item[i]);
				
	end
	
	function onGetNewCardClickBack(args)
		self:onHide();
	end
	
	self.getANewCard_back = self:Child("getANewCard-back");
	self.getANewCard_back:subscribeEvent("WindowTouchUp", "onGetNewCardClickBack");
	self.getANewCard_close:subscribeEvent("ButtonClick", "onGetNewCardClickBack");
	
	if self.obtainNewData then
		self:updateInfo(self.obtainNewData);
	end
	
end

function getANewCard:onHide(event)

	self.getANewCard_actor_star = nil;
	self.getANewCard_skill = nil;
	self.getANewCard_skill_item = nil;
	self.getANewCard_skill_text = nil;
	self.getANewCard_skill_name = nil;
	self.getANewCard_actor = nil;
	self:Close();
	
	if global.newCardMagicList then
		table.remove(global.newCardMagicList, 1);
	end
		
	global.triggerNewCardAndMagic();

end

function getANewCard:updateInfo(data)
	if self._show then
		self.unitInfo = dataConfig.configs.unitConfig[data.unitID];
		if self.unitInfo then
						
			function newCardFlySkill(window)

				if window then
					local action = LORD.GUIAction:new();
		
					action:addKeyFrame(LORD.Vector3(480, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
					action:addKeyFrame(LORD.Vector3(-20, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
					action:addKeyFrame(LORD.Vector3(20, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 225);
					action:addKeyFrame(LORD.Vector3(-20, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 250);
					action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 275);
					window:playAction(action);
		
				end
								
			end
			
			function newCardFlyStar(window)
		
				function newCardStarFlyEndFunc()
					uiaction.shake(self._view);
					
					LORD.SoundSystem:Instance():playEffect("star.mp3");
				end
			
				if window then
					local action = LORD.GUIAction:new();
		
					action:addKeyFrame(LORD.Vector3(-100, 100, 0), LORD.Vector3(0, 0, 720), LORD.Vector3(5, 5, 0), 1, 0);
					action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
					window:playAction(action);
					
					window:removeEvent("UIActionEnd");
					window:subscribeEvent("UIActionEnd", "newCardStarFlyEndFunc");
		
				end
			end
	
			function delayFlyFunc(dt)
				if self.getANewCard_actor_star and self.getANewCard_actor_star[self.flyIndex] then
					self.getANewCard_actor_star[self.flyIndex]:SetVisible(true);
					newCardFlyStar(self.getANewCard_actor_star[self.flyIndex]);
					
					self.flyIndex = self.flyIndex + 1;
				end
			end

			self.flyIndex = 1;
			local skillflyIndex = 1;
			
			self.getANewCard_actor_name:SetText(self.unitInfo.name);
			for i=1, 3 do
				if self.unitInfo.skill[i] then
					self.getANewCard_skill[i]:SetVisible(false);
					
					local skillinfo = dataConfig.configs.skillConfig[self.unitInfo.skill[i]];
					self.getANewCard_skill_item[i]:SetImage(skillinfo.icon);
					self.getANewCard_skill_item[i]:SetUserData(skillinfo.id);
					self.getANewCard_skill_text[i]:SetText(skillinfo.text);
					self.getANewCard_skill_name[i]:SetText(skillinfo.name);
					
					scheduler.performWithDelayGlobal(function()

						if self.getANewCard_skill and self.getANewCard_skill[skillflyIndex] then
							
							self.getANewCard_skill[skillflyIndex]:SetVisible(self.unitInfo.skill[skillflyIndex] ~= nil   );
							newCardFlySkill(self.getANewCard_skill[skillflyIndex]);
							
							skillflyIndex = skillflyIndex + 1;
						end
										
					end, 1 + i*0.1);
					
				else
					self.getANewCard_skill[i]:SetVisible(false);
				end
			end
						
			for i=1, 5 do				
				
				self.getANewCard_actor_star[i]:SetVisible(false);
				
				if i <= self.unitInfo.starLevel then
					
					scheduler.performWithDelayGlobal(delayFlyFunc, 0.5 + i*0.1);

				end

			end
			
			self.getANewCard_actor:SetActor(self.unitInfo.resourceName, "idle");
			local time = 0.002 * self.getANewCard_actor:SetSkillName("win") - 0.1; --  去掉了100ms
			self.getANewCard_actor:SetRotateY(45);
			
			scheduler.performWithDelayGlobal(function() 
				if self.getANewCard_actor then
					--print("change idle");
					self.getANewCard_actor:SetActor(self.unitInfo.resourceName, "idle");
					self.getANewCard_actor:SetRotateY(45);
				end
			end, time);
		end
	end
end

return getANewCard;
