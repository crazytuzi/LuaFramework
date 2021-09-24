friendDialog=commonDialog:new()

function friendDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.layerTab1=nil
    self.layerTab2=nil
    
    self.friendTab1=nil
    self.friendTab2=nil

    self.pageUpBtn=nil
    self.pageDownBtn=nil
    return nc
end

function friendDialog:init(bgSrc,isfullScreen,size,fullRect,inRect,tabTb,subTabTb,closeBtnSrc,titleStr,needRefresh,layerNum)
    base:setWait()
    if needRefresh~=nil and needRefresh then
        base:addNeedRefresh(self)
    end
      
    if layerNum==nil then
        layerNum=3
    end
    self.layerNum=layerNum
    local rect=CCSizeMake(1,1)
    local function tmpFunc()
    end
    local forbidBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    forbidBg:setContentSize(CCSizeMake(640,1136))
    forbidBg:ignoreAnchorPointForPosition(false)
    forbidBg:setAnchorPoint(CCPointMake(0,0))
    forbidBg:setTouchPriority(-(layerNum-1)*20-1)
    forbidBg:setVisible(false)
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.bgLayer=dialogBg
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:addChild(forbidBg)
    if isfullScreen then
        rect=CCSizeMake(640,G_VisibleSize.height)
    elseif size then
        rect=size
    end
    self.bgSize=rect
    dialogBg:setContentSize(rect)
    dialogBg:ignoreAnchorPointForPosition(false)
    dialogBg:setAnchorPoint(CCPointMake(0.5,0.5))
    dialogBg:setPosition(CCPointMake(G_VisibleSize.width/2,-G_VisibleSize.height/2))
    if titleStr~=nil then
        self.titleLabel = GetTTFLabel(titleStr,40);
        self.titleLabel:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-40))
        dialogBg:addChild(self.titleLabel,2);
    end
      
    self.panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",inRect,tmpFunc)
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66))
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-180))
    self.bgLayer:addChild(self.panelLineBg)

    local function close()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
    dialogBg:addChild(self.closeBtn)

    local tabBtn=CCMenu:create()
    local tabIndex=0
    local tabBtnItem;
    if tabTb~=nil then
        for k,v in pairs(tabTb) do
            tabBtnItem = CCMenuItemImage:create("tabBtnSmall.png", "tabBtnSmall_Selected.png","tabBtnSmall_Selected.png")
            tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

            local function tabClick(idx)
                self:tabClickColor(idx)
                return self:tabClick(idx)
            end
            tabBtnItem:registerScriptTapHandler(tabClick)
           
            local lb=GetTTFLabelWrap(v,30,CCSizeMake((self.bgLayer:getContentSize().width-20)/SizeOfTable(tabTb),0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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
            newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width,tabBtnItem:getContentSize().height-15))
            newsIcon:addChild(newsNumLabel,1)
            newsIcon:setTag(10)
            newsIcon:setVisible(false)
            tabBtnItem:addChild(newsIcon)

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
            tabBtn:setTouchPriority(-(layerNum-1)*20-4)
            tabBtnItem:setTag(tabIndex)
            tabIndex=tabIndex+1
       end
   end
   if subTabTb~=nil then
       local subTabIndex=0
       for k,v in pairs(subTabTb) do
           local tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))
           local function tabSubClick(idx)
               return self:tabSubClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabSubClick)
           local lb=GetTTFLabelWrap(v,20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
           self.allSubTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtnItem:setTag(subTabIndex+10)
           subTabIndex=subTabIndex+1
       end
    end  

   self:resetTab()
   self:doUserHandler()
   tabBtn:setPosition(0,0)
  dialogBg:addChild(tabBtn)
   
   self:initTableView()
   if newGuidMgr:isNewGuiding() then
        if self.tv~=nil then
            self.tv:setTableViewTouchPriority(100)
        end
   end
   local function forbidClick()
   end
   local rect2 = CCRect(0, 0, 50, 50);
   local capInSet = CCRect(20, 20, 10, 10);
   self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   self.topforbidSp:setTouchPriority(-(layerNum-1)*20-3)
   self.topforbidSp:setAnchorPoint(ccp(0,0))
   self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
   self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-3)
   self.bottomforbidSp:setAnchorPoint(ccp(0,0))
    local tvX,tvY
    local topY
    if(self.tv)then
        tvX,tvY=self.tv:getPosition()
        topY=tvY+self.tv:getViewSize().height
    else
        tvX=0
        tvY=0
        topY=0
    end
   local topHeight=rect.height-topY
   self.topforbidSp:setContentSize(CCSize(rect.width,topHeight))
   self.topforbidSp:setPosition(0,topY)
   dialogBg:addChild(self.topforbidSp)

   dialogBg:addChild(self.bottomforbidSp)
   self:resetForbidLayer()
   self.topforbidSp:setVisible(false)
   self.bottomforbidSp:setVisible(false)

   self.dialogLayer:addChild(dialogBg)
   self:show()
   return self.dialogLayer
end
--设置或修改每个Tab页签
function friendDialog:resetTab()
    local index=0
    local layerSize=self.bgLayer:getContentSize()
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v

        if index==0 then
            tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        elseif index==1 then
            tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1
    end
    local indexSub=0
    for k,v in pairs(self.allSubTabs) do
        local  tabBtnItem=v

        if indexSub==0 then
            tabBtnItem:setPosition(100,self.bgSize.height-tabBtnItem:getContentSize().height/2-160)
        elseif indexSub==1 then
            tabBtnItem:setPosition(248,self.bgSize.height-tabBtnItem:getContentSize().height/2-160)
        elseif indexSub==2 then
            tabBtnItem:setPosition(394,self.bgSize.height-tabBtnItem:getContentSize().height/2-160)
        elseif indexSub==3 then
            tabBtnItem:setPosition(540,self.bgSize.height-tabBtnItem:getContentSize().height/2-160)
        end
        if indexSub==self.selectedSubTabIndex then
            tabBtnItem:setEnabled(false)
        end
        indexSub=indexSub+1
    end
    local function showInfo()
        local tabStr={};
        local tabColor ={};
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        tabStr = {"\n",getlocal("friend_desc"),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    local tmp1=infoItem:getContentSize()
    infoBtn:setPosition(ccp(521,layerSize.height-120));
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,3);
    self.selectedTabIndex = 0
    self.selectedSubTabIndex = 0;
end

--设置对话框里的tableView
function friendDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.tv:setTableViewTouchPriority(1)
    self.tv:setPosition(ccp(30,30))
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)
    local capInSet = CCRect(20, 20, 10, 10);
    local function click(hd,fn,idx)
    end
    self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,click)
    if(friendVoApi:checkIfSimpleFriend())then
        self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-48, self.bgLayer:getContentSize().height-375))
        self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,170))
    else
        self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-48, self.bgLayer:getContentSize().height-315))
        self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,110))
    end
    self.tvBg:ignoreAnchorPointForPosition(false)
    self.tvBg:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(self.tvBg)
    --邀请好友的按钮
    local function onInviteFriend()
        if(G_curPlatName()=="efunandroidtw" or (G_curPlatName()=="3" and G_Version<=4) or G_curPlatName()=="efunandroiddny" or G_curPlatName()=="4" or G_curPlatName()=="47")then
            local tmpTb={}
            tmpTb["action"]="showSocialView"
            tmpTb["parms"]={}
            tmpTb["parms"]["uid"]=tostring(G_getTankUserName())
            tmpTb["parms"]["zoneid"]=tostring(base.curZoneID)
            tmpTb["parms"]["gameid"]=tostring(playerVoApi:getUid())
            local cjson=G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        elseif(friendVoApi:checkIfSimpleFriend())then
            friendVoApi:sendInviteFeed()
        else
            friendVoApi:showSocialView()
        end
    end
    local btnTextSize = 30
    if G_curPlatName()=="12" or G_curPlatName()=="androidzhongshouyouru" then
        btnTextSize = 25
    end
    local inviteItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onInviteFriend,nil,getlocal("friend_invite"),btnTextSize)
    inviteItem:setEnabled(true);
    local inviteBtn=CCMenu:createWithItem(inviteItem);
    if(friendVoApi:checkIfSimpleFriend())then
        inviteItem:setAnchorPoint(ccp(1,0.5))
        inviteBtn:setAnchorPoint(ccp(1,0.5))
        inviteBtn:setPosition(ccp(G_VisibleSizeWidth/2-20,70))
    else
        inviteBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
    end
    inviteBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(inviteBtn,2)

    if(friendVoApi:checkIfSimpleFriend())then
        local function onGotoHomePage()
            if(platCfg.platHomePageCfg[G_curPlatName()])then
                local tmpTb={}
                tmpTb["action"]="openUrlInAppWithClose"
                tmpTb["parms"]={}
                tmpTb["parms"]["connect"]=platCfg.platHomePageCfg[G_curPlatName()]
                local cjson=G_Json.encode(tmpTb)
                G_accessCPlusFunction(cjson)
            end
        end
        local homePageItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGotoHomePage,nil,getlocal("homepage"),btnTextSize)
        local homePageBtn=CCMenu:createWithItem(homePageItem)
        homePageItem:setAnchorPoint(ccp(0,0.5))
        homePageBtn:setAnchorPoint(ccp(0,0.5))
        homePageBtn:setPosition(ccp(G_VisibleSizeWidth/2+20,70))
        homePageBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(homePageBtn)

        local feedDescTitle=GetTTFLabelWrap(getlocal("feedDesc4Title"),23,CCSizeMake(G_VisibleSizeWidth-70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        feedDescTitle:setPosition(ccp(G_VisibleSizeWidth/2,140))
        self.bgLayer:addChild(feedDescTitle)
    end
    --上下翻页的按钮
    local function onPageUp()
        self:onPageChange(-1)
    end
    local pUpItem
    if(friendVoApi:checkIfSimpleFriend())then
        pUpItem=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",onPageUp,nil,nil,30)
    else
        pUpItem=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",onPageUp,nil,nil,30)
        pUpItem:setRotation(-180)
    end
    pUpItem:setEnabled(false);
    local pUpBtn=CCMenu:createWithItem(pUpItem);
    if(friendVoApi:checkIfSimpleFriend())then
        pUpBtn:setPosition(ccp(30,G_VisibleSizeHeight/2))
    else
        pUpBtn:setPosition(ccp(120,70))
    end
    pUpBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(pUpBtn,2)
    self.pageUpBtn=pUpItem
    local function onPageDown()
        self:onPageChange(1)
    end
    local pDownItem
    if(friendVoApi:checkIfSimpleFriend())then
        pDownItem=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",onPageDown,nil,nil,30)
        pDownItem:setRotation(-180)
    else
        pDownItem=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",onPageDown,nil,nil,30)
    end
    pDownItem:setEnabled(false);
    local pDownBtn=CCMenu:createWithItem(pDownItem);
    if(friendVoApi:checkIfSimpleFriend())then
        pDownBtn:setPosition(ccp(G_VisibleSizeWidth-30,G_VisibleSizeHeight/2))
    else
        pDownBtn:setPosition(ccp(G_VisibleSizeWidth-120,70))
    end
    pDownBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(pDownBtn,2)
    self.pageDownBtn=pDownItem
    self:switchTab(1)
    self:reposition()
end

function friendDialog:resetForbidLayer()
    if(self.selectedTabIndex==0)then
        self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-160))
        self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 160))
    else
        self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-205))
        self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 205))
    end
    self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 120))
end

--点击tab页签 idx:索引
function friendDialog:tabClick(idx)
    local tab2HasInited=(self.friendTab2~=nil)
    self:switchTab(idx+1)
    self:reposition()
    self:resetForbidLayer()
    if(idx==0)then
        self.friendTab1:pageChange(0)
    elseif(tab2HasInited)then
        self.friendTab2:pageChange(0)
    end
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
        else
            v:setEnabled(true)
        end
    end
end

--点击subTab页签 idx:索引
function friendDialog:tabSubClick(idx)
    if self.selectedSubTabIndex == idx then
        return
    end
    if self.selectedTabIndex ~= 1 then
        return
    end
    self.selectedSubTabIndex=idx
    self.friendTab2:sort()
    for k,v in pairs(self.allSubTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
        else
            v:setEnabled(true)
        end
    end
end

function friendDialog:switchTab(type)
    if type==nil then
      type=1
    end
    if type==1 then
        if self.friendTab1==nil then
            self.friendTab1=friendDialogTab1:new()
            self.layerTab1=self.friendTab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab1)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
    elseif type==2 then
        if self.friendTab2==nil then
            self.friendTab2=friendDialogTab2:new()
            self.layerTab2=self.friendTab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(0,0))
            self.layerTab2:setVisible(true)
        end
    end
end

function friendDialog:reposition()
    local indexSub=0
    if(self.selectedTabIndex==1)then
        self.tvBg:setPositionX(G_VisibleSizeWidth/2)
        for k,v in pairs(self.allSubTabs) do
            local tabBtnItem=v
            if indexSub==0 then
                tabBtnItem:setPosition(100,self.bgSize.height-tabBtnItem:getContentSize().height/2-160)
            elseif indexSub==1 then
                tabBtnItem:setPosition(248,self.bgSize.height-tabBtnItem:getContentSize().height/2-160)
            elseif indexSub==2 then
                tabBtnItem:setPosition(394,self.bgSize.height-tabBtnItem:getContentSize().height/2-160)
            elseif indexSub==3 then
                tabBtnItem:setPosition(540,self.bgSize.height-tabBtnItem:getContentSize().height/2-160)
            end
            indexSub=indexSub+1
        end
    elseif(self.selectedTabIndex==0)then
        self.tvBg:setPositionX(999333)
        for k,v in pairs(self.allSubTabs) do
            local  tabBtnItem=v
            tabBtnItem:setPosition(999333,0)
            indexSub=indexSub+1
        end
    end
end

function friendDialog:onPageChange(p)
    if(self.selectedTabIndex == 0)then
        self.friendTab1:pageChange(p)
    elseif(self.selectedTabIndex==1)then
        self.friendTab2:pageChange(p)
    end
end







