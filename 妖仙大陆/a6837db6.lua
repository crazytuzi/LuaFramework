function start(api,...)													
	local user = api.GetUserInfo()										
	api.World.Init()													
	local uids = {}														
	for i=1,5 do   														
		local uid = api.Helper.AddUnit(i,user.x,user.y + i * 2) 		
		table.insert(uids,uid)											
	end																	

	
	local act1 = {														
		'Sequence',	{time=5},											
		{'Skill',{id=100020,target=uids[2]}},							
		{'Delay',{min=0.8,max=2}},										
	}
	local act2 = {														
		'Sequence',{time=5},
		{'Skill',{id=200020,target=uids[1]}},
		{'Delay',{min=0.8,max=2}},
	}
	local act3 = {														
		'Sequence',{time=5},
		{'Skill',{id=300020,target=uids[2]}},
		{'Delay',{min=0.8,max=2}},
	}
	api.World.RunAction(uids[1],act1)									
	api.World.RunAction(uids[2],act2)									
	api.World.RunAction(uids[3],act3)									
	api.Wait()
end																		













