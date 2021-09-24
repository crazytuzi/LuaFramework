local believerSmallDialog=smallDialog:new()

function believerSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function believerSmallDialog:showReceiveTroopsDialog(size,troops,layerNum,callback)
  	local smdialog=believerSmallDialog:new()
	smdialog:initReceiveTroopsDialog(size,troops,layerNum,callback)
	return smdialog
end

function believerSmallDialog:initReceiveTroopsDialog(size,troops,layerNum,callback)
    self.isTouch=nil
    self.isUseAmi=true
    self.layerNum=layerNum
    local function touchHander()
    end
    local dialogBg=G_getNewDialogBg2(size,self.layerNum,touchHander,getlocal("believer_receive_troops"),30,titleColor)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)

    local content={}
    for k,v in pairs(troops) do
        table.insert(content,{k,v})
    end
    local tankCount=SizeOfTable(content)
    local cellWidth,cellHeight=490,120
    local cellHeight=120
    local isMoved=false

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return tankCount
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local tankId,tankNum=content[idx+1][1],content[idx+1][2]
            tankId=tonumber(tankId) or tonumber(RemoveFirstChar(tankId))

            local tmpTankCfg=tankCfg[tankId]
            local iconScale,fontSize=1,25

            local tankIcon=tankVoApi:getTankIconSp(tankId)--CCSprite:createWithSpriteFrameName(tmpTankCfg.icon)
            tankIcon:setAnchorPoint(ccp(0,0.5))
            tankIcon:setPosition(ccp(25,cellHeight/2))
            iconScale=80/tankIcon:getContentSize().width
            tankIcon:setScale(iconScale)
            cell:addChild(tankIcon)

            --坦克名称
            local nameLb=GetTTFLabelWrap(getlocal(tmpTankCfg.name),fontSize,CCSizeMake(cellWidth-105-20-105,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLb:setAnchorPoint(ccp(0.5,0.5))
            nameLb:setPosition(ccp(cellWidth/2,tankIcon:getPositionY()))
            cell:addChild(nameLb)

            --赠送数量
            local numLb=GetTTFLabelWrap("x"..tankNum,fontSize,CCSizeMake(80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            numLb:setAnchorPoint(ccp(0.5,0.5))
            numLb:setPosition(ccp(cellWidth-65,nameLb:getPositionY()))
            cell:addChild(numLb)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,size.height-200),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
    self.tv:setPosition(ccp((self.bgSize.width-cellWidth)/2,120))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
  
    local function confirm()
         PlayEffect(audioCfg.mouseClick)
         if callback ~=nil then
            callback()
         end
         self:close()
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",confirm,2,getlocal("ok"),25/0.8)
    sureItem:setScale(0.8)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-4);
    dialogBg:addChild(sureMenu)
    
    local function touchLuaSpr()
         
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function believerSmallDialog:showMatchSmallDialog(layerNum,callback)
    local sd=believerSmallDialog:new()
    sd:initMatchSmallDialog(layerNum,callback)
end

function believerSmallDialog:initMatchSmallDialog(layerNum,callback)
    local matchInfo=believerVoApi:getMatchInfo()
    if matchInfo==nil then
        self:close()
        do return end
    end
    local matchPlayer=matchInfo.player

    spriteController:addPlist("public/youhuaUI4.plist")
    spriteController:addTexture("public/youhuaUI4.png")
    self.isTouch=nil
    self.isUseAmi=true
    self.layerNum=layerNum
    self.bgSize=CCSizeMake(580,300)

    local dialogBg=G_getNewDialogBg2(self.bgSize,self.layerNum,nil,getlocal("believer_matching"),25,G_ColorWhite)
    dialogBg:setContentSize(self.bgSize)
    -- dialogBg:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer=dialogBg
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:addChild(dialogBg,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))

    local fontSize=25
    if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
        fontSize=22
    end
    local time=10
    local randMarryTime=math.random(1,3)
    -- randMarryTime=(randMarryTime%5)+1
    randMarryTime=time-randMarryTime
    local leftTimeLb=GetTTFLabel("00:"..time,fontSize)
    leftTimeLb:setAnchorPoint(ccp(0.5,1))
    leftTimeLb:setPosition(self.bgSize.width/2,self.bgSize.height-40)
    self.bgLayer:addChild(leftTimeLb,1)
    -- 倒计时动画
    local function setTimeHandler()
        if leftTimeLb and leftTimeLb.setString then
            time=time-1
            if time>=randMarryTime then
                leftTimeLb:setString("00:"..string.format("%02d",time))
            else
                leftTimeLb:stopAllActions()
                leftTimeLb:setVisible(false)
            end
        end
    end
    local delayTime=CCDelayTime:create(1)
    local setFunc=CCCallFunc:create(setTimeHandler)
    local seq=CCSequence:createWithTwoActions(delayTime,setFunc)
    local repeatForever=CCRepeatForever:create(seq)
    leftTimeLb:runAction(repeatForever)

    local leftHeadPosX,leftHeadPosY=self.bgSize.width/2-160,self.bgSize.height/2
    local rightHeadPosX,rightHeadPosY=self.bgSize.width/2+160,self.bgSize.height/2

    --中间vs
    local vsSp=CCSprite:createWithSpriteFrameName("VS.png")
    vsSp:setAnchorPoint(ccp(0.5,0.5))
    vsSp:setPosition(self.bgSize.width/2,self.bgSize.height/2)
    self.bgLayer:addChild(vsSp)

    local lBorderSp=CCSprite:createWithSpriteFrameName("newKuang4.png")
    lBorderSp:setPosition(leftHeadPosX,leftHeadPosY)
    self.bgLayer:addChild(lBorderSp)

    local iconWidth=80
    --玩家头像
    local picId=playerVoApi:getPic()
    local personPhotoName=playerVoApi:getPersonPhotoName(picId)
    local playerPhotoSp1=playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,iconWidth)
    playerPhotoSp1:setPosition(leftHeadPosX,leftHeadPosY)
    self.bgLayer:addChild(playerPhotoSp1)

    local nameLb1=GetTTFLabel(playerVoApi:getPlayerName(),fontSize)
    nameLb1:setAnchorPoint(ccp(0.5,1))
    nameLb1:setPosition(leftHeadPosX,leftHeadPosY-80)
    self.bgLayer:addChild(nameLb1)

    local rBorderSp=CCSprite:createWithSpriteFrameName("newKuang4.png")
    rBorderSp:setPosition(rightHeadPosX,rightHeadPosY)
    self.bgLayer:addChild(rBorderSp)

    --对手头像
    local mpicName=playerVoApi:getPersonPhotoName(matchPlayer.pic)
    local playerPhotoSp2=playerVoApi:GetPlayerBgIcon(mpicName,nil,nil,nil,iconWidth,matchPlayer.hfid)
    playerPhotoSp2:setPosition(rightHeadPosX,rightHeadPosY)
    playerPhotoSp2:setVisible(false)
    self.bgLayer:addChild(playerPhotoSp2,2)

    local nameLb2=GetTTFLabel(matchPlayer.name,fontSize)
    nameLb2:setAnchorPoint(ccp(0.5,1))
    nameLb2:setPosition(rightHeadPosX,rightHeadPosY-80)
    nameLb2:setVisible(false)
    self.bgLayer:addChild(nameLb2)

    local believerCfg=believerVoApi:getBelieverCfg()
    --存储闪现的头像
    local randHeadSpTb={}
    --头像配置集合
    local headCfgTb={}
    --可用头像数量
    local headNum=0
    local function getHeadSpHandler()
        local dataTb=believerCfg.photoRand
        if dataTb then
            for k,v in pairs(dataTb) do
                -- 先放头像，隐藏
                local picName=playerVoApi:getPersonPhotoName(2000+tonumber(v))
                local tmpSp=playerVoApi:GetPlayerBgIcon(picName,nil,nil,nil,iconWidth)
                tmpSp:setPosition(playerPhotoSp2:getPosition())
                tmpSp:setVisible(false)
                self.bgLayer:addChild(tmpSp,1)

                table.insert(randHeadSpTb,tmpSp)
                headNum=headNum+1
            end
        end
    end
    getHeadSpHandler()
    --第一个是谁~
    local lastHeadIdx=math.random(1,headNum)
    if randHeadSpTb[lastHeadIdx] then
        randHeadSpTb[lastHeadIdx]:setVisible(true)
    end

    local function acHeadHandler()
        if time<=randMarryTime then
            if playerPhotoSp2 then
                playerPhotoSp2:stopAllActions()
                --头像尺寸
                local spWidth=playerPhotoSp2:getContentSize().width
                local spHeight=playerPhotoSp2:getContentSize().height
                local function showParticle1()
                    -- local particle1=CCParticleSystemQuad:create("public/superEquip/superEquipGlowup1.plist")
                    -- particle1:setPositionType(kCCPositionTypeFree)
                    -- particle1:setPosition(ccp(spWidth/2,spHeight/2))
                    -- particle1:setAutoRemoveOnFinish(true) -- 自动移除
                    -- playerPhotoSp2:addChild(particle1,1)

                    -- local particle2=CCParticleSystemQuad:create("public/superEquip/superEquipGlowup2.plist")
                    -- particle2:setPositionType(kCCPositionTypeFree)
                    -- particle2:setPosition(ccp(spWidth/2,spHeight/2))
                    -- particle2:setAutoRemoveOnFinish(true) -- 自动移除
                    -- playerPhotoSp2:addChild(particle2,2)
                end
                local function showParticle2()
                    -- local particle=CCParticleSystemQuad:create("public/superEquip/superEquipGlowup3.plist")
                    -- particle:setPositionType(kCCPositionTypeFree)
                    -- particle:setPosition(ccp(spWidth/2,spHeight/2))
                    -- particle:setAutoRemoveOnFinish(true) -- 自动移除
                    -- playerPhotoSp2:addChild(particle,3)
                end
                local function showMarryInfoHander()
                    self:close()
                    spriteController:removePlist("public/youhuaUI4.plist")
                    spriteController:removeTexture("public/youhuaUI4.png")
                    if callback then
                        callback(false,true)
                    end    
                end
                local delay=CCDelayTime:create(0.9)
                local callFunc=CCCallFunc:create(showMarryInfoHander)
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq11=CCSequence:create(acArr)
                playerPhotoSp2:runAction(seq11)
                --显示真正的对手头像
                playerPhotoSp2:setVisible(true)
                nameLb2:setVisible(true)
                --隐藏掉假头像
                if randHeadSpTb[lastHeadIdx] then
                    randHeadSpTb[lastHeadIdx]:setVisible(false)
                end
            end
        else
            --先把之前的头像隐藏掉
            if randHeadSpTb[lastHeadIdx] then
                randHeadSpTb[lastHeadIdx]:setVisible(false)
            end
            local randHeadIdx=math.random(1,headNum)
            --与之前重复，处理一下
            if randHeadIdx==lastHeadIdx then
                --如果当前是1
                if randHeadIdx==1 then
                    randHeadIdx=randHeadIdx+math.random(2,headNum)
                else
                    --大于1的话，则取（idx-1）
                    randHeadIdx=randHeadIdx-1
                end
            end
            --跟之前的不重复
            if randHeadSpTb[randHeadIdx] then
                --直接显示
                randHeadSpTb[randHeadIdx]:setVisible(true)
                --记录当前的头像idx
                lastHeadIdx=randHeadIdx
            end
        end
    end
    local delayTime=CCDelayTime:create(0.1)
    local acHeadFunc=CCCallFunc:create(acHeadHandler)
    local seq=CCSequence:createWithTwoActions(acHeadFunc,delayTime)
    local repeatForever=CCRepeatForever:create(seq)
    playerPhotoSp2:runAction(repeatForever)

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(0,0)
    return self.dialogLayer
end

function believerSmallDialog:showTroopsFormationSmallDialog(troopType,layerNum,readCallBack)
    local sd=believerSmallDialog:new()
    sd:initTroopsFormationSmallDialog(troopType,layerNum,readCallBack)
end

function believerSmallDialog:initTroopsFormationSmallDialog(troopType,layerNum,readCallBack)
    self.isTouch=nil
    self.isUseAmi=true
    self.layerNum=layerNum
    self.troopType=troopType
    self.bgSize=CCSizeMake(550,700)

    local function close()
        return self:close()
    end
    local dialogBg=G_getNewDialogBg(self.bgSize,getlocal("formation"),30,nil,self.layerNum,true,close)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local cellWidth,cellHeight,tvHeight=self.bgSize.width-20,160,self.bgSize.height-80
    local fontSize=25
    if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
        fontSize=22
    end
    local believerCfg=believerVoApi:getBelieverCfg()
    local cellNum=believerCfg.formationNum
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return cellNum
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(cellWidth,cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local itemBg=G_getThreePointBg(CCSizeMake(cellWidth,cellHeight-10),nil,ccp(0.5,0.5),ccp(cellWidth/2,cellHeight/2),cell)
            local titleBg=G_createNewTitle({getlocal("formation_index",{idx+1}),24},CCSizeMake(300,0))
            titleBg:setPosition(cellWidth/2,itemBg:getContentSize().height-40)
            itemBg:addChild(titleBg)

            local btnScale,priority=0.6,-(self.layerNum-1)*20-3
            local isSaved,troopsInfo=believerVoApi:getFormationByIndex(idx+1,self.troopType)
            local function storageHandler()
                if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    local tankTab=tankVoApi:getTanksTbByType(self.troopType)
                    believerVoApi:saveFormationByIndex(idx+1,tankTab,self.troopType)
                    if self.tv then
                        local recordPoint=self.tv:getRecordPoint()
                        self.tv:reloadData()
                        self.tv:recoverToRecordPoint(recordPoint)
                    end
                    self:close()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),30)            
                end
            end
            if isSaved==true then
                G_createBotton(itemBg,ccp(cellWidth/2-120,60),{getlocal("cover"),25},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",storageHandler,btnScale,priority)
            else
                G_createBotton(itemBg,ccp(cellWidth/2,60),{getlocal("storage"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",storageHandler,btnScale,priority)
            end

            if isSaved==true then
                local function readHandler()
                    if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        --检查阵型内是否有限制兵种
                        local illegalState=believerVoApi:checkTroopsIllegal(troopsInfo)
                        if illegalState~=0 then
                            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("believer_troop_formation_lock"),nil,self.layerNum+1)
                            do return end
                        end
                        local function loadHandler()
                            for k,v in pairs(troopsInfo) do
                                if v and SizeOfTable(v)>0 then
                                    tankVoApi:setTanksByType(self.troopType,k,v[1],v[2])
                                else
                                    tankVoApi:deleteTanksTbByType(self.troopType,k)
                                end
                            end
                            if readCallBack then --更新我方部队
                                readCallBack()
                            end
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_read_formation_success"),30)            
                            self:close()
                        end
                        --兵池数据
                        local troopPool=believerVoApi:getTroopsPool()
                        --创建数组，key为fleetId，value为num
                        local fleetNumTb={}
                        --处理兵池数据
                        for k,v in pairs(troopPool) do
                            fleetNumTb[v[1]]=tonumber(v[2])
                        end
                        --兵池是否足够
                        local isEnough=true
                        --需要兑换的坦克数量
                        local needBuyTb={}
                        --遍历阵型，如果有不足的坦克需要提示是否兑换 
                        for k,v in pairs(troopsInfo) do
                            if v and SizeOfTable(v)>0 then
                                if fleetNumTb[v[1]] and fleetNumTb[v[1]]>=v[2] then
                                    fleetNumTb[v[1]]=fleetNumTb[v[1]]-v[2]
                                else --不足以兑换
                                    isEnough=false
                                    table.insert(needBuyTb,"a"..v[1])
                                end
                            end
                        end
                        if SizeOfTable(needBuyTb)>0 then
                            --是否可以兑换
                            local canExchange=true
                            local hasCostFleetTb={}
                            for k,v in pairs(needBuyTb) do
                                local fleetId=tonumber(RemoveFirstChar(v))
                                --需要的数量
                                local needNum=believerVoApi:getTroopExchangeCostNum(k) or 0
                                --当前拥有的全部数量
                                local hasNum=tankVoApi:getTankCountByItemId(fleetId)
                                --如果之前已经有此舰船的兑换需求，则计算剩余数量
                                if hasCostFleetTb[fleetId] then
                                    hasNum=hasNum-hasCostFleetTb[fleetId]
                                end
                                if hasNum<needNum then
                                    canExchange=false
                                    do break end
                                else
                                    --可兑换，记录数量，方便后面统计判断
                                    if hasCostFleetTb[fleetId]==nil then
                                        hasCostFleetTb[fleetId]=needNum
                                    else
                                        hasCostFleetTb[fleetId]=hasCostFleetTb[fleetId]+needNum
                                    end
                                end
                            end
                            if canExchange==true then
                                --请求一键补兵
                                local function oneKeyCallBack()
                                    local function oneKeyHandler()
                                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_change_sucess"),30)
                                        loadHandler()
                                    end
                                    local list={}
                                    for k,v in pairs(needBuyTb) do
                                        local needNum=believerVoApi:getTroopExchangeCostNum(k) or 0
                                        table.insert(list,{v,needNum})
                                    end
                                    believerVoApi:believerExchange(list,oneKeyHandler)
                                end
                                -- 已经设置自动补兵
                                if believerVoApi:checkAutoExchange()==true then
                                    oneKeyCallBack()
                                else
                                    local exchangeList,exchangeRateTb,troopsNum={},{},believerCfg.troopsNum
                                    for k,v in pairs(needBuyTb) do
                                        table.insert(exchangeList,{v,troopsNum})
                                        local cost=believerVoApi:getTroopExchangeCostNum(k)
                                        local exchangeNum=believerVoApi:getDayExchangeNum()+k
                                        table.insert(exchangeRateTb,{cost,troopsNum,exchangeNum})
                                    end
                                    local isAutoCheck=believerVoApi:checkAutoExchange()
                                    local function oneKeyConfirmHandler(callback)
                                        local function onConfirm()
                                            believerVoApi:requestAutoExchange(1,callback)
                                        end
                                        G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("believer_troop_exchange_oneKey_desc"),true,onConfirm)
                                    end
                                    local function oneKeyCancelHandler(callback)
                                        believerVoApi:requestAutoExchange(0,callback)
                                    end
                                    believerVoApi:showTroopExchangeSmallDialog(exchangeList,exchangeRateTb,true,self.layerNum+1,oneKeyCallBack,isAutoCheck,oneKeyConfirmHandler,oneKeyCancelHandler)
                                end
                            else
                                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("believer_troop_formation_no_fleet"),nil,self.layerNum+1)
                            end
                        else
                            loadHandler()
                        end
                    end
                end
                G_createBotton(itemBg,ccp(cellWidth/2+120,60),{getlocal("read"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",readHandler,btnScale,priority)
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
    local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition((self.bgSize.width-cellWidth)/2,15)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv,2)

    self:show()

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(0,0)
    return self.dialogLayer
end

--显示战斗等待页面
function believerSmallDialog:showWaitingBattleLayer(layerNum,callback,parent)
    local smdialog=believerSmallDialog:new()
    smdialog:initWaitingBattleDialog(layerNum,callback,parent)
    return smdialog
end

function believerSmallDialog:initWaitingBattleDialog(layerNum,callback,parent)
    spriteController:addPlist("public/serverWarLocal/swlocal_waiting.plist")
    spriteController:addTexture("public/serverWarLocal/swlocal_waiting.png")
    self.isTouch=nil
    self.isUseAmi=false
    self.layerNum=layerNum
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.parent=parent
    base:addNeedRefresh(self)

    local waitingLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function () end)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    waitingLayer:setTouchPriority(-(self.layerNum-1)*20-12)
    waitingLayer:setContentSize(rect)
    waitingLayer:setOpacity(255*0.8)
    waitingLayer:setPosition(getCenterPoint(self.dialogLayer))
    waitingLayer:setIsSallow(true)
    self.dialogLayer:addChild(waitingLayer,10)
    self.waitingLayer=waitingLayer

    local bgWidth,bgHeight=660,428
    local tankBodyPos=ccp(469.5,151.5)
    local paotouPos1,paotouPos2=ccp(406.5,299),ccp(442.5,267)
    local linePos=ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-500)
    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("swlocal_yellowline.png",CCRect(1,1,1,1),function () end)
    lineSp:setContentSize(CCSizeMake(640,3))
    lineSp:setPosition(linePos)
    self.waitingLayer:addChild(lineSp,15)
    local lineSp=CCSprite:createWithSpriteFrameName("swlocal_sqlitlight.png")
    lineSp:setPosition(linePos)
    self.waitingLayer:addChild(lineSp,16)

    -- 添加切割层
    local clipperSize=CCSizeMake(bgWidth,G_VisibleSizeHeight-lineSp:getPositionY())
    local clipper=CCClippingNode:create()
    clipper:setContentSize(clipperSize)
    clipper:setAnchorPoint(ccp(0.5,0))
    clipper:setPosition(lineSp:getPosition())
    local stencil=CCDrawNode:getAPolygon(clipperSize,1,1)
    clipper:setStencil(stencil)
    waitingLayer:addChild(clipper)

    local waitingBg=CCNode:create()
    waitingBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
    waitingBg:setAnchorPoint(ccp(0.5,0.5))
    waitingBg:setPosition(clipperSize.width/2,clipperSize.height/2-(clipperSize.height-bgHeight))
    clipper:addChild(waitingBg)
    local bgPos=ccp(waitingBg:getPosition())

    local waitingUpBg=CCSprite:createWithSpriteFrameName("swlocal_waitingup.png")
    waitingUpBg:setPosition(330,101.5)
    waitingBg:addChild(waitingUpBg,8)

    local url=G_downloadUrl("function/swlocal_waiting.png")
    local function onLoadIcon(fn,sprite)
        if self and self.waitingLayer and tolua.cast(self.waitingLayer,"LuaCCScale9Sprite")  and sprite then
            sprite:setAnchorPoint(ccp(0.5,0.5))
            sprite:setPosition(330,219.5)
            waitingBg:addChild(sprite,1)
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local webImage=LuaCCWebImage:createWithURL(url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local tankBodySp=CCSprite:createWithSpriteFrameName("swlocal_tankbody.png")
    tankBodySp:setPosition(tankBodyPos)
    waitingBg:addChild(tankBodySp,3)
    local bodyLightSp=CCSprite:createWithSpriteFrameName("swlocal_tankbodylight.png")
    bodyLightSp:setPosition(tankBodyPos)
    bodyLightSp:setOpacity(0)
    waitingBg:addChild(bodyLightSp,4)
    local tankPaotouSp=CCSprite:createWithSpriteFrameName("swlocal_paotou.png")
    tankPaotouSp:setPosition(paotouPos1)
    waitingBg:addChild(tankPaotouSp,2)
    local firekouSp=CCSprite:createWithSpriteFrameName("swlocal_firekou.png")
    firekouSp:setPosition(13,tankPaotouSp:getContentSize().height-15)
    firekouSp:setOpacity(0)
    tankPaotouSp:addChild(firekouSp)

    local paotouAcArr=CCArray:create()
    local moveTo1=CCMoveTo:create(0.2,paotouPos2)
    local function fire()
        local fire=CCParticleSystemQuad:create("scene/loadingEffect/fire.plist")
        if fire then
            fire:setAutoRemoveOnFinish(true)
            fire:setPositionType(kCCPositionTypeFree)
            local firePosX,firePosY=tankPaotouSp:getPosition()
            firePosX,firePosY=firePosX-100,firePosY+40
            fire:setPosition(firePosX,firePosY)
            fire:setRotation(-50 or 0)
            waitingBg:addChild(fire,2)
        end
        --坦克身体高亮动作
        local bodyAcArr=CCArray:create()
        local function light()
            bodyLightSp:setOpacity(255)
        end
        local function removeLight()
            bodyLightSp:setOpacity(0)
        end
        local lightFunc=CCCallFunc:create(light)
        local removeLightFunc=CCCallFunc:create(removeLight)
        local fadeOut=CCFadeOut:create(0.2)
        bodyAcArr:addObject(lightFunc)
        bodyAcArr:addObject(CCDelayTime:create(0.2))
        bodyAcArr:addObject(fadeOut)
        bodyAcArr:addObject(removeLightFunc)
        local lightAc=CCSequence:create(bodyAcArr)
        bodyLightSp:runAction(lightAc)

        --开炮炮口效果
        local function showFirekou()
            firekouSp:setOpacity(255)
        end
        local firekouFunc=CCCallFunc:create(showFirekou)
        local fadeIn=CCFadeOut:create(1.5)
        firekouSp:runAction(CCSequence:createWithTwoActions(firekouFunc,fadeIn))

        --开炮震动效果
        local shakeAcArr=CCArray:create()
        for i=1,5 do
          local rndx=15-(deviceHelper:getRandom()/100)*30
          local rndy=15-(deviceHelper:getRandom()/100)*30
          rndx,rndy=math.abs(rndx),-(math.abs(rndy))
          local moveTo1=CCMoveTo:create(0.02,ccp(rndx+bgPos.x,rndy+bgPos.y))
          local moveTo2=CCMoveTo:create(0.02,ccp(-rndx+bgPos.x,-rndy+bgPos.y))
          shakeAcArr:addObject(moveTo1)
          shakeAcArr:addObject(moveTo2)
        end
        local function resetPos()
           waitingBg:setPosition(bgPos)
        end
        local funcall=CCCallFunc:create(resetPos)
        shakeAcArr:addObject(funcall)
        local shakeSeq=CCSequence:create(shakeAcArr)
        waitingBg:runAction(shakeSeq)
    end
    local fireFunc=CCCallFunc:create(fire)
    local moveTo2=CCMoveTo:create(0.2,paotouPos1)
    paotouAcArr:addObject(moveTo1)
    paotouAcArr:addObject(fireFunc)
    paotouAcArr:addObject(moveTo2)
    paotouAcArr:addObject(CCDelayTime:create(2))
    local seq=CCSequence:create(paotouAcArr)
    local paotouAc=CCRepeatForever:create(seq)
    tankPaotouSp:runAction(paotouAc)

    local promptLb=GetTTFLabelWrap(getlocal("believer_prepare_inbattle"),30,CCSizeMake(600,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    promptLb:setPosition(linePos.x,linePos.y-100)
    promptLb:setColor(G_ColorYellowPro)
    waitingLayer:addChild(promptLb,10)

    local waitingTipIdx=math.random(1,4)
    local tipStr=getlocal("believer_battle_waittip"..waitingTipIdx)
    local tipStrLb=GetTTFLabelWrap(tipStr,25,CCSizeMake(600,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tipStrLb:setPosition(G_VisibleSizeWidth/2,180)
    waitingLayer:addChild(tipStrLb,10)

    local loadingBg=CCSprite:create("public/tankLoadingBg.png")
    loadingBg:setPosition(ccp(G_VisibleSizeWidth/2,250))
    self.waitingLayer:addChild(loadingBg,2)

    self.timeProgressTimer=CCProgressTimer:create(CCSprite:create("public/tankLoadingBar.png"))
    self.timeProgressTimer:setType(kCCProgressTimerTypeBar)
    self.timeProgressTimer:setMidpoint(ccp(0,0))
    self.timeProgressTimer:setBarChangeRate(ccp(1,0))
    self.timeProgressTimer:setPosition(ccp(G_VisibleSizeWidth/2,250))
    self.waitingLayer:addChild(self.timeProgressTimer,3)

    self.smallTankSp=CCSprite:create("public/tankShape.png")
    self.smallTankSp:setAnchorPoint(ccp(0.5,0.5))
    self.smallTankSp:setPosition(G_VisibleSizeWidth/2-self.timeProgressTimer:getContentSize().width/2+30,self.timeProgressTimer:getPositionY())
    self.waitingLayer:addChild(self.smallTankSp,3)

    self.waitingTime,self.maxTime=0,5
    local function closeHandler(event,data)
        local function close()
            self:close()
            if callback then
                callback(data)
            end
            if self.parent and self.parent.backToMainDialogHandler then
                self.parent:backToMainDialogHandler()
                self.parent=nil
            end
        end
        if self.waitingTime<3 then
            local function finish()
                self.waitingTime=self.maxTime
                self:setWaitingPercent()
            end
            local acArr=CCArray:create()
            acArr:addObject(CCDelayTime:create(3-self.waitingTime))
            acArr:addObject(CCCallFunc:create(finish))
            acArr:addObject(CCDelayTime:create(0.3))
            acArr:addObject(CCCallFunc:create(close))
            local seq=CCSequence:create(acArr)
            self.waitingLayer:runAction(seq)
        else
            self.waitingTime=self.maxTime
            self:setWaitingPercent()
            local delayAc=CCDelayTime:create(0.3)
            self.waitingLayer:runAction(CCSequence:createWithTwoActions(delayAc,CCCallFunc:create(close)))
        end
    end
    self.closeListener=closeHandler
    eventDispatcher:addEventListener("believer.battle.prepared",closeHandler)

    local function errorCloseHandler()
        self:close()
        if self.parent and self.parent.backToMainDialogHandler then
            self.parent:backToMainDialogHandler()
            self.parent=nil
        end
    end
    self.errorListener=errorCloseHandler
    eventDispatcher:addEventListener("believer.battle.error",errorCloseHandler)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function believerSmallDialog:setWaitingPercent()
    if self.waitingLayer and self.waitingTime and self.smallTankSp and self.timeProgressTimer then
        local percent=(self.waitingTime/self.maxTime)*100
        local tankX=G_VisibleSizeWidth/2-self.timeProgressTimer:getContentSize().width/2+30
        local tankDis=percent
        if (tankDis>=95) then
            tankDis=95
        end
        tankX=tankX+(tankDis/100)*self.timeProgressTimer:getContentSize().width
        self.smallTankSp:setPositionX(tankX)
        self.timeProgressTimer:setPercentage(percent)
    end
end

function believerSmallDialog:tick()
    if self.waitingLayer and self.waitingTime and self.smallTankSp and self.timeProgressTimer then
        if self.waitingTime<5 then
            self.waitingTime=self.waitingTime+1
        end
        self:setWaitingPercent()
    end
end

function believerSmallDialog:dispose()
    if self.waitingLayer then
        spriteController:removePlist("public/serverWarLocal/swlocal_waiting.plist")
        spriteController:removeTexture("public/serverWarLocal/swlocal_waiting.png")
        self.waitingLayer:removeFromParentAndCleanup(true)
        self.waitingLayer=nil
        if self.closeListener then
            eventDispatcher:removeEventListener("believer.battle.prepared",self.closeListener)
            self.closeListener=nil
        end
        if self.errorListener then
            eventDispatcher:removeEventListener("believer.battle.error",self.errorListener)
            self.errorListener=nil
        end
        base:removeFromNeedRefresh(self)
    end
end

return believerSmallDialog