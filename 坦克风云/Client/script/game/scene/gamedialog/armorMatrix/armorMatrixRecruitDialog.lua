armorMatrixRecruitDialog=commonDialog:new()

function armorMatrixRecruitDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.state = 0 
    self.currentTag=nil
    self.btnScale=160/205
    return nc
end

function armorMatrixRecruitDialog:doUserHandler()
	self.panelLineBg:setVisible(false)
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


	local startH=G_VisibleSizeHeight-100

    self.checkIndex=1 -- 默认选中普通

	self:initHeader()


    self:initBottom()
    -- eventDispatcher:dispatchEvent("guide.armor.recruit")

end

function armorMatrixRecruitDialog:initTableView()
end

function armorMatrixRecruitDialog:initHeader()
    local posY=G_VisibleSizeHeight-80

    local topBg=CCSprite:createWithSpriteFrameName("armor_arm_bg.png")
    topBg:setAnchorPoint(ccp(0.5,1))
    topBg:setPosition(G_VisibleSizeWidth/2,posY)
    self.bgLayer:addChild(topBg)


    local posTb={ccp(65,posY),ccp(G_VisibleSizeWidth-65,posY)}
    self.downSpTb={}

    for k,v in pairs(posTb) do
        local upSp=CCSprite:createWithSpriteFrameName("armor_arm_up.png")
        self.bgLayer:addChild(upSp,2)
        upSp:setAnchorPoint(CCPointMake(0.5,1))
        upSp:setPosition(v)
        local upSize=upSp:getContentSize()

        
        local downSp=CCSprite:createWithSpriteFrameName("armor_arm_down.png")
        upSp:addChild(downSp)
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

    -- 选择
    local iconPicTb={"armor_recruit_blue.png","armor_recruit_purple.png"}
    local titleTb={getlocal("normal"),getlocal("daily_lotto_tip_6")}
    self.grayTb1={}
    self.grayTb2={}

    self.checkSpTb={}
    self.timteLbTb={}
    local checkPosY=G_VisibleSizeHeight-480
    for i=1,2 do
        local function checkfunc(hd,fn,idx)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
                PlayEffect(audioCfg.mouseClick)
            end

            if self.checkIndex==idx then
                return --  点击本身选中的返回
            end
            -- self.nodeTb[2]
            self.checkIndex=idx
            self:switchNode()
            if idx==2 then
                if otherGuideMgr.isGuiding and otherGuideMgr.curStep==23 then
                    otherGuideMgr:hidingGuild()
                end
            end

        end
        local checkSp=LuaCCSprite:createWithSpriteFrameName(iconPicTb[i],checkfunc)
        self.bgLayer:addChild(checkSp,4)
        checkSp:setTouchPriority(-(self.layerNum-1)*20-4)
        checkSp:setScale(0.8)
        checkSp:setTag(i)
        self.checkSpTb[i]=checkSp

        table.insert(self["grayTb" .. i],checkSp)
        

        local checkSpSize=checkSp:getContentSize()
        local boxPic="armor_recruit_blueBox.png"
        if i==1 then
            checkSp:setPosition(G_VisibleSizeWidth/2-checkSpSize.width/2,checkPosY)
            boxPic="armor_recruit_blueBox.png"
        else
            checkSp:setPosition(G_VisibleSizeWidth/2+checkSpSize.width/2,checkPosY)
            boxPic="armor_recruit_purpleBox.png"
        end

        local boxSp=CCSprite:createWithSpriteFrameName(boxPic)
        checkSp:addChild(boxSp)
        boxSp:setPosition(checkSpSize.width/2,checkSpSize.height/2-28)
        boxSp:setTag(911)

        table.insert(self["grayTb" .. i],boxSp)

        local titleLb=GetTTFLabelWrap(titleTb[i],24/checkSp:getScale(),CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        checkSp:addChild(titleLb)
        titleLb:setPosition(checkSpSize.width/2,checkSpSize.height-50)

        table.insert(self["grayTb" .. i],titleLb)

        local timeSp=LuaCCSprite:createWithSpriteFrameName("armor_recruit_time" .. i .. ".png",checkfunc)
        checkSp:addChild(timeSp)
        timeSp:setAnchorPoint(ccp(0.5,1))
        timeSp:setPosition(checkSpSize.width/2,15)
        timeSp:setTouchPriority(-(self.layerNum-1)*20-4)
        timeSp:setTag(i)

        table.insert(self["grayTb" .. i],timeSp)

        local timeSize=timeSp:getContentSize()
        local sbHei=timeSize.height/4*3-10
        local posTb
        local picTb
        if i==1 then
            posTb={timeSize.width/2-30,timeSize.width/2+30}
            picTb={"equipBg_gray.png","equipBg_green.png"}
        else
            posTb={timeSize.width/2-60,timeSize.width/2,timeSize.width/2+60}
            picTb={"equipBg_green.png","equipBg_blue.png","equipBg_purple.png"}
           
        end
        for k,v in pairs(posTb) do
            local scale=0.5
            local bgSp=CCSprite:createWithSpriteFrameName(picTb[k])
            bgSp:setPosition(v,sbHei)
            timeSp:addChild(bgSp)
            bgSp:setScale(scale)
            table.insert(self["grayTb" .. i],bgSp)

            local qSp=CCSprite:createWithSpriteFrameName("armor_qMark.png")
            bgSp:addChild(qSp)
            qSp:setPosition(getCenterPoint(bgSp))
            qSp:setScale(1/scale*40/qSp:getContentSize().height)
            table.insert(self["grayTb" .. i],qSp)
        end

        local timeLb=GetTTFLabel("",22/checkSp:getScale())
        timeSp:addChild(timeLb)
        timeLb:setPosition(timeSp:getContentSize().width/2,40)
        self.timteLbTb[i]=timeLb
        table.insert(self["grayTb" .. i],timeLb)

        -- if i==2 then
        --     checkSp:setColor(G_ColorGray)
        --     boxSp:setColor(G_ColorGray)
        -- end
    end
    self:setGrayTbColor()

    self:resert() -- 机械臂的初始角度，选择框的初始位置

    if otherGuideMgr.isGuiding==true then
        otherGuideMgr:setGuideStepField(23,self.checkSpTb[2],true)
    end
end

function armorMatrixRecruitDialog:initBottom()
    if(base.hexieMode==1)then
        local reward=FormatItem(armorCfg.mustReward1.reward)
        local rewardStr
        for k,v in pairs(reward) do
            rewardStr=v.name.."×"..v.num
        end
        self.hexieLb=GetTTFLabelWrap(getlocal("armorMatrix_recruit_hexie",{rewardStr}),23,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        self.hexieLb:setPosition(G_VisibleSizeWidth/2,180)
        self.bgLayer:addChild(self.hexieLb)
    end
    local function gotoBagFunc(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
        end

        self:close()
        armorMatrixVoApi:showBagDialog(self.layerNum)
    end

    local function recruitFunc(tag,object)
        if G_checkClickEnable()==false then
            do
                self:switchNode()
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
            PlayEffect(audioCfg.mouseClick)
        end

        local type
        local num
        self.currentTag=tag
        if tag<10 then
            type=1
            num=1
        else
            type=2
            if tag==14 then
                num=10
            else
                num=1
            end
        end
        if type~=self.checkIndex then
            return -- 防止 按住一个按键 切换
        end

        -- 判断仓库是否满了
        local isOver,leftNum=armorMatrixVoApi:bagIsOver(num)

        if isOver then
            self:switchNode()
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage9050"),nil,self.layerNum+1)
            return
        end

        local gems=playerVoApi:getGems()
        local cosumeCost,free=armorMatrixVoApi:getRecruitCost(type,num)

        -- 金币不足
        if cosumeCost>gems then
            self:switchNode()
            local function onSure()
                activityAndNoteDialog:closeAllDialog()
            end
            GemsNotEnoughDialog(nil,nil,cosumeCost-gems,self.layerNum+1,cosumeCost,onSure)
            return
        end
        local function trueRecruit()
            local function refreshCalback(report)
                self.report=report
                playerVoApi:setGems(gems-cosumeCost)
                self:refreshCostLbColor()
                self:setGrayTbColor()
                self:switchNode(1)
                self:startAni()
                if (otherGuideMgr.isGuiding and otherGuideMgr.curStep==21 or otherGuideMgr.curStep==24) then
                    otherGuideMgr:hidingGuild()
                end
                if(base.hexieMode==1)then
                    local award=FormatItem(armorCfg["mustReward"..type].reward)
                    for k,v in pairs(award) do
                        v.num=v.num*num
                        G_addPlayerAward(v.type,v.key,v.id,v.num)
                    end
                    G_showRewardTip(award, true)
                end
            end
            armorMatrixVoApi:armorRecruitData(free,num,type,refreshCalback)
        end
        local function cancleF()
            self:switchNode()
        end
        local function showtip()
            local key="armorMatrix_gem_recruit"
            if G_isPopBoard(key) then
                local function secondTipFunc(flag)
                    local sValue=base.serverTime .. "_" .. flag
                    G_changePopFlag(key,sValue)
                end
                local str
                if(num==1)then
                    str=getlocal("armorMatrix_recruit_des1",{cosumeCost})
                else
                    str=getlocal("second_tip_des",{cosumeCost})
                end
                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),str,true,trueRecruit,secondTipFunc,cancleF)
            else
                trueRecruit()
            end
        end
        
        if num==1 then
            if type==1 then
                if (not free)then
                    showtip()
                else
                    trueRecruit()
                end
            else
                if (not free)then
                    showtip()
                else
                    trueRecruit()
                end
            end
        else
            showtip()
        end
        
    end
    self.recruitFunc=recruitFunc

    -- 仓库
    local menuTab1={pic1="newGreenBtn.png",pic2="newGreenBtn_down.png",lbStr=getlocal("sample_build_name_10"),callback=gotoBagFunc}
    -- 一抽
    local menuTab2={pic1="creatRoleBtn.png",pic2="creatRoleBtn_Down.png",lbStr=getlocal("armorMatrix_getBtnLb",{1}),callback=recruitFunc}
    -- 免费
    local menuTab3={pic1="newGreenBtn.png",pic2="newGreenBtn_down.png",lbStr=getlocal("armorMatrix_getBtnLb",{1}),callback=recruitFunc}

    local menuTab4={pic1="creatRoleBtn.png",pic2="creatRoleBtn_Down.png",lbStr=getlocal("armorMatrix_getBtnLb",{10}),callback=recruitFunc}
    if(base.hexieMode==1)then
        menuTab2.lbStr=getlocal("emblem_getBtnLbHexie",{1})
        menuTab3.lbStr=getlocal("emblem_getBtnLbHexie",{1})
        menuTab4.lbStr=getlocal("emblem_getBtnLbHexie",{10})
    end

    self.recruitItem,self.superbRecruitItem=nil,nil
    local armorCfg=armorMatrixVoApi:getArmorCfg()
    self.nodeTb={}
    local nodeH=150
    self.nodeH=nodeH
    self.freeMenu={}
    self.oneMenu={}
    self.freeTipSpTb={}
    for i=1,2 do
        local node = CCNode:create()
        node:setAnchorPoint(ccp(0.5,0))
        node:setContentSize(CCSizeMake(G_VisibleSizeWidth,nodeH))
        self.nodeTb[i]=node
        node:setPosition(G_VisibleSizeWidth/2,0)
        self.bgLayer:addChild(node,3)
        local nodeSize=node:getContentSize()

        if i==1 then
            for j=1,3 do
                local menuTb
                local pos
                if j==1 then -- 仓库
                    menuTb=menuTab1
                    posX=nodeSize.width/2-150
                elseif j==2 then -- 单招
                    menuTb=menuTab2
                    posX=nodeSize.width/2+150
                else -- 单招免费
                    menuTb=menuTab3
                    posX=nodeSize.width/2+150
                end
                local menuItem=GetButtonItem(menuTb.pic1,menuTb.pic2,menuTb.pic2,menuTb.callback,j,menuTb.lbStr,24/self.btnScale,101)
                menuItem:setScale(self.btnScale)
                local btnLb = menuItem:getChildByTag(101)
                if btnLb then
                    btnLb = tolua.cast(btnLb,"CCLabelTTF")
                    btnLb:setFontName("Helvetica-bold")
                end
                local btnMenu = CCMenu:createWithItem(menuItem)
                node:addChild(btnMenu)
                btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
                btnMenu:setBSwallowsTouches(true)
                btnMenu:setPosition(posX,nodeSize.height/2)

                local menuItemSize=menuItem:getContentSize()
                if j==2 then
                    self.oneMenu[i]=btnMenu

                    local childH=menuItemSize.height+20
                    local expIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
                    menuItem:addChild(expIcon1)
                    expIcon1:setPositionY(childH)
                    expIcon1:setAnchorPoint(ccp(0.5,0.5))
                    expIcon1:setTag(21)
                    expIcon1:setScale(1/self.btnScale)

                    local moneyCost1=armorCfg.moneyCost1
                    local iconLb1=GetTTFLabel(moneyCost1,24/self.btnScale)
                    menuItem:addChild(iconLb1)
                    iconLb1:setPositionY(childH)
                    iconLb1:setAnchorPoint(ccp(0.5,0.5))
                    iconLb1:setTag(22)
                    local gems=playerVoApi:getGems() or 0
                    if moneyCost1>gems then
                        iconLb1:setColor(G_ColorRed)
                    end
                    G_setchildPosX(menuItem,expIcon1,iconLb1)
                elseif j==3 then
                    self.freeMenu[i]=btnMenu

                    local freeLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),24/self.btnScale)
                    menuItem:addChild(freeLb)
                    freeLb:setPosition(menuItemSize.width/2,menuItemSize.height+20)
                    freeLb:setAnchorPoint(ccp(0.5,0.5))
                    freeLb:setColor(G_ColorGreen)

                    if self.freeTipSpTb[i]==nil then
                        local freeTipSp=G_createTipSp(menuItem)
                        self.freeTipSpTb[i]=freeTipSp
                    end
                end
                if j==3 then       
                    self.recruitItem=menuItem
                end
                -- G_setchildPosX(parent,child1,child2)
            end
        else
            for j=1,4 do
                local menuTb
                local pos
                if j==1 then -- 仓库
                    menuTb=menuTab1
                    posX=nodeSize.width/2-200
                elseif j==2 then -- 单招
                    menuTb=menuTab2
                    posX=nodeSize.width/2
                elseif j==3 then -- 单招免费
                    menuTb=menuTab3
                    posX=nodeSize.width/2
                else -- 十抽
                    menuTb=menuTab4
                    posX=nodeSize.width/2+200
                end
                local menuItem=GetButtonItem(menuTb.pic1,menuTb.pic2,menuTb.pic2,menuTb.callback,10+j,menuTb.lbStr,24/self.btnScale,101)
                menuItem:setScale(self.btnScale)
                local btnLb = menuItem:getChildByTag(101)
                if btnLb then
                    btnLb = tolua.cast(btnLb,"CCLabelTTF")
                    btnLb:setFontName("Helvetica-bold")
                end
                local btnMenu = CCMenu:createWithItem(menuItem)
                node:addChild(btnMenu)
                btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
                btnMenu:setBSwallowsTouches(true)
                btnMenu:setPosition(posX,nodeSize.height/2)

                local menuItemSize=menuItem:getContentSize()
                if j==2 or j==4 then
                    local needCost
                    if j==2 then
                        self.oneMenu[i]=btnMenu
                        needCost=armorCfg.moneyCost2
                    else
                        needCost=armorCfg.moneyCost2*10*armorCfg.discount
                    end
                    local childH=menuItemSize.height+20
                    local expIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
                    menuItem:addChild(expIcon1)
                    expIcon1:setPositionY(childH)
                    expIcon1:setAnchorPoint(ccp(0.5,0.5))
                    expIcon1:setTag(21)
                    expIcon1:setScale(1/self.btnScale)

                    local iconLb1=GetTTFLabel(needCost,24/self.btnScale)
                    menuItem:addChild(iconLb1)
                    iconLb1:setPositionY(childH)
                    iconLb1:setAnchorPoint(ccp(0.5,0.5))
                    iconLb1:setTag(22)
                    if j==4 then
                        self.iconLb3=iconLb1
                    end
                    local gems=playerVoApi:getGems() or 0
                    if needCost>gems then
                        iconLb1:setColor(G_ColorRed)
                    end
                    G_setchildPosX(menuItem,expIcon1,iconLb1)
                elseif j==3 then
                    self.freeMenu[i]=btnMenu
                    local freeLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),24/self.btnScale)
                    menuItem:addChild(freeLb)
                    freeLb:setPosition(menuItemSize.width/2,menuItemSize.height+20)
                    freeLb:setAnchorPoint(ccp(0.5,0.5))
                    freeLb:setColor(G_ColorGreen)

                    if self.freeTipSpTb[i]==nil then
                        local freeTipSp=G_createTipSp(menuItem)
                        self.freeTipSpTb[i]=freeTipSp
                    end
                    self.superbRecruitItem=menuItem
                end
            end
        end
    end

    self.nodeTb[2]:setPositionY(-nodeH*2)

    self:refreshBtn()

    if (otherGuideMgr.isGuiding and otherGuideMgr.curStep==20) then
        if self.recruitItem then
            otherGuideMgr:setGuideStepField(21,self.recruitItem,true)
            otherGuideMgr:toNextStep()
        end
    end

    self:refreshSpecialRecruitTip()
end

function armorMatrixRecruitDialog:refreshBtn()
    if self.freeMenu and self.freeMenu[1] then
        local _,freeFlag1,freeNum1,lastTime1=armorMatrixVoApi:getRecruitCost(1,1)
        local _,freeFlag2,freeNum2,lastTime2=armorMatrixVoApi:getRecruitCost(2,1)

        for i=1,2 do
            if i==1 then
                self.freeMenu[i]:setVisible(freeFlag1)
                self.oneMenu[i]:setVisible(not freeFlag1)
                if self.freeTipSpTb[i] then
                    self.freeTipSpTb[i]:setVisible(freeFlag1)
                end
            else
                self.freeMenu[i]:setVisible(freeFlag2)
                self.oneMenu[i]:setVisible(not freeFlag2)
                if self.freeTipSpTb[i] then
                    self.freeTipSpTb[i]:setVisible(freeFlag2)
                end
            end
        end
        if freeNum1>0 then
            self.timteLbTb[1]:setString(getlocal("armorMatrix_free_num",{freeNum1}))
            if self.checkIndex==1 then
                self.timteLbTb[1]:setColor(G_ColorGreen)
            end
        else
            self.timteLbTb[1]:setString(GetTimeForItemStr(lastTime1-base.serverTime))
        end
        if freeNum2>0 then
            self.timteLbTb[2]:setString(getlocal("armorMatrix_free_num",{freeNum2}))
            if self.checkIndex==2 then
                self.timteLbTb[2]:setColor(G_ColorGreen)
            end
        else
            self.timteLbTb[2]:setString(GetTimeForItemStr(lastTime2-base.serverTime))
        end

        if self.oneMoreFreeMenu and self.oneMoreRecruitMenu then
            if self.currentTag>10 then
                self.oneMoreFreeMenu:setVisible(freeFlag2)
                self.oneMoreRecruitMenu:setVisible(not freeFlag2)
            else
                self.oneMoreFreeMenu:setVisible(freeFlag1)
                self.oneMoreRecruitMenu:setVisible(not freeFlag1)
            end
        end
    end
end

function armorMatrixRecruitDialog:refreshCostLbColor()
    local menuItem1=tolua.cast(self.oneMenu[1]:getChildByTag(2),"CCMenuItem")
    local gems=playerVoApi:getGems() or 0

    if menuItem1 then
        local lb=tolua.cast(menuItem1:getChildByTag(22),"CCLabelTTF")
        if lb then
            local costNum=armorMatrixVoApi:getRecruitCost(1,1)
            if costNum>gems then
                lb:setColor(G_ColorRed)
            else
                lb:setColor(G_ColorWhite)
            end
        end
    end

    local menuItem2=tolua.cast(self.oneMenu[2]:getChildByTag(12),"CCMenuItem")
    if menuItem2 then
        local lb=tolua.cast(menuItem2:getChildByTag(22),"CCLabelTTF")
        if lb then
            local costNum=armorMatrixVoApi:getRecruitCost(2,1)
            if costNum>gems then
                lb:setColor(G_ColorRed)
            else
                lb:setColor(G_ColorWhite)
            end
        end
    end

    if self.iconLb3 then
        local costNum=armorMatrixVoApi:getRecruitCost(2,10)
        if costNum>gems then
            self.iconLb3:setColor(G_ColorRed)
        else
            self.iconLb3:setColor(G_ColorWhite)
        end
    end

end

--高级招募必出矩阵提示
function armorMatrixRecruitDialog:refreshSpecialRecruitTip()
    if FuncSwitchApi:isEnabled("armor_lottery_yh") == false then --怀旧服不做该优化，在这里做一下特殊处理
        do return end
    end
    if self.specialRecruitTip then
        self.specialRecruitTip:removeFromParentAndCleanup(true)
        self.specialRecruitTip=nil
    end
    if self.checkIndex ~= 2 then
        do return end
    end
    local matrixInfo  = armorMatrixVoApi:getArmorMatrixInfo()
    local rtimes = armorCfg.times
    if matrixInfo and matrixInfo.rtimes then
        if tonumber(matrixInfo.rtimes) > armorCfg.times then
            rtimes = armorCfg.times - (tonumber(matrixInfo.rtimes) - armorCfg.times)
        else
            rtimes = armorCfg.times - tonumber(matrixInfo.rtimes or 0)
        end
        if rtimes < 0 then
            rtimes = 0
        end
    end
    local specialRecruitTip,lbHeight=G_getRichTextLabel(getlocal("armor_special_rewardtip",{rtimes}),{G_ColorPurple,G_ColorYellowPro,G_ColorPurple},G_getLS(25,22),G_VisibleSizeWidth-60,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    specialRecruitTip:setAnchorPoint(ccp(0.5,1))
    specialRecruitTip:setPosition(G_VisibleSizeWidth/2,220+lbHeight/2)
    self.bgLayer:addChild(specialRecruitTip)
    self.specialRecruitTip = specialRecruitTip
end

function armorMatrixRecruitDialog:switchNode(flag)

    self:refreshSpecialRecruitTip()

    local time=0.3
    local function moveTunc(pos,targetSp,callback)
        local moveTo=CCMoveTo:create(time,pos)
        local fadeAc
        if pos.y<0 then
            fadeAc=CCFadeOut:create(time)
        else
            fadeAc=CCFadeIn:create(time)
        end
        local acArray=CCArray:create()
        acArray:addObject(moveTo)
        acArray:addObject(fadeAc)
        local acSpawn=CCSpawn:create(acArray)

        local function moveEnd()
            if callback then
                callback()
            end
        end
        local seq=CCSequence:createWithTwoActions(acSpawn,CCCallFunc:create(moveEnd))
        targetSp:runAction(seq)
       
    end
    local pos1=ccp(G_VisibleSizeWidth/2,-self.nodeH*2)
    local pos2=ccp(G_VisibleSizeWidth/2,0)

    -- 抽奖
    if flag then
        -- 闭合（消失）
        if flag==1 then
            moveTunc(pos1,self.nodeTb[self.checkIndex])
        else -- 展开
            moveTunc(pos2,self.nodeTb[self.checkIndex])
        end
        return
    end

    -- 选择普通或者高级
    if self.checkIndex==1 then
        -- self.checkSpTb[1]:setColor(G_ColorWhite)
        -- self.checkSpTb[2]:setColor(G_ColorGray)

        -- local boxSp1=tolua.cast(self.checkSpTb[1]:getChildByTag(911),"CCSprite")
        -- if boxSp1 then
        --     boxSp1:setColor(G_ColorWhite)
        -- end
        -- local boxSp2=tolua.cast(self.checkSpTb[2]:getChildByTag(911),"CCSprite")
        -- if boxSp2 then
        --     boxSp2:setColor(G_ColorGray)
        -- end

        -- self:runSelectAc(self.checkSpTb[1])
        -- self:deleteSelectAc(self.checkSpTb[2])

        moveTunc(pos2,self.nodeTb[1])
        moveTunc(pos1,self.nodeTb[2])
    else
        -- self.checkSpTb[1]:setColor(G_ColorGray)
        -- self.checkSpTb[2]:setColor(G_ColorWhite)

        -- local boxSp1=tolua.cast(self.checkSpTb[1]:getChildByTag(911),"CCSprite")
        -- if boxSp1 then
        --     boxSp1:setColor(G_ColorGray)
        -- end
        -- local boxSp2=tolua.cast(self.checkSpTb[2]:getChildByTag(911),"CCSprite")
        -- if boxSp2 then
        --     boxSp2:setColor(G_ColorWhite)
        -- end

        -- self:runSelectAc(self.checkSpTb[2])
        -- self:deleteSelectAc(self.checkSpTb[1])
        local function moveEnd()
            if otherGuideMgr.isGuiding and otherGuideMgr.curStep==23 then
                otherGuideMgr:setGuideStepField(24,self.superbRecruitItem)
                otherGuideMgr:toNextStep()
            end
        end
        moveTunc(pos1,self.nodeTb[1])
        moveTunc(pos2,self.nodeTb[2],moveEnd)
    end
    if(self.hexieLb)then
        local reward=FormatItem(armorCfg["mustReward"..self.checkIndex].reward)
        local rewardStr
        for k,v in pairs(reward) do
            rewardStr=v.name.."×"..v.num
        end
        self.hexieLb:setString(getlocal("armorMatrix_recruit_hexie",{rewardStr}))
    end
    self:setGrayTbColor()    
end

function armorMatrixRecruitDialog:startAni()
    self.state=2
    self.touchDialogBg:setIsSallow(true)

    if self.checkIndex==1 then
        self.checkSpTb[2]:setVisible(false)
    else
        self.checkSpTb[1]:setVisible(false)
    end

    local timeSp=self.checkSpTb[self.checkIndex]:getChildByTag(self.checkIndex)
    if timeSp then
        timeSp:setVisible(false)
    end

    self:beginAction()
end

function armorMatrixRecruitDialog:endAni()
    self.state=0
    self.touchDialogBg:setIsSallow(false)
    local checkSp=self.checkSpTb[self.checkIndex]
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

function armorMatrixRecruitDialog:beginAction()
    local checkSp=self.checkSpTb[self.checkIndex]
    local posY=checkSp:getPositionY()

    local acArray=CCArray:create()

    local acMove=CCMoveTo:create(0.2,CCPointMake(G_VisibleSizeWidth/2,posY))
    acArray:addObject(acMove)

    local acScale1=CCScaleTo:create(0.2,1.2)
    acArray:addObject(acScale1)

    local acScale2=CCScaleTo:create(0.1,1)
    acArray:addObject(acScale2)

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

function armorMatrixRecruitDialog:resert()
    for i=1,2 do
        self.downSpTb[i]:stopAllActions()
        self.checkSpTb[i]:setScale(0.8)
        self.checkSpTb[i]:setVisible(true)
        self.checkSpTb[i]:stopAllActions()
    end

    self.downSpTb[1]:setRotation(90)
    self.downSpTb[2]:setRotation(-90)

    local checkSize=self.checkSpTb[1]:getContentSize()
    self.checkSpTb[1]:setPositionX(G_VisibleSizeWidth/2-checkSize.width/2)
    self.checkSpTb[2]:setPositionX(G_VisibleSizeWidth/2+checkSize.width/2)
    local timeSp=self.checkSpTb[self.checkIndex]:getChildByTag(self.checkIndex)
    if timeSp then
        timeSp:setVisible(true)
    end
    local boxSp=tolua.cast(self.checkSpTb[self.checkIndex]:getChildByTag(911),"CCSprite")
    if boxSp then
        boxSp:setVisible(true)
    end


end

function armorMatrixRecruitDialog:showOneSerch(report)
    local layerNum=self.layerNum+1
    -- self.currentTag
    local checkSp
    if self.currentTag>10 then
        checkSp=self.checkSpTb[2]
    else
        checkSp=self.checkSpTb[1]
    end

    if self.myLayer==nil then
        self.myLayer=CCLayer:create()
        self.bgLayer:addChild(self.myLayer,10)
    else
        self.myLayer:removeFromParentAndCleanup(true)
        self.myLayer=nil
        self.myLayer=CCLayer:create()
        self.bgLayer:addChild(self.myLayer,10)
    end

    -- local function endCallback()
    -- end
    -- local diPic = "public/superWeapon/weaponBg.jpg"
    -- local sceneSp=LuaCCSprite:createWithFileName(diPic,endCallback)
    -- sceneSp:setAnchorPoint(ccp(0,0))
    -- sceneSp:setPosition(ccp(0,0))
    -- sceneSp:setTouchPriority(-(layerNum-1)*20-1)
    -- self.myLayer:addChild(sceneSp)
    -- sceneSp:setColor(ccc3(150, 150, 150))
    -- sceneSp:setTouchPriority(-(self.layerNum-1)*20-10)

    -- sceneSp:setScaleY(G_VisibleSizeHeight/sceneSp:getContentSize().height)
    -- sceneSp:setScaleX(G_VisibleSizeWidth/sceneSp:getContentSize().width)

    local layer = CCLayer:create()
    self.myLayer:addChild(layer,2)
    layer:setTouchEnabled(true)
    layer:setBSwallowsTouches(true)
    layer:setTouchPriority(-(layerNum-1)*20-1)


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
        local function callback1()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self.oneMoreFreeMenu=nil
            self.oneMoreRecruitMenu=nil
            self.myLayer:removeFromParentAndCleanup(true)
            self.myLayer=nil
            self:refreshBox()
            self:switchNode(2)
            self:resert()
        end

        local function callback2()
            self.oneMoreFreeMenu=nil
            self.oneMoreRecruitMenu=nil
            self.myLayer:removeFromParentAndCleanup(true)
            self.myLayer=nil
            self:refreshBox()
            self:resert()
            self.recruitFunc(self.currentTag)
        end

        local freeMenu,recruitMenu,sureMenu,freeItem,recruitItem,sureItem=self:addBtnMenu(layer,callback1,callback2,layerNum)
        freeMenu:setPosition(G_VisibleSizeWidth/2+150,80)
        recruitMenu:setPosition(G_VisibleSizeWidth/2+150,80)
        sureMenu:setPosition(G_VisibleSizeWidth/2-150,80)


        self.oneMoreFreeMenu=freeMenu
        self.oneMoreRecruitMenu=recruitMenu

        self:refreshBtn()


        local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",callback1,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))

        local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSize.height)
        local closeBtn = CCMenu:createWithItem(closeBtnItem)
        closeBtn:setTouchPriority(-(layerNum-1)*20-4)
        closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
        self.myLayer:addChild(closeBtn)

        if (otherGuideMgr.isGuiding and otherGuideMgr.curStep==21 or otherGuideMgr.curStep==24) then
            local nextStepId=otherGuideCfg[otherGuideMgr.curStep].toStepId
            otherGuideMgr:setGuideStepField(nextStepId,sureItem)
            otherGuideMgr:toNextStep()
        end
    end
    local callFunc=CCCallFunc:create(endAc)
    acArray:addObject(callFunc)

    local seq=CCSequence:create(acArray)

    icon:runAction(seq)

end

function armorMatrixRecruitDialog:showTenSearch(report,time)

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
        -- if self.isAction==false then
        --     self.isAction=true
        --     for k,v in pairs(iconSpTb) do
        --         v:stopAllActions()
        --         v:setScale(100/v:getContentSize().width)
        --     end
        --     for k,v in pairs(guangSpTb) do
        --         v[1]:stopAllActions()
        --         v[1]:setScale(1.6)
        --         local rotateBy = CCRotateBy:create(4,360)
        --         local reverseBy = rotateBy:reverse()
        --         v[1]:runAction(CCRepeatForever:create(reverseBy))

        --         v[2]:stopAllActions()
        --         v[2]:setScale(1.6)
        --         local rotateBy = CCRotateBy:create(4,360)
        --         v[2]:runAction(CCRepeatForever:create(rotateBy))
        --     end
        --     local menu=layer:getChildByTag(101)
        --     if menu then
        --         menu:setVisible(true)
        --     end

        -- end
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

    -- local diPic = "public/superWeapon/weaponBg.jpg"
    -- if scenePic then
    --     diPic = scenePic
    -- end
    -- local sceneSp=LuaCCSprite:createWithFileName(diPic,endCallback)
    -- sceneSp:setAnchorPoint(ccp(0,0))
    -- sceneSp:setPosition(ccp(0,0))
    -- sceneSp:setTouchPriority(-(layerNum-1)*20-1)
    -- self.myLayer:addChild(sceneSp)
    -- sceneSp:setColor(ccc3(150, 150, 150))
    -- sceneSp:setTouchPriority(-(self.layerNum-1)*20-10)

    -- sceneSp:setScaleY(G_VisibleSizeHeight/sceneSp:getContentSize().height)
    -- sceneSp:setScaleX(G_VisibleSizeWidth/sceneSp:getContentSize().width)

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
        if v.type=="am" then
            if v.key~="exp" then
                local cfg=armorMatrixVoApi:getCfgByMid(v.key)
                local color=armorMatrixVoApi:getColorByQuality(cfg.quality)
                nameLb:setColor(color)

                if cfg.quality>=4 then
                    flag=true
                end
            end
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
        print("callback1-------->")
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self.myLayer:removeFromParentAndCleanup(true)
        self.myLayer=nil
        self:refreshBox()
        self:switchNode(2)
        self:resert()
    end
    local function callback2()
        self.myLayer:removeFromParentAndCleanup(true)
        self.myLayer=nil
        self:refreshBox()
        self:resert()
        self.recruitFunc(14)
    end
    local menuItem={}
    menuItem[1]=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callback1,nil,getlocal("confirm"),24/self.btnScale,101)
    if(base.hexieMode==1)then
        menuItem[2]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",callback2,nil,getlocal("armorMatrix_getBtnLb",{10}),24/self.btnScale,101)
    else
        menuItem[2]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",callback2,nil,getlocal("emblem_getBtnLbHexie",{10}),24/self.btnScale,101)
    end
    menuItem[1]:setScale(self.btnScale)
    menuItem[2]:setScale(self.btnScale)
    
    local btnLb = menuItem[1]:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local btnLb = menuItem[2]:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end

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
    local costLb=GetTTFLabel(costNum .. "  ",24/self.btnScale)
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
    goldIcon:setScale(1/self.btnScale)

    costLb:setPosition(menuItem[2]:getContentSize().width/2-(costLb:getContentSize().width+goldIcon:getContentSize().width)/2,costLbPosY)

    self.isAction = false

    btnMenu:setVisible(false)

    if time then
        endCallback()
    end
end

function armorMatrixRecruitDialog:addBtnMenu(parent,callback1,callback2,layerNum)

    local function onSure()
        print("onSure-------->")
        if callback1 then
            callback1()
        end
        if otherGuideMgr.isGuiding and (otherGuideMgr.curStep==22 or  otherGuideMgr.curStep==25)then
            otherGuideMgr:toNextStep()
        end
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onSure,nil,getlocal("confirm"),24/self.btnScale,101)
    sureItem:setScale(self.btnScale)
    local btnLb = sureItem:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    
    local sureMenu = CCMenu:createWithItem(sureItem)
    parent:addChild(sureMenu)
    sureMenu:setTouchPriority(-(layerNum-1)*20-4)
    sureMenu:setBSwallowsTouches(true)

    local function onRecruit()
        if otherGuideMgr.isGuiding and (otherGuideMgr.curStep==21 or  otherGuideMgr.curStep==24)then
            otherGuideMgr:toNextStep()
        end
        if callback2 then
            callback2()
        end
    end
    local freeItem
    if(base.hexieMode==1)then
        freeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onRecruit,nil,getlocal("emblem_getBtnLbHexie",{1}),24/self.btnScale,101)
    else
        freeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onRecruit,nil,getlocal("armorMatrix_getBtnLb",{1}),24/self.btnScale,101)
    end
    freeItem:setScale(self.btnScale)
    local btnLb = freeItem:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    
    local freeMenu = CCMenu:createWithItem(freeItem)
    parent:addChild(freeMenu)
    freeMenu:setTouchPriority(-(layerNum-1)*20-4)
    freeMenu:setBSwallowsTouches(true)

    local menuItemSize=freeItem:getContentSize()
    local childH=menuItemSize.height+20

    local freeLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),24/self.btnScale)
    freeItem:addChild(freeLb)
    freeLb:setPosition(menuItemSize.width/2,menuItemSize.height+20)
    freeLb:setAnchorPoint(ccp(0.5,0.5)) 

    local freeTipSp=G_createTipSp(freeItem)
    freeTipSp:setVisible(true)

    local recruitItem
    if(base.hexieMode==1)then
        recruitItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onRecruit,nil,getlocal("emblem_getBtnLbHexie",{1}),24/self.btnScale,101)
    else
        recruitItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onRecruit,nil,getlocal("armorMatrix_getBtnLb",{1}),24/self.btnScale,101)
    end
    recruitItem:setScale(self.btnScale)
    local btnLb = recruitItem:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local recruitMenu = CCMenu:createWithItem(recruitItem)
    parent:addChild(recruitMenu)
    recruitMenu:setTouchPriority(-(layerNum-1)*20-4)
    recruitMenu:setBSwallowsTouches(true)

    local expIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
    recruitItem:addChild(expIcon1)
    expIcon1:setPositionY(childH)
    expIcon1:setAnchorPoint(ccp(0.5,0.5))
    expIcon1:setTag(21)
    expIcon1:setScale(1/self.btnScale)

    local needCost
    if self.currentTag<10 then
        needCost=armorMatrixVoApi:getRecruitCost(1,1)
    else
        needCost=armorMatrixVoApi:getRecruitCost(2,1)
    end
    local iconLb1=GetTTFLabel(needCost,24/self.btnScale)
    recruitItem:addChild(iconLb1)
    iconLb1:setPositionY(childH)
    iconLb1:setAnchorPoint(ccp(0.5,0.5))
    iconLb1:setTag(22)
    local gems=playerVoApi:getGems() or 0
    if needCost>gems then
        iconLb1:setColor(G_ColorRed)
    end
    G_setchildPosX(recruitItem,expIcon1,iconLb1)
    local gems=playerVoApi:getGems() or 0
    if needCost>gems then
        iconLb1:setColor(G_ColorRed)
    end

    return freeMenu,recruitMenu,sureMenu,freeItem,recruitItem,sureItem
end

function armorMatrixRecruitDialog:refreshBox()
    -- local boxSp=tolua.cast(self.checkSpTb[self.checkIndex]:getChildByTag(911),"CCSprite")
    -- if boxSp then
    --     boxSp:setVisible(true)
    -- end
end



function armorMatrixRecruitDialog:runSelectAc(parentBg)
    local pzFrameName="armor_recruit_select1.png"
    local metalSp1=CCSprite:createWithSpriteFrameName(pzFrameName)
    metalSp1:setAnchorPoint(ccp(0.5,0.5))
    metalSp1:setPosition(getCenterPoint(parentBg))
    parentBg:addChild(metalSp1,4)
    metalSp1:setTag(2001)
    metalSp1:setVisible(false)

    local metalSp2=CCSprite:createWithSpriteFrameName("armor_recruit_select2.png")
    metalSp2:setAnchorPoint(ccp(0.5,0.5))
    metalSp2:setPosition(getCenterPoint(parentBg))
    parentBg:addChild(metalSp2,4)
    metalSp2:setTag(2002) 
    metalSp2:setVisible(false)

    local function visivleFunc(target,visivle)
        target:setVisible(visivle)
    end

    local function callback1()
        visivleFunc(metalSp1,true)
    end
    local callFunc1=CCCallFunc:create(callback1)
    local delay1=CCDelayTime:create(0.08)

    local function callback2()
        visivleFunc(metalSp1,false)
    end
    local callFunc2=CCCallFunc:create(callback2)
    local delay2=CCDelayTime:create(0.08)

    local function callback3()
        visivleFunc(metalSp2,true)
    end
    local callFunc3=CCCallFunc:create(callback3)
    local delay3=CCDelayTime:create(0.08)

    local function callback4()
        visivleFunc(metalSp2,false)
    end
    local callFunc4=CCCallFunc:create(callback4)
    local delay4=CCDelayTime:create(1)

    local acArr=CCArray:create()
    acArr:addObject(callFunc1)
    acArr:addObject(delay1)
    acArr:addObject(callFunc2)
    acArr:addObject(delay2)
    acArr:addObject(callFunc3)
    acArr:addObject(delay3)
    acArr:addObject(callFunc4)
    acArr:addObject(delay4)
    
    local seq=CCSequence:create(acArr)
    local repeatForever=CCRepeatForever:create(seq)
    repeatForever:setTag(100)

    parentBg:runAction(repeatForever)

end
function armorMatrixRecruitDialog:deleteSelectAc(parentBg)
    parentBg:stopActionByTag(100)

    local child = parentBg:getChildByTag(2001)
    if child then
        child:removeFromParentAndCleanup(true)
    end
    local child = parentBg:getChildByTag(2002)
    if child then
        child:removeFromParentAndCleanup(true)
    end
end

function armorMatrixRecruitDialog:setGrayTbColor()
    if self.checkIndex==1 then
        for k,v in pairs(self.grayTb2) do
            if v then
                v:setColor(G_ColorGray)
            end
            if self.grayTb1[k] then
                self.grayTb1[k]:setColor(G_ColorWhite)
            end
        end
    else
        for k,v in pairs(self.grayTb2) do
            if v then
                v:setColor(G_ColorWhite)
            end
            if self.grayTb1[k] then
                self.grayTb1[k]:setColor(G_ColorGray)
            end
        end
    end
    self:refreshBtn()
end


function armorMatrixRecruitDialog:fastTick()
    if self.state==3 then
        self:endAni()
    end      
end


function armorMatrixRecruitDialog:tick()
   self:refreshBtn()
end

function armorMatrixRecruitDialog:dispose()
    self.recruitItem=nil
    self.superbRecruitItem=nil
    self.specialRecruitTip = nil
end

