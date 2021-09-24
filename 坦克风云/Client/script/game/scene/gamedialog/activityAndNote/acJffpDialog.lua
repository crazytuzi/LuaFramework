acJffpDialog=commonDialog:new()

function acJffpDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    self.tabviewSize=nil
    self.tabRewarList=nil
    self.rowNum=3              --每行有几个物品
    self.totolNum=9            --总共有多少个物品
    self.boxList={}            --9个抽取位
    self.allReward=nil         --所有的奖励物品
    self.selectedIndex=nil     --当前选择的第几个，>0是单次抽取，0是10连抽
    self.isOpenState=false     --是否是打开的状态
    self.pokerMask=nil
    self.isPlaying=false
    self.isFirstClick=true     --是否为第一次抽取
    self.openDialog=nil
    return nc
end


--设置对话框里的tableView
function acJffpDialog:initTableView()
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
    self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    
    local function touch( ... )
      -- body
    end
    local desHe=200
    -- if G_isIphone5()==true then
    --     desHe=290
    -- end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),touch);
    self.bgLayer:addChild(descBg,4)
    descBg:setAnchorPoint(ccp(0.5,1))
    descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,desHe))
    descBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight -95))
    if G_isIphone5()==true then
        descBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight -105))
    end

    local timelabel = GetTTFLabel(getlocal("activity_timeLabel"),26)
    local timelabel1 = GetTTFLabel(acJffpVoApi:getTimeStr(),26)
    timelabel:setAnchorPoint(ccp(0.5,1))
    timelabel1:setAnchorPoint(ccp(0.5,1))
    timelabel:setHorizontalAlignment(kCCTextAlignmentCenter)
    timelabel1:setHorizontalAlignment(kCCTextAlignmentCenter)
    descBg:addChild(timelabel)
    descBg:addChild(timelabel1)
    timelabel:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height-10))
    timelabel1:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height-40))
    timelabel:setColor(G_ColorYellowPro)

    local desTv, desLabel= G_LabelTableView(CCSizeMake(descBg:getContentSize().width*0.85, 120),getlocal("activity_jffp_desc"),25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(35,descBg:getContentSize().height-180))
    desTv:setAnchorPoint(ccp(0,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(60)
    descBg:addChild(desTv)  

    -- 帮助按钮
    local function touch2(tag,object)
        PlayEffect(audioCfg.mouseClick)
      local tabStr = {}
      local tabColor = {}
      tabStr = {"\n",getlocal("activity_jffp_tip3"),"\n",getlocal("activity_jffp_tip2"),"\n",getlocal("activity_jffp_tip1"),"\n"}
      tabColor = {nil, G_ColorRed, nil,nil, nil}
      local td=smallDialog:new()
      local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
      sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItemDesc = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch2,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-30, self.bgLayer:getContentSize().height-110))
    self.bgLayer:addChild(menuDesc,5)


    self.curNumLb = GetTTFLabel(getlocal("dailyAnswer_tab1_recentLabelNum",{acJffpVoApi:getCurNum()}),26)
    self.curNumLb:setAnchorPoint(ccp(0,1))
    self.curNumLb:setPosition(ccp(25,descBg:getPositionY()-descBg:getContentSize().height-5))
    self.bgLayer:addChild(self.curNumLb)
    self.curNumLb:setColor(G_ColorYellowPro)
    local function touchCallback(tag,object)
        if tag==20 then
            self.openDialog=acJffpTaskDialog:new()
            self.vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("activity_jffp_getScore"),true,self.layerNum + 1);
            sceneGame:addChild(self.vd,self.layerNum + 1)
        elseif tag==21 then
            if self.isPlaying==true then
                return
            end
            local curScore = acJffpVoApi:getCurNum()
            local cost=acJffpVoApi:getCostNum()
            if cost>curScore then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_jffp_noenough_score"),28)
                return
            end
            local function callbackHandler(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.jffp then
                        acJffpVoApi:refreshData(sData.data.jffp) 
                        local rewarItem=sData.data.jffp.report
                        local award
                        local content={}
                        for k,v in pairs(rewarItem) do
                            award = FormatItem(v)
                            table.insert(content,{award=award[1]})
                            for k,v in pairs(award) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                            end
                        end
                        -- local award=FormatItem(sData.data.userevaluate.reward) or {}
                        -- for k,v in pairs(award) do
                        --     G_addPlayerAward(v.type,v.key,v.id,v.num)
                        -- end
                        -- G_showRewardTip(award, true)
                        self:freshDialog()
                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,touchcallback1,true,true,nil,true,true,nil)
                    end
                    
                end
            end
            socketHelper:jifenfanpai(0,callbackHandler)
        end
    end
    
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
    self.getNumBtn= GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",touchCallback,2,getlocal("activity_jffp_getScore"),25)
    self.clickTenBtn= GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",touchCallback,2,getlocal("activity_jffp_clickTen",{acJffpVoApi:getRewardNum()}),strSize2,11)
    local btnMenu = CCMenu:create()
    btnMenu:addChild(self.getNumBtn)
    btnMenu:addChild(self.clickTenBtn)
    self.getNumBtn:setTag(20)
    self.clickTenBtn:setTag(21)
    btnMenu:alignItemsHorizontallyWithPadding(50)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(btnMenu)
    btnMenu:setPosition(self.bgLayer:getContentSize().width/2, 60)

    local function touchDialog( ... )
        -- print("----dmj----touchDialog:")
        -- if self.isOpenState==true then
        --     print("----dmj----touchDialog:false")
        --     self:reloadAllPoker(false)
        -- end
    end
    local viewHight = self.curNumLb:getPositionY()-140
    local capInSet = CCRect(130, 50, 1, 1)
    self.pokerDialog = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog)
    self.pokerDialog:setContentSize(CCSizeMake(G_VisibleSizeWidth-80,self.curNumLb:getPositionY()-140))
    self.pokerDialog:setPosition(ccp(self.bgLayer:getContentSize().width/2,95))
    self.pokerDialog:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(self.pokerDialog)
    self.pokerDialog:setTouchPriority(-(self.layerNum-1)*20-2)


    self.tabviewSize = CCSizeMake(G_VisibleSizeWidth-80,viewHight-20)
    
    self:initPokerInfo()

end

function acJffpDialog:doUserHandler()
    self.tabRewarList={}
    for i=1,self.totolNum do
        self.tabRewarList[i]={type=0,action=false}
    end
end

function acJffpDialog:initPokerInfo()
    for i=1,self.totolNum do
        
        self:getRewardBgSp(i)
    end
end

function acJffpDialog:getRewardBgSp(i)
    local function callBack2()
        if self.isPlaying==true then
            return
        end
        local curScore = acJffpVoApi:getCurNum()
        local cost=acJffpVoApi:getCostNum()
        if cost>curScore then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_jffp_noenough_score"),28)
            return
        end
        local function callbackHandler(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.jffp then
                    acJffpVoApi:refreshData(sData.data.jffp) 
                    local rewarItem=FormatItem(sData.data.jffp.report[1])
                    local allRewardItem = acJffpVoApi:getAllReward(rewarItem,sData.data.action)
                    self:reloadAllPoker(true,sData.data.action,allRewardItem)
                    self:freshDialog()
                    for k,v in pairs(rewarItem) do
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end
                    -- G_showRewardTip(rewarItem, true)
                end
                
            end
        end
        socketHelper:jifenfanpai(i,callbackHandler)
    end
    local blackLabelBg = LuaCCSprite:createWithSpriteFrameName("rewardCard1.png",callBack2)
    local scale=1
    if G_isIphone5()~=true then
        scale=0.7
        blackLabelBg:setScale(scale)
    end
    blackLabelBg:setTag(i+10)
    self.boxList[i]=blackLabelBg      --记录该抽取位
    self.pokerDialog:addChild(blackLabelBg,3)
    blackLabelBg:setAnchorPoint(ccp(0.5,0.5))
    blackLabelBg:setTouchPriority(-(self.layerNum-1)*20-3)
    local pos_x = i%self.rowNum==0 and self.rowNum or i%self.rowNum
    local pos_y = 3-math.floor((i-1)/self.rowNum)
    local pos_now = ccp(self.tabviewSize.width/self.rowNum*0.5+self.tabviewSize.width/self.rowNum*(pos_x-1),self.tabviewSize.height/3*0.5+self.tabviewSize.height/3*(pos_y-1))
    if G_isIphone5()~=true then
        pos_now = ccp(self.tabviewSize.width/self.rowNum*0.5+self.tabviewSize.width/self.rowNum*(pos_x-1),self.tabviewSize.height/3*0.5+(self.tabviewSize.height-10)/3*(pos_y-1)+15)
    end
    blackLabelBg:setPosition(pos_now)
end

function acJffpDialog:reloadAllPoker(isOpen,index,allRewardItem)
    if isOpen then
        self.isOpenState=true
        self.isPlaying=true
        if self.boxList then

            local rewardItem = allRewardItem[index]
            local function setDatacallback(image)
                G_showRewardTip({rewardItem}, true)
                for k,v in pairs(self.boxList) do
                    
                    if tonumber(k)== tonumber(index) then
                          
                    else
                        rewardItem = allRewardItem[k]
                        local function endPlay(image)
                            self.isPlaying=false
                        end
                        
                        self:openPoker(v,tonumber(k),endPlay,index,rewardItem)  
                    end
                end
                self.isFirstClick=false
            end
            local image = self.boxList[index]

            self:openPoker(image,index,setDatacallback,index,rewardItem)
            local function callback( ... )
                if self.isPlaying==true then
                    return
                end
                if self.isOpenState==true then
                    self:reloadAllPoker(false)
                end
            end
            if self.pokerMask == nil then
                self.pokerMask = LuaCCScale9Sprite:createWithSpriteFrameName("smallGreen2QuadrateBg.png",CCRect(20, 20, 10, 10),callback)
                self.pokerMask:setContentSize(CCSizeMake(self.pokerDialog:getContentSize().width,self.pokerDialog:getContentSize().height))
                self.pokerMask:setPosition(ccp(self.bgLayer:getContentSize().width/2,95))
                self.pokerMask:setAnchorPoint(ccp(0.5,0))
                self.bgLayer:addChild(self.pokerMask,3)
                self.pokerMask:setTouchPriority(-(self.layerNum-1)*20-4)
                self.pokerMask:setVisible(false)
            else
                self.pokerMask:setPosition(ccp(self.bgLayer:getContentSize().width/2,95))
            end
        end
    else
        self.isOpenState=false
        self.isPlaying=true
        if self.boxList then
            for k,v in pairs(self.boxList) do
                self:closePoker(v,tonumber(k))        
            end
        end
        if self.pokerMask then
            self.pokerMask:setPosition(ccp(9999,9999))
        end
    end
end


function acJffpDialog:openPoker(image,index,setDatacallback,selectedIndex,rewardItem)
    if image then
        -- image:removeAllChildrenWithCleanup(true)
        local function displayReward( ... )
            image:removeAllChildrenWithCleanup(true)
            -- image:setFlipX(true)
            local iconBg = CCSprite:createWithSpriteFrameName("rewardCard2.png")
            iconBg:setPosition(getCenterPoint(image))
            image:addChild(iconBg,2)

            local rewardIcon = G_getItemIcon(rewardItem)
            rewardIcon:setScaleY(100/rewardIcon:getContentSize().width)
            rewardIcon:setScaleX(-100/rewardIcon:getContentSize().width)
            rewardIcon:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height-20))
            rewardIcon:setAnchorPoint(ccp(0.5,1))
            iconBg:addChild(rewardIcon)
            local numLb = GetTTFLabel("x"..rewardItem.num,26)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(rewardIcon:getContentSize().width-15,5))
            -- numLb:setPosition(ccp(rewardIcon:getPositionX()+rewardIcon:getContentSize().width/2-5,rewardIcon:getPositionY()-rewardIcon:getContentSize().height+5))
            rewardIcon:addChild(numLb)
            -- numLb:setFlipX(true)
            if rewardIcon:getContentSize().width>100 then
                numLb:setScaleY(rewardIcon:getContentSize().width/100)
                numLb:setScaleX(rewardIcon:getContentSize().width/100)
            end
            local nameLb=GetTTFLabelWrap(rewardItem.name,22,CCSizeMake(iconBg:getContentSize().width-6,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLb:setAnchorPoint(ccp(0.5,0))
            nameLb:setPosition(ccp(iconBg:getContentSize().width/2,15))
            iconBg:addChild(nameLb)
            nameLb:setFlipX(true)
            if selectedIndex~=index then
                local function callback( ... )
                    
                end
                local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("smallGreen2QuadrateBg.png",CCRect(20, 20, 10, 10),callback)
                maskSp:setContentSize(CCSizeMake(iconBg:getContentSize().width,iconBg:getContentSize().height))
                maskSp:setPosition(getCenterPoint(iconBg))
                iconBg:addChild(maskSp,3)
            else
                G_addRectFlicker(rewardIcon,1.4*(rewardIcon:getContentSize().width/100),1.4*(rewardIcon:getContentSize().width/100))
                local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                lightSp:setAnchorPoint(ccp(0.5,0.5))
                lightSp:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2))
                image:addChild(lightSp)
                lightSp:setScale(1.65)                    
            end

        end
        local function callback2( ... )
            if setDatacallback then
                setDatacallback(image)
            end
        end
        local len = index%self.rowNum==0 and self.rowNum or index%self.rowNum
        local action = self:turnarount1(len,displayReward,callback2)
        image:runAction(action)
    end
end

function acJffpDialog:closePoker(image,index)
    if image then
        local function resetflipx( ... )
            -- image:setFlipX(true);
            self.isPlaying=false
            image:removeAllChildrenWithCleanup(true)
            
            tolua.cast(self.pokerDialog:getChildByTag(index+10),"CCSprite"):removeFromParentAndCleanup(true)
            self:getRewardBgSp(index)
        end
        local function displayReward( ... )
            image:removeAllChildrenWithCleanup(true)
            self.boxList[index]:setFlipX(true)
        end
        local len = index%self.rowNum==0 and self.rowNum or index%self.rowNum
        local action = self:turnarount2(len,displayReward,resetflipx)
        image:runAction(action)
        
    end
end

function acJffpDialog:turnarount1(index,callback,resetdataCallback)    --打开动画
    local arr = {-105,-95,-85,-75}
    local delay = 0.25
    local action = CCOrbitCamera:create(delay,1,0,0,arr[index],0,0)
    local seqArr = CCArray:create()
    seqArr:addObject(action)
    seqArr:addObject(CCCallFunc:create(callback))
    -- local action2 = CCOrbitCamera:create(1,1,0,arr[index],-180,0,0)
    local action2 = CCOrbitCamera:create(delay,1,0,arr[index],-(180+arr[index]),0,0)
    seqArr:addObject(action2)
    if resetdataCallback then
        seqArr:addObject(CCCallFunc:create(resetdataCallback))
    end
    local seq_action = CCSequence:create(seqArr)
    return seq_action
end

function acJffpDialog:turnarount2(index,callback,callback2)    --打开又关闭
    local arr = {105,95,85,75}
    local delay = 0.25
    local action = CCOrbitCamera:create(delay,1,0,-180,180-arr[index],0,0)
    local seqArr = CCArray:create()
    seqArr:addObject(action)
    seqArr:addObject(CCCallFunc:create(callback))
    local action2 = CCOrbitCamera:create(delay,1,0,180-arr[index],arr[index],0,0)
    seqArr:addObject(action2)
    if callback2 then
        seqArr:addObject(CCCallFunc:create(callback2))
    end
    local seq_action = CCSequence:create(seqArr)
    return seq_action
end

function acJffpDialog:freshDialog( ... )
    self.curNumLb:setString(getlocal("dailyAnswer_tab1_recentLabelNum",{acJffpVoApi:getCurNum()}))
    local btnLabel=tolua.cast(self.clickTenBtn:getChildByTag(11),"CCLabelTTF")
    if btnLabel then
        btnLabel:setString(getlocal("activity_jffp_clickTen",{acJffpVoApi:getRewardNum()}))
    end
end

function acJffpDialog:IsHadaction( ... )
    for k,v in pairs(self.tabRewarList)do
        if v and v.action==true then
            return true
        end
    end
    return false
end

function acJffpDialog:tick()
    local vo=activityVoApi:getActivityVo("jffp")
    if vo and activityVoApi:isStart(vo)==false then
        if self.openDialog then
            self.openDialog:close()
            self.openDialog=nil
        end
        self:close()
    end
end

function acJffpDialog:dispose()
    if self.openDialog then
        self.openDialog:close()
        self.openDialog=nil
    end
    if self.pokerDialog then
        self.pokerDialog:removeAllChildrenWithCleanup(true)
        self.pokerDialog=nil
    end
    self.boxList={}     
    self.pokerMask=nil                       
    self=nil
end