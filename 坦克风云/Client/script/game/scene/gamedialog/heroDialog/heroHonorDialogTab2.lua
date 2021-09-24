heroHonorDialogTab2={}
function heroHonorDialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.heroList=nil
    return nc
end

function heroHonorDialogTab2:updateHeroList()
    self.heroList=G_clone(heroVoApi:getHonoredHeroList())
end
function heroHonorDialogTab2:getHeroList()
    if self.heroList==nil then
        self.heroList={}
    end
    return self.heroList
end

function heroHonorDialogTab2:init(layerNum,parent)
    self.layerNum=layerNum
    self.parent=parent
    self.bgLayer=CCLayer:create()
    self:initTableView()
    return self.bgLayer
end

--设置对话框里的tableView
function heroHonorDialogTab2:initTableView()
    self:updateHeroList()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-200),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local heroList=self:getHeroList()
    if heroList and SizeOfTable(heroList)==0 then
        local noHeroLb=GetTTFLabelWrap(getlocal("hero_honor_no_had_honor"),35,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noHeroLb:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight - 135)*2/3))
        self.bgLayer:addChild(noHeroLb)
        noHeroLb:setColor(G_ColorGray)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function heroHonorDialogTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local heroList=self:getHeroList()
        return SizeOfTable(heroList)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(400,180)
        -- if idx==self.tvN-1 then
        --     tmpSize=CCSizeMake(400,80)
        -- end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local heroList=self:getHeroList()
        local hero=heroList[idx+1]

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                heroVoApi:showHeroRealiseDialog(hero,self.layerNum+1)
            end
        end
        local hei =150
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0,0.5));
        backSprie:setTag(1000+idx)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(backSprie,1)
        backSprie:setPosition(ccp(0,180/2))

        local mIcon=heroVoApi:getHeroIcon(hero.hid,hero.productOrder,nil,nil,nil,true)
        mIcon:setAnchorPoint(ccp(0,0.5))
        mIcon:setPosition(ccp(20,backSprie:getContentSize().height/2))
        backSprie:addChild(mIcon)
        mIcon:setScale(0.6)
        local heroVo=hero
        local nameStr=getlocal(heroListCfg[heroVo.hid].heroName)
        if  heroVoApi:isInQueueByHid(heroVo.hid) then
            nameStr=nameStr..getlocal("designate")
        end

        local xxx = 0

        local nameLb=GetTTFLabel(nameStr,28)
        local color=heroVoApi:getHeroColor(heroVo.productOrder)
        nameLb:setColor(color)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(ccp(xxx+mIcon:getContentSize().width,backSprie:getContentSize().height-50))
        backSprie:addChild(nameLb)
        local lvStr=G_LV()..hero.level.."/"..G_LV()..heroCfg.heroLevel[hero.productOrder]
        local lvLb=GetTTFLabel(lvStr,22)
        lvLb:setAnchorPoint(ccp(0,0.5))
        lvLb:setPosition(ccp(xxx+mIcon:getContentSize().width,30))
        backSprie:addChild(lvLb)

        local function callBack()
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                heroVoApi:showHeroRealiseDialog(hero,self.layerNum+1)
            end
        end
        local selectAllItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",callBack,nil,getlocal("hero_honor_realise"),25)
        selectAllItem:setAnchorPoint(ccp(1,0.5))
        local selectAllBtn=CCMenu:createWithItem(selectAllItem);
        selectAllBtn:setTouchPriority(-(self.layerNum-1)*20-2);
        selectAllBtn:setPosition(ccp(backSprie:getContentSize().width-10,backSprie:getContentSize().height/2))
        backSprie:addChild(selectAllBtn)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function heroHonorDialogTab2:tick()

end

function heroHonorDialogTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.layerNum=nil
    self.bgLayer=nil
end