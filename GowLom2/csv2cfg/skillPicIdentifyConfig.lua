local skillPicIdentifyConfig = {
	{
		skillName = "基本剑术",
		skillEffect = "被动技能，提高自身准确。",
		skillDescribe = "lv1需要等级:7，需要技能熟练度：50;lv2需要等级:11，需要技能熟练度：150;lv3需要等级:16，需要技能熟练度：300;提升技能熟练度：使用普攻",
		skillIdent = 3,
		skillBookSource = "需要技能书：基本剑术;1、书店老板处购买。",
		skillType = 1,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "攻杀剑术",
		skillEffect = "被动技能，增加自身准确，攻击时对目标造成额外伤害。",
		skillDescribe = "lv1需要等级:19，需要技能熟练度：200;lv2需要等级:22，需要技能熟练度：400;lv3需要等级:24，需要技能熟练度：800;提升技能熟练度：使用普攻",
		skillIdent = 7,
		skillBookSource = "需要技能书：攻杀剑术;1、书店老板处购买。",
		skillType = 1,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "刺杀剑术",
		skillEffect = "主动技能，技能开启后对刺杀目标造成额外伤害，对隔位目标造成较弱伤害；刺杀剑气将无视敌人的防御；可以受到随影剑法的加成。",
		skillDescribe = "lv1需要等级:25，需要技能熟练度：300;lv2需要等级:27，需要技能熟练度：600;lv3需要等级:29，需要技能熟练度：900;提升技能熟练度：使用刺杀剑术，并攻击隔位目标",
		skillIdent = 12,
		skillBookSource = "需要技能书：刺杀剑术;1、书店老板处购买。",
		skillType = 1,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "半月弯刀",
		skillEffect = "主动技能，技能开启后对环绕自身周围的目标造成剑气伤害；可以受到随影剑法的加成。",
		skillDescribe = "lv1需要等级:28，需要技能熟练度：400;lv2需要等级:31，需要技能熟练度：800;lv3需要等级:34，需要技能熟练度：1200;提升技能熟练度：使用半月弯刀",
		skillIdent = 25,
		skillBookSource = "需要技能书：半月弯刀;1、书店老板处购买。",
		skillType = 1,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "野蛮冲撞",
		skillEffect = "主动技能，用肩膀把目标撞开，如果撞到障碍物将会对自己造成伤害；能够推动等级低于自己的敌方，野蛮冲撞达到3级后能推动同级别敌方；野蛮冲撞达到3级后可以推动2格位置的敌方。",
		skillDescribe = "lv1需要等级:30，需要技能熟练度：800;lv2需要等级:34，需要技能熟练度：1600;lv3需要等级:39，需要技能熟练度：2400;提升技能熟练度：使用野蛮冲撞，并成功撞击敌方",
		skillIdent = 27,
		skillBookSource = "需要技能书：野蛮冲撞;1、书店老板处购买。",
		skillType = 1,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "烈火剑法",
		skillEffect = "主动技能，召唤火精灵附在武器上，对目标造成大量伤害；可以受到随影剑法的加成。",
		skillDescribe = "lv1需要等级:35，需要技能熟练度：300;lv2需要等级:39，需要技能熟练度：600;lv3需要等级:43，需要技能熟练度：1000;提升技能熟练度：使用烈火剑法",
		skillIdent = 26,
		skillBookSource = "需要技能书：烈火剑法;1、击败精英怪有几率获得；;2、击败首领有几率获得；;3、元宝行购买；;4、刷书；;5、藏经峡谷。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "4级烈火剑法",
		skillEffect = "主动技能，使用技能书提升至lv4的烈火剑法。",
		skillDescribe = "lv4需要等级:55;",
		skillIdent = 26,
		skillBookSource = "需要技能书：4级烈火剑法;1、皇家大学士处消耗3点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "5级烈火剑法",
		skillEffect = "主动技能，使用技能书提升至lv5的烈火剑法。",
		skillDescribe = "lv5需要等级:68;",
		skillIdent = 26,
		skillBookSource = "需要技能书：5级烈火剑法;1、皇家大学士处消耗5点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "6级烈火剑法",
		skillEffect = "主动技能，使用技能书提升至lv6的烈火剑法。",
		skillDescribe = "lv6需要等级:85;",
		skillIdent = 26,
		skillBookSource = "需要技能书：6级烈火剑法;1、皇家大学士处消耗8点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "狮子吼",
		skillEffect = "主动技能，强烈的吼叫可以使周围的怪物暂时麻痹，无法麻痹人物",
		skillDescribe = "lv1需要等级:38，需要技能熟练度：500;lv2需要等级:41，需要技能熟练度：800;lv3需要等级:44，需要技能熟练度：1200;提升技能熟练度：使用狮子吼，并成功麻痹敌方",
		skillIdent = 43,
		skillBookSource = "需要技能书：狮子吼;1、击败精英怪有几率获得；;2、击败首领有几率获得；;3、元宝行购买；;4、刷书；;5、藏经峡谷。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "逐日剑法",
		skillEffect = "主动技能，剑气凝聚成形，瞬间化作一道光影，突袭前方直线上目标造成大量伤害；目标越远伤害越低；可以受到随影剑法的加成。",
		skillDescribe = "lv1需要等级:47，需要技能熟练度：1000;lv2需要等级:52，需要技能熟练度：2000;lv3需要等级:59，需要技能熟练度：4000;提升技能熟练度：使用逐日剑法",
		skillIdent = 58,
		skillBookSource = "需要技能书：逐日剑法;1、皇家大学士处消耗1000贡献度及2点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "4级逐日剑法",
		skillEffect = "主动技能，使用技能书提升至lv4的逐日剑法。",
		skillDescribe = "lv4需要等级:75;",
		skillIdent = 58,
		skillBookSource = "需要技能书：4级逐日剑法;1、皇家大学士处消耗1000贡献度及3点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "5级逐日剑法",
		skillEffect = "主动技能，使用技能书提升至lv5的逐日剑法。",
		skillDescribe = "lv5需要等级:95;",
		skillIdent = 58,
		skillBookSource = "需要技能书：5级逐日剑法;1、皇家大学士处消耗1000贡献度及4点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "6级逐日剑法",
		skillEffect = "主动技能，使用技能书提升至lv6的逐日剑法。",
		skillDescribe = "lv6需要等级:1转15级;",
		skillIdent = 58,
		skillBookSource = "需要技能书：6级逐日剑法;1、皇家大学士处消耗1000贡献度及5点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "0级随影剑法",
		skillEffect = "被动技能，通过增加对剑术能力的掌握，永久提高主动伤害技能的效果；包括普通攻击、刺杀剑术、半月弯刀、烈火剑法、逐日剑法。",
		skillDescribe = "lv0需要等级：1转35级;",
		skillIdent = 60,
		skillBookSource = "需要技能书：随影剑法;1、皇家大学士处消耗2000贡献度及158点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "1级随影剑法",
		skillEffect = "被动技能，使用技能书提升至lv1的随影剑法。",
		skillDescribe = "lv1需要等级:1转55级;",
		skillIdent = 60,
		skillBookSource = "需要技能书：1级随影剑法;1、皇家大学士处消耗3000贡献度及218点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "2级随影剑法",
		skillEffect = "被动技能，使用技能书提升至lv2的随影剑法。",
		skillDescribe = "lv2需要等级:1转75级;",
		skillIdent = 60,
		skillBookSource = "需要技能书：2级随影剑法;1、皇家大学士处消耗4000贡献度及288点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "3级随影剑法",
		skillEffect = "被动技能，使用技能书提升至lv3的随影剑法。",
		skillDescribe = "lv3需要等级:2转1级;",
		skillIdent = 60,
		skillBookSource = "需要技能书：3级随影剑法;1、皇家大学士处消耗5000贡献度及368点阅历值兑换。",
		skillType = 2,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "0级追心刺",
		skillEffect = "主动技能，冲撞前方目标，能够推动等级低于自己60级的敌人1格，造成大量伤害的同时可回复自身体力，可以受到随影剑法的加成。",
		skillDescribe = "lv0需要等级：1转5级;",
		skillIdent = 63,
		skillBookSource = "需要技能书：追心刺;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗100秘籍点兑换。",
		skillType = 2,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "1级追心刺",
		skillEffect = "主动技能，使用技能书提升至lv1的追心刺；能够推动等级低于自己50级的敌人1格。",
		skillDescribe = "lv1需要等级:1转20级;",
		skillIdent = 63,
		skillBookSource = "需要技能书：1级追心刺;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗500秘籍点兑换。",
		skillType = 2,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "2级追心刺",
		skillEffect = "主动技能，使用技能书提升至lv2的追心刺；能够推动等级低于自己40级的敌人1格。",
		skillDescribe = "lv2需要等级:1转50级;",
		skillIdent = 63,
		skillBookSource = "需要技能书：2级追心刺;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗1500秘籍点兑换。",
		skillType = 2,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "3级追心刺",
		skillEffect = "主动技能，使用技能书提升至lv3的追心刺；能够推动等级低于自己30级的敌人1格。",
		skillDescribe = "lv3需要等级:2转5级;",
		skillIdent = 63,
		skillBookSource = "需要技能书：3级追心刺;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗2500秘籍点兑换。",
		skillType = 2,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "4级追心刺",
		skillEffect = "主动技能，使用技能书提升至lv4的追心刺；能够推动等级低于自己15级的敌人1格。",
		skillDescribe = "lv4需要等级:2转50级;",
		skillIdent = 63,
		skillBookSource = "需要技能书：4级追心刺;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗4000秘籍点兑换。",
		skillType = 2,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "5级追心刺",
		skillEffect = "主动技能，使用技能书提升至lv5的追心刺；能够推动等级低于自己的敌人1格。",
		skillDescribe = "lv5需要等级:3转15级;",
		skillIdent = 63,
		skillBookSource = "需要技能书：5级追心刺;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗6000秘籍点兑换。",
		skillType = 2,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "6级追心刺",
		skillEffect = "主动技能，使用技能书提升至lv6的追心刺；能够推动同等级的敌人2格。",
		skillDescribe = "lv6需要等级:3转30级;",
		skillIdent = 63,
		skillBookSource = "需要技能书：6级追心刺;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗9000秘籍点兑换。",
		skillType = 2,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "火球术",
		skillEffect = "主动技能，凝聚自身魔力发射一枚火球攻击目标造成伤害；对怪物造成额外伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:7，需要技能熟练度：50;lv2需要等级:11，需要技能熟练度：150;lv3需要等级:16，需要技能熟练度：300;提升技能熟练度：使用火球术",
		skillIdent = 1,
		skillBookSource = "需要技能书：火球术;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "抗拒火环",
		skillEffect = "主动技能，可以将身边的人或者怪兽推开；能够推动等级低于自己的敌方，抗拒火环达到3级后能推动同级别敌方。",
		skillDescribe = "lv1需要等级:12，需要技能熟练度：800;lv2需要等级:15，需要技能熟练度：1600;lv3需要等级:19，需要技能熟练度：2400;提升技能熟练度：使用抗拒火环，并成功击退敌方",
		skillIdent = 8,
		skillBookSource = "需要技能书：抗拒火环;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "诱惑之光",
		skillEffect = "主动技能，通过闪光电击使目标瘫痪，甚至可以使怪物成为忠实的仆人。",
		skillDescribe = "lv1需要等级:13，需要技能熟练度：1000;lv2需要等级:18，需要技能熟练度：2000;lv3需要等级:24，需要技能熟练度：4000;提升技能熟练度：使用诱惑之光",
		skillIdent = 20,
		skillBookSource = "需要技能书：诱惑之光;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "地狱火",
		skillEffect = "主动技能，向前挥出一堵火焰墙，使法术区域内的目标受到伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:16，需要技能熟练度：100;lv2需要等级:21，需要技能熟练度：400;lv3需要等级:26，需要技能熟练度：800;提升技能熟练度：使用地狱火",
		skillIdent = 9,
		skillBookSource = "需要技能书：地狱火;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "雷电术",
		skillEffect = "主动技能，从空中召唤一道雷电攻击目标造成伤害；对怪物造成额外伤害，如怪物是不死系，则更甚；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:17，需要技能熟练度：120;lv2需要等级:39，需要技能熟练度：300;lv3需要等级:43，需要技能熟练度：500;提升技能熟练度：使用雷电术",
		skillIdent = 11,
		skillBookSource = "需要技能书：雷电术;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "大火球",
		skillEffect = "主动技能，凝聚自身魔力发射一枚大火球攻击目标造成大量伤害；对怪物造成额外伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:19，需要技能熟练度：800;lv2需要等级:23，需要技能熟练度：1400;lv3需要等级:25，需要技能熟练度：2000;提升技能熟练度：使用大火球",
		skillIdent = 5,
		skillBookSource = "需要技能书：大火球;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "瞬息移动",
		skillEffect = "主动技能，利用强大魔力打乱空间，从而达到随机传送目的的法术。",
		skillDescribe = "lv1需要等级:19，需要技能熟练度：1000;lv2需要等级:22，需要技能熟练度：2000;lv3需要等级:25，需要技能熟练度：4000;提升技能熟练度：成功使用瞬息移动",
		skillIdent = 21,
		skillBookSource = "需要技能书：瞬息移动;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "爆裂火焰",
		skillEffect = "主动技能，产生高热的火焰，使法术区域内的目标受到大量伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:22，需要技能熟练度：300;lv2需要等级:27，需要技能熟练度：600;lv3需要等级:31，需要技能熟练度：1800;提升技能熟练度：使用爆裂火焰",
		skillIdent = 23,
		skillBookSource = "需要技能书：爆裂火焰;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "火墙",
		skillEffect = "主动技能，在地面上产生火焰，使踏入的目标持续受到伤害。",
		skillDescribe = "lv1需要等级:24，需要技能熟练度：400;lv2需要等级:29，需要技能熟练度：800;lv3需要等级:33，需要技能熟练度：1600;提升技能熟练度：使用火墙",
		skillIdent = 22,
		skillBookSource = "需要技能书：火墙;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "疾光电影",
		skillEffect = "主动技能，积蓄一道光电，使直线上所有目标受到大量伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:26，需要技能熟练度：300;lv2需要等级:29，需要技能熟练度：600;lv3需要等级:32，需要技能熟练度：1200;提升技能熟练度：使用疾光电影",
		skillIdent = 10,
		skillBookSource = "需要技能书：疾光电影;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "地狱雷光",
		skillEffect = "主动技能，呼唤强力雷光风暴，对所有围在身边的目标造成伤害；对不死系怪物造成大量额外伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:30，需要技能熟练度：400;lv2需要等级:32，需要技能熟练度：800;lv3需要等级:34，需要技能熟练度：1200;提升技能熟练度：使用地狱雷光",
		skillIdent = 24,
		skillBookSource = "需要技能书：地狱雷光;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "魔法盾",
		skillEffect = "主动技能，使用自身魔力制造一个魔法盾减少自身受到的伤害；不可减少刺杀剑术的伤害。",
		skillDescribe = "lv1需要等级:31，需要技能熟练度：300;lv2需要等级:34，需要技能熟练度：600;lv3需要等级:38，需要技能熟练度：900;提升技能熟练度：使用魔法盾",
		skillIdent = 31,
		skillBookSource = "需要技能书：魔法盾;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "圣言术",
		skillEffect = "主动技能，有机率一击败死不死生物。",
		skillDescribe = "lv1需要等级:32，需要技能熟练度：400;lv2需要等级:35，需要技能熟练度：800;lv3需要等级:39，需要技能熟练度：1200;提升技能熟练度：使用圣言术，并成功消灭怪物",
		skillIdent = 32,
		skillBookSource = "需要技能书：圣言术;1、书店老板处购买。",
		skillType = 3,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "4级雷电术",
		skillEffect = "主动技能，使用技能书提升至lv4的雷电术。",
		skillDescribe = "lv4需要等级:55;",
		skillIdent = 11,
		skillBookSource = "需要技能书：4级雷电术;1、皇家大学士处消耗3点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "5级雷电术",
		skillEffect = "主动技能，使用技能书提升至lv5的雷电术。",
		skillDescribe = "lv5需要等级:68;",
		skillIdent = 11,
		skillBookSource = "需要技能书：5级雷电术;1、皇家大学士处消耗5点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "6级雷电术",
		skillEffect = "主动技能，使用技能书提升至lv6的雷电术。",
		skillDescribe = "lv6需要等级:85;",
		skillIdent = 11,
		skillBookSource = "需要技能书：6级雷电术;1、皇家大学士处消耗8点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "冰咆哮",
		skillEffect = "主动技能，召唤强力的暴风雪，使法术区域内的目标受到大量伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:35，需要技能熟练度：400;lv2需要等级:39，需要技能熟练度：800;lv3需要等级:43，需要技能熟练度：1200;提升技能熟练度：使用冰咆哮",
		skillIdent = 33,
		skillBookSource = "需要技能书：冰咆哮;1、击败精英怪有几率获得；;2、击败首领有几率获得；;3、元宝行购买；;4、刷书；;5、藏经峡谷。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "寒冰掌",
		skillEffect = "主动技能，产生巨大的魔力推力，对目标造成大量伤害；对怪物造成额外伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:36，需要技能熟练度：300;lv2需要等级:39，需要技能熟练度：600;lv3需要等级:41，需要技能熟练度：1200;提升技能熟练度：使用寒冰掌",
		skillIdent = 39,
		skillBookSource = "需要技能书：寒冰掌;1、击败精英怪有几率获得；;2、击败首领有几率获得；;3、元宝行购买；;4、刷书；;5、藏经峡谷。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "灭天火",
		skillEffect = "主动技能，召唤天火，使单个目标受到伤害的同时扣除其魔力值；对怪物和人造成额外伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:38，需要技能熟练度：500;lv2需要等级:41，需要技能熟练度：800;lv3需要等级:44，需要技能熟练度：1400;提升技能熟练度：使用灭天火",
		skillIdent = 35,
		skillBookSource = "需要技能书：灭天火;1、击败精英怪有几率获得；;2、击败首领有几率获得；;3、元宝行购买；;4、刷书；;5、藏经峡谷。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "流星火雨",
		skillEffect = "主动技能，召唤一阵猛烈的火雨，使法术区域内的目标受到伤害；可以受到随风术的加成。",
		skillDescribe = "lv1需要等级:47，需要技能熟练度：1000;lv2需要等级:52，需要技能熟练度：2000;lv3需要等级:59，需要技能熟练度：4000;提升技能熟练度：使用流星火雨",
		skillIdent = 59,
		skillBookSource = "需要技能书：流星火雨;1、皇家大学士处消耗1000贡献度及2点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "4级流星火雨",
		skillEffect = "主动技能，使用技能书提升至lv4的流星火雨。",
		skillDescribe = "lv4需要等级:75;",
		skillIdent = 59,
		skillBookSource = "需要技能书：4级流星火雨;1、皇家大学士处消耗1000贡献度及3点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "5级流星火雨",
		skillEffect = "主动技能，使用技能书提升至lv5的流星火雨。",
		skillDescribe = "lv5需要等级:95;",
		skillIdent = 59,
		skillBookSource = "需要技能书：5级流星火雨;1、皇家大学士处消耗1000贡献度及4点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "6级流星火雨",
		skillEffect = "主动技能，使用技能书提升至lv6的流星火雨。",
		skillDescribe = "lv6需要等级:1转15级;",
		skillIdent = 59,
		skillBookSource = "需要技能书：6级流星火雨;1、皇家大学士处消耗1000贡献度及5点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "0级随风术",
		skillEffect = "被动技能，通过增加对法术释放的掌握，永久提高主动伤害技能的效果；包括火球术、地狱火、雷电术、大火球、爆裂火焰、冰咆哮、寒冰掌、灭天火、流星火雨。",
		skillDescribe = "lv0需要等级：1转35级;",
		skillIdent = 61,
		skillBookSource = "需要技能书：随风术;1、皇家大学士处消耗2000贡献度及158点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "1级随风术",
		skillEffect = "被动技能，使用技能书提升至lv1的随风术。",
		skillDescribe = "lv1需要等级:1转55级;",
		skillIdent = 61,
		skillBookSource = "需要技能书：1级随风术;1、皇家大学士处消耗3000贡献度及218点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "2级随风术",
		skillEffect = "被动技能，使用技能书提升至lv2的随风术。",
		skillDescribe = "lv2需要等级:1转75级;",
		skillIdent = 61,
		skillBookSource = "需要技能书：2级随风术;1、皇家大学士处消耗4000贡献度及288点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "3级随风术",
		skillEffect = "被动技能，使用技能书提升至lv3的随风术。",
		skillDescribe = "lv3需要等级:2转1级;",
		skillIdent = 61,
		skillBookSource = "需要技能书：3级随风术;1、皇家大学士处消耗5000贡献度及368点阅历值兑换。",
		skillType = 4,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "0级冰天雪地",
		skillEffect = "主动技能，蓄力重击瞬间冻裂地面，形成冰刺，对锁定的目标及目标周围敌人造成伤害；并有一定几率推动等级低于自己60级的敌人；可以受到随风术的加成。",
		skillDescribe = "lv0需要等级：1转5级;",
		skillIdent = 64,
		skillBookSource = "需要技能书：冰天雪地;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗100秘籍点兑换。",
		skillType = 4,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "1级冰天雪地",
		skillEffect = "主动技能，使用技能书提升至lv1的冰天雪地；有几率推动等级低于自己50级的敌人。",
		skillDescribe = "lv1需要等级:1转20级;",
		skillIdent = 64,
		skillBookSource = "需要技能书：1级冰天雪地;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗500秘籍点兑换。",
		skillType = 4,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "2级冰天雪地",
		skillEffect = "主动技能，使用技能书提升至lv2的冰天雪地；有几率推动等级低于自己40级的敌人。",
		skillDescribe = "lv2需要等级:1转50级;",
		skillIdent = 64,
		skillBookSource = "需要技能书：2级冰天雪地;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗1500秘籍点兑换。",
		skillType = 4,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "3级冰天雪地",
		skillEffect = "主动技能，使用技能书提升至lv3的冰天雪地；有几率推动等级低于自己30级的敌人。",
		skillDescribe = "lv3需要等级:2转5级;",
		skillIdent = 64,
		skillBookSource = "需要技能书：3级冰天雪地;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗2500秘籍点兑换。",
		skillType = 4,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "4级冰天雪地",
		skillEffect = "主动技能，使用技能书提升至lv4的冰天雪地；有几率推动等级低于自己15级的敌人。",
		skillDescribe = "lv4需要等级:2转50级;",
		skillIdent = 64,
		skillBookSource = "需要技能书：4级冰天雪地;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗4000秘籍点兑换。",
		skillType = 4,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "5级冰天雪地",
		skillEffect = "主动技能，使用技能书提升至lv5的冰天雪地；有几率推动等级低于自己的敌人。",
		skillDescribe = "lv5需要等级:3转15级;",
		skillIdent = 64,
		skillBookSource = "需要技能书：5级冰天雪地;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗6000秘籍点兑换。",
		skillType = 4,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "6级冰天雪地",
		skillEffect = "主动技能，使用技能书提升至lv6的冰天雪地；有几率推动同等级的敌人。",
		skillDescribe = "lv6需要等级:3转30级;",
		skillIdent = 64,
		skillBookSource = "需要技能书：6级冰天雪地;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗9000秘籍点兑换。",
		skillType = 4,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "治愈术",
		skillEffect = "主动技能，释放精神之力恢复自己或者他人的体力。",
		skillDescribe = "lv1需要等级:7，需要技能熟练度：50;lv2需要等级:11，需要技能熟练度：150;lv3需要等级:16，需要技能熟练度：300;提升技能熟练度：使用治愈术",
		skillIdent = 2,
		skillBookSource = "需要技能书：治愈术;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "精神力战法",
		skillEffect = "被动技能，通过与精神之力沟通，提高自身准确",
		skillDescribe = "lv1需要等级:9，需要技能熟练度：50;lv2需要等级:13，需要技能熟练度：150;lv3需要等级:19，需要技能熟练度：300;提升技能熟练度：使用普攻",
		skillIdent = 4,
		skillBookSource = "需要技能书：精神力战法;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "施毒术",
		skillEffect = "主动技能，可以指定某个目标中毒。持续消耗目标生命力，并使其受到的伤害加深。",
		skillDescribe = "lv1需要等级:14，需要技能熟练度：50;lv2需要等级:17，需要技能熟练度：150;lv3需要等级:20，需要技能熟练度：300;提升技能熟练度：使用施毒术",
		skillIdent = 6,
		skillBookSource = "需要技能书：施毒术;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "灵魂火符",
		skillEffect = "主动技能，将精神之力附着在护身符上，远程攻击目标造成伤害；可以受到随天术的加成。",
		skillDescribe = "lv1需要等级:18，需要技能熟练度：120;lv2需要等级:21，需要技能熟练度：300;lv3需要等级:24，需要技能熟练度：500;提升技能熟练度：使用灵魂火符",
		skillIdent = 13,
		skillBookSource = "需要技能书：灵魂火符;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "召唤骷髅",
		skillEffect = "主动技能，从地狱的深处召唤骷髅，作为自己的仆从。",
		skillDescribe = "lv1需要等级:19，需要技能熟练度：120;lv2需要等级:23，需要技能熟练度：300;lv3需要等级:26，需要技能熟练度：500;提升技能熟练度：使用召唤骷髅，并召出新的骷髅",
		skillIdent = 17,
		skillBookSource = "需要技能书：召唤骷髅;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "隐身术",
		skillEffect = "主动技能，在自身周围释放精神之力使怪物无法察觉你的存在。",
		skillDescribe = "lv1需要等级:20，需要技能熟练度：400;lv2需要等级:23，需要技能熟练度：800;lv3需要等级:26，需要技能熟练度：1600;提升技能熟练度：使用隐身术",
		skillIdent = 18,
		skillBookSource = "需要技能书：隐身术;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "集体隐身术",
		skillEffect = "主动技能，通过大量释放精神之力，能够隐藏范围内的人。",
		skillDescribe = "lv1需要等级:21，需要技能熟练度：400;lv2需要等级:25，需要技能熟练度：800;lv3需要等级:29，需要技能熟练度：1600;提升技能熟练度：使用集体隐身术",
		skillIdent = 19,
		skillBookSource = "需要技能书：集体隐身术;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "神圣战甲术",
		skillEffect = "主动技能，提高范围内非敌方的防御力和魔法防御力。",
		skillDescribe = "lv1需要等级:25，需要技能熟练度：1000;lv2需要等级:27，需要技能熟练度：2000;lv3需要等级:29，需要技能熟练度：4000;提升技能熟练度：使用神圣战甲术",
		skillIdent = 15,
		skillBookSource = "需要技能书：神圣战甲术;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "困魔咒",
		skillEffect = "主动技能，使用咒语将怪兽限制在一定的范围内。",
		skillDescribe = "lv1需要等级:28，需要技能熟练度：300;lv2需要等级:30，需要技能熟练度：600;lv3需要等级:32，需要技能熟练度：1200;提升技能熟练度：使用困魔咒",
		skillIdent = 16,
		skillBookSource = "需要技能书：困魔咒;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "气功波",
		skillEffect = "主动技能，一种内功的修炼，可以推开周围的怪物而得以防身的作用；能够推动等级低于自己的敌方，气功波达到3级后能推动同级别敌方。",
		skillDescribe = "lv1需要等级:29，需要技能熟练度：800;lv2需要等级:31，需要技能熟练度：1600;lv3需要等级:34，需要技能熟练度：2400;提升技能熟练度：使用气功波，并成功击退敌方",
		skillIdent = 37,
		skillBookSource = "需要技能书：气功波;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "群体治愈术",
		skillEffect = "主动技能，恢复自己和周围所有玩家的体力。",
		skillDescribe = "lv1需要等级:33，需要技能熟练度：400;lv2需要等级:35，需要技能熟练度：800;lv3需要等级:38，需要技能熟练度：1200;提升技能熟练度：使用群体治愈术",
		skillIdent = 29,
		skillBookSource = "需要技能书：群体治愈术;1、书店老板处购买。",
		skillType = 5,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "召唤神兽",
		skillEffect = "主动技能，召唤一只强大神兽作为自己的随从。",
		skillDescribe = "lv1需要等级:35，需要技能熟练度：150;lv2需要等级:39，需要技能熟练度：400;lv3需要等级:43，需要技能熟练度：600;提升技能熟练度：使用召唤神兽，并召出新的神兽",
		skillIdent = 30,
		skillBookSource = "需要技能书：召唤神兽;1、击败精英怪有几率获得；;2、击败首领有几率获得；;3、元宝行购买；;4、刷书；;5、藏经峡谷。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "4级召唤神兽",
		skillEffect = "主动技能，使用技能书提升至lv4的召唤神兽。",
		skillDescribe = "lv4需要等级:55;",
		skillIdent = 30,
		skillBookSource = "需要技能书：4级召唤神兽;1、皇家大学士处消耗3点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "5级召唤神兽",
		skillEffect = "主动技能，使用技能书提升至lv5的召唤神兽。",
		skillDescribe = "lv5需要等级:68;",
		skillIdent = 30,
		skillBookSource = "需要技能书：5级召唤神兽;1、皇家大学士处消耗5点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "6级召唤神兽",
		skillEffect = "主动技能，使用技能书提升至lv6的召唤神兽。",
		skillDescribe = "lv6需要等级:85;",
		skillIdent = 30,
		skillBookSource = "需要技能书：6级召唤神兽;1、皇家大学士处消耗8点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "无极真气",
		skillEffect = "被动技能，利用自然真气，引发体内潜力，固定提升自身精神力。",
		skillDescribe = "lv1需要等级:36，需要技能熟练度：500;lv2需要等级:39，需要技能熟练度：800;lv3需要等级:42，需要技能熟练度：1000;提升技能熟练度:使用普攻",
		skillIdent = 36,
		skillBookSource = "需要技能书：无极真气;1、击败精英怪有几率获得；;2、击败首领有几率获得；;3、元宝行购买；;4、刷书；;5、藏经峡谷。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "噬血术",
		skillEffect = "主动技能，用强大的精神力，吸取对方生命并造成伤害；可以受到随天术的加成。",
		skillDescribe = "lv1需要等级:47，需要技能熟练度：1000;lv2需要等级:52，需要技能熟练度：2000;lv3需要等级:59，需要技能熟练度：4000;提升技能熟练度：使用噬血术",
		skillIdent = 48,
		skillBookSource = "需要技能书：噬血术;1、皇家大学士处消耗1000贡献度及2点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "4级噬血术",
		skillEffect = "主动技能，使用技能书提升至lv4的噬血术。",
		skillDescribe = "lv4需要等级:75;",
		skillIdent = 48,
		skillBookSource = "需要技能书：4级噬血术;1、皇家大学士处消耗1000贡献度及3点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "5级噬血术",
		skillEffect = "主动技能，使用技能书提升至lv5的噬血术。",
		skillDescribe = "lv5需要等级:95;",
		skillIdent = 48,
		skillBookSource = "需要技能书：5级噬血术;1、皇家大学士处消耗1000贡献度及4点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "6级噬血术",
		skillEffect = "主动技能，使用技能书提升至lv6的噬血术。",
		skillDescribe = "lv6需要等级:1转15级;",
		skillIdent = 48,
		skillBookSource = "需要技能书：6级噬血术;1、皇家大学士处消耗1000贡献度及5点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "0级随天术",
		skillEffect = "被动技能，通过增加对道术释放的掌握，永久提高主动伤害技能的效果。包括灵魂火符、噬血术",
		skillDescribe = "lv0需要等级：1转35级;",
		skillIdent = 62,
		skillBookSource = "需要技能书：0级随天术;1、皇家大学士处消耗2000贡献度及158点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "1级随天术",
		skillEffect = "被动技能，使用技能书提升至lv1的随天术。",
		skillDescribe = "lv1需要等级:1转55级;",
		skillIdent = 62,
		skillBookSource = "需要技能书：1级随天术;1、皇家大学士处消耗3000贡献度及218点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "2级随天术",
		skillEffect = "被动技能，使用技能书提升至lv2的随天术。",
		skillDescribe = "lv2需要等级:1转75级;",
		skillIdent = 62,
		skillBookSource = "需要技能书：2级随天术;1、皇家大学士处消耗4000贡献度及288点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "3级随天术",
		skillEffect = "被动技能，使用技能书提升至lv3的随天术。",
		skillDescribe = "lv3需要等级:2转1级;",
		skillIdent = 62,
		skillBookSource = "需要技能书：3级随天术;1、皇家大学士处消耗5000贡献度及368点阅历值兑换。",
		skillType = 6,
		minServerState = 0,
		minOpenDay = 0
	},
	{
		skillName = "0级万剑归宗",
		skillEffect = "主动技能，万箭钻心天地同归，对目标及目标周围敌人造成伤害；并有一定几率推动等级低于自己60级的敌人；可以受到随天术的加成。",
		skillDescribe = "lv0需要等级：1转5级;",
		skillIdent = 65,
		skillBookSource = "需要技能书：0级万剑归宗;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗100秘籍点兑换。",
		skillType = 6,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "1级万剑归宗",
		skillEffect = "主动技能，使用技能书提升至lv1的万剑归宗；有几率推动等级低于自己50级的敌人。",
		skillDescribe = "lv1需要等级:1转20级;",
		skillIdent = 65,
		skillBookSource = "需要技能书：1级万剑归宗;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗500秘籍点兑换。",
		skillType = 6,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "2级万剑归宗",
		skillEffect = "主动技能，使用技能书提升至lv2的万剑归宗；有几率推动等级低于自己40级的敌人。",
		skillDescribe = "lv2需要等级:1转50级;",
		skillIdent = 65,
		skillBookSource = "需要技能书：2级万剑归宗;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗1500秘籍点兑换。",
		skillType = 6,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "3级万剑归宗",
		skillEffect = "主动技能，使用技能书提升至lv3的万剑归宗；有几率推动等级低于自己30级的敌人。",
		skillDescribe = "lv3需要等级:2转5级;",
		skillIdent = 65,
		skillBookSource = "需要技能书：3级万剑归宗;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗2500秘籍点兑换。",
		skillType = 6,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "4级万剑归宗",
		skillEffect = "主动技能，使用技能书提升至lv4的万剑归宗；有几率推动等级低于自己15级的敌人。",
		skillDescribe = "lv4需要等级:2转50级;",
		skillIdent = 65,
		skillBookSource = "需要技能书：4级万剑归宗;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗4000秘籍点兑换。",
		skillType = 6,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "5级万剑归宗",
		skillEffect = "主动技能，使用技能书提升至lv5的万剑归宗；有几率推动等级低于自己的敌人。",
		skillDescribe = "lv5需要等级:3转15级;",
		skillIdent = 65,
		skillBookSource = "需要技能书：5级万剑归宗;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗6000秘籍点兑换。",
		skillType = 6,
		minServerState = 1,
		minOpenDay = 0
	},
	{
		skillName = "6级万剑归宗",
		skillEffect = "主动技能，使用技能书提升至lv6的万剑归宗；有几率推动同等级的敌人。",
		skillDescribe = "lv6需要等级:3转30级;",
		skillIdent = 65,
		skillBookSource = "需要技能书：6级万剑归宗;1、服务器二阶段，且人物等级到达1转5级后，;在皇家大学士处消耗9000秘籍点兑换。",
		skillType = 6,
		minServerState = 1,
		minOpenDay = 0
	}
}

return skillPicIdentifyConfig
