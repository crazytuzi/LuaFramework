--PlayerDropItemConstant.lua
--/*-----------------------------------------------------------------
 --* Module:  PlayerDropItemConstant.lua
 --* Author:  gongyingqi
 --* Modified: 2016年2月5日
 --* Purpose: 玩家死亡爆物常量定义
 -------------------------------------------------------------------*/

--掉落概率最大值
DROP_RATE_MAX = 1000

--包裹物品掉落概率 10%
BAG_ITEM_DROP_RATE = 10
--包裹物品种类掉落最大数量
BAG_ITEM_DROP_NUM = 3
--单个物品掉落最大数量
BAG_ITEM_DROP_MAX = 3

--装备 部位 系数
EQUIP_POSITIONS = {
{Item_EquipPosition_Weapon, 40},
{Item_EquipPosition_UpperBody, 60},
{Item_EquipPosition_Head, 140},
{Item_EquipPosition_Necklace, 80},
{Item_EquipPosition_WristLeft, 110},
{Item_EquipPosition_WristRight, 110},
{Item_EquipPosition_RingLeft, 100},
{Item_EquipPosition_RingRight, 100},
{Item_EquipPosition_Waist, 120},
{Item_EquipPosition_Foot, 140},
}

--装备索引值与装备部位对应关系
EQUIP_INDEX = {
	[1] = Item_EquipPosition_Weapon,
	[2] = Item_EquipPosition_UpperBody,
	[3] = Item_EquipPosition_Head,
	[4] = Item_EquipPosition_Necklace,
	[5] = Item_EquipPosition_WristLeft,
	[6] = Item_EquipPosition_WristRight,
	[7] = Item_EquipPosition_RingLeft,
	[8] = Item_EquipPosition_RingRight,
	[9] = Item_EquipPosition_Waist,
	[10] = Item_EquipPosition_Foot,
}

--装备掉落为 x秒内死亡x次
EQUIP_DROP_JUDGE = {5*60, 20}
--x秒内死亡x次且x秒内没爆装备时爆一件装备概率20%
EQUIP_DROP_RATE = 20

--x秒内掉过装备，改变掉落规则
EQUIP_DROP_TIME_SCOPE = 30*60

--上次掉落该装备，再次掉落时的概率1%
EQUIP_AGAIN_DROP_RATE = 1

--装备物品品质系数
EQUIP_COLOR_RATE = {
	6,	--白色
	5,	--绿色
	4,	--蓝色
	3,	--紫色
	1,	--橙色
}

--装备物品等级系数
EQUIP_LEVEL_RATE = {
	{1, 1},		--等级为1的装备，系数1
	{20, 1},		--等级为1的装备，系数1
	{30, 8},		--等级为1的装备，系数1
	{40, 6},		--等级为1的装备，系数1
	{50, 5},		--等级为1的装备，系数1
	{60, 4},		--等级为1的装备，系数1
	{70, 3},		--等级为1的装备，系数1
}

--装备物品强化等级系数
EQUIP_STRENTH_RATE = {
	{0, 5, 10},		--从1级到10级，系数1
	{6, 10, 6},		--从1级到10级，系数1
	{11, 15, 4},	--从11级到20级，系数2
	{16, 18, 2},	--从11级到20级，系数2
	{19, 20, 1},	--从21级到30级，系数3
}

--装备物品pk值系数
EQUIP_PKVALUE_RATE = 
{
	{0, 1, 1},		--从1点到10点，系数1
	{2, 10, 5},	--从11点到20点，系数2
	{11, 50, 8},	--从21点到30点，系数3
	{51, 500000, 10},	--从21点到30点，系数3
}

