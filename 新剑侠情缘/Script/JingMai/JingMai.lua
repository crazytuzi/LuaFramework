function JingMai:OnJingMaiLevelUp(nJingMaiId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_XUEWEI_LEVELUP, nil, bOK, nJingMaiId, true);
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)
end

function JingMai:OnRequestJingMaiLevelUp(nJingMaiId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_XUEWEI_LEVELUP, nil, bOK, nJingMaiId);
end

-- 检查同伴界面经脉按钮的红点和TopButton同伴按钮红点(只要Tab有红点就出现)
function JingMai:CheckJingMaiMainPanelRP(pPlayer)
	for nJingMaiId in pairs(self.tbJingMaiSetting) do
		if JingMai:CheckJingMaiTabRedPoint(pPlayer, nJingMaiId) then
			return true
		end
	end
	return false
end

function JingMai:IsTodayMarkDayShowFlag(pPlayer, nJingMaiId)
	local nLocalDay = Lib:GetLocalDay();
	local nClickTabDate = Client:GetFlag("JingMaiTab_" ..nJingMaiId) or 0;
	return nLocalDay == nClickTabDate
end

-- 点击经脉界面Tab如果当前有显示红点加上标志
function JingMai:OnClickJingMaiPanelTab(nJingMaiId)
	if JingMai:CheckDayShowRedPoint(me, nJingMaiId) then
		Client:SetFlag("JingMaiTab_" .. nJingMaiId, Lib:GetLocalDay())
	end
end

-- 检查经脉界面Tab红点
function JingMai:CheckJingMaiTabRedPoint(pPlayer, nJingMaiId)
	if not JingMai:CheckOpen(pPlayer) then
		return false
	end
	if not JingMai:CheckJingMaiOpen(nJingMaiId) then
		return false
	end
	-- 条件一：新开经脉并且没有点过Tab(会一直显示，点一次清除)
	local bOpenClick = Client:GetFlag("JingMai_" .. nJingMaiId) ~= 1
	-- 条件二：经脉可激活会一直显示
	local bCanActivation = JingMai:CheckJingMaiLevelCanActivation(pPlayer, nJingMaiId)
	-- 条件三：经脉可升级（不检查银两）并且没有周天处于运转中状态 , 点一次清除然后今天内不再出现
	local bDayShow = self:CheckDayShowRedPoint(pPlayer, nJingMaiId)
	if bOpenClick or bCanActivation or bDayShow then
		return true
	end
	return false
end

function JingMai:CheckDayShowRedPoint(pPlayer, nJingMaiId)
	local bCanLevelUp = JingMai:CheckJingMaiLevelUp(pPlayer, nJingMaiId, false, true, true)
	local bHadRunning = JingMai:HadJingMaiLevelRunning(pPlayer)
	local bTodayClickTab = JingMai:IsTodayMarkDayShowFlag(pPlayer, nJingMaiId)
	return bCanLevelUp and not bHadRunning and not bTodayClickTab
end
-- 检查背包经脉红点
function JingMai:CheckJingMaiRedPoint(pPlayer)
	if not JingMai:CheckOpen(pPlayer) then
		return false
	end
	if JingMai:CheckJingMaiActivationRedPoint(pPlayer) or JingMai:CheckLastLevelUpRedPoint(pPlayer) or JingMai:CheckJingMaiLevelUpRedPoint(pPlayer) then
		return true
	end
	return false
end

