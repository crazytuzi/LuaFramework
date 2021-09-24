rebelDialog=commonDialog:new()

function rebelDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    self.page=1
    self.killNum=0
    self.list={}
    self.tvTab={}
    self.backSpTab={}
    self.leftTimeTb={}
    self.listPageDialog=nil
    self.reloadTvPage=1 --初始化和刷新tableview对应的页数
    self.noListLbTb={}
    self.rebelRefreshTime=nil --天眼叛军列表刷新时间
    self.delayRefreshTime=nil --天眼叛军列表延迟刷新时间
    return nc
end

function rebelDialog:initTableView()

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconLevel.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acydcz_images.plist")
    spriteController:addTexture("public/acydcz_images.png")
    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    spriteController:addPlist("public/believer/believerMain.plist")
    spriteController:addTexture("public/believer/believerMain.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    self.panelLineBg:setContentSize(CCSizeMake(602,G_VisibleSize.height- (rebelVoApi:pr_isOpen() and 270 or 110)))
    self.panelLineBg:setOpacity(0)
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66+35))
    if rebelVoApi:pr_isOpen() then
        self.panelLineBg:setPositionY(self.panelLineBg:getPositionY() - 160 / 2)
    end
    
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-180),nil)


    local function callback( ... )
        if(self and self.bgLayer and self.layerNum)then
            self:initContent()
        end
    end
    rebelVoApi:rebelGet(callback)
end


function rebelDialog:initContent()

    if rebelVoApi:pr_isOpen() then
        local topBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png", CCRect(18, 21, 1, 1), function()end)
        topBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, 160))
        topBg:setAnchorPoint(ccp(0.5, 1))
        topBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 87)
        self.bgLayer:addChild(topBg)
        local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
        titleBg:setAnchorPoint(ccp(0.5, 1))
        titleBg:setPosition(topBg:getContentSize().width / 2, topBg:getContentSize().height - 15)
        topBg:addChild(titleBg)
        local titleLb = GetTTFLabel(getlocal("personalRebel_titleText"), 24, true)
        titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
        titleLb:setColor(G_ColorYellowPro)
        titleBg:addChild(titleLb)
        local function onClickHandler(tag, obj)
            if G_checkClickEnable() == false then
                do return end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if tag == 10 then
                rebelVoApi:pr_showMainDialog(self.layerNum + 1)
            elseif tag == 11 then
                local tabStr = {
                    getlocal("personalRebel_directionTitle1"),
                    getlocal("personalRebel_directionText1_1"),
                    getlocal("personalRebel_directionText1_2"),
                    getlocal("personalRebel_directionText1_3"),
                    getlocal("personalRebel_directionText1_4"),
                    getlocal("personalRebel_directionText1_5"),
                    getlocal("personalRebel_directionText1_6"),
                    getlocal("personalRebel_directionText1_7", {math.floor(rebelCfg.recoverTime / 60)}),
                    getlocal("personalRebel_directionText1_8"),
                    "\n",
                    getlocal("personalRebel_directionTitle2"),
                    getlocal("personalRebel_directionText2_1"),
                    getlocal("personalRebel_directionText2_2"),
                    getlocal("personalRebel_directionText2_3"),
                    "\n",
                    getlocal("personalRebel_directionTitle3"),
                    getlocal("personalRebel_directionText3"),
                }
                local tabStrColor = {G_ColorGreen, nil, nil, nil, nil, nil, nil, nil, nil, G_ColorGreen, nil, nil, nil, nil, G_ColorGreen, nil}
                require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
                tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, tabStrColor, 25)
            end
        end
        local enterBtn = GetButtonItem("yh_nbSkillGoto.png", "yh_nbSkillGoto_Down.png", "yh_nbSkillGoto.png", onClickHandler, 10)
        local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onClickHandler, 11)
        local menuArr = CCArray:create()
        menuArr:addObject(enterBtn)
        menuArr:addObject(infoBtn)
        local btnMenu = CCMenu:createWithArray(menuArr)
        btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
        btnMenu:setPosition(ccp(0, 0))
        topBg:addChild(btnMenu)
        infoBtn:setPosition(topBg:getContentSize().width - 20 - infoBtn:getContentSize().width * infoBtn:getScale() / 2, 15 + infoBtn:getContentSize().height * infoBtn:getScale() / 2)
        enterBtn:setPosition(infoBtn:getPositionX() - (infoBtn:getContentSize().width * infoBtn:getScale() / 2 + 15 + enterBtn:getContentSize().width * enterBtn:getScale() / 2), 15 + enterBtn:getContentSize().height * enterBtn:getScale() / 2)

        --红点显示
        local capInSet1=CCRect(17, 17, 1, 1)
        local function touchClick()
        end
        self.freeGetFlagIcon = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
        self.freeGetFlagIcon:setPosition(enterBtn:getContentSize().width-5, enterBtn:getContentSize().height-5)
        --self.freeGetFlagIcon:setPosition(ccp(100,200))
        enterBtn:addChild(self.freeGetFlagIcon)

        local function refreshFlag(event,data)
            local cdTimer = rebelVoApi:getNowCDTimer()
            local curEnergy = rebelVoApi:getRebelEnergy()
            if self.freeGetFlagIcon then
                if curEnergy == rebelCfg.energyMax or cdTimer < base.serverTime  then
                    self.freeGetFlagIcon:setVisible(true)
                else
                    self.freeGetFlagIcon:setVisible(false)
                end
            end
        end
        self.refreshListener = refreshFlag
        eventDispatcher:addEventListener("refresh.flag.numbg",self.refreshListener)
        refreshFlag()

        self.freeGetFlagIcon:setScale(0.6)
        local prDescLb = GetTTFLabelWrap(getlocal("personalRebel_enterDescText"), 20, CCSizeMake(topBg:getContentSize().width - 200, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        prDescLb:setAnchorPoint(ccp(0, 1))
        prDescLb:setPosition(35, titleBg:getPositionY() - titleBg:getContentSize().height - 10)
        topBg:addChild(prDescLb)
        local worldRebelBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png", CCRect(18, 21, 1, 1), function()end)
        worldRebelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, topBg:getPositionY() - topBg:getContentSize().height - 15))
        worldRebelBg:setAnchorPoint(ccp(0.5, 1))
        worldRebelBg:setPosition(G_VisibleSizeWidth / 2, topBg:getPositionY() - topBg:getContentSize().height)
        self.bgLayer:addChild(worldRebelBg)
    end

    local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function()end)
    descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,160))
    descBg:ignoreAnchorPointForPosition(false)
    descBg:setAnchorPoint(ccp(0.5,1))
    descBg:setIsSallow(true)
    descBg:setTouchPriority(-(self.layerNum-1)*20-3)
    descBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height- (rebelVoApi:pr_isOpen() and 260 or 100)))
    self.bgLayer:addChild(descBg,1)

    local descMaxHeight = descBg:getContentSize().height - 20
    local lbShowWidth, lbPosX = 330, 150
    if rebelVoApi:pr_isOpen() then
        descMaxHeight = 90
        descBg:setOpacity(0)
        local titleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
        titleBg:setAnchorPoint(ccp(0.5, 1))
        titleBg:setPosition(descBg:getContentSize().width / 2, descBg:getContentSize().height - 5)
        descBg:addChild(titleBg)
        local titleLb = GetTTFLabel(getlocal("world_rebel"), 24, true)
        titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
        titleLb:setColor(G_ColorYellowPro)
        titleBg:addChild(titleLb)
        lbShowWidth = descBg:getContentSize().width - 100
        lbPosX = 35
    else
        local icon=CCSprite:createWithSpriteFrameName("rebelIcon.png")
        icon:setPosition(ccp(70,descBg:getContentSize().height/2))
        descBg:addChild(icon,1)
    end

    local lbHeight
    local killcount=rebelVoApi:getKillcount()
    local rewardLimit=rebelCfg.rewardLimit
  
    local descTb={
        {getlocal("alliance_rebel_info_desc",{killcount.."/"..rewardLimit}),{G_ColorWhite,G_ColorGreen,G_ColorWhite},nil,true},
        {getlocal("alliance_rebel_rewardtip",{math.floor(rebelCfg.overdue/86400)}),{G_ColorWhite,G_ColorGreen,G_ColorWhite},nil,true},
    }
    local desTv,descHeight,descTvHeight=G_LabelTableViewNew(CCSizeMake(lbShowWidth,descMaxHeight),descTb,21,kCCTextAlignmentLeft,nil,nil,nil,true)
    desTv:setAnchorPoint(ccp(0,0))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    descBg:addChild(desTv,1)
    local offset=0
    if descHeight>descMaxHeight then
        offset=80
    end
    desTv:setMaxDisToBottomOrTop(offset)
    desTv:setPosition(lbPosX,descBg:getContentSize().height/2-descTvHeight/2)

    local menuInfoPosY = descBg:getContentSize().height/2
    if rebelVoApi:pr_isOpen() then
        desTv:setPositionY(8)
        menuInfoPosY = desTv:getPositionY() + descTvHeight / 2
    end
    local function touchTip()
        local contentTb={getlocal("alliance_rebel_help_title1"),getlocal("alliance_rebel_help_content1"),"\n",getlocal("alliance_rebel_help_title2"),getlocal("alliance_rebel_help_content2_1"),getlocal("alliance_rebel_help_content2_2",{math.floor(rebelCfg.refreshTime/3600)}),getlocal("alliance_rebel_help_content2_3"),getlocal("alliance_rebel_help_content2_4"),getlocal("alliance_rebel_help_content2_5",{rebelCfg.damageRatio*100}),getlocal("alliance_rebel_help_content2_6",{rebelCfg.startDamage*100}),getlocal("alliance_rebel_help_content2_7",{math.floor(rebelCfg.recoverTime/60)}),getlocal("alliance_rebel_help_content2_8"),"\n",getlocal("alliance_rebel_help_title3"),getlocal("alliance_rebel_help_content3",{rebelCfg.rewardLimit,math.floor(rebelCfg.overdue/86400)})}
        if FuncSwitchApi:isEnabled("worldRebel_buff") == true then
            table.insert(contentTb, "\n")
            table.insert(contentTb, getlocal("alliance_rebel_help_title4"))
            table.insert(contentTb, getlocal("alliance_rebel_help_content4"))
        end
        local colorTb={G_ColorGreen,nil,nil,G_ColorGreen,nil,nil,nil,nil,nil,nil,nil,nil,G_ColorGreen,nil,nil,G_ColorGreen,nil}
        local textFormatTb={{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=true,richColor={nil,G_ColorGreen,nil}},{richFlag=true,richColor={nil,G_ColorRed,nil}},{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=false},{richFlag=false}}
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),contentTb,colorTb,nil,textFormatTb)
    end
    G_addMenuInfo(descBg,self.layerNum,ccp(descBg:getContentSize().width-40,menuInfoPosY),{},nil,nil,28,touchTip,true)

    local space=30
    local pageNum=3
    if playerVoApi:isRebelBuffActive()==true then --天眼buff生效，多一个天眼页签
        pageNum=4
        self:setRebelRefreshTime()
        self.page=4 --叛军天眼生效的话默认打开天眼页签
    end
    for i=1,pageNum do
        local backSprie=self:initList(i)

        self.list[i]=backSprie

        local pfScale=0.8
        local pox=self.panelLineBg:getContentSize().width/2-(space/2*(pageNum-1))+(i-1)*space

        if self.page==i then
            self:initListTv(i)
        end

    end


    self.listPageDialog=pageDialog:new()
    
    local isShowBg=false
    local isShowPageBtn=true
    local function onPage(topage)
        self.page=topage
    end
    local posY=self.panelLineBg:getContentSize().height-210
    local leftBtnPos=ccp(30,posY)
    local rightBtnPos=ccp(self.panelLineBg:getContentSize().width-30,posY)
    local function movedCallback(turnType,isTouch)
        local canMove=true
        if self.page and self.tvTab then
            local turnPage=self.page+1
            if turnType==1 then
                turnPage=self.page-1
            end
            if turnPage<=0 then
                turnPage=pageNum
            elseif turnPage>pageNum then
                turnPage=1
            end
            -- print("turnPage",turnPage)
            if self.tvTab[turnPage] then
            else
                self:initListTv(turnPage)
            end
            if self.tvTab[self.page] and isTouch==true then
                local tv=self.tvTab[self.page]
                if tv and tv.getScrollEnable and tv.getIsScrolled then
                    canMove=false
                    if tv:getScrollEnable()==true and tv:getIsScrolled()==false then
                        canMove=true
                    end
                end
            end
            
            if self.noListLbTb and self.noListLbTb[turnPage] then
                local lb=tolua.cast(self.noListLbTb[turnPage],"CCLabelTTF")
                if lb then
                    local list=rebelVoApi:getRebelList(turnPage)
                    if list and SizeOfTable(list)>0 then
                        lb:setVisible(false)
                    else
                        lb:setVisible(true)
                    end
                end
            end
        end
        return canMove
    end
    self.listPageDialog:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.panelLineBg,ccp(0,0),self.layerNum,self.page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,movedCallback)

    -- local maskSpHeight=self.bgLayer:getContentSize().height-290
    -- for k=1,3 do
    --     local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
    --     leftMaskSp:setAnchorPoint(ccp(0,0))
    --     -- leftMaskSp:setPosition(0,pos.y+25)
    --     leftMaskSp:setPosition(0,35)
    --     leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
    --     self.bgLayer:addChild(leftMaskSp,6)

    --     local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
    --     -- rightMaskSp:setRotation(180)
    --     rightMaskSp:setFlipX(true)
    --     rightMaskSp:setAnchorPoint(ccp(0,0))
    --     -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
    --     rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,35)
    --     rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
    --     self.bgLayer:addChild(rightMaskSp,6)
    -- end
end

function rebelDialog:initList(index)
    -- local index=indx-1
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),cellClick)
    backSprie:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width, self.panelLineBg:getContentSize().height))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(0,0))
    backSprie:setOpacity(0)
    self.panelLineBg:addChild(backSprie)
    -- backSprie:setOpacity(0)
    local bgWidth=backSprie:getContentSize().width
    local bgHeight=backSprie:getContentSize().height
    local headHeight=80

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local titleStr=""
    if index==4 then
        local flag,mt=playerVoApi:isRebelBuffActive()
        local leftTime=mt-base.serverTime
        if leftTime<=0 then
            leftTime=0
        end
        titleStr=getlocal("alliance_rebel_page_title"..index,{GetTimeStr(leftTime)})
    else
        titleStr=getlocal("alliance_rebel_page_title"..index)
    end
    -- titleStr=str
    local titleBg,titleLb = G_createNewTitle({titleStr,23,G_ColorYellowPro2},CCSizeMake(380,0),nil,nil,"Helvetica-bold")
    titleBg:setPosition(ccp(bgWidth/2,bgHeight-225))
    backSprie:addChild(titleBg,1)

    if self.titleLbTb==nil then
        self.titleLbTb={}
    end
    self.titleLbTb[index]=titleLb
    
    local descStr=getlocal("alliance_rebel_page_desc"..index,{rebelCfg.rewardLimit})
    if index>1 and index~=4 then
        descStr=getlocal("alliance_rebel_page_desc2",{rebelCfg.rewardLimit})
    elseif index==4 then
        local flag,mt=playerVoApi:isRebelBuffActive()
        descStr=getlocal("alliance_rebel_page_desc4",{GetTimeStr(mt-base.serverTime)})
    end
    -- descStr=str
    local textWidth=bgWidth-80
    if index==1 then
        textWidth=bgWidth-160
    end
    local descLb=GetTTFLabelWrap(descStr,26,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setPosition(ccp(30,40))
    descLb:setColor(G_ColorYellowPro)
    backSprie:addChild(descLb,1)
    if self.descLbTb==nil then
        self.descLbTb={}
    end
    self.descLbTb[index]=descLb

    local function nilFunc()
    end
    local listBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15, 15, 2, 2),nilFunc)
    listBg:setContentSize(CCSizeMake(backSprie:getContentSize().width,backSprie:getContentSize().height-330))
    listBg:setAnchorPoint(ccp(0.5,0))
    listBg:setPosition(ccp(backSprie:getContentSize().width/2,80))
    backSprie:addChild(listBg)
    self.backSpTab[index]=listBg

    local noListStr=getlocal("alliance_rebel_no_list_desc"..index)
    local noListLb=GetTTFLabelWrap(noListStr,30,CCSizeMake(listBg:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noListLb:setPosition(getCenterPoint(listBg))
    noListLb:setColor(G_ColorGray)
    listBg:addChild(noListLb)
    self.noListLbTb[index]=noListLb

    if index==1 and FuncSwitchApi:isEnabled("worldRebel_buff") == true then
        --进入月度充值活动页面
        local function goToYdczActivity()
            if activityVoApi:isStart(activityVoApi:getActivityVo("ydcz"))==true then
                activityAndNoteDialog:closeAllDialog() --关闭所有面板
                if acYdczVoApi then
                    jump_judgment("ydcz")
                end
            else
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage1985"),30)
            end
        end
        local rebelBuffSp,activeLb,activeBg=rebelVoApi:getRebelBuffSp(backSprie,ccp(backSprie:getContentSize().width-70,45),2,self.layerNum,goToYdczActivity)
        rebelBuffSp:setScale(0.6)
        activeBg:setScaleX(1.5*activeBg:getScaleX())
        activeBg:setScaleY(1.5*activeBg:getScaleY())
        activeBg:setPositionY(activeBg:getPositionY()+10)
    end

    self:tick()

    return backSprie
end


function rebelDialog:initListTv(index)
    local backSprie=self.backSpTab[index]
    if backSprie then
        backSprie=tolua.cast(backSprie,"LuaCCScale9Sprite")
        local bgWidth=backSprie:getContentSize().width
        local bgHeight=backSprie:getContentSize().height
        local contentHeight=bgHeight
        local num=10
        local height
        if index==1 or index==4 then
            height=100
        else
            height=70
            contentHeight=bgHeight-50
            local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
            headBg:setContentSize(CCSizeMake(backSprie:getContentSize().width-10,55))
            headBg:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height-35)
            backSprie:addChild(headBg)
            local lbx,lby,spacex=60,headBg:getContentSize().height/2,210
            for i=1,3 do
                local titleLb=GetTTFLabel(getlocal("alliance_rebel_page"..index.."_sub_title"..i),20,true)
                titleLb:setPosition(ccp(lbx+(i-1)*spacex,lby))
                titleLb:setColor(G_ColorYellowPro2)
                headBg:addChild(titleLb)
            end
        end

        if self.cellNumTb==nil then
            self.cellNumTb={}
        end
        local list=rebelVoApi:getRebelList(index)
        if list and SizeOfTable(list)>0 then
            self.cellNumTb[index]=SizeOfTable(list)
        end
        if index==1 then
            self.leftTimeTb={}
        end
        self.reloadTvPage=index
        local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                return self.cellNumTb[index]
            elseif fn=="tableCellSizeForIndex" then
                local tmpSize=CCSizeMake(bgWidth-20,height)
                return tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                local cellWidth=bgWidth-20
                local cellHeight=height

                if self.reloadTvPage<=3 then
                    local rebelVo=list[idx+1]
                    if self.reloadTvPage==1 then
                        local id=rebelVo.id
                        local totalLife=rebelVo.maxLife
                        local leftLife=rebelVo.curLife
                        local rebelLv=rebelVo.level
                        local rebelID=rebelVo.num
                        local place=rebelVo.place
                        local fleeTime=rebelVo.fleeTime
                        local leftTime=fleeTime-base.serverTime
                        
                        -- local tankPic=worldBaseVoApi:getRebelIcon(rebelLv,rebelID)
                        local nameStr
                        local tankSp
                        local tankId=rebelVoApi:getRebelIconTank(rebelLv,rebelID)
                        local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                        id=Split(id,"-")[1]
                        local midautumnFlag=rebelVoApi:isMidautumnRebel(fleeTime,id)
                        if midautumnFlag==true then
                            local picName=rebelVoApi:getSpecialRebelPic(100)
                            if picName then
                                nameStr=rebelVoApi:getRebelName(rebelLv,rebelID,true,100)
                                tankSp=CCSprite:createWithSpriteFrameName(picName)
                            else
                                nameStr=rebelVoApi:getRebelName(rebelLv,rebelID,true)
                                tankSp=G_getTankPic(tid,nil,nil,nil,nil,false)
                            end
                        else
                            nameStr=rebelVoApi:getRebelName(rebelLv,rebelID,true)
                            tankSp=G_getTankPic(tid,nil,nil,nil,nil,false)
                        end

                        if tankSp then
                            tankSp:setScale(0.6)
                            tankSp:setPosition(ccp(50,cellHeight/2))
                            cell:addChild(tankSp,1)
                        end

                        local barPx=235
                        local scalex=0.95
                        local per=(leftLife/totalLife)*100
                        local perStr=""
                        if per>0 and per<1 then
                            perStr="1%"
                        else
                            -- perStr=math.floor(per).."%"
                            perStr=G_keepNumber(per,0).."%"
                        end
                        AddProgramTimer(cell,ccp(barPx,cellHeight/2-20),11,12,perStr,"rebelProgressBg.png","rebelProgress.png",13,scalex,1)
                        local timerSpriteLv=cell:getChildByTag(11)
                        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
                        timerSpriteLv:setPercentage(per)
                        
                        if nameStr then
                            local nameLb=GetTTFLabelWrap(nameStr,20,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                            nameLb:setAnchorPoint(ccp(0,0.5))
                            nameLb:setPosition(ccp(barPx-timerSpriteLv:getContentSize().width/2*scalex,cellHeight/2+20))
                            nameLb:setColor(G_ColorBlue)
                            cell:addChild(nameLb,1)
                        end
           
                        local placeLb=GetTTFLabel(getlocal("city_info_coordinate_style",{place[1],place[2]}),20)
                        placeLb:setAnchorPoint(ccp(1,0.5))
                        placeLb:setPosition(ccp(barPx+timerSpriteLv:getContentSize().width/2*scalex+5,cellHeight/2+20))
                        placeLb:setColor(G_ColorBlue)
                        cell:addChild(placeLb,1)

                        local fleeStr=getlocal("serverwarteam_battleing")
                        -- fleeStr="啊啊啊啊啊啊啊啊啊啊"
                        local fleeLb=GetTTFLabelWrap(fleeStr,20,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        fleeLb:setAnchorPoint(ccp(0,0.5))
                        fleeLb:setPosition(ccp(cellWidth-160,cellHeight/2+20))
                        cell:addChild(fleeLb,1)
                        local leftTimeLb=GetTTFLabel(GetTimeStr(leftTime),20)
                        leftTimeLb:setAnchorPoint(ccp(0,0.5))
                        leftTimeLb:setPosition(ccp(cellWidth-160,cellHeight/2-20))
                        cell:addChild(leftTimeLb,1)
                        if leftTime<60 then
                            leftTimeLb:setColor(G_ColorRed)
                        else
                            leftTimeLb:setColor(G_ColorGreen)
                        end
                        self.leftTimeTb[idx+1]={lb=leftTimeLb,id=id,leftTime=leftTime}

                        local attSp=CCSprite:createWithSpriteFrameName("newAttackBtn.png")
                        attSp:setPosition(ccp(cellWidth-30,cellHeight/2))
                        cell:addChild(attSp,1)


                        local capInSet = CCRect(20, 20, 10, 10)
                        local function gotoMap(hd,fn,idx)
                            if self.tvTab[index] then
                                local tv1=self.tvTab[index]
                                if tv1 and tv1.getScrollEnable and tv1.getIsScrolled then
                                    if tv1:getScrollEnable()==true and tv1:getIsScrolled()==false then
                                        if place and place[1] and place[2] then
                                            for k,v in pairs(base.commonDialogOpened_WeakTb) do
                                                local dialog = base.commonDialogOpened_WeakTb[k]
                                                if dialog~=nil and dialog~=self and dialog.close then
                                                    dialog:close()
                                                end
                                            end
                                            self:close()
                                            mainUI:changeToWorld()
                                            worldScene:focus(place[1],place[2])
                                        end
                                    end
                                end
                            end
                        end
                        local cellBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,gotoMap)
                        cellBg:setContentSize(CCSizeMake(cellWidth,cellHeight))
                        cellBg:ignoreAnchorPointForPosition(false)
                        cellBg:setAnchorPoint(ccp(0,0))
                        cellBg:setTouchPriority(-(self.layerNum-1)*20-2)
                        cellBg:setPosition(ccp(0,0))
                        cell:addChild(cellBg)
                        cellBg:setOpacity(0)
                    else
                        local id=rebelVo.id
                        local rebelLv=rebelVo.level
                        local rebelID=rebelVo.num
                        local killTime=rebelVo.killTime
                        local killName=rebelVo.killName
                        local fleeTime=rebelVo.fleeTime
                        local status=0
                        if killName and killName~="" then
                            status=1
                        end
                        local time=0
                        if status==1 then
                            time=killTime-G_getWeeTs(killTime)
                        else
                            time=fleeTime-G_getWeeTs(fleeTime)
                        end

                        local timeLb=GetTTFLabel(G_getTimeStr(time,2),20)
                        timeLb:setAnchorPoint(ccp(0.5,0.5))
                        timeLb:setPosition(ccp(50,cellHeight/2))
                        cell:addChild(timeLb,1)

                        local lbWidth=230
                        local nameStr
                        local tankSp
                        local tankId=rebelVoApi:getRebelIconTank(rebelLv,rebelID)
                        local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                        id=Split(id,"-")[1]
                        local midautumnFlag=rebelVoApi:isMidautumnRebel(fleeTime,id)
                        if midautumnFlag==true then
                            local picName=rebelVoApi:getSpecialRebelPic(100)
                            if picName then
                                nameStr=rebelVoApi:getRebelName(rebelLv,rebelID,true,100)
                                tankSp=CCSprite:createWithSpriteFrameName(picName)
                            else
                                nameStr=rebelVoApi:getRebelName(rebelLv,rebelID,true)
                                tankSp=G_getTankPic(tid,nil,nil,nil,nil,false)
                            end
                        else
                            nameStr=rebelVoApi:getRebelName(rebelLv,rebelID,true)
                            tankSp=G_getTankPic(tid,nil,nil,nil,nil,false)
                        end
                        -- nameStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                        if nameStr then
                            local nameLb=GetTTFLabelWrap(nameStr,20,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                            nameLb:setAnchorPoint(ccp(0.5,0.5))
                            nameLb:setPosition(ccp(cellWidth/2-15,cellHeight/2))
                            nameLb:setColor(G_ColorBlue)
                            cell:addChild(nameLb,1)
                        end

                        if tankSp then
                            local tScale=0.5
                            tankSp:setScale(tScale)
                            local spWidth=0
                            local nameLb1=GetTTFLabel(nameStr,20)
                            if nameLb1:getContentSize().width>lbWidth then
                                spWidth=cellWidth/2-lbWidth/2-tankSp:getContentSize().width/2*tScale-5
                            else
                                spWidth=cellWidth/2-nameLb1:getContentSize().width/2-tankSp:getContentSize().width/2*tScale-10
                            end
                            tankSp:setPosition(ccp(spWidth,cellHeight/2))
                            cell:addChild(tankSp,1)
                        end

                        if self.reloadTvPage==2 then
                            local killerLb=GetTTFLabel(killName,20)
                            killerLb:setAnchorPoint(ccp(0.5,0.5))
                            killerLb:setPosition(ccp(cellWidth-100,cellHeight/2))
                            killerLb:setColor(G_ColorYellowPro)
                            cell:addChild(killerLb,1)
                        else
                            local statusStr=""
                            if status==1 then
                                statusStr=getlocal("dimensionalWar_status2")
                                local statusLb=GetTTFLabel(statusStr,20)
                                statusLb:setPosition(ccp(cellWidth-105,cellHeight/2+15))
                                statusLb:setColor(G_ColorRed)
                                cell:addChild(statusLb,1)
                                local killLb=GetTTFLabel(getlocal("alliance_rebel_kill",{killName}),20)
                                killLb:setPosition(ccp(cellWidth-105,cellHeight/2-10))
                                killLb:setColor(G_ColorRed)
                                cell:addChild(killLb,1)
                            else
                                statusStr=getlocal("alliance_rebel_status")
                                local statusLb=GetTTFLabel(statusStr,20)
                                statusLb:setPosition(ccp(cellWidth-105,cellHeight/2))
                                statusLb:setColor(G_ColorYellowPro)
                                cell:addChild(statusLb,1)
                            end
                            
                        end
                    end

                    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                    lineSp:setContentSize(CCSizeMake(cellWidth-10, 2))
                    lineSp:setPosition(ccp(cellWidth/2,2))
                    cell:addChild(lineSp)
                elseif self.reloadTvPage==4 then --天眼
                    local list=rebelVoApi:getRebelList(self.reloadTvPage)
                    local rebel=list[idx+1]
                    if rebel.x==nil or rebel.y==nil then
                        do return cell end
                    end
                    local rebelLv,troopId=rebel.rebelLv,rebel.troopId
                    local nameStr
                    local tankSp
                    local tankId=rebelVoApi:getRebelIconTank(rebelLv,troopId)
                    local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                    local midautumnFlag=rebelVoApi:isMidautumnRebel(rebel.expireTs,rebel.mid)
                    if midautumnFlag==true then
                        local picName=rebelVoApi:getSpecialRebelPic(100)
                        if picName then
                            nameStr=rebelVoApi:getRebelName(rebelLv,troopId,true,100)
                            tankSp=CCSprite:createWithSpriteFrameName(picName)
                        else
                            nameStr=rebelVoApi:getRebelName(rebelLv,troopId,true)
                            tankSp=G_getTankPic(tid,nil,nil,nil,nil,false)
                        end
                    else
                        nameStr=rebelVoApi:getRebelName(rebelLv,troopId,true)
                        tankSp=G_getTankPic(tid,nil,nil,nil,nil,false)
                    end

                    if tankSp then
                        tankSp:setScale(0.6)
                        tankSp:setPosition(ccp(50,cellHeight/2))
                        cell:addChild(tankSp,1)
                    end
                    local leftPosX=120
                    if nameStr then
                        local nameLb=GetTTFLabelWrap(nameStr,20,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        nameLb:setAnchorPoint(ccp(0,0.5))
                        nameLb:setPosition(ccp(leftPosX,cellHeight/2+20))
                        nameLb:setColor(G_ColorBlue)
                        cell:addChild(nameLb,1)

                        local placeLb=GetTTFLabel(getlocal("search_base_report_desc_4",{rebel.x,rebel.y}),20)
                        placeLb:setAnchorPoint(ccp(0,0.5))
                        placeLb:setPosition(ccp(leftPosX,cellHeight/2-20))
                        placeLb:setColor(G_ColorBlue)
                        cell:addChild(placeLb,1)
                    end

                    local rscolor=G_ColorWhite
                    local rs=rebel.rs+1
                    if rs==0 then
                        rscolor=G_ColorYellowPro
                    elseif rs==1 then
                        rscolor=G_ColorGreen
                    elseif rs==2 then
                        rscolor=G_ColorRed
                    end
                    local stateLb=GetTTFLabelWrap(getlocal("rebel_state"..(rebel.rs+1)),20,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    stateLb:setAnchorPoint(ccp(0,0.5))
                    stateLb:setPosition(ccp(400,cellHeight/2))
                    stateLb:setColor(rscolor)
                    cell:addChild(stateLb,1)

                    local function gotoMap(hd,fn,idx)
                        if self.tvTab[index] then
                            local tv1=self.tvTab[index]
                            if tv1 and tv1.getScrollEnable and tv1.getIsScrolled then
                                if tv1:getScrollEnable()==true and tv1:getIsScrolled()==false then
                                    for k,v in pairs(base.commonDialogOpened_WeakTb) do
                                        local dialog = base.commonDialogOpened_WeakTb[k]
                                        if dialog~=nil and dialog~=self and dialog.close then
                                            dialog:close()
                                        end
                                    end
                                    self:close()
                                    mainUI:changeToWorld()
                                    worldScene:focus(rebel.x,rebel.y)
                                end
                            end
                        end
                    end
                    if rs~=2 then --叛军未击杀的话可以跳转到世界地图
                        local attSp=LuaCCSprite:createWithSpriteFrameName("newAttackBtn.png",gotoMap)
                        attSp:setTouchPriority(-(self.layerNum-1)*20-2)
                        attSp:setPosition(ccp(cellWidth-30,cellHeight/2))
                        cell:addChild(attSp,1)
                    end
    
                    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                    lineSp:setContentSize(CCSizeMake(cellWidth-10, 2))
                    lineSp:setPosition(ccp(cellWidth/2,2))
                    cell:addChild(lineSp)
                end

                return cell
            elseif fn=="ccTouchBegan" then
                isMoved=false
                return true
            elseif fn=="ccTouchMoved" then
                isMoved=true
            elseif fn=="ccTouchEnded"  then

            end
        end
        local hd= LuaEventHandler:createHandler(tvCallBack)
        local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgWidth-20,contentHeight-20),nil)
        -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        tv:setPosition(ccp(10,10))
        backSprie:addChild(tv,2)
        tv:setMaxDisToBottomOrTop(80)
        self.tvTab[index]=tv
    end
end


--用户处理特殊需求,没有可以不写此方法
function rebelDialog:doUserHandler()
    
    if self.panelLineBg then
        self.bgLayer:reorderChild(self.panelLineBg,2)
    end
  
    if self.panelTopLine then
        self.panelTopLine:setVisible(false)
    end

    -- 去渐变线
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,2)
    self.bgLayer:addChild(panelBg)
end

function rebelDialog:tick()
    if self.page==1 then
        for k,v in pairs(self.leftTimeTb) do
            if v and v.lb then
                local lb=tolua.cast(v.lb,"CCLabelTTF")
                local leftTime=v.leftTime
                if leftTime and lb then
                    if leftTime>0 then
                        v.leftTime=leftTime-1
                        lb:setString(GetTimeStr(v.leftTime))
                    elseif v.id then
                        local list=rebelVoApi:getRebelList(self.page)
                        if list then
                            for m,n in pairs(list) do
                                if n and n.id==v.id then
                                    rebelVoApi:removeRebel(self.page,id)
                                    local tv=self.tvTab[self.page]
                                    if tv then
                                        self.leftTimeTb={}
                                        self.reloadTvPage=self.page
                                        tv:reloadData()
                                    end
                                end
                            end
                        end
                        do return end
                    end
                end
            end
        end
    end
    if self.descLbTb and self.descLbTb[4] and tolua.cast(self.descLbTb[4],"CCLabelTTF") then
        if self.rebelRefreshTime==nil or self.delayRefreshTime==nil then
            self:setRebelRefreshTime()
        end
        if base.serverTime>=self.rebelRefreshTime or base.serverTime>=self.delayRefreshTime then --整点刷新，或延迟1分钟刷新
            -- print("need refresh rebel list!!!")
            if base.serverTime>=self.delayRefreshTime then
                self.delayRefreshTime=self.delayRefreshTime+3600
            end
            local function refresh() --刷新天眼搜索的最新叛军列表信息
                if self.cellNumTb==nil then
                    self.cellNumTb={}
                end
                local page=4
                local list=rebelVoApi:getRebelList(page)
                self.cellNumTb[page]=SizeOfTable(list)
                if self.tvTab and self.tvTab[page] then
                    self.reloadTvPage=page
                    self.tvTab[page]:reloadData()
                end
            end
            rebelVoApi:rebelGet(refresh)
        end
        local leftTime=self.rebelRefreshTime-base.serverTime
        if leftTime<=0 then
            self:setRebelRefreshTime()
            leftTime=0
        end
        local descStr=getlocal("alliance_rebel_page_desc4",{GetTimeStr(leftTime)})
        local descLb=self.descLbTb[4]
        descLb:setString(descStr)
    end
    if self.titleLbTb and self.titleLbTb[4] and tolua.cast(self.titleLbTb[4],"CCLabelTTF") then
        local titleLb=self.titleLbTb[4]
        local flag,mt=playerVoApi:isRebelBuffActive()
        local leftTime=mt-base.serverTime
        if leftTime<=0 then
            leftTime=0
        end
        titleStr=getlocal("alliance_rebel_page_title4",{GetTimeStr(leftTime)})
        titleLb:setString(titleStr)
    end

    if self.noListLbTb and self.noListLbTb[self.page] then
        local lb=tolua.cast(self.noListLbTb[self.page],"CCLabelTTF")
        if lb then
            local list=rebelVoApi:getRebelList(self.page)
            if list and SizeOfTable(list)>0 then
                lb:setVisible(false)
            else
                lb:setVisible(true)
            end
        end
    end
end

--设置天眼叛军列表刷新时间
function rebelDialog:setRebelRefreshTime()
    local sec=base.serverTime%3600
    self.rebelRefreshTime=base.serverTime+3600-sec --整点刷新时间戳
    self.delayRefreshTime=self.rebelRefreshTime+60 --延迟1分钟刷新
    if sec<60 then --正好卡在延迟1分钟刷新的时间内，则设置延迟刷新的时间
        self.delayRefreshTime=base.serverTime+60-sec
    end
end

function rebelDialog:dispose()
    local data={key="alliance_rebel_detail"}
    eventDispatcher:dispatchEvent("allianceFunction.numChanged",data)
    if self.refreshListener then
    	eventDispatcher:removeEventListener("refresh.flag.numbg",self.refreshListener)
    end
	self.refreshListener=nil    
    self.layerNum=nil
    self.page=1
    self.killNum=0
    self.list={}
    self.tvTab={}
    self.backSpTab={}
    self.leftTimeTb={}
    self.listPageDialog=nil
    self.reloadTvPage=1
    self.noListLbTb={}
    self.descLbTb=nil
    self.titleLbTb=nil
    self.rebelRefreshTime=nil
    self.delayRefreshTime=nil
    self.cellNumTb=nil
    spriteController:removePlist("public/acydcz_images.plist")
    spriteController:removeTexture("public/acydcz_images.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/believer/believerMain.plist")
    spriteController:removeTexture("public/believer/believerMain.png")
end




