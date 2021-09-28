local BagConst = {

    AWAKEN_ITEM_MAXTAG = 20,
    
    --包裹道具最大数量
    BAG_PROP_MAXNUM = 300,
    
    --碎片最大数量
    BAG_FRAGMENT_MAXNUM = 300,
    
    --碎片类型
    FRAGMENT_TYPE_KNIGHT = 1 ,              --knight碎片
    FRAGMENT_TYPE_EQUIPMENT = 2 ,           --装备碎片
    FRAGMENT_TYPE_PET = 3,                  --战宠碎片
    
    
    --抽卡消耗数量 
    DROP_KNIGHT_MONEY_CONSUMPTION_PER_TIME   = 10000 ,    --抽良品卡每次消耗10000银两
    DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME = 300,  --抽神将卡每次消耗300黄金
    DROP_KNIGHT_GOLD_CONSUMPTION_TEN_TIME = 2800,  --抽神将卡十连抽消耗2800
    DROP_KNIGHT_GOLD_CONSUMPTION_20_TIME = 4800,  --抽神将卡20连抽消耗4800
    
    --良将抽卡的CD时间
    GOOD_KNIGHT_CD = 10 *60,
    -- GOOD_KNIGHT_CD = 60,
    --极品抽卡的CD时间
    GOLD_KNIGHT_CD = 46 * 60 *60,
    -- GOLD_KNIGHT_CD = 60,
    --抽卡消耗类型  // 0 免费 1 招募令 2 币
    DROP_KNIGHT_CONSUMPTION_TYPE = {
        FREE=0,
        TOKEN=1,
        MONEY=2,
    },
    
    --道具类型 
    ITEM_TYPE ={
        KNIGHT_TOKEN = 10,--抽卡 令牌   //{GOOD=2,GODLY=3}  良品是2，神将是3
        SECRET_SHOP_REFRESH_TOKEN = 15, -- 神秘商店刷新令
    },
    
    --八卦阵图类型
    TRIGRAMS_TYPE = {
    	TIAN_TRIGRAM = 205,  --天挂盘
    	DI_TRIGRAM = 206,  --地挂盘
    	REN_TRIGRAM = 207,  --人挂盘
	},
	
    --包裹变化类型
    CHANGE_TYPE={
        PROP = 1,
        EQUIPMENT = 2,
        KNIGHT = 3,
        FRAGMENT = 4,
        TREASURE_FRAGMENT = 5,
        TREASURE = 6,
        DRESS = 6,
        AWAKEN_ITEM = 11,
        PET = 12,
        HERO_SOUL = 13, -- 将灵
    },
    
    --是否需要显示使用按钮的道具,根据Item_type
    SHOW_BTN_USE={1,8,9},
    
    --购买的货币类型
    PRICE_TYPE = {
        GOLD = 2,    -- 元宝
        ESSENCE = 6, --武魂
        SHENHUN = 11,  -- 神魂
        PETPOINT = 15,  -- 兽魂即战宠积分
        HERO_SOUL_POINT = 16, --灵玉
    },

    -- 品质枚举
    QUALITY_TYPE = {
        WHITE   = 1,
        GREEN   = 2,
        BLUE    = 3,
        PURPLE  = 4,
        ORANGE  = 5,
        RED     = 6,
        GOLD    = 7,
    }
}

return BagConst
