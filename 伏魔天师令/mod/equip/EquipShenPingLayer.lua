local EquipShenPingLayer = classGc(view, function(self,_uid)
    self.m_curRoleUid=_uid or 0
    self.pMediator = require("mod.equip.EquipShenPingLayerMediator")()
    self.pMediator : setView(self)

    self.m_xuanjingCount = 0 
end)

local FONT_SIZE  = 20

-- local IPriority =-10

-- local  TAGBTN_ONESTRENGTH    = 1
-- local  TAGBTN_TENSTRENGTH    = 2

function EquipShenPingLayer.__create(self)
  self.m_container = cc.Node:create()

  --外层绿色底图大小
  self.m_rootBgSize = cc.size(828,476)

  -- local l_shiSpr = cc.Sprite : createWithSpriteFrameName( "general_xuanjing.png" ) 
  -- l_shiSpr       : setPosition(240,232)
  -- self.m_container : addChild(l_shiSpr)

  -- self.m_HaveLab = _G.Util:createLabel("",FONT_SIZE)
  -- self.m_HaveLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PBLUE))
  -- self.m_HaveLab : setAnchorPoint(cc.p(0,0.5))
  -- self.m_HaveLab : setPosition(270,228)
  -- self.m_container : addChild(self.m_HaveLab )

  self.m_mainBgSprSize = cc.size(380,465)

  self.m_mainBgSpr  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
  self.m_mainBgSpr  : setPreferredSize( self.m_mainBgSprSize )
  self.m_container  : addChild(self.m_mainBgSpr)
  self.m_mainBgSpr  : setPosition(self.m_rootBgSize.width/2-self.m_mainBgSprSize.width/2-5,-55)

  --当前属性
  self.m_beforeBgSpr  = cc.Sprite:createWithSpriteFrameName("general_teshu_tubiaokuan.png")
  -- self.m_beforeBgSpr  : loadTextures() 
  -- self.m_beforeBgSpr  : addTouchEventListener(local_tipscallback)
  self.m_beforeBgSpr  : setPosition(cc.p(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height-75))
  self.m_mainBgSpr    : addChild(self.m_beforeBgSpr)

  local size = self.m_beforeBgSpr : getContentSize ()

  self.m_beforeNameLab = _G.Util:createLabel("",FONT_SIZE)
  -- self.m_beforeNameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  self.m_beforeNameLab : setPosition(size.width/2-115,-30)
  self.m_beforeBgSpr   : addChild(self.m_beforeNameLab)

  local m_arrSpr = cc.Sprite : createWithSpriteFrameName("general_tip_down.png")
  m_arrSpr : setPosition(size.width/2,-90)
  -- m_arrSpr : setRotation(270)
  self.m_beforeBgSpr :addChild(m_arrSpr)

  --升品属性
  -- self.m_afterBgSpr  = cc.Sprite:createWithSpriteFrameName("general_teshu_tubiaokuan.png")
  -- -- self.m_afterBgSpr  : addTouchEventListener(local_tipscallback2)
  -- self.m_afterBgSpr  : setPosition(cc.p(self.m_mainBgSprSize.width/2+110,self.m_mainBgSprSize.height-130))
  -- self.m_mainBgSpr   : addChild(self.m_afterBgSpr)

  -- local size = self.m_afterBgSpr : getContentSize ()
  -- local m_afterLab  = _G.Util:createLabel("升品属性",FONT_SIZE)
  -- m_afterLab        : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  -- m_afterLab        : setPosition(size.width/2,size.height+15)
  -- self.m_afterBgSpr : addChild(m_afterLab)

  self.m_afterNameLab = _G.Util:createLabel("",FONT_SIZE)
  -- self.m_afterNameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_CYANBLUE))
  self.m_afterNameLab : setPosition(size.width/2+100,-30)
  self.m_beforeBgSpr   : addChild(self.m_afterNameLab)

  self.m_beforeLab = {1,2} --附魔前
  self.m_binfoLab = {1,2} --附魔前
  self.m_afterLab  = {1,2} --附魔后
  self.m_ainfoLab = {1,2} --附魔后

  for i=1,2 do
    local beforeX = 30
    local posY    = self.m_mainBgSprSize.height/2+30-(i-1)*40
    local afterX  = 240

    self.m_beforeLab[i] = _G.Util:createLabel("",FONT_SIZE)
    self.m_beforeLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_beforeLab[i] : setPosition(cc.p(beforeX,posY))
    self.m_beforeLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_mainBgSpr    : addChild(self.m_beforeLab[i])

    self.m_binfoLab[i] = _G.Util:createLabel("",FONT_SIZE)
    self.m_binfoLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_binfoLab[i] : setPosition(cc.p(beforeX+55,posY))
    self.m_binfoLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
    self.m_mainBgSpr    : addChild(self.m_binfoLab[i])
  
    self.m_afterLab[i] = _G.Util:createLabel("",FONT_SIZE)
    self.m_afterLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_afterLab[i] : setPosition(cc.p(afterX,posY))
    self.m_afterLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_mainBgSpr   : addChild(self.m_afterLab[i])

    self.m_ainfoLab[i] = _G.Util:createLabel("",FONT_SIZE)
    self.m_ainfoLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_ainfoLab[i] : setPosition(cc.p(afterX+55,posY))
    self.m_ainfoLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
    self.m_mainBgSpr   : addChild(self.m_ainfoLab[i])
  end

  local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
  lineSpr       : setPreferredSize( cc.size(self.m_mainBgSprSize.width,lineSpr:getContentSize().height) )
  self.m_mainBgSpr    : addChild(lineSpr)
  lineSpr       : setPosition(self.m_mainBgSprSize.width/2,185)

  local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
  lineSpr       : setPreferredSize( cc.size(self.m_mainBgSprSize.width,lineSpr:getContentSize().height) )
  self.m_mainBgSpr    : addChild(lineSpr)
  lineSpr       : setPosition(self.m_mainBgSprSize.width/2,125)

  --持有消耗模块---升品模块------
  self.m_spendContainer = cc.Node:create()
  self.m_mainBgSpr : addChild(self.m_spendContainer)
  --金额显示

  local m_spendLab = {1,2,3,4}
  local m_posX  = {140,240}
  local m_color = {_G.Const.CONST_COLOR_BROWN,_G.Const.CONST_COLOR_DARKORANGE}
  for i=1,2 do
      m_spendLab[i] = _G.Util:createLabel("消耗玄铁:",FONT_SIZE)
      m_spendLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
      m_spendLab[i] : setPosition(cc.p(m_posX[i],155))
      m_spendLab[i] : setColor(_G.ColorUtil:getRGB(m_color[i]))
      self.m_spendContainer : addChild(m_spendLab[i])
  end
  self.m_needStrLab = m_spendLab[1]
  self.m_needCountLab = m_spendLab[2]

  --货币类型图标
  -- self.l_iconSpr = cc.Sprite : createWithSpriteFrameName( "general_xuanjing.png" ) 
  -- lineSpr : addChild(self.l_iconSpr)
  -- self.l_iconSpr : setPosition(200,40)

  --持有消耗模块---升阶模块------
  self.m_shenContainer = cc.Node:create()
  self.m_mainBgSpr : addChild(self.m_shenContainer)
  self.m_shenContainer : setVisible(false)

  self.m_needgoodSpr  = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
  self.m_needgoodSpr  : setPosition(self.m_mainBgSprSize.width/2,110)
  self.m_shenContainer  : addChild(self.m_needgoodSpr)

  self.needgoodCountLab = _G.Util:createLabel("1/999",FONT_SIZE)
  self.needgoodCountLab : setAnchorPoint( cc.p(1,0.0) )
  self.needgoodCountLab : setPosition(cc.p(65,8))
  self.m_needgoodSpr      : addChild(self.needgoodCountLab,3)  


  local function local_btncallback(sender, eventType) 
      return self : onBtnCallBack(sender, eventType)
  end

  local szOne ="general_btn_gold.png"
  self.m_shenpingBtn  = gc.CButton:create(szOne) 
  self.m_shenpingBtn  : setTitleFontName(_G.FontName.Heiti)
  self.m_shenpingBtn  : setTitleText("升  品")
  self.m_shenpingBtn  : setTitleFontSize(FONT_SIZE+4)
  self.m_shenpingBtn  : addTouchEventListener(local_btncallback)
  self.m_mainBgSpr    : addChild(self.m_shenpingBtn)
  self.m_shenpingBtn  : setPosition(self.m_mainBgSprSize.width/2,75)

  local tanhao = cc.Sprite : createWithSpriteFrameName( "general_tanhao.png" )
  tanhao : setPosition( 80, 25 )
  -- tanhao : setScale(0.8)
  self.m_mainBgSpr : addChild( tanhao )

  local RewardGoods = _G.Util : createLabel( "饰品分解后材料100%返还", 18 )
  RewardGoods: setPosition(200,25)
  RewardGoods : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.m_mainBgSpr : addChild( RewardGoods )

  if self.m_isGuide then
      _G.GGuideManager:registGuideData(2,self.m_shenpingBtn)
  end

  return self.m_container
end
function EquipShenPingLayer.guideDelete(self,_guideId)
    if _guideId==_G.Const.CONST_NEW_GUIDE_SYS_EQUIP_RISE and self.m_isGuide then
        _G.GGuideManager:clearCurGuideNode()
    end
end


function EquipShenPingLayer.unregister(self)
    print("EquipShenPingLayer.unregister")
    if self.pMediator ~= nil then
      self.pMediator : destroy()
      self.pMediator = nil 
    end
end


function EquipShenPingLayer.onBtnCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
      print("升品回调")

      self : REQ_MAKE_EQUIP_NEW()
    end
end

function EquipShenPingLayer.ontipsbyDataCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
        local btn_tag  = sender : getTag()
        print("物品查看 data",btn_tag)
        if btn_tag <= 0 then return end

        local Position = sender : getWorldPosition()
        local m_good = self : getGoodsByIndex(btn_tag)
        if m_good==nil then return end

        local temp = _G.TipsUtil : create(m_good,_G.Const.CONST_GOODS_SITE_OTHERROLE,Position,0)
        cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
    end
end

function EquipShenPingLayer.getGoodsByIndex( self,_index )
  local scelectData = nil
  if self.m_equipList==nil then  return scelectData end
  for k,v in pairs(self.m_equipList) do
     if _index==v.index then
        scelectData = v
        break
     end
  end
  return scelectData
end

function EquipShenPingLayer.ontipsbyIdCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
        local goodsId=sender:getTag()
        print("物品查看 id",goodsId)
        if goodsId<=0 then return end

        local goodsIdx=self.m_beforeIconSpr:getTag()
        print("=========>>>>>>",goodsIdx,self.m_newEquipPower)
        if goodsIdx==-1 or self.m_newEquipPower==nil then return end

        local goodMsg=self:getGoodsByIndex(goodsIdx)
        local nPos=sender:getWorldPosition()
        local ortherData={powerful=self.m_newEquipPower}
        -- createByCopyMsg(self,_trueGoodsId,_goodsCopy,_position,_ortherData)

        local temp = _G.TipsUtil:createByCopyMsg(goodsId,goodMsg,nPos,ortherData)
        cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
    end
end

function EquipShenPingLayer.REQ_MAKE_EQUIP_NEW( self )
    local uid   =self.m_curRoleUid
    local index =self:getNowGoodsIndex()
    print("EquipShenPingLayer fafafafa===",uid,index)
    if uid==nil  or index==nil  or index <= 0 then
        return
    end
    local msg = REQ_MAKE_EQUIP_NEW()
    msg       : setArgs(
    2, -- {1背包2装备栏}
    uid,-- {主将0|武将ID}
    index,-- {物品的idx}
    1 -- {路线（单线or多线）}
    ) 
    _G.Network  : send(msg)
end

--现在的物品当前部位
function EquipShenPingLayer.setNowGoodsPart( self,_id )
    self.NowGoodsPart = _id
end
function EquipShenPingLayer.getNowGoodsPart( self )
    return self.NowGoodsPart
end
--现在的物品框id
function EquipShenPingLayer.setNowGoodsId( self,_id )
    self.NowGoodsId = _id
end
function EquipShenPingLayer.getNowGoodsId( self )
    return self.NowGoodsId
end
--现在的物品框index
function EquipShenPingLayer.setNowGoodsIndex( self,_id )
    self.NowGoodsIndex = _id
end
function EquipShenPingLayer.getNowGoodsIndex( self )
    return self.NowGoodsIndex
end

function EquipShenPingLayer.chuangeRole(self,_uid)
    self.m_curRoleUid=_uid or 0
    self:pushData({nowGoodsIndex=self.m_curEquipIdx})
end

function EquipShenPingLayer.NetWorkReturn_MAKE_EQUIP_NEW_REPLY( self,_uid,_idx )
  --升品或是升级完
  print("升品完毕 更新页面以及发命令更新主页面")
  local data={}
  data.nowGoodsIndex = _idx
  self:pushData(data)

  --发送命令给总界面
  print("EquipShenPingLayer 发送命令给总界面")
  local _Command=EquipGoodChangeCommand(EquipGoodChangeCommand.EQUIP)
  controller:sendCommand(_Command)
end

function EquipShenPingLayer.pushData( self,_data )
  self : setNowGoodsIndex(_data.nowGoodsIndex)

  self : resetScelectPanel()
  -- self : updateMoney()
  self : getSixProxyData()

  local index       = _data.nowGoodsIndex
  local scelectData = nil
  self.m_curEquipIdx=index
  if self.m_equipList==nil then return end
  for k,v in pairs(self.m_equipList) do
     if index==v.index then
        scelectData = v
        break
     end
  end
  if scelectData==nil then  
    --发命令隐藏选中效果
    local _Command = EquipGoodChangeCommand(EquipGoodChangeCommand.DELEFFECT)
    controller:sendCommand(_Command)
    return 
  end
  self : setNowGoodsId(scelectData.goods_id)
  
  self : updateScelectPanel(scelectData.goods_id,index) 

  self.m_shenpingBtn  : setTouchEnabled(true)
  self.m_shenpingBtn  : setDefault()

end

-- function EquipShenPingLayer.updateMoney( self )
--     local m_count = self : getPlayerData("XuanJing")
--     print("EquipShenPingLayer.updateMoney",m_count)
--     self.m_HaveLab : setString(m_count)
-- end

function EquipShenPingLayer.resetScelectPanel( self )
    if self.m_beforeIconSpr ~= nil then
        self.m_beforeIconSpr : removeFromParent(true)
        self.m_beforeIconSpr = nil 
    end
    if self.m_beforeIconLab ~= nil then
        self.m_beforeIconLab : removeFromParent(true)
        self.m_beforeIconLab = nil 
    end
    if self.m_afterIconSpr ~= nil then
        self.m_afterIconSpr : removeFromParent(true)
        self.m_afterIconSpr = nil 
    end
    if self.m_needGoodIconBtn ~= nil then
        self.m_needGoodIconBtn : removeFromParent(true)
        self.m_needGoodIconBtn = nil 
    end
    self.needgoodCountLab : setString("")
    self.m_beforeNameLab : setString("")
    self.m_afterNameLab  : setString("")
    self.m_needCountLab : setString("")
    for i=1,2 do
        self.m_beforeLab[i] : setString("")
        self.m_binfoLab[i] : setString("")
        self.m_afterLab[i]  : setString("")
        self.m_ainfoLab[i] : setString("")
    end

    self.m_shenpingBtn  : setTouchEnabled(false)
    self.m_shenpingBtn  : setGray()
end

function EquipShenPingLayer.updateScelectPanel( self,_id,_index )
    print("updateScelectPanel",_id)
   local node = _G.Cfg.goods[_id]
   if node==nil then return end 
   local baseNode = node.base_type
   -- self.m_beforeBgSpr : setTag(_index)
   --当前属性

  local function local_tipscallback(sender, eventType) 
      return self : ontipsbyDataCallBack(sender, eventType)
  end
  local sprSize         = self.m_beforeBgSpr : getContentSize()
  self.m_beforeIconSpr  = _G.ImageAsyncManager:createGoodsBtn(node,local_tipscallback,_index)
  self.m_beforeIconSpr  : setPosition(sprSize.width/2-1,sprSize.height/2)
  self.m_beforeBgSpr    : addChild(self.m_beforeIconSpr)
  
  self.m_beforeIconLab = _G.Util : createLabel("装备已满品阶",FONT_SIZE+2)
  self.m_beforeIconLab : setPosition(cc.p(self.m_mainBgSprSize.width/2+110,self.m_mainBgSprSize.height/2+10))
  self.m_beforeIconLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
  self.m_mainBgSpr     : addChild(self.m_beforeIconLab)

  self.m_beforeNameLab : setString(node.name)
  self.m_beforeNameLab : setColor(_G.ColorUtil:getRGBA(node.name_color))   
  --升品后的属性－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－

  -- self.m_afterBgSpr    : setVisible(true)
  self.m_beforeIconLab : setVisible(false)

  self.nums=0
  if baseNode ~= nil then
      for k,v in pairs(baseNode) do
          local nameStr = _G.Lang.type_name[v.type] or "无"
          -- local addStr  = math.ceil(v.v/100)

          if nameStr ~= nil and self.m_beforeLab[k] ~= nil then
              self.m_beforeLab[k] : setString(nameStr..":")
              self.m_binfoLab[k] : setString(v.v)
          end
          self.nums = self.nums + 1
      end
  end

  print("self.nums==>>",self.nums)
  local beforeX = 30
  local afterX  = 240
  local posY=self.m_mainBgSprSize.height/2+10
  if self.nums == 1 then
       self.m_beforeLab[1] : setPosition(beforeX,posY)
       self.m_binfoLab[1] : setPosition(beforeX+55,posY)
       self.m_afterLab[1]  : setPosition(afterX,posY)
       self.m_ainfoLab[1]  : setPosition(afterX+55,posY)
       self.m_beforeLab[2] : setString("")
       self.m_binfoLab[2] : setString("")
       self.m_afterLab[2] : setString("")
       self.m_ainfoLab[2] : setString("")
  else
    for i=1,2 do
      posY = self.m_mainBgSprSize.height/2+30-(i-1)*40
      self.m_beforeLab[i]:setPosition(beforeX,posY)
      self.m_binfoLab[i]:setPosition(beforeX+55,posY)
      self.m_afterLab[i]:setPosition(afterX,posY)
      self.m_ainfoLab[i]:setPosition(afterX+55,posY)
    end
  end

  local equipnode=_G.Cfg.equip_make[_id]
  local m_count = self : getPlayerData("XuanJing")
  print("equipnodeequipnodeequipnodeequipnode",equipnode)
  if equipnode==nil then 
    -- self.m_afterBgSpr    : setVisible(false)
    self.m_beforeIconLab : setVisible(true)
    self.m_needCountLab:setString(string.format("%d/0",m_count))
    local labWidth=self.m_needCountLab:getContentSize().width
    self.m_needCountLab:setPosition(240-labWidth/2,155)
    self.m_needStrLab:setPosition(140-labWidth/2,155)
    for i=1,2 do
      self.m_afterLab[i]:setString("")
      self.m_ainfoLab[i]:setString("")
    end
    return 
  end
  local nextid = equipnode.make1.goods
  print("nextidnextidnextidnextidnextidnextid",nextid)
  if nextid==nil then
    -- self.m_afterBgSpr    : setVisible(false)
    self.m_beforeIconLab : setVisible(true)
    self.m_needCountLab:setString(string.format("%d/0",m_count))
    local labWidth=self.m_needCountLab:getContentSize().width
    self.m_needCountLab:setPosition(240-labWidth/2,155)
    self.m_needStrLab:setPosition(140-labWidth/2,155)
    for i=1,2 do
      self.m_afterLab[i]:setString("")
      self.m_ainfoLab[i]:setString("")
    end
    return 
  end
  local nextnode = _G.Cfg.goods[nextid]
  print("nextnodenextnodenextnodenextnodenextnode",nextnode)
  if nextnode==nil then  
    -- self.m_afterBgSpr    : setVisible(false)
    self.m_beforeIconLab : setVisible(true)
    self.m_needCountLab:setString(string.format("%d/0",m_count))
    local labWidth=self.m_needCountLab:getContentSize().width
    self.m_needCountLab:setPosition(240-labWidth/2,155)
    self.m_needStrLab:setPosition(140-labWidth/2,155)
    for i=1,2 do
      self.m_afterLab[i]:setString("")
      self.m_ainfoLab[i]:setString("")
    end
    return 
  else
      for k,v in pairs(nextnode.base_type) do
          local nameStr = _G.Lang.type_name[v.type] or "无"
          -- local addStr  = math.ceil(v.v/100)

          if nameStr ~= nil and self.m_beforeLab[k] ~= nil then
              self.m_afterLab[k] : setString(nameStr..":")
              self.m_ainfoLab[k] : setString(v.v)
          end
          -- self.nums = self.nums + 1
      end
  end 
  
  --升品属性
    
  local function local_tipscallback2(sender, eventType) 
      return self : ontipsbyIdCallBack(sender, eventType)
  end
  -- self.m_afterBgSpr : setTag(nextid)
  -- local sprSize        = self.m_afterBgSpr : getContentSize()
  -- self.m_afterIconSpr  = _G.ImageAsyncManager:createGoodsBtn(nextnode,local_tipscallback2,nextid)
  -- self.m_afterIconSpr  : setPosition(sprSize.width/2-1,sprSize.height/2)
  -- self.m_afterBgSpr    : addChild(self.m_afterIconSpr)
  
  self.m_afterNameLab  : setString(nextnode.name)
  self.m_afterNameLab : setColor(_G.ColorUtil:getRGBA(nextnode.name_color))   

  self.m_spendContainer : setVisible(false)
  self.m_shenContainer  : setVisible(false)  
  --消耗玄铁
  if equipnode.make1.virtual ~= nil and equipnode.make1.virtual[1] ~= nil  then
     self.m_shenpingBtn:setTitleText("升品")

     self.m_spendContainer:setVisible(true)

      local needCount=equipnode.make1.virtual[1][2] or 0
      self.count = needCount
      self.m_needCountLab:setString(string.format("%d/%d",m_count,needCount))
      if m_count<needCount then
        self.m_needCountLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
      else
        self.m_needCountLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
      end
      local labWidth = self.m_needCountLab:getContentSize().width
      self.m_needCountLab:setPosition(240-labWidth/2,155)
      self.m_needStrLab:setPosition(140-labWidth/2,155)
  else
     self.m_shenpingBtn:setTitleText("神铸")
     
     self.m_shenContainer:setVisible(true)
      --需要物品
     local id     = equipnode.make1.goods_list[1][1] or 0 
     local count  = equipnode.make1.goods_list[1][2] or 0
      
     local node   = _G.Cfg.goods[id]
     if node==nil then return end

     local function nFun( sender, eventType )
        if eventType==ccui.TouchEventType.ended then
            local btn_tag  = sender:getTag()
            print("物品查看 data",btn_tag)
            local Position = sender:getWorldPosition()
            local temp = _G.TipsUtil:createById(btn_tag,nil,Position)
            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
        end
    end
     local sprSize           = self.m_needgoodSpr:getContentSize()
     self.m_needGoodIconBtn  = _G.ImageAsyncManager:createGoodsBtn(node,nFun,id)
     self.m_needGoodIconBtn  : setPosition(sprSize.width/2-1,sprSize.height/2)
     self.m_needgoodSpr      : addChild(self.m_needGoodIconBtn)

     local nHaveCount = self:getCountById(id)

     self.needgoodCountLab:setString(nHaveCount.."/"..count)
  end

  self.m_newEquipPower=nil
  local msg=REQ_MAKE_EQUIP_NEXT()
  msg:setArgs(2,self.m_curRoleUid,_index)
  _G.Network:send(msg)
end

function EquipShenPingLayer.getCountById( self ,_id )
    local propArray=_G.GBagProxy:getPropsList() or {}
    local goodsCount=0
    for k,v in pairs(propArray) do
        if v.goods_id==_id then
            goodsCount=goodsCount+v.goods_num
        end
    end
    return goodsCount
end

function EquipShenPingLayer.getSixProxyData(self)
    local mainplay = nil
    if self.m_curRoleUid==0 then
        print("getSixProxyData===>>>mi")
        mainplay    = _G.GPropertyProxy:getMainPlay()
    else
        print("getSixProxyData===>>>no mi")
        local m_uid = _G.GPropertyProxy:getMainPlay():getUid()
        local index = tostring( m_uid)..tostring( self.m_curRoleUid )
        mainplay    = _G.GPropertyProxy :getOneByUid( index, _G.Const.CONST_PARTNER)
    end

    if mainplay==nil then return end
    print("getSixProxyData===>>>  have")
    self.m_equipCount = mainplay : getEquipCount() --装备数量
    self.m_equipList  = mainplay : getEquipList()  --装备数据
end

function EquipShenPingLayer.NetWorkReturn_MAKE_EQUIP_NEXT_REPLY(self,_power)
    self.m_newEquipPower=_power
end

-- function EquipShenPingLayer.getPartTypeByNo( self,_no )
--     local m_no = nil 
--     if _no==1 then
--       m_no = _G.Const.CONST_EQUIP_WEAPON
--     elseif _no==2 then
--       m_no = _G.Const.CONST_EQUIP_NECKLACE
--     elseif _no==3 then
--       m_no = _G.Const.CONST_EQUIP_RING
--     elseif _no==4 then
--       m_no = _G.Const.CONST_EQUIP_ARMOR
--     elseif _no==5 then
--       m_no = _G.Const.CONST_EQUIP_CLOAK
--     elseif _no==6 then
--       m_no = _G.Const.CONST_EQUIP_SHOE
--     end 

--     return m_no 
-- end

function EquipShenPingLayer.getPlayerData( self,_CharacterName )
    local mainplay = _G.GPropertyProxy : getMainPlay()
    local CharacterValue = nil 

    if     _CharacterName=="Lv" then
        CharacterValue = mainplay : getLv()
    elseif _CharacterName=="Power" then
        CharacterValue = mainplay : getPowerful()
    elseif _CharacterName=="Pro" then
        CharacterValue = mainplay : getPro()
    elseif _CharacterName=="Vip" then
        CharacterValue = mainplay : getVipLv()
    elseif _CharacterName=="XuanJing" then
        CharacterValue = mainplay : getXuanJing()
    elseif _CharacterName==MONEYTYPE_GOLD then
        CharacterValue = mainplay : getGold()
    elseif _CharacterName==MONEYTYPE_RMB then
        CharacterValue = mainplay :getRmb() + mainplay :getBindRmb()
    elseif _CharacterName==MONEYTYPE_JADE then
        CharacterValue = 1
    end

    return CharacterValue
end

function EquipShenPingLayer.ShengPinSuccEffect(self,flag)
    print("升品成功特效",flag)
    if self.tempObj~=nil then
        self.tempObj:start()
        return
    end
    local sizes          = self.m_beforeBgSpr : getContentSize ()  
    local tempGafAsset=gaf.GAFAsset:create("gaf/shengpinchenggong.gaf")
    self.tempObj=tempGafAsset:createObject()
    local nPos=cc.p(sizes.width/2,sizes.height/2)
    self.tempObj:setLooped(false,false)
    self.tempObj:start()
    self.tempObj:setPosition(nPos)
    self.m_beforeBgSpr : addChild(self.tempObj,1000)
end

function EquipShenPingLayer.bagGoodsUpdate(self)
	print("物品更新了121211212")

	print(self.m_needCountLab,self.count)
	if self.m_needCountLab~=nil and self.count~=nil then
		local nCount = self : getPlayerData("XuanJing")
		self.m_needCountLab:setString(tostring(nCount).."/"..self.count)
    local labWidth=self.m_needCountLab:getContentSize().width
    self.m_needCountLab:setPosition(240-labWidth/2,155)
    self.m_needStrLab:setPosition(140-labWidth/2,155)
		if nCount<self.count then 
	      self.m_needCountLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	    else
	      self.m_needCountLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	    end
	end
end

return EquipShenPingLayer