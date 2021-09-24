local EquipBagLayer = classGc(view, function(self,_uid)
    self.m_curRoleUid=_uid or 0
    self.isMoving = 0
   -- self.m_myProperty=_G.GPropertyProxy:getMainPlay()

end)


local rootBgSize = cc.size(828,476)
local sprSize      = cc.size(79,79)


function EquipBagLayer.__create(self)
  self.m_container = cc.Node:create()
  self.goodDataTab = {}
  --右边内容－－－－－－－－－－－－－－－－－－－－－－－－－－－
  self.m_bgSpr2Size = cc.size(rootBgSize.width/2-30,rootBgSize.height-11)
  self.m_rightBgSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" )
  self.m_rightBgSpr : setPosition(rootBgSize.width/2-self.m_bgSpr2Size.width/2-5,-55)
  self.m_rightBgSpr : setPreferredSize( self.m_bgSpr2Size )
  self.m_container  : addChild(self.m_rightBgSpr)

  -- local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
  -- local lineSize = lineSpr:getContentSize()
  -- lineSpr : setPreferredSize(cc.size(self.m_bgSpr2Size.width-2,lineSize.height))
  -- lineSpr : setPosition(self.m_bgSpr2Size.width/2,30)
  -- self.m_rightBgSpr : addChild(lineSpr)

  self : EquipScrollView()

  return self.m_container
end

function EquipBagLayer.unregister(self)

end

function EquipBagLayer.EquipScrollView( self )
  if self.m_scrollView ~= nil then
    self.m_scrollView : removeFromParent(true)
    self.m_scrollView = nil

     print("清空goodDataTab")
     self.goodDataTab = {}    
    -- if self.goodDataTab ~= nil
    --[[
    for k,v in pairs(self.goodDataTab) do 
       print("清空goodDataTab.k.v",v)
       self.goodDataTab[k] = nil
    end
    --]]

  
  end
  
  local bagData=_G.GBagProxy:getRoleBagList()
  if bagData==nil then return end
  local bagCount = #bagData
  local roleCount = math.ceil(bagCount/3)
  if roleCount<4 then roleCount=4 end

  self.oneHeight = (self.m_bgSpr2Size.height-60)/4
  local viewSize = cc.size(self.m_bgSpr2Size.width-2,self.m_bgSpr2Size.height-60)
  local scrollViewSize = cc.size(self.m_bgSpr2Size.width-2,self.oneHeight*roleCount)

  local contentView = cc.ScrollView:create()
  contentView : setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  contentView : setViewSize(viewSize)
  contentView : setContentSize(scrollViewSize)
  contentView : setPosition(0,30)
  contentView : setContentOffset( cc.p( 0,viewSize.height-scrollViewSize.height)) -- 设置初始位置
  self.m_rightBgSpr : addChild(contentView)
  local barView=require("mod.general.ScrollBar")(contentView)
  barView:setPosOff(cc.p(-5,0))

  self.m_scrollView = contentView

  self.m_goodIdArray = {}
  self.m_powerfulArray = {}
  self.typeArray={}
  for k,v in pairs(bagData) do
    print("EquipScrollView",k,v.goods_id)
    self.m_goodIdArray[k] = v.goods_id
    self.m_powerfulArray[k]=v.powerful
  end
  local goodsSort = {}



  local winSize=cc.Director:getInstance():getVisibleSize()
  local function cFun(sender,eventType)
      if eventType==ccui.TouchEventType.began then
          self.m_touchOff=self.m_scrollView:getContentOffset()
      elseif eventType==ccui.TouchEventType.ended then
          local curOff=self.m_scrollView:getContentOffset()
          local subY=math.abs(self.m_touchOff.y-curOff.y)
          if subY>10 then
              return
          end

          local nTag=sender:getTag()
          local nPos=sender:getWorldPosition()

          print("cFun===>>",nPos.y,winSize.height/2+rootBgSize.height/2-100,winSize.height/2-rootBgSize.height/2-15)
          if nPos.y>winSize.height/2+rootBgSize.height/2-100 
            or nPos.y<winSize.height/2-rootBgSize.height/2-15
            or nTag<=0 then return end

          local bagType=_G.Const.CONST_GOODS_SITE_ROLEBACKPACK
          local temp=_G.TipsUtil:create(bagData[nTag],bagType,nPos,self.m_curRoleUid)
          cc.Director:getInstance():getRunningScene():addChild(temp,1000)
      end
  end

  local addRowNo = 0 -- 第几行
  local addColum = 0 -- 第几列
  local idx = 1
  for i=1,roleCount do
      for j=1,3 do
        local goodsdata=_G.Cfg.goods[self.m_goodIdArray[idx]]
        -- if i>4 then return end 
        local goodSpr = cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
        if j%3 == 1 then
            addColum = 0
            addRowNo = addRowNo + 1
        end
        addColum = addColum + 1

        local posX = sprSize.width/2+40+115*(addColum-1)
        local posY = scrollViewSize.height-51-self.oneHeight*(addRowNo-1)
        goodSpr : setPosition(posX,posY)
        contentView : addChild(goodSpr)

        if goodsdata~=nil then
            local iconBtn=_G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,idx,1)
            iconBtn:setPosition(sprSize.width/2,sprSize.height/2)
            iconBtn:setSwallowTouches(false)
            goodSpr:addChild(iconBtn)
             
            --self.goodDataTab.(goodsdata.type_sub) = {}

            self:isUporNotUp(goodsdata.type_sub,goodsdata.star,self.m_powerfulArray[idx],goodsdata.type_sub,iconBtn)
        end
        idx = idx + 1
      end
  end
  self : chuangeRole()
end
--function EquipBagLayer.isGoods

function EquipBagLayer.chuangeRole(self,_uid)
  print("self.m_curRoleUid",_uid)
  -- if self.m_curRoleUid~= 0 and self.iconBtn ~= nil then
  --   self.iconBtn : setEnabled(false)
  -- end
  if _uid~=nil then
    self.m_curRoleUid=_uid
  end
end

function EquipBagLayer.isUporNotUp(self,index,star,pow,_type,kuang)
   print("_type-->",_type)
  
    if self.goodDataTab[_type] == nil  then 
      self.goodDataTab[_type] = {} 
      self.goodDataTab[_type].powMax = pow
      self.goodDataTab[_type].starMax = star
      print("创建goodDataTab[_type]",_type,self.goodDataTab[_type].powMax,self.goodDataTab[_type].starMax)
      --print("self.goodDataTab._type",pow,star)
    else  
     
     --print("self.goodDataTab._type",self.goodDataTab._type)
     if self.goodDataTab[_type].starMax  < star then
        print("star资质对比",self.goodDataTab[_type].starMax,star)
        self.goodDataTab[_type].starMax = star
        self.goodDataTab[_type].pow  =  pow
         if self.typeArray[_type] ~= nil then 
            self.typeArray[_type]:removeFromParent(true) 
            self.typeArray[_type] = nil
         end 
         print("star-->大于",self.goodDataTab[_type].starMax,star)
     elseif self.goodDataTab[_type].starMax >  star then 
           print("star-->小于",self.goodDataTab[_type].starMax,star)
          return 
     elseif self.goodDataTab[_type].starMax == star then 
          print("star-->等于",self.goodDataTab[_type].starMax,star,pow)
          if self.goodDataTab[_type].powMax  < pow  then 
             print("战力对比:",self.goodDataTab[_type].powMax,pow)
             self.goodDataTab[_type].powMax = pow
          if self.typeArray[_type] ~= nil then 
              self.typeArray[_type]:removeFromParent(true) 
              self.typeArray[_type] = nil  
          end 
             --self.goodDataTab._type.starMax = star
          else 
             return
          end 
      end 
  end
 

  local action=cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5,180),cc.FadeTo:create(0.5,255)))
  print("m_equipList--->>",m_equipList,index,star,pow)

  local m_equipList  = _G.GPropertyProxy:getMainPlay():getEquipList()  --装备数据
  if m_equipList==nil then return end
  local scelectData=nil
  for k,v in pairs(m_equipList) do
      print("v.index",k,v.index)
      if index == v.index then
         scelectData = v
          print("dsdasdsadsad",v.goods_id,v.index,v.star,v.powerful)
          break
      end 
  end 

  for i=11,16 do
    if index==i and scelectData~=nil then
      print("加载upSpr",scelectData.star,star,"战力:",scelectData.powerful,pow)
      if scelectData.star < star then
        local upSpr=cc.Sprite:createWithSpriteFrameName("general_tip_down.png")
        upSpr:setRotation(-90)
        upSpr:setScale(0.4)
        upSpr:setPosition(62,15)
        upSpr:runAction(action:clone())
        kuang:addChild(upSpr)
        self.typeArray[i]=upSpr    
      elseif scelectData.star==star and scelectData.powerful<pow then
        local upSpr=cc.Sprite:createWithSpriteFrameName("general_tip_down.png")
        upSpr:setRotation(-90)
        upSpr:setScale(0.4)
        upSpr:setPosition(62,15)
        upSpr:runAction(action:clone())
        kuang:addChild(upSpr)
        self.typeArray[i]=upSpr 
      end
    elseif index==i and scelectData==nil then
        local upSpr=cc.Sprite:createWithSpriteFrameName("general_tip_down.png")
        upSpr:setRotation(-90)
        upSpr:setScale(0.4)
        upSpr:setPosition(62,15)
        upSpr:runAction(action:clone())
        kuang:addChild(upSpr) 
        self.typeArray[i]=upSpr 
    end
  end
end

return EquipBagLayer