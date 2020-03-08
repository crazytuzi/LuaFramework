local tbAct = Activity:GetUiSetting("DanceAct")

tbAct.nShowLevel = 1
tbAct.szTitle    = "舞动江湖";
tbAct.szUiName = "Normal";
tbAct.FnCustomData = function (_, tbData)
    local nTotalPlayerCount,nToDayCount = 0, 0
            if tbActData and tbActData.tbCustomInfo then
                local tbCustomInfo = tbActData.tbCustomInfo
                nTotalPlayerCount = tbCustomInfo.nTotalPlayerCount
                nToDayCount = tbCustomInfo.nToDayCount
                if Lib:GetLocalDay() ~= tbCustomInfo.nLastPlayDay then
                    nToDayCount = 0;
                end
            end
    local szContent =         string.format([[
[FFFE0D]舞动江湖活动开始了！[-]
[FFFE0D]活动时间：[-]%s-%s
[FFFE0D]参与等级：[-]20级
[FFFE0D]总剩余参加次数：%d[-]
[FFFE0D]今日还可参加次数：%d[-]
活动期间每天[FFFE0D]12:45[-]、[FFFE0D]15:00[-]、[FFFE0D]20:00[-]都会开放一场比赛，各位大侠记得及时报名进入准备场地，[FFFE0D]5分钟[-]后比赛准时开始。
开始比赛后各位大侠会开始跳舞，大侠需要按照给出的指令按顺序点击对应的按钮，方能维持自己持续跳舞，每正确执行一条指令都会为自己加[FFFE0D]1[-]积分，错误不加分；一段时间后会进入死斗阶段，此时执行正确指令加[FFFE0D]2[-]积分，一旦操作失误，将不能继续进行比赛。
执行指令的速度够快，获得的积分更可翻倍！连续的正确操作还能得到额外的奖励积分哦！
每场比赛都会按照积分排行为各位大侠发放奖励；活动最终结束时还会按大侠在整个期间获得的积分排行，按照排行发放奖励，快来争夺[FFFE0D]舞林至尊[-]限时称号和[11adf6][url=openwnd:玉丝千缕, ItemTips, "Item", nil, 7954][-]吧！
活动期间玩家每天可以参加[FFFE0D]2场[-]比赛，整个期间最多允许参加[FFFE0D]10场[-]比赛。
[FFFE0D]注：[-]打开音乐效果更棒哦！
                ]], Lib:TimeDesc11(tbData.nStartTime), Lib:TimeDesc11(tbData.nEndTime),  Activity.DanceMatch.tbSetting.nTotalPlayTimes - nTotalPlayerCount, Activity.DanceMatch.tbSetting.nEveryDayPlayerTimes - nToDayCount)
     
     local fnCall = function ()
        Activity.DanceMatch:TrySignUp()
        Ui:CloseWindow("NewInformationPanel")
     end
    return {szContent, "参与", fnCall}
end
