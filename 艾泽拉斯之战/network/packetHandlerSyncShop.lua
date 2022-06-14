function SyncShopHandler (diamondRefreshCount,refreshTime, shopType, shopItems )
	
	local data = dataManager.shopData
	data:setShopReFreshNum(diamondRefreshCount)	
	data:setShopReFreshTime(refreshTime)			
	local count = #shopItems	
	for i = 1,count do
		local d = shopItems[i]		
		--d['rowIndex'] = (i)%4
		
		 --d['arrayIndex'] = 1
		local item = data:newItem(d['rowIndex'],d['arrayIndex'],shopType,i-1)		
		if(item)then		
	 
			item:setSaleFinish(d['count'] == 0 )
		end	
	end
	eventManager.dispatchEvent({name = global_event.SHOP_UPDATE});	
 
end
