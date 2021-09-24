--require "luascript/script/componet/commonDialog"
tankTuningDialog=commonDialog:new()

function tankTuningDialog:new(bid,isShowPoint)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bid=bid
    self.isShowPoint=isShowPoint
    self.leftBtn=nil
    self.expandIdx={}
    self.expandHeight2=G_VisibleSize.height-156
    if G_isIphone5() then
       self.expandHeight=G_VisibleSize.height-156
    else
       self.expandHeight=1136-230
    end
    
    self.normalHeight=115
    self.extendSpTag=113
    self.headTab={}
    self.tankSoltTab={}
    self.tankResultTypeTab={}
    self.tankResultLockTab={}
    self.tankResultCountTab={}
    self.tankResultLevelTab={}
    self.tickTabCell={}
    self.tickNumLbTab={}
    self.expandUITab={}
    self.noAtkLb=nil;
    self.sendBtn=nil;
    self.sendMenu=nil;

    self.upgradeDialog=nil
    self.speedUpSmallDialog = nil
    local function speedListener(event,data)
        self:clearVar()
    end
    self.speedUpListener=speedListener
    eventDispatcher:addEventListener("tankslot.speedup",self.speedUpListener)
    return nc
end

--设置或修改每个Tab页签
function tankTuningDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
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
function tankTuningDialog:judgeProduceTank()
    if self.selectedTabIndex==2 then
        if SizeOfTable(tankUpgradeSlotVoApi:getAllSolts(self.bid))==0 then
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
function tankTuningDialog:noProduceTank()

         self.noAtkLb=GetTTFLabelWrap(getlocal("noSmeltTank"),24,CCSizeMake(500, 100),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        --self.noAtkLb=GetTTFLabel(getlocal("jumpToWorld"),25);
        self.noAtkLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2));
        self.noAtkLb:setColor(ccc3(144,144,144))
        self.bgLayer:addChild(self.noAtkLb)
        
        local function sendHandler()
            self:tabClick(1)
        end
        self.sendBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",sendHandler,nil,getlocal("jumpButton"),25)
        self.sendMenu=CCMenu:createWithItem(self.sendBtn)
        self.sendMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-200))
        self.sendMenu:setTouchPriority(-(self.layerNum-1)*20-5)
        self.bgLayer:addChild(self.sendMenu,2)
        
        self.noAtkLb:setVisible(false)
        self.sendMenu:setVisible(false)

        if SizeOfTable(tankUpgradeSlotVoApi:getAllSolts(self.bid))>0 then
            self.noAtkLb:setVisible(false)
            self.sendMenu:setVisible(false)
        else
            self.noAtkLb:setVisible(true)
            self.sendMenu:setVisible(true)

        end

end
--设置对话框里的tableView
function tankTuningDialog:initTableView()
    self.maxRemakeNum=200
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setTableViewTouchPriority(1)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    self.tankSoltTab=tankUpgradeSlotVoApi:getAllSolts(self.bid)
    --把用到的表 赋值下
    self:againAssignmentTab()
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function tankTuningDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       if self.selectedTabIndex==0 then
           return 1
       elseif self.selectedTabIndex==1 then
            return SizeOfTable(self.tankResultTypeTab)
       elseif self.selectedTabIndex==2 then
            return SizeOfTable(self.tankSoltTab)
       end

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       if self.selectedTabIndex==0 then
           tmpSize=CCSizeMake(600,self.expandHeight2)
           
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
           backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
           cell:addChild(backSprie,1)
           self.tickTabCell[idx+1]=cell


           local sprite = tankVoApi:getTankIconSp(tonumber(self.tankSoltTab[idx+1].itemId))--CCSprite:createWithSpriteFrameName(tankCfg[tonumber(self.tankSoltTab[idx+1].itemId)].icon);
           sprite:setAnchorPoint(ccp(0,0.5));
           sprite:setPosition(20,backSprie:getContentSize().height/2)
           sprite:setScale(0.5)
           cell:addChild(sprite,2)
           
           local strName = getlocal(tankCfg[tonumber(self.tankSoltTab[idx+1].itemId)].name).."*"..self.tankSoltTab[idx+1].itemNum
           --local lbName=GetTTFLabel(strName,26)
            local lbName=GetTTFLabelWrap(strName,24,CCSizeMake(26*10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
            lbName:setColor(G_ColorGreen)

           lbName:setPosition(105,backSprie:getContentSize().height/2+30)
           lbName:setAnchorPoint(ccp(0,0.5));
           cell:addChild(lbName,2)
           
           local leftTime,totalTime=tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.bid,tonumber(self.tankSoltTab[idx+1].slotId))

           local timeStr = GetTimeStr(leftTime)
           AddProgramTimer(cell,ccp(240,backSprie:getContentSize().height/2-20),10,11,timeStr,"TeamTravelBarBg.png","TeamTravelBar.png",11,nil,nil,nil,nil,20)
            local ccprogress=cell:getChildByTag(10)
            ccprogress=tolua.cast(ccprogress,"CCProgressTimer")
           
           local per = (totalTime-leftTime)/totalTime*100
            ccprogress:setPercentage(per)
                
                
            local function touch1()
                PlayEffect(audioCfg.mouseClick)
                local function superCreateHandler()
                    local function super()
                        if tankUpgradeSlotVoApi:getAllSolts(self.bid)[idx+1]==nil then
                    
                            ShowNOSpeed()
                            do
                                return
                            end
                        end
                        local result,reason=tankVoApi:checkUpgradeReBeforeSendServer(self.bid,self.tankSoltTab[idx+1].slotId)
                        local tankName=getlocal(tankCfg[tankUpgradeSlotVoApi:getSlotBySlotid(self.bid,self.tankSoltTab[idx+1].slotId).itemId].name)

                        local name,pic,desc,id,index,eType,equipId,bgname = getItem(self.tankSoltTab[idx+1].itemId,"o")
                        local num=tonumber(self.tankSoltTab[idx+1].itemNum)
                        local award={type="o",key="a" .. self.tankSoltTab[idx+1].itemId,pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
                        local reward={award}

                        if result==true then
                            self:clearVar()
                            local function serverSuperUpgrade(fn,data)
                              --local retTb=OBJDEF:decode(data)

                              if base:checkServerData(data)==true then
                                --tankVoApi:superUpgrade(self.bid,self.tankSoltTab[idx+1].slotId)
                                if self.speedUpSmallDialog ~= nil then
                                    self.speedUpSmallDialog:close()
                                    self.speedUpSmallDialog = nil
                                end
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptProduceFinish",{tankName}),28,nil,nil,reward)
                                G_cancelPush("t"..self.bid.."_"..self.tankSoltTab[idx+1].slotId,G_TankUpgradeTag)
                            tankVoApi:cancleUpgrade(self.bid,self.tankSoltTab[idx+1].slotId)
                                self:clearVar()
                                --self:tabClick(2)
                              end
                            end
                            local tid=tonumber(self.tankSoltTab[idx+1].itemId)
                            local nums=tonumber(self.tankSoltTab[idx+1].itemNum)
                            local slotid=tonumber(self.tankSoltTab[idx+1].slotId)
                            socketHelper:speedupUpgradeTanks(self.bid,slotid,tid,nums,serverSuperUpgrade)

                        else
                            if reson ==1 then
                            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+2)
                            elseif reson==2 then
                                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("notEnoughGem"),nil,self.layerNum+2)
                                
                            end
                        
                        end

                    end
                    local leftTime,totalTime=tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.bid,tonumber(self.tankSoltTab[idx+1].slotId))   
                    local gems=TimeToGems(leftTime)
                    local function buyGems()
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        end
                       vipVoApi:showRechargeDialog(self.layerNum+2)

                    end
                    if playerVo.gems<gems then
                        
                        local num=gems-playerVo.gems
                        local smallD=smallDialog:new()
                             smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{gems,playerVo.gems,num}),nil,self.layerNum+2)
                    else
                        local smallD=smallDialog:new()
                             smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),super,getlocal("dialog_title_prompt"),getlocal("speedUp",{gems}),nil,self.layerNum+2)
                    end
                end
                --使用加速道具
                if base.speedUpPropSwitch == 1 and newGuidMgr:isNewGuiding() ~= true then
                    if self.speedUpSmallDialog ~= nil then
                        self.speedUpSmallDialog:close()
                        self.speedUpSmallDialog = nil
                    end
                    require "luascript/script/componet/speedUpPropSmallDialog"
                    self.speedUpSmallDialog=speedUpPropSmallDialog:new(4,{self.bid,self.tankSoltTab[idx+1].slotId},superCreateHandler)
                    self.speedUpSmallDialog:init(self.layerNum+1)
                else
                    superCreateHandler()
                end
            end
            
            local function touch2()
                PlayEffect(audioCfg.mouseClick)
                local function callBack()
                    if tankUpgradeSlotVoApi:getAllSolts(self.bid)[idx+1]==nil then
                
                        ShowNOCancel()
                        do
                            return
                        end
                    end
                    local function serverCancle(fn,data)
                    --local retTb=OBJDEF:decode(data)

                      if base:checkServerData(data)==true then
                        G_cancelPush("t"..self.bid.."_"..self.tankSoltTab[idx+1].slotId,G_TankUpgradeTag)
                        tankVoApi:cancleUpgrade(self.bid,self.tankSoltTab[idx+1].slotId)
                        self:clearVar()

                      end

                    end
                    local tid=tonumber(self.tankSoltTab[idx+1].itemId)
                    local nums=tonumber(self.tankSoltTab[idx+1].itemNum)
                    local slotid=tonumber(self.tankSoltTab[idx+1].slotId)
                    socketHelper:cancelUpgradeTanks(self.bid,slotid,tid,nums,serverCancle)

                end
                
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("tankremake_returnResTip",{playerCfg.cancleReturnRate*100,playerCfg.cancleReturnPropRate*100}),nil,self.layerNum+1)
            
            end
            
            
            local menuItem1 = GetButtonItem("yh_BtnRight.png","yh_BtnRight_Down.png","yh_BtnRight_Down.png",touch1,10,nil,nil)
            local menu1 = CCMenu:createWithItem(menuItem1);
            menu1:setPosition(ccp(530,backSprie:getContentSize().height/2));
            menu1:setTouchPriority(-(self.layerNum-1)*20-2);
            cell:addChild(menu1,3);
            
            
            local menuItem2 = GetButtonItem("yh_BtnNo.png","yh_BtnNo_Down.png","yh_BtnNo_Down.png",touch2,11,nil,nil)
            local menu2 = CCMenu:createWithItem(menuItem2);
            menu2:setPosition(ccp(455,backSprie:getContentSize().height/2));
            menu2:setTouchPriority(-(self.layerNum-1)*20-2);
            cell:addChild(menu2,3);
            
            if self.tankSoltTab[idx+1].status==2 then
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
function tankTuningDialog:tabClick(idx)
        PlayEffect(audioCfg.mouseClick)
        for k,v in pairs(self.allTabs) do
          local tabBtnLabel=tolua.cast(v:getChildByTag(31),"CCLabelTTF")  
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            if self.selectedTabIndex==0 then
                self.tv:setTableViewTouchPriority(1)
            else
                self.tv:setTableViewTouchPriority(-43)
            end
            tabBtnLabel:setColor(G_ColorWhite)
         else
            v:setEnabled(true)
            tabBtnLabel:setColor(G_TabLBColorGreen)
         end
         
    end
  if self.selectedTabIndex==1 then
    self.normalHeight=115
  elseif self.selectedTabIndex==2 then
    self.normalHeight=115
  end

    self:judgeProduceTank()
    self:againAssignmentTab()
    self:clearVar()
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function tankTuningDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function tankTuningDialog:cellClick(idx)
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
function tankTuningDialog:loadCCTableViewCell(cell,idx,refresh)
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

                 if self.tankResultLockTab[idx-1000+1]==0 then
                    return self:cellClick(idx)
                 end
           end
           local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
           headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
           headerSprie:ignoreAnchorPointForPosition(false);
           headerSprie:setAnchorPoint(ccp(0,0));
           headerSprie:setTag(1000+idx)
           headerSprie:setIsSallow(false)
           headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
           headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
           cell:addChild(headerSprie)
           
           
           local m_tankIndex = self.tankResultTypeTab[idx+1]
           local lbName=GetTTFLabel(getlocal(tankCfg[m_tankIndex].name),24,true)
           lbName:setPosition(120,headerSprie:getContentSize().height/2+30)
           lbName:setAnchorPoint(ccp(0,0.5));
           headerSprie:addChild(lbName,2)
           lbName:setColor(G_ColorGreen)


           local r1Num=playerVoApi:getR1()
           local r2Num=playerVoApi:getR2()
           local r3Num=playerVoApi:getR3()
           local r4Num=playerVoApi:getR4()
           local need1Num=tonumber(tankCfg[m_tankIndex].upgradeMetalConsume)
           local need2Num=tonumber(tankCfg[m_tankIndex].upgradeOilConsume)
           local need3Num=tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume)
           local need4Num=tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume)

            local num1 = math.floor(r1Num/need1Num)
            local num2 = math.floor(r2Num/need2Num)
            local num3 = math.floor(r3Num/need3Num)
            local num4 = math.floor(r4Num/need4Num)

            local haveTankNum1=tankVoApi:getTankCountByItemId(m_tankIndex-1)
            local haveTankNum2=tankVoApi:getTankCountByItemId(m_tankIndex-1+40000)
            local haveTankNum=haveTankNum1+haveTankNum2

            local numTab = {num1,num2,num3,num4,haveTankNum}

            table.sort(numTab,function(a,b) return a<b end)
            local maxNum=numTab[1]
            -- if numTab[1]>100 then
            --   maxNum=100
            -- end
            
           -- local lbNum=GetTTFLabel(getlocal("schedule_ship_num",{self.tankResultCountTab[idx+1]}),22)
           local lbNum=GetTTFLabel(getlocal("can_smelt_num",{maxNum}),20)
           lbNum:setPosition(120,headerSprie:getContentSize().height/2)
           lbNum:setAnchorPoint(ccp(0,0.5));
           headerSprie:addChild(lbNum,2)
           self.tickNumLbTab[m_tankIndex]=lbNum
           
           
           
           local sprite = tankVoApi:getTankIconSp(m_tankIndex)--CCSprite:createWithSpriteFrameName(tankCfg[m_tankIndex].icon);
           sprite:setAnchorPoint(ccp(0,0.5));
           sprite:setPosition(20,headerSprie:getContentSize().height/2)
           sprite:setScale(0.5)
           headerSprie:addChild(sprite,2)
                  
           if self.tankResultLockTab[idx+1]==0 then
               --显示加减号
               local btn
               if expanded==false then
                   if r1Num<need1Num or
                    r2Num<need2Num or
                    r3Num<need3Num or
                    r4Num<need4Num then
                        btn=GraySprite:createWithSpriteFrameName("sYellowAddBtn.png")
                   else
                        btn=CCSprite:createWithSpriteFrameName("sYellowAddBtn.png")
                   end

               else
                   if r1Num<need1Num or
                    r2Num<need2Num or
                    r3Num<need3Num or
                    r4Num<need4Num then
                        btn=GraySprite:createWithSpriteFrameName("sYellowSubBtn.png")
                        self.expandUITab[idx+1]={
                            cellBtn=btn,
                        }
                   else
                        btn=CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
                   end

               end
               btn:setScale(0.8)
               btn:setAnchorPoint(ccp(0,0.5))
               btn:setPosition(ccp(headerSprie:getContentSize().width-10-btn:getContentSize().width,headerSprie:getContentSize().height/2))
               headerSprie:addChild(btn)
               btn:setTag(self.extendSpTag)
               
               local timeSp = CCSprite:createWithSpriteFrameName("IconTime.png");
               timeSp:setAnchorPoint(ccp(0,0.5));
               timeSp:setPosition(115,headerSprie:getContentSize().height/2-30)
               headerSprie:addChild(timeSp,2)
               -- local refitTankSpeed=playerCfg.refitTankSpeed[playerVoApi:getVipLevel()+1]
               -- local timeConsume=math.ceil(tonumber(tankCfg[m_tankIndex].upgradeTimeConsume)/(1+(buildingVoApi:getBuildiingVoByBId(self.bid).level-1)*0.05+refitTankSpeed));
               local timeConsume=tankVoApi:getTankUpgradeTime(m_tankIndex,self.bid)

               local lbTime=GetTTFLabel(GetTimeStr(tonumber(timeConsume)),20)
               lbTime:setPosition(165,headerSprie:getContentSize().height/2-30)
               lbTime:setAnchorPoint(ccp(0,0.5));
               headerSprie:addChild(lbTime,2)
           else
               local tsLb=GetTTFLabel(getlocal("chuanwu_level_require",{self.tankResultLockTab[idx+1]}),20)
               tsLb:setColor(G_ColorRed)
               tsLb:setTag(30)
               tsLb:setAnchorPoint(ccp(0,0))
               tsLb:setPosition(ccp(120,headerSprie:getContentSize().height/2-40))
               headerSprie:addChild(tsLb)

           
           end
           
  
           if expanded==true then --显示展开信息
              local rect = CCRect(0, 0, 50, 50);
                local capInSet = CCRect(20, 20, 10, 10);
                local function touchHander()
          
                end
                local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
                exBg:setAnchorPoint(ccp(0,0))
                exBg:setContentSize(CCSize(580,self.expandHeight-self.normalHeight-280-20))
                exBg:setPosition(ccp(0,180))
                exBg:setTag(2)
                cell:addChild(exBg)
                local m_tankIndex = self.tankResultTypeTab[idx+1]
                local spriteIcon = tankVoApi:getTankIconSp(m_tankIndex)--CCSprite:createWithSpriteFrameName(tankCfg[m_tankIndex].icon);
                spriteIcon:setAnchorPoint(ccp(0,0.5));
                spriteIcon:setScale(0.5)
                spriteIcon:setPosition(20,exBg:getContentSize().height+60)
                exBg:addChild(spriteIcon,2)

                local function touchInfo()
                    --[[
                    local td=smallDialog:new()
                    local dialog=td:initBackGround("panelBg.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1)
                    dialog:setPosition(getCenterPoint(sceneGame))
                    sceneGame:addChild(dialog,4)
                    td:show()
                    ]]
                    PlayEffect(audioCfg.mouseClick)
                    tankInfoDialog:create(exBg,m_tankIndex,self.layerNum+1)
                    
                
                end

                local menuItemInfo = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,11,nil,nil)
                local menuInfo = CCMenu:createWithItem(menuItemInfo);
                menuInfo:setPosition(ccp(520,exBg:getContentSize().height+50));
                menuInfo:setTouchPriority(-(self.layerNum-1)*20-2);
                exBg:addChild(menuInfo,3);
                
                local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
                local iconScale= 50/lifeSp:getContentSize().width
                lifeSp:setAnchorPoint(ccp(0,0.5));
                lifeSp:setPosition(120,exBg:getContentSize().height+90)
                exBg:addChild(lifeSp,2)
                lifeSp:setScale(iconScale)
                
                local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
                attackSp:setAnchorPoint(ccp(0,0.5));
                attackSp:setPosition(280,exBg:getContentSize().height+90)
                exBg:addChild(attackSp,2)
                attackSp:setScale(iconScale)
                
                local typeStr = "pro_ship_attacktype_"..tankCfg[m_tankIndex].attackNum

                local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
                attackTypeSp:setAnchorPoint(ccp(0,0.5));
                attackTypeSp:setPosition(120,exBg:getContentSize().height+35)
                exBg:addChild(attackTypeSp,2)
                attackTypeSp:setScale(iconScale)
                
                local lifeLb=GetTTFLabel(tankCfg[m_tankIndex].life,20)
                lifeLb:setAnchorPoint(ccp(0,0.5))
                lifeLb:setPosition(ccp(180,exBg:getContentSize().height+90))
                exBg:addChild(lifeLb)
                
                local attLb=GetTTFLabel(tankCfg[m_tankIndex].attack,20)
                attLb:setAnchorPoint(ccp(0,0.5))
                attLb:setPosition(ccp(340,exBg:getContentSize().height+90))
                exBg:addChild(attLb)
                
                local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),20,CCSizeMake(24*10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                attTypeLb:setAnchorPoint(ccp(0,0.5))
                attTypeLb:setPosition(ccp(180,exBg:getContentSize().height+35))
                exBg:addChild(attTypeLb)
                
                
                local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
                bgSp:setAnchorPoint(ccp(0,0.5));
                bgSp:setPosition(0,-30);
                exBg:addChild(bgSp,1);
                
                
                local timeSp = CCSprite:createWithSpriteFrameName("IconTime.png");
                timeSp:setAnchorPoint(ccp(0,0.5));
                timeSp:setPosition(30,-80)
                exBg:addChild(timeSp,2)
                
                self:exbgCellForId1(idx,exBg)
                
                

           end
       end

end

function tankTuningDialog:exbgCellForId1(idx,container)
  local m_tankIndex = self.tankResultTypeTab[idx+1]
  local addH=11;
  local reR1,reR2,reR3,reR4,reUpgradedTime = tankVoApi:getUpgradedTankResources(m_tankIndex)
  local haveTankNum1=tankVoApi:getTankCountByItemId(m_tankIndex-1)
  local haveTankNum2=tankVoApi:getTankCountByItemId(m_tankIndex-1+40000)
  local haveTankNum=haveTankNum1+haveTankNum2
  print("haveTankNum,haveTankNum2",haveTankNum,haveTankNum2)
  local typeLb=GetTTFLabel(getlocal("resourceType"),20)
  typeLb:setAnchorPoint(ccp(0.5,0.5))
  typeLb:setPosition(ccp(150,container:getContentSize().height-40+addH))
  container:addChild(typeLb)
  
  local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
  resourceLb:setAnchorPoint(ccp(0.5,0.5))
  resourceLb:setPosition(ccp(300,container:getContentSize().height-40+addH))
  container:addChild(resourceLb)

  local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
  haveLb:setAnchorPoint(ccp(0.5,0.5))
  haveLb:setPosition(ccp(450,container:getContentSize().height-40+addH))
  container:addChild(haveLb)
  

  

  local tb={
  {titleStr="metal",spName="resourse_normal_metal.png",needStr=FormatNumber(reR1),haveStr=FormatNumber(playerVoApi:getR1()),num1=playerVoApi:getR1(),num2=tonumber(tankCfg[m_tankIndex].upgradeMetalConsume)},
  {titleStr="oil",spName="resourse_normal_oil.png",needStr=FormatNumber(reR2),haveStr=FormatNumber(playerVoApi:getR2()),num1=playerVoApi:getR2(),num2=tonumber(tankCfg[m_tankIndex].upgradeOilConsume)},
  {titleStr="silicon",spName="resourse_normal_silicon.png",needStr=FormatNumber(reR3),haveStr=FormatNumber(playerVoApi:getR3()),num1=playerVoApi:getR3(),num2=tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume)},
  {titleStr="uranium",spName="resourse_normal_uranium.png",needStr=FormatNumber(reR4),haveStr=FormatNumber(playerVoApi:getR4()),num1=playerVoApi:getR4(),num2=tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume)},

    
  }
  if self.expandUITab[idx+1] then
      self.expandUITab[idx+1].resUITab={}
  end
  if tankCfg[m_tankIndex].upgradePropConsume~="" then
     local pid1 = tankCfg[m_tankIndex].upgradePropConsume[1][1]
     local pid2 = tankCfg[m_tankIndex].upgradePropConsume[2][1]
     local nameStr1=propCfg[pid1].name
     local numStr1=tankCfg[m_tankIndex].upgradePropConsume[1][2]
     local nameStr2=propCfg[pid2].name
     local numStr2=tankCfg[m_tankIndex].upgradePropConsume[2][2]


     local tb1={titleStr=nameStr1,spName=propCfg[pid1].icon,needStr=FormatNumber(numStr1),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1))),num2=tonumber(numStr1)}
     local tb2={titleStr=nameStr2,spName=propCfg[pid2].icon,needStr=FormatNumber(numStr2),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))),num2=tonumber(numStr2)}
     table.insert(tb,tb1)
     table.insert(tb,tb2)
  end
  local tb3={titleStr=tankCfg[m_tankIndex-1].name,spName=tankCfg[m_tankIndex-1].icon,needStr=1,haveStr=FormatNumber(haveTankNum),num1=haveTankNum,num2=1}
  table.insert(tb,tb3)


  local addy=60
  local countTb = {}

  for k,v in pairs(tb) do
      local r1Lb=GetTTFLabelWrap(getlocal(v.titleStr),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      r1Lb:setAnchorPoint(ccp(0.5,0.5))
      r1Lb:setPosition(ccp(150,container:getContentSize().height-100+addH-(k-1)*addy))
      container:addChild(r1Lb)

      local r1Sp=CCSprite:createWithSpriteFrameName(v.spName)
      r1Sp:setAnchorPoint(ccp(0.5,0.5))
      r1Sp:setPosition(ccp(40,container:getContentSize().height-100+addH-(k-1)*60))
      container:addChild(r1Sp)
      if v.titleStr==tankCfg[m_tankIndex-1].name then
        r1Sp:setScale(0.35)
      else
        r1Sp:setScale(0.5)
      end

      local needR1Lb=GetTTFLabel(v.needStr,20)
      needR1Lb:setAnchorPoint(ccp(0.5,0.5))
      needR1Lb:setPosition(ccp(300,container:getContentSize().height-100+addH-(k-1)*addy))
      container:addChild(needR1Lb)

      local haveR1Lb=GetTTFLabel(v.haveStr,20)
      haveR1Lb:setAnchorPoint(ccp(0.5,0.5))
      haveR1Lb:setPosition(ccp(450,container:getContentSize().height-100+addH-(k-1)*addy))
      container:addChild(haveR1Lb)

      local p1Sp;
      if v.num1>=v.num2 then
         p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")

        if k<=4 then
          local function callBack()
            smallDialog:showBuyResDialog(k,7)
          end
          local icon=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",callBack)
          icon:setTouchPriority(-(6-1)*20-1)
          icon:setPosition(ccp(510,container:getContentSize().height-100+addH-(k-1)*addy))
          container:addChild(icon)

          if self.expandUITab[idx+1] and self.expandUITab[idx+1].resUITab then
              self.expandUITab[idx+1].resUITab[k] = {
                  leftSp=p1Sp,
                  resLb=haveR1Lb,
                  rightSp=icon
              }
          end
        end
      end
      p1Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p1Sp:setPosition(ccp(400,container:getContentSize().height-100+addH-(k-1)*addy))

      container:addChild(p1Sp)
      countTb[k]=needR1Lb

      if k<=4 then
        if self.expandUITab[idx+1] and self.expandUITab[idx+1].resUITab then
            if self.expandUITab[idx+1].resUITab[k]==nil then
                self.expandUITab[idx+1].resUITab[k]={}
            end
            self.expandUITab[idx+1].resUITab[k].needLb=needR1Lb
        end
      end
  end


  local m_numLb=GetTTFLabel(" ",24)
  m_numLb:setPosition(70,-30);
  container:addChild(m_numLb,2);
  local m_tankIndex = self.tankResultTypeTab[idx+1]
  -- local refitTankSpeed=playerCfg.refitTankSpeed[playerVoApi:getVipLevel()+1]
  -- local timeConsume=math.ceil(tonumber(tankCfg[m_tankIndex].upgradeTimeConsume)/(1+(buildingVoApi:getBuildiingVoByBId(self.bid).level-1)*0.05+refitTankSpeed));
  local timeConsume=tankVoApi:getTankUpgradeTime(m_tankIndex,self.bid)
  
  local lbTime=GetTTFLabel(GetTimeStr(timeConsume),20)
  lbTime:setPosition(70,-80)
  lbTime:setAnchorPoint(ccp(0,0.5));
  container:addChild(lbTime,2)


  local function sliderTouch(handler,object)
      local count = math.floor(object:getValue())
      m_numLb:setString(count)
      if count>0 then
       lbTime:setString(GetTimeStr(timeConsume*count))
       for k,v in pairs(countTb) do
         v:setString(FormatNumber(tb[k].num2*count))
       end
           
      end

  end
  local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
  local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
  local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
  local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
  slider:setTouchPriority(-(self.layerNum-1)*20-2);
  slider:setIsSallow(true);
  
  slider:setMinimumValue(0.0);
  
  slider:setMaximumValue(self.maxRemakeNum);
  
  slider:setValue(0);
  slider:setPosition(ccp(355,-30))
  slider:setTag(99)
  container:addChild(slider,2)
  m_numLb:setString(math.floor(slider:getValue()))
  
  
  local function touchAdd()
      slider:setValue(slider:getValue()+1);
  end
  
  local function touchMinus()
      if slider:getValue()-1>0 then
          slider:setValue(slider:getValue()-1);
      end
  
  end
  
  local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
  addSp:setPosition(ccp(549,-30))
  container:addChild(addSp,1)
  addSp:setTouchPriority(-(self.layerNum-1)*20-3);
  
  local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
  minusSp:setPosition(ccp(157,-30))
  container:addChild(minusSp,1)
  minusSp:setTouchPriority(-(self.layerNum-1)*20-3);


  local function touch1()
        PlayEffect(audioCfg.mouseClick)
        local tid=tonumber(tankCfg[m_tankIndex].sid)
        local nums=math.floor(tonumber(slider:getValue()))
        local result,reson = tankVoApi:checkUpgradeResouceBeforeSendServer(self.bid,tid,nums)
        local tankNum1 = tankVoApi:getTankCountByItemId(tid-1)
        local tankNum2 = tankVoApi:getTankCountByItemId(tid-1+40000)

        local function doUpgrade()
            --成功添加
            local function serverUpgrade(fn,data)
                  --local retTb=OBJDEF:decode(data)

                  if base:checkServerData(data)==true then
                    --tankVoApi:refreshUpgradedTanks(tid,nums)
                    self:clearVar()
                    self:tabClick(2)

                  end
            end
            local enum=0
            if nums>tankNum1 then
              enum=nums-tankNum1
            end
            local function socketSend()
              socketHelper:upgradeTanks(self.bid,tid,nums,serverUpgrade,enum)
            end
            if enum>0 then
              smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),socketSend,getlocal("dialog_title_prompt"),getlocal("smelt_tip",{enum}),nil,self.layerNum+1)
            else
              socketSend()
            end
            
        end
        --reson 1:金币不足 2:队列不足
        if result==true then
            doUpgrade()
        else
            if reson ==1 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+1)
            elseif reson==2 then
                vipVoApi:showQueueFullDialog(3,self.layerNum+1,doUpgrade,self.bid)
            end
        
        end
                
            
    end
    local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("smelt"),28,100)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(460,-93));
    menu1:setTouchPriority(-(self.layerNum-1)*20-2);
    container:addChild(menu1,3);
    local lb = menuItem1:getChildByTag(100)
    if lb then
      lb = tolua.cast(lb,"CCLabelTTF")
      lb:setFontName("Helvetica-bold")
    end

    if tankCfg[m_tankIndex].upgradePropConsume~="" then
      local pid1 = tankCfg[m_tankIndex].upgradePropConsume[1][1]
      local pid2 = tankCfg[m_tankIndex].upgradePropConsume[2][1]
      local needP1 = tonumber(tankCfg[m_tankIndex].upgradePropConsume[1][2])
      local needP2 = tonumber(tankCfg[m_tankIndex].upgradePropConsume[2][2])
      local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
      local numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))) 

      if playerVoApi:getR1()>=tonumber(tankCfg[m_tankIndex].upgradeMetalConsume) and playerVoApi:getR2()>=tonumber(tankCfg[m_tankIndex].upgradeOilConsume) and playerVoApi:getR3()>=tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume) and playerVoApi:getR4()>=tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume) and
    haveTankNum>=1 and numP1>=1 and numP2>=1
     then
        
        local tnum1=playerVoApi:getR1()/tonumber(tankCfg[m_tankIndex].upgradeMetalConsume)
        local num1 = math.floor(tnum1)
        
        local tnum2=playerVoApi:getR2()/tonumber(tankCfg[m_tankIndex].upgradeOilConsume)
        local num2 = math.floor(tnum2)
        
        local tnum3=playerVoApi:getR3()/tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume)
        local num3 = math.floor(tnum3)
        
        local tnum4=playerVoApi:getR4()/tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume)
        local num4 = math.floor(tnum4)
        
        local num5 = haveTankNum
        
        local numTab = {num1,num2,num3,num4,num5}

        if tankCfg[m_tankIndex].upgradePropConsume~="" then
           local pid1 = tankCfg[m_tankIndex].upgradePropConsume[1][1]
           local pid2 = tankCfg[m_tankIndex].upgradePropConsume[2][1]
           local numP1 = math.floor(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))/needP1)
           local numP2 = math.floor(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2))))
           table.insert(numTab,numP1)
           table.insert(numTab,numP2)
        end

        table.sort(numTab,function(a,b) return a<b end)
        if numTab[1]>self.maxRemakeNum then

           slider:setMaximumValue(self.maxRemakeNum);
           
        else

           slider:setMaximumValue(numTab[1]);
           
        end
        
        if numTab[1]==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
        else
            slider:setMinimumValue(1.0);
        end
        
        if haveTankNum1>0 and haveTankNum1<numTab[1] then
          slider:setValue(haveTankNum1)
        else
          slider:setValue(numTab[1]);
        end
        menuItem1:setEnabled(true)
    else
        slider:setMaximumValue(0);
        menuItem1:setEnabled(false)
        menu1:setTag(199)
    
    end

    else
      if playerVoApi:getR1()>=tonumber(tankCfg[m_tankIndex].upgradeMetalConsume) and playerVoApi:getR2()>=tonumber(tankCfg[m_tankIndex].upgradeOilConsume) and playerVoApi:getR3()>=tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume) and playerVoApi:getR4()>=tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume) and
    haveTankNum>=1
     then
        
        local tnum1=playerVoApi:getR1()/tonumber(tankCfg[m_tankIndex].upgradeMetalConsume)
        local num1 = math.floor(tnum1)
        
        local tnum2=playerVoApi:getR2()/tonumber(tankCfg[m_tankIndex].upgradeOilConsume)
        local num2 = math.floor(tnum2)
        
        local tnum3=playerVoApi:getR3()/tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume)
        local num3 = math.floor(tnum3)
        
        local tnum4=playerVoApi:getR4()/tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume)
        local num4 = math.floor(tnum4)
        
        local num5 = haveTankNum
        
        local numTab = {num1,num2,num3,num4,num5}

        table.sort(numTab,function(a,b) return a<b end)
        if numTab[1]>self.maxRemakeNum then

           slider:setMaximumValue(self.maxRemakeNum);
           
        else

           slider:setMaximumValue(numTab[1]);
           
        end
        
        if numTab[1]==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
        else
            slider:setMinimumValue(1.0);
        end
        
        if haveTankNum1>0 and haveTankNum1<numTab[1] then
          slider:setValue(haveTankNum1)
        else
          slider:setValue(numTab[1]);
        end
        
        menuItem1:setEnabled(true)
    else
        slider:setMaximumValue(0);
        menuItem1:setEnabled(false)
        menu1:setTag(199)
    
    end

    end

    if self.expandUITab[idx+1] then
        self.expandUITab[idx+1].numLb=m_numLb
        self.expandUITab[idx+1].timeLb=lbTime
        self.expandUITab[idx+1].slider=slider
        self.expandUITab[idx+1].btn=menuItem1
    end

end

function tankTuningDialog:exbgCellForId(idx,container)
    
    local m_tankIndex = self.tankResultTypeTab[idx+1]
  local addH=11;
    
    local reR1,reR2,reR3,reR4,reUpgradedTime = tankVoApi:getUpgradedTankResources(m_tankIndex)

    local haveTankNum=tankVoApi:getTankCountByItemId(m_tankIndex-1)

    local typeLb=GetTTFLabel(getlocal("resourceType"),20)
    typeLb:setAnchorPoint(ccp(0.5,0.5))
    typeLb:setPosition(ccp(150,container:getContentSize().height-40+addH))
    container:addChild(typeLb)
    
    local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
    resourceLb:setAnchorPoint(ccp(0.5,0.5))
    resourceLb:setPosition(ccp(300,container:getContentSize().height-40+addH))
    container:addChild(resourceLb)
  
    local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
    haveLb:setAnchorPoint(ccp(0.5,0.5))
    haveLb:setPosition(ccp(450,container:getContentSize().height-40+addH))
    container:addChild(haveLb)
    

    local r1Lb=GetTTFLabelWrap(getlocal("metal"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    r1Lb:setAnchorPoint(ccp(0.5,0.5))
    r1Lb:setPosition(ccp(150,container:getContentSize().height-100+addH))
    container:addChild(r1Lb)
    
    local r2Lb=GetTTFLabelWrap(getlocal("oil"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    r2Lb:setAnchorPoint(ccp(0.5,0.5))
    r2Lb:setPosition(ccp(150,container:getContentSize().height-170+addH))
    container:addChild(r2Lb)
    
    local r3Lb=GetTTFLabelWrap(getlocal("silicon"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    r3Lb:setAnchorPoint(ccp(0.5,0.5))
    r3Lb:setPosition(ccp(150,container:getContentSize().height-240+addH))
    container:addChild(r3Lb)
    
    local r4Lb=GetTTFLabelWrap(getlocal("uranium"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    r4Lb:setAnchorPoint(ccp(0.5,0.5))
    r4Lb:setPosition(ccp(150,container:getContentSize().height-310+addH))
    container:addChild(r4Lb)
    
    local tankNameLb=GetTTFLabelWrap(getlocal(tankCfg[m_tankIndex-1].name),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tankNameLb:setAnchorPoint(ccp(0.5,0.5))
    tankNameLb:setPosition(ccp(150,container:getContentSize().height-380+addH))
    container:addChild(tankNameLb)
    
    
    
    local r1Sp=CCSprite:createWithSpriteFrameName("resourse_normal_metal.png")
    r1Sp:setAnchorPoint(ccp(0.5,0.5))
    r1Sp:setPosition(ccp(40,container:getContentSize().height-100+addH))
    r1Sp:setScale(0.5)
    container:addChild(r1Sp)
    
    local r2Sp=CCSprite:createWithSpriteFrameName("resourse_normal_oil.png")
    r2Sp:setAnchorPoint(ccp(0.5,0.5))
    r2Sp:setPosition(ccp(40,container:getContentSize().height-170+addH))
    r2Sp:setScale(0.5)
    container:addChild(r2Sp)
    
    local r3Sp=CCSprite:createWithSpriteFrameName("resourse_normal_silicon.png")
    r3Sp:setAnchorPoint(ccp(0.5,0.5))
    r3Sp:setPosition(ccp(40,container:getContentSize().height-240+addH))
    r3Sp:setScale(0.5)
    container:addChild(r3Sp)
    
    local r4Sp=CCSprite:createWithSpriteFrameName("resourse_normal_uranium.png")
    r4Sp:setAnchorPoint(ccp(0.5,0.5))
    r4Sp:setPosition(ccp(40,container:getContentSize().height-310+addH))
    r4Sp:setScale(0.5)
    container:addChild(r4Sp)
    
    local tankSp=tankVoApi:getTankIconSp(m_tankIndex-1)--CCSprite:createWithSpriteFrameName(tankCfg[m_tankIndex-1].icon)
    tankSp:setAnchorPoint(ccp(0.5,0.5))
    tankSp:setPosition(ccp(40,container:getContentSize().height-380+addH))
    tankSp:setScale(0.3)
    container:addChild(tankSp)

    
    local needR1Lb=GetTTFLabel(FormatNumber(reR1),20)
    needR1Lb:setAnchorPoint(ccp(0.5,0.5))
    needR1Lb:setPosition(ccp(300,container:getContentSize().height-100+addH))
    container:addChild(needR1Lb)
    
    local needR2Lb=GetTTFLabel(FormatNumber(reR2),20)
    needR2Lb:setAnchorPoint(ccp(0.5,0.5))
    needR2Lb:setPosition(ccp(300,container:getContentSize().height-170+addH))
    container:addChild(needR2Lb)
    
    local needR3Lb=GetTTFLabel(FormatNumber(reR3),20)
    needR3Lb:setAnchorPoint(ccp(0.5,0.5))
    needR3Lb:setPosition(ccp(300,container:getContentSize().height-240+addH))
    container:addChild(needR3Lb)
    
    local needR4Lb=GetTTFLabel(FormatNumber(reR4),20)
    needR4Lb:setAnchorPoint(ccp(0.5,0.5))
    needR4Lb:setPosition(ccp(300,container:getContentSize().height-310+addH))
    container:addChild(needR4Lb)
    
    local needTankLb=GetTTFLabel(1,20)
    needTankLb:setAnchorPoint(ccp(0.5,0.5))
    needTankLb:setPosition(ccp(300,container:getContentSize().height-380+addH))
    container:addChild(needTankLb)

    local haveR1Lb=GetTTFLabel(FormatNumber(playerVoApi:getR1()),20)
    haveR1Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR1Lb:setPosition(ccp(450,container:getContentSize().height-100+addH))
    container:addChild(haveR1Lb)
    
    local haveR2Lb=GetTTFLabel(FormatNumber(playerVoApi:getR2()),20)
    haveR2Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR2Lb:setPosition(ccp(450,container:getContentSize().height-170+addH))
    container:addChild(haveR2Lb)
    
    local haveR3Lb=GetTTFLabel(FormatNumber(playerVoApi:getR3()),20)
    haveR3Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR3Lb:setPosition(ccp(450,container:getContentSize().height-240+addH))
    container:addChild(haveR3Lb)
    
    local haveR4Lb=GetTTFLabel(FormatNumber(playerVoApi:getR4()),20)
    haveR4Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR4Lb:setPosition(ccp(450,container:getContentSize().height-310+addH))
    container:addChild(haveR4Lb)
    
    local haveTankLb=GetTTFLabel(FormatNumber(haveTankNum),20)
    haveTankLb:setAnchorPoint(ccp(0.5,0.5))
    haveTankLb:setPosition(ccp(450,container:getContentSize().height-380+addH))
    container:addChild(haveTankLb)
    
    
    
    
    local m_numLb=GetTTFLabel(" ",24)
    m_numLb:setPosition(70,-30);
    container:addChild(m_numLb,2);
    local m_tankIndex = self.tankResultTypeTab[idx+1]
    -- local refitTankSpeed=playerCfg.refitTankSpeed[playerVoApi:getVipLevel()+1]
    -- local timeConsume=math.ceil(tonumber(tankCfg[m_tankIndex].upgradeTimeConsume)/(1+(buildingVoApi:getBuildiingVoByBId(self.bid).level-1)*0.05+refitTankSpeed));
    local timeConsume=tankVoApi:getTankUpgradeTime(m_tankIndex,self.bid)
    
    local lbTime=GetTTFLabel(GetTimeStr(timeConsume),20)
    lbTime:setPosition(70,-80+addH)
    lbTime:setAnchorPoint(ccp(0,0.5));
    container:addChild(lbTime,2)

    local function sliderTouch(handler,object)
        local count = math.floor(object:getValue())
        m_numLb:setString(count)
        if count>0 then
         lbTime:setString(GetTimeStr(timeConsume*count))
            
         needR1Lb:setString(FormatNumber(tonumber(tankCfg[m_tankIndex].upgradeMetalConsume)*count))
         needR2Lb:setString(FormatNumber(tonumber(tankCfg[m_tankIndex].upgradeOilConsume)*count))
         needR3Lb:setString(FormatNumber(tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume)*count))
         needR4Lb:setString(FormatNumber(tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume)*count))
         needTankLb:setString(FormatNumber(tonumber(1*count)))

         
        end

    end
    local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
    local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
    local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    slider:setTouchPriority(-(self.layerNum-1)*20-2);
    slider:setIsSallow(true);
    
    slider:setMinimumValue(0.0);
    
    slider:setMaximumValue(self.maxRemakeNum);
    
    slider:setValue(0);
    slider:setPosition(ccp(355,-30))
    slider:setTag(99)
    container:addChild(slider,2)
    m_numLb:setString(math.floor(slider:getValue()))
    
    
    local function touchAdd()
        slider:setValue(slider:getValue()+1);
    end
    
    local function touchMinus()
        if slider:getValue()-1>0 then
            slider:setValue(slider:getValue()-1);
        end
    
    end
    
    local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
    addSp:setPosition(ccp(549,-30))
    container:addChild(addSp,1)
    addSp:setTouchPriority(-(self.layerNum-1)*20-3);
    
    local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
    minusSp:setPosition(ccp(157,-30))
    container:addChild(minusSp,1)
    minusSp:setTouchPriority(-(self.layerNum-1)*20-3);

    
--满足条件的对错号    
    local p1Sp;
      if playerVoApi:getR1()>=tonumber(tankCfg[m_tankIndex].upgradeMetalConsume) then
         p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
      end
      p1Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p1Sp:setPosition(ccp(400,container:getContentSize().height-100+addH))

      container:addChild(p1Sp)
      
      local p2Sp;
      if playerVoApi:getR2()>=tonumber(tankCfg[m_tankIndex].upgradeOilConsume) then
         p2Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p2Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
      end
      p2Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p2Sp:setPosition(ccp(400,container:getContentSize().height-170+addH))

      container:addChild(p2Sp)
      
       local p3Sp;
      if playerVoApi:getR3()>=tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume) then
         p3Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p3Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
      end
      p3Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p3Sp:setPosition(ccp(400,container:getContentSize().height-240+addH))

      container:addChild(p3Sp)
      
       local p4Sp;
      if playerVoApi:getR4()>=tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume) then
         p4Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p4Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
      end
      p4Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p4Sp:setPosition(ccp(400,container:getContentSize().height-310+addH))

      container:addChild(p4Sp)
      
       local p5Sp;
      if haveTankNum>=1 then
         p5Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
      else
         p5Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
      end
      p5Sp:setAnchorPoint(ccp(0.5,0.5))
      
      p5Sp:setPosition(ccp(400,container:getContentSize().height-380+addH))

      container:addChild(p5Sp)
      

    local function touch1()
        PlayEffect(audioCfg.mouseClick)
        local tid=tonumber(tankCfg[m_tankIndex].sid)
        local nums=math.floor(tonumber(slider:getValue()))
        local result,reson = tankVoApi:checkUpgradeResouceBeforeSendServer(self.bid,tid,nums)
        local function doUpgrade()
            --成功添加
            local function serverUpgrade(fn,data)
                  --local retTb=OBJDEF:decode(data)

                  if base:checkServerData(data)==true then
                    --tankVoApi:refreshUpgradedTanks(tid,nums)
                    self:clearVar()
                    self:tabClick(2)

                  end
            end
            socketHelper:upgradeTanks(self.bid,tid,nums,serverUpgrade)
        end

        --reson 1:金币不足 2:队列不足
        if result==true then
            doUpgrade()
        else
            if reson ==1 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+1)
            elseif reson==2 then
                vipVoApi:showQueueFullDialog(3,self.layerNum+1,doUpgrade,self.bid)
            end
        
        end
                
            
    end
    local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("smelt"),28,100)
    local menu1 = CCMenu:createWithItem(menuItem1);
    menu1:setPosition(ccp(460,-93));
    menu1:setTouchPriority(-(self.layerNum-1)*20-2);
    container:addChild(menu1,3);
    local lb = menuItem1:getChildByTag(100)
    if lb then
      lb = tolua.cast(lb,"CCLabelTTF")
      lb:setFontName("Helvetica-bold")
    end
    if playerVoApi:getR1()>=tonumber(tankCfg[m_tankIndex].upgradeMetalConsume) and playerVoApi:getR2()>=tonumber(tankCfg[m_tankIndex].upgradeOilConsume) and playerVoApi:getR3()>=tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume) and playerVoApi:getR4()>=tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume) and
    haveTankNum>=1
     then
        
        local tnum1=playerVoApi:getR1()/tonumber(tankCfg[m_tankIndex].upgradeMetalConsume)
        local num1 = math.floor(tnum1)
        
        local tnum2=playerVoApi:getR2()/tonumber(tankCfg[m_tankIndex].upgradeOilConsume)
        local num2 = math.floor(tnum2)
        
        local tnum3=playerVoApi:getR3()/tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume)
        local num3 = math.floor(tnum3)
        
        local tnum4=playerVoApi:getR4()/tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume)
        local num4 = math.floor(tnum4)
        
        local num5 = haveTankNum
        
        local numTab = {num1,num2,num3,num4,num5}
        table.sort(numTab,function(a,b) return a<b end)
        if numTab[1]>self.maxRemakeNum then

           slider:setMaximumValue(self.maxRemakeNum);
           
        else

           slider:setMaximumValue(numTab[1]);
           
        end
        
        if numTab[1]==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
        else
            slider:setMinimumValue(1.0);
        end
        
        slider:setValue(numTab[1]);
        menuItem1:setEnabled(true)
    else
        slider:setMaximumValue(0);
        menuItem1:setEnabled(false)
        menu1:setTag(199)
    
    end
    
    

end

function tankTuningDialog:refreshExpandUIData()
  if self.expandUITab and self.tankResultTypeTab then
      for i=1, SizeOfTable(self.tankResultTypeTab) do
          if self.expandUITab[i] and self.expandUITab[i].resUITab then
              local resUITab = self.expandUITab[i].resUITab
              local m_tankIndex = self.tankResultTypeTab[i]
              local reR1,reR2,reR3,reR4,reUpgradedTime = tankVoApi:getUpgradedTankResources(m_tankIndex)
              
              local tab={
                  { haveStr=FormatNumber(playerVoApi:getR1()),num=playerVoApi:getR1(),needNum=tonumber(reR1) },
                  { haveStr=FormatNumber(playerVoApi:getR2()),num=playerVoApi:getR2(),needNum=tonumber(reR2) },
                  { haveStr=FormatNumber(playerVoApi:getR3()),num=playerVoApi:getR3(),needNum=tonumber(reR3) },
                  { haveStr=FormatNumber(playerVoApi:getR4()),num=playerVoApi:getR4(),needNum=tonumber(reR4) },
              }
              for k,v in pairs(tab) do
                  if resUITab[k] then
                      if resUITab[k].resLb and tolua.cast(resUITab[k].resLb,"CCLabelTTF") then
                          local resLb = tolua.cast(resUITab[k].resLb,"CCLabelTTF")
                          resLb:setString(v.haveStr)
                      end
                      if v.num>=v.needNum then
                          if resUITab[k].leftSp and tolua.cast(resUITab[k].leftSp,"CCSprite") then
                              local leftSp = tolua.cast(resUITab[k].leftSp,"CCSprite")
                              local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("IconCheck.png")
                              if frame then
                                leftSp:setDisplayFrame(frame)
                              end
                          end
                          if resUITab[k].rightSp and tolua.cast(resUITab[k].rightSp,"CCSprite") then
                              local rightSp = tolua.cast(resUITab[k].rightSp,"CCSprite")
                              rightSp:removeFromParentAndCleanup(true)
                              resUITab[k].rightSp=nil
                          end
                      end
                  end
              end
              local _flag = false
              local slider = self.expandUITab[i].slider
              if slider then
                  local haveTankNum1=tankVoApi:getTankCountByItemId(m_tankIndex-1)
                  local haveTankNum2=tankVoApi:getTankCountByItemId(m_tankIndex-1+40000)
                  local haveTankNum=haveTankNum1+haveTankNum2

                  if tankCfg[m_tankIndex].upgradePropConsume~="" then
                      local pid1 = tankCfg[m_tankIndex].upgradePropConsume[1][1]
                      local pid2 = tankCfg[m_tankIndex].upgradePropConsume[2][1]
                      local needP1 = tonumber(tankCfg[m_tankIndex].upgradePropConsume[1][2])
                      local needP2 = tonumber(tankCfg[m_tankIndex].upgradePropConsume[2][2])
                      local numP1 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))
                      local numP2 = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2)))

                      if playerVoApi:getR1()>=tonumber(tankCfg[m_tankIndex].upgradeMetalConsume) and playerVoApi:getR2()>=tonumber(tankCfg[m_tankIndex].upgradeOilConsume) and playerVoApi:getR3()>=tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume) and playerVoApi:getR4()>=tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume) and haveTankNum>=1 and numP1>=1 and numP2>=1 then
                          local tnum1=playerVoApi:getR1()/tonumber(tankCfg[m_tankIndex].upgradeMetalConsume)
                          local num1 = math.floor(tnum1)

                          local tnum2=playerVoApi:getR2()/tonumber(tankCfg[m_tankIndex].upgradeOilConsume)
                          local num2 = math.floor(tnum2)

                          local tnum3=playerVoApi:getR3()/tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume)
                          local num3 = math.floor(tnum3)

                          local tnum4=playerVoApi:getR4()/tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume)
                          local num4 = math.floor(tnum4)

                          local num5 = haveTankNum

                          local numTab = {num1,num2,num3,num4,num5}

                          if tankCfg[m_tankIndex].upgradePropConsume~="" then
                              local pid1 = tankCfg[m_tankIndex].upgradePropConsume[1][1]
                              local pid2 = tankCfg[m_tankIndex].upgradePropConsume[2][1]
                              local numP1 = math.floor(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid1)))/needP1)
                              local numP2 = math.floor(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid2)))/needP2)
                              table.insert(numTab,numP1)
                              table.insert(numTab,numP2)
                          end

                          table.sort(numTab,function(a,b) return a<b end)
                          if numTab[1]>self.maxRemakeNum then
                              slider:setMaximumValue(self.maxRemakeNum);
                          else
                              slider:setMaximumValue(numTab[1]);
                          end
                          if numTab[1]==1 then
                              slider:setMinimumValue(1.0);
                              slider:setMaximumValue(1.0);
                          else
                              slider:setMinimumValue(1.0);
                          end
                          if haveTankNum1>0 and haveTankNum1<numTab[1] then
                              slider:setValue(haveTankNum1)
                          else
                              slider:setValue(numTab[1]);
                          end
                          if self.expandUITab[i].btn then
                              self.expandUITab[i].btn:setEnabled(true)
                          end
                          _flag=true
                      end
                  else
                      if playerVoApi:getR1()>=tonumber(tankCfg[m_tankIndex].upgradeMetalConsume) and playerVoApi:getR2()>=tonumber(tankCfg[m_tankIndex].upgradeOilConsume) and playerVoApi:getR3()>=tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume) and playerVoApi:getR4()>=tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume) and haveTankNum>=1 then
                          local tnum1=playerVoApi:getR1()/tonumber(tankCfg[m_tankIndex].upgradeMetalConsume)
                          local num1 = math.floor(tnum1)

                          local tnum2=playerVoApi:getR2()/tonumber(tankCfg[m_tankIndex].upgradeOilConsume)
                          local num2 = math.floor(tnum2)

                          local tnum3=playerVoApi:getR3()/tonumber(tankCfg[m_tankIndex].upgradeSiliconConsume)
                          local num3 = math.floor(tnum3)

                          local tnum4=playerVoApi:getR4()/tonumber(tankCfg[m_tankIndex].upgradeUraniumConsume)
                          local num4 = math.floor(tnum4)

                          local num5 = haveTankNum

                          local numTab = {num1,num2,num3,num4,num5}

                          table.sort(numTab,function(a,b) return a<b end)
                          if numTab[1]>self.maxRemakeNum then
                              slider:setMaximumValue(self.maxRemakeNum);
                          else
                              slider:setMaximumValue(numTab[1]);
                          end
                          if numTab[1]==1 then
                              slider:setMinimumValue(1.0);
                              slider:setMaximumValue(1.0);
                          else
                              slider:setMinimumValue(1.0);
                          end
                          if haveTankNum1>0 and haveTankNum1<numTab[1] then
                              slider:setValue(haveTankNum1)
                          else
                              slider:setValue(numTab[1]);
                          end
                          if self.expandUITab[i].btn then
                              self.expandUITab[i].btn:setEnabled(true)
                          end
                          _flag=true
                      end
                  end

                  if _flag==true then
                      local count=math.floor(slider:getValue())
                      if self.expandUITab[i].numLb and tolua.cast(self.expandUITab[i].numLb,"CCLabelTTF") then
                        local numLb = tolua.cast(self.expandUITab[i].numLb,"CCLabelTTF")
                        numLb:setString(count)
                      end
                      if self.expandUITab[i].timeLb and tolua.cast(self.expandUITab[i].timeLb,"CCLabelTTF") then
                          local timeLb = tolua.cast(self.expandUITab[i].timeLb,"CCLabelTTF")
                          local timeConsume=tankVoApi:getTankUpgradeTime(m_tankIndex,self.bid)
                          timeLb:setString(GetTimeStr(timeConsume*count))
                      end
                      for k,v in pairs(tab) do
                          if resUITab[k] and resUITab[k].needLb and tolua.cast(resUITab[k].needLb,"CCLabelTTF") then
                              local needLb = tolua.cast(resUITab[k].needLb,"CCLabelTTF")
                              needLb:setString(FormatNumber(v.needNum*count))
                          end
                      end
                      if self.expandUITab[i].cellBtn and tolua.cast(self.expandUITab[i].cellBtn,"CCSprite") then
                          local cellBtn = tolua.cast(self.expandUITab[i].cellBtn,"CCSprite")
                          local sp = CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
                          sp:setAnchorPoint(cellBtn:getAnchorPoint())
                          sp:setPosition(cellBtn:getPosition())
                          sp:setTag(cellBtn:getTag())
                          cellBtn:getParent():addChild(sp)
                          cellBtn:removeFromParentAndCleanup(true)
                          self.expandUITab[i].cellBtn=nil
                      end
                  end
              end
              if _flag==true then
                  self.expandUITab[i]=nil
              end
          end
      end
  end
end

function tankTuningDialog:tick()
    self:judgeProduceTank()
    if buildingVoApi:getBuildiingVoByBId(self.bid).level>0 then
        for k,v in pairs(self.allTabs) do
          local  tabBtnItem=v
            tabBtnItem:setVisible(true)
        end
    end
    if self.selectedTabIndex==0 then
        if self.upgradeDialog then
            self.upgradeDialog:tick()
        end
    elseif self.selectedTabIndex==1 then
    -- for k,v in pairs(self.tickNumLbTab) do
    --     local numLb=v
    --     numLb=tolua.cast(numLb,"CCLabelTTF")
    --     numLb:setString(getlocal("schedule_ship_num",{tankVoApi:getTankCountByItemId(k)}))
        
    -- end
        self:refreshExpandUIData()
    elseif self.selectedTabIndex==2 then
        for k,v in pairs(self.tickTabCell) do 

            if tankUpgradeSlotVoApi:getSlotBySlotid(self.bid,self.tankSoltTab[k].slotId)==nil then
                    self:clearVar()
                    do
                    return
                    end
            end
           if self.tankSoltTab[k].status==1 then
                
                local cell = self.tickTabCell[k]
                local ccprogress=cell:getChildByTag(10)
                ccprogress=tolua.cast(ccprogress,"CCProgressTimer")
                local leftTime,totalTime= tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.bid,self.tankSoltTab[k].slotId)
               
                local per = (totalTime-leftTime)/totalTime*100
                 ccprogress:setPercentage(per)
                 
                 local timeLb = ccprogress:getChildByTag(11)
                 timeLb=tolua.cast(timeLb,"CCLabelTTF")
                 local strTime= GetTimeStr(tankUpgradeSlotVoApi:getLeftTimeAndTotalTimeBySlotid(self.bid,self.tankSoltTab[k].slotId))
                 timeLb:setString(strTime)
                 if leftTime<=0 then
                    
                    self:clearVar()

                 end
            end

        end

        
    end



    local alienTechOpenLv=base.alienTechOpenLv or 22
    if base.alien==1 and base.richMineOpen==1 and newGuidMgr:isNewGuiding()==false and playerVoApi:getPlayerLevel()>=alienTechOpenLv then
        if self and self.tv and alienTechVoApi and alienTechVoApi.getFlag and alienTechVoApi:getFlag()==-1 and alienTechVoApi.getTechData then
            local function refreshTv()
                if self.selectedTabIndex==2 then
                    local recordPoint=self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)
                end
            end
            alienTechVoApi:getTechData(refreshTv)
        end
    end
end


function tankTuningDialog:clearVar()
    self.tankSoltTab={}
    self.tankSoltTab=tankUpgradeSlotVoApi:getAllSolts(self.bid)
    self.tickTabCell={}
    if(self.tv)then
        self.tv:reloadData()
    end
end

function tankTuningDialog:dispose()
    if self.speedUpSmallDialog then
        self.speedUpSmallDialog:close()
        self.speedUpSmallDialog = nil
    end
    self.isShowPoint=nil
    self.tickNumLbTab={}
    self.tickNumLbTab=nil
    self.expandIdx=nil
    self.islandStateTab=nil
    self.expandHeight=nil
    self.normalHeight=nil
    self.extendSpTag=nil
    self.headTab=nil
    self.expandUITab=nil
    self.upgradeDialog:dispose()
    self.upgradeDialog=nil
    eventDispatcher:removeEventListener("tankslot.speedup",self.speedUpListener)
    self=nil
end

function tankTuningDialog:againAssignmentTab()
    self.tankResultTypeTab,self.tankResultLockTab,self.tankResultCountTab=tankVoApi:getAllUpgradeTankTypeAndCoutByBid(self.bid)

end




