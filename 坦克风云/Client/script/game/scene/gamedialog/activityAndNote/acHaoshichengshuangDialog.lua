acHaoshichengshuangDialog = commonDialog:new()

function acHaoshichengshuangDialog:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self

	self.tabviewSize=nil
    self.drawing=false
    self.oneOrall=nil
    self.CurrentRewardIndex=0
    self.currenAllReward=false
    self.actionType=nil
    self.buyTwobtn=nil
    self.buyTenbtn=nil
    self.allbtn=nil
    self.OwnCountLabel=nil     --拥有的刷新次数
    self.alertTimeLabel=nil
    self.currentStateData=nil
    self.lastDrawIndex = 0     --上一次的抽取位置
    self.tabRewarList=nil
    self.boxList={}                                 --12个抽取位
    self.selectedIndex=0       --翻的牌的位置
    self.descBg=nil
    self.rewardItem=nil
    self.isRequiring=false
    self.extrareward=nil
    self.bgimage=nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acHaoshichengshuang.plist")
	return nc
end	

function acHaoshichengshuangDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))   
end	

function acHaoshichengshuangDialog:initTableView()
	local function callback( ... )
	end

	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
	self:tabClick(0,false)
end

function acHaoshichengshuangDialog:doUserHandler()
	self.tabRewarList={}
    for i=1,12 do
        self.tabRewarList[i]={type=0,action=false}
    end

    local desHe=270
    if G_isIphone5()==true then
        desHe=290
    end

    local function touch()
    end

    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),touch);
    self.bgLayer:addChild(descBg,4)
    descBg:setAnchorPoint(ccp(0.5,1))
    descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,desHe))
    descBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight -95))
    if G_isIphone5()==true then
        descBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight -105))
    end

    local timelabel = GetTTFLabel(getlocal("activity_timeLabel"),26)
    local timelabel1 = GetTTFLabel(acHaoshichengshuangVoApi:getTimeStr(),26)
    timelabel:setAnchorPoint(ccp(0.5,1))
    timelabel1:setAnchorPoint(ccp(0.5,1))
    timelabel:setHorizontalAlignment(kCCTextAlignmentCenter)
    timelabel1:setHorizontalAlignment(kCCTextAlignmentCenter)
    descBg:addChild(timelabel)
    descBg:addChild(timelabel1)
    timelabel:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height-10))
    timelabel1:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height-40))
    self.timeLb=timelabel1
    self:updateAcTime()


    local desTv, desLabel= G_LabelTableView(CCSizeMake(descBg:getContentSize().width*0.9, 60),getlocal("activity_haoshichengshuang_des"),25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(descBg:getContentSize().width*0.05,descBg:getContentSize().height-140))
    desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(60)
	descBg:addChild(desTv)  
    
    local function tipTouch()
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local tabStr = {"\n",getlocal("activity_haoshichengshuang_tip5"), getlocal("activity_haoshichengshuang_tip4"),getlocal("activity_haoshichengshuang_tip3"),getlocal("activity_haoshichengshuang_tip2"),getlocal("activity_haoshichengshuang_tip1"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
		sceneGame:addChild(dialog,self.layerNum+1)
    end
    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    tipItem:setAnchorPoint(ccp(1,1))
    tipItem:setScale(0.9)
    local menu = CCMenu:createWithItem(tipItem)
    descBg:addChild(menu,4)
    menu:setPosition(ccp(descBg:getContentSize().width-10,descBg:getContentSize().height-10))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)

    local acVo = acHaoshichengshuangVoApi:getAcVo()
    local troopPool=acVo.reward.troopPool
    local tankList = FormatItem(troopPool,nil,true)
    
    local iconH = 0
    if G_isIphone5()==true then
        iconH=10
    end
    for i=1,#tankList do
        local item = tankList[i]
        local function touch()
            local tankID = tonumber(RemoveFirstChar(item.key))
	        tankInfoDialog:create(nil,tankID,self.layerNum+1, nil)
        end
        local icon = LuaCCSprite:createWithSpriteFrameName(item.pic,touch)
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        descBg:addChild(icon)
        icon:setPosition(ccp(90+140*(i-1),60+iconH))
        icon:setScale(100/icon:getContentSize().width)
        G_addRectFlicker(icon,2,2)
    end

    self.alertTimeLabel = GetTTFLabel(getlocal("activity_haoshichengshuang_desc1",{GetTimeStr(acVo.reward.limitTime)}),25)
    -- descBg:addChild(self.alertTimeLabel)
    -- self.alertTimeLabel:setPosition(ccp(descBg:getContentSize().width*0.5,-20))
    self.alertTimeLabel:setColor(G_ColorYellow)

    self.OwnCountLabel = GetTTFLabel(getlocal("activity_haoshichengshuang_desc2",{acHaoshichengshuangVoApi:getownCount()}),25)
    -- self.bgLayer:addChild(self.OwnCountLabel)
    -- self.OwnCountLabel:setColor(G_ColorBlue)
    local viewHight = G_isIphone5()==true and 450 or 360
    self.tabviewSize = CCSizeMake(G_VisibleSizeWidth-40,viewHight)
    local pos_y = G_isIphone5()==true and 225 or 178
    -- self.OwnCountLabel:setPosition(ccp(G_VisibleSizeWidth*0.5,pos_y-20))

    local function touch( ... )
    end 
    local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),touch);
    self.bgLayer:addChild(descBg,1)
    descBg:setAnchorPoint(ccp(0.5,0))
    descBg:setContentSize(CCSizeMake(self.tabviewSize.width,self.tabviewSize.height+50))
    descBg:setPosition(ccp(G_VisibleSizeWidth*0.5,pos_y))

    

    self.descBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),touch);
    self.bgLayer:addChild(self.descBg,1)
    self.descBg:setAnchorPoint(ccp(0.5,0))
    self.descBg:setContentSize(self.tabviewSize)
    self.descBg:setPosition(ccp(G_VisibleSizeWidth*0.5,pos_y))
    self.descBg:setOpacity(0)

    local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
    descBg:addChild(bgSp)
    bgSp:setPosition(descBg:getContentSize().width/2, descBg:getContentSize().height-50/2)
    bgSp:setScaleX(1000/bgSp:getContentSize().width)
    bgSp:setScaleY(50/bgSp:getContentSize().height)

    bgSp:addChild(self.alertTimeLabel)
    self.alertTimeLabel:setPosition(bgSp:getContentSize().width*0.5,bgSp:getContentSize().height/2)
    self.alertTimeLabel:setScaleX(bgSp:getContentSize().width/1000)
    self.alertTimeLabel:setScaleY(bgSp:getContentSize().height/50)



    self:initRewardPool(pos_y)

    local function touchCallback(tag,object)
        local acVo = acHaoshichengshuangVoApi:getAcVo()
        local rewardCfg = acHaoshichengshuangVoApi:getCfg()
        if tag==20 or tag==21 then
            local NeedCost = 10000
            local count = 2
            if tag==20 then
                NeedCost = rewardCfg.twoCost
                count=2
            else
                NeedCost = rewardCfg.tenCost
                count=10
            end
            local function buycallback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.gems then
                        playerVoApi:setGems(tonumber(sData.data.gems))
                    end
                    if sData and sData.data and sData.data.haoshichengshuang and sData.data.haoshichengshuang.d and sData.data.haoshichengshuang.d.nums then
                        acVo.currentState.nums = sData.data.haoshichengshuang.d.nums
                    end
                    self:freshDialog()
                end
                base:cancleWait()
                base:cancleNetWait()
            end
            local function tobuy( ... )    ---购买次数
                local pType = tag==20 and 3 or 4
                socketHelper:acHaoshichengshuang(pType,nil,nil,buycallback)
                -- base:setWait()
                -- base:setNetWait()
            end
            local function buyGems()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
                end
                vipVoApi:showRechargeDialog(self.layerNum+1)
            end
            local function canclebuy(...)
            end
            if tonumber(NeedCost)<=playerVo.gems then
                local smallD=smallDialog:new()
                smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tobuy,getlocal("dialog_title_prompt"),getlocal("activity_haoshichengshuang_desc5",{tonumber(NeedCost),tonumber(count)}),nil,self.layerNum+2,nil,nil,canclebuy)
            elseif tonumber(NeedCost)>playerVo.gems then
                local num=tonumber(NeedCost)-playerVo.gems
                local smallD=smallDialog:new()
                smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(NeedCost),playerVo.gems,num}),nil,self.layerNum+2,nil,nil,canclebuy)
            end
        elseif tag==22 then
            smDiaHeight=400
            if G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" then
                smDiaHeight =450
            end
            if tonumber(acVo.currentState.cleanTimes or 0)<5 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,smDiaHeight),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_haoshichengshuang_desc6",{5-tonumber(acVo.currentState.cleanTimes or 0)}),nil,self.layerNum+1,nil,nil)
                return
            end
            local openflag= true 
            for k,v in pairs(self.tabRewarList)do
                if v.type==1 then
                    openflag=false
                end
            end
            if openflag== false then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_haoshichengshuang_desc8"),nil,self.layerNum+1,nil,nil)
                return
            end
            local NeedCost = 10000
            NeedCost=rewardCfg.totalCost
            local function buycallback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.gems then
                        playerVoApi:setGems(tonumber(sData.data.gems))
                    end
                    if sData and sData.data and sData.data.accessory then
                        accessoryVoApi:onRefreshData(sData.data.accessory) 
                    end
                    if sData and sData.data and sData.data.haoshichengshuang and sData.data.haoshichengshuang.d and sData.data.haoshichengshuang.d.nums then
                        acVo.currentState.nums = sData.data.haoshichengshuang.d.nums
                    end
                    if sData and sData.data and sData.data.haoshichengshuang then
                        self.currentStateData = sData.data.haoshichengshuang
                    end
                    if sData and sData.data and sData.data.report and sData.data.previousOpen then
                        local report = {}
                        for k,v in pairs(sData.data.report) do
                            for kk,vv in pairs(FormatItem(v)) do
                                table.insert(report,vv)
                            end
                        end
                        
                        self:displayAllReward(sData.data.previousOpen,report)
                    end
                    self:freshDialog()
                end
                base:cancleWait()
                base:cancleNetWait()
            end
            local function tobuy( ... )    ---全部开启
                socketHelper:acHaoshichengshuang(5,nil,nil,buycallback)
                -- base:setWait()
                -- base:setNetWait()
            end
            local function buyGems()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
                end
                vipVoApi:showRechargeDialog(self.layerNum+1)
                -- vipVoApi:showRechargeDialog(self.layerNum+1)
            end
            local function canclebuy(...)
            end
            if tonumber(NeedCost)<=playerVo.gems then
                local smallD=smallDialog:new()
                smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tobuy,getlocal("dialog_title_prompt"),getlocal("activity_haoshichengshuang_desc9",{tonumber(NeedCost)}),nil,self.layerNum+2,nil,nil,canclebuy)
            elseif tonumber(NeedCost)>playerVo.gems then
                local num=tonumber(NeedCost)-playerVo.gems
                local smallD=smallDialog:new()
                smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(NeedCost),playerVo.gems,num}),nil,self.layerNum+2,nil,nil,canclebuy)
            end
        end
    end
    self.buyTwobtn= GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",touchCallback,2,getlocal("activity_haoshichengshuang_btn_2"),25)
    self.buyTenbtn= GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",touchCallback,2,getlocal("activity_haoshichengshuang_btn_3"),25)
    self.allbtn= GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",touchCallback,2,getlocal("activity_haoshichengshuang_btn_4"),25)
    local btnMenu = CCMenu:create()
    btnMenu:addChild(self.buyTwobtn)
    btnMenu:addChild(self.buyTenbtn)
    btnMenu:addChild(self.allbtn)
    self.buyTwobtn:setTag(20)
    self.buyTenbtn:setTag(21)
    self.allbtn:setTag(22)
    -- btnMenu:setPosition(ccp(G_VisibleSizeWidth*0.5,pos_y-80))
    btnMenu:alignItemsHorizontallyWithPadding(50)
    -- self.bgLayer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-3)

    local desH=150
    if G_isIphone5()==true then
        desH=190
    end

     local menuBg = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),touch);
    menuBg:setAnchorPoint(ccp(0.5,0))
    menuBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,desH))
    menuBg:setPosition(ccp(G_VisibleSizeWidth*0.5,20))
    self.bgLayer:addChild(menuBg,4)

    menuBg:addChild(btnMenu)
    btnMenu:setPosition(menuBg:getContentSize().width/2, 40)

    menuBg:addChild(self.OwnCountLabel)
    self.OwnCountLabel:setPosition(menuBg:getContentSize().width/2, menuBg:getContentSize().height-23)
    if G_isIphone5()==true then
        self.OwnCountLabel:setPosition(menuBg:getContentSize().width/2, menuBg:getContentSize().height-33)
    end
    

    local rewardCfg = acHaoshichengshuangVoApi:getCfg()
    for i=1,3 do
        local gems=999999
        if i==1 then
            gems=rewardCfg.twoCost
        elseif i==2 then
            gems=rewardCfg.tenCost
        else
            gems=rewardCfg.totalCost
        end
        local sp = CCSprite:createWithSpriteFrameName("IconGold.png")
        local gemsLb = GetTTFLabel(tostring(gems),25)
        gemsLb:setAnchorPoint(ccp(0,0.5))
        gemsLb:setPosition(sp:getContentSize().width+10, sp:getContentSize().height/2)
        sp:addChild(gemsLb)
        sp:setAnchorPoint(ccp(0.5,0))

        if i==1 then
            self.buyTwobtn:addChild(sp)
            sp:setPosition(self.buyTwobtn:getContentSize().width/2-10, self.buyTwobtn:getContentSize().height)
        elseif i==2 then
            self.buyTenbtn:addChild(sp)
            sp:setPosition(self.buyTenbtn:getContentSize().width/2-10, self.buyTenbtn:getContentSize().height)
        else
           self.allbtn:addChild(sp)
            sp:setPosition(self.allbtn:getContentSize().width/2-10, self.allbtn:getContentSize().height)
        end
    end




    -- if acVo.acEt<base.serverTime then
    --     self.buyTwobtn:setEnabled(false)
    --     self.buyTenbtn:setEnabled(false)
    --     self.allbtn:setEnabled(false)
    -- end

     --请求网络数据
    self:getLiaoningData()
end

function acHaoshichengshuangDialog:getLiaoningData()
    local acVo = acHaoshichengshuangVoApi:getAcVo()
    -- if acVo.acEt<base.serverTime then
    --     return
    -- end
    local function datacallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.haoshichengshuang and sData.data.haoshichengshuang.d then
                local acVo = acHaoshichengshuangVoApi:getAcVo()
                self.lastDrawIndex=0
                if acVo.currentState.currentOpen and SizeOfTable(acVo.currentState.currentOpen)>0 then
                    self.lastDrawIndex = acVo.currentState.currentOpen[SizeOfTable(acVo.currentState.currentOpen)]
                end
                acHaoshichengshuangVoApi:updateData(sData.data.haoshichengshuang)
                local  acVo  = acHaoshichengshuangVoApi:getAcVo()
                if acVo.currentState and acVo.currentState.begin and acVo.currentState.beginTs and acVo.currentState.begin==1 and (acVo.currentState.beginTs+acVo.reward.limitTime)>base.serverTime then
                    local time = acVo.currentState.beginTs+acVo.reward.limitTime-base.serverTime
                    time = time<=0 and 0 or time
                    self.alertTimeLabel:setColor(G_ColorRed)
                    time = GetTimeForItemStrState(time)
                    self.alertTimeLabel:setString(getlocal("activity_haoshichengshuang_desc7",{time}))
                end
                self:refreshRewardBox()
            end
        end
        base:cancleWait()
        base:cancleNetWait()
    end
    -- base:setWait()
    -- base:setNetWait()
    base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
    socketHelper:acHaoshichengshuang(1,nil,nil,datacallback)
end


function acHaoshichengshuangDialog:refreshRewardBox()
    local acVo = acHaoshichengshuangVoApi:getAcVo()
    for k,v in pairs(self.boxList)do
        local image = tolua.cast(v,"CCSprite")
        image:removeFromParentAndCleanup(true)
    end
    local pos_y = G_isIphone5()==true and 235 or 178
    self:initRewardPool(pos_y)
    for i=1,12 do
        self.tabRewarList[i]={type=0,action=false}
    end
    for k,v in pairs(acVo.currentState.currentOpen) do
        local item = acHaoshichengshuangVoApi:getRewardItem(v)
        local icon = CCSprite:createWithSpriteFrameName(item.pic)
        icon:setScale(100/icon:getContentSize().width)
        local image = self.boxList[v]
        image:removeAllChildrenWithCleanup(true)
        image = tolua.cast(image,"CCSprite")
        image:addChild(icon)
        icon:setPosition(getCenterPoint(image))
        self.tabRewarList[v].type=1
    end
end

function acHaoshichengshuangDialog:initRewardPool(pos_y)
    local acVo = acHaoshichengshuangVoApi:getAcVo()
    local rewardCfg = acHaoshichengshuangVoApi:getCfg()
    -- local function touch( ... )
    -- end 
    -- local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),touch);
    -- self.bgLayer:addChild(descBg,1)
    -- descBg:setAnchorPoint(ccp(0.5,0))
    -- descBg:setContentSize(CCSizeMake(self.tabviewSize.width,self.tabviewSize.height+50))
    -- descBg:setPosition(ccp(G_VisibleSizeWidth*0.5,pos_y))

    -- self.descBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),touch);
    -- self.bgLayer:addChild(self.descBg,1)
    -- self.descBg:setAnchorPoint(ccp(0.5,0))
    -- self.descBg:setContentSize(self.tabviewSize)
    -- self.descBg:setPosition(ccp(G_VisibleSizeWidth*0.5,pos_y))
    -- self.descBg:setOpacity(0)
    for i=1,12 do
        local function callBack2()
            -- if self.drawing==true or acVo.acEt<base.serverTime or self.tabRewarList[i].type==1 or self:IsHadaction()==true then
            --     return
            -- end
            if self.drawing==true or self.tabRewarList[i].type==1 or self:IsHadaction()==true then
                return
            end
            self.drawing=true
            PlayEffect(audioCfg.mouseClick)
            local function callBack(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    self.currentInfo={}
                    if sData and sData.data and sData.data.accessory then
                        accessoryVoApi:onRefreshData(sData.data.accessory) 
                    end
                    if sData and sData.data and sData.data.gems then
                        playerVoApi:setGems(tonumber(sData.data.gems))
                    end
                    if sData and sData.data and sData.data.currentOpenIndex then
                        self.CurrentRewardIndex = sData.data.currentOpenIndex
                        local acVo = acHaoshichengshuangVoApi:getAcVo()
                        self.lastDrawIndex=0
                        if acVo.currentState.currentOpen and (SizeOfTable(acVo.currentState.currentOpen)%2)~=0 then
                            self.lastDrawIndex = acVo.currentState.currentOpen[SizeOfTable(acVo.currentState.currentOpen)]
                        end
                    end
                    if sData and sData.data and sData.data.index then
                        self.selectedIndex = sData.data.index
                    end
                    if sData and sData.data and sData.data.haoshichengshuang then
                        self.currentStateData = sData.data.haoshichengshuang
                    end
                    if sData and sData.data and sData.data.haoshichengshuang and sData.data.haoshichengshuang.d and sData.data.haoshichengshuang.d.nums then
                        acVo.currentState.nums = sData.data.haoshichengshuang.d.nums
                    end
                    self.rewardItem=nil
                    if sData and sData.data and sData.data.reward then
                        self.rewardItem = sData.data.reward
                    end
                    if sData and sData.data and sData.data.extraReward then
                        self.extrareward = sData.data.extraReward
                    end
                    self:reloadDrawdata(true)
                    self:tick()
                else
                    -- print("----sData.ret="..sData.ret)
                    if sData and sData.ret==-2034 and sData.data and sData.data.haoshichengshuang then
                        local acVo = acHaoshichengshuangVoApi:getAcVo()
                        self.lastDrawIndex=0
                        acHaoshichengshuangVoApi:updateData(sData.data.haoshichengshuang)
                        -- print("__________")
                        self:refreshRewardBox()
                        for i=1,12 do
                            -- print("__1___="..i)
                            self.tabRewarList[i]={type=0,action=false}
                        end
                    end
                end
                self:freshDialog()
                base:cancleWait()
                base:cancleNetWait()
                self.drawing=false
            end
            if tonumber(acHaoshichengshuangVoApi:getownCount())>0 then
                socketHelper:acHaoshichengshuang(2,i,acVo.currentState.refreshTs,callBack)
                -- base:setWait()
                -- base:setNetWait()
            else
                local NeedCost = 100000
                local function tobuy( ... )    ---购买次数
                    local function buycallback(fn,data)
                        local ret,sData = base:checkServerData(data)
                        if ret==true then
                            if sData and sData.data and sData.data.gems then
                                playerVoApi:setGems(tonumber(sData.data.gems))
                            end
                            if sData and sData.data and sData.data.haoshichengshuang and sData.data.haoshichengshuang.d and sData.data.haoshichengshuang.d.nums then
                                acVo.currentState.nums = sData.data.haoshichengshuang.d.nums
                            end
                            self:freshDialog()
                        end
                        base:cancleWait()
                        base:cancleNetWait()
                    end
                    socketHelper:acHaoshichengshuang(4,nil,nil,buycallback)
                    -- base:setWait()
                    -- base:setNetWait()
                    self.drawing=false
                end
                local function buyGems()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
                    end
                    self.drawing=false
                    vipVoApi:showRechargeDialog(self.layerNum+1)
                end
                local function canclebuy(...)
                    self.drawing=false
                end
                NeedCost = rewardCfg.tenCost
                if tonumber(NeedCost)<=playerVo.gems then
                    local smallD=smallDialog:new()
                    smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168,86,10,10),tobuy,getlocal("dialog_title_prompt"),getlocal("activity_haoshichengshuang_desc3",{tonumber(NeedCost)}),nil,self.layerNum+1,nil,nil,canclebuy)
                elseif tonumber(NeedCost)>playerVo.gems then
                    local num=tonumber(NeedCost)-playerVo.gems
                    local smallD=smallDialog:new()
                    smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168,86,10,10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(NeedCost),playerVo.gems,num}),nil,self.layerNum+1,nil,nil,canclebuy)
                end
            end
        end
        local blackLabelBg = LuaCCSprite:createWithSpriteFrameName("acHSCSkabei.png",callBack2)
        self.boxList[i]=blackLabelBg      --记录该抽取位
        self.descBg:addChild(blackLabelBg,3)
        blackLabelBg:setAnchorPoint(ccp(0.5,0.5))
        blackLabelBg:setTouchPriority(-(self.layerNum-1)*20-4)
        -- blackLabelBg:setScale(100/blackLabelBg:getContentSize().width)
        local pos_x = i%4==0 and 4 or i%4
        local pos_y = 3-math.floor((i-1)/4)
        local pos_now = ccp(self.tabviewSize.width/4*0.5+self.tabviewSize.width/4*(pos_x-1),self.tabviewSize.height/3*0.5+self.tabviewSize.height/3*(pos_y-1))
        blackLabelBg:setPosition(pos_now)
    end
end

function acHaoshichengshuangDialog:backToinit( ... ) ---复位
    for k,v in pairs(self.tabRewarList)do
        if v and v.type ~=0 then      --正面

        end
    end
end

function acHaoshichengshuangDialog:reloadDrawdata(isDraw)
    local acVo = acHaoshichengshuangVoApi:getAcVo()
    if isDraw==true then
        local flag = acVo.currentState.open[self.lastDrawIndex]
        if self.lastDrawIndex==0 and self.CurrentRewardIndex>0 then   --没有翻过来的牌

            local image = self.boxList[self.selectedIndex]
            image = tolua.cast(image,"CCSprite")
            image:removeAllChildrenWithCleanup(true)
            local item
            local function displayReward( ... )
                image:removeAllChildrenWithCleanup(true)
                item = acHaoshichengshuangVoApi:getRewardItem(self.CurrentRewardIndex,true)
                local icon = CCSprite:createWithSpriteFrameName(item.pic)
                icon:setScaleY(100/icon:getContentSize().width)
                icon:setScaleX(-100/icon:getContentSize().width)
                icon:setPosition(getCenterPoint(image))
                image:addChild(icon)
            end
            local len = self.CurrentRewardIndex
            len = len%4==0 and 4 or len%4
            local function setDatacallback( ... )
                self.tabRewarList[self.selectedIndex].type=1
                self.tabRewarList[self.selectedIndex].action=false
                acHaoshichengshuangVoApi:updateData(self.currentStateData)
            end
            self.tabRewarList[self.selectedIndex].type=1
            self.tabRewarList[self.selectedIndex].action=true
            local action = self:turnarount1(len,displayReward,setDatacallback)
            image:runAction(action)
        elseif self.lastDrawIndex~=0 then                             --有翻过来的牌
            ------最近一次的翻牌跟本次的一样
            local rewardindx = acVo.currentState.open[self.lastDrawIndex]
            local image = self.boxList[self.selectedIndex]
            image = tolua.cast(image,"CCSprite")
            image:removeAllChildrenWithCleanup(true)
            if rewardindx == self.CurrentRewardIndex then
                local item
                local function displayReward( ... )
                    image:removeAllChildrenWithCleanup(true)
                    item = acHaoshichengshuangVoApi:getRewardItem(self.CurrentRewardIndex,true)
                    local icon = CCSprite:createWithSpriteFrameName(item.pic)
                    icon:setScaleY(100/icon:getContentSize().width)
                    icon:setScaleX(-100/icon:getContentSize().width)
                    icon:setPosition(getCenterPoint(image))
                    image:addChild(icon)
                end
                local len = self.CurrentRewardIndex
                len = len%4==0 and 4 or len%4
                local function setDatacallback( ... )
                    self.tabRewarList[self.selectedIndex].type=1
                    self.tabRewarList[self.selectedIndex].action=false
                    acHaoshichengshuangVoApi:updateData(self.currentStateData)
                    self:displayGetReward(self.rewardItem)
                end
                self.tabRewarList[self.selectedIndex].type=1
                self.tabRewarList[self.selectedIndex].action=true
                local action = self:turnarount1(len,displayReward,setDatacallback)
                image:runAction(action)
            else                                            
                --最近一次的翻牌跟本次的不一样
                local lastImage = self.boxList[self.lastDrawIndex]
                lastImage = tolua.cast(lastImage,"CCSprite")
                local len = self.CurrentRewardIndex
                len = len%4==0 and 4 or len%4
                local function displayReward( ... )
                    image:removeAllChildrenWithCleanup(true)
                    local item = acHaoshichengshuangVoApi:getRewardItem(self.CurrentRewardIndex,true)
                    local icon = CCSprite:createWithSpriteFrameName(item.pic)
                    icon:setScaleY(100/icon:getContentSize().width)
                    icon:setScaleX(-100/icon:getContentSize().width)
                    icon:setPosition(getCenterPoint(image))
                    image:addChild(icon)
                end
                local function removeReward1( ... )
                    image:removeAllChildrenWithCleanup(true)
                end
                local function removeReward2( ... )
                    lastImage:removeAllChildrenWithCleanup(true)
                end
                local function setDatacallback1( ... )
                    self.tabRewarList[self.selectedIndex].type=0
                    self.tabRewarList[self.selectedIndex].action=false
                    acHaoshichengshuangVoApi:updateData(self.currentStateData)
                end
                local function setDatacallback2( ... )
                    self.tabRewarList[self.lastDrawIndex].type=0
                    self.tabRewarList[self.lastDrawIndex].action=false
                    acHaoshichengshuangVoApi:updateData(self.currentStateData)
                end
                local function lastCallback( ... )
                    --最近的那次翻过来的牌重新翻回去
                    local action_1 = self:turnarount2(len,removeReward1,setDatacallback1)
                    local len2 = self.lastDrawIndex
                    len2 = len2%4==0 and 4 or len2%4
                    local action_2 = self:turnarount2(len2,removeReward2,setDatacallback2)
                    image:stopAllActions()
                    image:runAction(action_1)
                    lastImage:runAction(action_2)
                end
                self.tabRewarList[self.selectedIndex].type=1
                self.tabRewarList[self.selectedIndex].action=true
                self.tabRewarList[self.lastDrawIndex].type=1
                self.tabRewarList[self.lastDrawIndex].action=true
                local action = self:turnarount1(len,displayReward,lastCallback)
                image:runAction(action)
            end
        end
    end
end

function acHaoshichengshuangDialog:turnarount1(index,callback,resetdataCallback)    --打开动画
    local arr = {-105,-95,-85,-75}
    local action = CCOrbitCamera:create(0.25,1,0,0,arr[index],0,0)
    local seqArr = CCArray:create()
    seqArr:addObject(action)
    seqArr:addObject(CCCallFunc:create(callback))
    local action2 = CCOrbitCamera:create(0.25,1,0,arr[index],-(180+arr[index]),0,0)
    seqArr:addObject(action2)
    seqArr:addObject(CCCallFunc:create(resetdataCallback))
    local seq_action = CCSequence:create(seqArr)
    return seq_action
end

function acHaoshichengshuangDialog:turnarount2(index,callback,callback2)    --打开又关闭
    local arr = {105,95,85,75}
    local action = CCOrbitCamera:create(0.25,1,0,-180,180-arr[index],0,0)
    local seqArr = CCArray:create()
    seqArr:addObject(action)
    seqArr:addObject(CCCallFunc:create(callback))
    local action2 = CCOrbitCamera:create(0.25,1,0,180-arr[index],arr[index],0,0)
    seqArr:addObject(action2)
    seqArr:addObject(CCCallFunc:create(callback2))
    local seq_action = CCSequence:create(seqArr)
    return seq_action
end

function acHaoshichengshuangDialog:displayGetReward(reward)
    local function touchcallback( ... )
        
    end
    if reward==nil then
        return
    end
    reward = FormatItem(reward)
    reward = reward[1]
    self.bgimage = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchcallback)
    self.bgimage:setContentSize(self.tabviewSize)
    self.descBg:addChild(self.bgimage,10)
    self.bgimage:setPosition(ccp(self.tabviewSize.width*0.5,self.tabviewSize.height*0.5))
    self.bgimage:setTouchPriority(-(self.layerNum-1)*20-5)
    local node = CCNode:create()
    self.bgimage:addChild(node)
    node:setPosition(ccp(self.bgimage:getContentSize().width*0.5,self.bgimage:getContentSize().height*0.7))

    local lighticon = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    node:addChild(lighticon)
    lighticon:setPosition(ccp(0,0))
    lighticon:runAction(CCRepeatForever:create(CCRotateBy:create(0.5,40)))
    local icon = CCSprite:createWithSpriteFrameName(reward.pic)
    node:addChild(icon)
    icon:setPosition(ccp(0,0))
    icon:setScale(100/icon:getContentSize().width)
    local function callback( ... )
        local label = GetTTFLabel(reward.name.."x"..reward.num,25)
        node:addChild(label)
        label:setPosition(ccp(0,-70))
        local function touch( ... )
            local function touchcallback1( ... )
                self:refreshRewardBox()
            end
            if self.extrareward then
                self.bgimage:removeFromParentAndCleanup(true)
                acHaoshichengshuangVoApi:updateData(self.currentStateData)
                local award = self.extrareward
                self.extrareward=nil
                award = FormatItem(award)
                self.bgimage=nil

                local content={}
                for i=1,#award do
                    table.insert(content,{award=award[i]})
                end
                smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,touchcallback1,true,true,nil,true,true,nil)
                -- smallDialog:showRewards(award,self.layerNum+1,touchcallback1)
            else
                self.bgimage:removeFromParentAndCleanup(true)
                self.bgimage=nil
                acHaoshichengshuangVoApi:updateData(self.currentStateData)
                self:refreshRewardBox()
            end
        end
        local btn = GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",touch,2,getlocal("confirm"),25)
        local menu = CCMenu:create()
        menu:addChild(btn)
        menu:setPosition(ccp(0,-150))
        node:addChild(menu)
    end
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.3, 1.3))
    arr:addObject(CCScaleTo:create(0.3, 1.1))
    arr:addObject(CCCallFunc:create(callback))
    local action2 = CCSequence:create(arr)
    node:runAction(action2)
end


function acHaoshichengshuangDialog:displayAllReward(resultList,rewardList)
    local acVo = acHaoshichengshuangVoApi:getAcVo()
    for k,v in pairs(self.boxList) do
        local image = tolua.cast(v,"CCSprite")
        image:removeAllChildrenWithCleanup(true)
        local item = acHaoshichengshuangVoApi:getRewardItem(resultList[k],true)
        local function displayReward( ... )
            image:removeAllChildrenWithCleanup(true)
            local icon = CCSprite:createWithSpriteFrameName(item.pic)
            icon:setScaleY(100/icon:getContentSize().width)
            icon:setScaleX(-100/icon:getContentSize().width)
            icon:setPosition(getCenterPoint(image))
            image:addChild(icon)
        end
        local len = k
        len = len%4==0 and 4 or len%4
        local function setDatacallback( ... )
            self.tabRewarList[k].type=1
            self.tabRewarList[k].action=false
        end
        self.tabRewarList[k].type=1
        self.tabRewarList[k].action=true
        local action = self:turnarount1(len,displayReward,setDatacallback)
        image:runAction(action)
    end
    acHaoshichengshuangVoApi:updateData(self.currentStateData)
    local function touchCallback( ... )
        acHaoshichengshuangVoApi:updateData(self.currentStateData)
        for i=1,12 do
            self.tabRewarList[i]={type=0,action=false}
        end
        self:refreshRewardBox()
    end
    local content={}
    for i=1,#rewardList do
        table.insert(content,{award=rewardList[i]})
    end

    smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,touchCallback,true,true,nil,true,true,nil)
end

function acHaoshichengshuangDialog:IsHadaction( ... )
    for k,v in pairs(self.tabRewarList)do
        if v and v.action==true then
            return true
        end
    end
    return false
end

function acHaoshichengshuangDialog:freshDialog( ... )
    self.OwnCountLabel:setString(getlocal("activity_haoshichengshuang_desc2",{acHaoshichengshuangVoApi:getownCount()}))
end

function acHaoshichengshuangDialog:updateAcTime()
    local acVo=acHaoshichengshuangVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acHaoshichengshuangDialog:tick()
    local vo=acHaoshichengshuangVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    self:updateAcTime()

    local  acVo  = acHaoshichengshuangVoApi:getAcVo()
    if acVo.currentState and acVo.currentState.begin and acVo.currentState.beginTs and acVo.currentState.begin==1 and (acVo.currentState.beginTs+acVo.reward.limitTime)>base.serverTime then
        local time = acVo.currentState.beginTs+acVo.reward.limitTime-base.serverTime
        time = time<=0 and 0 or time
        self.alertTimeLabel:setColor(G_ColorRed)
        time = GetTimeForItemStrState(time)
        self.alertTimeLabel:setString(getlocal("activity_haoshichengshuang_desc7",{time}))

    else
        self.alertTimeLabel:setColor(G_ColorYellow)
        self.alertTimeLabel:setString(getlocal("activity_haoshichengshuang_desc1",{GetTimeForItemStrState(acVo.reward.limitTime)}))
        -- if acVo.currentState.begin==1 and self.isRequiring==false and acVo.acEt>base.serverTime then
        if acVo.currentState.begin==1 and self.isRequiring==false then
            self.isRequiring=true
            local function datacallback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.haoshichengshuang and sData.data.haoshichengshuang.d then
                        local acVo = acHaoshichengshuangVoApi:getAcVo()
                        self.lastDrawIndex=0
                        if acVo.currentState.currentOpen and SizeOfTable(acVo.currentState.currentOpen)>0 then
                            self.lastDrawIndex = acVo.currentState.currentOpen[SizeOfTable(acVo.currentState.currentOpen)]
                        end
                        acHaoshichengshuangVoApi:updateData(sData.data.haoshichengshuang)
                        self:refreshRewardBox()
                        for i=1,12 do
                            self.tabRewarList[i]={type=0,action=false}
                        end
                        if self.bgimage then
                            self.bgimage:removeFromParentAndCleanup(true)
                            self.bgimage=nil
                        end
                    end
                end
                base:cancleWait()
                base:cancleNetWait()
                self.isRequiring=false
            end
            -- base:setWait()
            -- base:setNetWait()
            socketHelper:acHaoshichengshuang(1,nil,nil,datacallback)
        end
    end
    -- if acVo.acEt<base.serverTime then
    --     self.buyTenbtn:setEnabled(false)
    --     self.buyTwobtn:setEnabled(false)
    --     self.allbtn:setEnabled(false)
    -- else
    --     self.buyTenbtn:setEnabled(true)
    --     self.buyTwobtn:setEnabled(true)
    --     self.allbtn:setEnabled(true)
    -- end
end

function acHaoshichengshuangDialog:dispose()
    self.tabRewarList=nil
    self.CurrentRewardIndex=0
    self.currenAllReward=false
    self.currentInfo={}
    self.actionType=nil
    self.reloadByself=nil
     self.reloadByselfTime=0
     self.timeLb=nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acHaoshichengshuang.plist")
end