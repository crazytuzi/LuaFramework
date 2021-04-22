
local suicide = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlayAnimation",
        },
        {
            CLASS = "action.QSBSuicide", -- 自杀且不播放初始设定的死亡动画
        },
    },    
}
return suicide