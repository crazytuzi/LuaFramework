local tbWomensDay = Activity:GetUiSetting("WomensDay")


tbWomensDay.nShowLevel = 20
tbWomensDay.szTitle    = "三月八号女侠节";
tbWomensDay.nBottomAnchor = -50;

tbWomensDay.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime + 1)
        local szContent = "\n    诸位侠士，如今正值三月八号女侠节，江湖中的诸位男性侠士固然武功卓绝，令人钦佩，然而咱们武林中不少女侠同样是巾帼不让须眉，声名远播。今日，便是这些女侠们的节日！"
        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
end

tbWomensDay.tbSubInfo =
{
	{szType = "Item2", szInfo = "活动一     花叶两相和\n     女侠节来临之际，武林盟为女侠们准备了礼物，岂知竟被不轨之徒所劫，请女侠与男性侠士组成[FFFE0D]两人[-]队伍，由女侠担任[FFFE0D]队长[-]，在临安城[FFFE0D][url=npc:杨瑛, 633, 15][-]女侠处经过指引拿回礼物，同队男性侠士也可以获得一份奖励，男性侠士记得好好保护女侠哦。活动期间，每天可以[FFFE0D]无限次[-]参与活动，但只有[FFFE0D]一次[-]奖励，如队伍中双方都已经拿过奖励，将不能参加活动！活动期间玩家连续[FFFE0D]三天[-]都参加活动，还会获得限时称号！", szBtnText = "前往",  szBtnTrap = "[url=npc:杨瑛, 633, 15]"},
	{szType = "Item2", szInfo = "活动二     鲜花赠佳人\n     再英姿飒爽的女侠，也抵不过万紫千红的鲜花的芬芳。活动期间，每天[FFFE0D]前9次赠送[-] [aa62fc][url=openwnd:99朵玫瑰花, ItemTips, 'Item', nil, 2180] [-]，将额外获得[64db00] [url=openwnd:女侠的青睐, ItemTips, 'Item', nil, 3914] [-]，女侠虽美，不免爱花，可不要忘记为你心仪的女侠时常送上花朵噢！", szBtnText = "前往",  szBtnTrap = "[url=openwnd:test, CommonShop,'Treasure', 'tabAllShop']"},
};