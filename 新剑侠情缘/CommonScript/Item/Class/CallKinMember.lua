local tbItem = Item:GetClass("CallKinMember");
--别瞅了，客户端是不可能有货的
--想要脚本，联系http://www.jxqy.org

tbItem.nPlayDis = 5

function tbItem:OnUse(it)
	if not it.dwTemplateId then
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
	if nPlayInterval < nPlayDis then
		me.CenterMsg(string.format("[FFFE0D]%s秒[-]之后才可继续使用", nPlayDis - nPlayInterval > 0 and nPlayDis - nPlayInterval or 0))
		return
	end
	local nCount = it.nCount
	local nItemId = it.dwId
	local nConsumeCount = me.ConsumeItem(it, 1, Env.LogWay_WeddingFirework);
	if nConsumeCount ~= 1 then
		Log("WeddingFirework:OnUse ConsumeItem fail", me.dwID, me.szName, it.dwTemplateId, nConsumeCount);
		return
	end

	me.CreatePartnerByPos(nEffectId);

	me.nPlayWeddingFireworkTime = nNowTime

	return 0
end

function tbItem:CheckCanUse(pPlayer)
    local bRet = Map:IsFieldFightMap(pPlayer.nMapTemplateId);
    if not bRet then
        return false, "请前往野外地图再开启";
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

    return false, "只能在[FFFE0D]野外[-]使用"
end
