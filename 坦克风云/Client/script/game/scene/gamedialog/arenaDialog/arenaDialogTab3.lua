arenaDialogTab3={

}

function arenaDialogTab3:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.parent=parent
    self.bgLayer=nil
    self.allTabs={}
    self.selectedTabIndex=0
    self.bgLayer1=nil
    self.bgLayer2=nil
    self.tv1=nil
    self.tv2=nil
    self.tv3=nil
    self.cellheight1=70
    
    self.tvHeight=nil
   
    return nc
end

function arenaDialogTab3:init(layerNum)
    self.layerNum=layerNum;
    self.bgLayer=CCLayer:create();
    self:initTabLayer()
    
    return self.bgLayer
end

function arenaDialogTab3:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do

           tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabelWrap(v,24,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
           lb:setTag(31)
           if k~=1 then
              lb:setColor(G_TabLBColorGreen)
           end
           
           
            local numHeight=25
            local iconWidth=36
            local iconHeight=36
            local newsNumLabel = GetTTFLabel("0",numHeight)
            newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
            newsNumLabel:setTag(11)
            local capInSet1 = CCRect(17, 17, 1, 1)
            local function touchClick()
            end
            local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
            if newsNumLabel:getContentSize().width+10>iconWidth then
                iconWidth=newsNumLabel:getContentSize().width+10
            end
            newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
            newsIcon:ignoreAnchorPointForPosition(false)
            newsIcon:setAnchorPoint(CCPointMake(1,0.5))
            newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-2,tabBtnItem:getContentSize().height-30))
            newsIcon:addChild(newsNumLabel,1)
            newsIcon:setTag(10)
            newsIcon:setVisible(false)
            tabBtnItem:addChild(newsIcon)
           
           --local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
           local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
           lockSp:setAnchorPoint(CCPointMake(0,0.5))
           lockSp:setPosition(ccp(10,tabBtnItem:getContentSize().height/2))
           lockSp:setScaleX(0.7)
           lockSp:setScaleY(0.7)
           tabBtnItem:addChild(lockSp,3)
           lockSp:setTag(30)
           lockSp:setVisible(false)
            
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   tabBtn:setPosition(0,0)
   self.bgLayer:addChild(tabBtn)

end

--设置或修改每个Tab页签
function arenaDialogTab3:resetTab()
    self.allTabs={getlocal("arena_top100"),getlocal("arena_luckyRank")}


    self:initTab(self.allTabs)
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
            tabBtnItem:setPosition(100,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==1 then
            tabBtnItem:setPosition(248,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==2 then
            tabBtnItem:setPosition(394,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==3 then
            tabBtnItem:setPosition(540,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    
end

function arenaDialogTab3:initTabLayer()
    self:resetTab()
    self:initTabLayer1()
    self:initTabLayer2()
end

function arenaDialogTab3:initTabLayer1()
    self.bgLayer1=CCLayer:create();
    self.bgLayer:addChild(self.bgLayer1,2)

    local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
    bgSp:setPosition(ccp(self.bgLayer1:getContentSize().width/2,G_VisibleSize.height-240));
    bgSp:setScaleY(60/bgSp:getContentSize().height)
    bgSp:setScaleX(1200/bgSp:getContentSize().width)
    self.bgLayer1:addChild(bgSp)

    local descLb=GetTTFLabelWrap(getlocal("arena_top100Des"),25,CCSizeMake(self.bgLayer1:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0.5,0.5))
    descLb:setPosition(ccp(self.bgLayer1:getContentSize().width/2,G_VisibleSize.height-240))
    self.bgLayer1:addChild(descLb,1)

    

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setPosition(ccp(self.bgLayer1:getContentSize().width/2,G_VisibleSize.height-270));
    self.bgLayer1:addChild(lineSp,1)

    local hi=G_VisibleSize.height-305
    local tlbSize=26
    local tLb1 = GetTTFLabel(getlocal("alliance_scene_rank"),tlbSize);
    tLb1:setAnchorPoint(ccp(0,0.5));
    tLb1:setPosition(ccp(70,hi));
    self.bgLayer1:addChild(tLb1,2);

    local tLb2 = GetTTFLabel(getlocal("alliance_scene_button_info_name"),tlbSize);
    tLb2:setAnchorPoint(ccp(0,0.5));
    tLb2:setPosition(ccp(210,hi));
    self.bgLayer1:addChild(tLb2,2);

    local tLb3 = GetTTFLabel(getlocal("RankScene_level"),tlbSize);
    tLb3:setAnchorPoint(ccp(0,0.5));
    tLb3:setPosition(ccp(375,hi));
    self.bgLayer1:addChild(tLb3,2);

    local tLb4 = GetTTFLabel(getlocal("showAttackRank"),tlbSize);
    tLb4:setAnchorPoint(ccp(0.5,0.5));
    tLb4:setPosition(ccp(540,hi));
    self.bgLayer1:addChild(tLb4,2);

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setPosition(ccp(self.bgLayer1:getContentSize().width/2,G_VisibleSize.height-340));
    self.bgLayer1:addChild(lineSp,1)

    self:initTableView1()


end

function arenaDialogTab3:initTableView1()
    self.rankList=arenaVoApi:getArenaVo().ranklist
    local function callBack1(...)
       return self:eventHandler1(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    local height=0;
    self.tv1=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-380),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv1:setPosition(ccp(30,30))
    self.bgLayer1:addChild(self.tv1,3)
    self.tv1:setMaxDisToBottomOrTop(120)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function arenaDialogTab3:eventHandler1(handler,fn,idx,cel)
if fn=="numberOfCellsInTableView" then
            
           local num=SizeOfTable(self.rankList)
           return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(600,self.cellheight1)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
       lineSp:setAnchorPoint(ccp(0,0));
       lineSp:setPosition(ccp(0,0));
       cell:addChild(lineSp,1)

       local tlbSize=25
       local tLb1 = GetTTFLabel(idx+1,tlbSize);
       tLb1:setPosition(ccp(65,self.cellheight1/2+5));
       cell:addChild(tLb1,2);

       local nameStr = self.rankList[idx+1][2]
        if self.rankList[idx+1][1]<=450 then
            nameStr=arenaVoApi:getNpcNameById(self.rankList[idx+1][1])
        end

       local tLb2 = GetTTFLabelWrap(nameStr,tlbSize,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
       tLb2:setPosition(ccp(210,self.cellheight1/2+5));
       cell:addChild(tLb2,2);

       local tLb3 = GetTTFLabel(self.rankList[idx+1][3],tlbSize);
       tLb3:setPosition(ccp(370,self.cellheight1/2+5));
       cell:addChild(tLb3,2);

       local fightNum=FormatNumber(self.rankList[idx+1][4])
       local tLb4 = GetTTFLabel(fightNum,tlbSize);
       tLb4:setPosition(ccp(510,self.cellheight1/2+5));
       cell:addChild(tLb4,2);

       if self.rankList[idx+1][1]==playerVoApi:getUid() then
       		tLb1:setColor(G_ColorYellowPro)
       		tLb2:setColor(G_ColorYellowPro)
       		tLb3:setColor(G_ColorYellowPro)
       		tLb4:setColor(G_ColorYellowPro)
       end


       --self.rankList

       return cell;

       elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
       elseif fn=="ccTouchMoved" then
           self.isMoved=true
       elseif fn=="ccTouchEnded"  then
           
       elseif fn=="ccScrollEnable" then
                return 1
        end

end

function arenaDialogTab3:initTabLayer2()
    self.bgLayer2=CCLayer:create();
    self.bgLayer:addChild(self.bgLayer2,2)
    self.bgLayer2:setPosition(ccp(10000,0))

    local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
    bgSp:setAnchorPoint(ccp(0.5,1))
    bgSp:setPosition(ccp(self.bgLayer2:getContentSize().width/2,G_VisibleSize.height-208));
    bgSp:setScaleX(1200/bgSp:getContentSize().width)
    self.bgLayer2:addChild(bgSp)

    local adx=50
    local swidth=550
    local descLb1=GetTTFLabelWrap(getlocal("arena_luckyDes1"),23,CCSizeMake(swidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb1:setAnchorPoint(ccp(0,1))
    descLb1:setPosition(ccp(adx,G_VisibleSize.height-215))
    self.bgLayer2:addChild(descLb1,2)

    local descLb2=GetTTFLabelWrap(getlocal("arena_luckyDes2"),23,CCSizeMake(swidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb2:setAnchorPoint(ccp(0,1))
    descLb2:setPosition(ccp(adx,G_VisibleSize.height-220-descLb1:getContentSize().height))
    self.bgLayer2:addChild(descLb2,2)

    local rTimeStr = G_getTimeStr(arenaVoApi:getRewardTime())

    self.descLb3=GetTTFLabelWrap(getlocal("arena_luckyDes3",{rTimeStr}),23,CCSizeMake(swidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.descLb3:setAnchorPoint(ccp(0,1))
    self.descLb3:setPosition(ccp(adx,G_VisibleSize.height-225-descLb1:getContentSize().height-descLb2:getContentSize().height))
    self.bgLayer2:addChild(self.descLb3,2)

    local sheight = descLb1:getContentSize().height+descLb2:getContentSize().height+self.descLb3:getContentSize().height+30
    bgSp:setScaleY(sheight/bgSp:getContentSize().height)


    local rankLb1 = GetTTFLabelWrap(getlocal("arena_luckyRank1"),28,CCSizeMake((self.bgLayer2:getContentSize().width-60)/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    rankLb1:setAnchorPoint(ccp(0.5,1));
    rankLb1:setPosition(ccp(180,G_VisibleSize.height-220-sheight));
    self.bgLayer2:addChild(rankLb1,2);

    local rankLb2 = GetTTFLabelWrap(getlocal("arena_luckyRank2"),28,CCSizeMake((self.bgLayer2:getContentSize().width-60)/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    rankLb2:setAnchorPoint(ccp(0.5,1));
    rankLb2:setPosition(ccp(480,G_VisibleSize.height-220-sheight));
    self.bgLayer2:addChild(rankLb2,2);

    local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp3:setPosition(ccp(self.bgLayer2:getContentSize().width/2,rankLb1:getPositionY()-rankLb1:getContentSize().height-10));
    self.bgLayer2:addChild(lineSp3,1)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setAnchorPoint(ccp(0,1))
    lineSp:setRotation(90)
    lineSp:setPosition(ccp(360,lineSp3:getPositionY()-20))
    self.bgLayer2:addChild(lineSp,1)

    local hi=lineSp3:getPositionY()-20
    local tlbSize=23
    local tLb1 = GetTTFLabel(getlocal("alliance_scene_rank"),tlbSize);
    tLb1:setAnchorPoint(ccp(0,1));
    tLb1:setPosition(ccp(50,hi));
    self.bgLayer2:addChild(tLb1,2);

    local tLb2 = GetTTFLabel(getlocal("alliance_scene_button_info_name"),tlbSize);
    tLb2:setAnchorPoint(ccp(0,1));
    tLb2:setPosition(ccp(150,hi));
    self.bgLayer2:addChild(tLb2,2);

    local tLb3 = GetTTFLabel(getlocal("gem"),tlbSize);
    tLb3:setAnchorPoint(ccp(0,1));
    tLb3:setPosition(ccp(270,hi));
    self.bgLayer2:addChild(tLb3,2);

    local tLb4 = GetTTFLabel(getlocal("alliance_scene_rank"),tlbSize);
    tLb4:setAnchorPoint(ccp(0,1));
    tLb4:setPosition(ccp(410,hi));
    self.bgLayer2:addChild(tLb4,2);

    local tLb5 = GetTTFLabel(getlocal("gem"),tlbSize);
    tLb5:setAnchorPoint(ccp(0,1));
    tLb5:setPosition(ccp(520,hi));
    self.bgLayer2:addChild(tLb5,2);
    
    self.tvHeight = hi-50;

    self:initTableView2()
    self:initTableView3()


end

function arenaDialogTab3:initTableView2()
    self.upluckList=arenaVoApi:getArenaVo().luckrank.uprank
    local function callBack1(...)
       return self:eventHandler2(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    local height=0;
    self.tv2=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(300,self.tvHeight),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(30,30))
    self.bgLayer2:addChild(self.tv2,3)
    self.tv2:setMaxDisToBottomOrTop(120)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function arenaDialogTab3:eventHandler2(handler,fn,idx,cel)
if fn=="numberOfCellsInTableView" then
            
           local num=SizeOfTable(self.upluckList);
           return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(300,70)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
       lineSp:setScaleX(0.6)
       lineSp:setAnchorPoint(ccp(0,0));
       lineSp:setPosition(ccp(0,0));
       cell:addChild(lineSp,1)

       local tlbSize=20
       local tLb1 = GetTTFLabel(self.upluckList[idx+1][1],tlbSize);
       tLb1:setPosition(ccp(40,70/2));
       cell:addChild(tLb1,2);

       local nameStr = self.upluckList[idx+1][3]
       if self.upluckList[idx+1][2]<=450 then
            nameStr=arenaVoApi:getNpcNameById(self.upluckList[idx+1][2])
       end

       local tLb2 = GetTTFLabelWrap(nameStr,tlbSize,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
       tLb2:setPosition(ccp(150,70/2));
       cell:addChild(tLb2,2);

       local goldnum=arenaCfg.bigReward.u[1].gems
       if idx+1>3 then
          goldnum=arenaCfg.smallReward.u[1].gems
       end
       local tLb3 = GetTTFLabel(goldnum,tlbSize);
       tLb3:setPosition(ccp(260,70/2));
       cell:addChild(tLb3,2);



       return cell;

       elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
       elseif fn=="ccTouchMoved" then
           self.isMoved=true
       elseif fn=="ccTouchEnded"  then
           
       elseif fn=="ccScrollEnable" then
                return 1
       end

end

function arenaDialogTab3:initTableView3()
    self.dnrankList=arenaVoApi:getArenaVo().luckrank.dnrank
    local function callBack1(...)
       return self:eventHandler3(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    local height=0;
    self.tv3=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(240,self.tvHeight),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv3:setPosition(ccp(370,30))
    self.bgLayer2:addChild(self.tv3,3)
    self.tv3:setMaxDisToBottomOrTop(120)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function arenaDialogTab3:eventHandler3(handler,fn,idx,cel)
if fn=="numberOfCellsInTableView" then
            
           local num=SizeOfTable(self.dnrankList)
           return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
            tmpSize=CCSizeMake(240,70)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
       lineSp:setScaleX(0.4)
       lineSp:setAnchorPoint(ccp(0,0));
       lineSp:setPosition(ccp(0,0));
       cell:addChild(lineSp,1)

       local tlbSize=20
       local rankNum=self.dnrankList[idx+1]
       if type(self.dnrankList[idx+1])=="table" then
          rankNum=self.dnrankList[idx+1][1]
       end
       local tLb1 = GetTTFLabel(rankNum,tlbSize);
       tLb1:setPosition(ccp(60,70/2));
       cell:addChild(tLb1,2);

       local goldnum=arenaCfg.bigReward.u[1].gems
       if idx+1>3 then
          goldnum=arenaCfg.smallReward.u[1].gems
       end
       local tLb2 = GetTTFLabel(goldnum,tlbSize);
       tLb2:setPosition(ccp(170,70/2));
       cell:addChild(tLb2,2);

       return cell;

       elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
       elseif fn=="ccTouchMoved" then
           self.isMoved=true
       elseif fn=="ccTouchEnded"  then
           
       elseif fn=="ccScrollEnable" then
                return 1
       end

end

function arenaDialogTab3:tick()
  self.descLb3=tolua.cast(self.descLb3,"CCLabelTTF")
  local rTimeStr = G_getTimeStr(arenaVoApi:getRewardTime())
  self.descLb3:setString(getlocal("arena_nextAward",{rTimeStr}))
end

function arenaDialogTab3:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)
         else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
         end
    end
    
    if self.selectedTabIndex==0 then
       self.bgLayer1:setVisible(true)
       self.bgLayer1:setPosition(ccp(0,0))
       
       self.bgLayer2:setVisible(false)
       self.bgLayer2:setPosition(ccp(10000,0))

    elseif self.selectedTabIndex==1 then
       self.bgLayer2:setVisible(true)
       self.bgLayer2:setPosition(ccp(0,0))
       
       self.bgLayer1:setVisible(false)
       self.bgLayer1:setPosition(ccp(10000,0))


    end
    --self.tv:reloadData()
end

--用户处理特殊需求,没有可以不写此方法
function arenaDialogTab3:doUserHandler()

end

function arenaDialogTab3:dispose()
    
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.layerNum=nil;
    
end