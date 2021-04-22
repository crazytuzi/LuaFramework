-- 技能 群体普攻
-- 同时向多人发射弹道，加点震动
--[[
	boss 地穴魔蛛
	ID:3022 副本3-12
	psf 2018-1-22
]]--

local duyezhizhu_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },


        {
             CLASS = "composite.QSBSequence",
             ARGS = {

                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                -- {
                --      CLASS = "action.QSBRoledirection",
                --      OPTIONS = {direction = "skill_target"},
                -- },


                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {under_status = "attack_order", default_select = true,change_all_node_target = true},
                },
                {
                     CLASS = "action.QSBRoledirection",
                     OPTIONS = {direction = "skill_target"},
                },

                {
                    CLASS = "action.QSBBullet",
                },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 14},
                -- },


                {
                        CLASS = "action.QSBPlayAnimation",
         
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },

                {
                    CLASS = "action.QSBAttackFinish",

                },
            },
        },
    },
}

return duyezhizhu_pugong

