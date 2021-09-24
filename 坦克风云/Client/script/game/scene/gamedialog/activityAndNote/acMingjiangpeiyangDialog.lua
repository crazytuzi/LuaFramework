acMingjiangpeiyangDialog=commonDialog:new()

function acMingjiangpeiyangDialog:new()
	local nc={}
    nc.oneTrainBtn=nil
    nc.tenTrainBtn=nil
    nc.oneCostNode=nil
    nc.isTodayFlag=true
    nc.pointLbTb={}
    nc.trainItemTb={}
    nc.particleSp=nil
    nc.heroIcon=nil
    nc.fireLeft=nil
    nc.fireRight=nil
    nc.fireUp=nil
    nc.spriteBatchTb={}
    nc.forbidLayer=nil
    nc.progressPosCfg={
        {{1,0,95,511},{1,0,95,496},{1,0,95,481},{1,0,95,463},{1,0,95,445},{1,0,95,427},{1,0,95,409},{1,0,95,391},{1,0,95,376},{1,0,95,361},{1,0,95,343},{1,0,95,325},{1,0,95,307},{1,0,95,289},{1,0,95,271},},
        {{1,0,121,511},{1,0,121,501},{1,0,121,489},{1,0,121,471},{1,0,121,456},{1,0,121,441},{1,0,121,423},{1,0,121,405},{1,0,121,387},{1,0,121,369},{1,90,195,331},{1,90,208,331},{1,90,215,331},{1,90,177,331},{1,90,159,331},{1,0,248,293},{1,0,248,271},{1,0,248,281},{2,0,131,341},{2,180,238,321}},
        {{1,0,147,511},{1,0,147,497},{1,0,147,483},{1,0,147,465},{1,0,147,447},{1,0,147,429},{1,0,402,353},{1,0,402,335},{1,0,402,317},{1,0,402,299},{1,0,402,271},{1,0,402,285},{1,90,323,391},{1,90,305,391},{1,90,341,391},{1,90,354,391},{1,90,372,391},{1,90,287,391},{1,90,272,391},{1,90,257,391},{1,90,239,391},{1,90,221,391},{1,90,203,391},{1,90,185,391},{2,0,157,401},{2,180,392,381}},
        {{1,0,173,511},{1,0,173,489},{1,0,173,494},{1,0,553,413},{1,0,553,395},{1,0,553,377},{1,0,553,359},{1,0,553,341},{1,0,553,311},{1,0,553,326},{1,0,553,281},{1,0,553,293},{1,0,553,271},{2,0,183,461},{2,180,543,441},{1,90,331,451},{1,90,313,451},{1,90,301,451},{1,90,283,451},{1,90,265,451},{1,90,247,451},{1,90,229,451},{1,90,211,451},{1,90,469,451},{1,90,487,451},{1,90,505,451},{1,90,519,451},{1,90,451,451},{1,90,433,451},{1,90,418,451},{1,90,403,451},{1,90,385,451},{1,90,367,451},{1,90,349,451}}
    }
    nc.actionCfg={
        {{0,230,0.5}},
        {{0,35,0.1},{-140,0,0.3},{0,186,0.5}},
        {{0,90,0.2},{-278,0,0.6},{0,150,0.33}},
        {{0,160,0.375},{-420,0,0.95},{0,100,0.2}}
    }
    nc.valvePosCfg={{95,271,95,511},{248,271,121,505},{402,271,147,505},{553,271,173,511}}
    nc.itemPosCfg={95,248,402,553}
    nc.infoBgSp=nil
	setmetatable(nc, self)
	self.__index=self

	return nc
end	

function acMingjiangpeiyangDialog:initTableView()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acmjpy_images.plist")
    spriteController:addTexture("public/acmjpy_images.png")
    spriteController:addPlist("public/acBlessWords.plist")
    spriteController:addTexture("public/acBlessWords.png")
    self.isTodayFlag=acMingjiangpeiyangVoApi:isToday()
    self:initLayer()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acMingjiangpeiyangDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
end	

function acMingjiangpeiyangDialog:initLayer()
	local function bgClick()
	end
	local h=G_VisibleSizeHeight-90
	local w=G_VisibleSizeWidth-30 -- 背景框的宽度
    local desBgSize=CCSizeMake(w,150)
    local addHeight=0
    if(G_isIphone5())then
        h=G_VisibleSizeHeight-100
        addHeight=30
        desBgSize=CCSizeMake(w,150+addHeight)
    end
	local backSprite=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
    backSprite:setContentSize(desBgSize)
    backSprite:setAnchorPoint(ccp(0.5,1))
    backSprite:setPosition(ccp(G_VisibleSizeWidth/2,h))
    self.bgLayer:addChild(backSprite)

    local function touch(tag,object)
    	PlayEffect(audioCfg.mouseClick)
    	local tabStr={}
    	local tabColor={}
        local freeNum=acMingjiangpeiyangVoApi:getFreeNum()
    	tabStr={"\n",getlocal("activity_mjpy_rule4",{freeNum,freeNum}),"\n",getlocal("activity_mjpy_rule3",{acMingjiangpeiyangVoApi:getPointTimes()}),"\n",getlocal("activity_mjpy_rule2"),"\n",getlocal("activity_mjpy_rule1",{acMingjiangpeiyangVoApi:getMaxPoint()}),"\n"}
    	tabColor={nil, nil, nil, nil, nil,nil, nil,nil,nil}
    	local td=smallDialog:new()
    	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
    	sceneGame:addChild(dialog,self.layerNum+1)
    end
    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
  	local menuDesc=CCMenu:createWithItem(menuItemDesc)
  	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  	menuDesc:setPosition(ccp(w-20, backSprite:getContentSize().height-10))
  	backSprite:addChild(menuDesc)

  	local acLabel=GetTTFLabel(getlocal("activity_timeLabel"),25)
  	acLabel:setAnchorPoint(ccp(0.5,1))
  	acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, backSprite:getContentSize().height-10))
  	backSprite:addChild(acLabel)
 	acLabel:setColor(G_ColorGreen)
   
    local acVo=acMingjiangpeiyangVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,25)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setPosition(ccp((G_VisibleSizeWidth-20)/2, backSprite:getContentSize().height-10-acLabel:getContentSize().height))
    backSprite:addChild(messageLabel)
    self.timeLb=messageLabel
    self:updateAcTime()

 	local desTv,desLabel=G_LabelTableView(CCSizeMake(w-90,70+addHeight),getlocal("activity_mjpy_desc"),25,kCCTextAlignmentLeft)
 	backSprite:addChild(desTv)
    desTv:setPosition(ccp(55,5))
    desTv:setAnchorPoint(ccp(0.5,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(100)

    self:initHeroInfo()
    self:initTrainBtns()
    self:refreshTrainEffect()
end

-- 添加英雄显示信息
function acMingjiangpeiyangDialog:initHeroInfo()
    local addHeight=0
    local infoAddH=30
    if (G_isIphone5()) then
        addHeight=60
        infoAddH=60
    end
    local strSize2 = 19
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =22
    end
    local h=G_VisibleSizeHeight-240-addHeight
    local function bgClick()
    end
    local infoBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
    infoBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,550+infoAddH))
    infoBgSp:setAnchorPoint(ccp(0.5,1))
    infoBgSp:setPosition(ccp(G_VisibleSizeWidth/2,h))
    self.bgLayer:addChild(infoBgSp)
    self.infoBgSp=infoBgSp

    local infoBgW=infoBgSp:getContentSize().width
    local infoBgH=infoBgSp:getContentSize().height
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setScaleX((infoBgW-10)/blueBg:getContentSize().width)
    blueBg:setScaleY((infoBgH-10)/blueBg:getContentSize().height)
    blueBg:setPosition(infoBgW/2,5)
    infoBgSp:addChild(blueBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local offsetH=110
    if (G_isIphone5()) then
        offsetH=80
    end
    local spriteBatch=CCSpriteBatchNode:create("public/acmjpy_images.png")
    infoBgSp:addChild(spriteBatch)
    for k,cfg in pairs(self.progressPosCfg) do
        for kk,v in pairs(cfg) do
            local pType,rotation,posX,posY=v[1],v[2],v[3]-20,v[4]-offsetH
            local pic="acmjpy_progressbg"..pType..".png"
            local itemSp=CCSprite:createWithSpriteFrameName(pic)
            itemSp:setPosition(ccp(posX,posY))
            itemSp:setRotation(rotation)
            spriteBatch:addChild(itemSp)
        end
    end
    local function touchHeroIcon(...)
        PlayEffect(audioCfg.mouseClick)        
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"

        local mustgetHero=acMingjiangpeiyangVoApi:mustGetHero()
        local hid,heroProductOrder=acMingjiangpeiyangVoApi:getHidandheroProductOrder(mustgetHero)

        local td=acHuoxianmingjiangHeroInfoDialog:new(hid,heroProductOrder)
        local dialog=td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local mustgetHero=acMingjiangpeiyangVoApi:mustGetHero()
    local hid,heroProductOrder=acMingjiangpeiyangVoApi:getHidandheroProductOrder(mustgetHero)
    local heroIcon=heroVoApi:getHeroIcon(hid,heroProductOrder,true,touchHeroIcon,nil,nil,nil,{adjutants={}})
    heroIcon:setTouchPriority(-(self.layerNum-1)*20-2)
    heroIcon:setAnchorPoint(ccp(0,1))
    heroIcon:setPosition(50,infoBgH-40)
    heroIcon:setScale(0.8)
    infoBgSp:addChild(heroIcon,10)
    self.heroIcon=heroIcon
    local heroDesTvSize=CCSizeMake(280,107)
    local desBgSize=CCSizeMake(300,180)
    local desBackSprite=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),bgClick)
    desBackSprite:setContentSize(desBgSize)
    desBackSprite:setAnchorPoint(ccp(0,1))
    desBackSprite:setPosition(ccp(heroIcon:getPositionX()+heroIcon:getContentSize().width+10,infoBgH-20))
    infoBgSp:addChild(desBackSprite)
    local heroNameLabel=GetTTFLabel(heroVoApi:getHeroName(hid),30)
    heroNameLabel:setAnchorPoint(ccp(0,1))
    heroNameLabel:setColor(heroVoApi:getHeroColor(heroProductOrder))
    heroNameLabel:setPosition(ccp(10,desBgSize.height-10))
    desBackSprite:addChild(heroNameLabel)

    local scoreDescLb=GetTTFLabelWrap(getlocal("multiplierScore",{acMingjiangpeiyangVoApi:getPointTimes()}),strSize2,CCSize(desBgSize.width+250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    scoreDescLb:setAnchorPoint(ccp(0.5,0))
    scoreDescLb:setPosition(infoBgSp:getContentSize().width/2,10)
    scoreDescLb:setColor(G_ColorRed)
    infoBgSp:addChild(scoreDescLb)
    self.scoreDescLb=scoreDescLb
    if acMingjiangpeiyangVoApi:isMultiplier()==false then
        scoreDescLb:setVisible(false)
    end
    local desStr=acMingjiangpeiyangVoApi:getHeroDescStr()
    local heroDesTv,heroIntroduction=G_LabelTableView(heroDesTvSize,desStr,22,kCCTextAlignmentLeft)
    desBackSprite:addChild(heroDesTv)
    heroDesTv:setPosition(ccp(10,20))
    heroDesTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    heroDesTv:setMaxDisToBottomOrTop(100)
    local function rewardRecordsHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:recordHandler()
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.7)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(0,1))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(G_VisibleSizeWidth-recordBtn:getContentSize().width*recordBtn:getScaleX()-15,infoBgH-55))
    infoBgSp:addChild(recordMenu)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setPosition(recordBtn:getContentSize().width*recordBtn:getScale()/2,-5)
    recordLb:setScale(1/recordBtn:getScale())
    recordBtn:addChild(recordLb)

    local h=infoBgH-430
    local pointData=acMingjiangpeiyangVoApi:getPointData()
    local maxPoint=acMingjiangpeiyangVoApi:getMaxPoint()
    for i=1,4 do
        local function itemTouchHandler()
            local reward=acMingjiangpeiyangVoApi:getClientReward()
            reward=FormatItem(reward[i])
            require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
            acMingjiangpeiyangSmallDialog:showRewardItemDialog("TankInforPanel.png",CCSizeMake(550,450),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),reward,false,self.layerNum+1)
        end
        local pic,name=acMingjiangpeiyangVoApi:getTrainItem(i)
        local item=LuaCCSprite:createWithSpriteFrameName(pic,itemTouchHandler)
        if item then
            item:setPosition(self.itemPosCfg[i]-20,h)
            item:setTouchPriority(-(self.layerNum-1)*20-1)
            item:setScale(0.9)
            infoBgSp:addChild(item,5)

            local nameLb=GetTTFLabel(name,25)
            nameLb:setAnchorPoint(ccp(0.5,1))
            nameLb:setPosition(ccp(item:getContentSize().width/2,-5))
            -- nameLb:setScale(1/item:getScale())
            item:addChild(nameLb)
            local point=0
            if pointData and pointData[i] then
                point=pointData[i]
            end
            local pointLb=GetTTFLabel(point.."/"..maxPoint,25)
            pointLb:setAnchorPoint(ccp(0.5,1))
            -- pointLb:setScale(1/item:getScale())
            pointLb:setPosition(ccp(item:getContentSize().width/2,nameLb:getPositionY()-nameLb:getContentSize().height-5))
            item:addChild(pointLb)
            self.pointLbTb[i]=pointLb
            self.trainItemTb[i]=item
        end
    end
end

function acMingjiangpeiyangDialog:initTrainBtns()
    local strSize=25
    if G_getCurChoseLanguage()=="ru" then
        strSize=22
    end
    local function onceTrainHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- 判断是不是免费
        local freeFlag=acMingjiangpeiyangVoApi:isFree()
        self:trainHandler(1,freeFlag)
    end
    local oneTrainBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",onceTrainHandler,nil,getlocal("custom_train"),strSize,11)
    oneTrainBtn:setAnchorPoint(ccp(0.5,0))
    local oneTrainMenu=CCMenu:createWithItem(oneTrainBtn)
    oneTrainMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    oneTrainMenu:setPosition(ccp(G_VisibleSizeWidth/2-150,30))
    self.bgLayer:addChild(oneTrainMenu)
    self.oneTrainBtn=oneTrainBtn

    local oneCostNode=CCNode:create()
    oneCostNode:setAnchorPoint(ccp(0.5,0))
    oneTrainBtn:addChild(oneCostNode)
    self.oneCostNode=oneCostNode
    local oneCost=acMingjiangpeiyangVoApi:getOneCost()
    local oneCostLb=GetTTFLabel(tostring(oneCost),25)
    oneCostLb:setAnchorPoint(ccp(0,0))
    oneCostLb:setColor(G_ColorYellowPro)
    oneCostNode:addChild(oneCostLb)
    local oneGemsSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    oneGemsSp:setAnchorPoint(ccp(0,0))
    oneCostNode:addChild(oneGemsSp)
    local lbWidth=oneCostLb:getContentSize().width+oneGemsSp:getContentSize().width
    oneCostNode:setContentSize(CCSizeMake(lbWidth,1))
    oneCostLb:setPosition(ccp(0,0))
    oneGemsSp:setPosition(ccp(oneCostLb:getContentSize().width,0))
    oneCostNode:setPosition(ccp(oneTrainBtn:getContentSize().width/2,oneTrainBtn:getContentSize().height))

    local function tenTrainHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:trainHandler(2,false)
    end
    local tenTrainBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",tenTrainHandler,nil,getlocal("strong_train"),strSize,11)
    tenTrainBtn:setAnchorPoint(ccp(0.5,0))
    local tenTrainMenu=CCMenu:createWithItem(tenTrainBtn)
    tenTrainMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    tenTrainMenu:setPosition(ccp(G_VisibleSizeWidth/2+150,30))
    self.bgLayer:addChild(tenTrainMenu)
    self.tenTrainBtn=tenTrainBtn

    local tenCostNode=CCNode:create()
    tenCostNode:setAnchorPoint(ccp(0.5,0))
    tenTrainBtn:addChild(tenCostNode)
    local tenCost=acMingjiangpeiyangVoApi:getTenCost()
    local tenCostLb=GetTTFLabel(tostring(tenCost),25)
    tenCostLb:setAnchorPoint(ccp(0,0))
    tenCostLb:setColor(G_ColorYellowPro)
    tenCostNode:addChild(tenCostLb)
    local tenGemsSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    tenGemsSp:setAnchorPoint(ccp(0,0))
    tenCostNode:addChild(tenGemsSp)
    local lbWidth=tenCostLb:getContentSize().width+tenGemsSp:getContentSize().width
    tenCostNode:setContentSize(CCSizeMake(lbWidth,1))
    tenCostLb:setPosition(ccp(0,0))
    tenGemsSp:setPosition(ccp(tenCostLb:getContentSize().width,0))
    tenCostNode:setPosition(ccp(tenTrainBtn:getContentSize().width/2,tenTrainBtn:getContentSize().height))

    local freeFlag=acMingjiangpeiyangVoApi:isFree()
    if freeFlag==true then
        if self.oneTrainBtn and self.tenTrainBtn then
            tolua.cast(self.oneTrainBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))
            if self.oneCostNode then
                self.oneCostNode:setVisible(false)
            end
            self.tenTrainBtn:setEnabled(false)
        end
    end
end

function acMingjiangpeiyangDialog:trainHandler(trainType,isFree)
    local cost
    if tonumber(trainType)==1 then
        cost=acMingjiangpeiyangVoApi:getOneCost()
    elseif tonumber(trainType)==2 then
        cost=acMingjiangpeiyangVoApi:getTenCost()
    end
    if cost==nil then
        do return end
    end
    if playerVoApi:getGems()<cost and isFree==false then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        return
    end
    local function callback(fn,data)
        local oldHeroList=heroVoApi:getHeroList()
        local ret,sData=base:checkServerData(data)
        if ret==true then 
            if sData.data==nil then
                return
            end
            if (isFree==false and trainType==1) or trainType==2 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-cost)
            end
            local content={}
            local msgContent={}
            local completeFlag=false
            local allCompleteFlag=false
            local pointType
            local heroExistStr=""
            if sData.data.report then
                for k,v in pairs(sData.data.report) do
                    if v[1]==2 then
                        local item=v[2] --奖励内容
                        pointType=item[1] --培养的类型
                        local point=item[2] --本次该类型的积分
                        local multiplierFlag=item[3] --是否翻倍
                        local pic,name=acMingjiangpeiyangVoApi:getTrainItem(pointType)
                        local reward={pic=pic,type="",name=name,num=point,desc="",isPoint=true}
                        table.insert(content,{award=reward,point=0,index=k})
                        local showStr=getlocal("congratulationsGet",{reward.name .. "*" .. reward.num})
                        table.insert(msgContent,{showStr,G_ColorYellowPro})
                        local allDone=acMingjiangpeiyangVoApi:isAllTrainCompleted()
                        --在加积分前先判断是不是已经完成所有项
                        if allDone==true then
                            acMingjiangpeiyangVoApi:clearAc()
                        end
                        --加对应的积分
                        acMingjiangpeiyangVoApi:setTrainPoint(pointType,point)
                        --加完积分后再次判断有没有完成所有的积分项
                        completeFlag=acMingjiangpeiyangVoApi:isTrainCompleted(pointType)
                        allCompleteFlag=acMingjiangpeiyangVoApi:isAllTrainCompleted()
                        if trainType==2 then
                            if completeFlag==true then
                                local reward={pic=pic,type="",name=name,desc=""}
                                table.insert(content,{award=reward})
                                local showStr=getlocal("activity_mjpy_trainComplete",{reward.name})
                                table.insert(msgContent,{showStr,G_ColorYellowPro})
                            end
                            if allCompleteFlag==true then
                                local reward={pic="acmjpy_trainitem5.png",type="",name=name,desc=""}
                                table.insert(content,{award=reward})
                                local mustgetHero=acMingjiangpeiyangVoApi:mustGetHero()
                                local hid,heroProductOrder=acMingjiangpeiyangVoApi:getHidandheroProductOrder(mustgetHero)
                                local showStr=getlocal("activity_mjpy_trainAllComplete",{heroProductOrder,heroVoApi:getHeroName(hid)})
                                table.insert(msgContent,{showStr,G_ColorYellowPro})
                                acMingjiangpeiyangVoApi:clearAc()
                            end
                        end
                    else
                        local trainCompleteFlag=false
                        local awardTb=FormatItem(v[2]) or {}
                        local reward=awardTb[1]
                        table.insert(content,{award=reward,point=0,index=k})
                        local existStr=""
                        local showStr=""
                        local color=G_ColorWhite
                        if reward.type=="h" then
                            local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(reward,oldHeroList)
                            if heroIsExist==true then
                                if heroVoApi:heroHonorIsOpen()==true and  heroVoApi:getIsHonored(reward.key)==true then
                                    existStr=","..getlocal("hero_honor_recruit_honored_hero",{addNum})
                                    if addNum and addNum>0 then
                                        local pid=heroCfg.getSkillItem
                                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                                        bagVoApi:addBag(id,addNum)
                                    end
                                else
                                    if newProductOrder then
                                        existStr=","..getlocal("hero_breakthrough_desc",{newProductOrder})
                                    else
                                        existStr=","..getlocal("alreadyHasDesc",{addNum})
                                    end
                                end
                                heroExistStr=getlocal("congratulationsGet",{reward.name})..existStr
                            elseif heroIsExist==false then
                                local vo=heroVo:new()
                                vo.hid=reward.key
                                vo.level=1
                                vo.points=0
                                vo.productOrder=reward.num
                                vo.skill={}
                                table.insert(oldHeroList,vo)
                                -- heroVoApi:getNewHeroChat(reward.key)
                                if vo.productOrder and vo.productOrder>=2 then
                                    local star=heroVoApi:getHeroStars(vo.productOrder)
                                    local name=heroVoApi:getHeroName(vo.hid)
                                    local message={key="activity_mjpy_notice",param={playerVoApi:getPlayerName(),getlocal("activity_mingjiangpeiyang_title"),star,name}}
                                    chatVoApi:sendSystemMessage(message)
                                end
                            end
                            showStr=getlocal("congratulationsGet",{reward.name})..existStr
                            color=G_ColorYellowPro
                            local flag=acMingjiangpeiyangVoApi:isMultiplier() --是否翻倍
                            local mustgetHero=acMingjiangpeiyangVoApi:mustGetHero()
                            local hid,heroProductOrder=acMingjiangpeiyangVoApi:getHidandheroProductOrder(mustgetHero)
                            if flag==true and hid==reward.key then
                                acMingjiangpeiyangVoApi:multiplierDone()
                                trainCompleteFlag=true
                            end
                        else
                            showStr=getlocal("congratulationsGet",{reward.name .. "*" .. reward.num})
                        end
                        table.insert(msgContent,{showStr,color})
                        if trainCompleteFlag==true and trainType==2 then
                            table.insert(content,{isOnlyText=true,text=getlocal("activity_mjpy_tip",{acMingjiangpeiyangVoApi:getPointTimes()}),color=G_ColorRed,alignment=kCCTextAlignmentCenter,fontSize=25})
                            table.insert(msgContent,{showStr="",color=G_ColorWhite})
                        end
                        G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
                    end
                end
            end
            acMingjiangpeiyangVoApi:updateData(sData.data.mingjiangpeiyang)
            self:refresh()
            self:refreshTrainEffect()
            local function showRewards()
                if trainType==1 then
                    local freeFlag=acMingjiangpeiyangVoApi:isFree()
                    local cost=0
                    if freeFlag==false then
                        cost=acMingjiangpeiyangVoApi:getOneCost()
                    end
                    local function callback()
                       self:trainHandler(1,freeFlag)
                    end
                    local dialogH=500
                    local addDesc=""
                    local rewardPromptStr=""
                    if allCompleteFlag==true then
                        local mustgetHero=acMingjiangpeiyangVoApi:mustGetHero()
                        local hid,heroProductOrder=acMingjiangpeiyangVoApi:getHidandheroProductOrder(mustgetHero)
                        addDesc=getlocal("activity_mjpy_trainAllComplete",{heroProductOrder,heroVoApi:getHeroName(hid)})
                        dialogH=dialogH+60
                    elseif completeFlag==true then
                        rewardPromptStr=getlocal("activity_mjpy_rewardPrompt1")
                        dialogH=dialogH+60
                    end
                    if heroExistStr and heroExistStr~="" then
                        dialogH=dialogH+80
                    end
                    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
                    acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,dialogH),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),rewardPromptStr,heroExistStr,content,false,self.layerNum+1,addDesc,getlocal("confirm"),nil,getlocal("train_again"),callback,cost)
                elseif trainType==2 then
                    if content and SizeOfTable(content)>0 then
                        local function confirmHandler()
                        end
                        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
                        acMingjiangpeiyangSmallDialog:showSearchRewardsDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("strong_train"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,msgContent)
                    end  
                end
                self:removeForbidLayer()
            end
            if trainType==1 and pointType then
                self:playAnimation(pointType,showRewards)
            else
                showRewards()
            end
            local freeFlag=acMingjiangpeiyangVoApi:isFree()
            if freeFlag==false and trainType==1 then
                if self.oneTrainBtn and self.tenTrainBtn then
                    tolua.cast(self.oneTrainBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("custom_train"))
                    if self.oneCostNode then
                        self.oneCostNode:setVisible(true)
                    end
                    self.tenTrainBtn:setEnabled(true)
                end
            end
        else
            self:removeForbidLayer()
        end
    end
    socketHelper:trainHeroLottery(trainType,isFree,callback)
    self:addForbidLayer(nil)
end

function acMingjiangpeiyangDialog:recordHandler()
    local function callback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then 
            if sData.data==nil then
                return
            end
            local record={}
            if sData.data.log then
                for k,v in pairs(sData.data.log) do
                    reward=v[1]
                    reward=FormatItem(reward)
                    local rtype=v[3]
                    local colorTb={nil,G_ColorYellowPro,nil}
                    local desc=getlocal("custom_train")
                    if rtype==1 then
                        desc=getlocal("custom_train")
                    elseif rtype==2 then
                        desc=getlocal("custom_train").."<rayimg>".."（"..getlocal("activity_mjpy_rewardPrompt1").."）".."<rayimg>"
                    elseif rtype==3 then
                        desc=getlocal("custom_train").."<rayimg>".."（"..getlocal("activity_mjpy_rewardPrompt2").."）".."<rayimg>"
                    end
                    table.insert(record,{award=reward,time=v[2],desc=desc,colorTb=colorTb})
                end
            end
            local function sortFunc(a,b)
                if a and b and a.time and b.time then
                    return tonumber(a.time)>tonumber(b.time)
                end
            end
            table.sort(record,sortFunc)
            local recordCount=SizeOfTable(record)
            if recordCount==0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
                do return end
            end
            local function confirmHandler()
            end
            require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
            acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),getlocal("activity_customLottery_RewardRecode"),record,false,self.layerNum+1,confirmHandler)
        end
    end
    socketHelper:trainHeroLottery(3,nil,callback)
end

function acMingjiangpeiyangDialog:eventHandler(handler,fn,idx,cel)

end

function acMingjiangpeiyangDialog:refresh()
    local pointData=acMingjiangpeiyangVoApi:getPointData()
    local maxPoint=acMingjiangpeiyangVoApi:getMaxPoint()
    for i=1,4 do
        local point=pointData[i] or 0
        if self.pointLbTb and self.pointLbTb[i] then
            self.pointLbTb[i]:setString(point.."/"..maxPoint)
        end
    end
    if self.scoreDescLb and self.scoreDescLb:isVisible()==true then
        if acMingjiangpeiyangVoApi:isMultiplier()==false then
            self.scoreDescLb:setVisible(false)
        end
    end
end

function acMingjiangpeiyangDialog:refreshTrainEffect()
    local count=0
    for i=1,4 do
        local flag=acMingjiangpeiyangVoApi:isTrainCompleted(i)
        if flag==true then
            self:playCompleteAni(i)
            count=count+1
        else
            self:removeCompleteAni(i)
        end
    end
    if count==4 then
        self:playFire()
        if self.oneTrainBtn then
            local flickerPos=ccp(self.oneTrainBtn:getContentSize().width/2,self.oneTrainBtn:getContentSize().height/2)
            G_addRectFlicker(self.oneTrainBtn,2.2,1,flickerPos)
        end
    else
        self:removeFire()
        G_removeFlicker(self.oneTrainBtn)
    end
end

function acMingjiangpeiyangDialog:addForbidLayer(touchCallBack)
    local function touch()
       if touchCallBack then
            touchCallBack()
       end
    end
    if self.forbidLayer==nil then
        self.forbidLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
        self.forbidLayer:setTouchPriority(-(self.layerNum-1)*20-8)
        self.forbidLayer:setContentSize(G_VisibleSize)
        self.forbidLayer:setOpacity(0)
        self.forbidLayer:setPosition(getCenterPoint(self.bgLayer))
        self.bgLayer:addChild(self.forbidLayer,10);
    end
end

function acMingjiangpeiyangDialog:removeForbidLayer()
    if self.forbidLayer then
        self.forbidLayer:removeFromParentAndCleanup(true)
        self.forbidLayer=nil
    end
end

function acMingjiangpeiyangDialog:playAnimation(trainIdx,callback)
    if self.trainItemTb and self.trainItemTb[trainIdx] then
        local item=self.trainItemTb[trainIdx]
        local p=CCParticleSystemQuad:create("public/YELLOWrect.plist")
        p.positionType=kCCPositionTypeFree
        p:setScale(1.3)
        p:setPosition(ccp(item:getContentSize().width/2,item:getContentSize().height/2))
        item:addChild(p,10)
        self.particleSp=p

        local light=CCParticleSystemQuad:create("public/pointlight.plist")
        light.positionType=kCCPositionTypeFree
        light:setPosition(ccp(item:getContentSize().width/2,item:getContentSize().height))
        item:addChild(light,10)

        local actionCfg=self.actionCfg[trainIdx]
        if actionCfg then
            local acArr=CCArray:create()
            for k,cfg in pairs(actionCfg) do
                local move=CCMoveBy:create(cfg[3],CCPointMake(cfg[1],cfg[2]))
                acArr:addObject(move)
            end
            local function playEnd()
                if self.particleSp then
                    self.particleSp:removeFromParentAndCleanup(true)
                    self.particleSp=nil
                    light:removeFromParentAndCleanup(true)
                    light=nil
                    local guangSp=CCSprite:createWithSpriteFrameName("equipShine.png")
                    guangSp:setPosition(ccp(self.heroIcon:getPositionX()+self.heroIcon:getContentSize().width/2-10,self.heroIcon:getPositionY()-self.heroIcon:getContentSize().height/2))
                    guangSp:setScale(2)
                    self.infoBgSp:addChild(guangSp)
                    local function endCallBack()
                        guangSp:removeFromParentAndCleanup(true)
                        guangSp=nil
                        if callback then
                            callback()
                        end 
                    end
                    local actionArr=CCArray:create()
                    local blink=CCBlink:create(1,2)
                    actionArr:addObject(blink)
                    local callFunc=CCCallFuncN:create(endCallBack)
                    actionArr:addObject(callFunc)
                    local acseq=CCSequence:create(actionArr)
                    guangSp:runAction(acseq)
                end
            end
            local callFunc=CCCallFuncN:create(playEnd)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            if light then
                light:runAction(seq)
            end
        end
    end
end

function acMingjiangpeiyangDialog:playCompleteAni(trainIdx)
    if self.infoBgSp==nil then
        do return end
    end
    local offsetH=110
    if (G_isIphone5()) then
        offsetH=80
    end
    local spriteBatch=self.spriteBatchTb[trainIdx]
    if spriteBatch==nil then
        spriteBatch=CCSpriteBatchNode:create("public/acmjpy_images.png")
        spriteBatch:setTag(100+trainIdx)
        self.infoBgSp:addChild(spriteBatch)
        self.spriteBatchTb[trainIdx]=spriteBatch
        local posCfg=self.progressPosCfg[trainIdx]
        for k,v in pairs(posCfg) do
            local pType,rotation,posX,posY=v[1],v[2],v[3]-20,v[4]-offsetH
            local pic1="acmjpy_progress"..pType..".png"
            local itemSp1=CCSprite:createWithSpriteFrameName(pic1)
            itemSp1:setPosition(ccp(posX,posY))
            itemSp1:setRotation(rotation)
            spriteBatch:addChild(itemSp1)
            local pic2="acmjpy_plight"..pType..".png"
            local itemSp2=CCSprite:createWithSpriteFrameName(pic2)
            itemSp2:setPosition(ccp(posX,posY))
            itemSp2:setRotation(rotation)
            spriteBatch:addChild(itemSp2)
            local fadeIn=CCFadeOut:create(0.8)
            local fadeOut=fadeIn:reverse()
            -- local callFunc=CCCallFuncN:create(playBackBgEnd)
            local acArr=CCArray:create()
            acArr:addObject(fadeIn)
            acArr:addObject(fadeOut)
            local seq=CCSequence:create(acArr)
            itemSp2:runAction(CCRepeatForever:create(seq))
        end
        local cfg=self.valvePosCfg[trainIdx]
        local xd,yd,xu,yu=cfg[1],cfg[2],cfg[3],cfg[4]
        xd=xd-20
        yd=yd-offsetH+25
        xu=xu-20
        yu=yu-offsetH
        local  valveUp=CCSprite:createWithSpriteFrameName("acmjpy_valveup.png")
        valveUp:setAnchorPoint(ccp(0.5,0))
        valveUp:setPosition(ccp(xu,yu))
        spriteBatch:addChild(valveUp)
        local  valveDown=CCSprite:createWithSpriteFrameName("acmjpy_valvedown.png")
        valveDown:setAnchorPoint(ccp(0.5,0))
        valveDown:setPosition(ccp(xd,yd))
        spriteBatch:addChild(valveDown)
    end
end

function acMingjiangpeiyangDialog:removeCompleteAni(trainIdx)
    if self.infoBgSp then
        local spriteBatch=self.spriteBatchTb[trainIdx]
        if spriteBatch then
            spriteBatch:removeFromParentAndCleanup(true)
            self.spriteBatchTb[trainIdx]=nil
        end
    end
end

function acMingjiangpeiyangDialog:playFire()
    if self.heroIcon==nil then
        do return end
    end
    if self.fireLeft==nil then
        local leftAni=CCParticleSystemQuad:create("public/acmjpy_sidefire.plist")
        leftAni.positionType=kCCPositionTypeFree
        leftAni:setPosition(ccp(0,self.heroIcon:getContentSize().height*self.heroIcon:getScale()/2+20))
        leftAni:setScale(0.6)
        leftAni:setTag(10001)
        self.heroIcon:addChild(leftAni)
        self.fireLeft=leftAni
    end
    if self.fireRight==nil then
        local rightAni=CCParticleSystemQuad:create("public/acmjpy_sidefire.plist")
        rightAni.positionType=kCCPositionTypeFree
        rightAni:setPosition(ccp(self.heroIcon:getContentSize().width,self.heroIcon:getContentSize().height*self.heroIcon:getScale()/2+20))
        rightAni:setScale(0.6)
        rightAni:setTag(10002)
        self.heroIcon:addChild(rightAni)
        self.fireRight=rightAni
    end
    if self.fireUp==nil then
        local upAni=CCParticleSystemQuad:create("public/acmjpy_upfire.plist")
        upAni.positionType=kCCPositionTypeFree
        upAni:setPosition(ccp(self.heroIcon:getContentSize().width/2,self.heroIcon:getContentSize().height))
        upAni:setScale(0.8)
        upAni:setTag(10003)
        self.heroIcon:addChild(upAni)
        self.fireUp=upAni
    end
end

function acMingjiangpeiyangDialog:removeFire()
    if self.heroIcon then
        if self.fireLeft then
            self.fireLeft:removeFromParentAndCleanup(true)
            self.fireLeft=nil
        end
        if self.fireRight then
            self.fireRight:removeFromParentAndCleanup(true)
            self.fireRight=nil
        end
        if self.fireUp then
            self.fireUp:removeFromParentAndCleanup(true)
            self.fireUp=nil
        end
    end
end

function acMingjiangpeiyangDialog:removeAnimation()
    if self.particleSp then
        self.particleSp:removeFromParentAndCleanup(true)
        self.particleSp=nil
    end
end

function acMingjiangpeiyangDialog:dispose()
    self.oneTrainBtn=nil
    self.tenTrainBtn=nil
    self.oneCostNode=nil
    self.isTodayFlag=true
    self.pointLbTb={}
    self.trainItemTb={}
    self.particleSp=nil
    self.heroIcon=nil
    self.fireLeft=nil
    self.fireRight=nil
    self.fireUp=nil
    self.spriteBatchTb={}
    self.forbidLayer=nil
    self.timeLb=nil
    self:removeAnimation()
    spriteController:removePlist("public/acmjpy_images.plist")
    spriteController:removeTexture("public/acmjpy_images.png")
    spriteController:removePlist("public/acBlessWords.plist")
    spriteController:removeTexture("public/acBlessWords.png")
end

function acMingjiangpeiyangDialog:tick()
    local vo=acMingjiangpeiyangVoApi:getAcVo()
    if activityVoApi:isStart(vo)==false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    local todayFlag=acMingjiangpeiyangVoApi:isToday()
    if todayFlag~=self.isTodayFlag and todayFlag==false then
        self.isTodayFlag=todayFlag
        acMingjiangpeiyangVoApi:resetFreeNum()
        if self.oneTrainBtn and self.tenTrainBtn then
            tolua.cast(self.oneTrainBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("daily_lotto_tip_2"))
            if self.oneCostNode then
                self.oneCostNode:setVisible(false)
            end
            self.tenTrainBtn:setEnabled(false)
        end
    else
        self.isTodayFlag=todayFlag
    end

    self:updateAcTime()
end

function acMingjiangpeiyangDialog:updateAcTime()
    local acVo=acMingjiangpeiyangVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end