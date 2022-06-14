-- this usertype is defined in cpp file, so you should parse it manually!
function ItemInfoParseItemInfoData()		
	return ParseItemInfoData();
end

function ItemInfoHandler( opcode, bagType, items )
		local add =     opcode == 1
		local tempArrayCount  = #items
		
		local temp = nil
		local tipText = {}
		local newInstaneTip   = true
		for i=1, tempArrayCount do		
			temp = items[i]
			local item = nil
			local index = nil
			item = itemManager.getItemWithGuid( temp.itemSID )	 --dataManager.bagData:getItem(temp.position,temp.bagType)
			local oldCount = 0
			if (item ~= nil) then
				oldCount = item:getCount()
				index = item:getIndex()
				dataManager.bagData:delItem(item:getPos(),item:getVec())
			end			
			item = itemManager.createItem(temp.tableID,index)
			item:setCount(temp.overlap)
			item:setCreateTime(temp.createTime)
			item:setGUID(temp.itemSID)
			
			if(index ~= nil)then
				newInstaneTip = false
			end
			
			local changeoldCount = item:getCount() -  oldCount
			if (newInstaneTip == false and changeoldCount > 0 )then
				newInstaneTip = true
			end
		
			
			if(item:isEquip())then
				item:setEnhanceGold(temp.enhanceGold)
				item:setEnhanceLevel(temp.enhanceExp)
			end				
			dataManager.bagData:addItem(item,temp.position,temp.bagType,false)	
			
			if(newInstaneTip == true )then
				local t = item:getTipText(changeoldCount) 	
				if(t)then
					table.insert(tipText,t)
				end
			end
		end				

		dataManager.bagData:OnaddItemEnd()			
		eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_UPDATE});
		eventManager.dispatchEvent({name = global_event.PACK_UPDATE});		
		eventManager.dispatchEvent({name = global_event.MAIN_UI_ACTIVITY_STATE})		

		eventManager.dispatchEvent({name =  global_event.WARNINGHINT_SHOW,tip =  tipText ,RESGET = true})

		 
end