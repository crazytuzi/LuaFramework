SkillHurt = SkillHurt or {}

local __mathCeil=math.ceil
local __mathSqrt=math.sqrt
local __mathAbs=math.abs
local __mathMax=math.max
local __mathMin=math.min
local __mathPow=math.pow

function SkillHurt.calculateSkillHurt( self, _skillNode, _currentFrame, _Assailant, _Victim, skillId, _skillLv, vitroCharacter )
    if not _Assailant or not _Victim then return end
    -- CCLOG("开始 SkillHurt.calculateSkillHurt _Assailant.m_nID=%d,_Victim.m_nID=%d,_Victim.m_nType=%d ",_Assailant.m_nID, _Victim.m_nID, _Victim.m_nType )

    local isOnlyOnhurt,isCopyBox=false,false
    if _Victim.m_nType==_G.Const.CONST_GOODS_MONSTER then
        -- print("物品怪物被击中。。。。。CONST_GOODS_MONSTER")
        isOnlyOnhurt=true
        if self.m_stageView:getScenesType()==_G.Const.CONST_MAP_TYPE_COPY_BOX then
            if _Assailant.isMainPlay or (_Assailant.m_subject and _Assailant.m_subject.isMainPlay) then
                if self.m_stageView.m_copyBoxSendArray==nil then
                    self.m_stageView.m_copyBoxSendArray={}
                    self.m_stageView.m_copyBoxSendCount=0
                    local function onSchedule()
                        if self.m_stageView.m_copyBoxSendCount==0 then return end

                        local msg=REQ_MIBAO_BOX_HARM()
                        msg:setArgs(self.m_stageView.m_copyBoxSendCount,self.m_stageView.m_copyBoxSendArray)
                        _G.Network:send(msg)
                        self.m_stageView.m_copyBoxSendArray={}
                        self.m_stageView.m_copyBoxSendCount=0
                    end
                    _G.Scheduler:schedule(onSchedule,0.6)
                end
                self.m_stageView.m_copyBoxSendCount=self.m_stageView.m_copyBoxSendCount+1
                self.m_stageView.m_copyBoxSendArray[self.m_stageView.m_copyBoxSendCount]=_Victim.m_nID

                isCopyBox=true
            end
        end
    elseif _Victim.m_nType==_G.Const.CONST_TRAP or _Victim.m_nType==_G.Const.CONST_HOOK then
        isOnlyOnhurt=true
    end

    if isOnlyOnhurt then
        if not(_Assailant.m_nType==_G.Const.CONST_TRAP or _Assailant.m_nType==_G.Const.CONST_GOODS_MONSTER or _Assailant.m_nType==_G.Const.CONST_HOOK) then
            local hurtSkillId=_currentFrame.effect_out
            _Victim:onHurt(hurtSkillId,_Assailant)
        end
        return isCopyBox
    end

    if _Victim.m_nType==_G.Const.CONST_DEFENSE then
        -- print(">>>>>> 有怪物打到雕像啦 快的出效果啊亲。。。。。。。。")
        local hurtSkillId=_currentFrame.effect_out
        _Victim:onHurt(hurtSkillId)
        if vitroCharacter then
            skillId=vitroCharacter.m_vitroId
        end
        self:sendComputedefHP(_G.Const.CONST_WAR_DISPLAY_CRIT, _currentFrame.id, -400, _Assailant, _Victim,skillId, _currentFrame.percent*10000)
        return
    end

    --技能碰撞后结算伤害_Assailant 攻击者    _Victim 受害者
    _Assailant : handleSkillFrameBuff( _currentFrame, 1, 1, _skillNode.id)

    if _Victim:isHaveBuff( _G.Const.CONST_BATTLE_BUFF_INVINCIBLE) == true then
        if _currentFrame.buff then
            for i=1,#_currentFrame.buff do
                local currentBuff=_currentFrame.buff[i]
                if currentBuff.id>2600 and currentBuff.id<2700 then
                    local invBuff= _G.GBuffManager:getBuffNewObject(currentBuff.id, 0)
                    _Victim:addBuff(invBuff)
                end
            end
        end
        return false
    end
    local resultData,totalHurtValue=nil
    if _currentFrame.damage == 1 then
        if _Assailant.m_nType==_G.Const.CONST_HOOK or _Assailant.m_nType==_G.Const.CONST_GOODS_MONSTER or _Assailant.m_nType==_G.Const.CONST_TRAP then
            resultData={}
            resultData.hurtValue = __mathCeil(_Victim:getMaxHp()*_Assailant.m_proportion*0.0001)
            resultData.hurtValue = resultData.hurtValue + __mathCeil(_Assailant.m_fixedHurt)
            resultData.isOccurHit = true
        else            
            resultData,totalHurtValue = self:compute( _skillNode, _currentFrame, _Assailant, _Victim, _skillLv,skillId)
        end
        if resultData.isOccurHit then
            local crit_fix = resultData.isOccurCrit
            local hurtHP=resultData.hurtValue
            -- hurtHP = 1
            -- if not _Assailant.isMainPlay then
            -- if _Assailant:getProperty():getTeamID()==0 then
            --     hurtHP=hurtHP*100
            -- end
            -- print("SkillHurt.calculateSkillHurt  hurtHP=",hurtHP,"totalHurtValue=",totalHurtValue)

            if self.isNeedBroadcastHurt then
                if crit_fix then
                    crit_fix=_G.Const.CONST_WAR_DISPLAY_CRIT
                else
                    crit_fix=_G.Const.CONST_WAR_DISPLAY_NORMAL
                end

                if vitroCharacter then
                    skillId=vitroCharacter.m_vitroId
                end
                self:sendComputeHP(crit_fix, _currentFrame.id, -hurtHP, _Assailant, _Victim,skillId, _currentFrame.percent)
            else
                -- print("SkillHurt.calculateSkillHurt hurtHP=",hurtHP,"crit_fix=",crit_fix)

                local hurtSkillId=_currentFrame.effect_out

                local isPlayerAttack =_Assailant.isMainPlay
                if _Assailant.m_subject and _Assailant.m_subject.isMainPlay then
                    isPlayerAttack=true
                end
                if isPlayerAttack then
                    self.m_stageView:addCombo()
                    if _Victim:getType() == _G.Const.CONST_MONSTER then
                        local nowhp =_Victim:getHP()
                        if nowhp > 0 then
                            if nowhp > hurtHP then
                                self.m_stageView:addMonsHp(hurtHP)
                            else
                                self.m_stageView:addMonsHp(__mathCeil(nowhp))
                            end
                        end
                    end
                end

                if _currentFrame.iseffect~=0 then
                    -- if vitroCharacter~=nil then
                    --     _Victim:adjustDirect(vitroCharacter)
                    -- else
                    --     _Victim:adjustDirect(_Assailant)
                    -- end
                    local isNormalSkill
                    if _Assailant.m_normalSkills ~= nil and _Assailant.m_normalSkills[skillId] then
                        isNormalSkill = true
                    end
                    _Victim:onHurt(hurtSkillId,isNormalSkill,_currentFrame.iseffect)
                end
                _Victim:addHP(-hurtHP,crit_fix)
                -- if not _Assailant.m_noHurtEffect then
                    
                -- end
                --累计杀怪血量
                -- if isPlayerAttack == true and _Victim:getType() == _G.Const.CONST_MONSTER then
                --     self.m_stageView:addMonsHp(hurtHP)
                -- end

                --累计受击数量
                if _Victim.isMainPlay then
                    self.m_stageView : addHitTimes()
                end
            end
        else
            if self.isNeedBroadcastHurt then
                if vitroCharacter then
                    skillId=vitroCharacter.m_vitroId
                end
                self:sendComputeHP(_G.Const.CONST_WAR_DISPLAY_DODGE,  _currentFrame.id, 0, _Assailant, _Victim,skillId, _currentFrame.percent)
                -- return false
            end
            if _currentFrame.iseffect~=0 then
                -- if vitroCharacter~=nil then
                --     _Victim:adjustDirect(vitroCharacter)
                -- else
                --     _Victim:adjustDirect(_Assailant)
                -- end
                _Victim:showdodge()
            end
            -- return false
        end 
    end
-- 
    -- if _Victim:getType() == _G.Const.CONST_PLAYER then
        -- 改
        if _G.CharacterManager:checkNoHookArray(_Assailant) and 
            not (self.m_stageView:getScenesType() == _G.Const.CONST_MAP_TYPE_CITY_BOSS
            and _Assailant:getType() ~= _G.Const.CONST_MONSTER) then
            _Victim.m_nTarget=_Assailant
        end
    -- end
    local skillData=_G.g_SkillDataManager:getSkillData(skillId)
    local hasRigidityBuff,hasCrashBuff,hasBeatbackBuff,gatherData = _Victim:handleSkillFrameBuff( _currentFrame, 0, 1, _skillNode.id,totalHurtValue)
    if _Victim:getStatus() == _G.Const.CONST_BATTLE_STATUS_USESKILL and skillData and skillData.type~=_G.Const.CONST_SKILL_INTERRUPT_SKILL then
        -- if not (_Victim:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_DIZZY) or _Victim:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN))
        -- if _Victim.m_normalSkills ~= nil then
        --     for k,v in pairs(_Victim.m_normalSkills) do
        --         print(k,v)
        --     end
        --     print("@@@$@%@%%%",_Victim.m_nSkillID)
        -- end
        if _Assailant.m_nType~=_G.Const.CONST_HOOK and _Assailant.m_nType~=_G.Const.CONST_TRAP then
            -- if not (_Victim:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_DIZZY) or _Victim:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN))then
                -- if _Victim:getType() == _G.Const.CONST_MONSTER or 
                --     (_Victim.m_nSkillID~=nil and _Victim.m_normalSkills ~=nil and not _Victim.m_normalSkills[_Victim.m_nSkillID]) then
                -- if _Victim.m_nSkillID ~= nil  then
                    if _Victim:getType() == _G.Const.CONST_MONSTER then
                        if _Victim.m_canBreak~=1 then
                            hasRigidityBuff,hasCrashBuff,hasBeatbackBuff,gatherData=nil ,nil, nil,nil
                        end
                    else
                        hasRigidityBuff,hasCrashBuff,hasBeatbackBuff,gatherData=nil ,nil, nil,nil
                    end
                    
                -- end
            -- end
        end
    elseif _Victim:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN) then
        hasRigidityBuff,hasCrashBuff,hasBeatbackBuff,gatherData=nil ,nil, nil,nil
    end

    if _currentFrame.iseffect~=0 then
        if vitroCharacter~=nil then
            _Victim:adjustDirect(vitroCharacter)
        else
            _Victim:adjustDirect(_Assailant)
        end
    end

    --没有霸体则受伤
    if not _Victim:isHaveBuff( _G.Const.CONST_BATTLE_BUFF_ENDUCE) and not _Victim:isHaveBuff( _G.Const.CONST_BATTLE_BUFF_ENDUCE_FOREVER) then  
        --有僵直buff
        if hasRigidityBuff then
            --使用技能状态
            -- if _Victim:getStatus() == _G.Const.CONST_BATTLE_STATUS_USESKILL then
            --     _Victim:removeBuffBySkillId( _Victim.m_nSkillID )
            -- end
            if _Victim:getStatus()~=_G.Const.CONST_BATTLE_STATUS_CRASH or _Victim.m_isAirHurtAction then
                if _Victim:getStatus()==_G.Const.CONST_BATTLE_STATUS_USESKILL then
                    _Victim:hideEskillEffect()
                end
                _Victim:setStatus( _G.Const.CONST_BATTLE_STATUS_HURT,nil, _currentFrame.iseffect )
            end
        end
        if gatherData ~= nil then
            _Victim:Translation(gatherData.speed,gatherData.x,gatherData.y,_Assailant)
        end
        if hasBeatbackBuff then
            if _Victim:getStatus() == _G.Const.CONST_BATTLE_STATUS_USESKILL then
                _Victim:removeBuffBySkillId( _Victim.m_nSkillID )
                _Victim:hideEskillEffect()
            end

            -- local monsterRank = _Victim : getMonsterRank()
            -- if monsterRank ~= nil and monsterRank >= _G.Const.CONST_MONSTER_RANK_ELITE then return true end
            self:addThrustByID( _Assailant, _Victim, _G.Const.CONST_BATTLE_BUFF_BEATBACK, vitroCharacter )
        end
        if hasCrashBuff then
            if _Victim:getStatus() == _G.Const.CONST_BATTLE_STATUS_USESKILL then
                _Victim:removeBuffBySkillId( _Victim.m_nSkillID )
                _Victim:hideEskillEffect()
            end
            _Victim:setStatus( _G.Const.CONST_BATTLE_STATUS_CRASH)
            -- local monsterRank = _Victim : getMonsterRank()
            -- if monsterRank ~= nil and monsterRank >= _G.Const.CONST_MONSTER_RANK_GOOD then return true end
    
            self:addThrustByID( _Assailant, _Victim, _G.Const.CONST_BATTLE_BUFF_CRASH, vitroCharacter )
        end
    end

    return true
end

function SkillHurt.sendComputeHP( self,_crit_fix, _skillNum, _hurtHP,_Assailant, _Victim,_skillId, _percent)

    -- if _G.Const.CONST_WAR_DISPLAY_DODGE==_crit_fix then
    --     print("发闪避＝＝＝＝＝＝＝＝＝＝＝＝＝》》》 _crit_fix=",_crit_fix)
    -- elseif _G.Const.CONST_WAR_DISPLAY_CRIT==_crit_fix then
    --     print("发暴击＝＝＝＝＝＝＝＝＝＝＝＝＝》》》 _crit_fix=",_crit_fix)
    -- elseif _G.Const.CONST_WAR_DISPLAY_NORMAL==_crit_fix then
    --     print("发普通攻击＝＝＝＝＝＝＝＝＝＝＝＝＝》》》 _crit_fix=",_crit_fix)
    -- end
    if _Victim:getHP() <= 0 then return end
    if (not _Victim.isMainPlay and not _Assailant.isMainPlay) then
        local partner=nil
        if _Assailant:getType()==_G.Const.CONST_PARTNER and _Assailant.m_boss and _Assailant.m_boss.isMainPlay then
        elseif _Assailant.m_subject and _Assailant.m_subject.isMainPlay then
            _skillId=_Assailant.m_subjectSkill
        elseif _Victim:getType()==_G.Const.CONST_TEAM_HIRE or _Assailant:getType()==_G.Const.CONST_TEAM_HIRE then
        else
            return
        end
        -- if not partner.m_boss.isMainPlay then
        --     return
        -- end
    elseif _Victim.isMainPlay and (_Assailant:getType() == _G.Const.CONST_PLAYER 
        or _Assailant:getType() == _G.Const.CONST_PARTNER) then
        return
    end

    local assailantProperty =_Assailant:getProperty()
    local victimProperty =_Victim:getProperty()
    -- print("SkillHurt.sendComputeHP 发送  _Assailant:getName()=",_Assailant:getName())

    local scenesType = self.m_stageView:getScenesType()
    local warType = _G.Const.CONST_WAR_PARAS_1_WORLD_BOSS
    if scenesType == _G.Const.CONST_MAP_TYPE_KOF then
        if _Victim.isMainPlay then return end
        if self.m_stageView.m_txdy_super then
            warType = _G.Const.CONST_WAR_PARAS_1_TXDY_SUPER
        else            
            warType = _G.Const.CONST_WAR_PARAS_1_PK
        end
    elseif scenesType == _G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        warType = _G.Const.CONST_WAR_PARAS_1_TEAM
    elseif scenesType == _G.Const.CONST_MAP_TYPE_CLAN_BOSS then
        warType = _G.Const.CONST_WAR_PARAS_1_CLAN2
    elseif scenesType == _G.Const.CONST_MAP_CLAN_DEFENSE then
        warType = _G.Const.CONST_WAR_CLAN_DEFENSE
    elseif scenesType == _G.Const.CONST_MAP_CLAN_WAR then
        warType = _G.Const.CONST_WAR_WARFARE_WAR
    elseif scenesType == _G.Const.CONST_MAP_TYPE_CITY_BOSS then
        warType = _G.Const.CONST_WAR_PARAS_1_CITY_BOSS
    elseif scenesType == _G.Const.CONST_MAP_TYPE_COPY_BOX then
        warType = _G.Const.CONST_WAR_PARAS_MIBAO
    end

    local assailant_type = _Assailant : getType()
    local assailant_uid =  _Assailant : getID()
    local assailant_xml_id = _Assailant : getMonsterXMLID()
    if assailant_type == _G.Const.CONST_PARTNER or assailant_type == _G.Const.CONST_TEAM_HIRE then
        assailant_uid = assailantProperty:getUid()
        assailant_xml_id = assailantProperty:getPartner_idx()
    end

    local victim_type = _Victim : getType()
    local victim_uid = _Victim : getID()
    local victim_xml_id = _Victim : getMonsterXMLID()
    if victim_type == _G.Const.CONST_PARTNER or victim_type == _G.Const.CONST_TEAM_HIRE then
        victim_uid = victimProperty:getUid()
        victim_xml_id = victimProperty:getPartner_idx()
    end

    local msg = REQ_WAR_HARM_NEW()
    msg:setArgs(
                warType,
                assailant_type,
                assailant_uid,
                assailant_xml_id,
                victim_type,
                victim_uid,
                victim_xml_id,
                _skillId,
                _skillNum,
                _percent,
                _crit_fix,
                __mathAbs(_hurtHP)
            )

    if scenesType==_G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        _Assailant.m_victimDatas=_Assailant.m_victimDatas or {}
        _Assailant.m_victimDatas[#_Assailant.m_victimDatas+1]=msg
    else
        _G.Network:send(msg)
    end

    -- print("SkillHurt.sendComputeHP >>>>>assailant_type = ", assailant_type,"victim_type=", victim_type, " hp =",_hurtHP )
end

function SkillHurt.sendComputedefHP( self,_crit_fix, _skillNum, _hurtHP,_Assailant, _Victim, _skillId, _percent)
    local assailantProperty =_Assailant:getProperty()
    -- local mainProperty = _G.GPropertyProxy:getMainPlay()

    -- print("SkillHurt.sendComputeHP 发送  _Assailant:getName()=",_Assailant:getName())
    local warType = 16
    local scenesType = self.m_stageView:getScenesType()

    local assailant_type = _Assailant : getType()
    local assailant_uid =  _Assailant : getID()
    local assailant_xml_id = _Assailant : getMonsterXMLID()

    local victim_type = _Victim.m_nType
    local victim_uid  = 0
    local victim_xml_id = _Victim.m_goodsMonsterId
    
    local msg = REQ_WAR_HARM_NEW()
    msg:setArgs(
                warType,
                assailant_type,
                assailant_uid,
                assailant_xml_id,
                victim_type,
                victim_uid,
                victim_xml_id,
                _skillId,
                _skillNum,
                _percent,
                _crit_fix,
                __mathAbs(_hurtHP)
            )

    _G.Network:send(msg)
    return true 
end


function SkillHurt.addThrust( self, _Assailant, _Victim, vitroCharacter )
    -- if _Victim : isHaveBuff( _G.Const.CONST_BATTLE_BUFF_ENDUCE ) == true then    --霸体
    --     return
    -- end
    -- self : addThrustByID( _Assailant, _Victim, _G.Const.CONST_BATTLE_BUFF_RIGIDITY, vitroCharacter )     --僵值
    self : addThrustByID( _Assailant, _Victim, _G.Const.CONST_BATTLE_BUFF_CRASH, vitroCharacter )        --击飞
end

function SkillHurt.addThrustByID( self, _Assailant, _Victim, _buffID, vitroCharacter )
    if _Victim : isHaveBuff( _buffID ) then
        local buff = _Victim : getBuff( _buffID )
        if not buff then
            return
        end
        -- local selfCharacter = _Assailant
        -- if vitroCharacter then
        --     selfCharacter = vitroCharacter
        -- end
        -- if buff.speed and buff.pushAngle and buff.acceleration then
        --     local _AssailantScaleX = selfCharacter : getScaleX()
        --     local pushAngle = buff.pushAngle
        --     if _AssailantScaleX < 0 then
        --         pushAngle = -(90- (__mathAbs(buff.pushAngle) -90))
        --     end
        --     _Victim:thrust( buff.speed, pushAngle, buff.acceleration,buff.downacceleration)
        -- end
        if buff.speed>300 then
            _Victim.m_sceFly=true
        end
        -- 中心击退 Y轴位移
        local selfCharacter = _Victim
        if buff.speed and buff.pushAngle and buff.acceleration then
            local speed = buff.speed
            local _AssailantScaleX = _Assailant : getScaleX()
            local pushAngle = buff.pushAngle
            if _AssailantScaleX < 0 then
                pushAngle = __mathAbs(buff.pushAngle) - 180
            end
            local xyAngle = nil
            if vitroCharacter then
                xyAngle = vitroCharacter.angle
            end
            if buff.idEffect and _buffID==_G.Const.CONST_BATTLE_BUFF_CRASH then
                local random=gc.MathGc:random_0_1()>0.5 and 1 or -1
                local randomSpeed=gc.MathGc:random_0_1()*buff.idEffect
                speed=speed+random*randomSpeed
            end
            _Victim:thrust( speed, pushAngle, buff.acceleration,buff.downacceleration, xyAngle)
        end
    end
end

function SkillHurt.compute( self, _skillNode, _currentFrame, _Assailant, _Victim, _skillLv,_skillId)
    _Assailant.m_skillToVictims=_Assailant.m_skillToVictims or {}
    local id = nil
    local victimData = nil
    if _Victim.m_nType==_G.Const.CONST_MONSTER then
        id = _Victim.m_monsterId
    else
        id = _Victim.m_nID
    end
    if _Assailant.m_skillToVictims[id]==nil then
        _Assailant.m_skillToVictims[id]={}
    end
    victimData=_Assailant.m_skillToVictims[id][_skillId]
    if victimData==nil then
        victimData={}
        _Assailant.m_skillToVictims[id][_skillId]=victimData
    end

    if victimData.hitRatio~=nil then
        local resultData = {}
        local hitRandomRatio=gc.MathGc:random_0_1()
        if hitRandomRatio>victimData.hitRatio then
            resultData.isOccurHit=false
            return resultData
        end

        if victimData.critRatio~=nil then
            resultData.isOccurHit=true
            local critRandomRatio=gc.MathGc:random_0_1()
            local critHurtRaito = 1
            local isOccurCrit = false

            if critRandomRatio<=victimData.critRatio then
                isOccurCrit=true
                critHurtRaito=(1.8+victimData.critRatio)*_Assailant.m_critHurt
            end


            local hurtValue = 0
            -- if _Victim:getType() == _G.Const.CONST_PLAYER or _Victim:getType() == _G.Const.CONST_PARTNER then
            --     hurtValue=critHurtRaito*victimData.skillAttackValue+victimData.skillAttackConst
            -- else
            --     hurtValue=critHurtRaito*victimData.skillAttackValue+victimData.skillAttackConst
            -- end
            hurtValue=critHurtRaito*victimData.skillAttackValue
            hurtValue=__mathCeil(hurtValue)
            resultData.isOccurCrit=isOccurCrit
            resultData.hurtValue=__mathCeil(hurtValue*_currentFrame.percent)

            if _Assailant.lingYaoCamp and _Victim.lingYaoCamp then
                if (_Assailant.lingYaoCamp==_G.Const.CONST_PAR_ARENA_LING and _Victim.lingYaoCamp==_G.Const.CONST_PAR_ARENA_SHENG) 
                    or (_Assailant.lingYaoCamp==_G.Const.CONST_PAR_ARENA_SHENG and _Victim.lingYaoCamp==_G.Const.CONST_PAR_ARENA_AN)
                    or (_Assailant.lingYaoCamp==_G.Const.CONST_PAR_ARENA_AN and _Victim.lingYaoCamp==_G.Const.CONST_PAR_ARENA_LING) then

                    -- print("YYYYYYYYYYYYYYYYY=====>>>>克制。。。。。",resultData.hurtValue,__mathCeil(resultData.hurtValue*(1+_G.Const.CONST_PAR_ARENA_KEZHI*0.01)))
                    resultData.hurtValue=__mathCeil(resultData.hurtValue*(1+_G.Const.CONST_PAR_ARENA_KEZHI*0.01))
                end
            end
            -- print("resultData.hurtValue",resultData.hurtValue)
            return resultData,hurtValue
        end
    end

    local assailantProperty =_Assailant:getProperty()
    local victimProperty =_Victim:getProperty()

    if not assailantProperty or not victimProperty then
        CCLOG("攻击者或者受击者数据为空+++++++++++++++++++++++++=====ERROR")
        return 0
    end
    -- local assailantAttr = assailantProperty : getAttr()
    -- local victimAttr = victimProperty : getAttr()

    local assailantAttr = _Assailant : getWarAttr()
    local victimAttr = _Victim : getWarAttr()
        -- local strong_att         = victimAttr :getStrongAtt() or 0  --攻击
        -- local strong_def         = victimAttr :getStrongDef() or 0  --防御
        -- local crit               = victimAttr :getCrit() or 0       --暴击值(万分比)
        -- local crit_res           = victimAttr :getCritRes() or 0    --抗暴值(万分比)
        -- local wreck              = victimAttr :getWreck() or 0      --破甲值(万分比)
        -- local sp                 = victimAttr :getSp() or 0         -- {怒气}
        -- local dodge              = victimAttr :getDodge() or 0      -- {躲避值}
        -- local hit                = victimAttr :getHit() or 0        -- {命中值}

        -- local bonus              = victimAttr :getBonus() or 0      -- {伤害率}
        -- local reduction          = victimAttr :getReduction() or 0  
        -- print(strong_att,strong_def,crit,crit_res,wreck,dodge,hit,bonus,reduction,"victimAttr")
        -- local strong_att         = assailantAttr :getStrongAtt() or 0  --攻击
        -- local strong_def         = assailantAttr :getStrongDef() or 0  --防御
        -- local crit               = assailantAttr :getCrit() or 0       --暴击值(万分比)
        -- local crit_res           = assailantAttr :getCritRes() or 0    --抗暴值(万分比)
        -- local wreck              = assailantAttr :getWreck() or 0      --破甲值(万分比)
        -- local sp                 = assailantAttr :getSp() or 0         -- {怒气}
        -- local dodge              = assailantAttr :getDodge() or 0      -- {躲避值}
        -- local hit                = assailantAttr :getHit() or 0        -- {命中值}

        -- local bonus              = assailantAttr :getBonus() or 0      -- {伤害率}
        -- local reduction          = assailantAttr :getReduction() or 0  
        -- print(strong_att,strong_def,crit,crit_res,wreck,dodge,hit,bonus,reduction,"assailantAttr")
    local resultData = {}

    local assailantHit = assailantAttr:getHit()
    local victimDodge = victimAttr:getDodge()

    local assailantCrit = assailantAttr:getCrit()
    local assailantAttack = assailantAttr:getStrongAtt()
    if _Assailant.m_attackPlus then
        assailantAttack=assailantAttack*(_Assailant.m_attackPlus+100)*0.01
    end
    local assailantWreck = assailantAttr:getWreck()
    local assailantBonus = assailantAttr:getBonus()*0.0001

    local victimCritRes = victimAttr:getCritRes() or 0
    local victimDefend = victimAttr:getStrongDef() or 0
    local victimReduction = victimAttr:getReduction()*0.0001

    victimDefend=victimDefend==0 and 0.00001 or victimDefend
    victimCritRes=victimCritRes==0 and 0.00001 or victimCritRes

    victimDodge=victimDodge==0 and 0.00001 or victimDodge

    if (_Assailant.isMainPlay or _Victim.isMainPlay) and self.m_stageView.m_attributeAdds then
        for attrType,attributes in pairs(self.m_stageView.m_attributeAdds) do

            -- print("SkillHurt.compute attrType=",attrType,"attributes.labelValue=",attributes.labelValue)

            if _Assailant.isMainPlay then
                if attrType==_G.Const.CONST_ATTR_STRONG_ATT then  --42攻击
                    assailantAttack=assailantAttack*(attributes.labelValue+1)

                elseif attrType==_G.Const.CONST_ATTR_DEFEND_DOWN then    --44破甲
                    assailantWreck=assailantWreck*(attributes.labelValue+1)

                elseif attrType==_G.Const.CONST_ATTR_HIT then       --45命中
                    assailantHit=assailantHit*(attributes.labelValue+1)

                elseif attrType==_G.Const.CONST_ATTR_CRIT then    --47暴击
                    assailantCrit=assailantCrit*(attributes.labelValue+1)

                elseif attrType==_G.Const.CONST_ATTR_BONUS then   --49伤害率
                    assailantBonus=assailantBonus*(attributes.labelValue+1)
                end
            
            elseif _Victim.isMainPlay then
                if attrType==_G.Const.CONST_ATTR_STRONG_DEF then     --43防御
                    victimDefend=victimDefend*(attributes.labelValue+1)

                elseif attrType==_G.Const.CONST_ATTR_DODGE then    --46闪避
                    victimDodge=victimDodge*(attributes.labelValue+1)

                elseif attrType==_G.Const.CONST_ATTR_RES_CRIT then    --48抗暴
                    victimCritRes=victimCritRes*(attributes.labelValue+1)

                elseif attrType==_G.Const.CONST_ATTR_REDUCTION then   --50免伤率
                    victimReduction=victimReduction*(attributes.labelValue+1)

                end
            end
        end
    end

    -- print("assailantHit=",assailantHit)
    -- print("assailantCrit=",assailantCrit)
    -- print("assailantAttack=",assailantAttack)
    -- print("assailantWreck=",assailantWreck)
    -- print("assailantBonus=",assailantBonus)
    -- print("victimCritRes=",victimCritRes)
    -- print("victimDefend=",victimDefend)
    -- print("victimReduction=",victimReduction)


    local hitRatio = __mathMax(__mathMin(1.05-0.15*victimDodge/assailantHit,1),0.6)

    victimData.hitRatio=hitRatio 
    --当攻击方命中<=防御方闪避时
    -- if assailantHit<=victimDodge then
        -- print("当攻击方命中<=防御方闪避时 assailantHit=",assailantHit,",victimDodge=",victimDodge)
        --0.9*攻击方命中/防御方闪避
        -- hitRatio=0.9*assailantHit/victimDodge
        --max(min(1.1-0.2*防御方闪避/攻击方命中,1),0.2)
        -- hitRatio=__mathMax(__mathMin(1.2-0.3*victimDodge/assailantHit,1),0.2) 
    --当攻击方命中>防御方闪避时
    -- else
    --     -- print("当攻击方命中>防御方闪避时 assailantHit=",assailantHit,",victimDodge=",victimDodge)
    --     --1-0.1*防御方闪避/攻击方命中
    --     hitRatio=1-0.1*victimDodge/assailantHit
    -- end
    local hitRandomRatio=gc.MathGc:random_0_1()
    --未命中
    if hitRandomRatio>hitRatio then
        -- CCLOG("未命中 hitRandomRatio=%f,hitRatio=%f",hitRandomRatio,hitRatio)
        resultData.isOccurHit=false
        return resultData
    -- else
        -- CCLOG("命中 hitRandomRatio=%f,hitRatio=%f",hitRandomRatio,hitRatio)
    end
    resultData.isOccurHit=true


    local skillData=_G.g_SkillDataManager:getSkillData(_skillId)

    local skillAttackRatio =1
    local skillAttackConst =0
    if _Assailant.m_cloneRatio~=nil then
        skillAttackRatio=_Assailant.m_cloneRatio
        skillAttackConst=_Assailant.m_cloneConst
    else
        if skillData and skillData.lv and skillData.lv[_skillLv] then
            local lvData = skillData.lv[_skillLv]
            skillAttackRatio=lvData.mc_arg1*0.0001
            skillAttackConst=lvData.mc_arg2
        -- else
        --     CCLOG("无技能等级数据")
        end
    end

    local critRatio = 1
    --当攻击方暴击值>=防御方抗暴时
    if assailantCrit>=victimCritRes then
        -- print("当攻击方暴击值>=防御方抗暴时 assailantCrit=",assailantCrit,",victimCritRes=",victimCritRes)
        -- min(1,(0.5*攻击方暴击值/防御方抗暴-0.323)^0.5-0.1)
        critRatio=__mathMin(1,__mathSqrt(0.5*assailantCrit/victimCritRes-0.323)-0.1)*0.5
    else
        -- print("当攻击方暴击值<防御方抗暴时 assailantCrit=",assailantCrit,",victimCritRes=",victimCritRes)
        -- (0.167*(攻击方暴击值/防御方抗暴)^3+0.01)^0.5-0.1
         critRatio=(__mathSqrt(0.167*__mathPow(assailantCrit/victimCritRes,3)+0.01)-0.1)*0.5
    end
    victimData.critRatio=critRatio
    -- math.randomseed(os.time())
    local critRandomRatio=gc.MathGc:random_0_1()
    -- print("暴击率 critRatio=",critRatio,",critRandomRatio=",critRandomRatio)

    local critHurtRaito = 1
    local isOccurCrit = false

    --暴击
    if critRandomRatio<=critRatio then
        isOccurCrit=true
        critHurtRaito=(1.8+critRatio)*_Assailant.m_critHurt
    --     print("发生暴击 critHurtRaito=",critHurtRaito)
    -- else
    --     print("没有发生暴击 critHurtRaito=",critHurtRaito)
    end

    local hurtValue = 0
    if (_Assailant:getType() == _G.Const.CONST_PLAYER or _Assailant:getType() == _G.Const.CONST_PARTNER) and _Victim:getType() == _G.Const.CONST_MONSTER then


        local monsterData=_G.StageXMLManager:getMonsterData(_Victim.m_monsterId)

        local monsterLv =100
        if monsterData and monsterData.lv then
            monsterLv=monsterData.lv
        -- else
        --     CCLOG("战斗计算公式，没有技能数据 _skillId=%d",_skillId)
        end

        local assailantLv=assailantProperty:getLv()
        if _Assailant.m_nType == _G.Const.CONST_PARTNER then
            local playerCharacter = _G.CharacterManager:getPlayerByID(assailantProperty:getUid())
            if playerCharacter~=nil and playerCharacter.m_property~=nil then
                assailantLv=playerCharacter.m_property:getLv()
            end
        end
        -- print("monsterLv",monsterLv,assailantLv)
        --if(暴击，暴击伤害系数，1)*0.025*min(10,max(10+自身等级-目标等级，4))*攻击*破甲/护甲*技能效果系数+技能常数伤害
        -- hurtValue=critHurtRaito*0.025*__mathMin(10,__mathMax(10+assailantLv-monsterLv,4))*assailantAttack*assailantWreck/victimDefend*skillAttackRatio*(1+assailantBonus-victimReduction)+skillAttackConst
    
        --if(暴击，暴击伤害系数，1)*0.1*min(10,max(10+自身等级-目标等级，4))*(max(0.5*自身攻击-0.5*对方防御,0)+0.25*自身破甲)*技能效果系数*（1+伤害率-免伤率）+技能常数伤害
        -- victimData.skillAttackValue=0.1*__mathMin(10,__mathMax(10+assailantLv-monsterLv,4))*(__mathMax(0.3*(assailantAttack-victimDefend),0)+0.25*assailantWreck)*skillAttackRatio*(1+assailantBonus-victimReduction)
        local Bonus = 1+(assailantBonus-victimReduction)
        Bonus = Bonus > 0 and Bonus or 0
        victimData.skillAttackValue=0.04*__mathMin(25,__mathMax(25+assailantLv-monsterLv,5))*(assailantAttack*assailantWreck/(4*assailantAttack+4*assailantWreck+2*victimDefend)*skillAttackRatio*Bonus+skillAttackConst)
        victimData.skillAttackConst=skillAttackConst
        hurtValue=critHurtRaito*victimData.skillAttackValue
        -- hurtValue=critHurtRaito*0.1*__mathMin(10,__mathMax(10+assailantLv-monsterLv,4))*(__mathMax(0.3*(assailantAttack-victimDefend),0)+0.25*assailantWreck)*skillAttackRatio*(1+assailantBonus-victimReduction)+skillAttackConst

        -- print(0.04*__mathMin(25,__mathMax(25+assailantLv-monsterLv,5)),"player~~~~~")
    elseif (_Victim:getType() == _G.Const.CONST_PLAYER or  _Victim:getType() == _G.Const.CONST_PARTNER) and _Assailant:getType() == _G.Const.CONST_MONSTER then

        local monsterData=_G.StageXMLManager:getMonsterData(_Assailant.m_monsterId)

        local monsterLv =100
        if monsterData and monsterData.lv then
            monsterLv=monsterData.lv
        -- else
        --     CCLOG("战斗计算公式，没有技能数据 _skillId=%d",_skillId)
        end

        local assailantLv=victimProperty:getLv()
        if _Victim.m_nType == _G.Const.CONST_PARTNER then
            local playerCharacter = _G.CharacterManager:getPlayerByID(victimProperty:getUid())
            if playerCharacter~=nil and playerCharacter.m_property~=nil then
                assailantLv=playerCharacter.m_property:getLv()
            end
        end

        -- print("monsterLv",monsterLv,assailantLv)
        --if(暴击，暴击伤害系数，1)*0.025*min(10,max(10+自身等级-目标等级，4))*攻击*破甲/护甲*技能效果系数+技能常数伤害
        -- hurtValue=critHurtRaito*0.025*__mathMin(10,__mathMax(10+assailantLv-monsterLv,4))*assailantAttack*assailantWreck/victimDefend*skillAttackRatio*(1+assailantBonus-victimReduction)+skillAttackConst
    
        --if(暴击，暴击伤害系数，1)*0.1*min(10,max(10+自身等级-目标等级，4))*(max(0.5*自身攻击-0.5*对方防御,0)+0.25*自身破甲)*技能效果系数*（1+伤害率-免伤率）+技能常数伤害
        -- victimData.skillAttackValue=0.1*__mathMin(10,__mathMax(10+assailantLv-monsterLv,4))*(__mathMax(0.3*(assailantAttack-victimDefend),0)+0.25*assailantWreck)*skillAttackRatio*(1+assailantBonus-victimReduction)
        local Bonus = 1+(assailantBonus-victimReduction)
        Bonus = Bonus > 0 and Bonus or 0
        victimData.skillAttackValue=__mathPow(1.2,__mathMax(monsterLv-assailantLv,0))*(assailantAttack*assailantWreck/(4*assailantAttack+4*assailantWreck+2*victimDefend)*skillAttackRatio*Bonus+skillAttackConst)
        victimData.skillAttackConst=skillAttackConst
        hurtValue=critHurtRaito*victimData.skillAttackValue
        -- hurtValue=critHurtRaito*0.1*__mathMin(10,__mathMax(10+assailantLv-monsterLv,4))*(__mathMax(0.3*(assailantAttack-victimDefend),0)+0.25*assailantWreck)*skillAttackRatio*(1+assailantBonus-victimReduction)+skillAttackConst
        -- print(__mathPow(1.2,__mathMax(monsterLv-assailantLv,0)),__mathMax(monsterLv-assailantLv,0),"monster~~~~")
    else
        local Bonus = 1+(assailantBonus-victimReduction)
        Bonus = Bonus > 0 and Bonus or 0
        victimData.skillAttackValue=assailantAttack*assailantWreck/(4*assailantAttack+4*assailantWreck+2*victimDefend)*skillAttackRatio*Bonus+skillAttackConst
        victimData.skillAttackConst=skillAttackConst
        hurtValue=critHurtRaito*victimData.skillAttackValue
    end
    -- print(critHurtRaito,victimData.skillAttackValue,victimData.skillAttackConst,assailantAttack*assailantWreck/(4*assailantAttack+4*assailantWreck+2*victimDefend),skillAttackRatio,(1+(assailantBonus-victimReduction)))
    -- if _Victim:getType() == _G.Const.CONST_PLAYER or _Victim:getType() == _G.Const.CONST_PARTNER then
    --     --if(暴击，暴击伤害系数，1)*攻击*破甲/护甲*技能效果系数*(1+伤害率-免伤率)+技能常数伤害
    --     -- hurtValue=critHurtRaito*assailantAttack*assailantWreck/victimDefend*skillAttackRatio*(1+assailantBonus-victimReduction)/4+skillAttackConst

    --     --if(暴击，暴击伤害系数，1)*(max(0.5*自身攻击-0.5*对方防御,0)+0.25*自身破甲)*技能效果系数*（1+伤害率-免伤率）+技能常数伤害
    --     --自身的攻击*自身破甲/（自身攻击+自身破甲+对方防御）

    --     -- victimData.skillAttackValue=(__mathMax(0.3*(assailantAttack-victimDefend),0) +0.25*assailantWreck)*skillAttackRatio*(1+assailantBonus-victimReduction)
    --     victimData.skillAttackValue=assailantAttack*assailantWreck/(assailantAttack+assailantWreck+victimDefend)*skillAttackRatio*(1+(assailantBonus-victimReduction)*0.5)
    --     victimData.skillAttackConst=skillAttackConst
    --     hurtValue=critHurtRaito*victimData.skillAttackValue+victimData.skillAttackConst
    --     -- hurtValue=critHurtRaito*(__mathMax(0.3*(assailantAttack-victimDefend),0) +0.25*assailantWreck)*skillAttackRatio*(1+assailantBonus-victimReduction)+skillAttackConst

    --     -- print("critHurtRaito=",critHurtRaito)
    --     -- print("assailantAttack=",assailantAttack)
    --     -- print("assailantWreck=",assailantWreck)
    --     -- print("victimDefend=",victimDefend)
    --     -- print("skillAttackRatio=",skillAttackRatio)
    --     -- print("assailantBonus=",assailantBonus)
    --     -- print("victimReduction=",victimReduction)
    --     -- print("skillAttackConst=",skillAttackConst)
        
    -- else
    --     local monsterData=_G.StageXMLManager:getMonsterData(_Victim.m_monsterId)

    --     local monsterLv =100
    --     if monsterData and monsterData.lv then
    --         monsterLv=monsterData.lv
    --     -- else
    --     --     CCLOG("战斗计算公式，没有技能数据 _skillId=%d",_skillId)
    --     end

    --     local assailantLv=assailantProperty:getLv()
    --     if _Assailant.m_nType == _G.Const.CONST_PARTNER then
    --         local playerCharacter = _G.CharacterManager:getPlayerByID(assailantProperty:getUid())
    --         if playerCharacter~=nil and playerCharacter.m_property~=nil then
    --             assailantLv=playerCharacter.m_property:getLv()
    --         end
    --     end

    --     --if(暴击，暴击伤害系数，1)*0.025*min(10,max(10+自身等级-目标等级，4))*攻击*破甲/护甲*技能效果系数+技能常数伤害
    --     -- hurtValue=critHurtRaito*0.025*__mathMin(10,__mathMax(10+assailantLv-monsterLv,4))*assailantAttack*assailantWreck/victimDefend*skillAttackRatio*(1+assailantBonus-victimReduction)+skillAttackConst
    
    --     --if(暴击，暴击伤害系数，1)*0.1*min(10,max(10+自身等级-目标等级，4))*(max(0.5*自身攻击-0.5*对方防御,0)+0.25*自身破甲)*技能效果系数*（1+伤害率-免伤率）+技能常数伤害
    --     -- victimData.skillAttackValue=0.1*__mathMin(10,__mathMax(10+assailantLv-monsterLv,4))*(__mathMax(0.3*(assailantAttack-victimDefend),0)+0.25*assailantWreck)*skillAttackRatio*(1+assailantBonus-victimReduction)
    --     victimData.skillAttackValue=0.05*__mathMin(20,__mathMax(20+assailantLv-monsterLv,3))*assailantAttack*assailantWreck/(assailantAttack+assailantWreck+victimDefend)*skillAttackRatio*(1+(assailantBonus-victimReduction)*0.5)
    --     victimData.skillAttackConst=skillAttackConst
    --     hurtValue=critHurtRaito*victimData.skillAttackValue+victimData.skillAttackConst
    --     -- hurtValue=critHurtRaito*0.1*__mathMin(10,__mathMax(10+assailantLv-monsterLv,4))*(__mathMax(0.3*(assailantAttack-victimDefend),0)+0.25*assailantWreck)*skillAttackRatio*(1+assailantBonus-victimReduction)+skillAttackConst

    -- end
    -- CCLOG("SkillHurt.compute  hurtValue=%d",hurtValue)
    hurtValue=__mathCeil(hurtValue)
    resultData.isOccurCrit=isOccurCrit
    resultData.hurtValue=__mathCeil(hurtValue*_currentFrame.percent)

    if _Assailant.lingYaoCamp and _Victim.lingYaoCamp then
        if (_Assailant.lingYaoCamp==_G.Const.CONST_PAR_ARENA_LING and _Victim.lingYaoCamp==_G.Const.CONST_PAR_ARENA_SHENG) 
            or (_Assailant.lingYaoCamp==_G.Const.CONST_PAR_ARENA_SHENG and _Victim.lingYaoCamp==_G.Const.CONST_PAR_ARENA_AN)
            or (_Assailant.lingYaoCamp==_G.Const.CONST_PAR_ARENA_AN and _Victim.lingYaoCamp==_G.Const.CONST_PAR_ARENA_LING) then

            -- print("YYYYYYYYYYYYYYYYY=====>>>>克制。。。。。",resultData.hurtValue,__mathCeil(resultData.hurtValue*(1+_G.Const.CONST_PAR_ARENA_KEZHI*0.01)))
            resultData.hurtValue=__mathCeil(resultData.hurtValue*(1+_G.Const.CONST_PAR_ARENA_KEZHI*0.01))
        end
    end

    -- print("hurtValue!!!!!!!",hurtValue)
    return resultData,hurtValue
end