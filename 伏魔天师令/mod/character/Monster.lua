CMonster = classGc(CBaseCharacter,function(self,_nType)
    self.m_nType=_nType --人物／npc
    self.m_stageView=_G.g_Stage
    self:initAI()
end)
 
--AI相关参数
function CMonster.initAI( self )
    self.m_fTraceDistance = 600     --追踪距离
    self.m_fLastThinkTime =0
    self.m_fLastAttackTime =0
    self.m_fLastTraceTime=0
end

function CMonster.monsterInit( self,uid,monsterId,_xml, _x, _y, _skinID, _monsterName, _type,_direction)
    self.m_monsterId=monsterId

    self.m_scale = _xml.suofang / 10000
    self.m_nMoveSpeedX = _xml.speedx
    self.m_nMoveSpeedY = _xml.speedy
    self.m_hpNum       = _xml.boss_hp
    self.m_noFly       = _xml.fly==1 and true or nil

    local attr = _xml.attr
    self : init(uid,
                _monsterName or _xml.monster_name,
                attr.hp,
                attr.hp,
                attr.sp,
                attr.sp,
                _x,
                _y,
                _skinID or _xml.skin,_type,_xml.appera_skill)

    self.m_nMaxTenacity =_xml.toughness
    self.m_toughnessBuff=_xml.buffs
    -- self.m_drop_goods=_xml.drop_goods
    self.m_patrolRatio=_xml.xunluo
    self.m_canBreak=_xml.b
    self.m_deadBuffTarget=_xml.buff_target
    self.m_deadBuff=_xml.dead_buff
    self.m_head_icon=_xml.head_icon

    self.m_fThinkInterval = _xml.fanying*1000
    self.m_fAttackInterval = _xml.jiange*1000
    local sceneType = self.m_stageView.m_sceneType 
    if not(sceneType== _G.Const.CONST_MAP_TYPE_BOSS 
        or sceneType==_G.Const.CONST_MAP_CLAN_DEFENSE
        or sceneType==_G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER
        or sceneType==_G.Const.CONST_MAP_TYPE_CITY_BOSS
        or sceneType==_G.Const.CONST_MAP_TYPE_CLAN_BOSS
        or sceneType==_G.Const.CONST_MAP_TYPE_COPY_BOX) then
        self:setAI(_xml.ai)
    -- elseif sceneType==_G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
    --     local aiData=_G.g_CnfDataManager:getSkillAIData(_xml.ai)
    --     self.m_lpAINode=aiData
    end
    self.m_climb=_xml.qishen~=0 and _xml.qishen or nil
    self.m_climbBuff=_xml.qishenbuff~=0 and _xml.qishenbuff or nil
    self.m_triggerHp=_xml.hp_pre==0 and nil or _xml.hp_pre
    self.m_skillCDCall=function()
        self:clearAiAttackSkill()
    end
    self.m_triggerAI=_xml.hp_ai
    -- self.m_preSkillNumData=_xml.pre_skill
    self:setLv(_xml.lv)
    if _xml.big_hp == 0 then
        self:addBigHpView()
    end
    if self.m_nMaxTenacity==0 then
        local invBuff= _G.GBuffManager:getBuffNewObject(1401, 0)
        self:addBuff(invBuff) 
    end
    -- self:setProtect()
    local property = self:getProperty()
    if property ~= nil then
        property:setAI(_xml.ai)
        self:setWarAttr(property:getAttr())
        -- local strong_att         = property:getAttr() :getStrongAtt() or 0  --攻击
        -- local strong_def         = property:getAttr() :getStrongDef() or 0  --防御
        -- local crit               = property:getAttr() :getCrit() or 0       --暴击值(万分比)
        -- local crit_res           = property:getAttr() :getCritRes() or 0    --抗暴值(万分比)
        -- local wreck              = property:getAttr() :getWreck() or 0      --破甲值(万分比)
        -- local sp                 = property:getAttr() :getSp() or 0         -- {怒气}
        -- local dodge              = property:getAttr() :getDodge() or 0      -- {躲避值}
        -- local hit                = property:getAttr() :getHit() or 0        -- {命中值}

        -- local bonus              = property:getAttr() :getBonus() or 0      -- {伤害率}
        -- local reduction          = property:getAttr() :getReduction() or 0  
        -- print(strong_att,strong_def,crit,crit_res,wreck,dodge,hit,bonus,reduction,"monsterInit")
    end
    if _direction~=nil then
        self:setMoveClipContainerScalex(_direction)
    end
    if self.m_stageView.m_playPowerful~=nil then
        self:updateWarAttr(self.m_stageView.m_playPowerful)
    end
    if _xml.chuchang then
        _G.Util:playAudioEffect(_xml.chuchang)
    end

    if self.m_lpMovieClip and _xml.hidden_effect and type(_xml.hidden_effect)=="table" and self.m_lpMovieClip.addSoltHideName then
        for i=1,#_xml.hidden_effect do
            self.m_lpMovieClip:addSoltHideName(_xml.hidden_effect[i])
        end
    end
end

function CMonster.showBody(self,_skinID)

    if self.m_lpContainer==nil or _skinID==nil or _skinID==0 then return end
    -- self.m_lpMovieClipContainer:setPosition(cc.p(0,0))

    local function onCallFunc(event)
        self:animationCallFunc(event.type,event.animation,event)
    end

    local skinIdStr = "spine/".._skinID

    self.m_lpMovieClip=_G.SpineManager.createSpine(skinIdStr,self.m_skinScale)

    if self.m_lpMovieClip==nil then
        -- print("lua error CPlayer.showBody self.m_normalName=",skinIdStr)
        self.m_lpMovieClip=_G.SpineManager.createSpine("spine/20001",self.m_skinScale)
        self.m_isNoRes=true
    end
    if self.m_backMap~=nil then
        self.m_backBody=_G.SpineManager.createSpine(string.format("%s%s",skinIdStr,"_body"),self.m_skinScale)
        self.m_backBody:setPosition(self.m_nLocationX,self.m_nLocationY)
        -- self.m_backBody:setScaleX(self.m_nScaleX*self.m_skinScale)
        self.m_stageView.m_lpStageContainer:addChild(self.m_backBody,99)
    end
    self.m_lpMovieClip:registerSpineEventHandler(onCallFunc,2)
    self.m_lpMovieClip:registerSpineEventHandler(onCallFunc,3)
    self.m_lpMovieClipContainer:addChild(self.m_lpMovieClip)

    self.m_nStatus = -100
    self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)

    -- if self.m_lpMovieClip~=nil and self.m_lpMovieClip.getSkeletonSize~=nil then
    --     self.m_skeletonHeight=self.m_lpMovieClip:getSkeletonSize().height*self.m_skinScale
    -- end

    -- self.m_skeletonHeight=self.m_skeletonHeight*self.m_scale * self.m_skinScale 
    -- self.m_lpMovieClip:setOpacity(100)

    CCLOG("CMonster.loadMovieClip success")
end

function CMonster.releaseResource( self )
    self:releaseSkillResource()
    self:destoryBigHpView()
    self:removeAllClones()
    if self.m_lpContainer~=nil then
        if self.m_isCorpse then return end
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
    
    GCLOG("CMonster.releaseResource====>>>>self.m_nID=%d",self.m_nID)
end

--怪物等阶
function CMonster.setMonsterRank( self,_rank )
    self.m_nMonsterRank = _rank
end

function CMonster.getMonsterRank( self )
    return self.m_nMonsterRank
end

--重写析构
-- function CMonster.onDestory(self)
--     self.m_nAI = nil
--     self.m_lpAINode = nil
-- end

function CMonster.setAI( self, _AI )
    -- print("CMonster.setAI _AI=",_AI,debug.traceback())
    self.m_nAI = _AI or self.m_preAi
    self.m_nNextSkillID = 0
    -- self.m_nNextSkillID2 = 0
    -- self.m_nNextSkillID3 = 0

    if _AI==nil or _AI == 0 then
        return
    else
       -- 调试信息（蓝块）

        if _G.SysInfo:isIpNetwork() then
            if not self.aiBlockLayer then
                self.aiBlockLayer=cc.LayerColor:create(cc.c4b(0,0,255,50))
                self.aiBlockLayer:setContentSize(cc.size(0,0))
                self.m_lpContainer:addChild(self.aiBlockLayer)
                self.aiBlockLayer:setVisible(false)
            end
        end
    end

    local aiData=_G.g_CnfDataManager:getSkillAIData(_AI)
    if aiData==nil then
        -- CCMessageBox("monsterAI : ".._AI, "ERROR INIT MONSTER")
        CCLOG("lua error codeError!!!!  monsterAI : ".._AI )
        -- error("_____________")
        self.m_nAI =nil
        return
    end
    
    -- CCLOG("self.m_lpAINode.reaction_time=%f  self.m_nAI=%d",aiData.reaction_time,self.m_nAI)
    -- self.m_fThinkInterval = aiData.reaction_time*1000
    -- self.m_fAttackInterval = aiData.attack_interval*1000

    self.m_fThinkInterval = self.m_fThinkInterval or aiData.reaction_time*1000
    self.m_fAttackInterval = self.m_fAttackInterval or aiData.attack_interval*1000

    self.m_fTraceDistance =aiData.view

    self.m_lpAINode=aiData

    -- 攻击目标策略
    local attackFashion=aiData.attack_fashion
    local szFactionName=string.format("gotoFight%d",attackFashion)
    if self[szFactionName]~=nil then
        self.gotoFight=self[szFactionName]
    end

    -- 躲避策略
    for i=1,#aiData.dodge_fashion do
        local tempData=aiData.dodge_fashion[i]
        if tempData[1]==1 and tempData[2]>0 then
            self.m_fashionDodgoSkillId=tempData[2]
        end
    end

    self.m_isFirstRun=true

    if not self.m_preAi then
        self.m_preAi=_AI
    end
end


function CMonster.setAIBlockWithCollider(self,collider,_isAction)
    if collider==nil then return end

    self.aiCollider=collider

    if self.aiBlockLayer==nil then
        return
    end

    local offsetX,offsetY,vWidth,vHeight=collider.offsetX,collider.offsetY,collider.vWidth,collider.vHeight
    local scaleX = self.m_lpCharacterContainer:getScaleX()
    if scaleX > 0 then
        offsetX = offsetX
    else
        offsetX = offsetX * scaleX - vWidth
    end
    
    self.aiBlockLayer:setContentSize(cc.size(vWidth,vHeight))
    self.aiBlockLayer:setPosition(offsetX,offsetY)

    if _isAction then
        self.aiBlockLayer:setColor(cc.c4b(125,47,198,50))
        self.aiBlockLayer:setOpacity(120)
        -- self.aiBlockLayer:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.2,200),cc.FadeTo:create(0.2,50))))
    end
end

function CMonster.getAI( self )
    return self.m_nAI
end

function CMonster.getLv( self )
    return self.m_nLv
end

function CMonster.setLv( self, _nLv )
    self.m_nLv = _nLv
end
function CMonster.resetNamePos( self )
    if self.m_lpMonsterHpView == nil then return end
    self.m_lpMonsterHpView:setPosition(0,self.m_skeletonHeight+5+self.m_nLocationZ)
end

function CMonster.produceAttackSkillDatas(self)

    if self.m_attackSkillDatas then
        return
    end
    self.m_attackSkillDatas={}
    
    local property = self.m_property

    if not self.m_lpAINode then
        CCLOG("lua error CMonster.produceAttackSkillDatas 没有ai数据")
        return
    end

    local skillData=property:getSkillData()
    if not skillData then
        CCLOG("lua error CMonster.produceAttackSkillDatas skillData==nil")
        return
    end

    local attack_skills=self.m_lpAINode.attack_skill
    -- local attack_skill=nil
    if attack_skills~=nil and #attack_skills>=1 then
        local attack_skill=attack_skills[1]
        local attackSkillData = {}
        attackSkillData.sp=0
        attackSkillData.attack_skill=attack_skill
        self.m_attackSkillDatas[1]=attackSkillData
    end

    for _,skill_equip in pairs(skillData.skill_equip_list) do
        local selectSkillId = skill_equip.skill_id
        if selectSkillId and selectSkillId>0 and skill_equip.equip_pos<5 then
            local skillNode =_G.g_SkillDataManager:getSkillIdToId(selectSkillId)
            if skillNode then
                local sp = skillNode.sp
                local attackSkillData = {}
                attackSkillData.skillId=selectSkillId
                attackSkillData.sp=sp

                local attack_skill=nil
                for _,skill_data in pairs(attack_skills) do
                    if skill_data[2]==0 and selectSkillId==skill_data[1] then
                        attack_skill=skill_data
                        break
                    end
                end

                if attack_skill then
                    attackSkillData.attack_skill=attack_skill
                    self.m_attackSkillDatas[selectSkillId]=attackSkillData
                else
                    print("lua error AI没有该技能数据 selectSkillId=",selectSkillId)
                end
            else
                print("lua error SkillEffect没有数据 selectSkillId=",selectSkillId)
            end
        end
    end

    for skillId,attackSkillData in pairs(self.m_attackSkillDatas) do
        local colliderId = attackSkillData.attack_skill[1]
        local colliderData=_G.g_SkillDataManager:getAttackSkillCollider(colliderId)
        if not colliderData then
            print("lua error AI的碰撞区域数据找不到 colliderId=",colliderId)
            colliderData=_G.g_SkillDataManager:getSkillCollider(1)
        end

        attackSkillData.attackCollider={
            offsetX=colliderData.offsetX*self.m_nScaleXPer,
            offsetY=colliderData.offsetY*self.m_nScaleXPer,
            vWidth=colliderData.vWidth*self.m_nScaleXPer,
            vHeight=colliderData.vHeight*self.m_nScaleXPer,
        }

        attackSkillData.traceCollider={
            offsetX=(colliderData.offsetX+5)*self.m_nScaleXPer,
            offsetY=(colliderData.offsetY+5)*self.m_nScaleXPer,
            vWidth=(colliderData.vWidth-10)*self.m_nScaleXPer,
            vHeight=(colliderData.vHeight-10)*self.m_nScaleXPer,
        }
    end
end

-- function CMonster.getAvailableSkill(self)
--     local property = self:getProperty()

--     local attackSkillData = {}

--     local attack_skill=nil
--     local attack_skills=self.m_lpAINode.attack_skill

--     if not attack_skills then
--         return attackSkillData
--     end
--     if #attack_skills==1 then
--         attack_skill=attack_skills[1]
--     else
--         if self:getType() == _G.Const.CONST_PLAYER then
--             local skillData=property:getSkillData()
--             if skillData==nil then
--                 CCLOG("CMonster.getAvailableSkill skillData==nil")
--                 return
--             end

--             local selectSkillId = nil
--             for _,skill_equip in pairs(skillData.skill_equip_list) do
--                 local sp=0
--                 local skillNode =_G.g_SkillDataManager:getSkillEffect(skill_equip.skill_id)
--                 if skillNode ~= nil then
--                     sp = skillNode.sp
--                 end

--                 if self:canSubSp(-sp) and not self:isSkillCD(skill_equip.skill_id) then
--                     selectSkillId=skill_equip.skill_id
--                     break
--                 end
--             end
            
--             if selectSkillId then
--                 for _,skill_data in pairs(attack_skills) do
--                     if skill_data[2]==0 and selectSkillId==skill_data[1] then
--                         attack_skill=skill_data
--                         break
--                     end
--                 end
--             end

--             if not attack_skill then
--                 attack_skill=attack_skills[1]
--             end
--         end
--     end

    
--     if attack_skill then
--         attackSkillData.sp=0
--         attackSkillData.attack_skill=attack_skill

--         local colliderId =attack_skill[1]

--         local colliderData=_G.g_SkillDataManager:getAttackSkillCollider(colliderId)
--         if not colliderData then
--             CCMessageBox(_G.Language.ERROR_N[15].." colliderId="..colliderId,"ERROR")
--             colliderData=_G.g_SkillDataManager:getSkillCollider(1)
--         end

--         attackSkillData.attackCollider={
--             offsetX=colliderData.offsetX,
--             offsetY=colliderData.offsetY,
--             vWidth=colliderData.vWidth,
--             vHeight=colliderData.vHeight,
--         }

--         attackSkillData.traceCollider={
--             offsetX=colliderData.offsetX+5,
--             offsetY=colliderData.offsetY+10,
--             vWidth=colliderData.vWidth-30,
--             vHeight=colliderData.vHeight-10,
--         }
--     end

--     return attackSkillData
-- end

function CMonster.getAllAttackSkill(self)
    if self.m_attackSkillDatas then
        return
    end
    self.m_attackSkillDatas={}
    local attack_skills=self.m_lpAINode.attack_skill
    if not attack_skills then return end
    for _,attack_skill in pairs(attack_skills) do
        local attackSkillData = {}
        attackSkillData.sp=0
        attackSkillData.attack_skill=attack_skill

        local colliderId =attack_skill[1]

        local colliderData=_G.g_SkillDataManager:getAttackSkillCollider(colliderId)
        if not colliderData then
            -- CCMessageBox("AI的碰撞区域数据找不到 colliderId="..colliderId,"ERROR")
            print("lua error AI的碰撞区域数据找不到 colliderId=",colliderId)
            colliderData=_G.g_SkillDataManager:getSkillCollider(1)
        end

        attackSkillData.attackCollider={
            offsetX=colliderData.offsetX*self.m_nScaleXPer,
            offsetY=colliderData.offsetY*self.m_nScaleXPer,
            vWidth=colliderData.vWidth*self.m_nScaleXPer,
            vHeight=colliderData.vHeight*self.m_nScaleXPer,
        }

        attackSkillData.traceCollider={
            offsetX=(colliderData.offsetX+5)*self.m_nScaleXPer,
            offsetY=(colliderData.offsetY+5)*self.m_nScaleXPer,
            vWidth=(colliderData.vWidth-10)*self.m_nScaleXPer,
            vHeight=(colliderData.vHeight-10)*self.m_nScaleXPer,
        }

        self.m_attackSkillDatas[attack_skill[1]]=attackSkillData
    end
end

function CMonster.findNearTarget(self)
    local property = self:getProperty()
    if not property then
        CCLOG("CMonster.findNearTarget 找不到属性")
        return
    end
    --查找场景中所有对象
    local charList = _G.CharacterManager:getNoHookCharacter()
    local target = nil
    local maxDist = 100000000
    for k,char in pairs(charList) do
        --查找距离最近的进行攻击
        --查找不同队伍的对象打
        local charProperty = char:getProperty()
        if charProperty and not(charProperty:getTeamID() == property:getTeamID()
            or char.m_nStatus==_G.Const.CONST_BATTLE_STATUS_DEAD 
            or char.m_nType==_G.Const.CONST_GOODS_MONSTER)
        then
            dist = math.pow(self.m_nLocationX  - char.m_nLocationX , 2) + math.pow(self.m_nLocationY - char.m_nLocationY, 2)

            if dist < self.m_fTraceDistance*self.m_fTraceDistance then --判断出生点与距离
                --下面是找到最近距离的
                if dist < maxDist then
                    maxDist = dist
                    target = char
                end
            end
        end
    end
    return target
end

function CMonster.evade(self,forceEvade)
    math.randomseed(gc.MathGc:random_0_1())
    -- if forceEvade~=true then
    --     if math.random(0,100)>self.m_patrolRatio then
    --         return
    --     end
    -- end

    local randTypes = self.m_lpAINode.rand_type
    local rand_x = self.m_lpAINode.rand_x
    local rand_y = self.m_lpAINode.rand_y

    local selfx = self.m_nLocationX
    local selfy = self.m_nLocationY

    local randIndex = math.random(1,#randTypes) -- math.ceil(#randTypes*gc.MathGc:random_0_1())
    randValue=randTypes[randIndex]

    self.m_fLastThinkTime=self.m_fLastThinkTime+1000

    if randValue==5 and not self.m_nTarget then
        randValue=4
    end

    if randValue==1 then
        return
    elseif randValue==2 then
        local temRandX=rand_x*0.5
        selfx=selfx+math.random(-temRandX,temRandX)

    elseif randValue==3 then
        local temRandX=rand_x*0.5
        local temRandY=rand_y*0.5

        selfx=selfx+math.random(-temRandX,temRandX)
        selfy=selfy+math.random(-temRandY,temRandY)

    elseif randValue==4 then
        selfx = self.m_nLocationX+math.random(-rand_x,rand_x)
        local mapmaxy,mapminy = self.m_stageView:getMapLimitHeight(selfx)
        selfy = math.random(mapminy,mapmaxy)
    elseif randValue==5 then
        local subX=math.abs(self.m_nLocationX-self.m_nTarget.m_nLocationX)
        local tempDis=400

        if subX>tempDis and subX<rand_x+tempDis then
            if math.random(-10,10)<0 then
                return
            end
        end

        local lx = self.m_stageView:getMaplx()
        local rx = self.m_stageView:getMaprx()

        local isLeft
        if self.m_nTarget.m_nLocationX-tempDis<lx then
            isLeft=false
        elseif self.m_nTarget.m_nLocationX+tempDis>rx then
            isLeft=true
        else
            isLeft=self.m_nLocationX<self.m_nTarget.m_nLocationX
            -- if math.random(1,20)<8 then
            --     isLeft=not isLeft
            -- end
        end

        if isLeft then
            -- 往左边跑
            local maxX=self.m_nTarget.m_nLocationX-tempDis
            local minX=maxX-rand_x
            minX=minX<lx and lx or minX
            selfx=math.random(minX,maxX)

            local mapmaxy,mapminy = self.m_stageView:getMapLimitHeight(selfx)
            selfy=math.random(mapminy,mapmaxy)
        else
            -- 往右边跑
            local minX=self.m_nTarget.m_nLocationX+tempDis
            local maxX=minX+rand_x
            maxX=maxX>rx and rx or maxX
            selfx=math.random(minX,maxX)

            local mapmaxy,mapminy = self.m_stageView:getMapLimitHeight(selfx)
            selfy=math.random(mapminy,mapmaxy)
        end
    end
    
    -- print("CMonster.evade========>>>>>>",selfx,selfy,self:getLocationXY(),debug.traceback())
    self:setMovePos(cc.p(selfx,selfy))
end

function CMonster.removeThink(self)
    self.think=false
end
function CMonster.think( self, _now )
    if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_STOP_ACTION) then
        return
    end
    if not self.m_nAI or self.m_nAI == 0 then
        return
    end
    --判断是否有反应
	if _now - self.m_fLastThinkTime<self.m_fThinkInterval then  
        return
    end
    self:runTheAI(_now)
end

function CMonster.runTheAI( self, _now )
    local property = self:getProperty()
    if property==nil then
        print("code error CMonster.runTheAI找不到属性",self.m_monsterId)
        return
    end
    
    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_FALL or
        self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_CRASH then
        return
    end

    if (self.m_nSkillID and self.m_nSkillID > 0) 
        or (self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_MOVE and not self.m_attackSkillData) 
        or self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL then
        return
    end

    self.m_fLastThinkTime = _now

    if _now-self.m_fLastAttackTime<self.m_fAttackInterval then
        self:evade()
        return
    end

    if self.m_nTarget==nil then
        self.m_nTarget = self:findNearTarget()
    elseif self.m_nTarget.m_nStatus == _G.Const.CONST_BATTLE_STATUS_DEAD then
        self.m_nTarget = self:findNearTarget()
    end

    if self.m_nTarget==nil then
        self:evade()
        return
    end

    if not self.m_attackSkillDatas then
        self:getAllAttackSkill()
        if not self.m_attackSkillDatas then
            self:evade()
            return
        end
    end

    if _now-self.m_fLastTraceTime>1000 and
        math.abs(self.m_nLocationX-self.m_nTarget.m_nLocationX)<=100 and
        math.abs(self.m_nLocationY-self.m_nTarget.m_nLocationY)<=80 then

        self.m_fLastTraceTime=_now

        -- math.randomseed(_G.TimeUtil:getNowSeconds())

        if math.random()>0.5 then
            local lx = self.m_stageView:getMaplx()
            if self.m_nLocationX<lx+150 then
                local moveX = self.m_nLocationX+math.random(0,150)+300
                self:setMovePos(cc.p(moveX,self.m_nLocationY))
                return
            end
            
            local rx = self.m_stageView:getMaprx()
            if self.m_nLocationX>rx-150 then
                moveX = self.m_nLocationX-math.random(0,150)-300
                self:setMovePos(cc.p(moveX,self.m_nLocationY))
                return
            end

            local directTarget=self:getDirectWithThis(self.m_nTarget)
                if directTarget>0 then
                    local moveX = 0
                    if self.m_nLocationX<lx+150 then
                        moveX = self.m_nLocationX+math.random(0,150)+300
                    else
                        moveX = self.m_nLocationX-150-150
                    end
                    self:setMovePos(cc.p(moveX,self.m_nLocationY))
                else
                    local moveX = 0
                    if self.m_nLocationX>rx-150 then
                        moveX = self.m_nLocationX-math.random(0,150)-300
                    else
                        moveX = self.m_nLocationX+150+150
                    end
                    self:setMovePos(cc.p(moveX,self.m_nLocationY))
                end
            return
        end
    end
    
    self:gotoFight(_now)
end

function CMonster.stopFight(self)
    self:setStatus( _G.Const.CONST_BATTLE_STATUS_IDLE)
    self.m_nSkillID = 0
    self.m_nNextSkillID =0
    self.m_nNextSkillID2 = 0
    self.m_nNextSkillID3 = 0
end

function CMonster.closeToTarget(self)
    if not self.m_attackSkillData then return end

    local chX,chY,chWidth,chHeight = self.m_nTarget:getWorldCollider()
    if not chX or not chY or not chWidth or not chHeight then
        print("lua error CMonster.gotoFight m_nTarget:getWorldCollider==nil self.m_nTarget.m_SkinId=",self.m_nTarget.m_SkinId)
        self.m_nTarget=nil
        return
    end

    local targetCenterX=chX+chWidth*0.5
    local targetCenterY=chY+chHeight*0.5

    local _collider = self.m_attackSkillData.traceCollider
    self:setAIBlockWithCollider(_collider,true)
    
    local cX, cY,_,cWidth, cHeight = self:getConvertCollider(_collider)
    if not cX or not cY or not cWidth or not cHeight then
        print("lua error CMonster.gotoFight getConvertCollider(_collider)==nil m_SkinId=",self.m_SkinId)
        self.m_nTarget=nil
        return
    end

    local cWidth = cWidth-math.random(0,50)
    local seftCenterX = cX+cWidth/2
    local seftCenterY = cY+cHeight/2

    local moveXDelta = targetCenterX - seftCenterX
    local moveYDelta = 0
    if cY + cHeight < chY or chY + chHeight < cY then
        local tempHei=(chHeight+cHeight)/2*0.9
        moveYDelta = targetCenterY - seftCenterY+math.random(-tempHei,tempHei)
    end

    local offMoveX = (chWidth+cWidth)*(0.5-math.random(0,15)*0.01)
    if moveXDelta>0 then
        moveXDelta = moveXDelta - offMoveX
    else
        moveXDelta = moveXDelta + offMoveX
    end

    if self.m_nType==_G.Const.CONST_PARTNER and math.abs(moveXDelta)>_G.Const.CONST_WAR_PARTNER_DISTANCE then return end
    
    local selfx,selfy= self:getLocationXY()
    selfx=selfx+moveXDelta
    selfy=selfy+moveYDelta
    local isOut = self:convertLimitX(selfx)
    if isOut then
        selfx=2*targetCenterX -selfx
    end
    self:setMovePos(cc.p(selfx,selfy))

    if self.m_nType~=_G.Const.CONST_PARTNER then
        self.m_fLastThinkTime=self.m_fLastThinkTime+400
    end
end

function CMonster.gotoFight(self,_now)
    local directTarget= self:adjustDirect(self.m_nTarget)

    local _collider

    if self.m_attackSkillData==nil then
        -- local availableAttackSkillDatas={}
        local nCount=0
        local skillWidth=0
        for skillId,attackSkillData in pairs(self.m_attackSkillDatas) do
            
            if not self:isSkillCD(skillId) then
                nCount=nCount+1
                if skillWidth<attackSkillData.attackCollider.vWidth then
                    self.m_attackSkillData=attackSkillData
                    skillWidth=attackSkillData.attackCollider.vWidth
                end
            end
        end

        if nCount==0 then
            -- print("CMonster.gotoFight cd中，无技能可用，巡逻",self.m_patrolRatio)
            self:evade()
            return
        end

        _collider=self.m_attackSkillData.attackCollider
        if _collider==nil then
            self:clearAiAttackSkill()
            return
        end

        if math.random(0,100)<self.m_patrolRatio then
            self:evade()
            self:clearAiAttackSkill()
            return
        end
        
        -- local ranIndex=math.random(1,nCount)
        -- self.m_attackSkillData=availableAttackSkillDatas[ranIndex]
    else
        _collider=self.m_attackSkillData.attackCollider
    end
    
    if _G.CharacterManager:checkColliderByCharacter(self,_collider,self.m_nTarget) == true then
        self:cancelMove()
        self:setAIBlockWithCollider(_collider)
        local attack_skill = self.m_attackSkillData.attack_skill
        -- local num = gc.MathGc:random_0_1()
        -- if num < 0.5 then
        --     self.m_fLastThinkTime = self.m_fLastThinkTime + num * 1000
        --     local function actionCallFunc()
        --         self:useSkill(attack_skill[1])
        --     end
        --     local delay=cc.DelayTime:create(num)
        --     local func=cc.CallFunc:create(actionCallFunc)
        --     self.m_lpContainer:runAction(cc.Sequence:create(delay,func))
        -- end
        self:useSkill(attack_skill[1])
        self.m_fLastAttackTime=_now
        -- self.m_attackSkillData=nil
        self:clearAiAttackSkill()
        return
    elseif self.m_noLimit~=nil then
        -- self.m_nTarget=nil
        -- self.m_attackSkillData=nil
        return
    elseif self:useFashionDodgo() then
        return
    -- elseif _G.CharacterManager:checkColliderByCharacter(self,_collider,self.m_nTarget,true) == true then
    --     self:setMoveClipContainerScalex(-self.m_nScaleX)
    --     self:cancelMove()
    --     self:setAIBlockWithCollider(_collider)
    --     local attack_skill = self.m_attackSkillData.attack_skill
    --     -- local num = gc.MathGc:random_0_1()
    --     -- if num < 0.5 then
    --     --     self.m_fLastThinkTime = self.m_fLastThinkTime + num * 1000
    --     --     local function actionCallFunc()
    --     --         self:useSkill(attack_skill[1])
    --     --     end
    --     --     local delay=cc.DelayTime:create(num)
    --     --     local func=cc.CallFunc:create(actionCallFunc)
    --     --     self.m_lpContainer:runAction(cc.Sequence:create(delay,func))
    --     -- end
    --     self:useSkill(attack_skill[1])
    --     self.m_fLastAttackTime=_now
    --     self:clearAiAttackSkill()
    --     return
    end

    self:closeToTarget()
    -- print("setMovePos gotoFight===>>>>",self.m_nTarget.m_nLocationX,self.m_nTarget.m_nLocationY,self.m_lpMovePos.x,self.m_lpMovePos.y)
end

function CMonster.gotoFight102(self,_now)
    -- print("gotoFight102=======>>>>")
    local skillWidth=0

    local tempArray={}
    local tempCount=0
    for skillId,attackSkillData in pairs(self.m_attackSkillDatas) do
        if not self:isSkillCD(skillId) then
            local _collider=attackSkillData.attackCollider
            if _collider then
                if _G.CharacterManager:checkColliderByCharacter(self,_collider,self.m_nTarget)==true then

                    

                    tempCount=tempCount+1
                    tempArray[tempCount]=attackSkillData

                    
                elseif skillWidth<attackSkillData.attackCollider.vWidth then
                    self.m_attackSkillData=attackSkillData
                    skillWidth=attackSkillData.attackCollider.vWidth
                end
            end
        end
    end

    -- print("FFFFFFFFFFFFFFFFFF====>>>",tempCount,self.m_attackSkillData)
    if tempCount>0 then
        if math.random(0,100)<self.m_patrolRatio then
            self:evade()
            self:clearAiAttackSkill()
            return
        end

        local attackSkillData=tempArray[math.random(1,tempCount)]
        self:cancelMove()
        self:setAIBlockWithCollider(attackSkillData.attackCollider)
        local attack_skill=attackSkillData.attack_skill
        self:useSkill(attack_skill[1])
        self.m_fLastAttackTime=_now
        self:clearAiAttackSkill()
        return
    end

    if not self.m_attackSkillData then
        self:evade()
        return
    end

    if not self:useFashionDodgo() then
        self:closeToTarget()
    end
end

function CMonster.useFashionDodgo(self)
    if not self.m_fashionDodgoSkillId then
        return false
    end

    if math.abs(self.m_nLocationX-self.m_nTarget.m_nLocationX)<200 then
        if self.m_fashionDodgoSkillId then
            if not self:isSkillCD(self.m_fashionDodgoSkillId) then
                local rx=self.m_stageView:getMaprx()
                local lx=self.m_stageView:getMaplx()

                local isChuangeScaleX=false
                if self.m_nLocationX<lx+600 then
                    if self.m_nScaleX>0 then
                        isChuangeScaleX=true
                    end
                elseif self.m_nLocationX>rx-600 then
                    if self.m_nScaleX<0 then
                        isChuangeScaleX=true
                    end
                elseif (self.m_nLocationX<self.m_nTarget.m_nLocationX and self.m_nScaleX<0)
                    or (self.m_nLocationX>self.m_nTarget.m_nLocationX and self.m_nScaleX>0) then
                    isChuangeScaleX=true
                end

                if isChuangeScaleX then
                    self:setMoveClipContainerScalex(-self.m_nScaleX)
                end
                self:useSkill(self.m_fashionDodgoSkillId)
                return true
            end
        end
    end

    return false
end

function CMonster.updateWarAttr( self,val )
    local attrIndex = {"strong_att","strong_def","wreck","hit","dodge","crit","crit_res","bonus","reduction"}
    local attr=self:getWarAttr()
    for i=42,50 do
        attr:updateProperty(i,math.ceil(attr[attrIndex[i-41]]*val/10000))
    end
    local maxHp=self:getMaxHp()
    self:setMaxHp(math.ceil(maxHp*val/10000))
    self:setHP(math.ceil(maxHp*val/10000))
end
function CMonster.hideMonster( self,pos )
    local dir 
    if self.m_nLocationX<1000 then
        dir=1
    else
        dir=2
    end
    if pos~=nil and pos==dir then return end
    if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_USESKILL then
        self.m_completeSkill=true
        return
    end

    self.m_completeSkill=nil
    function c( )
        self:showMonster()
    end
    local moveX=500
    moveX=-moveX
    local move=cc.MoveTo:create(0.3,cc.p(moveX,0))
    self.m_lpMovieClip:runAction(cc.Sequence:create(move,cc.CallFunc:create(c)))
    self.m_cantUseskil=true
    self.m_noBeTarget=true
end
function CMonster.showMonster( self )
    local lstarX,rstarX=0,2028
    function c( )
        self.m_cantUseskil=nil
        self.m_noBeTarget=nil
    end
    local dir 
    if self.m_nLocationX<1000 then
        dir=1
    else
        dir=2
    end
    if dir==1 then
        -- self.m_lpMovieClip:setPosition(-moveX,0)
        self:setLocationX(rstarX)
        self:setMoveClipContainerScalex(-1)
    else
        -- self.m_lpMovieClip:setPosition(-moveX,0)
        self:setLocationX(lstarX)
        self:setMoveClipContainerScalex(1)
    end
    local move=cc.MoveTo:create(0.3,cc.p(0,0))

    self.m_lpMovieClip:runAction(cc.Sequence:create(move,cc.CallFunc:create(c)))
end
