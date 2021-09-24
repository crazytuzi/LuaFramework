local GoldView = classGc(view, function(self,playuid)
    self.pMediator = require("mod.role.GoldViewMediator")()
    self.pMediator : setView(self)

    self.playeruid = playuid or 0
    self.m_mainPlay=_G.GPropertyProxy:getMainPlay()
    -- self.m_spineResArray={}
end)

local FONT_SIZE = 24
local MAXSTAGE  = _G.Const.CONST_MATIAX_MAXSTAGE
local MAXLV     = _G.Const.CONST_MATIAX_MAXLV
local NO_page   = 0

local m_winSize = cc.Director:getInstance():getWinSize()
--外层绿色底图大小
local m_rootBgSize = cc.size(828,476)
--左边框大小
local leftSize = cc.size(m_rootBgSize.width/2-10,m_rootBgSize.height-12)
--右边框大小
local rightSize = cc.size(m_rootBgSize.width/2-10,m_rootBgSize.height-12)

function GoldView.__create(self)
  self.m_container = cc.Node:create()

  --左边内容－－－－－－－－－－－－－－－－－－－－－－－－－－－
  self.m_bgSpr1    = cc.Sprite : create( "ui/bg/role_dazuobg.png" ) 
  -- self.m_bgSpr1    : setContentSize( leftSize )
  self.m_bgSpr1    : setPosition(-(m_rootBgSize.width/2-leftSize.width/2-5),-80)
  self.m_container : addChild(self.m_bgSpr1)

  local lbgSize = self.m_bgSpr1:getContentSize()
  -- local dazuobg=cc.Sprite : create( "ui/bg/role_dazuobg.png" ) 
  -- dazuobg:setPosition(lbgSize.width/2-15,lbgSize.height/2)
  -- self.m_bgSpr1 : addChild(dazuobg)
  
  self.loginLab = _G.Util : createLabel("",FONT_SIZE+2)
  self.loginLab : setPosition(cc.p(lbgSize.width/2, lbgSize.height+45))
  self.loginLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.m_bgSpr1 : addChild(self.loginLab)

  --直线
  -- local uplineSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
  -- lineSize  = uplineSpr : getContentSize()
  -- uplineSpr : setPreferredSize(cc.size(leftSize.width-4, lineSize.height))
  -- uplineSpr : setPosition(leftSize.width/2, leftSize.height-37)
  -- self.m_bgSpr1 : addChild(uplineSpr)

  --右边内容－－－－－－－－－－－－－－－－－－－－－－－－－－－
  
  self.m_bgSpr2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
  self.m_bgSpr2 : setPreferredSize( rightSize )
  self.m_container : addChild(self.m_bgSpr2)
  self.m_bgSpr2 : setPosition(m_rootBgSize.width/2-rightSize.width/2-5,-56)

  -- local uplineSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
  -- uplineSpr : setPreferredSize(cc.size(rightSize.width-4, lineSize.height))
  -- uplineSpr : setPosition(rightSize.width/2, rightSize.height-37)
  -- self.m_bgSpr2  : addChild(uplineSpr)

  print("self.playeruid",self.playeruid)
  self : NetWorkSend(self.playeruid) -- 获取数据
  return self.m_container
end

function GoldView.NetWorkSend(self,id)
    --向服务器发送页面数据请求
    local msg = REQ_MATRIX_REQUEST()
    msg : setArgs(id)
    _G.Network : send(msg)
end

function GoldView.pushData(self,_data)
  print("pushData",_data.uid)
  -- 8个属性 修炼按钮名字
  self : rightattribute(_data) --直接刷新
  -- 页数
  self : leftvortex(_data)
end

function GoldView.leftvortex( self,_data )
  self.node  = _data.node
  self.grade = _data.grade
  local leftSize = self.m_bgSpr1 : getContentSize()
  -- local dazuobg  = cc.Sprite : create( "ui/bg/role_dazuobg.jpg" ) 
  -- -- dazuobg : setPreferredSize(cc.size(leftSize.width-6, leftSize.height-42))
  -- dazuobg : setPosition(leftSize.width/2, leftSize.height/2-15)
  -- self.m_bgSpr1  : addChild(dazuobg) 

  -- local szPlist="anim/effect_jinshen.plist"
  -- local szFram="effect_jinshen_"
  -- local act1=_G.AnimationUtil:createAnimateAction(szPlist,szFram,0.1)
  
  -- local effectSpr=cc.Sprite:create()
  -- effectSpr:runAction(cc.RepeatForever:create(act1))
  -- effectSpr:setPosition(leftSize.width/2,leftSize.height/2-32)
  -- self.m_bgSpr1:addChild(effectSpr)

  -- local szSpineName="spine/jinshen"
  -- self.m_spineResArray[szSpineName]=true
  -- local spine = _G.SpineManager.createSpine(szSpineName,1)
  -- spine : setPosition(leftSize.width/2+10,leftSize.height/2-160)
  -- spine : setAnimation(0,"idle",true)
  -- self.m_bgSpr1 : addChild(spine)
  local lbgSize = self.m_bgSpr1:getContentSize()
  local posX = {lbgSize.width/2+95,lbgSize.width/2+30,lbgSize.width/2-40,lbgSize.width/2-100,
                lbgSize.width/2-20,lbgSize.width/2-105,lbgSize.width/2-27,lbgSize.width/2-33}
  local posY = {lbgSize.height/2-90,lbgSize.height/2-45,lbgSize.height/2-45,lbgSize.height/2-80,
                lbgSize.height/2+15,lbgSize.height-115,lbgSize.height-95,lbgSize.height-30}
  local function vortexupdate(sender,eventType)
    if eventType==ccui.TouchEventType.ended then
      local tag  = sender : getTag()
      local _pos = sender : getWorldPosition()
      self.temp = self : NodeTips(tag)
      self.temp : setPosition(posX[tag], posY[tag]+35)
      self.m_bgSpr1   : addChild(self.temp,1000)
      print("节点",tag)
    end
  end

  local action = cc.RepeatForever:create(cc.RotateBy:create(1,360))
  self.vortex= {}
  self.drawline={}
  print("self.grade",self.grade)
  if self.grade > MAXSTAGE then
    -- self.grade = MAXSTAGE
    for i=1,MAXLV do
      self:addDrawLine(i,true)

      self.vortex[i] = gc.CButton : create("role_btntrue.png")
      self.vortex[i] : setPosition(posX[i],posY[i])
      self.vortex[i] : setTag(i)
      self.vortex[i] : addTouchEventListener(vortexupdate)
      self.vortex[i] : runAction(action:clone())
      self.vortex[i] : setButtonScale(0.6)
      self.m_bgSpr1 : addChild(self.vortex[i],5)
    end
  else
    for i=1,self.node do
      self:addDrawLine(i,true)

      self.vortex[i] = gc.CButton : create("role_btntrue.png")
      self.vortex[i] : setPosition(posX[i],posY[i])
      self.vortex[i] : setTag(i)
      self.vortex[i] : addTouchEventListener(vortexupdate)
      self.vortex[i] : runAction(action:clone())
      self.vortex[i] : setButtonScale(0.6)
      self.m_bgSpr1 : addChild(self.vortex[i],5)
    end
    for i=self.node+1,8 do
      self:addDrawLine(i)

      self.vortex[i] = gc.CButton : create("role_btnfalse.png")
      self.vortex[i] : setPosition(posX[i],posY[i])
      self.vortex[i] : setTag(i)
      self.vortex[i] : addTouchEventListener(vortexupdate)
      self.vortex[i] : runAction(action:clone())
      self.vortex[i] : setButtonScale(0.6)
      self.m_bgSpr1 : addChild(self.vortex[i],5)
    end
  end
end

function GoldView.addDrawLine(self,i,_type)
  if self.drawline[i]~=nil then
    self.drawline[i]:removeFromParent(true)
    self.drawline[i]=nil
  end
  local c4fcolor=cc.c4f(87/255,67/255,74/255,1)
  if _type then
    c4fcolor=cc.c4f(152/255,112/255,15/255,1)
  end
  local lbgSize = self.m_bgSpr1:getContentSize()
  local posX = {lbgSize.width/2+95,lbgSize.width/2+30,lbgSize.width/2-40,lbgSize.width/2-100,
                lbgSize.width/2-20,lbgSize.width/2-105,lbgSize.width/2-27,lbgSize.width/2-33}
  local posY = {lbgSize.height/2-90,lbgSize.height/2-45,lbgSize.height/2-45,lbgSize.height/2-80,
                lbgSize.height/2+15,lbgSize.height-115,lbgSize.height-95,lbgSize.height-30}
  if posX[i-1]~=nil then
    self.drawline[i] = cc.DrawNode : create()--绘制线条
    self.drawline[i] : drawSegment(cc.p(posX[i-1],posY[i-1]), cc.p(posX[i],posY[i]), 2,c4fcolor)
    self.m_bgSpr1 : addChild(self.drawline[i])
  end
end

function GoldView.NodeTips(self,node)
    local function onTouchBegan(touch,event)
      local touchPoint=touch:getStartLocation()
      print("onTouchBegan=====>>>",touchPoint.x,touchPoint.y)
      for k,v in pairs(self.vortex) do
        local arPoint=v:getAnchorPoint()
        local nodeSize=v:getContentSize()
        local forNodePos=v:convertToNodeSpaceAR(touchPoint)
        local touchRect=cc.rect(-arPoint.x*nodeSize.width,-arPoint.y*nodeSize.height,nodeSize.width,nodeSize.height)
        if not cc.rectContainsPoint(touchRect,forNodePos) then
          if self.temp ~= nil then
            self.temp:removeFromParent(true)
            self.temp=nil
          end
        end
      end
    end
    local listerner= cc.EventListenerTouchOneByOne:create()
    listerner      : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner      : setSwallowTouches(true)

    local tipskuang= ccui.Scale9Sprite:createWithSpriteFrameName("general_bagkuang.png")
    local grade = self.grade
    if grade > MAXSTAGE then grade = MAXSTAGE end
    local constant = _G.Cfg.matrix[grade][node].constant
    local names    = constant[1][1]
    local addnums  = constant[1][2]
    local typename = _G.Lang.type_name[names]
    local tipsLab  = _G.Util : createLabel(typename.."+"..addnums,FONT_SIZE-4)
    local LabSize  = tipsLab : getContentSize()
    tipskuang : setPreferredSize(cc.size(LabSize.width+20,40))
    local tipsSize = tipskuang : getContentSize()
    tipsLab : setPosition(cc.p(tipsSize.width/2,tipsSize.height/2+2))
    -- tipsLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
    tipskuang : addChild(tipsLab)

    tipskuang:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,tipskuang)
    return  tipskuang
end

function GoldView.returnvortex(self,_page,node)
  print("returnvortex",_page)
  if _page > MAXSTAGE then
    for i=1,MAXLV do
      self:addDrawLine(i,true)
      self.vortex[i] : loadTextures("role_btntrue.png")
    end
  else
    for i=1,node do
      self:addDrawLine(i,true)
      self.vortex[i] : loadTextures("role_btntrue.png")
    end
    for i=node+1,MAXLV do
      self:addDrawLine(i)
      self.vortex[i] : loadTextures("role_btnfalse.png")
    end
  end
end

function GoldView.rightattribute(self,_data)
    local powerSpr=cc.Sprite:createWithSpriteFrameName("main_fighting.png")
    powerSpr:setPosition(rightSize.width/2,rightSize.height-45)
    self.m_bgSpr2:addChild(powerSpr)

    local m_playerLab = _G.Util : createLabel("永久增加属性",FONT_SIZE-2)
    m_playerLab : setPosition(rightSize.width/2,rightSize.height-45)
    m_playerLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_bgSpr2: addChild(m_playerLab)
    --属性－－－－－－－－－－

    local doubleSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
    doubleSpr:setPreferredSize(cc.size(353,223))
    doubleSpr:setPosition(rightSize.width/2,rightSize.height/2+38)
    self.m_bgSpr2: addChild(doubleSpr)

    self.m_PropLab = {1,2,3,4,5,6,7,8}
    self.m_PropInfoLab= {1,2,3,4,5,6,7,8}
    local bgSize = cc.size(rightSize.width/2,46)
    local YHEIGHT = rightSize.height-80
    local spaceY = bgSize.height
    local posX = {bgSize.width/2,bgSize.width*1.3,bgSize.width/2,bgSize.width*1.3,
                    bgSize.width/2,bgSize.width*1.3,bgSize.width/2,bgSize.width*1.3}
    local posY = {YHEIGHT-spaceY,YHEIGHT-spaceY,YHEIGHT-2*spaceY,YHEIGHT-2*spaceY,
                YHEIGHT-3*spaceY,YHEIGHT-3*spaceY,YHEIGHT-4*spaceY,YHEIGHT-4*spaceY}
    local prop_img  = {"general_att.png","general_hp.png","general_wreck.png","general_def.png","general_hit.png",
                      "general_dodge.png","general_crit.png","general_crit_res.png","general_bonus.png","general_reduc.png"}
    for i=1,8 do
      -- if i % 2 == 1 then
      --     local titlebgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_titlebg.png")
      --     local titleHeight=titlebgSpr:getContentSize().height
      --     titlebgSpr:setPreferredSize(cc.size(rightSize.width+80,titleHeight))
      --     titlebgSpr:setPosition(rightSize.width/2,posY[i])
      --     self.m_bgSpr2 : addChild(titlebgSpr)
      -- end
      local m_bgSpr = cc.Sprite : createWithSpriteFrameName( prop_img[i] ) 
      m_bgSpr : setPosition(posX[i]-50,posY[i])
      self.m_bgSpr2 : addChild(m_bgSpr)

      self.m_PropLab[i] = _G.Util : createLabel("",FONT_SIZE-4)
      self.m_PropLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
      self.m_PropLab[i] : setPosition(posX[i]-30,posY[i]-2)
      self.m_PropLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
      self.m_bgSpr2    : addChild(self.m_PropLab[i])

      self.m_PropInfoLab[i] = _G.Util : createLabel("",FONT_SIZE-4)
      self.m_PropInfoLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
      self.m_PropInfoLab[i] : setPosition(posX[i]+20,posY[i]-2)
      self.m_PropInfoLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
      self.m_bgSpr2    : addChild(self.m_PropInfoLab[i])
    end

    --直线
    -- local m_lineSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
    -- local m_lineSprSize = m_lineSpr : getPreferredSize()
    -- m_lineSpr           : setPreferredSize( cc.size(rightSize.width+8,m_lineSprSize.height) )
    -- m_lineSpr           : setPosition(cc.p(rightSize.width/2+22,-20))
    -- self.m_bgSpr2   : addChild(m_lineSpr)

    self.xhaoLab  = _G.Util : createLabel("消耗星石：",FONT_SIZE-4)
    self.xhaoLab : setAnchorPoint( cc.p(0.0,0.5) )
    self.xhaoLab  : setPosition(cc.p(rightSize.width/2-50,130))
    self.xhaoLab  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_bgSpr2 : addChild(self.xhaoLab)

    self.xhaonumLab = _G.Util : createLabel("",FONT_SIZE-4)
    self.xhaonumLab : setAnchorPoint( cc.p(0.0,0.5) )
    self.xhaonumLab : setPosition(cc.p(rightSize.width/2+50,130))
    self.xhaonumLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.xhaonumLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
    self.m_bgSpr2 : addChild(self.xhaonumLab)

    -- local m_starSpr = gc.GraySprite : createWithSpriteFrameName("general_star2.png")
    -- m_starSpr : setPosition(cc.p(rightSize.width/2+30,rightSize.height/3+8))
    -- m_starSpr : setScale(1.3)
    -- self.m_bgSpr2 : addChild(m_starSpr)

    local xhaoLab  = _G.Util : createLabel("达成副本评价可以获得星石！",FONT_SIZE-6)
    xhaoLab  : setPosition(cc.p(rightSize.width/2,93))
    xhaoLab  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_bgSpr2 : addChild(xhaoLab)

    -- local tanhaoSpr = gc.GraySprite : createWithSpriteFrameName("general_tanhao.png")
    -- tanhaoSpr : setPosition(cc.p(65,rightSize.height/3-37))
    -- self.m_bgSpr2 : addChild(tanhaoSpr)

    local function btn_update(sender,eventType)
      if eventType==ccui.TouchEventType.ended then
        if self.grade > MAXSTAGE then
          local command = CErrorBoxCommand(34160)
          controller :sendCommand( command )
          return
        else
          print("修炼",self.grade,self.node)
          local msg = REQ_MATRIX_LIGHTS()
          -- msg : setArgs()--self.grade,self.node+1
          _G.Network : send(msg)
        end
      end
    end

    self.m_UpdateBtn = gc.CButton:create("general_btn_gold.png") 
    self.m_UpdateBtn : setTitleText("修 炼")
    self.m_UpdateBtn : addTouchEventListener(btn_update)
    self.m_UpdateBtn : setTitleFontSize(FONT_SIZE)
    self.m_UpdateBtn : setTitleFontName(_G.FontName.Heiti)
    self.m_UpdateBtn : setPosition(cc.p(rightSize.width/2,42))
    self.m_bgSpr2 : addChild(self.m_UpdateBtn)
    self : updatePanelData(_data)

    local uid = self.m_mainPlay : getUid()
    print("mainplay",uid,_data.uid)
    if _data.uid ~= uid then
      self.m_UpdateBtn : setBright(false)
      self.m_UpdateBtn : setEnabled(false)
    else
      local guideId=_G.GGuideManager:getCurGuideId()
      if guideId==_G.Const.CONST_NEW_GUIDE_SYS_GOLD
        or guideId==_G.Const.CONST_NEW_GUIDE_SYS_GOLD2 then
          _G.GGuideManager:registGuideData(2,self.m_UpdateBtn)
          _G.GGuideManager:runNextStep()

          if guideId==_G.Const.CONST_NEW_GUIDE_SYS_GOLD2 then
              self.m_guide_xiulian=2
          else
              self.m_guide_xiulian=1
          end
      end
    end
end

function GoldView.lightok( self,_data )
    self.grade = _data.grade
    print("lightok-->nodegrade",_data.node,_data.grade)
    self : updatePanelData(_data)
    self : returnvortex(self.grade,self.node)
    _G.Util:playAudioEffect("ui_goldbody")

    if self.m_guide_xiulian~=nil then
        if _data.node>=self.m_guide_xiulian then
            if _data.node==1 then
                _G.Util:playAudioEffect("sys_goldbody")
            end
            self.m_guide_xiulian=nil
            _G.GGuideManager:runNextStep()
        end
    end
end

function GoldView.updatePanelData( self,_data)
    print("updatePanelData",_data.grade,_data.node,MAXSTAGE)
    local grade = _data.grade or 1
    self.node  = _data.node or 0
    if grade > MAXSTAGE then
      grade = MAXSTAGE
      local name = _G.Cfg.matrix[grade][1].name
      self.loginLab : setString(name)
      local power = _G.Cfg.matrix[grade][MAXLV].power
      if self.playeruid~=0 then
        self.xhaonumLab : setString("0/0")
      else
        self.xhaonumLab : setString(string.format("%d/0",_data.stone))
        if _data.stone<power[1][2] then
          self.xhaonumLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
        end
      end
      local labWidth=self.xhaonumLab:getContentSize().width
      self.xhaoLab  : setPosition(cc.p(rightSize.width/2-50-labWidth/2,130))
      self.xhaonumLab : setPosition(cc.p(rightSize.width/2+50-labWidth/2,130))

      for i=1,MAXLV do
        local constant = _G.Cfg.matrix[grade][i].constant
        local all = _G.Cfg.matrix[grade][i].all
        print("goldData",constant[1][2],constant[1][1])
        local value = all[1][2]
        local names = constant[1][1]
        local typename = _G.Lang.type_name[names]
        self.m_PropLab[i] : setString(string.format("%s:",typename))
        self.m_PropInfoLab[i] : setString(value)
      end
    else
      --八个个属性
      for i=1,self.node do
        local constant = _G.Cfg.matrix[grade][i].constant
        local all = _G.Cfg.matrix[grade][i].all
        print("goldData",constant[1][2],constant[1][1])
        local value = all[1][2]
        local names = constant[1][1]
        local typename = _G.Lang.type_name[names]
        self.m_PropLab[i] : setString(string.format("%s:",typename))
        self.m_PropInfoLab[i] : setString(value)
      end
      for i=self.node+1, MAXLV do
        if grade-1 > 0 then 
          local constant = _G.Cfg.matrix[grade-1][i].constant
          local all = _G.Cfg.matrix[grade-1][i].all
          print("goldData",constant, constant[1],constant[1][2])
          local value = all[1][2]
          local names = constant[1][1]
          local typename = _G.Lang.type_name[names]
          self.m_PropLab[i] : setString(string.format("%s:",typename))
          self.m_PropInfoLab[i] : setString(value)
        elseif grade-1 <= 0 then
          local constant = _G.Cfg.matrix[1][i].constant
          local names = constant[1][1]
          local typename = _G.Lang.type_name[names]
          self.m_PropLab[i] : setString(string.format("%s:",typename))
          self.m_PropInfoLab[i] : setString(0)
        end
      end
      local name = _G.Cfg.matrix[grade][1].name
      self.loginLab : setString(name)
      local power = _G.Cfg.matrix[grade][self.node+1].power
      if self.playeruid~=0 then
        self.xhaonumLab : setString(string.format("0/0"))        
      else
        self.xhaonumLab : setString(string.format("%d/%d",_data.stone,power[1][2]))
        if _data.stone<power[1][2] then
          self.xhaonumLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
        end
      end
      local labWidth=self.xhaonumLab:getContentSize().width
      self.xhaoLab  : setPosition(cc.p(rightSize.width/2-50-labWidth/2,130))
      self.xhaonumLab : setPosition(cc.p(rightSize.width/2+50-labWidth/2,130))
    end
end

function GoldView.unregister(self)
    print("GoldView.unregister")
    if self.pMediator ~= nil then
      self.pMediator : destroy()
      self.pMediator = nil 
    end
    -- _G.SpineManager.releaseSpineInView(self.m_spineResArray)
end

return GoldView