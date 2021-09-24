
require "luascript/script/game/gamemodel/alliance/allianceShopVoApi"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFuDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSkillDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceEventDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/setGarrisonDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceHelpDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/rebelDialog"
allianceFunctionDialog={}

function allianceFunctionDialog:new(layerNum,parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.cellHeight=160
    self.btnTb=nil
    self.listener=nil
    self.parent=parent
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="in" then
      self.cellHeight =200
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconLevel.plist")
    spriteController:addPlist("public/allianceSkills.plist")
    spriteController:addTexture("public/allianceSkills.png")
    return nc
end

--设置或修改每个Tab页签
function allianceFunctionDialog:init(layerNum)
  self.layerNum=layerNum
  self.bgLayer=CCLayer:create();
    
  -- local rect = CCRect(0, 0, 50, 50);
  -- local capInSet = CCRect(20, 20, 10, 10);
  -- local function click(hd,fn,idx)
  -- end
  -- self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,click)
  -- self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-190))
  -- self.tvBg:ignoreAnchorPointForPosition(false)
  -- self.tvBg:setAnchorPoint(ccp(0.5,0))
  -- self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
  -- self.bgLayer:addChild(self.tvBg)
  self:initTabLayer(0);
  return self.bgLayer      

end

function allianceFunctionDialog:initTabLayer()
    self:initTableView()
    local function numTipRefresh(event,data)
        if self and self.btnTb and data then
          local key=data.key
          if self.btnTb[key] and self.refreshNumTips then
            self:refreshNumTips(key)
          end
        end
    end
    self.listener=numTipRefresh
    eventDispatcher:addEventListener("allianceFunction.numChanged",numTipRefresh)
end

function allianceFunctionDialog:initFunctionTb()
  local function callBack1()
      if base.ifAllianceShopOpen==0 then

        do
          return
        end
      end
      allianceShopVoApi:showShopDialog(self.layerNum+1)
  end 

  local function callBack2()
      local td=allianceSkillDialog:new(self.layerNum+1)
      local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_technology"),true,self.layerNum+1)
      sceneGame:addChild(dialog,self.layerNum+1)
  end 

  local function callBack3()
      local td=allianceFuDialog:new(self.layerNum+1)
      local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_duplicate"),true,self.layerNum+1)
      sceneGame:addChild(dialog,self.layerNum+1)
  end 

  local function callBack4()
      local td=allianceEventDialog:new(self.layerNum+1)
      local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_scene_event_title"),true,self.layerNum+1)
      sceneGame:addChild(dialog,self.layerNum+1)
  end 

  local function callBack5()
      local td = setGarrsionDialog:new(self.layerNum+1)
      local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),nil,nil,nil,getlocal("alliance_setGarrsion"),true,self.layerNum+1)
      sceneGame:addChild(dialog,self.layerNum+1)
  end 

  local function callBack6()
      local td = allianceHelpDialog:new(self.layerNum+1)
      local tbArr={getlocal("alliance_help_tab1"),getlocal("alliance_help_tab2"),getlocal("alliance_help_tab3")}
      local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("alliance_help"),true,self.layerNum+1)
      sceneGame:addChild(dialog,self.layerNum+1)
  end 

  local function callBack7()
      local td = rebelDialog:new(self.layerNum+1)
      local tbArr={}
      local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("alliance_rebel_info"),true,self.layerNum+1)
      sceneGame:addChild(dialog,self.layerNum+1)
  end 

  local function callBack8()
    allianceCityVoApi:showAllianceCityDialog(self.layerNum+1)
  end 

  self.functionTb={
  {icon="Icon_novicePacks.png",nameKey="allianceShop",descKey="alliance_function_desc1",callBack=callBack1,index=1},
  {icon="Icon_ke_yan_zhong_xin.png",nameKey="alliance_technology",descKey="alliance_function_desc2",callBack=callBack2,index=2},
  {icon="mainBtnCheckpoint_Down.png",nameKey="alliance_duplicate",descKey="alliance_function_desc3",callBack=callBack3,index=3},
  {icon="Icon_warn.png",nameKey="alliance_scene_event_title",descKey="alliance_function_desc4",callBack=callBack4,index=5},
  -- {icon="IconHelp.png",nameKey="alliance_setGarrsion",descKey="alliance_function_desc5",callBack=callBack5,index=6},
  }

  if base.allianceHelpSwitch==1 then
      local hData={icon="allianceHelp.png",nameKey="alliance_help",descKey="alliance_function_desc6",callBack=callBack6,index=7}
      table.insert(self.functionTb,hData)
  end

  if base.isRebelOpen==1 then
      local rebData={icon="rebelIcon.png",nameKey="alliance_rebel_detail",descKey="alliance_function_desc7",callBack=callBack7,index=4}
      table.insert(self.functionTb,rebData)
  end

  if base.allianceCitySwitch==1 then
      local cityData={icon="allianceCityIcon.png",nameKey="alliance_city",descKey="alliance_function_desc8",callBack=callBack8,index=8}
      table.insert(self.functionTb,cityData)
  end

  if base.isAllianceSkillSwitch==0 then
     for k,v in pairs(self.functionTb) do
      if v.nameKey=="alliance_technology" then
          table.remove(self.functionTb,k)
      end
    end
  end

  if base.ifAllianceShopOpen==0 then
    for k,v in pairs(self.functionTb) do
      if v.nameKey=="allianceShop" then
          table.remove(self.functionTb,k)
      end
    end
  end
  if base.isAllianceFubenSwitch==0 then
    for k,v in pairs(self.functionTb) do
      if v.nameKey=="alliance_duplicate" then
          table.remove(self.functionTb,k)
      end
    end
  end
  if base.isGarrsionOpen==0 then
    for k,v in pairs(self.functionTb) do
      if v.nameKey=="alliance_setGarrsion" then
          table.remove(self.functionTb,k)
      end
    end
  end  

  local function sortList(a,b)
    if a.index<b.index then
      return true
    end
    return false
  end
  table.sort(self.functionTb,sortList)
  self.btnTb={}
end

--设置对话框里的tableView
function allianceFunctionDialog:initTableView()
    self:initFunctionTb()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-25-165),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)

    self.tv:setMaxDisToBottomOrTop(120)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceFunctionDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.functionTb)
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(400,self.cellHeight)
         
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
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       cell:addChild(backSprie,1)

       
      local mIcon=nil
      local iconPosX,iconPosY,iconSize=60,backSprie:getContentSize().height/2,100
       if self.functionTb[idx+1].icon=="mainBtnCheckpoint_Down.png" then
          mIcon=CCSprite:createWithSpriteFrameName("Icon_BG.png")
          if mIcon then
            mIcon:setScale(iconSize/mIcon:getContentSize().width)
            mIcon:setPosition(iconPosX,iconPosY)
            backSprie:addChild(mIcon,1)
          end
          local mIcon2=CCSprite:createWithSpriteFrameName(self.functionTb[idx+1].icon)
          if mIcon2 then
            mIcon2:setScale(mIcon:getContentSize().width/mIcon2:getContentSize().width)
            mIcon2:setPosition(iconPosX,iconPosY)
            backSprie:addChild(mIcon2,2)
          end
       else
         mIcon=CCSprite:createWithSpriteFrameName(self.functionTb[idx+1].icon)
          if mIcon then
            mIcon:setPosition(iconPosX,iconPosY)
            backSprie:addChild(mIcon,2)
          end
       end

       local titleSize2 = 350
       local strSize2 = 280
       local subWidth = 0
       if G_getCurChoseLanguage() =="ar" then
          titleSize2 =280
          subWidth = -10
       end       

       local qualityLb=GetTTFLabelWrap(getlocal(self.functionTb[idx+1].nameKey),28,CCSizeMake(titleSize2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
       qualityLb:setAnchorPoint(ccp(0,1))
       qualityLb:setPosition(ccp(iconPosX+iconSize/2+15+subWidth,backSprie:getContentSize().height-30))
       backSprie:addChild(qualityLb)
       qualityLb:setColor(G_ColorGreen2)
       
       local descLb=GetTTFLabelWrap(getlocal(self.functionTb[idx+1].descKey),22,CCSizeMake(strSize2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
       descLb:setAnchorPoint(ccp(0,1))
       descLb:setPosition(ccp(iconPosX+iconSize/2+15+subWidth,backSprie:getContentSize().height-70))
       backSprie:addChild(descLb)
       



       local function onSelectAll()
         self.functionTb[idx+1].callBack()
       end
       local selectAllItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onSelectAll,nil,getlocal("allianceWar_enter"),25)
       selectAllItem:setAnchorPoint(ccp(1,0.5))
       local selectAllBtn=CCMenu:createWithItem(selectAllItem);
       selectAllBtn:setTouchPriority(-(self.layerNum-1)*20-2);
       selectAllBtn:setPosition(ccp(backSprie:getContentSize().width-10,backSprie:getContentSize().height/2))
       backSprie:addChild(selectAllBtn)
       
       local key=self.functionTb[idx+1].nameKey
       self.btnTb[key]=selectAllItem

       G_addNumTip(selectAllItem,ccp(selectAllItem:getContentSize().width+5,selectAllItem:getContentSize().height-15))

       self:refreshNumTips(key)

       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--点击tab页签 idx:索引
function allianceFunctionDialog:tabClick(idx)
        if newGuidMgr:isNewGuiding() then --新手引导
              if newGuidMgr.curStep==39 and idx~=1 then
                    do
                        return
                    end
              end
        end
        PlayEffect(audioCfg.mouseClick)
        
        for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:doUserHandler()
            self:getDataByType(idx)
            
         else
            v:setEnabled(true)
         end
    end

    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function allianceFunctionDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function allianceFunctionDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,120)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,800)
        end
    end
end

function allianceFunctionDialog:refreshNumTips(nameKey)
  local function refreshTip(key)
    local count=0
    if key=="alliance_duplicate" then --军团副本
      local rewardCount,availableCount=allianceFubenVoApi:getFunbenRewards()
      count=availableCount
    elseif key=="alliance_scene_event_title" then --军团事件
      count=allianceVoApi:getUnReadEventNum()
    elseif key=="alliance_help" then --军团协助
      local helplist=allianceHelpVoApi:getList(1)
      if helplist then
        count=SizeOfTable(helplist)
      end
    elseif key=="alliance_rebel_detail" then --叛军详情
      local rebellist=rebelVoApi:getRebelList(1)
      if rebellist then
        count=SizeOfTable(rebellist)
        if count==0 then
          local findlist=rebelVoApi:getFindRebelList()
          count=SizeOfTable(findlist)
        end
      end
    end
    if count>0 then
      G_refreshNumTip(self.btnTb[key],true,count)
    else
      G_refreshNumTip(self.btnTb[key],false)
    end
  end
  if nameKey then
    refreshTip(nameKey)
  else
    if self.btnTb then
      for k,v in pairs(self.btnTb) do
        refreshTip(k)
      end
    end
  end
end

function allianceFunctionDialog:tick()

end

function allianceFunctionDialog:dispose()
    eventDispatcher:removeEventListener("allianceFunction.numChanged",self.listener)
    self.expandIdx=nil
    self.btnTb=nil
    self.listener=nil
    self=nil
    spriteController:removePlist("public/allianceSkills.plist")
    spriteController:removeTexture("public/allianceSkills.png")
end




