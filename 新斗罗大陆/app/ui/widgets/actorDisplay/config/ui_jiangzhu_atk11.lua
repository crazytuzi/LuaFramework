
local ui_jiangzhu_shengyushu = 
{
     CLASS = "composite.QUIDBParallel",
     ARGS = 
     {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack11"},
        },
        {
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "ui_jiangzhu_attack11_1"},
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_frame = 55},
                }, 
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_jiangzhu_attack11_2"},
                },
                {
                    CLASS = "action.QUIDBPlayEffect",
                    OPTIONS = {effect_id = "ui_jiangzhu_attack11_3"},
                }, 
            },
        },
        {
            CLASS = "composite.QUIDBSequence",
            ARGS = {
                {
                    CLASS = "action.QUIDBDelayTime",
                    OPTIONS = {delay_time = 90 / 30},
                },
                {
                    CLASS = "action.QUIDBPlayAnimation",
                    OPTIONS = {animation = "stand"},
                },
            },
        },
    },
}
return ui_jiangzhu_shengyushu