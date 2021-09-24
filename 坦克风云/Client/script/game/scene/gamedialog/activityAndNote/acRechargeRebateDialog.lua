acRechargeRebateDialog=commonDialog:new()

function acRechargeRebateDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    self.height1=nil
    self.height2=nil
    self.height3=nil

    self.rewardBtn=nil
    self.cellWidth=570

    return nc
end

function acRechargeRebateDialog:initTableView()
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-105))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+20))

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-205),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,105))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    -- if G_curPlatName()=="androidjapan" or G_curPlatName()=="20" or G_curPlatName()=="0" or G_curPlatName()=="31" then
    -- else
        local function rewardCallback(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            if acRechargeRebateVoApi:canReward()==true then
                local function rewardHandler(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.gld then
                            playerVoApi:setGems(playerVoApi:getGems()+tonumber(sData.data.gld))
                            local awardTab={u={gems=tonumber(sData.data.gld)}}
                            local award=FormatItem(awardTab)
                            G_showRewardTip(award)
                        end
                        self.rewardBtn:setEnabled(false)
                        tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
                        acRechargeRebateVoApi:updateRecharge()
                    end
                end
                socketHelper:activeRechargerebate(rewardHandler)
            end
        end
        self.rewardBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rewardCallback,1,getlocal("newGiftsReward"),25,11)
        self.rewardBtn:setAnchorPoint(ccp(0.5,0))
        local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
        rewardMenu:setPosition(ccp(self.panelLineBg:getContentSize().width/2+10,7))
        if G_getIphoneType() == G_iphoneX then
            rewardMenu:setPosition(ccp(self.panelLineBg:getContentSize().width/2+10,27))
        end
        rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.panelLineBg:addChild(rewardMenu,2)
        local vo = acRechargeRebateVoApi:getAcVo()
        if acRechargeRebateVoApi:canReward()==true then
            self.rewardBtn:setEnabled(true)
        else
            self.rewardBtn:setEnabled(false)
            if vo and vo.c and vo.c<0 then
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
            else
            end
        end
    -- end
end

function acRechargeRebateDialog:getCellHeight(idx)
    if idx then
        if self["height"..idx]==nil then
            local discount=acRechargeRebateVoApi:getDiscount()*100

            local cellWidth=self.cellWidth
            local cellHeight=0
            local wSpace=30
            local hSpace=30

            local titleStr
            if idx==0 then
                titleStr=getlocal("activity_timeLabel")
            elseif idx==1 then
                titleStr=getlocal("activity_contentLabel")
            elseif idx==2 then
                titleStr=getlocal("activity_ruleLabel")
            end
            local titleLb=GetTTFLabelWrap(titleStr,30,CCSizeMake(cellWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            cellHeight=cellHeight+titleLb:getContentSize().height+10

            if idx==0 then
                self["height"..idx]=250
            elseif idx==1 then
                local rebateLb1=GetTTFLabelWrap(getlocal("activity_rechargeRebate_rebate_1"),25,CCSizeMake(cellWidth-15-wSpace,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                local numLb=GetTTFLabel(discount.."%",90)
                local rightSpace=50
                local rebateLb2=GetTTFLabelWrap(getlocal("activity_rechargeRebate_rebate_2"),25,CCSizeMake(cellWidth-15-wSpace-rightSpace,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)

                self["height"..idx]=cellHeight+rebateLb1:getContentSize().height+hSpace+numLb:getContentSize().height/2+hSpace+rebateLb2:getContentSize().height+hSpace*2+50
            elseif idx==2 then
                local descLb=GetTTFLabelWrap(getlocal("activity_rechargeRebate_desc1",{"20"}),25,CCSizeMake(cellWidth-15-wSpace,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

                self["height"..idx]=cellHeight+descLb:getContentSize().height+hSpace*3
                if G_getIphoneType() == G_iphoneX then
                    self["height"..idx] = self["height"..idx] - 200
                else
                    self["height"..idx] = self["height"..idx] - 150
                end
            end
        end
        return self["height"..idx]
    end
    return 0
end

function acRechargeRebateDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=3
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local height=self:getCellHeight(idx)
        tmpSize=CCSizeMake(self.cellWidth,height)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local vo=acRechargeRebateVoApi:getAcVo()
        local discount=acRechargeRebateVoApi:getDiscount()*100
        
        local cellWidth=self.cellWidth
        local cellHeight=self:getCellHeight(idx)
        local wSpace=30
        local hSpace=30

        local titleStr
        if idx==0 then
            titleStr=getlocal("activity_timeLabel")
        elseif idx==1 then
            titleStr=getlocal("activity_contentLabel")
        elseif idx==2 then
            titleStr=getlocal("activity_ruleLabel")
        end
        local titleLb=GetTTFLabelWrap(titleStr,30,CCSizeMake(cellWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleLb:setAnchorPoint(ccp(0,1))
        titleLb:setPosition(ccp(10,cellHeight-10))
        if idx == 0 then
            titleLb:setPosition(ccp(10,cellHeight-15)) 
        end
        cell:addChild(titleLb,3)
        titleLb:setColor(G_ColorGreen)

        if idx==0 then
            local backSpire = CCSprite:create("scene/goldAndTankBg_2.jpg")
            backSpire:setAnchorPoint(ccp(0,1))
            backSpire:setPosition(0,cellHeight)
            backSpire:setScaleX(self.cellWidth/backSpire:getContentSize().width)
            backSpire:setScaleY((cellHeight-10)/backSpire:getContentSize().height)
            cell:addChild(backSpire,1)
            local timeStr=acRechargeRebateVoApi:getTimeStr()
            local timeLb=GetTTFLabelWrap(timeStr,25,CCSizeMake(cellWidth-15-wSpace,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            timeLb:setAnchorPoint(ccp(0,1))
            timeLb:setPosition(ccp(200,titleLb:getPositionY()))
            cell:addChild(timeLb,2)
            self.timeLb=timeLb
            local timeSpire = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
            timeSpire:setContentSize(CCSizeMake(cellWidth,100))
            timeSpire:setAnchorPoint(ccp(0,1))
            timeSpire:setPosition(0,cellHeight)
            cell:addChild(timeSpire,1)
        elseif idx==1 then
            local rebateLb1=GetTTFLabelWrap(getlocal("activity_rechargeRebate_rebate_1"),25,CCSizeMake(cellWidth-15-wSpace,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            
            rebateLb1:setAnchorPoint(ccp(0,0.5))
            rebateLb1:setPosition(ccp(15+wSpace,cellHeight-titleLb:getContentSize().height-hSpace-rebateLb1:getContentSize().height/2))
            cell:addChild(rebateLb1,1)

            local numLb=GetTTFLabel(discount.."%",90)
            numLb:setAnchorPoint(ccp(0.5,0.5))
            numLb:setPosition(ccp(cellWidth/2,cellHeight-titleLb:getContentSize().height-rebateLb1:getContentSize().height-hSpace-numLb:getContentSize().height/2-hSpace/2))
            cell:addChild(numLb,1)
            numLb:setColor(G_ColorYellowPro)

            local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
            goldIcon:setPosition(ccp(cellWidth/2+numLb:getContentSize().width/2+goldIcon:getContentSize().width/2*2,cellHeight-titleLb:getContentSize().height-rebateLb1:getContentSize().height-hSpace-numLb:getContentSize().height/2-hSpace/2))
            goldIcon:setScale(2)
            cell:addChild(goldIcon,1)

            local rightSpace=50
            local rebateLb2=GetTTFLabelWrap(getlocal("activity_rechargeRebate_rebate_2"),25,CCSizeMake(cellWidth-15-wSpace-rightSpace,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
            rebateLb2:setAnchorPoint(ccp(1,0.5))
            rebateLb2:setPosition(ccp(cellWidth-5-rightSpace,30+rebateLb2:getContentSize().height/2))
            cell:addChild(rebateLb2,1)
        elseif idx==2 then
            local descLb=GetTTFLabelWrap(getlocal("activity_rechargeRebate_desc1",{discount}),25,CCSizeMake(cellWidth-15-wSpace,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(ccp(15+wSpace,cellHeight-titleLb:getContentSize().height-hSpace))
            cell:addChild(descLb,1)
        end


        if idx~=2 then
            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setAnchorPoint(ccp(0.5,0))
            lineSp:setPosition(ccp(cellWidth/2,0))
            cell:addChild(lineSp,1)
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

function acRechargeRebateDialog:updateAcTime()
    local acVo=acRechargeRebateVoApi:getAcVo()
    if self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        self.timeLb:setString(acRechargeRebateVoApi:getTimeStr())
    end
end

function acRechargeRebateDialog:tick()
    local vo=acRechargeRebateVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    self:updateAcTime()
end

function acRechargeRebateDialog:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.height1=nil
    self.height2=nil
    self.height3=nil
    self.rewardBtn=nil
    self.cellWidth=nil
    self.timeLb=nil
    self=nil
end