




function start(api,need_start)
	local qid = api.Quest.GetMainQuest()
	if qid then
		api.SetGuideBiStep(1)
		Helper.QuestHudGuide(qid,{textY=-15,force=false})
		api.Wait()
	end
end
