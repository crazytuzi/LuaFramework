local EquipGemLayer = classGc(view, function(self,_uid)
    self.m_curRoleUid=_uid or 0
    self.pMediator = require("mod.equip.EquipGemLayerMediator")(self)
    self.isMoving = 0
end)

local FONT_SIZE       = 20
local m_isNotic       = nil
local MAX_BSLV        = _G.Const.CONST_MAKE_PEAR_LV
local ONEPAGE_COUNT   = 8
--一行个数
local ONEPAGE_ROWNO   = 4
local MOVECMAXOUNT    = 10

local gap = 20

local Tag_btn_remove  = 11
local Tag_btn_up      = 12

local P_ROOT_SIZE = cc.size(828,476)

function EquipGemLayer.__create(self)
  self.m_container = cc.Node:create()

  self.m_mainBgSprSize = cc.size(380,465)

  self.m_mainBgSpr  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
  self.m_mainBgSpr  : setPreferredSize( self.m_mainBgSprSize )
  self.m_container  : addChild(self.m_mainBgSpr)
  self.m_mainBgSpr  : setPosition(P_ROOT_SIZE.width/2-self.m_mainBgSprSize.width/2-5,-55)

  local Spr_gembg = cc.Sprite : create( "ui/bg/equip_gembg.png" )
  Spr_gembg : setPosition( self.m_mainBgSprSize.width/2,self.m_mainBgSprSize.height/2+60 )
  Spr_gembg : setScale(0.8)
  self.m_mainBgSpr    : addChild( Spr_gembg )

  local function local_tipscallback(sender, eventType) 
      return self : onTipsCallBack(sender, eventType)
  end

  self.m_gemPanelArray = {1,2,3}
  self.m_gemSprArray   = {}
  self.m_equipGemSpr   = {1,2,3} --装备可卡强化宝石图片

  -- self.QuanSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
  -- self.QuanSpr:setPosition(self.m_mainBgSprSize.width/2-1,self.m_mainBgSprSize.height/2+42)
  -- self.m_mainBgSpr:addChild(self.QuanSpr)

  local posX = {self.m_mainBgSprSize.width/2,75,self.m_mainBgSprSize.width-75}
  local posY = {self.m_mainBgSprSize.height-55,self.m_mainBgSprSize.height/2+15,self.m_mainBgSprSize.height/2+15}
  for i=1,3 do
    self.m_gemPanelArray[i]={}
    local gemBtn=gc.CButton:create()  
    gemBtn:setTag(i)
    gemBtn:loadTextures("general_tubiaokuan.png") 
    gemBtn:addTouchEventListener(local_tipscallback)
    gemBtn:setPosition(posX[i],posY[i])
    self.m_mainBgSpr:addChild(gemBtn)
    local btnSize=gemBtn:getContentSize()

    local stateSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
    stateSpr : setPosition(btnSize.width/2,-18)
    gemBtn   : addChild(stateSpr)

    local stateLab = _G.Util:createLabel("未激活",FONT_SIZE)
    -- stateLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    stateLab : setPosition(btnSize.width/2,-18)
    gemBtn   : addChild(stateLab)

    --箭头
    -- local arrSpr = cc.Sprite : createWithSpriteFrameName("general_tip_down.png")
    -- arrSpr : setVisible(false)
    -- arrSpr : setRotation(90)
    -- arrSpr : setPosition(btnSize.width/2,-43)
    -- gemBtn : addChild(arrSpr)  

    --宝石镶嵌显示
    self.m_equipGemSpr[i] = cc.Sprite:createWithSpriteFrameName("general_tip_gem.png")
    self.m_equipGemSpr[i] : setVisible( false )
    self.m_equipGemSpr[i] : setPosition(60,60)
    gemBtn              : addChild(self.m_equipGemSpr[i],4) 

    self.m_gemPanelArray[i].gemBtn    = gemBtn
    self.m_gemPanelArray[i].stateSpr  = stateSpr
    self.m_gemPanelArray[i].stateLab  = stateLab
    -- self.m_gemPanelArray[i].arrSpr    = arrSpr
  end
  
  local gap = 35

  -- local jianbianSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_fram_jianbian.png" ) 
  -- jianbianSpr       : setPreferredSize( self.framSize )
  -- self.m_mainBgSpr  : addChild(jianbianSpr)
  -- jianbianSpr       : setPosition(self.m_mainBgSprSize.width/2,117+gap)

  local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_login_dawaikuan.png" )
  -- local lineSize = lineSpr:getContentSize()
  lineSpr       : setPreferredSize( cc.size(self.m_mainBgSprSize.width-10,92) )
  self.m_mainBgSpr : addChild(lineSpr)
  lineSpr       : setPosition(self.m_mainBgSprSize.width/2,70+gap)

  -- local downSpr = cc.Sprite : createWithSpriteFrameName( "general_down.png" ) 
  -- self.m_mainBgSpr : addChild(downSpr)
  -- downSpr       : setPosition(self.m_mainBgSprSize.width/2,10+gap)

  local function TouchEvent( obj, TouchEvent )
    local tag = obj : getTag()
    if TouchEvent == ccui.TouchEventType.ended then
      local id = self.m_curRoleUid
      -- if id ~= 0 then
      --   id = 1
      -- end
      if tag == Tag_btn_remove then
          self : REQ_MAKE_PART_REMOVE_ONE(id)
      elseif tag == Tag_btn_up then
          self : REQ_MAKE_PART_INSERT_ONE(id)
      end
    end
  end

  local btn_remove = gc.CButton : create()
  btn_remove : loadTextures( "general_btn_gold.png" )
  -- btn_remove : setButtonScale(0.8)
  btn_remove : setTitleText( "一键拆卸" )
  btn_remove : setTitleFontName( _G.FontName.Heiti )
  btn_remove : setTitleFontSize( FONT_SIZE+2 )
  btn_remove : setPosition( 95, 30 )
  btn_remove : setTag( Tag_btn_remove )
  btn_remove : addTouchEventListener( TouchEvent )
  self.m_mainBgSpr : addChild( btn_remove )

  local btn_up = gc.CButton : create()
  btn_up : loadTextures( "general_btn_lv.png" )
  -- btn_up : setButtonScale(0.8)
  btn_up : setTitleText( "一键镶嵌" )
  btn_up : setTitleFontName( _G.FontName.Heiti )
  btn_up : setTitleFontSize( FONT_SIZE+2 )
  btn_up : setPosition( 285, 30 )
  btn_up : setTag( Tag_btn_up )
  btn_up : addTouchEventListener( TouchEvent )

  self.m_mainBgSpr : addChild( btn_up )

  if self.m_isGuide then
      _G.GGuideManager:registGuideData(3,btn_up)
  end

  return self.m_container
end

function EquipGemLayer.guideDelete(self,_guideId)
    if _guideId==_G.Const.CONST_NEW_GUIDE_SYS_GEM and self.m_isGuide then
        _G.GGuideManager:runThisStep(4)
    end
end

function EquipGemLayer.XuanzhongRoleSpr( self,goodid )
  print("XuanzhongRoleSpr===>>>",goodid)
  local icon=_G.Cfg.goods[goodid].icon
  if icon==nil then return end
  if self.nowRoleSpr~=nil then
    self.nowRoleSpr:removeFromParent(true)
    self.nowRoleSpr=nil
  end
  self.nowRoleSpr=cc.Sprite:createWithSpriteFrameName(string.format("%s.png",icon))
  self.nowRoleSpr:setPosition(79/2,79/2)
  self.QuanSpr:addChild(self.nowRoleSpr)
end

function EquipGemLayer.REQ_MAKE_PART_INSERT_ONE( self, _id )
  local msg = REQ_MAKE_PART_INSERT_ONE()
  msg : setArgs( _id )
  _G.Network : send( msg )
end

function EquipGemLayer.REQ_MAKE_PART_REMOVE_ONE( self, _id )
  local msg = REQ_MAKE_PART_REMOVE_ONE()
  msg : setArgs( _id )
  _G.Network : send( msg )
end

function EquipGemLayer.createGemPanel(self )
    if self.m_pageView~=nil then 
        self.m_pageView : removeFromParent(true)
        self.m_pageView = nil 
    end
    local nBagData = self : getBagDatabyType()
    if nBagData==nil then return end
    local m_bagCount = #nBagData
    print("EquipGemLayer.createGoodPanel=",m_bagCount)
    
    local hangCount     = math.ceil(m_bagCount/ONEPAGE_ROWNO)
    -- if hangCount < 1 then hangCount = 1 end
    local innerHeight   = 85*hangCount
    local _pageViewSize = cc.size(self.m_mainBgSprSize.width-15,85)
    local innerViewSize = cc.size(self.m_mainBgSprSize.width,innerHeight)

    local gap = 35

    local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(true)
    pageView : enableSound()
    pageView : setSwallowTouches(true)
    pageView : setContentSize(_pageViewSize)  
    pageView : setPosition(cc.p(7,28+gap))
    pageView : setCustomScrollThreshold(50) 
    -- pageView:setContentOffset( cc.p( 0, _pageViewSize.height-innerHeight)) -- 设置初始位置

    local m_sprSize = cc.size(79,79)
    local pageCount = math.ceil(m_bagCount/ONEPAGE_COUNT)
    if pageCount==nil or pageCount<1 then pageCount=1 end

    local m_goodNo    = 0  --物品个数
    
    local m_rownum = math.ceil(m_bagCount/ONEPAGE_ROWNO) --至少显示1页 其余都是补齐1行
    print("self.m_rownum:", m_bagCount,m_rownum)
    if m_rownum == nil or m_rownum < 1 then m_rownum = 1 end
    -- if m_rownum < ONEPAGE_COUNT then
    --     m_rownum = ONEPAGE_COUNT
    -- end
    for k=1,m_rownum do
        local addRowNo = 0 -- 第几行
        local addColum = 0 -- 第几列
        local layout   = ccui.Layout : create()
        layout : setContentSize(_pageViewSize)

        for ii=1, ONEPAGE_ROWNO do
            m_goodNo = m_goodNo + 1
            -- if m_goodNo > m_bagCount then break end
            local m_oneGood = self : createOneGoodMethod(m_goodNo,nBagData[#nBagData-m_goodNo+1])

            if ii % 4 == 1 then
                addColum = 0
                addRowNo = addRowNo + 1
            end
            addColum   = addColum + 1

            if m_oneGood==nil then return end
            local posX = m_sprSize.width/2+10+(m_sprSize.width+10)*(addColum-1)
            local posY = _pageViewSize.height-m_sprSize.height/2-4-(m_sprSize.height)*(addRowNo-1)
            print("Size===>>",posX,posY)
            m_oneGood : setPosition(posX,posY)
            layout : addChild(m_oneGood)
        end


        -- local m_oneGood = self : createOneGoodMethod(k,nBagData[#nBagData-k+1])

        -- --位置设置 需要自己设置位置
        -- if k % ONEPAGE_ROWNO==1 then
        --   addColum = 0
        --   addRowNo = addRowNo + 1
        -- end
        -- addColum = addColum + 1

        -- local posX = m_sprSize.width/2+18+(m_sprSize.width+10)*(addColum-1)
        -- local posY =m_sprSize.height/2
        -- m_oneGood  : setPosition(posX,posY)
        pageView : addPage(layout)

         -- and nBagData[k]~=nil
    end

    self.m_mainBgSpr : addChild(pageView)

    -- local barView=require("mod.general.ScrollBar")(pageView)
    -- barView:setPosOff(cc.p(-12,0))

    self.m_pageView = pageView
end

function EquipGemLayer.setBagDatabyType(self,_type)
    local data        = _G.GBagProxy : getGemstoneList()
    local scelectdata = {}

    if data~=nil then
        for k,v in pairs(data) do
           local id = v.goods_id 
           local node = _G.Cfg.goods[id]
           if node~=nil then
              local m_type = node.type_sub
              print("----宝石选取---",m_type,_type)
              if m_type==_type then
                print("插入数据")
                  table.insert(scelectdata,v)
              end
           end

        end
    end
    print("ddddfdfd",scelectdata,#scelectdata)
    if scelectdata~=nil then
        local function sortfuncup( good1, good2)
            if good1.goods_id < good2.goods_id then
                return true
            end
            return false
        end
        table.sort( scelectdata, sortfuncup)
    end

    self.m_bagData = scelectdata
end

function EquipGemLayer.getBagDatabyType(self)
  return self.m_bagData
end

function EquipGemLayer.createOneGoodMethod( self,_no,_data )
  local tempNode = cc.Node:create()
  local nGoodbtn = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")


  local winSize  = cc.Director:getInstance():getVisibleSize()
  local function l_btnCallBack(sender, eventType)
    if eventType==ccui.TouchEventType.ended then
        local btn_tag=sender:getTag()
        local Position = sender : getWorldPosition()
        if self.isMoving>MOVECMAXOUNT then 
          self.isMoving = 0
          return 
        end
        self.isMoving = 0
        print("Position.x",Position.x,winSize.width/2+80,winSize.width/2+P_ROOT_SIZE.width/2-50)
        if Position.x<winSize.width/2+50 or Position.x>winSize.width/2+P_ROOT_SIZE.width/2-50
        or btn_tag <= 0 then return false end
        
        print("选择物品 id ",btn_tag)
        
        local temp = _G.TipsUtil:createById(btn_tag,_G.Const.CONST_GOODS_SITE_INLAIDBAG,Position)
        self.m_container:getParent():getParent():getParent():addChild(temp,500)

        self : setScelectGemId(btn_tag)
        return true
    elseif eventType==ccui.TouchEventType.moved then 
        self.isMoving = self.isMoving + 1
    end 
  end

  -- nGoodbtn:setSwallowTouches(false)
  -- nGoodbtn:addTouchEventListener(l_btnCallBack)

  tempNode : addChild(nGoodbtn)

  if _data==nil then return tempNode end

  -- nGoodbtn:setTag(_data.goods_id)

  local id=_data.goods_id
  local goodnode=_G.Cfg.goods[id]
  if goodnode~=nil then
    local iconSpr=_G.ImageAsyncManager:createGoodsBtn(goodnode,l_btnCallBack,id,_data.goods_num)
    -- iconSpr:setPosition(78/2,78/2)
    iconSpr:setSwallowTouches(false)
    tempNode:addChild(iconSpr,100)
  end

  return tempNode
end

function EquipGemLayer.unregister(self)
    print("EquipGemLayer.unregister")
    if self.pMediator~=nil then
      self.pMediator : destroy()
      self.pMediator = nil 
    end
end

function EquipGemLayer.onTipsCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
      local btn_tag = sender : getTag()
      print("按钮回调＝＝＝",btn_tag)
      -- for i=1,3 do
      --    if i==btn_tag then
      --       self.m_gemPanelArray[i].arrSpr : setVisible(true)
      --    else
      --       self.m_gemPanelArray[i].arrSpr : setVisible(false)
      --    end
      -- end
      self : createSelectEffect(sender)

      local m_oneData = self : getNowGemData()
      if m_oneData==nil then return end

      for i,part in pairs(m_oneData) do
         if i==btn_tag then
             local gemtype  = part.type
             local gemid    = part.pearl_id

             self:setBagDatabyType(gemtype)
             self:createGemPanel()
             self.m_preSelectPos=btn_tag
            
             if gemid==nil or gemid==0  then return end
             self : setScelectGemId(gemid)

            local Position = sender : getWorldPosition()
            local temp = _G.TipsUtil : createById(gemid,_G.Const.CONST_GOODS_SITE_INLAID,Position)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)

            break
         end
      end

    end
end
--现在的物品当前部位
function EquipGemLayer.setNowGoodsPartConst( self,_id )
    if self.m_nowGoodsPartConst~=_id then
        self.m_preSelectPos=1
    end
    self.m_nowGoodsPartConst = _id
end
function EquipGemLayer.getNowGoodsPartConst( self )
    return self.m_nowGoodsPartConst
end

function EquipGemLayer.setNowGemData( self,_data )
    self.NowGemData = _data
end
function EquipGemLayer.getNowGemData( self )
    return self.NowGemData
end

function EquipGemLayer.setScelectGemId( self,_data )
    self.ScelectGemId = _data
end
function EquipGemLayer.getScelectGemId( self )
    return self.ScelectGemId
end

--命令调用发协议
function EquipGemLayer.REQ_MAKE_PART_INSERT( self )
    local partnerid = self.m_curRoleUid
    local type_sub  = self:getNowGoodsPartConst() 
    local id        = self:getScelectGemId() 
    if partnerid==nil or type_sub==nil or id==nil then return end

    local msg = REQ_MAKE_PART_INSERT()
    msg :setArgs(partnerid,type_sub,id)
    _G.Network :send( msg)
    print("宝石镶嵌协议发送完毕－－－－－－")
end

function EquipGemLayer.REQ_MAKE_PART_INSERT_UP( self )
    local partnerid = self.m_curRoleUid
    local type_sub  = self : getNowGoodsPartConst() 
    local id        = self : getScelectGemId() 
    local node      = _G.Cfg.goods[id]
    if partnerid==nil or type_sub==nil or node==nil then return end

    self.m_gemUpdateMsg = REQ_MAKE_PART_INSERT_UP()
    self.m_gemUpdateMsg :setArgs(partnerid,type_sub,node.type_sub,0)
    _G.Network :send( self.m_gemUpdateMsg)
    print("宝石升级协议发送完毕－－－－－－")
end
function EquipGemLayer.gemUpdateMoneyBack(self,_money)
    if self.m_gemUpdateMsg==nil then return end
    local function nFun(_state)
        self.m_gemUpdateMsg.flag=1
        _G.Network:send(self.m_gemUpdateMsg)
        self.m_gemUpdateMsg=nil

        if not m_isNotic then
          m_isNotic=_state
        end
    end

    if not isHas5Star and m_isNotic then
        nFun()
        return
    end

    local szMsg
    if _money<=0 then
        szMsg="消耗同类低等宝石升级?\n(商城、试炼轮回可获得宝石礼包)"
    else
        szMsg=string.format("消耗同类低等宝石和%d钻石升级?\n(商城、试炼轮回可获得宝石礼包)",_money)
    end
    local boxView=_G.Util:showTipsBox(szMsg,nFun)
    boxView:showNeverNotic()
end

function EquipGemLayer.REQ_MAKE_PART_GEM_REMOVE( self )
    local partnerid = self.m_curRoleUid
    local type_sub  = self:getNowGoodsPartConst() 
    local id        = self:getScelectGemId() 
    if partnerid==nil or type_sub==nil or id==nil then return end

    local msg = REQ_MAKE_PART_GEM_REMOVE()
    msg :setArgs(partnerid,type_sub,id)
    _G.Network :send( msg)
    print("宝石拆卸协议发送完毕－－－－－－",id)
    _G.Util:playAudioEffect("Dong")
end

function EquipGemLayer.insertOkReturn( self )
  print("EquipGemLayer.insertOkReturn  1")
  local nPartConst=self:getNowGoodsPartConst()
  local partData
  if self.m_curRoleUid==0 then
    partData = _G.GPropertyProxy:getMainPlay():getEquipPartListBySort()
  else
    partData = _G.GPropertyProxy:getMainPlay():getWarPartner():getEquipPartListBySort()
  end

  if partData==nil or nPartConst==nil  then return end
  
  print("EquipGemLayer.insertOkReturn  2")
  self:initGemPanel(partData,nPartConst)
end

function EquipGemLayer.pushData( self,_data )
  print("EquipGemLayer.pushData",_data.nowGoodsPart,_data.nowPartGem)

  self.m_curPartData=_data
  local nPartConst=self:getPartTypeByNo(_data.nowGoodsPart)
  local nPartDataArray=_data.nowPartGem

  if nPartDataArray==nil or nPartConst==nil  then return end
  self:setNowGoodsPartConst(nPartConst)
  self:initGemPanel(nPartDataArray,nPartConst)

  local m_equipList  = _G.GPropertyProxy:getMainPlay():getEquipList()  --装备数据
  if m_equipList==nil then return end
  local scelectData=nil
  for k,v in pairs(m_equipList) do
     if nPartConst==v.index then
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
  -- self:XuanzhongRoleSpr(scelectData.goods_id)
  if self.m_effects_selectSpr~=nil then
      self.m_effects_selectSpr : removeFromParent(true)
      self.m_effects_selectSpr = nil 
  end
end

function EquipGemLayer.initGemPanel(self,_partDataArray,_partConst)
  print("initGemPanel===========>>>  1",_partDataArray,_partConst)
  --可镶嵌宝石显示清除
  for i=1,3 do
    self.m_equipGemSpr[i] : setVisible(false)
  end

  local preSelectPos=self.m_preSelectPos or 1
  for k,v in pairs(_partDataArray) do
    print("===========>>",_partConst,v.type_sub)
      if _partConst==v.type_sub then
          local partGemArray = v.gem_xxx
          local function sortfuncup( good1, good2)
              if good1.type<good2.type then
                  return true
              end
              return false
          end
          table.sort(partGemArray,sortfuncup)

          self:setNowGemData(partGemArray)

          print("部位类型---------------",k,v.type_sub)
          for i,part in pairs(partGemArray) do
            local gemtype  = part.type
            local gemid    = part.pearl_id
            print("此部位的镶嵌数据===",i,gemtype,gemid)
            --------------------
            --宝石可镶嵌显示
            local isTrue = false
            if gemid==0 then
              isTrue = self : getGemCountByType(gemtype)
            else
              isTrue = self : getGemCountById(gemid)
            end
            self.m_equipGemSpr[i] : setVisible(isTrue)
            --------------------
            self:initOneSoltData(i,gemtype,gemid)

            if i==preSelectPos then
                self:initFirstScelectGem(i,gemtype) --默认是第一个
            end
          end

          break 
      end
  end
end

function EquipGemLayer.getGemCountById(self,_id)
  local data = _G.GBagProxy : getGemstoneList()
  local node = _G.Cfg.goods[_id]
  if node==nil then return false end
  local next_gemId = node.d.as2 or 0  

  self.sum = 0 
  local isTrue = self : getGemById(_id)
  print("true",isTrue)
  return isTrue
end

function EquipGemLayer.getGemById(self,_id)
  print("当前宝石id",_id)
  local yushu = math.fmod(_id,10)
  print("当前宝石等级",yushu,MAX_BSLV)
  if yushu>=MAX_BSLV then return false end 
  local data = _G.GBagProxy:getGemstoneList()
  if data ~= nil then
    for k,v in pairs(data) do
      local goodId = data[k].goods_id
      print("goodId",goodId)
      local count  = 0 
      local bsdj = math.fmod(goodId,10)
      if bsdj <= yushu then 
        if math.floor(_id/1000) == math.floor(goodId/1000) then
          count = data[k].goods_num
          print("goodId",goodId,count,bsdj)
          self.sum = self.sum + count*3^(bsdj-1)
        end
      end
    end
  end
  local xCount = math.floor(self.sum/(2*3^(yushu-1)))
  print("当前背包拥有升级数",self.sum,xCount)
  if xCount>0 then
    return true
  else
    return false
  end
end

function EquipGemLayer.getGemCountByType(self,_type)
  local data = _G.GBagProxy : getGemstoneList()
  if data~=nil then
      for k,v in pairs(data) do
         local id = v.goods_id 
         local node = _G.Cfg.goods[id]
         if node~=nil and _type==node.type_sub  then
            print("EquipGemLayer getGemCountByType 有宝石勒")
            return true
         end

      end
  end
  return false
end

function EquipGemLayer.initFirstScelectGem( self,_no,_type )
  -- for i=1,3 do
  --    if i==_no then
  --       self.m_gemPanelArray[i].arrSpr : setVisible(true)
  --       self:createSelectEffect(self.m_gemPanelArray[i].gemBtn)
  --    else
  --       self.m_gemPanelArray[i].arrSpr : setVisible(false)
  --    end
  -- end
  self:setBagDatabyType(_type)

  self:createGemPanel()
end

function EquipGemLayer.initOneSoltData(self,_no,_gemtype,_id)
    if _no==nil or _no>3 then return end
    if self.m_gemSprArray[_no]~=nil then
        self.m_gemSprArray[_no]:removeFromParent(true)
        self.m_gemSprArray[_no]=nil
    end

    local Gemname = ""
    local Color   = _G.Const.CONST_COLOR_WHITE
    if _id==0 then
        Gemname = _G.Lang.gem_typename[_gemtype]  or ""
    else
       local node = _G.Cfg.goods[_id]
       if node==nil then return end
       Color   = node.name_color
       Gemname = node.name

      local sprSize     = self.m_gemPanelArray[_no].gemBtn : getContentSize()
      self.m_gemSprArray[_no]  = _G.ImageAsyncManager:createGoodsSpr(node)
      self.m_gemSprArray[_no]  : setPosition(sprSize.width/2,sprSize.height/2)
      self.m_gemPanelArray[_no].gemBtn  : addChild(self.m_gemSprArray[_no])

    end

    self.m_gemPanelArray[_no].stateLab : setString(Gemname)
    self.m_gemPanelArray[_no].stateLab : setColor(_G.ColorUtil:getRGB(Color))
    self.m_gemPanelArray[_no].stateSpr : setPreferredSize(cc.size(self.m_gemPanelArray[_no].stateLab:getContentSize().width+10,30))
    -- --现在的孔初始化
end

function EquipGemLayer.createSelectEffect( self,_obj )
    if _obj==nil then
        return 
    end
    if self.m_effects_selectSpr~=nil then
        self.m_effects_selectSpr : removeFromParent(true)
        self.m_effects_selectSpr = nil 
    end

    self.m_effects_selectSpr = cc.Sprite :create()
    self.m_effects_selectSpr : runAction(cc.RepeatForever:create(_G.AnimationUtil:getSelectBtnAnimate()))
    self.m_effects_selectSpr : setPosition(78/2-1,78/2)

    _obj:addChild(self.m_effects_selectSpr,20)
end

function EquipGemLayer.checkGemFromBag( self,_id )
   local isHave  = false 
   local m_data  = _G.GBagProxy : getGemstoneList()
    if m_data  ~=nil then
        for k,v in pairs(m_data) do
            if v.goods_id==_id then
                isHave  = true
                break 
            end
        end
    end

    return isHave
end

function EquipGemLayer.getPartTypeByNo( self,_no )
    local m_no = nil 
    if _no==1 then
      m_no = _G.Const.CONST_EQUIP_ARMOR
    elseif _no==2 then
      m_no = _G.Const.CONST_EQUIP_CLOAK
    elseif _no==3 then
      m_no = _G.Const.CONST_EQUIP_SHOE
    elseif _no==4 then
      m_no = _G.Const.CONST_EQUIP_NECKLACE
    elseif _no==5 then
      m_no = _G.Const.CONST_EQUIP_WEAPON
    elseif _no==6 then
      m_no = _G.Const.CONST_EQUIP_RING
    end 

    return m_no 
end

function EquipGemLayer.getPlayerData( self,_CharacterName )
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
    elseif _CharacterName==MONEYTYPE_GOLD then
        CharacterValue = mainplay : getGold()
    elseif _CharacterName==MONEYTYPE_RMB then
        CharacterValue = mainplay :getRmb() + mainplay :getBindRmb()
    elseif _CharacterName==MONEYTYPE_JADE then
        CharacterValue = 1
    end

    return CharacterValue
end

function EquipGemLayer.chuangeRole(self,_uid,_nowPartGem)
    self.m_curRoleUid=_uid or 0
    self.m_curPartData.nowPartGem=_nowPartGem
    self:pushData(self.m_curPartData)
end

function EquipGemLayer.GemSuccEffect(self,flag)
  print("镶嵌成功特效",flag)
    if flag == 1 then
      self.GemSpr = "main_effect_word_xq.png"
      _G.Util:playAudioEffect("ui_inlaid_stones")
    elseif flag == 2 then
      self.GemSpr = "main_effect_word_sj.png"
      _G.Util:playAudioEffect("ui_equip_add_magic")
    else return end

    if self.m_gemSuccSpr~=nil then return end
    self.m_gemSuccSpr=cc.Sprite:createWithSpriteFrameName(self.GemSpr)
    self.m_gemSuccSpr:setScale(0.05)
    self.m_gemSuccSpr:setPosition(0,0)
    -- self.m_container:addChild(self.m_gemSuccSpr,1000)
    local sizes = cc.size(85,85) 
    self.m_gemPanelArray[self.m_preSelectPos].gemBtn : addChild(self.m_gemSuccSpr,1000)    
    self.m_gemSuccSpr : setPosition(sizes.width/2-25,sizes.height/2)


    local addSpr =  cc.Sprite:createWithSpriteFrameName("main_effect_word_cg1.png") 
    self.m_gemSuccSpr : addChild(addSpr)
    local sprsize  = self.m_gemSuccSpr : getContentSize()
    local sprsize2 = addSpr : getContentSize()
    addSpr : setPosition(sprsize.width+sprsize2.width/2,sprsize.height/2)

    local function f1()
        self.m_gemSuccSpr:removeFromParent(true)
        self.m_gemSuccSpr=nil
    end
    local function f2()
        local action=cc.Sequence:create(cc.FadeTo:create(0.15,0),cc.CallFunc:create(f1))
        self.m_gemSuccSpr:runAction(action)
    end
    local function f3()
        local szPlist="anim/task_finish.plist"
        local szFram="task_finish_"
        local act1=_G.AnimationUtil:createAnimateAction(szPlist,szFram,0.12)
        local act2=cc.CallFunc:create(f2)

        local sprSize=self.m_gemSuccSpr:getContentSize()
        local effectSpr=cc.Sprite:create()
        effectSpr:setPosition(sprSize.width,sprSize.height*0.5)
        effectSpr:runAction(cc.Sequence:create(act1,act2))
        self.m_gemSuccSpr:addChild(effectSpr)
    end
    local action=cc.Sequence:create(cc.ScaleTo:create(0.15,1),cc.CallFunc:create(f3))
    self.m_gemSuccSpr:runAction(action)
end

return EquipGemLayer