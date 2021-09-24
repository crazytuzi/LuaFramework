shamBattleRankDialog = commonDialog:new()

function shamBattleRankDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.cellheight1=70
    return nc
end

function shamBattleRankDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
end

function shamBattleRankDialog:initTableView()
	self.rankList=arenaVoApi:getArenaVo().ranklist
	local function callBack1(...)
	return self:eventHandler1(...)
	end
	local hd1= LuaEventHandler:createHandler(callBack1)
	local height=0;
	self.tv=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-380+120-15),nil)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(30,40))
	self.bgLayer:addChild(self.tv,3)
	self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function shamBattleRankDialog:eventHandler1(handler,fn,idx,cel)
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

function shamBattleRankDialog:doUserHandler()
	 -- local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
  --   bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSize.height-240+120));
  --   bgSp:setScaleY(60/bgSp:getContentSize().height)
  --   bgSp:setScaleX(1200/bgSp:getContentSize().width)
  --   self.bgLayer:addChild(bgSp)

    local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),function () do return end end)
    backSprie1:setContentSize(CCSizeMake(600,80))
    backSprie1:setAnchorPoint(ccp(0.5,1))
    backSprie1:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-90)
    self.bgLayer:addChild(backSprie1)

    local descLb=GetTTFLabelWrap(getlocal("shamBattle_top100Des"),25,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setPosition(ccp(30,backSprie1:getContentSize().height/2))
    backSprie1:addChild(descLb,1)

    -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    -- lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSize.height-270+120));
    -- self.bgLayer:addChild(lineSp,1)

    local hi=G_VisibleSize.height-305+120-10
    local tlbSize=26
    local tLb1 = GetTTFLabel(getlocal("alliance_scene_rank"),tlbSize);
    tLb1:setAnchorPoint(ccp(0,0.5));
    tLb1:setPosition(ccp(70,hi));
    self.bgLayer:addChild(tLb1,2);
    tLb1:setColor(G_ColorGreen)

    local tLb2 = GetTTFLabel(getlocal("alliance_scene_button_info_name"),tlbSize);
    tLb2:setAnchorPoint(ccp(0,0.5));
    tLb2:setPosition(ccp(210,hi));
    self.bgLayer:addChild(tLb2,2);
    tLb2:setColor(G_ColorGreen)

    local tLb3 = GetTTFLabel(getlocal("RankScene_level"),tlbSize);
    tLb3:setAnchorPoint(ccp(0,0.5));
    tLb3:setPosition(ccp(375,hi));
    self.bgLayer:addChild(tLb3,2);
    tLb3:setColor(G_ColorGreen)

    local tLb4 = GetTTFLabel(getlocal("showAttackRank"),tlbSize);
    tLb4:setAnchorPoint(ccp(0.5,0.5));
    tLb4:setPosition(ccp(540,hi));
    self.bgLayer:addChild(tLb4,2);
    tLb4:setColor(G_ColorGreen)

    local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function () do return end end)
    backSprie2:setContentSize(CCSizeMake(600,self.bgLayer:getContentSize().height-80-40-120))
    backSprie2:setAnchorPoint(ccp(0.5,0))
    backSprie2:setPosition(self.bgLayer:getContentSize().width/2,25)
    self.bgLayer:addChild(backSprie2)

    -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    -- lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSize.height-340+120));
    -- self.bgLayer:addChild(lineSp,1)
end

function shamBattleRankDialog:dispose()
end