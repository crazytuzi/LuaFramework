ltzdzChatTab2 ={}
function ltzdzChatTab2:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    return nc
end

function ltzdzChatTab2:init()
	self.bgLayer=CCLayer:create()
	self:initLayer()
    local function refreshChat(event,data)
       self:refreshChat(data)
    end
    self.refreshChatListener=refreshChat
    eventDispatcher:addEventListener("ltzdz.newChat2",refreshChat)
	return self.bgLayer
end

function ltzdzChatTab2:initLayer()
    self:initTableView()
end
function ltzdzChatTab2:initTableView()

    self.chatList=G_clone(ltzdzChatVoApi:getChat2())
    self.chatNum=#self.chatList

    local function callBack(...)
        return self:eventHandlerNew(...)
    end
    local hSpace=65
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-15,self.bgLayer:getContentSize().height-270-hSpace-10),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,100+hSpace))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

    self:resetTvPos()
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function ltzdzChatTab2:eventHandlerNew(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.chatNum
    elseif fn=="tableCellSizeForIndex" then
        local chatVo=self.chatList[idx+1]
        if chatVo==nil then
            do return end
        end
        local height=chatVo.height
        height=136/2-40+chatVo.height+13
        if height<146 then
            height=146
        end
        tmpSize=CCSizeMake(600,height+5)
        -- if chatVo.timeVisible then
        --     tmpSize.height=tmpSize.height+60
        -- end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local chatVo=self.chatList[idx+1]
        if chatVo==nil then
            do return end
        end

        local isUserSelf = false -- 是否是当前玩家发送的消息
        if chatVo.senderId == playerVoApi:getUid() then
            isUserSelf = true
        end
        
        local wSpace=5
        local hSpace=5
    
        local width=chatVo.width
        local height=chatVo.height
        height=136/2-40+chatVo.height+13
        if height<146 then
            height=146
        end
        local jiange=0
        local totalHeight=height+hSpace+jiange
        local timeLbH=0
        -- if chatVo.timeVisible then
        --     timeLbH=60
        --     local timeStr=G_chatTime(chatVo.time,true)
        --     local timeLabel=GetTTFLabel(timeStr,26)
        --     timeLabel:setAnchorPoint(ccp(0.5,0.5))
        --     timeLabel:setPosition(ccp(300,totalHeight+timeLbH-30))
        --     cell:addChild(timeLabel,3)
        --     timeLabel:setColor(G_ColorYellowPro)
        -- end
        
      
        local typeWidth=55

        local bgImage="chat_head_common.png"
      


        -- 新版显示头像所以不在需要icon
        local pic=1
        if chatVo and chatVo.pic then
            pic=chatVo.pic
        end
        
        --类型图标
        local spSize=98
        local spaceX=10
        local typeSp = CCSprite:createWithSpriteFrameName(bgImage)
        local typeScale=spSize/typeSp:getContentSize().width
        typeSp:setAnchorPoint(ccp(0.5,0.5))
        cell:addChild(typeSp,3)
        typeSp:setScale(typeScale)

        if isUserSelf then
            typeSp:setPosition(ccp(600-wSpace-spSize/2,totalHeight-spSize/2-30))
            pic=playerVoApi:getPic()

        else
            typeSp:setPosition(ccp(wSpace+spSize/2,totalHeight-spSize/2-30))
        end

        -- 头像
        local headSp = playerVoApi:getPersonPhotoSp(pic)
        headSp:setScale(78/70*headSp:getScale())
        typeSp:addChild(headSp)
        headSp:setPosition(typeSp:getContentSize().width/2,80)
        -- headSp:setPosition(typeSp:getContentSize().width/2,typeSp:getContentSize().height/2)

        local timeStr=G_chatTime(chatVo.ts,true)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setAnchorPoint(ccp(1,1))
        timeLabel:setPosition(ccp(590,height+hSpace-3))
        cell:addChild(timeLabel,3)
        timeLabel:setVisible(false)

        -- 聊天信息背景
        local bgImage
        if isUserSelf then
            bgImage = "chat_bg_right.png"
        else
            bgImage = "chat_bg_left.png"
        end
        local function msgBgClick(...)
            
        end
        msgBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgImage,CCRect(30, 25, 1, 1),msgBgClick)
        msgBg:setContentSize(CCSizeMake(100,50))
        if isUserSelf then
            msgBg:setAnchorPoint(ccp(1,1))
            msgBg:setPosition(ccp(600-wSpace-spSize,totalHeight-spSize/2-17))
        else
            msgBg:setAnchorPoint(ccp(0,1))
            msgBg:setPosition(ccp(wSpace+spSize,totalHeight-spSize/2-17))
        end
        cell:addChild(msgBg)
        
        local messageLabel
        local msgX=0
        local msgY=-1
        
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local senderLabel


        local backSprie

        local function cellClick1(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                base:setWait()
                local function touchCallback()
                    base:cancleWait()
                    ltzdzVoApi:showPlayerInfoSmallDialog(self.layerNum+1,true,true,nil,getlocal("ltzdz_compete_file"),chatVo)
                end
                local fadeIn=CCFadeIn:create(0.2)
                local fadeOut=CCFadeOut:create(0.2)
                local callFunc=CCCallFuncN:create(touchCallback)
                local acArr=CCArray:create()
                acArr:addObject(fadeIn)
                acArr:addObject(fadeOut)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                backSprie:runAction(seq)
            end
        end

        backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSet,cellClick1)
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp(2,0))
        cell:addChild(backSprie,1)
        backSprie:setContentSize(CCSizeMake(596,totalHeight-5))
        backSprie:setOpacity(0)

        local lbSize=28
        local lbSpace=0
        if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
            lbSpace=8
            lbSize=22
        end

        local senderName=ltzdzChatVoApi:getNameStr(chatVo) or ""
        local senderId=chatVo.senderId
        local selfUserInfo=ltzdzFightApi:getUserInfo() or {}
        local ally=selfUserInfo.ally or 0
        if tonumber(senderId)==tonumber(ally) then
            senderName=getlocal("ltzdz_ally_friend") .. senderName
        end

        local color=ltzdzChatVoApi:getTypeInfo(2)
        senderLabel=GetTTFLabel(senderName,lbSize)
        if isUserSelf then
            senderLabel:setAnchorPoint(ccp(1,0))
            senderLabel:setPosition(ccp(600-wSpace-spSize-5,totalHeight-spSize/2-15+20+lbSpace))
        else
            senderLabel:setAnchorPoint(ccp(0,0))
            senderLabel:setPosition(ccp(wSpace+spSize+5,totalHeight-spSize/2-15+20+lbSpace))
        end
        cell:addChild(senderLabel,3)
        senderLabel:setColor(color)

        messageLabel=GetTTFLabelWrap(chatVo.msg,26,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,msgFont)
        -- messageLabel:setColor(lbColor)
        lbHeight=messageLabel:getContentSize().height
        msgX=msgX+typeWidth+wSpace
        msgY=msgY+lbHeight+hSpace
        
        messageLabel:setPosition(ccp(msgX,msgY))
        messageLabel:setAnchorPoint(ccp(0,0.5))

        local widLb=GetTTFLabel(chatVo.msg,26)
        if widLb:getContentSize().width<=width then
            local msgBgW=widLb:getContentSize().width+35
            if widLb:getContentSize().width<50 then
                msgBgW=70
            end
            msgBg:setContentSize(CCSizeMake(msgBgW,widLb:getContentSize().height+20))
        else
            msgBg:setContentSize(CCSizeMake(width+35,lbHeight+20))
        end
        local richAdd=0
        if isUserSelf then
            messageLabel:setPosition(ccp(15,msgBg:getContentSize().height/2+richAdd))
        else
            messageLabel:setPosition(ccp(20,msgBg:getContentSize().height/2+richAdd))
        end
        
        msgBg:addChild(messageLabel,2)

        
        messageLabel:setColor(color)

        if G_getCurChoseLanguage()=="ar" then
            messageLabel:setAnchorPoint(ccp(1,0.5))
            if isUserSelf then
                messageLabel:setPosition(ccp(msgBg:getContentSize().width-17,msgBg:getContentSize().height/2+richAdd))
            else
                messageLabel:setPosition(ccp(msgBg:getContentSize().width-10,msgBg:getContentSize().height/2+richAdd))
            end
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

function ltzdzChatTab2:refreshChat(data)
    if self.tv then
        self.chatList=G_clone(ltzdzChatVoApi:getChat2())
        local chatNum2=ltzdzChatVoApi:getMaxMore(2)
        if self.chatNum+1>chatNum2 then
            self.tv:removeCellAtIndex(0)
            self.chatNum=self.chatNum-1
            -- table.remove(self.chatList,1)
        end
        self.chatNum=self.chatNum+1
        -- table.insert(self.chatList,data)
        self.tv:insertCellAtIndex(self.chatNum-1)
        self:resetTvPos()
    end
end

function ltzdzChatTab2:resetTvPos()
    local recordPoint = self.tv:getRecordPoint()
    if recordPoint.y<0 then
        recordPoint.y=0
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function ltzdzChatTab2:dispose( )
    if self.refreshChatListener then
        eventDispatcher:removeEventListener("ltzdz.newChat2",self.refreshChatListener)
        self.refreshChatListener=nil
    end
    self.layerNum=nil
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    self.chatList=nil
    self.chatNum=nil
    self.bgLayer=nil
end