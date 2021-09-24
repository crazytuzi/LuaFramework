acHardGetRichDialogTab1={}

function acHardGetRichDialogTab1:new(parent,layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.parent=parent
    self.bgLayer=nil
    self.firstnameTb={}
    
    self.cellHeight= nil

    return nc
end

function acHardGetRichDialogTab1:init()
    self.bgLayer=CCLayer:create();

    local function callback(fn,data)
        local ret,sData=base:checkServerData(data)

        if ret==true then
            if sData~=nil and sData.data~=nil and sData.data.firstname~=nil then
                acHardGetRichVoApi:initNameRank(sData.data.firstname)
            end
            
            local function callback1(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData.data.res then
                      acHardGetRichVoApi:setResRank(sData.data.res)
                    end
                    self:initLayer()

                end
              end


             socketHelper:activeGethardgetrich(callback1)

          
        end
      end
    socketHelper:activeHardgetrichrank(0,callback)

    
    return self.bgLayer
end
function acHardGetRichDialogTab1:initLayer()

    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local function cellClick()

    end
    local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    headerSprie:setContentSize(CCSizeMake(590, G_VisibleSize.height-310))
    headerSprie:ignoreAnchorPointForPosition(false);
    headerSprie:setAnchorPoint(ccp(0.5,0));
    headerSprie:setIsSallow(false)
    headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    headerSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,30));
    self.bgLayer:addChild(headerSprie)

    local timeSize = 24
    local timeShowWidth =30
    local needPosX = 25
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage() =="ko" then
        timeSize =28
        timeShowWidth =0
        needPosX =0
    end   
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),timeSize)
    actTime:setPosition(ccp(40,self.bgLayer:getContentSize().height-200))
    actTime:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)

    local rewardTimeStr = GetTTFLabel(getlocal("recRewardTime"),timeSize)
    rewardTimeStr:setAnchorPoint(ccp(0,0.5))
    rewardTimeStr:setColor(G_ColorYellowPro)
    rewardTimeStr:setPosition(ccp(40,self.bgLayer:getContentSize().height-240))
    self.bgLayer:addChild(rewardTimeStr,5)

    local acVo = acHardGetRichVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,timeSize-2)
        timeLabel:setAnchorPoint(ccp(0,0.5))
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2-110+needPosX, self.bgLayer:getContentSize().height-200))
        self.bgLayer:addChild(timeLabel)

        local timeStr2=activityVoApi:getActivityRewardTimeStr(acVo.acEt,60,86400)
        local timeLabel2=GetTTFLabel(timeStr2,timeSize-2)
        timeLabel2:setAnchorPoint(ccp(0,0.5))
        timeLabel2:setPosition(ccp(self.bgLayer:getContentSize().width/2-110+needPosX, self.bgLayer:getContentSize().height-240))
        self.bgLayer:addChild(timeLabel2)

        self.timeLb=timeLabel
        self.rewardTimeLb=timeLabel2
        G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb)
    end
    
    local function touchInfo()
        local td=smallDialog:new()
        local str1=getlocal("activity_getRich_notice");
        local str2=getlocal("activity_getRich_notice1");
        tabStr={" ",str2,str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    
    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(570,self.bgLayer:getContentSize().height-230));
    menu:setTouchPriority(-(self.layerNum-1)*20-2);
    self.bgLayer:addChild(menu,3);
    
    -- local descLabel=GetTTFLabelWrap(getlocal("activity_getRich_explanation"),24,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- descLabel:setAnchorPoint(ccp(0,1))
    -- descLabel:setPosition(ccp(60,self.bgLayer:getContentSize().height-300))
    -- self.bgLayer:addChild(descLabel,5)

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setAnchorPoint(ccp(0,0));
    lineSp:setPosition(ccp(30,self.bgLayer:getContentSize().height-490));
    self.bgLayer:addChild(lineSp,1)

    local function call1(tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        local dd = acHardGetRichRankDialog:new(self,self.layerNum+1)
        local tb ={"gold","r1","r2","r3","r4"}
        dd:setType(tb[tag])
        local tbArr={}
        local vd = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("mainRank"),true,self.layerNum+1);
        sceneGame:addChild(vd,self.layerNum+1)
    end
    local resoucetb = {
    {name=acHardGetRichVoApi:getNameRank()[5],callback=call1,buttonStr="activity_getRich_rank1"},
    {name=acHardGetRichVoApi:getNameRank()[1],callback=call1,buttonStr="activity_getRich_rank2"},
    {name=acHardGetRichVoApi:getNameRank()[2],callback=call1,buttonStr="activity_getRich_rank3"},
    {name=acHardGetRichVoApi:getNameRank()[3],callback=call1,buttonStr="activity_getRich_rank4"},
    {name=acHardGetRichVoApi:getNameRank()[4],callback=call1,buttonStr="activity_getRich_rank5"},
    }
    for k,v in pairs(resoucetb) do

        
        -- local rect = CCRect(0, 0, 50, 50);
        -- local capInSet = CCRect(37, 26, 1, 1);
        -- local function cellClick()

        -- end
        -- local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TeamRepairBtn.png",capInSet,cellClick)
        -- headerSprie:setContentSize(CCSizeMake(350, 70))
        -- headerSprie:ignoreAnchorPointForPosition(false);
        -- headerSprie:setAnchorPoint(ccp(0,1));
        -- headerSprie:setIsSallow(false)
        -- headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        -- headerSprie:setPosition(ccp(50,self.bgLayer:getContentSize().height-495-85*(k-1)));
        -- self.bgLayer:addChild(headerSprie)

        local yy = 535

        local rankSp=CCSprite:createWithSpriteFrameName("top1.png")
        rankSp:setAnchorPoint(ccp(0,0.5));
        rankSp:setPosition(ccp(70,self.bgLayer:getContentSize().height-yy-85*(k-1)));
        self.bgLayer:addChild(rankSp,5);

        local name=getlocal("alliance_info_content")
        if resoucetb[k].name~="" then
           name= resoucetb[k].name
        end

        local nameLb=GetTTFLabel(name,30)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(ccp(180,self.bgLayer:getContentSize().height-yy-85*(k-1)))
        self.bgLayer:addChild(nameLb,5);

        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSp:setAnchorPoint(ccp(0,0));
        lineSp:setPosition(ccp(30,self.bgLayer:getContentSize().height-yy-46-85*(k-1)));
        self.bgLayer:addChild(lineSp,1)

        local function callbackRank()
            resoucetb[k].callback(k)
        end
        local menuItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",callbackRank,11,getlocal(resoucetb[k].buttonStr),25)
        local menu = CCMenu:createWithItem(menuItem);
        menuItem:setAnchorPoint(ccp(0.5,1))
        menu:setPosition(ccp(520,self.bgLayer:getContentSize().height-495-85*(k-1)));
        menu:setTouchPriority(-(self.layerNum-1)*20-2);
        self.bgLayer:addChild(menu,3);

    end
    self:initTableView()


end

function acHardGetRichDialogTab1:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,180),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setAnchorPoint(ccp(0,1))
    self.tv:setPosition(ccp(0,self.bgLayer:getContentSize().height-480))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(50)

end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acHardGetRichDialogTab1:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1

   elseif fn=="tableCellSizeForIndex" then
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage=="tw" then
            self.cellHeight = 300
        else
            self.cellHeight = 400
        end
       local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.cellHeight)

       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local descLabel1=GetTTFLabelWrap(getlocal("activity_getRich_explanation1"),24,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLabel1:setAnchorPoint(ccp(0,1))
        descLabel1:setPosition(ccp(60,self.cellHeight))
        cell:addChild(descLabel1,5)

        local descLabel=GetTTFLabelWrap(getlocal("activity_getRich_explanation2"),24,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLabel:setAnchorPoint(ccp(0,1))
        descLabel:setPosition(ccp(60,self.cellHeight-descLabel1:getContentSize().height))
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


function acHardGetRichDialogTab1:tick()
    if self.timeLb and self.rewardTimeLb then
        local acVo = acHardGetRichVoApi:getAcVo()
        G_updateActiveTime(acVo,self.timeLb,self.rewardTimeLb)
    end
end

function acHardGetRichDialogTab1:dispose()
    self.cellHeight= nil
    self.timeLb=nil
    self.rewardTimeLb=nil
    self.bgLayer=nil
    self=nil

end




