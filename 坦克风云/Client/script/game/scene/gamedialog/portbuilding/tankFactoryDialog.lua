--require "luascript/script/componet/commonDialog"
tankFactoryDialog=commonDialog:new()

function tankFactoryDialog:new(bid,layerNum,isGuide,isShowPoint,taskVo)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bid=bid
    self.isShowPoint=isShowPoint
    self.layerNum=layerNum
    self.leftBtn=nil
    self.expandIdx={}
    self.expandHeight2=G_VisibleSize.height-156

    if G_isIphone5() then
        self.expandHeight=G_VisibleSize.height-156
    else
        self.expandHeight=1136-230
    end

    if newGuidMgr:isNewGuiding() then
        self.expandHeight2=G_VisibleSize.height-140
        self.expandHeight=G_VisibleSize.height-140
    end

    self.normalHeight=115
    self.extendSpTag=113
    self.headTab={}
    self.tankSoltTab={}
    self.tankResultTypeTab={}
    self.tankResultLockTab={}
    self.tankResultCountTab={}
    self.tankResultLevelTab={}
    self.tickTabCell={}
    self.tickNumLbTab={}
    self.expandUITab={}
    self.m_lastNumValue=1;
    self.noAtkLb=nil;
    self.sendBtn=nil;
    self.sendMenu=nil;
    self.upgradeDialog=nil
    self.isGuide=isGuide
    self.addBtn=nil
    self.tankPoint=nil
    self.numTh=nil
    self.speedUpSmallDialog = nil
    self.taskVo=taskVo
    self.buildIdx=nil
    self.guildItem=nil

    local function speedListener(event,data)
        self:clearVar()
    end
    self.speedUpListener=speedListener
    eventDispatcher:addEventListener("tankslot.speedup",self.speedUpListener)
    return nc
end

--设置或修改每个Tab页签
function tankFactoryDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v

        if index==0 then
            tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        elseif index==1 then
            tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        elseif index==2 then
            tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1
    end

    if buildingVoApi:getBuildiingVoByBId(self.bid).level<1 then
        local index=0
        for k,v in pairs(self.allTabs) do
            local  tabBtnItem=v
            if index==2 then
                tabBtnItem:setVisible(false)
            end
            index=index+1
        end
    end
    self:noProduceTank()
    self:judgeProduceTank()

end
function tankFactoryDialog:judgeProduceTank()
    if self.noAtkLb==nil or tolua.cast(self.noAtkLb,"CCLabelTTF")==nil then
        do return end
    end
    if self.sendMenu==nil then
        do return end
    end
    if self.selectedTabIndex==2 then
        if SizeOfTable(tankSlotVoApi:getAllSolts(self.bid))==0 and newGuidMgr:isNewGuiding()~=nil then
            self.noAtkLb=tolua.cast(self.noAtkLb,"CCLabelTTF")
            self.noAtkLb:setVisible(true)
            self.sendMenu:setVisible(true)

        else
            self.noAtkLb=tolua.cast(self.noAtkLb,"CCLabelTTF")
            self.noAtkLb:setVisible(false)
            self.sendMenu:setVisible(false)
        end
    else
        self.noAtkLb=tolua.cast(self.noAtkLb,"CCLabelTTF")
        self.noAtkLb:setVisible(false)
        self.sendMenu:setVisible(false)
    end
end
function tankFactoryDialog:noProduceTank()

    self.noAtkLb=GetTTFLabelWrap(getlocal("noProdeceTank"),24,CCSizeMake(500, 100),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    --self.noAtkLb=GetTTFLabel(getlocal("jumpToWorld"),25);
    self.noAtkLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2));
    self.noAtkLb:setColor(ccc3(144,144,144))
    self.bgLayer:addChild(self.noAtkLb)

    local function sendHandler()
        self:tabClick(1)
    end
    self.sendBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",sendHandler,nil,getlocal("jumpButton"),25)
    self.sendMenu=CCMenu:createWithItem(self.sendBtn)
    self.sendMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-200))
    self.sendMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(self.sendMenu,2)

    self.noAtkLb:setVisible(false)
    self.sendMenu:setVisible(false)

    if SizeOfTable(tankSlotVoApi:getAllSolts(self.bid))>0 then
        self.noAtkLb:setVisible(false)
        self.sendMenu:setVisible(false)
    else
        self.noAtkLb:setVisible(true)
        self.sendMenu:setVisible(true)

    end

end
--设置对话框里的tableView
function tankFactoryDialog:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setTableViewTouchPriority(1)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    self.tankSoltTab=tankSlotVoApi:getAllSolts(self.bid)
    --把用到的表 赋值下
    self:againAssignmentTab()
    --任务跳转指引
    if self.btnItem ~= nil then
        local groupId = G_getGroupIdByBid(self.bid)
        local x,y,z,w  = G_getSpriteWorldPosAndSize(self.btnItem, 1)
        newSkipCfg[groupId].clickRect = CCRectMake(x,y+G_VisibleSize.height,z,w)
    end
    if newGuidMgr:isNewGuiding()==true and self.guildItem then
        if newGuidMgr.curStep==1 then
            local nextStepId=newGuidCfg[newGuidMgr.curStep].toStepId
            newGuidMgr:setGuideStepField(nextStepId,self.guildItem,true)
        end
        self.guildItem=nil
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function tankFactoryDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if self.selectedTabIndex==0 then
            return 1
        elseif self.selectedTabIndex==1 then
            return SizeOfTable(self.tankResultTypeTab)
        elseif self.selectedTabIndex==2 then
            return SizeOfTable(self.tankSoltTab)
        end

    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.selectedTabIndex==0 then
            tmpSize=CCSizeMake(600,self.expandHeight2)

        elseif self.selectedTabIndex==1 then
            if self.expandIdx["k"..idx]~=nil then
                tmpSize=CCSizeMake(600,self.expandHeight)
            else
                tmpSize=CCSizeMake(600,self.normalHeight)
            end
        elseif self.selectedTabIndex==2 then
            tmpSize=CCSizeMake(600,self.normalHeight)

        end

        return  tmpSize
    elseif fn=="tableCellAtIndex" then

        if self.selectedTabIndex==0 then

            local cell=CCTableViewCell:new()
            cell:autorelease()
            self:loadCCTableViewCell(cell,idx)
            return cell
        elseif self.selectedTabIndex==1 then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            self:loadCCTableViewCell(cell,idx)
            return cell
        elseif self.selectedTabIndex==2 then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local rect = CCRect(0, 0, 50, 50);
            local capInSet = CCRect(20, 20, 10, 10);
            local function cellClick(hd,fn,idx)
            --return self:cellClick(idx)
            end

            local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
            backSprie:ignoreAnchorPointForPosition(false);
            backSprie:setAnchorPoint(ccp(0,0));
            backSprie:setTag(1000+idx)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(backSprie,1)
            self.tickTabCell[idx+1]=cell


            local sprite = tankVoApi:getTankIconSp(tonumber(self.tankSoltTab[idx+1].itemId))--CCSprite:createWithSpriteFrameName(tankCfg[tonumber(self.tankSoltTab[idx+1].itemId)].icon);
            sprite:setAnchorPoint(ccp(0,0.5));
            sprite:setPosition(20,backSprie:getContentSize().height/2)
            sprite:setScale(0.5)
            cell:addChild(sprite,2)

            local strName = getlocal(tankCfg[tonumber(self.tankSoltTab[idx+1].itemId)].name).."*"..self.tankSoltTab[idx+1].itemNum
            local lbName=GetTTFLabelWrap(strName,24,CCSizeMake(26*10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
            lbName:setColor(G_ColorGreen)
            lbName:setPosition(105,backSprie:getContentSize().height/2+30)
            lbName:setAnchorPoint(ccp(0,0.5));
            cell:addChild(lbName,2)

            local leftTime,totalTime=tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.bid,tonumber(self.tankSoltTab[idx+1].slotId))

            local timeStr = GetTimeStr(leftTime)
            AddProgramTimer(cell,ccp(240,backSprie:getContentSize().height/2-20),10,11,timeStr,"TeamTravelBarBg.png","TeamTravelBar.png",11,nil,nil,nil,nil,20)
            local ccprogress=cell:getChildByTag(10)
            ccprogress=tolua.cast(ccprogress,"CCProgressTimer")

            local per = (totalTime-leftTime)/totalTime*100
            ccprogress:setPercentage(per)


            local function touch1()
                PlayEffect(audioCfg.mouseClick)


                local function superCreateHandler()
                    local tankname=getlocal(tankCfg[tankSlotVoApi:getSlotBySlotid(self.bid,self.tankSoltTab[idx+1].slotId).itemId].name)

                    local name,pic,desc,id,index,eType,equipId,bgname = getItem(self.tankSoltTab[idx+1].itemId,"o")
                    local num=tonumber(self.tankSoltTab[idx+1].itemNum)
                    local award={type="o",key="a" .. self.tankSoltTab[idx+1].itemId,pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
                    local reward={award}

                    local function super()
                        if tankSlotVoApi:getAllSolts(self.bid)[idx+1]==nil then

                            ShowNOSpeed()
                            do
                                return
                            end
                        end
                        local result,reason=tankVoApi:checkSuperUpgradeBeforeSendServer(self.bid,self.tankSoltTab[idx+1].slotId)
                        if result==true then
                            local function serverSuperUpgrade(fn,data)
                                --local retTb=OBJDEF:decode(data)

                                if base:checkServerData(data)==true then
                                    smallDialog:showTipsDialog("SuccessPanelSmall.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{tankname}),28,nil,nil,reward)
                                    G_cancelPush("t"..self.bid.."_"..self.tankSoltTab[idx+1].slotId,G_TankProduceTag)
                                    self:clearVar()
                                end
                                if self.speedUpSmallDialog ~= nil then
                                    self.speedUpSmallDialog:close()
                                    self.speedUpSmallDialog = nil
                                end
                            end
                            local tid=tonumber(self.tankSoltTab[idx+1].itemId)
                            local nums=tonumber(self.tankSoltTab[idx+1].itemNum)
                            local slotid=tonumber(self.tankSoltTab[idx+1].slotId)
                            socketHelper:speedupTanks(self.bid,slotid,tid,nums,serverSuperUpgrade)
                        else
                            if reson ==1 then
                                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+2)
                            elseif reson==2 then
                                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("notEnoughGem"),nil,self.layerNum+2)

                            end

                        end
                    end
                    local leftTime,totalTime=tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.bid,tonumber(self.tankSoltTab[idx+1].slotId))
                    local gems=TimeToGems(leftTime)
                    local function buyGems()
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        end
                        vipVoApi:showRechargeDialog(self.layerNum+2)

                    end
                    if playerVo.gems<gems then

                        local num=gems-playerVo.gems
                        local smallD=smallDialog:new()
                        smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{gems,playerVo.gems,num}),nil,self.layerNum+2)
                    else
                        local smallD=smallDialog:new()
                        smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),super,getlocal("dialog_title_prompt"),getlocal("speedUp",{gems}),nil,self.layerNum+2)
                    end
                end
                --使用加速道具
                if base.speedUpPropSwitch == 1 and newGuidMgr:isNewGuiding() ~= true then
                    if self.speedUpSmallDialog ~= nil then
                        self.speedUpSmallDialog:close()
                        self.speedUpSmallDialog = nil
                    end
                    require "luascript/script/componet/speedUpPropSmallDialog"
                    self.speedUpSmallDialog=speedUpPropSmallDialog:new(3,{self.bid,self.tankSoltTab[idx+1].slotId},superCreateHandler)
                    self.speedUpSmallDialog:init(self.layerNum+1)
                else
                    superCreateHandler()
                end
            end


            local function touch2()
                PlayEffect(audioCfg.mouseClick)
                local function callBack()
                    if tankSlotVoApi:getAllSolts(self.bid)[idx+1]==nil then

                        ShowNOCancel()
                        do
                            return
                        end
                    end
                    local function serverCancle(fn,data)
                        --local retTb=OBJDEF:decode(data)

                        if base:checkServerData(data)==true then
                            G_cancelPush("t"..self.bid.."_"..self.tankSoltTab[idx+1].slotId,G_TankProduceTag)
                            tankVoApi:cancleProduce(self.bid,self.tankSoltTab[idx+1].slotId)
                            self:clearVar()

                        end

                    end
                    local tid=tonumber(self.tankSoltTab[idx+1].itemId)
                    local nums=tonumber(self.tankSoltTab[idx+1].itemNum)
                    local slotid=tonumber(self.tankSoltTab[idx+1].slotId)
                    socketHelper:cancleTanks(self.bid,slotid,tid,nums,serverCancle)

                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("ship_produce_cancel_prompt"),nil,self.layerNum+1)


            end


            local menuItem1 = GetButtonItem("yh_BtnRight.png","yh_BtnRight_Down.png","yh_BtnRight_Down.png",touch1,10,nil,nil)
            local menu1 = CCMenu:createWithItem(menuItem1);
            menu1:setPosition(ccp(530,backSprie:getContentSize().height/2));
            menu1:setTouchPriority(-(self.layerNum-1)*20-2);
            cell:addChild(menu1,3);


            local menuItem2 = GetButtonItem("yh_BtnNo.png","yh_BtnNo_Down.png","yh_BtnNo_Down.png",touch2,11,nil,nil)
            local menu2 = CCMenu:createWithItem(menuItem2);
            menu2:setPosition(ccp(455,backSprie:getContentSize().height/2));
            menu2:setTouchPriority(-(self.layerNum-1)*20-2);
            cell:addChild(menu2,3);

            if self.tankSoltTab[idx+1].status==2 then
                menuItem1:setEnabled(false);
                local timeLb = ccprogress:getChildByTag(11)
                timeLb=tolua.cast(timeLb,"CCLabelTTF")
                timeLb:setString(getlocal("waiting"));

            end





            return cell;
        end



    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end
end

--点击tab页签 idx:索引
function tankFactoryDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            if self.selectedTabIndex==0 then
                self.tv:setTableViewTouchPriority(1)
            else
                self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
            end
            self:doUserHandler()
            if newGuidMgr:isNewGuiding() then --新手引导
                if self.selectedTabIndex==1 then
                    newGuidMgr:toNextStep()
            end
            end
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
        else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
        end

    end
    self:judgeProduceTank()
    self:againAssignmentTab()
    self:clearVar()
    self:resetForbidLayer()
    if self.selectedTabIndex~=1 then
        self:removeGuied()
        self.isGuide=2
    end
    if self.isGuide==true then
        if self.numTh~=nil then
            self:recordPoint(self.numTh)
        end
    end
end

--用户处理特殊需求,没有可以不写此方法
function tankFactoryDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function tankFactoryDialog:cellClick(idx)
    if self.selectedTabIndex==2 then
        return
    end
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)
        if self.expandIdx["k"..(idx-1000)]==nil then
            self.expandIdx["k"..(idx-1000)]=idx-1000
            self.tv:openByCellIndex(idx-1000,self.normalHeight)
            if newGuidMgr:isNewGuiding() then --新手引导
                if self.selectedTabIndex==1 then
                    newGuidMgr:toNextStep()
                end
            end
            self:removeGuied()
        else
            --self.requires[idx-1000+1]:dispose()
            --self.requires[idx-1000+1]=nil
            --self.allCellsBtn[idx-1000+1]=nil
            self.expandIdx["k"..(idx-1000)]=nil
            if self.selectedTabIndex==1 then
                self.expandUITab[(idx-1000)+1]=nil
            end
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

--创建或刷新CCTableViewCell
function tankFactoryDialog:loadCCTableViewCell(cell,idx,refresh)
    if self.selectedTabIndex==0 then
        self.upgradeDialog=buildingUpgradeCommon:new()
        self.upgradeDialog:init(cell,self.bgLayer,self.bid,self,self.layerNum,self.isShowPoint)
        self.btnItem = self.upgradeDialog.allCellsBtn[1]
        if newGuidMgr:isNewGuiding()==true and newGuidMgr.curStep==1 then
            self.guildItem=self.upgradeDialog.guildItem
        end    
    else

        local expanded=false
        if self.expandIdx["k"..idx]==nil then
            expanded=false
        else
            expanded=true
        end
        if expanded then
            cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.expandHeight))
        else
            cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
        end
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);

        local function cellClick(hd,fn,idx)

            if self.tankResultLockTab[idx-1000+1]==0 then
                return self:cellClick(idx)
            end
        end
        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)


        local m_tankIndex = self.tankResultTypeTab[idx+1]
        local lbName=GetTTFLabel(getlocal(tankCfg[m_tankIndex].name),24,true)
        lbName:setColor(G_ColorGreen)
        lbName:setPosition(120,headerSprie:getContentSize().height/2+30)
        lbName:setAnchorPoint(ccp(0,0.5));
        headerSprie:addChild(lbName,2)

        local lbNum=GetTTFLabel(getlocal("schedule_ship_num",{self.tankResultCountTab[idx+1]}),20)
        lbNum:setPosition(120,headerSprie:getContentSize().height/2)
        lbNum:setAnchorPoint(ccp(0,0.5));
        headerSprie:addChild(lbNum,2)
        self.tickNumLbTab[m_tankIndex]=lbNum



        local sprite = tankVoApi:getTankIconSp(m_tankIndex)--CCSprite:createWithSpriteFrameName(tankCfg[m_tankIndex].icon);
        sprite:setAnchorPoint(ccp(0,0.5));
        sprite:setPosition(20,headerSprie:getContentSize().height/2)
        sprite:setScale(0.5)
        headerSprie:addChild(sprite,2)

        if self.buildIdx==nil and self.taskVo and self.taskVo.group then
            local groupId=tonumber(self.taskVo.group)
            if (groupId >= 15 and groupId <= 18) or (groupId >= 31 and groupId <= 39) then --造兵
                local tankId
                if self.taskVo.require and self.taskVo.require[1] then
                    tankId=self.taskVo.require[1]
                end
                if tankId and tonumber(tankId)==tonumber(m_tankIndex) then
                    self.buildIdx=idx
                    local function nilFunc()
                    end
                    local lightBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",capInSet,nilFunc)
                    lightBgSp:setContentSize(headerSprie:getContentSize())
                    lightBgSp:ignoreAnchorPointForPosition(false)
                    lightBgSp:setIsSallow(false)
                    lightBgSp:setOpacity(0)
                    lightBgSp:setPosition(getCenterPoint(headerSprie))
                    lightBgSp:setTouchPriority(-(self.layerNum-1)*20-1)
                    headerSprie:addChild(lightBgSp)
                    local function playBlinkEffect()
                        local fadeIn=CCFadeIn:create(0.5)
                        local fadeOut=CCFadeOut:create(0.5)
                        local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
                        lightBgSp:runAction(CCRepeatForever:create(seq))
                    end
                    local function removeBlinkEffect()
                        if lightBgSp then
                            lightBgSp:setVisible(false)
                        end
                    end
                    guideTipMgr:setCallBackFunc(playBlinkEffect,removeBlinkEffect)
                end
            end
        end

        if self.tankResultLockTab[idx+1]==0 then
            --显示加减号
            local btn
            if expanded==false then
                if playerVoApi:getR1()<tonumber(tankCfg[m_tankIndex].metalConsume) or
                    playerVoApi:getR2()<tonumber(tankCfg[m_tankIndex].oilConsume) or
                    playerVoApi:getR3()<tonumber(tankCfg[m_tankIndex].siliconConsume) or
                    playerVoApi:getR4()<tonumber(tankCfg[m_tankIndex].uraniumConsume) then
                    btn=GraySprite:createWithSpriteFrameName("sYellowAddBtn.png")
                else
                    btn=CCSprite:createWithSpriteFrameName("sYellowAddBtn.png")

                end


            else
                if playerVoApi:getR1()<tonumber(tankCfg[m_tankIndex].metalConsume) or
                    playerVoApi:getR2()<tonumber(tankCfg[m_tankIndex].oilConsume) or
                    playerVoApi:getR3()<tonumber(tankCfg[m_tankIndex].siliconConsume) or
                    playerVoApi:getR4()<tonumber(tankCfg[m_tankIndex].uraniumConsume) then
                    btn=GraySprite:createWithSpriteFrameName("sYellowSubBtn.png")

                    self.expandUITab[idx+1]={
                        cellBtn=btn,
                    }
                else
                    btn=CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")

                end

            end
            btn:setScale(0.8)
            btn:setAnchorPoint(ccp(0,0.5))
            btn:setPosition(ccp(headerSprie:getContentSize().width-10-btn:getContentSize().width,headerSprie:getContentSize().height/2))
            headerSprie:addChild(btn)
            btn:setTag(self.extendSpTag)

            if self.isGuide==true then
                local numTh=nil
                for k,v in pairs(self.tankResultLockTab) do
                    if v==0 then
                        numTh=k;
                    end
                end
                if idx+1==numTh then
                    local scale=(btn:getContentSize().width+10)/40
                    G_addFlicker(btn,scale,scale,ccp(btn:getContentSize().width/2,btn:getContentSize().height/2))
                    self.addBtn=btn;
                    self.numTh=numTh

                end
            end

            local timeSp = CCSprite:createWithSpriteFrameName("IconTime.png");
            timeSp:setAnchorPoint(ccp(0,0.5));
            timeSp:setPosition(115,headerSprie:getContentSize().height/2-30)
            headerSprie:addChild(timeSp,2)

            local timeConsume=tankVoApi:getProductTime(m_tankIndex,self.bid)
            local lbTime=GetTTFLabel(GetTimeStr(timeConsume),20)
            lbTime:setPosition(165,headerSprie:getContentSize().height/2-30)
            lbTime:setAnchorPoint(ccp(0,0.5));
            headerSprie:addChild(lbTime,2)
        else
            local tsLb=GetTTFLabel(getlocal("chuanwu_level_require",{self.tankResultLockTab[idx+1]}),20)
            tsLb:setColor(G_ColorRed)
            tsLb:setTag(30)
            tsLb:setAnchorPoint(ccp(0,0))
            tsLb:setPosition(ccp(120,10))
            headerSprie:addChild(tsLb)


        end


        if expanded==true then --显示展开信息
            local rect = CCRect(0, 0, 50, 50);
            local capInSet = CCRect(20, 20, 10, 10);
            local function touchHander()

            end
            local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
            exBg:setAnchorPoint(ccp(0,0))

            if newGuidMgr:isNewGuiding() then
                exBg:setContentSize(CCSize(580,self.expandHeight-self.normalHeight-350))
                exBg:setPosition(ccp(0,210))
            else
                exBg:setContentSize(CCSize(580,self.expandHeight-self.normalHeight-280-20))
                exBg:setPosition(ccp(0,180))
            end

            exBg:setTag(2)
            cell:addChild(exBg)

            local dis = 5
            local m_tankIndex = self.tankResultTypeTab[idx+1]
            local spriteIcon = tankVoApi:getTankIconSp(m_tankIndex)--CCSprite:createWithSpriteFrameName(tankCfg[m_tankIndex].icon);
            spriteIcon:setAnchorPoint(ccp(0,0.5));
            spriteIcon:setScale(0.5)
            spriteIcon:setPosition(20,exBg:getContentSize().height+70-dis)
            exBg:addChild(spriteIcon,2)

            local function touchInfo()
                PlayEffect(audioCfg.mouseClick)
                tankInfoDialog:create(exBg,m_tankIndex,self.layerNum+1)

            end

            local menuItemInfo = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,11,nil,nil)
            local menuInfo = CCMenu:createWithItem(menuItemInfo);
            menuInfo:setPosition(ccp(520,exBg:getContentSize().height+70));
            menuInfo:setTouchPriority(-(self.layerNum-1)*20-2);
            exBg:addChild(menuInfo,3);



            local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");


            local iconScale= 50/lifeSp:getContentSize().width

            lifeSp:setAnchorPoint(ccp(0,0.5));
            lifeSp:setPosition(120,exBg:getContentSize().height+100-dis)
            exBg:addChild(lifeSp,2)
            lifeSp:setScale(iconScale)

            local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
            attackSp:setAnchorPoint(ccp(0,0.5));
            attackSp:setPosition(280,exBg:getContentSize().height+100-dis)
            exBg:addChild(attackSp,2)
            attackSp:setScale(iconScale)

            local typeStr = "pro_ship_attacktype_"..tankCfg[m_tankIndex].attackNum

            local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
            attackTypeSp:setAnchorPoint(ccp(0,0.5));
            attackTypeSp:setPosition(120,exBg:getContentSize().height+40-dis)
            exBg:addChild(attackTypeSp,2)
            attackTypeSp:setScale(iconScale)

            local lifeLb=GetTTFLabel(tankCfg[m_tankIndex].life,20)
            lifeLb:setAnchorPoint(ccp(0,0.5))
            lifeLb:setPosition(ccp(180,exBg:getContentSize().height+100-dis))
            exBg:addChild(lifeLb)

            local attLb=GetTTFLabel(tankCfg[m_tankIndex].attack,20)
            attLb:setAnchorPoint(ccp(0,0.5))
            attLb:setPosition(ccp(340,exBg:getContentSize().height+100-dis))
            exBg:addChild(attLb)

            local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),20,CCSizeMake(24*10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            attTypeLb:setAnchorPoint(ccp(0,0.5))
            attTypeLb:setPosition(ccp(180,exBg:getContentSize().height+40-dis))
            exBg:addChild(attTypeLb)



            local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
            bgSp:setAnchorPoint(ccp(0.5,0.5));
            bgSp:setPosition(exBg:getContentSize().width/2,-30);
            exBg:addChild(bgSp,1);


            local timeSp = CCSprite:createWithSpriteFrameName("IconTime.png");
            timeSp:setAnchorPoint(ccp(0,0.5));
            timeSp:setPosition(30,-80)
            exBg:addChild(timeSp,2)

            self:exbgCellForId1(idx,exBg)



        end
        local tankCount=SizeOfTable(self.tankResultTypeTab)
        if idx==tankCount-1 and self.buildIdx then
            if G_isIphone5()==true then
                guideTipMgr:setPanelPos(ccp(10,200))
            else
                guideTipMgr:setPanelPos(ccp(10,120))
            end
            if self.buildIdx>=tankCount-4 then
                self.tv:recoverToRecordPoint(ccp(0,0))
                guideTipMgr:setPanelPos(ccp(10,300))
            elseif self.buildIdx==0 then
            else
                local recordPoint=self.tv:getRecordPoint()
                local x=recordPoint.x
                local y=recordPoint.y+(self.buildIdx-1)*self.normalHeight
                self.tv:recoverToRecordPoint(ccp(x,y))
            end
        end
    end

end
function tankFactoryDialog:recordPoint(numTh)
    if numTh>6 and numTh<14 then
        local yy=(numTh-4)*self.normalHeight
        self.tv:recoverToRecordPoint(ccp(0,-1845+yy+30))
    end
end
function tankFactoryDialog:removeGuied()
    if self.addBtn~=nil then
        G_removeFlicker(self.addBtn)
        self.addBtn=nil
    end
    self.isGuide=2;
end
function tankFactoryDialog:exbgCellForId1(idx,container)
    local m_tankIndex = self.tankResultTypeTab[idx+1]
    local addH=11;
    local reR1,reR2,reR3,reR4,reUpgradedTime = tankVoApi:getProduceTankResources(m_tankIndex)

    local typeLb=GetTTFLabel(getlocal("resourceType"),20)
    typeLb:setAnchorPoint(ccp(0.5,0.5))
    typeLb:setPosition(ccp(150,container:getContentSize().height-40+addH))
    container:addChild(typeLb)

    local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
    resourceLb:setAnchorPoint(ccp(0.5,0.5))
    resourceLb:setPosition(ccp(300,container:getContentSize().height-40+addH))
    container:addChild(resourceLb)

    local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
    haveLb:setAnchorPoint(ccp(0.5,0.5))
    haveLb:setPosition(ccp(450,container:getContentSize().height-40+addH))
    container:addChild(haveLb)


    local tb={
        {titleStr="metal",spName="resourse_normal_metal.png",needStr=FormatNumber(reR1),haveStr=FormatNumber(playerVoApi:getR1()),num1=playerVoApi:getR1(),num2=tonumber(reR1)},
        {titleStr="oil",spName="resourse_normal_oil.png",needStr=FormatNumber(reR2),haveStr=FormatNumber(playerVoApi:getR2()),num1=playerVoApi:getR2(),num2=tonumber(reR2)},
        {titleStr="silicon",spName="resourse_normal_silicon.png",needStr=FormatNumber(reR3),haveStr=FormatNumber(playerVoApi:getR3()),num1=playerVoApi:getR3(),num2=tonumber(reR3)},
        {titleStr="uranium",spName="resourse_normal_uranium.png",needStr=FormatNumber(reR4),haveStr=FormatNumber(playerVoApi:getR4()),num1=playerVoApi:getR4(),num2=tonumber(reR4)},

    }
    if self.expandUITab[idx+1] then
        self.expandUITab[idx+1].resUITab={}
    end
    if tankCfg[m_tankIndex].propConsume~="" then
        local pid1 = tankCfg[m_tankIndex].propConsume[1][1]
        local pid2 = tankCfg[m_tankIndex].propConsume[2][1]
        local nameStr1=propCfg[pid1].name
        local numStr1=tankCfg[m_tankIndex].propConsume[1][2]
        local nameStr2=propCfg[pid2].name
        local numStr2=tankCfg[m_tankIndex].propConsume[2][2]


        local tb1={titleStr=nameStr1,spName=propCfg[pid1].icon,needStr=FormatNumber(numStr1),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num2=tonumber(numStr1)}
        local tb2={titleStr=nameStr2,spName=propCfg[pid2].icon,needStr=FormatNumber(numStr2),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num2=tonumber(numStr2)}
        table.insert(tb,tb1)
        table.insert(tb,tb2)
    end


    local addy=60
    local countTb = {}

    for k,v in pairs(tb) do
        local r1Lb=GetTTFLabelWrap(getlocal(v.titleStr),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        r1Lb:setAnchorPoint(ccp(0.5,0.5))
        r1Lb:setPosition(ccp(150,container:getContentSize().height-100+addH-(k-1)*addy))
        container:addChild(r1Lb)

        local r1Sp=CCSprite:createWithSpriteFrameName(v.spName)
        r1Sp:setAnchorPoint(ccp(0.5,0.5))
        r1Sp:setPosition(ccp(40,container:getContentSize().height-100+addH-(k-1)*60))
        container:addChild(r1Sp)
        r1Sp:setScale(0.5)
        -- if v.titleStr==tankCfg[m_tankIndex-1].name then
        --   r1Sp:setScale(0.35)
        -- else
        --   r1Sp:setScale(0.5)
        -- end

        local needR1Lb=GetTTFLabel(v.needStr,20)
        needR1Lb:setAnchorPoint(ccp(0.5,0.5))
        needR1Lb:setPosition(ccp(300,container:getContentSize().height-100+addH-(k-1)*addy))
        container:addChild(needR1Lb)

        local haveR1Lb=GetTTFLabel(v.haveStr,20)
        haveR1Lb:setAnchorPoint(ccp(0.5,0.5))
        haveR1Lb:setPosition(ccp(450,container:getContentSize().height-100+addH-(k-1)*addy))
        container:addChild(haveR1Lb)

        local p1Sp;
        if v.num1>=v.num2 then
            p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
        else
            p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")

            if k<=4 then
                local function callBack()
                  smallDialog:showBuyResDialog(k,7)
                end
                local icon=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",callBack)
                icon:setTouchPriority(-(6-1)*20-1)
                icon:setPosition(ccp(510,container:getContentSize().height-100+addH-(k-1)*addy))
                container:addChild(icon)

                if self.expandUITab[idx+1] and self.expandUITab[idx+1].resUITab then
                    self.expandUITab[idx+1].resUITab[k] = {
                        leftSp=p1Sp,
                        resLb=haveR1Lb,
                        rightSp=icon
                    }
                end
            end
        end
        p1Sp:setAnchorPoint(ccp(0.5,0.5))

        p1Sp:setPosition(ccp(400,container:getContentSize().height-100+addH-(k-1)*addy))

        container:addChild(p1Sp)
        countTb[k]=needR1Lb

        if k<=4 then
            if self.expandUITab[idx+1] and self.expandUITab[idx+1].resUITab then
                if self.expandUITab[idx+1].resUITab[k]==nil then
                    self.expandUITab[idx+1].resUITab[k]={}
                end
                self.expandUITab[idx+1].resUITab[k].needLb=needR1Lb
            end
        end
    end


    local m_numLb=GetTTFLabel(" ",24)
    m_numLb:setPosition(70,-30);
    container:addChild(m_numLb,2);
    local m_tankIndex = self.tankResultTypeTab[idx+1]

    local timeConsume=tankVoApi:getProductTime(m_tankIndex,self.bid)
    local lbTime=GetTTFLabel(GetTimeStr(timeConsume),20)
    lbTime:setPosition(70,-80)
    lbTime:setAnchorPoint(ccp(0,0.5));
    container:addChild(lbTime,2)

    local function sliderTouch(handler,object)
        local count = math.floor(object:getValue())
        m_numLb:setString(count)
        if count>0 then
            lbTime:setString(GetTimeStr(timeConsume*count))
            for k,v in pairs(countTb) do
                v:setString(FormatNumber(tb[k].num2*count))
            end

        end

    end
    local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
    local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
    local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    slider:setTouchPriority(-(self.layerNum-1)*20-2);
    slider:setIsSallow(true);

    slider:setMinimumValue(0.0);

    local maxProductNum=100.0
    local tankLevel = tankCfg[m_tankIndex].tankLevel
    for k, v in pairs(playerCfg.tankProduct) do
        if tankLevel >= v.grade[1] and tankLevel <= v.grade[2] then
            maxProductNum=v.num
            break
        end
    end
    slider:setMaximumValue(maxProductNum);

    slider:setValue(0);
    slider:setPosition(ccp(355,-30))
    slider:setTag(99)
    container:addChild(slider,2)
    m_numLb:setString(math.floor(slider:getValue()))


    local function touchAdd()
        slider:setValue(slider:getValue()+1);
    end

    local function touchMinus()
        if slider:getValue()-1>0 then
            slider:setValue(slider:getValue()-1);
        end

    end

    local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
    addSp:setPosition(ccp(549,-30))
    container:addChild(addSp,1)
    addSp:setTouchPriority(-(self.layerNum-1)*20-3);

    local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
    minusSp:setPosition(ccp(157,-30))
    container:addChild(minusSp,1)
    minusSp:setTouchPriority(-(self.layerNum-1)*20-3);


    local function touch1()
        PlayEffect(audioCfg.mouseClick)
        local tid=tonumber(tankCfg[m_tankIndex].sid)
        local nums=math.floor(tonumber(slider:getValue()))
        local result,reson =tankVoApi:checkUpgradeBeforeSendServer(self.bid,tid,nums)

        local function doAddtanks()
            --成功添加
            local function serverUpgrade(fn,data)
                --local retTb=OBJDEF:decode(data)

                if base:checkServerData(data)==true then
                    if newGuidMgr:isNewGuiding() then --新手引导
                        newGuidMgr:toNextStep()
                    end
                    self:clearVar()
                    self:tabClick(2)

                end
            end
            socketHelper:addTanks(self.bid,tid,nums,serverUpgrade)
        end


        --reson 1:金币不足 2:队列不足
        if result==true then
            doAddtanks()
        else
            if reson ==1 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+1)
            elseif reson==2 then
                vipVoApi:showQueueFullDialog(2,self.layerNum+1,doAddtanks,self.bid)
            end
        end
    end
    local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("startProduce"),28,100)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(460,-93));
    menu1:setTouchPriority(-(self.layerNum-1)*20-2);
    container:addChild(menu1,3);
    local lb = menuItem1:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb,"CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end

    if tankCfg[m_tankIndex].propConsume~="" then
        local pid1 = tankCfg[m_tankIndex].propConsume[1][1]
        local pid2 = tankCfg[m_tankIndex].propConsume[2][1]
        local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
        local numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2)))

        if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) and numP1>=1 and numP2>=1
        then

            local tnum1=playerVoApi:getR1()/tonumber(reR1)
            local num1 = math.floor(tnum1)

            local tnum2=playerVoApi:getR2()/tonumber(reR2)
            local num2 = math.floor(tnum2)

            local tnum3=playerVoApi:getR3()/tonumber(reR3)
            local num3 = math.floor(tnum3)

            local tnum4=playerVoApi:getR4()/tonumber(reR4)
            local num4 = math.floor(tnum4)

            local numTab = {num1,num2,num3,num4}

            if tankCfg[m_tankIndex].propConsume~="" then
                local pid1 = tankCfg[m_tankIndex].propConsume[1][1]
                local pid2 = tankCfg[m_tankIndex].propConsume[2][1]
                local needP1 = tonumber(tankCfg[m_tankIndex].propConsume[1][2])
                local needP2 = tonumber(tankCfg[m_tankIndex].propConsume[2][2])
                local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
                local numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2)))
                table.insert(numTab,math.floor(numP1/needP1))
                table.insert(numTab,math.floor(numP2/needP2))
            end

            table.sort(numTab,function(a,b) return a<b end)
            if numTab[1]>maxProductNum then

                slider:setMaximumValue(maxProductNum);

            else

                slider:setMaximumValue(numTab[1]);

            end

            if numTab[1]==1 then
                slider:setMinimumValue(1.0);
                slider:setMaximumValue(1.0);
            else
                slider:setMinimumValue(1.0);
            end

            slider:setValue(numTab[1]);
            menuItem1:setEnabled(true)
        else
            slider:setMaximumValue(0);
            menuItem1:setEnabled(false)
            menu1:setTag(199)

        end

    else
        if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4)
        then

            local tnum1=playerVoApi:getR1()/tonumber(reR1)
            local num1 = math.floor(tnum1)

            local tnum2=playerVoApi:getR2()/tonumber(reR2)
            local num2 = math.floor(tnum2)

            local tnum3=playerVoApi:getR3()/tonumber(reR3)
            local num3 = math.floor(tnum3)

            local tnum4=playerVoApi:getR4()/tonumber(reR4)
            local num4 = math.floor(tnum4)

            local numTab = {num1,num2,num3,num4}

            table.sort(numTab,function(a,b) return a<b end)
            if numTab[1]>maxProductNum then

                slider:setMaximumValue(maxProductNum);

            else

                slider:setMaximumValue(numTab[1]);

            end

            if numTab[1]==1 then
                slider:setMinimumValue(1.0);
                slider:setMaximumValue(1.0);
            else
                slider:setMinimumValue(1.0);
            end

            slider:setValue(numTab[1]);
            menuItem1:setEnabled(true)
        else
            slider:setMaximumValue(0);
            menuItem1:setEnabled(false)
            menu1:setTag(199)

        end

    end

    if newGuidMgr:isNewGuiding() then --新手引导
        if self.selectedTabIndex==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
            slider:setValue(1);
        end
    end

    if self.expandUITab[idx+1] then
        self.expandUITab[idx+1].numLb=m_numLb
        self.expandUITab[idx+1].timeLb=lbTime
        self.expandUITab[idx+1].slider=slider
        self.expandUITab[idx+1].btn=menuItem1
    end

end
function tankFactoryDialog:exbgCellForId(idx,container)

    local m_tankIndex = self.tankResultTypeTab[idx+1]

    local typeLb=GetTTFLabel(getlocal("resourceType"),20)
    typeLb:setAnchorPoint(ccp(0.5,0.5))
    typeLb:setPosition(ccp(150,container:getContentSize().height-40))
    container:addChild(typeLb)

    local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
    resourceLb:setAnchorPoint(ccp(0.5,0.5))
    resourceLb:setPosition(ccp(300,container:getContentSize().height-40))
    container:addChild(resourceLb)

    local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
    haveLb:setAnchorPoint(ccp(0.5,0.5))
    haveLb:setPosition(ccp(450,container:getContentSize().height-40))
    container:addChild(haveLb)


    local r1Lb=GetTTFLabelWrap(getlocal("metal"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    r1Lb:setAnchorPoint(ccp(0.5,0.5))
    r1Lb:setPosition(ccp(150,container:getContentSize().height-100))
    container:addChild(r1Lb)

    local r2Lb=GetTTFLabelWrap(getlocal("oil"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    r2Lb:setAnchorPoint(ccp(0.5,0.5))
    r2Lb:setPosition(ccp(150,container:getContentSize().height-170))
    container:addChild(r2Lb)

    local r3Lb=GetTTFLabelWrap(getlocal("silicon"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    r3Lb:setAnchorPoint(ccp(0.5,0.5))
    r3Lb:setPosition(ccp(150,container:getContentSize().height-240))
    container:addChild(r3Lb)

    local r4Lb=GetTTFLabelWrap(getlocal("uranium"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    r4Lb:setAnchorPoint(ccp(0.5,0.5))
    r4Lb:setPosition(ccp(150,container:getContentSize().height-310))
    container:addChild(r4Lb)



    local r1Sp=CCSprite:createWithSpriteFrameName("resourse_normal_metal.png")
    r1Sp:setAnchorPoint(ccp(0.5,0.5))
    r1Sp:setPosition(ccp(40,container:getContentSize().height-100))
    r1Sp:setScale(0.5)
    container:addChild(r1Sp)


    local r2Sp=CCSprite:createWithSpriteFrameName("resourse_normal_oil.png")
    r2Sp:setAnchorPoint(ccp(0.5,0.5))
    r2Sp:setPosition(ccp(40,container:getContentSize().height-170))
    r2Sp:setScale(0.5)
    container:addChild(r2Sp)

    local r3Sp=CCSprite:createWithSpriteFrameName("resourse_normal_silicon.png")
    r3Sp:setAnchorPoint(ccp(0.5,0.5))
    r3Sp:setPosition(ccp(40,container:getContentSize().height-240))
    r3Sp:setScale(0.5)
    container:addChild(r3Sp)

    local r4Sp=CCSprite:createWithSpriteFrameName("resourse_normal_uranium.png")
    r4Sp:setAnchorPoint(ccp(0.5,0.5))
    r4Sp:setPosition(ccp(40,container:getContentSize().height-310))
    r4Sp:setScale(0.5)
    container:addChild(r4Sp)


    local needR1Lb=GetTTFLabel(FormatNumber(tankCfg[m_tankIndex].metalConsume),20)
    needR1Lb:setAnchorPoint(ccp(0.5,0.5))
    needR1Lb:setPosition(ccp(300,container:getContentSize().height-100))
    container:addChild(needR1Lb)

    local needR2Lb=GetTTFLabel(FormatNumber(tankCfg[m_tankIndex].oilConsume),20)
    needR2Lb:setAnchorPoint(ccp(0.5,0.5))
    needR2Lb:setPosition(ccp(300,container:getContentSize().height-170))
    container:addChild(needR2Lb)

    local needR3Lb=GetTTFLabel(FormatNumber(tankCfg[m_tankIndex].siliconConsume),20)
    needR3Lb:setAnchorPoint(ccp(0.5,0.5))
    needR3Lb:setPosition(ccp(300,container:getContentSize().height-240))
    container:addChild(needR3Lb)

    local needR4Lb=GetTTFLabel(FormatNumber(tankCfg[m_tankIndex].uraniumConsume),20)
    needR4Lb:setAnchorPoint(ccp(0.5,0.5))
    needR4Lb:setPosition(ccp(300,container:getContentSize().height-310))
    container:addChild(needR4Lb)

    local haveR1Lb=GetTTFLabel(FormatNumber(playerVoApi:getR1()),20)
    haveR1Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR1Lb:setPosition(ccp(450,container:getContentSize().height-100))
    container:addChild(haveR1Lb)

    local haveR2Lb=GetTTFLabel(FormatNumber(playerVoApi:getR2()),20)
    haveR2Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR2Lb:setPosition(ccp(450,container:getContentSize().height-170))
    container:addChild(haveR2Lb)

    local haveR3Lb=GetTTFLabel(FormatNumber(playerVoApi:getR3()),20)
    haveR3Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR3Lb:setPosition(ccp(450,container:getContentSize().height-240))
    container:addChild(haveR3Lb)

    local haveR4Lb=GetTTFLabel(FormatNumber(playerVoApi:getR4()),20)
    haveR4Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR4Lb:setPosition(ccp(450,container:getContentSize().height-310))
    container:addChild(haveR4Lb)


    local m_numLb=GetTTFLabel(" ",24)
    m_numLb:setPosition(70,-30);
    container:addChild(m_numLb,2);

    local timeConsume=tankVoApi:getProductTime(m_tankIndex,self.bid)
    local lbTime=GetTTFLabel(GetTimeStr(timeConsume),20)
    lbTime:setPosition(70,-80)
    lbTime:setAnchorPoint(ccp(0,0.5));
    container:addChild(lbTime,2)

    local function sliderTouch(handler,object)

        local count = math.floor(object:getValue())
        m_numLb:setString(count)



        if count>0 then
            local timeConsume=tankVoApi:getProductTime(m_tankIndex,self.bid)
            lbTime:setString(GetTimeStr(timeConsume*count))

            needR1Lb:setString(FormatNumber(tonumber(tankCfg[m_tankIndex].metalConsume)*count))
            needR2Lb:setString(FormatNumber(tonumber(tankCfg[m_tankIndex].oilConsume)*count))
            needR3Lb:setString(FormatNumber(tonumber(tankCfg[m_tankIndex].siliconConsume)*count))
            needR4Lb:setString(FormatNumber(tonumber(tankCfg[m_tankIndex].uraniumConsume)*count))

        end

    end
    local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
    local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
    local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    slider:setTouchPriority(-(self.layerNum-1)*20-2);
    slider:setIsSallow(true);
    slider:setTag(99)

    slider:setMinimumValue(0.0);

    slider:setMaximumValue(100.0);



    slider:setValue(0);
    slider:setPosition(ccp(355,-30))
    container:addChild(slider,2)
    m_numLb:setString(math.floor(slider:getValue()))



    --[[
    local function tthandler()
    end
    local bookmarkBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),tthandler)
    bookmarkBox:setContentSize(CCSizeMake(120,40))
    bookmarkBox:ignoreAnchorPointForPosition(false)
    bookmarkBox:setAnchorPoint(ccp(0,1))
    bookmarkBox:setIsSallow(false)
    bookmarkBox:setTouchPriority(-(self.layerNum-1)*20-2)
    bookmarkBox:setPosition(ccp(10,-10))
        --bookmarkBox:setOpacity(0)
    container:addChild(bookmarkBox,1)
        bookmarkBox:setVisible(false)
        
    local function callBackBookmarkHandler(fn,eB,str)
            if tonumber(str)==nil then
                        m_numLb:setString(self.m_lastNumValue)
                      eB:setText(self.m_lastNumValue)
             else
                 if tonumber(str)>=1 and tonumber(str)<=100 then
                     self.m_lastNumValue=tonumber(str)
                     slider:setValue(self.m_lastNumValue)
                     m_numLb:setString(1)
                 else
                      if tonumber(str)<1 then
                          m_numLb:setString(1)
                          eB:setText(1)
                          slider:setValue(1)
                          self.m_lastNumValue=1
                      end
                      if tonumber(str)>100 then
                          m_numLb:setString(100)
                          eB:setText(100)
                          self.m_lastNumValue=100
                          slider:setValue(tonumber(100))
                      end
                  m_numLb:setString(self.m_lastNumValue)
                 end
                 eB:setText(self.m_lastNumValue)
                 m_numLb:setString(self.m_lastNumValue)
            end
            

    end
    
    
    local customEditBox=customEditBox:new()
    local length=3
    customEditBox:init(bookmarkBox,m_numLb,"mail_input_bg.png",nil,-42,length,callBackBookmarkHandler,nil,CCEditBox.kEditBoxInputModePhoneNumber,false)]]

    local function touchAdd()
        if newGuidMgr:isNewGuiding() then --新手引导
            do
                return
        end
        end
        slider:setValue(slider:getValue()+1);
    end

    local function touchMinus()
        if newGuidMgr:isNewGuiding() then --新手引导
            do
                return
        end
        end
        if slider:getValue()-1>0 then
            slider:setValue(slider:getValue()-1);
        end

    end

    local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
    addSp:setPosition(ccp(552,-30))
    container:addChild(addSp,1)
    addSp:setTouchPriority(-(self.layerNum-1)*20-3);


    local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
    minusSp:setPosition(ccp(157,-30))
    container:addChild(minusSp,1)
    minusSp:setTouchPriority(-(self.layerNum-1)*20-3);


    --满足条件的对错号
    local p1Sp;
    if playerVoApi:getR1()>=tonumber(tankCfg[m_tankIndex].metalConsume) then
        p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
    else
        p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
    end
    p1Sp:setAnchorPoint(ccp(0.5,0.5))

    p1Sp:setPosition(ccp(400,container:getContentSize().height-100))

    container:addChild(p1Sp)

    local p2Sp;
    if playerVoApi:getR2()>=tonumber(tankCfg[m_tankIndex].oilConsume) then
        p2Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
    else
        p2Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
    end
    p2Sp:setAnchorPoint(ccp(0.5,0.5))

    p2Sp:setPosition(ccp(400,container:getContentSize().height-170))

    container:addChild(p2Sp)

    local p3Sp;
    if playerVoApi:getR3()>=tonumber(tankCfg[m_tankIndex].siliconConsume) then
        p3Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
    else
        p3Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
    end
    p3Sp:setAnchorPoint(ccp(0.5,0.5))

    p3Sp:setPosition(ccp(400,container:getContentSize().height-240))

    container:addChild(p3Sp)

    local p4Sp;
    if playerVoApi:getR4()>=tonumber(tankCfg[m_tankIndex].uraniumConsume) then
        p4Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
    else
        p4Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
    end
    p4Sp:setAnchorPoint(ccp(0.5,0.5))

    p4Sp:setPosition(ccp(400,container:getContentSize().height-310))

    container:addChild(p4Sp)


    local function touch1()
        PlayEffect(audioCfg.mouseClick)
        local tid=tonumber(tankCfg[m_tankIndex].sid)
        local nums=math.floor(tonumber(slider:getValue()))

        local result,reson =tankVoApi:checkUpgradeBeforeSendServer(self.bid,tid,nums)
        local function doAddtanks()
            --成功添加
            local function serverUpgrade(fn,data)
                --local retTb=OBJDEF:decode(data)

                if base:checkServerData(data)==true then
                    if newGuidMgr:isNewGuiding() then --新手引导
                        newGuidMgr:toNextStep()
                    end
                    self:clearVar()
                    self:tabClick(2)

                end
            end
            socketHelper:addTanks(self.bid,tid,nums,serverUpgrade)
        end
        --reson 1:金币不足 2:队列不足
        if result==true then
            doAddtanks()
        else
            if reson ==1 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+1)
            elseif reson==2 then
                vipVoApi:showQueueFullDialog(2,self.layerNum+1,doAddtanks,self.bid)
            end

        end


    end
    local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("startProduce"),28,100)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(460,-100));
    menu1:setTouchPriority(-(self.layerNum-1)*20-2);
    container:addChild(menu1,3);
    local lb = menuItem1:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb,"CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end

    if playerVoApi:getR1()>=tonumber(tankCfg[m_tankIndex].metalConsume) and playerVoApi:getR2()>=tonumber(tankCfg[m_tankIndex].oilConsume) and playerVoApi:getR3()>=tonumber(tankCfg[m_tankIndex].siliconConsume) and playerVoApi:getR4()>=tonumber(tankCfg[m_tankIndex].uraniumConsume) then

        local tnum1=playerVoApi:getR1()/tonumber(tankCfg[m_tankIndex].metalConsume)
        local num1 = math.floor(tnum1)

        local tnum2=playerVoApi:getR2()/tonumber(tankCfg[m_tankIndex].oilConsume)
        local num2 = math.floor(tnum2)

        local tnum3=playerVoApi:getR3()/tonumber(tankCfg[m_tankIndex].siliconConsume)
        local num3 = math.floor(tnum3)

        local tnum4=playerVoApi:getR4()/tonumber(tankCfg[m_tankIndex].uraniumConsume)
        local num4 = math.floor(tnum4)

        local numTab = {num1,num2,num3,num4}
        table.sort(numTab,function(a,b) return a<b end)
        if numTab[1]>100 then

            slider:setMaximumValue(100);

        else

            slider:setMaximumValue(numTab[1]);

        end


        if numTab[1]==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
        else
            slider:setMinimumValue(1.0);
        end

        slider:setValue(numTab[1]);
        menuItem1:setEnabled(true)
    else
        slider:setMaximumValue(0);
        menuItem1:setEnabled(false)
        menu1:setTag(199)

    end

    if newGuidMgr:isNewGuiding() then --新手引导
        if self.selectedTabIndex==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
            slider:setValue(1);
    end
    end



end

function tankFactoryDialog:refreshExpandUIData()
    if self.expandUITab and self.tankResultTypeTab then
        for i=1, SizeOfTable(self.tankResultTypeTab) do
            if self.expandUITab[i] and self.expandUITab[i].resUITab then
                local resUITab = self.expandUITab[i].resUITab
                local m_tankIndex = self.tankResultTypeTab[i]
                local reR1,reR2,reR3,reR4,reUpgradedTime = tankVoApi:getProduceTankResources(m_tankIndex)

                local tab={
                    { haveStr=FormatNumber(playerVoApi:getR1()),num=playerVoApi:getR1(),needNum=tonumber(reR1) },
                    { haveStr=FormatNumber(playerVoApi:getR2()),num=playerVoApi:getR2(),needNum=tonumber(reR2) },
                    { haveStr=FormatNumber(playerVoApi:getR3()),num=playerVoApi:getR3(),needNum=tonumber(reR3) },
                    { haveStr=FormatNumber(playerVoApi:getR4()),num=playerVoApi:getR4(),needNum=tonumber(reR4) },
                }
                for k,v in pairs(tab) do
                    if resUITab[k] then
                        if resUITab[k].resLb and tolua.cast(resUITab[k].resLb,"CCLabelTTF") then
                            local resLb = tolua.cast(resUITab[k].resLb,"CCLabelTTF")
                            resLb:setString(v.haveStr)
                        end
                        if v.num>=v.needNum then
                            if resUITab[k].leftSp and tolua.cast(resUITab[k].leftSp,"CCSprite") then
                                local leftSp = tolua.cast(resUITab[k].leftSp,"CCSprite")
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("IconCheck.png")
                                if frame then
                                    leftSp:setDisplayFrame(frame)
                                end
                            end
                            if resUITab[k].rightSp and tolua.cast(resUITab[k].rightSp,"CCSprite") then
                                local rightSp = tolua.cast(resUITab[k].rightSp,"CCSprite")
                                rightSp:removeFromParentAndCleanup(true)
                                resUITab[k].rightSp=nil
                            end
                        end
                    end
                end
                local _flag = false
                local slider = self.expandUITab[i].slider
                if slider then
                    if tankCfg[m_tankIndex].propConsume~="" then
                        local pid1 = tankCfg[m_tankIndex].propConsume[1][1]
                        local pid2 = tankCfg[m_tankIndex].propConsume[2][1]
                        local needP1 = tonumber(tankCfg[m_tankIndex].propConsume[1][2])
                        local needP2 = tonumber(tankCfg[m_tankIndex].propConsume[2][2])
                        local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
                        local numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2)))

                        if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) and numP1>=1 and numP2>=1 then
                            local tnum1=playerVoApi:getR1()/tonumber(reR1)
                            local num1 = math.floor(tnum1)

                            local tnum2=playerVoApi:getR2()/tonumber(reR2)
                            local num2 = math.floor(tnum2)

                            local tnum3=playerVoApi:getR3()/tonumber(reR3)
                            local num3 = math.floor(tnum3)

                            local tnum4=playerVoApi:getR4()/tonumber(reR4)
                            local num4 = math.floor(tnum4)

                            local numTab = {num1,num2,num3,num4}

                            if tankCfg[m_tankIndex].propConsume~="" then
                                local pid1 = tankCfg[m_tankIndex].propConsume[1][1]
                                local pid2 = tankCfg[m_tankIndex].propConsume[2][1]
                                local numP1 = math.floor(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))/needP1)
                                local numP2 = math.floor(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2)))/needP2)
                                table.insert(numTab,numP1)
                                table.insert(numTab,numP2)
                            end
                            table.sort(numTab,function(a,b) return a<b end)
                            if numTab[1]>100 then
                                slider:setMaximumValue(100);
                            else
                                slider:setMaximumValue(numTab[1]);
                            end
                            if numTab[1]==1 then
                                slider:setMinimumValue(1.0);
                                slider:setMaximumValue(1.0);
                            else
                                slider:setMinimumValue(1.0);
                            end
                            slider:setValue(numTab[1]);
                            if self.expandUITab[i].btn then
                                self.expandUITab[i].btn:setEnabled(true)
                            end
                            _flag=true
                        end
                    else
                        if playerVoApi:getR1()>=tonumber(reR1) and playerVoApi:getR2()>=tonumber(reR2) and playerVoApi:getR3()>=tonumber(reR3) and playerVoApi:getR4()>=tonumber(reR4) then
                            local tnum1=playerVoApi:getR1()/tonumber(reR1)
                            local num1 = math.floor(tnum1)

                            local tnum2=playerVoApi:getR2()/tonumber(reR2)
                            local num2 = math.floor(tnum2)

                            local tnum3=playerVoApi:getR3()/tonumber(reR3)
                            local num3 = math.floor(tnum3)

                            local tnum4=playerVoApi:getR4()/tonumber(reR4)
                            local num4 = math.floor(tnum4)

                            local numTab = {num1,num2,num3,num4}

                            table.sort(numTab,function(a,b) return a<b end)
                            if numTab[1]>100 then
                                slider:setMaximumValue(100);
                            else
                                slider:setMaximumValue(numTab[1]);
                            end

                            if numTab[1]==1 then
                                slider:setMinimumValue(1.0);
                                slider:setMaximumValue(1.0);
                            else
                                slider:setMinimumValue(1.0);
                            end

                            slider:setValue(numTab[1]);
                            if self.expandUITab[i].btn then
                                self.expandUITab[i].btn:setEnabled(true)
                            end
                            _flag=true
                        end
                    end
                    if _flag==true then
                        local count=math.floor(slider:getValue())
                        if self.expandUITab[i].numLb and tolua.cast(self.expandUITab[i].numLb,"CCLabelTTF") then
                          local numLb = tolua.cast(self.expandUITab[i].numLb,"CCLabelTTF")
                          numLb:setString(count)
                        end
                        if self.expandUITab[i].timeLb and tolua.cast(self.expandUITab[i].timeLb,"CCLabelTTF") then
                            local timeLb = tolua.cast(self.expandUITab[i].timeLb,"CCLabelTTF")
                            local timeConsume=tankVoApi:getProductTime(m_tankIndex,self.bid)
                            timeLb:setString(GetTimeStr(timeConsume*count))
                        end
                        for k,v in pairs(tab) do
                            if resUITab[k] and resUITab[k].needLb and tolua.cast(resUITab[k].needLb,"CCLabelTTF") then
                                local needLb = tolua.cast(resUITab[k].needLb,"CCLabelTTF")
                                needLb:setString(FormatNumber(v.needNum*count))
                            end
                        end
                        if self.expandUITab[i].cellBtn and tolua.cast(self.expandUITab[i].cellBtn,"CCSprite") then
                            local cellBtn = tolua.cast(self.expandUITab[i].cellBtn,"CCSprite")
                            local sp = CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
                            sp:setAnchorPoint(cellBtn:getAnchorPoint())
                            sp:setPosition(cellBtn:getPosition())
                            sp:setTag(cellBtn:getTag())
                            cellBtn:getParent():addChild(sp)
                            cellBtn:removeFromParentAndCleanup(true)
                            self.expandUITab[i].cellBtn=nil
                        end
                    end
                end

                if _flag==true then
                    self.expandUITab[i]=nil
                end
            end
        end
    end
end

function tankFactoryDialog:tick()
    self:judgeProduceTank()
    if buildingVoApi:getBuildiingVoByBId(self.bid).level>0 then
        for k,v in pairs(self.allTabs) do
            local  tabBtnItem=v
            tabBtnItem:setVisible(true)
        end
    end
    if self.selectedTabIndex==0 then
        if self.upgradeDialog then
            self.upgradeDialog:tick()
        end
    elseif self.selectedTabIndex==1 then
        self.tankSoltTab={}
        self.tankSoltTab=tankSlotVoApi:getAllSolts(self.bid)
        for k,v in pairs(self.tickNumLbTab) do
            local numLb=v
            if numLb~=nil then
                numLb=tolua.cast(numLb,"CCLabelTTF")
                numLb:setString(getlocal("schedule_ship_num",{tankVoApi:getTankCountByItemId(k)}))
            end

        end
        self:refreshExpandUIData()
    elseif self.selectedTabIndex==2 then
        for k,v in pairs(self.tickTabCell) do

            if tankSlotVoApi:getSlotBySlotid(self.bid,self.tankSoltTab[k].slotId)==nil then
                self:clearVar()
                do
                    return
                end
            end
            if self.tankSoltTab[k].status==1 then

                local cell = self.tickTabCell[k]
                local ccprogress=cell:getChildByTag(10)
                ccprogress=tolua.cast(ccprogress,"CCProgressTimer")
                local leftTime,totalTime= tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.bid,self.tankSoltTab[k].slotId)

                local per = (totalTime-leftTime)/totalTime*100
                ccprogress:setPercentage(per)

                local timeLb = ccprogress:getChildByTag(11)
                timeLb=tolua.cast(timeLb,"CCLabelTTF")
                local strTime= GetTimeStr(tankSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.bid,self.tankSoltTab[k].slotId))
                timeLb:setString(strTime)
                if leftTime<=0 then

                    self:clearVar()

                end
            end

        end
    end


    local alienTechOpenLv=base.alienTechOpenLv or 22
    if base.alien==1 and base.richMineOpen==1 and newGuidMgr:isNewGuiding()==false and playerVoApi:getPlayerLevel()>=alienTechOpenLv then
        if self and self.tv and alienTechVoApi and alienTechVoApi.getFlag and alienTechVoApi:getFlag()==-1 and alienTechVoApi.getTechData then
            local function refreshTv()
                if self.selectedTabIndex==2 then
                    local recordPoint=self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)
                end
            end
            alienTechVoApi:getTechData(refreshTv)
        end
    end

end


function tankFactoryDialog:clearVar()
    self.tankSoltTab={}
    self.tankSoltTab=tankSlotVoApi:getAllSolts(self.bid)
    self.tickTabCell={}
    if(self.tv)then
        self.tv:reloadData()
    end

end

function tankFactoryDialog:dispose()
    if self.speedUpSmallDialog then
        self.speedUpSmallDialog:close()
        self.speedUpSmallDialog = nil
    end
    self.isShowPoint=nil
    self.layerNum=nil
    self.tickNumLbTab={}
    self.tickNumLbTab=nil
    self.expandIdx=nil
    self.islandStateTab=nil
    self.expandHeight=nil
    self.normalHeight=nil
    self.extendSpTag=nil
    self.headTab=nil
    self.expandUITab=nil
    self.upgradeDialog:dispose()
    self.upgradeDialog=nil
    eventDispatcher:removeEventListener("tankslot.speedup",self.speedUpListener)
    self.buildIdx=nil
    self.taskVo=nil
    self.guildItem=nil
    self=nil
end

function tankFactoryDialog:againAssignmentTab()
    self.tankResultTypeTab,self.tankResultLockTab,self.tankResultCountTab=tankVoApi:getAllTankTypeAndCoutByBid(self.bid)

end





