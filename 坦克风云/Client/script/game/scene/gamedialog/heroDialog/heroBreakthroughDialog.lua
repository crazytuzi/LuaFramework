
heroBreakthroughDialog=commonDialog:new()

function heroBreakthroughDialog:new(heroVo,parent,layerNum)
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
function heroBreakthroughDialog:resetTab()

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

function heroBreakthroughDialog:initLayer()
  local addY = 230

  local heroIcon = heroVoApi:getHeroIcon(self.heroVo.hid,self.heroVo.productOrder)
  heroIcon:setPosition(ccp(G_VisibleSizeWidth/2-150,G_VisibleSizeHeight-addY))
  self.bgLayer:addChild(heroIcon)

  local icon = CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
  icon:setFlipX(true)
  --icon:setAnchorPoint(ccp(0,0.5))
  icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-addY))
  self.bgLayer:addChild(icon)
  

  local heroIcon = heroVoApi:getHeroIcon(self.heroVo.hid,self.heroVo.productOrder+1)
  heroIcon:setPosition(ccp(G_VisibleSizeWidth/2+150,G_VisibleSizeHeight-addY))
  self.bgLayer:addChild(heroIcon)
  
  

  local function cellClick( ... )

  end
  local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAwardsBox.png",CCRect(40, 40, 1, 1),cellClick)
  rewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,140))
  rewardBg:ignoreAnchorPointForPosition(false)
  self.bgLayer:addChild(rewardBg)
  rewardBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-500))

  local strLb=GetTTFLabelWrap(getlocal("newGetSkill"),30,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  strLb:setAnchorPoint(ccp(0,0.5))
  strLb:setColor(G_ColorYellow)
  strLb:setPosition(ccp(70,G_VisibleSizeHeight-500))
  self.bgLayer:addChild(strLb)

  local sid =heroListCfg[self.heroVo.hid].skills[self.heroVo.productOrder+1][1]
  local iconSkill = CCSprite:create(heroVoApi:getSkillIconBySid(sid))

  --local iconSkill = CCSprite:createWithSpriteFrameName("Icon_buff5.png")
  iconSkill:setAnchorPoint(ccp(0,0.5))
  iconSkill:setPosition(ccp(200-20,strLb:getContentSize().height/2))
  iconSkill:setFlipX(true)
  strLb:addChild(iconSkill)


  local sid =heroListCfg[self.heroVo.hid].skills[self.heroVo.productOrder+1][1]
  local sNameLb=GetTTFLabelWrap(getlocal(heroSkillCfg[sid].name),30,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  sNameLb:setAnchorPoint(ccp(0,0.5))
  sNameLb:setColor(G_ColorYellow)
  sNameLb:setPosition(ccp(400,G_VisibleSizeHeight-500))
  self.bgLayer:addChild(sNameLb)

  
    
  
  
  local lbx=250

  local levelStr =heroCfg.throuhHeroLevel[self.heroVo.productOrder].."/"..G_LV()..heroCfg.heroLevel[self.heroVo.productOrder+1]
  if self.heroVo.level<heroCfg.throuhHeroLevel[self.heroVo.productOrder] then
      levelStr=self.heroVo.level.."/"..G_LV()..heroCfg.heroLevel[self.heroVo.productOrder+1]
  end

  local lbY = 40

  local color1=heroVoApi:getHeroColor(self.heroVo.productOrder)

  local color2=heroVoApi:getHeroColor(self.heroVo.productOrder+1)
  --UI
  local lbTB={
  {str=G_LV()..self.heroVo.level.."/"..G_LV()..heroCfg.heroLevel[self.heroVo.productOrder],size=28,pos={G_VisibleSizeWidth/2-150,G_VisibleSizeHeight-300-lbY},aPos={0.5,0.5},color=G_ColorYellow},
  {str=getlocal(heroListCfg[self.heroVo.hid].heroName),size=28,pos={G_VisibleSizeWidth/2-150,G_VisibleSizeHeight-350-lbY},aPos={0.5,0.5},color=color1},
  {str=G_LV()..levelStr,size=28,pos={G_VisibleSizeWidth/2+150,G_VisibleSizeHeight-300-lbY},aPos={0.5,0.5},color=G_ColorYellow},
  {str=getlocal(heroListCfg[self.heroVo.hid].heroName),size=28,pos={G_VisibleSizeWidth/2+150,G_VisibleSizeHeight-350-lbY},aPos={0.5,0.5},color=color2},


  }
  for k,v in pairs(lbTB) do
    local strLb=GetTTFLabel(v.str,v.size)
    if v.aPos then
       strLb:setAnchorPoint(ccp(v.aPos[1],v.aPos[2]))
    end
    if v.color then
       strLb:setColor(v.color)
    end
    strLb:setPosition(ccp(v.pos[1],v.pos[2]))
    self.bgLayer:addChild(strLb)
  end

   local rect = CCRect(0, 0, 50, 50);
   local capInSet = CCRect(20, 20, 10, 10);
   local function cellClick(hd,fn,idx)
       --return self:cellClick(idx)
   end
   local hei =250
   local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
   backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
   backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2, 250))
   -- backSprie:ignoreAnchorPointForPosition(false);
   -- backSprie:setAnchorPoint(ccp(0,0));
   backSprie:setIsSallow(false)
   backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
   self.bgLayer:addChild(backSprie,1)

   local tb,isSuccessUpdate,propsTb= heroVoApi:getThrouhNeedPropIconBySid(self.heroVo.hid,self.heroVo.productOrder,self.layerNum+1)
    for i=1,SizeOfTable(tb) do
        local icon = tb[i]
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(40+(icon:getContentSize().width+40)*(i-1),90)
        icon:setTouchPriority(-(self.layerNum-1)*20-1)
        backSprie:addChild(icon)
    end
    if isSuccessUpdate==false then
        local desLb=GetTTFLabelWrap(getlocal("notEnoughBreakthroughRes"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0.5,0.5))
        desLb:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-80))
        backSprie:addChild(desLb)
    end

  local function callBack( ... )
      if isSuccessUpdate==false then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughBreakthroughRes"),30)
        do
          return
        end
      end
      local function callback(fn,data)
          local ret,sData=base:checkServerData(data)
          if ret==true then
              for k,v in pairs(propsTb) do
                    bagVoApi:useItemNumId(tonumber(RemoveFirstChar(k)),v)
              end
              smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("heroBreakthroughSuccess"),30)

              if self.heroVo.productOrder+1>=2 then
                  local message={key="conThroughUp",param={playerVoApi:getPlayerName(),heroVoApi:getHeroName(self.heroVo.hid),heroVoApi:getHeroStars(self.heroVo.productOrder+1)}}
                  chatVoApi:sendSystemMessage(message)
              end
              self.parent:refresh()
              self:close()

              local data={hid=self.heroVo.hid}
              eventDispatcher:dispatchEvent("hero.breakthrough",data)
          end
      end
      socketHelper:heroAdvance(self.heroVo.hid,callback)

  end
  local btnStrSize = nil
  if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" then
    btnStrSize = 22
  else
    btnStrSize = 25
  end
  local heroStr = getlocal("breakthrough")
  local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",callBack,nil,heroStr,btnStrSize)
  local okBtn=CCMenu:createWithItem(okItem)
  okBtn:setTouchPriority(-(self.layerNum-1)*20-4)
  okBtn:setAnchorPoint(ccp(1,0.5))
  okBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
  self.bgLayer:addChild(okBtn)



end

--设置对话框里的tableView
function heroBreakthroughDialog:initTableView()
    

end


--点击tab页签 idx:索引
function heroBreakthroughDialog:tabClick(idx)
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
function heroBreakthroughDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function heroBreakthroughDialog:cellClick(idx)
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

function heroBreakthroughDialog:tick()

end

function heroBreakthroughDialog:dispose()
    self.expandIdx=nil

    self=nil

end




