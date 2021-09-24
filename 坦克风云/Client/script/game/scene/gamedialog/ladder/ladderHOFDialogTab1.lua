ladderHOFDialogTab1={}
function ladderHOFDialogTab1:new(tabType)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.tabType=tabType--1是个人名人堂，2是军团名人堂
    nc.hofList={}--个人名人堂数据
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/allianceActiveImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    nc.curPage=1
    return nc
end


function ladderHOFDialogTab1:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self:initTableView()
    return self.bgLayer
end


--设置对话框里的tableView
function ladderHOFDialogTab1:initTableView()
    self:getData()
    local tvW = self.bgLayer:getContentSize().width-30
    local tvH = self.bgLayer:getContentSize().height-200
    local tvY = 35
    self:initRankList(tvW,tvH,tvY)
    self.curPage=ladderVoApi.curPage
end

-- 初始化排行榜列表
function ladderHOFDialogTab1:initRankList(tvW,tvH,tvY)
    
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvW,tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,tvY))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(10)

    local listNum = #self.hofList
    if listNum<=0 then
        local noDataDescLb=GetTTFLabelWrap(getlocal("ladder_hof_desc1"),30,CCSizeMake(tvW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noDataDescLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-80))
        self.bgLayer:addChild(noDataDescLb)
        noDataDescLb:setColor(G_ColorGray)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function ladderHOFDialogTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local listNum = #self.hofList
        if ladderVoApi:getIfHasNextHofData(ladderVoApi.curPage)==true then
            listNum=listNum+1
        end
        return listNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,360)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellW = self.bgLayer:getContentSize().width-40
        local cellH = 345
        local hofList=self.hofList
        local listNum = #self.hofList
        local ifNextSp = false
        if ladderVoApi:getIfHasNextHofData(ladderVoApi.curPage)==true then
            listNum=listNum+1
            if (idx+1)==listNum then
                ifNextSp=true
            end
        end
        print("---dmj---idx:"..idx)
        local function clickHandler()
            if ifNextSp==true then
                local function callbackHandler(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        
                        ladderVoApi.curPage=ladderVoApi.curPage+1
                        self:getData()
                        -- local recordPoint = self.tv:getRecordPoint()
                        self.tv:reloadData()
                        -- self.tv:recoverToRecordPoint(recordPoint)
                    end
                end
                socketHelper:getLadderHistory(self.curPage+1,callbackHandler)
            end
        end
        local cellBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),clickHandler)
        cell:addChild(cellBgSp)
        if ifNextSp==true then
            cellBgSp:setContentSize(CCSizeMake(cellW-30,80))
            cellBgSp:setPosition(ccp(cellW/2,cellH-45))
            local moreLb=GetTTFLabelWrap(getlocal("showMore")..(idx+1),25,CCSizeMake(cellW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            moreLb:setPosition(getCenterPoint(cellBgSp))
            cellBgSp:setTouchPriority(-(self.layerNum-1)*20-2)
            cellBgSp:addChild(moreLb,3)
        else
            cellBgSp:setContentSize(CCSizeMake(cellW-30,cellH))
            cellBgSp:setPosition(ccp(cellW/2,cellH/2))
            local firstBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(28, 30, 1, 1),function ()end)
            firstBgSp:setContentSize(CCSizeMake(cellW-10,145))
            firstBgSp:setPosition(ccp(cellW/2,cellH-60))
            cell:addChild(firstBgSp,2)

            local seasonTitleSp=CCSprite:createWithSpriteFrameName("platWarNameBg2.png")
            seasonTitleSp:setAnchorPoint(ccp(0,0.5))
            seasonTitleSp:setPosition(ccp(0,firstBgSp:getContentSize().height-seasonTitleSp:getContentSize().height/2))
            firstBgSp:addChild(seasonTitleSp,2)
            if hofList and hofList[idx+1] then
                local hofVo = hofList[idx+1]
                local lbX = 110
                local index = 1
                for k,v in pairs(hofVo.ranklist) do
                    if self.tabType==1 then
                        local photoSp = playerVoApi:getPersonPhotoSp(v.pic)
                        local scale=70/photoSp:getContentSize().width
                        photoSp:setScale(scale)
                        photoSp:setPosition(ccp(70,cellH-(index-1)*(photoSp:getContentSize().height*scale+40)-70))
                        cell:addChild(photoSp,3)
                    else
                        lbX = 20
                    end
                    if index==1 then
                        local seasonLb=GetTTFLabelWrap(getlocal("serverWarLadderSeasonTitle",{hofVo.season}),25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        seasonLb:setPosition(getCenterPoint(seasonTitleSp))
                        seasonTitleSp:addChild(seasonLb,3)
                        seasonLb:setColor(G_ColorYellowPro)

                        local timeLb=GetTTFLabelWrap(G_getDataTimeStr(hofVo.t),22,CCSizeMake(300,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
                        timeLb:setPosition(ccp(cellW-30,cellH-20))
                        timeLb:setAnchorPoint(ccp(1,0.5))
                        cell:addChild(timeLb,3)
                    end

                    local rankNameLb=GetTTFLabel(getlocal("serverwar_rank_"..v.rank).."：",25)
                    rankNameLb:setPosition(ccp(lbX,cellH-(index-1)*110-60))
                    rankNameLb:setAnchorPoint(ccp(0,0.5))
                    cell:addChild(rankNameLb,3)

                    local nameLb=GetTTFLabelWrap(v.name,25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    nameLb:setPosition(ccp(lbX+rankNameLb:getContentSize().width,cellH-(index-1)*110-60))
                    nameLb:setAnchorPoint(ccp(0,0.5))
                    cell:addChild(nameLb,3)
                    nameLb:setColor(G_ColorGreen)

                    
                    local serverIcon = CCSprite:createWithSpriteFrameName("ServerBgBtn.png")
                    serverIcon:setPosition(ccp(lbX+15,cellH-(index-1)*110-95))
                    cell:addChild(serverIcon,3)
                    serverIcon:setScale(0.3)
                    local servernameLb=GetTTFLabelWrap(GetServerNameByID(v.sid),22,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    servernameLb:setPosition(ccp(lbX+15+serverIcon:getContentSize().width*0.3*0.5,cellH-(index-1)*110-95))
                    servernameLb:setAnchorPoint(ccp(0,0.5))
                    cell:addChild(servernameLb,3)

                    local fightingSp = CCSprite:createWithSpriteFrameName("allianceAttackIcon.png")
                    fightingSp:setPosition(ccp(lbX+250,cellH-(index-1)*110-95))
                    cell:addChild(fightingSp,3)
                    fightingSp:setScale(0.7)
                    local fightingLb=GetTTFLabelWrap(FormatNumber(v.fight),22,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    fightingLb:setPosition(ccp(fightingSp:getPositionX()+fightingSp:getContentSize().width/2*0.7,cellH-(index-1)*110-95))
                    fightingLb:setAnchorPoint(ccp(0,0.5))
                    cell:addChild(fightingLb,3)

                    local rankSp
                    if tonumber(v.rank)==1 then
                        rankSp=CCSprite:createWithSpriteFrameName("top1.png")
                    elseif tonumber(v.rank)==2 then
                        rankSp=CCSprite:createWithSpriteFrameName("top2.png")
                    elseif tonumber(v.rank)==3 then
                        rankSp=CCSprite:createWithSpriteFrameName("top3.png")
                    end
                    rankSp:setPosition(ccp(cellW-60,cellH-(index-1)*110-80))
                    rankSp:setScale(0.8)
                    cell:addChild(rankSp,3)
                    
                    if index==2 then
                        local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
                        lineSp:setPosition(ccp(cellW/2,servernameLb:getPositionY()-35))
                        lineSp:setScaleX(cellW/lineSp:getContentSize().width)
                        cell:addChild(lineSp)
                    end
                    index=index+1
                end
            end
        end
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

function ladderHOFDialogTab1:getData()
    -- print("ladderHOFDialogTab1:getData()"..self.tabType)
    if self.tabType==2 then
        self.hofList=ladderVoApi:getAllianceHOFList()
    else
        self.hofList=ladderVoApi:getPersonHOFList()
    end
end

function ladderHOFDialogTab1:tick()

end

function ladderHOFDialogTab1:dispose()
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/allianceActiveImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/allianceActiveImage.pvr.ccz")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
    self.bgLayer:removeFromParentAndCleanup(true)
end