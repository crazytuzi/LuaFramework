function DelItemResultHandler( bagType, position )
	dataManager.bagData:delItemWithPositions(position,bagType)
	eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_UPDATE});
	eventManager.dispatchEvent({name = global_event.PACK_UPDATE});						
end
