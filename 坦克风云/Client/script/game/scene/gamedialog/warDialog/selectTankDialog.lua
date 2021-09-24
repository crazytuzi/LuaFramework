selectTankDialog={}

function selectTankDialog:new()
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

      selectedTabIndex=1,  --当前选中的tab
      oldSelectedTabIndex=1,--上一次选中的tab
      allTabs={},
      keyTable1={},
      keyTable2={},
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--type:类型 1是防守板子的选择面板 2进攻 3关卡 layerNum:层数 callBack:确定按钮回调
--tankData tank信息
--troopsLimit 自定义的统率限制
-- isGangtieronglu 钢铁熔炉活动无坦克显示  尚无可熔炼坦克
-- isBanzhanshilian 是否是班长试炼
-- isCRaids 关卡扫荡
function selectTankDialog:showSelectTankDialog(type,layerNum,callBack,tankData,troopsLimit,isGangtieronglu,isBanzhanshilian,isCRaids)
    base:setWait()
    self.hei=0
    self.soldiersSelectedLbNum =GetTTFLabel(" ",26);
    self.isGangtieronglu=isGangtieronglu
    self.isBanzhanshilian=isBanzhanshilian
    self.isCRaids=isCRaids
    
    local capInSet = CCRect(15, 15, 1, 1);
    local function touchClick(hd,fn,idx)
        
    end
   self.selectedSp =LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBgSelected.png",capInSet,touchClick)
   self.selectedSp:setContentSize(CCSizeMake(100,36))
   if self.isCRaids==true then
      self.isNotTroopsLimit=true
   else
      self.isNotTroopsLimit=false
   end
  
    if self.isNotTroopsLimit==true then
      self.totalTroops=0
    else
      if troopsLimit and tonumber(troopsLimit) and tonumber(troopsLimit)>0 then
          self.totalTroops=tonumber(troopsLimit)
      else
          self.totalTroops=playerVoApi:getTotalTroops(type)
      end
    end
    if tankData and tankData[1] and tankData[2] then
        self.keyTable,self.tankTable=tankData[1],tankData[2]
    else
        if type==1 then
            self.keyTable,self.tankTable=tankVoApi:getAllTanksInByType(3)
        elseif type==2 then
            self.keyTable,self.tankTable=tankVoApi:getAllTanksInByType(1)
        
        elseif type==3 then
            self.keyTable,self.tankTable=tankVoApi:getAllTanksInByType(2)
        elseif type==11 then
            self.keyTable,self.tankTable=tankVoApi:getAllTanksInByType(11)
        else
            self.keyTable,self.tankTable=tankVoApi:getAllTanksInByType(type)
        end
    end

    self.mylayerNum=layerNum
    local td=selectTankDialog:new()
    local dia=td:init(layerNum,callBack,type);
    sceneGame:addChild(dia,layerNum)
    base:cancleWait()
end


function selectTankDialog:init(layerNum,callBack,type)
    self.dialogLayer=CCLayer:create();

    for i=1,2 do
        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        grayBgSp:setAnchorPoint(ccp(0.5,0.5))
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
        grayBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
        self.dialogLayer:addChild(grayBgSp)  
    end


    table.insert(G_SmallDialogDialogTb,self)
    local tHeight=900;

    self.keyTable1={}
    self.keyTable2={}
    local num1=0
    local num2=0
    for i=1,#self.keyTable do
       if self.keyTable[i].key==G_pickedList(self.keyTable[i].key) then
        num1=num1+1
        self.keyTable1[num1]=self.keyTable[i]
      else
        num2=num2+1
        self.keyTable2[num2]=self.keyTable[i]
      end
    end

    -- for k,v in pairs(self.keyTable) do
    --   if v.key==G_pickedList(v.key) then
    --     self.keyTable1[k]=v
    --   else
    --     self.keyTable2[k]=v
    --   end
    -- end

    -- for k,v in pairs(self.tankTable) do
    --   print(k,v)
    -- end

    -- for k,v in pairs(self.keyTable1) do
    --   print(k,v)
    -- end
    -- print("++++++++++++")
    -- for k,v in pairs(self.keyTable2) do
    --   print(k,v)
    -- end

    self.keyTable=self.keyTable1


     if self.keyTable~=nil then
      local count=SizeOfTable(self.keyTable)
      local countR=0
      if count>6 then
        countR=count-6
      end
      self.hei=math.ceil(countR/3)
    end
    
    
--背景    
    local function touch()
    
    end
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local rect=CCRect(0, 0, 400, 350)
    local capInSet=CCRect(168, 86, 10, 10)
    self.bgLayer=G_getNewDialogBg(CCSizeMake(600,tHeight),getlocal("choiceFleet"),30,touch,layerNum,true,close)
    --LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",capInSet,touch)
    -- self.bgLayer:setContentSize(CCSizeMake(600,tHeight));
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
    -- local titleLb = GetTTFLabel(getlocal("choiceFleet"),36);
    -- titleLb:setAnchorPoint(ccp(0.5,0.5));
    -- titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-titleLb:getContentSize().height/2-8));
    -- self.bgLayer:addChild(titleLb,2);
--上面的取消按钮    
    
    
    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    --     closeBtnItem:setPosition(0, 0)
    --     closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    -- closeBtnItem:registerScriptTapHandler(close)

    -- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    -- self.closeBtn:setPosition(ccp(self.bgLayer:getContentSize().width-closeBtnItem:getContentSize().width-5,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height-5))
    -- self.bgLayer:addChild(self.closeBtn)
        
--确定取消按钮    
    --取消
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         self:close()
    end
    local cancleItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn.png",cancleHandler,2,getlocal("cancel"),25)
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
        local valueNum=0
        if self.isCRaids==true then
            if self.soldiersSelectedLbNum then
                valueNum=tonumber(self.soldiersSelectedLbNum:getString()) or 0
            end
        elseif self.slider then
            valueNum = tonumber(string.format("%.2f", self.slider:getValue()))
        end
    		local num=math.ceil(valueNum)
        callBack(id,num)
        self:close()
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(self.bgLayer:getContentSize().width-150,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-4);
    self.bgLayer:addChild(sureMenu)
--选择条
    if self.isCRaids==true then
    else
        local m_numLb=GetTTFLabel(" ",30)
        m_numLb:setPosition(60,150);
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
        local spBg =CCSprite:createWithSpriteFrameName("proBar_n2.png");
        local spPr =CCSprite:createWithSpriteFrameName("proBar_n1.png");
        local spPr1 =CCSprite:createWithSpriteFrameName("grayBarBtn.png");--ProduceTankIconSlide
        self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
        self.slider:setTouchPriority(-(layerNum-1)*20-5);
        self.slider:setIsSallow(true);
        
        if #self.keyTable>0 then
            self.slider:setMinimumValue(1.0);
        else
            self.slider:setMinimumValue(1);
            self.slider:setMaximumValue(0);
        end
        
              
        self.slider:setValue(1);
        self.slider:setPosition(ccp(340,150))
        self.slider:setTag(99)
        self.bgLayer:addChild(self.slider,2)

        m_numLb:setString(math.ceil(self.slider:getValue()))
        self.m_numLb=m_numLb
        -- local bgSp = CCSprite:createWithSpriteFrameName("proBar_n2.png");
        -- bgSp:setScaleX(85/bgSp:getContentSize().width)
        -- bgSp:setAnchorPoint(ccp(0.5,0.5));
        -- bgSp:setPosition(60,150);
        -- self.bgLayer:addChild(bgSp,1);

        local function tthandler()
    
        end

        local function callBackXHandler(fn,eB,str,type,tag)
            self.lastNumValue = math.ceil(self.slider:getValue())
            m_numLb:setVisible(false)
            if type==1 then  --检测文本内容变化
                if str=="" then
                    self.m_numLb:setString(math.ceil(self.slider:getValue()))
                    self.slider:setValue(self.lastNumValue)
                    do return end
                end
                local strNum=tonumber(str)
                if strNum==nil then
                    -- eB:setText(self.lastNumValue)
                else
                    if strNum<=1 then
                        self.lastNumValue="1"
                        eB:setText("1")
                    elseif strNum>=1 and strNum<=self.slider:getMaximumValue() then
                        self.lastNumValue=strNum
                        eB:setText(strNum)
                    elseif strNum>self.slider:getMaximumValue() then
                        eB:setText(self.slider:getMaximumValue())
                        self.lastNumValue=tostring(self.slider:getMaximumValue())
                    else
                        eB:setText(str)
                    end
                end
                self.m_numLb:setString(self.lastNumValue)
                self.slider:setValue(self.lastNumValue)
                self.m_numLb=m_numLb
            elseif type==2 then --检测文本输入结束
                eB:setVisible(false)
                m_numLb:setVisible(true)
            end
        end
        local pos = ccp(60,150)
        local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("proBar_n3.png", CCRect(3, 3, 1, 1),tthandler)
        local editXBox = CCEditBox:createForLua(CCSize(85,40),xBox,nil,nil,callBackXHandler)
        editXBox:setAnchorPoint(ccp(0.5,0.5))
        editXBox:setPosition(pos);
        if G_isIOS()==true then
            editXBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
        else
            editXBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
        end
        xBox:setVisible(false)
        editXBox:setVisible(false)
        self.bgLayer:addChild(editXBox,1)

        local function showEditBox()
            editXBox:setText(math.ceil(self.slider:getValue()))
            editXBox:setVisible(true)
        end
        local numEditBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("proBar_n3.png", CCRect(3, 3, 1, 1),showEditBox)
        numEditBoxBg:setAnchorPoint(ccp(0.5,0.5))
        numEditBoxBg:setPosition(pos)
        numEditBoxBg:setContentSize(CCSize(85,33))
        numEditBoxBg:setTouchPriority(-(layerNum-1)*20-5)
        -- numEditBoxBg:setOpacity(0)
        self.bgLayer:addChild(numEditBoxBg)
        
        
        local function touchAdd()
            self.slider:setValue(self.slider:getValue()+1);
        end
        
        local function touchMinus()
            if self.slider:getValue()-1>0 then
                self.slider:setValue(self.slider:getValue()-1);
            end
        
        end
        
        local addSp=LuaCCSprite:createWithSpriteFrameName("greenPlus.png",touchAdd)
        addSp:setPosition(ccp(560,150))
        self.bgLayer:addChild(addSp,1)
        addSp:setTouchPriority(-(layerNum-1)*20-4);
        
        
        local minusSp=LuaCCSprite:createWithSpriteFrameName("greenMinus.png",touchMinus)
        minusSp:setPosition(ccp(125,150))
        self.bgLayer:addChild(minusSp,1)
        minusSp:setTouchPriority(-(layerNum-1)*20-4);
    end
--拥有坦克的 tableView
    self:initTableView()

    --  普通坦克和精英坦克的页签
    local function touchItem(idx)
      if idx==3 then
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {}
        local tabColor = {}
        tabStr = {"\n",getlocal("selectTank_info_tip1"),"\n",getlocal("selectTank_info_tip2"),"\n",getlocal("selectTank_info_tip3"),"\n",getlocal("selectTank_info_tip4"),"\n"}
        tabColor = {nil, nil, nil, nil,nil,nil,nil,G_ColorRed}

        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(layerNum+1,true,true,nil,titleStr,tabStr,tabColor,25)
      else
        self.oldSelectedTabIndex=self.selectedTabIndex
        self:tabClickColor(idx)
        return self:tabClick(idx)
      end
       
    end
    local commonItem = CCMenuItemImage:create("page_dark.png", "page_light.png","page_light.png")
    commonItem:setTag(1)
    commonItem:registerScriptTapHandler(touchItem)
    commonItem:setEnabled(false)
    self.allTabs[1]=commonItem
    local commonMenu=CCMenu:createWithItem(commonItem)
    commonMenu:setPosition(ccp(30+commonItem:getContentSize().width/2-10,self.bgLayer:getContentSize().height-110))
    commonMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(commonMenu,2)

    local sp1=CCSprite:createWithSpriteFrameName("picked_icon2.png")
    commonItem:addChild(sp1,2)
    sp1:setPosition(commonItem:getContentSize().width/2,commonItem:getContentSize().height/2)

    local pickedItem=CCMenuItemImage:create("page_dark.png", "page_light.png","page_light.png")
    pickedItem:setTag(2)
    pickedItem:registerScriptTapHandler(touchItem)
    self.allTabs[2]=pickedItem
    local pickedMenu=CCMenu:createWithItem(pickedItem)
    pickedMenu:setPosition(ccp(30+pickedItem:getContentSize().width/2*3-5,self.bgLayer:getContentSize().height-110))
    pickedMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(pickedMenu,2)

    local sp2=CCSprite:createWithSpriteFrameName("picked_icon2.png")
    pickedItem:addChild(sp2,2)
    sp2:setPosition(pickedItem:getContentSize().width/2,pickedItem:getContentSize().height/2)

    local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
    sp2:addChild(pickedIcon)
    pickedIcon:setPosition(sp2:getContentSize().width-10,sp2:getContentSize().height/2)
    pickedIcon:setScale(0.9)

    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchItem,1,nil,0)
    menuItemDesc:setTag(3)
    menuItemDesc:registerScriptTapHandler(touchItem)
    -- menuItemDesc:setScale(0.9)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(layerNum-1)*20-4)
    menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-40, self.bgLayer:getContentSize().height-110))
    self.bgLayer:addChild(menuDesc,2)

    local upM_Line = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
    upM_Line:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,upM_Line:getContentSize().height))
    upM_Line:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-menuItemDesc:getContentSize().height*0.5-112))
    upM_Line:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(upM_Line,2)

    if base.etank==0 or self.isCRaids==true then
      pickedItem:setVisible(false)
      pickedItem:setEnabled(false)
      menuItemDesc:setVisible(false)
      menuItemDesc:setEnabled(false)
    end
    if type and type==32 then
      menuItemDesc:setVisible(false)
      menuItemDesc:setEnabled(false)
    end

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
function selectTankDialog:initTableView()
    -- local capInSet = CCRect(20, 20, 10, 10);
    -- local tvBackSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,function ()end)
    -- tvBackSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-135-200))
    -- tvBackSprie:setAnchorPoint(ccp(0,0));
    -- tvBackSprie:setPosition(ccp(30,190))
    -- self.bgLayer:addChild(tvBackSprie)
    local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(5,205))
    -- mLine:setScaleX((self.dialogWidth-40)/mLine:getContentSize().width)
    mLine:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,mLine:getContentSize().height))
    mLine:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(mLine)

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
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-135-210),nil)
    self.tv:setTableViewTouchPriority((-(self.mylayerNum-1)*20-3))
    self.tv:setPosition(ccp(30,195))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function selectTankDialog:eventHandler(handler,fn,idx,cel)
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
       backSprie:setTouchPriority(-42)
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
            if self.totalTroops>=self.tankTable[tag][1] or self.isNotTroopsLimit==true then
                self.soldiersSelectedLbNum:setString(self.tankTable[tag][1])
                if self.slider then
                    self.slider:setMaximumValue(self.tankTable[tag][1]);
                    self.slider:setValue(self.tankTable[tag][1]);
                end
                soldiersLbNum:setString("0")
            else
                
                local soldierCount=self.tankTable[tag][1]-self.totalTroops
                self.soldiersSelectedLbNum:setString(self.totalTroops)
                if self.slider then
                    self.slider:setMaximumValue(self.totalTroops);
                    self.slider:setValue(self.totalTroops);
                end
                soldiersLbNum:setString(soldierCount)
            end
            


       end

       if self.tankTable~=nil then
           for k,v in pairs(self.keyTable) do
               local sprite = tankVoApi:getTankIconSp(v.key,nil,touch)--LuaCCSprite:createWithSpriteFrameName(tankCfg[v.key].icon,touch);
               sprite:setAnchorPoint(ccp(0.5,0.5));
               sprite:setTag(v.key)
               sprite:setIsSallow(true)
               sprite:setTouchPriority((-(self.mylayerNum-1)*20-2))
               local wid = sprite:getContentSize().width
               local dis = sprite:getContentSize().height+50            
               sprite:setPosition(24+wid/2+wid*numX+20*numX,self.hei*280+self.cellHeight-dis/2-numY*dis-self.subHei2*numY)
               sprite:setScale(1)
               cell:addChild(sprite,2)

               if v.key~=G_pickedList(v.key) then
                local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                sprite:addChild(pickedIcon)
                pickedIcon:setPosition(sprite:getContentSize().width*0.7,sprite:getContentSize().height*0.5-20)
                -- pickedIcon:setScale(sprite:getContentSize().width/100)
               end
               
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
               numSprie:setTouchPriority(-42)
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
                  if self.totalTroops>=self.tankTable[v.key][1] or self.isNotTroopsLimit==true then
                    self.soldiersSelectedLbNum:setString(self.tankTable[v.key][1])
                    soldiersLbNum:setString("0")
                    if self.slider then
                        self.slider:setMaximumValue(self.tankTable[v.key][1]);
                        self.slider:setValue(self.tankTable[v.key][1]);
                    end
                  else
                    
                    local soldierCount=self.tankTable[v.key][1]-self.totalTroops
                    self.soldiersSelectedLbNum:setString(self.totalTroops)
                    soldiersLbNum:setString(soldierCount)
                    if self.slider then
                        self.slider:setMaximumValue(self.totalTroops);
                        self.slider:setValue(self.totalTroops);
                    end
                  end
        
               end
               


               numX=numX+1
               if numX>2 then
                  numX=0
                  numY=numY+1
               end
               
               local function showInfoHandler(hd,fn,idx)
                  -- if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if self.tv:getIsScrolled()==true then
                        do
                            return
                        end
                    end
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local id = G_pickedList(v.key)
                    tankInfoDialog:create(nil,tonumber(id),self.mylayerNum+1)
                  -- end
               end
               local tipItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfoHandler,nil,nil,nil)
               local spScale=0.7
               tipItem:setScale(spScale)
               local tipMenu = CCMenu:createWithItem(tipItem)
               -- local px,py=24+wid/2+wid*numX+20*numX,self.hei*280+self.cellHeight-dis/2-20-numY*dis-80*numY
               tipMenu:setPosition(ccp(sprite:getContentSize().width-tipItem:getContentSize().width/2*spScale-10,sprite:getContentSize().height-tipItem:getContentSize().width/2*spScale-10))
               -- tipMenu:setPosition(ccp(px,py))
               tipMenu:setTouchPriority(-(self.mylayerNum-1)*20-3)
               sprite:addChild(tipMenu,5)
           end
       end
       num=0
       if self.isGangtieronglu then
        if self.keyTable and SizeOfTable(self.keyTable)==0 then
          local noTankLb = GetTTFLabelWrap(getlocal("activity_gangtieronglu_tip5"),30,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
          backSprie:addChild(noTankLb)
          noTankLb:setPosition(backSprie:getContentSize().width/2, backSprie:getContentSize().height/2)
          noTankLb:setColor(G_ColorYellowPro)
        end
      elseif self.isBanzhanshilian then

      else
          if self.keyTable and SizeOfTable(self.keyTable)==0 then
              local noTankStr
              if self.selectedTabIndex==1 then
                noTankStr=getlocal("noCommonTank")
              else
                noTankStr=getlocal("noEliteTank")
              end
              local noTankLb = GetTTFLabelWrap(noTankStr,25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
              backSprie:addChild(noTankLb)
              noTankLb:setPosition(backSprie:getContentSize().width/2, backSprie:getContentSize().height/2+50)
              -- noTankLb:setColor(G_ColorYellowPro)

                          -- 坦克工厂
              local function callback1()
                PlayEffect(audioCfg.mouseClick)
                self:close()
                activityAndNoteDialog:closeAllDialog()
                local bid=11;
                local tankSlot1=tankSlotVoApi:getSoltByBid(11)
                local tankSlot2=tankSlotVoApi:getSoltByBid(12)
                if SizeOfTable(tankSlot1)==0 and SizeOfTable(tankSlot2)==0 then
                bid=11;
                elseif SizeOfTable(tankSlot1)==0 and SizeOfTable(tankSlot2)>0 then
                bid=11;
                elseif SizeOfTable(tankSlot1)>0 and SizeOfTable(tankSlot2)==0 then
                bid=12;
                elseif SizeOfTable(tankSlot1)>0 and SizeOfTable(tankSlot2)>0 then
                bid=11;
                end

                local buildingVo=buildingVoApi:getBuildiingVoByBId(bid)
                if buildingVo.level==0 then
                bid=11;
                buildingVo=nil
                buildingVo=buildingVoApi:getBuildiingVoByBId(bid)
                end
                    require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
                local td=tankFactoryDialog:new(bid,3)
                local bName=getlocal(buildingCfg[6].buildName)

                local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
                local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildingVo.level..")",true,3)
                td:tabClick(1)
                sceneGame:addChild(dialog,3)
              end


              -- 关卡
              local function callback2()
                PlayEffect(audioCfg.mouseClick)
                self:close()
                activityAndNoteDialog:closeAllDialog()
                storyScene:setShow()
              end

              local function tiaozhuan()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    if self.selectedTabIndex==1 then
                      callback1()
                    else
                      callback2()
                    end
                end
              end
              local tiaozhuanItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",tiaozhuan,nil,getlocal("activity_heartOfIron_goto"),25)
              tiaozhuanItem:registerScriptTapHandler(tiaozhuan)
              local tiaozhuanMenu=CCMenu:createWithItem(tiaozhuanItem)
              tiaozhuanMenu:setTouchPriority(-(self.mylayerNum-1)*20-2)
              tiaozhuanMenu:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height/2-50))
              backSprie:addChild(tiaozhuanMenu,2)
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

function selectTankDialog:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
end

function selectTankDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx           
         else            
            v:setEnabled(true)
         end
    end
    if idx==1 then
      self.keyTable=self.keyTable1
    else
      self.keyTable=self.keyTable2
    end

    self.soldiersSelectedLbNum =GetTTFLabel(" ",26);

    local capInSet = CCRect(15, 15, 1, 1);
    local function touchClick(hd,fn,idx)

    end
    self.selectedSp =LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBgSelected.png",capInSet,touchClick)
    self.selectedSp:setContentSize(CCSizeMake(100,36))

     if self.keyTable~=nil then
      local count=SizeOfTable(self.keyTable)
      local countR=0
      if count>6 then
        countR=count-6
      end
      self.hei=math.ceil(countR/3)

      if G_getCurChoseLanguage() =="cn" and self.subHei then
        self.cellHeight = self.oldCellHeight - self.subHei*self.hei
      end
    end
    if self.slider then
        if #self.keyTable>0 then
            self.slider:setMinimumValue(1.0);
        else
            self.slider:setMinimumValue(1);
            self.slider:setMaximumValue(0);
        end
        self.slider:setValue(1);
        self.m_numLb:setString("0")
    end
    self.myTouchSp=nil
    self.tv:reloadData()

end

--顶部和底部的遮挡层
function selectTankDialog:resetForbidLayer()
   local tvX,tvY=self.tv:getPosition()
   local ridHeight = tvY+(G_VisibleSize.height-self.bgLayer:getContentSize().height)/2
   self.bottomforbidSp:setContentSize(CCSizeMake(640,ridHeight))
end


function selectTankDialog:close()
    
    self.dialogLayer:removeFromParentAndCleanup(true)
    self.isGangtieronglu=nil
    self.selectedTabIndex=nil
    self.oldSelectedTabIndex=nil
    self.allTabs=nil
    self.isBanzhanshilian=nil
    self.isCRaids=false
    self.isNotTroopsLimit=false
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
end



