acGhostWarsDialog=commonDialog:new()

function acGhostWarsDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.descH = {}
    return nc
end

function acGhostWarsDialog:initTableView()

  local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
  actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-105))
  self.bgLayer:addChild(actTime,5);
  actTime:setColor(G_ColorGreen)

  local acVo = acGhostWarsVoApi:getAcVo()
  if acVo ~= nil then
      local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
      local timeLabel=GetTTFLabel(timeStr,26)
      --timeLabel:setAnchorPoint(ccp(0,0))
      timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-140))
      self.bgLayer:addChild(timeLabel)
  end

  local desH,des,desH1,des1
  desH= self:getDesH(getlocal("activity_ghostWars_medalsAdd",{acGhostWarsVoApi:getMedalsRate()}),25, nil)
  table.insert(self.descH, desH)
  desH= self:getDesH(getlocal("activity_ghostWars_collectSpeed",{acGhostWarsVoApi:getCollectSpeedRate()}),25, nil)
  desH1= self:getDesH(getlocal("activity_ghostWars_collectSpeedNote"),25, nil)
  table.insert(self.descH, (desH+desH1))
  desH= self:getDesH(getlocal("activity_ghostWars_refitMaterials"),25, nil)
  desH1= self:getDesH(getlocal("activity_ghostWars_refitMaterialsNote",{acGhostWarsVoApi:getMinLevel()}),25, nil)
  table.insert(self.descH, (desH+desH1))
  

  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,15))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 40,G_VisibleSizeHeight - 265),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(20,110))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)

  local function gotoHandler( ... )
  	if G_checkClickEnable()==false then
      do
          return
      end
    end

    if newGuidMgr:isNewGuiding()==true then --新手引导
        do
          return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    activityAndNoteDialog:closeAllDialog()
  	mainUI:changeToWorld()
  end

  local gotoBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",gotoHandler,nil,getlocal("activity_heartOfIron_goto"),28)
  local gotoMenu=CCMenu:createWithItem(gotoBtn)
	gotoMenu:setAnchorPoint(ccp(0.5,0.5))
	gotoMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,65))
	gotoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(gotoMenu)


end

function acGhostWarsDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 3
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    local cellheight = self.descH[(idx+1)]+110
    if cellheight<=210 then
      cellheight=210
    end
    tmpSize = CCSizeMake(G_VisibleSizeWidth - 40,cellheight)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local cellheight = self.descH[(idx+1)]+100
    if cellheight<=210 then
      cellheight=200
    end
	local headercapInSet = CCRect(20, 20, 10, 10);
    local function headerSprieClick(hd,fn,idx)
    
    end
    local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",headercapInSet,headerSprieClick)
    headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, cellheight))
    headerSprie:ignoreAnchorPointForPosition(false);
    headerSprie:setAnchorPoint(ccp(0,0));
    headerSprie:setIsSallow(false)
    headerSprie:setPosition(ccp(0,0));
    cell:addChild(headerSprie)

    local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    backSprite:setContentSize(CCSizeMake(headerSprie:getContentSize().width-40,headerSprie:getContentSize().height-80))
	backSprite:setAnchorPoint(ccp(0,0))
	backSprite:setPosition(20,10)
	headerSprie:addChild(backSprite,1)

	local titleLb = GetTTFLabelWrap("",30,CCSizeMake(headerSprie:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	titleLb:setAnchorPoint(ccp(0,1))
	titleLb:setPosition(ccp(10,cellheight-10))
	headerSprie:addChild(titleLb)
	titleLb:setColor(G_ColorGreen)

  --小型资源箱
  --火控核心
  --总统军衔
  local icon

	if idx ==1 then
		titleLb:setString(getlocal("activity_ghostWars_againstTime"))
    icon = CCSprite:createWithSpriteFrameName("item_baoxiang_04.png")

		local collectSpeedLb= GetTTFLabelWrap(getlocal("activity_ghostWars_collectSpeed",{acGhostWarsVoApi:getCollectSpeedRate()}),25,CCSizeMake(backSprite:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		collectSpeedLb:setAnchorPoint(ccp(0,1))
		collectSpeedLb:setPosition(ccp(120,backSprite:getContentSize().height-30))
		backSprite:addChild(collectSpeedLb)

		local collectSpeedNoteLb =  GetTTFLabelWrap(getlocal("activity_ghostWars_collectSpeedNote"),25,CCSizeMake(backSprite:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		collectSpeedNoteLb:setAnchorPoint(ccp(0,1))
		collectSpeedNoteLb:setPosition(ccp(120,backSprite:getContentSize().height-30-collectSpeedLb:getContentSize().height))
		backSprite:addChild(collectSpeedNoteLb)
		collectSpeedNoteLb:setColor(G_ColorRed)

	elseif idx==2 then
		titleLb:setString(getlocal("activity_ghostWars_surprise"))
    icon = CCSprite:createWithSpriteFrameName("item_prop_393.png")

		local refitMaterialsLb= GetTTFLabelWrap(getlocal("activity_ghostWars_refitMaterials"),25,CCSizeMake(backSprite:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		refitMaterialsLb:setAnchorPoint(ccp(0,1))
		refitMaterialsLb:setPosition(ccp(120,backSprite:getContentSize().height-30))
		backSprite:addChild(refitMaterialsLb)

		local refitMaterialsNoteLb =  GetTTFLabelWrap(getlocal("activity_ghostWars_refitMaterialsNote",{acGhostWarsVoApi:getMinLevel()}),25,CCSizeMake(backSprite:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		refitMaterialsNoteLb:setAnchorPoint(ccp(0,1))
		refitMaterialsNoteLb:setPosition(ccp(120,backSprite:getContentSize().height-30-refitMaterialsLb:getContentSize().height))
		backSprite:addChild(refitMaterialsNoteLb)
		refitMaterialsNoteLb:setColor(G_ColorRed)
	elseif idx==0 then
		titleLb:setString(getlocal("activity_ghostWars_medals"))
    icon = CCSprite:createWithSpriteFrameName("Icon_BG.png")
    icon:setScale(100 / icon:getContentSize().width)

    local addIcon = CCSprite:createWithSpriteFrameName("military_rank_20.png")
    addIcon:setPosition(getCenterPoint(icon))
    icon:addChild(addIcon,1)

		local medalsLb= GetTTFLabelWrap(getlocal("activity_ghostWars_medalsAdd",{acGhostWarsVoApi:getMedalsRate()}),25,CCSizeMake(backSprite:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		medalsLb:setAnchorPoint(ccp(0,0.5))
		medalsLb:setPosition(ccp(120,backSprite:getContentSize().height/2))
		backSprite:addChild(medalsLb)
	end

  
  icon:setAnchorPoint(ccp(0,0.5))
  icon:setPosition(ccp(10,backSprite:getContentSize().height/2))
  backSprite:addChild(icon)



    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acGhostWarsDialog:tick()
  
end


function acGhostWarsDialog:getDesH(content, size, width)
  local showMsg=content or ""
  local width= width
  if width == nil then
    width = G_VisibleSizeWidth - 220
  end

  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))

  return height
end

function acGhostWarsDialog:dispose()
  self.desH = nil

  self=nil
end





