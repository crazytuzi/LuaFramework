function SyncKingHandler( icon, name, myths, intelligence, force, level, mp, maxMP, costRatio )
	
		BUG_REPORT.onSyncKingHandler( icon, name, myths, intelligence, force, level, mp, maxMP, costRatio )
			 
		print("syncKingHandler  ..................................")
		print("icon "..icon);
		print("name "..name);
        print("myths "..myths);
		print("intelligence "..intelligence);
		print("force "..force);
		print("level "..mp);
		print("maxMP "..maxMP);
		print("costRatio "..costRatio);
		
		local king = dataManager.battleKing[force]
		if(king)then		
			king:setIntelligence(intelligence)
			king:setForce(force)
			king:setLevel(level)		
			king:setMp(mp)
			king:setMpMax(maxMP)	
			king:setCasterMPRate(costRatio)	
			king:setName(name)
			king:setIcon(icon)
            king:setMyths(myths)
			
			eventManager.dispatchEvent({name = global_event.BATTLE_KING_ATTR_SYNC,  force = force })	
		end			
end
