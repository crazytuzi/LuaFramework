function smallDialog:showAllianceRewardsDialog(bgSrc,size,fullRect,inRect,data,callback,istouch,isuseami,layerNum)
	local sd=smallDialog:new()
  	sd:initAllianceRewardsDialog(bgSrc,size,fullRect,inRect,data,callback,istouch,isuseami,layerNum)
end

function smallDialog:initAllianceRewardsDialog(bgSrc,size,fullRect,inRect,data,callback,istouch,isuseami,layerNum)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    local function nilFun()
    end
    if baseAdd==nil then
        baseAdd=0
    end
    local dialogBg = G_getNewDialogBg2(size,layerNum,nil,getlocal("activity_chunjiepansheng_getReward"),25)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    -- local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png");
    -- spriteTitle:setAnchorPoint(ccp(x`0.5,0.5));
    -- spriteTitle:setPosition(ccp(self.bgSize.width/2,self.bgSize.height+20))
    -- self.bgLayer:addChild(spriteTitle,2)
    -- local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
    -- spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
    -- spriteTitle1:setPosition(ccp(self.bgSize.width/2,self.bgSize.height+20))
    -- self.bgLayer:addChild(spriteTitle1,2)
    -- local spriteShapeAperture = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
    -- spriteShapeAperture:setAnchorPoint(ccp(0.5,0.5));
    -- spriteShapeAperture:setPosition(ccp(self.bgSize.width/2,self.bgSize.height+20))
    -- self.bgLayer:addChild(spriteShapeAperture,1)

    if data==nil then
        do return end
    end

    -- -- local titleLb=GetTTFLabel(getlocal("activity_chunjiepansheng_getReward"),30)
    -- local titleLb=GetTTFLabelWrap(getlocal("activity_chunjiepansheng_getReward"),30,CCSize(size.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    -- titleLb:setAnchorPoint(ccp(0.5,1))
    -- titleLb:setColor(G_ColorYellowPro)
    -- titleLb:setPosition(ccp(size.width/2,size.height-40))
    -- self.bgLayer:addChild(titleLb,3)
    -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    -- lineSp:setAnchorPoint(ccp(0.5,1))
    -- lineSp:setScaleX(size.width/lineSp:getContentSize().width)
    -- lineSp:setPosition(ccp(size.width/2,titleLb:getPositionY()-titleLb:getContentSize().height/2-20))
    -- self.bgLayer:addChild(lineSp)

    local posX=20
    local wordSpace=10
    local textW=size.width-posX
    local textSize=25
    -- local customCountLb=GetTTFLabel(getlocal("alliance_custom_reward").."："..data.customNum,25)
    local customCountLb=GetTTFLabelWrap(getlocal("alliance_custom_reward").."："..data.customNum,textSize,CCSize(textW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    customCountLb:setAnchorPoint(ccp(0.5,1))
    customCountLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,size.height-30-10))
    self.bgLayer:addChild(customCountLb)


    -- local bCountLb=GetTTFLabel(getlocal("alliance_boss_rewardbox").."："..data.bcount,textSize)
    local bCountLb=GetTTFLabelWrap(getlocal("alliance_boss_rewardbox").."："..data.bossCount,textSize,CCSize(textW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    bCountLb:setAnchorPoint(ccp(0.5,1))
    bCountLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,customCountLb:getPositionY()-customCountLb:getContentSize().height-wordSpace))
    self.bgLayer:addChild(bCountLb)
    if data.bossCount <= 0 then
        bCountLb:setVisible(false)
    end

    -- local donateCountLb=GetTTFLabel(getlocal("my_alliance_donate").."："..data.curDonate,textSize)
    local donateCountLb=GetTTFLabelWrap(getlocal("my_alliance_donate").."："..data.curDonate.." - "..data.costDonate,textSize,CCSize(textW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    donateCountLb:setAnchorPoint(ccp(0.5,1))
    donateCountLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,bCountLb:getPositionY()-bCountLb:getContentSize().height-wordSpace))
    self.bgLayer:addChild(donateCountLb)
    if data.costDonate <= 0 then
        donateCountLb:setVisible(false)
    end
    -- local costDonateLb=GetTTFLabel(" - "..data.costDonate,textSize)
    -- costDonateLb:setAnchorPoint(ccp(0,1))
    -- costDonateLb:setPosition(ccp(donateCountLb:getPositionX()+donateCountLb:getContentSize().width,donateCountLb:getPositionY()))
    -- costDonateLb:setColor(G_ColorRed)
    -- self.bgLayer:addChild(costDonateLb)

    -- -- local rewardLb=GetTTFLabel(getlocal("alliance_rewardlist_pro").."：",textSize)
    -- local rewardLb=GetTTFLabelWrap(getlocal("alliance_rewardlist_pro").."：",textSize,CCSize(textW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- rewardLb:setAnchorPoint(ccp(0,1))
    -- rewardLb:setPosition(ccp(posX,donateCountLb:getPositionY()-donateCountLb:getContentSize().height-wordSpace))
    -- self.bgLayer:addChild(rewardLb)

    local titleBg = G_createNewTitle({getlocal("alliance_rewardlist_pro"), textSize,G_ColorYellowPro2}, CCSizeMake(300, 0), nil, nil, "Helvetica-bold")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(self.bgLayer:getContentSize().width / 2, donateCountLb:getPositionY()-donateCountLb:getContentSize().height-wordSpace-20)
    self.bgLayer:addChild(titleBg,2)

    local cellWidth=self.bgLayer:getContentSize().width-60
    local cellHeight=140
    local tvHeight=220
    local capInSet=CCRect(20, 20, 10, 10)
    local rewardMainSP=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFun)
    rewardMainSP:setContentSize(CCSizeMake(cellWidth+20,tvHeight+20+120))
    rewardMainSP:setAnchorPoint(ccp(0.5,1))
    rewardMainSP:setPosition(size.width/2,titleBg:getPositionY()+15)
    self.bgLayer:addChild(rewardMainSP)

    local rewardCount=SizeOfTable(data.rewardTab)
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return rewardCount
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local rewardItem=data.rewardTab[idx+1]
            if rewardItem and rewardItem.name and rewardItem.num then
                local icon,scale=G_getItemIcon(rewardItem,100,true,layerNum)
                if icon then
                    icon:setAnchorPoint(ccp(0,0.5))
                    icon:setPosition(cellWidth/2-70,cellHeight/2)
                    icon:setIsSallow(false)
                    cell:addChild(icon,1)
                    
                    local iconWidth=icon:getContentSize().width*icon:getScaleX()
                    local iconHeight=icon:getContentSize().height*icon:getScaleY()
                    local nameLable = GetTTFLabelWrap(rewardItem.name,textSize,CCSize(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    nameLable:setAnchorPoint(ccp(0,0))
                    nameLable:setColor(G_ColorYellowPro2)
                    nameLable:setPosition(ccp(icon:getPositionX()+iconWidth+10,icon:getPositionY()+10))
                    cell:addChild(nameLable,1)

                    local numLable = GetTTFLabel("x "..rewardItem.num,textSize)
                    numLable:setAnchorPoint(ccp(0,1))
                    numLable:setPosition(ccp(icon:getPositionX()+iconWidth+10,icon:getPositionY()-10))
                    cell:addChild(numLable,1)
                end
            end
            return cell
        elseif fn=="ccTouchBegan" then
            return true
        elseif fn=="ccTouchMoved" then

        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight+85),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.tv:setPosition(ccp(0,10))
    rewardMainSP:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    -- if tonumber(data.remainbcount)>0 then
    --     local tipLb = GetTTFLabelWrap(getlocal("alliance_bossreward_remain",{data.remainbcount}),textSize,CCSize(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    --     tipLb:setAnchorPoint(ccp(0.5,1))
    --     tipLb:setColor(G_ColorRed)
    --     tipLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,rewardMainSP:getPositionY()-rewardMainSP:getContentSize().height-10))
    --     self.bgLayer:addChild(tipLb)
    -- end
    local function confirmHandler()
        self:close()
    end
    local sureBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",confirmHandler,1,getlocal("ok"),textSize,11)
    sureBtn:setScale(0.8)
    local sureMenu=CCMenu:createWithItem(sureBtn)
    sureMenu:setPosition(ccp(size.width/2,80))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3)
    self.bgLayer:addChild(sureMenu)

    self:show()
    local function touchDialog()
        if self.isTouch~=nil and self.isTouch==true then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
      
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer
end

function smallDialog:showAllianceFubenGetBoxTipsDialog(data, layerNum, sureCallback)
    local sd = smallDialog:new()
    sd:initAllianceFubenGetBoxTipsDialog(data,sureCallback,false,false,layerNum)
end

function smallDialog:initAllianceFubenGetBoxTipsDialog(data,sureCallback,istouch,isuseami,layerNum)
    self.isTouch = istouch
    self.isUseAmi = isuseami

    self.dialogLayer=CCLayerColor:create(ccc4(0,0,0,255*0.7))
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local bgSize = CCSizeMake(560, 380)
    self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),function()end)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0.5))
    lightSp:setScaleX(3)
    lightSp:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-50)
    self.bgLayer:addChild(lightSp)

    local nameLb=GetTTFLabelWrap(getlocal("dialog_title_prompt"),30,CCSizeMake(320,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    nameLb:setAnchorPoint(ccp(0.5,0.5))
    nameLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(bgSize.width/2,bgSize.height-40)
    self.bgLayer:addChild(nameLb)

    local nameLb2=GetTTFLabel(getlocal("dialog_title_prompt"),30)
    local realNameW=nameLb2:getContentSize().width
    if realNameW>nameLb:getContentSize().width then
        realNameW=nameLb:getContentSize().width
    end
    for i=1,2 do
        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
        local anchorX=1
        local posX=bgSize.width/2-(realNameW/2+20)
        local pointX=-7
        if i==2 then
            anchorX=0
            posX=bgSize.width/2+(realNameW/2+20)
            pointX=15
        end
        pointSp:setAnchorPoint(ccp(anchorX,0.5))
        pointSp:setPosition(posX,nameLb:getPositionY())
        self.bgLayer:addChild(pointSp)

        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0,0.5))
        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
        pointSp:addChild(pointLineSp)
        if i==1 then
            pointLineSp:setRotation(180)
        end
    end

    local function createCheckBox(touchPriority,callback)
        local function operateHandler(...)
            if callback then
                callback(...)
            end
        end
        local menu=CCMenu:create()
        local switchSp1 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
        local switchSp2 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
        local menuItemSp1 = CCMenuItemSprite:create(switchSp1,switchSp2)
        local switchSp3 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
        local switchSp4 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
        local menuItemSp2 = CCMenuItemSprite:create(switchSp3,switchSp4)
        local checkBox = CCMenuItemToggle:create(menuItemSp1)
        checkBox:addSubItem(menuItemSp2)
        checkBox:setAnchorPoint(CCPointMake(0.5,0.5))
        checkBox:registerScriptTapHandler(operateHandler)
        menu:addChild(checkBox)
        menu:setTouchPriority(touchPriority)
        return checkBox,menu
    end

    local params1, params2, params3 = data[1] or 0, data[2] or 0, data[3] or 0
    local tipsLbFontSize = 22
    if G_getCurChoseLanguage() == "en" then
        tipsLbFontSize = 20
    end
    local label1 = GetTTFLabelWrap(getlocal("alliance_fubenGetTips1",{params1}),tipsLbFontSize,CCSizeMake(bgSize.width-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local label2 = GetTTFLabelWrap(getlocal("alliance_fubenGetTips2",{params2,params3}),tipsLbFontSize,CCSizeMake(bgSize.width-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    label1:setAnchorPoint(ccp(0, 0.5))
    label2:setAnchorPoint(ccp(0, 0.5))
    label1:setPosition(30+50, bgSize.height - 110 - label1:getContentSize().height / 2)
    label2:setPosition(30+50, label1:getPositionY() - label1:getContentSize().height / 2 - 65 - label2:getContentSize().height / 2)
    self.bgLayer:addChild(label1)
    self.bgLayer:addChild(label2)

    local checkBoxTb = {}
    local function onClickCheckBox(tag, obj)
        for k,v in pairs(checkBoxTb) do
            if obj~=v then
                v:setSelectedIndex(0)
            elseif obj:getSelectedIndex() == 0 then
                obj:setSelectedIndex(1)
            end
        end
    end
    local checkBox1, menu1 = createCheckBox(-(layerNum-1)*20-3,onClickCheckBox)
    menu1:setPosition(label1:getPositionX() - checkBox1:getContentSize().width / 2, label1:getPositionY())
    self.bgLayer:addChild(menu1)
    table.insert(checkBoxTb,checkBox1)
    local checkBox2, menu2 = createCheckBox(-(layerNum-1)*20-3,onClickCheckBox)
    menu2:setPosition(label2:getPositionX() - checkBox2:getContentSize().width / 2, label2:getPositionY())
    self.bgLayer:addChild(menu2)
    table.insert(checkBoxTb,checkBox2)

    if params1 <= 0 then
        checkBox1:setEnabled(false)
    else
        checkBox1:setSelectedIndex(1)
    end
    if params3 == 0 then
        checkBox1:setSelectedIndex(1)
        checkBox2:setEnabled(false)
        checkBox2:setVisible(false)
        label2:setVisible(false)
    else
        if params2 <= 0 then
            checkBox2:setEnabled(false)
        elseif checkBox1:getSelectedIndex() == 0 then
            checkBox2:setSelectedIndex(1)
        end
    end

    local function onClickHandler(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
            local param
            if checkBox1:getSelectedIndex() == 1 then
                param = 1
            elseif checkBox2:getSelectedIndex() == 1 then
                param = 2
            end
            if param then
                if sureCallback then
                    sureCallback(param, function() self:close() end)
                end
            end
        elseif tag == 11 then
            self:close()
        end
    end
    local btnScale = 0.8
    sureBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("confirm"), 24 / btnScale)
    cancelBtn = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", onClickHandler, 11, getlocal("cancel"), 24 / btnScale)
    sureBtn:setScale(btnScale)
    cancelBtn:setScale(btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(sureBtn)
    menuArr:addObject(cancelBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority(-(layerNum - 1) * 20 - 3)
    btnMenu:setPosition(0, 0)
    self.bgLayer:addChild(btnMenu)
    sureBtn:setPosition(bgSize.width / 2 - sureBtn:getContentSize().width * sureBtn:getScale() / 2 - 50, 35 + sureBtn:getContentSize().height * sureBtn:getScale() / 2)
    cancelBtn:setPosition(bgSize.width / 2 + cancelBtn:getContentSize().width * cancelBtn:getScale() / 2 + 50, 35 + cancelBtn:getContentSize().height * cancelBtn:getScale() / 2)

    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer
end