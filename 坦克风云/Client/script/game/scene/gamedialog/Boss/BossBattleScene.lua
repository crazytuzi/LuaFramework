require "luascript/script/game/scene/tank/tank"
BossBattleScene={
  container,
  l_container,
  r_container,
  l_grossLayer,    --草地1层
  l_traceLayer,    --痕迹2层
  l_shellLayer,    --子弹效果4层
  l_bombLayer,    --爆炸效果5层
  r_grossLayer,    --草地1层
  r_traceLayer,    --痕迹2层
  r_shellLayer,    --子弹效果5层
  r_bombLayer,    --爆炸效果5层
  r_tankLayer,    --右边坦克3层
  l_tankLayer,    --左边坦克3层
  topLayer, --UI下一层，静止层
  allT1={},
  allT2={},
  tickIndex=1,
  leftPlayerSp,
  rightPlayerSp,
  VSp, --字母V
  SSp, --字母S
  scheIndex,
  battleData,
  hhLb, --显示回合文本框
  hhSp, --回合原件
  playerData, --战斗玩家信息
  hhNum=1, --回合数
  lFireIndex=1, --左边开炮的坦克索引
  rFireIndex=1, --右边开炮的坦克索引
  nextFire=0, --下一次开火的是哪边的坦克  1:左边 2:右边
  fireIndex, --开火索引（用于检索后台返回的数据）
  fireIndexTotal, --开火索引总数
  startFire=false,
  fireTimer, --战斗开火计时器
  isBattleEnd=false,
  battleReward,
  battleAcReward,
  battlePaused=false,
  isBattleing=false,
  zwTickIndex=0,
  zwTreeTb={4,2,3,1},
  isAttacker,
  isReport, --是否是战报回放
  isFuben, --是否是军团副本
  isWin,  --是否胜利(攻击者)
  -- leftMovDis=ccp(-687,-342),
  -- rightMovDis=ccp(690,342),
  mapscale=1,
  mapreletivepos={ccp(1024,512),ccp(2048,1024)},--地图相对拼接相对位置
  l_mappos={ccp(-320,-5)},--左下角地图初始位置
  r_mappos={ccp(-1950,-1026+G_VisibleSizeHeight*0.5)},--右上角初始位置
  
  mapmoveBy={ccp(-1024,-513),ccp(1024,512)},--地图移动(左下，右上)--2048 1026
  
  --地图震动相关
  l_isShakeing=false,
  r_isShakeing=false,
  l_ShakeStTime=0, --左边震动开始时间
  r_ShakeStTime=0, --右边震动开始时间
  fastTickIndex=0,
  --
  
  endBtnItem=nil,--跳过按钮
  endBtnItemMenu=nil,
  
  resultStar=1,
  serverWarType=nil,
  serverWarTeam=nil,
  supperWeaponSpTb={},
  heroSpTb={},
  isPickedTankTb={},
  heroData=nil,
  isShowSW=false,
  isShowHero=false,
  firstValue1=1000,
  firstValue2=1000,
  
  is10074Skill=false, --10074 坦克技能专用
  is10094Skill=false, --10074 坦克技能专用
  spcSkill=nil, --特殊技能，为了异性科技加的

  baseRewards=nil,--战斗结束的基础奖励
  killTypeTab=nil,--战斗结束后摧毁的炮头类型列表 1：普通炮头，2：特殊炮头
  bossType=1,--boss战斗的boss类型 1：海德拉boss，2：新年除夕年兽boss
  warSpeed=1,--战斗播放速度
}
function BossBattleScene:initPickedTankSp( )
  local isEliteTb = {}
  for i=1,6 do
    if self.isPickedTankTb[i] then
      local tankId =tonumber(RemoveFirstChar(self.isPickedTankTb[i]))
      if tankId then
        isEliteTb[i]=tankCfg[tankId].isElite
      else
        isElite[i]=nil
      end
    end
  end
  -- for k,v in pairs(self.allT1) do
  --     -- if tonumber(k) and isEliteTb[k] and isEliteTb[k]==1 then
  --       local pickedSp = CCSprite:createWithSpriteFrameName("picked_icon1.png")
  --       -- pickedSp:setScale()
  --       pickedSp:setAnchorPoint(ccp(1,0.5))
  --       pickedSp:setPosition(ccp(v.sprite:getContentSize().width*0.7,v.sprite:getContentSize().height*0.5-10))
  --       v.sprite:addChild(pickedSp)
  --     -- end
  -- end
  for k,v in pairs(self.allT2) do
      if tonumber(k) and isEliteTb[k] and isEliteTb[k]==1 then
        local pickedSp = CCSprite:createWithSpriteFrameName("picked_icon1.png")
        -- pickedSp:setScale()
        pickedSp:setAnchorPoint(ccp(1,0.5))
        pickedSp:setPosition(ccp(v.sprite:getContentSize().width*0.7,v.sprite:getContentSize().height*0.5-10))
        v.sprite:addChild(pickedSp)
      end
  end
end

function BossBattleScene:initSuperWeaponSp( )
  local rightSW={}
  local leftSW = {}
  if self.superWeapon and self.superWeapon[1] and self.superWeapon[2] then
    if self.playerData[1][3]==1 then
      rightSW = self.superWeapon[1]
      leftSW = self.superWeapon[2]
    else
      rightSW = self.superWeapon[2]
      leftSW = self.superWeapon[1]
    end
    for k,v in pairs(self.allT1) do
      if rightSW~=nil and SizeOfTable(rightSW) and rightSW[k] and rightSW[k] ~=0 then
          local fro = Split(rightSW[k],"-")
          local swIconNum = string.sub(fro[1],2,2) 
          local swIconFrame = "superWeaponIcon"..swIconNum..".png"
          local swIcon = CCSprite:createWithSpriteFrameName(swIconFrame)
          table.insert(self.supperWeaponSpTb,swIcon)
          swIcon:setScale(0.45)
          swIcon:setAnchorPoint(ccp(0.5,0))
          if k==1 or k==2 or k==3 then
            swIcon:setPosition(ccp(v.sprite:getContentSize().width/2-80,v.sprite:getContentSize().height-5))
          else
            swIcon:setPosition(ccp(v.sprite:getContentSize().width/2-40,v.sprite:getContentSize().height-5))
          end
          v.sprite:addChild(swIcon)
          swIcon:setVisible(false)
      end
    end
    for k,v in pairs(self.allT2) do
      if leftSW~=nil and SizeOfTable(leftSW) and leftSW[k] and leftSW[k] ~=0 then
          local fro = Split(leftSW[k],"-")
          local swIconNum = string.sub(fro[1],2,2) 
          local swIconFrame = "superWeaponIcon"..swIconNum..".png"
          local swIcon = CCSprite:createWithSpriteFrameName(swIconFrame)
          table.insert(self.supperWeaponSpTb,swIcon)
          swIcon:setScale(0.45)
          swIcon:setAnchorPoint(ccp(0.5,0))
          swIcon:setPosition(ccp(v.sprite:getContentSize().width/2-30,v.sprite:getContentSize().height))
          v.sprite:addChild(swIcon)
          swIcon:setVisible(false)
      end
    end
  end
end

function BossBattleScene:initHeroSp()
    
    for k,v in pairs(self.allT1) do
      if self.heroData~=nil and self.heroData[1]~=nil and self.heroData[1][k]~=nil and self.heroData[1][k]~="" then
         local heroVo=Split(self.heroData[1][k],"-")
         local adjutants = heroAdjutantVoApi:decodeAdjutant(self.heroData[1][k]) --将领副官
         local heroSp=heroVoApi:getHeroIcon(heroVo[1],heroVo[3],nil,nil,nil,nil,nil,{adjutants=adjutants})
         table.insert(self.heroSpTb,heroSp)
         heroSp:setScale(0.3)
         heroSp:setAnchorPoint(ccp(0.5,0))
         if k==1 or k==2 or k==3 then
            heroSp:setPosition(ccp(v.sprite:getContentSize().width/2-50,v.sprite:getContentSize().height-5))
         else
            heroSp:setPosition(ccp(v.sprite:getContentSize().width/2-20,v.sprite:getContentSize().height-5))
         end
         v.sprite:addChild(heroSp)
         heroSp:setVisible(false)
      end
    end

    for k,v in pairs(self.allT2) do
      if self.heroData~=nil and self.heroData[2]~=nil and self.heroData[2][k]~=nil and self.heroData[2][k]~="" then
         local heroVo=Split(self.heroData[2][k],"-")
         local adjutants = heroAdjutantVoApi:decodeAdjutant(self.heroData[2][k]) --将领副官
         local heroSp=heroVoApi:getHeroIcon(heroVo[1],heroVo[3],nil,nil,nil,nil,nil,{adjutants=adjutants})
         table.insert(self.heroSpTb,heroSp)
         heroSp:setScale(0.3)
         heroSp:setAnchorPoint(ccp(0.5,0))
         heroSp:setPosition(ccp(v.sprite:getContentSize().width/2+15,v.sprite:getContentSize().height))
         v.sprite:addChild(heroSp)
         heroSp:setVisible(false)
         
      end
    end


    local function showInfo()
      if self.isShowSW ==false then
        for k,v in pairs(self.supperWeaponSpTb) do
          v:setVisible(true)                 
        end
        self.isShowSW=true
      else
        for k,v in pairs(self.supperWeaponSpTb) do
          v:setVisible(false)
        end
        self.isShowSW=false
      end
      if self.isShowHero==false then
         for k,v in pairs(self.heroSpTb) do
           v:setVisible(true)
         end
         self.isShowHero=true
      else
         for k,v in pairs(self.heroSpTb) do
           v:setVisible(false)
         end
         self.isShowHero=false
      end

    end
    local infoItem = GetButtonItem("heroBtn1.png","heroBtn2.png","heroBtn1.png",showInfo,11,nil,nil)
    infoItem:setAnchorPoint(ccp(0,0))
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(0,0))
    infoBtn:setPosition(ccp(20,20))
    infoBtn:setTouchPriority(-281);
    self.container:addChild(infoBtn,3);

    local fSp1=CCSprite:createWithSpriteFrameName("positiveHead.png")
    fSp1:setPosition(ccp(120,20))
    self.leftPlayerSp:addChild(fSp1)
    fSp1:setScale(0.7)

    local fSp2=CCSprite:createWithSpriteFrameName("positiveHead.png")
    fSp2:setPosition(ccp(self.rightPlayerSp:getContentSize().width-120,20))
    self.rightPlayerSp:addChild(fSp2)
    fSp2:setScale(0.7)


    local leftPlayerLb1=GetTTFLabel(self.firstValue2,25)
    leftPlayerLb1:setAnchorPoint(ccp(0,0.5))
    leftPlayerLb1:setPosition(ccp(fSp1:getContentSize().width+3,fSp1:getContentSize().height/2))
    fSp1:addChild(leftPlayerLb1)

    local leftPlayerLb2=GetTTFLabel(self.firstValue1,25)
    leftPlayerLb2:setAnchorPoint(ccp(1,0.5))
    leftPlayerLb2:setPosition(ccp(-3,fSp2:getContentSize().height/2))
    fSp2:addChild(leftPlayerLb2)

end

function BossBattleScene:init()

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/tankRestraint.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/emblem/emblemImage.plist")
    spriteController:addTexture("public/emblem/emblemImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    if G_getIphoneType() == G_iphoneX then
      self.l_mappos={ccp(-370,0)}--左下角地图初始位置
      self.r_mappos={ccp(-1950,-1026+G_VisibleSizeHeight*0.55-15)}--右上角初始位置
      self.mapscale=1.35
      self.mapreletivepos={ccp(1024*self.mapscale,513*self.mapscale),ccp(2049*self.mapscale+10,1027*self.mapscale)}--地图相对拼接相对位置
      self.mapmoveBy={ccp(-1024*self.mapscale-10,-513*self.mapscale),ccp(1024*self.mapscale+12,513*self.mapscale+2)}--地图移动(左下，右上)--2048 1026
    elseif G_getIphoneType() == G_iphone5 then
       self.l_mappos={ccp(-370,0)}--左下角地图初始位置
       self.r_mappos={ccp(-1950,-1026+G_VisibleSizeHeight*0.55)}--右上角初始位置
       self.mapscale=1.18
       self.mapreletivepos={ccp(1024*self.mapscale,513*self.mapscale),ccp(2049*self.mapscale,1027*self.mapscale)}--地图相对拼接相对位置
       self.mapmoveBy={ccp(-1024*self.mapscale,-513*self.mapscale),ccp(1024*self.mapscale,513*self.mapscale)}--地图移动(左下，右上)--2048 1026
    end
    local function tick()
         self:tick()
    end
    local size=G_VisibleSize
    self.scheIndex=CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick,0,false)
    self.container=CCLayer:create()
    self.leftPlayerSp=CCSprite:createWithSpriteFrameName("VS_leftInfo.png")
    self.rightPlayerSp=CCSprite:createWithSpriteFrameName("VS_leftInfo.png")
    self.rightPlayerSp:setFlipX(true)



    self.leftPlayerSp:setAnchorPoint(ccp(0,0))
    self.rightPlayerSp:setAnchorPoint(ccp(0,0))
    
    self.leftPlayerSp:setPosition(ccp(0,size.height-self.leftPlayerSp:getContentSize().height))
    self.rightPlayerSp:setPosition(ccp(size.width-self.rightPlayerSp:getContentSize().width,size.height-self.rightPlayerSp:getContentSize().height))
    --战斗双方信息显示
       local leftPName,rightPName
       if tonumber(self.playerData[2][1])==nil or tonumber(self.playerData[2][1])>6 then
           leftPName=self.playerData[2][1]
           if tonumber(leftPName)~=nil then
              leftPName=arenaVoApi:getNpcNameById(tonumber(leftPName))
           end
       else
           leftPName=getlocal("world_island_"..self.playerData[2][1])
       end
       if tonumber(self.playerData[1][1])==nil or tonumber(self.playerData[1][1])>6 then
           rightPName=self.playerData[1][1]
           if tonumber(rightPName)~=nil then
              rightPName=arenaVoApi:getNpcNameById(tonumber(rightPName))
           end
       else
           rightPName=getlocal("world_island_"..self.playerData[1][1])
       end
       local nameHeight = 75
       if platCfg.platUseUIWindow[G_curPlatName()]~=nil and platCfg.platUseUIWindow[G_curPlatName()]==2 then
            nameHeight = 65
        end

        if self.playerUid1~=nil and self.playerUid1==0 then
           rightPName=getlocal(rightPName)
        end
        if self.playerUid2~=nil and self.playerUid2==0 then
           leftPName=getlocal(leftPName)
        end

       local leftPlayerLb=GetTTFLabel(leftPName,25)
       leftPlayerLb:setAnchorPoint(ccp(0,1))
       leftPlayerLb:setPosition(ccp(25,nameHeight))
       self.leftPlayerSp:addChild(leftPlayerLb)
       local rightPlayerLb=GetTTFLabel(rightPName,25)
       rightPlayerLb:setAnchorPoint(ccp(1,1))
       rightPlayerLb:setPosition(self.rightPlayerSp:getContentSize().width-25,nameHeight)
       self.rightPlayerSp:addChild(rightPlayerLb)
       
       local leftPlayerLvLb=GetTTFLabel(G_LV()..self.playerData[2][2],20)
       leftPlayerLvLb:setAnchorPoint(ccp(0,1))
       leftPlayerLvLb:setPosition(ccp(25,28))
       self.leftPlayerSp:addChild(leftPlayerLvLb)
       local rightPlayerLvLb=GetTTFLabel(G_LV()..self.playerData[1][2],20)
       rightPlayerLvLb:setAnchorPoint(ccp(1,1))
       rightPlayerLvLb:setPosition(self.rightPlayerSp:getContentSize().width-25,28)
       self.rightPlayerSp:addChild(rightPlayerLvLb)
    --
    self.container:addChild(self.leftPlayerSp,10)
    self.container:addChild(self.rightPlayerSp,10)
    self.container:setTouchEnabled(true)
    self.container:setBSwallowsTouches(true) --屏蔽底层响应
    self.container:setTouchPriority(-81)
    self.container:setContentSize(G_VisibleSize)
    
    self.r_container=CCLayer:create()
    self.l_container=CCLayer:create()
    self.r_traceLayer=CCLayer:create() 
    self.l_traceLayer=CCLayer:create() 
    self.r_tankLayer=CCLayer:create()
    self.l_tankLayer=CCLayer:create()
    self.r_shellLayer=CCLayer:create()
    self.l_shellLayer=CCLayer:create()
    self.r_bombLayer=CCLayer:create()
    self.l_bombLayer=CCLayer:create()
    self.topLayer=CCLayer:create()
    
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    self.r_grossLayer=CCNode:create()

    self.r_grossLayer:setPosition(self.r_mappos[1])
    self.r_grossLayer:setAnchorPoint(ccp(0.5,0.5))

    for i=1,2 do
         local mapsprite=CCSprite:create(self.bgName2)
         
         -- mapsprite:setTag(100+i)--tag值 和 zorder 用于变化地图使用 目前未开放
         mapsprite:setScale(self.mapscale)         
         if i==1 then 
              mapsprite:setPosition(self.mapreletivepos[1])
         elseif i==2 then
              mapsprite:setPosition(self.mapreletivepos[2])
         end 
         self.r_grossLayer:addChild(mapsprite,i)
    end

    self.r_container:addChild(self.r_grossLayer,1) --右边草地层,1需要移动效果
    self.r_container:addChild(self.r_traceLayer,2) --右边痕迹层,2
    self.r_container:addChild(self.r_tankLayer,3) --右边坦克层,3
    self.r_container:addChild(self.r_shellLayer,4) --右边子弹层
    self.r_container:addChild(self.r_bombLayer,5) --右边爆炸效果层
    
    self.container:addChild(self.r_container,1)
    
    
    local clipper=CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(size.width,size.height*0.8))
    clipper:setAnchorPoint(ccp(0,0))
    clipper:setPosition(0,0)
    local stencil=CCDrawNode:getAPolygon(size,0.25,0.7)
    clipper:setStencil(stencil) --遮罩
    
    self.l_grossLayer=CCNode:create()

    self.l_grossLayer:setPosition(self.l_mappos[1])
    self.l_grossLayer:setAnchorPoint(ccp(0.5,0.5))

    for i=1,2 do
         local mapsprite=CCSprite:create(self.bgName1)
         -- mapsprite:setTag(100+i)--tag值 和 zorder 用于变化地图使用 目前未开放
         mapsprite:setScale(self.mapscale)

         if i==1 then 
              mapsprite:setPosition(self.mapreletivepos[1])
         elseif i==2 then
              mapsprite:setPosition(self.mapreletivepos[2])
         end 
         self.l_grossLayer:addChild(mapsprite,i)
    end

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    self.l_container:addChild(self.l_grossLayer,1) --左边草地层,1需要移动效果
    self.l_container:addChild(self.l_traceLayer,2) --左边痕迹层,2
    self.l_container:addChild(self.l_tankLayer,3) --左边添加坦克层
    self.l_container:addChild(self.l_shellLayer,4) --左边子弹层
    self.l_container:addChild(self.l_bombLayer,5) --左边爆炸效果层
    self.topLayer:setAnchorPoint(ccp(0,0))
    self.container:addChild(self.topLayer,9)
    clipper:addChild(self.l_container); --被遮罩
    self.container:addChild(clipper,1)
    sceneGame:addChild(self.container,5)
    
    local ang=math.atan2((size.height*0.25-size.height*0.7),(size.width-0))*180/3.1415;
    local fj=CCSprite:createWithSpriteFrameName("VSBarbedWire-.png")
    self.container:addChild(fj,15)
    fj:setAnchorPoint(ccp(0.5,0.5))
    fj:setPosition(ccp(size.width/2,size.height/2-25))
    fj:setScaleY(1)
    fj:setRotation(-ang)
    --隐藏面板
    storyScene:setHide(false)
    if storyScene.checkPointDialog[1]~=nil then
        storyScene.checkPointDialog[1]:setHide()
    end
    allianceFubenScene:setHide()
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
        if(v and v.setDisplay)then
            v:setDisplay(false) --隐藏所有commonDialog面板
        end
    end
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v and v.setDisplay then
            v:setDisplay(false) --隐藏所有smallDialog面板
        end
    end
    
    --


    self:moveMap()  --地图移动
    
    if newGuidMgr:isNewGuiding() == true and newGuidMgr.curStep == 50 then
        local function callBackToShowVS( )
           self:vsMoveAction()------ 
        end 
        local actionTb = {}
        actionTb["ShowVS"] ={nil,self.container,nil,nil,nil,3.2,nil,nil,callBackToShowVS }
        G_RunActionCombo(actionTb)
    else
        self:vsMoveAction() --VS 动画
    end
    
    local function showEndBtn()

    --[[
        local endBtn=LuaCCSprite:createWithSpriteFrameName("closeBtn.png",endFunc)
        endBtn:setTouchPriority(-103)
        endBtn:setIsSallow(true)
        endBtn:setAnchorPoint(ccp(0,0))
        self.container:addChild(endBtn,15)
        endBtn:setPosition(ccp(size.width-100,20))
    ]]


        if self.isBattleEnd==false then
            self.endBtnItemMenu:setPosition(ccp(size.width-self.endBtnItem:getContentSize().width,20))
        end
    end
        
        local function endFunc()
            PlayEffect(audioCfg.mouseClick)
            if newGuidMgr.curStep==52 or newGuidMgr.curStep == 54 or newGuidMgr.curBMStep==3 then
                if self.fireTimer~=nil then
                  CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
                end
                self.isBattleEnd=true
                self.endBtnItemMenu:setPosition(ccp(100000,20))
                if newGuidMgr.curBMStep~=nil then
                    newGuidMgr:toNextStep()
                else
                  newGuidMgr:toNextStep(55)
                end
                

            else

              if self.isBattleEnd==false or ( self.airShipSpTb and next(self.airShipSpTb) ) then
                  if self.airShipSpTb then
                      for i=1,2 do
                          if self.airShipSpTb[i] then
                            self.airShipSpTb[i]:stopAllActions()
                          end
                      end
                  end
                  if self.fireTimer~=nil then
                      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
                  end
                  self.isBattleEnd=true
                  if newGuidMgr:isNewGuiding()==false then
                    self:showResuil()
                  end
              end
            end
      --self:stopAction()
        end

        self.endBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",endFunc,nil,getlocal("skipPlay"),30)
        self.endBtnItem:setPosition(0,0)
        self.endBtnItem:setAnchorPoint(CCPointMake(0,0))
        self.endBtnItemMenu = CCMenu:createWithItem(self.endBtnItem)

        if newGuidMgr.curStep==52 or newGuidMgr.curBMStep==3 then
            self.endBtnItemMenu:setTouchPriority(-322)
        else
            self.endBtnItemMenu:setTouchPriority(-203)
        end
        

        self.endBtnItemMenu:setPosition(ccp(size.width-self.endBtnItem:getContentSize().width+10000,20))
        self.container:addChild(self.endBtnItemMenu,15)


    if  newGuidMgr:isNewGuiding()==false then
        local ccdelay=CCDelayTime:create(self.isReport==true and 0 or 3)
        local  ffunc=CCCallFuncN:create(showEndBtn)
        local  fseq=CCSequence:createWithTwoActions(ccdelay,ffunc)
        self.container:runAction(fseq)
    end

    
end

--初始化后台返回的战斗数据,bossType boss的类型 1：海德拉boss，2：新年除夕活动年兽boss
function BossBattleScene:initData(data,bossType)
    self.recSpeed = G_battleSpeed
    G_battleSpeed = 1
    self.isBattleing=true
    if bossType == nil then
      self.bossType = 1
    else
      self.bossType = bossType
    end
    if data.isInAllianceWar then
        self.bgName1="scene/battles_1.jpg"
        self.bgName2="scene/battles_1.jpg"
    else
        self.bgName1="scene/battles_4.jpg"
        self.bgName2="scene/battles_4.jpg"
      -- if bossType == 2 and data.data and data.data.eva and data.data.eva[4] then
      --    self.bgName1="scene/battles_"..data.data.eva[4]..".png"
      --    self.bgName2="scene/battles_"..data.data.eva[4]..".png"
      -- else
      --   self.bgName1="scene/r1_mi.jpg"
      --   self.bgName2="scene/r2_mi.jpg"
      -- end
    end
    --[[
    ]]
    --local retTb={}
    --local t1={[1]={1,10},[2]={1,10},[3]={1,10},[4]={1,20},[5]={1,20},[6]={1,20}}
    --local t2={[1]={1,10},[2]={1,20},[3]={1,10},[4]={1,20},[5]={1,10},[6]={1,20}}
    --数据顺序  p {右边}，{左边}   d:{{第一炮扣血量-剩余坦克数量,第二炮扣血量-剩余坦克数量,....},{第一炮扣血量-剩余坦克数量,第二炮扣血量-剩余坦克数量,....}} 双方有多少个坦克开过炮就有多少条数据记录,如果此次攻击被攻击坦克数量没有减少可以不返回”剩余坦克数量,“（即 --剩余坦克数量）
     --[[
     retTb={p={{"帝国舰队",3,0},{"坦克英雄",16,1}},t={t1,t2},d={{"23-5-1"},{"21-6"},{"0"},{"23-0"},{"23-1"},{"23-5"},{"23-5"},{"23-0"},{"23-5"},{"23-5"},{"23-0"},{"23-5"},{"23-5"},{"23-5"},{"23-0"},{"23-5"},{"23-5"},{"23-0"},{"23-5"},{"23-0"},{"23-0"},{"23-5"},{"23-5"},{"23-5"},{"25-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"},{"23-5"}},r={"1002-3","1104-5"}}
     ]]
    -- data.data.report = G_Json.decode('{"p":[{},["xiaolin1",52,1,1]],"h":[{},{}],"t":[[["a99999",1],{},{},{},{},{}],[["a10007",481],["a10007",481],["a10007",481],["a10007",481],["a10007",481],["a10144",898]]],"d":{"stats":{"dmg":[18216272,0],"loss":[0,0]},"pn":[5,0],"sk":[{},{}],"d":[["944539-1","1889078-1-1","944539-1"],["992063-1","1984126-1-1","992063-1"],["739592-1","739592-1","739592-1"],["356430-1","356430-1","356430-1"],["0","0","409895-1"],["6771903-1-1"]],"se":[0,"e72_3"],"fj":[["p1"],{}],"fd":{},"sw":[["w8-13","w1-15","w2-8",0,"w7-2","w3-2"],{}],"ad":{},"bd":[5281380,5437224,2623374,1731600,681096,622314]}}')
    --击杀炮头
    if data.destoryPaotou then
      self.destoryPaotou=data.destoryPaotou
    end
    if self.destoryPaotou ==nil then
      self.destoryPaotou={}
    end

    if self.bossType == 2 then
      if data.data.eva then
        self.bossDamage=data.data.eva[6]-(data.data.eva[2]-data.data.eva[3])
      end
    elseif self.bossType==3 then
      if data.data.allianceboss then
        self.bossDamage=data.data.allianceboss[5]-(data.data.allianceboss[2]-data.data.allianceboss[3])
      end
    else
      if data.data.worldboss.boss then
        self.bossDamage=data.data.worldboss.boss[5]-(data.data.worldboss.boss[2]-data.data.worldboss.boss[3])
      end
    end
    if self.bossDamage==nil then
      self.bossDamage=0
    end
    --retTb=data
    --是否是军团副本
    self.isFuben=data.isFuben
    if self.isFuben==nil then
        self.isFuben=false
    end
    --是否是战报回放
    self.isReport=data.isReport
  if self.isReport==nil then
    self.isReport=false
  end
    self.isAttacker=data.isAttacker
  if self.isAttacker==nil then
    self.isAttacker=true
  end
    self.serverWarTeam=data.serverWarTeam
    self.serverWarType=data.serverWarType
    self.isWin=data.data.report.w
    --self.battleData=data.data.report.d
    self.battleData=(data.data.report.d.d==nil and data.data.report.d or data.data.report.d.d)
    self.spcSkill=data.data.report.d.ab
    self.emblemData = data.data.report.d.se--军徽系统BUF
    self.baseRewards=data.data.reward
    self.killTypeTab=data.data.kill
    self.superWeapon=data.data.report.d.sw
    self.reflexHurtTb=data.data.report.d.bd or nil
    -- if self.reflexHurtTb then
    --     print("number of self.reflexHurtTb-===>>>>>",SizeOfTable(self.reflexHurtTb))
    -- end
    --[[
    local spcSkill=data.data.report.d.ab
    rhskill={}
    lhskill={}
    if spcSkill~=nil then
         for kk,vv in pairs(spcSkill[1]) do
                  if vv.h~=nil then

                  end
         end
    
    end
    ]]

    if newGuidMgr:isNewGuiding() ==true then
        table.insert(self.battleData,{"999999-1","999999-1"})
    else
        table.insert(self.battleData,{"999999-0","999999-0","999999-0","999999-0","999999-0","999999-0"})
    end

    local t1 = {}
    if self.bossType == 2 then
      local _tankId="a99998"
      if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        _tankId="a99999"
      end
      t1={[2]={_tankId,1}}
    else
      t1={[2]={"a99999",1}}
    end
    local t2={[1]={"a10001",10},[2]={"a10006",10},[3]={"a10016",10},[4]={"a10026",20},[5]={"a10036",20},[6]={"a10005",20}}
    local retb={p={{"帝国舰队",3,0},{"坦克英雄",16,1}},t={t1,t2},d={{"23-1-1"},{"23-1-1","23-1-1","23-1-1"},{"23-1-1"},{"23-1-1","23-1-1"},{"23-1-1","23-1-1","23-1-1","23-1-1","23-1-1","23-1-1"},{"23-1-1","23-1-1","23-1-1"},{"0","0","0","0","0","0"},{"23-1-1"},{"23-1-1","23-1-1","23-1-1"},{"23-1-1"},{"23-1-1","23-1-1"},{"23-1-1","23-1-1","23-1-1","23-1-1","23-1-1","23-1-1"},{"23-1-1","23-1-1","23-1-1"},{"100-0-1","100-0-1","100-0-1","100-0-1","100-0-1","100-0-1"}},r={"1002-3","1104-5"}}

    
    -- table.insert(retb,{"@"})
    -- table.insert(retb,{"20-1","32-4","3-2"})
    -- for k,v in pairs(self.battleData) do
    --     table.insert(retb,v)
    -- end
    
    -- self.battleData=retb.d

    
            -- print("战斗数据",self.battleData)
            -- for k,v in pairs(self.battleData) do
            --     print("新战斗",k,v)
            --     for kk,vv in pairs(v) do
            --         print("新战斗====",kk,vv)
            --     end
            -- end
    self.fjTb = data.data.report.d.fj or nil--(用于飞机图片使用) ,{{"p3","1313"},{"p4","1313"}}:1313  ---飞机相关数据 用于转换出技能名称
    self.playerData=data.data.report.p
    self.battleReward=data.data.report.r
    self.heroData=data.data.report.h
    self.addResPathTb={}

    self.skinTb = {}
    if data.data.report.d.sk then--皮肤数据列表 与 坦克id列表 是反着的，需要format
        self.skinTb[1] = data.data.report.d.sk[2]
        self.skinTb[2] = data.data.report.d.sk[1]
    end

    --飞艇信息 --
    if data.data.report.d.as then
      self.airShipTb = {}
        self.airShipTb[1] = data.data.report.d.as[2]
        self.airShipTb[2] = data.data.report.d.as[1]
    end
    -- self.battleData=retb.d
    -- self.playerData=retb.p
    -- self.battleReward=retb.r
    -- data.data.report.t=retb.t
    if self.bossType == 2 then
      local monsterName=getlocal("activity_newyearseve_bossname")
      if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        monsterName=getlocal("activity_newyearseve_bossname_1")
      end
      data.data.report.p[1]={monsterName,acNewYearsEveVoApi:getTankLv(),0,0}
    elseif self.bossType==3 then
      data.data.report.p[1]={getlocal("alliance_boss_name"),allianceFubenVoApi:getAllianceBossLv(),0,0}
    else
      data.data.report.p[1]={getlocal("BossBattle_title"),BossBattleVoApi:getBossLv(),0,0}
    end
    data.data.report.t[1]=t1

    if platCfg.platCfgNewTypeAddTank then
      for k,v in pairs(data.data.report.t[1]) do
        local sid = (self.skinTb[1] and self.skinTb[1]["p"..k]) and self.skinTb[1]["p"..k] or nil
        if v[1] then
           local tid = tonumber(RemoveFirstChar(v[1]))
           self:addRes(tid,sid)
        end
      end
      for k,v in pairs(data.data.report.t[2]) do
        local sid = (self.skinTb[2] and self.skinTb[2]["p"..k]) and self.skinTb[2]["p"..k] or nil
        if v[1] then
           local tid = tonumber(RemoveFirstChar(v[1]))
           self:addRes(tid,sid)
        end
      end
    end

    self:addRes2()
    -- if self.playerData[1][4]~=nil then
    --   self.firstValue1=self.playerData[1][4]
    -- end
    -- if self.playerData[2][4]~=nil then
    --   self.firstValue2=self.playerData[2][4]
    -- end
    -- if self.playerData[1][5]~=nil then
    --   self.playerUid1=self.playerData[1][5]
    -- end
    -- if self.playerData[2][5]~=nil then
    --   self.playerUid2=self.playerData[2][5]
    -- end
    if data.data.report.acaward then
       self.battleAcReward=data.data.report.acaward
    end
    self.resultStar=data.data.report.star
    self:isPickedTankId(data.data.report.t[2])
    self:startBattle(data.data.report.t[1],data.data.report.t[2],self.fjTb,nil,nil,self.skinTb[1],self.skinTb[2])

    if newGuidMgr:isNewGuiding() == true and newGuidMgr.curStep == 50 then
        self:animationBeforeStartBattle(data.data.report.t[1],data.data.report.t[2])
    end
end

function BossBattleScene:isPickedTankId(t2 )
    for i=1,6 do
        -- if t1[i]~=nil and #t1[i]>0 then
        --     if t1[i][2]>0 then
        --         self.isPickedTankTb[i]=t1[i][1]
        --     else
        --         self.isPickedTankTb[i]=nil
        --     end
        -- else
        --     self.isPickedTankTb[i]=nil
        -- end
        if t2[i]~=nil and  #t2[i]>0 then
            if t2[i][2]>0 then
                self.isPickedTankTb[i] = t2[i][1]
            else
                self.isPickedTankTb[i]=nil
            end
        else
            self.isPickedTankTb[i]=nil
        end
    end
end

function BossBattleScene:addRes(tid,sid)
    local skinId = sid and sid.."_" or ""
    if tid~=10001 and tid~=50001 and tid~=99999 and tid~=99998 then
        local tid= GetTankOrderByTankId(tid)

        local path = skinId.."t"..tid.."newTank."
        local str = "ship/newTank/"..path.."plist"--s1_t10095newTank.
        local str2 = "ship/newTank/"..path.."png"
        
        if self.addResPathTb==nil then
            self.addResPathTb={}
        end
        local tb = {str,str2}
        table.insert( self.addResPathTb, tb )
        -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(str)
        spriteController:addPlist(str)
        spriteController:addTexture(str2)
    end
    spriteController:addPlist("public/radiationImage.plist")
    spriteController:addTexture("public/radiationImage.png")
end
function BossBattleScene:addRes2( )
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/radiationImage.plist")
    spriteController:addTexture("public/radiationImage.png")
    spriteController:addPlist("public/emblemSkillBg.plist")
    spriteController:addTexture("public/emblemSkillBg.png")
    if self.fjTb then
        spriteController:addPlist("public/plane/battleImage/battlesPlaneCommon1.plist")--BattlesPlaneShellsImage
        spriteController:addTexture("public/plane/battleImage/battlesPlaneCommon1.png")
    end

    if self.airShipTb and self.airShipTb[2] and next(self.airShipTb[2]) then
        local airshipId = tonumber(self.airShipTb[2][1])
        G_addingOrRemovingAirShipImage(true, airshipId)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end
function BossBattleScene:removeRes()
    if self.addResPathTb and SizeOfTable(self.addResPathTb)>0 then
        for k,v in pairs(self.addResPathTb) do
            spriteController:removePlist(v[1])
            spriteController:removeTexture(v[2])
        end
    end
    spriteController:removePlist("public/radiationImage.plist")
    spriteController:removeTexture("public/radiationImage.png")
    if self.fjTb then
        spriteController:removePlist("public/plane/battleImage/battlesPlaneCommon1.plist")--BattlesPlaneShellsImage
        spriteController:removeTexture("public/plane/battleImage/battlesPlaneCommon1.png")
    end
    if self.airShipTb and self.airShipTb[2] and next(self.airShipTb[2]) then
        local airshipId = tonumber(self.airShipTb[2][1])
        G_addingOrRemovingAirShipImage(false, airshipId)
    end
end

function BossBattleScene:standByArmyInNewGuid( )--只给新手引导使用的
      
      for i=3,6 do
          self.allT2[i]:animationApproach()
      end 
      local delayTime = CCDelayTime:create(1.2)
      local delayTime2 = CCDelayTime:create(0.5)
      local function againBattleData()--如果 这里的数据有改变 那么对应的BOSS坦克内的判断也需改变相应数据条件==>> local destoryPaoGuanLife = {541261,541262,524835,458791,765248,658714} 
          self.battleData={
                            {"214-1","258-1","291-1"},
                            {"143-1","186-1","137-1","149-1","146-1","145-1"},
                            {"541261-1","541262-1","524835-1","532464-1","531219-1","529971-1"},
                            {"451428-1","460219-1","458791-1"},
                            {"733515-1","765248-1","749782-1","765784-1","773917-1","782053-1"},
                            {"658714-1"}
                          }

          self.battlePaused =false
          -- self.startFire=true
          self:vsMoveAction()
      end
      local function callBackToShowVS( )
         self:vsMoveAction()------ 
      end 
      local callBattle = CCCallFuncN:create(againBattleData)
      local arr = CCArray:create()
      arr:addObject(delayTime)
      arr:addObject(callBattle)
      local seq = CCSequence:create(arr)
      self.container:runAction(seq)
end

function BossBattleScene:battleEndWinerGoOut()--只给新手引导使用的
  
    if newGuidMgr:isNewGuiding() == true then
         local actionTb = {}
         for k,v in pairs(self.allT2) do
            v.inBattle =false
            v.container:stopAllActions()
            local arrivalPos = ccp(v.container:getPositionX()+400,v.container:getPositionY()+200)
            actionTb["k_"..k] ={1,v.container,nil,nil,arrivalPos,1.5,1}
         end
         G_RunActionCombo(actionTb)
    end
end
function BossBattleScene:animationBeforeStartBattle(t1,t2)--只给新手引导使用的
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    


    local function noData( ) end
    local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("GrayBg&RedSquare.png",CCRect(26,99,1,1),noData)
    middleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight*0.21))
    middleBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
    self.container:addChild(middleBg,30)
    local middleBgScaleY = 10/middleBg:getContentSize().height
    middleBg:setScaleY(middleBgScaleY)

    local upBoderSp = CCSprite:createWithSpriteFrameName("RedlineBoder.png")
    upBoderSp:setAnchorPoint(ccp(1,1))
    upBoderSp:setPosition(ccp(G_VisibleSizeWidth,G_VisibleSizeHeight*0.6))
    upBoderSp:setOpacity(0)
    self.container:addChild(upBoderSp,30)
    local upMovePos = ccp(G_VisibleSizeWidth*2,upBoderSp:getPositionY())

    local downBoderSp = CCSprite:createWithSpriteFrameName("RedlineBoder.png")
    downBoderSp:setAnchorPoint(ccp(0,0))
    downBoderSp:setFlipY(true)
    downBoderSp:setPosition(ccp(0,G_VisibleSizeHeight*0.4))
    downBoderSp:setOpacity(0)
    self.container:addChild(downBoderSp,30)
    local downMovePos = ccp(0-G_VisibleSizeWidth,downBoderSp:getPositionY())

    local warnStr = "WarningEN.png"
    if G_getCurChoseLanguage() == "cn" then
        warnStr = "WarningCN.png"
    end
    local warnLb = CCSprite:createWithSpriteFrameName(warnStr)
    warnLb:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
    warnLb:setOpacity(0)
    self.container:addChild(warnLb,30)


    local warnBg = CCSprite:createWithSpriteFrameName("RedOpenBgBoder.png")
    warnBg:setScaleX(G_VisibleSizeWidth/warnBg:getContentSize().width)
    warnBg:setScaleY(G_VisibleSizeHeight/warnBg:getContentSize().height)
    warnBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
    self.container:addChild(warnBg,30)
    local actionTb = {}
    actionTb["warn_1698"] ={middleBg,upBoderSp,downBoderSp,warnLb,upMovePos,downMovePos,middleBgScaleY,nil,nil,nil,1698 }
    actionTb["warn_1697"] ={warnBg,nil,nil,nil,nil,nil,nil,nil,nil,nil,1697 }
    G_RunActionCombo(actionTb)
end

--派坦克出战 t1:右上角  t2:左下角   格式:{[1]={1,13},[3]={2,190},[4]={3,56}}  {[位置索引]={船类型编号1-20,船数量}}
function BossBattleScene:startBattle(t1,t2,fjTb,aiTb,aiSkillTb,skinTb1,skinTb2)
    self:init()
    local num = -1
    local tid = "a99999"
    if self.bossType == 2 then
      num = -2
      if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
        tid = "a99999"
      else
        tid = "a99998"
      end
    elseif self.bossType==3 then
      num=-3
      tid="a99999"
    else
      num = -1
      tid = "a99999"
    end
    for k=1,6 do
        if t1[k]~=nil and #t1[k]>0 then
            if t1[k][2]>0 then
                local tankSp=tank:new(t1[k][1],num,k,1,false,self)

                self.allT1[k]=tankSp
            else
                local tankSp=tank:new(tid,num,k,1,true,self)
                self.allT1[k]=tankSp
            end
        else
                local tankSp=tank:new(tid,num,k,1,true,self)
                self.allT1[k]=tankSp

        end

        local skinId2 = skinTb2 and skinTb2["p"..k] or nil
        if t2[k]~=nil and  #t2[k]>0 then
            if t2[k][2]>0 then
                local tankSp=tank:new(t2[k][1],t2[k][2],k,2,false,self,nil,skinId2)
                self.allT2[k]=tankSp
            else
                local tankSp=tank:new("a10001",1,k,2,true,self,nil,skinId2)
                self.allT2[k]=tankSp
            end
        else
                local tankSp=tank:new("a10001",1,k,2,true,self,nil,skinId2)
                self.allT2[k]=tankSp
            
        end
        
    end
    if base.ifSuperWeaponOpen ==1 then
        self:initSuperWeaponSp()
    end

    if base.heroSwitch==1 and newGuidMgr:isNewGuiding()==false then
        self:initHeroSp()
    end
    self:initPickedTankSp()

     -----上面是tank 下面是plane
    if base.plane and base.plane == 1 and fjTb and SizeOfTable(fjTb) > 0 then
        for i=1,2 do
            local fjPoint = 3-i
            if fjTb[i] and #fjTb[i] >0 then
                local planeSp = plane:new(fjTb[i][1],i,fjPoint,fjTb[i][2],false,nil,true)
            end
        end
    end
end
function BossBattleScene:moveMap()
    local size=G_VisibleSize
    local speedNum = 8 
    local function reSetLeft()
        self.l_grossLayer:stopAllActions()
        self.l_grossLayer:setPosition(self.l_mappos[1])

        local  leftFunc=CCCallFuncN:create(reSetLeft);
        local  leftMoveBy=CCMoveBy:create(speedNum, self.mapmoveBy[1])
        local leftseq=CCSequence:createWithTwoActions(leftMoveBy,leftFunc)
        self.l_grossLayer:runAction(leftseq) 
    end
    local  leftFunc=CCCallFuncN:create(reSetLeft);
    local  leftMoveBy=CCMoveBy:create(speedNum, self.mapmoveBy[1])
    local leftseq=CCSequence:createWithTwoActions(leftMoveBy,leftFunc)
    self.l_grossLayer:runAction(leftseq) 

    local function reSetRight()
        self.r_grossLayer:stopAllActions()
        self.r_grossLayer:setPosition(self.r_mappos[1])    
        
        local  rightFunc=CCCallFuncN:create(reSetRight)
        local rightMoveBy=CCMoveBy:create(speedNum, self.mapmoveBy[2])
        local rightseq = CCSequence:createWithTwoActions(rightMoveBy,rightFunc)
        self.r_grossLayer:runAction(rightseq)
    end
    local  rightFunc=CCCallFuncN:create(reSetRight);
    local rightMoveBy=CCMoveBy:create(speedNum, self.mapmoveBy[2])
    local rightseq = CCSequence:createWithTwoActions(rightMoveBy,rightFunc)
    self.r_grossLayer:runAction(rightseq)
    
    --痕迹层移动
        local function reSetLeftTrace()
            self.l_traceLayer:stopAllActions()
            local curPosX,curPosY=self.l_traceLayer:getPosition()
            -- local  leftTraceMoveTo=CCMoveTo:create(speedNum, ccp(curPosX+self.leftMovDis.x,curPosY+self.leftMovDis.y))
            local  leftTraceMoveTo=CCMoveBy:create(speedNum, self.mapmoveBy[1])
            local  leftTraceFunc=CCCallFuncN:create(reSetLeftTrace)
            local leftTraceSeq=CCSequence:createWithTwoActions(leftTraceMoveTo,leftTraceFunc)
            self.l_traceLayer:runAction(leftTraceSeq)
        end
        local curPosX,curPosY=self.l_traceLayer:getPosition()
        -- local  leftTraceMoveTo=CCMoveTo:create(speedNum, ccp(curPosX+self.leftMovDis.x,curPosY+self.leftMovDis.y))
        local  leftTraceMoveTo=CCMoveBy:create(speedNum, self.mapmoveBy[1])
        local  leftTraceFunc=CCCallFuncN:create(reSetLeftTrace)
        local leftTraceSeq=CCSequence:createWithTwoActions(leftTraceMoveTo,leftTraceFunc)
        self.l_traceLayer:runAction(leftTraceSeq)

        local function reSetRightTrace()
            self.r_traceLayer:stopAllActions()
            local curPosX,curPosY=self.r_traceLayer:getPosition()
            -- local  rightTraceMoveTo=CCMoveTo:create(speedNum, ccp(curPosX+self.rightMovDis.x,curPosY+self.rightMovDis.y))
            local  rightTraceMoveTo=CCMoveBy:create(speedNum, self.mapmoveBy[2])
            local  rightTraceFunc=CCCallFuncN:create(reSetRightTrace)
            local rightTraceSeq=CCSequence:createWithTwoActions(rightTraceMoveTo,rightTraceFunc)
            self.r_traceLayer:runAction(rightTraceSeq)
        end
        local curPosX,curPosY=self.r_traceLayer:getPosition()
        local rightTraceMoveTo=CCMoveBy:create(speedNum, self.mapmoveBy[2])
        -- local  rightTraceMoveTo=CCMoveTo:create(speedNum, ccp(curPosX+self.rightMovDis.x,curPosY+self.rightMovDis.y))
        local  rightTraceFunc=CCCallFuncN:create(reSetRightTrace)
        local rightTraceSeq=CCSequence:createWithTwoActions(rightTraceMoveTo,rightTraceFunc)
        self.r_traceLayer:runAction(rightTraceSeq)
    --
        --爆炸效果层移动
        local function reSetLeftTrace()
            self.l_bombLayer:stopAllActions()
            local curPosX,curPosY=self.l_bombLayer:getPosition()
            -- local  leftTraceMoveTo=CCMoveTo:create(speedNum, ccp(curPosX+self.leftMovDis.x,curPosY+self.leftMovDis.y))
            local  leftTraceMoveTo=CCMoveBy:create(speedNum, self.mapmoveBy[1])
            local  leftTraceFunc=CCCallFuncN:create(reSetLeftTrace)
            local leftTraceSeq=CCSequence:createWithTwoActions(leftTraceMoveTo,leftTraceFunc)
            self.l_bombLayer:runAction(leftTraceSeq)
        end
        local curPosX,curPosY=self.l_bombLayer:getPosition()
        -- local  leftTraceMoveTo=CCMoveTo:create(speedNum, ccp(curPosX+self.leftMovDis.x,curPosY+self.leftMovDis.y))
        local  leftTraceMoveTo=CCMoveBy:create(speedNum, self.mapmoveBy[1])
        local  leftTraceFunc=CCCallFuncN:create(reSetLeftTrace)
        local leftTraceSeq=CCSequence:createWithTwoActions(leftTraceMoveTo,leftTraceFunc)
        self.l_bombLayer:runAction(leftTraceSeq)
        
        local function reSetRightTrace()
            self.r_bombLayer:stopAllActions()
            local curPosX,curPosY=self.r_bombLayer:getPosition()
            -- local  rightTraceMoveTo=CCMoveTo:create(speedNum, ccp(curPosX+self.rightMovDis.x,curPosY+self.rightMovDis.y))
            local rightTraceMoveTo = CCMoveBy:create(speedNum, self.mapmoveBy[2])
            local  rightTraceFunc=CCCallFuncN:create(reSetRightTrace)
            local rightTraceSeq=CCSequence:createWithTwoActions(rightTraceMoveTo,rightTraceFunc)
            self.r_bombLayer:runAction(rightTraceSeq)
        end
        local curPosX,curPosY=self.r_bombLayer:getPosition()
        local rightTraceMoveTo=CCMoveBy:create(speedNum, self.mapmoveBy[2])
        -- local  rightTraceMoveTo=CCMoveTo:create(speedNum, ccp(curPosX+self.rightMovDis.x,curPosY+self.rightMovDis.y))
        local  rightTraceFunc=CCCallFuncN:create(reSetRightTrace)
        local rightTraceSeq=CCSequence:createWithTwoActions(rightTraceMoveTo,rightTraceFunc)
        self.r_bombLayer:runAction(rightTraceSeq)
end

function BossBattleScene:vsMoveAction()

    --VS动画
    local size=G_VisibleSize
    self.VSp=CCSprite:createWithSpriteFrameName("v.png")
    self.SSp=CCSprite:createWithSpriteFrameName("s.png")
    self.VSp:setAnchorPoint(ccp(0.5,0.5))
    self.SSp:setAnchorPoint(ccp(0.5,0.5))
    self.VSp:setPosition(ccp(-self.VSp:getContentSize().width/2,size.height/2))
    self.SSp:setPosition(ccp(size.width+self.VSp:getContentSize().width/2,size.height/2))
    local VaimPos=ccp(size.width/2-self.VSp:getContentSize().width/2+15,size.height/2)
    local SaimPos=ccp(size.width/2+self.SSp:getContentSize().width/2-15,size.height/2)
    local function reSetV()
        self.VSp:stopAllActions()
        local delay=CCDelayTime:create(0.5)
        local scaleTo=CCScaleTo:create(0.3,0.5)
        local mvTo=CCMoveTo:create(0.3,ccp(size.width/2-25,size.height-40))
        local carray=CCArray:create()
        carray:addObject(mvTo)
        carray:addObject(scaleTo)
        local spawn=CCSpawn:create(carray)
        local upVSeq=CCSequence:createWithTwoActions(delay,spawn)
        self.VSp:runAction(upVSeq)
        --vs碰撞动画
           local pzFrameName="vs1.png" --碰撞动画
           local vsPzSp=CCSprite:createWithSpriteFrameName(pzFrameName)
           local pzArr=CCArray:create()
            for kk=1,10 do
                local nameStr="vs"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
           end
           local animation=CCAnimation:createWithSpriteFrames(pzArr)
           animation:setDelayPerUnit(0.05)
           local animate=CCAnimate:create(animation)
           vsPzSp:setAnchorPoint(ccp(0.5,0.5))
           vsPzSp:setPosition(ccp(size.width/2,size.height/2))
           self.container:addChild(vsPzSp,20)
           vsPzSp:setScale(5)
           local function removePzSp()
                vsPzSp:removeFromParentAndCleanup(true)
           end
           local  animEnd=CCCallFuncN:create(removePzSp)
           local  pzSeq=CCSequence:createWithTwoActions(animate,animEnd)
           vsPzSp:runAction(pzSeq)
    end
    local  VFunc=CCCallFuncN:create(reSetV);
    local VMoveTo=CCMoveTo:create(0.3,VaimPos)
    local Vseq = CCSequence:createWithTwoActions(VMoveTo,VFunc)
    self.VSp:runAction(Vseq)
    
    local function reSetS()
        self.SSp:stopAllActions()
        local delay=CCDelayTime:create(0.5)
        local scaleTo=CCScaleTo:create(0.3,0.5)
        local mvTo=CCMoveTo:create(0.3,ccp(size.width/2+25,size.height-40))
        local carray=CCArray:create()
        carray:addObject(mvTo)
        carray:addObject(scaleTo)
        local spawn=CCSpawn:create(carray)
        local function moveEndHandler()
            self:vsActiononTop()
        end
        local  moveEndFunc=CCCallFuncN:create(moveEndHandler);
        --local upSSeq=CCSequence:createWithTwoActions(delay,spawn)
        local acArray=CCArray:create()
        acArray:addObject(delay)
        acArray:addObject(spawn)
        acArray:addObject(moveEndFunc)
        local upSSeq=CCSequence:create(acArray)
        self.SSp:runAction(upSSeq)
    end
    local  SFunc=CCCallFuncN:create(reSetS);
    local SMoveTo=CCMoveTo:create(0.3,SaimPos)
    local Sseq = CCSequence:createWithTwoActions(SMoveTo,SFunc)
    self.SSp:runAction(Sseq)
    self.container:addChild(self.VSp,15)
    self.container:addChild(self.SSp,15)
    PlayEffect(audioCfg.battle_VS)
end

function BossBattleScene:vsActiononTop()
            local size=G_VisibleSize
           local pzFrameName="VSTop1.png" --动画
           local vsPzSp=CCSprite:createWithSpriteFrameName(pzFrameName)
           local pzArr=CCArray:create()
            for kk=1,6 do
                local nameStr="VSTop"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
           end
           local animation=CCAnimation:createWithSpriteFrames(pzArr)
           animation:setDelayPerUnit(0.05)
           local animate=CCAnimate:create(animation)
           vsPzSp:setAnchorPoint(ccp(0.5,0.5))
           vsPzSp:setPosition(ccp(size.width/2,size.height-45))
           self.container:addChild(vsPzSp,20)
           vsPzSp:setScale(3)
           local function removePzSp()
                vsPzSp:removeFromParentAndCleanup(true)
                if base.emblemSwitch == 1 and self.emblemData and SizeOfTable(self.emblemData) == 2 and (self.emblemData[1] ~= 0 or self.emblemData[2] ~= 0) then
                    self:showSuperEquipAc()
                elseif self.airShipTb and next(self.airShipTb) then
                    self:showAirShip()
                else
                  self.startFire=true
                end
           end
           local  animEnd=CCCallFuncN:create(removePzSp)
           local  pzSeq=CCSequence:createWithTwoActions(animate,animEnd)
           vsPzSp:runAction(pzSeq)
           self:showHH()
end

function BossBattleScene:showHH() --显示回合
    local size=G_VisibleSize
    if self.hhSp ==nil then
      self.hhSp=CCSprite:createWithSpriteFrameName("VS_RoundBg.png")
      self.hhSp:setAnchorPoint(ccp(0.5,0.5))
      self.hhSp:setPosition(ccp(size.width/2,size.height-91))
      self.container:addChild(self.hhSp,20)
    end
    --self.playerData=
    if self.hhLb ==nil then
      self.hhLb=GetTTFLabel(getlocal("battle_Count",{self.hhNum}),22)
      self.hhLb:setAnchorPoint(ccp(0.5,0.5))
      self.hhLb:setPosition(ccp(self.hhSp:getContentSize().width/2,self.hhSp:getContentSize().height/2))
      self.hhSp:addChild(self.hhLb,1)
    else
      self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
    end
           local pzFrameName="VSacross1.png" --回合动画
           local vsPzSp=CCSprite:createWithSpriteFrameName(pzFrameName)
           local pzArr=CCArray:create()
            for kk=1,6 do
                local nameStr="VSacross"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
           end
           local animation=CCAnimation:createWithSpriteFrames(pzArr)
           animation:setDelayPerUnit(0.05)
           local animate=CCAnimate:create(animation)
           vsPzSp:setAnchorPoint(ccp(0.5,0.5))
           vsPzSp:setPosition(ccp(self.hhSp:getContentSize().width/2,self.hhSp:getContentSize().height/2))
           self.hhSp:addChild(vsPzSp,3)
           vsPzSp:setScale(4)
           local function removePzSp()
                vsPzSp:removeFromParentAndCleanup(true)
           end
           local  animEnd=CCCallFuncN:create(removePzSp)
           local  pzSeq=CCSequence:createWithTwoActions(animate,animEnd)
           vsPzSp:runAction(pzSeq) 
end


--播放装备动画
function BossBattleScene:showSuperEquipAc()
    --战斗双方信息显示
     local leftPName,rightPName
     if tonumber(self.playerData[2][1])==nil or tonumber(self.playerData[2][1])>7 then
         leftPName=self.playerData[2][1]
         if tonumber(leftPName)~=nil then
            leftPName=arenaVoApi:getNpcNameById(tonumber(leftPName))
         end
     else
          if self.alienBattleData then
              leftPName=getlocal("alienMines_island_name_"..self.playerData[2][1])
          else
              if self.playerData[2][1]==7 then
                  local rebelLv,rebelID=1,1
                  if self.rebel then
                      rebelLv,rebelID=self.rebel.rebelLv or 1,self.rebel.rebelID or 1
                  end
                  leftPName=G_getIslandName(self.playerData[2][1],nil,rebelLv,rebelID,false)
              else
                  leftPName=getlocal("world_island_"..self.playerData[2][1])
              end
          end
     end
     if tonumber(self.playerData[1][1])==nil or tonumber(self.playerData[1][1])>7 then
         rightPName=self.playerData[1][1]
         if tonumber(rightPName)~=nil then
            rightPName=arenaVoApi:getNpcNameById(tonumber(rightPName))
         end
     else
          if self.alienBattleData then
              rightPName=getlocal("alienMines_island_name_"..self.playerData[1][1])
          else
              if self.playerData[1][1]==7 then
                  local rebelLv,rebelID=1,1
                  if self.rebel then
                      rebelLv,rebelID=self.rebel.rebelLv or 1,self.rebel.rebelID or 1
                  end
                  rightPName=G_getIslandName(self.playerData[1][1],nil,rebelLv,rebelID,false)
              else
                  rightPName=getlocal("world_island_"..self.playerData[1][1])
              end
          end
     end
     local nameHeight = 75
     if platCfg.platUseUIWindow[G_curPlatName()]~=nil and platCfg.platUseUIWindow[G_curPlatName()]==2 then
          nameHeight = 65
      end

      if self.playerUid1~=nil and self.playerUid1==0 then
         rightPName=getlocal(rightPName)
      end
      if self.playerUid2~=nil and self.playerUid2==0 then
         leftPName=getlocal(leftPName)
      end
      if self.acData and self.acData.type and self.acData.type=="banzhangshilian" then
          rightPName=getlocal("sample_enemy")
      end

      if self.battleType==1 then
          if tonumber(self.playerData[1][1])==-1 then
              rightPName=getlocal("local_war_npc_name")
          end
          if tonumber(self.playerData[2][1])==-1 then
              leftPName=getlocal("local_war_npc_name")
          end
      elseif self.battleType==2 then
          if tonumber(self.playerData[1][1]) then
              rightPName=superWeaponVoApi:getSWChallengeName(self.playerData[1][1])
          end
      elseif self.battleType==3 then
          if tonumber(self.playerData[1][1]) and tonumber(self.playerData[1][1])<=10 then
              rightPName=getlocal("super_weapon_rob_npc_name_"..tonumber(self.playerData[1][1]))
          end
      elseif self.battleType==4 then
          if tonumber(self.playerData[1][1]) and tonumber(self.playerData[1][1])<10 then
              rightPName=getlocal("plat_war_donate_troops_"..tonumber(self.playerData[1][1]))
          end
          if tonumber(self.playerData[2][1]) and tonumber(self.playerData[2][1])<10 then
              leftPName=getlocal("plat_war_donate_troops_"..tonumber(self.playerData[2][1]))
          end
      elseif self.battleType==5 then
         if tonumber(self.playerData[1][1]) then
              rightPName=arenaVoApi:getNpcNameById(tonumber(self.playerData[1][1]))
         end
      elseif self.battleType==6 then
          if tonumber(self.playerData[1][1])==-1 then
              rightPName=getlocal("local_war_npc_name")
          elseif tonumber(self.playerData[1][1])==0 then
              rightPName=getlocal("serverWarLocal_npc_boss")
          end
          if tonumber(self.playerData[2][1])==-1 then
              leftPName=getlocal("local_war_npc_name")
          elseif tonumber(self.playerData[2][1])==0 then
              leftPName=getlocal("serverWarLocal_npc_boss")
          end
      end

      local leftEquipId = self.emblemData[2] ~= 0 and self.emblemData[2] or nil
      local rightEquipId = self.emblemData[1] ~= 0 and self.emblemData[1] or nil
      local rect = CCRect(0, 0, 50, 50);
      local capInSet = CCRect(20, 20, 10, 10);
      local function cellClick(hd,fn,idx)

      end
      local mt,dt=0.2,1.1
      --军徽技能显示动画
      local function playSkillNameLbAction(sknameLb,skidx,skcount)
        if sknameLb==nil then
          do return end
        end
        local acArr=CCArray:create()
        acArr:addObject(CCDelayTime:create(mt/self.warSpeed))
        if skidx==1 then
          acArr:addObject(CCDelayTime:create(0.2/self.warSpeed))
        end
        if skidx>1 then
          sknameLb:setOpacity(0)
          acArr:addObject(CCDelayTime:create((skidx-1)*0.4/self.warSpeed))
          acArr:addObject(CCFadeIn:create(0.1/self.warSpeed))
          acArr:addObject(CCDelayTime:create(0.1/self.warSpeed))
        end
        if skidx<skcount then
          local ft=0.2/self.warSpeed
          local fadeOut=CCFadeOut:create(ft)
          local moveTo=CCMoveBy:create(ft,ccp(0,40))
          local arr=CCArray:create()
          arr:addObject(fadeOut)
          arr:addObject(moveTo)
          local spawn=CCSpawn:create(arr)
          acArr:addObject(spawn)
        end
        local seq=CCSequence:create(acArr)
        sknameLb:runAction(seq)
      end
      if leftEquipId ~= nil then
          local leftEquipCfg = emblemVoApi:getEquipCfgById(leftEquipId)
          local leftPanel = CCSprite:create("public/emblem/emblemBattleBg1.png") --LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",capInSet,cellClick)--对话背景
          leftPanel:ignoreAnchorPointForPosition(false)
          leftPanel:setAnchorPoint(ccp(1,0.5))
          leftPanel:setScaleY(1.2)
          leftPanel:setPosition(ccp(0,G_VisibleSizeHeight * 0.2))
          self.container:addChild(leftPanel,20)
          local leftLayerSize=CCSizeMake(leftPanel:getContentSize().width*leftPanel:getScaleX(),leftPanel:getContentSize().height*leftPanel:getScaleY())
          local leftLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
          leftLayer:setContentSize(leftLayerSize)
          leftLayer:setAnchorPoint(ccp(1,0.5))
          leftLayer:setPosition(leftPanel:getPosition())
          leftLayer:setOpacity(0)
          self.container:addChild(leftLayer,21)

          local leftPlayerLb=GetTTFLabel(leftPName,22)
          leftPlayerLb:setAnchorPoint(ccp(0,1))
          leftPlayerLb:setPosition(ccp(20,leftLayerSize.height-10))
          leftLayer:addChild(leftPlayerLb)

          local leftEquipIcon = emblemVoApi:getEquipIconNoBg(leftEquipId,22)
          leftEquipIcon:setAnchorPoint(ccp(0,0))
          leftEquipIcon:setPosition(ccp(37,35))
          leftLayer:addChild(leftEquipIcon)
          local attUp,skillTb,showPosTb
          if emblemTroopVoApi:checkIfIsEmblemTroopById(leftEquipId)==true then
            attUp=emblemTroopVoApi:getTroopAllAttUpByJointId(leftEquipId)
            leftEquipIcon:setPosition(45,35)
            skillTb,showPosTb=emblemTroopVoApi:getTroopSkillsByJointIdForBattle(leftEquipId)
          else
            attUp=leftEquipCfg.attUp
            if leftEquipCfg.skill then
              skillTb={leftEquipCfg.skill}
            end
          end
          if attUp ~= nil then
            local startY = leftLayerSize.height - 105 -- 220- 10 - 50/2
            if skillTb and SizeOfTable(skillTb)>0 then
              startY=leftLayerSize.height - 80
            end
            local startX = 230
            local iconSize=30
            local showAttup = emblemVoApi:getEquipAttUpForShow(attUp)
            for k,v in pairs(showAttup) do
              local attkey=buffKeyMatchCodeCfg[v[1]]
              if attkey and buffEffectCfg[attkey] and buffEffectCfg[attkey].icon2 then
                local pic=buffEffectCfg[attkey].icon2
                local attriSp=CCSprite:createWithSpriteFrameName(pic)
                attriSp:setAnchorPoint(ccp(0,0.5))
                attriSp:setScale(iconSize/attriSp:getContentSize().width)
                local px=startX+math.floor((k-1)/4)*140
                local py=0
                if k>4 then
                  py=startY-(k-5)*(iconSize+5)
                else
                  py=startY-(k-1)*(iconSize+5)
                end
                attriSp:setPosition(px,py)
                leftLayer:addChild(attriSp)

                local attLbAdd
                if v[1] == "troopsAdd" or v[1] == "first" then
                  attLbAdd=GetTTFLabel("+"..(v[2]),20)
                else
                  attLbAdd=GetTTFLabel("+"..(v[2] * 100).."%",20)
                end
                attLbAdd:setAnchorPoint(ccp(0,0.5))
                attLbAdd:setPosition(ccp(px+iconSize+5,py))
                attLbAdd:setColor(G_LowfiColorGreen)
                leftLayer:addChild(attLbAdd)
              end
            end
            if skillTb then
              local skcount=SizeOfTable(skillTb)
              if skcount>0 then
                local startX=220
                local skillBg=CCSprite:createWithSpriteFrameName("emblemSkillGreen.png")
                skillBg:setAnchorPoint(ccp(0,0))
                skillBg:setPosition(ccp(startX-skillBg:getContentSize().width*0.2,5))
                leftLayer:addChild(skillBg)
                local skid,skl,sknameStr
                for k,v in pairs(skillTb) do
                  skid,skl=v[1],v[2]
                  sknameStr=emblemVoApi:getEquipSkillNameById(skid,skl)
                  local sknameLb=GetTTFLabelWrap(sknameStr,20,CCSizeMake(skillBg:getContentSize().width - 110,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                  sknameLb:setAnchorPoint(ccp(0,0.5))
                  sknameLb:setPosition(ccp(skillBg:getContentSize().width*0.2,skillBg:getContentSize().height*0.5))
                  skillBg:addChild(sknameLb)

                  playSkillNameLbAction(sknameLb,k,skcount)
                end
              end
              if showPosTb then --军徽技能对应的位置动画
                for k,v in pairs(showPosTb) do
                  local acArr=CCArray:create()
                  local starSp=tolua.cast(leftEquipIcon:getChildByTag(10+tonumber(v)),"CCSprite")
                  if starSp then
                    acArr:addObject(CCDelayTime:create(mt/self.warSpeed))
                    acArr:addObject(CCDelayTime:create((tonumber(v)-1)*0.4/self.warSpeed))
                    acArr:addObject(CCBlink:create(0.2,2))
                    local seq=CCSequence:create(acArr)
                    starSp:runAction(seq)
                  end
                end
              end
            end
          end
          local leftPanelTb={leftPanel,leftLayer}
          for k,v in pairs(leftPanelTb) do
            local moveto = CCMoveTo:create(mt/self.warSpeed, CCPointMake(leftLayerSize.width >  G_VisibleSizeWidth and G_VisibleSizeWidth or leftLayerSize.width,G_VisibleSizeHeight * 0.2))
            local delay = CCDelayTime:create(dt/self.warSpeed)
            local moveBack = CCMoveTo:create(mt/self.warSpeed, CCPointMake(0, G_VisibleSizeHeight* 0.2))
            local function removeLeftPanel()
              v:stopAllActions()
              v:removeAllChildrenWithCleanup(true)
              v:removeFromParentAndCleanup(true)
              v = nil
              if rightEquipId == nil and k==2 then
                self:showFightUpAc()
                leftPanelTb=nil
              end
            end
            local clearFun = CCCallFuncN:create(removeLeftPanel)
            local acArr = CCArray:create()
            acArr:addObject(moveto)
            acArr:addObject(delay)
            acArr:addObject(moveBack)
            acArr:addObject(clearFun)

            local seq = CCSequence:create(acArr)
            v:runAction(seq)
          end

      end

      
      local rightEquipCfg
      if rightEquipId ~= nil then
          rightEquipCfg = emblemVoApi:getEquipCfgById(rightEquipId)
          local rightPanel = CCSprite:create("public/emblem/emblemBattleBg2.png")--LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",capInSet,cellClick)--对话背景
          rightPanel:ignoreAnchorPointForPosition(false)
          rightPanel:setAnchorPoint(ccp(0,0.5))
          rightPanel:setScaleY(1.2)
          rightPanel:setPosition(ccp(G_VisibleSizeWidth,G_VisibleSizeHeight * 0.8))
          self.container:addChild(rightPanel,20)

          local rightLayerSize=CCSizeMake(rightPanel:getContentSize().width*rightPanel:getScaleX(),rightPanel:getContentSize().height*rightPanel:getScaleY())
          local rightLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
          rightLayer:setContentSize(rightLayerSize)
          rightLayer:setAnchorPoint(ccp(0,0.5))
          rightLayer:setPosition(rightPanel:getPosition())
          rightLayer:setOpacity(0)
          self.container:addChild(rightLayer,21)

          local rightPlayerLb=GetTTFLabel(rightPName,22)
          rightPlayerLb:setAnchorPoint(ccp(1,1))
          rightPlayerLb:setPosition(rightLayerSize.width - 20,rightLayerSize.height - 10)
          rightLayer:addChild(rightPlayerLb)

          local rightEquipIcon = emblemVoApi:getEquipIconNoBg(rightEquipId,22)
          rightEquipIcon:setAnchorPoint(ccp(1,0))
          rightEquipIcon:setPosition(ccp(rightLayerSize.width - 37,35))
          rightLayer:addChild(rightEquipIcon)
          local attUp,skillTb,showPosTb
          if emblemTroopVoApi:checkIfIsEmblemTroopById(rightEquipId)==true then
            attUp=emblemTroopVoApi:getTroopAllAttUpByJointId(rightEquipId)
            leftEquipIcon:setPosition(45,35)
            skillTb,showPosTb=emblemTroopVoApi:getTroopSkillsByJointIdForBattle(rightEquipId)
          else
            attUp=leftEquipCfg.attUp
            if leftEquipCfg.skill then
              skillTb={leftEquipCfg.skill}
            end
          end
          if attUp ~= nil then
            local startY = rightLayerSize.height - 105 -- 220- 10 - 50/2
            if skillTb and SizeOfTable(skillTb)>0 then
              startY=rightLayerSize.height - 80
            end
            local startX = rightLayerSize.width - 300
            local iconSize=30
            local showAttup = emblemVoApi:getEquipAttUpForShow(attUp)
            for k,v in pairs(showAttup) do
              local attkey=buffKeyMatchCodeCfg[v[1]]
              if attkey and buffEffectCfg[attkey] and buffEffectCfg[attkey].icon2 then
                local pic=buffEffectCfg[attkey].icon2
                local attriSp=CCSprite:createWithSpriteFrameName(pic)
                attriSp:setAnchorPoint(ccp(0,0.5))
                attriSp:setScale(iconSize/attriSp:getContentSize().width)
                local px=startX-math.floor((k-1)/4)*140
                local py=0
                if k>4 then
                  py=startY-(k-5)*(iconSize+5)
                else
                  py=startY-(k-1)*(iconSize+5)
                end
                attriSp:setPosition(px,py)
                rightLayer:addChild(attriSp)

                local attLbAdd
                if v[1] == "troopsAdd" or v[1] == "first" then
                  attLbAdd=GetTTFLabel("+"..(v[2]),20)
                else
                  attLbAdd=GetTTFLabel("+"..(v[2] * 100).."%",20)
                end
                attLbAdd:setAnchorPoint(ccp(0,0.5))
                attLbAdd:setPosition(ccp(px+iconSize+5,py))
                attLbAdd:setColor(G_LowfiColorGreen)
                rightLayer:addChild(attLbAdd)
              end
            end
            if skillTb then
              local skcount=SizeOfTable(skillTb)
              if skcount>0 then
                local startX=220
                local skillBg=CCSprite:createWithSpriteFrameName("emblemSkillRed.png")
                skillBg:setAnchorPoint(ccp(1,0))
                skillBg:setFlipX(true)
                skillBg:setPosition(ccp(rightLayerSize.width-startX+skillBg:getContentSize().width*0.2,5))
                rightLayer:addChild(skillBg)
                local skid,skl,sknameStr
                for k,v in pairs(skillTb) do
                  local skid,skl=v[1],v[2] --技能id和等级
                  local sknameStr=emblemVoApi:getEquipSkillNameById(skid,skl)
                  local sknameLb=GetTTFLabelWrap(sknameStr,20,CCSizeMake(skillBg:getContentSize().width-10,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
                  sknameLb:setAnchorPoint(ccp(1,0.5))
                  sknameLb:setPosition(ccp(skillBg:getContentSize().width*0.8,skillBg:getContentSize().height*0.5))
                  skillBg:addChild(sknameLb)

                  playSkillNameLbAction(sknameLb,k,skcount)
                end
              end
              if showPosTb then --军徽技能对应的位置动画
                for k,v in pairs(showPosTb) do
                  local acArr=CCArray:create()
                  local starSp=tolua.cast(rightEquipIcon:getChildByTag(10+tonumber(v)),"CCSprite")
                  if starSp then
                    acArr:addObject(CCDelayTime:create(mt/self.warSpeed))
                    acArr:addObject(CCDelayTime:create((tonumber(v)-1)*0.4/self.warSpeed))
                    acArr:addObject(CCBlink:create(0.2/self.warSpeed,2))
                    local seq=CCSequence:create(acArr)
                    starSp:runAction(seq)
                  end
                end
              end
            end
          end
          local rightPanelTb={rightPanel,rightLayer}
          for k,v in pairs(rightPanelTb) do
            local rMoveto = CCMoveTo:create(mt/self.warSpeed, CCPointMake(rightLayerSize.width >= G_VisibleSizeWidth and 0 or G_VisibleSizeWidth - rightLayerSize.width, G_VisibleSizeHeight* 0.8))
            local rDelay = CCDelayTime:create(dt/self.warSpeed)
            local rMoveBack = CCMoveTo:create(mt/self.warSpeed, CCPointMake(G_VisibleSizeWidth, G_VisibleSizeHeight* 0.8))
            local function removeRightPanel()
              v:stopAllActions()
              v:removeAllChildrenWithCleanup(true)
              v:removeFromParentAndCleanup(true)
              v = nil
              if k==2 then
                self:showFightUpAc()
                rightPanelTb=nil
              end
            end
            local rClearFun = CCCallFuncN:create(removeRightPanel)
            local rAcArr = CCArray:create()
            rAcArr:addObject(rMoveto)
            rAcArr:addObject(rDelay)
            rAcArr:addObject(rMoveBack)
            rAcArr:addObject(rClearFun)

            local rSeq = CCSequence:create(rAcArr)
            v:runAction(rSeq)
          end
      end
end

--播放战斗力提升的动画
function BossBattleScene:showFightUpAc()
    self.superequipAcTb = {}
    --乙方
    if self.emblemData~=nil then
      if self.emblemData[1]~=0 then
        --对方
        local spX,spY
        for k,v in pairs(self.allT1) do
          spX = v.sprite:getContentSize().width/2-50
          spY = v.sprite:getContentSize().height/2+20
          local fightAddSp = CCSprite:createWithSpriteFrameName("emblem_addFight1.png")
          fightAddSp:setAnchorPoint(ccp(1,0))
          fightAddSp:setPosition(ccp(spX,spY))
          v.sprite:addChild(fightAddSp)
          local pzArr=CCArray:create()
          for kk=2,8 do
              local nameStr="emblem_addFight"..kk..".png"
              local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
              pzArr:addObject(frame)
          end
          local animation=CCAnimation:createWithSpriteFrames(pzArr)
          animation:setDelayPerUnit(0.12/self.warSpeed)
          local animate=CCAnimate:create(animation)
          local repeatForever=CCRepeatForever:create(animate)
          fightAddSp:runAction(repeatForever)
          table.insert(self.superequipAcTb,fightAddSp)

          local fightAddLb = GetTTFLabel(getlocal("emblem_fightAdd"),20)
          fightAddLb:setColor(G_ColorGreen)
          fightAddLb:setAnchorPoint(ccp(0,1))
          fightAddLb:setPosition(ccp(spX,spY-fightAddLb:getContentSize().height))
          v.sprite:addChild(fightAddLb)
          fightAddLb:setOpacity(0)
          table.insert(self.superequipAcTb,fightAddLb)

          local fadeIn=CCFadeIn:create(0.5/self.warSpeed)
          local moveTo1=CCMoveTo:create(0.5/self.warSpeed,ccp(spX,spY+fightAddSp:getContentSize().height/2))
          local fadeInArr=CCArray:create()
          fadeInArr:addObject(fadeIn)
          fadeInArr:addObject(moveTo1)
          local fadeInSpawn=CCSpawn:create(fadeInArr)
          local fadeOut=CCFadeOut:create(0.5/self.warSpeed)
          local moveTo2=CCMoveTo:create(0.5/self.warSpeed,ccp(spX,spY+fightAddSp:getContentSize().height))
          local fadeOutArr=CCArray:create()
          fadeOutArr:addObject(fadeOut)
          fadeOutArr:addObject(moveTo2)
          local fadeOutSpawn=CCSpawn:create(fadeOutArr)
          local delay=CCDelayTime:create(0.8/self.warSpeed)
          local acArr=CCArray:create()
          acArr:addObject(fadeInSpawn)
          acArr:addObject(fadeOutSpawn)
          local seq=CCSequence:create(acArr)
          fightAddLb:runAction(seq)
        end
      end
      if self.emblemData[2]~=0 then
        local spX,spY
        for k,v in pairs(self.allT2) do
          spX = v.sprite:getContentSize().width/2-50--+10
          spY = v.sprite:getContentSize().height/2+20
          local fightAddSp = CCSprite:createWithSpriteFrameName("emblem_addFight1.png")
          fightAddSp:setAnchorPoint(ccp(1,0))
          fightAddSp:setPosition(ccp(spX,spY))
          v.sprite:addChild(fightAddSp)
          local pzArr=CCArray:create()
          for kk=2,8 do
              local nameStr="emblem_addFight"..kk..".png"
              local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
              pzArr:addObject(frame)
          end
          local animation=CCAnimation:createWithSpriteFrames(pzArr)
          animation:setDelayPerUnit(0.12/self.warSpeed)
          local animate=CCAnimate:create(animation)
          fightAddSp:runAction(animate)
          table.insert(self.superequipAcTb,fightAddSp)

          local fightAddLb = GetTTFLabel(getlocal("emblem_fightAdd"),20)
          fightAddLb:setColor(G_ColorGreen)
          fightAddLb:setAnchorPoint(ccp(0,1))
          fightAddLb:setPosition(ccp(spX,spY-fightAddLb:getContentSize().height))
          v.sprite:addChild(fightAddLb)
          fightAddLb:setOpacity(0)
          table.insert(self.superequipAcTb,fightAddLb)

          local fadeIn=CCFadeIn:create(0.5/self.warSpeed)
          local moveTo1=CCMoveTo:create(0.5/self.warSpeed,ccp(spX,spY+fightAddSp:getContentSize().height/2))
          local fadeInArr=CCArray:create()
          fadeInArr:addObject(fadeIn)
          fadeInArr:addObject(moveTo1)
          local fadeInSpawn=CCSpawn:create(fadeInArr)
          local fadeOut=CCFadeOut:create(0.5/self.warSpeed)
          local moveTo2=CCMoveTo:create(0.5/self.warSpeed,ccp(spX,spY+fightAddSp:getContentSize().height))
          local fadeOutArr=CCArray:create()
          fadeOutArr:addObject(fadeOut)
          fadeOutArr:addObject(moveTo2)
          local fadeOutSpawn=CCSpawn:create(fadeOutArr)
          local delay=CCDelayTime:create(0.8/self.warSpeed)
          local acArr=CCArray:create()
          acArr:addObject(fadeInSpawn)
          acArr:addObject(fadeOutSpawn)
          local seq=CCSequence:create(acArr)
          fightAddLb:runAction(seq)
        end
      end
    end
    
    local delay = CCDelayTime:create(1.1)
    local function startFire()
      if self.superequipAcTb then
        for k,v in pairs(self.superequipAcTb) do
          if v then
             v:stopAllActions()
             v:removeFromParentAndCleanup(true)
             v = nil
          end
        end
        self.superequipAcTb = nil
      end
      if self.airShipTb and next(self.airShipTb) then
          self:showAirShip()
      else
        self.startFire = true
      end
    end
    local startFun = CCCallFuncN:create(startFire)
    local seq = CCSequence:createWithTwoActions(delay,startFun)
    self.container:runAction(seq)
end

function BossBattleScene:airShipRandomStayMov(rNum, pNum,thisShipNum)
    local det1num = rNum == 1 and 0.2 or 0.5
    local useT = math.random(2,4)

    local ccpAdd1

    if pNum < 3 then
        ccpAdd1 = pNum == 1 and ccp(15,15) or ccp(-15,-15)
    else
        ccpAdd1 = pNum == 3 and ccp(15,-15) or ccp(-15,15)
    end

    local isReverse = thisShipNum == 2
    if self.airShipSpTb[thisShipNum] then
        local movPos,movPos2
        local posx,addPosy
        if isReverse then
            if self.airShipTb[thisShipNum][1] == 6 then
                posx = -70
                addPosy = -20
            elseif self.airShipTb[thisShipNum][1] == 7 then
                posx = -40
                addPosy = -30
            else
                posx = - 80
                addPosy = 0
            end
            movPos2 = ccp(posx,G_VisibleSizeHeight * 0.49 + addPosy)
        else 
            det1num = rNum == 1 and 0.5 or 0.2
            useT = math.random(2,4)

            if self.airShipTb[thisShipNum][1] == 6 then
                posx = G_VisibleSizeWidth + 60
                addPosy = 10
            elseif self.airShipTb[thisShipNum][1] == 7 then
                  posx = G_VisibleSizeWidth + 10
                  addPosy = -35
            else
                posx = G_VisibleSizeWidth + 80
                addPosy = 0
            end

            movPos2 = ccp(posx,G_VisibleSizeHeight * 0.51 + addPosy)
        end
        movPos = ccpAdd( movPos2,ccpAdd1)
        local detTime1 = CCDelayTime:create(det1num)
        local movTo1 = CCMoveTo:create(useT,movPos)
        local sineOut1 = CCEaseSineIn:create(movTo1)

        local detTime2 = CCDelayTime:create(0.4)
        local movTo2 = CCMoveTo:create(useT,movPos2)
        local sineOut2 = CCEaseSineOut:create(movTo2)

        local function endMovHandl()
            local randomNum = math.random(1,2)
            local pointNum = math.random(1,4)

            self:airShipRandomStayMov(randomNum, pointNum, thisShipNum)  
        end
        local endMovCall = CCCallFunc:create(endMovHandl)
        local stayMovArr = CCArray:create()
        stayMovArr:addObject(detTime1)
        stayMovArr:addObject(sineOut1)
        stayMovArr:addObject(detTime2)
        stayMovArr:addObject(sineOut2)
        stayMovArr:addObject(endMovCall)
        local smSeq = CCSequence:create(stayMovArr)
        self.airShipSpTb[thisShipNum]:runAction(smSeq)
    end
end
function BossBattleScene:runAirShipStaying( )
    local delT = CCDelayTime:create(2 * G_battleSpeed)
    local function createStayShipHandl()
        if self.airShipSpTb then
          do return end--此时已经进入飞艇结束动画，不需要停留效果
        else
          self.airShipSpTb = {}
        end
        self.hasStayAirShip = true
        local airShipTb = self.airShipTb
        for k,v in pairs(airShipTb) do
            local isReverse = k == 2
            if v and next(v) then
                local useTb = {}
                local airShip,shadowSp = G_showAirShip(v[1], isReverse,nil,nil,nil,nil,true)
                self.airShipSpTb[k] = airShip
                shadowSp:setOpacity(0)
                airShip:setScale(( v[1] == 6 or v[1] == 7 ) and 0.8 or 0.9)

                local fontSize = v[1] == 6 and 23 or 19
                local airShipName = GetTTFLabel(v[2] ~= "" and v[2] or getlocal("airShip_name_"..v[1]),fontSize)
                local nameBg = CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
                airShipName:setVisible(false)
                nameBg:setOpacity(0)
                nameBg:setScaleX( ( airShipName:getContentSize().width + 20) / nameBg:getContentSize().width)
                nameBg:setScaleY( ( fontSize + 1 ) / nameBg:getContentSize().height )

                local startPos,stayPos
                local namePosx,namePosy
                local posx,addPosy
                if isReverse then
                    if v[1] == 6 then
                        posx = -70
                        addPosy = -20
                    elseif v[1] == 7 then
                        posx = -40
                        addPosy = -30
                    else
                        posx = - 80
                        addPosy = 0
                    end

                    startPos = ccp(posx,G_VisibleSizeHeight * 0.85 + addPosy)
                    stayPos = ccp(posx,G_VisibleSizeHeight * 0.49 + addPosy)
                    self.l_container:addChild(airShip,10)

                    namePosx = 480
                    namePosy = 315

                    if v[1] == 7 then
                      namePosx = 430
                      namePosy = 360
                    end
                else
                    if v[1] == 6 then
                        posx = G_VisibleSizeWidth + 60
                        addPosy = 10
                    elseif v[1] == 7 then
                        posx = G_VisibleSizeWidth + 10
                        addPosy = -35
                    else
                        posx = G_VisibleSizeWidth + 80
                        addPosy = 0
                    end

                    startPos = ccp(posx,G_VisibleSizeHeight * 0.15 + addPosy)
                    stayPos = ccp(posx,G_VisibleSizeHeight * 0.51 + addPosy)
                    self.r_container:addChild(airShip,10)

                    namePosx = 140
                    namePosy = 150

                    if v[1] == 7 then
                      namePosx = 160
                      namePosy = 185
                    end
                end
                airShip:setPosition(startPos)

                airShipName:setPosition(namePosx,namePosy)
                nameBg:setPosition(airShipName:getPosition())
                airShip:addChild(airShipName,8)
                airShip:addChild(nameBg,7)

                local useT = 2.5 * G_battleSpeed

                local movM1    = CCMoveTo:create(useT,stayPos)
                local sineOut1 = CCEaseSineOut:create(movM1)--由快到慢
                local function stayRandomHandl()
                    if not airShipTb[k + 1] or not next(airShipTb[ k + 1 ]) then
                        local airShipTb = self.airShipTb
                        for k,v in pairs(airShipTb) do
                          if v and next(v) then
                              local randomNum = math.random(1,2)
                              local pointNum = math.random(1,4)
                              self:airShipRandomStayMov(randomNum, pointNum,k)  
                          end
                        end
                        
                    end
                end
                local stayRandomCall = CCCallFunc:create(stayRandomHandl)
                local stayArr = CCArray:create()
                stayArr:addObject(sineOut1)
                stayArr:addObject(stayRandomCall)
                local staySeq = CCSequence:create(stayArr)
                airShip:runAction(staySeq)

                local sFadeIn = CCFadeIn:create(useT)
                shadowSp:runAction(sFadeIn)

                local nbgDet = CCDelayTime:create(useT)
                local nbgFadeIn = CCFadeTo:create(0.3,255 * 0.8)
                local nbgArr = CCArray:create()
                nbgArr:addObject(nbgDet)
                nbgArr:addObject(nbgFadeIn)
                local nbgSeq = CCSequence:create(nbgArr)
                nameBg:runAction(nbgSeq)

                local naDet = CCDelayTime:create(useT)
                local naFadeIn = CCBlink:create(0.9,3)
                local function nameShowHandl() airShipName:setVisible(true) end
                local nameShowCall = CCCallFunc:create(nameShowHandl)
                local naArr = CCArray:create()
                naArr:addObject(naDet)
                naArr:addObject(naFadeIn)
                naArr:addObject(nameShowCall)
                local naSeq = CCSequence:create(naArr)
                airShipName:runAction(naSeq)                
            end
        end
    end
    local toStayCall = CCCallFunc:create(createStayShipHandl)
    local arr = CCArray:create()
    arr:addObject(delT)
    arr:addObject(toStayCall)
    local seq = CCSequence:create(arr)
    self.container:runAction(seq)
end
function BossBattleScene:runStayShipToEnd( )

    local airShipTb = self.airShipTb
    local isHasShip = false

    for k,v in pairs(airShipTb) do
        local isReverse = k == 2
        if v and next(v) and self.airShipSpTb[k] then
            isHasShip = true

            local movPos
            if isReverse then
                movPos = ccp(G_VisibleSizeWidth,G_VisibleSizeHeight * 0.85)
            else
                movPos = ccp(0,G_VisibleSizeHeight * 0.15)
            end
            local mov1 = CCMoveTo:create(2.5,movPos)
            local sineOut2 = CCEaseSineIn:create(mov1)
            local function movEndHandl( )
                if not airShipTb[k + 1] or not next(airShipTb[ k + 1 ]) then
                    self:showResuil()
                end
            end
            local endCall = CCCallFunc:create(movEndHandl)
            local endArr = CCArray:create()
            endArr:addObject(sineOut2)
            endArr:addObject(endCall)
            local endSeq = CCSequence:create(endArr)
            self.airShipSpTb[k]:runAction(endSeq)
        end
    end
    if not isHasShip then
        self:showResuil()
    end
end
function BossBattleScene:showAirShip(isEndBattle)
    
    local airShipTb = self.airShipTb
    local isHasShip = false

    if isEndBattle then
      if not self.airShipSpTb and not self.hasStayAirShip then
          self.airShipSpTb = {}
      else
          self:runStayShipToEnd()
          do return end
      end
      for k,v in pairs(airShipTb) do
        local isReverse = k == 2
        local useTb = {}
        if v and next(v) then
            isHasShip = true
            local inT    = 3 * G_battleSpeed
            local outT = 2 * G_battleSpeed
            local dlT1 = 0.75 * G_battleSpeed
            local airShip,shadowSp = G_showAirShip(v[1], isReverse,nil,nil,nil,nil,true)
            self.airShipSpTb[k] = airShip
            airShip:setScale(v[1] == 6 and 0.8 or 0.9)
            local startPos,middlePos,endPos
            local addPosY = k == 1 and 50 or 100
            if isReverse then
                startPos = ccp(G_VisibleSizeWidth * 0.35, -200)
                middlePos = ccp(G_VisibleSizeWidth * 0.36,G_VisibleSizeHeight * 0.25)
                endPos   = ccp(G_VisibleSizeWidth + 150, G_VisibleSizeHeight * 0.5)
                self.l_container:addChild(airShip,10)
            else
                startPos = ccp(G_VisibleSizeWidth * 0.66, G_VisibleSizeHeight + 200)
                middlePos = ccp(G_VisibleSizeWidth * 0.67,G_VisibleSizeHeight * 0.75)
                endPos   = ccp(-150, G_VisibleSizeHeight * 0.5)
                self.r_container:addChild(airShip,10)
            end
            airShip:setPosition(startPos)

            local movM1    = CCMoveTo:create(inT,middlePos)
            local sineOut1 = CCEaseSineOut:create(movM1)--由快到慢
            local deT1     = CCDelayTime:create(dlT1)
            local movM2    = CCMoveTo:create(outT,endPos)          
            local sineOut2 = CCEaseSineIn:create(movM2)

            local function removeHandl()
                if airShip then
                    airShip:stopAllActions()
                    airShip:removeFromParentAndCleanup(true)
                end
                if not airShipTb[k + 1] or not next(airShipTb[ k + 1 ]) then
                    self:showResuil()
                end
            end
            local removeCall = CCCallFunc:create(removeHandl)
            local shipAcArr  = CCArray:create()
            shipAcArr:addObject(sineOut1)
            shipAcArr:addObject(deT1)
            shipAcArr:addObject(sineOut2)
            shipAcArr:addObject(removeCall)
            local shipAcSeq = CCSequence:create(shipAcArr)
            airShip:runAction(shipAcSeq)

            local airShipTipSp = CCSprite:createWithSpriteFrameName("airShipInBattleTipBg_"..k..".png")
            local tipSpWidth = airShipTipSp:getContentSize().width
            local tipTitle = GetTTFLabel(v[2] ~= "" and v[2] or getlocal("airShip_name_"..v[1]),20)
            tipTitle:setPosition(isReverse and 125 or tipSpWidth - 125, 78)
            airShipTipSp:addChild(tipTitle)

            local tipDec = GetTTFLabelWrap(getlocal("airShipInBattleDec2"),G_isAsia() and 15 or 12,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            tipDec:setPosition(isReverse and 105 or tipSpWidth - 105,32.5)
            airShipTipSp:addChild(tipDec)

            airShipTipSp:setFlipX(true)
            
            local startPos,endPos
            if isReverse then
                startPos = ccp(G_VisibleSizeWidth + tipSpWidth * 0.5, G_VisibleSizeHeight * 0.18)
                endPos   = ccp(G_VisibleSizeWidth - tipSpWidth * 0.5, G_VisibleSizeHeight * 0.18)
                self.l_container:addChild(airShipTipSp,10)
            else
                startPos = ccp(0 - tipSpWidth * 0.5, G_VisibleSizeHeight * 0.81)
                endPos   = ccp(0 + tipSpWidth * 0.5, G_VisibleSizeHeight * 0.81)
                self.r_container:addChild(airShipTipSp,10)
            end
            local tipMov1 = CCMoveTo:create(inT * 0.2,endPos)
            local tipOut1 = CCEaseSineOut:create(tipMov1)--由快到慢
            local tipDet  = CCDelayTime:create(inT)
            local tipMov2 = CCMoveTo:create(0.15,startPos)
            local tipOut2 = CCEaseSineOut:create(tipMov2)--由快到慢
            local function tipRemovHandl() 
                airShipTipSp:removeFromParentAndCleanup(true)
                
            end
            local tipRemvCall = CCCallFunc:create(tipRemovHandl)
            local tipArr = CCArray:create()
            tipArr:addObject(tipOut1)
            tipArr:addObject(tipDet)
            tipArr:addObject(tipOut2)
            tipArr:addObject(tipRemvCall)
            local tipSeq = CCSequence:create(tipArr)
            airShipTipSp:runAction(tipSeq)

            airShipTipSp:setPosition(startPos)
        end
      end
      if not isHasShip then
          self:showResuil()
      end
    else
      for k,v in pairs(airShipTb) do
        local isReverse = k == 2
        local useTb = {}
        -- print("k---->>>>",k,isReverse)
        if v and next(v) then
            isHasShip = true
            -- local useIdx = math.random(2,3)
            local inT    = 3 * G_battleSpeed
            local outT   = ( v[1] == 7 and 1.2 or 1.6 ) * G_battleSpeed
            local dlT1    = 1.1 * G_battleSpeed
            local dlT2    = 0.5 * G_battleSpeed
            useTb.start = true
            useTb.inT  = inT
            useTb.outT = outT
            useTb.dlT1  = dlT1
            useTb.dlT2  = dlT2
            local airShip,shadowSp = G_showAirShip(v[1], isReverse,nil,nil,nil, useTb, true)

            local scaleNum = 0.8
            if v[1] == 6 then
              scaleNum = isReverse and 0.63 or 0.6
            else
              scaleNum = 0.7
            end
            airShip:setScale(scaleNum)--(v[1] == 6 and 0.8 or 0.9)
            local startPos,middlePos1,middlePos2,endPos
            local addPosY = k == 1 and 50 or 100

            if isReverse then
              local basePosy = G_VisibleSizeHeight * 0.25
              startPos   = ccp(-310,-50)
              middlePos2 = ccp(G_VisibleSizeWidth * 0.32,basePosy + addPosY)
              middlePos1 = ccp(G_VisibleSizeWidth * 0.43,basePosy + addPosY - 100)
              endPos     = ccp(G_VisibleSizeWidth + 150, G_VisibleSizeHeight * 0.65)
              self.l_container:addChild(airShip,10)
              -- if v[1] > 5 then
                middlePos1 = ccpAdd(middlePos1,ccp(-40,-30))
                middlePos2 = ccpAdd(middlePos2,ccp(5,-80))
              -- end
            else
              local basePosy = G_VisibleSizeHeight * 0.75
              startPos   = ccp(G_VisibleSizeWidth + 310, G_VisibleSizeHeight - addPosY)
              middlePos1 = ccp(G_VisibleSizeWidth * 0.7,basePosy - addPosY)
              middlePos2 = ccp(G_VisibleSizeWidth * 0.58,basePosy - addPosY + 100)
              endPos     = ccp(-150, G_VisibleSizeHeight * 0.5)
              self.r_container:addChild(airShip,10)

              if v[1] > 5 then
                middlePos1 = ccpAdd(middlePos1,ccp(-50,-30))
                middlePos2 = ccpAdd(middlePos2,ccp(-25,-30))
              end
            end
            airShip:setPosition(startPos)

            local movM1    = CCMoveTo:create(inT,middlePos1)
            local sineOut1 = CCEaseSineOut:create(movM1)--由快到慢
            local deT1     = CCDelayTime:create(dlT2)

            local movM2    = CCMoveTo:create(dlT1,middlePos2)
            -- local sineOut2 = CCEaseSineOut:create(movM2)
            local scaleto = CCScaleTo:create(dlT1, ( v[1] == 6 or v[1] == 7 ) and 0.8 or 0.9 )

            local sArr = CCArray:create()
            sArr:addObject(movM2)
            sArr:addObject(scaleto)
            local spawnMov = CCSpawn:create(sArr)

            local deT2     = CCDelayTime:create(0.2 * G_battleSpeed)--dlT2)

            local movE     = CCMoveTo:create(outT,endPos)
            local sineIn   = CCEaseSineIn:create(movE)
            local function removeHandl()
                if airShip then
                    airShip:stopAllActions()
                    airShip:removeFromParentAndCleanup(true)
                end
                if not airShipTb[k + 1] or not next(airShipTb[ k + 1 ]) then
                    self.startFire = true
                    self:runAirShipStaying()
                end
                
            end
            local removeCall = CCCallFunc:create(removeHandl)
            local shipAcArr  = CCArray:create()
            shipAcArr:addObject(sineOut1)
            shipAcArr:addObject(deT1)
            shipAcArr:addObject(spawnMov)
            shipAcArr:addObject(deT2)
            shipAcArr:addObject(sineIn)
            shipAcArr:addObject(removeCall)
            local shipAcSeq = CCSequence:create(shipAcArr)
            airShip:runAction(shipAcSeq)

            if shadowSp and not isReverse then
                local shadowDet = CCDelayTime:create(inT + dlT2)
                local sMov = CCMoveBy:create(dlT1,ccpSub(middlePos1,middlePos2))
                -- local sMovsineOut = CCEaseSineOut:create(sMov)
                local shadowArr = CCArray:create()
                shadowArr:addObject(shadowDet)
                shadowArr:addObject(sMov)
                shadowSeq = CCSequence:create(shadowArr)
                shadowSp:runAction(shadowSeq)
            end

            local airShipTipSp = CCSprite:createWithSpriteFrameName("airShipInBattleTipBg_"..k..".png")
            local tipSpWidth = airShipTipSp:getContentSize().width
            local tipTitle = GetTTFLabel(v[2] ~= "" and v[2] or getlocal("airShip_name_"..v[1]),20)
            tipTitle:setPosition(isReverse and 125 or tipSpWidth - 125, 78)
            airShipTipSp:addChild(tipTitle)

            local tipDec = GetTTFLabelWrap(getlocal("airShipInBattleDec1"),G_isAsia() and 15 or 12,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            tipDec:setPosition(isReverse and 105 or tipSpWidth - 105,32.5)
            airShipTipSp:addChild(tipDec)

            airShipTipSp:setFlipX(true)
            
            local startPos,endPos
            if isReverse then
                startPos = ccp(G_VisibleSizeWidth + tipSpWidth * 0.5, G_VisibleSizeHeight * 0.18)
                endPos   = ccp(G_VisibleSizeWidth - tipSpWidth * 0.5, G_VisibleSizeHeight * 0.18)
                self.l_container:addChild(airShipTipSp,10)
            else
                startPos = ccp(0 - tipSpWidth * 0.5, G_VisibleSizeHeight * 0.81)
                endPos   = ccp(0 + tipSpWidth * 0.5, G_VisibleSizeHeight * 0.81)
                self.r_container:addChild(airShipTipSp,10)
            end
            local tipMov1 = CCMoveTo:create(inT * 0.2,endPos)
            local tipOut1 = CCEaseSineOut:create(tipMov1)--由快到慢
            local tipDet  = CCDelayTime:create(inT)
            local tipMov2 = CCMoveTo:create(0.15,startPos)
            local tipOut2 = CCEaseSineOut:create(tipMov2)--由快到慢
            local function tipRemovHandl() 
                airShipTipSp:removeFromParentAndCleanup(true)
            end
            local tipRemvCall = CCCallFunc:create(tipRemovHandl)
            local tipArr = CCArray:create()
            tipArr:addObject(tipOut1)
            tipArr:addObject(tipDet)
            tipArr:addObject(tipOut2)
            tipArr:addObject(tipRemvCall)
            local tipSeq = CCSequence:create(tipArr)
            airShipTipSp:runAction(tipSeq)

            airShipTipSp:setPosition(startPos)
        end
      end
      if not isHasShip then
          self.startFire = true
      end
    end
end


function BossBattleScene:fireTick(kzhzParm)
    
    --==========以下是空中轰炸==========
    local kzhz=nil
    if kzhzParm~=nil and kzhzParm==true then
        kzhz=true
    end
    local cdData=self.battleData[self.fireIndex]
    if cdData~=nil then
         if cdData[1]=="@" then --空中轰炸
            kzhz=true
            self.fireIndex=self.fireIndex+1
         end
    end
    --==========以上是空中轰炸==========

    local  battleEnd=false
    if self.nextFire==0 then
         if self.playerData[1][3]==1 then --左边先手
          self.nextFire=1
         else --右边先手
             self.nextFire=2
         end
         self.lFireIndex=1
         self.rFireIndex=1
    end
    local fireTank=nil  --当前开火的坦克
    if kzhz==nil then
            if self.nextFire==1 then
                   for k=self.lFireIndex,6 do
                       if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                            fireTank=self.allT1[k]
                            self.lFireIndex=k+1
                            do
                                break
                            end
                       end
                   end
                   self.nextFire=2
                   if fireTank==nil then --左方 本轮没有要开火的坦克了
                           self.lFireIndex=7 
                           for k=self.rFireIndex,6 do  --右方开火
                               if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                                    fireTank=self.allT2[k]
                                    self.rFireIndex=k+1
                                    do
                                        break
                                    end
                               end
                           end
                           if fireTank==nil then  --双方 本轮都没有要开火的坦克了
                               if  self:isBattleFinished() then
                                    battleEnd=true  --结束战斗
                               else
                                    self.nextFire=0  --重新开始一轮交火
                                    self:fireTick()  --立即开始一轮交火
                                    self.hhNum=self.hhNum+1
                                    self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
                                    do
                                        return
                                    end
                               end
                           end
                           self.nextFire=1 
                   end
            elseif self.nextFire==2 then
                   local isNewGuidStepWith52InIdx2 = false
                   for k=self.rFireIndex,6 do
                       if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                            fireTank=self.allT2[k]
                            self.rFireIndex=k+1

                            if k ==3 then
                              isNewGuidStepWith52InIdx2 =true
                            end

                            do
                                break
                            end
                       end
                   end 
                   if newGuidMgr:isNewGuiding() ==true and newGuidMgr.curStep ==52 and isNewGuidStepWith52InIdx2 then
                      fireTank = nil
                   end
                   --self.nextFire=1
                    if fireTank==nil then --右方 本轮没有要开火的坦克了
                           self.rFireIndex=7
                           for k=self.lFireIndex,6 do  --左方开火
                               if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                                    fireTank=self.allT1[k]
                                    self.lFireIndex=k+1
                                    do
                                        break
                                    end
                               end
                           end
                           if fireTank==nil then  --双方 本轮都没有要开火的坦克了
                               if  self:isBattleFinished() then
                                    battleEnd=true  --结束战斗
                               else
                                    self.nextFire=0  --重新开始一轮交火
                                    self:fireTick()  --立即开始一轮交火
                                    self.hhNum=self.hhNum+1
                                    self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
                                    do
                                        return
                                    end
                               end
                           end
                           self.nextFire=2 
                   end
            end
    else--空中轰炸
            if self.nextFire==1 then
                   for k=self.lFireIndex,6 do
                       if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                            fireTank=self.allT1[k]
                            do
                                break
                            end
                       end
                   end
                   if fireTank==nil then --左方 本轮没有要开火的坦克了
                           for k=self.rFireIndex,6 do  --右方开火
                               if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                                    fireTank=self.allT2[k]
                                    do
                                        break
                                    end
                               end
                           end
                           if fireTank==nil then  --双方 本轮都没有要开火的坦克了
                               if  self:isBattleFinished() then
                                    battleEnd=true  --结束战斗
                               else
                                     self.nextFire=0  --重新开始一轮交火
                                    self:fireTick(true)  --立即开始一轮交火
                                    self.hhNum=self.hhNum+1
                                    self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
                                    do
                                        return
                                    end
                               end
                           end
                   end
            elseif self.nextFire==2 then
                   for k=self.rFireIndex,6 do
                       if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                            fireTank=self.allT2[k]
                            do
                                break
                            end
                       end
                   end 
                    if fireTank==nil then --右方 本轮没有要开火的坦克了
                           for k=self.lFireIndex,6 do  --左方开火
                               if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                                    fireTank=self.allT1[k]
                                    do
                                        break
                                    end
                               end
                           end
                           if fireTank==nil then  --双方 本轮都没有要开火的坦克了
                               if  self:isBattleFinished() then
                                    battleEnd=true  --结束战斗
                               else
                                    self.nextFire=0  --重新开始一轮交火
                                    self:fireTick(true)  --立即开始一轮交火
                                    self.hhNum=self.hhNum+1
                                    self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
                                    do
                                        return
                                    end
                               end
                           end
                   end
            end
    end


    local btdata
    local tnextDData
    local isAttackSelf=false

    if self.hhNum%2==0 and tankCfg[fireTank.tankId].weaponType=="18" and newGuidMgr:isNewGuiding()==false then  --b型火箭车 单数轮次攻击
           --这里添加火箭车效果 fireTank 红箭坦克系列攒炮弹动画
           fireTank:animationCtrlByType("I")

    else
              local fireGunIdx = 1
              local btdata=self.battleData[self.fireIndex] --此次开火的数据
              self.fireIndex=self.fireIndex+1
              
              if tnextDData~=nil then
                   if tnextDData[1]=="$" then --本轮攻击要双击
                      self.is10074Skill=true
                      self.is10094Skill=true
                   end
              end
              local isAttackSelf=false
              if btdata==nil then
                  do
                      return
                  end
              end
              -- print("btdata----->")
              -- G_dayin(btdata)
                      if fireTank~=nil then
                           local beAttackedTanks,attackPos=self:getBeAttackedTanks(fireTank,kzhz)
                           local attackCurPos = attackPos--针对B型坦克攻击方式特别添加的
                           local len=SizeOfTable(beAttackedTanks)
                           local nextRealAttckPos = nil--针对B型坦克
                           if len>0 then
                              if kzhz==nil then

                                          local realAttackData=nil
                                          isAttackSelf,realAttackData=self:checkIsAttackSelf(btdata[1])
                                          if isAttackSelf==true then

                                              fireTank:attackedSelf(realAttackData)
                                          else
                                                          if fireTank.area==1 then
                                                            fireTank:setFire(0.02,6)
                                                          else
                                                            fireTank:setFire(0.02,(tankCfg[fireTank.tankId].type=="8" and 6 or len))
                                                          end
                                                          
                                                          if self.is10074Skill==false then
                                                             fireTank:removeBeAtked10074()
                                                          else
                                                             self.is10074Skill=false
                                                          end
                                                          if self.is10094Skill==false then
                                                             fireTank:removeBeAtked10094()
                                                          else
                                                             self.is10094Skill=false
                                                          end
                                                          if tankCfg[fireTank.tankId].type~="8" then
                                                                  for mm=1,len do
                                                                     local curBeAttackedTank=beAttackedTanks[mm]
                                                                     
                                                                     if tankCfg[fireTank.tankId].weaponType=="11" then --B型坦克追着上一次攻击的坦克打，知道将其打死
                                                                          for mkk=1,len do
                                                                               if beAttackedTanks[mkk] ~= nil and beAttackedTanks[mkk].isSpace==false then
                                                                                    attackCurPos[mm]=attackPos[mkk]
                                                                                    if attackPos[mkk]~= attackPos[mkk+1] then
                                                                                      nextRealAttckPos =attackPos[mkk+1]
                                                                                    end
                                                                                    do
                                                                                         break
                                                                                    end
                                                                               end
                                                                          end
                                                                          local isSame = true
                                                                          local isDie = 1
                                                                          local nextFireGun = 0
                                                                          if self.bossType == 2 then -- 夕兽活动
                                                                            isSame,isDie,nextFireGun = acNewYearsEveVoApi:isSameToGunNum(btdata,mm,attackCurPos[mm])
                                                                          elseif self.bossType==3 then
                                                                            isSame,isDie,nextFireGun=allianceFubenVoApi:isSameToGunNum(btdata,mm,attackCurPos[mm])
                                                                          else --世界boss
                                                                            isSame,isDie,nextFireGun = BossBattleVoApi:isSameToGunNum(btdata,mm,attackCurPos[mm])
                                                                          end
                                                                          if isSame==false or isDie ==0 then
                                                                                if fireGunIdx ==1 then
                                                                                  fireGunIdx= fireGunIdx+1
                                                                                else
                                                                                    fireGunIdx= fireGunIdx+1
                                                                                    if isDie ==0 then
                                                                                      battleEnd=true
                                                                                      fireTank.fireNum=mm-1
                                                                                      do break end
                                                                                    else--if attackCurPos[mm] < 6 then
                                                                                      if nextFireGun == nextRealAttckPos then
                                                                                        attackCurPos[mm] = nextFireGun
                                                                                      else
                                                                                        attackCurPos[mm] =nextRealAttckPos
                                                                                      end
                                                                                    end
                                                                                end
                                                                           end
                                                                     elseif tankCfg[fireTank.tankId].weaponType=="14" then
                                                                        if SizeOfTable(attackPos) > SizeOfTable(btdata) and btdata[mm] then
                                                                            local paotouNum = attackCurPos[mm]
                                                                            local newTankTb = {}
                                                                            if self.bossType == 2 then -- 夕兽活动
                                                                              newTankTb = acNewYearsEveVoApi:getNoSubLifeBossPaotou(btdata,mm)
                                                                            elseif self.bossType==3 then
                                                                              newTankTb = allianceFubenVoApi:getNoSubLifeBossPaotou(btdata,mm)
                                                                            else --世界boss
                                                                              newTankTb = BossBattleVoApi:getNoSubLifeBossPaotou(btdata,mm)
                                                                            end
                                                                            if newTankTb[attackPos[mm]] ==nil and mm < len then
                                                                                attackCurPos[mm] = attackCurPos[mm+1]
                                                                            end
                                                                        end
                                                                     end
                                                                                                                                         
                                                                      --以下返回3个字段，攻击者的技能效果、被攻击者的技能效果、排除掉技能效果后的战斗数据（同旧的的数据格式一致，减少代码修改量）
                                                                      if btdata[mm]==nil then
                                                                              do
                                                                                   break
                                                                              end
                                                                      end
                                                                      local attackerData,beAttackerData,retData=self:checkAnimEffectByData(btdata[mm])
                                                                      if attackerData~=nil then
                                                                          for eindex=1,#attackerData do
                                                                            print("mimimi=",attackerData[eindex])
                                                                            if attackerData[eindex]=="G" then
                                                                               fireTank.isG=true
                                                                               curBeAttackedTank:animationCtrlByType(attackerData[eindex],attackCurPos[mm])
                                                                            else
                                                                               fireTank:animationCtrlByType(attackerData[eindex])
                                                                            end
                                                                            
                                                                          end
                                                                      end
                                                                      -- if fireTank.area==1 then
                                                                      --   beAttackedTanks[mm]:beAttacked(1+mm*0.4,fireTank.tid,0,"0-0",nil,beAttackerData,fireTank.isG,attackPos[mm])

                                                                      -- else
                                                                      curBeAttackedTank:beAttacked(1+mm*0.4,fireTank.tid,23,retData==nil and btdata[mm] or retData,nil,beAttackerData,fireTank.isG,attackCurPos[mm])

                                                                      if fireTank.num == -1 and self.reflexHurtTb then
                                                                          self:reflexHurtToBoss(fireTank,mm)
                                                                      end
                                                                  end
                                                          else
                                                                  local hasIDs={}
                                                                  for mm=1,len do
                                                                    if fireTank.area==1 then
                                                                      hasIDs[beAttackedTanks[mm].pos]=1
                                                                    else
                                                                      hasIDs[attackPos[mm]]=1
                                                                    end
                                                                  end
                                                                  local dataID=1    
                                                                  if tankCfg[fireTank.tankId].type=="8" then  --火箭炮特殊处理
                                                                    local firetsk = 1
                                                                    for tsk=1,6 do
                                                                      if (tankCfg[fireTank.tankId].abilityID~=nil and tankCfg[fireTank.tankId].abilityID=="i") or BossBattleScene:hasSpcSkil(fireTank.area,"i","a"..fireTank.tankId) then --沙暴火箭炮

                                                                                      if btdata[tsk]==nil then
                                                                                              do
                                                                                                   break
                                                                                              end
                                                                                      end

                                                                                      local attackerData,beAttackerData,retData=self:checkAnimEffectByData(btdata[tsk])
                                                                                              if attackerData~=nil then
                                                                                                  for eindex=1,#attackerData do
                                                                                                      fireTank:animationCtrlByType(attackerData[eindex])
                                                                                                  end
                                                                                              end


                                                                                        if hasIDs[6]==nil then
                                                                                          firetsk=5
                                                                                        end
                                                                                       if self:getBossTankNum()[tsk]~=nil then
                                                                                          self.allT1[2]:beAttacked(1+tsk*0.1,fireTank.tid,23,retData==nil and btdata[tsk] or retData,nil,beAttackerData,nil,tsk)
                                                                                          dataID=dataID+1
                                                                                         if dataID>6 then
                                                                                              dataID=1
                                                                                         end
                                                                                       else
                                                                                          for sbhj=firetsk,6 do

                                                                                             if self:getBossTankNum()[sbhj]~=nil then
                                                                                                 
                                                                                                 self.allT1[2]:beAttacked(1+tsk*0.1,fireTank.tid,23,retData==nil and btdata[tsk] or retData,nil,beAttackerData,nil,sbhj)
                                                                                                 -- if retLeftNum==0 then --第dataID个被摧毁了
                                                                                                 --    beAttackedTanks[dataID]=nil
                                                                                                 -- end
                                                                                                 print("firetsk......",sbhj)
                                                                                                 firetsk=sbhj+1
                                                                                                 if firetsk> 6 then
                                                                                                  firetsk=1
                                                                                                 end
                                                                                                 do
                                                                                                    break
                                                                                                 end
                                                                                            -- else
                                                                                                 -- dataID=dataID+1
                                                                                                 --  if dataID>6 then
                                                                                                 --     dataID=1
                                                                                                 --  end
                                                                                             end

                                                                                         end
                                                                                       end

                                                                          else

                                                                              if hasIDs[tsk]~=nil then
                                                                                if btdata[dataID] == nil then
                                                                                  do
                                                                                    break
                                                                                  end
                                                                                end
                                                                                      local attackerData,beAttackerData,retData=self:checkAnimEffectByData(btdata[dataID])
                                                                                      if attackerData~=nil then
                                                                                          for eindex=1,#attackerData do
                                                                                              fireTank:animationCtrlByType(attackerData[eindex])
                                                                                          end
                                                                                      end

                                                                                      self.allT1[2]:beAttacked(1+tsk*0.1,fireTank.tid,23,retData==nil and btdata[dataID] or retData,nil,beAttackerData,nil,tsk)

                                                                                       dataID=dataID+1
                                                                              else
                                                                                    -- local dataTbs
                                                                                    -- if fireTank.area==1 then
                                                                                    --     dataTbs=self.allT2
                                                                                    -- else
                                                                                    --     dataTbs=self:getBossTankNum()
                                                                                    -- end
                                                                                    -- print("........tsk2",tsk)
                                                                                    -- dataTbs[tsk]:beAttacked(1+tsk*0.1,fireTank.tid,23,"23-1",nil,nil,nil,tsk)
                                                                                    self.allT1[2]:beAttacked(1+tsk*0.1,fireTank.tid,0,"0-1",nil,nil,nil,tsk)
                                                                              end
                                                                          end
                                                                      end
                                                                  end
                                                          end
                                             end
                              else  --空中轰炸
                                          for mm=1,len do
                                              beAttackedTanks[mm]:beAttacked(beAttackedTanks[mm].pos>3 and 0.2 or 0.5,1,23,btdata[mm],true)
                                          end
                              end
                           end
                      end
    end

    if self.fireIndex>self.fireIndexTotal then
        battleEnd=true
        if newGuidMgr:isNewGuiding()==true then
             if newGuidMgr.curStep==52 or newGuidMgr.curBMStep==3 then
                        do
                            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
                            newGuidMgr:toNextStep()
                            if self.endBtnItemMenu then
                              self.endBtnItemMenu:setPosition(ccp(100000,20))
                            end
                            return
                        end
             end
        end

    end
    if battleEnd==true then
        local function battleResult()
            if self.isBattleEnd==false then
                self.isBattleEnd=true
                if self.fireTimer~=nil then
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
                end
                if newGuidMgr:isNewGuiding()==false then
                  -- self:showResuil()
                  if self.airShipTb and next(self.airShipTb) then
                      self:showAirShip(true)
                  else
                    self:showResuil()
                  end
                elseif newGuidMgr:isNewGuiding()==true then
                    newGuidMgr:toNextStep()
                end
            end
            --self:stopAction()
        end
        
        local delayTime=CCDelayTime:create(5) --延时两秒再弹出结束面板
        local  delayfunc=CCCallFuncN:create(battleResult)
        local  seq=CCSequence:createWithTwoActions(delayTime,delayfunc)
        self.container:runAction(seq)
    end
    local nextDData=self.battleData[self.fireIndex]
    if nextDData~=nil then
         if nextDData[2]=="K" then
            --播放动画
            local function playerAnim()
              fireTank:animationCtrlByType("K")
            end
            local callFunc=CCCallFunc:create(playerAnim)
            local delay=CCDelayTime:create(2)
            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            sceneGame:runAction(seq)

         end

         if nextDData[1]=="$" then --本轮攻击要双击
            self.fireIndex=self.fireIndex+1
             if self.nextFire==1 then
                 --self.nextFire=1
                 self.lFireIndex=self.lFireIndex-1
             else
                 --self.nextFire=2
                 self.rFireIndex=self.rFireIndex-1
             end
         end
    end
    if isAttackSelf==true and fireTank~=nil and fireTank.isSpace~=true then
           if self.nextFire==1 then
                 --self.nextFire=1
                 self.lFireIndex=self.lFireIndex-1
             else
                 --self.nextFire=2
                 self.rFireIndex=self.rFireIndex-1
             end
             self:fireTick()   
    end
end

function BossBattleScene:tick()
    if self.isBattleEnd==true then
        do
            return
        end
    end
    if newGuidMgr:isNewGuiding()==true then
      if newGuidMgr.curStep==52 or newGuidMgr.curStep == 54 or newGuidMgr.curBMStep==3 then
          self.endBtnItemMenu:setTouchPriority(-322)
          self.endBtnItemMenu:setPosition(ccp(G_VisibleSize.width-self.endBtnItem:getContentSize().width,20))
      else
          if self and self.endBtnItemMenu~=nil then
              self.endBtnItemMenu:setTouchPriority(-203)
          end
      end
    end

    if self.startFire==true then
        --这里正式启动战斗
             if self.battlePaused==true then

                do
                    return
                end
             end


        local function fireTickHandler()
                self:fireTick()
        end
        self.fireIndex=1
        self.fireIndexTotal=#self.battleData
        self:fireTick()
        self.fireTimer=CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(fireTickHandler,3,false)
        self.startFire=false
    end
    self.tickIndex=self.tickIndex+1
    for k,v in pairs(self.allT1) do
        v:tick()
    end
    for k,v in pairs(self.allT2) do
        v:tick()
    end
end

function BossBattleScene:showZWTick()
    if self.isBattleing==false then
         do
             return
         end
    end
    --if self.zwTickIndex%3==0 then
        --self:addZW(self.zwTickIndex)

    --end
    self.zwTickIndex=self.zwTickIndex+1
end


function BossBattleScene:getBossTankNum()
  local tankTb = {}
  local paotou = {}
  if self.bossType == 2 then
    paotou = acNewYearsEveVoApi:getBossPaotou()
  elseif self.bossType==3 then
    paotou=allianceFubenVoApi:getBossPaotou()
  else
    paotou = BossBattleVoApi:getBossPaotou()
  end
  for k,v in pairs(paotou) do
    if v and v==1 then
      tankTb[k]=self.allT1[2]
    end
  end
  return tankTb
end

--获取被开火坦克攻击的坦克
function BossBattleScene:getBeAttackedTanks(fireTank,isSelectAll)
    local aimTanks
    local retTb={}
    local attackPos = {}

    if fireTank.area==1 then
        aimTanks=self.allT2
    else
        aimTanks=self:getBossTankNum()
    end
    
    if isSelectAll~=nil then
        
        for k=1,6 do
             if aimTanks[k]~=nil and aimTanks[k].isSpace==false then
                 table.insert(retTb,aimTanks[k])
             end
        end
        do
            return retTb
        end
    end
    

    local attackType=fireTank.attackType[fireTank.tankId] --攻击类型 1:单体 2:横排 3:纵排 6:全体
    local fireTankPos=fireTank.pos --开火的坦克在阵型中的位置
    local isBTypeTank=false --是否是B型坦克
    if attackType==1 then
        if tankCfg[fireTank.tankId].weaponType=="12" then
                isBTypeTank=true
        end
        local tmpPos= (fireTankPos>3 and (fireTankPos-3) or fireTankPos)
        local orderTb={}
        if tmpPos==1 then
            orderTb={1,4,2,5,3,6}
            if isBTypeTank then
                orderTb={4,5,6,1,2,3}
            end
        elseif tmpPos==2 then
            orderTb={2,5,3,6,1,4}
            if isBTypeTank then
                orderTb={5,6,4,2,3,1}
            end
        elseif tmpPos==3 then
            orderTb={3,6,2,5,1,4}
            if isBTypeTank then
                orderTb={6,5,4,3,2,1}
        end
        end
        for k,v in pairs(orderTb) do
             if aimTanks[v]~=nil and aimTanks[v].isSpace==false then
                 --retTb[v]=aimTanks[v]
                 table.insert(retTb,aimTanks[v])
                 table.insert(attackPos,v)
                 do
                    break  -- 只能取出一个数据
                 end
             end
        end
    elseif attackType==2 then
        local tmpPos= (fireTankPos>3 and (fireTankPos-3) or fireTankPos)
        local orderTb={}
        
        if tmpPos==1 then
            orderTb={{1,4},{2,5},{3,6}}
        elseif tmpPos==2 then
            orderTb={{2,5},{3,6},{1,4}}
        elseif tmpPos==3 then
            orderTb={{3,6},{2,5},{1,4}}
        end
        for k,v in pairs(orderTb) do
             if (aimTanks[v[1]]~=nil and aimTanks[v[1]].isSpace==false) or  (aimTanks[v[2]]~=nil and aimTanks[v[2]].isSpace==false) then
                 if aimTanks[v[1]]~=nil and aimTanks[v[1]].isSpace==false then
                    table.insert(retTb,aimTanks[v[1]])
                    table.insert(attackPos,v[1])
                 end
                 if aimTanks[v[2]]~=nil and aimTanks[v[2]].isSpace==false then
                    table.insert(retTb,aimTanks[v[2]])
                    table.insert(attackPos,v[2])
                 end
                 do
                    break  -- 只能取出一组数据
                 end
             end
        end
    elseif attackType==3 then
        if tankCfg[fireTank.tankId].weaponType=="11" then
                isBTypeTank=true
        end
        if isBTypeTank==true then
              local tmpPos= (fireTankPos>3 and (fireTankPos-3) or fireTankPos)
              -- print("tmpPos---->",tmpPos)
             local orderTb={}
             if tmpPos==1 then
                orderTb={1,4,2,5,3,6}
             elseif tmpPos==2 then
                orderTb={2,5,3,6,1,4}
             elseif tmpPos==3 then
                orderTb={3,6,2,5,1,4}
             end
             local numidx=0
             for k,v in pairs(orderTb) do
                  if  aimTanks[v]~=nil and aimTanks[v].isSpace==false then
                        table.insert(retTb,aimTanks[v])
                        table.insert(attackPos,v)
                        numidx=numidx+1
                        if numidx>=3 then
                            do
                                break
                            end
                        end
                  end
             end
             while true do
                   if SizeOfTable(retTb)<3 and SizeOfTable(retTb)> 0 then
                        table.insert(retTb,retTb[1])
                        table.insert(attackPos,attackPos[1])
                   else
                       do
                             break
                       end
                   end
             end
        else
          local tempTb={{1,4},{2,5},{3,6}}
          for k,v in pairs(tempTb) do
              if  aimTanks[v[1]]~=nil and aimTanks[v[1]].isSpace==false then
                  table.insert(retTb,aimTanks[v[1]])
                  table.insert(attackPos,v[1])
              elseif aimTanks[v[2]]~=nil and aimTanks[v[2]].isSpace==false then
                  table.insert(retTb,aimTanks[v[2]])
                  table.insert(attackPos,v[2])
              end
          end
        end
    elseif attackType==4 then
        local tmpPos= (fireTankPos>3 and (fireTankPos-3) or fireTankPos)
        local orderTb={}
        if tankCfg[fireTank.tankId].weaponType=="14" then
            if tmpPos==1 then
                orderTb={1,4,2,5,3,6}
            elseif tmpPos==2 then
                orderTb={2,5,3,6,1,4}
            elseif tmpPos==3 then
                orderTb={3,6,2,5,1,4}
            end

            for k,v in pairs(orderTb) do
                if v <4 and aimTanks[v] ~=nil and aimTanks[v].isSpace ==false then
                    table.insert(retTb,aimTanks[v])
                    table.insert(attackPos,v)
                    if aimTanks[v+3]~=nil and aimTanks[v+3].isSpace ==false then
                        table.insert(retTb,aimTanks[v+3])
                        table.insert(attackPos,v+3)
                    end
                    if v-1 >0 and aimTanks[v-1]~=nil and aimTanks[v-1].isSpace ==false then
                        table.insert(retTb,aimTanks[v-1])
                        table.insert(attackPos,v-1)
                    end
                    
                    if v+1 <4 and aimTanks[v+1]~=nil and aimTanks[v+1].isSpace ==false then
                        table.insert(retTb,aimTanks[v+1])
                        table.insert(attackPos,v+1)
                    end
                    do break end
                elseif aimTanks[v] ~=nil and aimTanks[v].isSpace ==false then
                    table.insert(retTb,aimTanks[v])
                    table.insert(attackPos,v)
                    if v-1 >3 and aimTanks[v-1]~=nil and aimTanks[v-1].isSpace ==false then
                        table.insert(retTb,aimTanks[v-1])
                        table.insert(attackPos,v-1)
                    end
                    if v+1 <7 and aimTanks[v+1]~=nil and aimTanks[v+1].isSpace ==false then
                        table.insert(retTb,aimTanks[v+1])
                        table.insert(attackPos,v+1)
                    end
                    do break end
                end
            end
        end
    elseif attackType==6 then
        for k=1,6 do
             if aimTanks[k]~=nil and aimTanks[k].isSpace==false then
                 table.insert(retTb,aimTanks[k])
                 table.insert(attackPos,k)
             end
        end
    end
    return retTb,attackPos
end


--添加摧毁的坦克 area:区域  pos:坦克在原地图层x,y坐标 sp:废墟图片
function BossBattleScene:addDestoryTank(area,pos,sp)

    local parentLayer
    local tankLayer
    if area==2 then  --左边
        parentLayer=self.l_traceLayer
        tankLayer=self.l_tankLayer
    else --右边
        parentLayer=self.r_traceLayer
        tankLayer=self.r_tankLayer
    end
    local worldPos=tankLayer:convertToWorldSpace(pos)
    local parentLayerPos=parentLayer:convertToNodeSpace(worldPos)
    sp:setPosition(parentLayerPos)
    parentLayer:addChild(sp)
    for k=1,6 do
        self:addBomb(sp)
    end
end

--添加命中效果
function BossBattleScene:addMzEffect(area,pos,sp)
    local parentLayer
    local tankLayer
    if area==2 then  --左边
        parentLayer=self.l_bombLayer
        tankLayer=self.l_tankLayer
    else --右边
        parentLayer=self.r_bombLayer
        tankLayer=self.r_tankLayer
    end
    local worldPos=tankLayer:convertToWorldSpace(pos)
    local parentLayerPos=parentLayer:convertToNodeSpace(worldPos)
    sp:setPosition(parentLayerPos)
    parentLayer:addChild(sp)
end
--添加弹壳效果
function BossBattleScene:addShellEffect(area,pos,sp)
    local parentLayer
    local tankLayer
    if area==2 then  --左边
        parentLayer=self.l_bombLayer
        tankLayer=self.l_tankLayer
    else --右边
        parentLayer=self.r_bombLayer
        tankLayer=self.r_tankLayer
    end
    local worldPos=tankLayer:convertToWorldSpace(pos)
    local parentLayerPos=parentLayer:convertToNodeSpace(worldPos)
    sp:setPosition(parentLayerPos)
    parentLayer:addChild(sp)
end

--添加开炮地面效果
function BossBattleScene:addDustEffect(area,pos,sp)
    local parentLayer
    local tankLayer
    if area==2 then  --左边
        parentLayer=self.l_traceLayer
        tankLayer=self.l_tankLayer
    else --右边
        parentLayer=self.r_traceLayer
        tankLayer=self.r_tankLayer
    end
    local worldPos=tankLayer:convertToWorldSpace(pos)
    local parentLayerPos=parentLayer:convertToNodeSpace(worldPos)
    sp:setPosition(parentLayerPos)
    parentLayer:addChild(sp)
end

--添加一个坑
function BossBattleScene:addDig(area,pos,sp)
    local parentLayer
    local tankLayer
    if area==2 then  --左边
        parentLayer=self.l_traceLayer
        tankLayer=self.l_tankLayer
    else --右边
        parentLayer=self.r_traceLayer
        tankLayer=self.r_tankLayer
    end
    local worldPos=tankLayer:convertToWorldSpace(pos)
    local parentLayerPos=parentLayer:convertToNodeSpace(worldPos)
    sp:setPosition(parentLayerPos)
    parentLayer:addChild(sp)
end
--添加爆炸冒烟动画
function BossBattleScene:addDie(area,pos,sp)
    local parentLayer
    local tankLayer
    if area==2 then  --左边
        parentLayer=self.l_bombLayer
        tankLayer=self.l_tankLayer
    else --右边
        parentLayer=self.r_bombLayer
        tankLayer=self.r_tankLayer
    end
    local worldPos=tankLayer:convertToWorldSpace(pos)
    local parentLayerPos=parentLayer:convertToNodeSpace(worldPos)
    sp:setPosition(parentLayerPos)
    parentLayer:addChild(sp)
end

function BossBattleScene:addSubLife(area,pos,sp,bj)
    local tankLayer
    if area==2 then  --左边
       
        tankLayer=self.l_tankLayer
    else --右边
 
        tankLayer=self.r_tankLayer
    end
    local worldPos=tankLayer:convertToWorldSpace(pos)
    sp:setPosition(worldPos)
    self.topLayer:addChild(sp)
    sp:setScale(0.7)

                local function subMvEnd()
                    sp:removeFromParentAndCleanup(true)
                    sp=nil
                end
                --[[
                local function bjHandler()
                    sp:setScale(1.4)
                end
                ]]
                local staPoint=worldPos
                local subMvTo=CCMoveTo:create(0.2,ccp(staPoint.x,staPoint.y+50))
                local delayTime=CCDelayTime:create(0.3)
                local subMvTo2=CCMoveTo:create(0.4,ccp(staPoint.x,staPoint.y+180))
                local  subfunc=CCCallFuncN:create(subMvEnd);
                --local  bjfunc=CCCallFuncN:create(bjHandler);
                local fadeOut=CCFadeTo:create(0.4,0)
                local fadeArr=CCArray:create()
                fadeArr:addObject(subMvTo2)
                fadeArr:addObject(fadeOut)
                local spawn=CCSpawn:create(fadeArr)
                local acArr=CCArray:create()
                acArr:addObject(subMvTo)
                if bj==true then
                    --acArr:addObject(bjfunc)
                    local wzScaleTo=CCScaleTo:create(0.2,2)
                    local wzScaleBack=CCScaleTo:create(0.2,1.3)
                    acArr:addObject(wzScaleTo)
                    acArr:addObject(wzScaleBack)
                end
                acArr:addObject(delayTime)
                acArr:addObject(spawn)
                acArr:addObject(subfunc)
                local  subseq=CCSequence:create(acArr)
                sp:runAction(subseq)
  
end
function BossBattleScene:addRestraintAni(area,pos,relativeNum)
    local tankLayer
    local sp = nil
    if area==2 then
        tankLayer=self.l_tankLayer
        sp=CCSprite:createWithSpriteFrameName("atkAnimation_1.png")
    else --右边
        sp=CCSprite:createWithSpriteFrameName("defAnimation_1.png")
        tankLayer=self.r_tankLayer
    end
    sp:setScale(1.5)

    local metalSp=CCSprite:createWithSpriteFrameName("CircleEffect_1.png")
    local pzArr=CCArray:create()
    if area==2 then
        for kk=1,13 do
        local nameStr="atkAnimation_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
        end
    else
        for kk=1,17 do
        local nameStr="defAnimation_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
        end
    end

    local animation=CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.08)
    local animate=CCAnimate:create(animation)
    local worldPos=tankLayer:convertToWorldSpace(pos)
    sp:setPosition(worldPos)
    self.topLayer:addChild(sp)
    --[[
    local numStr=""
    local numLb=GetTTFLabel(numStr,30)
    if relativeNum>0 then
       numStr="+"..relativeNum.."%"
       numLb:setColor(G_ColorGreen)
    else
       numStr=relativeNum.."%"
       numLb:setColor(G_ColorRed)
    end
    numLb:setString(numStr)
    numLb:setPosition(worldPos)
    self.topLayer:addChild(numLb)
    local  function callFunLb()
        numLb:removeFromParentAndCleanup(true)
        numLb=nil
    end 
    local moveto = CCMoveTo:create(0.5,ccp(worldPos.x+80,worldPos.y))
    local  lbfunc=CCCallFuncN:create(callFunLb);
    local delay=CCDelayTime:create(0.5)
    local aniArr1=CCArray:create()
    aniArr1:addObject(moveto)
    aniArr1:addObject(delay)
    aniArr1:addObject(lbfunc)
    local seq1=CCSequence:create(aniArr1)
    numLb:runAction(seq1)
    ]]

    local  function callFun()
        sp:removeFromParentAndCleanup(true)
        sp=nil
    end 
    local  subfunc=CCCallFunc:create(callFun);
    local aniArr=CCArray:create()
    aniArr:addObject(animate)
    aniArr:addObject(subfunc)
    local seq=CCSequence:create(aniArr)
    sp:runAction(seq)

end
--坦克爆炸动画
function BossBattleScene:addBomb(sp)
           local mzFrameName="hit4_1.png" --命中动画
           local mzSp=CCSprite:createWithSpriteFrameName(mzFrameName)
           local rnd1=math.random()
           local rnd2=math.random()
               
            mzSp:setPosition(ccp(sp:getContentSize().width/2+50-math.floor(100*rnd1),sp:getContentSize().height/2+40-math.floor(80*rnd2)))
            sp:addChild(mzSp,20)
            mzSp:setVisible(false)
           local function playBomb()
                mzSp:setVisible(true) 
               mzSp:stopAllActions()
               local  mzArr=CCArray:create()
                for kk=1,14 do
                    local nameStr="hit4_"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    mzArr:addObject(frame)
               end
               local animation=CCAnimation:createWithSpriteFrames(mzArr)
               animation:setDelayPerUnit(0.06)
               local animate=CCAnimate:create(animation)
               

               local function mzEnd()
                   mzSp:stopAllActions()
                   mzSp:removeFromParentAndCleanup(true)
                   mzSp=nil
               end
               local  mzfunc=CCCallFuncN:create(mzEnd);
               
               local acArr=CCArray:create()

               acArr:addObject(animate)
               acArr:addObject(mzfunc)
               local  seq=CCSequence:create(acArr)
               mzSp:runAction(seq)
           end
           local  delay=CCDelayTime:create(math.floor(1000*math.random())/1000)
           local  defunc=CCCallFuncN:create(playBomb)
           local  seq=CCSequence:createWithTwoActions(delay,defunc)
           mzSp:runAction(seq)
end

function BossBattleScene:showResuil()
    local function callback(tag,object)
        for k,v in pairs(base.commonDialogOpened_WeakTb) do
            if(v and v.setDisplay)then
                v:setDisplay(true) --显示原有的所有commonDialog面板
            end
        end
        for k,v in pairs(G_SmallDialogDialogTb) do
            if v and v.setDisplay then
                v:setDisplay(true) --显示原有的所有smallDialog面板
            end
        end
        if self.serverWarType then
            if self.serverWarType==1 and serverWarPersonalTeamScene and serverWarPersonalTeamScene.layerNum then
                serverWarPersonalTeamScene:setVisible(true)
            elseif self.serverWarType==2 and serverWarPersonalKnockOutScene and serverWarPersonalKnockOutScene.layerNum then
                serverWarPersonalKnockOutScene:setVisible(true)
            end
        end
        if self.serverWarTeam==1 then
            if serverWarTeamOutScene and serverWarTeamOutScene.layerNum then
                serverWarTeamOutScene:setVisible(true)
            end
        end
        self:close()
    end
    if self.isReport==true then
        callback()
        do return end
    end

    local isVictory
    local award
    if self.isFuben==true or self.bossType==3 then
        if self.isWin and self.isWin==1 then
            isVictory=true
        else
            isVictory=false
        end
        if self.battleReward and type(self.battleReward)=="table" and SizeOfTable(self.battleReward) then
            award=FormatItem(self.battleReward)
        end
        for k,v in pairs(self.allT1) do
          if v.bufSmallDialog then
            v.bufSmallDialog:close()
            v.bufSmallDialog=nil
          end
        end
        for k,v in pairs(self.allT2) do
          if v.bufSmallDialog then
            v.bufSmallDialog:close()
            v.bufSmallDialog=nil
          end
        end
        smallDialog:showBattleResultDialog("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),isVictory,callback,true,7,award,self.resultStar,self.isFuben)
    else
        if self.isAttacker==true then
            if self.battleReward==-1 then
                isVictory=false
            else
                isVictory=true
                if self.battleReward and type(self.battleReward)=="table" and SizeOfTable(self.battleReward) then
                    award=FormatItem(self.battleReward)
                end
                if self.battleAcReward and type(self.battleAcReward)=="table" and SizeOfTable(self.battleAcReward) then
                  for k,v in pairs(self.battleAcReward) do
                    if acAutumnCarnivalVoApi then
                        local cfg = acAutumnCarnivalVoApi:getGiftCfgForShow()
                        local acCfg = cfg[k]
                        table.insert(award,{name=getlocal(acCfg.name),num=v,pic=acCfg.icon,desc=acCfg.des,id=nil,type=nil,index=SizeOfTable(award)+1,key=nil,eType=nil,equipId=nil})
                    end
                  end
                end
            end
        else
            if self.battleReward~=-1 then
                isVictory=false
            else
                isVictory=true
            end
        end
        --smallDialog:showBattleResultDialog("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),isVictory,callback,true,7,award,self.resultStar)
        -- if self.bossDamage==0 then
        --   do return end
        -- end
        local isKill = false
        if self.destoryPaotou then
          for k,v in pairs(self.destoryPaotou) do
            if v and bossCfg.paotou[v] and bossCfg.paotou[v]==6 then
              isKill=true
            end
          end
        end

        if self.bossType == 2 then
          local content,rewardList = acNewYearsEveVoApi:getBattleRewards(self.bossDamage,self.baseRewards,self.killTypeTab)

          local function showRewardsTip()
                  --显示获取到的奖励的飘窗
                  G_showRewardTip(rewardList, true)
          end                      
          acNewYearsEveSmallDialog:showRewardItemsWithDiffTitleDialog("PanelPopup.png",CCSizeMake(550,650),nil,false,true,true,true,7,content,showRewardsTip,callback)
          -- local tmpTb={}
          -- for k,v in pairs(allRewardList) do
          --     table.insert(tmpTb,{award=v,point=0})
          -- end
          -- -- smallDialog:showSearchDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_tankjianianhua_awardContent"),tmpTb,nil,true,7,nil,true,true)
          -- smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_equipSearch_reward_include"),tmpTb,true,true,7,nil,nil,true)

          --本地添加奖励
          for index,item in pairs(rewardList) do
            G_addPlayerAward(item.type,item.key,item.id,item.num,false,true)   
          end
        else    
          if isKill==true then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("BossBattle_result_kill",{getlocal("BossBattle_name"),self.bossDamage,getlocal("BossBattle_name")}),nil,7,nil,callback)
          elseif SizeOfTable(self.destoryPaotou)>0 then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("BossBattle_result_destory",{getlocal("BossBattle_name"),self.bossDamage,SizeOfTable(self.destoryPaotou)}),nil,7,nil,callback)
          else
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("BossBattle_result_damage",{getlocal("BossBattle_name"),self.bossDamage}),nil,7,nil,callback)
          end
        end
    end
end

function BossBattleScene:stopAction()
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheIndex) --停止计时器
    if self.fireTimer~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
    end
    self.l_grossLayer:stopAllActions()
    self.r_grossLayer:stopAllActions()
    self.l_traceLayer:stopAllActions()
    self.r_traceLayer:stopAllActions()
    
    for k,v in pairs(self.allT1) do
        v.container:setVisible(false)
    end
    for k,v in pairs(self.allT2) do
        v.container:setVisible(false)
    end
end

function BossBattleScene:isBattleFinished()
    for k,v in pairs(self.allT1) do
        if v.isSpace==false then
             do
                return false
             end
        end
    end
    for k,v in pairs(self.allT2) do
        if v.isSpace==false then
             do
                return false
             end
        end
    end
    return true
end

--添加绿地
function BossBattleScene:addLD(idx)
      --左边
         local ldSp=CCSprite:createWithSpriteFrameName("d_1.png")
         ldSp:setAnchorPoint(ccp(0.5,0.5))
         winPos=ccp(600,G_VisibleSize.height*0.7)
         
         self.l_traceLayer:addChild(ldSp)
         
         local layerPos=self.l_traceLayer:convertToNodeSpace(winPos)
         ldSp:setPosition(layerPos)
      --右边
         
end
function BossBattleScene:addZW(idx)
        
       if idx%5==0 then 
                   local treeIndex=0
                   for i=1,4 do
                       treeIndex=math.ceil((deviceHelper:getRandom()/100)*4)

                       if treeIndex==0 then
                            treeIndex=1
                       end
                       local zwSp=CCSprite:createWithSpriteFrameName("zawu_"..self.zwTreeTb[treeIndex]..".png")
                       zwSp:setAnchorPoint(ccp(0.5,0))
                       local winPos
                       local randNum
                       if i==1 then --左上边
                            randNum=math.ceil((deviceHelper:getRandom()/100)*60)
                            winPos=ccp(310-randNum,G_VisibleSize.height*0.7-120)
                            randNum=120-randNum
                       elseif i==2 then --左下边
                            randNum=math.ceil((deviceHelper:getRandom()/100)*50)
                            winPos=ccp(640+80+randNum,G_VisibleSize.height*0.25-110)
                       
                       elseif i==3 then --右上边
                            randNum=math.ceil((deviceHelper:getRandom()/100)*50)
                            winPos=ccp(-60-randNum,G_VisibleSize.height*0.7+20)
                            randNum=100-randNum
                       else --右下边
                            randNum=math.ceil((deviceHelper:getRandom()/100)*50)
                            winPos=ccp(640-200+randNum,G_VisibleSize.height*0.25+20)
                       end
                       local layerPos
                       randNum=randNum+20
                       if i==1 then
                            layerPos=self.l_traceLayer:convertToNodeSpace(winPos)
                            self.l_traceLayer:addChild(zwSp,randNum)
                       elseif i==2 then
                            layerPos=self.l_bombLayer:convertToNodeSpace(winPos)
                            self.l_bombLayer:addChild(zwSp,randNum)
                       elseif i==3 then
                            layerPos=self.r_traceLayer:convertToNodeSpace(winPos)
                            self.r_traceLayer:addChild(zwSp,randNum)
                       else
                            layerPos=self.r_bombLayer:convertToNodeSpace(winPos)
                            self.r_bombLayer:addChild(zwSp,randNum)
                       end
                       zwSp:setPosition(layerPos)
                       
                       local function removeZWHandler()
                            zwSp:removeFromParentAndCleanup(true)
                            zwSp=nil
                       end
                       local ccdelay=CCDelayTime:create(5)
                       local  ffunc=CCCallFuncN:create(removeZWHandler)
                       local  fseq=CCSequence:createWithTwoActions(ccdelay,ffunc)
                       zwSp:runAction(fseq)
                   end
       end
        
       if idx%4==0 then  --添加破旧房屋
             for i=1,1 do
                   local zIndex=math.ceil((deviceHelper:getRandom()/100)*7)
                   if zIndex==0 then
                        zIndex=1
                   end
                   local zwSp=CCSprite:createWithSpriteFrameName("zawu_"..zIndex..".png")
                   zwSp:setAnchorPoint(ccp(0.5,0))
                   local winPos
                   local randNum
                   if i==1 then --左上边
                        randNum=math.ceil((deviceHelper:getRandom()/100)*60)
                        winPos=ccp(310-randNum,G_VisibleSize.height*0.7-30)
                        
                   elseif i==2 then --左下边
                        randNum=math.ceil((deviceHelper:getRandom()/100)*50)
                        winPos=ccp(640+80+randNum,G_VisibleSize.height*0.25-110)
                   
                   elseif i==3 then --右上边
                        randNum=math.ceil((deviceHelper:getRandom()/100)*50)
                        winPos=ccp(-60-randNum,G_VisibleSize.height*0.7+20)
                        randNum=100-randNum
                   else --右下边
                        randNum=math.ceil((deviceHelper:getRandom()/100)*50)
                        winPos=ccp(640-300+randNum,G_VisibleSize.height*0.25+50)
                   end
                   local layerPos
                   randNum=randNum+20
                   if i==1 then
                        layerPos=self.l_traceLayer:convertToNodeSpace(winPos)
                        self.l_traceLayer:addChild(zwSp,18)
                   elseif i==2 then
                        layerPos=self.l_bombLayer:convertToNodeSpace(winPos)
                        self.l_bombLayer:addChild(zwSp,18)
                   elseif i==3 then
                        layerPos=self.r_traceLayer:convertToNodeSpace(winPos)
                        self.r_traceLayer:addChild(zwSp,randNum)
                   else
                        layerPos=self.r_bombLayer:convertToNodeSpace(winPos)
                        self.r_bombLayer:addChild(zwSp,randNum)
                   end
                   zwSp:setPosition(layerPos)
                   
                   local function removeZWHandler()
                        zwSp:removeFromParentAndCleanup(true)
                        zwSp=nil
                   end
                   local ccdelay=CCDelayTime:create(5)
                   local  ffunc=CCCallFuncN:create(removeZWHandler)
                   local  fseq=CCSequence:createWithTwoActions(ccdelay,ffunc)
                   zwSp:runAction(fseq)
       end

       end
end
function BossBattleScene:close()
    if self.isFuben==true or self.bossType==3 then
        allianceFubenScene:setShowWhenEndBattle()
        -- if G_WeakTb.allianceDialog then
        --     G_WeakTb.allianceDialog:setDisplay(true)
        -- end
    else
        storyScene:setShowWhenEndBattle()
        if storyScene.checkPointDialog[1]~=nil then
            storyScene.checkPointDialog[1]:setShow()
        end
    end
    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheIndex) --停止计时器
    if self.fireTimer~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
    end
    self.container:removeFromParentAndCleanup(true)
    self:dispose()
end

function BossBattleScene:fastTick()
    self.fastTickIndex=self.fastTickIndex+1
    if self.fastTickIndex%2==0 then
         do
            return
         end
    end
    local curTime=G_getCurDeviceMillTime()
    if self.r_ShakeStTime~=0 and (curTime-self.r_ShakeStTime)<=1000 then
         self.r_isShakeing=true
         local rndx =5-(deviceHelper:getRandom()/100)*10
         local rndy =5-(deviceHelper:getRandom()/100)*10
         self.r_container:setPosition(ccp(rndx,rndy))
    else
         if self.r_isShakeing==true then
             self.r_container:setPosition(ccp(0,0))
             self.r_isShakeing=false
         end
    end
    if self.l_ShakeStTime~=0 and (curTime-self.l_ShakeStTime)<=1000 then
         self.l_isShakeing=true
         local rndx =5-(deviceHelper:getRandom()/100)*10
         local rndy =5-(deviceHelper:getRandom()/100)*10
         self.l_container:setPosition(ccp(rndx,rndy))
    else
         if self.l_isShakeing==true then
             self.l_container:setPosition(ccp(0,0))
             self.l_isShakeing=false
         end
    end
end

function BossBattleScene:mapShake(area)
    if area==1 then
         self.r_ShakeStTime=G_getCurDeviceMillTime()
    else
         self.l_ShakeStTime=G_getCurDeviceMillTime()
    end
end


function BossBattleScene:showStarAni(parent,m_starnum)
    --[[
    local parent=CCSprite:createWithSpriteFrameName("SuccessHeader.png");
    parent:setPosition(320,480)
    sceneGame:addChild(parent,99)
    ]]
    
    local starheight=parent:getContentSize().height/2+30;

    local star1 = CCSprite:createWithSpriteFrameName("gameoverstar_black.png");
    star1:ignoreAnchorPointForPosition(false);
    star1:setAnchorPoint(ccp(0.5,0.5));
    star1:setPosition(ccp(parent:getContentSize().width/2-100 ,starheight));
    star1:setScale(0.8);
    parent:addChild(star1);
    
    local star2 = CCSprite:createWithSpriteFrameName("gameoverstar_black.png");
    star2:ignoreAnchorPointForPosition(false);
    star2:setAnchorPoint(ccp(0.5,0.5));
    star2:setPosition(ccp(parent:getContentSize().width/2,starheight));
    parent:addChild(star2);
    
    local star3 = CCSprite:createWithSpriteFrameName("gameoverstar_black.png");
    star3:ignoreAnchorPointForPosition(false);
    star3:setAnchorPoint(ccp(0.5,0.5));
    star3:setPosition(ccp(parent:getContentSize().width/2+100,starheight));
    star3:setScale(0.8);
    parent:addChild(star3);
    
    local star1_1 = CCSprite:createWithSpriteFrameName("gameoverstar_gray.png");
    star1_1:ignoreAnchorPointForPosition(false);
    star1_1:setAnchorPoint(ccp(0.5,0.5));
    star1_1:setPosition(ccp(parent:getContentSize().width/2-100,starheight));
    star1_1:setScale(0.8);
    star1_1:setVisible(false);
    parent:addChild(star1_1);
    
    local star2_1 = CCSprite:createWithSpriteFrameName("gameoverstar_gray.png");
    star2_1:ignoreAnchorPointForPosition(false);
    star2_1:setAnchorPoint(ccp(0.5,0.5));
    star2_1:setPosition(ccp(parent:getContentSize().width/2,starheight));
    star2_1:setVisible(false);
    star2_1:setTag(-10000);
    parent:addChild(star2_1);
    
    local star3_1 = CCSprite:createWithSpriteFrameName("gameoverstar_gray.png");
    star3_1:ignoreAnchorPointForPosition(false);
    star3_1:setAnchorPoint(ccp(0.5,0.5));
    star3_1:setPosition(ccp(parent:getContentSize().width/2+100,starheight));
    star3_1:setScale(0.8);
    star3_1:setTag(-11000);
    star3_1:setVisible(false);
    parent:addChild(star3_1);
    

    local function playMusic()
        PlayEffect(audioCfg.battle_star)
    end
    
    local  spcArr=CCArray:create()
                   
    for kk=1,10 do
        local nameStr="star_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        spcArr:addObject(frame)
    end

    local animation=CCAnimation:createWithSpriteFrames(spcArr)
    animation:setRestoreOriginalFrame(true);
    animation:setDelayPerUnit(0.6/10)
    local animate=CCAnimate:create(animation)
    local starTime = 0.1;
    

    local scaleTo = CCScaleTo:create(0, 0.8);
    local scaleBy = CCScaleBy:create(starTime, 0.8*0.8);
    local fadeTo = CCFadeTo:create(starTime, 255);
    
    local carray=CCArray:create()
    carray:addObject(animate)
    carray:addObject(scaleTo)
    local spa=CCSpawn:create(carray)
    
    local carray1=CCArray:create()
    carray1:addObject(scaleBy)
    carray1:addObject(fadeTo)
    local spa2=CCSpawn:create(carray1)
    local block1 = CCScaleTo:create(0, 0.8);
    local block2 = CCFadeTo:create(0, 255);
    star1_1:setVisible(true);
    star1_1:setScale(3*0.8);
    star1_1:setOpacity(125);
    
    
    local function createBlockActionStarTwo()
        local starTime = 0.1;
        star2_1 : setVisible(true);
        star2_1 : setScale(3);
        star2_1 : setOpacity(125);
        local scaleto = CCScaleTo:create(0, 1);
        local scaleBy = CCScaleTo:create(starTime, 0.8);
        local fadeTo = CCFadeTo:create(starTime, 125);

        local carray=CCArray:create()
        carray:addObject(animate)
        carray:addObject(scaleTo)
        local spa=CCSpawn:create(carray)
        
        local carray1=CCArray:create()
        carray1:addObject(scaleBy)
        carray1:addObject(fadeTo)
        local spa2=CCSpawn:create(carray1)
        local block1 = CCScaleTo:create(0, 1);
        local block2 = CCFadeTo:create(0, 255);
        
        local acArr=CCArray:create()
        acArr:addObject(spa2)
        acArr:addObject(block2)
        local callFuncmusic=CCCallFunc:create(playMusic)
       local carray3=CCArray:create()
       carray3:addObject(spa)
       carray3:addObject(callFuncmusic)
       local spa3=CCSpawn:create(carray3)
        acArr:addObject(spa3)
        acArr:addObject(block1)
        local seq=CCSequence:create(acArr)
        star2_1:runAction(seq);
    
    end
    
    local function createBlock3InBlock3()
        local starTime = 0.1;
        star3_1 : setVisible(true);
        star3_1 : setScale(3*0.8);
        star3_1 : setOpacity(125);
        local scaleto = CCScaleTo:create(0, 1);
        local scaleBy = CCScaleTo:create(starTime, 0.8*0.8);
        local fadeTo = CCFadeTo:create(starTime, 125);
        
        local carray=CCArray:create()
        carray:addObject(animate)
        carray:addObject(scaleTo)
        local spa=CCSpawn:create(carray)
        
        local carray1=CCArray:create()
        carray1:addObject(scaleBy)
        carray1:addObject(fadeTo)
        local spa2=CCSpawn:create(carray1)
        local block1 = CCScaleTo:create(0, 0.8);
        local block2 = CCFadeTo:create(0, 255);
        
        local acArr=CCArray:create()
        acArr:addObject(spa2)
        acArr:addObject(block2)
        local callFuncmusic=CCCallFunc:create(playMusic)
       local carray3=CCArray:create()
       carray3:addObject(spa)
       carray3:addObject(callFuncmusic)
       local spa3=CCSpawn:create(carray3)
        acArr:addObject(spa3)
        acArr:addObject(block1)
        local seq=CCSequence:create(acArr)
        star3_1:runAction(seq);
    
    end
    
    local function createBlockActionStarThree()
        local starTime = 0.1;
        star2_1 : setVisible(true);
        star2_1 : setScale(3);
        star2_1 : setOpacity(125);
        local scaleto = CCScaleTo:create(0, 1);
        local scaleBy = CCScaleTo:create(starTime, 0.8);
        local fadeTo = CCFadeTo:create(starTime, 125);
        
        local carray=CCArray:create()
        carray:addObject(animate)
        carray:addObject(scaleTo)
        local spa=CCSpawn:create(carray)
        
        local carray1=CCArray:create()
        carray1:addObject(scaleBy)
        carray1:addObject(fadeTo)
        local spa2=CCSpawn:create(carray1)
        local block1 = CCScaleTo:create(0, 1);
        local block2 = CCFadeTo:create(0, 255);
        
        local acArr=CCArray:create()
        acArr:addObject(spa2)
        acArr:addObject(block2)
        local callFuncmusic=CCCallFunc:create(playMusic)
       local carray3=CCArray:create()
       carray3:addObject(spa)
       carray3:addObject(callFuncmusic)
       local spa3=CCSpawn:create(carray3)
        acArr:addObject(spa3)
        acArr:addObject(block1)
        local callFunc=CCCallFunc:create(createBlock3InBlock3)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        star2_1:runAction(seq);
    
    end



    if m_starnum==1 then

       local acArr=CCArray:create()
       acArr:addObject(spa2)
       acArr:addObject(block2)
       

       local callFuncmusic=CCCallFunc:create(playMusic)
       local carray3=CCArray:create()
       carray3:addObject(spa)
       carray3:addObject(callFuncmusic)
       local spa3=CCSpawn:create(carray3)

       acArr:addObject(spa3)
       acArr:addObject(block1)
       local seq=CCSequence:create(acArr)
       star1_1:runAction(seq);

    elseif m_starnum==2 then
    
       local acArr=CCArray:create()
       acArr:addObject(spa2)
       acArr:addObject(block2)
       local callFuncmusic=CCCallFunc:create(playMusic)
       local carray3=CCArray:create()
       carray3:addObject(spa)
       carray3:addObject(callFuncmusic)
       local spa3=CCSpawn:create(carray3)
       acArr:addObject(spa3)
       acArr:addObject(block1)
       local callFunc=CCCallFunc:create(createBlockActionStarTwo)
       acArr:addObject(callFunc)
       local seq=CCSequence:create(acArr)
       star1_1:runAction(seq);
       
    elseif m_starnum==3 then
       local acArr=CCArray:create()
       acArr:addObject(spa2)
       acArr:addObject(block2)
       local callFuncmusic=CCCallFunc:create(playMusic)
       local carray3=CCArray:create()
       carray3:addObject(spa)
       carray3:addObject(callFuncmusic)
       local spa3=CCSpawn:create(carray3)
       acArr:addObject(spa3)
       acArr:addObject(block1)
       local callFunc=CCCallFunc:create(createBlockActionStarThree)
       acArr:addObject(callFunc)
       local seq=CCSequence:create(acArr)
       star1_1:runAction(seq);
    
    end

end

function BossBattleScene:checkIsAttackSelf(btdata)
    local isAttackSelf=false
    local effectTB=Split(btdata,"-")
    local firstData=effectTB[1]
    if firstData~=nil then
          if string.sub(firstData,1,1)=="D" then
                isAttackSelf=true
                effectTB[1]=string.sub(firstData,2)
                return isAttackSelf,effectTB[1].."-"..effectTB[2]
          end
    end
    
    return isAttackSelf,nil
end


function BossBattleScene:checkAnimEffectByData(btdata) --根据后台返回的数据得出双方具体的技能动画效果
  -- print("+++++++++++++++++++++++")
  --   print("btdata",btdata)
    local effectTB=Split(btdata,"-")

    if #effectTB>=3 then --只有包含第3位的才可能有技能效果
           local effectData=effectTB[3]
           local attackerData={}
           local beattackerData={}
           local isAttackers=true
           local bjzd=0
           for i=1,string.len(effectData),1 do
                  local oneChar=string.sub(effectData,i,i)

                        if tonumber(oneChar)~=nil then
                             isAttackers=false
                             bjzd=tonumber(oneChar)
                        end

                  if tonumber(oneChar)==nil then
                         if isAttackers==true then
                              table.insert(attackerData,oneChar)
                         else
                               table.insert(beattackerData,oneChar)
                         end
                  end
           end
           return attackerData,beattackerData,effectTB[1].."-"..effectTB[2].."-"..bjzd
    end
    local atkData=effectTB[1]
    if #effectTB>=2 then
        atkData=effectTB[1].."-"..effectTB[2]
    end
    return nil,nil,atkData

end


function BossBattleScene:disposeWhenChangeServer()
    if self.fireTimer~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
        self.fireTimer=nil
    end
    
    if self.scheIndex~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheIndex)
        self.scheIndex=nil
    end
end

function BossBattleScene:hasSpcSkil(director,stype,tid) --方向1或2、技能类型、坦克id
     if self.spcSkill~=nil then
             local allSkillTB=self.spcSkill[director]
             if allSkillTB[stype]~=nil then
                  for kk,vv in pairs(allSkillTB[stype]) do
                       local lcTid ="a"..tostring(G_pickedList(tonumber(RemoveFirstChar(vv))))--
                       if  lcTid==tid then
                          do
                              return true
                          end
                       end
                  end
             end
     end
     return false
end

function BossBattleScene:reflexHurtToBoss(fireTank,mm)
    local firePos = {ccp(150,263),ccp(225,241),ccp(283,198),ccp(252,344),ccp(328,333),ccp(392,272)}
    local firePosIndex = mm--SizeOfTable(firePos)-mm+1
    if fireTank:getBossTankNum()[firePosIndex]==nil then
       firePosIndex = SizeOfTable(firePos)-SizeOfTable(fireTank:getBossTankNum())+firePosIndex
    end
    if fireTank:getBossTankNum()[firePosIndex]==nil then
       firePosIndex=firePosIndex-1
    end
    if fireTank:getBossTankNum()[firePosIndex]==nil or (firePosIndex>SizeOfTable(firePos)) then
       firePosIndex=5
    end
    fireTank:beAttacked(1+mm*0.5,10165,23,self.reflexHurtTb[mm].."-1",nil,nil,nil,firePosIndex,nil,nil,false)

end

function BossBattleScene:dispose()
    self.endBtnItemMenu=nil
    for k,v in pairs(self.allT1) do
        v:dispose()
        v=nil
    end
    for k,v in pairs(self.allT2) do
        v:dispose()
        v=nil
    end
    self.container=nil
      self.l_container=nil
      self.r_container=nil
      self.l_grossLayer=nil  --草地1层
      self.l_traceLayer=nil    --痕迹2层
      self.l_shellLayer=nil    --飞弹4层
      self.r_grossLayer=nil    --草地1层
      self.r_traceLayer=nil    --痕迹2层
      self.r_shellLayer=nil    --飞弹4层
     self.r_tankLayer=nil    --右边坦克3层
     self.l_tankLayer=nil    --左边坦克3层
     self.r_bombLayer=nil --右边爆炸效果5层
     self.l_bombLayer=nil --左边爆炸效果5层
     self.allT1=nil
     self.allT1={}
     self.allT2=nil
     self.allT2={}
     self.tickIndex=1
     self.leftPlayerSp=nil
     self.rightPlayerSp=nil
     self.VSp=nil
     self.SSp=nil
     self.battleData=nil
      self.scheIndex=nil
    self.hhNum=1
    self.startFire=false
    self.lFireIndex=1
    self.rFireIndex=1
    self.nextFire=0
    self.isBattleEnd=false
    self.battleReward=nil
    self.battleAcReward=nil
    self.isBattleing=false
  self.isAttacker=nil
    self.isReport=false
    self.isFuben=false
    self.isWin=nil  --是否胜利(攻击者)
    self.l_ShakeStTime=0 --左边震动开始时间
    self.r_ShakeStTime=0 --右边震动开始时间
    self.l_isShakeing=false
    self.r_isShakeing=false
    self.fastTickIndex=0
    self.serverWarType=nil
    self.serverWarTeam=nil
    self.heroData=nil
    self.supperWeaponSpTb={}
    self.heroSpTb={}
    self.isPickedTankTb={}
    self.isShowSW=false
    self.isShowHero=false
    G_releaseHeroImage()
    self.firstValue1=1000
    self.firstValue2=1000
    self.baseRewards=nil--战斗结束的基础奖励
    self.killTypeTab=nil--战斗结束后摧毁的炮头类型列表 1：普通炮头，2：特殊炮头
    self.bossType=1--boss战斗的boss类型 1：海德拉boss，2：新年除夕年兽boss
    self.bossDamage=0
    self.hhLb =nil
    self.hhSp =nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ship/tankRestraint.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("ship/tankRestraint.pvr.ccz")
    CCTextureCache:sharedTextureCache():removeTextureForKey("scene/cityR1_mi.jpg")
    CCTextureCache:sharedTextureCache():removeTextureForKey("scene/cityR2_mi.jpg")
    spriteController:removePlist("public/emblem/emblemImage.plist")
    spriteController:removeTexture("public/emblem/emblemImage.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemBattleBg1.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemBattleBg2.png")
    spriteController:removePlist("public/emblemSkillBg.plist")
    spriteController:removeTexture("public/emblemSkillBg.png")
    if platCfg.platCfgNewTypeAddTank then
      self:removeRes()
    end
    self.addResPathTb=nil
    self.fjTb = nil
    G_battleSpeed = self.recSpeed
    self.skinTb = nil
    self.airShipTb = nil
    self.airShipSpTb = nil
end


