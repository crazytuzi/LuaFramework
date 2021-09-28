
--新功能开启枚举
NF_RIDE = 1 --坐骑
NF_WING = 2 --光翼
NF_BATTLE = 3 --竞技场
NF_LOTTERY = 4 --寻宝
NF_RING = 5 --神戒
NF_FB_SINGLE = 6--单人副本
NF_FB_PROTECT = 7--守护副本
NF_FACTION = 8 -- 帮会
NF_FRIEND = 9 --好友
NF_FB_TOWER = 10 --爬塔副本
NF_TASK_DAILY = 11 --日常任务
NF_ACTIVE = 12 --活跃度
NF_TEAM = 13 --组队
NF_FURNACE = 14 --熔炉
NF_BEAUTY = 15 --美人-
NF_7DAY = 16 --七天登陆-
NF_MYSTERY = 17 --神秘商店
NF_STOREHOUSE = 18--仓库
NF_FB_SINGLE_2 = 19--战神试炼
NF_SIGN_IN = 20--每日签到
NF_SOUL = 21--离线挖矿
NF_ARM = 22--美人战甲
NF_WEAPON = 23--美人战刃
NF_GOD = 25--神装
NF_EMPIRE = 26--霸业
NF_BABY = 27--元婴
NF_BABY_QUALITY = 28--元婴品质
NF_MINE = 29--在线挖矿
NF_AUCTION = 30--拍卖行
NF_WASH = 33--洗练
NF_BLESS = 34--祝福
NF_STRENGTHEN = 35--强化
NF_GOLD = 36--点金
NF_LOST = 37--迷仙阵

--功能状态枚举
NF_OFF	= 1
NF_NOTICE	= 2
NF_FINISH	= 3

--功能开启类型枚举
NF_NO_RELATIVE	= 0
NF_RELATIVE	= 1

--功能与图标的对应关系
iconTab = 
{
	[NF_RIDE] = "1.png", --坐骑
	[NF_WING] = "2.png", --光翼
	[NF_BATTLE] = "3.png", --竞技场
	[NF_LOTTERY] = "4.png", --寻宝
	[NF_RING] = "5.png", --神戒
	[NF_FB_SINGLE] = "6.png",--单人副本
	[NF_FB_PROTECT] = "7.png",--守护副本
	[NF_FACTION] = "8.png", -- 帮会
	[NF_FRIEND] = "9.png", --好友
	[NF_FB_TOWER] = "10.png", --爬塔副本
	[NF_TASK_DAILY] = "11.png", --日常任务
	[NF_ACTIVE] = "12.png", --活跃度
	[NF_TEAM] = "13.png", --组队
	[NF_FURNACE] = "14.png", --熔炉
	[NF_BEAUTY] = "15.png", --美人
	[NF_7DAY] = "16.png", --七天登陆
	[NF_MYSTERY] = "17.png", --神秘商店
	[NF_STOREHOUSE] = "18.png",--仓库
	[NF_FB_SINGLE_2] = "19.png",--战神试炼
	[NF_SIGN_IN] = "20.png",--每日签到
	[NF_SOUL] = "21.png",--元神挂机
	[NF_ARM] = "22.png",--美人战甲
	[NF_WEAPON] = "23.png",--美人战刃
	[NF_GOD] = "25.png",--美人战甲
	[NF_EMPIRE] = "26.png",--美人战刃
	[NF_BABY] = "27.png",--元婴
	[NF_BABY_QUALITY] = "28.png",--元婴品质
	[NF_MINE] = "29.png",--元婴品质
	[NF_AUCTION] = "30.png",--拍卖行
	[NF_WASH] = "33.png",--洗练
	[NF_BLESS] = "34.png",--祝福
	[NF_STRENGTHEN] = "35.png",--强化
	[NF_GOLD] = "36.png",--点金
	[NF_LOST] = "37.png",--迷仙阵
}

iconBottom = 
{
	{tag=NF_BABY, onRes="res/mainui/54.png", offRes="res/mainui/54-1.png"},
	{tag=NF_FRIEND, onRes="res/mainui/58.png", offRes="res/mainui/58-1.png"},
	{tag=NF_FACTION, onRes="res/mainui/59.png", offRes="res/mainui/59-1.png"},
}

iconOnPath = "res/newFunction/icon/on/"
iconOffPath = "res/newFunction/icon/off/"
titleOnPath = "res/newFunction/title/on/"
titleOffPath = "res/newFunction/title/off/"