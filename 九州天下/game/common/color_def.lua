COLOR = {
	WHITE = "#ffffff",				-- 白
	GREY = "#808080",				-- 灰
	GREEN = "#00931F",  			-- 绿
	BLUE = "#25a3f5",				-- 蓝
	PURPLE = "#e35aff",				-- 紫
	ORANGE = "#ff5501",				-- 橙
	RED = "#ff0000", 				-- 红
	GOLD = "#d0cb74", 				-- 金
	YELLOW = "#fff334",   			-- 黄
	ANRED = "#fa4904",				-- 装备默认颜色
	FISHING = "#00ff00",            


	WU = "#ffffff",					-- 无
	WEI = "#ff5501",				-- 魏国
	QI = "#b71ada",					-- 齐国
	CHU = "#24a5ff",				-- 楚国
}

TEXT_COLOR = {
	WHITE = "#ffffff",			-- 白(按钮字/小标签字)
	RED = "#ff2929",			-- 红(提醒/不足)
	GOLD = "#ffff00",			-- 金(有关金币)
	GREEN = "#00931F",			-- 绿(有关数字)
	YELLOW = "#ffff00",			-- 黄
	BLUE = "#25a3f5",			-- 浅蓝(按钮下的小提示)
	PURPLE = "#ff00fd",			-- 紫
	ORANGE = "#ff9900",			-- 橙
	GRAY = "#636363ff",			-- 灰
	GRAY_BLUE = "#83b2e7ff",	-- 灰蓝
	GRAY_WHITE = "#B7D3F9FF",	-- 灰白（属性）
	LOWGREEN = "#2dcecfff",		-- 提醒
	GREEN_1 = "#40f466",		-- 通用描述数字颜色(浅绿)
	GREEN_2 = "#3fbc88",		-- 通用描述文字颜色(浅绿)
	GREEN_3 = "#33e45d",		-- 镉绿色(任务面板)
	GREEN_4 = "#00931f",		-- 第二版（绿）
	GREEN_5 = "#00ff00",		-- 
	GREEN_6 ="#02cb15",			-- 诡道法则(浅绿)
	GREEN_7 ="#00ff47",			-- 美人洗炼	
	BLUE_1 = "#b7d3f9",			-- 通用描述数字颜色(浅蓝)
	BLUE_2 = "#6098cb",			-- 通用描述文字颜色(浅蓝)
	BLUE_3 = "#2899f9",			-- 物品文字品质(浅蓝)
	BLUE_4 = "#0087df",			-- 
	PURPLE_1 = "#c56aff",		-- 通用描述数字颜色(浅紫)
	PURPLE_2 = "#934fc6",		-- 通用描述文字颜色(浅紫)
	PURPLE_3 = "#e35aff",		-- 物品文字品质(浅紫)
	PURPLE_4 = "#ee4fff",		-- 神器激活条件(浅紫)
	ORANGE_1 = "#ff8247",		-- 通用描述数字颜色(浅橙)
	ORANGE_2 = "#ba5f35",		-- 通用描述文字颜色(浅橙)
	ORANGE_3 = "#ff5501",		-- 物品文字品质(浅橙)
	RED_1 = "#ff3838",			-- 通用描述数字颜色(浅红)
	RED_2 = "#e75959",			-- 通用描述文字颜色(浅红)
	RED_3 = "#eb3434",			-- 物品文字品质(浅红)
	GRAY_1 = "#735c32",			-- 描述颜色(灰)
	BLACK_1 = "#503635",		-- 黑(聊天)
	Kill_COLOR = "#84410a",		-- 家族被杀传闻
	GOLD_2 = "#fdf63e",			-- 金色（破军）
	PURPLE_4 = "#9819e0",		-- 紫色 (女枪)
	PINK = "#fe40dc",			-- 粉红色 (弓箭手)
	BLUE_4 = "#23a2f4",			-- 蓝色 (琴女)
	ROLE_YELLOW = "#fff582",	-- 人物黄
	NPC_BLUE = "#24a5ff",		-- npc蓝
	PINK_2 = "#ff3fff",			-- 粉
	YELLOW_1 = "#FFFF00FF",      -- 玩家军衔，排名，Vip等级
	BLUE_5 = "#00CEE1FF",        -- 坐标蓝色
	GREEN_SPECIAL = "#00ff06",  -- 通用描述文字颜色(绿色)
	PURPLE2 = "#fc00f3",
	ORANGE2 = "#ffb400",		-- 橙
	GRAY_2 = "#532f1e",			-- 灰
	GRAY_3= "#854100",			-- 灰
}

-- 颜色从品质低到高
SOUL_NAME_COLOR = {
	"#029120",					-- 绿色
	"#0087DF",					-- 蓝色
	"#BE01E5",			    	-- 紫色
	"#FA4904",			    	-- 橙色
	"#D80303",					-- 红色
	"#FF3FFF",					-- 粉色
}

--频道文字描边颜色
CHANEL_TEXT_OUTLINE_COLOR = {
	[CHANNEL_TYPE.ALL] = Color(0.0039, 0.0784, 0.4, 1),
	[CHANNEL_TYPE.WORLD] = Color(0.2862, 0.0470, 0.0078, 0.86),
	[CHANNEL_TYPE.GUILD] = Color(0.6352, 0.2078, 0, 1),
	[CHANNEL_TYPE.TEAM] = Color(0.2000, 0.0078, 0.3608, 1),
	[CHANNEL_TYPE.SYSTEM] = Color(0.0039, 0.3294, 0.5294, 1),
	[CHANNEL_TYPE.SPEAKER] = Color(0.5019, 0.1764, 0, 1),
	[CHANNEL_TYPE.CAMP] =  Color(0.3333, 0.0157, 0.0157, 1),
}

QUALITY_ICON = {
	[GameEnum.ITEM_COLOR_WHITE] = "bg_cell_common",		--白色
	[GameEnum.ITEM_COLOR_GREEN] = "bg_cell_color_1",	--绿色
	[GameEnum.ITEM_COLOR_BLUE] = "bg_cell_color_2",		--蓝色
	[GameEnum.ITEM_COLOR_PURPLE] = "bg_cell_color_3", 	--紫色
	[GameEnum.ITEM_COLOR_ORANGE] = "bg_cell_color_4",	--橙色
	[GameEnum.ITEM_COLOR_RED] = "bg_cell_color_5"	,	--红色
	[GameEnum.ITEM_COLOR_GLOD] = "bg_cell_color_6",		--金色
}

MOUNT_QUALITY_ICON = {
	[GameEnum.ITEM_COLOR_GREEN] = "Grade_Green",		--绿色
	[GameEnum.ITEM_COLOR_BLUE] = "Grade_Blue",			--蓝色
	[GameEnum.ITEM_COLOR_PURPLE] = "Grade_Purple", 		--紫色
	[GameEnum.ITEM_COLOR_ORANGE] = "Grade_Orange"	,	--橙色
	[GameEnum.ITEM_COLOR_RED] = "Grade_Red"	,			--红色
}

ITEM_COLOR = {
	[GameEnum.ITEM_COLOR_WHITE] = TEXT_COLOR.WHITE,		-- 白
	[GameEnum.ITEM_COLOR_GREEN] = TEXT_COLOR.GREEN,		-- 绿
	[GameEnum.ITEM_COLOR_BLUE] = TEXT_COLOR.BLUE,		-- 蓝
	[GameEnum.ITEM_COLOR_PURPLE] = TEXT_COLOR.PURPLE_3,	-- 紫
	[GameEnum.ITEM_COLOR_ORANGE] = TEXT_COLOR.ORANGE_3,	-- 橙
	[GameEnum.ITEM_COLOR_RED] = TEXT_COLOR.RED,			-- 红
	[GameEnum.ITEM_COLOR_GLOD] = TEXT_COLOR.PINK_2,		-- 粉
}

--符文品质字体颜色
RUNE_COLOR = {
	[GameEnum.RUNE_COLOR_WHITE] = TEXT_COLOR.WHITE,			--白
	[GameEnum.RUNE_COLOR_BLUE] = TEXT_COLOR.BLUE_3,			--蓝
	[GameEnum.RUNE_COLOR_PURPLE] = TEXT_COLOR.PURPLE_3,		--紫
	[GameEnum.RUNE_COLOR_ORANGE] = TEXT_COLOR.ORANGE_3,		--橙
	[GameEnum.RUNE_COLOR_RED] = TEXT_COLOR.RED_3,			--红
}

BUTTON_BG_NAME = {
	[GameEnum.ITEM_COLOR_WHITE] = "link_green",			-- 白
	[GameEnum.ITEM_COLOR_GREEN] = "link_green",			-- 绿
	[GameEnum.ITEM_COLOR_BLUE] = "link_blue",			-- 蓝
	[GameEnum.ITEM_COLOR_PURPLE] = "link_purple",		-- 紫
	[GameEnum.ITEM_COLOR_ORANGE] = "link_orange",		-- 橙
	[GameEnum.ITEM_COLOR_RED] = "link_red",				-- 红
	[GameEnum.ITEM_COLOR_GLOD] = "link_green",			-- 金
}

--职业颜色
PROF_COLOR = {										-- 职业
	[GameEnum.ROLE_PROF_1] = TEXT_COLOR.GOLD_2,		-- 破军金色
	[GameEnum.ROLE_PROF_2] = TEXT_COLOR.PURPLE_4,	-- 女枪紫色
	[GameEnum.ROLE_PROF_3] = TEXT_COLOR.BLUE_4,		-- 弓箭手蓝色
	[GameEnum.ROLE_PROF_4] = TEXT_COLOR.PINK,		-- 琴女粉色
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
	[GameEnum.ROLE_CAMP_1] = COLOR.QI,					-- 齐
	[GameEnum.ROLE_CAMP_2] = COLOR.CHU,					-- 楚
	[GameEnum.ROLE_CAMP_3] = COLOR.WEI,					-- 魏
}

-- 国家官职名字颜色
CAMP_POST_NAME = {
	[CAMP_POST.CAMP_POST_KING] = "#e35aff",					-- 紫
	[CAMP_POST.CAMP_POST_DASIMA] = "#e35aff",				-- 紫
	[CAMP_POST.CAMP_POST_DAJIANGJUN] = "#e35aff",			-- 紫
	[CAMP_POST.CAMP_POST_CHEJIJIANGJUN] = "#e35aff",		-- 紫
	[CAMP_POST.CAMP_POST_YUSHIDAFU] = "#e35aff",			-- 紫
	[CAMP_POST.CAMP_POST_JINGYINGGUOMIN] = "#25a3f5",		-- 蓝
	[CAMP_POST.CAMP_POST_GUOMIN] = "#84410a",				-- 普通颜色
}

YUNBIAO_COLOR = {
	[GameEnum.YUNBIAO_COLOR_GREEN] = COLOR.GREEN,
	[GameEnum.YUNBIAO_COLOR_BLUE] = COLOR.BLUE,
	[GameEnum.YUNBIAO_COLOR_PURPLE] = COLOR.PURPLE,
	[GameEnum.YUNBIAO_COLOR_ORANGE] = COLOR.ORANGE,
	[GameEnum.YUNBIAO_COLOR_RED] = COLOR.RED,
}

Common_Five_Rank_Color = {
	"green",                        --绿
	"blue",							--蓝
	"purple",						--紫
	"orange",						--橙
	"red",							--红
}

GUILD_NAME_COLOR = {
	[GUILD_POST_TYPE.GUILD_POST_CHENG_YUAN] = "#25a3f5",			-- 白色
	[GUILD_POST_TYPE.GUILD_POST_JINGYING] = "#25a3f5",				-- 绿色
	[GUILD_POST_TYPE.GUILD_POST_HUFA] = "#25a3f5",					-- 蓝色
	[GUILD_POST_TYPE.GUILD_POST_ZHANG_LAO] = "#25a3f5",				-- 紫色
	[GUILD_POST_TYPE.GUILD_POST_FU_TUANGZHANG] = "#25a3f5",			-- 橙色
	[GUILD_POST_TYPE.GUILD_POST_TUANGZHANG] = "#25a3f5",			-- 红色
}

ADVANCE_SKILL_LEVEL_COLOR = {
	[1] = TEXT_COLOR.GREEN,
	[2] = TEXT_COLOR.BLUE,
	[3] = TEXT_COLOR.PURPLE,
	[4] = "#ff7300ff",
	[5] = TEXT_COLOR.RED,
}

SHEN_GE_QUALITY = {
	[1] = TEXT_COLOR.BLUE,
	[2] = TEXT_COLOR.PURPLE,
	[3] = TEXT_COLOR.ORANGE,
	[4] = TEXT_COLOR.RED,
	[5] = TEXT_COLOR.GOLD,
	[6] = TEXT_COLOR.PINK,
}

-- 宝宝颜色
BAOBAO_COLOR = {
	"#0000f1",
	"Fuchsia",
	"#FFFF00",
}

-- 宝宝守护精灵从品质低到高
BAOBAO_SPRITE_COLOR = {
	"#00ff06",					-- 绿色
	"#26baff",					-- 蓝色
	"#fc00f3",					-- 紫色
	"#fc4d00",					-- 橙色
}

function ToColorStr(str, color)
	str = str or ""
	color = color or COLOR.WHITE
	local color_str = "<color=%s>%s</color>"
	return string.format(color_str, color, str)
end

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
