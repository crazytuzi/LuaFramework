--require "luascript/script/componet/commonDialog"
commanderCenterDialog=commonDialog:new()

function commanderCenterDialog:new(bid,isShowPoint)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
  self.bid=bid
    self.isShowPoint=isShowPoint
    self.expandIdx={}
  self.normalHeight=155
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
  return nc
end

--设置或修改每个Tab页签
function commanderCenterDialog:resetTab()

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
function commanderCenterDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-190),nil)
    self.bgLayer:setTouchPriority(-41)
    self.tv:setTableViewTouchPriority(1)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
    --任务跳转指引
    if self.btnItem ~= nil then 
      local groupId = G_getGroupIdByBid(self.bid)
      local x,y,z,w  = G_getSpriteWorldPosAndSize(self.btnItem, 1)
      newSkipCfg[groupId].clickRect = CCRectMake(x,y+G_VisibleSize.height,z,w)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function commanderCenterDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
         tmpSize=CCSizeMake(600,self.expandHeight)
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
function commanderCenterDialog:tabClick(idx)
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
function commanderCenterDialog:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function commanderCenterDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
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
function commanderCenterDialog:loadCCTableViewCell(cell,idx,refresh)
   if self.selectedTabIndex==0 then
       self.upgradeDialog=buildingUpgradeCommon:new()
       self.upgradeDialog:init(cell,self.bgLayer,self.bid,self,nil,self.isShowPoint)
       self.btnItem = self.upgradeDialog.allCellsBtn[1]

   else --“说明”页签
       cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.expandHeight))
       local smInfo=""
       for m=1,10 do
          smInfo=smInfo..getlocal("command_scene_info_"..tostring(m)).."\n"
       end
       local infoLb=GetTTFLabelWrap(smInfo,20,CCSize(self.bgLayer:getContentSize().width-60,self.expandHeight),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
       infoLb:setAnchorPoint(ccp(0,1))
       infoLb:setPosition(ccp(10,self.expandHeight-20))
       cell:addChild(infoLb)
   end
end

function commanderCenterDialog:tick()

     local bvo=buildingVoApi:getBuildiingVoByBId(self.bid)
     local bcfg=buildingCfg[bvo.type]
    if self.selectedTabIndex==0 then
            self.upgradeDialog:tick()
      else --"说明页签"
          
      end
end

function commanderCenterDialog:resetBtn(exBg)
    
    local bvo=buildingVoApi:getBuildiingVoByBId(self.bid)

            --拆除按钮
            local function chaiHandler()
                 PlayEffect(audioCfg.mouseClick)
                 local function chai()
                     buildingVoApi:removeBuild(self.bid)
                     self:close()
                 end
                 local smallD=smallDialog:new()
                 smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),chai,getlocal("dialog_title_prompt"),getlocal("BuildBoard_remove_prompt"),nil,4)
                 
            end
            local chaiItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",chaiHandler,nil,getlocal("removeBuild"),25)
            local chaiMenu=CCMenu:createWithItem(chaiItem);
            chaiMenu:setPosition(ccp(130,-80))
            chaiMenu:setTouchPriority(-42);
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
            upgradeMenu:setTouchPriority(-42);
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
                 smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),cancleUpgrade,getlocal("dialog_title_prompt"),getlocal("BuildBoard_cancel_prompt"),nil,4)
                 
            end
            local cancleItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",cancleHandler,nil,getlocal("cancelBuild"),25)
            local cancleMenu=CCMenu:createWithItem(cancleItem);
            cancleMenu:setPosition(ccp(130,-80))
            cancleMenu:setTouchPriority(-42);
            cancleMenu:setTag(self.cancleUpgradeTag)
            exBg:addChild(cancleMenu)
            self.fourBtns[3]=cancleMenu
            --加速升级按钮
             local function superHandler()
                 PlayEffect(audioCfg.mouseClick)
                 local function superUpgrade()
               
                      if buildingVoApi:superUpgradeBuild(self.bid) then --加速成功
                         
                          self:tick()
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
                        GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),5,needGemsNum)
                     else
                        local smallD=smallDialog:new()
                        smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),superUpgrade,getlocal("dialog_title_prompt"),needGems,nil,4)
                     end
                 end

            end
            local superItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",superHandler,nil,getlocal("accelerateBuild"),25)
            local superMenu=CCMenu:createWithItem(superItem);
            superMenu:setPosition(ccp(exBg:getContentSize().width-100,-80))
            superMenu:setTouchPriority(-42);
            superMenu:setTag(self.superUpgradeTag)
            exBg:addChild(superMenu)
            self.fourBtns[4]=superMenu

            self:tick()
end

function commanderCenterDialog:dispose()
    self.upgradeDialog:dispose()
    self.expandHeight=820
    self.requires=nil
    self.allCellsBtn=nil
    self.fourBtns=nil
      self.upgradeDialog=nil
    self.isShowPoint=nil
end












