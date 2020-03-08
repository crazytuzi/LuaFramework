local tbItem = Item:GetClass("WorshipClue");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local fnComposeWorshipMap = function ()
		if not Activity:__IsActInProcessByType("QingMingAct") then
			me.CenterMsg("活动已经结束", true)
			return 
		end

		RemoteServer.TryComposeWorshipMap()
	end
	return {szFirstName = "合成", fnFirst = fnComposeWorshipMap};
end
