if not MODULE_GAMESERVER then
    Activity.WishAct = Activity.WishAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("WishAct") or Activity.WishAct

tbAct.GROUP 		= 67
tbAct.DATA_VERSION 	= 1
tbAct.WISH_COUNT 	= 2
tbAct.LIKE_BEGIN 	= 3
tbAct.LIKE_END 		= 12

tbAct.nErrCode_NoLikeTimes = 1
tbAct.nErrCode_NoKin       = 2
tbAct.nErrCode_NoWish      = 3
tbAct.nErrCode_RepeatLike  = 4
tbAct.nErrCode_ContentTooL = 5
tbAct.nErrCode_LimitWords  = 6
tbAct.nErrCode_NoWishTime  = 7
tbAct.nErrCode_NoInTime    = 8
tbAct.nErrCode_LackGold    = 9

tbAct.tbErrMsg = {
    [tbAct.nErrCode_NoLikeTimes]    = "点赞次数已用完",
    [tbAct.nErrCode_NoKin]          = "请先加入一个家族",
    [tbAct.nErrCode_NoWish]         = "没找到对应愿望，请重新尝试",
    [tbAct.nErrCode_RepeatLike]     = "每条愿望只能点赞一次",
    [tbAct.nErrCode_ContentTooL]    = "愿望最多不能超过三十个字符",
    [tbAct.nErrCode_LimitWords]     = "你许下的愿望含有敏感字符，请修改后重试",
    [tbAct.nErrCode_NoWishTime]     = "每个角色只能进行一次许愿",
    [tbAct.nErrCode_NoInTime]       = "结束了",
    [tbAct.nErrCode_LackGold]       = "元宝不足",
}

tbAct.UINOTIFY = 254

tbAct.PLAYERID = 1
tbAct.NAME 	   = 2
tbAct.HEADID   = 3
tbAct.FACTION  = 4
tbAct.LIKE     = 5
tbAct.CONTENT  = 6

tbAct.nTrueEndTime = Lib:ParseDateTime("2017-3-16")

tbAct.CONTENT_MAX_LEN = 30

tbAct.Wish_Type_Free = 1
tbAct.Wish_Type_Pay = 2

tbAct.nPayWishCost = 499

--自定义愿望奖励
tbAct.tbWishAward = 
{
	[tbAct.Wish_Type_Pay] = {{"item", 3943, 49}},
}

function tbAct:CheckWishContent(szMsg)
    if Lib:Utf8Len(szMsg) > self.CONTENT_MAX_LEN then
        return false, self.nErrCode_ContentTooL
    end

    if not MODULE_GAMESERVER and ReplaceLimitWords(szMsg) then
        return false, self.nErrCode_LimitWords
    end

    return true
end

function tbAct:CheckLike(pPlayer, nTarPlayerId)
	if GetTime() >= self.nTrueEndTime then
        return false, self.nErrCode_NoInTime
    end

	if MODULE_GAMESERVER then
    	self:CheckPlayerData(pPlayer)
	    local kinData = Kin:GetKinById(pPlayer.dwKinId)
	    if not kinData then
	        return false, self.nErrCode_NoKin
	    end
	else
		if pPlayer.dwKinId == 0 then
			return false, self.nErrCode_NoKin
		end
	end

    for i = self.LIKE_BEGIN, self.LIKE_END do
        local nLikePlayerId = pPlayer.GetUserValue(self.GROUP, i)
        if nLikePlayerId == 0 then
            break
        end
        if nLikePlayerId == nTarPlayerId then
            return false, self.nErrCode_RepeatLike
        end
        if i == self.LIKE_END then
            return false, self.nErrCode_NoLikeTimes
        end
    end

    if not MODULE_GAMESERVER then
    	return true
    end

    local tbData = self:GetData(pPlayer.dwKinId)
    local nIndex
    for i, tbInfo in ipairs(tbData) do
        if tbInfo[self.PLAYERID] == nTarPlayerId then
            nIndex = i
            break
        end
    end

    return nIndex, self.nErrCode_NoWish
end


------------------------------------client------------------------------------
function tbAct:OnDataUpdate(szType, tbData)
	if szType == "Data" then
		for _, tbInfo in ipairs(tbData) do
			tbInfo[self.CONTENT] = ReplaceLimitWords(tbInfo[self.CONTENT]) or tbInfo[self.CONTENT]
		end
		self.tbData = tbData
	elseif szType == "Wish" then
		self.tbData = self.tbData or {}
		tbData[self.CONTENT] = ReplaceLimitWords(tbData[self.CONTENT]) or tbData[self.CONTENT]
		table.insert(self.tbData, tbData)
	elseif szType == "Like" then
		self.tbData = self.tbData or {}
		for _, tbInfo in ipairs(self.tbData) do
			if tbInfo[self.PLAYERID] == tbData[1] then
				tbInfo[self.LIKE] = tbInfo[self.LIKE] + 1
				break
			end
		end
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_WISHACT_DATA_CHANGED, self.tbData)
end

function tbAct:GetLastLike()
	local nAllLike = self.LIKE_END - self.LIKE_BEGIN + 1
	for i = self.LIKE_BEGIN, self.LIKE_END do
		if me.GetUserValue(self.GROUP, i) == 0 then
			break
		end

		nAllLike = nAllLike - 1
	end
	return nAllLike
end

function tbAct:GetHadLike()
	local tbLike = {}
	for i = self.LIKE_BEGIN, self.LIKE_END do
		local nLikeId = me.GetUserValue(self.GROUP, i)
		if nLikeId > 0 then
			tbLike[nLikeId] = true
		else
			break
		end
	end
	return tbLike
end