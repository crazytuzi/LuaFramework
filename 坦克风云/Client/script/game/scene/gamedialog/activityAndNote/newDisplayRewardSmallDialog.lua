newDisplayRewardSmallDialog=smallDialog:new()

function newDisplayRewardSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self


    self.parent=nil
    self.data=nil
    self.type=0       --是配件还是碎片
    self.message=nil

    return nc
end

-- isXiuzheng 防止cell较少时，点击立即完成，跑到下面了
function newDisplayRewardSmallDialog:showRewardItemsWithDiffTitleDialog(bgSrc,size,tmpFunc,istouch,isuseami,isSizeAmi,isOneByOne,layerNum,content,callback1,callback2,isXiuzheng)
    local sd=newDisplayRewardSmallDialog:new()
    return sd:initDisplayRewardSmallDialog(bgSrc,size,tmpFunc,istouch,isuseami,isSizeAmi,isOneByOne,layerNum,content,callback1,callback2,isXiuzheng)
end

function newDisplayRewardSmallDialog:initDisplayRewardSmallDialog(bgSrc,size,tmpFunc,istouch,isuseami,isSizeAmi,isOneByOne,layerNum,content,callback1,callback2,isXiuzheng)   
    self.isTouch=istouch
    self.isUseAmi=isuseami
    self.isSizeAmi=isSizeAmi
    self.layerNum=layerNum

    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>1 then
        self.message={}
    else
        self.message=content
    end

    local function tmpFunc()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self.bgLayer:setOpacity(150)

    --物品列表
    local function eventHandler(handler,fn,idx,cel)
        local cellHight = 120
        if fn=="numberOfCellsInTableView" then
            -- print("SizeOfTable(self.message)",SizeOfTable(self.message))
            return SizeOfTable(self.message)
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize
            -- self.cellHight = 120
            local award = self.message[idx+1] or {}
            if type(award) ~= "table" then
                cellHight = 60
            else
                cellHight = 120
            end
            tmpSize = CCSizeMake(self.bgLayer:getContentSize().width - 20,cellHight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local award = self.message[idx+1] or {}

            if award then
                if type(award) ~= "table" then
                    local desc = GetTTFLabelWrap(award,28,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    desc:setAnchorPoint(ccp(0,0))
                    desc:setColor(G_ColorGreen)
                    cell:addChild(desc)
                else
                    local icon,iconScale = G_getItemIcon(award,90,false,self.layerNum,nil,self.tv1)
                    icon:setTouchPriority(-(self.layerNum-1)*20-2)
                    icon:setAnchorPoint(ccp(0,0.5))
                    icon:setPosition(10,cellHight/2)
                    cell:addChild(icon)


                    local name = GetTTFLabelWrap(award.newDes,25,CCSizeMake(self.bgLayer:getContentSize().width - 150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    name:setAnchorPoint(ccp(0,0.5))
                    name:setPosition(20+icon:getContentSize().width*iconScale,cellHight/2)
                    cell:addChild(name)
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
    local function callBack(...)
        return eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    
    local height = size.height-120*2-60*2-30
    if isXiuzheng and height>110 then
		self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(size.width,120*2+60*2),nil)
    	self.tv:setPosition(ccp(10,height))
    	
    else
    	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(size.width,size.height - 140),nil)
    	self.tv:setPosition(ccp(10,110))
    end
    
    self.tv:setMaxDisToBottomOrTop(100)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv,1)




    --确定按钮
    local isEnd=true
    local function confirm()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
        PlayEffect(audioCfg.mouseClick)

        if isEnd==true then
            if callback1~=nil then
                callback1()
            end
            if callback2~=nil then
                callback2()
            end
            self:close()
        elseif isEnd==false then

            if self and self.bgLayer and self.tv then
                self.bgLayer:stopAllActions()
                self.message=content
                local recordPoint=self.tv:getRecordPoint()
                self.tv:reloadData()
                recordPoint.y=0
                self.tv:recoverToRecordPoint(recordPoint)
                tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
            end
            isEnd=true
        end
    end

    local sureBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",confirm,1,getlocal("ok"),25,11)
    self.sureBtn=sureBtn
    local sureMenu=CCMenu:createWithItem(sureBtn)
    sureMenu:setPosition(ccp(size.width/2,sureBtn:getContentSize().height - 15))
    sureMenu:setTouchPriority(-(layerNum-1)*20-6)
    self.bgLayer:addChild(sureMenu,2)
    if SizeOfTable(content)>1 then
        isEnd=false
        tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("gemCompleted"))
    end
    if SizeOfTable(content)>1 and isOneByOne and isOneByOne == true then
        isEnd=false
    end

    local function forbidClick()
   
    end
    local rect2 = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.topforbidSp:setTouchPriority(-(layerNum-1)*20-5)
    self.topforbidSp:setAnchorPoint(ccp(0,0))
    self.topforbidSp:setContentSize(CCSize(self.bgSize.width, (G_VisibleSize.height-self.bgSize.height)/2+150))
    -- self.topforbidSp:setPosition(0,self.bgLayer:getContentSize().height-120-desc:getContentSize().height+30)
    self.topforbidSp:setPosition(0,self.bgLayer:getContentSize().height-120+30)



    self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-5)
    self.bottomforbidSp:setContentSize(CCSize(self.bgSize.width,30))
    self.bottomforbidSp:setAnchorPoint(ccp(0,0))
    self.bottomforbidSp:setPosition(0,0)
    dialogBg:addChild(self.topforbidSp)
    dialogBg:addChild(self.bottomforbidSp)
    self.bottomforbidSp:setVisible(false)
    self.topforbidSp:setVisible(false)

    self:show()

    local function touchDialog()
        if self.isTouch~=nil and self.isTouch == true then
            PlayEffect(audioCfg.mouseClick)
            if callback1~=nil then
                callback1()
            end
            if callback2~=nil then
                callback2()
            end
            self:close()
        end    
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>1 then
        local acArr=CCArray:create()
        for k,v in pairs(content) do
            local function showNextMsg()
                if self and self.tv and v then
                    table.insert(self.message,v)
                    self.tv:insertCellAtIndex(k-1)
                    if k==SizeOfTable(content) then
                    	tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
                        isEnd=true
                    end
                end
            end
            local callFunc1=CCCallFunc:create(showNextMsg)
            local delay=CCDelayTime:create(0.5)

            acArr:addObject(delay)
            acArr:addObject(callFunc1)
        end
        local function endCallBack()
            -- isEnd = true
        end
        local callFunc2=CCCallFunc:create(endCallBack)
        acArr:addObject(callFunc2)
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)
    end

    sceneGame:addChild(self.dialogLayer,layerNum)

    return self.dialogLayer
end

function newDisplayRewardSmallDialog:dispose()
    self.parent=nil
    self.data=nil
    self.type=0       --是配件还是碎片
    self.message=nil
end
