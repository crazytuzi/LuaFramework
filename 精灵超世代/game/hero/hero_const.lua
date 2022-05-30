--宝可梦(伙伴)的常量
-- by lwc
HeroConst = HeroConst or {}


--宝可梦背包页签类型
HeroConst.BagTab = {
    eBagHero        = 1 , --宝可梦页签
    eBagPokedex    = 2 , --图鉴页签
    eElfin          = 3,  -- 精灵
    eHalidom        = 4,  -- 圣物
}

--宝可梦主信息界面页签类型
HeroConst.MainInfoTab = {
    eMainTrain          = 1 , --培养  -- eMainEquip          = 2 , --装备 装备界面被移除了 放到宝可梦旁边
    eMainUpgradeStar    = 2 , --升星 
    eMainTalent         = 3 , --天赋
    eMainHolyequipment  = 4 , --神装
}

-- 宝可梦主信息界面页签类型名字
HeroConst.MainInfoTabName = {
    [HeroConst.MainInfoTab.eMainTrain] = TI18N("培养"),
    [HeroConst.MainInfoTab.eMainUpgradeStar] = TI18N("升星"),
    [HeroConst.MainInfoTab.eMainTalent] = TI18N("天赋领悟"),
    [HeroConst.MainInfoTab.eMainHolyequipment] = TI18N("饰品"),
}
--布阵界面中间的页签类型
HeroConst.FormMiddleTab = {
    eFormHero          = 1 , --上阵宝可梦
    eFormHallows       = 2 , --神器
    eFormFormation     = 3 , --阵法
}

HeroConst.FormShowType = {
    eFormFight   = 1 , --出战
    eFormSave    = 2 , --保存布阵
}
--宝可梦献祭类型
HeroConst.SacrificeType = {
    eHeroFuse          =   1, --融合神殿
    eHeroSacrifice     =   2, --宝可梦献祭
    eHeroReplace       =   3, --置换神殿
    eHeroDisband       =   4, --宝可梦重生
    eChipSacrifice     =   5, --宝可梦碎片献祭
}

HeroConst.tabType = {
    [HeroConst.SacrificeType.eHeroFuse] = TI18N("进化"),
    [HeroConst.SacrificeType.eHeroSacrifice] = TI18N("分解"),
    [HeroConst.SacrificeType.eHeroReplace] = TI18N("置换"),
    [HeroConst.SacrificeType.eHeroDisband] = TI18N("重生"),
}
--宝可梦共鸣类型
HeroConst.ResonateType = {
    eResonate        =   1, --宝可梦水晶
    eStoneTablet     =   2, --宝可梦石碑增益
    eEmpowerment     =   3, --宝可梦石碑注能
}
--宝可梦分解类型
HeroConst.ResetType = {
    eHeroReset     =   1, --宝可梦献祭
    eChipReset     =   2, --宝可梦碎片献祭
    eHolyEquipSell =   3, --神装出售
    eTenStarChang  =   4, --10星置换
    eActionHeroReset   =   5, --活动的宝可梦重生
    eFunriture     =   6, -- 家具出售
    eHeroReturn   =   7, --常驻的宝可梦回退
    eSpriteReturn   =   8, --活动的精灵重生
}


--宝可梦锁定类型(一般由服务端定义)
HeroConst.LockType = {
    eHeroLock          =   1, --宝可梦锁定
    eHeroChangeLock    =   2, --宝可梦置换锁定
    eHeroResonateLock  =   98, --宝可梦共鸣锁定 --客户端定义
    eFormLock          =   99, --宝可梦上阵锁定 --客户端定义
}

--宝可梦阵营类型
HeroConst.CampType = {
    eNone          = 0 , --无
    eWater         = 1 , --水
    eFire          = 2 , --火
    eWind          = 3 , --风
    eLight         = 4 , --光
    eDark          = 5 , --暗
    eLingtDark     = 6 , --光暗
}

--宝可梦阵营对应名字
HeroConst.CampName = { --水火风光暗
    [HeroConst.CampType.eNone]          = TI18N("无") , --无
    [HeroConst.CampType.eWater]         = TI18N("水") , --无
    [HeroConst.CampType.eFire]          = TI18N("火") , --无
    [HeroConst.CampType.eWind]          = TI18N("草") , --无
    [HeroConst.CampType.eLight]         = TI18N("光") , --无
    [HeroConst.CampType.eDark]          = TI18N("暗") , --无
}
--宝可梦阵营对应属性名字
HeroConst.CampAttrName = { --水火风光暗
    [HeroConst.CampType.eNone]          = TI18N("无") , --无
    [HeroConst.CampType.eWater]         = TI18N("水系") , --无
    [HeroConst.CampType.eFire]          = TI18N("火系") , --无
    [HeroConst.CampType.eWind]          = TI18N("草系") , --无
    [HeroConst.CampType.eLight]         = TI18N("光明") , --无
    [HeroConst.CampType.eDark]          = TI18N("黑暗") , --无
}

--阵营背景资源名字
HeroConst.CampBgRes = {
    [HeroConst.CampType.eWater] = "hero_info_bg_1",
    [HeroConst.CampType.eFire]  = "hero_info_bg_2",
    [HeroConst.CampType.eWind]  = "hero_info_bg_3",
    [HeroConst.CampType.eLight] = "hero_info_bg_4",
    [HeroConst.CampType.eDark]  = "hero_info_bg_5",
}

--阵营底座背景资源名字
HeroConst.CampBottomBgRes = {
    [HeroConst.CampType.eWater] = "hero_camp_1",
    [HeroConst.CampType.eFire]  = "hero_camp_2",
    [HeroConst.CampType.eWind]  = "hero_camp_3",
    [HeroConst.CampType.eLight] = "hero_camp_4",
    [HeroConst.CampType.eDark]  = "hero_camp_5",
}


--宝可梦职业类型
HeroConst.CareerType ={
    eNone     = 0 , --无
    eMagician     = 2 , --法师
    eWarrior      = 3 , --战士
    eTank         = 4 , --坦克
    eSsistant     = 5 , --辅助
}
--宝可梦职业对应名字
HeroConst.CareerName ={
    [0] = TI18N("无"),
    -- [1] = TI18N("无"),
    [HeroConst.CareerType.eMagician]    = TI18N("特攻"),
    [HeroConst.CareerType.eWarrior]     = TI18N("物攻"),
    [HeroConst.CareerType.eTank]        = TI18N("防御"),
    [HeroConst.CareerType.eSsistant]    = TI18N("辅助"),
}
--宝可梦职业对应名字
HeroConst.CareerName2 ={
    [0] = TI18N("无"),
    -- [1] = TI18N("无"),
    [HeroConst.CareerType.eMagician]    = TI18N("特"),
    [HeroConst.CareerType.eWarrior]     = TI18N("物"),
    [HeroConst.CareerType.eTank]        = TI18N("防"),
    [HeroConst.CareerType.eSsistant]    = TI18N("辅"),
}

--宝可梦item显示类型
HeroConst.ExhibitionItemType = {
    eNone  =   0, -- 无
    eHeroBag = 1 , --宝可梦背包类型
    ePokedex = 2 , --图鉴变灰类型
    eHeroChange = 4 , --宝可梦转换界面
    eFormFight = 7 , --布阵出战界面
    eVoyage = 8 , --远航界面
    eExpeditFight = 9 , --远征
    eStronger = 10 , --我要变强
    eEndLessHero = 11 , --是否是无尽试炼雇佣的宝可梦
    eAdventure = 12, -- 冒险
    eLimitExercise = 13, -- 限时试炼之境
    ePlanes = 14, -- 位面
}

--宝可梦红点类型
HeroConst.RedPointType ={
    eRPLevelUp  = 1,   --升级升阶
    eRPEquip    = 2,   --装备
    eRPStar     = 3,   --升星
    eRPTalent   = 4,   --天赋技能
    eRPHalidom_Unlock = 5, -- 圣物解锁
    eRPHalidom_Lvup = 6,   -- 圣物升级
    eRPHalidom_Step = 7,   -- 圣物进阶
    eResonate_extract = 8,   -- 共鸣精炼
    eResonate_stone = 9,   -- 共鸣石碑
    -- Artifact = 5,
    eElfin_hatch_done = 10, -- 精灵孵化完成
    eElfin_tree_lvup = 11,  -- 精灵古树可升级或进阶
    eElfin_empty_pos = 12,  -- 精灵古树有可放置的精灵
    eElfin_compound = 13,   -- 上阵的精灵可合成
    eElfin_higher_lv = 14,  -- 上阵精灵有更高级的精灵
    eElfin_hatch_lvup = 15, -- 灵窝可升级
    eElfin_hatch_egg = 16,  -- 有可孵化的灵窝和蛋
    eElfin_activate = 17,   -- 精灵图鉴红点
    eElfin_hatch_open = 18,   -- 灵窝可解锁
    eElfin_summon = 19,   -- 精灵免费召唤
}

--装备位置列表
HeroConst.EquipPosList = {
    [1] = BackPackConst.item_type.WEAPON, -- 武器
    [2] = BackPackConst.item_type.SHOE, -- 鞋子
    [3] = BackPackConst.item_type.CLOTHES, -- 衣服
    [4] = BackPackConst.item_type.HAT, -- 头盔
}

--神装装备位置列表
HeroConst.HolyequipmentPosList = {
    [1] = BackPackConst.item_type.GOD_EARRING,  -- 耳环
    [2] = BackPackConst.item_type.GOD_NECKLACE, -- 项链
    [3] = BackPackConst.item_type.GOD_RING,     -- 戒指
    [4] = BackPackConst.item_type.GOD_BANGLE,   -- 手镯
}

-- 神装item对应的默认资源名称
HeroConst.HolyEmptyIconName = {
    [BackPackConst.item_type.GOD_EARRING] = "hero_info_25",  --耳环
    [BackPackConst.item_type.GOD_RING] = "hero_info_27",  --戒指
    [BackPackConst.item_type.GOD_NECKLACE] = "hero_info_26",  --项链
    [BackPackConst.item_type.GOD_BANGLE] = "hero_info_28",  --手镯
}

--宝可梦绘图分享来源类型
HeroConst.ShareType = {
    eHeroInfoShare = 1,     --宝可梦信息绘图分享
    eLibraryInfoShare = 2,  --图书馆信息绘图分享
}

--宝可梦界面分享频道类型
HeroConst.ShareBtnType = {
    eHeroShareCross = 1 , --跨服频道 
    eHeroShareWorld = 2 , --世界频道 
    eHeroShareGuild = 3 , --公会频道 
}

--打开装备tips、面板来源类型
HeroConst.EnterType = {
    eOhter        = 0, --其他
    eHolyPlan     = 1, --神装方案管理
}

HeroConst.SelectHeroType = {
    eStarFuse     = 1, --表示融合祭坛
    eUpgradeStar  = 2, --表示升星界面的
    eHalidom      = 3, --圣物
    eTenConvert   = 4, --活动10星置换
    eResonateStone     = 5, --共鸣圣阵选择宝可梦
    eResonateEmpowerment = 6,   -- 共鸣赋能选择宝可梦
    eResonateCrystal = 7, --共鸣水晶(改版后增加的第一个页签)
}

--长时间点击类型
LONG_TOUCH_INIT_TYPE = 0   --初始化状态
LONG_TOUCH_BEGAN_TYPE = 1  --长按开始 
LONG_TOUCH_END_TYPE = 2    --长按因为触发了事件结束了
LONG_TOUCH_CANCEL_TYPE = 3 --长按取消