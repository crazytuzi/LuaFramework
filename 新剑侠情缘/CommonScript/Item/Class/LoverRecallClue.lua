local tbItem = Item:GetClass("LoverRecallClue");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	
	local fnComposeLoverRecallMap = function ()
		if not Activity:__IsActInProcessByType("LoverRecallAct") then
			me.CenterMsg("活动已经结束", true)
			return 
		end

		RemoteServer.TryComposeLoverRecallMap()
	end

	return {szFirstName = "合成", fnFirst = fnComposeLoverRecallMap};
end
