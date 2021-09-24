--战斗buff的配置
buffEffectCfg=
{
	--name: 名字
	--icon: 带边框的图标
	--icon2: 不带边框的图标
	--伤害
	[99]={id=100,key='dmage',name='property_dmage',icon="pro_ship_attack.png",icon2="refiningAtkIcon.png",index=0},
	--攻击力
	[100]={id=100,key='dmg',name='property_dmg',icon="pro_ship_attack.png",icon2="refiningAtkIcon.png",index=1},
	--精准
	[102]={id=102,key='accuracy',name='property_accuracy',icon="skill_01.png",icon2="buffIcon102.png",index=5},
	--闪避
	[103]={id=103,key='evade',name='property_evade',icon="skill_02.png",icon2="buffIcon103.png",index=6},
	--104到107是两两相同的, 历史遗留问题, 用哪个都可以
	--暴击
	[104]={id=104,key='crit',name='property_crit',icon="skill_03.png",icon2="buffIcon104.png",index=7},
	--装甲
	[105]={id=105,key='anticrit',name='property_anticrit',icon="skill_04.png",icon2="buffIcon105.png",index=9},
	--暴击
	[106]={id=106,key='crit',name='property_crit',icon="skill_03.png",icon2="buffIcon104.png",index=8},
	--装甲
	[107]={id=107,key='anticrit',name='property_anticrit',icon="skill_04.png",icon2="buffIcon105.png",index=10},
	--血量
	[108]={id=108,key='maxhp',name='property_maxhp',icon="pro_ship_life.png",icon2="refiningLifeIcon.png",index=2},
	--减伤
	[109]={id=109,key='dmg_reduce',name='property_dmg_reduce',index=13},
	--暴伤
	[110]={id=110,key='critDmg',name='property_critDmg',icon="skill_110.png",icon2="buffIcon110.png",index=11},
	--韧性
	[111]={id=111,key='decritDmg',name='property_decritDmg',icon="skill_111.png",icon2="buffIcon111.png",index=12},
	--防护
	[201]={id=201,key='armor',name='property_armor',icon="attributeArmor.png",icon2="refiningDefIcon.png",index=3},
	--击破
	[202]={id=202,key='arp',name='property_arp',icon="attributeARP.png",icon2="refiningPenIcon.png",index=4},
	-- 生产加速
	[200]={id=200,key='produceUp',name='property_produceUp'},
	-- 对坦克伤害加成
	[211]={id=211,key='tankAdd',name='property_tankAdd'},
	-- 对歼击车伤害加成
	[212]={id=212,key='jianjicheAdd',name='property_jianjicheAdd'},
	-- 对自行火炮伤害加成
	[213]={id=213,key='huopaoAdd',name='property_huopaoAdd'},
	-- 对火箭车伤害加成
	[214]={id=214,key='huojiancheAdd',name='property_huojiancheAdd'},
	-- 减少受到坦克伤害
	[221]={id=221,key='tankSub',name='property_tankSub'},
	-- 减少受到歼击车伤害
	[222]={id=222,key='jianjicheSub',name='property_jianjicheSub'},
	-- 减少受到自行火炮伤害
	[223]={id=223,key='huopaoSub',name='property_huopaoSub'},
	-- 减少受到火箭车伤害
	[224]={id=224,key='huojiancheSub',name='property_huojiancheSub'},
	--增加先手值
	[225]={id=225,key='first',name='property_first',icon2="buffIcon225.png",index=14},
	--增加带兵量
	[226]={id=226,key='add',name='property_add',icon2="buffIcon226.png",index=15},
	--减少对方先手值
	[227]={id=227,key='antifirst',name='property_antifirst',index=13},

	--以下是成长相关buff
	--行军加速
	[301]={id=301,key='moveSpeed',name='property_moveSpeed',index=301},
	--采集加速
	[302]={id=302,key='colloctSpeed',name='property_colloctSpeed',index=302},
	--资源生产速度提升
	[303]={id=303,key='madeSpeed',name='property_madeSpeed',index=303},
	--科研加速
	[304]={id=304,key='studySpeed',name='property_studySpeed',index=304},
	--加速建筑速度
	[305]={id=305,key='buildSpeed',name='property_buildSpeed',index=305},
	--增加军团城市个人荣耀采集上限
	[306]={id=306,key='honourLimit',name='property_honourLimit',index=306},
	--加速战机革新技能研究速度
	[307]={id=307,key='pNewSpeed',name='property_pNewSpeed',index=307},
	--增加坦克生产速度
	[308]={id=308,key='productTankSpeed',name='property_productTankSpeed',index=308},
	--增加坦克改造速度
	[309]={id=309,key='refitTankSpeed',name='property_refitTankSpeed',index=309},
	--军功加成
	[310]={id=310,key='jg',name='jgStr',index=310},
	--玩家经验加成
	[311]={id=311,key='exp',name='playerExpAddStr',index=311},
	-- 其它对应名字
	[1001]={name='sample_tech_name_24'}
}

buffKeyMatchCodeCfg={
	dmage=99,
	dmg=100,
	accuracy=102,
	evade=103,
	crit=104,
	anticrit=105,
	crit=106,
	anticrit=107,
	maxhp=108,
	dmg_reduce=109,
	critDmg=110,
	decritDmg=111,
	armor=201,
	arp=202,
	produceUp=200,
	tankAdd=211,
	jianjicheAdd=212,
	huopaoAdd=213,
	huojiancheAdd=214,
	tankSub=221,
	jianjicheSub=222,
	huopaoSub=223,
	huojiancheSub=224,
	first=225,
	add=226,
	antifirst=227,
	moveSpeed=301,
	colloctSpeed=302,
	collect=302,
	madeSpeed=303,
	studySpeed=304,
	buildSpeed=305,
	honourLimit=306,
	pNewSpeed=307,
	hp=108,
	troopsAdd=226,
	productTankSpeed=308,
	refitTankSpeed=309,
	jg=310,
	exp=311,
	load=1001
}
--当一堆buff同时出现的时候的排序
buffOrderCfg={100,108,201,202,102,103,104,106,105,107,110,111}