local tbDuanWuJieUi = Activity:GetUiSetting("DuanWuJie");

tbDuanWuJieUi.DuanWuJie = {
    nShowLevel = 20;
    szTitle = "端午送好礼";
    szBtnText = "每日目标";
    szBtnTrap = "[url=openwnd:test, CalendarPanel, 3]";
    FuncContent = function (tbData)
        local szStart   = Lib:TimeDesc7(tbData.nStartTime)
        local szEnd     = Lib:TimeDesc7(tbData.nEndTime + 1)
        local szContent = "    诸位侠士在达成[FFFE0D]每日目标20、40、60、80、100[-]的时候，将额外获得一份奖励，奖励从[FFFE0D]粽叶、鲜肉、稻米、麻绳[-]中随机一种，集齐四种后可以随机合成一个粽子。"
        return string.format("活动时间：[c8ff00]%s-%s[-]\n\n%s", szStart, szEnd, szContent)
    end;

    tbSubInfo =
    {
    	{szType = "Item1", szInfo = "活跃随机奖励", tbItemList = {2586, 2587, 2588, 2589}, tbItemName = {"粽叶", "稻米", "鲜肉", "麻绳"}},
    	{szType = "Item1", szInfo = "合成奖励", tbItemList = {8250, 8251}, tbItemName = {"香粳白玉粽", "彩缕碧筠粽"}},
    }
}

tbDuanWuJieUi.EverydayTarget1 = {
    nShowLevel = 20;
    szTitle = "全民好礼";
    szBtnText = "每日目标";
    szBtnTrap = "[url=openwnd:test, CalendarPanel, 3]";

    FuncContent = function (tbData)
        local szStart   = Lib:TimeDesc7(tbData.nStartTime)
        local szEnd     = Lib:TimeDesc7(tbData.nEndTime + 1)
        local szContent = "    诸位侠士在达成[FFFE0D]每日目标100点[-]的时候，将额外获得一份奖励哦，快去努力完成每日目标获取奖励吧。";
        return string.format("    活动时间：[c8ff00]%s-%s[-]\n\n%s", szStart, szEnd, szContent)
    end;
    tbSubInfo =
    {
        {szType = "Item1", szInfo = "100活跃奖励", tbItemList = {3515}, tbItemName = {"每日目标活跃礼盒"}},
    }
}

tbDuanWuJieUi.GanEnAct = {
    nShowLevel = 20;
    szTitle = "感恩节";
    szBtnText = "每日目标";
    szBtnTrap = "[url=openwnd:test, CalendarPanel, 3]";

    FuncContent = function (tbData)
        local szStart   = Lib:TimeDesc7(tbData.nStartTime)
        local szEnd     = Lib:TimeDesc7(tbData.nEndTime + 1)
        local szContent = "    诸位侠士在达成[FFFE0D]每日目标20、40、60、80、100[-]的时候，将额外获得一份奖励，奖励从[FFFE0D]火鸡、黄油、胡萝卜、碎面包[-]中随机一种，集齐四种后可以随机合成一个感恩节礼盒。";
        return string.format("    活动时间：[c8ff00]%s-%s[-]\n\n%s", szStart, szEnd, szContent)
    end;
    tbSubInfo =
    {
        {szType = "Item1", szInfo = "活跃随机奖励", tbItemList = {3398, 3399, 3400, 3401}, tbItemName = {"火鸡", "黄油", "胡萝卜", "碎面包"}},
        {szType = "Item1", szInfo = "合成奖励", tbItemList = {3403}, tbItemName = {"感恩节礼盒"}},
    }
}

tbDuanWuJieUi.YuanQi = {
    nShowLevel = 20;
    szTitle = "元气大礼包";
    szContent = "    诸位侠士今日的每日目标[FFFE0D] 80 [-]达成的时候，将额外获得[FFFE0D]未鉴定的卷轴*1、黄金宝箱*2[-]的奖励，快来参与活动达成活跃度吧。\n    ";
    szBtnText = "每日目标";
    szBtnTrap = "[url=openwnd:test, CalendarPanel, 3]";

    tbSubInfo =
    {
        {szType = "Item1", szInfo = "活跃奖励", tbItemList = {3013, 786}, tbItemName = {"未鉴定的卷轴", "黄金宝箱"}},
    }
}