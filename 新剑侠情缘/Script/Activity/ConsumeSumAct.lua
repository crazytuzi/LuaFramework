
local tbActUi = Activity:GetUiSetting("ConsumeSumAct");

tbActUi.nShowLevel = 1;
tbActUi.szTitle = "累计消费活动";
tbActUi.nBottomAnchor = -80;

tbActUi.FuncContent = function (tbData)
		local tbTime1 = os.date("*t", tbData.nStartTime)
		local tbTime2 = os.date("*t", tbData.nEndTime)
		return string.format([[活动时间：[c8ff00]%d年%d月%d日-%d月%d日[-]
\t\t\t活动内容：
\t\t\t尊敬的侠士，在活动期间累计消费元宝数量达到要求就将获得奖励！
]], tbTime1.year, tbTime1.month, tbTime1.day, tbTime2.month, tbTime2.day)
end

tbActUi.szBtnText = "前去消费"
tbActUi.szBtnTrap = "[url=openwnd:test, CommonShop, 'Treasure']";

tbActUi.tbSubInfo =
{
	{ szType = "Item3", szSub = "Consume", nParam =100,  tbItemList = {1394,1395}, tbItemName = {"名将令","逐鹿令"}},
	{ szType = "Item3", szSub = "Consume", nParam =1000, tbItemList = {1394,1395}, tbItemName = {"名将令","逐鹿令"}},
	{ szType = "Item3", szSub = "Consume", nParam =3000, tbItemList = {1394,1395}, tbItemName = {"名将令","逐鹿令"}},
};
