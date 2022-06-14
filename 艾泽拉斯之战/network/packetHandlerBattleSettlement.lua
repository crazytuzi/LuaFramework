function BattleSettlementHandler( battleType, win )
	battlePlayer.battleType = battleType;
	battlePlayer.win = win;
	
	if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT and win == true then
		global.setFlag("incidentAward", true);
	end
	
	if(battlePlayer.battleType  == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE  or enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE == battlePlayer.battleType )then
		
		if(	battlePlayer.win == true)then
			eventManager.dispatchEvent( {name = global_event.GUIDE_ON_STAGE_BATTLE_WIN})
		end
		
	else
	
	end
 
	
end
