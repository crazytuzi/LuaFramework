local tbItem = Item:GetClass("CollectAndRobClueBox");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUserSet = {};
	if Activity:__IsActInProcessByType("CollectAndRobClue") then
		local fnFirst = function ()
			Ui:OpenWindow("NationalCollectPanel") 
			Ui:CloseWindow("ItemTips")
		end
		tbUserSet.szFirstName = "打开"
		tbUserSet.fnFirst = fnFirst		
	else
		if Shop:CanSellWare(me, nItemId, 1) then
			tbUserSet.szFirstName = "出售"
			tbUserSet.fnFirst = "SellItem"
		end
	end
	return tbUserSet
end