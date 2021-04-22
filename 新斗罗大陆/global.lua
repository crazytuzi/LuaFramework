
--[[
全局定义的一些参数
--]]

global = {
    language = "chinese_simplified", -- localization
    title = "斗罗大陆", -- global title

    -- 字体
    font_monaco = "font/Monaco.ttf",
    font_zhcn = "font/FZZhunYuan-M02S.ttf",
    -- font_name = "default",
    font_name = "font/FZZhunYuan-M02S.ttf",

    -- 系统相关的参数
    system_reset_hour = 4, -- 每天凌晨4点重置所有的计数器，比如关卡能打的次数等

    ui_none_image = "ui/none.png", -- 1x1全透明的图片
    -- Drag Line
    ui_drag_line_white = "ui/white_line.png", -- 比较细的线
    ui_drag_line_green = "ui/green_line.png",  -- 比较粗的线
    ui_drag_line_yellow = "ui/yellow_line.png",  -- 比较粗的线
    ui_drag_line_white_circle1 = "ui/white_circle1.png", -- 线两端的圆
    ui_drag_line_white_circle2 = "ui/white_circle2.png",
    ui_drag_line_green_circle1 = "ui/green_circle1.png",
    ui_drag_line_green_circle2 = "ui/green_circle2.png",
    ui_drag_line_yellow_circle1 = "ui/yellow_circle1.png",
    ui_drag_line_yellow_circle2 = "ui/yellow_circle2.png",
  	ui_drag_line_circle = "ui/ball01.png", -- 线两端的圆
    
    -- Track Line
    ui_one_track_line = "effect/one_track_mind.png",  -- 一根经追踪线

    -- actor
    ui_actor_select_target = "ui/yellow_circle2.png",
    ui_actor_select_target_health = "ui/white_circle2.png",
    -- NPC
    ui_npc_circle = "ui/red_circle1.png",

    -- 界面相关的资源
    ui_hp_background_hero = "ui/hp_bg.png", -- 魂师的血条背景
    ui_hp_foreground_hero = "ui/hp_green.png", -- 魂师的血条
    ui_hp_background_npc = "ui/hp_bg.png", -- NPC的血条背景
    ui_hp_foreground_npc = "ui/hp_yellow.png", -- NPC的血条
    ui_hp_background_tmp = "ui/hp_red.png", -- 血条的临时背景，用于减血动画
    ui_hp_absorb = "ui/hp_white.png",
    ui_hp_limit = "ui/hp_limitred.png",

    ui_skill_icon_placeholder = "ui/lock.png", -- 未开放的技能图标
    ui_skill_icon_effect_cding = "cding",  --技能图标正在CD的特效
    ui_skill_icon_effect_cdok = "cdok",  --技能图标CD完成的特效，后续自动接standby
    ui_skill_icon_effect_standby = "standby",  --技能图标可以点击的特效
    ui_skill_icon_effect_release = "release",  --技能图标释放的特效

    ui_hp_hide_delay_time = 8, -- 血条如果 x 秒内无变化则自行消失
    ui_hp_hide_fadeout_time = 0.4, -- 血条消失的时候淡出耗时

    ui_skill_icon_disabled_overlay = ccc3(144, 144, 144), -- 魂师技能图标CD状态中时所显示的颜色加成
    ui_skill_icon_enabled_overlay = ccc3(255, 255, 255), -- 魂师技能图标CD冷却状态中时所显示的颜色加成
    ui_head_icon_disabled_overlay = ccc3(63, 63, 63), -- 头像图标CD状态中时所显示的颜色加成

    ui_hp_change_font_damage_npc = "font/YellowNumber.fnt",
    ui_hp_change_font_damage_hero = "font/RedNumber.fnt",   -- HP改变时的颜色：伤害
    ui_hp_change_font_treat = "font/GreenNumber.fnt",  -- HP改变时的颜色：治疗

    ui_dragline_color_no_target = ccc3(0, 235, 0),      -- 拖拽线目的地没有找到对象
    ui_dragline_color_on_enemy = ccc3(235, 235, 30),    -- 拖拽线指向敌人
    ui_dragline_color_on_teammate = ccc3(235, 235, 235),-- 拖拽线指向同伴

    ui_arena_start_aniamtion_ccbi = "ccb/Battle_SceneNumber.ccbi", -- 斗魂场开始动画
    ui_battle_boss_animation_ccbi = "ccb/Battle_Widget_BossCome.ccbi", -- Boss出现的动画
    alliance_arena_flag_effect = "flag_alliance", -- 联盟旗
    horde_arena_flag_effect = "flag_horde", -- 部落旗
    attack_mark_effect = "hunter_mark", -- 集火特效
    attack_mark_sound_effect = "FootmanYesAttack2", -- 集火音效

    loading_actor_file = "orc_warlord",
    loading_sheep_file = "sheep",
    loading_actor_animation_name = "walk01",
    loading_sheep_animation_name = "walk02",

    hero_add_effect = "consecration_5_1", -- 新增魂师特效

    image_frame_wave_1 = "wave1.png",
    image_frame_wave_2 = "wave2.png",
    image_frame_wave_3 = "wave3.png",

    hero_enter_time = 3.5 - 1.0, -- 魂师进场时间，魂师需要在该时间内进场，NPC在这个时间后开始启动
    wave_animation_time = 2.5 - 1.0, -- 每一波开始前动画的时间
    boss_animation_time = 3.0, -- boss出现动画的时间

    movement_speed_min = 12, -- 移动速度的最小值

    -- 屏幕大区划分成3x5的区域
    screen_big_grid_width = 6,
    screen_big_grid_height = 4,

    -- 自定义的每个单位的像素数量
    pixel_per_unit = 64,
    ranged_attack_distance = 20, -- 如果攻击距离超过20个单位，则认为是远程攻击

    -- 屏幕上方和下方不可用区域，单位为屏幕操作单元格 18 x 10，单个格子的大小为pixel_per_unit
    screen_margin_top = 3.0,
    screen_margin_bottom = 2.5,
    screen_margin_left = 0.5,
    screen_margin_right = 0.5,

    -- 最大仇恨可追溯时间范围(秒)
    hatred_period = 4, 

    npc_view_dead_delay = 1.6,
    npc_view_dead_blink_time = 1.0,
    remove_npc_delay_time = 2.7,
    pvp_hero_move_time = 2.2,

    victory_animation_duration = 3,

    sao_dang_quan_id = 7,

    additions = {
        -- 增益和减益效果
        attack_value = 0, -- 攻击_数值 √
        attack_percent = 0, -- 攻击_百分比（%）√
        hp_value = 0, -- 生命值_数值 √
        hp_percent = 0, -- 生命值_百分比（%）√
        armor_physical = 0, -- 物理抗性（%）√
        armor_magic = 0, -- 法术抗性（%）√
        hit_rating = 0, -- 命中等级 √
        hit_chance = 0, -- 命中率（%）√
        dodge_rating = 0, -- 闪避等级 √
        dodge_chance = 0, -- 闪避率（%）√  
        block_rating = 0, -- 格挡等级 √
        block_chance = 0, -- 格挡率（%）√
        critical_rating = 0, -- 暴击等级 √  
        critical_chance = 0, -- 暴击率（%）√
        critical_damage = 0, -- 暴击伤害（%）√
        cri_reduce_rating = 0, -- 抗暴等级
        cri_reduce_chance = 0, -- 抗暴几率 (%)
        movespeed_value = 0, -- 移动速度_数值 √
        movespeed_percent = 0, -- 移动速度_百分比 √ 
        haste_rating = 0, -- 攻速等级 
        attackspeed_chance = 0, -- 攻击速度百分比 
        physical_damage_percent_attack = 0, -- 物理伤害（%）√
        physical_damage_percent_beattack = 0, -- 物理易伤（%）√
        physical_damage_percent_beattack_reduce = 0, -- 物理伤害减免（%）√
        magic_damage_percent_attack = 0, -- 法术伤害（%）√
        magic_damage_percent_beattack = 0, -- 法术易伤（%）√
        magic_damage_percent_beattack_reduce = 0, -- 法术伤害减免（%）√
        magic_treat_percent_attack = 0, -- 治疗效果（%）√
        magic_treat_percent_beattack = 0, -- 被治疗效果（%）√
        pvp_physical_damage_percent_beattack_reduce = 0, -- pvp物理伤害减免
        pvp_magic_damage_percent_beattack_reduce = 0, -- pvp魔法伤害减免
        pvp_physical_damage_percent_attack = 0, -- pvp物理伤害加成
        pvp_magic_damage_percent_attack = 0, -- pvp魔法伤害加成
        aoe_attack_percent = 0, -- aoe造成伤害加成
        aoe_beattack_percent = 0, -- aoe受到伤害加成
    },

    config = {
        energy_refresh_interval = 360,
        max_energy = 150,
        skill_refresh_interval = 300,
        max_skill = 10,
        max_battle_count = 3,

        dungeon_type_normal = 1,
        dungeon_type_advanced = 2,
        dungeon_difficult_easy = 1,
        dungeon_difficult_normal = 2,
        dungeon_difficult_hard = 3,

        award_type_money = 1,
        award_type_token_money = 2,
        award_type_team_exp = 3,
        award_type_exp = 4,
        award_type_item = 5,
        award_type_hero = 6,
    },

    --各种刷新时间合集
    freshTime = {
        map_freshTime = 5, --关卡次数的刷新时间
        buyEnergy_freshTime = 5, --购买体力的刷新时间
        buyMoney_freshTime = 5, --购买金钱的刷新时间
        silver_freshTime = 5, --银宝箱的刷新时间
        task_freshTime = 5, --银宝箱的刷新时间
        sginin_freshTime = 5, --签到的刷新时间
        sunwell_freshTime = 5, --太阳井的刷新时间
        fortress_freshTime = 5, --要塞每日任务刷新时间
    },

    -- 每天固定刷新时间
    regular_refreshTime = 5,

    -- 装备最大强化等级
    equipment_max_level = 180,

    -- 饰品最大强化等级
    jewelry_max_level = 180,

    --解锁战队涉及关卡
    unlock_dungeon = {
        "wailing_caverns_8", --技能解锁
    },

    cutscenes = {
        KRESH_ENTRANCE = "KRESH_ENTRANCE",
    },

    -- 近战攻击在y轴上的最大攻击间隔
    melee_distance_y = 6,
    melee_distance_y_for_skill = 100.8^2, -- (global.melee_distance_y + 1) * 24 * 0.6)^2

    arena_warning = "魂师大人，当前不能操作战斗哦~",
    gloryarena_warning = "魂师大人，当前不能操作战斗哦~",
    glory_warning = "魂师大人，当前不能操作战斗哦~",
    silvermine_warning = "魂师大人，当前不能操作战斗哦~",
    stormarena_warning = "魂师大人，当前不能操作战斗哦~",
    plunder_warning = "魂师大人，当前不能操作战斗哦~",
    sunwell_warning = "魂师大人，当前不能操作战斗哦~",
    replay_warning = "魂师大人，当前不能操作战斗哦~",
    battle_force_explain = "战力最高的%d名魂师的战力总和为当前上阵总战力",
    maritime_warning = "魂师大人，当前不能操作战斗哦~",
    control_is_not_allowed_warning = "魂师大人，当前不能操作战斗哦~",

    immune_physical = "物理免疫",
    immune_magic = "法术免疫",

    already_subscribed_tip = "月卡已购买，请去精彩活动界面领取。",

    -- 滑动造成放慢的时间阈值
    time_gear_threshold = 0.1, -- 划线拖动0.1秒后才开始time gear

    music_volume = 0.60,  --背景音乐大小
    sound_volume = 1,  --背景音乐大小
}

global.font_default = global.font_zhcn

global.dragon_spine_scale = 1.4
global.dragon_spine_offsetY = -240
global.infinite_boss_effect = "zmwh_boss_tongyong_huixue" -- 无限血量boss回复满血特效

if not IsServerSide then
    local sharedApplication = CCApplication:sharedApplication()
    local target = sharedApplication:getTargetPlatform()
    if target == kTargetAndroid then
        global.font_monaco = "font/Monaco.ttf"
        global.font_zhcn = "font/FZZhunYuan-M02S.ttf"
        global.font_default = global.font_zhcn
    end
end




-- battle resolution
BATTLE_SCREEN_WIDTH  = 1280
BATTLE_SCREEN_HEIGHT = 720

BATTLE_SCENE_WIDTH = BATTLE_SCREEN_WIDTH
BATTLE_SCENE_HEIGHT = BATTLE_SCREEN_HEIGHT

BATTLE_AREA = {
    left = global.screen_margin_left * global.pixel_per_unit,
    bottom = global.screen_margin_bottom * global.pixel_per_unit,
    width = BATTLE_SCREEN_WIDTH - (global.screen_margin_right + global.screen_margin_left) * global.pixel_per_unit,
    height = BATTLE_SCREEN_HEIGHT - global.screen_margin_top * global.pixel_per_unit - global.screen_margin_bottom * global.pixel_per_unit,
}

BATTLE_AREA.right = BATTLE_AREA.left + BATTLE_AREA.width
BATTLE_AREA.top = BATTLE_AREA.bottom + BATTLE_AREA.height

EPSILON = 0.1
HIT_DELAY = 0.3
HIT_DELAY_FRAME = 10.0
SPINE_RUNTIME_FRAME = 30.0

-- 人物类型
ACTOR_TYPES = {
    HERO = "ACTOR_TYPE_HERO",
    HERO_NPC = "ACTOR_TYPE_HERO_NPC",
    NPC = "ACTOR_TYPE_NPC", 
}

--item分类
--[[
    1为突破材料
    2为装备 
    3为魂师碎片 
    4为消耗品
    5为卖钱消耗品
    6为礼包
]] 
ITEM_CONFIG_TYPE = {
    MATERIAL = 1, -- 装备碎片
    EQUIPMENT = 2, -- 装备
    SOUL = 3, -- 魂力精魄
    CONSUM = 4, -- 消耗品
    CONSUM_MONEY = 5, -- 卖钱的消耗品
    CONSUM_PACKAGE = 6, -- 礼包
    CONSUM_CHOOSE_PACKAGE = 11, -- 多选1礼包类型
    GEMSTONE = 17, -- 宝石
    GEMSTONE_PIECE = 18, -- 宝石碎片
    GEMSTONE_MATERIAL = 19, -- 宝石材料
    GEMSTONE_PACKAGE = 20, -- 宝石宝箱
    ZUOQI = 21, -- 坐骑碎片
    MOUNT_MATERIAL = 22, -- 坐骑喜好品
    MOUNT_PACKAGE = 23, -- 坐骑礼包
    ARTIFACT = 25, -- 真身
    ARTIFACT_PIECE = 31, -- 真身精华
    ARTIFACT_MATERIAL = 32, -- 真身消耗品
    ARTIFACT_PACKAGE = 28, -- 真身礼包
    GARNET = 1001, -- 榴石
    OBSIDIAN = 1002, -- 曜石
    SPAR_PIECE = 101, -- 晶石碎片
    SKIN_ITEM = 40, -- 皮肤道具
    MAGICHERB = 41, -- 仙品
    MAGICHERB_WILD = 42, -- 破碎仙品
    SOULSPIRIT_PIECE = 43, -- 魂灵碎片
    SOULSPIRIT_CONSUM = 44, -- 魂灵消耗品
    SUPER_HERO_EXP = 46, -- SS魂师经验
    GODARM_PIECE = 45,  --神器碎片
    RECHARGE_YUEKA = 47,  --月卡道具
    RECHARGE_All = 48,  --單充、累充道具
    RECHARGE_LEICHONG = 49,  --累充道具
    SOULSPIRITOCCULT_PIECE = 50, --魂灵秘术道具
    SOULSPIRITINHERIT_PIECE = 51, --魂灵传承碎片道具
    FOODS = 52, --下午茶食品与食材


}

QDEF = {
    -- readable return value
    HANDLED = "HANDLED",

    -- ui constants
    SCALE_CLICK = 1.05,

    -- events
    EVENT_CD_CHANGED = "EVENT_CD_CHANGED",
    EVENT_CD_STARTED = "EVENT_CD_STARTED",
    EVENT_CD_STOPPED = "EVENT_CD_STOPPED",
}

--装备类型
EQUIPMENT_TYPE = {
    WEAPON = "weapon",
    BRACELET = "bracelet",
    CLOTHES = "clothes",
    SHOES = "shoes",
    JEWELRY1 = "jewelry1",
    JEWELRY2 = "jewelry2",
}

ANIMATION = {
    WALK = "walk",
    REVERSEWALK = "reverse-walk",
    STAND = "stand",
    ATTACK = "attack",
    HIT = "hit",
    SELECTED = "selected",
    DEAD = "dead",
    VICTORY = "victory",
}

--副本类型
DUNGEON_TYPE = {
    NORMAL = 1,
    ELITE = 2,
    WELFARE = 5,
    GROTTO = 6,
    ACTIVITY_TIME = 3,
    ACTIVITY_CHALLENGE = 4,
    NIGHTMARE = 7, --噩梦副本
    METALCITY = 8, --金属之城副本
    ALL = 999,
}

BATTLE_MODE = {
    CONTINUOUS = 1,
    SEVERAL_WAVES = 2,
    WAVE_WITH_DIFFERENT_BACKGROUND = 3
}

APTITUDE = {
    SSS = 99,    --SSS
    SSR = 24,    --SS+
    SS  = 22,    --S+
    S   = 20,
    AA  = 18,    --A+
    A   = 15,
    B   = 12,
    C   = 10,
}

--[[
魂师入场起始点:
位置示意图:
        3
       / \
      4   1
       \ /     
        2  
坐标系:
        ↑y
        |
    ---------→ x
        |
        |
格式:
{{x, y}, {x, y}, {x, y}, {x, y}}
x和Y是指离屏幕中心的偏移
--]] 

HERO_POS = {{-80, 0}, {-194, -120}, {-268, 120}, {-412, 0}}
ARENA_HERO_POS = {{-80, 0}, {-194, -120}, {-268, 120}, {-412, 0}}

SUPPORT_SKILL_ONLY_ONCE = true
-- pvp control
ENABLE_AREAN_CONTROL = false
ENABLE_GLORY_CONTROL = true
ENABLE_FIGHT_CLUB_CONTROL = false
-- 是否允许多个同时冲锋
ALLOW_MULTIPLE_CHARGE = false
-- 符文是否有抛物线
RUNE_THROW = true

BATTLE_RECORD_DT_STEP_NUMBER = 16
BATTLE_RECORD_DT_PACK_BITS = 4

START_PORT = 9520
MAX_PORT_NUMBER = 8
GEMSTONE_MAXADVANCED_LEVEL = 25                     --  魂骨进阶最大等级

-- 替补英雄的入场位置
global.candidate_heroes_enter_pos = {{x = 32 + 152 * 5, y = 92 + 160}, {x = 32 + 152 * 4, y = 92 + 160}, {x = 32 + 152 * 2, y = 92 * 3 + 160}}
global.candidate_enemies_enter_pos = {{x = 32 + 152 * 3, y = 92 * 3 + 160}, {x = 32 + 152 * 4, y = 92 * 3 + 160}, {x = 32 + 152 * 6, y = 92 + 160}}
global.candidate_actor_initial_rage = {750, 900, 1000}