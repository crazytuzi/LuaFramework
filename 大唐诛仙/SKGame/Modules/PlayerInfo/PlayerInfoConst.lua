PlayerInfoConst = {}

--玩家基础属性
PlayerInfoConst.PlayerBaseProp = {
	[1] = 31,	-- 力量
	[2] = 32,	-- 智慧
	[3] = 33,	-- 耐力
	[4] = 34,	-- 灵力
	[5] = 35,	-- 幸运
}

--玩家战斗属性
PlayerInfoConst.PlayerBattleProp = {
	[1] = 1, -- 最大HP
	[2] = 3, -- 最大MP
	[3] = 5, -- 物理攻击
	[4] = 7, -- 法术攻击
	[5] = 9, -- 物理防御
	[6] = 11, -- 法术防御
	[7] = 13, -- 暴击
	[8] = 15, -- 韧性
}

--玩家特殊属性
PlayerInfoConst.PlayerSpecialProp = {
	[1] = 21,  --伤害加深
	[2] = 22,  --伤害减免
	[3] = 23,  --伤害暴击
	[4] = 24,  --移动速度
	[5] = 57,  --pk值
	[6] = 54,  --工会贡献
}

--上升或者降低
PlayerInfoConst.UpORDown = {
	[0] = "",
	[1] = "Icon/Other/arrow_01",  --上升
	[2] = "Icon/Other/arrow_11",  --降低
}

PlayerInfoConst.ProDesc = {
	"力量:[color=#43596b]影响[color=#3370b7]物理攻击[/color]和少量[color=#3370b7]生命值[/color][/color]",
	"智慧:[color=#43596b]影响[color=#3370b7]法术攻击[/color]和少量[color=#3370b7]法力值[/color][/color]",
	"耐力:[color=#43596b]影响[color=#3370b7]物理防御[/color]和[color=#3370b7]生命值[/color][/color]",
	"灵力:[color=#43596b]影响[color=#3370b7]法术防御[/color]和[color=#3370b7]法力值[/color][/color]",
	"幸运:[color=#43596b]影响[color=#3370b7]暴击[/color]和[color=#3370b7]韧性[/color][/color]"
}

PlayerInfoConst.EventName_OpenEquipList = "EventName_OpenEquipList"  --打开装备列表
PlayerInfoConst.EventName_OpenEquipTips = "EventName_OpenEquipTips" --打开装备tips
PlayerInfoConst.EventName_RefreshPlayerEquipList = "EventName_RefreshPlayerEquipList"  --更新玩家装备列表
PlayerInfoConst.EventName_ReFreshPlayerSkepEquipList = "EventName_ReFreshPlayerSkepEquipList"  --更新玩家对应的pos的装备列表
