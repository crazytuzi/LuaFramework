-- --------------------------------------------------
-- 角色数据
-- hosr
-- 说明，这里只做数据汇总
-- 参数变化需要发送通知的在收到更新协议那里处理
-- -------------------------------------------------
RoleEumn = RoleEumn or BaseClass()

-- 角色状态
RoleEumn.Status = {
    Normal = 0, --正常
    Fight = 2, --战斗
}

-- 活动事件
RoleEumn.Event = {
    None = 0,-- 0:无活动
    Dungeon = 1,-- 1:副本
    GuildZone = 2,-- 2:公会领地
    Convoy = 3,-- 3:护送
    Parade = 4,-- 4:游行
    Match = 5, -- 5:33段位赛
    Event_fairyland = 6, --幻境寻宝
    Exam = 7, -- 7 科举答题
    Event_examination_palace = 8 , --8 科举殿试答题
    WarriorReady = 10, -- 勇士战场准备
    Warrior = 11,    -- 勇士战场
    Marry = 12,              -- 参加典礼中
    Marry_cere = 13,          -- 参加典礼中(仪式阶段)
    Marry_guest = 14,         -- 参加典礼中(宾客)
    Marry_guest_cere = 15,    -- 参加典礼中(宾客 仪式阶段)
    TopCompete = 16, --巅峰对决
    GuildFight = 17, --公会战
    GuildFightReady = 18, --公会战准备区状态
    HeroReady = 20, -- 武道大会准备
    Hero = 21,      -- 武道大会
    GuildEliteFight = 22, --公会精英战
    DragonBoat = 23,        -- 赛龙舟
    WorldChampionReady = 24,        -- 天下第一武道会参与
    WorldChampionSuccess = 25,        -- 天下第一武道会匹配成功
    MasqueradeReady = 26,   -- 化妆舞会准备区
    Masquerade = 27,        -- 化妆舞会
    Home = 28,        -- 家园
    EnjoyMoon = 31,    -- 赏月
    SkyLantern = 30,    -- 孔明灯会
    Guildleague = 32,    -- 冠军联赛
    GuildleagueReady = 33,    -- 冠军联赛准备区
    DefenseCake = 34, --国庆活动保卫蛋糕
    DefenseCakeSub = 35, --国庆活动保卫蛋糕子任务
    Camp_halloween_pre = 36, --万圣节准备区
    Halloween = 37, --万圣节
    Halloween_sub = 38, --万圣节被识别
    camp_halloween_pre_enter = 39, -- 万圣节准备进入正式区
    GodsWar = 41, -- 诸神之战
    TeamDungeon_Recruit_Matching = 43, -- 组队副本招募匹配中
    PlayerkillMatching = 44, -- 英雄擂台匹配中
    PlayerkillBattle = 45, -- 打擂台状态
    GuildDungeonBattle = 46, -- 公会副本战斗
    GuildDungeon = 47, -- 公会副本场景
    AnimalChessMatch = 48,  -- 斗兽棋匹配
    AnimalChess = 49,       -- 斗兽棋进行中
    AnimalChessMatchSucc = 50,       -- 斗兽棋匹配成功
    NewQuestionMatch = 51, -- 新答题
    IngotCrashReady = 52, -- 元宝争霸准备
    IngotCrashPVP = 53, -- 元宝争霸1v1
    IngotCrashMatch = 54, -- 元宝争霸匹配
    IngotCrashLeagueOut = 55, -- 元宝争霸淘汰赛
    StarChallenge = 56, -- 星辰挑战
    ExquisiteShelf = 57, -- 玲珑宝阁
    GuildDragon = 58, -- 公会魔龙
    GuildDragonFight = 59, -- 公会魔龙 挑战
    GuildDragonRod = 60, -- 公会魔龙 掠夺
    RushTop = 61, -- 冲顶大会场内
    RushTopPlay = 62, -- 冲顶大会答题中
    GodsWarWorShip = 63, --诸神膜拜(膜拜状态)
    GodsWarWorShipChampion = 64, --诸神膜拜颁奖仪式
    Provocation = 65, -- 跨服约战大厅状态
    ProvocationRoom = 66, -- 跨服约战房间状态
    ApocalypseLord = 67, --天启领主（新龙王）
    DragonChess = 68,   --龙凤棋进行中
    DragonChessMatch = 69,  --龙凤棋匹配
    DragonChessMatchSucc = 70, --龙凤棋匹配成功
    GodsWarChallenge = 71,  --诸神boss战
    CanYonReady = 72,   --峡谷之巅准备区状态
    CanYon = 73,        --峡谷之巅活动状态
    WorldChampionStart = 74,        --天下第一武道会匹配中

}

-- 骑乘状态
RoleEumn.Ride = {
    None = 0, --无
    Fly = 1, --飞行
}

-- 队长状态
RoleEumn.TeamStatus = {
    None = 0, -- 无队伍
    Leader = 1, -- 队长
    Follow = 2, -- 跟随
    Away = 3, -- 暂离
    Offline = 4, -- 离线
}

-- 剧情状态
RoleEumn.DramaStatus = {
    None = 0, -- 无
    Running = 1, -- 进行中
}

-- 额外加点类型
RoleEumn.ExtPointType = {
    Honor = 1, -- 荣耀
    Item = 2, -- 道具
    Handbook = 3, -- 图鉴幻化
    LevBreak = 4, -- 等级突破
    LevBreakExchange = 5, -- 属性兑换
}

RoleEumn.attrExtraName = {
    ["hp_max"] =  TI18N("生命值")
    -- ,["mp_max"] =  "魔法上限"
    ,["atk_speed"] =  TI18N("攻速")
    ,["phy_dmg"] =  TI18N("物攻")
    ,["magic_dmg"] =  TI18N("魔攻")
    ,["phy_def"] =  TI18N("物防")
    ,["magic_def"] =  TI18N("魔防")
    -- ,["enhance_control"] = "控制加强"
    -- ,["anti_control"] = "控制抵抗"
    -- ,["heal_val"] = "治疗加强"
}

RoleInfo = RoleInfo or BaseClass()

function RoleInfo:__init()
    -- 角色状态
    self.status = RoleEumn.Status.Normal
    self.event = RoleEumn.Event.None
    self.ride = RoleEumn.Ride.None
    self.team_status = RoleEumn.TeamStatus.None
    self.drama_status = RoleEumn.DramaStatus.None

    -- 平台信息
    self.account = "" -- 帐号

    self.cross_type = 0 -- 跨服状态 0没有跨服1全跨服

    -- 基本信息
    self.id = 0 --"角色ID"
    self.platform = 0 --"平台标识"
    self.zone_id = 0 --"区号"
    self.name = 0 --"角色名"
    self.time_reg = 0 --"注册时间"
    self.sex = 0 --"性别"
    self.classes = 0 --"职业"
    self.label = 0 --"特殊标志"

    -- 属性
    self.hp = 0 --"生命"
    self.mp = 0 --"魔法"
    self.fc = 0 --"战力"
    self.hp_max = 0 --"生命上限"
    self.mp_max = 0 --"魔法上限"
    self.atk_speed = 0 --"攻击速度"
    self.phy_dmg = 0 --"物攻"
    self.magic_dmg = 0 --"魔攻"
    self.phy_def = 0 --"物防"
    self.magic_def = 0 --"魔防"
    self.crit = 0 --"暴击"
    self.tenacity = 0 --"坚韧"
    self.accuracy = 0 --"命中"
    self.evasion = 0 --"闪避"
    self.dmg_ratio = 0 --"伤害加成"
    self.def_ratio = 0 --"防御加成"
    self.enhance_control = 0 --"控制加强"
    self.anti_control = 0 --"控制抵抗"
    self.heal_val = 0 --"治疗加强"
    self.strength = 0 --"力量"
    self.constitution = 0 --"体质"
    self.magic = 0 --"智力"
    self.agility = 0 --"敏捷"
    self.endurance = 0 --"耐力"
    self.speed = 0 --"移动速度"
    self.point = 0 --"可分配点数"

    -- 资产
    self.coin = 0 -- "银币"
    self.gold = 0 -- "钻石"
    self.gold_bind = 0 -- "金币"
    self.intelligs = 0 -- "灵气"
    self.guild = 0 -- "公会贡献"
    self.energy = 0 -- "精力值"
    self.stars_score = 0 -- "星辰积分"
    self.satiety = 0 -- "饱食度"
    self.achieve_score = 0 -- "成就点"
    self.endless_challenge = 0 -- "挑战心得"

    -- 资产负债
    self.debt_coin = 0 -- 负债银币
    self.debt_gold = 0 -- 负债钻石
    self.debt_gold_bind = 0 -- 负债金币

    -- 经验等级
    self.lev = 0 -- "等级"
    self.exp = 0 -- "经验"
    self.reserve_exp = 0 -- "储备经验"
    self.lev_break_times = 0 -- 等级突破次数

    -- 自动加点方案
    self.pre_str = 0 -- "力量"
    self.pre_con = 0 -- "体质"
    self.pre_magic = 0 -- "智力"
    self.pre_agi = 0 -- "敏捷"
    self.pre_end = 0 -- "耐力"

    self.guild_name = ""

    -- 场景属性
    self.looks = {} -- 外观

    -- 荣耀已加点
    self.honorPoint = 0
    -- 道具加点
    self.itemPoint = 0
    -- 幻化加点
    self.handbookPoint = 0
    -- 等级突破加点
    self.levbreakPoint = 0
    -- 兑换等数
    self.levbreakExchangePoint = 0

    -- 历练双倍点
    self.skl_unique_exp = 0

    -- 改名次数
    self.rename = 0
    self.first_free = 0

    self.lover_id = nil --（妻子/丈夫）角色ID
    self.lover_platform = nil --（妻子/丈夫）平台标识
    self.lover_zone_id = nil --（妻子/丈夫）区号
    self.lover_name = nil --（妻子/丈夫）角色名
    self.wedding_status = nil --典礼状态

    self.camp = 0 -- 阵营值

    self.fid = 0 --家园id
    self.family_platform = "" --平台标识
    self.family_zone_id = 0 --区号

    self.last_classes_modify_time = 0 --转职时间
    self.classes_modify_times = 0 -- 转职次数
end

-- 数据更新
function RoleInfo:Update(proto, float)
    for k,v in pairs(proto) do
        if k == "ext_point" then
            for i,v1 in ipairs(v) do
                if v1.type == RoleEumn.ExtPointType.Honor then
                    self.honorPoint = v1.point
                elseif v1.type == RoleEumn.ExtPointType.Item then
                    self.itemPoint = v1.point
                elseif v1.type == RoleEumn.ExtPointType.Handbook then
                    self.handbookPoint = v1.point
                elseif v1.type == RoleEumn.ExtPointType.LevBreak then
                    self.levbreakPoint = v1.point
                elseif v1.type == RoleEumn.ExtPointType.LevBreakExchange then
                    self.levbreakExchangePoint = v1.point
                end
            end
        else
            if float then
                local change = v - self[k]
                if change > 0 and RoleEumn.attrExtraName[tostring(k)] ~= nil then
                    NoticeManager.Instance:FloatTxt(string.format("%s+%s", RoleEumn.attrExtraName[tostring(k)], change))
                end
            end
            self[k] = v
        end
    end
end

--传入对应的资产key获取自身对应资产的数量
function RoleInfo:GetMyAssetById(id)
    if id == 90000 then
        --银币
        return self.coin
    elseif id == 90001 then
        --绑定银币
        return self.bind
    elseif id == 90002 then
        --钻石
        return self.gold
    elseif id == 90003 then
        --金币
        return self.gold_bind
    elseif id == 90004 then
        --灵气
        return self.intelligs
    elseif id == 90005 then
        --宠物经验
        return self.pet_exp
    elseif id == 90006 then
        --精力值
        return self.energy
    elseif id == 90007 then
        --爱心
        return self.character
    elseif id == 90010 then
        -- 经验
        return self.exp
    elseif id == 90011 then
        -- 公会贡献
        return self.guild
    elseif id == 90012 then
        -- 星辰积分
        return self.stars_score
    elseif id == 90018 then
        --恩爱值
        return self.love
    elseif id == 90019 then
        -- 师道值
        return self.teacher_score
    elseif id == 90020 then
        -- 师道值
        return self.tournament
    elseif id == 90024 then
        -- 图鉴积分
        return self.handbook_point
    elseif id == 90025 then
        -- 中秋积分
        return self.mid_autumn_score
    elseif id == 90026 then
        -- 星钻
        return self.star_gold
    elseif id == 90035 then
        -- 水晶积分
        return self.crystal
    elseif id == 90055 then
        -- 历练双倍点
        return self.skl_unique_exp
    elseif id == KvData.assets.cake_exchange then
        -- 水晶积分
        return self.exchange or 0
    elseif id == KvData.assets.dollar then
        return self.dollar or 0
    elseif id == KvData.assets.naughty then
        return self.naughty or 0
     elseif id == KvData.assets.sunshine then
        return self.sunshine or 0
    elseif id == KvData.assets.single_dog then
        return self.single_dog or 0
    elseif id == KvData.assets.godswar then
        return self.godswar or 0
    elseif id == KvData.assets.slot_machine then
        return self.slot_machine or 0
    elseif id == KvData.assets.zillionaire_sc then
        return self.zillionaire_sc or 0
    elseif id == KvData.assets.score_exchange then
        return self.score_exchange or 0
    elseif id == KvData.assets.new_open_turn then
        return self.new_open_turn or 0
    elseif id == KvData.assets.long_score then
        return self.long_score or 0
    elseif id == KvData.assets.camp_pray_sc then
        return self.camp_pray_sc or 0
    end
    return 0
end

function RoleInfo:ExtraPoint()
    return self.honorPoint + self.itemPoint + self.handbookPoint + self.levbreakPoint + self.levbreakExchangePoint
end
