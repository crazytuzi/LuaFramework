
local tbItem = Item:GetClass("JuanZhou");

local MAX_NEED_ITEM_COUNT = 5;
local MAX_NEED_MONEY_COUNT = 1;
function tbItem:LoadSetting()
	local tbGroupFile = LoadTabFile("Setting/JuanZhou/JuanZhouGroup.tab", "ddd", nil, {"GroupId", "ItemId", "Count"});
	local szType = "ddsdsdd";
	local tbTitle = {"Id", "GroupId", "Tip", "NeedCount", "Award", "KinMsg", "WorldMsg"};
	for i = 1, MAX_NEED_ITEM_COUNT do
		szType = szType .. "s";
		table.insert(tbTitle, "Item" .. i);
	end

	for i = 1, MAX_NEED_MONEY_COUNT do
		szType = szType .. "sd";
		table.insert(tbTitle, "MoneyType" .. i);
		table.insert(tbTitle, "MoneyCount" .. i);
	end

	local tbFile = LoadTabFile("Setting/JuanZhou/JuanZhou.tab", szType, nil, tbTitle);

	self.tbAllSetting = {};
	for _, tbRow in pairs(tbFile) do
		if tbRow.Id > 0 then
			assert(not self.tbAllSetting[tbRow.Id], "[JuanZhou] Id repeat !! Id:" .. tbRow.Id);

			local tbAward = Lib:GetAwardFromString(tbRow.Award);
			assert(#tbAward > 0, "[JuanZhou] tbAward is null !! Id: " .. tbRow.Id);

			local tbNeedItem = {};
			if tbRow.GroupId > 0 then
				for _, tbInfo in pairs(tbGroupFile) do
					if tbInfo.GroupId == tbRow.GroupId then
						table.insert(tbNeedItem, {tbInfo.ItemId, tbInfo.Count});
					end
				end
				assert(#tbNeedItem > 0, "[JuanZhou] Unknow GroupId !! GroupId: " .. tbRow.GroupId);
			else
				for i = 1, MAX_NEED_ITEM_COUNT do
					local nItemId, nCount = string.match(tbRow["Item" .. i], "^(%d+)|(%d+)$");
					if nItemId then
						nItemId = tonumber(nItemId);
						nCount = tonumber(nCount);

						table.insert(tbNeedItem, {nItemId, nCount});
					end
				end
			end

			local tbNeedMoney = {};
			for i = 1, MAX_NEED_MONEY_COUNT do
				local szMoneyType = tbRow["MoneyType" .. i];
				local nCount = tbRow["MoneyCount" .. i];
				if szMoneyType and szMoneyType ~= "" then
					assert(Shop.tbMoney[szMoneyType], "[JuanZhou] Unknow Money Type !! MoneyType: " .. szMoneyType);
					assert(nCount > 0, "[JuanZhou] MoneyCount ERROR !! MoneyCount: " .. nCount);

					table.insert(tbNeedMoney, {szMoneyType, nCount});
				end
			end

			assert(#tbNeedItem + #tbNeedMoney > 0, "[JuanZhou] tbNeedItem is null !! Id: " .. tbRow.Id);

			self.tbAllSetting[tbRow.Id] = {
				nId = tbRow.Id,
				szTips = tbRow.Tip,
				tbNeedMoney = tbNeedMoney,
				tbNeedItem = tbNeedItem,
				tbAward = tbAward,
				szAward = tbRow.Award,
				nNeedCount = tbRow.NeedCount,
				WorldMsg = tbRow.WorldMsg,
				KinMsg = tbRow.KinMsg
			};

			-- 任选模式
			if self.tbAllSetting[tbRow.Id].nNeedCount > 0 then
				local tbAllowInfo = {};
				for _, tbInfo in pairs(tbNeedItem) do
					tbAllowInfo[tbInfo[1]] = tbAllowInfo[tbInfo[1]] or 0;
					tbAllowInfo[tbInfo[1]] = tbAllowInfo[tbInfo[1]] + tbInfo[2];
				end
				self.tbAllSetting[tbRow.Id].tbAllowInfo = tbAllowInfo;
			end
		end
	end
end

function tbItem:UseItem(it, tbSelect)
	local bCanCommit, szMsg, tbSetting = self:CheckCanCommit(it, tbSelect);
	if not bCanCommit then
		me.CenterMsg(szMsg);
		return;
	end

	local szName = it.szName;
	local dwTemplateId = it.dwTemplateId;
	local nCount = me.ConsumeItem(it, 1, Env.LogWay_JuanZhou);
	if nCount ~= 1 then
		Log("[JuanZhou] ERR !! Consume JuanZhou Item Fail !! ", me.dwID, me.szAccount, me.szName, dwTemplateId, nCount)
		return;
	end

	local bRet = self:ConsumeItem(tbSetting, tbSelect);
	if not bRet then
		return;
	end

	self:SendAward(szName, dwTemplateId, tbSetting);
end

function tbItem:ConsumeItem(tbSetting, tbSelect)
	local szConsumeInfo = "";
	for _, tbMoney in pairs(tbSetting.tbNeedMoney) do
		local bRet = me.CostMoney(tbMoney[1], tbMoney[2], Env.LogWay_JuanZhou);
		if not bRet then
			me.CenterMsg("扣除道具失败！");
			Log("[JuanZhou] Error ConsumeItemInBag fail !!", me.dwID, me.szAccount, me.szName, tbSetting.nId, szConsumeInfo);
			return false;
		end
		szConsumeInfo = szConsumeInfo .. string.format("%s|%s;", tbMoney[1], tbMoney[2]);
	end

	self.tbSkillBook = self.tbSkillBook or Item:GetClass("SkillBook");
	if tbSetting.nNeedCount <= 0 then
		-- 全收集模式
		for _, tbInfo in pairs(tbSetting.tbNeedItem) do
			local nCount, tbItem = me.GetItemCountInBags(tbInfo[1]);
			if tbItem[1] and tbItem[1].szClass == "SkillBook" then
				for i = #tbItem, 1, -1 do
					local pSkillBook = tbItem[i];
					if not self.tbSkillBook:CheckCanSell(pSkillBook) then
						nCount = nCount - pSkillBook.nCount;
						tbItem[i] = nil;
					end
				end
			end

			local nConsumeCount = 0;
			for _, pItem in ipairs(tbItem) do
				local nConsume = math.min(pItem.nCount, tbInfo[2] - nConsumeCount);
				nConsume = me.ConsumeItem(pItem, nConsume, Env.LogWay_JuanZhou);
				nConsumeCount = nConsumeCount + nConsume;
				if nConsumeCount >= tbInfo[2] then
					break;
				end
			end

			szConsumeInfo = szConsumeInfo .. string.format("%s|%s;", tbInfo[1], nConsumeCount);

			if nConsumeCount ~= tbInfo[2] then
				me.CenterMsg("扣除道具失败！");
				Log("[JuanZhou] Error ConsumeItemInBag fail !!", me.dwID, me.szAccount, me.szName, tbSetting.nId, szConsumeInfo);
				return false;
			end
		end
	else
		-- 任选模式
		for nItemId, nCount in pairs(tbSelect) do
			local pItem = KItem.GetItemObj(nItemId);
			if nCount <= 0 or not pItem or pItem.nCount < nCount or not tbSetting.tbAllowInfo[pItem.dwTemplateId] then
				me.CenterMsg("扣除道具失败！");
				Log("[JuanZhou] Error ConsumeItemInBag fail !!", me.dwID, me.szAccount, me.szName, tbSetting.nId, szConsumeInfo);
				return false;
			end

			if pItem.szClass == "SkillBook" and not self.tbSkillBook:CheckCanSell(pItem) then
				Log("[JuanZhou] Error ConsumeItemInBag fail !!", me.dwID, me.szAccount, me.szName, tbSetting.nId, szConsumeInfo);
				return false;
			end

			local nRet = me.ConsumeItem(pItem, nCount, Env.LogWay_JuanZhou);
			if nRet ~= nCount then
				me.CenterMsg("扣除道具失败！");
				Log("[JuanZhou] Error ConsumeItemInBag fail !!", me.dwID, me.szAccount, me.szName, tbSetting.nId, szConsumeInfo);
				return false;
			end
			szConsumeInfo = szConsumeInfo .. string.format("%s|%s;", pItem.dwTemplateId, nCount);
		end
	end

	return true;
end

function tbItem:SendAward(szName, dwTemplateId, tbSetting)
	local szItemName;
	local nItemTemplateId;
	for _, tbInfo in ipairs(tbSetting.tbAward) do
		if Player.AwardType[tbInfo[1]] == Player.award_type_item then
			local szName = Item:GetItemTemplateShowInfo(tbInfo[2], me.nFaction, me.nSex);
			szItemName = string.format("<%s>", szName);
			if tbInfo[3] > 1 then
				szItemName = szItemName .. " * " .. tbInfo[3];
			end
			nItemTemplateId = tbInfo[2];
			break;
		end
	end

	if not szItemName then
		local tbDsc = Lib:GetAwardDesCount2(tbSetting.tbAward, me);
		szItemName = tbDsc[1] or "";
	end

	if tbSetting.WorldMsg > 0 then
		local szMsg = MsgInfoCtrl:GetMsg(tbSetting.WorldMsg, me.szName, szName or "", szItemName);
		if nItemTemplateId then
			KPlayer.SendWorldNotify(0, 999, szMsg, 0, 1);
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg, nil, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemTemplateId, nFaction = me.nFaction, nSex = me.nSex});
		else
			KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1);
		end
	end

	if tbSetting.KinMsg > 0 and me.dwKinId > 0 then
		local szMsg = MsgInfoCtrl:GetMsg(tbSetting.KinMsg, me.szName, szName or "", szItemName);
		if nItemTemplateId then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, me.dwKinId, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemTemplateId, nFaction = me.nFaction, nSex = me.nSex});
		else
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, me.dwKinId);
		end
	end

	me.CenterMsg(string.format("恭喜完成了%s", szName));
	me.SendAward(tbSetting.tbAward, false, true, Env.LogWay_JuanZhou);

	local _, _, _, nQuality = Item:GetItemTemplateShowInfo(dwTemplateId);
	if nQuality >= 3 then
		Achievement:AddCount(me, "JuanZhou_2");
		if nQuality == 4 then
			Achievement:AddCount(me, "JuanZhou_4");
		elseif nQuality == 5 then
			Achievement:AddCount(me, "JuanZhou_5");
		end
	end
	Achievement:AddCount(me, "JuanZhou_1");
	Achievement:AddCount(me, "JuanZhou_3", 1);
	Achievement:AddCount(me, "JuanZhou_3", 1);
	Log("[JuanZhou] Use JuanZhou Item", me.dwID, me.szAccount, me.szName, dwTemplateId, szConsumeInfo, tbSetting.szAward);
end

function tbItem:GetSetting(dwTemplateId)
	local nId = KItem.GetItemExtParam(dwTemplateId, 1);
	return nId > 0 and self.tbAllSetting[nId] or nil;
end

function tbItem:CheckCanCommit(it, tbSelect)
	local tbSetting = self:GetSetting(it.dwTemplateId)
	if not tbSetting then
	    Log("EEEEEEEEEE[JuanZhou]CheckCanCommit", it.dwTemplateId);
		return false, "异常道具!!!!";
	end

	for _, tbMoney in pairs(tbSetting.tbNeedMoney) do
		if me.GetMoney(tbMoney[1]) < tbMoney[2] then
			return false, "未收集满所需物品";
		end
	end

	self.tbSkillBook = self.tbSkillBook or Item:GetClass("SkillBook");
	if tbSetting.nNeedCount <= 0 then
		-- 全收集模式
		for _, tbInfo in pairs(tbSetting.tbNeedItem) do
			local nCount, tbItem = me.GetItemCountInBags(tbInfo[1]);

			for _, pItem in ipairs(tbItem) do
				if pItem.szClass == "SkillBook" and not self.tbSkillBook:CheckCanSell(pItem) then
					nCount = nCount - pItem.nCount;
				end
			end

			if not nCount or nCount < tbInfo[2] then
				return false, "未收集满所需物品";
			end
		end
	else
		-- 任选模式
		local nSelectCount = 0;
		for nItemId, nCount in pairs(tbSelect or {}) do
			local pItem = KItem.GetItemObj(nItemId);
			if nCount <= 0 or not pItem or pItem.nCount < nCount or not tbSetting.tbAllowInfo[pItem.dwTemplateId] then
				return false, "选择道具出错";
			end

			if pItem.nPos ~= Item.EITEMPOS_BAG then
				return false, "只能使用背包内的物品";
			end

			if pItem.szClass == "SkillBook" and not self.tbSkillBook:CheckCanSell(pItem) then
				return false, "升级后的秘籍不能使用";
			end

			nSelectCount = nSelectCount + nCount;
		end

		if nSelectCount < tbSetting.nNeedCount then
			return false, "放入物品不满足任务需求";
		end
	end

	return true, "", tbSetting;
end


function tbItem:CheckCanCommitInBag(dwTemplateId)
	local tbSetting = self:GetSetting(dwTemplateId)
	if not tbSetting then
		return false;
	end

	for _, tbMoney in pairs(tbSetting.tbNeedMoney or {}) do
		if me.GetMoney(tbMoney[1]) < tbMoney[2] then
			return false;
		end
	end

	local nTotalCount = 0;
	local nTotalNeedCount = 0;
	for idx, tbInfo in ipairs(tbSetting.tbNeedItem) do
		local nItemId, nNeedCount = unpack(tbInfo)
		local nCount, tbItem = me.GetItemCountInBags(nItemId);
		for _, pItem in ipairs(tbItem) do
			if pItem.szClass == "SkillBook" and not Item:GetClass("SkillBook"):CheckCanSell(pItem) then
				nCount = nCount - pItem.nCount;
			end
		end

		nCount = math.min(nNeedCount, nCount);
		nTotalNeedCount = nTotalNeedCount + nNeedCount
		nTotalCount = nTotalCount + nCount;
	end
	if tbSetting.nNeedCount <= 0 then
		return nTotalNeedCount == nTotalCount;
	else
		return nTotalCount >= tbSetting.nNeedCount;
	end
end

