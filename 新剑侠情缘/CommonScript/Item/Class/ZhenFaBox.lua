
local tbItem = Item:GetClass("ZhenFaBox");

function tbItem:OnUse(it)
	local bRet, szMsg = me.CheckNeedArrangeBag();
	if bRet then
		me.CenterMsg(szMsg);
		return;
	end

	local nParamId = KItem.GetItemExtParam(it.dwTemplateId, 1);
	nParamId = Item:GetClass("RandomItemByTimeFrame"):GetRandomKindId(nParamId);
	local bRet, szMsg, tbAllAward = Item:GetClass("RandomItem"):RandomItemAward(me, nParamId, it.szName, Env.LogWay_ZhenFaOpenBoxAward);
	if not bRet or bRet ~= 1 then
		me.CenterMsg(szMsg);
		return;
	end

	me.SendAward(tbAllAward, false, true, Env.LogWay_ZhenFaOpenBoxAward);
	Log("[ZhenFaBox] OnUse", me.dwID, me.szName, me.szAccount, it.dwTemplateId);
	return 1;
end

function tbItem:GetCombineCountInfo(nItemTemplateId)
	local tbCount = {};
	for i = 2, 1, -1 do
		local nDstTemplateId = KItem.GetItemExtParam(nItemTemplateId, i + 1);
		local nCount = me.GetItemCountInBags(nDstTemplateId);
		tbCount[i] = nCount;
	end
	return unpack(tbCount);
end

function tbItem:Combine(nItemTemplateId)
	local nItemId = 0;
	local szName = "";
	local tbItemInfo= {};
	for i = 2, 1, -1 do
		local nDstTemplateId = KItem.GetItemExtParam(nItemTemplateId, i + 1);
		local tbBaseInfo = KItem.GetItemBaseProp(nDstTemplateId);
		local tbItem = me.FindItemInBag(nDstTemplateId);
		local nCount = me.GetItemCountInBags(nDstTemplateId);
		szName = tbBaseInfo.szName;
		if nCount > 0 and tbItem and tbItem[1] then
			table.insert(tbItemInfo, {tbItem[1].dwId, nCount});
		end
	end

	if #tbItemInfo <= 0 then
		me.CenterMsg(string.format("没有%s，无法合成！", szName));
	else
		local nItemCount = me.GetItemCountInBags(nItemTemplateId);
		for _, tbInfo in ipairs(tbItemInfo) do
			if nItemCount > 0 then
				RemoteServer.UseAllItem(tbInfo[1]);
				nItemCount = nItemCount - tbInfo[2];
			else
				break;
			end
		end
	end
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	local function fnCombine()
		Ui:CloseWindow("ItemTips");
		local nCount1, nCount2 = self:GetCombineCountInfo(nItemTemplateId);
		local nItemCount = me.GetItemCountInBags(nItemTemplateId);
		nCount2 = math.min(nCount2, nItemCount);
		nCount1 = math.min(nItemCount - nCount2, nCount1);
		me.MsgBox(string.format("少侠是否修复最大数量的[aa62fc]古旧阵法残卷[-]？\n修复规则：优先合成[ff8f06]传世阵法古籍[-]（可合成[FFFE0D]%s[-]本），其次合成[ff578c]精致阵法古籍[-]（可合成[FFFE0D]%s[-]本）", nCount2, nCount1), {
			{"全部修复", function () self:Combine(nItemTemplateId) end, bLight = true},
			{"取消"},
		});
	end
	return {szFirstName = "使用", fnFirst = "UseItem", szSecondName = "修复", fnSecond = fnCombine};
end