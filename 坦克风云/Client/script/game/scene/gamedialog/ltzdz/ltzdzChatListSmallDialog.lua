ltzdzChatListSmallDialog=smallDialog:new()

function ltzdzChatListSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function ltzdzChatListSmallDialog:showChatList(layerNum,istouch,isuseami,callBack,titleStr,parent,chatList,ally)
	local sd=ltzdzChatListSmallDialog:new()
    sd:initChatList(layerNum,istouch,isuseami,callBack,titleStr,parent,chatList,ally)
    return sd
end

function ltzdzChatListSmallDialog:initChatList(layerNum,istouch,isuseami,pCallBack,titleStr,parent,chatList,ally)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.parent=parent
    local nameFontSize=30


    -- base:removeFromNeedRefresh(self) --停止刷新
    base:addNeedRefresh(self)

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)


    local chatlistNum=SizeOfTable(chatList)
    local addH=0
    if chatlistNum==0 then
        addH=60
    else
        addH=chatlistNum*70
    end


    local dialogBg=G_getNewDialogBg2(CCSizeMake(580,80+addH),self.layerNum,callback,titleStr,25,titleColor)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer=dialogBg

    self:show()

    local function closeFunc()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    G_addForbidForSmallDialog(self.dialogLayer,dialogBg,-(layerNum-1)*20-3,closeFunc)

    local dialogSize=dialogBg:getContentSize()

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(dialogSize.width-40,addH))
    dialogBg2:setAnchorPoint(ccp(0.5,0))
    dialogBg2:setPosition(dialogSize.width/2,30)
    self.bgLayer:addChild(dialogBg2)

    if chatlistNum==0 then
        local descLb=GetTTFLabelWrap(getlocal("ltzdz_whisper_message_des2"),25,CCSizeMake(dialogBg2:getContentSize().width - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        dialogBg2:addChild(descLb)
        descLb:setPosition(getCenterPoint(dialogBg2))
    else
        for k,v in pairs(chatList) do
            local info=v.value
            if info then
                local cHeight=dialogBg2:getContentSize().height-35-(k-1)*70
                local nameStr=info.nickname or ""
                local color=G_ColorWhite
                if tonumber(v.uid)==tonumber(ally) then
                    nameStr=nameStr .. getlocal("ltzdz_ally_friend")
                    color=G_ColorBlue
                end
                local nameLb=GetTTFLabel(nameStr,25)
                dialogBg2:addChild(nameLb)
                nameLb:setAnchorPoint(ccp(0,0.5))
                nameLb:setPosition(10,cHeight)
                nameLb:setColor(color)

                local function touchSelectMenu()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    if pCallBack then
                        pCallBack(info.nickname,v.uid)
                    end
                    self:close()
                end
                local selectItem = GetButtonItem("newChatBtn.png","newChatBtn_Down.png","newChatBtn_Down.png",touchSelectMenu,nil,nil,nil);
                local selectBtn = CCMenu:createWithItem(selectItem)
                selectBtn:setTouchPriority(-(layerNum-1)*20-4)
                selectBtn:setPosition(ccp(dialogBg2:getContentSize().width-70,cHeight))
                dialogBg2:addChild(selectBtn)

                local upM_Line = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
                upM_Line:setContentSize(CCSizeMake(dialogBg2:getContentSize().width-10,upM_Line:getContentSize().height))
                upM_Line:setPosition(ccp(dialogBg2:getContentSize().width/2,cHeight-35))
                upM_Line:setAnchorPoint(ccp(0.5,0.5))
                dialogBg2:addChild(upM_Line,2)

            end
        end
    end

    self.childTb=G_clickSreenContinue(self.bgLayer)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function ltzdzChatListSmallDialog:setTimerSpPer(moneyTimerSprite,slotInfo)
    local totalTime=slotInfo[5]-slotInfo[4]
    local marchTime=base.serverTime-slotInfo[4]
    -- print("totalTime,marchTime",totalTime,marchTime)
    moneyTimerSprite:setPercentage(marchTime/totalTime*100)


    local lbPer = tolua.cast(moneyTimerSprite:getChildByTag(12),"CCLabelTTF")
    lbPer:setAnchorPoint(ccp(0.5,0))
    lbPer:setPosition(ccp(moneyTimerSprite:getContentSize().width/2,0))
    local subTime=slotInfo[5]-base.serverTime
    if subTime<0 then
        subTime=0
    end
    lbPer:setString(GetTimeStrForFleetSlot(subTime))
end

function ltzdzChatListSmallDialog:refreshSlot(data)

    if self.tv then
        self.allSlot=ltzdzFightApi:getSelfAllSlot()
        self.tickFleetTimer={}
        self.tv:reloadData()
    end

end


function ltzdzChatListSmallDialog:childVisible(flag)
    if self.childTb then
        for k,v in pairs(self.childTb) do
            if v then
                v:setVisible(flag)
            end
        end
    end
end


function ltzdzChatListSmallDialog:tick()
    if self.tickFleetTimer and self.allSlot then
        for k,v in pairs(self.tickFleetTimer) do
            local slotInfo=self.allSlot[k].value
            if v and slotInfo then
                self:setTimerSpPer(v,slotInfo)
            end
        end
    end
end


function ltzdzChatListSmallDialog:dispose()
    if self.slotListener then
        eventDispatcher:removeEventListener("ltzdz.refreshSlot",self.slotListener)
        self.slotListener=nil
    end
    self.childTb=nil

    self.allSlot=nil
    self.tickFleetTimer=nil
    -- base:removeFromNeedRefresh(self)
end

