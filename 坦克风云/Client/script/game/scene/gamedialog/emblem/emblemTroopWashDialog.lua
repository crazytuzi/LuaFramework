--军徽部队训练面板
emblemTroopWashDialog=commonDialog:new()

function emblemTroopWashDialog:new(parentDialog,washType,showIndex)
  local nc={
   parentDialog=parentDialog,
   list=nil,
   troopList=nil,--当前展示的装备大师列表
   troopLayer=nil,
   washType=washType,--洗练类型
   showIndex=showIndex,--显示第几个大师
   costShowTb=nil,--洗练消耗的道具
  }
  setmetatable(nc,self)
  self.__index=self
  return nc
end
--设置对话框里的tableView
function emblemTroopWashDialog:initTableView()
  self.panelLineBg:setVisible(false)
  local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
  panelBg:setAnchorPoint(ccp(0.5,0))
  panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
  panelBg:setPosition(G_VisibleSizeWidth/2,5)
  self.bgLayer:addChild(panelBg)
  spriteController:addPlist("public/vipFinal.plist")
  spriteController:addTexture("public/vipFinal.png")
  spriteController:addPlist("public/squaredImgs.plist")
  spriteController:addTexture("public/squaredImgs.png")
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
  self.panelLineBg:setAnchorPoint(ccp(0,0))
  self.panelLineBg:setPosition(ccp(0,0))

  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  spriteController:addPlist("public/emblem/emblemTroopImages.plist")
  spriteController:addTexture("public/emblem/emblemTroopImages.png")
  local bg=CCSprite:create("public/emblem/emTroop_bg.jpg")
  CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  bg:setAnchorPoint(ccp(0.5,1))
  bg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight-82))
  self.bgLayer:addChild(bg)

  local upBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
  upBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
  upBg:setAnchorPoint(ccp(0.5,1))
  upBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82)
  self.bgLayer:addChild(upBg,2)

  local function onTouchInfo()
      if G_checkClickEnable()==false then
          do return end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      local tipsSize=25
      local tabStr={}
      for i=1,5 do
          local str=""
          if i==4 then
            local shopCfg=emblemTroopCfg.shopList["i1"]
            str=getlocal("emblem_troop_wash_info"..i,{shopCfg.limit})
          else
            str=getlocal("emblem_troop_wash_info"..i)
          end
          table.insert(tabStr,str)
      end
      local titleStr=getlocal("activity_baseLeveling_ruleTitle")
      require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
      tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,tipsSize)
  end

  local infoItem=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",onTouchInfo,11,nil,nil)
  -- infoItem:setAnchorPoint(ccp(1,1))
  local infoBtn=CCMenu:createWithItem(infoItem)
  infoBtn:setPosition(ccp(bg:getContentSize().width-40,upBg:getContentSize().height/2))
  infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
  upBg:addChild(infoBtn)

  self.list={}
  self.troopList=emblemTroopVoApi:getEmblemTroopListWithSort()
  local len=0
  if self.troopList then
    len=SizeOfTable(self.troopList)
  end
  if len>0 then
    for i=1,len do
        local layer=self:updateTroopDetail(i)
        layer:setAnchorPoint(ccp(0,0))
        layer:setPosition(ccp(0,10))
        self.bgLayer:addChild(layer)
    end
    -- 检测边界
    local function checkBound(toType,isTouch)
        -- 往左(减)
        if toType==1 then
            -- 如果达到最大值，则无法左滑
            if self.showIndex>1 then
                return true
            end 
        else -- 往右(加)
            if self.showIndex<len then -- 第一页为最新的，则无法往右
                return true
            end
        end
        return false
    end
    require "luascript/script/componet/pageDialog"
    self.troopLayer=pageDialog:new()
    local isShowBg=false
    local isShowPageBtn=true

    local function updateBtnByPage(selectPage)
      if self.troopLayer then
          if len<=1 then
              self.troopLayer:setBtnEnabled(1,false)
              self.troopLayer:setBtnEnabled(2,false)
          elseif selectPage>=len then
              self.troopLayer:setBtnEnabled(2,false)
              self.troopLayer:setBtnEnabled(1,true)
          elseif selectPage<=1 then
              self.troopLayer:setBtnEnabled(1,false)
              self.troopLayer:setBtnEnabled(2,true)
          else
              self.troopLayer:setBtnEnabled(1,true)
              self.troopLayer:setBtnEnabled(2,true)
          end
      end
    end
    local function onPage(topage)
      self.showIndex=topage
      self:updateTroopDetail(topage)
      updateBtnByPage(topage)
    end
    local posY=G_VisibleSizeHeight-450
    local leftBtnPos=ccp(40,posY)
    local rightBtnPos=ccp(G_VisibleSizeWidth-40,posY)
    self.troopLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,self.showIndex,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,checkBound,nil,nil,nil)
    updateBtnByPage(self.showIndex)
  end

  local washCfg=emblemTroopVoApi:getTroopWashCfg()
  local iconStartX=30
  self.costShowTb={}
  if washCfg then
    for i=1,SizeOfTable(washCfg) do
      local costReward=emblemTroopVoApi:getTroopWashCost(i)
      if costReward then
          local costIcon=CCSprite:createWithSpriteFrameName(costReward.pic)
          costIcon:setAnchorPoint(ccp(0,0.5))
          upBg:addChild(costIcon,2)
          costIcon:setPosition(ccp(iconStartX, upBg:getContentSize().height-25))
          if costReward.key~="gems" then
            local function addPropHandler()
              self:addPropHandler()
            end
            local touchBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),addPropHandler)
            touchBg:setContentSize(CCSizeMake(costIcon:getContentSize().width+20,costIcon:getContentSize().height+20))
            touchBg:setTouchPriority(-(self.layerNum-1)*20-4)
            touchBg:setAnchorPoint(ccp(0.5,0.5))
            touchBg:setOpacity(0)
            touchBg:setPosition(costIcon:getPositionX()+costIcon:getContentSize().width/2,costIcon:getPositionY())
            upBg:addChild(touchBg)
          end
          
          local hadNum=0
          if costReward.key=="gems" then
              hadNum=playerVoApi:getGems()
          else
              hadNum=bagVoApi:getItemNumId(costReward.id)
              local addBtn=CCSprite:createWithSpriteFrameName("believerAddBtn.png")
              addBtn:setScale(0.6)
              addBtn:setPosition(costIcon:getContentSize().width-10,0)
              addBtn:setColor(ccc3(135,253,139))
              costIcon:addChild(addBtn)
          end

          local costLb=GetTTFLabel(FormatNumber(hadNum),20)
          costLb:setAnchorPoint(ccp(0,0.5))
          upBg:addChild(costLb,2)
          costLb:setPosition(costIcon:getPositionX()+costIcon:getContentSize().width+5,costIcon:getPositionY())

          if hadNum<costReward.num then
            costLb:setColor(G_LowfiColorRed2)
          end
          
          table.insert(self.costShowTb,{costLb,costReward})
          iconStartX=iconStartX+130
      end
    end
  end
end

function emblemTroopWashDialog:doUserHandler()

end

function emblemTroopWashDialog:updateTroopDetail(troopIndex)
    local troopId=self.troopList[troopIndex].id
    local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
    if troopVo==nil then
      do return end
    end
    local troopPic=troopVo:getIconPic()
    local troopNameStr=troopVo:getName()
    local washStrength=troopVo:getWashStrength()--强度
    local masterMaxStrong=troopVo:getMaxWashStrength()--最大强度
    local isBattle=troopVo:checkIfBattled()
    if isBattle==true then
      troopNameStr=troopNameStr.."("..getlocal("emblem_battle")..")"
    end

    local contentWidth=G_VisibleSizeWidth
    local contentHeight=G_VisibleSizeHeight-125
    local contentLayer=self.list[troopIndex]
    if contentLayer==nil then
      contentLayer=CCLayer:create()
      contentLayer:setContentSize(CCSizeMake(contentWidth,contentHeight))
      self.list[troopIndex]=contentLayer
    end
    local iconTag,nameTag,strengthTag,notSavedTag,nameLbTag=6,8,10,11,15
    local mIcon=tolua.cast(contentLayer:getChildByTag(iconTag),"CCSprite")
    if mIcon then
      mIcon:removeFromParentAndCleanup(true)
      mIcon=nil
    end
    mIcon=CCSprite:create(troopPic)
    mIcon:setAnchorPoint(ccp(0.5,0.5))
    mIcon:setPosition(ccp(contentWidth/2,G_VisibleSizeHeight-228))
    contentLayer:addChild(mIcon,1)
    mIcon:setTag(iconTag)
    local nameBg,nameLb=tolua.cast(contentLayer:getChildByTag(nameTag),"CCSprite"),tolua.cast(contentLayer:getChildByTag(nameLbTag),"CCLabelTTF")
    if nameBg==nil then
      local nameBgWidth,nameBgHeight=220,60
      nameBg=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
      nameBg:setAnchorPoint(ccp(0.5,0.5))
      nameBg:setScaleX(nameBgWidth/nameBg:getContentSize().width)
      nameBg:setScaleY(nameBgHeight/nameBg:getContentSize().height)
      nameBg:setPosition(ccp(contentWidth/2,mIcon:getPositionY()-nameBgHeight/2-60))
      nameBg:setFlipY(true)
      nameBg:setTag(nameTag)
      contentLayer:addChild(nameBg,2)

      nameLb=GetTTFLabelWrap(troopNameStr,20,CCSizeMake(contentWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
      nameLb:setAnchorPoint(ccp(0.5,1))
      nameLb:setTag(nameLbTag)
      nameLb:setPosition(ccp(contentWidth/2,nameBg:getPositionY()+nameBgHeight/2-5))
      contentLayer:addChild(nameLb,3)
      if isBattle==true then
        nameLb:setColor(G_LowfiColorRed2)
      end
    end
    local strengthLb,strengthStr=tolua.cast(contentLayer:getChildByTag(strengthTag),"CCLabelTTF"),getlocal("emblem_troop_washStrength",{washStrength})
    if strengthLb==nil then
      strengthLb=GetTTFLabel(strengthStr,18)
      strengthLb:setAnchorPoint(ccp(0.5,1))
      strengthLb:setPosition(ccp(contentWidth/2,nameLb:getPositionY()-nameLb:getContentSize().height-5))
      strengthLb:setColor(G_ColorYellowPro)
      contentLayer:addChild(strengthLb,3)
      strengthLb:setTag(strengthTag)
    else
      strengthLb:setString(strengthStr)
    end
    --刷新未保存训练的训练度状态
    local notSavedStrength=troopVo:getWashStrengthNotSaved()
    local strengthNotSavedLb=tolua.cast(contentLayer:getChildByTag(notSavedTag),"CCLabelTTF")
    if strengthNotSavedLb==nil then
      strengthNotSavedLb=GetTTFLabel("",18)
      strengthNotSavedLb:setAnchorPoint(ccp(0,1))
      contentLayer:addChild(strengthNotSavedLb,3)
      strengthNotSavedLb:setTag(notSavedTag)
    end
    strengthNotSavedLb:setPosition(ccp(strengthLb:getPositionX()+strengthLb:getContentSize().width/2+10,strengthLb:getPositionY()))  
    if notSavedStrength==0 then
      strengthNotSavedLb:stopAllActions()
      strengthNotSavedLb:setVisible(false)
    else
      strengthNotSavedLb:setVisible(true)
      notSavedStrength=notSavedStrength-washStrength
      if notSavedStrength>0 then
        strengthNotSavedLb:setString("+"..tostring(notSavedStrength))
        strengthNotSavedLb:setColor(G_ColorGreen)
      else
        strengthNotSavedLb:setString(tostring(notSavedStrength))
        strengthNotSavedLb:setColor(G_LowfiColorRed2)
      end 
      local fadeIn=CCFadeTo:create(1.5,255)
      local fadeOut=CCFadeTo:create(1.5,80)
      local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
      strengthNotSavedLb:runAction(CCRepeatForever:create(seq))        
    end

    --刷新部队的解锁状态
    local iconStartX=contentLayer:getContentSize().width/2-120*2
    local unlockCfg=emblemTroopVoApi:getTroopEquipPosUnlockCfg()
    if unlockCfg then
      local unlockNum=SizeOfTable(unlockCfg)
      local function clickUnlockIcon(hd,fn,idx)
        require "luascript/script/game/scene/gamedialog/emblem/emblemTroopSmallDialog"
        emblemTroopSmallDialog:showEmblemTroopUnlockDialog(self.layerNum+1,idx-20)
      end
      local unlockPosCfg={ccp(97,238),ccp(97,369),ccp(545,238),ccp(545,369)}
      for i=1,unlockNum do
        local unlockIcon,grayBgSp=tolua.cast(contentLayer:getChildByTag(20+i),"CCSprite"),nil
        if unlockIcon==nil then
          local pos=unlockPosCfg[i]
          unlockIcon=LuaCCSprite:createWithSpriteFrameName("emTroop_unlock"..i..".png",clickUnlockIcon)
          unlockIcon:setPosition(pos.x,G_VisibleSizeHeight-pos.y)
          contentLayer:addChild(unlockIcon)
          unlockIcon:setTag(20+i)
          unlockIcon:setTouchPriority(-(self.layerNum-1)*20-4)

          grayBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
          grayBgSp:setAnchorPoint(ccp(0.5,0.5))
          grayBgSp:setContentSize(unlockIcon:getContentSize())
          grayBgSp:setPosition(getCenterPoint(unlockIcon))
          unlockIcon:addChild(grayBgSp)
          grayBgSp:setTag(1)

          local linePic,flipFlag,lpos
          if i==1 then
            linePic,flipFlag,lpos="emTroop_uiline1.png",false,ccp(189.5,G_VisibleSizeHeight-238)
          elseif i==2 then
            linePic,flipFlag,lpos="emTroop_uiline2.png",false,ccp(189.5,G_VisibleSizeHeight-320)
          elseif i==3 then
            linePic,flipFlag,lpos="emTroop_uiline1.png",false,ccp(450.5,G_VisibleSizeHeight-238)
          elseif i==4 then
            linePic,flipFlag,lpos="emTroop_uiline2.png",true,ccp(450.5,G_VisibleSizeHeight-320)
          end
          if i==2 or i==4 then
            linePic="emTroop_uiline2.png"
          end
          if linePic and lpos then
            local lineSp=CCSprite:createWithSpriteFrameName(linePic)
            lineSp:setPosition(lpos)
            lineSp:setFlipX(flipFlag)
            contentLayer:addChild(lineSp)
          end
          local idxSp=CCSprite:createWithSpriteFrameName("emTroop_posIcon_"..i..".png")
          if idxSp then
            idxSp:setPosition(unlockIcon:getContentSize().width,0)
            unlockIcon:addChild(idxSp,2)
          end

          -- local unlockLb=GetTTFLabelWrap(getlocal("emblem_troop_unlock"..i),20,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
          -- unlockLb:setAnchorPoint(ccp(0.5,0.5))
          -- unlockLb:setPosition(ccp(unlockIcon:getPositionX(),unlockIcon:getPositionY()-unlockIcon:getContentSize().height/2-unlockLb:getContentSize().height/2-6))
          -- contentLayer:addChild(unlockLb)
        else
          grayBgSp=tolua.cast(unlockIcon:getChildByTag(1),"LuaCCScale9Sprite")
        end
        if unlockIcon and grayBgSp then
          if unlockCfg["q"..i].strNeed>masterMaxStrong then
            grayBgSp:setOpacity(180)
          else
            grayBgSp:setOpacity(0)
          end
        end
      end
    end

    --按钮操作
    local saveMenu,saveItem=tolua.cast(contentLayer:getChildByTag(13),"CCMenu"),nil
    if saveMenu==nil then
      local btnY=40
      local iphoneType=G_getIphoneType()
      if iphoneType==G_iphoneX or iphoneType==G_iphone5 then
        btnY=80
      end
      local btnScale,priority=0.8,-(self.layerNum-1)*20-3
      local function gotoWashAuto()
          self:gotoWashAuto(troopIndex)
      end
      local washAutoItem=G_createBotton(contentLayer,ccp(contentWidth/2-200,btnY),{getlocal("emblem_troop_washAuto")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",gotoWashAuto,btnScale,priority)

      local function gotoWash()
          self:gotoWash(troopIndex,self.washType)
      end
      local washItem=G_createBotton(contentLayer,ccp(contentWidth/2,btnY),{getlocal("emblem_troop_wash")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",gotoWash,btnScale,priority)

      local function gotoSave()
          self:gotoSaveWashData(troopIndex)
      end
      saveItem,saveMenu=G_createBotton(contentLayer,ccp(contentWidth/2+200,btnY),{getlocal("collect_border_save")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",gotoSave,btnScale,priority,nil,113)
      saveMenu:setTag(13)
    else
      saveItem=tolua.cast(saveMenu:getChildByTag(113),"CCMenuItemSprite")
    end
    if saveMenu and saveItem then
      if troopVo and troopVo.lastWashTb and SizeOfTable(troopVo.lastWashTb)>0 then
        saveItem:setEnabled(true)
      else
        saveItem:setEnabled(false)
      end
    end
    
    self:updateMasterAttribute(troopIndex) --刷新部队当前属性状态
    self:updateWashTypeShow(troopIndex) --刷新训练方式显示
    self:updateWashCostShow(troopIndex) --刷新训练消耗显示

    return contentLayer
end

function emblemTroopWashDialog:updateMasterAttribute(troopIndex)
    local contentLayer=self.list[troopIndex]
    if contentLayer==nil then
      do return end
    end
    local troopId=self.troopList[troopIndex].id
    local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
    if troopVo==nil then
      do return end
    end
    local contentWidth=contentLayer:getContentSize().width
    local addSavedTb=troopVo.addSavedTb
    local addTb=troopVo.lastWashTb
    local attrBgTag=5
    local bgWidth,bgHeight=contentLayer:getContentSize().width-40,280
    local attributeBg=tolua.cast(contentLayer:getChildByTag(attrBgTag),"CCSprite")
    if attributeBg==nil then
      local function cellClick(hd,fn,index)
      end
      attributeBg=LuaCCScale9Sprite:createWithSpriteFrameName("emTroop_panelBg.png",CCRect(54, 32, 2, 2),cellClick)
      attributeBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
      attributeBg:setAnchorPoint(ccp(0.5,1))
      attributeBg:setPosition(ccp(contentWidth/2,contentLayer:getContentSize().height/2+80))
      attributeBg:setTag(attrBgTag)
      contentLayer:addChild(attributeBg,4)

      local titleBgWidth,titleBgHeight=250,35
      local titleBg=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
      titleBg:setAnchorPoint(ccp(0.5,0))
      titleBg:setScaleX(titleBgWidth/titleBg:getContentSize().width)
      titleBg:setScaleY(titleBgHeight/titleBg:getContentSize().height)
      titleBg:setPosition(bgWidth/2,bgHeight-titleBgHeight)
      attributeBg:addChild(titleBg,2)

      local addTitlelb=GetTTFLabelWrap(getlocal("emblem_troop_attribute"),20,CCSizeMake(contentWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
      addTitlelb:setAnchorPoint(ccp(0.5,0))
      addTitlelb:setPosition(titleBg:getPositionX(),titleBg:getPositionY()+5)
      attributeBg:addChild(addTitlelb,3)
    end

    local attributeTb=emblemTroopVoApi:getTroopBaseAttributeType()
    local attPosY=bgHeight-50
    local barWidth,barHeight=350,14
    for k,attType in pairs(attributeTb) do
      local maxValue=emblemTroopVoApi:getTroopWashMaxValueByType(self.washType,attType)
      if maxValue then
        local cValue,value,addValue=0,0,0
        if addSavedTb and addSavedTb[attType] then
           cValue=addSavedTb[attType]
        end
        if addTb and addTb[attType] then
          value=addTb[attType]
        end
        if value>0 then
          addValue=(value*1000-cValue*1000)/1000
        end
        local bgTag,curTag,changeTag=k*10+1,k*10+2,k*10+3
        local timerSpriteBg=tolua.cast(attributeBg:getChildByTag(bgTag),"CCSprite")
        if timerSpriteBg==nil then
          local nameStr=""
          local attribute=G_getAttributeInfoByType(attType)
          if attribute then
            nameStr=getlocal(attribute.name)..":"
          end

          local sizeWidth = bgWidth-60
          if G_getCurChoseLanguage() == "ar" then
            sizeWidth = 80
          end
 
          local nameLb=GetTTFLabelWrap(nameStr,20,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
          nameLb:setAnchorPoint(ccp(0,0.5))
          nameLb:setPosition(ccp(20,attPosY))
          attributeBg:addChild(nameLb,1)


          timerSpriteBg=LuaCCScale9Sprite:createWithSpriteFrameName("emTroop_barBg.png",CCRect(6,6,2,2),function ()end)
          timerSpriteBg:setAnchorPoint(ccp(0.5,0.5))
          timerSpriteBg:setContentSize(CCSizeMake(barWidth,barHeight))
          timerSpriteBg:setPosition(ccp(bgWidth/2,attPosY))
          timerSpriteBg:setTag(bgTag)
          attributeBg:addChild(timerSpriteBg,2)
        end
        local addStartX=timerSpriteBg:getPosition()-timerSpriteBg:getContentSize().width/2
        --当前属性值进度
        local curProgressSp,changeRateSp=tolua.cast(attributeBg:getChildByTag(curTag),"CCSprite"),tolua.cast(attributeBg:getChildByTag(changeTag),"CCSprite")
        if curProgressSp==nil then
          if cValue and cValue>0 then
            curProgressSp=LuaCCScale9Sprite:createWithSpriteFrameName("emTroop_bar.png",CCRect(1,1,12,12),function ()end)
            -- curProgressSp=CCSprite:createWithSpriteFrameName("emTroop_bar.png")
            curProgressSp:setAnchorPoint(ccp(0,0.5))
            curProgressSp:setPosition(addStartX,attPosY)
            curProgressSp:setTag(curTag)
            attributeBg:addChild(curProgressSp,3)
          end
        end
        if curProgressSp then
          local curBarWidth=math.min(cValue/maxValue,1)*barWidth
          if curBarWidth<1 then
            curProgressSp:setContentSize(CCSizeMake(1,barHeight))
          else
            curProgressSp:setContentSize(CCSizeMake(curBarWidth,barHeight))
          end
          curProgressSp:setScaleX(curBarWidth/curProgressSp:getContentSize().width)
          addStartX=addStartX+curBarWidth
        end

        --本次训练属性值变化
        local barPic,changeBarW
        if addValue and addValue~=0 then
          if addValue>0 then
            barPic="emTroop_barGreen.png"
            changeBarW=math.min(maxValue-cValue,addValue)/maxValue*barWidth
            addStartX=addStartX-0.5 --进度条衔接不太好，所以往前移0.5个像素
          else
            barPic="emTroop_barRed.png"
            changeBarW=math.min(cValue,math.abs(addValue))/maxValue*barWidth
          end
        end
        if changeRateSp then
          changeRateSp:removeFromParentAndCleanup(true)
          changeRateSp=nil
        end
        if barPic and changeBarW then
          changeRateSp=LuaCCScale9Sprite:createWithSpriteFrameName(barPic,CCRect(1,1,12,12),function ()end)
          -- changeRateSp=CCSprite:createWithSpriteFrameName(barPic)
          if addValue>0 then
            changeRateSp:setAnchorPoint(ccp(0,0.5))
          else
            changeRateSp:setAnchorPoint(ccp(1,0.5))
          end
          changeRateSp:setTag(changeTag)
          attributeBg:addChild(changeRateSp,4)
          changeRateSp:setPosition(ccp(addStartX,attPosY))
          if changeBarW<1 then
            changeRateSp:setContentSize(CCSizeMake(1,barHeight))
          else
            changeRateSp:setContentSize(CCSizeMake(changeBarW,barHeight))
          end
          changeRateSp:setScaleX(changeBarW/changeRateSp:getContentSize().width)
          local fadeIn=CCFadeTo:create(1.5,255)
          local fadeOut=CCFadeTo:create(1.5,80)
          local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
          changeRateSp:runAction(CCRepeatForever:create(seq))
        end
        
        local valueStr,maxValueStr,changeStr
        if attType~="troopsAdd" and attType~="first" then
          valueStr=(cValue*100).."%%"
          maxValueStr=(maxValue*100).."%%"
          changeStr=(addValue*100).."%"
        else
          valueStr=tostring(cValue)
          maxValueStr=tostring(maxValue)
          changeStr=tostring(addValue)
        end

        local percentTag,addValueTag=k*10+4,k*10+5
        local percentStr=getlocal("scheduleChapter",{valueStr,maxValueStr})
        local percentLb,changeLb=tolua.cast(attributeBg:getChildByTag(percentTag),"CCLabelTTF"),tolua.cast(attributeBg:getChildByTag(addValueTag),"CCLabelTTF")
        if percentLb==nil then
          percentLb=GetTTFLabel(percentStr,18)
          percentLb:setAnchorPoint(ccp(0.5,0.5))
          percentLb:setPosition(ccp(timerSpriteBg:getPositionX(),attPosY))
          percentLb:setTag(percentTag)
          attributeBg:addChild(percentLb,5)
        end
        percentLb:setString(percentStr)
        if addValue>=0 then
          changeStr="+"..changeStr
        end
        if changeLb==nil then
          changeLb=GetTTFLabel(changeStr,20)
          changeLb:setAnchorPoint(ccp(0,0.5))
          changeLb:setPosition(ccp(bgWidth-90,attPosY))
          changeLb:setTag(addValueTag)
          attributeBg:addChild(changeLb,6)
        end
        changeLb:setString(changeStr)
        if addValue>0 then
          changeLb:setColor(G_ColorGreen)
        elseif addValue<0 then
          changeLb:setColor(G_LowfiColorRed2)
        else
          changeLb:setColor(G_ColorWhite)
        end
        changeLb:stopAllActions()
        if addValue~=0 then
          local fadeIn=CCFadeTo:create(1.5,255)
          local fadeOut=CCFadeTo:create(1.5,80)
          local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
          changeLb:runAction(CCRepeatForever:create(seq)) 
        end
        attPosY=attPosY-40
      end
    end
end

--刷新训练方式
function emblemTroopWashDialog:updateWashTypeShow(troopIndex)
  local contentLayer=self.list[troopIndex]
  if contentLayer==nil then
    do return end
  end
  local checkY,costY=175,95
  local iphoneType=G_getIphoneType()
  if iphoneType==G_iphoneX or iphoneType==G_iphone5 then
    checkY,costY=260,160
  end
  --对应训练方式的剩余次数刷新
  local function refreshTimesLb()
    local usedTimes=emblemTroopVoApi:getTroopWashTimes(self.washType)
    local maxTimes=emblemTroopVoApi:getTroopWashMaxTimes(self.washType)
    local lastTimes=0
    if maxTimes>usedTimes then
        lastTimes=maxTimes-usedTimes
    end
    local checkLbTag=100+self.washType
    local timesStr="("..getlocal("activity_newyearseve_prompt1_1",{lastTimes})..")"
    local checkLb,timesLb=tolua.cast(contentLayer:getChildByTag(checkLbTag),"CCLabelTTF"),tolua.cast(contentLayer:getChildByTag(30),"CCLabelTTF")
    if timesLb==nil then
      timesLb=GetTTFLabel("",22)
      timesLb:setAnchorPoint(ccp(0,0.5))
      timesLb:setTag(30)
      contentLayer:addChild(timesLb)
    end
    if timesLb and checkLb then
      timesLb:setString(timesStr)
      if lastTimes==0 then
        timesLb:setColor(G_LowfiColorRed2)
      else
        timesLb:setColor(G_ColorYellowPro)
      end
      timesLb:setPosition(checkLb:getPositionX()+checkLb:getContentSize().width,checkLb:getPositionY())
    end
  end
  --训练方式
  local contentWidth=contentLayer:getContentSize().width
  local washCfg=emblemTroopVoApi:getTroopWashCfg()
  local maxLen=SizeOfTable(washCfg)
  local checkIconTb={}
  local oneSpace=(contentWidth-20)/maxLen
  for i=1,maxLen do
    local checkBgTag,checkLbTag=i,100+i
    local checkBg,checkIcon,checkLb=tolua.cast(contentLayer:getChildByTag(checkBgTag),"CCSprite"),nil,tolua.cast(contentLayer:getChildByTag(checkLbTag),"CCLabelTTF")
    if checkBg==nil then
      local function checkClick(hd,fn,idx)
        self.washType=idx
        self:updateWashCostShow(troopIndex)
        self:updateWashTypeShow(troopIndex)
        for j=1,maxLen do
          if j==self.washType then
             checkIconTb[j]:setVisible(true)
          else
             checkIconTb[j]:setVisible(false)
          end
        end
        refreshTimesLb()
      end
      checkBg=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",checkClick)
      checkBg:setAnchorPoint(ccp(0,0.5))
      checkBg:setTouchPriority(-(self.layerNum-1)*20-4)
      checkBg:setPosition(ccp(30+(i-1)*oneSpace,checkY))
      contentLayer:addChild(checkBg)
      checkBg:setTag(checkBgTag)
      checkIcon=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
      checkIcon:setPosition(getCenterPoint(checkBg))
      checkBg:addChild(checkIcon)
      checkIcon:setTag(1)
      checkIconTb[i]=checkIcon

      checkLb=GetTTFLabel(getlocal("emblem_troop_washType"..i),22)
      checkLb:setAnchorPoint(ccp(0,0.5))
      checkLb:setPosition(ccp(checkBg:getPositionX()+checkBg:getContentSize().width+5,checkY))
      checkLb:setTag(checkLbTag)
      contentLayer:addChild(checkLb)
    end
    checkIcon=tolua.cast(checkBg:getChildByTag(1),"CCSprite")
    if checkIcon then
      if i~=self.washType then
        checkIcon:setVisible(false)
      else
        checkIcon:setVisible(true)
      end
    end
    refreshTimesLb()
  end
end

--刷新训练消耗的显示
function emblemTroopWashDialog:updateWashCostShow(troopIndex)
  local contentLayer=self.list[troopIndex]
  if contentLayer==nil then
    do return end
  end
  local costY=110
  local iphoneType=G_getIphoneType()
  if iphoneType==G_iphoneX or iphoneType==G_iphone5 then
    costY=160
  end
  local function addPropHandler()
    if self.washType==1 then
      self:addPropHandler(troopIndex)
    end
  end
  local contentWidth=contentLayer:getContentSize().width
  local costReward=emblemTroopVoApi:getTroopWashCost(self.washType)
  local costBg=tolua.cast(contentLayer:getChildByTag(50),"LuaCCScale9Sprite")
  if costBg==nil then
      costBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),addPropHandler)
      costBg:setTouchPriority(-(self.layerNum-1)*20-4)
      costBg:setAnchorPoint(ccp(0.5,0.5))
      costBg:setOpacity(0)
      costBg:setTag(50)
      contentLayer:addChild(costBg,2)
  end
  local iconTag,lbTag,addBtnTag=20,30,66
  local costWidth=0
  local costIcon,costLb,addBtn=tolua.cast(costBg:getChildByTag(iconTag),"CCSprite"),tolua.cast(costBg:getChildByTag(lbTag),"CCLabelTTF"),tolua.cast(costBg:getChildByTag(addBtnTag),"CCSprite")
  if costReward then
    if costIcon then
      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(costReward.pic)
      if frame then
        costIcon:setDisplayFrame(frame)
      end
    else
      costIcon=CCSprite:createWithSpriteFrameName(costReward.pic)
      costIcon:setAnchorPoint(ccp(0,0.5))
      costBg:addChild(costIcon)
      costIcon:setTag(iconTag)
    end
    if costLb then
      costLb:setString(costReward.num)
    else
      costLb=GetTTFLabel(costReward.num,22)
      costLb:setAnchorPoint(ccp(0,0.5))
      costLb:setTag(lbTag)
      costBg:addChild(costLb)
    end
    if self.washType==1 then
      if addBtn==nil then
        addBtn=CCSprite:createWithSpriteFrameName("believerAddBtn.png")
        addBtn:setAnchorPoint(ccp(0,0.5))
        addBtn:setColor(ccc3(135,253,139))
        addBtn:setTag(addBtnTag)
        costBg:addChild(addBtn)
      end
      costWidth=costWidth+addBtn:getContentSize().width+10
    end
    local hadNum=0
    if costReward.key=="gems" then
        hadNum=playerVoApi:getGems()
    else
        hadNum=bagVoApi:getItemNumId(costReward.id)
    end
    if hadNum<costReward.num then
      costLb:setColor(G_LowfiColorRed2)
    else
      costLb:setColor(G_ColorWhite)
    end
    costWidth=costWidth+costLb:getContentSize().width+costIcon:getContentSize().width
    costBg:setContentSize(CCSizeMake(costWidth,40))
    costBg:setPosition(contentWidth/2,costY)
    costIcon:setPosition(0,costBg:getContentSize().height/2)
    costLb:setPosition(costIcon:getPositionX()+costIcon:getContentSize().width,costBg:getContentSize().height/2)
    if addBtn then
      if self.washType==1 then
        addBtn:setVisible(true)
        addBtn:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())
      else
        addBtn:setVisible(false)
        addBtn:setPosition(999,0)
      end
    end
  end
end

--刷新当前道具的数量
function emblemTroopWashDialog:refreshCurResShow()
  if self.costShowTb then
    for k,v in pairs(self.costShowTb) do
      if v then
        local costReward=v[2]
        local hadNum=0
        if costReward.key=="gems" then
          hadNum=playerVoApi:getGems()
        else
          hadNum=bagVoApi:getItemNumId(costReward.id)
        end
        local costLb=tolua.cast(v[1],"CCLabelTTF")
        costLb:setString(FormatNumber(hadNum))

        if hadNum<costReward.num then
          costLb:setColor(G_LowfiColorRed2)
        else
          costLb:setColor(G_ColorWhite)
        end
      end
    end
  end
end

function emblemTroopWashDialog:gotoWashAuto(troopIndex)
  local troopId=self.troopList[troopIndex].id
  local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
  if troopVo and troopVo:checkIfBattled()==true then
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_battleTip"),30)
      do return end
  end

  local function callBack()
    self:update(troopIndex)
  end
  -- emblemTroopVoApi:troopWashAuto(troopId,self.washType,4,{1,0,0,0,0,0,0},callBack)
  -- do return end
  require "luascript/script/game/scene/gamedialog/purifying/begingPurifyingDialog"
  local td=begingPurifyingDialog:new(self,troopVo,nil,nil,callBack,2)
  local tbArr={}
  local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("emblem_troop_washBegin"),true,self.layerNum+1)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function emblemTroopWashDialog:gotoWash(troopIndex)
  local troopId=self.troopList[troopIndex].id
  local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
  if troopVo and troopVo:checkIfBattled()==true then
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_battleTip"),30)
      do return end
  end

  local function sureHandler()
    local costItem=emblemTroopVoApi:getTroopWashCost(self.washType)
    if costItem and costItem.key=="gems" or costItem.key=="gem" then
      local ownNum=playerVoApi:getGems()
      if costItem.num>ownNum then
        local function goRecharge()
          activityAndNoteDialog:closeAllDialog()
          vipVoApi:showRechargeDialog(self.layerNum+1)
        end
        GemsNotEnoughDialog(nil,nil,costItem.num-ownNum,self.layerNum+1,ownNum,goRecharge)
        do return end
      end
    elseif costItem and costItem.type=="p" then
      local ownNum=bagVoApi:getItemNumId(costItem.id)
      if costItem.num>ownNum then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newTech_pNotEnought"),30)
        do return end
      end
    end
    local usedTimes=emblemTroopVoApi:getTroopWashTimes(self.washType)
    local maxTimes=emblemTroopVoApi:getTroopWashMaxTimes(self.washType)
    if usedTimes>=maxTimes then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_wash_limitMax"),30)
    else
      local function realWash()
        local function callBack()
          self:update(troopIndex)
        end
        emblemTroopVoApi:troopWash(troopVo.id,self.washType,callBack)
      end
      local popKey="emtroop_onceWash"
      local function secondTipFunc(sbFlag)
        local sValue=base.serverTime .. "_" .. sbFlag
        G_changePopFlag(popKey,sValue)
      end
      if self.washType==2 and G_isPopBoard(popKey) then --金币训练的时候给出二次确认弹窗
        local tipStr=getlocal("second_tip_des",{costItem.num})
        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),tipStr,true,realWash,secondTipFunc)
      else
        realWash()
      end
    end
  end
  if troopVo and troopVo:checkIfOneAttUp()==true then     
    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("emblem_troop_wash_noSave"),false,sureHandler)
  else
    sureHandler()
  end
end

function emblemTroopWashDialog:gotoSaveWashData(troopIndex)
  local troopId=self.troopList[troopIndex].id
  local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
  if troopVo and (troopVo.lastWashTb and SizeOfTable(troopVo.lastWashTb)==0) or (troopVo.lastWashTb==nil) then
    do return end
  end
  if troopVo and troopVo:checkIfBattled()==true then
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_battleTip"),30)
      do return end
  end
  local function sureHandler( )
      local function callBack()
        self:update(troopIndex)
      end
      emblemTroopVoApi:troopWashSave(troopVo.id,callBack)  
  end
  G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("toSaveHandleStr"),false,sureHandler)
end

function emblemTroopWashDialog:update(troopIndex)
    local troopId=self.troopList[troopIndex].id
    local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
    self:updateTroopDetail(troopIndex)
    self:refreshCurResShow()
    if self.parentDialog and self.parentDialog.update then
      self.parentDialog:update(troopIndex)
    end
end

--添加训练消耗的道具
function emblemTroopWashDialog:addPropHandler(troopIndex)
  local shopIdx="i1"
  local shopCfg=emblemTroopCfg.shopList[shopIdx]
  local reward=FormatItem(shopCfg.reward)[1]
  local costTb=FormatItem(shopCfg.cost[1])
  local buyNum=emblemTroopVoApi:getShopItemBuyNum(shopIdx)
  local limitNum=shopCfg.limit
  local costItem=costTb[1]
  local num=playerVo[costItem.key]
  if num<costItem.num then --资源不够
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("resourcelimit"),30)
    do return end
  end
  if buyNum>=limitNum then --今日购买次数已达上限
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_exchangelimit"),30)
    do return end
  end
  local function touchBuy(count)
    local function realBuy()
      local function buyHandler()
        G_addPlayerAward(reward.type,reward.key,reward.id,reward.num*count)
        for k,v in pairs(costTb) do
          if v.type=="u" then
            playerVoApi:setValue(v.key,playerVo[v.key]-tonumber(v.num*count))
          elseif v.type=="p" then
            bagVoApi:useItemNumId(v.id,tonumber(v.num*count))
          end
        end
        self:updateWashCostShow(troopIndex)
        self:refreshCurResShow()
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
      end
      emblemTroopVoApi:emblemTroopShopExchange(shopIdx,count,buyHandler)
    end
    local popKey="emtroop_buyprop"
    local function secondTipFunc(sbFlag)
      local sValue=base.serverTime .. "_" .. sbFlag
      G_changePopFlag(popKey,sValue)
    end
    if G_isPopBoard(popKey) then
      local costItem=costTb[1]
      local tipStr=getlocal("emblem_troop_buyTop",{count*costItem.num,costItem.name,reward.name})
      G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),tipStr,true,realBuy,secondTipFunc)
    else
      realBuy()
    end
  end
  shopVoApi:showBatchBuyPropSmallDialog(reward.key,self.layerNum+1,touchBuy,nil,limitNum-buyNum,nil,costTb)
end

function emblemTroopWashDialog:refresh()
  self:update(self.showIndex)
end

function emblemTroopWashDialog:refreshType()
end

function emblemTroopWashDialog:tick()
end

function emblemTroopWashDialog:dispose()
  CCTextureCache:sharedTextureCache():removeTextureForKey("public/superEquip/emTroop_bg.jpg")
  spriteController:removePlist("public/emblem/emblemTroopImages.plist")
  spriteController:removeTexture("public/emblem/emblemTroopImages.png")
  spriteController:removePlist("public/vipFinal.plist")
  spriteController:removeTexture("public/vipFinal.png")
  spriteController:removePlist("public/squaredImgs.plist")
  spriteController:removeTexture("public/squaredImgs.png")
  self.parentDialog=nil
  self.list=nil
  self.troopList=nil--当前展示的装备大师列表
  self.troopLayer=nil
  self.washType=nil
  self.showIndex=nil
  self.costShowTb=nil
end