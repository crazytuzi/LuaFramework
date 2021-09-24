--require "luascript/script/componet/commonDialog"
tankDefenseDialog=commonDialog:new()

function tankDefenseDialog:new(layerNum,isGuide)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.myLayerTab1=nil
    
    self.playerTab2=nil
    self.myLayerTab2=nil

    self.playerTab3=nil
    self.myLayerTab3=nil
    self.isShowTank = 1
    self.layerNum=layerNum
    self.recordDefenseTanks={}
    
    for k,v in pairs(tankVoApi:getTemDefenseTanks()) do
        local tid=v[1]
        local num=v[2]
        tankVoApi:setTanksByType(1,k,tid,num)
    end

    self.heroTb=G_clone(heroVoApi:getDefHeroList())
    self.AITroopsTb=G_clone(AITroopsFleetVoApi:getDefAITroopsList())

  self.isGuide=isGuide;
    
    return nc
end

--设置或修改每个Tab页签
function tankDefenseDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(120,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(520,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

--设置对话框里的tableView
function tankDefenseDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setTableViewTouchPriority(1)
    self.tv:setPosition(ccp(3000,30))
    --self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    self.myLayerTab1=CCLayer:create();
    self.bgLayer:addChild(self.myLayerTab1)

    self:initTab1Layer();
    
    
    require "luascript/script/game/scene/gamedialog/warDialog/tankDialogTab2"
    self.playerTab2=tankDialogTab2:new()
    self.myLayerTab2=self.playerTab2:init(self,1,self.layerNum)
    self.bgLayer:addChild(self.myLayerTab2);
    self.myLayerTab2:setPosition(ccp(999333,0))
    self.myLayerTab2:setVisible(false)
    
    require "luascript/script/game/scene/gamedialog/warDialog/tankDialogTab3"
    self.playerTab3=tankDialogTab3:new()
    self.myLayerTab3=self.playerTab3:init(self.layerNum,self.isGuide)
    self.bgLayer:addChild(self.myLayerTab3);
    self.myLayerTab3:setPosition(ccp(999333,0))
    self.myLayerTab3:setVisible(false)

    for k,v in pairs(tankVoApi:getTanksTbByType(1)) do
        local tid=v[1]
        local num=v[2]
        self.recordDefenseTanks[k]={tid,num}
    end
end
function tankDefenseDialog:initTab1Layer()

    local tHeight = G_VisibleSize.height-260
    local posHeight = tHeight-500-25
    if G_getIphoneType() == G_iphoneX then
        posHeight = posHeight - 50
    end
    local strSize2 = 20
    if G_isIphone5() ==true then
        posHeight=posHeight-105
        strSize2=25
    end
    local strSize3 = 25
    if G_getCurChoseLanguage()=="ru" then
        strSize3 =19
    end

    local defLbNum = GetTTFLabelWrap(getlocal("showDefenceFleetText"),strSize2,CCSizeMake(580,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
    defLbNum:setAnchorPoint(ccp(0.5,0.5));
    defLbNum:setPosition(ccp(G_VisibleSize.width/2,posHeight));
    self.myLayerTab1:addChild(defLbNum,2);

    local defPromptLb = GetTTFLabelWrap(getlocal("setFleet_des"),strSize2,CCSizeMake(580,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    defPromptLb:setAnchorPoint(ccp(0.5,0.5))
    defPromptLb:setPosition(ccp(G_VisibleSize.width/2,posHeight-35))
    if G_isIphone5()==true then
        defPromptLb:setPosition(ccp(G_VisibleSize.width/2,posHeight-60))
    end
    defPromptLb:setColor(G_ColorYellowPro)
    self.myLayerTab1:addChild(defPromptLb,2)

    local function arrangeTroops()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:arrangeTroops()
    end
    local arrangeItem1=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",arrangeTroops,nil,getlocal("arrange_name"),25,101)
    -- arrangeItem1:setScale(0.8)
    -- local lb = arrangeItem1:getChildByTag(101)
    -- if lb then
    --     lb = tolua.cast(lb,"CCLabelTTF")
    --     lb:setFontName("Helvetica-bold")
    -- end
    local arrangeMenu1=CCMenu:createWithItem(arrangeItem1)
    arrangeMenu1:setPosition(ccp(520,80))
    arrangeMenu1:setTouchPriority((-(self.layerNum-1)*20-4))
    self.myLayerTab1:addChild(arrangeMenu1)

    local arrangeItem2=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",arrangeTroops,nil,getlocal("arrange_name"),25,101)
    -- arrangeItem2:setScale(0.8)
    -- local lb = arrangeItem2:getChildByTag(101)
    -- if lb then
    --     lb = tolua.cast(lb,"CCLabelTTF")
    --     lb:setFontName("Helvetica-bold")
    -- end
    local arrangeMenu2=CCMenu:createWithItem(arrangeItem2)
    arrangeMenu2:setPosition(ccp(520,80))
    arrangeMenu2:setTouchPriority((-(self.layerNum-1)*20-4))
    self.myLayerTab1:addChild(arrangeMenu2)

    local function callback(flag)
        self.isShowTank=flag+1
        if flag==0 then
            arrangeMenu2:setVisible(false)
            arrangeMenu1:setVisible(true)
        else
            arrangeMenu1:setVisible(false)
            arrangeMenu2:setVisible(true)
        end
    end
    G_addSelectTankLayer(1,self.myLayerTab1,self.layerNum,callback)

    local function readCallback(tank,hero)
    end
    local formationMenu=G_getFormationBtn(self.myLayerTab1,self.layerNum,self.isShowTank,1,readCallback)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function tankDefenseDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
           return 1
   elseif fn=="tableCellSizeForIndex" then
   
       local tmpSize
        tmpSize=CCSizeMake(600,140)
       return  tmpSize

   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        return cell;

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--点击tab页签 idx:索引
function tankDefenseDialog:tabClick(idx)
        PlayEffect(audioCfg.mouseClick)
        for k,v in pairs(self.allTabs) do
             if v:getTag()==idx then
                v:setEnabled(false)
                self.selectedTabIndex=idx

                self:doUserHandler()
                
                
             else
                v:setEnabled(true)
             end

        end
    if self.selectedTabIndex==0 then
        self.myLayerTab1:setVisible(true)
        self.myLayerTab1:setPosition(ccp(0,0))
        
        self.myLayerTab2:setVisible(false)
        self.myLayerTab2:setPosition(ccp(99999,0))

        self.myLayerTab3:setVisible(false)
        self.myLayerTab3:setPosition(ccp(99999,0))
   self.playerTab3:removeGuied()

    elseif self.selectedTabIndex==1 then
        self.myLayerTab1:setVisible(false)
        self.myLayerTab1:setPosition(ccp(10000,0))
        
        self.myLayerTab2:setVisible(true)
        self.myLayerTab2:setPosition(ccp(0,0))

        self.myLayerTab3:setVisible(false)
        self.myLayerTab3:setPosition(ccp(99999,0))
   self.playerTab3:removeGuied()


    elseif self.selectedTabIndex==2 then
        self.myLayerTab1:setVisible(false)
        self.myLayerTab1:setPosition(ccp(10000,0))
        
        self.myLayerTab2:setVisible(false)
        self.myLayerTab2:setPosition(ccp(99999,0))

        self.myLayerTab3:setVisible(true)
        self.myLayerTab3:setPosition(ccp(0,0))
    
    end
    
    self:againAssignmentTab()
    --self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function tankDefenseDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function tankDefenseDialog:cellClick(idx)
    if self.selectedTabIndex==2 then
        return
    end
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            --self.requires[idx-1000+1]:dispose()
            --self.requires[idx-1000+1]=nil
            --self.allCellsBtn[idx-1000+1]=nil
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end


function tankDefenseDialog:tick()
 local allSlots=SizeOfTable(attackTankSoltVoApi:getAllAttackTankSlots())
 if allSlots>0 then
    self:setTipsVisibleByIdx(true,2,allSlots)
 else
    self:setTipsVisibleByIdx(false,2)
 end
 local repairTanks=SizeOfTable(tankVoApi:getRepairTanks())
 if repairTanks>0 then
    self:setTipsVisibleByIdx(true,3,repairTanks)
 else
    self:setTipsVisibleByIdx(false,3)
 end

    if self.selectedTabIndex==1 then
        self.playerTab2:tick()
    elseif self.selectedTabIndex==2 then
        self.playerTab3:tick()
    end
    
end


function tankDefenseDialog:clearVar()
    
    self.tv:reloadData()

end

function tankDefenseDialog:arrangeTroops()
    local isChange=self:isTroopsChanged()
    local defenseTab=tankVoApi:getTanksTbByType(1)
    -- G_dayin(defenseTab)
    local htb=nil
    htb = heroVoApi:getMachiningHeroList(defenseTab)
    local tipStr
    local hasTroops=heroVoApi:isHaveTroops()
    if hasTroops==false then
        htb=nil
    end
    local aitTb=AITroopsFleetVoApi:getMatchAITroopsList(defenseTab)

    if isChange==false then
        tipStr=getlocal("arrange_nochange_troops_tip")
    end
    if tipStr then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30)
    end


    if isChange==true then
        local function serverSetdefenseTroop(fn,data)
            local ret, sData = base:checkServerData(data)
            if ret==true then
                if htb==nil then
                    htb={0,0,0,0,0,0}
                end
                heroVoApi:setDefHeroList(htb)
                AITroopsFleetVoApi:setDefAITroopsList(aitTb)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arrange_troops_success"),30)

                for k,v in pairs(defenseTab) do
                    local tid=v[1]
                    local num=v[2]
                    self.recordDefenseTanks[k]={tid,num}
                end
                self.heroTb=G_clone(heroVoApi:getDefHeroList())
                self.AITroopsTb=G_clone(AITroopsFleetVoApi:getDefAITroopsList())
                local emblemID = emblemVoApi:getTmpEquip()
                emblemVoApi:setBattleEquip(1,emblemID)
                local planePos = planeVoApi:getTmpEquip()
                planeVoApi:setBattleEquip(1,planePos)
                local airshipId = airShipVoApi:getTempLineupId()
                airShipVoApi:setBattleEquip(1,airshipId)
            end
        end
        local emblemID = emblemVoApi:getTmpEquip()
        local planePos = planeVoApi:getTmpEquip()
        local airshipId = airShipVoApi:getTempLineupId()
        socketHelper:setdefenseTroop(defenseTab,serverSetdefenseTroop,htb,emblemID,planePos,aitTb,airshipId)
    end
end

function tankDefenseDialog:forceClose()
    if self.isCloseing==true then
        do return end
    end
    if self.isCloseing==false then
        self.isCloseing=true
    end
    base.allShowedCommonDialog=base.allShowedCommonDialog-1
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
         if v==self then
             table.remove(base.commonDialogOpened_WeakTb,k)
             break
         end
    end
    if base.allShowedCommonDialog<0 then
        base.allShowedCommonDialog=0
    end
    if newGuidMgr and newGuidMgr:isNewGuiding() and (newGuidMgr.curStep==9 or newGuidMgr.curStep==46 or newGuidMgr.curStep==17 or newGuidMgr.curStep==35 or newGuidMgr.curStep==41) then --新手引导
        newGuidMgr:toNextStep()
    end
    -- if base.allShowedCommonDialog==0 and storyScene.isShowed==false then
    if base.allShowedCommonDialog==0 and storyScene and storyScene.isShowed==false and battleScene and battleScene.isBattleing==false then
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setShow()
            elseif sceneController.curIndex==1 then
                mainLandScene:setShow()
            elseif sceneController.curIndex==2 then
                worldScene:setShow()
            end
            mainUI:setShow()
        end
    end
    base:removeFromNeedRefresh(self) --停止刷新
    self:realClose()
end

function tankDefenseDialog:close(hasAnim)
    local function closeHandler()
        if self.isCloseing==true then
            do return end
        end
        if self.isCloseing==false then
            self.isCloseing=true
        end

        if hasAnim==nil then
            hasAnim=true
        end
        base.allShowedCommonDialog=base.allShowedCommonDialog-1
        for k,v in pairs(base.commonDialogOpened_WeakTb) do
             if v==self then
                 table.remove(base.commonDialogOpened_WeakTb,k)
                 break
             end
        end
        if base.allShowedCommonDialog<0 then
            base.allShowedCommonDialog=0
        end
        if newGuidMgr and newGuidMgr:isNewGuiding() and (newGuidMgr.curStep==9 or newGuidMgr.curStep==46 or newGuidMgr.curStep==17 or newGuidMgr.curStep==35 or newGuidMgr.curStep==41) then --新手引导
                newGuidMgr:toNextStep()
        end
        local function realClose()
            return self:realClose()
        end
        -- if base.allShowedCommonDialog==0 and storyScene.isShowed==false then
        if base.allShowedCommonDialog==0 and storyScene and storyScene.isShowed==false and battleScene and battleScene.isBattleing==false then
                    if portScene.clayer~=nil then
                        if sceneController.curIndex==0 then
                            portScene:setShow()
                        elseif sceneController.curIndex==1 then
                            mainLandScene:setShow()
                        elseif sceneController.curIndex==2 then
                            worldScene:setShow()
                        end
                        mainUI:setShow()
                    end
        end
         base:removeFromNeedRefresh(self) --停止刷新
       local time=0.3
       if newGuidMgr and newGuidMgr.curStep==16 then
          time=0;
       end
       local fc= CCCallFunc:create(realClose)
       local moveTo=CCMoveTo:create((hasAnim==true and time or 0),CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
       local acArr=CCArray:create()
       acArr:addObject(moveTo)
       acArr:addObject(fc)
       local seq=CCSequence:create(acArr)
       self.bgLayer:runAction(seq)
    end

    local isChange=self:isTroopsChanged()
    local function sureHandler()
        self:arrangeTroops()
        closeHandler()
    end
    local function cancelHandler()
        closeHandler()
    end
    if isChange==true then
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureHandler,getlocal("dialog_title_prompt"),getlocal("arrange_troops_change_tip"),nil,self.layerNum+1,nil,nil,cancelHandler)
    else
        closeHandler()
    end
end

function tankDefenseDialog:doSendOnClose()

end

function tankDefenseDialog:isTroopsChanged()
    local isChange=false
    local defenseTab=tankVoApi:getTanksTbByType(1)
    for k,v in pairs(defenseTab) do
        if v[1]~=self.recordDefenseTanks[k][1] or v[2]~=self.recordDefenseTanks[k][2] then
            isChange=true
        end
        if v[2]==0 then
            isChange=false
            break
        end
    end
    local htb=nil
    htb = heroVoApi:getMachiningHeroList(defenseTab)
    if htb~=nil then
        for k,v in pairs(htb) do
            if v~=self.heroTb[k] then
                isChange=true
                break
            end
        end
    end
    --检测AI部队是否发生变化
    local aitTb=nil
    aitTb = AITroopsFleetVoApi:getMatchAITroopsList(defenseTab)
    if aitTb~=nil then
        for k,v in pairs(aitTb) do
            print("k,v,self.AITroopsTb[k]===>>>",k,v,self.AITroopsTb[k])
            if v~=self.AITroopsTb[k] then
                isChange=true
                break
            end
        end
    end
    -- 检查军徽是否改变
    local tmpEmblemID = emblemVoApi:getTmpEquip(1)
    local emblemID = emblemVoApi:getBattleEquip(1)
    if tmpEmblemID~=emblemID then
        isChange = true
    end
    -- 检查飞机是否改变
    local tmpPlanePos = planeVoApi:getTmpEquip(1)
    local planePos = planeVoApi:getBattleEquip(1)
    if tmpPlanePos~=planePos then
        isChange = true
    end
    -- 检查飞艇是否改变
    local tmpAirShipId = airShipVoApi:getTempLineupId()
    local airShipId = airShipVoApi:getBattleEquip(1)
    if tmpAirShipId ~= airShipId then
        isChange = true
    end
    return isChange
end

function tankDefenseDialog:dispose()
    self.playerTab2:dispose()
    self.playerTab3:dispose()
    tankVoApi:clearTanksTbByType(1)
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
    airShipVoApi:setTempLineupId(nil)
    self.AITroopsTb=nil
    self=nil
end

function tankDefenseDialog:againAssignmentTab()


end