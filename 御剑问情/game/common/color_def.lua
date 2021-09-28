COLOR = {
	WHITE = "#ffffff",				-- 白
	GREY = "#808080",				-- 灰
	GREEN = "#00ff47ff",			-- 绿
	BLUE = "#a9d3fe",				-- 蓝
	BLUE_4 = "#0000f1",		        -- 蓝
	PURPLE = "#cb74d0",				-- 紫
	ORANGE = "#ff9900",				-- 橙
	RED = "#fb1212ff", 				-- 红
	GOLD = "#d0cb74", 				-- 金
	YELLOW = "#ffd493", 			-- 黄
}

TEXT_COLOR = {
	WHITE = "#ffffff",			-- 白(按钮字/小标签字)
	RED = "#fe3030",			-- 红(提醒/不足)
	RED2 = "#e40000",
	GOLD = "#ffff00",			-- 金(有关金币)
	PINK = "#fc6060",			-- 粉色
	GREEN = "#00ff00",			-- 绿(有关数字)
	GREEN1 = "#00ff90",          -- 绿
	GREEN2 = "#00ff06",
	YELLOW = "#ffff00",			-- 黄
	YELLOW1 = "#ffe500",
	BLUE = "#0065fc",			-- 浅蓝(按钮下的小提示)
	BLUE1 = "#0000f1",
	PURPLE = "#ff00fd",			-- 紫
	PURPLE2 = "#fc00f3",
	ORANGE = "#ff9900",			-- 橙
	GRAY = "#636363ff",			-- 灰
	GRAY_BLUE = "#83b2e7ff",	-- 灰蓝
	GRAY_WHITE = "#B7D3F9FF",	-- 灰白（属性）
	LOWGREEN = "#2dcecfff",		-- 提醒
	GREEN_1 = "#40f466",		-- 通用描述数字颜色(浅绿)
	GREEN_2 = "#3fbc88",		-- 通用描述文字颜色(浅绿)
	GREEN_3 = "#33e45d",		-- 镉绿色(任务面板)
	BLUE_1 = "#b7d3f9",			-- 通用描述数字颜色(浅蓝)
	BLUE_2 = "#6098cb",			-- 通用描述文字颜色(浅蓝)
	BLUE_3 = "#2899f9",			-- 物品文字品质(浅蓝)
	BLUE_4 = "#0000f1",			-- 特殊数字蓝色(深蓝)
	BLUE_5 = "#0000f1",
	PURPLE_1 = "#c56aff",		-- 通用描述数字颜色(浅紫)
	PURPLE_2 = "#934fc6",		-- 通用描述文字颜色(浅紫)
	PURPLE_3 = "#fc00f3",		-- 物品文字品质(浅紫)
	ORANGE_1 = "#ff8247",		-- 通用描述数字颜色(浅橙)
	ORANGE_2 = "#ba5f35",		-- 通用描述文字颜色(浅橙)
	ORANGE_3 = "#f08229",		-- 物品文字品质(浅橙)
	ORANGE_4 = "#fc4d00",		-- 图标属性文字
	RED_1 = "#ff3838",			-- 通用描述数字颜色(浅红)
	RED_2 = "#e75959",			-- 通用描述文字颜色(浅红)
	RED_3 = "#eb3434",			-- 物品文字品质(浅红)
	RED_4 = "#e40000",			-- 通用描述文字颜色(深红)
	GRAY_1 = "#735c32",			-- 描述颜色(灰)
	BLACK_1 = "#001828FF",      -- 描述颜色(黑)
	BLACK_2 = "#001828FF",      -- 描述颜色（黑）
	BLUE_SPECIAL = "#0000f1",   -- 数字描述（蓝色）
	BROWN_1 = "#8a4100",        -- vip文本描述(棕色)
	GREEN_SPECIAL = "#00ff06",  -- 通用描述文字颜色(绿色)
	GREEN_SPECIAL_1 = "#00842c",-- 通用描述属性颜色(绿色)
	BULE_NORMAL = "#0000f1",   -- 蓝色常用（物品数量）
	ACTIVITY_GREEN = "#00FF90", --活动数字颜色
	TONGYONG_TS ="#0000f1FF",   --特殊蓝色
	GUILD_MAZE = "#ffffff",		--公会迷宫字体颜色
	JINGSE = "#ffff00",
	GREEN_4 = "#89f201",         --材料（绿色）
	CAI = "#ffff00",         	--彩色
}

RICH_TEXT_COLOR = {
	WHITE = "#ffffff",			-- 白
	GREEN = "#00ff00",			-- 绿
	BLUE = "#00ffff",			-- 蓝
	PURPLE = "#d200ff",			-- 紫
	ORANGE = "#ffb400",			-- 橙
	RED = "#fe3030",			-- 红
	GOLD = "#fc6060",			-- 粉
	JINGSE = "#ffff00",			-- 金
	CAI  = "#ffff00",			-- 彩
	YELLOW  = "#FFF800FF",		-- 黄
}

-- 颜色从品质低到高
ITEM_TIP_NAME_COLOR = {
	"#135101",					-- 绿色
	"#074676",					-- 蓝色
	"#5c1998",					-- 紫色
	"#7d3500",					-- 橙色
	"#7f0e00",					-- 红色
	"#a61f1f",					-- 金色
	"#723600",					-- 真金色
}

-- 命魂颜色从品质低到高
SPIRIT_SOUL_COLOR = {
	"#00ff06",					-- 绿色
	"#0000f1",					-- 蓝色
	"#fc00f3",					-- 紫色
	"#fc4d00",					-- 橙色
	"#e40000",					-- 红色
	"#fc6060",					-- 粉色
	"#ffff00",                  -- 金色
	[11] = "#05842f",           -- 深绿色
}

-- 颜色从品质低到高
SOUL_NAME_COLOR = {
	"#00ff06",					-- 绿色
	"#0000f1",					-- 蓝色
	"#fc00f3",					-- 紫色
	"#fc4d00",					-- 橙色
	"#e40000",					-- 红色
	"#fc6060",					-- 粉色
	"#00842c",                  -- 深绿色
	[11] = "#05842f",                  -- 深绿色
}

--外观专用（盗用后果自负）
APPEARANCE_NAME_COLOR = {
	"#00ff06",					-- 绿色
	"#0080ff",					-- 蓝色
	"#fc00f3",					-- 紫色
	"#fc4d00",					-- 橙色
	"#e40000",					-- 红色
}

-- 宝宝守护精灵从品质低到高
BAOBAO_SPRITE_COLOR = {
	"#00ff06",					-- 绿色
	"#26baff",					-- 蓝色
	"#fc00f3",					-- 紫色
	"#fc4d00",					-- 橙色
}

-- 宝宝颜色
BAOBAO_COLOR = {
	"#0000f1",
	"Fuchsia",
	"#FFFF00",
}

-- 颜色从品质低到高
LIAN_QI_NAME_COLOR = {
	"#00842C",					-- 绿色
	"#0000f1",					-- 蓝色
	"#fc00f3",					-- 紫色
	"#fc4d00",					-- 橙色
	"#e40000",					-- 红色
	"#fc6060",					-- 金色
	"#00842c",                  -- 深绿色
}

-- 颜色从品质低到高（聊天用）
SOUL_NAME_COLOR_CHAT = {
	"#00ff00",					-- 绿色
	"#00ffff",					-- 蓝色
	"#d200ff",					-- 紫色
	"#ffb400",					-- 橙色
	"#fe3030",					-- 红色
	"#ffff00",					-- 金色
	"#723600",					-- 真金色
	"#723600",					-- 彩色
}
-- 颜色从品质低到高（炼魂装备用）
LIANHUN_NAME_COLOR_EQUIP = {
	[0] = "#ffffff", 			-- 白色
	"#00ff00",					-- 绿色
	"#00ffff",					-- 蓝色
	"#d200ff",					-- 紫色
	"#ffb400",					-- 橙色
	"#fe3030",					-- 红色
	"#fc6060",					-- 金色
	"#723600",					-- 真金色
}

BARRAGE_COLOR = {
	"#00ff06",					-- 绿色
	"#0000f1",					-- 蓝色
	"#fc00f3",					-- 紫色
	"#ff9000",					-- 橙色
	"#ff2a1f",					-- 红色
	"#fc6060",					-- 金色
	"#723600",					-- 真金色
}

ITEM_TIP_CONTEXT_COLOR = {
	"#05842f",					-- 绿色
	TEXT_COLOR.BULE_NORMAL,		-- 蓝色
	"#f12fea",					-- 紫色
	"#ed5f00",					-- 橙色
	TEXT_COLOR.RED,				-- 红色
	TEXT_COLOR.PINK,			-- 粉色
	TEXT_COLOR.JINGSE,			-- 金色
	TEXT_COLOR.CAI,				-- 彩色
}

--活动颜色从品质低到高
ACTIVITY_QUALITY_COLOR = {
	"#00ff00",					-- 绿色
	"#00ffff",					-- 蓝色
	"#f12fea",					-- 紫色
	"#ffb400",					-- 橙色
	"#fe3030",					-- 红色
}

-- 精灵资质颜色
SPIRIT_ADDITION_NAME_COLOR = {
	"#ffffff",					-- 无色 对应 无称号
	"#33e45d",					-- 绿色
	"#2899f9",					-- 蓝色
	"#f12fea",                  -- 紫色
	"#ffe76d",                  -- 金色
}

SKILL_ITEM_COLOR = {
	RICH_TEXT_COLOR.GREEN,			-- 绿
	RICH_TEXT_COLOR.BLUE,			-- 蓝
	RICH_TEXT_COLOR.PURPLE,			-- 紫
	RICH_TEXT_COLOR.ORANGE,			-- 橙
	TEXT_COLOR.RED,					-- 红
	TEXT_COLOR.PINK,				-- 粉
	TEXT_COLOR.JINGSE,				-- 金
	RICH_TEXT_COLOR.CAI,			-- 彩
}

-- 头衔颜色
TOUXIAN_COLOR = {
	Color(1/255,165/255,12/255,1),					-- 绿色
	Color(0,92/255,255/255,1),						-- 蓝色
	Color(255/255,0,228/255,1),						-- 紫色
	Color(255/255,84/255,0,1),                 	 	-- 橙色
	Color(255/255,0,0,1),                  			-- 红色
	Color(255/255,115/255,115/255,1),               -- 粉色
}

--鱼名字的颜色
FISH_NAME_COLOR = {
	[0] = SOUL_NAME_COLOR[1],
	[1] = "#00ffff",
	[2] = SOUL_NAME_COLOR[3],
	[3] = SOUL_NAME_COLOR[5],
}

ITEM_TIP_COLOR = {
	[GameEnum.EQUIP_COLOR_GREEN] = TEXT_COLOR.GREEN_SPECIAL_1,	-- 绿
	[GameEnum.EQUIP_COLOR_BLUE] = TEXT_COLOR.BLUE_5,			-- 蓝
	[GameEnum.EQUIP_COLOR_PURPLE] = TEXT_COLOR.PURPLE_3,		-- 紫
	[GameEnum.EQUIP_COLOR_ORANGE] = TEXT_COLOR.ORANGE_4,		-- 橙
	[GameEnum.EQUIP_COLOR_RED] = TEXT_COLOR.RED2,				-- 红
	[GameEnum.EQUIP_COLOR_TEMP] = TEXT_COLOR.YELLOW,			-- 金
}

--任务类型描边颜色
MAIN_TASK_TEXT_OUTLINE_COLOR = {
	[0] = Color(189/255,89/255,0,1),	-- 主线
	[1] = Color(25/255,87/255,50/255,1), -- 支线
	[2] = Color(25/255,87/255,50/255,1), -- 其余为其他任务线
	[3] = Color(25/255,87/255,50/255,1),
	[4] = Color(25/255,87/255,50/255,1),
	[5] = Color(25/255,87/255,50/255,1),
	[6] = Color(25/255,87/255,50/255,1),
	[10] = Color(25/255,87/255,50/255,1),
	[11] = Color(25/255,87/255,50/255,1),
}

MAIN_TASK_TEXT_OUTLINE_COLOR1 = {
	[0] = Color(0.4784,0.2235,0,1),
	[1] = Color(0.0235,0.3922,0.0745,1),
	[2] = Color(0.4941,0.0392,0.5882,1),
	[3] = Color(0.0745,0.3529,0.4980,1),
	[4] = Color(0.5019,0.1764,0,1),
	[5] = Color(0.5019,0.1764,0,1),
	[6] = Color(0.5019,0.1764,0,1),
	[10] = Color(0.5019,0.1764,0,1),
	[11] = Color(0.5019,0.1764,0,1),
}

QUALITY_ICON = {
	[GameEnum.ITEM_COLOR_WHITE] = "Quality_White",		--白色
	[GameEnum.ITEM_COLOR_GREEN] = "bg_mirror_green",	--绿色
	[GameEnum.ITEM_COLOR_BLUE] = "bg_mirror_blue",		--蓝色
	[GameEnum.ITEM_COLOR_PURPLE] = "bg_mirror_purple", 	--紫色
	[GameEnum.ITEM_COLOR_ORANGE] = "bg_mirror_orange",	--橙色
	[GameEnum.ITEM_COLOR_RED] = "bg_mirror_red"	,		--红色
	[GameEnum.ITEM_COLOR_GLOD] = "bg_mirror_pink",		--粉色
	[GameEnum.ITEM_COLOR_JINGSE] = "bg_mirror_gold",	--金色
	[GameEnum.ITEM_COLOR_CAI] = "bg_mirror_gold",		--彩色
}

-- 角色人物装备格子品质
ROLE_EQUIP_QUALITY_ICON = {
	[GameEnum.ITEM_COLOR_WHITE] = "bg_mirror_green",	--白色
	[GameEnum.ITEM_COLOR_GREEN] = "bg_mirror_green",	--绿色
	[GameEnum.ITEM_COLOR_BLUE] = "bg_mirror_blue",		--蓝色
	[GameEnum.ITEM_COLOR_PURPLE] = "bg_mirror_purple", 	--紫色
	[GameEnum.ITEM_COLOR_ORANGE] = "bg_mirror_orange",	--橙色
	[GameEnum.ITEM_COLOR_RED] = "bg_mirror_red"	,		--红色
	[GameEnum.ITEM_COLOR_GLOD] = "bg_mirror_pink",		--金色
}

-- 角色人物装备格子品质(圆形)
EQUIP_STAR_QUALITY_ICON = {
	[GameEnum.ITEM_COLOR_WHITE] = "bg_22_green",	--白色
	[GameEnum.ITEM_COLOR_GREEN] = "bg_22_green",	--绿色
	[GameEnum.ITEM_COLOR_BLUE] = "bg_22_blue",		--蓝色
	[GameEnum.ITEM_COLOR_PURPLE] = "bg_22_purple", 	--紫色
	[GameEnum.ITEM_COLOR_ORANGE] = "bg_22_orange",	--橙色
	[GameEnum.ITEM_COLOR_RED] = "bg_22_red"	,		--红色
	[GameEnum.ITEM_COLOR_GLOD] = "bg_22_pink",		--粉色
	[GameEnum.ITEM_COLOR_JINGSE] = "bg_22_gold",	--金色
	[GameEnum.ITEM_COLOR_CAI] = "bg_22_gold",		--彩色
}

MOUNT_QUALITY_ICON = {
	[GameEnum.ITEM_COLOR_GREEN] = "Grade_Green",		--绿色
	[GameEnum.ITEM_COLOR_BLUE] = "Grade_Blue",			--蓝色
	[GameEnum.ITEM_COLOR_PURPLE] = "Grade_Purple", 		--紫色
	[GameEnum.ITEM_COLOR_ORANGE] = "Grade_Orange"	,	--橙色
	[GameEnum.ITEM_COLOR_RED] = "Grade_Red"	,			--红色
}

ITEM_COLOR = {
	[GameEnum.ITEM_COLOR_WHITE] = TEXT_COLOR.WHITE,					-- 白
	[GameEnum.ITEM_COLOR_GREEN] = TEXT_COLOR.GREEN_SPECIAL_1,		-- 绿
	[GameEnum.ITEM_COLOR_BLUE] = TEXT_COLOR.BULE_NORMAL,			-- 蓝
	[GameEnum.ITEM_COLOR_PURPLE] = TEXT_COLOR.PURPLE_3,				-- 紫
	[GameEnum.ITEM_COLOR_ORANGE] = TEXT_COLOR.ORANGE_4,				-- 橙
	[GameEnum.ITEM_COLOR_RED] = TEXT_COLOR.RED_4,					-- 红
	[GameEnum.ITEM_COLOR_GLOD] = TEXT_COLOR.PINK,					-- 粉红
	[GameEnum.ITEM_COLOR_JINGSE] = TEXT_COLOR.JINGSE,				-- 金色
	[GameEnum.ITEM_COLOR_CAI] = TEXT_COLOR.CAI,						-- 彩色
}

CHAT_ITEM_COLOR = {
	[GameEnum.ITEM_COLOR_WHITE] = RICH_TEXT_COLOR.WHITE,		-- 白
	[GameEnum.ITEM_COLOR_GREEN] = RICH_TEXT_COLOR.GREEN,		-- 绿
	[GameEnum.ITEM_COLOR_BLUE] = RICH_TEXT_COLOR.BLUE,			-- 蓝
	[GameEnum.ITEM_COLOR_PURPLE] = RICH_TEXT_COLOR.PURPLE,		-- 紫
	[GameEnum.ITEM_COLOR_ORANGE] = RICH_TEXT_COLOR.ORANGE,		-- 橙
	[GameEnum.ITEM_COLOR_RED] = RICH_TEXT_COLOR.RED,			-- 红
	[GameEnum.ITEM_COLOR_GLOD] = TEXT_COLOR.PINK,				-- 粉
	[GameEnum.ITEM_COLOR_JINGSE] = TEXT_COLOR.JINGSE,			-- 真金色
	[GameEnum.ITEM_COLOR_CAI] = TEXT_COLOR.CAI,					-- 彩色
}

--符文品质字体颜色
RUNE_COLOR = {
	[GameEnum.RUNE_COLOR_WHITE] = TEXT_COLOR.GREEN_SPECIAL_1,	--白
	[GameEnum.RUNE_COLOR_BLUE] = TEXT_COLOR.BLUE_5,				--蓝
	[GameEnum.RUNE_COLOR_PURPLE] = TEXT_COLOR.PURPLE_3,			--紫
	[GameEnum.RUNE_COLOR_ORANGE] = TEXT_COLOR.ORANGE_4,			--橙
	[GameEnum.RUNE_COLOR_RED] = TEXT_COLOR.RED_4,				--红
	[GameEnum.RUNE_COLOR_PINK] = TEXT_COLOR.PINK,				--粉
}

BUTTON_BG_NAME = {
	[GameEnum.ITEM_COLOR_WHITE] = "link_green",			-- 白
	[GameEnum.ITEM_COLOR_GREEN] = "link_green",			-- 绿
	[GameEnum.ITEM_COLOR_BLUE] = "link_blue",			-- 蓝
	[GameEnum.ITEM_COLOR_PURPLE] = "link_purple",		-- 紫
	[GameEnum.ITEM_COLOR_ORANGE] = "link_orange",		-- 橙
	[GameEnum.ITEM_COLOR_RED] = "link_red",				-- 红
	[GameEnum.ITEM_COLOR_GLOD] = "link_pink",			-- 金（粉色
	[GameEnum.ITEM_COLOR_JINGSE] = "link_yellow"			-- 真金色
}

--职业颜色
PROF_COLOR = {										-- 职业
	[GameEnum.ROLE_PROF_1] = TEXT_COLOR.GOLD,		-- 战士金色
	[GameEnum.ROLE_PROF_2] = TEXT_COLOR.BLUE,		-- 法师蓝色
	[GameEnum.ROLE_PROF_3] = TEXT_COLOR.RED,		-- 枪手红色
}

--羽翼坐骑颜色
GRADE_COCOR = {
	[0] = COLOR.GOLD,							--特殊羽翼金色
	[1] = COLOR.GREEN,							-- 绿
	[2] = COLOR.GREEN,
	[3] = COLOR.BLUE,							-- 蓝
	[4] = COLOR.BLUE,
	[5] = COLOR.BLUE,							-- 紫
	[6] = COLOR.BLUE,
	[7] = COLOR.PURPLE,							-- 橙
	[8] = COLOR.PURPLE,
	[9] = COLOR.PURPLE,							-- 红
	[10] = COLOR.ORANGE,
	[11] = COLOR.ORANGE,
	[12] = COLOR.RED,
	[13] = COLOR.RED,
	[14] = COLOR.RED,
	[15] = COLOR.RED,
}

SEX_COLOR = {
	[GameEnum.MALE] = COLOR.BLUE,			-- 男性蓝色
	[GameEnum.FEMALE] = COLOR.PURPLE,		-- 女性粉色
}

CAMP_COLOR = {
	[GameEnum.ROLE_CAMP_0] = COLOR.WHITE,				-- 白色
	[GameEnum.ROLE_CAMP_1] = COLOR.ORANGE,				-- 橙
	[GameEnum.ROLE_CAMP_2] = COLOR.GREEN,				-- 绿
	[GameEnum.ROLE_CAMP_3] = COLOR.BLUE,				-- 蓝
}

--现在可能有6种等级，第6种用红色代替
Common_Five_Rank_Color = {
	"green",                        --绿
	"blue",							--蓝
	"purple",						--紫
	"orange",						--橙
	"red",							--红
	"red",							--红
}

SPRITE_SKILL_LEVEL_COLOR = {
	[1] = TEXT_COLOR.GREEN_SPECIAL,
	[2] = TEXT_COLOR.BLUE_4,
	[3] = TEXT_COLOR.PURPLE_3,
	[4] = TEXT_COLOR.ORANGE_4,
}

Rune_Compose_Quality_Color = {
	[1] = TEXT_COLOR.GREEN_SPECIAL,
	[2] = TEXT_COLOR.BLUE_4,
	[3] = TEXT_COLOR.PURPLE_3,
	[4] = TEXT_COLOR.ORANGE_4,
	[5] = TEXT_COLOR.RED2,
}

ROLE_FOLLOW_UI_COLOR = {
	GUILD_NAME = "#00ff06",
	LOVER_NAME = "#ffe500",
	ROLE_NAME = "#00ffff",
}

function ToColorStr(str, color)
	str = str or ""
	color = color or COLOR.WHITE
	local color_str = "<color=%s>%s</color>"
	return string.format(color_str, color, str)
end

function GetRightColor(str,flag,satisfy_color,lack_color)
	local dispose_str = str
	if flag(str) then
		dispose_str = ToColorStr(str,satisfy_color)
	else
		dispose_str = ToColorStr(str,lack_color)
	end
	return dispose_str
end