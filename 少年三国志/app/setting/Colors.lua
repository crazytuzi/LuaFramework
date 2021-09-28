local Colors = {}

Colors.LightGray = ccc3(156, 156, 156)
Colors.Gray = ccc3(80,80,80)
Colors.Noraml = ccc3(255,255,255)
--弹出框背景颜色
Colors.modelColor = ccc4(0, 0, 0, 178) --70% alpha

--弹出文字默认颜色
Colors.tipTextColor = ccc3(0xff, 0xff, 0xcc)

Colors.strokeBlack = ccc3(0, 0, 0)
Colors.strokeBrown = ccc3(51, 0, 0)
Colors.strokeYellow = ccc3(237,198,0)
Colors.strokeGreen = ccc3(22 ,131,138)

Colors.strokeOrange = ccc3(242,121,13)  --倒计时时间 kaka add

Colors.activeSkill = ccc3(197, 45, 0)
Colors.inActiveSkill = ccc3(80, 62, 50)

-- 剧情副本列表 标题颜色
Colors.titleGreen = ccc3(0xb1, 0xef, 0x65)
Colors.titleRed = ccc3(0xc5, 0x2d, 0x00)

--页签的颜色
Colors.TAB_NORMAL = ccc3(0x46,0x27,0x09)   --未选中
Colors.TAB_DOWN = ccc3(0xff,0xe0,0x95)     --选中
Colors.TAB_GRAY = ccc3(0x33,0x33,0x33)       --禁用

Colors.PVP_WIN = ccc3(252, 213, 167)
Colors.PVP_LOSE = ccc3(224, 217, 201)

Colors.darkColors={
    TITLE_01 = ccc3(0xff,0xe1,0x11),  --一级标题
    TITLE_02 = ccc3(0xf1,0xdd,0x90),  --二级标题
    DESCRIPTION = ccc3(0xfe,0xf6,0xd8),   --描述字
    ATTRIBUTE = ccc3(0xb1,0xef,0x65),   --增加的属性值
    TIPS_01 = ccc3(0xf2,0x79,0x0d),  --明显的提示文字
    TIPS_02 = ccc3(0xe1,0xb2,0x7c),   --低调的说明文字
}

Colors.lightColors= {
    TITLE_01 = ccc3(0xff,0xe1,0x11),  --一级标题
    TITLE_02 = ccc3(0x83,0x5c,0x42),  --二级标题
    DESCRIPTION = ccc3(0x50,0x3e,0x32),   --描述字
    ATTRIBUTE = ccc3(0x35,0x8d,0x0a),   --增加的属性值

    TIPS_01 = ccc3(0xc5,0x2d,0x00),  --明显的提示文字
    TIPS_02 = ccc3(0xa8,0x74,0x26),   --低调的说明文字
}

--[[
    darkColors
    TITLE_01 267444497
    TITLE_02 15850896
    DESCRIPTION 16709336
    ATTRIBUTE 11661157
    TIPS_01 15890701
    TIPS_02 14791292

    lightColors
    TITLE_02 8608834
    DESCRIPTION 5258818
    ATTRIBUTE 3509514
    TIPS_01 12922112
    TIPS_02 11039782
]]

--[[
    白 0xd8d6af
    绿 0x22b33d
    蓝 0X009ef8
    紫 0xbe4bf9
    橙 0xff6204
    红 0xFF0033
    金 0xffe432
]]
--品质颜色
--Colors.qualityColors = {
--     ccc3(0xd8,0xd6,0xaf),    --白
--     ccc3(0x22,0xb3,0x3d),        --绿色
--     ccc3(0x00,0x9e,0xf8),         --蓝
--     ccc3(0xbe,0x4b,0xf9),    --紫
--     ccc3(0xff,0x62,0x04),    --橙
--     ccc3(0xFF,0x00,0x33),    --红
--     ccc3(0xff,0xe4,0x32)    --金色
--}

Colors.qualityColors = {
    ccc3(0xff,0xff,0xff), --白色
    ccc3(0x99,0xff,0x33), --绿色
    ccc3(0x00,0xde,0xff), -- 蓝色
    ccc3(0xf9,0x53,0xff), --紫色
    ccc3(0xff,0x81,0x24), --橙色
    ccc3(0xff,0x29,0x12), -- 红色
    ccc3(0xff,0xea,0x00), -- 金色
}

-- 十进制品质颜色值
Colors.qualityDecColors = 
{
    16777215,       -- 白色
    10092339,        -- 绿色
    57087,          -- 蓝色
    16339967,       -- 紫色
    16744740,       -- 橙色
    16722194,       -- 红色
    16771584,       -- 金色
    
}
function Colors.getRichTextValue(color)
    if color == nil then
        return 0
    end
    if color.r == nil or color.b == nil or color.g == nil then
        return 0
    end
    return color.r*math.pow(16,4) + color.g*math.pow(16,2)+color.b
end


--[[等级 背景图,根据qualityImages同颜色]]
Colors.levelImages = {
    "dengji_icon_bai.png", --白色
    "dengji_icon_lv.png", --绿色
    "dengji_icon_lan.png", --蓝色
    "dengji_icon_zi.png", --紫色
    "dengji_icon_cheng.png", --橙色
    "dengji_icon_hong.png", --红色
    "dengji_icon_jin.png", --金色
}

--常用的UI颜色
Colors.uiColors = {
   WHITE = ccc3(0xff, 0xff, 0xff), --普通文字 白色
   LYELLOW = ccc3(0xff, 0xff, 0xcc), --普通文字 米黄色
   YELLOW = ccc3(0xff, 0xff, 0x00), --普通文字  黄色   物品技能标题
   GREEN = ccc3(0x99, 0xff, 0x00), --普通文字  绿色   掉落产物积分等
   PURPLE = ccc3(0xf9, 0x53, 0xff), --普通文字  紫色
   RED = ccc3(0xff, 0x33, 0x33), --普通文字  红色  倒计时
   BLUE = ccc3(0x00, 0xcc, 0xff), --普通文字  蓝色 突出的名称或标注
   GRAY = ccc3(0x99, 0x99, 0x99), --普通文字  灰色 
    YELLOW2 = ccc3(0xff,0xff, 0x99), -- 新的黄色
    ORANGE = ccc3(0xff,0x66,0x00), --橙色
    BROWN = ccc3(0x33, 0x00, 0x00),--棕色
}


Colors.dropKnightQuality = {
    "ui/text/txt/zj_wjzs_baijiang.png",
    "ui/text/txt/zj_wjzs_lvjiang.png",
    "ui/text/txt/zj_wjzs_lanjiang.png",
    "ui/text/txt/zj_wjzs_zijiang.png",
    "ui/text/txt/zj_wjzs_chengjiang.png",
    "ui/text/txt/zj_wjzs_hongjiang.png",
    "ui/text/txt/zj_wjzs_jinjiang.png",
}

function Colors.getDecimalQuality( quality )
    if quality < 1 or quality > #Colors.qualityColors then
        quality = 1
    end
    local clr = Colors.qualityColors[quality]
    return clr.r * 256*256 + clr.g*256 + clr.b
end

function Colors.getColorText( quality )
    if quality < 1 or quality > 7 then 
        return ""
    end

    local arr = {
    "LANG_KNIGHT_COLOR_WHITE",
    "LANG_KNIGHT_COLOR_GREEN",
    "LANG_KNIGHT_COLOR_BLUE",
    "LANG_KNIGHT_COLOR_VIOLET",
    "LANG_KNIGHT_COLOR_ORANGE",
    "LANG_KNIGHT_COLOR_RED",
    "LANG_KNIGHT_COLOR_GOLDEN",
    }

    return arr[quality]
end

function Colors.getColor(quality)
    if quality < 1 or quality > #Colors.qualityColors then
        quality = 1
    end
    return Colors.qualityColors[quality]
end

return Colors
