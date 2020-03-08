if not MODULE_GAMESERVER then
	Activity.WorldCupGuessAct = Activity.WorldCupGuessAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("WorldCupGuessAct") or Activity.WorldCupGuessAct

tbAct.nJoinLevel = 20

tbAct.nShowRewardItemId1 = 8318	--竞猜界面展示奖励用道具id(冠军)
tbAct.nShowRewardItemId4 = 8319	--竞猜界面展示奖励用道具id(四强)

tbAct.tbBaseReward1 = {  --基础奖励(冠军)
	{"Contrib", 15000},
}
tbAct.tbBaseReward4 = {	--基础奖励(四强)
	{"Contrib", 5000},
}

tbAct.tbTop4Cfg = { --四强
    {Lib:ParseDateTime("2018-06-29 04:00:00"), Lib:ParseDateTime("2018-06-30 21:59:59"), 2},   --{开始，结束，x倍基础奖励}
    {Lib:ParseDateTime("2018-06-30 22:00:00"), Lib:ParseDateTime("2018-07-06 21:59:59"), 1},
}
tbAct.tbTop1Cfg = {  --冠军
    {Lib:ParseDateTime("2018-06-29 04:00:00"), Lib:ParseDateTime("2018-06-30 21:59:59"), 5},   --{开始，结束，x倍基础奖励}
    {Lib:ParseDateTime("2018-06-30 22:00:00"), Lib:ParseDateTime("2018-07-06 21:59:59"), 3},
    {Lib:ParseDateTime("2018-07-06 22:00:00"), Lib:ParseDateTime("2018-07-11 01:59:59"), 2},
	{Lib:ParseDateTime("2018-07-11 02:00:00"), Lib:ParseDateTime("2018-07-15 22:59:59"), 1},
}

tbAct.tbGuessCost = {	--竞猜消耗(元宝)
	300, 100, 100, 100, 100,
}

tbAct.tbSelectCfg = {	--选择界面配置
	{8218, 8219, 8220, 8221},
	{8222, 8223, 8224, 8225},
	{8226, 8227, 8228, 8229},
	{8230, 8231, 8232, 8233},
	{8234, 8235, 8236, 8237},
	{8238, 8239, 8240, 8241},
	{8242, 8243, 8244, 8245},
	{8246, 8247, 8248, 8249},
}

tbAct.tbTeamCfg = {	--球队配置
	[0] = {"默认", "NationalFlag_Unidentified"},
	[8218] = {"俄罗斯", "NationalFlag_A_Russia"},
	[8219] = {"沙特阿拉伯	", "NationalFlag_A_SaudiArabia"},
	[8220] = {"埃及", "NationalFlag_A_Egypt"},
	[8221] = {"乌拉圭", "NationalFlag_A_Uruguay"},
	[8222] = {"葡萄牙", "NationalFlag_B_Portugal"},
	[8223] = {"西班牙", "NationalFlag_B_Spain"},
	[8224] = {"摩洛哥", "NationalFlag_B_Morocco"},
	[8225] = {"伊朗", "NationalFlag_B_Iran"},
	[8226] = {"法国", "NationalFlag_C_France"},
	[8227] = {"澳大利亚", "NationalFlag_C_Australia"},
	[8228] = {"秘鲁", "NationalFlag_C_Peru"},
	[8229] = {"丹麦", "NationalFlag_C_Denmark"},
	[8230] = {"阿根廷", "NationalFlag_D_Argentina"},
	[8231] = {"冰岛", "NationalFlag_D_Lceland"},
	[8232] = {"克罗地亚", "NationalFlag_D_Croatia"},
	[8233] = {"尼日利亚", "NationalFlag_D_Nigeria"},
	[8234] = {"巴西", "NationalFlag_E_Brazil"},
	[8235] = {"瑞士", "NationalFlag_E_Switzerland"},
	[8236] = {"哥斯达黎加", "NationalFlag_E_CostaRica"},
	[8237] = {"塞尔维亚", "NationalFlag_E_Serbia"},
	[8238] = {"德国", "NationalFlag_F_Germany"},
	[8239] = {"墨西哥", "NationalFlag_F_Mexico"},
	[8240] = {"瑞典", "NationalFlag_F_Sweden"},
	[8241] = {"韩国", "NationalFlag_F_Korea"},
	[8242] = {"比利时", "NationalFlag_G_Belgium"},
	[8243] = {"巴拿马", "NationalFlag_G_Panama"},
	[8244] = {"突尼斯", "NationalFlag_G_Tunisia"},
	[8245] = {"英格兰", "NationalFlag_G_England"},
	[8246] = {"波兰", "NationalFlag_H_Poland"},
	[8247] = {"塞内加尔", "NationalFlag_H_Senegal"},
	[8248] = {"哥伦比亚", "NationalFlag_H_Columbia"},
	[8249] = {"日本", "NationalFlag_H_Japan"},

}

--程序用,策划不用配
tbAct.tbTop1 = {}
tbAct.tbTop4 = {}

function tbAct:CheckPlayer(pPlayer)
	if pPlayer.nLevel < self.nJoinLevel then
		return false, string.format("请先将等级提升至%d", self.nJoinLevel)
	end
	return true
end

function tbAct:GetTimeIdx(tbTimeCfg)
	local nNow = GetTime()
	local nTimeIdx = 0
	for i, tb in ipairs(tbTimeCfg) do
		if nNow >= tb[1] and nNow <= tb[2] then
			nTimeIdx = i
			break
		end
	end
	return nTimeIdx, tbTimeCfg[nTimeIdx]
end

if MODULE_GAMECLIENT then
	function tbAct:Guess(nIdx, nItemTemplateId)
		RemoteServer.WorldCupReq("Guess", nIdx, nItemTemplateId)
	end

	function tbAct:UpdateData()
		RemoteServer.WorldCupReq("UpdateData")
	end

	function tbAct:OnUpdateData(tbData)
		self.tbData = tbData
		local szUiName = "WorldCupGuessPanel"
		if Ui:WindowVisible(szUiName) ~= 1 then
			return
		end
		Ui(szUiName):Refresh()
	end
end