-- ---------------------------
-- 道具用到的枚举
-- ---------------------------
BackpackEumn = BackpackEumn or {}
BackpackEumn.StorageType = {
    Backpack = 1,
    Store = 2,
    Equipment = 3,
    HomeStore = 4
}

--道具类型
BackpackEumn.ItemType = {
     none = 0 --普通
    ,swords = 1 --剑
    ,gloves = 2 --爪(拳套)
    ,wands = 3 --魔杖
    ,bows = 4 --弓
    ,magicbook = 5 --魔法书
    ,warblade = 21 -- 战刃
    ,pikeshield = 22 -- 枪盾
    ,finger = 6 --戒指
    ,neck = 7 --项链
    ,glyph = 8 --符文
    ,bracelet = 9 --手镯
    ,cloth = 10 --衣服
    ,waistband = 11 --腰带
    ,trousers = 12 --裤子
    ,wrists = 13 --护腕
    ,shoe = 14 --鞋子
    ,guard_weapon = 15--守护武器
    ,guard_cloth = 16--守护衣服
    ,guard_trousers = 17--守护裤子
    ,guard_shoe = 18--守护鞋子
    ,guard_neck = 19--守护项链
    ,guard_bracelet = 20--守护手镯
    ,hair = 50 --发型
    ,fashion = 51 --时装
    ,fashion_head = 4 --时装头饰
    ,fashion_cloth = 5 --时装衣服
    ,fashion_waist = 6 --时装腰带
    ,fashion_ring = 7 --时装戒指
    ,petskillbook = 100 --宠物技能书
    ,petattrgem = 101 --宠物属性宝石
    ,petskillgem = 102 --宠物技能宝石
    ,childattreqm = 103 --孩子属性装备
    ,childskilleqm = 104 --孩子技能装备
    ,petsupergem = 105 --超级护符中间状态，未选择
    ,gem = 110 --宝石
    ,gift = 111 --礼包
    ,formation = 112 --阵法书
    ,fruit = 113 --果实
    ,medicine = 114 --药品
    ,arts = 115 --工艺品
    ,decorate = 116 --家园装饰
    ,pet_feed = 117 --宠物口粮
    ,fightuse = 118 --战斗道具
    ,treasuremap = 119 --藏宝图
    ,petStoneMark = 120--宠物符石刻印
    ,pet_max_apt = 121--宠物资质上限丹
    ,pet_growth = 122--宠物成长丹
    ,pet_expbook = 123--宠物经验书
    ,pet_gemwash = 125--宠物符石重置丹
    ,role_wash = 126 -- 角色洗点单
    ,cp_treasuremap = 127 --伴侣宝藏
    ,limit_fruit = 128 --限量果实
    ,ride_food = 130 --坐骑口粮
    ,ride_piece = 135 -- 坐骑外观碎片
    ,handbook_piece = 136 -- 图鉴碎片
    ,embryo = 137 -- "孕育用具"
    ,childTelent = 138 -- "孩子资质上限"
    ,childGrowth = 139 -- "孩子成长丹"
    ,childFood = 140 -- "孩子饱食度"
    ,childPoint = 141 -- "孩子属性点"
    ,childcontainer = 143 -- "孩子买的瓶子"
    ,petglutinousriceballs = 144 -- 宠物元宵
    ,treasureoftruelove = 145 -- 真爱宝藏
    ,talismanring = 147 -- 指环法宝
    ,talismanmask = 148 -- 面具法宝
    ,talismancloak = 149 -- 斗篷法宝
    ,talismanbadge = 150 -- 纹章法宝
    ,selectgift = 154 -- 选择礼包
    ,pettrans = 155 -- 宠物幻化道具
    ,loveItem = 156 -- 七夕情缘道具
    ,probationRide = 157 -- 试用坐骑道具
    ,suitselectgift = 159 --时装选择礼包
    ,wingselectgift = 161 --翅膀选择礼包
    ,property = 9999 --数值道具
}

--道具类型名称
BackpackEumn.ItemTypeName = {
     [0] = TI18N("普通")
    ,[1] = TI18N("双剑")
    ,[2] = TI18N("魔杖")
    ,[3] = TI18N("战弓")
    ,[4] = TI18N("战锤")
    ,[5] = TI18N("魔法书")
    ,[21] = TI18N("战刃")
    ,[22] = TI18N("枪盾")
    ,[6] = TI18N("戒指")
    ,[7] = TI18N("项链")
    ,[8] = TI18N("符文")
    ,[9] = TI18N("手镯")
    ,[10] = TI18N("衣服")
    ,[11] = TI18N("腰带")
    ,[12] = TI18N("裤子")
    ,[13] = TI18N("护腕")
    ,[14] = TI18N("鞋子")
    ,[15] = TI18N("武器") --守护
    ,[16] = TI18N("衣服") --守护
    ,[17] = TI18N("裤子") --守护
    ,[18] = TI18N("鞋子") --守护
    ,[19] = TI18N("项链") --守护
    ,[20] = TI18N("手镯") --守护
    ,[50] = TI18N("发型")
    ,[51] = TI18N("时装")
    ,[52] = TI18N("时装头饰")
    ,[53] = TI18N("时装衣服")
    ,[54] = TI18N("时装腰带")
    ,[55] = TI18N("时装戒指")
    ,[100] = TI18N("宠物技能书")
    ,[101] = TI18N("宠物属性宝石")
    ,[102] = TI18N("宠物技能宝石")
    ,[110] = TI18N("宝石")
    ,[111] = TI18N("礼包")
    ,[112] = TI18N("阵法书")
    ,[113] = TI18N("果实")
    ,[114] = TI18N("药品")
    ,[115] = TI18N("工艺品")
    ,[116] = TI18N("家园装饰")
    ,[117] = TI18N("宠物口粮")
    ,[118] = TI18N("战斗道具")
    ,[119] = TI18N("藏宝图")
    ,[120] = TI18N("屠魔赦令")
    ,[121] = TI18N("宠物资质上限丹")
    ,[122] = TI18N("宠物成长丹")
    ,[123] = TI18N("宠物经验书")
    ,[9999] = TI18N("数值道具")
}

--绑定枚举
BackpackEumn.BindType = {
    bind = 1,
    unbind = 0,
}

--使用类型
BackpackEumn.UseType = {
    unuse = 0,--不能直接使用
    use_del = 1,--使用消耗
    use_undel = 2,--使用不消耗
}

--extra枚举
BackpackEumn.ExtraName = {
    market_price = 1 --市场价格
    ,source = 2 --物品来源
    ,assest = 3 --资产类型
    ,map_id = 4 --地图id
    ,map_x = 5 --地图x坐标
    ,map_y = 6 --地图y坐标
    ,fruit_time = 7 --果实次数
    ,pet_ploish = 8 --宠物洗练
    ,comprehend_look = 9 --神器外观
    ,enchant_break = 10 --强化突破
    ,comprehend_free_1 = 11 --转职免费精炼1
    ,comprehend_free_2 = 12 --转职免费精炼2
    ,comprehend_free_3 = 13 --转职免费精炼3
    ,comprehend_free_4 = 14 --转职免费精炼4
    ,comprehend_free_5 = 15 --转职免费精炼5
    ,comprehend_free_6 = 16 --转职免费精炼6
    ,comprehend_free_7 = 17 --转职免费精炼7
    ,comprehend_free_8 = 18 --转职免费精炼8
    ,comprehend_free_9 = 19 --转职免费精炼9
    ,comprehend_free_10 = 20 --转职免费精炼10
    ,gem_free_1 = 21 --转职免费宝石转换
    ,gem_free_2 = 22 --转职免费宝石转换
    -- 23 历史最高强化等级
    ,hero_back = 24 -- 英雄宝石找回
    ,quest_offer_role_id = 25 -- 悬赏奖章队长ID
    ,quest_offer_platform = 26 -- 悬赏奖章队长平台
    ,quest_offer_zone_id = 27 -- 悬赏奖章队长区号
    ,quest_offer_role_name = 28 -- 悬赏奖章队长名字
    ,quest_offer_times = 29 -- 悬赏奖章已赠送队长次数
    ,gem_free_3 = 30 --转职免费英雄宝石转换
    ,aptitude_acc = 31 --变异雷暴精华值
    ,fruit_lev = 32   --果实等级
    ,fruit_lev1_type = 33 --果实一级效果
    ,fruit_lev2_type = 34 --果实二级效果
    ,fruit_lev3_type = 35 --果实三级效果
}

--使用效果--客户端
BackpackEumn.ItemUseClient = {
    ride_piece = 17, -- 坐骑碎片品阶
    gift_show = 18, -- 礼包展示
    open_window = 100,--打开界面
    find_npc = 99, -- 寻找npc
    glyphs_effect = 21, -- 雕文效果
}

-- 过期类型
BackpackEumn.ExpireType = {
    None = 0, -- 无过期
    EndTime = 1, -- 获得起，过期分钟
    EndDate = 2, -- 获得起，过期日期
    StartTime = 3, -- 获得起，开启分钟
    StartDate = 4, -- 获得起，开启日期
    PutonEndTime = 5, -- 穿戴起，过期分钟
    PutonEndDate = 6, -- 穿戴起，过期日期
}

--装备位置名称
BackpackEumn.EquippositionName = {
    TI18N("武器"),
    TI18N("戒指"),
    TI18N("项链"),
    TI18N("符文"),
    TI18N("手镯"),
    TI18N("衣服"),
    TI18N("腰带"),
    TI18N("裤子"),
    TI18N("护腕"),
    TI18N("鞋子"),
    TI18N("翅膀"),
    TI18N("坐骑")
}

BackpackEumn.ActivityItemFlag = {
    ShowTips = 1,
    ShowWindow = 2,
}

function BackpackEumn.GetEquipNameByType(type)
    local name = ""
    if type <= 5 or type == BackpackEumn.ItemType.warblade or type == BackpackEumn.ItemType.pikeshield then
        name = TI18N("武器")
    else
        name = BackpackEumn.ItemTypeName[type]
    end
    return name
end

-- 从协议数据获取道具的出售的金币价格
function BackpackEumn.GetSellPrice(item)
    local price = 0
    if item ~= nil then
        if item.extra ~= nil then
            for k,v in pairs(item.extra) do
                if v.name == BackpackEumn.ExtraName.market_price then
                    price = v.value
                end
            end
        end
    end
    return price
end

-- 判断装备是否突破
function BackpackEumn.IsEnchantBreak(item)
    local result = false
    if item ~= nil and item.extra ~= nil then
        for k,v in pairs(item.extra) do
            if v.name == BackpackEumn.ExtraName.enchant_break and v.value == 1 then
                result = true
            end
        end
    end
    return result
end
