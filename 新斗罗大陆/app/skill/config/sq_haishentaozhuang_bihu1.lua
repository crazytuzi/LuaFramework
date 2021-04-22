-- 技能 神器 海神套装庇护触发5
-- 技能ID 2020162

local anqi_hongchenbiyou_baohu1 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBHaiShenTaoZhuang",
            OPTIONS = 
            {
                duration = 360, --技能生效总时长
                interval = 5, --没几秒对血量最低的目标触发一次护盾
                shelter_coefficient = 0.2, --庇护产生护盾相当于期间受到的伤害系数
                shelter_buff_id = "sq_haishentaozhuang_bihu1", --庇护常驻护盾产生的特效
                shelter_buff_id2 = "sq_haishentaozhuang_bihu2", --庇护常驻护盾产生的特效
                absorb_buff_id = "sq_haishentaozhuang_bihu_hudun", --濒死护盾产生的特效
                near_death_cd = 40, --濒死护盾CD时间
                near_death_buff_id = "sq_haishentaozhuang_bingsi1", --濒死护盾特效1
                near_death_buff_id2 = "sq_haishentaozhuang_bingsi2", --濒死护盾特效2
                near_death_coefficient = 1.2, --濒死护盾吸收系数
                shelter_damage_coefficient = 0,--爆炸护盾伤害系数，取决于吸收量
            },
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = true, buff_id = "sq_haishentaozhuang_bihu1_buff"},
        },
    },
 
}

return anqi_hongchenbiyou_baohu1