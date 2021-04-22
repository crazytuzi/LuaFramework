-- 技能 神器 海神套装庇护触发5
-- 技能ID 2020162

local anqi_hongchenbiyou_baohu1 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBChangeRageCofficient", 
            OPTIONS = {support_tianShiShengJian = true,change_cofficient_name = "rage_increase_coefficient",change_cofficient_value = 0, not_rage_info = true},
        },
    },
}

return anqi_hongchenbiyou_baohu1