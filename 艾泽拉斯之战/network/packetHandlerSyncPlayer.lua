 
function SyncPlayerHandler( __optional_flag__attr,  attr, __optional_flag__timeAttr,  timeAttr,__optional_flag__attrString,  attrString)
	
	local player  = dataManager.playerData;
	
 
	for i=1, table.maxn(attrString) do
		print("__optional_flag__attrString "..i);
		if __optional_flag__attrString:isSetbit(i-1) then
			local value = attrString[i]
			local attrEnum = i-1			
			player:setPlayerStringAttr(attrEnum, value)		
				if attrEnum == enum.PLAYER_ATTR_STRING.PLAYER_ATTR_STRING_NAME  then
					setWindowName(value)	
					if(global_event.HERONAME_HIDE)then
						eventManager.dispatchEvent({name = global_event.HERONAME_HIDE })
					end
					if(global_event.NOTICEDIAMOND_HIDE)then
						eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_HIDE })
					end
				end				
		end	
	end	
	
	for i=1, table.maxn(attr) do
		print("__optional_flag__attr "..i);
		if __optional_flag__attr:isSetbit(i-1) then
			local value = attr[i];
			local attrEnum = i-1;
			print("attrEnum "..attrEnum);
			
			local oldValue = player:getPlayerAttr(attrEnum, value);
			player:setPlayerAttr(attrEnum, value);
			
			player:onPlayerAttrChanged(attrEnum, oldValue, value);
		end
	end
	
	for i=1, table.maxn(timeAttr) do
		if __optional_flag__timeAttr:isSetbit(i-1) then
			local value = timeAttr[i]:GetUInt();
			local timeAttrEnum = i-1;
			
			player:setTimeAttr(timeAttrEnum, value);
			print(" timeAttrEnum "..timeAttrEnum.." value "..value);
		end
	end
	
	eventManager.dispatchEvent({name = global_event.PLAYER_ATTR_SYNC });
	eventManager.dispatchEvent({name = global_event.RESOURCE_UPDATE, });
	eventManager.dispatchEvent({name = global_event.MIRACLE_UPDATE});
	
end
