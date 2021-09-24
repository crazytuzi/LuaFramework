local KeyBoard = classGc(view)

--constant
local SKILL_COUNT=3
local BUTTON_ATTACK=10000
local BUTTON_SKILL=20000
local BUTTON_BIG_SKILL=30000
local BUTTON_MOUNT_SKILL=40000
local BUTTON_MOUNT_ATTACK=41000

-- _G.Const.CONST_WAR_MOUNT_CD=10
-- _G.Const.CONST_WAR_MOUNT_TIME=5

function KeyBoard.create(self,enableBigSkill,enableMountSkill,nSkillPreCDMount,nSkillPreCDArtifact)
    self.m_cdSchedule={}
    self.m_nSkillPreCDMount=nSkillPreCDMount
    self.m_nSkillPreCDArtifact=nSkillPreCDArtifact
    self.m_enableBigSkill=enableBigSkill
    self.m_enableMountSkill=enableMountSkill
    self.m_layer=cc.Layer:create()

    self.m_winSize=cc.Director:getInstance():getVisibleSize()
    self:init()
    return self.m_layer
end

function KeyBoard.destory(self)
    if self.m_layer~=nil then
        self.m_layer:removeFromParent(true)
        self.m_layer=nil
    end
    for k,v in pairs(self.m_cdSchedule) do
        _G.Scheduler:unschedule(v)
    end
    self:__removeMountLifeScheduler()
end

function KeyBoard.setVisible(self,_visible)
    if self.m_layer~=nil then
        self.m_layer:setVisible(_visible)
    end
end

function KeyBoard.init(self)
    self:initView()
    self.m_layer:setPosition(self.m_winSize.width-80,80)
end

function KeyBoard.onButtonPress(self,obj,eventType)
    if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
        self:cancelAttack()
    elseif eventType == ccui.TouchEventType.began then
        self:btnCallback(obj,eventType)
        if self.m_cdSchedule[BUTTON_ATTACK]==nil and (BUTTON_ATTACK==obj:getTag() or BUTTON_MOUNT_ATTACK==obj:getTag()) then
            local function c()
                self:btnCallback(obj,eventType)
            end
            self.m_cdSchedule[BUTTON_ATTACK] = _G.Scheduler:schedule(c,0.25)
        end
    end
end

function KeyBoard.initView(self)
    local function press(obj,eventType)
        return self:onButtonPress(obj,eventType)
    end
    -- --普通攻击
    self.m_btnAttack=gc.CButton:create("battle_assault.png")
    self.m_btnAttack:addTouchEventListener(press)
    self.m_btnAttack:setTag(BUTTON_ATTACK)
    self.m_btnAttack:setPosition(0,0)
    self.m_btnAttack:enableSound()
    self.m_layer:addChild(self.m_btnAttack,10)

    local scene_type=_G.g_Stage.m_sceneType
    local roleProperty=_G.GPropertyProxy:getMainPlay()
    if  scene_type==_G.Const.CONST_MAP_TYPE_THOUSAND  then
        roleProperty=_G.g_lpMainPlay:getProperty()
    end
    if roleProperty == nil then
        CCLOG("codeError!!!! KeyBoard.initView 103",roleProperty)
        return
    end


    local roleSkillData = roleProperty :getSkillData()
    local skinId = roleProperty:getSkinArmor()
    local attackSkillIds=nil

    attackSkillIds=roleSkillData.skill_equip_list

    attackSkillIds=attackSkillIds or {}

    local bigSkillId=nil
    if attackSkillIds[5]==nil then
        if self.m_enableBigSkill==true then
            local sKillInitData =_G.g_SkillDataManager:getSkillInitData(skinId)
            bigSkillId=sKillInitData.big_skill
        else
            bigSkillId=0
        end
    else
        if self.m_enableBigSkill==nil then
            bigSkillId=attackSkillIds[5].skill_id or 0
        elseif self.m_enableBigSkill==false then
            bigSkillId=0
        else
            local sKillInitData =_G.g_SkillDataManager:getSkillInitData(skinId)
            bigSkillId=sKillInitData.big_skill
        end
    end

    self.skillIds={}
    self.m_btnSkill = {}
    self.m_cdSkill = {}
    self.skillIcons={}
    local startAngle = 10

    self:addBigButton(bigSkillId)
    if self.m_enableMountSkill then
        self:addMountSkillButton(roleProperty:getMountID())
        self:addArtifactSkillButton(roleProperty:getArtifactSkillId())
    end
    local openLv={}
    for i=1,SKILL_COUNT do
        local sKillInitData=_G.g_SkillDataManager:getSkillInitData(skinId)
        local lv=_G.g_SkillDataManager:getSkillData(sKillInitData.skill_learn[i]).lv_min
        openLv[i]=lv
    end
    for positionIndex=1,SKILL_COUNT do
        --创建技能按钮
        local x = math.sin(math.rad(startAngle-56*(positionIndex-1)))*140
        local y = math.cos(math.rad(startAngle-56*(positionIndex-1)))*140

        local skillBtn=gc.CButton:create("battle_skill_box.png")
        -- skillBtn:setButtonScale(0.86)
        skillBtn:setTag(positionIndex)
        skillBtn:addTouchEventListener(press)
        skillBtn:enableSound()
        skillBtn:setPosition(x,y)
        self.m_layer:addChild(skillBtn,8)
        self.m_btnSkill[positionIndex]=skillBtn

        local skill_equip =attackSkillIds[positionIndex]
        if skill_equip~=nil and skill_equip.skill_id~=0 then
            self:addSkillButton(skill_equip.skill_id,positionIndex)
        else
            local lv = _G.g_Stage.m_lpPlay:getLv()
            if openLv[positionIndex]>lv then
                local tempSize=skillBtn:getContentSize()
                local label=_G.Util:createLabel(string.format("%d级解锁",openLv[positionIndex]),20)
                label:setPosition(tempSize.width*0.5,tempSize.height*0.5)
                skillBtn:addChild(label)
            end
            skillBtn:setTouchEnabled(false)
        end
    end

    self.m_skillSps={}
end

function KeyBoard.addSkillButton( self,_skill,index )
    local skillBtn=self.m_btnSkill[index]

    if not skillBtn then return end

    if self.skillIds[index] and self.m_cdSchedule[self.skillIds[index]] then
        _G.Scheduler:unschedule(self.m_cdSchedule[self.skillIds[index]])
        self.m_cdSchedule[self.skillIds[index]]=nil
    end

    skillBtn:removeAllChildren(true)

    if not _skill or _skill==0 then
        skillBtn:setTouchEnabled(false)

        self.m_cdSkill[index]=nil
        if self.skillIds[index] then
            local skillId=self.skillIds[self.skillIds[index]]
            self.skillIcons[skillId]=nil
            self.skillIds[self.skillIds[index]]=nil
            self.skillIds[index]=nil
        end
        return
    end

    skillBtn:setTouchEnabled(true)

    self.skillIds[index]=_skill
    self.skillIds[_skill]=index

    local tempSize=skillBtn:getContentSize()
    local node = cc.Node:create()
    node:setPosition(tempSize.width*0.5,tempSize.height*0.5)
    skillBtn:addChild(node,-1)
    
    local iconId = _G.Cfg.skill[_skill].icon
    local skillIcon = _G.ImageAsyncManager:createNormalSpr(string.format("icon/s%d.png",iconId))
    self.skillIcons[_skill]=skillIcon
    node:addChild(skillIcon,10)

    local cdSprite = cc.Sprite:createWithSpriteFrameName("general_picture_frame_3.png")
    local cdProgressTimer = cc.ProgressTimer:create(cdSprite)
    cdProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    cdProgressTimer:setReverseDirection(true)
    cdProgressTimer:setTag(0)
    cdProgressTimer:setScale(0.9)
    node:addChild(cdProgressTimer, 1000)
    self.m_cdSkill[index]=cdProgressTimer
end
function KeyBoard.changeSkillButton( self,_baseSkin,_skin )
    local changeSkillsData=_G.g_SkillDataManager:getSkillInitData(_skin)
    local changeSkills=changeSkillsData.skill_learn
    local baseSkillsData=_G.g_SkillDataManager:getSkillInitData(_baseSkin)
    local baseSkills=baseSkillsData.skill_learn

    for i=1,SKILL_COUNT do
        if self.skillIds[i]~=nil then
            local index
            local baseSkillId=self.skillIds[i]
            for z,v in pairs(baseSkills) do
                if v==baseSkillId then
                    index=z
                    break
                end
            end
            print(index,self.skillIds[i],"changeSkillButton============")
            if index~=nil then
                local _skill=changeSkills[index]
                self:changeSkillIcon(_skill,self.m_btnSkill[i])
                self.skillIds[baseSkillId]=nil
                self.skillIds[i]=_skill
                self.skillIds[_skill]=i
            end
        end
    end
    if self.m_btnBigSkill~=nil then
        self.m_bigSkillId=changeSkillsData.big_skill
        self:changeSkillIcon(changeSkillsData.big_skill,self.m_btnBigSkill)
    end

    self:isBlackOrColor()
end

function KeyBoard.addBigButton(self,_bigSkillId)
    --大技能攻击
    if self.m_btnBigSkill~=nil then return end

    self.m_bigSkillId= _bigSkillId
    BUTTON_BIG_SKILL = _bigSkillId

    if self.m_bigSkillId>0 then
        local function press(obj,eventType)
            return self:onButtonPress(obj,eventType)
        end
        self.m_btnBigSkill=gc.CButton:create("battle_skill_box.png")
        self.m_btnBigSkill:addTouchEventListener(press)
        self.m_btnBigSkill:setPosition(22,250)
        self.m_btnBigSkill:setTag(BUTTON_BIG_SKILL)
        self.m_btnBigSkill:enableSound()
        self.m_layer:addChild(self.m_btnBigSkill,8)

        local cNode=cc.ClippingNode:create()
        cNode:setPosition(-10,0)
        self.m_btnBigSkill:addChild(cNode)
        local dNode=cc.DrawNode:create()
        local nColor=cc.c4f(0,0,0,1)
        local array = {[1]={x=-20,y=0},[2]={x=130,y=0},[3]={x=130,y=80},[4]={x=-20,y=80}}
        dNode:drawPolygon(array,4,nColor,1,nColor)
        cNode:setStencil(dNode)
        self.m_bigSkillDraw=dNode
        local spine = _G.SpineManager.createSpine(string.format("spine/%s","6054"),1)
        spine:setAnimation(0,"idle",true)
        spine:setPosition(52,0)
        spine:setScale(0.7)
        cNode:addChild(spine)

        local tempSize=self.m_btnBigSkill:getContentSize()
        local node = cc.Node:create()
        node:setPosition(tempSize.width*0.5,tempSize.height*0.5)
        local iconId = _G.Cfg.skill[self.m_bigSkillId].icon
        local skillIcon = _G.ImageAsyncManager:createNormalSpr(string.format("icon/s%d.png",iconId))
        skillIcon:setTag(23333)
        node:addChild(skillIcon)
        local cdSprite = cc.Sprite:createWithSpriteFrameName("general_picture_frame_3.png")
        cdSprite:setOpacity(100)
        node:addChild(cdSprite)
        self.m_bigskillB=cdSprite
        cdSprite = cc.Sprite:createWithSpriteFrameName("general_picture_frame_3.png")
        cdSprite : setOpacity(200)
        local cdProgressTimer = cc.ProgressTimer:create(cdSprite)
        cdProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        cdProgressTimer:setReverseDirection(true)
        cdProgressTimer:setTag(0)
        cdProgressTimer:setPercentage(100)
        cdProgressTimer:setScale(0.9)
        self.m_cdSkill[5] = cdProgressTimer
        node:addChild(cdProgressTimer, 1000)
        self.m_btnBigSkill:addChild(node,-1,22333)
    end
end
function KeyBoard.changeSkillIcon( self,_skill,btn )
    local node=btn:getChildByTag(22333)
    if node~=nil then
        local iconSpr=node:getChildByTag(23333)
        local z=iconSpr:getLocalZOrder()
        iconSpr:removeFromParent(true)
        local iconId = _G.Cfg.skill[_skill].icon
        local skillIcon = _G.ImageAsyncManager:createNormalSpr(string.format("icon/s%d.png",iconId))
        if _skill~=self.m_bigSkillId then
            self.skillIcons[_skill]=skillIcon
        end
        skillIcon:setTag(23333)
        skillIcon:setLocalZOrder(z)
        node:addChild(skillIcon)
    end
end
function KeyBoard.getBigButton(self)
    return self.m_btnBigSkill
end

function KeyBoard.addMountSkillButton(self,_mountSkillId)
    if self.m_btnMountSkill~=nil then
        self.m_btnMountSkill:removeFromParent(true)
        self.m_btnMountSkill=nil
    end

    if self.m_mountSkillId and self.m_cdSchedule[self.m_mountSkillId]~=nil then
        _G.Scheduler:unschedule(self.m_cdSchedule[self.m_mountSkillId])
        self.m_cdSchedule[self.m_mountSkillId]=nil
    end

    if _mountSkillId>0 then
        local function press(obj,eventType)
            return self:onButtonPress(obj,eventType)
        end
        
        self.m_mountSkillId=_mountSkillId
        self.m_btnMountSkill=gc.CButton:create("battle_skill_box.png")
        self.m_btnMountSkill:addTouchEventListener(press)
        self.m_btnMountSkill:setPosition(-250,-29)
        self.m_btnMountSkill:setTag(BUTTON_MOUNT_SKILL)
        self.m_btnMountSkill:enableSound()
        self.m_layer:addChild(self.m_btnMountSkill,8)

        local tempSize=self.m_btnMountSkill:getContentSize()
        local node = cc.Node:create()
        node:setPosition(tempSize.width*0.5,tempSize.height*0.5)
        -- local data=_G.Cfg.skill[self.m_mountSkillId]
        local iconId = _G.Cfg.mount_battle[self.m_mountSkillId].icon or 0
        local skillIcon = _G.ImageAsyncManager:createNormalSpr(string.format("icon/s%d.png",iconId))
        node:addChild(skillIcon,10)
        local cdSprite = cc.Sprite:createWithSpriteFrameName("general_picture_frame_3.png")
        cdSprite : setOpacity(200)
        local cdProgressTimer = cc.ProgressTimer:create(cdSprite)
        cdProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        cdProgressTimer:setReverseDirection(true)
        cdProgressTimer:setTag(0)
        cdProgressTimer:setPercentage(0)
        cdProgressTimer:setScale(0.9)
        self.m_cdSkill[6] = cdProgressTimer
        self.skillIds[6]=BUTTON_MOUNT_SKILL
        self.skillIds[BUTTON_MOUNT_SKILL]=6
        node:addChild(cdProgressTimer, 1000)
        self.m_btnMountSkill:addChild(node,-1)
        self.m_btnSkill[6]=self.m_btnMountSkill
        local per
        if self.m_nSkillPreCDMount~=nil then
            per=self.m_nSkillPreCDMount/_G.Const.CONST_WAR_MOUNT_CD*100
        else
            self.m_nSkillPreCDMount=0
        end
        self:setSkillCD(BUTTON_MOUNT_SKILL,self.m_nSkillPreCDMount,per)
    end
end

function KeyBoard.addArtifactSkillButton(self,_artifactSkillId)
    if self.m_btnArtifactSkill~=nil then
        self.m_btnArtifactSkill:removeFromParent(true)
        self.m_btnArtifactSkill=nil
    end

    if self.m_artifactSkillId and self.m_cdSchedule[self.m_artifactSkillId]~=nil then
        _G.Scheduler:unschedule(self.m_cdSchedule[self.m_artifactSkillId])
        self.m_cdSchedule[self.m_artifactSkillId]=nil
    end

    if _artifactSkillId>0 then
        local function press(obj,eventType)
            return self:onButtonPress(obj,eventType)
        end
        
        self.m_artifactSkillId=_artifactSkillId
        self.m_btnArtifactSkill=gc.CButton:create("battle_skill_box.png")
        self.m_btnArtifactSkill:addTouchEventListener(press)
        self.m_btnArtifactSkill:setPosition(-380,-29)
        self.m_btnArtifactSkill:setTag(7)
        self.m_btnArtifactSkill:enableSound()
        self.m_layer:addChild(self.m_btnArtifactSkill,8)

        local tempSize=self.m_btnArtifactSkill:getContentSize()
        local node = cc.Node:create()
        node:setPosition(tempSize.width*0.5,tempSize.height*0.5)
        local data=_G.Cfg.skill[self.m_artifactSkillId]
        local skillIcon = _G.ImageAsyncManager:createNormalSpr(string.format("icon/s%d.png",data.icon))
        node:addChild(skillIcon,10)
        local cdSprite = cc.Sprite:createWithSpriteFrameName("general_picture_frame_3.png")
        cdSprite : setOpacity(200)
        local cdProgressTimer = cc.ProgressTimer:create(cdSprite)
        cdProgressTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        cdProgressTimer:setReverseDirection(true)
        cdProgressTimer:setTag(0)
        cdProgressTimer:setPercentage(0)
        cdProgressTimer:setScale(0.9)
        self.m_cdSkill[7] = cdProgressTimer
        self.skillIds[7]=self.m_artifactSkillId
        self.skillIds[self.m_artifactSkillId]=7
        node:addChild(cdProgressTimer, 1000)
        self.m_btnArtifactSkill:addChild(node,-1)
        self.m_btnSkill[7]=self.m_btnArtifactSkill
        local per
        if self.m_nSkillPreCDArtifact~=nil then
            per=self.m_nSkillPreCDArtifact/data.cd*100
        else
            self.m_nSkillPreCDArtifact=0
        end
        self:setSkillCD(self.m_artifactSkillId,self.m_nSkillPreCDArtifact,per)
    end
end
function KeyBoard.__showArtifactSkillButton(self)
    if self.m_btnArtifactSkill then
        self.m_btnArtifactSkill:setVisible(true)
    end
end
function KeyBoard.__hideArtifactSkillButton(self)
    if self.m_btnArtifactSkill then
        self.m_btnArtifactSkill:setVisible(false)
    end
end

function KeyBoard.btnCallback( self,obj, eventType )
    if eventType == ccui.TouchEventType.began then
        local skillIndex = obj:getTag()
        CCLOG("KeyBoard.btnCallback skillIndex=%d",skillIndex)
        --普通攻击
        if BUTTON_ATTACK==skillIndex then
            self:fireKeyCode(skillIndex,BUTTON_ATTACK)
            return true
        elseif BUTTON_MOUNT_ATTACK==skillIndex then
            self:fireKeyCode(skillIndex)
            return true
        elseif BUTTON_MOUNT_SKILL==skillIndex then
            if self.m_cdSkill[6]:getPercentage() == 0 then
                self:__chuangToMountBattle()
            end
            return true
        end
        -- 大技能攻击
        if BUTTON_BIG_SKILL==skillIndex then
            local skillId =self.m_bigSkillId
            if skillId~=nil and skillId~=0 and self.m_cdSkill[5]:getPercentage() == 0 then
                self:fireKeyCode(skillId,BUTTON_BIG_SKILL)
            end
            return true
        end

        if self.m_cdSkill[skillIndex]:getTag() == 0 then
            local skillId =self.skillIds[skillIndex]
            CCLOG("KeyBoard.btnCallback click btn skillId=%d", skillId)
            self:fireKeyCode(skillId,BUTTON_SKILL)
        end
        return true
    end
end

function KeyBoard.fireKeyCode( self, skillId,skillType)
    -- CCLOG("KeyBoard.fireKeyCode skillId=%d", skillId)
    local keyBoardCommand = CKeyBoardCommand()
    keyBoardCommand.skillId=skillId
    keyBoardCommand.skillType=skillType
    if skillType==BUTTON_ATTACK then
        keyBoardCommand.isAttack=true
    end
    controller:sendCommand(keyBoardCommand)
end

--获得技能sp 与 所有sp得比较结果
function KeyBoard.getCompareSpResult( self, skillId )
    if skillId == nil then return false end
    self.m_skillSps=self.m_skillSps or {}
    if self.m_skillSps[skillId]==nil then
        local skillNode =_G.g_SkillDataManager:getSkillData(skillId)
        if skillNode ~= nil then
            self.m_skillSps[skillId]=-skillNode.sp
        else
            self.m_skillSps[skillId]=-20
        end
    end
    return _G.g_Stage.m_lpPlay:canSubSp(self.m_skillSps[skillId])
end

--判断点击后是否黑白 or 彩色
function KeyBoard.isBlackOrColor( self)
    for k,obj in pairs(self.m_btnSkill) do
        local skillIndex=obj:getTag()
        local skillId =self.skillIds[skillIndex]
        local hasEnoughSp=self:getCompareSpResult(skillId)
        if self.skillIcons[skillId]~=nil then
            if hasEnoughSp then
                self.skillIcons[skillId]:setDefault()
            else
                self.skillIcons[skillId]:setGray()
            end
        end
    end
end

function KeyBoard.showBigSkillBtn(self)
    print("KeyBoard.showBigSkillBtn self.m_bigSkillId=",self.m_bigSkillId)
    if self.m_bigSkillId==0 then return end
    if self.m_btnBigSkill~=nil then
        self.m_btnBigSkill:setVisible(true)
    end
end

function KeyBoard.hideBigSkillBtn(self)
    if self.m_btnBigSkill~=nil then
        self.m_btnBigSkill:setVisible(false)
    end
end

function KeyBoard.updateSkillBtn( self,Mp ,maxMp )
    local skill = self.m_cdSkill[5]
    if skill == nil then
        return
    end
    local per = (maxMp-Mp)/maxMp*100
    if self.m_bigCDLabel==nil then
        local size = cc.size(100,92)
        local label = _G.Util:createLabel("",24)
        label       : setPosition(size.width/2,size.height/2)
        skill       : addChild(label)
        self.m_bigCDLabel=label
    end
    self.m_bigCDLabel:setString(math.ceil(100-per).."%")
    if per==0 then
        self.m_bigskillB:setVisible(false)
        self.m_bigCDLabel:setVisible(false)
        self.m_bigSkillDraw:setScaleY(2)
    else
        self.m_bigskillB:setVisible(true)
        self.m_bigCDLabel:setVisible(true)
        self.m_bigSkillDraw:setScaleY(math.ceil(100-per)/100)
    end

    local curPer = skill:getPercentage()
    local progress = cc.ProgressFromTo:create(0.2,curPer,per)
    self.m_cdSkill[5] : runAction(progress)
end

--设置技能CD
function KeyBoard.setSkillCD(self, skillId, cd, per, isNoRemove)
    -- CCLOG("KeyBoard.setSkillCD skillId=%d,cd=%f",skillId,cd)
    local skillIndex =self.skillIds[skillId]
    if skillIndex==nil then
        CCLOG("KeyBoard.setSkillCD skillIndex==nil skillId=%d",skillId)
        return
     end
    local skillCD = self.m_cdSkill[skillIndex]
    if self.m_cdSchedule[skillId]~=nil then
        _G.Scheduler:unschedule(self.m_cdSchedule[skillId])
        self.m_cdSchedule[skillId]=nil
    end

    skillCD:removeAllChildren(true)
    skillCD:stopAllActions()
    if skillCD==nil then
        CCLOG("技能按钮为空")
        return
    end

    if skillIndex==7 and cd~=0 then
        _G.g_Stage.m_artifactSkillTime=_G.TimeUtil:getTotalMilliseconds()+cd*1000
    end

    local spr = cc.Sprite:createWithSpriteFrameName("general_picture_frame_3.png")
    local size = cc.size(92,91)
    spr       : setPosition(size.width/2,size.height/2)
    spr       : setOpacity(140)
    skillCD   : addChild(spr)

    local label = _G.Util:createLabel("",24)
    label       : setPosition(size.width/2,size.height/2)
    skillCD     : addChild(label)
    
    if self.m_cdSchedule[skillId]==nil then
        local time = cd
        local function local_updateFun(_time)
            time=time-_time

            if time<0 then
                _G.Scheduler:unschedule(self.m_cdSchedule[skillId])
                self.m_cdSchedule[skillId]=nil
                
                if skillId==6 and self.m_useMountSkillTimes then
                    skillCD:setPercentage(1)
                else
                    label:removeFromParent(true)
                end
                if skillIndex==7 then
                    _G.g_Stage.m_artifactSkillTime=nil
                end
                return
            end
            local szTime=string.format("%.1f",time)
            label:setString(szTime)
        end
        self.m_cdSchedule[skillId]=_G.Scheduler:schedule(local_updateFun,0.1)
    end

    local function onCooldownCompleted( _node )
        if not isNoRemove then
            self :addHightSpr(_node)
            _node:setTag(0)
            local function reomve(node)
                node : removeFromParent(true)
            end
            spr   : runAction(cc.Sequence:create(cc.CallFunc:create(reomve)))
        end
    end
    skillCD:setTag(1)
    
    per=per and per or 100
    skillCD:setPercentage(per)
    local progress = cc.ProgressFromTo:create(cd,per,0)
    local func = cc.CallFunc:create(onCooldownCompleted)
    skillCD:runAction(cc.Sequence:create(progress,func))
end

function KeyBoard.cancelAttack(self)
    _G.Scheduler:unschedule(self.m_cdSchedule[BUTTON_ATTACK])
    self.m_cdSchedule[BUTTON_ATTACK] = nil
end

function KeyBoard.addHightSpr( self, _obj )
    local _hightSpr = _obj:getChildByTag(168)
    if _hightSpr==nil then
        _hightSpr = cc.Sprite:create()
        _hightSpr:setTag(168)
        local objContentSize =_obj:getContentSize()
        _hightSpr:setPosition(objContentSize.width/2,objContentSize.height/2)
        _obj:addChild( _hightSpr, 20)
    end
    _hightSpr:setVisible(true)
    local animate=_G.AnimationUtil:getSkillBtnFinishAnimate()
    local hide=cc.Hide:create()
    _hightSpr:runAction(cc.Sequence:create(animate,hide))
end

function KeyBoard.__chuangToMountBattle(self)
    if self.m_isMountBattble then return end

    local tempPlayer=_G.g_Stage:getMainPlayer()
    if tempPlayer:getStatus()==_G.Const.CONST_BATTLE_STATUS_MOVE
        or tempPlayer:getStatus()==_G.Const.CONST_BATTLE_STATUS_IDLE then

        local mountId=_G.Cfg.mount_battle[self.m_mountSkillId].id
        local mountSkillArray=_G.Cfg.mount_des[mountId].skill
        for i=1,SKILL_COUNT do
            self:addSkillButton(mountSkillArray[i+1],i)
        end

        self.m_useMountSkillTimes=_G.TimeUtil:getTotalMilliseconds()
        tempPlayer:chuangToMountBattle()
        self:setSkillCD(BUTTON_MOUNT_SKILL,_G.Const.CONST_WAR_MOUNT_TIME,nil,true)
        _G.g_Stage.m_mountSkillTime=_G.TimeUtil:getTotalMilliseconds()+_G.Const.CONST_WAR_MOUNT_CD*1000

        self:__removeMountLifeScheduler()
        local function nFun(_dt)
            self.m_mountLifeTimes=self.m_mountLifeTimes+_dt
            if self.m_mountLifeTimes>_G.Const.CONST_WAR_MOUNT_TIME then
                self:__chuangToPlayerBattle()
            end
        end
        self.m_mountLifeTimes=0
        self.m_mountLifeScheduler=_G.Scheduler:schedule(nFun,0.1)

        self:__hideArtifactSkillButton()
        self:__hideBigSkill()
        self:cancelAttack()
        BUTTON_MOUNT_ATTACK=mountSkillArray[1]
        self.m_btnAttack:setTag(BUTTON_MOUNT_ATTACK)



        self.m_isMountBattble=true
    end
end
function KeyBoard.__chuangToPlayerBattle(self)
    if not self.m_isMountBattble then return end

    local tempPlayer=_G.g_Stage:getMainPlayer()
    if tempPlayer:getStatus()==_G.Const.CONST_BATTLE_STATUS_MOVE
        or tempPlayer:getStatus()==_G.Const.CONST_BATTLE_STATUS_IDLE then

        local roleProperty=_G.GPropertyProxy:getMainPlay()
        local roleSkillData = roleProperty :getSkillData()
        local attackSkillIds=roleSkillData.skill_equip_list or {}
        for i=1,SKILL_COUNT do
            if attackSkillIds[i] then
                self:addSkillButton(attackSkillIds[i].skill_id,i)
            else
                self:addSkillButton(nil,i)
            end
        end

        local nTimes=_G.Const.CONST_WAR_MOUNT_CD-math.floor((_G.TimeUtil:getTotalMilliseconds()-self.m_useMountSkillTimes)*0.001)
        nTimes=nTimes<0 and 0 or nTimes
        local per=nTimes/_G.Const.CONST_WAR_MOUNT_CD*100
        self.m_useMountSkillTimes=nil
        self:setSkillCD(BUTTON_MOUNT_SKILL,nTimes,per)

        tempPlayer:chuangeToPlayerBattle()

        self:__showArtifactSkillButton()
        self:__showBigSkill()
        self:cancelAttack()
        self.m_btnAttack:setTag(BUTTON_ATTACK)

        self.m_isMountBattble=false
        self:__removeMountLifeScheduler()

    -- else
    --     tempPlayer.m_isMountBattbleEnd=true
    end
end

function KeyBoard.__removeMountLifeScheduler(self)
    if self.m_mountLifeScheduler then
        _G.Scheduler:unschedule(self.m_mountLifeScheduler)
        self.m_mountLifeScheduler=nil
    end
end

function KeyBoard.__hideBigSkill(self)
    if self.m_btnBigSkill then
        self.m_btnBigSkill:setVisible(false)
    end
end
function KeyBoard.__showBigSkill(self)
    if self.m_btnBigSkill then
        self.m_btnBigSkill:setVisible(true)
    end
end
return KeyBoard
