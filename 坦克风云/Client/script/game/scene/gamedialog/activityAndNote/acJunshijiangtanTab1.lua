acJunshijiangtanTab1 = {}

function acJunshijiangtanTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.flag = 2
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/sanguang.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acJunshijiangtan.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	return nc
end

function acJunshijiangtanTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
    acJunshijiangtanVoApi:formatData()
	self:initLayer()
	return self.bgLayer
end

function acJunshijiangtanTab1:initLayer()
	local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    descBg:setContentSize(CCSizeMake(580,180))
    descBg:setAnchorPoint(ccp(0.5,0))
    descBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height- 350))
    self.bgLayer:addChild(descBg)

   local timeSize = 23
   local timeShowWidth = 0
   local rewardHeightloc =0
   local timePosWidth = descBg:getContentSize().width/2+50+timeShowWidth
   if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" or G_getCurChoseLanguage()=="ru" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        timeSize =20
        timeShowWidth =30
        rewardHeightloc =-15
   -- elseif G_getCurChoseLanguage()=="ru" or G_getCurChoseLanguage() =="ja"  then
   --       timeSize =18
   --      timeShowWidth =30
   end
   if G_getCurChoseLanguage() =="ru" then
        timePosWidth=timePosWidth+60
   end
    local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),timeSize)
    timeTitle:setAnchorPoint(ccp(0,1))
	timeTitle:setPosition(ccp(110, 170))
	descBg:addChild(timeTitle)
	timeTitle:setColor(G_ColorGreen)

    local tansuoSp = CCSprite:createWithSpriteFrameName("intact.png")
    tansuoSp:setAnchorPoint(ccp(0,0))
    tansuoSp:setPosition(ccp(10,48))
    descBg:addChild(tansuoSp)


	local timeLabel = GetTTFLabelWrap(acJunshijiangtanVoApi:getTimeStr(),timeSize,CCSizeMake(descBg:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLabel:setAnchorPoint(ccp(0.5,1))
	timeLabel:setPosition(ccp(timePosWidth,170))
	descBg:addChild(timeLabel)

    local rewardTimeTitle = GetTTFLabel(getlocal("recRewardTime"),timeSize)
    rewardTimeTitle:setAnchorPoint(ccp(0,1))
    rewardTimeTitle:setPosition(ccp(110, 140+rewardHeightloc))
    descBg:addChild(rewardTimeTitle)
    rewardTimeTitle:setColor(G_ColorYellowPro)

    local rechargeTimeLabel = GetTTFLabelWrap(acJunshijiangtanVoApi:getRewardTimeStr(),timeSize,CCSizeMake(descBg:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    rechargeTimeLabel:setAnchorPoint(ccp(0.5,1))
    rechargeTimeLabel:setPosition(ccp(timePosWidth,140+rewardHeightloc))
    descBg:addChild(rechargeTimeLabel)
    self.descLb2=rechargeTimeLabel

    local acVo=acJunshijiangtanVoApi:getAcVo()
    self.timeLb=timeLabel
    self.rewardTimeLb=rechargeTimeLabel
    G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb,nil,true)

	local w = G_VisibleSizeWidth - 30 -- 背景框的宽度
	local desTv, desLabel = G_LabelTableView(CCSizeMake(w-150, 70),getlocal("activity_junshijiangtan_desc"),25,kCCTextAlignmentLeft)
 	descBg:addChild(desTv)
    desTv:setPosition(ccp(110,10))
    desTv:setAnchorPoint(ccp(0.5,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(100)
    self.descLb=desLabel

    local function touch(tag,object)
    	PlayEffect(audioCfg.mouseClick)
    	local tabStr = {}
    	local tabColor = {}
    	tabStr = {"\n",getlocal("activity_junshijiangtan_tab1_tip4"),"\n",getlocal("activity_junshijiangtan_tab1_tip3"),"\n",getlocal("activity_junshijiangtan_tab1_tip2"),"\n",getlocal("activity_junshijiangtan_tab1_tip1"),"\n"}
    	tabColor = {nil, nil, nil, nil, nil,nil, nil}
    	local td=smallDialog:new()
    	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
    	sceneGame:addChild(dialog,self.layerNum+1)

    end
    local menuPosWidth = descBg:getContentSize().width-20
    if G_getCurChoseLanguage() =="ru" then
        menuPosWidth =menuPosWidth+20
    end
    local menuItemDesc = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
  	local menuDesc=CCMenu:createWithItem(menuItemDesc)
  	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  	menuDesc:setPosition(ccp(menuPosWidth, descBg:getContentSize().height-10))
  	descBg:addChild(menuDesc)

    local tabMenuH = self.bgLayer:getContentSize().height-descBg:getContentSize().height-200
    if(G_isIphone5())then
        tabMenuH = self.bgLayer:getContentSize().height-descBg:getContentSize().height-210
    end
  	local tabStr = getlocal("hasChanceGet")
    local tabStrSize = 20
    if G_getCurChoseLanguage() =="ru" then
        tabStrSize =15
    end
  	local tabItem=GetButtonItem("RankBtnTab_Down.png", "RankBtnTab_Down.png","RankBtnTab_Down.png",touch,1,tabStr,tabStrSize)
    local tabMenu=CCMenu:createWithItem(tabItem)
    tabMenu:setPosition(ccp(100,tabMenuH))
    tabMenu:setTouchPriority(-(self.layerNum-1)*20-1)
    self.bgLayer:addChild(tabMenu,3)

    local btnBgH = self.bgLayer:getContentSize().height-descBg:getContentSize().height-360
    if(G_isIphone5())then
        btnBgH = self.bgLayer:getContentSize().height-descBg:getContentSize().height-380
    end
    local function clickTvItembg()      
    end
    local btnBg =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(40, 40, 10, 10),clickTvItembg)
    if(G_isIphone5())then
        btnBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,150))
    else
       btnBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,140))
    end
        btnBg:setPosition(ccp(G_VisibleSizeWidth/2,btnBgH))

    btnBg:setAnchorPoint(ccp(0.5, 0))
    self.bgLayer:addChild(btnBg,2)

  	local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(btnBg:getContentSize().width-50,btnBg:getContentSize().height-30),nil)
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    self.tv:setPosition(ccp(20,10))
    self.tv:setMaxDisToBottomOrTop(120)
    btnBg:addChild(self.tv)

    local jiaospH = 378
    local sanguangH = 420
    if(G_isIphone5())then
        jiaospH = 450
        sanguangH=535
    end
    self.jiaoSp1 = CCSprite:createWithSpriteFrameName("xieguang.png")
    self.jiaoSp1:setFlipX(true)
    self.jiaoSp1:setAnchorPoint(ccp(0.5,0))
    self.jiaoSp1:setPosition(self.bgLayer:getContentSize().width/2-35,jiaospH)
    self.bgLayer:addChild(self.jiaoSp1,0)

    self.jiaoSp2 = CCSprite:createWithSpriteFrameName("xieguang.png")
    self.jiaoSp2:setAnchorPoint(ccp(0.5,0))
    self.jiaoSp2:setPosition(self.bgLayer:getContentSize().width/2+35,jiaospH)
    self.bgLayer:addChild(self.jiaoSp2,0)

    self.sanguang = CCSprite:createWithSpriteFrameName("sanguang.png");
    
    self.bgLayer:addChild(self.sanguang)
    self.sanguang:setPosition(G_VisibleSizeWidth/2,sanguangH) 
    self.sanguang:setRotation(-90)
    if(G_isIphone5())then
        self.sanguang:setScaleY(1.5)
        self.sanguang:setScaleX(0.9) 
        self.jiaoSp1:setScaleY(1.5)
        self.jiaoSp2:setScaleY(1.5)
    else
        self.sanguang:setScaleY(1.5)
        self.sanguang:setScaleX(0.5) 
        self.jiaoSp2:setScaleY(0.6)
        self.jiaoSp2:setScaleX(1.5)
        self.jiaoSp2:setPosition(self.bgLayer:getContentSize().width/2-60,jiaospH)
        self.jiaoSp1:setScaleY(0.6)
        self.jiaoSp1:setScaleX(1.5)
        self.jiaoSp1:setPosition(self.bgLayer:getContentSize().width/2+60,jiaospH)

    end
     
    local strSize2 = 25
    if G_getCurChoseLanguage() =="ru" then
        strSize2 =22
    end

    local spH = 320
    if(G_isIphone5())then
        spH = 400
    end
    local spw = 200
    local function touchGaojisp(hd,fn,idx)
        if self.flag==3 then
            return
        else
            self.flag = 3
            self:refreshVisible()
            self:refresh()
        end
    end
    local gaojiSp = LuaCCSprite:createWithFileName("ship/heroskillImage/skill_s231.png",touchGaojisp)
    gaojiSp:setPosition(ccp(self.bgLayer:getContentSize().width/2+spw,spH))
    gaojiSp:setScale(1.2)
    gaojiSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(gaojiSp)

    local gaojiLabel = GetTTFLabel(getlocal("activity_junshijiangtan_gaojiLabel"),strSize2)
    gaojiLabel:setPosition(ccp(gaojiSp:getPositionX(),gaojiSp:getPositionY()-80))
    self.bgLayer:addChild(gaojiLabel)

    local checkGaoji = LuaCCSprite:createWithSpriteFrameName("BtnCheckBg.png",touchGaojisp)
    checkGaoji:setAnchorPoint(ccp(0.5,0.5))
    checkGaoji:setTouchPriority(-(self.layerNum-1)*20-4)
    checkGaoji:setPosition(ccp(self.bgLayer:getContentSize().width/2+spw,gaojiLabel:getPositionY()-50))
    self.bgLayer:addChild(checkGaoji,2)

    self.checkGaojiIcon = CCSprite:createWithSpriteFrameName("BtnCheck.png")
    --checkIcon:setAnchorPoint(ccp(0,0.5))
    self.checkGaojiIcon:setPosition(getCenterPoint(checkGaoji))
    checkGaoji:addChild(self.checkGaojiIcon,1)

    


    local function touchzhongjiSp(hd,fn,idx)
         if self.flag==2 then
            return
        else
            self.flag = 2
            self:refreshVisible()
            self:refresh()
        end
    end
    local zhongjiSp = LuaCCSprite:createWithSpriteFrameName("zhongjikecheng.png",touchzhongjiSp)
    zhongjiSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,spH))
    zhongjiSp:setScale(1.2)
    zhongjiSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(zhongjiSp)

    local zhongjiLabel = GetTTFLabel(getlocal("activity_junshijiangtan_zhongjiLabel"),strSize2)
    zhongjiLabel:setPosition(ccp(zhongjiSp:getPositionX(),zhongjiSp:getPositionY()-80))
    self.bgLayer:addChild(zhongjiLabel)

    local checkZhongji = LuaCCSprite:createWithSpriteFrameName("BtnCheckBg.png",touchzhongjiSp)
    checkZhongji:setAnchorPoint(ccp(0.5,0.5))
    checkZhongji:setTouchPriority(-(self.layerNum-1)*20-4)
    checkZhongji:setPosition(ccp(self.bgLayer:getContentSize().width/2,zhongjiLabel:getPositionY()-50))
    self.bgLayer:addChild(checkZhongji,2)

    self.checkZhongjiIcon = CCSprite:createWithSpriteFrameName("BtnCheck.png")
    --checkIcon:setAnchorPoint(ccp(0,0.5))
    self.checkZhongjiIcon:setPosition(getCenterPoint(checkZhongji))
    checkZhongji:addChild(self.checkZhongjiIcon,1)

    local function touchchujiSp(hd,fn,idx)
         if self.flag==1 then
            return
        else
            self.flag = 1
            self:refreshVisible()
            self:refresh()
        end
    end
    local chujiSp = LuaCCSprite:createWithSpriteFrameName("chujikecheng.png",touchchujiSp)
    chujiSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-spw,spH))
    chujiSp:setScale(1.2)
    chujiSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(chujiSp)

    local chujiLabel = GetTTFLabel(getlocal("activity_junshijiangtan_chujiLabel"),strSize2)
    chujiLabel:setPosition(ccp(chujiSp:getPositionX(),chujiSp:getPositionY()-80))
    self.bgLayer:addChild(chujiLabel)

    local checkChuji = LuaCCSprite:createWithSpriteFrameName("BtnCheckBg.png",touchchujiSp)
    checkChuji:setAnchorPoint(ccp(0.5,0.5))
    checkChuji:setTouchPriority(-(self.layerNum-1)*20-4)
    checkChuji:setPosition(ccp(self.bgLayer:getContentSize().width/2-spw,chujiLabel:getPositionY()-50))
    self.bgLayer:addChild(checkChuji,2)

    self.checkChujiIcon = CCSprite:createWithSpriteFrameName("BtnCheck.png")
    --checkIcon:setAnchorPoint(ccp(0,0.5))
    self.checkChujiIcon:setPosition(getCenterPoint(checkChuji))
    checkChuji:addChild(self.checkChujiIcon,1)

    -- local oneStudyBg = LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(40, 40, 10, 10),clickTvItembg)
    -- -- oneStudyBg:setContentSize(CCSizeMake(60,80))
    -- oneStudyBg:setPosition(ccp(10,90))       
    -- oneStudyBg:setAnchorPoint(ccp(0, 0))
    -- self.bgLayer:addChild(oneStudyBg)

    local onestudyH = 130
    local tenstudyH = 65
     if(G_isIphone5())then
        onestudyH = 160
        tenstudyH = 90
    end
    local oneStudyBg = CCSprite:createWithSpriteFrameName("RankItemBg.png")
    -- oneStudyBg:setContentSize(CCSizeMake(60,80))
    oneStudyBg:setPosition(ccp(G_VisibleSizeWidth/2-140,onestudyH)) 
    oneStudyBg:setScaleY(0.5)
    oneStudyBg:setScaleX(1.5)      
    oneStudyBg:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:addChild(oneStudyBg)

    local studySize = 25
    if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="ru" then
        studySize =22
    end
    local oneStudyLabel = GetTTFLabel(getlocal("activity_junshijiangtan_oneStudyLabel"),studySize)
    oneStudyLabel:setPosition(oneStudyBg:getPosition())
    self.bgLayer:addChild(oneStudyLabel)

    local tenStudyBg = CCSprite:createWithSpriteFrameName("RankItemBg.png")
    -- oneStudyBg:setContentSize(CCSizeMake(60,80))
    tenStudyBg:setPosition(ccp(G_VisibleSizeWidth/2-140,tenstudyH)) 
    tenStudyBg:setScaleY(0.5)
    tenStudyBg:setScaleX(1.5)      
    tenStudyBg:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:addChild(tenStudyBg)

    local tenStudyLabel = GetTTFLabel(getlocal("activity_junshijiangtan_tenStudyLabel"),studySize)
    tenStudyLabel:setPosition(tenStudyBg:getPosition())
    self.bgLayer:addChild(tenStudyLabel)

    local function oneStudyCallback()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local oneCost=acJunshijiangtanVoApi:getOneCost(self.flag)
        local diffGems=oneCost-playerVoApi:getGems()
        local isToday = acJunshijiangtanVoApi:isToday()
        if self.flag==2 then
            if isToday then
                if diffGems>0 then
                    GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost)
                    return
                end
                playerVoApi:setValue("gems",playerVoApi:getGems()-oneCost)
            end
        else
            if diffGems>0 then
                 GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost)
                 return
            end
            playerVoApi:setValue("gems",playerVoApi:getGems()-oneCost)
        end

        local function studyCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.junshijiangtan and sData.data.junshijiangtan.clientReward then
                    local rewardList = sData.data.junshijiangtan.clientReward
                    local content={}
                    for k,v in pairs(rewardList) do
                        local ptype = v[1]
                        local pID = v[2]
                        local num = v[3]
                        acJunshijiangtanVoApi:setScore(v[4])
                        local award = {}
                        local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
                        award={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId,point=v[4]}
                        G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                        table.insert(content,{award=award})

                    end
                    if content and SizeOfTable(content)>0 then
                        local function confirmHandler(awardIdx)
                        end
                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,nil,nil,nil,nil,true)

                        if self.flag==2 then
                            acJunshijiangtanVoApi:setLastTime(sData.ts)
                            self:refreshVisible()
                        end
                         acJunshijiangtanVoApi:updateData(sData.data.junshijiangtan)
                    end
                end
            end
        end
        socketHelper:activityJunshijiangtanStudy(self.flag,1,studyCallback)
    end
    local oneStudyItem = GetButtonItem("heroRecruitBtn2.png","heroRecruitBtn2Down.png","heroRecruitBtn2Down.png",oneStudyCallback,2,getlocal("activity_junshijiangtan_tab1_title"),20,11)
    local oneStudyMenu=CCMenu:createWithItem(oneStudyItem)
    oneStudyMenu:setPosition(ccp(G_VisibleSizeWidth/2+100,oneStudyBg:getPositionY()))
    oneStudyMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(oneStudyMenu)
    local lbOne=tolua.cast(oneStudyItem:getChildByTag(11),"CCLabelTTF")
    lbOne:setPosition(ccp(oneStudyItem:getContentSize().width*(1-1/8*5/2),oneStudyItem:getContentSize().height/2))
    self.oneStudyItem=oneStudyItem
    self.lbOne=lbOne
    self.onceBtn=oneStudyItem

    local mPos=oneStudyItem:getContentSize().width*(3/8/2)-5
    local mHeight=oneStudyItem:getContentSize().height/2
    local onegoldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    onegoldIcon:setPosition(ccp(mPos-22,mHeight))
    oneStudyItem:addChild(onegoldIcon)

    self.oneNumLb=GetTTFLabel(acJunshijiangtanVoApi:getOneCost(self.flag),20)
    oneStudyItem:addChild(self.oneNumLb)
    self.oneNumLb:setPosition(ccp(mPos+12,mHeight))
    self.oneNumLb:setColor(G_ColorYellowPro)


    local function tenStudyCallback()
         if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local tenCost=acJunshijiangtanVoApi:getTenCost(self.flag)
        local diffGems=tenCost-playerVoApi:getGems()
        if diffGems>0 then
             GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,tenCost)
             return
        end
        playerVoApi:setValue("gems",playerVoApi:getGems()-tenCost)


        local function studyCallback(fn,data)
             local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.junshijiangtan and sData.data.junshijiangtan.clientReward then
                    local rewardList = sData.data.junshijiangtan.clientReward
                    local content={}
                    -- local msgContent={}
                    for k,v in pairs(rewardList) do
                        local ptype = v[1]
                        local pID = v[2]
                        local num = v[3]
                        acJunshijiangtanVoApi:setScore(v[4])
                        local award = {}
                        local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
                        award={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId,point=v[4]}
                        G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                        table.insert(content,{award=award})

                    end
                    if content and SizeOfTable(content)>0 then
                        local function confirmHandler(awardIdx)
                        end
                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,nil,nil,nil,nil,true)
                         acJunshijiangtanVoApi:updateData(sData.data.junshijiangtan)
                    end
                end
            end
        end
        socketHelper:activityJunshijiangtanStudy(self.flag,2,studyCallback)
    end
    local tenStudyItem = GetButtonItem("heroRecruitBtn2.png","heroRecruitBtn2Down.png","heroRecruitBtn2Down.png",tenStudyCallback,2,getlocal("activity_junshijiangtan_tab1_Menu"),20,11)
    local tenStudyMenu=CCMenu:createWithItem(tenStudyItem)
    tenStudyMenu:setPosition(ccp(G_VisibleSizeWidth/2+100,tenStudyBg:getPositionY()))
    tenStudyMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tenStudyMenu)
    local lbTen=tolua.cast(tenStudyItem:getChildByTag(11),"CCLabelTTF")
    lbTen:setPosition(ccp(tenStudyItem:getContentSize().width*(1-1/8*5/2),tenStudyItem:getContentSize().height/2))
    self.tenBtn=tenStudyItem

    local mPos1=tenStudyItem:getContentSize().width*(3/8/2)-5
    local mHeight1=tenStudyItem:getContentSize().height/2
    local tengoldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    tengoldIcon:setPosition(ccp(mPos1-22,mHeight1))
    tenStudyItem:addChild(tengoldIcon)

    self.tenNumLb=GetTTFLabel(acJunshijiangtanVoApi:getTenCost(self.flag),20)
    tenStudyItem:addChild(self.tenNumLb)
    self.tenNumLb:setPosition(ccp(mPos1+12,mHeight1))
    self.tenNumLb:setColor(G_ColorYellowPro)

    self:refreshVisible()
    self:refresh()
end

function acJunshijiangtanTab1:eventHandler(handler,fn,idx,cel)
	 if fn=="numberOfCellsInTableView" then	 	
        -- return acJunshijiangtanVoApi:getTvNum(self.flag)
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local num = SizeOfTable(acJunshijiangtanVoApi:gerFormadata(self.flag))
		tmpSize=CCSizeMake(105+(num-1)*130,105)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease() 
        
	    local Formadata = acJunshijiangtanVoApi:gerFormadata(self.flag)
        for k,v in pairs(Formadata) do
            local formadata=v
            award={name=formadata.name,num=formadata.num,pic=formadata.pic,desc=formadata.desc,id=formadata.id,type=formadata.type,index=formadata.index,key=formadata.key,eType=formadata.eType,equipId=formadata.equipId}
            if award then
               local icon,iconScale = G_getItemIcon(award,100,true,self.layerNum,nil,self.tv)
                icon:setTouchPriority(-(self.layerNum-1)*20-5)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(10+(k-1)*130,50)
                cell:addChild(icon)

                local num = GetTTFLabel("x"..award.num,25/iconScale)
                num:setAnchorPoint(ccp(1,0))
                num:setPosition(icon:getContentSize().width-10,10)
                icon:addChild(num)
            end 
        end

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function acJunshijiangtanTab1:refreshVisible()
    if self.flag==1 then
        self.jiaoSp1:setVisible(true)
        self.jiaoSp2:setVisible(false)
        self.sanguang:setVisible(false)
        self.checkChujiIcon:setVisible(true)
        self.checkZhongjiIcon:setVisible(false)
        self.checkGaojiIcon:setVisible(false)
        self.oneNumLb:setString(acJunshijiangtanVoApi:getOneCost(self.flag))
        self.tenNumLb:setString(acJunshijiangtanVoApi:getTenCost(self.flag))
        self.lbOne:setString(getlocal("activity_junshijiangtan_tab1_title"))
        self.tenBtn:setEnabled(true)
        self.tv:reloadData()
    elseif self.flag==2 then
        self.jiaoSp1:setVisible(false)
        self.jiaoSp2:setVisible(false)
        self.sanguang:setVisible(true)
        self.checkChujiIcon:setVisible(false)
        self.checkZhongjiIcon:setVisible(true)
        self.checkGaojiIcon:setVisible(false)
        local isToday = acJunshijiangtanVoApi:isToday()
        if isToday then
            self.oneNumLb:setString(acJunshijiangtanVoApi:getOneCost(self.flag))
            self.lbOne:setString(getlocal("activity_junshijiangtan_tab1_title"))
            self.tenBtn:setEnabled(true)
        else
            self.oneNumLb:setString("0")
            self.lbOne:setString(getlocal("daily_lotto_tip_2"))
            self.tenBtn:setEnabled(false)

        end
        self.tenNumLb:setString(acJunshijiangtanVoApi:getTenCost(self.flag))
        self.tv:reloadData()
    elseif self.flag==3 then
        self.jiaoSp1:setVisible(false)
        self.jiaoSp2:setVisible(true)
        self.sanguang:setVisible(false)
        self.checkChujiIcon:setVisible(false)
        self.checkZhongjiIcon:setVisible(false)
        self.checkGaojiIcon:setVisible(true)
        self.tenBtn:setEnabled(true)
         self.oneNumLb:setString(acJunshijiangtanVoApi:getOneCost(self.flag))
        self.tenNumLb:setString(acJunshijiangtanVoApi:getTenCost(self.flag))
        self.lbOne:setString(getlocal("activity_junshijiangtan_tab1_title"))
        self.tv:reloadData()
    end
end

function acJunshijiangtanTab1:refresh()
   if self and self.bgLayer then
        local isToday = acJunshijiangtanVoApi:isToday()
        if self.flag==2 then
            if isToday then
                self.oneNumLb:setString(acJunshijiangtanVoApi:getOneCost(self.flag))
                self.lbOne:setString(getlocal("activity_junshijiangtan_tab1_title"))
                self.tenBtn:setEnabled(true)
            else
                self.oneNumLb:setString("0")
                self.lbOne:setString(getlocal("daily_lotto_tip_2"))
                self.tenBtn:setEnabled(false)

            end
        else
            self.tenBtn:setEnabled(true)
        end

        if acJunshijiangtanVoApi:checkCanSearch()==false then
            self.onceBtn:setEnabled(false)
            self.tenBtn:setEnabled(false)
        else
            --self.onceBtn:setEnabled(true)
            --self.tenBtn:setEnabled(true)
        end

        if self.descLb then
            if acJunshijiangtanVoApi:acIsStop()==true then
                self.descLb:setString(getlocal("activity_equipSearch_time_end"))
            end
        end

    end
end

function acJunshijiangtanTab1:tick()
    if self.timeLb and self.rewardTimeLb then
        local acVo = acJunshijiangtanVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb,nil,true)
    end
end

function acJunshijiangtanTab1:dispose()
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/heroRecruitImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/sanguang.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acJunshijiangtan.plist")
    self.bgLayer=nil
    self.layerNum=nil
    self.flag = nil
    self.descLb=nil
    self.tenBtn=nil
    self.onceBtn=nil
    self.jiaoSp1=nil
    self.jiaoSp2=nil
    self.sanguang=nil
    self.checkChujiIcon=nil
    self.checkZhongjiIcon=nil
    self.checkGaojiIcon=nil
    self.oneNumLb=nil
    self.tenNumLb=nil
    self.lbOne=nil
    self.timeLb=nil
    self.rewardTimeLb=nil
    self.tv=nil
end

