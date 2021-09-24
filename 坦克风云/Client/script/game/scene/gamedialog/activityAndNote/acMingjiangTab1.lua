acMingjiangTab1 = {}

function acMingjiangTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acMingjiangjiantou.plist")
	return nc
end

function acMingjiangTab1:initLogData()
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
            if ret==true then 
                if sData.data==nil then 
                    return
                end
                acMingjiangVoApi:clearLogData()
                if sData.data and sData.data.log then
                    acMingjiangVoApi:initLogData(sData.data.log)
                end
                self.timeLogTb,self.itemLogTb,self.itemNumLogTb = acMingjiangVoApi:getLogList()
                if self and self.bgLayer then
                    self:initLayer()
                end
            end                
    end
    socketHelper:activeMingjiangLog(callBack)
end

function acMingjiangTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLogData()
	return self.bgLayer
end

function acMingjiangTab1:initLayer()
	local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    descBg:setContentSize(CCSizeMake(580,100))
    descBg:setAnchorPoint(ccp(0.5,0))
    descBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height- 265))
    self.bgLayer:addChild(descBg)

   local timeSize = 25
   local timeShowWidth = 0
   local rewardHeightloc =0
   if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" then
        timeSize =23
        timeShowWidth =30
    elseif G_getCurChoseLanguage()=="ru" or G_getCurChoseLanguage() =="ja"  then
        timeSize =21
        timeShowWidth =30
        rewardHeightloc =-15
   end

    local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),timeSize)
    timeTitle:setAnchorPoint(ccp(0,1))
	timeTitle:setPosition(ccp(10,90))
	descBg:addChild(timeTitle)
	timeTitle:setColor(G_ColorGreen)

    local timeLabel
        if acMingjiangVoApi:acIsStop()~=true then
                timeLabel = GetTTFLabelWrap(acMingjiangVoApi:getTimeStr(),timeSize,CCSizeMake(descBg:getContentSize().width-250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                timeLabel:setPosition(ccp(descBg:getContentSize().width/2+30+timeShowWidth,90))
        else
            timeLabel = GetTTFLabelWrap(getlocal("activity_equipSearch_time_end"),timeSize-5,CCSizeMake(descBg:getContentSize().width-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            timeLabel:setPosition(ccp(descBg:getContentSize().width/2+30,90))
        end
    	timeLabel:setAnchorPoint(ccp(0.5,1))
    	
    	descBg:addChild(timeLabel)
        self.descLb=timeLabel

    local rewardTimeTitle = GetTTFLabel(getlocal("recRewardTime"),timeSize)
    rewardTimeTitle:setAnchorPoint(ccp(0,1))
    rewardTimeTitle:setPosition(ccp(10,50+rewardHeightloc))
    descBg:addChild(rewardTimeTitle)
    rewardTimeTitle:setColor(G_ColorYellowPro)

    local rechargeTimeLabel = GetTTFLabelWrap(acMingjiangVoApi:getRewardTimeStr(),timeSize,CCSizeMake(descBg:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    rechargeTimeLabel:setAnchorPoint(ccp(0.5,1))
    rechargeTimeLabel:setPosition(ccp(descBg:getContentSize().width/2+30+timeShowWidth,50+rewardHeightloc))
    descBg:addChild(rechargeTimeLabel)
    self.descLb2=rechargeTimeLabel

    self:updateAcTime()

	local function touch(tag,object)
    	PlayEffect(audioCfg.mouseClick)
    	local tabStr = {}
    	local tabColor = {}

    	tabStr = {"\n",getlocal("activity_mingjiang_tab1_tip",{acMingjiangVoApi:getValue()}),"\n",getlocal("activity_mingjiang_tab1_tip5"),"\n",getlocal("activity_mingjiang_tab1_tip4"),"\n",getlocal("activity_mingjiang_tab1_tip3"),"\n",getlocal("activity_mingjiang_tab1_tip2"),"\n",getlocal("activity_mingjiang_tab1_tip1"),"\n"}
    	tabColor = {nil, G_ColorRed, nil, nil, nil,nil, nil, nil,nil, nil}
        local value=acMingjiangVoApi:getValue()
        if value==10 then
            tabStr = {"\n",getlocal("activity_mingjiang_tab1_tip5"),"\n",getlocal("activity_mingjiang_tab1_tip4"),"\n",getlocal("activity_mingjiang_tab1_tip3"),"\n",getlocal("activity_mingjiang_tab1_tip2"),"\n",getlocal("activity_mingjiang_tab1_tip1"),"\n"}
            tabColor = { nil, nil, nil,nil, nil, nil,nil, nil}
        end
    	local td=smallDialog:new()
    	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
    	sceneGame:addChild(dialog,self.layerNum+1)

    end

    local menuItemDesc = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
  	local menuDesc=CCMenu:createWithItem(menuItemDesc)
  	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  	menuDesc:setPosition(ccp(descBg:getContentSize().width-20, descBg:getContentSize().height-10))
  	descBg:addChild(menuDesc)

    local progressH = self.bgLayer:getContentSize().height- 320
    if (G_isIphone5()) then
      progressH = self.bgLayer:getContentSize().height- 340
  end
	-- 进度条
	AddProgramTimer(self.bgLayer,ccp(self.bgLayer:getContentSize().width/2-25,progressH),110,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",111,barWScale,nil)
	self.loadingBar = tolua.cast(self.bgLayer:getChildByTag(110),"CCProgressTimer")
	self.loadingBarBg = tolua.cast(self.bgLayer:getChildByTag(111),"CCSprite")
	self.loadingBarBg:setRotation(180)
	self.loadingBar:setRotation(180)
	self.loadingBar:setScaleX(1.15)
	self.loadingBarBg:setScaleX(1.15)
	self.loadingBar:setScaleY(1.3)
	self.loadingBarBg:setScaleY(1.3)
	self.loadingBar:setMidpoint(ccp(1,0))
	self.loadingBar:setPercentage(0)

	local jiangliH = self.bgLayer:getContentSize().height- 450
  if (G_isIphone5()) then
      jiangliH = self.bgLayer:getContentSize().height- 470
  end

	local award1 = acMingjiangVoApi:getAward(1)
	local jiangli1,iconScale = G_getItemIcon(award1,100,true,self.layerNum,nil,nil)
	jiangli1:setPosition(ccp(self.bgLayer:getContentSize().width/2-68-150,jiangliH))
    jiangli1:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(jiangli1)


	local award2 = acMingjiangVoApi:getAward(2)
	local jiangli2,iconScale = G_getItemIcon(award2,100,true,self.layerNum,nil,nil)
    jiangli2:setPosition(ccp(self.bgLayer:getContentSize().width/2-71,jiangliH))
    jiangli2:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(jiangli2)

    local award3 = acMingjiangVoApi:getAward(3)
	local jiangli3,iconScale = G_getItemIcon(award3,100,true,self.layerNum,nil,nil)
    jiangli3:setPosition(ccp(self.bgLayer:getContentSize().width/2+75,jiangliH))
    jiangli3:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(jiangli3)

    local award4 = acMingjiangVoApi:getAward(4)
    local hasProductOrder
    local heroData=heroVoApi:getHeroByHid(award4.key)
    if heroData and heroData.productOrder then
        hasProductOrder=heroData.productOrder
    end
    local oldHeroList3=heroVoApi:getHeroList()
    local jiangli4,iconScale
    local type,heroIsExist,addNum=heroVoApi:getNewHeroData(award4,oldHeroList3)
    if heroIsExist==true and hasProductOrder and hasProductOrder>=award4.num then
        local awardS=G_clone(award4)
        -- 显示魂魄
        -- awardS.num=1
        -- awardS.eType=nil
        jiangli4,iconScale = G_getItemIcon(awardS,100,true,self.layerNum,nil,nil,nil,true)
    else
        jiangli4,iconScale = G_getItemIcon(award4,100,true,self.layerNum,nil,nil)
    end
    jiangli4:setPosition(ccp(self.bgLayer:getContentSize().width/2+70+150,jiangliH))
    jiangli4:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(jiangli4)

    -- 显示魂魄
    -- if heroIsExist==true then
    --     local soulNum = GetTTFLabel("x170",30)
    --     soulNum:setAnchorPoint(ccp(1,1))
    --     soulNum:setPosition(ccp(140,40))
    --     jiangli4:addChild(soulNum)
    -- end

    


    local fengeH = self.bgLayer:getContentSize().height- 285
    if (G_isIphone5()) then
      fengeH = self.bgLayer:getContentSize().height- 300
    end

    local scoreReward = acMingjiangVoApi:getscoreReward()
    self.scoreReward=scoreReward
    local fenggeLb1 = GetTTFLabel(scoreReward[1][1],25)
    fenggeLb1:setPosition(ccp(jiangli1:getPositionX(),fengeH))
    self.bgLayer:addChild(fenggeLb1)

    local fenggeLb2 = GetTTFLabel(scoreReward[2][1],25)
    fenggeLb2:setPosition(ccp(jiangli2:getPositionX(),fengeH))
    self.bgLayer:addChild(fenggeLb2)

    local fenggeLb3 = GetTTFLabel(scoreReward[3][1],25)
    fenggeLb3:setPosition(ccp(jiangli3:getPositionX(),fengeH))
    self.bgLayer:addChild(fenggeLb3)

    local fenggeLb4 = GetTTFLabel(scoreReward[4][1],25)
    fenggeLb4:setPosition(ccp(jiangli4:getPositionX(),fengeH))
    self.bgLayer:addChild(fenggeLb4)

    local jiantouH = jiangli1:getPositionY()+82
    local jiantou1W = jiangli1:getPositionX()
    local jiantouLinag1 = CCSprite:createWithSpriteFrameName("acMingjiangjiantouliang.png")
    jiantouLinag1:setPosition(ccp(jiantou1W,jiantouH))
    jiantouLinag1:setScale(1.2)
    self.bgLayer:addChild(jiantouLinag1)
    self.jiantouLinag1=jiantouLinag1

    local jiantouAn1 = CCSprite:createWithSpriteFrameName("acMingjiangjiantouan.png")
    jiantouAn1:setPosition(ccp(jiantou1W,jiantouH))
    jiantouAn1:setScale(1.2)
    self.bgLayer:addChild(jiantouAn1)
    self.jiantouAn1=jiantouAn1

     local jiantou2W = jiangli2:getPositionX()
    local jiantouLinag2 = CCSprite:createWithSpriteFrameName("acMingjiangjiantouliang.png")
    jiantouLinag2:setPosition(ccp(jiantou2W,jiantouH))
    jiantouLinag2:setScale(1.2)
    self.bgLayer:addChild(jiantouLinag2)
    self.jiantouLinag2=jiantouLinag2

    local jiantouAn2 = CCSprite:createWithSpriteFrameName("acMingjiangjiantouan.png")
    jiantouAn2:setPosition(ccp(jiantou2W,jiantouH))
    jiantouAn2:setScale(1.2)
    self.bgLayer:addChild(jiantouAn2)
    self.jiantouAn2=jiantouAn2

    local jiantou3W = jiangli3:getPositionX()
    local jiantouLinag3 = CCSprite:createWithSpriteFrameName("acMingjiangjiantouliang.png")
    jiantouLinag3:setPosition(ccp(jiantou3W,jiantouH))
    jiantouLinag3:setScale(1.2)
    self.bgLayer:addChild(jiantouLinag3)
    self.jiantouLinag3=jiantouLinag3

    local jiantouAn3 = CCSprite:createWithSpriteFrameName("acMingjiangjiantouan.png")
    jiantouAn3:setPosition(ccp(jiantou3W,jiantouH))
    jiantouAn3:setScale(1.2)
    self.bgLayer:addChild(jiantouAn3)
    self.jiantouAn3=jiantouAn3

    local jiantou4W = jiangli4:getPositionX()
    local jiantouLinag4 = CCSprite:createWithSpriteFrameName("acMingjiangjiantouliang.png")
    jiantouLinag4:setPosition(ccp(jiantou4W,jiantouH))
    jiantouLinag4:setScale(1.2)
    self.bgLayer:addChild(jiantouLinag4)
    self.jiantouLinag4=jiantouLinag4

    local jiantouAn4 = CCSprite:createWithSpriteFrameName("acMingjiangjiantouan.png")
    jiantouAn4:setPosition(ccp(jiantou4W,jiantouH))
    jiantouAn4:setScale(1.2)
    self.bgLayer:addChild(jiantouAn4)
    self.jiantouAn4=jiantouAn4



    local xinxiH = self.bgLayer:getContentSize().height- 730
    local xinxiSize=CCSizeMake(580,200)
    if(G_isIphone5())then
        xinxiH = self.bgLayer:getContentSize().height- 785
        xinxiSize=CCSizeMake(580,210)
    end
     local jiangliXingxiBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    jiangliXingxiBg:setContentSize(xinxiSize)
    jiangliXingxiBg:setAnchorPoint(ccp(0.5,0))
    jiangliXingxiBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,xinxiH))
    self.bgLayer:addChild(jiangliXingxiBg)

    local function touchHeroIcon()
        PlayEffect(audioCfg.mouseClick)        
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"
        local award = acMingjiangVoApi:getAward(4)
        local hid = award.key
        local heroProductOrder=award.num
        local td = acHuoxianmingjiangHeroInfoDialog:new(hid,heroProductOrder)
        local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
        sceneGame:addChild(dialog,self.layerNum+1)
     end   

     local award = acMingjiangVoApi:getAward(4)
     local hid = award.key
     local heroProductOrder=award.num
     local heroIcon = heroVoApi:getHeroIcon(hid,heroProductOrder,true,touchHeroIcon,nil,nil,nil,{adjutants={}})
     heroIcon:setTouchPriority(-(self.layerNum-1)*20-4)
     heroIcon:setPosition(ccp(self.bgLayer:getContentSize().width/2-210,110))
     heroIcon:setScale(0.8)
     jiangliXingxiBg:addChild(heroIcon)

      local heroNameLabel = GetTTFLabel(heroVoApi:getHeroName(hid),25)
     heroNameLabel:setAnchorPoint(ccp(0,1))
     heroNameLabel:setColor(heroVoApi:getHeroColor(heroProductOrder))
     heroNameLabel:setPosition(ccp(210, 170))
     jiangliXingxiBg:addChild(heroNameLabel)

     local productOrderLabel = GetTTFLabel(getlocal("hero_productOrder"),25)
     productOrderLabel:setPosition(ccp(210,120))
     productOrderLabel:setAnchorPoint(ccp(0,0.5))
     jiangliXingxiBg:addChild(productOrderLabel)

     local xinW = productOrderLabel:getPositionX()+60+productOrderLabel:getContentSize().width/2
     local h = productOrderLabel:getPositionY()
     for i=1,heroProductOrder do              
        local spriteStar = CCSprite:createWithSpriteFrameName("StarIcon.png")                  
        jiangliXingxiBg:addChild(spriteStar)
        spriteStar:setPosition(ccp(xinW,h))
        xinW = xinW+40
     end

    local desPosWidth =175
    local deslbPosWidth = 285
    local descSize = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        desPosWidth =210
        descSize =25
        deslbPosWidth =270
    end
     local heroDesLabel = GetTTFLabel(getlocal("hero_info_Introduction_title"), descSize)
     heroDesLabel:setAnchorPoint(ccp(0, 0.5))
     heroDesLabel:setPosition(ccp(desPosWidth, 80))
     jiangliXingxiBg:addChild(heroDesLabel)

     local heroDes
     local version = acMingjiangVoApi:getVersion()
     if version==nil then
        version=1
     end
     if version==1 then
        heroDes=getlocal("hero_info_Introduction1")
     elseif version==2 then
        heroDes=getlocal("hero_info_Introduction2")
     elseif version==3 then
        heroDes=getlocal("active_mingjiang_hero_des")
     else
        heroDes=getlocal("active_mingjiang_hero_des" .. version)
     end
     local heroDesTvSize = CCSizeMake(290, 90)
     local heroDesTv, heroIntroduction = G_LabelTableView(heroDesTvSize,heroDes,25,kCCTextAlignmentLeft)
    jiangliXingxiBg:addChild(heroDesTv)
    heroDesTv:setPosition(ccp(deslbPosWidth,10))
    heroDesTv:setAnchorPoint(ccp(0,0))
    heroDesTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    heroDesTv:setMaxDisToBottomOrTop(100) 

    self:addChoujiangjilu()

    local btnH = 35
    if(G_isIphone5())then
        btnH = 80
    end
    local function touchOneRecruitItem()
    	 if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local oneCost=acMingjiangVoApi:getOneCost()
        local diffGems=oneCost-playerVoApi:getGems()
        local isToday = acMingjiangVoApi:isToday()

        if isToday then
            if diffGems>0 then
                GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost)
                return
            end
            playerVoApi:setValue("gems",playerVoApi:getGems()-oneCost)
        end

        local function recruitCallback(fn,data)
            local oldHeroList=heroVoApi:getHeroList()
            local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData.data==nil then 
                  return
                end
                if sData.data and sData.data.hero and sData.data.hero.report then
                    self:showHero(sData.data.hero.report[1][1],oldHeroList)
                    acMingjiangVoApi:updateData(sData.data.huoxianmingjianggai)
                    self:refreshVisible()
                    self:refreshLogData()
                end
            end
        end
        socketHelper:activeMingjiangchoujiang(0,recruitCallback)
    end

    local strSize = 25
    if G_getCurChoseLanguage() =="ru" then
        strSize =22
    end
	local oneRecruitItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchOneRecruitItem,nil,getlocal("recruit"),strSize)
	oneRecruitItem:setAnchorPoint(ccp(0.5,0))
	local oneRecruitBtn=CCMenu:createWithItem(oneRecruitItem);
	oneRecruitBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	oneRecruitBtn:setPosition(ccp(G_VisibleSizeWidth/2-150,btnH))
	self.bgLayer:addChild(oneRecruitBtn)
    self.oneRecruitBtn=oneRecruitItem

	local addH1=80
      if(G_isIphone5())then
            addH1=90
      end
	self.oneLabel = GetTTFLabel(getlocal("activity_equipSearch_free_btn"),20)
	self.oneLabel:setAnchorPoint(ccp(0,0))
	self.oneLabel:setPosition(G_VisibleSizeWidth/2-150-oneRecruitItem:getContentSize().width/4, btnH+addH1)
	self.bgLayer:addChild(self.oneLabel)
	self.oneLabel :setColor(G_ColorGreen)

	local oneCost = acMingjiangVoApi:getOneCost()
	self.oneCostLabel = GetTTFLabel(tostring(oneCost),25)
	self.oneCostLabel:setAnchorPoint(ccp(0,0))
	self.oneCostLabel:setPosition(G_VisibleSizeWidth/2-150-oneRecruitItem:getContentSize().width/4+20, btnH+addH1-5)
	self.oneCostLabel:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(self.oneCostLabel)

	self.oneGem = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.oneGem:setAnchorPoint(ccp(0,0))
	self.oneGem:setPosition(G_VisibleSizeWidth/2-150-oneRecruitItem:getContentSize().width/4+self.oneCostLabel:getContentSize().width+20, btnH+addH1-5)
	self.bgLayer:addChild(self.oneGem) 

    local function touchTenRecruitItem()
    	if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local tenCost=acMingjiangVoApi:getTenCost()
        local diffGems=tenCost-playerVoApi:getGems()
        if diffGems>0 then
             GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,tenCost)
             return
        end
        playerVoApi:setValue("gems",playerVoApi:getGems()-tenCost)


        local function recruitCallback(fn,data)
            local oldHeroList3=heroVoApi:getHeroList()
            local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData.data==nil then 
                  return
                end

                if sData.data and sData.data.hero and sData.data.hero.report and self and self.bgLayer then
                    local rewardList = sData.data.hero.report or {}
                    local content={}
                    local msgContent={}
                    for k,v in pairs(rewardList) do
                        local awardTb=FormatItem(v[1]) or {}
                        local award=awardTb[1]

                        local existStr=""
                        local showStr
                         if award.type=="h" and award.eType=="h" then
                            local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList3)
                            if heroIsExist==true then
                                if heroVoApi:heroHonorIsOpen()==true and  heroVoApi:getIsHonored(award.key)==true then
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
                            elseif heroIsExist==false then
                                local vo = heroVo:new()
                                vo.hid=award.key
                                vo.level=1
                                vo.points=0
                                vo.productOrder=award.num
                                vo.skill={}
                                table.insert(oldHeroList3,vo)

                                heroVoApi:getNewHeroChat(award.key)
                            end
                            showStr=getlocal("congratulationsGet",{award.name})..existStr
                        else
                            showStr=getlocal("congratulationsGet",{award.name .. "*" .. award.num})
                            if award.type=="h" and award.eType=="s" then
                                local heroid=heroCfg.soul2hero[award.key]
                                if heroVoApi:heroHonorIsOpen()==true and  heroVoApi:getIsHonored(heroid)==true then
                                    existStr=","..getlocal("hero_honor_recruit_honored_hero",{award.num})
                                    showStr=showStr..existStr
                                    local addNum=award.num
                                    if addNum and addNum>0 then
                                        local pid=heroCfg.getSkillItem
                                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                                        bagVoApi:addBag(id,addNum)
                                    end
                                end
                            end
                        end

                        table.insert(content,{award=award})
                        table.insert(msgContent,{showStr,G_ColorWhite})
                        G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                    end
                    if content and SizeOfTable(content)>0 then
                        local function confirmHandler(awardIdx)
                        end
                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("heroRecruitTotal"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,msgContent)
                        acMingjiangVoApi:updateData(sData.data.huoxianmingjianggai)
                        self:refreshVisible()
                        self:refreshLogData()
                    end
                end
            end
        end
        socketHelper:activeMingjiangchoujiang(1,recruitCallback)
    end

	local tenRecruitItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchTenRecruitItem,nil,getlocal("activity_huoxianmingjiang_btnTen"),strSize)
	tenRecruitItem:setAnchorPoint(ccp(0.5,0))
	local tenRecruitBtn=CCMenu:createWithItem(tenRecruitItem);
	tenRecruitBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	tenRecruitBtn:setPosition(ccp(G_VisibleSizeWidth/2+150,btnH))
	self.bgLayer:addChild(tenRecruitBtn)
    self.tenRecruitBtn=tenRecruitItem

	local tenCost = acMingjiangVoApi:getTenCost()
	self.tenCostLabel = GetTTFLabel(tostring(tenCost),25)
	self.tenCostLabel:setAnchorPoint(ccp(0,0))
	self.tenCostLabel:setPosition(G_VisibleSizeWidth/2+150-tenRecruitItem:getContentSize().width/4+20, btnH+addH1-5)
	self.oneCostLabel:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(self.tenCostLabel)

	self.tenGem = CCSprite:createWithSpriteFrameName("IconGold.png")
	self.tenGem:setAnchorPoint(ccp(0,0))
	self.tenGem:setPosition(G_VisibleSizeWidth/2+150-tenRecruitItem:getContentSize().width/4+self.tenCostLabel:getContentSize().width+20, btnH+addH1-5)
	self.bgLayer:addChild(self.tenGem) 

  local function touchLingquItem()
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)
    local function callback(fn,data)
        local oldHeroList3=heroVoApi:getHeroList()
        local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData.data==nil then 
                  return
                end

                local score = acMingjiangVoApi:getScore()
                local rewardCfg=self.scoreReward or {}
                local reward
                if score>=self.scoreReward[4][1] then
                    reward=FormatItem(rewardCfg[4][2]) or {}
                elseif score>=self.scoreReward[3][1] then
                    reward=FormatItem(rewardCfg[3][2]) or {}
                elseif score>=self.scoreReward[2][1] then
                    reward=FormatItem(rewardCfg[2][2]) or {}
                elseif score>=self.scoreReward[1][1] then
                    reward=FormatItem(rewardCfg[1][2]) or {}
                end
               
                if reward then
                    for k,v in pairs(reward) do
                        if v.type=="h" then
                            local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(v,oldHeroList3)
                            if heroIsExist==true then
                                -- local sid = heroVoApi:getSoulSid(v.key)
                                -- heroVoApi:addSoul(sid,170)
                                local addNum=170
                                local showStr=getlocal("active_mingjiang_show_tip2",{award.name,addNum})
                                local existStr=""
                                local hid
                                if v.eType=="h" then
                                    hid=v.key
                                else
                                    hid=heroCfg.soul2hero[v.key]
                                end
                                if hid and heroVoApi:heroHonorIsOpen()==true and heroVoApi:getIsHonored(hid)==true then
                                    existStr=","..getlocal("hero_honor_recruit_honored_hero",{addNum})
                                    if addNum and addNum>0 then
                                        local pid=heroCfg.getSkillItem
                                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                                        bagVoApi:addBag(id,addNum)
                                    end
                                else
                                    if newProductOrder then
                                        showStr=getlocal("hero_breakthrough_desc",{newProductOrder})
                                        -- existStr=","..getlocal("hero_breakthrough_desc",{newProductOrder})
                                    -- else
                                    --     existStr=","..getlocal("alreadyHasDesc",{addNum})
                                    end
                                end
                                showStr=showStr..existStr
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),showStr,30)
                            else
                                local vo = heroVo:new()
                                vo.hid=v.key
                                vo.level=1
                                vo.points=0
                                vo.productOrder=award.num
                                vo.skill={}
                                table.insert(oldHeroList3,vo)
                                heroVoApi:getNewHeroChat(v.key)
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("active_mingjiang_show_tip",{award.num,award.name}),30)
                            end
                        else
                            G_showRewardTip(reward)  
                        end
                    end
                    for k,v in pairs(reward) do
                        G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                    end
                    
                end
                acMingjiangVoApi:updateData(sData.data.huoxianmingjianggai)
                self:refreshVisible()
            end
    end
    socketHelper:activityMingjianggetScoreReward(callback)
  end
  local lingquItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchLingquItem,nil,getlocal("daily_scene_get"),25)
  lingquItem:setAnchorPoint(ccp(0.5,0))
  local lingquBtn=CCMenu:createWithItem(lingquItem);
  lingquBtn:setTouchPriority(-(self.layerNum-1)*20-4);
  lingquBtn:setPosition(ccp(G_VisibleSizeWidth/2,btnH))
  self.lingquBtn = lingquItem
  self.bgLayer:addChild(lingquBtn)

  self:refreshVisible()
  self:refresh()
end

function acMingjiangTab1:showHero(reward,oldHeroList)
    if reward then
        local rewardTb=FormatItem(reward)
        local award=rewardTb[1]
        if award then
            if award.type=="h" then
                local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList)
                G_recruitShowHero(type,award,self.layerNum+1,heroIsExist,addNum,nil,newProductOrder)

                if award.eType=="h" and heroIsExist==false then
                    heroVoApi:getNewHeroChat(award.key)
                end

                if heroVoApi:heroHonorIsOpen()==true then
                    local hid
                    if award.eType=="h" then 
                        hid=award.key
                    elseif award.eType=="s" then
                        hid=heroCfg.soul2hero[award.key]
                    end 
                    if hid and heroVoApi:getIsHonored(hid)==true then
                        local pid=heroCfg.getSkillItem
                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                        bagVoApi:addBag(id,addNum)
                    end
                end
            else
                G_addPlayerAward(award.type,award.key,award.id,award.num,false,true)
                G_recruitShowHero(3,award,self.layerNum+1,nil,nil,nil)
            end
        end
    end
end

-- 添加抽奖记录
function acMingjiangTab1:addChoujiangjilu()

  local h = G_VisibleSizeHeight-780
  if(G_isIphone5())then
        h = G_VisibleSizeHeight-870
  end

  local function bgClick()
  end
  local logBackSprite = LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBg.png",CCRect(20, 20, 10, 10),bgClick)
    logBackSprite:setRotation(180)
    logBackSprite:setContentSize(CCSizeMake(G_VisibleSizeWidth-50, 70))
    logBackSprite:setPosition(ccp(G_VisibleSizeWidth/2, h))    
    self.bgLayer:addChild(logBackSprite)

    local eventStr = getlocal("activity_huoxianmingjiang_log_tip0")
    local color = G_ColorWhite
    if SizeOfTable(self.timeLogTb)~=0 then


      if string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="h" then
        eventStr = getlocal("activity_huoxianmingjiang_log_tip1",{self.itemNumLogTb[SizeOfTable(self.timeLogTb)],heroVoApi:getHeroName(self.itemLogTb[SizeOfTable(self.timeLogTb)])})
        color = G_ColorYellow
       elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="s" then
       eventStr = getlocal("activity_huoxianmingjiang_log_tip2",{heroVoApi:getHeroName(heroCfg.soul2hero[self.itemLogTb[SizeOfTable(self.timeLogTb)]]),self.itemNumLogTb[SizeOfTable(self.timeLogTb)]})
         
       elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="p" then
        eventStr = getlocal("activity_huoxianmingjiang_log_tip3",{getlocal(propCfg[self.itemLogTb[SizeOfTable(self.timeLogTb)]].name),self.itemNumLogTb[SizeOfTable(self.timeLogTb)]})
       end
    end

  self.recentLog = GetTTFLabelWrap(eventStr, 25, CCSizeMake(450,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.recentLog:setColor(color)
   self.recentLog:setAnchorPoint(ccp(0,0.5))
   self.bgLayer:addChild(self.recentLog)
   self.recentLog:setPosition(ccp(150, h))


  local function heroItemTouch()
     if G_checkClickEnable()==false then
                do
                    return
                end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
        end
      PlayEffect(audioCfg.mouseClick)

       require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangLogDialog"
       local td = acHuoxianmingjiangLogDialog:new(self.timeLogTb,self.itemLogTb,self.itemNumLogTb)
       local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("activity_customLottery_RewardRecode"))
       sceneGame:addChild(dialog,self.layerNum+1)
 
    end
    local heroInfoItem = GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",heroItemTouch,11,nil,nil)
   local heroMenu = CCMenu:createWithItem(heroInfoItem)
   heroMenu:setAnchorPoint(ccp(0,0.5))
   
   heroMenu:setTouchPriority(-(self.layerNum-1)*20-4)
   heroMenu:setPosition(ccp(63,h))
   self.bgLayer:addChild(heroMenu)
end

function acMingjiangTab1:refreshLogData()
 local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
            if ret==true then 
                if sData.data==nil then 
                    return
                end
                acMingjiangVoApi:clearLogData()
                if sData.data and sData.data.log then
                    acMingjiangVoApi:initLogData(sData.data.log)
                end
                self.timeLogTb,self.itemLogTb,self.itemNumLogTb = acMingjiangVoApi:getLogList()
                self:refreshRecentLog()
            end                
    end
    socketHelper:activeMingjiangLog(callBack)
end

function acMingjiangTab1:refreshRecentLog()
  local eventStr = getlocal("activity_huoxianmingjiang_log_tip0")
    local color = G_ColorWhite
    if SizeOfTable(self.timeLogTb)~=0 then

      if string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="h" then
        eventStr = getlocal("activity_huoxianmingjiang_log_tip1",{self.itemNumLogTb[SizeOfTable(self.timeLogTb)],heroVoApi:getHeroName(self.itemLogTb[SizeOfTable(self.timeLogTb)])})
        color = G_ColorYellow
       elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="s" then
       eventStr = getlocal("activity_huoxianmingjiang_log_tip2",{heroVoApi:getHeroName(heroCfg.soul2hero[self.itemLogTb[SizeOfTable(self.timeLogTb)]]),self.itemNumLogTb[SizeOfTable(self.timeLogTb)]})
         
       elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="p" then
        eventStr = getlocal("activity_huoxianmingjiang_log_tip3",{getlocal(propCfg[self.itemLogTb[SizeOfTable(self.timeLogTb)]].name),self.itemNumLogTb[SizeOfTable(self.timeLogTb)]})
       end
    end
  self.recentLog:setString(eventStr)
end

function acMingjiangTab1:refreshVisible()
    local score = acMingjiangVoApi:getScore()
    local rongyuPoint = acMingjiangVoApi:getrongyuPoint()
    if score==nil then
        score=0
    end
    if rongyuPoint==nil then
        rongyuPoint={0,0,0,0}
    end

    self.scoreReward=acMingjiangVoApi:getscoreReward()
    if score>=self.scoreReward[4][1] then
        self.loadingBar:setPercentage(100)
    else
        if self.loadingBar then
            if score<=self.scoreReward[1][1] then
                self.loadingBar:setPercentage(score/self.scoreReward[1][1]*10)
            elseif score<=self.scoreReward[2][1] then
                self.loadingBar:setPercentage(10+(score-self.scoreReward[1][1])/(self.scoreReward[2][1]-self.scoreReward[1][1])*30)
            elseif score<=self.scoreReward[3][1] then
                self.loadingBar:setPercentage(40+(score-self.scoreReward[2][1])/(self.scoreReward[3][1]-self.scoreReward[2][1])*30)
            else
                self.loadingBar:setPercentage(70+(score-self.scoreReward[3][1])/(self.scoreReward[4][1]-self.scoreReward[3][1])*30)
            end
        end
    end

    if score>=self.scoreReward[1][1] and rongyuPoint[1]==0 or score>=self.scoreReward[2][1] and rongyuPoint[2]==0 or score>=self.scoreReward[3][1] and rongyuPoint[3]==0 or score>=self.scoreReward[4][1] and rongyuPoint[4]==0  then
        self.lingquBtn:setVisible(true)
        self.oneRecruitBtn:setVisible(false)
        self.tenRecruitBtn:setVisible(false)       

        self.oneLabel:setVisible(false)
        self.oneCostLabel:setVisible(false)
        self.oneGem:setVisible(false)

        self.tenCostLabel:setVisible(false)
        self.tenGem:setVisible(false)
    else
        self.lingquBtn:setVisible(false)
        self.oneRecruitBtn:setVisible(true)
        self.tenRecruitBtn:setVisible(true)

        self.tenCostLabel:setVisible(true)
        self.tenGem:setVisible(true)
        if acMingjiangVoApi:isToday() then
            self.oneLabel:setVisible(false)
            self.oneCostLabel:setVisible(true)
            self.oneGem:setVisible(true)
        else
            self.oneLabel:setVisible(true)
            self.oneCostLabel:setVisible(false)
            self.oneGem:setVisible(false)
        end
    end

    if score>=self.scoreReward[4][1] then
        self.jiantouAn1:setVisible(false)
        self.jiantouAn2:setVisible(false)
        self.jiantouAn3:setVisible(false)
        self.jiantouAn4:setVisible(false)
    elseif score>=self.scoreReward[3][1] then
        self.jiantouAn1:setVisible(false)
        self.jiantouAn2:setVisible(false)
        self.jiantouAn3:setVisible(false)
    elseif score>=self.scoreReward[2][1] then
       self.jiantouAn1:setVisible(false)
        self.jiantouAn2:setVisible(false)
    elseif score>=self.scoreReward[1][1] then
         self.jiantouAn1:setVisible(false)
    end

end

function acMingjiangTab1:refresh()
   if self and self.bgLayer then
       local isToday = acMingjiangVoApi:isToday()
        if isToday  then
            if self.tenRecruitBtn then
                self.tenRecruitBtn:setEnabled(true)
            end
        else

            if self.tenRecruitBtn then
                self.tenRecruitBtn:setEnabled(false)
            end
            if self.oneLabel then
                self.oneLabel:setVisible(true)
            end
            if self.oneCostLabel then
                self.oneCostLabel:setVisible(false)
            end
            if self.oneGem then
                self.oneGem:setVisible(false)
            end
        end
     
        if acMingjiangVoApi:checkCanSearch()==false then
            if self.oneRecruitBtn then
                self.oneRecruitBtn:setEnabled(false)
            end
             if self.tenRecruitBtn then
                self.tenRecruitBtn:setEnabled(false)
            end 
        -- else

        --     if self.oneRecruitBtn then
        --         self.oneRecruitBtn:setEnabled(true)
        --     end
        --      if self.tenRecruitBtn then
        --         self.tenRecruitBtn:setEnabled(true)
        --     end          
        end

        -- if self.descLb then
        --     if acMingjiangVoApi:acIsStop()==true then
        --         self.descLb:setString(getlocal("activity_equipSearch_time_end"))
        --     end
        -- end

    end
end

function acMingjiangTab1:tick()
    self:updateAcTime()
end

function acMingjiangTab1:updateAcTime()
  local acVo=acMingjiangVoApi:getAcVo()
  if acVo then
     G_updateActiveTime(acVo,self.descLb,self.descLb2,nil,true)
  end
end

function acMingjiangTab1:dispose()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acMingjiangjiantou.plist")
    self.bgLayer=nil
    self.layerNum=nil
    self.jiantouLinag1=nil
    self.jiantouAn1=nil
    self.jiantouLinag2=nil
    self.jiantouAn2=nil
    self.jiantouLinag3=nil
    self.jiantouAn3=nil
    self.jiantouLinag4=nil
    self.jiantouAn4=nil
    self.scoreReward=nil
    self.loadingBar=nil
    self.descLb=nil
    self.descLb2=nil
    self.oneRecruitBtn=nil
    self.tenRecruitBtn=nil
    self.oneLabel=nil
    self.oneCostLabel=nil
    self.oneGem=nil
    self.tenCostLabel=nil
    self.tenGem=nil
    self.lingquBtn=nil
    self.loadingBarBg=nil
end

