local believerSeasonRewardTab={}

function believerSeasonRewardTab:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	
	return nc
end

function believerSeasonRewardTab:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initLayer()

    return self.bgLayer
end

function believerSeasonRewardTab:initLayer()
	local believerCfg=believerVoApi:getBelieverCfg()
    self.cellNum=SizeOfTable(believerCfg.seasonReward)
    self.seasonRewardList={}
    for k,v in pairs(believerCfg.seasonReward) do
 		local rewardCfg=v[1]
    	self.seasonRewardList[k]={kcoin=rewardCfg[1],extra=FormatItem(rewardCfg[2])}
    end

    local fontSize=25
    local promptLb=GetTTFLabelWrap(getlocal("believer_reward_season_prompt"),fontSize,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    promptLb:setAnchorPoint(ccp(0.5,0.5))
    promptLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-190))
    self.bgLayer:addChild(promptLb)

    local function infoHandler()
    	local tabStr={}
    	for i=1,3 do
    		table.insert(tabStr,getlocal("believer_reward_season_info_"..i))
    	end
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
    G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth-60,promptLb:getPositionY()),{},nil,nil,28,infoHandler,true)

	self.tvWidth,self.tvHeight,self.cellHeight=G_VisibleSizeWidth-50,G_VisibleSizeHeight-450,170
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight+10))
    tvBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-220)
    self.bgLayer:addChild(tvBg)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,tvBg:getPositionY()-self.tvHeight-5)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local grade,queue=believerVoApi:getMySegment()
    local iconWidth=150
   	local mySegIconSp=believerVoApi:getSegmentIcon(grade,queue)
    if mySegIconSp then
        mySegIconSp:setScale(iconWidth/mySegIconSp:getContentSize().width)
        mySegIconSp:setPosition(30+iconWidth/2,30+iconWidth/2)
        self.bgLayer:addChild(mySegIconSp,2)

     --    local segNameStr=believerVoApi:getSegmentName(grade,queue)
     --    local segmentLb=GetTTFLabelWrap(segNameStr,fontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    	-- segmentLb:setPosition(mySegIconSp:getPositionX(),mySegIconSp:getPositionY()-iconWidth/2-segmentLb:getContentSize().height/2+5)
    	-- self.bgLayer:addChild(segmentLb)

        local mySegPromptLb=GetTTFLabelWrap(getlocal("believer_myseg"),fontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    	mySegPromptLb:setPosition(mySegIconSp:getPositionX(),mySegIconSp:getPositionY()+iconWidth/2+mySegPromptLb:getContentSize().height/2-10)
    	self.bgLayer:addChild(mySegPromptLb)

        local rewardPosX,rewardPosY=G_VisibleSizeWidth-150,mySegIconSp:getPositionY()+20
        local function getHandler()
            if believerVoApi:checkSeasonStatus()==2 then
                local function getCallBack()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),28)
                    local grade=believerVoApi:getMySegment()
                    local rewardItem=self.seasonRewardList[grade]
                    if rewardItem and rewardItem.extra then
                        for k,v in pairs(rewardItem.extra) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num)
                        end
                    end
                    self:refreshSeasonRewardState()
                    if self.parent and self.parent.refreshRedTip then
                        self.parent:refreshRedTip(3)
                    end
                end
                believerVoApi:getRewardRequest(3,{grade=grade,queue=queue},getCallBack)
            else
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_reward_season_get_prompt"),28)
            end
        end
        local priority=-(self.layerNum-1)*20-4
        local rewardBoxSp=LuaCCSprite:createWithSpriteFrameName("believerBoxClosed.png",getHandler)
        rewardBoxSp:setTouchPriority(priority)
        rewardBoxSp:setScale(0.6)
        rewardBoxSp:setPosition(rewardPosX,rewardPosY)
        self.bgLayer:addChild(rewardBoxSp,2)
        self.rewardBoxSp=rewardBoxSp

        self:refreshSeasonRewardState()
    end
end

function believerSeasonRewardTab:refreshSeasonRewardState()
    if self.rewardBoxSp==nil then
        do return end
    end
    local flag=believerVoApi:getSeasonRewardFlag()
    if flag==-1 then --不可领取
        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("believerBoxClosed.png")
        if frame then
            self.rewardBoxSp:setDisplayFrame(frame)
        end
        if self.guangSp1 and self.guangSp2 then
            self.guangSp1:removeFromParentAndCleanup(true)
            self.guangSp1=nil
            self.guangSp2:removeFromParentAndCleanup(true)
            self.guangSp2=nil
        end
        if self.hasRewardBg and self.hasRewardLb then
            self.hasRewardBg:setVisible(false)
            self.hasRewardLb:setVisible(false)
        end
    elseif flag==0 then --可领取
        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("believerBoxClosed.png")
        if frame then
            self.rewardBoxSp:setDisplayFrame(frame)
        end
        if self.guangSp1 and self.guangSp2 then
            self.guangSp1:setVisible(true)
            self.guangSp2:setVisible(true)
        else
            self.guangSp1,self.guangSp2=G_playShineEffect(self.bgLayer,ccp(self.rewardBoxSp:getPosition()),1)
        end
        if self.hasRewardBg and self.hasRewardLb then
            self.hasRewardBg:setVisible(false)
            self.hasRewardLb:setVisible(false)
        end
    else --已领取
        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("believerBoxOpened.png")
        if frame then
            self.rewardBoxSp:setDisplayFrame(frame)
        end
        if self.guangSp1 and self.guangSp2 then
            self.guangSp1:setVisible(false)
            self.guangSp2:setVisible(false)
        end
        if self.hasRewardBg and self.hasRewardLb then
            self.hasRewardBg:setVisible(true)
            self.hasRewardLb:setVisible(true)
        else
            local hasRewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
            hasRewardBg:setScaleX(150/hasRewardBg:getContentSize().width)
            hasRewardBg:setPosition(self.rewardBoxSp:getPosition())
            self.bgLayer:addChild(hasRewardBg,4)
            local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),22)
            hasRewardLb:setPosition(self.rewardBoxSp:getPosition())
            self.hasRewardBg=hasRewardBg
            self.hasRewardLb=hasRewardLb
            self.bgLayer:addChild(hasRewardLb,5)    
        end
    end
end

function believerSeasonRewardTab:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.tvWidth,self.cellHeight)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local grade=self.cellNum-idx
        local rewardItem=self.seasonRewardList[grade]
        if rewardItem then
        	local segIconWidth=100
        	local segIconPosX,segIconPosY=10+segIconWidth/2,self.cellHeight/2
            local segIconSp=believerVoApi:getSegmentIcon(grade)
            if segIconSp then
                segIconSp:setScale(segIconWidth/segIconSp:getContentSize().width)
                segIconSp:setPosition(segIconPosX,segIconPosY)
                cell:addChild(segIconSp,2)
            end
            local fontSize=22
            local segNameStr=believerVoApi:getSegmentName(grade)
            local segmentLb=GetTTFLabelWrap(segNameStr,fontSize,CCSizeMake(self.tvWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
            if G_getCurChoseLanguage() == "ar" then
                segmentLb=GetTTFLabelWrap(segNameStr,fontSize,CCSizeMake(self.tvWidth-400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
            end
            segmentLb:setAnchorPoint(ccp(0,0.5))
            segmentLb:setColor(G_ColorHighGreen)
            segmentLb:setPosition(segIconPosX+segIconWidth/2+10,self.cellHeight-segmentLb:getContentSize().height/2-15)
            cell:addChild(segmentLb)

            local rewardLb=GetTTFLabelWrap(getlocal("donateReward"),fontSize-2,CCSizeMake(120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            if G_getCurChoseLanguage() == "ar" then
                rewardLb=GetTTFLabelWrap(getlocal("donateReward"),fontSize-2,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            end
            rewardLb:setAnchorPoint(ccp(0,0.5))
           
            rewardLb:setPosition(ccp(segmentLb:getPositionX(),(self.cellHeight-segmentLb:getContentSize().height-20)/2+15))
           
            cell:addChild(rewardLb)
            local tempLb=GetTTFLabel(getlocal("donateReward"),fontSize)
            local realW=tempLb:getContentSize().width
            if realW>rewardLb:getContentSize().width or G_getCurChoseLanguage() == "ar" then
            	realW=rewardLb:getContentSize().width
            end

            local iconWidth=70
            local rewardPosX,rewardPosY=rewardLb:getPositionX()+realW+10+iconWidth/2,rewardLb:getPositionY()
            if rewardItem.kcoin and tonumber(rewardItem.kcoin)>0 then
                local kCoinSp=CCSprite:createWithSpriteFrameName("believerKcoin.png")
                kCoinSp:setPosition(ccp(rewardPosX,rewardLb:getPositionY()))
                kCoinSp:setScale(0.7)
                cell:addChild(kCoinSp)

                local kcoinNumLb=GetTTFLabelWrap("x"..rewardItem.kcoin,fontSize-2,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                kcoinNumLb:setAnchorPoint(ccp(0.5,1))
                kcoinNumLb:setPosition(kCoinSp:getPositionX(),kCoinSp:getPositionY()-iconWidth/2-2)
                cell:addChild(kcoinNumLb)
                rewardPosX=rewardPosX+iconWidth+10
            end

            for k,item in pairs(rewardItem.extra) do
                local scale=1
                local iconSp
                if item.key=="gems" or item.key=="gem" then
                    iconSp=LuaCCSprite:createWithSpriteFrameName("iconGoldNew1.png",function () end)
                else
                    local function showInfoDialog()
                        G_showNewPropInfo(self.layerNum+1,true,true,nil,item,nil,nil,nil,nil,true)
                        return false
                    end
                    iconSp=G_getItemIcon(item,100,true,self.layerNum+1,showInfoDialog)
                    if item.type=="l" then
                        if item.eType=="c" then
                            scale=0.9
                        elseif item.eType=="h" then
                            scale=0.4
                        end
                    else
                        scale=iconWidth/iconSp:getContentSize().width
                    end
                end
 				iconSp:setScale(scale)
                iconSp:setTouchPriority(-(self.layerNum-1)*20-3)
 				iconSp:setPosition(rewardPosX+(k-1)*(iconWidth+10),rewardPosY)
 				cell:addChild(iconSp)
                local numLb=GetTTFLabel("x"..item.num,fontSize-2)
                numLb:setAnchorPoint(ccp(0.5,1))
                numLb:setPosition(iconSp:getPositionX(),iconSp:getPositionY()-iconWidth/2-2)
                cell:addChild(numLb)
            end

            local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function () end)
            mLine:setContentSize(CCSizeMake(self.tvWidth-20,mLine:getContentSize().height))
            mLine:setPosition(self.tvWidth/2,mLine:getContentSize().height/2)
            cell:addChild(mLine,1)
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

function believerSeasonRewardTab:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.layerNum=nil
    self.parent=nil
    self.tvWidth=nil
    self.tvHeight=nil
    self.cellHeight=nil
    self.seasonRewardList=nil
end

return believerSeasonRewardTab