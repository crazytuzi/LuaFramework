platWarSelectTankDialog={}

function platWarSelectTankDialog:new()
    local nc={
      bgLayer=nil,             --背景sprite
      dialogLayer,         --对话框层
      closeBtn,
      tv,
      mylayerNum,
      bgSize,
      isTouch,
      isUseAmi,
      isMoved,
      keyTable,
      tankTable,
      cellHeight,
      slider,
      totalTroops,
      hei,
      myCell,
      myTouchSp,
      selectedSp,
      topforbidSp, --顶端遮挡层
      bottomforbidSp, --底部遮挡层

    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--type:类型 1是防守板子的选择面板 2进攻 3关卡 layerNum:层数 callBack:确定按钮回调
--tankData tank信息
--troopsLimit 自定义的每种tank数量限制
--index 第几档
function platWarSelectTankDialog:showSelectTankDialog(type,layerNum,callBack,tankData,troopsLimit,index)
    if tankData and tankData[1] and tankData[2] and troopsLimit and index then
        self.keyTable,self.tankTable=tankData[1],tankData[2]
        self.totalTroops=troopsLimit
        self.index=index
    else
        do return end
    end
    
    base:setWait()
    self.hei=0
    self.soldiersSelectedLbNum=GetTTFLabel(" ",26);
    
    local capInSet = CCRect(15, 15, 1, 1);
    local function touchClick(hd,fn,idx)
        
    end
    self.selectedSp =LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBgSelected.png",capInSet,touchClick)
    self.selectedSp:setContentSize(CCSizeMake(80,36))

    if self.tankTable~=nil then
      local count=SizeOfTable(self.tankTable)
      local countR=0
      if count>6 then
        countR=count-6
      end
      self.hei=math.ceil(countR/3)
      if G_getCurChoseLanguage() =="cn" and self.subHei then
        self.cellHeight = self.oldCellHeight - self.subHei*self.hei
      end
    end
    self.mylayerNum=layerNum
    local td=platWarSelectTankDialog:new()
    local dia=td:init(layerNum,callBack);
    sceneGame:addChild(dia,layerNum)
    base:cancleWait()
    
    

end


function platWarSelectTankDialog:init(layerNum,callBack)
    self.dialogLayer=CCLayer:create();
    local tHeight=900;
    
    for i=1,2 do
        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        grayBgSp:setAnchorPoint(ccp(0.5,0.5))
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
        grayBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
        self.dialogLayer:addChild(grayBgSp)  
    end

--背景    
    local function touch()
    
    end

    local rect=CCRect(0, 0, 400, 350)
    local capInSet=CCRect(168, 86, 10, 10)
    self.bgLayer=LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",capInSet,touch)
    self.bgLayer:setContentSize(CCSizeMake(600,tHeight));
    self.bgLayer:setTouchPriority((-(layerNum-1)*20-1))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:addChild(self.bgLayer,1)
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",capInSet,touch);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=G_VisibleSize
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(touchDialogBg,1);

    
--title    
    local titleLb = GetTTFLabel(getlocal("choiceFleet"),36);
    titleLb:setAnchorPoint(ccp(0.5,0.5));
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-titleLb:getContentSize().height/2-8));
    self.bgLayer:addChild(titleLb,2);
--上面的取消按钮    
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    closeBtnItem:registerScriptTapHandler(close)

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgLayer:getContentSize().width-closeBtnItem:getContentSize().width-5,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height-5))
    self.bgLayer:addChild(self.closeBtn)
        
--确定取消按钮    
    --取消
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         self:close()
    end
    local cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall.png",cancleHandler,2,getlocal("cancel"),25)
    local cancleMenu=CCMenu:createWithItem(cancleItem);
    cancleMenu:setPosition(ccp(150,60))
    cancleMenu:setTouchPriority(-(layerNum-1)*20-4);
    self.bgLayer:addChild(cancleMenu)
    --确定
    local function sureHandler()
        PlayEffect(audioCfg.mouseClick)    
        if self.myTouchSp==nil then
            self:close()
            do
                return
            end
        end
        local id=self.myTouchSp:getTag()
    		local valueNum = tonumber(string.format("%.2f", self.slider:getValue()))
    		local num=math.ceil(valueNum)

        local pid=platWarVoApi:getPosByTankId(self.index,"a"..id)
        local fid=self.index
        local function donateCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data then
                    platWarVoApi:updateInfo(sData.data)
                    if sData.data.donateinfo then
                        local params={donateinfo=sData.data.donateinfo}
                        chatVoApi:sendUpdateMessage(24,params)
                    end
                end
                local isMaxFull=true
                for k,v in pairs(platWarCfg.troopsDonate) do
                    if v and v.donateNum then
                        local dNum=platWarVoApi:getDonateTroopsNumByIndex(k)
                        if dNum and dNum<v.donateNum then
                            isMaxFull=false
                        end
                    end
                end
                if isMaxFull==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_donate_troops_max_full"),30)
                else
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_donate_success"),30)
                end
                if callBack then
                    callBack()
                end
                self:close()
            elseif sData and sData.ret==-23109 then
                platWarVoApi:setTroopsFlag(-1)
                local function getInfoCallback()
                    if callBack then
                        callBack()
                    end
                end
                platWarVoApi:getInfo(getInfoCallback)
            end
        end
        socketHelper:platwarDonate(2,pid,fid,num,donateCallback)
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(self.bgLayer:getContentSize().width-150,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-4);
    self.bgLayer:addChild(sureMenu)
--选择条
    local m_numLb=GetTTFLabel(" ",30)
    m_numLb:setPosition(80,150);
    self.bgLayer:addChild(m_numLb,2);
    

    local function sliderTouch(handler,object)
		local valueNum = tonumber(string.format("%.2f", object:getValue()))
        local count = math.ceil(valueNum)
		--local count = math.ceil(object:getValue())
        if count>0 then
            m_numLb:setString(count)
            self.soldiersSelectedLbNum:setString(count)
        end
        
        
            
        if self.myTouchSp~=nil then
            local lb=self.myTouchSp:getChildByTag(2)
            lb=tolua.cast(lb,"CCLabelTTF")
            local num=self.tankTable[self.myTouchSp:getTag()][1]-count
            lb:setString(num)

        end

    end
    local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
    local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
    self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    self.slider:setTouchPriority(-(layerNum-1)*20-5);
    self.slider:setIsSallow(true);
    
    if #self.tankTable>0 then
        self.slider:setMinimumValue(1.0);
    else
        self.slider:setMinimumValue(1);
        self.slider:setMaximumValue(0);
    end
    
    
    
    self.slider:setValue(1);
    self.slider:setPosition(ccp(365,150))
    self.slider:setTag(99)
    self.bgLayer:addChild(self.slider,2)
    m_numLb:setString(math.ceil(self.slider:getValue()))

    local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
    bgSp:setAnchorPoint(ccp(0,0.5));
    bgSp:setPosition(15,150);
    self.bgLayer:addChild(bgSp,1);
    
    
    local function touchAdd()
        self.slider:setValue(self.slider:getValue()+1);
    end
    
    local function touchMinus()
        if self.slider:getValue()-1>0 then
            self.slider:setValue(self.slider:getValue()-1);
        end
    
    end
    
    local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
    addSp:setPosition(ccp(560,150))
    self.bgLayer:addChild(addSp,1)
    addSp:setTouchPriority(-(layerNum-1)*20-4);
    
    
    local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
    minusSp:setPosition(ccp(168,150))
    self.bgLayer:addChild(minusSp,1)
    minusSp:setTouchPriority(-(layerNum-1)*20-4);
--拥有坦克的 tableView
    self:initTableView()




     --以下代码处理上下遮挡层
       local function forbidClick()
       
       end
       local rect2 = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
       self.topforbidSp:setTouchPriority(-(layerNum-1)*20-3)
       self.topforbidSp:setAnchorPoint(ccp(0,0))
       self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
       self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-3)
       self.bottomforbidSp:setAnchorPoint(ccp(0,0))
       local tvX,tvY=self.tv:getPosition()
       local topY=tvY+self.tv:getViewSize().height+(rect.height-self.bgLayer:getContentSize().height)/2
       local topHeight=rect.height-topY
       self.topforbidSp:setContentSize(CCSize(rect.width,topHeight))
       self.topforbidSp:setPosition(0,topY)
       self.dialogLayer:addChild(self.topforbidSp)

       self.dialogLayer:addChild(self.bottomforbidSp)
       self:resetForbidLayer()
       self.topforbidSp:setVisible(false)
       self.bottomforbidSp:setVisible(false)
       --以上代码处理上下遮挡层

    
    return self.dialogLayer

end

--设置对话框里的tableView
function platWarSelectTankDialog:initTableView()
    local capInSet = CCRect(20, 20, 10, 10);
    local tvBackSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,function ()end)
    tvBackSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-165-170))
    tvBackSprie:setAnchorPoint(ccp(0,0));
    tvBackSprie:setPosition(ccp(30,230))
    self.bgLayer:addChild(tvBackSprie)

    self.cellHeight=self.bgLayer:getContentSize().height-165-85
    self.oldCellHeight = self.cellHeight
    self.subHei = 80
    self.subHei2 = 80
    self.subHei3 = -30
    if G_getCurChoseLanguage() =="cn" then
      self.subHei = 50
      self.subHei2 = 80 - self.subHei
      self.subHei3 = -35
      self.cellHeight = self.oldCellHeight - self.subHei*self.hei
    end

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-165-180),nil)
    self.tv:setTableViewTouchPriority((-(self.mylayerNum-1)*20-3))
    self.tv:setPosition(ccp(30,235))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    -- self.cellHeight=self.bgLayer:getContentSize().height-165-85
    -- local function callBack(...)
    --    return self:eventHandler(...)
    -- end
    -- local hd= LuaEventHandler:createHandler(callBack)
    -- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-165-180),nil)
    -- self.tv:setTableViewTouchPriority((-(self.mylayerNum-1)*20-3))
    -- self.tv:setPosition(ccp(30,240))
    -- self.bgLayer:addChild(self.tv)
    -- self.tv:setMaxDisToBottomOrTop(120)
    

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function platWarSelectTankDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(600,self.hei*280+self.cellHeight)
       return tmpSize
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
 
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end

       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.hei*280+self.cellHeight))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setOpacity(0)
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.mylayerNum-1)*20-2)
       cell:addChild(backSprie,1)
       
       local numX=0
       local numY=0
       local sp=CCSprite:createWithSpriteFrameName("TeamTankSelected.png");
       
       self.soldiersSelectedLbNum:setColor(G_ColorYellow)

       local function touch(object,name,tag)
            if self.tv:getIsScrolled()==true then
                do
                    return
                end
            end
            PlayEffect(audioCfg.mouseClick)
            local touchSp=cell:getChildByTag(tag)
            self.myTouchSp=touchSp
            sp:setPosition(touchSp:getPosition())
            
            for k,v in pairs(self.keyTable) do
                local spriteL=cell:getChildByTag(v.key)
                local lb=spriteL:getChildByTag(2)
                lb=tolua.cast(lb,"CCLabelTTF")
                lb:setString(self.tankTable[v.key][1])
            
            end
            
            local num=self.tankTable[tag][1]
            local soldiersLbNum=touchSp:getChildByTag(2)
            soldiersLbNum=tolua.cast(soldiersLbNum,"CCLabelTTF")
            self.soldiersSelectedLbNum:setPosition(ccp(touchSp:getPositionX(),touchSp:getPositionY()-50));
            
            self.selectedSp:setPosition(ccp(touchSp:getPositionX(),touchSp:getPositionY()-50));
            -- if self.totalTroops>=self.tankTable[tag][1] or isTroopsLimit==false then
            --     self.soldiersSelectedLbNum:setString(self.tankTable[tag][1])
            --     self.slider:setMaximumValue(self.tankTable[tag][1]);
            --     self.slider:setValue(self.tankTable[tag][1]);
            --     soldiersLbNum:setString("0")
            -- else
                
            --     local soldierCount=self.tankTable[tag][1]-self.totalTroops
            --     self.soldiersSelectedLbNum:setString(self.totalTroops)
            --     self.slider:setMaximumValue(self.totalTroops);
            --     self.slider:setValue(self.totalTroops);
            --     soldiersLbNum:setString(soldierCount)
            -- end
            if self.totalTroops and self.totalTroops[tag] and self.totalTroops[tag]<self.tankTable[tag][1] then
                local limitNum=self.totalTroops[tag]
                local soldierCount=self.tankTable[tag][1]-limitNum
                self.soldiersSelectedLbNum:setString(limitNum)
                self.slider:setMaximumValue(limitNum);
                self.slider:setValue(limitNum);
                soldiersLbNum:setString(soldierCount)
            else
                self.soldiersSelectedLbNum:setString(self.tankTable[tag][1])
                self.slider:setMaximumValue(self.tankTable[tag][1]);
                self.slider:setValue(self.tankTable[tag][1]);
                soldiersLbNum:setString("0")
            end

       end

       if self.tankTable~=nil then
           for k,v in pairs(self.keyTable) do
               -- local sprite = LuaCCSprite:createWithSpriteFrameName(tankCfg[v.key].icon,touch);
               local sprite = G_getETankIcon(2,v.key,touch)
               sprite:setAnchorPoint(ccp(0.5,0.5));
               sprite:setTag(v.key)
               sprite:setIsSallow(true)
               sprite:setTouchPriority((-(self.mylayerNum-1)*20-2))
               local wid = sprite:getContentSize().width
               local dis = sprite:getContentSize().height+60            
               sprite:setPosition(24+wid/2+wid*numX+20*numX,self.hei*280+self.cellHeight-dis/2-20-numY*dis-self.subHei2*numY)
               sprite:setScale(1)
               cell:addChild(sprite,2)
               
               local soldiersLbName = GetTTFLabelWrap(getlocal(tankCfg[v.key].name),24,CCSizeMake(24*7,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
               soldiersLbName:setAnchorPoint(ccp(0.5,1));
               soldiersLbName:setPosition(ccp(wid/2,self.subHei3));
               sprite:addChild(soldiersLbName,2);
               
               local capInSet = CCRect(15, 15, 1, 1);
               local function touchClick(hd,fn,idx)
               end

               local numSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",capInSet,touchClick)
               numSprie:setContentSize(CCSizeMake(130,36))
               numSprie:ignoreAnchorPointForPosition(false);
               numSprie:setPosition(ccp(wid/2,-16));
               numSprie:setTag(1000+idx)
               numSprie:setIsSallow(false)
               numSprie:setTouchPriority(-(self.mylayerNum-1)*20-2)
               sprite:addChild(numSprie,1)

               local str =self.tankTable[v.key][1]
               local soldiersLbNum = GetTTFLabel(str,26);
                soldiersLbNum:setAnchorPoint(ccp(0.5,0.5));
                soldiersLbNum:setPosition(ccp(wid/2,-16));
                --soldiersLbNum:setColor(G_ColorYellow)
                sprite:addChild(soldiersLbNum,2);
                soldiersLbNum:setTag(2);
               
               if numX==0 and numY==0 then
                  self.myTouchSp=sprite
                  sp:setPosition(sprite:getPosition())
                  cell:addChild(sp,3)
                  self.soldiersSelectedLbNum:setPosition(ccp(sprite:getPositionX(),sprite:getPositionY()-50));
                  self.selectedSp:setPosition(ccp(sprite:getPositionX(),sprite:getPositionY()-50));
                  cell:addChild(self.soldiersSelectedLbNum,4);
                  cell:addChild(self.selectedSp,3);
                  -- if self.totalTroops>=self.tankTable[v.key][1] or isTroopsLimit==false then
                  --   self.soldiersSelectedLbNum:setString(self.tankTable[v.key][1])
                  --   soldiersLbNum:setString("0")
                  --   self.slider:setMaximumValue(self.tankTable[v.key][1]);
                  --   self.slider:setValue(self.tankTable[v.key][1]);
                  -- else
                    
                  --   local soldierCount=self.tankTable[v.key][1]-self.totalTroops
                  --   self.soldiersSelectedLbNum:setString(self.totalTroops)
                  --   soldiersLbNum:setString(soldierCount)
                  --   self.slider:setMaximumValue(self.totalTroops);
                  --   self.slider:setValue(self.totalTroops);
                  -- end
                  if self.totalTroops and self.totalTroops[v.key] and self.totalTroops[v.key]<self.tankTable[v.key][1] then
                      local limitNum=self.totalTroops[v.key]
                      local soldierCount=self.tankTable[v.key][1]-limitNum
                      self.soldiersSelectedLbNum:setString(limitNum)
                      soldiersLbNum:setString(soldierCount)
                      self.slider:setMaximumValue(limitNum);
                      self.slider:setValue(limitNum);
                  else
                      self.soldiersSelectedLbNum:setString(self.tankTable[v.key][1])
                      soldiersLbNum:setString("0")
                      self.slider:setMaximumValue(self.tankTable[v.key][1]);
                      self.slider:setValue(self.tankTable[v.key][1]);
                  end
        
               end
               
               numX=numX+1
               if numX>2 then
                  numX=0
                  numY=numY+1
               end
               
           end
       end

       self.myCell=cell

       return cell;
       
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--顶部和底部的遮挡层
function platWarSelectTankDialog:resetForbidLayer()
   local tvX,tvY=self.tv:getPosition()
   local ridHeight = tvY+(G_VisibleSize.height-self.bgLayer:getContentSize().height)/2
   self.bottomforbidSp:setContentSize(CCSizeMake(640,ridHeight))
end


function platWarSelectTankDialog:close()

    self.dialogLayer:removeFromParentAndCleanup(true)

end



