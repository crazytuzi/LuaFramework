BattleConst = BattleConst or {}

--战斗类型(战前准备面板)
BattleConst.Fight_Type = {
    Nil = 0, --家战斗
    Default = 1,
    Arena = 2, --竞技场
    Darma = 3, --剧情副本战斗
    SingleBoss = 4,--个人Boss
    WorldBoss = 5,--世界boss
    Adventrue = 6, --神界探险
    StarTower = 7, --星命塔
    PK = 8, --切磋
    GuildDun = 9,   --公会副本
    Champion = 10,    --冠军联赛
    Endless = 11,    --无尽试炼
    -- LimitBoss = 12,  --限时BOSS
    SandybeachBossFight = 12, --沙滩保卫战 沙滩争夺战
    Escort = 13,
    DungeonStone = 14, -- 宝石副本
    Godbattle = 15, -- 众神战场
    GuildWar = 16,  -- 联盟战
    PrimusWar = 17,   -- 荣耀神殿战
    LadderWar = 18, -- 跨服天梯
    ExpeditFight = 21, --远征
    YuanZhenFight = 22, --元宵活动

    EliteMatchWar = 23, --精英赛
    EliteKingMatchWar = 24, --王者赛

    ElementWar = 25, -- 元素圣殿
    HeroTestWar = 26, -- 宝可梦试玩(限时召唤活动中)
    HeavenWar = 27,  -- 天界副本
    CrossArenaWar = 28, -- 跨服竞技场
    LimitExercise = 29, -- 试炼之境

    AdventrueMine = 30, --秘矿冒险

    CrossChampion = 31, -- 跨服冠军赛

    TermBegins = 32, -- 开学季战斗类型
    TermBeginsBoss = 33, -- 开学季boos战斗类型

    GuildSecretArea = 34, --公会秘境战斗

    Arean_Team = 35,    --组队竞技场

    Training_Camp = 36,    --新手训练营

    MonopolyWar_1 = 101, -- 大富翁第一阶段
    MonopolyWar_2 = 102, -- 大富翁第二阶段
    MonopolyWar_3 = 103, -- 大富翁第三阶段
    MonopolyWar_4 = 104, -- 大富翁第四阶段
    MonopolyBoss  = 105, -- 大富翁boss

    Arenapeakchampion  = 37, -- 巅峰冠军赛
    -- PlanesWar = 38, -- 位面冒险
    PlanesWar = 40, -- 新位面冒险(定义覆盖旧的需要的时候再弄一个新的)
    YearMonsterWar = 39, --年兽活动
    WhiteDayWar = 41,  --女神试炼
    AreanManyPeople = 42,  --多人竞技场
    PractiseTower = 43,  --演武场试练塔活动
}

BattleConst.Hook_Fight_Type = {
    Round = 1, --轮播
    Circle = 2, --一直播
}


--分享类型
BattleConst.ShareType = {
    SharePk = 1, --切磋
    SharePlunder = 2, --掠夺
    ShareLadder = 3,  -- 天梯
    ShareArena = 4,   -- 竞技场
    ShareGuildWar = 5, -- 公会战
    ShareElite = 6,   -- 精英段位赛
    ShareTower = 7,   -- 试炼塔
    SharePlanes = 8,   -- 位面
    ShareAreanManyPeople = 9,   -- 多人竞技场
}

-- 根据战斗类型获取录像分享类型
function BattleConst.getShareTypeByBattleType( battle_type )
    if battle_type == BattleConst.Fight_Type.PK then
        return BattleConst.ShareType.SharePk
    elseif battle_type == BattleConst.Fight_Type.Arena then
        return BattleConst.ShareType.ShareArena
    elseif battle_type == BattleConst.Fight_Type.GuildWar then
        return BattleConst.ShareType.ShareGuildWar
    elseif battle_type == BattleConst.Fight_Type.LadderWar then
        return BattleConst.ShareType.ShareLadder
    elseif battle_type == BattleConst.Fight_Type.EliteMatchWar or battle_type == BattleConst.Fight_Type.EliteKingMatchWar then
        return BattleConst.ShareType.ShareElite
    elseif battle_type == BattleConst.Fight_Type.StarTower then
        return BattleConst.ShareType.ShareTower
    elseif battle_type == BattleConst.Fight_Type.PlanesWar then
        return BattleConst.ShareType.SharePlanes
    elseif battle_type == BattleConst.Fight_Type.AreanManyPeople then
        return BattleConst.ShareType.ShareAreanManyPeople
    end
end

function BattleConst.isNoRequest(type)
    return type == BattleConst.Fight_Type.Default or
          type == BattleConst.Fight_Type.PK or
          type == BattleConst.Fight_Type.HeroTestWar
        --   type == BattleConst.Fight_Type.WorldBoss
end

function BattleConst.isPvP(type)
    return type == BattleConst.Fight_Type.Arena or type == BattleConst.Fight_Type.Escort
end

function BattleConst.isNeedName(type)
    return type == BattleConst.Fight_Type.PK
end

function BattleConst.canDoBattle(fight_type)
    return BattleConst.getUIFightByFightType(fight_type) == MainuiController:getInstance():getUIFightType() or BattleConst.isNoRequest(fight_type) or BattleController:getInstance():getWatchReplayStatus()
end

--- 根据战斗类型获取ui的战斗类型
function BattleConst.getUIFightByFightType(fight_type)
    local btn_type = MainuiConst.ui_fight_type.drama_scene
    if fight_type == BattleConst.Fight_Type.Darma or fight_type == BattleConst.Fight_Type.Nil then --剧情副本或者假战斗
        btn_type = MainuiConst.ui_fight_type.drama_scene
    elseif fight_type == BattleConst.Fight_Type.SingleBoss or fight_type == BattleConst.Fight_Type.WorldBoss then --历练殿
        btn_type = MainuiConst.ui_fight_type.boss
    elseif fight_type == BattleConst.Fight_Type.StarTower then--星命塔
        btn_type = MainuiConst.ui_fight_type.star_tower
    elseif fight_type == BattleConst.Fight_Type.GuildDun then--公会副本
        btn_type = MainuiConst.ui_fight_type.guild_dun
    elseif fight_type == BattleConst.Fight_Type.Adventrue then--冒险
        btn_type = MainuiConst.ui_fight_type.sky_scene
    elseif fight_type == BattleConst.Fight_Type.Arena then--竞技场
        btn_type = MainuiConst.ui_fight_type.arena
    elseif fight_type == BattleConst.Fight_Type.Endless then--无尽试炼
        btn_type =  MainuiConst.ui_fight_type.endless
    elseif fight_type == BattleConst.Fight_Type.Escort then --护送
        btn_type = MainuiConst.ui_fight_type.escort
    elseif fight_type == BattleConst.Fight_Type.DungeonStone then
        btn_type = MainuiConst.ui_fight_type.dungeon_stone
    elseif fight_type == BattleConst.Fight_Type.Godbattle then  --众神战场
        btn_type = MainuiConst.ui_fight_type.godbattle
    elseif fight_type == BattleConst.Fight_Type.GuildWar then  --联盟战
        btn_type = MainuiConst.ui_fight_type.guildwar
    elseif fight_type == BattleConst.Fight_Type.PrimusWar then  --神殿玩法
        btn_type = MainuiConst.ui_fight_type.primusWar
    elseif fight_type == BattleConst.Fight_Type.LadderWar then  -- 天梯
        btn_type = MainuiConst.ui_fight_type.ladderwar
    elseif fight_type == BattleConst.Fight_Type.ExpeditFight then  -- 远征
        btn_type = MainuiConst.ui_fight_type.expedit_fight
    elseif fight_type == BattleConst.Fight_Type.YuanZhenFight then --元宵厨房
        btn_type = MainuiConst.ui_fight_type.yaunzhen_fight
    elseif fight_type == BattleConst.Fight_Type.EliteMatchWar or fight_type == BattleConst.Fight_Type.EliteKingMatchWar then --精英赛
        btn_type = MainuiConst.ui_fight_type.eliteMatchWar
    elseif fight_type == BattleConst.Fight_Type.ElementWar then --元素圣殿
        btn_type = MainuiConst.ui_fight_type.elementWar
    elseif fight_type == BattleConst.Fight_Type.HeavenWar then --天界副本
        btn_type = MainuiConst.ui_fight_type.heavenwar
    elseif fight_type == BattleConst.Fight_Type.SandybeachBossFight then  --沙滩保卫战 沙滩争夺战
        btn_type = MainuiConst.ui_fight_type.sandybeachBossFight
    elseif fight_type == BattleConst.Fight_Type.CrossArenaWar then  -- 跨服竞技场
        btn_type = MainuiConst.ui_fight_type.crossarenawar
    elseif fight_type == BattleConst.Fight_Type.LimitExercise then  -- 试炼之境
        btn_type = MainuiConst.ui_fight_type.limit_exercise
    elseif fight_type == BattleConst.Fight_Type.AdventrueMine then  -- 秘矿冒险
        btn_type = MainuiConst.ui_fight_type.adventrueMine
    elseif fight_type == BattleConst.Fight_Type.CrossChampion then  -- 跨服冠军赛
        btn_type = MainuiConst.ui_fight_type.crosschampion
    elseif fight_type == BattleConst.Fight_Type.TermBegins or
      fight_type == BattleConst.Fight_Type.TermBeginsBoss then  -- 开学季战斗类型
        btn_type = MainuiConst.ui_fight_type.termbegins
    elseif fight_type == BattleConst.Fight_Type.GuildSecretArea then --公会秘境战斗类型
        btn_type = MainuiConst.ui_fight_type.guildsecretarea
    elseif fight_type == BattleConst.Fight_Type.Arean_Team then --组队竞技场
        btn_type = MainuiConst.ui_fight_type.areanTeam
    elseif fight_type == BattleConst.Fight_Type.MonopolyWar_1 then -- 大富翁第一阶段
        btn_type = MainuiConst.ui_fight_type.monopolywar_1
    elseif fight_type == BattleConst.Fight_Type.MonopolyWar_2 then -- 大富翁第二阶段
        btn_type = MainuiConst.ui_fight_type.monopolywar_2
    elseif fight_type == BattleConst.Fight_Type.MonopolyWar_3 then -- 大富翁第三阶段
        btn_type = MainuiConst.ui_fight_type.monopolywar_3
    elseif fight_type == BattleConst.Fight_Type.MonopolyWar_4 then -- 大富翁第四阶段
        btn_type = MainuiConst.ui_fight_type.monopolywar_4
    elseif fight_type == BattleConst.Fight_Type.MonopolyBoss then -- 大富翁boss
        btn_type = MainuiConst.ui_fight_type.monopolyboss
    elseif fight_type == BattleConst.Fight_Type.Training_Camp then -- 新手训练营
        btn_type = MainuiConst.ui_fight_type.trainingcamp
    elseif fight_type == BattleConst.Fight_Type.PlanesWar then -- 新手训练营
        btn_type = MainuiConst.ui_fight_type.planeswar
    elseif fight_type == BattleConst.Fight_Type.YearMonsterWar then -- 年兽活动
        btn_type = MainuiConst.ui_fight_type.yearmonsterwar
    elseif fight_type == BattleConst.Fight_Type.WhiteDayWar then -- 女神试炼
        btn_type = MainuiConst.ui_fight_type.whitedaywar
    elseif fight_type == BattleConst.Fight_Type.AreanManyPeople then -- 多人竞技场
        btn_type = MainuiConst.ui_fight_type.areanmanypeople
    elseif fight_type == BattleConst.Fight_Type.PractiseTower then -- 试练塔活动
        btn_type = MainuiConst.ui_fight_type.practisetower
    end
    return  btn_type
end

--是否存在buff加成
function BattleConst.isBuffAdd(type)
    return type == BattleConst.Fight_Type.Champion or type == BattleConst.Fight_Type.PK 
end

--是否显示倒计时
function BattleConst.isNeedTimer(type)
    return type == BattleConst.Fight_Type.DanRace
    or type == BattleConst.Fight_Type.Godbattle
    or type == BattleConst.Fight_Type.ChiefWar
    or type == BattleConst.Fight_Type.DiamondWar
end

--是否显示入场PK动画
function BattleConst.isNeedSpecStart(type)
    return type == BattleConst.Fight_Type.Arena or type == BattleConst.Fight_Type.Champion or
        type == BattleConst.Fight_Type.PK or type == BattleConst.Fight_Type.Godbattle or
        type == BattleConst.Fight_Type.LadderWar or type == BattleConst.Fight_Type.CrossArenaWar or
        type == BattleConst.Fight_Type.CrossChampion
end

--是否只能自动
function BattleConst.isCanBattleAuto(type)
    return type == BattleConst.Fight_Type.ChiefWar
    or type == BattleConst.Fight_Type.Godbattle
    or type == BattleConst.Fight_Type.TeamDungeon
end

--是否显示出手次数
function BattleConst.isShowRoundHands(type)
    return type == BattleConst.Fight_Type.GuildBoss
    or type == BattleConst.Fight_Type.BigWorldNoBattle
    or type == BattleConst.Fight_Type.HeroBoss
end


--是否显示出手次数
function BattleConst.isShowRoundHands(type)
    return type == BattleConst.Fight_Type.GuildBoss
    or type == BattleConst.Fight_Type.BigWorldNoBattle
    or type == BattleConst.Fight_Type.HeroBoss
end

--是否需要出手倒计时
function BattleConst.isNeedHandTimer(type)
    return type == BattleConst.Fight_Type.PVP
    or type == BattleConst.Fight_Type.SkyLadder
    or type == BattleConst.Fight_Type.DiamondWar
end

--切后台不发暂定协议
function BattleConst.isEnterBackGroupNotPause(type)
    return type == BattleConst.Fight_Type.Godbattle
    or type == BattleConst.Fight_Type.DiamondWar
    or type == BattleConst.Fight_Type.SkyLadder
    or type == BattleConst.Fight_Type.DarmaBattle
    or type == BattleConst.Fight_Type.ChiefWar
end

--观战是否需要转换组别
function BattleConst.isNeedChangeGroup(type)
    return type == BattleConst.Fight_Type.TeamDungeon
end

function BattleConst.isExistsDungeonType(type)
    for _, v in pairs(BattleConst.Fight_Type) do
        if type == v then
            return true
        end
    end
    return false
end

BattleConst.JumpType = {
    Summon = 1,   -- 召唤
    HeroBag = 2,  -- 宝可梦背包
    Forge = 3,    -- 锻造屋
    Hallows = 4,  -- 神器
}


--关闭结算界面后 类型
BattleConst.Closed_Result_Type = {
    LevelUpgradeType = 1, --升级界面
    TaskExpType      = 2, --隐藏历练类型
    LimitGiftType    = 3, --限时礼包类型(升级升星会触发)

    -- GuideType        = 3, --引导类型
    -- PlayActType      = 4, --播放剧情类型
}

-- 兼容旧的录像数据中阵营光环id（转为现在的id列表）
BattleConst.Old_Halo_Id_Change = {
    [1] = {1},
    [2] = {2},
    [3] = {3},
    [4] = {4},
    [5] = {5},
    [6] = {21},
    [7] = {6},
    [8] = {6},
    [9] = {7},
    [10] = {7},
    [11] = {8},
    [12] = {8},
    [13] = {11,18},
    [14] = {13,17},
    [15] = {12,16},
    [16] = {14,20},
    [17] = {15,19},
}