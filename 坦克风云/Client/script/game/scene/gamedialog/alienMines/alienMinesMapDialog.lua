alienMinesMapDialog = commonDialog:new()

function alienMinesMapDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.touchEnable=true
	self.touchArr={}
	self.curShowBases={}
	self.mapSprites={}
	self.worldSize=CCSizeMake((2*22-1)*100,60+21*170)
    -- self.worldSize=CCSizeMake((2*21-1)*80,60+21*130)
	self.topGap=110
	self.bottomGap=180
	self.waitShowBase=false
	self.lastRefreshTime=0
	self.posTipBar1=nil
    self.tanksSlotTab={}
    self.tankSlotItemTb={}
    self.btnTipsList={}
    self.m_newsNumTab={}
     
    return nc
end

--设置或修改每个Tab页签
function alienMinesMapDialog:resetTab()

    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end

    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
   -- self.bgLayer:reorderChild(self.panelLineBg,2)
   self.panelLineBg:setVisible(false)

end

function alienMinesMapDialog:initTableView()

    

	self:showMap()

    -- 初始化上方的背景
    self:initTop()

	-- 场景下方信息条的背景框
	self:initBottom()

	-- 初始化聊天
	self:initChat()

    -- 初始化左侧按钮
    self:addLeftMenu()

    -- 添加占领掠夺次数
    self:addOccuAndRobLb()

    -- 未开启时添加朦板
    if alienMinesVoApi:checkIsActive2()==false then
        self:addMengban()
    end


end

-- 添加占领掠夺次数
function alienMinesMapDialog:addOccuAndRobLb()
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgRead.png",CCRect(20, 20, 10, 10),cellClick)
    backSprie:setContentSize(CCSizeMake(200, 100))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,1));
    backSprie:setIsSallow(true)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(0,G_VisibleSizeHeight-80))
    self.bgLayer:addChild(backSprie,13)

    
    local robLb = GetTTFLabel(getlocal("alienMines_rob",{alienMinesVoApi:getRobNum(),alienMinesVoApi:getTotalRobNum()}),25)
    robLb:setAnchorPoint(ccp(0,0.5))
    robLb:setPosition(5, G_VisibleSizeHeight-80-backSprie:getContentSize().height/2+25)
    self.bgLayer:addChild(robLb,14)
    self.robLb=robLb
    self.robNum = alienMinesVoApi:getRobNum()

    local occupyLb = GetTTFLabel(getlocal("alienMines_occupy",{alienMinesVoApi:getOccupyNum(),alienMinesVoApi:getTotalOccupyNum()}),25)
    occupyLb:setAnchorPoint(ccp(0,0.5))
    occupyLb:setPosition(5, G_VisibleSizeHeight-80-backSprie:getContentSize().height/2-5)
    self.bgLayer:addChild(occupyLb,14)
    self.occupyLb=occupyLb
    self.occupyNum=alienMinesVoApi:getOccupyNum()

    local width1 = robLb:getContentSize().width
    local width2 = occupyLb:getContentSize().width
    if width1<width2 then
        width1=width2
    end
    backSprie:setContentSize(CCSizeMake(width1+10, 100))
    backSprie:setScaleY(0.73)

end

function alienMinesMapDialog:addMengban()
    local function nilFunc()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-9)
    local rect=CCSizeMake(640,G_VisibleSizeHeight-265)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(240)
    touchDialogBg:setAnchorPoint(ccp(0,0))
    touchDialogBg:setPosition(ccp(0,185))
    self.bgLayer:addChild(touchDialogBg,10)
    self.touchDialogBg=touchDialogBg

    local titleLb=GetTTFLabelWrap(getlocal("alienMines_beginTime"),30,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(touchDialogBg:getContentSize().width/2, touchDialogBg:getContentSize().height/2+10)
    titleLb:setColor(G_ColorYellowPro)
    touchDialogBg:addChild(titleLb)
    titleLb:setTag(301)

    local beginTime,endTime = alienMinesVoApi:getBeginAndEndtime()
    local time1 = string.format("%02d:%02d",beginTime[1],beginTime[2])
    local time2 = string.format("%02d:%02d",endTime[1],endTime[2])
    local timeStr = string.format("%s~%s",time1,time2)
    local timeLb = GetTTFLabel(timeStr,30)
    timeLb:setPosition(touchDialogBg:getContentSize().width/2, touchDialogBg:getContentSize().height/2-titleLb:getContentSize().height/2-10)
    timeLb:setColor(G_ColorYellowPro)
    touchDialogBg:addChild(timeLb)
    timeLb:setTag(302)

    self:refreshCDTime()
end


function alienMinesMapDialog:addLeftMenu()

    local function pushSmallMenu(tag,object)
        PlayEffect(audioCfg.mouseClick)
        self:pushSmallMenu(tag,object)
    end

    local selectSp1 = CCSprite:createWithSpriteFrameName("mainBtnDown.png");
    local selectSp2 = CCSprite:createWithSpriteFrameName("mainBtnDown_Down.png");
    local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2);  --(90,80)

    local selectSp3 = CCSprite:createWithSpriteFrameName("mainBtnUp.png");
    local selectSp4 = CCSprite:createWithSpriteFrameName("mainBtnUp_Down.png");
    local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4);

    self.m_pointLuaSp = ccp(menuItemSp1:getContentSize().width/2,230);
    self.menuItemWidth=menuItemSp1:getContentSize().width/2
    self.m_menuToggleSmall = CCMenuItemToggle:create(menuItemSp1);
    self.m_menuToggleSmall:addSubItem(menuItemSp2)

    self.m_menuToggleSmall:registerScriptTapHandler(pushSmallMenu)

    local menuAllSmall=CCMenu:createWithItem(self.m_menuToggleSmall);
    menuAllSmall:setPosition(self.m_pointLuaSp);
    menuAllSmall:setTouchPriority(-(self.layerNum-1)*20-6);
    self.bgLayer:addChild(menuAllSmall,3)
    self.menuAllSmall=menuAllSmall

   -- 添加采集队列
   if alienMinesVoApi:checkIsActive2()==true then
         self:addTanksSlotTab()
   end

end

-- 添加采集队列
function alienMinesMapDialog:addTanksSlotTab(flag)
    self.tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()
    self.tankSlotItemTb={}
    local num = SizeOfTable(self.tanksSlotTab)
    for i=1,num do
        local x = self.tanksSlotTab[i].targetid[1]
        local y = self.tanksSlotTab[i].targetid[2]
        local alienPic = "alien_mines" .. self.tanksSlotTab[i].type .. ".png"

        local nowRes,maxRes,alienNowRes,alienMaxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(self.tanksSlotTab[i].slotId)

        local function cellClick(hd,fn,idx)
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
        backSprie:setContentSize(CCSizeMake(400, 80))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0));
        backSprie:setIsSallow(true)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-6)
        backSprie:setPosition(ccp(0,110+80*(num-i+1)))
        self.bgLayer:addChild(backSprie,1)

        local iconPic = "alien_mines" .. self.tanksSlotTab[i].type .. "_" .. self.tanksSlotTab[i].type .. ".png"
        local iconSp=CCSprite:createWithSpriteFrameName(alienPic)
        iconSp:setAnchorPoint(ccp(0,0.5))
        iconSp:setPosition(10, backSprie:getContentSize().height/2)
        backSprie:addChild(iconSp)
        iconSp:setScale(0.5)

        local corStr = "X:" .. x .. "         " .. "Y:" .. y
        local corLb = GetTTFLabel(corStr, 22)
        corLb:setPosition(200, backSprie:getContentSize().height/4*3)
        backSprie:addChild(corLb)

        local alienSp=CCSprite:createWithSpriteFrameName(iconPic)
        backSprie:addChild(alienSp)
        alienSp:setPosition(100,backSprie:getContentSize().height/4)
        alienSp:setScale(0.4)

        local alienLb = GetTTFLabel(FormatNumber(alienNowRes), 22)
        alienLb:setAnchorPoint(ccp(0,0.5))
        alienLb:setPosition(130,backSprie:getContentSize().height/4)
        backSprie:addChild(alienLb)
        alienLb:setTag(101)

        local taiSp=CCSprite:createWithSpriteFrameName("IconUranium.png")
        backSprie:addChild(taiSp)
        taiSp:setPosition(220,backSprie:getContentSize().height/4)
        taiSp:setScale(1.1)

        local taiLb = GetTTFLabel(FormatNumber(nowRes), 22)
        taiLb:setAnchorPoint(ccp(0,0.5))
        taiLb:setPosition(250,backSprie:getContentSize().height/4)
        backSprie:addChild(taiLb)
        taiLb:setTag(102)

        local function backTouch()
             if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            if nowRes<maxRes then

                local function backSure()

                    local function serverBack(fn,data)
                        if base:checkServerData(data)==true then

                            eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[i].targetid[1],y=self.tanksSlotTab[i].targetid[2]}})
                            -- self:removeTanksSlotTab()
                            -- self:addTanksSlotTab(true)
                            -- self:pushSmallMenu()
                        else
                            eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[i].targetid[1],y=self.tanksSlotTab[i].targetid[2]}})
                            
                        end
                     end
                    socketHelper:alienMinesTroopBack(self.tanksSlotTab[i].slotId,serverBack)
                end

                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),backSure,getlocal("dialog_title_prompt"),getlocal("fleetStaying"),nil,self.layerNum+1)
            else

                    local function serverBack(fn,data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data)==true then
                            eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[i].targetid[1],y=self.tanksSlotTab[i].targetid[2]}})
                            -- self:removeTanksSlotTab()
                            -- self:addTanksSlotTab(true)
                            -- self:pushSmallMenu()
                            -- local params = {uid=playerVoApi:getUid(),x=self.tanksSlotTab[i].targetid[1],y=self.tanksSlotTab[i].targetid[2]}
                            -- chatVoApi:sendUpdateMessage(21,params)
                        else
                            eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[i].targetid[1],y=self.tanksSlotTab[i].targetid[2]}})
                        end
                     end
                    socketHelper:alienMinesTroopBack(self.tanksSlotTab[i].slotId,serverBack)
            end

                    
        end

        local backItem=GetButtonItem("IconReturnBtn.png","IconReturnBtn_Down.png","IconReturnBtn.png",backTouch,nil,nil,nil)
        local backMenu=CCMenu:createWithItem(backItem);
        backMenu:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
        backMenu:setTouchPriority(-(self.layerNum-1)*20-7);
        backSprie:addChild(backMenu)
        backItem:setScale(0.8)
        table.insert(self.tankSlotItemTb,backSprie)
    end
    self.menuAllSmall:setPositionY(230+SizeOfTable(self.tanksSlotTab)*80)
    if flag then
        self.menuAllSmall:setPositionY(230)
        for k,v in pairs(self.tankSlotItemTb) do
            v:setPosition(0, 110)
        end
    end
end

-- 删除采集队列
function alienMinesMapDialog:removeTanksSlotTab()
    if self.tankSlotItemTb then
        for k,v in pairs(self.tankSlotItemTb) do
            if v then
                v:removeFromParentAndCleanup(true)
            end
        end
    end
end


function alienMinesMapDialog:pushSmallMenu()
    local point 
    if self.m_menuToggleSmall:getSelectedIndex()==1 then
        point=ccp(0,110)
    end
    if self.tankSlotItemTb then

        if self.m_menuToggleSmall:getSelectedIndex()==1 then
            for k,v in pairs(self.tankSlotItemTb) do
                local function falseVisible()
                    v:setVisible(false)
                end
                local callFunc=CCCallFunc:create(falseVisible)
                local moveTo1=CCMoveTo:create(0.1+0.02*k, ccp(point.x,point.y-5))
                local moveTo2=CCMoveTo:create(0.1, point);
                local acArr=CCArray:create()
                acArr:addObject(moveTo1)
                acArr:addObject(moveTo2)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr);
                v:runAction(seq);
                -- v:setVisible(false)
            end
            local moveTo2=CCMoveTo:create(0.1, ccp(self.menuItemWidth,230));
            self.menuAllSmall:runAction(moveTo2)
            
        elseif self.m_menuToggleSmall:getSelectedIndex()==0 then
            local num = SizeOfTable(self.tankSlotItemTb)
            for k,v in pairs(self.tankSlotItemTb) do
                local point = ccp(0,110+80*(num-k+1))
                local moveTo1=CCMoveTo:create(0.1+0.02*k, ccp(point.x,point.y-5));
                local moveTo2=CCMoveTo:create(0.3, point);
                local acArr=CCArray:create()
                acArr:addObject(moveTo1)
                acArr:addObject(moveTo2)
                local seq=CCSequence:create(acArr)
                v:runAction(seq)
                v:setVisible(true)
            end
            local moveTo2=CCMoveTo:create(0.1, ccp(self.menuItemWidth,230+num*80));
            self.menuAllSmall:runAction(moveTo2)
        end
    end
end

function alienMinesMapDialog:initTop()
    
    local function touch()
    end
    local mySpriteUp=LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_uptitle.png",CCRect(150, 20, 20, 20),touch)
    mySpriteUp:setContentSize(CCSizeMake(G_VisibleSizeWidth, 81))
    mySpriteUp:setAnchorPoint(ccp(0.5,1));
    mySpriteUp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight);
    self.bgLayer:addChild(mySpriteUp,12);
    mySpriteUp:setTouchPriority(-(self.layerNum-1)*20-5);

    self.bgLayer:reorderChild(self.closeBtn,12)
    self.bgLayer:reorderChild(self.titleLabel,12)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-6)


end

-- 初始化聊天
function alienMinesMapDialog:initChat()
    local chatBg,chatMenu=G_initChat(self.bgLayer,self.layerNum+1,true,1,13,self.mySpriteDown:getContentSize().height-5)
    chatBg:setTouchPriority(-(self.layerNum-1)*20-8)
    chatBg:setIsSallow(true)
    chatMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.chatBg=chatBg
end

function alienMinesMapDialog:initBottom()
	local function touch()
    end
	self.mySpriteDown = LuaCCSprite:createWithSpriteFrameName("alien_mines_bottom.png",touch);
    self.mySpriteDown:setAnchorPoint(ccp(0.5,0));
    self.mySpriteDown:setPosition(G_VisibleSizeWidth/2,0);
    self.bgLayer:addChild(self.mySpriteDown,2);
    self.mySpriteDown:setTouchPriority(-(self.layerNum-1)*20-5);

    -- 行军
	local function callback1()
		require "luascript/script/game/scene/gamedialog/alienMines/alienMinesTroopsDialog"
		require "luascript/script/game/scene/gamedialog/alienMines/alienMinesTroopsTab1"
		require "luascript/script/game/scene/gamedialog/alienMines/alienMinesTroopsTab2"
		local tabTb ={getlocal("alienMines_troops"),getlocal("fight_scene_repaire")}
		local td=alienMinesTroopsDialog:new()
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("fleetInfoTitle2"),true,self.layerNum+1)
		sceneGame:addChild(dialog,self.layerNum+1)
	end


	-- 战报
	local function callback2()
		require "luascript/script/game/scene/gamedialog/alienMines/alienMinesReportDialog"
		local td=alienMinesReportDialog:new()
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("email_report"),true,self.layerNum+1)
		sceneGame:addChild(dialog,self.layerNum+1)
	end

	-- 排行
	local function callback3()
		require "luascript/script/game/scene/gamedialog/alienMines/alienMinesRankDialog"
		require "luascript/script/game/scene/gamedialog/alienMines/alienMinesRankTab1"
		require "luascript/script/game/scene/gamedialog/alienMines/alienMinesRankTab2"
		local tabTb ={getlocal("alliance_war_personal"),getlocal("alliance_list_scene_name")}
		local td=alienMinesRankDialog:new()
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("mainRank"),true,self.layerNum+1)
		sceneGame:addChild(dialog,self.layerNum+1)
	end

	-- 奖励
	local function callback4()
		require "luascript/script/game/scene/gamedialog/alienMines/alienMinesRewardDialog"
        local sd=alienMinesRewardDialog:new(islandType)
        return sd:init(self.layerNum+1)
	end

	-- 帮助
	local function callback5()
        require "luascript/script/game/scene/gamedialog/alienMines/alienMinesHelpDialog"
        local sd=alienMinesHelpDialog:new(islandType)
        return sd:init(self.layerNum+1)

	end

    self.alienMenuTb={
    b1={bName1="mainBtnTeam.png",bName2="mainBtnTeam_Down.png",btnLb="alienMines_march",callback=callback1,tag=0,sortId=1},
    b2={bName1="mainBtnMail.png",bName2="mainBtnMail_Down.png",btnLb="allianceWar_battleReport",callback=callback2,tag=1,sortId=2},
    b3={bName1="mainBtnRank.png",bName2="mainBtnRank_Down.png",btnLb="alienMines_rank",callback=callback3,tag=2,sortId=3},
    b4={bName1="mainBtnGift.png",bName2="mainBtnGiftDown.png",btnLb="serverwar_help_title5",callback=callback4,tag=3,sortId=4},
    b5={bName1="mainBtnHelp.png",bName2="mainBtnHelp_Down.png",btnLb="help",callback=callback5,tag=4,sortId=5}
	    }

	self.btnList={"b1","b2","b3","b4","b5"} --要显示的按钮

    self.btnTipsList={"b1","b2"} --需要刷新tip的按钮

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(560,105),nil)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(40,10))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-7);
    self.tv:setMaxDisToBottomOrTop(100)
    self.mySpriteDown:addChild(self.tv)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function alienMinesMapDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
        local cNum=SizeOfTable(self.btnList)
        return cNum
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize = CCSizeMake(120,105)
        return  tmpSize
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()

       local function touch1()
			if self.tv:getIsScrolled()==true then
				do return end
			end
			PlayEffect(audioCfg.mouseClick)
			self.alienMenuTb[self.btnList[idx+1]].callback()
            

        end
        local select31;
        local select32;
        local menuItem3;
        local titleLb;
		
		local numHeight=25
		local newsNumLabel = GetTTFLabel("0",numHeight)
		newsNumLabel:setTag(10)
	    local capInSet = CCRect(17, 17, 1, 1)
	    local function touchClick()
	    end
		local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet,touchClick)
        newsIcon:setContentSize(CCSizeMake(36,36))
		newsIcon:ignoreAnchorPointForPosition(false)
		newsIcon:setAnchorPoint(CCPointMake(0.5,0))
        newsIcon:setPosition(ccp(65,53))
        newsIcon:addChild(newsNumLabel,1)
		newsIcon:setVisible(false)
        newsNumLabel:setPosition(ccp(newsIcon:getContentSize().width/2,newsIcon:getContentSize().height/2))

        local btnName1 = self.alienMenuTb[self.btnList[idx+1]].bName1
        local btnName2 = self.alienMenuTb[self.btnList[idx+1]].bName2
        local btnLbStr = self.alienMenuTb[self.btnList[idx+1]].btnLb

        select31 = CCSprite:createWithSpriteFrameName(btnName1);
        select32 = CCSprite:createWithSpriteFrameName(btnName2);
        titleLb=GetTTFLabel(getlocal(btnLbStr),22);

        menuItem3 = CCMenuItemSprite:create(select31,select32);
        menuItem3:setAnchorPoint(ccp(0,0));
        menuItem3:setPosition(ccp(0,0))
        
        titleLb:setPosition(ccp(menuItem3:getContentSize().width/2,-4))
        titleLb:setColor(G_ColorGreen)
        menuItem3:addChild(titleLb,6)
        menuItem3:addChild(newsIcon,6)
        menuItem3:setTag(idx+11)

        for k,v in pairs(self.btnTipsList) do
            if v==self.btnList[idx+1] then
                self.m_newsNumTab[self.btnList[idx+1]]=newsIcon
            end
        end
        -- local index=idx+1
        -- self.m_functionBtnTb[self.btnList[idx+1]]=menuItem3
        local menu3=CCMenu:createWithItem(menuItem3);
        menu3:setAnchorPoint(ccp(0,0));
        menu3:setPosition(ccp(0,18))
        menuItem3:registerScriptTapHandler(touch1)
        menu3:setTouchPriority(-(self.layerNum-1)*20-6)

        cell:addChild(menu3)
    
       return cell
   elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function alienMinesMapDialog:refreshButtonTips()
    local num=0
    for k,v in pairs(self.m_newsNumTab) do
        if k=="b1" then
            num=SizeOfTable(attackTankSoltVoApi:getlienMinesTankSlots())+SizeOfTable(tankVoApi:getRepairTanks())
        elseif k=="b2" then
            num=alienMinesEmailVoApi:getHasUnread()
        end
        if num>0 then
            v:setVisible(true)
            self:setNewsNum(num,v)
        elseif v:isVisible()==true then
            v:setVisible(false)
        end
    end

end

function alienMinesMapDialog:setNewsNum(num,newsIcon)
    local strLb=newsIcon:getChildByTag(10)
    strLb=tolua.cast(strLb,"CCLabelTTF")
    strLb:setString(num)
    local width=newsIcon:getContentSize().width
    local height=newsIcon:getContentSize().height
    if strLb:getContentSize().width+10>width then
        width=strLb:getContentSize().width+10
    end
    newsIcon:setContentSize(CCSizeMake(width,height))
    strLb:setPosition(getCenterPoint(newsIcon))
    newsIcon:setVisible(true)
end

function alienMinesMapDialog:showMap()
	self.clayer=CCLayer:create()
    self.sceneSp=CCSprite:create("scene/world_map_mi.jpg")
    self.spSize=self.sceneSp:getContentSize()
    
    self:focus(1,1)
    self.bgLayer:addChild(self.clayer,1)
    
    self.clayer:setBSwallowsTouches(false)
    self.clayer:setTouchEnabled(true)
    local function tmpHandler(...)
       return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,true)
    self.clayer:setTouchPriority(-(self.layerNum-1)*20-4)

    local function onMineChange(event,data)
        self:mineChange(data)


    end
    self.mineChangeListener=onMineChange
    eventDispatcher:addEventListener("alienMines.mineChange",onMineChange)
end

function alienMinesMapDialog:touchEvent(fn,x,y,touch)
    if fn=="began" then
        if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 then
             return 0
        end
        self.isMoved=false
        self.touchArr[touch]=touch
        local touchIndex=0
        for k,v in pairs(self.touchArr) do
            if touchIndex==0 then
                 self.firstOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
            else
                 self.secondOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
            end
            touchIndex=touchIndex+1
        end
        if touchIndex==1 then
            self.secondOldPos=nil
            self.lastTouchDownPoint=self.firstOldPos
        end
        if SizeOfTable(self.touchArr)>1 then
            self.multTouch=true
        else
            self.multTouch=false
        end
        return 1
    elseif fn=="moved" then
        if self.touchEnable==false then
             do
                return
             end
        end
        self.isMoved=true
        self.needFadeEffectPos=nil
        self.clickAreaAble=false
        if self.multTouch==false then --单点触摸
             local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
             local moveDisPos=ccpSub(curPos,self.firstOldPos)
             local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
              if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<3 then
                 self.clickAreaAble=true
                 self.isMoved=false
                 do
                    return
                 end
             end
             self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,(curPos.y-self.firstOldPos.y)*3)

             local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),moveDisPos)
             self.clayer:setPosition(tmpPos)
             self.firstOldPos=curPos
             self.isMoving=true
             self:getNeedShowSps()
             self:checkBound()
             if self.posTipBar1==nil or self.posTipBar1.status==0 then
                self.posTipBar1=tipDialog:showTipsBar(self.bgLayer,ccp(320,G_VisibleSizeHeight+26),ccp(320,G_VisibleSizeHeight-26-90),"",80,5,false)
             end
             local screenCenterPosInClayer=self.clayer:convertToNodeSpace(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
             local pxPos,indexPos=self:getNearPiexlPoint(screenCenterPosInClayer)
             local centerRealPos=ccp(screenCenterPosInClayer.x,self.worldSize.height-screenCenterPosInClayer.y)
             local pPos=ccp(math.floor((centerRealPos.x+100)/200),math.floor((centerRealPos.y-60)/170))
             local tipLb=tolua.cast(self.posTipBar1.lable,"CCLabelTTF")
             if tipLb~=nil then
                 tipLb:setString(pPos.x..","..pPos.y)
             end
            -- mainUI:worldLandMove(pPos)
        end
    elseif fn=="ended" then
       if self.touchEnable==false then
             do
                return
             end
       end
       if self.isMoved==true then
         self.waitShowBase=true
         self.lastRefreshTime=G_getCurDeviceMillTime()
       end
       self:checkRemoveBase()
       self:checkIfHide()

       if self.touchArr[touch]~=nil then
           self.touchArr[touch]=nil
           local touchIndex=0
            for k,v in pairs(self.touchArr) do
                if touchIndex==0 then
                     self.firstOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                else
                     self.secondOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
                end
                touchIndex=touchIndex+1
            end
            if touchIndex==1 then
                self.secondOldPos=nil
            end
            if SizeOfTable(self.touchArr)>1 then
                self.multTouch=true
            else
                self.multTouch=false
            end
       end
       if  self.isMoving==true then
            self.isMoving=false
            local tmpToPos=ccpAdd(ccp(self.clayer:getPosition()),self.autoMoveAddPos)
            tmpToPos=self:checkBound(tmpToPos)

            local ccmoveTo=CCMoveTo:create(0.15,tmpToPos)
            local cceaseOut=CCEaseOut:create(ccmoveTo,3)
            local function callBack()
                self:getNeedShowSps()
            end
            local callFunc=CCCallFunc:create(callBack)
            local arr=CCArray:create()
            arr:addObject(cceaseOut)
            arr:addObject(callFunc)
            local seq=CCSequence:create(arr)


            self.clayer:runAction(seq)
            
       else --地图没有移动过
            deviceHelper:luaPrint("=========*******"..tostring(self.clickAreaAble))
            if self.clickAreaAble==true then
                 --self.firstOldPos
                 PlayEffect(audioCfg.mouseClick)
                 local mapPos=self.clayer:convertToNodeSpace(self.firstOldPos)
                 local realPoint=ccp(mapPos.x,self.worldSize.height-mapPos.y)
                 -- local piexlPoint,pt=self:getNearPiexlPoint(realPoint)
                 if piexlPoint~=nil then
                    -- if  worldBaseVoApi:getBaseVo(pt.x,pt.y)==nil then
                    --     self:showSelectedArea(piexlPoint.x,piexlPoint.y,pt.x,pt.y)
                    -- end
                 end
            end
       end
    else
        self.touchArr=nil
        self.touchArr={}
    end
end

function alienMinesMapDialog:checkRemoveBase()
    local fourPoints=self:get4Points()
    local inScreen=false
    for k,v in pairs(self.curShowBases) do
        inScreen=false

        for kk,vv in pairs(fourPoints) do
                if k==(vv.x*1000+vv.y) then --移除掉出了显示屏的基地图片
                      inScreen=true
                end
        end
        
        if inScreen==false then
                      for kk,vv in pairs(v) do
                        if vv then
                          vv:removeFromParentAndCleanup(true)
                        end
                          vv=nil
                      end
                      self.curShowBases[k]=nil
        end
    end
end

function alienMinesMapDialog:getNeedShowSps()
   local screenCenterPosInClayer=self.clayer:convertToNodeSpace(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
   local xIndex=math.floor(screenCenterPosInClayer.x/self.spSize.width)+1
   local yIndex=math.floor(screenCenterPosInClayer.y/self.spSize.height)+1
   local inTableIndex 

   local needShowIndexs={}  --所有需要加载地图图片的格子
   for xv=xIndex-1,xIndex+1 do  --这个循环只限制了最小值没有限制最大值
       if xv>=1 then
           for yv=yIndex-3,yIndex+3 do
                if yv>=0 then
                     inTableIndex=xv*10000+yv
                     needShowIndexs[inTableIndex]={xv,yv}
                end
           end
       end
   end

   for k,v in pairs(needShowIndexs) do
        if self.mapSprites[k]==nil then --加载地图并显示
                local tmpSp=CCSprite:create("scene/world_map_mi.jpg")
                tmpSp:setAnchorPoint(ccp(0,0))
                tmpSp:setPosition((v[1]-1)*self.spSize.width,(v[2]-1)*self.spSize.height)
                self.clayer:addChild(tmpSp)
                self.mapSprites[k]=tmpSp
        end
   end
   
   local needRemoveSp={}
   for k,v in pairs(self.mapSprites) do
        if needShowIndexs[k]==nil then --需要移除掉了
             table.insert(needRemoveSp,k)
        end
   end
   
   for k,v in pairs(needRemoveSp) do
    if self.mapSprites[v] then
        self.mapSprites[v]:removeFromParentAndCleanup(true)
    end
       
       self.mapSprites[v]=nil
   end
   needRemoveSp=nil

   
end

function alienMinesMapDialog:checkBound(pos)    
    local clayerPos
    if pos==nil then
        clayerPos=ccp(self.clayer:getPosition())
    else
        clayerPos=pos
    end
    if clayerPos.x>0 then
         clayerPos.x=0
    end
    
    if clayerPos.x<(G_VisibleSize.width-self.worldSize.width) then
        clayerPos.x=G_VisibleSize.width-self.worldSize.width
    end
    
    if clayerPos.y<(G_VisibleSize.height-(self.worldSize.height+self.topGap)) then
        clayerPos.y=G_VisibleSize.height-(self.worldSize.height+self.topGap)
    end
    
    if clayerPos.y>self.bottomGap then
         clayerPos.y=self.bottomGap
    end
    if pos==nil then
        self.clayer:setPosition(clayerPos)
    else
        return clayerPos
    end
end

function alienMinesMapDialog:getNearPiexlPoint(point)
    if point.y<=160 then
        point.y=160
    end
    if point.y>=60060 then
        point.y=60060
    end

    if point.x<80 then
        point.x=80
    end
    
    if point.x>95920 then
        point.x=95920
    end

    local cpmin=ccp(math.floor((point.x+100)/200),math.floor((point.y-60)/170))  --基地坐标，不是像素坐标
    local cpmax=ccp(math.ceil((point.x+100)/200),math.ceil((point.y-60)/170))
    local cpmin_p=self:toPiexl(cpmin) --转像素坐标
    local cpmax_p=self:toPiexl(cpmax) --转像素坐标
    
    local resultX
    local resultY
    if math.abs(cpmin_p.x-point.x)>math.abs(cpmax_p.x-point.x) then
        resultX=cpmax.x
    else
        resultX=cpmin.x
    end
    
    if math.abs(cpmin_p.y-point.y)>math.abs(cpmax_p.y-point.y) then
        resultY=cpmax.y
    else
        resultY=cpmin.y
    end
    local resultPiexl=self:toPiexl(ccp(resultX,resultY))
    local areaX=math.ceil(resultPiexl.x/1000)
    local areaY=math.ceil(resultPiexl.y/1000)
    -- if worldBaseVoApi.allBaseByArea[areaX*1000+areaY]==nil then
    --     do
    --         return nil,nil
    --     end
    -- end

    -- if worldBaseVoApi.allBaseByArea[areaX*1000+areaY][resultX*1000+resultY]~=nil then
    --         do
    --             return nil,nil
    --         end
    -- else
    --         do
                return  resultPiexl,ccp(resultX,resultY)
    --         end
    -- end
end

function alienMinesMapDialog:focus(x,y,flag,islandData)
    local cPoint=self:toPiexl(ccp(x,y))
    x=cPoint.x
    y=cPoint.y
    
    local xPos=G_VisibleSize.width/2-x
    local yPos=y+G_VisibleSize.height/2-self.worldSize.height
 	
 	if flag then
 		local pos = self:checkBound(ccp(xPos,yPos))
        self.clayerPos = pos
        local spWorldPos,layerMovePos=self:getSpWorldPos(islandData)
        local time=math.sqrt(layerMovePos.x*layerMovePos.x+layerMovePos.y*layerMovePos.y)/400
 		local moveTo = CCMoveTo:create(time,pos)
 		self.clayer:runAction(moveTo)
 		

	else
 		 self.clayer:setPosition(ccp(xPos,yPos))
 		 self.clayerPos = ccp(xPos,yPos)
 	end
   

    self:getNeedShowSps()
    self:checkBound()
    self.waitShowBase=true
end

function alienMinesMapDialog:toPiexl(point)
    return ccp((2*point.x-1)*100+100,60+170*point.y)
end

--将像素坐标转换为区域坐标
function alienMinesMapDialog:getAreaPos(x,y)
    x=math.ceil(x/1000)
    y=math.ceil((self.worldSize.height-y)/1000)
    if x<=0 then
        x=1
    end
    if y<=0 then
        y=1
    end
    return x,y
end


function alienMinesMapDialog:tick()
    if alienMinesVoApi:checkIsMonday()==true then
        self:close()
        return
    end


     if self.lastRefreshTime==0 then
     end
    -- 移动刷新
	 if self.waitShowBase==true then
        -- if self.lastRefreshTime==0 then
        --     self.lastRefreshTime=G_getCurDeviceMillTime()
        -- end
        if self.lastRefreshTime==0 or (G_getCurDeviceMillTime()-self.lastRefreshTime)>=1000 then
                 self.waitShowBase=false
                 
                 self.lastRefreshTime=G_getCurDeviceMillTime()
                 if self.posTipBar1~=nil and self.posTipBar1.status==1 then
                     self.posTipBar1:close()
                     self.posTipBar1=nil
                 end
                self:showBase(true)
        end
    end

    -- 从后台到前台的刷新
    if alienMinesVoApi:getrefreshFlag()==true then
       
        alienMinesVoApi:setrefreshFlag(false)
        self:showBase(true)
    end

    local tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()
    if tanksSlotTab and self.tanksSlotTab and SizeOfTable(tanksSlotTab)~=SizeOfTable(self.tanksSlotTab) then
        -- 刷新显示队列
        self:removeTanksSlotTab()
        self:addTanksSlotTab(true)
        self:pushSmallMenu()
    end

    -- 刷新资源数量
    if self.tanksSlotTab then

        local num=SizeOfTable(self.tanksSlotTab)
        if self.tankSlotItemTb then

            for k,v in pairs(self.tankSlotItemTb) do

                local vo = attackTankSoltVoApi:getSlotIdBytargetid(self.tanksSlotTab[k].targetid[1],self.tanksSlotTab[k].targetid[2])
                if vo then
                    local nowRes,maxRes,alienNowRes,alienMaxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(self.tanksSlotTab[k].slotId)

                    local alienLb = tolua.cast(v:getChildByTag(101),"CCLabelTTF")
                    alienLb:setString(FormatNumber(math.floor(alienNowRes)))

                    local taiLb = tolua.cast(v:getChildByTag(102),"CCLabelTTF")
                    taiLb:setString(FormatNumber(math.floor(nowRes)))
                end
            end
        end
    end

    -- 如果不在开启时间范围拉回所有部队
    self:CheckIsActive()

    -- 添加或者删除朦板
    if alienMinesVoApi:checkIsActive2()==false then
        if self.touchDialogBg==nil then
             self:addMengban()
        end
    else
        if self.touchDialogBg then
            self.touchDialogBg:removeFromParentAndCleanup(true)
            self.touchDialogBg=nil
        end
    end
    self:refreshCDTime()

    -- 去除保护罩
    if alienMinesVoApi:checkIsActive2()==true then
        self:removeProtect()  
    end
   

    if self.chatBg then
        G_setLastChat(self.chatBg,false,1,13)
    end

    -- 刷新掠夺和占领次数
    if self.robNum and self.robNum~=alienMinesVoApi:getRobNum() then
        self.robNum=alienMinesVoApi:getRobNum()
        if self.robLb then
            self.robLb:setString(getlocal("alienMines_rob",{alienMinesVoApi:getRobNum(),alienMinesVoApi:getTotalRobNum()}))
        end
    end

    if self.occupyNum and self.occupyNum~=alienMinesVoApi:getOccupyNum() then
        self.occupyNum=alienMinesVoApi:getOccupyNum()
        if self.occupyLb then
            self.occupyLb:setString(getlocal("alienMines_occupy",{alienMinesVoApi:getOccupyNum(),alienMinesVoApi:getTotalOccupyNum()}))
        end
    end

    -- 刷新tip
    self:refreshButtonTips()
    -- alienMinesEmailVoApi:getHasUnread()

end

-- 去除保护罩
function alienMinesMapDialog:removeProtect()
    -- 去除保护罩
    if self.tanksSlotTab and SizeOfTable(self.tanksSlotTab)~=0 then
        for k,v in pairs(self.tanksSlotTab) do
            local x = self.tanksSlotTab[k].targetid[1]
            local y = self.tanksSlotTab[k].targetid[2]
            local vo = alienMinesVoApi:getBaseVo(x,y)
            if vo then
                if vo.ptEndTime<base.serverTime then
                    for kk,vv in pairs(self.curShowBases) do
                         local baseSp=vv[vo.x*1000+vo.y]
                         if baseSp then
                             local sp = tolua.cast(baseSp:getChildByTag(111),"CCSprite")
                             if sp then
                                sp:removeFromParentAndCleanup(true)
                                local params = {uid=playerVoApi:getUid(),x=vo.x,y=vo.y,isProtect=true}
                            chatVoApi:sendUpdateMessage(21,params)
                             end
                         end
                    end
                end
            end
        end
    end
end




function alienMinesMapDialog:CheckIsActive()
    if alienMinesVoApi:checkIsActive6()==true and SizeOfTable(attackTankSoltVoApi:getlienMinesTankSlots())~=0 then
        local function callback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret==true then 
                if self.tanksSlotTab then
                    for k,v in pairs(self.tanksSlotTab) do
                        if self.tanksSlotTab[k] then
                            eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[k].targetid[1],y=self.tanksSlotTab[k].targetid[2]}})
                            -- 发聊天
                            -- local params = {uid=playerVoApi:getUid(),x=self.tanksSlotTab[k].targetid[1],y=self.tanksSlotTab[k].targetid[2]}
                            -- chatVoApi:sendUpdateMessage(21,params)
                        end
                    end
                end
            else
                eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[k].targetid[1],y=self.tanksSlotTab[k].targetid[2]}})

            end
        end
        socketHelper:alienMinesTroopBackAll(callback)
    end
end

function alienMinesMapDialog:show()
	-- base:cancleWait()
	self.bgLayer:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)


   local moveTo=CCMoveTo:create(0,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
   local function callBack()
       if self and self.isCloseing==false then
            if portScene.clayer~=nil then
                if sceneController.curIndex==0 then
                    portScene:setHide()
                elseif sceneController.curIndex==1 then
                    mainLandScene:setHide()
                elseif sceneController.curIndex==2 then
                    worldScene:setHide()
                end

                mainUI:setHide()
            end
       end
       base:cancleWait()
   end
   base.allShowedCommonDialog=base.allShowedCommonDialog+1
   table.insert(base.commonDialogOpened_WeakTb,self)
   local callFunc=CCCallFunc:create(callBack)
   local seq=CCSequence:createWithTwoActions(moveTo,callFunc)
   self.bgLayer:runAction(seq)
end

function alienMinesMapDialog:showBase(needSendRequest)
    local areaTb={}
    local centerScenePoint=self.clayer:convertToNodeSpace(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
    local fourPoints=self:get4Points()
        for k,v in pairs(fourPoints) do
        if areaTb[v.x*1000+v.y]==nil and self.curShowBases[v.x*1000+v.y]==nil then  --没有显示在地图上的，已经显示的不再进行处理
             areaTb[v.x*1000+v.y]=v.x*1000+v.y
        end
    end
    
    local needShowInMapTb={}
    local needRequestFromServer={}
    -- local function checkNeedSend(areaIndex)
    --     local  minX,maxX,minY,maxY=self:getMinAndMaxXYByAreaID(areaIndex)
    --     for x=minX,maxX do
    --         for y=minY,maxY do
    --             local vo=alienMinesVoApi:getBaseVo(x,y)
    --             if(vo==nil)then
    --                 -- print("+++++++++++++++++++1")
    --                 print("x,y+++",x,y)
    --                 return true
    --             end
    --         end
    --     end
    --     return false
    -- end
    for k,v in pairs(areaTb) do
        -- local needRequest=checkNeedSend(v)
         local tmpTb=alienMinesVoApi:getBasesByArea(k)
         if((tmpTb==nil or SizeOfTable(tmpTb)<2) and needSendRequest==true)then
         --if self.hasGetDataFromServer[k]==nil then
             
             needRequestFromServer[k]=v  --需要请求服务器获取数据
         else
             needShowInMapTb[k]=tmpTb
         end
    end
    self:realShowBase(needShowInMapTb)
    if needSendRequest==true then
            if SizeOfTable(needRequestFromServer)>0 then
                --发送网络请求
                local retMinX,retMinY,retMaxX,retMaxY=9999,9999,0,0
                for k,v in pairs(needRequestFromServer) do
                    local  minX,maxX,minY,maxY=self:getMinAndMaxXYByAreaID(v)
                    if retMinX>minX then
                        retMinX=minX
                    end
                    if retMinY>minY then
                        retMinY=minY
                    end
                    if maxX>retMaxX then
                        retMaxX=maxX
                    end
                    if maxY>retMaxY then
                        retMaxY=maxY
                    end
                end
                local function serverResponseHandler(fn,data)
                        local retStr,retTb=base:checkServerData(data,false)
                        -- local retTb=OBJDEF:decode(data)
                        if retTb.msg~="Success" then
                             do
                                
                                return false
                             end
                        end
                            if(base.fsaok==1)then
                                if(type(retTb.data.map)=="string")then
                                    local decodeData=G_decodeMap2(retTb.data.map,retTb.data.faker)
                                    if type(decodeData)=="string" then
                                        retTb.data.map = G_Json.decode(decodeData)
                                    end
                                end
                            end

                              for k,v in pairs(retTb.data.map) do
                                     --[[
                                     local ttppoint=self:toPiexl(ccp(tonumber(v[2]),tonumber(v[3])))
                                     local ttareaX=math.ceil(ttppoint.x/1000)
                                     local ttareaY=math.ceil(ttppoint.y/1000)
                                     if self.hasGetDataFromServer[ttareaX*1000+ttareaY]==nil then
                                            self.hasGetDataFromServer[ttareaX*1000+ttareaY]=1
                                     end
                                     ]]
                                alienMinesVoApi:add(tonumber(v[1]),tonumber(v[7]),v[8],tonumber(v[4]),tonumber(v[5]),tonumber(v[2]),tonumber(v[3]),tonumber(v[10]),tonumber(v[9]),tonumber(v[11]),tonumber(v[12]),v[13],tonumber(v[14]),tonumber(v[15]))
                              end
                              self:showBase(false)
                              self:checkRemoveBase()
                              self.clickAreaAble=true
                              
                end
                base:setNetWait()
                -- serverResponseHandler()
                socketHelper:getAlienMinesMap(retMinX,retMinY,retMaxX,retMaxY,serverResponseHandler)
            else --不需要请求服务器
                self.clickAreaAble=true
            end
    end
end

function alienMinesMapDialog:realShowBase(dataTb,isMoveBase)
    for k,v in pairs(dataTb) do
         if self.curShowBases[k]==nil then
             self.curShowBases[k]={}
         end
               for kk,vv in pairs(v) do
                     if self.curShowBases[k][vv.x*1000+vv.y]==nil then
                                 local function baseClick()
                                        if self.touchEnable==false then
                                            return
                                        end
                                        if G_checkClickEnable()==false then
                                            do
                                                return
                                            end
                                        end
                                        
                                        if self.isMoved==false then
                                             base.setWaitTime=G_getCurDeviceMillTime()
                                             PlayEffect(audioCfg.mouseClick)
                                            -- if(base.landFormOpen==1)then
                                                self:clickIslandHandler(vv)
                                            -- else
                                          
                                                -- self:clickIslandHandlerOld(vv)
                                            -- end
                                        end
                                 end

                                 local baseSp=LuaCCSprite:createWithSpriteFrameName("alien_mines"..vv.type..".png",baseClick)
                                 if vv.type==6 then
                                    baseSp:setScale(0.8)
                                 end
                                 baseSp:setAnchorPoint(ccp(0.5,0.5))
                                 local toLayerPoint=self:toPiexl(ccp(vv.x,vv.y))
                                 local realPoint=ccp(toLayerPoint.x,self.worldSize.height-toLayerPoint.y)
                                 baseSp:setTouchPriority(-(self.layerNum-1)*20-4)
                                 baseSp:setIsSallow(false)
                                 baseSp:setPosition(realPoint)
                                 self.clayer:addChild(baseSp,10+vv.y,vv.x*1000+vv.y)
                                 if self.curShowBases[k]==nil then
                                     self.curShowBases[k]={}
                                 end
                                 self.curShowBases[k][vv.x*1000+vv.y]=baseSp
                                 --table.insert(self.curShowBases[k],baseSp)
                                      
                                       
                                   self:baseShowLvTip(baseSp,vv)


                     end
               end
         
    end
    self:checkIfHide()
end

function alienMinesMapDialog:checkIfHide()
     local winPos=ccp(0,0)
    for k,v in pairs(self.curShowBases) do
    
        for kk,vv in pairs(v) do
                winPos=self.clayer:convertToWorldSpace(ccp(vv:getPosition()))
                if winPos.x>=-100 and winPos.x<=700 and winPos.y>-100 and winPos.y<G_VisibleSizeHeight+60 then
                      vv:setVisible(true)
                else
                      vv:setVisible(false)  
                end
        end
    end

end

function alienMinesMapDialog:baseShowLvTip(baseSp,vv)
    -- 显示保护罩
    local showProtectSp=false

    if vv.ptEndTime>base.serverTime then
        showProtectSp=true
    end

    if showProtectSp==true then
       local protectedSp=CCSprite:createWithSpriteFrameName("ShieldingShape.png")
       protectedSp:setAnchorPoint(ccp(0.5,0.5))
       protectedSp:setPosition(ccp(baseSp:getContentSize().width/2,baseSp:getContentSize().height/2))
       baseSp:addChild(protectedSp)
       protectedSp:setTag(111)
       protectedSp:setScale(1.5)
    end           

    -- if baseSp:getChildByTag(101)~=nil then
    --     tolua.cast(baseSp:getChildByTag(101),"CCSprite"):removeFromParentAndCleanup(true)
    -- end
   
    local lvTip 

    lvTip=CCSprite:createWithSpriteFrameName("IconLevel.png")

    local lvLb=GetTTFLabel(vv.level,25)

    lvLb:setPosition(ccp(lvTip:getContentSize().width/2,lvTip:getContentSize().height/2))

    lvTip:setScale(0.7)
    lvTip:addChild(lvLb)
    lvTip:setAnchorPoint(ccp(0.5,0.5))
    lvTip:setPosition(ccp(baseSp:getContentSize().width/2-5,baseSp:getContentSize().height))
    baseSp:addChild(lvTip,5)
    lvTip:setTag(101)

    -- vv.oid=playerVoApi:getUid()
    local addH=15
    local baseWidth=baseSp:getContentSize().width/2
    if vv.oid==playerVoApi:getUid() then
        -- print("+++++++++++++自己")
        local nameStr = playerVoApi:getPlayerName()
        local nameLb = GetTTFLabel(nameStr, 22)

        local function click()
        end
        local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png", CCRect(15,8,153,28),click)
        barSprie:setContentSize(CCSizeMake(nameLb:getContentSize().width+20, nameLb:getContentSize().height+10))
        barSprie:setPosition(ccp(baseSp:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
        baseSp:addChild(barSprie)

        barSprie:addChild(nameLb)
        nameLb:setPosition(barSprie:getContentSize().width/2, barSprie:getContentSize().height/2)

        local alliance =  allianceVoApi:getSelfAlliance()
        local allianceSp
        if alliance==nil or SizeOfTable(alliance)==0 then
            barSprie:setAnchorPoint(ccp(0.5,0.5))
        else
            barSprie:setAnchorPoint(ccp(0.5,0.5))
            barSprie:setPositionX(baseSp:getContentSize().width/2+5)
            if base.isAf == 1 then
                local defaultSelect = allianceVoApi:getFlagIconTab(alliance.banner)
                allianceSp = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.2)
                allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2 - 20,-barSprie:getContentSize().height/2+addH-5))
            else
                allianceSp=CCSprite:createWithSpriteFrameName("ArmyGroupIcon.png")
                allianceSp:setAnchorPoint(ccp(1,0.5))
                allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
            end
            baseSp:addChild(allianceSp)
        end

    else
       
        if vv.name==nil or vv.name==""  then
            -- print("+++++++++++++++空地")
        else
            local alliance =  allianceVoApi:getSelfAlliance()

            local nameStr = vv.name
            local nameLb = GetTTFLabel(nameStr, 22)

            local function click()
            end

            local barSprie
            if alliance and vv.allianceName and alliance.name==vv.allianceName then
                barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_allybg.png", CCRect(15,8,153,28),click)
            else
                barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("alien_mines_enemybg.png", CCRect(15,8,153,28),click)
            end
            barSprie:setContentSize(CCSizeMake(nameLb:getContentSize().width+20, nameLb:getContentSize().height+10))
            barSprie:setPosition(ccp(baseSp:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
            baseSp:addChild(barSprie)

            barSprie:addChild(nameLb)
            nameLb:setPosition(barSprie:getContentSize().width/2, barSprie:getContentSize().height/2)

            barSprie:setAnchorPoint(ccp(0.5,0.5))
            
            if alliance==nil or SizeOfTable(alliance)==0 then
                -- if vv.allianceName~=nil and vv.allianceName~="" then
                    barSprie:setPositionX(baseSp:getContentSize().width/2+5)
                    local allianceSp=CCSprite:createWithSpriteFrameName("alien_mines_enemy.png")
                    allianceSp:setAnchorPoint(ccp(1,0.5))
                    allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
                    baseSp:addChild(allianceSp)
                -- end
            else
                -- if vv.allianceName==nil or vv.allianceName=="" then
                -- else
                    local allianceSp
                    barSprie:setPositionX(baseSp:getContentSize().width/2+5)
                    if vv.allianceName==alliance.name then
                        if base.isAf == 1 then
                            local defaultSelect = allianceVoApi:getFlagIconTab(alliance.banner)
                            allianceSp = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.2)
                            allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2 - 20,-barSprie:getContentSize().height/2+addH - 5))
                        else
                            allianceSp=CCSprite:createWithSpriteFrameName("ArmyGroupIcon.png") 
                            allianceSp:setAnchorPoint(ccp(1,0.5))
                            allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
                        end
                    else
                        allianceSp=CCSprite:createWithSpriteFrameName("alien_mines_enemy.png")
                        allianceSp:setAnchorPoint(ccp(1,0.5))
                        allianceSp:setPosition(ccp(baseWidth-barSprie:getContentSize().width/2,-barSprie:getContentSize().height/2+addH))
                    end
                    -- allianceSp:setAnchorPoint(ccp(1,0.5))
                    baseSp:addChild(allianceSp)
                -- end
            end
        end
    end


end

function alienMinesMapDialog:get4Points()
        local centerScenePoint=self.clayer:convertToNodeSpace(ccp(G_VisibleSize.width/2,G_VisibleSize.height/2))
    local fourPoints={}
    local x,y=self:getAreaPos(centerScenePoint.x-G_VisibleSize.width/2,centerScenePoint.y+((G_VisibleSize.height/2)>480 and 480 or (G_VisibleSize.height/2)))    --左上角
    fourPoints[1]=ccp(x,y)
    x,y=self:getAreaPos(centerScenePoint.x-G_VisibleSize.width/2,centerScenePoint.y-((G_VisibleSize.height/2)>480 and 480 or (G_VisibleSize.height/2)))    --左下角
    fourPoints[2]=ccp(x,y)
    
    x,y=self:getAreaPos(centerScenePoint.x+G_VisibleSize.width/2,centerScenePoint.y+((G_VisibleSize.height/2)>480 and 480 or (G_VisibleSize.height/2)))    --右上角
    fourPoints[3]=ccp(x,y)
    
    x,y=self:getAreaPos(centerScenePoint.x+G_VisibleSize.width/2,centerScenePoint.y-((G_VisibleSize.height/2)>480 and 480 or (G_VisibleSize.height/2)))    --右下角
    fourPoints[4]=ccp(x,y)
    --[[
    if G_isIphone5()==true then
         x,y=self:getAreaPos(centerScenePoint.x,centerScenePoint.y)    --中心点
         fourPoints[5]=ccp(x,y)
    end
    ]]
    return fourPoints
end

function alienMinesMapDialog:getMinAndMaxXYByAreaID(areaID)
     
    local x,y=math.floor(areaID/1000),areaID%1000
    
    local pMinX,pMinY,pMaxX,pMaxY=(x-1)*1000,(y-1)*1000,x*1000,y*1000
    
    local minX,maxX,minY,maxY=math.ceil((pMinX+100)/200),math.floor((pMaxX+100)/200),math.ceil((pMinY-60)/170),math.floor((pMaxY-60)/170)
    
    if (pMaxX+100)%200==0 then  --一个区域取最小的 不取最大的（边界问题）
        maxX=maxX-1
    end
    
    if (pMaxY-60)%170==0 then   --一个区域取最小的 不取最大的（边界问题）
        maxY=maxY-1
    end
    
    return minX,maxX,minY,maxY
end

function alienMinesMapDialog:getSpWorldPos(islandData)
	local sp=tolua.cast(self.clayer:getChildByTag(islandData.x*1000+islandData.y),"LuaCCSprite")
	local spPos = ccp(sp:getPositionX(),sp:getPositionY())
	local spWorldPos = ccp(sp:getPositionX()+self.clayerPos.x,sp:getPositionY()+self.clayerPos.y)
    local layerMovePos = ccp(self.clayerPos.x-self.clayer:getPositionX(),self.clayerPos.y-self.clayer:getPositionY())
	return spWorldPos,layerMovePos
end

function alienMinesMapDialog:clickIslandHandler(islandData)

    if self.touchArr and SizeOfTable(self.touchArr)>=2 then
        return
    end
	self:focus(islandData.x,islandData.y,true,islandData)
	local spWorldPos,layerMovePos=self:getSpWorldPos(islandData)
    local idx
    if self.m_menuToggleSmall then
         idx = self.m_menuToggleSmall:getSelectedIndex()
         self.m_menuToggleSmall:setSelectedIndex(1)
         self:pushSmallMenu() 
    end
   
	local island=islandData
    --param myType: 面板类型, 1是自己占领, 2是友军占领, 3是敌军占领,4是空地
	local myType = self:getType(islandData)
    require "luascript/script/game/scene/gamedialog/alienMines/alienMinesSmallDialog"
    local sd
    if idx and idx==0 then
        sd=alienMinesSmallDialog:new(myType,island,self,true)
    else
        sd=alienMinesSmallDialog:new(myType,island,self)
    end
    return sd:init(self.layerNum+1,spWorldPos,layerMovePos)
end

function alienMinesMapDialog:getType(islandData)
    local myType
    if islandData.oid==playerVoApi:getUid() then
        myType=1
    else
        if islandData.name==nil or islandData.name=="" then
            myType=4
        else
            if allianceVoApi:isSameAlliance(islandData.allianceName) then
                myType=2
            else
                 myType=3
            end

        end
    end
    return myType
end

function alienMinesMapDialog:clickIslandHandlerOld(islandData)
end

function alienMinesMapDialog:mineChange(data)
    for k,v in pairs(data) do
        if v.isProtect~=true then
            if v.vv then
                for kk,pp in pairs(self.curShowBases) do
                     local baseSp=pp[v.x*1000+v.y]
                     if baseSp then
                        local function baseClick()
                            if self.touchEnable==false then
                                return
                            end
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            end
                            
                             base.setWaitTime=G_getCurDeviceMillTime()
                             PlayEffect(audioCfg.mouseClick)
                             self:clickIslandHandler(v.vv)
                        end
                        baseSp:removeFromParentAndCleanup(true)

                        -- baseSp:removeAllChildrenWithCleanup(true)
                        local baseSp=LuaCCSprite:createWithSpriteFrameName("alien_mines"..v.vv.type..".png",baseClick)
                         baseSp:setAnchorPoint(ccp(0.5,0.5))
                         local toLayerPoint=self:toPiexl(ccp(v.x,v.y))
                         local realPoint=ccp(toLayerPoint.x,self.worldSize.height-toLayerPoint.y)
                         baseSp:setTouchPriority(-(self.layerNum-1)*20-4)
                         baseSp:setIsSallow(false)
                         baseSp:setPosition(realPoint)

                         self.clayer:addChild(baseSp,10+v.y,v.x*1000+v.y)
                         if self.curShowBases[kk]==nil then
                             self.curShowBases[kk]={}
                         end
                         self.curShowBases[kk][v.x*1000+v.y]=baseSp
                         self:baseShowLvTip(baseSp,v.vv)
                         alienMinesVoApi:setBaseVoByXY(v.x,v.y,v.vv)
                         -- print("++++++++++++",v.x,v.x,v.vv)
                            -- 刷新显示队列
                        -- self:removeTanksSlotTab()
                        -- self:addTanksSlotTab(true)
                        -- self:pushSmallMenu()
                     end
                end
            else
                 self:refreshBaseSp(v.x,v.y)
            end
        else
            -- 去除保护罩
            for kk,pp in pairs(self.curShowBases) do
                 local baseSp=pp[v.x*1000+v.y]
                 if baseSp then
                     local sp = tolua.cast(baseSp:getChildByTag(111),"CCSprite")
                     if sp then
                        sp:removeFromParentAndCleanup(true)
                     end
                 end
            end
        
        end
       
    end

end

-- 刷新x,y坐标的baseSp
function alienMinesMapDialog:refreshBaseSp(x,y)
    local curShowBasesK
    for kk,vv in pairs(self.curShowBases) do
         local baseSp=vv[x*1000+y]
         if baseSp then
            -- baseSp:removeFromParentAndCleanup(true)
            -- baseSp:removeAllChildrenWithCleanup(true)
            curShowBasesK=kk
            break
         end
    end

    -- 坐标vo置空
   

    local function serverResponseHandler(fn,data)
        local retStr,retTb=base:checkServerData(data,false)
        local retTb=OBJDEF:decode(data)
        if retTb.msg~="Success" then
             do
                
                return false
             end
        end
            if(base.fsaok==1)then

                 if(type(retTb.data.map)=="string")then
                    local decodeData=G_decodeMap2(retTb.data.map,retTb.data.faker)
                    if type(decodeData)=="string" then
                        retTb.data.map=G_Json.decode(decodeData)
                    end
                 end
            end
              for k,v in pairs(retTb.data.map) do
                    alienMinesVoApi:setBaseVo(x,y)
                    alienMinesVoApi:add(tonumber(v[1]),tonumber(v[7]),v[8],tonumber(v[4]),tonumber(v[5]),tonumber(v[2]),tonumber(v[3]),tonumber(v[10]),tonumber(v[9]),tonumber(v[11]),tonumber(v[12]),v[13],tonumber(v[14]),tonumber(v[15]))
                end
             
               local vv=alienMinesVoApi:getBaseVo(x,y)

                local params = {uid=playerVoApi:getUid(),vv=vv}
                chatVoApi:sendUpdateMessage(21,params)

               local function baseClick()
                    if self.touchEnable==false then
                        return
                    end
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    end
                    

                     base.setWaitTime=G_getCurDeviceMillTime()
                     PlayEffect(audioCfg.mouseClick)
                     self:clickIslandHandler(vv)
                end
           

             local baseSp
             if curShowBasesK then
                baseSp =self.curShowBases[curShowBasesK][x*1000+y]
             end
            
             if baseSp then
                baseSp:removeFromParentAndCleanup(true)

                baseSp=LuaCCSprite:createWithSpriteFrameName("alien_mines"..vv.type..".png",baseClick)
                 baseSp:setAnchorPoint(ccp(0.5,0.5))
                 local toLayerPoint=self:toPiexl(ccp(vv.x,vv.y))
                 local realPoint=ccp(toLayerPoint.x,self.worldSize.height-toLayerPoint.y)
                 baseSp:setTouchPriority(-(self.layerNum-1)*20-4)
                 baseSp:setIsSallow(false)
                 baseSp:setPosition(realPoint)

                 self.clayer:addChild(baseSp,10+vv.y,vv.x*1000+vv.y)

                
                 if self.curShowBases[curShowBasesK]==nil then
                     self.curShowBases[curShowBasesK]={}
                 end
                 self.curShowBases[curShowBasesK][vv.x*1000+vv.y]=baseSp
                 self:baseShowLvTip(baseSp,vv)
                -- self:baseShowLvTip(baseSp,vv)
            end
                  -- 刷新显示队列
                -- self:removeTanksSlotTab()
                -- self:addTanksSlotTab(true)
                -- self:pushSmallMenu()

                              
        end
        base:setNetWait()
        socketHelper:getAlienMinesMap(x,y,x,y,serverResponseHandler)
end

function alienMinesMapDialog:refreshCDTime()
    if G_isGlobalServer()==true and self.touchDialogBg then
        if alienMinesVoApi:checkIsActive()==true then
            local beginTime,endTime = alienMinesVoApi:getBeginAndEndtime()
            local zeroTime=G_getWeeTs(base.serverTime)
            local dayTime=base.serverTime-zeroTime
            local st=beginTime[1]*3600+beginTime[2]*60
            local et=endTime[1]*3600+endTime[2]*60
            local titleLb=tolua.cast(self.touchDialogBg:getChildByTag(301),"CCLabelTTF")
            local timeLb=tolua.cast(self.touchDialogBg:getChildByTag(302),"CCLabelTTF")
            if dayTime<=st then
                if titleLb then
                    titleLb:setString(getlocal("alienMines_begin_cd"))
                end
                if timeLb then
                    timeLb:setString(G_formatActiveDate(st-dayTime))
                end
            elseif dayTime>=et then
                if titleLb then
                    titleLb:setString(getlocal("allianceWar_battleEnd"))
                end
                if timeLb then
                    timeLb:setString(G_formatActiveDate(86400-dayTime))
                end
            end
        end
    end
end

function alienMinesMapDialog:close(hasAnim)
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
    if newGuidMgr:isNewGuiding() and (newGuidMgr.curStep==9 or newGuidMgr.curStep==46 or newGuidMgr.curStep==17 or newGuidMgr.curStep==35 or newGuidMgr.curStep==41) then --新手引导
            newGuidMgr:toNextStep()
    end
    local function realClose()
        return self:realClose()
    end
    -- if base.allShowedCommonDialog==0 and storyScene.isShowed==false then
    if base.allShowedCommonDialog==0 and storyScene.isShowed==false and battleScene.isBattleing==false then
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
   local time=0
   if newGuidMgr.curStep==16 then
      time=0;
   end
   self.bgLayer:setPosition(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height)
   local fc= CCCallFunc:create(realClose)
   local moveTo=CCMoveTo:create((hasAnim==true and time or 0),CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
   local acArr=CCArray:create()
   acArr:addObject(moveTo)
   acArr:addObject(fc)
   local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)
end

function alienMinesMapDialog:dispose()
    eventDispatcher:removeEventListener("alienMines.mineChange",self.mineChangeListener)
	 if self.posTipBar1~=nil and self.posTipBar1.status==1 then
         self.posTipBar1:realClose()
         self.posTipBar1=nil
     end
	self.touchEnable=true
	self.touchArr={}
	self.curShowBases={}
	self.mapSprites={}
	self.worldSize=CCSizeMake((2*22-1)*100,60+21*170)
	self.topGap=110
	self.bottomGap=180
	self.waitShowBase=false
	self.lastRefreshTime=0
    tanksSlotTab={}
    tankSlotItemTb={} 
    self.robNum=nil
    self.occupyNum=nil
    self.robLb=nil
    self.occupyLb=nil
    self.m_newsNumTab=nil
end