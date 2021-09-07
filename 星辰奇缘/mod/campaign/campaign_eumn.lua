-- -------------------
-- 活动枚举
-- hosr
-- -------------------
CampaignEumn = CampaignEumn or {}

CampaignEumn.Status = {
    Doing = 0, -- 未完成
    Finish = 1, -- 完成未领取
    Accepted = 2, -- 已领取
}

CampaignEumn.Type = {
    Other = 0,           -- 模板活动
    FirstRecharge = 107, -- 首充活动
    ContinueRecharge = 338, -- 连充活动
    Rebate = 2, -- 充值返利
    OnLineReward = 3, -- 在线福利
    SpringFestival = 4, -- 春节活动
    OnLine = 6, -- 新在线福利
    OpenServer = 7, -- 开服活动
    WarmSpring = 9, -- 暖春活动
    QingMing = 9, -- 清明活动
    OpenServer1 = 10, -- 开服活动1
    Labour = 11, -- 劳动光荣
    May = 12,       -- 五月活动
    Children = 13,  -- 儿童节
	MergeServer = 14,	-- 合服活动
    MidAutumn = 15,     -- 中秋活动
    SummerActivity = 20, --暑假活动
    OpenBeta = 21, --公测活动
    NationalDay = 22, --国庆活动
    NewMoon = 23, --新月降临
    Halloween = 24, --万圣节活动
    DoubleEleven = 25, --双十一活动
    Thanksgiving = 26,  -- 感恩节
    Regression = 27, --老玩家回归
    Christmas = 28, -- 圣诞活动
    ChildBirth = 30,    -- 新资料片，孩子系统
    Fool = 31,          -- 春日
    ToyReward =33,     -- 扭蛋抽奖
    NewYear = 34,   -- 元旦活动  17年四月累冲
    Valentine = 35, -- 元宵活动 欢乐兜兜
    NewLabour = 36,  -- 2017年劳动节活动
    MayIOU = 5,     -- 情人节、520
    DragonBoatFestival = 38, -- 端午节活动
    RebateReward = 40, --小额双倍


    WorldLev = 41,  --世界等级活动
    WarmHeart = 42, -- 暖心活动（父亲节）
    CampBox = 43, --九宫格抽奖相关活动
    SummerGift = 44,
    BigSummer = 45, -- 大暑活动
    SummerCarnival = 46, --暑假狂欢
    BeginAutumn = 47,
    QiXi = 50,
    LoveWish = 51 -- 星语星愿
}
-- 活动排行榜类型
CampaignEumn.CampaignRankType =
{
    Intimacy = 60019  -- 亲密度排行榜
    ,PlayerKill = 60020 -- 星辰擂台排行榜
    ,Weapon = 60021 -- 武器评分排行榜
    ,Constellation = 60022 -- 十二星座排行榜
    ,WorldChampion = 60023 -- 武道大会排行榜
    ,Pet = 60024 -- 宠物排行榜
    ,Wing = 60025 -- 翅膀排行榜
    ,Mount = 60026 -- 坐骑评分排行榜
    ,Home = 60027 -- 家园评分排行榜
    ,Arena = 60028 -- 竞技场评分排行榜
    ,Stone = 60029 -- 宝石评分排行榜
    ,Weapon2 = 60030-- 武器评分排行榜
    ,Treasure = 60032 -- 寻宝评分排行榜
    ,ConSume = 60052 -- 累积消费排行榜
}

CampaignEumn.SpringFestivalType = {
    Recharge = 4,           -- 春节返利
    GroupPurchase = 5,      -- 新春抢购日
    Continue = 3,           -- 感恩连充
    NewYearGoods = 2,       -- 年货
    Snowman = 9,            -- 雪人大挑战
    SnowFight = 10,          -- 欢乐打雪仗
    Pumpkin = 8,            -- 调皮南瓜
    HideAndSeek = 7,        -- 捉迷藏
    Ski = 6,                -- 新春滑雪（改划龙舟）
    LuckyMoney = 1,        -- 压岁钱
    Exchange = 11,          -- 兑换商店
}

-- 2017年元宵+情人节活动
CampaignEumn.ValentineType = {
    --  Recharge = nil,           -- 充值送豪礼

    Love = nil,            -- 情牵一线（许愿）
    Bird = nil,              -- 百鸟迎春 （改砸套娃 jia）
    Chocolate = nil,          -- 情浓巧克力

    CakeExchange = nil,           -- （周年庆兑换， jia）
    Hand = nil,               -- 执子之手
    Lantern = nil,            -- 元宵灯会
    Exchange = nil,           -- 兑换商店
    Spirit = nil
}

CampaignEumn.LabourType = {
    Eggs = 1,           -- 神秘彩蛋
    LuckyBag = 2,       -- 守护福袋
    Trials = 3,         -- 四季挑战
    Monkey = 4,         -- 异域灵猴
    Reward = 5,         -- 劳动光荣礼包
}

CampaignEumn.OpenServerType = {
    Online = 1,                 --在线奖励
    MonthAndFund = 2,           --月卡和基金
    ZeroBuy = 3,                --开服0元购
    Therion = 4,                --神兽兑换
    Rank = 5,                   --排行榜奖励
    Wish = 6,                   --许愿仙池
    Flog = 7,                   --幸运翻牌
    Lucky = 8,                  --充值红包
    Reward = 9,                 --限时礼包
    Seven = 10,                 --七天乐享
    ConsumeReturn = 11 ,        --消费返利
    ContinuousRecharge = 12,    --新连充活动
    DirectBuy = 13,             --直购活动
    ValuePackage = 14,          --超值礼包
    AccumulativeRecharge = 15,  --累充活动
    ToyReward = 16,             --抽奖活动
    Exchange_Window = 17,       --兑换积分


    --未开启
    Continue = 222,       -- 连续充值
    ActiveReward = 99999,   -- 活跃度大奖
    Ship = 99999,           -- 星梦游轮
}

CampaignEumn.MayType = {
    Total = 1,          -- 充值送豪礼
    Summer = 5,         -- 盛夏光年
    Hand = 3,           -- 执子之手
    Rose = 4,           -- 玫瑰传情
    Reward = 2,         -- 恋爱季礼盒
}

CampaignEumn.ShowPosition = {
    MainUI = 1,         -- 主UI
    BibleCampaign = 2,  -- 奖励活动标签
    Other = 99,         -- 其他
}

CampaignEumn.ChildType = {
    Happy = 1,          -- 六月狂欢季
    Cake = 5,           -- 食盒制作
    DragonBoat = 3,     -- 赛龙舟
    RiverTroll = 4,     -- 清河妖
    Total = 2,          -- 累计充值
}

CampaignEumn.ShowType = {
    OpenServerFlop = 1,       -- 幸运翻牌
    DoubleElevenFeedback = 2,    -- 限时返利
    TreasureHunting = 3,       -- 探宝活动
    DoubleElevenGroup = 4, -- 团购
    Lantern = 6,        -- 每日充值（点亮灯笼）
    BuyPackage = 7,     -- 买礼包
    NewFashion = 8,     -- 新时装一套
    SeekChildren = 9,   -- 捉迷藏活动
    Hand = 10,           --执子之手
    IntiMacy = 12,        --亲密度排行
    QiXi = 13,            --七夕活动面板
    BigPicture = 14,            --大图展示


    Secondary = 15,    --次级窗口

    RechargeGift = 16,    --充值巨献
    ToyReward = 17,       --扭蛋活动
    MarchEvent = 18,      --烟花盛典
    Exchange_Window = 19, --兑换商店窗口
    Turntable = 20, --转盘活动
    SkyLantern = 21,--孔明灯会
    EnjoyMoon = 22, --中秋赏月夜
    PoetryChallenge = 23, --诗词挑战
    RebateReward = 24, -- 秋分狂欢
    FlowerOpen = 25, -- 花开富贵
    FlowerHundred = 26, --百花送福
    ValentineActiveFirst = 27, -- 情人节活动
    SecondaryTop = 28,
    RechargePackage = 29, -- 中秋礼包
    FlowerAccept = 30, -- 花朵收集
    AutumnBargain = 31, -- 金秋砍价活动
    LoginReward = 32, --登录送礼
    Boat = 33, -- 赛龙舟
    Boat = 33, -- 赛龙舟
    Zongzi = 34, -- 包粽子
    Consume =35,--累计消费
    KillEvil = 36,--祛除邪灵
    DiscountHalloween = 37, -- 万圣折扣商店
    TalkBubble = 38,        -- 对话框类型+妹纸
    LoveWish = 39, -- 星语星愿
    AnnualExchange = 40, -- 周年兑换
    DollsRandom = 41, --砸套娃
    SaveSingleDog = 42, --五彩遍山河
    SpriteEgg = 43, -- 精灵蛋
    CampaignInquiry = 44, -- 功能预告
    SalesPromotion = 45, -- 礼包促销
    SummerDoing = 46, --夏日必做
    CuteSnowMan = 47, --萌萌雪人
    SnowFight = 48,   --雪人挑战
    RideShow = 49,    --坐骑展示
    FastSkiing = 50,  --急速滑雪
    FashionSelection = 51, --时装评选
    RechargeCoupon = 52, --充值礼券
    LimitTimeStore = 53, --限时商店
    FashionDiscount = 54, --时装折扣
    DragonKingSendsBless = 57, --龙王送福
    NewYearTurnable = 58, --新春转盘
    LuckyMoney = 59,      --压岁钱
    NewYearGoods = 60,    -- 运年货
    MulticoloredMountainsAndRivers = 61, -- 五彩遍山河
    LanternMultiRecharge = 62,   --元宵连充
    RushTop = 63,  --冲顶大会
    SweetCake = 64, --糖果蛋糕
    ArborShake = 65,  --摇摇乐
    SignDraw = 66, --签到抽奖
    SummerCold = 67, --清凉一夏
    AprilTreasure = 68, --欢乐寻宝
    PurifyHome = 69, --净化家园
    PassBless = 70, --传递祝福
    Anniversary = 71, --周年庆
    FullSubtraction = 72, --满减商城
    FruitPlant = 73,  --水果种植
    NewRebate = 74, --新充值返利
    ConSumeRank = 75, --累消排行榜
    IntegralExchange = 76, --新积分兑换 
    NewRechargeGift = 77, --新充值礼包
    WarmHeartGift = 78, --暖心好礼
    ScratchCard = 79, --刮刮乐
    CollectWord = 80, --集字兑换
    SurpriseShop = 81, --惊喜折扣商店
    DirectPackage = 82, --直购礼包
    LuckyTree = 83, --幸运树
    IntoGold = 84, --点石成金（净化家园）
    WarOrder = 85, --战令
    CustomGift = 86, --定制礼包
    PrayTreasure = 87, --祈愿宝阁

    Other = 99,         -- 其他类型
    NoShow = 100,       -- 不显示
}

CampaignEumn.MergeServerType = {
	Double = 3,			-- 双倍免费领
	Endear = 4,			-- 亲密不打折
	Gift = 5,			-- 合服有好礼
	Login = 2, 			-- 登录送好礼
	First = 1,			-- 欢乐首充
    Pub  = 6,           -- 三倍大返利
}

CampaignEumn.MidAutumnType = {
    SkyLantern = 1,
    Reward = 2,
    EnjoyMoon = 3,
    Dress = 4,
    Feedback = 5,
    Exchange = 6,
}

CampaignEumn.NewMoonType = {
    Dice = 1,
    Recharge = 2,
    Three = 3,
}

CampaignEumn.HalloweenType = {
    Pumpkin = 1,
    GroupBuy = 2,
    KillEvil = 6,
    Reward = 3,         -- 万圣节礼盒
    Suger = 4,          -- 怪趣糖果会
    Exchange = 5,       -- 兑换

    NewMoon_Recharge = 99,
    NewMoon_Dice = 98,          -- 临时存放
}

CampaignEumn.ThanksgivingType = {
    Recharge = 1,       -- 感恩连充
    Active = 2,         -- 活跃翻牌
    Question = 3,       -- 答题
    Exchange = 4,       -- 兑换
}

CampaignEumn.RegressionType = {
    RegressionLogin = 1,         -- 回归登陆
    HandInHand = 2,          -- 携手并进礼
    HappyEncourageGift = 3, -- 欢乐助长礼
}

CampaignEumn.NewYearType = {
    Recharge = 1,       -- 累计充值
    Exchange = 3,       -- 元旦兑换
    Fight = 2,          -- 五彩仙盒
}

CampaignEumn.ChildBirthType = {
    Happy = 1,          -- 享乐狂欢
    Colorful = 2,
    Flower = 3,
}
CampaignEumn.NewLahourType = {
    Type1 = 1,    -- 劳动最光荣
    Type2 = 2,    -- 清扫城市
    Type3 = 3,    -- 顽皮小狐狸
    Back = 4,       -- 返利
    Group = 5,      -- 团购
    Reward = 6,     -- 礼包
}

CampaignEumn.FoolType = {
    Group = 2,
    Back = 1,
    Reward = 3,
}

CampaignEumn.MayIOUType = {
    Love = nil            -- 情牵一线（许愿）
    ,Bird = nil              -- 百鸟迎春
    ,Chocolate = nil          -- 情浓巧克力
    ,Intimacy = nil          -- 亲密度排行榜
}

CampaignEumn.DragonBoatType = {
    LoginReward = nil      -- 登录送礼
    ,Boat = nil            -- 赛龙舟
    ,Zongzi = nil          -- 包粽子
    ,Consume = nil        -- 累计消费
}
CampaignEumn.WorldLevType = {
     PlayerKill = nil -- 星辰擂台
    ,Weapon = nil -- 武器评分
    ,Constellation = nil -- 十二星座
    ,WorldChampion = nil -- 武道大会
    ,Pet = nil -- 宠物
    ,Gift = nil -- 礼包
    ,Wing = nil --翅膀排行
    ,Recharge = nil  -- 充值返利
    ,TotalRecharge = nil     -- 累计充值
    ,Gift2 = nil  -- 礼包2
    ,Mount = nil -- 坐骑评分排行榜
    ,Home = nil -- 家园评分排行榜
    ,Arena = nil -- 竞技场评分排行榜
    ,Stone = nil -- 宝石评分排行榜
    ,Weapon2 = nil -- 武器评分
    ,Recharge2 = nil-- 充值返利第二档
    ,TotalRecharge2 = nil-- 累计充值第二档
    ,Gift3 = nil -- 累计消费第三档
    ,Gift4 = nil -- 累计消费第四档
}

CampaignEumn.RebateReward =
{
    HotShopping = 1,
    RebateRewarded = 2,
    Back = nil,
}

CampaignEumn.WarmHeart =
{
    WarmHeart = 1,
    QuestKing = 2,
    CoinActive = 3,
}

CampaignEumn.CampBox =
{
    SummerQuest = 685
    ,CampBox = 686
    ,Recharge = 689
    ,Exchange = 690
}

CampaignEumn.SummerGift =
{
    MindAgain = 691
    ,SummerGift = 692
    ,Rank = 698
}

CampaignEumn.BigSummer =
{
    BigSummer = 701,
    Grouppurchase = 702,
}


CampaignEumn.SummerCarnival =
{
    Flowers = 706,
    Wish = 707,
    Recharge = 708,
    Rebate = 703,
    Festival = 704,
    Cold =  716,
}

CampaignEumn.BeginAutumn =
{
    RechargeGift = 717,
    TimeShop = 718,
}

CampaignEumn.QiXi =
{
    Intimacy = 4,
}


