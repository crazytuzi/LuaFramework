acXingyunpindianDialog = commonDialog:new()

function acXingyunpindianDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.rewardIconList={}
    self.rewardList={}
    self.flickerList={}
    self.reward={}

    self.showRowNum= false
    self.dicePlay=false
    self.flickerPlay=false
    self.btnShow=true
    self.playStart=false
    self.isLottery=false
    self.canStopAc=false
    self.inShowFlick=false
    self.callbackEnd =false
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acRepublicHui.plist")
    return nc
end 

function acXingyunpindianDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))   
end

function acXingyunpindianDialog:initTableView()
    self.arrowIndex=60

    local function touchDialog()
        if self.canStopAc ==true then
            self.canStopAc =false
            self:curShowAward()
        end
        if self.dicePlay then
            return
        end
    end
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect)
    self.touchDialogBg:setOpacity(0)
    self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
    self.touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.touchDialogBg,1)

    local function nilFunc()
    end
    local backSprie2 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
    backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.bgLayer:getContentSize().height-310))
    backSprie2:ignoreAnchorPointForPosition(false);
    backSprie2:setAnchorPoint(ccp(0.5,0));
    backSprie2:setIsSallow(false)
    backSprie2:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie2:setPosition(self.bgLayer:getContentSize().width/2, 20)
    self.bgLayer:addChild(backSprie2)

    if(G_isIphone5())then
        backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.bgLayer:getContentSize().height-410))
    else
        backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.bgLayer:getContentSize().height-310))
    end



    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    if(G_isIphone5())then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-380),nil)
    else
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-240),nil)
    end
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(0,0))
    backSprie2:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(0)

    -- if(G_isIphone5())then
    --  backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.bgLayer:getContentSize().height-370))
    -- end
end

function acXingyunpindianDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,700)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local iconWidth=110
        local iconHeight=136
        local wSpace=10
        local hSpace=-10
        local xSpace=30*4
        local ySpace=30*3+80
        self.flickerPosition=acXingyunpindianVoApi:getflickerPosition()

        local rewardCfg = acXingyunpindianVoApi:getRouletteCfg()
        if rewardCfg ~= nil then
            local index =1
            for k,v in pairs(rewardCfg) do
                local item = {}
                local icon, iconScale
                if v then
                    for m,n in pairs(v) do
                        if m~=nil and n~=nil then
                            local key,type1,num=m,k,n
                            if type(n)=="table" then
                                for i,j in pairs(n) do
                                    if i=="index" then
                                        index=j
                                    else
                                        key=i
                                        num=j
                                    end
                                    
                                end
                            end

                            if k=="mm" then
                                local pCfg = activityCfg.republicHui[key]
                                item = {type="mm",key=key,name = getlocal(pCfg.name), pic= pCfg.icon, num = num, desc = pCfg.des,index=index}
                            else
                                local name,pic,desc,id,noUseIdx,eType,equipId=getItem(key,type1)
                                item={name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId}
                            end
                    
                           
                            local icon,iconScale= G_getItemIcon(item, 100, true, self.layerNum)
                            if icon and item and item.num then
                                icon:ignoreAnchorPointForPosition(false)
                                icon:setAnchorPoint(ccp(0.5,0.5))
                                icon:setIsSallow(false)
                                icon:setTouchPriority(-(self.layerNum-1)*20-3)
                                cell:addChild(icon,1)

                                local numLabel=GetTTFLabel("x"..item.num,25)
                                numLabel:setAnchorPoint(ccp(1,0))
                                numLabel:setPosition(icon:getContentSize().width-10,0)
                                icon:addChild(numLabel,1)
                                numLabel:setScaleX(1/iconScale)
                                numLabel:setScaleY(1/iconScale)

                                self.rewardIconList[index]=icon
                                self.rewardList[index]=item
                                if(index<5)then
                                    icon:setPosition(ccp((iconWidth+wSpace)*(index-1)+xSpace,(iconHeight+hSpace)*3+hSpace+ySpace))
                                elseif(index==5)then
                                    icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
                                elseif(index==6)then
                                    icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,iconHeight+hSpace*2+ySpace))
                                elseif(index<11)then
                                    icon:setPosition(ccp((iconWidth+wSpace)*(10-index)+xSpace,hSpace*1+ySpace))
                                elseif(index==11)then
                                    icon:setPosition(ccp(xSpace,iconHeight+hSpace*2+ySpace))
                                elseif(index==12)then
                                    icon:setPosition(ccp(xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
                                end
                                if index==self.flickerPosition then
                                    self:showFlicker(index)
                                end
                            end
                           
                        end
                    end
                    
                end
                
               
                
            end

        end

        -- local topArrowY = 670
        local topArrowY = 610
        local buttomArrowY = 80
        local leftArrowX = 30
        local rightArrowX = self.bgLayer:getContentSize().width-70
        local arrowY = nil
        local single = 30
        for i=1,4 do
            arrowY = 390 - single * (i - 1)
            local leftArrow
            local rightArrow
            local topArrow
            local buttomArrow
            leftArrow= CCSprite:createWithSpriteFrameName("SlotArow.png")
            rightArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            topArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            buttomArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")

            -- if i==1 or i==3 then
            --     leftArrow= CCSprite:createWithSpriteFrameName("SlotArowRed.png")
            --     rightArrow = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
            --     topArrow = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
            --     buttomArrow = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
            -- else
            --     leftArrow= CCSprite:createWithSpriteFrameName("SlotArow.png")
            --     rightArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            --     topArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            --     buttomArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            -- end

            leftArrow:setPosition(ccp(leftArrowX,arrowY))
            leftArrow:setRotation(180)
            cell:addChild(leftArrow)

            rightArrow:setPosition(ccp(rightArrowX,arrowY))
            cell:addChild(rightArrow)

            arrowX = (self.bgLayer:getContentSize().width-40)/2-40+single * (i - 1)
            topArrow:setPosition(ccp(arrowX,topArrowY))
            topArrow:setRotation(270)
            cell:addChild(topArrow)

            buttomArrow:setPosition(ccp(arrowX,buttomArrowY))
            buttomArrow:setRotation(90)
            cell:addChild(buttomArrow)
        end

        self.leftIcon1 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.leftIcon1:setPosition(ccp(leftArrowX,360))
        self.leftIcon1:setVisible(true)
        self.leftIcon1:setRotation(180)
        cell:addChild(self.leftIcon1)
        self.leftIcon2 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.leftIcon2:setPosition(ccp(leftArrowX,300))
        self.leftIcon2:setVisible(true)
        self.leftIcon2:setRotation(180)
        cell:addChild(self.leftIcon2)

        self.rightIcon1 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.rightIcon1:setPosition(ccp(rightArrowX,390))
        self.rightIcon1:setVisible(true)
        cell:addChild(self.rightIcon1)
        self.rightIcon2 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.rightIcon2:setPosition(ccp(rightArrowX,330))
        self.rightIcon2:setVisible(true)
        cell:addChild(self.rightIcon2)

        self.topIcon1 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.topIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-40,topArrowY))
        self.topIcon1:setVisible(true)
        self.topIcon1:setRotation(270)
        cell:addChild(self.topIcon1)
        self.topIcon2 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.topIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+20,topArrowY))
        self.topIcon2:setVisible(true)
        self.topIcon2:setRotation(270)
        cell:addChild(self.topIcon2)

        self.buttomIcon1 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.buttomIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-10,buttomArrowY))
        self.buttomIcon1:setVisible(true)
        self.buttomIcon1:setRotation(90)
        cell:addChild(self.buttomIcon1)
        self.buttomIcon2 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.buttomIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+50,buttomArrowY))
        self.buttomIcon2:setVisible(true)
        self.buttomIcon2:setRotation(90)
        cell:addChild(self.buttomIcon2)

        self.playStart=true

        local function touch()
        end
        local capInSet = CCRect(20, 20, 10, 10)
        self.backSprite=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
        self.backSprite:setContentSize(CCSizeMake(220,220))
        self.backSprite:setAnchorPoint(ccp(0.5,0.5))
        self.backSprite:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2,350))
        cell:addChild(self.backSprite,1)
        if self.dice1Num==nil and self.dice2Num==nil then
            self.dice1Num,self.dice2Num = acXingyunpindianVoApi:getDiceNum()
        end

        self.dice1Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice1Num..".png")
        self.dice1Sp:setAnchorPoint(ccp(0.5,0.5))
        self.dice1Sp:setPosition(ccp(self.backSprite:getContentSize().width/4,self.backSprite:getContentSize().height/2))
        self.backSprite:addChild(self.dice1Sp,2)
        self.dice2Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice2Num..".png")
        self.dice2Sp:setAnchorPoint(ccp(0.5,0.5))
        self.dice2Sp:setPosition(ccp(self.backSprite:getContentSize().width/4*3,self.backSprite:getContentSize().height/2))
        self.backSprite:addChild(self.dice2Sp,2)

        self.diceNumSp=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
        self.diceNumSp:setAnchorPoint(ccp(0.5,0.5))
        self.diceNumSp:setPosition(ccp(self.backSprite:getContentSize().width/2,self.backSprite:getContentSize().height/2))
        self.diceNumSp:setContentSize(CCSizeMake(120,120))
        self.backSprite:addChild(self.diceNumSp,100)

        self.diceNumLb=GetTTFLabel(self.dice1Num+self.dice2Num,60)
        self.diceNumLb:setPosition(ccp(self.diceNumSp:getContentSize().width/2,self.diceNumSp:getContentSize().height/2))
        self.diceNumLb:setAnchorPoint(ccp(0.5,0.5))
        self.diceNumSp:addChild(self.diceNumLb)
        self.diceNumLb:setColor(G_ColorYellow)
        if self.showRowNum== false then
            self.diceNumSp:setVisible(false)
        end

    

        local leftPosX=self.bgLayer:getContentSize().width/2-170
        local rightPosX=self.bgLayer:getContentSize().width/2+130

          
        local function btnCallback(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end 

            PlayEffect(audioCfg.mouseClick)

            self.tag=tag

            self.flickerPosition=acXingyunpindianVoApi:getflickerPosition()
            if self.rewardIconList and SizeOfTable(self.rewardIconList)>0 then
                for k,v in pairs(self.rewardIconList) do
                    if k and v and k~=self.flickerPosition then
                        self:hideFlicker(k)
                    end
                end
            end
            
            local nowNum = acXingyunpindianVoApi:getNowNum()
            local num = 1
            if self.tag==1 then
                num=1
            else
                num=acXingyunpindianVoApi:getMul()
            end
            if num>nowNum then
                local function chongzhiCallback() --充值
                    activityAndNoteDialog:closeAllDialog()
                    vipVoApi:showRechargeDialog(self.layerNum+1)
                    if clickSureCallback then
                        clickSureCallback()
                    end
                end
                local smallD=smallDialog:new()
                smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),chongzhiCallback,getlocal("dialog_title_prompt"),getlocal("activity_xingyunpindian_noTime",{acXingyunpindianVoApi:getRecharge()}),nil,self.layerNum+1)
                return
            end
            local function lotteryCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData.numTab and type(sData.numTab)=="table" and sData.numTab[1]~=nil and sData.numTab[2]~=nil
                        then

                        self.dice1Num,self.dice2Num=sData.numTab[1],sData.numTab[2]
                    end
                    local rowNum = self.dice1Num+self.dice2Num
                    self.reward={}
                    if tag==1 then
                        -- if free==1 then
                        --     playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
                        -- end
                        if (rowNum+self.flickerPosition)>12 then 
                            table.insert(self.reward,self.rewardList[(rowNum+self.flickerPosition)-12])
                        else
                            table.insert(self.reward,self.rewardList[rowNum+self.flickerPosition])
                        end
                    elseif tag==2 then
                        for i=(self.flickerPosition+1),(self.flickerPosition+rowNum) do
                            local pos = i
                            if pos >12 then
                                pos = pos-12
                            end
                            table.insert(self.reward,self.rewardList[pos])
                        end
                    end

                    for k,v in pairs(self.reward) do   
                         G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                    end

                    if sData and sData.data and sData.data.xingyunpindian then
                        acXingyunpindianVoApi:updateData(sData.data.xingyunpindian)
                    end
                    self.desLb:setString(getlocal("activity_xingyunpindian_nowTime",{acXingyunpindianVoApi:getNowNum()}))
                    self.dicePlay=true
                    self.canStopAc =true
                    self.touchDialogBg:setIsSallow(true)
                    self:dicePlayTick()
                    self.btnShow=false
                    if self.btnShow==false then
                        self.lotteryOneBtn:setEnabled(false)
                        self.lotteryTenBtn:setEnabled(false)
                    end
                end

            end

            socketHelper:acXingyunpindianChoujiang(self.tag-1,lotteryCallback)     
        end


           
            local btnY=20
            if G_getIphoneType() == G_iphoneX then
                btnY = -50
            end
            self.lotteryTenBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",btnCallback,2,getlocal("activity_republicHui_superBtn"),25)
            self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
            local lotteryMenu=CCMenu:createWithItem(self.lotteryTenBtn)
            -- lotteryMenu:setPosition(ccp(leftPosX,btnY))
            lotteryMenu:setPosition(ccp(rightPosX,btnY))
            lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
            cell:addChild(lotteryMenu,2)

            self.lotteryOneBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",btnCallback,1,getlocal("activity_xingyunpindian_btn1"),25)
            self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
            local lotteryMenu1=CCMenu:createWithItem(self.lotteryOneBtn)
            -- lotteryMenu1:setPosition(ccp(rightPosX,btnY))
            lotteryMenu1:setPosition(ccp(leftPosX,btnY))
            lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-3)
            cell:addChild(lotteryMenu1,2)
    
        return cell

    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acXingyunpindianDialog:showFlicker(i)
    if newGuidMgr:isNewGuiding() then
        do return end
    end
    local icon = self.rewardIconList[i]
    if icon then
        local iconSize=100
        local flicker = icon:getChildByTag(501)
        if flicker==nil then
            local pzFrameName="RotatingEffect1.png"
            flicker=CCSprite:createWithSpriteFrameName(pzFrameName)
            local m_iconScaleX=(iconSize+8)/flicker:getContentSize().width
            local m_iconScaleY=(iconSize+8)/flicker:getContentSize().height
            local pzArr=CCArray:create()
            for kk=1,20 do
                local nameStr="RotatingEffect"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(pzArr)
            animation:setDelayPerUnit(0.1)
            local animate=CCAnimate:create(animation)
            flicker:setAnchorPoint(ccp(0.5,0.5))
            flicker:setScaleX(m_iconScaleX)
            flicker:setScaleY(m_iconScaleY)
            flicker:setPosition(ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
            icon:addChild(flicker,501)
            local repeatForever=CCRepeatForever:create(animate)
            flicker:runAction(repeatForever)
            -- flicker=G_addRectFlicker(icon,m_iconScaleX,m_iconScaleY)
            self.flickerList[i]=flicker
        else
            flicker:setPosition(ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
            if flicker:isVisible()==false then
                flicker:setVisible(true)
                local pzArr=CCArray:create()
                for kk=1,20 do
                    local nameStr="RotatingEffect"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    pzArr:addObject(frame)
                end
                local animation=CCAnimation:createWithSpriteFrames(pzArr)
                animation:setDelayPerUnit(0.1)
                local animate=CCAnimate:create(animation)
                local repeatForever=CCRepeatForever:create(animate)
                flicker:runAction(repeatForever)
            end
        end
    end
end

function acXingyunpindianDialog:doUserHandler()

    local function nilFunc()
    end
    local backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),nilFunc)
    backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 146))
    backSprie1:ignoreAnchorPointForPosition(false);
    backSprie1:setAnchorPoint(ccp(0.5,1));
    backSprie1:setIsSallow(false)
    backSprie1:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie1:setPosition(G_VisibleSizeWidth/2, G_VisibleSizeHeight-90)
    self.bgLayer:addChild(backSprie1)

    if(G_isIphone5())then
        backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 200))
        backSprie1:setPosition(G_VisibleSizeWidth/2, G_VisibleSizeHeight-120)
    else
        backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 146))
        backSprie1:setPosition(G_VisibleSizeWidth/2, G_VisibleSizeHeight-90)
    end

    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, backSprie1:getContentSize().height-10))
    backSprie1:addChild(acLabel)
    acLabel:setColor(G_ColorGreen)

    local acVo = acXingyunpindianVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,25)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, backSprie1:getContentSize().height-40))
    backSprie1:addChild(messageLabel)
    self.timeLb=messageLabel
    self:updateAcTime()

    local function touchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local tabStr = {"\n",getlocal("activity_xingyunpindian_tip3",{acXingyunpindianVoApi:getMul()}),getlocal("activity_xingyunpindian_tip2"), getlocal("activity_xingyunpindian_tip1",{acXingyunpindianVoApi:getRecharge()}),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
        sceneGame:addChild(dialog,self.layerNum+1)

    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(backSprie1:getContentSize().width-25,  backSprie1:getContentSize().height-10))
    backSprie1:addChild(menuDesc,2)

     local descTv
     if(G_isIphone5())then
        descTv=G_LabelTableView(CCSize(500,100),getlocal("activity_xingyunpindian_des",{acXingyunpindianVoApi:getRecharge()}),25,kCCTextAlignmentLeft)
     else
        descTv=G_LabelTableView(CCSize(500,70),getlocal("activity_xingyunpindian_des",{acXingyunpindianVoApi:getRecharge()}),25,kCCTextAlignmentLeft)
     end
    descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv:setPosition(ccp(30,10))
    backSprie1:addChild(descTv,2)
    descTv:setMaxDisToBottomOrTop(50)

    

    local desLb = GetTTFLabelWrap(getlocal("activity_xingyunpindian_nowTime",{acXingyunpindianVoApi:getNowNum()}),25,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(25, self.bgLayer:getContentSize().height-260)
    self.bgLayer:addChild(desLb)
    -- desLb:setColor(G_ColorGreen)
    self.desLb=desLb

    if(G_isIphone5())then
        descTv:setPosition(ccp(30,20))
        desLb:setPosition(25, self.bgLayer:getContentSize().height-355)
    else
        descTv:setPosition(ccp(30,10))
        desLb:setPosition(25, self.bgLayer:getContentSize().height-260)
    end
end

function acXingyunpindianDialog:play()
    self.inShowFlick =true
    self.tickInterval=30
    self.tickConst=30
    self.intervalNum=5--fasttick间隔 3帧一次
    self.haloPos=self.flickerPosition
    self.showRowNum= true
    self.diceNumSp:setVisible(true)
    self.rowNum=self.dice1Num+self.dice2Num
    self.diceNumLb:setString(self.rowNum)
    if (self.dice1Num+self.dice2Num+self.haloPos)>12 then
        self.endIdx =tonumber((self.dice1Num+self.dice2Num+self.haloPos)-12)
    else
        self.endIdx =tonumber(self.dice1Num+self.dice2Num+self.haloPos)
    end

end

function acXingyunpindianDialog:hideFlicker(i)
    if self and self.flickerList then
        for k,v in pairs(self.flickerList) do
            if k==i and v then 
                local sp = tolua.cast(v,"CCSprite")
                if sp then
                    sp:setVisible(false)
                end
            end
        end
    end
end

function acXingyunpindianDialog:playEndEffect( ... )
    self.flickerPosition = acXingyunpindianVoApi:getflickerPosition()
    local partTable={}
    local str = ""
    if self.reward and SizeOfTable(self.reward)>0 then
        str = getlocal("daily_lotto_tip_10")
        for k,v in pairs(self.reward) do
            if v.type=="mm" then
                partTable[k]=v
            end
            if k==SizeOfTable(self.reward) then
                str = str .. v.name .. " x" .. v.num
            else
                str = str .. v.name .. " x" .. v.num .. ","
            end
        end
    end
    if str and str~="" then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
    end

    for k,v in pairs(partTable) do
        if v then
            local pieceSp=CCSprite:createWithSpriteFrameName("BattleParts1.png")
            local icon = self.rewardIconList[v.index]
            pieceSp:setAnchorPoint(ccp(0.5,0.5))
            pieceSp:setPosition(ccp(icon:getPositionX()+50,icon:getPositionY()+50))
            self.bgLayer:addChild(pieceSp,1000)

            local function playEndCallback1()
                pieceSp:removeFromParentAndCleanup(true)
                pieceSp=nil
                self:refresh()

            end
            local callFunc=CCCallFuncN:create(playEndCallback1)

            local function hideLight()
            end
            local callFunc1=CCCallFuncN:create(hideLight)

            local delay=CCDelayTime:create(0.5)
            local mvTo0=CCMoveTo:create(0.5,ccp(self.bgLayer:getContentSize().width-100,G_VisibleSize.height-270))
            local scaleTo=CCScaleTo:create(0.2,2)
            local scaleTo1=CCScaleTo:create(0.3,0.2)

            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(callFunc1)
            acArr:addObject(mvTo0)

            acArr:addObject(scaleTo)
            acArr:addObject(scaleTo1)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            pieceSp:runAction(seq)
        end
    end
    self.isLottery=false
    self.showRowNum= false
    self.diceNumSp:setVisible(false)
    self.btnShow=true
    if self.btnShow==true then
        self.lotteryOneBtn:setEnabled(true)
        self.lotteryTenBtn:setEnabled(true)
    end
    self.touchDialogBg:setIsSallow(false)
    self.inShowFlick =false
    print("end~~~~~~~~~~~~~~~~~~~~~~~~~")
end

function acXingyunpindianDialog:dicePlayTick()
    local pzArr1=CCArray:create()
    local pzArr2=CCArray:create()
    for kk=1,6 do
        local nameStr="DicePlay0"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr1:addObject(frame)
        pzArr2:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(pzArr1)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    local repeatForever=CCRepeatForever:create(animate)
    self.dice1Sp:runAction(repeatForever)

    local animation2=CCAnimation:createWithSpriteFrames(pzArr2)
    animation2:setDelayPerUnit(0.1)
    local animate2=CCAnimate:create(animation2)
    local repeatForever2=CCRepeatForever:create(animate2)
    self.dice2Sp:runAction(repeatForever2)

    --self.tickIndex=5
    self.diceEnd=0
    --base:addNeedRefresh(self)
end

function acXingyunpindianDialog:updateAcTime()
    local acVo=acXingyunpindianVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acXingyunpindianDialog:tick()
    local vo=acXingyunpindianVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    self:updateAcTime()
end

function acXingyunpindianDialog:fastTick()

    if self.playStart==true then
        self.arrowIndex=self.arrowIndex-1
        if self.arrowIndex<=0 then 
            self.arrowIndex=60
            if self.ArrowPlay==false then 
                self.ArrowPlay=true
                self.leftIcon1:setPosition(ccp(30,360))
                self.leftIcon2:setPosition(ccp(30,300))
                self.rightIcon1:setPosition(ccp(self.bgLayer:getContentSize().width-70,390))
                self.rightIcon2:setPosition(ccp(self.bgLayer:getContentSize().width-70,330))
                self.topIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-40,610))
                self.topIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+20,610))
                self.buttomIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-10,80))
                self.buttomIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+50,80))
            else
                self.ArrowPlay=false
                self.leftIcon1:setPosition(ccp(30,390))
                self.leftIcon2:setPosition(ccp(30,330))
                self.rightIcon1:setPosition(ccp(self.bgLayer:getContentSize().width-70,360))
                self.rightIcon2:setPosition(ccp(self.bgLayer:getContentSize().width-70,300))
                self.topIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-10,610))
                self.topIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+50,610))
                self.buttomIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-40,80))
                self.buttomIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+20,80))
            end
        end
    end
    

    
    if self.dicePlay== true and self.canStopAc ==true then
        self.diceEnd=self.diceEnd+1
        if self.diceEnd==60 then 
            local function playEndCallback()
                self.dice1Sp:removeFromParentAndCleanup(true)
                self.dice2Sp:removeFromParentAndCleanup(true)
                self.dice1Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice1Num..".png")
                self.dice1Sp:setAnchorPoint(ccp(0.5,0.5))
                self.dice1Sp:setPosition(ccp(self.backSprite:getContentSize().width/4,self.backSprite:getContentSize().height/2))
                self.dice2Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice2Num..".png")
                self.dice2Sp:setAnchorPoint(ccp(0.5,0.5))
                self.dice2Sp:setPosition(ccp(self.backSprite:getContentSize().width/4*3,self.backSprite:getContentSize().height/2))

                self.backSprite:addChild(self.dice1Sp)
                self.backSprite:addChild(self.dice2Sp)
                self.dicePlay=false
                --base:removeFromNeedRefresh(self)
                local function playDelayEnd()
                    if self.canStopAc ==true then
                        self.flickerPlay=true
                        self:play()
                    end
                end
                local delay=CCDelayTime:create(0.5)
                local callFunc=CCCallFuncN:create(playDelayEnd)
            
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                self.bgLayer:runAction(seq) 
                
            end
            local delay=CCDelayTime:create(0.5)
            local callFunc=CCCallFuncN:create(playEndCallback)
            
            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            self.bgLayer:runAction(seq) 
        end
    elseif self.flickerPlay==true and self.dicePlay ==false and self.canStopAc ==true then
        
        if self.rowNum==nil or (self.rowNum and self.rowNum<=0) then
            do return end
        end
        -- self.tickIndex=self.tickIndex+1
        self.tickInterval=self.tickInterval-1
        if(self.tickInterval<=0)then
            self.tickInterval=self.tickConst
            self.rowNum= self.rowNum-1
            self.diceNumLb:setString(self.rowNum)
            self.haloPos=self.haloPos+1
            local pos = self.haloPos
            if(pos>12)then
                pos=pos-12
            end
            if self.tag==1 then
                if pos==1 then
                    self:hideFlicker(12)
                else
                    self:hideFlicker(pos-1)
                end
                self:showFlicker(pos)
            elseif self.tag==2 then
                if (self.haloPos-1)==self.flickerPosition then
                    self:hideFlicker(self.flickerPosition)
                end
                self:showFlicker(pos)
            end

            if self.rowNum==1 then
                local function playEnd()
                    self.flickerPlay=false
                    --base:removeFromNeedRefresh(self)
                    self.canStopAc =false
                    self:playEndEffect()
                end
                local delay=CCDelayTime:create(0.5)
                local callFunc=CCCallFuncN:create(playEnd)
                
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                self.bgLayer:runAction(seq) 
            end
        end
    end
    if self.callbackEnd ==true then
        self.callbackEnd =false
        self:playEndEffect()
    end
end

function acXingyunpindianDialog:curShowAward( )
    self.dicePlay=false
    self.flickerPlay =false

    if self.dice1Sp then
        self.dice1Sp:stopAllActions()
        self.dice1Sp:removeFromParentAndCleanup(true)
    end
    if self.dice2Sp then
        self.dice2Sp:stopAllActions()
        self.dice2Sp:removeFromParentAndCleanup(true)
    end
    self.dice1Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice1Num..".png")
    self.dice1Sp:setAnchorPoint(ccp(0.5,0.5))
    self.dice1Sp:setPosition(ccp(self.backSprite:getContentSize().width/4,self.backSprite:getContentSize().height/2))
    self.dice2Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice2Num..".png")
    self.dice2Sp:setAnchorPoint(ccp(0.5,0.5))
    self.dice2Sp:setPosition(ccp(self.backSprite:getContentSize().width/4*3,self.backSprite:getContentSize().height/2))

    self.backSprite:addChild(self.dice1Sp)
    self.backSprite:addChild(self.dice2Sp)
    --base:removeFromNeedRefresh(self)
    if self.flickerPlay ==false and self.inShowFlick==false then
        self:hideAllFlicker( )
        self.tickInterval=30
        self.tickConst=30
        self.intervalNum=5--fasttick间隔 3帧一次
        self.haloPos=self.flickerPosition
        self.showRowNum= true
        self.diceNumSp:setVisible(true)
        self.rowNum=self.dice1Num+self.dice2Num
        self.diceNumLb:setString(self.rowNum)
        if (self.dice1Num+self.dice2Num+self.haloPos)>12 then
            self.endIdx =tonumber((self.dice1Num+self.dice2Num+self.haloPos)-12)
        else
            self.endIdx =tonumber(self.dice1Num+self.dice2Num+self.haloPos)
        end
        -- self.flickerPlay=true
    end

    local loopNum = self.rowNum
    for i=1,loopNum do
        self.rowNum= self.rowNum-1
        self.diceNumLb:setString(self.rowNum)
        self.haloPos=self.haloPos+1
        local pos = self.haloPos
        if(pos>12)then
            pos=pos-12
        end
        if self.tag==1 then
            if pos==1 then
                self:hideFlicker(12)
            else
                self:hideFlicker(pos-1)
            end
            self:showFlicker(pos)
        elseif self.tag==2 then
            if (self.haloPos-1)==self.flickerPosition then
                self:hideFlicker(self.flickerPosition)
            end
            self:showFlicker(pos)
        end
        if self.rowNum==1 then
            self.callbackEnd =true
        end
    end
    

    
end
function acXingyunpindianDialog:hideAllFlicker( )
    if self.flickerList and SizeOfTable(self.flickerList)>0 then
        for k,v in pairs(self.flickerList) do
            local flicker = tolua.cast(v,"CCSprite")
            if flicker ~=nil then
                flicker:setVisible(false)
            end
        end
    end
end
function acXingyunpindianDialog:dispose()
    self.rewardIconList=nil
    self.rewardList=nil
    self.flickerList=nil
    self.reward=nil
    self.callbackEnd =false
    self.showRowNum= nil
    self.dicePlay=nil
    self.flickerPlay=nil
    self.btnShow=nil
    self.playStart=nil
    self.isLottery=nil
    self.timeLb=nil
     -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acRepublicHui.plist")
end