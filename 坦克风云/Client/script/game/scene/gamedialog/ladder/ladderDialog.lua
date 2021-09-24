-- 天梯排行榜
ladderDialog = commonDialog:new()
function ladderDialog:new()
    local  nc = {}
    setmetatable(nc,self)
    self.__index=self
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/serverWarLocal/serverWarLocalCommon.plist")
    return nc
end

--初始化对话框面板
function ladderDialog:initTableView( )
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))


    local seasonTitleSp = CCSprite:createWithSpriteFrameName("ladder_title_bg.png")
    seasonTitleSp:setAnchorPoint(ccp(0.5,0.5))
    seasonTitleSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-125))
    self.bgLayer:addChild(seasonTitleSp)

    local seasonTitleLb=GetTTFLabelWrap(ladderVoApi:getServerWarSeasonTitle(),30,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    seasonTitleLb:setAnchorPoint(ccp(0.5,0.5))
    seasonTitleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-125))
    self.bgLayer:addChild(seasonTitleLb)
    seasonTitleLb:setColor(G_ColorYellow)

    local function close()
        PlayEffect(audioCfg.mouseClick)    
        if(self.flameTb)then
            for k,v in pairs(self.flameTb) do
                v:removeFromParentAndCleanup(true)
            end
            self.flameTb=nil
        end
        return self:close()
     end
   local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    -- 帮助按钮
    local function helpHandler(tag,object)
        PlayEffect(audioCfg.mouseClick)
        ladderVoApi:openLadderRewardDialog(self.layerNum+1)
    end

    local helpBtn = GetButtonItem("mainBtnHelp.png","mainBtnHelp_Down.png","mainBtnHelp_Down.png",helpHandler,nil,nil,0)
    helpBtn:setAnchorPoint(ccp(1,0.5))
    helpBtn:setScale(0.8)
    local helpBtnMenu=CCMenu:createWithItem(helpBtn)
    helpBtnMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    helpBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width-30, self.bgLayer:getContentSize().height-125))
    self.bgLayer:addChild(helpBtnMenu,1)

    local pokerStartY = seasonTitleLb:getPositionY()-30
    local pokerH = pokerStartY-140

    local descLb=GetTTFLabelWrap(getlocal("ladderRank_desc1"),23,CCSizeMake(self.bgLayer:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,125))
    self.bgLayer:addChild(descLb)

    self:initMainUI(pokerStartY,pokerH)
    self:initAllButton()
end

function ladderDialog:initMainUI(pokerStartY,pokerH)
    local bgH = pokerH/2-20
    local bgW = self.bgLayer:getContentSize().width/2-30
    local pokerScaleY = 0.95
    if G_isIphone5()==true then
        pokerScaleY=1.2
    end
    self.warlist=ladderVoApi:getAllServerWarList()
    local index = 0
    local capInSet = CCRect(20, 20, 10, 10)
    local function clickPokerHandler(hd,fn,idx)
        ladderVoApi:openVsDialog(self.warlist[idx].id,idx,self.layerNum+1)
    end
    local function touchHander()
    end
    for k,v in pairs(self.warlist) do
        local temX = (bgW+10)*math.floor(index%2)+bgW/2+25
        local temY = pokerStartY-bgH/2-(bgH+10)*math.floor(index/2)-10
        index=index+1
        local pokerBg
        -- if v.flag==1 or v.flag==4 or v.flag==0 then
        if v.flag==4 or v.flag==0 then
            pokerBg = GraySprite:create(v.pic)
        else
            pokerBg = LuaCCSprite:createWithFileName(v.pic,clickPokerHandler)
            pokerBg:setTouchPriority(-(self.layerNum-1)*20-2)
        end
        pokerBg:setPosition(ccp(temX,temY))
        self.bgLayer:addChild(pokerBg)
        pokerBg:setTag(index)
        pokerBg:setScaleY(pokerScaleY)
        if v.flag==2 then
            self:addFlameBorder(pokerBg,pokerScaleY)
        end

        local subTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 1, 1),touchHander)
        subTitleBg:setContentSize(CCSizeMake(bgW-20,50))
        subTitleBg:setPosition(ccp(bgW/2-5,pokerBg:getContentSize().height-33))
        pokerBg:addChild(subTitleBg)
        subTitleBg:setScaleY(1/pokerScaleY)

        local subTitleLb=GetTTFLabelWrap(v.title,25,CCSizeMake(bgW-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        subTitleLb:setPosition(ccp(bgW/2,pokerBg:getContentSize().height-33))
        pokerBg:addChild(subTitleLb)
        subTitleLb:setColor(G_ColorYellowPro)
        subTitleLb:setScaleY(1/pokerScaleY)

        if v.flag~=0 then
            local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),touchHander)
            descBg:setContentSize(CCSizeMake(bgW-20,80))
            descBg:setPosition(ccp(bgW/2-3,30))
            pokerBg:addChild(descBg)
            -- descBg:setScaleY(0.5)
            descBg:setScaleY(1/pokerScaleY*0.5)

            local descLb=GetTTFLabelWrap(v.state,23,CCSizeMake(bgW-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            descLb:setPosition(ccp(bgW/2,30))
            pokerBg:addChild(descLb)
            descLb:setColor(v.stateColor)
            descLb:setScaleY(1/pokerScaleY)
            self["descLb"..index]=descLb
        else
            subTitleBg:setPosition(ccp(bgW/2-5,pokerBg:getContentSize().height/2))
            subTitleLb:setPosition(ccp(bgW/2,pokerBg:getContentSize().height/2))
        end
    end
end

function ladderDialog:addFlameBorder(pokerIcon,scaleY)
    local posY=pokerIcon:getPositionY()
    local posX=pokerIcon:getPositionX()
    local picWidth=pokerIcon:getContentSize().width
    local picHeight=pokerIcon:getContentSize().height
    local borderFlame1 = CCParticleSystemQuad:create("worldWar/fireBorder.plist")
    borderFlame1.positionType=kCCPositionTypeFree
    borderFlame1:setPosition(ccp(picWidth/2,picHeight-5))
    -- borderFlame1:setPosition(ccp(picWidth/2,posY - picHeight))
    borderFlame1:setScaleX(0.7)
    pokerIcon:addChild(borderFlame1,1)
    local borderFlame2 = CCParticleSystemQuad:create("worldWar/fireBorder.plist")
    borderFlame2.positionType=kCCPositionTypeFree
    -- borderFlame2:setPosition(ccp(picWidth/2,posY+5))
    borderFlame2:setPosition(ccp(picWidth/2,0))
    borderFlame2:setScaleX(0.7)
    pokerIcon:addChild(borderFlame2,1)
    local borderFlame3 = CCParticleSystemQuad:create("worldWar/fireBorderVertical.plist")
    borderFlame3.positionType=kCCPositionTypeFree
    borderFlame3:setPosition(ccp(0,picHeight/2))
    borderFlame3:setScaleY(0.8)
    pokerIcon:addChild(borderFlame3,1)
    local borderFlame4 = CCParticleSystemQuad:create("worldWar/fireBorderVertical.plist")
    borderFlame4.positionType=kCCPositionTypeFree
    borderFlame4:setPosition(ccp(picWidth,picHeight/2))
    borderFlame4:setScaleY(0.8)
    pokerIcon:addChild(borderFlame4,1)
    self.flameTb={borderFlame1,borderFlame2,borderFlame3,borderFlame4}
end

function ladderDialog:initAllButton()
    local function clickBtnHandler(tag,object)
        if tag==20 then
            ladderVoApi:openHOFDialog(self.layerNum+1)
        elseif tag==21 then
            ladderVoApi:openLadderRankDialog(self.layerNum+1)
        elseif tag==22 then
            ladderVoApi:openLadderShopDialog(self.layerNum+1)
        end
    end
    local btnMenu = CCMenu:create()
    local hallOfFameBtn= GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",clickBtnHandler,2,getlocal("hallOfFame"),25)
    hallOfFameBtn:setScale(0.9)
    btnMenu:addChild(hallOfFameBtn)
    hallOfFameBtn:setTag(20)
    local rankBtn= GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",clickBtnHandler,2,getlocal("rank",{canSweepNum}),25,11)
    btnMenu:addChild(rankBtn)
    rankBtn:setTag(21)
    rankBtn:setScale(0.9)
    local marketBtn= GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",clickBtnHandler,2,getlocal("market"),25,11)
    btnMenu:addChild(marketBtn)
    marketBtn:setTag(22)
    marketBtn:setScale(0.9)
    
    btnMenu:alignItemsHorizontallyWithPadding(50)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(btnMenu)
    btnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2, 58))
end

function ladderDialog:tick()
    self.warlist=ladderVoApi:getAllServerWarList()
    local index = 0
    for k,v in pairs(self.warlist) do
        index=index+1
        if self["descLb"..index] then
            self["descLb"..index]:setString(v.state)
            self["descLb"..index]:setColor(v.stateColor)
        end
    end
end

function ladderDialog:dispose()
    if self and self.bgLayer then
          self.bgLayer:removeFromParentAndCleanup(true)
          self.bgLayer=nil
      end
    self = nil
end