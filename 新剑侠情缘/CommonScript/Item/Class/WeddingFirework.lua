local tbItem = Item:GetClass("WeddingFirework");

tbItem.nPlayDis = 2000

function tbItem:OnUse(it)
	if not it.dwTemplateId then
		return
	end

	local pNpc = me.GetNpc()
	if not pNpc then
		return
	end

	local nEffectId= KItem.GetItemExtParam(it.dwTemplateId, 1);
	if not nEffectId then
		return
	end

	local bRet, szMsg = self:CheckCanUse(me)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	local nNowTime = GetTime()
	me.nPlayWeddingFireworkTime = me.nPlayWeddingFireworkTime or 0
	local nPlayInterval = nNowTime - me.nPlayWeddingFireworkTime
	if nPlayInterval < 3 then
		me.CenterMsg(string.format("[FFFE0D]%s秒[-]之后才可燃放", 3 - nPlayInterval > 0 and 3 - nPlayInterval or 0))
		return
	end
	local nCount = it.nCount
	local nItemId = it.dwId
	local nConsumeCount = me.ConsumeItem(it, 1, Env.LogWay_WeddingFirework);
	if nConsumeCount ~= 1 then
		Log("WeddingFirework:OnUse ConsumeItem fail", me.dwID, me.szName, it.dwTemplateId, nConsumeCount);
		return
	end

	local _, nX, nY = pNpc.GetWorldPos();

	Player:PlayEffectWithDistance(me, self.nPlayDis, nEffectId, nX, nY)
	me.nPlayWeddingFireworkTime = nNowTime
	me.CallClientScript("Item:GetClass('WeddingFirework'):OnUseEnd", nCount, nItemId)

	return 0
end

function tbItem:CheckCanUse(pPlayer)
	local bRet, szMsg = self:IsWhiteMap(pPlayer)
	if not bRet then
		return false, szMsg
	end

	return true
end

function tbItem:IsWhiteMap(pPlayer)
	if Map:IsCityMap(pPlayer.nMapTemplateId) then
		return true;
	end

	if Map:IsKinMap(pPlayer.nMapTemplateId) then
		return true;
	end

	if Map:IsHouseMap(pPlayer.nMapTemplateId) then
		return true;
	end

	if Wedding:GetWeddingMapLevel(pPlayer.nMapTemplateId) then
		return true
	end

    return false, "只能在[FFFE0D]婚礼现场、忘忧岛、主城、家族属地、家园[-]燃放"
end

if not MODULE_GAMESERVER then
	function tbItem:OnUseEnd(nCount, nItemId)
		if not nCount or not nItemId then
			return
		end
		Ui:CloseWindow("ItemBox")
		Ui:CloseWindow("ItemTips")
		if nCount <= 1 then
			local tbItems = me.FindItemInBag("WeddingFirework") or {}
			local pItem = tbItems[1]
			if pItem then
				self:OpenQuickUseItem(pItem.dwId, "使  用")
			else
				Ui:CloseWindow("QuickUseItem")
			end
		else
			self:OpenQuickUseItem(nItemId, "使  用")
		end
	end

	function tbItem:OpenQuickUseItem(nItemId, szBtnName)
		if Ui:WindowVisible("QuickUseItem") ~= 1 or (Ui("QuickUseItem") and Ui("QuickUseItem").nItemId ~= nItemId) then
			Ui:OpenWindow("QuickUseItem", nItemId, szBtnName);
		else
			Ui("QuickUseItem"):Update(szBtnName);
		end
	end
end