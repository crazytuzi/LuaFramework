ltzdzSeasonTaskRewardDialog=smallDialog:new()

function ltzdzSeasonTaskRewardDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzSeasonTaskRewardDialog:showSeasonTaskRewardDialog(layerNum)
    local sd=ltzdzSeasonTaskRewardDialog:new()
    sd:initSeasonTaskRewardDialog(layerNum)
    return sd
end

function ltzdzSeasonTaskRewardDialog:initSeasonTaskRewardDialog(layerNum)
    self.layerNum=layerNum
    self.isUseAmi=true
    self.isSizeAmi=false
    self.dialogLayer=CCLayer:create()

    local function close()
        return self:close()
    end
    local bgSize=CCSizeMake(580,320)
    self.bgSize=bgSize
    local dialogBg=G_getNewDialogBg(bgSize,getlocal("ltzdz_season_reward"),28,nil,self.layerNum,true,close)
    dialogBg:setContentSize(bgSize)
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,1)

    self:show()

    local rewardPanel=G_getThreePointBg(CCSizeMake(self.bgSize.width-40,140),nil,ccp(0.5,1),ccp(self.bgSize.width/2,self.bgSize.height-80),self.bgLayer)
    local tvWidth,tvHeight=rewardPanel:getContentSize().width,rewardPanel:getContentSize().height
    local cellWidth,cellHeight=tvWidth,140
    local taskTb=ltzdzVoApi:getWarCfg().seasonTask
    local cellNum=SizeOfTable(taskTb)
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then      
            return cellNum
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize
            tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local tid="t"..(idx+1)
            local task=taskTb[tid]
            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
            -- lineSp:setScale(0.95)
            lineSp:setPosition(cellWidth/2,cellHeight/2)
            cell:addChild(lineSp)

            local limitLb=GetTTFLabel(getlocal("getreward_limit"),22)
            limitLb:setAnchorPoint(ccp(0,0.5))
            limitLb:setPosition(20,3*cellHeight/4)
            -- limitLb:setColor(G_ColorYellowPro)
            cell:addChild(limitLb)

            local cur,max,state=ltzdzVoApi:getSeasonTaskState(tid)
            local colorTab={G_colorWhite,G_ColorRed,G_ColorRed,G_ColorRed,G_colorWhite}
            if cur>=max then --已完成
                colorTab={G_colorWhite,G_ColorGreen,G_ColorGreen,G_ColorGreen,G_colorWhite}
            end
            local descLb,lbHeight=G_getRichTextLabel(getlocal("ltzdz_season_taskdesc_t1",{cur,max}),colorTab,22,cellWidth-limitLb:getContentSize().width-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(limitLb:getPositionX()+limitLb:getContentSize().width,limitLb:getPositionY()+lbHeight/2)
            cell:addChild(descLb)

            -- local descLb=GetTTFLabelWrap(getlocal("ltzdz_season_taskdesc_t1",{cur,max}),22,CCSizeMake(cellWidth-limitLb:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            -- descLb:setAnchorPoint(ccp(0,0.5))
            -- descLb:setPosition(limitLb:getPositionX()+limitLb:getContentSize().width,limitLb:getPositionY())
            -- cell:addChild(descLb)

            local rewardLb=GetTTFLabel(getlocal("seasonRewardStr"),22)
            rewardLb:setAnchorPoint(ccp(0,0.5))
            rewardLb:setPosition(20,cellHeight/4)
            cell:addChild(rewardLb)

            local rewardItem=FormatItem(task.reward,nil,true)[1]
            if rewardItem then
                local rewardIcon
                if rewardItem.type=="u" then
                    rewardIcon=G_getNoBgResIcon(rewardItem)
                end
                if rewardIcon then
                    rewardIcon:setAnchorPoint(ccp(0,0.5))
                    rewardIcon:setPosition(rewardLb:getPositionX()+rewardLb:getContentSize().width,rewardLb:getPositionY())
                    cell:addChild(rewardIcon)

                    local numLb=GetTTFLabel(rewardItem.num,22)
                    numLb:setAnchorPoint(ccp(0,0.5))
                    numLb:setPosition(rewardIcon:getPositionX()+rewardIcon:getContentSize().width+10,rewardIcon:getPositionY())
                    cell:addChild(numLb)
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
    local hd=LuaEventHandler:createHandler(eventHandler)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition((self.bgSize.width-tvWidth)/2,rewardPanel:getPositionY()-tvHeight)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local function getRewardHandler()
        local cur,max,state=ltzdzVoApi:getSeasonTaskState("t1")
        if state==0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("unable_getSeasonReward"),28)
            do return end
        end
        local function handler()
            self.getItem:setEnabled(false)
            local strLb=tolua.cast(self.getItem:getChildByTag(101),"CCLabelTTF")
            if strLb then
                strLb:setString(getlocal("activity_hadReward"))
            end
        end
        ltzdzVoApi:getSeasonTaskReward("t1",handler)
    end
    local priority=-(self.layerNum-1)*20-4
    self.getItem=G_createBotton(self.bgLayer,ccp(self.bgSize.width/2,50),{getlocal("newGiftsReward")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getRewardHandler,0.7,priority)
    local cur,max,state=ltzdzVoApi:getSeasonTaskState("t1")
    if state==2 then
        self.getItem:setEnabled(false)
        local strLb=tolua.cast(self.getItem:getChildByTag(101),"CCLabelTTF")
        if strLb then
            strLb:setString(getlocal("activity_hadReward"))
        end
    end


    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),touchLuaSpr)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255*0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    self.dialogLayer:setPosition(0,0)
    sceneGame:addChild(self.dialogLayer,self.layerNum)
end

function ltzdzSeasonTaskRewardDialog:dispose()
end