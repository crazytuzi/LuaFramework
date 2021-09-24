local EquipFenJieLayer=classGc(view, function(self)
    self.pMediator=require("mod.equip.EquipFenJieLayerMediator")()
    self.pMediator:setView(self)
    -- self.isMoving=0
    -- self.m_isCheckAll=false
end)

local FONTSIZE = 20
local color1 = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)
local color2 = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE)
local color3 = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD )
local color4 = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED  )

local Tag_Btn_AllSwall = 65
local Tag_Btn_Swall    = 66
local MAXCOUNT = 6

local m_winSize = cc.Director:getInstance() : getWinSize()
local m_rootBgSize = cc.size(828,476)
local iconSize=cc.size(79,79)

function EquipFenJieLayer.__create(self)
  self.m_container = cc.Node:create()
  self.Spr_lu = cc.Sprite : create( "ui/bg/equip_gembg.png" )
  self.Spr_lu : setPosition( -190,-40 )
  -- self.Spr_lu : setScale(0.8)
  self.m_container    : addChild( self.Spr_lu )

  self:init()
  return self.m_container
end

function EquipFenJieLayer.init( self )
  self.myGoods = {}
  self.myGoods.goods   = {}
  self.myGoods.count   = {}
  self.indexList = {}
  self.goods_idList  = {}
  self.selectTimes = 0

  self : createLeft()
  self : createRigh()
end

function EquipFenJieLayer.createLeft( self )
  local width  = self.Spr_lu : getContentSize().width
  local height = self.Spr_lu : getContentSize().height
  local lefNode = cc.Node : create( )
  lefNode:setPosition(0,30)
  self.Spr_lu : addChild( lefNode )
  self.lefNode = lefNode

  local function ButtonCallBack( obj, touchType )
    self : touchEventCallBack( obj, touchType )
  end 

  self.Btn_lefKuan = {}
  self.spr_add={}
  local kuanX  = { width/2,width-110,width-110,width/2,110,110 }
  local kuanY  = { height-125, 270, 145, 65, 145, 270 }
  for i=1,MAXCOUNT do
      self.Btn_lefKuan[i] = gc.CButton : create()
      self.Btn_lefKuan[i] : loadTextures( "general_tubiaokuan.png","","",ccui.TextureResType.plistType)
      self.Btn_lefKuan[i] : setPosition( kuanX[i], kuanY[i] )
      self.Btn_lefKuan[i] : setTag( 100+i )
      self.Btn_lefKuan[i] : addTouchEventListener(ButtonCallBack)
      lefNode         : addChild(self.Btn_lefKuan[i],1)

      self.spr_add[i]     = cc.Sprite : createWithSpriteFrameName( "role_add.png" )
      self.spr_add[i]     : setPosition( iconSize.width/2,iconSize.height/2 )
      self.Btn_lefKuan[i] : addChild( self.spr_add[i] )
  end

  local spr = cc.Sprite : createWithSpriteFrameName( "general_tanhao.png" )
  spr : setPosition( 130, -25 )
  lefNode : addChild( spr )

  local lab = _G.Util : createLabel( "饰品被分解后材料100%返还", FONTSIZE-2 )
  lab     : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BROWN ) )
  lab     : setAnchorPoint(cc.p(0,0.5))
  lab     : setPosition( 145, -25 )
  lefNode   : addChild( lab )
end

function EquipFenJieLayer.createRigh( self )
  local rigNode    = cc.Node : create( )
  rigNode      : setPosition(29, -m_rootBgSize.height/2-50)
  self.m_container : addChild( rigNode )
  self.rigNode   = rigNode

  local mySize    = cc.size( 380,465 )

  local spr_base  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
  spr_base      : setPreferredSize( mySize )
  spr_base    : setAnchorPoint( 0, 0 )
  rigNode     : addChild( spr_base,-5 )

  local lab1 = _G.Util : createLabel( "分解可获得：", FONTSIZE )
  lab1 : setPosition( 30, mySize.height - 50 )
  lab1 : setAnchorPoint( 0, 0.5 )
  lab1 : setColor( color1 )
  rigNode : addChild( lab1 )

  local function ButtonCallBack( obj, touchType )
    self : touchEventCallBack( obj, touchType )
  end 

  self.Btn_RigKuan = {}

  local kuanX = { 30, 153, [0] = 275 }
  local kuanY = { 305,305,305, 200,200,200, 95,95,95 }
  for i=1,9 do
    local myWidget = gc.CButton : create("general_tubiaokuan.png" )
    myWidget : setTouchEnabled( true )
    myWidget : setAnchorPoint( 0, 0 )
    myWidget : setPosition( kuanX[i%3], kuanY[i] )
    myWidget : setTag( 1000+i )
    myWidget : addTouchEventListener( ButtonCallBack )
    rigNode  : addChild( myWidget, 1 )
    self.Btn_RigKuan[i] = myWidget
  end

  self.Btn_AllSwall = gc.CButton : create()
  self.Btn_AllSwall : setTitleText( "一键添加" )
  self.Btn_AllSwall : setTitleFontName( _G.FontName.Heiti )
  self.Btn_AllSwall : setTitleFontSize( FONTSIZE+2 )
  self.Btn_AllSwall : setPosition( 45, 22  )
  self.Btn_AllSwall : setAnchorPoint( 0,0 )
  self.Btn_AllSwall : loadTextures( "general_btn_gold.png" )
  self.Btn_AllSwall : setTag( Tag_Btn_AllSwall )
  self.Btn_AllSwall : addTouchEventListener( ButtonCallBack )
  rigNode       : addChild( self.Btn_AllSwall )

  self.Btn_Swall = gc.CButton : create()
  self.Btn_Swall : setTitleText( "分 解" )
  self.Btn_Swall : setTitleFontName( _G.FontName.Heiti )
  self.Btn_Swall : setTitleFontSize( FONTSIZE+2 )
  self.Btn_Swall : setPosition( 210, 22 )
  self.Btn_Swall : setAnchorPoint( 0,0 )
  self.Btn_Swall : loadTextures( "general_btn_lv.png" )
  self.Btn_Swall : setTag( Tag_Btn_Swall )
  self.Btn_Swall : addTouchEventListener( ButtonCallBack )
  rigNode      : addChild( self.Btn_Swall )

end

function EquipFenJieLayer.changeSelect( self, target )
  local mySelect = target : getChildByTag( 111 )
  local tag = target : getTag()
  if mySelect : isVisible() == true then
    if not self : subSelectTimes( tag ) then
      print( "没有找到匹配的IDX， tag = ", tag, self.bagData[tag].index )
    end
    mySelect : setVisible( false )
  else
    if self : addSelectTimes( tag ) then return end
    mySelect : setVisible( true  )
  end
end

function EquipFenJieLayer.addSelectTimes( self, tag )
  if self.NowselectTimes >= MAXCOUNT then
    local command = CErrorBoxCommand(7999)
      controller :sendCommand( command )
    return true
  else
    self.NowselectTimes = self.NowselectTimes + 1
    local idx = self.bagData[tag].index
    print( "addSelectTimes-->idx = ", idx )
    for i=1,MAXCOUNT do
      if self.NowindexList[i] == nil then
        self.NowindexList[i] = idx
        local goodid=self.bagData[tag].goods_id
        self.Nowgoods_idList[i] = _G.Cfg.goods[goodid]
        return
      end
    end
  end
end

function EquipFenJieLayer.subSelectTimes( self, tag )
  self.NowselectTimes = self.NowselectTimes - 1
  local idx = self.bagData[tag].index
  for i=1,MAXCOUNT do
    if self.NowindexList[i] == idx then
      self.NowindexList[i] = nil
      self.Nowgoods_idList[i] = nil
      return true
    end
  end
  return false
end

function EquipFenJieLayer.touchLefBtn( self, _num )

  if self.Btn_lefKuan[_num] : getChildByTag( 222 ) ~= nil then
    self : cleanOneSpr( _num )
    return
  end

  self.bagData  = self : getSwallowData()
  local goods_Num = #self.bagData
  print( "有", goods_Num, "件装备" )
  if goods_Num <= 0 then
    local command = CErrorBoxCommand(7991)
      controller :sendCommand( command )
    return
  end

  local goodsData = _G.Cfg.goods

  self.NowindexList = clone( self.indexList )
  self.Nowgoods_idList  = clone( self.goods_idList  )
  self.NowselectTimes = self.selectTimes 

  print( "存在数量：", self.NowselectTimes )
  -- for i=1,MAXCOUNT do
  --   print( "第", i , "件装备：", self.NowindexList[i], self.Nowgoods_idList[i] )
  -- end

  local function onTouchBegan() return true end
  local listerner=cc.EventListenerTouchOneByOne:create()
  listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
  listerner:setSwallowTouches(true)

  if self.myNewLayer ~= nil then
    self.myNewLayer : removeFromParent(true)
    self.myNewLayer = nil 
  end

  self.myNewLayer = cc.LayerColor:create(cc.c4b(0,0,0,255*0.5))
  self.myNewLayer : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.myNewLayer)
  cc.Director:getInstance():getRunningScene():addChild(self.myNewLayer,1000)

  local myNode = cc.Node : create()
  myNode : setPosition( m_winSize.width/2, m_winSize.height/2-38 )
  self.myNewLayer : addChild( myNode,1 )

  local mySize = cc.size( 500, 400 )

  local myBase = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
  myBase : setPreferredSize( mySize )
  myNode : addChild( myBase, -10 )

  local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
  tipslogoSpr : setPosition(mySize.width/2-135, mySize.height-25)
  myBase : addChild(tipslogoSpr)

  local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
  tipslogoSpr : setPosition(mySize.width/2+130, mySize.height-25)
  tipslogoSpr : setRotation(180)
  myBase : addChild(tipslogoSpr)

  local logoLab= _G.Util : createBorderLabel("选择饰品", FONTSIZE+4,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  logoLab : setPosition(mySize.width/2, mySize.height-25)
  logoLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  myBase  : addChild(logoLab)

  local function myClose( )
    if self.myNewLayer ~= nil then
        self.myNewLayer : removeFromParent(true)
        self.myNewLayer = nil 
      end
  end

  local function newLayerCallback( obj, touchType )
    local tag = obj : getTag()
    if touchType == ccui.TouchEventType.began then
      self.moveY = obj : getWorldPosition().y
      -- print( "按下", self.moveY )
    elseif touchType == ccui.TouchEventType.moved then
    elseif touchType == ccui.TouchEventType.ended then
      print( " 点击---> ", tag )
      if tag == 101 then
        self.selectTimes = self.NowselectTimes
        self.indexList = clone( self.NowindexList )
        self.goods_idList  = clone( self.Nowgoods_idList  )
        self : changeLefWidget()
        myClose()
      elseif tag == 102 then
        myClose()
      else
        local myMove = obj : getWorldPosition().y
        print( " myMove---> ", myMove )
        if myMove > 430 or myMove < 175 then
          return
        end
        if self.moveY - myMove > 10 or myMove - self.moveY > 10 then
          print( "这个是一次移动！" )
          return
        end
        self : changeSelect( obj )
      end
    end
  end

  local btn_sure = gc.CButton : create()
  btn_sure : setTitleText( "确 定" )
  btn_sure : setTitleFontName( _G.FontName.Heiti )
  btn_sure : setTitleFontSize( FONTSIZE+2 )
  btn_sure : setPosition( -95, -mySize.height/2 + 11  )
  btn_sure : setAnchorPoint( 0.5,0 )
  btn_sure : loadTextures( "general_btn_gold.png" )
  btn_sure : setTag( 101 )
  btn_sure : addTouchEventListener( newLayerCallback )
  myNode   : addChild( btn_sure,10 )

  local btn_cancle = gc.CButton : create()
  btn_cancle : setTitleText( "取 消" )
  btn_cancle : setTitleFontName( _G.FontName.Heiti )
  btn_cancle : setTitleFontSize( FONTSIZE+2 )
  btn_cancle : setPosition(  95, -mySize.height/2 + 11  )
  btn_cancle : setAnchorPoint( 0.5,0 )
  btn_cancle : loadTextures( "general_btn_lv.png" )
  btn_cancle : setTag( 102 )
  btn_cancle : addTouchEventListener( newLayerCallback )
  myNode   : addChild( btn_cancle,10 )

  print("sizesize-->",mySize.width,mySize.height)
  local size2 = cc.size( mySize.width-36, mySize.height-110 )

  local spr_base2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_di2kuan.png" )
  spr_base2 : setPreferredSize( size2 )
  spr_base2 : setPosition( 0, 12 )
  -- spr_base2 : setOpacity( 255*0.7 )
  myNode    : addChild( spr_base2 )

  local paicount = 0
  paicount=math.ceil(goods_Num/2)
  if goods_Num <= MAXCOUNT then
    paicount=3
  end
     
  local viewSize      = cc.size( size2.width, size2.height-10)
  local ScrollHeigh   = viewSize.height/3  
  local containerSize = cc.size( size2.width, ScrollHeigh*paicount )
  local ScrollView  = cc.ScrollView : create()
  ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
  ScrollView  : setViewSize(viewSize)
  ScrollView  : setContentSize(containerSize)
  ScrollView  : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
  ScrollView  : setPosition(cc.p(0, 5))
  ScrollView  : setTouchEnabled(true)
  spr_base2   : addChild( ScrollView,3 )

  local barView = require("mod.general.ScrollBar")(ScrollView)
  barView     : setPosOff(cc.p(-8,0))

  local size3 = cc.size( size2.width/2-9, ScrollHeigh-4 )
  local posX = { size2.width/4+2, [0] = size2.width/4*3 -3}
  local posY = containerSize.height-ScrollHeigh/2-2
  for i=1,goods_Num do
    local spr_widget=ccui.Button:create("general_nothis.png","general_isthis.png","general_isthis.png",1)
    spr_widget:setScale9Enabled(true)
    spr_widget:setContentSize(size3)
    spr_widget:setSwallowTouches(false)
    spr_widget:setPosition( posX[i%2], posY )
    spr_widget:setTag(i)
    spr_widget:addTouchEventListener(newLayerCallback)
    ScrollView:addChild(spr_widget)

    local id = self.bagData[i].goods_id
    local sprIcon = _G.ImageAsyncManager:createGoodsSpr(goodsData[id])
    sprIcon : setPosition( 46, size3.height/2 )
    sprIcon : setScale(0.85)
    spr_widget : addChild( sprIcon )

    local name = _G.Util : createLabel( goodsData[id].name, FONTSIZE )
    name : setPosition( 85, 54+3 )
    name : setColor( _G.ColorUtil:getRGB(goodsData[id].name_color)  )
    name : setAnchorPoint( 0, 0 )
    spr_widget : addChild( name )

    local labzizhi = _G.Util : createLabel( "资质:", FONTSIZE )
    labzizhi : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN) )
    labzizhi : setPosition( 85, 30+3  )
    labzizhi : setAnchorPoint( 0, 0 )
    spr_widget : addChild( labzizhi )

    local zizhi = _G.Util : createLabel( goodsData[id].star, FONTSIZE )
    zizhi : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE) )
    zizhi : setPosition( 85+labzizhi:getContentSize().width, 30+3  )
    zizhi : setAnchorPoint( 0, 0 )
    spr_widget : addChild( zizhi )

    local lablv = _G.Util : createLabel( "等级:", FONTSIZE )
    lablv : setPosition( 85, 6+3 )
    lablv : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN) )
    lablv : setAnchorPoint( 0, 0 )
    spr_widget : addChild( lablv  )

    local lv = _G.Util : createLabel( goodsData[id].lv, FONTSIZE )
    lv : setPosition( 85+lablv:getContentSize().width, 6+3 )
    lv : setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE) )
    lv : setAnchorPoint( 0, 0 )
    spr_widget : addChild( lv  )

    local kuan = cc.Sprite : createWithSpriteFrameName( "general_gold_floor.png" )
    kuan : setAnchorPoint( 0, 0 )
    kuan : setPosition( 165, 10 )
    spr_widget : addChild( kuan, 2 )

    local mySelect = cc.Sprite : createWithSpriteFrameName( "general_check_selected.png" )
    mySelect   : setPosition( 165, 10 )
    mySelect   : setAnchorPoint( 0, 0 )
    mySelect   : setTag( 111 )
    spr_widget : addChild( mySelect,3 )
    mySelect   : setVisible( false )

    for k=1,MAXCOUNT do
      if self.NowindexList[k] ~= nil then
        if self.NowindexList[k] == self.bagData[i].index then
          mySelect : setVisible( true )
        end
      end
    end

    if i%2 == 0 then 
      posY = posY - size3.height - 4
    end

  end
end

function EquipFenJieLayer.changeLefWidget( self )
  self.myGoods.goods = {}
  self.myGoods.count = {}
  for i=1,MAXCOUNT do
    local spr = self.Btn_lefKuan[i] : getChildByTag( 222 )
    local lab = self.Btn_lefKuan[i] : getChildByTag( 223 )
    local dins = self.Btn_lefKuan[i] : getChildByTag( 224 )
    if  spr ~= nil then
      spr : removeFromParent( true )
      spr = nil
    end
    if dins~=nil then
      dins : removeFromParent( true )
      dins = nil
    end
    if lab ~= nil then
      lab : removeFromParent( true )
      lab = nil
    end
  end
  for i=1,MAXCOUNT do
    if self.goods_idList[i] ~= nil then
      local sprIcon = cc.Sprite:createWithSpriteFrameName(string.format("%s.png",self.goods_idList[i].icon))
      sprIcon : setPosition( iconSize.width/2, iconSize.height/2 )
      sprIcon : setTag( 222 )
      self.Btn_lefKuan[i] : addChild( sprIcon )

      local labName = _G.Util : createLabel( self.goods_idList[i].name, FONTSIZE )
      labName : setTag( 223 )
      local color   = self.goods_idList[i].name_color
      _G.ColorUtil:setLabelColor(labName, color or 2)
      labName : setPosition( 40, -18 )
      self.Btn_lefKuan[i] : addChild( labName )

      local stateSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
      stateSpr : setPreferredSize(cc.size(10+labName:getContentSize().width,30))
      stateSpr : setTag( 224 )
      stateSpr : setPosition(iconSize.width/2,-18)
      self.Btn_lefKuan[i] : addChild(stateSpr,-1)

      self.spr_add[i]:setVisible(false)
    else
      self.spr_add[i]:setVisible(true)
    end
  end

  if self.selectTimes > 0 then
    self : changeRigWidget()
  end
end

function EquipFenJieLayer.changeRigWidget( self )
  self : cleanGoodsIcon()
  for i=1,MAXCOUNT do
    if self.goods_idList[i] ~= nil then
      local goods = self.goods_idList[i]
      print( "有", #goods, "个物品分解!" )
      for k=1,#goods do
        self : addGoods( goods[k],goods )
      end
      self : addShenWang( i )
    end
  end
  for i=1,#self.myGoods.goods do
    print("对应的物品：",self.myGoods.goods[i], self.myGoods.count[i])
    self : addGoodsIcon( i )
  end
end

function EquipFenJieLayer.addShenWang( self, _num )
  local function search(  )
    for i=1,#self.bagData do
      if self.bagData[i].index == self.indexList[_num] then
        return i
      end
    end 
    return false
  end

  local i  = search()
  if i == false then
    print( "search() 没有匹配到!" )
    return
  end

  local goodsId=self.bagData[i].goods_id
  local goodsdata=_G.Cfg.goods[goodsId]
  print("self.bagData[i].fumov",self.bagData[i].fumov)
  
  local goods   = goodsdata.split[1]
  if goods[2] > 0 then
    self : addGoods( goods,goodsdata )
  end
  if self.bagData[i].fumov>0 then
    self.myGoods.goods[2]=43000
    if self.myGoods.count[2]~=nil then
      self.myGoods.count[2]=self.myGoods.count[2]+self.bagData[i].fumov
    else
      self.myGoods.count[2]=self.bagData[i].fumov
    end
  end
end

function EquipFenJieLayer.addGoodsIcon( self, _num )
  local goodnode  = _G.Cfg.goods[ self.myGoods.goods[_num] ]
  local node = cc.Node : create()
  node : setTag( 555 )
  self.Btn_RigKuan[_num] : addChild( node )

  local m_iconSpr = _G.ImageAsyncManager:createGoodsSpr(goodnode,self.myGoods.count[_num])
  m_iconSpr : setPosition( iconSize.width/2,iconSize.width/2 )
  m_iconSpr : setTag( 555 )
  node : addChild( m_iconSpr )
end

function EquipFenJieLayer.cleanGoodsIcon( self )
  for i=1,9 do
    local spr = self.Btn_RigKuan[i] : getChildByTag( 555 )
    if spr ~= nil then
      spr : removeFromParent( true )
      spr = nil
    end
  end
end

function EquipFenJieLayer.addGoods( self, goods,gdata )
  local count = #self.myGoods.goods
  print( "物品数量：", count,gdata.lv )
  if count == 0 or count == nil then
    self.myGoods.goods[1] = goods[1]
    self.myGoods.count[1] = goods[2]
    return
  else
    for i=1,count do
      if self.myGoods.goods[i]==goods[1] then
        self.myGoods.count[i] = self.myGoods.count[i] + goods[2]
        print("00000",self.myGoods.count[i],goods[2])
        return
      end
    end
    self.myGoods.goods[count+1] = goods[1]
    self.myGoods.count[count+1] = goods[2]
  end
end

function EquipFenJieLayer.getSwallowData( self )
  local data=_G.GBagProxy:getRoleBagList()

  local function sortfuncup( good1, good2)
      if good1.star < good2.star then
        print("aaa----->>>",good1.star,good2.star)
          return true
      end
      return false
  end
  table.sort( data, sortfuncup)

  return data 
end

function EquipFenJieLayer.cleanOneSpr( self, tag )
  self.indexList[tag] = nil
  self.goods_idList[tag]  = nil
  print( "EquipFenJieLayer.cleanOneSpr = ", self.indexList[tag] )
  self.spr_add[tag]:setVisible(true)
  self.selectTimes = self.selectTimes - 1

  local spr = self.Btn_lefKuan[tag] : getChildByTag( 222 )
  if  spr ~= nil then
    spr : removeFromParent( true )
    spr = nil
  end
  local lab = self.Btn_lefKuan[tag] : getChildByTag( 223 )
  if  lab ~= nil then
    lab : removeFromParent( true )
    lab = nil
  end

  local dins = self.Btn_lefKuan[tag] : getChildByTag( 224 )
  if  dins ~= nil then
    dins : removeFromParent( true )
    dins = nil
  end

  self.myGoods.goods = {}
  self.myGoods.count = {}
  self : changeRigWidget()
end

function EquipFenJieLayer.cleanChoose( self )
  self.indexList = nil
  self.indexList = {}
  self.goods_idList  = nil
  self.goods_idList  = {}
  self.selectTimes   = 0
  self.myGoods.goods = {}
  self.myGoods.count = {}

  for i=1,MAXCOUNT do
    local spr = self.Btn_lefKuan[i] : getChildByTag( 222 )
    if  spr ~= nil then
      spr : removeFromParent( true )
      spr = nil
    end
    local lab = self.Btn_lefKuan[i] : getChildByTag( 223 )
    if  lab ~= nil then
      lab : removeFromParent( true )
      lab = nil
    end
    local dins = self.Btn_lefKuan[i] : getChildByTag( 224 )
    if  dins ~= nil then
      dins : removeFromParent( true )
      dins = nil
    end
  end
end

function EquipFenJieLayer.addAllSwall( self )
  self.bagData  = self : getSwallowData()
  if #self.bagData == 0 or #self.bagData == nil then
    local command = CErrorBoxCommand(7991)
      controller :sendCommand( command )
    return
  end
  local allcount = MAXCOUNT
  if #self.bagData < MAXCOUNT then 
    allcount = #self.bagData 
  end
  print( "选择了", self.selectTimes, #self.bagData, allcount )
  for i=1,allcount-self.selectTimes do
    for k=1,#self.bagData do
      if self : addSelect2Times( k, allcount ) then 
        self : changeLefWidget()
        return 
      end
    end 
  end
  self : changeLefWidget()
end


function EquipFenJieLayer.addSelect2Times( self, tag, allcount )
  local function checkSame( target  )
    for i=1,MAXCOUNT do
      if  self.indexList[i] ==  target then
        print( "已经存在相同的, i =", i, target, self.indexList[i] )
        return false
      end
    end
    return true
  end

  if self.selectTimes >= MAXCOUNT then
    return true
  else
    local idx = self.bagData[tag].index
    print( "addSelectTimes-->idx = ", idx )
    for i=1,MAXCOUNT do
      if self.indexList[i] == nil then
        print( "i = ", i )
        if checkSame(idx) then
          print( "找到没有匹配的，加入：", i, idx )
          self.selectTimes = self.selectTimes + 1
          self.indexList[i] = idx
          local goodid=self.bagData[tag].goods_id
          self.goods_idList[i] = _G.Cfg.goods[goodid]
          return
        end
      end
    end
  end
end

function EquipFenJieLayer.createIcon( self, sender, eventType )
  local tag = sender : getTag() - 1000
  if self.Btn_RigKuan[tag] : getChildByTag(555) == nil then return end
  print( "－－－－－－－按了图片－－－－－－－－" )
    local role_tag    = self.myGoods.goods[tag]
    local Position    = sender : getWorldPosition()
    local downbgSize  = cc.size(605, 392)
    local rightbgSize   = cc.size(605, 437)
    local _pos      = {}
    _pos.x          = Position.x+42
    _pos.y          = Position.y+42
    print("－－－－选中role_tag:", role_tag)
    print("－－－－Position.y",Position.y)
    if _pos.y > m_winSize.height/2+downbgSize.height/2-40 or _pos.y < m_winSize.height/2-rightbgSize.height/2-25 then return end
    if role_tag <= 0 then return end
    local temp = _G.TipsUtil : createById(role_tag,nil,_pos,0)
    cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
end

function EquipFenJieLayer.lianhun( self )
  if self.selectTimes == 0 or self.selectTimes == nil then
    local command = CErrorBoxCommand(7991)
      controller :sendCommand( command )
    return 
  end

  local count  = 0
  local myMsg  = {}
  for i=1,MAXCOUNT do
    if self.goods_idList[i] ~= nil then
      count = count + 1
      myMsg[count] = {}
      myMsg[count].goods_id  = goodid
      -- self.goods_idList[i]=_G.Cfg.goods[goodid]
      myMsg[count].idx = self.indexList[i]
      myMsg[count].count=1
    end
  end
  print( "发送的数量：", count,myMsg ) 
  local m_myLv=_G.GPropertyProxy:getMainPlay():getLv()
  local m_ture=false
  if self.goods_idList~=nil then
    print("#self.goods_idList",count)
    for i=1,MAXCOUNT do
      if self.goods_idList[i]~=nil then
        print("i-------->>>>>>>",i,m_myLv,self.goods_idList[i].lv)
        if m_myLv<self.goods_idList[i].lv then
          m_ture=true
          break
        end

        local m_equipList  = _G.GPropertyProxy:getMainPlay():getEquipList()  --装备数据
        print("m_equipList--->>>111",#m_equipList)
        if #m_equipList==0 then m_ture=true end
        for k,v in pairs(m_equipList) do
          local equipData=_G.Cfg.goods[v.goods_id]
          print("m_equipList--->>>222",k,equipData.lv,equipData.type_sub,self.goods_idList[i].lv)
          if self.goods_idList[i].lv>equipData.lv then
            m_ture=true
            break
          elseif self.goods_idList[i].lv==equipData.lv then
            if self.goods_idList[i].class>equipData.class then
              m_ture=true
              break
            end
          elseif self.goods_idList[i].type_sub==equipData.type_sub then
            m_ture=false
            break
          elseif self.goods_idList[i].type_sub~=equipData.type_sub then
            m_ture=true
          else
            m_ture=false
          end
        end
      end
    end 
  end
  if m_ture==false then
      local msg = REQ_MAKE_DECOMPOSE()
      msg : setArgs( count, myMsg )
      _G.Network :send( msg)
  else
      local function fun1()
          local msg = REQ_MAKE_DECOMPOSE()
          msg : setArgs( count, myMsg )
          _G.Network :send( msg)
      end
      _G.Util:showTipsBox("可穿戴装备分解后无法恢复\n是否继续分解？",fun1)
  end
end

function EquipFenJieLayer.updateDetele( self )
  local function removePartner( idx )
    for k=1,#self.bagData do
      if self.bagData[k].index == idx then
        return k
      end
    end
  end

  for i=1,MAXCOUNT do
    if self.indexList[i] ~= nil then
      local index = removePartner( self.indexList[i] )
      if index ~= nil then
        print( "移除第", index, "件", self.indexList[i] )
        table.remove( self.bagData, index)
        self.spr_add[i]:setVisible(true)
      end
    end
  end
  
  self : FenJieSuccEffect()
  self : cleanChoose()
  self : cleanGoodsIcon()
end

function EquipFenJieLayer.FenJieSuccEffect(self)
  print("分解成功特效")
    _G.Util:playAudioEffect("ui_equip_resolve")

    if self.m_fenjieSuccSpr~=nil then
        self.m_fenjieSuccSpr:start()
        return
    end
    
    local sizes          = self.Spr_lu : getContentSize ()  
    local tempGafAsset=gaf.GAFAsset:create("gaf/fenjie.gaf")
    self.m_fenjieSuccSpr=tempGafAsset:createObject()
    local nPos=cc.p(sizes.width/2,sizes.height/2)
    self.m_fenjieSuccSpr:setLooped(false,false)
    self.m_fenjieSuccSpr:start()
    self.m_fenjieSuccSpr:setPosition(nPos)
    self.Spr_lu : addChild(self.m_fenjieSuccSpr,1000)

    -- local function f1()
    --     self.m_fenjieSuccSpr:removeFromParent(true)
    --     self.m_fenjieSuccSpr=nil
    -- end
    -- local function f2()
    --     local action=cc.Sequence:create(cc.FadeTo:create(0.15,0),cc.CallFunc:create(f1))
    --     self.m_fenjieSuccSpr:runAction(action)
    -- end
    -- local function f3()
    --     local szPlist="anim/task_finish.plist"
    --     local szFram="task_finish_"
    --     local act1=_G.AnimationUtil:createAnimateAction(szPlist,szFram,0.12)
    --     local act2=cc.CallFunc:create(f2)

    --     local sprSize=self.m_fenjieSuccSpr:getContentSize()
    --     local effectSpr=cc.Sprite:create()
    --     effectSpr:setPosition(sprSize.width,sprSize.height*0.5)
    --     effectSpr:runAction(cc.Sequence:create(act1,act2))
    --     self.m_fenjieSuccSpr:addChild(effectSpr)
    -- end
    -- local action=cc.Sequence:create(cc.ScaleTo:create(0.15,1),cc.CallFunc:create(f3))
    -- self.m_fenjieSuccSpr:runAction(action)
end

function EquipFenJieLayer.unregister( self )
  print("EquipFenJieLayer.unregister")
  if self.pMediator ~= nil then
    self.pMediator : destroy()
    self.pMediator = nil 
  end
end

function EquipFenJieLayer.touchEventCallBack( self, obj, touchEvent )
  local tag = obj : getTag()
  if touchEvent == ccui.TouchEventType.began then
    print(" 按下 ", tag)
    elseif touchEvent == ccui.TouchEventType.moved then
        print(" 移动 ", tag)
    elseif touchEvent == ccui.TouchEventType.ended then
      print(" 抬起 ", tag)
      if 100 < tag and tag < 107 then
        self : touchLefBtn( tag - 100 )
      elseif tag == Tag_Btn_Swall then
        self : lianhun()
      elseif tag == Tag_Btn_AllSwall then
        self : addAllSwall()
      elseif 1000 < tag and tag < 1010 then
        self : createIcon( obj, touchEvent )
      end
    end
end

return EquipFenJieLayer



