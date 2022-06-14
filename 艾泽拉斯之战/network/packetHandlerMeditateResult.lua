function MeditateResultHandler( magic, overflowExp )
	dataManager.kingMagic:setMagicTowerFlag(false);
	eventManager.dispatchEvent({name = global_event.SKILLFUSE_HIDE});
	--eventManager.dispatchEvent({name = global_event.SKILLGET_SHOW, chooseData = magic, exp = overflowExp, });
end
