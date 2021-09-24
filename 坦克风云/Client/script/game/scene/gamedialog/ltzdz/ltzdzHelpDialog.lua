ltzdzHelpDialog=commonDialog:new()

function ltzdzHelpDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzHelpDialog:initTableView()
    self.panelLineBg:setVisible(false)

    local topBgSprite=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function()end)
    topBgSprite:setContentSize(CCSizeMake(616,100))
    topBgSprite:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-150)
    self.bgLayer:addChild(topBgSprite)

    local season=ltzdzVoApi.clancrossinfo.season
    local seasonStr=getlocal("ltzdz_season",{season})
    local seasonLb=GetTTFLabelWrap(seasonStr,30,CCSizeMake(G_VisibleSize.width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    seasonLb:setPosition(G_VisibleSize.width/2,G_VisibleSize.height-110-seasonLb:getContentSize().height/2)
    seasonLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(seasonLb)

    local lefttime=ltzdzVoApi:getSeasonEt()
    local seasonEndLb=GetTTFLabelWrap(getlocal("ltzdz_season_endStr",{GetTimeStr(lefttime)}),25,CCSizeMake(G_VisibleSize.width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    seasonEndLb:setPosition(G_VisibleSize.width/2,seasonLb:getPositionY()-seasonLb:getContentSize().height/2-seasonEndLb:getContentSize().height/2-10)
    -- seasonEndLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(seasonEndLb)
    self.seasonEndLb=seasonEndLb

    local warCfg=ltzdzVoApi:getWarCfg()
    local giveupTime=warCfg.surTime
    local marchOilCost=warCfg.marchOilCost
    local lastTime,standTime,warTime,timeCfg=ltzdzVoApi:getWarTime()
    self.tvWidth,self.tvHeight=G_VisibleSize.width,G_VisibleSize.height-300
    self.helpConf={
        {1,6,8},
        {1,6,1},
        {1,1,5,4,3,1},
        {1,4},
    }
    self.argsCfg={
        arg_1_1_1={warCfg.rankLast},
        arg_1_2_1={math.floor(lastTime/3600),math.floor(standTime/3600),math.floor(warTime/3600)},
        arg_1_2_4={G_getFormatDate(timeCfg[1][1]),G_getFormatDate(timeCfg[1][2]),G_getFormatDate(timeCfg[1][3])},
        arg_1_2_5={G_getFormatDate(timeCfg[2][1]),G_getFormatDate(timeCfg[2][2]),G_getFormatDate(timeCfg[2][3])},
        arg_1_2_6={G_getFormatDate(timeCfg[3][1]),G_getFormatDate(timeCfg[3][2]),G_getFormatDate(timeCfg[3][3])},
        arg_1_3_6={math.floor(giveupTime/60)},
        arg_1_3_7={warCfg.K,warCfg.rankPrt},
        -- arg_2_2_6={},
        arg_3_5_2={(marchOilCost[2]/marchOilCost[1])*100},
    }
    self.imageBgWidth,self.imageBgHeight=550,500
    self.imageCfg={ --explainNum:每张图片对应的注解个数
        {explainNum={1,3,2},labelWrapTb={
            -- 文字,字号,显示区域宽度,坐标,颜色,是否添加文字背景
            {{getlocal("ltzdz_help_image_content_1_1_1"),18,215,ccp(245,357),G_ColorGray},
             {getlocal("ltzdz_help_image_content_1_1_2"),20,235,ccp(245,260),G_ColorWhite}},
            {{getlocal("ltzdz_help_image_content_1_2_1"),18,165,ccp(122,335),G_ColorWhite},
             {getlocal("ltzdz_help_image_content_1_2_2"),18,95,ccp(75,71),G_ColorWhite},
             {getlocal("ltzdz_help_image_content_1_2_3"),18,95,ccp(305,71),G_ColorWhite}},
            {{getlocal("ltzdz_help_image_content_1_3_1"),18,360,ccp(245,367),G_ColorWhite},
             {getlocal("ltzdz_help_image_content_1_3_2"),18,360,ccp(245,175),G_ColorWhite}}
        }},
        {},
        {explainNum={4,5,1,2,3},labelWrapTb={
            {{getlocal("ltzdz_help_image_content_3_1_1"),18,70,ccp(245,242),G_ColorWhite,true},
             {getlocal("ltzdz_help_image_content_3_1_2"),18,70,ccp(82,90),G_ColorWhite,true},
             {getlocal("ltzdz_help_image_content_3_1_3"),18,70,ccp(245,90),G_ColorWhite,true},
             {getlocal("ltzdz_help_image_content_3_1_4"),18,90,ccp(405,90),G_ColorWhite,true}},
            {{getlocal("ltzdz_help_image_content_3_2_1"),18,126,ccp(105,298),G_ColorWhite}},
            {{getlocal("ltzdz_help_image_content_3_3_1"),18,85,ccp(53,345),G_ColorWhite},
             {getlocal("ltzdz_help_image_content_3_3_2"),20,135,ccp(415,346),G_ColorWhite},
             {getlocal("ltzdz_help_image_content_3_3_3"),18,90,ccp(143,223),G_ColorWhite}},
            {},
            {},
        }},
        {},
    }
    self:preloadImage()
    self.cellNum=SizeOfTable(self.helpConf)
    self.imageCellHeightTb={}
    self:getImageCellHeight()
    self.cellHeightTb={}
    self:getCellHeight()

    self.allTabBtn={}
    local tabBtn=CCMenu:create()
    for i=1,self.cellNum do
        local tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
        tabBtnItem:setAnchorPoint(ccp(0,1))
        tabBtnItem:setPosition(12+(i-1)*(tabBtnItem:getContentSize().width+4),topBgSprite:getPositionY()-topBgSprite:getContentSize().height/2-10)
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(i)

        local titleStr=getlocal("ltzdz_help_title"..i)
        local lb=GetTTFLabelWrap(titleStr,24,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
        tabBtnItem:addChild(lb,1)

        local function tabClick(idx)
            PlayEffect(audioCfg.mouseClick)
            return self:tabBtnClick(idx)
        end
        tabBtnItem:registerScriptTapHandler(tabClick)
        self.allTabBtn[i]=tabBtnItem
    end
    tabBtn:setPosition(0,0)
    tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tabBtn)
    local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,topBgSprite:getPositionY()-topBgSprite:getContentSize().height-10)
    self.bgLayer:addChild(tabLine)

    self:tabBtnClick(1)
end

function ltzdzHelpDialog:tabBtnClick(idx)
    for k,v in pairs(self.allTabBtn) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabBtnIndex=idx
        else
            v:setEnabled(true)
        end
    end
    self.curShowImageIndex=1
    if self.tv then
        self.tv:reloadData()
    else
        self:initHelpLayer()
    end
end

function ltzdzHelpDialog:preloadImage()
    if self.imageCfg then
        for k, v in pairs(self.imageCfg) do
            if v.explainNum then
                for i, j in pairs(v.explainNum) do
                    local imageFileName="yh_ltzdzHelp_image_"..k.."_"..i..".jpg"
                    local url=G_downloadUrl("function/"..imageFileName)
                    LuaCCWebImage:createWithURL(url,function(fn,imageSp)
                        if self.imageSize==nil then
                            self.imageSize=imageSp:getContentSize()
                        end
                    end)
                end
            end
        end
    end
end

function ltzdzHelpDialog:createPageView()
    local imageCfg = self.imageCfg[self.selectedTabBtnIndex]
    local imageNum = imageCfg.explainNum and SizeOfTable(imageCfg.explainNum) or 0
    if self.curShowImageIndex==nil then
        self.curShowImageIndex=1
    end
    if self.curShowImageIndex>imageNum then
        self.curShowImageIndex=imageNum
    end
    local imageFileName="yh_ltzdzHelp_image_"..self.selectedTabBtnIndex.."_"..self.curShowImageIndex..".jpg"

    local viewSize=CCSizeMake(self.imageBgWidth,self.imageBgHeight)
    local pageLayer = CCLayer:create()
    -- pageLayer:setContentSize(viewSize)
    pageLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth,viewSize.height))

    local bgSprite = LuaCCScale9Sprite:createWithSpriteFrameName("newSmallPanelBg3.png",CCRect(121,44,1,1),function()end)
    bgSprite:setContentSize(viewSize)
    bgSprite:setPosition(pageLayer:getContentSize().width/2,viewSize.height/2)
    pageLayer:addChild(bgSprite)
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitleBg3.png",CCRect(73,20,1,1),function ()end)
    titleBg:setContentSize(CCSizeMake(322,titleBg:getContentSize().height))
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height)
    bgSprite:addChild(titleBg)
    local titleStr=getlocal("ltzdz_help_image_title_"..self.selectedTabBtnIndex.."_"..self.curShowImageIndex)
    local titleLb=GetTTFLabelWrap(titleStr,24,CCSizeMake(titleBg:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    titleLb:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2)
    titleBg:addChild(titleLb)
    local clipper=CCClippingNode:create()
    clipper:setContentSize(self.imageSize or CCSizeMake(490,390))
    clipper:setAnchorPoint(ccp(0.5,0))
    clipper:setPosition(pageLayer:getContentSize().width/2,55)
    clipper:setStencil(CCDrawNode:getAPolygon(clipper:getContentSize(),1,1)) --遮罩
    -- bgSprite:addChild(clipper)
    pageLayer:addChild(clipper)

    local function initImageTextContent(sprite)
        if sprite:getChildByTag(100) then
            do return end
        end
        if imageCfg.labelWrapTb and imageCfg.labelWrapTb[self.curShowImageIndex] then
            for k,v in pairs(imageCfg.labelWrapTb[self.curShowImageIndex]) do
                local label=GetTTFLabelWrap(v[1],v[2],CCSizeMake(v[3],0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
                label:setAnchorPoint(ccp(0.5,0.5))
                label:setPosition(v[4])
                label:setColor(v[5])
                label:setTag(100)
                sprite:addChild(label,1)
                if v[6] then
                    local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
                    lbBg:setContentSize(label:getContentSize())
                    lbBg:setPosition(label:getPositionX(),label:getPositionY()-3)
                    lbBg:setOpacity(180)
                    sprite:addChild(lbBg)
                end
            end
        end
    end

    -- local infoSp=CCSprite:create("allianceWar/"..imageFileName)
    local infoSp
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    LuaCCWebImage:createWithURL(G_downloadUrl("function/"..imageFileName),function(fn,imageSp)
        if self and tolua.cast(clipper,"CCNode") then
            imageSp:setAnchorPoint(ccp(0.5,0))
            imageSp:setPosition(imageSp:getContentSize().width/2,0)
            -- bgSprite:addChild(imageSp)
            clipper:addChild(imageSp)
            initImageTextContent(imageSp)
            infoSp=imageSp
        end
    end)
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    if imageNum>1 then
        local onPage
        local pointSpace=30
        local _pointStartX
        local pointSpTb={}
        for i=1,imageNum do
            local pointPic="pagePoint.png"
            if self.curShowImageIndex==i then
                pointPic="pagePointLight.png"
            end
            local pointSp=CCSprite:createWithSpriteFrameName(pointPic)
            if _pointStartX==nil then
                _pointStartX=bgSprite:getContentSize().width-(pointSp:getContentSize().width*imageNum+pointSpace*(imageNum-1))
                _pointStartX=_pointStartX/2+pointSp:getContentSize().width/2
            end
            pointSp:setPosition(_pointStartX,28)
            bgSprite:addChild(pointSp)
            pointSpTb[i]=pointSp
            _pointStartX=_pointStartX+pointSp:getContentSize().width+pointSpace
        end

        local function leftAndRightBtnAction(_btnMenu,_flag)
            local posX,posY=_btnMenu:getPosition()
            local posX2=posX+_flag*20

            local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
            local fadeIn=CCFadeIn:create(0.5)
            local carray=CCArray:create()
            carray:addObject(mvTo)
            carray:addObject(fadeIn)
            local spawn=CCSpawn:create(carray)

            local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
            local fadeOut=CCFadeOut:create(0.5)
            local carray2=CCArray:create()
            carray2:addObject(mvTo2)
            carray2:addObject(fadeOut)
            local spawn2=CCSpawn:create(carray2)

            local seq=CCSequence:createWithTwoActions(spawn2,spawn)
            _btnMenu:runAction(CCRepeatForever:create(seq))
        end

        local function pageBtnHandler(tag,obj)
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if onPage then
                onPage(tag)
            end
        end
        local leftBtn=GetButtonItem("vipArrow.png","vipArrow.png","vipArrow.png",pageBtnHandler,-1)
        leftBtn:setRotation(180)
        local leftMenu=CCMenu:createWithItem(leftBtn)
        leftMenu:setAnchorPoint(ccp(0.5,0.5))
        leftMenu:setPosition(-15,bgSprite:getContentSize().height/2)
        leftMenu:setTouchPriority(-(self.layerNum-1)*20-3)
        bgSprite:addChild(leftMenu)

        local rightBtn=GetButtonItem("vipArrow.png","vipArrow.png","vipArrow.png",pageBtnHandler,1)
        local rightMenu=CCMenu:createWithItem(rightBtn)
        rightMenu:setAnchorPoint(ccp(0.5,0.5))
        rightMenu:setPosition(bgSprite:getContentSize().width+15,bgSprite:getContentSize().height/2)
        rightMenu:setTouchPriority(-(self.layerNum-1)*20-3)
        bgSprite:addChild(rightMenu)

        leftAndRightBtnAction(leftMenu,1)
        leftAndRightBtnAction(rightMenu,-1)

        local moveMinDis=50
        local priority = -(self.layerNum-1)*20-4
        local _isRunning=false

        onPage=function(_flag)
            -- if _flag==-1 then --左
            -- elseif _flag==1 then --右
            -- end
            if _isRunning then
                do return end
            end
            _isRunning=true
            self.curShowImageIndex=self.curShowImageIndex+_flag
            if self.curShowImageIndex<=0 then
                self.curShowImageIndex=imageNum
            end
            if self.curShowImageIndex>imageNum then
                self.curShowImageIndex=1
            end
            imageFileName="yh_ltzdzHelp_image_"..self.selectedTabBtnIndex.."_"..self.curShowImageIndex..".jpg"
            -- local nextInfoSp=CCSprite:create("allianceWar/"..imageFileName)
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
            LuaCCWebImage:createWithURL(G_downloadUrl("function/"..imageFileName),function(fn,nextInfoSp)
                if self and tolua.cast(clipper,"CCNode") then
                    nextInfoSp:setAnchorPoint(ccp(0.5,0))
                    nextInfoSp:setPosition(clipper:getContentSize().width/2+_flag*clipper:getContentSize().width,0)
                    -- bgSprite:addChild(nextInfoSp)
                    clipper:addChild(nextInfoSp)
                    initImageTextContent(nextInfoSp)
                    if infoSp then
                        local arr=CCArray:create()
                        arr:addObject(CCMoveBy:create(0.5,ccp(-_flag*infoSp:getContentSize().width,0)))
                        arr:addObject(CCDelayTime:create(0.3))
                        arr:addObject(CCCallFunc:create(function()end))
                        infoSp:runAction(CCSequence:create(arr))
                    end
                    local arr=CCArray:create()
                    arr:addObject(CCMoveBy:create(0.5,ccp(-_flag*nextInfoSp:getContentSize().width,0)))
                    arr:addObject(CCDelayTime:create(0.3))
                    arr:addObject(CCCallFunc:create(function()
                        titleLb:setString(getlocal("ltzdz_help_image_title_"..self.selectedTabBtnIndex.."_"..self.curShowImageIndex))
                        for k,v in pairs(pointSpTb) do
                            local pointPic="pagePoint.png"
                            if self.curShowImageIndex==k then
                                pointPic="pagePointLight.png"
                            end
                            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(pointPic)
                            if frame then
                                v:setDisplayFrame(frame)
                            end
                        end
                        if infoSp then
                            infoSp:removeFromParentAndCleanup(true)
                        end
                        nextInfoSp:removeFromParentAndCleanup(true)
                        self.tv:reloadData()
                        _isRunning=false
                    end))
                    nextInfoSp:runAction(CCSequence:create(arr))
                end
            end)
            -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            --[[
            infoSp:removeFromParentAndCleanup(true)
            infoSp=nil
            titleLb:setString(getlocal("ltzdz_help_image_title_"..self.selectedTabBtnIndex.."_"..self.curShowImageIndex))
            infoSp=CCSprite:create("allianceWar/"..imageFileName)
            infoSp:setAnchorPoint(ccp(0.5,0))
            infoSp:setPosition(viewSize.width/2,55)
            bgSprite:addChild(infoSp)
            initImageTextContent(infoSp)
            for k,v in pairs(pointSpTb) do
                local pointPic="pagePoint.png"
                if self.curShowImageIndex==k then
                    pointPic="pagePointLight.png"
                end
                v:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(pointPic))
            end
            self.tv:reloadData()
            --]]
        end

        --左右滑动逻辑
        --[[
        local beganPos
        local function touchHandler(fn,x,y,touch)
            if _isRunning then
                do return end
            end
            if fn=="began" then
                -- if not (self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false) then
                --     return 0
                -- end
                local pos = pageLayer:getParent():convertToWorldSpace(ccp(pageLayer:getPositionX(),pageLayer:getPositionY()))
                if x>=pos.x and x<=pos.x+viewSize.width and y>=pos.y and y<=pos.y+viewSize.height then
                else
                    return 0
                end
                -- if beganPos then
                --     return 0
                -- end
                beganPos=ccp(x,y)
                return 1
            elseif fn=="moved" then
            elseif fn=="ended" then
                local moveDis=ccpSub(ccp(x,y),beganPos)
                if moveDis.x>moveMinDis then --左
                    onPage(-1)
                elseif moveDis.x<-moveMinDis then --右
                    onPage(1)
                end
            end
        end
        pageLayer:setTouchEnabled(true)
        pageLayer:registerScriptTouchHandler(touchHandler,false,priority,false)
        pageLayer:setTouchPriority(priority)
        --]]
    end

    return pageLayer
end

function ltzdzHelpDialog:initHelpLayer()
    local function eventHandler(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(eventHandler)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp((G_VisibleSize.width-self.tvWidth)/2,30))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function ltzdzHelpDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        -- return self.cellNum
        return 2
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if idx==0 then
            tmpSize=CCSizeMake(self.tvWidth,self.imageCellHeightTb[self.selectedTabBtnIndex][self.curShowImageIndex])
        else
            tmpSize=CCSizeMake(self.tvWidth,self.cellHeightTb[self.selectedTabBtnIndex])
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        if idx==0 then
            local imageCfg=self.imageCfg[self.selectedTabBtnIndex]
            if imageCfg.explainNum then
                local cellWidth=self.tvWidth
                local cellHeight=self.imageCellHeightTb[self.selectedTabBtnIndex][self.curShowImageIndex]

                local pageView = self:createPageView()
                pageView:setPosition((cellWidth-pageView:getContentSize().width)/2,cellHeight-10-pageView:getContentSize().height)
                cell:addChild(pageView)

                local _posY=pageView:getPositionY()-10
                for i=1,imageCfg.explainNum[self.curShowImageIndex] do
                    local numSp=CCSprite:createWithSpriteFrameName("yh_ltzdzHelp_number"..i..".png")
                    numSp:setAnchorPoint(ccp(0,1))
                    numSp:setPosition((self.tvWidth-self.imageBgWidth)/2,_posY)
                    numSp:setScale(28/numSp:getContentSize().height)
                    cell:addChild(numSp)
                    local strKey="ltzdz_help_image_explain_"..self.selectedTabBtnIndex.."_"..self.curShowImageIndex.."_"..i
                    local contentLb,lbheight=self:getContentLb(getlocal(strKey),self.imageBgWidth-28)
                    contentLb:setAnchorPoint(ccp(0,1))
                    contentLb:setPosition(numSp:getPositionX()+numSp:getContentSize().width*numSp:getScale(),_posY)
                    cell:addChild(contentLb)
                    _posY=_posY-lbheight-5
                end

                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function () end)
                lineSp:setContentSize(CCSizeMake(cellWidth-4,2))
                lineSp:setPosition(cellWidth/2,0)
                cell:addChild(lineSp)
            end

            return cell
        end

        local cellHeight=self.cellHeightTb[self.selectedTabBtnIndex]

        local wzposY=cellHeight
        local conf=self.helpConf[self.selectedTabBtnIndex]
        for k,v in pairs(conf) do
            wzposY=wzposY-10
            local subTitleKey="ltzdz_help_subtitle_"..self.selectedTabBtnIndex.."_"..k
            if wzCfg[G_getCurChoseLanguage().."3"][subTitleKey] then
                local subTitleLb,lbheight=self:getSubTitleLb(getlocal(subTitleKey))
                subTitleLb:setAnchorPoint(ccp(0,1))
                subTitleLb:setColor(G_ColorYellowPro)
                subTitleLb:setPosition(20,wzposY)
                cell:addChild(subTitleLb)
                wzposY=wzposY-lbheight+10
            end
            for si=1,tonumber(v) do
                local argKey=self.selectedTabBtnIndex.."_"..k.."_"..si
                local arg=self.argsCfg["arg_"..argKey] or {}
                local contentKey="ltzdz_help_content_"..argKey
                local contentLb,lbheight=self:getContentLb(getlocal(contentKey,arg))
                contentLb:setAnchorPoint(ccp(0,1))
                contentLb:setPosition(20,wzposY)
                cell:addChild(contentLb)
                wzposY=wzposY-lbheight
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

function ltzdzHelpDialog:getImageCellHeight()
    for i=1,self.cellNum do
        if self.imageCellHeightTb[i]==nil then
            local imageCfg = self.imageCfg[i]
            if imageCfg.explainNum then
                self.imageCellHeightTb[i]={}
                for k,v in pairs(imageCfg.explainNum) do
                    local height=self.imageBgHeight+20
                    for j=1,v do
                        local strKey="ltzdz_help_image_explain_"..i.."_"..k.."_"..j
                        local contentLb,lbheight=self:getContentLb(getlocal(strKey),self.imageBgWidth-28)
                        height=height+lbheight
                        if j~=v then
                            height=height+5--字段落间距
                        end
                    end
                    self.imageCellHeightTb[i][k]=height+10
                end
            else
                self.imageCellHeightTb[i]={0}
            end
        end
    end
end

function ltzdzHelpDialog:getCellHeight()
    for i=1,self.cellNum do
        if self.cellHeightTb[i]==nil then
            local height=10
            local conf=self.helpConf[i]
            for k,v in pairs(conf) do
                local subTitleKey="ltzdz_help_subtitle_"..i.."_"..k
                if wzCfg[G_getCurChoseLanguage().."3"][subTitleKey] then
                    local subTitleLb,lbheight=self:getSubTitleLb(getlocal(subTitleKey))
                    height=height+lbheight
                else
                    height=height+10
                end
                for si=1,tonumber(v) do
                    local argKey=i.."_"..k.."_"..si
                    local arg=self.argsCfg["arg_"..argKey] or {}
                    local contentKey="ltzdz_help_content_"..argKey
                    local contentLb,lbheight=self:getContentLb(getlocal(contentKey,arg))
                    height=height+lbheight
                end
            end
            self.cellHeightTb[i]=height
        end
    end
end

function ltzdzHelpDialog:getTitleLb(title)
  local width=self.tvWidth-40
  local messageLabel=GetTTFLabelWrap(title,28,CCSizeMake(width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  return messageLabel
end

function ltzdzHelpDialog:getSubTitleLb(subTitle)
  local showMsg=subTitle or ""
  local width=self.tvWidth-40
  local messageLabel=GetTTFLabelWrap(showMsg,24,CCSizeMake(width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  local height=messageLabel:getContentSize().height+20
  return messageLabel,height
end

function ltzdzHelpDialog:getContentLb(content,_w)
  local showMsg=content or ""
  local width=_w or (self.tvWidth-40)
  local messageLabel=GetTTFLabelWrap(showMsg,22,CCSizeMake(width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  local height=messageLabel:getContentSize().height
  return messageLabel,height
end

function ltzdzHelpDialog:tick()
    if self.seasonEndLb then
        local lefttime=ltzdzVoApi:getSeasonEt()
        local lastTimeStr=self.seasonEndLb:getString()
        local timeStr=getlocal("ltzdz_season_endStr",{GetTimeStr(lefttime)})
        if lefttime>=0 and lastTimeStr~=timeStr then
            self.seasonEndLb:setString(getlocal("ltzdz_season_endStr",{GetTimeStr(lefttime)}))
        end
    end
end

function ltzdzHelpDialog:dispose()
    self.imageCellHeightTb={}
    self.cellHeightTb={}
    self.helpConf={}
    self.argsCfg={}
    self.imageCfg={}
    self.cellNum=0
    self.allTabBtn=nil
end