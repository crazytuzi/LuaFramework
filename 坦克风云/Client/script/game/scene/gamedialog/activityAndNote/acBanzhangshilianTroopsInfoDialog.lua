acBanzhangshilianTroopsInfoDialog=commonDialog:new()

function acBanzhangshilianTroopsInfoDialog:new(cIndex)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.cIndex=cIndex --关卡
    return nc
end

function acBanzhangshilianTroopsInfoDialog:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-500),nil)
    self.bgLayer:addChild(self.tv)
    self.tv:setPosition(ccp(30,120))
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)

    self:initLayer()
end

function acBanzhangshilianTroopsInfoDialog:initLayer()
    local bgWidth=self.bgLayer:getContentSize().width
    local bgHeight=self.bgLayer:getContentSize().height

    local spScaleX=1.15
    local spScaleY=1.2
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick()
    end
    local posterSp=LuaCCSprite:createWithFileName("public/Battleshow.jpg",cellClick)
    posterSp:setAnchorPoint(ccp(0.5,1))
    posterSp:setPosition(ccp(bgWidth/2,bgHeight-90))
    self.bgLayer:addChild(posterSp,1)
    posterSp:setScaleX(spScaleX)
    posterSp:setScaleY(spScaleY)

    -- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(bgWidth-40,80))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(backSprie,1)
    backSprie:setPosition(ccp(bgWidth/2,bgHeight-100-posterSp:getContentSize().height*spScaleY))
    local titleLb=GetTTFLabel(getlocal("forceInformation"),30)
    titleLb:setPosition(getCenterPoint(backSprie))
    backSprie:addChild(titleLb,1)


    local function onRankDialog()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function callback()
            acBanzhangshilianVoApi:showFullStarRankDialog(self.layerNum+1,self.cIndex)
        end
        acBanzhangshilianVoApi:getSocketLog(callback,self.cIndex)
    end
    local rankItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onRankDialog,nil,getlocal("activity_banzhangshilian_full_star_rank"),25)
    local rankMenu=CCMenu:createWithItem(rankItem)
    rankMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    rankMenu:setAnchorPoint(ccp(0.5,0.5))
    rankMenu:setPosition(ccp(200,65))
    self.bgLayer:addChild(rankMenu,3)

    local function onSetTroopsDialog()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        acBanzhangshilianVoApi:showSetTroopsDialog(self.layerNum+1,self.cIndex,self)
    end
    local setTroopsItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onSetTroopsDialog,nil,getlocal("activity_banzhangshilian_set_troops"),25)
    local setTroopsMenu=CCMenu:createWithItem(setTroopsItem)
    setTroopsMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    setTroopsMenu:setAnchorPoint(ccp(0.5,0.5))
    setTroopsMenu:setPosition(ccp(G_VisibleSizeWidth-200,65))
    self.bgLayer:addChild(setTroopsMenu,3)
end

function acBanzhangshilianTroopsInfoDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(self.bgLayer:getContentSize().width-60,710)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local bgWidth=self.bgLayer:getContentSize().width-60
        local bgHeight=700
        local background=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function () end)
        background:setContentSize(CCSizeMake(bgWidth,bgHeight))
        background:setAnchorPoint(ccp(0,0))
        background:setPosition(ccp(0,5))
        cell:addChild(background)

        local tankInfo
        local acVo=acBanzhangshilianVoApi:getAcVo()
        if self.cIndex and acVo and acVo.challengeCfg and acVo.challengeCfg[self.cIndex] then
            local cCfg=G_clone(acVo.challengeCfg[self.cIndex])
            tankInfo=cCfg.tank
        end
        local sizeLb=220*2+100+50+10
        for k=1,6 do
            --local width = 80+((k-1)%2)*280
            --local height = sizeLb-(math.floor((k+1)/2))*220
            local width = self.bgLayer:getContentSize().width-(math.ceil(k/3))*280
            local height = sizeLb-(((k-1)%3)*220+60)

            local function touchClick(hd,fn,idx)
            end
            local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("BgEmptyTank.png",CCRect(10, 10, 20, 20),touchClick)
            bgSp:setContentSize(CCSizeMake(150, 150))
            bgSp:ignoreAnchorPointForPosition(false)
            bgSp:setAnchorPoint(ccp(0,0))
            bgSp:setIsSallow(false)
            bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
            bgSp:setPosition(ccp(width,height))
            cell:addChild(bgSp,1)
            
            local txtSize=25
            local item
            if tankInfo then
                item=tankInfo[k]
            end
            if item and item[1] and item[2] then
                local tid=item[1]
                local num=item[2]
                local name,pic,desc,id,noUseIdx,eType,equipId=getItem(tid,"o")
                local icon = CCSprite:createWithSpriteFrameName(pic)
                icon:setPosition(getCenterPoint(bgSp))
                bgSp:addChild(icon,2)
                
                local str=(name).."("..tostring(num)..")"
                -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                local descLable = GetTTFLabelWrap(str,txtSize,CCSizeMake(260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                descLable:setAnchorPoint(ccp(0.5,1))
                descLable:setPosition(ccp(width+bgSp:getContentSize().width/2,height))
                cell:addChild(descLable,2)
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

function acBanzhangshilianTroopsInfoDialog:tick()
    local vo=acBanzhangshilianVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

end

function acBanzhangshilianTroopsInfoDialog:refresh()

end

function acBanzhangshilianTroopsInfoDialog:dispose()
    self.cIndex=nil
end