--require "luascript/script/componet/commonDialog"
isLandStateDialog=commonDialog:new()

function isLandStateDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.islandStateTab={}
    self.expandHeight=G_VisibleSize.height-140
    self.normalHeight=130
    self.extendSpTag=113
    self.headTab={}
    self.protectLabel=nil
    self.itemSoltTab={}
    self.timeLbTab={}
    self.timeLbTab2={}
    self.callbackNum=0
    self.protectResource=0
    self.helpDialog=nil
    return nc
end

--设置或修改每个Tab页签
function isLandStateDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
             tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
             --self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66+5))
             --self.panelLineBg:setContentSize(CCSizeMake(600,770))
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
    v:setVisible(false)
    v:setEnabled(false)
         index=index+1
    end
end

--设置对话框里的tableView
function isLandStateDialog:initTableView()
    spriteController:addPlist("public/datebaseShow.plist")
    spriteController:addTexture("public/datebaseShow.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/resource_youhua.plist")
    spriteController:addTexture("public/resource_youhua.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acItemBg.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local function showInfo()
      if G_checkClickEnable()==false then
        do
            return
        end
      end
      self:showHelpDialog()
    end
    local menuItem=GetButtonItem("monthlyBg.png","monthlyBg_Down.png","monthlyBg_Down.png",showInfo,11,nil,nil,nil,CCRect(50,50,1,1),CCSizeMake(G_VisibleSize.width-32,100))
    menuItem:setScaleY(70/menuItem:getContentSize().height)
    -- menuItem:setAnchorPoint(ccp(0,0.5))
    local menu=CCMenu:createWithItem(menuItem)
    menu:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height-120))
    menu:setTouchPriority(-45)
    self.bgLayer:addChild(menu)

    -- local spcSp=CCSprite:createWithSpriteFrameName("buy_light_0.png")
    -- local spcArr=CCArray:create()
    -- for kk=0,11 do
    --     local nameStr="buy_light_"..kk..".png"
    --     local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
    --     spcArr:addObject(frame)
    -- end
    -- local animation=CCAnimation:createWithSpriteFrames(spcArr)
    -- animation:setDelayPerUnit(0.08)
    -- local animate=CCAnimate:create(animation)
    -- spcSp:setScaleX((G_VisibleSize.width-50)/spcSp:getContentSize().width)
    -- spcSp:setScaleY(64/spcSp:getContentSize().height)
    -- spcSp:setPosition(getCenterPoint(menuItem))
    -- menuItem:addChild(spcSp)
    -- local delayAction=CCDelayTime:create(1)
    -- local seq=CCSequence:createWithTwoActions(animate,delayAction)
    -- local repeatForever=CCRepeatForever:create(seq)
    -- spcSp:runAction(repeatForever)

    -- local menuSize=menuItem:getContentSize()
    -- local clipper=CCClippingNode:create()
    -- clipper:setAnchorPoint(ccp(0,0.5))
    -- clipper:setContentSize(CCSizeMake(menuSize.width-15,menuSize.height))
    -- clipper:setPosition(ccp(3,menuSize.height/2))
    -- local stencil=CCDrawNode:getAPolygon(clipper:getContentSize(),1,1)
    -- clipper:setStencil(stencil)
    -- menuItem:addChild(clipper,1)

    -- self:showAnimation(clipper,menuSize.width-40,menuSize.height)

    self.protectResource=buildingVoApi:getProtectResource()
    local protectStr=FormatNumber(self.protectResource)
    self.protectLabel=GetTTFLabelWrap(getlocal("resource_protected_tip",{protectStr}),22,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
    -- self.protectLabel:setAnchorPoint(ccp(0,0.5))
    self.protectLabel:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height-120))
    self.bgLayer:addChild(self.protectLabel,3)

    self.tvWidth,self.tvHeight=self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-130
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.bgLayer:setTouchPriority(-41)
    self.tv:setTableViewTouchPriority(-43)
    self.tv:setPosition(ccp(30,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    self.islandStateTab=shopVoApi:getIslandState()

    self.itemSoltTab=useItemSlotVoApi:getAllSlots();

    if newGuidMgr:isNewGuiding() then
      if self.guideItem then
        local stepId=newGuidCfg[newGuidMgr.curStep].toStepId
        if stepId then
          newGuidMgr:setGuideStepField(stepId,self.guideItem,true)
        end
      end
      local btnScale=0.8
      local btnWidth,btnHeight=205*btnScale,71*btnScale
      local x,y=G_VisibleSize.width-120-btnWidth/2,G_VisibleSizeHeight-190-300-self.normalHeight-btnHeight/2
      local params={clickRect=CCRectMake(x,y,btnWidth,btnHeight),panlePos=ccp(10,y+220)}
      newGuidMgr:setGuideStepField(45,nil,nil,nil,params)
    end
end

function isLandStateDialog:showAnimation(parent,width,height)
  if parent==nil then
    do return end
  end
  local mx=width/2
  local opacity=50
  local actTime=0.6
  local lightSp1=CCSprite:createWithSpriteFrameName("acItemlight.png")
  local px,py=0-lightSp1:getContentSize().width/2,lightSp1:getContentSize().height/2
  lightSp1:setPosition(ccp(px,height-py))
  parent:addChild(lightSp1,10)
  lightSp1:setOpacity(opacity)
  local lightSp2=CCSprite:createWithSpriteFrameName("acItemlight.png")
  lightSp2:setPosition(ccp(px,py))
  parent:addChild(lightSp2,10)
  lightSp2:setOpacity(opacity)
  local function callBack1()
    lightSp1:setVisible(false)
  end
  local function callBack2()
    lightSp2:setVisible(false)
  end
  local function callBack3()
    lightSp1:setVisible(true)
    lightSp1:setPosition(ccp(px,height-py))
  end
  local function callBack4()
    lightSp2:setVisible(true)
    lightSp2:setPosition(ccp(px,py))
  end
  local moveTo1=CCMoveTo:create(actTime,ccp(mx,height-py))
  local moveTo2=CCMoveTo:create(actTime,ccp(mx,py))
  local fadeTo1=CCFadeTo:create(actTime,255)
  local carray1=CCArray:create()
  carray1:addObject(moveTo1)
  carray1:addObject(fadeTo1)
  local spawn1=CCSpawn:create(carray1)
  local carray2=CCArray:create()
  carray2:addObject(moveTo2)
  carray2:addObject(fadeTo1)
  local spawn2=CCSpawn:create(carray2)
  local moveTo3=CCMoveTo:create(actTime,ccp(parent:getContentSize().width-px,height-py))
  local moveTo4=CCMoveTo:create(actTime,ccp(parent:getContentSize().width-px,py))
  local fadeTo2=CCFadeTo:create(actTime,opacity)
  local carray3=CCArray:create()
  carray3:addObject(moveTo3)
  carray3:addObject(fadeTo2)
  local spawn3=CCSpawn:create(carray3)
  local carray4=CCArray:create()
  carray4:addObject(moveTo4)
  carray4:addObject(fadeTo2)
  local spawn4=CCSpawn:create(carray4)
  local callFunc1=CCCallFunc:create(callBack1)
  local callFunc2=CCCallFunc:create(callBack2)
  local callFunc3=CCCallFunc:create(callBack3)
  local callFunc4=CCCallFunc:create(callBack4)

  local delay1=CCDelayTime:create(0.2)
  local acArr1=CCArray:create()
  acArr1:addObject(spawn1)
  acArr1:addObject(spawn3)
  acArr1:addObject(callFunc1)
  acArr1:addObject(delay1)
  acArr1:addObject(callFunc3)
  local acArr2=CCArray:create()
  acArr2:addObject(spawn2)
  acArr2:addObject(spawn4)
  acArr2:addObject(callFunc2)
  acArr2:addObject(delay1)
  acArr2:addObject(callFunc4)
  local seq1=CCSequence:create(acArr1)
  local seq2=CCSequence:create(acArr2)
  lightSp1:runAction(CCRepeatForever:create(seq1))
  lightSp2:runAction(CCRepeatForever:create(seq2))
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function isLandStateDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       if self.selectedTabIndex==0 then
           return 6
       elseif self.selectedTabIndex==1 then
            return 4
       end

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       if self.selectedTabIndex==1 then
           tmpSize=CCSizeMake(400,200)
           
       else
           if self.expandIdx["k"..idx]~=nil then
              tmpSize=CCSizeMake(600,self.expandHeight)
           else
              tmpSize=CCSizeMake(600,self.normalHeight)
           end
           
       end

       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
       if self.selectedTabIndex==0 then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            self:loadCCTableViewCell(cell,idx)
            return cell
       
       elseif self.selectedTabIndex==1 then
           local cell=CCTableViewCell:new()
           cell:autorelease()
           local rect = CCRect(0, 0, 50, 50);
           local capInSet = CCRect(20, 20, 10, 10);
           local function cellClick(hd,fn,idx)
               return self:cellClick(idx)
           end
           local tmpSize
           if self.selectedTabIndex==1 then
               tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,200)
               
           else
               tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,120)

           end
           local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
           
           backSprie:setContentSize(tmpSize)
           backSprie:ignoreAnchorPointForPosition(false);
           backSprie:setAnchorPoint(ccp(0,0));
           backSprie:setTag(1000+idx)
           backSprie:setIsSallow(false)
           backSprie:setTouchPriority(-42)       
           cell:addChild(backSprie,1)

           local m_index = self.islandStateTab[idx+1].sid
           local lbName=GetTTFLabel(getlocal(self.islandStateTab[idx+1].name),24,true)
           lbName:setPosition(150,150)
           lbName:setAnchorPoint(ccp(0,0.5));
           cell:addChild(lbName,2)
           
           
           
           local sprite = CCSprite:createWithSpriteFrameName(self.islandStateTab[idx+1].icon);
           sprite:setAnchorPoint(ccp(0,0.5));
           sprite:setPosition(20,120)
           cell:addChild(sprite,2)
           
           local labelSize = CCSize(300, 100);
           local lbDescription=GetTTFLabelWrap(getlocal(self.islandStateTab[idx+1].description),20,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
           lbDescription:setPosition(130,80)
           lbDescription:setAnchorPoint(ccp(0,0.5));
           cell:addChild(lbDescription,2)
           
        local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
        gemIcon:setPosition(ccp(40,50));
        cell:addChild(gemIcon,2)

           local lbPrice=GetTTFLabel(self.islandStateTab[idx+1].gemCost,20)
           lbPrice:setPosition(60,50)
           lbPrice:setAnchorPoint(ccp(0,0.5));
           cell:addChild(lbPrice,2)
           
           local propId=0
           if idx==0 then
              propId=11
           elseif idx==1 then
              propId=12
           elseif idx==2 then
              propId=13
           elseif idx==3 then
              propId=14
           end
           
           local lbNum=GetTTFLabel(getlocal("propHave")..bagVoApi:getItemNumId(propId),20)
           lbNum:setPosition(20,23)
           lbNum:setAnchorPoint(ccp(0,0.5));
           cell:addChild(lbNum,2)

           local timeStr=useItemSlotVoApi:getLeftTimeById(propId)
           if timeStr~=nil then
               local timeLb=GetTTFLabel(GetTimeForItemStr(timeStr),20)
               timeLb:setPosition(backSprie:getContentSize().width-30,backSprie:getContentSize().height-30)
               timeLb:setAnchorPoint(ccp(1,0.5));
               timeLb:setColor(G_ColorYellow)
               backSprie:addChild(timeLb,2)
               self.timeLbTab2[propId]=timeLb
           end

          
           
           if bagVoApi:getItemNumId(propId)>0 then
                local function touch1()
                    local function callbackUseProc(fn,data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data)==true then
           local pid="p"..propId
           --统计使用物品
           statisticsHelper:useItem(pid,1)
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[pid].name)}),28)
                            self:reloadAndRemenber()
                        end

                    
                    end
                     
                    socketHelper:useProc(propId,nil,callbackUseProc)
                
                end
               local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("use"),28)
                local menu1 = CCMenu:createWithItem(menuItem1);
                menu1:setPosition(ccp(490,50));
                menu1:setTouchPriority(-42);
                cell:addChild(menu1,3);
                menuItem1:setScale(0.8)

           else
     local function touch1()
        local function touchBuy()
            local function callbackUseProc(fn,data)
                --local retTb=OBJDEF:decode(data)
                if base:checkServerData(data)==true then
                    if propId==14 then
                        worldScene:addProtect()
                    end
        local pid="p"..propId
        --统计购买物品
        statisticsHelper:buyItem(pid,propCfg[pid].gemCost,1,propCfg[pid].gemCost)
        --统计使用物品
        statisticsHelper:useItem(pid,1)
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[pid].name)}),28)
                    self:reloadAndRemenber()

                end
            
            end
             
            socketHelper:useProc(propId,1,callbackUseProc)
        end
                    
        local function buyGems()
            if G_checkClickEnable()==false then
                do
                    return
                end
            end
            vipVoApi:showRechargeDialog(self.layerNum+1)

        end
   local pid="p"..propId
        if playerVo.gems<tonumber(propCfg[pid].gemCost) then
            local num=tonumber(propCfg[pid].gemCost)-playerVo.gems
            local smallD=smallDialog:new()
                 smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(propCfg[pid].gemCost),playerVo.gems,num}),nil,self.layerNum+1)
        else
            local smallD=smallDialog:new()
                 smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{propCfg[pid].gemCost,getlocal(propCfg[pid].name)}),nil,self.layerNum+1)
        end
                
                end
                local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("buyAndUse"),28)
                local menu1 = CCMenu:createWithItem(menuItem1);
                menu1:setPosition(ccp(490,50));
                menu1:setTouchPriority(-42);
                cell:addChild(menu1,3);
                menuItem1:setScale(0.8)
           
           end
            return cell
       end


       
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--点击tab页签 idx:索引
function isLandStateDialog:tabClick(idx)
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
        self.tv:setPosition(ccp(30,40))
        self.protectLabel:setVisible(true)
    self.tv:setViewSize(CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-130))

         self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66+5))
         self.panelLineBg:setContentSize(CCSizeMake(600,770))
    else
        self.protectLabel:setVisible(false)
        self.islandStateTab=shopVoApi:getIslandState()
        self.tv:setPosition(ccp(30,30))
        
        self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66))
         self.panelLineBg:setContentSize(CCSizeMake(600,780))
    self.tv:setViewSize(CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120))
    end

    self.tv:reloadData()
    
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function isLandStateDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function isLandStateDialog:cellClick(idx)
    if self.selectedTabIndex==1 then
        return
    end
    if newGuidMgr:isNewGuiding()==true then
         if newGuidMgr.curStep==44 and (idx-1000)~=2 then
            do
                return
            end
         end
         newGuidMgr:toNextStep()
    end
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)
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

--创建或刷新CCTableViewCell
function isLandStateDialog:loadCCTableViewCell(cell,idx,refresh)
    local expanded=false
       if self.expandIdx["k"..idx]==nil then
             expanded=false
       else
             expanded=true
       end
       if expanded then
            cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.expandHeight))
       else
            cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
       end
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
               if idx~=1000 then
                    return self:cellClick(idx)
               end
       end
       local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
       headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
       headerSprie:ignoreAnchorPointForPosition(false);
       headerSprie:setAnchorPoint(ccp(0,0));
       headerSprie:setTag(1000+idx)
       headerSprie:setIsSallow(false)
       headerSprie:setTouchPriority(-42)
       headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
       cell:addChild(headerSprie)

      if newGuidMgr:isNewGuiding() and idx==2 then
        self.guideItem=headerSprie
      end
       
       local propId=0
       local propIdType = 0
       if idx==1 then
          propIdType=5
       elseif idx==2 then
          propIdType=1
       elseif idx==3 then
          propIdType=2
       elseif idx==4 then
          propIdType=3
       elseif idx==5 then
          propIdType=4
       end
       for k,v in pairs(useItemSlotVoApi:getAllSlots()) do
           if propCfg["p"..k].buffType==propIdType then
              propId=k
              break
           end
        end 
       local timeStr=useItemSlotVoApi:getLeftTimeById(propId)
       if timeStr~=nil then
           local timeLb=GetTTFLabel(GetTimeForItemStr(timeStr),20)
           timeLb:setPosition(headerSprie:getContentSize().width-30,headerSprie:getContentSize().height-30)
           timeLb:setAnchorPoint(ccp(1,0.5));
           timeLb:setColor(G_ColorYellow)
           headerSprie:addChild(timeLb,2)
           self.timeLbTab[propId]=timeLb
       end

       local lbName=GetTTFLabel(" ",24,true)
       lbName:setPosition(120,headerSprie:getContentSize().height-25)
       lbName:setAnchorPoint(ccp(0,0.5));
       headerSprie:addChild(lbName,2)

       local lbPrNum=GetTTFLabel(getlocal("capacity"),20)
       lbPrNum:setPosition(120,headerSprie:getContentSize().height-60)
       lbPrNum:setAnchorPoint(ccp(0,0.5));
       lbPrNum:setTag(30)
       headerSprie:addChild(lbPrNum,2)
       
       self.headTab[idx]=headerSprie
       local sprite
       local timerSpriteLv
       local resPic
       local resTypeTb={5,1,2,3,4}
       local bspeed,bcapacity
       local percentStr=""
       local color=G_ColorWhite
       local r1P,r2P,r3P,r4P,rGP=buildingVoApi:getResourcePercent()
       local pervTb={rGP,r1P,r2P,r3P,r4P}
       local num=self:getResNumByIndex(idx)
       if idx~=0 then
          bspeed,bcapacity=buildingVoApi:getTotalProduceSpeedAndCapacityByBType(resTypeTb[idx])
          percentStr=FormatNumber(num).."/"..FormatNumber(bcapacity)

          local lbNum=GetTTFLabel(getlocal("capacity"),20)
          lbNum:setPosition(120,headerSprie:getContentSize().height-95)
          lbNum:setAnchorPoint(ccp(0,0.5))
          headerSprie:addChild(lbNum,2)

          lbPrNum:setString(getlocal("produceSpeed",{bspeed}));

          local percent=pervTb[idx]
          if percent then
            if percent>100 then
              AddProgramTimer(headerSprie,ccp(280+lbNum:getContentSize().width,headerSprie:getContentSize().height-95),21,22," ","res_progressbg.png","resyellow_progress.png",23,nil,nil,nil,nil,20)
            else
              AddProgramTimer(headerSprie,ccp(280+lbNum:getContentSize().width,headerSprie:getContentSize().height-95),21,22," ","res_progressbg.png","resblue_progress.png",23,nil,nil,nil,nil,20)
            end
          end
          timerSpriteLv=headerSprie:getChildByTag(21);
          timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
          timerSpriteLv:setPercentage(percent)

          local proLb=timerSpriteLv:getChildByTag(22);
          proLb=tolua.cast(proLb,"CCLabelTTF")
          proLb:setColor(color)
          proLb:setString(percentStr)
          local protectPer=self.protectResource/bcapacity*100 --保护量比例
          local arrowSp=CCSprite:createWithSpriteFrameName("progress_point.png")
          timerSpriteLv:addChild(arrowSp)
          if protectPer>100 then
            protectPer=100
          end
          local offestX=0
          if protectPer==100 then
            offestX=-3
          end
          if protectPer>0 then
            arrowSp:setPosition(timerSpriteLv:getContentSize().width*protectPer/100+offestX,timerSpriteLv:getContentSize().height/2)
            arrowSp:setVisible(true)
          else
            arrowSp:setVisible(false)
          end
       end

       if idx==0 then
           resPic="resourse_normal_gem.png"
           lbName:setString(getlocal("gem"));
           lbPrNum:setString(getlocal("ownedGem",{num}));
           lbName:setPositionY(self.normalHeight/2 + 20)
           lbPrNum:setPositionY(self.normalHeight/2 - 20)
           
            local function touch()
                if self.tv:getIsScrolled()==true then
                        return
                end
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                end
                PlayEffect(audioCfg.mouseClick)
                vipVoApi:showRechargeDialog(4)

            end

            local menuItem1 = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touch,11,getlocal("moreMoney"),24+6,100)
            local menu1 = CCMenu:createWithItem(menuItem1);
            menu1:setPosition(ccp(490,self.normalHeight/2));
            menu1:setTouchPriority(-42);
            headerSprie:addChild(menu1,3);
            menuItem1:setScale(0.7)
            local lb = menuItem1:getChildByTag(100)
            if lb then
              lb = tolua.cast(lb, "CCLabelTTF")
              lb:setFontName("Helvetica-bold")
            end
           
       elseif idx==1 then
            resPic="resourse_normal_gold.png"
            lbName:setString(getlocal("money"));           
            -- if  acCrystalYieldVoApi~=nil  and acCrystalYieldVoApi:getAcVo()~=nil and base.serverTime > acCrystalYieldVoApi:getAcVo().st and base.serverTime<acCrystalYieldVoApi:getAcVo().et then
            --     local strAc=getlocal("crystalYieldEffect")
            --     local acLb=GetTTFLabel(strAc,23)
            --     acLb:setColor(G_ColorYellowPro)
            --     acLb:setAnchorPoint(ccp(0,0.5));
            --     acLb:setPosition(ccp(lbPrNum:getPositionX()+lbPrNum:getContentSize().width+20,lbPrNum:getPositionY()))
            --     headerSprie:addChild(acLb,2)
            -- end
       elseif idx==2 then
            resPic="resourse_normal_metal.png"
            lbName:setString(getlocal("metal"));
       elseif idx==3 then
            resPic="resourse_normal_oil.png"
            lbName:setString(getlocal("oil"));
       elseif idx==4 then
            resPic="resourse_normal_silicon.png"
            lbName:setString(getlocal("silicon"));
       elseif idx==5 then
            resPic="resourse_normal_uranium.png"
            lbName:setString(getlocal("uranium"));
       end
       if resPic then
          local function showBuffDetail()
            if newGuidMgr:isNewGuiding() then  --新手引导
              do return end
            end
            if idx~=0 then
              local bspeed,bcapacity,sdetail,cdetail=buildingVoApi:getTotalProduceSpeedAndCapacityByBType(resTypeTb[idx],true)
              if sdetail and cdetail then
                local details={sdetail,cdetail}
                require "luascript/script/game/scene/gamedialog/buffAddedSmallDialog"
                local sdialog=buffAddedSmallDialog:new()
                local tab={getlocal("res_speed"),getlocal("res_capacity")}
                sdialog:init("TankInforPanel.png",CCSizeMake(570,300),CCRect(130,50,1,1),getlocal("playerInfo"),tab,details,true,true,self.layerNum+1)
              end
            end
          end
          sprite=LuaCCSprite:createWithSpriteFrameName(resPic,showBuffDetail);
          if newGuidMgr:isNewGuiding() then  --新手引导
              if id==21 then
                sprite:setTouchPriority(-41)
              end
          else
            sprite:setTouchPriority(-43)
          end
          sprite:setAnchorPoint(ccp(0,0.5));
          sprite:setPosition(10,headerSprie:getContentSize().height/2)
          headerSprie:addChild(sprite,2)
        end
   
      if idx~=0 then
        local fangdajingSp=CCSprite:createWithSpriteFrameName("datebaseShow2.png")
        fangdajingSp:setAnchorPoint(ccp(1,0))
        fangdajingSp:setPosition(sprite:getContentSize().width-5,5)
        sprite:addChild(fangdajingSp,2)
      end
  
       local expHeightPos = 0
       if G_getCurChoseLanguage() =="vi" then
         expHeightPos =50
       end
       --显示加减号
       if idx~=0 then
           local btn
           if expanded==false then
               btn=CCSprite:createWithSpriteFrameName("moreBtn.png")
           else
               btn=CCSprite:createWithSpriteFrameName("lessBtn.png")
           end
           btn:setAnchorPoint(ccp(0,0.5))
           btn:setPosition(ccp(headerSprie:getContentSize().width-btn:getContentSize().width-15,headerSprie:getContentSize().height/2))
           headerSprie:addChild(btn)
           btn:setTag(self.extendSpTag)
       end
       
       
       if expanded==true then --显示展开信息
       
          local function touchHander()
          
          end
          local rect = CCRect(0, 0, 50, 50);
            local capInSet = CCRect(40, 40, 10, 10);
            local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemInforBg.png",capInSet,touchHander)
            exBg:setAnchorPoint(ccp(0,0))
            exBg:setContentSize(CCSize(580,self.expandHeight-self.normalHeight))
            exBg:setPosition(ccp(0,0))
            exBg:setTag(2)
            cell:addChild(exBg)
        if idx==1 then
           self:exbgCellForId(10,exBg,G_VisibleSize.height-480)
           self:exbgCellForId(25,exBg,G_VisibleSize.height-480-200)
           self:exbgCellForId(30,exBg,G_VisibleSize.height-480-400)
        
        elseif idx==2 then
           self:exbgCellForId(6,exBg,G_VisibleSize.height-480)
           self:exbgCellForId(21,exBg,G_VisibleSize.height-480-200)
           self:exbgCellForId(26,exBg,G_VisibleSize.height-480-400)
        elseif idx==3 then
           self:exbgCellForId(7,exBg,G_VisibleSize.height-480)
           self:exbgCellForId(22,exBg,G_VisibleSize.height-480-200)
           self:exbgCellForId(27,exBg,G_VisibleSize.height-480-400)
        elseif idx==4 then
           self:exbgCellForId(8,exBg,G_VisibleSize.height-480)
           self:exbgCellForId(23,exBg,G_VisibleSize.height-480-200)
           self:exbgCellForId(28,exBg,G_VisibleSize.height-480-400)
        elseif idx==5 then
           self:exbgCellForId(9,exBg,G_VisibleSize.height-480)
           self:exbgCellForId(24,exBg,G_VisibleSize.height-480-200)
           self:exbgCellForId(29,exBg,G_VisibleSize.height-480-400)
        end
            
            
       
       end

end

function isLandStateDialog:showHelpDialog()
  if self.helpDialog==nil then
    self.helpDialog=CCLayer:create()
    self.helpDialog:setBSwallowsTouches(true)
    local function touchHander()
    end
    local dWidth=570
    local dHeight=30
    -- if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
    --   dHeight=500
    -- end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130,50,1,1),touchHander)
    dialogBg:setTouchPriority(-(self.layerNum-1)*20-2)
    dialogBg:setPosition(getCenterPoint(self.helpDialog))
    self.helpDialog:addChild(dialogBg,1)

    local dLayer=CCNode:create()
    dLayer:setContentSize(CCSizeMake(dWidth,1))
    dLayer:setAnchorPoint(ccp(0.5,1))
    dialogBg:addChild(dLayer)

    local posY=0
    local titleLb=GetTTFLabelWrap(getlocal("resource_capacity"),24,CCSizeMake(dWidth-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    titleLb:setPosition(dWidth/2,posY-titleLb:getContentSize().height/2)
    dLayer:addChild(titleLb,2)
    local realH=titleLb:getContentSize().height
    local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    titleBg:setPosition(ccp(dWidth/2+30,titleLb:getPositionY()))
    titleBg:setScaleY((realH+20)/titleBg:getContentSize().height)
    titleBg:setScaleX((dWidth+100)/titleBg:getContentSize().width)
    dLayer:addChild(titleBg)
    local titleBgH=titleBg:getContentSize().height*titleBg:getScaleY()
    dHeight=dHeight+titleBgH+10
    posY=posY-titleBgH-10
    for i=1,3 do
      local pic,title,desc
      if i==1 then
        pic="resblue_progress.png"
        title=getlocal("rating_capacity")
        desc=getlocal("capacity_state_desc1")
      elseif i==2 then
        pic="resyellow_progress.png"
        title=getlocal("extra_capacity")
        desc=getlocal("capacity_state_desc2")
      else
        pic="res_progressbg.png"
        title=getlocal("safe_capacity")
        desc=getlocal("capacity_state_desc3")
      end
      if pic and title and desc then
        local sprite=CCSprite:createWithSpriteFrameName(pic)
        posY=posY-sprite:getContentSize().height/2
        sprite:setAnchorPoint(ccp(0,0.5))
        sprite:setPosition(ccp(40,posY))
        sprite:setScaleX(50/sprite:getContentSize().width)
        dLayer:addChild(sprite)
        if i==3 then
          local arrowSp=CCSprite:createWithSpriteFrameName("progress_point.png")
          arrowSp:setPosition(getCenterPoint(sprite))
          arrowSp:setScaleX(1/sprite:getScaleX())
          sprite:addChild(arrowSp)
        -- else
        --   local lb=GetTTFLabel("",25)
        --   if i==1 then
        --     lb:setString("1/1")
        --   else
        --     lb:setString("2/1")
        --   end
        --   lb:setPosition(getCenterPoint(sprite))
        --   sprite:addChild(lb,1)
        --   lb:setScaleX(1/sprite:getScaleX())
        end
        local titleLb=GetTTFLabelWrap(title,22,CCSizeMake(dWidth-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleLb:setAnchorPoint(ccp(0,1))
        titleLb:setPosition(ccp(100,posY+sprite:getContentSize().height/2-3))
        titleLb:setColor(G_ColorYellowPro)
        dLayer:addChild(titleLb)

        posY=posY-titleLb:getContentSize().height-10
        dHeight=dHeight+titleLb:getContentSize().height+10

        local descLb=GetTTFLabelWrap(desc,22,CCSizeMake(dWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLb:setAnchorPoint(ccp(0,1))
        descLb:setPosition(ccp(40,posY))
        dLayer:addChild(descLb)

        dHeight=dHeight+descLb:getContentSize().height+20
        posY=posY-descLb:getContentSize().height-20
        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setScaleX((dWidth-50)/lineSp:getContentSize().width)
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(ccp(dWidth/2,posY))
        dLayer:addChild(lineSp)
        dHeight=dHeight+20
        posY=posY-10
      end
    end
    dHeight=dHeight+60
    dialogBg:setContentSize(CCSizeMake(dWidth,dHeight))
    dLayer:setPosition(dWidth/2,dHeight-30)

    local function touchLuaSpr()
      local function realClose()
        if self.helpDialog then
          self.helpDialog:removeFromParentAndCleanup(true)
          self.helpDialog=nil
        end
      end
      local fc=CCCallFunc:create(realClose)
      local scaleTo1=CCScaleTo:create(0.1, 1.1)
      local scaleTo2=CCScaleTo:create(0.07, 0.8)

      local acArr=CCArray:create()
      acArr:addObject(scaleTo1)
      acArr:addObject(scaleTo2)
      acArr:addObject(fc)

      local seq=CCSequence:create(acArr)
      dialogBg:runAction(seq)
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.helpDialog))
    self.helpDialog:addChild(touchDialogBg)
    self.bgLayer:addChild(self.helpDialog,10)

    local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    local function callBack()
      base:cancleWait()
    end
    local callFunc=CCCallFunc:create(callBack)
    local scaleTo1=CCScaleTo:create(0.1,1.1)
    local scaleTo2=CCScaleTo:create(0.07,1)
    local acArr=CCArray:create()
    acArr:addObject(scaleTo1)
    acArr:addObject(scaleTo2)
    acArr:addObject(callFunc)

    local seq=CCSequence:create(acArr)
    dialogBg:runAction(seq)
  end
end

function isLandStateDialog:getResNumByIndex(idx)
  local num=0
  if idx==0 then
    num=playerVoApi:getGems()
  elseif idx==1 then
    num=playerVoApi:getGold()
  elseif idx==2 then
    num=playerVoApi:getR1()
  elseif idx==3 then
    num=playerVoApi:getR2()
  elseif idx==4 then
    num=playerVoApi:getR3()
  elseif idx==5 then
    num=playerVoApi:getR4()
  end
  return num  
end

function isLandStateDialog:exbgCellForId(id,parent,m_height)
  local pid="p"..id;
  local lbName=GetTTFLabelWrap(getlocal(propCfg[pid].name),24,CCSizeMake(26*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
  lbName:setPosition(130,150+m_height)
  lbName:setAnchorPoint(ccp(0,0.5));
  parent:addChild(lbName,2)

  local lbNum=GetTTFLabel(getlocal("propHave")..bagVoApi:getItemNumId(id),20)
  lbNum:setPosition(490,23+m_height+10)
  lbNum:setAnchorPoint(ccp(0.5,0.5));
  parent:addChild(lbNum,2)

  local sprite = CCSprite:createWithSpriteFrameName(propCfg[pid].icon);
  sprite:setAnchorPoint(ccp(0,0.5));
  sprite:setPosition(20,120+m_height)
  parent:addChild(sprite,2)

  local labelSize = CCSize(270, 100);
  local lbDescription=GetTTFLabelWrap(getlocal(propCfg[pid].description),20,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  lbDescription:setPosition(130,75+m_height)
  lbDescription:setAnchorPoint(ccp(0,0.5));
  parent:addChild(lbDescription,2)

  local propNum=bagVoApi:getItemNumId(id)
  if propNum==0 then
    local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
    gemIcon:setPosition(ccp(470,50+m_height+110));
    parent:addChild(gemIcon,2)

    local lbPrice=GetTTFLabel(propCfg[pid].gemCost,20)
    lbPrice:setPosition(gemIcon:getPositionX()+30,gemIcon:getPositionY())
    lbPrice:setAnchorPoint(ccp(0,0.5));
    parent:addChild(lbPrice,2)
  end
  local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png");
  lineSprite:setAnchorPoint(ccp(0,0.5));
  lineSprite:setPosition(20,m_height)
  parent:addChild(lineSprite,2)
  if propNum>0 then
    local function touch1()
      PlayEffect(audioCfg.mouseClick)
      if self:useBuffItem(id)>0 then
         do
            return
         end
      end
      
      if id==10 then
          
      
      end
      if newGuidMgr:isNewGuiding() then  --新手引导
          if id==21 then
              newGuidMgr:toNextStep()
              self:close();
          end
      end
      local function realUseProp(num)
        if num==nil then
          num=1
        end
        local function callbackUseProc(fn,data)
          --local retTb=OBJDEF:decode(data)
          if base:checkServerData(data)==true then
              --统计使用物品
              statisticsHelper:useItem(pid,num)
              smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[pid].name)}),28)
              self:reloadAndRemenber()
          end
        end
        socketHelper:useProc(id,nil,callbackUseProc,nil,nil,num)
      end
      if propNum>1 then
        local function useHandler(num)
          realUseProp(num)
        end
        bagVoApi:showBatchUsePropSmallDialog(pid,self.layerNum+1,useHandler)
      else
        realUseProp(1)
      end
    end
    local menuItem1=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touch1,11,getlocal("use"),28)
    local menu1=CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(490,40+m_height+60));
    menu1:setTouchPriority(-(self.layerNum-1)*20-2);
    parent:addChild(menu1,3);
    menuItem1:setScale(0.8)
  else
    local function touch1()
      local function touchBuy()
        local function callbackUseProc(fn,data)
          --local retTb=OBJDEF:decode(data)
          if base:checkServerData(data)==true then
            --统计购买物品
            statisticsHelper:buyItem(pid,propCfg[pid].gemCost,1,propCfg[pid].gemCost)
            --统计使用物品
            statisticsHelper:useItem(pid,1)

            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[pid].name)}),28)
            self:reloadAndRemenber()
            --self.tv:reloadData()
          end
        end
        socketHelper:useProc(id,1,callbackUseProc)
      end
   
      local function buyGems()
        if G_checkClickEnable()==false then
            do
              return
            end
        end
        vipVoApi:showRechargeDialog(self.layerNum+1)
      end
      local pid="p"..id
      if playerVo.gems<tonumber(propCfg[pid].gemCost) then
        local num=tonumber(propCfg[pid].gemCost)-playerVo.gems
        local smallD=smallDialog:new()
        smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(propCfg[pid].gemCost),playerVo.gems,num}),nil,self.layerNum+1)
      else
        if self:useBuffItem(id)>0 then
          do
            return
          end
        end
        local smallD=smallDialog:new()
        smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{propCfg[pid].gemCost,getlocal(propCfg[pid].name)}),nil,self.layerNum+1)
      end    
    end
    local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("buyAndUse"),28)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(490,40+m_height+60));
    menu1:setTouchPriority(-(self.layerNum-1)*20-2);
    parent:addChild(menu1,3);
    menuItem1:setScale(0.8)
  end
end
function isLandStateDialog:reloadAndRemenber()
    if newGuidMgr:isNewGuiding()~=true then
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end

end
function isLandStateDialog:tick()
    if self.selectedTabIndex==0 then
        for k,v in pairs(self.timeLbTab) do
            local timeLb=v
            timeLb=tolua.cast(timeLb,"CCLabelTTF")
            if useItemSlotVoApi:getLeftTimeById(k)==nil then
                self.timeLbTab={}
                self.headTab={}
                self:reloadAndRemenber()
                do
                    return
                end
            end
            local timeStr=useItemSlotVoApi:getLeftTimeById(k)
            if timeLb~=nil then
                timeLb:setString(GetTimeForItemStr(timeStr))
            end
        
        end

        local timerSpriteLv;
        local proLb
        local lbPrNum;
        local resTypeTb={5,1,2,3,4}
        local bspeed,bcapacity
        local r1P,r2P,r3P,r4P,rGP=buildingVoApi:getResourcePercent()
        local pervTb={rGP,r1P,r2P,r3P,r4P}
        local percent=0
        local percentStr=""
        for k,v in pairs(self.headTab) do
            if k~=0 then
              bspeed,bcapacity=buildingVoApi:getTotalProduceSpeedAndCapacityByBType(resTypeTb[k])
              percent=pervTb[k]
              local num=self:getResNumByIndex(k)
              percentStr=FormatNumber(num).."/"..FormatNumber(tonumber(bcapacity))
              timerSpriteLv=v:getChildByTag(21)
              timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
              if timerSpriteLv then
                timerSpriteLv:setPercentage(percent)
              end

              lbPrNum=v:getChildByTag(30)
              lbPrNum=tolua.cast(lbPrNum,"CCLabelTTF")
              lbPrNum:setString(getlocal("produceSpeed",{bspeed}));

              proLb=timerSpriteLv:getChildByTag(22);
              proLb=tolua.cast(proLb,"CCLabelTTF")
              proLb:setString(percentStr)

            end
        end
    else
        for k,v in pairs(self.timeLbTab2) do
            if useItemSlotVoApi:getLeftTimeById(k)==nil then
                self.timeLbTab={}
                self.headTab={}
                self:reloadAndRemenber()
                do
                    return
                end
            end
            local timeLb=v
            timeLb=tolua.cast(timeLb,"CCLabelTTF")
            
            local timeStr=useItemSlotVoApi:getLeftTimeById(k)
            timeLb:setString(GetTimeForItemStr(timeStr))
        
        end

    end

    --关卡科技数据，资源产量
    if checkPointVoApi then
        if self.callbackNum<3 then
            local techFlag=checkPointVoApi:getTechFlag()
            if techFlag==-1 then
                local function challengeRewardlistCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        checkPointVoApi:updateResAddPercent()
                        checkPointVoApi:setTechFlag(1)
                    end
                end
                socketHelper:challengeRewardlist(challengeRewardlistCallback)
                self.callbackNum=self.callbackNum+1
            end
        end
    end
    
end
function isLandStateDialog:useBuffItem(id,idx)
  local isEnabledUse = 0 --1:已经有小的 覆盖使用 2:已有大的 不能使用 0:直接使用
  local pid = "p"..id
  local buffTb=useItemSlotVoApi:getAllSlots()
  for k,v in pairs(buffTb) do
    local ppid = "p"..k
    if propCfg[ppid].buffType~=nil and propCfg[ppid].buffType<6 and propCfg[pid].buffType==6 then
       if propCfg[ppid].buffLevel<propCfg[pid].buffLevel then
          isEnabledUse=1
          break
       elseif propCfg[ppid].buffLevel>propCfg[pid].buffLevel then
          isEnabledUse=3
          break
       end
    elseif propCfg[ppid].buffType~=nil and propCfg[ppid].buffType==propCfg[pid].buffType then
       if propCfg[ppid].buffLevel<propCfg[pid].buffLevel then
          isEnabledUse=1
          break
       elseif propCfg[ppid].buffLevel>propCfg[pid].buffLevel then
          isEnabledUse=2
          break
       end
    end
  end

  if isEnabledUse==1 then
     local function sure()
       local function callbackUseProc1(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local nameStr=getlocal(propCfg[pid].name)
                local str = getlocal("use_prop_success",{nameStr})
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
                self:refreshBag(idx)
            end

       end
       socketHelper:useProc(id,nil,callbackUseProc1,1)
     end
     local str=""
     local keyTb={[1]="metal",[2]="oil",[3]="silicon",[4]="uranium",[5]="money",[7]="sample_prop_name_12",[8]="sample_prop_name_11",[9]="sample_prop_name_13"}
     for k,v in pairs(buffTb) do
       local ppid = "p"..k
       if propCfg[ppid].buffType<6 and propCfg[pid].buffType==6 then 
          str=str..getlocal(keyTb[propCfg[ppid].buffType])
       elseif propCfg[pid].buffType==propCfg[ppid].buffType then
          str=getlocal(keyTb[propCfg[ppid].buffType])
       end
     end


     smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sure,getlocal("dialog_title_prompt"),getlocal("sureUseItem1",{str}),nil,self.layerNum+1)


  elseif isEnabledUse==2 then
     local function sure()
       
     end
     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("sureUseItem2"),nil,self.layerNum + 1)
  elseif isEnabledUse==3 then
     local str=""
     local keyTb={[1]="metal",[2]="oil",[3]="silicon",[4]="uranium",[5]="money",[9]="sample_prop_name_13"}
     for k,v in pairs(buffTb) do
       local ppid = "p"..k
       if propCfg[ppid].buffType<6 then 
          str=str..getlocal(keyTb[propCfg[ppid].buffType])
       end
     end
     local function sure()
       
     end
     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("sureUseItem3",{str}),nil,self.layerNum + 1)

  end
  return isEnabledUse


end

function isLandStateDialog:dispose()
    spriteController:removePlist("public/datebaseShow.plist")
    spriteController:removeTexture("public/datebaseShow.png")
    spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acItemBg.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/acItemBg.png")
    self.expandIdx=nil
    self.islandStateTab=nil
    self.expandHeight=nil
    self.normalHeight=nil
    self.extendSpTag=nil
    self.headTab=nil
    self.protectLabel=nil
    self.callbackNum=0
    self.protectResource=0
    self.helpDialog=nil
    self.guideItem=nil
    self=nil
end