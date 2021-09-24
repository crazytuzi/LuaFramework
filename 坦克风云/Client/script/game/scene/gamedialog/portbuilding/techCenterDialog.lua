--require "luascript/script/componet/commonDialog"
techCenterDialog=commonDialog:new()

function techCenterDialog:new(bid,layerNum,isGuide,isShowPoint)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
  self.bid=bid
  self.layerNum=layerNum
  self.isShowPoint=isShowPoint
  self.normalHeight=120
  self.expandHeight=G_VisibleSize.height-140
  self.requires={}
  self.allCellsBtn={}
  self.progressTag=100
  self.upgradeBtnTag=101
  self.removeBuildBtnTag=102
  self.cancleUpgradeTag=103
  self.superUpgradeTag=104
  self.upgradeTextTag=105
  self.bgSpriteTag=106
  self.exBg=nil
  self.fourBtns={}
  self.tmLb=nil
  self.bDescLb=nil
  self.upgradeDialog=nil
  --科技升级页面
 self.expandIdx={}
 self.allTechData=nil
 self.progressTag2=107
 self.upgradeTextTag2=108
  self.bgSpriteTag2=109
  self.lockLbTag=110
  self.timeSpTag=111
  self.timeLbTag=112
  self.extendSpTag=113
  self.cellHeader={}
  self.isGuide=isGuide;
  self.guideTab={2,1,4,3,6,5,8,7}
  self.addBtn=nil
  self.canSpeedTime=0
  self.btnItem = nil
    local function speedListener(event,data)
        self:reload()
    end
    self.speedUpListener=speedListener
    eventDispatcher:addEventListener("techslot.speedup",self.speedUpListener)
    self.speedUpSmallDialog = nil--选择加速升级道具进行加速升级的小面板
  return nc
end

--设置或修改每个Tab页签
function techCenterDialog:resetTab()
    if base.fs==1 then
      self.canSpeedTime=playerVoApi:getFreeTime()
    end

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         else
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

--设置对话框里的tableView
function techCenterDialog:initTableView()
  if self.selectedTabIndex==1 then
     self.allTechData=technologyVoApi:getAllInfo()
  end
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-200),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(1)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function techCenterDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
   if self.selectedTabIndex==0 then
        return 1
   else
        return #technologyVoApi.allTechTbs
   end
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
   if self.selectedTabIndex==0 then
         tmpSize=CCSizeMake(600,self.expandHeight)
   else
       tmpSize=CCSizeMake(600,self.normalHeight)
   end
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
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
function techCenterDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            --self.tv:reloadData()
            self:doUserHandler()
         else
            v:setEnabled(true)
         end
    end
    self:tabClickColor(idx)

        self.tv:removeFromParentAndCleanup(true)
        self.tv=nil
        self:initTableView()
    if idx==1 then

        self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        
    else
        self.tv:setTableViewTouchPriority(1)
    end
    if self.selectedTabIndex~=1 then
        self:removeGuied()
    end
end

--用户处理特殊需求,没有可以不写此方法
function techCenterDialog:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function techCenterDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
                self:removeGuied()
        else
            if self.requires[idx-1000+1]~=nil then
                self.requires[idx-1000+1]:dispose()
                self.requires[idx-1000+1]=nil
                self.allCellsBtn[idx-1000+1]=nil
            end
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

--创建或刷新CCTableViewCell
function techCenterDialog:loadCCTableViewCell(cell,idx,refresh)
   if self.selectedTabIndex==0 then
            self.upgradeDialog=buildingUpgradeCommon:new()
            self.upgradeDialog:init(cell,self.bgLayer,self.bid,self,self.layerNum,self.isShowPoint)
            self.btnItem = self.upgradeDialog.allCellsBtn[1]
            if self.btnItem ~= nil then
              local groupId = G_getGroupIdByBid(self.bid)
              local x,y,z,w  = G_getSpriteWorldPosAndSize(self.btnItem, 1)
              newSkipCfg[groupId].clickRect = CCRectMake(x + 10,y - 25,z,w)
            end
   else --“研究”页签
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
       end
       local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
       headerSprie:ignoreAnchorPointForPosition(false);
       headerSprie:setAnchorPoint(ccp(0,0));
       headerSprie:setTag(1000+idx)
       headerSprie:setIsSallow(false)
       headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       headerSprie:setPosition(ccp(0,0));
       cell:addChild(headerSprie)
       self.cellHeader[idx+1]=headerSprie

       local techVo=self.allTechData[idx+1]     ---technologyVoApi.allTechTbs[idx+1]
       local tcfg=techCfg[tonumber(techVo.id)]
       local sp=CCSprite:createWithSpriteFrameName(tcfg.icon)
       sp:setAnchorPoint(ccp(0,0.5))
       local spScale=0.8;
       sp:setScale(spScale)
       sp:setPosition(ccp(10,self.normalHeight/2))
       headerSprie:addChild(sp)
       local nameLb
       if techVo.status~=0 then
            nameLb=GetTTFLabelWrap(getlocal(tcfg.name).." "..getlocal("uper_level").."."..techVo.level.."->"..getlocal("uper_level").."."..(techVo.level+1),21,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
       else
            nameLb=GetTTFLabelWrap(getlocal(tcfg.name).."("..G_LV()..techVo.level..")",21,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
          end
       nameLb:setColor(G_ColorGreen)
       nameLb:setAnchorPoint(ccp(0,0.5))
       nameLb:setPosition(ccp(30+sp:getContentSize().width*spScale,self.normalHeight-40))
       headerSprie:addChild(nameLb)

       if (techVo.level>=playerVoApi:getMaxLvByKey("techMaxLevel") or techVo.level>=techCfg[techVo.id].maxLevel or (techCfg[techVo.id].intervalLv and techVo.level*techCfg[techVo.id].intervalLv>=playerVoApi:getMaxLvByKey("techMaxLevel"))) and (techVo.level >= playerVoApi:getHonorInfo() and playerVoApi:getHonorInfo() >= playerVoApi:getHonorMaxLv()) then
            local maxLb = GetTTFLabel(getlocal("technology_max_level",{getlocal(techCfg[techVo.id].name)}),22)
            maxLb:setAnchorPoint(ccp(0,0))
            maxLb:setPosition(ccp(30+sp:getContentSize().width*spScale,20))
           headerSprie:addChild(maxLb)
       end

       local upgradeInfo,infos=technologyVoApi:getUpgradeInfo(techVo)

       if techVo.status==0 then
           --if upgradeInfo==false then
               local tsLb 
               if infos~=-1 then
                   tsLb=GetTTFLabelWrap(getlocal("technology_level_require",{techVo.unlockIndex}),21,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                   tsLb:setColor(G_ColorRed)
                   tsLb:setTag(self.lockLbTag)
                   tsLb:setAnchorPoint(ccp(0,0.5))
                   tsLb:setPosition(ccp(30+sp:getContentSize().width*spScale,35))
                   headerSprie:addChild(tsLb)
               end
           --end 
           --显示时间
                   local tmIco
                   local tmLb
                   if infos~=-1 then
                       tmIco=CCSprite:createWithSpriteFrameName("IconTime.png")
                       tmIco:setAnchorPoint(ccp(0,0))
                       tmIco:setPosition(ccp(25+sp:getContentSize().width*spScale,15))
                       headerSprie:addChild(tmIco)
                       tmIco:setTag(self.timeSpTag)
                       tmLb= GetTTFLabel(GetTimeStr(infos),20)
                       tmLb:setAnchorPoint(ccp(0,0.5))
                       tmLb:setPosition(ccp(25+sp:getContentSize().width*spScale+tmIco:getContentSize().width,35))
                       headerSprie:addChild(tmLb)
                       tmLb:setTag(self.timeLbTag)
                   end
                   --研究按钮
                   local function touch1()
                        PlayEffect(audioCfg.mouseClick)
                        local function doUpgrade()
                            local function serverUpgrade(fn,data)
                                    --local retTb=OBJDEF:decode(data)
                                    if base:checkServerData(data)==true then
                                        local upResult,reason=technologyVoApi:upgrade(techVo.id)
                                        if upResult==true then
                                              self:reload()
                                        end
                                    end
                            end
                            socketHelper:upgradeTech(techVo.id,serverUpgrade) --通知服务器
                        end
                        
                        local upResult,reason=technologyVoApi:checkUpgradeBeforeSendServer(techVo.id)
                        if upResult==true then --本地检测通过
                             doUpgrade()
                        else --本地检测未通过
                            local reasonStr
                            if reason==1 then
                                reasonStr=getlocal("resourcelimit")
                                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),reasonStr,nil,self.layerNum+1)
                            else
                                vipVoApi:showQueueFullDialog(4,self.layerNum+1,doUpgrade)
                            end
                        end

                   end
                   
                   local menuItem1 = GetButtonItem("yh_BtnBuild.png","yh_BtnBuild_Down.png","yh_BtnBuild_Down.png",touch1,10,nil,nil)
                   menuItem1:setAnchorPoint(ccp(0,0))
                    local menu1 = CCMenu:createWithItem(menuItem1);
                    menu1:setPosition(ccp(headerSprie:getContentSize().width-75,15));
                    menu1:setTouchPriority(-(self.layerNum-1)*20-2);
                    cell:addChild(menu1,3);

                   
                   local function touch2()
                        local isMax=true
                        if techCfg[techVo.id].intervalLv and techVo.level*techCfg[techVo.id].intervalLv>=playerVoApi:getMaxLvByKey("techMaxLevel") then
                            isMax=false
                        end
                        if (techVo.level<playerVoApi:getMaxLvByKey("techMaxLevel") and techVo.level<techCfg[techVo.id].maxLevel and isMax==true) or 
                          (techVo.level >= playerVoApi:getMaxLvByKey("techMaxLevel") and techVo.level >= techCfg[techVo.id].maxLevel and techVo.level < playerVoApi:getHonorInfo()) or playerVoApi:getHonorInfo() < playerVoApi:getHonorMaxLv() then
                            local td=smallDialog:new()
                            local dialog,container=td:initShowBuilding("TankInforPanel.png",CCSizeMake(530,550),CCRect(0, 0, 400, 500),CCRect(130, 50, 1, 1),nil,true,true,self.layerNum+1)
                            dialog:setPosition(ccp(0,0))
                            local upD=upgradeRequire:new()
                            local result=upD:create(container,"tech",techVo.id,nil,td)
                            sceneGame:addChild(dialog,self.layerNum+1)
                        else
                            local td=smallDialog:new()
                            local tabStr={};
                            local str1 = getlocal("technology_max_level",{getlocal(techCfg[techVo.id].name)})
                            local str2 = getlocal(techCfg[techVo.id].description)
                            tabStr={" ",str2,str1," "};
                            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
                            sceneGame:addChild(dialog,self.layerNum+1)

                        end
                        

                   end
                   
                   local menuItem2 = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch2,11,nil,nil)
                   menuItem2:setAnchorPoint(ccp(0,0))
                local menu2 = CCMenu:createWithItem(menuItem2);
                menu2:setPosition(ccp(headerSprie:getContentSize().width-150,15));
                menu2:setTouchPriority(-(self.layerNum-1)*20-2);
                cell:addChild(menu2,3);
                
                if (upgradeInfo==false or techVo.level>=playerVoApi:getMaxLvByKey("techMaxLevel") or techVo.level>=techCfg[techVo.id].maxLevel or (techCfg[techVo.id].intervalLv and techVo.level*techCfg[techVo.id].intervalLv>=playerVoApi:getMaxLvByKey("techMaxLevel"))) and (techVo.level >= playerVoApi:getHonorInfo()) then
                    menuItem1:setEnabled(false)
                    menuItem2:setEnabled(true)
                else
                    menuItem1:setEnabled(true)
                    menuItem2:setEnabled(true)
                end
                local upD=upgradeRequire:new()

                if (techVo.level<playerVoApi:getMaxLvByKey("techMaxLevel") and techVo.level<techCfg[techVo.id].maxLevel) or 
                  (techVo.level >= playerVoApi:getMaxLvByKey("techMaxLevel") and techVo.level >= techCfg[techVo.id].maxLevel and techVo.level < playerVoApi:getHonorInfo()) then
                    if techCfg[techVo.id].intervalLv and techVo.level*techCfg[techVo.id].intervalLv>=playerVoApi:getMaxLvByKey("techMaxLevel") then
                    else
                        local techResult,results,have=technologyVoApi:checkUpgradeRequire(techVo.id)
                        if techResult==false then
                            menuItem1:setEnabled(false)
                        end
                    end
                end
                

                   
                

           if infos~=-1 then
               if upgradeInfo==false then
                   tmIco:setVisible(false)
                   tmLb:setVisible(false)
               else
                   tsLb:setVisible(false)
               end
           end
       else
           local leftTime
           if techVo.status==1 then
                leftTime=GetTimeStr(technologyVoApi:leftTime(techVo.id))
           else 
                leftTime=getlocal("waiting")
           end
           AddProgramTimer(headerSprie,ccp(25+sp:getContentSize().width/2+165,35),self.progressTag2,self.upgradeTextTag2,leftTime,"TeamTravelBarBg.png","TeamTravelBar.png",self.bgSpriteTag2)
           --取消按钮
           local function cancleHandler()
                PlayEffect(audioCfg.mouseClick)
                local function realCancleHandler()
                
                      local function cancleUpgradeServer(fn,data)
                          --local retTb=OBJDEF:decode(data)
                          if base:checkServerData(data)==true then
                              
                                    self:reload()
                              
                          end
                      end
                      if technologyVoApi:checkCancleUpgradeBeforeServer(techVo.id)==true then
                          socketHelper:cancleUpgradeTech(techVo.id,cancleUpgradeServer) --通知服务器
                      end
                end
                if techVo.status==1 then
                   local smallD=smallDialog:new()
                   smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),realCancleHandler,getlocal("dialog_title_prompt"),getlocal("research_cancel_prompt"),nil,self.layerNum+1)
                else
                    realCancleHandler()
                end
   
           end
           local menuItem=GetButtonItem("yh_BtnNo.png","yh_BtnNo_Down.png","yh_BtnNo_Down.png",cancleHandler,idx+1,nil,nil)
            local cancleMenu=CCMenu:createWithItem(menuItem);
            menuItem:setAnchorPoint(ccp(0,0))
            cancleMenu:setPosition(ccp(headerSprie:getContentSize().width-150,15))
            cancleMenu:setTouchPriority(-(self.layerNum-1)*20-2);
            headerSprie:addChild(cancleMenu)
            
            --加速按钮
            local function superHandler()
                PlayEffect(audioCfg.mouseClick)

                local function superUpgradeHandler()
                    local function realSuperHandler()
                     
                        local function superServerHandler(fn,data)
                                
                              --local retTb=OBJDEF:decode(data)
                              if base:checkServerData(data)==true then
                                    technologyVoApi:superUpgrade(techVo.id)
                                    self:reload()
                                    if self.speedUpSmallDialog ~= nil then
                                        self.speedUpSmallDialog:close()
                                        self.speedUpSmallDialog = nil
                                    end
                              end
                        end
                        
                        local result,reason=technologyVoApi:checkSuperUpgradeBeforeSendServer(techVo.id)
                        if result==false then
                            if reason==1 then --升级已完成
                                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("indexisSpeed"),nil,self.layerNum+2)
                                     end
                        else
                             socketHelper:superUpgradeTech(techVo.id,superServerHandler) --通知服务器
                        end
                        
                        
                    end
                    local leftTime=technologyVoApi:leftTime(techVo.id)
                    local needGemsNum=TimeToGems(leftTime)
                    local needGems=getlocal("speedUp",{needGemsNum})
                    if needGemsNum>playerVoApi:getGems() then --宝石不足
                        GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),self.layerNum+2,needGemsNum)
                    else

                        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),realSuperHandler,getlocal("dialog_title_prompt"),needGems,nil,self.layerNum+2,nil,nil,nil,nil,nil,nil,nil,nil,getlocal("recommendJoinAlliance_lbDes"))
                    end
                end
                --使用加速道具
                if base.speedUpPropSwitch == 1 then
                    if self.speedUpSmallDialog ~= nil then
                        self.speedUpSmallDialog:close()
                        self.speedUpSmallDialog = nil
                    end
                    require "luascript/script/componet/speedUpPropSmallDialog"
                    self.speedUpSmallDialog=speedUpPropSmallDialog:new(2,techVo.id,superUpgradeHandler)
                    self.speedUpSmallDialog:init(self.layerNum+1)
                    do return end
                end
                superUpgradeHandler()
            end
            local menuItem2=GetButtonItem("yh_BtnRight.png","yh_BtnRight_Down.png","yh_BtnRight_Down.png",superHandler,idx+1,nil,nil)
            
            if techVo.status==2 then
                menuItem2:setEnabled(false)
            end

            local superMenu=CCMenu:createWithItem(menuItem2);
            menuItem2:setAnchorPoint(ccp(0,0))
            superMenu:setPosition(ccp(headerSprie:getContentSize().width-75,15))
            superMenu:setTouchPriority(-(self.layerNum-1)*20-2);
            headerSprie:addChild(superMenu)
            superMenu:setTag(102)

            --免费加速按钮
            local isFree=false
            if base.fs==1 then
              local function freeAccHandler()
                
                 PlayEffect(audioCfg.mouseClick)
                 local function realSuperHandler()
                 
                    local function superServerHandler(fn,data)
                            
                          if base:checkServerData(data)==true then
                                technologyVoApi:superUpgrade(techVo.id)
                                self:reload()
                          end
                    end
                    
                    local result,reason=technologyVoApi:checkSuperUpgradeBeforeSendServer(techVo.id,true)
                    if result==false then
                        if reason==1 then --升级已完成
                                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("indexisSpeed"),nil,self.layerNum+1)
                                 end
                    else
                         socketHelper:freeUpgradeTech(techVo.id,superServerHandler) --通知服务器
                    end
                    
                    
                 end
                local leftTime=technologyVoApi:leftTime(techVo.id) or 0
                if leftTime>0 and leftTime<=self.canSpeedTime then
                  realSuperHandler()
                end
              end
              local menuItem3=GetButtonItem("yh_freeSpeedupBtn.png","yh_freeSpeedupBtn_Down.png","yh_freeSpeedupBtn_Down.png",freeAccHandler,idx+1,nil,nil)
              
              if techVo.status==2 then
                  menuItem3:setEnabled(false)
              end

              local freeAccBtn=CCMenu:createWithItem(menuItem3);
              menuItem3:setAnchorPoint(ccp(0,0))
              freeAccBtn:setPosition(ccp(headerSprie:getContentSize().width-75,15))
              freeAccBtn:setTouchPriority(-(self.layerNum-1)*20-2);
              freeAccBtn:setTag(103)
              headerSprie:addChild(freeAccBtn)
              local freeLb = GetTTFLabelWrap(getlocal("daily_lotto_tip_2"),20,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
              menuItem3:addChild(freeLb)
              freeLb:setPosition(menuItem3:getContentSize().width/2,menuItem3:getContentSize().height+18)

              if techVo.status==1 then
                local leftTime=technologyVoApi:leftTime(techVo.id)
                if leftTime>self.canSpeedTime then
                    freeAccBtn:setVisible(false)
                    superMenu:setVisible(true)
                else
                    freeAccBtn:setVisible(true)
                    superMenu:setVisible(false)
                    isFree=true
                end
              elseif techVo.status==2 then
                freeAccBtn:setVisible(false)
              end
            
            end

            if base.allianceHelpSwitch==1 then
                local function seekHelpHandler()
                    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)

                        local function helpCallback(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                                if sData and sData.data and sData.data.newhelp then
                                    local selfAlliance=allianceVoApi:getSelfAlliance()
                                    if selfAlliance then
                                        local aid=selfAlliance.aid
                                        local prams={newhelp=sData.data.newhelp,uid=playerVoApi:getUid()}
                                        chatVoApi:sendUpdateMessage(29,prams,aid+1)
                                    end
                                    self:reload()
                                end
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_help_success"),30)
                            end
                        end
                        local tid=techVo.id
                        local techSlotVo1=technologySlotVoApi:getSlotByTid(tid)
                        local techVo1=technologyVoApi:getTechVoByTId(tid)
                        if techVo1 and techVo1.status==1 and techSlotVo1 and techSlotVo1.hid==nil then
                            if base.fs==1 then
                                local canSpeedTime=playerVoApi:getFreeTime()
                                local leftTime1=technologyVoApi:leftTime(tid)
                                if leftTime1>canSpeedTime then
                                    local slotid=techSlotVo1.slotid
                                    socketHelper:techAlliancehelp(slotid,helpCallback)
                                end
                            else
                                local slotid=techSlotVo1.slotid
                                socketHelper:techAlliancehelp(slotid,helpCallback)
                            end
                        end
                    end
                end
                local menuItem4=GetButtonItem("yh_allianceHelpBtn.png","yh_allianceHelpBtn_Down.png","yh_allianceHelpBtn_Down.png",seekHelpHandler,4,nil,nil)
                local seekHelpBtn=CCMenu:createWithItem(menuItem4)
                menuItem4:setAnchorPoint(ccp(0,0))
                seekHelpBtn:setPosition(ccp(headerSprie:getContentSize().width-75,15))
                seekHelpBtn:setTouchPriority(-(self.layerNum-1)*20-2);
                seekHelpBtn:setTag(104)
                headerSprie:addChild(seekHelpBtn)

                local tid=techVo.id
                local techSlotVo=technologySlotVoApi:getSlotByTid(tid)
                local selfAlliance=allianceVoApi:getSelfAlliance()
                if selfAlliance and techVo.status==1 and techSlotVo and techSlotVo.hid==nil and isFree==false then
                    seekHelpBtn:setVisible(true)
                    seekHelpBtn:setEnabled(true)
                    superMenu:setVisible(false)
                    superMenu:setEnabled(false)
                else
                    seekHelpBtn:setVisible(false)
                    seekHelpBtn:setEnabled(false)
                end
            end
       end
       
   end
end
function techCenterDialog:removeGuied()
    if self.addBtn~=nil then
        G_removeFlicker(self.addBtn)
        self.addBtn=nil
    end
  self.isGuide=2;
end

function techCenterDialog:tick()
    local flag=technologySlotVoApi:getFlag()
    if flag==0 then
        self:reload()
        technologySlotVoApi:setFlag(1)
        do
            return
        end
    end

     local bvo=buildingVoApi:getBuildiingVoByBId(self.bid)
     local bcfg=buildingCfg[bvo.type]
    if self.selectedTabIndex==0 then
        self.upgradeDialog:tick()
    
    else
           local allTechData
           if base.allianceHelpSwitch==1 then
                allTechData=technologyVoApi:getAllInfo(false)
           else
                self.allTechData=technologyVoApi:getAllInfo()
           end
           for k,v in pairs(self.cellHeader) do
            local techVo
            if base.allianceHelpSwitch==1 then
                techVo=allTechData[k]
            else
                techVo=self.allTechData[k]
            end
            if techVo.status==0 then
                local upgradeInfo,infos=technologyVoApi:getUpgradeInfo(techVo)
                if infos==-1 then --达到最高等级,不刷新任何数据
                       
                else

                        if upgradeInfo==true then
                          if techVo.isFinishedUpgrade==true then
                                 techVo.isFinishedUpgrade=false
                                 if base.allianceHelpSwitch==1 then
                                    technologyVoApi:setIsFinishedUpgrade(techVo.id,false)
                                 end
                                 self:reload()
                                 do
                                   return
                                 end
                          end
                          if v:getChildByTag(self.lockLbTag)~=nil then
                              tolua.cast(v:getChildByTag(self.lockLbTag),"CCLabelTTF"):setVisible(false)
                              tolua.cast(v:getChildByTag(self.timeSpTag),"CCSprite"):setVisible(true)
                              tolua.cast(v:getChildByTag(self.timeLbTag),"CCLabelTTF"):setVisible(true)
                          end
                        end
                 end
            elseif techVo.status==1 then
                if techVo.isFinishedUpgrade==true then -- 升级完成
                    
                     techVo.isFinishedUpgrade=false
                     if base.allianceHelpSwitch==1 then
                        technologyVoApi:setIsFinishedUpgrade(techVo.id,false)
                     end
                     self:reload()
                     do
                         return
                     end
                end
                local leftTime,totalTime=technologyVoApi:leftTime(techVo.id)
                local progressSp=tolua.cast(v:getChildByTag(self.progressTag2),"CCProgressTimer")
                if progressSp~=nil then
                    progressSp:setPercentage(((totalTime-leftTime)/totalTime)*100)
                    local txtLb=tolua.cast(progressSp:getChildByTag(self.upgradeTextTag2),"CCLabelTTF")
                    txtLb:setString(GetTimeStr(leftTime))
                end

                local isFree=false
                if base.fs==1 then
                  local superMenu=tolua.cast(v:getChildByTag(102),"CCMenu")
                  local freeAccBtn=tolua.cast(v:getChildByTag(103),"CCMenu")
                  if leftTime>self.canSpeedTime then
                      if superMenu then
                        superMenu:setVisible(true)
                        superMenu:setEnabled(true)
                      end
                      if freeAccBtn then
                        freeAccBtn:setVisible(false)
                        freeAccBtn:setEnabled(false)
                      end
                      
                  else
                    if superMenu then
                      superMenu:setVisible(false)
                      superMenu:setEnabled(false)
                    end

                    if freeAccBtn then
                      freeAccBtn:setVisible(true)
                      freeAccBtn:setEnabled(true)
                      isFree=true
                    end
                      
                  end
                end
                if base.allianceHelpSwitch==1 then
                    local superMenu=tolua.cast(v:getChildByTag(102),"CCMenu")
                    local seekHelpBtn=tolua.cast(v:getChildByTag(104),"CCMenu")
                    if seekHelpBtn and superMenu then
                        local tid=techVo.id
                        local techSlotVo=technologySlotVoApi:getSlotByTid(tid)
                        local selfAlliance=allianceVoApi:getSelfAlliance()
                        if selfAlliance and techVo.status==1 and techSlotVo and techSlotVo.hid==nil and isFree==false then
                            seekHelpBtn:setVisible(true)
                            seekHelpBtn:setEnabled(true)
                            superMenu:setVisible(false)
                            superMenu:setEnabled(false)
                        else
                            seekHelpBtn:setVisible(false)
                            seekHelpBtn:setEnabled(false)
                        end
                    end
                end
            end
        end
        if self.speedUpSmallDialog then
            self.speedUpSmallDialog:tick()
        end
    end
end

function techCenterDialog:resetBtn(exBg)
    
    local bvo=buildingVoApi:getBuildiingVoByBId(self.bid)

            --拆除按钮
            local function chaiHandler()
                 PlayEffect(audioCfg.mouseClick)
                 local function chai()
                     buildingVoApi:removeBuild(self.bid)
                     self:close()
                 end
                 local smallD=smallDialog:new()
                 smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),chai,getlocal("dialog_title_prompt"),getlocal("BuildBoard_remove_prompt"),nil,self.layerNum+1)
                 
            end
            local chaiItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",chaiHandler,nil,getlocal("removeBuild"),25)
            local chaiMenu=CCMenu:createWithItem(chaiItem);
            chaiMenu:setPosition(ccp(130,-80))
            chaiMenu:setTouchPriority(-(self.layerNum-1)*20-2);
            chaiMenu:setTag(self.removeBuildBtnTag)
            exBg:addChild(chaiMenu)
            self.fourBtns[1]=chaiMenu
     if bvo.type<16 then
         chaiItem:setVisible(false)
         chaiMenu:setVisible(false)
         chaiMenu:setTouchPriority(1)
     end
            --升级按钮
            local function touch1(tag,object)
                  PlayEffect(audioCfg.mouseClick)
                  if buildingVoApi:upgrade(self.bid,bvo.type) then
                        local leftTime= GetTimeStr(tonumber(Split(buildingCfg[bvo.type].timeConsumeArray,",")[bvo.level+1]))
                        AddProgramTimer(exBg,ccp(exBg:getContentSize().width/2,-20),self.progressTag,self.upgradeTextTag,leftTime,"ty_28.png","ty_29.png",self.bgSpriteTag)
                        self:tick()
                  end
                  
            end
            
            local menuItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touch1,nil,getlocal("upgradeBuild"),25)
            self.allCellsBtn[1]=menuItem
            if result==false then
                menuItem:setEnabled(false)
            end
            local upgradeMenu=CCMenu:createWithItem(menuItem);
            upgradeMenu:setPosition(ccp(exBg:getContentSize().width-100,-80))
            upgradeMenu:setTouchPriority(-(self.layerNum-1)*20-4);
            upgradeMenu:setTag(self.upgradeBtnTag)
            exBg:addChild(upgradeMenu)
            self.fourBtns[2]=upgradeMenu
      if bvo.status==2 then
            local leftTime= GetTimeStr(tonumber(Split(buildingCfg[bvo.type].timeConsumeArray,",")[bvo.level+1]))
                        AddProgramTimer(exBg,ccp(exBg:getContentSize().width/2,-20),self.progressTag,self.upgradeTextTag,leftTime,"ty_28.png","ty_29.png",self.bgSpriteTag)
      end
      
            --取消升级按钮
            local function cancleHandler()
                 PlayEffect(audioCfg.mouseClick)
                 local function cancleUpgrade()
                        if buildingVoApi:cancleUpgradeBuild(self.bid)==false then --取消失败

                        else--取消成功
                             self:tick()
                        end
                 end
                 local smallD=smallDialog:new()
                 smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),cancleUpgrade,getlocal("dialog_title_prompt"),getlocal("BuildBoard_cancel_prompt"),nil,self.layerNum+1)
                 
            end
            local cancleItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",cancleHandler,nil,getlocal("cancelBuild"),25)
            local cancleMenu=CCMenu:createWithItem(cancleItem);
            cancleMenu:setPosition(ccp(130,-80))
            cancleMenu:setTouchPriority(-(self.layerNum-1)*20-2);
            cancleMenu:setTag(self.cancleUpgradeTag)
            exBg:addChild(cancleMenu)
            self.fourBtns[3]=cancleMenu
            --加速升级按钮
             local function superHandler()
                 PlayEffect(audioCfg.mouseClick)
                 local function superUpgrade()
               
                      if buildingVoApi:superUpgradeBuild(self.bid) then --加速成功
                           
                      end
                 end
                 local bsv=buildingSlotVoApi:getSlotByBid(bvo.id)
        if bsv==nil then
             return
        end
                 local leftTime=base.serverTime-bsv.st-tonumber(Split(buildingCfg[bvo.type].timeConsumeArray,",")[bvo.level+1])
                 if leftTime<0 then
                        local needGemsNum=TimeToGems(-leftTime)
                        local needGems=getlocal("speedUp",{needGemsNum})
                     if needGemsNum>playerVoApi:getGems() then --金币不足
                        GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),self.layerNum+1,needGemsNum)
                     else
                        local smallD=smallDialog:new()
                        smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),superUpgrade,getlocal("dialog_title_prompt"),needGems,nil,self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,nil,getlocal("recommendJoinAlliance_lbDes"))
                     end
                 end

            end
            local superItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",superHandler,nil,getlocal("accelerateBuild"),25)
            local superMenu=CCMenu:createWithItem(superItem);
            superMenu:setPosition(ccp(exBg:getContentSize().width-100,-80))
            superMenu:setTouchPriority(-(self.layerNum-1)*20-2);
            superMenu:setTag(self.superUpgradeTag)
            exBg:addChild(superMenu)
            self.fourBtns[4]=superMenu

            self:tick()
end

function techCenterDialog:releaseVar()
      self.requires=nil
      self.requires={}
      self.allCellsBtn=nil
      self.allCellsBtn={}
      self.expandIdx=nil
      self.expandIdx={}
      self.exBg=nil
       self.fourBtns={}
      self.tmLb=nil
     self.bDescLb=nil

    self.allTechData=nil
    self.cellHeader=nil
    self.cellHeader={}
end

function techCenterDialog:reload()

        self:releaseVar()
        if self.selectedTabIndex==1 then
             self.allTechData=technologyVoApi:getAllInfo()
        end
        if self.tv~=nil then
            self.tv:reloadData()
        end
end

function techCenterDialog:dispose()
  if self.speedUpSmallDialog then
      self.speedUpSmallDialog:close()
      self.speedUpSmallDialog = nil
  end
  self.isShowPoint=nil
  self.layerNum=nil
  self.requires=nil
  self.allCellsBtn=nil

  self.exBg=nil
  self.fourBtns=nil
  self.tmLb=nil
  self.bDescLb=nil
  self.upgradeDialog:dispose()
  self.upgradeDialog=nil
  --科技升级页面
 self.expandIdx=nil
 self.allTechData=nil

  self.cellHeader=nil
  eventDispatcher:removeEventListener("techslot.speedup",self.speedUpListener)
  self.btnItem = nil
end



