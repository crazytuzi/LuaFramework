recodeDialog={}
function recodeDialog:new()
    local nc={
            container, -- 总背景框
            touchDialogBg, -- 黑色遮盖层
            layerNum,
            bgH, -- 背景的高度
            bgW, -- 背景的宽度
            tv,
          }
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function recodeDialog:init(layerNum)
	self.layerNum = layerNum

    local function getArmsRaceRecode(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData and sData.data then
                acArmsRaceVoApi:updateLog(sData.data)
                self:initLayer()
            end
        end
    end
    
    socketHelper:getArmsRaceRecode(getArmsRaceRecode)

end

function recodeDialog:initLayer()
	self.bgH = 700
	self.bgW = 600
	local function touchDialog()
          
    end

    local capInSet = CCRect(168, 86, 10, 10)
    local capInSet1 = CCRect(10, 10, 1, 1)


    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",capInSet,touchDialog);
    dialogBg:setContentSize(CCSizeMake(self.bgW,self.bgH))
    self.container=dialogBg
    
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touchDialog);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,self.layerNum)


	local tLable=GetTTFLabel(getlocal("activity_armsRace_recode"),40)
	tLable:setAnchorPoint(ccp(0.5,0.5))
	tLable:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-50))
	dialogBg:addChild(tLable,2)

	local function close()
        PlayEffect(audioCfg.mouseClick)    
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0,0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    closeBtn:setPosition(ccp(dialogBg:getContentSize().width-closeBtnItem:getContentSize().width,dialogBg:getContentSize().height-closeBtnItem:getContentSize().height))
    dialogBg:addChild(closeBtn)

    local buttonStr=getlocal("randomMoveIslandOK")
    local rightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",close,2,buttonStr,25)
    local rightMenu=CCMenu:createWithItem(rightItem);
    rightMenu:setPosition(ccp(self.container:getContentSize().width/2,50))
    rightMenu:setTouchPriority(-(self.layerNum-1)*20-3);
    dialogBg:addChild(rightMenu,5)
    
    
    local careLable=GetTTFLabelWrap(getlocal("activity_armsRace_care"),22,CCSizeMake(self.bgW - 30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	careLable:setAnchorPoint(ccp(0,0.5))
	careLable:setPosition(ccp(20,125))
	careLable:setColor(G_ColorRed)
	dialogBg:addChild(careLable,2)
    
    if acArmsRaceVoApi:getRecodeNum() == 0 then -- 没有任何领奖记录时的显示
		local noLabel=GetTTFLabelWrap(getlocal("activity_armsRace_noRecode"),22,CCSizeMake(self.bgW - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    noLabel:setAnchorPoint(ccp(0.5,0.5))
	    noLabel:setPosition(ccp(self.bgW/2,self.bgH/2))
	    dialogBg:addChild(noLabel)
	end


    self.container:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.container,self.layerNum+1)
    self:initTableView()
    self:show()
end


function recodeDialog:initTableView()
	local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgW - 20,self.bgH - 300),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,170))
    self.container:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(10)

    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(60, 20, 1, 1)
    local function touch(hd,fn,idx)

    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",capInSet,touch)
    backSprie:setContentSize(CCSizeMake(self.bgW - 20, 40))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0.5))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(self.bgW/2,self.bgH - 100))
    self.container:addChild(backSprie)
  

    local leftW = 160
    local timeLb=GetTTFLabel(getlocal("alliance_event_time"),22)
    timeLb:setPosition(leftW/2,self.bgH - 100)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    self.container:addChild(timeLb,2)
    timeLb:setColor(G_ColorGreen2)

    local eventLb=GetTTFLabel(getlocal("alliance_event_event"),22)
    eventLb:setPosition((self.bgW-20 - leftW)/2 + leftW,self.bgH - 100)
    eventLb:setAnchorPoint(ccp(0.5,0.5))
    self.container:addChild(eventLb,2)
    eventLb:setColor(G_ColorGreen2)
    
    

end


--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function recodeDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
    	local recodeNum = acArmsRaceVoApi:getRecodeNum()
    	if  recodeNum > 0 then
            return recodeNum
        end
        return 0
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgW-20,80)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local itemH = 80
        local itemW = self.bgW-20
        local leftW = 160
        local num = acArmsRaceVoApi:getRecodeNum()
        if num<=0 then
            do return end
        end
        
        -- 记录信息
        local recodes = acArmsRaceVoApi:getRecode()
        local recode = nil
        if recodes ~= nil and SizeOfTable(recodes) > idx then
            recode= recodes[idx + 1]
        end

        if recode == nil then
            return cell
        end
        
        local tankId=recode[1]
        local tid=tonumber(RemoveFirstChar(tankId))
        
        -- 奖励坦克配置
        local rewardTank = tankCfg[tid]
        if rewardTank == nil then
            return cell
        end

        local tankNum = tonumber(recode[2])
        local tankName = getlocal(rewardTank.name)
        local time = recode[3]

        local timeStr=allianceEventVoApi:getTimeStr(time)
        local timeLabel=GetTTFLabel(timeStr,22)
        timeLabel:setAnchorPoint(ccp(0.5,0.5))
        timeLabel:setPosition(ccp(leftW/2,itemH/2))
        cell:addChild(timeLabel,1)

        local message = getlocal("activity_armsRace_getTank",{tankNum, tankName})
        local textLabel=GetTTFLabelWrap(message,22,CCSizeMake(itemW - leftW - 10,itemH),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        textLabel:setAnchorPoint(ccp(0.5,0.5))
        textLabel:setPosition(ccp((itemW - leftW)/2 + leftW,itemH/2))
        cell:addChild(textLabel,1)

        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setScale(0.95)
        lineSp:setPosition(ccp(self.bgW/2,0))
        cell:addChild(lineSp)

        return cell

    elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
    elseif fn=="ccTouchMoved" then
           self.isMoved=true
    elseif fn=="ccTouchEnded"  then
           
    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end
end

--显示面板,加效果
function recodeDialog:show() 
   local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
   local function callBack()
       base:cancleWait()
   end
   local callFunc=CCCallFunc:create(callBack)
   
   local scaleTo1=CCScaleTo:create(0.1, 1.1);
   local scaleTo2=CCScaleTo:create(0.07, 1);

   local acArr=CCArray:create()
   acArr:addObject(scaleTo1)
   acArr:addObject(scaleTo2)
   acArr:addObject(callFunc)
    
   local seq=CCSequence:create(acArr)
   self.container:runAction(seq)
end

function recodeDialog:close()
    local function realClose()
        self.touchDialogBg:removeFromParentAndCleanup(true)
        self.touchDialogBg=nil
        self.container:removeFromParentAndCleanup(true)
        self.container=nil

        self.bgH = nil
	    self.bgW = nil
	    self.layerNum = nil

	    self.tv = nil
    end
    local fc= CCCallFunc:create(realClose)
    local scaleTo1=CCScaleTo:create(0.1, 1.1);
    local scaleTo2=CCScaleTo:create(0.07, 0.8);

    local acArr=CCArray:create()
    acArr:addObject(scaleTo1)
    acArr:addObject(scaleTo2)
    acArr:addObject(fc)
    
    local seq=CCSequence:create(acArr)
    self.container:runAction(seq)
end

function recodeDialog:tick()

    
end