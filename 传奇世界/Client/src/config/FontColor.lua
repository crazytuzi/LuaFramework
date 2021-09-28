local M = {
	white = cc.c3b(254, 254, 254),
	lable_yellow = cc.c3b(247, 206, 150),
	lable_black = cc.c3b(189, 142, 107),
	red = cc.c3b(171, 42, 27),
	green = cc.c3b(102, 255, 102),
	gray = cc.c3b(204, 204, 204),
	blue = cc.c3b(111, 170, 243),
	purple = cc.c3b(176, 88, 220),
	yellow = cc.c3b(255, 241, 121),
    alarm_red = cc.c3b(211, 46, 46),
	lable_outLine = cc.c3b(24, 17, 14),
	brown_gray = cc.c3b(38, 17, 8),
	deep_brown = cc.c3b(96,46,23),--cc.c3b(128,92,53),
	deep_purple = cc.c3b(255, 0, 255),

	black = cc.c3b(30, 30, 30),
	orange = cc.c3b(225, 153, 51),
	brown = cc.c3b(103,65,34),
	yellow_gray = cc.c3b(215, 195, 114),
    gold = cc.c3b(255, 240, 119),
    drop_white = cc.c3b(254, 239, 217),
    name_gray = cc.c3b(148, 107, 74),
    name_red = cc.c3b(251, 0, 0),
    name_green = cc.c3b(0, 251, 0),
    name_blue = cc.c3b(16, 74, 222),
    name_yellow = cc.c3b(247, 231, 0),
    name_orange = cc.c3b(255, 119, 0),

    orange_shallow = cc.c3b(188, 142, 108),
    orange_deep = cc.c3b(255, 241, 118),
}

local QualityColor = 
{
	[1] = M.white,
	[2] = M.green,
	[3] = M.blue,
	[4] = M.purple,
	[5] = M.orange,
}

function M:getQualityColor( nQuality )
	-- body
	return QualityColor[nQuality] or M.white
end

local names = {
	[M.white] = "白色",
	[M.black] = "黑色",
	[M.green] = "绿色",
	[M.blue] = "蓝色",
	[M.purple] = "紫色",
	[M.orange] = "橙色",
	[M.yellow] = "黄色",
	[M.red] = "红色",
	[M.brown] = "棕色",
	[M.gray] = "灰色",
	[M.yellow_gray] = "暗黄色",
	[M.lable_yellow] = "标签黄",
	[M.lable_black] = "标签黑",
	[M.lable_outLine] = "描边黑",
	[M.brown_gray] = "暗棕色",
	[M.deep_brown] = "深棕色",
	[M.deep_purple] = "紫红色",
}

function M:name(color)
	return names[color]
end
-----------------------
MColor = M
-----------------------
return M

