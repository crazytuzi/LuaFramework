expeditionWarRecordTab2Dialog={

}

function expeditionWarRecordTab2Dialog:new()
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

function expeditionWarRecordTab2Dialog:init(layerNum,parentDialog)
    self.layerNum=layerNum
    self.parentDialog=parentDialog
    self.bgLayer=CCLayer:create()
    self.heroTb=expeditionVoApi:getHeroTb()
    self:initTabLayer()
    

    return self.bgLayer
end

function expeditionWarRecordTab2Dialog:initTabLayer()
    self:initTableView()

    local tb = {
    {text=getlocal("heroTitle"),pos={160,self.bgLayer:getContentSize().height-250}},
    {text=getlocal("state"),pos={460,self.bgLayer:getContentSize().height-250}},

    }
    for k,v in pairs(tb) do
        local typeLb=GetTTFLabel(v.text,28)
        typeLb:setAnchorPoint(ccp(0.5,0.5))
        typeLb:setPosition(ccp(v.pos[1],v.pos[2]))
        typeLb:setColor(G_ColorGreen)
        self.bgLayer:addChild(typeLb)
    end

    
    

end

function expeditionWarRecordTab2Dialog:initTableView()

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345-30),nil)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,100))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local function Recruit()
        require "luascript/script/game/scene/gamedialog/heroDialog/heroRecruitDialog"
        local td=heroRecruitDialog:new(self.layerNum+1)
        local tbArr={}
        local str = getlocal("recruitTitle")
        if G_getBHVersion()==2 then
            str = getlocal("newrecruitTitle")
        end

        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168  , 86, 10, 10),tbArr,nil,nil,str,true,self.layerNum+1)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local RecruitItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",Recruit,nil,getlocal("expeditionRecruit"),25)
    local RecruitBtn=CCMenu:createWithItem(RecruitItem)
    RecruitBtn:setTouchPriority(-(self.layerNum-1)*20-2)
    RecruitBtn:setAnchorPoint(ccp(1,0.5))
    RecruitBtn:setPosition(ccp(200,60))
    self.bgLayer:addChild(RecruitBtn)


    local function Troops()
        require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
        local buildVo=buildingVoApi:getBuildiingVoByBId(11)
        local td=tankFactoryDialog:new(11,self.layerNum)
        local bName=getlocal(buildingCfg[6].buildName)
        local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,self.layerNum+1)
        td:tabClick(1)
        sceneGame:addChild(dialog,self.layerNum+1)
        
    end
    local TroopsItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",Troops,nil,getlocal("expeditionTroops"),25)
    local TroopsBtn=CCMenu:createWithItem(TroopsItem)
    TroopsBtn:setTouchPriority(-(self.layerNum-1)*20-2)
    TroopsBtn:setAnchorPoint(ccp(1,0.5))
    TroopsBtn:setPosition(ccp(460,60))
    self.bgLayer:addChild(TroopsBtn)

end

function expeditionWarRecordTab2Dialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then   
        
        return SizeOfTable(self.heroTb)
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
        if idx==SizeOfTable(self.heroTb)-1 then
            local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png");
            lineSp:setAnchorPoint(ccp(0.5,0));
            lineSp:setPosition((self.bgLayer:getContentSize().width-50)/2,0)
            lineSp:setScaleY(3)
            lineSp:setScaleX((self.bgLayer:getContentSize().width-50)/lineSp:getContentSize().width)
            cell:addChild(lineSp)
        end

        local tb = {
        {pos={0,self.cellHeight/2},},
        {pos={260,self.cellHeight/2},},
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

        local heroSp=heroVoApi:getHeroIcon(self.heroTb[idx+1].hid,self.heroTb[idx+1].productOrder)
        heroSp:setScale(0.5)
        heroSp:setPosition(ccp(130,self.cellHeight/2))
        cell:addChild(heroSp)

        local stateLb=GetTTFLabel(getlocal("alliance_war_standby_btn"),30)
        stateLb:setAnchorPoint(ccp(0.5,0.5))
        stateLb:setPosition(ccp(430,self.cellHeight/2))
        cell:addChild(stateLb)

        if self.heroTb[idx+1].isDead==1 then
            stateLb:setString(getlocal("expeditionHeroDead"))
            stateLb:setColor(G_ColorRed)
        elseif heroVoApi:isInQueueByHid(self.heroTb[idx+1].hid) then
            stateLb:setString(getlocal("expeditionPerformingTask"))
            stateLb:setColor(G_ColorYellowPro)
        end

       
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

function expeditionWarRecordTab2Dialog:refreshTableView()


end

function expeditionWarRecordTab2Dialog:tick()

end


--用户处理特殊需求,没有可以不写此方法
function expeditionWarRecordTab2Dialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function expeditionWarRecordTab2Dialog:cellClick(idx)

end

function expeditionWarRecordTab2Dialog:dispose()
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
