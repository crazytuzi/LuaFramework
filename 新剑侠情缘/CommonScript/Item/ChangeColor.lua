
Require("CommonScript/Faction.lua")

Item.tbChangeColor 	= Item.tbChangeColor or {};
local tbChangeColor = Item.tbChangeColor;

tbChangeColor.MAX_COLOR = 8
tbChangeColor.CONSUME_ITEM = 2569;
tbChangeColor.MAX_FACTION = Faction.MAX_FACTION_COUNT
tbChangeColor.INIT_CHARM_VALUE = 100

tbChangeColor.GROUP_WAIYI_GB = 145
tbChangeColor.VALUE_WAIYI_GB_SELECT = 1
tbChangeColor.VALUE_WAIYI_GB = 2

tbChangeColor.GROUP_HIDE_PART = 203;
tbChangeColor.KEY_HIDE_PART = 1;

-- 存储使用道具后显示的外装
tbChangeColor.ITEM_INT_VALUE_WAIYI_LIMIT = 1;

tbChangeColor.tbCharm = {};

function tbChangeColor:GetWaiyiLimitItem()
	if not self.tbWaiyiLimitItem then
		self.tbWaiyiLimitItem = LoadTabFile("Setting/Item/WaiyiLimitColor.tab", "ddd", "LimitColorItem", {"LimitColorItem", "OrgColorItem", "Position"});
	end

	return self.tbWaiyiLimitItem
end

function tbChangeColor:GetWaiyiBgSetting()
	if not self.tbWaiyiBg then
		self.tbWaiyiBg = LoadTabFile("Setting/Item/WaiyiBg.tab", "dsssssdds", "BgId", {"BgId", "BgName",
		"BgTipsPic","BgSmallPic","BgTexture","ViewBgTexture", "EffectId","EffectIdView", "RequirementText",});
	end
	return self.tbWaiyiBg
end

function tbChangeColor:GetColorItemAndSortGroup( )

	if not self.tbColorItem or not self.tbSortGroup or not self.tbConsume then
		self.tbColorItem = {};
		self.tbSortGroup = {};
		self.tbConsume = {};
		local szParam = "dddd"
		local tbConlumn = {"ChangeId", "Part","Genre" ,"CharmExtern"}
		for i = 1, self.MAX_COLOR do
			szParam = szParam.."ddd";
			table.insert(tbConlumn, "ColorItem"..i);
			table.insert(tbConlumn, "ConsumeItem"..i);
			table.insert(tbConlumn, "ConsumeCount"..i);
		end
		for i = 1, self.MAX_FACTION do
			szParam = szParam.."ss";
			table.insert(tbConlumn, "NameFacionMale"..i);
			table.insert(tbConlumn, "NameFacionFemale"..i)
		end
		local tbSetting = LoadTabFile("Setting/Item/WaiyiColor.tab", szParam, nil, tbConlumn);
		for _, tbInfo in ipairs(tbSetting) do
			local tbGroup = {nId = tbInfo.ChangeId, nPart = tbInfo.Part,nGenre = tbInfo.Genre,nCharmExtern = tbInfo.CharmExtern,
				tbItemList = {}, tbNameList = {}, tbItemSort = {}};
			table.insert(self.tbSortGroup , tbGroup);
			for i = 1, self.MAX_COLOR do
				local nItemId = tbInfo["ColorItem"..i];
				--local szItemName = tbInfo["ColorName"..i];
				if nItemId and nItemId > 0 then
					if not self.tbColorItem[nItemId] then
						self.tbColorItem[nItemId] = tbGroup;
						local nConsumeItem, nConsumeCount = tbInfo["ConsumeItem"..i], tbInfo["ConsumeCount"..i]
						self.tbConsume[nItemId] = { nConsumeItem, nConsumeCount };
						tbGroup.tbItemList[nItemId] = true;
						table.insert(tbGroup.tbItemSort, nItemId);
					else
						Log("Equip Color is Already Exist!!!", nItemId);
					end
				end
			end
			for i = 1, self.MAX_FACTION do
				tbGroup.tbNameList[i] = { tbInfo["NameFacionMale"..i], tbInfo["NameFacionFemale"..i]};
			end
		end
	end
	return  self.tbColorItem, self.tbSortGroup, self.tbConsume
end

function tbChangeColor:CanChangeColor(dwTemplateId)
	local tbColorItem = self:GetColorItemAndSortGroup()
	if not tbColorItem[dwTemplateId] then
		return false;
	end
	return true;
end

function tbChangeColor:GetConsumeInfo(dwTemplateId)
	local _,_,tbConsume = self:GetColorItemAndSortGroup()
	if not tbConsume[dwTemplateId] then
		return ;
	end
	return unpack(tbConsume[dwTemplateId])
end

function tbChangeColor:GetLimitItemInfo(dwTemplateId)
	local tbWaiyiLimitItem = self:GetWaiyiLimitItem()
	return tbWaiyiLimitItem[dwTemplateId];
end

function tbChangeColor:GetChangeId(dwTemplateId)
	local tbColorItem = self:GetColorItemAndSortGroup()
	if tbColorItem[dwTemplateId] then
		return tbColorItem[dwTemplateId].nId
	end
end

function tbChangeColor:GetChangePart(dwTemplateId)
	local tbColorItem = self:GetColorItemAndSortGroup()
	if tbColorItem[dwTemplateId] then
		return tbColorItem[dwTemplateId].nPart
	end
end

function tbChangeColor:GetWaiZhuanRes(dwTemplateId, nFaction, nSex)
	local szName,_,_,_,nResId,nEffectResId = Item:GetItemTemplateShowInfo(dwTemplateId, nFaction or 0, nSex or 0)
	return nResId,nEffectResId
end

function tbChangeColor:DoChangeColorDialogCallback(nItemId, nTargetId, bConfirm)
	self:DoChangeColor(me, nItemId, nTargetId, bConfirm)
end

function tbChangeColor:DoChangeColor(pPlayer, nItemId, nTargetId, bConfirm)
	local pItem;
	local tbItemGroup = {}
	local tbColorItem = self:GetColorItemAndSortGroup()
	local tbInfo = tbColorItem[nTargetId]
	local nConsumeItem, nConsumeCount = self:GetConsumeInfo(nTargetId)
	if not tbInfo then
		return;
	end

	if not (nConsumeItem and nConsumeCount and nConsumeItem > 0 and nConsumeCount > 0) then
		print("For free?", nConsumeCount, nConsumeItem)
		return;		-- 应该没有免费染色的
	end

	local tbOptList = {}
	for nId, _ in pairs(tbInfo.tbItemList) do
		local tbItemList = pPlayer.FindItemInPlayer(nId)
		for _, pCurItem in pairs(tbItemList) do
			if pCurItem.dwTemplateId == nTargetId then
				pPlayer.CenterMsg("此外装您已经拥有了这款颜色。");
				return;
			end
			local szName = Item:GetItemTemplateShowInfo(nId, pPlayer.nFaction, pPlayer.nSex)
			table.insert(tbItemGroup, pCurItem)
			table.insert(tbOptList, {Text = szName, Callback = self.DoChangeColorDialogCallback, Param = {self, pCurItem.dwId, nTargetId, true}})
		end
	end
	pItem = pPlayer.GetItemInBag(nItemId);

	if not pItem then
		pPlayer.CenterMsg("外装不存在！")
		return;
	end
	if not self:CanChangeColor(pItem.dwTemplateId) then
		pPlayer.CenterMsg("该装备不可染色！")
		return
	end

	if not tbInfo.tbItemList[pItem.dwTemplateId] then
		pPlayer.CenterMsg("此外装不能染为目标颜色");
		return;
	end

	if not self:CanColorItemShow(pPlayer, nTargetId) then
		pPlayer.CenterMsg("不存在该外装偏色");
		return;
	end

	if pPlayer.ConsumeItemInBag(nConsumeItem, nConsumeCount, Env.LogWay_ChangeColor, nil, nTargetId) < nConsumeCount then
		local tbBaseProp = KItem.GetItemBaseProp(nConsumeItem);
		pPlayer.CenterMsg(string.format("您身上的%s不足，不能进行染色", tbBaseProp.szName));
		return;
	end

	local nTimeOut = pItem.GetTimeOut()
    pPlayer.AddItem(nTargetId, 1, nTimeOut, Env.LogWay_ChangeColor)

	self:UpdateRank(pPlayer)
	pPlayer.CenterMsg("染色成功！");
end

function tbChangeColor:ItemHasShowColor(pItem, nPos)
	local nSaveValue = pItem.GetIntValue(self.ITEM_INT_VALUE_WAIYI_LIMIT);
	return KLib.GetBit(nSaveValue, nPos) == 1;
end

function tbChangeColor:CanColorItemShow(pPlayer, dwTemplateId)
	local tbLimitInfo = self:GetLimitItemInfo(dwTemplateId);
	if not tbLimitInfo then
		return true;
	end

	local pOrgColorItem = unpack(pPlayer.FindItemInPlayer(tbLimitInfo.OrgColorItem) or {});
	if not pOrgColorItem then
		return false;
	end

	return self:ItemHasShowColor(pOrgColorItem, tbLimitInfo.Position);
end

function tbChangeColor:AddShowColor(pPlayer, nTargetId)
	local tbLimitInfo = self:GetLimitItemInfo(nTargetId);
	if not tbLimitInfo then
		pPlayer.CenterMsg("对应外装偏色不存在");
		return false;
	end

	local szOrgItemName = Item:GetItemTemplateShowInfo(tbLimitInfo.OrgColorItem, pPlayer.nFaction, pPlayer.nSex);
	local pOrgColorItem = unpack(pPlayer.FindItemInPlayer(tbLimitInfo.OrgColorItem) or {});
	if not pOrgColorItem then
		pPlayer.CenterMsg(string.format("您尚未拥有初始外装[ffff00]%s[-]，请收藏该外装后再试试", szOrgItemName))
		return false;
	end

	if self:ItemHasShowColor(pOrgColorItem, tbLimitInfo.Position) then
		pPlayer.CenterMsg("你已经学习过该染色方案，不可重复学习哦");
		return false;
	end

	local nSaveValue = pOrgColorItem.GetIntValue(self.ITEM_INT_VALUE_WAIYI_LIMIT);
	nSaveValue = KLib.SetBit(nSaveValue, tbLimitInfo.Position, 1);
	pOrgColorItem.SetIntValue(self.ITEM_INT_VALUE_WAIYI_LIMIT, nSaveValue);

	local szItemName = Item:GetItemTemplateShowInfo(nTargetId, pPlayer.nFaction, pPlayer.nSex);
	pPlayer.CenterMsg(string.format("您已学会[ffff00]%s[-]的染色方案，记得染色后使用该外装哦！", szItemName));
	return true;
end

function tbChangeColor:GetTotalCharm(tbAllWaiyi, pPlayer)
	local tbChangeId = {}
	local tbHasWaiyi = {}
	local nTotalCharm = self.INIT_CHARM_VALUE;		-- 角色初始魅力值
	local tbColorItem = self:GetColorItemAndSortGroup()
	for _, pCurItem in pairs(tbAllWaiyi)do
		local nTemplateId = pCurItem.dwTemplateId

		if (not tbHasWaiyi[nTemplateId]) and (tbColorItem[nTemplateId]) then
			tbHasWaiyi[nTemplateId] = true;
			local nChangeId = tbColorItem[nTemplateId].nId
			local nCharmFirst, nCharmNext = self:GetCharmInfo(nTemplateId)
			if not tbChangeId[nChangeId] then
				tbChangeId[nChangeId] = true;
				nTotalCharm = nTotalCharm + nCharmFirst
			else
				nTotalCharm = nTotalCharm + nCharmNext
			end
		end
	end
	return nTotalCharm;
end

function tbChangeColor:GetCharmInfo(dwTemplateId)
	if not self.tbCharm[dwTemplateId] then
		local nConsumeItem, nConsumeCount = self:GetConsumeInfo(dwTemplateId)
		if nConsumeItem and nConsumeItem > 0 and nConsumeCount and nConsumeCount > 0 then
			local tbItemInfo = KItem.GetItemBaseProp(nConsumeItem)
			if tbItemInfo then
				local nItemCharm = math.floor(tbItemInfo.nValue * nConsumeCount / 100000);
				local tbColorItem = self:GetColorItemAndSortGroup()
				self.tbCharm[dwTemplateId] = { (tbColorItem[dwTemplateId].nCharmExtern or 0) + nItemCharm, nItemCharm};
			end
		end
	end
	if self.tbCharm[dwTemplateId] then
		return unpack(self.tbCharm[dwTemplateId])
	end
end

tbChangeColor.tbTypeToAchieve = {
	[Item.EQUIP_WAIYI] = "Clothes_1";
	[Item.EQUIP_WAI_WEAPON] = "Arms_1";
	[Item.EQUIP_WAI_HEAD] = "Hat_1";
	[Item.EQUIP_WAI_HORSE] = "Horse_1";
}

function tbChangeColor:UpdateRank(pPlayer)
	local nOldCharm = self:GetCacheCharm(pPlayer)
	local nTotalCharm, tbTypeCount = self:GetCacheCharm(pPlayer, true)
	Achievement:SetCount(pPlayer, "Charm_1", nTotalCharm)
	if tbTypeCount then
		for k,v in pairs(self.tbTypeToAchieve) do
			local nConut = tbTypeCount[k]
			if nConut then
				Achievement:SetCount(pPlayer, v, nConut)
			end
		end
	end
	RankBoard:UpdateRankVal("Charm", pPlayer.dwID, nTotalCharm)
	pPlayer.CallClientScript("Ui:OpenWindow", "CharmTip", nTotalCharm, nOldCharm)
end

function tbChangeColor:GetCacheCharm(pPlayer, bForceUpdate)
	local tbTypeCount;
	if not pPlayer.nCacheCharm or bForceUpdate  then
		local tbAllWaiyi = pPlayer.FindItemInPlayer("waiyi");
		tbTypeCount = {};
		for i,v in ipairs(tbAllWaiyi) do
			tbTypeCount[v.nItemType] = (tbTypeCount[v.nItemType] or 0) + 1
		end
		pPlayer.nCacheCharm = self:GetTotalCharm(tbAllWaiyi, pPlayer);
	end
	return pPlayer.nCacheCharm, tbTypeCount
end

function tbChangeColor:UnlockBg(pPlayer, nBgId)
	local tbWaiyiBg = self:GetWaiyiBgSetting()
	if not tbWaiyiBg[nBgId] then
		return;
	end
	if nBgId <= 32 and nBgId > 0 then
		local nValue = pPlayer.GetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB)
		nValue = KLib.SetBit(nValue, nBgId, 1)
		pPlayer.SetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB, nValue)
		return true
	end
end

function tbChangeColor:IsUnlockedBg(pPlayer, nBgId)
	if nBgId == 1 then
		return true;	-- 第一张图默认是开启的
	end
	if nBgId <= 32 and nBgId > 0 then
		local nValue = pPlayer.GetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB)
		return (KLib.GetBit(nValue, nBgId, 1) == 1);
	end
end

function tbChangeColor:ChangeWaiyiBg(pPlayer, nBgId)
	if not self:IsUnlockedBg(pPlayer, nBgId) then
		return;
	end
	pPlayer.SetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB_SELECT, nBgId)
	local pAsync = KPlayer.GetAsyncData(pPlayer.dwID)
	if pAsync then
		pAsync.SetWaiyiBgId(nBgId)
	end

	pPlayer.CallClientScript("Item.tbChangeColor:UpdateBg")
end

function tbChangeColor:GetWaiyiBg(pPlayer)
	local nGbId = pPlayer.GetUserValue(self.GROUP_WAIYI_GB, self.VALUE_WAIYI_GB_SELECT)
	if nGbId == 0 then
		nGbId = 1;
	end

	return nGbId;
end

function tbChangeColor:UpdateBg()
	local tbUi = Ui("WaiyiPreview")
	if tbUi and Ui:WindowVisible("WaiyiPreview") then
		tbUi:UpdateBg();
	end
end

function tbChangeColor:OnLogin( pPlayer )
	local nVal = pPlayer.GetUserValue(self.GROUP_HIDE_PART,self.KEY_HIDE_PART)
	if nVal == 0 then
		return
	end
	local tbBit = KLib.GetBitTB(nVal)
	for nPart = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
		local nBitVal = tbBit[nPart + 1]
		if nBitVal == 1 then
			--pPlayer.HideEquipResPart(nPart,1)
		end
	end
end

function tbChangeColor:ChangeResPartHide( pPlayer, nPart ,nHide)
	if nHide ~= 0 and nHide ~= 1 then
		Log(debug.traceback(), nPart, nHide, pPlayer.dwID)
		return
	end
	local nVal = pPlayer.GetUserValue(self.GROUP_HIDE_PART,self.KEY_HIDE_PART)
	nVal = 	KLib.SetBit(nVal,nPart + 1, nHide)
	if MODULE_GAMESERVER then
		pPlayer.SetUserValue(self.GROUP_HIDE_PART,self.KEY_HIDE_PART,nVal)
	end

	--pPlayer.HideEquipResPart(nPart,nHide)
end

function tbChangeColor:IsResPartHide( pPlayer, nPart )
	--local nVal = pPlayer.GetUserValue(self.GROUP_HIDE_PART,self.KEY_HIDE_PART)
	--return KLib.GetBit(nVal,nPart + 1) == 1
	return false;
end