local corpsget2 = class( "corpsget2", layout );

global_event.CORPSGET2_SHOW = "CORPSGET2_SHOW";
global_event.CORPSGET2_HIDE = "CORPSGET2_HIDE";
global_event.CORPSGET2_UPDATE_BUTTON = "CORPSGET2_UPDATE_BUTTON";

function corpsget2:ctor( id )
	corpsget2.super.ctor( self, id );
	self:addEvent({ name = global_event.CORPSGET2_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CORPSGET2_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.CORPSGET2_UPDATE_BUTTON, eventHandler = self.onUpdateButton});
end

function corpsget2:onShow(event)
	if self._show then
		return;
	end

	-- 十连抽判断升星
	global.triggerNewCardAndMagic();
		
	self:Show();

	function onClickCorpsGetClose()
		self:onHide();
		
		eventManager.dispatchEvent({ name = global_event.CARD_HIDE });
	end
	
	self.corpsget2_corps = self:Child( "corpsget2-corps" );
	self.corpsget2_button = self:Child( "corpsget2-button" );
	
	self.corpsget2_button:subscribeEvent("ButtonClick", "onClickCorpsGetClose");


	function onCorpsget2CardOneMore()
		
		--self:onHide();
		
		local player  = dataManager.playerData;
	
		player:drawOneCard();
				
	end
	
	function onCorpsget2CardTenMore()
		
		--self:onHide();
		
		local player  = dataManager.playerData;
	
		player:drawTenCard();
					
	end
	
	self.corpsget2_button_onemore = self:Child("corpsget2-button_onemore");
	self.corpsget2_button_onemore:subscribeEvent( "ButtonClick", "onCorpsget2CardOneMore");
	self.corpsget2_button_tenmore = self:Child("corpsget2-button_tenmore");
	self.corpsget2_button_tenmore:subscribeEvent( "ButtonClick", "onCorpsget2CardTenMore");
	
		
	self.tenCardData = event.tenCardData;
	
	-- 刷新信息
	local xPos = LORD.UDim(0, 5);
	local yPos = LORD.UDim(0, 5);
	
	local xGap = LORD.UDim(0, 15);
	local yGap = LORD.UDim(0, 15);
	
	local parentWindowSize = self.corpsget2_corps:GetPixelSize();
	for k, v in ipairs(self.tenCardData) do
		local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("corpsget2-"..k, "shipitem.dlg");
		self.corpsget2_corps:AddChildWindow(item);
		
		self:Child("corpsget2-"..k.."_shipitem-bar-back"):SetVisible(false);
		
		local shipitem_fragment = self:Child("corpsget2-"..k.."_shipitem-fragment");
		local shipitem_fragment_number = self:Child("corpsget2-"..k.."_shipitem-fragment-number");
		local shipitem_new = self:Child("corpsget2-"..k.."_shipitem-new");
		local equity = LORD.toStaticImage(self:Child("corpsget2-"..k.."_shipitem-equity"));
		local name = self:Child("corpsget2-"..k.."_shipitem-name");
		
		equity:SetImage("");
		
		shipitem_fragment:SetVisible(not v.firstGain);
		shipitem_new:SetVisible(v.firstGain);
		shipitem_fragment_number:SetText("+"..v.cardExp);
		
		item:SetXPosition(xPos);
		item:SetYPosition(yPos);
		
		xPos = xPos + item:GetWidth() + xGap;
		
		local xRight = xPos + item:GetWidth();
		if xRight.offset > parentWindowSize.x then
			xPos = LORD.UDim(0, 5);
			yPos = yPos + item:GetHeight() + yGap;
		end
		
		local cardType = v.cardID;
		local cardExp = v.cardExp;
		
		local star = cardData.getStarByExp(cardExp);
		local unitID = cardData.getUnitIDByTypeAndStar(cardType, star);
		local unitInfo = dataConfig.configs.unitConfig[unitID];
		
		if unitInfo then
		
			name:SetText(unitInfo.name);
			name:SetVisible(true);
		
			LORD.toStaticImage(self:Child("corpsget2-"..k.."_shipitem-head")):SetImage(unitInfo.icon);
			self:Child("corpsget2-"..k.."_shipitem-chose"):SetVisible(false);
			self:Child("corpsget2-"..k.."_shipitem-ship"):SetVisible(false);
			
			equity:SetImage(itemManager.getImageWithStar(unitInfo.starLevel));
			
			for i=1, 6 do
				if i <= star then
					self:Child("corpsget2-"..k.."_shipitem-star"..i):SetVisible(true);
				else
					self:Child("corpsget2-"..k.."_shipitem-star"..i):SetVisible(false);
				end
			end
			
		end
		
	end
	
end

function corpsget2:onHide(event)
	if not self._show then
		return;
	end
	
	self:Close();
	
	--eventManager.dispatchEvent({ name = global_event.CARD_HIDE });
	
end

function corpsget2:onUpdateButton(event)
	
	if not self._show then
		return;
	end
	
	local corpsget2_button = self:Child( "corpsget2-button" );
	corpsget2_button:SetEnabled(event.state);
			
end

return corpsget2;
