localWarDialogTab2={}

function localWarDialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeight=1200
    -- self.officeStatus=0

    return nc
end

function localWarDialogTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    localWarVoApi:updateOffice()
    self:initTableView()
    return self.bgLayer
end

function localWarDialogTab2:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-195),nil)
    self.bgLayer:addChild(self.tv)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(20,30))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)
end

function localWarDialogTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth-40,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth=G_VisibleSizeWidth-40
        local cellHeight=self.cellHeight
        local curPosY=cellHeight

        local allianceName=getlocal("fight_content_null")
        local ownCityInfo=localWarVoApi:getOwnCityInfo()
        if ownCityInfo and ownCityInfo.own_at and base.serverTime<tonumber(ownCityInfo.own_at) and ownCityInfo.name then
            allianceName=ownCityInfo.name
        end

        local function cellClick1(hd,fn,idx)
        end
        local titleSp1=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),cellClick1)
        titleSp1:setContentSize(CCSizeMake(cellWidth,60))
        titleSp1:ignoreAnchorPointForPosition(false)
        titleSp1:setAnchorPoint(ccp(0.5,1))
        titleSp1:setIsSallow(false)
        titleSp1:setTouchPriority(-(self.layerNum-1)*20-2)
        titleSp1:setPosition(ccp(cellWidth/2,curPosY))
        cell:addChild(titleSp1,1)
        local titleLb1=GetTTFLabel(allianceName,30)
        titleLb1:setAnchorPoint(ccp(0.5,0.5))
        titleLb1:setPosition(getCenterPoint(titleSp1))
        titleSp1:addChild(titleLb1)
        curPosY=curPosY-titleSp1:getContentSize().height
        
        
        local function showKingInfo( ... )
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                localWarVoApi:showOfficeInfoDialog(self.layerNum+1,1)
            end
        end
        local bgSp=CCSprite:create("public/localWar/TrialSquadDrawing.jpg")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setPosition(ccp(cellWidth/2,curPosY))
        cell:addChild(bgSp)
        bgSp:setScale((cellWidth-5)/bgSp:getContentSize().width)
        local kingSpBg=LuaCCSprite:createWithSpriteFrameName("RegionalWarBox3.png",showKingInfo)
        kingSpBg:setTouchPriority(-(self.layerNum-1)*20-2)
        kingSpBg:setAnchorPoint(ccp(0.5,1))
        kingSpBg:setPosition(ccp(cellWidth/2,curPosY-0))
        cell:addChild(kingSpBg)
        local kingSp
        local kingInfo=localWarVoApi:getOfficeByType(1)
        if kingInfo and kingInfo[5] then
            -- local photoPic="public/man.png"
            -- if tonumber(kingInfo[5])==1 then
            --     photoPic="public/man.png"
            -- elseif tonumber(kingInfo[5])==2 then
            --     photoPic="public/woman.png"
            -- end
            -- kingSp=CCSprite:create(photoPic)
            -- kingSp:setScale(0.35)

            kingSp=playerVoApi:getPersonPhotoSp(kingInfo[5])
            -- kingSp:getScale(2)
            local scale=kingSp:getScale()
            kingSp:setScale(scale*2)
        else
            kingSp=CCSprite:createWithSpriteFrameName("Office1.png")
        end
        kingSp:setPosition(ccp(kingSpBg:getContentSize().width/2,kingSpBg:getContentSize().height/2+20))
        kingSpBg:addChild(kingSp)
        curPosY=curPosY-bgSp:getContentSize().height
        local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick1)
        lbBg:setContentSize(CCSizeMake(kingSpBg:getContentSize().width-10,50))
        lbBg:setAnchorPoint(ccp(0.5,0))
        lbBg:setPosition(ccp(kingSpBg:getContentSize().width/2,5))
        kingSpBg:addChild(lbBg,1)
        local kingLb=GetTTFLabel(getlocal("local_war_office_1"),20)
        kingLb:setAnchorPoint(ccp(0.5,0))
        kingLb:setPosition(ccp(lbBg:getContentSize().width/2,26))
        lbBg:addChild(kingLb,1)
        if kingInfo and kingInfo[2] then
            local kingName=kingInfo[2] or ""
            local kingNameLb=GetTTFLabel(kingName,20)
            kingNameLb:setAnchorPoint(ccp(0.5,0))
            kingNameLb:setPosition(ccp(lbBg:getContentSize().width/2,1))
            lbBg:addChild(kingNameLb,1)
        end



        
        local titleSp2=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),cellClick1)
        titleSp2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,60))
        titleSp2:ignoreAnchorPointForPosition(false)
        titleSp2:setAnchorPoint(ccp(0.5,1))
        titleSp2:setIsSallow(false)
        titleSp2:setTouchPriority(-(self.layerNum-1)*20-2)
        titleSp2:setPosition(ccp(cellWidth/2,curPosY))
        cell:addChild(titleSp2,1)
        local titleLb2=GetTTFLabel(getlocal("local_war_help_title8"),30)
        titleLb2:setAnchorPoint(ccp(0.5,0.5))
        titleLb2:setPosition(getCenterPoint(titleSp2))
        titleSp2:addChild(titleLb2)
        curPosY=curPosY-titleSp2:getContentSize().height

        local titSize1 = 12
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
            titSize1 =16
        end

        for i=1,8 do
            local index=i+1
            local function onClickSetOffice()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    if localWarVoApi:canSetOffice(index)==true then
                        localWarVoApi:showSetOfficeDialog(self.layerNum+1,index)
                    else
                        localWarVoApi:showOfficeInfoDialog(self.layerNum+1,index)
                    end
                end
            end
            if localWarCfg.jobs and localWarCfg.jobs[index] then
                local officeBg=LuaCCSprite:createWithSpriteFrameName("RegionalWarBox2.png",onClickSetOffice)
                officeBg:setTouchPriority(-(self.layerNum-1)*20-2)
                local spaceX=(cellWidth-officeBg:getContentSize().width*4)/4
                local posX=spaceX/2+officeBg:getContentSize().width/2+((i-1)%4)*(spaceX+officeBg:getContentSize().width)
                local spaceY=10
                local firstY=curPosY-spaceY/2-officeBg:getContentSize().height/2
                local posY=firstY-math.floor((i-1)/4)*(spaceY+officeBg:getContentSize().height)
                officeBg:setPosition(ccp(posX,posY))
                cell:addChild(officeBg,1)


                local pic=localWarCfg.jobs[index].pic
                local title=getlocal(localWarCfg.jobs[index].title)
                local playerInfo=localWarVoApi:getOfficeByType(index)
                local playerName
                if playerInfo and playerInfo[2] then
                    playerName=playerInfo[2]
                end
                -- local scale=1
                -- print("playerName",playerName)
                -- if playerName and type(playerName)=="string" then
                --     if playerInfo[5] then
                --         -- pic="photo"..playerInfo[5]..".png"
                --         scale=1.3
                --     end
                -- end
                if pic and title then
                    local officeSp
                    if playerInfo and playerInfo[5] then
                        officeSp=playerVoApi:getPersonPhotoSp(playerInfo[5])
                        local scale=officeSp:getScale()
                        officeSp:setScale(scale*1.3)
                    else
                        officeSp=CCSprite:createWithSpriteFrameName(pic)
                    end
                    officeSp:setPosition(ccp(officeBg:getContentSize().width/2+5,officeBg:getContentSize().height-65))
                    -- officeSp:setScale(scale)
                    officeBg:addChild(officeSp)
                    -- local titleLb=GetTTFLabel(title,16)

                    local titleLb =GetTTFLabelWrap(title,titSize1,CCSizeMake(130, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    titleLb:setAnchorPoint(ccp(0.5,0.5))
                    titleLb:setPosition(ccp(officeBg:getContentSize().width/2,50))
                    officeBg:addChild(titleLb)
                    
                    if playerName and type(playerName)=="string" then
                        local nameLb=GetTTFLabel(playerName,16)
                        nameLb:setAnchorPoint(ccp(0.5,0.5))
                        nameLb:setPosition(ccp(officeBg:getContentSize().width/2,30))
                        officeBg:addChild(nameLb)
                    end
                end

                if i==8 then
                    curPosY=curPosY-officeBg:getContentSize().height*2-spaceY*2
                end
            end
        end

        local titleSp3=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),cellClick1)
        titleSp3:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,60))
        titleSp3:ignoreAnchorPointForPosition(false)
        titleSp3:setAnchorPoint(ccp(0.5,1))
        titleSp3:setIsSallow(false)
        titleSp3:setTouchPriority(-(self.layerNum-1)*20-2)
        titleSp3:setPosition(ccp(cellWidth/2,curPosY))
        cell:addChild(titleSp3,1)
        local titleLb3=GetTTFLabel(getlocal("local_war_office_slave"),30)
        titleLb3:setAnchorPoint(ccp(0.5,0.5))
        titleLb3:setPosition(getCenterPoint(titleSp3))
        titleSp3:addChild(titleLb3)
        curPosY=curPosY-titleSp3:getContentSize().height

        local slaveType=10
        if localWarCfg.jobs and localWarCfg.jobs[slaveType] then
            local slaveNum=localWarCfg.jobs[slaveType].count
            for i=1,slaveNum do
                -- local playerInfoTab=localWarVoApi:getOfficeByType(slaveType,i)
                local function onClickSetSlave()
                    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)

                        if localWarVoApi:canSetOffice(slaveType,i)==true then
                            localWarVoApi:showSetOfficeDialog(self.layerNum+1,slaveType,i)
                        else
                            localWarVoApi:showOfficeInfoDialog(self.layerNum+1,slaveType,i)
                        end
                    end
                end

                local slaveBg=LuaCCSprite:createWithSpriteFrameName("RegionalWarBox1.png",onClickSetSlave)
                slaveBg:setTouchPriority(-(self.layerNum-1)*20-2)
                local spaceX=(cellWidth-slaveBg:getContentSize().width*4)/4
                local posX=spaceX/2+slaveBg:getContentSize().width/2+((i-1)%4)*(spaceX+slaveBg:getContentSize().width)
                local spaceY=10
                local firstY=curPosY-spaceY/2-slaveBg:getContentSize().height/2
                local posY=firstY-math.floor((i-1)/4)*(spaceY+slaveBg:getContentSize().height)
                slaveBg:setPosition(ccp(posX,posY))
                cell:addChild(slaveBg,1)

                local pic="Office"..slaveType..".png"
                local title=getlocal("local_war_office_"..slaveType)
                local playerInfo=localWarVoApi:getOfficeByType(10,i)
                local playerName
                if playerInfo and playerInfo[2] then
                    playerName=playerInfo[2]
                end
                -- local scale=1
                -- if playerName and type(playerName)=="string" then
                --     if playerInfo[5] then
                --         -- pic="photo"..playerInfo[5]..".png"
                --         scale=1.3
                --     end
                -- end
                if pic and title then
                    local slaveSp
                    if playerInfo and playerInfo[5] then
                        slaveSp=playerVoApi:getPersonPhotoSp(playerInfo[5])
                        local scale=slaveSp:getScale()
                        slaveSp:setScale(scale*1.3)
                    else
                        slaveSp=CCSprite:createWithSpriteFrameName(pic)
                    end
                    slaveSp:setPosition(ccp(slaveBg:getContentSize().width/2+5,slaveBg:getContentSize().height-65))
                    -- slaveSp:setScale(scale)
                    slaveBg:addChild(slaveSp)
                    local titleLb=GetTTFLabel(title,16)
                    titleLb:setAnchorPoint(ccp(0.5,0.5))
                    titleLb:setPosition(ccp(slaveBg:getContentSize().width/2,50))
                    slaveBg:addChild(titleLb)
                end

                if playerName and type(playerName)=="string" then
                    local nameLb=GetTTFLabel(playerName,16)
                    nameLb:setAnchorPoint(ccp(0.5,0.5))
                    nameLb:setPosition(ccp(slaveBg:getContentSize().width/2,30))
                    slaveBg:addChild(nameLb)
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
    end
end

function localWarDialogTab2:refresh()

end

function localWarDialogTab2:tick()
    localWarVoApi:updateOffice()
    if self and self.tv and localWarVoApi:getOfficeFlag()==0 then
        localWarVoApi:setOfficeFlag(1)
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function localWarDialogTab2:dispose()
    self.bgLayer=nil
    self.layerNum=nil
end
