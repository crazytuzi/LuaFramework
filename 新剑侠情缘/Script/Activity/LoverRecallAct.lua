local tbArborDayCure = Activity:GetUiSetting("LoverRecallAct")


tbArborDayCure.nShowLevel = 20
tbArborDayCure.szTitle    = "吾爱江湖忆情缘";
tbArborDayCure.nBottomAnchor = -50;

tbArborDayCure.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime)
        local szContent = "\n    诸位侠士，诸位是否已经收获了属于自己的情缘？是否还记得昔日与你一同闯荡武林的好伙伴？如今「隐香楼」得到了可以追忆他们的过往的方法，只需集齐线索即可交换一份地图。"
        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
end

tbArborDayCure.tbSubInfo1 = 
{
	{szType = "Item2", szInfo = "吾爱情缘忆江湖\n     2017年[FFFE0D]5月19日-22日凌晨4点[-]，侠士通过完成[FFFE0D]一个每日目标[-]即可获得一个线索，每[FFFE0D]五个线索[-]可以合成一份[FFFE0D]地图[-]，可选择自己想进行的故事进行，可邀请[FFFE0D]一名亲密度5级及以上的异性好友组成队伍[-]前往。邀请者将获得一份随机奖励，据闻其中有可能得到稀有的[FFFE0D]超帅外装[-]哦！而被邀请者也能获得奖励。每人每天不限制开启次数，但只有一次进入他人线索地图的次数哦！", szBtnText = "获取线索",  szBtnTrap = "[url=openwnd:test, CalendarPanel]" },
};

tbArborDayCure.FuncSubInfo = function (tbData)
	local tbSubInfo = {}
	for _, tbInfo in ipairs(tbArborDayCure.tbSubInfo1) do
		table.insert(tbSubInfo, tbInfo)
	end
	return tbSubInfo
end