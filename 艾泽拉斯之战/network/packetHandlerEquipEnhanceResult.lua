function EquipEnhanceResultHandler( isEnhanceToMax )
 
	itemManager.setEnhancingEquip(false);
	eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_ENHANCE_RESULT, isEnhanceToMax = isEnhanceToMax});
end
