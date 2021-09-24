acMeteoriteLandingTab2 ={}

function acMeteoriteLandingTab2:new( )
    local nc = {}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.tv= nil
    self.ShowWidth=600
    self.expandIdx={}
    -- self.expandHeight=G_VisibleSizeHeight-370
    self.expandHeight=1136-300
    self.normalHeight =150
    self.cell1=nil 
    self.cell2=nil
    return nc
end

function acMeteoriteLandingTab2:init(layerNum)
  	self.bgLayer=CCLayer:create()
  	self.layerNum =layerNum
    if G_isIphone5() then
        self.expandHeight=1136-330
    else
        self.expandHeight=1136-500
    end
     local function onTvChange(event,data)
        self:tvChange(data)
    end
    self.tvChangeListener=onTvChange
    eventDispatcher:addEventListener("MeteoriteLanding.Change",onTvChange)

  	self:initTableView()
  	return self.bgLayer
end

function acMeteoriteLandingTab2:tvChange( )
    if self.tv then
         local recordPoint=self.tv:getRecordPoint()
          self.tv:reloadData()
          self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acMeteoriteLandingTab2:initTableView( )

    local function nilFunc()
    end

    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20, 20, 10, 10),nilFunc)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 150))
    backSprie:setAnchorPoint(ccp(0.5,1));
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-180)
    self.bgLayer:addChild(backSprie)

    local upLb = getlocal("activity_meteoriteLanding_Tab2_des")
    local desTv, desLabel = G_LabelTableView(CCSizeMake(backSprie:getContentSize().width-220, 120),upLb,25,kCCTextAlignmentLeft)
    backSprie:addChild(desTv)
    desTv:setPosition(ccp(30,20))
    desTv:setAnchorPoint(ccp(0,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(60)

    self.cellWidth=self.bgLayer:getContentSize().width-60

    local function desFunc()
      
          if G_checkClickEnable()==false then
              do
                  return
              end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
          end
          PlayEffect(audioCfg.mouseClick)
          local sd=smallDialog:new()
          local labelTab={"\n",getlocal("activity_meteoriteLanding_Tab2_tip2"),"\n",getlocal("activity_meteoriteLanding_Tab2_tip1"),"\n"}
          local colorTab={nil}
          local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(580,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,colorTab,nil,true)
          sceneGame:addChild(dialogLayer,self.layerNum+1)
          dialogLayer:setPosition(ccp(0,0))
      
    end
    local desItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",desFunc,nil,getlocal("shuoming"),25)
    desItem:setAnchorPoint(ccp(1,0.5))
    local desBtn=CCMenu:createWithItem(desItem)
    desItem:setScale(0.9)
    desBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    desBtn:setPosition(ccp(backSprie:getContentSize().width-20,backSprie:getContentSize().height/2))
    backSprie:addChild(desBtn)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.ShowWidth-10,self.bgLayer:getContentSize().height-360),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)


   -- self.recordPoint =  self.tv:getRecordPoint()
   -- print("self.recordPoint",self.recordPoint.x,self.recordPoint.y)

end

function acMeteoriteLandingTab2:eventHandler( handler,fn,idx,cel )
   if fn=="numberOfCellsInTableView" then
        return 2 ---需按照异星资源的数量确定
   elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.expandIdx and self.expandIdx["k"..idx]~=nil then
            tmpSize=CCSizeMake(self.cellWidth,self.expandHeight)
        else
            tmpSize=CCSizeMake(self.cellWidth,self.normalHeight)
        end
        return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
          local cell=CCTableViewCell:new()
          cell:autorelease()
          local expanded=false
          if self.expandIdx and self.expandIdx["k"..idx]~=nil then
            expanded=true
          end
          if expanded then
            cell:setContentSize(CCSizeMake(self.cellWidth, self.expandHeight))
          else
            cell:setContentSize(CCSizeMake(self.cellWidth, self.normalHeight))
          end

          local rect = CCRect(0, 0, 50, 50);
          local capInSet = CCRect(20, 20, 10, 10);
          local function cellClick(hd,fn,idx)
             return self:cellClick(idx)
          end

          local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
          headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
          headerSprie:ignoreAnchorPointForPosition(false);
          headerSprie:setAnchorPoint(ccp(0,0));
          headerSprie:setTag(1000+idx)
          headerSprie:setIsSallow(false)
          headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
          headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height))
          cell:addChild(headerSprie)
          
          -- 需要修改
          local nameStr,iconStr,rid,des,getNum=acMeteoriteLandingVoApi:getGetNameAndPic(idx+1)
          local num=alienTechVoApi:getAlienResByType(rid) or 0

          local icon=CCSprite:createWithSpriteFrameName(iconStr)
          icon:setScale(100/icon:getContentSize().height)
          icon:setAnchorPoint(ccp(0.5,0.5))
          icon:setPosition(ccp(70,headerSprie:getContentSize().height/2))
          headerSprie:addChild(icon)

          local desStr = nameStr .. "x" .. FormatNumber(getNum)
          local nameLb=GetTTFLabel(desStr,25)
          nameLb:setAnchorPoint(ccp(0,1))
          nameLb:setPosition(ccp(160,headerSprie:getContentSize().height/2+10))
          -- nameLb:setColor(G_ColorYellowPro)
          headerSprie:addChild(nameLb)

          local numLb=GetTTFLabel(getlocal("propInfoNum",{FormatNumber(num)}),25)
          numLb:setAnchorPoint(ccp(0,0))
          numLb:setPosition(ccp(160,25))
          -- headerSprie:addChild(numLb)


          if expanded==true then

            self:initExpand(idx,cell)
          end

          local item = acMeteoriteLandingVoApi:getCostItem(idx+1)
            local costItem={{},{}}
            if item[1].type == "r" then
                costItem[2]=item[1]
                costItem[1]=item[2]
            else
                costItem[2]=item[2]
                costItem[1]=item[1]
            end
          local maxNum = math.floor(acMeteoriteLandingVoApi:getMaxNum(costItem))
          local btn
          if expanded==false then
             if maxNum==0 then
                  btn=GraySprite:createWithSpriteFrameName("moreBtn.png")
             else
                  btn=CCSprite:createWithSpriteFrameName("moreBtn.png")

             end


          else
             if maxNum==0 then
                  btn=GraySprite:createWithSpriteFrameName("lessBtn.png")
             else
                  btn=CCSprite:createWithSpriteFrameName("lessBtn.png")

             end

          end
           btn:setAnchorPoint(ccp(0,0))
           btn:setPosition(ccp(headerSprie:getContentSize().width-10-btn:getContentSize().width,5))
           headerSprie:addChild(btn)

          -- if idx==0 then
          --     self.cell1=cell

          -- end

          -- if idx==1 then
          --     self.cell2=cell
          -- end


          return cell  
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end	
end

--创建或刷新CCTableViewCell
function acMeteoriteLandingTab2:loadCCTableViewCell(cell,idx,refresh)
end

function acMeteoriteLandingTab2:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)

        if self.expandIdx==nil then
          self.expandIdx={}
        end
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
            if idx==1001 then
             -- if self.cell1 and self.cell2 then
                -- local moveBy1 = self:moveAnimation()
                -- self.cell1:runAction(moveBy1)
                -- local moveBy2 = self:moveAnimation()
                -- self.cell2:runAction(moveBy2)
             -- end
            end
        end
    end

end

function acMeteoriteLandingTab2:moveAnimation()
  local moveBy = CCMoveBy:create(0.3,ccp(0,-self.normalHeight))
  return moveBy
end

function acMeteoriteLandingTab2:initExpand(idx,cell)
  if cell then
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);

   local nameStr,iconStr,rid,desc=acMeteoriteLandingVoApi:getGetNameAndPic(idx+1)
   local num=alienTechVoApi:getAlienResByType(rid) or 0

    local function touchHander()
    end
    
    

     local icon=CCSprite:createWithSpriteFrameName(iconStr)
      icon:setScale(100/icon:getContentSize().height)
      icon:setAnchorPoint(ccp(0.5,0.5))
      icon:setPosition(ccp(70,self.expandHeight-self.normalHeight-60))
      cell:addChild(icon)

      local function tipTouch()
          local sd=smallDialog:new()
          local labelTab={"\n",getlocal("activity_meteoriteLanding_getRes" .. idx+1),"\n",}
          local colorTab={nil,nil,nil}
          local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(580,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,labelTab,25,colorTab,nil,true)
          sceneGame:addChild(dialogLayer,self.layerNum+1)
          dialogLayer:setPosition(ccp(0,0))
      end
      local tipItem=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
      -- tipItem:setScale(0.8)
      tipItem:setAnchorPoint(ccp(1,0.5))
      local tipMenu = CCMenu:createWithItem(tipItem)
      tipMenu:setPosition(ccp(self.cellWidth,self.expandHeight-self.normalHeight-60))
      tipMenu:setTouchPriority(-(self.layerNum-1)*20-2)
      cell:addChild(tipMenu,1)


      local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
      exBg:setAnchorPoint(ccp(0,0))
      exBg:setContentSize(CCSize(self.cellWidth,self.expandHeight-self.normalHeight-280))
      exBg:setPosition(ccp(0,165))
      exBg:setTag(2)
      cell:addChild(exBg)

      local addH=11
      local typeLb=GetTTFLabel(getlocal("resourceType"),20)
      typeLb:setAnchorPoint(ccp(0.5,0.5))
      typeLb:setPosition(ccp(150,exBg:getContentSize().height-40+addH))
      exBg:addChild(typeLb)
      
      local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
      resourceLb:setAnchorPoint(ccp(0.5,0.5))
      resourceLb:setPosition(ccp(300,exBg:getContentSize().height-40+addH))
      exBg:addChild(resourceLb)

      local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
      haveLb:setAnchorPoint(ccp(0.5,0.5))
      haveLb:setPosition(ccp(450,exBg:getContentSize().height-40+addH))
      exBg:addChild(haveLb)
      
      local item = acMeteoriteLandingVoApi:getCostItem(idx+1)
      local costItem={{},{}}
      if item[1].type == "r" then
          costItem[2]=item[1]
          costItem[1]=item[2]
      else
          costItem[2]=item[2]
          costItem[1]=item[1]
      end
      local addy=60
      local tb={
            {titleStr=costItem[1].name,spName=costItem[1].pic,needStr=FormatNumber(costItem[1].num),haveStr=FormatNumber(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(costItem[1].key)))),num1=costItem[1].num,num2=tonumber(bagVoApi:getItemNumId(tonumber(RemoveFirstChar(costItem[1].key))))},
            {titleStr=costItem[2].name,spName=costItem[2].pic,needStr=FormatNumber(costItem[2].num),haveStr=FormatNumber(alienTechVoApi:getAlienResByType(costItem[2].key)),num1=costItem[2].num,num2=tonumber(alienTechVoApi:getAlienResByType(costItem[2].key))},
            }
        local countTb = {}
        for k,v in pairs(tb) do
            local r1Lb=GetTTFLabelWrap(v.titleStr,20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            r1Lb:setAnchorPoint(ccp(0.5,0.5))
            r1Lb:setPosition(ccp(150,exBg:getContentSize().height-100+addH-(k-1)*addy))
            exBg:addChild(r1Lb)

            local r1Sp=CCSprite:createWithSpriteFrameName(v.spName)
            r1Sp:setAnchorPoint(ccp(0.5,0.5))
            r1Sp:setPosition(ccp(40,exBg:getContentSize().height-100+addH-(k-1)*60))
            exBg:addChild(r1Sp)
            r1Sp:setScale(0.5)

            local needR1Lb=GetTTFLabel(v.needStr,20)
            needR1Lb:setAnchorPoint(ccp(0.5,0.5))
            needR1Lb:setPosition(ccp(300,exBg:getContentSize().height-100+addH-(k-1)*addy))
            exBg:addChild(needR1Lb)

            local haveR1Lb=GetTTFLabel(v.haveStr,20)
            haveR1Lb:setAnchorPoint(ccp(0.5,0.5))
            haveR1Lb:setPosition(ccp(450,exBg:getContentSize().height-100+addH-(k-1)*addy))
            exBg:addChild(haveR1Lb)

            local p1Sp;
            if v.num1<=v.num2 then
               p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
            else
               p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
            end
            p1Sp:setAnchorPoint(ccp(0.5,0.5))
            
            p1Sp:setPosition(ccp(400,exBg:getContentSize().height-100+addH-(k-1)*addy))

            exBg:addChild(p1Sp)
            countTb[k]=needR1Lb
        end

        local m_numLb=GetTTFLabel(" ",30)
        m_numLb:setPosition(70,-30);
        exBg:addChild(m_numLb,2)

        -- 能转换的最大数量
        local maxNum = math.floor(acMeteoriteLandingVoApi:getMaxNum(costItem))
        local function sliderTouch(handler,object)
            local count = math.floor(object:getValue())
            m_numLb:setString(count)
            for k,v in pairs(tb) do
                local numStr=FormatNumber(costItem[k].num*count)
                if count==0 then
                    numStr=FormatNumber(costItem[k].num*1)
                end
                local needLb=countTb[k]
                if needLb then
                    needLb:setString(numStr)
                end
            end
        end
        local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
        local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
        local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
        local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
        slider:setTouchPriority(-(self.layerNum-1)*20-2);
        slider:setIsSallow(true);
        
        if maxNum==0 then
            slider:setMinimumValue(0.0)
            slider:setMaximumValue(0.0)
            slider:setValue(0)
        elseif maxNum==1 then
            slider:setMinimumValue(1)
            slider:setMaximumValue(1)
            slider:setValue(1)
        else
          slider:setMaximumValue(maxNum)
          slider:setMinimumValue(1)
          slider:setValue(maxNum)
        end
        
        slider:setPosition(ccp(355,-30))
        slider:setTag(99)
        exBg:addChild(slider,2)
        m_numLb:setString(math.floor(slider:getValue()))

        local function touchAdd()
            slider:setValue(slider:getValue()+1);
        end
        
        local function touchMinus()
            if slider:getValue()-1>0 then
                slider:setValue(slider:getValue()-1);
            end
        
        end
        
        local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
        addSp:setPosition(ccp(549,-30))
        exBg:addChild(addSp,2)
        addSp:setTouchPriority(-(self.layerNum-1)*20-2);
        
        local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
        minusSp:setPosition(ccp(157,-30))
        exBg:addChild(minusSp,2)
        minusSp:setTouchPriority(-(self.layerNum-1)*20-2)

        local function touch1()
           if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local numAlien = math.floor(slider:getValue())
                if numAlien<=0 then
                  return
                end

                local function callback(fn,data)
                  local ret,sData=base:checkServerData(data)
                  if ret==true then
                    -- 设置数据
                    local num = alienTechVoApi:getAlienResByType(costItem[2].key)
                    alienTechVoApi:setAlienResByType(costItem[2].key,num-numAlien*costItem[2].num)

                    local getItem = acMeteoriteLandingVoApi:getGetItem(idx+1)
                    num = alienTechVoApi:getAlienResByType(getItem[1].key)
                    alienTechVoApi:setAlienResByType(getItem[1].key,num+numAlien*getItem[1].num)

                    -- bagVoApi:useItemNumId(tonumber(RemoveFirstChar(costItem[1].key)),numAlien*FormatNumber(costItem[1].num))

                    local showStr=getlocal("congratulationsGet",{getItem[1].name .. "*" .. numAlien*getItem[1].num})
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),showStr,30)


                    local recordPoint=self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)
                  end
                end
                socketHelper:acMeteoriteLandingGetResource(idx+1,numAlien,callback)
            end
           
        end
      local menuItem1 = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touch1,11,getlocal("startProduce"),28)
      local menu1 = CCMenu:createWithItem(menuItem1);
      menu1:setPosition(ccp(460,-93));
      menu1:setTouchPriority(-(self.layerNum-1)*20-2);
      exBg:addChild(menu1,3)

      local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
      bgSp:setAnchorPoint(ccp(0.5,0.5));
      bgSp:setPosition(exBg:getContentSize().width/2,-30);
      exBg:addChild(bgSp,1);

      if maxNum==0 then
        menuItem1:setEnabled(false)
      end

  end
end


function acMeteoriteLandingTab2:dispose( )
  eventDispatcher:removeEventListener("MeteoriteLanding.Change",self.tvChangeListener)
	self.bgLayer=nil
	self.layerNum =nil
  self.cell1=nil 
  self.cell2=nil
	self=nil

end