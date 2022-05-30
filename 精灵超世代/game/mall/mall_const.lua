MallConst = MallConst or {}

MallConst.MallType =
{
    GodShop = 1,           --钻石商城
    Recovery = 2,          --神格商店
    ScoreShop = 3,        -- 积分商店
    VarietyShop = 4,       --杂货店
    UnionShop = 5,         --公会商店
    ArenaShop = 6,         --竞技积分商城
    BossShop = 7,          --Boss积分商城
    FriendShop = 8,        --友情商城（现远征商城）
    SkillShop = 9,         -- 技能商店
    GuessShop = 16,        -- 探宝
    EliteShop = 17,        -- 精英段位赛
    HeroSkin = 18,        -- 宝可梦皮肤

    SuitShop = 28,        --神装商店
    Ladder = 30,           -- 跨服天梯商城
    Seerpalace = 31,       -- 先知殿商城

    ActionShop = 32,        -- 活动商店
    FestivalAction = 33, --节日活动购买

    CrossarenaShop = 34, -- 跨服竞技场商城
    SteriousShop = 35, -- 杂货铺
    CrosschampionShop = 36, -- 跨服冠军赛商城
    PeakchampionShop = 37, -- 巅峰冠军赛商城

    FurnitureShop = 41, -- 家具商城
    HomePetShop = 42,   -- 家园宠物出行商城
    HomeRandomShop = 43,-- 家园随机商城

    PlumeShop = 50,       -- 圣羽商店
    WelfareHeroShop = 51, -- 圣羽商店（宝可梦）
    WelfareClothShop = 52,-- 圣羽商店（神装）

    HeroSoulShop = 53,    -- 英魂商店

    AdventureShotKillBuy = 99, --神界冒险驱魂药剂购买(客户端自用)
    TermBeginsBuy = 98, --开学季提交boss(客户端自用)
    ActionYearMonsterExchange = 97, --年兽集字兑换(客户端自用)
    
    -- GodShop = 1,           --钻石商城
    -- HotShop = 2,          --热卖商城
    -- SecretShop = 3,        --神秘商店
   	-- ArenaShop = 4,         --竞技场商店
   	-- UnionShop = 5,         --公会商店
    -- ExpeditionShop = 6,    --远征商店
    -- MatchShop = 7,    --段位赛商店
    -- Recovery = 8,    --神格商店
    -- TimeArenaShop = 9,    --实时竞技
    -- WorldShop = 10,    --大世界商城
    -- FashionShop = 11,  --时装商城
    -- ArtifactShop = 12, ---神器商城，【獨立在商城外面】
    -- ScoreShop = 111, --积分商城，暂时会包含远征商店跟竞技场商店,现在又包含多个段位商城跟实时竞技商城
    -- AllHotShop = 112, --新热卖商城，包含2的热卖商城跟1的钻石商城


}


--相应的积分商城对应的资产符号
MallConst.MallPayType =
{
  -- [1]="gold",
  -- [2]="guild",               --公会积分
  -- [4]="arena_cent",          --竞技积分
  -- [5]="god_point",
  -- [6]="friend_point",
  -- [7]="hero_soul",

   -- [1]="gold",                --1-3不用这里，根据实际商品的资产类型处理
   -- [2]="gold",
   -- [3]="coin",
   -- [4]="arena_cent",          --竞技积分
   -- [5]="guild",               --公会积分
   -- [6]="expedition",          --远征积分
   -- [7]="rank_match_point",    --段位积分
   -- [8]="hero_soul",           --神格
   -- [9]="pk_point",           --实时pk
   -- [10]="world",           --世界贡献
   -- [11]="clothes_piece",          --时装
   -- [12] = "shenqi_point",
}

--相应的资产符号对应相应的资产符号
MallConst.MallTypeToRes =
{
  -- ["gold"]=1,
  -- ["guild"]=2,               --公会积分
  -- ["arena_cent"]=4,          --竞技积分
  -- ["god_point"]=5,
  -- ["friend_point"]=6,
  -- ["hero_soul"]=7,
   -- ["coin"]=1,               
   -- ["gold"]=2,
   -- ["arena_cent"]=6,        --竞技积分
   -- ["guild"]= 9,          --公会
   -- ["expedition"]=11,               --远征
   -- ["rank_match_point"]=12,    --段位积分
   -- ["hero_soul"]=13,    --神格积分
   -- ["pk_point"]=14,    --实时竞技
   -- ["world"]=18,    --实时竞技
   -- ["clothes_piece"]=19,           --世界贡献
   -- ["shenqi_point"] = 20,   --神器之灵
}

-- 积分商城类型定义
MallConst.Charge_Shop_Type = {
    Normal = 1,   -- 常规礼包
    Value = 2,    -- 超值礼包
    Privilege = 3,-- 特权商城
    Diamond = 4,  -- 钻石商城
    Dialy = 5,    -- 每日特惠
    Weekly = 6,   -- 每周限购
    Monthly = 7,  -- 月度限量
    Time = 8,     -- 限时礼包
    Cloth = 9,    -- 神装礼包
}

-- 商业街红点(这里的红点要兼容旧的VIP的红点，id不能重复，于是从99开始命名)
MallConst.Red_Index = {
    Variety = 99,  -- 精灵商店（免费刷新次数满）
    Weekly = 98,   -- 周礼包（有0元购可买）
    Monthly = 97,  -- 月礼包（有0元购可买）
    Chose = 96,    -- 自选礼包（有0元购可买）
}

-- 杂货店折扣对应的资源
MallConst.Variety_Zhe_Res = {
  [1] = "common_4001",
  [2] = "common_4002",
  [3] = "common_4003",
  [4] = "common_4004",
  [5] = "common_4005",
  [6] = "common_4006",
  [7] = "common_4007",
  [8] = "common_4008",
  [9] = "common_4009",
}
