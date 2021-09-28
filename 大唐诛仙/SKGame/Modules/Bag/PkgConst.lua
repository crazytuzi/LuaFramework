-- 背包常量
PkgConst = {}

-- 面板类型
PkgConst.PanelType = {
	bag = 0,
	medicine = 1,
	composition = 2,
	decomposition = 3,
	refined = 4,
}

-- 背包标签类型
PkgConst.BagTabType = {
	all = "0",
	equip = "1",
	xiaohao = "2",
	other = "3",
}

-- 事件
PkgConst.GridChange = "0"
PkgConst.BagChange = "1"
PkgConst.EquipChange = "2"

-- 药品
PkgConst.medicineDescList = {
	"放置的药剂按顺序依次出现在主界面药剂栏内，使用冷却时间 6s.", -- hp
	"放置的药剂按顺序依次出现在主界面药剂栏内，使用冷却时间 6s." -- mp
}
PkgConst.titleList = {
	"药剂栏（生命）",
	"药剂栏（法力）"
}
PkgConst.medicineTypeBidList = {
	[1] ={21100, 21101, 21102, 21103, 21104}, -- hp
	[2] ={21200, 21201, 21202, 21203, 21204} -- mp
}

PkgConst.ItemEffectType = {
	AddHP = 1, --加HP
	AddMP = 2, --加MP
	AddCoin = 3, --加金币
	AddVcoin = 4, --加元宝
	AddGem = 5, --加宝玉
	AddContribution = 6 , --加贡献度
	AddHonor = 7, --加荣誉
	AddExp = 8 , --加经验
	AddWakan = 9 ,--加灵力
	ReducePkValue = 10 , --减少PK值
	GiftBag = 11 , --礼包
	AddFeather = 12 , --加羽灵
	AddSkillMastery = 13, --加技能熟练度
	HuntingMonsterToken = 14, --猎妖令
	CopyKey = 15, --副本钥匙
	BagExtendCard = 16 , --背包扩容券
	AddBuff = 17 , --加Buff
	TombTreasureCard = 18 , --陵墓探宝令
	DrawCard = 19  --抽奖卡
}

PkgConst.BagExtendCardGoodsId = 3014