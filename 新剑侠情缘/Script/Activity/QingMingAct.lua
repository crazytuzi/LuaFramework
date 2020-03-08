local tbQingMingAct = Activity:GetUiSetting("QingMingAct")


tbQingMingAct.nShowLevel = 20
tbQingMingAct.szTitle    = "清明时节雨纷纷";
tbQingMingAct.nBottomAnchor = -50;

tbQingMingAct.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime)
        local szContent = "\n    诸位侠士，清明时节雨纷纷，路上行人欲断魂。江湖数十载，已有许多声名显赫的人消失于武林，而这些人，有的是心怀天下的枭雄，有的是独步武林的高手，今日，隐香楼得到他们故去之地的线索，有缘者可前去缅怀一番。"
        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
end

tbQingMingAct.tbSubInfo1 = 
{
	{szType = "Item2", szInfo = "江湖夜雨十年灯\n     2017年[FFFE0D]4月2日-5日凌晨4点[-]，侠士通过完成[FFFE0D]一个每日目标[-]以及[FFFE0D]五次家族捐献[-]均可获得一个线索，通过[FFFE0D]家族捐献[-]每天[FFFE0D]最多获得五个线索[-]，每[FFFE0D]五个线索[-]可以合成一份[FFFE0D]随机地图[-]，可邀请[FFFE0D]一名亲密度5级以上的好友组成队伍[-]前往。双方均可获得经验！邀请者更可获得一份随机奖励！每人每天不限制开启次数，但只有一次进入他人线索地图的次数哦！", szBtnText = "获取线索",  szBtnTrap = "[url=openwnd:test, CalendarPanel]" },
};

tbQingMingAct.FuncSubInfo = function (tbData)
	local tbSubInfo = {}
	for _, tbInfo in ipairs(tbQingMingAct.tbSubInfo1) do
		table.insert(tbSubInfo, tbInfo)
	end
	return tbSubInfo
end