--local tbActUi = Activity:GetUiSetting("DefendAct")
--
--tbActUi.nShowLevel = 30
--tbActUi.szTitle    = "五一江湖展身手";
--tbActUi.szBtnText  = "前往"
--tbActUi.szBtnTrap  = "[url=pos:text, 10, 9570, 11560]"
--tbActUi.fnCall = function () DefendFuben:GoNpc() end
--
--tbActUi.FuncContent = function (tbData)
--        local tbTime1 = os.date("*t", tbData.nStartTime)
--        local tbTime2 = os.date("*t", tbData.nEndTime)
--        local szContent = "    诸位，近日乃武林休憩日，理应让手脚运动一番，如何运动？听我道来：\n1、前往[FFFE0D] 襄阳城 [-]寻找老板娘[FFFE0D] 公孙惜花 [-]开始进行本次的活动\n2、必须为[FFFE0D] 两人 [-]组成一队，且两人必须是[FFFE0D] 异性角色 [-]\n3、参与活动即扣除次数，[FFFE0D] 每日只有一次次数 [-]\n4、地图东南西北共有四条道路，每轮随机挑选三路刷新杀手，每一路分别具有[FFFE0D] 一种五行属性[-]，[FFFE0D]不会重复[-]，可通过[FFFE0D] 小地图 [-]查看；\n5、每条路上还有一名师兄师姐，对话选择请求协助，他会自动防守所在道路，[FFFE0D]每轮只允许挑选一位帮忙[-]，进入地图时其[FFFE0D] 位置 [-]和[FFFE0D] 五行属性 [-]已经确定，不会变更；\n6、杀手悍不畏死，你与帮手对[FFFE0D] 五行克制的杀手造成极大伤害 [-] ，注意选择哦！"
--        local nMax = DegreeCtrl:GetMaxDegree("DefendFuben", me)
--        local nCompleteNum = math.min(DegreeCtrl:GetDegree(me, "DefendFuben"), nMax)
--        local szComplete = string.format("     [c8ff00]今日可参与次数：%d/%d", nCompleteNum, nMax)
--        return string.format("活动时间：[c8ff00]%d年%d月%d日4点-%d月%d日4点[-]\n%s\n%s", tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day, szContent, szComplete)
--end

--tbActUi.tbAwardInfo = {
--    --开始时间轴，奖励，结束时间轴
--    {"OpenLevel39", {{"Contrib", 50}}, {{"Contrib", 150}}, {{"Contrib", 300}}, {{"Contrib", 500}}, {{"Contrib", 700}}, {{"Contrib", 1000}, {"AddTimeTitle", 5033}}, "OpenDay33"},
--     {"OpenDay33", {{"Energy", 50}}, {{"Energy", 150}}, {{"Energy", 300}}, {{"Energy", 500}}, {{"Energy", 700}}, {{"Energy", 1000}, {"AddTimeTitle", 5033}}, "OpenDay720"},
--}
--tbActUi.FuncSubInfo = function ()
--    for _, tbInfo in ipairs(tbActUi.tbAwardInfo) do
--        if GetTimeFrameState(tbInfo[1]) == 1 and GetTimeFrameState(tbInfo[8]) ~= 1 then
--            local tbAward = {}
--            table.insert(tbAward, {szType = "Item1", szInfo = "防守一轮奖励", tbItemList = tbInfo[2], tbItemName = {}})
--            table.insert(tbAward, {szType = "Item1", szInfo = "防守二轮奖励", tbItemList = tbInfo[3], tbItemName = {}})
--            table.insert(tbAward, {szType = "Item1", szInfo = "防守三轮奖励", tbItemList = tbInfo[4], tbItemName = {}})
--            table.insert(tbAward, {szType = "Item1", szInfo = "防守四轮奖励", tbItemList = tbInfo[5], tbItemName = {}})
--            table.insert(tbAward, {szType = "Item1", szInfo = "防守五轮奖励", tbItemList = tbInfo[6], tbItemName = {}})
--            table.insert(tbAward, {szType = "Item1", szInfo = "防守六轮奖励", tbItemList = tbInfo[7], tbItemName = {}})
--            return tbAward
--        end
--    end
--    return {}
--end

function DefendFuben:OnLeaveMap()
	Ui:CloseWindow("HomeScreenFuben","TeamFuben")
end

function DefendFuben:CheckTeamMember(pP)
    local tbTeamMy = TeamMgr:GetMyTeamMemberData()
    if not tbTeamMy then
        return false,"缘定长相守活动需要与[FFFE0D] 一名异性侠士 [-]组成队伍才能参加哦"
    end
    local tbTeamMember =  TeamMgr:GetTeamMember()
    if #tbTeamMember ~= 1 then
        return false, "缘定长相守活动需要与[FFFE0D] 一名异性侠士 [-]组成队伍才能参加哦"
    end

    local tbTeamAll = 
    {
        [1] = tbTeamMy,
        [2] = tbTeamMember[1],
    }

    local tbSecOK = {}
    for nIdx, tbData in ipairs(tbTeamAll) do
         tbSecOK[nIdx] = Player:Faction2Sex(tbData.nFaction, tbData.nSex);
    end

    if tbSecOK[1] == tbSecOK[2] then
        return false, "需与一名异性角色组成两人队伍"
    end
    
    return true
end

function DefendFuben:GoNpc()
    local bRet,szMsg = self:CheckTeamMember(me)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    local nNpcTemplateId = 99;
    local nMapTemplateId = 10;
    local nPosX, nPosY   = AutoPath:GetNpcPos(nNpcTemplateId, nMapTemplateId);
    local fnCallback     = function ()
        local nNpcId = AutoAI.GetNpcIdByTemplateId(nNpcTemplateId);
        if nNpcId then
            Operation.SimpleTap(nNpcId);
        end
    end;
    AutoPath:GotoAndCall(nMapTemplateId, nPosX, nPosY, fnCallback);
    Ui:CloseWindow("NewInformationPanel")
    Ui:CloseWindow("CalendarPanel")
end

function DefendFuben:OnSynSeriesData(tbData)
    local tbSetting = tbData or {}
    local tbTextInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
    if me.nMapTemplateId ~= DefendFuben.nFubenMapTemplateId then
        return
    end

    for i = #tbTextInfo,1,-1 do
       tbTextInfo[i] = nil
    end

    for szKey,tbInfo in pairs(tbSetting) do
        for nRoad,tbNpc in pairs(tbInfo) do
            local tbTemp = DefendFuben:GetSeriesSetting(szKey,tbNpc.nSeries)
            if tbTemp then
                tbTemp.XPos = tbNpc.nNpcX
                tbTemp.YPos = tbNpc.nNpcY
                table.insert(tbTextInfo,tbTemp)
            end
        end
    end
end

function DefendFuben:SynSwitch(nEndTime)
    self.nEndTime = nEndTime
end