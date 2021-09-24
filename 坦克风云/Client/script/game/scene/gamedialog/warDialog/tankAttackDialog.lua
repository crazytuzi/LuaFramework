tankAttackDialog=commonDialog:new()

--param type: 要进攻的地点的类型
--param isLandTab: 要进攻的地点的worldBaseVo
--param layerNum: 显示的层
--param rebelType: 进攻叛军时需要的参数，1是普通进攻，2是高级进攻
--param attackNum: 进攻次数
function tankAttackDialog:new(type,isLandTab,layerNum,rebelType,attackNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.leftBtn=nil
    nc.expandIdx={}
    nc.myLayerTab1=nil
    
    nc.playerTab2=nil
    nc.myLayerTab2=nil

    nc.playerTab3=nil
    nc.myLayerTab3=nil
    
    nc.layerNum=layerNum
    
    if type==6 or type==7 or type==8 or type==9 then
        nc.attackType=0
    else
        if CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_fleetArrive")==1 then
            nc.attackType=0
        else
            nc.attackType=1
        end
    end
    if type==8 then
        nc.attackCityFlag=1 --进攻军团城市
    end
    nc.isLandTab=isLandTab
    nc.addBtn=nil
    nc.isShowTank=1
    nc.rebelType=rebelType
    nc.attackNum = attackNum
    
    return nc
end

--设置或修改每个Tab页签
function tankAttackDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
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
function tankAttackDialog:initTableView()
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

    require "luascript/script/game/scene/gamedialog/warDialog/tankDialogTab2"
    self.playerTab2=tankDialogTab2:new()
    self.myLayerTab2=self.playerTab2:init(self,1,self.layerNum)
    self.bgLayer:addChild(self.myLayerTab2);
    self.myLayerTab2:setPosition(ccp(999333,0))
    self.myLayerTab2:setVisible(false)
    
    require "luascript/script/game/scene/gamedialog/warDialog/tankDialogTab3"
    self.playerTab3=tankDialogTab3:new()
    self.myLayerTab3=self.playerTab3:init(self.layerNum)
    self.bgLayer:addChild(self.myLayerTab3);
    self.myLayerTab3:setPosition(ccp(999333,0))
    self.myLayerTab3:setVisible(false)
  
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
function tankAttackDialog:initTab1Layer()
    
    local tHeight = G_VisibleSize.height-260-10

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
    -- local moveTimeLb=GetTTFLabel(getlocal("costTime2",{moveTime}),26);
    -- moveTimeLb:setAnchorPoint(ccp(0,0.5));
    -- moveTimeLb:setPosition(ccp(110,tHeight+30));
    -- self.myLayerTab1:addChild(moveTimeLb,2);
    

    -- local fleetload=FormatNumber(tankVoApi:getAttackTanksCarryResource(tankVoApi:getTanksTbByType(2)))

    -- local fleetLb=GetTTFLabel(getlocal("fleetload",{fleetload}),26);
    -- fleetLb:setAnchorPoint(ccp(0,0.5));
    -- fleetLb:setPosition(ccp(110,tHeight));
    -- self.myLayerTab1:addChild(fleetLb,2);
    -- fleetLb:setTag(19)
    
    -- local targetLb=GetTTFLabel(getlocal("targetPostion",{0}),26);
    -- targetLb:setAnchorPoint(ccp(0,0.5));
    -- targetLb:setPosition(ccp(110+50,tHeight-530));
    -- self.myLayerTab1:addChild(targetLb,2);
    
    -- local lbWidth = 50
    -- if G_getCurChoseLanguage() =="ru" then
    --     lbWidth =70
    -- end
    -- local xx=self.isLandTab.x
    -- local xLabel=GetTTFLabel("X".."   "..xx,30)
    -- xLabel:setAnchorPoint(ccp(0,0.5))
    -- xLabel:setPosition(300+lbWidth,tHeight-530)
    --  self.myLayerTab1:addChild(xLabel)
     
     
    -- local yy=self.isLandTab.y
    -- local yLabel=GetTTFLabel("Y".."   "..yy,30)
    -- yLabel:setAnchorPoint(ccp(0,0.5))
    -- yLabel:setPosition(420+lbWidth,tHeight-530)
    --  self.myLayerTab1:addChild(yLabel)


    local function changeHandler(flag)
        self.isShowTank=flag+1
    end
    G_addSelectTankLayer(2,self.myLayerTab1,self.layerNum,changeHandler,nil,nil,self.isLandTab)

    local isFirst=false
    
    local function touchFight1()
        local function touchFight()

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
            
            if self.isLandTab and self.isLandTab.type~=7 and self.isLandTab.type~=9 and playerVoApi:getEnergy()==0 then
                local function buyEnergy()
                    G_buyEnergy(self.layerNum + 1)
                end
                smallDialog:showEnergySupplementDialog(self.layerNum + 1)
                do
                    return
                end
            end

            local isEableAttack=true
            local num=0;
            for k,v in pairs(tankVoApi:getTanksTbByType(2)) do
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

              if base:checkServerData(data)==true then
                    if self.isLandTab.type==6 then
                        worldScene:removeProtect()
                    end
                    if airShipVoApi:getTempLineupId() or self.isLandTab.type==9 then
                        airShipVoApi:requestInit(nil, false)
                    end
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptFleetSetSail",{self.isLandTab.x,self.isLandTab.y}),28)
                    self:close();
              end
            end
            local function doSendRequest()
                if isFirst==false then
                    isFirst=true
                    local attTab=tankVoApi:getTanksTbByType(2)
                    local targetid={self.isLandTab.x,self.isLandTab.y}
                    local emblemID=emblemVoApi:getTmpEquip()
                    print("emblemID------->>>>>",emblemID)
                    local planePos=planeVoApi:getTmpEquip()
                    local aitroops = nil
                    if AITroopsFleetVoApi:isHaveAITroops() then
                        aitroops=AITroopsFleetVoApi:getMatchAITroopsList(attTab)
                    end
                    local airShipId = airShipVoApi:getTempLineupId()
                    if heroVoApi:isHaveTroops() then
                        local hTb = heroVoApi:getMachiningHeroList(attTab)
                        socketHelper:attackTroop(targetid,attTab,self.attackType,nil,serverAttack,hTb,nil,self.rebelType,emblemID,planePos,aitroops,self.attackCityFlag,airShipId,self.attackNum)
                    else
                        socketHelper:attackTroop(targetid,attTab,self.attackType,isHelp,serverAttack,nil,nil,self.rebelType,emblemID,planePos,aitroops,self.attackCityFlag,airShipId,self.attackNum)
                    end
                end
            end
            --出战部队是否会动用基地的防守部队，如果会动用的话就出一个提示
            local changeFlag=false
            local defenceTankTb=tankVoApi:getTemDefenseTanks()
            local defenceNumTb={}
            for k,v in pairs(defenceTankTb) do
                if(v[1] and v[2])then
                    local key=tonumber(v[1])
                    if(defenceNumTb[key])then
                        defenceNumTb[key]=defenceNumTb[key] + tonumber(v[2])
                    else
                        defenceNumTb[key]=tonumber(v[2])
                    end
                end
            end
            local attTab=tankVoApi:getTanksTbByType(2)
            local attTankNumTb={}
            for k,v in pairs(attTab) do
                if(v[1] and v[2])then
                    local key=tonumber(v[1])
                    if(attTankNumTb[key])then
                        attTankNumTb[key]=attTankNumTb[key] + tonumber(v[2])
                    else
                        attTankNumTb[key]=tonumber(v[2])
                    end
                end
            end
            local allTankTb=tankVoApi:getAllTanks()
            for tankID,tankNum in pairs(defenceNumTb) do
                if(attTankNumTb[tankID] and allTankTb[tankID] and tonumber(allTankTb[tankID][1]) and (tonumber(allTankTb[tankID][1]) - attTankNumTb[tankID]<tankNum))then
                    changeFlag=true
                    break
                end
            end
            if(changeFlag)then
                local function onConfirm()
                    doSendRequest()
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("attackTankChangeDefence"),nil,self.layerNum+1)
            else
                doSendRequest()
            end
        end

    
       
        if playerVoApi:ifProtected()==true and self.isLandTab.type==6 then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchFight,getlocal("dialog_title_prompt"),getlocal("attack_warning"),nil,self.layerNum+1)
        else
            touchFight()
        end
        
    end
    --协防的方法
    local isFirstHelp=false
    local function helpPlayer()
        print("helpPlayer")
        if self.isLandTab.type==8 then --如果是驻防军团城市的话，先判断当前设置的部队是否满足驻防需求
            local attTab=tankVoApi:getTanksTbByType(2)
            local num=0
            for k,v in pairs(attTab) do
                if v and v[2] then
                    num=num+tonumber(v[2])
                end
            end
            local flag=allianceCityVoApi:isTroopsNumEnableDef(num)
            if flag==false then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("troopsDefDisableStr"),28)
                do return end
            end
        end
        --先判断舰队是不是满了
        local fleetsNums=Split(playerCfg.actionFleets,",")[playerVoApi:getVipLevel()+1] 
        if attackTankSoltVoApi:getAllTankSlotsNum()>=tonumber(fleetsNums) then
            self:close(false);
            vipVoApi:showQueueFullDialog(6,self.layerNum+1)
            do
                return
            end
        
        end
        --判断体力
        if playerVoApi:getEnergy()==0 then
            local function buyEnergy()
                G_buyEnergy(self.layerNum+1)
            end
            smallDialog:showEnergySupplementDialog(self.layerNum + 1)
            do
                return
            end
        end
        --判断是否选择了舰队 没有的话 提示选择最大战力
        local isEableAttack=true
            local num=0;
            for k,v in pairs(tankVoApi:getTanksTbByType(2)) do
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
        --去协防
        local function serverAttack(fn,data)
          --local retTb=OBJDEF:decode(data)

          if base:checkServerData(data)==true then
                -- if self.isLandTab.type==6 then
                --     worldScene:removeProtect()
                -- end
                if airShipVoApi:getTempLineupId() then
                    airShipVoApi:requestInit(nil, false)
                end
                allianceVoApi:apointRefreshData(4)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptFleetSetSail",{self.isLandTab.x,self.isLandTab.y}),28)
                self:close();
          end
        end

        local attTab=tankVoApi:getTanksTbByType(2)
        local targetid={self.isLandTab.x,self.isLandTab.y}
        local isHelp=1
        if self.attackCityFlag==1 then
            isHelp=nil
        end
        local apc=0
        local alliance=allianceVoApi:getSelfAlliance()
        if alliance and alliance.ainfo and alliance.ainfo.a and alliance.ainfo.a[4] then
            apc=alliance.ainfo.a[4]
        end

        local function doSendRequest()
            if isFirstHelp==false then
                isFirstHelp=true
                local emblemID=emblemVoApi:getTmpEquip()
                local planePos=planeVoApi:getTmpEquip()
                local aitroops = nil
                if AITroopsFleetVoApi:isHaveAITroops() then
                    aitroops=AITroopsFleetVoApi:getMatchAITroopsList(attTab)
                end
                local airShipId = airShipVoApi:getTempLineupId()
                if heroVoApi:isHaveTroops() then
                    local hTb = heroVoApi:getMachiningHeroList(attTab)
                    socketHelper:attackTroop(targetid,attTab,self.attackType,isHelp,serverAttack,hTb,apc,nil,emblemID,planePos,aitroops,self.attackCityFlag,airShipId)
                else
                    socketHelper:attackTroop(targetid,attTab,self.attackType,isHelp,serverAttack,nil,apc,nil,emblemID,planePos,aitroops,self.attackCityFlag,airShipId)
                end
            end
        end
        --协防部队是否会动用基地的防守部队，如果会动用的话就出一个提示
        local changeFlag=false
        local defenceTankTb=tankVoApi:getTemDefenseTanks()
        local defenceNumTb={}
        for k,v in pairs(defenceTankTb) do
            if(v[1] and v[2])then
                local key=tonumber(v[1])
                if(defenceNumTb[key])then
                    defenceNumTb[key]=defenceNumTb[key] + tonumber(v[2])
                else
                    defenceNumTb[key]=tonumber(v[2])
                end
            end
        end
        local attTab=tankVoApi:getTanksTbByType(2)
        local attTankNumTb={}
        for k,v in pairs(attTab) do
            if(v[1] and v[2])then
                local key=tonumber(v[1])
                if(attTankNumTb[key])then
                    attTankNumTb[key]=attTankNumTb[key] + tonumber(v[2])
                else
                    attTankNumTb[key]=tonumber(v[2])
                end
            end
        end
        local allTankTb=tankVoApi:getAllTanks()
        for tankID,tankNum in pairs(defenceNumTb) do
            if(attTankNumTb[tankID] and allTankTb[tankID] and tonumber(allTankTb[tankID][1]) and (tonumber(allTankTb[tankID][1]) - attTankNumTb[tankID]<tankNum))then
                changeFlag=true
                break
            end
        end
        if(changeFlag)then
            local function onConfirm()
                doSendRequest()
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("attackTankChangeDefence"),nil,self.layerNum+1)
        else
            doSendRequest()
        end
    end
    
    local buttonName=getlocal("attackGo")
    local callBackFight=touchFight1
    --判断如果是自己军团成员 按钮和方法变成协防
    if self.isLandTab.allianceName and allianceVoApi:isSameAlliance(self.isLandTab.allianceName) then
        if self.isLandTab.type==8 then
            buttonName=getlocal("city_garrison")
        else
            buttonName=getlocal("city_info_doubleCover")
        end
        callBackFight=helpPlayer
        if self.isLandTab.type==8 then --如果是军团城市驻防的话，有驻防部队的数量限制
            local troopsLimit=allianceCityVoApi:getDefTroopsLimit()
            local troopsLimitLb=GetTTFLabelWrap(getlocal("limit_defTroops_num",{troopsLimit}),22,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
            troopsLimitLb:setColor(G_ColorRed)
            troopsLimitLb:setAnchorPoint(ccp(1,0.5))
            troopsLimitLb:setPosition(G_VisibleSizeWidth-40,160)
            -- troopsLimitLb:setColor(G_ColorYellowPro)
            self.myLayerTab1:addChild(troopsLimitLb)
            if G_isIphone5()==false then
                troopsLimitLb:setPositionY(140)
            end
        end
    end

    
    local fightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",callBackFight,nil,buttonName,25,101)
    -- fightItem:setScale(0.8)
    -- local lb = fightItem:getChildByTag(101)
    -- if lb then
    --     lb = tolua.cast(lb,"CCLabelTTF")
    --     lb:setFontName("Helvetica-bold")
    -- end
    local fightMenu=CCMenu:createWithItem(fightItem);
    fightMenu:setPosition(ccp(520,80))
    fightMenu:setTouchPriority((-(self.layerNum-1)*20-6));
    self.myLayerTab1:addChild(fightMenu)

       
       
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
    local spScale=0.5
    if self.isLandTab.type==0 then
        local menuItem1 = GetButtonItem("BtnRight.png","BtnRight_Down.png","BtnRight_Down.png",touch1,10,nil,nil)
        menuItem1:setScale(spScale)
        local menu1 = CCMenu:createWithItem(menuItem1);
        -- menu1:setPosition(ccp(120,80));
        -- menu1:setPosition(ccp(100,tHeight-530));
        if G_isIphone5()==true then
            menu1:setPosition(ccp(68,tHeight+105-15));
        else
            menu1:setPosition(ccp(68,tHeight+105));
        end
        menu1:setTouchPriority((-(self.layerNum-1)*20-2));
        self.myLayerTab1:addChild(menu1,3);
        self.attackType=0

    else
        local selectSp1 = CCSprite:createWithSpriteFrameName("IconAttackBtn.png");
        local selectSp2 = CCSprite:createWithSpriteFrameName("IconAttackBtn_Down.png");
        selectSp1:setScale(spScale)
        selectSp2:setScale(spScale)
        local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2);  --(90,80)

        local selectSp3 = CCSprite:createWithSpriteFrameName("IconOccupyBtn.png");
        local selectSp4 = CCSprite:createWithSpriteFrameName("IconOccupyBtn_Down.png");
        selectSp3:setScale(spScale)
        selectSp4:setScale(spScale)
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
        -- menuAllSmall:setPosition(ccp(100,tHeight-530));
        -- menuAllSmall:setScale(spScale)
        if G_isIphone5()==true then
            menuAllSmall:setPosition(ccp(68,tHeight+105-15));
        else
            menuAllSmall:setPosition(ccp(68,tHeight+105));
        end
        menuAllSmall:setTouchPriority((-(self.layerNum-1)*20-2));
        self.myLayerTab1:addChild(menuAllSmall,10);

        
        if allianceVoApi:getSelfAlliance() and self.isLandTab.allianceName== allianceVoApi:getSelfAlliance().name then
            menuAllSmall:setVisible(false)
        end

    
    end
    
    local function readCallback(tank,hero)
    end
    local formationMenu=G_getFormationBtn(self.myLayerTab1,self.layerNum,self.isShowTank,2,readCallback)

    self.addBtn=nil

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function tankAttackDialog:eventHandler(handler,fn,idx,cel)
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
function tankAttackDialog:tabClick(idx)
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

    elseif self.selectedTabIndex==1 then
        self.myLayerTab1:setVisible(false)
        self.myLayerTab1:setPosition(ccp(10000,0))
        
        self.myLayerTab2:setVisible(true)
        self.myLayerTab2:setPosition(ccp(0,0))

        self.myLayerTab3:setVisible(false)
        self.myLayerTab3:setPosition(ccp(99999,0))


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
function tankAttackDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function tankAttackDialog:cellClick(idx)
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


function tankAttackDialog:tick()
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


function tankAttackDialog:clearVar()

    self.tv:reloadData()

end
function tankAttackDialog:refreshTab3()
    self.repairTank=tankVoApi:getRepairTanks()
    self.myLayerTab3:removeFromParentAndCleanup(true)
    self:initTab3Layer()
    self.myLayerTab3:setVisible(true)
    self.myLayerTab3:setPosition(ccp(0,0))
    self.tv:reloadData()

end



function tankAttackDialog:dispose()
    self.isShowTank=1
    tankVoApi:clearTanksTbByType(2)
    heroVoApi:clearTroops()
    emblemVoApi:setBattleEquip(2,nil)
    planeVoApi:setBattleEquip(2,nil)
    airShipVoApi:setTempLineupId(nil)

    self.playerTab2:dispose()
    self.playerTab3:dispose()

    self=nil
end

function tankAttackDialog:againAssignmentTab()


end




