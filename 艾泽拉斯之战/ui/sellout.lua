local sellout = class( "sellout", layout );

global_event.SELLOUT_SHOW = "SELLOUT_SHOW";
global_event.SELLOUT_HIDE = "SELLOUT_HIDE";

function sellout:ctor( id )
	sellout.super.ctor( self, id );
	self:addEvent({ name = global_event.SELLOUT_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SELLOUT_HIDE, eventHandler = self.onHide});
end

function sellout:onShow(event)
	if self._show then
		return;
	end
	self.filter = event.filter
	self:Show();

	--[[self.sellout_text_lv1 = self:Child( "sellout-text-lv1" );
	self.sellout_text_lv2 = self:Child( "sellout-text-lv2" );--]]
	self.sellout_textinfo = self:Child( "sellout-textinfo" );
	
	self.sellout_button1 = self:Child( "sellout-button1" );
	self.sellout_button2 = self:Child( "sellout-button2" );
	self.sellout_button3 = self:Child( "sellout-button3" );
	local level = dataManager.playerData:getLevel() - 5
	
	if(level < 0)then
		level = 0
	end	
	
	--[[self.sellout_text_lv1:SetText(level)
	self.sellout_text_lv2:SetText(level)--]]
	if self.filter == enum.ITEM_TYPE.ITEM_TYPE_DEBRIS then
	self.sellout_textinfo:SetText("批量卖出装备等级不超过^FF9F03"..level.."^FFFFFF级的装备碎片");
	elseif self.filter == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
	self.sellout_textinfo:SetText("批量卖出装备等级不超过^FF9F03"..level.."^FFFFFF级的装备");
	end
	
	function onClickSelloutGreen()
		self:onClickSellout(1)
	end
	function onClickSelloutBule()
		self:onClickSellout(2)
	end
	function onClickSelloutViolet()
		self:onClickSellout(3)
	end

	self.sellout_button1:subscribeEvent("ButtonClick", "onClickSelloutGreen")
	self.sellout_button2:subscribeEvent("ButtonClick", "onClickSelloutBule")
	self.sellout_button3:subscribeEvent("ButtonClick", "onClickSelloutViolet")
	self.sellout_close = self:Child( "sellout-close" );
	
	function onClickSelloutClose()	
		self:onHide()
	end
	
	self.sellout_close:subscribeEvent("ButtonClick", "onClickSelloutClose")

end

function sellout:onClickSellout(star)
		 self:onHide()
		
	local nums = dataManager.bagData:getVecItemNums(enum.BAG_TYPE.BAG_TYPE_BAG)
	local vec = dataManager.bagData:getVec(enum.BAG_TYPE.BAG_TYPE_BAG)
	local t = table.keys(vec)
	local itemIndex = 0
	local level = dataManager.playerData:getLevel() - 5
	if(level < 0)then
		level = 0
	end	
	local filteritem = {}
	
	-- and ( item:isDebris( ) or item:isEquip( ))
	for i = 1,nums do	
		local item = dataManager.bagData:getItem(t[i],enum.BAG_TYPE.BAG_TYPE_BAG)
		
		 if  (item  and  item:filter(self.filter))then	
				if(self.filter == enum.ITEM_TYPE.ITEM_TYPE_DEBRIS  )then
					if(  item:getProductIsEquip() and   item:getProductStar()<= star  and item:getProductUseLevel() <= level  )then
						table.insert(filteritem,item)	
					end
				else
					if(item:getStar()<= star  and item:getUseLevel() <= level  )then
						table.insert(filteritem,item)
					end
				end
		end
	end
	local send = {}	
	for i,v in pairs(filteritem)do
			local data = {}
			data.position = v:getPos()
			data.itemCount = v:getCount()
			table.insert(send,data)
	end
	if( #send > 0 )then
		sendTrade(send)
	end
end

function sellout:onHide(event)
	self:Close();
end

return sellout;
