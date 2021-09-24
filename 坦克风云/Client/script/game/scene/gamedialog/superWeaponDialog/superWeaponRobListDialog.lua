superWeaponRobListDialog=commonDialog:new()
function superWeaponRobListDialog:new(fid)
    local nc={}
    setmetatable(nc,self)
    nc.fid=fid
    self.__index=self
    return nc
end

--设置对话框里的tableView
function superWeaponRobListDialog:initTableView()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/hero/heroHonor.plist")
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-95))

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-290),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,120))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(140)

    self:initFood()
    self:initBottom()
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function superWeaponRobListDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local robList=superWeaponVoApi:getRobList()
        return SizeOfTable(robList)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,150)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        
        local strSize2 = 22
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
            strSize2= 25
        end

        local function nilFunc()
        end
        local sprieBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
        sprieBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,140))
        sprieBg:setAnchorPoint(ccp(0,0))
        sprieBg:setPosition(ccp(0,10))
        cell:addChild(sprieBg)

        local bgWidth=sprieBg:getContentSize().width
        local bgHeight=sprieBg:getContentSize().height

        local robList=superWeaponVoApi:getRobList()
        local robPlayerVo=robList[idx+1]
        local id=robPlayerVo.id
        local name=robPlayerVo.name
        local level=robPlayerVo.level
        local power=robPlayerVo.power
        local pic=robPlayerVo.pic
        local rate=robPlayerVo.rate
        local rateStr,color=superWeaponVoApi:getRateStr(rate)
        
        local personPhotoName=playerVoApi:getPersonPhotoName(pic)
        local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName)
        playerPic:setAnchorPoint(ccp(0,0.5))
        playerPic:setPosition(ccp(20,bgHeight/2))
        sprieBg:addChild(playerPic,1)

        local lbPosX=120
        local nameLabel=GetTTFLabel(name,30)
        nameLabel:setAnchorPoint(ccp(0,0.5))
        nameLabel:setPosition(ccp(lbPosX,bgHeight-30))
        sprieBg:addChild(nameLabel,1)
        nameLabel:setColor(G_ColorYellowPro)

        local levelLabel=GetTTFLabel(getlocal("fightLevel",{level}),25)
        levelLabel:setAnchorPoint(ccp(0,0.5))
        levelLabel:setPosition(ccp(lbPosX,bgHeight/2))
        sprieBg:addChild(levelLabel,1)

        local powerLabel=GetTTFLabel(getlocal("alliance_info_power")..FormatNumber(power),25)
        powerLabel:setAnchorPoint(ccp(0,0.5))
        powerLabel:setPosition(ccp(lbPosX,30))
        sprieBg:addChild(powerLabel,1)

        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local rateLabel=GetTTFLabelWrap(rateStr,strSize2,CCSizeMake(300,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        -- local rateLabel=GetTTFLabelWrap(str,25,CCSizeMake(300,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        rateLabel:setAnchorPoint(ccp(1,0.5))
        rateLabel:setPosition(ccp(bgWidth-10,bgHeight-30))
        sprieBg:addChild(rateLabel,1)
        rateLabel:setColor(color)


        local function attackHandler(tag,object)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                if G_isGlobalServer()==false then
                    if superWeaponVoApi:checkInPeaceTime()==true then
                        -- local stStr=G_getTimeStr(weaponrobCfg.peaceTime[1][1]*3600+weaponrobCfg.peaceTime[1][2]*60,2)
                        -- local etStr=G_getTimeStr(weaponrobCfg.peaceTime[2][1]*3600+weaponrobCfg.peaceTime[2][2]*60,2)
                        local stStr=G_getTimeStr(weaponrobCfg.peaceTime[1][1]*3600+weaponrobCfg.peaceTime[1][2]*60,2)
                        local etStr=G_getTimeStr(weaponrobCfg.peaceTime[2][1]*3600+weaponrobCfg.peaceTime[2][2]*60,2)
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_peace_tip",{stStr,etStr}),30)
                        do return end
                    end
                end

                local energyNum,nextTime=superWeaponVoApi:setCurEnergy()
                if energyNum<=0 then
                    superWeaponVoApi:showRobAddEnergySmallDialog(self.layerNum+1)
                    do return end
                end

                local function showAttackDialog( ... )
                    require "luascript/script/game/scene/gamedialog/warDialog/tankStoryDialog"
                    local td=tankStoryDialog:new(nil,nil,nil,nil,nil,{target=id,fid=self.fid,targetData=robPlayerVo})
                    local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("goFighting"),true,7)
                    sceneGame:addChild(dialog,7)
                end
                local protectTime=superWeaponVoApi:getProtectTime()
                if base.serverTime<protectTime then
                    local function onConfirm()
                        showAttackDialog()
                        self:close()
                    end
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("super_weapon_rob_protect_notice_tip"),nil,self.layerNum+1)
                else
                    showAttackDialog()
                    self:close()
                end
            end
        end
        local menuItemAttack=GetButtonItem("IconAttackBtn.png","IconAttackBtn_Down.png","IconAttackBtn_Down.png",attackHandler,idx+1,nil,0)
        local scale=1
        menuItemAttack:setScale(scale)
        local menuAttack=CCMenu:createWithItem(menuItemAttack)
        menuAttack:setPosition(ccp(bgWidth-menuItemAttack:getContentSize().width/2*scale-10,menuItemAttack:getContentSize().height/2*scale+10))
        menuAttack:setTouchPriority(-(self.layerNum-1)*20-2)
        sprieBg:addChild(menuAttack,1)


        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end


function superWeaponRobListDialog:initFood()
    local posY=self.bgLayer:getContentSize().height-130
    local foodLb=GetTTFLabelWrap(getlocal("super_weapon_rob_food"),25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- local foodLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊",25,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    foodLb:setAnchorPoint(ccp(0.5,0.5))
    foodLb:setPosition(ccp(80,posY))
    self.bgLayer:addChild(foodLb,1)

    local maxNum=weaponrobCfg.energyMax
    local energyNum,nextTime=superWeaponVoApi:setCurEnergy()
    local energyStr=""
    if energyNum<maxNum then
        energyStr=energyNum.."/"..maxNum.."("..GetTimeStr(nextTime)..")"
    else
        energyStr=energyNum.."/"..maxNum
    end
    AddProgramTimer(self.bgLayer,ccp(260,posY),24,25,energyStr,"AllBarBg.png","AllEnergyBar.png",26)
    self.timerSpriteEnergy=self.bgLayer:getChildByTag(24)
    self.timerSpriteEnergy=tolua.cast(self.timerSpriteEnergy,"CCProgressTimer")
    self.timerSpriteEnergy:setPercentage((energyNum/maxNum)*100)

    local function addFoodHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        superWeaponVoApi:showRobAddEnergySmallDialog(self.layerNum+1)
    end
    local addSp=LuaCCSprite:createWithSpriteFrameName("moreBtn.png",addFoodHandler)
    addSp:setPosition(ccp(420,posY))
    addSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(addSp,1)

    local function showInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={"\n",getlocal("super_weapon_rob_list_info"),"\n"}
        local tabColor={nil,G_ColorYellowPro,nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1) 
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-60,posY))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoBtn,1)
end

function superWeaponRobListDialog:initBottom()
    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local leftTime=superWeaponVoApi:freeRefreshLeftTime()
    self.freeRefreshLb=GetTTFLabelWrap(getlocal("super_weapon_rob_free_refresh",{G_getTimeStr(leftTime)}),25,CCSizeMake(self.bgLayer:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- self.freeRefreshLb=GetTTFLabelWrap(str,25,CCSizeMake(self.bgLayer:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.freeRefreshLb:setAnchorPoint(ccp(0,0.5))
    self.freeRefreshLb:setPosition(ccp(20,90))
    self.bgLayer:addChild(self.freeRefreshLb,1)

    
    if G_isGlobalServer()==false then
        -- local peaceStStr=getlocal("timeLabel2",{(weaponrobCfg.peaceTime[1][1]==0 and "00" or weaponrobCfg.peaceTime[1][1]),(weaponrobCfg.peaceTime[1][2]==0 and "00" or weaponrobCfg.peaceTime[1][21])})
        -- local peaceEtStr=getlocal("timeLabel2",{(weaponrobCfg.peaceTime[2][1]==0 and "00" or weaponrobCfg.peaceTime[2][1]),(weaponrobCfg.peaceTime[2][2]==0 and "00" or weaponrobCfg.peaceTime[2][2])})
        local peaceStStr=G_getTimeStr(weaponrobCfg.peaceTime[1][1]*3600+weaponrobCfg.peaceTime[1][2]*60,2)
        local peaceEtStr=G_getTimeStr(weaponrobCfg.peaceTime[2][1]*3600+weaponrobCfg.peaceTime[2][2]*60,2)
        local peaceLb=GetTTFLabelWrap(getlocal("super_weapon_rob_peace_time",{peaceStStr,peaceEtStr}),25,CCSizeMake(self.bgLayer:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        -- local peaceLb=GetTTFLabelWrap(str,25,CCSizeMake(self.bgLayer:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        peaceLb:setAnchorPoint(ccp(0,0.5))
        peaceLb:setPosition(ccp(20,40))
        self.bgLayer:addChild(peaceLb,1)
    end


    local function refreshHandler( ... )
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        
        local function refreshList()
            if self and self.tv then
                local recordPoint=self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
        local function onConfirm()
            local leftTime=superWeaponVoApi:freeRefreshLeftTime()
            if leftTime>0 then
                local costGems=superWeaponVoApi:getBuyRefreshCost()
                if(costGems>playerVoApi:getGems())then
                    GemsNotEnoughDialog(nil,nil,costGems - playerVoApi:getGems(),self.layerNum+1,costGems)
                    do return end
                end
                superWeaponVoApi:weaponGetRoblist(self.fid,true,false,refreshList)
            else
                superWeaponVoApi:weaponGetRoblist(self.fid,false,true,refreshList)
            end
        end
        local leftTime=superWeaponVoApi:freeRefreshLeftTime()
        if leftTime>0 then
            local costGems=superWeaponVoApi:getBuyRefreshCost()
            print("costGems",costGems)
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("super_weapon_rob_refresh_rob_list",{costGems}),nil,self.layerNum+1)
        else
            superWeaponVoApi:weaponGetRoblist(self.fid,false,true,refreshList)
        end
    end
    local menuItem = GetButtonItem("hero_switch1.png","hero_switch2.png","hero_switch2.png",refreshHandler,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem)
    menu:setPosition(ccp(self.bgLayer:getContentSize().width-70,65))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menu,3)
end

function superWeaponRobListDialog:tick()
    if self.timerSpriteEnergy then
        local maxNum=weaponrobCfg.energyMax
        local energyNum,nextTime=superWeaponVoApi:setCurEnergy()
        local energyStr=""
        if energyNum<maxNum then
            energyStr=energyNum.."/"..maxNum.."("..GetTimeStr(nextTime)..")"
        else
            energyStr=energyNum.."/"..maxNum
        end
        self.timerSpriteEnergy:setPercentage((energyNum/maxNum)*100)
        tolua.cast(self.timerSpriteEnergy:getChildByTag(25),"CCLabelTTF"):setString(energyStr)
    end
    if self.freeRefreshLb then
        local leftTime=superWeaponVoApi:freeRefreshLeftTime()
        self.freeRefreshLb:setString(getlocal("super_weapon_rob_free_refresh",{G_getTimeStr(leftTime)}))
    end
end

--用户处理特殊需求,没有可以不写此方法
function superWeaponRobListDialog:doUserHandler()

end

function superWeaponRobListDialog:dispose()
    self.fid=nil
end




