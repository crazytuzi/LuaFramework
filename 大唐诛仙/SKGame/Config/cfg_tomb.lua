--[[
	id:int#编号
	name:string#名字
	itemId:int#物品id
	group:int#档次
一个奖励池9个物品，每一个分组各取一个配置进入奖励池
	count:int#数量
	rate:int#概率（万分比）
	notice:int#抽中是否广播
]]

local cfg={
	[1]={
		id=1,
		name="初级摸金令",
		itemId=36101,
		group=1,
		count=1,
		rate=10000,
		notice=0,
	},
	[2]={
		id=2,
		name="小金币袋",
		itemId=20011,
		group=1,
		count=1,
		rate=10000,
		notice=0,
	},
	[3]={
		id=3,
		name="小元宝袋",
		itemId=20031,
		group=1,
		count=1,
		rate=5000,
		notice=0,
	},
	[4]={
		id=4,
		name="双倍经验药水(小)",
		itemId=25004,
		group=1,
		count=1,
		rate=10000,
		notice=0,
	},
	[5]={
		id=5,
		name="初级技能书",
		itemId=33001,
		group=1,
		count=1,
		rate=10000,
		notice=0,
	},
	[6]={
		id=6,
		name="低级猎妖令",
		itemId=33011,
		group=1,
		count=1,
		rate=10000,
		notice=0,
	},
	[7]={
		id=7,
		name="下品灵石",
		itemId=35009,
		group=1,
		count=2,
		rate=10000,
		notice=0,
	},
	[8]={
		id=8,
		name="初级神羽",
		itemId=35013,
		group=1,
		count=2,
		rate=10000,
		notice=0,
	},
	[9]={
		id=9,
		name="流光印记Ⅰ",
		itemId=40001,
		group=1,
		count=1,
		rate=10000,
		notice=0,
	},
	[10]={
		id=10,
		name="炎之印记Ⅰ",
		itemId=41001,
		group=1,
		count=1,
		rate=10000,
		notice=0,
	},
	[11]={
		id=11,
		name="冰之印记Ⅰ",
		itemId=42001,
		group=1,
		count=1,
		rate=10000,
		notice=0,
	},
	[12]={
		id=12,
		name="暗之印记Ⅰ",
		itemId=43001,
		group=1,
		count=1,
		rate=10000,
		notice=0,
	},
	[13]={
		id=13,
		name="初级摸金令",
		itemId=36101,
		group=2,
		count=2,
		rate=5000,
		notice=0,
	},
	[14]={
		id=14,
		name="广播喇叭",
		itemId=20000,
		group=2,
		count=1,
		rate=5000,
		notice=0,
	},
	[15]={
		id=15,
		name="经验丹·中",
		itemId=20002,
		group=2,
		count=2,
		rate=5000,
		notice=0,
	},
	[16]={
		id=16,
		name="还魂丹",
		itemId=23001,
		group=2,
		count=1,
		rate=5000,
		notice=0,
	},
	[17]={
		id=17,
		name="三倍经验药水(小)",
		itemId=25001,
		group=2,
		count=1,
		rate=3334,
		notice=0,
	},
	[18]={
		id=18,
		name="中级猎妖令",
		itemId=33012,
		group=2,
		count=1,
		rate=3334,
		notice=0,
	},
	[19]={
		id=19,
		name="追魂香",
		itemId=34001,
		group=2,
		count=1,
		rate=5000,
		notice=0,
	},
	[20]={
		id=20,
		name="洗红水",
		itemId=34009,
		group=2,
		count=1,
		rate=5000,
		notice=0,
	},
	[21]={
		id=21,
		name="千界叶",
		itemId=36100,
		group=2,
		count=1,
		rate=5000,
		notice=0,
	},
	[22]={
		id=22,
		name="转盘抽奖券",
		itemId=36104,
		group=2,
		count=1,
		rate=5000,
		notice=0,
	},
	[23]={
		id=23,
		name="双倍经验药水(中)",
		itemId=25005,
		group=2,
		count=1,
		rate=3334,
		notice=0,
	},
	[24]={
		id=24,
		name="初级摸金令",
		itemId=36101,
		group=3,
		count=4,
		rate=2500,
		notice=0,
	},
	[25]={
		id=25,
		name="双倍经验药水(大)",
		itemId=25006,
		group=3,
		count=1,
		rate=2000,
		notice=0,
	},
	[26]={
		id=26,
		name="中级技能书",
		itemId=33002,
		group=3,
		count=1,
		rate=2000,
		notice=0,
	},
	[27]={
		id=27,
		name="中品灵石",
		itemId=35010,
		group=3,
		count=2,
		rate=2000,
		notice=0,
	},
	[28]={
		id=28,
		name="中级神羽",
		itemId=35014,
		group=3,
		count=2,
		rate=2000,
		notice=0,
	},
	[29]={
		id=29,
		name="三倍经验药水(中)",
		itemId=25002,
		group=4,
		count=1,
		rate=1000,
		notice=0,
	},
	[30]={
		id=30,
		name="中级摸金令",
		itemId=36102,
		group=4,
		count=1,
		rate=1250,
		notice=0,
	},
	[31]={
		id=31,
		name="高级猎妖令",
		itemId=33013,
		group=4,
		count=1,
		rate=1112,
		notice=0,
	},
	[32]={
		id=32,
		name="中金币袋",
		itemId=20012,
		group=4,
		count=1,
		rate=2000,
		notice=0,
	},
	[33]={
		id=33,
		name="中元宝袋",
		itemId=20031,
		group=4,
		count=2,
		rate=2500,
		notice=0,
	},
	[34]={
		id=34,
		name="流光印记Ⅱ",
		itemId=40002,
		group=4,
		count=1,
		rate=1000,
		notice=0,
	},
	[35]={
		id=35,
		name="炎之印记Ⅱ",
		itemId=41002,
		group=4,
		count=1,
		rate=1000,
		notice=0,
	},
	[36]={
		id=36,
		name="冰之印记Ⅱ",
		itemId=42002,
		group=4,
		count=1,
		rate=1000,
		notice=0,
	},
	[37]={
		id=37,
		name="暗之印记Ⅱ",
		itemId=43002,
		group=4,
		count=1,
		rate=1000,
		notice=0,
	},
	[38]={
		id=38,
		name="中级摸金令",
		itemId=36102,
		group=5,
		count=2,
		rate=626,
		notice=0,
	},
	[39]={
		id=39,
		name="三倍经验药水(大)",
		itemId=25003,
		group=5,
		count=1,
		rate=500,
		notice=0,
	},
	[40]={
		id=40,
		name="经验丹·大",
		itemId=20003,
		group=5,
		count=3,
		rate=666,
		notice=0,
	},
	[41]={
		id=41,
		name="经验丹·大",
		itemId=20003,
		group=5,
		count=3,
		rate=666,
		notice=0,
	},
	[42]={
		id=42,
		name="映秋",
		itemId=61101,
		group=5,
		count=1,
		rate=556,
		notice=0,
	},
	[43]={
		id=43,
		name="风晚",
		itemId=61102,
		group=5,
		count=1,
		rate=556,
		notice=0,
	},
	[44]={
		id=44,
		name="背包扩充券",
		itemId=35019,
		group=5,
		count=1,
		rate=500,
		notice=0,
	},
	[45]={
		id=45,
		name="低级攻击药水",
		itemId=25011,
		group=5,
		count=2,
		rate=500,
		notice=0,
	},
	[46]={
		id=46,
		name="高级技能书",
		itemId=33003,
		group=5,
		count=1,
		rate=400,
		notice=0,
	},
	[47]={
		id=47,
		name="上品灵石",
		itemId=35011,
		group=5,
		count=1,
		rate=800,
		notice=0,
	},
	[48]={
		id=48,
		name="高级神羽",
		itemId=35015,
		group=5,
		count=1,
		rate=800,
		notice=0,
	},
	[49]={
		id=49,
		name="中级摸金令",
		itemId=36102,
		group=6,
		count=4,
		rate=312,
		notice=0,
	},
	[50]={
		id=50,
		name="中金币袋",
		itemId=20012,
		group=6,
		count=4,
		rate=500,
		notice=0,
	},
	[51]={
		id=51,
		name="中金币袋",
		itemId=20012,
		group=6,
		count=4,
		rate=500,
		notice=0,
	},
	[52]={
		id=52,
		name="中元宝袋",
		itemId=20032,
		group=6,
		count=2,
		rate=250,
		notice=0,
	},
	[53]={
		id=53,
		name="流光印记Ⅱ",
		itemId=40002,
		group=6,
		count=5,
		rate=200,
		notice=0,
	},
	[54]={
		id=54,
		name="流光印记Ⅱ",
		itemId=40002,
		group=6,
		count=5,
		rate=200,
		notice=0,
	},
	[55]={
		id=55,
		name="炎之印记Ⅱ",
		itemId=41002,
		group=6,
		count=5,
		rate=200,
		notice=0,
	},
	[56]={
		id=56,
		name="炎之印记Ⅱ",
		itemId=41002,
		group=6,
		count=5,
		rate=200,
		notice=0,
	},
	[57]={
		id=57,
		name="冰之印记Ⅱ",
		itemId=42002,
		group=6,
		count=5,
		rate=200,
		notice=0,
	},
	[58]={
		id=58,
		name="冰之印记Ⅱ",
		itemId=42002,
		group=6,
		count=5,
		rate=200,
		notice=0,
	},
	[59]={
		id=59,
		name="暗之印记Ⅱ",
		itemId=43002,
		group=6,
		count=5,
		rate=200,
		notice=0,
	},
	[60]={
		id=60,
		name="暗之印记Ⅱ",
		itemId=43002,
		group=6,
		count=5,
		rate=200,
		notice=0,
	},
	[61]={
		id=61,
		name="高级攻击药水",
		itemId=25013,
		group=6,
		count=1,
		rate=200,
		notice=0,
	},
	[62]={
		id=62,
		name="高级防御药水",
		itemId=25023,
		group=6,
		count=1,
		rate=200,
		notice=0,
	},
	[63]={
		id=63,
		name="裁影",
		itemId=61201,
		group=7,
		count=1,
		rate=148,
		notice=1,
	},
	[64]={
		id=64,
		name="日蚀",
		itemId=61202,
		group=7,
		count=1,
		rate=148,
		notice=1,
	},
	[65]={
		id=65,
		name="星晦",
		itemId=61203,
		group=7,
		count=1,
		rate=148,
		notice=1,
	},
	[66]={
		id=66,
		name="高级摸金令",
		itemId=36103,
		group=7,
		count=1,
		rate=156,
		notice=1,
	},
	[67]={
		id=67,
		name="高级技能书",
		itemId=33003,
		group=7,
		count=2,
		rate=200,
		notice=1,
	},
	[68]={
		id=68,
		name="上品灵石",
		itemId=35011,
		group=7,
		count=5,
		rate=160,
		notice=1,
	},
	[69]={
		id=69,
		name="大金币袋",
		itemId=20013,
		group=7,
		count=2,
		rate=200,
		notice=1,
	},
	[70]={
		id=70,
		name="流光印记Ⅲ",
		itemId=40003,
		group=7,
		count=1,
		rate=100,
		notice=1,
	},
	[71]={
		id=71,
		name="炎之印记Ⅲ",
		itemId=41003,
		group=7,
		count=1,
		rate=100,
		notice=1,
	},
	[72]={
		id=72,
		name="冰之印记Ⅲ",
		itemId=42003,
		group=7,
		count=1,
		rate=100,
		notice=1,
	},
	[73]={
		id=73,
		name="暗之印记Ⅲ",
		itemId=43003,
		group=7,
		count=1,
		rate=100,
		notice=1,
	},
	[74]={
		id=74,
		name="极品灵石",
		itemId=35012,
		group=7,
		count=1,
		rate=160,
		notice=1,
	},
	[75]={
		id=75,
		name="超级技能书",
		itemId=33004,
		group=8,
		count=1,
		rate=80,
		notice=1,
	},
	[76]={
		id=76,
		name="高级摸金令",
		itemId=36103,
		group=8,
		count=2,
		rate=78,
		notice=1,
	},
	[77]={
		id=77,
		name="经验丹·极",
		itemId=20004,
		group=8,
		count=5,
		rate=80,
		notice=1,
	},
	[78]={
		id=78,
		name="经验丹·极",
		itemId=20004,
		group=8,
		count=5,
		rate=80,
		notice=1,
	},
	[79]={
		id=79,
		name="大金币袋",
		itemId=20013,
		group=8,
		count=4,
		rate=100,
		notice=1,
	},
	[80]={
		id=80,
		name="中元宝袋",
		itemId=20032,
		group=8,
		count=5,
		rate=100,
		notice=1,
	},
	[81]={
		id=81,
		name="大金币袋",
		itemId=20013,
		group=8,
		count=4,
		rate=100,
		notice=1,
	},
	[82]={
		id=82,
		name="燃灵",
		itemId=61401,
		group=9,
		count=1,
		rate=20,
		notice=1,
	},
	[83]={
		id=83,
		name="月华",
		itemId=61402,
		group=9,
		count=1,
		rate=20,
		notice=1,
	},
	[84]={
		id=84,
		name="裂空",
		itemId=61403,
		group=9,
		count=1,
		rate=20,
		notice=1,
	},
	[85]={
		id=85,
		name="高级摸金令",
		itemId=36103,
		group=9,
		count=4,
		rate=40,
		notice=1,
	},
	[86]={
		id=86,
		name="超级技能书",
		itemId=33004,
		group=9,
		count=2,
		rate=40,
		notice=1,
	},
	[87]={
		id=87,
		name="超级技能书",
		itemId=33004,
		group=9,
		count=2,
		rate=40,
		notice=1,
	},
	[88]={
		id=88,
		name="极品灵石",
		itemId=35012,
		group=9,
		count=4,
		rate=40,
		notice=1,
	},
	[89]={
		id=89,
		name="极品灵石",
		itemId=35012,
		group=9,
		count=4,
		rate=40,
		notice=1,
	},
	[90]={
		id=90,
		name="大金币袋",
		itemId=20013,
		group=9,
		count=8,
		rate=50,
		notice=1,
	},
	[91]={
		id=91,
		name="大金币袋",
		itemId=20013,
		group=9,
		count=8,
		rate=50,
		notice=1,
	},
	[92]={
		id=92,
		name="经验丹·极",
		itemId=20004,
		group=9,
		count=10,
		rate=40,
		notice=1,
	},
	[93]={
		id=93,
		name="经验丹·极",
		itemId=20004,
		group=9,
		count=10,
		rate=40,
		notice=1,
	},
	[94]={
		id=94,
		name="超级技能书",
		itemId=33004,
		group=9,
		count=2,
		rate=40,
		notice=1,
	},
	[95]={
		id=95,
		name="超级技能书",
		itemId=33004,
		group=9,
		count=2,
		rate=40,
		notice=1,
	},
	[96]={
		id=96,
		name="极品灵石",
		itemId=35012,
		group=9,
		count=4,
		rate=40,
		notice=1,
	},
	[97]={
		id=97,
		name="极品灵石",
		itemId=35012,
		group=9,
		count=4,
		rate=40,
		notice=1,
	},
	[98]={
		id=98,
		name="大金币袋",
		itemId=20013,
		group=9,
		count=8,
		rate=50,
		notice=1,
	},
	[99]={
		id=99,
		name="大金币袋",
		itemId=20013,
		group=9,
		count=8,
		rate=50,
		notice=1,
	},
	[100]={
		id=100,
		name="经验丹·极",
		itemId=20004,
		group=9,
		count=10,
		rate=40,
		notice=1,
	},
	[101]={
		id=101,
		name="经验丹·极",
		itemId=20004,
		group=9,
		count=10,
		rate=40,
		notice=1,
	},
	[102]={
		id=102,
		name="超级技能书",
		itemId=33004,
		group=9,
		count=2,
		rate=40,
		notice=1,
	},
	[103]={
		id=103,
		name="超级技能书",
		itemId=33004,
		group=9,
		count=2,
		rate=40,
		notice=1,
	},
	[104]={
		id=104,
		name="极品灵石",
		itemId=35012,
		group=9,
		count=4,
		rate=40,
		notice=1,
	},
	[105]={
		id=105,
		name="极品灵石",
		itemId=35012,
		group=9,
		count=4,
		rate=40,
		notice=1,
	},
	[106]={
		id=106,
		name="大金币袋",
		itemId=20013,
		group=9,
		count=8,
		rate=50,
		notice=1,
	},
	[107]={
		id=107,
		name="大金币袋",
		itemId=20013,
		group=9,
		count=8,
		rate=50,
		notice=1,
	},
	[108]={
		id=108,
		name="经验丹·极",
		itemId=20004,
		group=9,
		count=10,
		rate=40,
		notice=1,
	},
	[109]={
		id=109,
		name="经验丹·极",
		itemId=20004,
		group=9,
		count=10,
		rate=40,
		notice=1,
	},
	[110]={
		id=110,
		name="超级技能书",
		itemId=33004,
		group=9,
		count=2,
		rate=40,
		notice=1,
	},
	[111]={
		id=111,
		name="超级技能书",
		itemId=33004,
		group=9,
		count=2,
		rate=40,
		notice=1,
	},
	[112]={
		id=112,
		name="极品灵石",
		itemId=35012,
		group=9,
		count=4,
		rate=40,
		notice=1,
	},
	[113]={
		id=113,
		name="极品灵石",
		itemId=35012,
		group=9,
		count=4,
		rate=40,
		notice=1,
	},
	[114]={
		id=114,
		name="大金币袋",
		itemId=20013,
		group=9,
		count=8,
		rate=50,
		notice=1,
	},
	[115]={
		id=115,
		name="大金币袋",
		itemId=20013,
		group=9,
		count=8,
		rate=50,
		notice=1,
	},
	[116]={
		id=116,
		name="经验丹·极",
		itemId=20004,
		group=9,
		count=10,
		rate=40,
		notice=1,
	},
	[117]={
		id=117,
		name="经验丹·极",
		itemId=20004,
		group=9,
		count=10,
		rate=40,
		notice=1,
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg