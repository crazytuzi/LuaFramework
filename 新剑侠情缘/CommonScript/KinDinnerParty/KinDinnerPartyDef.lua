KinDinnerParty.Def = {
	tbTaskMailAttaches = {	--每周布置任务邮件附件
		{"Coin", 1000},
	},

	nNpcFurnitureId = 10026,	-- 餐桌同等大小家具，检测是否可以摆放餐桌用

	nMinTaskLevel = 50,	--领取任务最小等级（含）

	nTaskCount = 9,	--任务条数
	HELP_IMITITY = 30; --帮忙装货增加亲密度
	tbWildMap = {10, 1000, 1405, 403, 409};	--采集地图id
	szIconAtlas = "UI/Atlas/Item/Item/Item16.prefab",	--任务界面物品图片atlas

	nMaxWeeklyCount = 2,	--家族每周最多聚餐次数
	nMaxPlayerJoinCount = 2,	--玩家每周最多参与次数

	nPartyTokenId = 9478,	--聚餐令牌道具id
	nTableNpcId = 3204,	--餐桌npc
	nTokenExpireTime = 7 * 24 * 3600,	--聚餐令牌有效期（秒）

	nAddExpInterval = 15,	--多少秒加一次经验
	nAddExpBase = 1.25,	--每次加多少倍的基础经验
	nBuffId = 4906,	--buff id

	tbEatRewards = {	--吃菜奖励
		{{"item", 9494, 1}},
		{{"item", 9494, 1}},
		{{"item", 9494, 1}},
		{{"item", 9494, 1}},
	},

	tbTimers = {	--定时器，可执行的指令：start, food(上菜), stopwarning, guess(新一轮猜成语), stop
		{2* 60, {"start", "food", "guess"}},
		{4* 60, {"food", "guess"}},
		{6* 60, {"food", "guess"}},
		{8* 60, {"food", "guess", "stopwarning"}},
		{10 * 60, {"stop"}},
	},

	nMaxGuessLen = 4,	--输入成语最大长度


	--
	-- 以下由程序配置
	--
	nSaveGroup = 172,
	nKeyWeekJoinTime = 1,
	nKeyJoinCount = 2,
}

if version_vn then
	KinDinnerParty.Def.nMaxGuessLen = 30
end

function KinDinnerParty:LoadIdioms()
	local tbSetting = LoadTabFile("Setting/KinDinnerParty/Idiom.tab", "s", nil, {"szIdiom"})

	self.Def.tbIdioms = {}
	for _, v in ipairs(tbSetting) do
		table.insert(self.Def.tbIdioms, v.szIdiom)
	end
end
KinDinnerParty:LoadIdioms()

if not version_tx and not version_hk and not version_xm and not version_vn then
	KinDinnerParty.bForceClose = true
end