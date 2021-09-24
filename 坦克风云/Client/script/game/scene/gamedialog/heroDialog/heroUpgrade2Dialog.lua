
heroUpgrade2Dialog=commonDialog:new()

function heroUpgrade2Dialog:new(heroVo,parent,layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.heroVo=heroVo
    self.parent=parent
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/hero_exp.plist")
   
    return nc
end

--设置或修改每个Tab页签
function heroUpgrade2Dialog:resetTab()
    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end

    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    self:initLayer()

end

function heroUpgrade2Dialog:initLayer()
  self.allAddH=0
  if G_isIphone5() then
    self.allAddH=20
  end
  local heroIcon = heroVoApi:getHeroIcon(self.heroVo.hid,self.heroVo.productOrder)
  heroIcon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180-self.allAddH))
  self.bgLayer:addChild(heroIcon)
  
  local exp,per,haveExp=heroVoApi:getHeroLeftExp(self.heroVo)
  local lbx=250
  local color=heroVoApi:getHeroColor(self.heroVo.productOrder)
  --UI
  local lbTB={
  {str=G_LV()..self.heroVo.level,size=20,pos={110,G_VisibleSizeHeight-350-self.allAddH},aPos={0,0.5},color=G_ColorYellow,tag=101},
  {str=getlocal(heroListCfg[self.heroVo.hid].heroName),size=24,pos={G_VisibleSizeWidth/2,G_VisibleSizeHeight-300-self.allAddH},aPos={0.5,0.5},color=color,bold=true},
  {str="MAX",size=20,pos={G_VisibleSizeWidth-150,G_VisibleSizeHeight-350-self.allAddH},aPos={0,0.5},color=G_ColorRed,tag=103},
  -- {str=getlocal("upgradeExpRequired",{exp}),size=26,pos={G_VisibleSize.width/2,G_VisibleSizeHeight-390},aPos={0.5,0.5},tag=102},

  }
  for k,v in pairs(lbTB) do
    local strLb=GetTTFLabel(v.str,v.size,v.bold)
    if v.aPos then
       strLb:setAnchorPoint(ccp(v.aPos[1],v.aPos[2]))
    end
    if v.color then
       strLb:setColor(v.color)
    end
    strLb:setPosition(ccp(v.pos[1],v.pos[2]))
    self.bgLayer:addChild(strLb)
    if v.tag~=nil then
       strLb:setTag(v.tag)
    end
    if k==3 then
      strLb:setVisible(false)
    end
  end

  AddProgramTimer(self.bgLayer,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-350-self.allAddH),10,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",11,0.6)
  self.timerSprite = tolua.cast(self.bgLayer:getChildByTag(10),"CCProgressTimer")
  self.timerSprite:setPercentage(per)

  local perStr=haveExp .. "/" .. exp
  local perLb=GetTTFLabel(perStr,20)
  -- self.timerSprite:addChild(perLb)
  self.bgLayer:addChild(perLb,10)
  -- perLb:setPosition(self.timerSprite:getContentSize().width/2,self.timerSprite:getContentSize().height/2)
  perLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-350-self.allAddH+1)
  self.perLb=perLb

end

--设置对话框里的tableView
function heroUpgrade2Dialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tvAddH=380
    if G_isIphone5() then
      self.tvAddH=410
    end
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-self.tvAddH-self.allAddH),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,30))
    self.bgLayer:addChild(self.tv)

    self.tv:setMaxDisToBottomOrTop(0)
    

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function heroUpgrade2Dialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(600,self.bgLayer:getContentSize().height-self.tvAddH-self.allAddH)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease() 


        local height=self.bgLayer:getContentSize().height-self.tvAddH-30

        local function nilFunc()
        end
        local descH=350
        if G_isIphone5() then
          descH=400
        end
        local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
        descBg:setContentSize(CCSizeMake(600,descH))
        descBg:setPosition(ccp(300,height))
        descBg:setAnchorPoint(ccp(0.5,1))
        cell:addChild(descBg)

        local maxLv=heroCfg.heroLevel[self.heroVo.productOrder]

        local lbH=descBg:getContentSize().height-40
        local lbW=descBg:getContentSize().width/2
        local attributeTb={
            {str=getlocal("current_attribute"),width=lbW-200,height=lbH},
            -- {str=getlocal("accessory_attChange"),width=lbW,height=lbH},
            {str=getlocal("top_attribute"),width=lbW+200,height=lbH},

        }  
        if tonumber(self.heroVo.level)<tonumber(maxLv) then
            table.insert(attributeTb,{str=getlocal("accessory_attChange"),width=lbW,height=lbH})
        end
        local sizeH=0
        for k,v in pairs(attributeTb) do
            local attributeLb=GetTTFLabelWrap(v.str,25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            attributeLb:setPosition(v.width,v.height)
            descBg:addChild(attributeLb,1)
            attributeLb:setColor(G_ColorYellowPro)
            if attributeLb:getContentSize().height>sizeH then
              sizeH=attributeLb:getContentSize().height
            end
        end

        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
        titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,sizeH+10))
        titleBg:setScaleX((G_VisibleSizeWidth-60)/titleBg:getContentSize().width)
        titleBg:setScaleY(60/titleBg:getContentSize().height)
        titleBg:setPosition(ccp(descBg:getContentSize().width/2,lbH))
        descBg:addChild(titleBg)

        local atb1,atb2=heroVoApi:getAddBuffTb(self.heroVo)
        local maxTb=heroVoApi:getMaxBuffTb(self.heroVo)

        local tb={atk={icon="attributeARP.png",lb={getlocal("dmg"),}},
                  hlp={icon="attributeArmor.png",lb={getlocal("hlp"),}},
                  hit={icon="skill_01.png",lb={getlocal("sample_skill_name_101"),}},
                  eva={icon="skill_02.png",lb={getlocal("sample_skill_name_102"),}},
                  cri={icon="skill_03.png",lb={getlocal("sample_skill_name_103"),}},
                  res={icon="skill_04.png",lb={getlocal("sample_skill_name_104"),}},
                 }
        self.adTb = {}
        for k,v in pairs(heroListCfg[self.heroVo.hid].heroAtt) do
            table.insert( self.adTb, k )
        end

        for i=1,SizeOfTable(heroListCfg[self.heroVo.hid].heroAtt) do
            local attackSp = CCSprite:createWithSpriteFrameName(tb[self.adTb[i]].icon)
            local iconScale= 50/attackSp:getContentSize().width
            attackSp:setAnchorPoint(ccp(0.5,0.5))
            local width=i%1
            local secPos=250
            if width==0 then
                width=2
                secPos=secPos+22
            end
            attackSp:setPosition(ccp(60,lbH-10-math.ceil(i/1)*65))
            descBg:addChild(attackSp,2)
            attackSp:setScale(iconScale)

            local strLb1=nil
            local sizeOfaddOrSub=nil
            if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" or G_getCurChoseLanguage()=="ru"  then
              strLb1=GetTTFLabelWrap(tb[self.adTb[i]].lb[1],35,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
              sizeOfaddOrSub=-20
            else
              strLb1=GetTTFLabel(tb[self.adTb[i]].lb[1],40)
              sizeOfaddOrSub=10
            end
            strLb1:setAnchorPoint(ccp(0,0.5))
            strLb1:setPosition(ccp(attackSp:getContentSize().width+10,attackSp:getContentSize().height/2))
            attackSp:addChild(strLb1)


            local strLb2=GetTTFLabel("+"..atb1[self.adTb[i]].."%",38)
            strLb2:setAnchorPoint(ccp(0,0.5))
            strLb2:setPosition(ccp(attackSp:getContentSize().width+sizeOfaddOrSub+strLb1:getContentSize().width+17,attackSp:getContentSize().height/2))
            attackSp:addChild(strLb2)

            if tonumber(self.heroVo.level)<tonumber(maxLv) then
                local aIcon = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
                aIcon:setAnchorPoint(ccp(0.5,0.5))
                aIcon:setPosition(ccp(270,lbH-10-math.ceil(i/1)*65))
                descBg:addChild(aIcon)
                aIcon:setScale(iconScale)

                local strLb3=GetTTFLabel(atb2[self.adTb[i]].."%",40)
                strLb3:setAnchorPoint(ccp(0,0.5))
                strLb3:setPosition(ccp(aIcon:getContentSize().width+3,aIcon:getContentSize().height/2))
                strLb3:setColor(G_ColorGreen)
                aIcon:addChild(strLb3)
            end
            

            local strLb4=GetTTFLabel(maxTb[self.adTb[i]].."%",40)
            strLb4:setAnchorPoint(ccp(0,0.5))
            strLb4:setPosition(ccp(lbW+180,lbH-10-math.ceil(i/1)*65))
            strLb4:setColor(G_ColorGreen)
            descBg:addChild(strLb4)
            strLb4:setScale(iconScale)
        end

        -- 当前拥有经验点
        -- 多语言修改lb长度CCSizeMake(360,0)
        local currentExp=heroVoApi:getExp() or 0
        local currentHAddH=30
        if G_isIphone5() then
          currentHAddH=50
        end
        local currentExpLb=GetTTFLabelWrap(getlocal("current_expPoint",{currentExp}),20,CCSizeMake(360,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        currentExpLb:setPosition(lbW-25,height-descH-currentHAddH)
        cell:addChild(currentExpLb,1)

        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),function ( ... )end)
        titleBg:setContentSize(CCSizeMake(560,currentExpLb:getContentSize().height + 16))
        titleBg:setPosition(lbW,height-descH-currentHAddH)
        cell:addChild(titleBg)

        local bookSp=CCSprite:createWithSpriteFrameName("hero_exp.png")
        bookSp:setScale(40/bookSp:getContentSize().width)
        bookSp:setAnchorPoint(ccp(0,0.5))
        bookSp:setPosition(currentExpLb:getContentSize().width,currentExpLb:getContentSize().height/2)
        currentExpLb:addChild(bookSp)


        if tonumber(self.heroVo.level)<tonumber(maxLv) then
            local upLv,allExp,oneNeedExp=heroVoApi:canMaxUpLevel(self.heroVo,currentExp)
            if upLv>1 then
                local function upgradeHero()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                        local function callback(fn,data)
                          local ret,sData=base:checkServerData(data)
                          if ret==true then
                            self:refresh()
                          end
                        end
                        local level=self.heroVo.level+1
                        local hid=self.heroVo.hid
                        socketHelper:oneUpgradeHero(level,hid,callback)
                    end
                  
                end
                local oneItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeHero,nil,getlocal("hero_upgrade_x",{1}),24/0.8,101)
                oneItem:setAnchorPoint(ccp(0.5,0))
                oneItem:setScale(0.8)
                local btnLb = oneItem:getChildByTag(101)
                if btnLb then
                  btnLb = tolua.cast(btnLb,"CCLabelTTF")
                  btnLb:setFontName("Helvetica-bold")
                end
                local oneBtn=CCMenu:createWithItem(oneItem);
                oneBtn:setTouchPriority(-(self.layerNum-1)*20-4);
                oneBtn:setPosition(ccp(lbW-150,10))
                cell:addChild(oneBtn)

                local numLb=GetTTFLabel(oneNeedExp,25)
                numLb:setAnchorPoint(ccp(0,0.5))
                numLb:setPosition(oneItem:getContentSize().width/2-25,oneItem:getContentSize().height+20)
                oneItem:addChild(numLb)

                local bookSp=CCSprite:createWithSpriteFrameName("hero_exp.png")
                bookSp:setScale(40/bookSp:getContentSize().width)
                bookSp:setAnchorPoint(ccp(0,0.5))
                bookSp:setPosition(numLb:getContentSize().width+10,numLb:getContentSize().height/2)
                numLb:addChild(bookSp)

                local function upgradeHero()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                        local function callback(fn,data)
                          local ret,sData=base:checkServerData(data)
                          if ret==true then
                            self:refresh()
                          end
                        end
                        local level=self.heroVo.level+upLv
                        local hid=self.heroVo.hid
                        socketHelper:oneUpgradeHero(level,hid,callback)
                    end
                end
                local XItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeHero,nil,getlocal("hero_upgrade_x",{upLv}),24/0.8,101)
                XItem:setAnchorPoint(ccp(0.5,0))
                XItem:setScale(0.8)
                local btnLb = XItem:getChildByTag(101)
                if btnLb then
                  btnLb = tolua.cast(btnLb,"CCLabelTTF")
                  btnLb:setFontName("Helvetica-bold")
                end
                local XBtn=CCMenu:createWithItem(XItem);
                XBtn:setTouchPriority(-(self.layerNum-1)*20-4);
                XBtn:setPosition(ccp(lbW+150,10))
                cell:addChild(XBtn)

                local numLb=GetTTFLabel(allExp,25)
                numLb:setAnchorPoint(ccp(0,0.5))
                numLb:setPosition(XItem:getContentSize().width/2-45,XItem:getContentSize().height+20)
                XItem:addChild(numLb)

                local bookSp=CCSprite:createWithSpriteFrameName("hero_exp.png")
                bookSp:setScale(40/bookSp:getContentSize().width)
                bookSp:setAnchorPoint(ccp(0,0.5))
                bookSp:setPosition(numLb:getContentSize().width+10,numLb:getContentSize().height/2)
                numLb:addChild(bookSp)
            elseif upLv==1 then
                local function upgradeHero()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                        local function callback(fn,data)
                          local ret,sData=base:checkServerData(data)
                          if ret==true then
                            self:refresh()
                          end
                        end
                        local level=self.heroVo.level+1
                        local hid=self.heroVo.hid
                        socketHelper:oneUpgradeHero(level,hid,callback)
                    end
                end
                local oneItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeHero,nil,getlocal("hero_upgrade_x",{1}),24/0.8,101)
                oneItem:setAnchorPoint(ccp(0.5,0))
                oneItem:setScale(0.8)
                local btnLb = oneItem:getChildByTag(101)
                if btnLb then
                  btnLb = tolua.cast(btnLb,"CCLabelTTF")
                  btnLb:setFontName("Helvetica-bold")
                end
                local oneBtn=CCMenu:createWithItem(oneItem);
                oneBtn:setTouchPriority(-(self.layerNum-1)*20-4);
                oneBtn:setPosition(ccp(lbW,10))
                cell:addChild(oneBtn)

                local numLb=GetTTFLabel(oneNeedExp,25)
                numLb:setAnchorPoint(ccp(0,0.5))
                numLb:setPosition(oneItem:getContentSize().width/2-25,oneItem:getContentSize().height+20)
                oneItem:addChild(numLb)

                local bookSp=CCSprite:createWithSpriteFrameName("hero_exp.png")
                bookSp:setScale(40/bookSp:getContentSize().width)
                bookSp:setAnchorPoint(ccp(0,0.5))
                bookSp:setPosition(numLb:getContentSize().width+10,numLb:getContentSize().height/2)
                numLb:addChild(bookSp)
            else
              oneNeedExp=heroVoApi:getHeroLeftExp(self.heroVo)

                local function upgradeHero()
                  if currentExp>=oneNeedExp then
                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage11014"),30)
                      do
                          return
                      end
                  end
                end
                local oneItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeHero,nil,getlocal("hero_upgrade_x",{1}),24/0.8,101)
                oneItem:setAnchorPoint(ccp(0.5,0))
                oneItem:setScale(0.8)
                local btnLb = oneItem:getChildByTag(101)
                if btnLb then
                  btnLb = tolua.cast(btnLb,"CCLabelTTF")
                  btnLb:setFontName("Helvetica-bold")
                end
                local oneBtn=CCMenu:createWithItem(oneItem);
                oneBtn:setTouchPriority(-(self.layerNum-1)*20-4);
                oneBtn:setPosition(ccp(lbW,10))
                cell:addChild(oneBtn)
                
                if currentExp<oneNeedExp then
                  oneItem:setEnabled(false)
                end
                
                local numLb=GetTTFLabel(oneNeedExp,25)
                numLb:setAnchorPoint(ccp(0,0.5))
                numLb:setPosition(oneItem:getContentSize().width/2-25,oneItem:getContentSize().height+20)
                oneItem:addChild(numLb)

                local bookSp=CCSprite:createWithSpriteFrameName("hero_exp.png")
                bookSp:setScale(40/bookSp:getContentSize().width)
                bookSp:setAnchorPoint(ccp(0,0.5))
                bookSp:setPosition(numLb:getContentSize().width+10,numLb:getContentSize().height/2)
                numLb:addChild(bookSp)
            end
        else
          -- 已经升到顶级
            local function touchSure()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                    self:close()
                end
            end
            local oneItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchSure,nil,getlocal("confirm"),24/0.8,101)
            oneItem:setAnchorPoint(ccp(0.5,0))
            oneItem:setScale(0.8)
            local btnLb = oneItem:getChildByTag(101)
            if btnLb then
              btnLb = tolua.cast(btnLb,"CCLabelTTF")
              btnLb:setFontName("Helvetica-bold")
            end
            local oneBtn=CCMenu:createWithItem(oneItem);
            oneBtn:setTouchPriority(-(self.layerNum-1)*20-4);
            oneBtn:setPosition(ccp(lbW,10))
            cell:addChild(oneBtn)

            local maxLb=GetTTFLabelWrap(getlocal("hero_retchTop"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
            maxLb:setAnchorPoint(ccp(0.5,0))
            maxLb:setPosition(oneItem:getContentSize().width/2,80)
            oneItem:addChild(maxLb,1)


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

function heroUpgrade2Dialog:refresh()
   self.heroVo=heroVoApi:getHeroByHid(self.heroVo.hid)
   local str=G_LV()..self.heroVo.level
   local lb=self.bgLayer:getChildByTag(101)
   lb=tolua.cast(lb,"CCLabelTTF")
   lb:setString(str)
   local exp,per,haveExp=heroVoApi:getHeroLeftExp(self.heroVo)
   self.timerSprite:setPercentage(per)

   local perStr=haveExp .. "/" .. exp
   self.perLb:setString(perStr)

   local maxLv=heroCfg.heroLevel[self.heroVo.productOrder]
   if tonumber(self.heroVo.level)==tonumber(maxLv) then
      local lb2=self.bgLayer:getChildByTag(103)
      lb2:setVisible(true)
      self.perLb:setVisible(false)
   end
  
    local recordPoint=self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)

end

--点击tab页签 idx:索引
function heroUpgrade2Dialog:tabClick(idx)
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
function heroUpgrade2Dialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function heroUpgrade2Dialog:cellClick(idx)
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

function heroUpgrade2Dialog:tick()

end

function heroUpgrade2Dialog:dispose()
    self.parent:refresh()
    self.expandIdx=nil
    self=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acFirstRechargenew.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/acFirstRechargenew.plist")
    spriteController:removePlist("public/hero_exp.plist")
    spriteController:removeTexture("public/hero_exp.png")
end




