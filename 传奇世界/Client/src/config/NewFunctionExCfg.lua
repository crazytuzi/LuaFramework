local Items=
{
	{id=1, school=1, delay=20, lvMin=3, lvMax=4, name="攻杀剑术", res=nil, effect="showSkill1002", effectNum=13, effectTime=1.6, effectOff=cc.p(0, -60), scale=1.2, content="战士初期神技。", detail="攻杀是非常实用的剑术，从这里开始，战士才开始向一名剑客迈进。"},
	{id=1, school=2, delay=20, lvMin=3, lvMax=4, name="雷电术", res=nil, effect="showSkill2002", effectNum=15, effectTime=1.6, effectOff=cc.p(0, -60), scale=1.2, content="法师初期神技。", detail="法师的初级电系攻击魔法。指尖发出微弱的电光，诱发天空落下一道巨大的闪电，直接劈向对手。"},
	{id=1, school=3, delay=20, lvMin=3, lvMax=4, name="灵魂道符", res=nil, effect="showSkill3002", effectNum=15, effectTime=1.6, effectOff=cc.p(0, -60), scale=1.2, content="道士初期神技。", detail="和火球术一样的远程法术，通过驱使护身符来攻击敌人。"},

	--{id=2, school=1, delay=10, lvMin=4, lvMax=6, itemId=2010401, name="", content="真正的勇士，欢迎回到传世的世界，请收下限量版传世布鞋。", detail="^c(orange)附加属性：^  \n物防：^c(lable_yellow)4-6^ "},
	--{id=2, school=2, delay=10, lvMin=4, lvMax=6, itemId=2020401, name="", content="真正的勇士，欢迎回到传世的世界，请收下限量版传世布鞋。", detail="^c(orange)附加属性：^  \n物防：^c(lable_yellow)4-6^^"},
	--{id=2, school=3, delay=10, lvMin=4, lvMax=6, itemId=2030401, name="", content="真正的勇士，欢迎回到传世的世界，请收下限量版传世布鞋。", detail="^c(orange)附加属性：^  \n物防：^c(lable_yellow)4-6^^"},

	{id=2, school=1, delay=25, lvMin=4, lvMax=10, itemId=2010301, name="", content="带上它，和你的兄弟一起踏上重建辉煌之路吧", detail="^c(orange)附加属性：^  \n物理攻击：^c(lable_yellow)14-21^"},
	{id=2, school=2, delay=25, lvMin=4, lvMax=10, itemId=2020301, name="", content="带上它，和你的兄弟一起踏上重建辉煌之路吧", detail="^c(orange)附加属性：^  \n魔法攻击：^c(lable_yellow)14-21^"},
	{id=2, school=3, delay=25, lvMin=4, lvMax=10, itemId=2030301, name="", content="带上它，和你的兄弟一起踏上重建辉煌之路吧", detail="^c(orange)附加属性：^  \n道术攻击：^c(lable_yellow)14-21^"},

	--{id=4, school=1, delay=15, lvMin=10, lvMax=13, itemId=2010201, name="", content="还记得那个经典的龙戒么？它见证了所有传世玩家的荣耀。", detail="^c(orange)附加属性：^      \n物攻：^c(lable_yellow)5-8^"},
	--{id=4, school=2, delay=15, lvMin=10, lvMax=13, itemId=2020201, name="", content="还记得那个经典的红宝戒指么？它见证了所有传世玩家的荣耀。", detail="^c(orange)附加属性：^  \n魔攻：^c(lable_yellow)5-8^"},
	--{id=4, school=3, delay=15, lvMin=10, lvMax=13, itemId=2030201, name="", content="还记得那个经典的白金戒指么？它见证了所有传世玩家的荣耀。", detail="^c(orange)附加属性：^  \n道攻：^c(lable_yellow)5-8^"},

	{id=3, school=1, delay=5, lvMin=10, lvMax=13, itemId=999998, num=100000, name="", content="使用可以获得10万金币", detail="可用于强化装备！"},
	{id=3, school=2, delay=5, lvMin=10, lvMax=13, itemId=999998, num=100000, name="", content="使用可以获得10万金币", detail="可用于强化装备！"},
	{id=3, school=3, delay=5, lvMin=10, lvMax=13, itemId=999998, num=100000, name="", content="使用可以获得10万金币", detail="可用于强化装备！"},

	--{id=4, school=1, delay=20, lvMin=13, lvMax=15, name="枣红马", res=nil, res="res/showplist/ride/1.png", effectNum=5, effectTime=1, scale=0.6, battle=24, content="好一匹骏马，平稳如船舷碧海，轻快似燕掠浮云。", detail="^c(orange)附加属性：^   \n物攻：^c(lable_yellow)2-5^ \n移动速度：^c(lable_yellow)23%^"},
	--{id=4, school=2, delay=20, lvMin=13, lvMax=15, name="枣红马", res=nil, res="res/showplist/ride/1.png", effectNum=5, effectTime=1, scale=0.6, battle=24, content="好一匹骏马，平稳如船舷碧海，轻快似燕掠浮云。", detail="^c(orange)附加属性：^  \n魔攻：^c(lable_yellow)2-5^   \n移动速度：^c(lable_yellow)23%^"},
	--{id=4, school=3, delay=20, lvMin=13, lvMax=15, name="枣红马", res=nil, res="res/showplist/ride/1.png", effectNum=5, effectTime=1, scale=0.6, battle=24, content="好一匹骏马，平稳如船舷碧海，轻快似燕掠浮云。", detail="^c(orange)附加属性：^  \n道术：^c(lable_yellow)2-5^    \n移动速度：^c(lable_yellow)23%^"},

	{id=4, school=1, delay=20, lvMin=13, lvMax=15, itemId=1001, num=50, name="", content="快速传送的必备道具", detail="自动寻路时点击可快速传送！"},
	{id=4, school=2, delay=20, lvMin=13, lvMax=15, itemId=1001, num=50, name="", content="快速传送的必备道具", detail="自动寻路时点击可快速传送！"},
	{id=4, school=3, delay=20, lvMin=13, lvMax=15, itemId=1001, num=50, name="", content="快速传送的必备道具", detail="自动寻路时点击可快速传送！"},

	{id=5, school=1, delay=20, lvMin=15, lvMax=21, itemId=1301, num=50, name="", content="强化装备的必备材料", detail="普通矿石，装备强化1-10级时消耗。"},
	{id=5, school=2, delay=20, lvMin=15, lvMax=21, itemId=1301, num=50, name="", content="强化装备的必备材料", detail="普通矿石，装备强化1-10级时消耗。"},
    {id=5, school=3, delay=20, lvMin=15, lvMax=21, itemId=1301, num=50, name="", content="强化装备的必备材料", detail="普通矿石，装备强化1-10级时消耗。"},
	
	--{id=6, school=1, delay=30, lvMin=21, lvMax=23, itemId=30004, name="勋章", content="勋章可以通过声望升级。", detail="佩戴勋章可以提升战斗力。"},
	--{id=6, school=2, delay=30, lvMin=21, lvMax=23, itemId=30005, name="勋章", content="勋章可以通过声望升级。", detail="佩戴勋章可以提升战斗力。"},
	--{id=6, school=3, delay=30, lvMin=21, lvMax=23, itemId=30006, name="勋章", content="勋章可以通过声望升级。", detail="佩戴勋章可以提升战斗力。"},
	
	{id=6, school=1, delay=30, lvMin=21, lvMax=23, itemId=20023, num=1, name="", content="持续性恢复药品", detail="使用后可持续恢复生命值和魔法值。"},
	{id=6, school=2, delay=30, lvMin=21, lvMax=23, itemId=20023, num=1, name="", content="持续性恢复药品", detail="使用后可持续恢复生命值和魔法值。"},
	{id=6, school=3, delay=30, lvMin=21, lvMax=23, itemId=20023, num=1, name="", content="持续性恢复药品", detail="使用后可持续恢复生命值和魔法值。"},

	--{id=9, school=1, delay=30, lvMin=23, lvMax=35, itemId=5110304, name="", content="圣战套装。象征着力量与和平的最终指引，在圣战中扼住恶魔的咽喉。", detail="^c(orange)附加属性：^  \n物理攻击：^c(lable_yellow)54-108^"},
	--{id=9, school=2, delay=30, lvMin=23, lvMax=35, itemId=5120304, name="", content="法神套装。出自掠夺而来的宝物中，充满灵力。", detail="^c(orange)附加属性：^  \n魔法攻击：^c(lable_yellow)54-108^"},
	--{id=9, school=3, delay=30, lvMin=23, lvMax=35, itemId=5130304, name="", content="天尊套装。无穷之力，惊为天人。", detail="^c(orange)附加属性：^  \n道术攻击：^c(lable_yellow)54-108^"},

	{id=7, school=1, delay=30, lvMin=23, lvMax=30, itemId=1452, num=20, name="", content="普通防具碎片", detail="打造防具必备材料！"},
	{id=7, school=2, delay=30, lvMin=23, lvMax=30, itemId=1452, num=20, name="", content="普通防具碎片", detail="打造防具必备材料！"},
	{id=7, school=3, delay=30, lvMin=23, lvMax=30, itemId=1452, num=20, name="", content="普通防具碎片", detail="打造防具必备材料！"},
	
	{id=8, school=1, delay=30, lvMin=30, lvMax=35, itemId=888888, num=200, name="绑定元宝", content="绑定元宝", detail="可用于在【绑元商城】购买物品"},
	{id=8, school=2, delay=30, lvMin=30, lvMax=35, itemId=888888, num=200, name="绑定元宝", content="绑定元宝", detail="可用于在【绑元商城】购买物品"},
	{id=8, school=3, delay=30, lvMin=30, lvMax=35, itemId=888888, num=200, name="绑定元宝", content="绑定元宝", detail="可用于在【绑元商城】购买物品"},

	-- {id=11, school=1, delay=30, lvMin=35, lvMax=41, name="冰晶之翼", effect="wing1", effectNum=5, effectTime=1, scale=1, battle=8200, content="从古至今，人们就渴望着拥有一双翅膀。", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)539^  \n法力：^c(lable_yellow)400^  \n物攻：^c(lable_yellow)120-239^  \n物防：^c(lable_yellow)46-92^  \n魔防：^c(lable_yellow)25-51^  \n"},
	-- {id=11, school=2, delay=30, lvMin=35, lvMax=41, name="冰晶之翼", effect="wing1", effectNum=5, effectTime=1, scale=1, battle=8200, content="从古至今，人们就渴望着拥有一双翅膀。", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)215^  \n法力：^c(lable_yellow)400^  \n魔攻：^c(lable_yellow)20-239^  \n物防：^c(lable_yellow)36-72^  \n魔防：^c(lable_yellow)48-96^  \n"},
	-- {id=11, school=3, delay=30, lvMin=35, lvMax=41, name="冰晶之翼", effect="wing1", effectNum=5, effectTime=1, scale=1, battle=8200, content="从古至今，人们就渴望着拥有一双翅膀。", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)359^  \n法力：^c(lable_yellow)400^  \n道术：^c(lable_yellow)20-239^  \n物防：^c(lable_yellow)42-83^  \n魔防：^c(lable_yellow)47-96^  \n"},

	-- {id=11, school=1, delay=30, lvMin=41, lvMax=42, name="元神", res=nil, effect="mrshow12", effectNum=5, effectTime=1, scale=0.8, battle=8200, content="元神，修炼后可给主人增加战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)539^  \n法力：^c(lable_yellow)400^  \n物攻：^c(lable_yellow)120-239^  \n物防：^c(lable_yellow)46-92^  \n魔防：^c(lable_yellow)25-51^  \n"},
	-- {id=11, school=2, delay=30, lvMin=41, lvMax=42, name="元神", res=nil, effect="mrshow12", effectNum=5, effectTime=1, scale=0.8, battle=8200, content="元神，修炼后可给主人增加战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)215^  \n法力：^c(lable_yellow)400^  \n魔攻：^c(lable_yellow)20-239^  \n物防：^c(lable_yellow)36-72^  \n魔防：^c(lable_yellow)48-96^  \n"},
	-- {id=11, school=3, delay=30, lvMin=41, lvMax=42, name="元神", res=nil, effect="mrshow12", effectNum=5, effectTime=1, scale=0.8, battle=8200, content="元神，修炼后可给主人增加战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)359^  \n法力：^c(lable_yellow)400^  \n道术：^c(lable_yellow)20-239^  \n物防：^c(lable_yellow)42-83^  \n魔防：^c(lable_yellow)47-96^  \n"},

	-- {id=12, school=1, delay=30, lvMin=42, lvMax=43, name="元神战刃-飞星", res=nil, effect="mrzhanren11", effectNum=14, effectTime=1.5, scale=1, battle=8200, content="元神华丽的武器，同时可给主人增加战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)539^  \n法力：^c(lable_yellow)400^  \n物攻：^c(lable_yellow)120-239^  \n物防：^c(lable_yellow)46-92^  \n魔防：^c(lable_yellow)25-51^  \n"},
	-- {id=12, school=2, delay=30, lvMin=42, lvMax=43, name="元神战刃-飞星", res=nil, effect="mrzhanren11", effectNum=14, effectTime=1.5, scale=1, battle=8200, content="元神华丽的武器，同时可给主人增加战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)215^  \n法力：^c(lable_yellow)400^  \n魔攻：^c(lable_yellow)20-239^  \n物防：^c(lable_yellow)36-72^  \n魔防：^c(lable_yellow)48-96^  \n"},
	-- {id=12, school=3, delay=30, lvMin=42, lvMax=43, name="元神战刃-飞星", res=nil, effect="mrzhanren11", effectNum=14, effectTime=1.5, scale=1, battle=8200, content="元神华丽的武器，同时可给主人增加战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)359^  \n法力：^c(lable_yellow)400^  \n道术：^c(lable_yellow)20-239^  \n物防：^c(lable_yellow)42-83^  \n魔防：^c(lable_yellow)47-96^  \n"},

	-- {id=14, school=1, lvMin=41, lvMax=43, itemId=9201, name="", content="记录武道典籍的书册，玛法大陆勇士梦寐以求的东西", detail="战士被动技能，可以永久提升物理攻击"},
	-- {id=14, school=2, lvMin=41, lvMax=43, itemId=9202, name="", content="记录武道典籍的书册，玛法大陆勇士梦寐以求的东西", detail="法师被动技能，可以永久提升魔法攻击"},
	-- {id=14, school=3, lvMin=41, lvMax=43, itemId=9203, name="", content="记录武道典籍的书册，玛法大陆勇士梦寐以求的东西", detail="道士被动技能，可以永久提升道术攻击"},

	-- {id=13, school=1, delay=30, lvMin=43, lvMax=46, name="元神战甲-心月", res=nil, effect="mrshow12", effectNum=5, effectTime=1, scale=0.8, battle=8200, content="元神华丽的战甲，同时可给主人增加战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)539^  \n法力：^c(lable_yellow)400^  \n物攻：^c(lable_yellow)120-239^  \n物防：^c(lable_yellow)46-92^  \n魔防：^c(lable_yellow)25-51^  \n"},
	-- {id=13, school=2, delay=30, lvMin=43, lvMax=46, name="元神战甲-心月", res=nil, effect="mrshow12", effectNum=5, effectTime=1, scale=0.8, battle=8200, content="元神华丽的战甲，同时可给主人增加战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)215^  \n法力：^c(lable_yellow)400^  \n魔攻：^c(lable_yellow)20-239^  \n物防：^c(lable_yellow)36-72^  \n魔防：^c(lable_yellow)48-96^  \n"},
	-- {id=13, school=3, delay=30, lvMin=43, lvMax=46, name="元神战甲-心月", res=nil, effect="mrshow12", effectNum=5, effectTime=1, scale=0.8, battle=8200, content="元神华丽的战甲，同时可给主人增加战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)359^  \n法力：^c(lable_yellow)400^  \n道术：^c(lable_yellow)20-239^  \n物防：^c(lable_yellow)42-83^  \n魔防：^c(lable_yellow)47-96^  \n"},

	-- {id=14, school=1, delay=30, lvMin=46, lvMax=52, name="元婴", res=nil, effect="babyPeriod1", effectOff=cc.p(0, -40), effectNum=14, effectTime=1, scale=0.6, battle=5000, content="修炼元婴可给主人增加各种属性与战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)472^  \n物攻：^c(lable_yellow)105-210^  \n物防：^c(lable_yellow)40-80^  \n魔防：^c(lable_yellow)22-45^  \n"},
	-- {id=14, school=2, delay=30, lvMin=46, lvMax=52, name="元婴", res=nil, effect="babyPeriod1", effectOff=cc.p(0, -40), effectNum=14, effectTime=1, scale=0.6, battle=5000, content="修炼元婴可给主人增加各种属性与战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)189^  \n魔攻：^c(lable_yellow)105-210^  \n物防：^c(lable_yellow)31-63^  \n魔防：^c(lable_yellow)42-84^  \n"},
	-- {id=14, school=3, delay=30, lvMin=46, lvMax=52, name="元婴", res=nil, effect="babyPeriod1", effectOff=cc.p(0, -40), effectNum=14, effectTime=1, scale=0.6, battle=5000, content="修炼元婴可给主人增加各种属性与战斗力", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)315^  \n道术：^c(lable_yellow)105-210^  \n物防：^c(lable_yellow)36-73^  \n魔防：^c(lable_yellow)42-83^  \n"},

	-- {id=15, school=1, delay=30, lvMin=52, lvMax=54, name="元婴炼神", res=nil, effect="babyPeriod5", effectOff=cc.p(0, -40), effectNum=14, effectTime=1, scale=0.6, battle=1300, content="元婴炼神，可改变元婴品质，元婴品质越高，附加给主人的属性越多", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)135^  \n物攻：^c(lable_yellow)30-60^  \n物防：^c(lable_yellow)11-23^  \n魔防：^c(lable_yellow)6-13^  \n"},
	-- {id=15, school=2, delay=30, lvMin=52, lvMax=54, name="元婴炼神", res=nil, effect="babyPeriod5", effectOff=cc.p(0, -40), effectNum=14, effectTime=1, scale=0.6, battle=1300, content="元婴炼神，可改变元婴品质，元婴品质越高，附加给主人的属性越多", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)54^  \n魔攻：^c(lable_yellow)30-60^  \n物防：^c(lable_yellow)9-18^  \n魔防：^c(lable_yellow)12-24^  \n"},
	-- {id=15, school=3, delay=30, lvMin=52, lvMax=54, name="元婴炼神", res=nil, effect="babyPeriod5", effectOff=cc.p(0, -40), effectNum=14, effectTime=1, scale=0.6, battle=1300, content="元婴炼神，可改变元婴品质，元婴品质越高，附加给主人的属性越多", detail="^c(orange)附加属性：^  \n生命：^c(lable_yellow)90^  \n道术：^c(lable_yellow)30-60^  \n物防：^c(lable_yellow)10-21^  \n魔防：^c(lable_yellow)10-21^  \n"},
}

return Items