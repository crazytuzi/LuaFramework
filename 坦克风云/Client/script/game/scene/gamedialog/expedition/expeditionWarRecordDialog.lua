require "luascript/script/game/scene/gamedialog/expedition/expeditionWarRecordTab1Dialog"
require "luascript/script/game/scene/gamedialog/expedition/expeditionWarRecordTab2Dialog"
expeditionWarRecordDialog=commonDialog:new()

function expeditionWarRecordDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    -- self.layerNum=layerNum
    
    self.layerTab1=nil
    self.layerTab2=nil
    
    self.playerTab1=nil
    self.playerTab2=nil

    self.tv1=nil
    self.tv2=nil

    self.redLb=nil
    self.blueLb=nil
    self.statsBtn=nil

    return nc
end

--设置或修改每个Tab页签
function expeditionWarRecordDialog:resetTab()
    --self.allTabs={getlocal("alliance_info_Introduction"),getlocal("alliance_technology"),getlocal("alliance_scene_event_title"),getlocal("alliance_duplicate")}
    self.allTabs={getlocal("fleetInfoTitle2"),getlocal("heroTitle")}
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



function expeditionWarRecordDialog:initTab(tabTb)
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
           
           local lb=GetTTFLabel(v,24)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
           lb:setTag(31)
           
           
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
function expeditionWarRecordDialog:tabClick(idx)

    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
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

function expeditionWarRecordDialog:initTableView()
    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    -- local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)

    self:initTabLayer()
    self:tabClick(0)

    G_AllianceWarDialogTb["expeditionWarRecordDialog"]=self
end

function expeditionWarRecordDialog:initTabLayer()
    self.playerTab1=expeditionWarRecordTab1Dialog:new()
    self.layerTab1=self.playerTab1:init(self.layerNum,self)
    self.bgLayer:addChild(self.layerTab1,2)

    self.playerTab2=expeditionWarRecordTab2Dialog:new()
    self.layerTab2=self.playerTab2:init(self.layerNum,self)
    self.bgLayer:addChild(self.layerTab2,2)
    self.layerTab2:setVisible(false)
    self.layerTab2:setPosition(ccp(10000,0))

    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 230))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-101))

    local descLb=GetTTFLabelWrap(getlocal("expeditionRecordInfo"),22,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0.5,0.5))
    descLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-120))
    self.bgLayer:addChild(descLb)


    local capInSet = CCRect(60, 20, 1, 1);
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",capInSet,cellClick)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, 40))
    backSprie:ignoreAnchorPointForPosition(false);
    backSprie:setAnchorPoint(ccp(0.5,0.5));
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-250));
    self.bgLayer:addChild(backSprie)


end


function expeditionWarRecordDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
        
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:getDataByType(idx)
        else
            v:setEnabled(true)
        end
    end
    self:switchTag(idx)
end

function expeditionWarRecordDialog:switchTag(idx)
    if idx==0 then
        if self.playerTab1==nil then
            self.playerTab1=expeditionWarRecordTab1Dialog:new()
            self.layerTab1=self.playerTab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab1)
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
        else
            self.layerTab1:setVisible(true)
            self.layerTab1:setPosition(ccp(0,0))
        end

        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
    elseif idx==1 then
        if self.playerTab2==nil then
            self.playerTab2=expeditionWarRecordTab2Dialog:new()
            self.layerTab2=self.playerTab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2)
            self.layerTab2:setPosition(ccp(0,0))
            self.layerTab2:setVisible(true)
        else
            self.layerTab2:setVisible(true)
            self.layerTab2:setPosition(ccp(0,0))
        end

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end

    end
end

--用户处理特殊需求,没有可以不写此方法
function expeditionWarRecordDialog:doUserHandler()

end


--点击了cell或cell上某个按钮
function expeditionWarRecordDialog:cellClick(idx)

end

function expeditionWarRecordDialog:tick()

end

function expeditionWarRecordDialog:dispose()
    self.layerTab1=nil
    self.layerTab2=nil
    
    self.playerTab1=nil
    self.playerTab2=nil

    self.tv1=nil
    self.tv2=nil

    self.redLb=nil
    self.blueLb=nil
    self.statsBtn=nil
    G_AllianceWarDialogTb["expeditionWarRecordDialog"]=nil

    self=nil
end




