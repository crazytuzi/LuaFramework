local tbActUi = Activity:GetUiSetting("WinterAct")

tbActUi.nShowLevel = 1
tbActUi.szTitle    = "冬至活动";
tbActUi.nBottomAnchor = -50;

tbActUi.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime)
        local szContent = "\n    冬至活动即将开启，诸位鏖战武林已有不少时日，劳苦功高，飞云与姑父、纳兰姑娘商议过后，希望让诸位能够稍事休息，小小心意，还望诸位侠士能够享受一个轻松写意、温暖安逸的冬至佳节！"
        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
end

tbActUi.tbSubInfo =
{
	{szType = "Item2", szInfo = "活动一      冬日烤火，温暖将至\n2016年[FFFE0D]12月21日参与家族烤火[-]，即可轻松获得[FFFE0D]20活跃度[-]，活动期间[FFFE0D]每答一题，无论对错[-]，即可获得[FFFE0D]20活跃度[-]，全天放松，轻松来袭，无需参加活动，只需烤烤火取取暖，轻轻松松满活跃！", szBtnText = "前  往",  szBtnTrap = "[url=openwnd:test, CalendarPanel]" },
	{szType = "Item2", szInfo = "活动二      冬日饺子，轻松将至\n2016年[FFFE0D]12月22日凌晨4点[-]，所有玩家均可获得一碗饺子，可用于领取8小时2.5倍离线经验，减轻负担，离线也能轻松得经验，热腾腾的饺子保质期仅有一日，[FFFE0D]12月22日4点[-]过期，要注意在[FFFE0D]背包使用[-]哦！", szBtnText = "前  往", szBtnTrap = "[url=openwnd:test, ItemBox]" },
	{szType = "Item2", szInfo = "活动三      冬日汤圆，甜蜜将至\n2016年[FFFE0D]12月22日凌晨4点[-]，所有玩家均可获得18枚汤圆，可用于[FFFE0D]完美奖励完美找回[-]，每次完美找回仅需消耗一颗汤圆，无需元宝，香糯可口的汤圆保质期仅有一日，[FFFE0D]12月22日4点[-]过期，要注意前往福利界面进行[FFFE0D]完美找回[-]哦！\n注意：可找回所有完美找回奖励，但银两找回不可使用汤圆", szBtnText = "前  往",  szBtnTrap = "[url=openwnd:test, WelfareActivity, SupplementPanel]" },
};
