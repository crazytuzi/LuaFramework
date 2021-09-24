platWarCfg=
{
	--地图属性
	mapAttr={
		--线路数量
		lineNum=5,
		--每条线路的位置长度
		lineLength=245,
		--据点的位置,位于据点的时候,地形为6城市。
		cityPos={1,62,123,184,245},
		--据点的耐久度类型
		cityType={2,1,0,1,2},
		--据点类型为1的耐久度
		cityBlood1=10000,
		--据点类型为2的耐久度
		cityBlood2=20000,
		--5条线路的对应地形,结算顺序也是这个,☆后台配置☆ 地形顺序1-5为 沼泽 山地 森林 沙漠 平原
		linePos={5,1,4,2,3},
		--5条线路的对应地图,结算顺序也是这个,☆前台显示☆ 地形从左至右是 沙漠 山地 沼泽 森林 平原
		linePosClient={4,2,1,3,5},
		--五条路的地形
		lineLandtype={5,1,4,2,3},



	},

	--坦克消耗兑换的比例
	--100比1的消耗比例,不足的部分向上取整
	tankeTransRate=100,
	-- 抓取战力前多名
	fcLimit=100,
	-- 实际参赛人数（前多少名）
	joinLimit=40,
	--积分明细最多多少条
	militaryrank=50,
	--每次设置部队和线路需要间隔1分钟
	settingTroopsLimit=60,

	--前台地图配置
	mapCfg={},

	--平台配置
	--icon：图标，donateNum：捐赠系数
	platform={
		["0"]={icon="platIcon_1.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--本地（和efun一样）
		["efun_tw"]={icon="platIcon_efun_tw.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1,avoid=1,critical=1,decritical=1}},	--efun港台
		["zsy_ru"]={icon="platIcon_5.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--中手游俄罗斯
		["kunlun_na"]={icon="platIcon_5.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--昆仑北美
		["1"]={icon="platIcon_1.png",donateNum=10,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--快用
		["android3kwan"]={icon="platIcon_android3kwan.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--3kwan
		["androidsevenga"]={icon="platIcon_android3kwan.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--德国安卓
		["efun_nm"]={icon="platIcon_android3kwan.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--efun  南美
		["zsy_ko"]={icon="platIcon_korea.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--中手游韩国
		["qihoo"]={icon="platIcon_qihoo.png",donateNum=1,attributeUp={attack=1,life=1.2,accurate=1.15,avoid=1,critical=1.05,decritical=1.05}},	--奇虎360
		["efun_dny"]={icon="platIcon_qihoo.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--efun 东南亚
		["fl_yueyu"]={icon="platIcon_fl_yueyu.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--飞流越狱
		["11"]={icon="platIcon_fl_yueyu.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--德国ios
		["1mobile"]={icon="platIcon_fl_yueyu.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--中手游 北美
		["gNet_jp"]={icon="platIcon_japan.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--日本
		["rayjoy_android"]={icon="platIcon_rayjoy_android.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--国内安卓
		["58"]={icon="platIcon_58.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--新飞流
		["5"]={icon="platIcon_58.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--飞流APP
		["tank_ar"]={icon="platIcon_5.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--阿拉伯
		["kunlun_france"]={icon="platIcon_5.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--法国
		["tank_turkey"]={icon="platIcon_5.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--土耳其
		["vietnam"]={icon="platIcon_5.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--越南
		["lewan"]={icon="platIcon_5.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--乐玩
		["kakao"]={icon="platIcon_korea.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--韩国kakao
		["gnetop"]={icon="platIcon_5.png",donateNum=1,attributeUp={attack=1,life=1,accurate=1.1,avoid=1,critical=1,decritical=1}},	--俄罗斯日本
	},


	--开战前有多少小时准备时间
	preparetime=48,
	--战斗持续多少个小时
	battletime=120,
	--结束战斗后有多少小时购买时间
	shoppingtime=120,

	battleAttr={
		--每次向上移动距离
		move=5,
		--战斗冷却时间，每X秒发生1次战斗
		cdTime=60,
		--每次复活需要 (秒还是回合)
		reviveTime=60,
		--每次攻击据点 （无防守） 减少耐久
		attackEmptyBase=5,
		--每次攻击据点（胜利，有防守 ）减少耐久
		attackBase=1,
		--每次坦克胜利获得贡献
		winRate=3,
		 --单场失败积分
		loseRate=1,
		-- winAllianceRate=30, --占领积分
		-- occupyRate=300, --最终胜利积分加成
		--连续作战减少的属性
		reducePercentage={
			attackReduce=0.25,	--攻击减少
			lifeReduce=0.25,		--血量减少
		},
	},

	--部队捐赠
	troopsDonate={
		[1]={
			--部队
			troops={{"a50005",1200},{"a50025",1200},{"a50006",1200},{"a50036",1200},{"a50015",1200},{"a50035",1200}},
			--属性修正
			skill={s101=60,s102=60,s103=60,s104=60,s105=60,s106=60,s107=60,s108=60,s109=60,s110=60,s111=60,s112=60,},tech={t1=60,t2=60,t3=60,t4=60,t5=60,t6=60,t7=60,t8=60,},attributeUp={attack=2,life=2,accurate=1,avoid=1,critical=1,decritical=1,},
			--战斗分数
			battlePoint=1000,
			--可捐赠数量
			donateNum=25,
		},
		[2]={
			--部队
			troops={{"a50124",1200},{"a50006",1200},{"a50074",1200},{"a50134",1200},{"a50064",1200},{"a50036",1200}},
			--属性修正
			skill={s101=70,s102=70,s103=70,s104=70,s105=70,s106=70,s107=70,s108=70,s109=70,s110=70,s111=70,s112=70,},tech={t1=70,t2=70,t3=70,t4=70,t5=70,t6=70,t7=70,t8=70,},attributeUp={attack=3,life=3,accurate=1,avoid=1,critical=1,decritical=1,},
			--战斗分数
			battlePoint=1000,
			--可捐赠数量
			donateNum=20,
		},
		[3]={
			--部队
			troops={{"a50094",1200},{"a50006",1200},{"a50074",1200},{"a50044",1200},{"a50083",1200},{"a60054",1200}},
			--属性修正
			skill={s101=80,s102=80,s103=80,s104=80,s105=80,s106=80,s107=80,s108=80,s109=80,s110=80,s111=80,s112=80,},tech={t1=80,t2=80,t3=80,t4=80,t5=80,t6=80,t7=80,t8=80,},attributeUp={attack=4,life=4,accurate=1,avoid=1,critical=1,decritical=1,},
			--战斗分数
			battlePoint=1000,
			--可捐赠数量
			donateNum=15,
		},
	},


	--部队士气
	troopsMorale={
		-- 士气影响 = 造成伤害的公式
		--  造成的伤害（额外提升部分）=   士气点数 / (  100000 + 士气点数） * 1
		-- 士气影响 = 受到伤害的公式 =   ( 士气点数 / (  100000 + 士气点数） * 1 )
		-- 士气影响 = 防护的公式 =  士气点数 / (  100000 + 士气点数） * 250
		-- 士气影响 = 击破的公式 =  士气点数 / (  100000 + 士气点数） * 250
		-- 士气影响 = 命中的公式 =  士气点数 / (  1000 + 士气点数） * 5
		-- 士气影响 = 闪避的公式 =  士气点数 / (  1000 + 士气点数） * 5
		-- 士气影响 = 暴击的公式 =  士气点数 / (  1000 + 士气点数） * 5
		-- 士气影响 = 装甲的公式 =  士气点数 / (  1000 + 士气点数） * 5
	},


	--留言板花费金币
	noticeCost=20,
	--留言板最大数量
	noticeMaxNum=30,
	--获取留言板数据间隔
	noticeInterval=60,
	--战报最大数量
	reportMaxNum=100,

	-- 捐赠等级限制
	donateLevel=30,
	--捐赠部队获得 贡献：每1辆坦克 = 5点贡献  （无视类型 ）
	donatePointRate=5,
	-- 捐赠坦克活的的商店积分
	donateShopPoint=2,

	--鼓舞士气
	donateMorale={
		--1金币，2点数（这种才可以暴击）
		donateCost1={20,50},
		donateCost2={200,500},
		--每xxx小时可以暴击一次
		critCD=22,
		--暴击的额外士气倍数
		critRate=5,
		--方式1和2，每次获得贡献
		rewardPoint1=20,
		rewardPoint2=200,
		--方式1和2，每次获得商店积分
		rewardShopPoint1=10,
		rewardShopPoint2=100,
	},
	--科技buff
	techBuff={
		--1 增加攻击， 2增加防暑，3 闪避暴击命中装甲，4 增加连击几率
		s1={
			type=1,
			icon="WarBuffCommander.png",
			lvLimit=10,
			effect={0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1}, --科技效果
			cost={50,50,50,50,50,50,50,50,50,50}, --金币花费
			successRate={100,90,80,70,60,50,40,30,20,10}, --成功几率
			powerEffect={0.03,0.06,0.09,0.12,0.15,0.18,0.21,0.24,0.27,0.30}, --对应实力的影响
		},
		s2={
			type=2,
			icon="WarBuffSmeltExpert.png",
			lvLimit=10,
			effect={0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1}, --科技效果
			cost={50,50,50,50,50,50,50,50,50,50}, --金币花费
			successRate={100,90,80,70,60,50,40,30,20,10}, --成功几率
			powerEffect={0.03,0.06,0.09,0.12,0.15,0.18,0.21,0.24,0.27,0.30}, --对应实力的影响
		},
		s3={
			type=3,
			icon="WarBuffNetget.png",
			lvLimit=10,
			effect={0.03,0.06,0.09,0.12,0.15,0.18,0.21,0.24,0.27,0.30}, --科技效果
			cost={80,80,80,80,80,80,80,80,80,80}, --金币花费
			successRate={100,90,80,70,60,50,40,30,20,10}, --成功几率
			powerEffect={0.03,0.06,0.09,0.12,0.15,0.18,0.21,0.24,0.27,0.30}, --对应实力的影响
		},
		s4={
			type=4,
			icon="WarBuffStatistician.png",
			lvLimit=10,
			effect={0.03,0.06,0.09,0.12,0.15,0.18,0.21,0.24,0.27,0.30}, --科技效果
			cost={80,80,80,80,80,80,80,80,80,80}, --金币花费
			successRate={100,90,80,70,60,50,40,30,20,10}, --成功几率
			powerEffect={0.03,0.06,0.09,0.12,0.15,0.18,0.21,0.24,0.27,0.30}, --对应实力的影响
		},
		s5={	--5 减少复活需要的回合
			type=5,
			icon="platWar_buff1.png",
			lvLimit=10,
			effect={1,2,3,4,5,6,7,8,9,10}, --科技效果
			cost={100,100,100,100,100,100,100,100,100,100}, --金币花费
			successRate={100,90,80,70,60,50,40,30,20,10}, --成功几率
			powerEffect={0.03,0.06,0.09,0.12,0.15,0.18,0.21,0.24,0.27,0.30}, --对应实力的影响
		},
		s6={	-- 6 减少每次连续作战的伤害减少
			type=6,
			icon="platWar_buff2.png",
			lvLimit=10,
			effect={0.97,0.94,0.91,0.88,0.85,0.82,0.79,0.76,0.73,0.7}, --科技效果
			cost={100,100,100,100,100,100,100,100,100,100}, --金币花费
			successRate={100,90,80,70,60,50,40,30,20,10}, --成功几率
			powerEffect={0.03,0.06,0.09,0.12,0.15,0.18,0.21,0.24,0.27,0.30}, --对应实力的影响
		},
	},

	 --战斗贡献排行榜
	battleRank={
		 --榜单人数
		maxNum=50,
		 --上榜要求
		limitNum=100,
		 --奖励内容
		reward={
			{range={1,1},reward={p={p866=200,p581=10000}},serverReward={props_p866=200},point=10000,}, --名次,奖励内容
			{range={2,2},reward={p={p866=150,p581=7000}},serverReward={props_p866=150},point=7000,},
			{range={3,5},reward={p={p866=100,p581=5000}},serverReward={props_p866=100},point=5000,},
			{range={6,10},reward={p={p866=70,p581=3000}},serverReward={props_p866=70},point=3000,},
			{range={11,20},reward={p={p866=50,p581=2000}},serverReward={props_p866=50},point=2000,},
			{range={21,50},reward={p={p866=30,p581=1500}},serverReward={props_p866=30},point=1500,},
		},
	},

	 --贡献实力排行榜
	pointRank={
		 --榜单人数
		maxNum=100,
		 --上榜要求
		limitNum=100,
		 --奖励内容
		reward={
			{range={1,1},reward={p={p601=100,p581=10000}},serverReward={props_p601=100},point=10000,}, --名次,奖励内容
			{range={2,2},reward={p={p601=70,p581=7000}},serverReward={props_p601=70},point=7000,},
			{range={3,5},reward={p={p601=50,p581=5000}},serverReward={props_p601=50},point=5000,},
			{range={6,10},reward={p={p601=40,p581=3000}},serverReward={props_p601=40},point=3000,},
			{range={11,20},reward={p={p601=30,p581=2000}},serverReward={props_p601=30},point=2000,},
			{range={21,50},reward={p={p601=25,p581=1500}},serverReward={props_p601=25},point=1500,},
			{range={51,100},reward={p={p601=20,p581=1000}},serverReward={props_p601=20},point=1000,},


		},
	},


	--最终胜利的奖励
	victoryReward={
		--该平台　３０及以上的玩家可以领取
		levelLimit=30,
		limitReward={
			q={p={{p679=1},{p20=20},{p448=20}}},
			h={props_p679=1,props_p20=20,props_p448=20}
		},
		--该平台　所有选手可以领取
		allReward={
			q={p={{p674=1},{p869=50},{p818=50}}},
			h={props_p674=1,props_p869=50,props_p818=50}
		},
		--该平日每日领取
		dailyReward={
			q={u={{r4=500000000},{gold=500000000}}},
			h={userinfo_r4=500000000,userinfo_gold=500000000}
		},
		--共计发放几天
		lastDays=5,
	},


	--最终失败的奖励
	failReward={
		--该平台　３０及以上的玩家可以领取
		levelLimit=30,
		limitReward={
			q={p={{p678=1},{p20=10},{p448=10}}},
			h={props_p678=1,props_p20=10,props_p448=10}
		},
		--该平台　所有选手可以领取
		allReward={
			q={p={{p674=1},{p869=20},{p818=20}}},
			h={props_p674=1,props_p869=20,props_p818=20}
		},
		--该平日每日领取
		dailyReward={
			q={u={{r4=200000000},{gold=200000000}}},
			h={userinfo_r4=200000000,userinfo_gold=200000000}
		},
		--共计发放几天
		lastDays=5,
	},

	--[跨国战商店]
	--pShop是普通商店
	--aShop是参赛商店
	--所有物品在本次跨国战之中均展示给玩家
	pShopItems=
	{
		i1={id="i1",buynum=100,price=5,reward={p={{p393=1}}},serverReward={props_p393=1}},
		i2={id="i2",buynum=100,price=5,reward={p={{p394=1}}},serverReward={props_p394=1}},
		i3={id="i3",buynum=100,price=5,reward={p={{p395=1}}},serverReward={props_p395=1}},
		i4={id="i4",buynum=100,price=5,reward={p={{p396=1}}},serverReward={props_p396=1}},
		i5={id="i5",buynum=2,price=200,reward={p={{p397=1}}},serverReward={props_p397=1}},
		i6={id="i6",buynum=2,price=200,reward={p={{p398=1}}},serverReward={props_p398=1}},
		i7={id="i7",buynum=2,price=200,reward={p={{p399=1}}},serverReward={props_p399=1}},
		i8={id="i8",buynum=2,price=200,reward={p={{p400=1}}},serverReward={props_p400=1}},
		i9={id="i9",buynum=20,price=10,reward={p={{p20=1}}},serverReward={props_p20=1}},
		i10={id="i10",buynum=3,price=500,reward={p={{p268=1}}},serverReward={props_p268=1}},
		i11={id="i11",buynum=3,price=2000,reward={p={{p269=1}}},serverReward={props_p269=1}},
		i12={id="i12",buynum=2,price=4000,reward={p={{p568=1}}},serverReward={props_p568=1}},
		i13={id="i13",buynum=2,price=2500,reward={p={{p183=1}}},serverReward={props_p183=1}},
		i14={id="i14",buynum=2,price=2500,reward={p={{p186=1}}},serverReward={props_p186=1}},
		i15={id="i15",buynum=2,price=2000,reward={p={{p195=1}}},serverReward={props_p195=1}},
		i16={id="i16",buynum=2,price=2000,reward={p={{p198=1}}},serverReward={props_p198=1}},
		i17={id="i17",buynum=2,price=2200,reward={p={{p207=1}}},serverReward={props_p207=1}},
		i18={id="i18",buynum=2,price=2200,reward={p={{p210=1}}},serverReward={props_p210=1}},
		i19={id="i19",buynum=2,price=2300,reward={p={{p219=1}}},serverReward={props_p219=1}},
		i20={id="i20",buynum=2,price=2300,reward={p={{p222=1}}},serverReward={props_p222=1}},
		i21={id="i21",buynum=1,price=3000,reward={p={{p189=1}}},serverReward={props_p189=1}},
		i22={id="i22",buynum=1,price=3000,reward={p={{p192=1}}},serverReward={props_p192=1}},
		i23={id="i23",buynum=1,price=2400,reward={p={{p201=1}}},serverReward={props_p201=1}},
		i24={id="i24",buynum=1,price=2400,reward={p={{p204=1}}},serverReward={props_p204=1}},
		i25={id="i25",buynum=1,price=2640,reward={p={{p213=1}}},serverReward={props_p213=1}},
		i26={id="i26",buynum=1,price=2640,reward={p={{p216=1}}},serverReward={props_p216=1}},
		i27={id="i27",buynum=1,price=2760,reward={p={{p225=1}}},serverReward={props_p225=1}},
		i28={id="i28",buynum=1,price=2760,reward={p={{p228=1}}},serverReward={props_p228=1}},
		i29={id="i29",buynum=2,price=5000,reward={p={{p230=1}}},serverReward={props_p230=1}},
	},
	aShopItems=
	{
		a1={id="a1",buynum=1,price=12000,reward={e={{p7=1}}},serverReward={accessory_p7=1}},
		a2={id="a2",buynum=2,price=4000,reward={p={{p90=1}}},serverReward={props_p90=1}},
		a3={id="a3",buynum=2,price=8000,reward={p={{p270=1}}},serverReward={props_p270=1}},
		a4={id="a4",buynum=3,price=2500,reward={p={{p183=1}}},serverReward={props_p183=1}},
		a5={id="a5",buynum=3,price=2500,reward={p={{p186=1}}},serverReward={props_p186=1}},
		a6={id="a6",buynum=3,price=2000,reward={p={{p195=1}}},serverReward={props_p195=1}},
		a7={id="a7",buynum=3,price=2000,reward={p={{p198=1}}},serverReward={props_p198=1}},
		a8={id="a8",buynum=3,price=2200,reward={p={{p207=1}}},serverReward={props_p207=1}},
		a9={id="a9",buynum=3,price=2200,reward={p={{p210=1}}},serverReward={props_p210=1}},
		a10={id="a10",buynum=3,price=2300,reward={p={{p219=1}}},serverReward={props_p219=1}},
		a11={id="a11",buynum=3,price=2300,reward={p={{p222=1}}},serverReward={props_p222=1}},
		a12={id="a12",buynum=2,price=3000,reward={p={{p189=1}}},serverReward={props_p189=1}},
		a13={id="a13",buynum=2,price=3000,reward={p={{p192=1}}},serverReward={props_p192=1}},
		a14={id="a14",buynum=2,price=2400,reward={p={{p201=1}}},serverReward={props_p201=1}},
		a15={id="a15",buynum=2,price=2400,reward={p={{p204=1}}},serverReward={props_p204=1}},
		a16={id="a16",buynum=2,price=2640,reward={p={{p213=1}}},serverReward={props_p213=1}},
		a17={id="a17",buynum=2,price=2640,reward={p={{p216=1}}},serverReward={props_p216=1}},
		a18={id="a18",buynum=2,price=2760,reward={p={{p225=1}}},serverReward={props_p225=1}},
		a19={id="a19",buynum=2,price=2760,reward={p={{p228=1}}},serverReward={props_p228=1}},
		a20={id="a20",buynum=2,price=3750,reward={p={{p354=1}}},serverReward={props_p354=1}},
		a21={id="a21",buynum=2,price=3750,reward={p={{p358=1}}},serverReward={props_p358=1}},
		a22={id="a22",buynum=2,price=3000,reward={p={{p362=1}}},serverReward={props_p362=1}},
		a23={id="a23",buynum=2,price=3000,reward={p={{p366=1}}},serverReward={props_p366=1}},
		a24={id="a24",buynum=2,price=3300,reward={p={{p370=1}}},serverReward={props_p370=1}},
		a25={id="a25",buynum=2,price=3300,reward={p={{p374=1}}},serverReward={props_p374=1}},
		a26={id="a26",buynum=2,price=3450,reward={p={{p378=1}}},serverReward={props_p378=1}},
		a27={id="a27",buynum=2,price=3450,reward={p={{p382=1}}},serverReward={props_p382=1}},
		a28={id="a28",buynum=5,price=5000,reward={p={{p230=1}}},serverReward={props_p230=1}},
	},
}

