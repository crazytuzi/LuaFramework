alienTechDialogTab2={}

function alienTechDialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv1=nil
    self.tv2=nil
    self.iconBgTab={}
    self.selectIndex=1


    self.normalHeight=100
    self.extendSpTag=113
    self.expandIdx={}
    self.expandHeight={}
    self.expandIconBgTab={}

    return nc
end

function alienTechDialogTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initBg()
    self:initTableView1()
    self:initTableView2()
    return self.bgLayer
end

function alienTechDialogTab2:initBg()
    local function click(hd,fn,idx)
    end
    for i=1,2 do
        -- if self.bgSprieTab[i] then
        --  self.bgSprieTab[i]:setVisible(true)
        -- else
            local bgSprie
            if i==1 then
                bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
                bgSprie:setContentSize(CCSizeMake(140, self.bgLayer:getContentSize().height-200))
                bgSprie:setPosition(ccp(30,30))
            elseif i==2 then
            --     -- bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),click)
            --     bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
            --     bgSprie:setContentSize(CCSizeMake(440, 80))
            --     bgSprie:setPosition(ccp(170,self.bgLayer:getContentSize().height-250))
            -- elseif i==3 then
            --     -- bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
                bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
                bgSprie:setContentSize(CCSizeMake(440, self.bgLayer:getContentSize().height-280+80))
                bgSprie:setPosition(ccp(170,30))
            end
            bgSprie:ignoreAnchorPointForPosition(false)
            bgSprie:setIsSallow(false)
            bgSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            bgSprie:setAnchorPoint(ccp(0,0))
            self.bgLayer:addChild(bgSprie,1)

            if i==1 then
                local iScale=1.3
                local upIcon=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
                upIcon:setAnchorPoint(ccp(0.5,0.5))
                upIcon:setPosition(ccp(bgSprie:getContentSize().width/2,bgSprie:getContentSize().height-upIcon:getContentSize().width))
                upIcon:setScale(iScale)
                upIcon:setRotation(90)
                bgSprie:addChild(upIcon,1)

                local downIcon=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
                downIcon:setAnchorPoint(ccp(0.5,0.5))
                downIcon:setPosition(ccp(bgSprie:getContentSize().width/2,downIcon:getContentSize().width))
                downIcon:setScale(iScale)
                downIcon:setRotation(-90)
                bgSprie:addChild(downIcon,1)
            -- elseif i==2 then
            --     local treeCfg=alienTechVoApi:getTreeCfg()
            --     local cfg=treeCfg[self.selectIndex]
            --     local str=getlocal("alien_tech_class_point",{0,cfg.totalPoint})
            --     self.totalPointLb=GetTTFLabelWrap(str,25,CCSizeMake(420,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            --     self.totalPointLb:setAnchorPoint(ccp(0.5,0.5))
            --     -- self.totalPointLb:setColor(G_ColorYellowPro)
            --     self.totalPointLb:setPosition(getCenterPoint(bgSprie))
            --     bgSprie:addChild(self.totalPointLb,2)
            end
            
        --  table.insert(self.bgSprieTab,i,bgSprie)
        -- end
    end
end

function alienTechDialogTab2:initTableView1()
    local function callBack1(...)
        return self:eventHandler1(...)
    end
    local hd= LuaEventHandler:createHandler(callBack1)
    self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(130,self.bgLayer:getContentSize().height-230-160),nil)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv1:setPosition(ccp(35,50+80))
    self.bgLayer:addChild(self.tv1,2)
    self.tv1:setMaxDisToBottomOrTop(120)

end

function alienTechDialogTab2:initTableView2()
    local function callBack2(...)
       return self:eventHandler2(...)
    end
    local hd= LuaEventHandler:createHandler(callBack2)
    self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(430,self.bgLayer:getContentSize().height-300+80),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(175,40))
    self.bgLayer:addChild(self.tv2,2)
    self.tv2:setMaxDisToBottomOrTop(120)

end


function alienTechDialogTab2:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local treeCfg=alienTechVoApi:getTreeCfg()
        return SizeOfTable(treeCfg)
    elseif fn=="tableCellSizeForIndex" then
        local treeCfg=alienTechVoApi:getTreeCfg()
        local tmpSize=CCSizeMake(130,120)
        if idx==0 or idx==4 then
            tmpSize=CCSizeMake(130,120+60)
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        -- if idx==0 or idx==5 then
            local labelFontSize=24
            local tStr=""
            if idx==0 then
                tStr=getlocal("alien_tech_common_tank")
            elseif idx==4 then
                tStr=getlocal("alien_tech_special_tank")
            end
            if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
                labelFontSize=24
            else
                labelFontSize=22
            end
            local tLabel=GetTTFLabelWrap(tStr,labelFontSize,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
            tLabel:setAnchorPoint(ccp(0.5,0.5))
            tLabel:setColor(G_ColorYellowPro)
            tLabel:setPosition(ccp(130/2,60/2+120))
            cell:addChild(tLabel,2)
        --  do return cell end
        -- end

        local treeCfg=alienTechVoApi:getTreeCfg()
        local cfg=treeCfg[idx+1]

        -- local rect = CCRect(0, 0, 50, 50);
        -- local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick1()
            if self.tv1 and self.tv1:getScrollEnable()==true and self.tv1:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                self:cellClick1(idx)
            end
        end
        -- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
        -- backSprie:setContentSize(CCSizeMake(130-40,115-40))
        -- backSprie:ignoreAnchorPointForPosition(false);
        -- backSprie:setAnchorPoint(ccp(0,0));
        -- backSprie:setTag(idx)
        -- backSprie:setIsSallow(false)
        -- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        -- backSprie:setPosition(ccp(0+15,5+20));
        -- cell:addChild(backSprie,2)

        local tid=cfg.pic
        local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
        -- local iconStr=tankCfg[id].icon
        -- local iconStr=cfg.pic
        local tankSp=G_getTankPic(id,cellClick1)
        -- local tankSp=LuaCCSprite:createWithSpriteFrameName(iconStr,cellClick1)
        if tankSp then
            tankSp:setScale(0.6)
            tankSp:setTouchPriority(-(self.layerNum-1)*20-2)
            tankSp:setPosition(ccp(130/2,120/2))
            cell:addChild(tankSp,2)
        end


        local iconBg=CCSprite:createWithSpriteFrameName("LanguageSelectBtn.png")
        iconBg:setPosition(ccp(65,60))
        cell:addChild(iconBg,1)
        table.insert(self.iconBgTab,idx+1,iconBg)
        iconBg:setVisible(false)

        if (idx+1)==self.selectIndex then
            iconBg:setVisible(true)
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

function alienTechDialogTab2:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local treeCfg=alienTechVoApi:getTreeCfg()
        local cfg=treeCfg[self.selectIndex]
        return SizeOfTable(cfg.desc)
    elseif fn=="tableCellSizeForIndex" then
        if self.expandIdx[self.selectIndex] and self.expandIdx[self.selectIndex]["k"..idx]~=nil then
            local expandHeight=self:getExpandHeight(idx)
            tmpSize=CCSizeMake(430,expandHeight)
        else
            tmpSize=CCSizeMake(430,self.normalHeight)
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        
        -- local rect = CCRect(0, 0, 50, 50);
        -- local capInSet = CCRect(20, 20, 10, 10);
        -- local function cellClick(hd,fn,idx)
        --  -- return self:cellClick(idx)
        -- end
        -- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
        -- backSprie:setContentSize(CCSizeMake(430,115))
        -- backSprie:ignoreAnchorPointForPosition(false);
        -- backSprie:setAnchorPoint(ccp(0,0));
        -- backSprie:setTag(idx)
        -- backSprie:setIsSallow(false)
        -- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        -- backSprie:setPosition(ccp(0,5));
        -- cell:addChild(backSprie,1)


        local cellWidth=430

        local treeCfg=alienTechVoApi:getTreeCfg()
        local cfg=treeCfg[self.selectIndex]
        local tid=cfg.desc[idx+1]
        local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
        local slotTb,totalPoint=alienTechVoApi:getSlotByTank(tid)
        local usedPoint=0
        for k,v in pairs(slotTb) do
            if v and type(v)=="string" then
                if k<=4 then
                    usedPoint=usedPoint+1
                else
                    if alienTechVoApi:getTechIsUnlock(v,self.selectIndex,true)==true then
                        usedPoint=usedPoint+1
                    end
                end
            end
        end

        
        local expanded=false
        if self.expandIdx[self.selectIndex] and self.expandIdx[self.selectIndex]["k"..idx]~=nil then
            expanded=true
        end
        if expanded then
            local expandHeight=self:getExpandHeight(idx)
            cell:setContentSize(CCSizeMake(cellWidth, expandHeight))
        else
            cell:setContentSize(CCSizeMake(cellWidth, self.normalHeight))
        end
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);

        local function cellClick2(hd,fn,idx)
            return self:cellClick2(idx)
        end
        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick2)
        headerSprie:setContentSize(CCSizeMake(cellWidth, self.normalHeight-4))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)


        if tankCfg[id].icon and tankCfg[id].icon~="" then
            local sprite = tankVoApi:getTankIconSp(id)
            sprite:setAnchorPoint(ccp(0,0.5));
            sprite:setPosition(10,headerSprie:getContentSize().height/2)
            sprite:setScale(0.5)
            headerSprie:addChild(sprite,2)
        end

        
        local isShowGai,tankGaiId=alienTechVoApi:getIsShowTankGai({tid})
        local str=getlocal(tankCfg[id].name)
        if isShowGai==true and tankGaiId then
            local tGaiId=(tonumber(tankGaiId) or tonumber(RemoveFirstChar(tankGaiId)))
            if tankCfg[tGaiId] then
                local tankGaiName=getlocal(tankCfg[tGaiId].name)
                str=str.."/"..tankGaiName
            end
        end
        -- local lbName=GetTTFLabel(str,20)
        -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local lbName=GetTTFLabelWrap(str,24,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        lbName:setPosition(90,headerSprie:getContentSize().height/2+22)
        lbName:setAnchorPoint(ccp(0,0.5))
        headerSprie:addChild(lbName,2)
        lbName:setColor(G_ColorGreen)

        
        str=getlocal("alien_tech_skill_point",{usedPoint,totalPoint})
        -- local lbPoint=GetTTFLabel(str,20)
        -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local lbPoint=GetTTFLabelWrap(str,20,CCSizeMake(260,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        lbPoint:setPosition(90,headerSprie:getContentSize().height/2-22)
        lbPoint:setAnchorPoint(ccp(0,0.5));
        headerSprie:addChild(lbPoint,2)

          

        --显示加减号
        local btn
        if expanded==false then
            btn=CCSprite:createWithSpriteFrameName("sYellowAddBtn.png")
        else
            btn=CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
        end
        btn:setScale(0.8)
        btn:setAnchorPoint(ccp(0,0.5))
        btn:setPosition(ccp(headerSprie:getContentSize().width-10-btn:getContentSize().width,headerSprie:getContentSize().height*0.5))
        headerSprie:addChild(btn)
        btn:setTag(self.extendSpTag)

        if expanded==true then --显示展开信息
            self:initExpand(idx,cell)
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

function alienTechDialogTab2:initExpand(idx,cell)
    if cell then
        local cellWidth=430

        local treeCfg=alienTechVoApi:getTreeCfg()
        local cfg=treeCfg[self.selectIndex]
        local tid=cfg.desc[idx+1]
        local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
        local slotTb,totalPoint=alienTechVoApi:getSlotByTank(tid)

        local expandHeight=self:getExpandHeight(idx)

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function touchHander()

        end
        local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
        exBg:setAnchorPoint(ccp(0,0))
        exBg:setContentSize(CCSize(cellWidth,expandHeight-self.normalHeight-5))
        exBg:setPosition(ccp(0,5))
        exBg:setTag(2)
        cell:addChild(exBg)

        local bgWidth,bgHeight=exBg:getContentSize().width,exBg:getContentSize().height

        local bgSpaceX=4.7
        local boxBg1=CCSprite:createWithSpriteFrameName("alienTechBoxBg.png")
        boxBg1:setAnchorPoint(ccp(1,0))
        boxBg1:setRotation(180)
        boxBg1:setPosition(ccp(bgWidth/2+bgSpaceX,bgHeight))
        exBg:addChild(boxBg1)
        local boxBg12=CCSprite:createWithSpriteFrameName("alienTechBoxBg.png")
        boxBg12:setAnchorPoint(ccp(1,0))
        boxBg12:setRotation(180)
        boxBg12:setPosition(ccp(0-bgSpaceX,bgHeight))
        exBg:addChild(boxBg12)
        boxBg12:setFlipX(true)

        local boxBg2=CCSprite:createWithSpriteFrameName("alienTechBoxBg.png")
        boxBg2:setAnchorPoint(ccp(1,0))
        boxBg2:setPosition(ccp(bgWidth/2-bgSpaceX,0))
        exBg:addChild(boxBg2)
        local boxBg22=CCSprite:createWithSpriteFrameName("alienTechBoxBg.png")
        boxBg22:setAnchorPoint(ccp(1,0))
        boxBg22:setPosition(ccp(bgWidth+bgSpaceX,0))
        exBg:addChild(boxBg22)
        boxBg22:setFlipX(true)
        
        self.expandIconBgTab[idx+1]={}
        local fx=50+95
        local lx=bgWidth/2-45
        local fy=120
        local ly=220
        local wSpace=(bgWidth-fx-lx)+90
        local hSpace=(bgHeight-fy-ly)/2-30
        local lSpace=10
        for i=1,6 do
            local posX,posY=fx+wSpace*((i+1)%2),bgHeight-fy-hSpace*(math.ceil(i/2)-1)
            local lineX=40-(math.ceil(i/2)-1)*lSpace+(bgWidth/2-10)*((i+1)%2)
            local connectorSp1=CCSprite:createWithSpriteFrameName("alienTechConnector1.png")
            connectorSp1:setAnchorPoint(ccp(0.5,1))
            connectorSp1:setPosition(ccp(lineX,bgHeight))
            exBg:addChild(connectorSp1,2)
            
            local lineHeight1=bgHeight-posY-5
            local lineSp1=CCSprite:createWithSpriteFrameName("alienTechLine1.png")
            lineSp1:setAnchorPoint(ccp(0.5,0.5))
            lineSp1:setScaleY(lineHeight1/lineSp1:getContentSize().height)
            lineSp1:setPosition(ccp(lineX,bgHeight-lineHeight1/2))
            exBg:addChild(lineSp1,1)

            local lineSp2=CCSprite:createWithSpriteFrameName("alienTechLine2.png")
            lineSp2:setAnchorPoint(ccp(0.5,0.5))
            lineSp2:setPosition(ccp(lineX,posY))
            exBg:addChild(lineSp2,1)

            local lineHeight3=posX-lineX-68
            local lineSp3=CCSprite:createWithSpriteFrameName("alienTechLine1.png")
            lineSp3:setAnchorPoint(ccp(0.5,1))
            lineSp3:setRotation(-90)
            lineSp3:setScaleY(lineHeight3/lineSp3:getContentSize().height)
            -- lineSp3:setPosition(ccp(lineX+lineHeight3/2+5,posY))
            lineSp3:setPosition(ccp(lineX+13,posY))
            exBg:addChild(lineSp3,1)

            local techBgSp
            if i<=4 then
                techBgSp=CCSprite:createWithSpriteFrameName("alienTechBg1.png")
            else
                techBgSp=CCSprite:createWithSpriteFrameName("alienTechBg2.png") 
            end
            techBgSp:setPosition(ccp(posX,posY))
            exBg:addChild(techBgSp,3)

            local connectorSp2=CCSprite:createWithSpriteFrameName("alienTechConnector2.png")
            connectorSp2:setAnchorPoint(ccp(1,0.5))
            connectorSp2:setPosition(ccp(posX-techBgSp:getContentSize().width/2+4,posY))
            exBg:addChild(connectorSp2,2)


            local techId=slotTb[i]
            if techId and techId~=-2 then
                local function clickIcon()
                    if self.tv2 and self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)

                        if techId==-1 then
                            local function callback1()
                                self:refresh()
                            end
                            local unlockSlotIndex=alienTechVoApi:getUnlockSlotIndex(tid)
                            -- print("unlockSlotIndex",unlockSlotIndex)
                            smallDialog:showAlienTechUnlockSlotDialog("PanelHeaderPopup.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,callback1,self.selectIndex,tid,unlockSlotIndex)
                        else
                            if alienTechCfg.talent[techId] and alienTechCfg.talent[techId][alienTechCfg.keyCfg.talentType]==2 then
                                local isUnlock=alienTechVoApi:getTechIsUnlock(techId,self.selectIndex,true)
                                if isUnlock==true then
                                    smallDialog:showAlienTechSlotDialog("PanelHeaderPopup.png",CCSizeMake(550,500),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,techId)
                                else
                                end
                            else
                                local function callback2()
                                    self:refresh()
                                end
                                smallDialog:showAlienTechSkillDialog("PanelHeaderPopup.png",CCSizeMake(550,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,callback2,self.selectIndex,tid,i)
                            end
                        end
                    end
                end

                local iconSize=80
                local iconBg=LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",clickIcon)
                iconBg:setTouchPriority(-(self.layerNum-1)*20-2)
                iconBg:setScale(iconSize/iconBg:getContentSize().width)
                iconBg:setPosition(ccp(posX,posY))
                exBg:addChild(iconBg,4)
                
                if type(techId)=="string" then
                    local isUnlock=alienTechVoApi:getTechIsUnlock(techId,self.selectIndex,true)
                    local iStr=alienTechCfg.talent[techId][alienTechCfg.keyCfg.icon][1]
                    local subIStr=alienTechCfg.talent[techId][alienTechCfg.keyCfg.icon][2]
                    local icon
                    local subIcon
                    if isUnlock==true then
                        icon=CCSprite:createWithSpriteFrameName(iStr)
                        if subIStr and subIStr~="" then
                            subIcon=CCSprite:createWithSpriteFrameName(subIStr)
                        end
                    else
                        icon=GraySprite:createWithSpriteFrameName(iStr)
                        if subIStr and subIStr~="" then
                            subIcon=GraySprite:createWithSpriteFrameName(subIStr)
                        end
                    end
                    icon:setScale(iconSize/icon:getContentSize().width)
                    icon:setPosition(getCenterPoint(iconBg))
                    -- icon:tag(11)
                    iconBg:addChild(icon,1)
                    if subIcon then
                        subIcon:setPosition(ccp(subIcon:getContentSize().width/2+10,icon:getContentSize().height-subIcon:getContentSize().height/2-10))
                        icon:addChild(subIcon,1)
                    end


                    local str=alienTechVoApi:getTechName(techId)
                    -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                    local descLb=GetTTFLabelWrap(str,20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                    descLb:setAnchorPoint(ccp(0.5,1))
                    descLb:setPosition(ccp(posX,posY-55))
                    exBg:addChild(descLb,3)

                    table.insert(self.expandIconBgTab[idx+1],icon)
                elseif techId==-1 then
                    local lockSp=CCSprite:createWithSpriteFrameName("alienTechLock.png")
                    -- lockSp:setPosition(getCenterPoint(iconBg))
                    -- iconBg:addChild(lockSp,5)
                    lockSp:setPosition(ccp(posX,posY))
                    exBg:addChild(lockSp,5)
                end
            else
                -- local iconSize=80
                -- local iconBg=CCSprite:createWithSpriteFrameName("alienTechEmptySlot.png")
                -- iconBg:setScale(iconSize/iconBg:getContentSize().width)
                -- iconBg:setPosition(ccp(posX,posY))
                -- exBg:addChild(iconBg,4)

                techBgSp:setVisible(false)
                local emptyIcon=CCSprite:createWithSpriteFrameName("alienTechEmptySkill.png")
                emptyIcon:setPosition(ccp(posX-45,posY))
                exBg:addChild(emptyIcon,6)
            end
        end


        local infScale=0.8
        local function infoHandler(tag,object)
            if self.tv2 and self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                require "luascript/script/game/scene/gamedialog/alienTechDialog/tankInfoEnhanceDialog"
                tankInfoEnhanceDialog:create(sceneGame,id,self.layerNum+1,nil,getlocal("alien_tech_title"))
            end
        end
        local strSize2 = 21
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
            strSize2 = 25
        end
        local infoItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",infoHandler,idx+1,getlocal("alien_tech_perp_info"),24/infScale,101)
        infoItem:setScale(infScale)
        local btnLb = infoItem:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        local infoMenu=CCMenu:createWithItem(infoItem)
        infoMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        infoMenu:setPosition(ccp(bgWidth-infoItem:getContentSize().width/2*infScale-20,infoItem:getContentSize().height/2*infScale+30))
        exBg:addChild(infoMenu,3)
    end
end


function alienTechDialogTab2:cellClick1(idx)
    for k,v in pairs(self.iconBgTab) do
        local iconBg=tolua.cast(v,"CCSprite")
        if k==(idx+1) then
            iconBg:setVisible(true)
        else
            iconBg:setVisible(false)
        end
    end

    if self.totalPointLb then
        local treeCfg=alienTechVoApi:getTreeCfg()
        local cfg=treeCfg[idx+1]
        local str=getlocal("alien_tech_class_point",{0,cfg.totalPoint})
        self.totalPointLb:setString(str)
    end

    self.selectIndex=idx+1

    if self.tv2 then
        self.tv2:reloadData()
    end
end

--点击了cell或cell上某个按钮
function alienTechDialogTab2:cellClick2(idx)
    if self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)

        if self.expandIdx[self.selectIndex]==nil then
            self.expandIdx[self.selectIndex]={}
        end
        if self.expandIdx[self.selectIndex]["k"..(idx-1000)]==nil then
            self.expandIdx[self.selectIndex]["k"..(idx-1000)]=idx-1000
            self.tv2:openByCellIndex(idx-1000,self.normalHeight)
        else
            local expandHeight=self:getExpandHeight(idx-1000)
            self.expandIdx[self.selectIndex]["k"..(idx-1000)]=nil
            self.tv2:closeByCellIndex(idx-1000,expandHeight)
            if self.expandIconBgTab[idx-1000+1] then
                for k,v in pairs(self.expandIconBgTab[idx-1000+1]) do
                    if v and v.setVisible then
                        v:setVisible(false)
                    end
                end
            end
        end
    end
end

function alienTechDialogTab2:getExpandHeight(idx)
    do return 920 end
    if self.expandHeight[self.selectIndex]==nil then
        self.expandHeight[self.selectIndex]={}
    end
    if self.expandHeight[self.selectIndex]["k"..idx]==nil then
        local treeCfg=alienTechVoApi:getTreeCfg()
        local cfg=treeCfg[self.selectIndex]
        local tid=(tonumber(cfg.desc[idx+1]) or tonumber(RemoveFirstChar(cfg.desc[idx+1])))
        if tid<10010 then
            self.expandHeight[self.selectIndex]["k"..idx]=400
        elseif tid>=10010 and tid<=10020 then
            self.expandHeight[self.selectIndex]["k"..idx]=500
        else
            self.expandHeight[self.selectIndex]["k"..idx]=600
        end
    end
    return self.expandHeight[self.selectIndex]["k"..idx]
end


function alienTechDialogTab2:refreshCellExpand(idx,cell)
    local expanded=false
    if self.expandIdx[self.selectIndex] and self.expandIdx[self.selectIndex]["k"..idx]~=nil then
        expanded=true
    end
    if expanded==true then
        if cell then
            if cell:getChildByTag(2) then
                local exBg=tolua.cast(cell:getChildByTag(2),"LuaCCScale9Sprite")
                exBg:removeFromParentAndCleanup(true)
            end
            self:initExpand(idx,cell)
        end
    end
end

function alienTechDialogTab2:refresh()
    if self.tv2 then
        local recordPoint=self.tv2:getRecordPoint()
        self.tv2:reloadData()
        self.tv2:recoverToRecordPoint(recordPoint)
    end
end

function alienTechDialogTab2:tick()
    if alienTechVoApi:getFlag()==0 then
        self:refresh()
        alienTechVoApi:setFlag(1)
    end
end

function alienTechDialogTab2:dispose()
    self.tv1=nil
    self.tv2=nil
    self.iconBgTab={}
    self.selectIndex=1
    self.expandIdx={}
    self.expandHeight={}
    self.expandIconBgTab={}
end





