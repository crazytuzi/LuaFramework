local RushView = classGc(view, function(self)
  self.m_mediator= require("mod.smodule.RushMediator")()
  self.m_mediator: setView(self)
end)

local R_ROWNO = 3
local PAGECOUNT = 6
local FONTSIZE = 20
local m_winSize=cc.Director:getInstance():getWinSize()
local doubleSize = cc.size( 846,468 )
local iconSize = cc.size(78,78)

function RushView.create( self )
  self.m_normalView=require("mod.general.NormalView")()
  self.m_rootLayer=self.m_normalView:create()
  self.m_normalView : setTitle("限时抢购")

  local tempScene=cc.Scene:create()
  tempScene:addChild(self.m_rootLayer)

  self:init()

  return tempScene
end

function RushView.init( self )
    local function nCloseFun()
      self:closeWindow()
    end
    self.m_normalView:addCloseFun(nCloseFun)
    -- self.m_normalView:showSecondBg()
    --初始化界面
    self:initView()
    --请求服务端消息
    self:requestService(20,2010)
end

function RushView.requestService(self,_type,_type_bb)
    --向服务器发送页面数据请求
    local msg = REQ_SHOP_REQUEST()
    msg : setArgs(_type,_type_bb)
    _G.Network : send(msg)
end

function RushView.initView( self )
  self.m_mainNode = cc.Node:create()
  self.m_mainNode : setPosition(m_winSize.width*0.5,m_winSize.height*0.5)
  self.m_rootLayer: addChild(self.m_mainNode)

  self.doubleSpr  = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
  self.doubleSpr  : setPreferredSize(doubleSize)
  self.doubleSpr  : setPosition(0, -20)
  self.m_mainNode : addChild(self.doubleSpr)

  local page_bg  = cc.Sprite : createWithSpriteFrameName("timeshop_shalou.png")
  page_bg : setPosition(doubleSize.width-100, -21)
  self.doubleSpr : addChild(page_bg)

  self.endtimeLab = _G.Util : createLabel("", FONTSIZE)
  self.endtimeLab : setAnchorPoint( cc.p(0.0,0.5) )
  self.endtimeLab : setPosition(doubleSize.width-80, -21)
  self.endtimeLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
  self.doubleSpr: addChild(self.endtimeLab)

  local page_bg  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
  page_bg : setPreferredSize(cc.size(60,35))
  page_bg : setPosition(doubleSize.width/2, -21)
  self.doubleSpr : addChild(page_bg)

  local pageSize = page_bg : getContentSize()
  -- self.LeftSpr   = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
  -- self.LeftSpr   : setPosition(-15, pageSize.height/2)
  -- page_bg        : addChild(self.LeftSpr)

  -- self.RightSpr  = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
  -- self.RightSpr  : setPosition(pageSize.width+15, pageSize.height/2)
  -- self.RightSpr  : setScale(-1)
  -- page_bg        : addChild(self.RightSpr)

  self.pageLab = _G.Util : createLabel("", FONTSIZE)
  self.pageLab : setPosition(pageSize.width/2, pageSize.height/2-1)
  page_bg: addChild(self.pageLab)
end

function RushView.pushData( self, _data)
  self.count = _data.count
  self.m_msg = _data.msg

  if self.m_pageView==nil then
    print("创建商店")
    self.timenext=_data.end_time
    self : countdownEvent()
    self : ShopPageView(_data.count,_data.msg)
  else
    print("刷新商店")
    self : SurplusBreak(_data.count,_data.msg)
    _G.Util:playAudioEffect("ui_receive_awards")
  end
end

function RushView.SurplusBreak( self, count, msg)
  for i=1, count do
    local goodData = msg[i]
    self.btnArray[goodData.idx].Lab:setString(goodData.total_remaider_num)
    if goodData.total_remaider_num<=0 then
      self.btnArray[goodData.idx].Btn:setTitleText("售完")
      self.btnArray[goodData.idx].Btn:setBright(false)
      self.btnArray[goodData.idx].Btn:setEnabled(false)
      self.btnArray[goodData.idx].Spr:setSpriteFrame("timeshop_wan.png")
    end
  end
end

function RushView.ShopPageView( self, pagecount, msg)
  -- if self.m_pageView~=nil then
  --   self.m_pageView:removeFromParent(true)
  --   self.m_pageView=nil
  -- end
  if msg == nil then return end
  local layerSize = cc.size(doubleSize.width-10,doubleSize.height)
  local pageView = ccui.PageView : create()
  pageView : setTouchEnabled(true)
  pageView : setSwallowTouches(true)
  pageView : setContentSize(layerSize)
  pageView : setPosition(cc.p(5, -2))
  pageView : setCustomScrollThreshold(50)
  pageView : enableSound()
  self.doubleSpr : addChild(pageView)

  self.m_pageView = pageView

  local m_pageCount = math.ceil(pagecount/PAGECOUNT)
  print("self.m_pageCount:", pagecount,m_pageCount)
  if m_pageCount == nil or m_pageCount < 1 then m_pageCount = 1 end

  self.btnArray = {}
  local m_goodNo    = 0  --物品个数
  local curCount=0
  for i=1, m_pageCount do
    local addRowNo  = 0 -- 第几行
    local addColum  = 0 -- 第几列
    local layout   = ccui.Layout : create()
    -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    layout : setContentSize(layerSize)
    -- layout:setBackGroundColor(cc.c3b(255, 100, 100))

    for ii=1, PAGECOUNT do
      curCount=curCount+1
      local goodData = msg[curCount]
      print("创建一页", goodData, msg, curCount)
      m_goodNo = m_goodNo + 1
      if m_goodNo > pagecount then break end
      local m_oneGood = self : ShopOneKuang(m_goodNo,goodData)

      if ii % R_ROWNO == 1 then
        addColum = 0
        addRowNo = addRowNo + 1
      end
      addColum   = addColum + 1

      if m_oneGood==nil then return end
      local posX = self.shopSize.width/2+4+(self.shopSize.width+5)*(addColum-1)
      local posY = layerSize.height-self.shopSize.height/2-8-(self.shopSize.height+6)*(addRowNo-1)
      print("Size===>>",posX,posY)
      m_oneGood : setPosition(posX,posY)
      layout : addChild(m_oneGood)
    end
    pageView : addPage(layout)
  end
  local m_nowPageCount = 1
  self.pageLab : setString(string.format(" %d/%d ",m_nowPageCount,m_pageCount))
  -- if m_nowPageCount == 1 then
  --   self.LeftSpr:setVisible(false)
  --   if m_nowPageCount == m_pageCount then
  --     self.RightSpr:setVisible(false)
  --   end
  -- end
  local function pageViewEvent(sender, eventType)
    if eventType == ccui.PageViewEventType.turning then
      local pageView       = sender
      local m_nowPageCount = pageView : getCurPageIndex() + 1
      local pageInfo       = string.format(" %d/%d ",m_nowPageCount,m_pageCount)
      print("翻页", pageInfo)
      self.pageLab : setString(pageInfo)
      -- if m_nowPageCount == 1 then
      --   self.LeftSpr:setVisible(false)
      --   self.RightSpr:setVisible(true)
      --   if m_nowPageCount == m_pageCount then
      --     self.RightSpr:setVisible(false)
      --   end
      -- elseif m_nowPageCount == m_pageCount then
      --   self.LeftSpr:setVisible(true)
      --   self.RightSpr:setVisible(false)
      -- else
      --   self.LeftSpr:setVisible(true)
      --   self.RightSpr:setVisible(true)
      -- end
    end
  end
  pageView : addEventListener(pageViewEvent)
end

function RushView.ShopOneKuang( self,Num,_data)
  print("创建物品框", Num, _data, _data.msg_xxx,_data.msg_xxx.goods_id)
  local goods_id = _data.msg_xxx.goods_id
  local icondata = _G.Cfg.goods[goods_id]
  local idx      = _data.idx
  print("icondata",icondata)
  if icondata == nil then return end 
  
  local shopSpr = cc.Sprite : createWithSpriteFrameName("timeshop_shopkuang.png")
  self.shopSize = shopSpr:getContentSize()

  local rolename = icondata.name
  local roleLab  = _G.Util : createBorderLabel(rolename, FONTSIZE)
  roleLab : setPosition(self.shopSize.width/2, self.shopSize.height-18)
  roleLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
  shopSpr : addChild(roleLab)

  local shop_hot = cc.Sprite : createWithSpriteFrameName("timeshop_shopjiao.png")
  shop_hot : setPosition(36, self.shopSize.height-30)
  shopSpr  : addChild(shop_hot)

  local strLab = _G.Util : createLabel("剩余", FONTSIZE-2)
  strLab : setPosition(self.shopSize.width-45, self.shopSize.height/2+50)
  -- strLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
  shopSpr  : addChild(strLab)

  local numsLab = _G.Util : createLabel(_data.total_remaider_num, FONTSIZE)
  numsLab : setPosition(self.shopSize.width-45, self.shopSize.height/2+27)
  numsLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
  -- numsLab : setAnchorPoint( cc.p(0.0,0.5) )
  shopSpr  : addChild(numsLab)

  self.btnArray[idx]={}
  self.btnArray[idx].Lab=numsLab
  self.btnArray[idx].Spr=shop_hot

  local jadeLab1 = _G.Util : createLabel(_data.v_price, FONTSIZE)
  jadeLab1 : setPosition(self.shopSize.width/2-2, 75)
  jadeLab1 : setAnchorPoint( cc.p(1,0.5) )
  jadeLab1 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
  shopSpr  : addChild(jadeLab1)

  local rmbSize = jadeLab1 : getContentSize()
  local line = cc.DrawNode : create()--绘制线条
  line    : drawLine(cc.p(0,2), cc.p(rmbSize.width+8,2), cc.c4f(0.6,0.1,0,1))
  line    : setAnchorPoint( cc.p(1,0.5) )
  line    : setPosition(self.shopSize.width/2-rmbSize.width-5, 73)
  shopSpr : addChild(line,2)

  local huobiImg = "general_xianYu.png"
  if _data.type == 3 then
      huobiImg   = "general_gold.png"
  elseif _data.type == 1 then
      huobiImg   = "general_tongqian.png"
  end
  local jade = cc.Sprite : createWithSpriteFrameName(huobiImg)
  jade    : setPosition(self.shopSize.width/2-rmbSize.width-23, 76)
  shopSpr : addChild(jade)

  local jadeLab2 = _G.Util : createLabel(_data.s_price, FONTSIZE)
  jadeLab2 : setPosition(self.shopSize.width/2+18, 75)
  jadeLab2 : setAnchorPoint( cc.p(0.0,0.5) )
  jadeLab2 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
  shopSpr  : addChild(jadeLab2)

  local function WidgetCallback(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      local role_tag = sender : getTag()
      local Position = sender : getWorldPosition()
          print("Position.x",Position.x,m_winSize.width/2-doubleSize.width/2)
          if Position.x > m_winSize.width/2+doubleSize.width/2 or Position.x < m_winSize.width/2-doubleSize.width/2
            or role_tag <= 0 then return end
      print("弹出对应的购买框", role_tag)
      sender:setOpacity(255)
      local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
      cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
    end
  end

  local roleBtn = gc.CButton : create("general_tubiaokuan.png")
  roleBtn  : setPosition(self.shopSize.width/2, self.shopSize.height/2+24)
  roleBtn  : addTouchEventListener(WidgetCallback)
  roleBtn  : setSwallowTouches(false)
  roleBtn  : setTag(goods_id)
  shopSpr  : addChild(roleBtn)

  local iconSpr = _G.ImageAsyncManager:createGoodsSpr(icondata)
  iconSpr  : setPosition(cc.p(iconSize.width/2,iconSize.height/2))
  roleBtn  : addChild(iconSpr)

  local function BuyCallback(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      local buytag = sender : getTag()
      local Position = sender : getWorldPosition()
      print("Position.x",Position.x,m_winSize.width/2-doubleSize.width/2)
      if Position.x > m_winSize.width/2+doubleSize.width/2 or Position.x < m_winSize.width/2-doubleSize.width/2
        or buytag <= 0 then return end
      print("弹出对应的购买框", buytag)
      local msg = REQ_SHOP_BUY()
      msg :setArgs(20,2010,idx,buytag,1,_data.type) 
      _G.Network : send(msg)
    end
  end

  local buyBtn = gc.CButton:create("general_btn_gold.png")
  buyBtn : setPosition(self.shopSize.width/2,30)
  buyBtn : addTouchEventListener(BuyCallback)
  buyBtn : setTitleText("抢 购")
  buyBtn : setTitleFontName(_G.FontName.Heiti)
  buyBtn : setTitleFontSize(FONTSIZE+4)
  -- buyBtn : setButtonScale(0.8)
  --buyBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
  buyBtn : setSwallowTouches(false)
  buyBtn : setTag(goods_id) 
  shopSpr : addChild(buyBtn)
  if _data.total_remaider_num==0 then
    buyBtn : setTitleText("售完")
    buyBtn : setEnabled(false)
    buyBtn : setBright(false)
    shop_hot : setSpriteFrame("timeshop_wan.png")
  end

  self.btnArray[idx].Btn=buyBtn
  return shopSpr
end

function RushView.initCountdown(self)
    if not self.timenext then return end
    local m_serverTime = _G.TimeUtil : getServerTimeSeconds()
    self.timenext = self.timenext - 1
    print("m_endTimes", self.timenext,m_serverTime)
    local time = ""
    if self.timenext <= 0 then
        self : uncountdownEvent()
        local msg  = REQ_REWARD_BEGIN()
        _G.Network : send( msg )
        self.endtimeLab : setString("00:00:00")
        for i=1,self.count do
          local goodData = self.m_msg[i]
          self.btnArray[goodData.idx].Btn:setTitleText("售完")
          self.btnArray[goodData.idx].Btn:setBright(false)
          self.btnArray[goodData.idx].Btn:setEnabled(false)
          self.btnArray[goodData.idx].Spr:setSpriteFrame("timeshop_wan.png")
        end
    else
        time = self : getTimeStr(self.timenext)
        self.endtimeLab : setString(time)
    end
end

function RushView.BUYFailureReturn(self)
  local szMsg="钻石不足，是否前往充值？"
  local function fun1()
    print("跳转到充值界面")
    self:closeWindow()
    _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE)
  end
  _G.Util:showTipsBox(szMsg,fun1)
end

function RushView.closeWindow( self )
  print("关闭限时抢购")
  if self.m_rootLayer == nil then return end
  self.m_rootLayer=nil
  cc.Director:getInstance():popScene()
  self : uncountdownEvent()
  self : destroy()
end

function RushView.countdownEvent( self )
    local function local_scheduler()
        self : initCountdown()
    end
    self.m_timeScheduler =  _G.Scheduler : schedule(local_scheduler, 1)
end

function RushView.uncountdownEvent( self )
    if self.m_timeScheduler ~= nil then
        _G.Scheduler : unschedule(self.m_timeScheduler )
        self.m_timeScheduler = nil
    end
end

function RushView.getTimeStr( self, _time)
    _time = _time < 0 and 0 or _time
    local hour   = math.floor(_time/3600)
    local min    = math.floor(_time%3600/60)
    local second = math.floor(_time%60)

    if hour < 10 then hour = "0"..hour
    elseif hour < 0 then hour = "00" end

    if min < 10 then min = "0"..min
    elseif min < 0 then min = "00" end

    if second < 10 then second = "0"..second end
    local time = tostring(hour)..":"..tostring(min)..":"..second

    return time
end

return RushView