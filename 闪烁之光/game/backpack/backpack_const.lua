BackPackConst = BackPackConst or {}

-- 物品大类
BackPackConst.Bag_Code = {
    BACKPACK            = 1,                -- 背包
    STORAGE             = 2,                -- 仓库
    EQUIPS              = 3,                -- 装备
    HOME                = 4,                -- 家园
    PETBACKPACK         = 5,                -- 宠物道具背包
}

--获取方式活动背包
BackPackConst.Gain_To_Bag_Code = {
    [1] = BackPackConst.Bag_Code.BACKPACK,
    [2] = BackPackConst.Bag_Code.EQUIPS,
    -- [4] = BackPackConst.Bag_Code.BACKPACK,
    -- [5] = BackPackConst.Bag_Code.BACKPACK,
    [6] = BackPackConst.Bag_Code.HOME,
    [7] = BackPackConst.Bag_Code.PETBACKPACK,
    -- [9] = BackPackConst.Bag_Code.BACKPACK,
    -- [10] = BackPackConst.Bag_Code.BACKPACK,
}

-- 用于判断的物品类型
BackPackConst.item_type = {
    NORMAL              = 0,                -- 普通
    WEAPON              = 1,                -- 武器
    SHOE                = 2,                -- 鞋子
    CLOTHES             = 3,                -- 衣服
    HAT                 = 4,                -- 头盔
    ASSET               = 7,                -- 资产
    MATERIALS           = 9,                -- 材料
    ARTIFACTCHIPS       = 10,               -- 神器(现在叫 符文)
    GOD_EARRING         = 23,               --神装_耳环
    GOD_RING            = 24,               --神装_戒指
    GOD_NECKLACE        = 25,               --神装_项链
    GOD_BANGLE          = 26,               --神装_手镯
    WEEK_CARD           = 27,               --周卡

    HERO_SKIN           = 28,               --英雄皮肤
    HERO_HUN            = 29,               --英魂(前后端统一命名的)

    HOME_PET_ITEM       = 31,               --萌宠道具
    HOME_PET_FOOD       = 32,               --萌宠食物
    HOME_PET_TREASURE   = 33,               --萌宠特产
    HOME_PET_PHOTO      = 34,               --萌宠明信片
    HOME_PET_LITTER     = 35,               --萌宠日记

    ELFIN               = 36,               --精灵
    ELFIN_EGG           = 37,               --精灵蛋
    ELFIN_ITEM          = 38,               --精灵孵化道具（锤子）

    GIFT                = 100,              -- 礼包
    FREE_GIFT           = 101,              -- 自选礼包
    PARTNER_DEBRIS      = 102,              -- 伙伴碎片
    STAR_SOUL           = 105,              -- 星命
}
-- 背包中的物品种类
BackPackConst.item_tab_type = {
    OTHERS              = 0,                -- 其他
    EQUIPS              = 1,                -- 装备
    PROPS               = 2,                -- 道具
    HERO                = 3,                -- 英雄
    SPECIAL             = 4,                -- 特殊
    HOLYEQUIPMENT       = 5,                -- 神装
    ELFIN               = 6,                -- 精灵

    HOMEPET_FOOD        = 98,                -- 萌宠食物
    HOMEPET_ITEM        = 99,                -- 萌宠道具
}

-- 背包中物品的使用类型,只区分消耗和非消耗类
BackPackConst.item_use_type = {
    NO_DIRECT_USE       = 0,                -- 不能直接使用
    CONSUM              = 1,                -- 消耗,直接使用的
    NO_CONSUM           = 2,                -- 不消耗
    EQUIP               = 3,                -- 穿戴
    BATCH_USE           = 4,                -- 批量使用
}

-- 物品的使用效果,使用这个物品可以获得
BackPackConst.item_effect_type = {
    GOLD = 1,                   -- 使用这类物品可以获得钻石
    COIN = 2,
    EXP = 3,
    PARTNER_EXP = 4,            -- 获得伙伴经验
    PARTNER_DEBRIS = 5,         -- 伙伴碎片
    BUFF = 6,                   -- buff
    PARTNER = 7,                -- 获得伙伴
    GIFT = 8                    -- 商城特惠礼包时效
}

-- 物品来源的
BackPackConst.item_source_type = {
    evt_partner_call = "evt_partner_call",          -- 伙伴召唤来源
    evt_mall_buy = "evt_mall_buy",                  -- 商城购买来源
    evt_dun_chapter = "evt_dun_chapter",            -- 剧情副本,包含了地下城
    evt_activity = "evt_activity",                  -- 活动
    evt_dungeon = "evt_dungeon",                    -- 装备副本
    evt_vip = "evt_vip",                            -- 跳转到vip面板
    evt_farplane = "evt_farplane",                            -- 跳转到异界裂缝
    evt_eqm_bag = "evt_eqm_bag",                    --跳转到装备背包
    evt_refine = "evt_refine",                      --跳转到装备制作
    evt_artifact = "evt_artifact",                  --神器铸造
    evt_tower = "evt_tower",                        --困难塔
    evt_halo = "evt_halo",                          --光环制作
    evt_compose = "evt_compose",                    --幸运石合成
    evt_world_boss = "evt_world_boss",              --世界boss
    evt_world_mon = "evt_world_mon",                --诸神大陆
}

--物品消耗使用还是出售
ItemConsumeType = 
{
    use = 1,
    sell = 2,
    resolve = 3,
    special = 4,
} 

BackPackConst.Big_Energy_ID = 10401
BackPackConst.Small_Energy_ID = 10400

EQUIP_PUT_TYPE =
{
    PUT_ON = 1,   --穿戴
    TAKE_OFF = 2, --脱下
    OFF = 3,      --没有标签
}
--格子状态
GridsCellState =
{
   lock = 1,  --未开启
   open = 2,  --已开启
   full = 3,  --有物品
}

--品质色
BackPackConst.quality_color = {
  [0] = Config.ColorData.data_color4[1],      --白
  [1] = Config.ColorData.data_color4[178],     --绿
  [2] = Config.ColorData.data_color4[203],     --蓝
  [3] = Config.ColorData.data_color4[185],     --紫
  [4] = Config.ColorData.data_color4[184],     --橙
  [5] = Config.ColorData.data_color4[206],     --红
}

--品质色
BackPackConst.quality_3_color = {
  [0] = Config.ColorData.data_color3[1],      --白
  [1] = Config.ColorData.data_color3[178],     --绿
  [2] = Config.ColorData.data_color3[203],     --蓝
  [3] = Config.ColorData.data_color3[185],     --紫
  [4] = Config.ColorData.data_color3[184],     --橙
  [5] = Config.ColorData.data_color3[206],     --红
}

-- 物品的品质
BackPackConst.quality = {
    white = 0,          -- 白
    green = 1,          -- 绿
    blue = 2,           -- 蓝
    purple = 3,         -- 紫
    orange = 4,         -- 橙
    red = 5             -- 红
}

BackPackConst.quality_color_id = {
    [0] = 1,
    [1] = 178,
    [2] = 203,
    [3] = 185,
    [4] = 184,
    [5] = 206
}

BackPackConst.ref_color = {
    [0] = 265,
    [1] = 266,
    [2] = 267,
    [3] = 268,
    [4] = 269,
    [5] = 270
}

--神装阶名字
BackPackConst.holyequip_jie_name = {
    [0] = TI18N("凡品"),
    [1] = TI18N("良品"),
    [2] = TI18N("极品")
}

-- 物品的品质颜色
BackPackConst.quality_name = {
    [0] = TI18N("白色"),
    [1] = TI18N("绿色"),
    [2] = TI18N("蓝色"),
    [3] = TI18N("紫色"),
    [4] = TI18N("橙色"),
    [5] = TI18N("红色"),
}

-- 物品的星级颜色
BackPackConst.star_name = {
    [1] = TI18N("一星"),
    [2] = TI18N("二星"),
    [3] = TI18N("三星"),
    [4] = TI18N("四星"),
    [5] = TI18N("五星"),
    [6] = TI18N("六星"),
}

--选中格子类型
BackPackConst.cb_type =
{
   all = 1,      --全部
   quality = 2,  --品质
   star = 3,     --星级
}

--神装装备空置背景图
BackPackConst.holy_equip_icon_name_list = {
    [BackPackConst.item_type.GOD_EARRING]   = "hero_info_25",  --耳环
    [BackPackConst.item_type.GOD_RING]      = "hero_info_27",  --戒指
    [BackPackConst.item_type.GOD_NECKLACE]  = "hero_info_26",  --项链
    [BackPackConst.item_type.GOD_BANGLE]    = "hero_info_28",  --手镯
}

--神装装备放置位置顺序
BackPackConst.holy_equip_name_suffix = {
    [BackPackConst.item_type.GOD_EARRING]  = 1,  --耳环
    [BackPackConst.item_type.GOD_NECKLACE] = 2,  --项链
    [BackPackConst.item_type.GOD_RING]     = 3,  --戒指
    [BackPackConst.item_type.GOD_BANGLE]   = 4,  --手镯   
}

--物品tips按钮需要枚举
-----------------------------------------

BackPackConst.tips_btn_type = {
    source = 1,             --来源
    goods_use = 2,          --普通物品使用
    boss_source = 3,        --跳转世界boss界面
    drama_new_source = 4,   --跳转剧情副本最新的关卡页面
    drama_source = 5,       --跳转剧情副本界面
    hero_source = 6,        --跳转英雄信息界面
    skill_source = 7,       --跳转英雄技能界面
    form_source = 8,        --跳转编队阵法界面
    call_source = 9,        --跳转召唤界面
    artifact_source = 10,   --跳转神器重铸界面
    redbag = 11,            --红包
    head = 12,              --个人设置头像
    chenghao = 13,          --个人设置称号
    stone_upgrade = 14,     --跳转宝石升级界面
    partner_character = 15, --跳转形象设置
    arena_source      = 16, --跳转竞技场
    low_treasure      = 17, --跳转幸运探宝
    high_treasure      = 18, --跳转高级探宝
    seerpalace_summon = 19, -- 先知殿
    seerpalace_change = 20, -- 先知召唤
    sell = 21,              --出售
    heaven_dial_1 = 22,     --跳转天界祈祷(战神)
    heaven_dial_2 = 23,     --跳转天界祈祷(智慧)
    heaven_dial_3 = 24,     --跳转天界祈祷(烈阳)
    heaven_dial_4 = 25,     --跳转天界祈祷(大地)
    heaven_dial_5 = 26,     --跳转天界祈祷(圣洁)
    fenjie = 30,            --分解
    hecheng = 31,           --英雄碎片合成
    hecheng2 = 32,          --神器合成
    upgrade_star = 33,      -- 伙伴直升卡,升星的
    halidom = 34,           -- 跳转到圣物
    heaven_book = 35,       -- 神装图鉴
    heaven_shop = 36,       -- 神装商店

    item_sell  =  37,       --道具出售 --by lwc
    hero_reset =  38,       --英雄重生 --by lwc
    resonate =  39,         --共鸣界面 --by lwc

    elfin_hatch = 40,       --跳转到精灵孵化(使用精灵蛋或孵化道具)
    elfin_rouse = 41,       --跳转到精灵古树(使用古树培养道具)

    petard = 42,            -- 花火大会
    return_action = 43,            -- 回归活动
    herosoul_shop = 44,     -- 英魂商店
    elfin_egg_synthetic = 45,     -- 精灵蛋合成
    elfin_summon = 46,       --跳转到精灵召唤
}

BackPackConst.tips_btn_title ={
    [BackPackConst.tips_btn_type.source]            = TI18N("来源"),
    [BackPackConst.tips_btn_type.goods_use]         = TI18N("使用"),
    [BackPackConst.tips_btn_type.boss_source]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.drama_new_source]  = TI18N("使用"),
    [BackPackConst.tips_btn_type.drama_source]      = TI18N("使用"),
    [BackPackConst.tips_btn_type.hero_source]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.skill_source]      = TI18N("使用"),
    [BackPackConst.tips_btn_type.form_source]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.call_source]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.artifact_source]   = TI18N("重铸"),
    [BackPackConst.tips_btn_type.redbag]            = TI18N("使用"),
    [BackPackConst.tips_btn_type.head]              = TI18N("使用"),
    [BackPackConst.tips_btn_type.chenghao]          = TI18N("使用"),
    [BackPackConst.tips_btn_type.stone_upgrade]     = TI18N("使用"),
    [BackPackConst.tips_btn_type.partner_character] = TI18N("使用"),
    [BackPackConst.tips_btn_type.arena_source]      = TI18N("使用"),
    [BackPackConst.tips_btn_type.low_treasure]      = TI18N("使用"),
    [BackPackConst.tips_btn_type.high_treasure]     = TI18N("使用"),
    [BackPackConst.tips_btn_type.sell]              = TI18N("出售"),
    [BackPackConst.tips_btn_type.heaven_dial_1]     = TI18N("使用"),
    [BackPackConst.tips_btn_type.heaven_dial_2]     = TI18N("使用"),
    [BackPackConst.tips_btn_type.heaven_dial_3]     = TI18N("使用"),
    [BackPackConst.tips_btn_type.heaven_dial_4]     = TI18N("使用"),
    [BackPackConst.tips_btn_type.heaven_dial_5]     = TI18N("使用"),
    [BackPackConst.tips_btn_type.fenjie]            = TI18N("分解"),
    [BackPackConst.tips_btn_type.hecheng]           = TI18N("合成"),
    [BackPackConst.tips_btn_type.hecheng2]          = TI18N("合成"),
    [BackPackConst.tips_btn_type.upgrade_star]      = TI18N("使用"),
    [BackPackConst.tips_btn_type.seerpalace_summon] = TI18N("使用"),
    [BackPackConst.tips_btn_type.seerpalace_change] = TI18N("使用"),
    [BackPackConst.tips_btn_type.halidom]           = TI18N("使用"),
    [BackPackConst.tips_btn_type.heaven_book]       = TI18N("神装图鉴"),
    [BackPackConst.tips_btn_type.heaven_shop]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.item_sell]         = TI18N("出售"),
    [BackPackConst.tips_btn_type.hero_reset]         = TI18N("使用"),
    [BackPackConst.tips_btn_type.resonate]         = TI18N("使用"),
    [BackPackConst.tips_btn_type.elfin_hatch]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.elfin_rouse]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.petard]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.return_action]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.herosoul_shop]       = TI18N("使用"),
    [BackPackConst.tips_btn_type.elfin_egg_synthetic]       = TI18N("合成"),
    [BackPackConst.tips_btn_type.elfin_summon]       = TI18N("使用"),
    
}

function BackPackConst.checkIsEquip(_type)
    if _type == BackPackConst.item_type.WEAPON or  --武器
        _type == BackPackConst.item_type.CLOTHES or  --衣服
        _type == BackPackConst.item_type.HAT or      --帽子
        _type == BackPackConst.item_type.GOD_EARRING or      --神装_耳环
        _type == BackPackConst.item_type.GOD_RING or         --神装_戒指
        _type == BackPackConst.item_type.GOD_NECKLACE or     --神装_项链
        _type == BackPackConst.item_type.GOD_BANGLE or       --神装_手镯
        _type == BackPackConst.item_type.SHOE then    --鞋子
        return true
    end
    return false
end

--是否周卡
function BackPackConst.checkoutIsWeekCard(data_type)
    if data_type then
        if data_type == BackPackConst.item_type.WEEK_CARD then
            return true
        else
            return false
        end
    end
    return false
end

--是否是神装
function BackPackConst.checkIsHolyEquipment(_type)
    if not _type then return false end
    if  _type == BackPackConst.item_type.GOD_EARRING or      --神装_耳环
        _type == BackPackConst.item_type.GOD_RING or         --神装_戒指
        _type == BackPackConst.item_type.GOD_NECKLACE or     --神装_项链
        _type == BackPackConst.item_type.GOD_BANGLE then     --神装_手镯
        return true
    end
    return false
end


--是否是英雄皮肤
function BackPackConst.checkIsHeroSkin(_type)
    if not _type then return false end
    if  _type == BackPackConst.item_type.HERO_SKIN then
        return true
    end
    return false
end

function BackPackConst.checkIsArtifact(type)
    return type == BackPackConst.item_type.ARTIFACTCHIPS
end

-- 是否为精灵孵化道具（锤子）
function BackPackConst.chekcIsElfinItem( _type )
    return _type == BackPackConst.item_type.ELFIN_ITEM
end

-- 是否为精灵蛋
function BackPackConst.checkIsElfinEgg( _type )
    return _type == BackPackConst.item_type.ELFIN_EGG
end

-- 是否为精灵
function BackPackConst.checkIsElfin( _type )
    return _type == BackPackConst.item_type.ELFIN
end

--- 装备tips上面的品质色 格式c4b(r,g,b,a) (在暗底上的)
function BackPackConst.getEquipTipsColor(quality)
    return BackPackConst.getBlackQualityColorC4B(quality)
end

--获取黑底(暗底) 对应品质颜色码 格式  c4b(r,g,b,a)
function BackPackConst.getBlackQualityColorC4B(quality)
    quality = quality or 0
    if quality == BackPackConst.quality.red then
        return Config.ColorData.data_color4[247] 
    elseif quality == BackPackConst.quality.orange then 
        return Config.ColorData.data_color4[246] 
    elseif quality == BackPackConst.quality.purple then 
        return Config.ColorData.data_color4[245] 
    elseif quality == BackPackConst.quality.blue then 
        return Config.ColorData.data_color4[244] 
    elseif quality == BackPackConst.quality.green then 
        return Config.ColorData.data_color4[243] 
    else
        return Config.ColorData.data_color4[242] 
    end
end

--获取黑底(暗底) 对应品质颜色码 格式  #ffffff
function BackPackConst.getBlackQualityColorStr(quality)
    quality = quality or 0
    if quality == BackPackConst.quality.red then
        return Config.ColorData.data_color_str[247] 
    elseif quality == BackPackConst.quality.orange then 
        return Config.ColorData.data_color_str[246] 
    elseif quality == BackPackConst.quality.purple then 
        return Config.ColorData.data_color_str[245] 
    elseif quality == BackPackConst.quality.blue then 
        return Config.ColorData.data_color_str[244] 
    elseif quality == BackPackConst.quality.green then 
        return Config.ColorData.data_color_str[243] 
    else
        return Config.ColorData.data_color_str[242] 
    end
end

--获取白底(通用ui底上) 对应品质颜色码 格式  c4b(r,g,b,a)
function BackPackConst.getWhiteQualityColorC4B(quality)
    quality = quality or 0
    if quality == BackPackConst.quality.red then
        return Config.ColorData.data_color4[206] 
    elseif quality == BackPackConst.quality.orange then 
        return Config.ColorData.data_color4[184] 
    elseif quality == BackPackConst.quality.purple then 
        return Config.ColorData.data_color4[185] 
    elseif quality == BackPackConst.quality.blue then 
        return Config.ColorData.data_color4[203] 
    elseif quality == BackPackConst.quality.green then 
        return Config.ColorData.data_color4[178] 
    else
        return Config.ColorData.data_color4[274] 
    end
end

--获取白底(通用ui底上) 对应品质颜色码 格式  #ffffff
function BackPackConst.getWhiteQualityColorStr(quality)
    quality = quality or 0
    if quality == BackPackConst.quality.red then
        return Config.ColorData.data_color_str[206] 
    elseif quality == BackPackConst.quality.orange then 
        return Config.ColorData.data_color_str[184] 
    elseif quality == BackPackConst.quality.purple then 
        return Config.ColorData.data_color_str[185] 
    elseif quality == BackPackConst.quality.blue then 
        return Config.ColorData.data_color_str[203] 
    elseif quality == BackPackConst.quality.green then 
        return Config.ColorData.data_color_str[178] 
    else
        return Config.ColorData.data_color_str[274] 
    end
end



--------------------------------------------