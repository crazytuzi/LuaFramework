function DirectLevelUp:OnReceiveAsk(tbBeAskList, szCurApplyer)
    self.tbBeAskList = tbBeAskList
    local tbMsgData =
    {
        szType = "Ask4DirectLevelUpItem",
        nTimeOut = GetTime() + 3600,
        szApplyer = szCurApplyer,
    }
    Ui:SynNotifyMsg(tbMsgData)
    Ui:SetRedPointNotify("Activity_BuyLevelUp")
end

function DirectLevelUp:OnSyncData(tbBeAskList, tbAppList, nActStartTime, nActEndTime)
    self.tbBeAskList = tbBeAskList or {}
    self.tbAppList = tbAppList or {}
    self.nActStartTime = nActStartTime
    self.nActEndTime = nActEndTime
end

function DirectLevelUp:GetAsk4HelpList()
    local tbFriend = FriendShip:GetAllFriendData(true)
    local tbAskList = {}
    for _, tbInfo in ipairs(tbFriend or {}) do
        if self.tbBeAskList[tbInfo.dwID] and tbInfo.nState == 2 then
            table.insert(tbAskList, tbInfo)
        end
    end
    return tbAskList
end

function DirectLevelUp:GetCanHelpMeList()
    local tbFriendData = FriendShip:GetAllFriendData()
    local tbCanHelpList = {}
    local nItemTID = self:GetCanBuyItem()
    if not nItemTID then
        return tbCanHelpList
    end
    for _, tbInfo in ipairs(tbFriendData or {}) do
        local bRet, szMsg = self:CheckCanHelp(tbInfo)
        local nImityLv = FriendShip:GetFriendImityLevel(tbInfo.dwID, me.dwID)
        nImityLv = nImityLv or 0
        if bRet and tbInfo.nState == 2 and nImityLv >= self.nImityLevel then
            table.insert(tbCanHelpList, tbInfo)
        end
    end
    return tbCanHelpList
end

function DirectLevelUp:GetApplyFlag(nPlayerId)
    self.tbAppList = self.tbAppList or {}
    return self.tbAppList[nPlayerId]
end

function DirectLevelUp:OnHelpRsp(nHelper)
    self.tbAppList = self.tbAppList or {}
    self.tbAppList[nHelper] = true
    UiNotify.OnNotify(UiNotify.emNOTIFY_LEVELUP_ASK4HELP_RSP)
end

function DirectLevelUp:CheckShowPanel()
--[[
	if me.nLevel < self.nRequireLevel then
        return
    end
	local nCanBuyID = self:GetCanBuyItem()
	if not nCanBuyID then
		return
	end
	local bCanBuy = self:CheckCanBuy(me, nCanBuyID)
    if bCanBuy then
    	local tbItem = me.FindItemInBag(nCanBuyID)
    	return #tbItem == 0
    end

	local bCanHelp = self:CheckCanHelp(me)
	local tbList   = self:GetAsk4HelpList() or {}
    return bCanHelp and next(tbList)
]]
    return
end

function DirectLevelUp:GetLastHelpTimes()
    local nLastSendTime = me.GetUserValue(self.GROUP, self.SEND_TIME)
    if self.nActStartTime and self.nActEndTime and GetTime() > self.nActStartTime and GetTime() < self.nActEndTime then
        if nLastSendTime >= self.nActStartTime then
            return 0
        end
    else
        if (GetTime() - nLastSendTime) < self.nSendInterval then
            return 0
        end
    end
    return 1
end
