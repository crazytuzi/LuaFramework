
local tbTestInfo = Activity:GetNormalNewInfomationUiSetting("test");

tbTestInfo.tbData = {
	nShowLevel = 20;
	szTitle = "端午送好礼";
	szBtnText = "每日目标";
	szBtnTrap = "[url=openwnd:test, CalendarPanel, 3]";
	szContent = "    活动时间：[c8ff00]2017年4月12日凌晨4点-4月15日凌晨3点[-]\n\n    诸位侠士在达成[FFFE0D]每日目标100点[-]的时候，将额外获得一份奖励哦，快去努力完成每日目标获取奖励吧。";
	tbSubInfo =
	{
		{szType = "Item1", szInfo = "活跃随机奖励", tbItemList = {2586, 2587, 2588, 2589}, tbItemName = {"粽叶", "稻米", "鲜肉", "麻绳"}},
		{szType = "Item1", szInfo = "合成奖励", tbItemList = {3311, 3715, 2591, 2590}, tbItemName = {"艺趣·盛典华服", "八宝粽", "洗髓经（中卷）", "五香粽"}},
	}
}


local tbLDMJInfo = Activity:GetNormalNewInfomationUiSetting("CrossLDMJ");

tbLDMJInfo.tbData = {
	nShowLevel = 1;
	szTitle = "[FFFE0D]汉王楚霸争天下，儿女情长传千古。[-]";
	szContent = "    “汉王刘邦与西楚霸王项羽互争天下，楚军受诈深入重地而围困于垓下，人心涣散，尽行崩解。未去者，仅八百余人。项羽无可奈何，惟思突出重围卷土重来。入帐中别虞姬，奈何势促时穷却也不舍爱妻。为重振项羽斗志，虞姬夺剑自刎以断其后顾之忧……”\n    忠贞之爱，大义之行，可歌可泣！\n    诸位豪侠，现听闻绝世幻境惊现废墟，更有甚者言“霸王别姬”上演于此，不妨携家族成员共同前往去探查一番，感受并参与这场旷古传世的儿女情长吧！\n    跨服历代名将资格获取：[FFFE0D]每周二、三、五、六晚[-]本服历代名将中表现优异的家族。（将于每周六晚本服历代名将结束后进行结算并公布）\n    跨服历代名将场次时间：首次获取资格后的[FFFE0D]每周一晚22:00-23:00[-]。";
	tbSubInfo =
	{
		{szType = "Item1", szInfo = "丰厚奖励", tbItemList = {3553, 6112, 4595, 1396}, tbItemName = {"同伴·项羽", "魂石·绝世虞姬", "魂石·项羽", "帝皇令"}},
	}
}
