allianceWar2RecordTab3={

}

function allianceWar2RecordTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv1=nil;
    self.tv2=nil;

    self.bgLayer=nil;
    self.layerNum=nil;
    self.allTabs={};
    
    self.bgLayer1=nil;
    self.bgLayer2=nil;

    self.selectedTabIndex=0;
    self.parentDialog=nil;
    self.cellHeight=120

    self.tvBg1=nil
    self.tvBg2=nil

    return nc;

end

--设置或修改每个Tab页签
function allianceWar2RecordTab3:resetTab()
    self.allTabs={getlocal("alliance_war_personal"),getlocal("alliance_list_scene_name")}

    self:initTab(self.allTabs)
    local index=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        if index==0 then
           tabBtnItem:setPosition(100-6,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-270)
        elseif index==1 then
           tabBtnItem:setPosition(248-3,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-270)
        -- elseif index==2 then
        --    tabBtnItem:setPosition(394+3,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-270)
        -- elseif index==3 then
        --    tabBtnItem:setPosition(540+6,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-270)
        end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1
    end

end

function allianceWar2RecordTab3:init(layerNum,parentDialog)
    self.parentDialog=parentDialog
    self.layerNum=layerNum;
    self.bgLayer=CCLayer:create();

    self:initTabLayer();
    self:initRedAndBlue()

    return self.bgLayer
end

function allianceWar2RecordTab3:initRedAndBlue()
    local capInSet=CCRect(20, 20, 10, 10)
    local function touch()
    end

    local lbTextSize = 22
    if G_getCurChoseLanguage()=="pt" then
        lbTextSize = 18
    end
    self.redLb = GetTTFLabelWrap(getlocal("alliance_war_red_total",{allianceWar2RecordVoApi.redDestroy}),lbTextSize,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    self.redLb:setAnchorPoint(ccp(0,0.5));
    self.redLb:setPosition(ccp(30,self.bgLayer:getContentSize().height-195));
    self.bgLayer:addChild(self.redLb,2);

    self.blueLb = GetTTFLabelWrap(getlocal("alliance_war_blue_total",{allianceWar2RecordVoApi.blueDestroy}),lbTextSize,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    self.blueLb:setAnchorPoint(ccp(0,0.5));
    self.blueLb:setPosition(ccp(30,self.bgLayer:getContentSize().height-240));
    self.bgLayer:addChild(self.blueLb,2);

    -- self:doUserHandler()
end

function allianceWar2RecordTab3:initTabLayer()
    self:resetTab()
    
end

function allianceWar2RecordTab3:initTabLayer1()
    self:doUserHandler()
    if self.tv1 then
        self.tv1:reloadData()
    else
        self.bgLayer1=CCLayer:create();

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function click(hd,fn,idx)
        end
        self.tvBg1 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,click)
        self.tvBg1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345-5))
        self.tvBg1:ignoreAnchorPointForPosition(false)
        self.tvBg1:setAnchorPoint(ccp(0.5,0))
        --self.tvBg1:setIsSallow(false)
        --self.tvBg1:setTouchPriority(-(self.layerNum-1)*20-2)
        self.tvBg1:setPosition(ccp(G_VisibleSizeWidth/2,100-70))
        self.bgLayer1:addChild(self.tvBg1)

        local limitLb=GetTTFLabelWrap(getlocal("allianceWar2_donate_notion",{allianceWar2Cfg.maxTankDonate}),25,CCSizeMake(self.tvBg1:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        limitLb:setAnchorPoint(ccp(0,0))
        limitLb:setPosition(ccp(15,12))
        self.tvBg1:addChild(limitLb)
        limitLb:setColor(G_ColorRed)

        -- local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
        -- bgSp:setAnchorPoint(ccp(0.5,1));
        -- bgSp:setPosition(ccp(self.tvBg1:getContentSize().width/2,self.tvBg1:getContentSize().height));
        -- bgSp:setScaleY(60/bgSp:getContentSize().height)
        -- bgSp:setScaleX(G_VisibleSizeWidth/bgSp:getContentSize().width)
        -- self.tvBg1:addChild(bgSp)

        -- local lbSize=22
        -- local lbHeight=self.tvBg1:getContentSize().height-30

        -- -- local tankNumLb=GetTTFLabelWrap(str,lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- local tankNumLb=GetTTFLabelWrap(getlocal("alliance_war_tank_name"),lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- tankNumLb:setAnchorPoint(ccp(0.5,0.5))
        -- tankNumLb:setPosition(ccp(G_VisibleSizeWidth/2-190-27,lbHeight))
        -- tankNumLb:setColor(G_ColorGreen)
        -- self.tvBg1:addChild(tankNumLb)

        -- -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- -- local selfNumLb=GetTTFLabelWrap(str,lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- local selfNumLb=GetTTFLabelWrap(getlocal("alliance_war_self_destroy_num"),lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- selfNumLb:setAnchorPoint(ccp(0.5,0.5))
        -- selfNumLb:setPosition(ccp(G_VisibleSizeWidth/2-27,lbHeight))
        -- selfNumLb:setColor(G_ColorGreen)
        -- self.tvBg1:addChild(selfNumLb)

        -- -- local enemyNumLb=GetTTFLabelWrap(str,lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- local enemyNumLb=GetTTFLabelWrap(getlocal("alliance_war_enemy_destroy_num"),lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- enemyNumLb:setAnchorPoint(ccp(0.5,0.5))
        -- enemyNumLb:setPosition(ccp(G_VisibleSizeWidth/2+190-27,lbHeight))
        -- enemyNumLb:setColor(G_ColorGreen)
        -- self.tvBg1:addChild(enemyNumLb)

        self.bgLayer:addChild(self.bgLayer1,2)



        local function callBack1(...)
           return self:eventHandler1(...)
        end
        local hd1= LuaEventHandler:createHandler(callBack1)
        local height=0;
        self.tv1=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345-70+50-limitLb:getContentSize().height-10),nil)
        --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv1:setPosition(ccp(25,100-65+limitLb:getContentSize().height+15))
        self.bgLayer1:addChild(self.tv1)
        self.tv1:setMaxDisToBottomOrTop(120)
    end
end

function allianceWar2RecordTab3:initTabLayer2()
    if self.tv2 then
        self.tv2:reloadData()
    else
        self.bgLayer2=CCLayer:create();

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function click(hd,fn,idx)
        end
        self.tvBg2 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,click)
        self.tvBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345-5))
        self.tvBg2:ignoreAnchorPointForPosition(false)
        self.tvBg2:setAnchorPoint(ccp(0.5,0))
        --self.tvBg2:setIsSallow(false)
        --self.tvBg2:setTouchPriority(-(self.layerNum-1)*20-2)
        self.tvBg2:setPosition(ccp(G_VisibleSizeWidth/2,100-70))
        self.bgLayer2:addChild(self.tvBg2)

        local limitLb=GetTTFLabelWrap(getlocal("allianceWar2_donate_notion",{allianceWar2Cfg.maxTankDonate}),25,CCSizeMake(self.tvBg2:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        limitLb:setAnchorPoint(ccp(0,0))
        limitLb:setPosition(ccp(15,12))
        self.tvBg2:addChild(limitLb)
        limitLb:setColor(G_ColorRed)

        -- local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
        -- bgSp:setAnchorPoint(ccp(0.5,1));
        -- bgSp:setPosition(ccp(self.tvBg2:getContentSize().width/2,self.tvBg2:getContentSize().height));
        -- bgSp:setScaleY(60/bgSp:getContentSize().height)
        -- bgSp:setScaleX(G_VisibleSizeWidth/bgSp:getContentSize().width)
        -- self.tvBg2:addChild(bgSp)
        
        -- local lbSize=22
        -- local lbHeight=self.tvBg2:getContentSize().height-30

        -- local tankNumLb=GetTTFLabelWrap(getlocal("alliance_war_tank_name"),lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- tankNumLb:setAnchorPoint(ccp(0.5,0.5))
        -- tankNumLb:setPosition(ccp(G_VisibleSizeWidth/2-190-27,lbHeight))
        -- tankNumLb:setColor(G_ColorGreen)
        -- self.tvBg2:addChild(tankNumLb)

        -- local redNumLb=GetTTFLabelWrap(getlocal("alliance_war_red_destroy_num"),lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- redNumLb:setAnchorPoint(ccp(0.5,0.5))
        -- redNumLb:setPosition(ccp(G_VisibleSizeWidth/2-27,lbHeight))
        -- redNumLb:setColor(G_ColorGreen)
        -- self.tvBg2:addChild(redNumLb)

        -- local blueNumLb=GetTTFLabelWrap(getlocal("alliance_war_blue_destroy_num"),lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- blueNumLb:setAnchorPoint(ccp(0.5,0.5))
        -- blueNumLb:setPosition(ccp(G_VisibleSizeWidth/2+190-27,lbHeight))
        -- blueNumLb:setColor(G_ColorGreen)
        -- self.tvBg2:addChild(blueNumLb)
        
        self.bgLayer:addChild(self.bgLayer2,2)
        self.bgLayer2:setVisible(false)
        self.bgLayer2:setPosition(ccp(10000,0))



        local function callBack2(...)
           return self:eventHandler2(...)
        end
        local hd2= LuaEventHandler:createHandler(callBack2)
        self.tv2=LuaCCTableView:createWithEventHandler(hd2,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345-70+50-limitLb:getContentSize().height-10),nil)
        self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv2:setPosition(ccp(25,100-65+limitLb:getContentSize().height+15))
        self.bgLayer2:addChild(self.tv2)
        self.tv2:setMaxDisToBottomOrTop(120)
    end
end

function allianceWar2RecordTab3:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local personDestroyTab=allianceWar2RecordVoApi:getPersonDestroyTab()
        -- local num=SizeOfTable(personDestroyTab)+1
        local num=SizeOfTable(personDestroyTab)
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            --return self:cellClick(idx)
        end

        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, self.cellHeight-5))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0,0));
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(5,5)
        cell:addChild(backSprie,1)

        -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        -- lineSp:setAnchorPoint(ccp(0,0));
        -- lineSp:setPosition(ccp(0,0));
        -- cell:addChild(lineSp,1)

        -- local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png")
        -- lineSp:setScaleX(self.bgLayer:getContentSize().width-50/lineSp:getContentSize().width)
        -- lineSp:setAnchorPoint(ccp(0.5,1))
        -- lineSp:setPosition(ccp((self.bgLayer:getContentSize().width-50)/2,lineSp:getContentSize().height))
        -- cell:addChild(lineSp,1)

        -- local lineSp1 = CCSprite:createWithSpriteFrameName("LineEntity.png")
        -- lineSp1:setScaleX(70/lineSp1:getContentSize().width)
        -- lineSp1:setAnchorPoint(ccp(0.5,0.5))
        -- lineSp1:setPosition(200,35)
        -- cell:addChild(lineSp1,1)
        -- lineSp1:setRotation(90)

        -- local lineSp2 = CCSprite:createWithSpriteFrameName("LineEntity.png")
        -- lineSp2:setScaleX(70/lineSp2:getContentSize().width)
        -- lineSp2:setAnchorPoint(ccp(0.5,0.5))
        -- lineSp2:setPosition(388,35)
        -- cell:addChild(lineSp2,1)
        -- lineSp2:setRotation(90)

        local lbSize=25
        local lbHeight=backSprie:getContentSize().height/2

        local destroyNum=0
        local lostNum=0
        local donateNum=0
        -- if idx==0 then
        --     local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png")
        --     lineSp:setScaleX(self.bgLayer:getContentSize().width-50/lineSp:getContentSize().width)
        --     lineSp:setAnchorPoint(ccp(0.5,1))
        --     lineSp:setPosition(ccp((self.bgLayer:getContentSize().width-50)/2,70))
        --     cell:addChild(lineSp,1)

        --     -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        --     -- local totalNameLb=GetTTFLabelWrap(str,lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        --     local totalNameLb=GetTTFLabelWrap(getlocal("alliance_war_total_num"),lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        --     totalNameLb:setPosition(97+5,lbHeight)
        --     cell:addChild(totalNameLb,1)

        --     local totalDestroy,totalLost=allianceWar2RecordVoApi:getPersonNum()
        --     destroyNum=totalDestroy or 0
        --     lostNum=totalLost or 0
        -- else
            local personDestroyTab=allianceWar2RecordVoApi:getPersonDestroyTab()
            local personDestroy=personDestroyTab[idx+1]
            local tankId=personDestroy[1]

            local tankSp=G_getTankPic(tankId)
            tankSp:setAnchorPoint(ccp(0.5,0.5))
            tankSp:setPosition(80,lbHeight)
            tankSp:setScale(0.7)
            backSprie:addChild(tankSp,1)
            if G_pickedList(tankId) ~= tankId then
                 local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                tankSp:addChild(pickedIcon)
                pickedIcon:setPosition(tankSp:getContentSize().width*0.7,tankSp:getContentSize().height*0.5-10)
            end

            destroyNum=personDestroy[2] or 0
            lostNum=personDestroy[3] or 0
            donateNum=personDestroy[5] or 0
        -- end

        -- local selfLb=GetTTFLabel(destroyNum,lbSize)
        -- selfLb:setPosition(ccp(288+5,lbHeight))
        -- cell:addChild(selfLb,1)

        -- local enemyNumLb=GetTTFLabel(lostNum,lbSize)
        -- enemyNumLb:setPosition(ccp(478+5,lbHeight))
        -- cell:addChild(enemyNumLb,1)

        local selfLb=GetTTFLabelWrap(getlocal("allianceWar2_wreck",{destroyNum}),25,CCSizeMake(190,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        selfLb:setAnchorPoint(ccp(0,0.5))
        selfLb:setPosition(ccp(170,lbHeight/2*3))
        backSprie:addChild(selfLb)

        local enemyNumLb=GetTTFLabelWrap(getlocal("allianceWar2_damage",{lostNum}),25,CCSizeMake(190,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        enemyNumLb:setAnchorPoint(ccp(0,0.5))
        enemyNumLb:setPosition(ccp(170,lbHeight/2))
        enemyNumLb:setColor(G_ColorRed)
        backSprie:addChild(enemyNumLb)

        local donateLb=GetTTFLabelWrap(getlocal("record_reward_contribution_num",{donateNum}),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        donateLb:setAnchorPoint(ccp(0,0.5))
        donateLb:setPosition(ccp(380,lbHeight))
        donateLb:setColor(G_ColorYellowPro)
        backSprie:addChild(donateLb)

        return cell;
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end

end

function allianceWar2RecordTab3:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local allianceDestroyTab=allianceWar2RecordVoApi:getAllianceDestroyTab()
        -- local num=SizeOfTable(allianceDestroyTab)+1
        local num=SizeOfTable(allianceDestroyTab)
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            --return self:cellClick(idx)
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, self.cellHeight-5))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0,0));
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(5,5)
        cell:addChild(backSprie,1)

        -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        -- lineSp:setAnchorPoint(ccp(0,0));
        -- lineSp:setPosition(ccp(0,0));
        -- cell:addChild(lineSp,1)

        -- local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png")
        -- lineSp:setScaleX(self.bgLayer:getContentSize().width-50/lineSp:getContentSize().width)
        -- lineSp:setAnchorPoint(ccp(0.5,1))
        -- lineSp:setPosition(ccp((self.bgLayer:getContentSize().width-50)/2,lineSp:getContentSize().height))
        -- cell:addChild(lineSp,1)

        -- local lineSp1 = CCSprite:createWithSpriteFrameName("LineEntity.png")
        -- lineSp1:setScaleX(70/lineSp1:getContentSize().width)
        -- lineSp1:setAnchorPoint(ccp(0.5,0.5))
        -- lineSp1:setPosition(200,35)
        -- cell:addChild(lineSp1,1)
        -- lineSp1:setRotation(90)

        -- local lineSp2 = CCSprite:createWithSpriteFrameName("LineEntity.png")
        -- lineSp2:setScaleX(70/lineSp2:getContentSize().width)
        -- lineSp2:setAnchorPoint(ccp(0.5,0.5))
        -- lineSp2:setPosition(388,35)
        -- cell:addChild(lineSp2,1)
        -- lineSp2:setRotation(90)

        local lbSize=25
        local lbHeight=backSprie:getContentSize().height/2

        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- local tankNameLb=GetTTFLabelWrap(str,lbSize,CCSizeMake(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- local tankNameLb=GetTTFLabelWrap(getlocal("alliance_war_tank_name"),lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- tankNameLb:setPosition(288,lbHeight)
        -- cell:addChild(tankNameLb,1)

        local destroyNum=0
        local lostNum=0
        -- if idx==0 then
        --     local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png")
        --     lineSp:setScaleX(self.bgLayer:getContentSize().width-50/lineSp:getContentSize().width)
        --     lineSp:setAnchorPoint(ccp(0.5,1))
        --     lineSp:setPosition(ccp((self.bgLayer:getContentSize().width-50)/2,70))
        --     cell:addChild(lineSp,1)

        --     -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        --     -- local totalNameLb=GetTTFLabelWrap(str,lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        --     local totalNameLb=GetTTFLabelWrap(getlocal("alliance_war_total_num"),lbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        --     totalNameLb:setPosition(97+5,lbHeight)
        --     cell:addChild(totalNameLb,1)

        --     destroyNum=allianceWar2RecordVoApi.redDestroy or 0
        --     lostNum=allianceWar2RecordVoApi.blueDestroy or 0
        -- else
            local allianceDestroyTab=allianceWar2RecordVoApi:getAllianceDestroyTab()
            local allianceDestroy=allianceDestroyTab[idx+1]
            local tankId=allianceDestroy[1]
            
            local tankSp=G_getTankPic(tankId)
            tankSp:setAnchorPoint(ccp(0.5,0.5))
            tankSp:setPosition(80,lbHeight)
            tankSp:setScale(0.7)
            backSprie:addChild(tankSp,1)
            if G_pickedList(tankId) ~= tankId then
                 local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                tankSp:addChild(pickedIcon)
                pickedIcon:setPosition(tankSp:getContentSize().width*0.7,tankSp:getContentSize().height*0.5-10)
            end

            destroyNum=allianceDestroy[2] or 0
            lostNum=allianceDestroy[3] or 0
        -- end

        -- local redLb=GetTTFLabel(destroyNum,lbSize)
        -- redLb:setPosition(ccp(288+5,lbHeight))
        -- cell:addChild(redLb,1)

        -- local blueNumLb=GetTTFLabel(lostNum,lbSize)
        -- blueNumLb:setPosition(ccp(478+5,lbHeight))
        -- cell:addChild(blueNumLb,1)

        local selfLb=GetTTFLabelWrap(getlocal("allianceWar2_wreck",{destroyNum}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        selfLb:setAnchorPoint(ccp(0,0.5))
        selfLb:setPosition(ccp(170,lbHeight/2*3))
        backSprie:addChild(selfLb)

        local enemyNumLb=GetTTFLabelWrap(getlocal("allianceWar2_damage",{lostNum}),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        enemyNumLb:setAnchorPoint(ccp(0,0.5))
        enemyNumLb:setPosition(ccp(170,lbHeight/2))
        enemyNumLb:setColor(G_ColorRed)
        backSprie:addChild(enemyNumLb)

        -- local donateLb=GetTTFLabelWrap(getlocal("record_reward_contribution_num",{1000000}),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        -- donateLb:setAnchorPoint(ccp(0,0.5))
        -- donateLb:setPosition(ccp(380,lbHeight))
        -- donateLb:setColor(G_ColorYellowPro)
        -- backSprie:addChild(donateLb)

        return cell;

    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
     
    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end

end

function allianceWar2RecordTab3:initTab(tabTb)
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

   self:tabClick(0)
end

function allianceWar2RecordTab3:getDataByType(type)
    if type==nil then
        type=0
    end 
    local function getbattlelogCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data then
                allianceWar2RecordVoApi:formatStatsData(sData.data)
                if self then
                    if type==0 then
                        self:initTabLayer1()
                        if self.parentDialog then
                            self.parentDialog:updateDestroyNum()
                        end
                        if self.bgLayer2 then
                            self.bgLayer2:setVisible(false)
                            self.bgLayer2:setPosition(ccp(10000,0))
                        end
                    elseif type==1 then
                        self:initTabLayer2()
                        if self.parentDialog then
                            self.parentDialog:updateDestroyNum()
                        end
                        if self.bgLayer1 then
                            self.bgLayer1:setVisible(false)
                            self.bgLayer1:setPosition(ccp(10000,0))
                        end
                    end
                    allianceWar2RecordVoApi:setDFlag(1)
                end
            end
        end
    end

    -- local personDestroyTab=allianceWar2RecordVoApi:getPersonDestroyTab()
    -- local allianceDestroyTab=allianceWar2RecordVoApi:getAllianceDestroyTab()
    -- if type==0 and (personDestroyTab==nil or SizeOfTable(personDestroyTab)>0) then
    local dFlag=allianceWar2RecordVoApi:getDFlag()
    -- print("dFlag",dFlag)
    if dFlag==-1 then
    -- if type==0 and dFlag==-1 then
    --     local selfAlliance = allianceVoApi:getSelfAlliance()
    --     local aid=selfAlliance.aid
    --     local uid=playerVoApi:getUid()
    --     local minTs,maxTs=nil,nil
    --     local warid=allianceWar2VoApi.warid
    --     if warid and warid>0 then
    --         socketHelper:alliancewarnewGetbattlelog(warid,3,aid,uid,minTs,maxTs,getbattlelogCallback)
    --     end
    -- -- elseif type==1 and (allianceDestroyTab==nil or SizeOfTable(allianceDestroyTab)>0) then
    -- elseif type==1 and dFlag==-1 then
        local selfAlliance = allianceVoApi:getSelfAlliance()
        local aid=selfAlliance.aid
        local uid=playerVoApi:getUid()
        local minTs,maxTs=nil,nil
        local warid=allianceWar2VoApi.warid
        -- print("warid",warid)
        if warid and warid>0 then
            -- warid=517899
            -- aid=1195 
            -- uid=1000268
            socketHelper:alliancewarnewGetbattlelog(warid,3,aid,uid,minTs,maxTs,getbattlelogCallback)
        end
    else
        self:switchTag(type)
    end
end
function allianceWar2RecordTab3:switchTag(idx)    
    if idx==0 then
        if self.tv1 then
            local recordPoint = self.tv1:getRecordPoint()
            self.tv1:reloadData()
            if recordPoint.y<=0 then
                self.tv1:recoverToRecordPoint(recordPoint)
            end
        else
            self:initTabLayer1()
        end
        if self.bgLayer1 then
            self.bgLayer1:setVisible(true)
            self.bgLayer1:setPosition(ccp(0,0))
        end
        if self.bgLayer2 then
            self.bgLayer2:setVisible(false)
            self.bgLayer2:setPosition(ccp(10000,0))
        end
    elseif idx==1 then
        if self.tv2 then
            local recordPoint = self.tv2:getRecordPoint()
            self.tv2:reloadData()
            if recordPoint.y<=0 then
                self.tv2:recoverToRecordPoint(recordPoint)
            end
        else
            self:initTabLayer2()
        end
        if self.bgLayer2 then
            self.bgLayer2:setVisible(true)
            self.bgLayer2:setPosition(ccp(0,0))
        end
        if self.bgLayer1 then
            self.bgLayer1:setVisible(false)
            self.bgLayer1:setPosition(ccp(10000,0))
        end
    end
end
function allianceWar2RecordTab3:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    if idx==1 and allianceWar2VoApi:checkInWarOrOver()==false then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_war_end_show"),30)
        do return end
    end
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_ColorWhite)

            self:getDataByType(idx)
         else
            v:setEnabled(true)
            local tabBtnItem = v
            local tabBtnLabel=tolua.cast(tabBtnItem:getChildByTag(31),"CCLabelTTF")
            tabBtnLabel:setColor(G_TabLBColorGreen)
         end
    end

end
function allianceWar2RecordTab3:tick()
    -- if self then
    --     if self.selectedTabIndex==0 then
    --         local dFlag=allianceWar2RecordVoApi:getDFlag()
    --         if dFlag==0 then
    --             if self.tv1 then
    --                 local recordPoint = self.tv1:getRecordPoint()
    --                 self.tv1:reloadData()
    --                 if recordPoint.y<=0 then
    --                     self.tv1:recoverToRecordPoint(recordPoint)
    --                 end
    --             end
    --             allianceWar2RecordVoApi:setDFlag(1)
    --         end
    --     elseif self.selectedTabIndex==1 then
    --         local dFlag=allianceWar2RecordVoApi:getDFlag()
    --         if dFlag==0 then
    --             if self.tv2 then
    --                 local recordPoint = self.tv2:getRecordPoint()
    --                 self.tv2:reloadData()
    --                 if recordPoint.y<=0 then
    --                     self.tv2:recoverToRecordPoint(recordPoint)
    --                 end
    --             end
    --             allianceWar2RecordVoApi:setDFlag(1)
    --         end
    --     end
    -- end
end


--用户处理特殊需求,没有可以不写此方法
function allianceWar2RecordTab3:doUserHandler()
    -- print("+++++++11111111allianceWar2VoApi:checkInWarOrOver()",allianceWar2VoApi:checkInWarOrOver())
    if allianceWar2VoApi:checkInWarOrOver()==true then
        local redDestroy=allianceWar2RecordVoApi.redDestroy or 0
        local blueDestroy=allianceWar2RecordVoApi.blueDestroy or 0
        if redDestroy==0 and blueDestroy==0 then
            local function getbattlelogCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData.data and sData.data.alog then
                        allianceWar2RecordVoApi:formatResultData(sData.data.alog)
                        -- if (G_AllianceWarDialogTb["allianceWarDialog"] or G_AllianceWarDialogTb["allianceWarOverviewDialog"]) and battleScene.isBattleing==false then
                        --     local isVictory=allianceWar2RecordVoApi:isVictory()
                        --     local params={}
                        --     local function callback(tag,object)
                        --     allianceSmallDialog:showWarResultDialog("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),isVictory,callback,true,7,params)
                        -- end
                        local redDestroy1=allianceWar2RecordVoApi.redDestroy or 0
                        local blueDestroy1=allianceWar2RecordVoApi.blueDestroy or 0
                        if self and self.redLb then
                            self.redLb:setString(getlocal("alliance_war_red_total",{redDestroy1}))
                        end
                        if self and self.blueLb then
                            self.blueLb:setString(getlocal("alliance_war_blue_total",{blueDestroy1}))
                        end
                    end
                end
            end
            local type=2
            local selfAlliance = allianceVoApi:getSelfAlliance()
            local aid=selfAlliance.aid
            local uid=playerVoApi:getUid()
            local warid=allianceWar2VoApi.warid
            print("warid22222",warid)
            if warid and warid>0 then
                socketHelper:alliancewarnewGetbattlelog(warid,type,aid,uid,nil,nil,getbattlelogCallback)
            end
        end
    else
        if self and self.redLb then
            self.redLb:setString(getlocal("alliance_war_red_total",{getlocal("alliance_war_end_show")}))
        end
        if self and self.blueLb then
            self.blueLb:setString(getlocal("alliance_war_blue_total",{getlocal("alliance_war_end_show")}))
        end
    end
end

--点击了cell或cell上某个按钮
function allianceWar2RecordTab3:cellClick(idx)

end

function allianceWar2RecordTab3:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    
    self.tv1=nil
    self.tv2=nil
    self.layerNum=nil
    self.allTabs=nil
    self.tvBg1=nil
    self.tvBg2=nil
    self.bgLayer1=nil
    self.bgLayer2=nil
    self.selectedTabIndex=nil
    self.bgLayer=nil

end
