acKljzTabTwo={}

function acKljzTabTwo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.normalHeight=80
    
    self.tv=nil
    self.tv2=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=1
    self.parentDialog=nil
    self.topHeight = 0
    self.isToday = true
    return nc
end

function acKljzTabTwo:init(layerNum,selectedTabIndex,parentDialog)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    spriteController:addPlist("public/taskYouhua.plist")--acKljzImage.png
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/commonBtn1.plist")
    spriteController:addTexture("public/commonBtn1.png")
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.parentDialog=parentDialog
    self.bgLayer=CCLayer:create()
    self:initTopModule()
    self:initTableView()
    return self.bgLayer
end

function acKljzTabTwo:dispose()
    self.topHeight = nil
    self.isToday = nil
    self.tv=nil
    self.tv2=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.parentDialog=nil
    self.topHeight = nil
    self.isToday = nil
    spriteController:removePlist("public/commonBtn1.plist")
    spriteController:removeTexture("public/commonBtn1.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
end

function acKljzTabTwo:initTopModule( )
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function ( ) end)
    titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,140))
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height - 160))
    self.bgLayer:addChild(titleBg,1)
    self:initTableView2(titleBg)
    self.topHeight = titleBg:getPositionY() - 140
end

function acKljzTabTwo:initTableView2(titleBg)
        local function callBack(...)
            return self:eventHandler2(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-48,132),nil)
        titleBg:setTouchPriority(-(self.layerNum-1)*20-1)
        self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv2:setPosition(ccp(4,4))
        titleBg:addChild(self.tv2)
        self.tv2:setMaxDisToBottomOrTop(0)
end
function acKljzTabTwo:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth-48,132)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local backBg=CCSprite:create("public/emblem/emblemBlackBg.jpg")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        backBg:setAnchorPoint(ccp(0,0.5))
        backBg:setPosition(ccp(0,66))
        cell:addChild(backBg)

        local nodata,acPoint=acKljzVoApi:getCurTaskedTb( )
        local maxPoint=acKljzVoApi:getMaxmovetimes( )
        local percentStr=""
        local per=tonumber(acPoint)/tonumber(maxPoint) * 100
        AddProgramTimer(cell,ccp((G_VisibleSizeWidth-48)*0.5,45),11,12,percentStr,"platWarProgressBg.png","taskBlueBar.png",13,1,1)
        local timerSpriteLv=cell:getChildByTag(11)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        local timerSpriteBg=cell:getChildByTag(13)
        timerSpriteBg=tolua.cast(timerSpriteBg,"CCSprite")

        local percentLb = GetTTFLabel(acPoint.."/"..maxPoint,23)
        percentLb:setPosition(ccp((G_VisibleSizeWidth-48)*0.5,45))
        cell:addChild(percentLb,99)

        local acSp=CCSprite:createWithSpriteFrameName("taskActiveSp.png")
        acSp:setPosition(ccp(60,45))
        cell:addChild(acSp,2)
        local acPointLb=GetBMLabel(acPoint,G_GoldFontSrc,10)
        acPointLb:setPosition(ccp(acSp:getContentSize().width/2,acSp:getContentSize().height/2-2))
        acSp:addChild(acPointLb,2)
        acPointLb:setScale(0.5)

        local topDesc = GetTTFLabelWrap(getlocal("activity_kljz_taskedDesc"),22,CCSize(460,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)--Bottom
        topDesc:setPosition(ccp((G_VisibleSizeWidth-48)*0.5,70))
        cell:addChild(topDesc)

        local todayGetLb = GetTTFLabel(getlocal("todayGetStr")..":",24)
        todayGetLb:setColor(G_ColorYellowPro)
        todayGetLb:setPosition(ccp(60,98))
        cell:addChild(todayGetLb)
        if G_getCurChoseLanguage() ~="cn" then
            todayGetLb:setAnchorPoint(ccp(0,0.5))
            todayGetLb:setPosition(ccp(10,110))

            topDesc:setFontSize(18)
            topDesc:setPositionY(80)
        end
        return cell
    end
end

function acKljzTabTwo:initTableView()
    local tvHeight=G_VisibleSizeHeight-400
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png",CCRect(16,16,1,1),function () end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-44,self.topHeight-40))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(22,25)
    self.bgLayer:addChild(tvBg)

    local function callback(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-44,self.topHeight-40),nil)
    self.tv:setPosition(ccp(22,25))
    self.bgLayer:addChild(self.tv,99)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setMaxDisToBottomOrTop(80)
end
function acKljzTabTwo:eventHandler(handler,fn,idx,cel)
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 = 23
    end
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(acKljzVoApi:getTaskTb())
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth-44,110)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellWidth = G_VisibleSizeWidth-44
        local taskTb = acKljzVoApi:getTaskTb()
        local taskType,taskNeedTimes,rewardtimes = taskTb[idx+1]["qtype"],taskTb[idx+1]["condition"],taskTb[idx+1]["rewardtimes"]
        local usedStep = acKljzVoApi:getCurTaskedTb( )[taskType] or 0
        usedStep = usedStep > taskNeedTimes and taskNeedTimes or usedStep
        local useTb = {usedStep,taskNeedTimes}
        local cellTaskLb = GetTTFLabel(getlocal("activity_chunjiepansheng_"..taskType.."_title",useTb),strSize2)
        if taskType =="gb" then--activity_chunjiepansheng_gba_title
            cellTaskLb = GetTTFLabel(getlocal("activity_chunjiepansheng_gba_title",useTb),strSize2)
        end
        cellTaskLb:setAnchorPoint(ccp(0,1))
        cellTaskLb:setPosition(ccp(15,90))
        cell:addChild(cellTaskLb,2)

        local bottomPosY = 30

        local getStr = GetTTFLabel(getlocal("activity_xuyuanlu_getGolds",{""}),21)
        getStr:setAnchorPoint(ccp(0,0.5))
        getStr:setPosition(ccp(15,bottomPosY))
        cell:addChild(getStr)

        local timeSp = CCSprite:createWithSpriteFrameName("pointIcon.png")
        timeSp:setAnchorPoint(ccp(0,0.5))
        timeSp:setScale(0.7)
        timeSp:setPosition(ccp(getStr:getContentSize().width+5 + getStr:getPositionX(),bottomPosY))
        cell:addChild(timeSp)

        local timesStr = GetTTFLabel(getlocal("activity_kljz_times",{rewardtimes}),21)
        timesStr:setAnchorPoint(ccp(0,0.5))
        timesStr:setPosition(ccp(timeSp:getContentSize().width*0.7 + timeSp:getPositionX()+5,bottomPosY))
        cell:addChild(timesStr)
        timesStr:setColor(G_ColorGreen)

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
        lineSp:setContentSize(CCSizeMake((cellWidth-4),2))
        lineSp:setPosition(cellWidth/2,1)
        cell:addChild(lineSp)

        if usedStep >= taskNeedTimes then
            local hadStr = GetTTFLabel(getlocal("ltzdz_hasget"),22)
            hadStr:setColor(G_ColorGray)
            hadStr:setAnchorPoint(ccp(0.5,0.5))
            hadStr:setPosition(ccp(cellWidth-60,55))
            cell:addChild(hadStr)
        else
            local function goTiantang()
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end

                G_goToDialog2(taskType,4,true)
            end
            local goItem=GetButtonItem("gotoBtn.png","gotoBtn_down.png","gotoBtn_down.png",goTiantang,nil)
            local goBtn=CCMenu:createWithItem(goItem);
            goBtn:setTouchPriority(-(self.layerNum-1)*20-4);
            goBtn:setPosition(ccp(cellWidth-60,55))
            cell:addChild(goBtn)
        end

        return cell
    end
end

function acKljzTabTwo:tick( )
    local vo=acKljzVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子

    end

    local todayFlag=acKljzVoApi:isToday()
    -- print("todayFlag=====>>>>",todayFlag,self.isToday)
    if self.isToday==true and todayFlag==false then
        self.isToday=false
        acKljzVoApi:setCurTaskedTb()
        if self.tv2 then        
            self.tv2:reloadData()
        end
        if self.tv then
            self.tv:reloadData()
        end
    end
end

