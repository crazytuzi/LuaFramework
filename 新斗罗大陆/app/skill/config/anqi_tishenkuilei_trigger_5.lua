
local anqi_tishenkuilei_trigger_5 = 
{
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true,},
    ARGS = 
    {
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {is_teammate = true, is_target = true, args_translate = {selectTarget = "strike_agreementee"}},
        },
        {
            CLASS = "action.QSBStrikeAgreement",
            OPTIONS = {is_strike_agreement = true, percent = 0.12,time = 8,hp_threshold = 0.05},
        },
    },
}
return anqi_tishenkuilei_trigger_5

