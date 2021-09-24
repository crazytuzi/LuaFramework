alienMinesTankAttackDialog=commonDialog:new()

function alienMinesTankAttackDialog:new(type,isLandTab,layerNum,isAlienMines,attackType,parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bid=bid
    self.leftBtn=nil
    self.expandIdx={}
    self.myLayerTab1=nil
    
    self.playerTab2=nil
    self.myLayerTab2=nil

    self.playerTab3=nil
    self.myLayerTab3=nil
    
    self.layerNum=layerNum
    self.parent=parent

    self.isAlienMines=isAlienMines
    
    if type==6 then
        self.attackType=0
    else
        if CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_fleetArrive")==1 then
            self.attackType=0
        else
            self.attackType=1
        end
    end

    -- 是否是异星矿场
    if isAlienMines==true then
        self.attackType=attackType
    end
    
    self.isLandTab=isLandTab
  self.addBtn=nil
    self.isShowTank=1
    
    return nc
end

--设置或修改每个Tab页签
function alienMinesTankAttackDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end

         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

--设置对话框里的tableView
function alienMinesTankAttackDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    self.myLayerTab1=CCLayer:create();
    self.bgLayer:addChild(self.myLayerTab1)
    self:initTab1Layer();

    require "luascript/script/game/scene/gamedialog/warDialog/tankDialogTab3"
    self.playerTab2=tankDialogTab3:new()
    self.myLayerTab2=self.playerTab2:init(self.layerNum)
    self.bgLayer:addChild(self.myLayerTab2);
    self.myLayerTab2:setPosition(ccp(999333,0))
    self.myLayerTab2:setVisible(false)
    
  
  if playerVoApi:getPlayerLevel()<=15 and newGuidMgr:isNewGuiding()==false then
   local function showTip()
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("needFleet"),28,getCenterPoint(sceneGame))
    end
   local delayTime = CCDelayTime:create(0.5);
   local fc= CCCallFunc:create(showTip)
   local acArr=CCArray:create()
   acArr:addObject(delayTime)
   acArr:addObject(fc)
   local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)

   end

end
function alienMinesTankAttackDialog:initTab1Layer()
    
    local tHeight = G_VisibleSize.height-260

    -- local soldiersLb = GetTTFLabel(getlocal("player_leader_troop_num",{playerVoApi:getTroopsLvNum()}),26);
    -- soldiersLb:setAnchorPoint(ccp(0,0.5));
    -- soldiersLb:setPosition(ccp(110,tHeight+60));
    -- self.myLayerTab1:addChild(soldiersLb,2);
    
    -- local soldiersLbNum = GetTTFLabel("+"..playerVoApi:getExtraTroopsNum(),26);
    -- soldiersLbNum:setColor(G_ColorGreen)
    -- soldiersLbNum:setAnchorPoint(ccp(0,0.5));
    -- soldiersLbNum:setPosition(ccp(soldiersLb:getPositionX()+soldiersLb:getContentSize().width,tHeight+60));
    -- self.myLayerTab1:addChild(soldiersLbNum,2);

    -- local help=nil
    -- if self.isLandTab.allianceName and allianceVoApi:isSameAlliance(self.isLandTab.allianceName) then
    --     help=true
    -- end
    
    -- local selfCoord={playerVoApi:getMapX(),playerVoApi:getMapY()}
    -- local targetCoord={self.isLandTab.x,self.isLandTab.y}
    -- local moveTime=GetTimeStr(MarchTimeConsume(selfCoord,targetCoord,help))

    -- local fleetload=FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(16)))
    -- local fleetLb=GetTTFLabel(getlocal("fleetload",{fleetload}),26);
    -- fleetLb:setAnchorPoint(ccp(0,0.5));
    -- fleetLb:setPosition(ccp(110,tHeight));
    -- self.myLayerTab1:addChild(fleetLb,2);
    -- fleetLb:setTag(19)
    -- fleetLb:setPosition(ccp(110,tHeight+20))

    
    -- local targetLb=GetTTFLabel(getlocal("targetPostion",{0}),26);
    -- targetLb:setAnchorPoint(ccp(0,0.5));
    -- targetLb:setPosition(ccp(110+50,tHeight-530));
    -- self.myLayerTab1:addChild(targetLb,2);
    
    -- local xx=self.isLandTab.x
    -- local xlbWidth = 0
    -- if G_getCurChoseLanguage() =="ru" then
    --     xlbWidth =30
    -- end
    -- print("xlbWidth....",xlbWidth)
    -- local xLabel=GetTTFLabel("X".."   "..xx,30)
    -- xLabel:setAnchorPoint(ccp(0,0.5))
    -- xLabel:setPosition(ccp(300+xlbWidth,tHeight-530))
    --  self.myLayerTab1:addChild(xLabel)
     
     
    -- local yy=self.isLandTab.y
    -- local yLabel=GetTTFLabel("Y".."   "..yy,30)
    -- yLabel:setAnchorPoint(ccp(0,0.5))
    -- yLabel:setPosition(ccp(420+xlbWidth,tHeight-530))
    --  self.myLayerTab1:addChild(yLabel)

    -- targetLb:setPosition(ccp(90,tHeight-530));
    -- xLabel:setPosition(280+xlbWidth,tHeight-530)
    -- yLabel:setPosition(400+xlbWidth,tHeight-530)



    local function changeHandler(flag)
        self.isShowTank=flag+1
    end
    G_addSelectTankLayer(16,self.myLayerTab1,self.layerNum,changeHandler,nil,nil,self.isLandTab)


    local isFirst=false
    
    local function touchFight1()
       
        local function touchFight()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

       

            PlayEffect(audioCfg.mouseClick)
            --playerVoApi:getVipLevel()
            local fleetsNums=Split(playerCfg.actionFleets,",")[playerVoApi:getVipLevel()+1] 
            
            if attackTankSoltVoApi:getAllTankSlotsNum()>=tonumber(fleetsNums) then
                self:close(false);
                vipVoApi:showQueueFullDialog(6,self.layerNum+1)
                do
                    return
                end
            
            end
            
            -- if playerVoApi:getEnergy()==0 then
            --     local function buyEnergy()
            --         G_buyEnergy(self.layerNum+1)
            --     end
            --     smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyEnergy,getlocal("dialog_title_prompt"),getlocal("energyis0"),nil,self.layerNum+1)
            --     do
            --         return
            --     end
            -- end

            local isEableAttack=true
            local num=0;
           
            for k,v in pairs(tankVoApi:getTanksTbByType(16)) do
                if SizeOfTable(v)==0 then
                    num=num+1;
                end
            end
          
            
            if num==6 then
                isEableAttack=false
            end
            
            if isEableAttack==false then
               local function addFlicker()
                    if self.addBtn then
                        G_addFlickerByTimes(self.addBtn,4.2,4.2,getCenterPoint(self.addBtn),3)
                    end
               end
               smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("needFleet"),nil,9,nil,addFlicker)
               do
                 return
               end
            end
            
            local function serverAttack(fn,data)
              --local retTb=OBJDEF:decode(data)
              local ret,sData=base:checkServerData(data)

              if ret==true then
                if sData and sData.data and sData.data.report then
                    local report=sData.data.report

                    -- local params = {uid=playerVoApi:getUid(),x=self.isLandTab.x,y=self.isLandTab.y}
                    -- chatVoApi:sendUpdateMessage(21,params)

                    if report.r and ((type(report.r)=="table" and SizeOfTable(report.r)>0) or (report.r==1)) then
                        eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.isLandTab.x,y=self.isLandTab.y}})
                    end

                    self:close()

                    -- 更新占领和掠夺次数
                    if self.attackType==0 then
                        alienMinesVoApi:setRobNum(1)
                    else
                        alienMinesVoApi:setOccupyNum(1)
                    end
                    
                    local isAttacker=true
                    local islandType=self.isLandTab.type
                    local bdata={data={report=report},isAttacker=isAttacker,alienBattleData={islandType=islandType}}
                    bdata.battleType = 7
                    battleScene:initData(bdata)
                    do return end
                end
              else
                eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.isLandTab.x,y=self.isLandTab.y}})
                self:close()
                if self.parent then
                    self.parent:close()
                end
              end
            end

            if isFirst==false then
                isFirst=true
                local attTab=tankVoApi:getTanksTbByType(16)

                if self.formationItem then
                     self.formationItem:setEnabled(false)
                end
               if self.fightItem then
                 self.fightItem:setEnabled(false) 
               end

               local bestMenu=tolua.cast(self.myLayerTab1:getChildByTag(101),"CCMenu")
               if bestMenu then
                
                    local bestItem=tolua.cast(bestMenu:getChildByTag(101),"CCMenuItemSprite")
                    if bestItem then
                        bestItem:setEnabled(false)
                    end
               end

                local emblemID=emblemVoApi:getTmpEquip()
                local planePos=planeVoApi:getTmpEquip()
                print("emblemID",emblemID)
                local targetid={self.isLandTab.x,self.isLandTab.y}
                local aitroops=nil
                if AITroopsFleetVoApi:isHaveAITroops() then
                    aitroops=AITroopsFleetVoApi:getMatchAITroopsList(attTab)
                end
                local airshipId = airShipVoApi:getTempLineupId()
                if heroVoApi:isHaveTroops() then
                    local hTb = heroVoApi:getMachiningHeroList(attTab)
                    socketHelper:alienMinesAttackTroop(targetid,attTab,self.attackType,nil,serverAttack,hTb,nil,emblemID,planePos,aitroops,airshipId)
                else
                    socketHelper:alienMinesAttackTroop(targetid,attTab,self.attackType,isHelp,serverAttack,nil,nil,emblemID,planePos,aitroops,airshipId)
                end
            end
            
        end    
       
       -- 掠夺
        if self.attackType==0 then
            local robNum = alienMinesVoApi:getRobNum()
            local totalRobNum = alienMinesVoApi:getTotalRobNum()
            if robNum>=totalRobNum then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage5017"),30)
            else
                touchFight()
            end
        else
            local occupyNum=alienMinesVoApi:getOccupyNum()
            local totalOccupyNum = alienMinesVoApi:getTotalOccupyNum()
            if occupyNum>=totalOccupyNum then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage5018"),30)
            else
                touchFight()
            end
        end
        
    
        
    end
    
    local buttonName=getlocal("attackGo")
    local callBackFight=touchFight1  

    
    local fightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",callBackFight,nil,buttonName,25)
    local fightMenu=CCMenu:createWithItem(fightItem);
    fightMenu:setPosition(ccp(520,80))
    fightMenu:setTouchPriority((-(self.layerNum-1)*20-6));
    self.myLayerTab1:addChild(fightMenu)
    self.fightItem=fightItem

       
       
    local function touch1(tag,object)
    
    end
    local function touch2(tag,object)
        object=tolua.cast(object,"CCMenuItemToggle")
        if object:getSelectedIndex()==0 then
            object:setSelectedIndex(1)
            local function callBack1()
                self.attackType=0
                object:setSelectedIndex(0)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack1,getlocal("dialog_title_prompt"),getlocal("atkReturn"),nil,self.layerNum+1)

            --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptFleetStateAttack"),28)

        else
            
            object:setSelectedIndex(0)
            local function callBack1()
                self.attackType=1
                object:setSelectedIndex(1)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack1,getlocal("dialog_title_prompt"),getlocal("atkNoReturn"),nil,self.layerNum+1)
            --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptFleetStateBack"),28)
            --self.attackType=1
        end
    
    end
    if self.isLandTab.type==0 then
        local menuItem1 = GetButtonItem("BtnRight.png","BtnRight_Down.png","BtnRight_Down.png",touch1,10,nil,nil)
        local menu1 = CCMenu:createWithItem(menuItem1);
        -- menu1:setPosition(ccp(120,80));
        menu1:setPosition(ccp(100,tHeight-530));
        menu1:setTouchPriority((-(self.layerNum-1)*20-2));
        self.myLayerTab1:addChild(menu1,3);
        self.attackType=0

    else
        local selectSp1 = CCSprite:createWithSpriteFrameName("IconAttackBtn.png");
        local selectSp2 = CCSprite:createWithSpriteFrameName("IconAttackBtn_Down.png");
        local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2);  --(90,80)

        local selectSp3 = CCSprite:createWithSpriteFrameName("IconOccupyBtn.png");
        local selectSp4 = CCSprite:createWithSpriteFrameName("IconOccupyBtn_Down.png");
        local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4);

        local m_menuToggleSmall = CCMenuItemToggle:create(menuItemSp1);
        m_menuToggleSmall:addSubItem(menuItemSp2)
        if self.attackType==1 then

            m_menuToggleSmall:setSelectedIndex(1)
        else
             m_menuToggleSmall:setEnabled(false)
            m_menuToggleSmall:setSelectedIndex(0)
        end
        m_menuToggleSmall:registerScriptTapHandler(touch2)

        local menuAllSmall=CCMenu:createWithItem(m_menuToggleSmall);
        -- menuAllSmall:setPosition(ccp(120,80));
        menuAllSmall:setPosition(ccp(100,tHeight-530));
        menuAllSmall:setTouchPriority((-(self.layerNum-1)*20-2));
        if self.isAlienMines==true then
        else
             self.myLayerTab1:addChild(menuAllSmall,10);
        end
       

        
        if allianceVoApi:getSelfAlliance() and self.isLandTab.allianceName== allianceVoApi:getSelfAlliance().name then
            menuAllSmall:setVisible(false)
        end

    
    end
    

    local function formationHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function readCallback(tank,hero)
            -- G_updateSelectTankLayer(2,self.myLayerTab1,self.layerNum,self.isShowTank,tank,hero)
        end
        smallDialog:showFormationDialog("PanelHeaderPopup.png",CCSizeMake(550,700),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("save_formation"),readCallback,16,self.isShowTank,self.myLayerTab1)
    end
    local formationItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",formationHandler,nil,getlocal("formation"),25)
    local formationMenu=CCMenu:createWithItem(formationItem)
    formationMenu:setPosition(ccp(120,80))
    formationMenu:setTouchPriority((-(self.layerNum-1)*20-6))
    self.myLayerTab1:addChild(formationMenu)
    self.formationItem=formationItem



    self.addBtn=nil

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function alienMinesTankAttackDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
           return 1
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
        tmpSize=CCSizeMake(600,200)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
                   
        local cell=CCTableViewCell:new()
        cell:autorelease()
        return cell

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--点击tab页签 idx:索引
function alienMinesTankAttackDialog:tabClick(idx)
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


    elseif self.selectedTabIndex==1 then
        self.myLayerTab1:setVisible(false)
        self.myLayerTab1:setPosition(ccp(10000,0))
        
        self.myLayerTab2:setVisible(true)
        self.myLayerTab2:setPosition(ccp(0,0))

    
    end    
end
--用户处理特殊需求,没有可以不写此方法
function alienMinesTankAttackDialog:doUserHandler()

end


function alienMinesTankAttackDialog:tick()
    local repairTanks=SizeOfTable(tankVoApi:getRepairTanks())
    if repairTanks>0 then
        self:setTipsVisibleByIdx(true,2,repairTanks)
    else
        self:setTipsVisibleByIdx(false,2)
    end

    if self.selectedTabIndex==1 then
        self.playerTab2:tick()
    end
end


function alienMinesTankAttackDialog:dispose()
    self.isShowTank=1
    tankVoApi:clearTanksTbByType(16)

    heroVoApi:clearTroops()

    self.playerTab2:dispose()
    self.isAlienMines=nil
    self=nil
end




