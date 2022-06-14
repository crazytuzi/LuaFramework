function ChooseMagicHandler( chooses )

	local magicTowerData = dataManager.magicTower;
	local magicCount = magicTowerData:getMediacateSkillCount();
	if magicCount == 1 and chooses[1] then
		sendChooseMagicResult(chooses[1].id);
	else
		eventManager.dispatchEvent({name = global_event.SKILLCHOICE_SHOW, choosesData = chooses });
	end
		
end
