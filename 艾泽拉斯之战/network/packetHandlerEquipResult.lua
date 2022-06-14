function EquipResultHandler( bagTypeA, positionA, bagTypeB, positionB )
		
		
	local  	_OLDA  =  clone(dataManager.bagData:getItem(positionA,bagTypeA) )
	local  	_OLDB  =  clone(dataManager.bagData:getItem(positionB,bagTypeB)) 
	
	
	dataManager.bagData:delItem(positionB,bagTypeB)	
	dataManager.bagData:delItem(positionA,bagTypeA)	
	
	dataManager.bagData:addItem(_OLDA,positionB,bagTypeB,false)	
	dataManager.bagData:addItem(_OLDB,positionA,bagTypeA,false)	

	itemManager.__additemToManger(_OLDA)	
	itemManager.__additemToManger(_OLDB)	
	
 	eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_UPDATE});
	eventManager.dispatchEvent({name = global_event.PACK_UPDATE});		
	eventManager.dispatchEvent({name = global_event.MAIN_UI_ACTIVITY_STATE})	

end
