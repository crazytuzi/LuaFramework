-- 场景常量数据

SceneConstData = SceneConstData or BaseClass()

SceneConstData.unittype_role = 0 -- 玩家
SceneConstData.unittype_npc = 1 -- 普通NPC
SceneConstData.unittype_monster = 2 -- 普通怪物
SceneConstData.unittype_boss = 3 -- BOSS
SceneConstData.unittype_dramaunit = 4 -- 剧情单位
SceneConstData.unittype_taskcollection = 5 -- 任务采集
SceneConstData.unittype_worldboss = 6 -- 世界boss
SceneConstData.unittype_pet = 7 -- 自己的宠物，不能配置，在此仅做占位
SceneConstData.unittype_escortbox = 8 -- 护送宝箱
SceneConstData.unittype_guildthief = 9 -- 公会盗贼
SceneConstData.unittype_clone_role = 11 -- 克隆玩家
SceneConstData.unittype_chest_box = 12 --冒险宝箱
SceneConstData.unittype_guild_chest_box = 14 --公会宝箱
SceneConstData.unittype_normal = 100 -- 普通单位
SceneConstData.unittype_teleporter = 101 -- 传送阵
SceneConstData.unittype_collection = 102 -- 公共采集元素
SceneConstData.unittype_sceneeffect = 103 -- 场景特效
SceneConstData.unittype_trialeffect = 104 -- 关卡特效
SceneConstData.unittype_pick  = 105 --采集元素(点击后采集)，删除
SceneConstData.unittype_taskcollection_effect = 106 -- 特效任务采集
SceneConstData.unittype_fun_teleporter = 107 -- 功能传送阵
SceneConstData.unittype_pumpkingoblin = 108 -- 万圣节南瓜精
SceneConstData.unittype_exquisite_shelf = 109 -- 珍宝阁传送阵
SceneConstData.unittype_guild_dragon = 110 -- 公会魔龙

SceneConstData.fun_type_normal = 1              -- 普通
SceneConstData.fun_type_quest_classes = 2       -- 职业任务单位
SceneConstData.fun_type_quest_offer = 3         -- 悬赏任务单位
SceneConstData.fun_type_quest_prac = 4          -- 历练任务单位
SceneConstData.fun_type_trial_unit = 5          -- 试炼单位
SceneConstData.fun_type_trial_box = 6           -- 试炼单位-宝箱
SceneConstData.fun_type_team_roll = 7           -- 组队roll点宝箱
SceneConstData.fun_type_quest_treasure = 8      -- 宝图怪
SceneConstData.fun_type_robber_treasure = 9     -- 公会盗贼宝图怪
SceneConstData.fun_type_dungeon = 10            -- 副本
SceneConstData.fun_type_tower = 11              -- 天空之塔
SceneConstData.fun_type_skill_prac_box = 12     -- 冒险宝箱
SceneConstData.fun_type_treasure_ghost = 13     -- 封妖
SceneConstData.fun_type_robber_box_switch = 14  -- 公会盗贼宝箱开关怪
SceneConstData.fun_type_classes_challenge = 15  -- 职业挑战怪
SceneConstData.fun_type_fairyland_enemy = 16    -- 幻境寻宝敌对怪
SceneConstData.fun_type_fairyland_box = 17      -- 幻境寻宝宝箱
SceneConstData.fun_type_guild_plant_flower = 20      -- 公会种花
SceneConstData.fun_type_constellation = 23      -- 星座单位
SceneConstData.fun_type_top_compete = 25 --巅峰宝箱
SceneConstData.fun_type_ship_box = 35 --远航冒险宝箱
SceneConstData.fun_type_exit_home = 44 -- 退出家园
SceneConstData.fun_type_exit_home_enter_finca = 45 -- 退出家园进入庄园
SceneConstData.fun_type_exit_finca_enter_home = 46 -- 从庄园进入家园
SceneConstData.fun_type_home_flower = 47 -- 家园魔法豌豆
SceneConstData.fun_type_notname_treasure = 58 -- 鸿福宝箱
SceneConstData.fun_type_child_water = 62 -- 子女泉水
SceneConstData.send_word_latern = 72 -- 寄语灯笼
SceneConstData.fun_type_godswar_boss = 74 -- 诸神boss


-- 战场ID定义
SceneConstData.battle_id_plot = 0 --剧情单位
SceneConstData.battle_id_normal = 1 --世界地图单位
SceneConstData.battle_id_quest_classes = 2 --职业任务
SceneConstData.battle_id_world_boss = 3 --世界boss
SceneConstData.battle_id_trial = 4 --极寒试炼
SceneConstData.battle_id_parade = 5 --游行巡逻
SceneConstData.battle_id_guild_robber = 6 --公会强盗
SceneConstData.battle_id_prac_box = 7 --冒险宝箱
SceneConstData.battle_id_treasure_ghost = 8 --封妖
SceneConstData.battle_id_classes_challenge = 9 --职业挑战
SceneConstData.battle_id_fairyland = 10 --幻境寻宝
SceneConstData.battle_id_qualifying = 11 --段位赛
SceneConstData.battle_id_home_box = 333 --家园豌豆奖励宝箱

SceneConstData.unitstate_walk  = 0
SceneConstData.unitstate_fly  = 1
SceneConstData.unitstate_ride  = 2

SceneConstData.translatestyle_fall = 1
SceneConstData.translatestyle_jump = 2
SceneConstData.translatestyle_down = 3
SceneConstData.translatestyle_now = 4

SceneConstData.classes_gladiator = 1 --狂剑
SceneConstData.classes_mage = 2 --魔导
SceneConstData.classes_ranger = 3 --战弓
SceneConstData.classes_musketeer = 4 --兽灵
SceneConstData.classes_devine = 5 --秘言师
SceneConstData.classes_moon = 6 --月魂
SceneConstData.classes_sanctuary = 7 -- 圣骑

SceneConstData.looktype_none = 0
SceneConstData.looktype_weapon = 1
SceneConstData.looktype_hair = 2
SceneConstData.looktype_dress = 3
SceneConstData.lookstype_belt = 4 -- 时装腰饰
SceneConstData.lookstype_ring = 5 -- 时装婚戒
SceneConstData.lookstype_headsurbase = 6 -- 时装头饰
SceneConstData.lookstype_halo = 7 -- 脚底光环

SceneConstData.looktype_ride = 20 -- 坐骑
SceneConstData.looktype_ride_jewelry1 = 21 -- 坐骑饰品1
SceneConstData.looktype_ride_jewelry2 = 22 -- 坐骑饰品2
SceneConstData.looktype_wing = 50
SceneConstData.looktype_pet_skin = 51
SceneConstData.looktype_honor = 52
SceneConstData.looktype_transform = 53
SceneConstData.looktype_name_color = 54
SceneConstData.looktype_guild_name_color = 55
SceneConstData.looktype_tpose_alpha = 56
SceneConstData.looktype_effect = 57
SceneConstData.looktype_buff = 58
SceneConstData.looktype_camp = 59
SceneConstData.looktype_scale = 62
SceneConstData.looktype_hero_camp = 63
SceneConstData.looktype_camp_name = 64
SceneConstData.looks_type_elf = 65 -- 精灵外观
SceneConstData.looktype_role_frame = 66
SceneConstData.looktype_lev_break = 67  -- 等级突破
SceneConstData.looktype_camp_cake = 68 -- 护送蛋糕
SceneConstData.looktype_league_king = 69 -- 冠军联赛王牌
SceneConstData.looks_type_guard_skin = 70 -- 守护模型
SceneConstData.looks_type_guard_animation = 71 -- 守护动作
SceneConstData.looks_type_combat_order = 72 -- 初始站位
SceneConstData.looktype_child_id = 73 -- 子女id
SceneConstData.looktype_transform_buff = 74 -- 战斗中显示的变身Buff
SceneConstData.looktype_pet_trans = 75 -- 战斗中显示宠物幻化动作
SceneConstData.looktype_pre_honor = 76
SceneConstData.looktype_child_animation = 77 -- 孩子的动作
SceneConstData.looks_type_unreal_buff = 78 -- 宠物幻化buff显示
SceneConstData.looks_type_unreal_skin = 79 -- 宠物幻化皮肤
SceneConstData.looks_type_double_ride_passenger = 80 -- 双人坐骑司机
SceneConstData.looks_type_double_ride_driver = 81 -- 双人坐骑乘客

SceneConstData.looksdefiner_npcpath = "prefabs/npc/%s.unity3d"

SceneConstData.looksdefiner_npcskinpath = "textures/npc/skin/%s.unity3d"
SceneConstData.looksdefiner_npcmodelpath = "prefabs/npc/model/%s.unity3d"
SceneConstData.looksdefiner_npcctrlpath = "prefabs/npc/controller/%s.unity3d"

SceneConstData.looksdefiner_playerctrlpath = "prefabs/roles/animation/role.unity3d"

SceneConstData.looksdefiner_headctrlpath = "prefabs/roles/headanimation/%s.unity3d"

SceneConstData.looksdefiner_playerbodypath = "prefabs/roles/model/%s.unity3d"

SceneConstData.looksdefiner_playerheadpath = "prefabs/roles/head/%s.unity3d"

SceneConstData.looksdefiner_playerbody_skinpath = "prefabs/roles/skin/%s.unity3d"

SceneConstData.looksdefiner_playerhead_skinpath = "prefabs/roles/headskin/%s.unity3d"

SceneConstData.looksdefiner_playerweaponpath = "prefabs/roles/weapon/%s.unity3d"

SceneConstData.looksdefiner_beltpath = "prefabs/surbase/%s.unity3d"

SceneConstData.looksdefiner_headsurbasepath = "prefabs/surbase/%s.unity3d"

SceneConstData.looksdefiner_ridepath = "prefabs/ride/model/%s.unity3d"

SceneConstData.looksdefiner_rideSkinpath = "prefabs/ride/skin/%s.unity3d"

SceneConstData.looksdefiner_rideCtrpath = "prefabs/ride/animation/%s.unity3d"

SceneConstData.looksdefiner_effectpath = "prefabs/effects/%s.unity3d"

SceneConstData.looksdefiner_uilookseffectpath = "prefabs/ui/%s.unity3d"

SceneConstData.UnitAction = {
    None = 0,
    Stand = 1,
    Move = 2,
    BattleStand = 3,
    BattleMove = 4,
    Attack = 5,
    Hit = 6,
    Dead = 7,
    Idle = 9,
    MultiHit = 10,
    Upthrow = 11,
    Standup = 12,
    Defense = 13,
    Pick = 14,
    Jump = 15,
    Show = 16,
    FlyStand = 17,
    FlyMove = 18,
    JumpUp = 19,
    JumpMove = 20,
    JumpDown = 21,
    Sit = 22
}

SceneConstData.UnitActionStr = {
    [""] = 1,
    ["stand"] = 1,
    ["move"] = 2,
    ["battlestand"] = 3,
    ["battlemove"] = 4,
    ["attack"] = 5,
    ["hit"] = 6,
    ["dead"] = 7,
    ["idle"] = 9,
    ["multihit"] = 10,
    ["upthrow"] = 11,
    ["standup"] = 12,
    ["defense"] = 13,
    ["pick"] = 14,
    ["jump"] = 15,
    ["show"] = 16,
    ["flystand"] = 17,
    ["flymove"] = 18,
    ["jumpup"] = 19,
    ["jumpmove"] = 20,
    ["jumpdown"] = 21,
    ["sit"] = 21,
}

function SceneConstData.genanimationname(prefix, id)
    if id ~= nil and id > 0 then
        return string.format("%s%s", prefix, id)
    end

    return prefix
end

SceneConstData.UnitFaceTo = {
    Forward = 0,
    LeftForward = 45,
    Left = 90,
    LeftBackward = 135,
    Backward = 180,
    RightBackward = 225,
    Right = 270,
    RightForward = 315
}

SceneConstData.UnitFaceToIndex = { 0, 45, 90, 135, 180, 225, 270, 315 }

SceneConstData.MapCell = 1 -- 场景资源类型


SceneConstData.UnitNoFaceToPoint = {
    [1] = true,
    [62317] = true,
    [62318] = true,
    [76695] = true,
    [76696] = true,
    [76697] = true,
    [76698] = true,
    [83110] = true,
    [64340] = true,
    [20101] = true,
    [20102] = true,
    [75892] = true,
    [75893] = true,
    [75894] = true,
    [75895] = true,
}

SceneConstData.UnitNoShadow = {
    [20101] = true,
    [20102] = true,
}

SceneConstData.UnitExcludeOutofview = {
    [20101] = true,
    [20102] = true,
}

SceneConstData.MapSeason = {
    None = 1,
    Winter = 2,
}


SceneConstData.default_looks = {
    -- 男狂剑
    ["1_1"] = {
        [1] = {
            looks_str = "",
            looks_val = 50001,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51001,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10001,
            looks_type = 1,
            looks_mode = 0,
        },
    },

    -- 女狂剑
    ["1_0"] = {
        [1] = {
            looks_str = "",
            looks_val = 50002,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51002,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10001,
            looks_type = 1,
            looks_mode = 0,
        },
    },

    -- 男魔导
    ["2_1"] = {
        [1] = {
            looks_str = "",
            looks_val = 50003,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51003,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10101,
            looks_type = 1,
            looks_mode = 0,
        },
    },

    -- 女魔导
    ["2_0"] = {
        [1] = {
            looks_str = "",
            looks_val = 50004,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51004,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10101,
            looks_type = 1,
            looks_mode = 0,
        },
    },

    -- 男战弓
    ["3_1"] = {
        [1] = {
            looks_str = "",
            looks_val = 50005,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51005,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10201,
            looks_type = 1,
            looks_mode = 0,
        },
    },

    -- 女战弓
    ["3_0"] = {
        [1] = {
            looks_str = "",
            looks_val = 50006,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51006,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10201,
            looks_type = 1,
            looks_mode = 0,
        },
    },

    -- 男兽灵
    ["4_1"] = {
        [1] = {
            looks_str = "",
            looks_val = 50007,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51007,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10301,
            looks_type = 1,
            looks_mode = 0,
        },
    },

    -- 女兽灵
    ["4_0"] = {
        [1] = {
            looks_str = "",
            looks_val = 50008,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51008,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10301,
            looks_type = 1,
            looks_mode = 0,
        },
    },

    -- 男秘言
    ["5_1"] = {
        [1] = {
            looks_str = "",
            looks_val = 50009,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51009,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10401,
            looks_type = 1,
            looks_mode = 0,
        },
    },

    -- 女秘言
    ["5_0"] = {
        [1] = {
            looks_str = "",
            looks_val = 50010,
            looks_type = 2,
            looks_mode = 0,
        },
        [2] = {
            looks_str = "",
            looks_val = 51010,
            looks_type = 3,
            looks_mode = 0,
        },
        [3] = {
            looks_str = "",
            looks_val = 10401,
            looks_type = 1,
            looks_mode = 0,
        },
    },
}
