local BDConst = {
    -- 最大战斗回合数
    maxRound = 30,

    -- 怒气上限
    maxRP = 200,

    -- 技能表现类型（通用性）
    SkillType = {
        Class1    = 1, -- 单个挨打特效（相互无关联）
        Class2    = 2, -- 通过effect触发特效
        ClassNone = 3, -- 不通用技能
    },

    speed = {
        normal  = 1.2,
        trustee = 2,
    },

    challengeType = {
        eNone        = 0,     -- 无
        eKillAll     = 1,     -- 敌方全灭
        eWinInRound  = 4,     -- x回合内获胜
        eHPRemain    = 2,     -- 我方总生命高于x%
        eAliveRemain = 3,     -- 我方存活不少于x人
    },

    -- 入场方式
    entryType = {
        eJumpLeft    = 1, -- 左边跳入
        eJumpRight   = 2, -- 右边跳入
        eJumpTop     = 3, -- 上面跳入
        eJumpBottom  = 4, -- 下面跳入
        eFlash       = 5, -- 闪现
        eJumpForward = 6, -- 模拟步行入场
        eJumpLocal   = 7, -- 原地跳动
        eNone        = 8, -- 无任何特效出现
    },

    -- @buff表现方式
    buffShowType = {
        eFadeOut = 1,   -- 淡出效果: 图片与伤害数字类似，特效播放后消失
        eStay    = 2,   -- 常驻:    图片一直显示，特效循环播放
    },

    -- @buff表现文件类型
    buffFileType = {
        ePicture = 1,
        eEffect  = 2,
        eAudio   = 3,
    },

    --
    targetEnum = {
        eNone             = 0,  -- 无
        eSingleFront      = 1,  -- 单前
        eSingleBack       = 2,  -- 单后
        eRowFront         = 3,  -- 前排
        eRowBack          = 4,  -- 后排
        eOneColumn        = 5,  -- 竖排
        eAll              = 6,  -- 全体
        eRandom           = 7,  -- 随机
        eHPMax            = 8,  -- 生命最高
        eHPMin            = 9,  -- 生命最低
        eRPMax            = 10, -- 怒气最高
        eRPMin            = 11, -- 怒气最低
        eHPLossMax        = 12, -- 损血最多
        eFightingForceMax = 13, -- 战力最高
        eSputteringRange  = 14, -- 溅射范围
        eDesignatedHero   = 15, -- 指定目标
    },

    actionTag = {
        eHeroMove = 1024 + 100,
        eShake    = 1024 + 101,
        eCamera   = 1024 + 102,
    },
}

return BDConst
