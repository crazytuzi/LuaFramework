Require("CommonScript/Player/PlayerDef.lua")
WaiYiTry.Def = {
	nLiuYunFuId = 9511,	--流云符道具id
	nQingXueFuId = 9510,	--晴雪符道具id

	nLiuYunFuValidTime = 3 * 24 * 3600,	--流云符有效期
	nQingXueFuValidTime = 2 * 24 * 3600,	--晴雪符有效期

	nGuideOpenBag = 48,	--打开背包指引
	nGuideOpenWaiYi = 49,	--打开外装收藏柜指引
	nGuideChangeColor = 50,	--更改外装颜色指引

	szMaxTimeframe = "OpenLevel59",	--最大时间轴
	nMinLevel = 10,	--最小参与等级（含）
	nMaxLevel = 40,	--最大参与等级（含）

	tbWhiteList = {	--体验符对应时装
		tbLiuYunFu = {	--流云符
			9515, 9516, 9517, 9518, 9519, 9520, 9521, 9522, 9523,
		},
		tbQingXueFu = {	--晴雪符
			4493, 9512, 9513, 9514, 9527, 9528, 9529,
		},
	},

	tbTypeNames = {	--WaiYiTry.tab 类型id对应的名字
		[1] = "江湖外装",
		[2] = "门派外装",
		[3] = "商城时装",
		[4] = "稀有时装",
	},
}

function WaiYiTry:LoadSetting()
	local tbSetting = LoadTabFile("Setting/WaiYiTry/WaiYiTry.tab", "ddssss", nil,
		{"nFaction", "nSex", "sz1", "sz2", "sz3", "sz4"})
	self.tbSetting = {}
	for _, tb in ipairs(tbSetting) do
		local tbWaiYi = {}
		for i=1, 4 do
			tbWaiYi[i] = {}
			for _, sz in ipairs(Lib:SplitStr(tb["sz"..i], ";")) do
				table.insert(tbWaiYi[i], tonumber(sz))
			end
		end
		self.tbSetting[tb.nFaction] = self.tbSetting[tb.nFaction] or {}
		if tb.nSex <= 0 then
 			self.tbSetting[tb.nFaction][Player.SEX_MALE] = tbWaiYi
 			self.tbSetting[tb.nFaction][Player.SEX_FEMALE] = tbWaiYi
 		else
 			self.tbSetting[tb.nFaction][tb.nSex] = tbWaiYi
 		end
	end
end
WaiYiTry:LoadSetting()

function WaiYiTry:GetTemplateId(pPlayer, nType, nIdx)
	local tbSetting = self.tbSetting[pPlayer.nFaction]
	if not tbSetting then
		return 0
	end
	tbSetting = tbSetting[pPlayer.nSex]
	if not tbSetting then
		return 0
	end
	tbSetting = tbSetting[nType]
	if not tbSetting then
		return 0
	end
	return tbSetting[nIdx] or 0
end