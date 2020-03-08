function WuLinDaHui:OnBuyTicketScuccess()
	me.CenterMsg("恭喜阁下获得参与武林大会的资格！", true)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DATA, "WLDHRefreshMainUi")
end

function WuLinDaHui:IsShowTopButton()
	local bIsAct = Activity:__IsActInProcessByType(self.szActNameYuGao)
	if bIsAct then
		return true, self.szActNameYuGao;
	end
	bIsAct = Activity:__IsActInProcessByType(self.szActNameBaoMing)
	if bIsAct then
		return true, self.szActNameBaoMing
	end
	bIsAct = Activity:__IsActInProcessByType(self.szActNameMain)
	if bIsAct then
		return true, self.szActNameMain
	end
end

function WuLinDaHui:GetPlayerTeamNum()
    local nSelfCurTeamNum = 0;
    for i, v in ipairs(WuLinDaHui.tbGameFormat) do
        local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. i) ;
        if tbTeamInfo and tbTeamInfo.szName then
            nSelfCurTeamNum = nSelfCurTeamNum + 1;
        end
    end
    return nSelfCurTeamNum
end

function WuLinDaHui:SetSysNotifyCation()
	if not Activity:__IsActInProcessByType(self.szActNameMain) then
		return
	end
	--是取最短的一个时间
	local tbNotifyTimeNodes = {}; --每个初赛和决赛开始前的才有通知
	for i, v in ipairs(WuLinDaHui.tbGameFormat) do
		local tbTeamInfo = Player:GetServerSyncData("WLDHFightTeamInfo" .. i) ;
        if tbTeamInfo and tbTeamInfo.nFightTeamID then 
       		local tbTimeNode, nState = self:GetCurTimeNode(i)
   			if nState == 1 or nState == 3 or nState == 5 or nState == 7 then
   				table.insert(tbNotifyTimeNodes, tbTimeNode[nState])
   				break; --可参与的初赛肯定是早于决赛的
   			elseif nState == 9  and tbTeamInfo.nFinals == i then
				table.insert(tbNotifyTimeNodes, tbTimeNode[nState])
   			end
        end
    end
   	if #tbNotifyTimeNodes == 0 then
   		return
   	end
	table.sort( tbNotifyTimeNodes, function (a, b)
		return a <  b
	end )   	
	local tbTime = os.date("*t", tbNotifyTimeNodes[1] -  self.tbDef.nPhoneSysNotifyMsgBeforeSec)
    Ui:NotificationMessage(self.tbDef.szPhoneSysNotifyMsg, tbTime.hour, tbTime.min, false)
end

function WuLinDaHui:GetCurTimeNode(nGameType)
    local tbTimeNode = WuLinDaHui:GetMatchTimeNode(nGameType)
    table.sort( tbTimeNode, function (a, b)
        return a < b;
    end )
    local nNow = GetTime()
    --初赛  1，2，3，4，5，6，7，8，  决赛 9， 10,  活动结束 11

    local nState = 1; 
    for i,v in ipairs(tbTimeNode) do
        if nNow >= v then
            nState = i + 1;
        else
            break;
        end
    end
    return tbTimeNode, nState
end

function WuLinDaHui:GetMatchTimeNode(nGameType, nStartTime)
	--注意获得以后还要重新排序
	if not nStartTime then
		nStartTime = Activity:__GetActTimeInfo(self.szActNameMain)
	end
	if not nStartTime then
		return {};
	end
	local tbTimeNode = {};
	for nDay, tbSche in ipairs(WuLinDaHui.tbScheduleDay) do
		if tbSche.nGameType == nGameType then
			local tbTime = os.date("*t", nStartTime + 3600 * 24 * (nDay - 1));
			if not tbSche.bFinal then
				for i, v in ipairs(WuLinDaHui.tbDef.tbStartMatchTime) do
					local hour1, min1 = string.match(v, "(%d+):(%d+)");
					local nSecBegin = os.time({year = tbTime.year, month = tbTime.month, day = tbTime.day, hour = hour1, min = min1, sec = 0});	
					table.insert(tbTimeNode, nSecBegin)
				end
				for i, v in ipairs(WuLinDaHui.tbDef.tbEndMatchTime) do
					local hour1, min1 = string.match(v, "(%d+):(%d+)");
					local nSecBegin = os.time({year = tbTime.year, month = tbTime.month, day = tbTime.day, hour = hour1, min = min1, sec = 0});	
					table.insert(tbTimeNode, nSecBegin)
				end
			else
				local hour1, min1 = string.match(WuLinDaHui.tbDef.szFinalStartMatchTime, "(%d+):(%d+)");
				local nSecBegin = os.time({year = tbTime.year, month = tbTime.month, day = tbTime.day, hour = hour1, min = min1, sec = 0});	
				table.insert(tbTimeNode, nSecBegin)

				local hour1, min1 = string.match(WuLinDaHui.tbDef.szFinalEndMatchTime, "(%d+):(%d+)");
				local nSecBegin = os.time({year = tbTime.year, month = tbTime.month, day = tbTime.day, hour = hour1, min = min1, sec = 0});	
				table.insert(tbTimeNode, nSecBegin)
			end
		end
	end

	return tbTimeNode
end

--预选赛的时间范围
function WuLinDaHui:GetGameTyoePreScheDayScope(nGameType)
	local tbDays = {}
	for nDay, tbSche in ipairs(WuLinDaHui.tbScheduleDay) do
		if tbSche.nGameType == nGameType and not tbSche.bFinal then
			table.insert(tbDays, nDay)
		end
	end
	return tbDays
end

function WuLinDaHui:GetGameTyeFinalDay(nGameType)
	for nDay, tbSche in ipairs(WuLinDaHui.tbScheduleDay) do
		if tbSche.nGameType == nGameType and tbSche.bFinal then
			return nDay
		end
	end
end

function WuLinDaHui:GetCLinetNowTimeNode()
	local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameYuGao)
	if  nStartTime and nEndTime then
		return nStartTime
	end

	local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameBaoMing)
	if  nStartTime and nEndTime then
		return nStartTime
	end

	local nStartTime, nEndTime = Activity:__GetActTimeInfo(self.szActNameMain)
	if not nStartTime then
		return
	end
	--每一阶段的初赛开始时， 初赛结束，决赛开始， 决赛结束
	local nNow = GetTime()

    local tbAllTimeNodes = {}
	for nGameType, v in ipairs(self.tbGameFormat) do
		local tbTimeNode = self:GetMatchTimeNode(nGameType)
		for _,v2 in ipairs(tbTimeNode) do
			table.insert(tbAllTimeNodes, v2)
		end	
	end
	table.sort( tbAllTimeNodes, function (a, b)
		return a < b
	end )
	if nNow < tbAllTimeNodes[1] then
		return
	end
	for i,v in ipairs(tbAllTimeNodes) do
		local nNextTime = tbAllTimeNodes[i+1]
		if nNextTime then
			if nNow >= v and nNow < nNextTime then
				return v
			end
		else
			return v
		end
	end
end

function WuLinDaHui:IsShowRedPoint()
	--没一个新的时间节点时 如果客户端没看过就显示红点
	local nTimeNode = self:GetCLinetNowTimeNode()
	if not nTimeNode then
		return
	end
	local nViewTime = Client:GetFlag("WLDHViewPanelTime")
	if not nViewTime or nViewTime < nTimeNode then
		return true;
	end
end

function WuLinDaHui:CheckRedPoint()
	if self:IsShowRedPoint() then
		Ui:SetRedPointNotify("Activity_WLDH")
	else
		Ui:ClearRedPointNotify("Activity_WLDH")
	end
end

function WuLinDaHui:CheckRequestTeamData(nGameType)
	local szSynKey = nGameType and "WLDHFightTeamInfo" .. nGameType or "WLDHFightTeamInfo1";
	local tbFightTeam = Player:GetServerSyncData(szSynKey);
    local bReques = true;
    if tbFightTeam then
    	local nRequestDelay = nGameType and WuLinDaHui.tbDef.nClientRequestTeamDataInterval or 60 * 30
    	if nGameType and WuLinDaHui:IsInMap(me.nMapTemplateId) then
    		nRequestDelay = WuLinDaHui.tbDef.nClientRequestTeamDataIntervalInMap
    	end
    	local nNow = GetTime()
        tbFightTeam.__RequesTime =  tbFightTeam.__RequesTime or nNow;
        if nNow - tbFightTeam.__RequesTime < nRequestDelay then
            bReques = false;
        end    
    end
    if bReques then
    	if nGameType then
    		RemoteServer.DoRequesWLDH("RequestFightTeam", nGameType);
    	else
			RemoteServer.DoRequesWLDH("RequestFightTeamAll");	
    	end
    end
end

function WuLinDaHui:OnChangeTeamInfo(nGameType)
	Ui:CloseWindow("TeamRelatedPanel")
	Ui:CloseWindow("CreateTeamPanel")
	local tbFightTeam = Player:GetServerSyncData("WLDHFightTeamInfo"..nGameType);
	if not tbFightTeam then
		return
	end
	local nFightTeamID = tbFightTeam.nFightTeamID
	if not nFightTeamID then
		return
	end
	local tbFightTeamShow = Player:GetServerSyncData("WLDHFightTeam:"..nFightTeamID);
	if not tbFightTeamShow then
		return
	end
	tbFightTeamShow.__RequesTime = 0;
end

function WuLinDaHui:CheckRequestTopTeamData(nGameType)
	local tbSyndata, nSynTimeVersion = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. nGameType) ;
	local nMinInterval = WuLinDaHui:IsInMap(me.nMapTemplateId) and WuLinDaHui.tbDef.nClientRequestTeamDataIntervalInMap or WuLinDaHui.tbDef.nClientRequestTeamDataInterval
    if not nSynTimeVersion or GetTime() - nSynTimeVersion >= nMinInterval then
        RemoteServer.DoRequesWLDH("RequestTopPreFightTeamList", nGameType, nSynTimeVersion);
    end
end

function WuLinDaHui:GetGuessingTeamID(nGameType)
    local tbSyncData = Player:GetServerSyncData("WLDHGuessingData") or {};
    return tbSyncData[nGameType] or 0;
end

function WuLinDaHui:CanGuessing(nGameType)
	local tbSyndata, nSynTimeVersion, nWinTeamId = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. nGameType) ;
    if nWinTeamId then
        return
    end
    local nActStartTime, nActEndTime = Activity:__GetActTimeInfo(WuLinDaHui.szActNameMain)
    if not nActStartTime then
        return
    end

    --获取对应的决赛开始时间
    local nDay = self:GetGameTyeFinalDay(nGameType)
    local tbTime = os.date("*t", nActStartTime + 3600 * 24 * (nDay - 1));
    local hour1, min1 = string.match(WuLinDaHui.tbDef.szFinalStartMatchTime, "(%d+):(%d+)");
    local nSecBegin = os.time({year = tbTime.year, month = tbTime.month, day = tbTime.day, hour = hour1, min = min1, sec = 0});
    if GetTime() <= nSecBegin then
        return true
    end
end

function WuLinDaHui:IsCanSigUp(pPlayer, nGameType)
	nGameType = nGameType or 1;
	local bRet, szMsg = WuLinDaHui:IsBaoMingTime(nGameType)
	if not bRet then
		return false, szMsg
	end
	local tbUiData, tbActData = Activity:GetActUiSetting(WuLinDaHui.szActNameBaoMing)
	if not tbUiData or not next(tbUiData) then
		tbUiData, tbActData = Activity:GetActUiSetting(WuLinDaHui.szActNameMain)
	end
	if not tbUiData or not next(tbUiData) then
		return false, "无活动相关配置"
	end
	local nLastStartBaoMingTime = tbUiData.nLastStartBaoMingTime
	local nSaveVal = pPlayer.GetUserValue(self.tbDef.SAVE_GROUP, self.tbDef.SAVE_KEY_TicketTime)
	return  nSaveVal >= nLastStartBaoMingTime
end

function WuLinDaHui:IsHasTicket()
	-- 因为服务端设的是 获取资格的时间，然后该时间是大于上次开启的时间
	if WuLinDaHui:IsBaoMingAndMainActTime() then
		return self:IsCanSigUp(me)	
	end
		--不在报名期的就需要资格时间大于获取的报名时间,即下次开时的上次报名时间
	local nWLDHStartBaoMingTime = Player:GetServerSyncData("nWLDHStartBaoMingTime");
    if not nWLDHStartBaoMingTime then --客户端还没获取到时就先取上个月初的时间
        local tbTime = os.date("*t", GetTime());            
        local nSec = os.time({year = tbTime.year, month = tbTime.month -1, day = 1})
        nWLDHStartBaoMingTime = nSec
        Player:ServerSyncData("nWLDHStartBaoMingTime", nSec)
        RemoteServer.DoRequesWLDH("GetWLDHStartBaoMingTime");
    end
    return me.GetUserValue(WuLinDaHui.tbDef.SAVE_GROUP, WuLinDaHui.tbDef.SAVE_KEY_TicketTime) > nWLDHStartBaoMingTime
end