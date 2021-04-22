
local zudui_dadizhiwang_siwangjineng = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {teammate = true, buff_id = "zudui_kuangbao"},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },               
}

return zudui_dadizhiwang_siwangjineng