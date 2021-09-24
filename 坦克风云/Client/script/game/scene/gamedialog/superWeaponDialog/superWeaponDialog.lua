superWeaponDialog=commonDialog:new()

-- 默认打开第几个面板
function superWeaponDialog:new(layerNum,selectedIndex)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.selectedIndex=selectedIndex
    nc.layerNum=layerNum    
    
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/localWar/localWar.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/superWeapon.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/hero/heroHonor.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/refiningImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/energyCrystal.plist")
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    return nc
end

function superWeaponDialog:initFunctionTb()
    local function callBack1()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            superWeaponVoApi:showSuperWeaponDialog(self.layerNum + 1)
        end
    end
    local function callBack21()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            
            local td=smallDialog:new()
            local tabStr = {" ",getlocal("super_weapon_info_1")," "}
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
            sceneGame:addChild(dialog,self.layerNum+1)
        end
    end

    local function callBack2()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end

            local function initChallengeCallback()
                local leftTime=0
                local cVo=superWeaponVoApi:getSWChallenge()
                if cVo then
                    if cVo.raidEndTime>0 and base.serverTime>cVo.raidEndTime then
                        local function finishCallback()
                            superWeaponVoApi:showChallengeDialog(self.layerNum+1)
                        end
                        superWeaponVoApi:raidChallengeFinish(false,finishCallback,true)
                    else
                        superWeaponVoApi:showChallengeDialog(self.layerNum+1)
                    end
                end
            end
            superWeaponVoApi:initChallenge(initChallengeCallback)
            if(otherGuideMgr.isGuiding and otherGuideMgr.curStep==6)then
              otherGuideMgr:toNextStep()
            end
        end
    end
    local function callBack22()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            
            local td=smallDialog:new()
            local tabStr = {" ",getlocal("super_weapon_info_2")," "}
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
            sceneGame:addChild(dialog,self.layerNum+1)
        end
    end

    local function callBack3()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            superWeaponVoApi:showRobDialog(self.layerNum+1)
        end
    end
    local function callBack23()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            
            local td=smallDialog:new()
            local tabStr = {" ",getlocal("super_weapon_info_3")," "}
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
            sceneGame:addChild(dialog,self.layerNum+1)
        end
    end

    local function callBack4()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            superWeaponVoApi:showEnergyCrystalDialog(self.layerNum+1)
            if(otherGuideMgr.isGuiding and otherGuideMgr.curStep==12)then
              otherGuideMgr:toNextStep()
            end
        end
    end
    local function callBack24()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            
            local td=smallDialog:new()
            local tabStr = {" ",getlocal("super_weapon_info_4")," "}
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
            sceneGame:addChild(dialog,self.layerNum+1)
        end
    end

    local challengeVo=superWeaponVoApi:getSWChallenge()
    if(challengeVo.maxClearPos==0)then
        self.functionTb={
            {icon="sw_2.png",nameKey="super_weapon_title_2",callBack=callBack2,callBack2=callBack22,type=2},
        }
    elseif(challengeVo.maxClearPos<20)then
        self.functionTb={
            {icon="sw_1.png",nameKey="super_weapon_title_1",callBack=callBack1,callBack2=callBack21,type=1},
            {icon="sw_2.png",nameKey="super_weapon_title_2",callBack=callBack2,callBack2=callBack22,type=2},
            {icon="sw_3.png",nameKey="super_weapon_title_3",callBack=callBack3,callBack2=callBack23,type=3},
        }
    else
        self.functionTb={
            {icon="sw_1.png",nameKey="super_weapon_title_1",callBack=callBack1,callBack2=callBack21,type=1},
            {icon="sw_2.png",nameKey="super_weapon_title_2",callBack=callBack2,callBack2=callBack22,type=2},
            {icon="sw_3.png",nameKey="super_weapon_title_3",callBack=callBack3,callBack2=callBack23,type=3},
            {icon="sw_4.png",nameKey="super_weapon_title_4",callBack=callBack4,callBack2=callBack24,type=4},
        }
    end
    return
end

--设置对话框里的tableView
function superWeaponDialog:initTableView()
    self.guideTb={}
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    self:initFunctionTb()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-25-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)

    self.tv:setMaxDisToBottomOrTop(120)
    if(otherGuideMgr.isGuiding and otherGuideMgr.curStep==5)then
      otherGuideMgr:toNextStep()
    end
    local challengeVo=superWeaponVoApi:getSWChallenge()
    if(challengeVo.maxClearPos==0 and otherGuideMgr.isGuiding==false)then
        if self.guideTb[6] then
          otherGuideMgr:setGuideStepField(6,self.guideTb[6],true)
        end
        if self.guideTb[12] then
          otherGuideMgr:setGuideStepField(12,self.guideTb[12],true)
        end
        otherGuideMgr:showGuide(6)
    end


    local function onDataChange(event,data)
        self:checkNotice()
    end
    self.eventListener=onDataChange
    eventDispatcher:addEventListener("superweapon.data.info",onDataChange)
    local function onBattleEnd(event,data)
        self:initFunctionTb()
        if(self.tv and tolua.cast(self.tv,"LuaCCTableView"))then
          tolua.cast(self.tv,"LuaCCTableView"):reloadData()
        end
    end
    self.eventListener2=onBattleEnd
    eventDispatcher:addEventListener("superweapon.guide.battleEnd",onBattleEnd)
    -- print("----dmj----otherGuideMgr.isGuiding:",otherGuideMgr.isGuiding)
    -- print("---dmj----self.selectedIndex:",self.selectedIndex)
    if self.selectedIndex and otherGuideMgr.isGuiding==false then
        if self.selectedIndex==1 then
        elseif self.selectedIndex==2 then
            local function initChallengeCallback()
                local leftTime=0
                local cVo=superWeaponVoApi:getSWChallenge()
                if cVo then
                    if cVo.raidEndTime>0 and base.serverTime>cVo.raidEndTime then
                        local function finishCallback()
                            superWeaponVoApi:showChallengeDialog(self.layerNum+1)
                        end
                        superWeaponVoApi:raidChallengeFinish(false,finishCallback,true)
                    else
                        superWeaponVoApi:showChallengeDialog(self.layerNum+1)
                    end
                end
            end
            superWeaponVoApi:initChallenge(initChallengeCallback)
        elseif self.selectedIndex==3 then
            
        elseif self.selectedIndex==4 then
        end
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function superWeaponDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.functionTb)
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(400,130)
         
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
       end
       
       local hei =120
       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       cell:addChild(backSprie,1)

       local mIcon=CCSprite:createWithSpriteFrameName(self.functionTb[idx+1].icon)
       mIcon:setAnchorPoint(ccp(0,0.5))
       mIcon:setPosition(ccp(10,backSprie:getContentSize().height/2))
       backSprie:addChild(mIcon)

       -- if self.functionTb[idx+1].type==4 then
       --    mIcon:setScale(10/8)
       --      local spMine=CCSprite:createWithSpriteFrameName("alien_mines3.png")
       --     spMine:setPosition(ccp(mIcon:getContentSize().width/2,mIcon:getContentSize().height/2))
       --     spMine:setScale(0.6)
       --     mIcon:addChild(spMine)
       -- end

       -- if self.functionTb[idx+1].type==6 then
       --    mIcon:setScale(10/8)
       --      local spMine=CCSprite:createWithSpriteFrameName("mainBtnFireware.png")
       --     spMine:setPosition(ccp(mIcon:getContentSize().width/2,mIcon:getContentSize().height/2))
       --     spMine:setScale(0.8)
       --     mIcon:addChild(spMine)
       -- end

       local qualityLb=GetTTFLabelWrap(getlocal(self.functionTb[idx+1].nameKey),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
       qualityLb:setAnchorPoint(ccp(0,0.5))
       qualityLb:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+15,backSprie:getContentSize().height/2))
       backSprie:addChild(qualityLb)

       -- if self.functionTb[idx+1].type==4 or self.functionTb[idx+1].type==6 then
       --   qualityLb:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width*10/8+15,backSprie:getContentSize().height-30))
       -- end

       local function callBack()
          self.functionTb[idx+1].callBack2()
       end

       local menuItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",callBack,11,nil,nil)
       local menu = CCMenu:createWithItem(menuItem);
       menu:setPosition(ccp(360,backSprie:getContentSize().height/2));
       menu:setTouchPriority(-(self.layerNum-1)*20-2);
       backSprie:addChild(menu,3);


       local function onSelectAll()
          self.functionTb[idx+1].callBack()
       end
       local selectAllItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onSelectAll,nil,getlocal("allianceWar_enter"),24/0.8,101)
       selectAllItem:setAnchorPoint(ccp(1,0.5))
       selectAllItem:setScale(0.8)
       local btnLb = selectAllItem:getChildByTag(101)
       if btnLb then
          btnLb = tolua.cast(btnLb,"CCLabelTTF")
          btnLb:setFontName("Helvetica-bold")
       end
       local selectAllBtn=CCMenu:createWithItem(selectAllItem);
       selectAllBtn:setTouchPriority(-(self.layerNum-1)*20-2);
       selectAllBtn:setPosition(ccp(backSprie:getContentSize().width-10,backSprie:getContentSize().height/2))
       backSprie:addChild(selectAllBtn)

       if self.functionTb[idx+1].nameKey=="super_weapon_title_2" then
          self.guideTb[6]=selectAllItem
        elseif self.functionTb[idx+1].nameKey=="super_weapon_title_4" then
          self.guideTb[12]=selectAllItem
       end
       
       if self.functionTb[idx+1].type==1 then
          self.equipTip = CCSprite:createWithSpriteFrameName("IconTip.png")
          self.equipTip:setPosition(ccp(selectAllItem:getContentSize().width-10,selectAllItem:getContentSize().height-10))
          self.equipTip:setVisible(false)
          selectAllItem:addChild(self.equipTip)
          self:checkNotice()
       elseif self.functionTb[idx+1].type==2 then
          self.resetTip = CCSprite:createWithSpriteFrameName("IconTip.png")
          self.resetTip:setPosition(ccp(selectAllItem:getContentSize().width-10,selectAllItem:getContentSize().height-10))
          self.resetTip:setVisible(false)
          selectAllItem:addChild(self.resetTip)
          self:checkNotice()
       elseif self.functionTb[idx+1].type==3 then
          self.energyTip = CCSprite:createWithSpriteFrameName("IconTip.png")
          self.energyTip:setPosition(ccp(selectAllItem:getContentSize().width-10,selectAllItem:getContentSize().height-10))
          self.energyTip:setVisible(false)
          selectAllItem:addChild(self.energyTip)
          self:checkNotice()
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

--用户处理特殊需求,没有可以不写此方法
function superWeaponDialog:doUserHandler()

end

function superWeaponDialog:tick()
end

--检查是否出现感叹号提醒
function superWeaponDialog:checkNotice()
    if(self.equipTip)then
        local equipNum=0
        for k,v in pairs(superWeaponVoApi:getEquipList()) do
            if(v and v~=0 and v~="0")then
                equipNum=equipNum + 1
            end
        end
        if(equipNum<6 and SizeOfTable(superWeaponVoApi:getWeaponList())>equipNum)then
            self.equipTip:setVisible(true)
        else
            self.equipTip:setVisible(false)
        end
    end
    if(self.resetTip)then
        self.resetTip:setVisible(superWeaponVoApi:getResetCost()==0)
    end
    if(self.energyTip)then
        self.energyTip:setVisible(superWeaponVoApi:setCurEnergy()>=weaponrobCfg.energyMax)
    end
end

function superWeaponDialog:dispose()
    self.equipTip=nil
    self.resetTip=nil
    self.energyTip=nil
    self.guideTb=nil
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
    -- eventDispatcher:removeEventListener("superweapon.data.info",self.eventListener)
    -- eventDispatcher:removeEventListener("superweapon.guide.battleEnd",self.eventListener2)
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/superWeapon/energyCrystal.plist")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/superWeapon/energyCrystal.pvr.ccz")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/superWeapon/superWeapon.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/superWeapon/swChallenge.plist")
    -- if G_isCompressResVersion()==true then
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.png")
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/superWeapon/superWeapon.png")
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/superWeapon/swChallenge.png")
    -- else
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.pvr.ccz")
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/superWeapon/superWeapon.pvr.ccz")
    --   CCTextureCache:sharedTextureCache():removeTextureForKey("public/superWeapon/swChallenge.pvr.ccz")
    -- end
end




