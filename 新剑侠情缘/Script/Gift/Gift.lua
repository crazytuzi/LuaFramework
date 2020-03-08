Gift.tbGiftData = {};
Gift.tbGiftItemData = {};

--[[
	更新全部礼物数据：tbGiftData的结构为：
	tbGiftData[dwId] = {};
	tbGiftData[dwId][nGiftType or szKey] = nRemain;				-- 剩余次数 nGiftType or szKey
	tbGiftData.nUpdateDay = nDay;						-- 最近更新的时间
]]

Gift.tbFlowerBoxPlay = {}

-- 送礼物成功
function Gift:SendGiftSuccess()
	--UiNotify.OnNotify(UiNotify.emNOTIFY_SEND_GIFT_SUCCESS);
end

-- 收礼物成功
function Gift:AcceptGiftSuccess(nGiftType, nItemId, szTips, nCount, bShowEffect)
	if nGiftType == Gift.GiftType.RoseAndGrass then
		Ui:OpenWindow("GiftPlay",nItemId);
	elseif nGiftType == Gift.GiftType.FlowerBox or nGiftType == Gift.GiftType.QRFlowerBox then
		if #self.tbFlowerBoxPlay == 0 then
			Ui:OpenWindow("FlowerBoxPlay", nItemId, szTips, nCount, bShowEffect);
		else
			if nCount and nCount > 0 then
				for i=1,nCount do
					table.insert(Gift.tbFlowerBoxPlay,{[1] = nItemId,[2] = szTips,[3] = bShowEffect})
				end
			end
		end
	end
end

function Gift:UpdateGiftData()
	RemoteServer.SynGiftData();
end

function Gift:OnSynGiftData(tbData)
	self.tbGiftData = tbData or {};
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_GIFT_DATA_FINISH);
end

function Gift:OnSynGiftItemData(tbData)
	self.tbGiftItemData = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_GIFT_DATA_FINISH);
end

function Gift:OnSynNoLimitData()
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_GIFT_DATA_FINISH);
end


Gift.tbCanSendGiftShow = 
{
	["XinDeBook"] = function (tbAcceptPlayer, nItemId)
	    if tbAcceptPlayer.nLevel > me.nLevel then
	    	return false;
	    end	

	    return true;
	end,
}

function Gift:GetAllCanSendGift(nFaction, dwID, bOnline, nLevel, nSex)
	local tbGiftList = {};
	local tbAcceptPlayer = {};
	tbAcceptPlayer.nFaction = nFaction;
	tbAcceptPlayer.nLevel = nLevel;

	if nSex == 0 then
		return tbGiftList;
	end

	for nGiftType,_ in ipairs(Gift.AllGift) do
		if bOnline or not Gift.AllGiftNeedOnline[nGiftType] then
			if Gift.SpecialGift[nGiftType] then
				if nGiftType == Gift.GiftType.MailGift then
					for szkey,tbInfo in pairs(Gift.tbMailGift) do
						local nTimesType = tbInfo.nTimesType
						if bOnline or not Gift.MailTimesTypeNeedOnline[nTimesType] then
							local tbItemId = tbInfo.tbItemId or {}
							local tbGirlItemId = tbInfo.tbGirlItemId or {}
							for nIdx, nItemId in ipairs(tbItemId) do
								local nId = nItemId
								if nSex == Gift.Sex.Girl and tbGirlItemId[nIdx] then
									nId = tbGirlItemId[nIdx]
								end

								local bAddGift = true;
								local fnCheck = Gift.tbCanSendGiftShow[szkey];
								if fnCheck then
									bAddGift = fnCheck(tbAcceptPlayer, nId);
								end
									
								if bAddGift then
									local nCount = me.GetItemCountInAllPos(nId)
									if nCount > 0 then
										table.insert(tbGiftList,{nGiftType = nGiftType,nItemId = nId})
									end
								end	
							end
						end
					end
				end
			else
				local nItemId = Gift:GetItemId(nGiftType,nSex)
				if nItemId and me.GetItemCountInAllPos(nItemId) > 0 then
					table.insert(tbGiftList,{nGiftType = nGiftType,nItemId = nItemId})
				end
			end
		end
	end

	return tbGiftList;
end

-- 礼物剩余的赠送次数
function Gift:RemainTimes(nAcceptId,nGiftType,nItemId)
	local tbGift = self.tbGiftData
	local tbGiftItem = self.tbGiftItemData
	local key
	local nTimes = self:MaxTimes(nGiftType,nItemId) or 0
	if nGiftType == Gift.GiftType.MailGift then
		local tbInfo = Gift:GetMailGiftItemInfo(nItemId)
		if not tbInfo then
			return 0
		end
		key = tbInfo.szKey
		if tbInfo.tbData.nTimesType == Gift.MailType.Times2Item then
			return tbGiftItem.tbSendItem and tbGiftItem.tbSendItem[key] or nTimes
		end
	else
		key = nGiftType
	end

	if not tbGift[nAcceptId] or not tbGift[nAcceptId][key] then
		return nTimes
	end

	return tbGift[nAcceptId][key]
end

function Gift:MaxTimes(nGiftType,nItemId)
	local nMaxTimes
	if nGiftType == Gift.GiftType.MailGift then
		local tbInfo = Gift:GetMailGiftItemInfo(nItemId)
		if not tbInfo then
			return
		end
		local nTimesType = tbInfo.tbData.nTimesType
		if nTimesType == Gift.MailType.Times2Player then
			nMaxTimes = tbInfo and tbInfo.tbData.nTimes
		elseif nTimesType == Gift.MailType.Times2Item then
			nMaxTimes = tbInfo and tbInfo.tbData.nItemSend
		elseif nTimesType == Gift.MailType.NoLimit then
			nMaxTimes = Gift.Times.Forever
		end
	else
		nMaxTimes = Gift.SendTimes[nGiftType]
	end
	return nMaxTimes
end


-- 数据同步之后才能用
function Gift:CanSendGiftMailT2I(nItemId)
	return self:RemainTimes(nil,Gift.GiftType.MailGift,nItemId) > 0
end

function Gift:CheckItemFriend(nGiftType,nItemId,nFriendId)
	local nRemain = self:RemainTimes(nFriendId,nGiftType,nItemId)
	if nRemain <= 0 then
		return false
	end
	if nGiftType == Gift.GiftType.MailGift then
		local tbInfo = Gift:GetMailGiftItemInfo(nItemId)
		if not tbInfo or not tbInfo.tbData then
			return false
		end
		if tbInfo.tbData.nImityLevel > 0 then
			local nImityLevel = FriendShip:GetFriendImityLevel(me.dwID, nFriendId) or 0
			if nImityLevel < tbInfo.tbData.nImityLevel then
				return false
			end
		end
	end 

	return true
end