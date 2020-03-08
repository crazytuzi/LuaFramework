Require("CommonScript/Item/Define.lua")

Item.tbItemRecovery 	= Item.tbItemRecovery or {};
local tbItemRecovery 	= Item.tbItemRecovery;

tbItemRecovery.nActStartTime = Lib:ParseDateTime("2019.6.6 4:00:00")
tbItemRecovery.nEndRecoveryTime = Lib:ParseDateTime("2019.6.17 12:00:00")

tbItemRecovery.SAVE_GROUP = 194
tbItemRecovery.SAVE_KEY = {
	[1] = {1,2}; --分别对应道具id 和道具id各个档位的回收bit ，一开始设置1，如果全部是0时，则清空道具id
	[2] = {3,4};
}

tbItemRecovery.tbFinishExtAwardMail = {
	Title = "端午节礼包异常处理";
	tbAttach = { {"item", 10935, 1}  };
	Text = "尊敬的少侠，您已成功回收全部异常礼包，感谢您的配合，特补发您一份[ffff00]端午暖心礼包[-]，请注意查收附件！";
};

tbItemRecovery.nMaxDebtSilverBoard = 6900;--单个礼包最多扣除的黎饰

tbItemRecovery.tbItemToIndex = {
	[10923] = 5;
	[10924] = 5;
	[10930] = 6;
	[10925] = 5;
	[10931] = 6;
	[10926] = 5;
	[10932] = 6;
};

--等价可兑换商品表
tbItemRecovery.tbEqualItemList = {
	--随机短篇
	--5级魂石任选
	--洗髓经任选
	--真气元气贡献任选
	--传承秘本
	[10941] = {
	 	[10938] = 1;
		[10939] = 1;
		[10940] = 1;
	};
	[10590] = {
		[10586] = 1;
		[10587] = 1;
		[10588] = 1;
	};
	[7670] = { 	--五级魂石任选箱
		[6126] = 1;
		[6127] = 1;
		[6112] = 1;
		[4849] = 1;
		[4595] = 1;
		[4053] = 1;
		[2827] = 1;
		[2828] = 1;
		[3897] = 1;
		[7377] = 1;
		[7648] = 1;
		[9401] = 1;
	};
	[6533] = { --货币任选
		[6188] = 1;
		[6536] = 1;
		[7070] = 1;
	};
	[7420] = {
		[3714] = 1;
		[3715] = 1;
		[3716] = 1;
	};
	[9313] = {
		[7970] = 1;
	};
}

tbItemRecovery.tbMoneyTypeItem = {
	[6188] = {"ZhenQi", 20000};
	[6536] = {"Energy", 20000};
	[7070] = {"Contrib",20000} ;
};

tbItemRecovery.tbCurRevoryRandItemList = {
	[10925] = {
		{Item = 10912;  nPrice = 4050}; --本音，要能对应到已镶嵌的
		{Item = 10014;  nPrice = 600};
		{Item = 10014;  nPrice = 600};
		{Item = 10941;  nPrice = 2500}; --随机短篇，包含鉴定出的
	};
	[10926] = {
		{Item = 10912;  nPrice = 4050};
		{Item = 10014;  nPrice = 600};
		{Item = 10014;  nPrice = 600};
		{Item = 10590;  nPrice = 3000};
	};
	[10932] = {
		{Item = 10912;  nPrice = 4050};
		{Item = 10014; nPrice = 600};
		{Item = 10014; nPrice = 600};
		{Item = 7670;  nPrice = 2000};
		{Item = 6533;  nPrice = 1000};
	};
	[10924] = {
		{Item = 7670; nPrice = 3050};
		{Item = 2804; nPrice = 300}; --和氏璧
		{Item = 2804; nPrice = 300}; --和氏璧
		{Item = 2804; nPrice = 300}; --和氏璧
		{Item = 2804; nPrice = 300}; --和氏璧
		{Item = 2804; nPrice = 300}; --和氏璧
		{Item = 10941; nPrice = 3000};
	};
	[10923]= { 
		{Item = 7670; nPrice = 4050};
		{Item = 3564; nPrice = 1500}; --双倍重置令
		{Item = 7536; nPrice = 60}; --至尊礼包邀请
		{Item = 7420; nPrice = 500}; --洗髓经任选
		{Item = 6533; nPrice = 1000};
	};
	[10931] = {
		{Item = 10912;  nPrice = 4050};
		{Item = 10014;  nPrice = 600};
		{Item = 10014;  nPrice = 600};
		{Item = 7670;  nPrice = 2000};
		{Item = 6533;  nPrice = 1000};
	};
	[10930] = {
		{Item = 7670;  nPrice = 3050};
		{Item = 2804;  nPrice = 300};
		{Item = 2804;  nPrice = 300};
		{Item = 2804;  nPrice = 300};
		{Item = 2804;  nPrice = 300};
		{Item = 2804;  nPrice = 300};
		{Item = 9313;  nPrice = 2000}; --传承秘本
		{Item = 6533;  nPrice = 1000};
	};
}

function tbItemRecovery:LoadList(  )
	local nNow = GetTime()
	if nNow > self.nEndRecoveryTime then
		Log("Error! tbItemRecovery:LoadList EndRecoveryTime ")
		return
	end
	local tbFile = LoadTabFile("HotFix/FinalRoleItem.tab", "dddd", nil, {"ServerId", "RoleId","Item1","Item2"},1,1);
	local nServerId = GetServerIdentity()
	for _,v in ipairs(tbFile) do
		if nServerId == v.ServerId then
			local pPlayer = KPlayer.GetPlayerObjById(v.RoleId)
			if pPlayer then
				self:AddRecoveryToPlayer(pPlayer, v.Item1,v.Item2)
			else
				local szCmd = string.format("Item.tbItemRecovery:OnDelayCmdAddRecoveryToPlayer('%d','%d')",v.Item1,v.Item2)
				KPlayer.AddDelayCmd(v.RoleId, szCmd, string.format("%s|%s|%s", "DuanWuGiftRecoveryDelay", v.Item1,v.Item2));
				Log("tbItemRecovery: Player Offline add", v.RoleId, v.Item1,v.Item2)
			end
		end
	end
end

function tbItemRecovery:CheckStartEndTimer(  )
	local nNow = GetTime()
	if nNow > self.nEndRecoveryTime then
		Log("tbItemRecovery:CheckStartEndTimer EndRecoveryTime ")
		return
	end
	if self.nTimerEndRecovery then
		Log("tbItemRecovery:CheckStartEndTimer Have Timer ")
		return
	end
	self.nTimerEndRecovery = Timer:Register(Env.GAME_FPS * (self.nEndRecoveryTime - nNow), self.OnEndItemRecovery, self)
	Log("tbItemRecovery:CheckStartEndTimer StartTimer")
end

function tbItemRecovery:OnEndItemRecovery(  )
	self.nTimerEndRecovery = nil;
	local tbFile = LoadTabFile("HotFix/FinalRoleItem.tab", "dddd", nil, {"ServerId", "RoleId","Item1","Item2"},1,1);
	local nServerId = GetServerIdentity()
	for _,v in ipairs(tbFile) do
		if nServerId == v.ServerId then
			local pPlayer = KPlayer.GetPlayerObjById(v.RoleId)
			if pPlayer then
				self:OnEndItemRecoveryPlayer(pPlayer)
			else
				local szCmd = "Item.tbItemRecovery:OnDelayCmdEndItemRecoveryPlayer()"
				KPlayer.AddDelayCmd(v.RoleId, szCmd,"DuanWuGiftRecoveryEndDelay");
				Log("tbItemRecoveryEnd: Player Offline add", v.RoleId)
			end
		end
	end
end

function tbItemRecovery:OnDelayCmdEndItemRecoveryPlayer( )
	self:OnEndItemRecoveryPlayer(me)
end

function tbItemRecovery:OnEndItemRecoveryPlayer( pPlayer )
	local bNeddDebt = false
	local szMailContext = "";
	for _,v in ipairs(self.SAVE_KEY) do
		local nRecycleBit = pPlayer.GetUserValue(self.SAVE_GROUP, v[2]);
		if nRecycleBit ~= 0 then
			local nRecycleItemId = pPlayer.GetUserValue(self.SAVE_GROUP, v[1]);
			bNeddDebt = true;
			--回收了哪些道具，总共要扣除多少黎饰，扣除不超过6900
			local tbHasRecycleItemList = {};
			local tbHasNotRecycleItemList = {}
			local nDebtSilverBoard = 0;
			local tbSubItemList = self.tbCurRevoryRandItemList[nRecycleItemId]
			local tbBit = KLib.GetBitTB(nRecycleBit)
			local tbItemBase = KItem.GetItemBaseProp(nRecycleItemId)
			szMailContext = string.format("%s异常获得[ffff00]%s[-]的回收情况：", szMailContext, tbItemBase.szName)
			for i2, v2 in ipairs(tbSubItemList) do
				local tbItemBase = KItem.GetItemBaseProp(v2.Item)
				if tbBit[i2] == 1 then
					nDebtSilverBoard = nDebtSilverBoard + v2.nPrice
					table.insert(tbHasNotRecycleItemList, tbItemBase.szName)
				else
					table.insert(tbHasRecycleItemList, tbItemBase.szName)
				end
			end
			
			nDebtSilverBoard = math.min(self.nMaxDebtSilverBoard, nDebtSilverBoard)
			szMailContext = string.format("%s\n本次成功回收的道具有：%s\n未回收的道具有：%s\n根据价值折算后，该礼包需扣除黎饰%d。\n\n", szMailContext, table.concat(tbHasRecycleItemList, "、"), table.concat(tbHasNotRecycleItemList, "、"), nDebtSilverBoard)
			Player:AddMoneyDebt(pPlayer.dwID, "SilverBoard", nDebtSilverBoard, Env.LogWay_ItemRecovery, nRecycleItemId, true)
			pPlayer.SetUserValue(self.SAVE_GROUP, v[1], 0);
			pPlayer.SetUserValue(self.SAVE_GROUP, v[2], 0);

			Log("tbItemRecovery:OnEndItemRecoveryPlayer", pPlayer.dwID, nRecycleItemId, nDebtSilverBoard,  table.concat( tbBit, ","))
		end
	end
	if bNeddDebt then
		szMailContext = string.format("%s我们已为少侠发放了[ffff00]端午暖心礼包[-]，请注意领取。感谢您的理解和支持！",szMailContext)
		local tbFinishExtAwardMail = Lib:CopyTB(self.tbFinishExtAwardMail) 
		tbFinishExtAwardMail.To = pPlayer.dwID;
		tbFinishExtAwardMail.Text = szMailContext
		Mail:SendSystemMail( tbFinishExtAwardMail )
		pPlayer.CallClientScript("Player:ServerSyncData", "UpdateTopButton")
	end
end

function tbItemRecovery:OnDelayCmdAddRecoveryToPlayer( item1,item2 )
	self:AddRecoveryToPlayer(me, tonumber(item1), tonumber(item2) )
end

function tbItemRecovery:AddRecoveryToPlayer( pPlayer, item1, item2 )
	--先检查玩家是否是合法的回收玩家
	local tbFromItems = {item1, item2}
	local tbValidItemIds = {};
	for _,itemid in ipairs(tbFromItems) do
		local index1 = self.tbItemToIndex[itemid]
		if index1 then
			local tbBuyInfo = Recharge.tbSettingGroup.YearGift[index1]
			local nLocalEndTime = pPlayer.GetUserValue(Recharge.SAVE_GROUP, tbBuyInfo.nEndTimeKey)
			if nLocalEndTime < self.nActStartTime then
				table.insert(tbValidItemIds, itemid)
			end
		end	
	end
	if not next(tbValidItemIds) then
		Log("tbItemRecovery:AddRecoveryToPlayer not Valid Role", pPlayer.dwID, item1, item2)
		return
	end

	for i,nItemId in ipairs(tbValidItemIds) do
		local tbKeys = self.SAVE_KEY[i]
		local tbSubItemList = self.tbCurRevoryRandItemList[nItemId]
		local nGiveToSysBit = 0;
		for i2,v2 in ipairs(tbSubItemList) do
			nGiveToSysBit = KLib.SetBit(nGiveToSysBit, i2, 1)
		end
		pPlayer.SetUserValue(self.SAVE_GROUP, tbKeys[1], nItemId)
		pPlayer.SetUserValue(self.SAVE_GROUP, tbKeys[2], nGiveToSysBit)
	end
	pPlayer.CallClientScript("Player:ServerSyncData", "UpdateTopButton")
	
	Log("tbItemRecovery:AddRecoveryToPlayer Valid", pPlayer.dwID, unpack(tbValidItemIds))
end

function tbItemRecovery:IsShowUi( pPlayer )
	for i,v in ipairs(self.SAVE_KEY) do
		if pPlayer.GetUserValue(self.SAVE_GROUP,v[1]) ~= 0 then
			return true
		end
	end
	return false
end

function tbItemRecovery:GetTarItemIdFromData( tbData, pPlayer)
	if tbData.org then
		return tbData.org
	end
	if tbData.nTemplateId then
		return tbData.nTemplateId
	end
	if tbData.nItemId then
		local pItem = pPlayer.GetItemInBag(tbData.nItemId)
		if not pItem then
			return 
		end
		return pItem.dwTemplateId
	end
end

function tbItemRecovery:GetCurItemLeftSubList( pPlayer, index)
	local tbSaveKeys = self.SAVE_KEY[index]
	local nItemId = pPlayer.GetUserValue(self.SAVE_GROUP,tbSaveKeys[1])
	if nItemId == 0 then
		return {},{}
	end
	local nGiveBit = pPlayer.GetUserValue(self.SAVE_GROUP, tbSaveKeys[2]) 
	local tbBit = KLib.GetBitTB(nGiveBit)
	local tbSubItemList = tbItemRecovery.tbCurRevoryRandItemList[nItemId]
	local tbNeedRecoveryIndex = {} --顺序对应是否需要回收
	local tbNeedItemCount = {}
	for i,v in ipairs(tbSubItemList) do
		local nCurBit = tbBit[i]
		tbNeedRecoveryIndex[i] = nCurBit
		if nCurBit == 1 then
			tbNeedItemCount[v.Item] = (tbNeedItemCount[v.Item] or 0) + 1;
		end
	end
	return tbNeedRecoveryIndex, tbNeedItemCount
end

tbItemRecovery.tbDataCheckFunc = {
	["itemId"] = function ( tbData, pPlayer)
		local pItem = pPlayer.GetItemInBag(tbData.nItemId)
		if not pItem then
			return false, "道具不存在"
		end
		if pItem.nCount < tbData.nCount then
			return false, "道具数量不足"
		end
		if pItem.dwTemplateId ~= tbData.nTemplateId then
			return false, "非法数据"
		end
		return true
	end;
	["InsetStoneId"] = function (tbData, pPlayer )
		local tbInsetInfo = pPlayer.GetInsetInfo(tbData.nEquipPos)
		if tbInsetInfo[tbData.nInsetPos] ~= tbData.nTemplateId then
			return
		end
		return true
	end;
	["sameItemId"] = function ( tbData, pPlayer )
		if not tbData.org then
			return
		end
		local tbSame = tbItemRecovery.tbEqualItemList[tbData.org]
		if not tbSame then
			return
		end
		local pItem = pPlayer.GetItemInBag(tbData.nItemId)
		if not pItem then
			return false, "道具不存在"
		end
		if pItem.nCount < tbData.nCount then
			return false, "道具数量不足"
		end
		if pItem.dwTemplateId ~= tbData.nTemplateId then
			return false, "非法数据"
		end
		if not tbSame[pItem.dwTemplateId] then
			return
		end
		return true
	end;
	["sameInsetStoneId"] = function ( tbData, pPlayer )
		if not tbData.org then
			return
		end
		local tbSame = tbItemRecovery.tbEqualItemList[tbData.org]
		if not tbSame then
			return
		end
		if not tbSame[tbData.nTemplateId] then
			return
		end
		local tbInsetInfo = pPlayer.GetInsetInfo(tbData.nEquipPos)
		if tbInsetInfo[tbData.nInsetPos] ~= tbData.nTemplateId then
			return
		end
		return true
	end;
	["FakeMoneyItem"] = function ( tbData, pPlayer)
		local tbMoneyInfo = tbItemRecovery.tbMoneyTypeItem[tbData.nTemplateId] 
		if not tbMoneyInfo then
			return
		end
		return true
	end;
};

tbItemRecovery.tbDataRecoverFunc = {
	["itemId"] = function ( tbData, pPlayer)
		local pItem = pPlayer.GetItemInBag(tbData.nItemId)
		if  pItem then
			local nIsEquip = pItem.IsEquip()
			pPlayer.ConsumeItem(pItem, tbData.nCount, Env.LogWay_ItemRecovery, tbData.nTarItemId)		
			if nIsEquip == 1 then
				FightPower:ChangeFightPower("JueXue", pPlayer);
			end
		end
	end;
	["InsetStoneId"] = function (tbData, pPlayer )
		StoneMgr:ForceRemoveInset( pPlayer, tbData.nEquipPos, tbData.nInsetPos)
	end;
	["sameItemId"] = function ( tbData, pPlayer )
		local pItem = pPlayer.GetItemInBag(tbData.nItemId)
		if  pItem then
			local nIsEquip = pItem.IsEquip()
			pPlayer.ConsumeItem(pItem, tbData.nCount, Env.LogWay_ItemRecovery, tbData.nTarItemId)		
			if nIsEquip == 1 then
				FightPower:ChangeFightPower("JueXue", pPlayer);
			end
		end
	end;
	["sameInsetStoneId"] = function ( tbData, pPlayer )
		StoneMgr:ForceRemoveInset( pPlayer, tbData.nEquipPos, tbData.nInsetPos)
	end;
	["FakeMoneyItem"] = function ( tbData, pPlayer)
		local tbMoneyInfo = tbItemRecovery.tbMoneyTypeItem[tbData.nTemplateId] 
		Player:AddMoneyDebt(pPlayer.dwID, tbMoneyInfo[1], tbMoneyInfo[2], Env.LogWay_ItemRecovery, tbData.nTarItemId, true)
	end;
}

function tbItemRecovery:CheckRecovery(pPlayer, tbDatas, index)
	local tbNeedRecoveryIndex, tbNeedItemCount = self:GetCurItemLeftSubList(pPlayer, index)
	if not next(tbNeedItemCount) then
		return false, "当前无可回收道具"
	end
	for i,v in ipairs(tbDatas) do
		local type = v.type
		local fnFunc = self.tbDataCheckFunc[type]
		if not fnFunc then
			return false, "无效的数据类型"
		end
		if not v.nCount or v.nCount <= 0 then
			return false, "无效的道具数量"
		end
		local bRet, szMsg = fnFunc(v, pPlayer)
		if not bRet then
			szMsg = szMsg or "无效的回收数据"
			return bRet, szMsg
		end
		local dwTemplateId = tbItemRecovery:GetTarItemIdFromData(v, pPlayer)
		if not dwTemplateId then
			return
		end
		local nNeedCount = tbNeedItemCount[dwTemplateId]
		if not nNeedCount then
			return false ,"放入了无效的道具"
		end
		if nNeedCount < v.nCount then
			return false, "放入的道具数过多"
		end
		tbNeedItemCount[dwTemplateId] = nNeedCount - v.nCount
	end
	return true;
end

function tbItemRecovery:OnRequestItemRecovery( pPlayer, tbDatas, index )
	local bRet, szMsg = self:CheckRecovery(pPlayer, tbDatas, index )
	if not bRet then
		pPlayer.CenterMsg(szMsg, true)
		return
	end
	local tbSaveKeys = self.SAVE_KEY[index]
	local nRecycleItemId = pPlayer.GetUserValue(self.SAVE_GROUP, tbSaveKeys[1]) 
	local nGiveBit = pPlayer.GetUserValue(self.SAVE_GROUP, tbSaveKeys[2]) 
	local tbNeedRecoveryIndex = self:GetCurItemLeftSubList(pPlayer, index)
	local tbSubItemList = self.tbCurRevoryRandItemList[nRecycleItemId]
	for i,v in ipairs(tbDatas) do
		v.nTarItemId = nRecycleItemId;
		local dwTemplateId = tbItemRecovery:GetTarItemIdFromData(v, pPlayer)
		local fnFunc = self.tbDataRecoverFunc[v.type]
		fnFunc(v, pPlayer)
		for i2=1,v.nCount do
			local nIndex = self:GetRecoveryBitIndex(tbNeedRecoveryIndex,tbSubItemList,dwTemplateId)
			tbNeedRecoveryIndex[nIndex] = 0;
			nGiveBit = KLib.SetBit(nGiveBit, nIndex, 0)
		end
		Log("tbItemRecovery:OnRequestItemRecovery subItem", pPlayer,nRecycleItemId, dwTemplateId, v.nCount, v.type, v.nItemId,v.nTemplateId);
	end
	pPlayer.SetUserValue(self.SAVE_GROUP, tbSaveKeys[2], nGiveBit)
	if nGiveBit == 0 then
		pPlayer.SetUserValue(self.SAVE_GROUP, tbSaveKeys[1], 0)
		Log("tbItemRecovery:OnRequestItemRecovery ClearItem", pPlayer,nRecycleItemId);
		if not self:IsShowUi(pPlayer) then
			self:SendRecoveryExtAward(pPlayer)
		end
	end
	pPlayer.CenterMsg("回收道具成功！")
	pPlayer.CallClientScript("Player:ServerSyncData", "UpdateTopButton")
end

function tbItemRecovery:GetRecoveryBitIndex( tbNeedRecoveryIndex, tbSubItemList , dwTemplateId)
	for i,v in ipairs(tbSubItemList) do
		if dwTemplateId == v.Item and tbNeedRecoveryIndex[i] == 1 then
			return i;
		end
	end
end

function tbItemRecovery:SendRecoveryExtAward( pPlayer )
	local tbFinishExtAwardMail = Lib:CopyTB(self.tbFinishExtAwardMail) 
	tbFinishExtAwardMail.To = pPlayer.dwID;
	Mail:SendSystemMail( tbFinishExtAwardMail )
	Log("tbItemRecovery:SendRecoveryExtAward", pPlayer.dwID)	
end

function tbItemRecovery:CheckRedPoint( )
	local bShowRed = false
	local bShow = Item.tbItemRecovery:IsShowUi( me )
	if bShow and Client:GetFlag("SeeItemRecoveryDay") ~= Lib:GetLocalDay() then
		bShowRed = true;
	end
	if bShowRed  then
		Ui:SetRedPointNotify("BtnRecovery")
	else
		Ui:ClearRedPointNotify("BtnRecovery")
	end
end