purifyingDialog1=commonDialog:new()

function purifyingDialog1:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/refiningImage.plist")
	return nc
end	

function purifyingDialog1:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))  
end	

function purifyingDialog1:initLayer()
    local spH = self.bgLayer:getContentSize().height-100
    local function touchSp()
        PlayEffect(audioCfg.mouseClick)
        require "luascript/script/game/scene/gamedialog/purifying/purifyingSmallUpdateDialog"
        local smallDialog=purifyingSmallUpdateDialog:new()
        smallDialog:init(self.layerNum+1,self.parent,getlocal("upgradeBuild"))
    end

    local function touchItem()
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local str1 = getlocal("purifying_item_des1")
        local str2 = getlocal("purifying_item_des2")
        local str3 = getlocal("purifying_item_des3")
        local tabStr = {" ",str3,str2,str1," "}
        local colorTb = {nil,nil,nil,nil}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTb)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

   local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchItem,11,nil,nil)
   menuItem:setAnchorPoint(ccp(1,1))
   local menu = CCMenu:createWithItem(menuItem);
   menu:setPosition(ccp(self.bgLayer:getContentSize().width-30,spH));
   menu:setTouchPriority(-(self.layerNum-1)*20-4);
   self.bgLayer:addChild(menu,3)

    local lbWidth = 220
    local jiyouWidth = 30
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="ar"then
        lbWidth =150
        jiyouWidth=20
    end

    local engineerSp = LuaCCSprite:createWithSpriteFrameName("jiyou.png",touchSp)
    engineerSp:setAnchorPoint(ccp(0,1))
    engineerSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(engineerSp)
    engineerSp:setPosition(ccp(jiyouWidth,spH-20))
    engineerSp:setScale(1.2)

    local lvLb = GetTTFLabel(getlocal("purifying_engineer_level",{accessoryVoApi:getSuccinct_level()}),25)
    lvLb:setPosition(ccp(lbWidth,spH-25))
    lvLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(lvLb)
    self.lvLb=lvLb

    local exp
   
    -- if accessoryVoApi:getSuccinct_level()==succinctCfg.engineerLvLimit then
    --     exp=succinctCfg.engineerExp[succinctCfg.engineerLvLimit]
    -- else
        exp=succinctCfg.engineerExp[accessoryVoApi:getSuccinct_level()+1]
    -- end  

     local subLevel
     if  accessoryVoApi:getSuccinct_level()==1 then
        subLevel=0
    else
        subLevel=succinctCfg.engineerExp[accessoryVoApi:getSuccinct_level()]
     end

    local exLb = GetTTFLabel(getlocal("purifying_engineer_experience",{accessoryVoApi:getSuccinct_exp()-subLevel,exp-subLevel}),25)
    exLb:setPosition(ccp(lbWidth,spH-60))
    exLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(exLb)
    self.exLb=exLb

    local lifeLb = GetTTFLabel(getlocal("engineer_experience1_limit",{succinctCfg.attLifeLimit[accessoryVoApi:getSuccinct_level()]*100 .. "%%"}),25)
    lifeLb:setPosition(ccp(lbWidth,spH-95))
    lifeLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(lifeLb)
    self.lifeLb=lifeLb

    local proLb = GetTTFLabel(getlocal("engineer_experience2_limit",{succinctCfg.arpArmorLimit[accessoryVoApi:getSuccinct_level()]}),25)
    proLb:setPosition(ccp(lbWidth,spH-130))
    proLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(proLb)
    self.proLb=proLb

end

function purifyingDialog1:initTableView()
    self:initLayer()
	local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSizeHeight-300),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function purifyingDialog1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 4
    elseif fn=="tableCellSizeForIndex" then
       self.cellHight = 250
       return  CCSizeMake(self.bgLayer:getContentSize().width-20,self.cellHight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local background=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function () end)
        background:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,self.cellHight-5))
        background:setAnchorPoint(ccp(0,0))
        background:setPosition(ccp(5,5))
        cell:addChild(background)

        local imageTb = {"refiningTank1.png","refiningTank2.png","refiningTank3.png","refiningTank4.png"}

        local tanId = idx+1
        local tankIcon=CCSprite:createWithSpriteFrameName(imageTb[idx+1])
        tankIcon:setAnchorPoint(ccp(0,0.5))
        tankIcon:setPosition(ccp(10,background:getContentSize().height/2))
        background:addChild(tankIcon)
        -- tankIcon:setScale(0.4)

        local h1 = 178
        local h2 = 73
        local w = 150
        self.posTb={}
        self.posTb[1]=ccp(w+100,h1)
        self.posTb[2]=ccp(w+200,h1)
        self.posTb[3]=ccp(w+300,h1)
        self.posTb[4]=ccp(w+400,h1)
        self.posTb[5]=ccp(w+100,h2)
        self.posTb[6]=ccp(w+200,h2)
        self.posTb[7]=ccp(w+300,h2)
        self.posTb[8]=ccp(w+400,h2)

        local equips=accessoryVoApi:getTankAccessories(tanId) or {}
        
        self.icons={}
        for k,v in pairs(self.posTb) do
            local aVo=equips["p"..k]
            local aIcon
            local function onClickIcon(hd,fn,tag)
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    if aVo:getConfigData("quality")>2 then
                        require "luascript/script/game/scene/gamedialog/purifying/purifyingDialog2"
                        local td=purifyingDialog2:new(aVo,self,"p"..k,"t" .. idx+1)
                        local tbArr={}
                        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("purifying"),true,self.layerNum+1)
                        sceneGame:addChild(dialog,self.layerNum+1)
                    else
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_limit_des"),30)
                    end
                    
                end
            end
            local function onClickLock(hd,fn,tag)
                 if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    if(tag>accessoryCfg.unLockPart)then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_notOpen"),30)
                    else
                    local unlockLv=accessoryCfg.partUnlockLv[tag]
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_part_unlock_desc",{unlockLv}),30)
                    end
                end
               
            end
            local function onClickEmptyGrid()
               if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                end
            end
            local function onNumBg()
               if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_not_wear"),30)
                end
            end
            if(aVo~=nil)then
                aIcon=accessoryVoApi:getAccessoryIcon(aVo.type,60,80,onClickIcon)
                local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
                local rankLb=GetTTFLabel(aVo.rank,30)
                rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
                rankTip:addChild(rankLb)
                rankTip:setScale(0.5)
                rankTip:setAnchorPoint(ccp(0,1))
                rankTip:setPosition(ccp(0,100))
                aIcon:addChild(rankTip)
                local lvLb=GetTTFLabel("Lv. "..aVo.lv,20)
                lvLb:setAnchorPoint(ccp(1,0))
                lvLb:setPosition(ccp(85,5))
                aIcon:addChild(lvLb)

                 if aVo:getConfigData("quality")<=2 then
                    local blackIcon = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
                    aIcon:addChild(blackIcon)
                    blackIcon:setPosition(ccp(aIcon:getContentSize().width/2,aIcon:getContentSize().height/2))
                    blackIcon:setScale(aIcon:getContentSize().width/blackIcon:getContentSize().width)
                    blackIcon:setOpacity(255)
                end
            else
                if(accessoryVoApi:checkPartUnlock(k))then
                    
                    if(accessoryVoApi.unUsedAccessory~=nil and accessoryVoApi.unUsedAccessory["t"..tanId]~=nil and accessoryVoApi.unUsedAccessory["t"..tanId]["p"..k]~=nil)then
                        aIcon=GetBgIcon("accessoryshadow_"..k..".png",onNumBg,nil,60,80)
                        local capInSet1 = CCRect(17, 17, 1, 1)
                        local function touchClick()

                        end
                        local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
                        newsIcon:setScale(0.5)
                        newsIcon:setPosition(ccp(70,70))
                        aIcon:addChild(newsIcon)
                    else
                        aIcon=GetBgIcon("accessoryshadow_"..k..".png",onClickEmptyGrid,nil,60,80)
                    end
                else
                    aIcon=GetBgIcon("accessoryshadow_"..k..".png",onClickLock,nil,60,80)
                    local lockIcon=CCSprite:createWithSpriteFrameName("LockIcon.png")
                    lockIcon:setScale(30/lockIcon:getContentSize().width)
                    lockIcon:setPosition(ccp(40,40))
                    aIcon:addChild(lockIcon)
                    if(k<=accessoryCfg.unLockPart)then
                        local unlockLb=GetTTFLabel(getlocal("fightLevel",{accessoryCfg.partUnlockLv[k]}),20)
                        unlockLb:setAnchorPoint(ccp(0.5,0))
                        unlockLb:setPosition(ccp(40,2))
                        unlockLb:setColor(G_ColorYellowPro)
                        aIcon:addChild(unlockLb)
                    end
                end
            end
            aIcon:setTouchPriority(-(self.layerNum-1)*20-2)
            aIcon:setTag(k)
            aIcon:setPosition(v)
            cell:addChild(aIcon,1)
            self.icons[k]=aIcon
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

function purifyingDialog1:refresh()
    self.lvLb:setString(getlocal("purifying_engineer_level",{accessoryVoApi:getSuccinct_level()}))
    local exp
    -- if accessoryVoApi:getSuccinct_level()==succinctCfg.engineerLvLimit then
    --     exp=succinctCfg.engineerExp[succinctCfg.engineerLvLimit]
    -- else
        exp=succinctCfg.engineerExp[accessoryVoApi:getSuccinct_level()+1]
    -- end
     if  accessoryVoApi:getSuccinct_level()==1 then
        subLevel=0
    else
        subLevel=succinctCfg.engineerExp[accessoryVoApi:getSuccinct_level()]
     end
    self.exLb:setString(getlocal("purifying_engineer_experience",{accessoryVoApi:getSuccinct_exp()-subLevel,exp-subLevel}))
    self.lifeLb:setString(getlocal("engineer_experience1_limit",{succinctCfg.attLifeLimit[accessoryVoApi:getSuccinct_level()]*100 .. "%%"}))
    self.proLb:setString(getlocal("engineer_experience2_limit",{succinctCfg.arpArmorLimit[accessoryVoApi:getSuccinct_level()]}))
end 


function purifyingDialog1:dispose()
    self.lvLb=nil
    self.exLb=nil
    self.lifeLb=nil
    self.proLb=nil
    self.tv=nil
    self.posTb=nil
    self.icons=nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/refiningImage.plist")
end


   


