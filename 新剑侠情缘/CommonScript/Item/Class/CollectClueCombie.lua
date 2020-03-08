local tbItem = Item:GetClass("CollectClueCombie");
function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUserSet = {};
	local tbAct = Activity.CollectAndRobClue
	local _, tbMyItemList = tbAct:GetMyItemListData();
	local tbClueItem = Item:GetClass("CollectAndRobClue");
	local bRet = tbClueItem:CanCombieDebris(tbMyItemList)
	if bRet then
		tbUserSet.szFirstName = "合成"
		tbUserSet.fnFirst = function ()
			RemoteServer.DoRequesActCollectAndRobClue("CombieClueItem")
		end	
	else
		tbUserSet.szFirstName = "预览"
		tbUserSet.fnFirst = function ()
			Item:ShowItemDetail({nTemplate = tbClueItem.nLastCombineItemId});
		end	
	end
	return tbUserSet
end