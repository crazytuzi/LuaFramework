selectRewardSmallDialog=smallDialog:new()

function selectRewardSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function selectRewardSmallDialog:showSelectRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,reward,desStr,pCallback,titleStr,pid,isMulti)
	local sd=selectRewardSmallDialog:new()
    sd:initSelectRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,reward,desStr,pCallback,titleStr,pid,isMulti)
end


function selectRewardSmallDialog:initSelectRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,reward,desStr,pCallback,titleStr,pid,isMulti)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    local strSize2 = 25
    local titleNeedWidth = 0
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 =30
    elseif G_getCurChoseLanguage() =="ru" then
        titleNeedWidth =20
    end
    local rewardNum=SizeOfTable(reward)
    local cellNum=math.ceil(rewardNum/2)
    self.reward=reward
    self.cellHeight=100
    self.tvHeight=cellNum*self.cellHeight
    self.selectSpTb={}
    local dialogBgWidth,dialogBgHeight =560, 80 + 100
    local tvVisibleH=self.cellHeight*3+self.cellHeight/2
    if cellNum<=3 then
        tvVisibleH=self.cellHeight*cellNum
    end
    dialogBgHeight=dialogBgHeight+tvVisibleH
    if isMulti == true then --如果是批量使用的话，面板高度增加
        dialogBgHeight=dialogBgHeight+80
    end
    local desLb=GetTTFLabelWrap(desStr,25,CCSizeMake(dialogBgWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    dialogBgHeight=dialogBgHeight+desLb:getContentSize().height+20


    self.bgSize=CCSizeMake(dialogBgWidth,dialogBgHeight)

    local function tmpFunc()
    end
    local function close()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),tmpFunc);
    -- touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect1)
    touchDialogBg:setOpacity(0.8*255)
    touchDialogBg:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:addChild(touchDialogBg);

    local dialogBg = G_getNewDialogBg(self.bgSize,titleStr,strSize2,nil,self.layerNum,true,close) --LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.bgLayer=dialogBg
    dialogBg:setContentSize(self.bgSize)
    dialogBg:setIsSallow(false)
    self.dialogLayer:addChild(dialogBg,1)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)


    self:show()

    local contenH=dialogBgHeight-75
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(20,contenH-desLb:getContentSize().height/2)
    dialogBg:addChild(desLb)
    
    contenH=contenH-desLb:getContentSize().height-10

    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
    lineSp:setContentSize(CCSizeMake(self.bgSize.width-30,lineSp:getContentSize().height))
    lineSp:setPosition(size.width/2,contenH)
    dialogBg:addChild(lineSp,0.5)

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(size.width-30,tvVisibleH),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,contenH-tvVisibleH-10))
    dialogBg:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

    self.refreshData.tableView=self.tv
    self:addForbidSp(dialogBg,CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),layerNum,true)

    local lineSp2=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
    dialogBg:addChild(lineSp2,1)
    lineSp2:setContentSize(CCSizeMake(self.bgSize.width-30,lineSp2:getContentSize().height))
    lineSp2:setPosition(size.width/2,contenH-tvVisibleH-20)

    contenH = contenH-tvVisibleH-20

    if isMulti == true then
        local numFontSize = 24
        local id = tonumber(pid) or tonumber(RemoveFirstChar(pid))
        -- print("pid===>",pid)
        local maxNum=bagVoApi:getItemNumId(id)
        local numTip=GetTTFLabel(getlocal("amountStr").."：",numFontSize)
        numTip:setAnchorPoint(ccp(0,0.5))
        self.bgLayer:addChild(numTip)
        local numLb=GetTTFLabel("",numFontSize)
        numLb:setAnchorPoint(ccp(0,0.5))
        numLb:setColor(G_ColorGreen)
        self.bgLayer:addChild(numLb)

        local function refreshNumLb()
            if self.slider then
                numLb:setString(math.ceil(self.slider:getValue()).."/"..maxNum)
                numTip:setPosition((self.bgSize.width-numTip:getContentSize().width-numLb:getContentSize().width)/2,lineSp2:getPositionY()-numTip:getContentSize().height/2-10)
                numLb:setPosition(numTip:getPositionX()+numTip:getContentSize().width,numTip:getPositionY())
            end
        end
        
        local function sliderTouch(handler,object)
            local count=math.ceil(object:getValue())
            if count>0 then
                refreshNumLb()
            end
        end
        local spBg=CCSprite:createWithSpriteFrameName("proBar_n2.png")
        local spPr=CCSprite:createWithSpriteFrameName("proBar_n1.png")
        local spPr1=CCSprite:createWithSpriteFrameName("grayBarBtn.png")
        local slider=LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch)
        slider:setTouchPriority(-(self.layerNum-1)*20-4)
        slider:setIsSallow(true)
        slider:setMinimumValue(1)
        slider:setMaximumValue(maxNum)
        slider:setValue(1)
        slider:setTag(99)
        self.bgLayer:addChild(slider,2)
        self.slider=slider
        refreshNumLb()
        slider:setPosition(ccp(self.bgSize.width/2,numTip:getPositionY()-numTip:getContentSize().height/2-16-10))

        local function touchHander()
        end
        local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("buyBarBg.png",CCRect(10,10,10,10),touchHander)
        bgSp:setContentSize(CCSizeMake(490,45))
        bgSp:setOpacity(0)
        bgSp:setPosition(self.bgSize.width/2,slider:getPositionY())
        self.bgLayer:addChild(bgSp,1)
        
        local function touchAdd()
            self.slider:setValue(self.slider:getValue()+1)
        end
        
        local function touchMinus()
            if self.slider:getValue()-1>0 then
                self.slider:setValue(self.slider:getValue()-1)
            end
        end

        local addSp=CCSprite:createWithSpriteFrameName("greenPlus.png")
        addSp:setAnchorPoint(ccp(1,0.5))
        addSp:setPosition(ccp(bgSp:getContentSize().width-10,bgSp:getContentSize().height/2))
        bgSp:addChild(addSp,1)

        local rect=CCSizeMake(50,45)
        local addTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchAdd)
        addTouchBg:setTouchPriority(-(self.layerNum-1)*20-5)
        addTouchBg:setContentSize(rect)
        addTouchBg:setAnchorPoint(ccp(1,0.5))
        addTouchBg:setOpacity(0)
        addTouchBg:setPosition(ccp(bgSp:getContentSize().width,bgSp:getContentSize().height/2))
        bgSp:addChild(addTouchBg,1)
       
        local minusSp=CCSprite:createWithSpriteFrameName("greenMinus.png")
        minusSp:setAnchorPoint(ccp(0,0.5))
        minusSp:setPosition(ccp(10,bgSp:getContentSize().height/2))
        bgSp:addChild(minusSp,1)

        local minusTouchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchMinus)
        minusTouchBg:setTouchPriority(-(self.layerNum-1)*20-5)
        minusTouchBg:setContentSize(rect)
        minusTouchBg:setAnchorPoint(ccp(0,0.5))
        minusTouchBg:setOpacity(0)
        minusTouchBg:setPosition(ccp(0,bgSp:getContentSize().height/2))
        bgSp:addChild(minusTouchBg,1)
    end

    local function clickSure()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        if pCallback then
            local count=1
            if isMulti == true then
                if self.slider then
                    count = math.ceil(self.slider:getValue())
                end
            end
            local isOver,leftNum = false,0
            local selectedReward = self.reward[self.selectId]
            if selectedReward then
                -- print("selectedReward--->",selectedReward.type,selectedReward.eType,selectedReward.key,selectedReward.name)
                local function realCallBack()
                    -- print("isOver,leftNum====>",isOver,leftNum)
                    if isOver==true then
                        if selectedReward.type=="e" and selectedReward.eType=="f" then
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("backstage9050"), 28)
                        else
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("armorMatrix_addBag_overTip",{leftNum}), 28)
                        end
                        do return end
                    end
                    pCallback(self.selectId,count)
                    self:close()
                end
                if selectedReward.type=="am" and selectedReward.eType=="m" then --获取的是装甲矩阵，则需要判断仓库是否已满
                    local function overHandler()
                        isOver,leftNum = armorMatrixVoApi:bagIsOver(count) 
                        realCallBack()
                    end
                    if armorMatrixVoApi.armorRequestFlag~=true then --说明没有获取矩阵的数据，则需要拉一下数据
                        local function callBack()
                            overHandler()
                        end
                        armorMatrixVoApi:armorGetData(callBack)
                    else
                        overHandler()
                    end
                elseif selectedReward.type=="e" and (selectedReward.eType=="f" or selectedReward.eType=="a") then --获取的是配件或配件碎片，则需要判断仓库是否已满
                    local function overHandler()
                        if selectedReward.eType=="f" then
                            isOver,leftNum=accessoryVoApi:isFbagFull(1,selectedReward.key)
                        elseif selectedReward.eType=="a" then
                            isOver,leftNum=accessoryVoApi:isAbagFull(count,selectedReward.key)
                        end
                        realCallBack()
                    end
                    if base.ifAccessoryOpen==1  then
                        if accessoryVoApi.dataNeedRefresh==true then
                            local function onRequestEnd(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    if sData and sData.data and sData.data.accessory then
                                        accessoryVoApi:onRefreshData(sData.data.accessory)
                                        overHandler()
                                    end
                                end
                            end
                            socketHelper:getAllAccesory(onRequestEnd)
                        else
                            overHandler()
                        end
                    end
                else
                    realCallBack()
                end
            end
        end
    end
    local btnScale = 0.7
    local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",clickSure,nil,getlocal("ok"),25/btnScale)
    okItem:setScale(btnScale)
    local okBtn=CCMenu:createWithItem(okItem);
    okBtn:setTouchPriority(-(layerNum-1)*20-4);
    okBtn:setPosition(ccp(size.width/2,50))
    dialogBg:addChild(okBtn)


    sceneGame:addChild(self.dialogLayer,layerNum)
    base:removeFromNeedRefresh(self) --停止刷新
end

function selectRewardSmallDialog:eventHandler(handler,fn,idx,cel)
    local strSize2 = 15
    local strSize3 = 15
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 =20
        strSize3 =20
    elseif G_getCurChoseLanguage() =="ru" then
        strSize2 =15
        strSize3 =13
    end
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgSize.width-30,self.tvHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local startH=self.tvHeight
        local startW=50
        local addW=250


        
        local function selectFunc(hd,fn,tag)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                -- 处理
                if self.selectId==tag-300 then
                    return 
                end
                self.selectId=tag-300
                for k,v in pairs(self.selectSpTb) do
                    if k==self.selectId then
                        v[1]:setVisible(false)
                        v[2]:setVisible(true)
                    else
                        v[1]:setVisible(true)
                        v[2]:setVisible(false)
                    end
                end
            end
        end

        local iconWidth = 80
        for k,v in pairs(self.reward) do
            local index=k%2
            if index==0 then
                index=2
            end
           
           local posX=startW+(index-1)*addW
           local posY=startH-50

           local function seletIcon(hd,fn,tag)
                local addDesc
                local isAccOrFrag
                if v.type=="e" and v.eType and v.eType=="f" then
                    isAccOrFrag=true
                    local output=accessoryCfg.fragmentCfg[v.key].output
                    if output and output~="" then
                        local tankID=accessoryCfg.aCfg[output].tankID
                        local tankStr
                        if(tankID==1)then
                            tankStr=getlocal("tanke")
                        elseif(tankID==2)then
                            tankStr=getlocal("jianjiche")
                        elseif(tankID==3)then
                            tankStr=getlocal("zixinghuopao")
                        elseif(tankID==4)then
                            tankStr=getlocal("huojianche")
                        end
                        if tankStr then
                            addDesc=getlocal("accessory_fragment_fit_part",{tankStr})
                        end
                    end
                end
                if(v.type=="am" and v.key~="exp")then
                    v.noLocal=1
                end
                propInfoDialog:create(sceneGame,v,self.layerNum+1,nil,nil,addDesc,nil,nil,isAccOrFrag,nil)
            end
            local icon,scale=G_getItemIcon(v,100,false,self.layerNum+1,seletIcon,self.tv)
            scale=iconWidth/icon:getContentSize().width
            icon:setScale(scale)
            cell:addChild(icon)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            icon:setPosition(posX,posY)
            icon:setTag(200+k)

            local nameH=posY+25
            local nameLb=GetTTFLabelWrap(v.name,strSize2,CCSizeMake(160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
            nameLb:setAnchorPoint(ccp(0,0.5))
            nameLb:setColor(G_ColorYellowPro)
            cell:addChild(nameLb)
            nameLb:setPosition(posX+50,nameH)

            local state = self:isCanSelect(v)
            if state == 0 then --可以选择
                local numH=posY-25
                local numLb=GetTTFLabel(getlocal("propInfoNum",{v.num}),strSize3)
                numLb:setAnchorPoint(ccp(0,0.5))
                numLb:setPosition(posX+50,numH)
                cell:addChild(numLb)

                local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),selectFunc)
                backSprie:setContentSize(CCSizeMake(150, self.cellHeight-20))
                backSprie:setAnchorPoint(ccp(0,0.5))
                backSprie:setTag(k+300)
                backSprie:setPosition(posX+50,posY)
                backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(backSprie,1)
                backSprie:setVisible(false)

                -- LegionCheckBtnUn
                local selectSp1=CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
                cell:addChild(selectSp1)
                -- selectSp1:setTouchPriority(-(self.layerNum-1)*20-2)
                selectSp1:setAnchorPoint(ccp(0,0.5))
                selectSp1:setPosition(posX+50+90,numH)
                selectSp1:setScale(0.7)
                -- selectSp1:setTag(k+300)
                local selectSp2=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
                cell:addChild(selectSp2)
                selectSp2:setAnchorPoint(ccp(0,0.5))
                selectSp2:setPosition(posX+50+90,numH)
                -- selectSp1:setVisible(false)
                selectSp2:setVisible(false)
                selectSp2:setScale(0.7)
                self.selectSpTb[k]={}
                self.selectSpTb[k][1]=selectSp1
                self.selectSpTb[k][2]=selectSp2
                if self.selectId == nil then
                    self.selectId = k
                    selectSp2:setVisible(true)
                end
            else
                local unselectTipLb = GetTTFLabelWrap(getlocal("propunselect_tip"..state), strSize2, CCSizeMake(160, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
                unselectTipLb:setAnchorPoint(ccp(0, 0))
                unselectTipLb:setColor(G_ColorRed)
                cell:addChild(unselectTipLb)
                local th = nameLb:getContentSize().height + unselectTipLb:getContentSize().height
                if th > iconWidth then
                    unselectTipLb:setPosition(nameLb:getPositionX(), startH - self.cellHeight)
                else
                    unselectTipLb:setPosition(nameLb:getPositionX(),posY - iconWidth/2)
                end
            end

            if k%2==0 then
                startH=startH-self.cellHeight
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

function selectRewardSmallDialog:isCanSelect(item)
    local state = 0
    if item.type=="p" and propCfg[item.key] then
        local dis = propCfg[item.key].tskinDiscount
        if dis then
            state = tankSkinVoApi:isSkinOwned(dis[1]) == true and 1 or state
            if state == 0 then
                local num = bagVoApi:getItemNumId(item.id)
                state = num > 0 and 2 or state
            end
        end
    end
    return state
end

function selectRewardSmallDialog:dispose()
    self.tv=nil
    self.reward=nil
    self.tvHeight=nil
    self.selectSpTb=nil
end

