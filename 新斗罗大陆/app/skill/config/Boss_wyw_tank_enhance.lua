
local jinzhan_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = { is_target = true, buff_id = "boss_wyw_tank_enhance"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = { is_target = false, buff_id = "zudui_mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBExpression",
                    OPTIONS = {expStr = "armor_magic:prop={enemies:magicArmor_f:avg*1}, armor_physical:prop={enemies:physicalArmor_f:avg *1},cri_reduce_chance:prop={enemies:critReduce:sum*0.25}"},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = { is_target = false, buff_id = "duyezhizhu_fushidebuff_mianyi"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
        
        
       	
    },
}

return jinzhan_tongyong