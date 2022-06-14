function ShipRemouldResultHandler( index, level )
	local shipInstance = shipData.getShipInstance(index+1);
	
	if shipInstance then
		shipInstance:setRemouldLevel(level);
	end
	
	eventManager.dispatchEvent({name = global_event.SHIPREMOULD_UPDATE, shipIndex = index+1});
	eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_SHIP_UPDATE });
	eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_REMOULD_OK });
	
end
