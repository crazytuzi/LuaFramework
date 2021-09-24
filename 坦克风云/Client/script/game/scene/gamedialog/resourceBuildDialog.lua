--require "luascript/script/componet/commonDialog"
resourceBuildDialog=commonDialog:new()

function resourceBuildDialog:new(bid)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
  self.bid=bid
  self.dataSource={}
    self.expandIdx={}
  self.normalHeight=155
  self.expandHeight=G_VisibleSize.height-140
  self.requires={}
  self.allCellsBtn={}
  self.lastBuildTime=0
    return nc
end

--设置或修改每个Tab页签
function resourceBuildDialog:resetTab()
    print("self.bid111=",self.bid)
    if G_phasedGuideOnOff() then
        if self.bid>45 then
            if phasedGuideMgr:getInsideKey(7)==0 then
                phasedGuideMgr:insidePanel(107)
                phasedGuideMgr:setInsideKeyDone(7)
            end
        end
    end
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

--设置对话框里的tableView
function resourceBuildDialog:initTableView()

  local configType=homeCfg.buildingUnlock[self.bid].type
  if configType==4 then
    self.buildType3=false
  else
    self.buildType3=true
  end
  
  if self.buildType3==true then
    self.dataSource={1,2,3,1,2,3,1,2,3,4,1,2,3,4,1,2,3,4}
  else
    self.dataSource={4}
  end

  self.tvWidth,self.tvHeight=self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-200
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.bgLayer:setTouchPriority(-41)
    self.tv:setTableViewTouchPriority(-43)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function resourceBuildDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
     if self.buildType3==true then
         return 3
     else
         return 1
     end
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       if self.expandIdx["k"..idx]~=nil then
         tmpSize=CCSizeMake(600,self.expandHeight)
       else
         tmpSize=CCSizeMake(600,self.normalHeight)
       end
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       --self.allCells[idx+1]=cell
       self:loadCCTableViewCell(cell,idx)      
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--点击tab页签 idx:索引
function resourceBuildDialog:tabClick(idx)
        PlayEffect(audioCfg.mouseClick)
        for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self.tv:reloadData()
            self:doUserHandler()
         else
            v:setEnabled(true)
         end
    end
end

--用户处理特殊需求,没有可以不写此方法
function resourceBuildDialog:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function resourceBuildDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if newGuidMgr:isNewGuiding()==true then 
            if newGuidMgr.curStep==24 then
                  if (idx-1000)~=1 then
                        do
                            return
                        end
                  end
            end
            if newGuidMgr.curStep==27 then
                  if (idx-1000)~=2 then
                        do
                            return
                        end
                  end
            end
        end
        PlayEffect(audioCfg.mouseClick)
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
                if newGuidMgr:isNewGuiding() then --新手引导 
                  local nextStepId  
                  if newGuidMgr.curStep==20 then
                    nextStepId=22
                  elseif newGuidMgr.curStep==23 then
                    nextStepId=25
                  elseif newGuidMgr.curStep==26 then
                    nextStepId=28
                  end
                  if nextStepId then
                    local btnWidth,btnHeight=205,71
                    local offestH=190
                    local iphoneType=G_getIphoneType()
                    if iphoneType==G_iphoneX then
                      offestH=514
                    elseif iphoneType==G_iphone5 then
                      offestH=400
                    end
                    local x,y=G_VisibleSize.width-140-btnWidth/2,30+offestH-80-btnHeight/2+(self.tvHeight-self.expandHeight)
                    local params={clickRect=CCRectMake(x,y,btnWidth,btnHeight),panlePos=ccp(10,y+300)}
                    newGuidMgr:setGuideStepField(nextStepId,nil,nil,nil,params)
                  end
                  newGuidMgr:toNextStep()
                end
        else
            self.requires[idx-1000+1]:dispose()
            self.requires[idx-1000+1]=nil
            self.allCellsBtn[idx-1000+1]=nil
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

--创建或刷新CCTableViewCell
function resourceBuildDialog:loadCCTableViewCell(cell,idx,refresh)
       local function cellClick(hd,fn,idx)
           return self:cellClick(idx)
       end
       local expanded=false
       if self.expandIdx["k"..idx]==nil then
             expanded=false
       else
             expanded=true
       end
       if refresh==nil then
          refresh=false
       end
       if refresh==false then --创建cell
               if expanded then
                   cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.expandHeight))
               else
                   cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
               end
                local rect = CCRect(0, 0, 50, 50);
                local capInSet = CCRect(20, 20, 10, 10);
               local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
               headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
               headerSprie:ignoreAnchorPointForPosition(false);
               headerSprie:setAnchorPoint(ccp(0,0));
               headerSprie:setTag(1000+idx)
               headerSprie:setIsSallow(false)
               headerSprie:setTouchPriority(-42)
               headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
               cell:addChild(headerSprie)
               local btype=self.dataSource[idx+1]
               local bcfg=buildingCfg[btype]
               --[[
               local itemImgSp=CCSprite:createWithSpriteFrameName(bcfg.style)
               itemImgSp:setScale(0.7)
               itemImgContainer:addChild(itemImgSp)
               itemImgSp:setPosition(ccp(itemImgContainer:getContentSize().width/2,itemImgContainer:getContentSize().height/2))]]
               
               local itemImgContainer=CCSprite:createWithSpriteFrameName(bcfg.icon)
               
               itemImgContainer:setAnchorPoint(ccp(0,0));
               
               itemImgContainer:setPosition(ccp(10,self.normalHeight-itemImgContainer:getContentSize().height))
               headerSprie:addChild(itemImgContainer)
               headerSprie:setOpacity(0)
               --建造时间
               local tmIco=CCSprite:createWithSpriteFrameName("IconTime.png")
               tmIco:setAnchorPoint(ccp(0,0))
               tmIco:setPosition(ccp(20,self.normalHeight-itemImgContainer:getContentSize().height-tmIco:getContentSize().height))
               headerSprie:addChild(tmIco)
               
               local tmLb= GetTTFLabel(GetTimeStr(tonumber(Split(bcfg.timeConsumeArray,",")[1])),20)
               tmLb:setAnchorPoint(ccp(0,0.5))
               tmLb:setPosition(ccp(20+tmIco:getContentSize().width,self.normalHeight-itemImgContainer:getContentSize().height-tmIco:getContentSize().height+tmIco:getContentSize().height/2))
               headerSprie:addChild(tmLb)
               --建筑名称
               local bNameCon=LuaCCScale9Sprite:createWithSpriteFrameName("HeaderBg.png",CCRect(15, 15, 5, 5),cellClick)
               bNameCon:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-200,48))
               bNameCon:setAnchorPoint(ccp(0,0))
               bNameCon:setPosition(125,self.normalHeight-bNameCon:getContentSize().height)
               headerSprie:addChild(bNameCon)
                
               local bNameLb= GetTTFLabel(getlocal(bcfg.buildName),24,true) 
               bNameLb:setAnchorPoint(ccp(0,0.5))
               bNameLb:setPosition(ccp(5,bNameCon:getContentSize().height/2))
               bNameCon:addChild(bNameLb)
               --描述文字
               local descStr=getlocal(bcfg.buildDescription,{FormatNumber(Split(bcfg.produceSpeed,",")[1]),FormatNumber(Split(bcfg.capacity,",")[1])})  
               local bDescLb=GetTTFLabelWrap(descStr,20,CCSize(bNameCon:getContentSize().width-55,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
               bDescLb:setAnchorPoint(ccp(0,0.5))
               bDescLb:setPosition(130,self.normalHeight-bNameCon:getContentSize().height-bDescLb:getContentSize().height/2)
               headerSprie:addChild(bDescLb)
               -- + -号按钮
               local btn
               if expanded==false then
                   btn=CCSprite:createWithSpriteFrameName("moreBtn.png")
               else
                   btn=CCSprite:createWithSpriteFrameName("lessBtn.png")
               end
               btn:setAnchorPoint(ccp(0,0))
               btn:setPosition(self.bgLayer:getContentSize().width-btn:getContentSize().width-70,self.normalHeight-itemImgContainer:getContentSize().height-20)
               headerSprie:addChild(btn)

               --展开后的内容
               if expanded then
                    local rect = CCRect(0, 0, 50, 50);
                    local capInSet = CCRect(20, 20, 10, 10);
                    local function touchHander()
          
                    end
                    local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
                    exBg:setAnchorPoint(ccp(0,0))
                    exBg:setContentSize(CCSize(self.bgLayer:getContentSize().width-80,440))
                    exBg:setPosition(ccp(10,190))
                    local iphoneType=G_getIphoneType()
                    if iphoneType==G_iphoneX then
                        exBg:setPosition(ccp(10,514))
                    elseif iphoneType==G_iphone5 then
                        exBg:setPosition(ccp(10,400))
                    end
                    exBg:setTag(2)
                    cell:addChild(exBg)

                    --建造条件
                    self.requires[idx+1]=upgradeRequire:new()
                    local result=self.requires[idx+1]:create(exBg,"build",self.bid,self.dataSource[idx+1])
                    --新建按钮
                    local function touch1(tag,object)
                          if (base.serverTime-self.lastBuildTime)<=2 then
                               do
                                    return
                               end
                          end
                          self.lastBuildTime=base.serverTime
                          PlayEffect(audioCfg.mouseClick)
                          local function serverUpgrade(fn,data)
                                  --local retTb=OBJDEF:decode(data)
                                  if base:checkServerData(data)==true then
                                      if buildingVoApi:upgrade(self.bid,self.dataSource[idx+1]) then
                                          self:close()
                                          if newGuidMgr:isNewGuiding() then --新手引导
                                                newGuidMgr:toNextStep()
                                          end
                                      end
                                  end
                          end
                          local checkResult=buildingVoApi:checkUpgradeBeforeSendServer(self.bid,self.dataSource[idx+1])
                          if(checkResult==0)then
                              socketHelper:upgradeBuild(self.bid,self.dataSource[idx+1],serverUpgrade)
                          elseif(checkResult==1)then
                              local targetType=self.dataSource[idx+1]
                              local function onSpeed()
                                  socketHelper:upgradeBuild(self.bid,targetType,serverUpgrade)
                              end
                              vipVoApi:showQueueFullDialog(1,5,onSpeed)
                          end
                    end
                    local menuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,idx+1,getlocal("startBuild"),24,101)
                    local lb = menuItem:getChildByTag(101)
                    if lb then
                      lb = tolua.cast(lb,"CCLabelTTF")
                      lb:setFontName("Helvetica-bold")
                    end
                    self.allCellsBtn[idx+1]=menuItem
                    if result==false then
                        menuItem:setEnabled(false)
                    end
                    local createMenu=CCMenu:createWithItem(menuItem);
                    createMenu:setPosition(ccp(exBg:getContentSize().width-100,-80))
                    createMenu:setTouchPriority(-42);
                    exBg:addChild(createMenu)
               end
        else --刷新内容
        
        end
end

function resourceBuildDialog:tick()
   for k,v in pairs(self.requires) do
      local result=v:tick()

         self.allCellsBtn[k]:setEnabled(result)

   end
end












