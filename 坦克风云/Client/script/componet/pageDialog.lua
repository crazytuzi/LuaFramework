pageDialog={}
function pageDialog:new()
    local nc={
            container,
            layerNum,
            leftBtn,
            rightBtn,
            page,
            list,
            isAnimation,
            turnInterval=0.3,   --翻页时间
            callback,

            bgLayer,
            sceneSp,
            touchArr={},
            multTouch=false,
            firstOldPos,
            secondOldPos,
            startPos=ccp(0,0),
            isMoving=false,
            autoMoveAddPos,
            zoomMidPosForWorld,
            zoomMidPosForSceneSp,
            touchEnable=true,
            isMoved=false, 
            lastTouchDownPoint=ccp(0,0),
            touchEnabledSp=nil,
            moveMinDis=50,     --翻页手指滑动距离

          }
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--param callback: 翻页完毕之后的回调函数,可以为nil
--param leftBtnPos: 左按钮的位置,可以为nil
--param rightBtnPos: 右按钮的位置,可以为nil
--specialShowTb:特殊显示 特殊动画使用，第一个位置：判定是否不触发触摸动画，第二个位置：告知使用效果ID，如有添加 自行新增ID (目前ID有：2,3)，第三个位置：传入自己使用的参数
-- 是新手引导页执行 forceE
function pageDialog:create(bgSrc,size,inRect,container,pos,layerNum,page,list,isShowBg,isShowPageBtn,callback,leftBtnPos,rightBtnPos,movedCallback,priority,touchRect,btnPic,isRotation,specialShowTb,moveMinDis,forceE)
    self.container=container
    self.layerNum=layerNum
    self.page=page or 1
    self.list=list or {}
    self.startPos=pos
    self.bgSize=size
    self.callback=callback
    self.touchRect=touchRect
    self.specialShowTb = specialShowTb
    self.forceE=forceE
    if specialShowTb and specialShowTb[1] then
        self.isNoTouch =specialShowTb[1]
    end
    self.movedCallback = movedCallback
    if moveMinDis then
        self.moveMinDis=moveMinDis
    end



    local function touchHander()
        
    end
    -- self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    -- self.bgSize=size
    -- self.bgLayer:setContentSize(size)
    -- self.bgLayer:setIsSallow(false)
    -- self.bgLayer:setTouchPriority(-(layerNum-1)*20-1)
    -- self.bgLayer:setPosition(pos)
    -- container:addChild(self.bgLayer)

    -- self.bgLayer=CCLayer:create()
    self.bgLayer=CCLayer:create()
    self.sceneSp=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    self.sceneSp:setContentSize(size)
    self.sceneSp:setIsSallow(false)
    -- self.sceneSp:setTouchPriority(-(layerNum-1)*20-1)
    -- self.sceneSp:setPosition(self.startPos)
    -- container:addChild(self.sceneSp)

    self.sceneSp:setAnchorPoint(ccp(0,0))
    self.sceneSp:setPosition(ccp(0,0))
    self.bgLayer:addChild(self.sceneSp,1)
    if isShowBg==false then
        self.sceneSp:setOpacity(0)
    end

    if G_isIphone5()==true then
        -- self.sceneSp:setScaleY(1.17)
    end
    self.bgLayer:setContentSize(CCSizeMake(self.sceneSp:getContentSize().width,self.sceneSp:getContentSize().height))
    -- self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:setPosition(self.startPos)
    -- self.bgLayer:addChild(self.bgLayer,3)
    
    self.bgLayer:setTouchEnabled(true)
    --self.sceneSp:setScale(self.minScale)

    local function tmpHandler(...)
       
       if self.isNoTouch ==nil or self.isNoTouch ==false then
             -- print("tmpHandler----~~~~!!!!")
           return self:touchEvent(...)
       end
    end

    --self.bgLayer:registerScriptTouchHandler(tmpHandler,false,-1,false)
    if priority then
        self.bgLayer:registerScriptTouchHandler(tmpHandler,false,priority,false)
        self.bgLayer:setTouchPriority(priority)
    else
        self.bgLayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-2,false)
        self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-2)
    end
    
    self.container:addChild(self.bgLayer)
    -- self.container:addChild(self.bgLayer,3)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    
    local function touch()
    end
    --self.touchEnabledSp=CCLayer:create()
    self.touchEnabledSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
    self.touchEnabledSp:setAnchorPoint(ccp(0,0))
    self.touchEnabledSp:setContentSize(G_VisibleSize)
    self.touchEnabledSp:setPosition(self.startPos)
    self.touchEnabledSp:setIsSallow(true)
    self.touchEnabledSp:setTouchPriority(-(self.layerNum-1)*20-6)
    self.container:addChild(self.touchEnabledSp,3)
    self.touchEnabledSp:setOpacity(0)
    self.touchEnabledSp:setPosition(ccp(10000,0))



    local px,py=pos.x,pos.y

    local tx,ty
    for k,v in pairs(list) do
        if self.page==k then
            v:setVisible(true)
            -- v:setPosition(getCenterPoint(self.bgLayer))
            tx,ty=v:getPosition()
        else
            v:setVisible(false)
            v:setPosition(ccp(10000,0))
        end
    end

    -- local lPos=ccp(self.bgLayer:getContentSize().width/2-self.bgSize.width,self.bgLayer:getContentSize().height/2)
    -- local rPos=ccp(self.bgLayer:getContentSize().width/2+self.bgSize.width,self.bgLayer:getContentSize().height/2)
    self.lPos=ccp(tx-G_VisibleSizeWidth,ty)
    self.rPos=ccp(tx+G_VisibleSizeWidth,ty) 
    self.cPos=ccp(tx,ty)

    if isShowPageBtn==nil then
        isShowPageBtn=true
    end
    if isShowPageBtn==true then
        local function leftPageHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end

            if self.isAnimation==true or (battleScene and battleScene.isBattleing==true) then
                do return end
            end

            PlayEffect(audioCfg.mouseClick)

            self:leftPage()

        end
        local scale=1
        local btnIconStr="leftBtnGreen.png"
        if btnPic then
            btnIconStr=btnPic
        end
        self.leftBtn=GetButtonItem(btnIconStr,btnIconStr,btnIconStr,leftPageHandler,11,nil,nil)
        if isRotation==true then
            self.leftBtn:setRotation(180)
        end
        self.leftBtn:setScale(scale)
        local leftMenu=CCMenu:createWithItem(self.leftBtn)
        leftMenu:setAnchorPoint(ccp(0.5,0.5))
        leftMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        container:addChild(leftMenu,1)
        if(leftBtnPos~=nil)then
            leftMenu:setPosition(leftBtnPos)
        else
            leftMenu:setPosition(ccp(px,py+size.height/2))
        end

        local posX,posY=leftMenu:getPosition()
        local posX2=posX+20

        local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
        local fadeIn=CCFadeIn:create(0.5)
        local carray=CCArray:create()
        carray:addObject(mvTo)
        carray:addObject(fadeIn)
        local spawn=CCSpawn:create(carray)

        local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
        local fadeOut=CCFadeOut:create(0.5)
        local carray2=CCArray:create()
        carray2:addObject(mvTo2)
        carray2:addObject(fadeOut)
        local spawn2=CCSpawn:create(carray2)

        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
        leftMenu:runAction(CCRepeatForever:create(seq))

        local function rightPageHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end

            if self.isAnimation==true or (battleScene and battleScene.isBattleing==true) then
                do return end
            end

            PlayEffect(audioCfg.mouseClick)
            
            self:rightPage()

        end
        self.rightBtn=GetButtonItem(btnIconStr,btnIconStr,btnIconStr,rightPageHandler,11,nil,nil)
        if isRotation==true then
        else
            self.rightBtn:setRotation(180)
        end
        self.rightBtn:setScale(scale)
        local rightMenu=CCMenu:createWithItem(self.rightBtn)
        rightMenu:setAnchorPoint(ccp(0.5,0.5))
        rightMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        -- self.bgLayer:addChild(rightMenu,1)
        container:addChild(rightMenu,1)
        -- rightMenu:setPosition(ccp(px+size.width/2,py))
        if(rightBtnPos~=nil)then
            rightMenu:setPosition(rightBtnPos)
        else
            rightMenu:setPosition(ccp(px+size.width,py+size.height/2))
        end

        local posX,posY=rightMenu:getPosition()
        local posX2=posX-20

        local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
        local fadeIn=CCFadeIn:create(0.5)
        local carray=CCArray:create()
        carray:addObject(mvTo)
        carray:addObject(fadeIn)
        local spawn=CCSpawn:create(carray)

        local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
        local fadeOut=CCFadeOut:create(0.5)
        local carray2=CCArray:create()
        carray2:addObject(mvTo2)
        carray2:addObject(fadeOut)
        local spawn2=CCSpawn:create(carray2)

        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
        rightMenu:runAction(CCRepeatForever:create(seq))
    end

    self.touchEnable=true
    self.isMoved=false 

    if specialShowTb then 
        if specialShowTb[2] ==2 then
            self:UseIconBtnChoosePage()
        elseif specialShowTb[2] ==3 then
            self:UseIconBtnChooseSecondPage()
        end
    end
    return self.bgLayer
end

function pageDialog:touchEvent(fn,x,y,touch)
    if fn=="began" then
        if self.forceE then
           if self.touchEnable==false or SizeOfTable(self.touchArr)>=1  or self.isAnimation==true or (battleScene and battleScene.isBattleing==true) then
                 return 0
            end
        else
            if self.touchEnable==false or SizeOfTable(self.touchArr)>=1 or newGuidMgr:isNewGuiding()==true or self.isAnimation==true or (battleScene and battleScene.isBattleing==true) then
                 return 0
            end
        end
        
        if self.touchRect and touch then
            local curTouchPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            -- print("curTouchPos~~~~",curTouchPos.x,curTouchPos.y)
            -- print("self.touchRect~~~~",self.touchRect.x,self.touchRect.y,self.touchRect.width,self.touchRect.height)
            if curTouchPos.x>(self.touchRect.x-self.touchRect.width/2) and curTouchPos.x<(self.touchRect.x+self.touchRect.width/2) and curTouchPos.y>(self.touchRect.y-self.touchRect.height/2) and curTouchPos.y<(self.touchRect.y+self.touchRect.height/2) then
            else
                return 0
            end
        end
        -- print("pass~~~~")

        self.isMoved=false
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
        -- if self.touchEnable==false or newGuidMgr:isNewGuiding()==true or self.isAnimation==true then
        --      do
        --         return
        --      end
        -- end
        -- self.isMoved=true
        -- if self.multTouch==true then --双点触摸

        -- else --单点触摸
        --      local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
        --      local moveDisPos=ccpSub(curPos,self.firstOldPos)
        --      local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
        --       if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<3 then
        --          self.isMoved=false
        --          do
        --             return
        --          end
        --      end
        --      self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,0)
        --      -- local tmpPos=ccpAdd(ccp(self.bgLayer:getPosition()),ccp(moveDisPos.x,0))
        --      -- self.bgLayer:setPosition(tmpPos)
        --      self.firstOldPos=curPos
        --      self.isMoving=true
        -- end
    elseif fn=="ended" then
        if self.forceE then
            if self.touchEnable==false or self.isAnimation==true then
                 do
                    return
                 end
            end
        else
            if self.touchEnable==false or newGuidMgr:isNewGuiding()==true or self.isAnimation==true then
                 do
                    return
                 end
            end
        end
       if self.touchArr[touch]~=nil then
           self.touchArr[touch]=nil
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
            end
            if SizeOfTable(self.touchArr)>1 then
                self.multTouch=true
            else
                self.multTouch=false
            end
       end

       if self.multTouch==true then --双点触摸

       else --单点触摸
           local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
           local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)

           if moveDisTmp.x>self.moveMinDis then
                self:leftPage(true)
           elseif moveDisTmp.x<-self.moveMinDis then
                self:rightPage(true)
           end
       end

       --[[
       if  self.isMoving==true then
            self.isMoving=false
            local tmpToPos=ccpAdd(ccp(self.bgLayer:getPosition()),self.autoMoveAddPos)
            -- tmpToPos=self:checkBound(tmpToPos)
            print("~~~~",tmpToPos.x,tmpToPos.y)
            local ccmoveTo=CCMoveTo:create(0.15,tmpToPos)
            local cceaseOut=CCEaseOut:create(ccmoveTo,3)
            self.bgLayer:runAction(cceaseOut)
       end
       ]]
    else
        self.touchArr=nil
        self.touchArr={}
    end
end


function pageDialog:leftPage(isTouch,nextPage)
    if self.movedCallback then
        if self.movedCallback(1,isTouch)==false then
            do return end
        end
    end
    if self.isAnimation==true then
        do return end
    end
    self.touchEnabledSp:setPosition(self.startPos)
    -- if self.page>1 then
        self.isAnimation=true
        
        local turnPage=self.page-1
        if nextPage then
            turnPage =nextPage
        end
        if turnPage<=0 then
            turnPage=SizeOfTable(self.list)
        end
        local newItem=self.list[turnPage]
        local item=self.list[self.page]

        newItem:setVisible(true)
        newItem:setPosition(self.lPos)

        local function playEndCallback()
            item:setVisible(false)
            item:setPosition(ccp(10000,0))
            self.isAnimation=false
            self.page=turnPage
            if self.callback then
                self.callback(self.page)
            end
            self.touchEnabledSp:setPosition(ccp(10000,0))
        end
        
        local mvTo1=CCMoveTo:create(self.turnInterval,self.rPos)
        local mvTo2=CCMoveTo:create(self.turnInterval,self.cPos)
        local tempPos=ccp(self.cPos.x+50,self.cPos.y)
        local mvTo3=CCMoveTo:create(0.06,tempPos)
        local mvTo4=CCMoveTo:create(0.06,self.cPos)
        local callFunc=CCCallFuncN:create(playEndCallback)

        local acArr=CCArray:create()
        -- acArr:addObject(delay)
        acArr:addObject(mvTo1)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        item:runAction(seq)

        local acArr1=CCArray:create()
        acArr1:addObject(mvTo2)
        acArr1:addObject(mvTo3)
        acArr1:addObject(mvTo4)
        local seq1=CCSequence:create(acArr1)
        newItem:runAction(seq1)

    -- end

end

function pageDialog:rightPage(isTouch,nextPage,customCallback)
    if self.movedCallback then
        if self.movedCallback(2,isTouch)==false then
            do return end
        end
    end
    if self.isAnimation==true then
        do return end
    end
    self.touchEnabledSp:setPosition(self.startPos)
    -- if self.page<SizeOfTable(self.list) then
        self.isAnimation=true
        
        local turnPage=self.page+1
        if nextPage then
            turnPage =nextPage
        end
        if turnPage>SizeOfTable(self.list) then
            turnPage=1
        end
        local newItem=self.list[turnPage]
        local item=self.list[self.page]

        newItem:setVisible(true)
        newItem:setPosition(self.rPos)

        local function playEndCallback()
            item:setVisible(false)
            item:setPosition(ccp(10000,0))
            self.isAnimation=false
            self.page=turnPage
            if self.callback then
                self.callback(self.page)
            end
            if customCallback then
                customCallback()
            end
            self.touchEnabledSp:setPosition(ccp(10000,0))
        end

        local mvTo1=CCMoveTo:create(self.turnInterval,self.lPos)
        local mvTo2=CCMoveTo:create(self.turnInterval,self.cPos)
        local tempPos=ccp(self.cPos.x-50,self.cPos.y)
        local mvTo3=CCMoveTo:create(0.06,tempPos)
        local mvTo4=CCMoveTo:create(0.06,self.cPos)
        local callFunc=CCCallFuncN:create(playEndCallback)

        local acArr=CCArray:create()
        -- acArr:addObject(delay)
        acArr:addObject(mvTo1)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        item:runAction(seq)

        local acArr1=CCArray:create()
        acArr1:addObject(mvTo2)
        acArr1:addObject(mvTo3)
        acArr1:addObject(mvTo4)
        local seq1=CCSequence:create(acArr1)
        newItem:runAction(seq1)

    -- end

end

function pageDialog:hide()
    if self then
        self.touchEnable=false
    end
end
function pageDialog:show()
    if self then
        self.touchEnable=true
    end
end

function pageDialog:setEnabled(enabled)
    if(self)then
        if self.leftBtn then
            self.leftBtn:setEnabled(enabled)
            self.leftBtn:setVisible(enabled)
        end
        if self.rightBtn then
            self.rightBtn:setEnabled(enabled)
            self.rightBtn:setVisible(enabled)
        end
        self.touchEnable=enabled
    end
end

function pageDialog:setBtnEnabled(btnType,flag)
    if btnType==1 then
        if self.leftBtn then
            self.leftBtn:setEnabled(flag)
            self.leftBtn:setVisible(flag)
        end
    else
        if self.rightBtn then
            self.rightBtn:setEnabled(flag)
            self.rightBtn:setVisible(flag)
        end
    end
end

function pageDialog:UseIconBtnChooseSecondPage( )--self.sceneSp "double11new"
    if self.specialShowTb[3][1] =="double11" then--只用于"double11new"
        self.menuItemTb ={}
        local ownIdx = self.specialShowTb[3][2]
        local btnMenu = CCMenu:create()
        local function btnIconCallback(tag,object)
            -- print("tag===>>>",tag)
            if self.isAnimation==true then
                do return end
            end
            for i=1,ownIdx do
                if i == tag then
                    self.menuItemTb[i]:setColor(ccc3(255,255,255))
                    self.menuItemTb[i]:setScale(1.2)
                else
                    self.menuItemTb[i]:setColor(ccc3(136,136,136))
                    self.menuItemTb[i]:setScale(1)
                end
            end
            if tag >self.page then
                self:rightPage(true,tag)
            elseif tag < self.page then
                self:leftPage(true,tag)
            end
        end
        for i=1,ownIdx do
            local otherData,whiShop = acDouble11NewVoApi:getwhiSelfShop(i)
            local btnIcon1 = CCSprite:createWithSpriteFrameName("double11_pic_"..whiShop..".png") 
            local btnIcon2 = CCSprite:createWithSpriteFrameName("double11_pic_"..whiShop..".png") 
            local btnIcon3 = CCSprite:createWithSpriteFrameName("double11_pic_"..whiShop..".png") 
            local menuItem = CCMenuItemSprite:create(btnIcon1,btnIcon2,btnIcon3)
            table.insert(self.menuItemTb,menuItem)
            menuItem:setColor(ccc3(136,136,136))
            if i ==1 then
                menuItem:setColor(ccc3(255,255,255))
                menuItem:setScale(1.2)
            end
            menuItem:registerScriptTapHandler(btnIconCallback)
            menuItem:setAnchorPoint(ccp(0.5,0.5))
            btnMenu:addChild(menuItem,0,i)
        end
        btnMenu:alignItemsHorizontallyWithPadding(-4)
        btnMenu:setTouchPriority(-(self.layerNum-1)*20-20)
        btnMenu:setBSwallowsTouches(true)
        local posY = self.specialShowTb[4] or 255
        btnMenu:setPositionY(G_VisibleSizeHeight-posY)        
        self.sceneSp:addChild(btnMenu)
    end
end

function pageDialog:UseIconBtnChoosePage( )--self.sceneSp
    if self.specialShowTb[3][1] =="double11" then
        self.menuItemTb ={}
        local ownIdx = self.specialShowTb[3][2]
        local btnMenu = CCMenu:create()
        local function btnIconCallback(tag,object)
            -- print("tag===>>>",tag)
            if self.isAnimation==true then
                do return end
            end
            for i=1,ownIdx do
                if i == tag then
                    self.menuItemTb[i]:setColor(ccc3(255,255,255))
                    self.menuItemTb[i]:setScale(1.2)
                else
                    self.menuItemTb[i]:setColor(ccc3(136,136,136))
                    self.menuItemTb[i]:setScale(1)
                end
            end
            if tag >self.page then
                self:rightPage(true,tag)
            elseif tag < self.page then
                self:leftPage(true,tag)
            end
        end
        for i=1,ownIdx do
            local otherData,whiShop = acDouble11VoApi:getwhiSelfShop(i)
            local btnIcon1 = CCSprite:createWithSpriteFrameName("double11_pic_"..whiShop..".png") 
            local btnIcon2 = CCSprite:createWithSpriteFrameName("double11_pic_"..whiShop..".png") 
            local btnIcon3 = CCSprite:createWithSpriteFrameName("double11_pic_"..whiShop..".png") 
            local menuItem = CCMenuItemSprite:create(btnIcon1,btnIcon2,btnIcon3)
            table.insert(self.menuItemTb,menuItem)
            menuItem:setColor(ccc3(136,136,136))
            if i ==1 then
                menuItem:setColor(ccc3(255,255,255))
                menuItem:setScale(1.2)
            end
            menuItem:registerScriptTapHandler(btnIconCallback)
            menuItem:setAnchorPoint(ccp(0.5,0.5))
            btnMenu:addChild(menuItem,0,i)
        end
        btnMenu:alignItemsHorizontallyWithPadding(-4)
        btnMenu:setTouchPriority(-(self.layerNum-1)*20-20)
        btnMenu:setBSwallowsTouches(true)
        local posY = self.specialShowTb[4] or 255
        btnMenu:setPositionY(G_VisibleSizeHeight-posY)
        self.sceneSp:addChild(btnMenu)

    elseif self.specialShowTb[3][1] =="new112018" then
        self.menuItemTb = {}
        self.starSpTb1  = {}
        self.starSpTb2  = {}
        self.openIdx = nil
        local ownIdx = self.specialShowTb[3][2]
        local btnMenu = CCMenu:create()
        local function btnIconCallback(tag,object)
            -- print("tag===>>>",tag)
            if self.isAnimation==true then
                do return end
            end
            for i=1,ownIdx do
                if i == tag then
                    self.menuItemTb[i]:setColor(ccc3(255,255,255))
                    self.menuItemTb[i]:setScale(1.2)
                else
                    self.menuItemTb[i]:setColor(ccc3(136,136,136))
                    self.menuItemTb[i]:setScale(1)
                end
                if self.openIdx == 1 then
                    if self.starSpTb1[i] then
                        self.starSpTb1[i]:setColor(ccc3(255,255,255))
                    end
                else
                    if self.starSpTb2[i] then
                        self.starSpTb2[i]:setColor(ccc3(255,255,255))
                    end
                end
            end
            if tag >self.page then
                self:rightPage(true,tag)
            elseif tag < self.page then
                self:leftPage(true,tag)
            end
        end
        for i=1,ownIdx do
            local otherData,whiShop = acDoubleOneVoApi:getwhiSelfShop(i)
            local btnIcon1 = CCSprite:createWithSpriteFrameName("double11_pic_"..whiShop..".png") 
            local btnIcon2 = CCSprite:createWithSpriteFrameName("double11_pic_"..whiShop..".png") 
            local btnIcon3 = CCSprite:createWithSpriteFrameName("double11_pic_"..whiShop..".png") 
            local menuItem = CCMenuItemSprite:create(btnIcon1,btnIcon2,btnIcon3)
            table.insert(self.menuItemTb,menuItem)
            menuItem:setColor(ccc3(136,136,136))
            if i ==1 then
                menuItem:setColor(ccc3(255,255,255))
                menuItem:setScale(1.2)
            end
            menuItem:registerScriptTapHandler(btnIconCallback)
            menuItem:setAnchorPoint(ccp(0.5,0.5))
            btnMenu:addChild(menuItem,0,i)

            local starPic1,starPic2,openIdx = acDoubleOneVoApi:getNewSelfShopTipPic(i)
            self.openIdx = openIdx
            if starPic1 then
                local starSp = CCSprite:createWithSpriteFrameName(starPic1)
                starSp:setPosition(ccp(menuItem:getContentSize().width * 0.5 + 20,menuItem:getContentSize().height * 0.5 + 20))
                menuItem:addChild(starSp)
                starSp:setColor(ccc3(255,255,255))
                self.starSpTb1[i] = starSp
                if openIdx == 2 then
                    starSp:setVisible(false)
                end
            end
            if starPic2 then
                local starSp = CCSprite:createWithSpriteFrameName(starPic2)
                starSp:setPosition(ccp(menuItem:getContentSize().width * 0.5 + 20,menuItem:getContentSize().height * 0.5 + 20))
                menuItem:addChild(starSp)
                starSp:setColor(ccc3(255,255,255))
                self.starSpTb2[i] = starSp
                if openIdx == 1 then
                    starSp:setVisible(false)
                end
            end
        end
        btnMenu:alignItemsHorizontallyWithPadding(-4)
        btnMenu:setTouchPriority(-(self.layerNum-1)*20-20)
        btnMenu:setBSwallowsTouches(true)
        local posY = self.specialShowTb[4] or 255
        btnMenu:setPositionY(G_VisibleSizeHeight-posY)
        self.sceneSp:addChild(btnMenu)

        btnIconCallback(acDoubleOneVoApi:getFirstShowShop( ) or 1)
    end
end

function pageDialog:dispose() --释放方法
    if self.touchEnabledSp then
        self.touchEnabledSp:removeFromParentAndCleanup(true)
        self.touchEnabledSp=nil
    end
    if self.starSpTb1 then
        for k,v in pairs(self.starSpTb1) do
            self.starSpTb1[k]:removeFromParentAndCleanup(true)
        end
    end
    if self.starSpTb2 then
        for k,v in pairs(self.starSpTb2) do
            self.starSpTb2[k]:removeFromParentAndCleanup(true)
        end
    end
    if self.menuItemTb then
        for k,v in pairs(self.menuItemTb) do
            self.menuItemTb[k]:removeFromParentAndCleanup(true)
        end
    end
    self.callback             =nil
    self.bgLayer              =nil
    self.sceneSp              =nil
    self.touchArr             =nil
    self.multTouch            =nil
    self.firstOldPos          =nil
    self.secondOldPos         =nil
    self.startPos             =nil
    self.isMoving             =nil
    self.autoMoveAddPos       =nil
    self.zoomMidPosForWorld   =nil
    self.zoomMidPosForSceneSp =nil
    self.touchEnable          =nil
    self.isMoved              =nil
    self.lastTouchDownPoint   =nil

    self.layerNum      =nil
    self.page          =nil
    self.leftBtn       =nil
    self.rightBtn      =nil      
    self.isAnimation   =nil
    self.turnInterval  =nil
    self.moveMinDis    =nil
    self.touchRect     =nil
    self.isTouch       =nil
    self.specialShowTb =nil
    self.menuItemTb    =nil
    self.starSpTb1     =nil
    self.starSpTb2     =nil
    self.openIdx       =nil
end
