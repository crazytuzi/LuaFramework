allianceFubenScene={
	bgLayer,
    clayer,
    sceneSp,
    touchArr={},
    multTouch=false,
    firstOldPos,
    secondOldPos,
    --startPos=ccp(0,100),
    --topPos=ccp(0,-100),
    startPos=ccp(0,0),
    topPos=ccp(0,0),
    minScale=0.8,
    maxScale=1.3,
    isMoving=false,
    isZooming=false,
    autoMoveAddPos,
    touchEnable=true,
    -- touchEnable=false,
    isMoved=false, 
	
	closeBtn=nil,
	fubenTab={},
	-- pointerSp,
    beforeHideIsShow=false, 
    -- checkPointDialog={},
    isShowed=false,
    lastTouchDownPoint=ccp(0,0),
	touchEnabledSp=nil,

    layerNum=4,
    chapterId=1,
    tipIcon=nil,
    isInitFuben=false,
    isClosing=false,
    fubenRewardSd=nil,
    isBossFu=false,
    bossRewardLb=nil,
    timeSp=nil,
    timeLb=nil,
    bossRewardBtn=nil,
    bossDescTv=nil,
}
--convertToWorldSpace
--convertToNodeSpace
--ccpMidpoint
function allianceFubenScene:show()
    -- setmetatable(self.checkPointDialog,{__mode="kv"})
	self.bgLayer=CCLayer:create()
    self.clayer=CCLayer:create()
    self.sceneSp=CCSprite:create("story/CheckpointBg.jpg") 
    self.sceneSp:setAnchorPoint(ccp(0,0))
    self.sceneSp:setPosition(ccp(0,0))
	self.clayer:addChild(self.sceneSp,1)
    -- self.sceneSp2=CCSprite:create("story/CheckpointBg.jpg")
    -- self.sceneSp2:setAnchorPoint(ccp(0,0))
    -- self.sceneSp2:setPosition(ccp(self.sceneSp:getContentSize().width,0))
    local sceneScale=1

    if G_getIphoneType() == G_iphoneX then
        self.sceneSp:setScaleY(G_VisibleSizeHeight/self.sceneSp:getContentSize().height)
    elseif G_getIphoneType() == G_iphone5 then
        sceneScale=1.2
        self.sceneSp:setScaleY(sceneScale)
    end
    -- self.clayer:addChild(self.sceneSp2,1)
    -- self.clayer:setContentSize(CCSizeMake(self.sceneSp:getContentSize().width+self.sceneSp2:getContentSize().width,self.sceneSp:getContentSize().height))
    self.clayer:setContentSize(CCSizeMake(self.sceneSp:getContentSize().width,self.sceneSp:getContentSize().height))
    self.clayer:setPosition(self.startPos)
	self.bgLayer:addChild(self.clayer,3)
    
    -- self.clayer:setTouchEnabled(false)
    self.clayer:setTouchEnabled(true)
    local function tmpHandler(...)
       return self:touchEvent(...)
    end
	self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-12,true)
    self.clayer:setTouchPriority(-(self.layerNum-1)*20-12)
	
    local function close()
        PlayEffect(audioCfg.mouseClick)
        -- if newGuidMgr:isNewGuiding()==true then
        --             newGuidMgr:toNextStep()
        -- end
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    closeBtnItem:registerScriptTapHandler(close)

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-14)
    if G_isIphone5()==true then
        self.closeBtn:setPosition(ccp(G_VisibleSize.width-closeBtnItem:getContentSize().width,G_VisibleSize.height-closeBtnItem:getContentSize().height))
    else
        self.closeBtn:setPosition(ccp(G_VisibleSize.width-closeBtnItem:getContentSize().width,G_VisibleSize.height-closeBtnItem:getContentSize().height))
    end
	self.bgLayer:addChild(self.closeBtn,4)

    local tipPos
    if G_isIphone5()==true then
        tipPos = ccp(G_VisibleSize.width-closeBtnItem:getContentSize().width-50,G_VisibleSize.height-closeBtnItem:getContentSize().height/2)
    else
        tipPos = ccp(G_VisibleSize.width-closeBtnItem:getContentSize().width-50,G_VisibleSize.height-closeBtnItem:getContentSize().height/2)
    end

    local function touchTip()

        local strTab
        local colorTab

        if self.isBossFu==true then
            strTab={" ",getlocal("alliance_boss_rule1",{alliancebossCfg.exprie}),getlocal("alliance_boss_rule2"),getlocal("alliance_boss_rule9",{alliancebossCfg.award.userinfo_expMax}),getlocal("alliance_boss_rule3")," ",getlocal("alliance_boss_rule4"),getlocal("alliance_boss_rule5"),getlocal("alliance_boss_rule6")," ",getlocal("alliance_boss_rule7"),getlocal("alliance_boss_rule8",{alliancebossCfg.raisingConsume})," "}
            colorTab={nil,G_ColorYellow,G_ColorYellow,G_ColorYellow,G_ColorYellow,nil,G_ColorYellow,G_ColorYellow,G_ColorYellow,nil,G_ColorYellow,G_ColorYellow,nil}
        else
            strTab={" ",getlocal("alliance_fuben_scene_tip_1"),getlocal("alliance_fuben_scene_tip_2"),getlocal("alliance_fuben_scene_tip_3")," ",getlocal("alliance_fuben_scene_tip_4"),getlocal("alliance_fuben_scene_tip_5"),getlocal("alliance_fuben_scene_tip_6"),getlocal("alliance_fuben_scene_tip_7"),getlocal("alliance_fuben_scene_tip_8")," "}
            colorTab={nil,G_ColorYellow,G_ColorYellow,G_ColorYellow,nil,G_ColorYellow,G_ColorYellow,G_ColorYellow,G_ColorYellow,G_ColorYellow,nil}
        end

        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),strTab,colorTab)

    end
    self.tipIcon = G_addMenuInfo(self.bgLayer,self.layerNum,tipPos,{},nil,nil,28,touchTip,true)

    self.tipIcon:setTouchPriority(-(self.layerNum-1)*20-14)


	sceneGame:addChild(self.bgLayer,self.layerNum)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-11)
	
	local function touch()
	end
	--self.touchEnabledSp=CCLayer:create()
	self.touchEnabledSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
    self.touchEnabledSp:setAnchorPoint(ccp(0,0))
	-- self.touchEnabledSp:setContentSize(CCSizeMake(self.sceneSp:getContentSize().width+self.sceneSp2:getContentSize().width,self.sceneSp:getContentSize().height))
    self.touchEnabledSp:setContentSize(CCSizeMake(self.sceneSp:getContentSize().width,self.sceneSp:getContentSize().height*sceneScale))
    self.touchEnabledSp:setPosition(self.startPos)
	--self.touchEnabledSp:setTouchEnabled(true)
	self.touchEnabledSp:setIsSallow(true)
	self.touchEnabledSp:setTouchPriority(-(self.layerNum-1)*20-11)
	sceneGame:addChild(self.touchEnabledSp,self.layerNum)
	self.touchEnabledSp:setOpacity(0)
	
    self:initFuben()
    self.isShowed=true
    table.insert(base.commonDialogOpened_WeakTb,self)
end
--[[
function allianceFubenScene:removeFuben()
    if self.fubenTab and SizeOfTable(self.fubenTab)>0 then
        if self.isRemoving==nil then
            self.isRemoving=false
        end
        if self.isRemoving==true then
            do return end
        end
        self.isRemoving=true
        for k,v in pairs(self.fubenTab) do
            if v and type(v)=="table" then
                for m,n in pairs(v) do
                    if n and type(n)=="table" then
                        for i,j in pairs(n) do
                            if j then
                                -- if type(j)~="userdata" then
                                    j:removeFromParentAndCleanup(true)
                                -- end
                                j=nil
                            end
                        end
                    else
                        if n then
                            -- if type(n)~="userdata" then
                                n:removeFromParentAndCleanup(true)
                            -- end
                            n=nil
                        end
                    end
                end
                v=nil
            else
                if v then
                    -- if type(v)~="userdata" then
                        v:removeFromParentAndCleanup(true)
                    -- end
                    v=nil
                end
            end
        end
    end
    self.fubenTab=nil
    self.fubenTab={}

    self.isRemoving=false
end
]]
function allianceFubenScene:initFuben()
    if self.isClosing==true then
        do return end
    end
    if self.isInitFuben==true then
        do return end
    end
    self.isInitFuben=true
    local chapterCfg=allianceFubenVoApi:getChapterCfg()
    local sectionCfg=allianceFubenVoApi:getSectionCfg()
    local chapter=chapterCfg[self.chapterId]

    local fubenVo=allianceFubenVoApi:getFuben()
    local unlockId=fubenVo.unlockId or 1
    local killNumTab=fubenVo.killCount or {}
    local awardNumTab=fubenVo.rewardCount or {}
    local tankNumTab=fubenVo.tank or {}

    local function clickHandler(object,name,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if self.isClosing==true then
            do return end
        end

        local chapterCfg=allianceFubenVoApi:getChapterCfg()
        local sectionCfg=allianceFubenVoApi:getSectionCfg()
        local chapter=chapterCfg[self.chapterId]
        local fubenVo=allianceFubenVoApi:getFuben()
        local unlockId=fubenVo.unlockId or 1
        local killNumTab=fubenVo.killCount or {}
        local awardNumTab=fubenVo.rewardCount or {}
        local tankNumTab=fubenVo.tank or {}

        local fubenId=(self.chapterId-1)*chapter.maxNum+tag
        if unlockId<fubenId then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        if self.fubenTab[tag].fubenSp then
            base:setWait()
            local isCall=true
            if type(self.fubenTab[tag].fubenSp)=="table" then
                for k,v in pairs(self.fubenTab[tag].fubenSp) do
                    -- if v and type(v)=="table" then
                    --     for m,n in pairs(v) do
                    --         local delayAction=CCDelayTime:create(0.6)
                    --         local fadeOut=CCTintTo:create(0.3,80,80,80)
                    --         local fadeIn=CCTintTo:create(0.3,255,255,255)
                    --         local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)

                    --         n:runAction(seq)
                    --         if isCall then
                    --             n:runAction(seq3)
                    --             isCall=false
                    --         end
                    --     end
                    -- else
                        local delayAction=CCDelayTime:create(0.6)
                        local fadeOut=CCTintTo:create(0.3,80,80,80)
                        local fadeIn=CCTintTo:create(0.3,255,255,255)
                        local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
                        local function callBack(...)
                            base:cancleWait()

                            local fubenId=(self.chapterId-1)*chapter.maxNum+tag
                            local fuben=sectionCfg[fubenId]

                            require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFubenDialog"
                            local td = allianceFubenDialog:new(fubenId)
                            local tbArr={}
                            local vd = td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal(fuben.name),true,self.layerNum+1)
                            sceneGame:addChild(vd,self.layerNum+1)
                        end
                        local callFunc=CCCallFunc:create(callBack)
                        local seq3=CCSequence:createWithTwoActions(delayAction,callFunc)

                        v:runAction(seq)
                        if isCall then
                            v:runAction(seq3)
                            isCall=false
                        end
                    -- end
                end
            else
                local delayAction=CCDelayTime:create(0.6)
                local fadeOut=CCTintTo:create(0.3,80,80,80)
                local fadeIn=CCTintTo:create(0.3,255,255,255)
                local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
                local function callBack(...)
                    base:cancleWait()

                    local fubenId=(self.chapterId-1)*chapter.maxNum+tag
                    local fuben=sectionCfg[fubenId]

                    require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFubenDialog"
                    local td = allianceFubenDialog:new(fubenId)
                    local tbArr={}
                    local vd = td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal(fuben.name),true,self.layerNum+1)
                    sceneGame:addChild(vd,self.layerNum+1)
                end
                local callFunc=CCCallFunc:create(callBack)
                local seq3=CCSequence:createWithTwoActions(delayAction,callFunc)

                self.fubenTab[tag].fubenSp:runAction(seq)
                self.fubenTab[tag].fubenSp:runAction(seq3)
            end 
        end

        if self.fubenTab[tag].gunSp then
            if type(self.fubenTab[tag].gunSp)=="table" then
                for k,v in pairs(self.fubenTab[tag].gunSp) do
                    if v and type(v)=="table" then
                        for m,n in pairs(v) do
                            if n then
                                local delayAction=CCDelayTime:create(0.6)
                                local fadeOut=CCTintTo:create(0.3,80,80,80)
                                local fadeIn=CCTintTo:create(0.3,255,255,255)
                                local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)

                                n:runAction(seq)
                            end
                        end
                    else
                        if v then
                            local delayAction=CCDelayTime:create(0.6)
                            local fadeOut=CCTintTo:create(0.3,80,80,80)
                            local fadeIn=CCTintTo:create(0.3,255,255,255)
                            local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)

                            v:runAction(seq)
                        end
                    end
                end
            else
                local delayAction=CCDelayTime:create(0.6)
                local fadeOut=CCTintTo:create(0.3,80,80,80)
                local fadeIn=CCTintTo:create(0.3,255,255,255)
                local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)

                self.fubenTab[tag].gunSp:runAction(seq)
            end 
        end
    end

    local function rewardHandler(object,name,tag)
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if self.isClosing==true then
            do return end
        end
        local fubenId=(self.chapterId-1)*chapter.maxNum+tag
        local fuben=sectionCfg[fubenId]
        local costDonate=tonumber(fuben.raisingConsume)
        local canUseDonate=allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid())

        local function fubenRewardHandler()
            if canUseDonate<costDonate then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage8038"),30)
                do return end
            end
            local function confirmHandler( ... )
                local function rewardCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        -- local reward=playerCfg.newGifts[3].award
                        local reward=sData.data.reward
                        local rewardTab=FormatItem(reward)

                        for k,v in pairs(rewardTab) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num)
                        end
                        G_showRewardTip(rewardTab)

                        local fubenVo=allianceFubenVoApi:getFuben()
                        local killNumTab=fubenVo.killCount or {}
                        local awardNumTab=fubenVo.rewardCount or {}
                        local fubenId1=(self.chapterId-1)*chapter.maxNum+tag
                        allianceFubenVoApi:setRewardCount(fubenId1)

                        local uid=playerVoApi:getUid()
                        allianceMemberVoApi:setUseDonate(uid,allianceMemberVoApi:getUseDonate(uid)+costDonate)
                        -- allianceMemberVoApi:setDonate(uid,canUseDonate-costDonate)

                        if acHeartOfIronVoApi then
                            acHeartOfIronVoApi:updateNum("acrd",1)
                        end
                        
                        self:refresh()
                    end
                end
                socketHelper:achallengeGetreward(fubenId,rewardCallback)
            end
            
            if costDonate>0 then
                local keyName = "alliance_getReward_cost"
                local function secondTipFunc(sbFlag)
                    local sValue=base.serverTime .. "_" .. sbFlag
                    G_changePopFlag(keyName,sValue)
                end
                if G_isPopBoard(keyName) then
                   G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des4",{costDonate}),true,confirmHandler,secondTipFunc)
                else
                    confirmHandler()
                end
            else
                confirmHandler()
            end

        end  
        fubenRewardHandler()
    end
    if self.isBossFu==true then --副本boss关卡
        self:initFubenBoss()
    else
        for i=1,chapter.maxNum do
            local fubenId=(self.chapterId-1)*chapter.maxNum+i
            local fuben=sectionCfg[fubenId]

            local tankTotalNum=0
            local tankNum=0
            local tankTab=FormatItem(fuben.tank)
            for k,v in pairs(tankTab) do
                if v then
                    tankTotalNum=tankTotalNum+v.num
                end
            end
            local tankFubenTab=tankNumTab[fubenId] or {}
            if tankFubenTab and SizeOfTable(tankFubenTab)>0 then
                for k,v in pairs(tankFubenTab) do
                    if v and tonumber(v[2]) then
                        tankNum=tankNum+tonumber(v[2])
                    end
                end
            end

            local isUnlock=false
            if fubenId<=unlockId then
                isUnlock=true
            end

            local isKill=false
            if tankNum<=0 then
                isKill=true
            end
            for k,v in pairs(killNumTab) do
                if tonumber(v)==fubenId then
                    isKill=true
                end
            end
            -- if tankNum<=0 then
            --     isKill=true
            -- else
            --     isKill=false
            -- end

            local isReward=false
            for k,v in pairs(awardNumTab) do
                if tonumber(v)==fubenId then
                    isReward=true
                end
            end

            local fubenSpPosX=fuben.pos[1].x
            local fubenSpPosY=G_VisibleSizeHeight-fuben.pos[1].y
            if fuben.pos[2] then
                fubenSpPosX=fuben.pos[2].x
                fubenSpPosY=G_VisibleSizeHeight-fuben.pos[2].y
            end
            local iphone5Space=50
            local iphoneXSpace=130
            if G_getIphoneType() == G_iphoneX then
                fubenSpPosY=fubenSpPosY - iphoneXSpace
            elseif G_getIphoneType() == G_iphone5 then
                fubenSpPosY=fubenSpPosY-iphone5Space
            end
            if self.fubenTab[i]==nil then
                self.fubenTab[i]={}
            end

            local fubenSp
            local lockSp
            local nameLabelBg
            local nameLabel
            local boxSp
            local boxOpenSp

            local arowData=fuben.arow
            if arowData~=nil then
                local arowX,arowY,arowRotation,bFlip=arowData.x,G_VisibleSizeHeight-arowData.y,arowData.rotation,arowData.bFlip
                if arowX~=nil and arowY~=nil and arowRotation~=nil then
                    local arowSp=CCSprite:create("story/CheckPointArow.png")
                    --local arowSp=CCSprite:createWithSpriteFrameName("CheckPointArow.png")
                    --arowSp:setAnchorPoint(ccp(0,0))
                    arowSp:setPosition(ccp(arowX,arowY))
                    if G_getIphoneType() == G_iphoneX then
                        arowSp:setPosition(ccp(arowX,arowY-iphoneXSpace))
                    elseif G_getIphoneType() == G_iphone5 then
                        arowSp:setPosition(ccp(arowX,arowY-iphone5Space))
                    end
                    arowSp:setRotation(arowRotation)
                    arowSp:setFlipX(bFlip)
                    arowSp:setScale(0.8)

                    self.clayer:addChild(arowSp,1)

                    self.fubenTab[i].arowSp=arowSp
                end
            end


            local scale=1.3
            local style1


            if i==5 then
                boxOpenSp=CCSprite:createWithSpriteFrameName("SeniorBoxOpen.png")
                boxSp=LuaCCSprite:createWithSpriteFrameName("SeniorBox.png",rewardHandler)
                boxOpenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY-60))
                boxSp:setPosition(ccp(fubenSpPosX,fubenSpPosY-60))
            else
                boxOpenSp=CCSprite:createWithSpriteFrameName("CommonBoxOpen.png")
                boxSp=LuaCCSprite:createWithSpriteFrameName("CommonBox.png",rewardHandler)
                boxOpenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                boxSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
            end
            boxSp:setTag(i)
            boxSp:setTouchPriority(-(self.layerNum-1)*20-13)
            boxSp:setIsSallow(false) 

            self.fubenTab[i].boxSp=boxSp
            self.fubenTab[i].boxOpenSp=boxOpenSp

            self.clayer:addChild(boxSp,1)
            self.clayer:addChild(boxOpenSp,1)



            if self.fubenTab[i].fubenSp==nil then
                self.fubenTab[i].fubenSp={}
            end
            if self.fubenTab[i].gunSp==nil then
                self.fubenTab[i].gunSp={}
            end
            local fubenSpTab={}

            if i==chapter.maxNum and SizeOfTable(fuben.icon)>1 then
                for k,v in pairs(fuben.icon) do
                    fubenSp=LuaCCSprite:createWithSpriteFrameName(v,clickHandler)
                    fubenSp:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y))
                    if G_getIphoneType() == G_iphoneX then
                        fubenSp:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y-iphoneXSpace))
                    elseif G_getIphoneType() == G_iphone5 then
                        fubenSp:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y-iphone5Space))
                    end
                    fubenSp:setTag(i)
                    if k==2 then
                        fubenSp:setScale(scale)
                    end

                    fubenSp:setTouchPriority(-(self.layerNum-1)*20-13)
                    fubenSp:setIsSallow(false)

                    self.clayer:addChild(fubenSp,2)

                    style1=Split(v,".png")
                    local style1Str=style1[1].."_1.".."png"
                    local gunSp=CCSprite:createWithSpriteFrameName(style1Str)

                    if gunSp~=nil then
                        gunSp:setPosition(getCenterPoint(fubenSp))
                        fubenSp:addChild(gunSp)
                        gunSp:setTag(i)
                        table.insert(self.fubenTab[i].gunSp,gunSp)
                    end

                    table.insert(self.fubenTab[i].fubenSp,fubenSp)
                end

            else
                fubenSp=LuaCCSprite:createWithSpriteFrameName(fuben.icon[1],clickHandler)
                style1=Split(fuben.icon[1],".png")
                fubenSp:setScale(scale)
            
                fubenSp:setTouchPriority(-(self.layerNum-1)*20-13)
                fubenSp:setIsSallow(false)

                fubenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                fubenSp:setTag(i)

                self.clayer:addChild(fubenSp,2)
                self.fubenTab[i].fubenSp=fubenSp

                local style1Str=style1[1].."_1.".."png"
                local gunSp=CCSprite:createWithSpriteFrameName(style1Str)
                -- self.chapterTab[chapterCfg.index].tankSp=gunSp
                if gunSp~=nil then
                    gunSp:setPosition(getCenterPoint(fubenSp))
                    fubenSp:addChild(gunSp)
                    gunSp:setTag(i)
                    self.fubenTab[i].gunSp=gunSp
                end
            end


            lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
            if fubenId==3 then
                lockSp:setPosition(ccp(fubenSpPosX,fubenSpPosY+15))
            else
                lockSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
            end
            self.clayer:addChild(lockSp,3)
            self.fubenTab[i].lockSp=lockSp




            --[[
            if isKill==true then
                if isReward==true then
                    self.fubenTab[i].boxSp:setVisible(false)
                    self.fubenTab[i].boxOpenSp:setVisible(true)

                    -- if i==5 then
                    --     fubenSp=CCSprite:createWithSpriteFrameName("SeniorBoxOpen.png")
                    --     fubenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY-60))
                    -- else
                    --     fubenSp=CCSprite:createWithSpriteFrameName("CommonBoxOpen.png")
                    --     fubenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                    -- end
                    -- self.clayer:addChild(fubenSp,1)

                    -- self.fubenTab[i].fubenSp=fubenSp
                else
                    self.fubenTab[i].boxSp:setVisible(true)
                    self.fubenTab[i].boxOpenSp:setVisible(false)           

                    -- if i==5 then
                    --     fubenSp=LuaCCSprite:createWithSpriteFrameName("SeniorBox.png",rewardHandler)
                    --     fubenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY-60))
                    -- else
                    --     fubenSp=LuaCCSprite:createWithSpriteFrameName("CommonBox.png",rewardHandler)
                    --     fubenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                    -- end
                    -- self.clayer:addChild(fubenSp,1)
                    -- fubenSp:setTag(i)

                    -- fubenSp:setTouchPriority(-(self.layerNum-1)*20-13)
                    -- fubenSp:setIsSallow(false)

                    -- self.fubenTab[i].fubenSp=fubenSp
                end
            else
                local isAdd=true 
                if self.fubenTab[i].fubenSp==nil then
                    self.fubenTab[i].fubenSp={}
                end
                if self.fubenTab[i].gunSp==nil then
                    self.fubenTab[i].gunSp={}
                end
                local fubenSpTab={}
                -- if not (checkPointVo and checkPointVo.isUnlock) then
                if isUnlock==false then
                    if i==chapter.maxNum and SizeOfTable(fuben.icon)>1 then
                        for k,v in pairs(fuben.icon) do
                            fubenSp=GraySprite:createWithSpriteFrameName(v)
                            fubenSp:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y))
                            if G_isIphone5()==true then
                                fubenSp:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y-iphone5Space))
                            end
                            fubenSp:setTag(i)
                            if k==2 then
                                fubenSp:setScale(scale)
                            end

                            self.clayer:addChild(fubenSp,2)

                            style1=Split(v,".png")
                            local style1Str=style1[1].."_1.".."png"
                            local gunSp=CCSprite:createWithSpriteFrameName(style1Str)
                            -- self.chapterTab[chapterCfg.index].tankSp=gunSp
                            if gunSp~=nil then
                                gunSp:setPosition(getCenterPoint(fubenSp))
                                fubenSp:addChild(gunSp)
                                gunSp:setTag(i)
                                table.insert(self.fubenTab[i].gunSp,gunSp)
                            end
                            -- table.insert(fubenSpTab,fubenSp)
                            table.insert(self.fubenTab[i].fubenSp,fubenSp)
                        end
                        -- self.fubenTab[i].fubenSp=fubenSpTab
                        isAdd=false
                    else
                        fubenSp=GraySprite:createWithSpriteFrameName(fuben.icon[1])
                        style1=Split(fuben.icon[1],".png")
                        fubenSp:setScale(scale)
                    end
                    -- fubenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                    -- fubenSp:setTag(i)

                    -- if i~=chapter.maxNum or (i==chapter.maxNum and k==2) then
                        lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
                        if fubenId==3 then
                            lockSp:setPosition(ccp(fubenSpPosX,fubenSpPosY+15))
                        else
                            lockSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                        end
                        self.clayer:addChild(lockSp,3)
                        --table.insert(self.fubenTab[i],{lockSp=lockSp})
                        self.fubenTab[i].lockSp=lockSp
                    -- end
                else
                    if i==chapter.maxNum and SizeOfTable(fuben.icon)>1 then
                        for k,v in pairs(fuben.icon) do
                            fubenSp=LuaCCSprite:createWithSpriteFrameName(v,clickHandler)
                            fubenSp:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y))
                            if G_isIphone5()==true then
                                fubenSp:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y-iphone5Space))
                            end
                            fubenSp:setTag(i)
                            if k==2 then
                                fubenSp:setScale(scale)
                            end

                            fubenSp:setTouchPriority(-(self.layerNum-1)*20-13)
                            fubenSp:setIsSallow(false)

                            self.clayer:addChild(fubenSp,2)

                            style1=Split(v,".png")
                            local style1Str=style1[1].."_1.".."png"
                            local gunSp=CCSprite:createWithSpriteFrameName(style1Str)
                            -- self.chapterTab[chapterCfg.index].tankSp=gunSp
                            if gunSp~=nil then
                                gunSp:setPosition(getCenterPoint(fubenSp))
                                fubenSp:addChild(gunSp)
                                gunSp:setTag(i)
                                table.insert(self.fubenTab[i].gunSp,gunSp)
                            end
                            -- table.insert(fubenSpTab,fubenSp)
                            table.insert(self.fubenTab[i].fubenSp,fubenSp)
                        end
                        -- self.fubenTab[i].fubenSp=fubenSpTab
                        isAdd=false
                    else
                        fubenSp=LuaCCSprite:createWithSpriteFrameName(fuben.icon[1],clickHandler)
                        style1=Split(fuben.icon[1],".png")
                        fubenSp:setScale(scale)
                    
                        fubenSp:setTouchPriority(-(self.layerNum-1)*20-13)
                        fubenSp:setIsSallow(false)
                    end
                end

                if isAdd==true then
                    fubenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                    fubenSp:setTag(i)

                    self.clayer:addChild(fubenSp,2)
                    self.fubenTab[i].fubenSp=fubenSp

                    local style1Str=style1[1].."_1.".."png"
                    local gunSp=CCSprite:createWithSpriteFrameName(style1Str)
                    -- self.chapterTab[chapterCfg.index].tankSp=gunSp
                    if gunSp~=nil then
                        gunSp:setPosition(getCenterPoint(fubenSp))
                        fubenSp:addChild(gunSp)
                        gunSp:setTag(i)
                        self.fubenTab[i].gunSp=gunSp
                    end
                end
            end
            ]]
            local nameTempLabel = GetTTFLabel("",25)

            if isKill then
                nameLabel=GetTTFLabel(getlocal("alliance_fuben_award_name",{fubenId}),25)
                nameTempLabel:setString(getlocal("alliance_fuben_award_name",{fubenId}))
            else
                nameLabel=GetTTFLabelWrap(getlocal(fuben.name),25,CCSizeMake(280,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                nameTempLabel:setString(getlocal(fuben.name))
            end
            local nameLabelWidth 
            if nameTempLabel:getContentSize().width>=nameLabel:getContentSize().width then
                nameLabelWidth = nameLabel:getContentSize().width
            else
                nameLabelWidth = nameTempLabel:getContentSize().width
            end
            local lbWidth=200

            local capInSet = CCRect(42, 26, 10, 10)
            local function cellClick(hd,fn,idx)
            end
            local serverTxtSp=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",capInSet,cellClick)
            -- if nameLabel:getContentSize().width+20>lbWidth then
            --     serverTxtSp:setContentSize(CCSizeMake(nameLabel:getContentSize().width+20,45))
            -- else
            --     serverTxtSp:setContentSize(CCSizeMake(lbWidth,45))
            -- end
            local serverTxtSpHeight = 45
            if nameLabel:getContentSize().height+20>serverTxtSpHeight then
                serverTxtSpHeight = nameLabel:getContentSize().height+20
            end
            if nameLabelWidth+20>lbWidth then
                serverTxtSp:setContentSize(CCSizeMake(nameLabelWidth+20,serverTxtSpHeight))
            else
                serverTxtSp:setContentSize(CCSizeMake(lbWidth,serverTxtSpHeight))
            end

            serverTxtSp:ignoreAnchorPointForPosition(false)
            serverTxtSp:setAnchorPoint(ccp(0.5,0.5))
            serverTxtSp:setIsSallow(false)
            serverTxtSp:setTouchPriority(-(self.layerNum-1)*20-12)

            local lableY=fubenSpPosY
            if fubenSp then
                if isKill==false then
                    lableY=lableY-fubenSp:getContentSize().height/2*scale-10
                    if i==1 or i==2 then
                        -- lableY=lableY
                    elseif i==3 then
                        lableY=lableY+50
                    elseif i==4 then
                        lableY=lableY+20
                    elseif i==5 then
                        lableY=lableY-60
                        fubenSpPosX=fubenSpPosX-10
                    end
                else 
                    if i==5 then
                        lableY=lableY-130
                    else
                        lableY=lableY-fubenSp:getContentSize().height/2*scale+10
                    end
                end
            end
            serverTxtSp:setPosition(ccp(fubenSpPosX,lableY))
            self.clayer:addChild(serverTxtSp,2)

            nameLabel:setPosition(getCenterPoint(serverTxtSp))
            serverTxtSp:addChild(nameLabel)
            self.fubenTab[i].serverTxtSp=serverTxtSp
            self.fubenTab[i].nameLabel=nameLabel
            
            
                -- local percentStr=tankNum.."/"..tankTotalNum
                local percentStr=""
                local percent=(tankNum/tankTotalNum)*100

                local proScaleX=0.56
                AddProgramTimer(self.clayer,ccp(fubenSpPosX,lableY-nameLabel:getContentSize().height/2-25),1000+fubenId,2000+fubenId,percentStr,"skillBg.png","skillBar.png",3000+fubenId,proScaleX)
                local ccprogress=self.clayer:getChildByTag(1000+fubenId)
                ccprogress=tolua.cast(ccprogress,"CCProgressTimer")
                ccprogress:setPercentage(percent)
                self.fubenTab[i].ccprogress=ccprogress

                local ccprogressBg=self.clayer:getChildByTag(3000+fubenId)
                ccprogressBg=tolua.cast(ccprogressBg,"CCSprite")
                self.fubenTab[i].ccprogressBg=ccprogressBg
            
            --[[
            if isUnlock==true then
                self.fubenTab[i].lockSp:setVisible(true)
            else
                self.fubenTab[i].lockSp:setVisible(false)
            end

            if isKill==false then
                self.fubenTab[i]serverTxtSpLabel:setString(getlocal(fuben.name))
                self.fubenTab[i].ccprogressBg:setVisible(true)
                tolua.cast(self.fubenTab[i].ccprogress,"CCProgressTimer"):setPercentage(percent)

                if self.fubenTab[i].fubenSp then
                    for k,v in pairs(self.fubenTab[i].fubenSp) do
                        if type(v)=="table" then
                            for m,n in pairs(v) do
                                n:setVisible(true)
                            end
                        else
                            v:setVisible(true)
                        end
                    end
                end
                
            else
                self.fubenTab[i].ccprogressBg:setVisible(false)
                self.fubenTab[i].nameLabel:setString(getlocal("alliance_fuben_award_name",{fubenId}))
            
                if isReward==true then
                    self.fubenTab[i].boxSp:setVisible(false)
                    self.fubenTab[i].boxOpenSp:setVisible(true)
                else
                    self.fubenTab[i].boxSp:setVisible(true)
                    self.fubenTab[i].boxOpenSp:setVisible(false)
                end

                if self.fubenTab[i].fubenSp then
                    for k,v in pairs(self.fubenTab[i].fubenSp) do
                        if type(v)=="table" then
                            for m,n in pairs(v) do
                                n:setVisible(true)
                            end
                        else
                            v:setVisible(true)
                        end
                    end
                end
            end

            ]]
            
        end
    end


    self:refresh()

    self.isInitFuben=false
end

function allianceFubenScene:initFubenBoss()
    local function nilFun()
    end
    local function showDetail()
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if self.bossDescTv then
            if self.bossDescTv:getScrollEnable()==true and self.bossDescTv:getIsScrolled()==true then
                do return end
            end
        end

        local killCount=allianceFubenVoApi:getAllianceBossKillCount()
        local function allianceBossGetHandler(fn,bossdata)
            local cret,cData=base:checkServerData(bossdata)
            if cret==true then
                -- allianceFubenScene:setShow(self.layerNum+1,chapterId)
                local curKill=allianceFubenVoApi:getAllianceBossKillCount()
                if tonumber(curKill)~=tonumber(killCount) then
                    allianceFubenVoApi:setFlag(1,0)
                end

                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFubenDialog"
                local td = allianceFubenDialog:new(0,true)
                local tbArr={}
                local vd = td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_fuben_chapterName_6"),true,self.layerNum+1)
                sceneGame:addChild(vd,self.layerNum+1)
            end
        end
        socketHelper:allianceBossGet(allianceBossGetHandler)
    end
    local capInSet=CCRect(20, 20, 10, 10)
    local bossMainSP=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,showDetail)
    bossMainSP:setContentSize(CCSizeMake(G_VisibleSize.width-200,500))
    bossMainSP:setAnchorPoint(ccp(0,1))
    bossMainSP:setPosition(20,self.clayer:getContentSize().height-100)
    bossMainSP:setOpacity(220)
    bossMainSP:setTouchPriority(-(self.layerNum-1)*20-13)
    self.clayer:addChild(bossMainSP,2)

    local bossTankIcon=CCSprite:createWithSpriteFrameName("t99999_1.png")
    bossTankIcon:setScale(0.3)
    bossTankIcon:setAnchorPoint(ccp(0,1))
    bossTankIcon:setPosition(10,bossMainSP:getContentSize().height-20)
    bossMainSP:addChild(bossTankIcon)
    local bossW=bossTankIcon:getContentSize().width*bossTankIcon:getScaleX()
    local bossH=bossTankIcon:getContentSize().height*bossTankIcon:getScaleY()

    local sectionRect=CCRect(0, 0, 177, 111)
    local sectionW=200
    local sectionH=120
    local sectionbg1=LuaCCScale9Sprite:createWithSpriteFrameName("alliance_boss_dissectionbg.png",sectionRect,nilFun)
    sectionbg1:setContentSize(CCSizeMake(sectionW,sectionH))
    sectionbg1:setAnchorPoint(ccp(0,1))
    sectionbg1:setPosition(20,bossTankIcon:getPositionY()-bossH-20)
    bossMainSP:addChild(sectionbg1,2)
    local section1=CCSprite:createWithSpriteFrameName("alliance_boss_dissection2.png")
    -- section1:setScale(0.2)
    section1:setPosition(sectionbg1:getContentSize().width/2,sectionbg1:getContentSize().height/2)
    sectionbg1:addChild(section1)

    local sectionbg2=LuaCCScale9Sprite:createWithSpriteFrameName("alliance_boss_dissectionbg.png",sectionRect,nilFun)
    sectionbg2:setContentSize(CCSizeMake(sectionW,sectionH))
    sectionbg2:setAnchorPoint(ccp(0,1))
    sectionbg2:setPosition(20,sectionbg1:getPositionY()-sectionbg1:getContentSize().height-20)
    bossMainSP:addChild(sectionbg2,2)
    local section2=CCSprite:createWithSpriteFrameName("alliance_boss_dissection1.png")
    -- section2:setScale(0.2)
    section2:setPosition(sectionbg2:getContentSize().width/2,sectionbg2:getContentSize().height/2)
    sectionbg2:addChild(section2)

    local descMainSP=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),nilFun)
    descMainSP:setContentSize(CCSizeMake(210,bossMainSP:getContentSize().height-60))
    descMainSP:setAnchorPoint(ccp(0,0.5))
    descMainSP:setPosition(bossMainSP:getContentSize().width-descMainSP:getContentSize().width-10,bossMainSP:getContentSize().height/2)
    bossMainSP:addChild(descMainSP)

    local textTb={getlocal("alliance_boss_name")," ",getlocal("alliance_boss_desc")}
    local colorTb={G_ColorYellowPro,G_ColorWhite,G_ColorWhite}
    local alignmentTb={kCCTextAlignmentCenter,kCCTextAlignmentCenter,kCCTextAlignmentLeft}
    local bossDescTv=G_LabelTableView(CCSizeMake(descMainSP:getContentSize().width-20,descMainSP:getContentSize().height-20),textTb,25,alignmentTb,colorTb)
    bossDescTv:setTableViewTouchPriority(-(self.layerNum-1)*20-13)
    bossDescTv:setPosition(10,10)
    descMainSP:addChild(bossDescTv)
    self.bossDescTv=bossDescTv

    local arrow1=LuaCCScale9Sprite:createWithSpriteFrameName("samllmap_line1.png",CCRect(40,10,20,5),nilFun)
    arrow1:setContentSize(CCSizeMake(bossMainSP:getContentSize().width,24))
    arrow1:setAnchorPoint(ccp(0,1))
    arrow1:setPosition(-10,arrow1:getContentSize().height/2)
    bossMainSP:addChild(arrow1,2)
    local arrow2=LuaCCScale9Sprite:createWithSpriteFrameName("samllmap_line2.png",CCRect(0,0,50,2),nilFun)
    arrow2:setContentSize(CCSizeMake(120,2))
    arrow2:setAnchorPoint(ccp(0,1))
    arrow2:setPosition(arrow1:getContentSize().width-10,0)
    arrow2:setRotation(60)
    bossMainSP:addChild(arrow2,2)

    local smallMap=LuaCCScale9Sprite:createWithSpriteFrameName("boss_fuben_smallmap.png",CCRect(0,0,184,156),showDetail)
    smallMap:setContentSize(CCSizeMake(184,156))
    smallMap:setAnchorPoint(ccp(1,0))
    smallMap:setPosition(G_VisibleSize.width,180)
    smallMap:setTouchPriority(-(self.layerNum-1)*20-13)
    self.clayer:addChild(smallMap,1)
    local smallMapPoint=CCSprite:createWithSpriteFrameName("localWar_miniMap_point1.png")
    smallMapPoint:setAnchorPoint(ccp(0,0))
    smallMapPoint:setPosition(28,50)
    smallMap:addChild(smallMapPoint,1)

    local pointNameLb=GetTTFLabel(getlocal("alliance_fuben_chapterName_6"),25)
    local pointSp=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",CCRect(42, 26, 10, 10),nilFun)
    pointSp:setContentSize(CCSizeMake(150,pointNameLb:getContentSize().height+20))
    pointSp:ignoreAnchorPointForPosition(false)
    pointSp:setAnchorPoint(ccp(0.5,1))
    pointSp:setPosition(ccp(smallMap:getContentSize().width/2,-10))
    smallMap:addChild(pointSp)
    pointNameLb:setPosition(ccp(pointSp:getContentSize().width/2,pointSp:getContentSize().height/2))
    pointSp:addChild(pointNameLb)

    local state,lefttime=allianceFubenVoApi:getFubenBossState()   
    local timeSp=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilFun)
    timeSp:setContentSize(CCSizeMake(200,40))
    timeSp:setAnchorPoint(ccp(0.5,0))
    timeSp:setPosition(ccp(pointSp:getContentSize().width/2,pointSp:getContentSize().height))
    pointSp:addChild(timeSp)
    local timeLb=GetTTFLabel(getlocal("alliance_boss_back",{lefttime.."s"}),25)
    timeLb:setPosition(ccp(timeSp:getContentSize().width/2,timeSp:getContentSize().height/2))
    timeSp:addChild(timeLb,1)
    timeLb:setColor(G_ColorYellowPro)
    timeSp:setVisible(false)
    self.timeSp=timeSp
    self.timeLb=timeLb
    if state==2 and tonumber(lefttime)>0 then
        timeSp:setVisible(true)
    end

    local reward=allianceFubenVoApi:getBossFubenRewards()
    if reward then
        reward=FormatItem(reward)
        reward=reward[1]
        local rewardDialog=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),nilFun)
        rewardDialog:setContentSize(CCSizeMake(G_VisibleSize.width-10,100))
        rewardDialog:setAnchorPoint(ccp(0.5,0))
        rewardDialog:setPosition(G_VisibleSize.width/2,0)
        self.clayer:addChild(rewardDialog,2)

        local function showPropInfo()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            propInfoDialog:create(sceneGame,reward,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
        end
        local boxSp=LuaCCSprite:createWithSpriteFrameName(reward.pic,showPropInfo)
        boxSp:setAnchorPoint(ccp(0,0.5))
        boxSp:setScale(0.8)
        boxSp:setTouchPriority(-(self.layerNum-1)*20-13)
        rewardDialog:addChild(boxSp,2)
        boxSp:setPosition(ccp(20,rewardDialog:getContentSize().height/2))

        local rewardNameLb=GetTTFLabel(reward.name,25)
        rewardNameLb:setAnchorPoint(ccp(0,0))
        rewardNameLb:setPosition(ccp(boxSp:getPositionY()+boxSp:getContentSize().width*boxSp:getScaleX()+10,boxSp:getPositionY()+5))
        rewardDialog:addChild(rewardNameLb)
        local bcount=allianceFubenVoApi:getAllianceBossRewardCount()
        local countLb=GetTTFLabel(getlocal("propInfoNum",{bcount}),25)
        countLb:setAnchorPoint(ccp(0,1))
        countLb:setPosition(ccp(boxSp:getPositionY()+boxSp:getContentSize().width*boxSp:getScaleX()+10,boxSp:getPositionY()-5))
        rewardDialog:addChild(countLb)
        self.bossRewardLb=countLb

        local function rewardHandler()
            PlayEffect(audioCfg.mouseClick)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end  
            local costDonate=tonumber(alliancebossCfg.raisingConsume)
            local canUseDonate=allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid())
            if canUseDonate<costDonate then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage8038"),30)
                do return end
            end
            local function confirmHandler( ... )
                local function rewardsCallBack(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        local reward=sData.data.reward
                        local rewardTab=FormatItem(reward)
                        for k,v in pairs(rewardTab) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num)
                        end
                        allianceFubenVoApi:setBossRewardCount(1)
                        local uid=playerVoApi:getUid()
                        allianceMemberVoApi:setUseDonate(uid,allianceMemberVoApi:getUseDonate(uid)+costDonate)
                        --弹出奖励面板
                        G_showRewardTip(rewardTab)
                        self:refresh()
                        allianceFubenVoApi:setFlag(1,0)
                    end
                end
                socketHelper:allianceRewardGetOneTime(nil,1,rewardsCallBack)
            end
            local keyName = "alliance_getReward_cost"
            local function secondTipFunc(sbFlag)
                local sValue=base.serverTime .. "_" .. sbFlag
                G_changePopFlag(keyName,sValue)
            end
            if G_isPopBoard(keyName) then
               G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des4",{costDonate}),true,confirmHandler,secondTipFunc)
            else
                confirmHandler()
            end
        end
        local menuItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,nil,getlocal("daily_scene_get"),25)
        local scale=0.9
        menuItem:setScale(scale)
        local menu=CCMenu:createWithItem(menuItem)
        menu:setPosition(ccp(rewardDialog:getContentSize().width-menuItem:getContentSize().width/2*scale-20,rewardDialog:getContentSize().height/2))
        menu:setTouchPriority(-(self.layerNum-1)*20-13)
        rewardDialog:addChild(menu)
        if tonumber(bcount)<=0 then
            menuItem:setEnabled(false)
        end
        self.bossRewardBtn=menuItem
    end
end

function allianceFubenScene:touchEvent(fn,x,y,touch)
    do return end
    --[[
    if fn=="began" then
        if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 or newGuidMgr:isNewGuiding()==true then
             return 0
        end
        self.isMoved=false
        self.touchArr[touch]=touch
        local touchIndex=0
        for k,v in pairs(self.touchArr) do
            local temTouch= tolua.cast(v,"CCTouch")
            if self and temTouch then
                if touchIndex==0 then
                     self.firstOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                else
                     self.secondOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                end
            end
            touchIndex=touchIndex+1
        end
        if touchIndex==1 then
            self.secondOldPos=nil
            self.lastTouchDownPoint=self.firstOldPos
        end
        if SizeOfTable(self.touchArr)>1 then
            self.multTouch=true
        else
            self.multTouch=false
        end
        return 1
    elseif fn=="moved" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
             do
                return
             end
        end
        self.isMoved=true
        if self.multTouch==true then --双点触摸

        else --单点触摸
             local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
             local moveDisPos=ccpSub(curPos,self.firstOldPos)
             local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
              if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<3 then
                 self.isMoved=false
                 do
                    return
                 end
             end
             --self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,(curPos.y-self.firstOldPos.y)*3)
             self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,0)
             local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),ccp(moveDisPos.x,0))
             self.clayer:setPosition(tmpPos)
             self:checkBound()
             self.firstOldPos=curPos
             self.isMoving=true
        end
    elseif fn=="ended" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
             do
                return
             end
        end
       if self.touchArr[touch]~=nil then
           self.touchArr[touch]=nil
           local touchIndex=0
            for k,v in pairs(self.touchArr) do
                if touchIndex==0 then
                     self.firstOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                else
                     self.secondOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                end
                touchIndex=touchIndex+1
            end
            if touchIndex==1 then
                self.secondOldPos=nil
            end
            if SizeOfTable(self.touchArr)>1 then
                self.multTouch=true
            else
                self.multTouch=false
            end
       end
       if  self.isMoving==true then
            self.isMoving=false
            local tmpToPos=ccpAdd(ccp(self.clayer:getPosition()),self.autoMoveAddPos)
            tmpToPos=self:checkBound(tmpToPos)

            local ccmoveTo=CCMoveTo:create(0.15,tmpToPos)
            local cceaseOut=CCEaseOut:create(ccmoveTo,3)
            self.clayer:runAction(cceaseOut)
       end
    else
        self.touchArr=nil
        self.touchArr={}
    end
    ]]
end


function allianceFubenScene:checkBound(pos)
		local tmpPos
		if pos==nil then
		   	tmpPos= ccp(self.clayer:getPosition())
		else
		   	tmpPos=pos
		end
		if tmpPos.x>0 then
		    tmpPos.x=0
		-- elseif tmpPos.x<(G_VisibleSize.width-(self.sceneSp:boundingBox().size.width+self.sceneSp2:boundingBox().size.width)) then
		--    	tmpPos.x=G_VisibleSize.width-(self.sceneSp:boundingBox().size.width+self.sceneSp2:boundingBox().size.width)
		-- end
        elseif tmpPos.x<(G_VisibleSize.width-(self.sceneSp:boundingBox().size.width)) then
            tmpPos.x=G_VisibleSize.width-(self.sceneSp:boundingBox().size.width)
        end

		if pos==nil then
		   	self.clayer:setPosition(tmpPos)
		else
		   	return tmpPos
		end
end



function allianceFubenScene:focusOn()
    if self and self.clayer then
        self.clayer:setPosition(ccp(0,0))
        if self.touchEnabledSp then
            self.touchEnabledSp:setPosition(ccp(0,0))
            self.touchEnabledSp:setVisible(true)
        end
        self:checkBound()
    end
end



function allianceFubenScene:setShow(layerNum,chapterId)
    if chapterId then
        self.chapterId=chapterId
    end
    if layerNum then
        self.layerNum=layerNum
    else
        self.layerNum=4
    end
    self.isBossFu=allianceFubenVoApi:isBossFuben(chapterId)
    if self.isBossFu==true then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/t99999Image.plist")
        spriteController:addPlist("public/boss_fuben_images.plist")
        spriteController:addTexture("public/boss_fuben_images.png")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar2.plist")
        spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
        spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    end
    -- self:close()

    -- base:setWait()
    self.isShowed=true
    -- if self.bgLayer==nil then
        self:show()
	-- else
	-- 	self:refresh()
 --    end
	-- if self.touchEnabledSp then
	-- 	self.touchEnabledSp:setPosition(self.startPos)
	-- end
	self:focusOn()
    self.touchEnable=true
    -- self.touchEnable=false

    G_AllianceDialogTb["allianceFubenScene"]=self

    if G_WeakTb and G_WeakTb.allianceDialog then
        G_WeakTb.allianceDialog:setDisplay(false)
    end

    --[[
    -- self.isMoved=false 
    self.bgLayer:setVisible(false)
  --   if newGuidMgr:isNewGuiding()==true then
		-- if self.pointerSp~=nil then
  --       	self.pointerSp:setVisible(false)
		-- end
  --   else
		-- if self.pointerSp~=nil then
	 --        self.pointerSp:setVisible(true)
		-- end
  --   end
    local fadeIn=CCFadeOutDownTiles:create(0.5,CCSizeMake(16,12))
    local back=fadeIn:reverse()
    

    local function callBack()
            self.bgLayer:setVisible(true)
    end
    local callFunc=CCCallFunc:create(callBack)
    local carray=CCArray:create()
        --carray:addObject(back)
        carray:addObject(callFunc)
    local spawn=CCSpawn:create(carray)

    local function hideUIHandler()
        self.bgLayer:stopAllActions()
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setHide()
            elseif sceneController.curIndex==1 then
                mainLandScene:setHide()
            elseif sceneController.curIndex==2 then
                worldScene:setHide()
            end
            mainUI:setHide()
        end
        base:cancleWait()
    end
    local hideUIFunc=CCCallFunc:create(hideUIHandler)
    local seq=CCSequence:createWithTwoActions(spawn,hideUIFunc)
    self.bgLayer:runAction(seq)
    ]]
end

function allianceFubenScene:setShowWhenEndBattle()
 --    if self.bgLayer==nil then
 --        -- self:setShow()
	-- else
	-- 	self:refresh()
 --    end
    if self and self.bgLayer~=nil then
        if self.beforeHideIsShow==true then
            self:focusOn()
            self.touchEnable=true
            -- self.touchEnable=false
            -- self.isMoved=false 
            self.bgLayer:setVisible(true)
            self.isShowed=true
        end
    elseif base.allShowedCommonDialog==0 then
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setShow()
            elseif sceneController.curIndex==1 then
                mainLandScene:setShow()
            elseif sceneController.curIndex==2 then
                worldScene:setShow()
            end
            mainUI:setShow()
        end
    end
end
function allianceFubenScene:setHide(hasAnim)
    if self and self.bgLayer~=nil then
        self.isShowed=false
        if self.touchEnabledSp then
            self.touchEnabledSp:setPosition(ccp(0,10000))
            self.touchEnabledSp:setVisible(false)
        end
        self.clayer:setPosition(ccp(0,10000))
        -- self:removeFuben()

		--self.touchEnabledSp:removeFromParentAndCleanup(true)
		--self.touchEnabledSp=nil
		
        
        -- if self.touchEnable==false then
        --     self.beforeHideIsShow=false
        -- else
            self.beforeHideIsShow=true
        -- end
        self.touchEnable=false
        self.bgLayer:setVisible(false)
        --[[
        base:setWait()
        if hasAnim==false then
            self.bgLayer:setVisible(false)
            base:cancleWait()
            base:cancleNetWait()
        else
            --local fadeOut=CCFadeOutDownTiles:create(0.5,CCSizeMake(16,12))
            --local function callBack()
                self.bgLayer:stopAllActions()
                self.bgLayer:setVisible(false)
                base:cancleWait()
           -- end
           -- local callFunc=CCCallFunc:create(callBack)
            --local seq=CCSequence:createWithTwoActions(fadeOut,callFunc)
            --self.bgLayer:runAction(seq)
            if base.allShowedCommonDialog==0 then
            
                 if portScene.clayer~=nil then
                    if sceneController.curIndex==0 then
                        portScene:setShow()
                    elseif sceneController.curIndex==1 then
                        mainLandScene:setShow()
                    elseif sceneController.curIndex==2 then
                        worldScene:setShow()
                    end
                    mainUI:setShow()
                end


            end
        end
        ]]
        
    end
    
end

function allianceFubenScene:refresh()
    if self and self.bgLayer and self.isShowed==true then
        -- self:removeFuben()
        -- self:initFuben()
        -- self:setShow(self.layerNum,self.chapterId)
        if self.isBossFu==true then
            if self.bossRewardLb and self.bossRewardBtn then
                local bcount=allianceFubenVoApi:getAllianceBossRewardCount()
                self.bossRewardLb:setString(getlocal("propInfoNum",{bcount}))
                if tonumber(bcount)>0 then
                    self.bossRewardBtn:setEnabled(true)
                else
                    self.bossRewardBtn:setEnabled(false)
                end
            end
        else
            local chapterCfg=allianceFubenVoApi:getChapterCfg()
            local sectionCfg=allianceFubenVoApi:getSectionCfg()
            local chapter=chapterCfg[self.chapterId]

            local fubenVo=allianceFubenVoApi:getFuben()
            local unlockId=fubenVo.unlockId or 1
            local killNumTab=fubenVo.killCount or {}
            local awardNumTab=fubenVo.rewardCount or {}
            local tankNumTab=fubenVo.tank or {}
            for i=1,chapter.maxNum do
                local fubenId=(self.chapterId-1)*chapter.maxNum+i
                local fuben=sectionCfg[fubenId]

                local tankTotalNum=0
                local tankNum=0
                local tankTab=FormatItem(fuben.tank)
                for k,v in pairs(tankTab) do
                    if v then
                        tankTotalNum=tankTotalNum+v.num
                    end
                end
                local tankFubenTab=tankNumTab[fubenId] or {}
                if tankFubenTab and SizeOfTable(tankFubenTab)>0 then
                    for k,v in pairs(tankFubenTab) do
                        if v and tonumber(v[2]) then
                            tankNum=tankNum+tonumber(v[2])
                        end
                    end
                end

                local isUnlock=false
                if fubenId<=unlockId then
                    isUnlock=true
                end

                local isKill=false
                if tankNum<=0 then
                    isKill=true
                end
                for k,v in pairs(killNumTab) do
                    if tonumber(v)==fubenId then
                        isKill=true
                    end
                end
                -- if tankNum<=0 then
                --     isKill=true
                -- else
                --     isKill=false
                -- end

                local isReward=false
                for k,v in pairs(awardNumTab) do
                    if tonumber(v)==fubenId then
                        isReward=true
                    end
                end

                local fubenSpPosX=fuben.pos[1].x
                local fubenSpPosY=G_VisibleSizeHeight-fuben.pos[1].y
                if fuben.pos[2] then
                    fubenSpPosX=fuben.pos[2].x
                    fubenSpPosY=G_VisibleSizeHeight-fuben.pos[2].y
                end
                local iphone5Space=50
                local iphoneXSpace=130
                if G_getIphoneType() == G_iphoneX then
                    fubenSpPosY=fubenSpPosY-iphoneXSpace
                elseif G_getIphoneType() == G_iphone5 then
                    fubenSpPosY=fubenSpPosY-iphone5Space
                end

                if self.fubenTab[i]==nil then
                    self.fubenTab[i]={}
                end
                


                if self.fubenTab[i].lockSp then
                    if isUnlock==true then
                        self.fubenTab[i].lockSp:setVisible(false)
                    else
                        self.fubenTab[i].lockSp:setVisible(true)
                    end
                end


                

                if isKill==false then

                    if self.fubenTab[i].ccprogress and self.fubenTab[i].ccprogressBg then
                        local percent=(tankNum/tankTotalNum)*100
                        self.fubenTab[i].ccprogressBg:setVisible(true)
                        tolua.cast(self.fubenTab[i].ccprogress,"CCProgressTimer"):setPercentage(percent)               
                    end
                    if self.fubenTab[i].nameLabel then
                        self.fubenTab[i].nameLabel:setString(getlocal(fuben.name))
                    end

                    if self.fubenTab[i].fubenSp then
                        if type(self.fubenTab[i].fubenSp)=="table" then
                            for k,v in pairs(self.fubenTab[i].fubenSp) do

                                v:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y))
                                if G_getIphoneType() == G_iphoneX then
                                    v:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y-iphoneXSpace))
                                elseif G_getIphoneType() == G_iphone5 then
                                    v:setPosition(ccp(fuben.pos[k].x,G_VisibleSizeHeight-fuben.pos[k].y-iphone5Space))
                                end

                                -- if type(v)=="table" then
                                --     for m,n in pairs(v) do
                                --         n:setVisible(true)
                                --         n:setTouchEnabled(true)
                                --     end
                                -- else
                                    v:setVisible(true)
                                    -- v:setTouchEnabled(true)
                                -- end
                            end
                        else
                            
                            self.fubenTab[i].fubenSp:setVisible(true)
                            self.fubenTab[i].fubenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                        end
                    end

                    if self.fubenTab[i].boxSp then
                        self.fubenTab[i].boxSp:setVisible(false)
                        self.fubenTab[i].boxSp:setPosition(ccp(0,10000))
                    end
                    if self.fubenTab[i].boxOpenSp then
                        self.fubenTab[i].boxOpenSp:setVisible(false)
                        self.fubenTab[i].boxOpenSp:setPosition(ccp(0,10000))
                    end
                else
                    if self.fubenTab[i].ccprogress and self.fubenTab[i].ccprogressBg then
                        self.fubenTab[i].ccprogressBg:setVisible(false)
                        tolua.cast(self.fubenTab[i].ccprogress,"CCProgressTimer"):setVisible(false)
                    end
                    if self.fubenTab[i].nameLabel then
                        self.fubenTab[i].nameLabel:setString(getlocal("alliance_fuben_award_name",{fubenId}))
                    end    

                    if self.fubenTab[i].fubenSp then
                        if type(self.fubenTab[i].fubenSp)=="table" then
                            for k,v in pairs(self.fubenTab[i].fubenSp) do

                                v:setPosition(ccp(0,10000))

                                -- if type(v)=="table" then
                                --     for m,n in pairs(v) do
                                --         n:setVisible(false)
                                --         n:setTouchEnabled(false)
                                --     end
                                -- else
                                    v:setVisible(false)
                                    -- v:setTouchEnabled(false)
                                -- end
                            end
                        else
                            self.fubenTab[i].fubenSp:setVisible(false)
                            self.fubenTab[i].fubenSp:setPosition(ccp(0,10000))
                        end
                    end

                    if isReward==true then
                        if self.fubenTab[i].boxSp then
                            self.fubenTab[i].boxSp:setVisible(false)
                            self.fubenTab[i].boxSp:setPosition(ccp(0,10000))
                        end
                        if self.fubenTab[i].boxOpenSp then
                            self.fubenTab[i].boxOpenSp:setVisible(true)
                            if i==5 then
                                self.fubenTab[i].boxOpenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY-60))
                            else
                                self.fubenTab[i].boxOpenSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                            end
                        end
                    else
                        if self.fubenTab[i].boxSp then
                            self.fubenTab[i].boxSp:setVisible(true)
                            if i==5 then
                                self.fubenTab[i].boxSp:setPosition(ccp(fubenSpPosX,fubenSpPosY-60))
                            else
                                self.fubenTab[i].boxSp:setPosition(ccp(fubenSpPosX,fubenSpPosY))
                            end
                        end
                        if self.fubenTab[i].boxOpenSp then
                            self.fubenTab[i].boxOpenSp:setVisible(false)
                            self.fubenTab[i].boxOpenSp:setPosition(ccp(0,10000))
                        end
                        
                    end
                end

            end
        end

        
    end
end

function allianceFubenScene:tick()
    if self and self.bgLayer and self.isShowed==true then
        if allianceFubenVoApi:getFlag(3)==0 or allianceFubenVoApi:isRefreshData()==true then
            self:refresh()
            allianceFubenVoApi:setFlag(3,1)
        end
        --处理副本boss复活
        local state,lefttime=allianceFubenVoApi:getFubenBossState()
        if self.timeSp and self.timeLb then
            if state==2 and tonumber(lefttime)>0 then
                self.timeSp:setVisible(true)
                self.timeLb:setString(getlocal("alliance_boss_back",{lefttime.."s"}))
            else
                self.timeSp:setVisible(false)
            end
        end
    end
end

function allianceFubenScene:close()
    self.isClosing=true
    if G_WeakTb and G_WeakTb.allianceDialog then
        G_WeakTb.allianceDialog:setDisplay(true)
    end
    if base.allShowedCommonDialog==0 then
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setShow()
            elseif sceneController.curIndex==1 then
                mainLandScene:setShow()
            elseif sceneController.curIndex==2 then
                worldScene:setShow()
            end
            mainUI:setShow()
        end
    end
    self:dispose()
end

function allianceFubenScene:dispose()
    if self.isBossFu==true then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ship/t99999Image.plist")
        spriteController:removePlist("public/boss_fuben_images.plist")
        spriteController:removeTexture("public/boss_fuben_images.png")
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/localWar/localWar2.plist")
        spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
        spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
    end
    G_AllianceDialogTb["allianceFubenScene"]=nil
    if self.touchEnabledSp then
        self.touchEnabledSp:removeFromParentAndCleanup(true)
        self.touchEnabledSp=nil
    end
    -- self:removeFuben()
    self.fubenTab={}
    self.tipIcon=nil
    self.closeBtn=nil
    --[[
    if self.sceneSp then
        self.sceneSp:removeFromParentAndCleanup(true)
    end
    if self.clayer then
        self.clayer:removeFromParentAndCleanup(true)
    end
    ]]
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    self.sceneSp=nil
    self.clayer=nil
    self.bgLayer=nil
    self.touchArr={}
    self.multTouch=false
    self.firstOldPos=nil
    self.secondOldPos=nil
    --startPos=ccp(0,100)
    --topPos=ccp(0,-100)
    self.startPos=ccp(0,0)
    self.topPos=ccp(0,0)
    self.minScale=0.8
    self.maxScale=1.3
    self.isMoving=false
    self.isZooming=false
    self.autoMoveAddPos=nil
    self.touchEnable=true
    -- self.touchEnable=false
    self.isMoved=false
    self.isShowed=false
    self.isInitFuben=false

	-- self.pointerSp=nil
    self.beforeHideIsShow=false
    -- self.checkPointDialog={}
    self.isClosing=false
    self.fubenRewardSd=nil
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
        if v==self then
            table.remove(base.commonDialogOpened_WeakTb,k)
            break
        end
    end
    self.isBossFu=false
    self.bossRewardLb=nil
    self.timeSp=nil
    self.timeLb=nil
    self.bossRewardBtn=nil
    self.bossDescTv=nil
end
