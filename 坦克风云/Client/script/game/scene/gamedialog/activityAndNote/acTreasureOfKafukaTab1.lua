acTreasureOfKafukaTab1 ={}

function acTreasureOfKafukaTab1:new( )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=nil
	self.selectedTabIndex=nil
	self.acTreasureDialog=nil

    self.bgLayer=nil
    self.onceBtn=nil
    self.tenBtn=nil
    self.backBg=nil
    self.flicker=nil
    self.spSize=100
    self.spTab={}
    self.descLb=nil
    self.animationBg=nil

    self.spTb={}
    self.itemPosition={}

    self.aid=nil
    self.ascNum=nil
    self.secIndex=nil
    self.iconList=0
    self.itemList={}
    self.rewardList={}

    -- self.second=nil
    self.movePos=15
    self.tipAward={}

    self.oneEnough=nil
    self.tenEnough=nil
    self.oneSelectedLb=nil
    self.tenSelectedLb=nil

    self.costLb1=nil
	self.gemIcon1=nil
	self.needLb1=nil
	self.costLb3=nil
	self.gemIcon3=nil
	self.line=nil
	self.costLb2=nil
	self.gemIcon2 =nil
	self.needLb2=nil
    return nc
end

function acTreasureOfKafukaTab1:init(layerNum,selectedTabIndex,acTreasureDialog )
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acTreasureOfKafuka.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self.layerNum=layerNum
	self.selectedTabIndex=selectedTabIndex
	self.acTreasureDialog=acTreasureDialog
	self.bgLayer= CCLayer:create()
	self:initDesc()

	  local function touchDialog()
	      if self.state == 2 then
	        PlayEffect(audioCfg.mouseClick)
	        self.state = 3
	        -- 暂停动画
	        -- self:close()
	      end
	  end
	  self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	  self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
	  local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	  self.touchDialogBg:setContentSize(rect)
	  self.touchDialogBg:setOpacity(0)
	  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
	  self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
	  self.bgLayer:addChild(self.touchDialogBg,1)
	return self.bgLayer
end

function acTreasureOfKafukaTab1:initDesc( )

	local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
	local oneCost=cfg.oneCost--1次，和探索的金币数
	local tenCost=cfg.tenCost--10次，和探索的金币数
	local w = G_VisibleSizeWidth - 50 -- 背景框的宽度

	local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
	headBs:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,170))
	headBs:setAnchorPoint(ccp(0.5,1))
	headBs:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height - 155))
	self.bgLayer:addChild(headBs,4)

	local function nilFunc( )
		
	end 
	local icon = LuaCCSprite:createWithSpriteFrameName("mainBtnAccessory.png",nilFunc)
	icon:setTouchPriority(-(self.layerNum-1)*20-5)
	icon:setAnchorPoint(ccp(0,0.5))
	icon:setPosition(10,80)
	icon:setScale(1.7)
	headBs:addChild(icon)

   local timeSize = 24
   local reTimeSize = 22
   local timeShowWidth = 0
   local rewardHeightloc =0
   if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" then
        timeSize =23
        timeShowWidth =30
    elseif G_getCurChoseLanguage()=="ru" then
        timeSize =21
        timeShowWidth =30
        rewardHeightloc =-15
    elseif G_getCurChoseLanguage() =="ja"  then
        timeSize =19
        reTimeSize =21
        timeShowWidth =30
   end

	local actTime=GetTTFLabel(getlocal("activity_timeLabel"),timeSize)
	actTime:setPosition(ccp(headBs:getContentSize().width*0.3-50,headBs:getContentSize().height-25))
	headBs:addChild(actTime,5)
	actTime:setAnchorPoint(ccp(0,0.5))
	actTime:setColor(G_ColorGreen)

    self.rewardTimeStr = GetTTFLabel(getlocal("recRewardTime"),timeSize)
    self.rewardTimeStr:setAnchorPoint(ccp(0,0.5))
    self.rewardTimeStr:setColor(G_ColorYellowPro)
    self.rewardTimeStr:setPosition(ccp(headBs:getContentSize().width*0.3-50,headBs:getContentSize().height-60))
    headBs:addChild(self.rewardTimeStr,5)

	local acVo = acEquipSearchIIVoApi:getAcVo()
	if acVo then
		local timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
		local timeLabel = GetTTFLabel(timeStr,reTimeSize)
		timeLabel:setAnchorPoint(ccp(0,0.5))
		timeLabel:setPosition(ccp(headBs:getContentSize().width*0.4+timeShowWidth,headBs:getContentSize().height-25))
		headBs:addChild(timeLabel,5)

        local timeStr2=activityVoApi:getActivityRewardTimeStr(acVo.acEt,60,86400)
        self.timeLabel2=GetTTFLabel(timeStr2,reTimeSize)
        self.timeLabel2:setAnchorPoint(ccp(0,0.5))
        self.timeLabel2:setPosition(ccp(headBs:getContentSize().width*0.4+timeShowWidth,headBs:getContentSize().height-60))
        headBs:addChild(self.timeLabel2)
	end

	local activeLabel = getlocal("activity_equipSearchII_label")
	local desTv, desLabel = G_LabelTableView(CCSizeMake(w-200, 80),activeLabel,25,kCCTextAlignmentLeft)
	headBs:addChild(desTv)
	desTv:setPosition(ccp(headBs:getContentSize().width*0.3-45,10))
	desTv:setAnchorPoint(ccp(0,0))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(100)

	local function touch(tag,object)
	    local strTab={" ",getlocal("activity_equipSearch_search_tip_6"),getlocal("activity_equipSearch_search_tip_5"),getlocal("activity_equipSearch_search_tip_4"),getlocal("activity_equipSearch_search_tip_3"),getlocal("activity_equipSearch_search_tip_2"),getlocal("activity_equipSearch_search_tip_1")," "}
        local colorTab={nil,G_ColorYellow,G_ColorYellow,G_ColorWhite,G_ColorWhite,G_ColorYellow,G_ColorWhite,nil}
        local sd=smallDialog:new()
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab)
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))

  	end

	w = w - 10 -- 按钮的x坐标
	local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,1))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(w-10, headBs:getContentSize().height-12))
	headBs:addChild(menuDesc)


	self.middleBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	self.middleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,150))
	self.middleBg:setAnchorPoint(ccp(0.5,1))
	self.middleBg:setPosition(ccp(G_VisibleSizeWidth/2,headBs:getPositionY()-headBs:getContentSize().height-5))
	self.bgLayer:addChild(self.middleBg)

	local titleLb = GetTTFLabelWrap(getlocal("activity_feixutansuo_rewardTitle"),25,CCSizeMake(self.middleBg:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	titleLb:setAnchorPoint(ccp(0,1))
	titleLb:setPosition(10,self.middleBg:getContentSize().height-10)
	self.middleBg:addChild(titleLb)

	self.noTansuoLb = GetTTFLabelWrap(getlocal("activity_feixutansuo_noReward"),25,CCSizeMake(self.middleBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.noTansuoLb:setAnchorPoint(ccp(0.5,0.5))
	self.noTansuoLb:setPosition(self.middleBg:getContentSize().width/2,self.middleBg:getContentSize().height/2)
	self.middleBg:addChild(self.noTansuoLb)

	--self:updateShowTv()

	--self.machineBg 当中间动画外框 背景坐标用
	self.machineBg=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),function () do return end end)
	self.machineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-700))
	self.machineBg:setAnchorPoint(ccp(0.5,1))
	self.machineBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5+2,self.middleBg:getPositionY()-self.middleBg:getContentSize().height-5))
	self.bgLayer:addChild(self.machineBg,7)
	self.machineBg:setVisible(false)

	local animationUpBorder = CCSprite:createWithSpriteFrameName("expedition_up.png")
	animationUpBorder:setScaleX(self.machineBg:getContentSize().width/animationUpBorder:getContentSize().width)
	animationUpBorder:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,20))
	animationUpBorder:setAnchorPoint(ccp(0.5,1))
	animationUpBorder:setPosition(ccp(self.bgLayer:getContentSize().width*0.5-18,self.middleBg:getPositionY()-self.middleBg:getContentSize().height-30))
	self.bgLayer:addChild(animationUpBorder,10)

	local animationDownBorder = CCSprite:createWithSpriteFrameName("expedition_down.png")
	animationDownBorder:setScaleX(self.machineBg:getContentSize().width/animationDownBorder:getContentSize().width)
	animationDownBorder:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,20))
	animationDownBorder:setAnchorPoint(ccp(0.5,1))
	animationDownBorder:setPosition(ccp(self.bgLayer:getContentSize().width*0.5-18,self.machineBg:getPositionY()-self.machineBg:getContentSize().height+5))
	self.bgLayer:addChild(animationDownBorder,10)

	self.animationBg = CCSprite:create("scene/cityR2_mi.jpg")
	self.animationBg:setScaleX((self.machineBg:getContentSize().width-10)/self.animationBg:getContentSize().width)
	self.animationBg:setScaleY(self.machineBg:getContentSize().height/self.animationBg:getContentSize().height)
	self.animationBg:setAnchorPoint(ccp(0.5,1))
	self.animationBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.middleBg:getPositionY()-self.middleBg:getContentSize().height-10))
	self.bgLayer:addChild(self.animationBg,6)

	local firstBorder = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
	firstBorder:setScaleX((self.machineBg:getContentSize().width-10)/firstBorder:getContentSize().width)
	firstBorder:setScaleY(self.machineBg:getContentSize().height/firstBorder:getContentSize().height)
	firstBorder:setAnchorPoint(ccp(0.5,1))
	firstBorder:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.middleBg:getPositionY()-self.middleBg:getContentSize().height-10))
	self.bgLayer:addChild(firstBorder,7)	

	local plat = CCSprite:createWithSpriteFrameName("expedition_bg1.png")
	plat:setScaleX(self.animationBg:getContentSize().width*0.23/plat:getContentSize().width)
	plat:setScaleY(self.animationBg:getContentSize().height*0.08/plat:getContentSize().height)
	plat:setAnchorPoint(ccp(0.5,0))
	local platHpos = 260
	local iconHpos = 600
	local borderSca = 0.28
	if G_isIphone5() then
		platHpos =440
		iconHpos =675
		borderSca = 0.4
	end
	plat:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,firstBorder:getPositionY()-platHpos))
	self.bgLayer:addChild(plat,8)
---
     local itemPosY = self.bgLayer:getContentSize().height-iconHpos
	self:getItemList() --拿到所有抽奖信息
	self.items={20,5,9,12,3}
      for k,v in pairs(self.items) do
        local iconSp = CCSprite:createWithSpriteFrameName("Icon_BG.png")
        iconSp:setAnchorPoint(ccp(0.5,0.5))
        if k==1 then
          iconSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,itemPosY))
        elseif k==2 then
          iconSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.1-20,itemPosY))
        elseif k==3 then
          iconSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.9+20,itemPosY))
        elseif k==4 then
          iconSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.3-20,itemPosY))
        elseif k==5 then
          iconSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.7+20,itemPosY))
        end
        iconSp:setScale(1.1-math.abs(self.bgLayer:getContentSize().width/2-iconSp:getPositionX())/(self.bgLayer:getContentSize().width/2))

        local icon= self:getItemIcon(v)--self.iconList[v]
        icon:setTag(1010)
        icon:setPosition(getCenterPoint(iconSp))
        icon:setAnchorPoint(ccp(0.5,0.5))
        iconSp:addChild(icon)
        self.bgLayer:addChild(iconSp,8)
        self.spTb[k]={}
        self.spTb[k].sp=iconSp
        self.spTb[k].id=v
        self.itemPosition[k]=iconSp:getPosition()
      end
 	
 	self.roundLight=CCSprite:createWithSpriteFrameName("roundLight.png")
 	self.roundLight:setAnchorPoint(ccp(0.5,0))
 	self.roundLight:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,plat:getPositionY()+20))
 	self.roundLight:setScaleY(self.animationBg:getContentSize().height*0.4/self.roundLight:getContentSize().height)
 	self.roundLight:setScaleX(self.bgLayer:getContentSize().width*0.28/self.roundLight:getContentSize().width)
 	self.bgLayer:addChild(self.roundLight,9)
 	self.roundLight:setVisible(true)

	local leftMask = CCSprite:createWithSpriteFrameName("SlotMask.png")
	leftMask:setScaleX(self.bgLayer:getContentSize().height*borderSca/leftMask:getContentSize().width)
	leftMask:setScaleY(self.bgLayer:getContentSize().width*0.28/leftMask:getContentSize().height)
	leftMask:setRotation(270)
	leftMask:setAnchorPoint(ccp(0,1))
	leftMask:setPosition(ccp(20,plat:getPositionY()))
	--leftMask:setOpacity()
	self.bgLayer:addChild(leftMask,9)

	local rightMask = CCSprite:createWithSpriteFrameName("SlotMask.png")
	rightMask:setScaleX(self.bgLayer:getContentSize().height*borderSca/rightMask:getContentSize().width)
	rightMask:setScaleY(self.bgLayer:getContentSize().width*0.28/rightMask:getContentSize().height)
	rightMask:setRotation(90)
	rightMask:setAnchorPoint(ccp(1,1))
	rightMask:setPosition(self.bgLayer:getContentSize().width-20,plat:getPositionY())
	self.bgLayer:addChild(rightMask,9)

	local tenSelectedBg = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () do return end end)
	tenSelectedBg:setContentSize(CCSizeMake(self.animationBg:getContentSize().width*0.4-50,80))
	tenSelectedBg:setAnchorPoint(ccp(0,0))
	tenSelectedBg:setPosition(ccp(25,30))
	self.bgLayer:addChild(tenSelectedBg)
	local oneSelectedBg = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () do return end end)
	oneSelectedBg:setContentSize(CCSizeMake(self.animationBg:getContentSize().width*0.4-50,80))
	oneSelectedBg:setAnchorPoint(ccp(0,0))
	oneSelectedBg:setPosition(ccp(25,35+tenSelectedBg:getContentSize().height))
	self.bgLayer:addChild(oneSelectedBg)

	local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
	local oneCost1=cfg.oneCost[2]
	local tenCost1=cfg.tenCost[2][2]
	self.oneEnough=oneCost1-playerVoApi:getGems()
	self.tenEnough=tenCost1-playerVoApi:getGems()

    self.tenSelectedLb=GetTTFLabelWrap(getlocal("activity_equipSearch_search_times",{tenCost[1]}),25,CCSizeMake(tenSelectedBg:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.tenSelectedLb:setAnchorPoint(ccp(0.5,0.5))
    self.tenSelectedLb:setPosition(ccp(tenSelectedBg:getContentSize().width/2,tenSelectedBg:getContentSize().height-24))
    tenSelectedBg:addChild(self.tenSelectedLb,2)
    if self.tenEnough> 0 then
    	self.tenSelectedLb:setColor(G_ColorRed)
    end
    self.oneSelectedLb=GetTTFLabelWrap(getlocal("activity_equipSearch_search_times",{oneCost[1]}),25,CCSizeMake(oneSelectedBg:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.oneSelectedLb:setAnchorPoint(ccp(0.5,0.5))
    self.oneSelectedLb:setPosition(ccp(oneSelectedBg:getContentSize().width/2,oneSelectedBg:getContentSize().height-24))
    oneSelectedBg:addChild(self.oneSelectedLb,2)    
    if self.oneEnough> 0 then
    	self.oneSelectedLb:setColor(G_ColorRed)
    end

    local  iconSize = 30
    if G_getCurChoseLanguage() =="en" then
    	iconSize =60
    end
    self.needLb2=GetTTFLabel(getlocal("activity_equipSearch_need"),22)
    self.needLb2:setAnchorPoint(ccp(0.5,0.5))
    self.needLb2:setPosition(ccp(tenSelectedBg:getContentSize().width/2-iconSize-30,tenSelectedBg:getContentSize().height-55))
    tenSelectedBg:addChild(self.needLb2,2)
    self.needLb2:setColor(G_ColorYellowPro)

    self.gemIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.gemIcon2:setAnchorPoint(ccp(0.5,0.5))
    local scale=iconSize/self.gemIcon2:getContentSize().width
    self.gemIcon2:setScale(scale)
    self.gemIcon2:setPosition(ccp(self.needLb2:getPositionX()+iconSize+10,tenSelectedBg:getContentSize().height-55))
    tenSelectedBg:addChild(self.gemIcon2,2)

    self.costLb2=GetTTFLabel(tenCost[2][1],22)
    self.costLb2:setAnchorPoint(ccp(0,0.5))
    self.costLb2:setPosition(ccp(self.gemIcon2:getPositionX()+10,tenSelectedBg:getContentSize().height-55))
    tenSelectedBg:addChild(self.costLb2,2)
    self.costLb2:setColor(G_ColorYellowPro)

    local costLb2x,costLb2y=self.costLb2:getPosition()
    self.line = CCSprite:createWithSpriteFrameName("redline.jpg")
    self.line:setScaleX((self.costLb2:getContentSize().width+iconSize+10)/self.line:getContentSize().width)
    self.line:setAnchorPoint(ccp(0,0.5))
    self.line:setPosition(ccp(costLb2x-iconSize,tenSelectedBg:getContentSize().height-55))
    tenSelectedBg:addChild(self.line,5)

    self.gemIcon3 = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.gemIcon3:setAnchorPoint(ccp(0.5,0.5))
    local scale=iconSize/self.gemIcon2:getContentSize().width
    self.gemIcon3:setScale(scale)
    self.gemIcon3:setPosition(ccp(self.costLb2:getPositionX()+iconSize+30,tenSelectedBg:getContentSize().height-55))
    tenSelectedBg:addChild(self.gemIcon3,2)

    self.costLb3 = GetTTFLabel(tenCost[2][2],22)
    self.costLb3:setAnchorPoint(ccp(0,0.5))
    self.costLb3:setPosition(ccp(self.gemIcon3:getPositionX()+10,tenSelectedBg:getContentSize().height-55))
    tenSelectedBg:addChild(self.costLb3,2)
    self.costLb3:setColor(G_ColorYellowPro)

    self.needLb1=GetTTFLabel(getlocal("activity_equipSearch_need"),22)
    self.needLb1:setAnchorPoint(ccp(0.5,0.5))
    self.needLb1:setPosition(ccp(oneSelectedBg:getContentSize().width/2-iconSize-10,oneSelectedBg:getContentSize().height-55))
    oneSelectedBg:addChild(self.needLb1,2)
    self.needLb1:setColor(G_ColorYellowPro)

    self.gemIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.gemIcon1:setAnchorPoint(ccp(0.5,0.5))
    local scale=iconSize/self.gemIcon1:getContentSize().width
    self.gemIcon1:setScale(scale)
    self.gemIcon1:setPosition(ccp(oneSelectedBg:getContentSize().width/2,oneSelectedBg:getContentSize().height-55))
    oneSelectedBg:addChild(self.gemIcon1,2)

    self.costLb1=GetTTFLabel(oneCost[2],22)
    self.costLb1:setAnchorPoint(ccp(0,0.5))
    self.costLb1:setPosition(ccp(oneSelectedBg:getContentSize().width/2+iconSize/2,oneSelectedBg:getContentSize().height-55))
    oneSelectedBg:addChild(self.costLb1,2)
    self.costLb1:setColor(G_ColorYellowPro)

    if G_isIphone5() then
    	self.gemIcon1:setScale(0.9)
    	self.gemIcon2:setScale(0.9)
    	self.gemIcon3:setScale(0.9)
    	self.line:setPosition(ccp(costLb2x-iconSize+20,tenSelectedBg:getContentSize().height-55))
    end

    local function rcordList(fn,data)
    	local ret,sData=base:checkServerData(data)
    	if ret==true then
    		if sData.data and sData.data.equipSearchII and sData.data.equipSearchII.recordlist then
    			for k,v in pairs(sData.data.equipSearchII.recordlist) do
    					table.insert(self.rewardList,{ptype=v[1],pID=v[2],num=v[3]})
    			end
    			local changeList = self.rewardList
    			local inddx = #changeList
    			for k,v in pairs(changeList) do
    				self.rewardList[inddx]=v
    				inddx=inddx-1
    			end
    		end
    	end
    	self:updateShowTv()
    end 
    socketHelper:activeTreasureOfKafukaRecord(rcordList)
	self:updateShowTv()

---------
    local function searchHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if acEquipSearchIIVoApi:checkCanSearch()==false then
            do return end
        end

        local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()

        local function searchCallback(fn,data)
            local isCost=acEquipSearchIIVoApi:isSearchToday()
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
                local oneCost1=cfg.oneCost[2]
                local tenCost1=cfg.tenCost[2][2]
                if tag==1 then
                    if isCost==true then
                        playerVoApi:setValue("gems",playerVoApi:getGems()-oneCost1)
                    end
                else
                    playerVoApi:setValue("gems",playerVoApi:getGems()-tenCost1)
                end

                if sData.data.useractive and sData.data.useractive.equipSearchII then
                    local equipSearch=sData.data.useractive.equipSearchII
                    acEquipSearchIIVoApi:updateData(equipSearch)
                end
                if sData.data.equipSearchII and sData.data.equipSearchII.report and self and self.bgLayer then
                    local content={}
                    local report=sData.data.equipSearchII.report or {}
                    for k,v in pairs(report) do
                        local awardTb=FormatItem(v[1]) or {}
                        for m,n in pairs(awardTb) do
                            local award=n or {}
                    self.aid = award.key-- 配件aid
                    self.ascNum= award.num--配件数量
                    if award.key =="f0" then 
                    	self.aid ="p230"
                    end
                    table.insert(self.rewardList,{ptype=award.type,pID=award.key,num=self.ascNum})
                    self.tipAward={name=award.name,num=award.num,type=award.ptype,key=award.key,pic=award.pic,desc=award.desc}
                            self.secIndex=acEquipSearchIIVoApi:getIndexByNameAndNum(self.aid,award.num)
                            table.insert(content,{award=award,point=v[2],index=self.secIndex})
                            G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                        end
                    end
                    if tag==1 then
                        tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
                        self:startPalyAnimation()--飘板在动画后面
                    end
                    if tag ==2 then
	                    if content and SizeOfTable(content)>0 then
	                        local function confirmHandler(awardIdx)
	                        	self:updateShowTv()
	                        end
	                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_equipSearch_total"),content,nil,true,self.layerNum+1,confirmHandler,true,true)
	                    end
	                end
                end

                -- if self.acTreasureDialog then
                --     self.acTreasureDialog:refresh()
                -- end
            end
        end
        local once=cfg.oneCost[1]
        local ten=cfg.tenCost[1]
        local oneCost=cfg.oneCost[2]
        local tenCost=cfg.tenCost[2][2]

        local function closeCallback( ... )
            if G_checkClickEnable()==false then
                do
                    return
                end
            end
            activityAndNoteDialog:closeAllDialog()
        end
        if tag==1 then
            local diffGems=oneCost-playerVoApi:getGems()
            if acEquipSearchIIVoApi:isSearchToday()==false then
            
            elseif diffGems>0 then
                GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost,closeCallback)
                do return end
            end
            socketHelper:activeEquipsearchII(1,searchCallback,once)
        elseif tag==2 then
            local diffGems2=tenCost-playerVoApi:getGems()
            if diffGems2>0 then
                GemsNotEnoughDialog(nil,nil,diffGems2,self.layerNum+1,tenCost,closeCallback)
                do return end
            end
            socketHelper:activeEquipsearchII(1,searchCallback,ten)
        end     
    end
    local textSize = 25
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
        textSize=20
    end
    self.onceBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",searchHandler,1,getlocal("activity_equipSearch_once_btn"),textSize,21)
    self.onceBtn:setAnchorPoint(ccp(0.5,0.5))
    local onceMune=CCMenu:createWithItem(self.onceBtn)
    onceMune:setAnchorPoint(ccp(0.5,0.5))
    onceMune:setPosition(ccp(self.bgLayer:getContentSize().width-self.onceBtn:getContentSize().width/2-50,158))
    onceMune:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(onceMune)


    self.tenBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",searchHandler,2,getlocal("activity_equipSearch_ten_btn"),textSize,22)
    self.tenBtn:setAnchorPoint(ccp(0.5,0.5))
    local tenMune=CCMenu:createWithItem(self.tenBtn)
    tenMune:setAnchorPoint(ccp(0.5,0.5))
    tenMune:setPosition(ccp(self.bgLayer:getContentSize().width-self.tenBtn:getContentSize().width/2-50,70))
    tenMune:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tenMune)

    if acEquipSearchIIVoApi:checkCanSearch()==false then
        self.onceBtn:setEnabled(false)
        self.tenBtn:setEnabled(false)
    else
        self.onceBtn:setEnabled(true)

        if acEquipSearchIIVoApi:isSearchToday()==false then
            tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
            self.tenBtn:setEnabled(false)
        else 
            tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
            self.tenBtn:setEnabled(true)
        end
    end
    if acEquipSearchIIVoApi:isSearchToday()==false then
        tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
        self.tenBtn:setEnabled(false)
        self.oneSelectedLb:setVisible(false)
        self.tenSelectedLb:setVisible(false)
        self.costLb1:setVisible(false)
		self.gemIcon1:setVisible(false)
		self.needLb1:setVisible(false)
		self.costLb3:setVisible(false)
		self.gemIcon3:setVisible(false)
		self.line:setVisible(false)
		self.costLb2:setVisible(false)
		self.gemIcon2:setVisible(false)
		self.needLb2:setVisible(false)
    else
        tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
        if acEquipSearchIIVoApi:checkCanSearch()==false then
        	self.tenBtn:setEnabled(false)
    	else
    		self.tenBtn:setEnabled(true)
    	end
    	self.oneSelectedLb:setVisible(true)
        self.tenSelectedLb:setVisible(true)
        self.costLb1:setVisible(true)
		self.gemIcon1:setVisible(true)
		self.needLb1:setVisible(true)
		self.costLb3:setVisible(true)
		self.gemIcon3:setVisible(true)
		self.line:setVisible(true)
		self.costLb2:setVisible(true)
		self.gemIcon2:setVisible(true)
		self.needLb2:setVisible(true)
    end

end

function acTreasureOfKafukaTab1:getItemList()
    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    local awardPool=cfg.pool or {}
    for k,v in pairs(awardPool) do
        if v.aid then
        		self.iconList=self.iconList+1
                self.itemList[k]=v
        end
    end
end

function acTreasureOfKafukaTab1:getItemIcon(id)
    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    local awardPool=cfg.pool or {}
  if awardPool then
    for k,v in pairs(awardPool) do
        local function touch()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local content=acEquipSearchIIVoApi:formatContent(k)
            if content and SizeOfTable(content)>0 then
                smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_equipSearch_reward_include"),content,true,true,self.layerNum+1,nil,nil,nil,true)
            end
        end

        if v.aid then
        	if k ==id then
	            local icon
	            local aid=v.aid
	            local eType=string.sub(aid,1,1)
	            if eType=="a" then
	                icon=accessoryVoApi:getAccessoryIcon(aid,80,100,touch)
	            elseif eType=="f" then
	                icon=accessoryVoApi:getFragmentIcon(aid,80,100,touch)
	            elseif eType=="p" then
	                local pic=accessoryCfg.propCfg[aid].icon
	                icon=LuaCCSprite:createWithSpriteFrameName(pic,touch)
	            end
	            if icon then
	                icon:setAnchorPoint(ccp(0.5,0.5))
	                icon:setTouchPriority(-(self.layerNum-1)*20-4)
	                icon:setScaleX(1.5)
	                icon:setScaleY(1.5)
	                return icon
	            end
	        end
        end
    end
  end
end

function acTreasureOfKafukaTab1:startPalyAnimation()
  self.roundLight:setVisible(false)
  --self.speed=5 
  self.moveDis=0
  self.isStop=false
  self.state = 2
  self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
  --base:addNeedRefresh(self)
  self.acTreasureDialog:refresh()
  print("得到抽取结果~")
end

function acTreasureOfKafukaTab1:stopPlayAnimation()
  self.roundLight:setVisible(true)
  local str=G_showRewardTip({self.tipAward},false)
  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
  print("正常~")
  self.state = 0
  self:result()
  self.touchDialogBg:setIsSallow(false) -- 点击事件透下去

end

function acTreasureOfKafukaTab1:moveSp()
  self.moveDis=self.moveDis+1
  -- local second = self.second
  for k,v in pairs(self.spTb) do

      local newPosotionX = v.sp:getPositionX()
      if (newPosotionX<self.bgLayer:getContentSize().width/2) and (newPosotionX+self.movePos)>self.bgLayer:getContentSize().width/2 then
        newPosotionX = self.bgLayer:getContentSize().width/2
      else
        newPosotionX = newPosotionX+10--self.movePos

      end


        v.sp:setPosition(ccp(newPosotionX,v.sp:getPositionY()))

        v.sp:setScale(1.1-math.abs(self.bgLayer:getContentSize().width/2-v.sp:getPositionX())/(self.bgLayer:getContentSize().width/2))

        if v.sp:getPositionX()<=40 then
        	v.sp:setVisible(false)
        elseif v.sp:getPositionX()>=(self.bgLayer:getContentSize().width-(v.sp:getContentSize().width+20)) then
        	v.sp:setVisible(false)
        	--v.sp:setEnabled(false)
        else
        	v.sp:setVisible(true)
        end        

        if v.sp:getPositionX()>=(self.bgLayer:getContentSize().width+88) then 
          local icon = v.sp:getChildByTag(1010)
          if icon then
            icon:removeFromParentAndCleanup(true)
          end
          local randomID =nil
          if self.moveDis>100 then
          --if self.second >5 then
          	randomID=self.secIndex
          else
            randomID = math.random(1,self.iconList)
          end
          local newIcon = self:getItemIcon(randomID)
          newIcon:setAnchorPoint(ccp(0.5,0.5))
          newIcon:setPosition(getCenterPoint(v.sp))
          newIcon:setTag(1010)
          v.sp:addChild(newIcon)
          v.sp:setPosition(ccp(28,v.sp:getPositionY()))
          v.id=randomID
          v.sp:setVisible(false)
        end
        local randomIDr = v.id
        --if self.second >5 and v.sp:getPositionX()==self.bgLayer:getContentSize().width/2 and randomIDr==self.secIndex and self.isStop== false then
        if self.moveDis >100 and v.sp:getPositionX()==self.bgLayer:getContentSize().width/2 and randomIDr==self.secIndex and self.isStop== false then
          self.isStop=true
          self.roundLight:setVisible(true)
        end
  end

  

  if self.isStop==true  then
    self.state = 3
    print("动画播放结束： ", self.state)
  end
end

function acTreasureOfKafukaTab1:getRandomID()
  
  if self.iconList and type(self.iconList)=="table" then
    local randomID = math.random(1,SizeOfTable(self.iconList))
    local hasAdd = false
    for k,v in pairs(self.items) do
      if v and v == randomID then
        hasAdd = true
      end
    end
    if hasAdd == false then
      table.insert(self.items,randomID)
      return self.iconList[randomID]
    else
      self:getOneIcon()
    end
  end
end

function acTreasureOfKafukaTab1:fastTick()
  if self.state == 2 then
    self:moveSp()
  elseif self.state == 3 then
    self:stopPlayAnimation()
    self:updateShowTv()

  end
end
function acTreasureOfKafukaTab1:tick( )

        local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
		local oneCost1=cfg.oneCost[2]
		local tenCost1=cfg.tenCost[2][2]
		self.oneEnough=oneCost1-playerVoApi:getGems()
		self.tenEnough=tenCost1-playerVoApi:getGems()
		if self.oneEnough>0 then
			self.oneSelectedLb:setColor(G_ColorRed)
		else
			self.oneSelectedLb:setColor(G_ColorWhite)
		end
		if self.tenEnough>0 then
			self.tenSelectedLb:setColor(G_ColorRed)
		else
			self.oneSelectedLb:setColor(G_ColorWhite)
			self.tenSelectedLb:setColor(G_ColorWhite)
		end
    if acEquipSearchIIVoApi:isSearchToday()==false then
        tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
        self.tenBtn:setEnabled(false)
        self.oneSelectedLb:setVisible(false)
        self.tenSelectedLb:setVisible(false)
        self.costLb1:setVisible(false)
		self.gemIcon1:setVisible(false)
		self.needLb1:setVisible(false)
		self.costLb3:setVisible(false)
		self.gemIcon3:setVisible(false)
		self.line:setVisible(false)
		self.costLb2:setVisible(false)
		self.gemIcon2:setVisible(false)
		self.needLb2:setVisible(false)
    else
        tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
        if acEquipSearchIIVoApi:checkCanSearch()==false then
        	self.tenBtn:setEnabled(false)
    	else
    		self.tenBtn:setEnabled(true)
    	end
    	self.oneSelectedLb:setVisible(true)
        self.tenSelectedLb:setVisible(true)
        self.costLb1:setVisible(true)
		self.gemIcon1:setVisible(true)
		self.needLb1:setVisible(true)
		self.costLb3:setVisible(true)
		self.gemIcon3:setVisible(true)
		self.line:setVisible(true)
		self.costLb2:setVisible(true)
		self.gemIcon2:setVisible(true)
		self.needLb2:setVisible(true)
    end

end
function acTreasureOfKafukaTab1:result()
 
    local index
    for k,v in pairs(self.itemList) do
      if v then
        if k==self.secIndex then
          index = k
        end
      end
    end
 if self.isStop == false then
      for k,v in pairs(self.spTb) do
          local icon = v.sp:getChildByTag(1010)
          if icon then
            icon:removeFromParentAndCleanup(true)
          end
          local newIcon
          if k == 1 then
            newIcon= self:getItemIcon(index)
            newIcon:setAnchorPoint(ccp(0.5,0.5))
            newIcon:setPosition(getCenterPoint(v.sp))
            newIcon:setTag(1010)
            v.sp:addChild(newIcon)
            v.sp:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,v.sp:getPositionY()))
            v.sp:setVisible(true)
            v.id=index
          elseif k==2 then
            if index==1 then
              newIcon= self:getItemIcon(self.iconList)
              v.id=self.iconList
            else
              newIcon= self:getItemIcon(index-1)
              v.id=index-1
            end
            newIcon:setAnchorPoint(ccp(0.5,0.5))
            newIcon:setPosition(getCenterPoint(v.sp))
            newIcon:setTag(1010)
            v.sp:addChild(newIcon)
            v.sp:setPosition(ccp(self.bgLayer:getContentSize().width*0.3-20,v.sp:getPositionY()))
            v.sp:setVisible(true)            
          elseif k==3 then
            if index==self.iconList then
              newIcon= self:getItemIcon(1)
              v.id=1
            else
              newIcon= self:getItemIcon(index+1)
              v.id=index+1
            end
            newIcon:setAnchorPoint(ccp(0.5,0.5))
            newIcon:setPosition(getCenterPoint(v.sp))
            newIcon:setTag(1010)
            v.sp:addChild(newIcon)
            v.sp:setPosition(ccp(self.bgLayer:getContentSize().width*0.7+20,v.sp:getPositionY()))
            v.sp:setVisible(true)
           elseif k==4 then
           	if index ==1 then
           		newIcon = self:getItemIcon(self.iconList-1)
           		v.id = self.iconList
           	elseif index ==2 then
           		newIcon= self:getItemIcon(self.iconList)
           		v.id =self.iconList
           	else
           		newIcon = self:getItemIcon(index-2)
           		v.id=index-2
           	end
            newIcon:setAnchorPoint(ccp(0.5,0.5))
            newIcon:setPosition(getCenterPoint(v.sp))
            newIcon:setTag(1010)
            v.sp:addChild(newIcon)
            v.sp:setPosition(ccp(self.bgLayer:getContentSize().width*0.1-20,v.sp:getPositionY()))
             v.sp:setVisible(true)
           elseif k==5 then
           	if index==self.iconList then
           		newIcon = self:getItemIcon(2)
           		v.id= 2
           	elseif index == self.iconList-1 then
           		newIcon = self:getItemIcon(1)
           		v.id= 1 
           	else
           		newIcon = self:getItemIcon(index+2)
           		v.id = index+2
           	end
            newIcon:setAnchorPoint(ccp(0.5,0.5))
            newIcon:setPosition(getCenterPoint(v.sp))
            newIcon:setTag(1010)
            v.sp:addChild(newIcon)
            v.sp:setPosition(ccp(self.bgLayer:getContentSize().width*0.9+20,v.sp:getPositionY()))   
            v.sp:setVisible(true)        	
          end

          v.sp:setScale(1.1-math.abs(self.bgLayer:getContentSize().width/2-v.sp:getPositionX())/(self.bgLayer:getContentSize().width/2))
      end
  end
  
end

function acTreasureOfKafukaTab1:refresh()
    if self and self.bgLayer then
        if acEquipSearchIIVoApi:checkCanSearch()==false then
            self.onceBtn:setEnabled(false)
            self.tenBtn:setEnabled(false)
        else
            self.onceBtn:setEnabled(true)
            

            if acEquipSearchIIVoApi:isSearchToday()==false then
                tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
                self.tenBtn:setEnabled(false)
            else
                tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
                self.tenBtn:setEnabled(true)
            end
        end

        if self.descLb then
            if acEquipSearchIIVoApi:acIsStop()==true then
                self.descLb:setString(getlocal("activity_equipSearch_time_end"))
            else
                local timeStr=acEquipSearchIIVoApi:getTimeStr()
                self.descLb:setString(timeStr)
            end
        end
        local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
		local oneCost1=cfg.oneCost[2]
		local tenCost1=cfg.tenCost[2][2]
		self.oneEnough=oneCost1-playerVoApi:getGems()
		self.tenEnough=tenCost1-playerVoApi:getGems()
		if self.oneEnough>0 then
			self.oneSelectedLb:setColor(G_ColorRed)
		else
			self.oneSelectedLb:setColor(G_ColorWhite)
		end
		if self.tenEnough>0 then
			self.tenSelectedLb:setColor(G_ColorRed)
		else
			self.tenSelectedLb:setColor(G_ColorWhite)
		end
    end
    
end

function acTreasureOfKafukaTab1:updateShowTv()

	if SizeOfTable(self.rewardList)<=0 then
		self.noTansuoLb:setVisible(true)
	else
		self.noTansuoLb:setVisible(false)

		if self.tv1~=nil then
			self.tv1:reloadData()
		else

			local function callBack(...)

				return self:eventHandler1(...)
			end
			local hd= LuaEventHandler:createHandler(callBack)
		 	self.tv1=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(self.middleBg:getContentSize().width-20,self.middleBg:getContentSize().height-50),nil)
			self.tv1:setAnchorPoint(ccp(0,0))
			self.tv1:setPosition(ccp(10,10))
			self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
			self.tv1:setMaxDisToBottomOrTop(100)
			self.middleBg:addChild(self.tv1,1)
		end
	end
end

function acTreasureOfKafukaTab1:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if SizeOfTable(self.rewardList) >=10 then
			return 10
		else
			return SizeOfTable(self.rewardList)
		end
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(105,105)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local index = SizeOfTable(self.rewardList)-idx
	    local rewardCfg = self.rewardList[index]
	    local ptype = rewardCfg["ptype"]
	    local pID = rewardCfg["pID"]
	    local num = rewardCfg["num"]
	    local award = {}
	    local name,pic,desc,id,index,eType,equipId=getItem(pID,ptype)
	    award={name=name,num=num,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pID,eType=eType,equipId=equipId}
	    if award then
           local icon,iconScale = G_getItemIcon(award,100,true,self.layerNum,nil,self.tv1)
            icon:setTouchPriority(-(self.layerNum-1)*20-5)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(10,50)
            cell:addChild(icon)

            local num = GetTTFLabel("x"..award.num,25/iconScale)
            num:setAnchorPoint(ccp(1,0))
            num:setPosition(icon:getContentSize().width-10,10)
            icon:addChild(num)
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

function acTreasureOfKafukaTab1:dispose()
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acXuyuanlu.pvr.ccz")
	self.layerNum=nil
	self.selectedTabIndex=nil
	self.acTreasureDialog=nil

    self.bgLayer=nil
    self.onceBtn=nil
    self.tenBtn=nil
    self.backBg=nil
    self.flicker=nil
    self.spSize=nil
    self.spTab=nil
    self.descLb=nil
    self.animationBg=nil

    self.spTb=nil
    self.itemPosition=nil

    self.aid=nil
    self.ascNum=nil
    self.secIndex=nil
    self.iconList=nil
    self.itemList=nil
    self.rewardList=nil

    -- self.second=nil
    self.movePos=nil
    self.tipAward=nil

    self.oneEnough=nil
    self.tenEnough=nil
    self.oneSelectedLb=nil
    self.tenSelectedLb=nil

    self.costLb1=nil
	self.gemIcon1=nil
	self.needLb1=nil
	self.costLb3=nil
	self.gemIcon3=nil
	self.line=nil
	self.costLb2=nil
	self.gemIcon2 =nil
	self.needLb2=nil
end