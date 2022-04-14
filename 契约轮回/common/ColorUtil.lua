-- 
-- @Author: LaoY
-- @Date:   2018-09-07 10:47:08
-- 

ColorUtil = {}
local this = ColorUtil

ColorUtil.ColorName =
{
	"White",
	"Green",
	"Blue",
	"Purple",
	"Orange",
	"Red",
	"Pink",
	"Yellow",
}

--颜色看 artsResource\字体\ziti.psd
ColorUtil.ColorType = {
	White  = 1,         --白色
	Green = 2,			--浅绿色(装备属性颜色)
	Blue = 3,			--蓝色(装备属性颜色)
	Purple = 4,			--紫色(装备属性颜色)
	Orange = 5,			--橙色(装备属性颜色)
	Red = 6,			--红色(装备属性颜色)
	Pink = 7,			--粉色(装备属性颜色)
	Yellow = 8,			--黄色(装备属性颜色)
	Apricot = 9,		--杏色	类似皮肤的颜色
	YellowWish = 10,	--淡黄色
	GreenDeep = 11,     --深绿色
	WhiteYellow = 12,   --偏白黄色
	--BlueWish = 13,      --淡蓝色  (玩家名字，头顶帮派)
	YellowWish2 = 14,	--淡黄色
	GrayWhite   = 15,   --灰白色我(装备属性名称)

	LinkGreen   = 16,   --链接 绿色

	Black = 99,         --黑色

	-- YellowWish = 9,		--淡黄色
	-- YellowWish = 9,		--淡黄色
}

local ColorList = {
	[ColorUtil.ColorType.White]     = "ffffff",
	[ColorUtil.ColorType.Green]		= "3ab60e",
	[ColorUtil.ColorType.Blue] 		= "49a3ff",
	[ColorUtil.ColorType.Purple] 	= "ae3aff",
	[ColorUtil.ColorType.Orange]	= "ff8942",
	[ColorUtil.ColorType.Red] 		= "eb0000",
	[ColorUtil.ColorType.Pink] 		= "e705af",
	[ColorUtil.ColorType.Yellow] 	= "ffcc00",
	[ColorUtil.ColorType.Apricot]	= "f0c78c",
	[ColorUtil.ColorType.YellowWish] = "ffe27c",
	[ColorUtil.ColorType.GreenDeep]	= "43f673",
	[ColorUtil.ColorType.WhiteYellow]	= "fef2b7",
	[ColorUtil.ColorType.YellowWish2]	= "FEEEA4",
	[ColorUtil.ColorType.GrayWhite] = "c1b7aa",
	[ColorUtil.ColorType.LinkGreen] = "00be00",
	[ColorUtil.ColorType.Black] = "000000",
}

local ColorList2 = {
    [ColorUtil.ColorType.White]     = "acacac",
    [ColorUtil.ColorType.Green]		= "76e153",
    [ColorUtil.ColorType.Blue] 		= "2cc1ff",
    [ColorUtil.ColorType.Purple] 	= "cc42ff",
    [ColorUtil.ColorType.Orange]	= "e46328",
    [ColorUtil.ColorType.Red] 		= "f53b3b",
    [ColorUtil.ColorType.Pink] 		= "ff58e5",
    [ColorUtil.ColorType.Yellow] 	= "ffff00",
    [ColorUtil.ColorType.Apricot]	= "f0c78c",
    [ColorUtil.ColorType.YellowWish] = "ffe27c",
    [ColorUtil.ColorType.GreenDeep]	= "43f673",
    [ColorUtil.ColorType.WhiteYellow]	= "fef2b7",
    [ColorUtil.ColorType.YellowWish2]	= "FEEEA4",
    [ColorUtil.ColorType.GrayWhite] = "c1b7aa",
    [ColorUtil.ColorType.LinkGreen] = "00be00",
}

function ColorUtil.GetColor(color_type)
	return ColorList[color_type]
end
--暗底
function ColorUtil.GetColor2(color_type)
    return ColorList2[color_type]
end

function ColorUtil.GetHtmlStr(color_type,str)
	return string.format("<color=#%s>%s</color>",ColorUtil.GetColor(color_type) or "",str)
end

---带颜色标签的颜色名字
function ColorUtil.GetColorNameWithColorTag(colorId)
	local colorName = ColorUtil.ColorName[colorId] or "Unkown"
	local colorValue = ColorUtil.GetColor(colorId) or "000000"

	return string.format("<color=#%s>%s</color>", colorValue, colorName)
end

function ColorUtil.GetColorName(colorId)
	return ColorUtil.ColorName[colorId]
end