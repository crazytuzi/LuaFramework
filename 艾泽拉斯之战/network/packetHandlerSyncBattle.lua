function SyncBattleHandler( battleType, battleGuid, isReplay,force, attackPlan, guardPlan, attackMagics, guardMagics )

	BUG_REPORT.onSyncBattleHandler( battleType, battleGuid, isReplay,force, attackPlan, guardPlan, attackMagics, guardMagics )
	local attackUnits = {}	
	local t ={}
	for i=1, #attackPlan do
		local temp = attackPlan[i]
		t.id =  temp.id
		t.x =  temp.position.x	
		t.y =  temp.position.y	
		t.soldierCount = temp.count		
		t.index = 	temp.index
		t.shipAttr = temp.shipAttr;
		attackUnits[i] = clone(t)	
	end
	
	local guardUnits = {}
	for i=1, #guardPlan do
		local temp = guardPlan[i]		
		t.id =  temp.id
		t.x =  temp.position.x	
		t.y =  temp.position.y	
		t.soldierCount = temp.count		
		t.index = 	temp.index
		t.shipAttr = 	temp.shipAttr;
			
		guardUnits[i] = clone(t)
					
	end
	--t = nil
	battlePlayer.battleType = battleType
	battlePlayer.force  = force
	battlePlayer.rePlayStatus = isReplay
	print("battlePlayer.battleType"..battlePlayer.battleType)
	
	battlePlayer.attackMagics = attackMagics;
	battlePlayer.guardMagics = guardMagics;
	
	if(battlePlayer.force ==  enum.FORCE.FORCE_ATTACK	)then
			battlePlayer.self_config  = attackUnits
			battlePlayer.other_config  =  guardUnits	
 
	else
			battlePlayer.self_config  = guardUnits
			battlePlayer.other_config  =  attackUnits
			
	end
  
	 --print("111111111111111111111111111111111111111111111111111111111111111111111111111111111111----"..battlePlayer.force)
	 
	 --hpMonitor.init();
	 --[[
	 -- ÑªÁ¿¼à¿Ø
	 for k,v in ipairs(battlePlayer.self_config) do
	 	hpMonitor.initHP(v.index, v.id, v.soldierCount);
	 end
	 
	 for k,v in ipairs(battlePlayer.other_config) do
	 	hpMonitor.initHP(v.index, v.id, v.soldierCount);
	 end
	 --]]
	 
end
