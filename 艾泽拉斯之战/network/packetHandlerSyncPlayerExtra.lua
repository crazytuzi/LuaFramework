function SyncPlayerExtraHandler( __optional_flag__attr,  attr )
	
	for i=1, 32 do
		if __optional_flag__attr:isSetbit(i-1) then
			dataManager.playerData:setExtraAttr(i-1, attr[i]);
			print("i "..i.." attr[i] "..attr[i])
		end
	end
	
	eventManager.dispatchEvent({name = global_event.GUILDCREATE_UPDATE});
	
end
