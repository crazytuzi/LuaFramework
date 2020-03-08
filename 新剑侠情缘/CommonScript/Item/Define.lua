
Item.EQUIP_WEAPON			= 1;		-- 武器
Item.EQUIP_ARMOR			= 2;		-- 衣服
Item.EQUIP_RING				= 3;		-- 戒指
Item.EQUIP_NECKLACE			= 4;		-- 项链
Item.EQUIP_AMULET			= 5;		-- 护身符
Item.EQUIP_BOOTS			= 6;		-- 鞋子
Item.EQUIP_BELT				= 7;		-- 腰带
Item.EQUIP_HELM				= 8;		-- 头盔
Item.EQUIP_CUFF				= 9;		-- 护腕
Item.EQUIP_PENDANT			= 10;		-- 腰坠
Item.EQUIP_HORSE			= 11;		-- 坐骑
Item.EQUIP_SKILL_BOOK		= 12;		-- 秘籍
Item.EQUIP_WAIYI 			= 13;		-- 外衣
Item.EQUIP_WAI_WEAPON		= 14;		-- 外装武器
Item.EQUIP_REIN				= 15;		-- 缰绳
Item.EQUIP_SADDLE			= 16;		-- 马鞍
Item.EQUIP_PEDAL			= 17;		-- 脚蹬
Item.EQUIP_WAI_HORSE		= 18;		-- 外装坐骑
Item.EQUIP_ZHEN_YUAN		= 19;		-- 真元
Item.EQUIP_WAI_BACK		    = 20;		-- 外背件
Item.EQUIP_WAI_HEAD		    = 21;		-- 外头
Item.EQUIP_JUEXUE_BOOK		= 22;		-- 绝学秘籍
Item.EQUIP_MIBEN_BOOK		= 23;		-- 秘本秘籍
Item.EQUIP_DUANPIAN_BOOK	= 24;		-- 断篇秘籍
--注意五行石的十件装备是不连续的
Item.EQUIP_WEAPON_SERIES 	= 25;		--五行石武器
Item.EQUIP_ARMOR_SERIES		= 26;		--五行石衣服
Item.EQUIP_RING_SERIES   	= 27;		--五行石戒指
Item.EQUIP_NECKLACE_SERIES	= 28;		--五行石项链
Item.EQUIP_AMULET_SERIES	= 29;		--五行石护身符
Item.EQUIP_BOOTS_SERIES		= 30;		--五行石鞋子
Item.EQUIP_BELT_SERIES		= 31;		--五行石腰带 --中间有插入其他类型道具
Item.EQUIP_HELM_SERIES		= 40;		-- 五行石头盔
Item.EQUIP_CUFF_SERIES		= 41;		-- 五行石护手
Item.EQUIP_PENDANT_SERIES	= 42;		-- 五行石腰坠
Item.EQUIP_BACK2 			= 43; 		-- 外背件2
Item.EQUIP_WAI_BACK2 		= 44; 		-- 外背件2 外装
Item.ITEM_SCRIPT			= 34;
Item.PARTNER 				= 35;  		-- 同伴类
Item.EQUIP_EX				= 36;		-- 未鉴定装备
Item.ITEM_JUE_YAO		    = 37;		-- 诀要
Item.ITEM_INSCRIPTION		= 38;		-- 铭文

-- 装备位置

Item.EQUIPPOS_HEAD			= 0;		-- 头
Item.EQUIPPOS_BODY			= 1;		-- 衣服
Item.EQUIPPOS_BELT			= 2;		-- 腰带
Item.EQUIPPOS_WEAPON		= 3;		-- 武器
Item.EQUIPPOS_FOOT			= 4;		-- 鞋子
Item.EQUIPPOS_CUFF			= 5;		-- 护腕
Item.EQUIPPOS_AMULET		= 6;		-- 护身符
Item.EQUIPPOS_RING			= 7;		-- 戒指
Item.EQUIPPOS_NECKLACE		= 8;		-- 项链
Item.EQUIPPOS_PENDANT		= 9;		-- 玉佩
Item.EQUIPPOS_HORSE			= 10;		-- 坐骑
Item.EQUIPPOS_SKILL_BOOK    = 11;		-- 秘籍
Item.EQUIPPOS_SKILL_BOOK_End = 20;		-- 秘籍结束
Item.EQUIPPOS_WAIYI			= 21;		-- 外装
Item.EQUIPPOS_WAI_WEAPON	= 22;		-- 外装武器
Item.EQUIPPOS_REIN			= 23;		-- 缰绳
Item.EQUIPPOS_SADDLE		= 24;		-- 马鞍
Item.EQUIPPOS_PEDAL			= 25;		-- 脚蹬
Item.EQUIPPOS_WAI_HORSE		= 26;		-- 外装坐骑
Item.EQUIPPOS_ZHEN_YUAN		= 27;		-- 真元
Item.EQUIPPOS_WAI_BACK		= 28;		-- 外背件
Item.EQUIPPOS_WAI_HEAD		= 29;		-- 外装头
Item.EQUIPPOS_JUEXUE_BEGIN  = 30;		-- 绝学开始
Item.EQUIPPOS_JUEXUE_END    = 70;		-- 绝学结束
Item.EQUIPPOS_WEAPON_SERIES = 	71;		--五行石武器
Item.EQUIPPOS_ARMOR_SERIES = 	72;
Item.EQUIPPOS_RING_SERIES = 	73;
Item.EQUIPPOS_NECKLACE_SERIES = 74;
Item.EQUIPPOS_AMULET_SERIES = 	75;
Item.EQUIPPOS_BOOTS_SERIES = 	76;
Item.EQUIPPOS_BELT_SERIES = 	77;
Item.EQUIPPOS_HELM_SERIES = 	78;
Item.EQUIPPOS_CUFF_SERIES = 	79;
Item.EQUIPPOS_PENDANT_SERIES = 	80;  	--五行石腰坠
Item.EQUIPPOS_BACK2			= 	81;		-- 外背件2 披风
Item.EQUIPPOS_WAI_BACK2		= 	82;		-- 外装 披风

Item.EQUIPPOS_NUM			= 82; 		--总装备位置数

Item.EQUIPPOS_MAIN_NUM     = 10; --主身体装备数量

Item.EITEMPOS_BAG     = 200; --背包的位置



Item.tbHorseItemPos = {
	[Item.EQUIPPOS_HORSE] 	= 1;
	[Item.EQUIPPOS_REIN] 	= 1;
	[Item.EQUIPPOS_SADDLE] = 1;
	[Item.EQUIPPOS_PEDAL] 	= 1;
}


--装备类型对应位置
Item.EQUIPTYPE_POS =
{
	[Item.EQUIP_WEAPON]		= Item.EQUIPPOS_WEAPON,
	[Item.EQUIP_ARMOR]		= Item.EQUIPPOS_BODY,
	[Item.EQUIP_RING]		= Item.EQUIPPOS_RING,
	[Item.EQUIP_NECKLACE]	= Item.EQUIPPOS_NECKLACE,
	[Item.EQUIP_AMULET]		= Item.EQUIPPOS_AMULET,
	[Item.EQUIP_BOOTS]		= Item.EQUIPPOS_FOOT,
	[Item.EQUIP_BELT]		= Item.EQUIPPOS_BELT,
	[Item.EQUIP_HELM]		= Item.EQUIPPOS_HEAD,
	[Item.EQUIP_CUFF]		= Item.EQUIPPOS_CUFF,
	[Item.EQUIP_PENDANT]	= Item.EQUIPPOS_PENDANT,
	[Item.EQUIP_HORSE]		= Item.EQUIPPOS_HORSE,
}

Item.LOGIC_MAX_COUNT		= 200

Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN = 1
Item.EQUIP_RANDOM_ATTRIB_VALUE_END = 6
Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL = 8;--装备的成长属性等级, baseIntValue

Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN_EXT = 9;
Item.EQUIP_RANDOM_ATTRIB_VALUE_END_EXT = 10; --最多8条随机属性和一个技能 ,因为铭刻石头已经用了 11到20

Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY = {};
for i = Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN, Item.EQUIP_RANDOM_ATTRIB_VALUE_END do
	table.insert(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY, i)
end
for i=Item.EQUIP_RANDOM_ATTRIB_VALUE_BEGIN_EXT,Item.EQUIP_RANDOM_ATTRIB_VALUE_END_EXT do
	table.insert(Item.tbEQUIP_RANDOM_ATTRIB_VALUE_KEY, i)
end
--tbEQUIP_RANDOM_ATTRIB_VALUE_KEY ！！已有的key不可以更改，注意有铭刻石的intval

--铭刻石，先预留10 个。现在按照最多3个
Item.EQUIP_RECORD_STONE_VALUE_BEGIN = 11;
Item.EQUIP_RECORD_STONE_VALUE_END 	= 20; --

--绝学数值保存
Item.EQUIP_JUEXUE_VALUE_BEGIN = 21
Item.EQUIP_JUEXUE_VALUE_END = 30
--白金装备进阶
Item.EQUIP_KEY_LAST_GOLD_LEVEL = 31; --黄金进入到白金时是到10阶的，记录之前的黄金阶数，在该装备进阶到对应阶前是不消耗对应的和氏璧的

-----!!itemIntValue key end !!----

Item.EQUIPTYPE_NAME =
{
	[Item.EQUIP_WEAPON	] = "武器",
	[Item.EQUIP_ARMOR	] = "衣服",
	[Item.EQUIP_RING	] = "戒指",
	[Item.EQUIP_NECKLACE] = "项链",
	[Item.EQUIP_AMULET	] = "护身符",
	[Item.EQUIP_BOOTS	] = "鞋子",
	[Item.EQUIP_BELT	] = "腰带",
	[Item.EQUIP_HELM	] = "帽子",
	[Item.EQUIP_CUFF	] = "护腕",
	[Item.EQUIP_PENDANT	] = "玉佩",
	[Item.EQUIP_HORSE	] = "坐骑",
	[Item.EQUIP_WAIYI	] = "外装",
	[Item.EQUIP_WAI_WEAPON] = "外装武器",
	[Item.EQUIP_REIN	] = "缰绳",
	[Item.EQUIP_SADDLE	] = "马鞍",
	[Item.EQUIP_PEDAL	] = "脚蹬",
	[Item.EQUIP_ZHEN_YUAN] = "真元",
	[Item.ITEM_INSCRIPTION] = "铭文",
	[Item.EQUIP_BACK2] = "披风",
}

-- 装备穿在身上的位置描述字符串
Item.EQUIPPOS_NAME =
{
	[Item.EQUIPPOS_HEAD]		= "帽子",
	[Item.EQUIPPOS_BODY]		= "衣服",
	[Item.EQUIPPOS_BELT]		= "腰带",
	[Item.EQUIPPOS_WEAPON]		= "武器",
	[Item.EQUIPPOS_FOOT]		= "鞋子",
	[Item.EQUIPPOS_CUFF]		= "护腕",
	[Item.EQUIPPOS_AMULET]		= "护身符",
	[Item.EQUIPPOS_RING]		= "戒指",
	[Item.EQUIPPOS_NECKLACE]	= "项链",
	[Item.EQUIPPOS_PENDANT]		= "玉佩",
	[Item.EQUIPPOS_HORSE]		= "坐骑",

	[Item.EQUIPPOS_REIN	] = "缰绳",
	[Item.EQUIPPOS_SADDLE	] = "马鞍",
	[Item.EQUIPPOS_PEDAL	] = "脚蹬",

	[Item.EQUIPPOS_WEAPON_SERIES] 	= "武器";
	[Item.EQUIPPOS_ARMOR_SERIES] 	= "衣服";
	[Item.EQUIPPOS_RING_SERIES] 	= "戒指";
	[Item.EQUIPPOS_NECKLACE_SERIES] = "项链";
	[Item.EQUIPPOS_AMULET_SERIES] 	= "护身符";
	[Item.EQUIPPOS_BOOTS_SERIES] 	= "鞋子";
	[Item.EQUIPPOS_BELT_SERIES] 	= "腰带";
	[Item.EQUIPPOS_HELM_SERIES] 	= "帽子";
	[Item.EQUIPPOS_CUFF_SERIES] 	= "护腕";
	[Item.EQUIPPOS_PENDANT_SERIES] 	= "玉佩";
};

Item.EQUIPTYPE_EN_NAME =
{
	[Item.EQUIP_WEAPON	] = "Weapon",
	[Item.EQUIP_ARMOR	] = "Armor",
	[Item.EQUIP_RING	] = "Ring",
	[Item.EQUIP_NECKLACE] = "Necklace",
	[Item.EQUIP_AMULET	] = "Amulet",
	[Item.EQUIP_BOOTS	] = "Boots",
	[Item.EQUIP_BELT	] = "Belt",
	[Item.EQUIP_HELM	] = "Helm",
	[Item.EQUIP_CUFF	] = "Cuff",
	[Item.EQUIP_PENDANT	] = "Pendant",
	[Item.EQUIP_HORSE	] = "Horse",
	[Item.EQUIP_ZHEN_YUAN] = "ZhenYuan",
	[Item.ITEM_INSCRIPTION] = "Inscription",
	[Item.EQUIP_WEAPON_SERIES] = "WeaponSeries" ,
	[Item.EQUIP_ARMOR_SERIES] = "ArmorSeries",
	[Item.EQUIP_RING_SERIES	] = "RingSeries",
	[Item.EQUIP_NECKLACE_SERIES] = "NecklaceSeries",
	[Item.EQUIP_AMULET_SERIES	] = "AmuletSeries",
	[Item.EQUIP_BOOTS_SERIES	] = "BootsSeries",
	[Item.EQUIP_BELT_SERIES	] = "BeltSeries",
	[Item.EQUIP_HELM_SERIES	] = "HelmSeries",
	[Item.EQUIP_CUFF_SERIES	] = "CuffSeries",
	[Item.EQUIP_PENDANT_SERIES	] = "PendantSeries",
}


Item.tbQualityColor =
{
	"itemframe", 			-- 白
	"itemframeGreen",		-- 绿
	"itemframeBlue",		-- 蓝
	"itemframePurple",		-- 紫
	"itemframePink",		-- 粉
	"itemframeOrange",		-- 橙
	"itemframeGold",		-- 金
}
Item.DEFAULT_COLOR = "itemframe";	-- 默认白色

Item.DROP_OBJ_TYPE_SPE = 0; --掉落特殊的
Item.DROP_OBJ_TYPE_MONEY = 1; --掉落钱
Item.DROP_OBJ_TYPE_ITEM  = 2; --掉落道具

Item.emEquipActiveReq_None = 0;
Item.emEquipActiveReq_Ride = 1;--骑乘激活

Item.szGeneralEquipPosAtlas = "UI/Atlas/Item/Item/Item2.prefab"
Item.tbGeneralEquipPosIcons = {
	[Item.EQUIPPOS_HEAD]		= "Helm",
	[Item.EQUIPPOS_BODY]		= "Armor",
	[Item.EQUIPPOS_BELT]		= "Belt",
	[Item.EQUIPPOS_WEAPON]		= "Weapon",
	[Item.EQUIPPOS_FOOT]		= "Boots",
	[Item.EQUIPPOS_CUFF]		= "Cuff",	--护腕
	[Item.EQUIPPOS_AMULET]		= "Amulet",	--护身符
	[Item.EQUIPPOS_RING]		= "Ring",
	[Item.EQUIPPOS_NECKLACE]	= "Necklace",
	[Item.EQUIPPOS_PENDANT]		= "Pendant",	--玉佩
	[Item.EQUIPPOS_HORSE]		= "",
}


Item.DetailType_Normal 	= 1;
Item.DetailType_Rare 	= 2;
Item.DetailType_Inherit = 3;
Item.DetailType_Gold 	= 4;
Item.DetailType_Platinum = 5;

Item.tbSellMoneyType = {
	[Item.DetailType_Normal]  = "Coin",
	[Item.DetailType_Rare] 	  = "Contrib",
	[Item.DetailType_Inherit] = "Contrib",
	-- [Item.DetailType_Gold] 	  = "Contrib", --黄金装备不能出售
}

Item.EXT_USER_VALUE_GROUP = 135

--四个扩展背包
Item.tbExtBagSetting =
{
	-- SaveId     BagCount
	{	1,			10},
	{	2,			10},
	{	3,			10},
	{	4,			10},
}
