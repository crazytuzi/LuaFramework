--require "luascript/script/componet/commonDialog"
acCrystalYieldDialog={

}

function acCrystalYieldDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=nil
    self.dialogLayer=nil
    self.bgLayer=nil
    self.closeBtn=nil
    self.bgSize=nil
    self.tv=nil
    self.normalHeight=170
    self.extendSpTag=113
    self.timeLbTab={}
    self.isCloseing=false
    self.buffTab={}

    return nc
end

function acCrystalYieldDialog:init(layerNum)
 self.layerNum=layerNum
 base:setWait()
    if G_isIphone5() then
        self.normalHeight=220
    end

   local size=CCSizeMake(640,G_VisibleSize.height)

	self.isTouch=false
    self.isUseAmi=true
	if layerNum then
		self.layerNum=layerNum
	else
		self.layerNum=4
	end
	local rect=size
	local function touchHander()

	end

	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),touchHander)
	self.dialogLayer=CCLayer:create()
	self.dialogLayer:setBSwallowsTouches(true)
	self.bgLayer=dialogBg
	self.bgSize=size
	self.bgLayer:setContentSize(size)

	local function touchDialog()

	end

	local function close()
		--PlayEffect(audioCfg.mouseClic1k)
		self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0, 0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))

	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
	self.bgLayer:addChild(self.closeBtn)

    local titleLb
    if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="pt" then
          titleLb = GetTTFLabelWrap(getlocal("crystalYield"),33,CCSizeMake(dialogBg:getContentSize().width-220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
    else
        titleLb= GetTTFLabel(getlocal("crystalYield"),40)
    end

	--local titleLb=GetTTFLabel(getlocal("crystalYield"),36)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(dialogBg:getContentSize().width/2, dialogBg:getContentSize().height-40))
	dialogBg:addChild(titleLb)


	local buygems=playerVoApi:getBuygems()
	if buygems==0 then
		self.isFirstRecharge=true
	elseif buygems>0 then
		self.isFirstRecharge=false
	end

	local function touchLuaSpr()

	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),touchLuaSpr);
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,960)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(0)
	touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
	self.bgLayer:addChild(touchDialogBg,1);
	
	self.bgLayer:setPosition(getCenterPoint(sceneGame))
    self:initTableView()
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
    sceneGame:addChild(self.bgLayer,self.layerNum)

    self:show()



	--return self.bgLayer
end

--设置对话框里的tableView
function acCrystalYieldDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local heightH = self.bgLayer:getContentSize().height-self.normalHeight*3
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-heightH),nil)

    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    base:addNeedRefresh(self)

    local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    end
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(10,self.normalHeight*3+20))
    self.bgLayer:addChild(characterSp,5)
    

    
    local descLabel=GetTTFLabelWrap(getlocal("crystalYield_desc"),26,CCSizeMake(340,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2+100,self.bgLayer:getContentSize().height-300))
    self.bgLayer:addChild(descLabel,5)
    
    local function touch()
        local td=smallDialog:new()
        local str1=getlocal("crystalYield_desci1");
        local str2=getlocal("crystalYield_desci2");
        tabStr={" ",str2,str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        --dialog:setPosition(getCenterPoint(sceneGame))
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(580,self.bgLayer:getContentSize().height-140));
    menu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(menu,5);
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-105))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acCrystalYieldVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        --timeLabel:setAnchorPoint(ccp(0,0))
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-140))
        self.bgLayer:addChild(timeLabel)
        self.timeLb=timeLabel
        self:updateAcTime()
    end

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acCrystalYieldDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 3

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.normalHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight))
        
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        
        end
        local txtSize = 25
        if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="ru" or G_getCurChoseLanguage()=="pt" then
            txtSize = 20
        end
        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
        headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight-4))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)
        
        if idx==0 then
           local mIcon=CCSprite:createWithSpriteFrameName("item_buff_gold_up2.png")
           mIcon:setAnchorPoint(ccp(0,0.5));
           mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2-30))
           headerSprie:addChild(mIcon)
           
           local titleLb=GetTTFLabel(getlocal("crystalYield1"),25)
           titleLb:setAnchorPoint(ccp(0,0.5));
            titleLb:setPosition(ccp(20,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
            headerSprie:addChild(titleLb,5);
            titleLb:setColor(G_ColorGreen)
            
            local descLabel=GetTTFLabelWrap(getlocal("crystalYield_desc1"),txtSize,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLabel:setAnchorPoint(ccp(0,0.5));
            descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2-30))
            headerSprie:addChild(descLabel,5)


        elseif idx==1 then
            local mIcon=CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
           mIcon:setAnchorPoint(ccp(0,0.5));
           mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2-30))
           headerSprie:addChild(mIcon)
           
           local titleLb=GetTTFLabel(getlocal("crystalYield2"),25)
           titleLb:setAnchorPoint(ccp(0,0.5));
            titleLb:setPosition(ccp(20,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
            headerSprie:addChild(titleLb,5);
            titleLb:setColor(G_ColorGreen)

            local getNum=playerVoApi:getPlayerLevel()*activityCfg["crystalHarvest"].baseGoldNum
            local descLabel=GetTTFLabelWrap(getlocal("crystalYield_desc2",{getNum}),txtSize,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLabel:setAnchorPoint(ccp(0,0.5));
            descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2-30))
            headerSprie:addChild(descLabel,5)

            local timesLb=GetTTFLabel("(0/1)",25)
            
            local timesLb=GetTTFLabel("(0/1)",25)
            timesLb:setAnchorPoint(ccp(0,0.5));
            timesLb:setPosition(ccp(titleLb:getPositionX()+titleLb:getContentSize().width+10,titleLb:getPositionY()))
            headerSprie:addChild(timesLb,5)

            
            local function onClickSell()
                local function raidCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        local gold=playerVoApi:getGold()+playerVoApi:getPlayerLevel()*activityCfg["crystalHarvest"].baseGoldNum
                        playerVoApi:setGold(gold) --设置金币
                        timesLb:setString("(1/1)")
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_hadReward"),30)
                        self.confirmBtn:removeFromParentAndCleanup(true)
                        local confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickSell,2,getlocal("activity_hadReward"),25)
                        self.confirmBtn=CCMenu:createWithItem(confirmItem);
                        self.confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2-10,40))
                        self.confirmBtn:setTouchPriority(-(self.layerNum-1)*20-2);
                        headerSprie:addChild(self.confirmBtn)
                        acCrystalYieldVoApi:setIsReceive()
                        confirmItem:setEnabled(false)
                        acCrystalYieldVoApi:updateShow()
                    end
                end
                socketHelper:activeCrystalHarvest(raidCallback)
            end
            
            local buttonstr=getlocal("daily_scene_get")
            if acCrystalYieldVoApi:isTodayReceive()==false then
                buttonstr=getlocal("activity_hadReward")
                timesLb:setString("(1/1)")
            end
            
            local confirmItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickSell,2,buttonstr,25)
                self.confirmBtn=CCMenu:createWithItem(confirmItem);
                self.confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2-10,40))
                self.confirmBtn:setTouchPriority(-(self.layerNum-1)*20-2);
                headerSprie:addChild(self.confirmBtn)
                
                if acCrystalYieldVoApi:isTodayReceive()==false then
                    confirmItem:setEnabled(false)
                end

        elseif idx==2 then
            local mIcon=CCSprite:createWithSpriteFrameName("item_baoxiang_05.png")
           mIcon:setAnchorPoint(ccp(0,0.5));
           mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2-30))
           headerSprie:addChild(mIcon)
           
           local titleLb=GetTTFLabel(getlocal("crystalYield3"),25)
           titleLb:setAnchorPoint(ccp(0,0.5));
            titleLb:setPosition(ccp(20,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
            headerSprie:addChild(titleLb,5);
            titleLb:setColor(G_ColorGreen)
            
            local timesStr="("..acCrystalYieldVoApi:getBuyCount().."/"..activityCfg["crystalHarvest"].maxCount.p96..")"
            local timesLb=GetTTFLabel(timesStr,25)
            timesLb:setAnchorPoint(ccp(0,0.5));
            timesLb:setPosition(ccp(titleLb:getPositionX()+titleLb:getContentSize().width+10,titleLb:getPositionY()))
            headerSprie:addChild(timesLb,5)

            
            local descLabel=GetTTFLabelWrap(getlocal("crystalYield_desc3"),txtSize,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLabel:setAnchorPoint(ccp(0,0.5));
            descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2-30))
            headerSprie:addChild(descLabel,5)
            
            local oldGoldLb=GetTTFLabel(propCfg["p96"].gemCost,30)
            oldGoldLb:setPosition(ccp(headerSprie:getContentSize().width-90,150))
            headerSprie:addChild(oldGoldLb,5)
            oldGoldLb:setColor(G_ColorRed)
            
            local line = CCSprite:createWithSpriteFrameName("redline.jpg")
            line:setScaleX((oldGoldLb:getContentSize().width  + 30) / line:getContentSize().width)
            --line:setAnchorPoint(ccp(0, 0))
            line:setPosition(getCenterPoint(oldGoldLb))
            oldGoldLb:addChild(line,2)

            local cellNum=math.ceil(propCfg["p96"].gemCost*activityCfg["crystalHarvest"].props.p96)
            local newGoldLb=GetTTFLabel(cellNum,30)
            newGoldLb:setPosition(ccp(headerSprie:getContentSize().width-90,110))
            headerSprie:addChild(newGoldLb,5)
            newGoldLb:setColor(G_ColorYellowPro)
            
            local goldIcon1=CCSprite:createWithSpriteFrameName("IconGold.png");
            goldIcon1:setPosition(ccp(oldGoldLb:getPositionX()+50,oldGoldLb:getPositionY()));
            headerSprie:addChild(goldIcon1)
            
            local goldIcon2=CCSprite:createWithSpriteFrameName("IconGold.png");
            goldIcon2:setPosition(ccp(newGoldLb:getPositionX()+50,newGoldLb:getPositionY()));
            headerSprie:addChild(goldIcon2)

            local function touch1(tag,object)
                 if self.tv:getIsScrolled()==true then
                    return
                 end
                 
                 if acCrystalYieldVoApi:getBuyCount()==activityCfg["crystalHarvest"].maxCount.p96 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_discount_maxNum"),30)
                    do
                        return
                    end
                 end

                 PlayEffect(audioCfg.mouseClick)
                local function touchBuy()
                    local function callbackBuyprop(fn,data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data)==true then
                            --统计购买物品
                            local cellNum=math.ceil(propCfg["p96"].gemCost*activityCfg["crystalHarvest"].props.p96)
                            statisticsHelper:buyItem(propCfg["p96"].sid,cellNum,1,cellNum)
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{getlocal(propCfg["p96"].name)}),28)
                            local count=acCrystalYieldVoApi:getBuyCount()+1
                            acCrystalYieldVoApi:setBuyCount(count)
                            local timesStr="("..acCrystalYieldVoApi:getBuyCount().."/"..activityCfg["crystalHarvest"].maxCount.p96..")"
                            timesLb:setString(timesStr)

                        end

                    end
                    socketHelper:buyProc(96,callbackBuyprop,1,"crystalHarvest")
                end
                local function buyGems()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                end
                    vipVoApi:showRechargeDialog(self.layerNum+1)

                end
                local cellNum=math.ceil(propCfg["p96"].gemCost*activityCfg["crystalHarvest"].props.p96)

                if playerVo.gems<tonumber(cellNum) then
                    local num=tonumber(cellNum)-playerVo.gems
                    local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(cellNum),playerVo.gems,num}),nil,self.layerNum+1)
                else
                    local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{cellNum,getlocal(propCfg["p96"].name)}),nil,self.layerNum+1)
                end

            end
            
            local confirmItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touch1,2,getlocal("buy"),25)
                local confirmBtn=CCMenu:createWithItem(confirmItem);
                confirmBtn:setPosition(ccp(headerSprie:getContentSize().width-confirmItem:getContentSize().width/2-10,40))
                confirmBtn:setTouchPriority(-(self.layerNum-1)*20-2);
                headerSprie:addChild(confirmBtn)

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
--点击了cell或cell上某个按钮
function acCrystalYieldDialog:cellClick(idx)
 if self.tv==nil then
    do
        return
    end
 end
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            --self.requires[idx-1000+1]:dispose()
            --self.requires[idx-1000+1]=nil
            --self.allCellsBtn[idx-1000+1]=nil
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

function acCrystalYieldDialog:updateAcTime()
    local acVo=acCrystalYieldVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acCrystalYieldDialog:tick()
    local vo=acCrystalYieldVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    self:updateAcTime()
end

function acCrystalYieldDialog:close()

    if hasAnim==nil then
        hasAnim=true
    end
    base.allShowedCommonDialog=base.allShowedCommonDialog-1
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
         if v==self then
            table.remove(base.commonDialogOpened_WeakTb,k)
            break
         end
    end
    if base.allShowedCommonDialog<0 then
        base.allShowedCommonDialog=0
    end
    local function realClose()
        return self:realClose()
    end
    if base.allShowedCommonDialog==0 and storyScene.isShowed==false then
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
   base:removeFromNeedRefresh(self) --停止刷新
   local fc= CCCallFunc:create(realClose)
   local moveTo=CCMoveTo:create((hasAnim==true and 0.3 or 0),CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
   local acArr=CCArray:create()
   acArr:addObject(moveTo)
   acArr:addObject(fc)
   local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)

end
function acCrystalYieldDialog:realClose()

    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()

end
--显示面板,加效果
function acCrystalYieldDialog:show()
   local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
   local function callBack()
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setHide()
            elseif sceneController.curIndex==1 then
                mainLandScene:setHide()
            elseif sceneController.curIndex==2 then
                worldScene:setHide()
            end
            
          
            mainUI:setHide()
            --self:getDataByType() --只有Email使用这个方法
        end
       base:cancleWait()
   end
   base.allShowedCommonDialog=base.allShowedCommonDialog+1
   table.insert(base.commonDialogOpened_WeakTb,self)
   local callFunc=CCCallFunc:create(callBack)
   local seq=CCSequence:createWithTwoActions(moveTo,callFunc)
   self.bgLayer:runAction(seq)
end
function acCrystalYieldDialog:dispose()
    self.layerNum=nil
    self.dialogLayer=nil
    self.bgLayer=nil
    self.closeBtn=nil
    self.bgSize=nil
    self.tv=nil
    self.normalHeight=nil
    self.extendSpTag=nil
    self.timeLb=nil
    base:removeFromNeedRefresh(self) --停止刷新
    self=nil
end
