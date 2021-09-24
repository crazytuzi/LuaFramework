--军徽部队详情面板
emblemTroopDialog=commonDialog:new()

function emblemTroopDialog:new(parentDialog,showIndex)  
  local nc={
    parentDialog=parentDialog,
    list=nil,
    troopList=nil,--当前展示的装备大师列表
    troopPageLayer=nil,
    showSkillList=nil,
    showIndex=showIndex,--显示第几个大师
  }
    setmetatable(nc,self)
    self.__index=self

    return nc
end
--设置对话框里的tableView
function emblemTroopDialog:initTableView()
  self.panelLineBg:setVisible(false)
  local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
  panelBg:setAnchorPoint(ccp(0.5,0))
  panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
  panelBg:setPosition(G_VisibleSizeWidth/2,5)
  self.bgLayer:addChild(panelBg)

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


  local function onTouchInfo()
      if G_checkClickEnable()==false then
          do return end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      local tipsSize=25
      if G_isAsia()==false then
          tipsSize=20
      end
      local placeGet=emblemTroopVoApi:getEmblemTroopPlaceGetCfg()
      local placeStr = ""
      for k,v in pairs(placeGet) do
        if k==3 then
          placeStr=placeStr..(v*100).."%%"
        else
          placeStr=placeStr..(v*100).."%%"..", "
        end
      end
      local tabStr = {getlocal("emblem_troop_info1"),getlocal("emblem_troop_info2"),getlocal("emblem_troop_info3",{placeStr}),getlocal("emblem_troop_info4")}
      local titleStr=getlocal("activity_baseLeveling_ruleTitle")
      require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
      tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,tipsSize)
  end

  local infoItem=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",onTouchInfo,11,nil,nil)
  infoItem:setAnchorPoint(ccp(1,1))
  local infoBtn=CCMenu:createWithItem(infoItem)
  infoBtn:setPosition(ccp(bg:getContentSize().width-20,bg:getContentSize().height-20))
  infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
  bg:addChild(infoBtn)
end

--用户处理特殊需求,没有可以不写此方法
function emblemTroopDialog:doUserHandler()
    self.list={}
    self.troopList=emblemTroopVoApi:getEmblemTroopListWithSort()
    local len=0
    if self.troopList then
      len=SizeOfTable(self.troopList)
    end
    if len>0 then
      for i=1,len do
          local layer=self:initTroopDetail(i)
          self.list[i]=layer--要放在下面刷新内容的前面
          self:updateTroopPos(i)
          self:updateTroopAdd(i)
          layer:setAnchorPoint(ccp(0,0))
          layer:setPosition(ccp(0,0))
          self.bgLayer:addChild(layer,1)
      end

      local function checkSkillTvIsScrolled()
        local contentLayer=self.list[self.showIndex]
        if contentLayer then
          local skillBg=tolua.cast(contentLayer:getChildByTag(15),"LuaCCScale9Sprite")
          if skillBg then
            local skillTv=tolua.cast(skillBg:getChildByTag(1),"LuaCCTableView")
            if skillTv and skillTv:getScrollEnable()==true and skillTv:getIsScrolled()==true then
              return true
            end
          end
        end
      end

      -- 检测边界
      local function checkBound(toType,isTouch)
          -- 往左(减)
          if toType==1 then
              -- 如果达到最大值，则无法左滑
              if self.showIndex>1 then
                  if not checkSkillTvIsScrolled() then
                    return true
                  end
              end 
          else -- 往右(加)
              if self.showIndex<len then -- 第一页为最新的，则无法往右
                  if not checkSkillTvIsScrolled() then
                    return true
                  end
              end
          end
          return false
      end
      require "luascript/script/componet/pageDialog"
      self.troopPageLayer=pageDialog:new()
      local isShowBg=false
      local isShowPageBtn=true

      local function updateBtnByPage(selectPage)
        if self.troopPageLayer then
            if len <= 1 then
                self.troopPageLayer:setBtnEnabled(1,false)
                self.troopPageLayer:setBtnEnabled(2,false)
            elseif selectPage>=len then
                self.troopPageLayer:setBtnEnabled(2,false)
                self.troopPageLayer:setBtnEnabled(1,true)
            elseif selectPage<=1 then
                self.troopPageLayer:setBtnEnabled(1,false)
                self.troopPageLayer:setBtnEnabled(2,true)
            else
                self.troopPageLayer:setBtnEnabled(1,true)
                self.troopPageLayer:setBtnEnabled(2,true)
            end
        end
      end

      local function onPage(topage)
        self.showIndex=topage
        self:updateTroopDetail(topage)
        updateBtnByPage(topage)
      end
      local posY=G_VisibleSizeHeight-220
      local leftBtnPos=ccp(40,posY)
      local rightBtnPos=ccp(G_VisibleSizeWidth-40,posY)
      self.troopPageLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,self.showIndex,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,checkBound,nil,nil,"leftBtnGreen.png")
      updateBtnByPage(self.showIndex)
    end
end

function emblemTroopDialog:initTroopDetail(troopIdx)
    local contentLayer=CCLayer:create()--CCLayerColor:create(ccc4(255,0,0,100))--
    local contentWidth=G_VisibleSizeWidth
    local contentHeight=G_VisibleSizeHeight-130
    contentLayer:setContentSize(CCSizeMake(contentWidth,contentHeight))

    local troopId=self.troopList[troopIdx].id
    local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
    if troopVo then
      local troopPic=troopVo:getIconPic()
      local masterName=troopVo:getName()
      local masterStrong=troopVo:getTroopStrength()--强度
      local isBattle=troopVo:checkIfBattled()
      if isBattle==true then
        masterName= masterName.."("..getlocal("emblem_battle")..")"
      end
      if self.showSkillList==nil then
        self.showSkillList={}
      end
      self.showSkillList[troopIdx]=troopVo:getSkillTb()
      local mIcon=CCSprite:create(troopPic)
      mIcon:setAnchorPoint(ccp(0.5,1))
      mIcon:setPosition(ccp(contentWidth/2,contentHeight))
      contentLayer:addChild(mIcon,1)
      mIcon:setTag(6)

      local nameBg=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
      nameBg:setAnchorPoint(ccp(0.5,0.5))
      nameBg:setPosition(ccp(contentWidth/2,contentHeight-mIcon:getContentSize().height))
      nameBg:setRotation(180)
      nameBg:setScaleX(2)
      contentLayer:addChild(nameBg,2)

      local nameLb=GetTTFLabelWrap(masterName,20,CCSizeMake(contentWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
      nameLb:setAnchorPoint(ccp(0.5,0.5))
      nameLb:setPosition(ccp(nameBg:getPositionX(),nameBg:getPositionY()+2))
      contentLayer:addChild(nameLb,2)
      if isBattle==true then
        nameLb:setColor(G_LowfiColorRed2)
      end

      local strongLb=GetTTFLabelWrap(getlocal("alliance_boss_degree",{masterStrong}),18,CCSizeMake(contentWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
      strongLb:setAnchorPoint(ccp(0.5,1))
      strongLb:setColor(G_ColorYellowPro)
      strongLb:setPosition(ccp(contentWidth/2,nameLb:getPositionY()-nameLb:getContentSize().height/2-5))
      contentLayer:addChild(strongLb,3)
      strongLb:setTag(20)

      local _h = 103
      if G_getIphoneType()==G_iphoneX then
        _h = 73
      end
      local addTitleBg=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
      addTitleBg:setAnchorPoint(ccp(0.5,0.5))
      addTitleBg:setPosition(ccp(contentWidth/2,contentHeight/2-_h+95-addTitleBg:getContentSize().height/2-20))
      addTitleBg:setScaleX(3)
      contentLayer:addChild(addTitleBg,7)

      local addTitlelb=GetTTFLabelWrap(getlocal("emblem_troop_attribute"),20,CCSizeMake(contentWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
      addTitlelb:setAnchorPoint(ccp(0.5,0.5))
      addTitlelb:setPosition(addTitleBg:getPositionX(),addTitleBg:getPositionY()+2)--标题占用30像素
      addTitlelb:setColor(G_ColorYellow)
      contentLayer:addChild(addTitlelb,7)

      
      local function cellClick(hd,fn,index)
      end
      local skillBgHeight=142
      if G_getIphoneType()==G_iphoneX then
        skillBgHeight=300
      elseif G_getIphoneType()==G_iphone5 then
        skillBgHeight=225
      end
      local skillBg=LuaCCScale9Sprite:createWithSpriteFrameName("emTroop_panelBg.png",CCRect(54, 54, 2, 2),cellClick)
      skillBg:setContentSize(CCSizeMake(contentWidth-40, skillBgHeight))
      skillBg:setAnchorPoint(ccp(0.5,0))
      skillBg:setPosition(ccp(contentWidth/2, 80))
      skillBg:setTag(15)
      contentLayer:addChild(skillBg,8)

      local skillTitleBg=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
      skillTitleBg:setAnchorPoint(ccp(0.5,0.5))
      skillTitleBg:setPosition(ccp(contentWidth/2,skillBg:getPositionY()+skillBgHeight-20))
      skillTitleBg:setScaleX(3)
      contentLayer:addChild(skillTitleBg,9)

      local skillTitlelb=GetTTFLabelWrap(getlocal("emblem_troop_skill"),20,CCSizeMake(contentWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
      skillTitlelb:setAnchorPoint(ccp(0.5,0.5))
      skillTitlelb:setPosition(ccp(skillTitleBg:getPositionX(), skillTitleBg:getPositionY()+2))
      skillTitlelb:setColor(G_ColorYellow)
      contentLayer:addChild(skillTitlelb,9)

      local noSkillLb=GetTTFLabel(getlocal("emblem_troop_noskill"),20)
      noSkillLb:setColor(G_ColorGray2)
      noSkillLb:setPosition(skillBg:getContentSize().width/2,(skillBg:getContentSize().height-20)/2)
      noSkillLb:setTag(101)
      skillBg:addChild(noSkillLb)

      local skillTb = self.showSkillList[troopIdx]
      if skillTb then
        if SizeOfTable(skillTb)==0 then
          noSkillLb:setVisible(true)
        else
          noSkillLb:setVisible(false)
        end

        local function eventHandler(handler,fn,idx,cel)
           if fn=="numberOfCellsInTableView" then
              return SizeOfTable(self.showSkillList[troopIdx])
           elseif fn=="tableCellSizeForIndex" then
              local skillId=self.showSkillList[troopIdx][idx+1][1]
              local skillLv=self.showSkillList[troopIdx][idx+1][2]
              local nameLb=GetTTFLabel(emblemVoApi:getEquipSkillNameById(skillId,skillLv),20)
              local descLb=GetTTFLabelWrap(emblemVoApi:getEquipSkillDesById(skillId,skillLv),20,CCSizeMake(skillBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
               return  CCSizeMake(skillBg:getContentSize().width,nameLb:getContentSize().height+descLb:getContentSize().height)
           elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                local skillId=self.showSkillList[troopIdx][idx+1][1] --  显示装备的技能信息
                local skillLv=self.showSkillList[troopIdx][idx+1][2]
                local nameLb=GetTTFLabel(emblemVoApi:getEquipSkillNameById(skillId,skillLv),20)
                local descLb=GetTTFLabelWrap(emblemVoApi:getEquipSkillDesById(skillId,skillLv),20,CCSizeMake(skillBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)

                local totalH=nameLb:getContentSize().height+descLb:getContentSize().height
                nameLb:setAnchorPoint(ccp(0,1))
                nameLb:setPosition(ccp(20,totalH))
                nameLb:setColor(G_ColorGreen)
                cell:addChild(nameLb)

                local icon=CCSprite:createWithSpriteFrameName("emTroop_point.png")
                cell:addChild(icon)
                icon:setPosition(ccp(10,totalH-nameLb:getContentSize().height/2))

                descLb:setAnchorPoint(ccp(0,0))
                descLb:setPosition(ccp(20,0))
                cell:addChild(descLb)
                return cell
           elseif fn=="ccTouchBegan" then
               -- self.isMoved=false
               return true
           elseif fn=="ccTouchMoved" then
               -- self.isMoved=true
           elseif fn=="ccTouchEnded"  then
           end
        end

        local hd= LuaEventHandler:createHandler(eventHandler)
        local skillTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(contentWidth-40,skillBgHeight-40),nil)
        -- skillBg:setTouchPriority(-(self.layerNum-1)*20-1)
        skillTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        skillTv:setPosition(ccp(0,0))
        skillBg:addChild(skillTv)
        skillTv:setMaxDisToBottomOrTop(120)
        skillTv:setTag(1)
      end
      local function gotoWash(tag,object)
          if G_checkClickEnable()==false then
              do
                  return
              end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
          end
          PlayEffect(audioCfg.mouseClick)

          require "luascript/script/game/scene/gamedialog/emblem/emblemTroopWashDialog"
          local troopIndex = troopIdx
          local listTb = emblemTroopVoApi:getEmblemTroopListWithSort()
          if listTb then
            for m, n in pairs(listTb) do
              if n.id==troopId then
                troopIndex = m
                break
              end
            end
          end
          local td=emblemTroopWashDialog:new(self,1,troopIndex)
          local tbArr={}
          local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("emblem_troop_washTitle"),true,self.layerNum+1)
          sceneGame:addChild(dialog,self.layerNum+1)
          -- 引导下一步
          if(otherGuideMgr and otherGuideMgr.isGuiding)then
              otherGuideMgr:toNextStep()
          end
      end
      local washItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",gotoWash,troopIdx,getlocal("emblem_troop_wash"),24/0.8,101)
      washItem:setScale(0.8)
      local washMenu=CCMenu:createWithItem(washItem)
      washMenu:setPosition(ccp(contentWidth/2,40))
      washMenu:setTouchPriority(-(self.layerNum-1)*20-3)
      contentLayer:addChild(washMenu)
      washMenu:setTag(troopIdx)
      if otherGuideMgr:checkGuide(77)==false then
        otherGuideMgr:setGuideStepField(77,washItem)
      end
    end
    return contentLayer
end

function emblemTroopDialog:updateTroopPos(troopIdx)
    local contentLayer=self.list[troopIdx]
    local troopId=self.troopList[troopIdx].id
    local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
    local equipedTb
    local equipedColor={0,0,0,0,0}
    if troopVo then
      equipedTb=troopVo.posTb--装备位信息
    end

    local function cellClick(hd,fn,index)
    end
    local equipBgWidth=contentLayer:getContentSize().width-40
    local equipBgHeight=150
    local bgPosY=contentLayer:getContentSize().height-275
    if G_getIphoneType()==G_iphoneX then
      bgPosY=bgPosY-110
    elseif G_getIphoneType()==G_iphone5 then
      bgPosY=bgPosY-80
    end

    local equipBg=LuaCCScale9Sprite:createWithSpriteFrameName("emTroop_pos_box.png",CCRect(69, 69, 2, 2),cellClick)
    equipBg:setContentSize(CCSizeMake(equipBgWidth, equipBgHeight))
    equipBg:setAnchorPoint(ccp(0.5,1))
    equipBg:setPosition(ccp(contentLayer:getContentSize().width/2, bgPosY))
    equipBg:setTag(5)
    contentLayer:addChild(equipBg,4)
    
    local function clickPosIcon(object,fn,tag)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      local equipId
      if equipedTb and equipedTb[tag] then
        equipId=equipedTb[tag]
      end
      if equipId and equipId~=0 then
        self:gotoUnSetSuperEquip(troopVo.id,tag,troopIdx)
      else
        self:gotoSetSuperEquip(troopVo.id,tag,troopIdx)
      end
    end

    local max=emblemTroopVoApi:getTroopMaxEquipNum()
    local oneSpace=170
    local startX=equipBgWidth/2-(oneSpace*max)/2
    for i=1,max do
      local equipId
      if equipedTb and equipedTb[i] then
        equipId=equipedTb[i]
      end

      local pic,addBtn,addBtnScale
      if equipId and equipId~=0 then
        local equipCfg=emblemVoApi:getEquipCfgById(equipId)
        if equipCfg then
          if equipCfg.color==1 then
            pic="emTroop_posBg_gray.png"
          elseif equipCfg.color==2 then
            pic="emTroop_posBg_green.png"
          elseif equipCfg.color==3 then
            pic="emTroop_posBg_blue.png"
          elseif equipCfg.color==4 then
            pic="emTroop_posBg_purple.png"
          elseif equipCfg.color==5 then
            pic="emTroop_posBg_orange.png"
          end
          equipedColor[equipCfg.color]=equipedColor[equipCfg.color]+1
          local equipPic=emblemVoApi:getEmblemPicNameById(equipId)
          if equipPic then
            addBtn=CCSprite:create(equipPic)
            addBtnScale=0.7
            if addBtn==nil then
              addBtn=CCSprite:createWithSpriteFrameName(equipPic)
              addBtnScale=0.8
            end
          end
        end  
      end
      if pic==nil then
        pic="emTroop_posBg_gray.png"
        local isUnlock=emblemTroopVoApi:checkIfPosUnlock(troopVo.id,i)
        if isUnlock==false then
          addBtn=CCSprite:createWithSpriteFrameName("emTroop_lock.png")
        else
          addBtn=CCSprite:createWithSpriteFrameName("emTroop_addBtn.png")
        end
      end

      local posIcon=LuaCCSprite:createWithSpriteFrameName(pic,clickPosIcon)
      posIcon:setTag(i)
      posIcon:setAnchorPoint(ccp(0.5,0.5))
      posIcon:setPosition(ccp(startX+oneSpace/2,equipBgHeight/2))
      posIcon:setScale(110/posIcon:getContentSize().height)
      posIcon:setTouchPriority((-(self.layerNum-1)*20-2))
      equipBg:addChild(posIcon)

      if addBtn then
        posIcon:addChild(addBtn)
        addBtn:setAnchorPoint(ccp(0.5,0.5))
        addBtn:setPosition(getCenterPoint(posIcon))
        if addBtnScale then
          addBtn:setScale(addBtnScale)
        end
      end
      
      if equipId==nil or equipId==0 then
        local posIndexIcon=CCSprite:createWithSpriteFrameName("emTroop_posIcon_"..i..".png")
        posIcon:addChild(posIndexIcon)
        posIndexIcon:setAnchorPoint(ccp(0.5,0.5))
        posIndexIcon:setPosition(97,8)
      end

      startX=startX+oneSpace
    end
    local activateId=emblemTroopVoApi:getTroopActivateIdByColorTb(equipedColor)
    local effectPic
    if activateId then
      effectPic="emTroop_icon_"..activateId..".png"
    else
      effectPic="emTroop_icon_e1.png"
    end

    local function clickEffectBtn()
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      local descTb= self:getEmblemTroopActivateDesTb(activateId)
      -- smallDialog:showSEmasterPosDialog("aD_smallBg.png",CCSizeMake(530,500),CCRect(134,100,2,1),nil,self.layerNum+1,getlocal("emblem_troop_activateTitle"),getlocal("emblem_troop_activateTip"),descTb)
      require "luascript/script/game/scene/gamedialog/emblem/emblemTroopSmallDialog"
      local subTitle={getlocal("emblem_troop_activateTip"),{nil,G_ColorOrange,nil,G_ColorGreen,nil}}
      emblemTroopSmallDialog:showEmblemTroopPosDialog(self.layerNum+1,getlocal("emblem_troop_activateTitle"),subTitle,descTb)
    end
    local effectIcon=LuaCCSprite:createWithSpriteFrameName(effectPic,clickEffectBtn)
    effectIcon:setAnchorPoint(ccp(1,1))
    effectIcon:setPosition(ccp(equipBgWidth-15,equipBgHeight-15))
    effectIcon:setTouchPriority(-(self.layerNum-1)*20-4)
    equipBg:addChild(effectIcon)
    if activateId==nil then
      effectIcon:setColor(G_ColorGray)
    end
end

function emblemTroopDialog:updateTroopAdd(troopIdx)
    local contentLayer=self.list[troopIdx]
    local troopId=self.troopList[troopIdx].id
    local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
    if troopVo==nil then
      do return end
    end
    local equipCfg=emblemVoApi:getEquipCfgById(troopVo.type)

    local addBgWidth=contentLayer:getContentSize().width-40
    local addBgHeight=162
    local _h = 103
    if G_getIphoneType()==G_iphoneX then
      _h = 73
    end
    local function cellClick(hd,fn,index)
    end
    local addBg=LuaCCScale9Sprite:createWithSpriteFrameName("emTroop_panelBg.png",CCRect(54, 54, 2, 2),cellClick)
    addBg:setContentSize(CCSizeMake(addBgWidth, addBgHeight))
    addBg:setAnchorPoint(ccp(0.5,0.5))
    addBg:setPosition(ccp(contentLayer:getContentSize().width/2, contentLayer:getContentSize().height/2-_h))
    addBg:setTag(10)
    contentLayer:addChild(addBg,6)
    
    local startY=addBgHeight-30

    local keyToTitle=emblemTroopVoApi:getTroopAttributeType()
    local len=SizeOfTable(keyToTitle)
    local hang=math.ceil(len/2)
    local hangSpace=30
    for i=1,hang do
      for j=1,2 do
        local index=(i-1)*2+j
        if index <= len then
            local addType=keyToTitle[index]

            local typeName=""
            local bufCodeId=buffKeyMatchCodeCfg[addType]
            if bufCodeId then
              typeName=buffEffectCfg[bufCodeId].name
            end

            local typeLb=GetTTFLabel(getlocal(typeName)..":",20)
            typeLb:setAnchorPoint(ccp(0,0.5))
            typeLb:setPosition(ccp(30+(j-1)*(G_VisibleSizeWidth/2),startY-hangSpace/2-(i-1)*hangSpace))
            addBg:addChild(typeLb)

            local showValue=troopVo:getAttValueByType(addType)
            local valueSize=22
            
            if showValue>0 then
              valueSize=22
            end

            local showStr,color
            if addType~="troopsAdd"  and addType~="first" then
              showStr=(showValue*100).."%"
            else
              showStr=tostring(showValue)
            end

            if showValue>=0 then
              showStr="+"..showStr
              color=G_ColorGreen
            end

            local valueLb=GetTTFLabel(showStr,valueSize)
            valueLb:setAnchorPoint(ccp(0,0.5))
            valueLb:setPosition(ccp(typeLb:getPositionX()+typeLb:getContentSize().width+3,typeLb:getPositionY()))
            valueLb:setColor(color or G_ColorWhite)
            addBg:addChild(valueLb)
        end
      end
    end 
end

function emblemTroopDialog:updateTroopDetail(troopIdx)
    local contentLayer=self.list[troopIdx]
    if contentLayer then
      local troopId=self.troopList[troopIdx].id
      local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
      if troopVo==nil then
        do return end
      end
      local troopPic=troopVo:getIconPic()
      local mIcon=tolua.cast(contentLayer:getChildByTag(6),"CCSprite")
      if mIcon and troopPic then
        -- mIcon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(troopPic))
        mIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(troopPic))
      end
      
      local newStrong=troopVo:getTroopStrength()
      local strongLb=tolua.cast(contentLayer:getChildByTag(20),"CCLabelTTF")
      strongLb:setString(getlocal("alliance_boss_degree",{newStrong}))

      local equipBg=tolua.cast(contentLayer:getChildByTag(5),"LuaCCScale9Sprite")
      if equipBg then
        equipBg:removeFromParentAndCleanup(true)
        equipBg=nil
      end
      self:updateTroopPos(troopIdx)
      
      local addBg=tolua.cast(contentLayer:getChildByTag(10),"LuaCCScale9Sprite")
      if addBg then
        addBg:removeFromParentAndCleanup(true)
        addBg=nil
      end
      self:updateTroopAdd(troopIdx)

      if self.showSkillList==nil then
        self.showSkillList={}
      end
      self.showSkillList[troopIdx]={}
      local skillTb--技能信息
      if troopVo then
        skillTb=troopVo:getSkillTb()
        self.showSkillList[troopIdx]=skillTb
      end
      --刷新技能面板
      local skillBg=tolua.cast(contentLayer:getChildByTag(15),"LuaCCScale9Sprite")
      if skillBg then
        local skillTv=tolua.cast(skillBg:getChildByTag(1),"LuaCCTableView")
        if skillTv then
          if skillTb then
            local noSkillLb=tolua.cast(skillBg:getChildByTag(101),"CCLabelTTF")
            local skillLen=SizeOfTable(skillTb)
            if noSkillLb then
              if skillLen==0 then
                noSkillLb:setVisible(true)
              else
                noSkillLb:setVisible(false)
              end
            end
          end
          skillTv:reloadData()
        end
      end
    end
end

function emblemTroopDialog:gotoSetSuperEquip(troopId,posIndex,troopIdx)
  local isUnlock,needWashStrong=emblemTroopVoApi:checkIfPosUnlock(troopId,posIndex)
  if isUnlock==false then
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_posLock",{needWashStrong,posIndex}),30)
      do return end
  end
  local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)
  if troopVo and troopVo:checkIfBattled()==true then
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_battleTip"),30)
      do return end
  end

  local function updateMasterShow()
    self:update(troopIdx)
  end
  local function goToSet(equipId)
    if equipId then
      emblemTroopVoApi:troopSetEquip(troopId,equipId,posIndex,updateMasterShow)
    end
  end
  emblemVoApi:showMainDialog(self.layerNum+1,goToSet,5,troopId)
  -- require "luascript/script/game/scene/gamedialog/emblem/emblemDialog"
  -- local td=emblemDialog:new(5,goToSet,nil,troopId)
  -- local tbArr={getlocal("superEquip_tab_title_0"),getlocal("superEquip_tab_title_2"),getlocal("superEquip_tab_title_3"),getlocal("superEquip_tab_title_4"),getlocal("superEquip_tab_title_5")}
  -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("superEquip_title"),true,self.layerNum+1)
  -- sceneGame:addChild(dialog,self.layerNum+1)
end

function emblemTroopDialog:gotoUnSetSuperEquip(troopId,posIndex,troopIdx)
  local troopVo=emblemTroopVoApi:getEmblemTroopData(troopId)  
  local equipId=emblemTroopVoApi:getEmblemTroopPosEquipId(troopId,posIndex)
  if equipId then
    local function updateMasterShow()
      self:update(troopIdx)
    end
    local function callBack()
      if troopVo and troopVo:checkIfBattled()==true then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_troop_battleTip"),30)
        do return end
      end
      emblemTroopVoApi:troopUnSetEquip(troopId,posIndex,updateMasterShow)
    end
    
    -- require "luascript/script/game/scene/gamedialog/superEquipDialog/superEquipInfoDialog"
    -- local smallDialog=superEquipInfoDialog:new()
    -- smallDialog:init(self.layerNum+ 1,equipId,6,callBack)
    local emblemVo = emblemVoApi:getEquipVoByID(equipId)
    emblemVoApi:showInfoDialog(emblemVo,self.layerNum+1,nil,6,callBack)
  end
end

function emblemTroopDialog:update(troopIdx)
    self:updateTroopDetail(troopIdx)
    if self.parentDialog and self.parentDialog.updateList then
      self.parentDialog:updateList()
    end
end

function emblemTroopDialog:getEmblemTroopActivateDesTb(activateId)
    if activateId then
      activateId=tonumber(RemoveFirstChar(activateId))
    end
    local descTb={}
    local activateCfg=emblemTroopVoApi:getTroopActivateCfg()
    if activateCfg then
        local fValue=0
        for k, v in pairs(activateCfg) do
          if v.attUp and v.attUp.first then
            descTb[tonumber(RemoveFirstChar(k))]=v.attUp.first
            if activateId and activateId>=tonumber(RemoveFirstChar(k)) then
              fValue=fValue+v.attUp.first
            end
          else
            descTb[tonumber(RemoveFirstChar(k))]=0
          end
        end
        -- local attType=emblemTroopVoApi:getTroopAttributeType()
        -- local function getAddStr(addCfg)
        --     local str
        --     for i=1,SizeOfTable(attType) do
        --         if addCfg[attType[i]] then
        --             local newStr
        --             if attType[i]=="troopsAdd" or attType[i]=="first" then
        --               newStr=getlocal("superEquip_attUp_"..attType[i]).."+".. addCfg[attType[i]]
        --             else
        --               newStr=getlocal("superEquip_attUp_"..attType[i]).."+".. (tonumber(addCfg[attType[i]])*100) .."%%"
        --             end
        --             if str then
        --                 str=str .."、".. newStr
        --             else
        --                 str=newStr
        --             end
        --         end
        --     end
        --     return str
        -- end
        -- for k,v in pairs(activateCfg) do
        --     local addStr=getAddStr(v.attUp)
        --     local desc=getlocal("emblem_troop_activateDes",{v.numNeed,addStr})
        --     if activateId and activateId>=tonumber(RemoveFirstChar(k)) then
        --       descTb[tonumber(RemoveFirstChar(k))]={desc,1}
        --     else
        --       descTb[tonumber(RemoveFirstChar(k))]={desc,0}
        --     end
        -- end
        table.insert(descTb,1,fValue)
    end
    return descTb
end


function emblemTroopDialog:tick()
end

function emblemTroopDialog:dispose()
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emTroop_bg.jpg")
    spriteController:removePlist("public/emblem/emblemTroopImages.plist")
    spriteController:removeTexture("public/emblem/emblemTroopImages.png")
    self.list=nil
    self.troopList=nil
    self.troopPageLayer=nil
    self.showSkillList=nil
    self=nil
end




