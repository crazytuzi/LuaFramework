
local ReallyView = classGc(view, function(self,_uid)
  self.m_mediator= require("mod.really.ReallyMediator")()
  self.m_mediator: setView(self)
  self.reallyData = {}
  self.oldSkill  = {}
  self.currentTypeId = 54105
  self.wingId = 0
  self.Grade  = 1
  self.tag    = 0
  self.nowtag = 101
  self.reallyUI  = {}
  self.playerUid = _uid or 0

  self.m_spineResArray={}
end)

local ReallyList = _G.Cfg.wing
local FontSize = 20
local m_winSize=cc.Director:getInstance():getWinSize()
local rightSize= cc.size( 284, 630 )
local iconSize = cc.size(79,79)

local openTag       = 110
local rideTag       = 120
local priceTag      = 130
local autoPriceTag  = 140

function ReallyView.create( self )
  self.m_rootLayer = cc.Scene : create()

  self.arenaBG = cc.Sprite : create("ui/bg/really_bg.jpg")
  self.arenaBG : setPosition(m_winSize.width/2,m_winSize.height/2)
  self.m_rootLayer : addChild(self.arenaBG)

  local function nCloseFun(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
      print("关闭宠物")
      cc.Director : getInstance() : popScene()
      self : destroy()
      _G.SpineManager.releaseSpineInView(self.m_spineResArray)
      local signArray=_G.GOpenProxy:getSysSignArray()
      if signArray[_G.Const.CONST_FUNC_OPEN_WING] then
          _G.GOpenProxy:delSysSign(_G.Const.CONST_FUNC_OPEN_WING)
      end
    end
  end
  local backButton= gc.CButton:create()
  backButton     : addTouchEventListener(nCloseFun)
  backButton     : loadTextures("general_view_close.png")
  backButton     : setSoundPath("bg/ui_sys_clickoff.mp3")
  backButton     : setPosition(self.arenaBG : getContentSize().width/2 + m_winSize.width/2-60,m_winSize.height-50)
  backButton     : setContentSize(cc.size(100,100))
  self.arenaBG   : addChild(backButton)

  self:init()
  --请求服务端消息
  self:requestService()
  return self.m_rootLayer
end

function ReallyView.init( self )
  local BGSize=self.arenaBG:getContentSize()
  local xingxiuNode=cc.Node:create()
  xingxiuNode:setPosition(BGSize.width/2-m_winSize.width/2,BGSize.height/2-m_winSize.height/2)
  self.m_rootLayer:addChild(xingxiuNode)

  self.reallyBtn = {}
  self.noJiLabel = {}
  self.nameLabel = {}
  self.wenzidi   = {}

  local function operateButton( sender,eventType )
    if eventType == ccui.TouchEventType.ended then
      local tag = sender:getTag()
      print("operateButton --->",self.currentTypeId,tag)
      self.tag = 0
      if tag==120 then
        if self.xingBG==nil then
          self:XingYuanView()
        else
          self.xingBG:setVisible(true)
          self.xinglisterner : setSwallowTouches(true)
        end
        self:RightSkill(self.nowtag)
        self:nowSkillIcon(self.nowtag)
      else
        self.currentTypeId = tag
        
        if self.reallyNode==nil then
          self:initView()
        else
          self.reallyNode:setVisible(true)
          local reallyName = _G.Cfg.wing_des[self.currentTypeId].name
          self.BBname:setString(reallyName)
          self.taglisterner : setSwallowTouches(true)
        end
        local num = (tag-54100)/5
        self:ReturnSpine(num,tag) 
        self:SkillIcon()
        self:getReallyData(self.currentTypeId,self.wingId)
      end
    end
  end

  local effectName = "spine/nengliangqiu"
  self.m_spineResArray[effectName]=true
  local effect = _G.SpineManager.createSpine(effectName,0.45)
  effect:setAnimation(0,"idle",true)
  effect:setPosition(m_winSize.width/2+300,170)
  self.m_rootLayer:addChild(effect)

  local yuanBtn=ccui.Widget:create()
  yuanBtn:setContentSize(cc.size(80,180))
  yuanBtn:setPosition(m_winSize.width/2+300,470)
  yuanBtn:addTouchEventListener(operateButton)
  yuanBtn:setTag(120)
  yuanBtn:setTouchEnabled(true)
  -- yuanBtn:setSwallowTouches(false)
  self.m_rootLayer:addChild(yuanBtn)

  local yuanLab=_G.Util:createBorderLabel("水 晶",FontSize,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLACK))
  yuanLab:setPosition(40,15)
  yuanLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
  yuanBtn:addChild(yuanLab)

  local SpineSize=cc.size(100,100)
  local posX={m_winSize.width/2-340,m_winSize.width/2-210,m_winSize.width/2-180,m_winSize.width/2-20,
              m_winSize.width/2+50,m_winSize.width/2+180,m_winSize.width/2+240,m_winSize.width/2+390}
  local posY={270,160,350,160,310,160,290,200}
  local m_myLv=_G.GPropertyProxy:getMainPlay():getLv()
  for i,v in ipairs(ReallyList) do
    print("ReallyList ---> ",i,v.name)
    -- local reallyBtnImg = "general_tubiaokuan.png"
    local reallyBtn=ccui.Widget:create()
    reallyBtn:setContentSize(SpineSize)
    reallyBtn:setPosition(cc.p(posX[i],posY[i]))
    reallyBtn:addTouchEventListener(operateButton)
    reallyBtn:setTag(v.wing_id)
    reallyBtn:setTouchEnabled(true)
    -- reallyBtn:setSwallowTouches(false)
    self.m_rootLayer:addChild(reallyBtn)

    self : ReturnSpineBtn(i,v.wing_id,reallyBtn)

    self.wenzidi[v.wing_id] = cc.Sprite:createWithSpriteFrameName("really_dins.png")
    self.wenzidi[v.wing_id] :setScaleY(1.5)
    -- self.wenzidi[v.wing_id] :setRotation(90)
    self.wenzidi[v.wing_id] :setPosition(-25,SpineSize.height/2-20)
    reallyBtn:addChild(self.wenzidi[v.wing_id])

    local bagNum = _G.GBagProxy:getGoodsCountById(v.wing_id)
    local LabStr = "未激活"
    local LabCol = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED)
    if bagNum>0 or _G.Cfg.wing_des[v.wing_id].m_lv <= m_myLv then
        LabStr = "可激活"
        LabCol = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLUE)
    end

    self.noJiLabel[v.wing_id]=_G.Util:createLabel(LabStr,FontSize)
    self.noJiLabel[v.wing_id]:setPosition(-36,SpineSize.height/2-40)
    self.noJiLabel[v.wing_id]:setColor(LabCol)
    self.noJiLabel[v.wing_id]:setAnchorPoint(cc.p(0,0.5))
    self.noJiLabel[v.wing_id]:setDimensions(22, 0)
    reallyBtn:addChild(self.noJiLabel[v.wing_id])
    self.SpHeight=SpineSize.height/2

    local reallyName = _G.Cfg.wing_des[v.wing_id].name
    self.nameLabel[v.wing_id]=_G.Util:createLabel(reallyName,FontSize)
    self.nameLabel[v.wing_id]:setPosition(-36,SpineSize.height/2+40)
    self.nameLabel[v.wing_id]:setAnchorPoint(cc.p(0,0.5))
    self.nameLabel[v.wing_id]:setDimensions(22, 0)
    -- if v.wing_id==54110 then
    --   self.noJiLabel[v.wing_id]:setPosition(-20,SpineSize.height/2-40)
    --   self.nameLabel[v.wing_id]:setPosition(-20,SpineSize.height/2+40)
    --   self.wenzidi[v.wing_id]:setPosition(-12,SpineSize.height/2-5)
    -- end
    reallyBtn:addChild(self.nameLabel[v.wing_id])
  end

  self:PropertyView()
end

function ReallyView.initView( self )
  local BGSize=self.arenaBG:getContentSize()
  local function onTouchBegan() return true end
  self.taglisterner = cc.EventListenerTouchOneByOne:create()
  self.taglisterner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
  self.taglisterner : setSwallowTouches(true)

  self.reallyNode=cc.Sprite : create("ui/bg/really_dins1.jpg")
  self.reallyNode:setPosition(m_winSize.width/2,m_winSize.height/2)
  self.reallyNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.taglisterner,self.reallyNode)
  self.m_rootLayer:addChild(self.reallyNode)
  self.dinSize=self.reallyNode:getContentSize()

  local layer=cc.LayerColor:create(cc.c4b(0,0,0,155))
  layer:setContentSize(BGSize)
  layer:setPosition(self.dinSize.width/2-BGSize.width/2,self.dinSize.height/2-BGSize.height/2)
  self.reallyNode:addChild(layer,-1)

  -- local bianSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
  -- bianSpr : setPreferredSize(cc.size(self.dinSize.width+25,self.dinSize.height+25))
  -- bianSpr : setPosition(self.dinSize.width/2,self.dinSize.height/2)
  -- self.reallyNode:addChild(bianSpr,-1)

  -- local effectName = "spine/nengliangqiu"
  -- local effect = _G.SpineManager.createSpine(effectName,1)
  -- effect:setAnimation(0,"idle",true)
  -- effect:setPosition(self.dinSize.width/2+25,self.dinSize.height/2)
  -- self.reallyNode:addChild(effect)

  local function nCloseFun(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
      print("关闭培养")
      self.reallyNode:setVisible(false)
      self.taglisterner : setSwallowTouches(false)
    end
  end
  local closeBtn = gc.CButton:create()
  closeBtn : addTouchEventListener(nCloseFun)
  closeBtn : loadTextures("general_view_close.png")
  closeBtn : setSoundPath("bg/ui_sys_clickoff.mp3")
  closeBtn : setPosition(self.dinSize.width-30,self.dinSize.height-30)
  closeBtn : setContentSize(cc.size(80,80))
  closeBtn : setButtonScale(0.8)
  self.reallyNode : addChild(closeBtn)

  -- local strdiSpr = cc.Sprite:createWithSpriteFrameName("general_dins.png")
  -- strdiSpr : setRotation(90)
  -- strdiSpr : setPosition(80,self.dinSize.height-150)
  -- self.reallyNode : addChild(strdiSpr)

  local reallyName = _G.Cfg.wing_des[self.currentTypeId].name
  self.BBname = _G.Util:createLabel(reallyName,20)
  -- self.BBname : setRotation(-90)
  self.BBname : setAnchorPoint(cc.p(0,0.5))
  self.BBname : setDimensions(22, 0)
  self.BBname : setPosition(85,self.dinSize.height-85)
  self.reallyNode  : addChild(self.BBname)

  self.pSize=cc.size(self.dinSize.width-rightSize.width,self.dinSize.height)
  self.pBackground = ccui.Widget:create()
  self.pBackground : setContentSize( self.pSize )
  self.pBackground : setPosition(self.pSize.width/2,self.dinSize.height/2 )
  self.reallyNode:addChild( self.pBackground )

  -- local shadow=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
  -- shadow:setPosition(self.pSize.width/2,215)
  -- shadow:setScaleX(3)
  -- shadow:setScaleY(1.5)
  -- self.reallyNode:addChild(shadow)

  self.rightGround = ccui.Widget:create()
  self.rightGround : setContentSize( rightSize )
  self.rightGround : setPosition(self.dinSize.width-rightSize.width/2,self.dinSize.height/2 )
  self.reallyNode:addChild( self.rightGround )

  self.MaxLvLab = _G.Util : createLabel( "宠物境界已满", FontSize+5 )
  self.MaxLvLab : setVisible( false )
  self.MaxLvLab : setPosition(rightSize.width/2,65)
  -- self.MaxLvLab : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE) )
  self.rightGround : addChild( self.MaxLvLab )

  self.m_attrFlyNode=_G.Util:getLogsView():createAttrLogsNode()
  self.m_attrFlyNode:setPosition(self.pSize.width/2-30,340)
  self.reallyNode:addChild(self.m_attrFlyNode,20)

  self : pBackgroundView()
  self : rightgroundView()
  -- self : reallyLeftView()
end

function ReallyView.PropertyView( self )
  local BGSize=self.arenaBG:getContentSize()
  local dituSize=cc.size(BGSize.width,72)
  local dituSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
  dituSpr:setOpacity(150)
  dituSpr:setPreferredSize(dituSize)
  dituSpr:setPosition(BGSize.width/2,35)
  self.arenaBG:addChild(dituSpr)

  print("PropertyView",BGSize.width/2,BGSize.width/2-m_winSize.width/2)
  local straddLab=_G.Util:createLabel("总属性加成:",FontSize)
  straddLab:setAnchorPoint(cc.p(0,0.5))
  straddLab:setPosition(180,50)
  -- straddLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  dituSpr:addChild(straddLab)

  -- local posX = 200
  -- local posY = 50
  -- local infoStr = {"strong_att","hp","defend_down","strong_def","hit","dod","crit","crit_res"}
  local infoStr = {42,41,44,43,45,46,47,48}
  self.z_infoZhi = {}
  self.z_infoLab = {}
  self.z_addLab  = {}
  local prop_img  = {"general_att.png","general_hp.png","general_wreck.png","general_def.png","general_hit.png",
            "general_dodge.png","general_crit.png","general_crit_res.png"} 
  local nameStr = {"攻击:","气血:","破甲:","防御:","命中:","闪避:","暴击:","抗暴:"} 
  for i=1, 8 do
    local key=infoStr[i]
    self.z_infoZhi[key]=0

    local infoSpr = cc.Sprite:createWithSpriteFrameName(prop_img[i])
    local nameLab = _G.Util:createLabel(nameStr[i],FontSize-2)
    self.z_infoLab[key] = _G.Util:createLabel("0",FontSize)
    self.z_addLab[key] = _G.Util:createLabel("("..self.z_infoZhi[key]..")",FontSize-2)

    -- nameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.z_infoLab[key] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.z_addLab[key] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.z_infoLab[key] : setAnchorPoint(cc.p(0,0.5))
    self.z_addLab[key] : setAnchorPoint(cc.p(0,0.5))

    if i<5 then 
      infoSpr : setPosition(180*i+130,50)
      nameLab : setPosition(180*i+165,48)
      self.z_infoLab[key] : setPosition(180*i+188,48)
      self.z_addLab[key] : setPosition(180*i+246,48)
    else
      infoSpr : setPosition(180*(i-4)+130,20)
      nameLab : setPosition(180*(i-4)+165,18)
      self.z_infoLab[key] : setPosition(180*(i-4)+188,18)
      self.z_addLab[key] : setPosition(180*(i-4)+246,18)
    end
    dituSpr : addChild(infoSpr)
    dituSpr : addChild(nameLab)
    dituSpr : addChild(self.z_infoLab[key])
    dituSpr : addChild(self.z_addLab[key])
  end
end

function ReallyView.XingYuanView( self )
  local BGSize=self.arenaBG:getContentSize()
  local function onTouchBegan() return true end
  self.xinglisterner = cc.EventListenerTouchOneByOne:create()
  self.xinglisterner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
  self.xinglisterner : setSwallowTouches(true)

  self.xingBG=cc.Sprite : create("ui/bg/really_dins2.jpg")
  self.xingBG:setPosition(m_winSize.width/2,m_winSize.height/2)
  self.xingBG:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.xinglisterner,self.xingBG)
  self.m_rootLayer:addChild(self.xingBG)
  self.dinSize=self.xingBG:getContentSize()

  local layer=cc.LayerColor:create(cc.c4b(0,0,0,155))
  layer:setContentSize(BGSize)
  layer:setPosition(self.dinSize.width/2-BGSize.width/2,self.dinSize.height/2-BGSize.height/2)
  self.xingBG:addChild(layer,-1)

  -- local bianSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
  -- bianSpr : setPreferredSize(cc.size(self.dinSize.width+25,self.dinSize.height+25))
  -- bianSpr : setPosition(self.dinSize.width/2,self.dinSize.height/2)
  -- self.xingBG:addChild(bianSpr,-1)

  local effectName = "spine/nengliangqiu"
  local effect = _G.SpineManager.createSpine(effectName,0.45)
  effect:setAnimation(0,"idle",true)
  effect:setPosition(self.dinSize.width/2+130,self.dinSize.height/2-150)
  self.xingBG:addChild(effect,100)

  local function nCloseFun(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
      print("关闭培养")
      self.xingBG:setVisible(false)
      self.xinglisterner : setSwallowTouches(false)
    end
  end
  local closeBtn = gc.CButton:create()
  closeBtn : addTouchEventListener(nCloseFun)
  closeBtn : loadTextures("general_view_close.png")
  closeBtn : setSoundPath("bg/ui_sys_clickoff.mp3")
  closeBtn : setPosition(self.dinSize.width-30,self.dinSize.height-30)
  closeBtn : setContentSize(cc.size(80,80))
  closeBtn : setButtonScale(0.8)
  self.xingBG : addChild(closeBtn)

  local function ReturnButton( sender,eventType )
    if eventType == ccui.TouchEventType.ended then
      self:onReturnSkillBtn(sender)
    end
  end

  self.skillSpr={}
  local posX = 71
  local posY = self.dinSize.height+68
  for i=101,108 do
    if i%2==0 then
      posX=186
    else
      posX=71
      posY=posY-137
    end
    
    local kuangBtn=ccui.Widget:create()
    kuangBtn:setContentSize(cc.size(108,132))
    kuangBtn:addTouchEventListener(ReturnButton)
    kuangBtn:setPosition(posX,posY-15)
    kuangBtn:setTouchEnabled(true)
    kuangBtn:setTag(i)
    self.xingBG : addChild(kuangBtn,10)

    local skillNode = _G.Cfg.wing_link[i]

    -- local icon = skillNode[i].icon
    self.skillSpr[i] = _G.ImageAsyncManager:createSkillSpr(i)
    self.skillSpr[i] : setPosition(posX,posY)
    self.skillSpr[i] : setGray()
    self.xingBG : addChild(self.skillSpr[i])

    local nameLab = _G.Util : createLabel( skillNode.name, FontSize )
    nameLab : setPosition(30,-32)
    -- nameLab : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE) )
    self.skillSpr[i] : addChild( nameLab )
  end
  self:createScelectEquipEffect(self.skillSpr[self.nowtag],true)

  local strLab = _G.Util : createLabel("技能说明:", FontSize )
  strLab : setPosition(self.dinSize.width/2-85,53)
  -- strLab : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE) )
  self.xingBG : addChild( strLab )

  local tjLab = _G.Util : createLabel( "激活条件：", FontSize )
  tjLab : setPosition(self.dinSize.width/2-85,self.dinSize.height/2-53)
  -- tjLab : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD) )
  self.xingBG : addChild( tjLab )

  local skillNode = _G.Cfg.wing_link[self.nowtag]
  self.skdesLab = _G.Util : createLabel(skillNode.des, FontSize )
  self.skdesLab : setPosition(self.dinSize.width/2-30,35)
  -- self.skdesLab : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE) )
  self.skdesLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)         --左对齐 
  self.skdesLab : setDimensions(350,60)  --设置文字区域
  self.skdesLab : setAnchorPoint(cc.p(0,0.5))
  self.xingBG : addChild( self.skdesLab )

  self.ztaiLab = _G.Util : createLabel("未激活", FontSize+4 )
  self.ztaiLab : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED) )
  self.ztaiLab : setPosition(self.dinSize.width/2+130,self.dinSize.height/2+10)
  self.xingBG : addChild( self.ztaiLab )
end

function ReallyView.onReturnSkillBtn(self, sender)
  self.nowtag = sender:getTag()
  print("operateButton --->",self.currentTypeId,self.nowtag)
  local skillNode = _G.Cfg.wing_link[self.nowtag]
  self.skdesLab:setString(skillNode.des)
  self.ztaiLab:setString("未激活")
  self.ztaiLab:setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED) )

  self:RightSkill(self.nowtag)
  self:createScelectEquipEffect(self.skillSpr[self.nowtag],true)
  self:nowSkillIcon(self.nowtag)
end

function ReallyView.nowSkillIcon(self, nowtag)
  if self.skillData~=nil then
    for k,v in pairs(self.skillData) do
      print("self.skillData==>2",v.skill_id)
      self.skillSpr[v.skill_id]:setDefault()
      if v.skill_id==nowtag then
        self.ztaiLab:setString("已激活")
        -- self.ztaiLab:setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN) )
      end
    end
  end
end

function ReallyView.RightSkill(self, _id)
  -- if self.wingSpr~=nil then
  --   self.wingSpr:removeFromParent(true)
    -- self.wingSpr=nil
  -- end
  if self.nameLab~=nil then
    for k,v in pairs(self.nameLab) do
      v:setString("")
    end
  end
  if self.needLab~=nil then
    for k,v in pairs(self.needLab) do
      v:setString("")
    end
  end
  if self.headSpr~=nil then
    for k,v in pairs(self.headSpr) do
      v:removeFromParent(true)
      v=nil
    end
  end

  local skillNode = _G.Cfg.wing_link[_id]
  local skillconn = skillNode.condition
  -- local icon = skillNode[i].icon
  -- self.wingSpr = _G.ImageAsyncManager:createSkillSpr(i)
  -- self.wingSpr : setPosition(self.dinSize.width/2,self.dinSize.height/2+100)
  -- self.xingBG : addChild(self.wingSpr)
  
  self.nameLab={}
  self.needLab={}
  self.headSpr={}
  for i=1,3 do 
    print("skillconn[i]",skillconn[i])
    if skillconn[i]~=nil then
      print("skillconn",i)
      local wingId = skillNode.condition[i][1]
      self.headSpr[i]=_G.ImageAsyncManager:createHeadSpr(wingId)
      self.headSpr[i]:setScale(0.8)
      self.headSpr[i]:setPosition(191+i*165,145)
      self.xingBG:addChild(self.headSpr[i])
      
      local gaiSpr=gc.GraySprite:createWithSpriteFrameName("really_headkuang.png")
      gaiSpr:setPosition(191+i*165,145)
      self.xingBG:addChild(gaiSpr)

      local wingNode = _G.Cfg.wing_des[wingId]
      self.nameLab[i] = _G.Util : createLabel( wingNode.name, FontSize )
      self.nameLab[i] : setPosition(191+i*165,201)
      -- self.nameLab[i] : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE) )
      self.xingBG : addChild( self.nameLab[i] )

      self.needLab[i] = _G.Util : createLabel(string.format("境界%d",skillconn[i][2]), FontSize )
      self.needLab[i] : setPosition(191+i*165,90)
      self.needLab[i] : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED) )
      self.xingBG : addChild( self.needLab[i] )

      if self.reallyData[wingId]==nil then
        self.headSpr[i]:setGray()
        -- gaiSpr:setGray()
      else
        if self.reallyData[wingId].grade>=skillNode.condition[i][2] then
          self.needLab[i] : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN) )
        end
      end
    end
  end
end

function ReallyView.createScelectEquipEffect( self,_obj,_istrue )
    if _obj == nil then return end
    if self.m_headEffect ~= nil then
        self.m_headEffect : retain()
        self.m_headEffect : removeFromParent(false)
        _obj : addChild(self.m_headEffect,20)
        self.m_headEffect : release()
        return
    end

    if _istrue then
      self.m_headEffect = cc.Sprite :createWithSpriteFrameName("really_kuang.png")
      -- self.m_headEffect : runAction(cc.RepeatForever :create( cc.Animate:create(animation)))
      self.m_headEffect : setPosition(30,17)

      _obj : addChild(self.m_headEffect,20)
    end
end

function ReallyView.pBackgroundView(self)
  local function operateCallBack( sender,eventType )
    if eventType == ccui.TouchEventType.ended then
      print("operateCallBack",sender:getTag())
      self:touchEventCallBack(sender,eventType)
    end
  end

  self.rideButton=gc.CButton:create()
  self.rideButton:loadTextures("general_btn_gold.png")
  self.rideButton:setPosition(self.pSize.width/2,60)
  self.rideButton:setTitleText("跟 随")
  self.rideButton:setTitleFontName(_G.FontName.Heiti)
  self.rideButton:setTitleFontSize(FontSize+2)
  self.rideButton:addTouchEventListener(operateCallBack)
  self.rideButton:setVisible(false)
  self.rideButton:setTag(rideTag)
  self.pBackground:addChild(self.rideButton)

  self.norideButton=gc.CButton:create()
  self.norideButton:loadTextures("general_btn_gold.png")
  self.norideButton:setPosition(self.pSize.width/2,60)
  self.norideButton:setTitleText("激 活")
  self.norideButton:setTitleFontSize(FontSize+2)
  self.norideButton:setTitleFontName(_G.FontName.Heiti)
  --self.norideButton:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
  self.norideButton:addTouchEventListener(operateCallBack)
  self.norideButton:setTag(openTag)
  self.pBackground:addChild(self.norideButton)

  local tipsLab = _G.Util:createLabel("激活的宠物属性可叠加",FontSize)
  -- tipsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LABELBLUE))
  tipsLab : setPosition(self.pSize.width/2,20)
  self.pBackground : addChild(tipsLab)

  if self.playerUid~=0 then
    self.rideButton:setBright(false)
    self.rideButton:setEnabled(false)
    self.norideButton:setBright(false)
    self.norideButton:setEnabled(false)
  else
    self.rideButton:setBright(true)
    self.rideButton:setEnabled(true)
    self.norideButton:setBright(true)
    self.norideButton:setEnabled(true)
  end

  -- local powerSprite = cc.Sprite:createWithSpriteFrameName("main_fighting.png")
  -- powerSprite : setPosition( self.pSize.width/2,self.pSize.height-50) 
  -- self.pBackground : addChild( powerSprite )

  self:SkillIcon()
end

function ReallyView.SkillIcon(self)
  if self.iconSpr~=nil then
    for k,v in pairs(self.iconSpr) do
        v:removeFromParent(true)
        v=true
    end
  end
  self.iconSpr={}
  local function cFun(sender,eventType)
      if eventType==ccui.TouchEventType.ended then
          local nTag=sender:getTag()
          local nPos=sender:getWorldPosition()
          print("Tag",nTag)

          self:SkillTips(nTag,nPos)
      end
  end

  local wingDes=_G.Cfg.wing_des[self.currentTypeId].skill
  for i=1,#wingDes do
    self.iconSpr[i] = _G.ImageAsyncManager:createSkillBtn(wingDes[i],cFun,wingDes[i])
    self.iconSpr[i] : setGray()
    self.iconSpr[i] : setPosition( 80+70*i,146) 
    self.pBackground : addChild(self.iconSpr[i])
    if self.skillData~=nil and i~=1 then
      for k,v in pairs(self.skillData) do
        print("v.skill_id==>",v.skill_id,wingDes[i])
        if v.skill_id==wingDes[i] then
          print("setDefault=============")
          self.iconSpr[i] : setDefault()
        end
      end
    end
  end
end

function ReallyView.SkillTips(self,tag,_pos)
  if self.tipsSpr~=nil then
    self.tipsSpr:removeFromParent(true)
    self.tipsSpr=nil
  end

  local num = (self.currentTypeId-54100)/5
  local wingData=_G.Cfg.wing[num]
  local tipsSize=cc.size(250,210)
  if tag<200 then
    tipsSize=cc.size(250,180)
  elseif self.Grade~=#wingData then
    tipsSize=cc.size(250,210)
  else
    tipsSize=cc.size(250,180)
  end
  local function onTouchBegan(touch)
    print("TipsUtil remove tips")
    local location=touch:getLocation()
    local bgRect=cc.rect(_pos.x,_pos.y,tipsSize.width,tipsSize.height)
    local isInRect=cc.rectContainsPoint(bgRect,location)
    print("location===>",location.x,location.y)
    print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
    if isInRect then
        return true
    end
    if self.tipsSpr~=nil then
      self.tipsSpr:removeFromParent(true)
      self.tipsSpr=nil
    end
    return true 
  end
  local skilllisterner = cc.EventListenerTouchOneByOne : create()
  skilllisterner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
  -- skilllisterner : setSwallowTouches(true)
  
  self.tipsSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_bagkuang.png")
  self.tipsSpr : setPreferredSize(tipsSize)
  self.tipsSpr : setAnchorPoint(cc.p(0,0))
  self.tipsSpr : setPosition(_pos)
  self.tipsSpr : getEventDispatcher() : addEventListenerWithSceneGraphPriority(skilllisterner, self.tipsSpr)
  cc.Director:getInstance():getRunningScene() :addChild(self.tipsSpr,1000)

  -- local icon = wingDes[tag].icon
  local spr = _G.ImageAsyncManager:createSkillSpr(tag)
  spr : setPosition(50,tipsSize.height-50)
  self.tipsSpr : addChild(spr)

  local name = _G.Cfg.wing_link[tag].name
  local nameLab = _G.Util : createLabel(name,FontSize)
  nameLab : setAnchorPoint(cc.p(0,0.5))
  nameLab : setPosition(cc.p(tipsSize.width/2-30,tipsSize.height-50))
  -- nameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.tipsSpr : addChild(nameLab)

  local des = _G.Cfg.wing_link[tag].des
  local basics = _G.Cfg.wing_link[tag].basics/100
  local plus   = _G.Cfg.wing_link[tag].plus/100
  local newbas = (self.Grade-1)*plus+basics
  if tag==202 then
    newbas = basics-(self.Grade-1)*plus
  end
  local newDes = string.gsub(des, "~p", newbas)
  local desLab = _G.Util : createLabel(newDes,FontSize)
  -- desLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  desLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)         --左对齐 
  desLab : setDimensions(tipsSize.width-40,0)  --设置文字区域
  desLab : setPosition(cc.p(tipsSize.width/2,tipsSize.height-125))
  self.tipsSpr : addChild(desLab)

  local lineSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
  local lineHeight= desLab:getContentSize().height+15
  lineSpr : setPreferredSize(cc.size(tipsSize.width-25,lineHeight))
  lineSpr : setPosition(tipsSize.width/2,tipsSize.height-125)
  self.tipsSpr : addChild(lineSpr,-1)

  if tag<200 then
    local weiyiLab = _G.Util : createLabel("(星缘)",FontSize)
    weiyiLab : setAnchorPoint(cc.p(0,0.5))
    weiyiLab : setPosition(cc.p(tipsSize.width/2-30,tipsSize.height-40))
    weiyiLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.tipsSpr : addChild(weiyiLab)
    nameLab : setPosition(cc.p(tipsSize.width/2-30,tipsSize.height-65))
  elseif self.Grade~=#wingData then
    local newplus = string.format("每阶加成%s%s",plus,"%")
    if tag==202 then
      newplus=string.format("每阶减少%d秒冷却时间",plus)
    end
    self.plusLab = _G.Util : createLabel(newplus,FontSize)
    self.plusLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.plusLab : setAnchorPoint(cc.p(0,0.5))         --左对齐 
    self.plusLab : setPosition(cc.p(20,30))
    self.tipsSpr : addChild(self.plusLab)
  end
end

function ReallyView.ReturnSpineBtn(self,num,wing_id,obj) 
  local SpineId = _G.Cfg.wing[num].skin_id
  local nScale  = _G.Cfg.wing_des[wing_id].scale
  local szSpineName="spine/"..SpineId
  local function nCall()

    local _spine=_G.SpineManager.createSpine(szSpineName,nScale/10000)
    _spine:setPosition(40,0)
    _spine:setAnimation(0,"idle",true)
    _spine:setScaleX(-1*nScale/10000)
    obj:addChild(_spine,3)
  end
  cc.Director:getInstance():getTextureCache():addImageAsync(szSpineName..".png",nCall)
  self.m_spineResArray[szSpineName]=true
end

function ReallyView.ReturnSpine(self,num,wing_id) 
  if self.spine~=nil then
      self.spine : removeFromParent(true)
      self.spine = nil
  end

  self.m_creatingWingId=wing_id

  local SpineId = _G.Cfg.wing[num].skin_id
  local nScale  = _G.Cfg.wing_des[wing_id].scale
  local szSpineName="spine/"..SpineId
  local function nCall()
    if self.m_creatingWingId~=wing_id then return end

    local _spine=_G.SpineManager.createSpine(szSpineName,2*nScale/10000)
    _spine:setPosition(self.pSize.width/2+10,230)
    _spine:setAnimation(0,"idle",true)
    self.reallyNode:addChild(_spine,3)

    self.m_creatingWingId=nil
    self.spine=_spine
  end
  cc.Director:getInstance():getTextureCache():addImageAsync(szSpineName..".png",nCall)
  self.m_spineResArray[szSpineName]=true
end

function ReallyView.rightgroundView(self)  
  local strLabel1 = _G.Util:createLabel("当前属性",FontSize)
  -- strLabel1 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  strLabel1 : setPosition(45,rightSize.height-75)
  self.rightGround : addChild(strLabel1)

  local strLabel2 = _G.Util:createLabel("(成长)",FontSize)
  strLabel2 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
  strLabel2 : setPosition(120,rightSize.height-75)
  self.rightGround : addChild(strLabel2)
  
  local infoStr = {"strong_att","hp","defend_down","strong_def","hit","dod","crit","crit_res"}
  self.infoLab = {}
  self.addLab  = {}
  -- local prop_img  = {"general_att.png","general_hp.png","general_wreck.png","general_def.png","general_hit.png",
            -- "general_dodge.png","general_crit.png","general_crit_res.png"} 
  local nameStr = {"攻击:","气血:","破甲:","防御:","命中:","闪避:","暴击:","抗暴:"} 
  for i=1, 8 do
    -- local infoSpr = cc.Sprite:createWithSpriteFrameName(prop_img[i])
    -- infoSpr : setPosition(30,rightSize.height-80-40*i)
    -- self.rightGround : addChild(infoSpr)

    local nameLab = _G.Util:createLabel(nameStr[i],FontSize)
    -- nameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    nameLab : setPosition(60,rightSize.height-75-36*i)
    self.rightGround : addChild(nameLab)

    local key=infoStr[i]
    self.infoLab[key] = _G.Util:createLabel("0",FontSize)
    self.infoLab[key] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.infoLab[key] : setAnchorPoint(cc.p(0,0.5))
    self.infoLab[key] : setPosition(92,rightSize.height-75-36*i)
    self.rightGround : addChild(self.infoLab[key])

    local key=infoStr[i]
    self.addLab[key] = _G.Util:createLabel("(0)",FontSize)
    self.addLab[key] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.addLab[key] : setAnchorPoint(cc.p(0,0.5))
    self.addLab[key] : setPosition(185,rightSize.height-75-36*i)
    self.rightGround : addChild(self.addLab[key])
  end

  self.powerSpriteNum = {}
  self : falseNodeView()
  self : trueNodeView()
end

function ReallyView.falseNodeView( self )
  self.falseNode = cc.Node:create()
  self.rightGround : addChild(self.falseNode)

  -- local tanSpr = cc.Sprite:createWithSpriteFrameName("general_tanhao.png")
  -- tanSpr : setPosition(45,120)
  -- self.falseNode : addChild(tanSpr)

  local wordStr = _G.Cfg.wing_des[self.currentTypeId].des1
  self.tipsLab = _G.Util:createLabel(wordStr,FontSize)
  -- self.tipsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LABELBLUE))
  self.tipsLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
  self.tipsLab : setDimensions(rightSize.width-50, 130)
  self.tipsLab : setAnchorPoint(cc.p(0,0.5))
  self.tipsLab : setPosition(20,110)
  self.falseNode : addChild(self.tipsLab)
end

function ReallyView.trueNodeView( self )
  self.trueNode = cc.Node:create()
  self.rightGround : addChild(self.trueNode)
  self.trueNode : setVisible(false)

  local levelSprite = ccui.Scale9Sprite:createWithSpriteFrameName("mount_level.png")
  levelSprite : setPosition(rightSize.width/2-20,225)
  self.trueNode : addChild( levelSprite )

  self.tenSprite = cc.Sprite:createWithSpriteFrameName("mount_0.png")
  self.tenSprite : setPosition(rightSize.width/2+18,225)
  self.trueNode : addChild(self.tenSprite)

  self.oneSprite = cc.Sprite:createWithSpriteFrameName("mount_1.png")
  self.oneSprite : setPosition(rightSize.width/2+35,225)
  self.trueNode : addChild(self.oneSprite)

  self.reallyUI.star = {1,2,3,4,5,6,7,8,9,10}
  for i=1,10 do
    local starSprite = gc.GraySprite:createWithSpriteFrameName("general_star2.png")
    starSprite:setPosition(15+27*(i-1),190 )
    starSprite:setScale(0.8)
    starSprite:setGray()
    self.trueNode:addChild( starSprite )
    self.reallyUI.star[i] = starSprite
  end

  local expbgSpr = cc.Sprite:createWithSpriteFrameName("main_exp_2.png")
  expbgSpr : setPosition(rightSize.width/2-5,162)
  expbgSpr : setScaleX(0.9)
  self.trueNode:addChild(expbgSpr)

  local expSize = expbgSpr:getContentSize()
  self.expBar = ccui.LoadingBar:create()
  self.expBar : loadTexture("main_exp.png",ccui.TextureResType.plistType)
  self.expBar : setPosition(expSize.width/2,expSize.height/2)
  expbgSpr:addChild(self.expBar)

  self.expLab = _G.Util:createLabel("0/0",FontSize-2)
  -- self.expLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  self.expLab : setPosition(rightSize.width/2-5,162)
  self.trueNode:addChild(self.expLab)

  local reallyLab = {1,2}
  local r_posX = {rightSize.width/2-35,rightSize.width/2+25}
  for i=1,2 do
    reallyLab[i] = _G.Util:createLabel("消耗宠物丹:",FontSize)
    reallyLab[i] : setPosition(r_posX[i],105)
    -- reallyLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
    self.trueNode: addChild(reallyLab[i])
  end
  -- reallyLab[1] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  reallyLab[2] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
  reallyLab[2] : setAnchorPoint(0,0.5)
  reallyLab[2] : setString("0/0")
  self.numsLab = reallyLab[2]

  self.exptipLab = _G.Util:createLabel("每次培养获得1~20点经验",FontSize-2)
  self.exptipLab : setPosition(rightSize.width/2,132)
  -- self.exptipLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  self.trueNode: addChild(self.exptipLab)

  local function operateCallBack( sender,eventType )
    if eventType == ccui.TouchEventType.ended then
      print("operateCallBack",sender:getTag())
      self:touchEventCallBack(sender,eventType)
    end
  end

  self.trainButton=gc.CButton:create()
  self.trainButton:loadTextures("general_btn_gold.png")
  self.trainButton:setPosition(rightSize.width/2-73,60)
  self.trainButton:setTitleText("培 养")
  self.trainButton:setTitleFontName(_G.FontName.Heiti)
  self.trainButton:setTitleFontSize(FontSize+2)
  self.trainButton:addTouchEventListener(operateCallBack)
  self.trainButton:setTag(priceTag)
  self.trueNode:addChild(self.trainButton)

  self.autoButton=gc.CButton:create()
  self.autoButton:loadTextures("general_btn_lv.png")
  self.autoButton:setPosition(rightSize.width/2+65,60)
  self.autoButton:setTitleText("培养50次")
  self.autoButton:setTitleFontName(_G.FontName.Heiti)
  self.autoButton:setTitleFontSize(FontSize+2)
  self.autoButton:addTouchEventListener(operateCallBack)
  --self.autoButton:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
  self.autoButton:setTag(autoPriceTag)
  self.trueNode:addChild(self.autoButton)

  if self.playerUid~=0 then
    self.trainButton:setBright(false)
    self.trainButton:setEnabled(false)
    self.autoButton:setBright(false)
    self.autoButton:setEnabled(false)
  else
    self.trainButton:setBright(true)
    self.trainButton:setEnabled(true)
    self.autoButton:setBright(true)
    self.autoButton:setEnabled(true)
  end
end

function ReallyView.reallyDataView(self,_itemList,_id)
  if _itemList==nil then return end
  self.rideButton:setVisible(true)
  self.norideButton:setVisible(false)
  self.trueNode:setVisible(true)
  self.falseNode:setVisible(false)
  self.iconSpr[1]:setDefault()

  print("_itemList",_itemList,_id,_itemList.wing_id,_itemList.grade,_itemList.lv,_itemList.exp,_itemList.powerful)
  local wingId = _itemList.wing_id or self.currentTypeId
  local _level = _itemList.grade or 0
  local _star  = _itemList.lv or 0
  local _count = _itemList.exp or 0
  local _powerfulInit = _itemList.powerful or 0
  self.Grade = _level
  
  print("已穿id",wingId,_id)
  if wingId == _id then
    self.tag = 1
    self.rideButton : setTitleText("休 息")
  else
    self.rideButton : setTitleText("跟 随")
  end

  local reallyCfg = {}
  for k,v in pairs(ReallyList) do
    if v.wing_id == wingId then
      reallyCfg = v
    end
  end

  if (_star == 10 and not reallyCfg[_level]) or 
     (_level ~= 1 and _star == 1) then
     print( " _G.g_lpMainPlay : showStarSkill()" )
     _G.g_lpMainPlay : showStarSkill()
  end
  print("zuoqidengji11",_level,_star,_count,reallyCfg.wing_id)
  local oddsList = reallyCfg[_level][_star].odds
  local wishList = reallyCfg[_level][_star].wish
  local costList = reallyCfg[_level][_star].cost
  local limitList= reallyCfg[_level][_star].limit
  local attrList = reallyCfg[_level][_star].attr
  local wingGoods= _G.GBagProxy:getGoodsCountById(54000)
  local bilv = _count/limitList*100
  self.expBar:setPercent(bilv)

  local nextList = {}
  if reallyCfg[_level][_star+1] then
    nextList = reallyCfg[_level][_star+1].attr
  elseif reallyCfg[_level+1] and reallyCfg[_level+1][1] then
    nextList = reallyCfg[_level+1][1].attr
  else
    nextList = { hp=0,strong_att=0,strong_def=0,defend_down=0,
        hit=0,dod=0,crit=0,crit_res=0}
  end

  self.expLab  : setString(string.format("%d/%d",_count,limitList))
  self.exptipLab  : setString(string.format("每次培养获得%d~%d点经验",oddsList,wishList))
  if self.playerUid~=0 then
    self.numsLab : setString(string.format("0/0"))
  else
  	self.allCount = costList
    self.numsLab : setString(string.format("%d/%d",wingGoods,costList))

    if wingGoods<costList then 
      self.numsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    else
      self.numsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    end
  end

  for key,value in pairs(attrList) do
    local tempLabel=self.infoLab[key]
    if tempLabel~=nil then
      tempLabel:setString(tostring(value))
    end
    local g = nextList[key]-value
    if g < 0 then 
      g = 0 
      self.expBar:setPercent(100)
      self.trainButton : setVisible(false)
      self.autoButton : setVisible(false)
      self.expLab  : setString( "MAX" )
      self.MaxLvLab    : setVisible( true )
      if self.playerUid~=0 then
        self.numsLab : setString(string.format("0/0"))
      else
        self.numsLab : setString(string.format("%d/0",wingGoods))
        self.numsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
      end
    else
      self.autoButton : setVisible(true)
      self.trainButton : setVisible(true)
      self.MaxLvLab    : setVisible( false )
    end
    self.addLab[key]:setString(string.format("(%d)",g))
  end

  for i=1, _star do
    self.reallyUI.star[i] : setDefault()
  end

  for i=_star+1, 10 do
    self.reallyUI.star[i] : setGray()
  end

  local shiwei = 0
  local gewei  = _level
  if gewei >= 10 then 
    shiwei = gewei/10 - gewei/10%1
    print( "shiwei = ", shiwei )
    gewei  = gewei%10
  end
  local frame1 = cc.SpriteFrameCache : getInstance() : getSpriteFrame( string.format("%s%d%s","mount_",shiwei,".png" ) )
  local frame2 = cc.SpriteFrameCache : getInstance() : getSpriteFrame( string.format("%s%d%s","mount_",gewei,".png" ) )
  print( "shiweipng = ", frame1,frame2 )
  self.tenSprite  : setSpriteFrame( frame1 )
  self.oneSprite  : setSpriteFrame( frame2 )

  self:createPowerNum(_powerfulInit)
end

function ReallyView.createPowerNum( self, _powerNum )
  if self.m_powerNode~=nil then
        self.m_powerNode:removeFromParent(true)
        self.m_powerNode=nil 
    end
    print("createPowerfulIcon====",_powerNum)

    self.m_powerNode=cc.Node:create()
    local tempLab=_G.Util:createBorderLabel(string.format("战力:%d",_powerNum),20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    tempLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    tempLab:setPosition(0,0)
    self.m_powerNode : addChild(tempLab)

    self.m_powerNode:setPosition(self.pSize.width/2+15, self.pSize.height-49)
    self.pBackground:addChild(self.m_powerNode,10)
end

function ReallyView.setReallyData(self,_dataList,_id,_skillList,_dat)
  if _dataList==nil then return end
  print("setReallyData --->",self.currentTypeId,_id,_skillList)
  self.wingId = _id
  
  for k,v in pairs(_dataList) do
    print("self.reallyData",self.reallyData,v.wing_id)
    self.reallyData[v.wing_id] = v
    self.wenzidi[v.wing_id]:setScaleY(1)
    self.noJiLabel[v.wing_id]:setString("")
    self.nameLabel[v.wing_id]:setPosition(-36,self.SpHeight)
    -- if v.wing_id==54110 then
    --   self.nameLabel[v.wing_id]:setPosition(-20,self.SpHeight)
    -- end
  end

  self.skillData=_skillList
  
  print("itemDataitemData",_id,_skillList)

  if _id~=0 then
    self.wenzidi[_id]:setScaleY(1.5)
    self.noJiLabel[_id]:setString("跟随中")
    self.noJiLabel[_id]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.nameLabel[_id]:setPosition(-36,self.SpHeight+40)
    -- if _id==54110 then
    --   self.nameLabel[_id]:setPosition(-20,self.SpHeight+40)
    -- end
  end

  self:DatInfoString(_dat)
end

function ReallyView.DatInfoString(self,_dat)
  for k,v in pairs(self.skillData) do
    if self.oldSkill[v.skill_id]==nil then
      local nature=_G.Cfg.wing_link[v.skill_id].nature
      print("_skillList-->",k,nature[1][1],nature[1][2],nature[2])
      self.z_infoZhi[nature[1][1]]=self.z_infoZhi[nature[1][1]]+nature[1][2]/100
      if nature[2]~=nil then
        self.z_infoZhi[nature[2][1]]=self.z_infoZhi[nature[2][1]]+nature[2][2]/100
      end
    end
    self.oldSkill[v.skill_id]=true
  end
  self.skillNum = #self.skillData

  local datzhi={_dat.hp,_dat.att,_dat.def,_dat.wreck,
          _dat.hit,_dat.dod,_dat.crit,_dat.crit_res}
  for i=41, 48 do 
    print("_dat-->>",datzhi[i-40])
    self.z_addLab[i]:setString("(+"..self.z_infoZhi[i].."%)")
    self.z_infoLab[i]:setString(datzhi[i-40])
  end
end

function ReallyView.Skill_Succ(self,_skillList,_dat)
  print("刷新技能数据")
  self.skillData=_skillList
  if self.iconSpr~=nil then
    local wingDes=_G.Cfg.wing_des[self.currentTypeId].skill
    for i=1,#wingDes do
      if self.skillData~=nil and i~=1 then
        for k,v in pairs(self.skillData) do
          print("v.skill_id==>",v.skill_id,wingDes[i])
          if v.skill_id==wingDes[i] then
            print("setDefault=============")
            self.iconSpr[i] : setDefault()
          end
        end
      end
    end
  end
end

function ReallyView.setReallyCul(self,_dataList,_dat)
  if _dataList==nil then return end
  print("self.reallyData[self.currentTypeId]",_dataList)
  self.reallyData[self.currentTypeId]=_dataList
  self:reallyDataView(_dataList,self.wingId)
  self:DatInfoString(_dat)
end

function ReallyView.getReallyData(self,_dataId,_id)
  print("getReallyData --->",_dataId,_id)
  local list = self.reallyData[_dataId]
  local num = (_dataId-54100)/5
  if list then
    self:reallyDataView(list,_id)
  else
    self:changeDate()
  end
end

function ReallyView.changeDate(self)
  self.falseNode:setVisible(true)
  self.trueNode:setVisible(false)
  self.MaxLvLab:setVisible(false)
  self.norideButton:setVisible(true)
  self.rideButton:setVisible(false)

  local wingId = self.currentTypeId
  local wordStr = _G.Cfg.wing_des[wingId].des1
  local _powerful = 0
  local _grade = 1
  local _star = 0

  self.tipsLab:setString(wordStr)

  local reallyCfg = {}
  for k,v in pairs(ReallyList) do
    if v.wing_id == wingId then
      reallyCfg = v
    end
  end
  print("zuoqidengji2222",_grade,_star,reallyCfg.wing_id)
  local attrList = reallyCfg[_grade][_star].attr

  local nextList = {}
  if reallyCfg[_grade][_star+1] then
    nextList = reallyCfg[_grade][_star+1].attr
  end

  for key,value in pairs(attrList) do
    local tempLabel=self.infoLab[key]
    if tempLabel~=nil then
      tempLabel:setString(tostring(value))
    end
    local g = nextList[key]-value
    self.addLab[key]:setString(string.format("(%d)",g))
  end

  self:createPowerNum(_powerful)
end

function ReallyView.requestService( self )
  local msg = REQ_WING_REQUEST()
  msg:setArgs( self.playerUid )
  _G.Network:send(msg)
end

function ReallyView.touchEventCallBack( self, obj, eventType  )
  local tag = obj:getTag()
  if eventType == ccui.TouchEventType.ended then
    if tag == openTag then
      local msg = REQ_WING_ACTIVATE()
      msg:setArgs( self.currentTypeId )
      _G.Network:send(msg)
    elseif tag == rideTag then
      print("self.tag",self.tag)
      if math.fmod(self.tag,2)==0 then
        local msg = REQ_WING_RIDE()
        msg:setArgs( self.currentTypeId )
        _G.Network:send(msg)
      else
        local msg = REQ_WING_RIDE()
        msg:setArgs( 0 )
        _G.Network:send(msg)
      end
    elseif tag == priceTag then
      local msg = REQ_WING_STRENGTHEN()
      msg:setArgs( self.currentTypeId,1)
      _G.Network:send(msg)
    elseif tag == autoPriceTag then
      local msg = REQ_WING_STRENGTHEN()
      msg:setArgs( self.currentTypeId,50)
      _G.Network:send(msg)
    end
  elseif eventType == ccui.TouchEventType.canceled then
      print(" 点击取消 ",  tag)
  end
end

function ReallyView.setRole( self, wing_id )
  print("穿戴卸下",self.tag,math.fmod(self.tag,2),wing_id)
  if math.fmod(self.tag,2)==0 then
    self.rideButton : setTitleText("休 息")
    _G.Util:playAudioEffect("ui_partner_fight")
  else
    self.rideButton : setTitleText("跟 随")
    _G.Util:playAudioEffect("ui_sys_clickoff")
  end
  for k,v in pairs(ReallyList) do
    if v.wing_id == wing_id then
      self.wenzidi[v.wing_id]:setScaleY(1.5)
      self.noJiLabel[v.wing_id]:setString("跟随中")
      self.noJiLabel[v.wing_id]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
      self.nameLabel[v.wing_id]:setPosition(-36,self.SpHeight+40)
      -- if v.wing_id==54110 then
      --   self.nameLabel[v.wing_id]:setPosition(-20,self.SpHeight+40)
      -- end
    else
      if self.reallyData[v.wing_id]~=nil then
        self.wenzidi[v.wing_id]:setScaleY(1)
        self.noJiLabel[v.wing_id]:setString("")
        self.nameLabel[v.wing_id]:setPosition(-36,self.SpHeight)
        -- if v.wing_id==54110 then
        --   self.nameLabel[v.wing_id]:setPosition(-20,self.SpHeight)
        -- end
      else
        self.wenzidi[v.wing_id]:setScaleY(1.5)
        self.noJiLabel[v.wing_id]:setString("未激活")
        self.noJiLabel[v.wing_id]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
        self.nameLabel[v.wing_id]:setPosition(-36,self.SpHeight+40)
        -- if v.wing_id==54110 then
        --   self.nameLabel[v.wing_id]:setPosition(-20,self.SpHeight+40)
        -- end
      end
    end
  end
  self.wingId = wing_id
  self.tag = self.tag+1
end

function ReallyView.Wing_Succ( self )
  _G.Util:playAudioEffect("balance_reward")
  self:getReallyData(self.currentTypeId,self.wingId)
  self.rideButton : setTitleText("跟 随")
end

-- function ReallyView.AttrFryNode(self,_obj)
  -- local attrFryNode=_G.Util:getLogsView():createAttrLogsNode()
  -- attrFryNode:setPosition(self.pSize.width/2,self.pSize.height/2)
  -- _obj:addChild(attrFryNode,100)
-- end

function ReallyView.bagGoodsUpdate(self)
	if self.numsLab~=nil and self.allCount~=nil then
		local nCount=_G.GBagProxy:getGoodsCountById(54000)
    	self.numsLab : setString(string.format("%d/%d",nCount,self.allCount))
    	if nCount<self.allCount then 
	      self.numsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	    else
	      self.numsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	    end
	end
end

return ReallyView

