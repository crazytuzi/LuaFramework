rewardCenterDialog={}

function rewardCenterDialog:new()
    local nc={
            bgLayer,
        }
    setmetatable(nc,self)
    self.__index=self
    self.getAllRewardBtn=nil
    self.layerNum=0
    self.curPage=1
    self.maxNum=1
    self.rewardNumLb=nil
    self.listNum=0
    self.pageLb=nil
    self.awardIndex=0;
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/superWeaponTmp.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    return nc
end

--设置对话框里的tableView
function rewardCenterDialog:initTableView(layerNum)
    spriteController:addPlist("public/acThfb.plist")
    spriteController:addTexture("public/acThfb.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/rewardCenterImage.plist")
    spriteController:addTexture("public/rewardCenterImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
    self.layerNum=layerNum
    self.maxNum=rewardCenterVoApi:getMaxNum()
    --外边框
    local dialogBgHeight = 780
    if G_getIphoneType()==G_iphone4 then
        dialogBgHeight=650
    end
    self.bgSize = CCSizeMake(560,dialogBgHeight)
    local function touch( ... )
        
    end
    local capInSet = CCRect(130, 50, 1, 1)
    local dialogBg = G_getNewDialogBg2(self.bgSize, layerNum, touch)
	-- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touch)
    -- dialogBg:setContentSize(CCSizeMake(560,800))
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(sceneGame:getContentSize().width/2,sceneGame:getContentSize().height/2-50)
    dialogBg:setTouchPriority(-(self.layerNum-1)*20-3)
    -- self.layerNum=self.layerNum+1

    -- 翻页start
    self:initPageBtn()
    -- 翻页end

    local capInSet1 = CCRect(10, 10, 1, 1)
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touch);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-3)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(250)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.touchDialogBg,3);
    -- self.layerNum=self.layerNum+1

    -- local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
    -- spriteTitle:setAnchorPoint(ccp(0.5,0.5));
    -- spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
    -- dialogBg:addChild(spriteTitle,2)

    --面板上面的装饰图
    local spriteTitle = CCSprite:createWithSpriteFrameName("top.png");
    spriteTitle:setAnchorPoint(ccp(0.5,0));
    spriteTitle:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
    dialogBg:addChild(spriteTitle,2)
    --闪闪亮
    local lightPos = ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height+10)
    self:initSunShine(dialogBg,dialogBgHeight,lightPos)

    local spriteShapeInfor = CCSprite:createWithSpriteFrameName("titlebg.png");
    spriteShapeInfor:setAnchorPoint(ccp(0.5,0));
    spriteShapeInfor:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-45)
    dialogBg:addChild(spriteShapeInfor,1)
    --面板最下面的横线
    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setAnchorPoint(ccp(0,0));
    mLine:setPosition(ccp(4,20))
    mLine:setContentSize(CCSizeMake(dialogBg:getContentSize().width-10,mLine:getContentSize().height))
    dialogBg:addChild(mLine)
    -- 标题文本
    local titleLb=GetTTFLabel(getlocal("rewardCenterTitle"),24,true)
    titleLb:setPosition(ccp(dialogBg:getContentSize().width/2,spriteTitle:getPositionY()-spriteTitle:getContentSize().height/2+6))
    titleLb:setAnchorPoint(ccp(0.5,0));
    dialogBg:addChild(titleLb,2)
    titleLb:setColor(G_ColorYellowPro)

    -- local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png");
    -- lineSp2:setAnchorPoint(ccp(0.5,1));
    -- lineSp2:setPosition(ccp(dialogBg:getContentSize().width/2,titleLb:getPositionY()-titleLb:getContentSize().height))
    -- dialogBg:addChild(lineSp2,2)
    -- lineSp2:setScaleX((dialogBg:getContentSize().width-160)/lineSp2:getContentSize().width)

    --奖励最多保存15天...
    local subLbSize = 16
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        subLbSize =20
    end
    local subTitleLb=GetTTFLabel(getlocal("rewardCenterSubTitle"),subLbSize)
    subTitleLb:setPosition(20,titleLb:getPositionY()-titleLb:getContentSize().height-15)
    subTitleLb:setAnchorPoint(ccp(0,0));
    dialogBg:addChild(subTitleLb,2)

    -- 奖励数量
    self.rewardNumLb=GetTTFLabel("x"..tostring(rewardCenterVoApi:getTotalRewarNum()),24)
    self.rewardNumLb:setPosition(dialogBg:getContentSize().width-15,titleLb:getPositionY()-titleLb:getContentSize().height-17)
    self.rewardNumLb:setAnchorPoint(ccp(1,0));
    dialogBg:addChild(self.rewardNumLb,2)

    local rewardNumIcon 
    if G_checkUseAuditUI()==true then
        rewardNumIcon= CCSprite:createWithSpriteFrameName("friendBtn.png");
        rewardNumIcon:setScale(0.7)
    else
        rewardNumIcon= CCSprite:createWithSpriteFrameName("bluegift.png");
        rewardNumIcon:setScale(0.9)
    end
    
    rewardNumIcon:setAnchorPoint(ccp(1,0.5));
    rewardNumIcon:setPosition(dialogBg:getContentSize().width-self.rewardNumLb:getContentSize().width-5,titleLb:getPositionY()-titleLb:getContentSize().height+4)
    dialogBg:addChild(rewardNumIcon,2)

    -- 全部领取
    local function getAllRewardHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local function getRewadCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.accessory then
                    accessoryVoApi:onRefreshData(sData.data.accessory)
                end
                if sData and sData.data.success and SizeOfTable(sData.data.success)>0 then

                    -- 新添加（一部分奖励后台无法给前台同步）
                    for k,id in pairs(sData.data.success) do
                        rewardCenterVoApi:getPointInListById(id)
                        local award=rewardCenterVoApi:getRewardListById(id)
                        local reward = FormatItem(award)
                        if reward then
                            for kk,v in pairs(reward) do
                                -- print("v.type,v.name",v.type,v.name)
                                if v.type~="u" and v.type~="o" and v.type~="h" and  v.type~="e" and v.type~="p" then
                                    G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num), nil, true)
                                end
                            end
                        end
                    end

                    rewardCenterVoApi:deleteSuccessAllRewardItem(sData.data.success)
                    local rewardStr=getlocal("rewardCenterGetAllSuccess")
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr ,30)

                    
                end
                if sData and sData.data.fail and SizeOfTable(sData.data.fail)>0 then
                    rewardCenterVoApi:deleteFailAllRewardItem(sData.data.fail)
                end
                if rewardCenterVoApi:getIsMore()== true and rewardCenterVoApi:isHasReward()==false then
                    local function sendMoreHandler(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if self.curPage<1 then 
                                self.curPage=rewardCenterVoApi:getMaxPage() 
                            end
                            if self.curPage>rewardCenterVoApi:getMaxPage() then 
                                self.curPage=1
                            end
                            self.tv:reloadData()
                            self:refresh()
                            self:controlPageBtn()
                        end
                    end
                    local temPage = self.curPage
                    if temPage<1 then 
                        temPage=rewardCenterVoApi:getMaxPage() 
                    end
                    if temPage>rewardCenterVoApi:getMaxPage() then 
                        temPage=1
                    end
                    socketHelper:getRewardCenterList(temPage,rewardCenterVoApi:getMaxNum(),sendMoreHandler)
                else
                    if rewardCenterVoApi:isHasReward()==true then
                        self.tv:reloadData()
                        self:refresh()
                    else
                        self:close()
                    end
                    
                end
            end
        end
        if SizeOfTable(rewardCenterVoApi:getAllRewardId())>0 then
            socketHelper:getRewardCenterReward(rewardCenterVoApi:getAllRewardId(),getRewadCallback)
        else
            -- print("-------dmj----------没有可以领取的奖励")
        end
    end
    local function closeHandler( ... )
        rewardCenterVoApi:deleteAllExpireRewardItems()
        self:close()
    end
    local closeBtn=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn.png",closeHandler,2,getlocal("fight_close"),24,100)
    closeBtn:setAnchorPoint(ccp(0.5,0.5))
    closeBtn:setScale(0.8)
    local lb = closeBtn:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb,"CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    local closeBtnMenu=CCMenu:createWithItem(closeBtn)
    closeBtnMenu:setPosition(ccp(dialogBg:getContentSize().width/4,closeBtn:getContentSize().height/2+21))
    closeBtnMenu:setTouchPriority(-(99-1)*20-1)
    dialogBg:addChild(closeBtnMenu,2)
    -- self.layerNum=self.layerNum+1

    self.getAllRewardBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getAllRewardHandler,11,getlocal("alien_tech_acceptAll"),24,100)
    self.getAllRewardBtn:setAnchorPoint(ccp(0.5,0.5))
    self.getAllRewardBtn:setScale(0.8)
    local lb = self.getAllRewardBtn:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb,"CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    local getAllRewardMenu=CCMenu:createWithItem(self.getAllRewardBtn)
    getAllRewardMenu:setPosition(ccp(dialogBg:getContentSize().width/4*3,self.getAllRewardBtn:getContentSize().height/2+21))
    getAllRewardMenu:setTouchPriority(-(99-1)*20-1)
    dialogBg:addChild(getAllRewardMenu,2)
    -- self.layerNum=self.layerNum+1
    -- 奖励列表
    local tvHight=subTitleLb:getPositionY()-subTitleLb:getContentSize().height-getAllRewardMenu:getPositionY() -35
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(dialogBg:getContentSize().width-20,tvHight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setAnchorPoint(ccp(0,1))
    self.tv:setPosition(ccp(10,100))
    dialogBg:addChild(self.tv,3)
    -- self.layerNum=self.layerNum+1

    local function touch3( ... )
        print("----dmj======touch3")
    end
    local topSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touch3);
    topSp:setAnchorPoint(ccp(0,1))
    topSp:setContentSize(CCSizeMake(dialogBg:getContentSize().width,dialogBg:getContentSize().height-subTitleLb:getPositionY()+subTitleLb:getContentSize().height))
    dialogBg:addChild(topSp)
    topSp:setPosition(ccp(0,dialogBg:getContentSize().height))
    topSp:setTouchPriority(-(self.layerNum-1)*20-9)
    topSp:setVisible(false)

    local bottomSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touch3);
    bottomSp:setAnchorPoint(ccp(0,0))
    bottomSp:setContentSize(CCSizeMake(dialogBg:getContentSize().width,self.getAllRewardBtn:getContentSize().height+20))
    dialogBg:addChild(bottomSp)
    bottomSp:setPosition(ccp(0,0))
    bottomSp:setTouchPriority(-(self.layerNum-1)*20-9)
    bottomSp:setVisible(false)
    return self.bgLayer
end


--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function rewardCenterDialog:eventHandler(handler,fn,idx,cel)
    local temHeight = 260-55
    local temLbHeight = 28
    if fn=="numberOfCellsInTableView" then
        self.listNum = SizeOfTable(rewardCenterVoApi:getRewardVoList())
        return self.listNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local rewardVo=rewardCenterVoApi:getRewardVoByIndex(idx)
        if rewardVo then
            local temRewardDescLb=GetTTFLabelWrap(rewardVo:getRewardDescStr(),18,CCSizeMake(self.bgLayer:getContentSize().width-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            if temRewardDescLb:getContentSize().height>temLbHeight then--大于2行的，高度需要动态计算
                temHeight=temHeight-temLbHeight+temRewardDescLb:getContentSize().height
            end
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,temHeight)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
            local rewardVo=rewardCenterVoApi:getRewardVoByIndex(idx)
            local subLbSize2 = 16
            if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
                subLbSize2 =22
            end
            if rewardVo then
                local startY = 260-55
                -- 背景
                local function cellClick( ... )
                    -- body
                end
                local rewardDescLb=GetTTFLabelWrap(rewardVo:getRewardDescStr(),18,CCSizeMake(self.bgLayer:getContentSize().width-36, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                rewardDescLb:setColor(G_ColorYellowPro)
                --奖励条目的最外框
                local sprieBg=LuaCCScale9Sprite:createWithSpriteFrameName("boxbg.png",CCRect(5, 5, 1, 1),cellClick)
                if rewardDescLb:getContentSize().height>temLbHeight then--大于2行的，高度需要动态计算
                    temHeight=temHeight-temLbHeight+rewardDescLb:getContentSize().height
                    startY=temHeight-10
                end
                sprieBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,temHeight-10))
                sprieBg:setAnchorPoint(ccp(0,0))
                sprieBg:setPosition(ccp(0,10))
                sprieBg:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(sprieBg)
                --渐变
                local sprieBg2=CCSprite:createWithSpriteFrameName("gradualchange.png")
                sprieBg2:setAnchorPoint(ccp(1,0))
                sprieBg2:setPosition(ccp(self.bgLayer:getContentSize().width,0))
                sprieBg:addChild(sprieBg2)

                local subTitleSp=CCSprite:createWithSpriteFrameName("littletitle.png")
                -- subTitleSp:setFlipX(true)
                subTitleSp:setAnchorPoint(ccp(0,0))
                subTitleSp:setPosition(ccp(0,sprieBg:getContentSize().height-subTitleSp:getContentSize().height+10))
                cell:addChild(subTitleSp,2)
                -- 小标题以及描述，日期
                local rewardTitleLb=GetTTFLabel(rewardVo:getRewardTitleStr(),subLbSize2,true)
                rewardTitleLb:setPosition(20,subTitleSp:getPositionY()+subTitleSp:getContentSize().height/2)
                rewardTitleLb:setAnchorPoint(ccp(0,0.5));
                cell:addChild(rewardTitleLb,3)

                local expireTimeLb=GetTTFLabel(rewardVo:getExpireTimeStr(),20)
                expireTimeLb:setPosition(sprieBg:getContentSize().width-10,rewardTitleLb:getPositionY())
                expireTimeLb:setAnchorPoint(ccp(1,0.5));
                expireTimeLb:setColor(G_ColorGreen)
                cell:addChild(expireTimeLb,3)

                
                rewardDescLb:setPosition(10,rewardTitleLb:getPositionY()-rewardTitleLb:getContentSize().height)
                rewardDescLb:setAnchorPoint(ccp(0,1));
                cell:addChild(rewardDescLb,3)

                -- 奖励列表
                -- print("-----dmj----len:"..SizeOfTable(rewardVo.reward))
                -- G_dayin(rewardVo.reward)
                local curRewardList = FormatItem(rewardVo.reward)
                local rewardVd = self:initRewarListDialog(curRewardList,idx);
                rewardVd:setAnchorPoint(ccp(0,0))
                rewardVd:setPosition(ccp(15,20))
                -- rewardVd:setTag(idx)
                cell:addChild(rewardVd,4)
                
                
                -- 领取按钮或者已过期文本
                local function getRewadHandler(tag,object)
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local function getRewadCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData and sData.data and sData.data.accessory then
                                accessoryVoApi:onRefreshData(sData.data.accessory)
                            end
                            if sData and sData.data.success and SizeOfTable(sData.data.success)>0 then
                                local id = sData.data.success[1]
                                rewardCenterVoApi:getPointInListById(id)
                                local award=rewardCenterVoApi:getRewardListById(id)
                                local reward = FormatItem(award)
                                local rewardStr=getlocal("daily_lotto_tip_10")
                                if reward then
                                    for k,v in pairs(reward) do
                                        if k==SizeOfTable(reward) then
                                            rewardStr = rewardStr .. v.name .. " x" .. v.num
                                        else
                                            rewardStr = rewardStr .. v.name .. " x" .. v.num .. ","
                                        end
                                        -- 新添加（一部分奖励后台无法给前台同步）
                                        if v.type~="u" and v.type~="o" and v.type~="h" and  v.type~="e" and v.type~="p" then
                                            G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num), nil, true)
                                        end
                                    end
                                    -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr ,30,nil,nil,reward)
                                    G_showRewardTip(reward, true)
                                    rewardCenterVoApi:deleteRewardItemById(id)

                                    if rewardCenterVoApi:getIsMore()== true and rewardCenterVoApi:isHasReward()==false then
                                        local function sendMoreHandler(fn,data)
                                            local ret,sData=base:checkServerData(data)
                                            if ret==true then
                                                if self.curPage<1 then 
                                                    self.curPage=rewardCenterVoApi:getMaxPage() 
                                                end
                                                if self.curPage>rewardCenterVoApi:getMaxPage() then 
                                                    self.curPage=1
                                                end
                                                self.tv:reloadData()
                                                self:refresh()
                                                self:controlPageBtn()
                                            end
                                        end
                                        local temPage = self.curPage
                                        if temPage<1 then 
                                            temPage=rewardCenterVoApi:getMaxPage() 
                                        end
                                        if temPage>rewardCenterVoApi:getMaxPage() then 
                                            temPage=1
                                        end
                                        socketHelper:getRewardCenterList(temPage,rewardCenterVoApi:getMaxNum(),sendMoreHandler)
                                    else
                                        if rewardCenterVoApi:isHasReward()==true then
                                            -- local recordPoint = self.tv:getRecordPoint()
                                            self.tv:reloadData()
                                            -- self.tv:recoverToRecordPoint(recordPoint)
                                            self:refresh()
                                        else
                                            self:close()
                                        end
                                        
                                    end
                                end
                            elseif  sData and sData.data.fail and SizeOfTable(sData.data.fail)>0 then
                                 -- 该奖励物品已经过期
                                rewardCenterVoApi:deleteFailAllRewardItem(sData.data.fail)
                                if rewardCenterVoApi:isHasReward()==true then
                                    local recordPoint = self.tv:getRecordPoint()
                                    self.tv:reloadData()
                                    self.tv:recoverToRecordPoint(recordPoint)
                                    self:refresh()
                                else
                                    self:close()
                                end
                            end
                        end
                    end
                    socketHelper:getRewardCenterReward({rewardVo:getId()},getRewadCallback)
                end
                if rewardVo:isExpire()==true then
                    local expireLb=GetTTFLabelWrap(getlocal("expireDesc"),22,CCSizeMake(140, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                    expireLb:setPosition(ccp(sprieBg:getContentSize().width-75,rewardVd:getContentSize().height/2+5))
                    expireLb:setAnchorPoint(ccp(0.5,0));
                    cell:addChild(expireLb,5)
                else
                    local getRewardBtn=GetButtonItem("yh_taskReward.png","yh_taskReward_down.png","yh_taskReward.png",getRewadHandler,11,nil,0)
                    getRewardBtn:setAnchorPoint(ccp(1,0))
                    local getRewardBtnMenu=CCMenu:createWithItem(getRewardBtn)
                    getRewardBtnMenu:setPosition(ccp(sprieBg:getContentSize().width-35,45))
                    getRewardBtnMenu:setTouchPriority(-(self.layerNum-1)*20-7)
                    cell:addChild(getRewardBtnMenu,5)
                    getRewardBtnMenu:setTag(idx+1)
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

--这是奖励条目里面的小框
function rewardCenterDialog:initRewarListDialog(curRewardList,index)
    local function touch()
        
    end
    local rewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("littlebox.png",CCRect(20, 20, 2, 2),touch)
    rewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-200,110))
    -- rewardBg:setTouchPriority(-(self.layerNum-1)*20-3)
    rewardBg:setPosition(ccp(0,0))
    rewardBg:setAnchorPoint(ccp(0,0))
    local function callBack2(handler,fn,idx,cell)
        return self:eventHandler2(handler,fn,idx,cell,curRewardList,index)
    end
    -- self.layerNum=self.layerNum+1
    local hd2= LuaEventHandler:createHandler(callBack2)
    local tv=LuaCCTableView:createHorizontalWithEventHandler(hd2,CCSizeMake(self.bgLayer:getContentSize().width-215,125),nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    tv:setAnchorPoint(ccp(0,1))
    tv:setPosition(ccp(8,-5))
    rewardBg:addChild(tv,self.layerNum)
    -- self.layerNum=self.layerNum+1
    return rewardBg
end

function rewardCenterDialog:eventHandler2(handler,fn,idx,cel,curRewardList,index)

    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(curRewardList)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(100,120)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local rewardItem = curRewardList[idx+1]
        if rewardItem then 
            local function showTip()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==true then
                    return
                end
                if rewardItem then
                    propInfoDialog:create(sceneGame,rewardItem,100)
                end
            end
            local iconSize=70
            -- print("-------dmj-----rewardItem.pic:"..rewardItem.pic)
            -- local iconSp=LuaCCSprite:createWithSpriteFrameName(rewardItem.pic,showTip)
            -- print("id----->",rewardItem.id,rewardItem.name,rewardItem.pic)
            -- print("----dmj----pic:"..rewardItem.id..rewardItem.pic.."---id:"..rewardItem.id.."--tyep:"..rewardItem.type)
            -- G_dayin(rewardItem)
            local iconSp = G_getItemIcon(rewardItem,nil,true,100,showTip,nil,nil,nil,nil,nil,true)
            iconSp:setAnchorPoint(ccp(0,0))
            iconSp:setPosition(ccp(10,30))
            iconSp:setTouchPriority(-(self.layerNum-1)*20-4)
            cell:addChild(iconSp)
            iconSp:setScale(iconSize/iconSp:getContentSize().width)
            -- iconSp:setScale(0.9)
            -- self.layerNum=self.layerNum+1/
            --奖励数量
            local numLb=GetTTFLabel("x"..FormatNumber(rewardItem.num),20)
            numLb:setPosition(iconSize/2+7,8)
            numLb:setAnchorPoint(ccp(0.5,0));
            cell:addChild(numLb,3)
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

-- 翻页按钮
function rewardCenterDialog:initPageBtn()
    
    local scale=1.3
    if self.leftBtn==nil then
        local function leftPageHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end

            if self.isAnimation==true or (battleScene and battleScene.isBattleing==true) then
                do return end
            end

            PlayEffect(audioCfg.mouseClick)

            self:leftPage()

        end
        self.leftBtn=GetButtonItem("rewardCenterArrow.png","rewardCenterArrow.png","rewardCenterArrow.png",leftPageHandler,11,nil,nil)
        self.leftBtn:setScale(scale)
        local leftMenu=CCMenu:createWithItem(self.leftBtn)
        leftMenu:setAnchorPoint(ccp(0.5,0.5))
        leftMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(leftMenu,6)
        leftMenu:setPosition(ccp(-15,self.bgLayer:getContentSize().height/2))

        local posX,posY=leftMenu:getPosition()
        local posX2=posX+20

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
        leftMenu:runAction(CCRepeatForever:create(seq))
    end

    if self.rightBtn==nil then
        local function rightPageHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end

            if self.isAnimation==true or (battleScene and battleScene.isBattleing==true) then
                do return end
            end

            PlayEffect(audioCfg.mouseClick)
            
            self:rightPage()

        end
        self.rightBtn=GetButtonItem("rewardCenterArrow.png","rewardCenterArrow.png","rewardCenterArrow.png",rightPageHandler,11,nil,nil)
        self.rightBtn:setRotation(180)
        self.rightBtn:setScale(scale)
        local rightMenu=CCMenu:createWithItem(self.rightBtn)
        rightMenu:setAnchorPoint(ccp(0.5,0.5))
        rightMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(rightMenu,6)

        rightMenu:setPosition(ccp(self.bgLayer:getContentSize().width+15,self.bgLayer:getContentSize().height/2))

        local posX,posY=rightMenu:getPosition()
        local posX2=posX-20

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
        rightMenu:runAction(CCRepeatForever:create(seq))
    end

    

    local pageStr = self.curPage.."/"..rewardCenterVoApi:getMaxPage()
    self.pageLb=GetTTFLabel(pageStr,24)
    self.pageLb:setPosition(self.bgLayer:getContentSize().width/2,38)
    self.pageLb:setAnchorPoint(ccp(0.5,0));
    self.bgLayer:addChild(self.pageLb,6)

    -- local spriteTitle1 = CCSprite:createWithSpriteFrameName("worldInputBg.png");
    -- spriteTitle1:setAnchorPoint(ccp(0.5,0));
    -- spriteTitle1:setPosition(self.bgLayer:getContentSize().width/2,35)
    -- self.bgLayer:addChild(spriteTitle1,5)

    self:controlPageBtn()
end

function rewardCenterDialog:leftPage()
    local function sendMoreHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            self.curPage=self.curPage-1
            if self.curPage<1 then 
                self.curPage=rewardCenterVoApi:getMaxPage() 
            end
            if self.curPage>rewardCenterVoApi:getMaxPage() then 
                self.curPage=1
            end
            self.tv:reloadData()
            self:refresh()
            self:controlPageBtn()
        end
    end
    local temPage = self.curPage-1
    if temPage<1 then 
        temPage=rewardCenterVoApi:getMaxPage() 
    end
    if temPage>rewardCenterVoApi:getMaxPage() then 
        temPage=1
    end
    socketHelper:getRewardCenterList(temPage,rewardCenterVoApi:getMaxNum(),sendMoreHandler)

end

function rewardCenterDialog:rightPage()
    local function sendMoreHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            self.curPage=self.curPage+1
            if self.curPage<1 then 
                self.curPage=rewardCenterVoApi:getMaxPage() 
            end
            if self.curPage>rewardCenterVoApi:getMaxPage() then 
                self.curPage=1
            end
            self.tv:reloadData()
            self:refresh()
            self:controlPageBtn()
        end
    end
    local temPage = self.curPage+1
    if temPage<1 then 
        temPage=rewardCenterVoApi:getMaxPage() 
    end
    if temPage>rewardCenterVoApi:getMaxPage() then 
        temPage=1
    end
    socketHelper:getRewardCenterList(temPage,rewardCenterVoApi:getMaxNum(),sendMoreHandler)
    
end

function rewardCenterDialog:controlPageBtn()
    local maxPage = rewardCenterVoApi:getMaxPage()
    if maxPage>1 then
        if self.leftBtn then
            self.leftBtn:setVisible(true)
        end    
        if self.rightBtn then
            self.rightBtn:setVisible(true)
        end
    else
        if self.leftBtn then
            self.leftBtn:setVisible(false)
        end
        if self.rightBtn then
            self.rightBtn:setVisible(false)
        end
    end
    if self.pageLb then
        local pageStr = self.curPage.."/"..rewardCenterVoApi:getMaxPage()
        self.pageLb:setString(pageStr)
    end
end

function rewardCenterDialog:initSunShine( parent ,titleHeight , leftPos)
    -- local rewardshunshiebg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    -- rewardshunshiebg:setOpacity(0)
    -- parent:addChild(rewardshunshiebg,-1)
    -- rewardshunshiebg:setPosition(leftPos)
    -- -- rewardshunshiebg:setScaleY(1/1.25)
    -- rewardshunshiebg:setScale(1.2)
    for i=1,2 do
      local realLight = CCSprite:createWithSpriteFrameName("rewardsunshinelight.png")
      realLight:setScale(1.5)
      realLight:setPosition(leftPos)
      if i==1 then
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        realLight:setBlendFunc(blendFunc)
      end
      -- if i==2 then
      --   realLight:setOpacity(0.5*255)
      -- end      
      parent:addChild(realLight,-i) 
      local roteSize = i ==1 and 180 or -180
      local orif ,tarf= 255,0.4*255
      -- if i==2 then
      --   orif,tarf=0.2*255,255
      -- end
      realLight:setOpacity(orif)

      local arr1 = CCArray:create()
      local rotate1=CCRotateBy:create(4.5, roteSize)
      arr1:addObject(rotate1)
      local fadeTo1 = CCFadeTo:create(4.5,tarf)
      arr1:addObject(fadeTo1)
      local spawn1 = CCSpawn:create(arr1)
      local arr2 = CCArray:create()
      local rotate2=CCRotateBy:create(4.5, roteSize)
      arr2:addObject(rotate2)
      local fadeTo2 = CCFadeTo:create(4.5,orif)
      arr2:addObject(fadeTo2)
      local spawn2 = CCSpawn:create(arr2)
      local seq = CCSequence:createWithTwoActions(spawn1,spawn2)

      -- local repeatForever = CCRepeatForever:create(rotate1)
      -- realLight:runAction(repeatForever)
    
      local finalAc = CCRepeatForever:create(seq)
      realLight:runAction(finalAc)
    end
end

--刷新板子
function rewardCenterDialog:refresh()
    if self.rewardNumLb and rewardCenterVoApi then
        self.rewardNumLb:setString("x"..tostring(rewardCenterVoApi:getTotalRewarNum()))
    end
end

function rewardCenterDialog:tick()

end

function rewardCenterDialog:close()
    self.pageLb=nil
    self.curPage=1
    self.rewardNumLb=nil
    self.listNum=0
    self.getAllRewardBtn=nil
    self.layerNum=0
    self.maxNum=1
    if self and self.touchDialogBg then
        self.touchDialogBg:removeFromParentAndCleanup(true)
        self.touchDialogBg=nil
    end
    if self and self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    spriteController:removePlist("public/acThfb.plist")
    spriteController:removeTexture("public/acThfb.png")
    spriteController:removePlist("public/rewardCenterImage.plist")
    spriteController:removeTexture("public/rewardCenterImage.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/bubbleImage.plist")

end

function rewardCenterDialog:dispose()

end
