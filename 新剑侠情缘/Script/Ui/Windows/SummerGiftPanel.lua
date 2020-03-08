local tbUi = Ui:CreateClass("SummerGiftPanel")

tbUi.szContent = "活动时间：[c8ff00]%d年%d月%d日-%d年%d月%d日\n[-]活动内容：\n1、每日参与指定活动将获得一份奖励\n2、活动结束后，将根据达成活动目标的天数额外发放一份奖励，参与天数越多，奖励越高哦！"

function tbUi:OnOpen()
    local nBeginTime = Lib:ParseDateTime(SummerGift.szBeginDay)
    local tbBegin = os.date("*t", nBeginTime)
    local tbClose = os.date("*t", nBeginTime + (SummerGift.nActAltDay-1)*24*60*60)
    local szContent = string.format(self.szContent, tbBegin.year, tbBegin.month, tbBegin.day, tbClose.year, tbClose.month, tbClose.day)
    self.pPanel:Label_SetText("ActiveDetails", szContent)

    local nCompleteFlag = me.GetUserValue(SummerGift.GROUP, SummerGift.COMPLETE_FLAG)
    local fnSetItem = function (tbItem, nIdx)
        local tbTime = os.date("*t", nBeginTime+(nIdx-1)*24*60*60)
        tbItem.pPanel:Label_SetText("ActiveMarkTxt1", string.format("%d月%d日活动", tbTime.month, tbTime.day))

        local bComplete = KLib.GetBit(nCompleteFlag, nIdx) == 1
        tbItem.pPanel:SetActive("CompletedMark", bComplete)

        tbItem["Activeitemframe1"]:SetGenericItem(SummerGift.tbDayAward[nIdx])
        tbItem["Activeitemframe1"].fnClick = tbItem["Activeitemframe1"].DefaultClick

        local tbAwardDesc = Lib:GetAwardDesCount({SummerGift.tbDayAward[nIdx]}, me)
        local tbShowAward = tbAwardDesc[1]
        local szDesc = tbShowAward.szDesc;
        tbItem.pPanel:Label_SetText("ActiveItemName1", szDesc)

        local tbTodayAct = SummerGift.tbAct[nIdx]
        for i = 1, 2 do
            local tbInfo = SummerGift.tbActInfo[tbTodayAct[i][1]]
            tbItem.pPanel:Sprite_SetSprite("ActivityIcon1_" .. i, tbInfo.szSprite, tbInfo.szAltas)
            tbItem.pPanel:Label_SetText("ActivityName1_" .. i, tbInfo.szName)
        end

        local nCurIdx = SummerGift:GetCurDayIndex()
        tbItem.pPanel:SetActive("TimeBg1", nCurIdx == nIdx)
        tbItem.pPanel:SetActive("TimeBg2", nCurIdx == nIdx)
        tbItem.pPanel:SetActive("ActivityTime1", nCurIdx == nIdx)
        tbItem.pPanel:SetActive("ActivityTime2", nCurIdx == nIdx)
        if nCurIdx == nIdx then
            local tbToday = SummerGift.tbAct[nCurIdx]
            for i = 1, 2 do
                local nSavePos = SummerGift.BEGIN_FLAG + i - 1
                local nCurTimes = me.GetUserValue(SummerGift.GROUP, nSavePos)
                local nJoinTimes = tbToday[i][2]
                tbItem.pPanel:Label_SetText("ActivityTime" .. i, string.format("%d/%d", math.min(nJoinTimes, nCurTimes), nJoinTimes))
            end
        end
    end
    self.ScrollViewActive:Update(SummerGift.nActAltDay, fnSetItem)
    local nDayIdx = SummerGift:GetCurDayIndex()
    nDayIdx = math.max(nDayIdx, 1)
    self.ScrollViewActive.pPanel:ScrollViewGoToIndex("Main", nDayIdx)

    for i, tbInfo in ipairs(SummerGift.tbAward) do
        self["ActiveReward" .. i]:SetGenericItem(tbInfo[2][1])
        self["ActiveReward" .. i].fnClick = self["ActiveReward" .. i].DefaultClick
    end

    local nCompleteDays = 0
    for i = 1, SummerGift.nActAltDay do
        local bComplete = KLib.GetBit(nCompleteFlag, i) == 1
        nCompleteDays = bComplete and (nCompleteDays + 1) or nCompleteDays
    end
    for i = 1, SummerGift.nActAltDay do
        local szSprite = i <= nCompleteDays and "Tab3_2" or "Tab3_1"
        local nScale = i <= nCompleteDays and 0.6 or 0.4
        self.pPanel:Sprite_SetSprite("Day" .. i, szSprite)
        self.pPanel:ChangeScale("Day" .. i, nScale, nScale, 1)
    end
    local nPercent = math.max(nCompleteDays - 1, 0)/(SummerGift.nActAltDay-1)
    self.pPanel:Sprite_SetFillPercent("Bar", nPercent)
end

tbUi.tbOnClick = {
    BtnActive = function (self)
        Ui:CloseWindow("WelfareActivity")
        Ui:OpenWindow("CalendarPanel", 1)
    end
}