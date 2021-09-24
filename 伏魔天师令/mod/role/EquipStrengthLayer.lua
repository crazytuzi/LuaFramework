local EquipStrengthLayer = classGc(view, function(self,_uid)
    self.m_curRoleUid=_uid or 0
    self.pMediator = require("mod.role.EquipStrengthLayerMediator")()
    self.pMediator : setView(self)
end)

local FONT_SIZE  = 20

local IPriority =-10

local  TAGBTN_ONESTRENGTH    = 1
local  TAGBTN_TENSTRENGTH    = 2

function EquipStrengthLayer.__create(self)
  self.m_container = cc.Node:create()

  self.m_strengView=require("mod.role.StrengLayer")(self.m_curRoleUid)
  self.m_strengLayer=self.m_strengView:create()
  self.m_container:addChild(self.m_strengLayer)

  --外层绿色底图大小
  self.m_rootBgSize = cc.size(828,476)
  self.m_mainBgSprSize = cc.size(380,465)

  self.m_mainBgSpr  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
  self.m_mainBgSpr  : setPreferredSize( self.m_mainBgSprSize )
  self.m_container  : addChild(self.m_mainBgSpr)
  self.m_mainBgSpr  : setPosition(self.m_rootBgSize.width/2-self.m_mainBgSprSize.width/2-5,-55)

  self.m_partBgSpr = cc.Sprite : createWithSpriteFrameName("role_streng1.png")
  self.m_partBgSpr : setPosition(cc.p(self.m_mainBgSprSize.width/2+1,self.m_mainBgSprSize.height-68))
  self.m_partBgSpr : setScale(1.7)
  self.m_mainBgSpr : addChild(self.m_partBgSpr)

  -- local tempGafAsset=gaf.GAFAsset:create("gaf/loong.gaf")
  -- local tempObj=tempGafAsset:createObject()
  -- local nPos=cc.p(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height-70)
  -- tempObj:setLooped(true,true)
  -- tempObj:setScale(0.9)
  -- tempObj:start()
  -- tempObj:setPosition(nPos)
  -- self.m_mainBgSpr : addChild(tempObj,1000)

  self.partNameLab = _G.Util:createLabel("",FONT_SIZE)
  self.partNameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  self.partNameLab : setPosition(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height-140)
  self.m_mainBgSpr : addChild(self.partNameLab)

  self.m_arrSpr = cc.Sprite : createWithSpriteFrameName("general_tip_down.png")
  self.m_arrSpr : setPosition(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height/2+8)
  self.m_mainBgSpr :addChild(self.m_arrSpr)


  self.m_beforeLab = {1,2,3} --强化前
  self.m_afterLab  = {1,2,3} --强化后
  self.m_binfoLab  = {1,2,3}
  self.m_ainfoLab  = {1,2,3}

  for i=1,3 do
    local beforeX = 30
    local posY    = self.m_mainBgSprSize.height/2+30-(i-1)*25
    local afterX  = 240

    self.m_beforeLab[i] = _G.Util:createLabel("",FONT_SIZE)
    self.m_beforeLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_beforeLab[i] : setPosition(beforeX,posY)
    self.m_beforeLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_mainBgSpr    : addChild(self.m_beforeLab[i])

    self.m_binfoLab[i] = _G.Util:createLabel("",FONT_SIZE)
    self.m_binfoLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_binfoLab[i] : setPosition(beforeX+55,posY)
    self.m_binfoLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
    self.m_mainBgSpr    : addChild(self.m_binfoLab[i])
  
    self.m_afterLab[i] = _G.Util:createLabel("",FONT_SIZE)
    self.m_afterLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_afterLab[i] : setPosition(afterX,posY)
    self.m_afterLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_mainBgSpr   : addChild(self.m_afterLab[i])

    self.m_ainfoLab[i] = _G.Util:createLabel("",FONT_SIZE)
    self.m_ainfoLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_ainfoLab[i] : setPosition(afterX+55,posY)
    self.m_ainfoLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
    self.m_mainBgSpr   : addChild(self.m_ainfoLab[i])
  end

  local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
  lineSpr : setPreferredSize( cc.size(self.m_mainBgSprSize.width-10,lineSpr:getContentSize().height) )
  lineSpr : setPosition(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height/2+60)
  self.m_mainBgSpr : addChild(lineSpr)

  local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
  lineSpr : setPreferredSize( cc.size(self.m_mainBgSprSize.width-10,lineSpr:getContentSize().height) )
  lineSpr : setPosition(self.m_mainBgSprSize.width/2,187)
  self.m_mainBgSpr : addChild(lineSpr)

  local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
  lineSpr : setPreferredSize( cc.size(self.m_mainBgSprSize.width-10,lineSpr:getContentSize().height) )
  lineSpr : setPosition(self.m_mainBgSprSize.width/2,97)
  self.m_mainBgSpr : addChild(lineSpr)

  local m_spendLab = {1,2,3,4,5}
  local m_posX  = {62,62,160,160,195}
  local m_posY  = {60,30,60,30,30}
  local m_color = {_G.Const.CONST_COLOR_BROWN,_G.Const.CONST_COLOR_BROWN,_G.Const.CONST_COLOR_DARKORANGE,
                  _G.Const.CONST_COLOR_DARKORANGE,_G.Const.CONST_COLOR_DARKORANGE}
  for i=1,5 do
      m_spendLab[i] = _G.Util:createLabel("70%",FONT_SIZE)
      m_spendLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
      m_spendLab[i] : setPosition(m_posX[i],m_posY[i])
      m_spendLab[i] : setColor(_G.ColorUtil:getRGB(m_color[i]))
      lineSpr : addChild(m_spendLab[i])  
  end
  m_spendLab[1] : setString("消耗铜钱:")
  m_spendLab[2] : setString("成功几率:")
  m_spendLab[5] : setString(" + 3%VIP")
  self.m_MoneyLab   = m_spendLab[3]
  self.m_SuccessLab = m_spendLab[4]
  self.m_VipAddLab  = m_spendLab[5]

  --货币类型图标
  -- self.l_iconSpr = cc.Sprite : createWithSpriteFrameName( "general_tongqian.png" ) 
  -- lineSpr  : addChild(self.l_iconSpr)
  -- self.l_iconSpr : setPosition(172,62)

  local viplv = self:getPlayerData("Vip")
  local nowvipLab   = _G.Util:createLabel(string.format("(Vip%d)",viplv),FONT_SIZE)
  nowvipLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  nowvipLab : setAnchorPoint( cc.p(0.0,0.5) )
  nowvipLab    : setPosition(260, 30)
  lineSpr : addChild( nowvipLab )

  local function local_btncallback(sender, eventType) 
      self : onBtnCallBack(sender, eventType)
  end

  local szOne ="general_btn_lv.png"
  local szTen ="general_btn_gold.png"

  self.m_oneStrengBtn  = gc.CButton:create() 
  self.m_oneStrengBtn  : setTitleFontName(_G.FontName.Heiti)
  self.m_oneStrengBtn  : loadTextures(szOne)
  self.m_oneStrengBtn  : setTitleText("灌  注")
  self.m_oneStrengBtn  : setTag(TAGBTN_ONESTRENGTH)
  self.m_oneStrengBtn  : setTitleFontSize(FONT_SIZE+2)
  self.m_oneStrengBtn  : addTouchEventListener(local_btncallback)
  self.m_mainBgSpr     : addChild(self.m_oneStrengBtn)
  self.m_oneStrengBtn  : setPosition(self.m_mainBgSprSize.width/2-90,45)

  self.m_tenStrengBtn  = gc.CButton:create()
  self.m_tenStrengBtn  : setTitleFontName(_G.FontName.Heiti) 
  self.m_tenStrengBtn  : loadTextures(szTen)
  self.m_tenStrengBtn  : setTitleText("灌注十次")
  self.m_tenStrengBtn  : setTitleFontSize(FONT_SIZE+2)
  self.m_tenStrengBtn  : setTag(TAGBTN_TENSTRENGTH)
  --self.m_tenStrengBtn  : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
  self.m_tenStrengBtn  : addTouchEventListener(local_btncallback)
  self.m_mainBgSpr     : addChild(self.m_tenStrengBtn)
  self.m_tenStrengBtn  : setPosition(self.m_mainBgSprSize.width/2+90,45)

  if self.m_curRoleUid~=0 then
    self.m_oneStrengBtn:setBright(false)
    self.m_oneStrengBtn:setEnabled(false)
    self.m_tenStrengBtn:setBright(false)
    self.m_tenStrengBtn:setEnabled(false)
  end
  local guideId=_G.GGuideManager:getCurGuideId()
  if guideId==_G.Const.CONST_NEW_GUIDE_SYS_EQUIP then
      -- local function nFun()
          -- _G.GGuideManager:runNextStep()
      -- end
      print("IOOOIOIOOOIOIOIOIOIOI====>>>>")
      _G.GGuideManager:registGuideData(3,self.m_oneStrengBtn)
      -- _G.GGuideManager:runNextStep()
      self.m_guide_number=0

      -- self.m_oneStrengBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(nFun)))
  end

  self:pushData(1)

  return self.m_container
end

function EquipStrengthLayer.unregister(self)
    print("EquipStrengthLayer.unregister")
    if self.pMediator ~= nil then
      self.pMediator : destroy()
      self.pMediator = nil 
    end
end


function EquipStrengthLayer.onBtnCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
      local btn_tag = sender : getTag()
      print("强化按钮回掉=",btn_tag)
      if btn_tag==TAGBTN_ONESTRENGTH and self.m_guide_number~=nil then
        self.m_guide_number=self.m_guide_number+1 
        if self.m_guide_number==3 then
          _G.GGuideManager:runNextStep()  
        end
      end 

      self : REQ_MAKE_PART_STREN(btn_tag)
    end
end

function EquipStrengthLayer.REQ_MAKE_PART_STREN( self,_type )
    local partnerid = self.m_curRoleUid
    local partno    = self : getNowGoodsPartType() 
    if partnerid == nil or partno == nil or _type == nil then return end

    local msg = REQ_MAKE_PART_STREN()
    msg :setArgs(partnerid,partno,_type)
    _G.Network :send( msg)
end

function EquipStrengthLayer.REQ_MAKE_PART_STREN_REQ( self )
    local partnerid = self.m_curRoleUid
    local partno    = self:getNowGoodsPartType()
    print("REQ_MAKE_PART_STREN_REQ===>>>",partnerid,partno)
    if partnerid==nil or partno==nil then return end

    local msg = REQ_MAKE_PART_STREN_REQ()
    msg :setArgs(partnerid,partno)
    _G.Network :send( msg)
end

--现在的角色id
function EquipStrengthLayer.chuangeRole(self,_uid)
    self.m_curRoleUid=_uid or 0
    self:pushData({nowGoodsPart=self.m_nowPartPos})
end
--现在的物品当前部位
function EquipStrengthLayer.setNowGoodsPartType( self,_id )
    self.m_nowGoodsPartType=_id
end
function EquipStrengthLayer.getNowGoodsPartType( self )
    return self.m_nowGoodsPartType
end

function EquipStrengthLayer.pushData( self,_index )
  local EquilConst,partName=self:getPartTypeAndNameByNo(_index)
  print("EquipStrengthLayer.pushData",_index)
  self:setNowGoodsPartType(EquilConst)
  self.partNameLab:setString(string.format("%s",partName))

  self.m_nowPartPos=_index

  --替换选中的图片
  if _index==nil or _index>6 then
    print("lua error!!!EquipStrengthLayer.pushData===>>>>>")
    return
  end
  self:updateScelectSpr(_index)
  self:REQ_MAKE_PART_STREN_REQ()
end

function EquipStrengthLayer.StrengthDataReturn(self,m_lv,money,odds,odds_vip,msg_xxx,msg_xxx2)
  print("EquipStrengthLayer.StrengthDataReturn",m_lv,money,odds,odds_vip,msg_xxx,msg_xxx2)

  -- local m_count = self:getPlayerData(MONEYTYPE_GOLD)
  -- if m_count > 10000000 then
  --   m_count = math.floor(m_count/10000).."万"
  -- end
  -- self.m_HaveLab : setString(m_count)

  self.m_beforeLab[1] : setString("等级:")
  self.m_binfoLab[1] : setString(m_lv)
  self.m_afterLab[1]  : setString("等级:")
  self.m_ainfoLab[1]  : setString(m_lv+1)
  local size = self.m_partBgSpr : getContentSize ()
  local num=1
  if msg_xxx ~= nil and msg_xxx2 ~= nil  then
      for i=2,3 do
          local data  = msg_xxx[num]
          local data2 = msg_xxx2[num]
          num=num+1
          if data2 ~= nil then
            self.typeName2 = _G.Lang.type_name[data2.type] or "无"
            self.m_afterLab[i] : setString(string.format("%s:",self.typeName2))
            self.m_ainfoLab[i] : setString(data2.type_value)
            self.m_afterLab[2] : setPosition(240,self.m_mainBgSprSize.height/2+5)
            self.m_ainfoLab[2] : setPosition(295,self.m_mainBgSprSize.height/2+5)
          else
            self.m_afterLab[2] : setPosition(240,self.m_mainBgSprSize.height/2-10)
            self.m_ainfoLab[2] : setPosition(295,self.m_mainBgSprSize.height/2-10)
            self.m_afterLab[i] : setString("")
            self.m_ainfoLab[i] : setString("")
          end
          if data ~= nil then
            self.m_beforeLab[2] : setPosition(30,self.m_mainBgSprSize.height/2+5)
            self.m_binfoLab[2] : setPosition(85,self.m_mainBgSprSize.height/2+5)
            self.m_arrSpr : setPosition(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height/2+3)
            local typeName1 = _G.Lang.type_name[data.type] or "无"
            self.m_beforeLab[i] : setString(string.format("%s:",typeName1))
            self.m_binfoLab[i] : setString(data.type_value)

          -- elseif m_lv == 0 then
          --   self.m_beforeLab[1] : setPosition(30,self.m_mainBgSprSize.height/2+10)
          --   self.m_beforeLab[i] : setString(self.typeName2.."+0")
          else
            if m_lv == 0 then
              if data2 ~= nil then
                self.m_beforeLab[2] : setPosition(30,self.m_mainBgSprSize.height/2+5)
                self.m_binfoLab[2] : setPosition(85,self.m_mainBgSprSize.height/2+5)
                self.m_arrSpr : setPosition(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height/2+3)
                self.m_beforeLab[i] : setString(string.format("%s:",self.typeName2))
                self.m_binfoLab[i] : setString(0)
              else
                self.m_arrSpr : setPosition(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height/2+8)
                self.m_beforeLab[2] : setPosition(30,self.m_mainBgSprSize.height/2-10)
                self.m_binfoLab[2] : setPosition(85,self.m_mainBgSprSize.height/2-10)
                self.m_beforeLab[i] : setString("")
                self.m_binfoLab[i] : setString("")
              end
            else
              self.m_arrSpr : setPosition(self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height/2+8)
              self.m_beforeLab[2] : setPosition(30,self.m_mainBgSprSize.height/2-10)
              self.m_binfoLab[2] : setPosition(85,self.m_mainBgSprSize.height/2-10)
              self.m_beforeLab[i] : setString("")
              self.m_binfoLab[i] : setString("")
            end
          end
      end
  end

  local m_count = self:getPlayerData(MONEYTYPE_GOLD)
  self.money = money
  if m_count<money then
    self.m_MoneyLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
  else
    self.m_MoneyLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
  end

  self.m_MoneyLab   : setString(money or 0)
  self.m_SuccessLab : setString(string.format("%d%s",odds/100,"%"))
  self.m_VipAddLab  : setString(string.format(" + %d%s",odds_vip/100,"%"))

  if self.m_guide_level~=nil then
      if self.m_guide_level<=m_lv then
          _G.GGuideManager:runNextStep()
      end
  end

  -- local labWidth = self.m_MoneyLab : getContentSize().width
  -- self.l_iconSpr : setPosition(180+labWidth,64)
end

function EquipStrengthLayer.updateScelectSpr(self, _no )
    local m_str       = string.format("role_streng%d.png",_no)
    self.m_partBgSpr  : setSpriteFrame(m_str) 
end

function EquipStrengthLayer.getPartTypeAndNameByNo( self,_no )
    local szPartName = ""
    local EquipConst=nil
    if _no ==1 then
      EquipConst = _G.Const.CONST_EQUIP_ARMOR
      szPartName = "天冲"
    elseif _no ==2 then
      EquipConst = _G.Const.CONST_EQUIP_CLOAK
      szPartName = "灵慧"
    elseif _no ==3 then
      EquipConst = _G.Const.CONST_EQUIP_SHOE
      szPartName = "气"
    elseif _no ==4 then
      EquipConst = _G.Const.CONST_EQUIP_NECKLACE
      szPartName = "力"
    elseif _no ==5 then
      EquipConst = _G.Const.CONST_EQUIP_WEAPON
      szPartName = "中枢"
    elseif _no ==6 then
      EquipConst = _G.Const.CONST_EQUIP_RING
      szPartName = "精"
    end 

    return EquipConst,szPartName
end

function EquipStrengthLayer.resetEquipData( self )
   for i=1,6 do
      if self.EquipsixSpr[i] ~= nil then
          self.EquipsixSpr[i] : removeFromParent(true)
          self.EquipsixSpr[i] = nil 
      end
      self.EquipBtn[i] : setTag(-1)
   end
end

function EquipStrengthLayer.getPlayerData( self,_CharacterName )
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

function EquipStrengthLayer.showStrengthOkEffect(self,_isTrue)
    if self.tempObj~=nil then
        self.tempObj:removeFromParent(true)
        self.tempObj=nil
    end
    if _isTrue==1 then
      local sizes          = self.m_partBgSpr : getContentSize ()  
      local tempGafAsset=gaf.GAFAsset:create("gaf/guanzhuchenggong.gaf")
      self.tempObj=tempGafAsset:createObject()
      local nPos=cc.p(sizes.width/2,sizes.height/2)
      self.tempObj:setLooped(false,false)
      self.tempObj:start()
      self.tempObj:setPosition(nPos)
      self.m_partBgSpr     : addChild(self.tempObj,1000)
      _G.Util:playAudioEffect("ui_strengthen_success")
    else
      local sizes          = self.m_partBgSpr : getContentSize ()  
      local tempGafAsset=gaf.GAFAsset:create("gaf/guanzhushibai.gaf")
      self.tempObj=tempGafAsset:createObject()
      local nPos=cc.p(sizes.width/2,sizes.height/2)
      self.tempObj:setLooped(false,false)
      self.tempObj:start()
      self.tempObj:setPosition(nPos)
      self.m_partBgSpr     : addChild(self.tempObj,1000)
      _G.Util:playAudioEffect("ui_strengthen_fail")
    end

    -- if _isTrue == 1 then
    --   self.StrengSpr = "main_effect_word_qh1.png"
    --   self.YESorNO = "main_effect_word_cg1.png"
    --   self.szPlist="anim/task_finish.plist"
    --   self.szFram="task_finish_"
    --   _G.Util:playAudioEffect("ui_strengthen_success")
    -- else
    --   self.StrengSpr = "main_effect_word_qh2.png"
    --   self.YESorNO = "main_effect_word_sb2.png"
    --   self.szPlist="anim/task_strenglose.plist"
    --   self.szFram="task_strenglose_"
    --   _G.Util:playAudioEffect("ui_strengthen_fail")
    -- end
    -- if self.m_StrengthOkSpr~=nil then return end
    -- self.m_StrengthOkSpr=cc.Sprite:createWithSpriteFrameName(self.StrengSpr)
    -- self.m_StrengthOkSpr:setScale(0.05)
    -- self.m_StrengthOkSpr:setPosition(0,0)
    -- -- self.m_container:addChild(self.m_StrengthOkSpr,1000)
    -- local sizes          = self.m_partBgSpr : getContentSize ()  
    -- self.m_partBgSpr     : addChild(self.m_StrengthOkSpr,1000)    
    -- self.m_StrengthOkSpr : setPosition(sizes.width/4,sizes.height/2)


    -- local addSpr =  cc.Sprite:createWithSpriteFrameName(self.YESorNO) 
    -- self.m_StrengthOkSpr : addChild(addSpr)
    -- local sprsize  = self.m_StrengthOkSpr : getContentSize()
    -- local sprsize2 = addSpr : getContentSize()
    -- addSpr : setPosition(sprsize.width+sprsize2.width/2,sprsize.height/2)

    -- local function f1()
    --     tempObj:stop()
    -- end
    -- local function f2()
    --     local action=cc.Sequence:create(cc.FadeTo:create(0.15,0),cc.CallFunc:create(f1))
    --     self.m_StrengthOkSpr:runAction(action)
    -- end
    -- local function f3()
    --     local act1=_G.AnimationUtil:createAnimateAction(self.szPlist,self.szFram,0.12)
    --     local act2=cc.CallFunc:create(f2)

    --     local sprSize=self.m_StrengthOkSpr:getContentSize()
    --     local effectSpr=cc.Sprite:create()
    --     effectSpr:setPosition(sprSize.width,sprSize.height*0.5)
    --     effectSpr:runAction(cc.Sequence:create(act1,act2))
    --     self.m_StrengthOkSpr:addChild(effectSpr)
    -- end
    -- local action=cc.Sequence:create(cc.ScaleTo:create(0.15,1),cc.CallFunc:create(f1))
    -- self.m_StrengthOkSpr:runAction(action)
end

function EquipStrengthLayer.playerpower( self )
  -- print("playerpowerplayerpowerplayerpowerplayerpower====>>>")
  self.m_strengView:playerpower()
end

function EquipStrengthLayer.updateMoney( self )
	print(self.m_MoneyLab,self.money,"111111111111111")
	if self.m_MoneyLab~=nil and self.money~=nil then
		local m_count = self:getPlayerData(MONEYTYPE_GOLD)
	    if m_count<self.money then
	    	self.m_MoneyLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	    else
	    	self.m_MoneyLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PBLUE))
	    end
	end
end

return EquipStrengthLayer