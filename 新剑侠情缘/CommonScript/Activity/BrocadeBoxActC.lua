if not MODULE_GAMESERVER then
	Activity.BrocadeBoxAct = Activity.BrocadeBoxAct or {}
end

local tbAct = MODULE_GAMESERVER and Activity:GetClass("BrocadeBoxAct") or Activity.BrocadeBoxAct

tbAct.USERGROUP_CATCHBOX = 188
tbAct.USERKEY_CATCHTIME = 1
tbAct.USERKEY_CATCHCOUNT = 2

--锦盒品质等级
tbAct.tbQuality = {
	LOW = 1,
	MID = 2,
	HIGH = 3,
}
--=============以下策划配置================--

--不同道具对应的不同Npc模板ID(这里是不同品质的锦盒的Id)
tbAct.tbItem2Npc = {
	--[nItemTId] = nNpcTemplateId
	[10289] = 3425,		
	[10290] = 3426,
	[10291] = 3427,
}

--Npc对应的品质等级
tbAct.tbNpc2Quality = {
	--[nNpcTID] = nQualityLevel
	[3425] = tbAct.tbQuality.LOW,
	[3426] = tbAct.tbQuality.MID,
	[3427] = tbAct.tbQuality.HIGH,
}

--道具对应的品质等级（这里是不同品质的锦盒的Id)
tbAct.tbItem2Quality = {
	--[nItemTId] = nQualityLevel
	[10289]	= tbAct.tbQuality.LOW,
	[10290] = tbAct.tbQuality.MID,
	[10291] = tbAct.tbQuality.HIGH,
}

--不同品质等级对应的常规奖励(猜对猜错都有)
tbAct.tbNormalAward = {
	[tbAct.tbQuality.LOW] = {
	  --{szType, nId, nCount}
		{"item", 10293, 1},
	},
	[tbAct.tbQuality.MID] = {
		{"item", 10294, 1},
	},
	[tbAct.tbQuality.HIGH] = {
		{"item", 10295, 1},
	},
}

--不同品质等级对应的额外奖励(猜对才有)
tbAct.tbExtraAward = {
	[tbAct.tbQuality.LOW] = {
	  --{szType, nId, nCount}
		{"item", 10296, 1},
	},
	[tbAct.tbQuality.MID] = {
		{"item", 10313, 1},
	},
	[tbAct.tbQuality.HIGH] = {
		{"item", 10314, 1},
	},
}

--不同品质等级对应的名称(世界公告时展示用)
tbAct.tbQuality2Name = {
	[tbAct.tbQuality.LOW] = "普通的新年锦盒",
	[tbAct.tbQuality.MID] = "精致的新年锦盒",
	[tbAct.tbQuality.HIGH] = "华美的新年锦盒", 
}

--最小参与等级
tbAct.MIN_LEVEL = 50

--与锦盒相同大小的家具模板ID，用来作摆放检测
tbAct.NPC_FURNITURE_ID = 10026

--锦盒存在的时长
tbAct.NPC_VAlID_TIME = 3 * 24 * 60 * 60

--家园中同时存在的锦盒的最大数量
tbAct.MAX_NPC_TOTAL = 10

--每天的收取上限
tbAct.CATCH_LIMIT_ONEDAY = 3

--每日限制的刷新时间
tbAct.REFRESH_TIME = 4 * 60 * 60	--随便填了每天4点

--寄语的长度限制
tbAct.MAX_JIYU_LEN = 15

--寄语模板
tbAct.tbJiYuTemplate = {
	"攀折赠君还有意，翠眉轻嫩怕春风",
	"美人赠我锦绣段，何以报之青玉案",
	"赠君珍物情几许，却怕斜阳深院里",
	"何以折相赠，白花青桂枝",
	"因君怀胆气，赠尔定交情",
	"江南无所有，聊赠一枝春",
	"持为美人赠，勖此故交心",
	"两情顾盼合，珠碧赠于斯",
	"投我以木瓜，报之以琼琚"
}

--活跃度对应的宝箱(这里应该配随机宝箱，暂时先直接配锦盒做测试)
tbAct.tbEverydayTargetAward = {
	[4] = 10297,	--80活跃度
	[5] = 10297,	--100活跃度
}

--1,3,6礼包对应的宝箱(配随机宝箱)
tbAct.tbDailyGiftAward = {
	[Recharge.DAILY_GIFT_TYPE.YUAN_6] = 10297,
}

--重新随机获得锦盒的概率
tbAct.tbRerandomRate = {
	[tbAct.tbQuality.LOW] = 50,
	[tbAct.tbQuality.MID] = 30,
	[tbAct.tbQuality.HIGH] = 20,
}

--重新随机锦盒的道具的Id(就叫它随机券吧)
tbAct.RERANDOM_ITEM_TID = 10292
--元宝养护时获得随机券的概率
tbAct.HELPCURE_AWARD_RATE = 0.2
--感叹号通知的过期时间(秒)
tbAct.NOTIFY_TIMEOUT = 300
--延迟通知的时间(秒)
tbAct.DELAY_TIME = 300
--收取时，错误答案来源于亲密度前X名
tbAct.INTIMACY_TOP = 50

--玩家好友数量不够的时候，用来填充选项的假名字
tbAct.tbFakePlayerName = {
	[-1] = "独孤剑",
	[-2] = "南宫飞云",
	[-3] = "杨影枫",
	[-4] = "鬼谷子",
	[-5] = "唐简",
}

--猜对后双方增加的亲密度
tbAct.ADD_INTIMACY = 50

--===========以上策划配置===========--


--根据玩家位置计算出摆放锦盒的坐标
function tbAct:CalcBoxPos(pPlayer)
	local nMapId, nX, nY = pPlayer.GetWorldPos()
	local nDir = pPlayer.GetNpc().GetDir()
	nX = nX + math.floor(g_DirCos(nDir) / 1024 * 200)
	nY = nY + math.floor(g_DirSin(nDir) / 1024 * 200)

	return nMapId, nX, nY
end

--随机模板寄语
function tbAct:RandomTemplateJiYu()
	local nTemplateNum = #self.tbJiYuTemplate
	local nRandomIdx = MathRandom(1, nTemplateNum)
	if self.nJiYu then
		while self.nJiYu == nRandomIdx do
			nRandomIdx = MathRandom(1, nTemplateNum)
		end
	end
	self.nJiYu = nRandomIdx
	return self.tbJiYuTemplate[nRandomIdx]
end


function tbAct:GetItemTIdByQuality(nQuality)
	for nItemTId, nQualityLevel in pairs(self.tbItem2Quality) do
		if nQuality == nQualityLevel then
			return nItemTId
		end
	end
end

