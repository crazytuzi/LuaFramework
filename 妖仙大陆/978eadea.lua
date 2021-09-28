





function Quest_InProgress(api, id)
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/guild/guild_establish.gui.xml'))
	api.PlaySoundByKey('guide38')
	Helper.TouchGuide(nil,{text=api.GetText('guide38'),noDestory=true})
	api.Sleep(4)
end

function start(api, id, s)
	if s == api.Quest.Status.IN_PROGRESS then
		api.Wait(Helper.WaitScriptEndByType(1))
		Quest_InProgress(api,id)
	end
end
