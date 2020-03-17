

_G.SKILL_TYPE = {
	ACTIVE = 1,--主动技能
	AOE = 2,--主动AOE
	PASSIVE = 3,--被动技能
}

--[[
技能操作类型
1=普通技能
2=蓄力技能
3=多段攻击技能
4=引导类技能
5=连续技
]]

--技能消耗类型
_G.SKILL_CONSUM_TYPE = {
	HP = 1,--生命
	MP = 2,--内力
	HPPER = 3,--生命百分比
	MPPER = 4,--内力百分比
	TILI = 5,--体力
	NUQI = 6,--怒气
	MAXHP = 7,--生命上限
	MAXMP = 8,--内力上限
    WUHUN = 9,--武魂豆
    KILLMONSTER = 10, --杀怪积分  --adder:houxudong date:2016/10/22 16:28:36
    TIANSHEN = 11, --天神
}

_G.SkipNoticeConfig = 
{
    --血的跳字间隔
    NormalTick = 100,
    --属性的跳字间隔
    AttrTick = 200,
    --血跳字的最大数量
    MaxNum = 100,
};

_G.DAMAGE = {
    NORMAL = 0,
    MISS = 1,           --闪避
    CRIT = 2,           --暴击
    BLOCKED = 4,        --格挡
    KILL = 8,           --击杀
    IMMUNITY = 16,      --免疫
    KNOCKBACK = 32,     --击退
    STIFF = 64,         --硬直
    RAMPAGE = 128,      --狂暴
    REBIRTH = 256,      --兽魄 焚噬苍穹
    IGNORE = 512,       --免疫伤害
    SUPER = 1024,       --卓越一击
    -- REALM = 2048,       --境界压制
    REFLEX = 4096,      --反弹伤害
    IGDEF = 8192,       --无视一击
    TIANSHEN = 65536,   --天神陷井
    LINGQI = 131072,    --法宝陷阱
}

_G.SKILL_OPER_TYPE = {
    DEF = 1,
    PREP = 2,
    MULTI = 3,
    CHAN = 4,
    COMBO = 5,
    COLLECT = 6,
    ROLL = 7,
    JUMP = 9,
    WUHUN = 10,
    MOVETRAP = 14,
    STATICTRAP = 15,
    TARGETPFX = 16,
    SHENBING = 17,
    LINGQI = 20,
	TIANSHEN = 21,
}

_G.SkillAction = {
    [SKILL_OPER_TYPE.DEF] = "PlayDefault",
    [SKILL_OPER_TYPE.PREP] = "PlayPrep",
    [SKILL_OPER_TYPE.MULTI] = "PlayMulti",
    [SKILL_OPER_TYPE.CHAN] = "PlayChan",
    [SKILL_OPER_TYPE.COMBO] = "PlayCombo",
    [SKILL_OPER_TYPE.COLLECT] = "PlayCollect",
    [SKILL_OPER_TYPE.ROLL] = "PlayRoll",
    [SKILL_OPER_TYPE.JUMP] = "PlayJump",
    [SKILL_OPER_TYPE.WUHUN] = "PlayWuhun",
    [SKILL_OPER_TYPE.MOVETRAP] = "PlayMoveTrap",
    [SKILL_OPER_TYPE.STATICTRAP] = "PlayStaticTrap",
    [SKILL_OPER_TYPE.TARGETPFX] = "PlayTragetPfx",
    [SKILL_OPER_TYPE.SHENBING] = "PlayShenbing",
    [SKILL_OPER_TYPE.LINGQI] = "PlayLingqi",
    [SKILL_OPER_TYPE.TIANSHEN] = "PlayTianshen",
}

--角色身上跳字的类型
_G.enBattleNoticeType = 
{
    HP_DWON = 1,
    HP_CRIT = 2,
    MISS = 3,
    DEFPARRY = 4,
    DODGE = 5,
    COMBO_DWON = 6,
    COMBO_CRIT = 7,
    HP_ADD = 8,
    MP_ADD = 9,
    ZUOQI_DWON = 10,
    ZUOQI_CRIT = 11,
    WUHUN_DWON = 12,
    WUHUN_CRIT = 13,
    SHENBING_DOWN = 14,
    SHENBING_CRIT = 15,
    SUPER = 16;
    JINGJIE_DOWN = 17, 
    JINGJIE_CRIT = 18,
    IGDEF = 19,
	TIANSHEN_DWON = 20,
	TIANSHEN_CRIT = 21,
    LINGQI_DOWN = 22,
    LINGQI_CRIT = 23,
}


_G.NOTICE = {
    ["self"] = {
        [enBattleNoticeType.HP_DWON] = {
            skipConfig =  1006,
            text = "down"
        },
        [enBattleNoticeType.HP_CRIT] = {
            skipConfig =  1007,
            text = "crit"
        },
        [enBattleNoticeType.MISS] = {
            skipConfig =  1008,
            text = "miss"
        },
        [enBattleNoticeType.DEFPARRY] = {
            skipConfig =  1009,
            text = "defparry"
        },
        [enBattleNoticeType.DODGE] = {
            skipConfig =  1010,
            text = "dodge"
        },
        [enBattleNoticeType.HP_ADD] = {
            skipConfig = 1013,
            text = "+"
        },
        [enBattleNoticeType.MP_ADD] = {
            skipConfig = 1014,
            text = "+"
        },
    },
    ["other"] = {
        [enBattleNoticeType.HP_DWON] = {
            skipConfig =  1001,
            text = "down"
        },
        [enBattleNoticeType.HP_CRIT] = {
            skipConfig =  1002,
            text = "crit"
        },
        [enBattleNoticeType.COMBO_CRIT] = {
            skipConfig =  1012,
            text = "crit"
        },
        [enBattleNoticeType.COMBO_DWON] = {
            skipConfig =  1011,
            text = "down"
        },
        [enBattleNoticeType.MISS] = {
            skipConfig =  1003,
            text = "miss"
        },
        [enBattleNoticeType.DEFPARRY] = {
            skipConfig =  1004,
            text = "defparry"
        },
        [enBattleNoticeType.DODGE] = {
            skipConfig =  1005,
            text = "dodge"
        },
        [enBattleNoticeType.ZUOQI_CRIT] = {
            skipConfig =  1016,
            text = "crit"
        },
        [enBattleNoticeType.ZUOQI_DWON] = {
            skipConfig =  1015,
            text = "down"
        },
        [enBattleNoticeType.WUHUN_CRIT] = {
            skipConfig =  1018,
            text = "crit"
        },
        [enBattleNoticeType.WUHUN_DWON] = {
            skipConfig =  1017,
            text = "down"
        },
        [enBattleNoticeType.SHENBING_CRIT] = {
            skipConfig =  1020,
            text = "crit"
        },
        [enBattleNoticeType.SHENBING_DOWN] = {
            skipConfig =  1019,
            text = "down"
        },
        [enBattleNoticeType.SUPER] = {
            skipConfig =  1021,
            text = "down"
        },
        [enBattleNoticeType.JINGJIE_DOWN] = {
            skipConfig =  1022,
            text = "down"
        }, 
        [enBattleNoticeType.JINGJIE_CRIT] = {
            skipConfig =  1023,
            text = "down"
        },
        [enBattleNoticeType.IGDEF] = {
            skipConfig =  1024,
            text = "down"
        },
        [enBattleNoticeType.TIANSHEN_CRIT] = {
            skipConfig =  1027,
            text = "crit"
        },
		[enBattleNoticeType.TIANSHEN_DWON] = {
            skipConfig =  1027,
            text = "down"
        },
        [enBattleNoticeType.LINGQI_CRIT] = {
            skipConfig =  1028,
            text = "crit"
        },
        [enBattleNoticeType.LINGQI_DOWN] = {
            skipConfig =  1029,
            text = "down"
        },
    }
}