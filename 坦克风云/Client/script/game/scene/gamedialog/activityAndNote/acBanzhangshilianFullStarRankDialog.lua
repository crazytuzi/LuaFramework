acBanzhangshilianFullStarRankDialog=commonDialog:new()

function acBanzhangshilianFullStarRankDialog:new(layerNum,cIndex)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.cIndex=cIndex --关卡
    self.height=160
    self.report=nil
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    return nc
end

--设置或修改每个Tab页签
function acBanzhangshilianFullStarRankDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
end

function acBanzhangshilianFullStarRankDialog:initTableView()
    self.report=acBanzhangshilianVoApi:getReport(self.cIndex)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight - 160),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)

    local noPeopleLb = GetTTFLabelWrap(getlocal("activity_banzhangshilian_noPeople"),30,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noPeopleLb:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(noPeopleLb)
    noPeopleLb:setColor(G_ColorYellowPro)
    self.noPeopleLb=noPeopleLb

    if self.num and self.num~=0 then
        noPeopleLb:setVisible(false)
    else
        noPeopleLb:setVisible(true)
    end
    
end

function acBanzhangshilianFullStarRankDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if self.report==nil then
            self.num=0
        else
            self.num=SizeOfTable(self.report)
        end
        return self.num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-70,self.height)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)

        local function nilFunc()
        end
        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,nilFunc)
        headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.height-10))
        headerSprie:ignoreAnchorPointForPosition(false)
        headerSprie:setAnchorPoint(ccp(0,0))
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height/2))
        cell:addChild(headerSprie)

        -- 时间
        local timeChuo = tonumber(self.report[idx+1].ts)
        local timeLb = GetTTFLabel(G_getDataTimeStr(timeChuo),25)
        timeLb:setAnchorPoint(ccp(0.5,0))
        timeLb:setPosition(ccp(headerSprie:getContentSize().width/2,headerSprie:getContentSize().height/2))
        headerSprie:addChild(timeLb)
        timeLb:setColor(G_ColorGreen2)

        local lbHeight=headerSprie:getContentSize().height-10
        local lbWidth=100

        local nameStr = self.report[idx+1].name
        local nameLb = GetTTFLabel(nameStr,28)
        nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setPosition(ccp(lbWidth,headerSprie:getContentSize().height/2-10))
        headerSprie:addChild(nameLb)

       
        local rankStr = idx+1 .. "th"
        local rankLb=GetTTFLabel(rankStr,28)
        rankLb:setPosition(ccp(lbWidth,headerSprie:getContentSize().height/2+10))
        rankLb:setAnchorPoint(ccp(0.5,0))
        cell:addChild(rankLb)
        rankLb:setColor(G_ColorYellow)

        local rankSp
        if idx+1==1 then
            rankSp=CCSprite:createWithSpriteFrameName("top1.png")
        elseif idx+1==2 then
            rankSp=CCSprite:createWithSpriteFrameName("top2.png")
        elseif idx+1==3 then
            rankSp=CCSprite:createWithSpriteFrameName("top3.png")
        end
        if rankSp then
            rankSp:setAnchorPoint(ccp(0.5,1))
            rankSp:setPosition(ccp(lbWidth,lbHeight))
            cell:addChild(rankSp,2)
            rankLb:setVisible(false)
        end

       
        --播放战斗动画按钮
        local function touchAction(tag,object )
             if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                self:showBattle(idx+1)
            end
            
        end 
        local actionTouchFir = GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn.png",touchAction,nil,nil,0)
        actionTouchFir:setAnchorPoint(ccp(1,0.5))
        local actionTouchFirMenu = CCMenu:createWithItem(actionTouchFir)
        actionTouchFirMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        actionTouchFirMenu:setPosition(ccp(headerSprie:getContentSize().width-10,headerSprie:getContentSize().height/2))
        headerSprie:addChild(actionTouchFirMenu)


        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acBanzhangshilianFullStarRankDialog:showBattle(idx)
    local isAttacker=true
    local acData={type="banzhangshilian"}
    local landform
    local acVo=acBanzhangshilianVoApi:getAcVo()
    local challengeCfg=acVo.challengeCfg
    if self.cIndex and challengeCfg and challengeCfg[self.cIndex] then
        if challengeCfg[self.cIndex].land and tonumber(challengeCfg[self.cIndex].land) then
            local landType=tonumber(challengeCfg[self.cIndex].land)
            landform={landType,landType}
        end
    end
    local data={data={report=self.report[idx].report},isAttacker=isAttacker,isReport=true,acData=acData,landform=landform}
    battleScene:initData(data)
end

function acBanzhangshilianFullStarRankDialog:tick()
    local vo=acBanzhangshilianVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    if self.num and self.num==0 then
        if self.noPeopleLb then
            if self.noPeopleLb:isVisible()==false then
                self.noPeopleLb:setVisible(true)
            end
        end
    end
end




function acBanzhangshilianFullStarRankDialog:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.report=nil
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end