





function Quest_New(api, id)

end

function Quest_CanFinish(api, id)

end

function Quest_Done(api, id)

end

function Quest_InProgress(api, id)
	
end

function start(api, id, s)
	if s == api.Quest.Status.NEW then
		Quest_New(api,id)
	elseif s == api.Quest.Status.CAN_FINISH then
		Quest_CanFinish(api,id)
	elseif s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	elseif s == api.Quest.Status.DONE then
		Quest_Done(api,id)
	end
end
