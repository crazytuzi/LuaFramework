
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



require "luascript/script/game/scene/gamedialog/activityAndNote/acEatChickenTank"
require "luascript/script/game/scene/tank/plane"
require "luascript/script/game/scene/tank/tankBufSmallDialog"
acEatChickenBattleScene={
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
  leftMovDis=ccp(-938,-422),
  rightMovDis=ccp(690,342),
  
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
  alienBattleData=nil,
  heroSpTb={},
  supperWeaponSpTb={},
  isPickedTankTb={},
  heroData=nil,
  isShowHero=false,
  isShowSW =false,
  isNewBufShow=true,
  firstValue1=1000,
  firstValue2=1000,
  is10074Skill=false, --10074 坦克技能专用
  is10094Skill=false, --10094 坦克技能专用
  spcSkill=nil, --特殊技能，为了异性科技加的
  bfSkill, --开战前的BUF
  bfSkilledTb={}, --已使用过的 开战前的BUF
  mapscale=1,
  mapreletivepos={ccp(1024,512),ccp(2048,1024)},--地图相对拼接相对位置
  l_mappos={ccp(-320,-5)},--左下角地图初始位置
  r_mappos={ccp(-1950,-1026+G_VisibleSizeHeight*0.5)},--右上角初始位置
  
  mapmoveBy={ccp(-1024,-513),ccp(1024,512)},--地图移动(左下，右上)--2048 1026
  landform=nil, --地形
  battleType=nil,--战斗类型，是哪个战斗场景,1:区域战,2:超级武器关卡战斗,3:超级武器抢夺碎片,4:平台战战报,5:军事演习,6:群雄争霸,7异星矿场,8将领装备
  acData=nil, --活动数据，acType区分活动类型，{acType="",...}
  winCondition=nil, --超级武器关卡过关条件
  swId=nil, --超级武器关卡id
  robData=nil, --超级武器抢夺
  upgradeTanks={}, --生成的精锐坦克列表
  levelTb={}, -- 关卡部队信息
  challenge=0, -- 攻打关卡能再次攻打 1：能 0：不能
  ecId=nil,--装备探索id
  closeResultPanelHandler=nil,--关闭结算面板回调函数
  zOrder=nil,
  rebel=nil, --叛军数据
  warSpeed=0.5,
  speedShowArr = {},

  fjFireIndex = 0,--飞机开火索引
  fjFireIndexTotal = 0,--飞机开火索引总数
  fjNextFire = 0,--下一次开火的是哪边的飞机  1:左边 2:右边
  fjIsFire = false,
  allPlane = {},--第7战斗位：左右两架飞机
  firstData = {} --原始数据，用于战斗回放
}



function acEatChickenBattleScene:init()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/tankRestraint.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/emblem/emblemImage.plist")
    spriteController:addTexture("public/emblem/emblemImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    if G_isIphone5()==true then
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

    self.upSlideSP = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    self.upSlideSP:setContentSize(CCSizeMake(G_VisibleSizeWidth,140))
    self.upSlideSP:setOpacity(0)
    self.upSlideSP:setAnchorPoint(ccp(0.5,1))
    self.upSlideSP:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight))
    self.container:addChild(self.upSlideSP,22)

    --战斗双方信息显示

    --
    self.container:setTouchEnabled(true)
    self.container:setBSwallowsTouches(true) --屏蔽底层响应
    self.container:setTouchPriority(-81)
    self.container:setContentSize(G_VisibleSize)
    local function tmpHandler(...)
       -- return self:touchEvent(...)
    end
    -- self.container:registerScriptTouchHandler(tmpHandler,false,-81,false)
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
    
    
    
    --[[
    self.r_grossLayer=CCSprite:create(self.bgName2);
    self.r_grossLayer:setContentSize(CCSizeMake(1475,1207))
    self.r_grossLayer:setScale(1.44)
    self.r_grossLayer:setAnchorPoint(ccp(0,0))
    ]]
    
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

     --[[
     self.l_grossLayer = CCSprite:create(self.bgName1);
     --self.l_grossLayer:setContentSize(CCSizeMake(1459,1158))
     self.l_grossLayer:setScale(1.78)
     self.l_grossLayer:setAnchorPoint(ccp(0.5,0.5))
     ]]

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

   
    --self.l_grossLayer:setAnchorPoint(ccp(0,0));
    --self.l_grossLayer:setPosition(ccp(486,384));
    
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

    local addPosYy = {15,15,5,10,15,15}
    for i=1,6 do
      local chickenSp = CCSprite:createWithSpriteFrameName("chickBtn_1.png")
      chickenSp:setPosition(ccp(fj:getContentSize().width*0.16*i,fj:getContentSize().height*0.5+addPosYy[i]))
      fj:addChild(chickenSp)
    end
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
    
    --


    self:moveMap()  --地图移动
    
    -- self:vsMoveAction() --VS 动画
    
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

              if self.isBattleEnd==false then
                  self.isBattleEnd=true
                  -- self:showResuil()
              end
            end
      --self:stopAction()
        end

        self.endBtnItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",endFunc,nil,getlocal("skipPlay"),30)
        self.endBtnItem:setPosition(20,0)
        self.endBtnItem:setScale(0.8)
        self.endBtnItem:setAnchorPoint(CCPointMake(0,0))
        self.endBtnItemMenu = CCMenu:createWithItem(self.endBtnItem)
        self.endBtnItem:setVisible(false)
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

    self:initTitleAndBg()
end
function acEatChickenBattleScene:initTitleAndBg( )--
    local titleBg =LuaCCScale9Sprite:createWithSpriteFrameName("singleTitleBg.png",CCRect(173,41,1,1),function ()end)
    titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,80))
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight))
    self.container:addChild(titleBg,99)

    local titleStr = GetTTFLabel(getlocal("activity_qmcj_title"),32,"Helvetica-bold")
    titleStr:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(titleStr)


    local function closeCall()
        PlayEffect(audioCfg.mouseClick)   
        print("close????????") 
        return self:showResuil()
     end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",closeCall,nil,nil,nil);
      closeBtnItem:setPosition(0, 0)
      closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-322)
    closeBtn:setPosition(ccp(titleBg:getContentSize().width-closeBtnItem:getContentSize().width,titleBg:getContentSize().height-closeBtnItem:getContentSize().height))
    titleBg:addChild(closeBtn)
end

--初始化后台返回的战斗数据
function acEatChickenBattleScene:initData(data,closeResultPanelHandler,zOrder,layerNum,rewardTb)
    self.layerNum = layerNum
    self.rewardTb = rewardTb
    self.rewardTbNums = SizeOfTable(rewardTb)
    self.firstData = data
    -- self.oldG_battleSpeed = G_battleSpeed
    -- G_battleSpeed = 0.2
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
        self.bgName1="scene/battles_1.jpg"
        self.bgName2="scene/battles_1.jpg"
    end

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
    data.data = {}
    data.data.report = G_Json.decode('{"t":[[["a10074",1],["a20055",1],["a10075",1],["a10084",1],["a20155",1],["a20125",1]],[["a10008",1],["a10038",1],["a10008",1],["a10018",1],["a10028",1],["a10018",1]]],"h":[],"p":[],"d":{"d":[["25-5","25-5","25-5"],["112-4-1","112-2-1","56-4","63-5","63-5","63-4"],["25-5","25-5","25-5"],["173-3"],["78-4","88-5"],["173-3"]],"se":[0,0]},"r":1}')--假数据使用，平常不用 用于坦克战斗数据表现使用


    self.battleData={{"112-4-1","112-2-1","56-4","63-5","63-5","63-4"}}---(data.data.report.d.d==nil and data.data.report.d or data.data.report.d.d)
    self.spcSkill=data.data.report.d.ab
    self.emblemData = data.data.report.d.se--军徽系统BUF
    self.bfSkill =G_clone(data.data.report.d.bfs) --开战前的BUF（特效显示等等）
    self.superWeapon=data.data.report.d.sw
    self.upgradeTanks=data.data.report.upgradeTanks or {} --生成的精锐坦克列表
    self.levelTb=data.levelTb -- 关卡部队信息（再打一次关卡需要）
    self.challenge=data.data.report.challenge or 0

    self.fjfdTb = data.data.report.d.fd -- 飞机战斗数据


    self.fjFireIndexTotal = self.fjfdTb and #self.fjfdTb or 0
    self.fjTb =data.data.report.d.fj--(用于飞机图片使用) ,{{"p3","1313"},{"p4","1313"}}:1313  ---飞机相关数据 用于转换出技能名称
    self.skillCD = {["be"]=1,["bf"]=1}--技能动画延时的KEY和回合数[除非策划要求修改，否则该表内的数据不要动，只用作判断即可,判断后台是否传回要求取消延时效果的字段


    self.playerData=data.data.report.p
    self.battleReward=data.data.report.r
    self.heroData=data.data.report.h

    self.addResPathTb={}

    if platCfg.platCfgNewTypeAddTank then
      for k,v in pairs(data.data.report.t[1]) do
        if v[1] then
           local tid = tonumber(RemoveFirstChar(v[1]))
           self:addRes(tid)
        end
      end
      for k,v in pairs(data.data.report.t[2]) do
        if v[1] then
           local tid = tonumber(RemoveFirstChar(v[1]))
           self:addRes(tid)
        end
      end
    end

    self:addRes2()

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
    self:isPickedTankId(data.data.report.t[1],data.data.report.t[2])
    
    self:startBattle(data.data.report.t[1],data.data.report.t[2],self.fjTb)

end
function acEatChickenBattleScene:isPickedTankId(t1,t2 )
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

function acEatChickenBattleScene:addRes(tid)
    if tid~=10001 and tid~=50001 and tid~=99999 and tid~=99998 then
        local tid= GetTankOrderByTankId(tid)
        local str = "ship/newTank/t"..tid.."newTank.plist"
        local str2 = "ship/newTank/t"..tid.."newTank.png"

        if self.addResPathTb==nil then
            self.addResPathTb={}
        end
        local tb = {str,str2}
        table.insert(self.addResPathTb,tb)
        spriteController:addPlist(str)
        spriteController:addTexture(str2)
    end
    
end

function acEatChickenBattleScene:addRes2()
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
    if self.fjTb then
        spriteController:addPlist("public/plane/battleImage/battlesPlaneCommon1.plist")
        spriteController:addTexture("public/plane/battleImage/battlesPlaneCommon1.png")
        spriteController:addPlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
        spriteController:addTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
        spriteController:addPlist("public/plane/battleImage/battlePlaneSkillActionImage.plist")
        spriteController:addTexture("public/plane/battleImage/battlePlaneSkillActionImage.png")
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function acEatChickenBattleScene:removeRes()
    if self.addResPathTb and SizeOfTable(self.addResPathTb)>0 then
        for k,v in pairs(self.addResPathTb) do
            spriteController:removePlist(v[1])
            spriteController:removeTexture(v[2])
        end
    end
    spriteController:removePlist("public/radiationImage.plist")
    spriteController:removeTexture("public/radiationImage.png")
    spriteController:removePlist("public/burstEffect.plist")
    spriteController:removeTexture("public/burstEffect.png")
    spriteController:removePlist("public/emblemSkillBg.plist")
    spriteController:removeTexture("public/emblemSkillBg.png")
    spriteController:removePlist("public/inBattleUsedBtn.plist")
    spriteController:removeTexture("public/inBattleUsedBtn.png")
    if self.fjTb then
        spriteController:removePlist("public/plane/battleImage/battlesPlaneCommon1.plist")
        spriteController:removeTexture("public/plane/battleImage/battlesPlaneCommon1.png")
        spriteController:removePlist("public/plane/battleImage/battlesPlaneShellsImage.plist")
        spriteController:removeTexture("public/plane/battleImage/battlesPlaneShellsImage.png")
        spriteController:removePlist("public/plane/battleImage/battlePlaneSkillActionImage.plist")
        spriteController:removeTexture("public/plane/battleImage/battlePlaneSkillActionImage.png")
    end
    -- CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
end

--派坦克出战 t1:右上角  t2:左下角   格式:{[1]={1,13},[3]={2,190},[4]={3,56}}  {[位置索引]={船类型编号1-20,船数量}}
function acEatChickenBattleScene:startBattle(t1,t2,fjTb)
    self:init()
    for k=1,6 do
        if t1[k]~=nil and #t1[k]>0 then
            if t1[k][2]>0 then
                local tankSp=acEatChickenTank:new(t1[k][1],t1[k][2],k,1,false,nil,self)
                self.allT1[k]=tankSp
            else
                local tankSp=acEatChickenTank:new("a10001",1,k,1,true,nil,self)
                self.allT1[k]=tankSp
            end
        else
                local tankSp=acEatChickenTank:new("a10001",1,k,1,true,nil,self)
                self.allT1[k]=tankSp

        end
        if t2[k]~=nil and  #t2[k]>0 then
            if t2[k][2]>0 then
                local tankSp=acEatChickenTank:new(t2[k][1],t2[k][2],k,2,false,nil,self)
                self.allT2[k]=tankSp
            else
                local tankSp=acEatChickenTank:new("a10001",1,k,2,true,nil,self)
                self.allT2[k]=tankSp
            end
        else
                local tankSp=acEatChickenTank:new("a10001",1,k,2,true,nil,self)
                self.allT2[k]=tankSp
            
        end
        
    end

    self.startFire=true
end
function acEatChickenBattleScene:moveMap()
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




function acEatChickenBattleScene:readyToEnd(  )
    
    local function battleResult()
        if self.isBattleEnd==false then
            self.isBattleEnd=true
            -- self:showResuil()
        end
        --self:stopAction()
    end
    
    local delayTime=CCDelayTime:create(3 * G_battleSpeed) --延时两秒再弹出结束面板
    local  delayfunc=CCCallFuncN:create(battleResult)
    local  seq=CCSequence:createWithTwoActions(delayTime,delayfunc)
    self.container:runAction(seq)
end


function acEatChickenBattleScene:cleanCurHHSkill(  )--清除本回合后台返回的告知的消除技能特效
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

function acEatChickenBattleScene:fireTick(kzhzParm)
    --==========以下是空中轰炸==========
    local kzhz,fuSheBo,cityGun=nil,nil,nil
    if kzhzParm~=nil and kzhzParm==true then
        kzhz=true
    end
    local cdData=self.battleData[self.fireIndex]
    --==========以上是空中轰炸==========
    local  battleEnd=false
    if self.nextFire==0 then
         -- if self.playerData[1][3]==1 then --左边先手
         --        self.nextFire=1
         -- else --右边先手
         --        self.nextFire=2
         -- end
         self.nextFire=2
         -- print("self.nextFire----->",self.nextFire)
         self.lFireIndex=1
         self.rFireIndex=1
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
    local fireTank=nil  --当前开火的坦克
    if kzhz==nil then
            if self.nextFire==1 then
                   for k=self.lFireIndex,6 do
                       if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                            fireTank=self.allT1[k]
                            self.lFireIndex=k+1
                            do break end
                       end
                   end
                   self.nextFire=2
                   if fireTank==nil then --左方 本轮没有要开火的坦克了
                           self.lFireIndex=7 
                           for k=self.rFireIndex,6 do  --右方开火
                               if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                                    fireTank=self.allT2[k]
                                    self.rFireIndex=k+1
                                    do break end
                               end
                           end
                           if fireTank==nil then  --双方 本轮都没有要开火的坦克了
                               if  self:isBattleFinished() then
                                    battleEnd=true  --结束战斗
                               else
                                      self.nextFire=0  --重新开始一轮交火
                                      self.hhNum=self.hhNum + 1
                                      self:fireTick()  --立即开始一轮交火
                                      self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
                                   
                                    do return end
                               end
                           end
                           self.nextFire=2 
                   end
            elseif self.nextFire==2 then
                   for k=self.rFireIndex,6 do
                       if self.allT2[k]~=nil and self.allT2[k].isSpace==false then
                            fireTank=self.allT2[k+1]
                            self.rFireIndex=k+1
                            do break end
                       end
                   end 
            
                   self.nextFire=2
                    if fireTank==nil then --右方 本轮没有要开火的坦克了
                           self.rFireIndex=7
                           for k=self.lFireIndex,6 do  --左方开火
                               if self.allT1[k]~=nil and self.allT1[k].isSpace==false then
                                    fireTank=self.allT1[k]
                                    self.lFireIndex=k+1
                                    do break end
                               end
                           end
                           if fireTank==nil then  --双方 本轮都没有要开火的坦克了
                               if  self:isBattleFinished() then
                                    battleEnd=true  --结束战斗
                               else
                                      self.nextFire=0  --重新开始一轮交火
                                      self.hhNum=self.hhNum+1
                                      self:fireTick()  --立即开始一轮交火
                                      self.hhLb:setString(getlocal("battle_Count",{self.hhNum}))
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

    --local btdata
    --local tnextDData
    local isAttackSelf=false
    local islunkong=false

    if self.hhNum%2==0 and tankCfg[fireTank.tankId].weaponType=="18" then  --b型火箭车 单数轮次数开火
           --这里添加火箭车效果 fireTank
           fireTank:animationCtrlByType("I")

    else


          local btdata=self.battleData[self.fireIndex] --此次开火的数据
          -- print("~~~~~~~~~>11111")
          -- G_dayin(btdata)
          -- print("~~~~~~~~~>111111")
          self.fireIndex=self.fireIndex+1
          local burstData={}
          local tnextDData=self.battleData[self.fireIndex]
          if tnextDData~=nil then
               if tnextDData[1]=="AZ" then --军徽爆破技能，6辆歼击车打死目标后，爆炸伤害，后面有可能连击
                  for k,v in pairs(tnextDData) do
                      if k>1 then
                          table.insert(burstData,v)
                      end
                  end
                  tnextDData=self.battleData[self.fireIndex+1]
               end
               if tnextDData and tnextDData[1]=="$" then --本轮攻击要双击
                  self.is10074Skill=true
                  self.is10094Skill=true
               end
          end

          isAttackSelf=false
          if btdata==nil then
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
                                              self:fireTick()
                                          end
                                      else            
                                                      local curAttNums = 6
                                                      local isBKSkill = false
                                                      if islunkong==false then
                                                          if (tankCfg[fireTank.tankId].abilityID and tankCfg[fireTank.tankId].abilityID=="bk") or acEatChickenBattleScene:hasSpcSkil(fireTank.area,"bk","a"..fireTank.tankId) then
                                                              curAttNums = SizeOfTable(btdata)
                                                              isBKSkill = true
                                                          end
                                                          if isBKSkill then
                                                              curBeAttackNums = curAttNums
                                                              fireTank:setFire(0.02,curAttNums)
                                                          else
                                                              curBeAttackNums = (tankCfg[fireTank.tankId].type=="8" and (tankCfg[fireTank.tankId].abilityID == nil or (tankCfg[fireTank.tankId].abilityID and tankCfg[fireTank.tankId].abilityID~="i") or acEatChickenBattleScene:hasSpcSkil(fireTank.area,"i","a"..fireTank.tankId) == false )) and 6 or SizeOfTable(btdata)
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
                                                                   -- print("curBeAttackedTank.isWillDie",curBeAttackedTank.isWillDie)
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
                                                                           -- curBeAttackedTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                        else
                                                                           -- fireTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                        end
                                                                        
                                                                      end
                                                                  end
                                                                      if len>1 and  (curBeAttackedTank.tankId==10134 or  curBeAttackedTank.tankId==10135 or curBeAttackedTank.tankId==10133) then
                                                                          curBeAttackedTank.isAtamaTankAbility=true --触发阿塔玛坦克防御技能
                                                                      end
                                                                      if islunkong==false then

                                                                            --军徽爆破技能
                                                                            if burstData and SizeOfTable(burstData)>0 then
                                                                                local burstDataNum = SizeOfTable(burstData)
                                                                                curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                                -- print("curBeAttackNums------>",curBeAttackNums)
                                                                                curBeAttackedTank:beAttacked(1+mm*0.4,fireTank.tid,23,retData==nil and btdata[mm] or retData,nil,beAttackerData,fireTank.isG,nil,nil,true,nil,nil,nil)

                                                                                local aimTanks = curBeAttackedTank.area==1 and self.allT1 or self.allT2
                                                                                local bombPos=curBeAttackedTank.pos
                                                                                local beBombedPosTb = {{2,4},{1,3,5},{2,6},{1,5},{2,4,6},{3,5}}
                                                                                local beBombedPos = beBombedPosTb[bombPos]
                                                                                local burstIndex=1
                                                                                for ii,jj in pairs(aimTanks) do
                                                                                    local beAttTank=jj
                                                                                    if beAttTank and beAttTank.isWillDie==false and beAttTank.isSpace==false then
                                                                                        
                                                                                        
                                                                                        for posk,posv in pairs(beBombedPos) do
                                                                                            if burstData[burstIndex] and beAttTank.container and beAttTank.pos and posv and tonumber(beAttTank.pos)==tonumber(posv) then
                                                                                                local burstDataStr=burstData[burstIndex]
                                                                                                local bData=Split(burstDataStr,"-")
                                                                                                if bData and SizeOfTable(bData)>0 then
                                                                                                    local lifesub=tonumber(bData[1]) or 0
                                                                                                    local dalayTime=1+mm*0.4+1.1
                                                                                                    local useZero = burstIndex == burstDataNum and 0 or nil
                                                                                                    beAttTank:beAttacked(dalayTime,beAttTank.tid,lifesub,burstDataStr,nil,nil,nil,nil,nil,nil,false,nil,useZero)
                                                                                                end
                                                                                                burstIndex=burstIndex+1
                                                                                            end
                                                                                        end
                                                                                    end
                                                                                end
                                                                            else
                                                                                curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                                curBeAttackedTank:beAttacked(1+mm*0.4,fireTank.tid,23,retData==nil and btdata[mm] or retData,nil,beAttackerData,fireTank.isG,nil,nil,nil,nil,nil,curBeAttackNums)
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
                                                              if tankCfg[fireTank.tankId].type=="8" then  --火箭炮特殊处理
                                                                  
                                                                  for tsk=1,curAttNums do
                                                                      -- print("btdata[tsk]........",btdata[tsk],tsk,fireTank.tankId)
                                                                      if islunkong==true and btdata[tsk] ==nil then

                                                                        do break end
                                                                      end
                                                                      if (tankCfg[fireTank.tankId].abilityID~=nil and tankCfg[fireTank.tankId].abilityID=="i") or acEatChickenBattleScene:hasSpcSkil(fireTank.area,"i","a"..fireTank.tankId) then --沙暴火箭炮

                                                                            if btdata[tsk]==nil then
                                                                                  do break end
                                                                            end

                                                                            local attackerData,beAttackerData,retData=self:checkAnimEffectByData(btdata[tsk],fireTank)
                                                                            if islunkong ==true then
                                                                                -- fireTank:animationCtrlByType(attackerData[1])
                                                                                do break end
                                                                            end
                                                                            if attackerData~=nil then
                                                                                for eindex=1,#attackerData do
                                                                                      -- fireTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                                end
                                                                            end
                                                                            for sbhj=1,6 do

                                                                                 if beAttackedTanks[dataID]~=nil then
                                                                                     curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                                     local retLeftNum=beAttackedTanks[dataID]:beAttacked(1+tsk*0.1,fireTank.tid,23,retData==nil and btdata[tsk] or retData,nil,beAttackerData,nil,nil,nil,nil,nil,nil,curBeAttackNums)
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
                                                                                -- fireTank:animationCtrlByType(attackerData[1])
                                                                                do break end
                                                                            end
                                                                            if attackerData~=nil then
                                                                                for eindex=1,#attackerData do
                                                                                      -- fireTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                                end
                                                                            end
                                                                            for sbhj=1,6 do
                                                                                 if beAttackedTanks[dataID]~=nil then
                                                                                     curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                                     local retLeftNum=beAttackedTanks[dataID]:beAttacked(0.8+tsk*0.12,fireTank.tid,23,retData==nil and btdata[tsk] or retData,nil,beAttackerData,nil,nil,nil,nil,nil,nil,curBeAttackNums)
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
                                                                                    -- fireTank:animationCtrlByType(attackerData[1])
                                                                                    do break end
                                                                                  end
                                                                                  if attackerData~=nil then

                                                                                      for eindex=1,#attackerData do
                                                                                          -- fireTank:animationCtrlByType(attackerData[#attackerData+1-eindex])
                                                                                      end
                                                                                  end
                                                                                  curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                                  
                                                                                  local useChicken = self.rewardTbNums > 0  and true or false
                                                                                  self.rewardTbNums = self.rewardTbNums - 1
                                                                                  beAttackedTanks[dataID]:beAttacked(1+tsk*0.1,fireTank.tid,23,retData==nil and btdata[dataID] or retData,nil,beAttackerData,nil,nil,nil,nil,nil,nil,curBeAttackNums,nil,useChicken,self.rewardTb,tsk)

                if tsk == SizeOfTable(btdata) then
                    -- local delayT = CCDelayTime:create(1 + SizeOfTable(btdata) *0.1 )
                    -- local function tickCall()
                    --   print("fastTick")
                    --   self:mapShake(1)
                    --   self:fastTick()   
                    -- end
                    -- local arr = CCArray:create()
                    -- local callFunc=CCCallFunc:create(tickCall)
                    -- arr:addObject(delayT)
                    -- arr:addObject(callFunc)
                    -- local seq = CCSequence:create(arr)
                    -- self.container:runAction(seq)

                end
                if self.rewardTb[tsk] then

                     local useItem,icon = self.rewardTb[tsk],nil
                     if useItem.key  then
                          icon = G_getItemIcon(useItem,100,nil,nil,nil,nil,nil,nil,nil,nil,true)
                     else
                          icon = CCSprite:createWithSpriteFrameName(useItem.pic)
                     end
                     icon:setOpacity(0)
                     icon:setVisible(false)
                     icon:setScale(80/icon:getContentSize().width)
                     icon:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.58))
                     self.container:addChild(icon,99)
                     local function callBack()
                       icon:setVisible(true)
                     end
                     local function callBack2()
                       icon:setVisible(false)
                     end
                     local delay1 = CCDelayTime:create(2+tsk*0.3)
                     local callFunc=CCCallFunc:create(callBack)
                     local fadeIn = CCFadeIn:create(0)
                     local delay = CCDelayTime:create(0.2)
                     local fadeOut = CCFadeOut:create(0.2)
                     local callFunc2=CCCallFunc:create(callBack2)
                     local moveto = CCMoveTo:create(0.2,ccp(icon:getPositionX(),icon:getPositionY()+150))
                     -- local seq2=CCSequence:createWithTwoActions(fadeOut,moveto)
                     local arr = CCArray:create()
                     arr:addObject(delay1)
                     arr:addObject(callFunc)
                     arr:addObject(fadeIn)
                     arr:addObject(delay)
                     arr:addObject(moveto)
                     arr:addObject(fadeOut)
                     arr:addObject(callFunc2)
                     -- arr:addObject(seq2)
                      local seq=CCSequence:create(arr)
                      icon:runAction(seq)


                      local killTimesStr = GetTTFLabel(tsk,80,"Helvetica-bold")
                      killTimesStr:setVisible(false)
                      self.container:addChild(killTimesStr,98)
                      killTimesStr:setPosition(ccp(80,G_VisibleSizeHeight*0.77 + 10))

                      local killTimesStr2 = GetTTFLabel(tsk,80,"Helvetica-bold")
                      killTimesStr:addChild(killTimesStr2)
                      killTimesStr2:setPosition(getCenterPoint(killTimesStr))


                      local delay11 = CCDelayTime:create(2+tsk*0.3)
                      -- local moveto11 = CCMoveTo:create(0.2,ccp(killTimesStr:getPositionX() + 350,killTimesStr:getPositionY()))
                      local delay12 = CCDelayTime:create(0.3)
                      local function callBack22()
                        if SizeOfTable(self.rewardTb) < 7 then
                          if tsk < SizeOfTable(self.rewardTb) then
                            killTimesStr:setVisible(false)
                          end
                        else
                            if tsk < 6 then
                              killTimesStr:setVisible(false)
                            end
                        end
                      end
                      local callFunc22=CCCallFunc:create(callBack22)
                      local function callBack21()
                        killTimesStr:setVisible(true)
                      end
                      local callFunc21=CCCallFunc:create(callBack21)
                      local arr11 = CCArray:create()
                      arr11:addObject(delay11)
                      arr11:addObject(callFunc21)
                      arr11:addObject(delay12)
                      arr11:addObject(callFunc22)
                      local seq11 = CCSequence:create(arr11)
                      killTimesStr:runAction(seq11)

                      if self.killStr == nil then
                        local needTimes = SizeOfTable(self.rewardTb) > 6 and 6 or SizeOfTable(self.rewardTb)
                        self.blackBufBg = CCSprite:createWithSpriteFrameName("blackBufBg.png")
                        self.blackBufBg:setPosition(ccp(15,G_VisibleSizeHeight*0.77))
                        self.blackBufBg:setScale(1.8)
                        self.blackBufBg:setAnchorPoint(ccp(0,0.5))
                        self.container:addChild(self.blackBufBg,90)
                        self.blackBufBg:setVisible(false)
                        local bbbNeedTiems = CCDelayTime:create(2.1)
                        local function bbbshowCall( )
                            self.blackBufBg:setVisible(true)
                        end
                        local bbbshowFunc=CCCallFunc:create(bbbshowCall)
                        local bbbArr = CCArray:create()
                        bbbArr:addObject(bbbNeedTiems)
                        bbbArr:addObject(bbbshowFunc)
                        local bbbseq = CCSequence:create(bbbArr)
                        self.blackBufBg:runAction(bbbseq)

                          self.killStr = GetTTFLabel(getlocal("killStr"),45,"Helvetica-bold")
                          self.killStr:setPosition(ccp(130,G_VisibleSizeHeight*0.77))
                          self.killStr:setColor(G_ColorRed)
                          self.container:addChild(self.killStr,98)
                          self.killStr:setVisible(false)
                          local killStr2 = GetTTFLabel(getlocal("killStr"),45,"Helvetica-bold")
                          killStr2:setPosition(getCenterPoint(self.killStr))
                          killStr2:setColor(G_ColorRed)
                          self.killStr:addChild(killStr2)

                          self.killStr:setAnchorPoint(ccp(0,0.5))
                          if G_getCurChoseLanguage()=="cn" then
                              self.killStr:setAnchorPoint(ccp(0.5,0.5))
                          end
                          
                          local function showCall( )
                              self.killStr:setVisible(true)
                          end
                          local showFunc=CCCallFunc:create(showCall)
                          local delayT1 = CCDelayTime:create(2.3)
                          local delayT = CCDelayTime:create(needTimes * 0.3 + 0.5)
                          local function closeCall( )
                              self.killStr:removeFromParentAndCleanup(true)
                              self.killStr = nil
                              self.blackBufBg:removeFromParentAndCleanup(true)
                              self.blackBufBg = nil
                              self:showResuil()
                          end 
                          local callFunc=CCCallFunc:create(closeCall)
                          local arr = CCArray:create()
                          arr:addObject(delayT1)
                          arr:addObject(showFunc)
                          arr:addObject(delayT)
                          arr:addObject(callFunc)
                          local seq = CCSequence:create(arr)
                          self.killStr:runAction(seq)
                      end

                      --self:showResuil()
                end



                                                                                  dataID=dataID+1
                                                                          else --打在空地上
                                                                               local dataTbs
                                                                               if fireTank.area==1 then
                                                                                      dataTbs=self.allT2
                                                                               else
                                                                                      dataTbs=self.allT1
                                                                               end
                                                                               curBeAttackNums = curBeAttackNums >0 and curBeAttackNums-1 or curBeAttackNums
                                                                               dataTbs[tsk]:beAttacked(1+tsk*0.1,fireTank.tid,23,"23-1",nil,nil,nil,nil,nil,nil,nil,nil,curBeAttackNums)
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
                                        -- self:runFuSheBo()
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
            if base.plane and base.plane == 1 and self.fjTb and SizeOfTable(self.fjTb) > 0 then
              if self.fjFireIndex >=self.fjFireIndexTotal then
                    delayAdd = 1
              else
                    battleEnd = false
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
                -- self:showResuil()
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
                   self.nextFire=2
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
           -- if self.nextFire==2 then
           --     self.nextFire=1
           --     self.lFireIndex=self.lFireIndex-1
           -- else
           --     self.nextFire=2
           --     self.rFireIndex=self.rFireIndex-1
           -- end
           self.nextFire=2
             self.rFireIndex=self.rFireIndex-1
           self:fireTick()   
    end
end

function acEatChickenBattleScene:tick()
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
            self.endBtnItemMenu:setTouchPriority(-203)
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
                self:fireTick()
        end
        self.fireIndex=1
        self.fireIndexTotal=#self.battleData
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

function acEatChickenBattleScene:tankBeAttackAnimationFinish( )
      self:fireTick()
end

function acEatChickenBattleScene:takeSpecialShow( idx )--战斗画面内特殊技能显示方法 idx 1.加效果 2.去掉效果
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

function acEatChickenBattleScene:setNewType( nType)--战斗逻辑内添加已使用过的技能type，为移除使用
    
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

function acEatChickenBattleScene:showZWTick()
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
function acEatChickenBattleScene:getBeAttackedTanks(fireTank,isSelectAll)
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

--添加摧毁的坦克 area:区域  pos:坦克在原地图层x,y坐标 sp:废墟图片
function acEatChickenBattleScene:addDestoryTank(area,pos,sp)
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
function acEatChickenBattleScene:addMzEffect(area,pos,sp)
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
function acEatChickenBattleScene:addShellEffect(area,pos,sp)
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
function acEatChickenBattleScene:addDustEffect(area,pos,sp)
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
function acEatChickenBattleScene:addDig(area,pos,sp)
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
function acEatChickenBattleScene:addDie(area,pos,sp)
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
function acEatChickenBattleScene:addBurst(area,pos,sp)
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

function acEatChickenBattleScene:addSubLife(area,pos,sp,bj,deTime)
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
function acEatChickenBattleScene:addRestraintAni(area,pos,relativeNum)
    
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
function acEatChickenBattleScene:addBomb(sp)
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

function acEatChickenBattleScene:showResuil()
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
                local dataKey="superWeapon@challenge@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..challengeVo.maxClearPos
                local localData=CCUserDefault:sharedUserDefault():getIntegerForKey(dataKey)
                if(localData~=1)then
                    local message={key="super_weapon_sysMsg",param={playerVoApi:getPlayerName(),challengeVo.curClearPos}}
                    chatVoApi:sendSystemMessage(message)
                    CCUserDefault:sharedUserDefault():setIntegerForKey(dataKey,1)
                    CCUserDefault:sharedUserDefault():flush()
                end
            end
        end
        if self.closeResultPanelHandler then
            self.closeResultPanelHandler()
        end
        self:close()
    end
        callback()
        do return end
end

function acEatChickenBattleScene:stopAction()
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

function acEatChickenBattleScene:isBattleFinished()
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
function acEatChickenBattleScene:addLD(idx)
      --左边
         local ldSp=CCSprite:createWithSpriteFrameName("d_1.png")
         ldSp:setAnchorPoint(ccp(0.5,0.5))
         winPos=ccp(600,G_VisibleSize.height*0.7)
         
         self.l_traceLayer:addChild(ldSp)
         
         local layerPos=self.l_traceLayer:convertToNodeSpace(winPos)
         ldSp:setPosition(layerPos)
      --右边
         
end
function acEatChickenBattleScene:addZW(idx)
        
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
function acEatChickenBattleScene:close()
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

function acEatChickenBattleScene:fastTick()
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

function acEatChickenBattleScene:mapShake(area)
    if area==1 then
         self.r_ShakeStTime=G_getCurDeviceMillTime()
    else
         self.l_ShakeStTime=G_getCurDeviceMillTime()
    end
end


function acEatChickenBattleScene:showStarAni(parent,m_starnum)
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

function acEatChickenBattleScene:checkIsAttackSelf(btdata)
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


function acEatChickenBattleScene:checkAnimEffectByData(btdata,fireTank) --根据后台返回的数据得出双方具体的技能动画效果
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
           if effectTB[1] =="*" then
              if self.skillCD[effectData] and fireTank then
                  fireTank.beSkillCD[effectData] = 1
              else
                  table.insert(attackerData,effectData)
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


function acEatChickenBattleScene:disposeWhenChangeServer()
    if self.fireTimer~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fireTimer)
        self.fireTimer=nil
    end
    
    if self.scheIndex~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheIndex)
        self.scheIndex=nil
    end
end

function acEatChickenBattleScene:hasSpcSkil(director,stype,tid) --方向1或2、技能类型、坦克id
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

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


function acEatChickenBattleScene:dispose()
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
    self.allPlane = {}
    self.skillCD = {}--技能动画延时的回合数
    self.speedShowArr = {}
    self.upSlideSP = nil
    self.oldG_battleSpeed = nil
    G_battleSpeed = 1
    self.killStr = nil
    self.blackBufBg = nil
    
end


