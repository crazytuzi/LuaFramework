--Author:        bishaoqing
--DateTime:      2016-05-10 11:40:36
--Region:        UI布局通用配置项

--ui规范项
local UiCfg = {
    ----------------------------------------
    --字体
    sFontName = nil,
    ----------------------------------------

    ----------------------------------------
    --字号(单位：px)
    stFontSize = 
    {
        --一级页签/标题
        FirstTabsSize = 24,

        --标题类/按钮类/二级页签
        SecondTabsSize = 22,

        --常规信息/标题类文字过多时
        NormalSize = 20,

        --内容较多信息
        TooMuchWordsSize = 18,

        --极限最小字号
        MinimumSize = 16,
    },
    ----------------------------------------

    ----------------------------------------
    --各种字体颜色
    FontColor = 
    {
        --数字类
        NumberColor = cc.c4b(254, 239, 217, 255),

        --灰色按钮/白色装备
        GrayColor = cc.c4b(204, 204, 204, 255),

        --按钮/页签/标题
        ButtonTabsAndTitleColor = cc.c4b(247, 206, 150, 255),

        --蓝色装备
        BlueColor = cc.c4b(111, 170, 243, 255),

        --常规文本/一级页签暗色
        NormalAndGrayFirstTabColor = cc.c4b(189, 142, 107, 255),

        --紫色装备
        PurpleColor = cc.c4b(176, 88, 220, 255),

        --提示类/警示类
        TipAndWarningColor = cc.c4b(211, 46, 46, 255),

        --人名/货币
        NameAndMoneyColor = cc.c4b(255, 241, 121, 255),

        --亮色底板1
        LightedBgColor = cc.c4b(103, 64, 34, 255),

        --普通人名
        NomalNameColor = cc.c4b(255, 255, 255, 255),

        --亮色底板2
        LightedBg2Color = cc.c4b(38, 17, 8, 255),

        --橙装
        OrangeColor = cc.c4b(255, 153, 51, 255),

        --开启/达成/绿色装备
        GreenColor = cc.c4b(102, 255, 102, 255),
    },
    ----------------------------------------
    
    ----------------------------------------
    --ui布局(单位px)
    UiMargin = 
    {
        --可见区域宽度（规范图长条线）
        VisibleWidth = 960,

        --规范图绿色
        Green = 20,

        --规范图黄色
        Yellow = 23,

        --规范图洋红（叫不出来名字）
        Fuchsin = 60,

        --规范图白色
        White = 12,

        --规范图紫色
        Purple = 110,

        --规范图蓝色
        Blue = 4,

        --规范图红色
        Red = 8,
        
    },
    ----------------------------------------
}

return UiCfg