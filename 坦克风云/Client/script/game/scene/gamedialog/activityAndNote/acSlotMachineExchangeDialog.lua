acSlotMachineExchangeDialog={}

function acSlotMachineExchangeDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.closeBtn=nil
    self.tv=nil
    self.topforbidSp = nil --顶端遮挡层
    self.bottomforbidSp = nil --底部遮挡层
    return nc

end

function acSlotMachineExchangeDialog:initInfoLayer()
    local titleLb = GetTTFLabel(getlocal("activity_slotMachine_tableLb"),40)
    titleLb:setAnchorPoint(ccp(0.5,1))
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-20))
    self.bgLayer:addChild(titleLb,2)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-110),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,20))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(30)
end

function acSlotMachineExchangeDialog:init(layerNum)

    self.layerNum=layerNum

    local function tmpFunc()
    
    end
    
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),tmpFunc)
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(580,850)
    self.bgLayer:setContentSize(rect)
    self.bgLayer:ignoreAnchorPointForPosition(false)
    self.bgLayer:setAnchorPoint(CCPointMake(0.5,0.5))
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    
    local function close()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
     end
   local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-6)
    self.closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)
    
    self:initInfoLayer()
    
    
    
    local function touchDialog()
          
    end
    
    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(20, 20, 10, 10)
    
    -- local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",capInSet,touchDialog);
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect1=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect1)
    touchDialogBg:setOpacity(0)
    touchDialogBg:ignoreAnchorPointForPosition(false)
    touchDialogBg:setAnchorPoint(CCPointMake(0.5,0.5))
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))

    self.bgLayer:addChild(touchDialogBg)
    sceneGame:addChild(self.bgLayer,self.layerNum)
    
    local function forbidClick()
       print("点击了啦啦啦啦啦~")
    end
    local rect2 = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.topforbidSp:setTouchPriority(-(self.layerNum-1)*20-5)
    self.topforbidSp:setAnchorPoint(ccp(0,0))
    self.topforbidSp:setIsSallow(true)
    self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,500))
    self.topforbidSp:setPosition(0,self.bgLayer:getContentSize().height)
    self.bgLayer:addChild(self.topforbidSp)


    self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.bottomforbidSp:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bottomforbidSp:setAnchorPoint(ccp(0,1))
    self.bottomforbidSp:setIsSallow(true)
    self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,500))
    self.bottomforbidSp:setPosition(0,0)
    self.bgLayer:addChild(self.bottomforbidSp)
    self.topforbidSp:setVisible(false)
    self.bottomforbidSp:setVisible(false)

    --return self.bgLayer
end

function acSlotMachineExchangeDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(560,480)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local W = 560
        local H = 480
        local titleH = 80
        local single = (H - titleH)/4

        local titleLb=GetTTFLabel(getlocal("activity_slotMachine_tableTitleLb"..tonumber(idx + 1)),28)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(W/2, H - titleH/2))
        cell:addChild(titleLb,1)
        titleLb:setColor(G_ColorGreen)
        
        local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSP:setAnchorPoint(ccp(0.5,0.5))
        lineSP:setScaleX(W/lineSP:getContentSize().width)
        lineSP:setScaleY(1.2)
        lineSP:setPosition(ccp(W/2,H - titleH))
        cell:addChild(lineSP)

        local cfgByNum = acSlotMachineVoApi:getCfgConversionTableByNum(3 - idx)
        local index = 1
        for k,v in pairs(cfgByNum) do
            local iconNum = v.num
            local id = v.id
            local pic = nil
            local icon = nil
            local iconX = nil
            local iconY = H - titleH - single * (index - 0.5)
            for i=1,iconNum do
                iconX = W - 180 - i * 120
                -- iconX = i * (W - 180)/(iconNum + 1)
                pic = acSlotMachineVoApi:getPicById(id)
                icon = CCSprite:createWithSpriteFrameName(pic)
                icon:setScale(0.6)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(ccp(iconX,iconY))
                cell:addChild(icon)
            end

            -- 奖励坦克
            local rewardCfg = v.reward.o[1]
            for k2,v2 in pairs(rewardCfg) do
                if k ~= "index" then
                    local tankId = tonumber(RemoveFirstChar(k2))
                    local tankNum = v2
                    local tankCfg = tankCfg[tankId]
                    if tankCfg ~= nil then
                        iconX = W - 20

                        local function showInfoHandler(hd,fn,idx)
                          if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            tankInfoDialog:create(nil,tankId,self.layerNum+1, true)
                          end
                        end
                        
                        local icon2
                        local iconScaleX=1
                        local iconScaleY=1
                        icon2 = LuaCCSprite:createWithSpriteFrameName(tankCfg.icon,showInfoHandler)
                        if icon2:getContentSize().width>100 then
                          iconScaleX=0.78*100/150
                          iconScaleY=0.78*100/150
                        else
                          iconScaleX=0.78
                          iconScaleY=0.78
                        end
                        icon2:setScaleX(iconScaleX)
                        icon2:setScaleY(iconScaleY)
                        icon2:ignoreAnchorPointForPosition(false)
                        icon2:setAnchorPoint(ccp(1,0.5))
                        icon2:setPosition(ccp(iconX ,iconY))
                        icon2:setIsSallow(false)
                        icon2:setTouchPriority(-(self.layerNum-1)*20-2)
                        cell:addChild(icon2,1)

                        local numLabel=GetTTFLabel("x"..tankNum,25)
                        numLabel:setAnchorPoint(ccp(1,0))
                        numLabel:setPosition(icon2:getContentSize().width-10,0)
                        icon2:addChild(numLabel,1)
                        numLabel:setScaleX(1/iconScaleX)
                        numLabel:setScaleY(1/iconScaleY)
                    end

                end 
            end
            
            iconX = W - 145 
            local denghao=GetTTFLabel("=",30)
            denghao:setAnchorPoint(ccp(1,0.5))
            denghao:setPosition(iconX ,iconY)
            cell:addChild(denghao)

            index = index + 1
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



function acSlotMachineExchangeDialog:close()
    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()
end
function acSlotMachineExchangeDialog:dispose()
    self.bgLayer=nil
    self.closeBtn=nil
    self.tv=nil
    self.topforbidSp = nil --顶端遮挡层
    self.bottomforbidSp = nil --底部遮挡层
    self = nil
end
