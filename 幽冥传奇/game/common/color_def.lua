COLOR3B = {
	WHITE = cc.c3b(0xff, 0xff, 0xff),				-- 白
	GREEN = cc.c3b(0x1e, 0xff, 0x00),				-- 绿
	BRIGHT_GREEN = cc.c3b(0x00, 0xff, 0x00),		-- 鲜绿
	BLUE = cc.c3b(0x36, 0xc4, 0xff),				-- 蓝
	PURPLE = cc.c3b(0xa3, 0x35, 0xee),				-- 紫
	PURPLE2 = cc.c3b(0xde, 0x00, 0xff),				-- 紫
	ORANGE = cc.c3b(0xff, 0x7f, 0x00),				-- 橙
	RED = cc.c3b(0xff, 0x28, 0x28),					-- 红
	YELLOW = cc.c3b(0xff, 0xff, 0x00),				-- 黄
	G_Y = cc.c3b(0xf4, 0xff, 0x00),					-- 金黄
	GOLD = cc.c3b(0xff, 0xc8, 0x00),				-- 金色
	DULL_GOLD = cc.c3b(0xc7, 0xb3, 0x77),			-- 暗金
	BLACK = cc.c3b(0x00, 0x00, 0x00),				-- 黑
	BROWN = cc.c3b(0x51, 0x2b, 0x1b),				-- 棕色
	GRAY = cc.c3b(0xa6, 0xa6, 0xa6),				-- 灰色
	OLIVE = cc.c3b(0xed, 0xd9, 0xb2),				-- 橄榄色
	PINK = cc.c3b(0xdb, 0x70, 0xdb),				-- 粉色
	LIGHT_BROWN = cc.c3b(0x9c, 0x8b, 0x6f),			-- 茶色
	G_W = cc.c3b(0xb0, 0xa6, 0x94),					-- 灰白
	G_W2 = cc.c3b(0xf4, 0xe6, 0xcf),				-- 灰白亮
	R_Y = cc.c3b(0xbe, 0x87, 0x40),					-- 红黄
	DEEP_R_Y = cc.c3b(0xe3, 0x83, 0x49),			-- 深红黄
	DEEP_ORANGE = cc.c3b(0xe2, 0xb9, 0x3d),			-- 深桔色
	BROWN2 = cc.c3b(0xAF, 0x8E, 0x58),				-- 棕色2
	GRAY2 = cc.c3b(0x76, 0x73, 0x67),				-- 灰色2
	GRAY3 = cc.c3b(0x96, 0x94, 0x87),				-- 茶色
	ORANGE2 = cc.c3b(0xdb, 0x70, 0x24),				-- 茶色

	-- db7024
}

COLORSTR = {
	WHITE = "ffffff",				-- 白
	GREEN = "1eff00",				-- 绿
	BRIGHT_GREEN = "00ff00",		-- 鲜绿
	BLUE = "36c4ff",				-- 蓝
	PURPLE = "a335ee",				-- 紫
	PURPLE2 = "de00ff",				-- 紫
	ORANGE = "ff7f00",				-- 橙
	RED = "ff2828",					-- 红
	YELLOW = "ffff00",				-- 黄
	G_Y = "f4ff00",					-- 金黄
	GOLD = "ffc800",				-- 金色
	DULL_GOLD = "c7b377",			-- 暗金
	BLACK = "000000",				-- 黑
	BROWN = "512b1b",				-- 棕色
	GRAY = "a6a6a6",				-- 灰色
	OLIVE = "edd9b2",				-- 橄榄色
	PINK = "db70db",				-- 粉色
	LIGHT_BROWN = "9c8b6f",			-- 茶色
	G_W = "b0a694",					-- 灰白
	G_W2 = "f4e6cf",				-- 灰白亮
	R_Y = "be8740",					-- 红黄
	DEEP_R_Y = "e38349",			-- 深红黄
	DEEP_ORANGE = "e2b93d",			-- 深桔色
	GRAY3 = "969487"
}

COLOR4B = {
	BLACK = cc.c4b(0, 0, 0, 255),					-- 黑色
}

ITEM_COLOR = {	
	[GameEnum.ITEM_COLOR_WHITE] = COLOR3B.WHITE,	-- 白
	[GameEnum.ITEM_COLOR_GREEN] = COLOR3B.GREEN,	-- 绿
	[GameEnum.ITEM_COLOR_BLUE] = COLOR3B.BLUE,		-- 蓝
	[GameEnum.ITEM_COLOR_PURPLE] = COLOR3B.PURPLE,	-- 紫
	[GameEnum.ITEM_COLOR_ORANGE] = COLOR3B.ORANGE,	-- 橙
	[GameEnum.ITEM_COLOR_RED] = COLOR3B.RED,		-- 红
	[GameEnum.ITEM_COLOR_GLOD] = COLOR3B.G_Y,		-- 金
}
	
EQUIP_COLOR = {
	[GameEnum.EQUIP_COLOR_GREEN] = COLOR3B.GREEN,	-- 绿
	[GameEnum.EQUIP_COLOR_BLUE] = COLOR3B.BLUE,		-- 蓝
	[GameEnum.EQUIP_COLOR_PURPLE] = COLOR3B.PURPLE,	-- 紫
	[GameEnum.EQUIP_COLOR_ORANGE] = COLOR3B.ORANGE,	-- 橙
	[GameEnum.EQUIP_COLOR_RED] = COLOR3B.RED,		-- 红
	[GameEnum.EQUIP_COLOR_TEMP] = COLOR3B.G_Y,		-- 金
}

CAMP_COLOR = {
	[GameEnum.ROLE_CAMP_0] = "ffffff",				-- 白色
	[GameEnum.ROLE_CAMP_1] = "ff7f00",				-- 橙
	[GameEnum.ROLE_CAMP_2] = "1eff00",				-- 绿
	[GameEnum.ROLE_CAMP_3] = "36c4ff",				-- 蓝
}

STRENGTH_COLOR = {
	[0] = "1eff00",				-- 绿
	[1] = "1eff00",				-- 绿
	[2] = "1eff00",				-- 绿
	[3] = "1eff00",				-- 绿
	[4] = "1eff00",				-- 绿
	[5] = "1eff00",				-- 绿
	[6] = "1eff00",				-- 绿
	[7] = "1eff00",				-- 绿
	[8] = "1eff00",				-- 绿
	[9] = "1eff00",				-- 绿
	[10] = "1eff00",				-- 蓝
	[11] = "1eff00",				-- 蓝
	[12] = "1eff00",				-- 蓝
	[13] = "36c4ff",				-- 蓝
	[14] = "36c4ff",				-- 蓝
	[15] = "36c4ff",				-- 蓝
	[16] = "36c4ff",				-- 蓝
	[17] = "36c4ff",				-- 蓝
	[18] = "36c4ff",				-- 蓝
	[19] = "36c4ff",				-- 蓝
	[20] = "36c4ff",				-- 蓝
	[21] = "36c4ff",				-- 蓝
	[22] = "36c4ff",				-- 蓝
	[23] = "36c4ff",				-- 蓝
	[24] = "36c4ff",				-- 蓝
	[25] = "b446ff",				-- 紫
	[26] = "b446ff",				-- 紫
	[27] = "b446ff",				-- 紫
	[28] = "b446ff",				-- 紫
	[29] = "b446ff",				-- 紫
	[30] = "b446ff",				-- 紫
	[31] = "b446ff",				-- 紫
	[32] = "b446ff",				-- 紫
	[33] = "b446ff",				-- 紫
	[34] = "b446ff",				-- 紫
	[35] = "b446ff",				-- 紫
	[36] = "b446ff",				-- 紫
	[37] = "ff7f00",				-- 橙
	[38] = "ff7f00",				-- 橙
	[39] = "ff7f00",				-- 橙
	[40] = "ff7f00",				-- 橙
	[41] = "ff7f00",				-- 橙
	[42] = "ff7f00",				-- 橙
	[43] = "ff7f00",				-- 橙
	[44] = "ff7f00",				-- 橙
	[45] = "ff7f00",				-- 橙
	[46] = "ff7f00",				-- 橙
	[47] = "ff7f00",				-- 橙
	[48] = "ff7f00",				-- 橙
}

SEX_COLOR = {
	[GameEnum.MALE] = {"♂", "00ffff", cc.c3b(0x00, 0xff, 0xff)},		-- 男性蓝色
	[GameEnum.FEMALE] = {"♀", "db70db", cc.c3b(0xdb, 0x70, 0xdb)},		-- 女性粉色
}

CAMP_COLOR3B = {
	[GameEnum.ROLE_CAMP_0] = COLOR3B.WHITE,			-- 白色
	[GameEnum.ROLE_CAMP_1] = COLOR3B.ORANGE,		-- 橙
	[GameEnum.ROLE_CAMP_2] = COLOR3B.GREEN,			-- 绿
	[GameEnum.ROLE_CAMP_3] = COLOR3B.BLUE,			-- 蓝
}

-- 进阶颜色
JINJIE_COLOR3B = {
	[0] = COLOR3B.WHITE,							-- 白
	[1] = COLOR3B.GREEN,							-- 绿
	[2] = COLOR3B.GREEN,							
	[3] = COLOR3B.BLUE,								-- 蓝
	[4] = COLOR3B.BLUE,								
	[5] = COLOR3B.PURPLE,							-- 紫
	[6] = COLOR3B.PURPLE,							
	[7] = COLOR3B.ORANGE,							-- 橙
	[8] = COLOR3B.ORANGE,							
	[9] = COLOR3B.RED,								-- 红
	[10] = COLOR3B.RED,								
	[11] = COLOR3B.RED,								
}

NEW_EQUIP_COLOR = {					
	[0] = COLOR3B.WHITE,							-- 白
	[1] = COLOR3B.GREEN,							-- 绿
	[2] = COLOR3B.BLUE,								-- 蓝
	[3] = COLOR3B.PURPLE,							-- 紫
	[4] = COLOR3B.ORANGE,							-- 橙
}

--职业颜色
PROF_COLOR3B = {										-- 职业
	[GameEnum.ROLE_PROF_1] = cc.c3b(0x00, 0xff, 0xff),	-- 男性蓝色
	[GameEnum.ROLE_PROF_2] = cc.c3b(0xdb, 0x70, 0xdb),	-- 女性粉色
	[GameEnum.ROLE_PROF_3] = cc.c3b(0x00, 0xff, 0xff),	-- 男性蓝色
}

--仙女颜色
PERI_COLOR3B = {
	[1] = COLOR3B.WHITE,							-- 白
	[2] = COLOR3B.GREEN,							-- 绿
	[3] = COLOR3B.BLUE,								-- 蓝
	[4] = COLOR3B.PURPLE,							-- 紫
	[5] = COLOR3B.ORANGE,							-- 橙
	[6] = COLOR3B.RED,								-- 红
}

--仙女光环颜色
PERI_HALO_COCOR3B = {
	[0] = COLOR3B.WHITE,						
	[1] = COLOR3B.WHITE,							-- 绿
	[2] = COLOR3B.GREEN,							-- 蓝
	[3] = COLOR3B.BLUE,								-- 紫
	[4] = COLOR3B.PURPLE,							-- 橙
	[5] = COLOR3B.ORANGE,							-- 红
}

function C3b2Str(c3b)
	return string.format("%02x%02x%02x", c3b.r, c3b.g, c3b.b)
end

function Str2C3b(str)
	if nil == str or string.len(str) ~= 6 then
		ErrorLog("Str2C3b")
		return COLOR3B.WHITE
	end

	return cc.c3b(tonumber("0x" .. string.sub(str, 1, 2)) or 0xff,
		tonumber("0x" .. string.sub(str, 3, 4)) or 0xff,
		tonumber("0x" .. string.sub(str, 5, 6)) or 0xff)
end

function Str2C3bEx(str)
	if nil == str or string.len(str) ~= 8 then
		ErrorLog("Str2C3bEx")
		return COLOR3B.WHITE
	end

	return cc.c3b(tonumber("0x" .. string.sub(str, 3, 4)) or 0xff,
		tonumber("0x" .. string.sub(str, 5, 6)) or 0xff,
		tonumber("0x" .. string.sub(str, 7, 8)) or 0xff)
end

function UInt2C3b(value)
	-- 常用颜色快速转换
	if value == 0xffffffff or value == 0x00ffffff  then
		return cc.c3b(0xff, 0xff, 0xff)
	elseif value == 0xffff0000 or value == 0x00ff0000 then
		return cc.c3b(0xff, 0x00, 0x00)
	elseif value == 0xff00ff00 or value == 0x0000ff00 then
		return cc.c3b(0x00, 0xff, 0x00)
	end

	return cc.c3b(bit:_and(bit:_rshift(value, 16), 0xff), 
		bit:_and(bit:_rshift(value, 8), 0xff), 
		bit:_and(value, 0xff))
end

function IsC3bEqual(a, b)
	return a.r == b.r and a.g == b.g and a.b == b.b
end