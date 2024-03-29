--[[
	id:int#行为ID
	remask:string#行为说明
	targetType:int#目标类型0=玩家
1=怪物
2=BUFF
	targetChoice:int#目标选取0=就近选取
1=仇恨最高
2=血量最低
	actionType:int#行为类型0=释放技能
1=定点移动
2=选取移动
3=跟随玩家
4=瞬移玩家
	actionValue:int[]#行为参数0：技能ID
1：坐标点
2：BUFFID
3：0
4：0
	actionEnd:int#行为结束0=达成目的
配置时间
	actionSwitch:int#行为跳转0=不指定跳转
1=指定判定层ID
2=指定行为层ID
	switchValue:int#跳转参数0:0
1：判定层ID
2：行为层ID
]]

local cfg={
	[2030]={
		id=2030,
		remask="山膏砸地",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2030},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2031]={
		id=2031,
		remask="山膏旋转",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2031},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2032]={
		id=2032,
		remask="山膏近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2032},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2040]={
		id=2040,
		remask="多罗罗近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2040},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2041]={
		id=2041,
		remask="多罗罗位移",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2041},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2042]={
		id=2042,
		remask="多罗罗矩形",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2042},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2050]={
		id=2050,
		remask="狸力矩形",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2050},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2051]={
		id=2051,
		remask="狸力近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2051},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2060]={
		id=2060,
		remask="鸣蛇近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2060},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2061]={
		id=2061,
		remask="鸣蛇远单",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2061},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2062]={
		id=2062,
		remask="鸣蛇圆形",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2062},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2070]={
		id=2070,
		remask="独目鬼重劈",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2070},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2071]={
		id=2071,
		remask="独目鬼鬼火",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2071},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2072]={
		id=2072,
		remask="独目鬼普攻",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2072},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2080]={
		id=2080,
		remask="山鬼普攻",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2080},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2081]={
		id=2081,
		remask="山鬼圆形2段",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2081},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2082]={
		id=2082,
		remask="山鬼旋转",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2082},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2090]={
		id=2090,
		remask="举父近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2090},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2091]={
		id=2091,
		remask="举父移动伤害源",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2091},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2092]={
		id=2092,
		remask="举父跟踪伤害源",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2092},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2093]={
		id=2093,
		remask="举父远程范围",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2093},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2100]={
		id=2100,
		remask="黄祖近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2100},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2101]={
		id=2101,
		remask="黄祖持续单体",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2101},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2102]={
		id=2102,
		remask="黄祖远单体",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2102},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2110]={
		id=2110,
		remask="明蛛近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2110},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2111]={
		id=2111,
		remask="明蛛扇形",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2111},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2112]={
		id=2112,
		remask="明蛛子弹",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2112},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2120]={
		id=2120,
		remask="一目人近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2120},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2121]={
		id=2121,
		remask="一目人圆形",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2121},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2130]={
		id=2130,
		remask="山魈近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2130},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2131]={
		id=2131,
		remask="山魈旋转",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2131},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2132]={
		id=2132,
		remask="山魈飞矛",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2132},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2140]={
		id=2140,
		remask="夔牛护盾",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2140},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2141]={
		id=2141,
		remask="夔牛近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2141},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2150]={
		id=2150,
		remask="文马近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2150},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2151]={
		id=2151,
		remask="文马飞矛",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2151},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2152]={
		id=2152,
		remask="文马矩形",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2152},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2153]={
		id=2153,
		remask="文马冲锋",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2153},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2160]={
		id=2160,
		remask="桑伯近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2160},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2161]={
		id=2161,
		remask="桑伯矩形",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2161},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2162]={
		id=2162,
		remask="桑伯远范围",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2162},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2170]={
		id=2170,
		remask="泽蛙近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2170},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2171]={
		id=2171,
		remask="泽蛙远单",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2171},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2172]={
		id=2172,
		remask="泽蛙近范",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2172},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2180]={
		id=2180,
		remask="呼罗罗远单",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2180},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2181]={
		id=2181,
		remask="呼罗罗旋转",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2181},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2182]={
		id=2182,
		remask="呼罗罗随机范围",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2182},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2190]={
		id=2190,
		remask="渊客技能1",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2190},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2191]={
		id=2191,
		remask="渊客技能2",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2191},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2192]={
		id=2192,
		remask="渊客技能3",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2192},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2200]={
		id=2200,
		remask="虹龟冲锋",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2200},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2201]={
		id=2201,
		remask="虹龟砸地",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2201},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2202]={
		id=2202,
		remask="虹龟远程",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2202},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2203]={
		id=2203,
		remask="虹龟近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2203},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2210]={
		id=2210,
		remask="皓苍近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2210},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2211]={
		id=2211,
		remask="皓苍远范",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2211},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2212]={
		id=2212,
		remask="皓苍近范",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2212},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2220]={
		id=2220,
		remask="承黄技能1",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2220},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2221]={
		id=2221,
		remask="承黄技能2",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2221},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2222]={
		id=2222,
		remask="承黄技能3",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2222},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2230]={
		id=2230,
		remask="鲛女技能1",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2230},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2231]={
		id=2231,
		remask="鲛女技能2",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2231},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2232]={
		id=2232,
		remask="鲛女技能3",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2232},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2240]={
		id=2240,
		remask="天蛛远单",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2240},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2241]={
		id=2241,
		remask="天蛛位移",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2241},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2242]={
		id=2242,
		remask="天蛛矩形",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2242},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2250]={
		id=2250,
		remask="赤蛤远单",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2250},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2251]={
		id=2251,
		remask="赤蛤喷火",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2251},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2252]={
		id=2252,
		remask="赤蛤火球",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2252},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2260]={
		id=2260,
		remask="旋龟近普",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2260},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2261]={
		id=2261,
		remask="旋龟近范",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2261},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2262]={
		id=2262,
		remask="旋龟加血",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2262},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2270]={
		id=2270,
		remask="飞廉冰爪",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2270},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2271]={
		id=2271,
		remask="飞廉普攻1",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2271},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2272]={
		id=2272,
		remask="飞廉普攻2",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2272},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2273]={
		id=2273,
		remask="飞廉普攻3",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2273},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2274]={
		id=2274,
		remask="飞廉冰环（近）",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2274},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2275]={
		id=2275,
		remask="飞廉冰环（中）",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2275},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2276]={
		id=2276,
		remask="飞廉冰环（远）",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2276},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2277]={
		id=2277,
		remask="飞廉冰雾",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2277},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2278]={
		id=2278,
		remask="飞廉冰锥",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2278},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2280]={
		id=2280,
		remask="青熊单体青竹",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2280},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2281]={
		id=2281,
		remask="青熊自身aoe",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2281},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2282]={
		id=2282,
		remask="青熊发射子弹",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2282},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2290]={
		id=2290,
		remask="化蛇远子弹",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2290},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2291]={
		id=2291,
		remask="化蛇远范围",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2291},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2292]={
		id=2292,
		remask="化蛇自范围",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2292},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2300]={
		id=2300,
		remask="三尾狐普攻",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2300},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2301]={
		id=2301,
		remask="三尾狐单体子弹",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2301},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2302]={
		id=2302,
		remask="三尾狐扇形",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2302},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2303]={
		id=2303,
		remask="三尾狐位移",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2303},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2310]={
		id=2310,
		remask="英招近战",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2310},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2311]={
		id=2311,
		remask="英招远单",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2311},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2312]={
		id=2312,
		remask="英招远范围",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2312},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2320]={
		id=2320,
		remask="开明兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2320},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2321]={
		id=2321,
		remask="开明兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2321},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2322]={
		id=2322,
		remask="开明兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2322},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2330]={
		id=2330,
		remask="旱魃",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2330},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2331]={
		id=2331,
		remask="旱魃",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2331},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2332]={
		id=2332,
		remask="旱魃",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2332},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2340]={
		id=2340,
		remask="无伤",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2340},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2341]={
		id=2341,
		remask="无伤",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2341},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2342]={
		id=2342,
		remask="无伤",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2342},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2343]={
		id=2343,
		remask="无伤",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2343},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2350]={
		id=2350,
		remask="陆吾",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2350},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2351]={
		id=2351,
		remask="陆吾",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2351},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2352]={
		id=2352,
		remask="陆吾",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2352},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2360]={
		id=2360,
		remask="女魃",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2360},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2361]={
		id=2361,
		remask="女魃",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2361},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2362]={
		id=2362,
		remask="女魃",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2362},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2370]={
		id=2370,
		remask="厌火",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2370},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2371]={
		id=2371,
		remask="厌火",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2371},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2372]={
		id=2372,
		remask="厌火",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2372},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2373]={
		id=2373,
		remask="厌火",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2373},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2380]={
		id=2380,
		remask="风后远单",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2380},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2381]={
		id=2381,
		remask="风后远范围",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2381},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2382]={
		id=2382,
		remask="风后矩形范围",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2382},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2383]={
		id=2383,
		remask="风后自身范围",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2383},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2384]={
		id=2384,
		remask="风后雷机关",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2384},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2385]={
		id=2385,
		remask="风后风机关",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2385},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2390]={
		id=2390,
		remask="相柳普攻",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2390},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2391]={
		id=2391,
		remask="相柳咆哮",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2391},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2392]={
		id=2392,
		remask="相柳吐息",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2392},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2393]={
		id=2393,
		remask="相柳附毒吐息",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2393},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2400]={
		id=2400,
		remask="应龙",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2400},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2401]={
		id=2401,
		remask="应龙",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2401},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[2402]={
		id=2402,
		remask="应龙",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={2402},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[3150]={
		id=3150,
		remask="相马",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={3150},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[3151]={
		id=3151,
		remask="相马",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={3151},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[3152]={
		id=3152,
		remask="相马",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={3152},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4011]={
		id=4011,
		remask="狼",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4011},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4012]={
		id=4012,
		remask="法杖狼人",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4012},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4013]={
		id=4013,
		remask="爪子狼人",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4013},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4021]={
		id=4021,
		remask="兽态野猪",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4021},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4022]={
		id=4022,
		remask="弓箭猪人",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4022},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4023]={
		id=4023,
		remask="棒子猪人",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4023},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4041]={
		id=4041,
		remask="弯刀蜥蜴人",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4041},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4042]={
		id=4042,
		remask="法杖蜥蜴人",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4042},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4043]={
		id=4043,
		remask="剑蜥蜴人",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4043},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4310]={
		id=4310,
		remask="蛮民",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4310},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4320]={
		id=4320,
		remask="守护兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4320},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4330]={
		id=4330,
		remask="蛮族祭师",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4330},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4510]={
		id=4510,
		remask="秽血巨人",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4510},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4520]={
		id=4520,
		remask="秽血萨满",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4520},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[4530]={
		id=4530,
		remask="龙血巨人",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={4530},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8010]={
		id=8010,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8010},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8011]={
		id=8011,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8011},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8012]={
		id=8012,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8012},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8013]={
		id=8013,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8013},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8014]={
		id=8014,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8014},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8015]={
		id=8015,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8015},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8016]={
		id=8016,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8016},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8017]={
		id=8017,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8017},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8018]={
		id=8018,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8018},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8019]={
		id=8019,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8019},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8020]={
		id=8020,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8020},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8021]={
		id=8021,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8021},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8022]={
		id=8022,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8022},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8023]={
		id=8023,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8023},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8024]={
		id=8024,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8024},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8025]={
		id=8025,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8025},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8026]={
		id=8026,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8026},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8027]={
		id=8027,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8027},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8028]={
		id=8028,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8028},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8029]={
		id=8029,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8029},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8030]={
		id=8030,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8030},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8031]={
		id=8031,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8031},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8032]={
		id=8032,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8032},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8033]={
		id=8033,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8033},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8034]={
		id=8034,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8034},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8035]={
		id=8035,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8035},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8036]={
		id=8036,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8036},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8037]={
		id=8037,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8037},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8038]={
		id=8038,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8038},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8039]={
		id=8039,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8039},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8040]={
		id=8040,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8040},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8041]={
		id=8041,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8041},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8042]={
		id=8042,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8042},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8043]={
		id=8043,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8043},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8044]={
		id=8044,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8044},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8045]={
		id=8045,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8045},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8046]={
		id=8046,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8046},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8047]={
		id=8047,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8047},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8048]={
		id=8048,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8048},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	},
	[8049]={
		id=8049,
		remask="召唤兽",
		targetType=0,
		targetChoice=0,
		actionType=0,
		actionValue={8049},
		actionEnd=0,
		actionSwitch=0,
		switchValue=0
	}
}

function cfg:Get( key )
	return cfg[key]
end
return cfg