local EquipFuMoLayer = classGc(view, function(self,_uid)
    self.m_curRoleUid=_uid or 0
    self.pMediator = require("mod.equip.EquipFuMoLayerMediator")(self)
end)

local FONT_SIZE  = 20

local FUMOID = 43000

function EquipFuMoLayer.__create(self)
  self.m_container = cc.Node:create()

  --外层绿色底图大小
  self.m_rootBgSize = cc.size(828,476)

  -- local l_shiSpr = cc.Sprite : createWithSpriteFrameName( "general_fumoshi.png" ) 
  -- l_shiSpr       : setPosition(250,232)
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

  self.m_partBgSpr  = cc.Sprite : createWithSpriteFrameName("general_teshu_tubiaokuan.png")
  self.m_partBgSpr  : setPosition(cc.p(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height-75))
  self.m_mainBgSpr  : addChild(self.m_partBgSpr)

  local size = self.m_partBgSpr : getContentSize ()

  self.partNameLab = _G.Util:createLabel("武器",FONT_SIZE)
  self.partNameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE))
  self.partNameLab : setPosition(size.width/2,-25)
  self.m_partBgSpr : addChild(self.partNameLab)

  self.m_arrSpr = cc.Sprite : createWithSpriteFrameName("general_tip_down.png")
  self.m_arrSpr : setPosition(size.width/2,-90)
  -- self.m_arrSpr : setRotation(270)
  self.m_partBgSpr :addChild(self.m_arrSpr)


  self.m_beforeLab = {1,2,3} --附魔前
  self.m_binfoLab = {1,2,3} --附魔前
  self.m_afterLab  = {1,2,3} --附魔后
  self.m_ainfoLab = {1,2,3} --附魔后

  self.m_maxLab = _G.Util:createLabel("附魔已达上限",FONT_SIZE)
  self.m_maxLab : setAnchorPoint( cc.p(0.0,0.5) )
  self.m_maxLab : setPosition(240,self.m_mainBgSprSize.height/2+15)
  self.m_maxLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
  self.m_maxLab : setVisible(false)
  self.m_mainBgSpr   : addChild(self.m_maxLab)

  for i=1,3 do
    local beforeX = 30
    local posY    = self.m_mainBgSprSize.height/2+40-(i-1)*25
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

  local lineSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
  lineSpr           : setPreferredSize( cc.size(self.m_mainBgSprSize.width-10,lineSpr:getContentSize().height) )
  self.m_mainBgSpr  : addChild(lineSpr)
  lineSpr           : setPosition(self.m_mainBgSprSize.width/2,185)

  local lineSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
  lineSpr           : setPreferredSize( cc.size(self.m_mainBgSprSize.width-10,lineSpr:getContentSize().height) )
  self.m_mainBgSpr  : addChild(lineSpr)
  lineSpr           : setPosition(self.m_mainBgSprSize.width/2,125)

  self.m_infoLab = _G.Util:createLabel("消耗附魔石:",FONT_SIZE)
  self.m_infoLab : setAnchorPoint( cc.p(0.0,0.5) )
  self.m_infoLab : setPosition(cc.p(80,30))
  self.m_infoLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  lineSpr   : addChild(self.m_infoLab) 

  self.m_SpendLab = _G.Util:createLabel("",FONT_SIZE)
  self.m_SpendLab : setAnchorPoint( cc.p(0.0,0.5) )
  self.m_SpendLab : setPosition(cc.p(200,30))
  self.m_SpendLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  lineSpr: addChild(self.m_SpendLab) 

  --货币类型图标
  -- self.l_iconSpr = cc.Sprite : createWithSpriteFrameName( "general_fumoshi.png" ) 
  -- lineSpr      : addChild(self.l_iconSpr)
  -- self.l_iconSpr       : setPosition(200,35)

  local function local_btncallback(sender, eventType) 
      return self : onBtnCallBack(sender, eventType)
  end

  local szOne ="general_btn_gold.png"

  self.m_fuMoBtn  = gc.CButton:create() 
  self.m_fuMoBtn  : setTitleFontName(_G.FontName.Heiti)
  self.m_fuMoBtn  : loadTextures(szOne)
  self.m_fuMoBtn  : setTitleText("附  魔")
  self.m_fuMoBtn  : setTitleFontSize(FONT_SIZE+4)
  self.m_fuMoBtn  : addTouchEventListener(local_btncallback)
  self.m_mainBgSpr: addChild(self.m_fuMoBtn)
  self.m_fuMoBtn  : setPosition(self.m_mainBgSprSize.width/2,75)

  local tanhao = cc.Sprite : createWithSpriteFrameName( "general_tanhao.png" )
  tanhao : setPosition( 80, 25 )
  -- tanhao : setScale(0.8)
  self.m_mainBgSpr : addChild( tanhao )

  local RewardGoods = _G.Util : createLabel( "饰品分解后材料100%返还", 18 )
  RewardGoods : setPosition(200,25)
  RewardGoods : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.m_mainBgSpr : addChild( RewardGoods )

  if self.m_isGuide then
      _G.GGuideManager:registGuideData(2,self.m_fuMoBtn)
  end

  return self.m_container
end
function EquipFuMoLayer.guideDelete(self,_guideId)
    if _guideId==_G.Const.CONST_NEW_GUIDE_SYS_EQUIP_FUMO and self.m_isGuide then
        _G.GGuideManager:clearCurGuideNode()
    end
end

function EquipFuMoLayer.unregister(self)
    print("EquipFuMoLayer.unregister")
    if self.pMediator ~= nil then
      self.pMediator : destroy()
      self.pMediator = nil 
    end
end

function EquipFuMoLayer.ontipsbyDataCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
        local btn_tag  = sender : getTag()
        print("物品查看 data",btn_tag)
        if btn_tag <= 0 then return end

        local Position = sender : getWorldPosition()
        local m_good = self : getGoodsByIndex(btn_tag)
        if m_good == nil then return end

        local temp = _G.TipsUtil : create(m_good,_G.Const.CONST_GOODS_SITE_OTHERROLE,Position,self.m_curRoleUid)
        cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
    end
end

function EquipFuMoLayer.getGoodsByIndex( self,_index )
  local scelectData = nil
  if self.m_equipList == nil then  return scelectData end
  for k,v in pairs(self.m_equipList) do
     if _index == v.index then
        scelectData = v
        break
     end
  end
  return scelectData
end

function EquipFuMoLayer.onBtnCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
        self:REQ_MAKE_ENCHANT()
    end
end

function EquipFuMoLayer.REQ_MAKE_ENCHANT( self )
    local partnerid = self.m_curRoleUid
    local index     = self:getNowGoodsIndex() 
    if index==nil then return end

    local msg = REQ_MAKE_ENCHANT()
    msg :setArgs(2,partnerid,index)
    _G.Network :send( msg)
end

--现在的物品当前部位
function EquipFuMoLayer.setNowGoodsPart( self,_id )
    self.NowGoodsPart = _id
end
function EquipFuMoLayer.getNowGoodsPart( self )
    return self.NowGoodsPart
end
--现在的物品框index
function EquipFuMoLayer.setNowGoodsIndex( self,_id )
    self.NowGoodsIndex = _id
end
function EquipFuMoLayer.getNowGoodsIndex( self )
    return self.NowGoodsIndex
end
--现在的物品框id
function EquipFuMoLayer.setNowGoodsId( self,_id )
    self.NowGoodsId = _id
end
function EquipFuMoLayer.getNowGoodsId( self )
    return self.NowGoodsId
end

function EquipFuMoLayer.NetWorkReturn__MAKE_ENCHANT_OK( self,_uid,_idx )
  print("附魔成功 更新数据")
  local data = {}
  data.nowPartnerId  = _uid
  data.nowGoodsIndex = _idx

  self : pushData(data)
end

function EquipFuMoLayer.pushData( self,_data )
  print("EquipFuMoLayer.pushData",_data.nowGoodsIndex)

  self.m_curEquipIndex=_data.nowGoodsIndex
  self : setNowGoodsIndex(_data.nowGoodsIndex)

  self : resetScelectPanel()
  self : updateFuMoCount()
  self : getSixProxyData()

  local index       = _data.nowGoodsIndex
  local scelectData = nil
  if self.m_equipList == nil then  return end
  for k,v in pairs(self.m_equipList) do
     if index == v.index then
        scelectData = v
        break
     end
  end

  if scelectData == nil then  
    --发命令隐藏选中效果
    local _Command = EquipGoodChangeCommand(EquipGoodChangeCommand.DELEFFECT)
    controller:sendCommand(_Command)

   -- local command = CErrorBoxCommand(7996)
   -- controller :sendCommand( command )
           
    return 
  end
  print("EquipFuMoLayer.pushData 222   ",scelectData.fumo,scelectData.fumoz)
  self : setNowGoodsId(scelectData.goods_id)
  self : updateScelectPanel(scelectData.goods_id,index,scelectData.fumo,scelectData.fumoz) 
end

function EquipFuMoLayer.updateFuMoCount( self )
    local m_data  = _G.GBagProxy : getPropsList()
    local m_count = 0 
    if m_data   ~= nil then
        for k,v in pairs(m_data) do
            if v.goods_id == FUMOID then
                m_count = m_count + v.goods_num
            end
        end
    end
    self.count = m_count
end

function EquipFuMoLayer.resetScelectPanel( self )
   if self.m_partIconSpr ~= nil then
      self.m_partIconSpr : removeFromParent(true)
      self.m_partIconSpr = nil 
   end
   for i=1,3 do
       self.m_beforeLab[i] : setString("")
       self.m_binfoLab[i] : setString("")
       self.m_afterLab[i]  : setString("")
       self.m_ainfoLab[i] : setString("")
   end

   -- self.m_partBgSpr : setTag(-1)
   -- self.m_fuMoBtn   : setTag(-1)

   self.partNameLab   : setString("")
   self.partNameLab   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
   self.m_SpendLab    : setString("")
end

function EquipFuMoLayer.updateScelectPanel( self,_id,_index,_fumo,_fumoz )
   local node = _G.Cfg.goods[_id]
   if node == nil then  return end 
   local baseNode = node.base_type
   
    local function local_tipscallback(sender, eventType) 
      return self : ontipsbyDataCallBack(sender, eventType)
    end
   -- self.m_partBgSpr : setTag(_index)
   -- self.m_fuMoBtn   : setTag(_index)

   local sprSize       = self.m_partBgSpr : getContentSize()
   self.m_partIconSpr  = _G.ImageAsyncManager:createGoodsBtn(node,local_tipscallback,_index)
   self.m_partIconSpr  : setPosition(sprSize.width/2-1,sprSize.height/2)
   self.m_partBgSpr    : addChild(self.m_partIconSpr)

   self.partNameLab : setString(node.name)
   self.partNameLab : setColor(_G.ColorUtil:getRGB(node.name_color))

    if _fumo ~= nil and _fumo >= 0 then
        local nownode  = _G.Cfg.equip_enchant[_fumo]
        local nextnode = _G.Cfg.equip_enchant[_fumo+1]
        self.nums = 0
        if nownode ~= nil then
            local addPe = nownode.percent/100
            self.m_beforeLab[1] : setString("加成:")
            self.m_binfoLab[1] : setString(addPe.."%")
            --属性
            if baseNode ~= nil then
                for k,v in pairs(baseNode) do
                    local nameStr = _G.Lang.type_name[v.type] or "无"
                    local addStr  = math.ceil(v.v*addPe/100)

                    if nameStr ~= nil and self.m_beforeLab[k+1] ~= nil then
                        self.m_beforeLab[k+1] : setString(nameStr..":")
                        self.m_binfoLab[k+1] : setString(addStr)
                    end
                    self.nums = self.nums + 1
                end
            end
        else
            if nextnode ~= nil then
                if baseNode ~= nil then
                    for k,v in pairs(baseNode) do
                        local nameStr = _G.Lang.type_name[v.type] or "无"
                        if self.m_beforeLab[k+1] ~= nil then
                             self.m_beforeLab[k+1] : setString(nameStr..":")
                             self.m_binfoLab[k+1]  : setString("0")
                        end
                        self.nums = self.nums + 1
                    end
                end
            end
            self.m_beforeLab[1] : setString("加成:")
            self.m_binfoLab[1] : setString("0%")
        end

        print("self.nums",self.nums)
        local nSize = self.m_partBgSpr:getContentSize()
        if self.nums == 1 then
             self.m_beforeLab[2] : setPosition(30,self.m_mainBgSprSize.height/2-13)
             self.m_binfoLab[2] : setPosition(85,self.m_mainBgSprSize.height/2-13)
             self.m_beforeLab[3] : setPosition(30,self.m_mainBgSprSize.height/2+10)
             self.m_binfoLab[3] : setPosition(85,self.m_mainBgSprSize.height/2+10)
             self.m_afterLab[2]  : setPosition(240,self.m_mainBgSprSize.height/2-13)
             self.m_afterLab[3] : setPosition(240,self.m_mainBgSprSize.height/2+10)
             self.m_ainfoLab[2]  : setPosition(295,self.m_mainBgSprSize.height/2-13)
             self.m_afterLab[3] : setPosition(295,self.m_mainBgSprSize.height/2+10)
             self.m_arrSpr : setPosition(nSize.width/2,-87)
             self.m_maxLab : setPosition(240,self.m_mainBgSprSize.height/2+12)
        else
            self.m_beforeLab[2] : setPosition(30,self.m_mainBgSprSize.height/2-20)
            self.m_binfoLab[2] : setPosition(85,self.m_mainBgSprSize.height/2-20)
            self.m_beforeLab[3] : setPosition(30,self.m_mainBgSprSize.height/2+10)
            self.m_binfoLab[3] : setPosition(85,self.m_mainBgSprSize.height/2+10)
            self.m_afterLab[2]  : setPosition(240,self.m_mainBgSprSize.height/2-20)
            self.m_afterLab[3] : setPosition(240,self.m_mainBgSprSize.height/2+10)
            self.m_ainfoLab[2]  : setPosition(295,self.m_mainBgSprSize.height/2-20)
            self.m_ainfoLab[3] : setPosition(295,self.m_mainBgSprSize.height/2+10)
            self.m_maxLab : setPosition(240,self.m_mainBgSprSize.height/2+10)
            self.m_arrSpr : setPosition(nSize.width/2,-90)
        end

        if nextnode ~= nil then
            local nextaddPe    = nextnode.percent/100
            local nextbaseNode = nextnode.base_type
            self.m_afterLab[1] : setString("加成:")
            self.m_ainfoLab[1] : setString(nextaddPe.."%")
            
            if nextnode.goods_list == nil then  return end
            self.m_SpendLab : setString(string.format("%d/%d",self.count,nextnode.goods_list[1][2] or 0 ))
            local labWidth=self.m_SpendLab:getContentSize().width
            self.m_infoLab : setPosition(cc.p(120-labWidth/2,30))
            self.m_SpendLab : setPosition(cc.p(240-labWidth/2,30))
            if self.count < nextnode.goods_list[1][2] then
                self.m_SpendLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
            else
                self.m_SpendLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
            end

            --属性
            if baseNode ~= nil then
                for k,v in pairs(baseNode) do
                    local nameStr = _G.Lang.type_name[v.type] or "无"
                    local addStr  = math.ceil(v.v*nextaddPe/100) or "0"
                    if self.m_afterLab[k+1] ~= nil then 
                        self.m_afterLab[k+1] : setString(nameStr..":")
                        self.m_ainfoLab[k+1] : setString(addStr)
                        self.m_maxLab : setVisible(false)
                    end
                end
            end
        else
            self.m_afterLab[1] : setString("")
            self.m_ainfoLab[1] : setString("")
            self.m_afterLab[2] : setString("")
            self.m_ainfoLab[2] : setString("")
            self.m_afterLab[3] : setString("")
            self.m_ainfoLab[3] : setString("")
            self.m_maxLab : setVisible(true)
            self.m_SpendLab : setString(string.format("%d/0",self.count ))
            local labWidth=self.m_SpendLab:getContentSize().width
            self.m_infoLab : setPosition(cc.p(120-labWidth/2,30))
            self.m_SpendLab : setPosition(cc.p(240-labWidth/2,30))
        end
    end
end

function EquipFuMoLayer.getSixProxyData(self)
    local _nowPartnerId =self.m_curRoleUid

    local mainplay = nil
    if _nowPartnerId == 0 then
        mainplay    = _G.GPropertyProxy:getMainPlay()
    else
        local m_uid = _G.GPropertyProxy:getMainPlay():getUid()
        local index = tostring( m_uid)..tostring( _nowPartnerId )
        mainplay    = _G.GPropertyProxy :getOneByUid( index, _G.Const.CONST_PARTNER)
    end

    if mainplay == nil then return end
    self.m_equipCount = mainplay : getEquipCount() --装备数量
    self.m_equipList  = mainplay : getEquipList()  --装备数据
end

function EquipFuMoLayer.getPlayerData( self,_CharacterName )
    local mainplay = _G.GPropertyProxy : getMainPlay()
    local CharacterValue = nil 

    if     _CharacterName == "Lv" then
        CharacterValue = mainplay : getLv()
    elseif _CharacterName == "Power" then
        CharacterValue = mainplay : getPowerful()
    elseif _CharacterName == "Pro" then
        CharacterValue = mainplay : getPro()
    elseif _CharacterName == "Vip" then
        CharacterValue = mainplay : getVipLv()
    elseif _CharacterName == MONEYTYPE_GOLD then
        CharacterValue = mainplay : getGold()
    elseif _CharacterName == MONEYTYPE_RMB then
        CharacterValue = mainplay :getRmb() + mainplay :getBindRmb()
    elseif _CharacterName == MONEYTYPE_JADE then
        CharacterValue = 1
    end

    return CharacterValue
end

function EquipFuMoLayer.chuangeRole(self,_uid)
    self.m_curRoleUid=_uid or 0
    self:pushData({nowGoodsIndex=self.m_curEquipIndex})
end

function EquipFuMoLayer.FuMoSuccEffect(self)
    print("附魔成功特效")
    _G.Util:playAudioEffect("ui_equip_add_magic")
    if self.fumoSuccSpr~=nil then return end
    self.fumoSuccSpr=cc.Sprite:createWithSpriteFrameName("main_effect_word_fm1.png")
    self.fumoSuccSpr:setScale(0.05)
    self.fumoSuccSpr:setPosition(0,0)
    -- self.m_container:addChild(self.fumoSuccSpr,1000)
    local sizes          = self.m_partBgSpr : getContentSize ()  
    self.m_partBgSpr     : addChild(self.fumoSuccSpr,1000)    
    self.fumoSuccSpr : setPosition(sizes.width/4,sizes.height/2)


    local addSpr =  cc.Sprite:createWithSpriteFrameName("main_effect_word_cg1.png") 
    self.fumoSuccSpr : addChild(addSpr)
    local sprsize  = self.fumoSuccSpr : getContentSize()
    local sprsize2 = addSpr : getContentSize()
    addSpr : setPosition(sprsize.width+sprsize2.width/2,sprsize.height/2)

    local function f1()
        self.fumoSuccSpr:removeFromParent(true)
        self.fumoSuccSpr=nil
    end
    local function f2()
        local action=cc.Sequence:create(cc.FadeTo:create(0.15,0),cc.CallFunc:create(f1))
        self.fumoSuccSpr:runAction(action)
    end
    local function f3()
        local szPlist="anim/task_finish.plist"
        local szFram="task_finish_"
        local act1=_G.AnimationUtil:createAnimateAction(szPlist,szFram,0.12)
        local act2=cc.CallFunc:create(f2)

        local sprSize=self.fumoSuccSpr:getContentSize()
        local effectSpr=cc.Sprite:create()
        effectSpr:setPosition(sprSize.width,sprSize.height*0.5)
        effectSpr:runAction(cc.Sequence:create(act1,act2))
        self.fumoSuccSpr:addChild(effectSpr)
    end
    local action=cc.Sequence:create(cc.ScaleTo:create(0.15,1),cc.CallFunc:create(f3))
    self.fumoSuccSpr:runAction(action)
end

return EquipFuMoLayer