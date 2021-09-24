acArmorEliteDialog = commonDialog:new()

function acArmorEliteDialog:new()
	local nc = {}
	setmetatable(nc,self)
	self.__index = self
	nc.isToday=nil
	nc.canClick=true
	local function addPlist()
		spriteController:addPlist("public/armorMatrix.plist")
	    spriteController:addTexture("public/armorMatrix.png")
	    spriteController:addPlist("public/armorEliteImage.plist")
	    spriteController:addTexture("public/armorEliteImage.png")
	end
	G_addResource8888(addPlist)
	
	return nc
end

function acArmorEliteDialog:dispose()
	spriteController:removePlist("public/armorMatrix.plist")
    spriteController:removeTexture("public/armorMatrix.png")
    spriteController:removePlist("public/armorEliteImage.plist")
    spriteController:removeTexture("public/armorEliteImage.png")
end

function acArmorEliteDialog:doUserHandler()
	self.panelLineBg:setVisible(false)
	self.isToday=acArmorEliteVoApi:isToday()



    local function touchDialog()
        if self.state == 2 then
            PlayEffect(audioCfg.mouseClick)
            self.state=3 
        end
    end
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect)
    self.touchDialogBg:setOpacity(0)
    self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
    self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.touchDialogBg,1)

    local function onLoadIcon(fn,icon)
        if self and self.bgLayer and icon then
            self.bgLayer:addChild(icon)
            icon:setScaleX(self.bgLayer:getContentSize().width/icon:getContentSize().width)
            icon:setScaleY((self.bgLayer:getContentSize().height-80)/icon:getContentSize().height)
            icon:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-40)
            icon:setColor(G_ColorGray)
        end
    end
    local url=G_downloadUrl("function/armorBg.jpg")
    local webImage = LuaCCWebImage:createWithURL(url,onLoadIcon)

    local h = G_VisibleSizeHeight-150
	local acLabel = GetTTFLabel(getlocal("activityCountdown"),25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp(G_VisibleSizeWidth/2, h))
	self.bgLayer:addChild(acLabel,2)
	acLabel:setColor(G_ColorYellowPro)

	h = h-30
	local timeStr=acArmorEliteVoApi:getTimer()
	local messageLabel=GetTTFLabel(timeStr,25)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setColor(G_ColorYellowPro)
	messageLabel:setPosition(ccp(G_VisibleSizeWidth/2, h))
	self.bgLayer:addChild(messageLabel,2)
	self.timeLb=messageLabel


	local startH=G_VisibleSizeHeight-100

    self.checkIndex=1 -- 默认选中普通

	self:initHeader()

    self:initBottom()
end

function acArmorEliteDialog:initHeader()
    local posY=G_VisibleSizeHeight-80

    local topBg=CCSprite:createWithSpriteFrameName("armor_arm_bg.png")
    topBg:setAnchorPoint(ccp(0.5,1))
    topBg:setPosition(G_VisibleSizeWidth/2,posY)
    self.bgLayer:addChild(topBg,1)


    local posTb={ccp(65,posY),ccp(G_VisibleSizeWidth-65,posY)}
    self.downSpTb={}

    for k,v in pairs(posTb) do
        local upSp=CCSprite:createWithSpriteFrameName("armor_arm_up.png")
        self.bgLayer:addChild(upSp,2)
        upSp:setAnchorPoint(CCPointMake(0.5,1))
        upSp:setPosition(v)
        local upSize=upSp:getContentSize()

        
        local downSp=CCSprite:createWithSpriteFrameName("armor_arm_down.png")
        upSp:addChild(downSp,1)
        local downSize=downSp:getContentSize()
        -- downSp:setAnchorPoint(CCPointMake(11/downSize.width,123/downSize.height))
         -- 11, 123 
        if k==1 then
            downSp:setAnchorPoint(CCPointMake((downSize.width-11)/downSize.width,(downSize.height-123)/downSize.height))
            downSp:setPosition(upSize.width/2-5,125)

            -- downSp:setRotation(-90)
        else
            downSp:setAnchorPoint(CCPointMake(11/downSize.width,(downSize.height-123)/downSize.height))
            downSp:setPosition(upSize.width/2+5,125)
            -- downSp:setRotation(90)
        end
        downSp:setFlipY(true)
        if k==2 then
            upSp:setFlipX(true)
        else
            downSp:setFlipX(true)
        end
        self.downSpTb[k]=downSp
    end

    -- do return end

    local function checkfunc()
    end

    local checkSp=LuaCCSprite:createWithSpriteFrameName("armorElite_recruitBg.png",checkfunc)
    self.bgLayer:addChild(checkSp,4)
    checkSp:setTouchPriority(-(self.layerNum-1)*20-4)
    -- checkSp:setScale(0.8)
    self.checkSp=checkSp

    local checkPosY=G_VisibleSizeHeight-480
    checkSp:setPosition(G_VisibleSizeWidth/2,checkPosY)

    local checkSpSize=checkSp:getContentSize()

    local boxSp=CCSprite:createWithSpriteFrameName("armorElite_box.png")
    checkSp:addChild(boxSp)
    boxSp:setPosition(checkSpSize.width/2,checkSpSize.height/2-28)
    boxSp:setTag(911)

	local titleLb=GetTTFLabelWrap(getlocal("activity_zjjy_mysterious"),25,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	checkSp:addChild(titleLb)
	titleLb:setPosition(checkSpSize.width/2,checkSpSize.height-50)


    self:resert() -- 机械臂的初始角度，选择框的初始位置
end

function acArmorEliteDialog:initBottom()
	local iphoneAddH=0
	if(G_isIphone5())then
		iphoneAddH=50
	end
	local function rewardRecordsHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function showLog()
            acArmorEliteVoApi:showLogRecord(self.layerNum+1)
        end
        acArmorEliteVoApi:getLog(showLog)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    -- recordBtn:setScale(0.7)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(0,1))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(G_VisibleSizeWidth-recordBtn:getContentSize().width*recordBtn:getScaleX()/2-15,380+iphoneAddH))
    self.bgLayer:addChild(recordMenu,1)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setPosition(recordBtn:getContentSize().width*recordBtn:getScale()/2,0)
    recordLb:setScale(1/recordBtn:getScale())
    recordBtn:addChild(recordLb)

	local function nilFunc()
	end

	local desBg1=LuaCCScale9Sprite:createWithSpriteFrameName("armorElite_bgDi.png",CCRect(4, 4, 1, 1),nilFunc)
	desBg1:setAnchorPoint(ccp(0.5,0))
	desBg1:setContentSize(CCSizeMake(G_VisibleSizeWidth,64))
	self.bgLayer:addChild(desBg1,1)
	desBg1:setPosition(self.bgLayer:getContentSize().width/2,240+iphoneAddH)
	desBg1:setOpacity(255*0.5)
	self.desBg1=desBg1

	local barSp=CCSprite:createWithSpriteFrameName("monthlyBar.png")
	barSp:setAnchorPoint(ccp(0.5,1))
	barSp:setPosition(ccp(desBg1:getContentSize().width/2,desBg1:getContentSize().height+7))
	desBg1:addChild(barSp,1)
	barSp:setScale(1.1)

	local goldLine=CCSprite:createWithSpriteFrameName("armorElite_goldLine.png")
	desBg1:addChild(goldLine)
	goldLine:setPosition(desBg1:getContentSize().width/2,0)
	goldLine:setScaleX(600/goldLine:getContentSize().width)
	

    self:addDesLb1()

    local ishexie,rewardItem=acArmorEliteVoApi:isHexie()
	if(ishexie)then
        for k,v in pairs(rewardItem) do
            if k==#rewardItem then
            	rewardStr=v.name.."×"..v.num
            else
            	rewardStr=v.name.."×"..v.num .. ","
            end
        end
        self.hexieLb=GetTTFLabelWrap(getlocal("armorMatrix_recruit_hexie",{rewardStr}),23,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        self.hexieLb:setPosition(G_VisibleSizeWidth/2,200)
        self.bgLayer:addChild(self.hexieLb,1)
    end

	local function recruitFunc(tag,object)
		if self.canClick==false then
			do return end
		end
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
        end
        -- print("tag=======",tag)

        local num
        local cost=0
        if tag==3 then
        	num=1
        else
        	num=tag
        	local gems=playerVoApi:getGems() or 0
			local moneyCost=acArmorEliteVoApi:getCostByType(tag)
			-- print("moneyCost",moneyCost)
			cost=moneyCost
			if moneyCost>gems then
				local function onSure()
	                activityAndNoteDialog:closeAllDialog()
	            end
	            GemsNotEnoughDialog(nil,nil,moneyCost-gems,self.layerNum+1,moneyCost,onSure)
	            return
			end
        end

        if self.myLayer then
        	self.myLayer:removeFromParentAndCleanup(true)
            self.myLayer=nil
           	self:resert()
        end
        	

        self.currentTag=tag
        local function refreshFunc(report)
        	playerVoApi:setGems(playerVoApi:getGems()-cost)
        	self.report=report


        	self:addDesLb1()
        	self:refreshLbColor()
        	self.isToday=acArmorEliteVoApi:isToday()
        	self:refreshBtn()

        	self:startAni()
        end

        local function sureClick()
            local free=0
            if tag==3 then
                free=1
            end
	        acArmorEliteVoApi:socketElite(1,num,free,refreshFunc)
	    end

        local function secondTipFunc(sbFlag)
            local keyName=acArmorEliteVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end

        if cost and cost>0 then
            local keyName=acArmorEliteVoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
            
        else
            sureClick()
        end
	end
	self.recruitFunc=recruitFunc

	local freeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",recruitFunc,3,getlocal("activity_qxtw_buy",{1}),25)
	local freeBtn = CCMenu:createWithItem(freeItem)
	self.bgLayer:addChild(freeBtn,1)
	freeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	freeBtn:setBSwallowsTouches(true)
	freeBtn:setPosition(self.bgLayer:getContentSize().width/2-180,90)
	self.freeBtn=freeBtn

	local freeLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),25)
    freeItem:addChild(freeLb)
    freeLb:setPosition(freeItem:getContentSize().width/2,freeItem:getContentSize().height+20)
    freeLb:setAnchorPoint(ccp(0.5,0.5))
    freeLb:setColor(G_ColorGreen)

	local oneItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",recruitFunc,1,getlocal("activity_qxtw_buy",{1}),25)
	local oneBtn = CCMenu:createWithItem(oneItem)
	self.bgLayer:addChild(oneBtn,1)
	oneBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	oneBtn:setBSwallowsTouches(true)
	oneBtn:setPosition(self.bgLayer:getContentSize().width/2-180,90)
	self.oneBtn=oneBtn

	local childH=oneItem:getContentSize().height+20
    local expIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
    oneItem:addChild(expIcon1)
    expIcon1:setPositionY(childH)
    expIcon1:setAnchorPoint(ccp(0.5,0.5))
    expIcon1:setTag(21)

    local moneyCost1=acArmorEliteVoApi:getCostByType(1)
    local iconLb1=GetTTFLabel(moneyCost1,25)
    oneItem:addChild(iconLb1)
    iconLb1:setPositionY(childH)
    iconLb1:setAnchorPoint(ccp(0.5,0.5))
    iconLb1:setTag(22)
    self.iconLb1=iconLb1
    
    G_setchildPosX(oneItem,expIcon1,iconLb1)

	local tenItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",recruitFunc,10,getlocal("activity_qxtw_buy",{10}),25)
	local tenBtn = CCMenu:createWithItem(tenItem)
	self.bgLayer:addChild(tenBtn,1)
	tenBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	tenBtn:setBSwallowsTouches(true)
	tenBtn:setPosition(self.bgLayer:getContentSize().width/2+180,90)
	self.tenBtn=tenBtn

	local childH=tenItem:getContentSize().height+20
    local expIcon2=CCSprite:createWithSpriteFrameName("IconGold.png")
    tenItem:addChild(expIcon2)
    expIcon2:setPositionY(childH)
    expIcon2:setAnchorPoint(ccp(0.5,0.5))
    expIcon2:setTag(21)

    local moneyCost2=acArmorEliteVoApi:getCostByType(2)
    local iconLb2=GetTTFLabel(moneyCost2,25)
    tenItem:addChild(iconLb2)
    iconLb2:setPositionY(childH)
    iconLb2:setAnchorPoint(ccp(0.5,0.5))
    iconLb2:setTag(22)
    self.iconLb2=iconLb2
    G_setchildPosX(tenItem,expIcon2,iconLb2)

    self:refreshLbColor()

    self:refreshBtn()

end

function acArmorEliteDialog:addDesLb1()
	if self.desLb1 then
		self.desLb1:removeFromParentAndCleanup(true)
	end
    local version = acArmorEliteVoApi:getVersion()
    local desLb
    local colorTb
    local needNum=acArmorEliteVoApi:getNextBigRewardNum()
    if needNum==1 then
        if version==2 then
            desLb=getlocal("activity_zjjy_v2_des2")
            colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite,G_ColorPurple,G_ColorWhite}
        else
            desLb=getlocal("activity_zjjy_des2")
            colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite,G_ColorBlue,G_ColorWhite,G_ColorPurple,G_ColorWhite}
        end
    else
        if version==2 then
            colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite,G_ColorPurple,G_ColorWhite}
            desLb=getlocal("activity_zjjy_v2_des1",{acArmorEliteVoApi:getNextBigRewardNum()})
        else
            colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite,G_ColorBlue,G_ColorWhite,G_ColorPurple,G_ColorWhite}
            desLb=getlocal("activity_zjjy_des1",{acArmorEliteVoApi:getNextBigRewardNum()})
        end
    end

	self.desLb1,self.lbHeight=G_getRichTextLabel(desLb,colorTb,24,G_VisibleSizeWidth-80,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.desLb1:setAnchorPoint(ccp(0.5,1))
    self.desLb1:setPosition(ccp(self.desBg1:getContentSize().width/2,self.desBg1:getContentSize().height/2+self.lbHeight/2-4))
    self.desBg1:addChild(self.desLb1,2)
end


function acArmorEliteDialog:refreshLbColor()
	local gems=playerVoApi:getGems() or 0

	local moneyCost1=acArmorEliteVoApi:getCostByType(1)
    if moneyCost1>gems then
        self.iconLb1:setColor(G_ColorRed)
    else
    	self.iconLb1:setColor(G_ColorWhite)
    end

    local moneyCost2=acArmorEliteVoApi:getCostByType(2)
    if moneyCost2>gems then
        self.iconLb2:setColor(G_ColorRed)
    else
    	self.iconLb2:setColor(G_ColorWhite)
    end
end

function acArmorEliteDialog:refreshBtn()
	if self.oneBtn and self.freeBtn then
		if self.isToday then
			self.oneBtn:setVisible(true)
			self.freeBtn:setVisible(false)
		else
			self.oneBtn:setVisible(false)
			self.freeBtn:setVisible(true)
		end
	end
end

function acArmorEliteDialog:resert()
    self.downSpTb[1]:stopAllActions()
    self.downSpTb[2]:stopAllActions()
    -- self.checkSp:setScale(0.8)
    self.checkSp:setVisible(true)
    self.checkSp:stopAllActions()

    self.downSpTb[1]:setRotation(90)
    self.downSpTb[2]:setRotation(-90)

    local boxSp=tolua.cast(self.checkSp:getChildByTag(911),"CCSprite")
    if boxSp then
        boxSp:setVisible(true)
    end
end

function acArmorEliteDialog:initTableView()
end

function acArmorEliteDialog:startAni()
	self.state=2
    self.touchDialogBg:setIsSallow(true)
    self:beginAction()
end

function acArmorEliteDialog:beginAction()
	local checkSp=self.checkSp
    local posY=checkSp:getPositionY()

    local acArray=CCArray:create()

    local acMove=CCMoveTo:create(0,CCPointMake(G_VisibleSizeWidth/2,posY))
    acArray:addObject(acMove)

    local acScale1=CCScaleTo:create(0.2,1.2)
    -- acArray:addObject(acScale1)

    local acScale2=CCScaleTo:create(0.1,1)
    -- acArray:addObject(acScale2)

    local function rotateAc(parent,flag)
        local rotateTb={{0.2,230},{0.2,230},{0.2,175},{0.1,185},{0.1,180}}
        for k,v in pairs(rotateTb) do
            local time=v[1]
            local rotation=v[2]
            if flag==2 then
                rotation=-v[2]
            end
            local rotate1=CCRotateTo:create(time,rotation)
            parent:addObject(rotate1)
        end

    end
    -- 臂展动画
    local function folderAc()
        local acArray1=CCArray:create()

        
        local delay1=CCDelayTime:create(0.1)
        acArray1:addObject(delay1)

        rotateAc(acArray1,1)

        local function endAc()
            for i=1,2 do
                local pzFrameName="VSTop1.png" --动画
                local vsPzSp=CCSprite:createWithSpriteFrameName(pzFrameName)
                checkSp:addChild(vsPzSp)
                if i==1 then
                    vsPzSp:setPosition(0,checkSp:getContentSize().height/2+75)
                else
                    vsPzSp:setPosition(checkSp:getContentSize().width,checkSp:getContentSize().height/2+75)
                end

                local pzArr=CCArray:create()
                for kk=1,6 do
                    local nameStr="VSTop"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    pzArr:addObject(frame)
                end
                local animation=CCAnimation:createWithSpriteFrames(pzArr)
                animation:setDelayPerUnit(0.05)
                local animate=CCAnimate:create(animation)
                local function Remove()
                    vsPzSp:removeFromParentAndCleanup(true)
                end
                local  animEnd=CCCallFuncN:create(Remove)
                local  pzSeq=CCSequence:createWithTwoActions(animate,animEnd)
                vsPzSp:runAction(pzSeq)
            end

            local function acLight()
                local bombSp=CCSprite:createWithSpriteFrameName("armor_recruit_bomb.png")
                checkSp:addChild(bombSp)
                bombSp:setTag(208)
                bombSp:setPosition(checkSp:getContentSize().width/2,15)
                local blink = CCBlink:create(1, 3)
                local repeatForever=CCRepeatForever:create(blink)
                bombSp:runAction(repeatForever)

                local light1=CCSprite:createWithSpriteFrameName("armor_recruit_light.png")
                checkSp:addChild(light1)
                light1:setAnchorPoint(ccp(0.5,0))
                light1:setPosition(checkSp:getContentSize().width/2,0)
                light1:setTag(201)
                light1:setFlipY(true)

                local light2=CCSprite:createWithSpriteFrameName("armor_recruit_light.png")
                checkSp:addChild(light2)
                light2:setAnchorPoint(ccp(0.5,1))
                light2:setPosition(checkSp:getContentSize().width/2,checkSp:getContentSize().height-70)
                -- light2:setFlipY(true)
                light2:setTag(202)
                local moveTo1=CCMoveTo:create(0.3,CCPointMake(checkSp:getContentSize().width/2,checkSp:getContentSize().height-130))
                local acArray1=CCArray:create()
                acArray1:addObject(moveTo1)

                local function remove1()
                    light1:removeFromParentAndCleanup(true)
                end
                local callFunc13=CCCallFunc:create(remove1)
                acArray1:addObject(callFunc13)
                local seq1=CCSequence:create(acArray1)

                light1:runAction(seq1)

                local function remove()
                    light2:removeFromParentAndCleanup(true)
                end
                local acArray2=CCArray:create()
                local moveTo2=CCMoveTo:create(0.35,CCPointMake(checkSp:getContentSize().width/2,80))
                acArray2:addObject(moveTo2)
                local callFunc3=CCCallFunc:create(remove)
                acArray2:addObject(callFunc3)

                local function addPlist1()
                    -- local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup1.plist")
                    -- particleS:setPositionType(kCCPositionTypeFree)
                    -- particleS:setPosition(ccp(checkSp:getContentSize().width/2,checkSp:getContentSize().height/2))
                    -- particleS:setAutoRemoveOnFinish(true) -- 自动移除
                    -- checkSp:addChild(particleS,10)
                    -- particleS:setScale(0.4)
                    -- particleS:setTag(206)
                    -- local particleS2 = CCParticleSystemQuad:create("public/emblem/emblemGlowup2.plist")
                    -- particleS2:setPositionType(kCCPositionTypeFree)
                    -- particleS2:setPosition(ccp(checkSp:getContentSize().width/2,checkSp:getContentSize().height/2))
                    -- particleS2:setAutoRemoveOnFinish(true) -- 自动移除
                    -- checkSp:addChild(particleS2,11)
                    -- particleS2:setScale(0.4)
                    -- particleS2:setTag(207)
                end
                local function addPlist2()
                    -- local particleS = CCParticleSystemQuad:create("public/emblem/emblemGlowup3.plist")
                    -- particleS:setPositionType(kCCPositionTypeFree)
                    -- particleS:setPosition(ccp(checkSp:getContentSize().width/2,checkSp:getContentSize().height/2))
                    -- particleS:setAutoRemoveOnFinish(true) -- 自动移除
                    -- checkSp:addChild(particleS,12)
                    -- particleS:setTag(205)
                    -- particleS:setScale(0.4)

                    local delay=CCDelayTime:create(0.4)
                    local function sbEnd()
                        self:endAni()
                    end
                    local callFunc=CCCallFunc:create(sbEnd)
                    local acArr=CCArray:create()
                    -- acArr:addObject(delay)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    checkSp:runAction(seq)
                end
                -- local callFunc1=CCCallFunc:create(addPlist1)
                -- acArray2:addObject(callFunc1)
                -- local delay = CCDelayTime:create(0.5)
                -- acArray2:addObject(delay)
                local callFunc2=CCCallFunc:create(addPlist2)
                acArray2:addObject(callFunc2)

                local seq=CCSequence:create(acArray2)
                light2:runAction(seq)
            end   
            acLight() -- 光 扫射

            local function acLightIng()
                local lightingSp1=CCSprite:createWithSpriteFrameName("armor_recruit_l1.png")
                checkSp:addChild(lightingSp1)
                lightingSp1:setTag(203)
                lightingSp1:setPosition(15,checkSp:getContentSize().height-150)

                local pzArr1=CCArray:create()
                for kk=1,5 do
                    local nameStr="armor_recruit_l"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    pzArr1:addObject(frame)
                end
                local animation1=CCAnimation:createWithSpriteFrames(pzArr1)
                animation1:setDelayPerUnit(0.05)
                local animate1=CCAnimate:create(animation1)
                local repeatForever1=CCRepeatForever:create(animate1)
                lightingSp1:runAction(repeatForever1)

                local lightingSp2=CCSprite:createWithSpriteFrameName("armor_recruit_l1.png")
                checkSp:addChild(lightingSp2)
                lightingSp2:setTag(204)
                lightingSp2:setPosition(checkSp:getContentSize().width-15,checkSp:getContentSize().height-150)

                local pzArr2=CCArray:create()
                for kk=5,1,-1 do
                    local nameStr="armor_recruit_l"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    pzArr2:addObject(frame)
                end
                local animation2=CCAnimation:createWithSpriteFrames(pzArr2)
                animation2:setDelayPerUnit(0.05)
                local animate2=CCAnimate:create(animation2)
                local repeatForever2=CCRepeatForever:create(animate2)
                lightingSp2:runAction(repeatForever2)
            end
            acLightIng()  -- 闪电   
        end
        local callFunc=CCCallFunc:create(endAc)

        acArray1:addObject(callFunc)
        local seq = CCSequence:create(acArray1)
        self.downSpTb[1]:runAction(seq)

        local acArray2=CCArray:create()
        local delay2=CCDelayTime:create(0.1)
        acArray2:addObject(delay2)

        rotateAc(acArray2,2)

        local seq2 = CCSequence:create(acArray2)
        self.downSpTb[2]:runAction(seq2)
    end
    -- local callFunc=CCCallFunc:create(folderAc)
    -- acArray:addObject(callFunc)

    local seq = CCSequence:create(acArray)
    checkSp:runAction(seq)

    folderAc()
end

function acArmorEliteDialog:endAni()
    self.state=0
    self.touchDialogBg:setIsSallow(false)
    local checkSp=self.checkSp
    checkSp:stopAllActions()
    checkSp:setPositionX(G_VisibleSizeWidth/2)
    checkSp:setScale(1)
    self.downSpTb[1]:stopAllActions()
    self.downSpTb[2]:stopAllActions()
    self.downSpTb[1]:setRotation(180)
    self.downSpTb[2]:setRotation(-180)

    local boxSp=tolua.cast(checkSp:getChildByTag(911),"CCSprite")
    if boxSp then
        boxSp:setVisible(false)
    end

    for i=201,208 do
        local child=checkSp:getChildByTag(i)
        if child then
            child:removeFromParentAndCleanup(true)
        end
    end

    -- self:resert()
    if SizeOfTable(self.report)==1 then
        self:showOneSerch(self.report)
    else
        self:showTenSearch(self.report,time)
    end
end

function acArmorEliteDialog:showOneSerch(report)
	self.canClick=false
    local layerNum=self.layerNum+1
    -- self.currentTag
    local checkSp=self.checkSp
  
    if self.myLayer==nil then
        self.myLayer=CCLayer:create()
        self.bgLayer:addChild(self.myLayer,10)
    else
        self.myLayer:removeFromParentAndCleanup(true)
        self.myLayer=nil
        self.myLayer=CCLayer:create()
        self.bgLayer:addChild(self.myLayer,10)
    end

    local layer = CCLayer:create()
    self.myLayer:addChild(layer,2)
    -- layer:setTouchEnabled(true)
    -- layer:setBSwallowsTouches(true)
    -- layer:setTouchPriority(-(layerNum-1)*20-1)


    local reward=report[1]
    local icon,scale = G_getItemIcon(reward,100,true,layerNum)
    layer:addChild(icon,4)
    icon:setPosition(G_VisibleSizeWidth/2,checkSp:getPositionY()-13)
    icon:setTouchPriority(-(layerNum-1)*20-4)
    icon:setScale(0.1)

    if reward.type=="am" and reward.key=="exp" then
        local lvBg=CCSprite:createWithSpriteFrameName("amHeaderBg.png")
        lvBg:setAnchorPoint(ccp(1,0))
        lvBg:setPosition(ccp(icon:getContentSize().width-6,7))
        icon:addChild(lvBg)
        lvBg:setFlipX(true)
        -- lvBg:setScale(1/scale)
        -- lvBg:setTag(2002)
        local numLb=GetTTFLabel(FormatNumber(reward.num),25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(icon:getContentSize().width-12,7))
        icon:addChild(numLb,1)

        lvBg:setScaleX((numLb:getContentSize().width+25)/lvBg:getContentSize().width)
        lvBg:setScaleY(numLb:getContentSize().height/lvBg:getContentSize().height)
    end

    local nameStr=reward.name
    
    local nameLb = GetTTFLabelWrap(nameStr,22,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    nameLb:setAnchorPoint(ccp(0.5,1))
    nameLb:setPosition(ccp(icon:getContentSize().width/2,0))
    icon:addChild(nameLb)
    nameLb:setScale(1/scale)

    local acArray=CCArray:create()

    local scaleTo1=CCScaleTo:create(0.2,1.5)
    acArray:addObject(scaleTo1)
    local scaleTo2=CCScaleTo:create(0.05,1)
    acArray:addObject(scaleTo2)

    local function endAc()
	    self.canClick=true
        local showReward=G_clone(report)
        local ishexie,rewardItem=acArmorEliteVoApi:isHexie()
        if ishexie then
            table.insert(showReward,1,rewardItem[1])
        end
	    G_showRewardTip(showReward,true)
        -- local function callback1()
        --     if G_checkClickEnable()==false then
        --         do
        --             return
        --         end
        --     else
        --         base.setWaitTime=G_getCurDeviceMillTime()
        --     end
        --     self.oneMoreFreeMenu=nil
        --     self.oneMoreRecruitMenu=nil
        --     self.myLayer:removeFromParentAndCleanup(true)
        --     self.myLayer=nil
        --     self:resert()
        -- end

        -- local function callback2()
        --     self.oneMoreFreeMenu=nil
        --     self.oneMoreRecruitMenu=nil
        --     self.myLayer:removeFromParentAndCleanup(true)
        --     self.myLayer=nil
        --     self:resert()
        --     self.recruitFunc(self.currentTag)
        -- end

        -- local freeMenu,recruitMenu,sureMenu=self:addBtnMenu(layer,callback1,callback2,layerNum)
        -- freeMenu:setPosition(G_VisibleSizeWidth/2+150,80)
        -- recruitMenu:setPosition(G_VisibleSizeWidth/2+150,80)
        -- sureMenu:setPosition(G_VisibleSizeWidth/2-150,80)


        -- self.oneMoreFreeMenu=freeMenu
        -- self.oneMoreRecruitMenu=recruitMenu

        -- self:refreshBtn()


        -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",callback1,nil,nil,nil);
        -- closeBtnItem:setPosition(0, 0)
        -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))

        -- local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSize.height)
        -- local closeBtn = CCMenu:createWithItem(closeBtnItem)
        -- closeBtn:setTouchPriority(-(layerNum-1)*20-4)
        -- closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
        -- self.myLayer:addChild(closeBtn)
    end
    local callFunc=CCCallFunc:create(endAc)
    acArray:addObject(callFunc)

    local seq=CCSequence:create(acArray)

    icon:runAction(seq)

end

function acArmorEliteDialog:showTenSearch(report,time)

    local layerNum=self.layerNum+1
    if self.myLayer==nil then
        self.myLayer=CCLayer:create()
        self.bgLayer:addChild(self.myLayer,10)
        self.myLayer:setTouchEnabled(true)
        self.myLayer:setBSwallowsTouches(true)
        self.myLayer:setTouchPriority(-(layerNum-1)*20-1)
    end
   
    local layer = CCLayer:create()
    self.myLayer:addChild(layer,2)

    local iconSpTb={}
    local guangSpTb={}

    local function endCallback()
    end

    local function onLoadIcon(fn,icon)
        if self and self.myLayer and icon then
            self.myLayer:addChild(icon)
            icon:setScaleX(G_VisibleSizeWidth/icon:getContentSize().width)
            icon:setScaleY(G_VisibleSizeHeight/icon:getContentSize().height)
            icon:setPosition(self.myLayer:getContentSize().width/2,self.myLayer:getContentSize().height/2)
            icon:setColor(G_ColorGray)
        end
    end
    local url=G_downloadUrl("function/armorBg.jpg")
    local webImage = LuaCCWebImage:createWithURL(url,onLoadIcon)

    -- activity_chunjiepansheng_getReward
    local subH1=0
    local subH2=0
    if(G_isIphone5())then
        subH1=80
        subH2=120
    end
    local titleLb = GetTTFLabelWrap(getlocal("you_get_title"),30,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-70-subH1))
    titleLb:setColor(G_ColorYellowPro)
    layer:addChild(titleLb)

    local function runGuangAction(targetSp,delaytime,isReverse)
        local delay=CCDelayTime:create(delaytime)
        local scaleTo1 = CCScaleTo:create(0.2,2)
        local scaleTo2 = CCScaleTo:create(0.05,1.6)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)

        local function callback()
            local rotateBy = CCRotateBy:create(4,360)
            if isReverse then
                local reverseBy = rotateBy:reverse()
                targetSp:runAction(CCRepeatForever:create(reverseBy))
            else
                targetSp:runAction(CCRepeatForever:create(rotateBy))
            end
            
        end
        local callFunc=CCCallFunc:create(callback)
        acArr:addObject(callFunc)

        local seq=CCSequence:create(acArr)
        targetSp:runAction(seq)
    end

    local function runIconAction(targetSp,delaytime,numFlag)
        local delay=CCDelayTime:create(delaytime)
        local scale1=120/targetSp:getContentSize().width
        local scale2=100/targetSp:getContentSize().width
        local scaleTo1 = CCScaleTo:create(0.2,scale1)
        local scaleTo2 = CCScaleTo:create(0.05,scale2)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        if numFlag==10 then
            local function callback()
                local showReward=G_clone(report)
                local ishexie,rewardItem=acArmorEliteVoApi:isHexie()
                if ishexie then
                    rewardItem[1].num=rewardItem[1].num*10
                    table.insert(showReward,1,rewardItem[1])
                end
            	G_showRewardTip(showReward,true)

                self.isAction=true
                local menu=layer:getChildByTag(101)
                if menu then
                    menu:setVisible(true)
                end
            end
            local callFunc=CCCallFunc:create(callback)
            acArr:addObject(callFunc)
        end
        local seq=CCSequence:create(acArr)
        targetSp:runAction(seq)
    end

    local subH = 170
    subH=subH+subH2
    local jiageH=160
    if(G_isIphone5())then
        jiageH=170
    end
    for k,v in pairs(report) do
        local i=math.ceil(k/3)
        local j=k%3
        if j==0 then
            j=3
        end

        local pos=ccp(68+(j-1)*200+50, G_VisibleSizeHeight-subH-(i-1)*jiageH)
        if k==10 then
            pos=ccp(68+(2-1)*200+50, G_VisibleSizeHeight-subH-(i-1)*jiageH)
        end

        local awardItem=v

        local icon,scale = G_getItemIcon(awardItem,100,true,layerNum)
        layer:addChild(icon,4)
        icon:setPosition(pos)
        icon:setTouchPriority(-(layerNum-1)*20-4)

        iconSpTb[k]=icon

        if awardItem.type=="am" and awardItem.key=="exp" then
            local lvBg=CCSprite:createWithSpriteFrameName("amHeaderBg.png")
            lvBg:setAnchorPoint(ccp(1,0))
            lvBg:setPosition(ccp(icon:getContentSize().width-6,7))
            lvBg:setFlipX(true)
            icon:addChild(lvBg)
            -- lvBg:setScale(1/scale)
            -- lvBg:setTag(2002)
            local numLb=GetTTFLabel(FormatNumber(awardItem.num),25)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(icon:getContentSize().width-12,7))
            icon:addChild(numLb,1)

            lvBg:setScaleX((numLb:getContentSize().width+25)/lvBg:getContentSize().width)
            lvBg:setScaleY(numLb:getContentSize().height/lvBg:getContentSize().height)
            -- numLb:setScale(1/scale)
            -- lvLb:setTag(2001)
        end

        local nameStr=awardItem.name

        local nameLb = GetTTFLabelWrap(nameStr,22,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setPosition(ccp(icon:getContentSize().width/2,0))
        icon:addChild(nameLb)
        nameLb:setScale(1/scale)

        local flag=false
        if v.type=="p" then
            -- if v.key~="exp" then
                local useGetArmor=propCfg[v.key].useGetArmor
                if useGetArmor then
                    local aKey
                    for k,v in pairs(useGetArmor) do
                        aKey=k
                    end
                    local cfg=armorMatrixVoApi:getCfgByMid(aKey)
                    local color=armorMatrixVoApi:getColorByQuality(cfg.quality)
                    nameLb:setColor(color)

                    if cfg.quality>=4 then
                        flag=true
                    end
                end
            -- end
        end

        icon:setScale(0.0001)

        
        -- delaytime
        local delayTime = (k-1)*0.2

        runIconAction(icon,delayTime,k)

        if flag == true then
            local guangSp1 = CCSprite:createWithSpriteFrameName("equipShine.png")
            layer:addChild(guangSp1,1)
            guangSp1:setPosition(pos)
            guangSp1:setScale(0.0001)

            runGuangAction(guangSp1,delayTime,true)

            local guangSp2 = CCSprite:createWithSpriteFrameName("equipShine.png")
            layer:addChild(guangSp2,1)
            guangSp2:setPosition(pos)
            guangSp2:setScale(0.0001)

            runGuangAction(guangSp2,delayTime)

            table.insert(guangSpTb,{guangSp1,guangSp2})

        end

    end

    local function callback1()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self.myLayer:removeFromParentAndCleanup(true)
        self.myLayer=nil
        self:resert()
    end
    local function callback2()
        self.myLayer:removeFromParentAndCleanup(true)
        self.myLayer=nil
        self:resert()
        self.recruitFunc(10)
    end
    local menuItem={}
    menuItem[1]=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",callback1,nil,getlocal("confirm"),25)
    -- if(base.hexieMode==1)then
        menuItem[2]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",callback2,nil,getlocal("activity_qxtw_buy",{10}),25)
        
    -- else
    --     menuItem[2]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",callback2,nil,getlocal("emblem_getBtnLbHexie",{10}),25)
    -- end

    local btnMenu = CCMenu:create()
    
    btnMenu:addChild(menuItem[1])
    btnMenu:addChild(menuItem[2])
    
    btnMenu:alignItemsHorizontallyWithPadding(160)
    layer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(layerNum-1)*20-4)
    btnMenu:setBSwallowsTouches(true)
    btnMenu:setPositionY(140) 
    btnMenu:setTag(101)

    if(G_isIphone5())then
        btnMenu:setPositionY(btnMenu:getPositionY()+10) 
    end


    local costLbPosY=90
    local costNum=armorMatrixVoApi:getRecruitCost(2,10)
    local costLb=GetTTFLabel(costNum .. "  ",25)
    costLb:setAnchorPoint(ccp(0,0.5))
    menuItem[2]:addChild(costLb)

    local gems=playerVoApi:getGems() or 0
    if costNum>gems then
        costLb:setColor(G_ColorRed)
    end

    local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setAnchorPoint(ccp(0,0.5))
    goldIcon:setPosition(costLb:getContentSize().width,costLb:getContentSize().height/2)
    costLb:addChild(goldIcon,1)

    costLb:setPosition(menuItem[2]:getContentSize().width/2-(costLb:getContentSize().width+goldIcon:getContentSize().width)/2,costLbPosY)

    self.isAction = false

    btnMenu:setVisible(false)

    if time then
        endCallback()
    end
end

function acArmorEliteDialog:fastTick()
    if self.state==3 then
        self:endAni()
    end      
end

function acArmorEliteDialog:tick() 
	local vo=acArmorEliteVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

	local today=acArmorEliteVoApi:isToday()
	if self.isToday~=today then
		self.isToday=today
		self:refreshBtn()
	end 
    if self.timeLb then
    	self.timeLb:setString(acArmorEliteVoApi:getTimer())
    end
end



