
CombatUtil = CombatUtil or {}

-- 战斗摄像头
CombatUtil.camera_angle = 25
CombatUtil.camera_z = -10

CombatUtil.map_scale = Vector3(7.2, 8, 1)
CombatUtil.map_scale_widescreen = Vector3(8.65, 9.61, 1.2)

CombatUtil.playerBodyPath = "prefabs/roles/model/%s.unity3d"
CombatUtil.playerSkinPath = "prefabs/roles/skin/%s.unity3d"
CombatUtil.playerCtrlPath = "prefabs/roles/animation/role.unity3d"
CombatUtil.playerWeaponPath= "prefabs/roles/weapon/%s.unity3d"
CombatUtil.playerWingPath= "prefabs/wing/model/%s.unity3d"
CombatUtil.playerBeltPath= "prefabs/surbase/%s.unity3d"

CombatUtil.headctrlpath = "prefabs/roles/headanimation/%s.unity3d"
CombatUtil.headSkinPath = "prefabs/roles/headskin/%s.unity3d"
CombatUtil.headModelPath = "prefabs/roles/head/%s.unity3d"

CombatUtil.npcModelPath = "prefabs/npc/model/%s.unity3d"
CombatUtil.npcAnimationPath = "prefabs/npc/animation/%s.unity3d"
CombatUtil.npcSkinPath = "prefabs/npc/skin/%s.unity3d"

CombatAssetType = {
    Main = 1
    ,Dep = 2
}

CombatUtil.startResources = {
    {file = AssetConfig.bufficon, type = CombatAssetType.Dep, holdTime = 120}
    ,{file = AssetConfig.combat_texture, type = CombatAssetType.Dep, holdTime = 120}
    ,{file = AssetConfig.combat2_texture, type = CombatAssetType.Dep, holdTime = 120}
    ,{file = AssetConfig.skill_shout, type = CombatAssetType.Dep, holdTime = 120}
    -- ,{file = AssetConfig.combat_cd_effect, type = CombatAssetType.Main, holdTime = 120}
    -- ,{file = AssetConfig.wing_skill, type = CombatAssetType.Dep, holdTime = 120}
    -- ,{file = AssetConfig.skillIcon_endless, type = CombatAssetType.Dep, holdTime = 120}
    ,{file = AssetConfig.childhead, type = CombatAssetType.Dep, holdTime = 120}
    ,{file = AssetConfig.normalbufficon, type = CombatAssetType.Dep}
    ,{file = AssetConfig.formation_icon, type = CombatAssetType.Dep}
    -- ,{file = AssetConfig.skillIcon_roleother, type = CombatAssetType.Dep}
    ,{file = AssetConfig.combat_mapui, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.heads, type = CombatAssetType.Dep, holdTime = 120}
    ,{file = AssetConfig.combat_skillareaPath, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.combat_mixareaPath, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.combat_headinfoareaPath, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.combat_counterinfoareaPath, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.combat_functioniconPath, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.combat_extend_path, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.combat_summon_path, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.combat_itempanel_path, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.transition, type = CombatAssetType.Main, holdTime = 120}
    ,{file = AssetConfig.combat_mainPanelPath, type = CombatAssetType.Main, holdTime = 120}
    -- ,{file = AssetConfig.talisman_skill, type = CombatAssetType.Dep, holdTime = 120}
    ,{file = string.format(AssetConfig.effect, 20021), type = CombatAssetType.Main, holdTime = 120}
    ,{file = string.format(AssetConfig.effect, 20022), type = CombatAssetType.Main, holdTime = 120}
    ,{file = string.format(AssetConfig.effect, 20023), type = CombatAssetType.Main, holdTime = 120}
}

-- 特殊技能
-- 1001 防御
-- 1002 逃跑
-- 1003 保护
-- 1004 使用物品
-- 1006 捕宠
CombatUtil.specialList = {1001, 1002, 1004, 1006, 1101, 1102, 1103, 1104, 1105, 1106, 1126}
CombatUtil.specialSkillList = {1001, 1002, 1003, 1004, 1006}

SelfCombatCommand = {
    [1] = TI18N("复活"),
    [2] = TI18N("治疗"),
    [3] = TI18N("保护"),
    [4] = TI18N("解控"),
    [5] = TI18N("召唤"),
}

TargetCombatCommand = {
    [1] = TI18N("集火"),
    [2] = TI18N("封印"),
    [3] = TI18N("物攻"),
    [4] = TI18N("法攻"),
    [5] = TI18N("守尸"),
}

CombatEventType = {
    Start = "Start"
    ,End = "End"
    ,Hit = "Hit"
    ,MultiHit = "MultiHit"
    ,MoveEnd = "MoveEnd"
}

-- 参战者类型
FighterType = {
    None = 0
    ,Role = 1
    ,Unit = 2
    ,Pet = 3
    ,Cloner = 4
    ,Guard = 5
    ,Child = 6
}

SkillTargetType = {
    SelfGroup = 0   -- 友方
    ,Enemy = 1      -- 敌方
    ,Self = 2       -- 自身
    ,All = 3        -- 任何人
    ,Master = 4     -- 主人
    ,SelfGroupNotSelf = 5     --除自己外的友方
    ,Couple = 6     -- 伴侣
    ,None = 7     -- 无目标
    ,EnemyGroupPet = 8     -- 敌方宠物
    ,SelfGroupPet = 9     -- 己方宠物
}

-- 布局
FighterLayout = {
    EAST = 1
    ,WEST = 2
}

-- 动作
FighterAction = {
    None = 0
    ,Stand = 1
    ,Move = 2
    ,BattleStand = 3
    ,BattleMove = 4
    ,Attack = 5
    ,Hit = 6
    ,Dead = 7
    ,Idle = 9
    ,MultiHit = 10
    ,Upthrow = 11
    ,Standup = 12
    ,Defense = 13
    ,Pick = 14
    ,Jump = 15
    ,Show = 16
}

-- 移动类型
MoveType = {
    ToTarget = 1
    ,ToSelf = 2
    ,TargetToSelf = 3 -- 反正时用到
    ,ToTargetOrg = 4 -- 保护时用到
    ,BlinkToTarget = 5 -- 瞬移到目标前
}

-- 作用范围
EffectRange = {
    Single = 1
    ,Group = 2
}

-- 特效触发时间
EffectTrigger = {
    ActionStart = 1
    ,Hit = 2
    ,MultiHit = 3
    ,ActionEnd = 4
    ,MoveEnd = 5
    ,Follow = 6
}

-- 特效攻击类型
EffectAttackType = {
    Normal = 0          -- 普通
    ,Attack = 1         -- 攻击
    ,MultiHit = 2       -- 连击
    ,Thunder = 3        -- 雷击
    ,Boom = 4           -- 爆击
    ,MuiltThunder = 5           -- 群体雷击
    ,Bubble1 = 6           -- 泡泡弹射1段
    ,Bubble2 = 7           -- 泡泡弹射2段
    ,Geocentric1 = 8           -- 地心烈炎1段
    ,Geocentric2 = 9           -- 地心烈炎2段
    ,Poker1 = 10 -- 红牌
    ,Poker2 = 11 -- 黑牌
}

-- 特效目标类型
EffectTarget = {
    Attacker = 0
    ,Defence = 1
}

-- 特效范围
EffectRange = {
    Single = 1
    ,Group = 2
}

-- 特效类型
EffectType = {
    FlyEffect = 0
    ,StaticEffect = 1
    ,HitFlyEffect = 2
}

-- 移动方向
UIMoveDir = {
    Up = 1
    ,Down = 2
    ,Lef = 3
    ,Right = 4
}

CombatClasses = {
    None = 0,
    Gladiator = 1,  --狂剑
    Mage = 2,       --魔导
    Ranger = 3,     --战弓
    Musketeer = 4,  --兽灵
    Devine = 5,     --秘言
    Moon = 6,      --月魂
    Temple = 7,     -- 圣骑
}

-- 特效绑定
EffectTargetPoint = {
    Origin = 0      -- 原点
    ,LHand = 1      -- 左手
    ,RHand = 2      -- 右手
    ,LFoot = 3      -- 左脚
    ,RFoot = 4      -- 右脚
    ,Weapon = 5     -- 武器
    ,Custom = 6     -- 自定义
    ,LWeapon = 7    -- 左武器
    ,RWeapon = 8    -- 右武器
}

-- 特效挂点
EffectDataMounter = {
    Origin = 0
    ,Weapon = 1
    ,WingL1 = 2
    ,WingL2 = 3
    ,WingL3 = 4
    ,WingR1 = 5
    ,WingR2 = 6
    ,WingR3 = 7
    ,Wing = 8
    ,Custom = 9
    ,TopOrigin = 10
}

-- 震屏类型
CombatShakeType = {
    Normal = 1
    ,Small = 2
}

-- 状态
CombatSeletedState = {
    Idel = 1
    ,Role = 2
    ,Pet = 3
}

-- 战斗类型
CombatFightType = {
    PVP = 1
    ,PVE = 2
}

CombatUtil.SkillPanelType = {
    RoleAttack = 1,
    RoleSkill = 2,
    RoleSp = 3,
    PetAttack = 4,
    PetSkill = 5,
    PetSp = 6,
    None = 7,
}

Combat_Type = {
    [1] = TI18N("普通战斗"),
    [2] = TI18N("剧情战斗"),
    [3] = TI18N("野外挂机"),
    [4] = TI18N("试炼战斗"),
    [5] = TI18N("世界boss"),
    [6] = TI18N("切磋"),
    [7] = TI18N("护送"),
    [8] = TI18N("悬赏任务"),
    [9] = TI18N("公会强盗"),
    [10] = TI18N("宝图任务"),
    [11] = TI18N("副本战斗"),
    [13] = TI18N("上古封妖"),
    [14] = TI18N("挑战会长"),
    [15] = TI18N("精英历练"),
    [16] = TI18N("天空之塔"),
    [17] = TI18N("职业挑战"),
    [18] = TI18N("幻境寻宝"),
    [19] = TI18N("幻境寻宝Boss"),
    [20] = TI18N("幻境寻宝宝箱"),
    [21] = TI18N("荣耀试炼"),
    [22] = TI18N("任务链"),
    [23] = TI18N("猴子"),
    [24] = TI18N("猴王"),
    [25] = TI18N("主线历练"),
    [26] = TI18N("星座挑战"),
    [27] = TI18N("伴侣任务"),
    [28] = TI18N("公会宝藏"),
    [29] = TI18N("宠物情缘"),
    [30] = TI18N("情缘任务"),
    [31] = TI18N("诗词"),
    [32] = TI18N("诗词Boss"),
    [33] = TI18N("师徒任务"),
    [34] = TI18N("远航任务"),
    [35] = TI18N("偷钱"),
    [36] = TI18N("勇者试炼"),
    [40] = TI18N("武道会"),
    [43] = TI18N("无尽挑战"),
    [54] = TI18N("夺宝奇兵"),
    [58] = TI18N("武道会"),
    [61] = TI18N("龙王资格"),
    [62] = TI18N("龙王试练"),
    [63] = TI18N("玲珑宝阁"),
    [68] = TI18N("银月贤者"),
    [69] = TI18N("天启资格"),
    [70] = TI18N("天启试练"),
    [71] = TI18N("诸神挑战"),
    [72] = TI18N("幻月灵兽"),
    [100] = TI18N("竞技场"),
    [102] = TI18N("段位赛"),
    [103] = TI18N("勇士战场"),
    [104] = TI18N("巅峰对决"),
    [105] = TI18N("公会战"),
    [106] = TI18N("公会精英战"),
    [107] = TI18N("荣耀战场"),
    [108] = TI18N("冠军联赛"),
    [110] = TI18N("诸神之战小组赛"),
    [111] = TI18N("诸神之战决赛"),
    [113] = TI18N("英雄擂台"),
    [114] = TI18N("钻石联赛"),
    [115] = TI18N("跨服擂台"),
    [116] = TI18N("峡谷之巅"),
}

CombatUtil.NotShowWingType = {
    [107] = TI18N("荣耀战场"),
    [104] = TI18N("巅峰对决"),
    [40] = TI18N("武道会"),
    [102] = TI18N("段位赛"),
    [105] = TI18N("公会战"),
    [106] = TI18N("公会精英战"),
}

CombatUtil.NotShowBloodType = {
    [104] = TI18N("巅峰对决"),
    [107] = TI18N("荣耀战场"),
    [108] = TI18N("冠军联赛"),
    [110] = TI18N("诸神之战小组赛"),
    [111] = TI18N("诸神之战决赛"),
    [114] = TI18N("钻石联赛"),
}

CombatUtil.CombatType = {
    unknown = 0, --                    %% 未知类型（异常情况）
    kill_unit = 1, --                  %% 普通击杀单位
    plot = 2, --                       %% 剧情
    hook = 3, --                       %% 暗雷挂机
    trial = 4, --                      %% 试炼战斗
    world_boss = 5, --                 %% 世界boss
    challenge = 6, --                  %% 切磋
    escort = 7, --                     %% 护送
    quest_offer = 8, --                %% 悬赏任务
    guild_robber = 9, --               %% 公会强盗
    quest_treasure = 10, --            %% 宝图任务
    dungeon = 11, --                   %% 副本战斗
    treasure_ghost = 13, --            %% 封妖
    challenge_leader = 14, --          %% 挑战会长分身
    quest_prac_quint = 15, --          %% (主线)精英历练任务
    tower_boss = 16, --                %% 天空之塔
    classes_challenge = 17, --         %% 职业挑战
    fairyland = 18, --                 %% 幻境寻宝
    fairyland_rainbow_boss = 19, --    %% 幻境寻宝彩虹boss
    fairyland_box_boss = 20, --        %% 幻境寻宝宝箱boss
    glory = 21, --                     %% 荣耀试炼
    quest_chain = 22, --               %% 任务链
    campaign_unit_match = 23, --       %% 匹配怪 
    campaign_unit_match_boss = 24, --  %% 匹配怪boss 
    quest_prac = 25, --                %% (主线)历练任务（非精英）
    constellation = 26, --             %% 星座
    quest_marriage = 27, --            %% 伴侣战斗任务
    guild_treasure = 28, --            %% 公会宝藏
    meet_pet = 29, --                  %% 宠物情缘
    quest_couple = 30, --              %% 情缘任务
    campaign_unit_order = 31, --       %% 顺序击杀怪
    campaign_unit_order_boss = 32, --  %% 顺序击杀怪(boss) 
    quest_teacher = 33, --             %% 师徒任务
    shipping = 34, --                  %% 远航
    campaign_unit_steal = 35, --       %% 偷钱
    brave_trial = 36, --               %% 勇者试炼
    dragon_boat = 37, --               %% 赛龙舟
    campaign_unit_kill = 38, --        %% 死亡数量
    campaign_unit_kill_boss = 39, --   %% 河妖
    tournament = 40, --                %% 武道会
    elf = 41, --                       %% 精灵
    campaign_unit_base = 42, --        %% 普通活动怪
    endless_challenge = 43, --         %% 无尽挑战
    catch_pet = 44, --                 %% 抓宠物
    lev_break = 45, --                 %% 等级突破
    camp_cake = 46, --                 %% 蛋糕
    campaign_unit_card = 47, --        %% 翻牌
    campaign_unit_card_boss = 48, --   %% 翻牌boss
    sworn = 49, --                     %% 结拜系统
    treasure_pet = 50, --              %% 宠物战斗
    campaign_unit_heap = 51, --        %% 堆雪人
    campaign_snow = 52, --             %% 打雪战
    dungeon_tower1 = 54, --            %% 夺宝奇兵（战斗录像用）
    maze = 55, --                       %% 珍宝石板
    guild_dungeon = 56, --              %% 公会副本
    campaign_unit_fox = 57, --          %% 顽皮小狐狸
    tournament_2v2 = 58, --                %% 武道会
    quest_king = 59, --                %% 
    glory_new = 60, --                 %% 爵位
    spirit_treasure_general = 61, --   %% 精灵兽宝藏将领
    spirit_treasure_boss = 62, --      %% 精灵兽宝藏boss
    exquisite_shelf = 63, --           %% 玲珑宝阁
    single_dog = 64, --                %% 单身狗打秀恩爱
    guild_dragon_monster = 65, --      %% 公会魔龙挑战打魔龙
    guild_dragon_loot = 66, --         %% 公会魔龙挑战掠夺玩家
    skl_unique = 67, --                %% 绝招挑战
    stars_trial = 68, --               %% 星辰试炼
    oracle_treasure_general = 69, --   %% 天启兽宝藏将领
    oracle_treasure_boss = 70, --      %% 天启兽宝藏boss
    combat_type_gods_challenge = 71, -- %% 诸神挑战
    combat_type_star_moon = 72, -- %% 星月灵兽/幻月灵兽
    arena = 100, --           %% 竞技场
    qualifying = 102, --      %% 段位赛
    warrior = 103, --         %% 勇士战场
    top_compete = 104, --     %% 巅峰对决
    guild_war = 105, --       %% 公会战
    guild_hero = 106, --      %% 公会精英战
    hero = 107, --            %% 荣耀
    guild_league = 108, --    %% 公会联赛
    guild_war_cross = 109, -- %% 跨服公会战
    gods_duel = 110, --       %% 诸神之战小组赛
    gods_duel_final = 111, --       %% 诸神之战决赛
    guild_siege = 112, --     %% 公会攻城战
    rencounter = 113, --      %% 星辰擂台
    gold_league = 114, --         %% 钻石联赛
    provocation = 115, --       %% 跨服约战
}

-- 显示弹幕的录像战斗类型
CombatUtil.ShowDamakuRecType = {
    [1] = true,
    [2] = true,
    [3] = true,
    [9] = true,
    [10] = true,
    [13] = true,
    [71] = true,
    [106] = true,
}
--显示弹幕的观战类型
CombatUtil.ShowDamakuWatchType = {
    [110] = true,
    [111] = true,
    [71] = true,
    [106] = true,
}


-- 只比较数字和字符串
function table.containValue(t, value)
    for k, v in pairs(t) do
        if value == v then
            return true;
        end
    end
    return false;
end
function table.containKey(t, key)
    return BaseUtils.ContainKeyTable(t, key)
end

-- 遍历数组
function Iterator(list)
    local index = 1
    local size = #list
    local nextElement = function(l)
        if index <= size then
            local elem = list[index]
            index = index + 1
            return elem
        else
            return nil
        end
    end
    return nextElement, list
end

function CombatUtil.GridToPosition(row, column)
    local dict = CombatManager.Instance.gridToPostDict
    local key = "{" .. row .. ", " .. column .. "}"
    if dict[key] then
        return dict[key]
    else
        local real = ctx.ScreenWidth / ctx.ScreenHeight
        local oSize = 1.871345
        local bevel = 2 * oSize / math.cos((90 - CombatUtil.camera_angle) / 180 * math.pi)
        local y = 0
        local ratio_x = 2 * oSize * real / 128
        local ratio_z = bevel / 72
        local x = (column - 64) * ratio_x
        local z = 0 - (row - 36) * ratio_z
        dict[key] = Vector3(x, y, z)
        return dict[key]
    end
end

function CombatUtil.GridDistance(srcRow, srcColumn, targetRow, targetColumn)
    local srcPosition = CombatUtil.GridToPosition(srcRow, srcColumn)
    local targetPosition = CombatUtil.GridToPosition(targetRow, targetColumn)
    local x = targetPosition.x - srcPosition.x
    local y = targetPosition.y - srcPosition.y
    local z = targetPosition.z - srcPosition.z
    return Vector3(x, y, z)
end

function CombatUtil.Key(...)
    local params = {...}
    local retval = nil
    for _, v in ipairs(params) do
        if (retval == nil) then
            retval = "" .. v
        else
            retval = retval .. "_" .. v
        end
    end
    return retval
end

function CombatUtil.GetDefaultCombatSkillObject(skillId, skillLev, name)
	local skill = {id = 0, lev = 1, name = "", type = 0, sub_type = 0, motion_id = {1000}, is_shout = 0, shout_id = 0, attack_type = 0, target_type = 1, attack_times = 1, target_list = {{flag = 1,target_mode = 2,target_num = 1}}, cooldown = 0, cost_mp = 0}
    skill.id = skillId
    skill.lev = skillLev
    skill.name = name
    if skillId == 1003 or skillId == 60126 then
        skill.is_shout = 1
    end
    return skill
end

function CombatUtil.GetDefaultMotionEvent(motionId, modelId)
	local eventData = {motion_id = 1000, npc_res_id = 30000, total = 1067, hit_time = 466, multi_time = 466}
    eventData.motion_id = motionId
    eventData.npc_res_id = modelId
    return eventData
end

-- function CombatUtil.WorldToUIPoint(camera, point)
--     local sPoint = camera:WorldToScreenPoint(point)
--     local width = ctx.ScreenWidth
--     local height = ctx.ScreenHeight
--     local x = 1280 * sPoint.x / width
--     local y = 720 * sPoint.y / height
--     return Vector3(x - 640, y - 360, sPoint.z)
-- end
function CombatUtil.WorldToUIPoint(camera, point)
    -- 返回的是屏幕长宽
    local sPoint = camera:WorldToScreenPoint(point)
    local width = ctx.ScreenWidth
    local height = ctx.ScreenHeight
    local origin = 960 / 540
    local current = width / height

    -- 实际UI长宽
    local h = ((origin / current - 1) / 2 + 1) * 540
    local w = ((origin - current) / 2 + current) / origin * 960

    -- 屏幕长宽转换成UI长宽
    local x = w * sPoint.x / width
    local y = h * sPoint.y / height

    return Vector3(x - w / 2, y - h / 2, sPoint.z)
end

function CombatUtil.UIToWorldPoint(camera, point)
    -- 返回的是屏幕长宽
    local width = ctx.ScreenWidth
    local height = ctx.ScreenHeight
    local origin = 960 / 540
    local current = width / height

    -- 实际UI长宽
    local h = ((origin / current - 1) / 2 + 1) * 540
    local w = ((origin - current) / 2 + current) / origin * 960
-- print(string.format("%s, %s", w, h))
    local sPoint = Vector2(point.x * width / w + w / 2, point.y * height / h + h / 2)

    return camera:ScreenToWorldPoint(sPoint)
    -- return camera:ScreenToWorldPoint(point)
end

-- 主播报升序
function CombatUtil.SortMojorData(elem1, elem2)
    if elem1.order > elem2.order then
        return false
    else
        return true
    end
end

-- 子播报升序
function CombatUtil.SortSubData(elem1, elem2)
    if elem1.sub_order > elem2.sub_order then
        return false
    elseif elem1.sub_order < elem2.sub_order then
        return true
    else
        if table.containValue(CombatUtil.specialSkillList, elem1.skill_id) then
            return false
        else
            return elem1.target_id > elem2.target_id -- 解决不稳定排序问题
        end
    end
end

-- true 不调换
function CombatUtil.SortSubListData(elem1, elem2)
    local target1 = elem1.target_id
    local target2 = elem2.target_id
    local orderVal1 = -1
    local orderVal2 = -1
    if #elem1.self_changes > 0 then
        for _, data in ipairs(elem1.self_changes) do
            if data.change_type == 7 then
                orderVal1 = data.change_val
            end
        end
    end
    if #elem2.self_changes > 0 then
        for _, data in ipairs(elem2.self_changes) do
            if data.change_type == 7 then
                orderVal2 = data.change_val
            end
        end
    end
    if orderVal1 == -1 and orderVal2 == -1 then
        return target1 < target2
    elseif orderVal1 == orderVal2 then
        return target1 < target2
    else
        return orderVal1 < orderVal2
    end
end

-- 计算距离
function CombatUtil.Distance(rx, ry, tx, ty)
    local rvl = math.pow(rx - tx, 2) + math.pow(ry - ty, 2)
    rvl = math.sqrt(rvl)
    return rvl
end

-- 获取技能的攻击范围类型
function CombatUtil.SkillRange(skill)
    local tList = skill.target_list
    -- 60075 雷霆之怒 特殊处理
    if tList == nil or skill.id == 60075 or skill.id == 160088 or skill.id == 160087 then
        return EffectRange.Single
    else
        for _, info in ipairs(tList) do
            if info.target_num > 1 then
                return EffectRange.Group
            end
        end
        return EffectRange.Single
    end
end

function CombatUtil.GetBehindPoint(controller, distance)
    if controller == nil then
        -- Log.Error("取位置时候出错controller是空")
        return Vector3(0, 0, 0)
    end
    local face = controller.originFaceToPos
    local originPoint = controller.originPos
    return CombatUtil.GetBehindPoint2(face, originPoint, controller.layout, distance)
end

function CombatUtil.GetBehindPointCur(controller, distance)
    if controller == nil or BaseUtils.isnull(controller.transform) then
        -- Log.Error("取位置时候出错controller是空")
        return Vector3(0, 0, 0)
    end
    local face = controller.originFaceToPos
    local originPoint = controller.transform.position
    return CombatUtil.GetBehindPoint2(face, originPoint, controller.layout, distance)
end

function CombatUtil.GetBehindPoint2(face, originPoint, layout, distance)
    local dx = math.abs(face.x - originPoint.x)
    local dz = math.abs(face.z - originPoint.z)
    local angle = math.atan(dz / dx)
    local px = math.cos(angle) * distance
    local pz = math.sin(angle) * distance
    if layout == FighterLayout.EAST then
        return Vector3(originPoint.x + px, originPoint.y, originPoint.z - pz)
    else
        return Vector3(originPoint.x - px, originPoint.y, originPoint.z + pz)
    end
end


function CombatUtil.SetAlpha(gameObject, value)
    if value == 0 then
        CombatUtil.SetMesh(gameObject, false)
    elseif value == 1 then
        CombatUtil.SetMesh(gameObject, true)
        Utils.SetAlpha(gameObject, value)
    else
        CombatUtil.SetMesh(gameObject, true)
        Utils.SetAlpha(gameObject, value)
    end
end

-- 隐藏网格渲染/buff特效和人物武器头部
function CombatUtil.SetMesh(go, hide)
    if BaseUtils.isnull(go) then
        return
    end
    local pskin = go:GetComponentsInChildren(MeshRenderer, true)
    local smr = go:GetComponentsInChildren(SkinnedMeshRenderer, true)
    for i,v in ipairs(pskin) do
        if string.find(v.name, 'BuffEffect') ~= nil
            or string.find(v.name, 'Mesh_') ~= nil
            or v.name == "bp_root"
            or v.name == "Bip_L_Foot"
            or v.name == "Bip_L_Hand"
            or v.name == "Bip_L_Weapon"
            or v.name == "Bip_R_Foot"
            or v.name == "Bip_R_Hand"
            or v.name == "Bip_R_Weapon"
            or v.name == "bp_wing"
            or v.name == "Bip_Head" then
            -- v.enabled = hide
            v.gameObject:SetActive(hide)
        end
    end
    for i,v in ipairs(smr) do
        if string.find(v.name, 'BuffEffect') ~= nil
            or string.find(v.name, 'Mesh_') ~= nil
            or v.name == "bp_root"
            or v.name == "Bip_L_Foot"
            or v.name == "Bip_L_Hand"
            or v.name == "Bip_L_Weapon"
            or v.name == "Bip_R_Foot"
            or v.name == "Bip_R_Hand"
            or v.name == "Bip_R_Weapon"
            or v.name == "bp_wing"
            or v.name == "Bip_Head" then
            v.gameObject:SetActive(hide)
            -- v.enabled = hide
        end
    end
end

function CombatUtil.SetColor(go, color)
    if BaseUtils.isnull(go) then
        return
    end
    local pskin = go:GetComponent(MeshRenderer)
    if pskin ~= null and not BaseUtils.is_null(pskin) then
        pskin.enabled = hide
    end
    for i = 0, go.transform.childCount-1 do
        local t = go.transform:GetChild (i)
        local pskin = t:GetComponent(MeshRenderer)
        if pskin ~= null and not BaseUtils.is_null(pskin) then
            pskin.material.color = color
        end
        local isbuff = string.find(t.gameObject.name, 'BuffEffect')
        local smr = t:GetComponent(SkinnedMeshRenderer)
        if not BaseUtils.is_null(smr) and isbuff == nil then
            smr.material.color = color
        end
        -- if isbuff ~= nil or t.gameObject.name == "bp_root" then
        --     t.gameObject:SetActive(hide)
        -- end
    end
end

function CombatUtil.GetNormalSKill(classes)
    if classes == CombatClasses.Gladiator then
        return 1101
    elseif classes == CombatClasses.Mage then
        return 1102
    elseif classes == CombatClasses.Ranger then
        return 1103
    elseif classes == CombatClasses.Musketeer then
        return 1104
    elseif classes == CombatClasses.Devine then
        return 1105
    elseif classes == CombatClasses.Moon then
        return 1106
    elseif classes == CombatClasses.Temple then
        return 1126
    else
        return 1105
    end
end

function CombatUtil.GetNormalSKillMotion(classes)
    local motionId = 10010
    if classes == CombatClasses.Gladiator then
        motionId = 10010
    elseif classes == CombatClasses.Mage then
        motionId = 20010
    elseif classes == CombatClasses.Ranger then
        motionId = 30010
    elseif classes == CombatClasses.Musketeer then
        motionId = 40010
    elseif classes == CombatClasses.Devine then
        motionId = 50011
    elseif classes == CombatClasses.Moon then
        motionId = 60020
    elseif classes == CombatClasses.Temple then
        return 70010
    else
        motionId = 50011
    end
    return motionId
end

function CombatUtil.DOLocalMoveX(target, endValue, duration, callback)
    local pos = target:GetComponent(RectTransform).anchoredPosition
    tween:DoPosition(target, Vector2(pos.x, pos.y), Vector2(endValue, pos.y), duration, callback, "linear", 0)
end
function CombatUtil.DOLocalMoveX2(target, endValue, duration, callback)
    local pos = target:GetComponent(RectTransform).anchoredPosition
    tween:DoPosition(target, Vector2(pos.x, pos.y), Vector2(endValue, pos.y), duration, callback, "linear", 2)
end
function CombatUtil.DOLocalMoveY(target, endValue, duration, callback)
    local pos = target:GetComponent(RectTransform).anchoredPosition
    tween:DoPosition(target, Vector2(pos.x, pos.y), Vector2(pos.x, endValue), duration, callback, "linear", 0)
end

function CombatUtil.pcall(call)
    local status, err = pcall(call)
    if not status then
        error("出错了：" .. tostring(err))
    end
end

function CombatUtil.FaceTo(target, point)
    local x = target.transform.position.x - point.x
    local z = target.transform.position.z - point.z
    local angle = math.atan2(x, z) * 180 / math.pi
    target.transform.rotation = Quaternion.identity
    target.transform:Rotate(Vector3(0, angle, 0))
end

function CombatUtil.EastPoint()
    return DataCombatUtil.data_right_pos
end
function CombatUtil.WestPoint()
    return DataCombatUtil.data_left_pos
end

function CombatUtil.SortBuffPlayData(elem1, elem2)
    if elem1.action_type > elem2.action_type then
        return true
    else
        return false
    end
end

function CombatUtil.BindMounter(tpose, effect, mounterName)
    local mounterPath = BaseUtils.GetChildPath(tpose.transform, mounterName)
    local mounter = tpose.transform:Find(mounterPath)
    if mounter ~= nil then
        effect.transform:SetParent(mounter)
    else
        effect.transform:SetParent(tpose.transform)
    end
    effect.transform.localPosition = Vector3.zero
    effect.transform.localRotation = Quaternion.identity
    effect.transform.localScale = Vector3(1, 1, 1)
    effect.transform.localPosition = Vector3(0, 0, 0)
end

function CombatUtil.DestroyChildActive(container, force)
    if BaseUtils.isnull(container) then
        return
    end
    local tcc = container.transform.childCount
    local list = {}
    for i = 1, tcc do
        local child = container.transform:GetChild(i - 1)
        if child.gameObject.activeSelf or force then
            table.insert(list, child)
        end
    end
    for _, data2 in ipairs(list) do
        GameObject.Destroy(data2.gameObject)
    end
end

function CombatUtil.GetFirstSkill(classes)
    local skilltable = {
        10001,
        20001,
        30001,
        40001,
        50001,
        69001,
        69501,
    }
    return skilltable[classes]
end

function CombatUtil.GetMapPath(combat_type)
    local mapid = SceneManager.Instance:CurrentMapId()
    local key1 = BaseUtils.Key(combat_type,mapid)
    local key2 = BaseUtils.Key(combat_type,"0")
    local path = "textures/combat/combatmap/1.unity3d"
    if DataCombatUtil.data_combat_map[key1] ~= nil then
        path = string.format("textures/combat/combatmap/%s.unity3d", tostring(DataCombatUtil.data_combat_map[key1].combat_mapid))
    elseif DataCombatUtil.data_combat_map[key2] ~= nil then
        path = string.format("textures/combat/combatmap/%s.unity3d", tostring(DataCombatUtil.data_combat_map[key2].combat_mapid))
    end
    return SubpackageManager.Instance.combatmapSetting:Resources(path)
end

CombatUtil.ShowFailedType = {
    [1] = 1
    ,[2] = 1
    ,[3] = 1
    ,[4] = 1
    ,[5] = 1
    ,[8] = 1
    ,[10] = 1
    ,[11] = 1
    ,[13] = 1
    ,[14] = 1
    ,[15] = 1
    ,[16] = 1
    ,[18] = 1
    ,[19] = 1
    ,[20] = 1
    ,[21] = 1
    ,[22] = 1
    ,[68] = 1
    ,[72] = 1
}

function CombatUtil.TryParseHtmlString(HexColor)
    local Hr = "0x"..string.sub(HexColor, 2,3)
    local Hg = "0x"..string.sub(HexColor, 4,5)
    local Hb = "0x"..string.sub(HexColor, 6,7)
    local Dr = string.format("%d",Hr)
    local Dg = string.format("%d",Hg)
    local Db = string.format("%d",Hb)
    return Dr, Dg, Db
end

function CombatUtil.GetResID(rType, fighter)
    local npcData = CombatManager.Instance:GetNpcBaseData(fighter.base_id)
    if npcData ~= nil and npcData.res_type == 5 then
        fighter.type = FighterType.Role
    end
    if rType == "Model" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_dress then
                return BaseUtils.ConvertInvalidDressModel(fighter.classes, fighter.sex, v.looks_val)
            end
        end
        local looksVal = BaseUtils.default_dress(fighter.classes, fighter.sex);
        return looksVal
    elseif rType == "Skin" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_dress then
                return BaseUtils.ConvertInvalidDressSkin(fighter.classes, fighter.sex, v.looks_mode)
            end
        end
        local looksVal = BaseUtils.default_dress_skin(fighter.classes, fighter.sex);
        return looksVal
    elseif rType == "Weapon" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_weapon then
                return look.looks_val
            end
        end
        local looksVal = BaseUtils.default_weapon(fighter.classes, fighter.sex);
        return looksVal
    elseif rType == "Ctrl" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        return string.format(CombatUtil.playerCtrlPath, (fighter.sex == 0 and "female" or "male"))
    elseif rType == "WingSkin" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_wing then
                local wingdata = DataWing.data_base[look.looks_val]
                local skinPath = wingdata.map_id
                return skinPath
            end
        end
    elseif rType == "WingModel" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_wing then
                local wingdata = DataWing.data_base[look.looks_val]
                local modelPath = wingdata.model_id
                return modelPath
            end
        end
    elseif rType == "WingCtrl" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_wing then
                local wingdata = DataWing.data_base[look.looks_val]
                local animationData = DataAnimation.data_wing_data[wingdata.act_id]
                local ctrlPath = string.format("prefabs/wing/animation/%s.unity3d", animationData.controller_id)
                return ctrlPath
            end
        end
    elseif rType == "WeaponEffect" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_weapon then
                if look.looks_mode ~= 0 then
                    local effectData = DataEffect.data_effect[look.looks_mode]
                    if effectData == nil then
                        print(string.format("<color='#00ff00'>effect_data 这个武器特效id数据没有啊 %s</color>", look.looks_mode))
                    else
                        return string.format(AssetConfig.effect, effectData.res_id)
                    end
                end
            end
        end
    elseif rType == "BeltModel" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.lookstype_belt then
                local belData = DataFashion.data_base[v.looks_val]
                if belData == nil then
                    print(string.format("<color='#00ff00'>fashion_data 这个时装id数据没有啊 %s</color>", v.looks_val))
                else
                    return belData.model_id
                end
            end
        end
    elseif rType == "HeadSurbaseModel" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.lookstype_headsurbase then
                local headSurbaseData = DataFashion.data_base[v.looks_val]
                if headSurbaseData == nil then
                    print(string.format("<color='#00ff00'>fashion_data 这个时装id数据没有啊 %s</color>", v.looks_val))
                else
                    return headSurbaseData.model_id
                end
            end
        end
    elseif rType == "BeltEffect" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.lookstype_belt then
                if look.looks_mode ~= 0 then
                    local effectData = DataEffect.data_effect[look.looks_mode]
                    if effectData == nil then
                        print(string.format("<color='#00ff00'>effect_data 这个武器特效id数据没有啊 %s</color>", look.looks_mode))
                    else
                        return string.format(AssetConfig.effect, effectData.res_id)
                    end
                end
            end
        end
    elseif rType == "HeadSurbaseEffect" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.lookstype_headsurbase then
                if look.looks_mode ~= 0 then
                    local effectData = DataEffect.data_effect[look.looks_mode]
                    if effectData == nil then
                        print(string.format("<color='#00ff00'>effect_data 这个特效id数据没有啊 %s</color>", look.looks_mode))
                    else
                        self.effectPath = string.format(AssetConfig.effect, effectData.res_id)
                        self.effectData = effectData
                    end
                end
            end
        end
    -- Head
    elseif rType == "HeadModel" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_hair then
                return BaseUtils.ConvertInvalidHeadModel(fighter.classes, fighter.sex, v.looks_val)
            end
        end
        local looksVal = BaseUtils.default_head(fighter.classes, fighter.sex);
        return string.format(CombatUtil.headModelPath, looksVal)
    elseif rType == "HeadSkin" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_hair then
                return BaseUtils.ConvertInvalidHeadSkin(fighter.classes, fighter.sex, v.looks_mode)
            end
        end
        local looksVal = BaseUtils.default_head_skin(fighter.classes, fighter.sex);
        return string.format(CombatUtil.headSkinPath, looksVal)
    elseif rType == "HeadCtrl" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        return string.format(CombatUtil.headctrlpath, (fighter.sex == 0 and "female" or "male"))
    -- Npc
    elseif rType == "Model" and fighter.type == FighterType.Unit then
        local npcData = CombatManager.Instance:GetNpcBaseData(fighter.base_id)
        if npcData == nil then
            Log.Error("[战斗]缺少单位基础信息():[NpcBaseId:" .. fighter.base_id .. "]")
        end
        return npcData.res
    elseif rType == "Ctrl" and fighter.type == FighterType.Unit then
        local npcData = CombatManager.Instance:GetNpcBaseData(fighter.base_id)
        -- local animationData = data_animation.data_npc_data[npcData.animation_id]
        local animationData = CombatManager.Instance:GetAnimationData(npcData.animation_id)
        if animationData == nil then
            Log.Error("[战斗]缺少动作基础信息(animation_data):[AnimationId:" .. npcData.animation_id .. "][NpcBaseId:" .. fighter.base_id .. "]")
        end
        if animationData.controller_id == 99999 then
            return string.format(CombatUtil.playerCtrlPath, (fighter.sex == 0 and "female" or "male"))
        else
            return string.format(CombatUtil.npcAnimationPath, animationData.controller_id)
        end
    elseif rType == "Skin" and fighter.type == FighterType.Unit then
        local npcData = CombatManager.Instance:GetNpcBaseData(fighter.base_id)
        return npcData.skin

    -- Pet
    elseif rType == "Model" and fighter.type == FighterType.Pet then
        local petData = CombatManager.Instance:GetPetBaseData(fighter.base_id)
        local modelId = petData.model_id
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looks_type_unreal_skin and v.looks_mode ~= 0 then -- 先处理幻化
                return v.looks_mode
            end
        end

        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_skin and v.looks_mode ~= 0 then -- 再处理皮肤
                return v.looks_mode
            end
        end
        return string.format(CombatUtil.npcModelPath, modelId)
    elseif rType == "Ctrl" and fighter.type == FighterType.Pet then
        local petData = CombatManager.Instance:GetPetBaseData(fighter.base_id)
        -- local animationData = data_animation.data_npc_data[petData.animation_id]
        local animationData = CombatManager.Instance:GetAnimationData(petData.animation_id)
        return animationData.controller_id
    elseif rType == "Skin" and fighter.type == FighterType.Pet then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looks_type_unreal_skin then -- 先处理幻化
                return string.format(CombatUtil.npcSkinPath, v.looks_val)
            end
        end

        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_skin then -- 再处理皮肤
                return string.format(CombatUtil.npcSkinPath, v.looks_val)
            end
        end
        local petData = CombatManager.Instance:GetPetBaseData(fighter.base_id)
        return petData.skin_id_0
    elseif rType == "WeaponEffect" and (fighter.type == FighterType.Pet) then
        local petData = CombatManager.Instance:GetPetBaseData(fighter.base_id)
        if #petData.effects_0 ~= 0 then
            local resid = DataEffect.data_effect[petData.effects_0[1].effect_id].res_id
            local psth = string.format("prefabs/effect/%s.unity3d", tostring(resid))
            -- BaseUtils.dump(fighter.looks, "宠物外观！！！！！！！！！")
            return tostring(resid)
        end
    elseif rType == "Model" and fighter.type == FighterType.Guard then
        local guardData = CombatManager.Instance:GetGuardBaseData(fighter.base_id)
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == 70 then
                return v.looks_mode
            end
        end
        return guardData.res_id
    elseif rType == "Ctrl" and fighter.type == FighterType.Guard then
        local guardData = CombatManager.Instance:GetGuardBaseData(fighter.base_id)
        local animationData = CombatManager.Instance:GetAnimationData(guardData.animation_id)
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == 71 then
                animationData = self.combatMgr:GetAnimationData(v.looks_mode)
            end
        end
        if animationData == nil then
            Log.Error("[战斗]缺少动作基础信息(animation_data):[AnimationId:" .. npcData.animation_id .. "][NpcBaseId:" .. fighter.base_id .. "]")
        end
        if animationData.controller_id == 99999 then
            return string.format(CombatUtil.playerCtrlPath, (fighter.sex == 0 and "female" or "male"))
        else
            return string.format(CombatUtil.npcAnimationPath, animationData.controller_id)
        end
    elseif rType == "Skin" and fighter.type == FighterType.Guard then
        local guardData = CombatManager.Instance:GetGuardBaseData(fighter.base_id)
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == 70 then
                return v.looks_val
            end
        end
        return guardData.paste_id
    end
    return nil
end

function CombatUtil.IsHasEffect(go, effectData)
    -- local effectData = DataEffect.data_effect[effectid]
    if effectData == nil then
        return false
    end
    if effectData.mounter == EffectDataMounter.Custom then
        local mounter = BaseUtils.GetChildPath(go.transform, effectData.mounter_str)
        if mounter ~= "" then
            local m = go.transform:Find(mounter)
            if m ~= nil then
                for i=1,m.childCount do
                    if string.find(m:GetChild(i-1).gameObject.name, tostring(effectData.res_id)) ~= nil then
                        print(m:GetChild(i-1).gameObject.name)
                        return true
                    end
                end
            end
        end
    elseif effectData.mounter == EffectDataMounter.Origin then
        local m = go.transform
        if m ~= nil then
            for i=1,m.childCount do
                if string.find(m:GetChild(i-1).gameObject.name, tostring(effectData.res_id)) ~= nil then
                    return true
                end
            end
        end
    elseif effectData.mounter == EffectDataMounter.TopOrigin then
        local m = go.transform
        if m ~= nil then
            for i=1,m.childCount do
                if string.find(m:GetChild(i-1).gameObject.name, tostring(effectData.res_id)) ~= nil then
                    return true
                end
            end
        end
    elseif effectData.mounter == EffectDataMounter.Weapon then
        local lmounter = BaseUtils.GetChildPath(go.transform, "Bip_L_Weapon")
        local rmounter = BaseUtils.GetChildPath(go.transform, "Bip_R_Weapon")
        if lmounter ~= "" or rmounter ~= "" then
            local clone = false
            if lmounter ~= "" then
                local lm = go.transform:Find(lmounter)
                if lm ~= nil then
                    for i=1,lm.childCount do
                        if string.find(lm:GetChild(i-1).gameObject.name, tostring(effectData.res_id)) ~= nil then
                            return true
                        end
                    end
                end
            end
            if rmounter ~= "" then
                local rm = go.transform:Find(rmounter)
                if rm ~= nil then
                    if rm ~= nil then
                        for i=1,rm.childCount do
                            if string.find(rm:GetChild(i-1).gameObject.name, tostring(effectData.res_id)) ~= nil then
                                return true
                            end
                        end
                    end
                end
            end
        end
    else
        local mounterPath = nil
        if effectData.mounter == EffectDataMounter.Wing then
            mounterPath = BaseUtils.GetChildPath(go.transform, "bp_wing")
        elseif effectData.mounter == EffectDataMounter.WingL1 then
            -- 看以后需求改
            mounterPath = BaseUtils.GetChildPath(go.transform, "bp_wing")
        else
            mounterPath = BaseUtils.GetChildPath(go.transform, "bp_wing")
        end
        if mounterPath ~= nil then
            local mounter = go.transform:Find(mounterPath)
            if mounter ~= nil then
                if mounter ~= nil then
                    for i=1,mounter.childCount do
                        if string.find(mounter:GetChild(i-1).gameObject.name, tostring(effectData.res_id)) ~= nil then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

function CombatUtil.IsShowWing(combat_type)
    return CombatUtil.NotShowWingType[combat_type] == nil
end

function CombatUtil.CheckSubpackEffect(effectId, effectDict)
    local effectPath = "prefabs/effect/" .. effectId .. ".unity3d"
    if not SubpackageManager.Instance.IsSubPackage then
        return effectPath
    end
    if effectDict[effectPath] ~= nil then
        return effectDict[effectPath]
    end
    local changePath = SubpackageManager.Instance.effectSetting:Resources(effectId)
    if effectPath ~= changePath then
        effectDict[effectPath] = changePath
    end
    return changePath
end

function CombatUtil.GetSubpackEffect(effectId, effectDict)
    local effectPath = "prefabs/effect/" .. effectId .. ".unity3d"
    if effectDict[effectPath] ~= nil then
        return effectDict[effectPath]
    end
    return effectPath
end

function CombatUtil.GetOriginPos(formationId, lev, formationpos)
    local key = CombatUtil.Key(formationId, lev)
    local formationData = DataFormation.data_list[key]
    if formationData == nil then
        return formationpos
    end
    local list = formationData.pos_desc
    local newPos = formationpos
    for _, pdata in ipairs(list) do
        if pdata[2] == formationpos then
            -- if pdata[2] > 5 then
            --     newPos = pdata[2] + 5
            -- else
                newPos = pdata[1]
            -- end
            break
        end
    end
    return newPos
    -- end
end

CombatUtil.pointList = {
            [1] = {
                [1] = -0.072*0.8,
                [2] = 0,
                [3] = 0.034871191978455*0.8,
            },
            [2] = {
                [1] = -0.008*0.8,
                [2] = 0,
                [3] = 0.079598994255066*0.8,
            },
            [3] = {
                [1] = 0.0064*0.8,
                [2] = 0,
                [3] = 0.079743590354919*0.8,
            },
            [4] = {
                [1] = 0.0552*0.8,
                [2] = 0,
                [3] = 0.057904748916626*0.8,
            },
            [5] = {
                [1] = 0.0024*0.8,
                [2] = 0,
                [3] = 0.079963994026184*0.8,
            },
            [6] = {
                [1] = -0.0624*0.8,
                [2] = 0,
                [3] = 0.05006236076355*0.8,
            },
            [7] = {
                [1] = -0.0344*0.8,
                [2] = 0,
                [3] = 0.072226309776306*0.8,
            },
            [8] = {
                [1] = 0.0136*0.8,
                [2] = 0,
                [3] = 0.078835525512695*0.8,
            },
            [9] = {
                [1] = 0.0024*0.8,
                [2] = 0,
                [3] = 0.079963994026184*0.8,
            },
            [10] = {
                [1] = 0.0736*0.8,
                [2] = 0,
                [3] = 0.031353468894958*0.8,
            },
            [11] = {
                [1] = -0.0688*0.8,
                [2] = 0,
                [3] = 0.040823521614075*0.8,
            },
            [12] = {
                [1] = -0.0576*0.8,
                [2] = 0,
                [3] = 0.055517926216125*0.8,
            },
        }

function CombatUtil.GetRandomPointList()
    -- if CombatUtil.pointList == nil then
        local temp = {}
        -- for i=1, 12 do
        --     local x = Random.Range(-100, 100)/100
        --     local zdir = Mathf.Pow(-1, Random.Range(0, 1))
        --     local z = Mathf.Sqrt(1 - x*x)*zdir
        --     table.insert(temp, Vector3(x, 0, z)*0.08)
        -- end
        -- CombatUtil.pointList = temp
        -- temp =
        return CombatUtil.pointList
    -- end
    -- return CombatUtil.pointList
end