
--[[
    战斗模块常量
    由它决定战斗是从哪个模块进入
]]

--[[
    进入战斗所传参数为一个table
    table = {
        *   model = BattleMode.BATTLE_MOSHEN_MODE     调用战斗的模块,参考BattleMode
        *   msg = report,                               战报
        *   callback = x                                回调函数
            ---以下参数据不同模块而定
    }
]]


--[[
    魔神进入战斗参数
    table = {
        model = BattleMode.BATTLE_MOSHEN_MODE
        msg = report
        callback =  function() xxx end
        attack_type = ATTACK_REBEL.NORMAL or ATTACK_REBEL.SPECIAL   全力一击或普通攻击,参考MoShenConst  
        attack_multiple = 2.5  攻击倍数
        
    }
]]
local BattleConst = {
    BattleMode = {
        BATTLE_ARENA_MODE = 1,   --竞技场
        BATTLE_MOSHEN_MODE = 2,  --魔神
        BATTLE_DUNGEON_MODE = 3, -- 主线副本
        BATTLE_STORYDUNGEON_MODE = 4, -- 剧情副本
    },

    SHOW_HP_DETAIL = false  -- 用于调试战斗血量，请勿打开
}
return BattleConst
