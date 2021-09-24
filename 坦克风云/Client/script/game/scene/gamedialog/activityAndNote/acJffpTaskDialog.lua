acJffpTaskDialog=commonDialog:new()

function acJffpTaskDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    return nc
end


--设置对话框里的tableView
function acJffpTaskDialog:initTableView()
    acJffpVoApi:checkIsToday()

    
    self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
   
    local descBgSp= CCSprite:create("public/superWeapon/weaponBg.jpg")
    descBgSp:setAnchorPoint(ccp(0.5,1))
    descBgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getPositionY()+self.panelLineBg:getContentSize().height/2-10))
    self.bgLayer:addChild(descBgSp,1)

    local scoreLb = GetTTFLabel(getlocal("activity_jffp_scoreprogress"),26)
    scoreLb:setAnchorPoint(ccp(0,1))
    scoreLb:setPosition(ccp(50,descBgSp:getContentSize().height-20))
    descBgSp:addChild(scoreLb)
    scoreLb:setColor(G_ColorYellowPro)

    local taskList,totalScore,curScore = acJffpVoApi:getTaskList()
    local percent=math.floor(curScore/totalScore*100)
	
	if(percent>100)then
		percent=100
	end
	AddProgramTimer(self.bgLayer,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180),823,nil,nil,"VipIconYellowBarBg.png","xpBar.png",824)
	local powerBar = tolua.cast(self.bgLayer:getChildByTag(823),"CCProgressTimer")
	powerBar:setScaleX(395/powerBar:getContentSize().width)
	powerBar:setScaleY(30/powerBar:getContentSize().height)
	powerBar:setPercentage(percent)
	local powerBarBg = tolua.cast(self.bgLayer:getChildByTag(824),"CCSprite")
	powerBarBg:setScaleX(400/powerBarBg:getContentSize().width)
	powerBarBg:setScaleY(40/powerBarBg:getContentSize().height)

	local percentLb=GetTTFLabel(curScore.."/"..totalScore,25)
	percentLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180))
	self.bgLayer:addChild(percentLb,2)

	local function codeSpHandler( ... )
		-- body
	end
	local bgH = percentLb:getPositionY()-80
	local tvBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 1, 1),codeSpHandler)
    tvBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,bgH))
    tvBgSp:setPosition(G_VisibleSizeWidth/2,30)
    tvBgSp:setAnchorPoint(ccp(0.5,0));
    self.bgLayer:addChild(tvBgSp,2)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,bgH-20),nil)
    self.bgLayer:addChild(self.tv,3)
    self.tv:setPosition(ccp(40,40))
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acJffpTaskDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    local taskList = acJffpVoApi:getTaskList()
    return SizeOfTable(taskList)
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    tmpSize=CCSizeMake(G_VisibleSizeWidth - 40,80)
     return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local taskList = acJffpVoApi:getTaskList()
    if taskList and taskList[idx+1] then
        local descStr = taskList[idx+1].desc
        local descLb=GetTTFLabelWrap(descStr,22,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(ccp(20,50))
        cell:addChild(descLb)

        local perStr = taskList[idx+1].num.."/"..taskList[idx+1].totalnum
        local perLb=GetTTFLabel(perStr,22)
        perLb:setAnchorPoint(ccp(1,0.5))
        perLb:setPosition(ccp(G_VisibleSizeWidth - 80,50))
        if taskList[idx+1].isComplete==1 then
            perLb:setColor(G_ColorYellowPro)
        end

        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-50,5))
        lineSp:setScaleX((self.bgLayer:getContentSize().width-50)/lineSp:getContentSize().width)
        cell:addChild(lineSp)

        cell:addChild(perLb)
    end
    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acJffpTaskDialog:tick()
    if acJffpVoApi:checkIsToday() == false then
        self.tv:reloadData()
    end
end

function acJffpTaskDialog:dispose()
    
    self=nil
end