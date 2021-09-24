acXuyuanluTab2={


}

function acXuyuanluTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
   
    self.layerNum=nil

    self.awardData=nil

    return nc

end

function acXuyuanluTab2:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self:initTableView()

    return self.bgLayer
end

function acXuyuanluTab2:initTableView()

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
  self.bgLayer:addChild(self.touchDialogBg,1)
  --self.touchDialogBg:setVisible(false)

	local function nilFun()
	end
    local capInSet = CCRect(20, 20, 10, 10);
	self.backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",capInSet,nilFun)
	self.backSprite:setAnchorPoint(ccp(0.5,1))
	self.backSprite:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-175))
	self.backSprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-100,self.bgLayer:getContentSize().height-500))
	self.bgLayer:addChild(self.backSprite)

	local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("activity_xuyuanlu_propTip5"),"\n",getlocal("activity_xuyuanlu_propTip4"),"\n",getlocal("activity_xuyuanlu_propTip3"),"\n",getlocal("activity_xuyuanlu_propTip2"),"\n",getlocal("activity_xuyuanlu_propTip1"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    --infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(self.backSprite:getContentSize().width-20,self.backSprite:getContentSize().height-20))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.backSprite:addChild(infoBtn,3)

    self.roundLb = GetTTFLabelWrap(getlocal("activity_xuyuanlu_round",{acXuyuanluVoApi:getNowRound()}),30,CCSizeMake(self.backSprite:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.roundLb:setAnchorPoint(ccp(0,0.5))
    self.roundLb:setPosition(30,self.backSprite:getContentSize().height-50)
    self.roundLb:setColor(G_ColorYellow)
    self.backSprite:addChild(self.roundLb)

	local function callBack(...)
     	return self:eventHandler(...)
	end
  	local hd= LuaEventHandler:createHandler(callBack)
  	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.backSprite:getContentSize().width-20,self.backSprite:getContentSize().height-120),nil)
  	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  	self.tv:setPosition(ccp(10,10))
  	self.backSprite:addChild(self.tv)
  	self.tv:setMaxDisToBottomOrTop(120)

    local btnX = self.bgLayer:getContentSize().width-150
	local btnY = 80

	self.canWishNumLb = GetTTFLabelWrap(getlocal("activity_xuyuanlu_todayNum",{}),25,CCSizeMake(260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.canWishNumLb:setAnchorPoint(ccp(0.5,0))
    self.canWishNumLb:setPosition(btnX-10,btnY+60)
    self.bgLayer:addChild(self.canWishNumLb)

    local lbSize=25
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage()=="ru" then
        lbSize =21
    end
    local desc = G_LabelTableView(CCSize(260,80),getlocal("activity_xuyuanlu_propDesc"),lbSize,kCCTextAlignmentCenter,G_ColorRed)
    desc:setAnchorPoint(ccp(0.5,1))
    desc:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    desc:setPosition(btnX-130,self.bgLayer:getContentSize().height-self.backSprite:getContentSize().height-270)
    desc:setMaxDisToBottomOrTop(50)
    self.bgLayer:addChild(desc)

    local scale = 0.8

    self.stoveSp=CCSprite:createWithSpriteFrameName("WishingStove.png")
    self.stoveSp:setScale(scale)
    self.stoveSp:setAnchorPoint(ccp(0,0))
    self.stoveSp:setPosition(40,btnY-20)
    self.bgLayer:addChild(self.stoveSp)

	local function wishHandler( ... )
		 local function wishCallback(fn,data)


            
            local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData.data.xuyuanlu.clientReward then
                    acXuyuanluVoApi:setPropWishNum(acXuyuanluVoApi:getPropWishNum()-1)
                    local reward = sData.data.xuyuanlu.clientReward
                    self.award={}
                    if reward then
                        for k,v in pairs(reward) do
                            local ptype = v[1]
                            local pid = v[2]
                            local pnum = v[3]
                            local name,pic,desc,id,noUseIdx,eType,equipId=getItem(pid,ptype)
                            self.award={name=name,num=pnum,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pid,eType=eType,equipId=equipId}
                            if acXuyuanluVoApi:checkIsChatByID(pid)==true then
                                local message={key="activity_chatSystemMessage",param={playerVoApi:getPlayerName(),getlocal("activity_xuyuanlu_title"),name}}
                                chatVoApi:sendSystemMessage(message)
                            end
                        end
                    end
                    G_addPlayerAward(self.award.type,self.award.key,self.award.id,self.award.num,nil,true)
                    acXuyuanluVoApi:updateShow()


                    self.wishBtn:setEnabled(false)
                    if self.particleS then
                        self.particleS:removeFromParentAndCleanup(true)
                        self.particleS = nil 
                    end
                    self.particleS = CCParticleSystemQuad:create("public/WishingFire.plist")
                    if G_isIphone5()==true then
                        self.particleS:setScale(scale)
                    end
                    self.particleS.positionType=kCCPositionTypeFree
                    self.particleS:setPosition(self.stoveSp:getContentSize().width/2,self.stoveSp:getContentSize().height-30)
                    self.stoveSp:addChild(self.particleS)
                    --self.particleS:setVisible(true)
                    if self.goldIcon then
                        self.goldIcon:removeFromParentAndCleanup(true)
                        self.goldIcon = nil 
                    end
                    local function endHandler()
                        if self and self.particleS then
                            if self.goldIcon then
                                self.goldIcon:removeFromParentAndCleanup(true)
                                self.goldIcon = nil 
                            end
                            
                            self.goldIcon =  G_getItemIcon(self.award,100, true, self.layerNum)
                            self.goldIcon:setAnchorPoint(ccp(0.5,0.5))
                            print("self.layerNum1=",self.layerNum)
                            if self.layerNum ==nil then
                                do
                                    return
                                end
                            end
                            print("self.layerNum2=",self.layerNum)
                            self.goldIcon:setTouchPriority(-(self.layerNum-1)*20-5)
                            self.goldIcon:setPosition(40+self.stoveSp:getContentSize().width*scale/2,btnY+self.stoveSp:getContentSize().height*scale-50)
                            self.bgLayer:addChild(self.goldIcon,10)
                            self.goldIcon:setScale(0.1)

                            local numlb = GetTTFLabel("x"..self.award.num,25)
                            numlb:setAnchorPoint(ccp(1,0))
                            numlb:setPosition(self.goldIcon:getContentSize().width-10,10)
                            self.goldIcon:addChild(numlb)


                            local function callBack()

                                local function playEndCallback1()
                                    local function sureHandler( ... )
                                        if self.goldIcon then
                                            self.goldIcon:removeFromParentAndCleanup(true)
                                            self.goldIcon = nil 
                                        end
                                        if self.particleS then
                                            self.particleS:removeFromParentAndCleanup(true)
                                            self.particleS = nil 
                                        end
                                        if self.sureBtn then
                                            self.sureBtn:setVisible(false)
                                        end
                                        if self.rewardDesc then
                                            self.rewardDesc:setVisible(false)
                                        end

                                        self.touchDialogBg:setIsSallow(false)
                                        --self.touchDialogBg:setVisible(false)
                                        self.touchDialogBg:setPosition(ccp(9999999,0))
                                        G_showRewardTip({self.award})
                                        self:updateShow()
                                    end
                                    if self.rewardDesc == nil then
                                        self.rewardDesc = GetTTFLabelWrap(self.award.name.." x"..self.award.num,25,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                                        self.rewardDesc:setAnchorPoint(ccp(0.5,0.5))
                                        self.rewardDesc:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-40)
                                        self.bgLayer:addChild(self.rewardDesc,13)
                                    else
                                        self.rewardDesc:setVisible(true)
                                        self.rewardDesc:setString(self.award.name.." x"..self.award.num)
                                    end
                                    if self.sureBtn == nil then
                                        self.sureBtn = GetButtonItem("BigBtnBlue.png","BigBtnBlue.png","BigBtnBlue.png",sureHandler,11,getlocal("confirm"),25)
                                        local sureMenu = CCMenu:createWithItem(self.sureBtn);
                                        sureMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-120))
                                        sureMenu:setTouchPriority(-(self.layerNum-1)*20-14);
                                        self.bgLayer:addChild(sureMenu,13)
                                    else
                                        self.sureBtn:setVisible(true)
                                    end
                                end
                                --self.touchDialogBg:setVisible(true)
                                self.touchDialogBg:setIsSallow(true)
                                self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
                                local callFunc=CCCallFuncN:create(playEndCallback1)
                                local delay=CCDelayTime:create(0.5)
                                local mvTo0=CCMoveTo:create(0.5,ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2+50))
                                local acArr=CCArray:create()
                                acArr:addObject(delay)
                                acArr:addObject(mvTo0)
                                acArr:addObject(callFunc)
                                local seq=CCSequence:create(acArr)
                                self.goldIcon:runAction(seq)

                            end
                            local callFunc=CCCallFunc:create(callBack)
                            local scaleTo1=CCScaleTo:create(2,1)
                            local acArr=CCArray:create()
                            acArr:addObject(scaleTo1)
                            acArr:addObject(callFunc)

                            local seq=CCSequence:create(acArr)
                            self.goldIcon:runAction(seq)
                        end
                    end
                    local callFunc=CCCallFunc:create(endHandler)
                    local delay=CCDelayTime:create(2)
                    local acArr=CCArray:create()
                    acArr:addObject(delay)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    sceneGame:runAction(seq)
               end
            end
        end

        socketHelper:activityXuyuanluPropWish(wishCallback)

	end

	self.wishBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",wishHandler,11,getlocal("activity_xuyuanlu_wishing"),25)
	local wishMenu = CCMenu:createWithItem(self.wishBtn);
	wishMenu:setPosition(ccp(btnX,btnY))
	wishMenu:setTouchPriority(-(self.layerNum-1)*20-4);
	self.bgLayer:addChild(wishMenu,3)



   	-- self.particleS = CCParticleSystemQuad:create("public/WishingFire.plist")
   	-- self.particleS:setScale(scale)
    -- self.particleS.positionType=kCCPositionTypeFree
   	-- self.particleS:setPosition(self.stoveSp:getContentSize().width/2,self.stoveSp:getContentSize().height-30)
    -- self.stoveSp:addChild(self.particleS)
    -- self.particleS:setVisible(false)

    self:updateShow()

end


function acXuyuanluTab2:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 3
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    tmpSize = CCSizeMake(self.backSprite:getContentSize().width - 20,(self.backSprite:getContentSize().height-120)/3)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    cell:setContentSize(CCSizeMake(self.backSprite:getContentSize().width - 20,(self.backSprite:getContentSize().height-120)/3-5))
    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setScaleX(cell:getContentSize().width/lineSprite:getContentSize().width)
    lineSprite:setScaleY(1.2)
    lineSprite:setPosition(cell:getContentSize().width/2,cell:getContentSize().height)
    cell:addChild(lineSprite)

    local state,needCfg= acXuyuanluVoApi:getConditionByID(idx+1)

    local descStr = ""
    if idx == 0 then
    	descStr=getlocal("activity_xuyuanlu_task1",{needCfg})
    elseif idx == 1 then
        state=FormatNumber(state)
        needCfg=FormatNumber(needCfg)
    	descStr=getlocal("activity_xuyuanlu_task2",{needCfg})
    elseif idx == 2 then
        state=FormatNumber(state)
        needCfg=FormatNumber(needCfg)
    	descStr=getlocal("activity_xuyuanlu_task3",{needCfg})
    end
    local descLb = GetTTFLabelWrap(descStr,25,CCSizeMake(cell:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0,1))
    descLb:setPosition(10,cell:getContentSize().height-10)
    cell:addChild(descLb)

    local stateLb = GetTTFLabelWrap("",25,CCSizeMake(cell:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    stateLb:setAnchorPoint(ccp(0,0))
    stateLb:setPosition(10,10)
    cell:addChild(stateLb)
    
    if acXuyuanluVoApi:CheckTaskIsCompleteByID(idx+1)==true then
        stateLb:setString(getlocal("schedule_finish"))
        stateLb:setColor(G_ColorGreen)
    else
        stateLb:setString(getlocal("schedule_count",{state,needCfg}))
        stateLb:setColor(G_ColorRed)
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

function acXuyuanluTab2:updateShow()
	local propWishNum = acXuyuanluVoApi:getPropWishNum()
    if self.canWishNumLb then
        self.canWishNumLb:setString(getlocal("activity_xuyuanlu_todayNum",{propWishNum}))
    end
    if self.wishBtn then
        if propWishNum<=0 then
            self.wishBtn:setEnabled(false)
        else
            self.wishBtn:setEnabled(true)
        end
    end
    if  self.roundLb then
        self.roundLb:setString(getlocal("activity_xuyuanlu_round",{acXuyuanluVoApi:getNowRound()}))
    end
    if self.tv then
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end
function acXuyuanluTab2:tick()

end

function acXuyuanluTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self = nil
end
