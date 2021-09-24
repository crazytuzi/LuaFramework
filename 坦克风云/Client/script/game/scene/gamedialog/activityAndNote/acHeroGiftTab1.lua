acHeroGiftTab1={}

function acHeroGiftTab1:new( )
	local  nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
	self.layerNum=nil

	self.recuitOne=nil
	self.recuitTen=nil
	return nc
end

function acHeroGiftTab1:init( layerNum)
	require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    
    -- self:initTableView()
    self:initBottomLayer()

    return self.bgLayer
end	

function acHeroGiftTab1:initBottomLayer( )

	  local h = G_VisibleSizeHeight - 90
	  if(G_isIphone5())then
	    h = G_VisibleSizeHeight - 100
	  end
	  local w = G_VisibleSizeWidth - 30 -- 背景框的宽度
    
    local strSize2 = 23
    local needWidth2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" then
        strSize2 =28
        needWidth2 = 0
    end
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),strSize2)
    actTime:setPosition(ccp(50-needWidth2,self.bgLayer:getContentSize().height-195))
    actTime:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorYellowPro)
    
    local rewardTimeStr = GetTTFLabel(getlocal("recRewardTime"),strSize2)
    rewardTimeStr:setAnchorPoint(ccp(0,0.5))
    rewardTimeStr:setColor(G_ColorYellowPro)
    rewardTimeStr:setPosition(ccp(50-needWidth2,self.bgLayer:getContentSize().height-230))
    self.bgLayer:addChild(rewardTimeStr,5)

    local acVo = acHeroGiftVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,24)
        timeLabel:setAnchorPoint(ccp(0,0.5))
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2-110+needWidth2, self.bgLayer:getContentSize().height-195))
        self.bgLayer:addChild(timeLabel)
        self.timeLb=timeLabel

        local timeStr2=activityVoApi:getActivityRewardTimeStr(acVo.acEt,60,86400)
        local timeLabel2=GetTTFLabel(timeStr2,24)
        timeLabel2:setAnchorPoint(ccp(0,0.5))
        timeLabel2:setPosition(ccp(self.bgLayer:getContentSize().width/2-110+needWidth2, self.bgLayer:getContentSize().height-230))
        self.bgLayer:addChild(timeLabel2)
        self.rewardLb=timeLabel2
        self:updateAcTime()
    end

    local function touch(tag,object)
    	PlayEffect(audioCfg.mouseClick)
    	local tabStr = {}
    	local tabColor = {}
    	tabStr = {"\n",getlocal("activity_heroGift_tip2"),"\n",getlocal("activity_heroGift_tip1"),"\n"}
    	tabColor = {nil, nil, nil, nil, nil}
    	local td=smallDialog:new()
    	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
    	sceneGame:addChild(dialog,self.layerNum+1)

    end

    local menuItemDesc = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
  	local menuDesc=CCMenu:createWithItem(menuItemDesc)
  	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  	menuDesc:setPosition(ccp(w-20, self.bgLayer:getContentSize().height-180))
  	self.bgLayer:addChild(menuDesc)

  	local function bgClick( ) --用于backSprie,heroBackDrop1,heroBackDrop2
  		
  	end 
 	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
    local bgHeightSize = self.bgLayer:getContentSize().height*0.2-50
    if G_isIphone5() then
        bgHeightSize=bgHeightSize+70
    end
    backSprie:setContentSize(CCSizeMake(w-20, bgHeightSize))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height-250))
    self.bgLayer:addChild(backSprie)

    -- for i=1,4 do
    --     local fj=CCSprite:createWithSpriteFrameName("VSBarbedWire-.png")
    --     backSprie:addChild(fj,15)
    --     fj:setAnchorPoint(ccp(0.5,0.5))
    --     fj:setPosition(ccp(backSprie:getContentSize().width*0.5,backSprie:getContentSize().height))
    --     fj:setScaleY(1)
    --     fj:setScaleX(0.6)
    --     if i%2 ==0 and i%4 ==0 then
    --         fj:setPosition(ccp(0,backSprie:getContentSize().height*0.5))
    --         fj:setRotation(90)
    --         fj:setScaleY(1)
    --         fj:setScaleX(0.3)
    --     elseif i%2 ==0 then
    --         fj:setPosition(ccp(backSprie:getContentSize().width,backSprie:getContentSize().height*0.5))
    --         fj:setRotation(90)
    --         fj:setScaleY(1)
    --         fj:setScaleX(0.3)
    --     elseif i%3 ==0 then
    --         fj:setPosition(ccp(backSprie:getContentSize().width*0.5,0))
    --     end
    --     -- fj:setPosition(ccp(size.width/2,size.height/2-25))

        
    -- end




    local showHeroList = acHeroGiftVoApi:getShowHero()
    local lbWidthPos = 55
    if G_getCurChoseLanguage() =="ar" then
        lbWidthPos =35
    end
 	local desTv, desLabel = G_LabelTableView(CCSizeMake(w-160, backSprie:getContentSize().height*0.8),getlocal("activity_heroGift_desc",{showHeroList[1].name,showHeroList[1].num,showHeroList[2].name,showHeroList[2].num}),22,kCCTextAlignmentLeft)
 	backSprie:addChild(desTv)
    desTv:setPosition(ccp(lbWidthPos,backSprie:getContentSize().height*0.1))
    desTv:setAnchorPoint(ccp(0.5,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(100)  

    local score = acHeroGiftVoApi:getScore()
    local currentIntegral=GetTTFLabel(getlocal("dailyAnswer_tab1_recentLabelNum",{score}),28) --当前积分 需要刷新 需要添加积分的函数VoApi
    currentIntegral:setPosition(ccp(25,self.bgLayer:getContentSize().height*0.5+50))
    currentIntegral:setAnchorPoint(ccp(0,0.5))
    currentIntegral:setTag(55)
    currentIntegral:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(currentIntegral)

 	local heroBackDrop1 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
    heroBackDrop1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width*0.9+15, self.bgLayer:getContentSize().height*0.2))
    heroBackDrop1:setAnchorPoint(ccp(0,1))
    heroBackDrop1:setPosition(ccp(25, currentIntegral:getPositionY()-30))
    self.bgLayer:addChild(heroBackDrop1)

    local heroShowName1 = showHeroList[1].name
    local heroShowNum1 = showHeroList[1].num --品阶
    local heroShowDes1= showHeroList[1].desc

    local function heroItemTouch( ... )
        local td = acHuoxianmingjiangHeroInfoDialog:new(showHeroList[1].key,heroShowNum1)
        local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
        sceneGame:addChild(dialog,self.layerNum+1)
    end

	local heroInfoItem = GetButtonItem("worldBtnModify.png","worldBtnModify.png","worldBtnModify.png",heroItemTouch,11,nil,nil)
	local heroMenu = CCMenu:createWithItem(heroInfoItem)
	heroMenu:setAnchorPoint(ccp(0,0))
	heroMenu:setScale(0.85)

	heroMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	heroMenu:setPosition(ccp(heroBackDrop1:getContentSize().width-40,heroBackDrop1:getContentSize().height-40))
	heroBackDrop1:addChild(heroMenu)   

    local function bcall( ... )
    	
    end 
    local heroShowIcon1 = G_getItemIcon(showHeroList[1],nil,false,self.layerNum,bcall)
    heroShowIcon1:setPosition(ccp(30,heroBackDrop1:getContentSize().height*0.5))
    heroShowIcon1:setAnchorPoint(ccp(0,0.5))
    heroBackDrop1:addChild(heroShowIcon1)

    heroShowNameLb1=GetTTFLabel(heroShowName1,24)
    heroShowNameLb1:setPosition(heroShowIcon1:getContentSize().width+10,heroBackDrop1:getContentSize().height-25)
    heroShowNameLb1:setAnchorPoint(ccp(0,0.5))
    heroBackDrop1:addChild(heroShowNameLb1)

    local gradeLb = GetTTFLabel(getlocal("hero_productOrder"),22)
    gradeLb:setPosition(ccp(heroShowIcon1:getContentSize().width+10,heroBackDrop1:getContentSize().height-55))
    gradeLb:setAnchorPoint(ccp(0,0.5))
    heroBackDrop1:addChild(gradeLb)
    local startHeight = gradeLb:getPositionY()
    local startWidht = gradeLb:getPositionX()+gradeLb:getContentSize().width+30
    for i=1,heroShowNum1 do              
        local spriteStar = CCSprite:createWithSpriteFrameName("StarIcon.png")                  
        heroBackDrop1:addChild(spriteStar)
        spriteStar:setAnchorPoint(ccp(0.5,0.5))
        spriteStar:setPosition(ccp(startWidht,startHeight))
        startWidht = startWidht+40
    end

    local needWIdht = 0
    if G_getCurChoseLanguage() =="ar" then
        needWIdht =50
    end
    local introduc = GetTTFLabel(getlocal("alliance_info_Introduction"),22)
    introduc:setPosition(ccp(heroShowIcon1:getContentSize().width+10,heroBackDrop1:getContentSize().height-80))
    introduc:setAnchorPoint(ccp(0,0.5))
    heroBackDrop1:addChild(introduc)
    local heroShowDescLb = G_LabelTableView(CCSizeMake(heroBackDrop1:getContentSize().width*0.5+needWIdht, heroBackDrop1:getContentSize().height-80),getlocal(heroShowDes1),22,kCCTextAlignmentLeft)
 	heroBackDrop1:addChild(heroShowDescLb)
    heroShowDescLb:setPosition(ccp(introduc:getPositionX()+introduc:getContentSize().width+20,5))
    heroShowDescLb:setAnchorPoint(ccp(0,0))
    heroShowDescLb:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    heroShowDescLb:setMaxDisToBottomOrTop(100) 

 	local heroBackDrop2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
    heroBackDrop2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width*0.9+15, self.bgLayer:getContentSize().height*0.2))
    heroBackDrop2:setAnchorPoint(ccp(0,1))
    heroBackDrop2:setPosition(ccp(25, heroBackDrop1:getPositionY()-heroBackDrop1:getContentSize().height-10))
    self.bgLayer:addChild(heroBackDrop2)

    local heroShowName2 = showHeroList[2].name
    local heroShowNum2 = showHeroList[2].num --品阶
    local heroShowDes2= showHeroList[2].desc

    local function heroItemTouch2( ... )
        local td = acHuoxianmingjiangHeroInfoDialog:new(showHeroList[2].key,heroShowNum2)
        local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
        sceneGame:addChild(dialog,self.layerNum+1)
    end

	local heroInfoItem2 = GetButtonItem("worldBtnModify.png","worldBtnModify.png","worldBtnModify.png",heroItemTouch2,11,nil,nil)
	local heroMenu2 = CCMenu:createWithItem(heroInfoItem2)
	heroMenu2:setAnchorPoint(ccp(0,0))
	heroMenu2:setScale(0.85)

	heroMenu2:setTouchPriority(-(self.layerNum-1)*20-4)
	heroMenu2:setPosition(ccp(heroBackDrop2:getContentSize().width-40,heroBackDrop2:getContentSize().height-40))
	heroBackDrop2:addChild(heroMenu2)   

    local heroShowIcon2 = G_getItemIcon(showHeroList[2],nil,false,self.layerNum,bcall)
    heroShowIcon2:setPosition(ccp(30,heroBackDrop2:getContentSize().height*0.5))
    heroShowIcon2:setAnchorPoint(ccp(0,0.5))
    heroBackDrop2:addChild(heroShowIcon2)

    heroShowNameLb2=GetTTFLabel(heroShowName2,24)
    heroShowNameLb2:setPosition(heroShowIcon2:getContentSize().width+10,heroBackDrop2:getContentSize().height-25)
    heroShowNameLb2:setAnchorPoint(ccp(0,0.5))
    heroBackDrop2:addChild(heroShowNameLb2)

    local gradeLb2 = GetTTFLabel(getlocal("hero_productOrder"),22)
    gradeLb2:setPosition(ccp(heroShowIcon2:getContentSize().width+10,heroBackDrop2:getContentSize().height-55))
    gradeLb2:setAnchorPoint(ccp(0,0.5))
    heroBackDrop2:addChild(gradeLb2)
    local startHeight = gradeLb2:getPositionY()
    local startWidht = gradeLb2:getPositionX()+gradeLb2:getContentSize().width+30
    for i=1,heroShowNum2 do              
        local spriteStar = CCSprite:createWithSpriteFrameName("StarIcon.png")                  
        heroBackDrop2:addChild(spriteStar)
        spriteStar:setAnchorPoint(ccp(0.5,0.5))
        spriteStar:setPosition(ccp(startWidht,startHeight))
        startWidht = startWidht+40
    end

    local introduc2 = GetTTFLabel(getlocal("alliance_info_Introduction"),22)
    introduc2:setPosition(ccp(heroShowIcon2:getContentSize().width+10,heroBackDrop2:getContentSize().height-80))
    introduc2:setAnchorPoint(ccp(0,0.5))
    heroBackDrop2:addChild(introduc2)
    local heroShowDescLb2 = G_LabelTableView(CCSizeMake(heroBackDrop2:getContentSize().width*0.5+needWIdht*0.8, heroBackDrop2:getContentSize().height-80),getlocal(heroShowDes2),22,kCCTextAlignmentLeft)
 	heroBackDrop2:addChild(heroShowDescLb2)
    heroShowDescLb2:setPosition(ccp(introduc2:getPositionX()+introduc2:getContentSize().width+20,5))
    heroShowDescLb2:setAnchorPoint(ccp(0,0))
    heroShowDescLb2:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    heroShowDescLb2:setMaxDisToBottomOrTop(100) 




    local str1 = getlocal("recruit")
    local str2 = getlocal("continuousRecruit")
    local function recruitHandler1( ...)
    	self:clickSingleReward(...)
    end 
	
    self.recuitOne = GetButtonItem("heroRecruitBtn2.png","heroRecruitBtn2Down.png","heroRecruitBtn2Down.png",recruitHandler1,11,str1,20,111)
    self.recuitOne:setAnchorPoint(ccp(0,0))
    self.recuitOne:setScaleX(0.9)
  	local recuitOnebtn=CCMenu:createWithItem(self.recuitOne)
  	recuitOnebtn:setTouchPriority(-(self.layerNum-1)*20-5)
  	recuitOnebtn:setPosition(ccp(40,50))
  	self.bgLayer:addChild(recuitOnebtn)

	local lb=tolua.cast(self.recuitOne:getChildByTag(111),"CCLabelTTF")  -- 单抽 10连抽 按钮文字位置调整
 	lb:setPosition(ccp(self.recuitOne:getContentSize().width*0.7,self.recuitOne:getContentSize().height*0.5))

	local goldIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
    -- goldIcon1:setScale()
    goldIcon1:setAnchorPoint(ccp(0.5,0.5))
    goldIcon1:setPosition(ccp(20,self.recuitOne:getContentSize().height*0.5))
    self.recuitOne:addChild(goldIcon1)
    goldIcon1:setVisible(true)
    goldIcon1:setTag(112)

    local singleGoldNum = acHeroGiftVoApi:getSingleGoldShow()
    local goldNum1 = GetTTFLabel(singleGoldNum,22) --------
    goldNum1:setAnchorPoint(ccp(0.5,0.5))
    goldNum1:setPosition(ccp(goldIcon1:getPositionX()+goldIcon1:getContentSize().width+5,self.recuitOne:getContentSize().height*0.5))
    self.recuitOne:addChild(goldNum1)
    goldNum1:setVisible(true)
    goldNum1:setTag(222)

   local freeShow = GetTTFLabel(getlocal("daily_lotto_tip_2"),22) --------
    freeShow:setAnchorPoint(ccp(0.5,0.5))
    freeShow:setPosition(ccp(goldIcon1:getPositionX()+goldIcon1:getContentSize().width-5,self.recuitOne:getContentSize().height*0.5))
    self.recuitOne:addChild(freeShow)
    freeShow:setVisible(false)
    freeShow:setTag(444)


    local function recruitHandler2( ...)
    	self:clickSingleReward2(...)
    end 
    local str2Size = 15
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        str2Size =20
    end
    self.recuitTen = GetButtonItem("heroRecruitBtn2.png","heroRecruitBtn2Down.png","heroRecruitBtn2.png",recruitHandler2,22,str2,str2Size,222)
    self.recuitTen:setAnchorPoint(ccp(1,0))
    self.recuitTen:setScaleX(0.9)
  	local recuitTenbtn=CCMenu:createWithItem(self.recuitTen)
  	recuitTenbtn:setTouchPriority(-(self.layerNum-1)*20-5)
  	recuitTenbtn:setPosition(ccp(self.bgLayer:getContentSize().width-40,50))
  	self.bgLayer:addChild(recuitTenbtn)
  	local lb2=tolua.cast(self.recuitTen:getChildByTag(222),"CCLabelTTF")  -- 单抽 10连抽 按钮文字位置调整
 	lb2:setPosition(ccp(self.recuitTen:getContentSize().width*0.7,self.recuitTen:getContentSize().height*0.5))

	local goldIcon2=CCSprite:createWithSpriteFrameName("IconGold.png")
    -- goldIcon1:setScale()
    goldIcon2:setAnchorPoint(ccp(0.5,0.5))
    goldIcon2:setPosition(ccp(20,self.recuitTen:getContentSize().height*0.5))
    self.recuitTen:addChild(goldIcon2)
    goldIcon2:setVisible(true)
    goldIcon2:setTag(1)
    local mulGoldNum = acHeroGiftVoApi:getMulGoldShow()
    local goldNum2 = GetTTFLabel(mulGoldNum,22) --------
    goldNum2:setAnchorPoint(ccp(0.5,0.5))
    goldNum2:setPosition(ccp(goldIcon2:getPositionX()+goldIcon2:getContentSize().width+5,self.recuitTen:getContentSize().height*0.5))
    self.recuitTen:addChild(goldNum2)
    goldNum2:setVisible(true)
    goldNum2:setTag(2)

    if acHeroGiftVoApi:isFree() ==true and acHeroGiftVoApi:acIsStop() ==false then
    	goldIcon1:setVisible(false)
    	goldNum1:setVisible(false)
    	freeShow:setVisible(true)
    	self.recuitTen:setEnabled(false)
    end
    if acHeroGiftVoApi:acIsStop() then
    	self.recuitOne:setEnabled(false)
    	self.recuitTen:setEnabled(false)
    end
end

function acHeroGiftTab1:clickSingleReward( ... )
	 if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)

	local oneCost=acHeroGiftVoApi:getSingleGoldShow( )
    local diffGems=oneCost-playerVoApi:getGems()
	local method = 2
	if acHeroGiftVoApi:isFree() ==true then
		method =1
	end
	if method ==2 then
		if diffGems>0 and playerVoApi:getGems()~=0 then
			GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost)
			return
		end
        if playerVoApi:getGems()==0 and diffGems>0 then
            GemsNotEnoughDialog(nil,nil,oneCost,self.layerNum+1,oneCost)
            return
        end
	end
	local function freeOrSingleAward( fn,data )
        local oldHeroList=heroVoApi:getHeroList()
        local ret,sData = base:checkServerData(data)
        if acHeroGiftVoApi:acIsStop() then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("acOver"),28)
            do return end
        end
        if ret==true then
            if sData.data==nil then 
              return
            end
            if tonumber(sData.data.twohero.c)==1 and acHeroGiftVoApi:isFree()==false then
            	playerVoApi:setValue("gems",playerVoApi:getGems()-oneCost)
            end
            if sData.data.twohero.v then
            	acHeroGiftVoApi:setScore( tonumber(sData.data.twohero.v ))
            end
            if sData.data.twohero.t then
            	acHeroGiftVoApi:setLastTime(tonumber(sData.data.twohero.t))
            end
            if sData.data.twohero then
                acHeroGiftVoApi:updateData(sData.data.twohero)
            end
            local scoreSHow = nil
            local reward = {}
            if sData.data and sData.data.report and sData.data.report then
                for k,v in pairs(sData.data.report) do
                	for r,t in pairs(v) do
                		if tonumber(t)  then
                			-- acHeroGiftVoApi:setScore( t,2 )
                            -- print("ttttttttt111",t)
                			scoreSHow=t
	                	elseif SizeOfTable(t)~=nil then
    		            	-- local award=FormatItem(t) or {}
	                		reward =t
	                	end

	                end
                end
            end
            if SizeOfTable(reward) and scoreSHow then
				acHeroGiftVoApi:showHero(reward,oldHeroList,scoreSHow,true,self.layerNum)
			end
            self:refresh()
        end
	end 
	socketHelper:acHeroGiftSending("rand",method,freeOrSingleAward)
end





function acHeroGiftTab1:clickSingleReward2( ... )
	 if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
    PlayEffect(audioCfg.mouseClick)

	local tenCost=acHeroGiftVoApi:getMulGoldShow( )
    local diffGems=tenCost-playerVoApi:getGems()
	local method = 3
	
	if method ==3 then
		if diffGems>0 and playerVoApi:getGems()~=0 then
			GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,tenCost)
			return
		end
        if playerVoApi:getGems()==0 and diffGems>0 then
            GemsNotEnoughDialog(nil,nil,tenCost,self.layerNum+1,tenCost)
            return
        end
	end
	local function tenCostAward( fn,data )
		local oldHeroList3=heroVoApi:getHeroList()
        local ret,sData = base:checkServerData(data)
        if acHeroGiftVoApi:acIsStop() then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("acOver"),28)
            do return end
        end
        if ret==true then
            if sData.data==nil then 
              return
            end
            if tonumber(sData.data.twohero.c)==1 then
            	print(" not free~~~~",sData.data.twohero.c)
            	playerVoApi:setValue("gems",playerVoApi:getGems()-tenCost)
            end
            if sData.data.twohero.v then
            	acHeroGiftVoApi:setScore( tonumber(sData.data.twohero.v ))
            end
            if sData.data.twohero.t then
            	acHeroGiftVoApi:setLastTime(tonumber(sData.data.twohero.t))
            end
            if sData.data.twohero then
                acHeroGiftVoApi:updateData(sData.data.twohero)
            end
            -- local scoreSHow = nil
            if sData.data and sData.data.report and sData.data.report then
            	local content={}
            	local msgContent = {}
            	local showStr = nil
            	local scoreSHow = {}
                for k,v in pairs(sData.data.report) do
                	for r,t in pairs(v) do
                		if tonumber(t)  then
                			-- acHeroGiftVoApi:setScore( t,2 )
                   --          print("ttttttttt222",t)
                			table.insert(scoreSHow,t)
	                	elseif SizeOfTable(t)~=nil then
								 -- local award=FormatItem(t) or {}
	 						local awardTb=FormatItem(v[1]) or {}
	                        local award=awardTb[1]

	                        local existStr=""
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

	                end
                end
                if SizeOfTable(scoreSHow) then
                	for i=1,SizeOfTable(scoreSHow) do
                		msgContent[i][1]=msgContent[i][1]..", "..getlocal("serverwar_get_point")..scoreSHow[i]
                	end
                end
                if content and SizeOfTable(content)>0 then
                    local function confirmHandler(awardIdx)
                    end
                    smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("heroRecruitTotal"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,msgContent)
                    -- acMingjiangVoApi:updateData(sData.data.huoxianmingjianggai)
                    -- self:refreshVisible()
                    -- self:refreshLogData()
                end
            end

            self:refresh()
        end
	end 
	socketHelper:acHeroGiftSending("rand",method,tenCostAward)
end

function acHeroGiftTab1:refresh()
	if acHeroGiftVoApi:isFree() ==false then
		local goldIcon1 = tolua.cast(self.recuitOne:getChildByTag(112),"CCSprite")
		local goldNum1 = tolua.cast(self.recuitOne:getChildByTag(222),"CCLabelTTF")
		local freeShow = tolua.cast(self.recuitOne:getChildByTag(444),"CCLabelTTF")
		goldIcon1:setVisible(true)
    	goldNum1:setVisible(true)
    	freeShow:setVisible(false)
    	self.recuitTen:setEnabled(true)

		local score = acHeroGiftVoApi:getScore()
    	local currentIntegral = tolua.cast(self.bgLayer:getChildByTag(55),"CCLabelTTF")
    	currentIntegral:setString(getlocal("dailyAnswer_tab1_recentLabelNum",{score}))
    end
end

function acHeroGiftTab1:tick(  )
	if acHeroGiftVoApi:isToday()==false and acHeroGiftVoApi:acIsStop() ==false then
		local goldIcon1 = tolua.cast(self.recuitOne:getChildByTag(112),"CCSprite")
		local goldNum1 = tolua.cast(self.recuitOne:getChildByTag(222),"CCLabelTTF")
		local freeShow = tolua.cast(self.recuitOne:getChildByTag(444),"CCLabelTTF")
		goldIcon1:setVisible(false)
    	goldNum1:setVisible(false)
    	freeShow:setVisible(true)
    	self.recuitTen:setEnabled(false)
        -- acHeroGiftVoApi:updateShow()
    	acHeroGiftVoApi:setLastTime(0)
    end
    if acHeroGiftVoApi:acIsStop() ==true then
        self.recuitOne:setEnabled(false)
        self.recuitTen:setEnabled(false)
    end
    self:updateAcTime()
end

function acHeroGiftTab1:updateAcTime()
    local acVo=acHeroGiftVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb,self.rewardLb)
    end
end


function acHeroGiftTab1:dispose( )

	self.bgLayer=nil
	self.layerNum=nil

	self.recuitOne=nil
	self.recuitTen=nil
end