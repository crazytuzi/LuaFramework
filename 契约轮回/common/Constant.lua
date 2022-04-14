--
-- Author: LaoY
-- Date: 2018-06-28 19:14:33
--

Constant = {}

Constant.Protocal = {
	Connect		= 101,	--连接服务器
	Exception   = 102,	--异常掉线
	Disconnect  = 103,	--正常断线
	Message		= 104,	--接收消息
}

Constant.GlobalControll = {}

Constant.GoldType = {
	Level 		= "level",  	--等级
	Exp 		= "exp",  		--经验
	ExpAdd 		= "expadd",  	--经验
	Gold 		= "gold",  		--元宝
	BGold 		= "bgold", 		--绑元 原来 Diamond
	Coin 		= "coin",  		--金币 原来 Gemstone
	BCoin 		= "bcoin",  	--绑定金币 原来 Gemstone
	Fame		= "fame",		--声望
	Honor		= "honor",		--荣誉
	Feat		= "feat",		--功勋
	Mana		= "Mana",		--威望
	Contrib		= "contrib",	--帮贡
	McExp 		= "mc_exp",  	--魔法星尘
	McExch 		= "mc_exch",  	--魔晶石
	McFuse 		= "mc_fuse",  	--融合魔晶
	McHunt 		= "mc_hunt",  	--魔法塔寻宝 星力
	PetCream	= "pet_cream",  	--宠物精华
	STScore 	= "st_score",  --寻宝积分
	SoulExch    = "soul_exch",  --圣痕合成
	SoulFuse    = "soul_fuse",  --圣痕进阶
	SoulExp		= "soul_exp",	--圣痕经验
	BossScore   = "boss_score",  -- 首领积分
	BabyScore   = "BabyScore",   --子女精华
	CompeteScore = "CompeteScore", --擂台币
	illusEssence = "illEssence", --图鉴精华
	GodScore     = "GodScore",   --神灵精华
	mechaScore   =  "mechaScore",
	PetEquipExp  = "PetEquipExp", --宠物装备经验
	GreenGold    = "GreenGold",  --绿钻
	artScore1    =  "artScore1",   --神器货币1
	artScore2    =  "artScore2",   --神器货币2
	artScore3    =  "artScore3",   --神器货币3
	artScore4    =  "artScore4",   --神器货币4
	artScore5    =  "artScore5",   --神器货币5

}

---获得(Money字段)物品时不进行飘字的列表
Constant.PickUpSkip = {
	[enum.ITEM.ITEM_LEVEL] = true,
	[enum.ITEM.ITEM_EXP] = true,
	[enum.ITEM.ITEM_EXPADD] = true,
	[enum.ITEM.ITEM_EXPCOEF] = true,
}

Constant.GoldIDMap = {
	[enum.ITEM.ITEM_LEVEL]   = Constant.GoldType.Level,
	[enum.ITEM.ITEM_EXP]     = Constant.GoldType.Exp,
	[enum.ITEM.ITEM_EXPADD]  = Constant.GoldType.ExpAdd,
	[enum.ITEM.ITEM_GOLD]    = Constant.GoldType.Gold,
	[enum.ITEM.ITEM_BGOLD]   = Constant.GoldType.BGold,
	[enum.ITEM.ITEM_COIN]    = Constant.GoldType.Coin,
	[enum.ITEM.ITEM_BCOIN]   = Constant.GoldType.BCoin,
	[enum.ITEM.ITEM_FAME]    = Constant.GoldType.Fame,
	[enum.ITEM.ITEM_HONOR]   = Constant.GoldType.Honor,
	[enum.ITEM.ITEM_FEAT]    = Constant.GoldType.Feat,
	[enum.ITEM.ITEM_MANA]    = Constant.GoldType.Mana,
	[enum.ITEM.ITEM_CONTRIB] = Constant.GoldType.Contrib,
	[enum.ITEM.ITEM_MC_EXP]  = Constant.GoldType.McExp,
	[enum.ITEM.ITEM_MC_EXCH] = Constant.GoldType.McExch,
	[enum.ITEM.ITEM_MC_HUNT] = Constant.GoldType.McHunt,
	[enum.ITEM.ITEM_PET_CREAM] = Constant.GoldType.PetCream,
	[enum.ITEM.ITEM_INTEGRAL] = Constant.GoldType.STScore,
	[enum.ITEM.ITEM_SOUL_EXP] = Constant.GoldType.SoulExp,
	[enum.ITEM.ITEM_SOUL_EXCH] = Constant.GoldType.SoulExch,
	[enum.ITEM.ITEM_SOUL_FUSE] = Constant.GoldType.SoulFuse,
	[enum.ITEM.ITEM_BOSSFEN] = Constant.GoldType.BossScore,
	[enum.ITEM.ITEM_BABY] = Constant.GoldType.BabyScore,
	[enum.ITEM.ITEM_ARENA_MONEY] = Constant.GoldType.CompeteScore,
	[enum.ITEM.ITEM_ILLUS_ESSENCE] = Constant.GoldType.illusEssence,
	[enum.ITEM.ITEM_GOD_MONEY] = Constant.GoldType.GodScore,
	[enum.ITEM.ITEM_MECHA_MONEY] = Constant.GoldType.mechaScore,
	[enum.ITEM.ITEM_PETEQUIP_EXP] = Constant.GoldType.PetEquipExp,
	[enum.ITEM.ITEM_GREEN_DRILL] = Constant.GoldType.GreenGold,
	[enum.ITEM.ITEM_ELEMENT_1] = Constant.GoldType.artScore1,
	[enum.ITEM.ITEM_ELEMENT_2] = Constant.GoldType.artScore2,
	[enum.ITEM.ITEM_ELEMENT_3] = Constant.GoldType.artScore3,
	[enum.ITEM.ITEM_ELEMENT_4] = Constant.GoldType.artScore4,
	[enum.ITEM.ITEM_ELEMENT_5] = Constant.GoldType.artScore5,
}

Constant.GoldTypeMap = {}

for id, key in pairs(Constant.GoldIDMap) do
	Constant.GoldTypeMap[key] = id
end


Constant.GoldName = {}

for id, key in pairs(Constant.GoldIDMap) do
	if enumName.ITEM[id] then
		Constant.GoldName[key] = enumName.ITEM[id]
	end
end




-- 游戏开始后，延迟请求数据等级
-- 登录成功后开始算起
Constant.GameStartReqLevel = {
	Best 		= 0.1,	--最高级，游戏开始就请求数据
	Super       = 1.0,	--超高级
	High 		= 1.5,	--高
	Ordinary 	= 2.0,	--一般
	Low 		= 2.5,	--低
	VLow 		= 5.0,	--超级低
}

Constant.LoadResLevel = {
	Urgent 	= 1,		--紧急资源 只有切换场景才能用
	Best 	= 2,
	Super 	= 3,
	High 	= 4,
	Low 	= 5,
	Down 	= 6,
}

-- 
-- Constant.BMFontKey = {

-- }

Constant.DeviceLevel = {
	Best 	= 1,
	High 	= 2,
	Low 	= 3,
}

-- 用于重新加载lua文件
Constant.ReLoadLuaList = {}
-- package.loaded[xx] = nil

-- （非常驻对象）在对象缓存池的时间
Constant.InPoolTime = 25

-- 缓存角色相关对象 99接近无限大
Constant.CacheRoleObject = 2

Constant.TITLE_IMG_PATH = "iconasset/icon_title";

-- 进入省电模式的时间
Constant.EnterLowPowerTime = 100

-- 是否首次登陆
Constant.IsFirstLanding = nil
Constant.EarliestLandingTime = false
Constant.EarliestLandingTimeCacheKey = "EarliestLandingTimeCacheKey"


-- rendertexture 设置
Constant.RT = {
	RtWidth = 1024,
	RtHeight = 1024,
	RtDepth = 24,
}

Constant.AllEffectCount = 10