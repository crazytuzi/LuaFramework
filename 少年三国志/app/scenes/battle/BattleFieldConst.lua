-- BattleFieldConst

local ActionConst = {
    -- 角色出现
    CHAR_SHOW = "battle/action/action_char_show.json",
    -- 低级别角色出现,
    CHAR_SHOW_LOW = "battle/action/action_char_show_blue.json",
    -- 角色死亡
    CHAR_DIE = "battle/action/action_char_die.json",
    -- 角色技能出招
    CHAR_SKILLSTART = "battle/action/action_char_skillstart.json",
    -- 角色呼吸动画
    IDLE = "battle/action/action_idle_1.json",
    -- 角色移动
    RUN = "battle/action/action_run.json",
    -- 角色闪避
    DODGE = "battle/action/action_cont_shanbi_hit_1.json",
    DODGE_R = "battle/action/action_cont_shanbi_hit_1_r.json"
}

local SpConst = {
    -- 怒气动画
    ANGER = "sp_angerfull"
}

local BattleFieldConst = {}
BattleFieldConst.action = ActionConst
BattleFieldConst.sp = SpConst

-- 回合类型，1表示普通回合，2表示战宠回合
BattleFieldConst.ROUND_NORMAL   = 1
BattleFieldConst.ROUND_PET      = 2

-- 技能类型
BattleFieldConst.SKILL_KNIGHT_NORMAL    = 1 -- 武将普通攻击
BattleFieldConst.SKILL_KNIGHT_ACTIVE    = 2 -- 武将主动技能
BattleFieldConst.SKILL_KNIGHT_PASSIVE   = 3 -- 武将被动技能
BattleFieldConst.SKILL_KNIGHT_COMBO     = 4 -- 武将合击大招
BattleFieldConst.SKILL_PET_NORMAL       = 5 -- 战宠普通攻击
BattleFieldConst.SKILL_PET_ACTIVE       = 6 -- 战宠主动技能

return BattleFieldConst

