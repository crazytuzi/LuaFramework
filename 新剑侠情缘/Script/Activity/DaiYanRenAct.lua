Activity.DaiYanRen = Activity.DaiYanRen or {}
local tbAct = Activity.DaiYanRen
tbAct.tbMsg = {
    DYRAct_TryAgreeApply = "[FFFE0D]%s[-]邀请你一同参与代言人情缘秘境活动, 一旦同意，[FFFE0D]无法更改[-]，是否确定同意参加？\n(%%d秒后自动关闭)",
    DYRAct_TryAgreeEnterFuben = "[FFFE0D]%s[-]邀请你一同参与情缘副本活动\n(%%d秒后自动关闭)",
}
function tbAct:OnGetInvite(szNotifyKey, nInviteId, szName, ...)
    local tbParam = {...}
    local fnAgree = function ()
        if not TeamMgr:HasTeam() then
            me.CenterMsg("没有队伍")
            return
        end

        local tbMember = TeamMgr:GetTeamMember()
        if #tbMember ~= 1 then
            me.CenterMsg("只能两个人队伍")
            return
        end

        if tbMember[1].nPlayerID ~= nInviteId then
            me.CenterMsg("邀请已过期")
            return
        end
        RemoteServer.Act_DaiYanRenAct(szNotifyKey, nInviteId, true, tbParam)
    end

    local fnDisagree = function ()
        RemoteServer.Act_DaiYanRenAct(szNotifyKey, nInviteId, false, tbParam)
    end

    local szMsg = string.format(self.tbMsg[szNotifyKey], szName)
    Ui:OpenWindow("MessageBox", szMsg, {{fnAgree}, {fnDisagree},
    {function ()
        Ui:CloseWindow("MessageBox")
    end}},
    {"同意", "拒绝"}, nil, 20)
end


local tbDaiYanRen = Activity:GetUiSetting("DaiYanRenAct")


tbDaiYanRen.nShowLevel = 40
tbDaiYanRen.szTitle    = "新颖不离伴江湖";
tbDaiYanRen.nBottomAnchor = -50;

tbDaiYanRen.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime)
        local szContent = "\n    诸位侠士，近日江湖中出了一对风姿绝代的侠侣。他们俩男的英俊潇洒，女的倾国倾城，而且两人均为心地善良，武功卓绝之人，却从不以真实姓名示人。最近，声名鹊起的他们，在数月前忽然消失在江湖上，让许多人升起了兴趣。"
        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
end

tbDaiYanRen.tbSubInfo1 = 
{
    {szType = "Item2", szInfo = "新心相映携手行\n     诸位侠士，活动期间，可前往[47f005][url=npc:公孙惜花, 99, 10][-]处报名参与活动！规则如下：\n1、寻找一名[FFFE0D]亲密度5级、等级40级以上[-]的[FFFE0D]异性好友[-]组成[FFFE0D]2人队伍[-]前去报名\n2、一旦报名结成关系，不可更换\n3、活动过程中[FFFE0D]任务可以单人独立完成[-]，[FFFE0D]秘境必须2人组队[-]完成\n4、活动结束后，所有侠士身上的任务均会被[FFFE0D]自动删除[-]，各位侠士注意抓紧时间完成哦！\n活动过程中不仅有[ff578c] [url=openwnd:破月剑, ItemTips, 'Item', nil, 4801] [-]、[ff578c] [url=openwnd:残红剑, ItemTips, 'Item', nil, 4802] [-]、[ff578c] [url=openwnd:心心相惜, ItemTips, 'Item', nil, 4803] [-]、[ff578c] [url=openwnd:楚楚动人, ItemTips, 'Item', nil, 4804] [-]、[ff578c] [url=openwnd:相思门, ItemTips, 'Item', nil, 4805] [-]、[ff578c] [url=openwnd:一人心, ItemTips, 'Item', nil, 4806] [-]、[ff578c] [url=openwnd:月兔灯, ItemTips, 'Item', nil, 4808] [-]等物品作为奖励，更会在林更新少侠与颖宝宝女侠的见证下，经历一系列的情缘秘境！", szBtnText = "前去报名",  szBtnTrap = "[url=npc:公孙惜花, 99, 10]" },
};

tbDaiYanRen.FuncSubInfo = function (tbData)
    local tbSubInfo = {}
    for _, tbInfo in ipairs(tbDaiYanRen.tbSubInfo1) do
        table.insert(tbSubInfo, tbInfo)
    end
    return tbSubInfo
end

tbDaiYanRen.fnCustomCheckRP = function (tbData)
    local bNotApply      = me.GetUserValue(73, 2) == 0
    local nToday         = Lib:GetLocalDay()
    local tbRedPointInfo = Client:GetUserInfo("ActivityUiRedPoint")
    local bDayNotShow    = not tbRedPointInfo[tbData.szKeyName] or tbRedPointInfo[tbData.szKeyName] ~= nToday
    return bNotApply and bDayNotShow
end