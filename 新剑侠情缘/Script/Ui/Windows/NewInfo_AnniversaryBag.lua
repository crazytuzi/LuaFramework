local tbUi = Ui:CreateClass("NewInfo_AnniversaryBag")

function tbUi:OnOpen(tbData)
	local nStartTime, nEndTime = unpack(tbData)
	local tbStartTime    = os.date("*t", nStartTime);
	local tbEndTime    = os.date("*t", nEndTime);
	self.pPanel:Label_SetText("QingrenjieTime", string.format("活动时间：%d年%d月%d日-%d月%d日", tbStartTime.year, tbStartTime.month,tbStartTime.day, tbEndTime.month, tbEndTime.day ))
end
tbUi.tbOnClick = {};

tbUi.tbOnClick.Btn1 = function (self)
	Ui:OpenWindow("WelfareActivity", "NewYearBuyGift")
end