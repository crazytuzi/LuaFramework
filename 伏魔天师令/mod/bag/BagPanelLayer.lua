local BagPanelLayer = classGc(view, function(self,_panelType)
    self.m_panelType = _panelType
    print("_panelType_panelType=",_panelType)

    self.isMoving = 0
    self.NowPage   = 1
end)

local TAG_PROPS = 1
local TAG_GEM   = 2
local TAG_EQUIP = 3
local TAG_BUY   = 4
local PAGECOUNT = 32
local FONTSIZE  = 20


local winSize  = cc.Director:getInstance():getWinSize()
local mainSize = cc.size(830, 427)
local iconSize  = cc.size(79,79)

function BagPanelLayer.__create(self)
  self.m_container = cc.Node:create()
  -- self.m_container : setPosition(winSize.width/2,0)
  --中间换页数显示
  -- local di2kuanSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_di2kuan.png" ) 
  -- di2kuanSpr : setPreferredSize(cc.size(790,412))
  -- di2kuanSpr : setPosition(mainSize.width/2+13,mainSize.height/2+15)
  -- self.m_container : addChild(di2kuanSpr)

  self.m_kuangSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double.png" ) 
  self.m_kuangSpr : setPreferredSize( mainSize )
  self.m_kuangSpr : setPosition(0,-30)
  self.m_container : addChild(self.m_kuangSpr)

  local page_bg  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
  page_bg        : setPreferredSize(cc.size(80,40))
  page_bg        : setPosition(mainSize.width/2, -35)
  -- page_bg        : setScaleX(2.5)
  self.m_kuangSpr: addChild(page_bg)

  local pageSize = page_bg : getContentSize()
  -- self.LeftSpr   = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
  -- self.LeftSpr   : setPosition(-15, pageSize.height/2)
  -- page_bg        : addChild(self.LeftSpr)

  -- self.RightSpr  = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
  -- self.RightSpr  : setPosition(pageSize.width+15, pageSize.height/2)
  -- self.RightSpr  : setScale(-1)
  -- page_bg        : addChild(self.RightSpr)

  self.pageLab = _G.Util : createLabel("", FONTSIZE)
  -- self.pageLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
  self.pageLab : setPosition(mainSize.width/2-2, -37)
  self.m_kuangSpr: addChild(self.pageLab)

  local numsLab = _G.Util : createLabel("格子容量:", FONTSIZE)
  numsLab : setPosition(mainSize.width-135, -23)
  numsLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  self.m_container: addChild(numsLab)

  self.m_bagCountLab = _G.Util : createLabel("",FONTSIZE)
  self.m_bagCountLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  self.m_bagCountLab : setAnchorPoint( cc.p(0.0,0.5) ) 
  self.m_bagCountLab : setPosition(mainSize.width-85,-23)
  self.m_container   : addChild(self.m_bagCountLab) 

  self : BagPageView()
  self : updateShowGoodsCountLab()

  return self.m_container
end

function BagPanelLayer.BagPageView( self )
  if self.m_panelType == nil then return end
  local bagData  = self : getBagDataByeType(self.m_panelType)
  local bagData1 = self : getBagDataByeType(1)
  local bagData2 = self : getBagDataByeType(2)
  local bagData3 = self : getBagDataByeType(3)
  local bagData4 = self : getBagDataByeType(4)
  if bagData1==nil or bagData2==nil or bagData3==nil or bagData4==nil then return end

  self.m_bagCount = #bagData1 + #bagData2 + #bagData3
  if self.m_panelType==TAG_BUY then
    self.m_bagCount = #bagData4
  end
  print("BagPanelLayer.BagScrollView =",self.m_bagCount)

  local bagCount = #bagData
  local roleCount = math.ceil(bagCount/PAGECOUNT)
  print("self.m_pageCount:", bagCount,roleCount)
  if roleCount == nil or roleCount < 1 then roleCount = 1 end
  self.oneHeight = (mainSize.height-30)/4

  local pageView = ccui.PageView : create()
  pageView : setTouchEnabled(true)
  pageView : setSwallowTouches(true)
  pageView : setContentSize(cc.size(mainSize.width-3,mainSize.height))
  pageView : setPosition(cc.p(1, 0))
  pageView : setCustomScrollThreshold(50)
  pageView : enableSound()
  self.m_kuangSpr : addChild(pageView)

  local function cFun(sender,eventType)
      if eventType==ccui.TouchEventType.move then 
          print( "移动啦" )
      elseif eventType==ccui.TouchEventType.began then
          self.isMove = sender : getWorldPosition().x
          print( "按下啦" )
      elseif eventType==ccui.TouchEventType.ended then
          local move  = sender : getWorldPosition().x - self.isMove
          print( "移动了：", move )
          if move > 10 or move < -10 then
            print( "这是一次移动" )
            return
          end
          local nTag=sender:getTag()
          local nPos=sender:getWorldPosition()

          print("postion---->>>>",nPos.x,winSize.width/2+mainSize.width/2,winSize.width/2-mainSize.width/2)
          if nPos.x>winSize.width/2+mainSize.width/2 
            or nPos.x<winSize.width/2-mainSize.width/2
            or nTag<=0 then
              return
          end

          local goodMsg=self:getGoodsByIndex(nTag)
          if goodMsg==nil then 
              return 
          end
          local bagType=_G.Const.CONST_GOODS_SITE_BACKPACK
          if self.m_panelType==TAG_BUY then
              bagType=_G.Const.CONST_GOODS_SITE_GOODSELL
          end

          local temp=_G.TipsUtil:create(goodMsg,bagType,nPos,0)
          cc.Director:getInstance():getRunningScene():addChild(temp,1000)
      end
  end

 
  local roleid = 1
  for i=1,roleCount do
    local addRowNo = 0 -- 第几行
    local addColum = 0 -- 第几列
    local layout   = ccui.Layout : create()
    -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    -- layout : setContentSize(kuangSize)
    -- layout:setBackGroundColor(cc.c3b(255, 100, 100))
    for j=1,PAGECOUNT do
      local baginfo = bagData[roleid]
      -- print("baginfo",bagData[roleid])
      
      -- if i > 4 and goodsdata == nil then return end 
      local goodSpr = cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
      if j % 8 == 1 then
        addColum = 0
        addRowNo = addRowNo + 1
      end
      addColum = addColum + 1

      local posX = iconSize.width/2+28+(iconSize.width+20)*(addColum-1)
      local posY = mainSize.height-self.oneHeight/2-15-self.oneHeight*(addRowNo-1)
      goodSpr : setPosition(posX,posY)
      layout : addChild(goodSpr)

      if baginfo ~= nil then
        local goodsdata = _G.Cfg.goods[baginfo.goods_id]
        if goodsdata ~= nil then
          local goodnums = 1
          if baginfo.goods_num > 0 then
              goodnums = baginfo.goods_num
          end

          local iconBtn=_G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,baginfo.index,goodnums)
          iconBtn      : setSwallowTouches(false)
          iconBtn : setPosition(iconSize.width/2, iconSize.height/2)
          -- goodSpr : addTouchEventListener(cFun)
          -- goodSpr : setTag(baginfo.index)
          goodSpr : addChild(iconBtn)
        end
      end
      roleid = roleid + 1
    end
    pageView : addPage(layout)
  end

  print("m_nowPageCount",m_nowPageCount,self.NowPage)
  local m_nowPageCount = self.NowPage
  self.pageLab : setString(string.format(" %d/%d ",m_nowPageCount,roleCount))
  -- if m_nowPageCount == 1 then
    -- self.LeftSpr:setVisible(false)
    -- if m_nowPageCount == roleCount then
      -- self.RightSpr:setVisible(false)
    -- end
  -- end
  local function pageViewEvent(sender, eventType)
      if eventType == ccui.PageViewEventType.turning then
          local pageView       = sender
          local m_nowPageCount = pageView : getCurPageIndex() + 1
          local pageInfo       = string.format(" %d/%d ",m_nowPageCount,roleCount)
          print("翻页", pageView : getCurPageIndex(),pageInfo)
          self.pageLab : setString(pageInfo)
          -- if m_nowPageCount == 1 then
            -- self.LeftSpr:setVisible(false)
            -- self.RightSpr:setVisible(true)
            -- if m_nowPageCount == roleCount then
              -- self.RightSpr:setVisible(false)
            -- end
          -- elseif m_nowPageCount == roleCount then
            -- self.LeftSpr:setVisible(true)
            -- self.RightSpr:setVisible(false)
          -- else
            -- self.LeftSpr:setVisible(true)
            -- self.RightSpr:setVisible(true)
          -- end
          self.NowPage = m_nowPageCount
      end
  end
  print("dadasdsad",self.NowPage)
  pageView : scrollToPage(self.NowPage-1)
  pageView : addEventListener(pageViewEvent)
end

function BagPanelLayer.updateShowGoodsCountLab( self )
  local goodsCount = self.m_bagCount  
  print("goodsCount-->",goodsCount)
  local m_str = "500"
  if self.m_panelType == TAG_BUY then
     m_str = "32"
  end
  self.m_bagCountLab : setString(goodsCount.."/"..m_str)
end

function BagPanelLayer.getBagDataByeType(self,_type)
    local data = nil 
    if _type == TAG_EQUIP then
        data = _G.GBagProxy : getEquipmentList()
    elseif _type  == TAG_GEM then
        data = _G.GBagProxy : getGemstoneList()
    elseif _type == TAG_PROPS then
        data = _G.GBagProxy : getPropsList()
    elseif _type == TAG_BUY then
        data = _G.GBagProxy : getBagSellList()
    end

    local function sortfuncup( good1, good2)
        if good1.goods_id<good2.goods_id then
            return true
        end
        return false
    end
    table.sort(data,sortfuncup)

    return data 
end

function BagPanelLayer.getGoodsByIndex( self, _index)
    local bagData=self:getBagDataByeType(self.m_panelType)
    if bagData==nil then return end 
    for k,v in pairs( bagData) do
        if v.index==_index then
            return v
        end
    end
    return nil
end

return BagPanelLayer