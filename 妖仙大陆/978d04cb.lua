






button_name = '购买药剂'

function Quest_InProgress(api, id)
	npcId = api.Quest.GetIntParam(id,'NPCchat')
	if npcId > 0 then
		msg_id = api.SubscribOnReciveMessage('Npc.Menu.'..npcId)
		api.Wait(msg_id)
		sp_func = api.UI.FindComponent('xmds_ui/npc/npc.gui.xml','sp_func')
		btn_box = api.UI.FindChild(sp_func,function (uid)
			return api.UI.GetText(uid) == button_name
		end)
		if btn_box then
			api.Wait(Helper.TouchGuide(btn_box,{x=-30}))
		end
	end
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
