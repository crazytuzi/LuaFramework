activityDialog=commonDialog:new()

function activityDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.acVo = nil
    return nc
end

--点击tab页签 idx:索引
function activityDialog:initTableView()
  local h, title
  if self.acVo.type == "firstRecharge" then
    h,title = self:getTitle(getlocal("firstRechargeReward"),30)
  elseif self.acVo.type == "discount" then
    h,title = self:getTitle(getlocal("activity_timeLabel"),30)
  else
    h,title = self:getTitle(getlocal("activity_"..self.acVo.type.."_title"),30)
  end
  local titleX = G_VisibleSizeWidth/2
  local titleY = G_VisibleSizeHeight - 70 - h
  title:setAnchorPoint(ccp(0.5, 0))
  title:setPosition(ccp(titleX, titleY))
  title:setColor(G_ColorYellowPro)
  self.bgLayer:addChild(title)

  
  local timeStr=""
  if self.acVo.type == "firstRecharge" then
    timeStr=getlocal("getRewardAnyRecharge")
  else
    timeStr=activityVoApi:getActivityTimeStr(self.acVo.st,self.acVo.acEt)
  end
  local timeH, timeLabel = self:getTitle(timeStr, 26)
  local timeY = titleY - timeH
  timeLabel:setAnchorPoint(ccp(0.5, 0))
  timeLabel:setPosition(ccp(titleX, timeY))
  self.bgLayer:addChild(timeLabel)

  self:doSomething()
  self:setTv(titleX, timeY)
end

function activityDialog:doSomething( ... )
  
end

function activityDialog:setTv(titleX, timeY)
  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, timeY - 20))
  self.panelLineBg:setPosition(ccp(titleX, 10))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,timeY - 40),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,20))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)
end

function activityDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize = CCSizeMake(100,100)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function activityDialog:getTitle(content, size)
  local showMsg=content or ""
  local width=G_VisibleSizeWidth - 20
  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
  local height=messageLabel:getContentSize().height+20
  -- messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end

function activityDialog:dispose()
  self.acVo = nil
  self=nil
end





