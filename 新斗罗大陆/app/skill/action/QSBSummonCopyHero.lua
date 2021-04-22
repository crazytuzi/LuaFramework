-- **************************************************
-- Author               : wanghai
-- FileName             : QSBSummonCopyHero.lua
-- Description          : 
-- Create time          : 2019-10-26 12:27
-- Last modified        : 2019-10-26 12:27
-- **************************************************

local QSBAction = import(".QSBAction")
local QSBSummonCopyHero = class("QSBSummonCopyHero", QSBAction)
local QSkill = import("...models.QSkill")

function QSBSummonCopyHero:_execute(dt)
    local options = self:getOptions()
    local copy_hero_id = options.copy_hero_id
    local actor = self._attacker
    if copy_hero_id == nil or type(copy_hero_id) ~= "number" then
        self:finished()
        return
    end
    local buff_id = options.buff_id
    local screen_pos = options.screen_pos
    local pos = options.pos
    local copySlots = options.copy_slots
    local hasEnchatSkill = options.has_enchat_skill
    local hasGodSkill = options.has_god_skill
    local isVisible = options.is_visible
    local relativePos = options.relative_pos
    
    local percent = options.percent
    local ai_name = options.ai_name
    local appear_skill = options.appear_skill

    local param = {}
    param.summoner = actor
    param.heroId = copy_hero_id
    param.copySlots = copySlots
    param.screen_pos = screen_pos
    param.aiType = ai_name
    param.hasEnchatSkill = hasEnchatSkill
    param.hasGodSkill = hasGodSkill
    param.pos = pos
    param.clean_new_wave = self._options.clean_new_wave
    param.aiTypeHealth = options.ai_name_health
    if relativePos ~= nil then
        local attackerPos = self._attacker:getPosition()
        param.screen_pos = {x = attackerPos.x + relativePos.x, y = attackerPos.y + relativePos.y}
        param.pos = nil
    end

    local copyHero = app.battle:summonCopyHero(param)

    if not copyHero then
        self:finished()
        return
    end

    if options.direction ~= "" then
        copyHero:setDirection(options.direction)
    else
        copyHero:setDirection(self._attacker:getDirection())
    end

    if appear_skill then
        local skill = QSkill.new(appear_skill, {}, copyHero, 1)
        copyHero._skills[appear_skill] = skill
        copyHero:attack(skill, nil, nil, true)
    end

    copyHero:applyBuff(buff_id, copyHero)
    if not IsServerSide then
        local view = app.scene:getActorViewFromModel(copyHero)
        local skeletonView = view:getSkeletonActor()
        if self:getOptions().set_color then
            copyHero:setCopyHeroColor(self:getOptions().set_color, self:getOptions().set_color2)
            if not skeletonView.isFca then
                skeletonView:setColor(self._options.set_color)
                skeletonView:getSkeletonAnimation():setShaderProgram(qShader.Q_ProgramPositionTextureColorHSI)
                if self._options.set_color2 then
                    skeletonView:setColor2(self._options.set_color2)
                end
            else
                skeletonView:getRenderTextureSprite():setColor(self._options.set_color)
                setNodeShaderProgram(skeletonView:getRenderTextureSprite(), qShader.Q_ProgramPositionTextureColorHSI)
                skeletonView:stopSetColorOffset(true)
                if self._options.set_color2 then
                    local c2 = self._options.set_color2
                    -- c2 = ccc4(255, 255, 255, 255)
                    skeletonView:getRenderTextureSprite():setColorOffset(ccc4f(c2.r/255, c2.g/255, c2.b/255, c2.a/255))
                end
            end
        end
        if not isVisible then view:getSkeletonActor():setOpacity(0) end
    end
--[[======================================================================]]--    
    local funcTab = {
        "getMaxHp",
        "getAttack",
        "getCrit",
        "getHit",
        "getMaxHaste",
        "getPVPPhysicalAttackPercent",
        "getPVPMagicAttackPercent",
        "getOriginPVPPhysicalReducePercent",
        "getOriginPVPMagicReducePercent",
        "getHitLevel",
        "getPhysicalArmor",
        "getMagicArmor",
        "getDodge",
        "getBlock",
        "getCritReduce",
        "getPhysicalDamagePercentAttack",
        "getMagicDamagePercentAttack",
        "getPhysicalDamagePercentBeattack",
        "getPhysicalDamagePercentBeattackReduce",
        "getMagicDamagePercentBeattack",
        "getMagicDamagePercentBeattackReduce",
        "getPVPPhysicalReducePercent",
        "getPVPMagicReducePercent",
        "getPhysicalDamagePercentAttackReduce",
        "getMagicDamagePercentBeattackReduce",
        "getPVPMagicAttackPercent",
        "getPVPPhysicalAttackPercent",
        "getPVEDamagePercentAttack",
        "getPVEDamagePercentBeattack",
        "getAOEBeattackPercent",
        "getAOEAttackPercent",
        "getMagicPenetration",
        "getPhysicalPenetration",
        "getMagicTreatPercentAttack",
    }
    for k, v in pairs(funcTab) do
        copyHero[v] = function(copyHero, ...)
            return actor[v](actor, ...) * percent
        end
    end
    copyHero:setFullHp()

    self:finished()
end

function QSBSummonCopyHero:_onCancel()
end

return QSBSummonCopyHero

