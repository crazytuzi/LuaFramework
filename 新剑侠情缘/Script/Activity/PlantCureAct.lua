local tbAct         = Activity:GetUiSetting("PlantCureAct")
tbAct.szTitle       = "端午节活动";
tbAct.nBottomAnchor = -50;

tbAct.FuncContent = function (tbData)
	local szContent = "[FFFE0D]端午节活动开始了！[-]\n活动时间：[c8ff00]%s-%s[-]\n\n    诸位侠士在家园植树花费元宝进行[FFFE0D]养护[-]或者[FFFE0D]协助养护[-]的时候，将额外获得一份奖励，奖励从[FFFE0D]粽叶、鲜肉、稻米、麻绳[-]中随机一种，集齐四种后可以随机合成一个粽子。"
	return string.format(szContent, Lib:TimeDesc7(tbData.nStartTime), Lib:TimeDesc7(tbData.nEndTime))
end

tbAct.tbSubInfo = 
{
	{szType = "Item1", szInfo = "养护随机奖励", tbItemList = {10899, 10900, 10901, 10902}, tbItemName = {"粽叶", "稻米", "鲜肉", "麻绳"}},
    {szType = "Item1", szInfo = "合成奖励", tbItemList = {10904, 10905, 10906, 10907, 10908}, tbItemName = {"蜜枣粽", "什锦粽", "紫薯粽", "红豆粽", "咸肉粽"}},
};