dimensionalWarSignDialog=commonDialog:new()

function dimensionalWarSignDialog:new(layerNum)
    local nc={
        airship = nil
    }
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.dimensionalWarTanks={{},{},{},{},{},{}}
    self.dimensionalWarHero={0,0,0,0,0,0}
    self.dimensionalWarAITroops={0,0,0,0,0,0}
    nc.dimensionalEmblem = nil
    nc.dimensionalPlane = nil
    self.signBtn=nil
    self.updateBtn=nil
    self.enterBtn=nil
    self.type=33
    self.currentShow=1

    return nc
end

--设置对话框里的tableView
function dimensionalWarSignDialog:initTableView()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-30))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,G_VisibleSize.height-105))

    if self.closeBtn then
        self.closeBtn:setPosition(ccp(10000,0))
    end
    local function close()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local status=dimensionalWarVoApi:getStatus()
        if dimensionalWarVoApi:isHadApply()==true and status~=10 and status~=11 then
            local fleetInfo=tankVoApi:getTanksTbByType(self.type)
            local isHasTroops=false
            for k,v in pairs(fleetInfo) do
                if v and v[1] and v[2] and v[2]>0 then
                    isHasTroops=true
                end
            end
            if isHasTroops==true then
                local isChangeFleet,costTanks=self:isChangeFleet()
                -- print("isChangeFleet",isChangeFleet)
                if isChangeFleet==true then
                    local function onConfirm()
                        local function saveCallback()
                            local function callback()
                                self:close()
                            end
                            self:saveHandler(fleetInfo,callback)
                        end
                        if costTanks and SizeOfTable(costTanks)>0 then
                            smallDialog:showWorldWarCostTanksDialog("PanelHeaderPopup.png",CCSizeMake(550,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,saveCallback,costTanks,2)
                        else
                            saveCallback() 
                        end
                    end
                    local function onCancle()
                        self:close()
                    end
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("world_war_set_changed_fleet"),nil,self.layerNum+1,nil,nil,onCancle)
                else
                    self:close()
                end
            else
                local function sureHandler()
                    self:revertFleet()
                end
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("dimensionalWar_fleet_not_empty"),nil,self.layerNum+1,nil,sureHandler)
            end
        else
            self:close()
        end
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    local closeMune = CCMenu:createWithItem(closeBtnItem)
    closeMune:setTouchPriority(-(self.layerNum-1)*20-4)
    closeMune:setPosition(ccp(self.bgLayer:getContentSize().width-closeBtnItem:getContentSize().width,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(closeMune)


    self:initFleet()
    self:initUI()
    self:initBtn()

    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-5),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,10))
    -- self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)
    -- self.tv:setMaxDisToBottomOrTop(120)
end

function dimensionalWarSignDialog:initFleet()
    local function callback(flag)
        self.currentShow=flag+1
    end
    local type=self.type
    self.dimensionalWarTanks=G_clone(tankVoApi:getTanksTbByType(type))
    self.maxPowerBtn=G_addSelectTankLayer(type,self.bgLayer,self.layerNum,callback,nil,20)
    self.dimensionalWarHero=G_clone(heroVoApi:getDimensionalWarHeroList())
    self.dimensionalWarAITroops=G_clone(AITroopsFleetVoApi:getDimensionalWarAITroopsList())
    tankVoApi:setDimensionalWarTempTanks(G_clone(tankVoApi:getTanksTbByType(type)))
    self.airship = airShipVoApi:getBattleEquip(self.type)
end

function dimensionalWarSignDialog:initUI()
    local capInSet = CCRect(42, 26, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local serverTxtSp=LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png",capInSet,cellClick)
    serverTxtSp:setAnchorPoint(ccp(0.5,0))
    if G_isIphone5()==true then
        serverTxtSp:setContentSize(CCSizeMake(580,self.bgLayer:getContentSize().height-815-70))
    else
        serverTxtSp:setContentSize(CCSizeMake(580,self.bgLayer:getContentSize().height-815))
    end
    serverTxtSp:setPosition(ccp(G_VisibleSizeWidth/2,120))
    self.bgLayer:addChild(serverTxtSp,2)

    local descTab={getlocal("dimensionalWar_sign_desc1"),getlocal("dimensionalWar_sign_desc2"),getlocal("dimensionalWar_sign_desc3",{userWarCfg.tankeTransRate}),getlocal("dimensionalWar_sign_desc4",{math.floor(userWarCfg.prepareTime/60)})}
    local colorTab={G_ColorYellowPro,G_ColorWhite,G_ColorWhite,G_ColorWhite}
    local kCCTextAlignment={kCCTextAlignmentCenter,kCCTextAlignmentLeft,kCCTextAlignmentLeft,kCCTextAlignmentLeft}
    tabelLb = G_LabelTableView(CCSizeMake(serverTxtSp:getContentSize().width-50,serverTxtSp:getContentSize().height-20),descTab,25,kCCTextAlignment,colorTab)
    tabelLb:setPosition(ccp(25,10))
    tabelLb:setAnchorPoint(ccp(0,0))
    tabelLb:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    tabelLb:setMaxDisToBottomOrTop(150)
    serverTxtSp:addChild(tabelLb,5)
end
function dimensionalWarSignDialog:initBtn()
    local function saveHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local status=dimensionalWarVoApi:getStatus()
        if status==10 or status==11 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_set_fleet_desc"),30)
            do return end
        end

        local fleetInfo=tankVoApi:getTanksTbByType(self.type)
        local isHasTroops=false
        for k,v in pairs(fleetInfo) do
            if v and v[1] and v[2] and v[2]>0 then
                isHasTroops=true
            end
        end
        if isHasTroops==true then
            local function saveCallback()
                self:saveHandler(fleetInfo)
            end
            -- local costTanks,isSame=tankVoApi:setFleetCostTanks(self.allianceWar2Tanks,fleetInfo)
            local isChangeFleet,costTanks=self:isChangeFleet()
            -- print("isChangeFleet",isChangeFleet)
            if isChangeFleet==false then
            -- if isSame==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_no_change_save"),30)
            else
                if costTanks and SizeOfTable(costTanks)>0 then
                    smallDialog:showWorldWarCostTanksDialog("PanelHeaderPopup.png",CCSizeMake(550,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,saveCallback,costTanks,2)
                else
                    saveCallback()
                end
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWarNoArmy"),30)
        end      
    end
    self.signBtn=GetButtonItem("blueSmallBtn.png","blueSmallBtn_Down.png","blueSmallBtn_Down.png",saveHandler,nil,getlocal("allianceWar_sign"),25,12)
    self.signBtn:setAnchorPoint(ccp(0.5,1))
    -- self.signBtn:setScale(0.8)
    local signMenu=CCMenu:createWithItem(self.signBtn)
    signMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    signMenu:setPosition(ccp(G_VisibleSizeWidth-180,113))
    self.bgLayer:addChild(signMenu,5)

    self.updateBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",saveHandler,nil,getlocal("dimensionalWar_chenge"),25,13)
    self.updateBtn:setAnchorPoint(ccp(0.5,1))
    -- self.updateBtn:setScale(0.8)
    local updateMenu=CCMenu:createWithItem(self.updateBtn)
    updateMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    updateMenu:setPosition(ccp(G_VisibleSizeWidth-180,113))
    self.bgLayer:addChild(updateMenu,5)

    self:refreshBtn()
end

function dimensionalWarSignDialog:saveHandler(fleetInfo,callback)
    local function setinfoHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            -- local function callbackHandler()
                if dimensionalWarVoApi:isHadApply()==false then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_signup_success"),30)
                else
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),30)
                end
                -- allianceWar2VoApi:setInitFlag(1)
                local type=self.type
                self.dimensionalWarTanks=G_clone(tankVoApi:getTanksTbByType(type))
                -- local heroList=heroVoApi:getTroopsHeroList()
                local heroList={0,0,0,0,0,0}
                if sData.data and sData.data.userwarhero then
                    heroList=sData.data.userwarhero
                end
                --AI部队
                local aitroops={0,0,0,0,0,0}
                if sData.data and sData.data.aitroops then
                    aitroops=sData.data.aitroops
                end
                AITroopsFleetVoApi:setAITroopsTb(aitroops)
                AITroopsFleetVoApi:setDimensionalWarAITroopsList(aitroops)

                self.dimensionalWarHero=G_clone(heroVoApi:getDimensionalWarHeroList())
                self.dimensionalWarAITroops=G_clone(AITroopsFleetVoApi:getDimensionalWarAITroopsList())

                tankVoApi:setDimensionalWarTempTanks(G_clone(tankVoApi:getTanksTbByType(type)))
                local emblemID = emblemVoApi:getTmpEquip()
                emblemVoApi:setBattleEquip(self.type,emblemID)
                local planePos = planeVoApi:getTmpEquip()
                planeVoApi:setBattleEquip(self.type,planePos)
                airShipVoApi:setBattleEquip(self.type,airShipVoApi:getTempLineupId())

                -- allianceWar2VoApi:setLastSetFleetTime(base.serverTime)
                -- local savedTroops={tanks=G_clone(tankVoApi:getTanksTbByType(type)),hero=G_clone(heroVoApi:getAllianceWar2HeroList())}
                -- allianceWar2VoApi:setSavedTroops(savedTroops)
                -- print("save~~~~~~~")
                -- G_dayin(G_clone(tankVoApi:getTanksTbByType(type)))
                self:tick()
                dimensionalWarVoApi:setApplyTime(tonumber(sData.ts))
                self:refreshBtn()
                if callback then
                    callback()
                end
            -- end
            -- local cityID=allianceWar2VoApi:getTargetCity()
            -- local status=allianceWar2VoApi:getStatus(cityID)
            -- if status==30 then
            --     local function requestCallback(fn1,data1)
            --         local ret1,sData1=base:checkServerData(data1)
            --         G_isShowTip=true
            --         if ret1==true then
            --             callbackHandler()
            --         end
            --     end
            --     local initFlag=nil
            --     if allianceWar2VoApi:getInitFlag()==-1 then
            --         initFlag=true
            --     end
            --     G_isShowTip=false
            --     socketHelper:alliancewarnewGet(allianceWar2VoApi:getTargetCity(),initFlag,requestCallback)
            -- else
            --     callbackHandler()
            -- end
        end
    end
    local hero=nil
    if heroVoApi:isHaveTroops()==true then
        -- local heroList=heroVoApi:getAllianceWar2HeroList()
        local heroList=heroVoApi:getTroopsHeroList()
        -- G_dayin(heroList)
        hero=heroVoApi:getBindFleetHeroList(heroList,fleetInfo,self.type)
        if hero then
            for k,v in pairs(hero) do
                if v and type(v)=="string" then
                    local heroArr=Split(v,"-")
                    if heroArr and heroArr[1] then
                        hero[k]=heroArr[1]
                    end
                end
            end
        end
    end
    local aitroops=AITroopsFleetVoApi:getAITroopsTb()
    aitroops=AITroopsFleetVoApi:getBindFleetAITroopsList(aitroops, fleetInfo, self.type)

    local emblemID = emblemVoApi:getTmpEquip()
    emblemID=emblemVoApi:getEquipIdForBattle(emblemID)
    if emblemID~=-1 then
        local planePos = planeVoApi:getTmpEquip()
        local airshipId = airShipVoApi:getTempLineupId()
        if dimensionalWarVoApi:isHadApply()==true then
            socketHelper:userwarApply(fleetInfo,hero,setinfoHandler,emblemID,planePos,aitroops,airshipId)
        else
            local applynum=dimensionalWarVoApi:getApplynum()
            if applynum>=userWarCfg.maxApplyNum then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage23310"),30)
            else
                socketHelper:userwarApply(fleetInfo,hero,setinfoHandler,emblemID,planePos,aitroops,airshipId)
            end
        end
    end
end

function dimensionalWarSignDialog:isChangeFleet()
    local fleetInfo=tankVoApi:getTanksTbByType(self.type)
    local costTanks,isSame=tankVoApi:setFleetCostTanks(self.dimensionalWarTanks,fleetInfo)

    local hero1=heroVoApi:getBindFleetHeroList(self.dimensionalWarHero,self.dimensionalWarTanks,self.type,false)
    local heroList=heroVoApi:getTroopsHeroList()
    local hero2=heroVoApi:getBindFleetHeroList(heroList,fleetInfo,self.type,false)
    local isSameHero=heroVoApi:isSameHero(hero1,hero2)

    local aitroops1 = AITroopsFleetVoApi:getBindFleetAITroopsList(self.dimensionalWarAITroops,self.dimensionalWarTanks,self.type,false)
    local aiTb = AITroopsFleetVoApi:getAITroopsTb()
    local aitroops2 = AITroopsFleetVoApi:getBindFleetAITroopsList(aiTb,fleetInfo,self.type,false)
    local isSameAITroops = AITroopsFleetVoApi:isSameAITroops(aitroops1,aitroops2)

    local isSameEmblem = true
    local tmpEmblemId = emblemVoApi:getTmpEquip()
    local emblemID = emblemVoApi:getBattleEquip(self.type)
    if tmpEmblemId~=emblemID then
        isSameEmblem = false
    end
    local isSamePlane = true
    local tmpPlanePos = planeVoApi:getTmpEquip()
    local planePos = planeVoApi:getBattleEquip(self.type)
    if tmpPlanePos~=planePos then
        isSamePlane = false
    end
    local isSameAirship = true
    if airShipVoApi:getTempLineupId() ~= airShipVoApi:getBattleEquip(self.type) then
        isSameAirship = false
    end
    if isSame==true and isSameHero==true and isSameEmblem and isSamePlane and isSameAITroops==true and isSameAirship==true then
        return false,costTanks
    else
        return true,costTanks
    end
end

function dimensionalWarSignDialog:updateData()
    if self.dimensionalWarTanks then
        for k,v in pairs(self.dimensionalWarTanks) do
            if v and v[1] and v[2] then
                tankVoApi:setTanksByType(self.type,k,v[1],v[2])
            else
                tankVoApi:deleteTanksTbByType(self.type,k)
            end
        end
    end
    if self.dimensionalWarHero then
        heroVoApi:setDimensionalWarHeroList(G_clone(self.dimensionalWarHero))
    end
    if self.dimensionalWarAITroops then
        AITroopsFleetVoApi:setDimensionalWarAITroopsList(G_clone(self.dimensionalWarAITroops))
    end
    if self.dimensionalEmblem then
        emblemVoApi:setBattleEquip(self.type,self.dimensionalEmblem)
    end
    if self.dimensionalPlane then
        planeVoApi:setBattleEquip(self.type,self.dimensionalPlane)
    end
    if self.airship then
        airShipVoApi:setBattleEquip(self.type,self.airship)
    end
end

function dimensionalWarSignDialog:revertFleet()
    if self and self.bgLayer then
        -- heroVoApi:clearTroops()
        self:updateData()
        G_updateSelectTankLayer(self.type,self.bgLayer,self.layerNum,self.currentShow)  
    end
end

--用户处理特殊需求,没有可以不写此方法
function dimensionalWarSignDialog:doUserHandler()

end

function dimensionalWarSignDialog:refreshBtn()
    if self.signBtn==nil or self.updateBtn==nil then
        do return end
    end
    if dimensionalWarVoApi:isHadApply()==true then
        self.signBtn:setVisible(false)
        self.signBtn:setEnabled(false)
        self.updateBtn:setVisible(true)
        self.updateBtn:setEnabled(true)
    else
        self.signBtn:setVisible(true)
        self.signBtn:setEnabled(true)
        self.updateBtn:setVisible(false)
        self.updateBtn:setEnabled(false)
    end
end

function dimensionalWarSignDialog:tick()

end

function dimensionalWarSignDialog:dispose()
    self:updateData()
    self.dimensionalWarTanks={{},{},{},{},{},{}}
    self.dimensionalWarHero={0,0,0,0,0,0}
    self.dimensionalWarAITroops={0,0,0,0,0,0}
    self.dimensionalEmblem = nil
    self.dimensionalPlane = nil
    self.airship = nil
    self.signBtn=nil
    self.updateBtn=nil
    self.enterBtn=nil
    self.currentShow=1
end




