--require "luascript/script/componet/commonDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2BidDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2Tab1Dialog"
-- require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2Tab2Dialog"
-- require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar2/allianceWar2Tab3Dialog"
allianceWar2Dialog=commonDialog:new()

function allianceWar2Dialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    -- self.expandIdx={}
    self.layerNum=layerNum
    
    -- self.layerTab1=nil
    -- self.layerTab2=nil
    -- self.layerTab3=nil
    
    -- self.playerTab1=nil
    -- self.playerTab2=nil
    -- self.playerTab3=nil
    self.recordNewsIcon=nil
    self.timerSprite1=nil
    self.timerSprite2=nil
    self.timerLb1=nil
    self.timerLb2=nil
    self.getTime=0
    base.pauseSync=true
    self.statusFlag=nil
    self.callbackNum=0
    self.callbackNum1=0
    self.callbackExpiredTime=0
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
    return nc
end

--设置或修改每个Tab页签
function allianceWar2Dialog:resetTab()

   --  local index=0
   --  local tabHeight=80
   --  for k,v in pairs(self.allTabs) do
   --       local  tabBtnItem=v

   --       if index==0 then
   --       tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
   --       elseif index==1 then
   --       tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
   --       elseif index==2 then
   --       tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         
   --       local numHeight=25
			-- local iconWidth=36
			-- local iconHeight=36
	  --  	    local capInSet1 = CCRect(17, 17, 1, 1)
	  --  	    local function touchClick()
	  --  	    end
	  --       self.newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
	  --       self.newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
	  --  		self.newsIcon:ignoreAnchorPointForPosition(false)
	  --  		self.newsIcon:setAnchorPoint(CCPointMake(1,0.5))
   --      self.newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width,tabBtnItem:getContentSize().height-15))
			-- self.newsIcon:setTag(10)
	  --  		self.newsIcon:setVisible(false)
		 --    tabBtnItem:addChild(self.newsIcon)

   --       end
   --       if index==self.selectedTabIndex then
   --           tabBtnItem:setEnabled(false)
   --       end
   --       index=index+1
   --  end
    
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-260))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66-40))
    self.panelLineBg:setOpacity(0)
    -- self.bgLayer:setOpacity(0)
    self.closeBtn:setPosition(ccp(10000,0))

    self:initHeader()
    self:initFunctionBar()
end

function allianceWar2Dialog:initHeader()
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),function() end)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth,170))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
    self.bgLayer:addChild(backSprie,1)


    local bgWidth=backSprie:getContentSize().width
    local bgHeight=backSprie:getContentSize().height
    local spacey=5

    local posy=bgHeight-25
    self.endLb=GetTTFLabelWrap(getlocal("allianceWar_battleEnd"),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.endLb:setAnchorPoint(ccp(0,0.5))
    self.endLb:setPosition(20,posy)
    self.endLb:setColor(G_ColorGreen)
    backSprie:addChild(self.endLb,1)

    -- local cdTime=allianceWar2VoApi:getLeftWarTime()
    local timeStr="--:--:--"--G_getTimeStr(cdTime)
    -- AddProgramTimer(backSprie,ccp(370,posy),823,824,timeStr,"VipIconYellowBarBg.png","xpBar.png",825)
    AddProgramTimer(backSprie,ccp(370,posy),823,824,timeStr,"VipIconYellowBarBg.png","VipIconYellowBar.png",825)
    self.backSprie=backSprie

    posy=bgHeight/2+spacey
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(40, 40, 10, 10);
    local capInSetNew=CCRect(20, 20, 10, 10)
    -- local function cellClick1(hd,fn,idx)
    --     local td=warRecordDialog:new()
    --     local tbArr={getlocal("alliance_war_record_title"),getlocal("alliance_war_stats")}
    --     -- local tbSubArr={getlocal("alliance_war_personal"),getlocal("alliance_list_scene_name")}
    --     local tbSubArr={}
    --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbSubArr,nil,getlocal("alliance_war_battle_stats"),true,self.layerNum+1)
    --     sceneGame:addChild(dialog,self.layerNum+1)
    -- end
    -- local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
    -- backSprie:setContentSize(CCSizeMake(600, 70))
    -- backSprie:setAnchorPoint(ccp(0.5,0.5))
    -- backSprie:setIsSallow(false)
    -- backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
    -- backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-125))
    -- self.bgLayer:addChild(backSprie,1)

    local redIcon=CCSprite:createWithSpriteFrameName("awRedFlag.png")
    redIcon:setAnchorPoint(ccp(0,0.5))
    redIcon:setPosition(10,posy)
    backSprie:addChild(redIcon)
    
    local blueIcon=CCSprite:createWithSpriteFrameName("awBlueFlag.png")
    blueIcon:setAnchorPoint(ccp(1,0.5))
    blueIcon:setPosition(backSprie:getContentSize().width-10,posy)
    backSprie:addChild(blueIcon)
    blueIcon:setFlipX(true)
    
    local fadeOut=CCTintTo:create(0.5,130,130,130)
    local fadeIn=CCTintTo:create(0.5,255,255,255)
    local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
    local repeatForever=CCRepeatForever:create(seq)
    if allianceWar2VoApi.targetState==1 then
        redIcon:runAction(repeatForever)
    elseif allianceWar2VoApi.targetState==2 then
        blueIcon:runAction(repeatForever)
    end

    
    -- local function record()
    
    -- end
    -- local bgIconSp=LuaCCSprite:createWithSpriteFrameName("WarVS_BG.png",record)
    -- bgIconSp:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2))
    -- backSprie:addChild(bgIconSp,5)

    -- local vSp=LuaCCSprite:createWithSpriteFrameName("v.png",record)
    -- local sSp=LuaCCSprite:createWithSpriteFrameName("s.png",record)
    -- vSp:setScale(0.5)
    -- sSp:setScale(0.5)
    -- vSp:setPosition(ccp(backSprie:getContentSize().width/2-vSp:getContentSize().width/4+5,backSprie:getContentSize().height/2))
    -- sSp:setPosition(ccp(backSprie:getContentSize().width/2+sSp:getContentSize().width/4-5,backSprie:getContentSize().height/2))
    -- backSprie:addChild(vSp,6)
    -- backSprie:addChild(sSp,6)
    
    -- local fadeOut=CCTintTo:create(0.5,255,97,0)
    -- local fadeIn=CCTintTo:create(0.5,255,255,255)
    -- local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
    -- local repeatForever=CCRepeatForever:create(seq)
    -- vSp:runAction(repeatForever)
    
    -- local fadeOut=CCTintTo:create(0.5,255,97,0)
    -- local fadeIn=CCTintTo:create(0.5,255,255,255)
    -- local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
    -- local repeatForever=CCRepeatForever:create(seq)
    -- sSp:runAction(repeatForever)


    local vsSp=CCSprite:createWithSpriteFrameName("awVS.png")
    vsSp:setPosition(ccp(bgWidth/2,posy))
    backSprie:addChild(vsSp,1)
    local vsSp1=CCSprite:createWithSpriteFrameName("awVS1.png")
    vsSp1:setPosition(ccp(bgWidth/2,posy))
    backSprie:addChild(vsSp1,2)
    local fadeIn=CCFadeIn:create(0.5)
    local fadeOut=CCFadeOut:create(0.5)
    local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
    vsSp1:runAction(CCRepeatForever:create(seq))
    local lbBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    lbBg:setPosition(ccp(bgWidth/2,posy))
    backSprie:addChild(lbBg)
    local lbBg1=CCSprite:createWithSpriteFrameName("awYellowBg.png")
    lbBg1:setPosition(ccp(bgWidth/2,posy))
    backSprie:addChild(lbBg1) 

    self:addProgram(backSprie)

    local function callback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            allianceWar2VoApi:setInitFlag(1)
            allianceWar2VoApi:setCurHero(sData) 
            allianceWar2VoApi:setCurAITroops(sData) --设置当前AI部队
            allianceWar2VoApi:setCurTroopsSkin(sData)
            if self.playerTab1==nil then
                self.playerTab1=allianceWar2Tab1Dialog:new(self)
                self.layerTab1=self.playerTab1:init(self.layerNum)
                self.bgLayer:addChild(self.layerTab1);
                self.layerTab1:setPosition(ccp(0,0))
                self.layerTab1:setVisible(true)
            else

            end

            -- self.playerTab2=allianceWarTab2Dialog:new()
            -- self.layerTab2=self.playerTab2:init(self.layerNum)
            -- self.bgLayer:addChild(self.layerTab2);
            -- self.layerTab2:setPosition(ccp(10000,0))
            -- self.layerTab2:setVisible(false)

            -- self.playerTab3=allianceWarTab3Dialog:new(self)
            -- self.layerTab3=self.playerTab3:init(self.layerNum)
            -- self.bgLayer:addChild(self.layerTab3);
            -- self.layerTab3:setPosition(ccp(10000,0))
            -- self.layerTab3:setVisible(false)
            G_isShowTip=true
        end
    end
    local status
    local cityID=allianceWar2VoApi:getTargetCity()
    if cityID then
        status=allianceWar2VoApi:getStatus(cityID)
    end
    self.statusFlag=status
    if status and status==30 then
        local initFlag=nil
        if allianceWar2VoApi:getInitFlag()==-1 then
            initFlag=true
        end
        socketHelper:alliancewarnewGet(allianceWar2VoApi:getTargetCity(),initFlag,callback)
    else
        if self.playerTab1==nil then
            self.playerTab1=allianceWar2Tab1Dialog:new(self)
            self.layerTab1=self.playerTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1);
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
        end
    end
    
    

    -- local iconWidth=36
    -- local iconHeight=36
    -- local capInSet1 = CCRect(17, 17, 1, 1)
    -- local function touchClick()
    -- end
    -- self.recordNewsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
    -- self.recordNewsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
    -- self.recordNewsIcon:ignoreAnchorPointForPosition(false)
    -- self.recordNewsIcon:setAnchorPoint(CCPointMake(0.5,0.5))
    -- self.recordNewsIcon:setPosition(ccp(backSprie:getContentSize().width/2+60,backSprie:getContentSize().height-iconHeight/2))
    -- self.recordNewsIcon:setTag(111)
    -- self.recordNewsIcon:setScale(0.7)
    -- self.recordNewsIcon:setVisible(false)
    -- backSprie:addChild(self.recordNewsIcon,7)
    -- self.recordNewsIcon:setVisible(false)

    -- -- local maxNum=allianceWar2RecordVoApi:getPersonMaxNum()
    -- -- local personRecordTab=allianceWar2RecordVoApi:getPersonRecordTab()
    -- -- if maxNum and personRecordTab then
    -- --     if maxNum>0 and allianceWar2RecordVoApi:getRFlag()==-1 then
    -- --         self.recordNewsIcon:setVisible(true)
    -- --     end
    -- -- end

    -- if allianceWar2RecordVoApi:getHasNew()==true then
    --     self.recordNewsIcon:setVisible(true)
    -- end

    self:tick()
end

function allianceWar2Dialog:initFunctionBar()
    local function onBufferChange(event,data)
        self:tipSpIsVisible(data)
    end
    self.bufferChangeListener=onBufferChange
    eventDispatcher:addEventListener("allianceWar2.bufferChange",onBufferChange)



    self.functionBarHeight=112
    local function nilFunc()
    end
    local functionBarBg=LuaCCScale9Sprite:createWithSpriteFrameName("localWar_functionBarBorder.png",CCRect(20,20,10,10),nilFunc)
    functionBarBg:setTouchPriority(-(self.layerNum-1)*20-7)
    functionBarBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,self.functionBarHeight))
    functionBarBg:setAnchorPoint(ccp(0.5,0))
    functionBarBg:setPosition(ccp(G_VisibleSizeWidth/2,0))
    self.bgLayer:addChild(functionBarBg,5)

    local function close()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        
        local function onConfirm()
            self:close()
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("allianceWar2_quit_battle"),nil,self.layerNum+1)
    end
    local functionBarBg1=LuaCCScale9Sprite:createWithSpriteFrameName("localWar_functionBarBorder.png",CCRect(20,20,10,10),close)
    functionBarBg1:setTouchPriority(-(self.layerNum-1)*20-7)
    functionBarBg1:setContentSize(CCSizeMake(self.functionBarHeight+30,self.functionBarHeight))
    functionBarBg1:setAnchorPoint(ccp(1,0))
    functionBarBg1:setPosition(ccp(G_VisibleSizeWidth,0))
    self.bgLayer:addChild(functionBarBg1,5)

    local returnIcon=CCSprite:createWithSpriteFrameName("IconReturn-.png")
    returnIcon:setPosition(ccp(functionBarBg1:getContentSize().width/2,70))
    functionBarBg1:addChild(returnIcon,5)
    local backLb=GetTTFLabelWrap(getlocal("coverFleetBack"),25,CCSizeMake(self.functionBarHeight,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    backLb:setAnchorPoint(ccp(0.5,0.5))
    backLb:setColor(G_ColorYellow)
    backLb:setPosition(ccp((self.functionBarHeight+30)/2,25))
    functionBarBg1:addChild(backLb,5)

    local bgWidth=functionBarBg:getContentSize().width-functionBarBg1:getContentSize().width

    -- local functionBarCenter=CCSprite:createWithSpriteFrameName("localWar_functionBarCenter.png")
    -- functionBarCenter:setAnchorPoint(ccp(0.5,0))
    -- functionBarCenter:setPosition(ccp(G_VisibleSizeWidth/2,0))
    -- functionBarBg:addChild(functionBarCenter)

    local function onSetTroops()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        allianceWar2VoApi:showTroopsDialog(self.layerNum+1)
    end
    local setTroopsItem=GetButtonItem("mainBtnTeam.png","mainBtnTeam_Down.png","mainBtnTeam_Down.png",onSetTroops,nil,nil,nil)
    local setTroopsBtn=CCMenu:createWithItem(setTroopsItem)
    setTroopsBtn:setTouchPriority(-(self.layerNum-1)*20-8)
    setTroopsBtn:setPosition(ccp(bgWidth/8,self.functionBarHeight/2 + 10))
    functionBarBg:addChild(setTroopsBtn)
    local setTroopsLb=GetTTFLabel(getlocal("fleetInfoTitle2"),25)
    setTroopsLb:setColor(G_ColorGreen)
    setTroopsLb:setPosition(ccp(bgWidth/8,20))
    functionBarBg:addChild(setTroopsLb)
    self.troopAlert=CCSprite:createWithSpriteFrameName("IconTip.png")
    self.troopAlert:setAnchorPoint(CCPointMake(1,0.5))
    self.troopAlert:setPosition(ccp(G_VisibleSizeWidth/8 + 40,self.functionBarHeight/2 + 30))
    self.troopAlert:setTag(801)
    functionBarBg:addChild(self.troopAlert)
    self.troopAlert:setVisible(false)

    -- local function onAlliance()
    --     if G_checkClickEnable()==false then
    --         do return end
    --     else
    --         base.setWaitTime=G_getCurDeviceMillTime()
    --     end
    --     PlayEffect(audioCfg.mouseClick)

    --     -- localWarVoApi:showAllianceDialog(self.layerNum+1)
    -- end
    -- local allianceItem=GetButtonItem("mainBtnFireware.png","mainBtnFireware_Down.png","mainBtnFireware_Down.png",onAlliance,nil,nil,nil)
    -- local allianceBtn=CCMenu:createWithItem(allianceItem)
    -- allianceBtn:setTouchPriority(-(self.layerNum-1)*20-8)
    -- allianceBtn:setPosition(ccp(bgWidth/8*3,self.functionBarHeight/2 + 10))
    -- functionBarBg:addChild(allianceBtn)
    -- local allianceLb=GetTTFLabel(getlocal("alliance_list_scene_name"),25)
    -- allianceLb:setColor(G_ColorGreen)
    -- allianceLb:setPosition(ccp(bgWidth/8*3,20))
    -- functionBarBg:addChild(allianceLb)

    local function onBuff()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        -- if(base.serverTime<serverWarLocalFightVoApi:getStartTime())then
        --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarLocal_battleNotStart"),30)
        --     do return end
        -- end
        -- if(isLastBattle() and serverWarLocalFightVoApi:checkIsEnd())then
        --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_matchStatus2"),30)
        --     do return end
        -- end
        -- serverWarLocalVoApi:showBuffDialog(self.layerNum+1)
        allianceWar2VoApi:showBufferDialog(self.layerNum+1)
        -- localWarVoApi:showAllianceDialog(self.layerNum+1)
    end
    local buffItem=GetButtonItem("serverWarLocalBuff.png","serverWarLocalBuff_down.png","serverWarLocalBuff_down.png",onBuff,nil,nil,nil)
    local buffBtn=CCMenu:createWithItem(buffItem)
    buffBtn:setTouchPriority(-(self.layerNum-1)*20-8)
    buffBtn:setPosition(ccp(bgWidth/8*3,self.functionBarHeight/2 + 10))
    functionBarBg:addChild(buffBtn)
    local buffLb=GetTTFLabel(getlocal("alliance_skill"),25)
    buffLb:setColor(G_ColorGreen)
    buffLb:setPosition(ccp(bgWidth/8*3,20))
    functionBarBg:addChild(buffLb)

    self.tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
    self.tipSp:setAnchorPoint(CCPointMake(1,0.5))
    self.tipSp:setPosition(ccp(buffItem:getContentSize().width+10,buffItem:getContentSize().height-23))
    -- self.tipSp:setVisible(false)
    buffItem:addChild(self.tipSp)
    
    self:tipSpIsVisible()

    -- local allianceItem=GetButtonItem("mainBtnFireware.png","mainBtnFireware_Down.png","mainBtnFireware_Down.png",onAlliance,nil,nil,nil)
    -- local allianceBtn=CCMenu:createWithItem(allianceItem)
    -- allianceBtn:setTouchPriority(-(self.layerNum-1)*20-8)
    -- allianceBtn:setPosition(ccp(bgWidth/8*3,self.functionBarHeight/2 + 10))
    -- functionBarBg:addChild(allianceBtn)
    -- local allianceLb=GetTTFLabel(getlocal("alliance_skill"),25)
    -- allianceLb:setColor(G_ColorGreen)
    -- allianceLb:setPosition(ccp(bgWidth/8*3,20))
    -- functionBarBg:addChild(allianceLb)


    -- local function onMiniMap()
    --     if G_checkClickEnable()==false then
    --         do return end
    --     else
    --         base.setWaitTime=G_getCurDeviceMillTime()
    --     end
    --     PlayEffect(audioCfg.mouseClick)
    --     -- self:showMiniMap()
    -- end
    -- local miniMapItem=GetButtonItem("miniMapBtn.png","miniMapBtn_down.png","miniMapBtn_down.png",onMiniMap,nil,nil,nil)
    -- local miniMapBtn=CCMenu:createWithItem(miniMapItem)
    -- miniMapBtn:setTouchPriority(-(self.layerNum-1)*20-8)
    -- miniMapBtn:setPosition(ccp(G_VisibleSizeWidth/2,functionBarCenter:getContentSize().height/2))
    -- functionBarBg:addChild(miniMapBtn)

    local function onReport()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        allianceWar2VoApi:showRecordDialog(self.layerNum+1)
        -- localWarVoApi:showReportDialog(self.layerNum+1)
    end
    local reportItem=GetButtonItem("mainBtnMail.png","mainBtnMail_Down.png","mainBtnMail_Down.png",onReport,nil,nil,nil)
    local reportBtn=CCMenu:createWithItem(reportItem)
    reportBtn:setTouchPriority(-(self.layerNum-1)*20-8)
    reportBtn:setPosition(ccp(bgWidth/8*5,self.functionBarHeight/2 + 10))
    functionBarBg:addChild(reportBtn)
    local reportLb=GetTTFLabel(getlocal("allianceWar_battleReport"),25)
    reportLb:setColor(G_ColorGreen)
    reportLb:setPosition(ccp(bgWidth/8*5,20))
    functionBarBg:addChild(reportLb)
    -- self.tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
    -- self.tipSp:setAnchorPoint(CCPointMake(1,0.5))
    -- self.tipSp:setPosition(ccp(reportItem:getContentSize().width,reportItem:getContentSize().height-15))
    -- self.tipSp:setVisible(false)
    -- reportItem:addChild(self.tipSp)

    local function onGift()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        local resultcityID=allianceWar2VoApi:getTargetCity()
        local selectedCityData=allianceWar2VoApi:getCityDataByID(resultcityID)
        local type=allianceWar2Cfg.city[resultcityID].type
        allianceWar2VoApi:showRewardDialog(self.layerNum+1,selectedCityData,type)
        -- localWarVoApi:showHelpDialog(self.layerNum+1)
    end
    local giftItem=GetButtonItem("mainBtnGift.png","mainBtnGiftDown.png","mainBtnGiftDown.png",onGift,nil,nil,nil)
    local giftBtn=CCMenu:createWithItem(giftItem)
    giftBtn:setTouchPriority(-(self.layerNum-1)*20-8)
    giftBtn:setPosition(ccp(bgWidth/8*7,self.functionBarHeight/2 + 10))
    functionBarBg:addChild(giftBtn)
    local helpLb=GetTTFLabel(getlocal("local_war_help_title9"),25)
    helpLb:setColor(G_ColorGreen)
    helpLb:setPosition(ccp(bgWidth/8*7,20))
    functionBarBg:addChild(helpLb)
end

function allianceWar2Dialog:tipSpIsVisible()
    if self.tipSp then
        self.tipSp:setVisible(allianceWar2VoApi.tipFlag)
    end
end


function allianceWar2Dialog:setPoint()
    local pointTb = allianceWar2VoApi:getPoint()
    -- print("pointTb",pointTb)
    if pointTb~=nil then
        -- print("pointTb[1],pointTb[2]",pointTb[1],pointTb[2])
        local barWidth=250
        -- print("pointTb[2]",pointTb[2])
        -- print("self.timerSprite2",self.timerSprite2)
        if pointTb[1] and self.timerSprite1 then
            local scalex=barWidth/self.timerSprite1:getContentSize().width
            local point=pointTb[1]
            local per1=point/allianceWar2Cfg.winPointMax*100
            self.timerSprite1=tolua.cast(self.timerSprite1,"CCProgressTimer")
            self.timerSprite1:setPercentage(per1)
            -- self.timerLb1=tolua.cast(self.timerLb1,"CCLabelTTF")
            -- self.timerLb1:setString(pointTb[1])

            local label=self.timerSprite1:getChildByTag(1001)
            if label then
                label=tolua.cast(label,"CCLabelTTF")
                if label then
                    label:setString(point)
                end
            else
                label = GetTTFLabel(point,24)
                label:setPosition(ccp(self.timerSprite1:getContentSize().width/2,self.timerSprite1:getContentSize().height/2))
                self.timerSprite1:addChild(label,5)
                label:setTag(1001)
                label:setScaleX(1/scalex)
            end
        end
        if pointTb[2] and self.timerSprite2 then
            -- print("1~~~~~~~~~~~~~~~~~~~")
            local scalex=barWidth/self.timerSprite2:getContentSize().width
            local point=pointTb[2]
            local per2=point/allianceWar2Cfg.winPointMax*100
            self.timerSprite2=tolua.cast(self.timerSprite2,"CCProgressTimer")
            self.timerSprite2:setPercentage(per2)
            -- self.timerLb2=tolua.cast(self.timerLb2,"CCLabelTTF")
            -- self.timerLb2:setString(pointTb[2])

            local label2=self.timerSprite2:getChildByTag(1002)
            -- print("label2",label2)
            if label2 then
                label2=tolua.cast(label2,"CCLabelTTF")
                if label2 then
                    label2:setString(point)
                end
            else
                label2 = GetTTFLabel(point,24)
                label2:setPosition(ccp(self.timerSprite2:getContentSize().width/2,self.timerSprite2:getContentSize().height/2))
                self.timerSprite2:addChild(label2,5)
                label2:setTag(1002)
                label2:setScaleX(1/scalex)
            end
        end
    end
end

function allianceWar2Dialog:addProgram(backSprie)
    local spacey=5
    local barWidth=250
    local psSprite1 = CCSprite:createWithSpriteFrameName("platWarProgress1.png");
    self.timerSprite1 = CCProgressTimer:create(psSprite1);
    self.timerSprite1:setBarChangeRate(ccp(1, 0));
    self.timerSprite1:setType(kCCProgressTimerTypeBar);
    self.timerSprite1:setTag(101);
    local scalex=barWidth/self.timerSprite1:getContentSize().width
    self.timerSprite1:setScaleX(scalex)

    local rY=35
    local point1=ccp(145-10,backSprie:getContentSize().height/2-1-rY)
    local point2=ccp(150-10,backSprie:getContentSize().height/2-rY)

    self.timerSprite1:setPosition(point1);
    backSprie:addChild(self.timerSprite1, 2);
    local loadingBk = CCSprite:createWithSpriteFrameName("platWarProgressBg.png");
    loadingBk:setPosition(point2);
    loadingBk:setTag(102);
    -- psSprite1:setFlipX(true)
    -- loadingBk:setFlipX(true)
    self.timerSprite1:setMidpoint(ccp(0,1));
    backSprie:addChild(loadingBk,1);
    loadingBk:setScaleX(scalex)

    self.timerSprite1:setPercentage(0);
    
    local psSprite3 = CCSprite:createWithSpriteFrameName("platWarProgress2.png");
    self.timerSprite2 = CCProgressTimer:create(psSprite3);
    self.timerSprite2:setMidpoint(ccp(1,0));
    self.timerSprite2:setBarChangeRate(ccp(1, 0));
    self.timerSprite2:setType(kCCProgressTimerTypeBar);
    self.timerSprite2:setTag(103);
    self.timerSprite2:setScaleX(scalex)
    
    local point3=ccp(450+55,backSprie:getContentSize().height/2-1-rY)
    local point4=ccp(445+55,backSprie:getContentSize().height/2-rY)

    self.timerSprite2:setPosition(point3);
    backSprie:addChild(self.timerSprite2, 2);
    local loadingBk2 = CCSprite:createWithSpriteFrameName("platWarProgressBg.png");
    loadingBk2:setPosition(point4);
    loadingBk2:setTag(104);
    backSprie:addChild(loadingBk2,1);
    loadingBk2:setScaleX(scalex)
    
    local pointTb = allianceWar2VoApi:getPoint()
    if pointTb~=nil then
        local per1=pointTb[1]/allianceWar2Cfg.winPointMax*100
        local per2=pointTb[2]/allianceWar2Cfg.winPointMax*100
        self.timerSprite1:setPercentage(per1);
        self.timerSprite2:setPercentage(per2);
    end
    -- self.timerLb1=GetTTFLabel("",26)
    -- self.timerLb1:setAnchorPoint(ccp(0.5,0.5))
    -- self.timerLb1:setPosition(getCenterPoint(self.timerSprite1))
    -- self.timerSprite1:addChild(self.timerLb1)
    
    -- self.timerLb2=GetTTFLabel("",26)
    -- self.timerLb2:setAnchorPoint(ccp(0.5,0.5))
    -- self.timerLb2:setPosition(getCenterPoint(self.timerSprite2))
    -- self.timerSprite2:addChild(self.timerLb2)
    
    -- self.timerLb1:setString(pointTb[1])
    -- self.timerLb2:setString(pointTb[2])


    local nameTb=allianceWar2VoApi:getAllianceNameTb()
    local name1=""
    -- print("nameTb",nameTb)
    if nameTb and nameTb[1] and nameTb[1].name then
        name1=nameTb[1].name
    end
    local nameLb1=GetTTFLabel(name1,26)
    nameLb1:setAnchorPoint(ccp(0,0.5))
    nameLb1:setPosition(ccp(50,backSprie:getContentSize().height/2+spacey))
    backSprie:addChild(nameLb1, 2)

    local name2=""
    if nameTb and nameTb[2] and nameTb[2].name then
        name2=nameTb[2].name
    end
    local nameLb2=GetTTFLabel(name2,26)
    nameLb2:setAnchorPoint(ccp(1,0.5))
    nameLb2:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2+spacey))
    backSprie:addChild(nameLb2, 2)
    
    local bgPosy=22
    local blueBg=CCSprite:createWithSpriteFrameName("awBlueBg.png")
    blueBg:setPosition(ccp(point3.x,bgPosy))
    backSprie:addChild(blueBg,2)
    blueBg:setScale(0.7)
    self.bluePointLb=GetTTFLabelWrap(getlocal("allianceWar2_per_point",{0}),20,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bluePointLb:setAnchorPoint(ccp(0.5,0.5))
    self.bluePointLb:setColor(G_ColorYellow)
    self.bluePointLb:setPosition(ccp(point3.x,bgPosy))
    backSprie:addChild(self.bluePointLb,3)
    local redBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    redBg:setPosition(ccp(point1.x,bgPosy))
    backSprie:addChild(redBg,2)
    redBg:setScale(blueBg:getContentSize().width/redBg:getContentSize().width*0.7)
    self.redPointLb=GetTTFLabelWrap(getlocal("allianceWar2_per_point",{0}),20,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.redPointLb:setAnchorPoint(ccp(0.5,0.5))
    self.redPointLb:setColor(G_ColorYellow)
    self.redPointLb:setPosition(ccp(point1.x,bgPosy))
    backSprie:addChild(self.redPointLb,3)
    
    
end


--设置对话框里的tableView
function allianceWar2Dialog:initTableView()
    
    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)

    self.tv:setMaxDisToBottomOrTop(120)

    G_AllianceWarDialogTb["allianceWar2Dialog"]=self
end

-- --点击tab页签 idx:索引
-- function allianceWar2Dialog:tabClick(idx)
--         if newGuidMgr:isNewGuiding() then --新手引导
--               if newGuidMgr.curStep==39 and idx~=1 then
--                     do
--                         return
--                     end
--               end
--         end
--         PlayEffect(audioCfg.mouseClick)
        
--         for k,v in pairs(self.allTabs) do
--          if v:getTag()==idx then
--             v:setEnabled(false)
--             self.selectedTabIndex=idx
--             self:tabClickColor(idx)
--             self:doUserHandler()
--             self:getDataByType(idx)
            
--          else
--             v:setEnabled(true)
--          end
--     end
    
--     if idx==0 then
--         self.layerTab1:setVisible(true)
--         self.layerTab1:setPosition(ccp(0,0))
        
--         self.layerTab2:setVisible(false)
--         self.layerTab2:setPosition(ccp(99930,0))

--         self.layerTab3:setVisible(false)
--         self.layerTab3:setPosition(ccp(99930,0))
--     elseif idx==1 then
--         self.layerTab1:setVisible(false)
--         self.layerTab1:setPosition(ccp(10000,0))
        
--         self.layerTab2:setVisible(true)
--         self.layerTab2:setPosition(ccp(0,0))

--         self.layerTab3:setVisible(false)
--         self.layerTab3:setPosition(ccp(99930,0))
    
--     elseif idx==2 then
--         self.layerTab1:setVisible(false)
--         self.layerTab1:setPosition(ccp(99930,0))
        
--         self.layerTab2:setVisible(false)
--         self.layerTab2:setPosition(ccp(99930,0))

--         self.layerTab3:setVisible(true)
--         self.layerTab3:setPosition(ccp(0,0))
--         self.playerTab3:clearTouchSp()
--         self.playerTab3:refreshAtk()
--     end

--     self:resetForbidLayer()
-- end

--用户处理特殊需求,没有可以不写此方法
function allianceWar2Dialog:doUserHandler()

end

-- --点击了cell或cell上某个按钮
-- function allianceWar2Dialog:cellClick(idx)
--     if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
--         if self.expandIdx["k"..(idx-1000)]==nil then
--                 self.expandIdx["k"..(idx-1000)]=idx-1000
--                 self.tv:openByCellIndex(idx-1000,120)
--         else
--             self.expandIdx["k"..(idx-1000)]=nil
--             self.tv:closeByCellIndex(idx-1000,800)
--         end
--     end
-- end

function allianceWar2Dialog:tick()
    if allianceWar2VoApi:getIsShowResult()==true then
        allianceWar2VoApi:setIsShowResult(false)
        allianceWar2VoApi:showResultDialog()
    end

    local status
    local cityID=allianceWar2VoApi:getTargetCity()
    if cityID then
        status=allianceWar2VoApi:getStatus(cityID)
    end
    
    if status==nil then
        do return end
    end
    if status<20 then
        do return end
    end
    if self.callbackNum==nil then
        self.callbackNum=0
    end
    if status and status==30 and self.statusFlag~=status and self.callbackNum<5 then
        local function callback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                allianceWar2VoApi:setInitFlag(1)
                allianceWar2VoApi:setCurHero(sData) 
                allianceWar2VoApi:setCurAITroops(sData)
                allianceWar2VoApi:setCurTroopsSkin(sData)
                self.statusFlag=status
                self.callbackNum=0
                if self.playerTab1==nil then
                    self.playerTab1=allianceWar2Tab1Dialog:new(self)
                    self.layerTab1=self.playerTab1:init(self.layerNum)
                    self.bgLayer:addChild(self.layerTab1);
                    self.layerTab1:setPosition(ccp(0,0))
                    self.layerTab1:setVisible(true)
                end
            end
        end
        local initFlag=nil
        if allianceWar2VoApi:getInitFlag()==-1 then
            initFlag=true
        end
        socketHelper:alliancewarnewGet(allianceWar2VoApi:getTargetCity(),initFlag,callback)
        self.callbackNum=self.callbackNum+1
        do return end
    end

    if self.troopAlert then
        local hasSetTroops=allianceWar2VoApi:isHasSetFleet()
        if(hasSetTroops==false)then
            self.troopAlert:setVisible(true)
        else
            self.troopAlert:setVisible(false)
        end
    end

    if self and self.playerTab1 and self.playerTab1.tick then
        self.playerTab1:tick()
    end

    -- if self.endLb then
    --     if status==20 then
    --         self.endLb:setString(getlocal("serverwar_battleTime"))
    --     elseif status==30 then
    --         self.endLb:setString(getlocal("allianceWar_battleEnd"))
    --     end
    -- end

    if status<30 then
        do return end
    end

    if self.backSprie then
        local cdTime=allianceWar2VoApi:getLeftWarTime()
        if cdTime<=0 then
            cdTime=0
        end
        local timerSpriteLv = self.backSprie:getChildByTag(823)
        -- print("cdTime,per",cdTime,per)
        -- print("timerSpriteLv",timerSpriteLv)
        if timerSpriteLv then
            timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
            local lb=timerSpriteLv:getChildByTag(824)
            if lb then
                lb=tolua.cast(lb,"CCLabelTTF")
                local timeStr=G_getTimeStr(cdTime)
                lb:setString(timeStr)
            end
            -- if status==30 then
                local per=cdTime/allianceWar2Cfg.maxBattleTime*100
                timerSpriteLv:setPercentage(per)
            -- end
        end
    end

    local perPointTb=allianceWar2VoApi:getPerPoint()
    if self.redPointLb then
        if perPointTb and perPointTb[1] then
            self.redPointLb:setString(getlocal("allianceWar2_per_point",{perPointTb[1]}))
        end
    end
    if self.bluePointLb then
        if perPointTb and perPointTb[2] then
            self.bluePointLb:setString(getlocal("allianceWar2_per_point",{perPointTb[2]}))
        end
    end
    
    self:setPoint()

    if allianceWar2VoApi.targetCity then
        local targetCity=allianceWar2VoApi.targetCity
        local isInWar = allianceWar2VoApi:getStatus(targetCity)
        local pointTb = allianceWar2VoApi:getPoint()
        if allianceWar2VoApi:getIsEnd()==false then
            if (isInWar>30 or (pointTb and ((pointTb[1] and pointTb[1]>=allianceWar2Cfg.winPointMax) or (pointTb[2] and pointTb[2]>=allianceWar2Cfg.winPointMax)))) and base.serverTime>self.callbackExpiredTime and self.callbackNum1<=3 then
                local function callback()
                    if self and self.close then
                        self:close()
                    end
                end
                allianceWar2VoApi:endBattle(callback)
                self.callbackNum1=self.callbackNum1+1
                self.callbackExpiredTime=base.serverTime+5
                if self.callbackNum1==3 then
                    allianceWar2VoApi:setIsEnd(true)
                    if self and self.close then
                        self:close()
                    end
                end
            end
        end
    end

    -- self.getTime=self.getTime+1
    -- local isInWar = allianceWar2VoApi:getStatus(allianceWar2VoApi.targetCity)
    -- if self.getTime%10==0 and G_isRefreshGetpoint and (isInWar==30 or isInWar==40) then
    --     local function callback(fn,data)
    --         local cresult,retTb=base:checkServerData(data)
    --         if cresult==true then
    --             if retTb.data~=nil and retTb.data.alliancewar~=nil and retTb.data.alliancewar.isover==1 and G_isRefreshGetpoint then
    --                 self:close()
    --             end
    --         end
    --     end
    --     socketHelper:alliancewarGetwarpoint(allianceWar2VoApi:getTargetCity(),callback,false)
    -- end
    -- if self.newsIcon then
    --     if tankVoApi:checkIsIconShow() then
    --         self.newsIcon:setVisible(true)
    --     else
    --         self.newsIcon:setVisible(false)
    --     end
    -- end


    -- if self.selectedTabIndex==0 and self.playerTab1~=nil then
    --     self.playerTab1:tick()

    -- elseif self.selectedTabIndex==1 and self.playerTab2~=nil then
    --     self.playerTab2:tick()

    -- elseif self.selectedTabIndex==2 and self.playerTab3~=nil then
    --     self.playerTab3:tick()

    -- end
    
    -- if self.recordNewsIcon then
    --     if self.recordNewsIcon:isVisible()==true then
    --         self.recordNewsIcon:setVisible(false)
    --     end
    --     -- local maxNum=allianceWar2RecordVoApi:getPersonMaxNum()
    --     -- local personRecordTab=allianceWar2RecordVoApi:getPersonRecordTab()
    --     -- if maxNum and personRecordTab then
    --     --     if allianceWar2RecordVoApi:getRFlag()==-1 and  then
    --     --         self.recordNewsIcon:setVisible(true)
    --     --     end
    --     -- end
    --     if allianceWar2RecordVoApi:getHasNew()==true then
    --         self.recordNewsIcon:setVisible(true)
    --     end
    -- end

end

function allianceWar2Dialog:dispose()
    -- self.expandIdx=nil
    -- if self.playerTab1~=nil then
    --     self.playerTab1:dispose()
    -- end
    -- if self.playerTab2~=nil then
    --     self.playerTab2:dispose()
    -- end
    -- if self.playerTab3~=nil then
    --     self.playerTab3:dispose()
    -- end
    eventDispatcher:removeEventListener("allianceWar2.bufferChange",self.bufferChangeListener)
    self.recordNewsIcon=nil
    -- self.layerTab1=nil
    -- self.layerTab2=nil
    -- self.layerTab3=nil
    
    -- self.playerTab1=nil
    -- self.playerTab2=nil
    -- self.playerTab3=nil
    self.callbackNum=0
    self.callbackNum1=0
    self.callbackExpiredTime=0
    self=nil
    base.pauseSync=false
    G_isShowTip=false
    G_AllianceWarDialogTb["allianceWar2Dialog"]=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
end




