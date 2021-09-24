
heroUpgradeDialog=commonDialog:new()

function heroUpgradeDialog:new(heroVo,parent,layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.heroVo=heroVo
    self.parent=parent
    return nc
end

--设置或修改每个Tab页签
function heroUpgradeDialog:resetTab()

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

function heroUpgradeDialog:initLayer()

  local heroIcon = heroVoApi:getHeroIcon(self.heroVo.hid,self.heroVo.productOrder)
  heroIcon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180))
  self.bgLayer:addChild(heroIcon)
  
  local exp,per=heroVoApi:getHeroLeftExp(self.heroVo)
  local lbx=250
  local color=heroVoApi:getHeroColor(self.heroVo.productOrder)
  --UI
  local lbTB={
  {str=G_LV()..self.heroVo.level,size=20,pos={110,G_VisibleSizeHeight-350},aPos={0,0.5},color=G_ColorYellow,tag=101},
  {str=getlocal(heroListCfg[self.heroVo.hid].heroName),size=24,pos={G_VisibleSizeWidth/2,G_VisibleSizeHeight-300},aPos={0.5,0.5},color=color,bold=true},
  {str=getlocal("heroUpgradeCost"),size=20,pos={G_VisibleSizeWidth/2,G_VisibleSizeHeight-600},aPos={0.5,0.5},},
  {str=getlocal("upgradeExpRequired",{exp}),size=20,pos={G_VisibleSize.width/2,G_VisibleSizeHeight-390},aPos={0.5,0.5},tag=102},

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
  end

  AddProgramTimer(self.bgLayer,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-350),10,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",11,0.6)
  self.timerSprite = tolua.cast(self.bgLayer:getChildByTag(10),"CCProgressTimer")
  self.timerSprite:setPercentage(per)

  local atb1,atb2=heroVoApi:getAddBuffTb(self.heroVo)
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
  self.lbTb1={}
  self.lbTb2={}
  for i=1,SizeOfTable(heroListCfg[self.heroVo.hid].heroAtt) do
      local attackSp = CCSprite:createWithSpriteFrameName(tb[self.adTb[i]].icon)
      local iconScale= 50/attackSp:getContentSize().width
      attackSp:setAnchorPoint(ccp(0,0.5))
      local width=i%2
      local secPos=250
      if width==0 then
          width=2
          secPos=secPos+22
      end
      attackSp:setPosition(ccp(-220+secPos*width,self.bgLayer:getContentSize().height-380-math.ceil(i/2)*80))
      self.bgLayer:addChild(attackSp,2)
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
      self.lbTb1[i]=strLb2

      local aIcon = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
      aIcon:setAnchorPoint(ccp(0,0.5))
      aIcon:setPosition(ccp(strLb2:getContentSize().width+3,strLb2:getContentSize().height/2))
      strLb2:addChild(aIcon)

      local strLb3=GetTTFLabel(atb2[self.adTb[i]].."%",40)
      strLb3:setAnchorPoint(ccp(0,0.5))
      strLb3:setPosition(ccp(aIcon:getContentSize().width+3,aIcon:getContentSize().height/2))
      strLb3:setColor(G_ColorGreen)
      aIcon:addChild(strLb3)
      self.lbTb2[i]=strLb3

  end
  --箭头
  local capInSet = CCRect(9, 6, 1, 1);
  local function touchClick(hd,fn,idx)
       
   end
   local arrowWidth=nil
   if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" or G_getCurChoseLanguage()=="ru"  then
    arrowWidth=180
  else
    arrowWidth=240
  end
   local arrowSp1 =LuaCCScale9Sprite:createWithSpriteFrameName("heroArrowRight.png",capInSet,touchClick)
   arrowSp1:setContentSize(CCSizeMake(arrowWidth, 16))
   arrowSp1:setAnchorPoint(ccp(0,0.5))
   arrowSp1:setPosition(ccp(20, G_VisibleSizeHeight-600))
   arrowSp1:setIsSallow(false)
   arrowSp1:setTouchPriority(-(self.layerNum-1)*20-2)
   self.bgLayer:addChild(arrowSp1,1)

   local arrowSp2 =LuaCCScale9Sprite:createWithSpriteFrameName("heroArrowRight.png",capInSet,touchClick)
   arrowSp2:setContentSize(CCSizeMake(arrowWidth, 16))
   arrowSp2:setAnchorPoint(ccp(0,0.5))
   arrowSp2:setPosition(ccp(self.bgLayer:getContentSize().width-20, G_VisibleSizeHeight-600))
   arrowSp2:setIsSallow(false)
   arrowSp2:setTouchPriority(-(self.layerNum-1)*20-2)
   self.bgLayer:addChild(arrowSp2,1)
   arrowSp2:setRotation(180)

end

--设置对话框里的tableView
function heroUpgradeDialog:initTableView()
    self.propsTb=heroVoApi:getHeroExpBookList()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-650),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)

    self.tv:setMaxDisToBottomOrTop(120)
    

end

function heroUpgradeDialog:refresh()
   self.heroVo=heroVoApi:getHeroByHid(self.heroVo.hid)
   local str=G_LV()..self.heroVo.level
   local lb=self.bgLayer:getChildByTag(101)
   lb=tolua.cast(lb,"CCLabelTTF")
   lb:setString(str)
   local exp,per=heroVoApi:getHeroLeftExp(self.heroVo)
   self.timerSprite:setPercentage(per)
   local str2=getlocal("upgradeExpRequired",{exp})
   local lb2=self.bgLayer:getChildByTag(102)
   lb2=tolua.cast(lb2,"CCLabelTTF")
   lb2:setString(str2)

   local atb1,atb2=heroVoApi:getAddBuffTb(self.heroVo)
   for i=1,SizeOfTable(self.lbTb1) do
     local lb= tolua.cast(self.lbTb1[i],"CCLabelTTF")
     lb:setString("+"..atb1[self.adTb[i]].."%")
   end
   for i=1,SizeOfTable(self.lbTb2) do
     local lb= tolua.cast(self.lbTb2[i],"CCLabelTTF")
     lb:setString(atb2[self.adTb[i]].."%")
   end

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function heroUpgradeDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.propsTb)
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(400,150)
         
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       -- local hei =150
       -- local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       -- backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
       -- backSprie:ignoreAnchorPointForPosition(false);
       -- backSprie:setAnchorPoint(ccp(0,0));
       -- backSprie:setTag(1000+idx)
       -- backSprie:setIsSallow(false)
       -- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       -- cell:addChild(backSprie,1)
       local propVo = propCfg[self.propsTb[idx+1]]
       local icon = CCSprite:createWithSpriteFrameName(propCfg[self.propsTb[idx+1]].icon)
       icon:setAnchorPoint(ccp(0,0.5))
       icon:setPosition(ccp(10,75))
       cell:addChild(icon)

       local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
       lineSp:setAnchorPoint(ccp(0,0));
       lineSp:setPosition(ccp(0,0));
       cell:addChild(lineSp,2)

       local function callBack()
          if self.tv:getIsScrolled()==true then
              do
                  return
              end
          end
          local numStr = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(self.propsTb[idx+1])))
          if numStr==0 then
             smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("itemNotEnough"),30)
             do return end

          end


          local function callbackUpgrade(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret==true then
                   -- local level = heroVoApi:getHeroByHid(self.heroVo.hid).level
                   -- for i=40,heroCfg.heroLevel[#heroCfg.heroLevel],10 do
                   --   if level>=i and self.heroVo.level<i then
                   --      local message={key="conLevelUp",param={playerVoApi:getPlayerName(),heroVoApi:getHeroStars(self.heroVo.productOrder),heroVoApi:getHeroName(self.heroVo.hid),level}}
                   --        chatVoApi:sendSystemMessage(message)
                   --   end
                   -- end
                   
                   
                  local recordPoint = self.tv:getRecordPoint()
                  self:refresh()
                  bagVoApi:useItemNumId(tonumber(RemoveFirstChar(self.propsTb[idx+1])),1)
                  self.tv:reloadData()
                  self.tv:recoverToRecordPoint(recordPoint)
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propVo.name)}),30)

              end
          end
          socketHelper:heroUpgrade(self.heroVo.hid,self.propsTb[idx+1],1,callbackUpgrade)
       end
       
       local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callBack,nil,getlocal("use"),24/0.8,101)
       okItem:setScale(0.8)
       local btnLb = okItem:getChildByTag(101)
       if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
       end
       local okBtn=CCMenu:createWithItem(okItem)
       okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
       okBtn:setAnchorPoint(ccp(1,0.5))
       okBtn:setPosition(ccp(self.bgLayer:getContentSize().width-125,60))
       cell:addChild(okBtn)
       local totalSize = 30
       if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() == "fr" then
          totalSize=25
       elseif G_getCurChoseLanguage()=="ru"  then
          totalSize =20
       end
       local numStr = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(self.propsTb[idx+1])))
       local colorRed = nil
       if numStr==0 then
          colorRed=G_ColorRed
       end
       
       local lbTB={
        {str=getlocal(propVo.name),size=24,pos={140,150-30},aPos={0,0.5},color=G_ColorYellowPro,fontName="Helvetica-bold"},
        {str=getlocal(propVo.description),size=20,pos={140,150-90},aPos={0,0.5},},
        {str=getlocal("ownedPropNum",{numStr}),size=20,pos={730,120},aPos={1,0.5},color=colorRed},

       }
       for k,v in pairs(lbTB) do
         local lbWidth = 280
         if G_getCurChoseLanguage() =="ar"  and k==3 then
            lbWidth=100
            v.pos[1]=530
          elseif   G_getCurChoseLanguage()=="ru" and k==3 then
            lbWidth =150
            v.pos[1]=v.pos[1]-135
         end
         local strLb=GetTTFLabelWrap(v.str,v.size,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,v.fontName)
         if v.aPos then
            strLb:setAnchorPoint(ccp(v.aPos[1],v.aPos[2]))
         end
         if v.color then
            strLb:setColor(v.color)
         end
         strLb:setPosition(ccp(v.pos[1],v.pos[2]))
         cell:addChild(strLb)
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

--点击tab页签 idx:索引
function heroUpgradeDialog:tabClick(idx)
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
function heroUpgradeDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function heroUpgradeDialog:cellClick(idx)
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

function heroUpgradeDialog:tick()

end

function heroUpgradeDialog:dispose()
    self.parent:refresh()
    self.expandIdx=nil

    self=nil

end




