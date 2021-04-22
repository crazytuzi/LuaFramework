-- 技能 牛天自动2
-- 技能ID 547
-- 肩甲进入充能状态，几秒后爆发，伤害敌方，护盾友方
--[[
	魂师 牛天
	ID:1052
	psf 2020-2-12
]]--

local pf_ssniutian02_zidong2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
        },
        {
            CLASS = "action.QSBPlayAnimation",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsIsUnderStatus",
                    OPTIONS = {is_attacker = true, status = "ssniutian_zhenji7"},
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "action.QSBApplyBuff",	
                            OPTIONS = {buff_id = "pf_sstianqingniumang02_zhenji7_buff",teammate = true},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 52},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai", is_target = false},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 21},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = {"pf_sstianqingniumang02_zidong2_buff1","pf_sstianqingniumang02_zidong2_buff;y"}},
                },
            },
        },
    },
}

return pf_ssniutian02_zidong2

