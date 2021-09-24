local CCnfDataManager={}

--"scene_door_cnf"
function CCnfDataManager.getDoorData(self,doorId)
    return _G.Cfg.scene_door[doorId]
end

--goods_cnf.lua
function CCnfDataManager.getGoodsData(self,goodsId)
    return _G.Cfg.goods[goodsId]
end

--icon_drop_cnf.lua
function CCnfDataManager.getDropGoodsData(self,goodsId)
    return _G.Cfg.icon_drop[goodsId]
end

--partner_init_cnf.lua
function CCnfDataManager.getPartnerData(self,partnerId)
    return _G.Cfg.partner_init[partnerId]
end

function CCnfDataManager.getSkillAIData(self,_AI)
    return _G.Cfg.skill_ai[_AI]
end

--broadcast
function CCnfDataManager.getBroadcastData(self, _broadcastId)
    return _G.Cfg.broadcast[_broadcastId]
end

--mount_cnf
function CCnfDataManager.getMountData(self, mountId)
    return _G.Cfg.mount[mountId]
end

function CCnfDataManager.getAISkillArray(self,_AI)
    local skillArray={}
    local aiCnf=_G.Cfg.skill_ai[_AI]
    if aiCnf~=nil and aiCnf.attack_skill~=nil and #aiCnf.attack_skill>0 then
        for i,v in ipairs(aiCnf.attack_skill) do
            skillArray[v[1]]=true
        end
    end
    return skillArray
end

_G.g_CnfDataManager=CCnfDataManager


-------------------------------------------------------------------
local CSkillDataManager={}

--"skill_skill2id_cnf"
function CSkillDataManager.getSkillIdToId(self,skillId)
    return _G.Cfg.skill[skillId]
end

--"skill_effect_cnf"
function CSkillDataManager.getSkillEffect(self,skillId)
    -- local skillIdToId = self:getSkillIdToId(skillId)

    -- if skillIdToId==nil or skillIdToId.frame_id==nil then 
    --     return nil
    -- end
    return _G.Cfg.skill_effect[skillId]
end

--"skill_effect_cnf"
function CSkillDataManager.getDirectSkillEffect(self,frame_id)
    return _G.Cfg.skill_effect[frame_id]
end

--"skill_skill2id_cnf"
function CSkillDataManager.getAskillId(self,skillId)
    local skillId2Id=_G.Cfg.skill[skillId]
    if not skillId2Id then
        return nil
    end
    return  skillId2Id.action_id
end

 --"skill_skill2id_cnf"
function CSkillDataManager.getEskillId(self,skillId)
    local skillId2Id=_G.Cfg.skill[skillId]
    if not skillId2Id then
        return nil
    end
    return skillId2Id.effect_id
 end
 --"skill_skill2id_cnf"
function CSkillDataManager.getEskillId2(self,skillId)
    local skillId2Id=_G.Cfg.skill[skillId]
    if not skillId2Id then
        return nil
    end
    return skillId2Id.effect_id2
 end
 --"skill_skill2id_cnf"
function CSkillDataManager.getEskillId3(self,skillId)
    local skillId2Id=_G.Cfg.skill[skillId]
    if not skillId2Id then
        return nil
    end
    return skillId2Id.pre_effect_id
 end

  --"skill_skill2id_cnf"
function CSkillDataManager.getHskillId(self,skillId,num)
    local skillId2Id=_G.Cfg.skill_effect[skillId]
    if not skillId2Id then
        return nil
    end
    num=num or 1
    return skillId2Id.frame[num].effect_out
 end

--"skill_cnf"
function CSkillDataManager.getSkillData(self,skillId)
    return _G.Cfg.skill[skillId]
end

--"skill_collider_cnf"
function CSkillDataManager.getSkillCollider(self,colliderId)
    return _G.Cfg.skill_collider[colliderId]
end

--"skill_effect_cnf"
function CSkillDataManager.getAttackSkillCollider(self,colliderId)
    -- print(colliderId,"####")
    return _G.Cfg.skill_ai_collider[colliderId]
end

--"player_int_cnf"
function CSkillDataManager.getSkillInitData(self,skinId)
    skinId=skinId or 0
    return _G.Cfg.player_init[skinId%10000]
end

--"skill_skin_cnf"
function CSkillDataManager.getSkinData(self,skinId)
    skinId=skinId or 0
    return _G.Cfg.skill_skin[skinId]
end

--"vitro_cnf"
function CSkillDataManager.getVitroData(self,vitroId)
    return _G.Cfg.vitro[vitroId]
end
--"trap_cnf"
function CSkillDataManager.getTrapData(self,trapId)
    return _G.Cfg.trap[trapId]
end

function CSkillDataManager.getSkillEffectIdArray(self,_skillId)
    local effectIdArray1={}
    local effectIdArray2={}
    local skillCnf=_G.Cfg.skill[_skillId]
    if skillCnf~=nil then
        if skillCnf.effect_id~=nil then
            for i=1,#skillCnf.effect_id do
                local effectId=skillCnf.effect_id[i].id
                local classId=skillCnf.effect_id[i].class
                if effectId>0 then
                    if classId==1 then
                        effectIdArray1[effectId]=true
                    elseif classId==3 then
                        effectIdArray2[effectId]=true
                    end
                end
            end
        end
        if skillCnf.effect_id2~=nil then
            for i=1,#skillCnf.effect_id2 do
                local effectId=skillCnf.effect_id2[i].id
                local classId=skillCnf.effect_id2[i].class
                if effectId>0 then
                    if classId==1 then
                        effectIdArray1[effectId]=true
                    elseif classId==3 then
                        effectIdArray2[effectId]=true
                    end
                end
            end
        end
    end
    return effectIdArray1,effectIdArray2
end
function CSkillDataManager.hasParticleVitro(self,_skillId)
    local skillCnf=_G.Cfg.skill[_skillId]
    if skillCnf~=nil then
        if skillCnf.effect_id2~=nil then
            for i=1,#skillCnf.effect_id2 do
                local classId=skillCnf.effect_id2[i].class
                if classId==2 then
                    return true
                end
            end
        end
    end
    return false
end

_G.g_SkillDataManager=CSkillDataManager
