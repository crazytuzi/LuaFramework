acPhltLottery={}

function acPhltLottery:new()
	local nc={}
    nc.bgLayer=nil
    nc.forbidLayer=nil
    nc.isEnd=false
    nc.freeBtn=nil
    nc.lotteryBtn=nil
    nc.multiLotteryBtn=nil
    nc.isTodayFlag=true
    nc.actionLayer=nil
	setmetatable(nc, self)
	self.__index=self

	return nc
end

function acPhltLottery:init(layerNum,parent)
    spriteController:addPlist("public/acBlessWords.plist")
    spriteController:addTexture("public/acBlessWords.png")
    spriteController:addPlist("public/acPhlt_images.plist")
    spriteController:addTexture("public/acPhlt_images.png")
    spriteController:addPlist("public/acPhlt_tank.plist")
    spriteController:addTexture("public/acPhlt_tank.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
    spriteController:addTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
    spriteController:addPlist("public/acthreeyear_images.plist")
    spriteController:addTexture("public/acthreeyear_images.png")
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addTexture("public/acChunjiepansheng.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initTableView()

    return self.bgLayer
end

function acPhltLottery:initTableView()
    local count=math.floor((G_VisibleSizeHeight-160)/80)
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        self.bgLayer:addChild(bgSp)
        if G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        end
    end

    local desTvAddH,offsetY,timeOffsetY,iconOffsetY=0,0,0,0
    if G_isIphone5()==true then
        desTvAddH=50
        offsetY=-35
        iconOffsetY=-45
        timeOffsetY=-20
    elseif base.hexieMode==1 then
        iconOffsetY=20
        timeOffsetY=0
    end
    local zorder=5
    local item
    local shop=acPhltVoApi:getShop()
    for id,v in pairs(shop) do
        if v.isflick and tonumber(v.isflick)==1 then
            item=FormatItem(v.reward)[1]
            do break end
        end
    end
    local function showNewPropInfo()
        G_showNewPropInfo(self.layerNum+1,true,true,nil,item,true,getlocal("activity_phlt_getway"))
        return false
    end
    local bigRewardSp=G_getItemIcon(item,100,true,self.layerNum+1,showNewPropInfo)
    bigRewardSp:setTouchPriority(-(self.layerNum-1)*20-3)
    bigRewardSp:setPosition(85,G_VisibleSizeHeight-240+iconOffsetY)
    self.bgLayer:addChild(bigRewardSp,zorder)

    local timeLb=GetTTFLabel(acPhltVoApi:getTimeStr(),25)
    timeLb:setAnchorPoint(ccp(0.5,1))
    timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-170+timeOffsetY))
    timeLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(timeLb,zorder)
    self.timeLb=timeLb
    self:updateAcTime()

    if base.hexieMode~=1 or G_isIphone5()==true then
        local desTv,desLabel=G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-180,70+desTvAddH),getlocal("activity_phlt_desc"),25,kCCTextAlignmentLeft)
        self.bgLayer:addChild(desTv)
        desTv:setPosition(ccp(140,G_VisibleSizeHeight-310-desTvAddH+offsetY))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        desTv:setMaxDisToBottomOrTop(100)
    end

    local function infoHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={}
        for i=1,3 do
            local str
            if base.hexieMode==1 and (i==1 or i==2) then
                str=getlocal("activity_phlt_hxrule"..i)
            else
                str=getlocal("activity_phlt_rule"..i)
            end
            if str then
                table.insert(tabStr,str)
            end
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
    end

    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",infoHandler)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-40,G_VisibleSizeHeight-200+timeOffsetY))
    self.bgLayer:addChild(menuDesc,zorder)

    self:initLayer()
end

function acPhltLottery:initLayer()
    local addH=0
    if G_isIphone5()==true then
        addH=-100
    elseif base.hexieMode==1 then
        addH=45
    end
    local zorder=5
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local lotteryBg=CCSprite:create("public/acPhltBg.jpg")
    lotteryBg:setAnchorPoint(ccp(0.5,1))
    lotteryBg:setScaleX(596/lotteryBg:getContentSize().width)
    lotteryBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-320+addH)
    self.bgLayer:addChild(lotteryBg)
    self.lotteryBg=lotteryBg
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local orangeLine1=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine1:setPosition(lotteryBg:getContentSize().width/2,lotteryBg:getContentSize().height)
    lotteryBg:addChild(orangeLine1)
    local orangeLine2=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine2:setPosition(lotteryBg:getContentSize().width/2,0)
    lotteryBg:addChild(orangeLine2)

    local tankBodySp=CCSprite:createWithSpriteFrameName("phlt_tankbody.png")
    tankBodySp:setAnchorPoint(ccp(0.5,0))
    tankBodySp:setPosition(lotteryBg:getContentSize().width-tankBodySp:getContentSize().width/2,0)
    lotteryBg:addChild(tankBodySp)
    local paotouSp=CCSprite:createWithSpriteFrameName("phlt_paotou5.png")
    paotouSp:setPosition(getCenterPoint(tankBodySp))
    tankBodySp:addChild(paotouSp)
    self.paotouSp=paotouSp

    local function logHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:logHandler()
    end
    local logBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",logHandler,11)
    logBtn:setScale(0.8)
    logBtn:setAnchorPoint(ccp(1,1))
    local logMenu=CCMenu:createWithItem(logBtn)
    logMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    logMenu:setPosition(ccp(G_VisibleSizeWidth-40,G_VisibleSizeHeight-340+addH))
    self.bgLayer:addChild(logMenu,zorder)
    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,0))
    logBg:setScale(1/logBtn:getScale())
    logBtn:addChild(logBg)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logLb:setColor(G_ColorYellowPro)
    logBg:addChild(logLb)

    local function rewardPoolHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        --显示奖池
        local content={}
        local pool1,pool2=acPhltVoApi:getRewardPool()
        local pool={pool1,pool2}
        for k,rewardlist in pairs(pool) do
            local item={}
            item.rewardlist=rewardlist
            local titleStr,subStr="",""
            if k==1 then
                titleStr= G_getCurChoseLanguage() =="de"  and getlocal("activity_phlt_hit") or getlocal("activity_phlt_hitReward")
                subStr= getlocal("activity_phlt_hit")
            else
                titleStr=G_getCurChoseLanguage() =="de"and getlocal("activity_phlt_miss") or getlocal("activity_phlt_missReward")
                subStr=getlocal("activity_phlt_miss")
            end
            item.title={titleStr,G_ColorYellowPro,25}
            item.subTitle={getlocal("activity_phlt_rewardpro",{subStr})}
            table.insert(content,item)
        end
        local title={getlocal("award"),nil,30}
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
        acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),title,content,self.layerNum+1,nil,nil,nil,true)
    end
    local poolBtn=GetButtonItem("CommonBox.png","CommonBox.png","CommonBox.png",rewardPoolHandler,11)
    poolBtn:setScale(0.6)
    poolBtn:setAnchorPoint(ccp(0,1))
    local poolMenu=CCMenu:createWithItem(poolBtn)
    poolMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    poolMenu:setPosition(ccp(40,G_VisibleSizeHeight-340+addH+5))
    self.bgLayer:addChild(poolMenu,zorder)
    local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    poolBg:setAnchorPoint(ccp(0.5,1))
    poolBg:setContentSize(CCSizeMake(logBg:getContentSize().width,40))
    poolBg:setPosition(ccp(poolBtn:getContentSize().width/2,0))
    poolBg:setScale(1/poolBtn:getScale())
    poolBtn:addChild(poolBg)
    local poolLb=GetTTFLabelWrap(getlocal("award"),22,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    poolLb:setPosition(poolBg:getContentSize().width/2,poolBg:getContentSize().height/2)
    poolLb:setColor(G_ColorYellowPro)
    poolBg:addChild(poolLb)

    local btnAddH=0
    if G_isIphone5()==true then
        btnAddH=50
    end
    if base.hexieMode==1 then
        local offsetY=0
        if G_isIphone5()==true then
            offsetY=30
            btnAddH=btnAddH-30
        end
        local hxReward=acPhltVoApi:getHexieReward()
        local promptLb=GetTTFLabelWrap(getlocal("activity_phlt_hexiePro",{hxReward.name}),25,CCSize(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        promptLb:setAnchorPoint(ccp(0.5,1))
        promptLb:setPosition(G_VisibleSizeWidth/2,160+offsetY)
        promptLb:setColor(G_ColorYellowPro)
        self.bgLayer:addChild(promptLb)
    end

    local cost1,cost2=acPhltVoApi:getLotteryCost()
    local function lotteryHandler()
        self:lotteryHandler()
    end
    self.freeBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,60+btnAddH),lotteryHandler)
    self.lotteryBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,60+btnAddH),lotteryHandler,cost1)

    local function multiLotteryHandler()
        self:lotteryHandler(true)
    end
    local num=acPhltVoApi:getMultiNum()
    self.multiLotteryBtn=self:getLotteryBtn(num,ccp(G_VisibleSizeWidth/2+120,60+btnAddH),multiLotteryHandler,cost2)
    self:refreshLotteryBtn()
    self:tick()
end

function acPhltLottery:getLotteryBtn(num,pos,callback,cost)
    local btnZorder,btnFontSize=2,25
    local function lotteryHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback()
        end
    end
    local lotteryBtn
    local btnScale=0.8
    if cost and tonumber(cost)>0 then
        local btnStr=""
        if base.hexieMode==1 then
            btnStr=getlocal("activity_qxtw_buy",{num})
        else
            btnStr=getlocal("activity_phlt_lottery",{num})
        end
        lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler,nil,btnStr,btnFontSize/btnScale,11)
        local costLb=GetTTFLabel(tostring(cost),25)
        costLb:setAnchorPoint(ccp(0,0.5))
        costLb:setColor(G_ColorYellowPro)
        costLb:setScale(1/btnScale)
        lotteryBtn:addChild(costLb)
        local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(0,0.5))
        costSp:setScale(1/btnScale)
        lotteryBtn:addChild(costSp)
        local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
        costLb:setPosition(lotteryBtn:getContentSize().width/2-lbWidth/2,lotteryBtn:getContentSize().height+costLb:getContentSize().height/2+8)
        costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())
    else
        lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",lotteryHandler,nil,getlocal("daily_lotto_tip_2"),btnFontSize/btnScale,11)
    end
    lotteryBtn:setScale(btnScale)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    lotteryMenu:setPosition(pos)
    self.bgLayer:addChild(lotteryMenu,btnZorder)

    return lotteryBtn
end

function acPhltLottery:lotteryHandler(multiFlag)
    local multiFlag=multiFlag or false
    local function realLottery(num,cost)
        local function callback(lotteryTb,pt,point,rewardlist,hxReward)
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
            if rewardlist and type(rewardlist)=="table" then
                local function realShow()
                    local function showEndHandler()
                        G_showRewardTip(rewardlist,true)
                    end
                    local addStrTb,addStrTb2
                    if pt and SizeOfTable(pt)>0 then
                        addStrTb={}
                        addStrTb2={}
                        for k,v in pairs(pt) do
                            local addStr=""
                            local result=lotteryTb[k] or 0
                            local color
                            if result==1 then
                                addStr=getlocal("activity_phlt_hit")
                                color=G_ColorGreen
                            else
                                addStr=getlocal("activity_phlt_miss")
                                color=G_ColorRed
                            end
                            table.insert(addStrTb,getlocal("activity_nljj_score",{v or 0}))
                            table.insert(addStrTb2,{addStr,color})
                        end
                    end
                    if hxReward then
                        table.insert(rewardlist,1,hxReward)
                        table.insert(addStrTb,1,"")
                        table.insert(addStrTb2,1,{getlocal("activity_mineexploreG_storeReward"),G_ColorYellowPro})
                    end
                    local titleStr=getlocal("activity_wheelFortune4_reward")
                    local titleStr2=getlocal("activity_tccx_total_score")..getlocal("activity_nljj_score",{point})
                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardlist,showEndHandler,titleStr,titleStr2,addStrTb,addStrTb2)
                end
                self:showActionLayer(lotteryTb,realShow)
            end
            self:refreshLotteryBtn()
        end
        local freeFlag=acPhltVoApi:isFreeLottery()
        acPhltVoApi:acPhltRequest({action=1,num=num,free=freeFlag},callback)
    end
    local cost1,cost2=acPhltVoApi:getLotteryCost()
    local cost,num=0,1
    if acPhltVoApi:isToday()==false then
        acPhltVoApi:resetFreeLottery()
    end
    local freeFlag=acPhltVoApi:isFreeLottery()
    if cost1 and cost2 then
        if multiFlag==false and freeFlag==0 then
            cost=cost1
        elseif multiFlag==true then
            cost=cost2
            num=acPhltVoApi:getMultiNum()
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        do return end
    else
        local function sureClick()
            realLottery(num,cost)
        end
        local function secondTipFunc(sbFlag)
            local keyName=acPhltVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        if cost and cost>0 then
            local keyName=acPhltVoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
        else
            sureClick()
        end
    end
end

function acPhltLottery:showActionLayer(lotteryTb,callback)
    if self.actionLayer then
        do return end
    end
    local hitCfg={
        {ccp(274,220),0.7},
        {ccp(88,280),0.6},
        {ccp(196,375),0.4},
        {ccp(341,420),0.3},
        {ccp(466.5,340),0.5},

    } --命中区域的配置
    local showFlag=false
    local function touchHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:removeActionLayer()
        if callback and showFlag==false then
            callback()
        end
    end
    local actionLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),touchHandler)
    actionLayer:setAnchorPoint(ccp(0.5,0))
    actionLayer:setOpacity(0)
    actionLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    actionLayer:setPosition(G_VisibleSizeWidth/2,0)
    actionLayer:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(actionLayer,3)
    self.actionLayer=actionLayer

    local lotteryBg=CCNode:create()
    lotteryBg:setAnchorPoint(ccp(0.5,1))
    lotteryBg:setContentSize(self.lotteryBg:getContentSize())
    lotteryBg:setPosition(self.lotteryBg:getPosition())
    self.actionLayer:addChild(lotteryBg)

    local fireIdxTb={1,2,3,4,5}
    local function fire(succFlag)
        local acArr=CCArray:create()
        for kk=1,5 do
            local nameStr="phlt_paotou"..kk..".png"
            local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            acArr:addObject(frame)
        end
        local animation=CCAnimation:createWithSpriteFrames(acArr)
        animation:setDelayPerUnit(0.06)
        local animate=CCAnimate:create(animation)
        local function fireCallBack()
            if self.actionLayer==nil then
                do return end
            end
            local idx=math.random(1,SizeOfTable(fireIdxTb))
            local fireIdx=fireIdxTb[idx] or 1
            local fireCfg=hitCfg[fireIdx]
            table.remove(fireIdxTb,idx)

            local fireSp=CCSprite:createWithSpriteFrameName("plane_bigShells_1.png")
            local spcArr=CCArray:create()
            for kk=1,16 do
                local nameStr="plane_bigShells_"..kk..".png"
                local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                spcArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(spcArr)
            animation:setDelayPerUnit(0.08)
            local animate=CCAnimate:create(animation)
            local function removeFire()
               fireSp:removeFromParentAndCleanup(true)
               fireSp=nil
            end
            local removeHandler=CCCallFunc:create(removeFire)
            local seq=CCSequence:createWithTwoActions(animate,removeHandler)
            fireSp:runAction(seq)

            fireSp:setAnchorPoint(ccp(0.5,0.5))
            local px,py=fireCfg[1].x,fireCfg[1].y
            if succFlag==nil or succFlag==false then
                px=px+60
                if idx==1 or idx==2 then
                    px=px+30
                end
                py=py+30
            end
            fireSp:setPosition(px,py)
            fireSp:setScale(fireCfg[2])
            lotteryBg:addChild(fireSp,2)
            PlayEffect(audioCfg.planeBomb)

            local digSp=CCSprite:createWithSpriteFrameName("keng_1.png")
            digSp:setAnchorPoint(ccp(0.5,0.5))
            digSp:setScale(fireCfg[2]*0.6)
            digSp:setPosition(px,py-20)
            digSp:setOpacity(0)
            lotteryBg:addChild(digSp)
            local acArr=CCArray:create()
            local delay=CCDelayTime:create(0.6)
            acArr:addObject(delay)
            local fadein=CCFadeIn:create(0.01)
            acArr:addObject(fadein)
            local fadeout=CCFadeOut:create(1.8)
            acArr:addObject(fadeout)
            local function subMvEnd()
                digSp:removeFromParentAndCleanup(true)
            end
            local subfunc=CCCallFuncN:create(subMvEnd)
            acArr:addObject(subfunc)
            local subseq=CCSequence:create(acArr)
            digSp:runAction(subseq)
        end
        local fireHandler=CCCallFunc:create(fireCallBack)
        local fireSeq=CCSequence:createWithTwoActions(animate,fireHandler)
        self.paotouSp:runAction(fireSeq)

        local fireArr=CCArray:create()
        local guangSp=CCSprite:createWithSpriteFrameName("phlt_paofire0.png")
        for kk=0,9 do
            local nameStr="phlt_paofire"..kk..".png"
            local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            fireArr:addObject(frame)
        end
        local fireAni=CCAnimation:createWithSpriteFrames(fireArr)
        fireAni:setDelayPerUnit(0.06)
        local fireAnimate=CCAnimate:create(fireAni)
        guangSp:setPosition(40-guangSp:getContentSize().width/2+40,self.paotouSp:getContentSize().height+70)
        self.paotouSp:addChild(guangSp)
        guangSp:runAction(fireAnimate)
        -- PlayEffect(audioCfg.tank_1)
        -- PlayEffect(audioCfg.tank_2)
        PlayEffect(audioCfg.tank_3)
        -- PlayEffect(audioCfg.tank_4)
        -- PlayEffect(audioCfg.tank_5)
    end

    local acArr=CCArray:create()
    for k,v in pairs(lotteryTb) do
        if k~=1 then
            local delay=CCDelayTime:create(0.8)
            acArr:addObject(delay)
        end
        local function playFire()
            if v==1 then
                fire(true)
            else
                fire(false)
            end
        end
        local delay=CCDelayTime:create(0.4)
        acArr:addObject(delay)
        local fireHandler=CCCallFunc:create(playFire)
        acArr:addObject(fireHandler)
    end
    local function showRewards()
        showFlag=true
        if callback then
            callback()
        end
        self:removeActionLayer()
    end
    local delay=CCDelayTime:create(1.8)
    acArr:addObject(delay)
    local showHandler=CCCallFunc:create(showRewards)
    acArr:addObject(showHandler)
    local seq=CCSequence:create(acArr)
    self.actionLayer:runAction(seq)
end

function acPhltLottery:removeActionLayer()
    if self.actionLayer then
        self.actionLayer:removeFromParentAndCleanup(true)
        self.actionLayer=nil
    end
end
function acPhltLottery:logHandler()
    local function showLog()
        local rewardLog=acPhltVoApi:getRewardLog() or {}
        if rewardLog and SizeOfTable(rewardLog)>0 then
            local logList={}
            for k,v in pairs(rewardLog) do
                local num,reward,succ,time,point=v.num,v.reward,v.succ,v.time,v.point
                local title
                if base.hexieMode==1 then
                    title={getlocal("activity_phlt_hx_logt",{num,point})}
                else
                    title={getlocal("activity_phlt_logt",{num,point})}
                end
                local subhead={getlocal("activity_phlt_logt2",{succ,tonumber(num)-tonumber(succ)})}
                local content={{reward}}
                local log={title=title,subhead=subhead,content=content,ts=time}
                table.insert(logList,log)
            end
            local logNum=SizeOfTable(logList)
            require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
            acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
        end
    end
    local rewardLog=acPhltVoApi:getRewardLog()
    if rewardLog then
        showLog()
    else
        acPhltVoApi:acPhltRequest({action=3},showLog)
    end
end

function acPhltLottery:refreshLotteryBtn()
    if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn then
        local isEnd=acPhltVoApi:isEnd()
        if isEnd==false then
             local freeFlag=acPhltVoApi:isFreeLottery()
            if freeFlag==1 then
                self.lotteryBtn:setVisible(false)
                self.freeBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(false)
            else
                self.freeBtn:setVisible(false)
                self.lotteryBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(true)
            end
        end
    end
end

function acPhltLottery:updateAcTime()
    local acVo=acPhltVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acPhltLottery:updateUI()
    self:refreshLotteryBtn()
end

function acPhltLottery:tick()
    local isEnd=acPhltVoApi:isEnd()
    if isEnd==false then
        local todayFlag=acPhltVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            --重置免费次数
            acPhltVoApi:resetFreeLottery()
            self:refreshLotteryBtn()
        end
        if self then
          self:updateAcTime()
        end
    end
end

function acPhltLottery:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.isEnd=false
    self.freeBtn=nil
    self.lotteryBtn=nil
    self.multiLotteryBtn=nil
    self.isTodayFlag=true
    self.actionLayer=nil
    spriteController:removePlist("public/acBlessWords.plist")
    spriteController:removeTexture("public/acBlessWords.png")
    spriteController:removePlist("public/acPhlt_images.plist")
    spriteController:removeTexture("public/acPhlt_images.png")
    spriteController:removePlist("public/acPhlt_tank.plist")
    spriteController:removeTexture("public/acPhlt_tank.png")
    spriteController:removePlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
    spriteController:removeTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
    spriteController:removePlist("public/acChunjiepansheng.plist")
    spriteController:removeTexture("public/acChunjiepansheng.png")
end