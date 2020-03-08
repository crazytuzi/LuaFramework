if not MODULE_GAMESERVER then
	Activity.WorldCupAct = Activity.WorldCupAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("WorldCupAct") or Activity.WorldCupAct


tbAct.szMainKey = "WorldCupAct"

tbAct.nJoinLevel = 20

tbAct.nBookId = 8216	--收集册id
tbAct.nMedalItemId = 8217	--未鉴定徽章道具id
tbAct.szIdentyCostType = "Contrib"   --鉴定消耗货币类型，不能为元宝
tbAct.nIdentyMedalCost = 60	--鉴定徽章消耗
tbAct.tbActiveAward = { -- 活跃奖励个数
	[1] = 0,
	[2] = 0,
	[3] = 1,
	[4] = 1,
	[5] = 1,
}
tbAct.tbDailyGiftAward = {	--购买每日礼包奖励个数
	[1] = 1,	--1元
	[2] = 1,	--3元
	[3] = 1,	--6元
}

tbAct.tbScoreCfg = {
	[8218] = 1,    --俄罗斯国家队徽章
	[8219] = 1,    --沙特阿拉伯国家队徽章
	[8220] = 1,    --埃及国家队徽章
	[8221] = 1,    --乌拉圭国家队徽章
	[8222] = 1,    --葡萄牙国家队徽章
	[8223] = 1,    --西班牙国家队徽章
	[8224] = 1,    --摩洛哥国家队徽章
	[8225] = 1,    --伊朗国家队徽章
	[8226] = 1,    --法国国家队徽章
	[8227] = 1,    --澳大利亚国家队徽章
	[8228] = 1,    --秘鲁国家队徽章
	[8229] = 1,    --丹麦国家队徽章
	[8230] = 1,    --阿根廷国家队徽章
	[8231] = 1,    --冰岛国家队徽章
	[8232] = 1,    --克罗地亚国家队徽章
	[8233] = 1,    --尼日利亚国家队徽章
	[8234] = 1,    --巴西国家队徽章
	[8235] = 1,    --瑞士国家队徽章
	[8236] = 1,    --哥斯达黎加国家队徽章
	[8237] = 1,    --塞尔维亚国家队徽章
	[8238] = 1,    --德国国家队徽章
	[8239] = 1,    --墨西哥国家队徽章
	[8240] = 1,    --瑞典国家队徽章
	[8241] = 1,    --韩国国家队徽章
	[8242] = 1,    --比利时国家队徽章
	[8243] = 1,    --巴拿马国家队徽章
	[8244] = 1,    --突尼斯国家队徽章
	[8245] = 1,    --英格兰国家队徽章
	[8246] = 1,    --波兰国家队徽章
	[8247] = 1,    --塞内加尔国家队徽章
	[8248] = 1,    --哥伦比亚国家队徽章
	[8249] = 1,    --日本国家队徽章
}

tbAct.nTransferItemNormal = 8392	--转换道具（普通）
tbAct.nTransferItemAdvance = 8393 --转换道具（高级）
tbAct.nTransferExpire = Lib:ParseDateTime("2018-07-17 0:0:0")
tbAct.nTransferTokenExpire = Lib:ParseDateTime("2018-07-11 1:59:59")

tbAct.szMailText = "您在[FFFE0D]2018世界杯徽章收集活动[-]中位列第[FFFE0D]%d[-]名，附件为奖励，请查收！"
tbAct.tbRankAward = {
	{1, {"Item", 2804, 100}, {"Item", 8254, 1}, {"Item", 8274, 1}},
	{5, {"Item", 2804, 60}, {"Item", 8255, 1}, {"Item", 8275, 1}},
	{10, {"Item", 2804, 40}},
	{20, {"Item", 2804, 30}},
	{50, {"Item", 2804, 20}},
	{200, {"Item", 2804, 10}},
	{500, {"Item", 2804, 5}},
}
tbAct.nBaseRewardScoreMin = 999999	--满x价值量获得基础奖励
tbAct.tbBaseReward = {"Item", 7704, 1} --基础奖励

tbAct.tbCollect32Rewards = {	--收集满32支球队的徽章获得的奖励
	{"item", 224, 6},
}

tbAct.tbShowItems = {	--收集册中显示的徽章物品id
	8218, 8219, 8220, 8221, 
	8222, 8223, 8224, 8225, 
	8226, 8227, 8228, 8229, 
	8230, 8231, 8232, 8233, 
	8234, 8235, 8236, 8237, 
	8238, 8239, 8240, 8241, 
	8242, 8243, 8244, 8245, 
	8246, 8247, 8248, 8249
}

tbAct.tbShowItems4 = { --上届4强名单
	8238, 8230, 8234
}
tbAct.tbShowItems8 = {  --上届8强名单
	8238, 8230, 8234, 8226, 8242, 8248, 8236
}

function tbAct:CheckPlayer(pPlayer)
	if pPlayer.nLevel < self.nJoinLevel then
		return false, string.format("请先将等级提升至%d", self.nJoinLevel)
	end
	return true
end

if MODULE_GAMECLIENT then
	function tbAct:GainReward()
		RemoteServer.WorldCupReq("GainReward")
	end

	function tbAct:UpdateData()
		RemoteServer.WorldCupReq("UpdateData")
	end

	function tbAct:OnUpdateData(tbData)
		self.tbData = tbData
		local szUiName = "WorldCupPanel"
		if Ui:WindowVisible(szUiName) ~= 1 then
			return
		end
		Ui(szUiName):Refresh()
	end

	function tbAct:Transfer(bNormal)
		bNormal = not not bNormal

		if not self.nTransFromItemId or self.nTransFromItemId <= 0 then
			return false, "您尚未选择要转换的徽章！"
		end

		if self.nTransFromItemId == self.nTransToItemId then
	        return false, "待转换徽章不得与目标徽章相同！"
	    end

		if not self.tbData then
			self:UpdateData()
			return false
		end
		local nCount = self.tbData.tbItems[self.nTransFromItemId] or 0
		if nCount <= 0 then
			return false, "尚未获得所选徽章"
		end

		if not bNormal then
			if not self.nTransToItemId or self.nTransToItemId <= 0 then
				return false, "您尚未选择转换目标徽章！"
			end
			local nCount = self.tbData.tbItems[self.nTransToItemId] or 0
			if nCount <= 0 then
				return false, "尚未获得所选目标徽章"
			end		
		end

		local szFromName = Item:GetItemTemplateShowInfo(self.nTransFromItemId, me.nFaction, me.nSex)
		local szMsg = bNormal and string.format("确定将[FFFE0D]%s[-]转换成除本徽章之外随机一个国家队徽章吗？转换成功之后将消耗[FFFE0D]普通的徽章转换符[-]！", szFromName) or 
			string.format("确定将[FFFE0D]%s[-]转换成[FFFE0D]%s[-]吗？转换成功后将消耗[FFFE0D]高级的徽章转换符[-]！", szFromName, Item:GetItemTemplateShowInfo(self.nTransToItemId, me.nFaction, me.nSex))
		me.MsgBox(szMsg, {{"确定", function ()
			local szUiName = "WorldCupTransferPanel"
			if Ui:WindowVisible(szUiName) == 1 then
				Ui(szUiName).pPanel:SetActive("texiao", true)
				Ui(szUiName).pPanel:SetActive("BtnTransformation", false)
			end
			Timer:Register(Env.GAME_FPS * 1, function()
				RemoteServer.WorldCupReq("Transfer", bNormal, self.nTransFromItemId, self.nTransToItemId)
				self.nTransFromItemId = nil
				self.nTransToItemId = nil
			end)
		end}, {"取消"}})
		return true
	end

	function tbAct:OnUpdateTransferData()
		local szUiName = "WorldCupTransferPanel"
		if Ui:WindowVisible(szUiName) ~= 1 then
			return
		end
		Ui(szUiName):Refresh()
	end
end