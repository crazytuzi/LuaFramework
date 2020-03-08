
local tbRechargeCardActUi = Activity:GetUiSetting("RechargeCardActNormal");

tbRechargeCardActUi.nShowLevel = 10;
tbRechargeCardActUi.szTitle = "周末狂欢";
tbRechargeCardActUi.nBottomAnchor = -80;

tbRechargeCardActUi.FuncContent = function ()
		local nEndTime = Lib:GetLocalWeekEndTime(GetTime() - 3600 * 4) - 1
		local nFromTime = nEndTime - 3600 * 24
		local tbTime1 = os.date("*t", nFromTime)
		local tbTime2 = os.date("*t", nEndTime)
		return string.format("活动时间：[c8ff00]%d年%d月%d日-%d月%d日两日[-]", tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day)
end

tbRechargeCardActUi.tbSubInfo =
{
	{szType = "Item2", szInfo = string.format("活动一：\n福利狂欢，元宝为邻；活动期间，充值送礼活动7日礼包、30日礼包可额外领取[FFFE0D]%d%%元宝[-]", Recharge.fActivityCardAwardParam) , szBtnText = "前  往", szBtnTrap = "[url=openwnd:test, WelfareActivity, RechargeGift]" },
	{szType = "Item2", szInfo = "活动二：\n挑战盟主，元宝不断；阳刚热忱的盟主独孤剑将褒奖诸位挑战者，活动期间，挑战盟主的拍卖物品的产出将提升[FFFE0D]50%[-]", szBtnText = "前  往",  szBtnTrap = "[url=openwnd:test, CalendarPanel]" },
	{szType = "Item2", szInfo = "活动三：\n家族烤火，人人有奖；活动期间参与家族烤火，答题将获得[FFFE0D]双倍贡献[-]，且投掷骰子的获奖成员[FFFE0D]增加一倍[-]", szBtnText = "前  往",  szBtnTrap = "[url=openwnd:test, CalendarPanel]" },
};
