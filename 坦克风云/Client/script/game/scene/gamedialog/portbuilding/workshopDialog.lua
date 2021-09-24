--require "luascript/script/componet/commonDialog"
workshopDialog=commonDialog:new()

function workshopDialog:new(bid,isShowPoint)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bid=bid
    self.isShowPoint=isShowPoint
    self.leftBtn=nil
    self.expandIdx={}
    self.workShopTab={}
    self.expandHeight=G_VisibleSize.height-140
    self.normalHeight=115
    self.extendSpTag=113
    self.headTab={}
    self.workShopSoltTab={}
    self.tickTabCell={}
    self.upgradeDialog=nil
    self.expandUITab={}
    
    self.noAtkLb=nil;
    self.sendBtn=nil;
    self.sendMenu=nil;
    local function speedListener(event,data)
        self:clearVar()
    end
    self.speedUpListener=speedListener
    eventDispatcher:addEventListener("workshopslot.speedup",self.speedUpListener)
    return nc
end

--设置或修改每个Tab页签
function workshopDialog:resetTab()
    local index=0
    local tbNum = SizeOfTable(self.allTabs)
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if tbNum==3 then
           if index==0 then
           tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
           elseif index==1 then
           tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
           elseif index==2 then
           tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
           end
         else
           if index==0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
           elseif index==1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
           end
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    if buildingVoApi:getBuildiingVoByBId(self.bid).level<1 then
        local index=0
        for k,v in pairs(self.allTabs) do
          local  tabBtnItem=v
          if index==1 then
             tabBtnItem:setVisible(false)
          elseif index==2 then
             tabBtnItem:setVisible(false)
          end
          index=index+1
        end
    end
    
    self:noProduceTank()
    self:judgeProduceTank()
end

function workshopDialog:judgeProduceTank()
    if self.selectedTabIndex==2 then
        if SizeOfTable(workShopSlotVoApi:getAllSolts())==0 then
            self.noAtkLb:setVisible(true)
            self.sendMenu:setVisible(true)
            
        else
            self.noAtkLb:setVisible(false)
            self.sendMenu:setVisible(false)
        end
    else
        self.noAtkLb:setVisible(false)
        self.sendMenu:setVisible(false)
    end
end
function workshopDialog:noProduceTank()

         self.noAtkLb=GetTTFLabelWrap(getlocal("noProduceItem"),24,CCSizeMake(500, 100),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        --self.noAtkLb=GetTTFLabel(getlocal("jumpToWorld"),25);
        self.noAtkLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2));
        self.noAtkLb:setColor(ccc3(144,144,144))
        self.bgLayer:addChild(self.noAtkLb)
        
        local function sendHandler()
            local tbNum = SizeOfTable(self.allTabs)
            if tbNum==3 then
              self:tabClick(1)
            else
              self:tabClick(0)
            end
            
        end
        self.sendBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",sendHandler,nil,getlocal("jumpButton"),25)
        self.sendMenu=CCMenu:createWithItem(self.sendBtn)
        self.sendMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-200))
        self.sendMenu:setTouchPriority(-(self.layerNum-1)*20-5)
        self.bgLayer:addChild(self.sendMenu,2)
        
        self.noAtkLb:setVisible(false)
        self.sendMenu:setVisible(false)

        if SizeOfTable(workShopSlotVoApi:getAllSolts())>0 then
            self.noAtkLb:setVisible(false)
            self.sendMenu:setVisible(false)
        else
            self.noAtkLb:setVisible(true)
            self.sendMenu:setVisible(true)

        end

end

--设置对话框里的tableView
function workshopDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-41)
    --self.tv:setTableViewTouchPriority(-43)
    self.tv:setTableViewTouchPriority(1)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    self.workShopTab=workShopApi:getWorkShopResources()
    self.workShopSoltTab=workShopSlotVoApi:getAllSolts();

    local tbNum = SizeOfTable(self.allTabs)
    if tbNum==3 then
    else
      self.selectedTabIndex=1
      self:clearVar()
      self.tv:setTableViewTouchPriority(-43)
    end
    
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function workshopDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       if self.selectedTabIndex==0 then
           return 1
       elseif self.selectedTabIndex==1 then
            return SizeOfTable(self.workShopTab)
       elseif self.selectedTabIndex==2 then
            return SizeOfTable(self.workShopSoltTab)
       end

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       if self.selectedTabIndex==0 then
           tmpSize=CCSizeMake(600,self.expandHeight)
           
       elseif self.selectedTabIndex==1 then
           if self.expandIdx["k"..idx]~=nil then
              tmpSize=CCSizeMake(600,self.expandHeight)
           else
              tmpSize=CCSizeMake(600,self.normalHeight)
           end
       elseif self.selectedTabIndex==2 then
           tmpSize=CCSizeMake(600,self.normalHeight)

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
            self:loadCCTableViewCell(cell,idx)
            return cell
       elseif self.selectedTabIndex==2 then
           local cell=CCTableViewCell:new()
           cell:autorelease()
           local rect = CCRect(0, 0, 50, 50);
           local capInSet = CCRect(20, 20, 10, 10);
           local function cellClick(hd,fn,idx)
               --return self:cellClick(idx)
           end

           local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
           backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
           backSprie:ignoreAnchorPointForPosition(false);
           backSprie:setAnchorPoint(ccp(0,0));
           backSprie:setTag(1000+idx)
           backSprie:setIsSallow(false)
           backSprie:setTouchPriority(-42)
           cell:addChild(backSprie,1)
           self.tickTabCell[idx+1]=cell

           local pid="p"..self.workShopSoltTab[idx+1].itemId
           local sprite = CCSprite:createWithSpriteFrameName(propCfg[pid].icon);
           sprite:setAnchorPoint(ccp(0,0.5));
           sprite:setPosition(20,backSprie:getContentSize().height/2)
           sprite:setScale(0.7)
           cell:addChild(sprite,2)
           
           local strName = getlocal(propCfg[pid].name).."*"..self.workShopSoltTab[idx+1].itemNum
           local lbName=GetTTFLabelWrap(strName,24,CCSizeMake(26*10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
           lbName:setColor(G_ColorGreen)
           lbName:setPosition(105,backSprie:getContentSize().height/2+30)
           lbName:setAnchorPoint(ccp(0,0.5));
           cell:addChild(lbName,2)

           local timeStr = GetTimeStr(workShopSlotVoApi:getLeftTimeAndTotalTimeBySlotid(tonumber(self.workShopSoltTab[idx+1].slotId)))
           AddProgramTimer(cell,ccp(240,backSprie:getContentSize().height/2-20),10,11,timeStr,"TeamTravelBarBg.png","TeamTravelBar.png",11,nil,nil,nil,nil,20)
            local ccprogress=cell:getChildByTag(10)
            ccprogress=tolua.cast(ccprogress,"CCProgressTimer")
            --区域战buff
            local buffValue=0
            if localWarVoApi then
                local buffType=8
                local buffTab=localWarVoApi:getSelfOffice()
                if G_getHasValue(buffTab,buffType)==true then
                    buffValue=G_getLocalWarBuffValue(buffType)
                end
            end
            local proTime=math.ceil(tonumber(self.workShopTab[idx+1].timeConsume)/(1+buffValue))
           local totalTime=proTime*self.workShopSoltTab[idx+1].itemNum
           
           local per = (totalTime-workShopSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.workShopSoltTab[idx+1].slotId))/totalTime*100
            ccprogress:setPercentage(per)
            
            
            local function touch1()
                PlayEffect(audioCfg.mouseClick)
                local function super()
                    if workShopSlotVoApi:getAllSolts()[idx+1]==nil then
                
                        ShowNOSpeed()
                        do
                            return
                        end
                    end
                    local result,reason=workShopApi:checkSuperProduceBeforeSendServer(self.workShopSoltTab[idx+1].slotId)
                    local propName=propCfg[pid].name

                    local name,pic,desc,id,index,eType,equipId,bgname = getItem(pid,"p")
                    local num=tonumber(self.workShopSoltTab[idx+1].itemNum)
                    local award={type="p",key=pid,pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
                    local reward={award}

                    if result==true then
                        local function serverSuperUpgrade(fn,data)
                              --local retTb=OBJDEF:decode(data)
                              if base:checkServerData(data)==true then  
                                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{getlocal(propName)}),28,nil,nil,reward)
                                  G_cancelPush("p".."_"..self.workShopSoltTab[idx+1].slotId,G_ItemProduceTag)

                                  self:clearVar()
                                      --self:tick()
                              end
                        end
                        
                        local pid=tonumber(self.workShopSoltTab[idx+1].itemId)
                        local nums=tonumber(self.workShopSoltTab[idx+1].itemNum)
                        local slotid=self.workShopSoltTab[idx+1].slotId
                        socketHelper:speedUpProps(slotid,pid,nums,serverSuperUpgrade)
                        
                        
                    else
                        if reson ==1 then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+1)
                        elseif reson==2 then
                            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("notEnoughGem"),nil,self.layerNum+1)
                            
                        end
                    
                    end
                end
                
                
                
                
                local leftTime=workShopSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.workShopSoltTab[idx+1].slotId)   
            local gems=TimeToGems(leftTime)
            local function buyGems()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                end
                vipVoApi:showRechargeDialog(self.layerNum+1)

            end
            if playerVo.gems<gems then
                
                local num=gems-playerVo.gems
                local smallD=smallDialog:new()
                     smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{gems,playerVo.gems,num}),nil,self.layerNum+1)
            else
                local smallD=smallDialog:new()
                     smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),super,getlocal("dialog_title_prompt"),getlocal("speedUp",{gems}),nil,self.layerNum+1)
            end
            
            end
            
            local function touch2()
                PlayEffect(audioCfg.mouseClick)
                local result,reason=workShopApi:checkCancleProduceBeforeSendServer(self.workShopSoltTab[idx+1].slotId)
                if result==true then
                
                    local function callBack()
                        if workShopSlotVoApi:getAllSolts()[idx+1]==nil then
                    
                            ShowNOCancel()
                            do
                                return
                            end
                        end
                       local function serverCancleUpgrade(fn,data)
                              --local retTb=OBJDEF:decode(data)
                              if base:checkServerData(data)==true then
                                    
                                  G_cancelPush("p".."_"..self.workShopSoltTab[idx+1].slotId,G_ItemProduceTag)
                                  workShopApi:cancleProduce(self.workShopSoltTab[idx+1].slotId)
                                  self:clearVar()
                              end
                        end
                        
                        local pid=tonumber(self.workShopSoltTab[idx+1].itemId)
                        local nums=tonumber(self.workShopSoltTab[idx+1].itemNum)
                        local slotid=self.workShopSoltTab[idx+1].slotId
                        socketHelper:cancelProps(slotid,pid,nums,serverCancleUpgrade)
                     end

                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("prop_produce_cancel_prompt"),nil,self.layerNum+1)
                end
            
            end
            
            
            local menuItem1 = GetButtonItem("yh_BtnRight.png","yh_BtnRight_Down.png","yh_BtnRight_Down.png",touch1,10,nil,nil)
            local menu1 = CCMenu:createWithItem(menuItem1);
            menu1:setPosition(ccp(530,backSprie:getContentSize().height/2));
            menu1:setTouchPriority(-42);
            cell:addChild(menu1,3);
            
            
            local menuItem2 = GetButtonItem("yh_BtnNo.png","yh_BtnNo_Down.png","yh_BtnNo_Down.png",touch2,11,nil,nil)
            local menu2 = CCMenu:createWithItem(menuItem2);
            menu2:setPosition(ccp(455,backSprie:getContentSize().height/2));
            menu2:setTouchPriority(-42);
            cell:addChild(menu2,3);
            
            if self.workShopSoltTab[idx+1].status==2 then
                menuItem1:setEnabled(false);
               local timeLb = ccprogress:getChildByTag(11)
               timeLb=tolua.cast(timeLb,"CCLabelTTF")
               timeLb:setString(getlocal("waiting"));
            
            end

            



           return cell;
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
function workshopDialog:tabClick(idx)
        PlayEffect(audioCfg.mouseClick)
        for k,v in pairs(self.allTabs) do
          local tabBtnLabel=tolua.cast(v:getChildByTag(31),"CCLabelTTF")  
         if v:getTag()==idx then
            v:setEnabled(false)
            local tbNum = SizeOfTable(self.allTabs)
            if tbNum==3 then
              self.selectedTabIndex=idx
            else
              self.selectedTabIndex=idx+1
            end
            if self.selectedTabIndex==0 then
                self.tv:setTableViewTouchPriority(1)
            else
                self.tv:setTableViewTouchPriority(-43)
            end
            self:clearVar()
            self:doUserHandler()
            
            tabBtnLabel:setColor(G_ColorWhite)
         else
            v:setEnabled(true)
            tabBtnLabel:setColor(G_TabLBColorGreen)
         end
         self:clearVar()
    end
    self:judgeProduceTank()
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function workshopDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function workshopDialog:cellClick(idx)
    if self.selectedTabIndex==2 then
        return
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
            if self.selectedTabIndex==1 then
              self.expandUITab[(idx-1000)+1]=nil
            end
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

--创建或刷新CCTableViewCell
function workshopDialog:loadCCTableViewCell(cell,idx,refresh)
       if self.selectedTabIndex==0 then
                self.upgradeDialog=buildingUpgradeCommon:new()
                self.upgradeDialog:init(cell,self.bgLayer,self.bid,self,nil,self.isShowPoint)
       else
       
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
                 return self:cellClick(idx)
           end
           local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
           headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
           headerSprie:ignoreAnchorPointForPosition(false);
           headerSprie:setAnchorPoint(ccp(0,0));
           headerSprie:setTag(1000+idx)
           headerSprie:setIsSallow(false)
           headerSprie:setTouchPriority(-42)
           headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
           cell:addChild(headerSprie)
           
           
           local m_index = tonumber(self.workShopTab[idx+1].sid)
           local lbName=GetTTFLabel(getlocal(self.workShopTab[idx+1].name),24,true)
           lbName:setColor(G_ColorGreen)
           lbName:setPosition(110,headerSprie:getContentSize().height/2+30)
           lbName:setAnchorPoint(ccp(0,0.5));
           headerSprie:addChild(lbName,2)
           
           local lbNum=GetTTFLabel(getlocal("propHave")..bagVoApi:getItemNumId(m_index),20)
           lbNum:setPosition(110,headerSprie:getContentSize().height/2+2)
           lbNum:setAnchorPoint(ccp(0,0.5));
           headerSprie:addChild(lbNum,2)
           
           local timeSp = CCSprite:createWithSpriteFrameName("IconTime.png");
           timeSp:setAnchorPoint(ccp(0,0.5));
           timeSp:setPosition(105,headerSprie:getContentSize().height/2-30)
           headerSprie:addChild(timeSp,2)

            --区域战buff
            local buffValue=0
            if localWarVoApi then
                local buffType=8
                local buffTab=localWarVoApi:getSelfOffice()
                if G_getHasValue(buffTab,buffType)==true then
                    buffValue=G_getLocalWarBuffValue(buffType)
                end
            end
            local proTime=math.ceil(tonumber(self.workShopTab[idx+1].timeConsume)/(1+buffValue))
           local lbTime=GetTTFLabel(GetTimeStr(proTime),20)
           lbTime:setPosition(155,headerSprie:getContentSize().height/2-30)
           lbTime:setAnchorPoint(ccp(0,0.5));
           headerSprie:addChild(lbTime,2)
           
           local sprite = CCSprite:createWithSpriteFrameName(self.workShopTab[idx+1].icon);
           sprite:setAnchorPoint(ccp(0,0.5));
           sprite:setPosition(20,headerSprie:getContentSize().height/2)
           sprite:setScale(0.7)
           headerSprie:addChild(sprite,2)
                  
                   
           --显示加减号
           local btn
           if expanded==false then
               btn=CCSprite:createWithSpriteFrameName("sYellowAddBtn.png")
           else
               btn=CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
           end
           btn:setScale(0.8)
           btn:setAnchorPoint(ccp(0,0.5))
           btn:setPosition(ccp(headerSprie:getContentSize().width-10-btn:getContentSize().width,headerSprie:getContentSize().height/2))
           headerSprie:addChild(btn)
           btn:setTag(self.extendSpTag)

           
           if expanded==true then --显示展开信息
              local rect = CCRect(0, 0, 50, 50);
                local capInSet = CCRect(20, 20, 10, 10);
                local function touchHander()
          
                end
                local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
                exBg:setAnchorPoint(ccp(0,0))
                exBg:setContentSize(CCSize(580,self.expandHeight-self.normalHeight-340))
                exBg:setPosition(ccp(0,220))
                exBg:setTag(2)
                cell:addChild(exBg)
                
                local sprite = CCSprite:createWithSpriteFrameName(self.workShopTab[idx+1].icon);
                sprite:setAnchorPoint(ccp(0,0.5));
                sprite:setScale(0.7)
                sprite:setPosition(20,exBg:getContentSize().height+60)
                exBg:addChild(sprite,2)

                local labelSize = CCSize(400, 100);
                local lbDescription=GetTTFLabelWrap(getlocal(self.workShopTab[idx+1].description),20,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                lbDescription:setPosition(120,exBg:getContentSize().height+60)
                lbDescription:setAnchorPoint(ccp(0,0.5));
                exBg:addChild(lbDescription,2)
                
                
                local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
                bgSp:setAnchorPoint(ccp(0,0.5));
                bgSp:setPosition(0,-40);
                exBg:addChild(bgSp,1);
                
                
                local timeSp = CCSprite:createWithSpriteFrameName("IconTime.png");
                timeSp:setAnchorPoint(ccp(0,0.5));
                timeSp:setPosition(30,-80)
                exBg:addChild(timeSp,2)
                
                self:exbgCellForId(idx,exBg,slider)
                
                

           end
       end

end

function workshopDialog:exbgCellForId(idx,container)
    
    local typeLb=GetTTFLabel(getlocal("resourceType"),20)
    typeLb:setAnchorPoint(ccp(0.5,0.5))
    typeLb:setPosition(ccp(150,container:getContentSize().height-40))
    container:addChild(typeLb)
    
    local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
    resourceLb:setAnchorPoint(ccp(0.5,0.5))
    resourceLb:setPosition(ccp(300,container:getContentSize().height-40))
    container:addChild(resourceLb)
  
    local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
    haveLb:setAnchorPoint(ccp(0.5,0.5))
    haveLb:setPosition(ccp(450,container:getContentSize().height-40))
    container:addChild(haveLb)
    
    local goldLb=GetTTFLabel(getlocal("money"),20)
    goldLb:setAnchorPoint(ccp(0.5,0.5))
    goldLb:setPosition(ccp(150,container:getContentSize().height-100))
    container:addChild(goldLb)
    
    local goldSp=CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
    goldSp:setAnchorPoint(ccp(0.5,0.5))
    goldSp:setPosition(ccp(40,container:getContentSize().height-100))
    goldSp:setScale(0.5)
    container:addChild(goldSp)
    
    local hLb=GetTTFLabel(getlocal("sample_prop_name_2021"),20)
    hLb:setAnchorPoint(ccp(0.5,0.5))
    hLb:setPosition(ccp(150,container:getContentSize().height-170))
    container:addChild(hLb)
    
    local hSp=CCSprite:createWithSpriteFrameName("item_xunzhang_02.png")
    hSp:setAnchorPoint(ccp(0.5,0.5))
    hSp:setPosition(ccp(40,container:getContentSize().height-170))
    hSp:setScale(0.5)
    container:addChild(hSp)
    
    local needGoldLb=GetTTFLabel(FormatNumber(self.workShopTab[idx+1].moneyConsume),20)
    needGoldLb:setAnchorPoint(ccp(0.5,0.5))
    needGoldLb:setPosition(ccp(300,container:getContentSize().height-100))
    container:addChild(needGoldLb)

    local haveGoldLb=GetTTFLabel(FormatNumber(playerVoApi:getGold()),20)
    haveGoldLb:setAnchorPoint(ccp(0.5,0.5))
    haveGoldLb:setPosition(ccp(450,container:getContentSize().height-100))
    container:addChild(haveGoldLb)

    local needHLb=GetTTFLabel(FormatNumber(self.workShopTab[idx+1].propConsume[2]),20)
    needHLb:setAnchorPoint(ccp(0.5,0.5))
    needHLb:setPosition(ccp(300,container:getContentSize().height-170))
    container:addChild(needHLb)

    local haveHLb=GetTTFLabel(FormatNumber(bagVoApi:getItemNumId(19)),20)
    haveHLb:setAnchorPoint(ccp(0.5,0.5))
    haveHLb:setPosition(ccp(450,container:getContentSize().height-170))
    container:addChild(haveHLb)
    
    
    
    local m_numLb=GetTTFLabel(" ",30)
    m_numLb:setPosition(68,-40);
    container:addChild(m_numLb,2);
    
    --区域战buff
    local buffValue=0
    if localWarVoApi then
        local buffType=8
        local buffTab=localWarVoApi:getSelfOffice()
        if G_getHasValue(buffTab,buffType)==true then
            buffValue=G_getLocalWarBuffValue(buffType)
        end
    end
    local proTime=math.ceil(tonumber(self.workShopTab[idx+1].timeConsume)/(1+buffValue))
    local lbTime=GetTTFLabel(GetTimeStr(proTime),20)
    lbTime:setPosition(70,-80)
    lbTime:setAnchorPoint(ccp(0,0.5));
    container:addChild(lbTime,2)

    local function sliderTouch(handler,object)
        local count = math.floor(object:getValue())
        m_numLb:setString(count)
        if count>0 then
         lbTime:setString(GetTimeStr(proTime*count))
         needGoldLb:setString(FormatNumber(self.workShopTab[idx+1].moneyConsume*count))
         needHLb:setString(FormatNumber(self.workShopTab[idx+1].propConsume[2]*count))
         
        end
        
        --object=tolua.cast(object,"LuaCCControlSlider")
        --object:setValue(math.floor(object:getValue()))

    end
    local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
    local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
    local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    slider:setTouchPriority(-42);
    slider:setIsSallow(true);
    
    slider:setMinimumValue(0.0);
    
    slider:setMaximumValue(100.0);
    
    slider:setValue(0);
    slider:setTag(99)
    slider:setPosition(ccp(355,-40))
    container:addChild(slider,2)
    m_numLb:setString(math.floor(slider:getValue()))
    
    


    
     local p1Sp;
      if bagVoApi:getItemNumId(19)>=tonumber(self.workShopTab[idx+1].propConsume[2]) then
         p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
      end
      p1Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p1Sp:setPosition(ccp(400,container:getContentSize().height-170))

    container:addChild(p1Sp)
    
    local p2Sp
      if tonumber(self.workShopTab[idx+1].moneyConsume)<=playerVoApi:getGold() then
         p2Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p2Sp=CCSprite:createWithSpriteFrameName("IconFault.png")

        local function callBack()
          smallDialog:showBuyResDialog(5,7)
        end
        local icon=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",callBack)
        icon:setTouchPriority(-(6-1)*20-1)
        icon:setPosition(ccp(510,container:getContentSize().height-100))
        container:addChild(icon)

        self.expandUITab[idx+1]={
          resLb=haveGoldLb,
          leftSp=p2Sp,
          slider=slider,
          numLb=m_numLb,
          rightSp=icon,
        }

      end
      p2Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p2Sp:setPosition(ccp(400,container:getContentSize().height-100))

    container:addChild(p2Sp)
    
    local function touch1()
        PlayEffect(audioCfg.mouseClick)
        local function doProduce()
            --成功添加并调网络接口告诉服务器开始生产
            local function serverUpgrade(fn,data)
                  if base:checkServerData(data)==true then
                    self:clearVar()
                    if tbNum==3 then
                      self:tabClick(2)
                    else
                      self:tabClick(1)
                    end
                    
                  end
            end
            local pid=tonumber(self.workShopTab[idx+1].sid)
            local nums=math.floor(tonumber(slider:getValue()))
            socketHelper:produceProps(pid,nums,serverUpgrade)
            bagVoApi:useItemNumId(19,nums)
        end
        local result,reson = workShopApi:checkUpgradeBeforeSendServer(tonumber(self.workShopTab[idx+1].sid),math.floor(tonumber(slider:getValue())))
        --reson 1:金币不足 2:勋章不足 3:队列不足
        if result==true then
            doProduce()
        else
            if reson ==1 or reson==2 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+1)
            
            elseif reson==3 then
                vipVoApi:showQueueFullDialog(5,self.layerNum+1,doProduce)
            end
        
        end
                
            
    end
    local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("startProduce"),28,100)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(460,-110));
    menu1:setTouchPriority(-42);
    container:addChild(menu1,3);
    local lb = menuItem1:getChildByTag(100)
    if lb then
      lb = tolua.cast(lb, "CCLabelTTF")
      lb:setFontName("Helvetica-bold")
    end
    
    if bagVoApi:getItemNumId(19)>=tonumber(self.workShopTab[idx+1].propConsume[2]) and tonumber(self.workShopTab[idx+1].moneyConsume)<=playerVoApi:getGold() then
        
        local tnum1=bagVoApi:getItemNumId(19)/tonumber(self.workShopTab[idx+1].propConsume[2])
        local num1 = math.floor(tnum1)
        
        local tnum2=playerVoApi:getGold()/tonumber(self.workShopTab[idx+1].moneyConsume)
        local num2 = math.floor(tnum2)
        if num1<num2 then
            if num1>100 then
                slider:setMaximumValue(100);
                slider:setMinimumValue(1);
            else
                slider:setMinimumValue(1.0);
                slider:setMaximumValue(num1);
                if num1==1 then
                    slider:setMaximumValue(1.0);
                end

            end
            
        else
            if num2>100 then
                slider:setMaximumValue(100);
                slider:setMinimumValue(1);
            else
                slider:setMinimumValue(1.0);
                slider:setMaximumValue(num2);
                if num2==1 then
                    slider:setMaximumValue(1.0);
                end

            end
        end
        
        --[[
        if num1==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
        else
            slider:setMinimumValue(1.0);
        end
   ]]
        slider:setValue(1);
        --slider:setMinimumValue(1.0);
        menuItem1:setEnabled(true)
    else
        slider:setMaximumValue(0);
        --slider:setMinimumValue(0);
        menuItem1:setEnabled(false)
        menu1:setTag(199)
    
    end
    
    local function touchAdd()
        if slider:getValue()+1<=slider:getMaximumValue() then
            slider:setValue(slider:getValue()+1);
        end
    end
    
    local function touchMinus()
        if slider:getValue()-1>0 then
            slider:setValue(slider:getValue()-1);
        end
    
    end
    
    local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
    addSp:setPosition(ccp(549,-40))
    container:addChild(addSp,1)
    addSp:setTouchPriority(-43);
    
    local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
    minusSp:setPosition(ccp(157,-40))
    container:addChild(minusSp,1)
    minusSp:setTouchPriority(-43);
    
    if self.expandUITab[idx+1]~=nil then
      self.expandUITab[idx+1].btn=menuItem1
    end
end

function workshopDialog:refreshUIData()
  if self.expandUITab and self.workShopTab then
    for i=1, SizeOfTable(self.workShopTab) do
      if self.expandUITab[i] then
        if self.expandUITab[i].resLb and tolua.cast(self.expandUITab[i].resLb,"CCLabelTTF") then
          local resLb = tolua.cast(self.expandUITab[i].resLb,"CCLabelTTF")
          resLb:setString(FormatNumber(playerVoApi:getGold()))
        end
        if tonumber(self.workShopTab[i].moneyConsume)<=playerVoApi:getGold() then
          if self.expandUITab[i].leftSp and tolua.cast(self.expandUITab[i].leftSp,"CCSprite") then
            local leftSp = tolua.cast(self.expandUITab[i].leftSp,"CCSprite")
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("IconCheck.png")
            if frame then
              leftSp:setDisplayFrame(frame)
            end
          end
          if self.expandUITab[i].rightSp and tolua.cast(self.expandUITab[i].rightSp,"CCSprite") then
            local rightSp = tolua.cast(self.expandUITab[i].rightSp,"CCSprite")
            rightSp:removeFromParentAndCleanup(true)
          end

          local slider = self.expandUITab[i].slider
          if slider then
            if bagVoApi:getItemNumId(19)>=tonumber(self.workShopTab[i].propConsume[2]) and tonumber(self.workShopTab[i].moneyConsume)<=playerVoApi:getGold() then
                local tnum1=bagVoApi:getItemNumId(19)/tonumber(self.workShopTab[i].propConsume[2])
                local num1 = math.floor(tnum1)
                
                local tnum2=playerVoApi:getGold()/tonumber(self.workShopTab[i].moneyConsume)
                local num2 = math.floor(tnum2)
                if num1<num2 then
                    if num1>100 then
                        slider:setMaximumValue(100);
                        slider:setMinimumValue(1);
                    else
                        slider:setMinimumValue(1.0);
                        slider:setMaximumValue(num1);
                        if num1==1 then
                            slider:setMaximumValue(1.0);
                        end

                    end
                    
                else
                    if num2>100 then
                        slider:setMaximumValue(100);
                        slider:setMinimumValue(1);
                    else
                        slider:setMinimumValue(1.0);
                        slider:setMaximumValue(num2);
                        if num2==1 then
                            slider:setMaximumValue(1.0);
                        end

                    end
                end
                
                slider:setValue(1);
                if self.expandUITab[i].btn then
                  self.expandUITab[i].btn:setEnabled(true)
                end
            end

            if self.expandUITab[i].numLb and tolua.cast(self.expandUITab[i].numLb,"CCLabelTTF") then
              local numLb = tolua.cast(self.expandUITab[i].numLb,"CCLabelTTF")
              numLb:setString(math.floor(slider:getValue()))
            end
          end

          self.expandUITab[i]=nil
        end
      end
    end
  end
end

function workshopDialog:tick()
  self:judgeProduceTank()
    if buildingVoApi:getBuildiingVoByBId(self.bid).level>0 then
        for k,v in pairs(self.allTabs) do
          local  tabBtnItem=v
            tabBtnItem:setVisible(true)
        end
    end
    if self.selectedTabIndex==0 then
        self.upgradeDialog:tick()
    elseif self.selectedTabIndex==1 then
        self:refreshUIData()
    elseif self.selectedTabIndex==2 then
        self.workShopSoltTab=workShopSlotVoApi:getAllSolts()
        for k,v in pairs(self.tickTabCell) do 
            
            if SizeOfTable(workShopSlotVoApi:getAllSolts())==0 then
                self:clearVar()
                do
                    return
                end
            end
            if workShopSlotVoApi:getSlotBySlotid(self.workShopSoltTab[k].slotId)==nil then
                    self:clearVar()
                    do
                    return
                    end
            end
           if self.workShopSoltTab[k].status==1 then
                
                local cell = self.tickTabCell[k]
                local ccprogress=cell:getChildByTag(10)
                ccprogress=tolua.cast(ccprogress,"CCProgressTimer")
                local leftTime,totalTime= workShopSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.workShopSoltTab[k].slotId)
                --区域战buff
                local buffValue=0
                if localWarVoApi then
                    local buffType=8
                    local buffTab=localWarVoApi:getSelfOffice()
                    if G_getHasValue(buffTab,buffType)==true then
                        buffValue=G_getLocalWarBuffValue(buffType)
                    end
                end
                totalTime=math.ceil(tonumber(totalTime/(1+buffValue)))
                
                local per = (totalTime-leftTime)/totalTime*100
                 ccprogress:setPercentage(per)
                 
                 local timeLb = ccprogress:getChildByTag(11)
                 timeLb=tolua.cast(timeLb,"CCLabelTTF")
                 local strTime= GetTimeStr(workShopSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.workShopSoltTab[k].slotId))
                 timeLb:setString(strTime)
                 if leftTime<=0 then
                    
                    self:clearVar()

                 end
            end

        end
        
    end
    
end


function workshopDialog:clearVar()
    self.workShopSoltTab={}
    self.workShopSoltTab=workShopSlotVoApi:getAllSolts();
    self.tickTabCell={}
    if(self.tv)then
        self.tv:reloadData()
    end
end

function workshopDialog:dispose()
    self.isShowPoint=nil
    self.expandIdx=nil
    self.islandStateTab=nil
    self.expandHeight=nil
    self.normalHeight=nil
    self.extendSpTag=nil
    self.headTab=nil
    self.expandUITab=nil
    self.upgradeDialog:dispose()
      self.upgradeDialog=nil
    eventDispatcher:removeEventListener("workshopslot.speedup",self.speedUpListener)
    self=nil
end




