--军徽功能列表面板
emblemFunctionListDialog=commonDialog:new()
function emblemFunctionListDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--设置或修改每个Tab页签
function emblemFunctionListDialog:resetTab()
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
end

function emblemFunctionListDialog:initFunctionTb()
  local function callBack1()
     if base.emblemSwitch~=1 then
          do return end
      end
      local permitLevel=emblemVoApi:getPermitLevel()
      if permitLevel and playerVoApi:getPlayerLevel()<permitLevel then
          smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("emblem_building_not_permit",{permitLevel}),nil,3)
          do return end
      end
      emblemVoApi:showMainDialog(self.layerNum+1)
  end

  local function callBack11()
    local td=smallDialog:new()
    local str1=getlocal("emblem_rule_tip1")
    local tabStr={" ",str1," "}
    local colorTb={nil,G_ColorWhite,nil}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTb)
    sceneGame:addChild(dialog,self.layerNum+1)
  end

  local function callBack2()
    local flag,openLv=emblemTroopVoApi:checkIfEmblemTroopIsOpen()
    if flag==false then  
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{openLv}),30)
      do return end
    end
    require "luascript/script/game/scene/gamedialog/emblem/emblemTroopListDialog"
    local td=emblemTroopListDialog:new()
    local tbArr={}
    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("emblem_troop"),true,self.layerNum+1)
    sceneGame:addChild(dialog,self.layerNum + 1)
  end

  local function callBack12()
    local td=smallDialog:new()
    local str1=getlocal("emblem_troop_tip1")
    local str2=getlocal("emblem_troop_tip2")
    local tabStr={" ",str2,str1," "}
    local colorTb={nil,G_ColorWhite,G_ColorWhite,nil}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTb)
    sceneGame:addChild(dialog,self.layerNum+1)
  end

  self.functionTb={
    {icon="emblemIcon.png",nameKey="emblem_title",callBack=callBack1,callBack2=callBack11,flag=1},
  }
  if emblemTroopVoApi:checkIfEmblemTroopCanShow()==true then
    table.insert(self.functionTb,{icon="emblemTroop_icon.png",nameKey="emblem_troop",callBack=callBack2,callBack2=callBack12,flag=2})
  end
end

function emblemFunctionListDialog:doUserHandler()
  self:initFunctionTb()
end

--设置对话框里的tableView
function emblemFunctionListDialog:initTableView()
  self.tvWidth,self.tvHeight,self.cellHeight=self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-145,130
  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd=LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
  self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,30)
  self.bgLayer:addChild(self.tv)

  self.tv:setMaxDisToBottomOrTop(120)

  if self.guideItem then
    if otherGuideMgr.isGuiding then
      if otherGuideMgr.curStep==16 then --引导军徽系统选项
        otherGuideMgr:setGuideStepField(72,self.guideItem,true)
        otherGuideMgr:showGuide(72)
      elseif otherGuideMgr.curStep==73 then --引导军徽部队功能选项
        otherGuideMgr:setGuideStepField(74,self.guideItem,true)
        otherGuideMgr:showGuide(74)
      end
    end
  end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function emblemFunctionListDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(self.functionTb)
  elseif fn=="tableCellSizeForIndex" then 
    return  CCSizeMake(self.tvWidth,self.cellHeight)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local rect=CCRect(0, 0, 50, 50)
    local capInSet=CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
       
    local hei=self.cellHeight-10
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    backSprie:setContentSize(CCSizeMake(self.tvWidth,hei))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(0,10))
    backSprie:setTag(1000+idx)
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    cell:addChild(backSprie,1)

    local mIcon=CCSprite:createWithSpriteFrameName(self.functionTb[idx+1].icon)
    mIcon:setAnchorPoint(ccp(0,0.5))
    mIcon:setPosition(ccp(10,backSprie:getContentSize().height/2))
    backSprie:addChild(mIcon)

    local qualityLb=GetTTFLabelWrap(getlocal(self.functionTb[idx+1].nameKey),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    qualityLb:setAnchorPoint(ccp(0,0.5))
    qualityLb:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+15,backSprie:getContentSize().height/2))
    backSprie:addChild(qualityLb)

    local function callBack()
      if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
          do return end
        else
          base.setWaitTime=G_getCurDeviceMillTime()
        end
        self.functionTb[idx+1].callBack2()
      end
    end
    local menuItem=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",callBack,11,nil,nil)
    local menu=CCMenu:createWithItem(menuItem)
    menu:setPosition(ccp(365,backSprie:getContentSize().height/2))
    menu:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:addChild(menu,3)


    local function onSelectAll()
      if self.tv:getIsScrolled()==true then
        do
            return
        end
      end
      if otherGuideMgr.isGuiding then
        otherGuideMgr:toNextStep()
      end
      self.functionTb[idx+1].callBack()
    end
    local selectAllItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onSelectAll,nil,getlocal("allianceWar_enter"),25,100)
    selectAllItem:setAnchorPoint(ccp(1,0.5))
    selectAllItem:setScale(0.8)
    local lb=selectAllItem:getChildByTag(100)
    if lb then
      lb=tolua.cast(lb, "CCLabelTTF")
      lb:setFontName("Helvetica-bold")
    end
    local selectAllBtn=CCMenu:createWithItem(selectAllItem)
    selectAllBtn:setTouchPriority(-(self.layerNum-1)*20-2)
    selectAllBtn:setPosition(ccp(backSprie:getContentSize().width-10,backSprie:getContentSize().height/2))
    backSprie:addChild(selectAllBtn)

    if otherGuideMgr.isGuiding then --找出引导元素
      if (otherGuideMgr.curStep==16 and idx==0) or (otherGuideMgr.curStep==73 and idx==1) then
        self.guideItem=selectAllItem
      end
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

function emblemFunctionListDialog:tick()
end

function emblemFunctionListDialog:dispose()
  self.guideItem=nil
end