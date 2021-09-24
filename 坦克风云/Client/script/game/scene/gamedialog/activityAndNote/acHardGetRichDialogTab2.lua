acHardGetRichDialogTab2={}

function acHardGetRichDialogTab2:new(parent,layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.parent=parent
    self.bgLayer=nil
    self.expandIdx={}
    self.bgSize=nil
    self.tv=nil
    self.expandHeight=G_VisibleSize.height-140+102
    self.normalHeight=120
    self.extendSpTag=113
    
    self.desCellHeight=nil

    return nc
end

function acHardGetRichDialogTab2:init()
    self.bgLayer=CCLayer:create();
    self:initLayer()
    return self.bgLayer
end
function acHardGetRichDialogTab2:initLayer()
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setAnchorPoint(ccp(0,0));
    lineSp:setPosition(ccp(30,self.bgLayer:getContentSize().height-290));
    self.bgLayer:addChild(lineSp,1)
    self:initTableView()
    self:initTableView1()

end

function acHardGetRichDialogTab2:initTableView1()
    local function callBack(...)
       return self:eventHandler1(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,100),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv1:setAnchorPoint(ccp(0,1))
    self.tv1:setPosition(ccp(0,self.bgLayer:getContentSize().height-280))
    self.bgLayer:addChild(self.tv1)
    self.tv1:setMaxDisToBottomOrTop(50)

end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acHardGetRichDialogTab2:eventHandler1(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1

   elseif fn=="tableCellSizeForIndex" then
   
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage=="tw" then
            self.desCellHeight = 230
        else
            self.desCellHeight = 330
        end
       local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.desCellHeight)

       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local descLabel1=GetTTFLabelWrap(getlocal("activity_getRich_goaldes1"),24,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLabel1:setAnchorPoint(ccp(0,1))
        descLabel1:setPosition(ccp(60,self.desCellHeight))
        cell:addChild(descLabel1,5)

        local descLabel=GetTTFLabelWrap(getlocal("activity_getRich_goaldes2"),24,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLabel:setAnchorPoint(ccp(0,1))
        descLabel:setPosition(ccp(60,self.desCellHeight-descLabel1:getContentSize().height))
        cell:addChild(descLabel,5)


        return cell

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end


function acHardGetRichDialogTab2:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-322),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acHardGetRichDialogTab2:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 5

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize

       if self.expandIdx["k"..idx]~=nil then
          tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,self.expandHeight)
       else
          tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,self.normalHeight)
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

function acHardGetRichDialogTab2:loadCCTableViewCell(cell,idx)
       local expanded=false
       if self.expandIdx["k"..idx]==nil then
             expanded=false
       else
             expanded=true
       end
       if expanded then
            cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.expandHeight))
       else
            cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.normalHeight))
       end
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
            return self:cellClick(idx)
       end
       local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
       headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.normalHeight-4))
       headerSprie:ignoreAnchorPointForPosition(false);
       headerSprie:setAnchorPoint(ccp(0,0));
       headerSprie:setTag(1000+idx)
       headerSprie:setIsSallow(false)
       headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
       cell:addChild(headerSprie)


       local index=idx+1
       local tb={"gold","r1","r2","r3","r4"}
       local num,goalTb = acHardGetRichVoApi:getPersonGoalByKey(tb[index])
       local lbstr="activity_getRich_goal"..index
       local nameLb=GetTTFLabel(getlocal(lbstr,{num,4}),30)
       nameLb:setAnchorPoint(ccp(0,0.5))
       nameLb:setPosition(ccp(40,headerSprie:getContentSize().height/2))
       headerSprie:addChild(nameLb,5);

       local btn
       if expanded==false then
           btn=CCSprite:createWithSpriteFrameName("moreBtn.png")
       else
           btn=CCSprite:createWithSpriteFrameName("lessBtn.png")
       end
       btn:setAnchorPoint(ccp(0,0))
       btn:setPosition(ccp(headerSprie:getContentSize().width-10-btn:getContentSize().width,5))
       headerSprie:addChild(btn)
       btn:setTag(self.extendSpTag)

       if expanded==true then --显示展开信息
       
          local function touchHander()
          
          end
          local rect = CCRect(0, 0, 50, 50);
          local capInSet = CCRect(40, 40, 10, 10);
          local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemInforBg.png",capInSet,touchHander)
          exBg:setAnchorPoint(ccp(0,0))
          exBg:setContentSize(CCSize(620,self.expandHeight-self.normalHeight))
          exBg:setPosition(ccp(0,0))
          exBg:setTag(2)
          cell:addChild(exBg)
          local heightExBg=exBg:getContentSize().height
          for i=1,4 do
              self:exbgCellForId(idx+1,exBg,heightExBg-110*i,i)
          end


          

        end

end

function acHardGetRichDialogTab2:exbgCellForId(type,parent,m_height,idx)

    local numGoal=FormatNumber(activityCfg.hardGetRich.personalGoal[idx])
    local nameLb=GetTTFLabel(getlocal("activity_getRich_getGoal",{numGoal}),30)
    nameLb:setAnchorPoint(ccp(0,0.5))
    nameLb:setPosition(ccp(40,m_height))
    parent:addChild(nameLb,5);

    local goalStr=""
    local goalnum = activityCfg.hardGetRich.personalGoal[idx]
    local tb={"gold","r1","r2","r3","r4"}
    local curnum = 0
    goalStr=FormatNumber(goalnum)
    curnum=acHardGetRichVoApi:getResTb()[tb[type]]

    local goalLb=GetTTFLabel(getlocal("scheduleChapter",{FormatNumber(curnum),goalStr}),30)
    goalLb:setAnchorPoint(ccp(1,0.5))
    goalLb:setPosition(ccp(500,m_height))
    parent:addChild(goalLb,5);


    local function touchInfo()
        local td=smallDialog:new()
        local str1=getlocal("activity_getRich_finishGoalReward");
        local award=FormatItem(acHardGetRichVoApi:getPersonreward()[idx]) or {}
        local str2=G_showRewardStr(award)
        --local str2=getlocal("activity_getRich_notice1");
        tabStr={" ",str2,str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    
    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(555,m_height));
    menu:setTouchPriority(-(self.layerNum-1)*20-2);
    parent:addChild(menu,3);

    


    

    local goal,goalTb=acHardGetRichVoApi:getPersonGoalByKey(tb[type])
    local menux=430
    if goalTb[idx]==1 then
        local function callback( ... )
        end
       local menuItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",callback,11,getlocal("activity_hadReward"),25)
        local menu = CCMenu:createWithItem(menuItem);
        menuItem:setAnchorPoint(ccp(0.5,0.5))
        menu:setPosition(ccp(menux,m_height));
        menu:setTouchPriority(-(self.layerNum-1)*20-5);
        menuItem:setEnabled(false)
        parent:addChild(menu,3);
        goalLb:setVisible(false)
    else
        local function callbackRank()
            local function callback()
              
            end
            local function callback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    local award=FormatItem(acHardGetRichVoApi:getPersonreward()[idx]) or {}
                    for k,v in pairs(award) do
                      G_addPlayerAward(v.type,v.key,v.id,v.num)
                    end
                    G_showRewardTip(award, true)
                    acHardGetRichVoApi:setIsReward(tb[type],idx)
                    self.tv:reloadData()
                    local acvo=activityVoApi:getActivityVo("hardGetRich")
                    activityVoApi:updateShowState(acvo)
                end
            end
            socketHelper:activeHardgetrich(tb[type],idx,callback)
        end
        local menuItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",callbackRank,11,getlocal("newGiftsReward"),25)
        local menu = CCMenu:createWithItem(menuItem);
        menuItem:setAnchorPoint(ccp(0.5,0.5))
        menu:setPosition(ccp(menux,m_height));
        menu:setTouchPriority(-(self.layerNum-1)*20-5);
        menu:setVisible(false)
        parent:addChild(menu,3);
        if curnum>=goalnum then
          goalLb:setVisible(false)
          menu:setVisible(true)
        end

    end
    

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setAnchorPoint(ccp(0,0));
    lineSp:setPosition(ccp(30,m_height-50));
    parent:addChild(lineSp,1)

end

--点击了cell或cell上某个按钮
function acHardGetRichDialogTab2:cellClick(idx)
 if self.tv==nil then
    do
        return
    end
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

function acHardGetRichDialogTab2:refreshTv()
  self.tv:reloadData()
end


function acHardGetRichDialogTab2:tick()

end

function acHardGetRichDialogTab2:dispose()
    self.desCellHeight=nil
    self.bgLayer=nil
    self=nil

end




