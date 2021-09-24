acKafukabaozangTab1={}

function acKafukabaozangTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.acEquipSearchDialog=nil

    self.bgLayer=nil
    self.onceBtn=nil
   -- self.tenBtn=nil
    self.backBg=nil
    self.flicker=nil
    self.spSize=100
    self.spTab={}
    self.descLb=nil

    self.selectOnce =nil
    self.selectTen=nil
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

function acKafukabaozangTab1:init(layerNum,selectedTabIndex,acEquipSearchDialog)
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.acEquipSearchDialog=acEquipSearchDialog
    self.bgLayer=CCLayer:create()

    local function touchDialog()
    end
  	self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
  	self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
  	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
  	self.touchDialogBg:setContentSize(rect)
  	--self.touchDialogBg:setOpacity(0)
 	 self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
  	self.touchDialogBg:setPosition(ccp(9999999,0))
 	 --self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
  	self.bgLayer:addChild(self.touchDialogBg,10)
	  --self.touchDialogBg:setVisible(false)

    self:initDesc()
    --self:initAwardPool()
    self.selectOnce=true
    self.selectTen=false
    self:initChestSp()
    self:initSearch()
    return self.bgLayer
end

function acKafukabaozangTab1:initDesc()
    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,150))
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height - 165))
    self.bgLayer:addChild(titleBg,1)

    local leftIcon = CCSprite:createWithSpriteFrameName("acbaozangIcon.png")
    leftIcon:setScale(1.5)
    leftIcon:setPosition(ccp(10,titleBg:getContentSize().height/2))
    leftIcon:setAnchorPoint(ccp(0,0.5))
    titleBg:addChild(leftIcon,5)

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

    self.actTime=GetTTFLabel(getlocal("activity_timeLabel"),timeSize)
    self.actTime:setPosition(ccp(titleBg:getContentSize().width*0.3-50,titleBg:getContentSize().height-25))
    self.actTime:setAnchorPoint(ccp(0,0.5))
    titleBg:addChild(self.actTime,5)
    self.actTime:setColor(G_ColorGreen)

    self.rewardTimeStr = GetTTFLabel(getlocal("recRewardTime"),timeSize)
    self.rewardTimeStr:setAnchorPoint(ccp(0,0.5))
    self.rewardTimeStr:setColor(G_ColorYellowPro)
    self.rewardTimeStr:setPosition(ccp(titleBg:getContentSize().width*0.3-50,titleBg:getContentSize().height-60))
    titleBg:addChild(self.rewardTimeStr,5)

    local acVo = acEquipSearchIIVoApi:getAcVo()
    if acVo then
    	local timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    	self.timeLabel = GetTTFLabel(timeStr,reTimeSize)
        self.timeLabel:setAnchorPoint(ccp(0,0.5))
    	self.timeLabel:setPosition(ccp(titleBg:getContentSize().width*0.4+timeShowWidth,titleBg:getContentSize().height-25))
    	titleBg:addChild(self.timeLabel,5)

        local timeStr2=activityVoApi:getActivityRewardTimeStr(acVo.acEt,60,86400)
        self.timeLabel2=GetTTFLabel(timeStr2,reTimeSize)
        self.timeLabel2:setAnchorPoint(ccp(0,0.5))
        self.timeLabel2:setPosition(ccp(titleBg:getContentSize().width*0.4+timeShowWidth,titleBg:getContentSize().height-60))
        titleBg:addChild(self.timeLabel2)
    end

    self.descLb=GetTTFLabelWrap(getlocal("activity_equipSearch_time_end"),25,CCSizeMake(titleBg:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.descLb:setAnchorPoint(ccp(0.5,0.5))
    self.descLb:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height-50))
    titleBg:addChild(self.descLb,2)
    self.descLb:setColor(G_ColorGreen)
    if acEquipSearchIIVoApi:acIsStop()==true then
    	self.descLb:setVisible(true)
    	self.actTime:setVisible(false)
    	self.timeLabel:setVisible(false)
        self.rewardTimeStr:setVisible(false)
        self.timeLabel2:setVisible(false)
    else
    	self.descLb:setVisible(false)
    	self.actTime:setVisible(true)
    	self.timeLabel:setVisible(true)
        self.rewardTimeStr:setVisible(true)
        self.timeLabel2:setVisible(true)
    end

    local descTv = G_LabelTableView(CCSize(titleBg:getContentSize().width-200,60),getlocal("activity_kafukabaozang_content"),23,kCCTextAlignmentLeft)
   	descTv:setPosition(ccp(125,10))
   	descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
   	descTv:setAnchorPoint(ccp(0,0))
   	descTv:setMaxDisToBottomOrTop(50)
   	titleBg:addChild(descTv,5)

    local function onClickDesc()
        local strTab={" ",getlocal("activity_equipSearch_search_tip_6"),getlocal("activity_equipSearch_search_tip_5"),getlocal("activity_equipSearch_search_tip_4"),getlocal("activity_equipSearch_search_tip_3"),getlocal("activity_equipSearch_search_tip_2"),getlocal("activity_equipSearch_search_tip_1")," "}
        local colorTab={nil,G_ColorYellow,G_ColorYellow,G_ColorWhite,G_ColorWhite,G_ColorYellow,G_ColorWhite,nil}
        local sd=smallDialog:new()
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab)
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local scale=0.8
    local descBtnItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",onClickDesc)
    descBtnItem:setAnchorPoint(ccp(0.5,1))
    descBtnItem:setScale(scale)
    local descBtn=CCMenu:createWithItem(descBtnItem)
    descBtn:setAnchorPoint(ccp(0.5,1))
    descBtn:setPosition(ccp(titleBg:getContentSize().width-descBtnItem:getContentSize().width*scale/2-10,titleBg:getContentSize().height-20))
    descBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    titleBg:addChild(descBtn,2)

end

function acKafukabaozangTab1:initAwardPool()
    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local backBgHeight=G_VisibleSize.height-500
    self.backBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    self.backBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,backBgHeight))
    self.backBg:setAnchorPoint(ccp(0,0))
    self.backBg:setPosition(ccp(30,247))
    self.bgLayer:addChild(self.backBg,1)


    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    -- local awardPool=FormatItem(cfg.pool) or {}
    local awardPool=cfg.pool or {}
    local row=math.ceil(SizeOfTable(awardPool)/5)
    for k,v in pairs(awardPool) do
        local px=20+self.spSize/2+((k-1)%5)*110
        -- local space=(backBgHeight/row)-5
        local space=110
        local py=self.backBg:getContentSize().height-(math.ceil(k/5)-1)*space-self.spSize/2-16
        if G_isIphone5()==true then
            space=135
            py=self.backBg:getContentSize().height-(math.ceil(k/5)-1)*space-self.spSize/2-63
        end

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
                local scale=self.spSize/icon:getContentSize().width
                icon:setScale(scale)
                icon:setPosition(ccp(px,py))
                icon:setTouchPriority(-(self.layerNum-1)*20-4)
                self.backBg:addChild(icon,1)
                table.insert(self.spTab,k,icon)
            end
        end
    end

end

function acKafukabaozangTab1:initSearch()
    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    local oneCost=cfg.oneCost
    local tenCost=cfg.tenCost

    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end

    local IconStr
    local scale
    local iconSize=30
    if activityVoApi:getLotteryIsUseProp(acEquipSearchIIVoApi:getAcVo()) ==true then
        IconStr = "Ticket.png"
        scale=0.5
    else
        IconStr = "IconGold.png"
        scale=0.7
    end

    print(IconStr)
    local btnY = 70
    local hPos=btnY+60
    self.gemIcon1 = CCSprite:createWithSpriteFrameName(IconStr)
    self.gemIcon1:setAnchorPoint(ccp(0,0.5))
    local scale=iconSize/self.gemIcon1:getContentSize().width
    self.gemIcon1:setScale(scale)
    self.gemIcon1:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,hPos))
    self.bgLayer:addChild(self.gemIcon1,2)

    self.costLb1=GetTTFLabel(oneCost[2],28)
    self.costLb1:setAnchorPoint(ccp(1,0.5))
    self.costLb1:setPosition(ccp(self.bgLayer:getContentSize().width/2,hPos))
    self.bgLayer:addChild(self.costLb1,2)
    self.costLb1:setColor(G_ColorYellowPro)


    local lSpace=45

    self.costLb2=GetTTFLabel(tenCost[2][2],28)
    self.costLb2:setAnchorPoint(ccp(0,0.5))
    self.costLb2:setPosition(ccp(self.bgLayer:getContentSize().width/2,hPos))
    self.bgLayer:addChild(self.costLb2,2)
    self.costLb2:setColor(G_ColorYellowPro)

    self.gemIcon2 = CCSprite:createWithSpriteFrameName(IconStr)
    self.gemIcon2:setAnchorPoint(ccp(0,0.5))
    local scale=iconSize/self.gemIcon2:getContentSize().width
    self.gemIcon2:setScale(scale)
    self.gemIcon2:setPosition(ccp(self.bgLayer:getContentSize().width/2+self.costLb2:getContentSize().width+10,hPos))
    self.bgLayer:addChild(self.gemIcon2,2)

    self.gemIcon3 = CCSprite:createWithSpriteFrameName(IconStr)
    self.gemIcon3:setAnchorPoint(ccp(1,0.5))
    local scale=iconSize/self.gemIcon2:getContentSize().width
    self.gemIcon3:setScale(scale*0.8)
    self.gemIcon3:setPosition(ccp(self.bgLayer:getContentSize().width/2-10,hPos))
    self.bgLayer:addChild(self.gemIcon3,2)

    self.costLb3=GetTTFLabel(tenCost[2][1],22)
    self.costLb3:setAnchorPoint(ccp(1,0.5))
    self.costLb3:setPosition(ccp(self.bgLayer:getContentSize().width/2-self.gemIcon3:getContentSize().width*scale*0.8-10,hPos))
    self.bgLayer:addChild(self.costLb3,2)
    self.costLb3:setColor(G_ColorYellowPro)

    self.lineRedSp = CCSprite:createWithSpriteFrameName("redline.jpg")
    self.lineRedSp:setScaleX((self.costLb3:getContentSize().width+iconSize+10)/self.lineRedSp:getContentSize().width)
    self.lineRedSp:setAnchorPoint(ccp(1,0.5))
    self.lineRedSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-10,hPos))
    self.bgLayer:addChild(self.lineRedSp,5)




    

    
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
                if self.selectOnce==true then
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
                    self.reward = {}
                    self.point = 0
                    local report=sData.data.equipSearchII.report or {}
                    for k,v in pairs(report) do
                        local awardTb=FormatItem(v[1]) or {}
                        for m,n in pairs(awardTb) do
                            local award=n or {}
                            print(award.key,award.name)
                            self.reward = award
                            self.point = v[2]
                            local index=acEquipSearchIIVoApi:getIndexByNameAndNum(award.key,award.num)
                            table.insert(content,{award=award,point=v[2],index=index})
                            G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                        end
                    end
                    if self.selectOnce==true then
                    	if acEquipSearchIIVoApi:isSearchToday()==false then
                    		acEquipSearchIIVoApi:setLastTime(base.serverTime)
                    	end
                        if self then
                            if self.oneChest then
	                        	self.oneChest:setVisible(false)
	                        end
	                        if self.selectChest then
	                        	self.selectChest:removeFromParentAndCleanup(true)
	                        	self.selectChest = nil
	                        end
	                        self.selectChest = CCSprite:createWithSpriteFrameName("silverBoxOpen.png")
	                        self.selectChest:setPosition(self.oneChest:getPosition())
	                        self.bgLayer:addChild(self.selectChest,11)

	                        local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
						    lightSp:setAnchorPoint(ccp(0.5,0.5))
						    lightSp:setPosition(getCenterPoint(self.selectChest))
						    self.selectChest:addChild(lightSp,1)

						    local itemIcon = G_getItemIcon(self.reward, 100, true, self.layerNum)
						    itemIcon:setAnchorPoint(ccp(0.5,0.5))
							itemIcon:setPosition(getCenterPoint(lightSp))
							lightSp:addChild(itemIcon)

							local numlb = GetTTFLabel("x"..self.reward.num,25)
                            numlb:setAnchorPoint(ccp(1,0))
                            numlb:setPosition(itemIcon:getContentSize().width-10,10)
                            itemIcon:addChild(numlb)

                            local function playEndCallback()
                                local function sureHandler( ... )
			                        if self.sureBtn then
			                            self.sureBtn:setVisible(false)
			                        end
			                        if self.selectChest then
			                        	self.selectChest:removeFromParentAndCleanup(true)
			                        	self.selectChest = nil
			                        end
			                        if self.rewardDesc then
			                            self.rewardDesc:setVisible(false)
			                        end
			                        if self.oneChest then
			                        	self.oneChest:setVisible(true)
			                        end

			                        self.touchDialogBg:setIsSallow(false)
			                        --self.touchDialogBg:setVisible(false)
			                        self.touchDialogBg:setPosition(ccp(9999999,0))
			                        G_showRewardTip({self.reward})
			                    end
			                    if self.rewardDesc == nil then
			                        self.rewardDesc = GetTTFLabelWrap(getlocal("activity_kafukabaozang_openOneChest",{self.reward.name.." x"..self.reward.num," x"..self.point}),25,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			                        self.rewardDesc:setAnchorPoint(ccp(0.5,0.5))
			                        self.rewardDesc:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-60)
			                        self.bgLayer:addChild(self.rewardDesc,13)
			                    else
			                        self.rewardDesc:setVisible(true)
			                        self.rewardDesc:setString(getlocal("activity_kafukabaozang_openOneChest",{self.reward.name.." x"..self.reward.num," x"..self.point}))
			                    end
			                    if self.sureBtn == nil then
			                        self.sureBtn = GetButtonItem("BigBtnBlue.png","BigBtnBlue.png","BigBtnBlue.png",sureHandler,11,getlocal("confirm"),25)
			                        local sureMenu = CCMenu:createWithItem(self.sureBtn);
			                        sureMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-160))
			                        sureMenu:setTouchPriority(-(self.layerNum-1)*20-14);
			                        self.bgLayer:addChild(sureMenu,13)
			                    else
			                        self.sureBtn:setVisible(true)
			                    end
                            end
                            --self.touchDialogBg:setVisible(true)
                            self.touchDialogBg:setIsSallow(true)
                            self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
                            local callFunc=CCCallFuncN:create(playEndCallback)
                            --local delay=CCDelayTime:create(0.5)
                            local mvTo=CCMoveTo:create(0.3,ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2+50))
                            local acArr=CCArray:create()
                            --acArr:addObject(delay)
                            local scale1=CCScaleTo:create(0.1,250/self.selectChest:getContentSize().width)
                            local scale2=CCScaleTo:create(0.2,1)
                            local delay=CCDelayTime:create(0.2)
                            acArr:addObject(mvTo)
                            acArr:addObject(scale1)
                            acArr:addObject(scale2)
                            acArr:addObject(delay)
                            acArr:addObject(callFunc)
                            local seq=CCSequence:create(acArr)
                            self.selectChest:runAction(seq)

                        end



                        --tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
                    end
                    if self.selectTen ==true then
	                    if content and SizeOfTable(content)>0 then
	                        local function confirmHandler(awardIdx)
	                        end
	                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_equipSearch_total"),content,nil,true,self.layerNum+1,confirmHandler,true,true)
	                    end
	                end
                end

                self:updateShowSearch()

                if self.acEquipSearchDialog then
                    self.acEquipSearchDialog:refresh()
                end
            end
        end
        local once=cfg.oneCost[1]
        local ten=cfg.tenCost[1]
        local oneCost=cfg.oneCost[2]
        local tenCost=cfg.tenCost[2][2]

        local function clickCallback( ... )
           if G_checkClickEnable()==false then
                do
                return
                end
            end
            activityAndNoteDialog:closeAllDialog()
        end

        if activityVoApi:getLotteryIsUseProp(acEquipSearchIIVoApi:getAcVo()) ==true then
            if self.selectOnce==true and acEquipSearchIIVoApi:isSearchToday()==false then
                socketHelper:activeEquipsearchII(1,searchCallback,once)
            else
                local needPro
                if self.selectOnce ==true then
                    needPro=oneCost
                elseif self.selectTen == true then
                    needPro=tenCost
                end
                
                local function touchBuy( ... )
                    if self.selectOnce ==true then
                        local diffGems=oneCost-playerVoApi:getGems()
                        if diffGems>0 then
                            GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost,clickCallback)
                            do return end
                        end
                        socketHelper:activeEquipsearchII(1,searchCallback,once)
                    elseif self.selectTen ==true then
                        local diffGems2=tenCost-playerVoApi:getGems()
                        if diffGems2>0 then
                            GemsNotEnoughDialog(nil,nil,diffGems2,self.layerNum+1,tenCost,clickCallback)
                            do return end
                        end
                        socketHelper:activeEquipsearchII(1,searchCallback,ten)
                    end
                   
                end
                local smallD=smallDialog:new()
                smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("activity_republicHui_notEnough",{needPro,needPro,getlocal("activity_republicHui_propName")}),nil,self.layerNum+1)
            end

        else
            if self.selectOnce ==true then
                local diffGems=oneCost-playerVoApi:getGems()
                if acEquipSearchIIVoApi:isSearchToday()==false then
                
                 elseif diffGems>0 then
                    GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost,clickCallback)
                    do return end
                end
                socketHelper:activeEquipsearchII(1,searchCallback,once)
            elseif self.selectTen ==true then
                local diffGems2=tenCost-playerVoApi:getGems()
                if diffGems2>0 then
                    GemsNotEnoughDialog(nil,nil,diffGems2,self.layerNum+1,tenCost,clickCallback)
                    do return end
                end
                socketHelper:activeEquipsearchII(1,searchCallback,ten)
            end
        end
        
        
    end
    -- self.onceBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",searchHandler,1)
    local textSize = 25
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
        textSize=20
    end
    self.onceBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",searchHandler,1,getlocal("activity_equipSearch_once_btn"),textSize,21)
    self.onceBtn:setAnchorPoint(ccp(0.5,0.5))
    local onceMune=CCMenu:createWithItem(self.onceBtn)
    onceMune:setAnchorPoint(ccp(0.5,0.5))
    onceMune:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnY))
    onceMune:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(onceMune,1)

    if acEquipSearchIIVoApi:isSearchToday()==false then
        tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
    else
        tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_kafukabaozang_getRewardBtn"))
    end

    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX(self.bgLayer:getContentSize().width/lineSp:getContentSize().width)
    lineSp:setAnchorPoint(ccp(0.5,0.5))
    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,btnY+90))
    self.bgLayer:addChild(lineSp,5)

    self.lotteryDescLb = GetTTFLabelWrap("",25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.lotteryDescLb:setAnchorPoint(ccp(0.5,0))
    self.lotteryDescLb:setPosition(self.bgLayer:getContentSize().width/2,btnY+100)
    self.bgLayer:addChild(self.lotteryDescLb)
    
    self:updateShowSearch()
end

function acKafukabaozangTab1:updateShowSearch()
    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    local oneCost=cfg.oneCost[2]
    local tenCost=cfg.tenCost[2][2]
    local playerGems = playerVoApi:getGems()
    if self.onceBtn then
        if acEquipSearchIIVoApi:checkCanSearch()==false then
            self.onceBtn:setEnabled(false)
        else
            self.onceBtn:setEnabled(true)
        end
    end
	if self.selectOnce == true then
		if self.gemIcon1 and self.costLb1 then
			if acEquipSearchIIVoApi:isSearchToday()==false then
				self.gemIcon1:setVisible(false)
	    		self.costLb1:setVisible(false)
			else
	    		self.gemIcon1:setVisible(true)
	    		self.costLb1:setVisible(true)
                if activityVoApi:getLotteryIsUseProp(acEquipSearchIIVoApi:getAcVo()) ==false then
                    if oneCost>playerGems then
                        self.costLb1:setColor(G_ColorRed)
                    else
                        self.costLb1:setColor(G_ColorWhite)
                    end
                end
	    	end
    	end
    	if self.gemIcon2 and self.gemIcon3 and self.costLb2 and self.costLb3 and self.lineRedSp then
    		self.gemIcon2:setVisible(false)
    		self.gemIcon3:setVisible(false)
	    	self.costLb2:setVisible(false)
	    	self.costLb3:setVisible(false)
	    	self.lineRedSp:setVisible(false)
    	end
    	if self.lotteryDescLb then
    		self.lotteryDescLb:setString(getlocal("activity_kafukabaozang_onceLotteryDesc"))
    	end
    else
    	if self.gemIcon1 and self.costLb1 then
	    	self.gemIcon1:setVisible(false)
	    	self.costLb1:setVisible(false)
    	end
    	if self.gemIcon2 and self.gemIcon3 and self.costLb2 and self.costLb3 and self.lineRedSp then
	    	self.gemIcon2:setVisible(true)
	    	self.gemIcon3:setVisible(true)
	    	self.costLb2:setVisible(true)
	    	self.costLb3:setVisible(true)
	    	self.lineRedSp:setVisible(true)
            if activityVoApi:getLotteryIsUseProp(acEquipSearchIIVoApi:getAcVo()) ==false then
                 if tenCost>playerGems then
                    self.costLb2:setColor(G_ColorRed)
                else
                    self.costLb2:setColor(G_ColorWhite)
                end
            end
	    end
	    if self.lotteryDescLb then
    		self.lotteryDescLb:setString(getlocal("activity_kafukabaozang_tenLotteryDesc"))
    	end
    end
end



function acKafukabaozangTab1:initChestSp()
	local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
	local function nilClick( ... )
		-- body
	end
	local chestSp =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilClick)
	chestSp:setContentSize(CCSizeMake(300, 178))
    chestSp:ignoreAnchorPointForPosition(false)
    chestSp:setAnchorPoint(ccp(0.5,0))
    chestSp:setIsSallow(false)
    chestSp:setTouchPriority(-(self.layerNum-1)*20-2)
	chestSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,230))
    self.bgLayer:addChild(chestSp,5)

    self.jiaoSp1 = CCSprite:createWithSpriteFrameName("TriangleLight.png")
    -- self.jiaoSp1:setScaleY(0.6)
    self.jiaoSp1:setAnchorPoint(ccp(0.5,0))
    self.jiaoSp1:setPosition(self.bgLayer:getContentSize().width/2,400)
    self.bgLayer:addChild(self.jiaoSp1,4)

    self.jiaoSp2 = CCSprite:createWithSpriteFrameName("TriangleLight.png")
    -- self.jiaoSp2:setRotation(180)
    -- self.jiaoSp2:setScaleY(0.6)
    self.jiaoSp2:setFlipX(true)
    self.jiaoSp2:setAnchorPoint(ccp(0.5,0))
    self.jiaoSp2:setPosition(self.bgLayer:getContentSize().width/2,400)
    self.bgLayer:addChild(self.jiaoSp2,4)

    local bgSp1 = CCSprite:createWithSpriteFrameName("expedition_up.png")
    bgSp1:setScaleX((self.bgLayer:getContentSize().width-100)/bgSp1:getContentSize().width)
    bgSp1:setAnchorPoint(ccp(0.5,1))
    bgSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-330))
    self.bgLayer:addChild(bgSp1,2)

    local bgSp2 = CCSprite:createWithSpriteFrameName("expedition_down.png")
    bgSp2:setScaleX((self.bgLayer:getContentSize().width-100)/bgSp2:getContentSize().width)
    bgSp2:setAnchorPoint(ccp(0.5,0))
    bgSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,420))
    self.bgLayer:addChild(bgSp2,2)



    -- local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilClick)
    -- backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-200,self.bgLayer:getContentSize().height-780))
    -- backSprie:setAnchorPoint(ccp(0.5,0))
    -- backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,420))
    --self.bgLayer:addChild(backSprie,1)


    local mapSp = CCSprite:create("scene/world_map_mi.jpg")
	mapSp:setScaleX((self.bgLayer:getContentSize().width-120)/mapSp:getContentSize().width)
	mapSp:setScaleY((self.bgLayer:getContentSize().height-760)/mapSp:getContentSize().height)
	mapSp:setAnchorPoint(ccp(0.5,0))
	mapSp:setPosition(self.bgLayer:getContentSize().width/2,430)
	self.bgLayer:addChild(mapSp,1)

	local treeSpH = 500
	local treeScale = 1.5
    local MountainSpH = 540
    local MountainSpScale = 1
	if G_isIphone5()==true then
		treeSpH = 550
		treeScale = 2.3
        MountainSpH = 620
        MountainSpScale = 1.5
	end

	local treeSP1 = CCSprite:createWithSpriteFrameName("world_ground_4.png")
    treeSP1:setAnchorPoint(ccp(0.5,0))
	treeSP1:setPosition(self.bgLayer:getContentSize().width/2-140,treeSpH)
	self.bgLayer:addChild(treeSP1,5)
	treeSP1:setScale(treeScale)

	local treeSP2 = CCSprite:createWithSpriteFrameName("world_ground_4.png")
    treeSP2:setAnchorPoint(ccp(0.5,0))
	treeSP2:setPosition(self.bgLayer:getContentSize().width/2+140,treeSpH)
	self.bgLayer:addChild(treeSP2,5)
	treeSP2:setScale(treeScale)

	local MountainSp = CCSprite:createWithSpriteFrameName("world_ground_1.png")
    MountainSp:setAnchorPoint(ccp(0.5,0))
	MountainSp:setPosition(self.bgLayer:getContentSize().width/2+150,MountainSpH)
	self.bgLayer:addChild(MountainSp,4)
	MountainSp:setScale(MountainSpScale)


	local function onceClick( ... )
		if self.selectOnce == false then
			self.selectOnce =true
			self.selectTen = false
			self:updateSelect()
			self:updateShowSearch()
		end
	end
    local checkOnceBg = LuaCCSprite:createWithSpriteFrameName("BtnCheckBg.png",onceClick)
    checkOnceBg:setAnchorPoint(ccp(0.5,0.5))
    checkOnceBg:setTouchPriority(-(self.layerNum-1)*20-4)
    checkOnceBg:setPosition(ccp(self.bgLayer:getContentSize().width/2-150,490))
    self.bgLayer:addChild(checkOnceBg,2)

    self.checkOnceIcon = CCSprite:createWithSpriteFrameName("BtnCheck.png")
    --checkIcon:setAnchorPoint(ccp(0,0.5))
    self.checkOnceIcon:setPosition(getCenterPoint(checkOnceBg))
    checkOnceBg:addChild(self.checkOnceIcon,1)

    local function tenClick( ... )
    	if acEquipSearchIIVoApi:isSearchToday()==false then
    		do return end
    	end
		if self.selectTen == false then
			self.selectTen =true
			self.selectOnce = false
			self:updateSelect()
			self:updateShowSearch()
		end
	end

    local checkTenBg = LuaCCSprite:createWithSpriteFrameName("BtnCheckBg.png",tenClick)
    checkTenBg:setAnchorPoint(ccp(0.5,0.5))
    checkTenBg:setTouchPriority(-(self.layerNum-1)*20-4)
    checkTenBg:setPosition(ccp(self.bgLayer:getContentSize().width/2+150,490))
    self.bgLayer:addChild(checkTenBg,2)

    self.checkTenIcon = CCSprite:createWithSpriteFrameName("BtnCheck.png")
    --checkIcon:setAnchorPoint(ccp(0,0.5))
    self.checkTenIcon:setPosition(getCenterPoint(checkTenBg))
    checkTenBg:addChild(self.checkTenIcon,1)

    local cfg = acEquipSearchIIVoApi:getEquipSearchCfg()

    local function onClickOneChest( ... )

    	local rewardCfg = FormatItem(cfg.showIconList,true,true)
    	local td = acFeixutansuoRewardTip:new()
        td:init("PanelHeaderPopup.png",getlocal("activity_kafukabaozang_onceChestName"),getlocal("activity_feixutansuo_rewardDesc"),rewardCfg,nil,self.layerNum+1)
    end
    -- self.oneChest = GetButtonItem("silverBox.png","silverBoxOpen.png","silverBoxOpen.png",onClickOneChest)
    -- local oneMenu = CCMenu:createWithItem(self.oneChest)
    -- oneMenu:setPosition(self.bgLayer:getContentSize().width/2,350)
    -- oneMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- self.bgLayer:addChild(oneMenu,5)

    self.oneChest = LuaCCSprite:createWithSpriteFrameName("silverBox.png",onClickOneChest)
    self.oneChest:setPosition(self.bgLayer:getContentSize().width/2,350)
    self.oneChest:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.oneChest,5)

    self.oneChestName = GetTTFLabelWrap(getlocal("activity_kafukabaozang_onceChestName"),25,CCSizeMake(chestSp:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.oneChestName:setAnchorPoint(ccp(0.5,0))
    self.oneChestName:setPosition(chestSp:getContentSize().width/2,20)
    chestSp:addChild(self.oneChestName)
    self.oneChestName:setColor(G_ColorGreen)


    local function onClickTenChest( ... )
    	local rewardCfg = FormatItem(cfg.showIconList,true,true)
    	local td = acFeixutansuoRewardTip:new()
        td:init("PanelHeaderPopup.png",getlocal("activity_kafukabaozang_tenChestName"),getlocal("activity_feixutansuo_rewardDesc"),rewardCfg,nil,self.layerNum+1)
    end
    -- self.tenChest = GetButtonItem("SpecialBox.png","SpecialBoxOpen.png","SpecialBoxOpen.png",onClickTenChest)
    -- local tenMenu = CCMenu:createWithItem(self.tenChest)
    -- tenMenu:setPosition(self.bgLayer:getContentSize().width/2,350)
    -- tenMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- self.bgLayer:addChild(tenMenu,5)

    self.tenChest = LuaCCSprite:createWithSpriteFrameName("SpecialBox.png",onClickTenChest)
    self.tenChest:setPosition(self.bgLayer:getContentSize().width/2,350)
    self.tenChest:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.tenChest,5)

    self.tenChestName = GetTTFLabelWrap(getlocal("activity_kafukabaozang_tenChestName"),25,CCSizeMake(chestSp:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.tenChestName:setAnchorPoint(ccp(0.5,0))
    self.tenChestName:setPosition(chestSp:getContentSize().width/2,20)
    chestSp:addChild(self.tenChestName)
    self.tenChestName:setColor(G_ColorGreen)

    self:updateSelect()
end

function acKafukabaozangTab1:updateSelect()

    if acEquipSearchIIVoApi:isSearchToday()==false then
        self.selectOnce =true
        self.selectTen = false
    end
	if self.checkOnceIcon then
		if self.selectOnce == true then
			self.checkOnceIcon:setVisible(true)
		else
			self.checkOnceIcon:setVisible(false)
		end
	end
	if self.oneChest and self.oneChestName then
		if self.selectOnce == true then
			--self.oneChest:setEnabled(true)
			self.oneChest:setVisible(true)
			self.oneChest:setPosition(self.bgLayer:getContentSize().width/2,350)
			self.oneChestName:setVisible(true)
		else
			--self.oneChest:setEnabled(false)
			self.oneChest:setVisible(false)
			self.oneChest:setPosition(999999,0)
			self.oneChestName:setVisible(false)
		end
	end
	if self.jiaoSp1 then
		if self.selectOnce == true then
			self.jiaoSp1:setVisible(true)
		else
			self.jiaoSp1:setVisible(false)
		end
	end
	if self.checkTenIcon then
		if self.selectTen==true then
			self.checkTenIcon:setVisible(true)
		else
			self.checkTenIcon:setVisible(false)
		end
	end
	if self.tenChest and self.tenChestName then
		if self.selectTen == true then
			--self.tenChest:setEnabled(true)
			self.tenChest:setVisible(true)
			self.tenChest:setPosition(self.bgLayer:getContentSize().width/2,350)
			self.tenChestName:setVisible(true)
		else
			--self.tenChest:setEnabled(false)
			self.tenChest:setVisible(false)
			self.tenChest:setPosition(999999,0)
			self.tenChestName:setVisible(false)
		end
	end

	if self.jiaoSp2 then
		if self.selectTen == true then
			self.jiaoSp2:setVisible(true)
		else
			self.jiaoSp2:setVisible(false)
		end
	end
end

function acKafukabaozangTab1:refresh()
    if self and self.bgLayer then
        if acEquipSearchIIVoApi:checkCanSearch()==false then
            self.onceBtn:setEnabled(false)
        else
            self.onceBtn:setEnabled(true)

            if acEquipSearchIIVoApi:isSearchToday()==false then

                if self then
                    for k,v in pairs(G_SmallDialogDialogTb) do
                        if v and v.close then
                            v:close()
                        end
                    end
                    self:updateSelect()
                    self:updateShowSearch()
                    tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))

                end
            else
                tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_kafukabaozang_getRewardBtn"))
            end
        end

        

        if self.descLb then
            if acEquipSearchIIVoApi:acIsStop()==true then
		    	self.descLb:setVisible(true)
		    	self.actTime:setVisible(false)
		    	self.timeLabel:setVisible(false)
                self.rewardTimeStr:setVisible(false)
                self.timeLabel2:setVisible(false)
		    else
		    	self.descLb:setVisible(false)
		    	self.actTime:setVisible(true)
		    	self.timeLabel:setVisible(true)
                self.rewardTimeStr:setVisible(true)
                self.timeLabel2:setVisible(true)
		    end
        end

    end
    
end

function acKafukabaozangTab1:dispose()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png")
    

    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.acEquipSearchDialog=nil

    self.spTab=nil
    self.spSize=nil
    self.onceBtn=nil
    --self.tenBtn=nil
    self.backBg=nil
    self.bgLayer=nil
    self.descLb=nil
    self.selectOnce =nil
    self.selectTen=nil
    self=nil

end






