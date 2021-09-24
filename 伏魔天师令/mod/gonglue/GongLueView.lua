
local GongLueView = classGc(view, function(self,_type)
    self.m_winSize=cc.Director:getInstance():getWinSize()
    self.TAG_HY = 711
    self.TAG_AC = 712
    self.TAG_BQ = 713
    self.TAG_BOX1 = 201
    self.TAG_BOX2 = 202
    self.TAG_BOX3 = 203
    self.TAG_BOX4 = 204
    self.TAG_BOX5 = 205
    self.TAG_HYVALUE = 1001
    self.TAG_HYLV    = 1002
    self.gl_strong_ids = _G.Cfg.gl_strong_id
    self.m_firstType=_type or self.TAG_HY

    self.activitySprs={}
    Self_num = 0

    self.m_sysList=_G.GOpenProxy:getSysId() --功能按钮id

    -- self.m_resourcesArray = {}
end)

local hdbgSize = cc.size(790, 412)
local bgSize   = cc.size(780, 400)
local FONTSIZE = 20

local TAG_GNKF = 206

function GongLueView.create( self )
  self.m_normalView=require("mod.general.TabUpView")()
  self.m_rootLayer=self.m_normalView:create("攻 略")

  local tempScene=cc.Scene:create()
  tempScene:addChild(self.m_rootLayer)

  local isFirstEnter=true
  local function onNodeEvent(event)
      if "enter"==event then
          if isFirstEnter then
              isFirstEnter=false
          else
              local msg=REQ_GONGLUE_HY()
              _G.Network:send(msg)
          end
      end
  end
  tempScene:registerScriptHandler(onNodeEvent)
  
  self : regMediator()
  self : initView()
  self : getPlayerData()
  return tempScene
end

function GongLueView.REQ_GONGLUE_HY( self )
  local msg = REQ_GONGLUE_HY()
  _G.Network: send( msg )
end

function GongLueView.initView( self )
  local function closeFun()
    self:closeWindow()
  end
  local function tabBtnCallBack(tag)
    print("CopyView.__initView tabBtnCallBack>>>>> tag="..tag)
    self:showGongLueByType(tag)
    return true
  end
  self.m_normalView:addCloseFun(closeFun)
  self.m_normalView:addTabButton("今日活跃",self.TAG_HY)
  self.m_normalView:addTabButton("活动日历",self.TAG_AC)
  self.m_normalView:addTabButton("我要变强",self.TAG_BQ)
  -- self.m_normalView:addTabButton("功能开放",TAG_GNKF)
  self.m_normalView:addTabFun(tabBtnCallBack)

  local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_STRATEGY)
  if rewardIconCount>0 then
    self.m_normalView:setTagIconNum(self.TAG_HY,rewardIconCount)
  end

  self.m_mainContainer = cc.Node:create()
  self.m_mainContainer : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
  self.m_rootLayer:addChild(self.m_mainContainer)

  self.m_tagcontainer = {}
  self.m_normalView:selectTagByTag(self.m_firstType)
  self:showGongLueByType(self.m_firstType)
  self.boxdata = _G.Cfg.gl_vitality_box
end

function GongLueView.chuangIconNum(self,_sysId,_number)
  if _G.Const.CONST_FUNC_OPEN_STRATEGY==_sysId then
    self.m_normalView:setTagIconNum(self.TAG_HY,_number)
  end
end

function GongLueView.regMediator( self )
  self.m_mediator= require("mod.gonglue.GongLueMediator")()
  print("注册GongLueMediator")
  self.m_mediator: setView(self)
  -- body
end

function GongLueView.closeWindow( self, Tag )
  -- ScenesManger.releaseFileArray(self.m_resourcesArray)
  if self.m_rootLayer==nil then return end
  self.m_rootLayer=nil
  cc.Director:getInstance():popScene()
  self:destroy()
  -- body
end


function GongLueView.showGongLueByType( self, tag )
  for i=self.TAG_HY,self.TAG_BQ do
    if self.m_tagcontainer[i]~=nil then
        if i == tag then
            self.m_tagcontainer[i] : setVisible(true)
        else
            self.m_tagcontainer[i] : setVisible(false)
        end
    end
  end

  local isNewView=false
  if self.m_tagcontainer[tag]==nil then
      isNewView=true
      self.m_tagcontainer[tag]=cc.Node:create()
      self.m_mainContainer:addChild(self.m_tagcontainer[tag])
  end

  if tag == self.TAG_HY then
      if isNewView then
          self : hyView()
      end
      self:REQ_GONGLUE_HY()
  elseif tag == self.TAG_AC then
      if isNewView then
          self : activityriliView()
      end
      self:REQ_GONGLUE_ACTIVITY_DAY( 0 )
  elseif tag == self.TAG_BQ then
      if isNewView then
          self : woyaobianqiangView()
      end
      self:REQ_GONGLUE_STRONG(10111)
  -- elseif tag == TAG_GNKF then
  --     if isNewView then
  --         -- self : createGNKF()
  --     end
  end
end

function GongLueView.hyView( self )
  print("初始化hyview 界面")
  self.hybgground = ccui.Widget:create()
  self.hybgground : setContentSize( bgSize )
  self.hybgground : setPosition( cc.p( 2,-41 ) )
  self.m_tagcontainer[self.TAG_HY] : addChild( self.hybgground )

  -- self : showRoleSpine()
  local myGirl = cc.Sprite:create("ui/bg/gonglve_gril.jpg")
  -- myGirl       : setScale(0.95)
  myGirl       : setPosition( -250, -117 )  
  self.m_tagcontainer[self.TAG_HY] : addChild( myGirl, -1 )

  -- if self.m_resourcesArray[ "icon/guide_grild.png" ] == nil then
      -- self.m_resourcesArray[ "icon/guide_grild.png" ] = true
  -- end

  -- myGirl:runAction(
  --   cc.RepeatForever:create(
  --     cc.Sequence:create(cc.MoveBy:create(1,cc.p(0,10)),cc.MoveBy:create(1,cc.p(0,-10)))))

  self.jinabSize  = cc.size(bgSize.width, 2)
  local kuangline = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
  kuangline       : setPosition(bgSize.width/2, bgSize.height-90)
  kuangline       : setPreferredSize(self.jinabSize)
  self.hybgground : addChild(kuangline)

  local gl_jindutiaod = cc.Sprite:createWithSpriteFrameName("main_exp_2.png")
  gl_jindutiaod : setPosition(bgSize.width/2+55, bgSize.height-29)
  gl_jindutiaod : setScaleX(2)
  self.hybgground : addChild( gl_jindutiaod )

  local expSize = gl_jindutiaod:getContentSize()
  self.gl_jindutiao = ccui.LoadingBar:create()
  self.gl_jindutiao : loadTexture("main_exp.png",ccui.TextureResType.plistType)
  self.gl_jindutiao : setPosition(expSize.width/2-1,expSize.height/2+0.5)
  gl_jindutiaod:addChild(self.gl_jindutiao)
  self.gl_jindutiao : setPercent( 0 )

  local function touchEvent( obj, eventType )
    self:touchEventCallBack( obj, eventType )
    -- body
  end
  self.boxBtn = {1,2,3,4,5}
  self.stepLabel = {1,2,3,4,5}
  local jinduSize = self.gl_jindutiao:getContentSize()
  local boxWidth = 580/5
  for i=1, 5 do
    self.boxBtn[i] = ccui.Button:create()
    self.boxBtn[i] : loadTextures("gl_box_light.png","","gl_box_normal.png",ccui.TextureResType.plistType)
    self.boxBtn[i] : setTag(200+i)
    self.boxBtn[i] : addTouchEventListener( touchEvent )
    self.boxBtn[i] : setPosition( cc.p(150+boxWidth*i, bgSize.height-26) ) 
    self.boxBtn[i] : setBright(false)
    self.hybgground: addChild( self.boxBtn[i] )

    self.stepLabel[i] = _G.Util:createBorderLabel(100*i,FONTSIZE,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_XSTROKE))
    self.stepLabel[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
    self.stepLabel[i] : setPosition( cc.p( 150+boxWidth*i, bgSize.height-70) )
    self.hybgground  : addChild( self.stepLabel[i] )
  end

  -- self.activeSpr = cc.Sprite:createWithSpriteFrameName("gl_active.png")
  -- self.activeSpr : setPosition(55, bgSize.height-45)
  -- self.hybgground   : addChild( self.activeSpr )

  self.todayValueLabel = _G.Util:createBorderLabel("活跃值: 0",FONTSIZE+4,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_XSTROKE))
  self.todayValueLabel : setAnchorPoint( cc.p(0,0.5) )
  self.todayValueLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  self.todayValueLabel : setPosition( 10, bgSize.height-28)
  self.hybgground : addChild( self.todayValueLabel )

  local oncSize = cc.size(bgSize.width-200,bgSize.height/2+35)
  self.ac_title = self : titleView("活动名称","等级","次数","活跃值", oncSize, true, nil )
  self.ac_title : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  self.ac_title : setPosition(cc.p( bgSize.width/2+110, bgSize.height/2+50) )
  self.hybgground: addChild( self.ac_title )
end

function GongLueView.hyAcView( self )
  -- 今日活跃状态栏
  if self.VscrollView ~=nil then
    self.VscrollView:removeFromParent(true)
    self.VscrollView=nil
  end
  local oncSize = cc.size(bgSize.width-200,bgSize.height/2+103)
  local Pos  = cc.p(self.hybgground:getPosition())

  local gl_viCount = 0
  for k,v in pairs(self.gl_vitality) do
    gl_viCount=gl_viCount+1
  end
  self.vitalitynode={}
  self.vitalityBtn ={}
  self.VscrollView = cc.ScrollView:create()
  local vsSize = cc.size(oncSize.width-4,bgSize.height/2+103)
  local innerSize  = cc.size( vsSize.width, oncSize.height/4*gl_viCount )
  self.VscrollView : setViewSize(vsSize)
  self.VscrollView : setContentSize(innerSize)
  self.VscrollView : setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
  self.VscrollView : setBounceable(false)
  self.VscrollView : setTouchEnabled(true)
  self.VscrollView : setDelegate()
  self.VscrollView : setContentOffset(cc.p(0, vsSize.height-innerSize.height))
  self.VscrollView : setPosition( cc.p( Pos.x/2+205, -56 ) )
  print(">>>>>>>>innerSizeinnerSizeinnerSize", oncSize.height*gl_viCount, gl_viCount )
  local icount = 1
  for k,v in ipairs(self.gl_vitality) do
    print( "这边的值：", v.lv, v.f_count, v.sum_count )
    self.vitalitynode[k] = self:hy_once( oncSize,v )
    self.vitalitynode[k] : setPosition(cc.p( innerSize.width/2, innerSize.height-oncSize.height/4-(oncSize.height/4)*(icount-1)+1) )
    self.VscrollView : addChild( self.vitalitynode[k] )
    icount = icount + 1
  end
  self.hybgground : addChild( self.VscrollView )
    
  local barView=require("mod.general.ScrollBar")(self.VscrollView)
  barView:setPosOff(cc.p(23,0))
  -- barView:setMoveHeightOff(-2)
end

function GongLueView.titleView( self,name, lv, count, hy_value, oncSize )
  local line = ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
  local lineSprSize = line : getPreferredSize()
  line : setPreferredSize( cc.size( oncSize.width, lineSprSize.height ) )
  local nameLabel  = _G.Util:createLabel(name,      FONTSIZE )
  local LvLabel    = _G.Util:createLabel(lv,        FONTSIZE )
  local CountLabel = _G.Util:createLabel(count,     FONTSIZE )
  local valueLabel = _G.Util:createLabel(hy_value,  FONTSIZE )

  local onew = oncSize.width/7
  nameLabel  : setPosition( cc.p( oncSize.width/2-onew*2.5-20, 30 ) )
  LvLabel    : setPosition( cc.p( oncSize.width/2-onew-20, 30 ) )
  CountLabel : setPosition( cc.p( oncSize.width/2+10-20, 30 ) )
  valueLabel : setPosition( cc.p( oncSize.width/2+onew+30-20, 30 ) ) 

  nameLabel  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  LvLabel    : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  CountLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  valueLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))

  line : addChild( nameLabel )
  line : addChild( LvLabel )
  line : addChild( CountLabel )
  line : addChild( valueLabel )

  return line
  -- body
end

function GongLueView.hy_once( self, oncSize, hy )
  -- 今日活跃
  local function myTouchCallBack( obj, eventType )
    if eventType == ccui.TouchEventType.ended then
      local Position  = obj : getWorldPosition()
      if Position.y > 315 then return end
      self:touchEventCallBack(obj, eventType)
    end
  end
  local line = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
  local lineSprSize = line : getPreferredSize()
  line : setPreferredSize( cc.size( oncSize.width, lineSprSize.height ) )
  local nameLabel  = _G.Util:createLabel(hy.name,      FONTSIZE )
  local LvLabel    = _G.Util:createLabel(hy.lv,        FONTSIZE )
  local CountLabel = _G.Util:createLabel(hy.f_count.."/"..hy.sum_count,     FONTSIZE )
  local valueLabel = _G.Util:createLabel("/"..hy.once_value*hy.sum_count,     FONTSIZE )

  local fValueLabel = _G.Util:createLabel(hy.f_count*hy.once_value,      FONTSIZE )
  -- fValueLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
  fValueLabel : setPosition( cc.p( oncSize.width/2+10, 22 ) )
  fValueLabel : setAnchorPoint( 1,0.5 )
  fValueLabel : setTag(self.TAG_HYVALUE)
  valueLabel  : setAnchorPoint( cc.p( 0,0.5 ) )

  local viBtn  = gc.CButton:create()
  viBtn : loadTextures("general_btn_gold.png")
  viBtn : setTag( hy.funid )
  viBtn : setTitleFontName(_G.FontName.Heiti)
  viBtn : addTouchEventListener( myTouchCallBack )
  print("hy.state",hy.state)
  if hy.f_count == hy.sum_count then
    viBtn : setTitleText("已完成" )
    viBtn : setTouchEnabled(false)
    viBtn : setBright(false)
  elseif hy.state  then
    viBtn : setTitleText("前 往")
  else
    viBtn : setTitleText("未开启")
    viBtn : setTouchEnabled(false)
    viBtn : setBright(false)
  end
  viBtn : setTitleFontSize(24)
  self.vitalityBtn[hy.id] = viBtn
  self.vitalityBtn[hy.id]:setPosition(cc.p( oncSize.width-70, 35 ))

  nameLabel  : setPosition( cc.p( 67, 35 ) )
  LvLabel    : setPosition( cc.p( oncSize.width/2-100, 35 ) )
  CountLabel : setPosition( cc.p( oncSize.width/2-5, 35 ) )
  fValueLabel: setPosition( cc.p( oncSize.width/2+90, 35 ) )
  valueLabel : setPosition( cc.p( oncSize.width/2+92, 35 ) ) 

  nameLabel  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  -- if hy.state then
  --   LvLabel  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  -- else
  --   LvLabel  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
  -- end
  -- CountLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  -- valueLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))

  line : addChild( self.vitalityBtn[hy.id] ) 
  line : addChild( fValueLabel )
  line : addChild( nameLabel )
  line : addChild( LvLabel )
  line : addChild( CountLabel )
  line : addChild( valueLabel )
  return line
end

function GongLueView.touchEventCallBack( self, obj, eventType )
  local tag = obj:getTag()
  if eventType == ccui.TouchEventType.began then
    if tag == self.TAG_BOX1 or tag == self.TAG_BOX2 or tag == self.TAG_BOX3 or
       tag == self.TAG_BOX4 or tag == self.TAG_BOX5 then
       local box_type = obj:isBright()
        if box_type then
          self:boxTips(tag)
        end
        print( "1111111" )
    end
    print(" 按下 ", tag )
    elseif eventType == ccui.TouchEventType.moved then
        print(" 移动 ",  tag)
    elseif eventType == ccui.TouchEventType.ended then
      if tag == self.TAG_BOX1 or tag == self.TAG_BOX2 or tag == self.TAG_BOX3 or
         tag == self.TAG_BOX4 or tag == self.TAG_BOX5 then
         self:box_operate(obj,tag)
         print( "2222222" )
      elseif tag == 1 or tag == 2 or tag == 3 or tag == 4 or tag == 5 or
             tag == 6 or tag == 7 then
          self.befor_week = tag
          self:ac_week(tag)
          self:REQ_GONGLUE_ACTIVITY_DAY( tag )
          print( "3333333" )
      elseif tag == 10111 or tag == 10112 or tag == 10113 or tag == 10114 or tag == 10115 then
          self.befor_bq = tag 
          self:ac_bq(tag)
          self:REQ_GONGLUE_STRONG( tag )
          print( "4444444" )
      end
      local Position  = obj : getWorldPosition()
      print("Position.y",Position.y,bgSize.height)
      if tag < 200 then 
        print( "5555555" )
        print("Position.y",Position.y,bgSize.height-70)
        if Position.y > bgSize.height-70 or Position.y < 100 then return end
      end
      if Position.y > bgSize.height+90 or Position.y < 35 then return end

      if tag == self.TAG_BOX1 or tag == self.TAG_BOX2 or tag == self.TAG_BOX3 or
        tag == self.TAG_BOX4 or tag == self.TAG_BOX5 then
        print( "6666666" )
        _G.GLayerManager : openLayerByMapOpenId(tag)
      elseif tag == 1 or tag == 2 or tag == 3 or tag == 4 or tag == 5 or
        tag == 6 or tag == 7 then
        print( "7777777" )
        _G.GLayerManager : openLayerByMapOpenId(tag)
      elseif tag == 10111 or tag == 10112 or tag == 10113 or tag == 10114 or tag == 10115 then
        print( "8888888" )
        _G.GLayerManager : openLayerByMapOpenId(tag)
      else
        -- self:closeWindow()
        if tag == _G.Const.CONST_MAP_QIECHUO_GONGLUE then
          local myText = "在城镇里点击其他玩家，选择切磋，待对方同意后即可进行切磋"
          local function fun1( )
            self:closeWindow()
          end
          _G.Util:showTipsBox(myText,fun1)
          return
        end
        print( "得到的tag：", tag )
        _G.GLayerManager : openSubLayerByMapOpenId(tag)
      end
        print(" 点击结束 ",  tag )
    elseif eventType == ccui.TouchEventType.canceled then
        print(" 点击取消 ",  tag)
    end
end

function GongLueView.box_operate( self, obj, tag )
  local box_type = obj:isBright()
  if box_type then
    local idstep = 0
    if tag == self.TAG_BOX1 then
      idstep = 1
    elseif tag == self.TAG_BOX2 then
      idstep = 2
    elseif tag == self.TAG_BOX3 then
      idstep = 3
    elseif tag == self.TAG_BOX4 then
      idstep = 4
    elseif tag == self.TAG_BOX5 then
      idstep = 5
    end
    self : REQ_GONGLUE_BOX( idstep )
    print("领取宝箱奖励",box_type, idstep)
  else  
    self:boxTips(tag)
    print("宝箱tips奖励",box_type)
  end
end

function GongLueView.boxTips( self, tag )
  local idstep = nil
  local _pos   = nil
  if tag == self.TAG_BOX1 then
    idstep = 1
    _pos = self.boxBtn[1]:getWorldPosition()
  elseif tag == self.TAG_BOX2 then
    idstep = 2
    _pos = self.boxBtn[2]:getWorldPosition()
  elseif tag == self.TAG_BOX3 then
    idstep = 3
    _pos = self.boxBtn[3]:getWorldPosition()
  elseif tag == self.TAG_BOX4 then
    idstep = 4
    _pos = self.boxBtn[4]:getWorldPosition()
  elseif tag == self.TAG_BOX5 then
    idstep = 5
    _pos = self.boxBtn[5]:getWorldPosition()
  end
  local boxD = self.boxdata[idstep]
  local red  = boxD.box_red
  local temp = _G.TipsUtil : createById(red[1],nil,_pos)
  cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
end

function GongLueView.REQ_GONGLUE_HY( self )
  local msg = REQ_GONGLUE_HY()
  _G.Network:send(msg)
end

function GongLueView.REQ_GONGLUE_ACTIVITY_DAY( self, week )
  local msg = REQ_GONGLUE_ACTIVITY_DAY()
  msg:setArgs(week)
  _G.Network:send(msg)
end

function GongLueView.REQ_GONGLUE_STRONG( self, bqType )
  local arg = bqType-10110
  print("arg====", arg)
  local msg = REQ_GONGLUE_STRONG()
  msg:setArgs(arg)
  _G.Network:send(msg)
end

function GongLueView.REQ_GONGLUE_BOX( self, id )
  local msg = REQ_GONGLUE_BOX()
  msg:setArgs(id)
  _G.Network:send(msg)
end

function GongLueView.sethy( self, hy_value, box_count, boxs, hy_count, hy )
  print("准备更新啦")
  if self.hy_value~=nil and self.hy_value==hy_value then return end
  self.hy_value = hy_value
  self.box_count= box_count
  self.boxs     = boxs
  self.hy_count = hy_count
  self.hy       = hy
  --更新宝箱信息
  self:update_hy_box()
  --更新今日活动信息
  self:update_today_ac()
end

function GongLueView.update_hy_box( self )
  print("更新宝箱",self.boxs)
  for k,v in pairs(self.boxs) do
    print("更新宝箱",k,v)
    if v == 1 then
      self.boxBtn[1] : setBright(false)
      self.boxBtn[1] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
    elseif v == 2 then
      self.boxBtn[2] : setBright(false)
      self.boxBtn[2] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
    elseif v == 3 then
      self.boxBtn[3] : setBright(false)
      self.boxBtn[3] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
    elseif v == 4 then
      self.boxBtn[4] : setBright(false)
      self.boxBtn[4] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
    elseif v == 5 then
      self.boxBtn[5] : setBright(false)
      self.boxBtn[5] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
    end
  end
  self.gl_jindutiao:setPercent( self.hy_value/5 ) 
  self.todayValueLabel:setString( string.format("活跃值: %d",self.hy_value ))

  local BosSteps = _G.Cfg.gl_vitality_box
  for k,v in pairs(BosSteps) do
    if self:chickBox( v.id ) then
      if self.hy_value>=v.value then
        if v.id == 1 then
          self.boxBtn[1] : setBright(true)
        elseif v.id == 2 then
          self.boxBtn[2] : setBright(true)
        elseif v.id == 3 then
          self.boxBtn[3] : setBright(true)
        elseif v.id == 4 then
          self.boxBtn[4] : setBright(true)
        elseif v.id == 5 then
          self.boxBtn[5] : setBright(true)
        end
      end
    end
  end
end

function GongLueView.SUCCESS( self ,_data )
  print("更新宝箱",_data.id)
  if _data.id == 1 then
    self.boxBtn[1] : setBright(false)
    self.boxBtn[1] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
  elseif _data.id == 2 then
    self.boxBtn[2] : setBright(false)
    self.boxBtn[2] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
  elseif _data.id == 3 then
    self.boxBtn[3] : setBright(false)
    self.boxBtn[3] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
  elseif _data.id == 4 then
    self.boxBtn[4] : setBright(false)
    self.boxBtn[4] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
  elseif _data.id == 5 then
    self.boxBtn[5] : setBright(false)
    self.boxBtn[5] : loadTextureDisabled("gl_open.png",ccui.TextureResType.plistType)
  end
end

function GongLueView.chickBox( self, idstep)
  local res = true
  for k,v in pairs(self.boxs) do    
    if v == idstep then
      res=false
    end
  end
  return res
end

function GongLueView.update_today_ac( self )
  print("更新活跃ID")
  local vitality = _G.Cfg.gl_vitality
  self.gl_vitality = {}
  local falsehy_id = {}

  for k,v in pairs(vitality) do
    local res,hy_num = self:chickHyId( v.id,v.sum_count )
    print("self.playerlv",v.lv,v.id)

    if self.m_sysList[v.funid*10]==nil and v.id~=112 then 
    -- if self.playerlv < v.lv then
      v.state = false
      v.f_count = hy_num
      table.insert(falsehy_id,v)
    else 
      v.state  = true
      v.f_count = hy_num
      table.insert(self.gl_vitality,v)
    end
  end

  local function sortfun( hy1,hy2 )
    if hy1.sum_count == hy1.f_count then
      return false
    elseif hy2.sum_count == hy2.f_count then
      return true
    else
      return hy1.lv<hy2.lv
    end
      
  end
  table.sort(self.gl_vitality,sortfun)
  table.sort(falsehy_id,sortfun)

  for i,v in ipairs(falsehy_id) do
    table.insert(self.gl_vitality,v)
  end

  self:hyAcView()
end

function GongLueView.chickHyId( self, hyid,sum_count)
  local res = true 
  local hy_num = 0
  for k,v in pairs(self.hy) do
    print("hy-->id,hy_num",v.hy_id,v.hy_num,hyid)
    if v.hy_id == hyid then
      res    = false
      hy_num = v.hy_num
    end
    if hy_num > sum_count then
      hy_num = sum_count
    end
  end
  return res,hy_num

end
  
--   日历   
function GongLueView.activityriliView( self )
  local acbgSize = cc.size(615,475)
  self.acbgground = ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
  self.acbgground : setContentSize( acbgSize )
  self.acbgground : setPosition( cc.p( 110,-55 ) )
  self.m_tagcontainer[self.TAG_AC] : addChild( self.acbgground )

  local bgSize=cc.size(211,475) 
  self.leftacbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
  self.leftacbg : setContentSize(bgSize )
  self.leftacbg : setPosition( cc.p( -308,-55 ) )
  self.m_tagcontainer[self.TAG_AC] : addChild( self.leftacbg )

  local function touchEvent( obj, eventType )
    self:touchEventCallBack( obj, eventType )
    -- body
  end
  local oncede  = 54
  self.weekBtn  = {1,2,3,4,5,6,7}
  local weekStr = {"星 期 一","星 期 二","星 期 三","星 期 四","星 期 五","星 期 六","星 期 日"}
  local weekSize = cc.size(155,hdbgSize.height/7-4)
  for i=1, 7 do
    self.weekBtn[i] = ccui.Button:create("general_title_one.png","general_title_two.png","general_title_two.png",1)
    -- self.weekBtn[i] : setContentSize(cc.size(175,53))
    -- self.weekBtn[i] : setScale9Enabled(true)
    -- self.weekBtn[i] : setTitleFontName(_G.FontName.Heiti)
    -- self.weekBtn[i] : setTitleFontSize(FONTSIZE+4)
    -- self.weekBtn[i] : setTitleText(weekStr[i])
    -- self.weekBtn[i] : setTitleColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
    self.weekBtn[i] : setTag(i)
    self.weekBtn[i] : addTouchEventListener( touchEvent )
    self.weekBtn[i] : setPosition(-bgSize.width/2-203, bgSize.height/2-95-(i-1)*(bgSize.height/7-1) )
    self.m_tagcontainer[self.TAG_AC]:addChild( self.weekBtn[i] )

    local btnSize=self.weekBtn[i]:getContentSize()
    local weekLab=_G.Util:createLabel(weekStr[i],24)
    weekLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    weekLab:setPosition(btnSize.width/2,btnSize.height/2)
    self.weekBtn[i]:addChild(weekLab)
  end
end

function GongLueView.ActivityView( self )
  print("ActivityViewActivityViewActivityViewActivityView ", self.AcscrollView )
  -- 日历活动
  if self.AcscrollView ~=nil then
    self.AcscrollView:removeFromParent(true)
    self.AcscrollView=nil
  end
  if self.barView ~= nil then
    self.barView : remove()
    self.barView = nil
  end
  local acSize = self.acbgground :getContentSize()
  
  self.actalityBtn={}
  local oncSize = cc.size(acSize.width-12,(acSize.height-9)/4-4)
  local activitycount = #self.todayActivityIds
  self.AcscrollView = cc.ScrollView:create()
  local vsSize = cc.size(acSize.width,(acSize.height-9))
  self.AcscrollView : setViewSize(vsSize)
  self.AcscrollView : setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
  local innerSize = cc.size( vsSize.width, (acSize.height-9)/4*activitycount )
  self.AcscrollView : setContentSize(innerSize) 
  self.AcscrollView : setContentOffset(cc.p(0, (acSize.height-9)-(acSize.height-9)/4*activitycount))
  self.AcscrollView : setPosition( cc.p( 0, 5 ) )
  print(">>>>>>>>innerSizeinnerSizeinnerSize", activitycount, (acSize.height-9)/4*activitycount )
  for i,v in ipairs(self.todayActivityIds) do
    Self_num = i
    self : ac_once( oncSize, v )
  end

  local num = 1
  local NewTodayActivityIds = {}
  for i,v in ipairs(self.todayActivityIds) do
    if v.isOpen == 1 then 
      NewTodayActivityIds[num] = v
      num = num+1
    end
  end
  for i,v in ipairs(self.todayActivityIds) do
    if v.isOpen == 0 then 
      NewTodayActivityIds[num] = v
      num = num+1
    end
  end

  local icount = 1
  for k,v in ipairs(NewTodayActivityIds) do
    self.activitySprs[k] = self:ac_once( oncSize,v )
    self.activitySprs[k] : setPosition(cc.p( innerSize.width/2, innerSize.height-oncSize.height/2-4-(acSize.height-9)/4*(icount-1)) )
    self.AcscrollView: addChild( self.activitySprs[k] )
    icount = icount +1
  end
  self.acbgground:addChild( self.AcscrollView )
  if vsSize.height<innerSize.height then
    local barView=require("mod.general.ScrollBar")(self.AcscrollView)
    self.barView =barView
    barView:setPosOff(cc.p(-7,0))
  end
end

function GongLueView.ac_once( self, oncSize, idState )

  local function TimeCompare( time1, time2 )
    if time2.hour > time1.hour then 
      return true
    elseif time2.hour == time1.hour then 
      if time2.min >= time1.min then
        return true
      else
        return false
      end
    else
      return false
    end
  end

  local function touchEvent( obj, eventType )
    self:touchEventCallBack(obj, eventType)
  end
  local bg = ccui.Scale9Sprite:createWithSpriteFrameName("general_nothis.png")
  bg :setContentSize( oncSize )

  -- local line = ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
  -- local lineSprSize = line : getPreferredSize()
  -- line :setPreferredSize( cc.size( oncSize.width, lineSprSize.height ) )
  local activitydate = self.gl_strong_ids[idState.id]
  print( "需要的idState.id  = ", idState.id )

  local idSprName = string.format("%s.png",activitydate.sub_pic)
  print("idSprNameidSprNameidSprName = ", idSprName)
  local spriteFrameCache=cc.SpriteFrameCache:getInstance()
  local spriteFrame = spriteFrameCache:getSpriteFrame(idSprName)
  if spriteFrame == nil then
    idSprName = "main_icon_regulation.png"
  end
  local acidspr = cc.Sprite:createWithSpriteFrameName(idSprName)

  if activitydate.open_time[1] == 0 then
    activitydate.open_time[1] = "00"
  end
  if activitydate.open_time[2] == 0 then
    activitydate.open_time[2] = "00"
  end
  if activitydate.open_time[3] == 0 then
    activitydate.open_time[3] = "00"
  end
  if activitydate.open_time[4] == 0 then
    activitydate.open_time[4] = "00"
  end

  local startTime = { hour = string.format(activitydate.open_time[1]), min = string.format(activitydate.open_time[2]) }
  local endTime   = { hour = string.format(activitydate.open_time[3]), min = string.format(activitydate.open_time[4]) }
  local open_time = startTime.hour..":"..startTime.min.." - "..endTime.hour..":"..endTime.min

  print("open_timeopen_timeopen_time = ", open_time)
  local timeLabel    = _G.Util:createLabel( "时间 "..open_time,FONTSIZE)
  local openlvLabel  = _G.Util:createLabel( "等级: ",  FONTSIZE )
  local lvLabel  = _G.Util:createLabel(activitydate.open_lv,  FONTSIZE )
  local rewardLabel = _G.Util:createLabel( "奖励: ",FONTSIZE )
  local rewaredLabel = _G.Util:createLabel( activitydate.reward,FONTSIZE )
  if activitydate.open_time[1] == "00" and activitydate.open_time[2] == "00" and activitydate.open_time[3] == 23 and 
    activitydate.open_time[4] == 59 then
    timeLabel : setString("时间 全天开放")
  end
  local nowTime = _G.TimeUtil:getNowSeconds()
  local tempTime = os.date("*t", nowTime)

  local m_NowTime = { hour = string.format(tempTime.hour), min = string.format(tempTime.min) }

  if self.todayacti ~= self.befor_week then
    timeLabel     : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  else
    print("time",tempTime.year,tempTime.month,tempTime.day,tempTime.hour,tempTime.min)
    if TimeCompare(startTime, m_NowTime) and TimeCompare(m_NowTime, endTime) then
      timeLabel     : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    else
      timeLabel     : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    end
  end
  openlvLabel   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  if self.playerlv >= activitydate.open_lv then
    lvLabel   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  else
    lvLabel   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
  end

  rewardLabel   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)) 
  rewaredLabel  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE)) 
  
  -- 是否前 往按钮
  local acBtn  = gc.CButton:create()
  acBtn : loadTextures("general_btn_gold.png")
  -- acBtn : setTag( activitydate.enter )
  acBtn : setTag( activitydate.open )
  acBtn : setTitleFontName(_G.FontName.Heiti)
  acBtn : addTouchEventListener( touchEvent )
  
  local State = 0
  print("self.todayacti>>>>>",self.todayacti,self.befor_week)
  if self.todayacti == self.befor_week and TimeCompare(startTime, m_NowTime) and TimeCompare(m_NowTime, endTime) and idState.state == 1 then
    State = 1
  end

  if State == 1 then
    self.todayActivityIds[Self_num].isOpen = 1
    acBtn : setTitleText("前 往")
  else
    self.todayActivityIds[Self_num].isOpen = 0
    acBtn : setTitleText("未开启")
    acBtn : setTouchEnabled(false)
    acBtn : setBright(false)
  end

  acBtn : setTitleFontSize(24)
  self.actalityBtn[idState.id] = acBtn

  timeLabel    :setAnchorPoint( 0,0.5 )
  openlvLabel  :setAnchorPoint( 0,0.5 )
  lvLabel  :setAnchorPoint( 0,0.5 )
  rewaredLabel :setAnchorPoint( 0,0.5 )
  rewardLabel :setAnchorPoint( 0,0.5 )

  acidspr                       : setPosition(cc.p( 60,  oncSize.height/2 ))
  timeLabel                     : setPosition(cc.p( 140, oncSize.height/2+30 ))
  openlvLabel                   : setPosition(cc.p( 140, oncSize.height/2 ))
  lvLabel                       : setPosition(cc.p( 140+openlvLabel:getContentSize().width, oncSize.height/2 ))
  rewardLabel                   : setPosition(cc.p( 140, oncSize.height/2-30 ))
  rewaredLabel                  : setPosition(cc.p( 140+rewardLabel:getContentSize().width, oncSize.height/2-30 ))
  self.actalityBtn[idState.id]  : setPosition(cc.p( oncSize.width-75, oncSize.height/2 ))
  -- line                          : setPosition(cc.p( oncSize.width/2, 0 ))

  bg:addChild( acidspr )
  bg:addChild( timeLabel )
  bg:addChild( openlvLabel )
  bg:addChild( lvLabel )
  bg:addChild( rewardLabel )
  bg:addChild( rewaredLabel )
  bg:addChild( self.actalityBtn[idState.id] )
  -- bg:addChild( line )

  return bg
  -- body
end

function GongLueView.ac_week( self,tag )
    local bgSize=cc.size(211,475) 
    for i=1, 7 do
        if i~=tag then
            self.weekBtn[i]:setBright(true)
            self.weekBtn[i]:setEnabled(true)
            -- self.weekBtn[i]:setTitleColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
            self.weekBtn[i] : setPosition(-bgSize.width/2-203, bgSize.height/2-95-(i-1)*(bgSize.height/7-1) )
        else
            self.weekBtn[i]:setBright(false)
            self.weekBtn[i]:setEnabled(false)
            -- self.weekBtn[i]:setTitleColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
            self.weekBtn[i] : setPosition(-bgSize.width/2-200, bgSize.height/2-95-(i-1)*(bgSize.height/7-1) )
        end
    end
end

-- function GongLueView.BtnDown( self )
--   if self.BtnNode~=nil then
--     self.BtnNode:removeFromParent(true)
--     self.BtnNode=nil
--   end

--   return self.BtnNode
-- end

function GongLueView.ac_bq( self,tag )
  local bgSize=cc.size(211,475)
  local zzzz=1
  for i=10111, 10115 do
    if i ~= tag then
      self.Iwant[i]:setBright(true)
      self.Iwant[i]:setEnabled(true)
      -- self.Iwant[i] : setTitleColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
      self.Iwant[i] : setPosition(-bgSize.width/2-203, bgSize.height/2-95-(zzzz-1)*(bgSize.height/7))
    else
      self.Iwant[i]:setBright(false)
      self.Iwant[i]:setEnabled(false)
      -- self.Iwant[i] : setTitleColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
      self.Iwant[i] : setPosition(-bgSize.width/2-200, bgSize.height/2-95-(zzzz-1)*(bgSize.height/7))
    end
    zzzz=zzzz+1
  end
end


function GongLueView.setactivity( self, day, activity_count, activitys )
  print("数据已到准备跟新")
  if self.todayacti == nil then
    self.todayacti = day
  end
  if self.befor_week == nil then
    self.befor_week = day
  elseif self.befor_week ~= day then
    self.befor_week = day
  end
  print("self.befor_week", self.befor_week)
  self.useacticount = activity_count
  self.activitys    = activitys 
  self:ac_week( self.befor_week )
  local calendar = _G.Cfg.gl_calendar
  local ActivityIds = calendar[self.befor_week].idlist
  self.todayActivityIds = {}

  print("setactivitysetactivitysetactivitysetactivity11")
  for i,v in ipairs(ActivityIds) do
    local state = self:chickActivity(v)
    self.todayActivityIds[i] = {}
    self.todayActivityIds[i].id = v
    self.todayActivityIds[i].state = state
    print("self.todayActivityIds[i].state",self.todayActivityIds[i].state)
  end

  self:ActivityView()
  print("setactivitysetactivitysetactivitysetactivity22")
  -- body
end

--- 我要变强
function GongLueView.setstrong( self, type, strong_count, strongs )
  print("数据已到准备跟新setstrong", self.befor_bq)
  if self.befor_bq == nil then
    self.befor_bq = type+10110
  end

  self.usebqcount = strong_count
  self.strongs    = strongs 
  print("strongs------>", self.strongs,type)
  self:ac_bq( self.befor_bq )
  local strong = _G.Cfg.gl_strong
  local strongIds = strong[type].idlist
  local strong_id = _G.Cfg.gl_strong_id
  self.m_strongIds = {}

  print("m_strongIdsm_strongIdsm_strongIdsm_strongIdsm_strongIds")
  for i,v in ipairs(strongIds) do
    local state = self:chickstrong(v)
    self.m_strongIds[i] = {}
    self.m_strongIds[i].id = v
    self.m_strongIds[i].state = state
    self.m_strongIds[i].open_lv = strong_id[v].open_lv
    print("state",state)
  end
  -- self : update_st()
  self:StrongView()
end

function GongLueView.chickActivity( self, Acid )
  local res = 0 
  local aclv = self.gl_strong_ids[Acid]
  print("v.open_lv",self.playerlv,aclv.open_lv)
  if self.playerlv >= aclv.open_lv then
    res    = 1
  end
  print("res",res)
  return res
end

function GongLueView.chickstrong( self, stid )
  local res = false 
  local stlv = self.gl_strong_ids[stid]
  print("v.open_lv",stid,self.playerlv,stlv.open_lv)
  if self.playerlv >= stlv.open_lv then
    res    = true
  end
  return res
  -- body
end

function GongLueView.update_st( self )
  print("更新活跃ID")
  local _strong = _G.Cfg.gl_strong_id_cnf
  self.gl_strong = {}
  local falsest_id = {}

  for k,v in pairs(_strong) do
    local res,hy_num = self:chickstrong( v.sub_id )
    print("chickstrong-->",v.sub_id)
    if res then 
      v.state = false
      table.insert(falsest_id,v)
    else 
      v.state  = true
      table.insert(self.gl_strong,v)
    end
  end

  local function sortfun( st1,st2 )
      return st1.open_lv<st2.open_lv
  end
  table.sort(self.gl_strong,sortfun)
  table.sort(falsest_id,sortfun)

  for i,v in ipairs(falsest_id) do
    table.insert(self.gl_strong,v)
  end

  self:StrongView()
  -- body
end

function GongLueView.woyaobianqiangView( self )
  print("woyaobianqiangView===>>>")
  local stbgSize = cc.size(615,475)
  self.stbgground = ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
  self.stbgground : setContentSize( stbgSize )
  self.stbgground : setPosition( 110,-55 )
  self.m_tagcontainer[self.TAG_BQ] : addChild( self.stbgground )

  local bgSize=cc.size(211,475)
  self.leftacbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
  self.leftacbg : setContentSize( bgSize )
  self.leftacbg : setPosition( -308,-55 )
  self.m_tagcontainer[self.TAG_BQ] : addChild( self.leftacbg )

  local function touchEvent( obj, eventType )
    self:touchEventCallBack( obj, eventType )
  end
  local BtnSize = cc.size(155,hdbgSize.height/7-4)
  local strong  = _G.Cfg.gl_strong
  self.Iwant    = {}
  local wantStr = {"我 要 变 强","我 要 赚 钱","我 要 升 级","我 要 材 料","功 能 开 放"}
  local zzzz=1
  for i=10111,10115 do
    print("i的值:", i)
    self.Iwant[i] = ccui.Button:create("general_title_one.png","general_title_two.png","general_title_two.png",1)
    -- self.Iwant[i] : setContentSize(cc.size(175,53))
    -- self.Iwant[i] : setScale9Enabled(true)
    self.Iwant[i] : setTag(i)
    -- self.Iwant[i] : setTitleFontName(_G.FontName.Heiti)
    -- self.Iwant[i] : setTitleFontSize(FONTSIZE+4)
    -- self.Iwant[i] : setTitleText(wantStr[zzzz])
    -- self.Iwant[i] : setTitleColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
    self.Iwant[i] : addTouchEventListener( touchEvent )
    self.Iwant[i] : setPosition(-bgSize.width/2-203, bgSize.height/2-95-(zzzz-1)*(bgSize.height/7))
    self.m_tagcontainer[self.TAG_BQ] : addChild( self.Iwant[i] )

    local btnSize=self.Iwant[i]:getContentSize()
    local weekLab=_G.Util:createLabel(wantStr[zzzz],24)
    weekLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    weekLab:setPosition(btnSize.width/2,btnSize.height/2)
    self.Iwant[i]:addChild(weekLab)
    zzzz = zzzz+1
  end
  print("self.Iwant[i]",self.Iwant[10111])
  -- self.Iwant[10111] : setTitleColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  self.Iwant[10111] : setBright(false)
  self.Iwant[10111] : setEnabled(false)
end

function GongLueView.StrongView( self )
   print("StrongViewStrongViewStrongViewStrongView ", self.StscrollView )
  -- 我要变强
  if self.StscrollView ~=nil then
    self.StscrollView:removeFromParent(true)
    self.StscrollView=nil
  end
  if self.barView2 ~= nil then
    self.barView2 : remove()
    self.barView2 = nil
  end
  local StSize = self.stbgground  :getContentSize()

  self.sttivitySprs={}
  self.sttalityBtn={}
  local oncSize = cc.size(StSize.width-12,(StSize.height-9)/4-4)
  local sttivitycount = #self.m_strongIds
  self.StscrollView = cc.ScrollView:create()
  local vsSize = cc.size(StSize.width,(StSize.height-9))
  self.StscrollView : setViewSize(vsSize)
  self.StscrollView : setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
  local innerSize = cc.size( vsSize.width, (StSize.height-9)/4*sttivitycount )
  self.StscrollView : setContentSize(innerSize) 
  self.StscrollView : setContentOffset(cc.p(0, (StSize.height-9)-(StSize.height-9)/4*sttivitycount))
  self.StscrollView : setPosition( cc.p( 0, 5 ) )
  print(">>>>>>>>innerSizeinnerSizeinnerSize", sttivitycount, (StSize.height-9)/4*sttivitycount )

  local newArray={}
  for i=1,sttivitycount do
    local nTag=self.m_strongIds[i].id
    local tempCnf=_G.Cfg.gl_strong_id[nTag]
    local openId=tempCnf.enter or -100
    -- local openId=tempCnf.open or -100
    print("aaaaaaa--->",openId)
    self.m_strongIds[i].isOepn=self.m_sysList[openId]~=nil
  end

  local function sort(v1,v2)
    if v1.isOepn and not v2.isOepn then
      return true
    elseif not v1.isOepn and v2.isOepn then
      return false
    else
      return v1.open_lv<v2.open_lv
    end
  end
  table.sort( self.m_strongIds, sort )

  for k,v in ipairs(self.m_strongIds) do
    self.sttivitySprs[k] = self:st_once( oncSize,v )
    self.sttivitySprs[k] : setPosition(cc.p( innerSize.width/2, innerSize.height-oncSize.height/2-4-(StSize.height-9)/4*(k-1)) )
    self.StscrollView    : addChild( self.sttivitySprs[k] )
  end
  self.stbgground :addChild( self.StscrollView )
  if vsSize.height<innerSize.height then
    local barView=require("mod.general.ScrollBar")(self.StscrollView)
    self.barView2=barView
    barView:setPosOff(cc.p(-7.5,0))
  end
end

function GongLueView.st_once( self, oncSize, st )

  local function touchEvent( obj, eventType )
    self:touchEventCallBack(obj, eventType)
  end
  local bg = ccui.Scale9Sprite:createWithSpriteFrameName("general_nothis.png")
  bg :setContentSize( oncSize )

  -- local line = ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
  -- local lineSprSize = line : getPreferredSize()
  -- line :setPreferredSize( cc.size( oncSize.width, lineSprSize.height ) )
  local strongdate = self.gl_strong_ids[st.id]

  local idSprName = string.format("%s.png",strongdate.sub_pic)
  print("idSprNameidSprNameidSprName = ", idSprName)
  local spriteFrameCache=cc.SpriteFrameCache:getInstance()
  local spriteFrame = spriteFrameCache:getSpriteFrame(idSprName)
  if spriteFrame == nil then
    idSprName = "main_icon_regulation.png"
  end
  local stidspr = cc.Sprite:createWithSpriteFrameName(idSprName)

  local open_limit = "开启:"..strongdate.terms
  print("open_timeopen_timeopen_limit = ", open_limit)
  local openLabel    = _G.Util:createLabel("开启: ",FONTSIZE)
  local limitLabel    = _G.Util:createLabel(strongdate.terms,FONTSIZE)
  local miaosuLabel  = _G.Util:createLabel( strongdate.sub_dec,  FONTSIZE )
  miaosuLabel    : setDimensions(oncSize.width/2+50,70)
  miaosuLabel    : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
  openLabel     : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  limitLabel     : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  miaosuLabel    : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE)) 
  -- 是否前 往按钮
  local stBtn  = gc.CButton:create()
  stBtn : loadTextures("general_btn_gold.png")
  -- stBtn : setTag( strongdate.enter )
  stBtn : setTag( strongdate.open )
  stBtn : setTitleFontName(_G.FontName.Heiti)
  stBtn : addTouchEventListener( touchEvent )
  print("idState",st.state)
  if st.isOepn then
    stBtn : setTitleText("前 往")
  else
    stBtn : setTitleText("未开启")
    stBtn : setTouchEnabled(false)
    stBtn : setBright(false)
  end
  stBtn : setTitleFontSize(24)
  self.sttalityBtn[st.id] = stBtn

  openLabel   :setAnchorPoint( 0,0.5 )
  limitLabel   :setAnchorPoint( 0,0.5 )
  miaosuLabel  :setAnchorPoint( 0,0.5 )

  stidspr                       : setPosition(cc.p( 60,  oncSize.height/2 ))
  openLabel                     : setPosition(cc.p( 140, oncSize.height/2+18 ))
  limitLabel                    : setPosition(cc.p( 140+openLabel:getContentSize().width, oncSize.height/2+18 ))
  miaosuLabel                   : setPosition(cc.p( 140, oncSize.height/2-38 ))
  self.sttalityBtn[st.id]  : setPosition(cc.p( oncSize.width-75, oncSize.height/2 ))
  -- line                          : setPosition(cc.p( oncSize.width/2, 0 ))

  bg:addChild( stidspr )
  bg:addChild( openLabel )
  bg:addChild( limitLabel )
  bg:addChild( miaosuLabel )
  bg:addChild( self.sttalityBtn[st.id] )
  -- bg:addChild( line )

  return bg
  -- body
end

function GongLueView.getPlayerData( self )
  local mainplay = _G.GPropertyProxy : getMainPlay()
  -- local CharacterValue = nil 
  self.playerlv = mainplay : getLv()
  self.Time = _G.TimeUtil : getServerTimeSeconds()
end

return GongLueView