--[[
    filename: ComBattle.Defin.BDEvent
    description:
    date: 2016.08.31

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local BDEvent = {
    eBattleBegin = "b_b_",
    eBattleEnd   = "b_e_",
    eStageBegin  = "s_b_",
    eStageEnd    = "s_e_",
    eRoundBegin  = "r_b_",
    eRoundEnd    = "r_e_",
    eStepBegin   = "ss_b_",
    eStepEnd     = "ss_e_",
    eCreateHeroFinish = "c_h_f_",

    eCastTip  = "b_c_t_",    -- 施法蓄力提示
    eCasting  = "b_c_b_",    -- 施法开始
    eCasted   = "b_c_e_",    -- 施法完成
    eBeHit    = "b_h_b_",    -- 挨打
    eBeHitted = "b_h_e_",    -- 挨打结束

    eChangeHero = "s_h_c_",

    eHeroIn            = "s_h_i_",     -- 主将入场
    eHeroDead          = "s_h_d_b_", -- 主将死亡
    eHeroDeadActionEnd = "s_h_d_e_",
    eHeroReborn        = "s_h_r_",

    eMoveOut  = "m_o_",     -- 有主将移动
    eMoveBack = "m_b_",     -- 主将移回原位

    eAttackBegin = "a_b_",
    eAttackEnd   = "a_e_",

    eHP = "h_hp_",
    eRP = "h_rp_",

    eBuffAdd = "h_buff_a_",
    eBuffDel = "h_buff_e_",
}

return BDEvent
