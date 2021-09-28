

function split(str,sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function start(api)
	local qid = api.Quest.GetMainQuest()
	if qid then
		local Status = api.Quest.Status
		local s = api.Quest.GetState(qid)
		if s == api.Quest.Status.NEW then
			
			
			api.SendChatMsg('@gm acceptTask '..qid)
		elseif s == api.Quest.Status.CAN_FINISH then
			api.SendChatMsg('@gm finishTask '..qid)
			api.Sleep(2)
			
			local Next = api.Quest.GetStringParam(qid,'Next')
			if not Next then return end
			local all_next = split(Next,':')
			api.SendChatMsg('@gm discardTask '..qid)
			if #all_next > 1 then
				
				local pro = api.GetProKey()
				for _,v in ipairs(all_next) do
					local t = api.Quest.GetQuestStatic(v)
					if t.Job == pro then
						api.SendChatMsg('@gm acceptTask '..v.ID)
						break
					end
				end
			else
				api.SendChatMsg('@gm acceptTask '..all_next[1])
			end			
		elseif s == api.Quest.Status.IN_PROGRESS then
			local npcid = api.Quest.GetIntParam(qid,'CompleteNpc')
			if npcid < 0 then
				api.SendChatMsg('@gm finishTask '..qid)
			else
				api.SendChatMsg('@gm finishTaskTarget '..qid)
			end
		end
		api.Sleep(2)
	end
end
