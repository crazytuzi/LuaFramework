local tbActUi = Activity:GetUiSetting("WeekendQuestion")
--
--tbActUi.nShowLevel = 30
--tbActUi.szTitle    = "五一江湖动灵机";
--tbActUi.szBtnText  = "前往"
--tbActUi.fnCall = function () tbActUi:GoNpc() end
--tbActUi.szBtnTrap  = "[url=pos:text, 10, 9570, 11560]"
--
--tbActUi.FuncContent = function (tbData)
--        local tbTime1 = os.date("*t", tbData.nStartTime)
--        local tbTime2 = os.date("*t", tbData.nEndTime)
--        local szContent = "    诸位，近日乃武林规定的休憩之日，值此假日，理应让头脑运动一番，我给诸位出了个点子，规则如下：\n1、需前往[FFFE0D] 襄阳城 [-]寻找老板娘[FFFE0D] 公孙惜花 [-]开始进行本次的活动\n2、必须为[FFFE0D] 两人 [-]组成一队，且两人必须是[FFFE0D] 异性角色 [-]\n3、由一人先行答题，答完后另一人紧接着继续回答，题目将发送到队伍频道\n4、答题后将出现下个出题人的线索，答对的越多，线索越清晰\n5、题目总共[FFFE0D] 8轮16题 [-]，全部答完即完成\n     诸位侠士，出发吧！"
--        local nMax = Activity.WeekendQuestion.MAX_COUNT
--        local nCompleteNum = math.min(Activity.WeekendQuestion:GetComplete(), nMax)
--        local szComplete = string.format("     [c8ff00]今日已完成轮数：%d/%d", nCompleteNum, nMax)
--        return string.format("活动时间：[c8ff00]%d年%d月%d日4点-%d月%d日4点[-]\n%s\n%s", tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day, szContent, szComplete)
--end

--tbActUi.tbAwardInfo = {
--    --开始时间轴，奖励，结束时间轴
--    {"OpenLevel39", {{"BasicExp", 30}, {"Contrib", 200}}, {{"BasicExp", 10}, {"Contrib", 50}}, "OpenDay33"},
--    {"OpenDay33", {{"BasicExp", 30}, {"Energy", 200}}, {{"BasicExp", 10}, {"Energy", 50}}, "OpenDay720"},
--}
--tbActUi.FuncSubInfo = function ()
--    for _, tbInfo in ipairs(tbActUi.tbAwardInfo) do
--        if GetTimeFrameState(tbInfo[1]) == 1 and GetTimeFrameState(tbInfo[4]) ~= 1 then
--            local tbAward = {}
--            table.insert(tbAward, {szType = "Item1", szInfo = "答对奖励", tbItemList = tbInfo[2], tbItemName = {}})
--            table.insert(tbAward, {szType = "Item1", szInfo = "答错奖励", tbItemList = tbInfo[3], tbItemName = {}})
--            table.insert(tbAward, {szType = "Item1", szInfo = "累计答对奖励", tbItemList = {3315, 3316}, tbItemName = {}})
--            return tbAward
--        end
--    end
--    return {}
--end

function tbActUi:GetData()
    return self.tbData
end

function tbActUi:SynData()
   RemoteServer.SynWeekendQuestionData()
end

function tbActUi:OnSynData(tbData)
    self.tbData = tbData
    UiNotify.OnNotify(UiNotify.emNOTIFY_WEEKEND_QUIZ_SYN)
end

function tbActUi:CheckTeamMember(pP)
    local tbTeamMy = TeamMgr:GetMyTeamMemberData()
    if not tbTeamMy then
        return false,"周末答题活动需要与[FFFE0D] 一名异性侠士 [-]组成队伍才能参加哦"
    end
    local tbTeamMember =  TeamMgr:GetTeamMember()
    if #tbTeamMember ~= 1 then
        return false, "周末答题活动需要与[FFFE0D] 一名异性侠士 [-]组成队伍才能参加哦"
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

function tbActUi:GoNpc()
    local bRet,szMsg = self:CheckTeamMember(me)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    Ui.HyperTextHandle:Handle(self.szBtnTrap, 0, 0);
    Ui:CloseWindow("NewInformationPanel")
end
