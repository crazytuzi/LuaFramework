
-- 坦克战报数据格式(一个完整字串)：
  -- 连击与空中支援及其它特殊技能触发
    -- 连击是'$'      {23-4}{$}{23-3}
    -- 空中支援是'@'  {@}{23-4}
    -- 特殊技能如'K'之类会出现在前两种（$,@）符号后，表示下一个串会触发这个技能   {$K}{23-4}
  -- 闪避时整个串是'0'   {0}
  -- 本回合开火前受到的敌对坦克技能伤害,字串按'-'分割
    -- 第一段 本次自己扣血量   {D524-143} 烧自己
      -- 血量前会有以英文字母标识的本回合前所受到的敌方坦克技能效果
    -- 第二段 剩余坦克数量
  -- 击中时字串按'-'分割   {58674-61-B0C} 自己触发B技能 目标触发C技能   对应的小写字母是移除对应的技能
    -- 第一段 第一炮扣血量
    -- 第二段 剩余坦克数量
    -- 第三段 以数值0/1标识是否暴击,数字标识前后会有以英文字母标识的本次攻击触发的一些坦克技能
      -- 0非暴击
      -- 1是暴击
      -- 坦克技能分作用对象出现在暴击标识前后,暴击标识前的表示作用于自己，暴击标识后的表示作用于目标
        -- 大写是触发
        -- 小写是技能效果消失
-- 字串示例：
-- "$" 下一字串是本回合连击的串
-- "@" 下一字串是空中支援的串
-- "K" 下一字串会触发'K'技能
-- 闪避 "0"
-- 触发技能 "58674-61-B0C",
-- 本回合自己受到技能伤害 "D524-143",



require "luascript/script/game/scene/tank/tank"
require "luascript/script/game/scene/tank/plane"
require "luascript/script/game/scene/tank/aiTank"
require "luascript/script/game/scene/tank/tankBufSmallDialog"
battleScene={
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
  hhNum      =1, --回合数
  lFireIndex =1, --左边开炮的坦克索引
  rFireIndex =1, --右边开炮的坦克索引
  nextFire   =0, --下一次开火的是哪边的坦克  1:左边 2:右边
  fireIndex, --开火索引（用于检索后台返回的数据）
  fireIndexTotal, --开火索引总数
  startFire=false,
  fireTimer, --战斗开火计时器
  isBattleEnd=false,
  battleReward,
  battleAcReward,
  battlePaused =false,
  isBattleing  =false,
  zwTickIndex  =0,
  zwTreeTb     ={4,2,3,1},
  isAttacker,
  isReport, --是否是战报回放
  isFuben, --是否是军团副本
  isWin,  --是否胜利(攻击者)
  leftMovDis  =ccp(-938,-422),
  rightMovDis =ccp(690,342),
  
  --地图震动相关
  l_isShakeing  =false,
  r_isShakeing  =false,
  l_ShakeStTime =0, --左边震动开始时间
  r_ShakeStTime =0, --右边震动开始时间
  fastTickIndex =0,
  --
  
  endBtnItem       =nil,--跳过按钮
  endBtnItemMenu   =nil,
  
  resultStar       =1,
  serverWarType    =nil,
  serverWarTeam    =nil,
  alienBattleData  =nil,
  heroSpTb         ={},
  supperWeaponSpTb ={},
  isPickedTankTb   ={},
  heroData         =nil,
  isShowHero       =false,
  isShowSW         =false,
  isNewBufShow     =true,
  firstValue1      =1000,
  firstValue2      =1000,
  is10074Skill     =false, --10074 坦克技能专用
  is10094Skill     =false, --10094 坦克技能专用
  spcSkill         =nil, --特殊技能，为了异性科技加的
  bfSkill, --开战前的BUF
  bfSkilledTb             ={}, --已使用过的 开战前的BUF
  mapscale                =1,
  mapreletivepos          ={ccp(1024,512),ccp(2048,1024)},--地图相对拼接相对位置
  l_mappos                ={ccp(-320,-5)},--左下角地图初始位置
  r_mappos                ={ccp(-1950,-1026+G_VisibleSizeHeight*0.5)},--右上角初始位置
  
  mapmoveBy               ={ccp(-1024,-513),ccp(1024,512)},--地图移动(左下，右上)--2048 1026
  landform                =nil, --地形
  battleType              =nil,--战斗类型，是哪个战斗场景,1:区域战,2:超级武器关卡战斗,3:超级武器抢夺碎片,4:平台战战报,5:军事演习,6:群雄争霸,7异星矿场,8将领装备,37：狂热集结，38：军团锦标赛个人战
  acData                  =nil, --活动数据，acType区分活动类型，{acType="",...}
  winCondition            =nil, --超级武器关卡过关条件
  swId                    =nil, --超级武器关卡id
  robData                 =nil, --超级武器抢夺
  upgradeTanks            ={}, --生成的精锐坦克列表
  levelTb                 ={}, -- 关卡部队信息
  challenge               =0, -- 攻打关卡能再次攻打 1：能 0：不能
  ecId                    =nil,--装备探索id
  closeResultPanelHandler =nil,--关闭结算面板回调函数
  zOrder                  =nil,
  rebel                   =nil, --叛军数据
  warSpeed                =0.5,
  speedShowArr     = {},
  
  fjFireIndex      = 0,--飞机开火索引
  fjFireIndexTotal = 0,--飞机开火索引总数
  fjNextFire       = 0,--下一次开火的是哪边的飞机  1:左边 2:右边
  fjIsFire         = false,
  allPlane         = {},--第7战斗位：左右两架飞机
  firstData        = {}, --原始数据，用于战斗回放

  allAI1 = {},--ai部队1 tb  
  allAI2 = {},--ai部队2 tb  
  aiFireIndex,--ai开火索引（用于检索后台返回的数据）
  aiFireIndexTotal,
  lAIFireIndex = 1, --左边AI开炮的坦克索引
  rAIFireIndex = 1,
  aiIsBlank    = {},--攻击类型的ai部队的空击表
}

function battleScene:formatFaData(faData)
    self.fjfaTb = nil
    self.fjCurEnergyTb = {1,1} --默认为 1,1 第一回合默认 1点能量
    if faData then
        self.fjfaTb = {}
        for k,v in pairs(faData) do
            local formatTb = Split(v,"-")    -- v : "1-1-0-1" 第一个位置：第几回合（触发技能的前一回合） 第二个位置：攻守哪一方 第三个位置：减少的能量点 第四个位置：增加的能量点
            if not self.fjfaTb[tonumber(formatTb[1]) + 1] then
              self.fjfaTb[tonumber(formatTb[1]) + 1] = {}
            end
            self.fjfaTb[tonumber(formatTb[1]) + 1][tonumber(formatTb[2])] = formatTb -- 后台返回的回合数 是当前回合数，是技能触发的前一个回合，所以此处要 + 1
        end
    end
end

function battleScene:initPickedTankSp( )
  local isEliteTb = {}
  for i=1,12 do
    if self.isPickedTankTb[i] then
      local tankId =tonumber(RemoveFirstChar(self.isPickedTankTb[i]))
      -- print("self.isPickedTankTb[i]:....",self.isPickedTankTb[i],tankId)
      if tankId then
        isEliteTb[i]=tankCfg[tankId].isElite
      else
        isElite[i]=nil
      end
    end
  end
  for k,v in pairs(self.allT1) do
      if tonumber(k) and isEliteTb[k] and isEliteTb[k]==1 then
        local pickedSp = CCSprite:createWithSpriteFrameName("picked_icon1.png")
        -- pickedSp:setScale()
        pickedSp:setAnchorPoint(ccp(1,0.5))
        pickedSp:setPosition(ccp(v.sprite:getContentSize().width*0.7,v.sprite:getContentSize().height*0.5-10))
        v.sprite:addChild(pickedSp)
      end
  end
  for k,v in pairs(self.allT2) do
      if tonumber(k) and isEliteTb[k+6] and isEliteTb[k+6]==1 then
        local pickedSp = CCSprite:createWithSpriteFrameName("picked_icon1.png")
        -- pickedSp:setScale()
        pickedSp:setAnchorPoint(ccp(1,0.5))
        pickedSp:setPosition(ccp(v.sprite:getContentSize().width*0.7,v.sprite:getContentSize().height*0.5-10))
        v.sprite:addChild(pickedSp)
      end
  end
end
function battleScene:initSuperWeaponSp( )
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
            swIcon:setPosition(ccp(v.sprite:getContentSize().width/2-90,v.sprite:getContentSize().height-5))
          else
            swIcon:setPosition(ccp(v.sprite:getContentSize().width/2-50,v.sprite:getContentSize().height-5))
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
function battleScene:initHeroSp()
    
    for k,v in pairs(self.allT1) do
      if self.heroData~=nil and self.heroData[1]~=nil and self.heroData[1][k]~=nil and self.heroData[1][k]~="" then
         local heroVo=Split(self.heroData[1][k],"-")
         local adjutants = heroAdjutantVoApi:decodeAdjutant(self.heroData[1][k])
         local heroSp=heroVoApi:getHeroIcon(heroVo[1],heroVo[3],nil,nil,nil,nil,nil,{adjutants=adjutants})
         table.insert(self.heroSpTb,heroSp)
         heroSp:setScale(0.3)
         heroSp:setAnchorPoint(ccp(0.5,0))
         if k==1 or k==2 or k==3 then
            heroSp:setPosition(ccp(v.sprite:getContentSize().width/2-45,v.sprite:getContentSize().height-5))
         else
            heroSp:setPosition(ccp(v.sprite:getContentSize().width/2-5,v.sprite:getContentSize().height-5))
         end
         v.sprite:addChild(heroSp)
         heroSp:setVisible(false)
      end
    end

    for k,v in pairs(self.allT2) do
      if self.heroData~=nil and self.heroData[2]~=nil and self.heroData[2][k]~=nil and self.heroData[2][k]~="" then
         local heroVo=Split(self.heroData[2][k],"-")
         local adjutants = heroAdjutantVoApi:decodeAdjutant(self.heroData[2][k])
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

      if base.isNewBufPos==1 then
        if self.isNewBufShow ==true  then
          for k,v in pairs(self.allT1) do
            if v.bufShowMask then
              v.bufShowMask:setVisible(false)
            end
          end
          for k,v in pairs(self.allT2) do
            if v.bufShowMask then
              v.bufShowMask:setVisible(false)
            end
          end
          self.isNewBufShow =false
        else
          for k,v in pairs(self.allT1) do
            if v.bufShowMask then
              v.bufShowMask:setVisible(true)
            end
          end
          for k,v in pairs(self.allT2) do
            if v.bufShowMask then
              v.bufShowMask:setVisible(true)
            end
          end
          self.isNewBufShow =true
        end
      end
    end
    local infoItem = GetButtonItem("battleHeroBtn.png","battleHeroBtnDown.png","battleHeroBtn.png",showInfo,11,nil,nil)
    infoItem:setAnchorPoint(ccp(0,0))
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(0,0))
    infoBtn:setPosition(ccp(125,15))
    infoBtn:setTouchPriority(-281);
    self.container:addChild(infoBtn,3);
    if(G_isHexie()) or newGuidMgr:isNewGuiding()==true or self.battleType == 37 then
      infoBtn:setVisible(false)
    end

    if newGuidMgr:isNewGuiding()==false then

        local function changeSpeedCall( )
            if G_battleSpeed == 1 then
                G_battleSpeed = 0.5
                if self.speedShowArr[2] then
                  self.speedPicShow:setDisplayFrame(self.speedShowArr[2])
                end
            elseif G_battleSpeed == 0.5 then
                G_battleSpeed = 0.3
                if self.speedShowArr[3] then
                  self.speedPicShow:setDisplayFrame(self.speedShowArr[3])
                end
            elseif G_battleSpeed == 0.3 then
                G_battleSpeed = 1
                if self.speedShowArr[1] then
                  self.speedPicShow:setDisplayFrame(self.speedShowArr[1])
                end
            end
        end
        local quickItem = GetButtonItem("quickBtn.png","quickBtnDown.png","quickBtn.png",changeSpeedCall,11,nil,nil)
        quickItem:setAnchorPoint(ccp(0,0))
        local quickBtn = CCMenu:createWithItem(quickItem);
        quickBtn:setAnchorPoint(ccp(0,0))
        quickBtn:setPosition(ccp(20,15))
        quickBtn:setTouchPriority(-281);
        self.container:addChild(quickBtn,3);

        for i=1,3 do
            local frameSp = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("speed_"..i..".png") 
            self.speedShowArr[i] = frameSp
        end

        if G_battleSpeed == 1 then
            self.speedPicShow = CCSprite:createWithSpriteFrameName("speed_1.png")
        elseif G_battleSpeed == 0.5 then
            self.speedPicShow = CCSprite:createWithSpriteFrameName("speed_2.png")
        elseif G_battleSpeed == 0.3 then
            self.speedPicShow = CCSprite:createWithSpriteFrameName("speed_3.png")
        end
        if self.speedPicShow then
            self.speedPicShow:setAnchorPoint(ccp(0.5,0))
            self.speedPicShow:setPosition(getCenterPoint(quickItem))
            quickItem:addChild(self.speedPicShow)
        end

    end

    if self.battleType ~= 37 then--狂热集结功能 不需要显示

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
end

function battleScene:init()
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

    self.upSlideSP = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    self.upSlideSP:setContentSize(CCSizeMake(G_VisibleSizeWidth,140))
    self.upSlideSP:setOpacity(0)
    self.upSlideSP:setAnchorPoint(ccp(0.5,1))
    self.upSlideSP:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight))
    self.container:addChild(self.upSlideSP,22)

    self.leftPlayerSp:setAnchorPoint(ccp(0,0))
    self.rightPlayerSp:setAnchorPoint(ccp(0,0))
    
    self.leftPlayerSp:setPosition(ccp(0,self.upSlideSP:getContentSize().height-self.leftPlayerSp:getContentSize().height))
    self.rightPlayerSp:setPosition(ccp(self.upSlideSP:getContentSize().width-self.rightPlayerSp:getContentSize().width,self.upSlideSP:getContentSize().height-self.rightPlayerSp:getContentSize().height))
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
                    local rebelLv,rebelID,rpic=1,1,0
                    if self.rebel then
                        rebelLv,rebelID,rpic=self.rebel.rebelLv or 1,self.rebel.rebelID or 1,self.rebel.rpic or 0
                    end
                    leftPName=G_getIslandName(self.playerData[2][1],nil,rebelLv,rebelID,false,rpic)
                else
                    leftPName=getlocal("world_island_"..self.playerData[2][1])
                end
            end
       end
       if tonumber(self.playerData[1][1])==nil or tonumber(self.playerData[1][1])>7 then
            if tonumber(self.playerData[1][1]) == 9 then
                if self.shipboss and self.shipboss.bType then
                  rightPName = getlocal("airShip_bossNameType" .. self.shipboss.bType)
                end
            else
           rightPName=self.playerData[1][1]
           if tonumber(rightPName)~=nil then
              rightPName=arenaVoApi:getNpcNameById(tonumber(rightPName))
           end
            end
       else
            if self.alienBattleData then
                rightPName=getlocal("alienMines_island_name_"..self.playerData[1][1])
            else
                if self.playerData[1][1]==7 then
                    local rebelLv,rebelID,rpic=1,1,0
                    if self.rebel then
                        rebelLv,rebelID,rpic=self.rebel.rebelLv or 1,self.rebel.rebelID or 1,self.rebel.rpic or 0
                    end
                    rightPName=G_getIslandName(self.playerData[1][1],nil,rebelLv,rebelID,false,rpic)
                elseif tonumber(self.playerData[1][1]) == 9 then
                    if self.shipboss and self.shipboss.bType then
                      rightPName = getlocal("airShip_bossNameType" .. self.shipboss.bType)
                    end
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
        if self.personalRebelData and self.personalRebelData.prName then --个人叛军名字
          rightPName = self.personalRebelData.prName
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
    self.upSlideSP:addChild(self.leftPlayerSp)
    self.upSlideSP:addChild(self.rightPlayerSp)
    self.container:setTouchEnabled(true)
    self.container:setBSwallowsTouches(true) --屏蔽底层响应
    self.container:setTouchPriority(self.layerNum and (-(self.layerNum-1)*20-4) or (-81))
    self.container:setContentSize(G_VisibleSize)
    local function tmpHandler(...)
       -- return self:touchEvent(...)
    end
    -- self.container:registerScriptTouchHandler(tmpHandler,false,-81,false)
    self.r_container  =CCLayer:create()
    self.l_container  =CCLayer:create()
    self.r_traceLayer =CCLayer:create() 
    self.l_traceLayer =CCLayer:create() 
    self.r_tankLayer  =CCLayer:create()
    self.l_tankLayer  =CCLayer:create()
    self.r_shellLayer =CCLayer:create()
    self.l_shellLayer =CCLayer:create()
    self.r_bombLayer  =CCLayer:create()
    self.l_bombLayer  =CCLayer:create()
    self.topLayer     =CCLayer:create()

    
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

    -- self.l_grossLayer:setContentSize(CCSizeMake(2048,1026))

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
    -- sceneGame:addChild(self.container,5)
    if self.zOrder then
      sceneGame:addChild(self.container,self.zOrder)
    else
      sceneGame:addChild(self.container,5)
    end
    
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
    if self.battleType==4 then
        if platWarMapScene and platWarMapScene.setHide then
            platWarMapScene:setHide()
        end
    end
    
    self:moveMap()  --地图移动
    self:vsMoveAction() --VS 动画
    
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
        if newGuidMgr.curStep==52 or newGuidMgr.curBMStep==3 then
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
              self:showResuil()
          end
        end
        --self:stopAction()
    end

    self.endBtnItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",endFunc,nil,getlocal("skipPlay"),30)
    self.endBtnItem:setPosition(20,0)
    self.endBtnItem:setScale(0.8)
    self.endBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.endBtnItemMenu = CCMenu:createWithItem(self.endBtnItem)

    if newGuidMgr.curStep==52 or newGuidMgr.curBMStep==3 then
        self.endBtnItemMenu:setTouchPriority(-322)
    else
        local touchNum = self.layerNum and (-(self.layerNum - 1) * 20 - 4) < -203 and (-(self.layerNum - 1) * 20 - 4) or -203
        self.endBtnItemMenu:setTouchPriority(touchNum)
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

--初始化后台返回的战斗数据
function battleScene:initData(data,closeResultPanelHandler,zOrder,layerNum)
    self.firstData = data
    if closeResultPanelHandler then
        self.closeResultPanelHandler=closeResultPanelHandler
    end
    self.landform=data.landform --地形 {0,0} {攻击方,防守方}
    if self.landform==nil then
        self.landform={4,4}
    end
    for k,v in pairs(self.landform) do
        if(v==0)then
            self.landform[k]=4
        end
    end
    self.isBattleing=true
    
    if data.isInAllianceWar then
        self.bgName1="scene/battles_1.jpg"
        self.bgName2="scene/battles_1.jpg"
    else
        -- self.bgName1="scene/r1_mi.jpg"
        -- self.bgName2="scene/r2_mi.jpg"
        self.bgName1="scene/battles_"..self.landform[1]..".jpg"
        self.bgName2="scene/battles_"..self.landform[2]..".jpg"
    end
    self.layerNum = layerNum
    --retTb=data
    --
    if zOrder then
        self.zOrder=zOrder
    end
    --战斗类型，是哪个战斗场景,1:区域战 5:军事演习（新）
    self.battleType=data.battleType
    --是否是军团副本
    self.isFuben=data.isFuben
    if self.isFuben==nil then
        self.isFuben=false
    end
    --是否是战报回放
    self.isReport=data.isReport

    self.personalRebelData=data.personalRebelData --个人叛军

    if self.isReport==nil then
      self.isReport=false
    end
      self.isAttacker=data.isAttacker
    if self.isAttacker==nil then
      self.isAttacker=true
    end
    self.serverWarTeam=data.serverWarTeam
    self.serverWarType=data.serverWarType
    self.alienBattleData=data.alienBattleData
    self.landform=data.landform --地形 {0,0} {攻击方,防守方}
    -- print("self.landform",self.landform)
    -- if self.landform then
    --     for k,v in pairs(self.landform) do
    --         print("landform",k,v)
    --     end
    -- end
    self.acData=data.acData  --活动类型
    self.isWin=data.data.report.w

    -- data.data.report = G_Json.decode('{"ocean":[1,1,1],"p":[["璨渃、晨曦",120,1,5332],["连坑带坑",120,0,1218]],"r":-1,"d":{"sw":[["w6-20","w2-18","w5-20","w8-18","w7-20","w1-18"],["w7-20","w6-20","w2-18","w5-20","w3-17","w1-18"]],"stats":{"loss":[1930,1452],"dmg":[11657780155,76566218]},"ah":[["2-2"],["1-2","3-2"]],"sk":[{},{}],"an":[{"p2":"a10","p1":"a12","p4":"a14"},{"p3":"a9","p1":"a10","p5":"a11"}],"fd":{},"pn":[6,6],"bd":{},"se":["e901-e102_4-e103_3-e93_3-1353-0.116-0.499-0.229-0.014-0.12-0.006-m1","e901-e112_2-e82_3-e101-1276-0.025-0.023-0.085-0.255-0.255-0.019-m1"],"fa":{},"ad":[["6818888-1279-1-ch","6766388-0-3-ch","6818888-0-4-ch","6760138-3067-5-ch"],["78006269-0-1"]],"d":[["0","1309463385-0","1965810121-0-1","315717137-0-1","4018014852-0-1","4048774660-0-1"],["76566218-1431-B1X"],["0"],["$"],["0"]],"fj":[["p3","s1123"],["p1","s1197"]]},"t":[[["a50034",3134],["a50005",3134],["a10028",4],["a20065",4],["a50035",3134],["a20115",4]],[["a50015",1447],["a50008",1],["a10045",1],["a10135",1],["a50084",1],["a20155",1]]],"h":[["h54-80-6-1,j25,3,2,j26,2,3,j9,7,4,j12,5","h14-80-6-1,j11,4,2,j10,5,3,j20,1,4,j19,1","h15-80-6-1,j6,4,2,j11,4,3,j19,2","h32-80-6","h71-80-6-1,j11,3,2,j10,2,3,j15,3","h7-80-6-1,j14,3,2,j22,3"],["h4-80-6-1,j23,1,2,j7,2,3,j16,1","h5-80-6-1,j11,1","h23-70-5","h20-80-6-1,j11,1","h21-70-5","h22-70-5"]]}')--假数据使用，平常不用 用于坦克战斗数据表现使用

    --专门用于开发阶段，调试，测试 使用，--------------------------------------
    -- self.battleData = {}
    -- local noInitData = data.data.report.d.d and  data.data.report.d.d or data.data.report.d
    -- print("SizeOfTable(noInitData)------->",SizeOfTable(noInitData))
    -- local noInitDataIndex = 1
    -- for k,v in pairs(noInitData) do
    --     if type(v) =="string" and string.sub(v,1,3) =="#--" then
    --       -- table.remove(noInitData,k)
    --       print("noInitDataIndex------>",noInitDataIndex)
    --       noInitDataIndex = noInitDataIndex + 1
    --     else
    --       table.insert(self.battleData,v)
    --     end
    -- end
    -- print("SizeOfTable(noInitData)---222222---->",SizeOfTable(noInitData))
    --------------------------------------------------------------------------

    self.battleData = (data.data.report.d.d==nil and data.data.report.d or data.data.report.d.d)

    self.spcSkill     = data.data.report.d.ab
    self.emblemData   = data.data.report.d.se--军徽系统BUF
    self.bfSkill      = G_clone(data.data.report.d.bfs) --开战前的BUF（特效显示等等）
    self.superWeapon  = data.data.report.d.sw
    self.upgradeTanks = data.data.report.upgradeTanks or {} --生成的精锐坦克列表
    self.levelTb      = data.levelTb -- 关卡部队信息（再打一次关卡需要）
    self.challenge    = data.data.report.challenge or 0
    
    --飞艇信息 --
    -- self.airShipTb = {{5},{5}}--测试
    if data.data.report.d.as then
      self.airShipTb = {}
        self.airShipTb[1] = data.data.report.d.as[2]
        self.airShipTb[2] = data.data.report.d.as[1]
    end

    self.fjfdTb       = data.data.report.d.fd -- 飞机战斗数据
    self:formatFaData(data.data.report.d.fa or nil) -- 飞机战斗回合内增加的能量点数
    self.planeShellsNumTb = data.data.report.d.pn or {}--飞机能量点数最大值（5以上的能量值 = 飞机 + 飞机技能）
    ------专门用于开发阶段，调试，测试 使用，--------------------------------------
    -- self.fjfdTb = {}
    -- local noInitFjData = data.data.report.d.fd or {} -- 飞机战斗数据
    -- print("SizeOfTable(noInitFjData)----fj--->",SizeOfTable(noInitFjData))
    -- local noInitfjDataIndex = 1
    -- for k,v in pairs(noInitFjData) do
    --     -- print("noInitFjData------v----------->",v)
    --     if type(v) =="string" and string.sub(v,1,3) =="#--" then
    --       -- table.remove(noInitFjData,k)
    --       print("noInitfjDataIndex------>",noInitfjDataIndex)
    --       noInitfjDataIndex = noInitfjDataIndex + 1
    --     else
    --         table.insert(self.fjfdTb,v)
    --     end
    -- end
    -- print("SizeOfTable(noInitFjData)----fj-22222-->",SizeOfTable(noInitFjData))
    --------------------------------------------------------------------------

    self.fjFireIndexTotal = self.fjfdTb and #self.fjfdTb or 0
    self.fjTb =data.data.report.d.fj--(用于飞机图片使用) ,{{"p3","1313"},{"p4","1313"}}:1313  ---飞机相关数据 用于转换出技能名称
    self.skillCD = {["be"]=1,["bf"]=1,["bl"]=1,["bm"]=1}--技能动画延时的KEY和回合数[除非策划要求修改，否则该表内的数据不要动，只用作判断即可,判断后台是否传回要求取消延时效果的字段

    ------------------------------- AI 部 队 ----------------------------------
    self.aiTb =  {}--{{"a9","a5","a5","a5","a5","a5"},{"a6",}}--(ai部队图片使用) {{"2","1"},{"4","2"}} (数字0 占位)
    self.aiBufTb = {}--{ { {["ca"] = 2},{},{},{},{},{} } }--{}  --ai部队 给己方单体坦克释放buf或护盾 的 位置表
    self.aiAttHH = {}--各个攻击部队的攻击回合数
    if data.data.report.d.an then
      self.aiTb[1] = {}
      self.aiTb[2] = {}
      for i=1,6 do
          self.aiTb[1][i] = (data.data.report.d.an[2]["p"..i] and type(data.data.report.d.an[2]["p"..i]) ~= "userdata") and data.data.report.d.an[2]["p"..i] or 0
          self.aiTb[2][i] = (data.data.report.d.an[1]["p"..i] and type(data.data.report.d.an[1]["p"..i]) ~= "userdata") and data.data.report.d.an[1]["p"..i] or 0
      end
    end
    if data.data.report.d.ai then
        self.aiBufTb[1] = data.data.report.d.ai[2]
        self.aiBufTb[2] = data.data.report.d.ai[1]
    end

    self.aiSkillTb      = {} --ai部队各部队技能详情----只应用己方部队buf或护盾特效，己方ai部队出现时一次性释放buf或护盾使用
    self.aiResNeedTipTb = {} --用于给ai部队技能资源加载使用
    if self.aiTb and SizeOfTable(self.aiTb) > 0 then
        local oriTb = {}
        if data.data.report.d.ah then
            oriTb[1] = data.data.report.d.ah[2]
            oriTb[2] = data.data.report.d.ah[1]
            for k,v in pairs(self.aiTb) do
                if oriTb[k] and SizeOfTable(oriTb) > 0 then
                    self.aiAttHH[k] = {}
                    for m,n in pairs(oriTb[k]) do
                        local attTb = Split(n,"-")
                         self.aiAttHH[k][tonumber(attTb[1])] = tonumber(attTb[2])
                    end
                end
            end
        end
        self.aiTroopsCfg  = AITroopsVoApi:getModelCfg()
        local aiTroopType = self.aiTroopsCfg.aitroopType--配置表信息
        local aiSkill     = self.aiTroopsCfg.skill--配置表信息
        for k,v in pairs(self.aiTb) do
            if v then
              self.aiSkillTb[k] = {}
              for m,n in pairs(v) do
                  if n and n ~= 0 then
                    local skill2 = aiTroopType[n].skill2
                    self.aiSkillTb[k][n] = {}
                    self.aiSkillTb[k][n][1] = skill2[1]--技能id
                    self.aiSkillTb[k][n][2] = aiSkill[skill2[1]].type--技能type 1：buf 2：盾 3：ai部队攻击
                    self.aiSkillTb[k][n][3] = aiSkill[skill2[1]].range == 2 and true or false--技能的范围
                    self.aiSkillTb[k][n][4] = aiSkill[skill2[1]].ability--调用的特效id

                    if self.aiSkillTb[k][n][2] > 0 and self.aiResNeedTipTb[self.aiSkillTb[k][n][2]] == nil then--ai部队资源加载的 标识（目前就3种：1，2，3）
                        self.aiResNeedTipTb[self.aiSkillTb[k][n][2]] =true
                    end

                    if self.aiSkillTb[k][n][2] == 1 or self.aiSkillTb[k][n][2] == 2 then -- 盾 或 buf
                        local abilty = self.aiSkillTb[k][n][4]
                        if not self.aiSkillTb[k][n][3] then-- 非群体攻击,拿到被施加的坦克位置
                            if self.aiBufTb[k] then 
                               for kk,v in pairs(self.aiBufTb[k]) do
                                  if v[abilty] then
                                     self.aiSkillTb[k][n][6] = v[abilty]--放置被释放的坦克位置
                                  end
                               end
                            end
                        end

                        if self.aiSkillTb[k][n][2] == 2 then
                            self.aiSkillTb[k][n][5] = abilty == "ce" and 1 or 2 --护盾特效使用图片的类型 （2种）
                        end
                    end
                  end
              end
            end
        end
    end

    self.aiBattleData=data.data.report.d.ad or {}--{{"10000-100-1"}}

    ---------------------------------------------------------------------------
    self.playerData=data.data.report.p
    self.battleReward=data.data.report.r
    self.heroData=data.data.report.h

    self.skinTb = {}
    if data.data.report.d.sk then--皮肤数据列表 与 坦克id列表 是反着的，需要format
        self.skinTb[1] = data.data.report.d.sk[2]
        self.skinTb[2] = data.data.report.d.sk[1]
    end
    self.addResPathTb={}

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

    if self.playerData[1][4]~=nil then
      self.firstValue1=self.playerData[1][4]
    end
    if self.playerData[2][4]~=nil then
      self.firstValue2=self.playerData[2][4]
    end
    if self.playerData[1][5]~=nil then
      self.playerUid1=self.playerData[1][5]
    end
    if self.playerData[2][5]~=nil then
      self.playerUid2=self.playerData[2][5]
    end
    if data.data.report.acaward then
       self.battleAcReward=data.data.report.acaward
    end
    self.resultStar=data.data.report.star
    self.winCondition=data.data.report.wins --超级武器关卡过关条件
    self.swId=data.swId --超级武器关卡id
    if data.ecId then
      self.ecId=data.ecId
    end
    self.robData=data.robData
    if self.robData==nil then
        self.robData={}
    end
    self.robData.flopReward=data.data.flop
    self.robData.swFid=data.data.getfragment
    self.robData.report=data.data.report
    self.robData.callBackParams=data.callBackParams
    self.rebel=data.data.rebel --叛军数据
    self.shipboss=data.data.shipboss --飞艇欧米伽小队数据
    self:isPickedTankId(data.data.report.t[1],data.data.report.t[2])
    
    if self.battleType == 37 then--狂热集结功能需求
        self.resultStar = 3
    end

    self:startBattle(data.data.report.t[1],data.data.report.t[2],self.fjTb,self.aiTb,self.aiSkillTb,self.skinTb[1],self.skinTb[2])

end
function battleScene:isPickedTankId(t1,t2 )
    for i=1,6 do
        if t1[i]~=nil and #t1[i]>0 then
            if t1[i][2]>0 then
                self.isPickedTankTb[i]=t1[i][1]
            else
                self.isPickedTankTb[i]=nil
            end
        else
            self.isPickedTankTb[i]=nil
        end
        if t2[i]~=nil and  #t2[i]>0 then
            if t2[i][2]>0 then
                self.isPickedTankTb[i+6] = t2[i][1]
            else
                self.isPickedTankTb[i+6]=nil
            end
        else
            self.isPickedTankTb[i+6]=nil
        end
    end
end

function battleScene:analyzeEmblemData()--解析军徽技能，判断是否为防御真实伤害的技能(真实伤害 ： 飞机，AI 的 攻击伤害值)
    if self.emblemData then
        local useTb = {["e122"] = 1}
        local isAllFalse = true
        self.realDefBufTb = {}
        for i=1,2 do
            if self.emblemData[i] and not tonumber(self.emblemData[i]) then
                local isTroop = emblemTroopVoApi:checkIfIsEmblemTroopById(self.emblemData[i])
                if isTroop then
                  local equipArr = Split(self.emblemData[i],"-")
                  for ii=2,4 do
                      local effect = Split(equipArr[ii],"_")[1]
                      -- print("effect---->>",effect,i)
                      self.realDefBufTb[i] = useTb[effect] and true or nil
                      if self.realDefBufTb[i] then
                          isAllFalse = false
                          do break end
                      end  
                  end
                else
                    local effect = Split(self.emblemData[i],"_")[1]
                    self.realDefBufTb[i] = useTb[effect] and true or nil
                    if self.realDefBufTb[i] then
                        isAllFalse = false
                    end 
                end
            end
        end
        if isAllFalse then
            self.realDefBufTb = nil
        else
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            spriteController:addPlist("public/realDefImage.plist")
            spriteController:addTexture("public/realDefImage.png")
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        end
    end
end

function battleScene:addRes(tid,sid)--sid:坦克皮肤id
    local skinId = sid and sid.."_" or ""
    -- print("skinId===>>>>",sid,skinId)
    if tid~=10001 and tid~=50001 and tid~=99999 and tid~=99998 then
        local tid= GetTankOrderByTankId(tid)
        local path = skinId.."t"..tid.."newTank."
        local str = "ship/newTank/"..path.."plist"--s1_t10095newTank.
        local str2 = "ship/newTank/"..path.."png"

        if self.addResPathTb==nil then
            self.addResPathTb={}
        end
        local tb = {str,str2}
        table.insert(self.addResPathTb,tb)
        spriteController:addPlist(str)
        spriteController:addTexture(str2)

        if skinId ~= "" then
            local needTankId = {s11=1}--s11_t10145_battlePic --新皮肤坦克战斗内所需的效果图,这里为 非通用效果图
            local generalTypeId = {s13=2,s14=1,s15=1,s16=1}--新皮肤坦克战斗内所需的 通 用 效果图
            local thisTid = needTankId[sid] and tid or nil
            if thisTid or generalTypeId[sid] then
                local path,str,str2 = "","",""
                if thisTid then
                  path = skinId.."t"..thisTid.."_battlePic."
                  str  = "ship/newTank/"..path.."plist"
                  str2 = "ship/newTank/"..path.."png"
                else
                  local typeId = generalTypeId[sid]
                  path = "newTankSkinGnrFireType_"..typeId.."_battlePic."
                  str  = "public/tankSkin/"..path.."plist"
                  str2 = "public/tankSkin/"..path.."png"
                end 
                if self.addResPathTb==nil then
                    self.addResPathTb={}
                end
                local tb = {str,str2}
                table.insert(self.addResPathTb,tb)
                spriteController:addPlist(str)
                spriteController:addTexture(str2)
            end
        end
    end

end

function battleScene:addRes2()
    spriteController:addPlist("public/radiationImage.plist")
    spriteController:addTexture("public/radiationImage.png")
    spriteController:addPlist("public/burstEffect.plist")
    spriteController:addTexture("public/burstEffect.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/emblemSkillBg.plist")
    spriteController:addTexture("public/emblemSkillBg.png")
    spriteController:addPlist("public/inBattleUsedBtn.plist")
    spriteController:addTexture("public/inBattleUsedBtn.png")
    -- spriteController:addPlist("public/realDefImage2.plist")
    -- spriteController:addTexture("public/realDefImage2.png")
    if base.plane==1 and self.fjTb then
        spriteController:addPlist("public/plane/battleImage/battlesPlaneCommon1.plist")
        spriteController:addTexture("public/plane/battleImage/battlesPlaneCommon1.png")
        spriteController:addPlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
        spriteController:addTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
        spriteController:addPlist("public/plane/battleImage/battlePlaneSkillActionImage.plist")
        spriteController:addTexture("public/plane/battleImage/battlePlaneSkillActionImage.png")
    end
    if base.AITroopsSwitch==1 and self.aiTb and SizeOfTable(self.aiTb) > 0 then
        spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattle1ShowImage.plist")
        spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattle1ShowImage.png")
        spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattle2ShowImage.plist")
        spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattle2ShowImage.png")
        spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattle3ShowImage.plist")
        spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattle3ShowImage.png")
        spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleDynamicIcon.plist")
        spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleDynamicIcon.png")
        spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleDynamicIcon2.plist")
        spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleDynamicIcon2.png")
        
        if self.aiResNeedTipTb then
          if self.aiResNeedTipTb[3] then
              -------判断是否有 ai部队 激 光 效 果         --------------------------------------------------------
              spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleLaserImage2.plist")
              spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleLaserImage2.png")
              spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleLaserImage1.plist")
              spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleLaserImage1.png")
          end
          if self.aiResNeedTipTb[2] then
              -------判断是否有该技能 护盾（两种 需要区别判断）--------------------------------------------------------
              spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleSkillHighShieldImage.plist")
              spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleSkillHighShieldImage.png")
              spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleSkillLowShieldImage.plist")
              spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleSkillLowShieldImage.png")
          end
              -------判断是否有该技能 buf--------------------------------------------------------------------------
          if self.aiResNeedTipTb[1] then
              spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleYellowSkillImage1.plist")
              spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleYellowSkillImage1.png")
              spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleYellowSkillImage2.plist")
              spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleYellowSkillImage2.png")
              spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleBlueSkillImage1.plist")
              spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleBlueSkillImage1.png")
              spriteController:addPlist("public/aiTroopsImage/battleImage/aiBattleBlueSkillImage2.plist")
              spriteController:addTexture("public/aiTroopsImage/battleImage/aiBattleBlueSkillImage2.png")
          end
        end
    end
    if self.airShipTb and self.airShipTb[2] and next(self.airShipTb[2]) then
        local airshipId = tonumber(self.airShipTb[2][1])
        G_addingOrRemovingAirShipImage(true, airshipId)
    end

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function battleScene:removeRes()
    if self.addResPathTb and SizeOfTable(self.addResPathTb)>0 then
        for k,v in pairs(self.addResPathTb) do
            spriteController:removePlist(v[1])
            spriteController:removeTexture(v[2])
        end
    end
    -- spriteController:removePlist("public/realDefImage2.plist")
    -- spriteController:removeTexture("public/realDefImage2.png")
    spriteController:removePlist("public/radiationImage.plist")
    spriteController:removeTexture("public/radiationImage.png")
    spriteController:removePlist("public/burstEffect.plist")
    spriteController:removeTexture("public/burstEffect.png")
    spriteController:removePlist("public/emblemSkillBg.plist")
    spriteController:removeTexture("public/emblemSkillBg.png")
    spriteController:removePlist("public/inBattleUsedBtn.plist")
    spriteController:removeTexture("public/inBattleUsedBtn.png")
    if base.plane==1 and self.fjTb then
        spriteController:removePlist("public/plane/battleImage/battlesPlaneCommon1.plist")
        spriteController:removeTexture("public/plane/battleImage/battlesPlaneCommon1.png")
        spriteController:removePlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
        spriteController:removeTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
        spriteController:removePlist("public/plane/battleImage/battlePlaneSkillActionImage.plist")
        spriteController:removeTexture("public/plane/battleImage/battlePlaneSkillActionImage.png")
    end
    if base.AITroopsSwitch==1 and self.aiTb and SizeOfTable(self.aiTb) > 0 then
        spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattle1ShowImage.plist")
        spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattle1ShowImage.png")
        spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattle2ShowImage.plist")
        spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattle2ShowImage.png")
        spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattle3ShowImage.plist")
        spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattle3ShowImage.png")
        spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleDynamicIcon.plist")
        spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleDynamicIcon.png")
        spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleDynamicIcon2.plist")
        spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleDynamicIcon2.png")

        if self.aiResNeedTipTb then
          if self.aiResNeedTipTb[3] then
              -------判断是否有 ai部队 激 光 效 果         --------------------------------------------------------
              spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleLaserImage2.plist")
              spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleLaserImage2.png")
              spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleLaserImage1.plist")
              spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleLaserImage1.png")
          end
          if self.aiResNeedTipTb[2] then
              -------判断是否有该技能 护盾（两种 需要区别判断）--------------------------------------------------------
              spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleSkillHighShieldImage.plist")
              spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleSkillHighShieldImage.png")
              spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleSkillLowShieldImage.plist")
              spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleSkillLowShieldImage.png")
          end
            -------判断是否有该技能 buf--------------------------------------------------------------------------
          if self.aiResNeedTipTb[1] then
              spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleYellowSkillImage1.plist")
              spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleYellowSkillImage1.png")
              spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleYellowSkillImage2.plist")
              spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleYellowSkillImage2.png")
              spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleBlueSkillImage1.plist")
              spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleBlueSkillImage1.png")
              spriteController:removePlist("public/aiTroopsImage/battleImage/aiBattleBlueSkillImage2.plist")
              spriteController:removeTexture("public/aiTroopsImage/battleImage/aiBattleBlueSkillImage2.png")
          end
        end
    end
    if self.realDefBufTb then
      spriteController:removePlist("public/realDefImage.plist")
      spriteController:removeTexture("public/realDefImage.png")
    end
    if self.airShipTb and self.airShipTb[2] and next(self.airShipTb[2]) then
        local airshipId = tonumber(self.airShipTb[2][1])
        G_addingOrRemovingAirShipImage(false, airshipId)
    end
end

--派坦克出战 t1:右上角  t2:左下角   格式:{[1]={1,13},[3]={2,190},[4]={3,56}}  {[位置索引]={船类型编号1-20,船数量}}
function battleScene:startBattle(t1,t2,fjTb,aiTb,aiSkillTb,skinTb1,skinTb2)
    self:init()
    local layerTb1 = {4,1,5,2,6,3}
    local layerTb2 = {1,4,2,5,3,6}
    for kk=1,6 do
        local k = layerTb1[kk]
        local aiTankSp1,aiTankSp2 = nil,nil--层级问题，所以需要ai部队跟坦克一起创建
        local skinId1 = skinTb1 and skinTb1["p"..k] or nil
        if t1[k]~=nil and #t1[k]>0 then
            if t1[k][2]>0 then
                local tankSp=tank:new(t1[k][1],t1[k][2],k,1,false,nil,self,skinId1)
                self.allT1[k]=tankSp
            else
                local tankSp=tank:new("a10001",1,k,1,true,nil,self,skinId1)
                self.allT1[k]=tankSp
            end
        else
                local tankSp=tank:new("a10001",1,k,1,true,nil,self,skinId1)
                self.allT1[k]=tankSp

        end
        ------------------------- aiTank -------------------------防守方 【2】
        if aiTb and aiTb[1] and aiTb[1][k] and aiTb[1][k] ~= 0 then
              aiTankSp1 = aiTank:new(aiTb[1][k],k,1,false,self,nil,aiSkillTb[1][aiTb[1][k]])
        end
        self.allAI1[k] = aiTankSp1
        ----------------------------------------------------------
        local k = layerTb2[kk]
        local skinId2 = skinTb2 and skinTb2["p"..k] or nil
        if t2[k]~=nil and  #t2[k]>0 then
            if t2[k][2]>0 then
                local tankSp=tank:new(t2[k][1],t2[k][2],k,2,false,nil,self,skinId2)
                self.allT2[k]=tankSp
            else
                local tankSp=tank:new("a10001",1,k,2,true,nil,self,skinId2)
                self.allT2[k]=tankSp
            end
        else
                local tankSp=tank:new("a10001",1,k,2,true,nil,self,skinId2)
                self.allT2[k]=tankSp
            
        end
        ------------------------- aiTank -------------------------攻击方 【1】
        if aiTb and aiTb[2] and aiTb[2][k] and aiTb[2][k] ~= 0 then
              aiTankSp2 = aiTank:new(aiTb[2][k],k,2,false,self,nil,aiSkillTb[2][aiTb[2][k]])
        end
        self.allAI2[k] = aiTankSp2
        ----------------------------------------------------------
    end
    if base.ifSuperWeaponOpen ==1 then
        self:initSuperWeaponSp()
    end
    if base.heroSwitch==1 then
        self:initHeroSp()
    end
    self:initPickedTankSp()

    -----上面是tank 下面是plane-----
    if base.plane and base.plane == 1 and fjTb and SizeOfTable(fjTb) > 0 then
        for i=1,2 do
            local fjPoint = 3-i
            if fjTb[i] and #fjTb[i] >0 then
                local planeSp = plane:new(fjTb[i][1],i,fjPoint,fjTb[i][2],false,nil,nil,self.planeShellsNumTb[i])
                self.allPlane[fjPoint] = planeSp
            end
        end
    end
end
function battleScene:moveMap()
    local size=G_VisibleSize
    local speedNum = 8 
    local function reSetLeft()
        self.l_grossLayer:stopAllActions()
        self.l_grossLayer:setPosition(self.l_mappos[1])
        -- for i=1,2 do--变换地图使用，目前未开放
        --     local mapSp = tolua.cast(self.l_grossLayer:getChildByTag(100+i),"CCSprite")
        --     if mapSp:getZOrder() ==1 then
        --         self.r_grossLayer:reorderChild(mapSp,2)
        --     else
        --       self.l_grossLayer:reorderChild(mapSp,1)
        --     end
        -- end
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
        -- for i=1,2 do--变换地图使用，目前未开放
        --     local mapSp = tolua.cast(self.r_grossLayer:getChildByTag(100+i),"CCSprite")
        --     if mapSp:getZOrder() ==1 then
        --         self.r_grossLayer:reorderChild(mapSp,2)
        --     else
        --       self.r_grossLayer:reorderChild(mapSp,1)
        --     end
        -- end        
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
    --
end

function battleScene:vsMoveAction()

    --VS动画
    local size=G_VisibleSize
    self.VSp=CCSprite:createWithSpriteFrameName("v.png")
    self.SSp=CCSprite:createWithSpriteFrameName("s.png")
    self.VSp:setAnchorPoint(ccp(0.5,0.5))
    self.SSp:setAnchorPoint(ccp(0.5,0.5))
    self.VSp:setPosition(ccp(-self.VSp:getContentSize().width*0.5,-size.height*0.4))
    self.SSp:setPosition(ccp(size.width+self.VSp:getContentSize().width*0.5,-size.height*0.4))
    local VaimPos=ccp(size.width*0.5-self.VSp:getContentSize().width*0.5+15,-size.height*0.4)
    local SaimPos=ccp(size.width*0.5+self.SSp:getContentSize().width*0.5-15,-size.height*0.4)
    local function reSetV()
        self.VSp:stopAllActions()
        local delay=CCDelayTime:create(0.5 * G_battleSpeed)
        local scaleTo=CCScaleTo:create(0.3 * G_battleSpeed,0.5)
        local mvTo=CCMoveTo:create(0.3 * G_battleSpeed,ccp(size.width*0.5-25,self.upSlideSP:getContentSize().height-40))
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
           animation:setDelayPerUnit(0.05 * G_battleSpeed)
           local animate=CCAnimate:create(animation)
           vsPzSp:setAnchorPoint(ccp(0.5,0.5))
           vsPzSp:setPosition(ccp(size.width*0.5,-size.height*0.4))
           self.upSlideSP:addChild(vsPzSp,20)
           vsPzSp:setScale(5)
           local function removePzSp()
                vsPzSp:removeFromParentAndCleanup(true)
           end
           local  animEnd=CCCallFuncN:create(removePzSp)
           local  pzSeq=CCSequence:createWithTwoActions(animate,animEnd)
           vsPzSp:runAction(pzSeq)
    end
    local  VFunc=CCCallFuncN:create(reSetV);
    local VMoveTo=CCMoveTo:create(0.3 * G_battleSpeed,VaimPos)
    local Vseq = CCSequence:createWithTwoActions(VMoveTo,VFunc)
    self.VSp:runAction(Vseq)
    
    local function reSetS()
        self.SSp:stopAllActions()
        local delay=CCDelayTime:create(0.5 * G_battleSpeed)
        local scaleTo=CCScaleTo:create(0.3 * G_battleSpeed,0.5)
        local mvTo=CCMoveTo:create(0.3 * G_battleSpeed,ccp(size.width*0.5+25,self.upSlideSP:getContentSize().height-40))
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
    local SMoveTo=CCMoveTo:create(0.3 * G_battleSpeed,SaimPos)
    local Sseq = CCSequence:createWithTwoActions(SMoveTo,SFunc)
    self.SSp:runAction(Sseq)
    self.upSlideSP:addChild(self.VSp)
    self.upSlideSP:addChild(self.SSp)
    PlayEffect(audioCfg.battle_VS)
end

function battleScene:vsActiononTop()
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
           animation:setDelayPerUnit(0.05 * G_battleSpeed)
           local animate=CCAnimate:create(animation)
           vsPzSp:setAnchorPoint(ccp(0.5,0.5))
           vsPzSp:setPosition(ccp(size.width/2,self.upSlideSP:getContentSize().height-45))
           self.upSlideSP:addChild(vsPzSp,20)
           vsPzSp:setScale(3)
           local function removePzSp()
                vsPzSp:removeFromParentAndCleanup(true)
                if base.emblemSwitch == 1 and self.emblemData and SizeOfTable(self.emblemData) == 2 and (self.emblemData[1] ~= 0 or self.emblemData[2] ~= 0) then
                    self:showEmblemAc()
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
           self.slideMovEnd = true
end

function battleScene:showHH() --显示回合
    local size=G_VisibleSize
    self.hhSp=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
    self.hhSp:setOpacity(150)
    self.hhSp:setAnchorPoint(ccp(0.5,0.5))
    self.hhSp:setPosition(ccp(size.width*0.5,self.upSlideSP:getContentSize().height-91))
    self.upSlideSP:addChild(self.hhSp)
    --self.playerData=
    self.hhLb=GetTTFLabel(getlocal("battle_Count",{self.hhNum}),22)
    self.hhLb:setAnchorPoint(ccp(0.5,0.5))
    self.hhLb:setPosition(ccp(self.hhSp:getContentSize().width/2,self.hhSp:getContentSize().height/2))
    self.hhSp:addChild(self.hhLb,1)


           local pzFrameName="VSacross1.png" --回合动画
           local vsPzSp=CCSprite:createWithSpriteFrameName(pzFrameName)
           vsPzSp:setScale(3)
           local pzArr=CCArray:create()
            for kk=1,6 do
                local nameStr="VSacross"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
           end
           local animation=CCAnimation:createWithSpriteFrames(pzArr)
           animation:setDelayPerUnit(0.05 * G_battleSpeed)
           local animate=CCAnimate:create(animation)
           vsPzSp:setPosition(ccp(self.hhSp:getContentSize().width*0.65,self.hhSp:getContentSize().height*0.5))
           self.hhSp:addChild(vsPzSp,3)
           
           local function removePzSp()
                vsPzSp:removeFromParentAndCleanup(true)
           end
           local  animEnd=CCCallFuncN:create(removePzSp)
           local  pzSeq=CCSequence:createWithTwoActions(animate,animEnd)
           vsPzSp:runAction(pzSeq) 
end

--播放装备动画
function battleScene:showEmblemAc()
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
          if tonumber(self.playerData[1][1]) == 9 then
              if self.shipboss and self.shipboss.bType then
                rightPName = getlocal("airShip_bossNameType" .. self.shipboss.bType)
              end
          else
         rightPName=self.playerData[1][1]
         if tonumber(rightPName)~=nil then
            rightPName=arenaVoApi:getNpcNameById(tonumber(rightPName))
         end
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
              elseif tonumber(self.playerData[1][1]) == 9 then
                  if self.shipboss and self.shipboss.bType then
                    rightPName = getlocal("airShip_bossNameType" .. self.shipboss.bType)
                  end
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
      self:analyzeEmblemData()--解析军徽属性 ：用于 加载相应的动态图片，后面需要判断是为要使用的效果（抵抗真实伤害的动画效果）
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
        acArr:addObject(CCDelayTime:create(mt/self.warSpeed * G_battleSpeed))
        if skidx==1 then
          acArr:addObject(CCDelayTime:create(0.2/self.warSpeed * G_battleSpeed))
        end
        if skidx>1 then
          sknameLb:setOpacity(0)
          acArr:addObject(CCDelayTime:create((skidx-1)*0.4/self.warSpeed * G_battleSpeed))
          acArr:addObject(CCFadeIn:create(0.1/self.warSpeed * G_battleSpeed))
          acArr:addObject(CCDelayTime:create(0.1/self.warSpeed * G_battleSpeed))
        end
        if skidx<skcount then
          local ft=0.2/self.warSpeed * G_battleSpeed
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
          CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
          CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
          local leftPanel = CCSprite:create("public/emblem/emblemBattleBg1.png")
          CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
          CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
          leftPanel:setScaleY(1.2)
          leftPanel:ignoreAnchorPointForPosition(false)
          leftPanel:setAnchorPoint(ccp(1,0.5))
          leftPanel:setPosition(ccp(0,G_VisibleSizeHeight * 0.33))
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
          leftPlayerLb:setPosition(ccp(20,leftLayerSize.height - 10))
          leftLayer:addChild(leftPlayerLb)

          local leftEquipIcon = emblemVoApi:getEquipIconNoBg(leftEquipId,22,nil,nil,-10)
          leftEquipIcon:setAnchorPoint(ccp(0,0))
          leftEquipIcon:setPosition(ccp(37,55))
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
                    acArr:addObject(CCDelayTime:create(mt/self.warSpeed * G_battleSpeed))
                    acArr:addObject(CCDelayTime:create((tonumber(v)-1)*0.4/self.warSpeed * G_battleSpeed))
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
            local moveto = CCMoveTo:create(mt/self.warSpeed * G_battleSpeed, CCPointMake(leftLayerSize.width >  G_VisibleSizeWidth and G_VisibleSizeWidth or leftLayerSize.width,G_VisibleSizeHeight * 0.33))
            local delay = CCDelayTime:create(dt/self.warSpeed * G_battleSpeed)
            local moveBack = CCMoveTo:create(mt/self.warSpeed * G_battleSpeed, CCPointMake(0, G_VisibleSizeHeight* 0.33))
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
          CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
          CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
          local rightPanel = CCSprite:create("public/emblem/emblemBattleBg2.png")--LuaCCScale9Sprite:createWithSpriteFrameName("GuidePanel.png",capInSet,cellClick)--对话背景
          CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
          CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
          rightPanel:setScaleY(1.2)
          rightPanel:ignoreAnchorPointForPosition(false)
          rightPanel:setAnchorPoint(ccp(0,0.5))
          rightPanel:setPosition(ccp(G_VisibleSizeWidth,G_VisibleSizeHeight * 0.67))
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

          local rightEquipIcon = emblemVoApi:getEquipIconNoBg(rightEquipId,22,nil,nil,-10)
          rightEquipIcon:setAnchorPoint(ccp(1,0))
          rightEquipIcon:setPosition(ccp(rightLayerSize.width - 37,55))
          rightLayer:addChild(rightEquipIcon)
          local attUp,skillTb,showPosTb
          if emblemTroopVoApi:checkIfIsEmblemTroopById(rightEquipId)==true then
            attUp=emblemTroopVoApi:getTroopAllAttUpByJointId(rightEquipId)
            rightEquipIcon:setPosition(rightLayerSize.width-45,35)
            skillTb,showPosTb=emblemTroopVoApi:getTroopSkillsByJointIdForBattle(rightEquipId)
          else
            attUp=rightEquipCfg.attUp
            if rightEquipCfg.skill then
              skillTb={rightEquipCfg.skill}
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
                    acArr:addObject(CCDelayTime:create(mt/self.warSpeed * G_battleSpeed))
                    acArr:addObject(CCDelayTime:create((tonumber(v)-1)*0.4/self.warSpeed * G_battleSpeed))
                    acArr:addObject(CCBlink:create(0.2/self.warSpeed * G_battleSpeed,2))
                    local seq=CCSequence:create(acArr)
                    starSp:runAction(seq)
                  end
                end
              end
            end
          end
          
          local rightPanelTb={rightPanel,rightLayer}
          for k,v in pairs(rightPanelTb) do
            local rMoveto = CCMoveTo:create(mt/self.warSpeed * G_battleSpeed, CCPointMake(rightLayerSize.width >= G_VisibleSizeWidth and 0 or G_VisibleSizeWidth - rightLayerSize.width, G_VisibleSizeHeight* 0.67))
            local rDelay = CCDelayTime:create(dt/self.warSpeed * G_battleSpeed)
            local rMoveBack = CCMoveTo:create(mt/self.warSpeed * G_battleSpeed, CCPointMake(G_VisibleSizeWidth, G_VisibleSizeHeight* 0.67))
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
function battleScene:showFightUpAc()
    self.emblemAcTb = {}
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
          table.insert(self.emblemAcTb,fightAddSp)

          local fightAddLb = GetTTFLabel(getlocal("emblem_fightAdd"),20)
          fightAddLb:setColor(G_ColorGreen)
          fightAddLb:setAnchorPoint(ccp(0,1))
          fightAddLb:setPosition(ccp(spX,spY-fightAddLb:getContentSize().height))
          v.sprite:addChild(fightAddLb)
          fightAddLb:setOpacity(0)
          table.insert(self.emblemAcTb,fightAddLb)

          local fadeIn=CCFadeIn:create(0.5/self.warSpeed * G_battleSpeed)
          local moveTo1=CCMoveTo:create(0.5/self.warSpeed * G_battleSpeed,ccp(spX,spY+fightAddSp:getContentSize().height/2))
          local fadeInArr=CCArray:create()
          fadeInArr:addObject(fadeIn)
          fadeInArr:addObject(moveTo1)
          local fadeInSpawn=CCSpawn:create(fadeInArr)
          local fadeOut=CCFadeOut:create(0.5/self.warSpeed * G_battleSpeed)
          local moveTo2=CCMoveTo:create(0.5/self.warSpeed * G_battleSpeed,ccp(spX,spY+fightAddSp:getContentSize().height))
          local fadeOutArr=CCArray:create()
          fadeOutArr:addObject(fadeOut)
          fadeOutArr:addObject(moveTo2)
          local fadeOutSpawn=CCSpawn:create(fadeOutArr)
          local delay=CCDelayTime:create(0.8/self.warSpeed * G_battleSpeed)
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
          animation:setDelayPerUnit(0.12/self.warSpeed * G_battleSpeed)
          local animate=CCAnimate:create(animation)
          fightAddSp:runAction(animate)
          table.insert(self.emblemAcTb,fightAddSp)

          local fightAddLb = GetTTFLabel(getlocal("emblem_fightAdd"),20)
          fightAddLb:setColor(G_ColorGreen)
          fightAddLb:setAnchorPoint(ccp(0,1))
          fightAddLb:setPosition(ccp(spX,spY-fightAddLb:getContentSize().height))
          v.sprite:addChild(fightAddLb)
          fightAddLb:setOpacity(0)
          table.insert(self.emblemAcTb,fightAddLb)

          local fadeIn=CCFadeIn:create(0.5/self.warSpeed * G_battleSpeed)
          local moveTo1=CCMoveTo:create(0.5/self.warSpeed * G_battleSpeed,ccp(spX,spY+fightAddSp:getContentSize().height/2))
          local fadeInArr=CCArray:create()
          fadeInArr:addObject(fadeIn)
          fadeInArr:addObject(moveTo1)
          local fadeInSpawn=CCSpawn:create(fadeInArr)
          local fadeOut=CCFadeOut:create(0.5/self.warSpeed * G_battleSpeed)
          local moveTo2=CCMoveTo:create(0.5/self.warSpeed * G_battleSpeed,ccp(spX,spY+fightAddSp:getContentSize().height))
          local fadeOutArr=CCArray:create()
          fadeOutArr:addObject(fadeOut)
          fadeOutArr:addObject(moveTo2)
          local fadeOutSpawn=CCSpawn:create(fadeOutArr)
          local delay=CCDelayTime:create(0.8/self.warSpeed * G_battleSpeed)
          local acArr=CCArray:create()
          acArr:addObject(fadeInSpawn)
          acArr:addObject(fadeOutSpawn)
          local seq=CCSequence:create(acArr)
          fightAddLb:runAction(seq)
        end
      end
    end
    
    local delay = CCDelayTime:create(1.1 * G_battleSpeed)
    local function startFire()
      if self.emblemAcTb then
        for k,v in pairs(self.emblemAcTb) do
          if v then
             v:stopAllActions()
             v:removeFromParentAndCleanup(true)
             v = nil
          end
        end
        self.emblemAcTb = nil
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

function battleScene:airShipRandomStayMov(rNum, pNum,thisShipNum)
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
function battleScene:runAirShipStaying( )
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
                local nameBg = CCSprite:createWithSpriteFrameName("arpl_shipNameBg.png")
                airShipName:setVisible(false)
                nameBg:setOpacity(0)
                -- nameBg:setScaleX( ( airShipName:getContentSize().width + 20) / nameBg:getContentSize().width)
                -- nameBg:setScaleY( ( fontSize + 1 ) / nameBg:getContentSize().height )

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
                      namePosy = 360 + 15
                    end
                else
                    if v[1] == 6 then
                        posx = G_VisibleSizeWidth + 65
                        addPosy = 10
                    elseif v[1] == 7 then
                        posx = G_VisibleSizeWidth + 15
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
                      namePosy = 185 - 70
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
function battleScene:runStayShipToEnd( )

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
function battleScene:showAirShip(isEndBattle)
    
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

function battleScene:readyToEnd(  )
    local function battleResult()
        if self.isBattleEnd==false then
            self.isBattleEnd=true
            if self.fireTimer~=nil then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
            end
            if self.airShipTb and next(self.airShipTb) then
                self:showAirShip(true)
            else
              self:showResuil()
            end
            if newGuidMgr:isNewGuiding()==true then
                newGuidMgr:toNextStep()
            end
        end
        --self:stopAction()
    end
    
    local delayTime=CCDelayTime:create(3 * G_battleSpeed) --延时两秒再弹出结束面板
    local  delayfunc=CCCallFuncN:create(battleResult)
    local  seq=CCSequence:createWithTwoActions(delayTime,delayfunc)
    self.container:runAction(seq)
end

function battleScene:fjFireTick( )
    local firePlane=nil  --当前开火的飞机
    if self.fjFireIndex >= self.fjFireIndexTotal and self.fireIndex >= self.fireIndexTotal then
        -- print("end in fjFireTick~~~~~~~")
        self:readyToEnd()
    end
    if self.fjNextFire < 2 and self.fjFireIndex < self.fjFireIndexTotal then--self.fjNextFire:当前这一轮坦克攻击完后 飞机的攻击次数（默认一轮 是对攻各一次 普攻+技能攻击）
        self.fjNextFire = self.fjNextFire + 1
        self.fjFireIndex = self.fjFireIndex + 1
        local beAttackedTank = nil--普攻被攻击坦克（默认从序列最小开始）
        local whiNum = 1 --左右那一方坦克挨揍，默认为右侧
        local skilledAttTanks,selfTanks = {},{}
        
        -- print("self.fjNextFire----->",self.fjNextFire)
        if self.playerData[2][3] == 1 then--左侧先开火
            if self.allPlane[3-self.fjNextFire] then--and self.allPlane[self.fjNextFire].isSpace == false then

                firePlane = self.allPlane[3-self.fjNextFire]--确定左右哪一方飞机出场
                if self.fjNextFire == 1 then
                    for k,v in pairs(self.allT1) do
                         if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                              beAttackedTank = self.allT1[k]--确定当前被普攻的坦克
                              skilledAttTanks = self.allT1
                              selfTanks = self.allT2
                              do break end
                         end
                    end
                elseif self.fjNextFire == 2 then
                    whiNum = 2
                    for k,v in pairs(self.allT2) do
                         if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                              beAttackedTank = self.allT2[k]--确定当前被普攻的坦克
                              skilledAttTanks = self.allT2
                              selfTanks = self.allT1
                              do break end
                         end
                    end
                end
            else
                self.fjFireIndex = self.fjFireIndex - 1--判断当前如果没有飞机开火，回退到上一次飞机开火数据序列
            end
        else--右侧先开火 
            if self.allPlane[self.fjNextFire] then
                
                firePlane = self.allPlane[self.fjNextFire]
                if self.fjNextFire == 2 then
                    for k,v in pairs(self.allT1) do
                         if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                              beAttackedTank = self.allT1[k]
                              skilledAttTanks = self.allT1
                              selfTanks = self.allT2
                              do break end
                         end
                    end
                elseif self.fjNextFire == 1 then
                    whiNum = 2
                    for k,v in pairs(self.allT2) do
                         if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                              beAttackedTank = self.allT2[k]
                              skilledAttTanks = self.allT2
                              selfTanks = self.allT1
                              do break end
                         end
                    end
                end
            else
                self.fjFireIndex = self.fjFireIndex - 1
            end
        end

        local btdata=self.fjFireIndex > 0 and self.fjfdTb[self.fjFireIndex] or nil --此次开火的数据(普攻)
        local skdata = {}--技能开火的数据（全体攻击)
        local len=btdata and SizeOfTable(btdata) or 0--普攻开火次数
        
        local randIndx = math.random(3,5)
        if btdata == nil or len == 0 or beAttackedTank == nil then
            self:fireTick()
          do return end
        end
        local willData= (self.fjfdTb[self.fjFireIndex+1] and type(self.fjfdTb[self.fjFireIndex+1]) ~= "table") and Split(self.fjfdTb[self.fjFireIndex+1],"-") or {}
        local curSkill = (firePlane and firePlane.sId) and planeCfg.skillCfg[firePlane.sId].planeAnim or nil
        if willData[1] =="@" then
            firePlane:runSkillAction()
            self.fjFireIndex = self.fjFireIndex+2
            skdata = self.fjfdTb[self.fjFireIndex]
        elseif curSkill and self.hhNum >= planeCfg.skillCfg[firePlane.sId].CD then
            local isSkill = false
            if firePlane.skillCD < planeCfg.skillCfg[firePlane.sId].skillCD then
                isSkill = firePlane.skillCD == 0 and true
                firePlane.skillCD = firePlane.skillCD + 1
            else
                firePlane.skillCD = 0
            end
            if isSkill then
                local isShowSkill = false
                local useKey = {bd=1,bh=1,bg=1,bj=1,bi=1}
                if useKey[curSkill] then
                    willData[2] = string.upper(curSkill)
                    isShowSkill = true
                elseif curSkill =="bb" then
                    willData[4] = string.upper(curSkill)
                    isShowSkill = true
                end
                if isShowSkill then
                    firePlane:runSkillAction()
                    self.fjFireIndex = self.fjFireIndex+1
                    skdata = self.fjfdTb[self.fjFireIndex]
                end
            end
        end
        
        firePlane:beginAttAction()--飞机飞过动画
        beAttackedTank:showPlaneAttEff(randIndx,whiNum)--普通攻击动画
        -- print("here after普通攻击动画~~~~~~~~~ ")
        
        local skLen           = skdata and  SizeOfTable(skdata) or nil
        local curBeAttackNums = (skLen == nil or skLen == 0) and len or nil
        local isOnlyOne       = (skLen == nil or skLen == 0) and true or false
        self:defPlaneRealAtt(isOnlyOne,beAttackedTank)

        for mm=1,len do--开始攻击（普通攻击动画）
            local attackerData,beAttackerData,retData=self:checkAnimEffectByData(btdata[mm],nil,true)--普通：没有用到attackerData，beAttackerData 这两个数据
            curBeAttackNums = (curBeAttackNums and curBeAttackNums >0) and curBeAttackNums-1 or curBeAttackNums
            local notYet = (skLen and skLen >0) and true or nil
            beAttackerData = mm == 1 and beAttackerData or nil
            beAttackerData = self:beRealAttackSkillShow(beAttackedTank,beAttackerData,0.7)
            beAttackedTank:beAttacked(0.7+mm*0.15,1,23,retData==nil and btdata[mm] or retData,nil,beAttackerData,nil,nil,nil,nil,false,0,curBeAttackNums,nil,notYet)
        end
        
        if skLen and skLen > 0 then--技能攻击动画
              curBeAttackNums = skLen
              local curDelayT = 2.1--目前技能动画（不是技能攻击动画）统一延时时间
              firePlane:runSkillAnimation(whiNum == 2 and self.l_tankLayer or self.r_tankLayer,20,1.5,whiNum)--20:层级
              local skIndex = 1
              for i=1,SizeOfTable(skilledAttTanks) do
                  if skilledAttTanks[i] and skilledAttTanks[i].isSpace== false and skilledAttTanks[i].isWillDie == false then

                      local attackerData,beAttackerData,retData=self:checkAnimEffectByData(skdata[skIndex],nil,true)--普通：没有用到attackerData，beAttackerData 这两个数据
                      curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                      beAttackerData = self:beRealAttackSkillShow(skilledAttTanks[i],beAttackerData,1.5)
                      skilledAttTanks[i]:beAttacked(1.8,1,23,skdata[skIndex],nil,beAttackerData,nil,nil,nil,nil,false,0,curBeAttackNums)  
                      skIndex = skIndex < skLen and skIndex+1
                  end
              end
              local selfTb = {BD=1,BG=1,BH=1,BI=1,BJ=1}--针对自己的群体技能
              local skillSelf,idSelf,skillYou,idYou = willData[2],tonumber(willData[3]),willData[4],tonumber(willData[5])
              -- print("skillSelf---------skillYou------->",skillSelf,skillYou)
              if skillSelf and tonumber(skillSelf) == nil then
                  if skillSelf =="BC" and idSelf and selfTanks[idSelf] and selfTanks[idSelf].isSpace == false and selfTanks[idSelf].isWillDie == false  then
                      selfTanks[tonumber(idSelf)]:animationCtrlByType(skillSelf,nil,true,curDelayT)
                  --elseif skillSelf =="BD" or skillSelf =="BG" or skillSelf =="BH" or skillSelf =="BI" or skillSelf =="BJ" then
                  elseif selfTb[skillSelf] then
                      for k,v in pairs(selfTanks) do
                          if selfTanks[k] and selfTanks[k].isSpace == false  and selfTanks[k].isWillDie == false then
                              selfTanks[k]:animationCtrlByType(skillSelf,nil,true,curDelayT)
                          end
                      end
                  end
              end 

              if skillYou and tonumber(skillYou) == nil then
                  local upperSkill = string.upper(skillYou)--如果有小写的字符（去掉效果的字段），需转换成 大写，用于判断使用，仅用于判断使用
                  local singleYouTb = {BA=1,BE=1,BF=1,BL=1,BM=1}--针对敌方的单体技能  (upperSkill =="BA" or  upperSkill =="BE" or upperSkill =="BF")
                  if singleYouTb[upperSkill] and idYou then 
                      if idYou < 10 and skilledAttTanks[idYou] and skilledAttTanks[idYou].isSpace == false and skilledAttTanks[idYou].isWillDie == false then
                          if skilledAttTanks[idYou].beSkillCD[string.lower(skillYou)] then
                              skilledAttTanks[idYou].beSkillCD[string.lower(skillYou)] = nil
                          end
                          if self.hhNum%2~=0 and tankCfg[skilledAttTanks[idYou].tankId].weaponType=="18" then--只适用红箭系列
                              local useInRedTankTb = {be=1,bf=1,bl=1,bm=1}
                              if useInRedTankTb[string.lower(skillYou)] then
                                skilledAttTanks[idYou].redCD[string.lower(skillYou)] = 1
                              end
                          end

                          skilledAttTanks[idYou]:animationCtrlByType(skillYou,nil,true,curDelayT)
                      else
                          local youIdTb = {math.floor(idYou/10),idYou%10}
                          for k,v in pairs(youIdTb) do
                              if v > 0 and skilledAttTanks[v] and skilledAttTanks[v].isSpace == false and skilledAttTanks[v].isWillDie == false then
                                if skilledAttTanks[v].beSkillCD[string.lower(skillYou)] then
                                    skilledAttTanks[v].beSkillCD[string.lower(skillYou)] = nil
                                end
                                if self.hhNum%2~=0 and tankCfg[skilledAttTanks[v].tankId].weaponType=="18" then--只适用红箭系列
                                    local useInRedTankTb = {be=1,bf=1,bl=1,bm=1}
                                    if useInRedTankTb[string.lower(skillYou)] then
                                        skilledAttTanks[v].redCD[string.lower(skillYou)] = 1
                                    end
                                end
                                skilledAttTanks[v]:animationCtrlByType(skillYou,nil,true,curDelayT)
                              end
                          end
                      end
                  elseif skillYou =="BB" then
                      for k,v in pairs(skilledAttTanks) do
                          if skilledAttTanks[k] and skilledAttTanks[k].isSpace == false  and skilledAttTanks[k].isWillDie == false then
                              -- print("skilledAttTanks[k]tid--------->",skilledAttTanks[k].tid)
                              skilledAttTanks[k]:animationCtrlByType(skillYou,nil,true,curDelayT)
                          end
                      end
                  end
              end 

        end
        if self.fjNextFire == 2 or (self.fjNextFire == 1 and ( SizeOfTable(self.fjTb[1]) == 0 or SizeOfTable(self.fjTb[2]) == 0 )) then
            self:cleanCurHHSkill()            
        end
    else
        self.fjIsFire = false
        self.fjNextFire = 0

        -- print("in fjFireTick~~~cur round end~~~~")
        self.nextFire=0  --重新开始一轮交火
        self.hhNum=self.hhNum + 1
        self:fireTick()  --立即开始一轮交火
        -- print("self.hhNum----------->",self.hhNum)
        self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
        for k,v in pairs(self.allPlane) do
            local subNum,addNum = nil,nil -- 改变的能量点数(减去的点数，增加的点数)
            if self.fjfaTb and self.fjfaTb[self.hhNum] and self.fjfaTb[self.hhNum][3-k] then
                local faTb = self.fjfaTb[self.hhNum][3-k]
                subNum,addNum = tonumber(faTb[3]),tonumber(faTb[4])
            end
            self.fjCurEnergyTb[k] = 1 + self.fjCurEnergyTb[k]
            self.fjCurEnergyTb[k] = self.allPlane[k]:refNewShells(self.fjCurEnergyTb[k],subNum,addNum)
        end
        
    end
    -- print("in plane battle~~~~~",self.fjNextFire)
end

function battleScene:defPlaneRealAtt(onlyOne,tank)-- 抵抗 飞机群体的真实伤害动画
  --------------------被飞机攻击所受的真实伤害的抵抗效果调用--------------------
  if self.realDefBufTb then
    if onlyOne then
        if tank and tank.isSpace == false then
          if self.realDefBufTb[tank.area] then
            tank:animationCtrlByType("CG")
          end
        end
    else
          if self.playerData[2][3] == 1 then--左侧先开火
              if self.allPlane[3-self.fjNextFire] then
                  if self.fjNextFire == 1 then
                      if self.realDefBufTb[1] then
                        for k,v in pairs(self.allT1) do
                             if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                                  self.allT1[k]:animationCtrlByType("CG")
                             end
                        end
                      end
                  elseif self.fjNextFire == 2 then
                      if self.realDefBufTb[2] then
                        for k,v in pairs(self.allT2) do
                             if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                                  self.allT2[k]:animationCtrlByType("CG")
                             end
                        end
                      end
                  end
              end
          else
              if self.allPlane[self.fjNextFire] then
                  if self.fjNextFire == 2 then
                      if self.realDefBufTb[1] then
                        for k,v in pairs(self.allT1) do
                           if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                                self.allT1[k]:animationCtrlByType("CG")
                           end
                        end
                      end
                  elseif self.fjNextFire == 1 then
                      if self.realDefBufTb[2] then
                        for k,v in pairs(self.allT2) do
                           if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                                self.allT2[k]:animationCtrlByType("CG")
                           end
                        end
                      end
                  end
              end
          end
    end
  end
      ------------------------------------------------------------------------------
end

function battleScene:cleanCurHHSkill(  )--清除本回合后台返回的告知的消除技能特效
      local function callback( )
          for k,v in pairs(self.allT1) do
              if self.allT1[k] and self.allT1[k].isSpace == false then
                  for m,n in pairs(self.allT1[k].beSkillCD) do
                      if  self.allT1[k].beSkillCD[m] then
                          self.allT1[k].beSkillCD[m] = nil
                          self.allT1[k]:animationCtrlByType(m,nil)
                      end
                  end
              end
          end
          for k,v in pairs(self.allT2) do
              if self.allT2[k] and self.allT2[k].isSpace == false then
                  for m,n in pairs(self.allT2[k].beSkillCD) do
                      if  self.allT2[k].beSkillCD[m] then
                          self.allT2[k].beSkillCD[m] = nil
                          self.allT2[k]:animationCtrlByType(m,nil)
                      end
                  end
              end
          end
      end

      local det = CCDelayTime:create(2 * G_battleSpeed)
      local callFunc = CCCallFuncN:create(callback)
      local acArr=CCArray:create()
      acArr:addObject(det)
      acArr:addObject(callFunc)
      local seq=CCSequence:create(acArr)
      self.container:runAction(seq) 
end

function battleScene:fireTick(kzhzParm)

    --==========以下是空中轰炸==========
    local kzhz,fuSheBo,cityGun=nil,nil,nil
    if kzhzParm~=nil and kzhzParm==true then
        kzhz=true
    end
    local cdData=self.battleData[self.fireIndex]

    if cdData~=nil then
         if cdData[1]=="@" then --空中轰炸
            kzhz=true
            self.fireIndex=self.fireIndex+1
         elseif cdData[1]=="@1" then--辐射菠
            fuSheBo =true
            kzhz =true
            self.fireIndex=self.fireIndex+1
         elseif cdData[1]=="@2" then--城防炮
            cityGun =true
            kzhz =true
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

         self.lAIFireIndex = 1
         self.rAIFireIndex = 1
    end

    --------------以下是开战前添加或删除的BUF（特效显示，等等）---------------------
    if self.bfSkill ~=nil and  SizeOfTable(self.bfSkill)>0 then
        if self.hhNum==1 then
          self:takeSpecialShow(1)
        elseif self.hhNum ==2 then
          self:takeSpecialShow(2)
        end
    end
    --------------以上是开战前添加或删除的BUF（特效显示，等等）---------------------
    local fireTank   = nil  --当前开火的坦克 
    local aiFireTank = nil  --当前开火的AI坦克
    if kzhz==nil then
            if self.nextFire==1 then
                   for k=self.lFireIndex,6 do
                       if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                            fireTank=self.allT1[k]
                            self.lFireIndex=k+1
                            self.lAIFireIndex = k+1
                            do break end
                       elseif self.allAI1[k] and self.allAI1[k].isCanAtt and self.aiBattleData[self.aiFireIndex] then
                            aiFireTank = self.allAI1[k]
                            self.lAIFireIndex = k+1
                            self.lFireIndex=k+1
                            do break end
                       end
                   end
                   self.nextFire=2
                   if fireTank==nil and aiFireTank == nil then --左方 本轮没有要开火的坦克了 同时 没有要开火的AI部队 
                           self.lFireIndex   = 7 
                           self.lAIFireIndex = 7
                           for k=self.rFireIndex,6 do  --右方开火
                               if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                                    fireTank=self.allT2[k]
                                    self.rFireIndex=k+1
                                    self.rAIFireIndex = k+1
                                    do break end
                               elseif self.allAI2[k] and self.allAI2[k].isCanAtt and self.aiBattleData[self.aiFireIndex] then
                                    aiFireTank = self.allAI2[k]
                                    self.rAIFireIndex = k+1
                                    self.rFireIndex=k+1
                                    do break end
                               end
                           end
                           if fireTank==nil and aiFireTank == nil then  --双方 本轮都没有要开火的坦克了 同时 没有要开火的AI部队 
                               if  self:isBattleFinished() then
                                    battleEnd=true  --结束战斗
                               else
                                    if self.fjTb then
                                      self.fjIsFire =true
                                      self:fjFireTick()
                                    else
                                      self.nextFire=0  --重新开始一轮交火
                                      self.hhNum=self.hhNum + 1
                                      self:fireTick()  --立即开始一轮交火
                                      self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
                                    end
                                    do return end
                               end
                           end
                           self.nextFire=1 
                   end
            elseif self.nextFire==2 then
                   for k=self.rFireIndex,6 do
                       if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                            fireTank=self.allT2[k]
                            self.rFireIndex=k+1
                            self.rAIFireIndex = k+1
                            do break end
                       elseif self.allAI2[k] and self.allAI2[k].isCanAtt and self.aiBattleData[self.aiFireIndex] then
                            aiFireTank = self.allAI2[k]
                            self.rFireIndex=k+1
                            self.rAIFireIndex = k+1
                            do break end
                       end
                   end 

                   self.nextFire=1
                    if fireTank==nil and aiFireTank == nil then --右方 本轮没有要开火的坦克了 同时 没有要开火的AI部队 
                           self.rFireIndex   = 7
                           self.rAIFireIndex = 7
                           for k=self.lFireIndex,6 do  --左方开火
                               if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                                    fireTank=self.allT1[k]
                                    self.lFireIndex=k+1
                                    self.lAIFireIndex = k+1
                                    do break end
                               elseif self.allAI1[k] and self.allAI1[k].isCanAtt and self.aiBattleData[self.aiFireIndex] then
                                    aiFireTank = self.allAI1[k]
                                    self.lFireIndex=k+1
                                    self.lAIFireIndex = k+1
                                    do break end
                               end
                           end
                           if fireTank==nil and aiFireTank == nil then  --双方 本轮都没有要开火的坦克了 同时 没有要开火的AI部队 
                               if  self:isBattleFinished() then
                                    battleEnd=true  --结束战斗
                               else
                                    if self.fjTb then
                                      self.fjIsFire =true
                                      self:fjFireTick()
                                    else
                                      self.nextFire=0  --重新开始一轮交火
                                      self.hhNum=self.hhNum+1
                                      self:fireTick()  --立即开始一轮交火
                                      self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
                                    end
                                    do return end
                               end
                           end
                           self.nextFire=2 
                   end
            end
    else--空中轰炸
            if cityGun then
                for k=self.lFireIndex,6 do
                     if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                          fireTank=self.allT1[k]
                          do break end
                     end
                 end
                 if fireTank==nil then --左方 本轮没有要开火的坦克了
                         for k=self.rFireIndex,6 do  --右方开火
                             if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                                  fireTank=self.allT2[k]
                                  do break end
                             end
                         end
                         if fireTank==nil then  --双方 本轮都没有要开火的坦克了
                             if  self:isBattleFinished() then
                                  battleEnd=true  --结束战斗
                             else
                                   self.nextFire=0  --重新开始一轮交火
                                   self.hhNum=self.hhNum+1
                                  self:fireTick(true)  --立即开始一轮交火
                                  --self.hhNum=self.hhNum+1
                                  self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
                                  do return end
                             end
                         end
                 end
            else
               for k=self.rFireIndex,6 do
                   if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                        fireTank=self.allT2[k]
                        do break end
                   end
               end 
               if fireTank==nil then --右方 本轮没有要开火的坦克了
                       for k=self.lFireIndex,6 do  --左方开火
                           if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                                fireTank=self.allT1[k]
                                do  break end
                           end
                       end
                       if fireTank==nil then  --双方 本轮都没有要开火的坦克了
                           if  self:isBattleFinished() then
                                battleEnd=true  --结束战斗
                           else
                                self.nextFire=0  --重新开始一轮交火
                                self.hhNum=self.hhNum+1
                                self:fireTick(true)  --立即开始一轮交火
                                --self.hhNum=self.hhNum+1
                                self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
                                do return end
                           end
                       end
               end
           end
    end

    if aiFireTank and self.aiBattleData[self.aiFireIndex] then---处理 ai部队 攻击数据 与被攻击的坦克的逻辑
        if aiFireTank.attNum < self.aiAttHH[tonumber(aiFireTank.area)][tonumber(aiFireTank.pos)] then
            aiFireTank.attNum = aiFireTank.attNum + 1
        else
            aiFireTank.isCanAtt = false
        end
        local aibtdata=self.aiFireIndex > 0 and self.aiBattleData[self.aiFireIndex] or nil --此次开火的数据(普攻)
        self.aiFireIndex = self.aiFireIndex + 1
        if aiFireTank.aiSkillTb[2] == 3 then
            aiFireTank:showLaserFire()--激光炮
        end
        if self.aiIsBlank[aiFireTank.area.."_"..aiFireTank.pos.."_"..aiFireTank.aId] then --受击方 无被攻击类型，所以攻击数据只有一组 “#-#-#”，
            self:attackedByAiTank(nil,nil,3 - aiFireTank.area,true)
        else
              local len=aibtdata and SizeOfTable(aibtdata) or 0--当前被攻击的对象数
              if aibtdata == nil or len == 0 then
                  print("aiTank---len---btdata---error:::>",aiFireTank,len,aibtdata)
                    self:fireTick()
                  do return end
              end

              --aiBattleDataTb = {{攻击数值,对方剩余坦克数，对方位置},{},...}  
              --whiDirection = 光柱落点（ 1 ：左边 ，2：右边 ， 3 ： 中间 ， 4 ：非多击 ）
              --isBlank = 本次攻击是否为空（只表现动画，无伤害值显示）
              local aiBattleDataTb, whiDirection,isBlank = self:checkAiBattleData(aibtdata,len) 

              self.aiIsBlank[aiFireTank.area.."_"..aiFireTank.pos.."_"..aiFireTank.aId] = isBlank and true or false

              if isBlank or self.realDefBufTb == nil then
                if isBlank then
                  self:attackedByAiTank(nil,nil,3 - aiFireTank.area,true)
                else
                  self:attackedByAiTank(aiBattleDataTb,whiDirection,3 - aiFireTank.area,isBlank)
                end
              else

                local curArea = 3 - aiFireTank.area
                local curTankTb = curArea == 1 and self.allT1 or self.allT2

                local function canBeAttacked()
                  self:attackedByAiTank(aiBattleDataTb,whiDirection,curArea,isBlank)
                end
                if self.realDefBufTb[curArea] then
                  for k,v in pairs(aiBattleDataTb) do
                      beAttTankPos = tonumber(v[3])
                      if curTankTb[beAttTankPos] and curTankTb[beAttTankPos].isSpace==false then
                        curTankTb[beAttTankPos]:animationCtrlByType("CG")
                      end
                      if k == SizeOfTable(aiBattleDataTb) then
                          local delayT = CCDelayTime:create(0.3 * G_battleSpeed)
                          local  delayfunc=CCCallFuncN:create(canBeAttacked)
                          local  seq=CCSequence:createWithTwoActions(delayT,delayfunc)
                          self.container:runAction(seq)
                      end
                  end
                else
                    canBeAttacked()
                end
              end
        end
        do return end
    end

    local isAttackSelf=false
    local islunkong=false
    local notYet = nil

    if self.hhNum%2==0 and tankCfg[fireTank.tankId].weaponType=="18" then  --b型火箭车 单数轮次数开火
           --这里添加火箭车效果 fireTank
           fireTank:animationCtrlByType("I")

           local btdata=self.battleData[self.fireIndex] 
           local isAttackSelfAg,realAttackDataAg,islunkongAg,isSingleDataAg=self:checkIsAttackSelf(btdata)
           if islunkongAg and SizeOfTable(fireTank.redCD) > 0 then
                self.fireIndex = self.fireIndex + 1
                self:checkAnimEffectByData(btdata[1],fireTank)
           end
           fireTank.redCD = {}
    else


          local btdata=self.battleData[self.fireIndex] --此次开火的数据
          -- print("~~~~~~~~~>11111")
          -- G_dayin(btdata)
          -- print("~~~~~~~~~>111111")
          self.fireIndex=self.fireIndex+1
          local burstData, burstPos
          local tnextDData=self.battleData[self.fireIndex]
          if tnextDData~=nil then
               if tnextDData[1]=="AZ" then --爆破军徽技能，6辆歼击车打死目标后，爆炸伤害，后面有可能连击
                  burstData = {}
                  burstPos = tonumber(tnextDData[2]) or nil
                  local beginPos = burstPos and 2 or 1
                  burstPos = tnextDData[2]
                  for k,v in pairs(tnextDData) do
                      if k > beginPos then
                          table.insert(burstData,v)
                      end
                  end
                  tnextDData=self.battleData[self.fireIndex+1]
                  -- notYet = true
               end

               if tnextDData then 
                  if tnextDData[1]=="$" then --本轮攻击要双击
                      self.is10074Skill=true
                      self.is10094Skill=true
                      notYet = true
                  end
                  if tnextDData[2]=="K" then
                      notYet = true
                  end
               end
               
          end
          isAttackSelf=false
          if btdata==nil then
              self:readyToEnd()
              do return end
          end

                  if fireTank~=nil then
                       local beAttackedTanks=self:getBeAttackedTanks(fireTank,kzhz)

                       local len=SizeOfTable(beAttackedTanks)
                       local curBeAttackNums = nil
                       -- local fireTank.fireNum = nil --当前开火的次数，用于新机制：最后一次开火后回调
                       if len>0 then
                          if kzhz==nil then

                                      local realAttackData=nil
                                      isAttackSelf,realAttackData,islunkong,isSingleData=self:checkIsAttackSelf(btdata)
                                      if isAttackSelf==true then
                                          fireTank:attackedSelf(realAttackData)
                                          if fireTank.isSpace ==true then
                                              if self.aiTb[fireTank.area] and self.aiTb[fireTank.area][fireTank.pos] and self.aiTb[fireTank.area][fireTank.pos] ~= 0 then--ai部队出现,并且播放对应buf技能
                                                   local aiTankShowSp = fireTank.area == 1 and self.allAI1[fireTank.pos] or self.allAI2[fireTank.pos]

                                                   if aiTankShowSp then
                                                       local allTankTb = fireTank.area ==1 and self.allT1 or self.allT2
                                                       local function fireTickCall()
                                                            self:fireTick()
                                                       end
                                                       aiTankShowSp:showAiTankAnimation(0,allTankTb,fireTickCall)
                                                   else
                                                      print("~~~~~~~~~~~~~~~~~~~~error in self.aiTb[fireTank.area][fireTank.pos]~~~~~~~~~~~~~~~~~~~~")
                                                      self:fireTick()
                                                   end
                                              else
                                                   self:fireTick()
                                              end
                                          end
                                      else            
                                                      local curAttNums = 6
                                                      local isBKSkill = false
                                                      if islunkong==false then
                                                          if (tankCfg[fireTank.tankId].abilityID and tankCfg[fireTank.tankId].abilityID=="bk") or self:hasSpcSkil(fireTank.area,"bk","a"..fireTank.tankId) then
                                                              curAttNums = SizeOfTable(btdata)
                                                              isBKSkill = true
                                                          end
                                                          if isBKSkill then
                                                              curBeAttackNums = curAttNums
                                                              fireTank:setFire(0.02,curAttNums)
                                                          else

                                                              if tankCfg[fireTank.tankId].type=="8" then
                                                                  if (tankCfg[fireTank.tankId].abilityID and (tankCfg[fireTank.tankId].abilityID and tankCfg[fireTank.tankId].abilityID=="i")) or self:hasSpcSkil(fireTank.area,"i","a"..fireTank.tankId) then
                                                                      curBeAttackNums = SizeOfTable(btdata)
                                                                  else
                                                                      curBeAttackNums = 6
                                                                  end
                                                              else
                                                                  curBeAttackNums = SizeOfTable(btdata)
                                                              end
                                                              fireTank:setFire(0.02,(tankCfg[fireTank.tankId].type=="8" and 6 or len))
                                                          end
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
                                                      local bombPos=0
                                                      if tankCfg[fireTank.tankId].type~="8" then
                                                              for mm=1,len do
                                                                  if islunkong ==true and btdata[mm] ==nil then 
                                                                    do break end
                                                                  end
                                                                  local curBeAttackedTank=beAttackedTanks[mm]
                                                                   if tankCfg[fireTank.tankId].weaponType=="11" then --B型坦克追着上一次攻击的坦克打，知道将其打死
                                                                        for mkk=1,len do
                                                                               if beAttackedTanks[mkk].isWillDie==false and beAttackedTanks[mkk].isSpace==false then
                                                                                    curBeAttackedTank=beAttackedTanks[mkk]
                                                                                    do break end
                                                                               end
                                                                        end
                                                                   end

                                                                   if curBeAttackedTank.isWillDie==true then
                                                                            fireTank.fireNum=mm-1
                                                                            do break end
                                                                   end

                                                                  --以下返回3个字段，攻击者的技能效果、被攻击者的技能效果、排除掉技能效果后的战斗数据（同旧的的数据格式一致，减少代码修改量）
                                                                  local attackerData,beAttackerData,retData=self:checkAnimEffectByData(btdata[mm],fireTank)
                                                                  if attackerData~=nil then
                                                                      for eindex=1,#attackerData do
                                                                        -- print("~~~~attackerData[eindex]---->",attackerData[#attackerData+1-eindex],#attackerData+1-eindex)
                                                                        if attackerData[#attackerData+1-eindex]=="G" then
                                                                          fireTank.isG=true
                                                                           curBeAttackedTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                        else
                                                                           fireTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                        end
                                                                        
                                                                      end
                                                                  end
                                                                  if len>1 and  (curBeAttackedTank.tankId==10134 or  curBeAttackedTank.tankId==10135 or curBeAttackedTank.tankId==10133) then
                                                                      curBeAttackedTank.isAtamaTankAbility=true --触发阿塔玛坦克防御技能
                                                                  end
                                                                  if islunkong==false then
                                                                        burstPos = burstPos or curBeAttackedTank.pos-----某些平台不会开这个新军徽，需要在这里做全部考虑
                                                                        if burstData and SizeOfTable(burstData)>0 and burstPos then--军徽爆破技能
                                                                            -- curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                            -- print("curBeAttackNums------>",curBeAttackNums)
                                                                            local isBurst = curBeAttackedTank.pos == burstPos and true or nil
                                                                            curBeAttackedTank:beAttacked(1+mm*0.4,fireTank.tid,23,retData==nil and btdata[mm] or retData,nil,beAttackerData,fireTank.isG,nil,nil,isBurst,nil,nil,nil,nil,notYet)
                                                                            if mm == len then
                                                                              self:burstNow(curBeAttackedTank,burstData,burstPos,3.2)
                                                                            end
                                                                        else
                                                                            curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                            curBeAttackedTank:beAttacked(1+mm*0.4,fireTank.tid,23,retData==nil and btdata[mm] or retData,nil,beAttackerData,fireTank.isG,nil,nil,nil,nil,nil,curBeAttackNums,nil,notYet,fireTank.skinId)
                                                                        end
                                                                  end
                                                              end
                                                      else
                                                              local hasIDs,singlePos={},0
                                                              -- print("~~~~~~>>>>>>",btdata)
                                                              -- G_dayin(btdata)
                                                              for mm=1,len do
                                                                  if islunkong ==true and btdata[mm] ==nil then 
                                                                    do break end
                                                                  end
                                                                  hasIDs[beAttackedTanks[mm].pos]=1
                                                                  if isSingleData then--用于解除沉默技能
                                                                      singlePos = beAttackedTanks[mm].pos
                                                                  end
                                                                  local curBeAttackedTank=beAttackedTanks[mm]--火箭车攻击阿塔玛的特效
                                                                  if len>1 and (curBeAttackedTank.tankId==10134 or curBeAttackedTank.tankId==10133 or curBeAttackedTank.tankId==10135) then
                                                                          curBeAttackedTank.isAtamaTankAbility=true --触发阿塔玛坦克防御技能
                                                                  end
                                                                      
                                                              end
                                                              local dataID=1    
                                                              local curHhHasIds = SizeOfTable(hasIDs) --当前回合普通火箭车打击的实际目标数，用于新爆破军徽延时使用
                                                              if tankCfg[fireTank.tankId].type=="8" then  --火箭炮特殊处理
                                                                  
                                                                  for tsk=1,curAttNums do
                                                                      -- print("btdata[tsk]........",btdata[tsk],tsk,fireTank.tankId)
                                                                      if islunkong==true and btdata[tsk] ==nil then
                                                                        do break end
                                                                      end
                                                                      if (tankCfg[fireTank.tankId].abilityID~=nil and tankCfg[fireTank.tankId].abilityID=="i") or self:hasSpcSkil(fireTank.area,"i","a"..fireTank.tankId) then --沙暴火箭炮

                                                                            if btdata[tsk]==nil then
                                                                                  do break end
                                                                            end

                                                                            local attackerData,beAttackerData,retData=self:checkAnimEffectByData(btdata[tsk],fireTank)
                                                                            if islunkong ==true then
                                                                                fireTank:animationCtrlByType(attackerData[1])
                                                                                do break end
                                                                            end
                                                                            if attackerData~=nil then
                                                                                for eindex=1,#attackerData do
                                                                                      fireTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                                end
                                                                            end
                                                                            for sbhj=1,6 do

                                                                                 if beAttackedTanks[dataID]~=nil then
                                                                                    local retLeftNum
                                                                                    if burstPos then--军徽爆破技能
                                                                                          local isBurst = beAttackedTanks[dataID].pos == burstPos and true or nil
                                                                                          retLeftNum=beAttackedTanks[dataID]:beAttacked(0.8+tsk*0.12,fireTank.tid,23,retData==nil and btdata[tsk] or retData,nil,beAttackerData,nil,nil,nil,isBurst,nil,nil,nil,nil,notYet)
                                                                                          if tsk == curAttNums then
                                                                                            self:burstNow(beAttackedTanks[dataID],burstData,burstPos)
                                                                                          end
                                                                                    else
                                                                                         curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                                         retLeftNum=beAttackedTanks[dataID]:beAttacked(1+tsk*0.1,fireTank.tid,23,retData==nil and btdata[tsk] or retData,nil,beAttackerData,nil,nil,nil,nil,nil,nil,curBeAttackNums,nil,notYet,fireTank.skinId)
                                                                                    end
                                                                                    if retLeftNum==0 then --第dataID个被摧毁了
                                                                                          beAttackedTanks[dataID]=nil
                                                                                    end
                                                                                    do break end
                                                                                 else
                                                                                     dataID=dataID+1
                                                                                      if dataID>6 then
                                                                                          dataID=1
                                                                                      end
                                                                                 end
                                                                            end

                                                                             dataID=dataID+1
                                                                             if dataID>6 then
                                                                                  dataID=1
                                                                             end
                                                                      elseif isBKSkill then --t34火箭车

                                                                            if btdata[tsk]==nil then
                                                                                    do break end
                                                                            end

                                                                            local attackerData,beAttackerData,retData=self:checkAnimEffectByData(btdata[tsk],fireTank)
                                                                            if islunkong ==true then
                                                                                fireTank:animationCtrlByType(attackerData[1])
                                                                                do break end
                                                                            end
                                                                            if attackerData~=nil then
                                                                                for eindex=1,#attackerData do
                                                                                      fireTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                                end
                                                                            end
                                                                            for sbhj=1,6 do
                                                                                 if beAttackedTanks[dataID]~=nil then
                                                                                    local retLeftNum
                                                                                    if burstPos then--军徽爆破技能
                                                                                          local isBurst = beAttackedTanks[dataID].pos == burstPos and true or nil
                                                                                          retLeftNum=beAttackedTanks[dataID]:beAttacked(0.8+tsk*0.12,fireTank.tid,23,retData==nil and btdata[tsk] or retData,nil,beAttackerData,nil,nil,nil,isBurst,nil,nil,nil,nil,notYet)
                                                                                          if tsk == curAttNums then
                                                                                            self:burstNow(beAttackedTanks[dataID],burstData,burstPos)
                                                                                          end
                                                                                    else
                                                                                         curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                                         retLeftNum=beAttackedTanks[dataID]:beAttacked(0.8+tsk*0.12,fireTank.tid,23,retData==nil and btdata[tsk] or retData,nil,beAttackerData,nil,nil,nil,nil,nil,nil,curBeAttackNums,nil,notYet,fireTank.skinId)
                                                                                    end

                                                                                     if retLeftNum==0 then --第dataID个被摧毁了
                                                                                          beAttackedTanks[dataID]=nil
                                                                                     end
                                                                                     do break end
                                                                                 else
                                                                                      dataID=dataID+1
                                                                                      if dataID>6 then
                                                                                          dataID=1
                                                                                      end
                                                                                 end
                                                                            end

                                                                            dataID=dataID+1
                                                                            if dataID>6 then
                                                                                  dataID=1
                                                                            end

                                                                      else
                                                                          if isSingleData then
                                                                             tsk = singlePos
                                                                             isSingleData = false
                                                                          end
                                                                          if hasIDs[tsk]~=nil then --此位置有目标坦克
                                                                            -- print("tsk,hasIDs[tsk]",tsk,hasIDs[tsk])
                                                                            -- print("~~~~~~~~~>22222",dataID,btdata[dataID])
                                                                            -- G_dayin(btdata)
                                                                            -- print("~~~~~~~~~>222222")
                                                                                  local attackerData,beAttackerData,retData=self:checkAnimEffectByData(btdata[dataID],fireTank)
                                                                                  if islunkong ==true then
                                                                                    fireTank:animationCtrlByType(attackerData[1])
                                                                                    do break end
                                                                                  end
                                                                                  if attackerData~=nil then
                                                                                      for eindex=1,#attackerData do
                                                                                          fireTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                                      end
                                                                                  end
                                                                                  if burstPos then--军徽爆破技能
                                                                                      local isBurst = beAttackedTanks[dataID].pos == burstPos and true or nil
                                                                                      beAttackedTanks[dataID]:beAttacked(1+tsk*0.1,fireTank.tid,23,retData==nil and btdata[dataID] or retData,nil,beAttackerData,nil,nil,nil,isBurst,nil,nil,nil,nil,notYet,fireTank.skinId)
                                                                                      if dataID == curHhHasIds then
                                                                                        self:burstNow(beAttackedTanks[dataID],burstData,burstPos)
                                                                                      end
                                                                                  else
                                                                                      curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                                      beAttackedTanks[dataID]:beAttacked(1+tsk*0.1,fireTank.tid,23,retData==nil and btdata[dataID] or retData,nil,beAttackerData,nil,nil,nil,nil,nil,nil,curBeAttackNums,nil,notYet,fireTank.skinId)
                                                                                  end
                                                                                  dataID=dataID+1
                                                                          else --打在空地上
                                                                               local dataTbs = fireTank.area==1 and self.allT2 or self.allT1
                                                                               curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                               dataTbs[tsk]:beAttacked(1+tsk*0.1,fireTank.tid,23,"23-1",nil,nil,nil,nil,nil,nil,nil,nil,curBeAttackNums,nil,notYet,fireTank.skinId)
                                                                          end
                                                                      end
                                                                  end
                                                              end
                                                      end
                                         end
                          else  --空中轰炸
                                      local isNeedPlane,isFuSheBo = true,nil
                                      

                                      if fuSheBo then--目前仅适用于”@1“(异次元战场)
                                        isNeedPlane = nil
                                        isFuSheBo =true
                                        self:runFuSheBo()
                                      elseif cityGun then
                                        notYet = true--在这里设置为true ：后端并没有在此显示ai部队的逻辑，故前后端统一
                                        curBeAttackNums = SizeOfTable(btdata)
                                        isNeedPlane = nil
                                        isFuSheBo =nil
                                        local addS = (self.emblemData and (self.emblemData[1] ~= 0 or self.emblemData[2] ~= 0)) and 1.4 or 0
                                        local gunsShowNum = SizeOfTable(btdata)
                                        -- gunsShowNum = 6
                                        local gunsDelayT = gunsShowNum > 3 and 2.2 or 1.5
                                        self:runCityGun(addS,gunsShowNum)--播放城防炮效果
                                        for mm=1,len do
                                            if btdata[mm] and beAttackedTanks[mm] and beAttackedTanks[mm].pos then
                                              curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                              beAttackedTanks[mm]:beAttacked(addS+gunsDelayT+mm*0.15,11,23,btdata[mm],nil,nil,nil,nil,nil,nil,nil,nil,curBeAttackNums,"beAttInCityGun",nil,notYet)
                                            end
                                        end
                                      end
                                      if cityGun == nil then
                                          curBeAttackNums = SizeOfTable(beAttackedTanks) 
                                          for mm=1,len do
                                              curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                              beAttackedTanks[mm]:beAttacked(beAttackedTanks[mm].pos>3 and 0.2 or 0.5,1,23,btdata[mm],isNeedPlane,nil,nil,nil,isFuSheBo,nil,nil,nil,curBeAttackNums)
                                          end
                                      end
                          end
                       end
                  end
    end

    local delayAdd=0
    if self.fireIndex>=self.fireIndexTotal then
        if self.fireIndex==self.fireIndexTotal then
            local nxtData=self.battleData[self.fireIndex]
            if (nxtData and nxtData[1]=="AZ")then
                battleEnd=true
                delayAdd=1
            end
        else
            battleEnd=true
            if newGuidMgr:isNewGuiding()==true then
                 if newGuidMgr.curStep==52 or newGuidMgr.curBMStep==3 then
                    do
                        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
                        newGuidMgr:toNextStep()
                        self.endBtnItemMenu:setPosition(ccp(100000,20))
                        return
                    end
                 end
            end
            if self.fjTb and SizeOfTable(self.fjTb) > 0 then
              if self.fjFireIndex >= self.fjFireIndexTotal then
                    delayAdd = 1
              else
                    battleEnd = false
              end
            end
        end
        if battleEnd and self.aiFireIndex and self.aiFireIndexTotal and self.aiFireIndex <= self.aiFireIndexTotal then
            battleEnd = false
            if self.aiFireIndex + 1 == self.aiFireIndexTotal and self.aiBattleData[self.aiFireIndexTotal] then
                local isCanUse = self:checkAiBattleDataIsCanUse( self.aiBattleData[self.aiFireIndexTotal] )
                if not isCanUse then
                    battleEnd = true
                end
            end
        end
    end

    if battleEnd==true then
        -- self:readyToEnd()
        local function battleResult()
            if self.isBattleEnd==false then
                self.isBattleEnd=true
                if self.fireTimer~=nil then
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
                end
                if self.airShipTb and next(self.airShipTb) then
                  self:showAirShip(true)
                else
                  self:showResuil()
                end
                if newGuidMgr:isNewGuiding()==true then
                    newGuidMgr:toNextStep()
                end
            end
            --self:stopAction()
        end
        
        local delayTime=CCDelayTime:create((3+delayAdd) * G_battleSpeed)--延时两秒再弹出结束面板
        local  delayfunc=CCCallFuncN:create(battleResult)
        local  seq=CCSequence:createWithTwoActions(delayTime,delayfunc)
        self.container:runAction(seq)
    end

    local nextDData=self.battleData[self.fireIndex]
    if nextDData~=nil then
         local isBurst=false
         if nextDData[1]=="AZ" then --6辆歼击车打死目标后，爆炸伤害，后面有可能连击
            self.fireIndex=self.fireIndex+1
            nextDData=self.battleData[self.fireIndex]
            isBurst=true
         end
         if nextDData then
           if nextDData[2]=="K" then --乘胜追击
              --播放动画
              if newGuidMgr:isNewGuiding()==false then
                local function playerAnim()
                  fireTank:animationCtrlByType("K")
                end
                local callFunc=CCCallFunc:create(playerAnim)
                local delayTs=2
                if isBurst==true then --爆炸完之后放技能
                    delayTs=delayTs+0.5
                end
                local delay=CCDelayTime:create(delayTs * G_battleSpeed)
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                sceneGame:runAction(seq)
              end

           end

           if nextDData[1]=="$" then --本轮攻击要双击
              self.fireIndex=self.fireIndex+1
               if self.nextFire==2 then
                   self.nextFire=1
                   self.lFireIndex=self.lFireIndex-1
               else
                   self.nextFire=2
                   self.rFireIndex=self.rFireIndex-1

               end
           end
         end
    end
    if islunkong ==true or (self.hhNum%2==0 and tankCfg[fireTank.tankId].weaponType=="18")then--(self.hhNum%2==0 and tankCfg[fireTank.tankId].weaponType=="18")  适用于新的回合机制，如果改为原来旧的定时启动，需删除或注释掉
      self:fireTick()
    end
    if isAttackSelf==true and fireTank~=nil and fireTank.isSpace~=true then
           if self.nextFire==2 then
               self.nextFire=1
               self.lFireIndex=self.lFireIndex-1
           else
               self.nextFire=2
               self.rFireIndex=self.rFireIndex-1
           end
           self:fireTick()   
    end
end

function battleScene:tick()
    if self.isBattleEnd==true then
        do
            return
        end
    end
    if newGuidMgr.curStep==52 or newGuidMgr.curBMStep==3 then
        self.endBtnItemMenu:setTouchPriority(-322)
        self.endBtnItemMenu:setPosition(ccp(G_VisibleSize.width-self.endBtnItem:getContentSize().width,20))
    else
        if self.endBtnItemMenu~=nil then
          local touchNum = self.layerNum and (-(self.layerNum - 1) * 20 - 4) < -203 and (-(self.layerNum - 1) * 20 - 4) or -203
            self.endBtnItemMenu:setTouchPriority(touchNum)
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
              -- print("in fireTickHandler~~~~!!!@@@@")
              if self.fjIsFire and self.fjTb then
                self:fjFireTick()
              else
                self:fireTick()
              end
        end
        self.fireIndex   = 1
        self.aiFireIndex = 1
        self.fireIndexTotal   = #self.battleData
        self.aiFireIndexTotal = #self.aiBattleData
        self:fireTick()
        -- self.fireTimer=CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(fireTickHandler,3,false)
        -- print("self.fireTimer---->",self.fireTimer)
        self.startFire=false
    end
    self.tickIndex=self.tickIndex+1
    for k,v in pairs(self.allT1) do
        v:tick()
        if base.isNewBufPos ==1 and v.bufShowMask then --
            if self.isNewBufShow ==false then
                v.bufShowMask:setVisible(false)
            end
        end
    end
    for k,v in pairs(self.allT2) do
        v:tick()
        if base.isNewBufPos ==1 and v.bufShowMask then
            if self.isNewBufShow ==false then
                v.bufShowMask:setVisible(false)
            end
        end
    end
end

function battleScene:tankBeAttackAnimationFinish(isAiAttEnd)
    if self.fjIsFire and self.fjTb then
      self:fjFireTick()
    else
      self:fireTick()
    end
end

function battleScene:takeSpecialShow( idx )--战斗画面内特殊技能显示方法 idx 1.加效果 2.去掉效果
  if idx ==1 then
      local bfsTb_1 = self.bfSkill[1]
      local bfsTb_2 = self.bfSkill[2]
      if self.bfSkill[1] ~=nil and SizeOfTable(self.bfSkill[1]) >0 then
          local bufTb = {}
          for k,v in pairs(self.bfSkill[1]) do
            if v ~= "" then
                local len = string.len(v)
                for i=1,len+1,2 do
                    local twoChar=string.sub(v,i,i+1)
                    if twoChar~=nil and tostring(twoChar)~=nil then
                      self.allT1[k]:animationCtrlByType(twoChar)
                      self:setNewType(twoChar)
                    end
                end
                self.bfSkill[1][k]=""-----------当这辆tank的技能全部使用完毕，置空
            end
          end
      end
      if self.bfSkill[2] ~=nil and SizeOfTable(self.bfSkill[2]) >0 then
          for k,v in pairs(self.bfSkill[2]) do
            if v ~= "" then
                local len = string.len(v)
                for i=1,len+1,2 do
                    local twoChar=string.sub(v,i,i+1)
                    if twoChar~=nil and tostring(twoChar)~=nil then
                      self.allT2[k]:animationCtrlByType(twoChar)
                      self:setNewType(twoChar)
                    end
                end
                self.bfSkill[2][k]=""
            end
          end
      end
  elseif idx == 2 then --去除技能特效
      local removIdx = nil
      for i=1,#self.bfSkilledTb do
          if self.bfSkilledTb[i] == "AT" then----------判断是否是要删除的技能，如果有新技能需要判断 在里面添加即可
            for m,n in pairs(self.allT1) do
                if m >3 and n ~= nil then
                  n:animationCtrlByType("at")
                end
            end
            for m,n in pairs(self.allT2) do
                if m >3 and n ~=nil then
                  n:animationCtrlByType("at")
                end
            end
            table.remove(self.bfSkilledTb,i)
            i = i-1
          end
      end
      
      local isAllFaild = true
      for k,v in pairs(self.bfSkill) do
          for m,n in pairs(v) do
            if n ~= "" then
              isAllFaild =false
            end
          end
      end
      if isAllFaild ==true then
        self.bfSkill =nil
      end
  end
end

function battleScene:setNewType( nType)--战斗逻辑内添加已使用过的技能type，为移除使用
    
    local isHas = false
    for k,v in pairs(self.bfSkilledTb) do
      if v ==nType then
        isHas = true
        do break end
      end
    end
    if isHas ==false then
      table.insert(self.bfSkilledTb,nType)
    end
end

function battleScene:showZWTick()
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

--获取被开火坦克攻击的坦克
function battleScene:getBeAttackedTanks(fireTank,isSelectAll)
    local aimTanks
    local retTb={}
    if fireTank.area==1 then
        aimTanks=self.allT2
    else
        aimTanks=self.allT1
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
    -- print("fireTank.tankId-->>>",fireTank.tankId,fireTank.attackType[fireTank.tankId])

    local attackType=fireTank.attackType[fireTank.tankId] --攻击类型(炮弹的数量) 1:单体 2:横排 3:纵排 4：四发（第一种 十字星打发） 6:全体  ---[[attackType 在tank.lua内修改！！！！]]
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
                 end
                 if aimTanks[v[2]]~=nil and aimTanks[v[2]].isSpace==false then
                    table.insert(retTb,aimTanks[v[2]])
                 end
                 do break  -- 只能取出一组数据
                 end
             end
        end
    elseif attackType==3 then
        if tankCfg[fireTank.tankId].weaponType=="11" then
                isBTypeTank=true
        end
        if isBTypeTank==true then
            local tmpPos= (fireTankPos>3 and (fireTankPos-3) or fireTankPos)
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
                        numidx=numidx+1
                        if numidx>=3 then
                            do break end
                        end
                  end
             end
             while true do
               if SizeOfTable(retTb)<3 then
                    table.insert(retTb,retTb[1])
               else
                   do break end
               end
             end
        else
          local tempTb={{1,4},{2,5},{3,6}}
          for k,v in pairs(tempTb) do
              if  aimTanks[v[1]]~=nil and aimTanks[v[1]].isSpace==false then
                  table.insert(retTb,aimTanks[v[1]])
              elseif aimTanks[v[2]]~=nil and aimTanks[v[2]].isSpace==false then
                  table.insert(retTb,aimTanks[v[2]])
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

                    if aimTanks[v+3]~=nil and aimTanks[v+3].isSpace ==false then
                        table.insert(retTb,aimTanks[v+3])
                    end
                    if v-1 >0 and aimTanks[v-1]~=nil and aimTanks[v-1].isSpace ==false then
                        table.insert(retTb,aimTanks[v-1])
                    end
                    if v+1 <4 and aimTanks[v+1]~=nil and aimTanks[v+1].isSpace ==false then
                        table.insert(retTb,aimTanks[v+1])
                    end
                    do break end
                elseif aimTanks[v] ~=nil and aimTanks[v].isSpace ==false then
                    table.insert(retTb,aimTanks[v])

                    if v-1 >3 and aimTanks[v-1]~=nil and aimTanks[v-1].isSpace ==false then
                        table.insert(retTb,aimTanks[v-1])
                    end
                    if v+1 <7 and aimTanks[v+1]~=nil and aimTanks[v+1].isSpace ==false then
                        table.insert(retTb,aimTanks[v+1])
                    end
                    do break end
                end
            end
        end
        
    elseif attackType==6 then
        for k=1,6 do
             if aimTanks[k]~=nil and aimTanks[k].isSpace==false then
                 table.insert(retTb,aimTanks[k])
             end
        end
    end
    return retTb
end

--添加摧毁的坦克 area:区域  pos:坦克在原地图层x,y坐标 sp:废墟图片,lastBeAttNum:剩余子弹数：用于最终被打败一方，AI部队随最后一辆死亡坦克一起退场
function battleScene:addDestoryTank(area,pos,sp,lastBeAttNum)
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
    if lastBeAttNum == 0 then
      local allTankTb = area == 1 and self.allT1 or self.allT2
      local isAllDie = true
      for i=1,SizeOfTable(allTankTb) do
          if allTankTb[i] and allTankTb[i].isWillDie == false then
             isAllDie = false
             do break end
          end  
      end
      if isAllDie then
          local aiTankShowSpTb = area == 1 and self.allAI1 or self.allAI2
          for k,v in pairs(aiTankShowSpTb) do
              if v.isShow and v.isNotShowDestroyAITank then
                v.isNotShowDestroyAITank = false
                v.container:setVisible(false)
                local stopAiSp = CCSprite:createWithSpriteFrameName(v.btPic)
                local worldPos=tankLayer:convertToWorldSpace(ccp(v.container:getPosition()))
                local parentLayerPos=parentLayer:convertToNodeSpace(worldPos)
                stopAiSp:setPosition(parentLayerPos)
                parentLayer:addChild(stopAiSp)
              end
          end
      end
    end
end

--添加命中效果
function battleScene:addMzEffect(area,pos,sp)
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
function battleScene:addShellEffect(area,pos,sp)
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
function battleScene:addDustEffect(area,pos,sp)
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
function battleScene:addDig(area,pos,sp)
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
function battleScene:addDie(area,pos,sp)
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
--添加爆破动画
function battleScene:addBurst(area,pos,sp)
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

function battleScene:addSubLife(area,pos,sp,bj,deTime)
    local newDeTime = deTime or 0.3
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
                local subMvTo=CCMoveTo:create(0.2 * G_battleSpeed,ccp(staPoint.x,staPoint.y+50))
                local delayTime=CCDelayTime:create(newDeTime * G_battleSpeed)
                local subMvTo2=CCMoveTo:create(0.4 * G_battleSpeed,ccp(staPoint.x,staPoint.y+180))
                local  subfunc=CCCallFuncN:create(subMvEnd);
                --local  bjfunc=CCCallFuncN:create(bjHandler);
                local fadeOut=CCFadeTo:create(0.4 * G_battleSpeed,0)
                local fadeArr=CCArray:create()
                fadeArr:addObject(subMvTo2)
                fadeArr:addObject(fadeOut)
                local spawn=CCSpawn:create(fadeArr)
                local acArr=CCArray:create()
                acArr:addObject(subMvTo)
                if bj==true then
                    --acArr:addObject(bjfunc)
                    local wzScaleTo=CCScaleTo:create(0.2 * G_battleSpeed,2)
                    local wzScaleBack=CCScaleTo:create(0.2 * G_battleSpeed,1.3)
                    acArr:addObject(wzScaleTo)
                    acArr:addObject(wzScaleBack)
                end
                acArr:addObject(delayTime)
                acArr:addObject(spawn)
                acArr:addObject(subfunc)
                local  subseq=CCSequence:create(acArr)
                sp:runAction(subseq)
  
end
function battleScene:addRestraintAni(area,pos,relativeNum)
    
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
    animation:setDelayPerUnit(0.08 * G_battleSpeed)
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
function battleScene:addBomb(sp)
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

function battleScene:showResuil()
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
        if(self.swId)then
            local challengeVo=superWeaponVoApi:getSWChallenge()
            if(challengeVo.maxClearPos==1 and challengeVo.curClearPos==1 and otherGuideMgr:checkGuide(8)==false)then
                eventDispatcher:dispatchEvent("superweapon.guide.battleEnd")
                otherGuideMgr:showGuide(8)
            elseif(challengeVo.maxClearPos==20 and challengeVo.curClearPos==20 and otherGuideMgr:checkGuide(20)==false)then
                eventDispatcher:dispatchEvent("superweapon.guide.battleEnd")
                otherGuideMgr:showGuide(11)
            elseif((challengeVo.maxClearPos==50 and challengeVo.curClearPos==50) or (challengeVo.maxClearPos==60 and challengeVo.curClearPos==60) or (challengeVo.maxClearPos==70 and challengeVo.curClearPos==70))then
                -- local dataKey="superWeapon@challenge@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..challengeVo.maxClearPos
                -- local localData=CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
                -- if(localData~=1)then
                --     local message={key="super_weapon_sysMsg",param={playerVoApi:getPlayerName(),challengeVo.curClearPos}}
                --     chatVoApi:sendSystemMessage(message)
                --     CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,1)
                --     CCUserDefault:sharedUserDefault():flush()
                -- end
            end
        end
        if (self.ecId or self.battleType==38) and self.closeResultPanelHandler then
          if self.battleType==38 then
            local isVictory = false
            if self.battleReward == -1 then
              isVictory = false
            else
              isVictory = true
            end
            self.closeResultPanelHandler(isVictory)
          else
            self.closeResultPanelHandler()            
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
    if self.isFuben==true then 
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
        self.endBtnItem:setVisible(false)
        smallDialog:showBattleResultDialog_2("BlackAlphaBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(0, 0, 400, 350),CCRect(0,0,40,40),isVictory,callback,true,8,award,self.resultStar,self.isFuben,self.acData,nil,nil,nil,nil,nil,nil,self)
        -- smallDialog:showBattleResultDialog("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),isVictory,callback,true,8,award,self.resultStar,self.isFuben,self.acData)
    elseif self.battleType == 38 then --军团锦标赛战斗结算处理
        if self.battleReward == -1 then
          isVictory = false
        else
          isVictory = true
        end
        local diffId = self.firstData.diffId or 1 --个人战关卡难易程度
        local troops = self.firstData.troops or {{}, {}, {}, {}, {}, {}}--我方出战部队
        local dieTroops = self.firstData.data.report.dietroops or {{}, {}, {}, {}, {}, {}} --损失的部队
        if isVictory == false then --我方输了的话，部队全部损伤
          dieTroops = troops
        end

        local result = {star = self.resultStar / diffId, dieTroops = dieTroops, diffId = diffId, troops = troops}
        championshipWarVoApi:showPersonalWarBattleResultDialog(isVictory, result, false, 8, callback, self)
    elseif self.personalRebelData then --个人叛军战斗结算处理
      if self.battleReward == 1 then
        isVictory = true
      else
        isVictory = false
      end
        if self.personalRebelData.callbackFunc then
          self.personalRebelData.callbackFunc(self.firstData.data.reward, isVictory, callback, self.layerNum)
        end
    else
        if self.isAttacker==true then
            if self.battleReward==-1 then
                isVictory=false
            else
                isVictory=true
                if self.battleReward and type(self.battleReward)=="table" and SizeOfTable(self.battleReward) then
                    if self.alienBattleData and type(self.alienBattleData)=="table" and self.alienBattleData.islandType then
                        if self.battleReward and self.battleReward.u and self.battleReward.u.r4 then
                            local num=tonumber(self.battleReward.u.r4) or 0
                            local resType=self.alienBattleData.islandType
                            if alienMineCfg and alienMineCfg.collect and alienMineCfg.collect[resType] and alienMineCfg.collect[resType].rate then
                                local rate=alienMineCfg.collect[resType].rate
                                self.battleReward.r={}
                                self.battleReward.r["r"..resType]=math.floor(num*rate)
                            end
                        end
                    end 
                    award=FormatItem(self.battleReward)
                end
                if self.battleAcReward and type(self.battleAcReward)=="table" and SizeOfTable(self.battleAcReward) then
                  for k,v in pairs(self.battleAcReward) do
                    if acAutumnCarnivalVoApi then
                        local cfg = acAutumnCarnivalVoApi:getGiftCfgForShow()
                        local acCfg = cfg[k]
                        -- print(SizeOfTable(award))
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

        self.endBtnItem:setVisible(false)----使用新方法 需要把“跳过战斗”按钮隐藏起来，否则有重叠显示，不美观

        smallDialog:showBattleResultDialog_2("BlackAlphaBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(0, 0, 400, 350),CCRect(0,0,40,40),isVictory,callback,true,8,award,self.resultStar,nil,nil,self.winCondition,self.swId,self.robData,self.upgradeTanks,self.levelTb,self.challenge,self)

        -- smallDialog:showBattleResultDialog("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),isVictory,callback,true,8,award,self.resultStar,nil,nil,self.winCondition,self.swId,self.robData,self.upgradeTanks,self.levelTb,self.challenge)
    end
end

function battleScene:stopAction()
    if self.scheIndex then
      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheIndex) --停止计时器
    end
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

function battleScene:isBattleFinished()
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
function battleScene:addLD(idx)
      --左边
         local ldSp=CCSprite:createWithSpriteFrameName("d_1.png")
         ldSp:setAnchorPoint(ccp(0.5,0.5))
         winPos=ccp(600,G_VisibleSize.height*0.7)
         
         self.l_traceLayer:addChild(ldSp)
         
         local layerPos=self.l_traceLayer:convertToNodeSpace(winPos)
         ldSp:setPosition(layerPos)
      --右边
         
end
function battleScene:addZW(idx)
        
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
function battleScene:close()
    if self.battleType==4 then
        if platWarMapScene and platWarMapScene.setShowWhenEndBattle then
            platWarMapScene:setShowWhenEndBattle()
        end
    elseif self.isFuben==true then
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
    -- print("self.scheindex......",self.scheIndex)
    if self.scheIndex then
      CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheIndex) --停止计时器
    end
    if self.fireTimer~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
    end
    if self.container then
      self.container:removeFromParentAndCleanup(true)
    end
    self:dispose()
end

function battleScene:fastTick()
    if(self.fastTickIndex==nil)then
      do return end
    end
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

function battleScene:mapShake(area)
    if area==1 then
         self.r_ShakeStTime=G_getCurDeviceMillTime()
    else
         self.l_ShakeStTime=G_getCurDeviceMillTime()
    end
end


function battleScene:showStarAni(parent,m_starnum)
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
        local starTime = 0.1 * G_battleSpeed;
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
        local starTime = 0.1 * G_battleSpeed;
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

function battleScene:checkIsAttackSelf(btdata)
    local isAttackSelf,realAttackData,islunkong,isSingleData=false,nil,false,false
    if btdata and btdata[1] then
        realAttackData={}
        local index=0
        for k,v in pairs(btdata) do
            local effectTB=Split(v,"-")
            local firstData=effectTB[1]
            if firstData~=nil then            
                if string.sub(firstData,1,1)=="D" then
                    isAttackSelf=true
                    effectTB[1]=string.sub(firstData,2)
                    realAttackData[k]=effectTB[1].."-"..effectTB[2]
                elseif string.len(firstData)>=2 and string.sub(firstData,1,2)=="AY" then
                    isAttackSelf=true
                    effectTB[1]=string.sub(firstData,3)
                    realAttackData[k]=effectTB[1].."-"..effectTB[2]
                elseif tostring(firstData)~=nil and tostring(firstData)=="*" then
                    index=index+1
                    isSingleData = true
                end
            end
        end
        if index==SizeOfTable(btdata) then
            islunkong=true
        end
    end

    return isAttackSelf,realAttackData,islunkong,isSingleData
end


function battleScene:checkAnimEffectByData(btdata,fireTank,specialAttType) --根据后台返回的数据得出双方具体的技能动画效果
  -- print("in here???????")
  -- G_dayin(btdata)
  -- print("btdata......",btdata)
    local effectTB=Split(btdata,"-")

    if #effectTB>=3 then --只有包含第3位的才可能有技能效果
           local effectData=effectTB[3]
           local effectData2=effectTB[4]
           local attackerData={}
           local beattackerData={}
           local isAttackers=true
           local bjzd=0
           if specialAttType then -- 飞机数据格式 4338463-1036-ch ，需要在此处做修正
              effectData = ""
              effectData2 = tostring(effectTB[3]) and "0"..effectTB[3] or effectTB[3]
           end
           if effectTB[1] =="*" then
              local returnEffectData = effectData == "n" and "bl" or nil
              if self.skillCD[effectData] and fireTank then
                  fireTank.beSkillCD[effectData] = 1
              else
                  table.insert(attackerData,effectData)
                  if returnEffectData and fireTank then
                      fireTank.beSkillCD[returnEffectData] = 1
                      fireTank.beSkillCD["bf"] = 1
                      fireTank.beSkillCD["be"] = 1
                      fireTank.beSkillCD["bm"] = 1
                  end
              end
           else
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
           end
           
           
           if effectData2~=nil then
           
                  local numidx=1
                  for i=1,string.len(effectData2),1 do
                        local oneChar=string.sub(effectData2,i,i)
                        if tonumber(oneChar)~=nil then
                               numidx=i
                        end
                  end
                  for i=1,numidx-1,2 do
                          local oneChar=string.sub(effectData2,i,i+1)
                          if self.skillCD[oneChar] and fireTank then
                              fireTank.beSkillCD[oneChar] = 1
                          else
                              table.insert(attackerData,oneChar)
                          end
                  end
                  for i=numidx+1,string.len(effectData2),2 do
                          local oneChar=string.sub(effectData2,i,i+1)
                          table.insert(beattackerData,oneChar)
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

---------------- ai 部队 ----------------收集开火的数据
function battleScene:checkAiBattleData(aibtdata,len) --此次开火的数据，攻击几个对象
    local curAiBtData = {}
    local whiDirection = len > 3 and 3 or nil
    local isBlank = false
    for k,v in pairs(aibtdata) do
        local effectTB=Split(v,"-")
        local attPos = tonumber(effectTB[3])
        curAiBtData[k] = effectTB

        if effectTB[1] == "#" and effectTB[2] == "#" then-- 对方无受击目标，跳出
            isBlank =true 
            do break end
        end
        if len > 1 and len < 4 then
            if not whiDirection then
                if attPos == 1 or attPos == 4 then
                    whiDirection = 1
                elseif attPos == 3 or attPos == 6 then
                    whiDirection = 2
                end
            elseif whiDirection ~= 3 then
                if whiDirection == 2 and (attPos == 1 or attPos == 4) then
                    whiDirection = 3
                elseif whiDirection == 1 and (attPos == 3 or attPos == 6) then
                    whiDirection = 3
                end
            end
        end
    end
    if not whiDirection then 
        if len > 1 then
            whiDirection = 3
        else
            whiDirection = 4 --只攻击了一个目标，
        end
    end
    return curAiBtData,whiDirection,isBlank
end
---只判断当前数据 是否可以用
function battleScene:checkAiBattleDataIsCanUse(aibtdata)
    for k,v in pairs(aibtdata) do
        local effectTB=Split(v,"-")
        if effectTB[1] == "#" and effectTB[2] == "#" then-- 对方无受击目标，跳出
            return false
        end
    end
    return true
end

function battleScene:attackedByAiTank(beData,whiDirection,area,isBlank)
    local bePosed,posTb = nil,{} --定位受击动画效果坐标，posTb :分支动画效果坐标
    local posTb2 = {}--用于受击烟火坐标使用
    local beRotated,rotatedTb = nil,{} -- 定位受击动画所摆的角度，postTb :分支动画的摆的角度
    local lineTb = {}--多个受击目标与起始点的直线距离（用于缩放动画效果使用）
    local layerTb1 = {4,1,5,2,6,3}
    local layerTb2 = {1,4,2,5,3,6}
    local curTankTb = {}--受击方坦克

    local beAttackedPic = CCSprite:createWithSpriteFrameName("laser_1.png")
    beAttackedPic:setAnchorPoint(ccp(1,0.5))
    if area == 1 then
        curTankTb = self.allT1
        local rightTopPos={ccp(230,694),ccp(359,603),ccp(510,512),ccp(291,821),ccp(427,738),ccp(557,658)}
        if G_isIphone5()==true then
            rightTopPos={ccp(230,694+176),ccp(359,603+176),ccp(510 ,512+176),ccp(291,821+176),ccp(427,738+176),ccp(557,658+176)}
        end
        beRotated = -25

        if isBlank or whiDirection == 3 then -- 空 或 全伤
            bePosed = ccp(rightTopPos[2].x + 35,rightTopPos[2].y + 45)
            if isBlank then
              posTb   = rightTopPos
              for k,v in pairs(posTb) do
                 rotatedTb[k] = G_getAngle(nil,bePosed,v)
                 lineTb[k]    = G_straightLineDistance(bePosed,v)
              end
            else
              for k,v in pairs(beData) do
                 local kk = tonumber(beData[k][3])
                 posTb[k] = rightTopPos[kk]
                 -- print("kk====>>>>",kk,beData)
                 rotatedTb[k] = G_getAngle(nil,bePosed,rightTopPos[kk])
                 lineTb[k]    = G_straightLineDistance(bePosed,rightTopPos[kk])
              end
            end
        elseif whiDirection == 4 then -- 单伤
            posTb = nil
            bePosed = rightTopPos[tonumber(beData[1][3])]
        elseif whiDirection == 2 then -- 右边
            bePosed = ccp(rightTopPos[2].x + 85,rightTopPos[2].y + 50)
            for k,v in pairs(beData) do
               local kk = tonumber(beData[k][3])
               posTb[k] = rightTopPos[kk]
               rotatedTb[k] = G_getAngle(nil,bePosed,rightTopPos[kk])
               lineTb[k]    = G_straightLineDistance(bePosed,rightTopPos[kk])
            end
        elseif whiDirection == 1 then -- 左边
            bePosed = ccp(rightTopPos[1].x + 85,rightTopPos[1].y + 0)
            for k,v in pairs(beData) do
               local kk = tonumber(beData[k][3])
               posTb[k] = rightTopPos[kk]
               rotatedTb[k] = G_getAngle(nil,bePosed,rightTopPos[kk])
               lineTb[k]    = G_straightLineDistance(bePosed,rightTopPos[kk])
            end
        end
        self.r_shellLayer:addChild(beAttackedPic)
    else
        curTankTb = self.allT2
        local leftDownPos={ccp(112,394),ccp(258,294),ccp(413,195),ccp(69,245),ccp(209,148),ccp(358,53)} --左下角6个坦克位置
        beRotated = 155

        if isBlank or whiDirection == 3 then -- 空 或 全伤
            bePosed = ccp(leftDownPos[2].x - 20,leftDownPos[2].y - 55)
            if isBlank then
              posTb   = leftDownPos
              for k,v in pairs(posTb) do
                 rotatedTb[k] = G_getAngle(nil,bePosed,v)
                 lineTb[k]    = G_straightLineDistance(bePosed,v)
              end
            else
              for k,v in pairs(beData) do
                 local kk = tonumber(beData[k][3])
                 posTb[k] = leftDownPos[kk]
                 rotatedTb[k] = G_getAngle(nil,bePosed,leftDownPos[kk])
                 lineTb[k]    = G_straightLineDistance(bePosed,leftDownPos[kk])
              end
            end
        elseif whiDirection == 4 then -- 单伤
            posTb = nil
            bePosed = leftDownPos[tonumber(beData[1][3])]
        elseif whiDirection == 2 then -- 右边
            bePosed = ccp(leftDownPos[5].x + 90,leftDownPos[5].y + 10)
            for k,v in pairs(beData) do
               local kk = tonumber(beData[k][3])
               posTb[k] = leftDownPos[kk]
               rotatedTb[k] = G_getAngle(nil,bePosed,leftDownPos[kk])
               lineTb[k]    = G_straightLineDistance(bePosed,leftDownPos[kk])
            end
        elseif whiDirection == 1 then -- 左边
            bePosed = ccp(leftDownPos[4].x + 80,leftDownPos[4].y + 45)
            for k,v in pairs(beData) do
               local kk = tonumber(beData[k][3])
               posTb[k] = leftDownPos[kk]
               rotatedTb[k] = G_getAngle(nil,bePosed,leftDownPos[kk])
               lineTb[k]    = G_straightLineDistance(bePosed,leftDownPos[kk])
            end
        end
        self.l_shellLayer:addChild(beAttackedPic)
    end

    if beData then
      if posTb then
          for k,v in pairs(posTb) do
            local beAttTankPos = tonumber(beData[k][3])
            local curTank = curTankTb[beAttTankPos]
            self:beRealAttackSkillShow(curTank,{beData[k][4]},0.7)
          end
      else
         local beAttTankPos = tonumber(beData[1][3])
         local curTank = curTankTb[beAttTankPos]
         self:beRealAttackSkillShow(curTank,{beData[1][4]},0.7)
      end
    end

    local deT1 = CCDelayTime:create(0.7)
    local function beAttFun1()--
         local laserAnimArr=CCArray:create()
         for kk=1,14 do
            local nameStr="laser_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            laserAnimArr:addObject(frame)
         end

         local animation=CCAnimation:createWithSpriteFrames(laserAnimArr)
         animation:setDelayPerUnit(0.05 * G_battleSpeed)--0.6
         local amiAc=CCAnimate:create(animation)

         beAttackedPic:setRotation(beRotated)
         beAttackedPic:setPosition(bePosed)
         local function laserEnd1()
              beAttackedPic:removeFromParentAndCleanup(true)
              beAttackedPic=nil
         end
         local  ffunc=CCCallFuncN:create(laserEnd1)
         local  fseq=CCSequence:createWithTwoActions(amiAc,ffunc) 
         beAttackedPic:runAction(fseq)
    end
    local beAttFunCall1   = CCCallFunc:create(beAttFun1)
    local beAttFunCall1_1 = nil
    if posTb then--添加首次命中烟雾效果
        local function beAttFun1_1()
              --播放命中动画
                     local mzSp=CCSprite:createWithSpriteFrameName("beLasered_1.png")
                     local  mzArr=CCArray:create()
                     for kk=1,23 do
                           local nameStr="beLasered_"..kk..".png"
                           local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                           mzArr:addObject(frame)
                     end
                     local animation=CCAnimation:createWithSpriteFrames(mzArr)
                     animation:setDelayPerUnit(0.04 * G_battleSpeed)
                     local animate=CCAnimate:create(animation)
                     mzSp:setPosition(bePosed)
                     if area == 1 then
                         self.r_shellLayer:addChild(mzSp,20)
                     else
                         self.l_shellLayer:addChild(mzSp,20)
                     end
                     local function mzEnd()
                          mzSp:stopAllActions()
                          mzSp:removeFromParentAndCleanup(true)
                          mzSp=nil
                     end
                     local  mzfunc=CCCallFuncN:create(mzEnd)
                     local  subLeftArr=CCArray:create()
                     subLeftArr:addObject(animate)
                     subLeftArr:addObject(mzfunc)
                     local  seq= CCSequence:create(subLeftArr)
                     mzSp:runAction(seq)
        end 
        beAttFunCall1_1 = CCCallFunc:create(beAttFun1_1)
    end
    local  actionArr=CCArray:create()
    actionArr:addObject(deT1)
    actionArr:addObject(beAttFunCall1)

    local deT2,beAttFunCall2 = nil,nil
    local beDataNum = isBlank and 6 or SizeOfTable(beData)
    if posTb then
        actionArr:addObject(beAttFunCall1_1)
        deT2 = CCDelayTime:create(0.2)
        actionArr:addObject(deT2)
        local indx = 1
        for k,v in pairs(posTb) do
            -- local k = layerTb1[kkk]
            local lastBeAttNum = beDataNum - indx
            local lifesub,leftn,curTank
            local beAttTankPos
            local willDie = false
            if not isBlank then
                if beData[k] == nil or beData[k][1] == nil then
                  do break end
                end
                beAttTankPos = tonumber(beData[k][3])
                lifesub = tonumber(beData[k][1])
                leftn   = tonumber(beData[k][2])
                curTank = curTankTb[beAttTankPos]
            else
                beAttTankPos = k
                curTank = curTankTb[k]
            end
            if isBlank or (curTank and curTank.isWillDie == false and curTank.isSpace == false) then
                local function beAttFun2( )
                     if not isBlank then
                        
                         if lifesub>0 and leftn == 0 then
                                curTank.isWillDie=true
                                willDie =true
                         end
                         curTank.tankNumLb:setString(leftn)
                         curTank.curTankNums=leftn

                         if leftn == 0 then
                              if curTank.container then
                                  curTank:playDieAnim()
                                  self:mapShake(curTank.area)
                                  local destoryPic = "t"..curTank.tid.."_"..curTank.area.."_die"..".png"
                                  if curTank.skinId and curTank.skinId ~= "" then
                                      destoryPic = curTank.skinId.."_"..destoryPic
                                  end
                                  self:addDestoryTank(curTank.area,ccp(curTank.container:getPosition()),CCSprite:createWithSpriteFrameName(destoryPic),lastBeAttNum)
                                  curTank.container:setVisible(false)
                              end
                         else
                            ------------------------播放 受击 声效------------------------
                         end

                         --播放扣除血量动画
                         curTank.subLifeLb=GetBMLabel(-lifesub,G_FontSrc,30)
                         if curTank.subLifeLb and lifesub==0 then
                            curTank.subLifeLb:setVisible(false)
                         end
                         curTank.subLifeLb:setAnchorPoint(ccp(0.5,0.5))
                         self:addSubLife(curTank.area,ccp(curTank.container:getPosition()),curTank.subLifeLb,nil,0)
                         if leftn==0 then
                             curTank.isSpace=true
                         end
                     end
                     --分支激光动画
                     local function sLaserFun()
                             local laserSp=CCSprite:createWithSpriteFrameName("laser_1.png")
                             laserSp:setAnchorPoint(ccp(0,0.5))

                             laserAnimArr = CCArray:create()
                             for kk=1,14 do
                                local nameStr="laser_"..kk..".png"
                                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                                laserAnimArr:addObject(frame)
                             end

                             local animation=CCAnimation:createWithSpriteFrames(laserAnimArr)
                             animation:setDelayPerUnit(0.05 * G_battleSpeed)--0.6
                             local amiAc=CCAnimate:create(animation)

                             laserSp:setScaleX(lineTb[k] / laserSp:getContentSize().width)

                             laserSp:setRotation(rotatedTb[k])
                             laserSp:setPosition(bePosed)
                             laserSp:setVisible(false)

                             if curTank.area == 1 then
                                 self.r_shellLayer:addChild(laserSp)
                             else
                                 self.l_shellLayer:addChild(laserSp)
                             end
                             local function showLaserSp( )
                                  laserSp:setVisible(true)
                             end 
                             local showLaserSpFun = CCCallFunc:create(showLaserSp)
                             local function endLaserSp( )
                                  laserSp:stopAllActions()
                                  laserSp:removeFromParentAndCleanup(true)
                                  laserSp=nil
                             end 
                             local endLaserSpFun = CCCallFunc:create(endLaserSp)
                             local laserArr = CCArray:create()
                             laserArr:addObject(showLaserSpFun)
                             laserArr:addObject(amiAc)
                             laserArr:addObject(endLaserSpFun)
                             local laserSeq = CCSequence:create(laserArr)
                             laserSp:runAction(laserSeq)
                     end
                     local sLaserFunCall = CCCallFunc:create(sLaserFun)
                     
                     deT33 = CCDelayTime:create(0.1)
                     --播放命中动画
                     local mzSp=CCSprite:createWithSpriteFrameName("beLasered_1.png")
                     local  mzArr=CCArray:create()
                     for kk=1,23 do
                           local nameStr="beLasered_"..kk..".png"
                           local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                           mzArr:addObject(frame)
                     end
                     local animation=CCAnimation:createWithSpriteFrames(mzArr)
                     animation:setDelayPerUnit(0.04 * G_battleSpeed)
                     local animate=CCAnimate:create(animation)
                     if curTank.area==1 and self then
                         mzSp:setPosition(posTb[k])
                         self.r_tankLayer:addChild(mzSp,20)
                     else
                         curTank.container:addChild(mzSp,20)
                     end
                     local function mzEnd()
                          if mzSp then
                            mzSp:stopAllActions()
                            mzSp:removeFromParentAndCleanup(true)
                            mzSp=nil
                          end
                          if indx >= beDataNum then
                              self:callNextAttack(0,area,curTankTb)
                          else
                              indx = indx + 1
                          end
                     end
                     local  mzfunc=CCCallFuncN:create(mzEnd)
                     local  subLeftArr=CCArray:create()
                     if curTank.isWillDie == false and curTank.isSpace == false then
                         subLeftArr:addObject(sLaserFunCall)
                         subLeftArr:addObject(deT33)
                         subLeftArr:addObject(animate)       
                     elseif willDie then
                         subLeftArr:addObject(sLaserFunCall)
                         subLeftArr:addObject(deT33)
                     end
                     subLeftArr:addObject(mzfunc)
                     local  seq= CCSequence:create(subLeftArr)
                     mzSp:runAction(seq)
                end
                beAttFunCall2=CCCallFuncN:create(beAttFun2)
                actionArr:addObject(beAttFunCall2)

            else
                print("error in [[[[[[ whiDirection != 4 ]]]]]]] in posTb has - >posTb.k : ",k,curTank.pos,curTank.isWillDie,curTank.isSpace)
            end
        end

    elseif whiDirection == 4 then
        local beAttTankPos = tonumber(beData[1][3])
        local lifesub = tonumber(beData[1][1])
        local leftn   = tonumber(beData[1][2])
        local curTank = curTankTb[beAttTankPos]
        
        if curTank and curTank.isWillDie == false and curTank.isSpace == false then
             
             local function beAttFun2( )
                 if lifesub>0 and leftn == 0 then
                        curTank.isWillDie=true
                 end
                 curTank.tankNumLb:setString(leftn)
                 curTank.curTankNums=leftn

                 if leftn == 0 then
                      if curTank.container then
                          curTank:playDieAnim()
                          self:mapShake(curTank.area)
                          local destoryPic = "t"..curTank.tid.."_"..curTank.area.."_die"..".png"
                          if curTank.skinId and curTank.skinId ~= "" then
                              destoryPic = curTank.skinId.."_"..destoryPic
                          end
                          self:addDestoryTank(curTank.area,ccp(curTank.container:getPosition()),CCSprite:createWithSpriteFrameName(destoryPic),0)
                          curTank.container:setVisible(false)
                      end
                 else
                    ------------------------播放 受击 声效------------------------
                 end
                 --播放扣除血量动画
                 curTank.subLifeLb=GetBMLabel(-lifesub,G_FontSrc,30)
                 if curTank.subLifeLb and lifesub==0 then
                    curTank.subLifeLb:setVisible(false)
                 end
                 curTank.subLifeLb:setAnchorPoint(ccp(0.5,0.5))
                 self:addSubLife(curTank.area,ccp(curTank.container:getPosition()),curTank.subLifeLb,nil,0)
                 if leftn==0 then
                     curTank.isSpace=true
                 end
                 --播放命中动画
                 local mzSp=CCSprite:createWithSpriteFrameName("beLasered_1.png")
                 local  mzArr=CCArray:create()
                 for kk=1,23 do
                       local nameStr="beLasered_"..kk..".png"
                       local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                       mzArr:addObject(frame)
                 end
                 local animation=CCAnimation:createWithSpriteFrames(mzArr)
                 animation:setDelayPerUnit(0.04 * G_battleSpeed)
                 local animate=CCAnimate:create(animation)
                 if curTank.area==1 and self then
                     mzSp:setPosition(bePosed)
                     self.r_tankLayer:addChild(mzSp,20)
                 else
                     curTank.container:addChild(mzSp,20)
                 end
                 local function mzEnd()
                      mzSp:stopAllActions()
                      mzSp:removeFromParentAndCleanup(true)
                      mzSp=nil

                      self:callNextAttack(0,area,curTankTb)
                 end
                 local  mzfunc=CCCallFuncN:create(mzEnd)
                 local  subLeftArr=CCArray:create()
                 subLeftArr:addObject(animate)
                 subLeftArr:addObject(mzfunc)
                 local  seq= CCSequence:create(subLeftArr)
                 mzSp:runAction(seq)
             end
             beAttFunCall2=CCCallFuncN:create(beAttFun2)
             actionArr:addObject(beAttFunCall2)
        else
            print "error in [[[[[[ whiDirection == 4 ]]]]]]] in error"
        end
    end

    local fseq=CCSequence:create(actionArr)
    self.container:runAction(fseq) 
end
----改动此函数 需要注意是否要修改tank.lua的( local function callNextAttack() )
----本函数目前仅用于ai部队攻击对方坦克并且把对方坦克干掉
function battleScene:callNextAttack(curBeFireNums,area,curTankTb)
    -- print("curBeFireNums---area---->",curBeFireNums,area)
    if curBeFireNums and curBeFireNums <= 0 and self.tankBeAttackAnimationFinish then
       -- local parent       = self.alsoparent
       local allTankTb    = curTankTb
       local isAllDie     = true--如果全死了 变为true 直接进入结束
       local aiTankShowSpTb = {}
       for i=1,SizeOfTable(allTankTb) do
          if allTankTb[i] and allTankTb[i].isWillDie == false then--and allTankTb[i].isSpace == false then
             isAllDie = false
             do break end
          end
       end
       if isAllDie then
          self:tankBeAttackAnimationFinish()
       else
           if self.aiTb and self.aiTb[area] then
               aiTankShowSpTb = area == 1 and self.allAI1 or self.allAI2
           end
           local addDetTime = 0
           local lastAI     = nil
           for i=1,SizeOfTable(allTankTb) do
                if allTankTb[i].isWillDie and aiTankShowSpTb[i] and aiTankShowSpTb[i].isShow == false then
                   aiTankShowSpTb[i]:showAiTankAnimation(addDetTime,allTankTb)
                   local addT = (aiTankShowSpTb[i].aiSkillTb[2] == 1 or aiTankShowSpTb[i].aiSkillTb[2] ==2 ) and 4.5 or 2
                   addDetTime = addDetTime + addT
                   lastAI = aiTankShowSpTb[i]
                end
           end
           local function nextFun( ... )
              self:tankBeAttackAnimationFinish()
           end
           if lastAI then
              lastAI:nextAtt(addDetTime,nextFun)
           else
              self:tankBeAttackAnimationFinish()
           end
       end
    end
end

function battleScene:disposeWhenChangeServer()
    if self.fireTimer~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
        self.fireTimer=nil
    end
    
    if self.scheIndex~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheIndex)
        self.scheIndex=nil
    end
end

function battleScene:hasSpcSkil(director,stype,tid) --方向1或2、技能类型、坦克id
     if self.spcSkill~=nil then
             local allSkillTB=self.spcSkill[director]
             if allSkillTB[stype]~=nil then
                  for kk,vv in pairs(allSkillTB[stype]) do
                       local lcTid ="a"..tostring(G_pickedList(tonumber(RemoveFirstChar(vv))))--
                      -- print("vv......------>",vv,RemoveFirstChar(vv),G_pickedList(tonumber(RemoveFirstChar(vv))),lcTid,tid)
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
function battleScene:runFuSheBo()
    if self.l_container then
        local fuSheBo1 = CCSprite:createWithSpriteFrameName("radiationBigSkill.png")
        fuSheBo1:setPosition(ccp(G_VisibleSizeWidth*0.35,G_VisibleSizeHeight*0.25))
        fuSheBo1:setAnchorPoint(ccp(0.5,0.5))
        self.l_container:addChild(fuSheBo1,2)
        fuSheBo1:setScale(2)

        local delayTime = CCDelayTime:create(0)
        local fadeIn = CCFadeIn:create(0.1 * G_battleSpeed)
        local scalBig = CCScaleTo:create(0.2 * G_battleSpeed,5)
        local fadeOut = CCFadeOut:create(0.1 * G_battleSpeed)

        local carray1=CCArray:create()
        carray1:addObject(fadeOut)
        local carray2 =CCArray:create()
        carray2:addObject(scalBig)
        local spawn1=CCSpawn:create(carray1)
        local spawn2=CCSpawn:create(carray2)
        local actionFuSheBo=CCSequence:createWithTwoActions(spawn2,spawn1)
        local cceaseOut=CCEaseOut:create(actionFuSheBo,0.8)        

        local function stopRun( )
           fuSheBo1:stopAllActions()
           fuSheBo1:removeFromParentAndCleanup(true)
           fuSheBo1=nil
        end 
        local ccFunc = CCCallFuncN:create(stopRun)
        local carray3=CCArray:create()
        carray3:addObject(delayTime)
        carray3:addObject(cceaseOut)
        carray3:addObject(ccFunc)
        local seq1 = CCSequence:create(carray3)
        fuSheBo1:runAction(seq1)
-----------------
        local fuSheBo2 = CCSprite:createWithSpriteFrameName("radiationBigSkill.png")
        fuSheBo2:setPosition(ccp(G_VisibleSizeWidth*0.35,G_VisibleSizeHeight*0.25))
        fuSheBo2:setAnchorPoint(ccp(0.5,0.5))
        self.l_container:addChild(fuSheBo2,2)
        fuSheBo2:setScale(1.5)
        fuSheBo2:setOpacity(200)
        fuSheBo2:setVisible(false)

        local delayTime2 = CCDelayTime:create(0.15)
        local fadeIn2 = CCFadeIn:create(0.1 * G_battleSpeed)
        local scalBig2 = CCScaleTo:create(0.25 * G_battleSpeed,4.5)
        local fadeOut2 = CCFadeOut:create(0.15 * G_battleSpeed)

        local carray11=CCArray:create()
        carray11:addObject(fadeOut2)
        local carray22 =CCArray:create()
        carray22:addObject(scalBig2)
        local spawn11=CCSpawn:create(carray11)
        local spawn22=CCSpawn:create(carray22)
        local actionFuSheBo2=CCSequence:createWithTwoActions(spawn22,spawn11)
        local cceaseOut1=CCEaseOut:create(actionFuSheBo2,0.7)
        
        local function stopRun2( )
           fuSheBo2:stopAllActions()
           fuSheBo2:removeFromParentAndCleanup(true)
           fuSheBo2=nil
        end 
        local function showSelf( )
          fuSheBo2:setVisible(true)
        end 
        local ccFunc33 = CCCallFuncN:create(showSelf)
        local ccFunc2 = CCCallFuncN:create(stopRun2)
        local carray33=CCArray:create()
        carray33:addObject(ccFunc33)
        carray33:addObject(delayTime2)
        carray33:addObject(cceaseOut1)
        carray33:addObject(ccFunc2)
        local seq11 = CCSequence:create(carray33)
        fuSheBo2:runAction(seq11)
    end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if self.r_container then
        local fuSheBo1 = CCSprite:createWithSpriteFrameName("radiationBigSkill.png")
        fuSheBo1:setPosition(ccp(G_VisibleSizeWidth*0.25,G_VisibleSizeHeight*0.4))
        fuSheBo1:setAnchorPoint(ccp(0.5,0.5))
        self.r_container:addChild(fuSheBo1,2)
        fuSheBo1:setScale(2)
        fuSheBo1:setVisible(false)

        local delayTime = CCDelayTime:create(0.5)
        local fadeIn = CCFadeIn:create(0.1 * G_battleSpeed)
        local scalBig = CCScaleTo:create(0.25 * G_battleSpeed,5)
        local fadeOut = CCFadeOut:create(0.15 * G_battleSpeed)

        local carray1=CCArray:create()
        carray1:addObject(fadeOut)
        local carray2 =CCArray:create()
        carray2:addObject(scalBig)
        local spawn1=CCSpawn:create(carray1)
        local spawn2=CCSpawn:create(carray2)
        local actionFuSheBo=CCSequence:createWithTwoActions(spawn2,spawn1)
        local cceaseOut=CCEaseOut:create(actionFuSheBo,0.8)        

        local function stopRun( )
           fuSheBo1:stopAllActions()
           fuSheBo1:removeFromParentAndCleanup(true)
           fuSheBo1=nil
        end 
        local function showSelf2( )
          fuSheBo1:setVisible(true)
        end 
        local ccFunc44 = CCCallFuncN:create(showSelf2)
        local ccFunc = CCCallFuncN:create(stopRun)
        local carray3=CCArray:create()
        carray3:addObject(delayTime)
        carray3:addObject(ccFunc44)
        carray3:addObject(cceaseOut)
        carray3:addObject(ccFunc)
        local seq1 = CCSequence:create(carray3)
        fuSheBo1:runAction(seq1)
-----------------
        local fuSheBo2 = CCSprite:createWithSpriteFrameName("radiationBigSkill.png")
        fuSheBo2:setPosition(ccp(G_VisibleSizeWidth*0.25,G_VisibleSizeHeight*0.4))
        fuSheBo2:setAnchorPoint(ccp(0.5,0.5))
        self.r_container:addChild(fuSheBo2,2)
        fuSheBo2:setScale(1.5)
        fuSheBo2:setOpacity(200)
        fuSheBo2:setVisible(false)

        local delayTime2 = CCDelayTime:create(0.8)
        local fadeIn2 = CCFadeIn:create(0.1 * G_battleSpeed)
        local scalBig2 = CCScaleTo:create(0.25 * G_battleSpeed,4.5)
        local fadeOut2 = CCFadeOut:create(0.15 * G_battleSpeed)

        local carray11=CCArray:create()
        carray11:addObject(fadeOut2)
        local carray22 =CCArray:create()
        carray22:addObject(scalBig2)
        local spawn11=CCSpawn:create(carray11)
        local spawn22=CCSpawn:create(carray22)
        local actionFuSheBo2=CCSequence:createWithTwoActions(spawn22,spawn11)
        local cceaseOut1=CCEaseOut:create(actionFuSheBo2,0.7)

        local function stopRun2( )
           fuSheBo2:stopAllActions()
           fuSheBo2:removeFromParentAndCleanup(true)
           fuSheBo2=nil
        end 
        local function showSelf( )
          fuSheBo2:setVisible(true)
        end 
        local ccFunc33 = CCCallFuncN:create(showSelf)
        local ccFunc2 = CCCallFuncN:create(stopRun2)
        local carray33=CCArray:create()
        carray33:addObject(delayTime2)
        carray33:addObject(ccFunc33)
        carray33:addObject(cceaseOut1)
        carray33:addObject(ccFunc2)
        local seq11 = CCSequence:create(carray33)
        fuSheBo2:runAction(seq11)
    end
end
function battleScene:runCityGun(addS,cityGunFireNums)
    local fireFixedT = cityGunFireNums >1 and 0.15 or 0
    -- print("addS-------->",addS)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/cityGunBattleImage.plist")
    spriteController:addTexture("public/cityGunBattleImage.png")
    spriteController:addPlist("public/plane/battleImage/battlesPlaneCommon1.plist")
    spriteController:addTexture("public/plane/battleImage/battlesPlaneCommon1.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local coverDia = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    coverDia:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    coverDia:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
    self.r_container:addChild(coverDia,98)

    local cityGunBg = CCSprite:createWithSpriteFrameName("cityGunBg1.png")
    cityGunBg:setPosition(ccp(G_VisibleSizeWidth*0.7,G_VisibleSizeHeight*0.65))
    cityGunBg:setScale(0.5)
    cityGunBg:setVisible(false)
    self.r_container:addChild(cityGunBg,99)
    local cityGunBg2 = CCSprite:createWithSpriteFrameName("cityGunBg2.png")
    cityGunBg2:setPosition(getCenterPoint(cityGunBg))
    cityGunBg:addChild(cityGunBg2)

    local cityGunTitleBg = CCSprite:createWithSpriteFrameName("cityGunTitleBg.png")--cityGunName
    cityGunTitleBg:setAnchorPoint(ccp(1,0))
    cityGunTitleBg:setPosition(ccp(cityGunBg:getContentSize().width,cityGunBg:getContentSize().height+5))
    cityGunBg:addChild(cityGunTitleBg)

    local nameLine1 = CCSprite:createWithSpriteFrameName("planeSkill_yellow.png")
    nameLine1:setPosition(ccp(0,cityGunTitleBg:getContentSize().height))
    cityGunTitleBg:addChild(nameLine1)
    local blendFunc = ccBlendFunc:new()
    blendFunc.src = GL_SRC_ALPHA
    blendFunc.dst = GL_ONE
    nameLine1:setBlendFunc(blendFunc)


    local nameLine2 = CCSprite:createWithSpriteFrameName("planeSkill_yellow.png")
    nameLine2:setPosition(ccp(cityGunTitleBg:getContentSize().width,0))
    cityGunTitleBg:addChild(nameLine2)
    local blendFunc = ccBlendFunc:new()
    blendFunc.src = GL_SRC_ALPHA
    blendFunc.dst = GL_ONE
    nameLine2:setBlendFunc(blendFunc)    

    nameLine1:setOpacity(0)
    nameLine2:setOpacity(0)

    local cityGunName = GetTTFLabel(getlocal("cityGunName"),24,true)
    cityGunName:setAnchorPoint(ccp(1,0.5))
    if cityGunName:getContentSize().width > cityGunTitleBg:getContentSize().width+20 then
      cityGunTitleBg:setScaleX(cityGunName:getContentSize().width/(cityGunTitleBg:getContentSize().width+20))
    end
    cityGunName:setPosition(ccp(cityGunTitleBg:getPositionX()-5,cityGunTitleBg:getPositionY()+cityGunTitleBg:getContentSize().height*0.5))
    cityGunBg:addChild(cityGunName)

    local fortPos = {ccp(271.5, 84.5),ccp(155, 73),ccp(72, 68.5)}
    local gunsPos = {ccp(208.5, 123),ccp(114.5, 105),ccp(48, 91.5)}
    local gunsFiredPos  = {ccp(246,100),ccp(135,90),ccp(62,82)}
    local gunsFiringPos = {ccp(183, 137),ccp(94.5, 116.5),ccp(35.5, 99.5)}
    local gunsTb = {}
    -- cityGunFireNums = 6
    local showNums,showNums2 = cityGunFireNums >3 and 3 or cityGunFireNums , cityGunFireNums > 3 and cityGunFireNums - 3 or nil
    if cityGunFireNums == 1 then--一发炮弹的时候 要一轮齐射
        showNums = 3
    end

    for i=1,3 do
      local fortPic = CCSprite:createWithSpriteFrameName("fort_"..i..".png")
      fortPic:setPosition(fortPos[i])
      cityGunBg:addChild(fortPic,1)

      local guns = CCSprite:createWithSpriteFrameName("guns_"..i..".png")
      guns:setPosition(gunsPos[i])
      cityGunBg:addChild(guns)
      gunsTb[i] = guns
    end
    -- cityGunBg:setScale(1.5)
    local function playShake()
        local shakeArr=CCArray:create()
        for i=1,5 do
          local dd=deviceHelper:getRandom()
          local rndx=15-(math.random(1,3)/100)*30+G_VisibleSizeWidth*0.7
          local rndy=15-(math.random(1,100)/100)*30+G_VisibleSizeHeight*0.65
          local moveTo=CCMoveTo:create(0.02,ccp(rndx,rndy))
          shakeArr:addObject(moveTo)
        end
        local function resetPos()
           cityGunBg:setPosition(ccp(G_VisibleSizeWidth*0.7,G_VisibleSizeHeight*0.65))
        end
        local funcall=CCCallFunc:create(resetPos)
        shakeArr:addObject(funcall)
        local shakeSeq=CCSequence:create(shakeArr)
        cityGunBg:runAction(shakeSeq)
    end
    local function gunningNow( )
          for i=1,showNums do
              local function gunFiring( )
                  local fire=CCParticleSystemQuad:create("public/gunFire.plist")
                  if fire then
                      fire:setAutoRemoveOnFinish(true)
                      fire:setPositionType(kCCPositionTypeFree)
                      fire:setPosition(gunsFiringPos[i])
                      fire:setScale(0.4-i*0.1)
                      cityGunBg:addChild(fire,10)
                  end
                  PlayEffect(audioCfg.tank_2)
                  playShake()
                  return fire
              end 
              local delayT2 = CCDelayTime:create(fireFixedT * i)--0.2*i
              local movTo   = CCMoveTo:create(0,gunsFiredPos[i])
              local fireCall = CCCallFunc:create(gunFiring)
              local movTo2  = CCMoveTo:create(0.4,gunsPos[i])
              local usedelayT = fireFixedT == 0 and 0.3 or 0--0.2 - 0.1*(i-1)
              local delayT3 = CCDelayTime:create(usedelayT)--0.5 - 0.2*(i-1)
              local arr     = CCArray:create()
              arr:addObject(delayT2)
              arr:addObject(movTo)
              arr:addObject(fireCall)
              arr:addObject(movTo2)
              arr:addObject(delayT3)
              local seq = CCSequence:create(arr)
              gunsTb[i]:runAction(seq)  
          end
          if showNums2 then
              for i=1,showNums2 do
                  local function gunFiring( )
                      local fire=CCParticleSystemQuad:create("public/gunFire.plist")
                      if fire then
                          fire:setAutoRemoveOnFinish(true)
                          fire:setPositionType(kCCPositionTypeFree)
                          fire:setPosition(gunsFiringPos[i])
                          fire:setScale(0.4-i*0.1)
                          cityGunBg:addChild(fire,10)
                      end
                      PlayEffect(audioCfg.tank_2)
                      playShake()
                      return fire
                  end 
                  local delayT2 = CCDelayTime:create(0.5 + fireFixedT * i)--0.2*i
                  local movTo   = CCMoveTo:create(0,gunsFiredPos[i])
                  local fireCall = CCCallFunc:create(gunFiring)
                  local movTo2  = CCMoveTo:create(0.4,gunsPos[i])
                  local usedelayT = fireFixedT == 0 and 0.3 or 0--0.2 - 0.1*(i-1)
                  local delayT3 = CCDelayTime:create(usedelayT)--0.5 - 0.2*(i-1)
                  local arr     = CCArray:create()
                  arr:addObject(delayT2)
                  arr:addObject(movTo)
                  arr:addObject(fireCall)
                  arr:addObject(movTo2)
                  arr:addObject(delayT3)
                  local seq = CCSequence:create(arr)
                  gunsTb[i]:runAction(seq)  
              end
          end
          local function destoryGuns( )
              coverDia:removeFromParentAndCleanup(true)
              cityGunBg:removeFromParentAndCleanup(true)
              spriteController:removePlist("public/cityGunBattleImage.plist")
              spriteController:removeTexture("public/cityGunBattleImage.png")
              spriteController:removePlist("public/plane/battleImage/battlesPlaneCommon1.plist")
              spriteController:removeTexture("public/plane/battleImage/battlesPlaneCommon1.png")
          end 
          local cccaldestory = CCCallFuncN:create(destoryGuns)
          local removeDelayT =  cityGunFireNums == 1 and 0.5 or 1.2
          if  cityGunFireNums > 3 then
              removeDelayT = 2.0
          end
          
          local delayT4      = CCDelayTime:create(removeDelayT)
          -- local movTo        = CCMoveTo:create(0.2,ccp(G_VisibleSizeWidth*1.8,G_VisibleSizeHeight*0.6))
          local scaleto      = CCScaleTo:create(0.2, 0.5)
          local arr          = CCArray:create()
          arr:addObject(delayT4)
          arr:addObject(scaleto)
          arr:addObject(cccaldestory)
          local seq = CCSequence:create(arr)
          cityGunBg:runAction(seq)

    end 
    local function visCall( )
        cityGunBg:setVisible(true)
    end
    local function titleCall( )

        local fadeIn = CCFadeIn:create(0)
        local fadeOunt = CCFadeOut:create(0.1)
        local delayT1 = CCDelayTime:create(0.3)
        local lineMovTo = CCMoveTo:create(0.2,ccp(cityGunTitleBg:getContentSize().width,nameLine1:getPositionY()))
        local acArrL1 = CCArray:create()
        acArrL1:addObject(delayT1)
        acArrL1:addObject(fadeIn)
        acArrL1:addObject(lineMovTo)
        acArrL1:addObject(fadeOunt)
        local seqL1 = CCSequence:create(acArrL1)

        local fadeIn2 = CCFadeIn:create(0)
        local fadeOunt2 = CCFadeOut:create(0.1)
        local delayT2 = CCDelayTime:create(0.3)
        local lineMovTo2 = CCMoveTo:create(0.2,ccp(0,nameLine2:getPositionY()))
        local acArrL2 = CCArray:create()
        acArrL2:addObject(delayT2)
        acArrL2:addObject(fadeIn2)
        acArrL2:addObject(lineMovTo2)
        acArrL2:addObject(fadeOunt2)
        local seqL2 = CCSequence:create(acArrL2)

        nameLine1:runAction(seqL1)
        nameLine2:runAction(seqL2)
        
    end 
    local visCallF   = CCCallFuncN:create(visCall) 
    local scaleto = CCScaleTo:create(0.1, 1.3)
    local scaleto2 = CCScaleTo:create(0.1, 1)
    local delayT  = CCDelayTime:create(addS)
    local delayT5 = CCDelayTime:create(0.1)
    local showTitleCall = CCCallFunc:create(titleCall)
    local delayT6 = CCDelayTime:create(0.5)
    local cccal   = CCCallFuncN:create(gunningNow)
    local arr     = CCArray:create()
    arr:addObject(delayT)
    arr:addObject(visCallF)
    arr:addObject(scaleto)
    arr:addObject(scaleto2)
    arr:addObject(delayT5)
    arr:addObject(showTitleCall)
    arr:addObject(delayT6)
    arr:addObject(cccal)
    local seq = CCSequence:create(arr)
    cityGunBg:runAction(seq)
end

function battleScene:burstNow(curBeAttackedTank,burstData,burstPos,newDeTime)--爆破军徽被辐射的坦克部队
      if not burstPos then
        print "~~~~~~ burstPos is nil ~~~~~~~~"
        do return end
      end
      -- print("burstNow~~~~~~~~~~")
      local burstDataNum = SizeOfTable(burstData)
      local aimTanks = curBeAttackedTank.area==1 and self.allT1 or self.allT2
      local bombPos=burstPos
      local beBombedPosTb = {{2,4},{1,3,5},{2,6},{1,5},{2,4,6},{3,5}}
      local beBombedPos = beBombedPosTb[bombPos]
      local burstIndex=1
      for ii,jj in pairs(aimTanks) do
          local beAttTank=jj
          if beAttTank and beAttTank.isWillDie==false and beAttTank.isSpace==false then
              for posk,posv in pairs(beBombedPos) do
                  if burstData[burstIndex] and beAttTank.container and beAttTank.pos and posv and tonumber(beAttTank.pos)==tonumber(posv) then
                      local burstDataStr = burstData[burstIndex]
                      local bData = Split(burstDataStr,"-")
                      if bData and SizeOfTable(bData)>0 then
                          local lifesub   = tonumber(bData[1]) or 0
                          local dalayTime = newDeTime or 2.8--1+mm*0.4+1.3
                          local useZero   = burstIndex == burstDataNum and 0 or nil
                          --10165 用于被攻击方显示冒烟效果的目的，没有其他意义
                          beAttTank:beAttacked(dalayTime,10165,lifesub,burstDataStr,nil,nil,nil,nil,nil,nil,false,nil,useZero)
                      end
                      burstIndex=burstIndex+1
                  end
              end
          end
      end
end

function battleScene:beRealAttackSkillShow(beAttackedTank,beAttackerData,delayT)
    if not beAttackerData then
        do return end
    end

    local thisShowSkillTb = {CH=1,ch=1}--需要在攻击前播放的效果
    if beAttackerData then
      for eindex=1,#beAttackerData do
          if beAttackerData[eindex] and thisShowSkillTb[beAttackerData[eindex]] then 
              local function showSkill( )
                  beAttackedTank:animationCtrlByType(beAttackerData[eindex])  
              end
              local det = CCDelayTime:create(delayT * G_battleSpeed)
              local callFunc = CCCallFuncN:create(showSkill)
              local acArr = CCArray:create()
              acArr:addObject(det)
              acArr:addObject(callFunc)
              local seq=CCSequence:create(acArr)
              self.container:runAction(seq) 
              return nil
          else
              return beAttackerData
          end
      end
    end
end

-- function battleScene:touchEvent(fn,x,y,touch)
--     if fn=="began" then
--         if self.touchEnable==false then--or SizeOfTable(self.touchArr)>=2 then
--              return 0
--         end
--         if y >= G_VisibleSizeHeight - 140 then --self.upSlideSP:getPositionY() then
--           self.movStY = y
--           self.isMoved = false
--         else
--           self.movStY = 0
--           self.isMoved = nil
--         end
--         return 1
--     elseif fn=="moved" then
--         if self.touchEnable==false then
--              do return end
--         end
--         if self.isMoved == false then
--              self.isMoved = true
--         end
--     elseif fn=="ended" then
--        if self.touchEnable==false then
--              do return end
--        end
--        -- print("self.slideMovEnd ----->",self.slideMovEnd)
--        if self.isMoved==true and self.slideMovEnd then
--             local slideSpPosY = self.upSlideSP:getPositionY()
--             if y - self.movStY >= 30 and slideSpPosY <= G_VisibleSizeHeight then --向上
--                 self.slideMovEnd = false
--                 self:moveUpSlide(true)
--             elseif self.movStY - 30 >= y and slideSpPosY > G_VisibleSizeHeight then --向下
--                 self.slideMovEnd = false
--                 self:moveUpSlide(false)
--             end
--        end

--     else
--     end
-- end

-- function battleScene:moveUpSlide(movUp)
--     local curPosX,curPosY,curHeight = self.upSlideSP:getPositionX(),self.upSlideSP:getPositionY(),self.upSlideSP:getContentSize().height
--     if movUp then
--         local mov = CCMoveTo:create(0.5,ccp(curPosX,curPosY+curHeight))
--         local function reSetMovEnd( )
--             self.slideMovEnd = true
--         end 
--         local ccFunc = CCCallFuncN:create(reSetMovEnd)
--         local acArr = CCArray:create()
--         acArr:addObject(mov)
--         acArr:addObject(ccFunc)
--         local seq = CCSequence:create(acArr)
--         self.upSlideSP:runAction(seq)
--     else
--         local mov = CCMoveTo:create(0.5,ccp(curPosX,curPosY-curHeight))
--         local function reSetMovEnd( )
--             self.slideMovEnd = true
--         end 
--         local ccFunc = CCCallFuncN:create(reSetMovEnd)
--         local acArr = CCArray:create()
--         acArr:addObject(mov)
--         acArr:addObject(ccFunc)
--         local seq = CCSequence:create(acArr)
--         self.upSlideSP:runAction(seq)
--     end
-- end

function battleScene:dispose()
    eventDispatcher:dispatchEvent("battle.close",{win=(self.isWin==1)})
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
     self.endBtnItemMenu=nil
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
    self.alienBattleData=nil
    self.heroData=nil
    self.heroSpTb={}
    self.supperWeaponSpTb={}
    self.isPickedTankTb={}
    self.isShowHero=false
    self.isShowSW =false
    self.isNewBufShow =true
    self.landform=nil
    self.battleType=nil
    self.acData=nil
    self.winCondition=nil
    self.swId=nil
    self.ecId=nil
    self.robData=nil
    self.zOrder=nil
    G_releaseHeroImage()
    self.firstValue1=1000
    self.firstValue2=1000
    self.upgradeTanks={}
    self.levelTb={}
    self.challenge=0
    self.bfSkill =nil
    self.bfSkilledTb={}
    self.rebel=nil
    self.shipboss=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ship/tankRestraint.plist")
    if G_isCompressResVersion()==true then
        CCTextureCache:sharedTextureCache():removeTextureForKey("ship/tankRestraint.png")
    else
        CCTextureCache:sharedTextureCache():removeTextureForKey("ship/tankRestraint.pvr.ccz")
    end
    CCTextureCache:sharedTextureCache():removeTextureForKey("scene/cityR1_mi.jpg")
    CCTextureCache:sharedTextureCache():removeTextureForKey("scene/cityR2_mi.jpg")
    spriteController:removePlist("public/emblem/emblemImage.plist")
    spriteController:removeTexture("public/emblem/emblemImage.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemBattleBg1.png")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemBattleBg2.png")
    if platCfg.platCfgNewTypeAddTank then
      self:removeRes()
    end
    self.addResPathTb=nil

    self.fjFireIndex = 0
    self.fjFireIndexTotal = 0
    self.fjNextFire = 0
    self.fjIsFire = false
    for k,v in pairs(self.allPlane) do
        v:dispose()
        v=nil
    end
    self.allPlane     = {}
    self.skillCD      = {}--技能动画延时的回合数
    self.speedShowArr = {}
    self.upSlideSP    = nil
    self.aiTb         = nil
    self.aiBattleData = nil
    self.aiIsBlank    = {}
    self.skinTb       = nil
    self.realDefBufTb = nil
    self.airShipTb    = nil
    self.airShipSpTb  = nil
end


