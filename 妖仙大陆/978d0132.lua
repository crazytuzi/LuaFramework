





function Quest_InProgress(api, id)
	params = {text=api.GetText('guide34'),force=true,buttonText='膜拜',soundKey='guide34'}
	Helper.PickGuide(params)
	api.Wait()
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	elseif s== api.Quest.Status.DONE then
		StartScript('zhucheng5')
	end
end
