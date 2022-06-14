local itemsale = class( "itemsale", layout );

global_event.ITEMSALE_SHOW = "ITEMSALE_SHOW";
global_event.ITEMSALE_HIDE = "ITEMSALE_HIDE";

function itemsale:ctor( id )
	itemsale.super.ctor( self, id );
	self:addEvent({ name = global_event.ITEMSALE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ITEMSALE_HIDE, eventHandler = self.onHide});
end

function itemsale:onShow(event)
	self.curSelItem = event.selItem
	if self._show then
		return;
	end

	self:Show();
	self.itemsale_item_container = LORD.toStaticImage(self:Child( "itemsale--item-container" ));
	
	self.itemsale_item = LORD.toStaticImage(self:Child( "itemsale-item" ));
	self.itemsale_item_stlevel = LORD.toStaticImage(self:Child( "itemsale-item-stlevel" ));
 
	self.itemsale_item_image = LORD.toStaticImage(self:Child( "itemsale-item-image" ));
	self.itemsale_item_name = self:Child( "itemsale-item-name" );
	self.itemsale_item_delete = self:Child( "itemsale-item-delete" );
	
	self.itemsale_item_add = self:Child( "itemsale-item-add" );
	
	
	self.itemsale_get_num = self:Child( "itemsale-get-num" );
	self.itemsale_button = self:Child( "itemsale-button" );
	self.itemsale_close = self:Child( "itemsale-close" );
	self.itemsale_item_num= self:Child( "itemsale-item-num" );
	
	self.itemsale_getone_num = self:Child( "itemsale-getone-num" );
	

		 
	function on_itemsale_close_click()
		self:onHide()
	end	
	self.itemsale_close:subscribeEvent("ButtonClick", "on_itemsale_close_click");	
	
	
	
	
	function on_itemsale_Max_click()
		local item = itemManager.getItem(self.curSelItem) 
		local itemc = item:getCount()
		if(self.itemCount < itemc)then
			self.itemCount = itemc
			self:update()
		end
	end	
	self.itemsale_item_maxbutton = self:Child( "itemsale-item-maxbutton" );
	self.itemsale_item_maxbutton:subscribeEvent("ButtonClick", "on_itemsale_Max_click");	
	
	function on_itemsale_button_click()
		self:onHide()
		local item = itemManager.getItem(self.curSelItem) 
		local pos = item:getPos()
		local data = {}
		data.position = pos
		data.itemCount = self.itemCount
		sendTrade({data})
	end	
		
	self.itemsale_button:subscribeEvent("ButtonClick", "on_itemsale_button_click");	
	
	--[[function on_itemsale_item_delete_click()
		if(self.itemCount > 1)then
			self.itemCount = self.itemCount -1
			self:update()
		end						
	end
	self.itemsale_item_delete:subscribeEvent("ButtonClick", "on_itemsale_item_delete_click");	
	]]--
	
	
	
	function onitemsale_item_del_Hold()	
		if(self.itemCount > 1)then
			self.itemCount = self.itemCount -1
			self:update()
		end			
		
		print("onitemsale_item_del_Hold")		
	end	
	
	function on_itemsale_item_delete_down()
		
		if(self.itemHoldHandleAdd ~= nil)then
			scheduler.unscheduleGlobal(self.itemHoldHandleAdd)
			self.itemHoldHandleAdd = nil
		end	
		
		if(self.itemHoldHandleDel ~= nil)then
			scheduler.unscheduleGlobal(self.itemHoldHandleDel)
			self.itemHoldHandleDel = nil
		end	
		if(self.itemHoldHandleDel == nil)then
			self.itemHoldHandleDel = scheduler.scheduleGlobal(onitemsale_item_del_Hold,0.1)
		end		
		
		print("on_itemsale_item_delete_down")		
	end
	function on_itemsale_item_delete_up()
		if(self.itemHoldHandleDel ~= nil)then
			scheduler.unscheduleGlobal(self.itemHoldHandleDel)
			self.itemHoldHandleDel = nil
		end	
		onitemsale_item_del_Hold()
				print("on_itemsale_item_delete_up")	
	end
 


		function on_itemsale_item_delete_up__(args)
			
			on_itemsale_item_delete_up()
			
			local clickImage = LORD.toWindowEventArgs(args).window		
			clickImage:SetScale(  LORD.Vector3(1,1,1))
			
		end

		function on_itemsale_item_delete_down__(args)
			on_itemsale_item_delete_down()
			local clickImage = LORD.toWindowEventArgs(args).window		
			clickImage:SetScale(  LORD.Vector3(1.2,1.2,1.2))
			
		end
	self.itemsale_item_delete:subscribeEvent("WindowTouchUp", "on_itemsale_item_delete_up__")
	
	self.itemsale_item_delete:subscribeEvent("WindowTouchDown", "on_itemsale_item_delete_down__")
	
	self.itemsale_item_delete:subscribeEvent("WindowLongTouchCancel", "on_itemsale_item_delete_up__")	
	
	
	
	
	
	
	function onitemsale_item_Hold()
		local item = itemManager.getItem(self.curSelItem) 
		local itemc = item:getCount()
		if(self.itemCount  < itemc)then
			self.itemCount = self.itemCount + 1	
			self:update()
		end
		
	end	
	
	function on_itemsale_item_image_down()
		if(self.itemHoldHandleDel ~= nil)then
			scheduler.unscheduleGlobal(self.itemHoldHandleDel)
			self.itemHoldHandleDel = nil
		end	
		if(self.itemHoldHandleAdd ~= nil)then
			scheduler.unscheduleGlobal(self.itemHoldHandleAdd)
			self.itemHoldHandleAdd = nil
		end	
		if(self.itemHoldHandleAdd == nil)then
			self.itemHoldHandleAdd = scheduler.scheduleGlobal(onitemsale_item_Hold,0.1)
		end			
	end
	function on_itemsale_item_image_up()
		if(self.itemHoldHandleAdd ~= nil)then
			scheduler.unscheduleGlobal(self.itemHoldHandleAdd)
			self.itemHoldHandleAdd = nil
		end	
		onitemsale_item_Hold()
	end
 
	self.itemsale_item_image:subscribeEvent("WindowTouchUp", "on_itemsale_item_image_up")
	self.itemsale_item_image:subscribeEvent("WindowTouchDown", "on_itemsale_item_image_down")
	
	self.itemsale_item_image:subscribeEvent("WindowLongTouchCancel", "on_itemsale_item_image_up")
	
	
	
	
	
		function on_itemsale_item_image_up__(args)
			on_itemsale_item_image_up()
			local clickImage = LORD.toWindowEventArgs(args).window		
			clickImage:SetScale(  LORD.Vector3(1,1,1))
			
		end

		function on_itemsale_item_image_down__(args)
			on_itemsale_item_image_down()
			local clickImage = LORD.toWindowEventArgs(args).window		
			clickImage:SetScale(  LORD.Vector3(1.2,1.2,1.2))
			
		end
	self.itemsale_item_add:subscribeEvent("WindowTouchUp", "on_itemsale_item_image_up__")
	self.itemsale_item_add:subscribeEvent("WindowTouchDown", "on_itemsale_item_image_down__")
	self.itemsale_item_add:subscribeEvent("WindowLongTouchCancel", "on_itemsale_item_image_up__")
	

	self.itemCount = 1
	
	
	self:update()
end

function itemsale:update()
		
	local item = itemManager.getItem(self.curSelItem) 	
	self.itemsale_item_image:SetImage(item:getIcon())
	global.setMaskIcon(self.itemsale_item_image, item:getMaskIcon());
	self.itemsale_item:SetImage(item:getImageWithStar()) 
	self.itemsale_item_stlevel:SetText(item:getEnhanceLevelStr()) 	
	self.itemsale_item_container:SetImage(itemManager.getBackImage(item:isDebris()))
	
	self.itemsale_item_name:SetText(item:getName())	--getName	
	self.itemCount = self.itemCount or 1
	self.itemsale_item_num:SetText(self.itemCount.."/"..item:getCount())	--item:getCount()
	local c,price = item:canScale()
	self.itemsale_get_num:SetText(self.itemCount*price)	--item:getCount() 	
	self.itemsale_getone_num:SetText(price)
end	

	


function itemsale:onHide(event)
	self:Close();
	if(self.itemHoldHandleAdd ~= nil)then
			scheduler.unscheduleGlobal(self.itemHoldHandleAdd)
			self.itemHoldHandleAdd = nil
	end	
	if(self.itemHoldHandleDel ~= nil)then
			scheduler.unscheduleGlobal(self.itemHoldHandleDel)
			self.itemHoldHandleDel = nil
	end	
end

return itemsale;
