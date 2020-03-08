local tbItem = Item:GetClass("CollectClueDebris");

local tbChangeItemTemp = {
[6469] = 6389;[6471] = 6390;[6472] = 6391;[6473] = 6392;[6474] = 6393;[6475] = 6394;[6476] = 6395;[6477] = 6396;[6478] = 6397;[6479] = 6398;[6480] = 6399;[6481] = 6400;[6482] = 6401;[6483] = 6402;[6484] = 6403;[6485] = 6404;[6486] = 6405;[6487] = 6406;[6488] = 6407;[6489] = 6408;[6490] = 6409;[6491] = 6410;[6492] = 6411;[6493] = 6412;[6494] = 6413;[6495] = 6415;[6470] = 6416;[6496] = 6417;[6497] = 6418;[6498] = 6419;[6499] = 6420;[6500] = 6421;[6501] = 6422;[6502] = 6423;[6503] = 6424;[6504] = 6425;[6505] = 6426;[6506] = 6427;[6507] = 6428;[6508] = 6429;[6509] = 6430;[6510] = 6431;[6511] = 6432;[6512] = 6433;[6513] = 6434;[6514] = 6435;[6515] = 6436;[6516] = 6437;[6517] = 6438;[6518] = 6439;	
}
function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUserSet = {};
	local tbAct = Activity.CollectAndRobClue
	local nCount = tbAct:GetItemCount(nTemplateId)
	if nCount >= Item:GetClass("CollectAndRobClue").COMBIE_COUNT then
		tbUserSet.szFirstName = "合成"
		tbUserSet.fnFirst = function ()
			RemoteServer.DoRequesActCollectAndRobClue("CombieClueDerbis", nTemplateId)
		end	
	else
		tbUserSet.szFirstName = "增加"
		tbUserSet.fnFirst = function ()
			local nCount, tbGetItem = me.GetItemCountInBags(6414)
			if nCount > 0 and tbGetItem[1] then
				local pItem = tbGetItem[1]
				local nChangeId = tbChangeItemTemp[nTemplateId]
				if not nChangeId then
					Log("Error !!!CollectClueDebris", nTemplateId)
					return
				end
				local tbSelItem = {
					[nChangeId] = 1;
				}
				
				RemoteServer.UseChooseItem(pItem.dwId, tbSelItem)
				return
			end
			me.CenterMsg("您缺少乾坤分卷碎片")
		end	
	end
	return tbUserSet
end
