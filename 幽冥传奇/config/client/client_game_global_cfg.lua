
-- 客户端游戏上的全局配置
CLIENT_GAME_GLOBAL_CFG = {
	mainui_stone = {
		454,    -- 回城石物品id
		455,    -- 随机石物品id
	},
	wing_skill_icon_list = {10000, 10001, 10002, 10003, 10004, 10005},	-- 翅膀技能图标物品id
	xuelian_items = {496, 497, 487},	-- 天山雪莲物品id
	fuhuo_item_id = 460,				-- 复活物品id
	
	
	
	circle_exchange_icon = 10006,		-- 转生等级兑换显示图标
	lunhui_exchange_icon = 10007,		-- 轮回等级兑换显示图标
	heart_item_id = 3413,				-- 心法物品id
	fuwen_jh_id = 3499,					-- 符文精华物品id
	prestige_wand_id = 3518,			-- 威望令id
	shengwu_id = 3443,					-- 圣物id
	shenyu_id = 3477,					-- 神羽碎片id
	shenyu2_id = 3170,					-- 神羽id
	fuwen_equip_id = 2836,				-- 符文id
	change_name_card = 458,			-- 角色更名卡id
	custom_title_a = 3903,			-- 自定义称号a id
	custom_title_b = 3904,			-- 自定义称号b id
	GetUsetitle = 1677, 			-- 获得使用佩戴称号

	-- 背包中不提醒红点  使用的物品id
	ignore_remind_items = {
----------------------------------------------------

[445] = 1,--刺杀剑法
[446] = 1,--半月剑法
[447] = 1,--烈火剑法
[448] = 1,--开天神斩
[449] = 1,--野蛮冲撞
[450] = 1,--护体神盾
[1630] = 1,--逐日剑法
[3067] = 1,--怒冲秘籍
[3068] = 1,--龙爪手

[454] = 1,--回城石
[455] = 1,--随机石
[461] = 1,--传音喇叭
[456] = 1,--赎罪药水
[457] = 1,--行会召唤令
[458] = 1,--角色更名卡
[459] = 1,--庆典烟花
[542] = 1,--贵族特权
[543] = 1,--王者特权
[544] = 1,--至尊特权
[2134] = 1,--精
[2135] = 1,--彩
[2136] = 1,--春
[2137] = 1,--夏
[2138] = 1,--秋
[2139] = 1,--冬
[2140] = 1,--季
[2141] = 1,--周
[2142] = 1,--年
[2143] = 1,--与
[2144] = 1,--同
[2145] = 1,--国
[2146] = 1,--庆
[2147] = 1,--典
[2148] = 1,--百
[2149] = 1,--千
[2150] = 1,--圣
[2151] = 1,--诞
[2152] = 1,--狂
[2153] = 1,--欢
[2154] = 1,--活
[2155] = 1,--动
[2156] = 1,--回
[2157] = 1,--馈
[2158] = 1,--你
[2159] = 1,--在
[2160] = 1,--中
[2161] = 1,--节
[2162] = 1,--日
[2163] = 1,--元
[2164] = 1,--旦
[2165] = 1,--愚
[2166] = 1,--情
[2167] = 1,--人
[2168] = 1,--宵
[2169] = 1,--清
[2170] = 1,--明
[2171] = 1,--劳
[2172] = 1,--正
[2173] = 1,--版
[2174] = 1,--传
[2175] = 1,--奇
[2176] = 1,--炎
[2177] = 1,--龙
[2178] = 1,--赤
[2179] = 1,--月
[2180] = 1,--城
[2181] = 1,--齐
[2182] = 1,--您
[2183] = 1,--度
[2184] = 1,--浪
[2185] = 1,--漫
[2186] = 1,--喜
[2187] = 1,--迎
[2188] = 1,--六
[2189] = 1,--一
[2190] = 1,--儿
[2191] = 1,--童
[2192] = 1,--感
[2193] = 1,--恩
[2194] = 1,--重
[2195] = 1,--阳
[2196] = 1,--王
[2197] = 1,--战
[2198] = 1,--法
[2199] = 1,--道
[2200] = 1,--来
[2201] = 1,--袭
[2202] = 1,--嗨
[2203] = 1,--爆
[2204] = 1,--全
[2205] = 1,--场
[2206] = 1,--劲
[2207] = 1,--服
[2208] = 1,--教
[2209] = 1,--师
[2210] = 1,--立
[2211] = 1,--学
[2212] = 1,--生
[2213] = 1,--平
[2214] = 1,--安
[2215] = 1,--夜
[2216] = 1,--至
[2217] = 1,--腊
[2218] = 1,--八
[2219] = 1,--小
[2220] = 1,--寒
[2221] = 1,--除
[2222] = 1,--夕
[2223] = 1,--妇
[2224] = 1,--女
[2225] = 1,--植
[2226] = 1,--树
[2227] = 1,--分
[2228] = 1,--五
[2229] = 1,--四
[2230] = 1,--青
[2231] = 1,--博
[2232] = 1,--物
[2233] = 1,--馆
[2234] = 1,--环
[2235] = 1,--境
[2236] = 1,--父
[2237] = 1,--亲
[2238] = 1,--奥
[2239] = 1,--林
[2240] = 1,--匹
[2241] = 1,--克
[2242] = 1,--建
[2243] = 1,--党
[2244] = 1,--暑
[2245] = 1,--假
[2246] = 1,--大
[2247] = 1,--军
[2248] = 1,--十
[2249] = 1,--新
[2250] = 1,--快
[2251] = 1,--乐
[2252] = 1,--午
[2253] = 1,--端
[2254] = 1,--天
[2255] = 1,--佳

----------------------------------------------------
	},

	--背包整理不弹使用框的物品
	ignore_openkeyview_items = {   
----------------------------------------------------

[2284] = 1,-- 红包
[2285] = 1,-- 大红包
[2134] = 1,--精
[2135] = 1,--彩
[2136] = 1,--春
[2137] = 1,--夏
[2138] = 1,--秋
[2139] = 1,--冬
[2140] = 1,--季
[2141] = 1,--周
[2142] = 1,--年
[2143] = 1,--与
[2144] = 1,--同
[2145] = 1,--国
[2146] = 1,--庆
[2147] = 1,--典
[2148] = 1,--百
[2149] = 1,--千
[2150] = 1,--圣
[2151] = 1,--诞
[2152] = 1,--狂
[2153] = 1,--欢
[2154] = 1,--活
[2155] = 1,--动
[2156] = 1,--回
[2157] = 1,--馈
[2158] = 1,--你
[2159] = 1,--在
[2160] = 1,--中
[2161] = 1,--节
[2162] = 1,--日
[2163] = 1,--元
[2164] = 1,--旦
[2165] = 1,--愚
[2166] = 1,--情
[2167] = 1,--人
[2168] = 1,--宵
[2169] = 1,--清
[2170] = 1,--明
[2171] = 1,--劳
[2172] = 1,--正
[2173] = 1,--版
[2174] = 1,--传
[2175] = 1,--奇
[2176] = 1,--炎
[2177] = 1,--龙
[2178] = 1,--赤
[2179] = 1,--月
[2180] = 1,--城
[2181] = 1,--齐
[2182] = 1,--您
[2183] = 1,--度
[2184] = 1,--浪
[2185] = 1,--漫
[2186] = 1,--喜
[2187] = 1,--迎
[2188] = 1,--六
[2189] = 1,--一
[2190] = 1,--儿
[2191] = 1,--童
[2192] = 1,--感
[2193] = 1,--恩
[2194] = 1,--重
[2195] = 1,--阳
[2196] = 1,--王
[2197] = 1,--战
[2198] = 1,--法
[2199] = 1,--道
[2200] = 1,--来
[2201] = 1,--袭
[2202] = 1,--嗨
[2203] = 1,--爆
[2204] = 1,--全
[2205] = 1,--场
[2206] = 1,--劲
[2207] = 1,--服
[2208] = 1,--教
[2209] = 1,--师
[2210] = 1,--立
[2211] = 1,--学
[2212] = 1,--生
[2213] = 1,--平
[2214] = 1,--安
[2215] = 1,--夜
[2216] = 1,--至
[2217] = 1,--腊
[2218] = 1,--八
[2219] = 1,--小
[2220] = 1,--寒
[2221] = 1,--除
[2222] = 1,--夕
[2223] = 1,--妇
[2224] = 1,--女
[2225] = 1,--植
[2226] = 1,--树
[2227] = 1,--分
[2228] = 1,--五
[2229] = 1,--四
[2230] = 1,--青
[2231] = 1,--博
[2232] = 1,--物
[2233] = 1,--馆
[2234] = 1,--环
[2235] = 1,--境
[2236] = 1,--父
[2237] = 1,--亲
[2238] = 1,--奥
[2239] = 1,--林
[2240] = 1,--匹
[2241] = 1,--克
[2242] = 1,--建
[2243] = 1,--党
[2244] = 1,--暑
[2245] = 1,--假
[2246] = 1,--大
[2247] = 1,--军
[2248] = 1,--十
[2249] = 1,--新
[2250] = 1,--快
[2251] = 1,--乐
[2252] = 1,--午
[2253] = 1,--端
[2254] = 1,--天
[2255] = 1,--佳

----------------------------------------------------
	},
	-- 材料获取途径
	-- {viewLink;xxxxx;寻宝} 打开一个界面 xxxxx为界面链接字符串（在客户端打开一个界面的时候会在黑色窗口输出）
	-- {moveto;xx;威望任务} 传送到一个npc的身边 xx为 config\misc\ChuansongPoint.lua 配置里的id字段
	item_get_ways = {
--{moveto;51;除魔任务}
--{moveto;48;经验副本}
--{viewLink;Experiment#Trial;试练关卡}
--{viewLink;Investment#Blessing;祈福}
--{viewLink;MainBagView#ComspoePanel;背包合成}
--{viewLink;NewlyBossView;激战BOSS}
--{viewLink;Activity#Active;日常活跃}
--{viewLink;Explore;探索宝藏}
--{viewLink;NewlyBossView#Rare#FortureBoss;稀有BOSS}
--{viewLink;Shop#Bind_yuan;元宝商城}
--{viewLink;Recycle;回收装备}


		[1] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(100级)
		[2] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(200级)
		[3] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(300级)
		[4] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(400级)
		[5] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(500级)
		[6] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(600级)
		[7] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(700级)
		[8] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(800级)
		[9] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(900级)
		[10] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1000级)
		[11] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1100级)
		[12] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1200级)
		[13] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1300级)
		[14] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1400级)
		[15] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1500级)
		[16] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1600级)
		[17] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1700级)
		[18] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1800级)
		[19] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(1900级)
		[20] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",-- 等级直升丹(2000级)
		[22] = "{moveto;51;除魔任务}{moveto;48;经验副本}{viewLink;Experiment#Trial;练功房-试练}{viewLink;Investment#Blessing;祈福-等级祈福}",--  等级直升丹碎片


		[444] = "{moveto;71;天书任务}{viewLink;Shop#Yongzhe;商城-积分}",--技能丹
		[451] = "{moveto;71;天书任务}{viewLink;Activity#Active;日常活动-活跃度}",--上古残卷
		[453] = "{moveto;71;天书任务}{viewLink;Activity#Active;日常活动-活跃度}",--技能残页
		
		[445] = "{moveto;71;天书任务}",--刺杀剑法
		[446] = "{moveto;71;天书任务}",--半月剑法
		[447] = "{moveto;71;天书任务}",--烈火剑法
		[448] = "{moveto;71;天书任务}",--开天神斩
		[449] = "{moveto;71;天书任务}",--野蛮冲撞
		[1630] = "{moveto;71;天书任务}",--逐日剑法
		[450] = "{moveto;71;天书任务}",--护体神盾
		
		[3067] = "{viewLink;Explore;探索宝藏}",--怒冲秘籍
		[3068] = "{viewLink;Explore;探索宝藏}",--龙爪手
		
		[3301] = "{viewLink;精彩活动}",--真气-蓝灵雪魄
		[3302] = "{viewLink;精彩活动}",--真气-紫电霜魂
		[3303] = "{viewLink;Investment#LuxuryGifts;天天福利-豪礼}",--真气-纯真年代
		[3304] = "{viewLink;精彩活动}",--真气-姹紫嫣红
		[3305] = "{viewLink;精彩活动}",--真气-玄黄天罡
		[3306] = "{viewLink;精彩活动}",--真气-浴劫涅槃
		[3307] = "{viewLink;精彩活动}",--真气-降龙伏虎
		[3308] = "{viewLink;精彩活动}",--真气-青鸾火舞
		[3309] = "{viewLink;精彩活动}",--真气-情投意合
		[3310] = "{viewLink;精彩活动}",--真气-比翼双飞
		[2108] = "{viewLink;精彩活动}",--时装兑换卡
		[2109] = "{viewLink;精彩活动}",--幻武兑换卡
		[3322] = "{viewLink;精彩活动}",--真气兑换卡
		

		[1657] = "{moveto;48;炼狱副本}{moveto;21;护送镖车}",--  5神灵精魄
		[1658] = "{moveto;48;炼狱副本}{moveto;21;护送镖车}",--  10神灵精魄
		[1659] = "{moveto;48;炼狱副本}{moveto;21;护送镖车}",--  20神灵精魄
		[1660] = "{moveto;48;炼狱副本}{moveto;21;护送镖车}",--  100神灵精魄
		[1661] = "{moveto;48;炼狱副本}{moveto;21;护送镖车}",--  200神灵精魄
		[1662] = "{moveto;48;炼狱副本}{moveto;21;护送镖车}",--  500神灵精魄
		[2055] = "{moveto;48;炼狱副本}{moveto;21;护送镖车}",--  神灵精魄
		
		[493] = "{viewLink;Guild#OfferView;行会悬赏}{viewLink;Recycle;回收装备}{viewLink;Experiment#Trial;练功房-试炼}{viewLink;Investment#Blessing;祈福-元宝祈福}",--  元宝
		
		[351] = "{viewLink;Experiment#DigOre;练功房-矿洞}{viewLink;Experiment#Trial;练功房-试练}",--  强化石
		[442] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{viewLink;Shop#Prop;商城-钻石}",--  精致强化石
		[443] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{viewLink;Shop#Prop;商城-钻石}",--  极致强化石
		
		[2514] = "{viewLink;Experiment#DigOre;练功房-矿洞}{moveto;48;材料副本}",--  精炼石
		[2937] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{viewLink;Shop#Prop;商城-钻石}",--  精致精炼石
		[2938] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{viewLink;Shop#Prop;商城-钻石}",--  极致精炼石
		
		
		[2278] = "{viewLink;Shop#Prop;商城-钻石}{viewLink;OpenServiceAcitivity.WelfareTurnbel;福利转盘}{viewLink;Investment#DailyChange;每日充值}",--  洗炼符
		[2279] = "{viewLink;Shop#Prop;商城-钻石}",--  洗炼保护石
		[2280] = "{viewLink;Investment#DailyChange;每日充值}",--  精致洗炼符
		[2281] = "{viewLink;OpenServiceAcitivity.WelfareTurnbel;福利转盘}{viewLink;Investment#DailyChange;每日充值}",--  精致洗炼符(完美)
		[2282] = "{viewLink;Explore;探索宝藏}",--  极致洗炼符
		[2283] = "{viewLink;Explore;探索宝藏}",--  极致洗炼符(完美)
		
		[272] = "{viewLink;Experiment#DigOre;练功房-矿洞}{viewLink;NewlyBossView;怪物掉落}",--  血符碎片
		[273] = "{moveto;48;材料副本}{viewLink;Activity#Activity;活动-膜拜城主}{viewLink;Welfare#Welfare;福利大厅-签到}",--  护盾碎片
		[2510] = "{moveto;48;材料副本}{viewLink;Activity#Activity;日常-行会闯关}",--  宝石碎片
		[274] = "{moveto;48;材料副本}{viewLink;Activity#Activity;日常-阵营战}",--  魂珠碎片
		[261] = "{viewLink;Shop#Prop;商城-钻石}",--  天鼎碎片

		[350] = "{moveto;48;材料副本}{viewLink;Welfare#Welfare;福利大厅-签到}",--  羽毛
		[338] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·疾风掠影碎片
		[339] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·雷动九霄碎片
		[340] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·冰雷剑气碎片
		[341] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·双龙戏珠碎片
		[342] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·龙啸九天碎片
		[343] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·天神圣光碎片
		[344] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·冰火龙皇碎片
		[345] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·嗜血魔蝠碎片
		[346] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·花飘花落碎片
		[347] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·剑皇临世碎片
		[348] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·浴血圣凰碎片
		[349] = "{viewLink;DiamondPet;挖掘BOSS}",--  影翼·龙腾天下碎片
		
  


		[2056] = "{viewLink;NewlyBossView#Drop#FortureBoss;激战-运势BOSS}{viewLink;Explore;探索宝藏}",--  特戒
		[2057] = "{viewLink;NewlyBossView#Rare#FortureBoss;激战-运势BOSS}{viewLink;Explore#Fullserpro探索宝藏-全服进度}",--  特戒碎片
		[1628] = "{viewLink;Shop#Prop;商城-钻石}",--  特戒融合石
		[1629] = "{viewLink;Shop#Prop;商城-钻石}",--  特戒分离石
		
		[27] = "{viewLink;Shop#Prop;商城-钻石}",--  洗点神水

		[2051] = "{viewLink;NewlyBossView#Rare#MiJing;激战-热血霸者}{viewLink;Explore#RareTreasure;寻宝-龙皇秘宝}{viewLink;Explore;寻宝获得}",--至尊神石·神兵
		[2052] = "{viewLink;NewlyBossView#Rare#MiJing;激战-热血霸者}{viewLink;Explore#RareTreasure;寻宝-龙皇秘宝}{viewLink;Explore;寻宝获得}",--至尊神石·神甲
		[2053] = "{viewLink;NewlyBossView#Rare#MiJing;激战-龙皇秘境}{viewLink;Explore#RareTreasure;寻宝-龙皇秘宝}{viewLink;Explore;寻宝获得}",--战神神石
		[2054] = "{viewLink;NewlyBossView#CircleBoss;激战-转生BOSS}{viewLink;Explore#RareTreasure;寻宝-龙皇秘宝}{viewLink;Explore;寻宝获得}",--杀阵神石
		[2258] = "{viewLink;NewlyBossView#Rare#MiJing;激战-热血霸者}{viewLink;Explore#RareTreasure;寻宝-龙皇秘宝}{viewLink;Explore;寻宝获得}",--霸者碎片·面甲
		[2259] = "{viewLink;NewlyBossView#Rare#MiJing;激战-热血霸者}{viewLink;Explore#RareTreasure;寻宝-龙皇秘宝}{viewLink;Explore;寻宝获得}",--霸者碎片·护肩
		[2260] = "{viewLink;NewlyBossView#Rare#MiJing;激战-热血霸者}{viewLink;Explore#RareTreasure;寻宝-龙皇秘宝}{viewLink;Explore;寻宝获得}",--霸者碎片·吊坠
		[2261] = "{viewLink;NewlyBossView#Rare#MiJing;激战-热血霸者}{viewLink;Explore#RareTreasure;寻宝-龙皇秘宝}{viewLink;Explore;寻宝获得}",--霸者碎片·护膝


		[863] = "{viewLink;CrossBoss;跨服BOSS-远古秘境}",--万壕装精炼石
		[864] = "{viewLink;CrossBoss;跨服BOSS-远古秘境}",--金壕装精炼石
		[865] = "{viewLink;CrossBoss;跨服BOSS-远古秘境}",--雄壕装精炼石

		[2502] = "{viewLink;NewlyBossView#Rare#ShenWei;激战BOSS-稀有-神威秘境}",--  神羽碎片
		[2503] = "{viewLink;NewlyBossView#Rare#MoyuBoss;激战BOSS-稀有-魔域圣殿}",--  战宠装碎片




		[306] = "{viewLink;Shop#Prop;钻石商城}{viewLink;NewlyBossView#Rare#FortureBoss;激战-限时-运势BOSS}",--  黑檀木
		[307] = "{viewLink;Shop#Prop;钻石商城}{viewLink;NewlyBossView#Rare#FortureBoss;激战-限时-运势BOSS}",--  黑铁矿
		[308] = "{viewLink;Shop#Prop;钻石商城}{viewLink;NewlyBossView#Rare#FortureBoss;激战-限时-运势BOSS}",--  黄铜矿
		[309] = "{viewLink;NewlyBossView#Rare#FortureBoss;激战-限时-运势BOSS}",--  纯银矿
		[310] = "{viewLink;NewlyBossView#Rare#FortureBoss;激战-限时-运势BOSS}",--  鎏金矿
		[311] = "{viewLink;OutOfPrint;绝版抢购}",--  宠技【麻痹之力】
		[312] = "{viewLink;OutOfPrint;绝版抢购}",--  宠技【疾风之力】
		[313] = "{viewLink;OutOfPrint;绝版抢购}",--  宠技【狂血之力】
  




		[352] = "{viewLink;Shop#Prop;商城购买}{viewLink;MainBagView#ComspoePanel;灵石合成}",--  1级生命宝石
		[367] = "{viewLink;Shop#Prop;商城购买}{viewLink;MainBagView#ComspoePanel;灵石合成}",--  1级防御宝石
		[382] = "{viewLink;Shop#Prop;商城购买}{viewLink;MainBagView#ComspoePanel;灵石合成}",--  1级攻击宝石
		[397] = "{viewLink;Shop#Prop;商城购买}{viewLink;MainBagView#ComspoePanel;灵石合成}",--  1级切割宝石
		[412] = "{viewLink;Shop#Prop;商城购买}{viewLink;MainBagView#ComspoePanel;灵石合成}",--  1级暴击宝石
		[427] = "{viewLink;Shop#Prop;商城购买}{viewLink;MainBagView#ComspoePanel;灵石合成}",--  1级韧性宝石


		[452] = "{viewLink;NewlyBossView;激战BOSS}",--  蚩尤神石


		[1710] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;Explore;寻宝}",--  热血Ⅰ☆至尊神兵
		[1713] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;Explore;寻宝}",--  热血Ⅰ☆至尊神甲
		[1716] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;Explore;寻宝}",--  热血Ⅰ☆至尊神铠
		[1719] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;Explore;寻宝}",--  热血Ⅴ☆霸者面甲
		[1727] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;Explore;寻宝}",--  热血Ⅴ☆霸者护肩
		[1735] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;Explore;寻宝}",--  热血Ⅴ☆霸者吊坠
		[1743] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;Explore;寻宝}",--  热血Ⅴ☆霸者护膝
		[1751] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;Explore;寻宝}",--  热血1☆战神头盔
		[1781] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;Explore;寻宝}",--  热血1☆战神项链
		[1811] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;Explore;寻宝}",--  热血1☆战神手镯
		[1841] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;Explore;寻宝}",--  热血1☆战神戒指
		[1871] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;Explore;寻宝}",--  热血1☆战神腰带
		[1901] = "{viewLink;NewlyBossView#Rare#MiJing;龙皇秘宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;Explore;寻宝}",--  热血1☆战神鞋子
		[1931] = "{viewLink;Explore;寻宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;NewlyBossView#Wild#CircleBoss;转生BOSS}",--  1阶·四方杀阵々天煞
		[1961] = "{viewLink;Explore;寻宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;NewlyBossView#Wild#CircleBoss;转生BOSS}",--  1阶·四方杀阵々天绝
		[1991] = "{viewLink;Explore;寻宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;NewlyBossView#Wild#CircleBoss;转生BOSS}",--  1阶·四方杀阵々天劫
		[2021] = "{viewLink;Explore;寻宝}{viewLink;MainGodEquipView#RexueGodEquipDuiHuan;兑换}{viewLink;NewlyBossView#Wild#CircleBoss;转生BOSS}",--  1阶·四方杀阵々天命
		[2098] = "{viewLink;NewlyBossView;激战BOSS}",--魄力值
		[2262] = "{moveto;3;膜拜城主}{viewLink;NewlyBossView#Rare#Chiyou;蚩尤结界}",--屠魔令
		[2096] = "{viewLink;Recycle;回收装备}",--勇者积分
		[266] = "{viewLink;Investment#Blessing;祈福}{viewLink;Experiment#Trial;试炼}{viewLink;NewlyBossView;激战boss}{viewLink;Recycle;回收装备}{viewLink;Activity#Activity;元宝嘉年华}{viewLink;Activity#Activity;多倍押镖}",--  5W元宝

		[2835] = "{viewLink;CrossBoss#FlopCard;跨服BOSS-翻牌}{viewLink;Shop#Prop;钻石商城}",--  元素【火系】
		[2836] = "{viewLink;CrossBoss#FlopCard;跨服BOSS-翻牌}{viewLink;Shop#Prop;钻石商城}",--  元素【暗系】
		[2837] = "{viewLink;CrossBoss#FlopCard;跨服BOSS-翻牌}{viewLink;Shop#Prop;钻石商城}",--  元素【光系】
		[2838] = "{viewLink;CrossBoss#FlopCard;跨服BOSS-翻牌}{viewLink;Shop#Prop;钻石商城}",--  元素【风系】
		[2839] = "{viewLink;CrossBoss#FlopCard;跨服BOSS-翻牌}{viewLink;Shop#Prop;钻石商城}",--  元素【雷系】
		[2840] = "{viewLink;CrossBoss#FlopCard;跨服BOSS-翻牌}{viewLink;Shop#Prop;钻石商城}",--  元素【冰系】
		[479] = "{viewLink;CrossBoss#CrossBossInfo;跨服BOSS-上古圣兽宫}{viewLink;Shop#Prop;钻石商城}",--  圣兽灵力
		
		[2832] = "{viewLink;Activity#Activity;日常-闭关修炼}{viewLink;Shop#Prop;钻石商城}",--  魔书丹(小)
		[2833] = "{viewLink;Activity#Activity;日常-闭关修炼}{viewLink;Shop#Prop;钻石商城}",--  魔书丹(中)
		[2834] = "{viewLink;Activity#Activity;日常-闭关修炼}{viewLink;Shop#Prop;钻石商城}",--  魔书丹(大)
		[2815] = "{viewLink;Activity#Activity;日常-闭关修炼}",--  魔书【砂玉丹】
		[2816] = "{viewLink;Activity#Activity;日常-闭关修炼}",--  魔书【血牙丹】
		[2817] = "{viewLink;Activity#Activity;日常-闭关修炼}",--  魔书【炽凰丹】

		[700] = "{viewLink;Shop#Prop;钻石商城}",--  材料扫荡令
		
		[317] = "{viewLink;MainBagView#ComspoePanel;背包-合成}",--  初级BOSS召唤令
		[318] = "{viewLink;MainBagView#ComspoePanel;背包-合成}",--  高级BOSS召唤令
		[319] = "{viewLink;MainBagView#ComspoePanel;背包-合成}",--  超级BOSS召唤令
		[320] = "{viewLink;MainBagView#ComspoePanel;背包-合成}",--  顶级BOSS召唤令
		[482] = "{viewLink;MainBagView#ComspoePanel;背包-合成}",--  初级经验珠
		[483] = "{viewLink;MainBagView#ComspoePanel;背包-合成}",--  中级经验珠
		[484] = "{viewLink;MainBagView#ComspoePanel;背包-合成}{viewLink;Activity#Active;日常活动-活跃度}",--  高级经验珠
		[485] = "{viewLink;MainBagView#ComspoePanel;背包-合成}",--  超级经验珠



	},

	-- 内功说明
	inner_tip_content = "{image;res/xui/common/orn_100.png;25,20}采用绑金可升级内功等级\n{image;res/xui/common/orn_100.png;25,20}受到伤害时按比例优先扣内功值再扣血\n{image;res/xui/common/orn_100.png;25,20}内功穿透：忽略目标的内功免伤\n{image;res/xui/common/orn_100.png;25,20}各种资质丹可提升内功的各种属性",
	-- 战鼓说明
	prestige_tip_content = "1.战魂值达到条件可自动升级战鼓，获得属性加成；\n2.攻击战鼓等级低于自身的玩家时，伤害额外增加10%；\n3.每天0点根据玩家当前战鼓等级回收战魂值，战鼓等级越高，回收量越大。当战魂值不足时，自动降低战鼓等级；\n4.每天根据战鼓等级和战魂值，重新排榜",
	-- 烈焰幻境说明
	fire_vision_tip_content = "1.击杀BOSS可获得一次祈福机会\n2.击杀BOSS次数在次日0点重置\n3.祈福有几率获得极品烈焰印记",
	-- 龙魂圣域说明
	dragon_soul_tip_content = "1.击杀BOSS可获得一次祈福机会\n2.击杀BOSS次数在次日0点重置\n3.祈福有几率获得极品抗暴心法",

	----通用特效id
	-- 分解成功播放特效id
	decompose_eff_id = 8,
	-- 合成成功播放特效id
	compose_eff_id = 13,

	-- 升级成功
	upgrade_eff_id = 17,

	chuansong_npc_id = 75, -- 传送员npc id

	-- 分解分类配置 level 等级范围,circle 转生范围, type 物品类型
	recycle_lev_limit = {
		[1] = {level = {0, 300}, circle = nil, type = {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【300级以下】装备（{wordcolor;%s;%s}）"},
		[2] = {level = nil, circle = {1, 3}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【1-2转】装备（{wordcolor;%s;%s}）"},
		[3] = {level = nil, circle = {3, 4}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【3转】装备（{wordcolor;%s;%s}）"},
		[4] = {level = nil, circle = {4, 5}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【4转】装备（{wordcolor;%s;%s}）"},
		[5] = {level = nil, circle = {5, 6}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【5转】装备（{wordcolor;%s;%s}）"},
		[6] = {level = nil, circle = {6, 7}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【6转】装备（{wordcolor;%s;%s}）"},
		[7] = {level = nil, circle = {7, 8}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【7转】装备（{wordcolor;%s;%s}）"},
		[8] = {level = nil, circle = {8, 9}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【8转】装备（{wordcolor;%s;%s}）"},
		[9] = {level = nil, circle = {9, 10}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【9转】装备（{wordcolor;%s;%s}）"},
		--[10] = {level = nil, circle = {10, 11}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【10转】装备（{wordcolor;%s;%s}）"},
		--[11] = {level = nil, circle = {11, 12}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【11转】装备（{wordcolor;%s;%s}）"},
		--[12] = {level = nil, circle = {12, 13}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【12转】装备（{wordcolor;%s;%s}）"},
		--[13] = {level = nil, circle = {13, 14}, type =  {1, 2, 3, 4, 5, 6, 7, 8}, desc = "【13转】装备（{wordcolor;%s;%s}）"},
		--[8] = {level = nil, circle = nil, type = {146}, desc = "【守护神装】（{wordcolor;%s;%s}）"},
		--[9] = {level = nil, circle = nil, type = {15, 16, 39, 40}, desc = "【热血杀阵】（{wordcolor;%s;%s}）"},
	},

	-- 特殊装备分解
	sprice_equip = {level = {0, 1}, circle = nil, type = {9, 10, 11, 12, 13, 14, 41, 42, 43, 44, 45, 46, 15, 16, 39, 40, 27 ,28 ,29 ,31 ,32 ,36 ,37 ,35 ,33 ,30 ,34 ,38 ,146 ,147 ,50 ,51 ,52 ,53}, desc = "【热血杀阵】（{wordcolor;%s;%s}）"},

	-- CQ20_IOS平台需要使用特殊金额的渠道 目前应用于"特权卡"和"充值大礼包"
	ios_charge = {["iaa"] = 1, ["aaa"] = 1, ["iab"] = 1, ["lbm"] = 1},

	-- 自动完成任务时间
	atuo_complete_task = 5,

	bag_type_list = {
		zb_type_list = { -- 背包-装备
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
			[5] = 1,
			[6] = 1,
			[7] = 1,
			[8] = 1,
			[17] = 1,
			[18] = 1,
			[19] = 1,
			[20] = 1,
			[21] = 1,
			[22] = 1,
			[23] = 1,
			[24] = 1,
			[30] = 1,
			[31] = 1,
			[32] = 1,
			[33] = 1,
			[34] = 1,
			[35] = 1,
			[36] = 1,
			[37] = 1,
			[38] = 1,
			[9] = 1,
			[10] = 1,
			[11] = 1,
			[12] = 1,
			[13] = 1,
			[14] = 1,
			[41] = 1,
			[42] = 1,
			[43] = 1,
			[44] = 1,
			[45] = 1,
			[46] = 1,
			[15] = 1,
			[16] = 1,
			[39] = 1,
			[40] = 1,
			[25] = 1,
			[26] = 1,
			[120] = 1,
			[121] = 1
		},
		material_type_list = { -- 背包-材料
			[102] = 1,
			[103] = 1,
			[104] = 1,
			[105] = 1,
			[106] = 1,
			[113] = 1,
			[124] = 1,
			[144] = 1,
		}
	},

	-- 装扮预览 格式 {{item_id-男, item_id-女}, ...} or {item_id-通用, ...}
	fashion_preview = {
		[1] = {--装扮-时装
			{1484,1488},--嘻哈乐手(男) 嘻哈乐手(女)
			{1496,1500},--铁血军魂(男)
			{1508,1512},--天长地久(男)
			{1520,1524},--网球王子(男)
			{1532,1536},--沙滩派对(男)
			{1544,1548},--蜘蛛侠(男)
			{1664,1665},--至尊·巅峰霸主(男)
		},

		[2] = { --装扮-幻武
			1492,--魔音贝斯
			1504,--铁军战魂
			1516,--一枝恩爱玫
			1528,--特大网球拍
			1540,--鲨鱼泳圈
			1552,--蜘蛛电刃
			1663,--至尊·龙城之刃
		},
		[3] = { --装扮-真气
			3301,--蓝灵雪魄
			3302,--紫电霜魂
			3303,--纯真年代
			3304,--姹紫嫣红
			3305,--玄黄天罡
			3306,--浴劫涅槃
			3307,--降龙伏虎
			3308,--青鸾火舞
			3309,--情投意合
			3310,--比翼双飞

		},
	},


	-- 称号列表-用于开放显示
	-- 字段item_id 已弃用
	title_client_config = {
	--------------------------------------------------
		[1] =  {effect_id = 212,},				--1//家里有矿(首充获得)
		[2] =  {effect_id = 213,},				--2//不要怂就是干(登录7天获得)
		[3] =  {effect_id = 214,},				--3//武器大师(【守护竞技30】活动,第1名)
		[4] =  {effect_id = 215,},				--4//逍遥尊者(【战宠竞技19】活动,第1名)
		[5] =  {effect_id = 216,},				--5//物华天宝(【魂珠竞技21】活动,第1名)
		[6] =  {effect_id = 217,},				--6//无翼伦比(【翅膀竞技9】活动,第1名)
		[7] =  {effect_id = 218,},				--7//无敌是多么寂寞(【战力竞技23】活动,第1名)
		[8] =  {effect_id = 219,},				--8//杀BOSS直升VIP12(主线任务赠送)
		[9] =  {effect_id = 1183,},				--9//天地神壕(【合服-消费争锋81】活动,第1名)
	--	[10] = {effect_id = 221,},				--10//君临天下(【土豪装竞技】第一名)[暂时无用]
		[11] = {effect_id = 222,},				--11//天下第一壕(【开服-消费竞技18】活动,第1名)
		[12] = {effect_id = 237,},				--12//无敌神装(【热血竞技22】活动,第1名)
		[13] = {effect_id = 1178,},				--13//珠光宝气(【宝石竞技20】活动,第1名)
		[14] = {effect_id = 1179,},				--14//转世天帝(【等级竞技8】活动,第1名)
		[15] = {effect_id = 408,},				--15//万人斩(日常活动-阵营战，击杀100人)
		[16] = {effect_id = 1180,},				--16//鉴宝达人(【鉴宝竞技24】活动,第1名)
	--	[17] = {effect_id = 224,},				--17//星空之神(【星魂竞技】第一名)[暂时无用]
		[22] = {effect_id = 1181,},				--定制称号专用1
		[23] = {effect_id = 1327,},				--定制称号专用2	天空之城城主(称号)   【玩家名字:s21.心已放空】

		[33] = {effect_id = 223,},				--33//最强王者(排行榜-战力榜，第1名)
		[34] = {effect_id = 224,},				--34//至尊星耀(排行榜-战力榜，第2-10名)
	--	[35] = {effect_id = 230,},				--35//达官显贵(根据封神等级做判断第一名可获得)[暂时无用]
	--	[36] = {effect_id = 231,},				--36//十大名流(官职等级做判断，官职第2-10名获得)[暂时无用]
		[37] = {effect_id = 230,},				--37//枭雄之首(排行榜-等级榜-第1名)
		[38] = {effect_id = 231,},				--38//十大枭雄(排行榜-等级榜，第2-10名)
	--	[39] = {effect_id = 332, item_id = 0},					--39//战神无双(装备战力第一名)[暂时无用]
	--	[40] = {effect_id = 235,},				--40//十大宗师(装备战力第2-10名)[暂时无用]
		[41] = {effect_id = 332,},				--41//持宝人(日常活动-夺宝奇兵,持宝人)
		[42] = {effect_id = 235,},				--42//龙城城主(日常活动-攻城战-王城城主)
		[43] = {effect_id = 236,},				--43//龙城勇士(日常活动-攻城战-王城成员) 
		[44] = {effect_id = 1182,},				--44//雄霸天下(日常活动-武林争霸，第一名)
	--	[45] = {effect_id = 401,},				--45//万世伟业(试炼推关第一名)[暂时无用]
	--	[46] = {effect_id = 402,},				--46//十大雄才(试炼推关第2-10名)[暂时无用]
		[47] = {effect_id = 1228,},				--47//贵族特权
		[48] = {effect_id = 1229,},				--48//王者特权
		[49] = {effect_id = 1230,},				--49//至尊特权
	--	[50] = {effect_id = 409,},				--50//至尊神壕(合服5天总消费榜第1名可获得)[暂时无用]
		[51] = {effect_id = 409,},				--51//屠龙高手(日常活动-世界BOSS，最后一击)
		
		[200] = {effect_id = 450,},					--护镖大亨

	--------------------------------------------------
	},
}


-- 物品合成类型 和item\itemEnhance\ItemSynthesisConfig.lua服务端配置对应
ITEM_SYNTHESIS_TYPES = {
	GOD_WING = 1, -- 神羽合成
	STONE = 2, -- 宝石合成
	FUWEN = 3, -- 符文兑换
	CHUANSHI = 4, -- 传世分解
	BATTLE_LINE = 5, -- 战纹
	COLOR_STONE = 6, -- 七彩石
}

-- 装备分解类型 和item\itemEnhance\EquipDecompose.lua服务端配置对应
EQUIP_DECOMPOSE_TYPES = {
	GOD_EQUIP = 1, -- 神装分解
	FUWEN = 2, -- 符文分解
	HEART = 3, -- 心法分解
}




--[[
-- 客户端条件判断配置
runtime\assets\scripts\game\common\cond_def.lua

-- 客户端视图
runtime\assets\scripts\game\common\view_def.lua

-- 主界面图标(可以调整图标的排列顺序和开放条件)
runtime\assets\scripts\game\common\mainui_def.lua

-- 客户端场景配置
runtime\assets\scripts\config\config_map.lua

-- 物品tip显示类型配置
runtime\assets\scripts\game\tip\tip_def.lua

-- 主线任务配置
runtime\assets\scripts\game\task\task_def.lua

-- 功能引导配置
runtime\assets\scripts\config\client\FunctionGuide.lua

-- 主界面提示小图标
runtime\assets\scripts\game\mainui\mainui_small_tip.lua

-- 物品合成视图配置
runtime\assets\scripts\config\client\item_synthesis_view_cfg.lua

传世装备基础属性id定义、传世装备技能描述
runtime\assets\scripts\config\client\chuanshi_cfg.lua

神炉-抗暴神技
runtime\assets\scripts\config\client\heart_suit_plus_cfg.lua

--烈焰神力技能配置
runtime\assets\scripts\config\client\fire_god_power_cfg.lua

-- 寻宝装备预览配置
runtime\assets\scripts\config\client\dream.lua

-- 极品预览配置
runtime\assets\scripts\config\client\shop_preview_cfg.lua

-- 伤害文字显示配置
runtime\assets\scripts\game\fight\fight_text.lua

-- 圣兽宫殿物品显示配置
runtime\assets\scripts\config\client\beast_palace_cfg.lua

-- 烈焰幻境物品显示配置
runtime\assets\scripts\config\client\fire_vision_cfg.lua

-- 商店配置路径
runtime\assets\scripts\config\server\config\store\ShangPu\
 "3JingYanDaoJu", "4QiZhenYiBao",
 
-- 极品预览配置
runtime\assets\scripts\config\client\shop_preview_cfg.lua -- 商店
runtime\assets\scripts\config\client\fire_vision_preview_cfg.lua -- 烈焰幻境
runtime\assets\scripts\config\client\dragon_soul_preview_cfg.lua -- 龙魂圣城

-- 王城争霸奖励显示配置
runtime\assets\scripts\config\client\wang_cheng_zheng_ba_cfg.lua

-- 称号获得条件配置
runtime\assets\scripts\config\client\title\headTitleDesc.lua

-- 开服活动王成霸业配置
runtime\assets\scripts\config\client\open_server\WangChengBaYeCfg.lua

]]
