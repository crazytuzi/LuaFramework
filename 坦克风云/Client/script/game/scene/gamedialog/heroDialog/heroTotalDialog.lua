
heroTotalDialog=commonDialog:new()

function heroTotalDialog:new(layerNum)
    
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.isShowTip=false
    self.tipSpTb={}

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/heroRecruitImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/hero/heroHonor.plist")
    if base.he==1 then
        
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/hero/heroequip/equipCompress.plist")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    end
    return nc
end

--设置或修改每个Tab页签
function heroTotalDialog:resetTab()

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
        

end

function heroTotalDialog:initFunctionTb()
  local function showHelpInfo(tabStr,colorTb)
    local td=smallDialog:new()
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTb)
    sceneGame:addChild(dialog,self.layerNum+1)
  end
  local function callBack1()
      local heroOpenLv=base.heroOpenLv or 20
      if playerVoApi:getPlayerLevel()<heroOpenLv then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{heroOpenLv}),30)

         do
           return
         end
      end
      require "luascript/script/game/scene/gamedialog/heroDialog/heroRecruitDialog"
      local td=heroRecruitDialog:new(self.layerNum+1)
      local tbArr={}


       local str = getlocal("recruitTitle")
       -- if G_getBHVersion()==2 then
       --    str = getlocal("newrecruitTitle")
       -- end

      local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,str,true,self.layerNum+1)
      sceneGame:addChild(dialog,self.layerNum+1)
  end
  local function callBack2()
        require "luascript/script/game/scene/gamedialog/heroDialog/heroManagerDialog"
        local td=heroManagerDialog:new()
        local tbArr={}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("heroManage"),true,self.layerNum+1)
        sceneGame:addChild(dialog,self.layerNum+1)

  end

  local function callBack11()
      local td=smallDialog:new()
      local str1 = getlocal("recruitHeroDes1")
      local str2 = getlocal("recruitHeroDes2")
      local str3 = getlocal("recruitHeroDes3")
      local str4 = getlocal("recruitHeroDes4",{heroCfg.freeTicketLimit})
      local str5 = getlocal("recruitHeroDes5",{math.ceil(heroCfg.payTicketTime/3600)})
      local str6 = getlocal("recruitHeroDes6")
      local str7 = getlocal("recruitHeroDes7")



      local tabStr = {" ",str7,str6,str5,str4,str3,str2,str1," "}
      -- if G_getBHVersion()==2 then
      if(base.hexieMode==1)then

        local str1 = getlocal("newrecruitHeroDes1")
        local str2 = getlocal("newrecruitHeroDes2")
        local str3 = getlocal("newrecruitHeroDes3",{heroCfg.freeTicketLimit})
        local str4 = getlocal("newrecruitHeroDes4",{math.ceil(heroCfg.payTicketTime/3600)})
        local str5 = getlocal("newrecruitHeroDes5")
        tabStr = {" ",str5,str4,str3,str2,str1," "}
      end


      local colorTb = {nil,G_ColorRed,nil,nil,nil,nil,nil,nil,nil}
      local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTb)
      sceneGame:addChild(dialog,self.layerNum+1)
  end
  local function callBack12()
      local td=smallDialog:new()
      local str1 = getlocal("manageHeroDes1")
      local str2 = getlocal("manageHeroDes2")
      local str3 = getlocal("manageHeroDes3")
      local tabStr = {" ",str3,str2,str1," "}
      local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
      sceneGame:addChild(dialog,self.layerNum+1)
  end

    local aStr = "recruitTitle"
    if G_getBHVersion()==2 then
        aStr = "newrecruitTitle"
    end
  self.functionTb={
  {icon="recruitIcon.png",nameKey=aStr,callBack=callBack1,callBack2=callBack11,type=true},
  {icon="heroManage.png",nameKey="heroManage",callBack=callBack2,callBack2=callBack12},

  }

  local heroOpenLv=base.heroOpenLv or 20
  if playerVoApi:getPlayerLevel()<heroOpenLv then
    table.remove(self.functionTb,1)
  end

  --将领副官
  if heroAdjutantVoApi:isOpen() then
    local function callBack7()
        local heroList = heroVoApi:getHeroList()
        local heroCount = SizeOfTable(heroList)
        if heroCount <= 0 then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("heroAdjutant_notHeroTips"), 30)
            do return end
        end
        require "luascript/script/game/scene/gamedialog/heroDialog/heroAdjutantDialog"
        local td = heroAdjutantDialog:new(self.layerNum + 1)
        local dialog = td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("heroAdjutant_title"),true,self.layerNum+1)
        sceneGame:addChild(dialog, self.layerNum + 1)
        if(otherGuideMgr.isGuiding and otherGuideMgr.curStep and otherGuideMgr.curStep>=80 and otherGuideMgr.curStep<=81)then
            otherGuideMgr:endNewGuid()
        end
    end
    local function callBack17()
        local td = smallDialog:new()
        local tabStr = {
            " ",
            getlocal("heroAdjutant_explainInfo3"),
            getlocal("heroAdjutant_explainInfo2"),
            getlocal("heroAdjutant_explainInfo1"),
            " "
        }
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    table.insert(self.functionTb, {icon="adj_funcIcon.png", nameKey="heroAdjutant_title", callBack=callBack7, callBack2=callBack17})
  end
  
  if heroVoApi:heroHonorIsOpen()==true and playerVoApi:getPlayerLevel()>=heroFeatCfg.levelLimit then
      eventDispatcher:dispatchEvent("hero.openDialog")
      local function callBack3()
          require "luascript/script/game/scene/gamedialog/heroDialog/heroHonorDialog"
          local td=heroHonorDialog:new()
          local tbArr={getlocal("hero_honor_sub_title_1"),getlocal("hero_honor_sub_title_2")}
          local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("hero_honor_title"),true,self.layerNum+1)
          sceneGame:addChild(dialog,self.layerNum+1)
          if(otherGuideMgr.isGuiding and otherGuideMgr.curStep and otherGuideMgr.curStep>=2 and otherGuideMgr.curStep<=4)then
              otherGuideMgr:endNewGuid()
          end
      end
      local function callBack13()
          local td=smallDialog:new()
          local str1 = getlocal("hero_honor_tip_1")
          local str2 = getlocal("hero_honor_tip_2")
          local tabStr = {" ",str2,str1," "}
          if(heroVoApi:heroHonor2IsOpen())then
              table.insert(tabStr,2,getlocal("hero_honor_tip_3"))
              table.insert(tabStr,2,getlocal("hero_honor_tip_4"))
          end
          local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
          sceneGame:addChild(dialog,self.layerNum+1)
      end
      local heroHonor={icon="heroHonorIcon.png",nameKey="hero_honor_title",callBack=callBack3,callBack2=callBack13}
      table.insert(self.functionTb,heroHonor)
  end

  -- 将领装备研究所
  if base.he==1 then
    
    
    local function callBack4()
        local function openEquipLab( ... )
            heroEquipVoApi:openEquipLabDialog(self.layerNum+1)
        end
        
        local function callbackHandler4(fn,data)
            openEquipLab()
        end
        if heroEquipVoApi and heroEquipVoApi.ifNeedSendRequest==true then
            heroEquipVoApi:equipGet(callbackHandler4)
        else
            openEquipLab()
        end
    end
    local function callBack14()
        local td=smallDialog:new()
        local str1 = getlocal("equiplab_tip1")
        local str2 = getlocal("equiplab_tip2")
        local str3 = getlocal("equiplab_tip3")
        local str4 = getlocal("equiplab_tip4")
        local str5 = getlocal("equiplab_tip5")
        
        local tabStr = {" ",str5,str4,str3,str2,str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local heroEquipLab={icon="heroEquipIcon.png",nameKey="equip_lab_title",callBack=callBack4,callBack2=callBack14}
    

    local function callBack5()
        heroEquipChallengeVoApi:openExploreDialog(nil,nil,self.layerNum+1)
    end
    local function callBack15()
        local td=smallDialog:new()
        local str1 = getlocal("equip_explore_tip_1")
        local str2 = getlocal("equip_explore_tip_2")
        local str3 = getlocal("equip_explore_tip_3")
        local str4 = getlocal("equip_explore_tip_4")
        local str5 = getlocal("equip_explore_tip_5")
        local str6 = getlocal("equip_explore_tip_6")
        local tabStr = {" ",str6,str5,str4,str3,str2,str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local equipOpenLv=base.heroEquipOpenLv or 30
    local heroEquipChallenge={icon="heroEquipLabIcon.png",nameKey="equip_explore_title",callBack=callBack5,callBack2=callBack15}
    if playerVoApi:getPlayerLevel()>=equipOpenLv then
      table.insert(self.functionTb,heroEquipLab)
      table.insert(self.functionTb,heroEquipChallenge)
    end

    local function callBack6()
      require "luascript/script/game/scene/gamedialog/heroDialog/heroSmeltDialog"
      require "luascript/script/config/gameconfig/heroSmeltCfg"
      local td=heroSmeltDialog:new()
      local tbArr={}
      local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("hero_smelt_title"),true,self.layerNum+1)
      sceneGame:addChild(dialog,self.layerNum+1)
    end
    local function callBack16()
      local str1 = getlocal("hero_smelt_info1")
      local str2 = getlocal("hero_smelt_info2")
      local str3 = getlocal("hero_smelt_info3")
      local str4 = getlocal("hero_smelt_info4")
      local tabStr = {" ",str6,str5,str4,str3,str2,str1," "}
      showHelpInfo(tabStr,nil)
    end
    if base.hs==1 and playerVoApi:getPlayerLevel()>=20 then
      spriteController:addPlist("public/heroSmeltImage.plist")
      spriteController:addTexture("public/heroSmeltImage.png")

      local heroSmeltLab={icon="hero_smelt_icon.png",nameKey="hero_smelt_title",callBack=callBack6,callBack2=callBack16}
      table.insert(self.functionTb,heroSmeltLab)

    end
  end
end

--设置对话框里的tableView
function heroTotalDialog:initTableView()
    heroEquipVoApi.heroOpenFlag=true
    self:initFunctionTb()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-25-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)

    self.tv:setMaxDisToBottomOrTop(120)

    if self.guideAdjItem and otherGuideMgr.curStep==80 and otherGuideMgr:checkGuide(81)==false then
        otherGuideMgr:showGuide(81)
        otherGuideMgr:setGuideStepField(81,self.guideAdjItem,true)
    elseif self.guideItem and otherGuideMgr:checkGuide(4)==false then
        otherGuideMgr:setGuideStepField(4,self.guideItem,true)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function heroTotalDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.functionTb)
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(400,130)
         
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       local hei =120
       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       cell:addChild(backSprie,1)

       local mIcon=CCSprite:createWithSpriteFrameName(self.functionTb[idx+1].icon)
       mIcon:setAnchorPoint(ccp(0,0.5))
       mIcon:setPosition(ccp(10,backSprie:getContentSize().height/2))
       backSprie:addChild(mIcon)

       local qualityLbFontSize = 24
       if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
          qualityLbFontSize = 24
       else
          qualityLbFontSize = 20
       end
       local qualityLb=GetTTFLabelWrap(getlocal(self.functionTb[idx+1].nameKey),qualityLbFontSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
       qualityLb:setAnchorPoint(ccp(0,0.5))
       qualityLb:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+15,backSprie:getContentSize().height/2))
       backSprie:addChild(qualityLb)

       local function callBack()
          if self.tv:getIsScrolled()==true then
              do
                  return
              end
          end
         self.functionTb[idx+1].callBack2()
       end

       local menuItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",callBack,11,nil,nil)
       local menu = CCMenu:createWithItem(menuItem);
       menu:setPosition(ccp(360,backSprie:getContentSize().height/2));
       menu:setTouchPriority(-(self.layerNum-1)*20-2);
       backSprie:addChild(menu,3);


       local function onSelectAll()
        if self.tv:getIsScrolled()==true then
            do
                return
            end
        end
         self.functionTb[idx+1].callBack()
       end
       local selectAllItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onSelectAll,nil,getlocal("allianceWar_enter"),24/0.8,101)
       selectAllItem:setAnchorPoint(ccp(1,0.5))
       selectAllItem:setScale(0.8)
       local btnLb = selectAllItem:getChildByTag(101)
       if btnLb then
          btnLb = tolua.cast(btnLb,"CCLabelTTF")
          btnLb:setFontName("Helvetica-bold")
       end
       local selectAllBtn=CCMenu:createWithItem(selectAllItem);
       selectAllBtn:setTouchPriority(-(self.layerNum-1)*20-2);
       selectAllBtn:setPosition(ccp(backSprie:getContentSize().width-10,backSprie:getContentSize().height/2))
       backSprie:addChild(selectAllBtn)
       
       if idx==0 and heroVoApi:isHasFreeLottery()==true and self.functionTb[idx+1].type then
           local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
           tipSp:setAnchorPoint(CCPointMake(1,0.5))
           tipSp:setPosition(ccp(selectAllItem:getContentSize().width+10,selectAllItem:getContentSize().height-10))
           tipSp:setTag(101)
           selectAllItem:addChild(tipSp)
       end
      local item=self.functionTb[idx+1]
      if item then
        self.tipSpTb[item.nameKey]=nil
        if item.nameKey=="equip_lab_title" then
          local tipSp=CCSprite:createWithSpriteFrameName("IconTip.png")
          tipSp:setPosition(ccp(selectAllItem:getContentSize().width+10,selectAllItem:getContentSize().height-10))
          tipSp:setAnchorPoint(CCPointMake(1,0.5))
          selectAllItem:addChild(tipSp)
          self.tipSpTb[item.nameKey]=tipSp
          local tipFlag=self:getFunctionTipFlag(item.nameKey)
          tipSp:setVisible(tipFlag)
        elseif item.nameKey=="hero_honor_title" then --将领授勋
          self.guideItem=selectAllItem
        elseif item.nameKey=="heroAdjutant_title" then --将领副官
          self.guideAdjItem = selectAllItem
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

--点击tab页签 idx:索引
function heroTotalDialog:tabClick(idx)
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
function heroTotalDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function heroTotalDialog:cellClick(idx)
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

function heroTotalDialog:tick()
    if self and self.isShowTip~=heroVoApi:isHasFreeLottery() then
        if self.tv then
            self.tv:reloadData()
        end
        self.isShowTip=heroVoApi:isHasFreeLottery()
    end
    if self and self.tipSpTb then
      local refreshFlag=false
      for nameKey,tipSp in pairs(self.tipSpTb) do
        local tipFlag=self:getFunctionTipFlag(nameKey)
        tipSp=tolua.cast(tipSp,"CCSprite")
        if tipSp then
          tipSp:setVisible(tipFlag)
        end
      end
    end
end

function heroTotalDialog:getFunctionTipFlag(nameKey)
    local tipFlag=false
    if nameKey=="equip_lab_title" then
      tipFlag=heroEquipVoApi:checkIfHasFreeLottery()
    end
    return tipFlag
end

function heroTotalDialog:dispose()
    heroEquipVoApi.heroOpenFlag=false
    G_releaseHeroImage()
    self.expandIdx=nil
    self.isShowTip=false
    self.tipSpTb={}
    self.guideItem=nil
    self=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/heroRecruitImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/heroRecruitImage.pvr.ccz")
    if base.he==1 then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/hero/heroequip/equipCompress.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/hero/heroequip/equipCompress.png")
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
    end
    if base.hs==1 and playerVoApi:getPlayerLevel()>=20 then
       spriteController:removePlist("public/heroSmeltImage.plist")
       spriteController:removeTexture("public/heroSmeltImage.png")
    end
end




