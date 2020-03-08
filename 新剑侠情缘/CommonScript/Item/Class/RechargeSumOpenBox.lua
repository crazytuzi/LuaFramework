
local tbItem = Item:GetClass("RechargeSumOpenBox");
tbItem.ITEM_KEY_CURLEVEL = 1;

function tbItem:GetAct(  )
	local tbAct = MODULE_GAMESERVER and Activity:GetClass("RechargeSumOpenBox") or Activity.RechargeSumOpenBox
	return tbAct
end

function tbItem:OnUse(it)
	local tbAct = self:GetAct()
	local tbAwardSet = tbAct.tbRechargeItemBoxAwardSetting[it.dwTemplateId]
	if not tbAwardSet then
		me.CenterMsg("ERROR1")
		return
	end
	local nCurlevel = it.GetIntValue(self.ITEM_KEY_CURLEVEL)
	local nOpenLevel = nCurlevel + 1;
	local tbProdInfo = Recharge.tbSettingGroup.BuyGold[nOpenLevel]
	if not tbProdInfo then
		me.CenterMsg("ERROR2")
		return
	end
	local tbGetAward = tbAwardSet[nOpenLevel]
	if not tbGetAward then
		me.CenterMsg("ERROR3")
		return
	end
	
	local nNeedKeyItemId = tbAct.tbRechargeGetKeyItem[tbProdInfo.nGroupIndex]
	if not nNeedKeyItemId then
		me.CenterMsg("ERROR4")
		return
	end
	if me.ConsumeItemInBag(nNeedKeyItemId ,1, Env.LogWay_RechargeSumOpenBox)  ~= 1 then
		local tbItembase = KItem.GetItemBaseProp(nNeedKeyItemId)
		me.CenterMsg(string.format("您的%s不足", tbItembase.szName))
		return
	end
	if nOpenLevel == #tbAwardSet then
		it.Delete(Env.LogWay_RechargeSumOpenBox)
		if tbAct.nOpenAllBoxRedBagKey then
			Kin:RedBagOnEvent(me, tbAct.nOpenAllBoxRedBagKey, 1)	
		end
		-----公告
		local szBugNotifyMsg = tbAct.szOpenAllNotifyMsg
		if not Lib:IsEmptyStr(szBugNotifyMsg) then
			local nItemId;
			for i,v in ipairs(tbGetAward) do
				local szType,nVal = unpack(v)
				if Player.AwardType[szType] == Player.award_type_item then
					nItemId = nVal
					break;
				end
			end
			if nItemId then
				local szName, _,_,nQuality = Item:GetItemTemplateShowInfo(nItemId, me.nFaction, me.nSex)
				if szName then
					local _, _, _, _, TxtColor = Item:GetQualityColor(nQuality)
					local szMsg = string.format(szBugNotifyMsg, me.szName, TxtColor, szName)
					KPlayer.SendWorldNotify(0, 999, szMsg, 0, 1);
					ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg, nil, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemId, nFaction = me.nFaction, nSex = me.nSex});
				end
			end
		end
	else
		it.SetIntValue(self.ITEM_KEY_CURLEVEL, nOpenLevel)
	end
	me.SendAward(tbGetAward, nil,nil, Env.LogWay_RechargeSumOpenBox)
end


function tbItem:GetCurOpenLevel( it )
	local nCurlevel = it.GetIntValue(self.ITEM_KEY_CURLEVEL)
	return nCurlevel + 1;
end

function tbItem:GetIntrol( dwTemplateId, nItemID )
	if not nItemID then
		return
	end
	local pItem = KItem.GetItemObj(nItemID)
	if not pItem then
		return
	end
	local nCurlevel = pItem.GetIntValue(self.ITEM_KEY_CURLEVEL)
	local tbAct = self:GetAct()
	local tbSeting = tbAct.tbRechargeItemBoxTipSetting[dwTemplateId]
	local tbDescs = {}
	for i,v in ipairs(tbSeting) do
		local bActive = nCurlevel >= i;
		table.insert(tbDescs, string.format("[%s]%s （%s）[-]", bActive and "ffff00" or "ffffff",  v,  bActive and "已解锁" or "未解锁"))
	end
	return "充值对应层数金额获得该层的宝箱钥匙，开启[FFFE0D]全部六层宝箱更可获得称号奖励[-]，奖励为：\n" .. table.concat( tbDescs, "\n")
end