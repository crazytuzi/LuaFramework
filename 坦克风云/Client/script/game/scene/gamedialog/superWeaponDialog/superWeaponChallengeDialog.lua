superWeaponChallengeDialog=commonDialog:new()

function superWeaponChallengeDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
    
    return nc
end

function superWeaponChallengeDialog:initTableView()
    -- self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    -- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    self.panelLineBg:setVisible(false)
    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width,G_VisibleSizeHeight),nil)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- self.tv:setPosition(ccp(30,30))
    -- self.bgLayer:addChild(self.tv)
    -- self.tv:setMaxDisToBottomOrTop(120)
    -- self.bgLayer:reorderChild(self.closeBtn,2)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local challengeBg=CCSprite:create("public/superWeapon/challengeBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    challengeBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    --机型适配
    if G_getIphoneType() == G_iphoneX then
        challengeBg:setScaleY(G_VisibleSizeHeight/challengeBg:getContentSize().height)
    end

    self.bgLayer:addChild(challengeBg)

    local cVo=superWeaponVoApi:getSWChallenge()
    if cVo==nil or SizeOfTable(cVo)==0 then
        do return end
    end

    self:initHeader()
    self:initTanks()
    self:initBottom()

    if(eventDispatcher:hasEventHandler("superWeapon.tanksMove",self.onTanksMoveListener)==false)then
        eventDispatcher:addEventListener("superWeapon.tanksMove",self.onTanksMoveListener)
    end

    self.lastCurPos=cVo.curClearPos
    local function onBattleEnd(event,data)
        local challengeVo=superWeaponVoApi:getSWChallenge()
        if(challengeVo.maxClearPos==1)then
            self:showGuideDialog()
        end
    end
    self.eventListener=onBattleEnd
    eventDispatcher:addEventListener("superweapon.guide.battleEnd",onBattleEnd)

    local leftTime=superWeaponVoApi:getRaidLeftTime()
    if leftTime and leftTime>0 then
        self:initLoading()
    end
end

function superWeaponChallengeDialog:initHeader()
    local function cellClick1(hd,fn,idx)
    end
    local titleSp=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),cellClick1)
    titleSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,70))
    titleSp:ignoreAnchorPointForPosition(false)
    titleSp:setAnchorPoint(ccp(0.5,1))
    titleSp:setIsSallow(false)
    titleSp:setTouchPriority(-(self.layerNum-1)*20-1)
    titleSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-5))
    self.bgLayer:addChild(titleSp,11)
    local titleLb=GetTTFLabel(getlocal("super_weapon_title_2"),32,true)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(getCenterPoint(titleSp))
    titleSp:addChild(titleLb)
    -- curPosY=curPosY-titleSp1:getContentSize().height
    local function close()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(self.layerNum-1)*20-11)
    closeBtn:setPosition(ccp(self.bgLayer:getContentSize().width-closeBtnItem:getContentSize().width,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(closeBtn,12)


    local cVo=superWeaponVoApi:getSWChallenge()
    local curIndex=cVo.curClearPos+1
    if curIndex>SizeOfTable(swChallengeCfg.list) then
        curIndex=SizeOfTable(swChallengeCfg.list)
    end
    local usedCNum=cVo.hasCNum
    local buyCNum=cVo.buyCNum

    local lbPosX1=140
    local lbWidth1,lbWidth3=200,200
    local lbPosX2=lbPosX1
    local lbWidth2=self.bgLayer:getContentSize().width-lbPosX2-20-80
    local lbPosY=self.bgLayer:getContentSize().height-115
    local lbSpace=50
    local cfg=swChallengeCfg.list[curIndex]
    local npcNameStr=superWeaponVoApi:getSWChallengeName(curIndex)
    local clearanceConditionStr=superWeaponVoApi:getClearConditionStr(curIndex)
    local leftChallengeNum=swChallengeCfg.challengeNum+buyCNum-usedCNum
    local baseRewardTb=FormatItem(cfg.clientReward.base)
    local baseRewardItem=baseRewardTb[1]
    local rewardNum=baseRewardItem.num
    local strSize2,strSize3 = 20,20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 = 20
        lbWidth1 = 150
        lbPosX1 = 140
    else
        strSize3 = 15
        lbWidth3 = 110
    end
    local lbTb={
        {getlocal("super_weapon_challenge_current_location"),strSize3,ccp(1,0.5),ccp(lbPosX1,lbPosY),self.bgLayer,2,G_ColorYellowPro,CCSize(lbWidth3,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter},
        {npcNameStr,strSize2,ccp(0,0.5),ccp(lbPosX2,lbPosY),self.bgLayer,2,nil,CCSize(lbWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {getlocal("super_weapon_challenge_clearance_condition"),strSize3,ccp(1,0.5),ccp(lbPosX1,lbPosY-lbSpace),self.bgLayer,2,G_ColorYellowPro,CCSize(lbWidth3,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter},
        {clearanceConditionStr,strSize2,ccp(0,0.5),ccp(lbPosX2,lbPosY-lbSpace),self.bgLayer,2,nil,CCSize(lbWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {getlocal("super_weapon_challenge_num"),strSize3,ccp(1,0.5),ccp(lbPosX1,lbPosY-lbSpace*2),self.bgLayer,2,G_ColorYellowPro,CCSize(lbWidth3,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter},
        {leftChallengeNum,strSize2,ccp(0,0.5),ccp(lbPosX2,lbPosY-lbSpace*2),self.bgLayer,2,nil,CCSize(lbWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {getlocal("super_weapon_challenge_reward"),strSize3,ccp(1,0.5),ccp(lbPosX1,lbPosY-lbSpace*3),self.bgLayer,2,G_ColorYellowPro,CCSize(lbWidth3,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter},
        {rewardNum,strSize2,ccp(0,0.5),ccp(lbPosX2,lbPosY-lbSpace*3),self.bgLayer,2,nil,CCSize(lbWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
    }
    for k,v in pairs(lbTb) do
        local lb=GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
        if k==2 then
            self.npcNameLb=lb
        elseif k==4 then
            self.clearConditionLb=lb
        elseif k==6 then
            self.leftNumLb=lb
        elseif k==8 then
            self.rewardNumLb=lb
        end
        if k%2==0 then
            local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
            lbBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-150,45))
            lbBg:setAnchorPoint(ccp(0,0.5))
            lbBg:setPosition(ccp(20,lb:getPositionY()))
            self.bgLayer:addChild(lbBg,1)
            lbBg:setOpacity(180)
        end
    end
    local posHeight = 0
    if G_getCurChoseLanguage() =="ru" then
        posHeight =25
    end
    local swchallengeactiveVO = activityVoApi:getActivityVo("swchallengeactive")
    if swchallengeactiveVO ~=nil and activityVoApi:isStart(swchallengeactiveVO) == true then
        local activityDescStr = ""
        activityDescStr=getlocal("activity_swchallengeactive_addDesc",{acSwchallengeactiveVoApi:getActivityLocalName()})
        
        self.activityDescLb = GetTTFLabelWrap(activityDescStr,30,CCSizeMake(self.bgLayer:getContentSize().width-40, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        self.activityDescLb:setAnchorPoint(ccp(0.5,1))
        self.activityDescLb:setPosition(ccp(self.bgLayer:getContentSize().width/2, lbPosY-lbSpace*4+15+posHeight))
        self.bgLayer:addChild(self.activityDescLb)
        self.activityDescLb:setColor(G_ColorYellowPro)
    end

    local itemSp=CCSprite:createWithSpriteFrameName("sw_8.png")
    itemSp:setPosition(ccp(275,lbPosY-lbSpace*3))
    itemSp:setScale(0.6)
    self.bgLayer:addChild(itemSp,1)

    local function showBigReward()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local cVo=superWeaponVoApi:getSWChallenge()
        local curIndex=cVo.curClearPos+1
        if curIndex>SizeOfTable(swChallengeCfg.list) then
            curIndex=SizeOfTable(swChallengeCfg.list)
        end
        local cfg=swChallengeCfg.list[curIndex]
        if cfg and cfg.clientReward and cfg.clientReward.rand then
            local rewardTb=cfg.clientReward.rand
            local bigReward=FormatItem(rewardTb)
            if bigReward and SizeOfTable(bigReward)>0 then
                superWeaponVoApi:showChallengeRewardSmallDialog(curIndex,1,self.layerNum+1)
            end
        end
    end
    local rewardTb=cfg.clientReward.rand
    local bigReward=FormatItem(rewardTb)
    self.bigRewardSp=LuaCCSprite:createWithSpriteFrameName("SeniorBox.png",showBigReward)
    self.bigRewardSp:setPosition(ccp(345,lbPosY-lbSpace*3))
    self.bigRewardSp:setScale(0.5)
    self.bigRewardSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.bigRewardSp,1)
    if bigReward and SizeOfTable(bigReward)>0 then
    else
        self.bigRewardSp:setVisible(false)
    end

    local function showInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={"\n",getlocal("super_weapon_challenge_info"),"\n"}
        local tabColor={nil,G_ColorYellowPro,nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1) 
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
    infoItem:setScale(0.9)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-60,lbPosY))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(infoBtn,1)
end
function superWeaponChallengeDialog:refreshTanks(isMove,isOnClear)
    local midWidth=self.bgLayer:getContentSize().width/2
    local midHeight=self.bgLayer:getContentSize().height/2-30

    if self.tankSpTb==nil then
        self.tankSpTb={}
    end
    if self.tankSpTb and SizeOfTable(self.tankSpTb)>0 then
        for k,v in pairs(self.tankSpTb) do
            if v then
                v:removeFromParentAndCleanup(true)
            end
        end
        self.tankSpTb={}
    end

    local cVo=superWeaponVoApi:getSWChallenge()
    local curIndex=cVo.curClearPos+1
    if curIndex>SizeOfTable(swChallengeCfg.list) then
        curIndex=SizeOfTable(swChallengeCfg.list)
    end
    local cfg=swChallengeCfg.list[curIndex]
    local tankTb=cfg.tank
    -- tankTb={{"a10007",20},{"a10007",20},{"a10007",20},{"a10007",20},{"a10007",20},{"a10007",20},}
    for k,v in pairs(tankTb) do
        if v and v[1] and v[2] then
            local tid=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
            local num=tonumber(v[2]) or 0
            local tankSp=G_getTankPic(tid)
            if tankSp then
                local posx,posy
                if k==1 then
                    posx,posy=midWidth-150,midHeight-70
                elseif k==2 then
                    posx,posy=midWidth,midHeight
                elseif k==3 then
                    posx,posy=midWidth+20,midHeight-125
                elseif k==4 then
                    posx,posy=midWidth-75,midHeight+100
                elseif k==5 then
                    posx,posy=midWidth+125,midHeight+100
                elseif k==6 then
                    posx,posy=midWidth+150,midHeight-30
                end
                self.bgLayer:addChild(tankSp)
                table.insert(self.tankSpTb,tankSp)
                if isMove==true then
                    tankSp:setPosition(ccp(posx+600,posy+450))
                    local function movedCallBack()
                    end
                    local moveTo=CCMoveTo:create(1,ccp(posx,posy))
                    local callFunc=CCCallFunc:create(movedCallBack)
                    local seq=CCSequence:createWithTwoActions(moveTo,callFunc)
                    tankSp:runAction(seq)
                else
                    tankSp:setPosition(ccp(posx,posy))
                end
            end
        end
    end
end
function superWeaponChallengeDialog:initTanks()
    local midWidth=self.bgLayer:getContentSize().width/2
    local midHeight=self.bgLayer:getContentSize().height/2-15

    local cVo=superWeaponVoApi:getSWChallenge()
    local curIndex=cVo.curClearPos+1
    if curIndex>SizeOfTable(swChallengeCfg.list) then
        curIndex=SizeOfTable(swChallengeCfg.list)
    end
    local cfg=swChallengeCfg.list[curIndex]

    local function attackHandler(hd,fn,idx)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:showAttackDialog()
    end
    local touchAreaSp =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),attackHandler)
    touchAreaSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-200,self.bgLayer:getContentSize().height-600))
    touchAreaSp:ignoreAnchorPointForPosition(false)
    touchAreaSp:setAnchorPoint(ccp(0.5,0.5))
    touchAreaSp:setIsSallow(false)
    touchAreaSp:setTouchPriority(-(self.layerNum-1)*20-4)
    touchAreaSp:setPosition(ccp(midWidth,midHeight))
    self.bgLayer:addChild(touchAreaSp)
    touchAreaSp:setOpacity(0)

    self:refreshTanks()
end

function superWeaponChallengeDialog:showAttackDialog()
    if(otherGuideMgr.isGuiding and otherGuideMgr.curStep==7)then
        otherGuideMgr:toNextStep()
    end

    local leftTime=superWeaponVoApi:getRaidLeftTime()
    if leftTime>0 then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_can_not_attack_tip_1"),30)
        do return end
    end

    local cVo1=superWeaponVoApi:getSWChallenge()
    local curIndex1=tonumber(cVo1.curClearPos)+1
    if curIndex1>SizeOfTable(swChallengeCfg.list) then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_clear_all"),30)
        do return end
    end

    require "luascript/script/game/scene/gamedialog/warDialog/tankStoryDialog"
    local td=tankStoryDialog:new(nil,nil,nil,nil,curIndex1)
    local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("goFighting"),true,7)
    sceneGame:addChild(dialog,7)
end

function superWeaponChallengeDialog:initBottom()

    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =22
    end
    local curPosY=35
    local midWidth=self.bgLayer:getContentSize().width/2
    local cVo=superWeaponVoApi:getSWChallenge()
    local resetNum=superWeaponVoApi:getLeftResetNum()
    local lbTb={
        {getlocal("elite_challenge_reset_num",{resetNum}),strSize2,ccp(0.5,0.5),ccp(midWidth,curPosY),self.bgLayer,1,nil,CCSize(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
    }
    for k,v in pairs(lbTb) do
        self.leftResetNumLb=GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
    end

    curPosY=curPosY+70
    local btnPosY=curPosY
    local function resetHandler( ... )
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local leftTime=superWeaponVoApi:getRaidLeftTime()
        if leftTime>0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_can_not_reset_tip_1"),30)
            do return end
        end

        local function resetChallengeCallback()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionRestartSuccess"),30)
            self:refreshTanks()
            self:tick()
        end
        local free
        local cVo2=superWeaponVoApi:getSWChallenge()
        local lastRestTime1=cVo2.lastRestTime
        if G_isToday(lastRestTime1)==false then
            free=true
        else
            local resetCost=superWeaponVoApi:getResetCost()
            if(resetCost>playerVoApi:getGems())then
                GemsNotEnoughDialog(nil,nil,resetCost - playerVoApi:getGems(),self.layerNum+1,resetCost)
                do return end
            end
            free=false
        end
        local function onConfirm()
            superWeaponVoApi:resetChallenge(free,resetChallengeCallback)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("super_weapon_challenge_reset_desc"),nil,self.layerNum+1)
    end
    self.resetBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",resetHandler,1,getlocal("dailyTaskReset"),24/0.8,101)
    self.resetBtn:setScale(0.8)
    local btnLb = self.resetBtn:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local menuReset=CCMenu:createWithItem(self.resetBtn)
    menuReset:setAnchorPoint(ccp(0,0))
    menuReset:setPosition(ccp(120,btnPosY))
    menuReset:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menuReset,1)
    self.resetBtn2=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",resetHandler,1,getlocal("super_weapon_challenge_free_reset"),24/0.8,101)
    self.resetBtn2:setScale(0.8)
    local btnLb = self.resetBtn2:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local menuReset2=CCMenu:createWithItem(self.resetBtn2)
    menuReset2:setAnchorPoint(ccp(0,0))
    menuReset2:setPosition(ccp(120,btnPosY))
    menuReset2:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menuReset2,1)
    local lastRestTime=cVo.lastRestTime
    if G_isToday(lastRestTime)==false then
        -- local lb=tolua.cast(self.resetBtn:getChildByTag(101),"CCLabelTTF")
        -- lb:setString(getlocal("super_weapon_challenge_free_reset"))
        self.resetBtn:setVisible(false)
        self.resetBtn:setEnabled(false)
        self.resetBtn2:setVisible(true)
        self.resetBtn2:setEnabled(true)
    else
        self.resetBtn:setVisible(true)
        self.resetBtn2:setVisible(false)
        self.resetBtn2:setEnabled(false)
        if resetNum<=0 then
            self.resetBtn:setEnabled(false)
        else
            self.resetBtn:setEnabled(true)
        end
    end
    
    -- local function speedUpHandler( ... )
    --     if G_checkClickEnable()==false then
    --         do
    --             return
    --         end
    --     else
    --         base.setWaitTime=G_getCurDeviceMillTime()
    --     end
    --     PlayEffect(audioCfg.mouseClick)

    --     local leftTime=superWeaponVoApi:getRaidLeftTime()
    --     if leftTime>0 then
    --         local speedUpGems=superWeaponVoApi:raidSpeedUpCost(leftTime)
    --         if(speedUpGems>playerVoApi:getGems())then
    --             GemsNotEnoughDialog(nil,nil,speedUpGems - playerVoApi:getGems(),self.layerNum+1,speedUpGems)
    --             do return end
    --         end
    --         local function finishCallback()
    --             smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_raid_complete"),30)
    --         end
    --         local function onConfirm()
    --             superWeaponVoApi:raidChallengeFinish(true,finishCallback)
    --         end
    --         smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("super_weapon_challenge_speed_up_desc",{speedUpGems}),nil,self.layerNum+1)
    --     end
    -- end
    -- self.speedUpBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",speedUpHandler,2,getlocal("gemCompleted"),25,102)
    -- local menuSpeedUp=CCMenu:createWithItem(self.speedUpBtn)
    -- menuSpeedUp:setAnchorPoint(ccp(0,0))
    -- menuSpeedUp:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnPosY))
    -- menuSpeedUp:setTouchPriority(-(self.layerNum-1)*20-4)
    -- self.bgLayer:addChild(menuSpeedUp,1)

    local function attackHandler(hd,fn,idx)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:showAttackDialog()
    end
    -- local attackBtn=GetButtonItem("IconAttackBtn.png","IconAttackBtn_Down.png","IconAttackBtn_Down.png",attackHandler,2,nil,0)
    local attackBtn=GetButtonItem("alien_mines_attack_on.png","alien_mines_attack.png","alien_mines_attack.png",attackHandler,2,nil,0)
    attackBtn:setScale(1.5)
    local menuAttack=CCMenu:createWithItem(attackBtn)
    menuAttack:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnPosY+90))
    menuAttack:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menuAttack,1)
    local attackLb=GetTTFLabel(getlocal("RankScene_attack"),24,true)
    attackLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnPosY))
    self.bgLayer:addChild(attackLb,1)
    

    local function raidHandler( ... )
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local leftTime=superWeaponVoApi:getRaidLeftTime()
        if leftTime>0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_can_not_attack_tip_2"),30)
            do return end
        end
        
        local cVo=superWeaponVoApi:getSWChallenge()
        if cVo then
            local curPos=tonumber(cVo.curClearPos)
            local maxPos=tonumber(cVo.maxClearPos)
            if curPos>=maxPos then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_raid_tip_1"),30)
                do return end
            end
        end
        local function raidCallback(moPrivilegeFlag)
            if moPrivilegeFlag ~= true then
                self:initLoading()
            end
        end
        superWeaponVoApi:showChallengeRaidSmallDialog(self.layerNum+1,raidCallback)
    end
    self.raidBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",raidHandler,3,getlocal("elite_challenge_raid_btn"),24/0.8,103)
    self.raidBtn:setScale(0.8)
    local btnLb = self.raidBtn:getChildByTag(103)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local menuRaid=CCMenu:createWithItem(self.raidBtn)
    menuRaid:setAnchorPoint(ccp(0,0))
    menuRaid:setPosition(ccp(self.bgLayer:getContentSize().width-120,btnPosY))
    menuRaid:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menuRaid,1)


    local resetGems=superWeaponVoApi:getResetCost()
    local leftTime=superWeaponVoApi:getRaidLeftTime()
    -- local speedUpGems=superWeaponVoApi:raidSpeedUpCost(leftTime)
    curPosY=curPosY+60
    self.resetGemsLb=GetTTFLabel(resetGems,25)
    self.resetGemsLb:setPosition(ccp(120-20,curPosY))
    self.bgLayer:addChild(self.resetGemsLb,1)
    local goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp1:setPosition(ccp(120+30,curPosY))
    self.bgLayer:addChild(goldSp1,1)
    -- self.speedUpGemsLb=GetTTFLabel(speedUpGems,25)
    -- self.speedUpGemsLb:setPosition(ccp(self.bgLayer:getContentSize().width/2-20,curPosY))
    -- self.bgLayer:addChild(self.speedUpGemsLb,1)
    -- local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
    -- goldSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2+30,curPosY))
    -- self.bgLayer:addChild(goldSp2,1)

    -- self.countDownLb=GetTTFLabel(G_getTimeStr(leftTime),25)
    -- self.countDownLb:setAnchorPoint(ccp(0.5,0.5))
    -- self.countDownLb:setPosition(ccp(self.bgLayer:getContentSize().width-120,curPosY))
    -- self.bgLayer:addChild(self.countDownLb,1)
    -- if leftTime<=0 then
    --     self.countDownLb:setVisible(false)
    --     -- self.speedUpBtn:setEnabled(false)
    -- end


    -- curPosY=curPosY+40
    local spPosx=self.bgLayer:getContentSize().width-70
    curPosY=320--self.bgLayer:getContentSize().height-320
    local function showRewardInfo( ... )
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        superWeaponVoApi:showCRewardListDialog(self.layerNum+1)
    end
    local rewardSp=LuaCCSprite:createWithSpriteFrameName("SeniorBox.png",showRewardInfo)
    -- rewardSp:setPosition(ccp(self.bgLayer:getContentSize().width-200,curPosY))
    rewardSp:setPosition(ccp(spPosx,curPosY))
    rewardSp:setScale(0.5)
    rewardSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rewardSp,1)

    local function showRankList()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        superWeaponVoApi:showCRankDialog(self.layerNum+1)
    end
    local rankSp=LuaCCSprite:createWithSpriteFrameName("mainBtnRank.png",showRankList)
    -- rankSp:setPosition(ccp(self.bgLayer:getContentSize().width-70,curPosY))
    rankSp:setPosition(ccp(spPosx,curPosY-100))
    rankSp:setScale(0.8)
    rankSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rankSp,1)

    -- curPosY=curPosY+30
    local strSize4 = 24
    if G_getCurChoseLanguage() =="de" then
        strSize4 = 20
    end
    local lbTb2={
        -- {getlocal("super_weapon_challenge_reward_preview"),strSize2,ccp(0.5,0),ccp(self.bgLayer:getContentSize().width-200,curPosY),self.bgLayer,1,nil,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom},
        -- {getlocal("mainRank"),25,ccp(0.5,0),ccp(self.bgLayer:getContentSize().width-70,curPosY),self.bgLayer,1,nil,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom},
        {getlocal("super_weapon_challenge_reward_preview"),strSize4,ccp(0.5,0.5),ccp(spPosx,curPosY-40),self.bgLayer,1,nil,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold"},
        {getlocal("mainRank"),24,ccp(0.5,0.5),ccp(spPosx,curPosY-100-40),self.bgLayer,1,nil,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold"},
    }
    for k,v in pairs(lbTb2) do
        GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
    end

    
end


function superWeaponChallengeDialog:initLoading()
    if self.cLayer then
        self.cLayer:removeFromParentAndCleanup(true)
        self.cLayer=nil
    end
    if self.cLayer1 then
        self.cLayer1:removeFromParentAndCleanup(true)
        self.cLayer1=nil
    end

    -- local layer2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    -- local loadingTexture2=spriteController:getTexture("public/serverWarLocal/sceneBg.jpg")
    -- local loadingBg2=CCSprite:createWithTexture(loadingTexture2)
    local loadingBg2 = CCSprite:create("public/serverWarLocal/sceneBg.jpg")
    local tankBg2=CCSprite:createWithSpriteFrameName("dwLoading4.png")
    local tankSp12=CCSprite:createWithSpriteFrameName("dwLoading2.png")
    local tankSp22=CCSprite:createWithSpriteFrameName("dwLoading3.png")
    local wheelSp2=CCSprite:createWithSpriteFrameName("dwLoading1.png")
    local roundPoint2=CCSprite:createWithSpriteFrameName("dwLoading5.png")
    if loadingBg2 and tankBg2 and tankSp12 and tankSp22 and wheelSp2 and roundPoint2 then
    else
        -- self:raidCallback()
        do return end
    end

    self.cLayer1 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    self.cLayer1:setTouchPriority(-(self.layerNum-1)*20-5)
    self.cLayer1:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    self.cLayer1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.bgLayer:addChild(self.cLayer1,9)
    local tmpLayer1 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    tmpLayer1:setTouchPriority(-(self.layerNum-1)*20-1)
    tmpLayer1:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    tmpLayer1:setPosition(getCenterPoint(self.cLayer1))
    self.cLayer1:addChild(tmpLayer1)

    self.cLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    self.cLayer:setTouchPriority(-(self.layerNum-1)*20-5)
    self.cLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    -- self.cLayer:setOpacity(200)
    -- self.cLayer:setAnchorPoint(ccp(0,0))
    -- self.cLayer:setPosition(ccp(G_VisibleSizeWidth,0))
    -- self.cLayer:runAction(CCMoveTo:create(0.8,ccp(0,0)))
    self.cLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.cLayer:setScale(0.1)
    local scaleTo1=CCScaleTo:create(0.4,1.1)
    local scaleTo2=CCScaleTo:create(0.1,1)
    local acArr=CCArray:create()
    acArr:addObject(scaleTo1)
    acArr:addObject(scaleTo2)
    local seq=CCSequence:create(acArr)
    self.cLayer:runAction(seq)
    self.cLayer:setOpacity(0)
    
    -- local loadingTexture=spriteController:getTexture("public/serverWarLocal/sceneBg.jpg")
    -- local loadingBg=CCSprite:createWithTexture(loadingTexture)
    local loadingBg = CCSprite:create("public/serverWarLocal/sceneBg.jpg")
    loadingBg:setColor(ccc3(220,220,220))
    loadingBg:setScale(G_VisibleSizeWidth/loadingBg:getContentSize().width)
    loadingBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.cLayer:addChild(loadingBg)
    self.loadingBg=loadingBg

    local raidFinishData=superWeaponVoApi:getShowRaidFinishData()
    if superWeaponVoApi:getShowRaidFinishData() then
        local costTime=raidFinishData.costTime
        local floorNum=raidFinishData.floorNum
        local txtPy=G_VisibleSizeHeight/2+155
        local curFloorLb=GetTTFLabelWrap(getlocal("sw_raid_finish_desc",{curFloor}),30,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        curFloorLb:setAnchorPoint(ccp(0.5,0.5))
        curFloorLb:setPosition(G_VisibleSizeWidth/2,txtPy)
        self.cLayer:addChild(curFloorLb,1)
        curFloorLb:setColor(G_ColorYellowPro)
        local rlbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),function ()end)
        rlbBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-180,curFloorLb:getContentSize().height+10))
        rlbBg:setPosition(ccp(G_VisibleSizeWidth/2,txtPy))
        self.cLayer:addChild(rlbBg)

        txtPy=G_VisibleSizeHeight/2+60--160
        local txtBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        txtBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,50))
        txtBg:setPosition(ccp(1000,txtPy))
        self.cLayer:addChild(txtBg)
        local leftFloorLb=GetTTFLabel(getlocal("sw_raid_floor_num",{floorNum}),25)
        -- leftFloorLb:setAnchorPoint(ccp(0.5,0.5))
        leftFloorLb:setPosition(getCenterPoint(txtBg))
        txtBg:addChild(leftFloorLb,5)
        txtBg:setVisible(false)
        local function callBack( ... )
            txtBg:setVisible(true)
        end
        local callFunc=CCCallFunc:create(callBack)
        local delay=CCDelayTime:create(0.5)
        local moveTo=CCMoveTo:create(0.5,ccp(self.cLayer:getContentSize().width/2,txtPy))
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(callFunc)
        acArr:addObject(moveTo)
        local seq=CCSequence:create(acArr)
        txtBg:runAction(seq)

        txtPy=G_VisibleSizeHeight/2-20
        local txtBg1=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        txtBg1:setContentSize(CCSizeMake(G_VisibleSizeWidth,50))
        txtBg1:setPosition(ccp(1000,txtPy))
        self.cLayer:addChild(txtBg1)
        local leftTimeLb=GetTTFLabel(getlocal("sw_raid_cost_time",{GetTimeStr(costTime)}),25)
        -- leftTimeLb:setAnchorPoint(ccp(1,0.5))
        leftTimeLb:setPosition(getCenterPoint(txtBg1))
        txtBg1:addChild(leftTimeLb,5)
        txtBg1:setVisible(false)
        local function callBack1( ... )
            txtBg1:setVisible(true)
        end
        local callFunc1=CCCallFunc:create(callBack1)
        delay=CCDelayTime:create(0.8)
        moveTo=CCMoveTo:create(0.5,ccp(self.cLayer:getContentSize().width/2,txtPy))
        local acArr1=CCArray:create()
        acArr1:addObject(delay)
        acArr1:addObject(callFunc1)
        acArr1:addObject(moveTo)
        local seq1=CCSequence:create(acArr1)
        txtBg1:runAction(seq1)

        txtPy=G_VisibleSizeHeight/2-100
        local txtBg2=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        txtBg2:setContentSize(CCSizeMake(G_VisibleSizeWidth,50))
        txtBg2:setPosition(ccp(1000,txtPy))
        self.cLayer:addChild(txtBg2)
        -- local rewardLb=GetTTFLabel(getlocal("sw_raid_reward"),25)
        local colorTab={nil,G_ColorYellowPro,nil}
        local rewardLb,lbHeight=G_getRichTextLabel(getlocal("sw_raid_reward"),colorTab,25,G_VisibleSizeWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,0,true)
        rewardLb:setAnchorPoint(ccp(0.5,1))
        rewardLb:setPosition(ccp(txtBg2:getContentSize().width/2,txtBg2:getContentSize().height/2+lbHeight/2))
        txtBg2:addChild(rewardLb,5)
        txtBg2:setVisible(false)
        local function callBack2( ... )
            txtBg2:setVisible(true)
        end
        local callFunc2=CCCallFunc:create(callBack2)
        delay=CCDelayTime:create(1.3)
        moveTo=CCMoveTo:create(0.5,ccp(self.cLayer:getContentSize().width/2,txtPy))
        local acArr2=CCArray:create()
        acArr2:addObject(delay)
        acArr2:addObject(callFunc2)
        acArr2:addObject(moveTo)
        local seq2=CCSequence:create(acArr2)
        txtBg2:runAction(seq2)

        self.bgLayer:addChild(self.cLayer,10)

        local function sureHandler( ... )
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if self.cLayer then
                self.cLayer:removeFromParentAndCleanup(true)
                self.cLayer=nil
            end
            if self.cLayer1 then
                self.cLayer1:removeFromParentAndCleanup(true)
                self.cLayer1=nil
            end
        end
        local sureItem=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",sureHandler,11,getlocal("ok"),25)
        local sureMenu=CCMenu:createWithItem(sureItem)
        sureMenu:setPosition(ccp(self.cLayer1:getContentSize().width/2,105))
        sureMenu:setTouchPriority(-(self.layerNum-1)*20-11)
        self.cLayer1:addChild(sureMenu,3)

        superWeaponVoApi:setShowRaidFinishData(nil)
    else
        local tankBg=CCSprite:createWithSpriteFrameName("dwLoading4.png")
        tankBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
        self.cLayer:addChild(tankBg)
        self.tankBg=tankBg
        self.tankSp1=CCSprite:createWithSpriteFrameName("dwLoading2.png")
        self.tankSp1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
        self.cLayer:addChild(self.tankSp1)
        self.tankSp2=CCSprite:createWithSpriteFrameName("dwLoading3.png")
        self.tankSp2:setVisible(false)
        self.tankSp2:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
        self.cLayer:addChild(self.tankSp2)
        self.wheelTb={}
        for i=1,4 do
            local wheelSp=CCSprite:createWithSpriteFrameName("dwLoading1.png")
            wheelSp:setPosition(G_VisibleSizeWidth/2 - 32 + 16*(i - 1) + 8,G_VisibleSizeHeight/2 - 22)
            self.cLayer:addChild(wheelSp)
            local rotateBy=CCRotateBy:create(0.4,-360)
            wheelSp:runAction(CCRepeatForever:create(rotateBy))
            table.insert(self.wheelTb,wheelSp)
        end
        local roundPoint=CCSprite:createWithSpriteFrameName("dwLoading5.png")
        roundPoint:setAnchorPoint(ccp(-3.8,0.5))
        roundPoint:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
        self.cLayer:addChild(roundPoint)
        local rotateBy=CCRotateBy:create(1,360)
        roundPoint:runAction(CCRepeatForever:create(rotateBy))
        self.roundPoint=roundPoint

        local waitLb=GetTTFLabelWrap(getlocal("sw_raid_waiting"),25,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        waitLb:setAnchorPoint(ccp(0.5,0.5))
        waitLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-80)
        self.cLayer:addChild(waitLb,1)

        local leftTime=superWeaponVoApi:getRaidLeftTime()
        local curFloor,leftFloor=superWeaponVoApi:getRaidFloor()
        self.curFloor=curFloor
        local txtPy=G_VisibleSizeHeight/2+155
        self.curFloorLb=GetTTFLabelWrap(getlocal("sw_raid_current_floor",{curFloor}),30,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.curFloorLb:setAnchorPoint(ccp(0.5,0.5))
        self.curFloorLb:setPosition(G_VisibleSizeWidth/2,txtPy)
        self.cLayer:addChild(self.curFloorLb,1)
        self.curFloorLb:setColor(G_ColorYellowPro)
        local rlbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),function ()end)
        rlbBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-180,self.curFloorLb:getContentSize().height+10))
        rlbBg:setPosition(G_VisibleSizeWidth/2,txtPy)
        self.cLayer:addChild(rlbBg)

        txtPy=G_VisibleSizeHeight/2-160
        local txtBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        txtBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,50))
        txtBg:setPosition(G_VisibleSizeWidth/2,txtPy)
        self.cLayer:addChild(txtBg)
        self.leftFloorLb=GetTTFLabel(getlocal("sw_raid_left_floor",{leftFloor}),25)
        self.leftFloorLb:setAnchorPoint(ccp(0,0.5))
        self.leftFloorLb:setPosition(20,txtPy)
        self.cLayer:addChild(self.leftFloorLb,1)
        self.leftTimeLb=GetTTFLabel(getlocal("costTime1",{GetTimeStr(leftTime)}),25)
        self.leftTimeLb:setAnchorPoint(ccp(1,0.5))
        self.leftTimeLb:setPosition(G_VisibleSizeWidth-20,txtPy)
        self.cLayer:addChild(self.leftTimeLb,1)

        self.bgLayer:addChild(self.cLayer,10)


        local function speedUpHandler()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            -- if self.cLayer then
            --     self.cLayer:removeFromParentAndCleanup(true)
            --     self.cLayer=nil
            -- end
            -- if self.cLayer1 then
            --     self.cLayer1:removeFromParentAndCleanup(true)
            --     self.cLayer1=nil
            -- end
            local leftTime=superWeaponVoApi:getRaidLeftTime()
            if leftTime>0 then
                local speedUpGems=superWeaponVoApi:raidSpeedUpCost(leftTime)
                if(speedUpGems>playerVoApi:getGems())then
                    GemsNotEnoughDialog(nil,nil,speedUpGems - playerVoApi:getGems(),self.layerNum+1,speedUpGems)
                    do return end
                end
                local function finishCallback()
                    -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_raid_complete"),30)
                end
                local function onConfirm()
                    superWeaponVoApi:raidChallengeFinish(true,finishCallback)
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("super_weapon_challenge_speed_up_desc",{speedUpGems}),nil,self.layerNum+1)
            end
        end
        -- local closeItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",closeCLayer,11,getlocal("fight_close"),25)
        -- local closeMenu = CCMenu:createWithItem(closeItem)
        -- -- closeMenu:setPosition(ccp(self.cLayer:getContentSize().width/2,120))
        -- closeMenu:setPosition(ccp(999333,0))
        -- closeMenu:setTouchPriority(-(self.layerNum-1)*20-11)
        -- self.cLayer:addChild(closeMenu,3)
        -- self.closeMenu=closeMenu
        self.speedUpBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",speedUpHandler,11,getlocal("gemCompleted"),25)
        local menuSpeedUp=CCMenu:createWithItem(self.speedUpBtn)
        menuSpeedUp:setPosition(ccp(self.cLayer1:getContentSize().width/2,105))
        menuSpeedUp:setTouchPriority(-(self.layerNum-1)*20-11)
        self.cLayer1:addChild(menuSpeedUp,3)
        self.menuSpeedUp=menuSpeedUp

        local speedUpGems=superWeaponVoApi:raidSpeedUpCost(leftTime)
        self.speedUpGemsLb=GetTTFLabel(speedUpGems,30)
        self.speedUpGemsLb:setPosition(ccp(self.cLayer1:getContentSize().width/2-20,160))
        self.cLayer1:addChild(self.speedUpGemsLb,1)
        local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
        goldSp2:setPosition(ccp(self.cLayer1:getContentSize().width/2+30,160))
        self.cLayer1:addChild(goldSp2,1)
        goldSp2:setScale(1.2)
    end
end

function superWeaponChallengeDialog:doUserHandler()

end

function superWeaponChallengeDialog:tick()
    if self and self.bgLayer then
        local cVo=superWeaponVoApi:getSWChallenge()
        if cVo then
            if self.activityDescLb then
                local swchallengeactiveVO = activityVoApi:getActivityVo("swchallengeactive")
                if swchallengeactiveVO ~=nil and activityVoApi:isStart(swchallengeactiveVO) == false then
                    local activityDescStr = ""
                    self.activityDescLb:setString(activityDescStr)
                    self.activityDescLb=nil
                end
            end
            if cVo.lastRestTime and self.resetBtn and self.resetBtn2 then
                local lastRestTime=cVo.lastRestTime
                if G_isToday(lastRestTime)==false then
                    -- local lb=tolua.cast(self.resetBtn:getChildByTag(101),"CCLabelTTF")
                    -- lb:setString(getlocal("super_weapon_challenge_free_reset"))
                    -- self.resetBtn:setEnabled(true)

                    self.resetBtn:setVisible(false)
                    self.resetBtn:setEnabled(false)
                    self.resetBtn2:setVisible(true)
                    self.resetBtn2:setEnabled(true)
                else
                    -- local lb=tolua.cast(self.resetBtn:getChildByTag(101),"CCLabelTTF")
                    -- lb:setString(getlocal("dailyTaskReset"))
                    self.resetBtn:setVisible(true)
                    self.resetBtn2:setVisible(false)
                    self.resetBtn2:setEnabled(false)
                    local resetNum=superWeaponVoApi:getLeftResetNum()
                    if resetNum<=0 then
                        self.resetBtn:setEnabled(false)
                    else
                        self.resetBtn:setEnabled(true)
                    end
                end
            end
            if self.leftResetNumLb then
                local resetNum=superWeaponVoApi:getLeftResetNum()
                self.leftResetNumLb:setString(getlocal("elite_challenge_reset_num",{resetNum}))
            end

            local leftTime=superWeaponVoApi:getRaidLeftTime()
            if leftTime<=0 then
                -- if self.countDownLb then
                --     if self.countDownLb:isVisible()==true then
                --         self.countDownLb:setVisible(false)
                --     end
                -- end
                -- if self.speedUpBtn then
                --     self.speedUpBtn:setEnabled(false)
                -- end
            else
                -- if self.countDownLb then
                --     if self.countDownLb:isVisible()==false then
                --         self.countDownLb:setVisible(true)
                --     end
                --     self.countDownLb:setString(G_getTimeStr(leftTime))
                -- end
                -- if self.speedUpBtn then
                --     self.speedUpBtn:setEnabled(true)
                -- end

                if superWeaponVoApi:getShowRaidFinishData() then
                else
                    local curFloor,leftFloor=superWeaponVoApi:getRaidFloor()
                    if self.leftFloorLb then
                        self.leftFloorLb:setString(getlocal("sw_raid_left_floor",{leftFloor}))
                    end
                    if self.leftTimeLb then
                        self.leftTimeLb:setString(getlocal("costTime1",{GetTimeStr(leftTime)}))
                    end
                    if curFloor and self.curFloor and self.curFloor~=curFloor then
                        self.curFloor=curFloor
                        if self.curFloorLb then
                            local function movedCallBack( ... )
                                self.curFloorLb:setString(getlocal("sw_raid_current_floor",{curFloor}))
                                self.curFloorLb:setPosition(ccp(1000,G_VisibleSizeHeight/2+155))
                            end
                            local moveTo=CCMoveTo:create(1,ccp(-1000,G_VisibleSizeHeight/2+155))
                            local callFunc=CCCallFunc:create(movedCallBack)
                            local moveTo2=CCMoveTo:create(1,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2+155))
                            local acArr=CCArray:create()
                            acArr:addObject(moveTo)
                            acArr:addObject(callFunc)
                            acArr:addObject(moveTo2)
                            local seq=CCSequence:create(acArr)
                            self.curFloorLb:runAction(seq)
                        end
                    end
                    if self.speedUpGemsLb then
                        local speedUpGems=superWeaponVoApi:raidSpeedUpCost(leftTime)
                        if speedUpGems<0 then
                            speedUpGems=0
                        end
                        self.speedUpGemsLb:setString(speedUpGems)
                    end
                end
            end

            if self.resetGemsLb then
                local resetGems=superWeaponVoApi:getResetCost()
                self.resetGemsLb:setString(resetGems)
            end
            
            local curIndex=cVo.curClearPos+1
            if curIndex>SizeOfTable(swChallengeCfg.list) then
                curIndex=SizeOfTable(swChallengeCfg.list)
            end
            local usedCNum=cVo.hasCNum
            local buyCNum=cVo.buyCNum
            local cfg=swChallengeCfg.list[curIndex]
            local npcNameStr=superWeaponVoApi:getSWChallengeName(curIndex)
            local clearanceConditionStr=superWeaponVoApi:getClearConditionStr(curIndex)
            local leftChallengeNum=swChallengeCfg.challengeNum+buyCNum-usedCNum
            -- local baseRewardTb=FormatItem(cfg.clientReward.base)
            -- local baseRewardItem=baseRewardTb[1]
            -- local rewardNum=baseRewardItem.num
            local rewardNum=0
            for k,v in pairs(cfg.clientReward.base) do
                for key,num in pairs(v) do
                    rewardNum=num
                end
            end
            if self.npcNameLb then
                self.npcNameLb:setString(npcNameStr)
            end
            if self.clearConditionLb then
                self.clearConditionLb:setString(clearanceConditionStr)
            end
            if self.leftNumLb then
                self.leftNumLb:setString(leftChallengeNum)
            end
            if self.rewardNumLb then
                self.rewardNumLb:setString(rewardNum)
            end

            if self.bigRewardSp then
                local cfg=swChallengeCfg.list[curIndex]
                if cfg and cfg.clientReward and cfg.clientReward.rand then
                    local rewardTb=cfg.clientReward.rand
                    if rewardTb and SizeOfTable(rewardTb)>0 then
                        self.bigRewardSp:setVisible(true)
                    else
                        self.bigRewardSp:setVisible(false)
                    end
                end
            end

            if self.lastCurPos and self.lastCurPos~=cVo.curClearPos then
                if self.tankSpTb and SizeOfTable(self.tankSpTb)>0 then
                    if self.tankSpTb==nil then
                        self.tankSpTb={}
                    end
                    if self.tankSpTb and SizeOfTable(self.tankSpTb)>0 then
                        for k,v in pairs(self.tankSpTb) do
                            if v then
                                v:removeFromParentAndCleanup(true)
                            end
                        end
                        self.tankSpTb={}
                    end
                end
                if battleScene.isBattleing==false then
                    self:refreshTanks(true)
                    self.lastCurPos=cVo.curClearPos
                end
            end

            if superWeaponVoApi:getShowRaidFinishData() then
                self:initLoading()
                superWeaponVoApi:setShowRaidFinishData(nil)
            end
        end
    end
end

function superWeaponChallengeDialog:showGuideDialog()
    if(self.guideLayer)then
        self.guideLayer:removeFromParentAndCleanup(true)
        self.guideLayer=nil
    end
    local layerNum=self.layerNum + 1
    self.guideLayer=CCLayer:create()
    self.bgLayer:addChild(self.guideLayer,3)
    local function nilFunc( ... )
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    touchDialogBg:setOpacity(180)
    touchDialogBg:setAnchorPoint(ccp(0,0))
    touchDialogBg:setPosition(ccp(0,0))
    self.guideLayer:addChild(touchDialogBg)
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
    dialogBg:setContentSize(CCSizeMake(570,400))
    dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.guideLayer:addChild(dialogBg,1)
    --礼花效果
    local pX = nil
    local PY = nil
    for i=1,3 do
        pX = dialogBg:getContentSize().width/2 + (i - 2) * 200
        PY = dialogBg:getContentSize().height/2
        if i ~= 2 then
            PY = PY + 200
        end
        local p = CCParticleSystemQuad:create("public/SMOKE.plist")
        p.positionType = kCCPositionTypeFree
        p:setPosition(ccp(pX,PY))
        dialogBg:addChild(p,10)
    end
    local titleLb=GetTTFLabelWrap(getlocal("congratulationsGet",{getlocal(superWeaponCfg.weaponCfg.w1.name)}),25,CCSizeMake(570,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setColor(G_ColorYellowPro)
    titleLb:setPosition(ccp(570/2,330))
    dialogBg:addChild(titleLb)
    local icon=CCSprite:createWithSpriteFrameName("w1_big.png")
    icon:setScale(180/icon:getContentSize().height)
    icon:setPosition(ccp(570/2,210))
    dialogBg:addChild(icon)
    local function onHide()
        if(self and self.guideLayer)then
            self.guideLayer:removeFromParentAndCleanup(true)
            self.guideLayer=nil
        end
        self:close()
    end
    local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",onHide,3,getlocal("confirm"),25,103)
    local okBtn=CCMenu:createWithItem(okItem)
    okBtn:setPosition(ccp(570/2,60))
    okBtn:setTouchPriority(-(layerNum-1)*20-2)
    dialogBg:addChild(okBtn)
end

function superWeaponChallengeDialog:dispose()
    self.curFloor=nil
    eventDispatcher:removeEventListener("superweapon.guide.battleEnd",self.eventListener)
    if(otherGuideMgr.isGuiding and (otherGuideMgr.curStep==8 or otherGuideMgr.curStep==11))then
        otherGuideMgr:toNextStep()
    end
    eventDispatcher:removeEventListener("superWeapon.tanksMove",self.onTanksMoveListener)
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
end




