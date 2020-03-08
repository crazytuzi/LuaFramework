local tbNewYearLoginAct = Activity:GetUiSetting("NewYearLoginAct")


tbNewYearLoginAct.nShowLevel = 1
tbNewYearLoginAct.szTitle    = "新年福利放送";
tbNewYearLoginAct.nBottomAnchor = -50;

tbNewYearLoginAct.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime + 1)
        local szContent = "\n    诸位侠士，新年将近，为了让诸位侠士能够更好地享受假期，武林中推出了诸多福利，让侠士们能够轻轻松松获得奖励，有哪几项福利？且听我慢慢道来。"
        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
end

tbNewYearLoginAct.tbSubInfo =
{
	{szType = "Item2", szInfo = "活动一     新年来临，好礼相迎\n     活动期间，[FFFE0D]40级[-]以上侠士每日均可领取！若当天未登录，活动结束前可花费元宝补领。领取的[FFFE0D]桃花糕[-]使用后可以获得30点活跃度！[FFFE0D]有效期24小时[-]！不用担心陪伴家人而错过活动啦！", szBtnText = "去领奖",  szBtnTrap = "[url=openwnd:text, LoginAwardsPanel, true]" },
	{szType = "Item2", szInfo = "活动二     庆贺新岁，轻松找回\n     活动期间，[FFFE0D]银两找回与完美找回[-]将享受[FFFE0D]50%的折扣[-]，即使陪伴家人未能参加活动，也能以超低折扣重新找回前两日奖励。", szBtnText = "去找回",  szBtnTrap = "[url=openwnd:test, WelfareActivity, 'SupplementPanel']"},
};

tbNewYearLoginAct.fnCustomCheckRP = function (tbData)
    if me.nLevel < LoginAwards.NEWYEAR_ACT_LEVEL then
        return
    end

    local nDayIdx = LoginAwards:GetCurDayIdx(tbData.tbCustomInfo.nStartTime)
    for i = 1, nDayIdx do
        local nSaveKey, nFlagIdx = LoginAwards:GetSaveInfo(i, tbData.tbCustomInfo.nAwardFlag)
        local nFlag = me.GetUserValue(tbData.tbCustomInfo.nGroup, nSaveKey)
        if KLib.GetBit(nFlag, nFlagIdx) == 0 then
            return true
        end
    end
end