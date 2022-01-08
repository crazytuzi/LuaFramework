--[[
******后山Boss单元*******

    -- by yao
    -- 2015/12/25
]]

local HoushanBoss = class("HoushanBoss", BaseLayer)


function HoushanBoss:ctor(data)
    self.super.ctor(self,data)
    self.btn_base = nil         --点击boss按钮
    self.img_boss = nil         --boss图片
    self.img_num = nil          --
    self.bar_xuetiao1 = nil     --血条
    self.img_zhiye = nil        --职业图片
    self.icon_yijisha = nil     --已击杀标志
    self.bg_zhengzaitiaozhan = nil  --正在挑战
    self.img_touxiang = nil     --正在挑战的人物头像
    self.txt_name = nil         --正在挑战的人物名字
    self.chapter = nil          --章节
    self.bossIndex = nil        --第几个boss
    self.bossState = 0          --boss的状态
    self.fighteffect = nil
    self.parentLayer = nil

    self:init("lua.uiconfig_mango_new.faction.HoushanBoss")
end

function HoushanBoss:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_base = TFDirector:getChildByPath(ui,'btn_base')
    self.btn_base.logic = self
    self.btn_base:setTouchEnabled(false)
    self.img_boss = TFDirector:getChildByPath(ui,'img_boss')
    self.img_boss:setVisible(false)
    self.img_num = TFDirector:getChildByPath(ui,'img_num')
    self.bar_xuetiao1 = TFDirector:getChildByPath(ui,'bar_xuetiao1')
    self.img_zhiye = TFDirector:getChildByPath(ui,'img_zhiye')
    self.icon_yijisha = TFDirector:getChildByPath(ui,'icon_yijisha')
    self.bg_zhengzaitiaozhan = TFDirector:getChildByPath(ui,'bg_zhengzaitiaozhan')
    self.bg_zhengzaitiaozhan:setVisible(false)
    self.img_touxiang = TFDirector:getChildByPath(ui,'img_touxiang')
    self.txt_name = TFDirector:getChildByPath(ui,'txt_name')
    self.Panel = TFDirector:getChildByPath(ui,'Panel')
    

end

--显示UI数据
function HoushanBoss:setData(chapter,bossIndex,bossState,bossInfo, layer)
    -- body
    self.chapter = chapter
    self.bossIndex = bossIndex
    self.bossState = bossState
    self.parentLayer = layer
 
    local oneChapterInfo = HoushanManager:getHoushanListByZoneId(chapter)
    self.chapter = chapter
    self.bossIndex = bossIndex
    -- self.img_boss:setTexture("icon/head/" .. oneChapterInfo[bossIndex].icon .. ".png")

    if self.armature then self.armature:removeFromParent() end
    local armatureID = oneChapterInfo[bossIndex].rolebig
    ModelManager:addResourceFromFile(1, armatureID, 1)
    self.armature = ModelManager:createResource(1, armatureID)
    self.armature:setPosition(ccp(0, 40))
    self.armature:setScale(0.7)
    self.btn_base:addChild(self.armature)
    -- ModelManager:playWithNameAndIndex(self.armature, "stand", -1, 1, -1, -1)

    self.img_num:setTexture("ui_new/faction/houshan/icon_guan" .. bossIndex .. ".png")

    if bossInfo == nil then
        self.bar_xuetiao1:setPercent(100)
    else
        local checkpoint_id = oneChapterInfo[bossIndex].checkpoint_id
        percent = FactionManager:getCheckPointPercentHp(chapter, checkpoint_id)
        self.bar_xuetiao1:setPercent(percent)
    end

    self:showBossState(bossState,bossInfo)
end

function HoushanBoss:showBossState(bossState,bossInfo)
    if self.fighteffect ~= nil then
        self.fighteffect:setVisible(false)
    end
    
    if bossState == 1 then
        self.icon_yijisha:setVisible(false)
        self.bg_zhengzaitiaozhan:setVisible(false)
        self.btn_base:setGrayEnabled(true)
        self.btn_base:setTouchEnabled(false)
    elseif bossState == 2 then
        self.icon_yijisha:setVisible(false)
        self.bg_zhengzaitiaozhan:setVisible(false)
        self.btn_base:setGrayEnabled(false)
        self.btn_base:setTouchEnabled(true)
        self:setFightEffect()
        ModelManager:playWithNameAndIndex(self.armature, "stand", -1, 1, -1, -1)
    elseif bossState == 3 then
        self.icon_yijisha:setVisible(false)
        self.bg_zhengzaitiaozhan:setVisible(true)
        self.btn_base:setGrayEnabled(false)
        self.btn_base:setTouchEnabled(true)
        local RoleIcon = RoleData:objectByID(bossInfo.profession)
        self.img_touxiang:setTexture(RoleIcon:getHeadPath())
        self.txt_name:setText(bossInfo.lockPlayerName)  
        self:addtimer()
        self:setFightEffect()
        self:setIsChallengeEffect()
        ModelManager:playWithNameAndIndex(self.armature, "stand", -1, 1, -1, -1)
    elseif bossState == 4 then
        self.icon_yijisha:setVisible(true)
        self.bg_zhengzaitiaozhan:setVisible(false)
        -- self.btn_base:setGrayEnabled(true)
        self.btn_base:setTouchEnabled(false)
    end
end

function HoushanBoss:addtimer()
    local time = MainPlayer:getNowtime()
    local cutDownTime = 0
    if bossInfo~=nil and bossInfo.lockTime ~= nil then
        cutDownTime = math.floor(bossInfo.lockTime/1000) - time
    end
    if cutDownTime <= 0 then
        return
    end

    self.countDownTimer = TFDirector:addTimer(1000, -1, nil, 
        function () 
        if cutDownTime <= 0 then
            self:removeOwntimer(self.countDownTimer)
            self.bg_zhengzaitiaozhan:setVisible(false)
            --FactionManager:requestGuildZoneInfo()
            self.bossState = 2
        else
            cutDownTime = cutDownTime - 1
        end
    end)
         
end

function HoushanBoss:setIsChallengeEffect()
    if self.isChallenge == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/ischallenging.xml")
        self.isChallenge = TFArmature:create("ischallenging_anim")
        if self.isChallenge == nil then
            return
        end
        self.isChallenge:setAnimationFps(GameConfig.ANIM_FPS)
        self.isChallenge:playByIndex(0, -1, -1, 1)
        self.isChallenge:setZOrder(10)
        self.isChallenge:setPosition(ccp(100,23))
        self.bg_zhengzaitiaozhan:addChild(self.isChallenge)
        self.isChallenge:setVisible(true)
    else
        self.isChallenge:setVisible(true)
    end
end

function HoushanBoss:setFightEffect()
    -- if self.fighteffect == nil then
    --     TFResourceHelper:instance():addArmatureFromJsonFile("effect/mission_attacking.xml")
    --     self.fighteffect = TFArmature:create("mission_attacking_anim")
    --     if self.fighteffect == nil then
    --         return
    --     end
    --     self.fighteffect:setAnimationFps(GameConfig.ANIM_FPS)
    --     self.fighteffect:playByIndex(0, -1, -1, 1)
    --     self.fighteffect:setZOrder(10)
    --     self.fighteffect:setPosition(ccp(120,165))
    --     self:addChild(self.fighteffect)
    --     self.fighteffect:setVisible(true)
    -- else
    --     self.fighteffect:setVisible(true)
    -- end
    if self.backeffect == nil then
        self.backeffect = Public:addEffect("jingzhongjie2", self.btn_base, 0, 40, 0.6)
        self.backeffect:setZOrder(-1)
    end

    if self.fronteffect == nil then
        self.fronteffect = Public:addEffect("jingzhongjie1", self.btn_base, 0, 40, 0.6)
    end
end

function HoushanBoss:removeUI()
	self.super.removeUI(self)
end


function HoushanBoss:registerEvents()
	self.super.registerEvents(self)
    self.btn_base:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onButtonClick))
    self.btn_base:addMEListener(TFWIDGET_TOUCHENDED, self.onBtnAttackTouchEndedHandle);
end

function HoushanBoss.onButtonClick(sender)
	-- body
    local self = sender.logic
    if self.bossState == 1 or self.bossState == 4 then
        sender:setShaderProgram("GrayShader", true)
        return
    elseif self.bossState == 3 then
        self:removeOwntimer(self.countDownTimer)
        self.parentLayer.IsClickItem = true
        self.parentLayer.clickBoss = self.bossIndex
        FactionManager:requestGuildZone(self.chapter)
        HoushanManager:setHoushanUnlockBossInfo(self.chapter,self.bossIndex)
        --HoushanManager:lockedZone(self.chapter)
        return
    else
        local zonePersonalInfo = HoushanManager:getZonePersonalInfoByZoneId(self.chapter)
        if zonePersonalInfo == nil then
            self:removeOwntimer(self.countDownTimer)
            self.parentLayer.IsClickItem = true
            self.parentLayer.clickBoss = self.bossIndex
            FactionManager:requestGuildZone(self.chapter)
            HoushanManager:setHoushanUnlockBossInfo(self.chapter,self.bossIndex)
            --HoushanManager:lockedZone(self.chapter)
        else
            local challengeNum = zonePersonalInfo.challengeCount
            if challengeNum >= 2 then
                --toastMessage("挑战次数不足！")
                toastMessage(localizable.common_no_fight_times)
            else
                self:removeOwntimer(self.countDownTimer)
                self.parentLayer.IsClickItem = true
                self.parentLayer.clickBoss = self.bossIndex
                FactionManager:requestGuildZone(self.chapter)
                HoushanManager:setHoushanUnlockBossInfo(self.chapter,self.bossIndex)
            end
        end       
    end
    
end

function HoushanBoss.onBtnAttackTouchEndedHandle(sender)
    local self = sender.logic
    if self.bossState == 1 or self.bossState == 4 then
        sender:setShaderProgram("GrayShader", true)
    end
end

-----断线重连支持方法
function HoushanBoss:onShow()
    self.super.onShow(self)
end

function HoushanBoss:removeOwntimer(timerId)
    if timerId then
        TFDirector:removeTimer(timerId)
        if  timerId == self.countDownTimer then
            self.countDownTimer = nil
        end
    end
end

function HoushanBoss:removeEvents()
    self.btn_base:removeMEListener(TFWIDGET_CLICK)
    self:removeOwntimer(self.countDownTimer)
    self.super.removeEvents(self)
end

function HoushanBoss:dispose()
    self.super.dispose(self)
end

return HoushanBoss