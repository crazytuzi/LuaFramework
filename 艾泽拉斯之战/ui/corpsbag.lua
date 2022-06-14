local corpsbag = class( "corpsbag", layout );

global_event.CORPSBAG_SHOW = "CORPSBAG_SHOW";
global_event.CORPSBAG_HIDE = "CORPSBAG_HIDE";

function corpsbag:ctor( id )
	corpsbag.super.ctor( self, id );
	self:addEvent({ name = global_event.CORPSBAG_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CORPSBAG_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_INSTANCE, eventHandler = self.onHide})	
end

function corpsbag:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.corpsbag_tab = {};
	self.corpsbag_tab_new = {};
	self.corpsbag_tab_new_n = {};
	self.selectTabFlag = {};
	
	-- 种族映射表
	local raceMap = {
		[1] = -1,
		[2] = 0,
		[3] = 1,
		[4] = 2,
		[5] = 3,
	};
	
	for i=1, 5 do
	
		self.corpsbag_tab[i] = LORD.toRadioButton(self:Child( "corpsbag-tab"..i ));
		self.corpsbag_tab[i]:SetUserData(raceMap[i]);
		self.corpsbag_tab[i]:subscribeEvent("RadioStateChanged", "onSelectRace");
	
		if i==1 then
			self.corpsbag_tab_new[i] = false;
			self.corpsbag_tab_new_n[i] = false;
		else
			self.corpsbag_tab_new[i] = self:Child("corpsbag-tab"..i.."-new");
			self.corpsbag_tab_new_n[i] = self:Child("corpsbag-tab"..i.."-new-n");
			local count = cardData.getNewGainedCountByRace(raceMap[i]);
			
			self.corpsbag_tab_new[i]:SetVisible(count > 0);
			self.corpsbag_tab_new_n[i]:SetText(count);
		end
		
		self.selectTabFlag[raceMap[i]] = false;
	end
	
	self.corpsbag_scroll = LORD.toScrollPane(self:Child( "corpsbag-scroll" ));
	self.corpsbag_scroll:init();
	
	self.corpsbag_close = self:Child( "corpsbag-close" );
	
	self.corpsbag_close:subscribeEvent( "ButtonClick", "onClickClose" );
	
	function onClickClose()
		self:onHide();
	end
	
	function onSelectRace(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		if window:IsSelected() then
			local race = window:GetUserData();
			self.selectTabFlag[race] = true;
			self:onUpdateRace(race);
			local index = table.keyOfItem(raceMap,race)	
			if(self.corpsbag_tab_new[index] )then
				self.corpsbag_tab_new[index]:SetVisible(false)	
			end
		end
	end
	
	function onClickCorpsBagUnit(args)
		local window = LORD.toWindowEventArgs(args).window;
		local id = window:GetUserData();
		self:onShowUnitInfo(id);
	end
	
	self.corpsbag_tab[1]:SetSelected(true);
		
end

function corpsbag:onHide(event)
	self:Close();
	if(self.selectTabFlag)then
		for k,v in pairs(self.selectTabFlag) do
			if v then
				cardData.setNewGainedByRace(k);
			end
		end
	end
end

function corpsbag:onUpdateRace(race)
	
	self.corpsbag_scroll:ClearAllItem();
	self.corpsbag_scroll:InitializePos();
	
	local scrollPanelSize = self.corpsbag_scroll:GetPixelSize();
	
	local index = 1;
	local xPosition = LORD.UDim(0, 5);
	local yPosition = LORD.UDim(0, 5);
	for k,v in ipairs(cardData.cardlist) do
		
		if race == dataConfig.configs.unitConfig[v.cardType].race or race < 0 then
						
			local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("corpsbag-"..index, "shipitem.dlg");

			item:SetXPosition(xPosition);
			item:SetYPosition(yPosition);				
			self.corpsbag_scroll:additem(item);
			
			local icon = LORD.toStaticImage(self:Child("corpsbag-"..index.."_shipitem-head"));
			local shipIcon = LORD.toStaticImage(self:Child("corpsbag-"..index.."_shipitem-ship"));
			local selectFrame = LORD.toStaticImage(self:Child("corpsbag-"..index.."_shipitem-chose"));
			local fakeWindow = self:Child("corpsbag-"..index.."_shipitem-fake");
			local expBar = self:Child("corpsbag-"..index.."_shipitem-bar-back");
			local expProgress = self:Child("corpsbag-"..index.."_shipitem-bar");
			local expPorgressText = self:Child("corpsbag-"..index.."_shipitem-bar-text");
			local newCard = self:Child("corpsbag-"..index.."_shipitem-new");
			local equity = LORD.toStaticImage(self:Child("corpsbag-"..index.."_shipitem-equity"));
			
			local name = self:Child("corpsbag-"..index.."_shipitem-name");
			name:SetVisible(false);
			
			equity:SetImage(itemManager.getImageWithStar(0));
			
			newCard:SetVisible(v:getNewGainedFlagInBag() > 0);			
		
			-- 接收事件
			fakeWindow:SetVisible(true);
			fakeWindow:subscribeEvent("WindowTouchUp", "onClickCorpsBagUnit");
			
			local starImage = {};
			for i=1, 6 do
				starImage[i] = self:Child("corpsbag-"..index.."_shipitem-star"..i);
				starImage[i]:SetVisible(false);
			end
			
			local unitInfo = {};
			if v.star > 0 then
				unitInfo = dataConfig.configs.unitConfig[v.unitID];
				
				equity:SetImage(itemManager.getImageWithStar(unitInfo.starLevel));
				
				item:SetEnabled(true);
				icon:SetEnabled(true);
				expBar:SetVisible(false);
				
				for i=1, v.star do
					starImage[i]:SetVisible(true);
				end
				
				fakeWindow:SetUserData(v.cardType);
			else
				unitInfo = dataConfig.configs.unitConfig[v.cardType];
				item:SetEnabled(false);
				icon:SetEnabled(false);
				
				fakeWindow:SetVisible(false);
				expBar:SetVisible(true);
				local currentExp = v:getCurrentExp();
				local nextExp = v:getNextExp();
				local percent = currentExp / nextExp;
				expProgress:SetProperty("Progress", percent);
				expPorgressText:SetText(currentExp.."/"..nextExp);
				
				--fakeWindow:SetUserData(v.cardType);
			end
			
			icon:SetImage(unitInfo.icon);
			shipIcon:SetVisible(false);
			selectFrame:SetVisible(false);

			xPosition = xPosition + item:GetWidth() + LORD.UDim(0, 5);
			local xRightPosition = xPosition + item:GetWidth();
			if xRightPosition.offset > scrollPanelSize.x then
				xPosition = LORD.UDim(0,5);
				yPosition = yPosition + item:GetHeight() + LORD.UDim(0, 5);
			end		
			
			index = index + 1;
		end
		
	end
	
end

function corpsbag:onShowUnitInfo(cardType)
	--print("onShowUnitInfo");
	eventManager.dispatchEvent({name = global_event.CROPSINFOR_SHOW, displayCardType = cardType});
	
	local cardInstance = cardData.getCardInstance(cardType);
	if cardInstance then
		cardData.playVoiceByUnitID(cardInstance:getUnitID());
	end
end

return corpsbag;
