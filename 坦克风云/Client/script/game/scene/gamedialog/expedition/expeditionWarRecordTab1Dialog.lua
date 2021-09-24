expeditionWarRecordTab1Dialog={

}

function expeditionWarRecordTab1Dialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil;
    self.tv2=nil;

    self.bgLayer=nil;
    self.layerNum=nil;
    self.allTabs={};
    self.cellHeight=120

    self.selectedTabIndex=0;
    self.parentDialog=nil;

    self.cellHeightTab={}
    -- self.cellHeightTab2={}

    self.canSand=true
    self.noRecordLb=nil

    return nc;

end

function expeditionWarRecordTab1Dialog:init(layerNum,parentDialog)
    self.layerNum=layerNum
    self.parentDialog=parentDialog
    self.bgLayer=CCLayer:create()
    self.tankTb=expeditionVoApi:getDeadTank()
    self:initTabLayer()
    

    return self.bgLayer
end

function expeditionWarRecordTab1Dialog:initTabLayer()
    self:initTableView()

    local tb = {
    {text=getlocal("help3_t3_t2"),pos={140,self.bgLayer:getContentSize().height-250}},
    {text=getlocal("expeditionDead"),pos={330,self.bgLayer:getContentSize().height-250}},
    {text=getlocal("expeditionSurplus"),pos={520,self.bgLayer:getContentSize().height-250}},

    }
    for k,v in pairs(tb) do
        local typeLb=GetTTFLabel(v.text,28)
        typeLb:setAnchorPoint(ccp(0.5,0.5))
        typeLb:setPosition(ccp(v.pos[1],v.pos[2]))
        typeLb:setColor(G_ColorGreen)
        self.bgLayer:addChild(typeLb)
    end

    
    

end

function expeditionWarRecordTab1Dialog:initTableView()

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345+5+30),nil)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,100-65))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function expeditionWarRecordTab1Dialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then   
        
        return SizeOfTable(self.tankTb)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,self.cellHeight)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
        lineSp:setAnchorPoint(ccp(0.5,1));
        lineSp:setPosition((self.bgLayer:getContentSize().width-50)/2,self.cellHeight)
        lineSp:setScaleY(3)
        lineSp:setScaleX((self.bgLayer:getContentSize().width-50)/lineSp:getContentSize().width)
        cell:addChild(lineSp)
        if idx==SizeOfTable(self.tankTb)-1 then
            local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
            lineSp:setAnchorPoint(ccp(0.5,0));
            lineSp:setPosition((self.bgLayer:getContentSize().width-50)/2,0)
            lineSp:setScaleY(3)
            lineSp:setScaleX((self.bgLayer:getContentSize().width-50)/lineSp:getContentSize().width)
            cell:addChild(lineSp)
        end

        local tb = {
        {pos={0,self.cellHeight/2},},
        {pos={200,self.cellHeight/2},},
        {pos={400,self.cellHeight/2},},
        {pos={self.bgLayer:getContentSize().width-50,self.cellHeight/2},},
        }

        for k,v in pairs(tb) do
           local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
            lineSp:setAnchorPoint(ccp(0.5,0.5));
            lineSp:setPosition(ccp(v.pos[1],v.pos[2]))
            lineSp:setScaleY(5)
            lineSp:setScaleX((self.cellHeight)/lineSp:getContentSize().width)
            lineSp:setRotation(90)
            cell:addChild(lineSp)
        end
        local tankSp=G_getTankPic(tonumber(RemoveFirstChar(self.tankTb[idx+1].id)))
        tankSp:setPosition(ccp(100,self.cellHeight/2))
        cell:addChild(tankSp)

        if G_pickedList(tonumber(RemoveFirstChar(self.tankTb[idx+1].id))) ~= tonumber(RemoveFirstChar(self.tankTb[idx+1].id)) then
            local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
            tankSp:addChild(pickedIcon)
            pickedIcon:setPosition(tankSp:getContentSize().width*0.7,tankSp:getContentSize().height*0.5-10)
        end  

        local numLb=GetTTFLabel(self.tankTb[idx+1].num,28)
        numLb:setAnchorPoint(ccp(0.5,0.5))
        numLb:setPosition(ccp(300,self.cellHeight/2))
        cell:addChild(numLb)

        local leftNumLb=GetTTFLabel(self.tankTb[idx+1].leftNum,28)
        leftNumLb:setAnchorPoint(ccp(0.5,0.5))
        leftNumLb:setPosition(ccp(490,self.cellHeight/2))
        cell:addChild(leftNumLb)

       
        return cell

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

function expeditionWarRecordTab1Dialog:refreshTableView()


end

function expeditionWarRecordTab1Dialog:tick()

end


--用户处理特殊需求,没有可以不写此方法
function expeditionWarRecordTab1Dialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function expeditionWarRecordTab1Dialog:cellClick(idx)

end

function expeditionWarRecordTab1Dialog:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    
    self.tv=nil
    -- self.tv2=nil
    self.layerNum=nil
    self.allTabs=nil
    self.cellHeightTab=nil
    self.canSand=nil
    self.noRecordLb=nil

    -- self.bgLayer1=nil
    -- self.bgLayer2=nil
    self.selectedTabIndex=nil
    self.bgLayer=nil

end
