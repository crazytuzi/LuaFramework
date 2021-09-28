--------------------------------------------------------------------------------------
-- 文件名:	EffectStealMana.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	效果-偷怒气
-- 应  用:  
---------------------------------------------------------------------------------------
EffectStealMana = class("EffectStealMana", function() return CEffectBase:new() end)
EffectStealMana.__index = EffectStealMana

function EffectStealMana:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakeFirst)

	if not GameObj_Attacker or not GameObj_Defencer or not self.tbCfg  then   return end

    if self.tbCfg.EffecType == macro_pb.Skill_Effect_StealMana --[[偷怒气]] then
        
        local enemyMana = GameObj_Defencer.mana
        --[[被偷着的怒气不够表配置的数据大的情况偷取剩余怒气]]
        if GameObj_Defencer.mana <= 0 then 
             enemyMana = 0
             GameObj_Defencer.mana = 0
        elseif GameObj_Defencer.mana <= self:getDataValue1()  then
            enemyMana = GameObj_Defencer.mana
            GameObj_Defencer.mana = enemyMana - enemyMana
        else
            enemyMana = enemyMana - self:getDataValue1()
            GameObj_Defencer.mana = GameObj_Defencer.mana - self:getDataValue1()
        end

        --偷怒气者 加上偷来的怒气
        GameObj_Attacker.mana =  enemyMana <= self:getDataValue1() 
            and GameObj_Attacker.mana + enemyMana or GameObj_Attacker.mana + self:getDataValue1()
        
        GameObj_Attacker.mana = math.min(GameObj_Attacker.mana, GameObj_Attacker.max_mana)
		GameObj_Attacker.mana = math.max(0, GameObj_Attacker.mana)


    end
end


