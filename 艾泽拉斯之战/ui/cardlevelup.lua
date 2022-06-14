local cardlevelup = class( "cardlevelup", layout );

global_event.CARDLEVELUP_SHOW = "CARDLEVELUP_SHOW";
global_event.CARDLEVELUP_HIDE = "CARDLEVELUP_HIDE";

function cardlevelup:ctor( id )
	cardlevelup.super.ctor( self, id );
	self:addEvent({ name = global_event.CARDLEVELUP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CARDLEVELUP_HIDE, eventHandler = self.onHide});
end

function cardlevelup:onShow(event)
	if self._show then
		return;
	end
	
	-- 升级的数据
	self.levelupData = event.data;
	
	self:Show();
	
	-- old unit
	self.cardlevelup_item1 = LORD.toStaticImage(self:Child( "cardlevelup-item1" ));
	self.cardlevelup_item1_back = LORD.toStaticImage(self:Child( "cardlevelup-item1-back" ));
	self.cardlevelup_item1_item = LORD.toStaticImage(self:Child( "cardlevelup-item1-item" ));
	self.cardlevelup_item1_name = self:Child( "cardlevelup-item1-name" );
	self.cardlevelup_item1_star = self:Child( "cardlevelup-item1-star" );
	
	self.cardlevelup_item1_star = {};
	
	for i=1, 5 do
		self.cardlevelup_item1_star[i] = LORD.toStaticImage(self:Child( "cardlevelup-item1-star"..i ));
	end
	
	-- new unit
	self.cardlevelup_item2 = LORD.toStaticImage(self:Child( "cardlevelup-item2" ));
	self.cardlevelup_item2_back = LORD.toStaticImage(self:Child( "cardlevelup-item2-back" ));
	self.cardlevelup_item2_item = LORD.toStaticImage(self:Child( "cardlevelup-item2-item" ));
	self.cardlevelup_item2_name = self:Child( "cardlevelup-item2-name" );
	self.cardlevelup_item2_star = self:Child( "cardlevelup-item2-star" );
	
	self.cardlevelup_item2_star = {};
	
	for i=1, 5 do
		self.cardlevelup_item2_star[i] = LORD.toStaticImage(self:Child( "cardlevelup-item2-star"..i ));
	end
	
	-- close button
	self.cardlevelup_close = self:Child( "cardlevelup-close" );
	
	function onCardlevelupClose()
		self:onHide();
	end
	
	self.cardlevelup_close:subscribeEvent("ButtonClick", "onCardlevelupClose");
	
	self.animate = LORD.toAnimateWindow(self:Child("cardlevelup-effect"));
	
	-- attack
	self.cardlevelup_gongji_before = self:Child( "cardlevelup-gongji-num" );
	self.cardlevelup_gongji_after = self:Child( "cardlevelup-gongji-num_0" );
	
	-- hp
	self.cardlevelup_shengming_before = self:Child( "cardlevelup-shengming-num" );
	self.cardlevelup_shengming_after = self:Child( "cardlevelup-shengming-num_2" );
	
	if self.levelupData then
		self:updateInfo(self.levelupData);
	end
	
	
	--	uiaction.shake(self._view);
end

function cardlevelup:onHide(event)
	
		self.cardlevelup_item2_star = nil;
		self:Close();
		
		if global.newCardMagicList then
			table.remove(global.newCardMagicList, 1);
		end
		
		global.triggerNewCardAndMagic();

end

function cardlevelup:updateInfo(data)
		
	function cardFlyStar(window)

		function cardStarFlyEndFunc()
			uiaction.shake(self._view);
			
			LORD.SoundSystem:Instance():playEffect("star.mp3");
		end
	
		if window then
			local action = LORD.GUIAction:new();

			action:addKeyFrame(LORD.Vector3(-100, 100, 0), LORD.Vector3(0, 0, 720), LORD.Vector3(5, 5, 0), 1, 0);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
			window:playAction(action);
			
			window:removeEvent("UIActionEnd");
			window:subscribeEvent("UIActionEnd", "cardStarFlyEndFunc");

		end
	end

	if self._show then
		local oldUnitInfo = dataConfig.configs.unitConfig[data.oldUnitID];
		local newUnitInfo = dataConfig.configs.unitConfig[data.newUnitID];
		
		if oldUnitInfo and newUnitInfo then
		
			self.cardlevelup_item1_back:SetImage(itemManager.getImageWithStar(oldUnitInfo.starLevel));
			self.cardlevelup_item2_back:SetImage(itemManager.getImageWithStar(newUnitInfo.starLevel));
			
			self.cardlevelup_item1_item:SetImage(oldUnitInfo.icon);
			self.cardlevelup_item2_item:SetImage(newUnitInfo.icon);
			
			self.cardlevelup_item1_name:SetText(oldUnitInfo.name);
			self.cardlevelup_item2_name:SetText(newUnitInfo.name);
						
			function delayFlyFunc(index)
				if self.cardlevelup_item2_star and self.cardlevelup_item2_star[index] then
					self.cardlevelup_item2_star[index]:SetVisible(true);
					cardFlyStar(self.cardlevelup_item2_star[index]);
				end
			end
			
			for i=1, 5 do
				if i <= oldUnitInfo.starLevel then
					self.cardlevelup_item1_star[i]:SetVisible(true);
				else
					self.cardlevelup_item1_star[i]:SetVisible(false);
				end
				
				if i <= newUnitInfo.starLevel then
					self.cardlevelup_item2_star[i]:SetVisible(false);
					
					scheduler.performWithDelayGlobal(delayFlyFunc, i*0.1, i);
				else
					self.cardlevelup_item2_star[i]:SetVisible(false);
				end

			end
			
			--self.animate:pause();
			self.animate:play();
			
			self.cardlevelup_gongji_before:SetText(oldUnitInfo.soldierDamage);
			self.cardlevelup_gongji_after:SetText(newUnitInfo.soldierDamage);
			
			self.cardlevelup_shengming_before:SetText(oldUnitInfo.soldierHP);
			self.cardlevelup_shengming_after:SetText(newUnitInfo.soldierHP);
																							
		end
	end
end

return cardlevelup;
