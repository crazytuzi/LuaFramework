alienMinesTroopsTab1={

}

function alienMinesTroopsTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil

    self.tanksSlotTab={}
    self.tickSlotTab={}
    self.tickSlotTab1={}
    self.tickSlotBG={}
    return nc
end

function alienMinesTroopsTab1:init(layerNum)
 	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()
	self:initTableView()

	-- if self.type~=2 then
    
 --        self.noAtkLb=GetTTFLabelWrap(getlocal("jumpToWorld"),30,CCSizeMake(500, 100),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
 --        --self.noAtkLb=GetTTFLabel(getlocal("jumpToWorld"),25);
 --        self.noAtkLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2));
 --        self.noAtkLb:setColor(ccc3(144,144,144))
 --        self.bgLayer:addChild(self.noAtkLb)
        
 --        local function sendHandler()
 --            -- parent:close()
 --            -- mainUI:changeToWorld()
 --        end
 --        self.sendBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",sendHandler,nil,getlocal("jumpButton"),25)
 --        self.sendMenu=CCMenu:createWithItem(self.sendBtn)
 --        self.sendMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-200))
 --        self.sendMenu:setTouchPriority(-(self.layerNum-1)*20-5)
 --        self.bgLayer:addChild(self.sendMenu,2)
        
 --        self.noAtkLb:setVisible(false)
 --        self.sendMenu:setVisible(false)

 --        if SizeOfTable(self.tanksSlotTab)>0 then
 --            self.noAtkLb:setVisible(false)
 --            self.sendMenu:setVisible(false)
 --        else
 --            self.noAtkLb:setVisible(true)
 --            self.sendMenu:setVisible(true)

 --        end
 --    end

	return self.bgLayer
end

function alienMinesTroopsTab1:initTableView()

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,G_VisibleSize.height-85-120),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function alienMinesTroopsTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		self.tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()
		return SizeOfTable(self.tanksSlotTab)

	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,180)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease() 

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end
		local hei=180-4
	   
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, hei))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(20,2))
		cell:addChild(backSprie)

		local nameStr;
        if self.tanksSlotTab[idx+1].type>0 and self.tanksSlotTab[idx+1].type<4 then
            nameStr=getlocal("alien_tech_res_name_"..self.tanksSlotTab[idx+1].type).." "..getlocal("lower_level").."."..self.tanksSlotTab[idx+1].level.."("..self.tanksSlotTab[idx+1].targetid[1]..","..self.tanksSlotTab[idx+1].targetid[2]..")"
            if G_getCurChoseLanguage()=="ar" then
                nameStr=" "..getlocal("lower_level").."."..self.tanksSlotTab[idx+1].level.."("..self.tanksSlotTab[idx+1].targetid[1]..","..self.tanksSlotTab[idx+1].targetid[2]..")"..getlocal("alien_tech_res_name_"..self.tanksSlotTab[idx+1].type)
            end
        else
            nameStr=self.tanksSlotTab[idx+1].tName.." "..getlocal("lower_level").."."..self.tanksSlotTab[idx+1].level;
        end
        
        local labName=GetTTFLabelWrap(nameStr,24,CCSizeMake(24*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        labName:setAnchorPoint(ccp(0,0.5));
        labName:setPosition(ccp(120,backSprie:getContentSize().height-35))
        backSprie:addChild(labName)

        -- 添加进度条标志图标
        local taiSp=CCSprite:createWithSpriteFrameName("IconUranium.png")
        backSprie:addChild(taiSp)
        taiSp:setPosition(100,backSprie:getContentSize().height/2+20)

        local pic = "alien_mines" .. self.tanksSlotTab[idx+1].type .. ".png"
        local pic2 = "alien_mines" .. self.tanksSlotTab[idx+1].type .. "_" .. self.tanksSlotTab[idx+1].type .. ".png"
        local alienSp=CCSprite:createWithSpriteFrameName(pic2)
        backSprie:addChild(alienSp)
        alienSp:setPosition(100,backSprie:getContentSize().height/2-20)
        alienSp:setScale(0.5)

		AddProgramTimer(backSprie,ccp(255,backSprie:getContentSize().height/2+20),9,12,getlocal("attckarrivade"),"TeamTravelBarBg.png","TeamTravelBar.png",11);
		local moneyTimerSprite = tolua.cast(backSprie:getChildByTag(9),"CCProgressTimer")
		self.tickSlotTab[idx+1]=moneyTimerSprite

        AddProgramTimer(backSprie,ccp(255,backSprie:getContentSize().height/2-20),10,13,getlocal("alienMines_getResource"),"TeamTravelBarBg.png","TeamTravelBar.png",11);
        local moneyTimerSprite1 = tolua.cast(backSprie:getChildByTag(10),"CCProgressTimer")
        -- moneyTimerSprite1:setPercentage(100)
        self.tickSlotTab1[idx+1]=moneyTimerSprite1

		local cellTankSlot = self.tanksSlotTab[idx+1]
		local lbPer = tolua.cast(moneyTimerSprite:getChildByTag(12),"CCLabelTTF")
        local lbPer1 = tolua.cast(moneyTimerSprite1:getChildByTag(13),"CCLabelTTF")


		local iconSp
		--情况1 采集中的时候
            if cellTankSlot.isGather==2 and cellTankSlot.bs==nil then
            
                iconSp=CCSprite:createWithSpriteFrameName(pic)
                iconSp:setTag(101)
                local nowRes,maxRes,alienNowRes,alienMaxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(self.tanksSlotTab[idx+1].slotId)

                local per=nowRes/maxRes*100
                moneyTimerSprite:setPercentage(per);
                if nowRes>=maxRes then
                   nowRes=maxRes
                end
                if alienNowRes>=alienMaxRes then
                    alienNowRes=alienMaxRes
                end

                lbPer:setString(getlocal("stayForResource",{FormatNumber(nowRes),FormatNumber(maxRes)}))

                moneyTimerSprite1:setPercentage(per)
                lbPer1:setString(getlocal("stayForResource",{FormatNumber(alienNowRes),FormatNumber(alienMaxRes)}))
                
                
                local function backTouch()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    if self.tv:getIsScrolled()==true then
                        do
                            return
                        end
                    end
                    local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(self.tanksSlotTab[idx+1].slotId)
                    if nowRes<maxRes then

                        local function backSure()

                            local function serverBack(fn,data)
                                --local retTb=OBJDEF:decode(data)

                                if base:checkServerData(data)==true then
                                	eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                                    self.tickSlotBG={}
                                    self.tickSlotTab={}
                                    self.tickSlotTab1={}
                                    self.tanksSlotTab={}
                                    self.tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()          		
                                    
                                    self.tv:reloadData()
                                else
                                    eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                                end
                             end
                            socketHelper:alienMinesTroopBack(self.tanksSlotTab[idx+1].slotId,serverBack)
                        end
                        
                        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),backSure,getlocal("dialog_title_prompt"),getlocal("fleetStaying"),nil,self.layerNum+1)
                    else

                            local function serverBack(fn,data)
                                --local retTb=OBJDEF:decode(data)
                                if base:checkServerData(data)==true then
                                	eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                                    self.tickSlotBG={}
                                    self.tickSlotTab={}
                                    self.tickSlotTab1={}
                                    self.tanksSlotTab={}
                                    self.tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()
                                    
                                    self.tv:reloadData()	
                                else
                                    eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                                end
                             end
                            socketHelper:alienMinesTroopBack(self.tanksSlotTab[idx+1].slotId,serverBack)
                    end

                    
                end
                local backItem=GetButtonItem("IconReturnBtn.png","IconReturnBtn_Down.png","IconReturnBtn.png",backTouch,nil,nil,nil)
                local backMenu=CCMenu:createWithItem(backItem);
	            backMenu:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                backMenu:setTouchPriority(-(self.layerNum-1)*20-2);
                backSprie:addChild(backMenu)
            --情况2 采集满的时候
            elseif cellTankSlot.isGather==3 and cellTankSlot.bs==nil then
                iconSp=CCSprite:createWithSpriteFrameName(pic)
                iconSp:setTag(101);
                local nowRes,maxRes,alienNowRes,alienMaxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(self.tanksSlotTab[idx+1].slotId)

                local per=100
                moneyTimerSprite:setPercentage(per);

                lbPer:setString(getlocal("stayForResource",{FormatNumber(maxRes),FormatNumber(maxRes)}))

                moneyTimerSprite1:setPercentage(per)
                lbPer1:setString(getlocal("stayForResource",{FormatNumber(alienMaxRes),FormatNumber(alienMaxRes)}))
                local function backTouch()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    local function serverBack(fn,data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data)==true then
                            self.tickSlotBG={}
                            self.tickSlotTab={}
                            self.tickSlotTab1={}
                            self.tanksSlotTab={}
                            self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                            self.tv:reloadData()
							-- enemyVoApi:deleteEnemy(self.tanksSlotTab[idx+1].targetid[1],self.tanksSlotTab[idx+1].targetid[2])
                            eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                        else
                            eventDispatcher:dispatchEvent("alienMines.mineChange",{{x=self.tanksSlotTab[idx+1].targetid[1],y=self.tanksSlotTab[idx+1].targetid[2]}})
                        end
                     end
                    socketHelper:alienMinesTroopBack(self.tanksSlotTab[idx+1].slotId,serverBack)
                    
                end
                local backItem=GetButtonItem("IconReturnBtn.png","IconReturnBtn_Down.png","IconReturnBtn.png",backTouch,nil,nil,nil)
                local backMenu=CCMenu:createWithItem(backItem);
	            backMenu:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                backMenu:setTouchPriority(-(self.layerNum-1)*20-2);
                backSprie:addChild(backMenu)
            end

            iconSp:setPosition(ccp(50,backSprie:getContentSize().height/2));
            iconSp:setScale(0.6)
            backSprie:addChild(iconSp)
            self.tickSlotBG[idx+1]=iconSp

            local function touch2()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                if self.tv:getIsScrolled()==true then
                        do
                            return
                        end
                end
                require "luascript/script/game/scene/gamedialog/warDialog/tankAttackInfoDialog"
                local tankInfo = tankAttackInfoDialog:new()
                local infoBg = tankInfo:init(self.tanksSlotTab[idx+1],self.tanksSlotTab[idx+1].troops,self.layerNum+1,true)                
            end
           
            local menuItem2 = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch2,11,nil,nil)
            local menu2 = CCMenu:createWithItem(menuItem2);
            menu2:setPosition(ccp(440,backSprie:getContentSize().height/2));
            menu2:setTouchPriority(-(self.layerNum-1)*20-2);
            backSprie:addChild(menu2,3)
		
	   return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function alienMinesTroopsTab1:tick()
    

    local isChange=false;
    self.tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()
 --    if self.type~=2 then
	--     if SizeOfTable(self.tanksSlotTab)>0 then
	--         self.noAtkLb:setVisible(false)
	--         self.sendMenu:setVisible(false)
	--     else
	--         self.noAtkLb:setVisible(true)
	--         self.sendMenu:setVisible(true)
	--     end
	-- end


    if SizeOfTable(self.tanksSlotTab)~=SizeOfTable(self.tickSlotTab) then
        
        for k,v in pairs(self.tickSlotTab) do
            v:removeFromParentAndCleanup(true)
            v=nil
        end
         self.tickSlotTab={}

        for k,v in pairs(self.tickSlotTab1) do
            v:removeFromParentAndCleanup(true)
            v=nil
        end
         self.tickSlotTab1={}
      
        self.tv:reloadData()
        do
            return
        end

    end
    
    
    for k,v in pairs(self.tickSlotTab) do
        
        if self.tanksSlotTab[k].isGather==2 and self.tanksSlotTab[k].bs==nil then
            
            if self.tickSlotBG[k]:getTag()~=101 then
                self.tickSlotBG={}
                self.tickSlotTab={}
                self.tickSlotTab1={}
                self.tanksSlotTab={}
                self.tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()
                self.tv:reloadData()
            end

            local nowRes,maxRes,alienNowRes,alienMaxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(self.tanksSlotTab[k].slotId)
            local per=nowRes/maxRes
            v:setPercentage(per*100);
     


            local totleRes=maxRes
            local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")
            if nowRes>=totleRes then
               nowRes=totleRes
            end
            lbPer:setString(getlocal("stayForResource",{FormatNumber(math.floor(nowRes)),FormatNumber(totleRes)}))

            self.tickSlotTab1[k]:setPercentage(per*100)
            if alienNowRes>=alienMaxRes then
               alienNowRes=alienMaxRes
            end 
            local lbPer1 = tolua.cast(self.tickSlotTab1[k]:getChildByTag(13),"CCLabelTTF")
            lbPer1:setString(getlocal("stayForResource",{FormatNumber(math.floor(alienNowRes)),FormatNumber(alienMaxRes)}))


            
            -- self.tickSlotTab
        elseif self.tanksSlotTab[k].isHelp~=nil and self.tanksSlotTab[k].bs==nil and self.tanksSlotTab[k].isGather~=4 and self.tanksSlotTab[k].isGather~=5 then
            if self.tickSlotBG[k]:getTag()~=104 then
                self.tickSlotBG={}
                self.tickSlotTab={}
                self.tickSlotTab1={}
                self.tanksSlotTab={}
                self.tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()
                self.tv:reloadData()
            end
            local lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotIdForAlienMines(self.tanksSlotTab[k].slotId)
            local per=(totletime-lefttime)/totletime*100
            v:setPercentage(per);
            local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")
           
            local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotIdForAlienMines(self.tanksSlotTab[k].slotId))
            lbPer:setString(getlocal("attckarrivade",{time}))

            -- if alienNowRes>=alienMaxRes then
            --    alienNowRes=alienMaxRes
            -- end 
            -- local lbPer1 = tolua.cast(self.tickSlotTab[k]:getChildByTag(13),"CCLabelTTF")
            -- lbPer1:setString(getlocal("stayForResource",{FormatNumber(math.floor(alienNowRes)),FormatNumber(alienMaxRes)}))

        elseif self.tanksSlotTab[k].isGather==3 and self.tanksSlotTab[k].bs==nil then
            if self.tickSlotBG[k]:getTag()~=101 then
                self.tickSlotBG={}
                self.tickSlotTab={}
                self.tanksSlotTab={}
                self.tickSlotTab1={}
                self.tanksSlotTab=attackTankSoltVoApi:getlienMinesTankSlots()
                self.tv:reloadData()
            end

            local nowRes,maxRes,alienNowRes,alienMaxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(self.tanksSlotTab[k].slotId)
            --local per=nowRes/maxRes
            v:setPercentage(100);


            local totleRes=maxRes
            local lbPer = tolua.cast(v:getChildByTag(12),"CCLabelTTF")
            lbPer:setString(getlocal("stayForResource",{FormatNumber(math.floor(totleRes)),FormatNumber(totleRes)}))

            self.tickSlotTab1[k]:setPercentage(100)
            if alienNowRes>=alienMaxRes then
               alienNowRes=alienMaxRes
            end 

            local lbPer1 = tolua.cast(self.tickSlotTab1[k]:getChildByTag(13),"CCLabelTTF")
            lbPer1:setString(getlocal("stayForResource",{FormatNumber(math.floor(alienMaxRes)),FormatNumber(alienMaxRes)}))
        end

        -- 异星矿产的采集
        -- local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotIdForAlienMines(self.tanksSlotTab[k].slotId)

        -- local lbPer1 = tolua.cast(self.tickSlotTab1[k]:getChildByTag(13),"CCLabelTTF")
        -- lbPer1:setString(getlocal("alienMines_getResource",{FormatNumber(math.floor(nowRes))}))

    end
end

function alienMinesTroopsTab1:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.tv=nil
end