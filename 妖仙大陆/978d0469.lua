






function Quest_InProgress(api, id)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
