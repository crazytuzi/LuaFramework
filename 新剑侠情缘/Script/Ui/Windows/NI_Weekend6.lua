local tbUi = Ui:CreateClass("NI_Weekend6")

tbUi.szEndTime1 = "2016/6/7" --不包括这一天
tbUi.szEndTime2 = "2016/6/6"
tbUi.szEndTime3 = "2016/6/12"
tbUi.szTimeDesc1 = "2016年6月5日-2016年6月6日"  --十连抽打折活动
tbUi.szTimeDesc2 = "2016年6月5日-2016年6月5日"  --珍宝阁水晶上架活动
tbUi.szTimeDesc3 = "2016年6月5日-2016年6月11日" --周月卡额外领50%元宝
function tbUi:OnOpen()
    local nCurTime = GetTime()
    for i = 1, 3 do
        local szLast = self["szTimeDesc" .. i]
        local nEndTime = Lib:ParseDateTime(self["szEndTime" .. i])
        if nCurTime >= nEndTime then
            szLast = string.format("%s[FFFE0D]（活动已结束）[-]", szLast)
        else
            local nLastTime = math.ceil((nEndTime - nCurTime)/(24*60*60))
            szLast = string.format("%s[FFFE0D]（活动剩余%d天）[-]", szLast, math.max(nLastTime, 1))
        end
        self.pPanel:Label_SetText("WeekenderTimeDetails" .. i, szLast)
    end
end

function tbUi:DirectToUi(...)
    Ui:OpenWindow(...)
    Ui:CloseWindow("NewInformationPanel")
end

tbUi.tbOnClick = {
    BtnWeekender1 = function (self)--招募
        self:DirectToUi("Partner", "CardPickingPanel")
    end,
    BtnWeekender2 = function (self)--珍宝阁
        self:DirectToUi("CommonShop", "Treasure", 1)
    end,
    BtnWeekender3 = function (self)--充值送礼
        self:DirectToUi("WelfareActivity", "RechargeGift")
    end,
}