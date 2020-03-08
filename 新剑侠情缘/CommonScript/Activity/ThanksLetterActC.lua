if not MODULE_GAMESERVER then
    Activity.ThanksLetterAct = Activity.ThanksLetterAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("ThanksLetterAct") or Activity.ThanksLetterAct

tbAct.szMainKey = "ThanksLetterAct"

tbAct.tbRedBags = {
    {nDate = Lib:ParseDateTime("2019-02-04"), szPwd = "金猪报喜迎春来", nAwardId = 4, },
    {nDate = Lib:ParseDateTime("2019-02-05"), szPwd = "九州福照贺新岁", nAwardId = 4, },
    {nDate = Lib:ParseDateTime("2019-02-06"), szPwd = "福满江湖齐团圆", nAwardId = 4, },
    {nDate = Lib:ParseDateTime("2019-02-07"), szPwd = "己亥岁伴君如故", nAwardId = 4, },
}

if MODULE_GAMECLIENT then
	function tbAct:OnThanksLetterUpdate(nNow, nCurRedBagDate)
		if Ui:WindowVisible("ThanksLetterPanel") ~= 1 then
			return
		end
		Ui("ThanksLetterPanel"):OnServerUpdate(nNow, nCurRedBagDate)
	end
end