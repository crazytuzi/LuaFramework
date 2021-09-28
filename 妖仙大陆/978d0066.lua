





function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.PickGuide({text=api.GetText('guide22'),soundKey='guide22',force=true,buttonText='调查'}))
	end
end
