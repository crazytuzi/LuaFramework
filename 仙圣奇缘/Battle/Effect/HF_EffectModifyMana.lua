--------------------------------------------------------------------------------------
-- 文件名:	HF_BattleCard.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-9-22 21:09
-- 版  本:	1.0
-- 描  述:	效果-修改当前气势
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


CEffectModifyMana = class("CEffectModifyMana", function() return CEffectBase:new() end)
CEffectModifyMana.__index = CEffectModifyMana

function CEffectModifyMana:takeEffect(GameObj_Attacker, GameObj_Defencer, bTakeFirst)
	if bTakeFirst then
   
        if self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_Mana--每回合增加气势
		    or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_Mana--每回合减少气势
		    or self.tbCfg.EffecType == macro_pb.Skill_Effect_ModifyMana--[[立即减少怒气]] then
            
            local mana = GameObj_Defencer.mana + self.tbCfg.EffectValue1
            mana = math.min(mana, GameObj_Defencer.max_mana)
            GameObj_Defencer.mana = math.max(0, mana)
    
            gEffectData:setManaEffectValue(GameObj_Defencer.apos, self.tbCfg.EffectValue1)
            gEffectData:setEffectType(GameObj_Defencer.apos, self.tbCfg.EffecType)
          

         elseif self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_MaxMana --增加气势上限
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_MaxMana--减少气势上限
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Add_ManaMaxPercent--增加气势上限万分比
			or self.tbCfg.EffecType == macro_pb.Skill_Effect_Reduce_ManaMaxPercent--[[减少气势上限万分比]] then
			nBaseProp = GameObj_Defencer.max_mana

		    self.data = math.floor(self.tbCfg.EffectValue1 + (nBaseProp * self.tbCfg.EffectValue2) / g_BasePercent)

            --减少气势上限时会出现的情况
            if GameObj_Defencer:get_maxMana() < GameObj_Defencer.mana then 
                GameObj_Defencer.mana = math.min(GameObj_Defencer.mana, GameObj_Defencer:get_maxMana())
		        GameObj_Defencer.mana = math.max(0, GameObj_Defencer.mana)
            end

        end

	end

end


