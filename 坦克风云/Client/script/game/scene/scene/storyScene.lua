require "luascript/script/game/gamemodel/checkPoint/checkPointVoApi"

storyScene={
	bgLayer,
    clayer,
    sceneSp,
    touchArr={},
    multTouch=false,
    firstOldPos,
    secondOldPos,
    --startPos=ccp(0,100),
    --topPos=ccp(0,-100),
    startPos=ccp(0,0),
    topPos=ccp(0,0),
    minScale=0.8,
    maxScale=1.3,
    isMoving=false,
    isZooming=false,
    autoMoveAddPos,
    zoomMidPosForWorld,
    zoomMidPosForSceneSp,
    touchEnable=true,
    isMoved=false, 
	
	closeBtn=nil,
	checkPointTab={},
	pointerSp,
    beforeHideIsShow=false, 
    checkPointDialog={},
    isShowed=false,
    lastTouchDownPoint=ccp(0,0),
	touchEnabledSp=nil,
    headSprie=nil,
    iconTab={},
    isShow=false,
    mapMoveDisPos=ccp(0,0),
    startDeaccleary=false,
    pointerPos=ccp(0,0),

}
--convertToWorldSpace
--convertToNodeSpace
--ccpMidpoint
function storyScene:show()
    self.isShow=true
    setmetatable(self.checkPointDialog,{__mode="kv"})
	self.bgLayer=CCLayer:create()
    self.clayer=CCLayer:create()

    local mapScaleY,mapOffsetH=1,0
    if G_getIphoneType()==G_iphone5 then
        mapScaleY=1.17
        mapOffsetH=50
    elseif G_getIphoneType()==G_iphoneX then
        mapScaleY=1.3
        mapOffsetH=130
    end
    self.mapOffsetH=mapOffsetH
    self.layerWidth=0
    self.boundingBoxWidth=0

    --self.sceneSp=CCSprite:createWithSpriteFrameName("story_background1.jpg")
    self.sceneSp=CCSprite:create("story/CheckpointBg.jpg")
    self.sceneSp:setAnchorPoint(ccp(0,0))
    self.sceneSp:setPosition(ccp(0,0))
    self.sceneSp:setScaleY(mapScaleY)
	self.clayer:addChild(self.sceneSp,1)
    self.layerWidth=self.layerWidth+self.sceneSp:getContentSize().width
    self.boundingBoxWidth=self.boundingBoxWidth+self.sceneSp:boundingBox().size.width


    -- local cpNum=checkPointVoApi:getCheckPointNum()
    -- local checkPointCfg = checkPointVoApi:getCfgBySid(cpNum)
    -- if checkPointCfg.mapNum and checkPointCfg.mapNum>=2 then
    --     --self.sceneSp2=CCSprite:createWithSpriteFrameName("story_background2.jpg")
    --     self.sceneSp2=CCSprite:create("story/CheckpointBg.jpg")
    --     self.sceneSp2:setAnchorPoint(ccp(0,0))
    --     self.sceneSp2:setPosition(ccp(self.sceneSp:getContentSize().width,0))
    --     self.clayer:addChild(self.sceneSp2,1)
    --     self.layerWidth=self.layerWidth+self.sceneSp2:getContentSize().width
    --     self.boundingBoxWidth=self.boundingBoxWidth+self.sceneSp2:boundingBox().size.width
    -- end
    -- if checkPointCfg.mapNum and checkPointCfg.mapNum>=3 then
    --     self.sceneSp3=CCSprite:create("story/CheckpointBg.jpg")
    --     self.sceneSp3:setAnchorPoint(ccp(0,0))
    --     self.sceneSp3:setPosition(ccp(self.sceneSp:getContentSize().width+self.sceneSp2:getContentSize().width,0))
    --     self.clayer:addChild(self.sceneSp3,1)
    --     self.layerWidth=self.layerWidth+self.sceneSp3:getContentSize().width
    --     self.boundingBoxWidth=self.boundingBoxWidth+self.sceneSp3:boundingBox().size.width
    -- end

    -- if G_isIphone5()==true then
    --     if self.sceneSp then
    --         self.sceneSp:setScaleY(1.17)
    --     end
    --     if self.sceneSp2 then
    --         self.sceneSp2:setScaleY(1.17)
    --     end
    --     if self.sceneSp3 then
    --         self.sceneSp3:setScaleY(1.17)
    --     end
    -- end

    print("checkPointVoApi:getCheckPointNum()",checkPointVoApi:getCheckPointNum())
    local cpNum=checkPointVoApi:getCheckPointNum()
    local checkPointCfg = checkPointVoApi:getCfgBySid(cpNum)
    local mapNumCfg=checkPointCfg.mapNum
    local mapNum=math.ceil(mapNumCfg)
    if mapNum and mapNum>=2 then
        for i=2,mapNum do
            self["sceneSp"..i]=CCSprite:create("story/CheckpointBg.jpg")
            self["sceneSp"..i]:setAnchorPoint(ccp(0,0))
            self["sceneSp"..i]:setPosition(ccp(self.sceneSp:getContentSize().width*(i-1),0))
            self["sceneSp"..i]:setScaleY(mapScaleY)
            self.clayer:addChild(self["sceneSp"..i],1)
            local per=mapNumCfg-math.floor(mapNumCfg)
            if i==mapNum and per>0 then
                self.layerWidth=self.layerWidth+self["sceneSp"..i]:getContentSize().width*per
                self.boundingBoxWidth=self.boundingBoxWidth+self["sceneSp"..i]:boundingBox().size.width*per
            else
                self.layerWidth=self.layerWidth+self["sceneSp"..i]:getContentSize().width
                self.boundingBoxWidth=self.boundingBoxWidth+self["sceneSp"..i]:boundingBox().size.width
            end
        end
    end
    
    self.clayer:setContentSize(CCSizeMake(self.layerWidth,self.sceneSp:getContentSize().height))
    self.clayer:setPosition(self.startPos)
	self.bgLayer:addChild(self.clayer,3)
    
    self.clayer:setTouchEnabled(true)
    --self.sceneSp:setScale(self.minScale)
	--self.sceneSp2:setScale(self.minScale)
    local function tmpHandler(...)
       return self:touchEvent(...)
    end

    --self.clayer:registerScriptTouchHandler(tmpHandler,false,-1,false)
	self.clayer:registerScriptTouchHandler(tmpHandler,false,-52,true)
	self.clayer:setTouchPriority(-52)
	
    local function close()
        PlayEffect(audioCfg.mouseClick)
        if newGuidMgr:isNewGuiding()==true then
                    newGuidMgr:toNextStep()
        end
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(1,0))

    closeBtnItem:registerScriptTapHandler(close)
    closeBtnItem:setScaleX(0.9)

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-54)
    if G_isIphone5()==true then
        self.closeBtn:setPosition(ccp(G_VisibleSize.width,G_VisibleSize.height-closeBtnItem:getContentSize().height))
    else
        self.closeBtn:setPosition(ccp(G_VisibleSize.width,G_VisibleSize.height-closeBtnItem:getContentSize().height))
    end
	self.bgLayer:addChild(self.closeBtn,10)
    -- self.closeBtn:setPosition(ccp(self.headSprie:getContentSize().width-closeBtnItem:getContentSize().width,self.headSprie:getContentSize().height/2))
    -- self.headSprie:addChild(self.closeBtn,1)

	sceneGame:addChild(self.bgLayer,3)
	self.bgLayer:setTouchPriority(-51)
	
	local function touch()
	end
	--self.touchEnabledSp=CCLayer:create()
	self.touchEnabledSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
    self.touchEnabledSp:setAnchorPoint(ccp(0,0))
	self.touchEnabledSp:setContentSize(CCSizeMake(self.layerWidth,self.sceneSp:getContentSize().height))
    self.touchEnabledSp:setPosition(self.startPos)
	--self.touchEnabledSp:setTouchEnabled(true)
	self.touchEnabledSp:setIsSallow(true)
	self.touchEnabledSp:setTouchPriority(-51)
	sceneGame:addChild(self.touchEnabledSp,3)
	self.touchEnabledSp:setOpacity(0)

    self:initCheckPoint()
    self.isShowed=true

    self:updateHeadTech()
end

function storyScene:updateHeadTech()
    local techFlag=checkPointVoApi:getTechFlag()
    if techFlag==-1 then
        local function challengeRewardlistCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                self:showHeadTech()
                checkPointVoApi:setTechFlag(1)
            end
        end
        socketHelper:challengeRewardlist(challengeRewardlistCallback)
    else
        self:showHeadTech()
    end
end

function storyScene:showHeadTech()
    if self then
        if self.headSprie==nil then
            local function tmpClick()
            end
            self.headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),tmpClick)
            self.headSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth, 90))
            self.headSprie:ignoreAnchorPointForPosition(false)
            self.headSprie:setAnchorPoint(ccp(0,1))
            self.headSprie:setIsSallow(false)
            self.headSprie:setTouchPriority(-51)
            self.headSprie:setPosition(ccp(0,G_VisibleSizeHeight))
            self.bgLayer:addChild(self.headSprie,6)


            local challengeTechCfg=checkPointVoApi:getChallengeTechCfg()
            if challengeTechCfg then
                for k,v in pairs(challengeTechCfg) do
                    local index=tonumber(v.cid)
                    if index then
                        local function showTechInfo(object,name,tag)
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            if self.touchEnable==false then
                                do return end
                            end
                            PlayEffect(audioCfg.mouseClick)
                            -- 旧的
                            -- smallDialog:showTechInfoDialog("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,4,k)
                            -- 新的
                            checkPointVoApi:showStroyTechInfo(4,true,true,"",k)


                        end
                        local size=75
                        local icon=LuaCCSprite:createWithSpriteFrameName(v.icon,showTechInfo)
                        local scale=size/icon:getContentSize().width
                        icon:setPosition(ccp(5+size/2+(index-1)*size,self.headSprie:getContentSize().height/2))
                        icon:setScale(scale)
                        icon:setTouchPriority(-53)
                        self.headSprie:addChild(icon,1)
                        self.iconTab[index]=icon
                        -- table.insert(self.iconTab,icon)


                        local unlock,level=checkPointVoApi:getTechIsEffect(index)
                        print("unlockunlockunlock",unlock,level)
                        local function tmpFunc()
                        end
                        local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
                        maskSp:setOpacity(255)
                        local spSize=CCSizeMake(icon:getContentSize().width,icon:getContentSize().height)
                        maskSp:setContentSize(spSize)
                        maskSp:setPosition(getCenterPoint(icon))
                        maskSp:setTag(11)
                        icon:addChild(maskSp,2)
                        if unlock==true then
                            maskSp:setVisible(false)
                        else
                            maskSp:setVisible(true)
                        end
                    end
                end
            end
        end
        if self.iconTab and SizeOfTable(self.iconTab)>0 then
            for k,v in pairs(self.iconTab) do
                if v then
                    local icon=tolua.cast(v,"LuaCCSprite")
                    if icon then
                        local maskSp=tolua.cast(icon:getChildByTag(11),"LuaCCScale9Sprite")
                        if maskSp then
                            local unlock=checkPointVoApi:getTechIsEffect(k) 
                            if unlock==true then
                                maskSp:setVisible(false)
                            else
                                maskSp:setVisible(true)
                            end
                        end
                    end
                end
            end
        end
    end
end

function storyScene:touchEvent(fn,x,y,touch)
    if fn=="began" then
        if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 or newGuidMgr:isNewGuiding()==true then
             return 0
        end
        self.isMoved=false
        self.startDeaccleary=false
        self.touchArr[touch]=touch
        local touchIndex=0
        for k,v in pairs(self.touchArr) do
            local temTouch= tolua.cast(v,"CCTouch")
            if self and temTouch then
                if touchIndex==0 then
                     self.firstOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                else
                     self.secondOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
                end
            end
            touchIndex=touchIndex+1
        end
        if touchIndex==1 then
            self.secondOldPos=nil
            self.lastTouchDownPoint=self.firstOldPos
        end
        if SizeOfTable(self.touchArr)>1 then
            self.multTouch=true
        else
            self.multTouch=false
        end
        return 1
    elseif fn=="moved" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
             do
                return
             end
        end
        self.isMoved=true
        if self.multTouch==true then --双点触摸

        else --单点触摸
             local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
             local moveDisPos=ccpSub(curPos,self.firstOldPos)
             local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
             self.mapMoveDisPos=moveDisPos
              if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<20 then
                 self.isMoved=false
                 do
                    return
                 end
             end
             --self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,(curPos.y-self.firstOldPos.y)*3)
             self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,0)
             if self.clayer == nil then
                do return end
             end
             local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),ccp(moveDisPos.x,0))
             self.clayer:setPosition(tmpPos)
             self:checkBound()
             self.firstOldPos=curPos
             self.isMoving=true
        end
    elseif fn=="ended" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
             do
                return
             end
        end
       if self.touchArr[touch]~=nil then
           self.touchArr[touch]=nil
           local touchIndex=0
            for k,v in pairs(self.touchArr) do
                local tmpTouch=tolua.cast(v,"CCTouch")
                if tmpTouch then
                    if touchIndex==0 then
                         self.firstOldPos=CCDirector:sharedDirector():convertToGL(tmpTouch:getLocationInView())
                    else
                         self.secondOldPos=CCDirector:sharedDirector():convertToGL(tmpTouch:getLocationInView())
                    end
                    touchIndex=touchIndex+1
                end
            end
            if touchIndex==1 then
                self.secondOldPos=nil
            end
            if SizeOfTable(self.touchArr)>1 then
                self.multTouch=true
            else
                self.multTouch=false
            end
       end
       if  self.isMoving==true then
            self.isMoving=false
            self.startDeaccleary=true
            --[[
            local tmpToPos=ccpAdd(ccp(self.clayer:getPosition()),self.autoMoveAddPos)
            tmpToPos=self:checkBound(tmpToPos)

            local ccmoveTo=CCMoveTo:create(0.15,tmpToPos)
            local cceaseOut=CCEaseOut:create(ccmoveTo,3)
            self.clayer:runAction(cceaseOut)
            ]]
       end
    else
        self.touchArr=nil
        self.touchArr={}
    end
end

function storyScene:fastTick()
    if self.startDeaccleary==true then --缓动减速效果
    
         self.mapMoveDisPos=ccpMult(self.mapMoveDisPos,0.9)
         
             self.mapMoveDisPos.y=0
             local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),self.mapMoveDisPos)

             if tmpPos.x>0 then
                tmpPos.x=0
                self.mapMoveDisPos.x=0
             elseif tmpPos.x<(G_VisibleSize.width-self.boundingBoxWidth) then
                tmpPos.x=G_VisibleSize.width-self.boundingBoxWidth
                self.mapMoveDisPos.x=0
             end
             
         
         self.clayer:setPosition(ccpAdd(ccp(self.clayer:getPosition()),self.mapMoveDisPos))
         
         if  (math.abs(self.mapMoveDisPos.x)+math.abs(self.mapMoveDisPos.y))<1 then
                self.startDeaccleary=false
         end
    end

end


function storyScene:checkBound(pos)
		local tmpPos
		if pos==nil then
		   	tmpPos= ccp(self.clayer:getPosition())
		else
		   	tmpPos=pos
		end
		if tmpPos.x>0 then
		    tmpPos.x=0
		elseif tmpPos.x<(G_VisibleSize.width-(self.boundingBoxWidth)) then
		   	tmpPos.x=G_VisibleSize.width-(self.boundingBoxWidth)
		end
     	
            --[[	
		if tmpPos.y>=self.startPos.y then
		    tmpPos.y=self.startPos.y
		elseif tmpPos.y<(G_VisibleSize.height-self.sceneSp:boundingBox().size.height+self.topPos.y)  then
		    tmpPos.y=G_VisibleSize.height-self.sceneSp:boundingBox().size.height+self.topPos.y
		end
        ]]
		if pos==nil then
		   	self.clayer:setPosition(tmpPos)
		else
		   	return tmpPos
		end
end

function storyScene:focusOn()
    local y=G_VisibleSize.height/2-self.sceneSp:boundingBox().size.height/2
	local x=G_VisibleSize.width/2-checkPointVoApi:getCfgBySid(checkPointVoApi:getUnlockSid()).x
    self.clayer:setPosition(ccp(x,y))
    self:checkBound()
end

function storyScene:setShow(focusPoint)
    base:setWait()
    if self.bgLayer==nil then
        self:show()
	else
		self:refresh()
    end
	if self.touchEnabledSp then
		self.touchEnabledSp:setPosition(self.startPos)
	end
    if self.headSprie then
        self.headSprie:setPosition(ccp(0,G_VisibleSizeHeight))
    end
    if(focusPoint==nil)then
    	self:focusOn()
        if(self.pointerSp)then
            self.pointerSp:setPosition(self.pointerPos)
        end
    else
        self.clayer:setPosition(ccp(focusPoint.x,G_VisibleSize.height/2-self.sceneSp:boundingBox().size.height/2))
        self:checkBound()
        if(self.pointerSp)then
            self.pointerSp:setPosition(ccp(focusPoint.x,focusPoint.y+self.pointerSp:getContentSize().height/2+10+self.mapOffsetH))
        end
    end
    self.touchEnable=true
    self.isMoved=false 
    self.bgLayer:setVisible(false)
    self.isShowed=true
    if newGuidMgr:isNewGuiding()==true then
		if self.pointerSp~=nil then
        	self.pointerSp:setVisible(false)
		end
    else
		if self.pointerSp~=nil then
	        self.pointerSp:setVisible(true)
		end
    end
    local fadeIn=CCFadeOutDownTiles:create(0.5,CCSizeMake(16,12))
    local back=fadeIn:reverse()
    

    local function callBack()
            self.bgLayer:setVisible(true)
    end
    local callFunc=CCCallFunc:create(callBack)
    local carray=CCArray:create()
        --carray:addObject(back)
        carray:addObject(callFunc)
    local spawn=CCSpawn:create(carray)

    local function hideUIHandler()
                self.bgLayer:stopAllActions()
                if portScene.clayer~=nil then
                    if sceneController.curIndex==0 then
                        portScene:setHide()
                    elseif sceneController.curIndex==1 then
                        mainLandScene:setHide()
                    elseif sceneController.curIndex==2 then
                        worldScene:setHide()
                    end
                    mainUI:setHide()
                end
                base:cancleWait()
    end
    local hideUIFunc=CCCallFunc:create(hideUIHandler)
    local seq=CCSequence:createWithTwoActions(spawn,hideUIFunc)
    self.bgLayer:runAction(seq)
    table.insert(base.commonDialogOpened_WeakTb,self)
end

function storyScene:setShowWhenEndBattle()
 --    if self.bgLayer==nil then
 --        --self:show()
	-- else
	-- 	self:refresh()
 --        print("self.headSprie~~~~~~~2",self.headSprie)
 --        if self.headSprie and newGuidMgr:isNewGuiding()==false then
 --            self.headSprie:setPosition(ccp(0,G_VisibleSizeHeight))
 --        end
 --    end
    if self.beforeHideIsShow==true then
        self:refresh()
        if self.headSprie and newGuidMgr:isNewGuiding()==false then
            self.headSprie:setPosition(ccp(0,G_VisibleSizeHeight))
        end
        self:focusOn()
        self.touchEnable=true
        self.isMoved=false 
        self.bgLayer:setVisible(true)
        self.isShowed=true
    end
    local flag=false
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
        if v==self then
            flag=true
            break
        end
    end
    if(flag==false)then
        table.insert(base.commonDialogOpened_WeakTb,self)
    end
end
function storyScene:setHide(hasAnim)
    self.isShowed=false
	if self.touchEnabledSp then
		self.touchEnabledSp:setPosition(ccp(0,10000))
	end
    if self.headSprie then
        self.headSprie:setPosition(ccp(0,10000))
    end
    if self.bgLayer~=nil then
		--self.touchEnabledSp:removeFromParentAndCleanup(true)
		--self.touchEnabledSp=nil
		self.touchEnabledSp:setVisible(false)
        base:setWait()
        if self.touchEnable==false then
            self.beforeHideIsShow=false
        else
            self.beforeHideIsShow=true
        end
        self.touchEnable=false
        
        if hasAnim==false then
            self.bgLayer:setVisible(false)
            base:cancleWait()
            base:cancleNetWait()
        else
            --local fadeOut=CCFadeOutDownTiles:create(0.5,CCSizeMake(16,12))
            --local function callBack()
                self.bgLayer:stopAllActions()
                self.bgLayer:setVisible(false)
                base:cancleWait()
           -- end
           -- local callFunc=CCCallFunc:create(callBack)
            --local seq=CCSequence:createWithTwoActions(fadeOut,callFunc)
            --self.bgLayer:runAction(seq)
            if base.allShowedCommonDialog==0 then
            
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
        end
        
        
    end
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
        if v==self then
            table.remove(base.commonDialogOpened_WeakTb,k)
            break
        end
    end
end

function storyScene:initCheckPoint()
	local function clickHandler(object,name,tag)
		self:clickCheckPointHandler(object,name,tag)
    end

	self.pointerSp=CCSprite:createWithSpriteFrameName("ArowShape.png")
	--[[
    if newGuidMgr:isNewGuiding()==true then
        self.pointerSp:setVisible(false)
    else
        self.pointerSp:setVisible(true)
    end
	]]
	self.pointerSp:setPosition(ccp(0,0))
	self.clayer:addChild(self.pointerSp,3)
	--self.pointerSp:setRotation(180)
    --local up=CCMoveBy:create(0.5,CCPointMake(0,50))
	--local down=CCMoveBy:create(0.5,CCPointMake(0,-50))
    local up=CCMoveBy:create(0.35,CCPointMake(0,50/2))
	local down=CCMoveBy:create(0.35,CCPointMake(0,-50/2))
    local seq=CCSequence:createWithTwoActions(up,down)
    self.pointerSp:runAction(CCRepeatForever:create(seq))
	
	for i=1,checkPointVoApi:getCheckPointNum() do
		local checkPointSp
		local lockSp
		local rankSp
		local starLabelBg
		local starLabel
		local star
		local starNum = 0
		local checkPointCfg = checkPointVoApi:getCfgBySid(i)
		local checkPointVo = checkPointVoApi:getCheckPointVoBySid(i)

		local arowData=checkPointCfg.arow
		if arowData~=nil and i~=checkPointVoApi:getCheckPointNum() then
			local arowX,arowY,arowRotation=arowData.x,arowData.y,arowData.rotation
			if arowX~=nil and arowY~=nil and arowRotation~=nil then
				local arowSp=CCSprite:create("story/CheckPointArow.png")
				--local arowSp=CCSprite:createWithSpriteFrameName("CheckPointArow.png")
			    --arowSp:setAnchorPoint(ccp(0,0))
			    arowSp:setPosition(ccp(arowX,arowY+self.mapOffsetH))
				arowSp:setRotation(arowRotation)
				self.clayer:addChild(arowSp,1)
			end
		end

        if not (checkPointVo and checkPointVo.isUnlock) then
            checkPointSp=GraySprite:createWithSpriteFrameName(checkPointCfg.mapIcon)
            checkPointSp:setPosition(ccp(checkPointCfg.x,checkPointCfg.y+self.mapOffsetH))
            checkPointSp:setTag(i)
        else
            checkPointSp=LuaCCSprite:createWithSpriteFrameName(checkPointCfg.mapIcon,clickHandler)
            checkPointSp:setPosition(ccp(checkPointCfg.x,checkPointCfg.y+self.mapOffsetH))
            checkPointSp:setTag(i)
            
            checkPointSp:setTouchPriority(-53)
            checkPointSp:setIsSallow(false)
        end
        self.clayer:addChild(checkPointSp,2)

        if i==1 then
            local nextStepId=newGuidCfg[newGuidMgr.curStep].toStepId
            newGuidMgr:setGuideStepField(nextStepId,checkPointSp,false)
        end
        
		table.insert(self.checkPointTab,i,{checkPointSp=checkPointSp})

		if not (checkPointVo and checkPointVo.isUnlock) then
			lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
		    lockSp:setPosition(ccp(checkPointCfg.x,checkPointCfg.y+self.mapOffsetH))
			self.clayer:addChild(lockSp,2)
			--table.insert(self.checkPointTab[i],{lockSp=lockSp})
			self.checkPointTab[i].lockSp=lockSp
		end
		
		rankSp=CCSprite:createWithSpriteFrameName(checkPointCfg.style)
	    rankSp:setPosition(ccp(checkPointCfg.x-65,checkPointCfg.y-checkPointSp:getContentSize().height/2-10+self.mapOffsetH))
		self.clayer:addChild(rankSp,2)
        
		if rankSp:getContentSize().width>=36 then
			rankSp:setScaleX(0.6)
			rankSp:setScaleY(0.6)
		end
        
	    local rect = CCRect(0, 0, 50, 50)
	    local capInSet = CCRect(20, 20, 10, 10)
	    local function cellClick(hd,fn,idx)
	    end
	    starLabelBg =LuaCCScale9Sprite:createWithSpriteFrameName("StarIconBg.png",capInSet,cellClick)
	    starLabelBg:setContentSize(CCSizeMake(90, 35))
	    starLabelBg:ignoreAnchorPointForPosition(false)
	    starLabelBg:setIsSallow(false)
	    starLabelBg:setTouchPriority(-52)
		starLabelBg:setPosition(ccp(checkPointCfg.x,checkPointCfg.y-checkPointSp:getContentSize().height/2-10+self.mapOffsetH))
		self.clayer:addChild(starLabelBg,2)
		if checkPointVo and checkPointVo.starNum then
			starNum=checkPointVo.starNum
		else
			starNum=0
		end
	    starLabel=GetTTFLabel(getlocal("scheduleChapter",{starNum,checkPointVoApi:getCheckPointStarNum()}),24,true)
	    starLabel:setPosition(getCenterPoint(starLabelBg))
	    starLabel:setColor(G_ColorYellow)
		starLabelBg:addChild(starLabel)
		--table.insert(self.checkPointTab[i],{starLabel=starLabel})
		self.checkPointTab[i].starLabel=starLabel

		star=CCSprite:createWithSpriteFrameName("StarIcon.png")
	    star:setPosition(ccp(checkPointCfg.x+70,checkPointCfg.y-checkPointSp:getContentSize().height/2-10+self.mapOffsetH))
		self.clayer:addChild(star,2)
		
		if i==tonumber(checkPointVoApi:getUnlockSid()) then
            self.pointerPos=ccp(checkPointCfg.x,checkPointCfg.y+checkPointSp:getContentSize().height/2+10+self.mapOffsetH)
			self.pointerSp:setPosition(self.pointerPos)
		end
	end
end

function storyScene:refresh()
	local starNum
	for i=1,checkPointVoApi:getCheckPointNum() do
		starNum=0
		local checkPointCfg = checkPointVoApi:getCfgBySid(i)
		local checkPointVo = checkPointVoApi:getCheckPointVoBySid(i)
		if self.checkPointTab[i] and checkPointVo then
			if self.checkPointTab[i].lockSp and checkPointVo.isUnlock then
				self.checkPointTab[i].lockSp:setVisible(false)
				
				if self.checkPointTab[i].checkPointSp then
					self.clayer:removeChild(self.checkPointTab[i].checkPointSp,true)
					self.checkPointTab[i].checkPointSp=nil
					local function clickHandler(object,name,tag)
						self:clickCheckPointHandler(object,name,tag)
					end
		            self.checkPointTab[i].checkPointSp=LuaCCSprite:createWithSpriteFrameName(checkPointCfg.mapIcon,clickHandler)
		            self.checkPointTab[i].checkPointSp:setPosition(ccp(checkPointCfg.x,checkPointCfg.y+self.mapOffsetH))
		            self.checkPointTab[i].checkPointSp:setTouchPriority(-53)
		            self.checkPointTab[i].checkPointSp:setIsSallow(false)
					self.checkPointTab[i].checkPointSp:setTag(i)
					self.clayer:addChild(self.checkPointTab[i].checkPointSp,2)
				end
			end
			if checkPointVo.starNum then
				starNum=checkPointVo.starNum
			end
			self.checkPointTab[i].starLabel:setString(getlocal("scheduleChapter",{starNum,checkPointVoApi:getCheckPointStarNum()}))
			if i==tonumber(checkPointVoApi:getUnlockSid()) then
                self.pointerPos=ccp(checkPointCfg.x,checkPointCfg.y+self.checkPointTab[i].checkPointSp:getContentSize().height/2+10+self.mapOffsetH)
				self.pointerSp:setPosition(self.pointerPos)
			end
		end
	end

    self:updateHeadTech()
end

function storyScene:clickCheckPointHandler(object,name,tag)

    if self.isMoved==true or self.touchEnable==false then
		return
    end
    PlayEffect(audioCfg.mouseClick)
	local checkPoint=checkPointVoApi:getCheckPointVoBySid(tostring(tag))
	if checkPoint and checkPoint.isUnlock then
        if math.abs(G_getCurDeviceMillTime()-base.setWaitTime)<=100 then
              do
                    return
              end
        end
        base:setWait()
        local delayAction=CCDelayTime:create(0.6)
        local fadeOut=CCTintTo:create(0.3,80,80,80)
        local fadeIn=CCTintTo:create(0.3,255,255,255)
        local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
        self.checkPointTab[tag].checkPointSp:runAction(seq)
        local function callBack(...)
            base:cancleWait()
            require "luascript/script/game/scene/gamedialog/checkPointDialog"
		    local cpd = checkPointDialog:new(tag)
                
            self.checkPointDialog[1]=cpd

		    local cd = cpd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("checkPoint"),true,4)

		    sceneGame:addChild(cd,4)
             if newGuidMgr:isNewGuiding() then --新手引导
                            newGuidMgr:toNextStep()
             end
        end
        local callFunc=CCCallFunc:create(callBack)
        local seq3=CCSequence:createWithTwoActions(delayAction,callFunc)
        self.checkPointTab[tag].checkPointSp:runAction(seq3)
	end
end

function storyScene:close()
	self:setHide()
    self.isShow=false
end

function storyScene:realClose()
    self:setHide()
end

function storyScene:dispose()
    if self.touchEnabledSp then
        self.touchEnabledSp:removeFromParentAndCleanup(true)
        self.touchEnabledSp=nil
    end
    self.bgLayer=nil
    self.clayer=nil
    self.sceneSp=nil
    self.touchArr={}
    self.multTouch=false
    self.firstOldPos=nil
    self.secondOldPos=nil
    --startPos=ccp(0,100)
    --topPos=ccp(0,-100)
    self.startPos=ccp(0,0)
    self.topPos=ccp(0,0)
    self.minScale=0.8
    self.maxScale=1.3
    self.isMoving=false
    self.isZooming=false
    self.autoMoveAddPos=nil
    self.zoomMidPosForWorld=nil
    self.zoomMidPosForSceneSp=nil
    self.touchEnable=true
    self.isMoved=false
	self.closeBtn=nil
	self.checkPointTab={}
	self.pointerSp=nil
    self.beforeHideIsShow=false
    self.checkPointDialog={}
    self.headSprie=nil
    self.iconTab={}
    self.mapOffsetH=0
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
        if v==self then
            table.remove(base.commonDialogOpened_WeakTb,k)
            break
        end
    end
end
