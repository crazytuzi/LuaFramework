function ShipUpgradeResultHandler( index, level )
	--print("result: "..result.."index: "..index.." level: "..level);
	
	if index ~= -1 then
		shipData.shiplist[index+1]:setLevel(level);
		 
		if shipData.shiplist[index+1]:isEnoughPlayerLevel() then
			eventManager.dispatchEvent({name = global_event.SHIPLEVELUP_UPDATE });
		else
			eventManager.dispatchEvent({name = global_event.SHIPLEVELUP_HIDE });
		end
		
		eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_SHIP_UPDATE });
		eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_LEVELUP_OK });
	else
		-- 自动升级的约定
		for k,v in ipairs(shipData.shiplist) do
			v:setLevel(level);
		end
	end
	
end
